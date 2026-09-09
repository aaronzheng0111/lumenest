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
  });

  final Stage stage;
  final int? weekValue;

  /// `PREGNANCY_WEEK` | `POSTPARTUM_WEEK` | null
  final String? weekUnit;

  final int userId;
  final String nickname;
  final RichUserProfile rich;

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

  /// AC-01-F01 week line.
  String get weekLabel {
    switch (stage) {
      case Stage.prep:
        return '备孕中';
      case Stage.pregnant:
        final w = (weekValue != null && weekValue! >= 1) ? weekValue! : 1;
        return '孕$w周';
      case Stage.delivery:
        if (weekValue != null && weekValue! >= 1) {
          return '产褥第$weekValue周';
        }
        return '待回填分娩日期';
      case Stage.postpartum:
        final w = (weekValue != null && weekValue! >= 1) ? weekValue! : 1;
        return '产后第$w周';
    }
  }

  /// Compact agent prompt line (sensitive medical kept abstract).
  String get agentArchiveLine => rich.agentContextSummary(
        nickname: nickname,
        stageLabel: stageLabel,
        weekValue: weekValue,
        weekUnit: weekUnit,
      );
}
