import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app_copy.dart';
import '../../data/conversation_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/glass_tokens.dart';
import '../../theme/radius_tokens.dart';
import '../../theme/spacing_tokens.dart';
import '../../widgets/glass/glass_container.dart';

/// ChatGPT-style bubble: long-press or action row for copy / delete.
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    this.animateReveal = false,
    this.onDeleted,
    this.onCopied,
  });

  final ChatMessage message;

  /// When true, assistant text types out once (new offline/remote replies).
  final bool animateReveal;

  final VoidCallback? onDeleted;
  final VoidCallback? onCopied;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: message.content));
    onCopied?.call();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppCopy.messageCopied),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppCopy.deleteMessage),
        content: const Text(AppCopy.deleteMessageConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppCopy.privacyClose),
          ),
          TextButton(
            key: Key('confirm_delete_message_${message.id}'),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(AppCopy.deleteMessage),
          ),
        ],
      ),
    );
    if (ok == true) onDeleted?.call();
  }

  Future<void> _showActions(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                key: Key('copy_message_${message.id}'),
                leading: const Icon(Icons.copy_rounded),
                title: const Text(AppCopy.copyMessage),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _copy(context);
                },
              ),
              ListTile(
                key: Key('delete_message_${message.id}'),
                leading: const Icon(Icons.delete_outline_rounded),
                title: const Text(AppCopy.deleteMessage),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDelete(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

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
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  key: Key('chat_bubble_${message.id}'),
                  borderRadius: radius,
                  onLongPress: () => _showActions(context),
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
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                key: Key('bubble_copy_${message.id}'),
                tooltip: AppCopy.copyMessage,
                visualDensity: VisualDensity.compact,
                iconSize: 18,
                color: AppColors.onSurfaceVariant,
                onPressed: () => _copy(context),
                icon: const Icon(Icons.copy_rounded),
              ),
              IconButton(
                key: Key('bubble_delete_${message.id}'),
                tooltip: AppCopy.deleteMessage,
                visualDensity: VisualDensity.compact,
                iconSize: 18,
                color: AppColors.onSurfaceVariant,
                onPressed: () => _confirmDelete(context),
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          if (message.sourceTitles.isNotEmpty) ...[
            const SizedBox(height: 2),
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
