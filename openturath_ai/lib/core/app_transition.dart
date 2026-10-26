import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Jenis perpindahan tampilan seluruh aplikasi.
enum AppTransitionKind {
  /// Terang/gelap: tampilan baru terungkap melingkar dari titik sentuhan.
  theme,

  /// Bahasa: tampilan baru terungkap lewat sapuan berbulu searah baca
  /// bahasa tujuan (kiri ke kanan, atau kanan ke kiri untuk Arab).
  language,
}

/// Pintu masuk untuk perpindahan tema dan bahasa yang mulus.
///
/// Warna di banyak widget dihitung langsung dari kecerahan (bukan dari
/// `Theme.of`), sehingga `themeAnimationDuration` tidak bisa menganimasikannya.
/// Karena itu layar dipotret sebelum perubahan, lalu potret itu diletakkan di
/// atas tampilan baru dan disingkirkan dengan animasi.
abstract final class AppTransition {
  static _AppTransitionHostState? _host;

  /// Panggil SEBELUM mengubah nilai tema/bahasa. Selesai setelah layar lama
  /// dipotret; tanpa host (mis. di pengujian) langsung kembali.
  ///
  /// [rtl] hanya dipakai untuk [AppTransitionKind.language]: arah baca bahasa
  /// tujuan, yang menentukan arah sapuan.
  static Future<void> begin(AppTransitionKind kind, {bool rtl = false}) async {
    final host = _host;
    if (host == null) return;
    await host._capture(kind, rtl: rtl);
  }
}

/// Membungkus isi aplikasi dan menampilkan potret lama selama transisi.
class AppTransitionHost extends StatefulWidget {
  const AppTransitionHost({super.key, required this.child});

  final Widget child;

  @override
  State<AppTransitionHost> createState() => _AppTransitionHostState();
}

class _AppTransitionHostState extends State<AppTransitionHost>
    with SingleTickerProviderStateMixin {
  final GlobalKey _boundaryKey = GlobalKey();
  late final AnimationController _controller = AnimationController(vsync: this)
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) _clear();
    });

  ui.Image? _image;
  AppTransitionKind _kind = AppTransitionKind.theme;
  bool _rtl = false;
  Offset _origin = Offset.zero;
  Offset? _lastPointer;

  @override
  void initState() {
    super.initState();
    AppTransition._host = this;
  }

  @override
  void dispose() {
    if (AppTransition._host == this) AppTransition._host = null;
    _controller.dispose();
    _image?.dispose();
    super.dispose();
  }

  void _clear() {
    if (!mounted) return;
    setState(() {
      _image?.dispose();
      _image = null;
    });
  }

  Future<void> _capture(AppTransitionKind kind, {bool rtl = false}) async {
    if (!mounted || MediaQuery.disableAnimationsOf(context)) return;
    final boundary = _boundaryKey.currentContext?.findRenderObject();
    if (boundary is! RenderRepaintBoundary || !boundary.hasSize) return;
    try {
      final ratio = View.of(context).devicePixelRatio;
      final image = await boundary.toImage(pixelRatio: ratio);
      if (!mounted) {
        image.dispose();
        return;
      }
      _controller.stop();
      final previous = _image;
      setState(() {
        _image = image;
        _kind = kind;
        _rtl = rtl;
        _origin = _lastPointer ?? boundary.size.center(Offset.zero);
      });
      previous?.dispose();
      _controller.duration =
          Duration(milliseconds: kind == AppTransitionKind.theme ? 720 : 650);
      _controller.forward(from: 0);
    } catch (_) {
      // Gagal memotret: perubahan tetap berlaku, hanya tanpa animasi.
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    return Listener(
      onPointerDown: (event) => _lastPointer = event.localPosition,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(key: _boundaryKey, child: widget.child),
          if (image != null)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    final snapshot = RawImage(
                      image: image,
                      fit: BoxFit.fill,
                      width: double.infinity,
                      height: double.infinity,
                    );
                    final t = _controller.value;
                    if (_kind == AppTransitionKind.language) {
                      return _sweep(snapshot, t);
                    }
                    return LayoutBuilder(builder: (context, box) {
                      final size = box.biggest;
                      final reach = [
                        Offset.zero,
                        Offset(size.width, 0),
                        Offset(0, size.height),
                        Offset(size.width, size.height),
                      ].map((c) => (c - _origin).distance).reduce(math.max);
                      return ClipPath(
                        clipper: _HoleClipper(
                          origin: _origin,
                          radius:
                              reach * Curves.easeInOutCubic.transform(t) * 1.02,
                        ),
                        child: snapshot,
                      );
                    });
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

extension on _AppTransitionHostState {
  /// Sapuan berbulu: bagian potret lama yang sudah terlewati menghilang,
  /// tepinya lembut, dan potret sedikit ikut terdorong searah sapuan.
  Widget _sweep(Widget snapshot, double t) {
    const feather = 0.32;
    final eased = Curves.easeInOutCubic.transform(t);
    final front = eased * (1 + feather);
    final a = (front - feather).clamp(0.0, 1.0);
    final b = front.clamp(0.0, 1.0);
    final dir = _rtl ? -1.0 : 1.0;
    return Transform.translate(
      offset: Offset(dir * 22 * eased, 0),
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (rect) => LinearGradient(
          begin: _rtl ? Alignment.centerRight : Alignment.centerLeft,
          end: _rtl ? Alignment.centerLeft : Alignment.centerRight,
          colors: const [Color(0x00000000), Color(0xFF000000)],
          stops: [a, b],
        ).createShader(rect),
        child: snapshot,
      ),
    );
  }
}

/// Memotong lubang bundar pada potret lama; yang tersisa hanya bagian luar
/// lingkaran, sehingga tampilan baru terlihat di dalamnya.
class _HoleClipper extends CustomClipper<Path> {
  const _HoleClipper({required this.origin, required this.radius});

  final Offset origin;
  final double radius;

  @override
  Path getClip(Size size) => Path()
    ..fillType = PathFillType.evenOdd
    ..addRect(Offset.zero & size)
    ..addOval(Rect.fromCircle(center: origin, radius: radius));

  @override
  bool shouldReclip(_HoleClipper old) =>
      old.radius != radius || old.origin != origin;
}
