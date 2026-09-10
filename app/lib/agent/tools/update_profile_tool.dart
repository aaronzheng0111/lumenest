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
    this.proposeOnly = false,
  });

  final bool applied;
  final String summary;

  /// Sensitive patch detected but not written — user must confirm explicitly.
  final bool proposeOnly;
}

/// Local tool: update rich profile / daily check-in from chat intents.
///
/// Writes through [UserProfileRepository] — same SSOT as Profile UI editors.
/// Identity / clear / list-overwrite intents require [hasExplicitWriteIntent].
/// Safe daily check-ins may auto-apply.
abstract final class UpdateProfileTool {
  static const name = 'update_profile';

  static final RegExp _weekZh = RegExp(r'孕\s*(\d{1,2})\s*周');
  static final RegExp _weekZhAlt = RegExp(r'(\d{1,2})\s*周孕');
  static final RegExp _weekEn =
      RegExp(r'(\d{1,2})\s*weeks?\s*pregnant', caseSensitive: false);

  static final RegExp _water =
      RegExp(r'(?:喝了|饮水|喝水)\s*(\d{2,4})\s*(?:ml|毫升)?');
  static final RegExp _weight =
      RegExp(r'(?:体重|称重)\s*(\d{2,3}(?:\.\d)?)\s*(?:kg|公斤)?');
  static final RegExp _sleep =
      RegExp(r'(?:睡了|睡眠)\s*(\d{1,2}(?:\.\d)?)\s*(?:小时|h)?');
  static final RegExp _steps = RegExp(r'(?:步数|走了)\s*(\d{3,5})\s*步?');
  static final RegExp _kicks = RegExp(r'(?:胎动|踢了)\s*(\d{1,3})\s*次?');
  static final RegExp _height =
      RegExp(r'身高\s*(\d{2,3}(?:\.\d)?)\s*(?:cm|厘米)?');
  static final RegExp _blood = RegExp(r'血型\s*([ABO]{1,2}[+-]?)');
  static final RegExp _allergySet = RegExp(
    r'过敏\s*[:：]?\s*([^\s。！!？?\n]{1,40})',
  );
  static final RegExp _allergySetStrict = RegExp(
    r'(?:过敏|allerg(?:y|ies)?(?:\s*to)?)\s*[:：]\s*(.+)',
    caseSensitive: false,
  );
  static final RegExp _likeFood = RegExp(r'(?:喜欢吃|爱吃)\s*[:：]?\s*(.+)');
  static final RegExp _dislikeFood = RegExp(r'(?:不喜欢吃|讨厌吃)\s*[:：]?\s*(.+)');

  /// Explicit confirm / edit phrasing for sensitive writes.
  static bool hasExplicitWriteIntent(String userText) {
    final t = userText.trim().toLowerCase();
    if (t.isEmpty) return false;
    const markers = [
      '更新档案',
      '修改档案',
      '改一下档案',
      '确认更新档案',
      '帮我改档案',
      'update my profile',
      'update profile',
    ];
    for (final m in markers) {
      if (t.contains(m.toLowerCase())) return true;
    }
    return false;
  }

  /// Keywords / patterns that suggest a profile update turn.
  static bool shouldInvoke(String userText) {
    final t = userText.trim();
    if (t.isEmpty) return false;
    if (hasExplicitWriteIntent(t)) return true;

    // Safe check-in / structured vitals (auto-apply candidates).
    const safeNeedles = [
      '吃了叶酸',
      '吃了孕维',
      '吃了维生素',
      'took my prenatal',
      'prenatal vitamin',
    ];
    final lower = t.toLowerCase();
    for (final n in safeNeedles) {
      if (lower.contains(n.toLowerCase())) return true;
    }
    if (_weekZh.hasMatch(t) || _weekZhAlt.hasMatch(t) || _weekEn.hasMatch(t)) {
      return true;
    }
    if (_water.hasMatch(t) ||
        _weight.hasMatch(t) ||
        _sleep.hasMatch(t) ||
        _steps.hasMatch(t) ||
        _kicks.hasMatch(t) ||
        _height.hasMatch(t) ||
        _blood.hasMatch(t)) {
      return true;
    }

    // Sensitive intents only when phrased as an explicit status change,
    // or when paired with archive markers (already returned above).
    if (_hasIdentityStatusPhrase(t) ||
        _hasAllergyClearPhrase(t) ||
        _allergySetStrict.hasMatch(t) ||
        _allergySet.hasMatch(t) ||
        _likeFood.hasMatch(t) ||
        _dislikeFood.hasMatch(t) ||
        _hasDietPhrase(t) ||
        _hasCommunicationPhrase(t)) {
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
    final blockedSensitive = <String>[];
    final explicit = hasExplicitWriteIntent(t);

    final draft = await profiles.loadDraft();
    var dates = IdentityDates(
      lastMenstruationDate: draft.lastMenstruationDate,
      dueDate: draft.dueDate,
      birthDate: draft.birthDate,
    );
    var datesDirty = false;
    String? datesError;

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

      // --- Identity (sensitive): week number is specific enough to auto-apply;
      // status flips need explicit write intent.
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
      } else if (_wantsPregnant(t)) {
        if (explicit) {
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
        } else {
          blockedSensitive.add('妊娠状态→怀孕中');
        }
      } else if (_wantsTrying(t)) {
        if (explicit) {
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
        } else {
          blockedSensitive.add('妊娠状态→备孕中');
        }
      } else if (_wantsPostpartum(t)) {
        if (explicit) {
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
        } else {
          blockedSensitive.add('妊娠状态→产后');
        }
      }

      // --- Allergies (sensitive clear / set)
      if (_hasAllergyClearPhrase(t)) {
        if (explicit) {
          profile = profile.copyWith(
            allergies: const AllergyBag(certainty: FieldCertainty.none),
          );
          changes.add('过敏：无');
        } else {
          blockedSensitive.add('清空过敏');
        }
      } else {
        final allergyMatch = _allergySetStrict.firstMatch(t) ??
            (explicit ? _allergySet.firstMatch(t) : null);
        if (allergyMatch != null) {
          final items = _splitTags(allergyMatch.group(1)!, maxLen: 40);
          if (items.isNotEmpty) {
            if (explicit) {
              final merged = _mergeTags(profile.allergies.other, items);
              profile = profile.copyWith(
                allergies: AllergyBag(
                  certainty: FieldCertainty.known,
                  other: merged,
                ),
              );
              changes.add('过敏：${merged.join("、")}');
            } else {
              blockedSensitive.add('过敏→${items.join("、")}');
            }
          }
        }
      }

      // --- Safe daily check-in / vitals (ranged)
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

      final waterMatch = _water.firstMatch(t);
      if (waterMatch != null) {
        final ml = double.tryParse(waterMatch.group(1)!);
        if (ml != null && ml >= 50 && ml <= 5000) {
          check = check.copyWith(localDate: checkDay, waterMl: ml);
          changes.add('今日饮水：${ml.round()}ml');
        }
      }

      final weightMatch = _weight.firstMatch(t);
      if (weightMatch != null) {
        final kg = double.tryParse(weightMatch.group(1)!);
        if (kg != null && kg >= 30 && kg <= 200) {
          check = check.copyWith(localDate: checkDay, weightKg: kg);
          profile = profile.copyWith(currentWeightKg: kg);
          changes.add('体重：$kg kg');
        }
      }

      final sleepMatch = _sleep.firstMatch(t);
      if (sleepMatch != null) {
        final h = double.tryParse(sleepMatch.group(1)!);
        if (h != null && h >= 0 && h <= 24) {
          check = check.copyWith(localDate: checkDay, sleepHours: h);
          changes.add('今日睡眠：${h}h');
        }
      }

      final stepsMatch = _steps.firstMatch(t);
      if (stepsMatch != null) {
        final s = int.tryParse(stepsMatch.group(1)!);
        if (s != null && s >= 0 && s <= 100000) {
          check = check.copyWith(localDate: checkDay, steps: s);
          changes.add('今日步数：$s');
        }
      }

      final kickMatch = _kicks.firstMatch(t);
      if (kickMatch != null) {
        final k = int.tryParse(kickMatch.group(1)!);
        if (k != null && k >= 0 && k <= 200) {
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

      final heightMatch = _height.firstMatch(t);
      if (heightMatch != null) {
        final h = double.tryParse(heightMatch.group(1)!);
        if (h != null && h >= 100 && h <= 250) {
          profile = profile.copyWith(heightCm: h);
          changes.add('身高：$h cm');
        }
      }

      final bloodMatch = _blood.firstMatch(t);
      if (bloodMatch != null) {
        profile = profile.copyWith(bloodType: bloodMatch.group(1));
        changes.add('血型：${bloodMatch.group(1)}');
      }

      // --- Diet / foods / communication (sensitive overwrite → merge + explicit)
      if (t.contains('纯素') || t.toLowerCase().contains('vegan')) {
        if (explicit) {
          profile = profile.copyWith(dietPreference: DietPreference.vegan);
          changes.add('饮食：纯素');
        } else {
          blockedSensitive.add('饮食→纯素');
        }
      } else if (t.contains('素食') ||
          t.toLowerCase().contains('vegetarian')) {
        if (explicit) {
          profile = profile.copyWith(dietPreference: DietPreference.vegetarian);
          changes.add('饮食：素食');
        } else {
          blockedSensitive.add('饮食→素食');
        }
      }

      if (_hasCommunicationPhrase(t)) {
        if (explicit) {
          if (t.contains('简洁')) {
            profile = profile.copyWith(
              communicationStyle: CommunicationStyle.concise,
            );
            changes.add('沟通：简洁');
          } else if (t.contains('详细')) {
            profile = profile.copyWith(
              communicationStyle: CommunicationStyle.detailed,
            );
            changes.add('沟通：详细');
          } else if (t.contains('亲切') || t.contains('友好')) {
            profile = profile.copyWith(
              communicationStyle: CommunicationStyle.friendly,
            );
            changes.add('沟通：亲切');
          } else if (t.contains('专业')) {
            profile = profile.copyWith(
              communicationStyle: CommunicationStyle.professional,
            );
            changes.add('沟通：专业');
          }
        } else {
          blockedSensitive.add('沟通风格');
        }
      }

      final likeMatch = _likeFood.firstMatch(t);
      if (likeMatch != null) {
        final items = _splitTags(likeMatch.group(1)!, maxLen: 30);
        if (items.isNotEmpty) {
          if (explicit) {
            final merged = _mergeTags(profile.favoriteFoods, items);
            profile = profile.copyWith(favoriteFoods: merged);
            changes.add('爱吃：${merged.join("、")}');
          } else {
            blockedSensitive.add('爱吃→${items.join("、")}');
          }
        }
      }

      final dislikeMatch = _dislikeFood.firstMatch(t);
      if (dislikeMatch != null) {
        final items = _splitTags(dislikeMatch.group(1)!, maxLen: 30);
        if (items.isNotEmpty) {
          if (explicit) {
            final merged = _mergeTags(profile.dislikedFoods, items);
            profile = profile.copyWith(dislikedFoods: merged);
            changes.add('不爱吃：${merged.join("、")}');
          } else {
            blockedSensitive.add('不爱吃→${items.join("、")}');
          }
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
      } on ProfileValidationException catch (e) {
        datesError = e.message;
      }
    }

    if (changes.isEmpty && blockedSensitive.isNotEmpty) {
      return ProfileToolResult(
        applied: false,
        proposeOnly: true,
        summary: '敏感修改未写入（${blockedSensitive.join("；")}）。'
            '请再说「更新档案：…」确认，或到「我的」手动修改',
      );
    }

    if (changes.isEmpty) {
      return const ProfileToolResult(
        applied: false,
        summary: '未识别到可写入的档案字段，可在「我的」里手动编辑',
      );
    }

    var summary = changes.join('；');
    if (blockedSensitive.isNotEmpty) {
      summary = '$summary。另有敏感项未写入（${blockedSensitive.join("；")}），'
          '请用「更新档案：…」确认';
    }
    if (datesError != null) {
      summary = '$summary（阶段日期未同步：$datesError）';
    }
    return ProfileToolResult(applied: true, summary: summary);
  }

  static bool _hasIdentityStatusPhrase(String t) =>
      _wantsPregnant(t) || _wantsTrying(t) || _wantsPostpartum(t);

  static bool _wantsPregnant(String t) {
    final lower = t.toLowerCase();
    return t.contains('我怀孕') ||
        lower.contains('i am pregnant') ||
        lower.contains("i'm pregnant");
  }

  static bool _wantsTrying(String t) {
    final lower = t.toLowerCase();
    // Avoid bare「备孕」in prose like「备孕知识」.
    return RegExp(r'(我在备孕|改成备孕|状态.{0,4}备孕|备孕中)').hasMatch(t) ||
        lower.contains('trying to conceive');
  }

  static bool _wantsPostpartum(String t) {
    final lower = t.toLowerCase();
    // Avoid bare「产后」in「产后抑郁」unless explicit status phrasing.
    return RegExp(r'(我产后了|改成产后|状态.{0,4}产后|已经产后)').hasMatch(t) ||
        RegExp(r'\bi am postpartum\b').hasMatch(lower) ||
        RegExp(r"\bi'?m postpartum\b").hasMatch(lower);
  }

  static bool _hasAllergyClearPhrase(String t) {
    final lower = t.toLowerCase();
    return t.contains('无过敏') ||
        t.contains('没有过敏') ||
        lower.contains('no allergies');
  }

  static bool _hasDietPhrase(String t) {
    final lower = t.toLowerCase();
    return t.contains('纯素') ||
        t.contains('素食') ||
        lower.contains('vegan') ||
        lower.contains('vegetarian');
  }

  static bool _hasCommunicationPhrase(String t) =>
      t.contains('沟通风格') ||
      (t.contains('沟通') &&
          (t.contains('简洁') ||
              t.contains('详细') ||
              t.contains('亲切') ||
              t.contains('专业')));

  static List<String> _splitTags(String raw, {required int maxLen}) => raw
      .split(RegExp(r'[,，、/]|和'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty && s.length < maxLen)
      .take(8)
      .toList();

  static List<String> _mergeTags(List<String> existing, List<String> incoming) {
    final out = <String>[...existing];
    for (final item in incoming) {
      if (!out.any((e) => e.toLowerCase() == item.toLowerCase())) {
        out.add(item);
      }
    }
    return out.take(12).toList();
  }
}
