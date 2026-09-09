import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_mom_baby/agent/group_consult_graph.dart';
import 'package:ai_mom_baby/agent/next_speaker.dart';
import 'package:ai_mom_baby/context/drift_context_slice.dart';
import 'package:ai_mom_baby/data/db/database_provider.dart';
import 'package:ai_mom_baby/data/db/domain_enums.dart';
import 'package:ai_mom_baby/data/drift_conversation_repository.dart';
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

  test('resolveSpeakers caps at 2 and supports 小暖→苏心', () {
    final dual = resolveSpeakers(
      type: ConversationTypeWire.group,
      soloRole: AgentRole.xiaonuan,
      userText: '今天有点焦虑睡不好',
      hasImage: false,
      riskScore: 0,
      routerRules: rules,
    );
    // "焦虑" hits router → SUXIN alone.
    expect(dual, [AgentRole.suxin]);

    final soft = resolveSpeakers(
      type: ConversationTypeWire.group,
      soloRole: AgentRole.xiaonuan,
      userText: '心情不好但还能撑',
      hasImage: false,
      riskScore: 0,
      routerRules: const [],
    );
    expect(soft, [AgentRole.xiaonuan, AgentRole.suxin]);
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
    final msgs = await repo.listMessages(cid);
    final assistants = msgs.where((m) => m.isAssistant).toList();
    expect(assistants.length, 2);
    expect(assistants[0].speakerRole, 'XIAONUAN');
    expect(assistants[1].speakerRole, 'SUXIN');
  });
}

class _CountingLlm implements LlmClient {
  int calls = 0;

  @override
  bool get canCallRemote => true;

  @override
  Future<LlmResult> complete({
    required List<ChatMessageWire> messages,
    required String requestId,
  }) async {
    calls++;
    return LlmResult(status: LlmStatus.ok, content: '回复$calls');
  }
}

class _PassGate implements SafetyGate {
  @override
  SafetyDecision inspect(String userText) => const SafetyDecision.pass();
}
