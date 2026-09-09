import 'package:flutter_test/flutter_test.dart';

import 'package:ai_mom_baby/domain/effective_journey.dart';
import 'package:ai_mom_baby/domain/identity_dates.dart';
import 'package:ai_mom_baby/domain/identity_reconcile.dart';
import 'package:ai_mom_baby/domain/profile_consistency.dart';
import 'package:ai_mom_baby/domain/rich_user_profile.dart';
import 'package:ai_mom_baby/domain/stage.dart';
import 'package:ai_mom_baby/domain/stage_resolver.dart';
import 'package:ai_mom_baby/domain/user_profile_snapshot.dart';

void main() {
  final today = DateTime(2026, 9, 9);

  group('IdentityReconciler', () {
    test('should clear due/week/movement when switching pregnant to trying', () {
      final rich = RichUserProfile(
        pregnancyStatus: PregnancyStatus.pregnant,
        pregnancyWeekOverride: 20,
        todayCheckIn: const DailyCheckIn(babyMovementCount: 8),
      );
      final dates = IdentityDates(
        dueDate: DateTime(2026, 12, 1),
        lastMenstruationDate: DateTime(2026, 2, 25),
      );

      final result = IdentityReconciler.reconcileOnStatusIntent(
        status: PregnancyStatus.tryingToConceive,
        rich: rich,
        dates: dates,
        today: today,
      );

      expect(result.dates.dueDate, isNull);
      expect(result.dates.birthDate, isNull);
      expect(result.rich.pregnancyWeekOverride, isNull);
      expect(result.rich.todayCheckIn.babyMovementCount, isNull);
      expect(result.rich.pregnancyStatus, PregnancyStatus.tryingToConceive);

      final stage = resolveStage(
        today: today,
        dueDate: result.dates.dueDate,
        birthDate: result.dates.birthDate,
        lastMenstruationDate: result.dates.lastMenstruationDate,
      );
      expect(stage.stage, Stage.prep);

      final journey = EffectiveJourney.from(
        stage: stage.stage,
        rich: result.rich,
        dates: result.dates,
        today: today,
        weekValue: stage.weekValue,
        weekUnit: stage.weekUnit,
      );
      expect(journey.primaryLabel, '备孕中');
      expect(journey.primaryLabel.contains('孕20'), isFalse);
      expect(journey.summaryWithHistory(result.rich), isNot(contains('孕20')));
    });

    test('should drive non-PREP stage when postpartum with birth only', () {
      final result = IdentityReconciler.reconcileOnStatusIntent(
        status: PregnancyStatus.postpartum,
        rich: const RichUserProfile(),
        dates: const IdentityDates(),
        today: today,
      );

      expect(result.dates.birthDate, today);
      expect(result.dates.dueDate, isNotNull);
      final stage = resolveStage(
        today: today,
        dueDate: result.dates.dueDate,
        birthDate: result.dates.birthDate,
      );
      expect(stage.stage, isNot(Stage.prep));
      expect(result.rich.pregnancyStatus, PregnancyStatus.postpartum);

      final journey = EffectiveJourney.from(
        stage: stage.stage,
        rich: result.rich,
        dates: result.dates,
        today: today,
        weekValue: stage.weekValue,
        weekUnit: stage.weekUnit,
      );
      expect(journey.primaryLabel, contains('产'));
      expect(journey.primaryLabel.contains('备孕'), isFalse);
    });

    test('should write through week override then clear it', () {
      final result = IdentityReconciler.applyWeekOverrideWriteThrough(
        week: 12,
        rich: const RichUserProfile(pregnancyWeekOverride: 12),
        dates: const IdentityDates(),
        today: today,
      );

      expect(result.rich.pregnancyWeekOverride, isNull);
      expect(result.dates.dueDate, isNotNull);
      expect(result.dates.lastMenstruationDate, isNotNull);
      final stage = resolveStage(
        today: today,
        dueDate: result.dates.dueDate,
        birthDate: result.dates.birthDate,
        lastMenstruationDate: result.dates.lastMenstruationDate,
      );
      expect(stage.stage, Stage.pregnant);
      expect(stage.weekValue, 12);
    });

    test('should project status when dates change to pregnant', () {
      final due = today.add(const Duration(days: 100));
      final result = IdentityReconciler.reconcileOnDatesChange(
        dates: IdentityDates(dueDate: due),
        rich: const RichUserProfile(
          pregnancyStatus: PregnancyStatus.tryingToConceive,
          pregnancyWeekOverride: 5,
        ),
        today: today,
      );
      expect(result.rich.pregnancyStatus, PregnancyStatus.pregnant);
      expect(result.rich.dueDateOverride, isNull);
    });
  });

  group('EffectiveJourney', () {
    test('should never summarize prep as pregnant week', () {
      const snap = UserProfileSnapshot(
        stage: Stage.prep,
        rich: RichUserProfile(
          pregnancyStatus: PregnancyStatus.tryingToConceive,
          pregnancyWeekOverride: 20,
        ),
      );
      final journey = EffectiveJourney.fromSnapshot(snap, today: today);
      expect(journey.primaryLabel, '备孕中');
      expect(journey.summaryWithHistory(snap.rich), '备孕中');
      expect(journey.showBabyMovement, isFalse);
    });

    test('should expose pregnancy primary label from stage week', () {
      final journey = EffectiveJourney.from(
        stage: Stage.pregnant,
        weekValue: 20,
        weekUnit: 'PREGNANCY_WEEK',
        rich: const RichUserProfile(pregnancyStatus: PregnancyStatus.pregnant),
        dates: IdentityDates(dueDate: today.add(const Duration(days: 140))),
        today: today,
      );
      expect(journey.primaryLabel, '孕20周');
      expect(journey.statusLabel, '孕期');
      expect(journey.trimester, 2);
      expect(journey.showBabyMovement, isTrue);
      expect(journey.showPrenatalVitaminNudge, isTrue);
    });
  });

  group('ProfileConsistencyValidator', () {
    test('should reject first pregnancy with previous count', () {
      final errors = ProfileConsistencyValidator.validate(
        const RichUserProfile(
          isFirstPregnancy: true,
          previousPregnancies: 3,
        ),
      );
      expect(errors, isNotEmpty);
      expect(errors.first, contains('首次怀孕'));
    });

    test('should clear meds and allergies when certainty is none', () {
      final rich = RichUserProfile(
        medicationsCertainty: FieldCertainty.none,
        medications: const [MedicationEntry(name: '叶酸')],
        allergies: const AllergyBag(
          certainty: FieldCertainty.none,
          food: ['花生'],
        ),
      );
      final cleaned = ProfileConsistencyValidator.normalizeCertaintyLists(rich);
      expect(cleaned.medications, isEmpty);
      expect(cleaned.allergies.listedCount, 0);
      expect(cleaned.allergies.certainty, FieldCertainty.none);
    });
  });
}
