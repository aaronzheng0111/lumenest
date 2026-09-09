import 'package:flutter/material.dart';

import '../../agent/tool_acl.dart';
import '../../agent/tool_labels.dart';
import '../../app_copy.dart';
import '../../theme/app_colors.dart';
import '../../theme/glass_tokens.dart';
import '../../theme/radius_tokens.dart';
import '../../theme/spacing_tokens.dart';
import '../../widgets/glass/glass_container.dart';
import 'chat_typing_indicator.dart';

/// Awaiting-reply row: optional tool-calling chips + typing dots.
class ChatAwaitingReply extends StatelessWidget {
  const ChatAwaitingReply({
    super.key,
    this.tools = const [],
  });

  final List<AgentTool> tools;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tools.isNotEmpty) ...[
            for (final tool in tools)
              Padding(
                padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
                child: _ToolCallingChip(tool: tool),
              ),
          ],
          const ChatTypingIndicator(compact: true),
        ],
      ),
    );
  }
}

class _ToolCallingChip extends StatelessWidget {
  const _ToolCallingChip({required this.tool});

  final AgentTool tool;

  @override
  Widget build(BuildContext context) {
    final label = AppCopy.callingTool(AgentToolLabels.displayName(tool));
    return GlassContainer(
      fill: GlassFill.light,
      borderRadius: RadiusTokens.borderPill,
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.xs + 2,
      ),
      boxShadow: const [],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        key: Key('chat_tool_${tool.name}'),
        children: [
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: AppColors.primaryDeep,
            ),
          ),
          const SizedBox(width: SpacingTokens.sm),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
