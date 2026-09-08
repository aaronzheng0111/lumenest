import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_copy.dart';
import '../../domain/agent_role.dart';
import '../../providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/glass_tokens.dart';
import '../../theme/radius_tokens.dart';
import '../../theme/spacing_tokens.dart';
import '../../widgets/atmosphere_background.dart';
import '../../widgets/glass/glass_app_bar.dart';
import '../../widgets/glass/glass_container.dart';

class ChatSessionPage extends ConsumerWidget {
  const ChatSessionPage({super.key, required this.role});

  final AgentRole role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locked = !role.unlockedInP1;
    final privacy = ref.watch(privacyAcceptedProvider).maybeWhen(
          data: (v) => v,
          orElse: () => false,
        );

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: GlassAppBar.forContext(
        context,
        title: Text(role.displayName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: AtmosphereBackground(
        child: Column(
          children: [
            if (locked)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  SpacingTokens.pageMargin,
                  GlassAppBar.contentHeight +
                      MediaQuery.paddingOf(context).top +
                      SpacingTokens.lg,
                  SpacingTokens.pageMargin,
                  0,
                ),
                child: GlassContainer(
                  fill: GlassFill.roseSoft,
                  padding: const EdgeInsets.all(SpacingTokens.md),
                  child: Text(
                    AppCopy.roleLockedBanner,
                    key: const Key('locked_banner'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              )
            else
              SizedBox(
                height: GlassAppBar.contentHeight +
                    MediaQuery.paddingOf(context).top +
                    SpacingTokens.lg,
              ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.fromLTRB(
                SpacingTokens.pageMargin,
                0,
                SpacingTokens.pageMargin,
                SpacingTokens.lg + MediaQuery.paddingOf(context).bottom,
              ),
              child: GlassContainer(
                fill: GlassFill.medium,
                borderRadius: RadiusTokens.borderPill,
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.lg,
                  vertical: SpacingTokens.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        locked ? '该角色暂未开放' : '和${role.displayName}说点什么…',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                      ),
                    ),
                    IconButton(
                      key: const Key('chat_send'),
                      onPressed: locked
                          ? null
                          : () {
                              if (!privacy) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(AppCopy.privacyRequiredToChat),
                                  ),
                                );
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text(AppCopy.comingSoon)),
                              );
                            },
                      icon: const Icon(Icons.send_rounded),
                      color: AppColors.primaryDeep,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
