import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/user_profile_snapshot.dart';
import '../../../providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/glass_tokens.dart';
import '../../../theme/radius_tokens.dart';
import '../../../theme/spacing_tokens.dart';
import '../../../widgets/glass/glass_container.dart';
import 'sleep_weight_sheet.dart';
import 'symptom_log_sheet.dart';

const kMoodOptions = ['平静', '开心', '疲惫', '焦虑', '低落'];

/// Snapshot chips + mood picker writing [todayCheckIn].
class HealthSnapshotStrip extends ConsumerWidget {
  const HealthSnapshotStrip({
    super.key,
    required this.snapshot,
    this.moodFocusKey,
  });

  final UserProfileSnapshot snapshot;
  final GlobalKey? moodFocusKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final check = snapshot.rich.todayCheckIn;
    final selectedMood = check.mood;

    return GlassContainer(
      key: const Key('health_snapshot_strip'),
      fill: GlassFill.light,
      borderRadius: RadiusTokens.borderLg,
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('今日状态', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: SpacingTokens.sm),
          Wrap(
            spacing: SpacingTokens.sm,
            runSpacing: SpacingTokens.sm,
            children: [
              _SnapChip(
                label: check.waterMl == null
                    ? '饮水 —'
                    : '水 ${check.waterMl!.round()}ml',
              ),
              _SnapChip(
                key: const Key('snap_sleep'),
                label: check.sleepHours == null
                    ? '睡眠 —'
                    : '睡 ${check.sleepHours}h',
                onTap: () => showSleepSheet(context, ref, snapshot),
              ),
              _SnapChip(
                key: const Key('snap_weight'),
                label: check.weightKg == null
                    ? '体重 —'
                    : '体重 ${check.weightKg}kg',
                onTap: () => showWeightSheet(context, ref, snapshot),
              ),
              _SnapChip(
                key: const Key('snap_symptom'),
                label: '不适记录',
                onTap: () => showSymptomLogSheet(context, ref, snapshot),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.md),
          Text(
            key: moodFocusKey,
            '心情',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: SpacingTokens.sm),
          Wrap(
            spacing: SpacingTokens.sm,
            runSpacing: SpacingTokens.sm,
            children: [
              for (final mood in kMoodOptions)
                ChoiceChip(
                  key: Key('mood_chip_$mood'),
                  label: Text(mood),
                  selected: selectedMood == mood,
                  onSelected: (_) {
                    final next = selectedMood == mood ? null : mood;
                    ref.read(homeCheckInControllerProvider).setMood(next);
                  },
                ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          Text(
            '严重不适请及时就医，这里仅作生活记录。',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _SnapChip extends StatelessWidget {
  const _SnapChip({
    super.key,
    required this.label,
    this.onTap,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.glassRoseSoft,
      borderRadius: RadiusTokens.borderPill,
      child: InkWell(
        onTap: onTap,
        borderRadius: RadiusTokens.borderPill,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.md,
            vertical: SpacingTokens.sm,
          ),
          child: Text(label, style: Theme.of(context).textTheme.labelMedium),
        ),
      ),
    );
  }
}
