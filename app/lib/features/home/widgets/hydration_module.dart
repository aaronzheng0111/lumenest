import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/user_profile_snapshot.dart';
import '../../../providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/glass_tokens.dart';
import '../../../theme/radius_tokens.dart';
import '../../../theme/spacing_tokens.dart';
import '../../../widgets/glass/glass_container.dart';

/// Progress vs water goal; +250 / +500 / custom → [DailyCheckIn.waterMl].
class HydrationModule extends ConsumerWidget {
  const HydrationModule({super.key, required this.snapshot});

  final UserProfileSnapshot snapshot;

  static const defaultGoalMl = 2000.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = snapshot.rich.dailyWaterGoalMl ?? defaultGoalMl;
    final current = snapshot.rich.todayCheckIn.waterMl ?? 0;
    final progress = goal <= 0 ? 0.0 : (current / goal).clamp(0.0, 1.0);

    return GlassContainer(
      key: const Key('hydration_module'),
      fill: GlassFill.light,
      borderRadius: RadiusTokens.borderLg,
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('今日饮水', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              Text(
                '${current.round()} / ${goal.round()} ml',
                key: const Key('hydration_progress_label'),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.md),
          ClipRRect(
            borderRadius: RadiusTokens.borderPill,
            child: LinearProgressIndicator(
              key: const Key('hydration_progress'),
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.glassRoseSoft,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  key: const Key('hydration_plus_250'),
                  onPressed: () =>
                      ref.read(homeCheckInControllerProvider).addWaterMl(250),
                  child: const Text('+250'),
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: OutlinedButton(
                  key: const Key('hydration_plus_500'),
                  onPressed: () =>
                      ref.read(homeCheckInControllerProvider).addWaterMl(500),
                  child: const Text('+500'),
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: FilledButton(
                  key: const Key('hydration_custom'),
                  onPressed: () => _custom(context, ref, current),
                  child: const Text('自定义'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _custom(
    BuildContext context,
    WidgetRef ref,
    double current,
  ) async {
    final controller = TextEditingController(
      text: current > 0 ? current.round().toString() : '',
    );
    final result = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(ctx).bottom,
          ),
          child: GlassContainer(
            fill: GlassFill.heavy,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(RadiusTokens.sheet),
            ),
            padding: const EdgeInsets.all(SpacingTokens.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('设置今日饮水量 (ml)',
                    style: Theme.of(ctx).textTheme.titleMedium),
                const SizedBox(height: SpacingTokens.md),
                TextField(
                  key: const Key('hydration_custom_field'),
                  controller: controller,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  decoration: const InputDecoration(hintText: '例如 1500'),
                ),
                const SizedBox(height: SpacingTokens.lg),
                FilledButton(
                  onPressed: () {
                    final v = double.tryParse(controller.text.trim());
                    Navigator.of(ctx).pop(v);
                  },
                  child: const Text('保存'),
                ),
              ],
            ),
          ),
        );
      },
    );
    controller.dispose();
    if (result != null && result >= 0) {
      await ref.read(homeCheckInControllerProvider).setWaterMl(result);
    }
  }
}
