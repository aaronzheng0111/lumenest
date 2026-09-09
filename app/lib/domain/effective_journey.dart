import 'identity_dates.dart';
import 'rich_user_profile.dart';
import 'stage.dart';
import 'stage_resolver.dart';
import 'user_profile_snapshot.dart';

/// Read-only projection of the user's life-stage identity.
///
/// [Stage] from dates is the single source of truth. [PregnancyStatus] only
/// refines PREP copy (未怀孕 vs 备孕中). Consumers must not invent a second
/// identity plane.
final class EffectiveJourney {
  const EffectiveJourney({
    required this.stage,
    required this.statusLabel,
    required this.weekLabel,
    required this.primaryLabel,
    this.weekValue,
    this.weekUnit,
    required this.showBabyMovement,
    required this.showPrenatalVitaminNudge,
    this.trimester,
    this.dueDate,
    this.birthDate,
    this.lastMenstruationDate,
    this.cycleDay,
    this.inFertileWindow = false,
  });

  final Stage stage;

  /// Short chip / status word (备孕 / 孕期 / 生产 / 产后 / 未怀孕).
  final String statusLabel;

  /// Week-oriented line (孕20周 / 产后第3周 / 备孕中 / …).
  final String weekLabel;

  /// Single identity string for summaries — never concatenates conflicting
  /// status + pregnancy week.
  final String primaryLabel;

  final int? weekValue;
  final String? weekUnit;
  final bool showBabyMovement;
  final bool showPrenatalVitaminNudge;
  final int? trimester;
  final DateTime? dueDate;
  final DateTime? birthDate;
  final DateTime? lastMenstruationDate;
  final int? cycleDay;
  final bool inFertileWindow;

  factory EffectiveJourney.fromSnapshot(
    UserProfileSnapshot snap, {
    DateTime? today,
  }) {
    return EffectiveJourney.from(
      stage: snap.stage,
      weekValue: snap.weekValue,
      weekUnit: snap.weekUnit,
      rich: snap.rich,
      dates: IdentityDates(
        lastMenstruationDate: snap.lastMenstruationDate,
        dueDate: snap.dueDate,
        birthDate: snap.birthDate,
      ),
      today: today ?? DateTime.now(),
    );
  }

  factory EffectiveJourney.from({
    required Stage stage,
    required RichUserProfile rich,
    required IdentityDates dates,
    required DateTime today,
    int? weekValue,
    String? weekUnit,
  }) {
    final day = calendarDay(today);
    final resolved = resolveStage(
      today: day,
      dueDate: dates.dueDate,
      birthDate: dates.birthDate,
      lastMenstruationDate: dates.lastMenstruationDate,
    );
    // Prefer caller-provided week from snapshot (already resolved), else live.
    final week = weekValue ?? resolved.weekValue;
    final unit = weekUnit ?? resolved.weekUnit;
    final effectiveStage = stage;

    final hasPrenatalMed = rich.medications.any((m) => m.isPrenatalVitamin);
    final showMovement =
        effectiveStage == Stage.pregnant && (week == null || week >= 20);
    final showVitamin = switch (effectiveStage) {
      Stage.prep || Stage.pregnant => true,
      Stage.delivery || Stage.postpartum => hasPrenatalMed,
    };

    final trimester = effectiveStage == Stage.pregnant
        ? rich.trimesterFromWeek(week)
        : null;

    final cycle = _cycleDay(
      lmp: dates.lastMenstruationDate,
      today: day,
      stage: effectiveStage,
    );

    final labels = _labels(
      stage: effectiveStage,
      status: rich.pregnancyStatus,
      weekValue: week,
      cycleDay: cycle?.day,
    );

    return EffectiveJourney(
      stage: effectiveStage,
      statusLabel: labels.statusLabel,
      weekLabel: labels.weekLabel,
      primaryLabel: labels.primaryLabel,
      weekValue: week,
      weekUnit: unit,
      showBabyMovement: showMovement,
      showPrenatalVitaminNudge: showVitamin,
      trimester: trimester,
      dueDate: dates.dueDate,
      birthDate: dates.birthDate,
      lastMenstruationDate: dates.lastMenstruationDate,
      cycleDay: cycle?.day,
      inFertileWindow: cycle?.fertile ?? false,
    );
  }

  /// Me / pregnancy section summary — one identity, optional soft history.
  String summaryWithHistory(RichUserProfile rich) {
    final bits = <String>[
      primaryLabel,
      if (rich.previousPregnancies != null) '既往${rich.previousPregnancies}次',
    ];
    return bits.join(' · ');
  }

  static ({String statusLabel, String weekLabel, String primaryLabel}) _labels({
    required Stage stage,
    required PregnancyStatus status,
    required int? weekValue,
    required int? cycleDay,
  }) {
    return switch (stage) {
      Stage.prep => () {
          if (status == PregnancyStatus.notPregnant) {
            return (
              statusLabel: '未怀孕',
              weekLabel: '未怀孕',
              primaryLabel: '未怀孕',
            );
          }
          if (cycleDay != null) {
            return (
              statusLabel: '备孕',
              weekLabel: '周期第$cycleDay天',
              primaryLabel: '备孕中',
            );
          }
          return (
            statusLabel: '备孕',
            weekLabel: '备孕中',
            primaryLabel: '备孕中',
          );
        }(),
      Stage.pregnant => () {
          final w = (weekValue != null && weekValue >= 1) ? weekValue : 1;
          final weekLine = '孕$w周';
          return (
            statusLabel: '孕期',
            weekLabel: weekLine,
            primaryLabel: weekLine,
          );
        }(),
      Stage.delivery => () {
          if (weekValue != null && weekValue >= 1) {
            final line = '产褥第$weekValue周';
            return (
              statusLabel: '生产',
              weekLabel: line,
              primaryLabel: line,
            );
          }
          return (
            statusLabel: '生产',
            weekLabel: '待回填分娩日期',
            primaryLabel: '待回填分娩日期',
          );
        }(),
      Stage.postpartum => () {
          final w = (weekValue != null && weekValue >= 1) ? weekValue : 1;
          final line = '产后第$w周';
          return (
            statusLabel: '产后',
            weekLabel: line,
            primaryLabel: line,
          );
        }(),
    };
  }

  static ({int day, bool fertile})? _cycleDay({
    required DateTime? lmp,
    required DateTime today,
    required Stage stage,
  }) {
    if (stage != Stage.prep || lmp == null) return null;
    final lmpDay = calendarDay(lmp);
    final elapsed = calendarDaysBetween(lmpDay, today);
    if (elapsed < 0) return null;
    final day = (elapsed % 28) + 1;
    final fertile = day >= 11 && day <= 16;
    return (day: day, fertile: fertile);
  }
}
