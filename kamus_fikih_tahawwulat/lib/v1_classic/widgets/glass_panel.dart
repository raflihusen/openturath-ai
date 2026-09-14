import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/classic_glass_theme.dart';

class GlassPanel extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool isThick;
  final VoidCallback? onTap;

  const GlassPanel({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.padding,
    this.margin,
    this.isThick = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final blurSigma = isThick ? 24.0 : 14.0;
    final surfaceColor = isDark
        ? (isThick ? const Color(0x661E293B) : const Color(0x331E293B))
        : (isThick ? const Color(0xCCFFFFFF) : const Color(0x8AFFFFFF));

    final borderColor = isDark
        ? (isThick ? const Color(0x40FFFFFF) : const Color(0x24FFFFFF))
        : (isThick ? const Color(0x80FFFFFF) : const Color(0x4AFFFFFF));

    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          splashColor: ClassicGlassTheme.getAccent(isDark).withOpacity(0.18),
          highlightColor: Colors.transparent,
          child: content,
        ),
      );
    }

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: content,
        ),
      ),
    );
  }
}
