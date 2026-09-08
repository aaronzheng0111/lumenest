import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Cream → blush → peach atmosphere with soft decorative orbs (non-interactive).
class AtmosphereBackground extends StatelessWidget {
  const AtmosphereBackground({
    super.key,
    this.child,
  });

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(gradient: AppColors.atmosphereGradient),
        ),
        Positioned(
          top: -40,
          right: -60,
          child: _Orb(
            diameter: 180,
            color: AppColors.secondary.withOpacity(0.45),
          ),
        ),
        Positioned(
          bottom: 80,
          left: -50,
          child: _Orb(
            diameter: 140,
            color: AppColors.primary.withOpacity(0.25),
          ),
        ),
        if (child != null) child!,
      ],
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({
    required this.diameter,
    required this.color,
  });

  final double diameter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: diameter * 0.45,
              spreadRadius: diameter * 0.08,
            ),
          ],
        ),
      ),
    );
  }
}
