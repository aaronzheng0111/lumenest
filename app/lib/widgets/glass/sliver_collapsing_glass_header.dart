import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Pinned collapsing header for [CustomScrollView] — glass-friendly alternative
/// to Material [SliverAppBar] when the expanded/collapsed surfaces are custom.
///
/// Reserves [topInset] (typically the status-bar padding) at all scroll
/// offsets, then crossfades [expanded] → [collapsed] and pins at
/// [collapsedBodyHeight].
class SliverCollapsingGlassHeader extends StatelessWidget {
  const SliverCollapsingGlassHeader({
    super.key,
    required this.topInset,
    required this.expandedBodyHeight,
    required this.collapsedBodyHeight,
    required this.expanded,
    required this.collapsed,
    this.horizontalPadding = 0,
  });

  /// Status-bar / safe-area inset kept above both expanded and collapsed body.
  final double topInset;

  /// Expanded body height below [topInset].
  final double expandedBodyHeight;

  /// Pinned body height below [topInset].
  final double collapsedBodyHeight;

  /// Fully expanded header content.
  final Widget expanded;

  /// Compact content shown when pinned.
  final Widget collapsed;

  /// Horizontal inset applied to both surfaces.
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    assert(
      expandedBodyHeight >= collapsedBodyHeight,
      'expandedBodyHeight must be ≥ collapsedBodyHeight',
    );
    return SliverPersistentHeader(
      pinned: true,
      delegate: CollapsingGlassHeaderDelegate(
        topInset: topInset,
        expandedBodyHeight: expandedBodyHeight,
        collapsedBodyHeight: collapsedBodyHeight,
        expanded: expanded,
        collapsed: collapsed,
        horizontalPadding: horizontalPadding,
      ),
    );
  }
}

/// Delegate used by [SliverCollapsingGlassHeader]; public for widget tests.
final class CollapsingGlassHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  CollapsingGlassHeaderDelegate({
    required this.topInset,
    required this.expandedBodyHeight,
    required this.collapsedBodyHeight,
    required this.expanded,
    required this.collapsed,
    this.horizontalPadding = 0,
  });

  final double topInset;
  final double expandedBodyHeight;
  final double collapsedBodyHeight;
  final Widget expanded;
  final Widget collapsed;
  final double horizontalPadding;

  @override
  double get minExtent => topInset + collapsedBodyHeight;

  @override
  double get maxExtent => topInset + expandedBodyHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final range = (maxExtent - minExtent).clamp(1.0, double.infinity);
    final progress = (shrinkOffset / range).clamp(0.0, 1.0);
    final expandedOpacity = (1.0 - progress * 1.35).clamp(0.0, 1.0);
    final collapsedOpacity = ((progress - 0.35) / 0.65).clamp(0.0, 1.0);

    // Isolate header paints (opacity crossfade) from the scrolling body.
    return RepaintBoundary(
      child: ColoredBox(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.only(
            top: topInset,
            left: horizontalPadding,
            right: horizontalPadding,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (expandedOpacity > 0)
                IgnorePointer(
                  ignoring: progress > 0.55,
                  child: ClipRect(
                    child: _fade(
                      expandedOpacity,
                      Align(
                        alignment: Alignment.topCenter,
                        child: expanded,
                      ),
                    ),
                  ),
                ),
              if (collapsedOpacity > 0)
                IgnorePointer(
                  ignoring: progress < 0.45,
                  child: _fade(collapsedOpacity, collapsed),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Skip [Opacity] (saveLayer) when fully visible.
  static Widget _fade(double opacity, Widget child) {
    if (opacity >= 1.0) return child;
    return Opacity(opacity: opacity, child: child);
  }

  @override
  bool shouldRebuild(covariant CollapsingGlassHeaderDelegate oldDelegate) {
    return topInset != oldDelegate.topInset ||
        expandedBodyHeight != oldDelegate.expandedBodyHeight ||
        collapsedBodyHeight != oldDelegate.collapsedBodyHeight ||
        horizontalPadding != oldDelegate.horizontalPadding ||
        expanded != oldDelegate.expanded ||
        collapsed != oldDelegate.collapsed;
  }

  @override
  OverScrollHeaderStretchConfiguration? get stretchConfiguration => null;
}
