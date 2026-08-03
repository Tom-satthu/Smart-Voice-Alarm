import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

enum ScreenSizeClass { compact, medium, expanded }

abstract final class Responsive {
  static ScreenSizeClass of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppConstants.desktopBreakpoint) {
      return ScreenSizeClass.expanded;
    }
    if (width >= AppConstants.tabletBreakpoint) {
      return ScreenSizeClass.medium;
    }
    return ScreenSizeClass.compact;
  }

  static bool isCompact(BuildContext context) =>
      of(context) == ScreenSizeClass.compact;

  static bool isTabletOrLarger(BuildContext context) =>
      of(context) != ScreenSizeClass.compact;

  static double horizontalPadding(BuildContext context) {
    switch (of(context)) {
      case ScreenSizeClass.compact:
        return AppConstants.spaceLg;
      case ScreenSizeClass.medium:
        return AppConstants.spaceXl;
      case ScreenSizeClass.expanded:
        return AppConstants.space2xl;
    }
  }

  static double contentWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width.clamp(0, AppConstants.maxContentWidth).toDouble();
  }
}

class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth = AppConstants.maxContentWidth,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding:
              padding ??
              EdgeInsets.symmetric(
                horizontal: Responsive.horizontalPadding(context),
              ),
          child: child,
        ),
      ),
    );
  }
}
