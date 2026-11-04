import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/localization.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/models/user_model.dart';
import 'package:openturath_ai/services/agent_session_manager.dart';
import 'package:openturath_ai/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:openturath_ai/services/agent_service.dart';
import 'package:openturath_ai/services/diagnostic_report_service.dart';
import 'package:openturath_ai/services/persistent_google_session.dart';
import 'package:openturath_ai/widgets/agent_multi_tab_room.dart';

const _email = 'session-reader@example.invalid';

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

class _UrlService extends AgentService {
  _UrlService([this.error]);
  final AgentAccessException? error;
  @override
  Future<String?> getAgentUrl(String agentId) async {
    if (error != null) throw error!;
    return 'https://notebook.google.com/notebook/00000000-0000-4000-8000-000000000001';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final platform = _WebViewPlatform();
  final manager = AgentSessionManager.instance;
  final agent =
      AgentModel.defaultAgents.firstWhere((a) => a.id == 'fiqh_syafii');
  setUp(() {
    InAppWebViewPlatform.instance = platform;
    SharedPreferences.setMockInitialValues({});
    AppConfig.localeNotifier.value = 'id';
    platform.cookies
      ..cookies = [Cookie(name: 'SID', value: 'synthetic-session')]
      ..failRead = false
      ..deletions = 0;
    platform.lastView = null;
    manager.closeAll();
    AuthService.previewUser = UserModel(
        uid: 'reader',
        name: 'Reader',
        email: _email,
        photoUrl: '',
        plan: 'trial',
        questionsUsed: 0);
  });
  tearDown(() {
    manager.closeAll();
    AuthService.previewUser = null;
  });
  Future<void> open(WidgetTester tester, {AgentAccessException? error}) async {
    manager.openAgent(agent, user: AuthService.previewUser);
    await tester.pumpWidget(
        MaterialApp(home: AgentMultiTabRoom(agentService: _UrlService(error))));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
  }

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 4));
  }

  for (final vip in [false, true]) {
    testWidgets(
        '${vip ? 'VIP' : 'ordinary'} account verifies Google only before opening AI', (tester) async {
      if (vip) {
        AuthService.previewUser = UserModel.fromMap('vip', {
          'email': _email,
          'name': 'VIP Reader',
          'is_vip': true,
          'role': 'vip',
        });
      }
      try {
        await open(tester);
        expect(find.text(Loc.tr('roomLoginNow')), findsOneWidget);
        expect(find.text(Loc.tr('roomSeePlans')), findsNothing);
        expect(find.byType(InAppWebView), findsNothing);
        expect(manager.activeTab!.isSessionReady, isFalse);
        expect(platform.cookies.deletions, 0);
      } finally {
        await close(tester);
      }
    });
  }
  testWidgets(
      'matching verified owner opens AI without another account connection',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'webview_session_owner': _email,
      PersistentGoogleSession.verifiedOwnerKey: _email,
    });
    try {
      await open(tester);
      expect(find.byType(InAppWebView), findsOneWidget);
      expect(find.text(Loc.tr('roomLoginNow')), findsNothing);
      expect(platform.cookies.deletions, 0);
    } finally {
      await close(tester);
    }
  });

  testWidgets('failure before a URL reaches the report with the original cause',
      (tester) async {
    try {
      await open(tester,
          error: const AgentAccessException(
              'failed-precondition', 'Preparing access',
              reason: 'access_provisioning',
              requestId: '11111111-2222-4333-8444-555555555555'));
      final payload = DiagnosticReportService.payload(
          stage: 'room-load',
          code: 'load-failed',
          failure: manager.activeTab!.failure);
      expect(payload['stage'], 'agent-url');
      expect(payload['code'], 'failed-precondition');
      expect(payload['reason'], 'access_provisioning');
      expect(payload['agent_id'], 'fiqh_syafii');
      expect(payload['request_id'], '11111111-2222-4333-8444-555555555555');
      expect(find.text(Loc.tr('roomSeePlans')), findsNothing);
    } finally {
      await close(tester);
    }
  });

  for (final vip in [false, true]) {
    testWidgets('server entitlement decision preserves VIP=$vip',
        (tester) async {
      AuthService.previewUser = UserModel.fromMap('reader', {
        'email': _email,
        'name': 'Reader',
        'is_vip': vip,
        'entitlements': {
          'fiqh_syafii': {
            'status': 'active',
            'plan': 'yearly',
            'expiry':
                DateTime.now().add(const Duration(days: 365)).toIso8601String()
          }
        },
      });
      try {
        await open(tester,
            error: const AgentAccessException(
                'permission-denied', 'Entitlement required',
                reason: 'entitlement_required'));
        expect(manager.activeTab!.isPaywallRequired, !vip);
        expect(find.text(Loc.tr('roomSeePlans')),
            vip ? findsNothing : findsOneWidget);
        expect(platform.cookies.deletions, 0);
      } finally {
        await close(tester);
      }
    });
  }
}
