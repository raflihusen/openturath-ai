import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/widgets/tahawwulat_module_screen.dart';

void main() {
  testWidgets('modul Mengenal Fikih Tahawwulat terbaca tanpa overflow',
      (tester) async {
    for (final width in [360.0, 820.0]) {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      await tester
          .pumpWidget(const MaterialApp(home: TahawwulatModuleScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(ListView), findsOneWidget);
      await tester.scrollUntilVisible(find.byType(FilledButton), 600,
          scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();
      expect(find.byType(FilledButton), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
    addTearDown(tester.view.reset);
  });
}
