import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import 'app_copy.dart';

/// Maps SDK failures to useful copy without displaying SDK payloads or tokens.
/// An empty message means the user cancelled the authorization flow.
String loginErrorMessage(Object error) {
  if (error is PlatformException) {
    if (error.code == 'sign_in_canceled') return '';
    if (error.code == 'network_error') return AppCopy.networkError;
    if (error.code == 'sign_in_failed' &&
        '${error.details}'.toLowerCase().contains('keychain')) {
      return AppCopy.desktopKeychainError;
    }
  }
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'keychain-error' => AppCopy.desktopKeychainError,
      'popup-closed-by-user' || 'canceled' => '',
      'network-request-failed' => AppCopy.networkError,
      _ => AppCopy.googleSignInFailed,
    };
  }
  return AppCopy.googleSignInFailed;
}
