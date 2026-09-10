import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/models/user_model.dart';

void main() {
  group('System Hardening & Entitlement Suite', () {
    test('All active agents have consistent pricing catalog', () {
      final activeAgents = AgentModel.defaultAgents.where((a) => a.isActive).toList();
      expect(activeAgents.isNotEmpty, isTrue);

      for (final agent in activeAgents) {
        expect(agent.price1m, isNotNull);
        expect(agent.price1m!, greaterThan(0));
        // All individual monthly plans are unified at 50,000 IDR
        expect(agent.price1m, equals(50000));
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

    test('URL security policy allows Google NotebookLM ecosystem and blocks external redirects', () {
      bool isAllowedUrl(String urlStr) {
        final uri = Uri.tryParse(urlStr);
        if (uri == null) return false;
        if (uri.scheme.toLowerCase() != 'https') return false;

        final host = uri.host.toLowerCase();
        return host.endsWith('.google.com') ||
            host == 'google.com' ||
            host.endsWith('.gstatic.com') ||
            host.endsWith('.googleusercontent.com') ||
            host.endsWith('.firebaseapp.com');
      }

      expect(isAllowedUrl('https://notebooklm.google.com/notebook/abc-123'), isTrue);
      expect(isAllowedUrl('https://accounts.google.com/ServiceLogin'), isTrue);
      expect(isAllowedUrl('https://fonts.gstatic.com/s/roboto/v20/xyz.woff2'), isTrue);
      expect(isAllowedUrl('http://notebooklm.google.com'), isFalse); // HTTP insecure
      expect(isAllowedUrl('https://evil-phishing.com/notebooklm.google.com'), isFalse);
      expect(isAllowedUrl('javascript:alert(1)'), isFalse);
      expect(isAllowedUrl('file:///android_asset/something.html'), isFalse);
    });

    test('Redeem code normalization handles whitespace, casing, and dashes', () {
      String normalizeCode(String input) {
        return input.trim().toUpperCase().replaceAll(RegExp(r'[\s-]'), '');
      }

      expect(normalizeCode('  santri-7hari  '), equals('SANTRI7HARI'));
      expect(normalizeCode('FIKIH-SYAFII-2026'), equals('FIKIHSYAFII2026'));
      expect(normalizeCode('  voucher 123  '), equals('VOUCHER123'));
    });
  });
}
