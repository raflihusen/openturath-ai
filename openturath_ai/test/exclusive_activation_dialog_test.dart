import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/localization.dart';
import 'package:openturath_ai/widgets/exclusive_activation_dialog.dart';

void main() {
  testWidgets(
      'activation shows factual expiry without unsupported access claims',
      (tester) async {
    AppConfig.localeNotifier.value = 'id';
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('id'),
        supportedLocales: Loc.supportedLocales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                ExclusiveActivationDialog.show(
                  context,
                  serviceTitle: "Kajian Fikih Syafi'i: Al-Muhaqqiq",
                  durationDays: 7,
                  expiryDate: DateTime(2040, 10, 6),
                  agentId: 'fiqh_syafii',
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Akses telah aktif'), findsOneWidget);
    expect(find.text("AI Kajian Fikih Syafi'i: Al-Muhaqqiq"), findsOneWidget);
    expect(find.textContaining('Berlaku hingga'), findsOneWidget);
    expect(find.textContaining('2040'), findsOneWidget);
    expect(find.textContaining('TERVERIFIKASI'), findsNothing);
    expect(find.textContaining('Tanpa Batas'), findsNothing);
    expect(find.text('Buka AI'), findsOneWidget);
    expect(find.text('Tutup'), findsOneWidget);

    // Klik tombol tutup
    await tester.ensureVisible(find.text('Tutup'));
    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();

    expect(find.text('Akses telah aktif'), findsNothing);
  });
}
