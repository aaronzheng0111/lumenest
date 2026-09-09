import 'package:flutter/material.dart';

import '../../domain/rich_user_profile.dart';
import '../../domain/stage.dart';
import '../../domain/user_profile_snapshot.dart';
import '../../theme/app_colors.dart';
import '../../theme/glass_tokens.dart';
import '../../theme/radius_tokens.dart';
import '../../theme/spacing_tokens.dart';
import '../../widgets/atmosphere_background.dart';
import '../../widgets/glass/glass_app_bar.dart';
import '../../widgets/glass/glass_container.dart';

/// Optional journey detail (not a bottom-nav tab).
class JourneyDetailPage extends StatelessWidget {
  const JourneyDetailPage({super.key, required this.snapshot});

  final UserProfileSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final rows = _rows(snapshot);
    return AtmosphereBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: GlassAppBar.forContext(
          context,
          title: const Text('我的旅程'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    snapshot.weekLabel,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  Text(
                    '以下信息来自你本地档案；未填写的字段不会编造。',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: SpacingTokens.lg),
                  for (final row in rows) ...[
                    _DetailRow(label: row.$1, value: row.$2),
                    const Divider(height: SpacingTokens.xl),
                  ],
                  Text(
                    '本应用提供生活与情绪陪伴，不作诊断。如有异常不适，请及时就医。',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static List<(String, String)> _rows(UserProfileSnapshot snap) {
    final rich = snap.rich;
    final out = <(String, String)>[
      ('阶段', snap.stageLabel),
      if (rich.pregnancyStatus != PregnancyStatus.unset)
        ('妊娠状态', rich.pregnancyStatus.label),
    ];
    if (snap.lastMenstruationDate != null) {
      out.add(('末次月经', _fmt(snap.lastMenstruationDate!)));
    }
    final due = rich.dueDateOverride ?? snap.dueDate;
    if (due != null) out.add(('预产期', _fmt(due)));
    if (snap.birthDate != null) out.add(('分娩日期', _fmt(snap.birthDate!)));
    final week = rich.pregnancyWeekOverride ?? snap.weekValue;
    if (snap.stage == Stage.pregnant && week != null) {
      out.add(('孕周', '第$week周'));
      final tri = rich.trimesterFromWeek(week);
      if (tri != null) out.add(('孕期', '第$tri孕期'));
    }
    if (snap.stage == Stage.postpartum && snap.weekValue != null) {
      out.add(('产后周', '第${snap.weekValue}周'));
    }
    if (rich.numberOfChildren != null) {
      out.add(('子女数', '${rich.numberOfChildren}'));
    }
    return out;
  }

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 88,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}
