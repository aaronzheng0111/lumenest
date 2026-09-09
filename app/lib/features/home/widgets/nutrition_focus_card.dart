import 'package:flutter/material.dart';

import '../../../domain/rich_user_profile.dart';
import '../../../domain/user_profile_snapshot.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/glass_tokens.dart';
import '../../../theme/radius_tokens.dart';
import '../../../theme/spacing_tokens.dart';
import '../../../widgets/glass/glass_container.dart';

/// Lightweight nutrition focus with wellness disclaimer.
class NutritionFocusCard extends StatelessWidget {
  const NutritionFocusCard({super.key, required this.snapshot});

  final UserProfileSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final focus = _todayFocus(snapshot);
    return GlassContainer(
      key: const Key('nutrition_focus_card'),
      fill: GlassFill.roseSoft,
      borderRadius: RadiusTokens.borderLg,
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('今日饮食关注', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: SpacingTokens.sm),
          Text(focus, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: SpacingTokens.sm),
          Text(
            '一般营养提示，非个性化医疗建议。特殊饮食请咨询专业人士。',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  static String _todayFocus(UserProfileSnapshot snap) {
    final note = snap.rich.todayCheckIn.nutritionNote?.trim();
    if (note != null && note.isNotEmpty) return note;
    final goals = snap.rich.nutritionalGoals?.trim();
    if (goals != null && goals.isNotEmpty) return goals;
    return switch (snap.rich.pregnancyStatus) {
      PregnancyStatus.tryingToConceive =>
        '备孕阶段可关注均衡膳食与叶酸来源（蔬果、全谷），量力而行。',
      PregnancyStatus.pregnant =>
        '孕期可多选择富含铁与优质蛋白的食物，少食多餐，不适就休息。',
      PregnancyStatus.postpartum =>
        '产后恢复期注意补水与温和营养，听从医护与自身节奏。',
      _ => '保持规律进食与饮水，选择自己舒服的清淡搭配即可。',
    };
  }
}
