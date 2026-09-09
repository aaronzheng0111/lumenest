import '../../data/user_profile_repository.dart';
import '../../domain/effective_journey.dart';
import '../../domain/identity_dates.dart';
import '../../domain/identity_reconcile.dart';
import '../../domain/profile_consistency.dart';
import '../../domain/rich_user_profile.dart';
import '../../domain/stage_resolver.dart';

/// Result of a local profile-mutating tool call.
final class ProfileToolResult {
  const ProfileToolResult({
    required this.applied,
    required this.summary,
  });

  final bool applied;
  final String summary;
}

/// Local tool: update rich profile / daily check-in from chat intents.
///
/// Writes through [UserProfileRepository] — same SSOT as Profile UI editors.
/// Identity intents mutate dates via [IdentityReconciler], not status-only.
abstract final class UpdateProfileTool {
  static const name = 'update_profile';

  static final RegExp _weekZh = RegExp(r'孕\s*(\d{1,2})\s*周');
  static final RegExp _weekZhAlt = RegExp(r'(\d{1,2})\s*周孕');
  static final RegExp _weekEn =
      RegExp(r'(\d{1,2})\s*weeks?\s*pregnant', caseSensitive: false);

  /// Keywords / patterns that suggest a profile update turn.
  static bool shouldInvoke(String userText) {
    final t = userText.trim();
    if (t.isEmpty) return false;
    const needles = [
      '更新档案',
      '修改档案',
      '改一下档案',
      '我怀孕',
      '孕周',
      '过敏',
      '吃了叶酸',
      '吃了孕维',
      '吃了维生素',
      '喝了水',
      '饮水',
      '体重',
      '睡了',
      '睡眠',
      '步数',
      '胎动',
      '沟通风格',
      '喜欢吃',
      '不喜欢吃',
      '爱吃',
      '素食',
      '纯素',
      '血型',
      '身高',
      '无过敏',
      '没有过敏',
      '备孕',
      '产后',
      'update my',
      'i am pregnant',
      "i'm pregnant",
      'weeks pregnant',
      'took my prenatal',
      'allerg',
      'postpartum',
      'vegan',
    ];
    final lower = t.toLowerCase();
    for (final n in needles) {
      if (lower.contains(n.toLowerCase())) return true;
    }
    if (_weekZh.hasMatch(t) || _weekZhAlt.hasMatch(t) || _weekEn.hasMatch(t)) {
      return true;
    }
    return false;
  }

  /// Applies best-effort patches from free text; returns a human summary.
  static Future<ProfileToolResult> invoke({
    required UserProfileRepository profiles,
    required String userText,
    DateTime? now,
  }) async {
    final t = userText.trim();
    final day = now ?? DateTime.now();
    final changes = <String>[];

    final draft = await profiles.loadDraft();
    var dates = IdentityDates(
      lastMenstruationDate: draft.lastMenstruationDate,
      dueDate: draft.dueDate,
      birthDate: draft.birthDate,
    );
    var datesDirty = false;

    await profiles.updateRichProfile((current) {
      var profile = current;
      var check = current.todayCheckIn;
      final checkDay = DateTime(day.year, day.month, day.day);
      if (check.localDate == null ||
          check.localDate!.year != checkDay.year ||
          check.localDate!.month != checkDay.month ||
          check.localDate!.day != checkDay.day) {
        check = DailyCheckIn(localDate: checkDay);
      }

      final weekMatch = _weekZh.firstMatch(t) ??
          _weekZhAlt.firstMatch(t) ??
          _weekEn.firstMatch(t);
      if (weekMatch != null) {
        final w = int.tryParse(weekMatch.group(1)!);
        if (w != null && w >= 1 && w <= 42) {
          final reconciled = IdentityReconciler.applyWeekOverrideWriteThrough(
            week: w,
            rich: profile.copyWith(todayCheckIn: check),
            dates: dates,
            today: day,
          );
          dates = reconciled.dates;
          datesDirty = true;
          profile = reconciled.rich;
          check = profile.todayCheckIn;
          changes.add('孕周更新为第$w周');
        }
      } else if (t.contains('我怀孕') ||
          t.toLowerCase().contains('i am pregnant') ||
          t.toLowerCase().contains("i'm pregnant")) {
        final reconciled = IdentityReconciler.reconcileOnStatusIntent(
          status: PregnancyStatus.pregnant,
          rich: profile.copyWith(todayCheckIn: check),
          dates: dates,
          today: day,
        );
        dates = reconciled.dates;
        datesDirty = true;
        profile = reconciled.rich;
        check = profile.todayCheckIn;
        changes.add('妊娠状态：怀孕中');
      } else if (t.contains('备孕') ||
          t.contains('想怀孕') ||
          t.toLowerCase().contains('trying to conceive')) {
        final reconciled = IdentityReconciler.reconcileOnStatusIntent(
          status: PregnancyStatus.tryingToConceive,
          rich: profile.copyWith(todayCheckIn: check),
          dates: dates,
          today: day,
        );
        dates = reconciled.dates;
        datesDirty = true;
        profile = reconciled.rich;
        check = profile.todayCheckIn;
        changes.add('妊娠状态：备孕中');
      } else if (t.contains('产后') ||
          t.toLowerCase().contains('postpartum')) {
        final reconciled = IdentityReconciler.reconcileOnStatusIntent(
          status: PregnancyStatus.postpartum,
          rich: profile.copyWith(todayCheckIn: check),
          dates: dates,
          today: day,
        );
        dates = reconciled.dates;
        datesDirty = true;
        profile = reconciled.rich;
        check = profile.todayCheckIn;
        changes.add('妊娠状态：产后');
      }

      if (t.contains('无过敏') ||
          t.contains('没有过敏') ||
          t.toLowerCase().contains('no allergies')) {
        profile = profile.copyWith(
          allergies: const AllergyBag(certainty: FieldCertainty.none),
        );
        changes.add('过敏：无');
      } else {
        final allergyMatch = RegExp(
          r'(?:过敏|allerg(?:y|ies)?(?:\s*to)?)\s*[:：]?\s*(.+)',
          caseSensitive: false,
        ).firstMatch(t);
        if (allergyMatch != null) {
          final items = _splitTags(allergyMatch.group(1)!, maxLen: 40);
          if (items.isNotEmpty) {
            profile = profile.copyWith(
              allergies: AllergyBag(
                certainty: FieldCertainty.known,
                other: items,
              ),
            );
            changes.add('过敏：${items.join("、")}');
          }
        }
      }

      if (t.contains('吃了叶酸') ||
          t.contains('吃了孕维') ||
          t.contains('吃了维生素') ||
          t.toLowerCase().contains('took my prenatal') ||
          t.toLowerCase().contains('prenatal vitamin')) {
        check = check.copyWith(
          localDate: checkDay,
          prenatalVitaminTaken: true,
        );
        changes.add('今日：已服孕期维生素/叶酸');
      }

      final waterMatch =
          RegExp(r'(?:喝了|饮水|喝水)\s*(\d{2,4})\s*(?:ml|毫升)?').firstMatch(t);
      if (waterMatch != null) {
        final ml = double.tryParse(waterMatch.group(1)!);
        if (ml != null) {
          check = check.copyWith(localDate: checkDay, waterMl: ml);
          changes.add('今日饮水：${ml.round()}ml');
        }
      }

      final weightMatch =
          RegExp(r'(?:体重|称重)\s*(\d{2,3}(?:\.\d)?)\s*(?:kg|公斤)?').firstMatch(t);
      if (weightMatch != null) {
        final kg = double.tryParse(weightMatch.group(1)!);
        if (kg != null) {
          check = check.copyWith(localDate: checkDay, weightKg: kg);
          profile = profile.copyWith(currentWeightKg: kg);
          changes.add('体重：$kg kg');
        }
      }

      final sleepMatch =
          RegExp(r'(?:睡了|睡眠)\s*(\d{1,2}(?:\.\d)?)\s*(?:小时|h)?').firstMatch(t);
      if (sleepMatch != null) {
        final h = double.tryParse(sleepMatch.group(1)!);
        if (h != null) {
          check = check.copyWith(localDate: checkDay, sleepHours: h);
          changes.add('今日睡眠：${h}h');
        }
      }

      final stepsMatch = RegExp(r'(?:步数|走了)\s*(\d{3,5})\s*步?').firstMatch(t);
      if (stepsMatch != null) {
        final s = int.tryParse(stepsMatch.group(1)!);
        if (s != null) {
          check = check.copyWith(localDate: checkDay, steps: s);
          changes.add('今日步数：$s');
        }
      }

      final kickMatch = RegExp(r'(?:胎动|踢了)\s*(\d{1,3})\s*次?').firstMatch(t);
      if (kickMatch != null) {
        final k = int.tryParse(kickMatch.group(1)!);
        if (k != null) {
          final stage = resolveStage(
            today: day,
            dueDate: dates.dueDate,
            birthDate: dates.birthDate,
            lastMenstruationDate: dates.lastMenstruationDate,
          );
          final journey = EffectiveJourney.from(
            stage: stage.stage,
            weekValue: stage.weekValue,
            weekUnit: stage.weekUnit,
            rich: profile,
            dates: dates,
            today: day,
          );
          if (journey.showBabyMovement) {
            check = check.copyWith(localDate: checkDay, babyMovementCount: k);
            changes.add('今日胎动：$k 次');
          }
        }
      }

      final heightMatch =
          RegExp(r'身高\s*(\d{2,3}(?:\.\d)?)\s*(?:cm|厘米)?').firstMatch(t);
      if (heightMatch != null) {
        final h = double.tryParse(heightMatch.group(1)!);
        if (h != null) {
          profile = profile.copyWith(heightCm: h);
          changes.add('身高：$h cm');
        }
      }

      final bloodMatch = RegExp(r'血型\s*([ABO]{1,2}[+-]?)').firstMatch(t);
      if (bloodMatch != null) {
        profile = profile.copyWith(bloodType: bloodMatch.group(1));
        changes.add('血型：${bloodMatch.group(1)}');
      }

      if (t.contains('纯素') || t.toLowerCase().contains('vegan')) {
        profile = profile.copyWith(dietPreference: DietPreference.vegan);
        changes.add('饮食：纯素');
      } else if (t.contains('素食')) {
        profile = profile.copyWith(dietPreference: DietPreference.vegetarian);
        changes.add('饮食：素食');
      }

      if (t.contains('沟通') || t.contains('风格')) {
        if (t.contains('简洁')) {
          profile =
              profile.copyWith(communicationStyle: CommunicationStyle.concise);
          changes.add('沟通：简洁');
        } else if (t.contains('详细')) {
          profile =
              profile.copyWith(communicationStyle: CommunicationStyle.detailed);
          changes.add('沟通：详细');
        } else if (t.contains('亲切') || t.contains('友好')) {
          profile =
              profile.copyWith(communicationStyle: CommunicationStyle.friendly);
          changes.add('沟通：亲切');
        } else if (t.contains('专业')) {
          profile = profile.copyWith(
            communicationStyle: CommunicationStyle.professional,
          );
          changes.add('沟通：专业');
        }
      }

      final likeMatch = RegExp(r'(?:喜欢吃|爱吃)\s*[:：]?\s*(.+)').firstMatch(t);
      if (likeMatch != null) {
        final items = _splitTags(likeMatch.group(1)!, maxLen: 30);
        if (items.isNotEmpty) {
          profile = profile.copyWith(favoriteFoods: items);
          changes.add('爱吃：${items.join("、")}');
        }
      }

      final dislikeMatch =
          RegExp(r'(?:不喜欢吃|讨厌吃)\s*[:：]?\s*(.+)').firstMatch(t);
      if (dislikeMatch != null) {
        final items = _splitTags(dislikeMatch.group(1)!, maxLen: 30);
        if (items.isNotEmpty) {
          profile = profile.copyWith(dislikedFoods: items);
          changes.add('不爱吃：${items.join("、")}');
        }
      }

      if (changes.isEmpty) return current;
      return ProfileConsistencyValidator.normalizeCertaintyLists(
        profile.copyWith(todayCheckIn: check),
      );
    });

    if (datesDirty) {
      try {
        await profiles.saveEdits(
          ProfileEdits.fromIdentityDates(dates),
          today: day,
        );
      } on ProfileValidationException {
        // Rich profile still updated; stage sync is best-effort.
      }
    }

    if (changes.isEmpty) {
      return const ProfileToolResult(
        applied: false,
        summary: '未识别到可写入的档案字段，可在「我的」里手动编辑',
      );
    }
    return ProfileToolResult(
      applied: true,
      summary: changes.join('；'),
    );
  }

  static List<String> _splitTags(String raw, {required int maxLen}) => raw
      .split(RegExp(r'[,，、/]|和'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty && s.length < maxLen)
      .take(8)
      .toList();
}
