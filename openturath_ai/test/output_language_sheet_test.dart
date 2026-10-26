import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/theme.dart';
import 'package:openturath_ai/widgets/output_language_sheet.dart';

void main() {
  group('mergeOutputLanguages', () {
    test('tiga bahasa utama selalu di atas dan tidak diulang dari halaman', () {
      final merged = mergeOutputLanguages(
          ['español', 'Indonesia', 'English', 'العربية', 'español', '日本語']);
      expect(merged.take(3).map((l) => l.code), ['id', 'en', 'ar']);
      expect(merged.skip(3).map((l) => l.label), ['español', '日本語']);
    });

    test('tanpa data halaman hanya tiga bahasa utama', () {
      expect(mergeOutputLanguages(const []).length, 3);
    });

    test('nama dari halaman dipakai apa adanya sebagai alias pencocokan', () {
      final l = mergeOutputLanguages(['español (México)']).last;
      expect(l.label, 'español (México)');
      expect(l.aliases, ['español (méxico)']);
    });
  });

  group('filterOutputLanguages', () {
    final all =
        mergeOutputLanguages(['español', 'español (México)', 'français']);
    test('mencari tanpa membedakan huruf besar/kecil', () {
      expect(filterOutputLanguages(all, 'ESPA').map((l) => l.label),
          ['español', 'español (México)']);
    });
    test('mencocokkan alias bahasa utama', () {
      expect(filterOutputLanguages(all, 'indonesian').single.code, 'id');
    });
    test('kosong mengembalikan semua', () {
      expect(filterOutputLanguages(all, '  ').length, all.length);
    });
  });

  Future<void> open(WidgetTester tester,
      {required Future<List<String>> Function()? load,
      required Future<bool> Function(OutputLanguage) onSelect}) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    AppConfig.localeNotifier.value = 'en';
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => showOutputLanguageSheet(context,
                current: 'id', onSelect: onSelect, loadPageLanguages: load),
            child: const Text('buka'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('buka'));
    await tester.pump();
  }

  testWidgets('tiga bahasa utama langsung tampil, sisanya menyusul',
      (tester) async {
    await open(tester,
        load: () async => ['español', 'Filipino'], onSelect: (_) async => true);
    expect(find.text('Bahasa Indonesia'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('español'), findsOneWidget);
    expect(find.text('Filipino'), findsOneWidget);
  });

  testWidgets('kolom cari menyaring dan menampilkan keadaan kosong',
      (tester) async {
    await open(tester,
        load: () async => ['español', 'Filipino'], onSelect: (_) async => true);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'fili');
    await tester.pump();
    expect(find.text('Filipino'), findsOneWidget);
    expect(find.text('español'), findsNothing);
    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pump();
    expect(find.text('No language found'), findsOneWidget);
  });

  testWidgets('memilih bahasa halaman mengirim nama persis', (tester) async {
    OutputLanguage? picked;
    await open(tester,
        load: () async => ['español (México)'],
        onSelect: (l) async {
          picked = l;
          return true;
        });
    await tester.pumpAndSettle();
    await tester.tap(find.text('español (México)'));
    await tester.pumpAndSettle();
    expect(picked?.label, 'español (México)');
    expect(picked?.aliases, ['español (méxico)']);
  });

  testWidgets('gagal memuat daftar tidak merusak sheet', (tester) async {
    await open(tester,
        load: () async => throw StateError('x'), onSelect: (_) async => true);
    await tester.pumpAndSettle();
    expect(find.text('Bahasa Indonesia'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
