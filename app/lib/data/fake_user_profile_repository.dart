import '../domain/stage.dart';
import '../domain/user_profile_snapshot.dart';
import 'user_profile_repository.dart';

/// Stand-in for widget tests that do not need Drift.
class FakeUserProfileRepository implements UserProfileRepository {
  FakeUserProfileRepository({
    this.snapshot = const UserProfileSnapshot(stage: Stage.prep),
    this.throwOnGet = false,
  });

  UserProfileSnapshot snapshot;
  final bool throwOnGet;
  int getSnapshotCalls = 0;
  int saveEditsCalls = 0;
  ProfileEdits? lastEdits;

  @override
  Future<UserProfileSnapshot> getSnapshot({DateTime? today}) async {
    getSnapshotCalls++;
    if (throwOnGet) {
      throw StateError('snapshot failed');
    }
    return snapshot;
  }

  @override
  Future<ProfileDraft> loadDraft() async {
    return const ProfileDraft(nickname: '妈妈');
  }

  @override
  Future<void> saveEdits(ProfileEdits edits, {DateTime? today}) async {
    saveEditsCalls++;
    lastEdits = edits;
  }
}
