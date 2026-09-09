import 'package:flutter/material.dart';

import '../../domain/agent_role.dart';
import '../../theme/app_colors.dart';
import '../../theme/glass_tokens.dart';
import '../../theme/radius_tokens.dart';
import '../../theme/spacing_tokens.dart';
import '../../widgets/glass/glass_container.dart';

/// Floating list of [AgentRole] mentions filtered by typed prefix.
class ChatMentionPicker extends StatelessWidget {
  const ChatMentionPicker({
    super.key,
    required this.roles,
    required this.onSelected,
  });

  final List<AgentRole> roles;
  final ValueChanged<AgentRole> onSelected;

  @override
  Widget build(BuildContext context) {
    if (roles.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
      child: GlassContainer(
        fill: GlassFill.heavy,
        borderRadius: RadiusTokens.borderMd,
        padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: ListView.builder(
            key: const Key('chat_mention_picker'),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: roles.length,
            itemBuilder: (context, index) {
              final role = roles[index];
              return InkWell(
                key: Key('chat_mention_${role.wireId}'),
                onTap: () => onSelected(role),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.lg,
                    vertical: SpacingTokens.sm,
                  ),
                  child: Row(
                    children: [
                      ClipOval(
                        child: Image.asset(
                          role.avatarAsset,
                          width: 28,
                          height: 28,
                          fit: BoxFit.cover,
                          errorBuilder: (context, _, __) => CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.secondary,
                            child: Text(
                              role.displayName.substring(0, 1),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: SpacingTokens.md),
                      Text(
                        '@${role.displayName}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurface,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
