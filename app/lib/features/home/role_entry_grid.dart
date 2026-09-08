import 'package:flutter/material.dart';

import '../../domain/agent_role.dart';
import '../../theme/app_colors.dart';
import '../../theme/glass_tokens.dart';
import '../../theme/spacing_tokens.dart';
import '../../widgets/glass/glass_container.dart';

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
    return GridView.count(
      key: const Key('role_grid'),
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: SpacingTokens.md,
      crossAxisSpacing: SpacingTokens.md,
      childAspectRatio: 1.15,
      children: [
        for (final role in order)
          _RoleCard(
            role: role,
            onTap: () => onSelect(role),
          ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({required this.role, required this.onTap});

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
          fill: unlocked ? GlassFill.rose : GlassFill.locked,
          padding: const EdgeInsets.all(SpacingTokens.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  ClipOval(
                    child: Image.asset(
                      role.avatarAsset,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.secondary,
                        child: Text(role.displayName.substring(0, 1)),
                      ),
                    ),
                  ),
                  if (!unlocked)
                    const Icon(
                      Icons.lock_rounded,
                      size: 16,
                      color: AppColors.locked,
                    ),
                ],
              ),
              const SizedBox(height: SpacingTokens.sm),
              Text(
                role.displayName,
                key: Key('role_${role.wireId}'),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
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
