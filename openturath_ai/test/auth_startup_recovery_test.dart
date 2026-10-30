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
  @override
  User? get currentUser => user;
  @override
  Stream<User?> authStateChanges() => Stream.value(user);
  @override
  Future<UserCredential> signInWithCredential(AuthCredential credential) {
    credentialCalls++;
    return pendingCredential!.future;
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
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
  TestGoogleAccount(this.tokens);
  final Future<GoogleSignInAuthentication> tokens;
  @override
  Future<GoogleSignInAuthentication> get authentication => tokens;
}

class TestGoogle extends Fake implements GoogleSignIn {
  GoogleSignInAccount? account;
  @override
  Future<GoogleSignInAccount?> signInSilently({
    bool suppressErrors = true,
    bool reAuthenticate = false,
  }) async =>
      account;
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
        restoreTimeout: const Duration(milliseconds: 40));
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
