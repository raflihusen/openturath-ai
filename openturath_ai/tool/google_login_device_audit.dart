// Internal device entrypoint. Uses the real application, Firebase identity,
// native Google WebView and its existing cookies. Never shipped as lib/main.dart.
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:openturath_ai/core/google_connection_flow.dart';
import 'package:openturath_ai/core/routes.dart';
import 'package:openturath_ai/main.dart' as application;
import 'package:openturath_ai/screens/google_session_auth_screen.dart';
import 'package:openturath_ai/screens/main_shell_screen.dart';
import 'package:openturath_ai/services/auth_service.dart';
import 'package:openturath_ai/services/persistent_google_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool _contains<T extends Widget>(Element root) {
  var found = root.widget is T;
  root.visitChildren((child) {
    if (!found) found = _contains<T>(child);
  });
  return found;
}

NavigatorState? _navigator(Element root) {
  if (root is StatefulElement && root.state is NavigatorState) {
    return root.state as NavigatorState;
  }
  NavigatorState? found;
  root.visitChildren((child) => found ??= _navigator(child));
  return found;
}

Future<void> main() async {
  if (!const bool.fromEnvironment('OT_INTERNAL_GOOGLE_AUDIT')) {
    throw StateError('Internal device audit flag required');
  }
  await application.main();
  final clock = Stopwatch()..start();
  final auth = AuthService();
  final prefs = await SharedPreferences.getInstance();
  var dispatched = false;
  var seenGoogle = false;
  var checkingResult = false;
  String? openingUid;
  String? verifiedOwner;
  bool? ready;
  int? dispatchedAt;

  void record(String phase, [Map<String, Object?> details = const {}]) {
    debugPrint('OT_DEVICE_AUDIT ${jsonEncode({
          'phase': phase,
          'elapsed_ms': clock.elapsedMilliseconds,
          ...details,
        })}');
  }

  record('started');
  Timer.periodic(const Duration(milliseconds: 250), (timer) async {
    final root = WidgetsBinding.instance.rootElement;
    if (root == null || checkingResult) return;
    if (!dispatched &&
        auth.hasAuthenticatedSession &&
        auth.cachedCurrentUser != null &&
        _contains<MainShellScreen>(root)) {
      final navigator = _navigator(root);
      if (navigator == null) return;
      dispatched = true;
      openingUid = auth.cachedCurrentUser!.uid;
      verifiedOwner = prefs.getString(PersistentGoogleSession.verifiedOwnerKey);
      ready = prefs.getBool('google_session_ready');
      dispatchedAt = clock.elapsedMilliseconds;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        record('app_entry_dispatched', {'authenticated_app': true});
        navigator.pushNamed(AppRoutes.googleSessionAuth,
            arguments: GoogleConnectionPurpose.appEntry);
      });
      WidgetsBinding.instance.scheduleFrame();
    }
    final hasGoogleScreen = _contains<GoogleSessionAuthScreen>(root);
    if (dispatched && hasGoogleScreen && !seenGoogle) {
      seenGoogle = true;
      record('native_google_screen_visible');
    }
    if (seenGoogle && !hasGoogleScreen && _contains<MainShellScreen>(root)) {
      checkingResult = true;
      timer.cancel();
      bool? cookiePresent;
      try {
        cookiePresent = await PersistentGoogleSession.instance
            .hasLiveSession(null)
            .timeout(const Duration(seconds: 6));
      } catch (_) {}
      record('returned_to_dashboard', {
        'after_dispatch_ms': clock.elapsedMilliseconds - dispatchedAt!,
        'firebase_identity_unchanged': auth.hasAuthenticatedSession &&
            auth.cachedCurrentUser?.uid == openingUid,
        'verified_owner_unchanged':
            prefs.getString(PersistentGoogleSession.verifiedOwnerKey) ==
                verifiedOwner,
        'ready_marker_unchanged':
            prefs.getBool('google_session_ready') == ready,
        'google_cookie_present': cookiePresent,
      });
    }
    if (clock.elapsed > const Duration(minutes: 3)) {
      timer.cancel();
      record('observation_timeout', {'google_screen_seen': seenGoogle});
    }
  });
}
