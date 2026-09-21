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
    this.offset = const Offset(0, 0.025),
  });

  final Widget child;
  final int index;
  final Offset offset;

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
    return AnimatedSlide(
      duration: OTMotion.normal,
      curve: OTMotion.curve,
      offset: _visible ? Offset.zero : widget.offset,
      child: AnimatedOpacity(
        duration: OTMotion.normal,
        curve: OTMotion.curve,
        opacity: _visible ? 1 : 0,
        child: widget.child,
      ),
    );
  }
}
