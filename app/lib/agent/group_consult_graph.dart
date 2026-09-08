import '../context/context_slice.dart';
import '../data/conversation_repository.dart';
import '../data/db/domain_enums.dart';
import '../domain/agent_role.dart';
import '../knowledge/knowledge_retriever.dart';
import '../llm/llm_types.dart';
import '../safety/safety_gate.dart';
import 'next_speaker.dart';
import 'role_prompts.dart';
import 'tool_acl.dart';
import 'xiaonuan_graph.dart';

/// GROUP turn: Safety → route → 1–2 LLM speakers → persist (AC-11-B04/B05).
class GroupConsultGraph {
  GroupConsultGraph({
    required this.safety,
    required this.retriever,
    required this.llm,
    required this.messages,
    required this.slicer,
    required this.summaryWriter,
    required this.routerRules,
    this.userId = 1,
    this.promptLoader = RolePrompts.load,
  });

  final SafetyGate safety;
  final KnowledgeRetriever retriever;
  final LlmClient llm;
  final ConversationRepository messages;
  final ContextSlicer slicer;
  final SummaryWriter summaryWriter;
  final List<RouterRule> routerRules;
  final int userId;
  final Future<String> Function(AgentRole role) promptLoader;

  Future<GraphTurnResult> handle({
    required int conversationId,
    required String userText,
    bool hasImage = false,
    int? riskScore,
  }) async {
    if (safety is LocalSafetyGate) {
      (safety as LocalSafetyGate).conversationId = '$conversationId';
    }
    final decision = safety.inspect(userText);
    if (decision.block) {
      final id = await messages.insertAssistantMessage(
        conversationId: conversationId,
        content: decision.reply ?? '',
        speaker: AgentRole.xiaonuan,
        safetyBadge: true,
      );
      return GraphTurnResult(
        assistantContent: decision.reply ?? '',
        blockedBySafety: true,
        llmCalls: 0,
        assistantMessageId: id,
      );
    }

    final speakers = resolveSpeakers(
      type: ConversationTypeWire.group,
      soloRole: AgentRole.xiaonuan,
      userText: userText,
      hasImage: hasImage,
      riskScore: riskScore,
      routerRules: routerRules,
    );

    final slice = await slicer.build(
      userId: userId,
      conversationId: conversationId,
    );

    var llmCalls = 0;
    String? lastContent;
    int? lastId;
    final allSources = <String>[];
    String? previousRef;

    for (final speaker in speakers.take(2)) {
      final prompt = await promptLoader(speaker);
      final hits = await _retrieveForRole(speaker, userText);
      final sources = hits.map((h) => h.title).take(3).toList();
      allSources.addAll(sources);

      var system = '$prompt\n${slice.promptBlock}';
      if (hits.isNotEmpty) {
        final buf = StringBuffer('\n【本地资料】\n');
        for (final h in hits) {
          buf.writeln('- ${h.title}: ${h.text}');
        }
        system = '$system$buf';
      }
      if (previousRef != null) {
        system = '$system\n【上一助手】$previousRef';
      }

      final result = await llm.complete(
        messages: [
          ChatMessageWire(role: 'system', content: system),
          ...slice.recentTurns,
          ChatMessageWire(role: 'user', content: userText),
        ],
        requestId: 'grp-${speaker.wireId}-${DateTime.now().microsecondsSinceEpoch}',
      );
      llmCalls++;

      final content = switch (result.status) {
        LlmStatus.ok => result.content ?? LlmUserCopy.retryLater,
        LlmStatus.missingKey => LlmUserCopy.missingKey,
        _ => LlmUserCopy.retryLater,
      };
      lastContent = content;

      final handoffRef = speakers.length > 1
          ? 'handoff:${speakers.map((s) => s.wireId).join('>')}'
          : null;
      lastId = await messages.insertAssistantMessage(
        conversationId: conversationId,
        content: content,
        speaker: speaker,
        sourceTitles: sources,
        agentReplyRef: handoffRef,
      );
      previousRef = '${speaker.displayName}: ${content.length > 40 ? content.substring(0, 40) : content}';

      if (result.status == LlmStatus.ok && result.content != null) {
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
    );
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
