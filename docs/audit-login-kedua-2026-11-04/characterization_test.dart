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

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:openturath_ai/core/routes.dart';
import 'package:openturath_ai/screens/splash_screen.dart';
import 'package:openturath_ai/services/persistent_google_session.dart';

const _email = 'session-reader@example.invalid';
final _notebookUrl = WebUri('https://notebook.google.com/');

class _Cookies extends PlatformCookieManager {
  _Cookies()
      : super.implementation(const PlatformCookieManagerCreationParams());

  List<Cookie> cookies = [];
  bool failRead = false;
  int deletions = 0;
  int reads = 0;

  @override
  Future<List<Cookie>> getCookies({
    required WebUri url,
    PlatformInAppWebViewController? iosBelow11WebViewController,
    PlatformInAppWebViewController? webViewController,
  }) async {
    reads++;
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
  int emailChecks = 0;

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
    if (source.contains('var selectors =')) {
      emailChecks++;
      return detectedEmail;
    }
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


class _SignedInFirebaseUser extends Fake implements fb.User {
  @override String get uid => 'fixture-firebase-signed-in';
  @override String get email => _email;
  @override bool get isAnonymous => false;
}
class _RestoredAuth extends AuthService {
  @override fb.User get currentUser => _SignedInFirebaseUser();
  @override Future<UserModel?> restoreSession() async => null;
}
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final platform = _WebViewPlatform();
  final routeResults = <bool?>[];
  setUp(() {
    InAppWebViewPlatform.instance = platform;
    AppConfig.localeNotifier.value = 'id';
    SharedPreferences.setMockInitialValues({});
    platform.cookies
      ..cookies = [Cookie(name: 'SID', value: 'synthetic-audit-session')]
      ..failRead = false
      ..deletions = 0
      ..reads = 0;
    platform.lastView = null;
    routeResults.clear();
    AgentSessionManager.instance.closeAll();
    AuthService.previewUser = UserModel(uid: 'fixture-reader', name: 'Fixture Reader',
        email: _email, photoUrl: '', plan: 'trial', questionsUsed: 0);
  });
  tearDown(() {
    AuthService.previewUser = null;
    AgentSessionManager.instance.closeAll();
  });
  Future<InAppWebViewController> open(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) => Scaffold(body: TextButton(
        onPressed: () async => routeResults.add(await Navigator.of(context)
          .push<bool>(MaterialPageRoute(builder: (_) => const GoogleSessionAuthScreen()))),
        child: const Text('Open connection'))))));
    await tester.tap(find.text('Open connection'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    final native = _Controller();
    platform.lastView!.params.onWebViewCreated!(
        InAppWebViewController.fromPlatform(platform: native));
    return InAppWebViewController.fromPlatform(platform: native);
  }
  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 4));
  }
  Future<void> emitLoad(WidgetTester tester, InAppWebViewController controller) async {
    platform.lastView!.params.onLoadStop!(
        controller, (controller.platform as _Controller).currentUrl);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 350));
  }
  for (final target in [
    'https://myaccount.google.com/security',
    'https://myaccount.google.com/',
  ]) {
    testWidgets('AUDIT authenticated-session fixture remains blocked on $target',
        (tester) async {
      final controller = await open(tester);
      final native = controller.platform as _Controller;
      native.currentUrl = WebUri(target);
      await emitLoad(tester, controller);
      for (var tick = 0; tick < 3; tick++) {
        await tester.pump(const Duration(seconds: 3));
      }
      expect(routeResults, isEmpty);
      expect(find.byType(GoogleSessionAuthScreen), findsOneWidget);
      expect(native.emailChecks, 0);
      expect(platform.cookies.reads, 0);
      await tester.tap(find.text(Loc.tr('ui_5bcbc797a7')));
      await tester.pump();
      expect(find.text(Loc.tr('pleaseFinishGoogleLogin')), findsOneWidget);
      expect(routeResults, isEmpty);
      expect(platform.cookies.deletions, 0);
      await close(tester);
    });
  }
  testWidgets('AUDIT the same fixture completes only after reaching Notebook',
      (tester) async {
    final controller = await open(tester);
    final native = controller.platform as _Controller;
    native.currentUrl = WebUri('https://myaccount.google.com/security');
    await emitLoad(tester, controller);
    expect(routeResults, isEmpty);
    native.currentUrl = _notebookUrl;
    await emitLoad(tester, controller);
    expect(routeResults, [true]);
    expect(native.emailChecks, greaterThanOrEqualTo(2));
    expect(platform.cookies.deletions, 0);
    await close(tester);
  });
  testWidgets('AUDIT live cookies plus Yes Signed In still fails without Notebook email',
      (tester) async {
    final controller = await open(tester);
    (controller.platform as _Controller).detectedEmail = null;
    await tester.tap(find.text(Loc.tr('ui_5bcbc797a7')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text(Loc.tr('yesAlreadySignedIn')), findsOneWidget);
    await tester.tap(find.text(Loc.tr('yesAlreadySignedIn')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(routeResults, isEmpty);
    expect(find.text(Loc.tr('googleSessionUnverifiedTitle')), findsOneWidget);
    expect(platform.cookies.deletions, 0);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(PersistentGoogleSession.verifiedOwnerKey), isNull);
    await close(tester);
  });
  testWidgets('AUDIT fallback accepts 3PSID but final persistence rejects this cookie set',
      (tester) async {
    platform.cookies.cookies = [
      Cookie(name: '__Secure-3PSID', value: 'synthetic-audit-3psid')];
    final controller = await open(tester);
    final native = controller.platform as _Controller;
    native.detectedEmail = null;
    await tester.tap(find.text(Loc.tr('ui_5bcbc797a7')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text(Loc.tr('yesAlreadySignedIn')), findsOneWidget);
    native.detectedEmail = _email;
    await tester.tap(find.text(Loc.tr('yesAlreadySignedIn')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(routeResults, isEmpty);
    expect(find.text(Loc.tr('googleSessionUnverifiedTitle')), findsOneWidget);
    expect(platform.cookies.deletions, 0);
    await close(tester);
  });
  testWidgets('AUDIT splash permits authenticated Firebase user without Google readiness',
      (tester) async {
    platform.cookies.cookies = [];
    await tester.pumpWidget(MaterialApp(
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => SplashScreen(authService: _RestoredAuth()),
        AppRoutes.login: (_) => const Scaffold(body: Text('Login destination')),
        AppRoutes.dashboard: (_) => const Scaffold(body: Text('Dashboard destination')),
      }));
    await tester.pumpAndSettle();
    expect(find.text('Dashboard destination'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('google_session_ready'), isFalse);
    expect(platform.cookies.deletions, 0);
    await close(tester);
  });
}
