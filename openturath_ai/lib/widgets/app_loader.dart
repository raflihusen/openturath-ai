import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/localization.dart';
import '../core/scholarly_fonts.dart';
import '../core/design/ot_motion.dart';
import 'package:openturath_ai/core/design/ot_typography.dart';

/// Loader folio OpenTurath dengan kecepatan periodik dan dukungan reduced motion.
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
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: OTMotion.loaderLoop,
    );
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMotion();
  }

  void _syncMotion() {
    final reduced = MediaQuery.disableAnimationsOf(context);
    final active = WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    if (reduced || !TickerMode.of(context) || !active) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (mounted) _syncMotion();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
        Semantics(
            label: widget.title == null
                ? Loc.tr('loadingProcess')
                : Loc.text(widget.title!),
            liveRegion: true,
            child: RepaintBoundary(
                child: SizedBox.square(
                  dimension: widget.isFullscreen ? 56 : widget.title == null ? 24 : 48,
                  child: CustomPaint(painter: _OrbitPainter(animation: _controller, still: still, color: dotColor))))),
        if (widget.title != null) ...[
          const SizedBox(height: 20),
          Text(
            Loc.text(widget.title!),
            textAlign: TextAlign.center,
            style: widget.isFullscreen
                ? ScholarlyFonts.outfit(
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

/// Smooth periodic phase: endpoint position and velocity match exactly.
class _OrbitPainter extends CustomPainter {
  _OrbitPainter({required this.animation, required this.still, required this.color}) : super(repaint: animation);
  final Animation<double> animation;
  final bool still;
  double get progress => still ? .25 : animation.value;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final phase = progress * 2 * math.pi;
    // Periodic easing preserves velocity at the loop seam. Four folios breathe
    // and turn as one; opacity does not flicker or imply measured progress.
    final turn = phase - .45 * math.sin(phase);
    final breath = .5 - .5 * math.cos(phase);
    final w = size.shortestSide;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(turn);
    for (var i = 0; i < 4; i++) {
      canvas.save();
      canvas.rotate(i * math.pi / 2);
      final radius = w * (.16 + .07 * breath);
      final rect = Rect.fromCenter(
          center: Offset(radius, -radius),
          width: w * (.30 - .05 * breath),
          height: w * (.30 + .04 * breath));
      canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(w * .105)),
          Paint()..color = color.withValues(alpha: 1 - i * .16));
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_OrbitPainter old) =>
      old.animation != animation || old.still != still || old.color != color;
}
