import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/models/user_model.dart';
import 'package:openturath_ai/core/constants.dart';

void main() {
  group('Active Subscription Access Verification', () {
    final futureExpiry = DateTime.now().add(const Duration(days: 365));
    final pastExpiry = DateTime.now().subtract(const Duration(days: 1));

    test('Active subscriber with plan tholib_1m has access to all agents even with empty entitlements', () {
      final user = UserModel(
        uid: 'user_active_tholib',
        name: 'Rafli Husen',
        email: 'chenhuha135@gmail.com',
        photoUrl: '',
        plan: AppConstants.planTholib1m,
        subscriptionExpiry: futureExpiry,
        questionsUsed: 0,
        entitlements: {},
      );

      expect(user.isPremium, isTrue);
      expect(user.isSubscriptionActive, isTrue);
      expect(user.hasAccess, isTrue);
      expect(user.hasAccessToAgent('fiqh_syafii'), isTrue);
      expect(user.hasAccessToAgent('hadits'), isTrue);
      expect(user.hasAccessToAgent('ushul_fiqh'), isTrue);
      expect(user.hasAccessToAgent('nahwu_sharaf'), isTrue);
    });

    test('Active subscriber with plan bahits_1y or tholib_6m has full access', () {
      for (final planName in [AppConstants.planBahits1y, AppConstants.planTholib6m, 'sultan', 'all_ai_1m', 'full']) {
        final user = UserModel(
          uid: 'user_full_$planName',
          name: 'Peneliti',
          email: 'peneliti@example.com',
          photoUrl: '',
          plan: planName,
          subscriptionExpiry: futureExpiry,
          questionsUsed: 0,
          entitlements: {},
        );

        expect(user.isSubscriptionActive, isTrue, reason: planName);
        expect(user.hasAccessToAgent('fiqh_syafii'), isTrue, reason: planName);
        expect(user.hasAccessToAgent('tafsir'), isTrue, reason: planName);
      }
    });

  test('Active subscriber with redeem voucher code has full access', () {
      final user = UserModel(
        uid: 'user_redeem',
        name: 'Santri',
        email: 'santri@example.com',
        photoUrl: '',
        plan: 'redeem_1y',
        subscriptionExpiry: futureExpiry,
        questionsUsed: 0,
        entitlements: {},
      );

      expect(user.isSubscriptionActive, isTrue);
      expect(user.hasAccessToAgent('fiqh_syafii'), isTrue);
    });

    test('Expired subscriber is denied access', () {
      final user = UserModel(
        uid: 'user_expired',
        name: 'Expired User',
        email: 'expired@example.com',
        photoUrl: '',
        plan: AppConstants.planTholib1m,
        subscriptionExpiry: pastExpiry,
        questionsUsed: 0,
        entitlements: {},
      );

      expect(user.isSubscriptionActive, isFalse);
      expect(user.hasAccessToAgent('fiqh_syafii'), isFalse);
    });

    test('Single-module subscriber only has access to entitled module', () {
      final user = UserModel(
        uid: 'user_single',
        name: 'Single User',
        email: 'single@example.com',
        photoUrl: '',
        plan: 'single',
        subscriptionExpiry: futureExpiry,
        questionsUsed: 0,
        entitlements: {
          'fiqh_syafii': ModuleEntitlement(
            plan: 'single',
            expiry: futureExpiry,
            status: 'active',
          ),
        },
      );

      expect(user.isSubscriptionActive, isTrue);
      expect(user.hasAccessToAgent('fiqh_syafii'), isTrue);
      expect(user.hasAccessToAgent('hadits'), isFalse);
    });
  });

  test('time-bound trial voucher grants access without a question quota', () {
    final user = UserModel(
      uid: 'trial-user',
      name: 'Trial',
      email: 'trial@example.test',
      photoUrl: '',
      plan: 'trial',
      questionsUsed: 999,
      entitlements: {
        'all_access': ModuleEntitlement(
          plan: 'trial',
          expiry: DateTime.now().add(const Duration(days: 7)),
        ),
      },
    );

    expect(user.hasAccessToAgent('fikih-syafii'), isTrue);
    expect(user.questionsRemainingForAgent('fikih-syafii'), 9999);
  });
}
