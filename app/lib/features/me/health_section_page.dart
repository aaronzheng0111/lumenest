import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/user_profile_snapshot.dart';
import '../../providers.dart';
import '../../theme/spacing_tokens.dart';
import 'profile_ui_shared.dart';

/// Sensitive health detail + manual editor.
class HealthSectionPage extends ConsumerStatefulWidget {
  const HealthSectionPage({super.key});

  @override
  ConsumerState<HealthSectionPage> createState() => _HealthSectionPageState();
}

class _HealthSectionPageState extends ConsumerState<HealthSectionPage> {
  final _bloodType = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();
  final _preWeight = TextEditingController();
  final _targetMin = TextEditingController();
  final _targetMax = TextEditingController();
  final _bp = TextEditingController();
  final _conditions = TextEditingController();
  final _surgeries = TextEditingController();
  final _chronic = TextEditingController();
  final _family = TextEditingController();
  final _mental = TextEditingController();
  final _vax = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _bloodType.dispose();
    _height.dispose();
    _weight.dispose();
    _preWeight.dispose();
    _targetMin.dispose();
    _targetMax.dispose();
    _bp.dispose();
    _conditions.dispose();
    _surgeries.dispose();
    _chronic.dispose();
    _family.dispose();
    _mental.dispose();
    _vax.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final rich = await ref.read(userProfileRepositoryProvider).loadRichProfile();
    if (!mounted) return;
    setState(() {
      _bloodType.text = rich.bloodType ?? '';
      _height.text = rich.heightCm?.toString() ?? '';
      _weight.text = rich.currentWeightKg?.toString() ?? '';
      _preWeight.text = rich.prePregnancyWeightKg?.toString() ?? '';
      _targetMin.text = rich.targetWeightMinKg?.toString() ?? '';
      _targetMax.text = rich.targetWeightMaxKg?.toString() ?? '';
      _bp.text = rich.bloodPressure ?? '';
      _conditions.text = rich.medicalConditions.join('、');
      _surgeries.text = rich.previousSurgeries.join('、');
      _chronic.text = rich.chronicConditions.join('、');
      _family.text = rich.familyMedicalHistory ?? '';
      _mental.text = rich.mentalWellbeing ?? '';
      _vax.text = rich.vaccinationStatus ?? '';
      _loading = false;
    });
  }


  Future<void> _save() async {
    if (_saving) return;
    await runProfileSectionSave(
      context: context,
      setSaving: (v) => setState(() => _saving = v),
      save: () => commitRichProfile(ref, (current) {
        return current.copyWith(
          bloodType: emptyToNull(_bloodType.text),
          heightCm: double.tryParse(_height.text.trim()),
          currentWeightKg: double.tryParse(_weight.text.trim()),
          prePregnancyWeightKg: double.tryParse(_preWeight.text.trim()),
          targetWeightMinKg: double.tryParse(_targetMin.text.trim()),
          targetWeightMaxKg: double.tryParse(_targetMax.text.trim()),
          bloodPressure: emptyToNull(_bp.text),
          medicalConditions: splitProfileTags(_conditions.text),
          previousSurgeries: splitProfileTags(_surgeries.text),
          chronicConditions: splitProfileTags(_chronic.text),
          familyMedicalHistory: emptyToNull(_family.text),
          mentalWellbeing: emptyToNull(_mental.text),
          vaccinationStatus: emptyToNull(_vax.text),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const ProfileSectionLoading(title: '健康档案');
    }
    final h = double.tryParse(_height.text.trim());
    final w = double.tryParse(_weight.text.trim());
    final bmiHint = (h == null || w == null || h <= 0)
        ? 'BMI：填写身高体重后自动计算'
        : 'BMI：${(w / ((h / 100) * (h / 100))).toStringAsFixed(1)}';
    return ProfileSectionScaffold(
      title: '健康档案',
      saving: _saving,
      onSave: _save,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '敏感健康信息仅保存在本机，首页只显示摘要。',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(
            fieldKey: const Key('health_blood_type'),
            controller: _bloodType,
            label: '血型',
          ),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(
            fieldKey: const Key('health_height'),
            controller: _height,
            label: '身高 (cm)',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(
            fieldKey: const Key('health_weight'),
            controller: _weight,
            label: '当前体重 (kg)',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: SpacingTokens.sm),
          Text(bmiHint),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(
            controller: _preWeight,
            label: '孕前体重 (kg)',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(
            controller: _targetMin,
            label: '建议体重下限 (kg)',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(
            controller: _targetMax,
            label: '建议体重上限 (kg)',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(
            fieldKey: const Key('health_bp'),
            controller: _bp,
            label: '血压',
          ),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(
            controller: _conditions,
            label: '疾病史（顿号分隔）',
            maxLines: 2,
          ),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(
            controller: _surgeries,
            label: '手术史（顿号分隔）',
            maxLines: 2,
          ),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(
            controller: _chronic,
            label: '慢性病（顿号分隔）',
            maxLines: 2,
          ),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(
            controller: _family,
            label: '家族病史',
            maxLines: 2,
          ),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(
            controller: _mental,
            label: '心理/情绪状态',
            maxLines: 2,
          ),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(controller: _vax, label: '疫苗接种情况'),
        ],
      ),
    );
  }
}

String healthSummary(UserProfileSnapshot snap) {
  final n = snap.rich.healthDetailCount;
  if (n == 0) return '未添加健康明细';
  return '$n 项健康明细已添加';
}
