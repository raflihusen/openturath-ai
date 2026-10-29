import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/onboarding_copy.dart';
import 'package:openturath_ai/core/routes.dart';
import 'package:openturath_ai/screens/onboarding_screen.dart';
import 'package:openturath_ai/services/onboarding_gate.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
      'pengenalan lima slide tanpa overflow (id/en/ar, ponsel/desktop)',
      (tester) async {
    addTearDown(() {
      tester.view.reset();
      AppConfig.localeNotifier.value = 'id';
    });
    for (final lang in ['id', 'en', 'ar']) {
      for (final width in [360.0, 1280.0]) {
        AppConfig.localeNotifier.value = lang;
        tester.view.physicalSize = Size(width, width < 600 ? 760 : 800);
        tester.view.devicePixelRatio = 1;
        await tester.pumpWidget(
            const MaterialApp(home: OnboardingScreen(replay: true)));
        for (var page = 0; page < 5; page++) {
          for (var k = 0; k < 60; k++) {
            await tester.pump(const Duration(milliseconds: 100));
          }
          expect(tester.takeException(), isNull,
              reason: '$lang $width slide $page');
          if (page < 4) {
            await tester.tap(find.text(OnboardingCopy.next));
            await tester.pump(const Duration(milliseconds: 600));
          }
        }
        expect(find.text(OnboardingCopy.start), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
      }
    }
  });

  testWidgets('selesai menandai sudah dilihat dan menuju rute berikutnya',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    expect(await OnboardingGate.seen(), isFalse);
    await tester.pumpWidget(MaterialApp(
      onGenerateRoute: (s) => MaterialPageRoute<void>(
        settings: s,
        builder: (_) => s.name == AppRoutes.login
            ? const Text('LOGIN')
            : const OnboardingScreen(),
      ),
      initialRoute: AppRoutes.onboarding,
    ));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text(OnboardingCopy.skip));
    await tester.pump();
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('LOGIN'), findsOneWidget);
    expect(await OnboardingGate.seen(), isTrue);
  });
}
