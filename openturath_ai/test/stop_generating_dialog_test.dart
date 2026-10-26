import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/localization.dart';
import 'package:openturath_ai/core/theme.dart';
import 'package:openturath_ai/widgets/stop_generating_dialog.dart';

const _copy = {
  'id': ['Hentikan jawaban?', 'Hentikan', 'Lanjutkan'],
  'en': ['Stop generating?', 'Stop', 'Keep generating'],
  'ar': ['إيقاف الإنشاء؟', 'إيقاف', 'متابعة'],
};

Future<bool?> _open(WidgetTester tester, ThemeData theme,
    {required String tapText}) async {
  bool? result;
  await tester.pumpWidget(MaterialApp(
    theme: theme,
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () async =>
                result = await showStopGeneratingDialog(context),
            child: const Text('buka'),
          ),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('buka'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(tapText));
  await tester.pumpAndSettle();
  return result;
}

void main() {
  for (final entry in _copy.entries) {
    testWidgets('dialog berhenti hanya judul dan dua tombol (${entry.key})',
        (tester) async {
      AppConfig.localeNotifier.value = entry.key;
      final labels = entry.value;
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showStopGeneratingDialog(context),
              child: const Text('buka'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('buka'));
      await tester.pumpAndSettle();
      expect(Loc.tr('stopGeneratingTitle'), labels[0]);
      expect(find.text(labels[0]), findsOneWidget);
      expect(find.text(labels[1]), findsOneWidget);
      expect(find.text(labels[2]), findsOneWidget);
      // Tidak ada teks penjelas Google, hanya judul + 2 tombol.
      expect(find.byType(Text), findsNWidgets(4));
    });
  }

  testWidgets('memilih Stop mengembalikan true, terang dan gelap',
      (tester) async {
    AppConfig.localeNotifier.value = 'en';
    expect(await _open(tester, AppTheme.lightTheme, tapText: 'Stop'), isTrue);
    expect(await _open(tester, AppTheme.darkTheme, tapText: 'Stop'), isTrue);
  });

  testWidgets('Keep generating mengembalikan false', (tester) async {
    AppConfig.localeNotifier.value = 'en';
    expect(await _open(tester, AppTheme.lightTheme, tapText: 'Keep generating'),
        isFalse);
  });
}
