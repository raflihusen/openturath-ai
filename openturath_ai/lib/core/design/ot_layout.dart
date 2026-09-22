import 'package:flutter/material.dart';

/// Mobile-first layout rules for OpenTurath.
///
/// The website and the application share typography and tone, but not page
/// composition. These constraints keep operational screens readable on phones
/// and prevent tablet layouts from becoming stretched phone UIs.
class OTLayout {
  static const double compactBreakpoint = 600;
  static const double mediumBreakpoint = 840;
  static const double readableWidth = 680;
  static const double catalogueWidth = 960;
  static const double minimumTouchTarget = 48;

  static double pageInset(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= mediumBreakpoint) return 32;
    if (width >= compactBreakpoint) return 24;
    return 20;
  }

  static int catalogueColumns(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1100) return 3;
    if (width >= 720) return 2;
    return 1;
  }

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= compactBreakpoint;
}

class OTConstrainedContent extends StatelessWidget {
  const OTConstrainedContent({
    super.key,
    required this.child,
    this.maxWidth = OTLayout.readableWidth,
    this.padding,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ??
              EdgeInsets.symmetric(horizontal: OTLayout.pageInset(context)),
          child: child,
        ),
      ),
    );
  }
}
