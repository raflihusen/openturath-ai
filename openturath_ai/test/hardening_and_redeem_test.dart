import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/hijri_date_utils.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/models/user_model.dart';
import 'package:openturath_ai/screens/agent_webview_screen.dart';
import 'package:openturath_ai/services/subscription_service.dart';

void main() {
  group('System Hardening & Entitlement Suite', () {
    test('All active agents have consistent pricing catalog', () {
      final activeAgents = AgentModel.defaultAgents.where((a) => a.isActive).toList();
      expect(activeAgents.isNotEmpty, isTrue);

      for (final agent in activeAgents) {
        expect(agent.price1m, isNotNull);
        expect(agent.price1m!, greaterThan(0));
        // All individual monthly plans are unified at 49,000 IDR
        expect(agent.price1m, equals(49000));
      }
    });

    test('UserModel modular entitlement grants access when active and not expired', () {
      final futureExpiry = DateTime.now().add(const Duration(days: 7));
      final user = UserModel(
        uid: 'user_active_7d',
        name: 'Santri Riset',
        email: 'santri@example.com',
        photoUrl: '',
        plan: 'custom',
        questionsUsed: 0,
        entitlements: {
          'fiqh_syafii': ModuleEntitlement(
            plan: 'redeem_7d',
            expiry: futureExpiry,
            status: 'active',
          ),
        },
      );

      expect(user.hasAccessToAgent('fiqh_syafii'), isTrue);
      // Does not grant access to unowned agents
      expect(user.hasAccessToAgent('hadits'), isFalse);
    });

    test('UserModel modular entitlement denies access when expired', () {
      final pastExpiry = DateTime.now().subtract(const Duration(days: 1));
      final user = UserModel(
        uid: 'user_expired',
        name: 'Santri Expired',
        email: 'santri_exp@example.com',
        photoUrl: '',
        plan: 'custom',
        questionsUsed: 0,
        entitlements: {
          'fiqh_syafii': ModuleEntitlement(
            plan: 'redeem_7d',
            expiry: pastExpiry,
            status: 'expired',
          ),
        },
      );

      expect(user.hasAccessToAgent('fiqh_syafii'), isFalse);
    });

    test('Full bundle plan grants access to all active agents regardless of individual entitlements', () {
      final futureExpiry = DateTime.now().add(const Duration(days: 30));
      final user = UserModel(
        uid: 'user_full_bundle',
        name: 'Santri Riset Lengkap',
        email: 'santri_full@example.com',
        photoUrl: '',
        plan: 'full',
        questionsUsed: 0,
        subscriptionExpiry: futureExpiry,
      );

      expect(user.hasAccessToAgent('fiqh_syafii'), isTrue);
      expect(user.hasAccessToAgent('hadits'), isTrue);
      expect(user.hasAccessToAgent('fiqh_tahawwulat'), isTrue);
    });

    test('URL security policy allows Google NotebookLM ecosystem and blocks external redirects (Production Code)', () {
      bool check(String urlStr) {
        final uri = Uri.tryParse(urlStr);
        if (uri == null) return false;
        return AgentWebviewScreen.isAllowedNotebookUrl(uri);
      }

      expect(check('https://notebooklm.google.com/notebook/abc-123'), isTrue);
      expect(check('https://accounts.google.com/ServiceLogin'), isTrue);
      expect(check('https://fonts.gstatic.com/s/roboto/v20/xyz.woff2'), isFalse); // Resource URL is not a top-level destination.
      expect(check('https://apis.google.com/js/api.js'), isFalse);
      expect(check('http://notebooklm.google.com'), isFalse); // HTTP insecure rejected
      expect(check('https://evil-phishing.com/notebooklm.google.com'), isFalse);
      expect(check('javascript:alert(1)'), isFalse);
      expect(check('file:///android_asset/something.html'), isFalse);
    });

    test('Redeem code normalization handles whitespace, casing, and dashes (Production Code)', () {
      expect(SubscriptionService.normalizeCode('  santri-7hari  '), equals('SANTRI7HARI'));
      expect(SubscriptionService.normalizeCode('FIKIH-SYAFII-2026'), equals('FIKIHSYAFII2026'));
      expect(SubscriptionService.normalizeCode('  voucher 123  '), equals('VOUCHER123'));
      expect(SubscriptionService.normalizeCode(' santri_123 '), equals('SANTRI_123'));
    });

    test('redeemErrorMessage formats neutral copy and preserves device protection messages', () {
      // 1. Standar kode sudah pernah dipakai (netral 'Kode ini')
      expect(
        SubscriptionService.redeemErrorMessage('already-exists'),
        equals('Kode ini sudah pernah ditukarkan sebelumnya.'),
      );

      // 2. Pesan proteksi perangkat dari server diteruskan utuh
      const deviceMsg = 'Kode ini hanya dapat diklaim 1 kali per perangkat. Perangkat ini sudah pernah mengaktifkannya sebelumnya.';
      expect(
        SubscriptionService.redeemErrorMessage('already-exists', deviceMsg),
        equals(deviceMsg),
      );

      // 3. Pesan proteksi ponsel fisik / anti emulator diteruskan utuh
      const emulatorMsg = 'Kode ini hanya dapat diaktifkan melalui ponsel fisik asli.';
      expect(
        SubscriptionService.redeemErrorMessage('failed-precondition', emulatorMsg),
        equals(emulatorMsg),
      );
    });

    test('addCalendarMonthsClamped correctly handles leap year 29 Feb and non-leap 28 Feb boundary conditions (F-11)', () {
      // 1. Tahun kabisat (2024): 31 Januari + 1 bulan = 29 Februari 2024
      final jan31Leap = DateTime(2024, 1, 31);
      final febLeap = HijriDateUtils.addCalendarMonthsClamped(jan31Leap, 1);
      expect(febLeap.year, equals(2024));
      expect(febLeap.month, equals(2));
      expect(febLeap.day, equals(29));

      // 2. Tahun non-kabisat (2025): 31 Januari + 1 bulan = 28 Februari 2025
      final jan31NonLeap = DateTime(2025, 1, 31);
      final febNonLeap = HijriDateUtils.addCalendarMonthsClamped(jan31NonLeap, 1);
      expect(febNonLeap.year, equals(2025));
      expect(febNonLeap.month, equals(2));
      expect(febNonLeap.day, equals(28));

      // 3. Dari 29 Februari kabisat (2024) + 12 bulan (1 tahun) = 28 Februari 2025 (non-kabisat)
      final leapFeb29 = DateTime(2024, 2, 29);
      final nextYearFeb = HijriDateUtils.addCalendarMonthsClamped(leapFeb29, 12);
      expect(nextYearFeb.year, equals(2025));
      expect(nextYearFeb.month, equals(2));
      expect(nextYearFeb.day, equals(28));

      // 4. 31 Maret + 1 bulan = 30 April
      final mar31 = DateTime(2024, 3, 31);
      final apr30 = HijriDateUtils.addCalendarMonthsClamped(mar31, 1);
      expect(apr30.month, equals(4));
      expect(apr30.day, equals(30));

      // 5. 31 Mei + 1 bulan = 30 Juni
      final may31 = DateTime(2024, 5, 31);
      final jun30 = HijriDateUtils.addCalendarMonthsClamped(may31, 1);
      expect(jun30.month, equals(6));
      expect(jun30.day, equals(30));
    });
  });
}
