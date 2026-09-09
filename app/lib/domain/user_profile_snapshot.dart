import 'effective_journey.dart';
import 'stage.dart';
import 'rich_user_profile.dart';

/// Read model from 03 (+ rich profile for Home / Me / agent context).
final class UserProfileSnapshot {
  const UserProfileSnapshot({
    required this.stage,
    this.weekValue,
    this.weekUnit,
    this.userId = 1,
    this.nickname = '妈妈',
    this.rich = const RichUserProfile(),
    this.lastMenstruationDate,
    this.dueDate,
    this.birthDate,
  });

  final Stage stage;
  final int? weekValue;

  /// `PREGNANCY_WEEK` | `POSTPARTUM_WEEK` | null
  final String? weekUnit;

  final int userId;
  final String nickname;
  final RichUserProfile rich;

  /// Calendar dates from the users row (for journey / cycle UI only).
  final DateTime? lastMenstruationDate;
  final DateTime? dueDate;
  final DateTime? birthDate;

  static const UserProfileSnapshot fallback = UserProfileSnapshot(
    stage: Stage.prep,
  );

  String get stageLabel => stage.label;

  String get displayName {
    final full = rich.fullName?.trim();
    if (full != null && full.isNotEmpty) return full;
    return nickname;
  }

  int? get ageYears => rich.ageYears();

  /// AC-01-F01 week line (Stage SSOT via [EffectiveJourney]).
  String get weekLabel =>
      EffectiveJourney.fromSnapshot(this).weekLabel;

  /// Compact agent prompt line (sensitive medical kept abstract).
  String get agentArchiveLine {
    final journey = EffectiveJourney.fromSnapshot(this);
    return rich.agentContextSummary(
      nickname: nickname,
      primaryLabel: journey.primaryLabel,
      weekValue: journey.weekValue,
      weekUnit: journey.weekUnit,
      trimester: journey.trimester,
      includePrenatalVitamin: journey.showPrenatalVitaminNudge,
      includeBabyMovement: journey.showBabyMovement,
    );
  }
}
