import 'package:flutter/material.dart';

import '../../app_copy.dart';
import '../../domain/user_profile_snapshot.dart';
import '../../theme/app_colors.dart';
import '../../theme/glass_tokens.dart';
import '../../theme/radius_tokens.dart';
import '../../theme/spacing_tokens.dart';
import '../../widgets/glass/glass_container.dart';

class HomeStageHeader extends StatelessWidget {
  const HomeStageHeader({super.key, required this.snapshot});

  final UserProfileSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GlassContainer(
      fill: GlassFill.medium,
      borderRadius: RadiusTokens.borderXl,
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  identifier: 'home_stage',
                  child: Container(
                    key: const Key('home_stage'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.md,
                      vertical: SpacingTokens.sm,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.glassRoseSoft,
                      borderRadius: RadiusTokens.borderPill,
                    ),
                    child: Text(
                      snapshot.stageLabel,
                      style: textTheme.labelMedium,
                    ),
                  ),
                ),
                const SizedBox(height: SpacingTokens.md),
                Semantics(
                  identifier: 'home_week',
                  child: Text(
                    snapshot.weekLabel,
                    key: const Key('home_week'),
                    style: textTheme.displaySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: SpacingTokens.md),
          ClipRRect(
            borderRadius: RadiusTokens.borderLg,
            child: Image.asset(
              'assets/illustrations/hero-pregnancy.png',
              width: 88,
              height: 88,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(
                width: 88,
                height: 88,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TodayTaskTeaser extends StatelessWidget {
  const TodayTaskTeaser({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      fill: GlassFill.roseSoft,
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('今日任务', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: SpacingTokens.sm),
          Text(
            AppCopy.todayTasksPlaceholder,
            key: const Key('today_tasks'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
