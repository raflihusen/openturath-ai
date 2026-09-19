import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openturath_ai/core/theme.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/models/user_model.dart';
import 'package:openturath_ai/core/localization.dart';
import 'package:openturath_ai/models/bookmark_model.dart';
import 'package:openturath_ai/services/agent_service.dart';
import 'package:openturath_ai/widgets/app_error_state.dart';
import 'package:openturath_ai/core/design/ot_typography.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  OTTypography.useSystemFontFallback = true;

  group('Resilience & Compliance Suite', () {
    testWidgets('AppErrorState renders properly with retry and back buttons', (tester) async {
      bool retried = false;
      bool backPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: AppErrorState(
              title: 'Gagal Memuat Korpus',
              message: 'Terjadi kendala koneksi saat menghubungi server.',
              onRetry: () => retried = true,
              onBack: () => backPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Gagal Memuat Korpus'), findsOneWidget);
      expect(find.text('Terjadi kendala koneksi saat menghubungi server.'), findsOneWidget);
      expect(find.text('Coba lagi'), findsOneWidget);
      expect(find.text('Kembali'), findsOneWidget);

      await tester.tap(find.text('Coba lagi'));
      expect(retried, isTrue);

      await tester.tap(find.text('Kembali'));
      expect(backPressed, isTrue);
    });

    test('AgentModel defaultAgents have complete Arabic metadata and no null pointer risks', () {
      for (final agent in AgentModel.defaultAgents) {
        expect(agent.id, isNotEmpty);
        expect(agent.title, isNotEmpty);
        expect(agent.titleArabic, isNotEmpty);
        expect(agent.category, isNotEmpty);

        if (agent.isActive) {
          expect(agent.price1m, isNotNull);
        }

        if (agent.subAgents != null) {
          for (final sub in agent.subAgents!) {
            expect(sub.nameArabic, isNotEmpty);
            expect(sub.name, isNotEmpty);
          }
        }
      }
    });

    test('Anonymous guest user model properties are valid', () {
      final guest = UserModel(
        uid: 'guest_test_123',
        name: 'Peneliti Tamu',
        email: '',
        photoUrl: '',
        plan: 'trial',
        questionsUsed: 0,
      );

      expect(guest.isGuest, isTrue);
      expect(guest.isTrial, isTrue);
      expect(guest.questionsRemaining, equals(0));
      expect(guest.hasAccess, isFalse);
    });

    test('AppTheme Obsidian standard does not leak gold color #D4AF37', () {
      expect(AppTheme.lmDarkCanvas, equals(AppTheme.canvasDark));
      expect(AppTheme.lmDarkSurface, equals(AppTheme.surfaceCardDark));
      expect(AppTheme.lmDarkBorder, equals(AppTheme.borderDark));
      expect(AppTheme.lmDarkAccent, equals(AppTheme.accentDark));

      // Light mode
      expect(AppTheme.lmLightCanvas, equals(AppTheme.canvasLight));
      expect(AppTheme.lmLightSurface, equals(AppTheme.surfaceCardLight));
      expect(AppTheme.lmLightBorder, equals(AppTheme.borderLight));
      expect(AppTheme.lmLightAccent, equals(AppTheme.accentLight));
    });

    test('AgentAccessException encapsulates code, message, and string representation', () {
      const exc = AgentAccessException(
        'permission-denied',
        'Batas uji coba 10 pertanyaan telah tercapai.',
      );
      expect(exc.code, equals('permission-denied'));
      expect(exc.message, contains('10 pertanyaan'));
      expect(exc.toString(), contains('AgentAccessException(permission-denied)'));
    });

    test('UserModel hasAccessToAgent respects modular entitlements and expiry', () {
      final now = DateTime.now();
      final future = now.add(const Duration(days: 30));
      final past = now.subtract(const Duration(days: 1));

      final activeUser = UserModel(
        uid: 'user_active_1',
        email: 'santri@openturath.ai',
        name: 'Santri Aktif',
        photoUrl: '',
        plan: 'premium',
        questionsUsed: 0,
        entitlements: {
          'fiqh_tahawwulat': ModuleEntitlement(
            plan: 'tholib_1m',
            status: 'active',
            expiry: future,
          ),
        },
      );

      expect(activeUser.hasAccessToAgent('fiqh_tahawwulat'), isTrue);

      final expiredUser = UserModel(
        uid: 'user_expired_1',
        email: 'santri_exp@openturath.ai',
        name: 'Santri Expired',
        photoUrl: '',
        plan: 'trial',
        questionsUsed: 10,
        entitlements: {
          'fiqh_tahawwulat': ModuleEntitlement(
            plan: 'tholib_1m',
            status: 'expired',
            expiry: past,
          ),
        },
      );

      expect(expiredUser.hasAccessToAgent('fiqh_tahawwulat'), isFalse);
      expect(expiredUser.isTrialExhausted, isFalse);
    });

    test('ThemeData dark and light include hardened component themes', () {
      final darkTheme = AppTheme.darkTheme;
      expect(darkTheme.snackBarTheme.behavior, equals(SnackBarBehavior.floating));
      expect(darkTheme.inputDecorationTheme.filled, isTrue);
      expect(darkTheme.dialogTheme.backgroundColor, equals(AppTheme.surfaceCardDark));

      final lightTheme = AppTheme.lightTheme;
      expect(lightTheme.snackBarTheme.behavior, equals(SnackBarBehavior.floating));
      expect(lightTheme.inputDecorationTheme.filled, isTrue);
      expect(lightTheme.dialogTheme.backgroundColor, equals(AppTheme.surfaceCardLight));
    });

    test('Localization contains valid cancel key in all three languages', () {
      AppConfig.localeNotifier.value = 'id';
      expect(Loc.tr('cancel'), equals('Batal'));

      AppConfig.localeNotifier.value = 'en';
      expect(Loc.tr('cancel'), equals('Cancel'));

      AppConfig.localeNotifier.value = 'ar';
      expect(Loc.tr('cancel'), equals('إلغاء'));

      // Restore default
      AppConfig.localeNotifier.value = 'id';
    });

    test('BookmarkModel serializes and deserializes correctly', () {
      final now = DateTime.now();
      final bm = BookmarkModel(
        id: 'bm_test_1',
        title: 'Kaidah Fiqh',
        agentId: 'fiqh_syafii',
        agentTitle: 'AI Fikih Syafi\'i',
        fieldName: 'Fikih',
        fieldId: 'fiqh',
        arabicExcerpt: 'الْأُمُورُ بِمَقَاصِدِهَا',
        fullAnswer: 'Segala perkara bergantung pada niatnya.',
        bookReference: 'Al-Asybah wan-Nazhair',
        pageNumber: 'Hal. 10',
        createdAt: now,
      );

      final json = bm.toJson();
      final restored = BookmarkModel.fromJson(json);

      expect(restored.id, equals('bm_test_1'));
      expect(restored.title, equals('Kaidah Fiqh'));
      expect(restored.arabicExcerpt, equals('الْأُمُورُ بِمَقَاصِدِهَا'));
      expect(restored.fieldId, equals('fiqh'));
    });
  });
}
