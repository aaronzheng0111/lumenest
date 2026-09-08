import 'stage.dart';

/// Calendar-day arithmetic for stage rules (P1: device local = Asia/Shanghai).
DateTime calendarDay(DateTime value) =>
    DateTime(value.year, value.month, value.day);

int calendarDaysBetween(DateTime from, DateTime to) {
  return calendarDay(to).difference(calendarDay(from)).inDays;
}

/// Outcome of [resolveStage] — matches `fixtures/stage_cases.json` fields.
class StageResolveResult {
  const StageResolveResult({
    required this.stage,
    this.weekValue,
    this.weekUnit,
    this.pregnancyWeek,
    this.postpartumWeek,
  });

  final Stage stage;
  final int? weekValue;
  final String? weekUnit;
  final int? pregnancyWeek;
  final int? postpartumWeek;
}

/// Pure stage machine (AC-03-B01). No Flutter / IO.
StageResolveResult resolveStage({
  required DateTime today,
  DateTime? dueDate,
  DateTime? birthDate,
  DateTime? lastMenstruationDate,
}) {
  final day = calendarDay(today);

  if (dueDate == null) {
    return const StageResolveResult(stage: Stage.prep);
  }

  final due = calendarDay(dueDate);
  if (day.isBefore(due)) {
    final week = pregnancyWeekFor(
      today: day,
      lastMenstruationDate: lastMenstruationDate,
      dueDate: due,
    );
    return StageResolveResult(
      stage: Stage.pregnant,
      weekValue: week,
      weekUnit: 'PREGNANCY_WEEK',
      pregnancyWeek: week,
    );
  }

  if (birthDate == null) {
    return const StageResolveResult(stage: Stage.delivery);
  }

  final birth = calendarDay(birthDate);
  final daysSinceBirth = calendarDaysBetween(birth, day);
  final postpartum = postpartumWeekFor(daysSinceBirth: daysSinceBirth);

  if (daysSinceBirth <= 42) {
    return StageResolveResult(
      stage: Stage.delivery,
      weekValue: postpartum,
      weekUnit: 'POSTPARTUM_WEEK',
      postpartumWeek: postpartum,
    );
  }

  return StageResolveResult(
    stage: Stage.postpartum,
    weekValue: postpartum,
    weekUnit: 'POSTPARTUM_WEEK',
    postpartumWeek: postpartum,
  );
}

/// Gestational week: floor(daysSinceLmp / 7) + 1, clamped to 1–42.
int pregnancyWeekFor({
  required DateTime today,
  DateTime? lastMenstruationDate,
  required DateTime dueDate,
}) {
  final lmp = lastMenstruationDate != null
      ? calendarDay(lastMenstruationDate)
      : calendarDay(dueDate).subtract(const Duration(days: 280));
  final days = calendarDaysBetween(lmp, today);
  final raw = (days ~/ 7) + 1;
  return clampPregnancyWeek(raw);
}

int clampPregnancyWeek(int raw) {
  if (raw < 1) return 1;
  if (raw > 42) return 42;
  return raw;
}

/// Postpartum / delivery week: floor(daysSinceBirth / 7) + 1.
int postpartumWeekFor({required int daysSinceBirth}) {
  if (daysSinceBirth < 0) return 1;
  return (daysSinceBirth ~/ 7) + 1;
}
