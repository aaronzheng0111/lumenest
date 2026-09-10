import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../app_copy.dart';
import '../../chat/chat_media.dart';
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
    this.showActions = true,
    this.onDeleted,
    this.onCopied,
  });

  final ChatMessage message;

  /// When true, assistant text types out once (new offline/remote replies).
  final bool animateReveal;

  /// When false, hide copy/delete (e.g. in-flight stream draft).
  final bool showActions;

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
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
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
    final bodyStyle = Theme.of(context).textTheme.bodyMedium;

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
                  onLongPress: showActions ? () => _showActions(context) : null,
                  child: GlassContainer(
                    fill: fill,
                    borderRadius: radius,
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.md,
                      vertical: SpacingTokens.sm,
                    ),
                    child: isUser
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (message.media.isNotEmpty)
                                _MessageMediaRow(media: message.media),
                              if (message.content.isNotEmpty)
                                Text(message.content, style: bodyStyle),
                            ],
                          )
                        : animateReveal
                            ? _TypewriterText(
                                key: ValueKey('type_${message.id}'),
                                text: message.content,
                                style: bodyStyle,
                              )
                            : _AssistantMarkdown(
                                data: message.content,
                                style: bodyStyle,
                              ),
                  ),
                ),
              ),
            ),
          ),
          if (showActions) ...[
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
          ],
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

class _MessageMediaRow extends StatelessWidget {
  const _MessageMediaRow({required this.media});

  final List<ChatMediaItem> media;

  IconData _iconFor(ChatMediaKind kind) {
    return switch (kind) {
      ChatMediaKind.image => Icons.image_outlined,
      ChatMediaKind.audio => Icons.graphic_eq_rounded,
      ChatMediaKind.file => Icons.insert_drive_file_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
      child: Wrap(
        key: const Key('message_media_row'),
        spacing: 6,
        runSpacing: 4,
        children: [
          for (final item in media)
            Chip(
              key: Key('message_media_${item.id}'),
              avatar: Icon(_iconFor(item.kind), size: 16),
              label: Text(
                item.displayName,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
        ],
      ),
    );
  }
}

/// Themed markdown for assistant bubbles (user stays plain [Text]).
class _AssistantMarkdown extends StatelessWidget {
  const _AssistantMarkdown({required this.data, this.style});

  final String data;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final base = (style ?? Theme.of(context).textTheme.bodyMedium)?.copyWith(
          color: AppColors.onSurface,
          height: 1.45,
        ) ??
        const TextStyle(color: AppColors.onSurface, height: 1.45);
    final demotedHeading = base.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: base.fontSize,
    );
    return MarkdownBody(
      data: data,
      selectable: false,
      softLineBreak: true,
      styleSheet: MarkdownStyleSheet(
        p: base,
        strong: base.copyWith(fontWeight: FontWeight.w600),
        em: base.copyWith(fontStyle: FontStyle.italic),
        listBullet: base,
        listIndent: 20,
        h1: demotedHeading,
        h2: demotedHeading,
        h3: demotedHeading,
        h4: demotedHeading,
        h5: demotedHeading,
        h6: demotedHeading,
        blockSpacing: 6,
        listBulletPadding: const EdgeInsets.only(right: 6),
        a: base.copyWith(color: AppColors.primaryDeep),
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
        if (_controller.isCompleted) {
          return _AssistantMarkdown(data: widget.text, style: widget.style);
        }
        final chars = widget.text.characters;
        final count =
            (chars.length * _controller.value).ceil().clamp(0, chars.length);
        final visible = chars.take(count).toString();
        return Text(visible, style: widget.style);
      },
    );
  }
}
