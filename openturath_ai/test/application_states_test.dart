import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/widgets/app_loader.dart';
import 'package:openturath_ai/widgets/app_error_state.dart';
import 'package:openturath_ai/models/user_model.dart';
import 'package:openturath_ai/core/constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Milestone 4: 14 Application States Verification', () {
    testWidgets('State 2 & 3: AppLoader renders inline and fullscreen pulse states', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('id'), supportedLocales: [Locale('id')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: Scaffold(
            body: AppLoader(
              title: 'Menelaah Naskah...',
              subtitle: 'Menghubungkan ke korpus kitab',
            ),
          ),
        ),
      );

      expect(find.text('Menelaah Naskah...'), findsOneWidget);
      expect(find.text('Menghubungkan ke korpus kitab'), findsOneWidget);
    });

    testWidgets('State 9: AppErrorState.network renders peaceful scholarly network error', (tester) async {
      bool retried = false;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('id'), supportedLocales: const [Locale('id')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: Scaffold(
            body: AppErrorState.network(
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('Koneksi terputus'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);

      await tester.tap(find.text('Coba kembali'));
      expect(retried, isTrue);
    });

    testWidgets('State 10: AppErrorState.unauthorized renders locked module state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('id'), supportedLocales: [Locale('id')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: Scaffold(
            body: AppErrorState.unauthorized(),
          ),
        ),
      );

      expect(find.text('Akses kajian diperlukan'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
    });

    testWidgets('State 7 & 8: AppErrorState.empty renders scholarly empty state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('id'), supportedLocales: [Locale('id')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: Scaffold(
            body: AppErrorState.empty(),
          ),
        ),
      );

      expect(find.text('Rujukan belum ditemukan'), findsOneWidget);
      expect(find.byIcon(Icons.find_in_page_outlined), findsOneWidget);
    });

    testWidgets('State 11: AppErrorState.generic renders serene fallback state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('id'), supportedLocales: [Locale('id')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: Scaffold(
            body: AppErrorState.generic(),
          ),
        ),
      );

      expect(find.text('Ruang kajian belum tersedia'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    test('State 13: Disabled/Locked entitlement check accurately enforces paywall', () {
      final freeUser = UserModel(
        uid: 'user_free',
        name: 'Santri Pemula',
        email: 'santri@openturath.ai',
        photoUrl: '',
        plan: AppConstants.planTrial,
        questionsUsed: 50,
      );

      // Free user without entitlements does not have access to notebook agents
      expect(freeUser.hasAccessToAgent('fiqh_muamalat'), isFalse);
      expect(freeUser.hasAccessToAgent('fiqh_syafii'), isFalse);
    });

    test('State 12: Active selected agent entitlement check allows access for subscribed user', () {
      final futureExpiry = DateTime.now().add(const Duration(days: 30));
      final fullUser = UserModel(
        uid: 'user_subscribed',
        name: 'Kyai Peneliti',
        email: 'kyai@openturath.ai',
        photoUrl: '',
        plan: 'all_access',
        questionsUsed: 5,
        subscriptionExpiry: futureExpiry,
        entitlements: {
          'all_access': ModuleEntitlement(
            plan: 'all_access',
            expiry: futureExpiry,
            status: 'active',
          ),
        },
      );

      expect(fullUser.hasAccessToAgent('fiqh_muamalat'), isTrue);
      expect(fullUser.hasAccessToAgent('fiqh_tahawwulat'), isTrue);
    });
  });
}


