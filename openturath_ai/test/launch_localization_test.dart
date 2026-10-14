import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/app_copy.dart';
import 'package:openturath_ai/core/book_study_level.dart';
import 'package:openturath_ai/core/copy_catalog.dart';
import 'package:openturath_ai/core/design/ot_typography.dart';
import 'package:openturath_ai/core/localization.dart';
import 'package:openturath_ai/core/product_pricing.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/widgets/promo_price.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppConfig.localeNotifier.value = 'id';
    OTTypography.useSystemFontFallback = true;
  });
  tearDown(() {
    AppConfig.localeNotifier.value = 'id';
    OTTypography.useSystemFontFallback = false;
  });
  test('every copy entry has three translations with identical placeholders', () {
    final placeholder = RegExp(r'\{\d+\}');
    for (final entry in copyCatalog.entries) {
      expect(entry.value.length, 3, reason: entry.key);
      final expected = placeholder.allMatches(entry.value.first).map((m) => m[0]).toSet();
      for (final text in entry.value) {
        expect(text.trim(), isNotEmpty, reason: entry.key);
        expect(placeholder.allMatches(text).map((m) => m[0]).toSet(), expected, reason: entry.key);
      }
    }
  });
  test('language survives reinitialization and invalid persisted values are rejected', () async {
    await AppConfig.setLocale('ar');
    AppConfig.localeNotifier.value = 'id';
    await AppConfig.init();
    expect(AppConfig.localeNotifier.value, 'ar');
    expect(AppCopy.navHome, 'الرئيسية');
    await AppConfig.setLocale('unsupported');
    expect(AppConfig.localeNotifier.value, 'ar');
  });
  test('unknown classifications stay unknown rather than being inferred from a title', () {
    expect(BookStudyLevel.fromMetadata('hashiyah'), BookStudyLevel.hashiyah);
    expect(BookStudyLevel.fromMetadata('A Commentary on Trade'), BookStudyLevel.unclassified);
    expect(BookStudyLevel.fromMetadata(''), BookStudyLevel.unclassified);
  });
  test('catalog exposes 17 independent disciplines plus Tahawwulat', () {
    final disciplines = AgentModel.defaultAgents.where((a) => a.kind == CorpusKind.discipline);
    expect(disciplines.where((a) => a.id != 'fiqh_tahawwulat').length, 17);
    expect(disciplines.where((a) => a.id == 'fiqh_tahawwulat').length, 1);
  });
  testWidgets('Arabic price and English labels rebuild without remounting the screen', (tester) async {
    await tester.pumpWidget(ValueListenableBuilder<String>(valueListenable: AppConfig.localeNotifier,
      builder: (_, language, __) => MaterialApp(locale: Locale(language),
        supportedLocales: Loc.supportedLocales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        builder: (_, child) => LocaleScope(child: child!),
        home: const Scaffold(body: PromoPrice(amount: 50000, regularAmount: 300000)),
      )));
    expect(find.text('Rp 300.000'), findsOneWidget);
    await AppConfig.setLocale('ar');
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(PromoPrice));
    expect(Directionality.of(context), TextDirection.rtl);
    expect(find.textContaining('توفير'), findsOneWidget);
    await AppConfig.setLocale('en');
    await tester.pumpAndSettle();
    expect(find.textContaining('Save 83%'), findsOneWidget);
    expect(find.text('Rp 50.000'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  test('annual Tahawwulat discount is derived from the actual amounts', () {
    final annual = ProductPricing.tahawwulat.last;
    expect(annual.amount, 1999000);
    expect(annual.regularAmount, 4995000);
    expect(annual.savingsPercent, 60);
  });
}
