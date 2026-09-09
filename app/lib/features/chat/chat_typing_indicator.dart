import 'package:flutter/material.dart';

import '../../app_copy.dart';
import '../../theme/app_colors.dart';
import '../../theme/spacing_tokens.dart';

/// Animated “正在回复…” row shown while the agent graph is running.
class ChatTypingIndicator extends StatefulWidget {
  const ChatTypingIndicator({
    super.key,
    this.compact = false,
  });

  /// When true, shows only the bouncing dots (e.g. under tool-status chips).
  final bool compact;

  @override
  State<ChatTypingIndicator> createState() => _ChatTypingIndicatorState();
}

class _ChatTypingIndicatorState extends State<ChatTypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dots = AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = (_controller.value + i * 0.22) % 1.0;
            final bounce = (1 - (phase - 0.5).abs() * 2).clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Transform.translate(
                offset: Offset(0, -4 * bounce),
                child: Opacity(
                  opacity: 0.35 + 0.65 * bounce,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryDeep,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );

    if (widget.compact) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
        child: Row(
          key: const Key('chat_loading'),
          children: [dots],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
      child: Row(
        key: const Key('chat_loading'),
        children: [
          Text(
            AppCopy.llmLoading,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
          const SizedBox(width: SpacingTokens.sm),
          dots,
        ],
      ),
    );
  }
}
