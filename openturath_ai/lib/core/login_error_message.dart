import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import 'app_copy.dart';
import 'localization.dart';

/// Maps SDK failures to useful copy without displaying SDK payloads or tokens.
/// An empty message means the user cancelled the authorization flow.
String loginErrorMessage(Object error) {
  if (error is PlatformException) {
    if (error.code == 'sign_in_canceled') {
      return '';
    }
    if (error.code == 'network_error') {
      return AppCopy.networkError;
    }
    if (error.code == 'browser_launch_failed') {
      return AppCopy.desktopBrowserError;
    }
    if (error.code == 'desktop_loopback_failed') {
      return AppCopy.desktopListenerError;
    }
    if (error.code == 'sign_in_failed' &&
        '${error.details}'.toLowerCase().contains('keychain')) {
      return AppCopy.desktopKeychainError;
    }
  }
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'keychain-error' => AppCopy.desktopKeychainError,
      'auth-operation-in-progress' => Loc.tr('authPreviousLoginPending'),
      'popup-closed-by-user' || 'canceled' => '',
      'network-request-failed' => AppCopy.networkError,
      _ => _withCode(error.code),
    };
  }
  return _withCode(error is PlatformException ? error.code : null);
}

final _safeCode = RegExp(r'^[a-zA-Z0-9_-]{1,40}$');

/// Pesan umum plus kode galat singkat agar pengguna bisa melaporkannya. Hanya kode,
/// tidak pernah pesan atau detail SDK yang bisa memuat token.
String _withCode(String? code) {
  final safe = code != null && _safeCode.hasMatch(code) ? code : null;
  return safe == null
      ? AppCopy.googleSignInFailed
      : '${AppCopy.googleSignInFailed} ($safe)';
}
