import 'package:flutter/material.dart';

/// Brand + semantic colors from `DESIGN.md`.
abstract final class AppColors {
  static const Color primary = Color(0xFFE8A598);
  static const Color primaryDeep = Color(0xFFC97B6E);
  static const Color secondary = Color(0xFFF5D5C8);
  static const Color tertiary = Color(0xFF5BB98A);
  static const Color neutral = Color(0xFFF7F1EA);
  static const Color blush = Color(0xFFF3E4DC);
  static const Color atmosphereBottom = Color(0xFFEBD5CB);
  static const Color onSurface = Color(0xFF4A3728);
  static const Color onSurfaceVariant = Color(0xFF8A7A6C);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color locked = Color(0xFFB5A89C);
  static const Color divider = Color(0x144A3728); // 8% of #4A3728

  static const Color glassLight = Color(0x8CFFFFFF); // 0.55
  static const Color glassMedium = Color(0x66FFFFFF); // 0.40
  static const Color glassHeavy = Color(0xB8FFFFFF); // 0.72
  static const Color glassRose = Color(0x73E8A598); // 0.45
  static const Color glassRoseSoft = Color(0x59F5D5C8); // 0.35
  static const Color glassLocked = Color(0x52FFFFFF); // 0.32
  static const Color glassStroke = Color(0xA6FFFFFF); // 0.65
  static const Color glassStrokeSoft = Color(0x59FFFFFF); // 0.35
  static const Color scrim = Color(0x474A3728); // 0.28

  static const LinearGradient atmosphereGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [neutral, blush, atmosphereBottom],
  );
}
