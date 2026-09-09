import 'package:flutter_test/flutter_test.dart';

import 'package:ai_mom_baby/data/fake_user_profile_repository.dart';
import 'package:ai_mom_baby/domain/rich_user_profile.dart';
import 'package:ai_mom_baby/domain/stage.dart';
import 'package:ai_mom_baby/domain/user_profile_snapshot.dart';
import 'package:ai_mom_baby/features/home/home_nudge.dart';

void main() {
  group('resolveHomeNudge', () {
    test('should prefer vitamin when not taken in prep', () {
      final nudge = resolveHomeNudge(
        const UserProfileSnapshot(stage: Stage.prep),
      );
      expect(nudge?.kind, HomeNudgeKind.vitamin);
    });

    test('should prefer water after vitamin taken', () {
      final nudge = resolveHomeNudge(
        UserProfileSnapshot(
          stage: Stage.prep,
          rich: RichUserProfile(
            todayCheckIn: DailyCheckIn(
              localDate: DateTime(2026, 9, 9),
              prenatalVitaminTaken: true,
            ),
          ),
        ),
      );
      expect(nudge?.kind, HomeNudgeKind.water);
    });

    test('should prefer mood when hydrated', () {
      final nudge = resolveHomeNudge(
        UserProfileSnapshot(
          stage: Stage.prep,
          rich: RichUserProfile(
            todayCheckIn: DailyCheckIn(
              localDate: DateTime(2026, 9, 9),
              prenatalVitaminTaken: true,
              waterMl: 800,
            ),
          ),
        ),
      );
      expect(nudge?.kind, HomeNudgeKind.mood);
    });
  });

  group('FakeUserProfileRepository.updateTodayCheckIn', () {
    test('should accumulate water and log habit event', () async {
      final repo = FakeUserProfileRepository();
      await repo.updateTodayCheckIn(
        (c) => c.copyWith(waterMl: (c.waterMl ?? 0) + 250.0),
        now: DateTime(2026, 9, 9, 10),
        eventCategory: 'HABIT',
        eventSummary: '饮水 +250ml',
      );
      expect(repo.rich.todayCheckIn.waterMl, 250);
      expect(repo.wellnessEvents, isNotEmpty);
      expect(repo.wellnessEvents.first.category, 'HABIT');
    });

    test('should reset check-in on a new calendar day', () async {
      final repo = FakeUserProfileRepository(
        rich: RichUserProfile(
          todayCheckIn: DailyCheckIn(
            localDate: DateTime(2026, 9, 8),
            waterMl: 900,
            mood: '开心',
          ),
        ),
      );
      await repo.updateTodayCheckIn(
        (c) => c.copyWith(waterMl: 250.0),
        now: DateTime(2026, 9, 9),
      );
      expect(repo.rich.todayCheckIn.waterMl, 250);
      expect(repo.rich.todayCheckIn.mood, isNull);
    });
  });
}
