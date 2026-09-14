import 'package:flutter_test/flutter_test.dart';
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
    expect(summary.supportingLabel, contains('MASA COBA'));
  });

  test('uses nearest expiry and count for several individual AI accesses', () {
    final summary = resolveMembershipPass(user({
      'fiqh': ModuleEntitlement(plan: 'pro', expiry: DateTime.now().add(const Duration(days: 8))),
      'hadis': ModuleEntitlement(plan: 'pro', expiry: DateTime.now().add(const Duration(days: 2))),
      'tafsir': ModuleEntitlement(plan: 'pro', expiry: DateTime.now().add(const Duration(days: 5))),
    }));
    expect(summary.state, MembershipPassState.expiringSoon);
    expect(summary.accessLabel, '3 asisten aktif');
    expect(summary.expiryLabel, 'AKSES TERDEKAT BERAKHIR');
  });

  test('does not claim access while a payment is pending', () {
    final summary = resolveMembershipPass(user({
      'fiqh': ModuleEntitlement(plan: 'pro', status: 'pending', paymentStatus: 'pending'),
    }));
    expect(summary.state, MembershipPassState.paymentPending);
    expect(summary.ctaLabel, 'Lihat status pembayaran');
  });

  test('locks a user without a valid entitlement', () {
    final summary = resolveMembershipPass(user(const {}));
    expect(summary.state, MembershipPassState.locked);
    expect(summary.ctaLabel, 'Aktifkan Pro');
  });
}
