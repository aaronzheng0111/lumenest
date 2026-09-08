import 'stage.dart';

/// Read model from 03. Home must not compute gestational week itself.
class UserProfileSnapshot {
  const UserProfileSnapshot({
    required this.stage,
    this.weekValue,
    this.weekUnit,
  });

  final Stage stage;
  final int? weekValue;

  /// `PREGNANCY_WEEK` | `POSTPARTUM_WEEK` | null
  final String? weekUnit;

  static const UserProfileSnapshot fallback = UserProfileSnapshot(
    stage: Stage.prep,
  );

  String get stageLabel => stage.label;

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
}
