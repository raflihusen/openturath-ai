import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openturath_ai/widgets/ot_interactive.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('Holistic Tactile & Interactive Animation Suite', () {
    testWidgets('OtTactileCard renders child and animates scale on tap down and up', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: OtTactileCard(
                onTap: () => tapped = true,
                pressedScale: 0.95,
                child: const Text('Test Card'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Card'), findsOneWidget);

      // Verify initial scale is 1.0
      Transform transform = tester.widget(find.descendant(of: find.byType(OtTactileCard), matching: find.byType(Transform)).first);
      expect(transform.transform.getMaxScaleOnAxis(), 1.0);

      // Tap Down (simulate user pressing finger on screen)
      final gesture = await tester.startGesture(tester.getCenter(find.text('Test Card')));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 200));

      // After press duration, scale should compress to pressedScale
      final dynamic state = tester.state(find.byType(OtTactileCard));
      expect(state.debugScaleValue, closeTo(0.95, 0.01));

      // Release finger
      await gesture.up();
      await tester.pumpAndSettle();

      expect(tapped, isTrue);

      // Verify returns to 1.0
      expect(state.debugScaleValue, closeTo(1.0, 0.001));
    });

    testWidgets('OtInteractiveButton wraps button and triggers onPressed', (tester) async {
      int count = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: OtInteractiveButton(
                onPressed: () => count++,
                child: const Text('Interactive CTA'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Interactive CTA'), findsOneWidget);

      await tester.tap(find.text('Interactive CTA'));
      await tester.pumpAndSettle();

      expect(count, 1);
    });

    testWidgets('OtCopyMorphButton copies text and morphs from copy icon to checkmark', (tester) async {
      // Mock clipboard system channel
      final List<MethodCall> log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (MethodCall methodCall) async {
        log.add(methodCall);
        if (methodCall.method == 'Clipboard.setData') {
          return null;
        }
        return null;
      });

      bool onCopiedCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: OtCopyMorphButton(
                textToCopy: 'Kutipan Ibnu Hajar Al-Asqalani',
                onCopied: () => onCopiedCalled = true,
              ),
            ),
          ),
        ),
      );

      // Initially shows copy icon
      expect(find.byKey(const ValueKey('copy')), findsOneWidget);
      expect(find.byKey(const ValueKey('check')), findsNothing);

      // Tap the copy button
      await tester.tap(find.byType(OtCopyMorphButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(onCopiedCalled, isTrue);

      // Should have morphed to checkmark icon
      expect(find.byKey(const ValueKey('check')), findsOneWidget);
      expect(find.byKey(const ValueKey('copy')), findsNothing);

      // Wait for 1.8s timeout
      await tester.pump(const Duration(milliseconds: 1900));
      await tester.pumpAndSettle();

      // Should return to copy icon
      expect(find.byKey(const ValueKey('copy')), findsOneWidget);
      expect(find.byKey(const ValueKey('check')), findsNothing);
    });
  });
}
