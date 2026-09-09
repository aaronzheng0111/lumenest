import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_mom_baby/agent/xiaonuan_graph.dart';
import 'package:ai_mom_baby/context/drift_context_slice.dart';
import 'package:ai_mom_baby/data/db/database_provider.dart';
import 'package:ai_mom_baby/data/privacy_store.dart';
import 'package:ai_mom_baby/domain/agent_role.dart';
import 'package:ai_mom_baby/knowledge/knowledge_retriever.dart';
import 'package:ai_mom_baby/llm/dio_llm_client.dart';
import 'package:ai_mom_baby/llm/llm_types.dart';
import 'package:ai_mom_baby/providers.dart';
import 'package:ai_mom_baby/safety/safety_gate.dart';

void main() {
  test('offline handle via resolveLlm survives client identity changes', () async {
    final db = DriftDatabaseProvider(executor: NativeDatabase.memory());
    await db.init();
    addTearDown(db.close);

    const offlineConfig = LlmConfig(
      baseUrl: '',
      apiKey: '',
      model: 'offline',
      forceOffline: true,
    );

    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        privacyStoreProvider.overrideWithValue(
          MemoryPrivacyStore(accepted: true),
        ),
        llmClientProvider.overrideWith(
          (ref) => DioLlmClient(config: offlineConfig),
        ),
      ],
    );
    addTearDown(container.dispose);

    final repo = container.read(conversationRepositoryProvider);
    final cid = await repo.getOrCreateSolo(role: AgentRole.xiaonuan);
    await repo.insertUserMessage(conversationId: cid, content: 'hi');

    // Build graph the same way providers do: snapshot + resolveLlm.
    final graph = XiaonuanGraph(
      safety: _PassGate(),
      retriever: FakeKnowledgeRetriever(),
      llm: container.read(llmClientProvider),
      resolveLlm: () => container.read(llmClientProvider),
      messages: repo,
      systemPrompt: '你是小暖',
      slicer: EmptyContextSlicer(),
      summaryWriter: NoopSummaryWriter(),
      offlineReplyDelay: Duration.zero,
    );

    // New client instance (catalog/model rebuild simulation).
    final turn = await graph.handle(conversationId: cid, userText: 'hi');
    expect(turn.usedOfflineDefault, isTrue);
    expect(turn.assistantContent.contains('小暖'), isTrue);

    final timeTurn = await graph.handle(conversationId: cid, userText: '几点');
    expect(timeTurn.assistantContent.contains(RegExp(r'\d{4}-\d{2}-\d{2}')), isTrue);
  });
}

class _PassGate implements SafetyGate {
  @override
  SafetyDecision inspect(String userText) => const SafetyDecision.pass();
}
