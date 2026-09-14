import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/ot_motion.dart';

/// AppleInteractiveWrapper — Umpan balik sentuh bergaya Apple HIG
/// Scale 0.985 saat ditekan + HapticFeedback.lightImpact()
class AppleInteractiveWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const AppleInteractiveWrapper({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
  });

  @override
  State<AppleInteractiveWrapper> createState() => _AppleInteractiveWrapperState();
}

class _AppleInteractiveWrapperState extends State<AppleInteractiveWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: OTMotion.micro,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: OTMotion.pressedScale).animate(
      CurvedAnimation(parent: _controller, curve: OTMotion.defaultCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails _) {
    _controller.reverse();
    HapticFeedback.lightImpact();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
