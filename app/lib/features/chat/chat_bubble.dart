import 'package:flutter/material.dart';

import '../../app_copy.dart';
import '../../data/conversation_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/glass_tokens.dart';
import '../../theme/radius_tokens.dart';
import '../../theme/spacing_tokens.dart';
import '../../widgets/glass/glass_container.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    this.animateReveal = false,
  });

  final ChatMessage message;

  /// When true, assistant text types out once (new offline/remote replies).
  final bool animateReveal;

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
                    decoration: const BoxDecoration(
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
                child: animateReveal && !isUser
                    ? _TypewriterText(
                        key: ValueKey('type_${message.id}'),
                        text: message.content,
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    : Text(
                        message.content,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
              ),
            ),
          ),
          if (message.sourceTitles.isNotEmpty) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                key: const Key('source_row'),
                spacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '来源：',
                    key: const Key('source_label'),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  for (final title in message.sourceTitles.take(3))
                    Chip(
                      key: Key('source_chip_$title'),
                      label: Text(
                        title,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TypewriterText extends StatefulWidget {
  const _TypewriterText({
    super.key,
    required this.text,
    this.style,
  });

  final String text;
  final TextStyle? style;

  @override
  State<_TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final chars = widget.text.characters.length;
    final ms = (280 + chars * 18).clamp(280, 1600);
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: ms),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final chars = widget.text.characters;
        final count =
            (chars.length * _controller.value).ceil().clamp(0, chars.length);
        final visible = chars.take(count).toString();
        return Text(visible, style: widget.style);
      },
    );
  }
}
