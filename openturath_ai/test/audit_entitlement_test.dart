import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/models/user_model.dart';

void main() {
  ModuleEntitlement entitlement({String status = 'active'}) => ModuleEntitlement(
    plan: 'tholib_1m', status: status, expiry: DateTime.now().add(const Duration(days: 1)));
  UserModel user(Map<String, ModuleEntitlement> entitlements) => UserModel(
    uid: 'u', name: 'U', email: '[REDACTED_EMAIL]', photoUrl: '', plan: 'trial',
    questionsUsed: 0, entitlements: entitlements);
  test('A10 specific paid module survives revoked all-access', () {
    final u = user({'all_access': entitlement(status: 'revoked'), 'hadits': entitlement()});
    expect(u.hasAccessToAgent('hadits'), isTrue);
    expect(u.hasAccessToAgent('tafsir'), isFalse);
  });
  test('A10 all language aliases use the same canonical entitlement', () {
    final u = user({'nahwu': entitlement()});
    for (final id in ['nahwu_sharaf', 'bahasa_arab', 'lughah_nahwu', 'lughah_mujam']) {
      expect(u.hasAccessToAgent(id), isTrue, reason: id);
    }
  });
  test('A10 unrelated prefix cannot open a new module', () {
    expect(user({'fiqh': entitlement()}).hasAccessToAgent('fiqh_syafii'), isFalse);
  });
  test('unknown and pending states fail closed even with future expiry', () {
    for (final status in ['pending', 'failed', 'suspended', 'unknown', '']) {
      expect(user({'hadits': entitlement(status: status)}).hasAccessToAgent('hadits'), isFalse);
    }
    expect(ModuleEntitlement.fromMap({'plan': 'pro', 'expiry': '2099-01-01'}).isActive, isFalse);
  });
  test('specific revocation overrides an active all-access grant', () {
    final u = user({'all_access': entitlement(), 'hadits': entitlement(status: 'revoked')});
    expect(u.hasAccessToAgent('hadits'), isFalse);
    expect(u.hasAccessToAgent('tafsir'), isTrue);
  });
  test('canonical pending entitlement cannot fall back to legacy global expiry', () {
    final u = UserModel(uid: 'u', name: '', email: '', photoUrl: '', plan: 'all_access',
      questionsUsed: 0, subscriptionExpiry: DateTime.now().add(const Duration(days: 10)),
      entitlements: {'hadits': entitlement(status: 'pending')});
    expect(u.hasAccessToAgent('hadits'), isFalse);
    expect(u.hasAccess, isFalse);
  });

}


