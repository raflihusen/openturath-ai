import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/navigation_guard.dart';

void main() {
  setUp(() {
    NavigationGuard.resetForTesting();
  });

  group('NavigationGuard Single-Flight Tests', () {
    testWidgets('safePushNamed ignores concurrent duplicate navigation calls', (tester) async {
      int pushCallCount = 0;

      final testApp = MaterialApp(
        onGenerateRoute: (settings) {
          if (settings.name == '/test_sub') {
            pushCallCount++;
            return MaterialPageRoute(
              builder: (context) => const Scaffold(body: Text('Subscription Page')),
              settings: settings,
            );
          }
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Simulasikan 3 kali tap bersamaan saat lag
                    NavigationGuard.safePushNamed(context, '/test_sub');
                    NavigationGuard.safePushNamed(context, '/test_sub');
                    NavigationGuard.safePushNamed(context, '/test_sub');
                  },
                  child: const Text('Upgrade'),
                ),
              ),
            ),
          );
        },
      );

      await tester.pumpWidget(testApp);
      await tester.tap(find.text('Upgrade'));
      await tester.pumpAndSettle();

      expect(find.text('Subscription Page'), findsOneWidget);
      // Tepat 1 kali navigasi diproses, 2 panggilan duplikat lainnya diabaikan!
      expect(pushCallCount, equals(1));
    });

    testWidgets('safeNavigate executes only one action during concurrent invocations', (tester) async {
      int actionCount = 0;

      final testApp = MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                for (int i = 0; i < 5; i++) {
                  NavigationGuard.safeNavigate(context, () async {
                    await Future.delayed(const Duration(milliseconds: 50));
                    actionCount++;
                    return true;
                  });
                }
              },
              child: const Text('Concurrent Action'),
            );
          },
        ),
      );

      await tester.pumpWidget(testApp);
      await tester.tap(find.text('Concurrent Action'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(actionCount, equals(1));
    });
  });
}
