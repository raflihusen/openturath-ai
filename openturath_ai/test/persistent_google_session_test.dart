import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/services/auth_service.dart';
import 'package:openturath_ai/services/persistent_google_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _CookiePlatform extends InAppWebViewPlatform {
  final manager = _MemoryCookieManager();

  @override
  PlatformCookieManager createPlatformCookieManager(
    PlatformCookieManagerCreationParams params,
  ) =>
      manager;
}

class _MemoryCookieManager extends PlatformCookieManager {
  _MemoryCookieManager()
      : super.implementation(const PlatformCookieManagerCreationParams());

  final cookies = <Cookie>[];
  int reads = 0;
  int writes = 0;
  int deletes = 0;

  @override
  Future<List<Cookie>> getCookies({
    required WebUri url,
    PlatformInAppWebViewController? iosBelow11WebViewController,
    PlatformInAppWebViewController? webViewController,
  }) async {
    reads++;
    return List.of(cookies);
  }

  @override
  Future<bool> setCookie({
    required WebUri url,
    required String name,
    required String value,
    String path = '/',
    String? domain,
    int? expiresDate,
    int? maxAge,
    bool? isSecure,
    bool? isHttpOnly,
    HTTPCookieSameSitePolicy? sameSite,
    PlatformInAppWebViewController? iosBelow11WebViewController,
    PlatformInAppWebViewController? webViewController,
  }) async {
    writes++;
    return true;
  }

  @override
  Future<bool> deleteAllCookies() async {
    deletes++;
    cookies.clear();
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final platform = _CookiePlatform();
  final session = PersistentGoogleSession.instance;
  const ownerKey = AuthService.webSessionOwnerKey;
  const verifiedOwnerKey = PersistentGoogleSession.verifiedOwnerKey;
  const accountA = 'account-a@example.test';
  const accountB = 'account-b@example.test';

  setUpAll(() {
    InAppWebViewPlatform.instance = platform;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    platform.manager
      ..reads = 0
      ..writes = 0
      ..deletes = 0;
    platform.manager.cookies
      ..clear()
      ..add(Cookie(name: 'SID', value: 'synthetic-session-a'));
  });

  tearDown(() {
    expect(platform.manager.writes, 0,
        reason: 'Ownership checks must never replay native cookies.');
    expect(platform.manager.deletes, 0,
        reason: 'Switching an app account must preserve native cookies.');
    expect(platform.manager.cookies.single.value, 'synthetic-session-a');
  });

  test('account B cannot inherit account A session after reconciliation',
      () async {
    SharedPreferences.setMockInitialValues({
      ownerKey: accountA,
      verifiedOwnerKey: accountA,
      'google_session_ready': true,
    });

    await AuthService.reconcileWebSession(accountB);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(ownerKey), isNull);
    expect(prefs.getString(verifiedOwnerKey), isNull);
    expect(prefs.getBool('google_session_ready'), false);
    expect(await session.restoreSessionIfAvailable(accountB), false);
    expect(platform.manager.reads, 0);
  });

  test('an unowned native cookie is not assigned to the app account', () async {
    await AuthService.reconcileWebSession(accountB);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(ownerKey), isNull);
    expect(await session.restoreSessionIfAvailable(accountB), false);
    expect(prefs.getBool('google_session_ready'), false);
    expect(platform.manager.reads, 0);
  });

  test('room callback cannot establish or replace a verified owner', () async {
    await AuthService.rememberWebSessionOwner(accountB);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(ownerKey), isNull);

    await prefs.setString(ownerKey, accountA);
    await AuthService.rememberWebSessionOwner(accountB);
    expect(prefs.getString(ownerKey), accountA);
    expect(platform.manager.reads, 0);
  });

  test('matching verified owner keeps its native session without mutation',
      () async {
    SharedPreferences.setMockInitialValues({
      ownerKey: accountA,
      verifiedOwnerKey: accountA,
    });

    await AuthService.reconcileWebSession(' ACCOUNT-A@EXAMPLE.TEST ');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(ownerKey), accountA);
    expect(prefs.getString(verifiedOwnerKey), accountA);
    expect(prefs.getBool('google_session_ready'), true);
    expect(platform.manager.reads, 1);
  });

  test('verified onboarding can establish ownership for a live native session',
      () async {
    expect(await session.lockAndPersistCookies(null, accountA), true);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(ownerKey), accountA);
    expect(prefs.getString(verifiedOwnerKey), accountA);
    expect(prefs.getBool('google_session_ready'), true);
    expect(await session.restoreSessionIfAvailable(accountA), true);
    expect(await session.restoreSessionIfAvailable(accountB), false);
    expect(prefs.getBool('google_session_ready'), false);
  });

  test('an empty account cannot establish ownership from a native cookie',
      () async {
    expect(await session.lockAndPersistCookies(null, '  '), false);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(ownerKey), isNull);
    expect(prefs.getBool('google_session_ready'), isNot(true));
    expect(platform.manager.reads, 0);
  });

  test('legacy owner requires identity verification without deleting cookies',
      () async {
    SharedPreferences.setMockInitialValues({
      ownerKey: accountA,
      'google_session_ready': true,
    });

    await AuthService.reconcileWebSession(accountA);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(ownerKey), accountA);
    expect(prefs.getString(verifiedOwnerKey), isNull);
    expect(prefs.getBool('google_session_ready'), false);
    expect(platform.manager.reads, 0);

    await AuthService.rememberWebSessionOwner(accountA);
    expect(prefs.getString(verifiedOwnerKey), isNull);
    expect(await session.restoreSessionIfAvailable(accountA), false);

    // Only the verified onboarding callback can upgrade the legacy owner.
    expect(await session.lockAndPersistCookies(null, accountA), true);
    expect(prefs.getString(verifiedOwnerKey), accountA);
    expect(await session.restoreSessionIfAvailable(accountA), true);
  });
}
