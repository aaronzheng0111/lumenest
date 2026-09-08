import 'package:flutter/services.dart';

import '../context/context_slice.dart';
import '../context/drift_context_slice.dart';
import '../data/conversation_repository.dart';
import '../domain/agent_role.dart';
import '../knowledge/knowledge_retriever.dart';
import '../llm/llm_types.dart';
import '../safety/safety_gate.dart';
import 'tool_acl.dart';

class GraphTurnResult {
  const GraphTurnResult({
    required this.assistantContent,
    required this.blockedBySafety,
    required this.llmCalls,
    this.sourceTitles = const [],
    this.assistantMessageId,
  });

  final String assistantContent;
  final bool blockedBySafety;
  final int llmCalls;
  final List<String> sourceTitles;
  final int? assistantMessageId;
}

/// Hard-coded P1 graph: Safety → retrieve → context → LLM(0|1) → persist → summary.
class XiaonuanGraph {
  XiaonuanGraph({
    required this.safety,
    required this.retriever,
    required this.llm,
    required this.messages,
    required this.systemPrompt,
    ContextSlicer? slicer,
    SummaryWriter? summaryWriter,
    this.userId = 1,
    this.speaker = AgentRole.xiaonuan,
  })  : slicer = slicer ?? EmptyContextSlicer(),
        summaryWriter = summaryWriter ?? NoopSummaryWriter();

  final SafetyGate safety;
  final KnowledgeRetriever retriever;
  final LlmClient llm;
  final ConversationRepository messages;
  final String systemPrompt;
  final ContextSlicer slicer;
  final SummaryWriter summaryWriter;
  final int userId;
  final AgentRole speaker;

  static const assetPromptPath =
      'assets/fixtures/prompts/xiaonuan_system_prompt.txt';

  static Future<String> loadSystemPrompt({AssetBundle? bundle}) {
    return (bundle ?? rootBundle).loadString(assetPromptPath);
  }

  Future<GraphTurnResult> handle({
    required int conversationId,
    required String userText,
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
    final slice = await slicer.build(
      userId: userId,
      conversationId: conversationId,
    );

    var system = '${systemPrompt}\n${slice.promptBlock}';
    if (hits.isNotEmpty) {
      final buf = StringBuffer('\n【本地资料】\n');
      for (final h in hits) {
        buf.writeln('- ${h.title}: ${h.text}');
      }
      system = '$system$buf';
    }

    final wireMessages = <ChatMessageWire>[
      ChatMessageWire(role: 'system', content: system),
      ...slice.recentTurns,
      ChatMessageWire(role: 'user', content: userText),
    ];

    final result = await llm.complete(
      messages: wireMessages,
      requestId: _requestId(),
    );

    final content = switch (result.status) {
      LlmStatus.ok => result.content ?? LlmUserCopy.retryLater,
      LlmStatus.missingKey => LlmUserCopy.missingKey,
      _ => LlmUserCopy.retryLater,
    };

    final id = await messages.insertAssistantMessage(
      conversationId: conversationId,
      content: content,
      speaker: speaker,
      sourceTitles: sources,
    );

    if (result.status == LlmStatus.ok && result.content != null) {
      // Fire-and-forget style write; await so tests can observe.
      await summaryWriter.writeTurnSummary(
        userId: userId,
        assistantContent: content,
        rawRef: 'msg:$id',
      );
    }

    return GraphTurnResult(
      assistantContent: content,
      blockedBySafety: false,
      llmCalls: 1,
      sourceTitles: sources,
      assistantMessageId: id,
    );
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
