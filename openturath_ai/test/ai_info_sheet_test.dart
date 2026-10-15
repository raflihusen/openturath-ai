import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/services/open_turath_catalog_repository.dart';
import 'package:openturath_ai/widgets/ai_info_sheet.dart';

void main() {
  final info = (jsonDecode(File('assets/data/info_ai.json').readAsStringSync()) as List)
      .cast<Map<String, dynamic>>();
  final metadata = jsonDecode(
          File('assets/data/metadata_training_seluruh_ai.json').readAsStringSync())
      as Map<String, dynamic>;

  test('info AI V9.2: 18 AI, 5.382 kitab, sama dengan metadata pustaka', () {
    expect(info.length, 18);
    expect(info.fold<int>(0, (n, e) => n + (e['isi']['jumlah_kitab'] as int)), 5382);
    expect(metadata.length, 18);
    for (final key in metadata.keys) {
      final m = AiLibraryMetadata.fromJson(key, metadata[key] as Map<String, dynamic>);
      expect(m.totalKitab, greaterThan(0), reason: key);
    }
  });

  test('setiap AI punya Tentang dan minimal 6 ide pertanyaan', () {
    for (final e in info) {
      expect((e['tentang'] as String).length, greaterThan(150), reason: e['id'] as String);
      expect((e['contoh_pertanyaan'] as List).length, greaterThanOrEqualTo(6), reason: e['id'] as String);
    }
  });

  for (final e in info) {
    testWidgets('lembar info ${e['id']} tampil tanpa galat', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: AiInfoSheet(info: e))));
      expect(find.text(e['judul'] as String), findsOneWidget);
      expect(find.text('Batasan'), findsOneWidget);
      expect(find.text('Coba tanyakan'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
