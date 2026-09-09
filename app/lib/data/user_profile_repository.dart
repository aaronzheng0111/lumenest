import '../domain/rich_user_profile.dart';
import '../domain/user_profile_snapshot.dart';

/// Partial update for stage columns on the `users` row.
final class ProfileEdits {
  const ProfileEdits({
    this.nickname,
    this.lastMenstruationDate,
    this.dueDate,
    this.birthDate,
    this.clearLastMenstruationDate = false,
    this.clearDueDate = false,
    this.clearBirthDate = false,
  });

  final String? nickname;
  final DateTime? lastMenstruationDate;
  final DateTime? dueDate;
  final DateTime? birthDate;
  final bool clearLastMenstruationDate;
  final bool clearDueDate;
  final bool clearBirthDate;
}

/// Editable stage fields shown on the pregnancy stage form (no Drift types).
final class ProfileDraft {
  const ProfileDraft({
    required this.nickname,
    this.lastMenstruationDate,
    this.dueDate,
    this.birthDate,
  });

  final String nickname;
  final DateTime? lastMenstruationDate;
  final DateTime? dueDate;
  final DateTime? birthDate;
}

/// Local account row for the account switcher.
final class LocalAccount {
  const LocalAccount({
    required this.id,
    required this.nickname,
    required this.isActive,
  });

  final int id;
  final String nickname;
  final bool isActive;
}

/// Thrown when [UserProfileRepository.saveEdits] rejects input (AC-03-F03).
final class ProfileValidationException implements Exception {
  ProfileValidationException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Single SSOT for stage dates + rich profile. UI and agent tools both use this.
abstract class UserProfileRepository {
  Future<int> getActiveUserId();

  Future<List<LocalAccount>> listAccounts();

  /// Creates a new local user and optionally switches to it.
  Future<int> createAccount({
    String nickname = '妈妈',
    bool switchTo = true,
  });

  Future<void> switchAccount(int userId);

  Future<UserProfileSnapshot> getSnapshot({DateTime? today});

  Future<ProfileDraft> loadDraft();

  Future<void> saveEdits(ProfileEdits edits, {DateTime? today});

  Future<RichUserProfile> loadRichProfile();

  /// Replaces the rich profile blob for the active user (manual UI save).
  Future<void> saveRichProfile(RichUserProfile profile);

  /// Merges a patched rich profile (agent tool + section editors).
  Future<RichUserProfile> updateRichProfile(
    RichUserProfile Function(RichUserProfile current) transform,
  );

  /// Shared write path for Home / Me / chat: patch today's [DailyCheckIn].
  ///
  /// Resets the strip when [localDate] is a different calendar day.
  /// Optionally appends a [ProfileEvents] habit/mood row for lightweight trends.
  Future<RichUserProfile> updateTodayCheckIn(
    DailyCheckIn Function(DailyCheckIn current) patch, {
    DateTime? now,
    String? eventCategory,
    String? eventSummary,
    String? eventRawRef,
  });

  /// Logs a symptom / habit event without changing today's check-in strip.
  Future<void> logWellnessEvent({
    required String category,
    required String summary,
    String? rawRef,
    DateTime? now,
  });
}
