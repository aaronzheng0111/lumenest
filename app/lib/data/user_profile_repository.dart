import '../domain/user_profile_snapshot.dart';

class ProfileEdits {
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

/// Editable fields shown on the Me profile form (no Drift types).
class ProfileDraft {
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

/// Thrown when [UserProfileRepository.saveEdits] rejects input (AC-03-F03).
class ProfileValidationException implements Exception {
  ProfileValidationException(this.message);
  final String message;

  @override
  String toString() => message;
}

abstract class UserProfileRepository {
  Future<UserProfileSnapshot> getSnapshot({DateTime? today});

  Future<ProfileDraft> loadDraft();

  Future<void> saveEdits(ProfileEdits edits, {DateTime? today});
}
