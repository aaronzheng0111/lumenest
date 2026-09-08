import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/glass_tokens.dart';
import '../../theme/spacing_tokens.dart';
import 'glass_container.dart';

/// Translucent medium-glass app bar (content height 56) with hairline bottom stroke.
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GlassAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.statusBarHeight = 0,
  });

  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;

  /// Pass [MediaQuery.paddingOf(context).top] from the parent when known.
  final double statusBarHeight;

  static const double contentHeight = 56;

  @override
  Size get preferredSize =>
      Size.fromHeight(contentHeight + statusBarHeight + 1);

  /// Builds a [GlassAppBar] sized for the current safe-area top inset.
  static PreferredSizeWidget forContext(
    BuildContext context, {
    Key? key,
    Widget? title,
    Widget? leading,
    List<Widget>? actions,
    bool centerTitle = true,
  }) {
    final top = MediaQuery.paddingOf(context).top;
    return GlassAppBar(
      key: key,
      title: title,
      leading: leading,
      actions: actions,
      centerTitle: centerTitle,
      statusBarHeight: top,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: statusBarHeight),
          GlassContainer(
            fill: GlassFill.medium,
            borderRadius: BorderRadius.zero,
            blurSigma: GlassTokens.blurSigma,
            boxShadow: null,
            height: contentHeight,
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
            child: NavigationToolbar(
              leading: leading,
              middle: DefaultTextStyle(
                style: Theme.of(context).textTheme.titleMedium!,
                child: title ?? const SizedBox.shrink(),
              ),
              trailing: actions == null
                  ? null
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: actions!,
                    ),
              centerMiddle: centerTitle,
              middleSpacing: SpacingTokens.sm,
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.divider),
        ],
      ),
    );
  }
}
