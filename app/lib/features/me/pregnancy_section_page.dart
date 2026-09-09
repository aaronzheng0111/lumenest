import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/user_profile_repository.dart';
import '../../domain/effective_journey.dart';
import '../../domain/identity_dates.dart';
import '../../domain/identity_reconcile.dart';
import '../../domain/profile_consistency.dart';
import '../../domain/rich_user_profile.dart';
import '../../domain/stage.dart';
import '../../domain/user_profile_snapshot.dart';
import '../../providers.dart';
import '../../theme/spacing_tokens.dart';
import 'me_profile_form.dart';
import 'profile_ui_shared.dart';

/// Manual editor: pregnancy & fertility (+ link to stage dates form).
class PregnancySectionPage extends ConsumerStatefulWidget {
  const PregnancySectionPage({super.key});

  @override
  ConsumerState<PregnancySectionPage> createState() =>
      _PregnancySectionPageState();
}

class _PregnancySectionPageState extends ConsumerState<PregnancySectionPage> {
  PregnancyStatus _status = PregnancyStatus.unset;
  final _week = TextEditingController();
  final _prevPreg = TextEditingController();
  final _children = TextEditingController();
  final _hospital = TextEditingController();
  final _provider = TextEditingController();
  final _history = TextEditingController();
  final _complications = TextEditingController();
  final _fertility = TextEditingController();
  bool? _firstPregnancy;
  DateTime? _conception;
  Stage _stage = Stage.prep;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _week.dispose();
    _prevPreg.dispose();
    _children.dispose();
    _hospital.dispose();
    _provider.dispose();
    _history.dispose();
    _complications.dispose();
    _fertility.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final repo = ref.read(userProfileRepositoryProvider);
    final rich = await repo.loadRichProfile();
    final snap = await repo.getSnapshot();
    if (!mounted) return;
    setState(() {
      _status = rich.pregnancyStatus;
      _stage = snap.stage;
      _week.text = rich.pregnancyWeekOverride?.toString() ??
          (snap.stage == Stage.pregnant && snap.weekValue != null
              ? '${snap.weekValue}'
              : '');
      _prevPreg.text = rich.previousPregnancies?.toString() ?? '';
      _children.text = rich.numberOfChildren?.toString() ?? '';
      _hospital.text = rich.preferredMaternityHospital ?? '';
      _provider.text = rich.obGynProvider ?? '';
      _history.text = rich.previousPregnancyHistory ?? '';
      _complications.text = rich.previousMiscarriageOrComplications ?? '';
      _fertility.text = rich.fertilityTreatment ?? '';
      _firstPregnancy = rich.isFirstPregnancy;
      _conception = rich.estimatedConceptionDate;
      _loading = false;
    });
  }

  bool get _showWeekField =>
      _status == PregnancyStatus.pregnant || _stage == Stage.pregnant;

  Future<void> _save() async {
    if (_saving) return;
    await runProfileSectionSave(
      context: context,
      setSaving: (v) => setState(() => _saving = v),
      save: () async {
        final repo = ref.read(userProfileRepositoryProvider);
        final draft = await repo.loadDraft();
        final current = await repo.loadRichProfile();
        final today = DateTime.now();

        var draftRich = current.copyWith(
          previousPregnancies: int.tryParse(_prevPreg.text.trim()),
          numberOfChildren: int.tryParse(_children.text.trim()),
          preferredMaternityHospital: emptyToNull(_hospital.text),
          obGynProvider: emptyToNull(_provider.text),
          previousPregnancyHistory: emptyToNull(_history.text),
          previousMiscarriageOrComplications:
              emptyToNull(_complications.text),
          fertilityTreatment: emptyToNull(_fertility.text),
          isFirstPregnancy: _firstPregnancy,
          estimatedConceptionDate: _conception,
          pregnancyWeekOverride: _showWeekField
              ? int.tryParse(_week.text.trim())
              : null,
        );

        final dates = IdentityDates(
          lastMenstruationDate: draft.lastMenstruationDate,
          dueDate: draft.dueDate,
          birthDate: draft.birthDate,
        );
        final errors = ProfileConsistencyValidator.validate(
          draftRich,
          dates: dates,
          today: today,
        );
        if (errors.isNotEmpty) {
          throw ProfileValidationException(errors.first);
        }

        var reconciled = IdentityReconciler.reconcileOnStatusIntent(
          status: _status,
          rich: draftRich,
          dates: dates,
          today: today,
        );
        final weekInput = int.tryParse(_week.text.trim());
        if (reconciled.rich.pregnancyStatus == PregnancyStatus.pregnant &&
            weekInput != null &&
            reconciled.rich.pregnancyWeekOverride != null) {
          reconciled = IdentityReconciler.applyWeekOverrideWriteThrough(
            week: weekInput,
            rich: reconciled.rich,
            dates: reconciled.dates,
            today: today,
          );
        }
        draftRich =
            ProfileConsistencyValidator.normalizeCertaintyLists(reconciled.rich);

        await repo.saveEdits(
          ProfileEdits.fromIdentityDates(reconciled.dates),
          today: today,
        );
        // saveEdits already projects status from dates; overlay editor fields.
        await repo.saveRichProfile(draftRich);
        ref.invalidate(userProfileSnapshotProvider);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const ProfileSectionLoading(title: '孕期与生育');
    }
    return ProfileSectionScaffold(
      title: '孕期与生育',
      saving: _saving,
      onSave: _save,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('妊娠状态', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: SpacingTokens.sm),
          profileChoiceChips(
            values: PregnancyStatus.values,
            selected: _status,
            labelOf: (s) => s.label,
            onChanged: (s) => setState(() => _status = s),
          ),
          if (_showWeekField) ...[
            const SizedBox(height: SpacingTokens.md),
            profileTextField(
              fieldKey: const Key('preg_week'),
              controller: _week,
              label: '孕周（1–42，保存后写回日期）',
              keyboardType: TextInputType.number,
            ),
          ],
          const SizedBox(height: SpacingTokens.md),
          Text('是否首次怀孕', style: Theme.of(context).textTheme.titleSmall),
          Row(
            children: [
              ChoiceChip(
                label: const Text('是'),
                selected: _firstPregnancy == true,
                onSelected: (_) => setState(() => _firstPregnancy = true),
              ),
              const SizedBox(width: SpacingTokens.sm),
              ChoiceChip(
                label: const Text('否'),
                selected: _firstPregnancy == false,
                onSelected: (_) => setState(() => _firstPregnancy = false),
              ),
              const SizedBox(width: SpacingTokens.sm),
              ChoiceChip(
                label: const Text('不确定'),
                selected: _firstPregnancy == null,
                onSelected: (_) => setState(() => _firstPregnancy = null),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(
            controller: _prevPreg,
            label: '既往怀孕次数',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(
            controller: _children,
            label: '子女数',
            keyboardType: TextInputType.number,
          ),
          ProfileDateTile(
            label: '预估受孕日',
            value: _conception,
            onPick: () async {
              final d = await pickProfileDate(context, current: _conception);
              if (d != null) setState(() => _conception = d);
            },
            onClear: () => setState(() => _conception = null),
          ),
          profileTextField(controller: _fertility, label: '辅助生殖/治疗'),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(
            controller: _history,
            label: '既往孕产史',
            maxLines: 2,
          ),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(
            controller: _complications,
            label: '流产/并发症史',
            maxLines: 2,
          ),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(controller: _hospital, label: '偏好产院'),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(controller: _provider, label: '产科医生/医护'),
          const SizedBox(height: SpacingTokens.lg),
          OutlinedButton.icon(
            key: const Key('preg_stage_dates'),
            onPressed: () async {
              final saved = await Navigator.of(context).push<bool>(
                MaterialPageRoute<bool>(
                  builder: (_) => const MeProfileFormPage(),
                ),
              );
              if (saved == true) {
                ref.invalidate(userProfileSnapshotProvider);
                await _load();
              }
            },
            icon: const Icon(Icons.calendar_month_outlined),
            label: const Text('编辑末次月经 / 预产期 / 分娩日'),
          ),
        ],
      ),
    );
  }
}

String pregnancySummary(UserProfileSnapshot snap) {
  final journey = EffectiveJourney.fromSnapshot(snap);
  return journey.summaryWithHistory(snap.rich);
}
