import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_copy.dart';
import 'package:openturath_ai/core/membership_pass_state.dart';
import 'package:openturath_ai/models/user_model.dart';

void main() {
  UserModel user(Map<String, ModuleEntitlement> entitlements) => UserModel(
        uid: 'u1', name: 'Udin', email: 'udin@example.com', photoUrl: '',
        plan: 'free', questionsUsed: 0, entitlements: entitlements,
      );

  test('presents a time-bound trial as Pro with remaining days', () {
    final summary = resolveMembershipPass(user({
      'fiqh': ModuleEntitlement(plan: 'trial', status: 'active', trialDurationDays: 3,
        expiry: DateTime.now().add(const Duration(days: 2, hours: 2))),
    }));
    expect(summary.state, MembershipPassState.trialPro);
    expect(summary.badge, 'PRO');
    expect(summary.supportingLabel.toLowerCase(), contains('masa coba'));
  });

  test('uses nearest expiry and count for several individual AI accesses', () {
    final summary = resolveMembershipPass(user({
      'fiqh': ModuleEntitlement(plan: 'pro', expiry: DateTime.now().add(const Duration(days: 8))),
      'hadis': ModuleEntitlement(plan: 'pro', expiry: DateTime.now().add(const Duration(days: 2))),
      'tafsir': ModuleEntitlement(plan: 'pro', expiry: DateTime.now().add(const Duration(days: 5))),
    }));
    expect(summary.state, MembershipPassState.expiringSoon);
    expect(summary.accessLabel, AppCopy.assistantsAvailableCount(3));
    expect(summary.expiryLabel, 'Berlaku hingga');
  });

  test('does not claim access while a payment is pending', () {
    final summary = resolveMembershipPass(user({
      'fiqh': const ModuleEntitlement(plan: 'pro', status: 'pending', paymentStatus: 'pending'),
    }));
    expect(summary.state, MembershipPassState.paymentPending);
    expect(summary.ctaLabel, 'Lihat status pembayaran');
  });

  test('keeps an active Pro pass open when another payment is pending', () {
    final user = UserModel(
      uid: 'u1', name: 'Udin', email: '', photoUrl: '', plan: 'free', questionsUsed: 0,
      entitlements: {
        'fiqh_syafii': ModuleEntitlement(
          plan: 'premium', expiry: DateTime(2026, 10, 1),
        ),
        'hadits': const ModuleEntitlement(
          plan: 'premium', status: 'pending', paymentStatus: 'pending',
        ),
      },
    );

    final pass = resolveMembershipPass(user, now: DateTime(2026, 9, 14));
    expect(pass.isOpen, isTrue);
    expect(pass.state, MembershipPassState.activePro);
  });

  test('locks a user without a valid entitlement', () {
    final summary = resolveMembershipPass(user(const {}));
    expect(summary.state, MembershipPassState.locked);
    expect(summary.ctaLabel, AppCopy.chooseProPlan);
  });

  test('keeps a legacy account-level Pro subscription open during migration', () {
    final legacy = UserModel(
      uid: 'legacy', name: 'Udin', email: 'u@example.com', photoUrl: '',
      plan: 'tholib_1m', questionsUsed: 0,
      subscriptionExpiry: DateTime.now().add(const Duration(days: 10)),
    );
    expect(resolveMembershipPass(legacy).state, MembershipPassState.activePro);
  });
}
