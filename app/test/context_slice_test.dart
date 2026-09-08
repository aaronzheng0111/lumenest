import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_mom_baby/agent/xiaonuan_graph.dart';
import 'package:ai_mom_baby/context/context_slice.dart';
import 'package:ai_mom_baby/context/drift_context_slice.dart';
import 'package:ai_mom_baby/data/db/database_provider.dart';
import 'package:ai_mom_baby/data/db/domain_enums.dart';
import 'package:ai_mom_baby/data/drift_conversation_repository.dart';
import 'package:ai_mom_baby/data/drift_user_profile_repository.dart';
import 'package:ai_mom_baby/domain/agent_role.dart';
import 'package:ai_mom_baby/domain/stage.dart';
import 'package:ai_mom_baby/domain/user_profile_snapshot.dart';
import 'package:ai_mom_baby/knowledge/knowledge_retriever.dart';
import 'package:ai_mom_baby/llm/llm_types.dart';
import 'package:ai_mom_baby/safety/safety_gate.dart';

void main() {
  final limits = jsonDecode(
    File('../sdd/09-context-slice-memory/fixtures/slice_limits.json')
        .readAsStringSync(),
  ) as Map<String, dynamic>;
  final titles = (limits['prompt_titles'] as List).cast<String>();

  test('T09-01 promptBlock title order', () {
    final block = buildPromptBlock(
      snapshot: const UserProfileSnapshot(
        stage: Stage.pregnant,
        weekValue: 16,
        weekUnit: 'PREGNANCY_WEEK',
      ),
      habitsText: '早睡',
      summariesText: '昨天有点累',
    );
    expect(block.contains(titles[0]), isTrue);
    expect(block.contains(titles[1]), isTrue);
    expect(block.contains(titles[2]), isTrue);
    expect(block.indexOf(titles[0]), lessThan(block.indexOf(titles[1])));
    expect(block.indexOf(titles[1]), lessThan(block.indexOf(titles[2])));
    expect(block, contains('阶段=孕期'));
    expect(block, contains('周次=16PREGNANCY_WEEK'));
  });

  test('T09-03 SummaryWriter truncates to 80 chars', () {
    final long = '啊' * 120;
    final cut = truncateSummary(long, maxChars: limits['summary_max_chars'] as int);
    expect(cut.length, 80);
  });

  test('T09-02 recent turns capped at 20 excluding current user', () async {
    final db = DriftDatabaseProvider(executor: NativeDatabase.memory());
    await db.init();
    addTearDown(db.close);
    final repo = DriftConversationRepository(db);
    final profiles = DriftUserProfileRepository(db);
    final slicer = DriftContextSlicer(
      databaseProvider: db,
      profiles: profiles,
      messages: repo,
    );
    final cid = await repo.getOrCreateSolo(role: AgentRole.xiaonuan);
    for (var i = 0; i < 25; i++) {
      await repo.insertUserMessage(conversationId: cid, content: 'u$i');
      await repo.insertAssistantMessage(
        conversationId: cid,
        content: 'a$i',
        speaker: AgentRole.xiaonuan,
      );
    }
    await repo.insertUserMessage(conversationId: cid, content: 'current');
    final slice = await slicer.build(userId: 1, conversationId: cid);
    expect(slice.recentTurns.length, 20);
    expect(slice.recentTurns.any((m) => m.content == 'current'), isFalse);
    expect(slice.recentTurns.last.content, 'a24');
  });

  test('T09-04 graph injects promptBlock and writes summary on ok', () async {
    final db = DriftDatabaseProvider(executor: NativeDatabase.memory());
    await db.init();
    addTearDown(db.close);
    final repo = DriftConversationRepository(db);
    final profiles = DriftUserProfileRepository(db);
    final llm = _CountingLlm(reply: '先歇一歇吧。');
    final writer = DriftSummaryWriter(
      databaseProvider: db,
      profiles: profiles,
    );
    final graph = XiaonuanGraph(
      safety: _PassGate(),
      retriever: FakeKnowledgeRetriever(),
      llm: llm,
      messages: repo,
      systemPrompt: '你是小暖',
      slicer: DriftContextSlicer(
        databaseProvider: db,
        profiles: profiles,
        messages: repo,
      ),
      summaryWriter: writer,
    );
    final cid = await repo.getOrCreateSolo(role: AgentRole.xiaonuan);
    await repo.insertUserMessage(conversationId: cid, content: '今天有点累');
    await graph.handle(conversationId: cid, userText: '今天有点累');
    expect(llm.calls, 1);
    final system = llm.lastMessages!.first.content;
    expect(system.contains('【档案】'), isTrue);
    expect(system.contains('【习惯】'), isTrue);
    expect(system.contains('【近期摘要】'), isTrue);

    final events = await db.db.select(db.db.profileEvents).get();
    expect(events.where((e) => e.category == ProfileCategoryWire.summary), isNotEmpty);

    await writer.clearSummaries(userId: 1);
    final after = await db.db.select(db.db.profileEvents).get();
    expect(after.where((e) => e.category == ProfileCategoryWire.summary), isEmpty);
    final msgs = await repo.listMessages(cid);
    expect(msgs.length, 2); // user + assistant bubbles remain
  });

  test('failed LLM does not write summary', () async {
    final db = DriftDatabaseProvider(executor: NativeDatabase.memory());
    await db.init();
    addTearDown(db.close);
    final repo = DriftConversationRepository(db);
    final profiles = DriftUserProfileRepository(db);
    final writer = DriftSummaryWriter(
      databaseProvider: db,
      profiles: profiles,
    );
    final graph = XiaonuanGraph(
      safety: _PassGate(),
      retriever: FakeKnowledgeRetriever(),
      llm: _FailLlm(),
      messages: repo,
      systemPrompt: '你是小暖',
      slicer: EmptyContextSlicer(),
      summaryWriter: writer,
    );
    final cid = await repo.getOrCreateSolo(role: AgentRole.xiaonuan);
    await graph.handle(conversationId: cid, userText: '你好');
    final events = await db.db.select(db.db.profileEvents).get();
    expect(events, isEmpty);
  });
}

class _CountingLlm implements LlmClient {
  _CountingLlm({this.reply = 'ok'});
  final String reply;
  int calls = 0;
  List<ChatMessageWire>? lastMessages;

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

class _FailLlm implements LlmClient {
  @override
  Future<LlmResult> complete({
    required List<ChatMessageWire> messages,
    required String requestId,
  }) async {
    return const LlmResult(status: LlmStatus.timeout);
  }
}

class _PassGate implements SafetyGate {
  @override
  SafetyDecision inspect(String userText) => const SafetyDecision.pass();
}
