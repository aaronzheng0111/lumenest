import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_mom_baby/agent/xiaonuan_graph.dart';
import 'package:ai_mom_baby/data/db/database_provider.dart';
import 'package:ai_mom_baby/data/drift_conversation_repository.dart';
import 'package:ai_mom_baby/domain/agent_role.dart';
import 'package:ai_mom_baby/knowledge/knowledge_retriever.dart';
import 'package:ai_mom_baby/llm/llm_types.dart';
import 'package:ai_mom_baby/safety/safety_gate.dart';

void main() {
  test('AC-08-B03 system prompt contains required substrings', () {
    final text = File(
      '../sdd/08-p1-agent-xiaonuan-demo/fixtures/xiaonuan_system_prompt.txt',
    ).readAsStringSync();
    for (final needle in [
      '先共情，再解答',
      '用“人话”说专业',
      '正向收尾，给行动建议',
      '不给出诊断结论',
      '不提供用药剂量',
      '你是小暖',
    ]) {
      expect(text.contains(needle), isTrue, reason: needle);
    }
  });

  test('AC-08-B01/B02 safety block → llm calls 0', () async {
    final db = DriftDatabaseProvider(executor: NativeDatabase.memory());
    await db.init();
    addTearDown(db.close);
    final repo = DriftConversationRepository(db);
    final llm = _CountingLlm();
    final safety = _BlockingGate();
    final graph = XiaonuanGraph(
      safety: safety,
      retriever: FakeKnowledgeRetriever(),
      llm: llm,
      messages: repo,
      systemPrompt: '你是小暖\n先共情，再解答\n用“人话”说专业\n正向收尾，给行动建议\n不给出诊断结论\n不提供用药剂量',
    );
    final cid = await repo.getOrCreateSolo(role: AgentRole.xiaonuan);
    final result = await graph.handle(
      conversationId: cid,
      userText: '出血了怎么办',
    );
    expect(result.blockedBySafety, isTrue);
    expect(result.llmCalls, 0);
    expect(llm.calls, 0);
    final msgs = await repo.listMessages(cid);
    expect(msgs.single.safetyBadge, isTrue);
  });

  test('AC-08-B02 pass → llm calls 1 and messages length 2', () async {
    final db = DriftDatabaseProvider(executor: NativeDatabase.memory());
    await db.init();
    addTearDown(db.close);
    final repo = DriftConversationRepository(db);
    final llm = _CountingLlm(reply: '先歇一歇，喝口水也好。');
    final graph = XiaonuanGraph(
      safety: _PassGate(),
      retriever: FakeKnowledgeRetriever(
        hits: const [
          KnowledgeHit(
            id: 'kb-rest',
            title: '休息',
            text: '适度休息',
            score: 1.0,
          ),
        ],
      ),
      llm: llm,
      messages: repo,
      systemPrompt: '你是小暖',
    );
    final cid = await repo.getOrCreateSolo(role: AgentRole.xiaonuan);
    final result = await graph.handle(
      conversationId: cid,
      userText: '今天有点累',
    );
    expect(result.blockedBySafety, isFalse);
    expect(result.llmCalls, 1);
    expect(llm.calls, 1);
    expect(llm.lastMessages?.length, 2);
    expect(llm.lastMessages!.first.role, 'system');
    expect(llm.lastMessages!.last.role, 'user');
    expect(result.assistantContent, '先歇一歇，喝口水也好。');
    expect(result.sourceTitles, ['休息']);
    expect(
      result.assistantContent.contains('林医生') ||
          result.assistantContent.contains('GPT'),
      isFalse,
    );
  });
}

class _CountingLlm extends LlmClient {
  _CountingLlm({this.reply = 'ok'});

  final String reply;
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
    return LlmResult(status: LlmStatus.ok, content: reply);
  }
}

class _BlockingGate implements SafetyGate {
  @override
  SafetyDecision inspect(String userText) {
    return const SafetyDecision.block(
      category: 'MEDICAL_EMERGENCY',
      patternId: 'bleed',
      reply: '请立即就医',
    );
  }
}

class _PassGate implements SafetyGate {
  @override
  SafetyDecision inspect(String userText) => const SafetyDecision.pass();
}
