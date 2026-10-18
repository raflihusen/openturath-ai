import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/widgets/tahawwulat_introduction_sheet.dart';

PengantarNaskah _naskah() => PengantarNaskah.fromJson(
    jsonDecode(File('assets/data/pengantar_tahawwulat.json').readAsStringSync())
        as Map<String, dynamic>);

void main() {
  group('naskah pengantar', () {
    final n = _naskah();

    test('video dan naskah dibundel', () {
      expect(File(n.video).existsSync(), isTrue);
      expect(n.slide.length, greaterThanOrEqualTo(40));
    });

    test('waktu slide bersambung tanpa celah', () {
      for (var i = 1; i < n.slide.length; i++) {
        expect(n.slide[i].mulai, n.slide[i - 1].akhir, reason: n.slide[i].id);
      }
    });

    test('setiap bab punya slide, bab berurutan', () {
      expect(n.awalBab.length, n.bab.length);
      for (var i = 1; i < n.slide.length; i++) {
        expect(n.slide[i].bab, greaterThanOrEqualTo(n.slide[i - 1].bab));
      }
    });

    test('indeksPada memetakan waktu ke slide', () {
      expect(n.indeksPada(Duration.zero), 0);
      final s = n.slide[10];
      expect(n.indeksPada(s.mulai + const Duration(milliseconds: 5)), 10);
      expect(n.indeksPada(n.slide.last.akhir), n.slide.length - 1);
    });

    test('setiap ibarah menyebut sumbernya', () {
      for (final s in n.slide.where((s) => s.ibarah != null)) {
        expect(s.sumber, isNotNull, reason: s.id);
      }
    });

    test('istilah baku DESIGN.md dan tanpa tanggal/kelompok yang ditebak', () {
      final semua =
          File('assets/data/pengantar_tahawwulat.json').readAsStringSync();
      for (final kata in [
        'Hadits',
        'Aqidah',
        'komprehensif',
        'Zionis',
        'Masoneri',
        '773',
      ]) {
        expect(semua.contains(kata), isFalse, reason: kata);
      }
    });
  });

  for (final ukuran in [const Size(360, 780), const Size(1280, 860)]) {
    testWidgets('semua slide terbaca tanpa overflow pada ${ukuran.width}',
        (tester) async {
      tester.view.physicalSize = ukuran;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final n = _naskah();
      await tester.pumpWidget(MaterialApp(
          home: TahawwulatIntroductionSheet(videoEnabled: false, naskah: n)));
      await tester.pumpAndSettle();
      for (var i = 0; i < n.slide.length; i++) {
        expect(find.text(n.slide[i].judul), findsWidgets,
            reason: n.slide[i].id);
        expect(tester.takeException(), isNull, reason: n.slide[i].id);
        if (i < n.slide.length - 1) {
          await tester.tap(find.byTooltip('Slide berikutnya'));
          await tester.pumpAndSettle();
        }
      }
      expect(find.text('Selesai'), findsOneWidget);
    });
  }

  testWidgets('menu bab desktop melompat ke slide yang dipilih',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 860);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final n = _naskah();
    await tester.pumpWidget(MaterialApp(
        home: TahawwulatIntroductionSheet(videoEnabled: false, naskah: n)));
    await tester.pumpAndSettle();
    final target = n.slide.indexWhere((s) => s.id == 'empatrukun');
    await tester.tap(find.text(n.slide[target].judul).first);
    await tester.pumpAndSettle();
    expect(find.text('${target + 1} / ${n.slide.length}'), findsOneWidget);
  });
}
