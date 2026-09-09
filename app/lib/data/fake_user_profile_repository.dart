import '../domain/rich_user_profile.dart';
import '../domain/stage.dart';
import '../domain/user_profile_snapshot.dart';
import 'user_profile_repository.dart';

/// Stand-in for widget tests that do not need Drift.
class FakeUserProfileRepository implements UserProfileRepository {
  FakeUserProfileRepository({
    this.snapshot = const UserProfileSnapshot(stage: Stage.prep),
    this.throwOnGet = false,
    RichUserProfile? rich,
  }) : rich = rich ?? snapshot.rich;

  UserProfileSnapshot snapshot;
  RichUserProfile rich;
  final bool throwOnGet;
  int getSnapshotCalls = 0;
  int saveEditsCalls = 0;
  int saveRichCalls = 0;
  ProfileEdits? lastEdits;
  final List<LocalAccount> accounts = [
    const LocalAccount(id: 1, nickname: '妈妈', isActive: true),
  ];
  int activeUserId = 1;

  @override
  Future<int> getActiveUserId() async => activeUserId;

  @override
  Future<List<LocalAccount>> listAccounts() async =>
      List<LocalAccount>.from(accounts);

  @override
  Future<int> createAccount({
    String nickname = '妈妈',
    bool switchTo = true,
  }) async {
    final id = (accounts.map((a) => a.id).fold(0, (a, b) => a > b ? a : b)) + 1;
    for (var i = 0; i < accounts.length; i++) {
      final a = accounts[i];
      accounts[i] = LocalAccount(
        id: a.id,
        nickname: a.nickname,
        isActive: switchTo ? false : a.isActive,
      );
    }
    accounts.add(LocalAccount(id: id, nickname: nickname, isActive: switchTo));
    if (switchTo) activeUserId = id;
    return id;
  }

  @override
  Future<void> switchAccount(int userId) async {
    activeUserId = userId;
    for (var i = 0; i < accounts.length; i++) {
      final a = accounts[i];
      accounts[i] = LocalAccount(
        id: a.id,
        nickname: a.nickname,
        isActive: a.id == userId,
      );
    }
  }

  @override
  Future<UserProfileSnapshot> getSnapshot({DateTime? today}) async {
    getSnapshotCalls++;
    if (throwOnGet) {
      throw StateError('snapshot failed');
    }
    return snapshot.copyWithRich(rich);
  }

  @override
  Future<ProfileDraft> loadDraft() async {
    return ProfileDraft(nickname: snapshot.nickname);
  }

  @override
  Future<void> saveEdits(ProfileEdits edits, {DateTime? today}) async {
    saveEditsCalls++;
    lastEdits = edits;
    if (edits.nickname != null) {
      snapshot = UserProfileSnapshot(
        stage: snapshot.stage,
        weekValue: snapshot.weekValue,
        weekUnit: snapshot.weekUnit,
        userId: snapshot.userId,
        nickname: edits.nickname!,
        rich: rich,
      );
    }
  }

  @override
  Future<RichUserProfile> loadRichProfile() async => rich;

  @override
  Future<void> saveRichProfile(RichUserProfile profile) async {
    saveRichCalls++;
    rich = profile;
    snapshot = snapshot.copyWithRich(profile);
  }

  @override
  Future<RichUserProfile> updateRichProfile(
    RichUserProfile Function(RichUserProfile current) transform,
  ) async {
    final next = transform(rich);
    if (next.encode() == rich.encode()) return rich;
    await saveRichProfile(next);
    return next;
  }
}

extension on UserProfileSnapshot {
  UserProfileSnapshot copyWithRich(RichUserProfile r) => UserProfileSnapshot(
        stage: stage,
        weekValue: weekValue,
        weekUnit: weekUnit,
        userId: userId,
        nickname: nickname,
        rich: r,
      );
}
