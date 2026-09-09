import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/user_profile_snapshot.dart';
import '../../../providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/glass_tokens.dart';
import '../../../theme/radius_tokens.dart';
import '../../../theme/spacing_tokens.dart';
import '../../../widgets/glass/glass_container.dart';
import '../home_nudge.dart';

/// Compact one-liner + CTA (not chatbot bubbles).
class AgentNudgeCard extends ConsumerWidget {
  const AgentNudgeCard({
    super.key,
    required this.snapshot,
    this.onOpenProfile,
    this.onFocusMood,
  });

  final UserProfileSnapshot snapshot;
  final VoidCallback? onOpenProfile;
  final VoidCallback? onFocusMood;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nudge = resolveHomeNudge(snapshot);
    if (nudge == null) return const SizedBox.shrink();

    return GlassContainer(
      key: const Key('agent_nudge_card'),
      fill: GlassFill.roseSoft,
      borderRadius: RadiusTokens.borderLg,
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.tips_and_updates_outlined,
            color: AppColors.primaryDeep,
            size: 22,
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Text(
              nudge.message,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(width: SpacingTokens.sm),
          TextButton(
            key: Key('agent_nudge_cta_${nudge.kind.name}'),
            onPressed: () => _onCta(ref, nudge),
            child: Text(nudge.ctaLabel),
          ),
        ],
      ),
    );
  }

  Future<void> _onCta(WidgetRef ref, HomeNudge nudge) async {
    final controller = ref.read(homeCheckInControllerProvider);
    switch (nudge.kind) {
      case HomeNudgeKind.water:
        await controller.addWaterMl(250);
      case HomeNudgeKind.vitamin:
        await controller.setPrenatalVitaminTaken(true);
      case HomeNudgeKind.mood:
        onFocusMood?.call();
      case HomeNudgeKind.profile:
        onOpenProfile?.call();
    }
  }
}
