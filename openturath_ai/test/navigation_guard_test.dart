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

    testWidgets('safePushNamed allows opening a child route while parent route is active on stack', (tester) async {
      int subPageOpened = 0;
      int termsPageOpened = 0;

      final testApp = MaterialApp(
        onGenerateRoute: (settings) {
          if (settings.name == '/subscription') {
            subPageOpened++;
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    // Buka child route terms dari dalam subscription
                    NavigationGuard.safePushNamed(context, '/terms');
                  },
                  child: const Text('Open Terms'),
                ),
              ),
              settings: settings,
            );
          } else if (settings.name == '/terms') {
            termsPageOpened++;
            return MaterialPageRoute(
              builder: (context) => const Scaffold(body: Text('Terms Page')),
              settings: settings,
            );
          }
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  NavigationGuard.safePushNamed(context, '/subscription');
                },
                child: const Text('Go To Subscription'),
              ),
            ),
          );
        },
      );

      await tester.pumpWidget(testApp);
      await tester.tap(find.text('Go To Subscription'));
      await tester.pumpAndSettle();

      expect(subPageOpened, equals(1));
      expect(find.text('Open Terms'), findsOneWidget);

      // Jeda transisi 450ms berlalu
      await tester.pump(const Duration(milliseconds: 500));

      // Pengguna menekan Open Terms dari dalam halaman subscription
      await tester.tap(find.text('Open Terms'));
      await tester.pumpAndSettle();

      expect(termsPageOpened, equals(1));
      expect(find.text('Terms Page'), findsOneWidget);
    });
  });
}
