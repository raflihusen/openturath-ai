import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/app_copy.dart';
import 'package:openturath_ai/core/login_error_message.dart';

void main() {
  for (final locale in ['id', 'en', 'ar']) {
    test('Google Keychain failure is actionable in $locale', () {
      AppConfig.localeNotifier.value = locale;
      final error = PlatformException(
        code: 'sign_in_failed',
        message: 'com.google.GIDSignIn',
        details: 'keychain error',
      );
      expect(loginErrorMessage(error), AppCopy.desktopKeychainError);
      expect(loginErrorMessage(error), isNot(AppCopy.googleSignInFailed));
    });
  }
  test('cancelled Google authorization is not displayed as failure', () {
    expect(loginErrorMessage(PlatformException(code: 'sign_in_canceled')), '');
  });
  test('network failure and Firebase Keychain failure remain distinct', () {
    expect(loginErrorMessage(PlatformException(code: 'network_error')),
        AppCopy.networkError);
    expect(loginErrorMessage(FirebaseAuthException(code: 'keychain-error')),
        AppCopy.desktopKeychainError);
  });
  test('unknown SDK failures never expose their credential payloads', () {
    const sensitive = 'synthetic-secret-token';
    final platform =
        PlatformException(code: 'sign_in_failed', details: sensitive);
    final firebase = FirebaseAuthException(code: 'unknown', message: sensitive);
    expect(loginErrorMessage(platform), AppCopy.googleSignInFailed);
    expect(loginErrorMessage(firebase), AppCopy.googleSignInFailed);
    expect(loginErrorMessage(firebase), isNot(contains(sensitive)));
  });
  tearDown(() => AppConfig.localeNotifier.value = 'id');
}
