import 'package:flutter/services.dart';

import '../data/conversation_repository.dart';
import '../domain/agent_role.dart';
import '../knowledge/knowledge_retriever.dart';
import '../llm/llm_types.dart';
import '../safety/safety_gate.dart';

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

/// Hard-coded P1 graph: Safety → retrieve → LLM(0|1) → persist.
class XiaonuanGraph {
  XiaonuanGraph({
    required this.safety,
    required this.retriever,
    required this.llm,
    required this.messages,
    required this.systemPrompt,
  });

  final SafetyGate safety;
  final KnowledgeRetriever retriever;
  final LlmClient llm;
  final ConversationRepository messages;
  final String systemPrompt;

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

    final hits = await retriever.search(userText, k: 3);
    final sources = hits.map((h) => h.title).take(3).toList();
    var system = systemPrompt;
    if (hits.isNotEmpty) {
      final buf = StringBuffer('\n【本地资料】\n');
      for (final h in hits) {
        buf.writeln('- ${h.title}: ${h.text}');
      }
      system = '$systemPrompt$buf';
    }

    final result = await llm.complete(
      messages: [
        ChatMessageWire(role: 'system', content: system),
        ChatMessageWire(role: 'user', content: userText),
      ],
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
      speaker: AgentRole.xiaonuan,
      sourceTitles: sources,
    );

    return GraphTurnResult(
      assistantContent: content,
      blockedBySafety: false,
      llmCalls: 1,
      sourceTitles: sources,
      assistantMessageId: id,
    );
  }

  static String _requestId() {
    final ms = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
    return 'xn-$ms';
  }
}
