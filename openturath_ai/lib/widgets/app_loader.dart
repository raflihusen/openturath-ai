import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/localization.dart';
import '../core/scholarly_fonts.dart';
import 'openturath_brand.dart';

import 'package:openturath_ai/core/design/ot_typography.dart';
import 'package:openturath_ai/core/design/ot_radius.dart';
/// AppLoader: Komponen visual baku tiga titik berdenyut (Three-Dots Pulse Loader).
/// Menyatukan 4 implementasi loader berbeda menjadi satu komponen berstandar Apple HIG.
class AppLoader extends StatefulWidget {
  final double dotSize;
  final double spacing;
  final Color? color;
  final String? title;
  final String? subtitle;
  final VoidCallback? onCancel;
  final String? cancelLabel;
  final bool isFullscreen;

  const AppLoader({
    super.key,
    this.dotSize = 9.0,
    this.spacing = 5.0,
    this.color,
    this.title,
    this.subtitle,
    this.onCancel,
    this.cancelLabel,
    this.isFullscreen = false,
  });

  const AppLoader.fullscreen({
    super.key,
    this.dotSize = 10.0,
    this.spacing = 5.0,
    this.color,
    this.title,
    this.subtitle,
    this.onCancel,
    this.cancelLabel,
  }) : isFullscreen = true;

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultAccent = isDark ? AppTheme.accentDark : AppTheme.accentLight;
    final dotColor = widget.color ?? defaultAccent;
    final textPrimary =
        isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final canvas = isDark ? AppTheme.canvasDark : AppTheme.canvasLight;
    final still = MediaQuery.disableAnimationsOf(context);

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isFullscreen) ...[
          OpenTurathMark(size: 40, color: textPrimary),
          const SizedBox(height: 22),
          // Garis tipis dengan ruas yang meluncur: memuat tanpa durasi pasti.
          ClipRRect(
            borderRadius: BorderRadius.circular(OTRadius.xs),
            child: SizedBox(
              width: 132,
              height: 2,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => CustomPaint(
                  painter: _SlidingBarPainter(
                    progress: still ? 0.5 : _controller.value,
                    track: textPrimary.withValues(alpha: 0.10),
                    bar: textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ] else
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (index) {
                  final delay = index * 0.2;
                  final t = (_controller.value - delay) % 1.0;
                  final curveVal =
                      Curves.easeInOutSine.transform(t < 0 ? t + 1.0 : t);
                  final scale =
                      0.75 + (0.45 * (1.0 - (curveVal - 0.5).abs() * 2));
                  final opacity =
                      0.3 + (0.7 * (1.0 - (curveVal - 0.5).abs() * 2));

                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: widget.spacing),
                    child: Transform.scale(
                      scale: scale,
                      child: Opacity(
                        opacity: opacity.clamp(0.25, 1.0),
                        child: Container(
                          width: widget.dotSize,
                          height: widget.dotSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: dotColor,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        if (widget.title != null) ...[
          const SizedBox(height: 20),
          Text(
            Loc.text(widget.title!),
            textAlign: TextAlign.center,
            style: widget.isFullscreen
                ? ScholarlyFonts.newsreader(
                    fontSize: OTFontSize.s20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                    color: textPrimary,
                  )
                : ScholarlyFonts.outfit(
                    fontSize: OTFontSize.s16,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
          ),
        ],
        if (widget.subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.subtitle!,
            textAlign: TextAlign.center,
            style: ScholarlyFonts.outfit(
              fontSize: OTFontSize.s14,
              color: textSecondary,
            ),
          ),
        ],
        if (widget.onCancel != null) ...[
          const SizedBox(height: 24),
          TextButton(
            onPressed: widget.onCancel,
            style: TextButton.styleFrom(
              minimumSize: const Size(80, 44),
            ),
            child: Text(
              widget.cancelLabel ?? Loc.tr('cancel'),
              style: ScholarlyFonts.outfit(
                fontSize: OTFontSize.s14,
                fontWeight: FontWeight.w400,
                color: textSecondary,
              ),
            ),
          ),
        ],
      ],
    );

    if (widget.isFullscreen) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: canvas,
        child: SafeArea(
          child: Center(child: content),
        ),
      );
    }

    return Center(child: content);
  }
}

/// Ruas pendek yang meluncur di atas lintasan tipis.
class _SlidingBarPainter extends CustomPainter {
  _SlidingBarPainter(
      {required this.progress, required this.track, required this.bar});

  final double progress;
  final Color track;
  final Color bar;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = track);
    final eased = Curves.easeInOutCubic.transform(progress);
    final width = size.width * 0.38;
    final left = -width + (size.width + width) * eased;
    canvas.drawRect(
        Rect.fromLTWH(left, 0, width, size.height), Paint()..color = bar);
  }

  @override
  bool shouldRepaint(_SlidingBarPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
