// Penjaga konsistensi desain: `lib/screens` dan `lib/widgets` tidak boleh
// menulis nilai desain mentah. Ukuran huruf, radius, dan warna diambil dari
// token di `lib/core/design/`.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/design/ot_typography.dart';

void main() {
  final files = [Directory('lib/screens'), Directory('lib/widgets')]
      .expand((dir) => dir.listSync(recursive: true))
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList();

  List<String> offenders(RegExp pattern) => [
        for (final file in files)
          for (final (index, line) in file.readAsLinesSync().indexed)
            if (pattern.hasMatch(line) && !line.trimLeft().startsWith('//'))
              '${file.path}:${index + 1}: ${line.trim()}'
      ];

  test('skala huruf tertutup: sembilan langkah, tanpa pecahan', () {
    expect(OTFontSize.scale, [11, 12, 14, 16, 18, 20, 22, 26, 36]);
  });

  test('tidak ada fontSize berangka di layar dan widget', () {
    expect(offenders(RegExp(r'fontSize:\s*[^,;)]*?(?<![\w.])\d')), isEmpty);
  });

  test('tidak ada radius berangka di layar dan widget', () {
    expect(offenders(RegExp(r'circular\(\s*\d')), isEmpty);
  });

  test('tidak ada warna mentah di layar dan widget', () {
    expect(offenders(RegExp(r'\bColor\(0x')), isEmpty);
    expect(offenders(RegExp(r'\bColors\.(?!transparent\b)[a-zA-Z]')), isEmpty);
  });

  test('layar tidak menata tombol sendiri; varian ada di OTButtons', () {
    final screens = offenders(RegExp(r'\.styleFrom\('))
        .where((line) => line.startsWith('lib/screens'))
        .toList();
    expect(screens, isEmpty);
  });

  test('padding hanya memakai langkah skala jarak', () {
    const allowed = {0, 2, 4, 8, 12, 16, 20, 24, 32, 40, 48, 56, 64, 72, 96};
    final call = RegExp(r'EdgeInsets(?:Directional)?\.\w+\([^()]*\)');
    final number = RegExp(r'(?<![\w.])(\d+(?:\.\d+)?)(?![\w.])');
    final bad = <String>[];
    for (final file in files) {
      for (final match in call.allMatches(file.readAsStringSync())) {
        for (final value in number.allMatches(match.group(0)!)) {
          final parsed = double.parse(value.group(1)!);
          if (!allowed.contains(parsed)) {
            bad.add('${file.path}: ${match.group(0)}');
          }
        }
      }
    }
    expect(bad, isEmpty);
  });

  test('hanya tiga bobot huruf: 400, 600, 700', () {
    expect(
        offenders(RegExp(r'FontWeight\.(w[123589]00|bold|normal)\b')), isEmpty);
  });
}
