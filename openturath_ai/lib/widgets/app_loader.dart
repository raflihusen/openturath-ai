import '../core/l10n/app_dictionary.dart';
import 'package:flutter/material.dart';
import 'package:openturath_ai/core/design/ot_fonts.dart';
import '../core/design/ot_colors.dart';

/// Quiet shared loading state. Reduced-motion users see a static indicator;
/// offstage destinations stop the animation instead of spending background frames.
class AppLoader extends StatefulWidget {
  final double dotSize;
  final double spacing;
  final Color? color;
  final String? title;
  final String? subtitle;
  final VoidCallback? onCancel;
  final String cancelLabel;
  final bool isFullscreen;

  const AppLoader({
    super.key,
    this.dotSize = 9.0,
    this.spacing = 5.0,
    this.color,
    this.title,
    this.subtitle,
    this.onCancel,
    this.cancelLabel = 'Batal',
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
    this.cancelLabel = 'Batal',
  }) : isFullscreen = true;

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _animate = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animate = !MediaQuery.disableAnimationsOf(context) && TickerMode.of(context);
    if (animate == _animate) return;
    _animate = animate;
    if (_animate) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.value = .5;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultAccent = OTColors.textPrimary(isDark);
    final dotColor = widget.color ?? defaultAccent;
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final canvas = OTColors.canvas(isDark);

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Semantics(label: context.tr('Sedang memuat'), liveRegion: true,
          child: ExcludeSemantics(child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                final delay = index * 0.2;
                final t = (_controller.value - delay) % 1.0;
                final curveVal = Curves.easeInOutSine.transform(t < 0 ? t + 1.0 : t);
                final scale = _animate
                    ? .92 + (.08 * (1.0 - (curveVal - .5).abs() * 2)) : 1.0;
                final opacity = _animate
                    ? .4 + (.55 * (1.0 - (curveVal - .5).abs() * 2)) : .65;

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
        ))),
        if (widget.title != null) ...[
          const SizedBox(height: 20),
          Text(
            context.tr(widget.title!),
            textAlign: TextAlign.center,
            style: OTFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
        ],
        if (widget.subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            context.tr(widget.subtitle!),
            textAlign: TextAlign.center,
            style: OTFonts.outfit(
              fontSize: 12,
              color: textSecondary,
            ),
          ),
        ],
        if (widget.onCancel != null) ...[
          const SizedBox(height: 24),
          TextButton(
            onPressed: widget.onCancel,
            style: TextButton.styleFrom(
              minimumSize: const Size(96, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              widget.cancelLabel,
              style: OTFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w500,
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
          child: Center(child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420),
                child: content),
          )),
        ),
      );
    }

    return Center(child: content);
  }
}


