import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// OtTactileCard: Widget pembungkus sentuhan taktil berbobot fisik (Google Edge Gallery spec).
/// Memberikan kompresi skala lembut (scale 0.96) saat ditekan dan membal elastis saat dilepas,
/// lengkap dengan getaran haptik mikro di ujung jari pengguna.
class OtTactileCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressedScale;
  final Duration pressDuration;
  final Duration releaseDuration;
  final BorderRadius? borderRadius;
  final HitTestBehavior behavior;

  const OtTactileCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.965,
    this.pressDuration = const Duration(milliseconds: 90),
    this.releaseDuration = const Duration(milliseconds: 140),
    this.borderRadius,
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  State<OtTactileCard> createState() => _OtTactileCardState();
}

class _OtTactileCardState extends State<OtTactileCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.pressDuration,
      reverseDuration: widget.releaseDuration,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pressedScale,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onTap != null || widget.onLongPress != null) {
      HapticFeedback.lightImpact();
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails _) {
    if (widget.onTap != null || widget.onLongPress != null) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null || widget.onLongPress != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            alignment: Alignment.center,
            child: child,
          );
        },
        child: widget.borderRadius != null
            ? ClipRRect(borderRadius: widget.borderRadius!, child: widget.child)
            : widget.child,
      ),
    );
  }
}

/// OtInteractiveButton: Tombol taktil dengan respon sentuhan elastis untuk seluruh CTA aplikasi.
class OtInteractiveButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double pressedScale;
  final BorderRadius? borderRadius;

  const OtInteractiveButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.pressedScale = 0.955,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return OtTactileCard(
      onTap: onPressed,
      pressedScale: pressedScale,
      borderRadius: borderRadius,
      child: child,
    );
  }
}

/// OtCopyMorphButton: Ikon tombol salin yang bermutasi halus menjadi ikon centang hijau
/// dengan efek pembesaran mikro (*scale pop*) saat teks berhasil disalin.
class OtCopyMorphButton extends StatefulWidget {
  final String textToCopy;
  final VoidCallback? onCopied;
  final Color? defaultColor;
  final Color successColor;
  final double iconSize;

  const OtCopyMorphButton({
    super.key,
    required this.textToCopy,
    this.onCopied,
    this.defaultColor,
    this.successColor = const Color(0xFF10B981), // Emerald Green
    this.iconSize = 18.0,
  });

  @override
  State<OtCopyMorphButton> createState() => _OtCopyMorphButtonState();
}

class _OtCopyMorphButtonState extends State<OtCopyMorphButton> {
  bool _copied = false;

  void _copy() async {
    if (widget.textToCopy.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: widget.textToCopy));
    HapticFeedback.mediumImpact();
    widget.onCopied?.call();

    if (!mounted) return;
    setState(() => _copied = true);

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fallbackColor = isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final effectiveDefaultColor = widget.defaultColor ?? fallbackColor;

    return OtTactileCard(
      onTap: _copy,
      pressedScale: 0.88,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          transitionBuilder: (child, animation) {
            return ScaleTransition(
              scale: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: _copied
              ? Icon(
                  Icons.check_circle_rounded,
                  key: const ValueKey('check'),
                  color: widget.successColor,
                  size: widget.iconSize,
                )
              : Icon(
                  Icons.copy_rounded,
                  key: const ValueKey('copy'),
                  color: effectiveDefaultColor,
                  size: widget.iconSize,
                ),
        ),
      ),
    );
  }
}
