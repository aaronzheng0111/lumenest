import 'package:flutter/material.dart';

import '../../../domain/rich_user_profile.dart';
import '../../../domain/stage.dart';
import '../../../domain/user_profile_snapshot.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/glass_tokens.dart';
import '../../../theme/radius_tokens.dart';
import '../../../theme/spacing_tokens.dart';
import '../../../widgets/glass/glass_container.dart';
import '../journey_detail_page.dart';

/// Stage hero: TTC / pregnant / postpartum — mutually exclusive copy.
class JourneyHeroCard extends StatelessWidget {
  const JourneyHeroCard({super.key, required this.snapshot});

  final UserProfileSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final content = _JourneyContent.from(snapshot);

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

  factory _JourneyContent.from(UserProfileSnapshot snap) {
    final status = _effectiveStatus(snap);
    return switch (status) {
      PregnancyStatus.tryingToConceive => _ttc(snap),
      PregnancyStatus.pregnant => _pregnant(snap),
      PregnancyStatus.postpartum => _postpartum(snap),
      PregnancyStatus.notPregnant => const _JourneyContent(
          chipLabel: '未怀孕',
          headline: '日常照护',
          subtitle: '需要时可以在档案里更新状态',
        ),
      PregnancyStatus.unset => _fromStage(snap),
    };
  }

  static PregnancyStatus _effectiveStatus(UserProfileSnapshot snap) {
    final s = snap.rich.pregnancyStatus;
    if (s != PregnancyStatus.unset) return s;
    return switch (snap.stage) {
      Stage.pregnant => PregnancyStatus.pregnant,
      Stage.postpartum || Stage.delivery => PregnancyStatus.postpartum,
      Stage.prep => PregnancyStatus.tryingToConceive,
    };
  }

  static _JourneyContent _fromStage(UserProfileSnapshot snap) {
    return switch (snap.stage) {
      Stage.prep => _ttc(snap),
      Stage.pregnant => _pregnant(snap),
      Stage.delivery || Stage.postpartum => _postpartum(snap),
    };
  }

  static _JourneyContent _ttc(UserProfileSnapshot snap) {
    final lmp = snap.lastMenstruationDate;
    if (lmp == null) {
      return const _JourneyContent(
        chipLabel: '备孕',
        headline: '备孕中',
        subtitle: '填写末次月经后可显示周期日',
      );
    }
    final today = DateTime.now();
    final day = DateTime(today.year, today.month, today.day);
    final lmpDay = DateTime(lmp.year, lmp.month, lmp.day);
    final elapsed = day.difference(lmpDay).inDays;
    if (elapsed < 0) {
      return const _JourneyContent(
        chipLabel: '备孕',
        headline: '备孕中',
      );
    }
    final cycleDay = (elapsed % 28) + 1;
    final fertile = cycleDay >= 11 && cycleDay <= 16;
    return _JourneyContent(
      chipLabel: '备孕',
      headline: '周期第$cycleDay天',
      subtitle: fertile ? '可能处于易孕窗口（估算，非诊断）' : null,
    );
  }

  static _JourneyContent _pregnant(UserProfileSnapshot snap) {
    final week = snap.rich.pregnancyWeekOverride ?? snap.weekValue;
    final tri = snap.rich.trimesterFromWeek(week);
    final due = snap.rich.dueDateOverride ?? snap.dueDate;
    final headline = week != null && week >= 1 ? '孕$week周' : snap.weekLabel;
    final parts = <String>[
      if (tri != null) '第$tri孕期',
      if (due != null)
        '预产期 ${due.year}-${due.month.toString().padLeft(2, '0')}-'
            '${due.day.toString().padLeft(2, '0')}',
    ];
    return _JourneyContent(
      chipLabel: '孕期',
      headline: headline,
      subtitle: parts.isEmpty ? null : parts.join(' · '),
    );
  }

  static _JourneyContent _postpartum(UserProfileSnapshot snap) {
    final week = snap.weekValue;
    final headline = week != null && week >= 1
        ? '产后第$week周'
        : (snap.stage == Stage.delivery ? '待回填分娩日期' : snap.weekLabel);
    return _JourneyContent(
      chipLabel: snap.stage == Stage.delivery ? '生产' : '产后',
      headline: headline,
      subtitle: '照顾自己与宝宝，不适请寻求专业帮助',
    );
  }
}
