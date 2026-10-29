import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_installer/engine/fake_engine.dart';
import 'package:openturath_installer/l10n.dart';
import 'package:openturath_installer/ui/installer_shell.dart';

Widget host(FakeInstallEngine e, String lang, {VoidCallback? onClose}) =>
    MaterialApp(
      home: Scaffold(
        body: InstallerShell(
          engine: e,
          initialLanguage: lang,
          onClose: onClose,
        ),
      ),
    );

Future<void> intro(WidgetTester t) async {
  for (var i = 0; i < 40; i++) {
    await t.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('alur penuh: sambutan, memasang, selesai, buka', (t) async {
    final e = FakeInstallEngine(total: const Duration(seconds: 2));
    var closed = false;
    await t.pumpWidget(host(e, 'id', onClose: () => closed = true));
    await intro(t);
    expect(find.text('Pasang'), findsOneWidget);
    await t.tap(find.text('Pasang'));
    await t.pump(const Duration(milliseconds: 600));
    expect(
      find.text('Memasang OpenTurath AI'),
      findsNothing,
      reason: 'status memakai tahap, bukan judul',
    );
    expect(find.textContaining('%'), findsOneWidget);
    for (var i = 0; i < 60; i++) {
      await t.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Siap digunakan.'), findsOneWidget);
    await t.tap(find.text('Buka OpenTurath'));
    await t.pump();
    expect(e.launched, 1);
    expect(closed, isTrue);
    expect(t.takeException(), isNull);
  });

  testWidgets('galat menggantikan layar dan bisa diulang', (t) async {
    final e = FakeInstallEngine(total: const Duration(seconds: 1), failAt: .5);
    await t.pumpWidget(host(e, 'en'));
    await intro(t);
    await t.tap(find.text('Install'));
    for (var i = 0; i < 30; i++) {
      await t.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Installation stopped.'), findsOneWidget);
    await t.tap(find.text('Try again'));
    await t.pump(const Duration(milliseconds: 600));
    expect(find.text('Install'), findsOneWidget);
  });

  testWidgets('bahasa berganti seketika dan Arab memakai RTL', (t) async {
    await t.pumpWidget(host(FakeInstallEngine(), 'id'));
    await intro(t);
    await t.tap(find.text('AR'));
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text('تثبيت'), findsOneWidget);
    expect(Directionality.of(t.element(find.text('تثبيت'))), TextDirection.rtl);
  });

  testWidgets('tanpa overflow di semua bahasa dan ukuran jendela', (t) async {
    addTearDown(t.view.reset);
    for (final lang in Strings.codes) {
      for (final size in [const Size(760, 540), const Size(640, 460)]) {
        t.view.physicalSize = size;
        t.view.devicePixelRatio = 1;
        await t.pumpWidget(host(FakeInstallEngine(), lang));
        await intro(t);
        expect(t.takeException(), isNull, reason: '$lang $size');
        await t.tap(find.byIcon(Icons.expand_more_rounded));
        await t.pump(const Duration(milliseconds: 500));
        expect(t.takeException(), isNull, reason: 'opsi $lang $size');
      }
    }
  });

  testWidgets('gerak dikurangi: tanda langsung penuh', (t) async {
    await t.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: host(FakeInstallEngine(), 'id'),
      ),
    );
    await t.pump(const Duration(milliseconds: 200));
    expect(find.text('Pasang'), findsOneWidget);
  });
}
