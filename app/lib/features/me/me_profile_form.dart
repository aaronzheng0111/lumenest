import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_copy.dart';
import '../../data/user_profile_repository.dart';
import '../../providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/glass_tokens.dart';
import '../../theme/radius_tokens.dart';
import '../../theme/spacing_tokens.dart';
import '../../widgets/atmosphere_background.dart';
import '../../widgets/glass/glass_app_bar.dart';
import '../../widgets/glass/glass_container.dart';

/// AC-03-F01 profile editor — nickname + three optional dates.
class MeProfileFormPage extends ConsumerStatefulWidget {
  const MeProfileFormPage({super.key});

  @override
  ConsumerState<MeProfileFormPage> createState() => _MeProfileFormPageState();
}

class _MeProfileFormPageState extends ConsumerState<MeProfileFormPage> {
  final _nicknameController = TextEditingController(text: '妈妈');
  DateTime? _lmp;
  DateTime? _due;
  DateTime? _birth;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final draft = await ref.read(userProfileRepositoryProvider).loadDraft();
      if (!mounted) return;
      setState(() {
        _nicknameController.text = draft.nickname;
        _lmp = draft.lastMenstruationDate;
        _due = draft.dueDate;
        _birth = draft.birthDate;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _pickDate({
    required DateTime? current,
    required ValueChanged<DateTime?> onPicked,
  }) async {
    final now = DateTime.now();
    final initial = current ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(initial.year, initial.month, initial.day),
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      onPicked(DateTime(picked.year, picked.month, picked.day));
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final repo = ref.read(userProfileRepositoryProvider);
      await repo.saveEdits(
        ProfileEdits(
          nickname: _nicknameController.text.trim(),
          lastMenstruationDate: _lmp,
          dueDate: _due,
          birthDate: _birth,
          clearLastMenstruationDate: _lmp == null,
          clearDueDate: _due == null,
          clearBirthDate: _birth == null,
        ),
      );
      ref.invalidate(userProfileSnapshotProvider);
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text(AppCopy.profileSaved)),
      );
      Navigator.of(context).pop(true);
    } on ProfileValidationException catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text(AppCopy.checkBirthDate)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AtmosphereBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: GlassAppBar.forContext(
          context,
          title: const Text(AppCopy.editProfile),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(SpacingTokens.pageMargin),
                children: [
                  GlassContainer(
                    fill: GlassFill.heavy,
                    borderRadius: RadiusTokens.borderXl,
                    padding: const EdgeInsets.all(SpacingTokens.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          key: const Key('profile_nickname'),
                          controller: _nicknameController,
                          maxLength: 20,
                          decoration: const InputDecoration(
                            labelText: AppCopy.nicknameLabel,
                            counterText: '',
                          ),
                        ),
                        const SizedBox(height: SpacingTokens.md),
                        _DateRow(
                          key: const Key('profile_lmp'),
                          label: AppCopy.lastMenstruationLabel,
                          value: _lmp,
                          onTap: () => _pickDate(
                            current: _lmp,
                            onPicked: (d) => setState(() => _lmp = d),
                          ),
                          onClear: () => setState(() => _lmp = null),
                        ),
                        _DateRow(
                          key: const Key('profile_due'),
                          label: AppCopy.dueDateLabel,
                          value: _due,
                          onTap: () => _pickDate(
                            current: _due,
                            onPicked: (d) => setState(() => _due = d),
                          ),
                          onClear: () => setState(() => _due = null),
                        ),
                        _DateRow(
                          key: const Key('profile_birth'),
                          label: AppCopy.birthDateLabel,
                          value: _birth,
                          onTap: () => _pickDate(
                            current: _birth,
                            onPicked: (d) => setState(() => _birth = d),
                          ),
                          onClear: () => setState(() => _birth = null),
                        ),
                        const SizedBox(height: SpacingTokens.lg),
                        FilledButton(
                          key: const Key('profile_save'),
                          onPressed: _saving ? null : _save,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryDeep,
                          ),
                          child: Text(_saving ? '…' : AppCopy.saveProfile),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    required this.onClear,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final text = value == null
        ? '未填写'
        : '${value!.year}-${value!.month.toString().padLeft(2, '0')}-${value!.day.toString().padLeft(2, '0')}';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(text),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            IconButton(
              tooltip: '清除',
              onPressed: onClear,
              icon: const Icon(Icons.clear_rounded),
            ),
          const Icon(Icons.calendar_today_outlined, size: 20),
        ],
      ),
      onTap: onTap,
    );
  }
}
