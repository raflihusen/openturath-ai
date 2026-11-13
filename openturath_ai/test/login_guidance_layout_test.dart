import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/app_copy.dart';
import 'package:openturath_ai/core/localization.dart';
import 'package:openturath_ai/core/theme.dart';
import 'package:openturath_ai/models/user_model.dart';
import 'package:openturath_ai/screens/login_screen.dart';
import 'package:openturath_ai/screens/google_session_auth_screen.dart';
import 'package:openturath_ai/services/auth_service.dart';
import 'package:openturath_ai/widgets/login_guidance.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AuthService.previewUser = UserModel(
        uid: 'reader',
        name: 'Reader',
        email: 'reader@example.invalid',
        photoUrl: '',
        plan: 'trial',
        questionsUsed: 0);
  });
  tearDown(() => AuthService.previewUser = null);

  Widget host(Widget child, String locale, double scale) => MaterialApp(
        theme: AppTheme.lightTheme,
        locale: Locale(locale),
        supportedLocales: Loc.supportedLocales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        builder: (context, page) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(scale)),
            child: Directionality(
                textDirection:
                    locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                child: page!)),
        home: child,
      );

  for (final locale in ['id', 'en', 'ar']) {
    for (final size in [
      const Size(320, 640),
      const Size(390, 844),
      const Size(1280, 800)
    ]) {
      for (final scale in [1.0, 1.4]) {
        testWidgets('login screen fits $locale $size text $scale',
            (tester) async {
          AppConfig.localeNotifier.value = locale;
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          await tester.pumpWidget(host(const LoginScreen(), locale, scale));
          await tester.pump(const Duration(seconds: 2));
          expect(find.text(Loc.tr('loginTitle')), findsOneWidget);
          expect(find.text(AppCopy.continueWithGoogle), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
        });
        testWidgets('second login remains usable $locale $size text $scale',
            (tester) async {
          AppConfig.localeNotifier.value = locale;
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          await tester.pumpWidget(host(
              GoogleSessionAuthScreen(
                  webViewBuilder: (_, settings, url) =>
                      const SizedBox(key: Key('google-page'))),
              locale,
              scale));
          await tester.pump(const Duration(seconds: 1));
          expect(find.byKey(const Key('google-page')), findsOneWidget);
          expect(tester.getSize(find.byKey(const Key('google-page'))).height,
              greaterThan(100));
          expect(find.text(Loc.tr('loginGoogleSecurityShort')), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
        });
      }
    }
    testWidgets('privacy explanation and real policy can be opened $locale',
        (tester) async {
      AppConfig.localeNotifier.value = locale;
      await tester.pumpWidget(host(
          const Scaffold(body: SingleChildScrollView(child: LoginGuidance())),
          locale,
          1));
      await tester.tap(find.text(Loc.tr('loginGuidanceDetails')));
      await tester.pumpAndSettle();
      final facts = find.text(Loc.tr('loginPrivacyFacts'));
      await tester.ensureVisible(facts);
      expect(facts, findsOneWidget);
      final policy = find.text(Loc.tr('privacyPolicy'));
      await tester.ensureVisible(policy);
      await tester.tap(policy);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
