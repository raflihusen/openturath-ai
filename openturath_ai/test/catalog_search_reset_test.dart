import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/screens/book_catalog_screen.dart';

void main() {
  testWidgets(
      'clear cancels pending search instead of restoring the stale query',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: BookCatalogScreen(initialQuery: 'الأم'),
    ));
    await tester.enterText(find.byType(TextField), 'بحث جديد');
    await tester.tap(find.byIcon(Icons.clear_rounded));
    await tester.pump(const Duration(milliseconds: 250));
    expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text, '');
    expect(find.byIcon(Icons.clear_rounded), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
