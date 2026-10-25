import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/constants.dart';
import 'package:openturath_ai/core/localization.dart';
import 'package:openturath_ai/core/theme.dart';
import 'package:openturath_ai/models/user_model.dart';
import 'package:openturath_ai/screens/subscription_screen.dart';
import 'package:openturath_ai/services/auth_service.dart';

void main() {
  testWidgets(
      'Langganan tanpa overflow di lima lebar, dua skala teks, tiga bahasa, '
      'dua tema; harga tidak pecah dan lima asisten tampil rapat',
      (tester) async {
    addTearDown(() {
      tester.view.reset();
      AppConfig.localeNotifier.value = 'id';
      AuthService.previewUser = null;
    });
    AuthService.previewUser = UserModel(
      uid: 'Qx7Zp2LmN8vRt4Kc',
      name: 'Rafli Husen',
      email: 'contoh@openturath.id',
      photoUrl: '',
      plan: AppConstants.planTrial,
      questionsUsed: 0,
    );
    for (final locale in ['id', 'en', 'ar']) {
      for (final dark in [false, true]) {
        for (final width in [320.0, 390.0, 850.0, 980.0, 1280.0]) {
          for (final scale in [1.0, 1.6]) {
            final reason = '$locale dark=$dark w=$width x$scale';
            AppConfig.localeNotifier.value = locale;
            tester.view.physicalSize = Size(width, 2600);
            tester.view.devicePixelRatio = 1;
            await tester.pumpWidget(MaterialApp(
              key: ValueKey(reason),
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: dark ? ThemeMode.dark : ThemeMode.light,
              locale: Locale(locale),
              supportedLocales: Loc.supportedLocales,
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.linear(scale)),
                  child: LocaleScope(child: child!)),
              home: const SubscriptionScreen(),
            ));
            await tester.runAsync(
                () => Future<void>.delayed(const Duration(milliseconds: 80)));
            for (var k = 0; k < 6; k++) {
              await tester.pump(const Duration(milliseconds: 300));
            }
            expect(tester.takeException(), isNull, reason: reason);
            // Dua tombol bayar (paket utama dan satu bidang).
            expect(find.byType(FilledButton), findsNWidgets(2), reason: reason);
            // Kedua kartu punya satu baris pilihan yang simetris; paket utama
            // menyebut "lima asisten" tanpa mendaftar namanya.
            expect(
                find.text(locale == 'ar'
                    ? 'خمسة مساعدين'
                    : locale == 'en'
                        ? 'Five AI assistants'
                        : 'Lima asisten AI'),
                findsOneWidget,
                reason: reason);
            expect(find.textContaining('Al-Muhaqqiq'), findsNothing,
                reason: reason);
          }
        }
      }
    }
  });

  testWidgets('pengguna aktif melihat Aktif dan Perpanjang akses',
      (tester) async {
    addTearDown(() {
      tester.view.reset();
      AuthService.previewUser = null;
    });
    AuthService.previewUser = UserModel(
      uid: 'Qx7Zp2LmN8vRt4Kc',
      name: 'Rafli Husen',
      email: 'contoh@openturath.id',
      photoUrl: '',
      plan: 'bahits_1y',
      questionsUsed: 0,
      entitlements: {
        'fiqh_tahawwulat': ModuleEntitlement(
          plan: 'bahits_1y',
          expiry: DateTime.now().add(const Duration(days: 90)),
        ),
      },
    );
    tester.view.physicalSize = const Size(980, 2000);
    tester.view.devicePixelRatio = 1;
    AppConfig.localeNotifier.value = 'id';
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      locale: const Locale('id'),
      supportedLocales: Loc.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) => LocaleScope(child: child!),
      home: const SubscriptionScreen(),
    ));
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 80)));
    for (var k = 0; k < 6; k++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    expect(tester.takeException(), isNull);
    expect(find.text('Perpanjang akses'), findsOneWidget);
    expect(find.text('AKTIF'), findsOneWidget);
  });
}
