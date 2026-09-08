import 'package:flutter/material.dart';

/// Corner radii from `DESIGN.md`.
abstract final class RadiusTokens {
  static const double sm = 8;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 24;
  static const double sheet = 28;
  static const double full = 9999;

  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius borderXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius borderSheet =
      BorderRadius.all(Radius.circular(sheet));
  static const BorderRadius borderPill =
      BorderRadius.all(Radius.circular(full));

  /// Sheet top corners only (bottom sheet).
  static const BorderRadius sheetTop = BorderRadius.vertical(
    top: Radius.circular(sheet),
  );
}
