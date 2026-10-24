import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/arabic_catalog.dart';
import '../core/design/ot_motion.dart';
import '../core/localization.dart';

/// Jeda awal bagi urutan ke-`step`: rapat, supaya slide tidak terasa menunggu.
Duration slideDelay(int step) =>
    Duration(milliseconds: 120 + 90 * math.min(step, 10));

/// Muncul pelan: pudar dan naik (atau masuk dari samping), berurutan.
/// Gerak dikurangi: langsung tampil.
class SlideReveal extends StatefulWidget {
  const SlideReveal(
      {super.key, required this.step, required this.child, this.dx = 0});
  final int step;
  final double dx;
  final Widget child;
  @override
  State<SlideReveal> createState() => _SlideRevealState();
}

class _SlideRevealState extends State<SlideReveal>
    with SingleTickerProviderStateMixin {
  late final Duration _delay = slideDelay(widget.step);
  late final AnimationController _c = AnimationController(
      vsync: this, duration: _delay + OTMotion.transition * 2);
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.of(context).disableAnimations) {
      _c.value = 1;
    } else {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = (_delay + OTMotion.transition * 2).inMilliseconds;
    final a = CurvedAnimation(
        parent: _c,
        curve: Interval(_delay.inMilliseconds / total, 1,
            curve: Curves.easeOutCubic));
    return FadeTransition(
      opacity: a,
      child: SlideTransition(
        position:
            Tween<Offset>(begin: Offset(widget.dx, 0.08), end: Offset.zero)
                .animate(a),
        child: widget.child,
      ),
    );
  }
}

/// Teks yang menyala kata demi kata. Tetap satu `Text`, jadi pembacaan layar
/// dan pencarian teks tidak terpengaruh.
class SlideWords extends StatefulWidget {
  const SlideWords(this.text,
      {super.key, required this.style, this.step = 0, this.textAlign});
  final String text;
  final TextStyle style;
  final int step;
  final TextAlign? textAlign;
  @override
  State<SlideWords> createState() => _SlideWordsState();
}

class _SlideWordsState extends State<SlideWords>
    with SingleTickerProviderStateMixin {
  static const _fade = 380;
  late final List<String> _words = widget.text.split(' ');
  late final int _per = math.max(14, math.min(48, 1100 ~/ _words.length));
  late final int _lead = slideDelay(widget.step).inMilliseconds;
  late final int _total = _lead + _per * _words.length + _fade;
  late final AnimationController _c = AnimationController(
      vsync: this, duration: Duration(milliseconds: _total));
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.of(context).disableAnimations) {
      _c.value = 1;
    } else {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base =
        widget.style.color ?? DefaultTextStyle.of(context).style.color!;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final ms = _c.value * _total;
        return Text.rich(
          TextSpan(style: widget.style, children: [
            for (var i = 0; i < _words.length; i++)
              TextSpan(
                text: i < _words.length - 1 ? '${_words[i]} ' : _words[i],
                style: TextStyle(
                    color: base.withValues(
                        alpha: base.a *
                            Curves.easeOut.transform(
                                ((ms - _lead - i * _per) / _fade)
                                    .clamp(0.0, 1.0)))),
              ),
          ]),
          textAlign: widget.textAlign,
        );
      },
    );
  }
}

/// Angka yang menghitung naik dari nol. Angka Arab-Indic pada bahasa Arab.
class SlideCount extends StatefulWidget {
  const SlideCount(this.to, {super.key, required this.style, this.step = 0});
  final int to;
  final TextStyle style;
  final int step;
  @override
  State<SlideCount> createState() => _SlideCountState();
}

class _SlideCountState extends State<SlideCount>
    with SingleTickerProviderStateMixin {
  late final int _lead = slideDelay(widget.step).inMilliseconds;
  late final int _total = _lead + 900;
  late final AnimationController _c = AnimationController(
      vsync: this, duration: Duration(milliseconds: _total));
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.of(context).disableAnimations) {
      _c.value = 1;
    } else {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          final t = Curves.easeOutCubic
              .transform(((_c.value * _total - _lead) / 900).clamp(0.0, 1.0));
          final n = '${(widget.to * t).round()}';
          return Text(Loc.isArabic ? ArabicCatalog.digits(n) : n,
              style: widget.style);
        },
      );
}

/// Cincin yang terisi sebesar `fraction`, dipakai di belakang angka.
class SlideRing extends StatefulWidget {
  const SlideRing(
      {super.key,
      required this.fraction,
      required this.ink,
      required this.size,
      this.step = 0,
      this.child});
  final double fraction, size;
  final Color ink;
  final int step;
  final Widget? child;
  @override
  State<SlideRing> createState() => _SlideRingState();
}

class _SlideRingState extends State<SlideRing>
    with SingleTickerProviderStateMixin {
  late final int _lead = slideDelay(widget.step).inMilliseconds;
  late final int _total = _lead + 1100;
  late final AnimationController _c = AnimationController(
      vsync: this, duration: Duration(milliseconds: _total));
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.of(context).disableAnimations) {
      _c.value = 1;
    } else {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, child) {
            final t = Curves.easeInOutCubic.transform(
                ((_c.value * _total - _lead) / 1100).clamp(0.0, 1.0));
            return CustomPaint(
              painter: _RingPainter(widget.ink, widget.fraction * t),
              child: child,
            );
          },
          child: Center(child: widget.child),
        ),
      );
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.ink, this.fraction);
  final Color ink;
  final double fraction;

  @override
  void paint(Canvas c, Size s) {
    final rect =
        Rect.fromCircle(center: s.center(Offset.zero), radius: s.width / 2 - 4);
    c.drawArc(
        rect,
        0,
        2 * math.pi,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = ink.withValues(alpha: 0.14));
    c.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * fraction,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round
          ..color = ink);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.fraction != fraction || old.ink != ink;
}
