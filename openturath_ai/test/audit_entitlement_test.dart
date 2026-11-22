import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/membership_pass_state.dart';
import 'package:openturath_ai/models/user_model.dart';
import 'package:openturath_ai/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  ModuleEntitlement entitlement({String status = 'active'}) =>
      ModuleEntitlement(
          plan: 'tholib_1m',
          status: status,
          expiry: DateTime.now().add(const Duration(days: 1)));
  UserModel user(Map<String, ModuleEntitlement> entitlements) => UserModel(
      uid: 'u',
      name: 'U',
      email: 'u@example.test',
      photoUrl: '',
      plan: 'trial',
      questionsUsed: 0,
      entitlements: entitlements);
  test('A10 specific paid module survives revoked all-access', () {
    final u = user({
      'all_access': entitlement(status: 'revoked'),
      'hadits': entitlement()
    });
    expect(u.hasAccessToAgent('hadits'), isTrue);
    expect(u.hasAccessToAgent('tafsir'), isFalse);
  });
  test('A10 all language aliases use the same canonical entitlement', () {
    final u = user({'nahwu': entitlement()});
    for (final id in [
      'nahwu_sharaf',
      'bahasa_arab',
      'lughah_nahwu',
      'lughah_mujam'
    ]) {
      expect(u.hasAccessToAgent(id), isTrue, reason: id);
    }
  });
  test('A10 unrelated prefix cannot open a new module', () {
    expect(
        user({'fiqh': entitlement()}).hasAccessToAgent('fiqh_syafii'), isFalse);
  });
  test('Permanent VIP opens every module despite old revoked subscriptions',
      () {
    for (final protection in [
      {'is_vip': true},
      {'role': 'VIP'}
    ]) {
      final vip = UserModel.fromMap('vip', {
        ...protection,
        'email': 'vip@example.test',
        'plan': 'free',
        'subscription_expiry': DateTime.utc(2000).toIso8601String(),
        'entitlements': {
          'all_access': {
            'plan': 'all_access',
            'status': 'revoked',
            'expiry': DateTime.utc(2000).toIso8601String(),
          }
        },
      });
      expect(vip.isVip, isTrue);
      expect(vip.isTrial, isFalse);
      expect(vip.isPremium, isTrue);
      expect(vip.hasAccess, isTrue);
      for (final agent in [
        'fiqh_syafii',
        'fiqh_tahawwulat',
        'tafsir',
        'hadits'
      ]) {
        expect(vip.hasAccessToAgent(agent), isTrue, reason: agent);
      }
      expect(vip.copyWith(questionsUsed: 10000).isVip, isTrue);
      expect(UserModel.fromMap('vip', vip.toJsonMap()).isVip, isTrue);
      expect(UserModel.fromMap('vip', vip.toMap()).isVip, isTrue);
    }
  });
  test('Expired ordinary account does not become permanent VIP', () {
    final ordinary = UserModel.fromMap('ordinary', {
      'is_vip': false,
      'role': 'user',
      'plan': 'all_access',
      'subscription_expiry': DateTime.utc(2000).toIso8601String(),
    });
    expect(ordinary.isVip, isFalse);
    expect(ordinary.hasAccessToAgent('hadits'), isFalse);
  });

  test('all_specialists unlocks non-Tahawwulat disciplines and isolates all 5 Tahawwulat sub-AIs', () {
    final u = user({
      'all_specialists': ModuleEntitlement(
        plan: 'all_specialists_1m',
        status: 'active',
        paymentStatus: 'paid',
        expiry: DateTime.now().add(const Duration(days: 30)),
      ),
    });
    for (final allowed in [
      'fiqh_syafii',
      'fiqh_hanafi',
      'hadits',
      'tafsir',
      'nahwu_sharaf',
      'bibliografi_faharis',
    ]) {
      expect(u.hasAccessToAgent(allowed), isTrue, reason: allowed);
    }
    for (final isolated in [
      'fiqh_tahawwulat',
      'fiqh_tahawwulat_muhaqqiq',
      'fiqh_tahawwulat_bayan',
      'fiqh_tahawwulat_khatib',
      'fiqh_tahawwulat_habib',
      'fiqh_tahawwulat_mukhtabir',
      'fikih-tahawwulat-bayan',
    ]) {
      expect(u.hasAccessToAgent(isolated), isFalse, reason: isolated);
    }
    final pass = resolveMembershipPass(u);
    expect(pass.badge, 'PRO');
    expect(pass.accessLabel, contains('Kecuali Fikih Tahawwulat'));
  });

  test('pending or failed entitlement with future expiry is never active', () {
    final pending = ModuleEntitlement(
      plan: 'tholib_1m',
      status: 'pending',
      expiry: DateTime.now().add(const Duration(days: 30)),
    );
    final failed = ModuleEntitlement(
      plan: 'tholib_1m',
      status: 'failed',
      expiry: DateTime.now().add(const Duration(days: 30)),
    );
    expect(pending.isActive, isFalse);
    expect(failed.isActive, isFalse);
    expect(user({'hadits': pending}).hasAccessToAgent('hadits'), isFalse);
  });

  test('applyActiveGrant for all_specialists never leaks all_access or Tahawwulat', () async {
    addTearDown(AuthService.resetWebSessionForTest);
    SharedPreferences.setMockInitialValues({});
    await AuthService.applyActiveGrant(
      'santri@example.test',
      expiry: DateTime.now().add(const Duration(days: 30)),
      agentId: 'all_specialists',
      isPaidSubscription: true,
      replaceEntitlements: true,
    );
    final cached = AuthService().cachedCurrentUser;
    expect(cached, isNotNull);
    expect(cached!.entitlements.containsKey('all_specialists'), isTrue);
    expect(cached.entitlements.containsKey('all_access'), isFalse);
    expect(cached.entitlements.containsKey('all_ai'), isFalse);
    expect(cached.hasAccessToAgent('fiqh_syafii'), isTrue);
    expect(cached.hasAccessToAgent('fiqh_tahawwulat'), isFalse);
    expect(cached.hasAccessToAgent('fiqh_tahawwulat_khatib'), isFalse);
  });
}
