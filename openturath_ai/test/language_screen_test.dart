import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/routes.dart';
import 'package:openturath_ai/screens/language_screen.dart';
import 'package:openturath_ai/services/language_gate.dart';
import 'package:openturath_ai/services/onboarding_gate.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(() => AppConfig.localeNotifier.value = 'id');

  test('usulan bahasa mengikuti perangkat: ar, id, selain itu en', () {
    expect(LanguageGate.suggest(const ui.Locale('ar', 'SA')), 'ar');
    expect(LanguageGate.suggest(const ui.Locale('id', 'ID')), 'id');
    expect(LanguageGate.suggest(const ui.Locale('fr', 'FR')), 'en');
  });

  test(
      'pemasangan baru belum memilih; pengguna lama yang menyimpan bahasa dianggap sudah',
      () async {
    expect(await LanguageGate.chosen(), isFalse);
    SharedPreferences.setMockInitialValues({'app_locale': 'en'});
    expect(await LanguageGate.chosen(), isTrue);
    SharedPreferences.setMockInitialValues({});
    await LanguageGate.markChosen();
    expect(await LanguageGate.chosen(), isTrue);
  });

  Widget app() => MaterialApp(
        home: const LanguageScreen(),
        routes: {
          AppRoutes.onboarding: (_) =>
              const Scaffold(body: Text('Onboarding destination')),
          AppRoutes.login: (_) =>
              const Scaffold(body: Text('Login destination')),
        },
      );

  testWidgets('memilih bahasa lalu lanjut ke pengenalan, bukan langsung login',
      (tester) async {
    await tester.pumpWidget(app());
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('language-ar')));
    await tester.pump();
    expect(AppConfig.localeNotifier.value, 'ar');
    await tester.tap(find.byKey(const ValueKey('language-continue')));
    await tester.pumpAndSettle();
    expect(find.text('Onboarding destination'), findsOneWidget);
    expect(await LanguageGate.chosen(), isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('bila pengenalan sudah dilihat, langsung ke tujuan',
      (tester) async {
    await OnboardingGate.markSeen();
    await tester.pumpWidget(app());
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('language-continue')));
    await tester.pumpAndSettle();
    expect(find.text('Login destination'), findsOneWidget);
  });

  testWidgets('tanpa overflow di ponsel kecil dan desktop', (tester) async {
    addTearDown(tester.view.reset);
    for (final size in [const Size(320, 560), const Size(1280, 800)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(app());
      await tester.pump();
      expect(tester.takeException(), isNull, reason: '$size');
    }
  });
}
