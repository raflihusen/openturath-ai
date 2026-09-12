import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/models/user_model.dart';

void main() {
  ModuleEntitlement entitlement({String status = 'active'}) => ModuleEntitlement(
    plan: 'tholib_1m', status: status, expiry: DateTime.now().add(const Duration(days: 1)));
  UserModel user(Map<String, ModuleEntitlement> entitlements) => UserModel(
    uid: 'u', name: 'U', email: 'u@example.test', photoUrl: '', plan: 'trial',
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
}
