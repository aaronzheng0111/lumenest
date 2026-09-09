import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/rich_user_profile.dart';
import '../../domain/user_profile_snapshot.dart';
import '../../providers.dart';
import '../../theme/spacing_tokens.dart';
import 'profile_ui_shared.dart';

/// Manual editor: agent-facing preferences.
class PreferencesSectionPage extends ConsumerStatefulWidget {
  const PreferencesSectionPage({super.key});

  @override
  ConsumerState<PreferencesSectionPage> createState() =>
      _PreferencesSectionPageState();
}

class _PreferencesSectionPageState
    extends ConsumerState<PreferencesSectionPage> {
  final _favFoods = TextEditingController();
  final _disliked = TextEditingController();
  final _activities = TextEditingController();
  final _exercisePref = TextEditingController();
  final _reminder = TextEditingController();
  final _notifFreq = TextEditingController();
  final _reminderTime = TextEditingController();
  final _language = TextEditingController();
  CommunicationStyle _comm = CommunicationStyle.unset;
  UnitSystem _units = UnitSystem.unset;
  HealthcarePreference _healthcare = HealthcarePreference.unset;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _favFoods.dispose();
    _disliked.dispose();
    _activities.dispose();
    _exercisePref.dispose();
    _reminder.dispose();
    _notifFreq.dispose();
    _reminderTime.dispose();
    _language.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final rich = await ref.read(userProfileRepositoryProvider).loadRichProfile();
    if (!mounted) return;
    setState(() {
      _favFoods.text = rich.favoriteFoods.join('、');
      _disliked.text = rich.dislikedFoods.join('、');
      _activities.text = rich.favoriteActivities.join('、');
      _exercisePref.text = rich.exercisePreference ?? '';
      _reminder.text = rich.reminderPreference ?? '';
      _notifFreq.text = rich.notificationFrequency ?? '';
      _reminderTime.text = rich.preferredReminderTime ?? '';
      _language.text = rich.language ?? '';
      _comm = rich.communicationStyle;
      _units = rich.units;
      _healthcare = rich.healthcarePreference;
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
          favoriteFoods: splitProfileTags(_favFoods.text),
          dislikedFoods: splitProfileTags(_disliked.text),
          favoriteActivities: splitProfileTags(_activities.text),
          exercisePreference: emptyToNull(_exercisePref.text),
          communicationStyle: _comm,
          reminderPreference: emptyToNull(_reminder.text),
          notificationFrequency: emptyToNull(_notifFreq.text),
          preferredReminderTime: emptyToNull(_reminderTime.text),
          language: emptyToNull(_language.text),
          units: _units,
          healthcarePreference: _healthcare,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const ProfileSectionLoading(title: '偏好设置');
    }
    return ProfileSectionScaffold(
      title: '偏好设置',
      saving: _saving,
      onSave: _save,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          profileTextField(
            fieldKey: const Key('prefs_fav_foods'),
            controller: _favFoods,
            label: '爱吃的食物',
          ),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(
            fieldKey: const Key('prefs_disliked'),
            controller: _disliked,
            label: '不喜欢的食物',
          ),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(controller: _activities, label: '喜欢的活动'),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(controller: _exercisePref, label: '运动偏好'),
          const SizedBox(height: SpacingTokens.md),
          Text('沟通风格', style: Theme.of(context).textTheme.titleSmall),
          profileChoiceChips(
            values: CommunicationStyle.values,
            selected: _comm,
            labelOf: (c) => c.label,
            onChanged: (c) => setState(() => _comm = c),
          ),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(controller: _reminder, label: '提醒偏好'),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(controller: _notifFreq, label: '通知频率'),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(controller: _reminderTime, label: '偏好提醒时间'),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(
            fieldKey: const Key('prefs_language'),
            controller: _language,
            label: '语言',
          ),
          const SizedBox(height: SpacingTokens.md),
          Text('单位制', style: Theme.of(context).textTheme.titleSmall),
          profileChoiceChips(
            values: UnitSystem.values,
            selected: _units,
            labelOf: (u) => u.label,
            onChanged: (u) => setState(() => _units = u),
          ),
          const SizedBox(height: SpacingTokens.md),
          Text('就医偏好', style: Theme.of(context).textTheme.titleSmall),
          profileChoiceChips(
            values: HealthcarePreference.values,
            selected: _healthcare,
            labelOf: (h) => h.label,
            onChanged: (h) => setState(() => _healthcare = h),
          ),
        ],
      ),
    );
  }
}

String preferencesSummary(UserProfileSnapshot snap) {
  final r = snap.rich;
  final bits = <String>[
    if (r.favoriteFoods.isNotEmpty) '饮食偏好已填',
    if (r.communicationStyle != CommunicationStyle.unset)
      r.communicationStyle.label,
    if (r.language case final lang? when lang.isNotEmpty) lang,
    if (r.units != UnitSystem.unset) r.units.label,
  ];
  return bits.isEmpty ? '点击完善偏好' : bits.join(' · ');
}
