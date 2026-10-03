import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/open_turath_book.dart';
import '../services/open_turath_catalog_repository.dart';

/// "Rak kitab": judul kitab asli dari katalog bergerak pelan di dalam siluet
/// lengkung logo. Judul yang melewati garis baca menyala dan digarisbawahi,
/// dan [onFocus] menerima kitab itu agar keterangannya bisa ditampilkan.
class LibraryCanvas extends StatefulWidget {
  const LibraryCanvas({super.key, this.onFocus});

  final ValueChanged<OpenTurathBook>? onFocus;

  @override
  State<LibraryCanvas> createState() => _LibraryCanvasState();
}

class _LibraryCanvasState extends State<LibraryCanvas>
    with SingleTickerProviderStateMixin {
  static const _modules = ['fiqh_syafii', 'hadits', 'tafsir', 'ushul_fiqh'];
  static const _columns = 3;
  static const _rowHeight = 46.0;
  static const _speed = 13.0; // px per detik

  late final AnimationController _clock = AnimationController(
      vsync: this, duration: const Duration(hours: 1));
  List<OpenTurathBook> _books = const [];
  final List<List<TextPainter>> _painters = [[], [], []];
  final List<List<OpenTurathBook>> _columnBooks = [[], [], []];
  int _focused = -1;

  bool get _underTest =>
      !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final picked = <OpenTurathBook>[];
    for (final module in _modules) {
      try {
        final books = await OpenTurathCatalogRepository.instance
            .loadBooksForModule(module);
        // Judul pendek saja agar muat satu baris di kolom sempit.
        picked.addAll(books
            .where((book) => book.title.length >= 3 && book.title.length <= 26)
            .take(10));
      } catch (_) {
        // Katalog belum termuat: kanvas tetap tampil tanpa judul.
      }
    }
    if (!mounted || picked.isEmpty) return;
    setState(() {
      _books = picked;
      for (var c = 0; c < _columns; c++) {
        _painters[c].clear();
        _columnBooks[c].clear();
      }
      for (var i = 0; i < picked.length; i++) {
        final column = i % _columns;
        _columnBooks[column].add(picked[i]);
        _painters[column].add(TextPainter(
          text: TextSpan(
            text: picked[i].title,
            style: const TextStyle(
              fontFamily: 'NativeArabic',
              fontSize: 21,
              height: 1.5,
              color: Color(0xFFFFFFFF),
            ),
          ),
          textDirection: TextDirection.rtl,
          maxLines: 1,
          ellipsis: '…',
        ));
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.disableAnimationsOf(context) || _underTest;
    if (still) {
      _clock.stop();
    } else if (!_clock.isAnimating) {
      _clock.repeat();
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    for (final column in _painters) {
      for (final painter in column) {
        painter.dispose();
      }
    }
    super.dispose();
  }

  void _reportFocus(int index) {
    if (index == _focused || index < 0) return;
    _focused = index;
    final books = _columnBooks[1];
    if (books.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onFocus?.call(books[index % books.length]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _clock,
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _LibraryPainter(
            seconds: _clock.value * 3600,
            painters: _painters,
            ready: _books.isNotEmpty,
            rowHeight: _rowHeight,
            speed: _speed,
            onFocus: _reportFocus,
          ),
        ),
      ),
    );
  }
}

class _LibraryPainter extends CustomPainter {
  _LibraryPainter({
    required this.seconds,
    required this.painters,
    required this.ready,
    required this.rowHeight,
    required this.speed,
    required this.onFocus,
  });

  final double seconds;
  final List<List<TextPainter>> painters;
  final bool ready;
  final double rowHeight;
  final double speed;
  final ValueChanged<int> onFocus;

  /// Lengkung runcing seperti logo: dua busur bertemu di puncak.
  static Path archPath(Rect rect) {
    final shoulder = rect.top + rect.height * 0.42;
    return Path()
      ..moveTo(rect.left, rect.bottom)
      ..lineTo(rect.left, shoulder)
      ..cubicTo(rect.left, rect.top + rect.height * 0.2,
          rect.center.dx - rect.width * 0.2, rect.top + rect.height * 0.08,
          rect.center.dx, rect.top)
      ..cubicTo(rect.center.dx + rect.width * 0.2,
          rect.top + rect.height * 0.08, rect.right,
          rect.top + rect.height * 0.2, rect.right, shoulder)
      ..lineTo(rect.right, rect.bottom)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final archWidth = math.min(size.width * 0.78, 420.0);
    final archHeight = math.min(size.height * 0.62, archWidth * 1.25);
    final arch = Rect.fromLTWH(
      (size.width - archWidth) / 2,
      size.height * 0.07,
      archWidth,
      archHeight,
    );
    final path = archPath(arch);

    canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.fill
          ..color = const Color(0x0AFFFFFF));

    if (ready) {
      canvas.save();
      canvas.clipPath(path);
      final columnWidth = (arch.width - 48) / painters.length;
      final readingLine = arch.top + arch.height * 0.56;
      for (var c = 0; c < painters.length; c++) {
        final column = painters[c];
        if (column.isEmpty) continue;
        final loop = column.length * rowHeight;
        // Kolom bergerak dengan kecepatan sedikit berbeda (paralaks).
        final drift = seconds * speed * (1 + c * 0.22) + c * rowHeight * 0.5;
        final right = arch.left + 24 + columnWidth * (c + 1) - 8;
        for (var i = 0; i < column.length; i++) {
          var y = arch.bottom - ((drift + i * rowHeight) % loop);
          if (y < arch.top - rowHeight) y += loop;
          if (y > arch.bottom || y < arch.top - rowHeight) continue;
          final painter = column[i]..layout(maxWidth: columnWidth - 8);
          final distance = (y + rowHeight / 2 - readingLine).abs();
          final glow = c == 1
              ? (1 - (distance / rowHeight)).clamp(0.0, 1.0)
              : 0.0;
          if (c == 1 && glow > 0.5) onFocus(i);
          // Memudar di tepi atas dan bawah jendela lengkung.
          final edge = math.min(
                  (y - arch.top) / 90, (arch.bottom - y - rowHeight) / 70)
              .clamp(0.0, 1.0);
          final opacity = (0.16 + glow * 0.8) * edge;
          if (opacity <= 0.01) continue;
          final offset = Offset(right - painter.width, y);
          canvas.saveLayer(
              Rect.fromLTWH(offset.dx, y, painter.width, rowHeight),
              Paint()..color = Color.fromRGBO(255, 255, 255, opacity));
          painter.paint(canvas, offset);
          canvas.restore();
          if (glow > 0) {
            final lineY = y + painter.height + 2;
            canvas.drawLine(
              Offset(right, lineY),
              Offset(right - painter.width * Curves.easeOut.transform(glow),
                  lineY),
              Paint()
                ..strokeWidth = 1
                ..color = Color.fromRGBO(255, 255, 255, 0.7 * glow * edge),
            );
          }
        }
      }
      canvas.restore();
    }

    canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = const Color(0x2EFFFFFF));
  }

  @override
  bool shouldRepaint(_LibraryPainter oldDelegate) =>
      oldDelegate.seconds != seconds || oldDelegate.ready != ready;
}
