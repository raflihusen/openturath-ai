import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:openturath_ai/core/l10n/language_notifier.dart';
import 'package:openturath_ai/core/l10n/app_dictionary.dart';
import 'package:openturath_ai/core/hijri_date_utils.dart';
import 'package:openturath_ai/core/daily_scholarly_gem.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('new key takes precedence and unknown persisted locale falls back safely', () async {
    SharedPreferences.setMockInitialValues({'app_locale': 'en', 'ot_preferred_language': 'ar',
      'ot_eastern_arabic_digits': true});
    final service = LocaleService.forTesting();
    await service.initialize();
    expect(service.current.language, AppLanguage.ar);
    expect(service.current.easternArabicDigits, isTrue);
    SharedPreferences.setMockInitialValues({'ot_preferred_language': '../../bad'});
    final invalid = LocaleService.forTesting();
    await invalid.initialize();
    expect(invalid.current.language, AppLanguage.id);
  });

  test('slow hydration cannot overwrite a hot switch; writes preserve last choice', () async {
    SharedPreferences.setMockInitialValues({'ot_preferred_language': 'id'});
    final service = LocaleService.forTesting();
    final loading = service.initialize();
    final first = service.update(language: AppLanguage.en);
    final last = service.update(language: AppLanguage.ar, easternArabicDigits: true);
    expect(service.current.language, AppLanguage.ar);
    await loading;
    expect(await first, isTrue);
    expect(await last, isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(LocaleService.languageKey), 'ar');
    expect(prefs.getBool(LocaleService.digitsKey), isTrue);
  });

  testWidgets('live route preserves local state while language and numeral direction change', (tester) async {
    final service = LocaleService.forTesting();
    final container = ProviderContainer(overrides: [
      languageProvider.overrideWith((ref) => LanguageNotifier(service)),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: Consumer(
      builder: (context, ref, _) {
        final locale = ref.watch(languageProvider);
        return MaterialApp(locale: Locale(locale.languageCode),
          supportedLocales: const [Locale('id'), Locale('en'), Locale('ar')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          builder: (context, child) => AppLocaleScope(locale: locale,
            child: Directionality(textDirection: locale.isArabic ? TextDirection.rtl : TextDirection.ltr,
              child: child!)), home: const _RetainedCounter());
      })));
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    await service.update(language: AppLanguage.ar);
    await tester.pumpAndSettle();
    expect(Directionality.of(tester.element(find.byType(FilledButton))), TextDirection.rtl);
    await service.update(easternArabicDigits: true);
    await tester.pumpAndSettle();
    expect(find.text('١'), findsOneWidget);
    expect(find.text(AppDictionary.translate('shell.home', 'ar')), findsOneWidget);
    await service.update(language: AppLanguage.en);
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
    expect(Directionality.of(tester.element(find.byType(FilledButton))), TextDirection.ltr);
  });

  test('Hijri formatter matches three languages and English ordinal exceptions', () {
    String f(int d, String code, [bool eastern = false]) => HijriDateUtils.formatHijri(
      day: d, month: 9, year: 1447, languageCode: code, easternArabicDigits: eastern);
    expect(f(17, 'id'), '17 Ramadan 1447 H');
    expect(f(17, 'en'), '17th Ramadan 1447 AH');
    expect(f(17, 'ar', true), '١٧ رمضان ١٤٤٧ هـ');
    expect(f(11, 'en'), startsWith('11th'));
    expect(f(12, 'en'), startsWith('12th'));
    expect(f(13, 'en'), startsWith('13th'));
    expect(f(21, 'en'), startsWith('21st'));
    expect(() => HijriDateUtils.formatHijri(day: 0, month: 9, year: 1447), throwsArgumentError);
  });

  test('daily curated excerpt remains stable within a calendar day and includes its source', () {
    final first = DailyScholarlyGem.forDate(DateTime(2026, 9, 19, 1));
    final same = DailyScholarlyGem.forDate(DateTime(2026, 9, 19, 23));
    final next = DailyScholarlyGem.forDate(DateTime(2026, 9, 20));
    expect(first.id, same.id);
    expect(first.id, isNot(next.id));
    expect(first.copyWithSanad('ar'), contains(first.sanad));
    expect(first.copyWithSanad('en'), contains(first.sourceUrl));
  });
}
class _RetainedCounter extends StatefulWidget {
  const _RetainedCounter();
  @override
  State<_RetainedCounter> createState() => _RetainedCounterState();
}
class _RetainedCounterState extends State<_RetainedCounter> {
  int count = 0;
  @override
  Widget build(BuildContext context) => Scaffold(body: Column(children: [
    Text(context.tr('shell.home')),
    FilledButton(onPressed: () => setState(() => count++), child: Text(context.uiNumber(count))),
  ]));
}
