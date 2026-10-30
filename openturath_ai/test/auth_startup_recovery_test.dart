import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:openturath_ai/core/localization.dart';
import 'package:openturath_ai/core/routes.dart';
import 'package:openturath_ai/main.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/services/agent_service.dart';
import 'package:openturath_ai/widgets/specialist_card.dart';
import 'package:openturath_ai/models/user_model.dart';
import 'package:openturath_ai/screens/dashboard_screen.dart';
import 'package:openturath_ai/screens/splash_screen.dart';
import 'package:openturath_ai/services/auth_service.dart';

class TestUser extends Fake implements User {
  TestUser(this.uid, {this.isAnonymous = false});
  @override
  final String uid;
  @override
  final bool isAnonymous;
  @override
  String get email => '$uid@example.test';
  @override
  String get displayName => 'Account $uid';
  @override
  String? get photoURL => null;
}

class TestCredential extends Fake implements UserCredential {
  TestCredential(this.user);
  @override
  final User user;
}

class TestAuth extends Fake implements FirebaseAuth {
  User? user;
  int credentialCalls = 0;
  int signOutCalls = 0;
  Completer<UserCredential>? pendingCredential;
  FirebaseAuthException? credentialFailure;
  Completer<void>? signOutWait;
  int nativeInFlight = 0;
  int maxNativeInFlight = 0;
  @override
  User? get currentUser => user;
  @override
  Stream<User?> authStateChanges() => Stream.value(user);
  @override
  Future<UserCredential> signInWithCredential(AuthCredential credential) {
    credentialCalls++;
    nativeInFlight++;
    if (nativeInFlight > maxNativeInFlight) maxNativeInFlight = nativeInFlight;
    final result = credentialFailure == null
        ? pendingCredential!.future
        : Future<UserCredential>.error(credentialFailure!);
    return result.then((result) {
      user = result.user;
      return result;
    }).whenComplete(() => nativeInFlight--);
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    await signOutWait?.future;
    user = null;
  }
}

class TestTokens extends Fake implements GoogleSignInAuthentication {
  @override
  String get accessToken => 'test-access';
  @override
  String get idToken => 'test-id';
}

class TestGoogleAccount extends Fake implements GoogleSignInAccount {
  TestGoogleAccount(this.tokens, {this.email = 'google@example.test'});
  final Future<GoogleSignInAuthentication> tokens;
  @override
  final String email;
  @override
  Future<GoogleSignInAuthentication> get authentication => tokens;
}

class TestGoogle extends Fake implements GoogleSignIn {
  GoogleSignInAccount? account;
  int authorizeCalls = 0;
  int silentCalls = 0;
  @override
  Future<GoogleSignInAccount?> signIn() async {
    authorizeCalls++;
    return account;
  }

  @override
  Future<GoogleSignInAccount?> signInSilently({
    bool suppressErrors = true,
    bool reAuthenticate = false,
  }) async {
    silentCalls++;
    return account;
  }

  @override
  Future<GoogleSignInAccount?> signOut() async => null;
}

class DashboardAuth extends AuthService {
  User? user;
  UserModel? cached;
  final events = StreamController<UserModel?>.broadcast();
  @override
  User? get currentUser => user;
  @override
  UserModel? get cachedCurrentUser => cached;
  @override
  Stream<UserModel?> get userStream => events.stream;
  @override
  Future<UserModel?> getCurrentUserModel() async => cached;
  @override
  Future<UserModel?> restoreSession() async => cached;
}

class PendingAgents extends AgentService {
  final result = Completer<List<AgentModel>>();
  @override
  Future<List<AgentModel>> getAgents(
          {bool forceRefresh = false, dynamic firestore}) =>
      result.future;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  UserModel profile(String uid) => UserModel(
        uid: uid,
        name: 'Cached $uid',
        email: '$uid@example.test',
        photoUrl: '',
        plan: 'bahits_1y',
        questionsUsed: 4,
      );

  setUp(() {
    AuthService.previewUser = null;
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    AuthService.previewUser = null;
  });

  test('disk profile without Firebase session is never authenticated',
      () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    SharedPreferences.setMockInitialValues({
      'current_user_uid': 'old-cache',
      'openturath_cached_user_old-cache':
          jsonEncode(profile('old-cache').toJsonMap()),
      'webview_session_owner': 'old-cache@example.test',
      'google_session_ready': true,
    });
    final auth = TestAuth();
    final service = AuthService(auth: auth, googleSignIn: TestGoogle());
    expect(await service.restoreSession(), isNull);
    expect(service.cachedCurrentUser, isNull);
    expect(await service.getCurrentUserModel(), isNull);
    expect(auth.signOutCalls, 0);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('webview_session_owner'), 'old-cache@example.test');
    expect(prefs.getBool('google_session_ready'), isTrue);
  });

  test('offline cache retains profile only for authenticated matching UID',
      () async {
    SharedPreferences.setMockInitialValues({
      'current_user_uid': 'offline-owner',
      'openturath_cached_user_offline-owner':
          jsonEncode(profile('offline-owner').toJsonMap()),
    });
    final auth = TestAuth()..user = TestUser('offline-owner');
    final service = AuthService(auth: auth, googleSignIn: TestGoogle());
    expect((await service.restoreSession())?.name, 'Cached offline-owner');
    expect(service.cachedCurrentUser?.plan, 'bahits_1y');
    auth.user = TestUser('different-owner');
    expect((await service.restoreSession())?.uid, 'different-owner');
    expect(service.cachedCurrentUser?.name, 'Account different-owner');
    auth.user = null;
    expect(service.cachedCurrentUser, isNull);
  });

  test('unauthenticated delete reports recent login instead of succeeding',
      () async {
    final service = AuthService(auth: TestAuth(), googleSignIn: TestGoogle());
    await expectLater(
        service.deleteAccount(),
        throwsA(
          isA<FirebaseAuthException>()
              .having((e) => e.code, 'code', 'requires-recent-login'),
        ));
  });

  test('anonymous account cannot restore or delete a real account', () async {
    final auth = TestAuth()..user = TestUser('guest', isAnonymous: true);
    final service = AuthService(auth: auth, googleSignIn: TestGoogle());
    expect(await service.restoreSession(), isNull);
    expect(await service.getCurrentUserModel(), isNull);
    await expectLater(
        service.deleteAccount(), throwsA(isA<FirebaseAuthException>()));
  });

  test(
      'late Google token after deadline cannot start Firebase credential login',
      () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    final tokens = Completer<GoogleSignInAuthentication>();
    final auth = TestAuth();
    final google = TestGoogle()..account = TestGoogleAccount(tokens.future);
    final service = AuthService(
        auth: auth,
        googleSignIn: google,
        restoreTimeout: const Duration(milliseconds: 40));
    expect(await service.restoreSession(), isNull);
    tokens.complete(TestTokens());
    await Future<void>.delayed(Duration.zero);
    expect(auth.credentialCalls, 0);
    expect(auth.signOutCalls, 0);
  });

  test('credential deadline leaves native Google metadata intact', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    SharedPreferences.setMockInitialValues({
      'webview_session_owner': 'kept@example.test',
      'webview_session_owner_verified_v1': 'kept@example.test',
      'google_session_ready': true,
    });
    final pending = Completer<UserCredential>();
    final auth = TestAuth()..pendingCredential = pending;
    final google = TestGoogle()
      ..account = TestGoogleAccount(Future.value(TestTokens()));
    final service = AuthService(
        auth: auth,
        googleSignIn: google,
        restoreTimeout: const Duration(milliseconds: 40));
    expect(await service.restoreSession(), isNull);
    expect(auth.credentialCalls, 1);
    expect(auth.signOutCalls, 0);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('webview_session_owner_verified_v1'),
        'kept@example.test');
    expect(prefs.getBool('google_session_ready'), isTrue);
    final user = TestUser('late-owner');
    auth.user = user;
    pending.complete(TestCredential(user));
    await Future<void>.delayed(Duration.zero);
    expect(auth.signOutCalls, 0);
  });

  test('explicit logout wins over an earlier pending credential request',
      () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    final pending = Completer<UserCredential>();
    final auth = TestAuth()..pendingCredential = pending;
    final google = TestGoogle()
      ..account = TestGoogleAccount(Future.value(TestTokens()));
    final service = AuthService(
        auth: auth,
        googleSignIn: google,
        restoreTimeout: const Duration(milliseconds: 40),
        authenticationTimeout: const Duration(milliseconds: 40));
    final restored = service.restoreSession();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(auth.credentialCalls, 1);
    await service.signOut();
    final user = TestUser('logged-out-owner');
    auth.user = user;
    pending.complete(TestCredential(user));
    expect(await restored, isNull);
    await Future<void>.delayed(Duration.zero);
    expect(auth.currentUser, isNull);
    expect(auth.signOutCalls, 2);
  });

  test(
      'interactive Google token cannot keep the login operation pending forever',
      () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    final token = Completer<GoogleSignInAuthentication>();
    final auth = TestAuth();
    final google = TestGoogle()..account = TestGoogleAccount(token.future);
    final service = AuthService(
        auth: auth,
        googleSignIn: google,
        authenticationTimeout: const Duration(milliseconds: 40));
    await expectLater(
        service.signInWithGoogle(), throwsA(isA<TimeoutException>()));
    token.complete(TestTokens());
    await Future<void>.delayed(Duration.zero);
    expect(auth.credentialCalls, 0);
    expect(auth.signOutCalls, 0);
  });

  test('new interactive login invalidates a previous account token completion',
      () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    final token = Completer<GoogleSignInAuthentication>();
    final auth = TestAuth();
    final oldGoogle = TestGoogle()..account = TestGoogleAccount(token.future);
    final first =
        AuthService(auth: auth, googleSignIn: oldGoogle).signInWithGoogle();
    await Future<void>.delayed(Duration.zero);
    final newer = AuthService(auth: auth, googleSignIn: TestGoogle());
    expect(await newer.signInWithGoogle(), isNull);
    token.complete(TestTokens());
    expect(await first, isNull);
    expect(auth.credentialCalls, 0);
    expect(
        (await SharedPreferences.getInstance()).getString('current_user_uid'),
        isNull);
  });

  test(
      'interactive Firebase credential deadline never publishes a late profile',
      () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    final pending = Completer<UserCredential>();
    final auth = TestAuth()..pendingCredential = pending;
    final google = TestGoogle()
      ..account = TestGoogleAccount(Future.value(TestTokens()));
    final service = AuthService(
        auth: auth,
        googleSignIn: google,
        authenticationTimeout: const Duration(milliseconds: 40));
    await expectLater(
        service.signInWithGoogle(), throwsA(isA<TimeoutException>()));
    final user = TestUser('late-interactive-owner');
    auth.user = user;
    pending.complete(TestCredential(user));
    await Future<void>.delayed(Duration.zero);
    expect(
        (await SharedPreferences.getInstance()).getString('current_user_uid'),
        isNull);
    expect(auth.signOutCalls, 0);
  });

  test(
      'pending native A blocks account B before authorization until explicit retry',
      () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    final pendingA = Completer<UserCredential>();
    final auth = TestAuth()..pendingCredential = pendingA;
    final googleA = TestGoogle()
      ..account = TestGoogleAccount(Future.value(TestTokens()));
    final serviceA = AuthService(
        auth: auth,
        googleSignIn: googleA,
        restoreTimeout: const Duration(milliseconds: 30));
    expect(await serviceA.restoreSession(), isNull);
    expect(auth.credentialCalls, 1);
    final googleB = TestGoogle()
      ..account = TestGoogleAccount(Future.value(TestTokens()));
    final serviceB = AuthService(
        auth: auth,
        googleSignIn: googleB,
        authenticationTimeout: const Duration(milliseconds: 30));
    await expectLater(
        serviceB.signInWithGoogle(),
        throwsA(isA<FirebaseAuthException>()
            .having((e) => e.code, 'code', 'auth-operation-in-progress')));
    expect(googleB.authorizeCalls, 0);
    expect(auth.credentialCalls, 1);
    pendingA.complete(TestCredential(TestUser('native-A')));
    await Future<void>.delayed(Duration.zero);
    expect(googleB.authorizeCalls, 0);
    expect(auth.credentialCalls, 1); // Timed-out B must never dispatch later.
    final pendingB = Completer<UserCredential>();
    auth.pendingCredential = pendingB;
    final retry = serviceB.signInWithGoogle();
    await Future<void>.delayed(Duration.zero);
    expect(googleB.authorizeCalls, 1);
    expect(auth.credentialCalls, 2);
    pendingB.complete(TestCredential(TestUser('native-B')));
    expect((await retry)?.uid, 'native-B');
    expect(auth.currentUser?.uid, 'native-B');
    expect(auth.maxNativeInFlight, 1);
  });

  test('a failed native request releases the gate for a waiting new login', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    final pendingA = Completer<UserCredential>();
    final pendingB = Completer<UserCredential>();
    final auth = TestAuth()..pendingCredential = pendingA;
    final googleA = TestGoogle()..account = TestGoogleAccount(Future.value(TestTokens()));
    final first = AuthService(auth: auth, googleSignIn: googleA,
      restoreTimeout: const Duration(milliseconds: 30));
    expect(await first.restoreSession(), isNull);
    final googleB = TestGoogle()..account = TestGoogleAccount(Future.value(TestTokens()));
    final next = AuthService(auth: auth, googleSignIn: googleB,
      authenticationTimeout: const Duration(milliseconds: 300));
    final waiting = next.signInWithGoogle();
    auth.pendingCredential = pendingB;
    pendingA.completeError(FirebaseAuthException(code: 'network-request-failed'));
    await Future<void>.delayed(Duration.zero);
    expect(googleB.authorizeCalls, 1);
    expect(auth.credentialCalls, 2);
    pendingB.complete(TestCredential(TestUser('after-failed-native')));
    expect((await waiting)?.uid, 'after-failed-native');
    expect(auth.maxNativeInFlight, 1);
  });

  test('simultaneous restorations reserve the native mutation gate atomically',
      () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    final pendingA = Completer<UserCredential>();
    final pendingB = Completer<UserCredential>();
    final auth = TestAuth()..pendingCredential = pendingA;
    TestGoogle google() =>
        TestGoogle()..account = TestGoogleAccount(Future.value(TestTokens()));
    final first =
        AuthService(auth: auth, googleSignIn: google()).restoreSession();
    final second =
        AuthService(auth: auth, googleSignIn: google()).restoreSession();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(auth.credentialCalls, 1);
    auth.pendingCredential = pendingB;
    pendingA.complete(TestCredential(TestUser('same-owner')));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(auth.credentialCalls, 2);
    expect(auth.maxNativeInFlight, 1);
    pendingB.complete(TestCredential(TestUser('same-owner')));
    await Future.wait([first, second]);
    expect(auth.nativeInFlight, 0);
  });

  test('queued restoration cannot dispatch after its own deadline', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    final pending = Completer<UserCredential>();
    final auth = TestAuth()..pendingCredential = pending;
    TestGoogle google() =>
        TestGoogle()..account = TestGoogleAccount(Future.value(TestTokens()));
    final first = AuthService(
            auth: auth,
            googleSignIn: google(),
            restoreTimeout: const Duration(milliseconds: 30))
        .restoreSession();
    final second = AuthService(
            auth: auth,
            googleSignIn: google(),
            restoreTimeout: const Duration(milliseconds: 30))
        .restoreSession();
    expect(await Future.wait([first, second]), [null, null]);
    expect(auth.credentialCalls, 1);
    pending.complete(TestCredential(TestUser('only-request')));
    await Future<void>.delayed(Duration.zero);
    expect(auth.credentialCalls, 1);
    expect(auth.maxNativeInFlight, 1);
  });

  test(
      'logout stays bounded and hides identity while native A and cleanup remain pending',
      () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    final pending = Completer<UserCredential>();
    final cleanup = Completer<void>();
    final auth = TestAuth()..pendingCredential = pending;
    final googleA = TestGoogle()
      ..account = TestGoogleAccount(Future.value(TestTokens()));
    final service = AuthService(
        auth: auth,
        googleSignIn: googleA,
        restoreTimeout: const Duration(milliseconds: 30),
        authenticationTimeout: const Duration(milliseconds: 30));
    expect(await service.restoreSession(), isNull);
    auth.user = TestUser('visible-before-logout');
    final identities = <User?>[];
    final subscription = service.authStateChanges.listen(identities.add);
    await Future<void>.delayed(Duration.zero);
    expect(identities.last?.uid, 'visible-before-logout');
    auth.signOutWait = cleanup;
    await service.signOut().timeout(const Duration(milliseconds: 300));
    expect(identities.last, isNull);
    expect(service.currentUser, isNull);
    expect(service.cachedCurrentUser, isNull);
    expect(service.hasAuthenticatedSession, isFalse);
    expect(
        (await SharedPreferences.getInstance())
            .getBool(AuthService.explicitLogoutKey),
        isTrue);
    final googleB = TestGoogle()
      ..account = TestGoogleAccount(Future.value(TestTokens()));
    final newer = AuthService(
        auth: auth,
        googleSignIn: googleB,
        authenticationTimeout: const Duration(milliseconds: 30));
    pending.complete(TestCredential(TestUser('late-logout-A')));
    await Future<void>.delayed(Duration.zero);
    // A is native-authenticated, but the explicit logout hides it immediately.
    expect(auth.currentUser?.uid, 'late-logout-A');
    expect(service.currentUser, isNull);
    await expectLater(
        newer.signInWithGoogle(),
        throwsA(isA<FirebaseAuthException>()
            .having((e) => e.code, 'code', 'auth-operation-in-progress')));
    expect(googleB.authorizeCalls, 0);
    cleanup.complete();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(auth.currentUser, isNull);
    expect(auth.signOutCalls, 2);
    final next = Completer<UserCredential>();
    auth.pendingCredential = next;
    final retry = newer.signInWithGoogle();
    await Future<void>.delayed(Duration.zero);
    next.complete(TestCredential(TestUser('post-logout-B')));
    expect((await retry)?.uid, 'post-logout-B');
    expect(newer.currentUser?.uid, 'post-logout-B');
    expect(
        (await SharedPreferences.getInstance())
            .getBool(AuthService.explicitLogoutKey),
        isNull);
    await subscription.cancel();
  });

  test(
      'persisted explicit logout is honored after a process restart without Google cleanup',
      () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    SharedPreferences.setMockInitialValues({
      AuthService.explicitLogoutKey: true,
      'webview_session_owner': 'untouched@example.test',
      'webview_session_owner_verified_v1': 'untouched@example.test',
    });
    final auth = TestAuth()..user = TestUser('persisted-A');
    final google = TestGoogle();
    final service = AuthService(auth: auth, googleSignIn: google);
    expect(await service.restoreSession(), isNull);
    expect(auth.currentUser, isNull);
    expect(service.currentUser, isNull);
    expect(auth.signOutCalls, 1);
    expect(google.silentCalls, 0);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('webview_session_owner'), 'untouched@example.test');
    expect(prefs.getString('webview_session_owner_verified_v1'),
        'untouched@example.test');
  });

  test('keychain fallback never accepts old A after the user selected B',
      () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    final auth = TestAuth()
      ..user = TestUser('keychain-A')
      ..credentialFailure = FirebaseAuthException(code: 'keychain-error');
    final google = TestGoogle()
      ..account = TestGoogleAccount(Future.value(TestTokens()),
          email: 'keychain-B@example.test');
    final service = AuthService(auth: auth, googleSignIn: google);
    await expectLater(
        service.signInWithGoogle(),
        throwsA(isA<FirebaseAuthException>()
            .having((e) => e.code, 'code', 'keychain-error')));
    expect(
        (await SharedPreferences.getInstance()).getString('current_user_uid'),
        isNull);
  });

  test('keychain fallback accepts the same explicitly selected account',
      () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    final auth = TestAuth()
      ..user = TestUser('keychain-same')
      ..credentialFailure = FirebaseAuthException(code: 'keychain-error');
    final google = TestGoogle()
      ..account = TestGoogleAccount(Future.value(TestTokens()),
          email: ' KEYCHAIN-SAME@example.test ');
    final service = AuthService(auth: auth, googleSignIn: google);
    expect((await service.signInWithGoogle())?.uid, 'keychain-same');
  });

  testWidgets(
      'splash rejects a restored cached profile when auth remains absent',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'language_chosen_v1': true,
      'onboarding_seen_v1': true,
    });
    final auth = DashboardAuth()..cached = profile('stale');
    await tester.pumpWidget(MaterialApp(
      home: SplashScreen(authService: auth),
      routes: {AppRoutes.login: (_) => const Text('Login destination')},
    ));
    await tester.pumpAndSettle();
    expect(find.text('Login destination'), findsOneWidget);
  });

  testWidgets('dashboard hides cached identity after session disconnects',
      (tester) async {
    final auth = DashboardAuth()..cached = profile('stale');
    await tester
        .pumpWidget(MaterialApp(home: DashboardScreen(authService: auth)));
    await tester.pump();
    expect(find.text('Cached stale'), findsNothing);
    expect(find.text(Loc.tr('sessionReconnectTitle')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await auth.events.close();
    await tester.pump(const Duration(seconds: 16));
  });

  testWidgets(
      'initialization timeout releases retry and permits successful retry',
      (tester) async {
    var calls = 0;
    var ready = 0;
    await tester.pumpWidget(InitializationFailureApp(
      title: 'Connection failed',
      message: 'Please retry',
      retryTimeout: const Duration(seconds: 1),
      initialize: () {
        calls++;
        return calls == 1 ? Completer<void>().future : Future.value();
      },
      onInitialized: () => ready++,
    ));
    await tester.tap(find.text('Coba lagi'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(ready, 0);
    await tester.tap(find.text('Coba lagi'));
    await tester.pump();
    expect(calls, 2);
    expect(ready, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Hanafi stays unavailable before and after a stalled catalog times out',
      (tester) async {
    final auth = DashboardAuth()
      ..user = TestUser('launch-owner')
      ..cached = profile('launch-owner');
    await tester.pumpWidget(MaterialApp(
        home: DashboardScreen(
      authService: auth,
      agentService: PendingAgents(),
    )));
    await tester.enterText(find.byType(TextField), 'Hanafi');
    await tester.pump();
    SpecialistCard card() =>
        tester.widget<SpecialistCard>(find.byType(SpecialistCard).first);
    expect(card().isLocked, isTrue);
    expect(card().statusLabel, isNotNull);
    await tester.pump(const Duration(seconds: 5));
    expect(card().isLocked, isTrue);
    expect(card().statusLabel, isNotNull);
    await tester.pumpWidget(const SizedBox());
    await auth.events.close();
    await tester.pump(const Duration(seconds: 16));
    expect(tester.takeException(), isNull);
  });

  testWidgets('late initialization does not replace a disposed failure screen',
      (tester) async {
    final pending = Completer<void>();
    var ready = false;
    await tester.pumpWidget(InitializationFailureApp(
      title: 'Failed',
      message: 'Retry',
      initialize: () => pending.future,
      onInitialized: () => ready = true,
    ));
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpWidget(const SizedBox());
    pending.complete();
    await tester.pump();
    expect(ready, isFalse);
    expect(tester.takeException(), isNull);
  });
}
