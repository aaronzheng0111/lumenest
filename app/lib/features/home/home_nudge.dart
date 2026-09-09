import '../../domain/rich_user_profile.dart';
import '../../domain/stage.dart';
import '../../domain/user_profile_snapshot.dart';

/// Local one-liner nudge for Home (not a chat bubble).
final class HomeNudge {
  const HomeNudge({
    required this.message,
    required this.ctaLabel,
    required this.kind,
  });

  final String message;
  final String ctaLabel;
  final HomeNudgeKind kind;
}

enum HomeNudgeKind {
  water,
  vitamin,
  mood,
  profile,
}

/// Picks at most one contextual nudge from today's check-in + stage.
HomeNudge? resolveHomeNudge(UserProfileSnapshot snapshot) {
  final check = snapshot.rich.todayCheckIn;
  final status = snapshot.rich.pregnancyStatus;
  final needsVitamin = status == PregnancyStatus.tryingToConceive ||
      status == PregnancyStatus.pregnant ||
      snapshot.stage == Stage.pregnant ||
      snapshot.stage == Stage.prep;

  if (needsVitamin && check.prenatalVitaminTaken != true) {
    return const HomeNudge(
      message: '今天的叶酸/孕维还没打卡，记得按医嘱服用哦。',
      ctaLabel: '已服用',
      kind: HomeNudgeKind.vitamin,
    );
  }

  final water = check.waterMl ?? 0;
  final goal = snapshot.rich.dailyWaterGoalMl ?? 2000;
  if (water < goal * 0.25) {
    return const HomeNudge(
      message: '今天饮水还不多，先记一杯水吧（习惯提醒，非医嘱）。',
      ctaLabel: '喝水 +250',
      kind: HomeNudgeKind.water,
    );
  }

  if (check.mood == null || check.mood!.trim().isEmpty) {
    return const HomeNudge(
      message: '记一下今天的心情，方便回顾自己的状态。',
      ctaLabel: '去记录',
      kind: HomeNudgeKind.mood,
    );
  }

  if (status == PregnancyStatus.unset && snapshot.stage == Stage.prep) {
    return const HomeNudge(
      message: '完善孕期状态，首页会给你更贴合的每日照护建议。',
      ctaLabel: '去档案',
      kind: HomeNudgeKind.profile,
    );
  }

  return null;
}
