import '../context/context_slice.dart';
import '../data/conversation_repository.dart';
import '../data/db/domain_enums.dart';
import '../data/user_profile_repository.dart';
import '../domain/agent_role.dart';
import '../knowledge/knowledge_retriever.dart';
import '../llm/llm_types.dart';
import '../safety/safety_gate.dart';
import 'next_speaker.dart';
import 'offline_default_reply.dart';
import 'role_prompts.dart';
import 'tool_acl.dart';
import 'tools/get_current_time_tool.dart';
import 'tools/update_profile_tool.dart';
import 'xiaonuan_graph.dart';

/// GROUP turn: Safety → route → 1–2 LLM speakers → persist (AC-11-B04/B05).
///
/// All speakers share the same [LlmClient] (one model). Context mirrors
/// [XiaonuanGraph]: system = role prompt + slice.promptBlock + KB/tools, then a
/// single growing transcript (labeled assistants) so the second speaker sees the
/// first's full reply — not a truncated system note.
class GroupConsultGraph {
  GroupConsultGraph({
    required this.safety,
    required this.retriever,
    required this.messages,
    required this.slicer,
    required this.summaryWriter,
    required this.routerRules,
    LlmClient? llm,
    LlmClient Function()? resolveLlm,
    this.profiles,
    this.userId = 1,
    this.promptLoader = RolePrompts.load,
    this.clock,
    this.offlineReplyDelay = const Duration(milliseconds: 650),
  })  : assert(
          llm != null || resolveLlm != null,
          'Provide llm or resolveLlm',
        ),
        _llm = llm,
        _resolveLlm = resolveLlm;

  final SafetyGate safety;
  final KnowledgeRetriever retriever;
  final LlmClient? _llm;
  final LlmClient Function()? _resolveLlm;
  final ConversationRepository messages;
  final ContextSlicer slicer;
  final SummaryWriter summaryWriter;
  final List<RouterRule> routerRules;
  final UserProfileRepository? profiles;
  final int userId;
  final Future<String> Function(AgentRole role) promptLoader;
  final DateTime Function()? clock;
  final Duration offlineReplyDelay;

  LlmClient get llm => _resolveLlm?.call() ?? _llm!;

  Future<GraphTurnResult> handle({
    required int conversationId,
    required String userText,
    bool hasImage = false,
    int? riskScore,
    void Function(AgentRole speaker, String partial)? onPartial,
    Future<void> Function()? onSpeakerPersisted,
  }) async {
    if (safety is LocalSafetyGate) {
      (safety as LocalSafetyGate).conversationId = '$conversationId';
    }
    final safetyDecision = safety.inspect(userText);
    if (safetyDecision.block) {
      final id = await messages.insertAssistantMessage(
        conversationId: conversationId,
        content: safetyDecision.reply ?? '',
        speaker: AgentRole.xiaonuan,
        safetyBadge: true,
      );
      return GraphTurnResult(
        assistantContent: safetyDecision.reply ?? '',
        blockedBySafety: true,
        llmCalls: 0,
        assistantMessageId: id,
      );
    }

    final route = await resolveSpeakersAsync(
      type: ConversationTypeWire.group,
      soloRole: AgentRole.xiaonuan,
      userText: userText,
      hasImage: hasImage,
      riskScore: riskScore,
      routerRules: routerRules,
      intentLlm: llm,
    );
    final speakers = route.speakers;

    final toolsUsed = <AgentTool>[];
    final timeResult = _maybeRunCurrentTime(
      speakers.isEmpty ? AgentRole.xiaonuan : speakers.first,
      userText,
      toolsUsed,
    );
    // Group write-back is Xiaonuan-only (orchestra), even if ToolAcl allows
    // specialists in solo. Specialist-only rounds (e.g. @林医生) skip profile.
    final profileResult = await _maybeUpdateProfile(
      speakers.isEmpty || speakers.contains(AgentRole.xiaonuan)
          ? AgentRole.xiaonuan
          : speakers.first,
      userText,
      toolsUsed,
    );

    final slice = await slicer.build(
      userId: userId,
      conversationId: conversationId,
    );

    final transcript = <ChatMessageWire>[
      ...slice.recentTurns,
      ChatMessageWire(role: 'user', content: userText),
    ];

    var llmCalls = 0;
    String? lastContent;
    int? lastId;
    final allSources = <String>[];
    var usedOffline = false;
    final speakerList = speakers.take(2).toList();

    for (final speaker in speakerList) {
      String prompt;
      try {
        prompt = await promptLoader(speaker);
      } catch (_) {
        prompt = '你是${speaker.displayName}';
      }
      final hits = await _retrieveForRole(speaker, userText);
      final sources = hits.map((h) => h.title).take(3).toList();
      allSources.addAll(sources);

      var system = '$prompt\n${slice.promptBlock}';
      system = '$system\n${_groupIdentityBlock(speaker, speakerList)}';
      if (hits.isNotEmpty) {
        final buf = StringBuffer('\n【本地资料】\n');
        for (final h in hits) {
          buf.writeln('- ${h.title}: ${h.text}');
        }
        system = '$system$buf';
      }
      if (timeResult != null) {
        system = '$system\n【工具】${GetCurrentTimeTool.name}=$timeResult';
      }
      // Only tell Xiaonuan about profile tool outcomes (avoid specialist echo).
      if (profileResult != null && speaker == AgentRole.xiaonuan) {
        system =
            '$system\n【工具】${UpdateProfileTool.name}=${profileResult.summary}';
      }

      final String content;
      final bool writeSummary;

      if (!llm.canCallRemote) {
        if (offlineReplyDelay > Duration.zero) {
          await Future<void>.delayed(offlineReplyDelay);
        }
        content = OfflineDefaultReply.build(
          speaker: speaker,
          userText: userText,
          currentTime: timeResult,
          profileUpdateSummary: speaker == AgentRole.xiaonuan &&
                  profileResult?.applied == true
              ? profileResult!.summary
              : null,
          profileProposeSummary: speaker == AgentRole.xiaonuan &&
                  profileResult?.proposeOnly == true
              ? profileResult!.summary
              : null,
        );
        usedOffline = true;
        writeSummary = false;
      } else {
        final result = await collectLlmStream(
          llm.streamComplete(
            messages: [
              ChatMessageWire(role: 'system', content: system),
              ...transcript,
            ],
            requestId:
                'grp-${speaker.wireId}-${DateTime.now().microsecondsSinceEpoch}',
          ),
          onPartial: onPartial == null
              ? null
              : (partial) => onPartial(speaker, partial),
        );
        llmCalls++;

        content = switch (result.status) {
          LlmStatus.ok => result.content ?? LlmUserCopy.retryLater,
          LlmStatus.missingKey => OfflineDefaultReply.build(
              speaker: speaker,
              userText: userText,
              currentTime: timeResult,
              profileUpdateSummary: speaker == AgentRole.xiaonuan &&
                      profileResult?.applied == true
                  ? profileResult!.summary
                  : null,
              profileProposeSummary: speaker == AgentRole.xiaonuan &&
                      profileResult?.proposeOnly == true
                  ? profileResult!.summary
                  : null,
            ),
          _ => LlmUserCopy.retryLater,
        };
        if (result.status == LlmStatus.missingKey) usedOffline = true;
        writeSummary = result.status == LlmStatus.ok && result.content != null;
      }
      lastContent = content;

      final handoffRef = speakerList.length > 1
          ? 'handoff:${speakerList.map((s) => s.wireId).join('>')}'
          : null;
      lastId = await messages.insertAssistantMessage(
        conversationId: conversationId,
        content: content,
        speaker: speaker,
        sourceTitles: sources,
        agentReplyRef: handoffRef,
      );

      if (onSpeakerPersisted != null) {
        await onSpeakerPersisted();
      }

      transcript.add(
        ChatMessageWire(
          role: 'assistant',
          content: '${speaker.displayName}：$content',
        ),
      );

      if (writeSummary) {
        await summaryWriter.writeTurnSummary(
          userId: userId,
          assistantContent: content,
          rawRef: 'msg:$lastId',
        );
      }
    }

    return GraphTurnResult(
      assistantContent: lastContent ?? '',
      blockedBySafety: false,
      llmCalls: llmCalls,
      sourceTitles: allSources.take(3).toList(),
      assistantMessageId: lastId,
      toolsUsed: toolsUsed,
      usedOfflineDefault: usedOffline,
    );
  }

  String? _maybeRunCurrentTime(
    AgentRole speaker,
    String userText,
    List<AgentTool> toolsUsed,
  ) {
    if (!ToolAcl.canUse(speaker, AgentTool.getCurrentTime)) return null;
    if (!GetCurrentTimeTool.shouldInvoke(userText)) return null;
    toolsUsed.add(AgentTool.getCurrentTime);
    return GetCurrentTimeTool.invoke(now: clock?.call());
  }

  /// Short per-turn identity / orchestra boundaries (not baked into role txt).
  static String _groupIdentityBlock(
    AgentRole speaker,
    List<AgentRole> speakerList,
  ) {
    final hasSpecialist = speakerList.any((r) => r != AgentRole.xiaonuan);
    final buf = StringBuffer(
      '【会诊身份】你当前角色是「${speaker.displayName}」。'
      '只以本身份自居；严禁冒充其他角色'
      '（例如不是小暖时不得自称小暖）。'
      '历史消息里带姓名前缀的是其他会诊成员说的话，仅作参考。',
    );
    if (speaker == AgentRole.xiaonuan && hasSpecialist) {
      final next = speakerList.firstWhere((r) => r != AgentRole.xiaonuan);
      buf.write(
        '你是编排者：先接住用户，点名下一位「${next.displayName}」，'
        '并明确告诉用户本轮「以${next.displayName}为准」。',
      );
    } else if (speaker != AgentRole.xiaonuan) {
      buf.write(
        '你是专科补充：只答本职领域；不要宣称已改档案；'
        '不要重新分配发言权或点名下一位。',
      );
    }
    return buf.toString();
  }

  Future<ProfileToolResult?> _maybeUpdateProfile(
    AgentRole speaker,
    String userText,
    List<AgentTool> toolsUsed,
  ) async {
    final repo = profiles;
    if (repo == null) return null;
    // Boundary: group profile write-back only for Xiaonuan (orchestra).
    if (speaker != AgentRole.xiaonuan) return null;
    if (!ToolAcl.canUse(speaker, AgentTool.updateProfile)) return null;
    if (!UpdateProfileTool.shouldInvoke(userText)) return null;
    final result = await UpdateProfileTool.invoke(
      profiles: repo,
      userText: userText,
      now: clock?.call(),
    );
    if (result.applied) {
      toolsUsed.add(AgentTool.updateProfile);
      return result;
    }
    if (result.proposeOnly) return result;
    return null;
  }

  Future<List<KnowledgeHit>> _retrieveForRole(
    AgentRole speaker,
    String userText,
  ) async {
    if (!ToolAcl.canUse(speaker, AgentTool.retrieveKb)) return const [];
    final hits = await retriever.search(userText, k: 3);
    if (speaker == AgentRole.suxin) {
      return hits.where((h) => ToolAcl.suxinMayUseChunk(h.id)).toList();
    }
    return hits;
  }
}
