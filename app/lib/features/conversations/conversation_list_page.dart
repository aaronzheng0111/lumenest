import 'package:flutter/material.dart';

import '../../app_copy.dart';
import '../../theme/app_colors.dart';
import '../../theme/spacing_tokens.dart';
import '../../widgets/atmosphere_background.dart';
import '../../widgets/glass/glass_tab_bar.dart';

class ConversationListPage extends StatelessWidget {
  const ConversationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AtmosphereBackground(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            SpacingTokens.pageMargin,
            SpacingTokens.xl,
            SpacingTokens.pageMargin,
            GlassTabBar.height + SpacingTokens.xl,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/illustrations/empty-chat.png',
                width: 160,
                height: 160,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.chat_bubble_outline,
                  size: 72,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: SpacingTokens.lg),
              Text(
                AppCopy.emptyConversations,
                key: const Key('empty_conversations'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
