import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/rich_user_profile.dart';
import '../../../domain/user_profile_snapshot.dart';
import '../../../providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/glass_tokens.dart';
import '../../../theme/radius_tokens.dart';
import '../../../theme/spacing_tokens.dart';
import '../../../widgets/glass/glass_container.dart';

const _symptomKeys = <(String, String)>[
  ('nausea', '恶心'),
  ('fatigue', '疲劳'),
  ('headache', '头痛'),
  ('backPain', '背痛'),
  ('heartburn', '烧心'),
  ('swelling', '水肿'),
  ('dizziness', '头晕'),
];

Future<void> showSymptomLogSheet(
  BuildContext context,
  WidgetRef ref,
  UserProfileSnapshot snapshot,
) async {
  final selected = <String>{};
  final latest = snapshot.rich.latestSymptoms;
  if (latest.nausea != null) selected.add('nausea');
  if (latest.fatigue != null) selected.add('fatigue');
  if (latest.headache != null) selected.add('headache');
  if (latest.backPain != null) selected.add('backPain');
  if (latest.heartburn != null) selected.add('heartburn');
  if (latest.swelling != null) selected.add('swelling');
  if (latest.dizziness != null) selected.add('dizziness');

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setModal) {
          return GlassContainer(
            fill: GlassFill.heavy,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(RadiusTokens.sheet),
            ),
            padding: const EdgeInsets.all(SpacingTokens.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('快速记录不适', style: Theme.of(ctx).textTheme.titleMedium),
                const SizedBox(height: SpacingTokens.xs),
                Text(
                  '仅作生活记录。若症状严重或持续，请寻求专业医疗帮助。',
                  style: Theme.of(ctx).textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: SpacingTokens.md),
                Wrap(
                  spacing: SpacingTokens.sm,
                  runSpacing: SpacingTokens.sm,
                  children: [
                    for (final (key, label) in _symptomKeys)
                      FilterChip(
                        key: Key('symptom_$key'),
                        label: Text(label),
                        selected: selected.contains(key),
                        onSelected: (on) {
                          setModal(() {
                            if (on) {
                              selected.add(key);
                            } else {
                              selected.remove(key);
                            }
                          });
                        },
                      ),
                  ],
                ),
                const SizedBox(height: SpacingTokens.lg),
                FilledButton(
                  key: const Key('symptom_save'),
                  onPressed: () async {
                    final now = DateTime.now();
                    const mild = '轻度';
                    final log = SymptomLog(
                      nausea: selected.contains('nausea') ? mild : null,
                      fatigue: selected.contains('fatigue') ? mild : null,
                      headache: selected.contains('headache') ? mild : null,
                      backPain: selected.contains('backPain') ? mild : null,
                      heartburn: selected.contains('heartburn') ? mild : null,
                      swelling: selected.contains('swelling') ? mild : null,
                      dizziness: selected.contains('dizziness') ? mild : null,
                      loggedAt: now,
                    );
                    await ref
                        .read(homeCheckInControllerProvider)
                        .saveSymptomLog(log);
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  },
                  child: const Text('保存'),
                ),
                SizedBox(height: MediaQuery.paddingOf(ctx).bottom),
              ],
            ),
          );
        },
      );
    },
  );
}
