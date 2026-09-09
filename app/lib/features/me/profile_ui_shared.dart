import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_copy.dart';
import '../../data/user_profile_repository.dart';
import '../../domain/rich_user_profile.dart';
import '../../providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/glass_tokens.dart';
import '../../theme/radius_tokens.dart';
import '../../theme/spacing_tokens.dart';
import '../../widgets/atmosphere_background.dart';
import '../../widgets/glass/glass_app_bar.dart';
import '../../widgets/glass/glass_container.dart';

/// Shared glass scaffold for profile section editors (manual path).
class ProfileSectionScaffold extends ConsumerWidget {
  const ProfileSectionScaffold({
    super.key,
    required this.title,
    required this.child,
    this.onSave,
    this.saving = false,
  });

  final String title;
  final Widget child;
  final VoidCallback? onSave;
  final bool saving;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AtmosphereBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: GlassAppBar.forContext(
          context,
          title: Text(title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            if (onSave != null)
              TextButton(
                key: const Key('profile_section_save'),
                onPressed: saving ? null : onSave,
                child: Text(saving ? '…' : AppCopy.saveProfile),
              ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            SpacingTokens.pageMargin,
            SpacingTokens.md,
            SpacingTokens.pageMargin,
            SpacingTokens.xxl,
          ),
          children: [
            GlassContainer(
              fill: GlassFill.heavy,
              borderRadius: RadiusTokens.borderXl,
              padding: const EdgeInsets.all(SpacingTokens.lg),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

/// Loading shell reused by every profile section editor.
class ProfileSectionLoading extends StatelessWidget {
  const ProfileSectionLoading({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return ProfileSectionScaffold(
      title: title,
      child: const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

/// Splits comma /顿号 / newline tagged lists from profile text fields.
List<String> splitProfileTags(String raw) => raw
    .split(RegExp(r'[,，、\n]'))
    .map((s) => s.trim())
    .where((s) => s.isNotEmpty)
    .toList();

/// Trims [raw]; empty strings become null for nullable profile fields.
String? emptyToNull(String raw) {
  final trimmed = raw.trim();
  return trimmed.isEmpty ? null : trimmed;
}

/// Atomically merges [transform] into the rich profile and refreshes snapshot.
Future<void> commitRichProfile(
  WidgetRef ref,
  RichUserProfile Function(RichUserProfile current) transform,
) async {
  await ref.read(userProfileRepositoryProvider).updateRichProfile(transform);
  ref.invalidate(userProfileSnapshotProvider);
}

/// Runs a section save with snackbar + pop(true) on success.
Future<void> runProfileSectionSave({
  required BuildContext context,
  required Future<void> Function() save,
  required void Function(bool saving) setSaving,
}) async {
  setSaving(true);
  final messenger = ScaffoldMessenger.of(context);
  try {
    await save();
    if (!context.mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text(AppCopy.profileSaved)),
    );
    Navigator.of(context).pop(true);
  } on ProfileValidationException catch (e) {
    if (!context.mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
  } catch (e) {
    if (!context.mounted) return;
    messenger.showSnackBar(SnackBar(content: Text('$e')));
  } finally {
    if (context.mounted) setSaving(false);
  }
}

String dash(String? value) {
  if (value == null || value.trim().isEmpty) return '未填写';
  return value.trim();
}

String joinOrDash(List<String> items) {
  if (items.isEmpty) return '未填写';
  return items.join('、');
}

Widget profileTextField({
  required TextEditingController controller,
  required String label,
  Key? fieldKey,
  int maxLines = 1,
  int? maxLength,
  TextInputType? keyboardType,
}) {
  return TextField(
    key: fieldKey,
    controller: controller,
    maxLines: maxLines,
    maxLength: maxLength,
    keyboardType: keyboardType,
    decoration: InputDecoration(
      labelText: label,
      counterText: maxLength == null ? null : '',
    ),
  );
}

Widget certaintyChips({
  required FieldCertainty value,
  required ValueChanged<FieldCertainty> onChanged,
}) {
  return profileChoiceChips(
    values: FieldCertainty.values,
    selected: value,
    labelOf: (c) => c.label,
    onChanged: onChanged,
  );
}

/// Choice chips for any enum with a display label.
Widget profileChoiceChips<T>({
  required List<T> values,
  required T selected,
  required String Function(T) labelOf,
  required ValueChanged<T> onChanged,
}) {
  return Wrap(
    spacing: SpacingTokens.sm,
    runSpacing: SpacingTokens.sm,
    children: [
      for (final value in values)
        ChoiceChip(
          label: Text(labelOf(value)),
          selected: value == selected,
          onSelected: (_) => onChanged(value),
        ),
    ],
  );
}

Future<DateTime?> pickProfileDate(
  BuildContext context, {
  DateTime? current,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  final now = DateTime.now();
  final initial = current ?? now;
  return showDatePicker(
    context: context,
    initialDate: DateTime(initial.year, initial.month, initial.day),
    firstDate: firstDate ?? DateTime(1950),
    lastDate: lastDate ?? DateTime(now.year + 2),
  );
}

class ProfileDateTile extends StatelessWidget {
  const ProfileDateTile({
    super.key,
    required this.label,
    required this.value,
    required this.onPick,
    required this.onClear,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final text = value == null
        ? '未填写'
        : '${value!.year}-${value!.month.toString().padLeft(2, '0')}-'
            '${value!.day.toString().padLeft(2, '0')}';
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
      onTap: onPick,
    );
  }
}

class ProfileSectionCard extends StatelessWidget {
  const ProfileSectionCard({
    super.key,
    required this.tileKey,
    required this.icon,
    required this.title,
    required this.summary,
    required this.onTap,
    this.sensitive = false,
  });

  final Key tileKey;
  final IconData icon;
  final String title;
  final String summary;
  final VoidCallback onTap;
  final bool sensitive;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      fill: GlassFill.heavy,
      borderRadius: RadiusTokens.borderXl,
      margin: const EdgeInsets.only(bottom: SpacingTokens.md),
      child: ListTile(
        key: tileKey,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.lg,
          vertical: SpacingTokens.sm,
        ),
        leading: CircleAvatar(
          backgroundColor: AppColors.glassRoseSoft,
          child: Icon(icon, color: AppColors.primaryDeep, size: 20),
        ),
        title: Text(title),
        subtitle: Text(
          summary,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (sensitive)
              Padding(
                padding: const EdgeInsets.only(right: SpacingTokens.xs),
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 16,
                  color: AppColors.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
