import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/app_copy.dart';
import 'package:openturath_ai/core/login_error_message.dart';

void main() {
  test('Google configuration failure explains that deleting an account cannot fix it', () {
    AppConfig.localeNotifier.value = 'id';
    final message = loginErrorMessage(PlatformException(code: 'sign_in_failed',
        message: 'com.google.android.gms.common.api.ApiException: 10: synthetic-secret-token'));
    expect(message, contains('G10'));
    expect(message, contains('menghapus akun'));
    expect(message, isNot(contains('synthetic-secret-token')));
  });
  test('other native codes are not labelled as Google configuration error 10', () {
    for (final code in [7, 100, 12501]) {
      expect(loginErrorMessage(PlatformException(code: 'sign_in_failed',
          message: 'ApiException: $code:')), isNot(contains('G10')));
    }
  });
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
    expect(loginErrorMessage(platform), startsWith(AppCopy.googleSignInFailed));
    expect(loginErrorMessage(firebase), startsWith(AppCopy.googleSignInFailed));
    expect(loginErrorMessage(platform), isNot(contains(sensitive)));
    expect(loginErrorMessage(firebase), isNot(contains(sensitive)));
  });
  test('generic failure shows only a short error code for support', () {
    expect(loginErrorMessage(FirebaseAuthException(code: 'invalid-credential')),
        '${AppCopy.googleSignInFailed} (invalid-credential)');
    expect(loginErrorMessage(StateError('x')), AppCopy.googleSignInFailed);
    expect(
        loginErrorMessage(PlatformException(code: 'browser_launch_failed')),
        AppCopy.desktopBrowserError);
  });
  tearDown(() => AppConfig.localeNotifier.value = 'id');
}
