import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/user_profile_snapshot.dart';
import '../../../providers.dart';
import '../../../theme/glass_tokens.dart';
import '../../../theme/radius_tokens.dart';
import '../../../theme/spacing_tokens.dart';
import '../../../widgets/glass/glass_container.dart';

Future<void> showSleepSheet(
  BuildContext context,
  WidgetRef ref,
  UserProfileSnapshot snapshot,
) async {
  final controller = TextEditingController(
    text: snapshot.rich.todayCheckIn.sleepHours?.toString() ?? '',
  );
  final result = await showModalBottomSheet<double>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
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
              Text('今日睡眠（小时）', style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: SpacingTokens.md),
              TextField(
                key: const Key('sleep_hours_field'),
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(hintText: '例如 7.5'),
              ),
              const SizedBox(height: SpacingTokens.lg),
              FilledButton(
                onPressed: () {
                  Navigator.of(ctx)
                      .pop(double.tryParse(controller.text.trim()));
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
  if (result != null && result >= 0 && result <= 24) {
    await ref.read(homeCheckInControllerProvider).setSleepHours(result);
  }
}

Future<void> showWeightSheet(
  BuildContext context,
  WidgetRef ref,
  UserProfileSnapshot snapshot,
) async {
  final controller = TextEditingController(
    text: snapshot.rich.todayCheckIn.weightKg?.toString() ??
        snapshot.rich.currentWeightKg?.toString() ??
        '',
  );
  final result = await showModalBottomSheet<double>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
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
              Text('今日体重（kg）', style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: SpacingTokens.md),
              TextField(
                key: const Key('weight_kg_field'),
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(hintText: '例如 58.5'),
              ),
              const SizedBox(height: SpacingTokens.lg),
              FilledButton(
                onPressed: () {
                  Navigator.of(ctx)
                      .pop(double.tryParse(controller.text.trim()));
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
  if (result != null && result > 0 && result < 300) {
    await ref.read(homeCheckInControllerProvider).setWeightKg(result);
  }
}
