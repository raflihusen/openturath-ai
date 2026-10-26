import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/theme.dart';
import 'package:openturath_ai/widgets/ot_popup_menu.dart';

Widget _app(ThemeData theme, ValueChanged<String> onSelected) => MaterialApp(
      theme: theme,
      home: Scaffold(
        body: Center(
          child: PopupMenuButton<String>(
            onSelected: onSelected,
            itemBuilder: (_) => const [
              OTPopupMenuItem(value: 'a', child: Text('Satu')),
              OTPopupMenuItem(value: 'b', child: Text('Dua')),
            ],
          ),
        ),
      ),
    );

void main() {
  for (final entry in {
    'terang': AppTheme.lightTheme,
    'gelap': AppTheme.darkTheme,
  }.entries) {
    testWidgets('item menu memilih nilai dan menyorot membulat (${entry.key})',
        (tester) async {
      String? picked;
      await tester.pumpWidget(_app(entry.value, (v) => picked = v));
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      expect(find.text('Satu'), findsOneWidget);

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.text('Satu')));
      await tester.pump();
      final ink = tester.widget<InkWell>(find
          .ancestor(of: find.text('Satu'), matching: find.byType(InkWell))
          .first);
      expect(ink.borderRadius, isNotNull);
      expect(ink.hoverColor, isNotNull);

      await tester.tap(find.text('Dua'));
      await tester.pumpAndSettle();
      expect(picked, 'b');
    });
  }
}
