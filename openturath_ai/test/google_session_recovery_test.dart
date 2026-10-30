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

  @override
  Future<WebUri?> getUrl() async {
    if (failUrlRead) throw PlatformException(code: 'fixture-disposed-view');
    return _notebookUrl;
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
  _WebView(PlatformInAppWebViewWidgetCreationParams params)
      : super.implementation(params);

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
  // CookieManager.instance retains its platform object, so keep one fake for
  // this file and reset its state between cases rather than replacing it.
  final platform = _WebViewPlatform();
  final routeResults = <bool?>[];
  late UserModel user;

  setUp(() {
    InAppWebViewPlatform.instance = platform;
    AppConfig.localeNotifier.value = 'id';
    SharedPreferences.setMockInitialValues({});
    platform.cookies
      ..cookies = []
      ..failRead = false
      ..deletions = 0;
    platform.lastView = null;
    routeResults.clear();
    AgentSessionManager.instance.closeAll();
    user = UserModel(
      uid: 'fixture-session-reader',
      name: 'Session Reader',
      email: _email,
      photoUrl: '',
      plan: 'trial',
      questionsUsed: 0,
    );
    AuthService.previewUser = user;
  });

  tearDown(() {
    AuthService.previewUser = null;
    AgentSessionManager.instance.closeAll();
  });

  Future<InAppWebViewController> open(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        return Scaffold(
          body: TextButton(
            onPressed: () async {
              final result = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                    builder: (_) => const GoogleSessionAuthScreen()),
              );
              routeResults.add(result);
            },
            child: const Text('Open Google connection'),
          ),
        );
      }),
    ));
    await tester.tap(find.text('Open Google connection'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    final nativeController = _Controller();
    platform.lastView!.params.onWebViewCreated!(
        InAppWebViewController.fromPlatform(platform: nativeController));
    // The macOS plugin wraps the same platform controller separately for
    // onWebViewCreated and later navigation events.
    return InAppWebViewController.fromPlatform(platform: nativeController);
  }

  Future<void> finishLoad(
      WidgetTester tester, InAppWebViewController controller) async {
    platform.lastView!.params.onLoadStop!(controller, _notebookUrl);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 350));
  }

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    // Warning SnackBars may have already scheduled their minimum display time
    // while the connection view was mounted. Drain those fixture timers too.
    await tester.pump(const Duration(seconds: 4));
  }

  for (final failRead in [false, true]) {
    testWidgets(
        'matching DOM email with ${failRead ? 'unreadable' : 'missing'} cookies does not complete connection',
        (tester) async {
      platform.cookies.failRead = failRead;
      final controller = await open(tester);
      await finishLoad(tester, controller);

      final prefs = await SharedPreferences.getInstance();
      expect(routeResults, isEmpty);
      expect(find.byType(GoogleSessionAuthScreen), findsOneWidget);
      expect(prefs.getBool('google_session_ready'), isNot(true));
      expect(prefs.getString('webview_session_owner'), isNull);
      expect(platform.cookies.deletions, 0);
      await close(tester);
    });
  }

  testWidgets('successful Google session completes with verified owner',
      (tester) async {
    platform.cookies.cookies = [Cookie(name: 'SID', value: 'fixture-only')];
    final controller = await open(tester);
    await finishLoad(tester, controller);

    final prefs = await SharedPreferences.getInstance();
    expect(routeResults, [true]);
    expect(prefs.getBool('google_session_ready'), isTrue);
    expect(prefs.getString('webview_session_owner'), _email);
    expect(prefs.getString('google_session_email'), _email);
    expect(platform.cookies.deletions, 0);
    await close(tester);
  });

  testWidgets(
      'recovery replaces the WebView and retry connects a valid session',
      (tester) async {
    final controller = await open(tester);
    final failedView = platform.lastView;
    await finishLoad(tester, controller);

    expect(find.text(Loc.tr('googleSessionUnverifiedTitle')), findsOneWidget);
    expect(find.text(Loc.tr('verifyingSessionTitle')), findsNothing);
    expect(find.byType(InAppWebView), findsNothing);
    expect(routeResults, isEmpty);

    platform.cookies.cookies = [Cookie(name: 'SID', value: 'fixture-only')];
    await tester.tap(find.text(Loc.tr('tryAgain')));
    await tester.pump();
    expect(find.byType(InAppWebView), findsOneWidget);
    expect(platform.lastView, isNot(same(failedView)));
    expect(platform.lastView!.params.initialUrlRequest!.url.toString(),
        'https://notebook.google.com/');
    final retryNativeController = _Controller();
    platform.lastView!.params.onWebViewCreated!(
        InAppWebViewController.fromPlatform(platform: retryNativeController));
    final retryController =
        InAppWebViewController.fromPlatform(platform: retryNativeController);

    // A disposed view can deliver a late event after replacement. Its failed
    // platform call must not replace the new view with another recovery state.
    (controller.platform as _Controller).failUrlRead = true;
    failedView!.params.onLoadStop!(controller, _notebookUrl);
    await tester.pump();
    expect(find.byType(InAppWebView), findsOneWidget);
    expect(find.text(Loc.tr('googleSessionUnverifiedTitle')), findsNothing);
    await finishLoad(tester, retryController);

    final prefs = await SharedPreferences.getInstance();
    expect(routeResults, [true]);
    expect(prefs.getBool('google_session_ready'), isTrue);
    expect(prefs.getString('webview_session_owner'), _email);
    expect(platform.cookies.deletions, 0);
    await close(tester);
  });

  testWidgets('canceling Google connection preserves account, cookies and tabs',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'google_session_ready': true,
      'webview_session_owner': _email,
      'google_session_email': _email,
      'notebook_google_email': _email,
    });
    platform.cookies.cookies = [Cookie(name: 'SID', value: 'fixture-only')];
    final manager = AgentSessionManager.instance;
    manager.openAgent(AgentModel.defaultAgents.first);
    final existingTab = manager.activeTab;
    await open(tester);

    await tester.tap(find.byTooltip(Loc.tr('cancelSignIn')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text(Loc.tr('cancelGoogleConnectionTitle')), findsOneWidget);
    await tester.tap(find.text(Loc.tr('cancelGoogleConnectionAction')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    final prefs = await SharedPreferences.getInstance();
    expect(routeResults, [false]);
    expect(AuthService.previewUser, same(user));
    expect(manager.activeTab, same(existingTab));
    expect(manager.tabs, [existingTab]);
    expect(platform.cookies.deletions, 0);
    expect(platform.cookies.cookies.single.name, 'SID');
    expect(prefs.getBool('google_session_ready'), isTrue);
    expect(prefs.getString('webview_session_owner'), _email);
    expect(prefs.getString('google_session_email'), _email);
    await close(tester);
  });

  testWidgets('verification cannot dismiss the open cancellation dialog',
      (tester) async {
    platform.cookies.cookies = [Cookie(name: 'SID', value: 'fixture-only')];
    final controller = await open(tester);
    await tester.tap(find.byTooltip(Loc.tr('cancelSignIn')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text(Loc.tr('cancelGoogleConnectionTitle')), findsOneWidget);

    // A late page-load callback can arrive while the user is deciding. It
    // must not pop the dialog with a result that impersonates their choice.
    await finishLoad(tester, controller);

    expect(routeResults, isEmpty);
    expect(find.text(Loc.tr('cancelGoogleConnectionTitle')), findsOneWidget);
    await tester.tap(find.text(Loc.tr('cancelGoogleConnectionAction')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(routeResults, [false]);
    expect(platform.cookies.deletions, 0);
    expect(platform.cookies.cookies.single.name, 'SID');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('google_session_ready'), isNot(true));
    expect(prefs.getString('webview_session_owner'), isNull);
    await close(tester);
  });

  testWidgets('manual continue cannot accept unreadable session as confirmed',
      (tester) async {
    platform.cookies.failRead = true;
    final controller = await open(tester);
    (controller.platform as _Controller).detectedEmail = null;

    await tester.tap(find.text(Loc.tr('ui_5bcbc797a7')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    // A confirmation is only a request to recheck; it cannot substitute for
    // evidence that Google accepted the session and the expected account.
    if (find.text(Loc.tr('yesAlreadySignedIn')).evaluate().isNotEmpty) {
      await tester.tap(find.text(Loc.tr('yesAlreadySignedIn')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 350));
    }
    expect(routeResults, isEmpty);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('google_session_ready'), isNot(true));
    expect(prefs.getString('webview_session_owner'), isNull);
    expect(platform.cookies.deletions, 0);
    await close(tester);
  });
}
