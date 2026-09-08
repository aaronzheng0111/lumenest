import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/db/database_provider.dart';
import 'data/fixture_store.dart';
import 'data/privacy_store.dart';
import 'data/user_profile_repository.dart';
import 'domain/user_profile_snapshot.dart';

final databaseProvider = Provider<DatabaseProvider>((ref) {
  final provider = DriftDatabaseProvider();
  ref.onDispose(provider.close);
  return provider;
});

/// Completes after seed rows exist. Failures surface the upgrade screen.
final databaseReadyProvider = FutureProvider<void>((ref) async {
  await ref.watch(databaseProvider).init();
});

final userProfileRepositoryProvider = Provider<UserProfileRepository>(
  (ref) => AssetMockUserProfileRepository(),
);

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
