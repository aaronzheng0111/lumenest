import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/rich_user_profile.dart';
import '../../domain/user_profile_snapshot.dart';
import '../../providers.dart';
import '../../theme/spacing_tokens.dart';
import 'profile_ui_shared.dart';

/// Manual editor: lifestyle + today's check-in strip fields.
class LifestyleSectionPage extends ConsumerStatefulWidget {
  const LifestyleSectionPage({super.key});

  @override
  ConsumerState<LifestyleSectionPage> createState() =>
      _LifestyleSectionPageState();
}

class _LifestyleSectionPageState extends ConsumerState<LifestyleSectionPage> {
  DietPreference _diet = DietPreference.unset;
  final _waterGoal = TextEditingController();
  final _waterToday = TextEditingController();
  final _sleep = TextEditingController();
  final _sleepQuality = TextEditingController();
  final _stepsGoal = TextEditingController();
  final _stepsToday = TextEditingController();
  final _exerciseFreq = TextEditingController();
  final _exerciseType = TextEditingController();
  final _caffeine = TextEditingController();
  final _alcohol = TextEditingController();
  final _smoking = TextEditingController();
  final _foodPrefs = TextEditingController();
  final _foodAvoid = TextEditingController();
  final _nutrition = TextEditingController();
  final _mood = TextEditingController();
  final _weightToday = TextEditingController();
  bool _vitaminTaken = false;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _waterGoal.dispose();
    _waterToday.dispose();
    _sleep.dispose();
    _sleepQuality.dispose();
    _stepsGoal.dispose();
    _stepsToday.dispose();
    _exerciseFreq.dispose();
    _exerciseType.dispose();
    _caffeine.dispose();
    _alcohol.dispose();
    _smoking.dispose();
    _foodPrefs.dispose();
    _foodAvoid.dispose();
    _nutrition.dispose();
    _mood.dispose();
    _weightToday.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final rich = await ref.read(userProfileRepositoryProvider).loadRichProfile();
    final check = rich.todayCheckIn;
    if (!mounted) return;
    setState(() {
      _diet = rich.dietPreference;
      _waterGoal.text = rich.dailyWaterGoalMl?.toString() ?? '';
      _waterToday.text = check.waterMl?.toString() ?? '';
      _sleep.text = check.sleepHours?.toString() ??
          rich.typicalSleepHours?.toString() ??
          '';
      _sleepQuality.text = rich.sleepQuality ?? '';
      _stepsGoal.text = rich.dailyStepsGoal?.toString() ?? '';
      _stepsToday.text = check.steps?.toString() ?? '';
      _exerciseFreq.text = rich.exerciseFrequency ?? '';
      _exerciseType.text = rich.exerciseType ?? '';
      _caffeine.text = rich.caffeine ?? '';
      _alcohol.text = rich.alcohol ?? '';
      _smoking.text = rich.smoking ?? '';
      _foodPrefs.text = rich.foodPreferences.join('、');
      _foodAvoid.text = rich.foodsAvoided.join('、');
      _nutrition.text = check.nutritionNote ?? rich.nutritionalGoals ?? '';
      _mood.text = check.mood ?? '';
      _weightToday.text = check.weightKg?.toString() ?? '';
      _vitaminTaken = check.prenatalVitaminTaken == true;
      _loading = false;
    });
  }


  Future<void> _save() async {
    if (_saving) return;
    await runProfileSectionSave(
      context: context,
      setSaving: (v) => setState(() => _saving = v),
      save: () => commitRichProfile(ref, (current) {
        final now = DateTime.now();
        final day = DateTime(now.year, now.month, now.day);
        final weightToday = double.tryParse(_weightToday.text.trim());
        return current.copyWith(
          dietPreference: _diet,
          dailyWaterGoalMl: double.tryParse(_waterGoal.text.trim()),
          typicalSleepHours: double.tryParse(_sleep.text.trim()),
          sleepQuality: emptyToNull(_sleepQuality.text),
          dailyStepsGoal: int.tryParse(_stepsGoal.text.trim()),
          exerciseFrequency: emptyToNull(_exerciseFreq.text),
          exerciseType: emptyToNull(_exerciseType.text),
          caffeine: emptyToNull(_caffeine.text),
          alcohol: emptyToNull(_alcohol.text),
          smoking: emptyToNull(_smoking.text),
          foodPreferences: splitProfileTags(_foodPrefs.text),
          foodsAvoided: splitProfileTags(_foodAvoid.text),
          nutritionalGoals: emptyToNull(_nutrition.text),
          todayCheckIn: DailyCheckIn(
            localDate: day,
            waterMl: double.tryParse(_waterToday.text.trim()),
            weightKg: weightToday,
            sleepHours: double.tryParse(_sleep.text.trim()),
            steps: int.tryParse(_stepsToday.text.trim()),
            nutritionNote: emptyToNull(_nutrition.text),
            mood: emptyToNull(_mood.text),
            prenatalVitaminTaken: _vitaminTaken,
            babyMovementCount: current.todayCheckIn.babyMovementCount,
          ),
          currentWeightKg: weightToday ?? current.currentWeightKg,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const ProfileSectionLoading(title: '生活方式');
    }
    return ProfileSectionScaffold(
      title: '生活方式',
      saving: _saving,
      onSave: _save,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('饮食偏好', style: Theme.of(context).textTheme.titleSmall),
          profileChoiceChips(
            values: DietPreference.values,
            selected: _diet,
            labelOf: (d) => d.label,
            onChanged: (d) => setState(() => _diet = d),
          ),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(
            controller: _waterGoal,
            label: '每日饮水目标 (ml)',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(
            fieldKey: const Key('lifestyle_water_today'),
            controller: _waterToday,
            label: '今日已饮水 (ml)',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(
            controller: _sleep,
            label: '睡眠时长 (小时)',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(controller: _sleepQuality, label: '睡眠质量'),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(
            controller: _stepsGoal,
            label: '步数目标',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(
            controller: _stepsToday,
            label: '今日步数',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(controller: _exerciseFreq, label: '运动频率'),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(controller: _exerciseType, label: '运动类型'),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(controller: _caffeine, label: '咖啡因'),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(controller: _alcohol, label: '酒精'),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(controller: _smoking, label: '吸烟'),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(
            controller: _foodPrefs,
            label: '食物偏好（顿号分隔）',
          ),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(
            controller: _foodAvoid,
            label: '避免食物（顿号分隔）',
          ),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(controller: _nutrition, label: '营养备注 / 目标'),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(controller: _mood, label: '今日心情'),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(
            controller: _weightToday,
            label: '今日体重 (kg)',
            keyboardType: TextInputType.number,
          ),
          SwitchListTile(
            key: const Key('lifestyle_vitamin'),
            contentPadding: EdgeInsets.zero,
            title: const Text('今日已服孕维/叶酸'),
            value: _vitaminTaken,
            onChanged: (v) => setState(() => _vitaminTaken = v),
          ),
        ],
      ),
    );
  }
}

String lifestyleSummary(UserProfileSnapshot snap) {
  final r = snap.rich;
  final bits = <String>[
    if (r.dietPreference != DietPreference.unset) r.dietPreference.label,
    if (r.dailyWaterGoalMl != null) '饮水目标${r.dailyWaterGoalMl!.round()}ml',
    if (r.typicalSleepHours != null) '睡眠${r.typicalSleepHours}h',
    if (r.exerciseFrequency case final f? when f.isNotEmpty) f,
    if (r.caffeine case final c? when c.isNotEmpty) '咖啡因已填',
  ];
  return bits.isEmpty ? '点击完善生活方式' : bits.join(' · ');
}
