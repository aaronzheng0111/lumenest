import '../domain/stage.dart';
import '../domain/user_profile_snapshot.dart';
import 'user_profile_repository.dart';

/// Stand-in until 03 `UserProfileRepository` exists (T01-07).
class FakeUserProfileRepository implements UserProfileRepository {
  FakeUserProfileRepository({
    this.snapshot = const UserProfileSnapshot(stage: Stage.prep),
    this.throwOnGet = false,
  });

  final UserProfileSnapshot snapshot;
  final bool throwOnGet;
  int getSnapshotCalls = 0;

  @override
  Future<UserProfileSnapshot> getSnapshot() async {
    getSnapshotCalls++;
    if (throwOnGet) {
      throw StateError('snapshot failed');
    }
    return snapshot;
  }
}
