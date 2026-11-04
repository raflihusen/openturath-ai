import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
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
  Completer<void>? readGate;
  bool reading = false;

  @override
  Future<List<Cookie>> getCookies({
    required WebUri url,
    PlatformInAppWebViewController? iosBelow11WebViewController,
    PlatformInAppWebViewController? webViewController,
  }) async {
    reading = true;
    await readGate?.future;
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

class _AppAuth extends AuthService {
  _AppAuth(this.user);
  UserModel? user;
  bool authenticated = true;
  @override
  bool get hasAuthenticatedSession => authenticated && user != null;
  @override
  UserModel? get cachedCurrentUser => user;
  @override
  fb.User? get currentUser => null;
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
      ..deletions = 0
      ..readGate = null
      ..reading = false;
    platform.lastView = null;
    AuthService.previewUser = UserModel(
        uid: 'app-entry-reader',
        name: 'Reader',
        email: _email,
        photoUrl: '',
        plan: 'trial',
        questionsUsed: 0);
  });
  tearDown(() => AuthService.previewUser = null);

  Future<InAppWebViewController> open(WidgetTester tester,
      {AuthService? authService}) async {
    await tester.pumpWidget(MaterialApp(
      home: GoogleSessionAuthScreen(authService: authService),
      builder: (context, child) => Directionality(
          textDirection: AppConfig.localeNotifier.value == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: child!),
      routes: {
        AppRoutes.dashboard: (_) =>
            const Scaffold(body: Text('OpenTurath home')),
        AppRoutes.login: (_) =>
            const Scaffold(body: Text('OpenTurath sign in')),
      },
    ));
    final native = _Controller();
    platform.lastView!.params.onWebViewCreated!(
        InAppWebViewController.fromPlatform(platform: native));
    return InAppWebViewController.fromPlatform(platform: native);
  }

  Future<void> finishLoad(
      WidgetTester tester, InAppWebViewController controller) async {
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

  for (final locale in ['id', 'en', 'ar']) {
    for (final width in [320.0, 390.0, 1280.0]) {
      testWidgets('app entry action fits $locale at width $width',
          (tester) async {
        AppConfig.localeNotifier.value = locale;
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        try {
          await open(tester);
          expect(tester.takeException(), isNull);
          final action = find.descendant(
              of: find.byType(AppBar),
              matching: find.text(Loc.tr('enterOpenTurath')));
          expect(action, findsOneWidget);
          final bounds = tester.getRect(action);
          expect(bounds.left, greaterThanOrEqualTo(0));
          expect(bounds.right, lessThanOrEqualTo(width));
          await tester.tap(action);
          await tester.pumpAndSettle();
          expect(find.text('OpenTurath home'), findsOneWidget);
        } finally {
          await close(tester);
        }
      });
    }
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

  testWidgets(
      'Google cookies and a cached profile cannot replace app authentication',
      (tester) async {
    final auth = _AppAuth(AuthService.previewUser)..authenticated = false;
    final controller = await open(tester, authService: auth);
    try {
      (controller.platform as _Controller).currentUrl =
          WebUri('https://myaccount.google.com/security');
      await finishLoad(tester, controller);
      expect(find.text('OpenTurath home'), findsNothing);
      await tester.tap(find.descendant(
          of: find.byType(AppBar), matching: find.byType(TextButton)));
      await tester.pumpAndSettle();
      expect(find.text('OpenTurath sign in'), findsOneWidget);
      expect(platform.cookies.deletions, 0);
    } finally {
      await close(tester);
    }
  });

  for (final signOut in [false, true]) {
    testWidgets(
        'late cookie completion cannot enter after ${signOut ? 'logout' : 'account change'}',
        (tester) async {
      final auth = _AppAuth(AuthService.previewUser);
      final gate = Completer<void>();
      platform.cookies.readGate = gate;
      final controller = await open(tester, authService: auth);
      try {
        (controller.platform as _Controller).currentUrl =
            WebUri('https://myaccount.google.com/security');
        platform.lastView!.params.onLoadStop!(
            controller, (controller.platform as _Controller).currentUrl);
        await tester.pump();
        expect(platform.cookies.reading, isTrue);
        if (signOut) {
          auth.authenticated = false;
        } else {
          auth.user = UserModel(
              uid: 'another-reader',
              name: 'Other',
              email: 'other@example.invalid',
              photoUrl: '',
              plan: 'trial',
              questionsUsed: 0);
        }
        gate.complete();
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(find.text('OpenTurath home'), findsNothing);
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('webview_session_owner_verified_v1'), isNull);
        expect(platform.cookies.deletions, 0);
      } finally {
        if (!gate.isCompleted) gate.complete();
        await close(tester);
      }
    });
  }

  testWidgets(
      'late cookie completion is safe after the connection screen closes',
      (tester) async {
    final gate = Completer<void>();
    platform.cookies.readGate = gate;
    final controller = await open(tester);
    (controller.platform as _Controller).currentUrl =
        WebUri('https://myaccount.google.com/security');
    platform.lastView!.params.onLoadStop!(
        controller, (controller.platform as _Controller).currentUrl);
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    gate.complete();
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(platform.cookies.deletions, 0);
  });

  for (final target in [
    'https://accounts.google.com/signin/v2/challenge/pwd',
    'https://accounts.google.com/signin/v2/challenge/otp',
    'https://myaccount.google.com.evil.invalid/security',
    'http://myaccount.google.com/security',
  ]) {
    testWidgets(
        'no automatic completion on challenge or untrusted route: $target',
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
