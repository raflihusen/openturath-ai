import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/localization.dart';
import 'package:openturath_ai/screens/subscription_screen.dart';

DateTime _beforeLaunch() => DateTime.utc(2026, 10, 20, 5);
DateTime _duringOffer() => DateTime.utc(2026, 10, 25, 5);
DateTime _afterOffer() => DateTime.utc(2026, 11, 3);

void main() {
  setUp(() {
    AppConfig.localeNotifier.value = 'id';
  });

  group('PromoCountdownBanner', () {
    testWidgets(
        'renders ultra-minimalist solid red countdown banner in Dark theme',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          locale: const Locale('id'),
          supportedLocales: Loc.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: const Scaffold(
            body: Center(
              child: PromoCountdownBanner(clock: _beforeLaunch),
            ),
          ),
        ),
      );

      await tester.pump();

      // Check header title
      expect(find.text('MENUJU PELUNCURAN PROMO 10 HARI'), findsOneWidget);

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

      // Verify solid red container background (100% opacity)
      final container = tester.widget<Container>(find.descendant(
        of: find.byType(PromoCountdownBanner),
        matching: find.byType(Container),
      ));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, const Color(0xFFB91C1C));

      // Advance 1 second to verify timer ticks without crash
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets(
        'renders ultra-minimalist solid red countdown banner in Light theme',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          locale: const Locale('id'),
          supportedLocales: Loc.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: const Scaffold(
            body: Center(
              child: PromoCountdownBanner(clock: _beforeLaunch),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('MENUJU PELUNCURAN PROMO 10 HARI'), findsOneWidget);
      expect(find.text('HARI'), findsOneWidget);

      final container = tester.widget<Container>(find.descendant(
        of: find.byType(PromoCountdownBanner),
        matching: find.byType(Container),
      ));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, const Color(0xFFB91C1C));

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
              child: PromoCountdownBanner(clock: _beforeLaunch),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('10-DAY PROMO LAUNCH COUNTDOWN'), findsOneWidget);
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
    testWidgets('shows the live offer and the ended state by the clock',
        (tester) async {
      Future<void> pumpAt(DateTime Function() clock) async {
        await tester.pumpWidget(MaterialApp(
          theme: ThemeData.light(),
          locale: const Locale('id'),
          supportedLocales: Loc.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home:
              Scaffold(body: Center(child: PromoCountdownBanner(clock: clock))),
        ));
        await tester.pump();
      }

      await pumpAt(_duringOffer);
      expect(find.text('PENAWARAN PERDANA TERBATAS (10 HARI)'), findsOneWidget);
      expect(find.textContaining('Berakhir Senin, 2 Nov'), findsOneWidget);

      await pumpAt(_afterOffer);
      expect(find.text('PENAWARAN PERDANA TELAH SELESAI'), findsOneWidget);
      expect(find.text('00'), findsNWidgets(4));
    });
  });
}
