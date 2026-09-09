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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final journey = EffectiveJourney.fromSnapshot(snapshot);
    final content = _JourneyContent.from(journey);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => JourneyDetailPage(snapshot: snapshot),
          ),
        );
      },
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
      ),
    );
  }
}

final class _JourneyContent {
  const _JourneyContent({
    required this.chipLabel,
    required this.headline,
    this.subtitle,
  });

  final String chipLabel;
  final String headline;
  final String? subtitle;

  factory _JourneyContent.from(EffectiveJourney journey) {
    return switch (journey.stage) {
      Stage.prep => _prep(journey),
      Stage.pregnant => _pregnant(journey),
      Stage.delivery || Stage.postpartum => _postpartum(journey),
    };
  }

  static _JourneyContent _prep(EffectiveJourney journey) {
    if (journey.primaryLabel == '未怀孕') {
      return const _JourneyContent(
        chipLabel: '未怀孕',
        headline: '日常照护',
        subtitle: '需要时可以在档案里更新状态',
      );
    }
    if (journey.cycleDay != null) {
      return _JourneyContent(
        chipLabel: journey.statusLabel,
        headline: journey.weekLabel,
        subtitle: journey.inFertileWindow
            ? '可能处于易孕窗口（估算，非诊断）'
            : null,
      );
    }
    return _JourneyContent(
      chipLabel: journey.statusLabel,
      headline: journey.primaryLabel,
      subtitle: '填写末次月经后可显示周期日',
    );
  }

  static _JourneyContent _pregnant(EffectiveJourney journey) {
    final due = journey.dueDate;
    final parts = <String>[
      if (journey.trimester != null) '第${journey.trimester}孕期',
      if (due != null)
        '预产期 ${due.year}-${due.month.toString().padLeft(2, '0')}-'
            '${due.day.toString().padLeft(2, '0')}',
    ];
    return _JourneyContent(
      chipLabel: journey.statusLabel,
      headline: journey.primaryLabel,
      subtitle: parts.isEmpty ? null : parts.join(' · '),
    );
  }

  static _JourneyContent _postpartum(EffectiveJourney journey) {
    return _JourneyContent(
      chipLabel: journey.statusLabel,
      headline: journey.primaryLabel,
      subtitle: '照顾自己与宝宝，不适请寻求专业帮助',
    );
  }
}
