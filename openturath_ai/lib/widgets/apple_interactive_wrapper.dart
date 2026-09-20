import '../core/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wrapper interaktif bergaya Apple iOS dengan animasi kompresi mikro
/// (press-down scale), pantulan pegas halus, dan getaran haptic feedback taktil.
class AppleInteractiveWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressedScale;
  final Duration duration;
  final bool enableHaptic;
  final HapticFeedbackType hapticType;
  final BorderRadius? borderRadius;
  final String? semanticLabel;

  const AppleInteractiveWrapper({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.975,
    this.duration = const Duration(milliseconds: 110),
    this.enableHaptic = true,
    this.hapticType = HapticFeedbackType.light,
    this.borderRadius,
    this.semanticLabel,
  });

  @override
  State<AppleInteractiveWrapper> createState() => _AppleInteractiveWrapperState();
}

enum HapticFeedbackType {
  light,
  medium,
  selection,
  none,
}

class _AppleInteractiveWrapperState extends State<AppleInteractiveWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: const Duration(milliseconds: 140),
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

  void _triggerHaptic() {
    if (!widget.enableHaptic) return;
    switch (widget.hapticType) {
      case HapticFeedbackType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.selection:
        HapticFeedback.selectionClick();
        break;
      case HapticFeedbackType.none:
        break;
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null || widget.onLongPress != null) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null || widget.onLongPress != null) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null || widget.onLongPress != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final hasAction = widget.onTap != null || widget.onLongPress != null;
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    Widget result = reduceMotion
        ? widget.child
        : AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              );
            },
            child: widget.child,
          );

    if (hasAction) {
      result = Semantics(
        button: true,
        enabled: true,
        label: widget.semanticLabel,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: reduceMotion ? null : _handleTapDown,
          onTapUp: reduceMotion ? null : _handleTapUp,
          onTapCancel: reduceMotion ? null : _handleTapCancel,
          onTap: () {
            _triggerHaptic();
            widget.onTap?.call();
          },
          onLongPress: widget.onLongPress != null
              ? () {
                  HapticFeedback.mediumImpact();
                  widget.onLongPress?.call();
                }
              : null,
          child: result,
        ),
      );
    }

    return result;
  }
}
