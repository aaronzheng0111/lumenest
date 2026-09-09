import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_mom_baby/agent/offline_default_reply.dart';
import 'package:ai_mom_baby/agent/tool_acl.dart';
import 'package:ai_mom_baby/agent/tools/get_current_time_tool.dart';
import 'package:ai_mom_baby/agent/xiaonuan_graph.dart';
import 'package:ai_mom_baby/data/db/database_provider.dart';
import 'package:ai_mom_baby/data/drift_conversation_repository.dart';
import 'package:ai_mom_baby/domain/agent_role.dart';
import 'package:ai_mom_baby/knowledge/knowledge_retriever.dart';
import 'package:ai_mom_baby/llm/llm_types.dart';
import 'package:ai_mom_baby/safety/safety_gate.dart';

void main() {
  group('GetCurrentTimeTool', () {
    test('shouldInvoke matches time intents', () {
      expect(GetCurrentTimeTool.shouldInvoke('现在几点了？'), isTrue);
      expect(GetCurrentTimeTool.shouldInvoke('当前时间是多少'), isTrue);
      expect(GetCurrentTimeTool.shouldInvoke('what time is it'), isTrue);
      expect(GetCurrentTimeTool.shouldInvoke('今天有点累'), isFalse);
    });

    test('invoke formats fixed clock', () {
      final fixed = DateTime(2026, 9, 9, 14, 45, 3);
      expect(
        GetCurrentTimeTool.invoke(now: fixed, timeZoneLabel: 'CST'),
        '2026-09-09 14:45:03 (CST)',
      );
    });
  });

  test('ToolAcl allows getCurrentTime for all roles', () {
    for (final role in AgentRole.values) {
      expect(ToolAcl.canUse(role, AgentTool.getCurrentTime), isTrue);
    }
  });

  test('offline default reply without time', () {
    final text = OfflineDefaultReply.build(
      speaker: AgentRole.xiaonuan,
      userText: '今天有点累',
    );
    expect(text.contains('小暖'), isTrue);
    expect(text.contains('今天有点累'), isTrue);
    expect(text.contains('本地演示'), isTrue);
    expect(text.contains('未配置模型服务'), isFalse);
  });

  test('graph offline default: no remote call, still replies', () async {
    final db = DriftDatabaseProvider(executor: NativeDatabase.memory());
    await db.init();
    addTearDown(db.close);
    final repo = DriftConversationRepository(db);
    final llm = _OfflineLlm();
    final graph = XiaonuanGraph(
      safety: _PassGate(),
      retriever: FakeKnowledgeRetriever(),
      llm: llm,
      messages: repo,
      systemPrompt: '你是小暖',
      offlineReplyDelay: Duration.zero,
    );
    final cid = await repo.getOrCreateSolo(role: AgentRole.xiaonuan);
    final result = await graph.handle(
      conversationId: cid,
      userText: '今天有点累',
    );
    expect(result.usedOfflineDefault, isTrue);
    expect(result.llmCalls, 0);
    expect(llm.calls, 0);
    expect(result.assistantContent.contains('小暖'), isTrue);
    expect(result.assistantContent.contains('今天有点累'), isTrue);
    expect(result.assistantContent, isNot(LlmUserCopy.missingKey));
    final msgs = await repo.listMessages(cid);
    expect(msgs.where((m) => m.isAssistant), hasLength(1));
  });

  test('graph invokes get_current_time tool in offline mode', () async {
    final db = DriftDatabaseProvider(executor: NativeDatabase.memory());
    await db.init();
    addTearDown(db.close);
    final repo = DriftConversationRepository(db);
    final fixed = DateTime(2026, 9, 9, 14, 45, 3);
    final graph = XiaonuanGraph(
      safety: _PassGate(),
      retriever: FakeKnowledgeRetriever(),
      llm: _OfflineLlm(),
      messages: repo,
      systemPrompt: '你是小暖',
      clock: () => fixed,
      offlineReplyDelay: Duration.zero,
    );
    final cid = await repo.getOrCreateSolo(role: AgentRole.xiaonuan);
    final result = await graph.handle(
      conversationId: cid,
      userText: '现在几点了？',
    );
    expect(result.toolsUsed, [AgentTool.getCurrentTime]);
    expect(result.usedOfflineDefault, isTrue);
    expect(result.assistantContent.contains('2026-09-09 14:45:03'), isTrue);
  });

  test('graph injects time tool into remote system prompt', () async {
    final db = DriftDatabaseProvider(executor: NativeDatabase.memory());
    await db.init();
    addTearDown(db.close);
    final repo = DriftConversationRepository(db);
    final llm = _CountingLlm();
    final fixed = DateTime(2026, 1, 2, 3, 4, 5);
    final graph = XiaonuanGraph(
      safety: _PassGate(),
      retriever: FakeKnowledgeRetriever(),
      llm: llm,
      messages: repo,
      systemPrompt: '你是小暖',
      clock: () => fixed,
      offlineReplyDelay: Duration.zero,
    );
    final cid = await repo.getOrCreateSolo(role: AgentRole.xiaonuan);
    final result = await graph.handle(
      conversationId: cid,
      userText: '告诉我当前时间',
    );
    expect(result.toolsUsed, [AgentTool.getCurrentTime]);
    expect(result.llmCalls, 1);
    expect(llm.lastMessages!.first.content.contains('get_current_time='), isTrue);
    expect(llm.lastMessages!.first.content.contains('2026-01-02 03:04:05'), isTrue);
  });
}

class _OfflineLlm implements LlmClient {
  int calls = 0;

  @override
  bool get canCallRemote => false;

  @override
  Future<LlmResult> complete({
    required List<ChatMessageWire> messages,
    required String requestId,
  }) async {
    calls++;
    return const LlmResult(status: LlmStatus.missingKey);
  }
}

class _CountingLlm implements LlmClient {
  int calls = 0;
  List<ChatMessageWire>? lastMessages;

  @override
  bool get canCallRemote => true;

  @override
  Future<LlmResult> complete({
    required List<ChatMessageWire> messages,
    required String requestId,
  }) async {
    calls++;
    lastMessages = messages;
    return const LlmResult(status: LlmStatus.ok, content: '好的');
  }
}

class _PassGate implements SafetyGate {
  @override
  SafetyDecision inspect(String userText) => const SafetyDecision.pass();
}
