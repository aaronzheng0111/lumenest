import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_copy.dart';
import '../../data/user_profile_repository.dart';
import '../../domain/user_profile_snapshot.dart';
import '../../providers.dart';
import '../../theme/spacing_tokens.dart';
import 'profile_ui_shared.dart';

/// Manual editor: basic personal fields.
class PersonalSectionPage extends ConsumerStatefulWidget {
  const PersonalSectionPage({super.key});

  @override
  ConsumerState<PersonalSectionPage> createState() =>
      _PersonalSectionPageState();
}

class _PersonalSectionPageState extends ConsumerState<PersonalSectionPage> {
  final _fullName = TextEditingController();
  final _nickname = TextEditingController();
  final _gender = TextEditingController();
  final _location = TextEditingController();
  final _occupation = TextEditingController();
  final _relationship = TextEditingController();
  final _emergency = TextEditingController();
  DateTime? _dob;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _fullName.dispose();
    _nickname.dispose();
    _gender.dispose();
    _location.dispose();
    _occupation.dispose();
    _relationship.dispose();
    _emergency.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final snap = await ref.read(userProfileSnapshotProvider.future);
    final rich = snap.rich;
    if (!mounted) return;
    setState(() {
      _fullName.text = rich.fullName ?? '';
      _nickname.text = snap.nickname;
      _gender.text = rich.gender ?? '';
      _location.text = rich.location ?? '';
      _occupation.text = rich.occupation ?? '';
      _relationship.text = rich.relationshipStatus ?? '';
      _emergency.text = rich.emergencyContact ?? '';
      _dob = rich.dateOfBirth;
      _loading = false;
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    await runProfileSectionSave(
      context: context,
      setSaving: (v) => setState(() => _saving = v),
      save: () async {
        final nick = _nickname.text.trim();
        final repo = ref.read(userProfileRepositoryProvider);
        await repo.saveEdits(ProfileEdits(nickname: nick));
        await commitRichProfile(ref, (current) {
          return current.copyWith(
            fullName: emptyToNull(_fullName.text),
            dateOfBirth: _dob,
            gender: emptyToNull(_gender.text),
            location: emptyToNull(_location.text),
            occupation: emptyToNull(_occupation.text),
            relationshipStatus: emptyToNull(_relationship.text),
            emergencyContact: emptyToNull(_emergency.text),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const ProfileSectionLoading(title: '个人资料');
    }
    return ProfileSectionScaffold(
      title: '个人资料',
      saving: _saving,
      onSave: _save,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          profileTextField(
            fieldKey: const Key('personal_full_name'),
            controller: _fullName,
            label: '姓名',
          ),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(
            fieldKey: const Key('personal_nickname'),
            controller: _nickname,
            label: AppCopy.nicknameLabel,
            maxLength: 20,
          ),
          const SizedBox(height: SpacingTokens.md),
          ProfileDateTile(
            key: const Key('personal_dob'),
            label: '生日',
            value: _dob,
            onPick: () async {
              final d = await pickProfileDate(context, current: _dob);
              if (d != null) setState(() => _dob = d);
            },
            onClear: () => setState(() => _dob = null),
          ),
          profileTextField(
            fieldKey: const Key('personal_gender'),
            controller: _gender,
            label: '性别',
          ),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(
            fieldKey: const Key('personal_location'),
            controller: _location,
            label: '地区',
          ),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(
            fieldKey: const Key('personal_occupation'),
            controller: _occupation,
            label: '职业',
          ),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(
            fieldKey: const Key('personal_relationship'),
            controller: _relationship,
            label: '感情状况',
          ),
          const SizedBox(height: SpacingTokens.md),
          profileTextField(
            fieldKey: const Key('personal_emergency'),
            controller: _emergency,
            label: '紧急联系人',
          ),
        ],
      ),
    );
  }
}

String personalSummary(UserProfileSnapshot snap) {
  final r = snap.rich;
  final bits = <String>[
    if (r.dateOfBirth != null) '生日已填',
    if (r.gender case final g? when g.isNotEmpty) g,
    if (r.location case final loc? when loc.isNotEmpty) loc,
    if (r.occupation case final o? when o.isNotEmpty) o,
  ];
  return bits.isEmpty ? '点击完善个人资料' : bits.join(' · ');
}
