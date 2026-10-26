import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/widgets/tahawwulat_scenes.dart';

/// Menjaga deck ringkas "Mengenal Fikih Tahawwulat": ringkas, lengkap tiga
/// bahasa, dan setiap slide punya adegan yang menjelaskannya.
void main() {
  final deck =
      jsonDecode(File('assets/data/slides_mengenal.json').readAsStringSync())
          as Map<String, dynamic>;
  final slides = (deck['slides'] as List).cast<Map<String, dynamic>>();
  final bab = deck['bab'] as List;

  test('deck ringkas: sekitar 30 slide, bukan 84', () {
    expect(slides.length, inInclusiveRange(25, 40));
  });

  test('setiap slide punya adegan, dan tidak ada adegan tanpa slide', () {
    final used = slides.map((s) => s['scene'] as String).toList();
    expect(used.toSet().length, used.length, reason: 'kunci adegan ganda');
    for (final id in used) {
      expect(sceneFor(id), isNotNull, reason: 'slide $id tanpa adegan');
      expect(sceneFor(id)!.alt, isNotNull, reason: '$id tanpa teks alt');
    }
    for (var i = 1; i <= 32; i++) {
      final id = 'm${i.toString().padLeft(2, '0')}';
      expect(used.contains(id), isTrue, reason: 'adegan $id tidak dipakai');
    }
    // Adegan lama bernomor s*/n* sudah dibuang dari registri.
    for (final old in ['s1', 's24', 's53', 's79', 'n2', 'n3']) {
      expect(sceneFor(old), isNull, reason: 'adegan lama $old masih ada');
    }
  });

  test('semua bab terpakai dan urut', () {
    final babs = slides.map((s) => s['bab'] as int).toList();
    for (var i = 1; i < babs.length; i++) {
      expect(babs[i], greaterThanOrEqualTo(babs[i - 1]));
    }
    expect(babs.toSet().length, bab.length);
  });

  test('EN dan AR lengkap dan sebentuk dengan Indonesia', () {
    for (var i = 0; i < slides.length; i++) {
      final s = slides[i];
      for (final lang in ['en', 'ar']) {
        final tr = (s['i18n'] as Map)[lang] as Map<String, dynamic>?;
        expect(tr, isNotNull, reason: 'slide ${i + 1} tanpa $lang');
        if (s['kind'] == 'title') {
          expect(tr!['title'], isNotEmpty, reason: 'slide ${i + 1} $lang');
        } else {
          expect((tr!['blocks'] as List).length, (s['blocks'] as List).length,
              reason: 'slide ${i + 1} $lang jumlah blok');
        }
      }
    }
    for (final b in bab) {
      expect((b as Map)['en'], isNotEmpty);
      expect(b['ar'], isNotEmpty);
    }
  });

  test('hanya slide terakhir yang menampilkan tombol mulai', () {
    final ends = [
      for (var i = 0; i < slides.length; i++)
        if (slides[i]['end'] == true) i
    ];
    expect(ends, [slides.length - 1]);
  });

  test('ringkas: total kata di bawah 2.000 (sekitar 8 menit baca)', () {
    var words = 0;
    for (final s in slides) {
      final text = StringBuffer();
      for (final k in ['kicker', 'title', 'sub']) {
        if (s[k] != null) text.write('${s[k]} ');
      }
      for (final b in (s['blocks'] as List?) ?? const []) {
        (b as Map).forEach((_, v) => text.write('${jsonEncode(v)} '));
      }
      words += RegExp(r'\w+').allMatches(text.toString()).length;
    }
    expect(words, lessThan(2000));
  });
}
