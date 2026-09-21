import 'dart:math';
import 'package:flutter/material.dart';

/// Widget animasi masuk bertingkat (progressive staggered entrance)
/// Mensimulasikan sistem gerak website V6:
/// - Translasi vertikal: 22px -> 0px
/// - Opacity: 0.0 -> 1.0
/// - Kurva Apple fluid spring: Cubic(0.16, 1.0, 0.3, 1.0)
/// - Delay per indeks: min(index, 6) * 60ms
class StaggeredEntrance extends StatefulWidget {
  final int index;
  final Widget child;
  final Duration duration;
  final double verticalOffset;
  final Curve curve;

  const StaggeredEntrance({
    super.key,
    required this.index,
    required this.child,
    this.duration = const Duration(milliseconds: 550),
    this.verticalOffset = 22.0,
    this.curve = const Cubic(0.16, 1.0, 0.3, 1.0),
  });

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _translateY;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    final curved = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
    _translateY = Tween<double>(
      begin: widget.verticalOffset,
      end: 0.0,
    ).animate(curved);

    final delayMs = min(widget.index, 6) * 60;
    if (delayMs > 0) {
      Future.delayed(Duration(milliseconds: delayMs), () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, _translateY.value),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
