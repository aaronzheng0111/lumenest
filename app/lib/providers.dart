import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'agent/group_consult_graph.dart';
import 'agent/next_speaker.dart';
import 'agent/xiaonuan_graph.dart';
import 'agent/role_prompts.dart';
import 'context/context_slice.dart';
import 'context/drift_context_slice.dart';
import 'data/conversation_repository.dart';
import 'data/db/database_provider.dart';
import 'data/drift_conversation_repository.dart';
import 'data/drift_user_profile_repository.dart';
import 'data/privacy_store.dart';
import 'data/user_profile_repository.dart';
import 'domain/agent_role.dart';
import 'domain/user_profile_snapshot.dart';
import 'knowledge/knowledge_retriever.dart';
import 'llm/dio_llm_client.dart';
import 'llm/llm_model_catalog.dart';
import 'llm/llm_model_selection_store.dart';
import 'llm/llm_types.dart';
import 'safety/safety_audit_log.dart';
import 'safety/safety_gate.dart';
import 'tasks/drift_task_card_service.dart';
import 'tasks/task_cards.dart';

final databaseProvider = Provider<DatabaseProvider>((ref) {
  final provider = DriftDatabaseProvider();
  ref.onDispose(provider.close);
  return provider;
});

/// Completes after seed rows exist. Failures surface the upgrade screen.
final databaseReadyProvider = FutureProvider<void>((ref) async {
  await ref.watch(databaseProvider).init();
});

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return DriftUserProfileRepository(ref.watch(databaseProvider));
});

/// Cold-start snapshot. Failures map to PREP without crashing.
final userProfileSnapshotProvider =
    FutureProvider<UserProfileSnapshot>((ref) async {
  final repo = ref.watch(userProfileRepositoryProvider);
  try {
    return await repo.getSnapshot();
  } catch (e) {
    debugPrint('UserProfileRepository.getSnapshot failed: $e');
    return UserProfileSnapshot.fallback;
  }
});

final privacyStoreProvider = Provider<PrivacyStore>(
  (ref) => SharedPrefsPrivacyStore(),
);

final privacyAcceptedProvider = FutureProvider<bool>((ref) async {
  return ref.watch(privacyStoreProvider).isAccepted();
});

typedef DataExporter = Future<void> Function(String json);

final dataExporterProvider = Provider<DataExporter>((ref) {
  return (_) async {};
});

final safetyAuditLogProvider = Provider<SafetyAuditLog>((ref) {
  return SafetyAuditLog();
});

/// Loaded once after first use. Tests may override with sync fixtures.
final safetyGateProvider = FutureProvider<SafetyGate>((ref) async {
  final audit = ref.watch(safetyAuditLogProvider);
  return LocalSafetyGate.load(
    onAudit: ({
      required String category,
      required String patternId,
      String? conversationId,
    }) {
      // Fire-and-forget; never include message body.
      audit.write(
        category: category,
        patternId: patternId,
        conversationId: conversationId,
      );
    },
  );
});

final llmModelCatalogProvider = FutureProvider<LlmModelCatalog>((ref) {
  return loadLlmModelCatalog();
});

final llmModelSelectionStoreProvider = Provider<LlmModelSelectionStore>((ref) {
  return SharedPrefsLlmModelSelectionStore();
});

/// Persisted catalog model id (per-app). Hydrates from SharedPreferences.
final selectedLlmModelIdProvider =
    StateNotifierProvider<SelectedLlmModelController, String>((ref) {
  return SelectedLlmModelController(
    store: ref.watch(llmModelSelectionStoreProvider),
    catalogLoader: () => ref.read(llmModelCatalogProvider.future),
  );
});

class SelectedLlmModelController extends StateNotifier<String> {
  SelectedLlmModelController({
    required LlmModelSelectionStore store,
    required Future<LlmModelCatalog> Function() catalogLoader,
    String initialId = 'local-demo',
  })  : _store = store,
        _catalogLoader = catalogLoader,
        super(initialId) {
    _hydrate();
  }

  final LlmModelSelectionStore _store;
  final Future<LlmModelCatalog> Function() _catalogLoader;

  Future<void> _hydrate() async {
    try {
      final catalog = await _catalogLoader();
      final saved = await _store.getSelectedId();
      final resolved = catalog.resolve(saved);
      if (!mounted) return;
      state = resolved.id;
    } catch (_) {
      // Keep [initialId]; catalog errors surface in the picker UI.
    }
  }

  Future<void> select(String id) async {
    try {
      final catalog = await _catalogLoader();
      final resolved = catalog.resolve(id);
      state = resolved.id;
      await _store.setSelectedId(resolved.id);
    } catch (_) {
      state = id;
      await _store.setSelectedId(id);
    }
  }
}

final llmConfigProvider = Provider<LlmConfig>((ref) {
  final env = LlmConfig.fromEnvironment();
  final selectedId = ref.watch(selectedLlmModelIdProvider);
  final catalog = ref.watch(llmModelCatalogProvider).valueOrNull;
  if (catalog == null) {
    // Match offline behavior before the catalog asset finishes loading.
    return env.hasKey ? env : env.copyWith(forceOffline: true);
  }
  return env.withModelOption(catalog.resolve(selectedId));
});

final llmClientProvider = Provider<LlmClient>((ref) {
  return DioLlmClient(config: ref.watch(llmConfigProvider));
});

final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  return DriftConversationRepository(ref.watch(databaseProvider));
});

final conversationListProvider =
    FutureProvider<List<ConversationListItem>>((ref) async {
  try {
    return await ref.watch(conversationRepositoryProvider).listConversations();
  } catch (_) {
    return const [];
  }
});

/// Loaded from fixtures; tests may override with a sync [FakeKnowledgeRetriever].
final knowledgeRetrieverProvider = FutureProvider<KnowledgeRetriever>((ref) {
  return FakeSubstringRetriever.load();
});

final contextSlicerProvider = Provider<ContextSlicer>((ref) {
  return DriftContextSlicer(
    databaseProvider: ref.watch(databaseProvider),
    profiles: ref.watch(userProfileRepositoryProvider),
    messages: ref.watch(conversationRepositoryProvider),
  );
});

final summaryWriterProvider = Provider<SummaryWriter>((ref) {
  return DriftSummaryWriter(
    databaseProvider: ref.watch(databaseProvider),
    profiles: ref.watch(userProfileRepositoryProvider),
  );
});

final xiaonuanGraphProvider = FutureProvider<XiaonuanGraph>((ref) async {
  return ref.watch(agentGraphProvider(AgentRole.xiaonuan).future);
});

/// Solo-role graph (TASK-203). GROUP handoff uses [groupConsultGraphProvider].
final agentGraphProvider =
    FutureProvider.family<XiaonuanGraph, AgentRole>((ref, role) async {
  // Do NOT watch llmClientProvider here — catalog/model hydration recreates the
  // client and would dispose this FutureProvider mid-await, making chat send fail.
  SafetyGate safety;
  try {
    safety = await ref.watch(safetyGateProvider.future);
  } catch (e, st) {
    debugPrint('safetyGateProvider failed, using pass-through: $e\n$st');
    safety = const _PassThroughSafetyGate();
  }

  KnowledgeRetriever retriever;
  try {
    retriever = await ref.watch(knowledgeRetrieverProvider.future);
  } catch (e, st) {
    debugPrint('knowledgeRetrieverProvider failed, using empty: $e\n$st');
    retriever = FakeKnowledgeRetriever();
  }

  String prompt;
  try {
    prompt = await RolePrompts.load(role);
  } catch (e, st) {
    debugPrint('RolePrompts.load failed: $e\n$st');
    prompt = '你是${role.displayName}';
  }

  final llmSnapshot = ref.read(llmClientProvider);
  return XiaonuanGraph(
    safety: safety,
    retriever: retriever,
    llm: llmSnapshot,
    resolveLlm: () {
      try {
        return ref.read(llmClientProvider);
      } catch (_) {
        return llmSnapshot;
      }
    },
    messages: ref.watch(conversationRepositoryProvider),
    systemPrompt: prompt,
    slicer: ref.watch(contextSlicerProvider),
    summaryWriter: ref.watch(summaryWriterProvider),
    speaker: role,
  );
});

/// Debug override until subscription module (12) lands. Default true for P1 QA.
final groupConsultEnabledProvider = Provider<bool>((ref) => true);

final groupConsultGraphProvider = FutureProvider<GroupConsultGraph>((ref) async {
  SafetyGate safety;
  try {
    safety = await ref.watch(safetyGateProvider.future);
  } catch (e, st) {
    debugPrint('safetyGateProvider failed, using pass-through: $e\n$st');
    safety = const _PassThroughSafetyGate();
  }

  KnowledgeRetriever retriever;
  try {
    retriever = await ref.watch(knowledgeRetrieverProvider.future);
  } catch (e, st) {
    debugPrint('knowledgeRetrieverProvider failed, using empty: $e\n$st');
    retriever = FakeKnowledgeRetriever();
  }

  List<RouterRule> rules;
  try {
    rules = await loadRouterRules();
  } catch (e, st) {
    debugPrint('loadRouterRules failed: $e\n$st');
    rules = const [];
  }

  final llmSnapshot = ref.read(llmClientProvider);
  return GroupConsultGraph(
    safety: safety,
    retriever: retriever,
    llm: llmSnapshot,
    resolveLlm: () {
      try {
        return ref.read(llmClientProvider);
      } catch (_) {
        return llmSnapshot;
      }
    },
    messages: ref.watch(conversationRepositoryProvider),
    slicer: ref.watch(contextSlicerProvider),
    summaryWriter: ref.watch(summaryWriterProvider),
    routerRules: rules,
  );
});

final taskCardServiceProvider = FutureProvider<TaskCardService>((ref) async {
  final templates = await loadTaskTemplates();
  return DriftTaskCardService(
    databaseProvider: ref.watch(databaseProvider),
    profiles: ref.watch(userProfileRepositoryProvider),
    templates: templates,
  );
});

final todayTaskCardsProvider =
    FutureProvider<List<TaskCardView>>((ref) async {
  try {
    await ref.watch(databaseReadyProvider.future);
    final service = await ref.watch(taskCardServiceProvider.future);
    return service.listToday(DateTime.now());
  } catch (_) {
    return const [];
  }
});

/// Used when safety assets fail to load so chat can still reply offline.
class _PassThroughSafetyGate implements SafetyGate {
  const _PassThroughSafetyGate();

  @override
  SafetyDecision inspect(String userText) => const SafetyDecision.pass();
}
