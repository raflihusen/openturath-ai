import 'dart:async';

import 'package:flutter/material.dart';

import '../core/design/ot_motion.dart';

/// A quiet, one-shot V6 entrance for cards and editorial sections.
///
/// It intentionally avoids looping effects and fully respects the platform's
/// reduced-motion preference.
class OTStaggeredEntrance extends StatefulWidget {
  const OTStaggeredEntrance({
    super.key,
    required this.child,
    this.index = 0,
    this.translateY = 22,
  });

  final Widget child;
  final int index;
  final double translateY;

  @override
  State<OTStaggeredEntrance> createState() => _OTStaggeredEntranceState();
}

class _OTStaggeredEntranceState extends State<OTStaggeredEntrance> {
  Timer? _timer;
  bool _visible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_visible || _timer != null) return;

    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      _visible = true;
      return;
    }

    final delay = OTMotion.stagger * widget.index.clamp(0, 6);
    _timer = Timer(delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: OTMotion.normal,
      curve: OTMotion.curve,
      transform: Matrix4.translationValues(
        0,
        _visible ? 0 : widget.translateY,
        0,
      ),
      child: AnimatedOpacity(
        duration: OTMotion.normal,
        curve: OTMotion.curve,
        opacity: _visible ? 1 : 0,
        child: widget.child,
      ),
    );
  }
}
