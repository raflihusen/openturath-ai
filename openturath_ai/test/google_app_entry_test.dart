import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/localization.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/models/user_model.dart';
import 'package:openturath_ai/screens/google_session_auth_screen.dart';
import 'package:openturath_ai/services/agent_session_manager.dart';
import 'package:openturath_ai/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:openturath_ai/core/routes.dart';

const _email = 'session-reader@example.invalid';
final _notebookUrl = WebUri('https://notebook.google.com/');

class _Cookies extends PlatformCookieManager {
  _Cookies()
      : super.implementation(const PlatformCookieManagerCreationParams());

  List<Cookie> cookies = [];
  bool failRead = false;
  int deletions = 0;

  @override
  Future<List<Cookie>> getCookies({
    required WebUri url,
    PlatformInAppWebViewController? iosBelow11WebViewController,
    PlatformInAppWebViewController? webViewController,
  }) async {
    if (failRead) throw PlatformException(code: 'fixture-cookie-read-failed');
    return cookies;
  }

  @override
  Future<bool> deleteAllCookies() async {
    deletions++;
    cookies = [];
    return true;
  }
}

class _Controller extends PlatformInAppWebViewController {
  _Controller()
      : super.implementation(
            const PlatformInAppWebViewControllerCreationParams(id: 'fixture'));

  String? detectedEmail = _email;
  bool failUrlRead = false;
  WebUri currentUrl = _notebookUrl;

  @override
  Future<WebUri?> getUrl() async {
    if (failUrlRead) throw PlatformException(code: 'fixture-disposed-view');
    return currentUrl;
  }

  @override
  Future<dynamic> evaluateJavascript({
    required String source,
    ContentWorld? contentWorld,
  }) async {
    if (source.contains('var selectors =')) return detectedEmail;
    return null;
  }

  @override
  Future<bool> canGoBack() async => false;

  @override
  Future<void> loadUrl({
    required URLRequest urlRequest,
    Uri? iosAllowingReadAccessTo,
    WebUri? allowingReadAccessTo,
  }) async {}

  @override
  Future<void> reload() async {}
}

class _WebView extends PlatformInAppWebViewWidget {
  _WebView(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) => const SizedBox();

  @override
  T controllerFromPlatform<T>(PlatformInAppWebViewController controller) =>
      params.controllerFromPlatform!(controller) as T;

  @override
  void dispose() {}
}

class _WebViewPlatform extends InAppWebViewPlatform {
  final cookies = _Cookies();
  _WebView? lastView;

  @override
  PlatformCookieManager createPlatformCookieManager(
          PlatformCookieManagerCreationParams params) =>
      cookies;

  @override
  PlatformInAppWebViewWidget createPlatformInAppWebViewWidget(
      PlatformInAppWebViewWidgetCreationParams params) {
    return lastView = _WebView(params);
  }
}


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final platform = _WebViewPlatform();

  setUp(() {
    InAppWebViewPlatform.instance = platform;
    AppConfig.localeNotifier.value = 'id';
    SharedPreferences.setMockInitialValues({});
    platform.cookies
      ..cookies = [Cookie(name: 'SID', value: 'synthetic-session')]
      ..failRead = false
      ..deletions = 0;
    platform.lastView = null;
    AuthService.previewUser = UserModel(
      uid: 'app-entry-reader', name: 'Reader', email: _email,
      photoUrl: '', plan: 'trial', questionsUsed: 0);
  });
  tearDown(() => AuthService.previewUser = null);

  Future<InAppWebViewController> open(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: const GoogleSessionAuthScreen(),
      routes: {
        AppRoutes.dashboard: (_) => const Scaffold(body: Text('OpenTurath home')),
        AppRoutes.login: (_) => const Scaffold(body: Text('OpenTurath sign in')),
      },
    ));
    final native = _Controller();
    platform.lastView!.params.onWebViewCreated!(
      InAppWebViewController.fromPlatform(platform: native));
    return InAppWebViewController.fromPlatform(platform: native);
  }

  Future<void> finishLoad(WidgetTester tester,
      InAppWebViewController controller) async {
    platform.lastView!.params.onLoadStop!(
      controller, (controller.platform as _Controller).currentUrl);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 350));
  }

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 4));
  }

  for (final target in [
    'https://myaccount.google.com/',
    'https://myaccount.google.com/security',
    'https://myaccount.google.com/signinoptions/recovery-email',
  ]) {
    testWidgets('signed-in account page enters app without Notebook: $target',
        (tester) async {
      final controller = await open(tester);
      try {
        (controller.platform as _Controller)
          ..currentUrl = WebUri(target)
          ..detectedEmail = null;
        await finishLoad(tester, controller);
        expect(find.text('OpenTurath home'), findsOneWidget);
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('google_session_ready'), isNot(true));
        expect(prefs.getString('webview_session_owner_verified_v1'), isNull);
        expect(platform.cookies.deletions, 0);
      } finally {
        await close(tester);
      }
    });
  }

  testWidgets('manual app entry works while browser session is unverified',
      (tester) async {
    platform.cookies.cookies = [];
    final controller = await open(tester);
    try {
      (controller.platform as _Controller).currentUrl =
          WebUri('https://accounts.google.com/InteractiveLogin');
      await tester.tap(find.descendant(
        of: find.byType(AppBar), matching: find.byType(TextButton)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text('OpenTurath home'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('google_session_ready'), isNot(true));
      expect(platform.cookies.deletions, 0);
    } finally {
      await close(tester);
    }
  });

  testWidgets('unreadable WebView cannot block entering an authenticated app',
      (tester) async {
    final controller = await open(tester);
    try {
      (controller.platform as _Controller).failUrlRead = true;
      await tester.tap(find.descendant(
        of: find.byType(AppBar), matching: find.byType(TextButton)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text('OpenTurath home'), findsOneWidget);
      expect(platform.cookies.deletions, 0);
    } finally {
      await close(tester);
    }
  });

  for (final target in [
    'https://accounts.google.com/signin/v2/challenge/pwd',
    'https://accounts.google.com/signin/v2/challenge/otp',
    'https://myaccount.google.com.evil.invalid/security',
    'http://myaccount.google.com/security',
  ]) {
    testWidgets('no automatic completion on challenge or untrusted route: $target',
        (tester) async {
      final controller = await open(tester);
      try {
        (controller.platform as _Controller).currentUrl = WebUri(target);
        await finishLoad(tester, controller);
        expect(find.text('OpenTurath home'), findsNothing);
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('webview_session_owner_verified_v1'), isNull);
        expect(platform.cookies.deletions, 0);
      } finally {
        await close(tester);
      }
    });
  }
}
