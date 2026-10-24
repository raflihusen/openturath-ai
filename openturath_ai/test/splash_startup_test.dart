import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/routes.dart';
import 'package:openturath_ai/screens/splash_screen.dart';

void main() {
  Future<void> startApp(
    WidgetTester tester,
    String Function() resolveRoute,
  ) async {
    await tester.pumpWidget(MaterialApp(
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) =>
            SplashScreen(resolveInitialRoute: resolveRoute),
        AppRoutes.login: (_) => const Scaffold(body: Text('Login destination')),
        AppRoutes.dashboard: (_) =>
            const Scaffold(body: Text('Dashboard destination')),
      },
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('first launch leaves splash for login without a navigator race',
      (tester) async {
    await startApp(tester, () => AppRoutes.login);
    expect(find.text('Login destination'), findsOneWidget);
    expect(find.byType(SplashScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('restored auth routes to dashboard after mounting',
      (tester) async {
    await startApp(tester, () => AppRoutes.dashboard);
    expect(find.text('Dashboard destination'), findsOneWidget);
    expect(find.byType(SplashScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an auth read error leaves splash for the real login screen',
      (tester) async {
    await startApp(tester, () => throw StateError('Auth state unavailable'));
    expect(find.text('Login destination'), findsOneWidget);
    expect(find.byType(SplashScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ketuk melewati splash tanpa menunggu seluruh urutan',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) =>
            SplashScreen(resolveInitialRoute: () => AppRoutes.login),
        AppRoutes.login: (_) => const Scaffold(body: Text('Login destination')),
      },
    ));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(SplashScreen), findsOneWidget);
    await tester.tap(find.byType(SplashScreen));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Login destination'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('gerak dikurangi: bingkai akhir langsung, ditahan singkat',
      (tester) async {
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: MaterialApp(
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (_) =>
              SplashScreen(resolveInitialRoute: () => AppRoutes.login),
          AppRoutes.login: (_) =>
              const Scaffold(body: Text('Login destination')),
        },
      ),
    ));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(SplashScreen), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Login destination'), findsOneWidget);
  });
}
