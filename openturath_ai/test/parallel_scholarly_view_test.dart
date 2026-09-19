import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/widgets/parallel_scholarly_view.dart';

void main() {
  testWidgets('preserves distinct source and commentary at narrow widths', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox(
      width: 340, child: SingleChildScrollView(child: ParallelScholarlyView(
        arabicExcerpt: 'العلم نور', commentary: 'Saved explanation',
        isAiCommentary: true))))));
    expect(find.text('العلم نور'), findsOneWidget);
    expect(find.text('Saved explanation'), findsOneWidget);
    final source = tester.widget<SelectableText>(find.widgetWithText(SelectableText, 'العلم نور'));
    expect(source.textDirection, TextDirection.rtl);
    expect(tester.takeException(), isNull);
  });
}
