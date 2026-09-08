import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/db/database_provider.dart';
import 'data/drift_user_profile_repository.dart';
import 'data/privacy_store.dart';
import 'data/user_profile_repository.dart';
import 'domain/user_profile_snapshot.dart';
import 'safety/safety_audit_log.dart';
import 'safety/safety_gate.dart';
import 'llm/dio_llm_client.dart';
import 'llm/llm_types.dart';

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

final llmConfigProvider = Provider<LlmConfig>((ref) {
  return LlmConfig.fromEnvironment();
});

final llmClientProvider = Provider<LlmClient>((ref) {
  return DioLlmClient(config: ref.watch(llmConfigProvider));
});
