import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_inappwebview_windows/src/in_app_webview/windows_scroll_processor.dart';

void main() {
  group('WindowsTouchpadScrollProcessor', () {
    test('vertical touchpad scroll with horizontal micro-drift never emits horizontal wheel', () {
      final processor = WindowsTouchpadScrollProcessor();
      processor.onPanZoomStart();

      double totalY = 0;
      for (int i = 0; i < 10; i++) {
        final res = processor.processPanZoomUpdate(dx: 0.9, dy: -6.0);
        expect(res, isNotNull);
        expect(res!.dx, 0.0, reason: 'horizontal drift must not trigger HORIZONTAL_WHEEL');
        expect(res.dy, lessThan(0.0), reason: 'two-finger swipe up scrolls content down');
        totalY += res.dy;
      }

      expect(processor.axisLock, WindowsScrollAxisLock.vertical);
      expect(totalY, lessThan(-15.0));
    });

    test('intentional horizontal touchpad swipe locks horizontal and uses correct WM_MOUSEHWHEEL sign', () {
      final processor = WindowsTouchpadScrollProcessor();
      processor.onPanZoomStart();

      // Swiping two fingers left (dx < 0) moves viewport right (WM_MOUSEHWHEEL > 0).
      final res = processor.processPanZoomUpdate(dx: -12.0, dy: 1.5);
      expect(res, isNotNull);
      expect(processor.axisLock, WindowsScrollAxisLock.horizontal);
      expect(res!.dy, 0.0);
      expect(res.dx, greaterThan(0.0));
    });

    test('sub-pixel 120Hz touchpad frames accumulate instead of truncating to zero', () {
      final processor = WindowsTouchpadScrollProcessor();
      processor.onPanZoomStart();

      int emittedCount = 0;
      double totalWheelUnits = 0;
      // 0.12 px per frame * 0.28 * 6 = 0.2016 wheel units per frame (< 1).
      // Over 20 frames -> ~4.03 wheel units, must emit multiple non-zero scrolls.
      for (int i = 0; i < 20; i++) {
        final res = processor.processPanZoomUpdate(dx: 0.02, dy: -0.12);
        if (res != null) {
          emittedCount++;
          expect(res.dx, 0.0);
          totalWheelUnits += res.dy * WindowsTouchpadScrollProcessor.cppWheelMultiplier;
        }
      }

      expect(emittedCount, greaterThanOrEqualTo(3));
      expect(totalWheelUnits, closeTo(-4.0, 0.5));
    });

    test('pinch-to-zoom gestures (scale != 1.0) are ignored', () {
      final processor = WindowsTouchpadScrollProcessor();
      processor.onPanZoomStart();

      expect(
        processor.processPanZoomUpdate(dx: 3.0, dy: -15.0, scale: 1.15),
        isNull,
      );
      expect(
        processor.processPanZoomUpdate(dx: -3.0, dy: 15.0, scale: 0.85),
        isNull,
      );
    });

    test('extreme fast flicks are safely clamped below int16_t overflow limit', () {
      final processor = WindowsTouchpadScrollProcessor();
      processor.onPanZoomStart();

      final res = processor.processPanZoomUpdate(dx: 0.0, dy: -200000.0);
      expect(res, isNotNull);
      expect(
        (res!.dy * WindowsTouchpadScrollProcessor.cppWheelMultiplier).abs(),
        lessThanOrEqualTo(30000.0),
      );
    });

    test('legacy PointerScrollEvent filters diagonal drift and maps both axes correctly', () {
      final processor = WindowsTouchpadScrollProcessor();

      // Mouse wheel / legacy Synaptics scroll down (dy > 0) with minor dx drift
      final down = processor.processPointerScroll(dx: 1.5, dy: 20.0);
      expect(down, isNotNull);
      expect(down!.dx, 0.0);
      expect(down.dy, closeTo(-20.0, 0.001));

      // Horizontal scroll right (dx > 0) -> positive WM_MOUSEHWHEEL
      final right = processor.processPointerScroll(dx: 20.0, dy: 0.0);
      expect(right, isNotNull);
      expect(right!.dy, 0.0);
      expect(right.dx, closeTo(20.0, 0.001));
    });

    test('non-finite inputs are ignored safely', () {
      final processor = WindowsTouchpadScrollProcessor();
      expect(processor.processPanZoomUpdate(dx: double.nan, dy: -5.0), isNull);
      expect(processor.processPointerScroll(dx: 0.0, dy: double.infinity), isNull);
    });
  });
}
