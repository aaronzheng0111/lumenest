import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/rich_user_profile.dart';
import '../../domain/user_profile_snapshot.dart';
import '../../providers.dart';
import '../../theme/spacing_tokens.dart';
import 'profile_ui_shared.dart';

/// Sensitive medications & allergies detail + manual editor.
class MedicationsSectionPage extends ConsumerStatefulWidget {
  const MedicationsSectionPage({super.key});

  @override
  ConsumerState<MedicationsSectionPage> createState() =>
      _MedicationsSectionPageState();
}

class _MedicationsSectionPageState
    extends ConsumerState<MedicationsSectionPage> {
  FieldCertainty _allergyCertainty = FieldCertainty.unset;
  final _medAllergy = TextEditingController();
  final _foodAllergy = TextEditingController();
  final _envAllergy = TextEditingController();
  final _otherAllergy = TextEditingController();
  FieldCertainty _medCertainty = FieldCertainty.unset;
  final _meds = TextEditingController();
  final _prenatal = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _medAllergy.dispose();
    _foodAllergy.dispose();
    _envAllergy.dispose();
    _otherAllergy.dispose();
    _meds.dispose();
    _prenatal.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final rich = await ref.read(userProfileRepositoryProvider).loadRichProfile();
    if (!mounted) return;
    setState(() {
      _allergyCertainty = rich.allergies.certainty;
      _medAllergy.text = rich.allergies.medication.join('、');
      _foodAllergy.text = rich.allergies.food.join('、');
      _envAllergy.text = rich.allergies.environmental.join('、');
      _otherAllergy.text = rich.allergies.other.join('、');
      _medCertainty = rich.medicationsCertainty;
      _meds.text = rich.medications
          .where((m) => !m.isPrenatalVitamin)
          .map((m) => m.name)
          .join('、');
      _prenatal.text = rich.medications
          .where((m) => m.isPrenatalVitamin || m.isSupplement)
          .map((m) => m.name)
          .join('、');
      _loading = false;
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    await runProfileSectionSave(
      context: context,
      setSaving: (v) => setState(() => _saving = v),
      save: () => commitRichProfile(ref, (current) {
        final meds = <MedicationEntry>[
          for (final n in splitProfileTags(_meds.text)) MedicationEntry(name: n),
          for (final n in splitProfileTags(_prenatal.text))
            MedicationEntry(
              name: n,
              isPrenatalVitamin: true,
              isSupplement: true,
            ),
        ];
        var certainty = _medCertainty;
        if (certainty == FieldCertainty.unset && meds.isNotEmpty) {
          certainty = FieldCertainty.known;
        }
        var allergyCert = _allergyCertainty;
        final medication = splitProfileTags(_medAllergy.text);
        final food = splitProfileTags(_foodAllergy.text);
        final environmental = splitProfileTags(_envAllergy.text);
        final other = splitProfileTags(_otherAllergy.text);
        final listed =
            medication.length + food.length + environmental.length + other.length;
        if (allergyCert == FieldCertainty.unset && listed > 0) {
          allergyCert = FieldCertainty.known;
        }
        return current.copyWith(
          allergies: AllergyBag(
            certainty: allergyCert,
            medication: allergyCert == FieldCertainty.none
                ? const []
                : medication,
            food: allergyCert == FieldCertainty.none ? const [] : food,
            environmental: allergyCert == FieldCertainty.none
                ? const []
                : environmental,
            other: allergyCert == FieldCertainty.none ? const [] : other,
          ),
          medicationsCertainty: certainty,
          medications:
              certainty == FieldCertainty.none ? const <MedicationEntry>[] : meds,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const ProfileSectionLoading(title: '用药与过敏');
    }
    return ProfileSectionScaffold(
      title: '用药与过敏',
      saving: _saving,
      onSave: _save,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('过敏情况', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: SpacingTokens.sm),
          certaintyChips(
            value: _allergyCertainty,
            onChanged: (c) => setState(() => _allergyCertainty = c),
          ),
          if (_allergyCertainty == FieldCertainty.known ||
              _allergyCertainty == FieldCertainty.unset) ...[
            const SizedBox(height: SpacingTokens.md),
            profileTextField(
              fieldKey: const Key('allergy_med'),
              controller: _medAllergy,
              label: '药物过敏',
            ),
            const SizedBox(height: SpacingTokens.md),
            profileTextField(
              fieldKey: const Key('allergy_food'),
              controller: _foodAllergy,
              label: '食物过敏',
            ),
            const SizedBox(height: SpacingTokens.md),
            profileTextField(
              controller: _envAllergy,
              label: '环境过敏',
            ),
            const SizedBox(height: SpacingTokens.md),
            profileTextField(
              controller: _otherAllergy,
              label: '其他过敏',
            ),
          ],
          const SizedBox(height: SpacingTokens.xl),
          Text('用药 / 补充剂', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: SpacingTokens.sm),
          certaintyChips(
            value: _medCertainty,
            onChanged: (c) => setState(() => _medCertainty = c),
          ),
          if (_medCertainty == FieldCertainty.known ||
              _medCertainty == FieldCertainty.unset) ...[
            const SizedBox(height: SpacingTokens.md),
            profileTextField(
              fieldKey: const Key('meds_list'),
              controller: _meds,
              label: '当前用药（顿号分隔）',
              maxLines: 2,
            ),
            const SizedBox(height: SpacingTokens.md),
            profileTextField(
              fieldKey: const Key('meds_prenatal'),
              controller: _prenatal,
              label: '孕维 / 叶酸 / 补充剂',
              maxLines: 2,
            ),
          ],
        ],
      ),
    );
  }
}

String medicationsSummary(UserProfileSnapshot snap) {
  final r = snap.rich;
  return '${r.allergies.summaryLabel} · ${r.medicationsSummary}';
}
