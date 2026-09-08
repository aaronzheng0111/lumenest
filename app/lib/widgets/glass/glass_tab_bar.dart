import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/glass_tokens.dart';
import '../../theme/radius_tokens.dart';
import '../../theme/shadow_tokens.dart';
import '../../theme/spacing_tokens.dart';
import 'glass_container.dart';

class GlassTabItem {
  const GlassTabItem({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;
}

/// Floating pill tab bar — selected tab uses rose glass, not a thick underline.
class GlassTabBar extends StatelessWidget {
  const GlassTabBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onChanged,
  }) : assert(items.length >= 2);

  final List<GlassTabItem> items;
  final int currentIndex;
  final ValueChanged<int> onChanged;

  static const double height = 64;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        SpacingTokens.pageMargin,
        0,
        SpacingTokens.pageMargin,
        SpacingTokens.lg + bottom,
      ),
      child: GlassContainer(
        fill: GlassFill.medium,
        borderRadius: RadiusTokens.borderPill,
        blurSigma: GlassTokens.blurSigma,
        boxShadow: ShadowTokens.float,
        height: height,
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.sm,
          vertical: SpacingTokens.sm,
        ),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: _TabChip(
                  item: items[i],
                  selected: i == currentIndex,
                  onTap: () => onChanged(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final GlassTabItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        selected ? AppColors.onSurface : AppColors.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: RadiusTokens.borderPill,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.glassRose : Colors.transparent,
            borderRadius: RadiusTokens.borderPill,
            border: selected
                ? Border.all(color: AppColors.glassStroke, width: 1)
                : null,
            boxShadow: selected ? ShadowTokens.glowRose : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, size: 22, color: color),
              const SizedBox(height: 2),
              Text(
                item.label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: color,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
