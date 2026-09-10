import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_mom_baby/agent/group_consult_graph.dart';
import 'package:ai_mom_baby/agent/group_intent_router.dart';
import 'package:ai_mom_baby/agent/next_speaker.dart';
import 'package:ai_mom_baby/agent/tool_acl.dart';
import 'package:ai_mom_baby/context/drift_context_slice.dart';
import 'package:ai_mom_baby/data/active_user_store.dart';
import 'package:ai_mom_baby/data/db/database_provider.dart';
import 'package:ai_mom_baby/data/db/domain_enums.dart';
import 'package:ai_mom_baby/data/drift_conversation_repository.dart';
import 'package:ai_mom_baby/data/drift_user_profile_repository.dart';
import 'package:ai_mom_baby/domain/agent_role.dart';
import 'package:ai_mom_baby/knowledge/knowledge_retriever.dart';
import 'package:ai_mom_baby/llm/llm_types.dart';
import 'package:ai_mom_baby/safety/safety_gate.dart';

void main() {
  late List<RouterRule> rules;

  setUpAll(() async {
    final raw = File('../sdd/11-four-roles-and-handoff/fixtures/router_rules.json')
        .readAsStringSync();
    rules = await loadRouterRules(jsonOverride: raw);
  });

  test('T11-02 handoff_cases.json nextSpeaker', () {
    final cases = jsonDecode(
      File('../sdd/11-four-roles-and-handoff/fixtures/handoff_cases.json')
          .readAsStringSync(),
    ) as Map<String, dynamic>;
    for (final raw in cases['cases'] as List<dynamic>) {
      final c = raw as Map<String, dynamic>;
      final got = nextSpeaker(
        type: c['type'] as String,
        soloRole: AgentRoleX.fromWire(c['soloRole'] as String?),
        userText: c['text'] as String,
        hasImage: c['hasImage'] as bool? ?? false,
        riskScore: c['riskScore'] as int?,
        routerRules: rules,
      );
      expect(got.wireId, c['expect'] as String, reason: c['id'] as String?);
    }
  });

  test('resolveSpeakers consult handoff and soft emotion', () {
    final consult = resolveSpeakers(
      type: ConversationTypeWire.group,
      soloRole: AgentRole.xiaonuan,
      userText: '今天有点焦虑睡不好',
      hasImage: false,
      riskScore: 0,
      routerRules: rules,
    );
    // Keyword → specialist, then 小暖 + 专科会诊分配.
    expect(consult, [AgentRole.xiaonuan, AgentRole.suxin]);

    final soft = resolveSpeakers(
      type: ConversationTypeWire.group,
      soloRole: AgentRole.xiaonuan,
      userText: '心情不好但还能撑',
      hasImage: false,
      riskScore: 0,
      routerRules: const [],
    );
    expect(soft, [AgentRole.xiaonuan, AgentRole.suxin]);

    final medical = resolveSpeakers(
      type: ConversationTypeWire.group,
      soloRole: AgentRole.xiaonuan,
      userText: '产检要注意什么',
      hasImage: false,
      riskScore: 0,
      routerRules: rules,
    );
    expect(medical, [AgentRole.xiaonuan, AgentRole.lin]);

    final mention = resolveSpeakers(
      type: ConversationTypeWire.group,
      soloRole: AgentRole.xiaonuan,
      userText: '@林医生 胎盘低置要紧吗',
      hasImage: false,
      riskScore: 0,
      routerRules: rules,
    );
    expect(mention, [AgentRole.lin]);
  });

  test('GroupIntentRouter parseRoleLabel', () {
    expect(GroupIntentRouter.parseRoleLabel('LIN'), AgentRole.lin);
    expect(GroupIntentRouter.parseRoleLabel('角色：SUXIN'), AgentRole.suxin);
    expect(GroupIntentRouter.parseRoleLabel('ama'), AgentRole.ama);
    expect(GroupIntentRouter.parseRoleLabel('nonsense'), AgentRole.xiaonuan);
  });

  test('resolveSpeakersAsync uses LLM intent when rules miss', () async {
    final llm = _ScriptedIntentLlm('LIN');
    final decision = await resolveSpeakersAsync(
      type: ConversationTypeWire.group,
      soloRole: AgentRole.xiaonuan,
      userText: '肚子不舒服怎么回事',
      hasImage: false,
      riskScore: 0,
      routerRules: const [],
      intentLlm: llm,
    );
    expect(decision.usedLlmIntent, isTrue);
    expect(decision.speakers, [AgentRole.xiaonuan, AgentRole.lin]);
    expect(llm.calls, 1);
  });

  test('T11-06 group graph ≤2 LLM and speakers differ', () async {
    final db = DriftDatabaseProvider(executor: NativeDatabase.memory());
    await db.init();
    addTearDown(db.close);
    final repo = DriftConversationRepository(db);
    final llm = _CountingLlm();
    final graph = GroupConsultGraph(
      safety: _PassGate(),
      retriever: FakeKnowledgeRetriever(),
      llm: llm,
      messages: repo,
      slicer: EmptyContextSlicer(),
      summaryWriter: NoopSummaryWriter(),
      routerRules: const [],
      promptLoader: (role) async => '你是${role.displayName}',
    );
    final cid = await repo.getOrCreateGroup();
    await repo.insertUserMessage(conversationId: cid, content: '心情不好但还能撑');
    final result = await graph.handle(
      conversationId: cid,
      userText: '心情不好但还能撑',
    );
    expect(result.llmCalls, 2);
    expect(llm.calls, 2);
    // Second shared-model call must see the first speaker's full labeled reply.
    expect(llm.callMessages.length, 2);
    final second = llm.callMessages[1];
    expect(second.first.role, 'system');
    expect(second.first.content, contains('【会诊身份】'));
    expect(second.first.content, contains('苏心'));
    expect(second.first.content, contains('专科补充'));
    expect(second.first.content, contains('不要宣称已改档案'));
    final firstSystem = llm.callMessages[0].first.content;
    expect(firstSystem, contains('编排者'));
    expect(firstSystem, contains('以苏心为准'));
    expect(
      second.map((m) => '${m.role}:${m.content}').toList(),
      containsAllInOrder([
        'user:心情不好但还能撑',
        'assistant:小暖：回复1',
      ]),
    );
    final msgs = await repo.listMessages(cid);
    final assistants = msgs.where((m) => m.isAssistant).toList();
    expect(assistants.length, 2);
    expect(assistants[0].speakerRole, 'XIAONUAN');
    expect(assistants[1].speakerRole, 'SUXIN');
  });

  test('group graph survives RolePrompts load failure', () async {
    final db = DriftDatabaseProvider(executor: NativeDatabase.memory());
    await db.init();
    addTearDown(db.close);
    final repo = DriftConversationRepository(db);
    final llm = _CountingLlm();
    final graph = GroupConsultGraph(
      safety: _PassGate(),
      retriever: FakeKnowledgeRetriever(),
      llm: llm,
      messages: repo,
      slicer: EmptyContextSlicer(),
      summaryWriter: NoopSummaryWriter(),
      routerRules: const [],
      promptLoader: (_) async =>
          throw StateError('Unable to load asset: prompts'),
      offlineReplyDelay: Duration.zero,
    );
    final cid = await repo.getOrCreateGroup();
    await repo.insertUserMessage(conversationId: cid, content: '你好');
    final result = await graph.handle(
      conversationId: cid,
      userText: '你好',
    );
    expect(result.llmCalls, 1);
    expect(result.assistantContent, isNotEmpty);
  });

  test('group Lin-only turn does not updateProfile for 我吃了叶酸', () async {
    final db = DriftDatabaseProvider(executor: NativeDatabase.memory());
    await db.init();
    addTearDown(db.close);
    final profiles = DriftUserProfileRepository(
      db,
      activeUserStore: MemoryActiveUserStore(),
    );
    final repo = DriftConversationRepository(db);
    final graph = GroupConsultGraph(
      safety: _PassGate(),
      retriever: FakeKnowledgeRetriever(),
      llm: _OfflineLlm(),
      messages: repo,
      slicer: EmptyContextSlicer(),
      summaryWriter: NoopSummaryWriter(),
      routerRules: rules,
      profiles: profiles,
      promptLoader: (role) async => '你是${role.displayName}',
      offlineReplyDelay: Duration.zero,
      clock: () => DateTime(2026, 9, 9, 10),
    );
    final cid = await repo.getOrCreateGroup();
    const text = '@林医生 我吃了叶酸';
    await repo.insertUserMessage(conversationId: cid, content: text);
    final result = await graph.handle(conversationId: cid, userText: text);
    expect(result.toolsUsed, isNot(contains(AgentTool.updateProfile)));
    final rich = await profiles.loadRichProfile();
    expect(rich.todayCheckIn.prenatalVitaminTaken, isNot(true));
    final msgs = await repo.listMessages(cid);
    final assistants = msgs.where((m) => m.isAssistant).toList();
    expect(assistants, hasLength(1));
    expect(assistants.single.speakerRole, 'LIN');
  });
}

class _CountingLlm extends LlmClient {
  int calls = 0;
  final List<List<ChatMessageWire>> callMessages = [];

  @override
  bool get canCallRemote => true;

  @override
  Future<LlmResult> complete({
    required List<ChatMessageWire> messages,
    required String requestId,
  }) async {
    calls++;
    callMessages.add(List.of(messages));
    return LlmResult(status: LlmStatus.ok, content: '回复$calls');
  }
}

class _ScriptedIntentLlm extends LlmClient {
  _ScriptedIntentLlm(this.label);
  final String label;
  int calls = 0;

  @override
  bool get canCallRemote => true;

  @override
  Future<LlmResult> complete({
    required List<ChatMessageWire> messages,
    required String requestId,
  }) async {
    calls++;
    return LlmResult(status: LlmStatus.ok, content: label);
  }
}

class _PassGate implements SafetyGate {
  @override
  SafetyDecision inspect(String userText) => const SafetyDecision.pass();
}

class _OfflineLlm extends LlmClient {
  @override
  bool get canCallRemote => false;

  @override
  Future<LlmResult> complete({
    required List<ChatMessageWire> messages,
    required String requestId,
  }) async {
    return const LlmResult(status: LlmStatus.missingKey);
  }
}
