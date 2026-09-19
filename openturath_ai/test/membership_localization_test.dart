import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openturath_ai/core/design/ot_typography.dart';
import 'package:openturath_ai/core/l10n/app_dictionary.dart';
import 'package:openturath_ai/core/l10n/membership_dictionary.dart';
import 'package:openturath_ai/widgets/specialist_card.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    OTTypography.useSystemFontFallback = true;
  });

  test('all membership messages preserve parameters in each language', () {
    final parameter = RegExp(r'\{([a-zA-Z0-9_]+)\}');
    Set<String> names(String value) =>
        parameter.allMatches(value).map((match) => match[1]!).toSet();
    for (final entry in membershipDictionary.entries) {
      expect(entry.value.keys.toSet(), {'id', 'en', 'ar'}, reason: entry.key);
      for (final language in ['id', 'en', 'ar']) {
        expect(entry.value[language]!.trim(), isNotEmpty, reason: entry.key);
        expect(names(entry.value[language]!), names(entry.value['id']!),
            reason: '${entry.key}: $language');
      }
    }
  });

  test('payment and entitlement states remain distinct in every language', () {
    for (final language in ['id', 'en', 'ar']) {
      final messages = [
        'membership.payment_access_confirmed',
        'membership.payment_access_pending',
        'membership.access_payment_pending',
        'membership.payment_access_unconfirmed',
      ].map((key) => AppDictionary.translate(key, language)).toList();
      expect(messages.toSet(), hasLength(4));
      expect(messages.any((text) => text.startsWith('membership.')), isFalse);
      final total = AppDictionary.translate('membership.total', language,
          args: {'price': 'Rp 1.000.000'});
      expect(total, contains('Rp 1.000.000'));
    }
  });

  testWidgets('Arabic assistant actions fit and keep library navigation separate',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 780);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    var opened = 0;
    var library = 0;
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: const [Locale('id'), Locale('en'), Locale('ar')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: Scaffold(body: SingleChildScrollView(
        child: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
          child: SpecialistCard(
            title: 'فقه التحولات',
            scopeLabel: 'دراسة النصوص والمراجع',
            onOpen: () => opened++,
            onOpenLibrary: () => library++,
          ),
        ),
      )),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final libraryButton = find.byTooltip(AppDictionary.translate(
      'membership.library_title', 'ar', args: {'title': 'فقه التحولات'}));
    await tester.tap(libraryButton);
    await tester.pump();
    expect(library, 1);
    expect(opened, 0);
    expect(Directionality.of(tester.element(libraryButton)), TextDirection.rtl);
    final arrow = tester.widget<Icon>(find.byIcon(Icons.arrow_forward_rounded));
    expect(arrow.icon!.matchTextDirection, isTrue);
  });
}
