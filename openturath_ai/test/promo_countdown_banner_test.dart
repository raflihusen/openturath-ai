import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/localization.dart';
import 'package:openturath_ai/screens/subscription_screen.dart';

void main() {
  setUp(() {
    AppConfig.localeNotifier.value = 'id';
  });

  group('PromoCountdownBanner', () {
    testWidgets('renders minimalist red countdown banner in Dark theme',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          locale: const Locale('id'),
          supportedLocales: Loc.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: const Scaffold(
            body: Center(
              child: PromoCountdownBanner(),
            ),
          ),
        ),
      );

      await tester.pump();

      // Check header title and pill
      expect(find.text('MENUJU PELUNCURAN PROMO 10 HARI'), findsOneWidget);
      expect(find.text('MULAI JUMAT 12:00 WIB'), findsOneWidget);

      // Check units
      expect(find.text('HARI'), findsOneWidget);
      expect(find.text('JAM'), findsOneWidget);
      expect(find.text('MENIT'), findsOneWidget);
      expect(find.text('DETIK'), findsOneWidget);

      // Check footer info
      expect(
        find.textContaining('Mulai Jumat, 23 Okt · 12:00 WIB'),
        findsOneWidget,
      );

      // Advance 1 second to verify timer ticks without crash
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('renders minimalist red countdown banner in Light theme',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          locale: const Locale('id'),
          supportedLocales: Loc.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: const Scaffold(
            body: Center(
              child: PromoCountdownBanner(),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('MENUJU PELUNCURAN PROMO 10 HARI'), findsOneWidget);
      expect(find.text('MULAI JUMAT 12:00 WIB'), findsOneWidget);
      expect(find.text('HARI'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('renders properly with English locale', (tester) async {
      AppConfig.localeNotifier.value = 'en';

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          locale: const Locale('en'),
          supportedLocales: Loc.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: const Scaffold(
            body: Center(
              child: PromoCountdownBanner(),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('10-DAY PROMO LAUNCH COUNTDOWN'), findsOneWidget);
      expect(find.text('STARTS FRI 12:00 WIB'), findsOneWidget);
      expect(find.text('DAYS'), findsOneWidget);
      expect(find.text('HOURS'), findsOneWidget);
      expect(find.text('MINUTES'), findsOneWidget);
      expect(find.text('SECONDS'), findsOneWidget);
      expect(
        find.textContaining('Starts Friday, Oct 23 · 12:00 WIB'),
        findsOneWidget,
      );

      await tester.pump(const Duration(seconds: 1));
    });
  });
}
