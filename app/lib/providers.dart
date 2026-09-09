import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'agent/group_consult_graph.dart';
import 'agent/next_speaker.dart';
import 'agent/xiaonuan_graph.dart';
import 'agent/role_prompts.dart';
import 'context/context_slice.dart';
import 'context/drift_context_slice.dart';
import 'data/active_user_store.dart';
import 'data/conversation_repository.dart';
import 'data/db/database_provider.dart';
import 'data/drift_conversation_repository.dart';
import 'data/drift_user_profile_repository.dart';
import 'data/privacy_store.dart';
import 'data/user_profile_repository.dart';
import 'domain/agent_role.dart';
import 'domain/rich_user_profile.dart';
import 'domain/user_profile_snapshot.dart';
import 'knowledge/knowledge_retriever.dart';
import 'chat/chat_suggestions_catalog.dart';
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
  return DriftUserProfileRepository(
    ref.watch(databaseProvider),
    activeUserStore: ref.watch(activeUserStoreProvider),
  );
});

final activeUserStoreProvider = Provider<ActiveUserStore>((ref) {
  return SharedPrefsActiveUserStore();
});

/// Cached active user id; bump via [ActiveUserController.switchTo] / create.
final activeUserIdProvider =
    StateNotifierProvider<ActiveUserController, AsyncValue<int>>((ref) {
  return ActiveUserController(
    ref,
    store: ref.watch(activeUserStoreProvider),
    profiles: ref.watch(userProfileRepositoryProvider),
  );
});

/// Owns active-account switches and invalidates user-scoped providers.
class ActiveUserController extends StateNotifier<AsyncValue<int>> {
  ActiveUserController(
    this._ref, {
    required ActiveUserStore store,
    required UserProfileRepository profiles,
  })  : _store = store,
        _profiles = profiles,
        super(const AsyncLoading()) {
    _hydrate();
  }

  final Ref _ref;
  final ActiveUserStore _store;
  final UserProfileRepository _profiles;

  Future<void> _hydrate() async {
    try {
      final id = await _store.getActiveUserId();
      if (!mounted) return;
      state = AsyncData(id);
    } catch (e, st) {
      if (!mounted) return;
      state = AsyncError(e, st);
    }
  }

  void _invalidateUserScoped() {
    // Snapshot / accounts already watch [activeUserIdProvider]; refresh chats
    // and today cards that close over the previous user id.
    _ref.invalidate(conversationListProvider);
    _ref.invalidate(todayTaskCardsProvider);
  }

  Future<void> switchTo(int userId) async {
    await _profiles.switchAccount(userId);
    if (!mounted) return;
    state = AsyncData(userId);
    _invalidateUserScoped();
  }

  Future<int> createAccount({String nickname = '妈妈'}) async {
    final id = await _profiles.createAccount(nickname: nickname);
    if (!mounted) return id;
    state = AsyncData(id);
    _invalidateUserScoped();
    return id;
  }
}

/// Cold-start snapshot. Failures map to PREP without crashing.
final userProfileSnapshotProvider =
    FutureProvider<UserProfileSnapshot>((ref) async {
  // Re-read when active user changes.
  ref.watch(activeUserIdProvider);
  final repo = ref.watch(userProfileRepositoryProvider);
  try {
    return await repo.getSnapshot();
  } catch (e) {
    debugPrint('UserProfileRepository.getSnapshot failed: $e');
    return UserProfileSnapshot.fallback;
  }
});

final localAccountsProvider = FutureProvider<List<LocalAccount>>((ref) async {
  ref.watch(activeUserIdProvider);
  return ref.watch(userProfileRepositoryProvider).listAccounts();
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

/// Recommended prompts for chat composers ([ChatSuggestionsCatalog]).
final chatSuggestionsCatalogProvider =
    FutureProvider<ChatSuggestionsCatalog>((ref) {
  return ChatSuggestionsCatalog.load();
});

/// Resolved prompt chips for a chat scene (and optional role override).
///
/// Watches [chatSuggestionsCatalogProvider]; returns `[]` while loading/error
/// so composers can hide suggestions without special-casing AsyncValue.
final chatSuggestionsForProvider = Provider.autoDispose
    .family<List<String>, ({String scene, AgentRole? role})>((ref, args) {
  return ref.watch(chatSuggestionsCatalogProvider).maybeWhen(
        data: (catalog) =>
            catalog.suggestionsFor(args.scene, role: args.role),
        orElse: () => const <String>[],
      );
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
  ref.watch(activeUserIdProvider);
  return DriftConversationRepository(
    ref.watch(databaseProvider),
    activeUserId: () =>
        ref.read(activeUserIdProvider).valueOrNull ?? 1,
  );
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
    profiles: ref.watch(userProfileRepositoryProvider),
    userId: ref.watch(activeUserIdProvider).valueOrNull ?? 1,
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
    profiles: ref.watch(userProfileRepositoryProvider),
    userId: ref.watch(activeUserIdProvider).valueOrNull ?? 1,
  );
});

final taskCardServiceProvider = FutureProvider<TaskCardService>((ref) async {
  final templates = await loadTaskTemplates();
  ref.watch(activeUserIdProvider);
  return DriftTaskCardService(
    databaseProvider: ref.watch(databaseProvider),
    profiles: ref.watch(userProfileRepositoryProvider),
    templates: templates,
    activeUserId: () =>
        ref.read(activeUserIdProvider).valueOrNull ?? 1,
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

/// Home / Me / chat shared mutations for [DailyCheckIn].
final homeCheckInControllerProvider = Provider<HomeCheckInController>((ref) {
  return HomeCheckInController(ref);
});

class HomeCheckInController {
  HomeCheckInController(this._ref);

  final Ref _ref;

  UserProfileRepository get _profiles =>
      _ref.read(userProfileRepositoryProvider);

  Future<void> _refresh() async {
    _ref.invalidate(userProfileSnapshotProvider);
  }

  Future<void> addWaterMl(double ml) async {
    if (ml <= 0) return;
    await _profiles.updateTodayCheckIn(
      (c) => c.copyWith(waterMl: (c.waterMl ?? 0) + ml),
      eventCategory: 'HABIT',
      eventSummary: '饮水 +${ml.round()}ml',
      eventRawRef: '{"type":"water","deltaMl":$ml}',
    );
    await _refresh();
  }

  Future<void> setWaterMl(double? ml) async {
    await _profiles.updateTodayCheckIn(
      (c) => c.copyWith(waterMl: ml),
      eventCategory: ml == null ? null : 'HABIT',
      eventSummary: ml == null ? null : '饮水设为 ${ml.round()}ml',
      eventRawRef: ml == null ? null : '{"type":"water","setMl":$ml}',
    );
    await _refresh();
  }

  Future<void> setMood(String? mood) async {
    final label = mood?.trim();
    await _profiles.updateTodayCheckIn(
      (c) => c.copyWith(mood: label),
      eventCategory: label == null || label.isEmpty ? null : 'MOOD',
      eventSummary: label == null || label.isEmpty ? null : '心情：$label',
      eventRawRef: label == null || label.isEmpty
          ? null
          : '{"type":"mood"}',
    );
    await _refresh();
  }

  Future<void> setPrenatalVitaminTaken(bool taken) async {
    await _profiles.updateTodayCheckIn(
      (c) => c.copyWith(prenatalVitaminTaken: taken),
      eventCategory: 'HABIT',
      eventSummary: taken ? '已服孕维/叶酸' : '取消孕维打卡',
      eventRawRef: '{"type":"prenatalVitamin","taken":$taken}',
    );
    await _refresh();
  }

  Future<void> setSleepHours(double? hours) async {
    await _profiles.updateTodayCheckIn(
      (c) => c.copyWith(sleepHours: hours),
      eventCategory: hours == null ? null : 'HABIT',
      eventSummary: hours == null ? null : '睡眠 ${hours}h',
      eventRawRef: hours == null ? null : '{"type":"sleep","hours":$hours}',
    );
    await _refresh();
  }

  Future<void> setWeightKg(double? kg) async {
    await _profiles.updateTodayCheckIn(
      (c) => c.copyWith(weightKg: kg),
      eventCategory: kg == null ? null : 'HABIT',
      eventSummary: kg == null ? null : '体重 ${kg}kg',
      eventRawRef: kg == null ? null : '{"type":"weight","kg":$kg}',
    );
    if (kg != null) {
      await _profiles.updateRichProfile(
        (current) => current.copyWith(currentWeightKg: kg),
      );
    }
    await _refresh();
  }

  Future<void> saveSymptomLog(SymptomLog log) async {
    await _profiles.updateRichProfile(
      (current) => current.copyWith(latestSymptoms: log),
    );
    await _profiles.logWellnessEvent(
      category: 'SYMPTOM',
      summary: _symptomSummary(log),
      rawRef: '{"type":"symptom"}',
    );
    await _refresh();
  }

  static String _symptomSummary(SymptomLog log) {
    final bits = <String>[
      if (log.nausea != null) '恶心',
      if (log.fatigue != null) '疲劳',
      if (log.headache != null) '头痛',
      if (log.backPain != null) '背痛',
      if (log.heartburn != null) '烧心',
      if (log.swelling != null) '水肿',
      if (log.mood != null) '情绪',
      if (log.sleepQuality != null) '睡眠',
    ];
    return bits.isEmpty ? '记录了不适感受' : '不适：${bits.join("、")}';
  }
}

/// Used when safety assets fail to load so chat can still reply offline.
class _PassThroughSafetyGate implements SafetyGate {
  const _PassThroughSafetyGate();

  @override
  SafetyDecision inspect(String userText) => const SafetyDecision.pass();
}
