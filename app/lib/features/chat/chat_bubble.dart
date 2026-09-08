import 'package:flutter/material.dart';

import '../../app_copy.dart';
import '../../data/conversation_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/glass_tokens.dart';
import '../../theme/radius_tokens.dart';
import '../../theme/spacing_tokens.dart';
import '../../widgets/glass/glass_container.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final align =
        isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final fill = isUser ? GlassFill.roseSoft : GlassFill.light;
    final radius = isUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(6),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(6),
            bottomRight: Radius.circular(20),
          );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
      child: Column(
        crossAxisAlignment: align,
        children: [
          if (!isUser) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.speakerDisplayName ?? '小暖',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                if (message.safetyBadge) ...[
                  const SizedBox(width: SpacingTokens.sm),
                  Container(
                    key: const Key('safety_badge'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.glassRoseSoft,
                      borderRadius: RadiusTokens.borderPill,
                    ),
                    child: Text(
                      AppCopy.safetyBadge,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
          ],
          Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.78,
              ),
              child: GlassContainer(
                fill: fill,
                borderRadius: radius,
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.md,
                  vertical: SpacingTokens.sm,
                ),
                child: Text(
                  message.content,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ),
          if (message.sourceTitles.isNotEmpty) ...[
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              children: [
                for (final title in message.sourceTitles)
                  Chip(
                    key: Key('source_chip_$title'),
                    label: Text(title, style: Theme.of(context).textTheme.labelSmall),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
