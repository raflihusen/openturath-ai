import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:openturath_ai/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('auth_service.dart no longer imports cloud_firestore or opens .snapshots() listeners', () {
    final source = File('lib/services/auth_service.dart').readAsStringSync();
    expect(source.contains("package:cloud_firestore/cloud_firestore.dart"), isFalse);
    expect(source.contains('.snapshots()'), isFalse);
    expect(source.contains('FirebaseFirestore'), isFalse);
    expect(source.contains("replaceEntitlements"), isTrue);
  });

  test('applyVpsUserStatusPayload replaces stale entitlements when replaceEntitlements=true', () async {
    const email = 'santri.test@example.com';
    final future = DateTime.now().toUtc().add(const Duration(days: 30)).toIso8601String();

    await AuthService.applyVpsUserStatusPayload(email, {
      'success': true,
      'replaceEntitlements': true,
      'hasActiveAccess': true,
      'isVip': false,
      'plan': 'fiqh_syafii',
      'expiryIso': future,
      'entitlements': {
        'fiqh_syafii': {
          'plan': 'tholib_1m',
          'status': 'active',
          'expiry': future,
          'kind': 'payment',
        },
        'akidah': {
          'plan': 'tholib_1m',
          'status': 'active',
          'expiry': future,
          'kind': 'payment',
        },
      },
    });

    final auth = AuthService();
    var user = auth.cachedCurrentUser;
    expect(user, isNotNull);
    expect(user!.entitlements.containsKey('fiqh_syafii'), isTrue);
    expect(user.entitlements.containsKey('akidah'), isTrue);

    // Next sync from VPS returns only akidah with replaceEntitlements=true:
    // stale fiqh_syafii must be removed cleanly (anti-split-brain).
    await AuthService.applyVpsUserStatusPayload(email, {
      'success': true,
      'replaceEntitlements': true,
      'hasActiveAccess': true,
      'isVip': false,
      'plan': 'akidah',
      'expiryIso': future,
      'entitlements': {
        'akidah': {
          'plan': 'tholib_1m',
          'status': 'active',
          'expiry': future,
          'kind': 'payment',
        },
      },
    });

    user = auth.cachedCurrentUser;
    expect(user, isNotNull);
    expect(user!.entitlements.containsKey('akidah'), isTrue);
    expect(user.entitlements.containsKey('fiqh_syafii'), isFalse);

    // Revocation clears all entitlements for non-VIP user.
    await AuthService.applyVpsUserStatusPayload(email, {
      'success': true,
      'replaceEntitlements': true,
      'hasActiveAccess': false,
      'isVip': false,
      'entitlements': <String, dynamic>{},
    });
    user = auth.cachedCurrentUser;
    expect(user, isNotNull);
    expect(user!.entitlements, isEmpty);
    expect(user.isSubscriptionActive, isFalse);
    expect(user.isAgentSubscriptionActive('akidah'), isFalse);
  });

  test('applyVpsUserStatusPayload preserves canonical VIP prerogatives even with empty entitlements', () async {
    const vipEmail = 'prilatief@gmail.com';
    await AuthService.applyVpsUserStatusPayload(vipEmail, {
      'success': true,
      'replaceEntitlements': true,
      'hasActiveAccess': true,
      'isVip': true,
      'plan': 'vip',
      'entitlements': <String, dynamic>{},
    });

    final user = AuthService().cachedCurrentUser;
    expect(user, isNotNull);
    expect(user!.isVip, isTrue);
    expect(user.isAgentSubscriptionActive('fiqh_tahawwulat'), isTrue);
    expect(user.isAgentSubscriptionActive('fiqh_syafii'), isTrue);
  });
}
