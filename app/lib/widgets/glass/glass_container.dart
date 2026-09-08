import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/glass_tokens.dart';
import '../../theme/radius_tokens.dart';
import '../../theme/shadow_tokens.dart';

/// Frosted glass surface: [BackdropFilter] + translucent fill + luminous stroke.
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.fill = GlassFill.light,
    this.borderRadius = RadiusTokens.borderLg,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.blurSigma = GlassTokens.blurSigma,
    this.boxShadow = ShadowTokens.card,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final GlassFill fill;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final double blurSigma;
  final List<BoxShadow>? boxShadow;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: boxShadow,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        clipBehavior: clipBehavior,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: GlassTokens.fill(
              color: fill.color,
              borderRadius: borderRadius,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
