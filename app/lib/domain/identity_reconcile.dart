import 'identity_dates.dart';
import 'rich_user_profile.dart';
import 'stage.dart';
import 'stage_resolver.dart';

/// Result of reconciling pregnancy status intents with calendar dates.
final class IdentityReconcileResult {
  const IdentityReconcileResult({
    required this.dates,
    required this.rich,
  });

  final IdentityDates dates;
  final RichUserProfile rich;
}

/// Mutates dates + rich profile so Stage (from dates) and PregnancyStatus agree.
///
/// Does not change [resolveStage] semantics — only writes compatible dates.
abstract final class IdentityReconciler {
  /// Applies a user/agent pregnancy-status intent by mutating dates.
  static IdentityReconcileResult reconcileOnStatusIntent({
    required PregnancyStatus status,
    required RichUserProfile rich,
    required IdentityDates dates,
    required DateTime today,
  }) {
    final day = calendarDay(today);
    return switch (status) {
      PregnancyStatus.unset => IdentityReconcileResult(
          dates: dates,
          rich: _projectStatus(rich, dates, day),
        ),
      PregnancyStatus.notPregnant || PregnancyStatus.tryingToConceive =>
        _toPrep(status: status, rich: rich, dates: dates),
      PregnancyStatus.pregnant =>
        _toPregnant(rich: rich, dates: dates, today: day),
      PregnancyStatus.postpartum =>
        _toPostpartum(rich: rich, dates: dates, today: day),
    };
  }

  /// After LMP/due/birth change: project status and clear incompatible fields.
  static IdentityReconcileResult reconcileOnDatesChange({
    required IdentityDates dates,
    required RichUserProfile rich,
    required DateTime today,
  }) {
    final day = calendarDay(today);
    var next = _clearDueDateOverride(rich);
    next = _clearIncompatibleCurrentFields(next, dates, day);
    next = _projectStatus(next, dates, day);
    return IdentityReconcileResult(dates: dates, rich: next);
  }

  /// Writes [week] into LMP/due, then clears [RichUserProfile.pregnancyWeekOverride].
  static IdentityReconcileResult applyWeekOverrideWriteThrough({
    required int week,
    required RichUserProfile rich,
    required IdentityDates dates,
    required DateTime today,
  }) {
    final day = calendarDay(today);
    final w = clampPregnancyWeek(week);
    final lmp = day.subtract(Duration(days: (w - 1) * 7));
    final due = lmp.add(const Duration(days: 280));
    final nextDates = IdentityDates(
      lastMenstruationDate: lmp,
      dueDate: due,
      birthDate: null,
    );
    final nextRich = rich.copyWith(
      pregnancyStatus: PregnancyStatus.pregnant,
      pregnancyWeekOverride: null,
      dueDateOverride: null,
      todayCheckIn: rich.todayCheckIn.copyWith(babyMovementCount: null),
    );
    return IdentityReconcileResult(dates: nextDates, rich: nextRich);
  }

  static IdentityReconcileResult _toPrep({
    required PregnancyStatus status,
    required RichUserProfile rich,
    required IdentityDates dates,
  }) {
    final nextDates = IdentityDates(
      lastMenstruationDate: dates.lastMenstruationDate,
      dueDate: null,
      birthDate: null,
    );
    final nextRich = rich.copyWith(
      pregnancyStatus: status,
      pregnancyWeekOverride: null,
      dueDateOverride: null,
      todayCheckIn: rich.todayCheckIn.copyWith(babyMovementCount: null),
    );
    return IdentityReconcileResult(dates: nextDates, rich: nextRich);
  }

  static IdentityReconcileResult _toPregnant({
    required RichUserProfile rich,
    required IdentityDates dates,
    required DateTime today,
  }) {
    final week = rich.pregnancyWeekOverride ?? 20;
    if (dates.dueDate == null) {
      return applyWeekOverrideWriteThrough(
        week: week,
        rich: rich,
        dates: dates,
        today: today,
      );
    }
    final nextDates = IdentityDates(
      lastMenstruationDate: dates.lastMenstruationDate,
      dueDate: dates.dueDate,
      birthDate: null,
    );
    var nextRich = rich.copyWith(
      pregnancyStatus: PregnancyStatus.pregnant,
      dueDateOverride: null,
    );
    if (rich.pregnancyWeekOverride != null) {
      return applyWeekOverrideWriteThrough(
        week: rich.pregnancyWeekOverride!,
        rich: nextRich,
        dates: nextDates,
        today: today,
      );
    }
    return IdentityReconcileResult(dates: nextDates, rich: nextRich);
  }

  static IdentityReconcileResult _toPostpartum({
    required RichUserProfile rich,
    required IdentityDates dates,
    required DateTime today,
  }) {
    final birth = dates.birthDate ?? today;
    // resolveStage returns PREP when dueDate is null — seed due ≈ birth.
    final due = dates.dueDate ?? birth;
    final nextDates = IdentityDates(
      lastMenstruationDate: dates.lastMenstruationDate,
      dueDate: due,
      birthDate: birth,
    );
    final nextRich = rich.copyWith(
      pregnancyStatus: PregnancyStatus.postpartum,
      pregnancyWeekOverride: null,
      dueDateOverride: null,
      todayCheckIn: rich.todayCheckIn.copyWith(babyMovementCount: null),
    );
    return IdentityReconcileResult(dates: nextDates, rich: nextRich);
  }

  static RichUserProfile _projectStatus(
    RichUserProfile rich,
    IdentityDates dates,
    DateTime today,
  ) {
    final stage = resolveStage(
      today: today,
      dueDate: dates.dueDate,
      birthDate: dates.birthDate,
      lastMenstruationDate: dates.lastMenstruationDate,
    ).stage;
    final projected = switch (stage) {
      Stage.prep => _prepStatus(rich.pregnancyStatus),
      Stage.pregnant => PregnancyStatus.pregnant,
      Stage.delivery || Stage.postpartum => PregnancyStatus.postpartum,
    };
    return rich.copyWith(pregnancyStatus: projected);
  }

  static PregnancyStatus _prepStatus(PregnancyStatus current) {
    return switch (current) {
      PregnancyStatus.notPregnant => PregnancyStatus.notPregnant,
      PregnancyStatus.tryingToConceive => PregnancyStatus.tryingToConceive,
      PregnancyStatus.unset => PregnancyStatus.unset,
      PregnancyStatus.pregnant || PregnancyStatus.postpartum =>
        PregnancyStatus.tryingToConceive,
    };
  }

  static RichUserProfile _clearIncompatibleCurrentFields(
    RichUserProfile rich,
    IdentityDates dates,
    DateTime today,
  ) {
    final stage = resolveStage(
      today: today,
      dueDate: dates.dueDate,
      birthDate: dates.birthDate,
      lastMenstruationDate: dates.lastMenstruationDate,
    ).stage;
    var next = rich;
    if (stage != Stage.pregnant) {
      next = next.copyWith(
        pregnancyWeekOverride: null,
        todayCheckIn: next.todayCheckIn.copyWith(babyMovementCount: null),
      );
    }
    return next;
  }

  static RichUserProfile _clearDueDateOverride(RichUserProfile rich) {
    if (rich.dueDateOverride == null) return rich;
    return rich.copyWith(dueDateOverride: null);
  }
}
