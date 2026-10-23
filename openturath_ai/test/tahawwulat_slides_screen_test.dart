import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/widgets/tahawwulat_slides_screen.dart';

void main() {
  testWidgets(
      'slide Mengenal Fikih Tahawwulat tanpa overflow (id/ar, ponsel/desktop)',
      (tester) async {
    addTearDown(() {
      tester.view.reset();
      AppConfig.localeNotifier.value = 'id';
    });
    for (final lang in ['id', 'ar']) {
      for (final width in [360.0, 1280.0]) {
        AppConfig.localeNotifier.value = lang;
        tester.view.physicalSize = Size(width, width < 600 ? 760 : 800);
        tester.view.devicePixelRatio = 1;
        await tester.pumpWidget(
            MaterialApp(home: TahawwulatSlidesScreen(onAsk: () {})));
        for (var k = 0; k < 20; k++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        var n = 0;
        while (n < 80) {
          await tester.pump(const Duration(milliseconds: 1500));
          expect(tester.takeException(), isNull,
              reason: '$lang $width slide $n');
          final btn = tester.widget<IconButton>(find.byType(IconButton).last);
          if (btn.onPressed == null) break;
          await tester.tap(find.byType(IconButton).last);
          await tester.pump(const Duration(milliseconds: 400));
          n++;
        }
        expect(n, greaterThan(40), reason: '$lang $width');
        await tester.pumpWidget(const SizedBox());
      }
    }
  });
}
