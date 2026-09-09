import 'package:flutter/services.dart';

import '../context/context_slice.dart';
import '../context/drift_context_slice.dart';
import '../data/conversation_repository.dart';
import '../data/user_profile_repository.dart';
import '../domain/agent_role.dart';
import '../knowledge/knowledge_retriever.dart';
import '../llm/llm_types.dart';
import '../safety/safety_gate.dart';
import 'offline_default_reply.dart';
import 'tool_acl.dart';
import 'tools/get_current_time_tool.dart';
import 'tools/update_profile_tool.dart';

class GraphTurnResult {
  const GraphTurnResult({
    required this.assistantContent,
    required this.blockedBySafety,
    required this.llmCalls,
    this.sourceTitles = const [],
    this.assistantMessageId,
    this.toolsUsed = const [],
    this.usedOfflineDefault = false,
  });

  final String assistantContent;
  final bool blockedBySafety;
  final int llmCalls;
  final List<String> sourceTitles;
  final int? assistantMessageId;
  final List<AgentTool> toolsUsed;
  final bool usedOfflineDefault;
}

/// Hard-coded P1 graph: Safety → retrieve → tools → context → LLM|offline → persist → summary.
class XiaonuanGraph {
  XiaonuanGraph({
    required this.safety,
    required this.retriever,
    required this.messages,
    required this.systemPrompt,
    LlmClient? llm,
    LlmClient Function()? resolveLlm,
    ContextSlicer? slicer,
    SummaryWriter? summaryWriter,
    this.profiles,
    this.userId = 1,
    this.speaker = AgentRole.xiaonuan,
    this.clock,
    this.offlineReplyDelay = const Duration(milliseconds: 650),
  })  : assert(
          llm != null || resolveLlm != null,
          'Provide llm or resolveLlm',
        ),
        _llm = llm,
        _resolveLlm = resolveLlm,
        slicer = slicer ?? EmptyContextSlicer(),
        summaryWriter = summaryWriter ?? NoopSummaryWriter();

  final SafetyGate safety;
  final KnowledgeRetriever retriever;
  final LlmClient? _llm;
  final LlmClient Function()? _resolveLlm;
  final ConversationRepository messages;
  final String systemPrompt;
  final ContextSlicer slicer;
  final SummaryWriter summaryWriter;
  final UserProfileRepository? profiles;
  final int userId;
  final AgentRole speaker;

  /// Injectable clock for [GetCurrentTimeTool] (tests).
  final DateTime Function()? clock;

  /// Artificial pause so the chat typing animation is visible in offline mode.
  final Duration offlineReplyDelay;

  /// Prefer [resolveLlm] so Riverpod model switches do not dispose this graph mid-turn.
  LlmClient get llm => _resolveLlm?.call() ?? _llm!;

  static const assetPromptPath =
      'assets/fixtures/prompts/xiaonuan_system_prompt.txt';

  static Future<String> loadSystemPrompt({AssetBundle? bundle}) {
    return (bundle ?? rootBundle).loadString(assetPromptPath);
  }

  Future<GraphTurnResult> handle({
    required int conversationId,
    required String userText,
    void Function(AgentRole speaker, String partial)? onPartial,
  }) async {
    if (safety is LocalSafetyGate) {
      (safety as LocalSafetyGate).conversationId = '$conversationId';
    }
    final decision = safety.inspect(userText);
    if (decision.block) {
      final id = await messages.insertAssistantMessage(
        conversationId: conversationId,
        content: decision.reply ?? '',
        speaker: speaker,
        safetyBadge: true,
      );
      return GraphTurnResult(
        assistantContent: decision.reply ?? '',
        blockedBySafety: true,
        llmCalls: 0,
        assistantMessageId: id,
      );
    }

    final hits = await _retrieveForRole(userText);
    final sources = hits.map((h) => h.title).take(3).toList();
    final toolsUsed = <AgentTool>[];
    final timeResult = _maybeRunCurrentTime(userText, toolsUsed);
    final profileResult = await _maybeUpdateProfile(userText, toolsUsed);

    final slice = await slicer.build(
      userId: userId,
      conversationId: conversationId,
    );

    var system = '$systemPrompt\n${slice.promptBlock}';
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
    if (profileResult != null) {
      system =
          '$system\n【工具】${UpdateProfileTool.name}=${profileResult.summary}';
    }

    final String content;
    final int llmCalls;
    final bool usedOffline;
    final bool writeSummary;

    if (!llm.canCallRemote) {
      if (offlineReplyDelay > Duration.zero) {
        await Future<void>.delayed(offlineReplyDelay);
      }
      content = OfflineDefaultReply.build(
        speaker: speaker,
        userText: userText,
        currentTime: timeResult,
        profileUpdateSummary:
            profileResult?.applied == true ? profileResult!.summary : null,
      );
      llmCalls = 0;
      usedOffline = true;
      writeSummary = false;
    } else {
      final wireMessages = <ChatMessageWire>[
        ChatMessageWire(role: 'system', content: system),
        ...slice.recentTurns,
        ChatMessageWire(role: 'user', content: userText),
      ];

      final result = await collectLlmStream(
        llm.streamComplete(
          messages: wireMessages,
          requestId: _requestId(),
        ),
        onPartial: onPartial == null
            ? null
            : (partial) => onPartial(speaker, partial),
      );

      content = switch (result.status) {
        LlmStatus.ok => result.content ?? LlmUserCopy.retryLater,
        LlmStatus.missingKey => OfflineDefaultReply.build(
            speaker: speaker,
            userText: userText,
            currentTime: timeResult,
            profileUpdateSummary:
                profileResult?.applied == true ? profileResult!.summary : null,
          ),
        _ => LlmUserCopy.retryLater,
      };
      llmCalls = 1;
      usedOffline = result.status == LlmStatus.missingKey;
      writeSummary = result.status == LlmStatus.ok && result.content != null;
    }

    final id = await messages.insertAssistantMessage(
      conversationId: conversationId,
      content: content,
      speaker: speaker,
      sourceTitles: sources,
    );

    if (writeSummary) {
      await summaryWriter.writeTurnSummary(
        userId: userId,
        assistantContent: content,
        rawRef: 'msg:$id',
      );
    }

    return GraphTurnResult(
      assistantContent: content,
      blockedBySafety: false,
      llmCalls: llmCalls,
      sourceTitles: sources,
      assistantMessageId: id,
      toolsUsed: toolsUsed,
      usedOfflineDefault: usedOffline,
    );
  }

  String? _maybeRunCurrentTime(String userText, List<AgentTool> toolsUsed) {
    if (!ToolAcl.canUse(speaker, AgentTool.getCurrentTime)) return null;
    if (!GetCurrentTimeTool.shouldInvoke(userText)) return null;
    toolsUsed.add(AgentTool.getCurrentTime);
    return GetCurrentTimeTool.invoke(now: clock?.call());
  }

  Future<ProfileToolResult?> _maybeUpdateProfile(
    String userText,
    List<AgentTool> toolsUsed,
  ) async {
    final repo = profiles;
    if (repo == null) return null;
    if (!ToolAcl.canUse(speaker, AgentTool.updateProfile)) return null;
    if (!UpdateProfileTool.shouldInvoke(userText)) return null;
    final result = await UpdateProfileTool.invoke(
      profiles: repo,
      userText: userText,
      now: clock?.call(),
    );
    if (!result.applied) return null;
    toolsUsed.add(AgentTool.updateProfile);
    return result;
  }

  Future<List<KnowledgeHit>> _retrieveForRole(String userText) async {
    if (!ToolAcl.canUse(speaker, AgentTool.retrieveKb)) {
      return const [];
    }
    final hits = await retriever.search(userText, k: 3);
    if (speaker == AgentRole.suxin) {
      return hits.where((h) => ToolAcl.suxinMayUseChunk(h.id)).toList();
    }
    return hits;
  }

  static String _requestId() {
    final ms = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
    return 'xn-$ms';
  }
}
