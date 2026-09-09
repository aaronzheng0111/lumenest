import 'package:flutter/material.dart';

import '../../domain/agent_role.dart';
import '../../theme/app_colors.dart';
import '../../theme/glass_tokens.dart';
import '../../theme/radius_tokens.dart';
import '../../theme/spacing_tokens.dart';
import '../../widgets/glass/glass_container.dart';

/// Compact horizontal role entry (secondary to Chat tab).
class RoleEntryGrid extends StatelessWidget {
  const RoleEntryGrid({super.key, required this.onSelect});

  final ValueChanged<AgentRole> onSelect;

  static const order = [
    AgentRole.xiaonuan,
    AgentRole.lin,
    AgentRole.suxin,
    AgentRole.ama,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('和谁聊聊', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: SpacingTokens.sm),
        SizedBox(
          height: 88,
          child: ListView.separated(
            key: const Key('role_grid'),
            scrollDirection: Axis.horizontal,
            itemCount: order.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: SpacingTokens.sm),
            itemBuilder: (context, index) {
              final role = order[index];
              return _CompactRoleChip(
                role: role,
                onTap: () => onSelect(role),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CompactRoleChip extends StatelessWidget {
  const _CompactRoleChip({required this.role, required this.onTap});

  final AgentRole role;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unlocked = role.isUnlocked;
    return Semantics(
      button: true,
      label: role.displayName,
      child: GestureDetector(
        onTap: onTap,
        child: GlassContainer(
          width: 72,
          fill: unlocked ? GlassFill.rose : GlassFill.locked,
          borderRadius: RadiusTokens.borderLg,
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.sm,
            vertical: SpacingTokens.sm,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  ClipOval(
                    child: Image.asset(
                      role.avatarAsset,
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.secondary,
                        child: Text(role.displayName.substring(0, 1)),
                      ),
                    ),
                  ),
                  if (!unlocked)
                    const Icon(
                      Icons.lock_rounded,
                      size: 12,
                      color: AppColors.locked,
                    ),
                ],
              ),
              const SizedBox(height: SpacingTokens.xs),
              Text(
                role.displayName,
                key: Key('role_${role.wireId}'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: unlocked
                          ? AppColors.onSurface
                          : AppColors.locked,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
