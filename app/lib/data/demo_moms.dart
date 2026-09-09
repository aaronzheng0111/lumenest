import '../domain/rich_user_profile.dart';
import '../domain/stage.dart';
import '../domain/stage_resolver.dart';

/// One canned local account for previewing Home / Me across life stages.
final class DemoMom {
  const DemoMom({
    required this.id,
    required this.nickname,
    required this.status,
    required this.blurb,
    this.lmpDaysAgo,
    this.dueDaysFromToday,
    this.birthDaysAgo,
  });

  final int id;
  final String nickname;
  final PregnancyStatus status;
  final String blurb;

  /// Days before [today] for LMP (cycle / pregnancy week).
  final int? lmpDaysAgo;

  /// Days from [today] to due date (negative = already past).
  final int? dueDaysFromToday;

  /// Days before [today] for birth.
  final int? birthDaysAgo;

  /// Relative calendar dates for [today] (device local day).
  ({DateTime? lmp, DateTime? due, DateTime? birth}) datesFor(DateTime today) {
    final day = calendarDay(today);
    DateTime? offset(int? days, {required bool before}) {
      if (days == null) return null;
      return before
          ? day.subtract(Duration(days: days))
          : day.add(Duration(days: days));
    }

    return (
      lmp: offset(lmpDaysAgo, before: true),
      due: dueDaysFromToday == null
          ? null
          : (dueDaysFromToday! >= 0
              ? day.add(Duration(days: dueDaysFromToday!))
              : day.subtract(Duration(days: -dueDaysFromToday!))),
      birth: offset(birthDaysAgo, before: true),
    );
  }

  RichUserProfile get richProfile => RichUserProfile(
        pregnancyStatus: status,
        location: '深圳',
      );

  Stage expectedStage(DateTime today) {
    final d = datesFor(today);
    return resolveStage(
      today: today,
      dueDate: d.due,
      birthDate: d.birth,
      lastMenstruationDate: d.lmp,
    ).stage;
  }
}

/// Three period personas: 备孕 / 孕期 / 产后.
abstract final class DemoMoms {
  /// ~周期第 12 天备孕。
  static const prep = DemoMom(
    id: 1,
    nickname: '晓晓·备孕',
    status: PregnancyStatus.tryingToConceive,
    blurb: '备孕中，有末次月经，无预产期',
    lmpDaysAgo: 12,
  );

  /// 约孕 20 周。
  static const pregnant = DemoMom(
    id: 2,
    nickname: '林林·孕期',
    status: PregnancyStatus.pregnant,
    blurb: '怀孕中，约孕 20 周',
    lmpDaysAgo: 139, // floor(139/7)+1 = 20
    dueDaysFromToday: 141, // LMP+280 ≈ today+141
  );

  /// 产后约第 2 周（产褥期 DELIVERY）。
  static const postpartum = DemoMom(
    id: 3,
    nickname: '安安·产后',
    status: PregnancyStatus.postpartum,
    blurb: '产后约 2 周',
    birthDaysAgo: 14,
    dueDaysFromToday: -14,
  );

  static const List<DemoMom> all = [prep, pregnant, postpartum];

  static DemoMom? byId(int id) {
    for (final m in all) {
      if (m.id == id) return m;
    }
    return null;
  }
}
