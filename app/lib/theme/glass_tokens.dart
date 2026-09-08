import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Frosted-glass material parameters from `DESIGN.md` / UI 设计参数.
abstract final class GlassTokens {
  static const double blurSigma = 24;
  static const double blurSigmaSheet = 32;
  static const double borderWidth = 1;

  static ImageFilter blur([double sigma = blurSigma]) =>
      ImageFilter.blur(sigmaX: sigma, sigmaY: sigma);

  static BoxDecoration fill({
    required Color color,
    required BorderRadius borderRadius,
    Color stroke = AppColors.glassStroke,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: borderRadius,
      border: Border.all(color: stroke, width: borderWidth),
      boxShadow: boxShadow,
    );
  }
}

enum GlassFill {
  light,
  medium,
  heavy,
  rose,
  roseSoft,
  locked,
}

extension GlassFillX on GlassFill {
  Color get color => switch (this) {
        GlassFill.light => AppColors.glassLight,
        GlassFill.medium => AppColors.glassMedium,
        GlassFill.heavy => AppColors.glassHeavy,
        GlassFill.rose => AppColors.glassRose,
        GlassFill.roseSoft => AppColors.glassRoseSoft,
        GlassFill.locked => AppColors.glassLocked,
      };
}
