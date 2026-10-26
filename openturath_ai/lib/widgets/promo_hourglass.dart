import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Jam pasir kecil untuk banner promo. [remaining] (0..1) adalah bagian pasir
/// yang masih di ruang atas; nilainya turun mengikuti waktu promo. Pasir
/// mengikuti gravitasi: di ponsel, sensor percepatan memiringkan permukaannya
/// mengikuti kemiringan ponsel dengan sedikit kelembaman; di komputer tanpa
/// sensor, pasir tetap tegak. Gerak dikurangi: tidak memakai sensor.
class PromoHourglass extends StatefulWidget {
  const PromoHourglass(
      {super.key,
      required this.remaining,
      required this.color,
      this.height = 52});

  final double remaining;
  final Color color;
  final double height;

  @override
  State<PromoHourglass> createState() => _PromoHourglassState();
}

class _PromoHourglassState extends State<PromoHourglass>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_tick);
  StreamSubscription<AccelerometerEvent>? _sub;
  Offset _target = const Offset(0, 1), _g = const Offset(0, 1);
  Offset _v = Offset.zero;
  Duration _last = Duration.zero;
  bool _still = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.disableAnimationsOf(context);
    if (still == _still && (_sub != null || _ticker.isActive)) return;
    _still = still;
    _sub?.cancel();
    _sub = null;
    if (still) {
      _ticker.stop();
      _target = _g = const Offset(0, 1);
      return;
    }
    // Hanya ponsel dan tablet punya sensor. Kegagalan sensor (platform tanpa
    // sensor, uji) bisa muncul secara asinkron, jadi dijaga di zonanya sendiri.
    if (!kIsWeb &&
        !Platform.environment.containsKey('FLUTTER_TEST') &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      runZonedGuarded(() {
        _sub =
            accelerometerEventStream(samplingPeriod: SensorInterval.uiInterval)
                .listen((e) {
          // Percepatan terukur = -gravitasi; layar: x kanan, y bawah.
          final g = Offset(-e.x, e.y);
          final n = g.distance;
          if (n > 3) _target = g / n; // abaikan gerakan tak jelas
        }, onError: (_) {}, cancelOnError: true);
      }, (_, __) {});
    }
    if (!_ticker.isActive) _ticker.start();
  }

  void _tick(Duration t) {
    final dt = ((t - _last).inMicroseconds / 1e6).clamp(0.0, 0.05);
    _last = t;
    if ((_target - _g).distance < 0.002 && _v.distance < 0.002) return;
    // Pegas teredam: lembam kecil supaya permukaan pasir terasa bergoyang.
    _v += (_target - _g) * (60 * dt) - _v * (7 * dt);
    _g += _v * (dt * 6);
    final n = _g.distance;
    if (n > 0.0001) _g = _g / n;
    setState(() {});
  }

  @override
  void dispose() {
    _sub?.cancel();
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
        excludeSemantics: true,
        child: CustomPaint(
          size: Size(widget.height * 0.62, widget.height),
          painter: _HourglassPainter(
              widget.remaining.clamp(0.0, 1.0), _g, widget.color),
        ),
      );
}

class _HourglassPainter extends CustomPainter {
  _HourglassPainter(this.remaining, this.g, this.color);
  final double remaining;
  final Offset g;
  final Color color;

  static double _area(List<Offset> p) {
    var a = 0.0;
    for (var i = 0; i < p.length; i++) {
      final q = p[(i + 1) % p.length];
      a += p[i].dx * q.dy - q.dx * p[i].dy;
    }
    return a.abs() / 2;
  }

  /// Memotong poligon cembung pada setengah bidang n·p >= d.
  static List<Offset> _clip(List<Offset> poly, Offset n, double d) {
    final out = <Offset>[];
    for (var i = 0; i < poly.length; i++) {
      final a = poly[i], b = poly[(i + 1) % poly.length];
      final da = a.dx * n.dx + a.dy * n.dy - d,
          db = b.dx * n.dx + b.dy * n.dy - d;
      if (da >= 0) out.add(a);
      if ((da >= 0) != (db >= 0)) {
        out.add(Offset.lerp(a, b, da / (da - db))!);
      }
    }
    return out;
  }

  /// Pasir seluas [fraction] dari ruang, menumpuk di sisi gravitasi.
  static List<Offset> _sand(List<Offset> chamber, Offset n, double fraction) {
    if (fraction <= 0.001) return const [];
    final total = _area(chamber);
    if (fraction >= 0.999) return chamber;
    var lo = chamber.map((p) => p.dx * n.dx + p.dy * n.dy).reduce(math.min);
    var hi = chamber.map((p) => p.dx * n.dx + p.dy * n.dy).reduce(math.max);
    for (var i = 0; i < 28; i++) {
      final mid = (lo + hi) / 2;
      final a = _area(_clip(chamber, n, mid));
      if (a > fraction * total) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    return _clip(chamber, n, (lo + hi) / 2);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    final r = size.width * 0.40,
        h = size.height * 0.44,
        neck = size.width * 0.05;
    final upper = [
      Offset(-r, -h),
      Offset(r, -h),
      Offset(neck, 0),
      Offset(-neck, 0)
    ];
    final lower = [
      Offset(-neck, 0),
      Offset(neck, 0),
      Offset(r, h),
      Offset(-r, h)
    ];
    final n = g.distance < 0.01 ? const Offset(0, 1) : g / g.distance;

    final fill = Paint()..color = color.withValues(alpha: 0.9);
    for (final (chamber, f) in [(upper, remaining), (lower, 1 - remaining)]) {
      final s = _sand(chamber, n, f);
      if (s.length >= 3) {
        canvas.drawPath(Path()..addPolygon(s, true), fill);
      }
    }
    // Aliran tipis lewat leher bila tegak dan masih ada pasir di atas.
    if (remaining > 0.005 && remaining < 0.995 && n.dy > 0.7) {
      canvas.drawLine(
          Offset(0, -h * 0.05),
          Offset(0, h * 0.62),
          Paint()
            ..color = color.withValues(alpha: 0.7)
            ..strokeWidth = size.width * 0.03);
    }
    final glass = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.4, size.width * 0.05)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final outline = Path()
      ..moveTo(-r, -h)
      ..lineTo(r, -h)
      ..lineTo(neck, 0)
      ..lineTo(r, h)
      ..lineTo(-r, h)
      ..lineTo(-neck, 0)
      ..close();
    canvas.drawPath(outline, glass);
    // Tutup atas dan bawah.
    final cap = r * 1.25;
    canvas.drawLine(Offset(-cap, -h - 2), Offset(cap, -h - 2), glass);
    canvas.drawLine(Offset(-cap, h + 2), Offset(cap, h + 2), glass);
  }

  @override
  bool shouldRepaint(_HourglassPainter old) =>
      old.remaining != remaining || old.g != g || old.color != color;
}
