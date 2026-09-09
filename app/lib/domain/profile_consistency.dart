import 'identity_dates.dart';
import 'rich_user_profile.dart';
import 'stage_resolver.dart';

/// Validates parity / certainty / week-range constraints on a rich profile.
abstract final class ProfileConsistencyValidator {
  /// Returns human-readable error messages; empty means OK to save.
  static List<String> validate(
    RichUserProfile rich, {
    IdentityDates? dates,
    DateTime? today,
  }) {
    final errors = <String>[];

    if (rich.isFirstPregnancy == true) {
      final prev = rich.previousPregnancies;
      if (prev != null && prev > 0) {
        errors.add('首次怀孕时，既往怀孕次数应为 0');
      }
      final kids = rich.numberOfChildren;
      if (kids != null && kids > 0) {
        errors.add('首次怀孕时，子女数应为 0');
      }
    }

    if (rich.previousPregnancies != null && rich.previousPregnancies! < 0) {
      errors.add('既往怀孕次数不能为负数');
    }
    if (rich.numberOfChildren != null && rich.numberOfChildren! < 0) {
      errors.add('子女数不能为负数');
    }

    final week = rich.pregnancyWeekOverride;
    if (week != null && (week < 1 || week > 42)) {
      errors.add('孕周应在 1–42 之间');
    }

    if (dates != null && rich.estimatedConceptionDate != null) {
      final conception = calendarDay(rich.estimatedConceptionDate!);
      final day = calendarDay(today ?? DateTime.now());
      if (conception.isAfter(day)) {
        errors.add('预估受孕日不能晚于今天');
      }
      final birth = dates.birthDate;
      if (birth != null && conception.isAfter(calendarDay(birth))) {
        errors.add('预估受孕日不能晚于分娩日');
      }
      final due = dates.dueDate;
      if (due != null &&
          conception.isAfter(calendarDay(due).add(const Duration(days: 14)))) {
        errors.add('预估受孕日与预产期明显矛盾');
      }
    }

    return errors;
  }

  /// Clears medication/allergy lists when certainty is [FieldCertainty.none].
  static RichUserProfile normalizeCertaintyLists(RichUserProfile rich) {
    var next = rich;
    if (next.medicationsCertainty == FieldCertainty.none &&
        next.medications.isNotEmpty) {
      next = next.copyWith(medications: const <MedicationEntry>[]);
    }
    if (next.allergies.certainty == FieldCertainty.none &&
        next.allergies.listedCount > 0) {
      next = next.copyWith(
        allergies: const AllergyBag(certainty: FieldCertainty.none),
      );
    }
    return next;
  }
}
