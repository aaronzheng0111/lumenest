import 'package:flutter/material.dart';

import '../../../domain/effective_journey.dart';
import '../../../domain/stage.dart';
import '../../../domain/user_profile_snapshot.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/glass_tokens.dart';
import '../../../theme/radius_tokens.dart';
import '../../../theme/spacing_tokens.dart';
import '../../../widgets/glass/glass_container.dart';
import '../journey_detail_page.dart';

/// Stage hero — copy from [EffectiveJourney] only (Stage SSOT).
class JourneyHeroCard extends StatelessWidget {
  const JourneyHeroCard({super.key, required this.snapshot});

  final UserProfileSnapshot snapshot;

  /// Expanded height used by the home collapsing header (card + spacing).
  static const double expandedExtent = 160;

  /// Pinned compact bar height.
  static const double collapsedExtent = 56;

  static void openDetail(BuildContext context, UserProfileSnapshot snapshot) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => JourneyDetailPage(snapshot: snapshot),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final content = JourneyHeroContent.fromSnapshot(snapshot);

    return Semantics(
      button: true,
      label: content.semanticsLabel,
      child: GestureDetector(
        onTap: () => openDetail(context, snapshot),
        child: GlassContainer(
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
                          content.chipLabel,
                          style: textTheme.labelMedium,
                        ),
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    Semantics(
                      identifier: 'home_week',
                      child: Text(
                        content.headline,
                        key: const Key('home_week'),
                        style: textTheme.displaySmall,
                      ),
                    ),
                    if (content.subtitle != null) ...[
                      const SizedBox(height: SpacingTokens.sm),
                      Text(
                        content.subtitle!,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: SpacingTokens.md),
              ExcludeSemantics(
                child: ClipRRect(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact pinned journey strip shown after the home header collapses.
class JourneyPinnedBar extends StatelessWidget {
  const JourneyPinnedBar({super.key, required this.snapshot});

  final UserProfileSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final content = JourneyHeroContent.fromSnapshot(snapshot);

    return Semantics(
      button: true,
      label: content.semanticsLabel,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: GestureDetector(
          key: const Key('journey_pinned_bar'),
          onTap: () => JourneyHeroCard.openDetail(context, snapshot),
          child: GlassContainer(
            fill: GlassFill.medium,
            borderRadius: RadiusTokens.borderLg,
            padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.md,
              vertical: SpacingTokens.sm,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.md,
                    vertical: SpacingTokens.xs,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.glassRoseSoft,
                    borderRadius: RadiusTokens.borderPill,
                  ),
                  child: Text(content.chipLabel, style: textTheme.labelSmall),
                ),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: Text(
                    content.headline,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall,
                  ),
                ),
                const ExcludeSemantics(
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shared journey labels for expanded card and pinned bar.
final class JourneyHeroContent {
  const JourneyHeroContent({
    required this.chipLabel,
    required this.headline,
    this.subtitle,
  });

  final String chipLabel;
  final String headline;
  final String? subtitle;

  /// Single spoken label for the interactive journey surfaces.
  String get semanticsLabel {
    final parts = <String>[chipLabel, headline, if (subtitle != null) subtitle!];
    return parts.join('，');
  }

  factory JourneyHeroContent.fromSnapshot(UserProfileSnapshot snapshot) {
    return JourneyHeroContent.from(EffectiveJourney.fromSnapshot(snapshot));
  }

  factory JourneyHeroContent.from(EffectiveJourney journey) {
    return switch (journey.stage) {
      Stage.prep => _prep(journey),
      Stage.pregnant => _pregnant(journey),
      Stage.delivery || Stage.postpartum => _postpartum(journey),
    };
  }

  static JourneyHeroContent _prep(EffectiveJourney journey) {
    if (journey.primaryLabel == '未怀孕') {
      return const JourneyHeroContent(
        chipLabel: '未怀孕',
        headline: '日常照护',
        subtitle: '需要时可以在档案里更新状态',
      );
    }
    if (journey.cycleDay != null) {
      return JourneyHeroContent(
        chipLabel: journey.statusLabel,
        headline: journey.weekLabel,
        subtitle: journey.inFertileWindow
            ? '可能处于易孕窗口（估算，非诊断）'
            : null,
      );
    }
    return JourneyHeroContent(
      chipLabel: journey.statusLabel,
      headline: journey.primaryLabel,
      subtitle: '填写末次月经后可显示周期日',
    );
  }

  static JourneyHeroContent _pregnant(EffectiveJourney journey) {
    final due = journey.dueDate;
    final parts = <String>[
      if (journey.trimester != null) '第${journey.trimester}孕期',
      if (due != null)
        '预产期 ${due.year}-${due.month.toString().padLeft(2, '0')}-'
            '${due.day.toString().padLeft(2, '0')}',
    ];
    return JourneyHeroContent(
      chipLabel: journey.statusLabel,
      headline: journey.primaryLabel,
      subtitle: parts.isEmpty ? null : parts.join(' · '),
    );
  }

  static JourneyHeroContent _postpartum(EffectiveJourney journey) {
    return JourneyHeroContent(
      chipLabel: journey.statusLabel,
      headline: journey.primaryLabel,
      subtitle: '照顾自己与宝宝，不适请寻求专业帮助',
    );
  }
}
