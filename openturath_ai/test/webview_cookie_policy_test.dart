import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/webview_cookie_policy.dart';

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  for (final platform in TargetPlatform.values) {
    test('native WebView settings preserve the cookie policy on $platform', () {
      debugDefaultTargetPlatformOverride = platform;
      final settings = InAppWebViewSettings(
        incognito: false,
        sharedCookiesEnabled: WebViewCookiePolicy.sharedCookiesEnabled,
      ).toMap();

      expect(settings['sharedCookiesEnabled'], platform != TargetPlatform.macOS,
          reason: 'Only macOS must avoid replaying Foundation cookies into '
              'WebKit; other platforms keep their existing configuration.');
      expect(settings['incognito'], isFalse,
          reason: 'Disabling the Foundation bridge must retain the persistent '
              'WebKit store.');
    });
  }

  test('login, study room and checkout all use the shared cookie policy', () {
    // Native WebViews cannot run in Flutter unit tests. Guard their actual
    // configuration sites so a new view cannot reintroduce a stale-cookie replay.
    final setting = RegExp(r'sharedCookiesEnabled\s*:\s*([^,]+),');
    for (final path in [
      'lib/screens/google_session_auth_screen.dart',
      'lib/widgets/agent_multi_tab_room.dart',
      'lib/widgets/payment_checkout_sheet.dart',
    ]) {
      final values = setting
          .allMatches(File(path).readAsStringSync())
          .map((match) => match.group(1)!.replaceAll(RegExp(r'\s+'), ''))
          .toList();
      expect(values, isNotEmpty, reason: '$path must set its cookie policy');
      expect(values, everyElement('WebViewCookiePolicy.sharedCookiesEnabled'),
          reason: '$path must not replay the shared HTTP cookie jar on macOS');
    }
  });
}
