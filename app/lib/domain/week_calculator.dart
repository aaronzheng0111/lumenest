import 'stage_resolver.dart';

/// Thin wrappers kept as the Plan seam for week math unit tests.
abstract final class WeekCalculator {
  static int pregnancyWeek({
    required DateTime today,
    DateTime? lastMenstruationDate,
    required DateTime dueDate,
  }) {
    return pregnancyWeekFor(
      today: today,
      lastMenstruationDate: lastMenstruationDate,
      dueDate: dueDate,
    );
  }

  static int postpartumWeek({required int daysSinceBirth}) {
    return postpartumWeekFor(daysSinceBirth: daysSinceBirth);
  }
}
