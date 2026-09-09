import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/rich_user_profile.dart';
import '../../../domain/stage.dart';
import '../../../domain/user_profile_snapshot.dart';
import '../../../providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/glass_tokens.dart';
import '../../../theme/radius_tokens.dart';
import '../../../theme/spacing_tokens.dart';
import '../../../widgets/glass/glass_container.dart';

/// Pending meds / prenatal vitamin for today.
class MedsPendingCard extends ConsumerWidget {
  const MedsPendingCard({super.key, required this.snapshot});

  final UserProfileSnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rich = snapshot.rich;
    final check = rich.todayCheckIn;
    final vitaminPending = check.prenatalVitaminTaken != true &&
        (rich.pregnancyStatus == PregnancyStatus.pregnant ||
            rich.pregnancyStatus == PregnancyStatus.tryingToConceive ||
            snapshot.stage == Stage.pregnant ||
            snapshot.stage == Stage.prep ||
            rich.medications.any((m) => m.isPrenatalVitamin));

    final pendingMeds = rich.medications
        .where((m) => !m.isPrenatalVitamin)
        .take(3)
        .toList();

    if (!vitaminPending && pendingMeds.isEmpty) {
      return const SizedBox.shrink();
    }

    return GlassContainer(
      key: const Key('meds_pending_card'),
      fill: GlassFill.light,
      borderRadius: RadiusTokens.borderLg,
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('今日用药提醒', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            '按医嘱服用；此处仅作本地打卡。',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
          if (vitaminPending) ...[
            const SizedBox(height: SpacingTokens.sm),
            SwitchListTile(
              key: const Key('home_vitamin_toggle'),
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text('叶酸 / 孕维'),
              value: check.prenatalVitaminTaken == true,
              onChanged: (v) => ref
                  .read(homeCheckInControllerProvider)
                  .setPrenatalVitaminTaken(v),
            ),
          ],
          for (final med in pendingMeds)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: const Icon(Icons.medication_outlined, size: 20),
              title: Text(med.name),
              subtitle: med.dosage == null ? null : Text(med.dosage!),
            ),
        ],
      ),
    );
  }
}
