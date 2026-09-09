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

  final List<({String category, String summary, String? rawRef})> wellnessEvents =
      [];

  @override
  Future<RichUserProfile> updateTodayCheckIn(
    DailyCheckIn Function(DailyCheckIn current) patch, {
    DateTime? now,
    String? eventCategory,
    String? eventSummary,
    String? eventRawRef,
  }) async {
    final day = now ?? DateTime.now();
    final checkDay = DateTime(day.year, day.month, day.day);
    final next = await updateRichProfile((current) {
      var check = current.todayCheckIn;
      final d = check.localDate;
      final sameDay = d != null &&
          d.year == checkDay.year &&
          d.month == checkDay.month &&
          d.day == checkDay.day;
      if (!sameDay) {
        check = DailyCheckIn(localDate: checkDay);
      } else if (check.localDate == null) {
        check = check.copyWith(localDate: checkDay);
      }
      return current.copyWith(todayCheckIn: patch(check));
    });
    if (eventCategory != null &&
        eventSummary != null &&
        eventSummary.trim().isNotEmpty) {
      await logWellnessEvent(
        category: eventCategory,
        summary: eventSummary.trim(),
        rawRef: eventRawRef,
        now: day,
      );
    }
    return next;
  }

  @override
  Future<void> logWellnessEvent({
    required String category,
    required String summary,
    String? rawRef,
    DateTime? now,
  }) async {
    wellnessEvents.add((category: category, summary: summary, rawRef: rawRef));
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
        lastMenstruationDate: lastMenstruationDate,
        dueDate: dueDate,
        birthDate: birthDate,
      );
}
