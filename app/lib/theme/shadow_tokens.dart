import 'package:flutter/material.dart';

/// Soft dual-layer shadows (warm brown alpha, never pure black).
abstract final class ShadowTokens {
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x1A4A3728),
      offset: Offset(0, 8),
      blurRadius: 24,
    ),
    BoxShadow(
      color: Color(0x0F4A3728),
      offset: Offset(0, 2),
      blurRadius: 6,
    ),
  ];

  static const List<BoxShadow> float = [
    BoxShadow(
      color: Color(0x244A3728),
      offset: Offset(0, 12),
      blurRadius: 32,
    ),
    BoxShadow(
      color: Color(0x144A3728),
      offset: Offset(0, 4),
      blurRadius: 8,
    ),
  ];

  static const List<BoxShadow> sheet = [
    BoxShadow(
      color: Color(0x2E4A3728),
      offset: Offset(0, 24),
      blurRadius: 48,
    ),
  ];

  /// Selected / active rose glow — use sparingly.
  static const List<BoxShadow> glowRose = [
    BoxShadow(
      color: Color(0x59E8A598),
      offset: Offset(0, 0),
      blurRadius: 20,
    ),
  ];
}
