import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Penjaga keamanan WebView: pengaturan yang tidak boleh aktif di build rilis.
///
/// Ini pemeriksaan sumber (bukan runtime) karena InAppWebView tidak bisa
/// dijalankan di tes unit. Tujuannya mencegah regresi diam-diam.
void main() {
  final files = [
    Directory('lib/screens'),
    Directory('lib/widgets'),
    Directory('lib/services'),
  ]
      .where((d) => d.existsSync())
      .expand((d) => d.listSync(recursive: true))
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  test('isInspectable tidak pernah true mentah; hanya mengikuti kDebugMode',
      () {
    final bad = <String>[];
    var seen = 0;
    for (final file in files) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.trimLeft().startsWith('//')) continue;
        if (!line.contains('isInspectable')) continue;
        seen++;
        if (!line.contains('kDebugMode')) {
          bad.add('${file.path}:${i + 1}: ${line.trim()}');
        }
      }
    }
    expect(seen, greaterThanOrEqualTo(2),
        reason: 'ruang kajian dan layar masuk Google sama-sama mengatur ini');
    expect(bad, isEmpty,
        reason: 'inspektur WebView aktif di rilis membuka DOM dan sesi');
  });
}
