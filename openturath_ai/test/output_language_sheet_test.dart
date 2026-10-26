import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/widgets/output_language_sheet.dart';

void main() {
  testWidgets('memilih bahasa memanggil penukar dan menutup lembar',
      (tester) async {
    OutputLanguage? chosen;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => showOutputLanguageSheet(
              context,
              current: 'id',
              onSelect: (language) async {
                chosen = language;
                return true;
              },
            ),
            child: const Text('buka'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('buka'));
    await tester.pumpAndSettle();
    expect(find.text('Bahasa Indonesia'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(chosen?.code, 'en');
    expect(chosen?.aliases.first, 'english (united states)');
    expect(find.text('English'), findsNothing);
  });
}
