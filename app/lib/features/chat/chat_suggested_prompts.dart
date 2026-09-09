import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/glass_tokens.dart';
import '../../theme/radius_tokens.dart';
import '../../theme/spacing_tokens.dart';
import '../../widgets/glass/glass_container.dart';

/// Horizontal suggestion chips above the composer.
///
/// Prompt strings come from [ChatSuggestionsCatalog] (fixture JSON), not
/// hardcoded in page widgets.
class ChatSuggestedPrompts extends StatelessWidget {
  const ChatSuggestedPrompts({
    super.key,
    required this.prompts,
    required this.onSelected,
  });

  final List<String> prompts;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    if (prompts.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          key: const Key('chat_suggested_prompts'),
          scrollDirection: Axis.horizontal,
          itemCount: prompts.length,
          separatorBuilder: (_, __) => const SizedBox(width: SpacingTokens.sm),
          itemBuilder: (context, index) {
            final prompt = prompts[index];
            return GlassContainer(
              fill: GlassFill.light,
              borderRadius: RadiusTokens.borderPill,
              padding: EdgeInsets.zero,
              boxShadow: const [],
              child: InkWell(
                key: Key('chat_suggestion_$index'),
                borderRadius: RadiusTokens.borderPill,
                onTap: () => onSelected(prompt),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.md,
                    vertical: SpacingTokens.sm,
                  ),
                  child: Center(
                    child: Text(
                      prompt,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurface,
                          ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
