import 'dart:async';
import '../core/login_error_message.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../core/constants.dart';
import 'agent_service.dart';
import 'agent_session_manager.dart';
import 'session_user_stream.dart';
import 'browser_companion_chat_service.dart';
import 'persistent_google_session.dart';
import 'auth_failure_reporter.dart';
import 'desktop_auth_gateway.dart';

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    Duration restoreTimeout = const Duration(seconds: 15),
    Duration authenticationTimeout = const Duration(seconds: 15),
  })  : _providedAuth = auth,
        _providedGoogleSignIn = googleSignIn,
        _restoreTimeout = restoreTimeout,
        _authenticationTimeout = authenticationTimeout;

  final FirebaseAuth? _providedAuth;
  final GoogleSignIn? _providedGoogleSignIn;
  final Duration _restoreTimeout;
  final Duration _authenticationTimeout;
  // Ditunda sampai dipakai, agar layar bisa dirender tanpa Firebase (pratinjau, tes).
  late final FirebaseAuth _auth = _providedAuth ?? FirebaseAuth.instance;
  late final GoogleSignIn _googleSignIn = _providedGoogleSignIn ??
      GoogleSignIn(
        clientId: (!kIsWeb &&
                (defaultTargetPlatform == TargetPlatform.iOS ||
                    defaultTargetPlatform == TargetPlatform.macOS))
            ? '255541559800-fen41rigfp5o3fsntiieaien3v915ptd.apps.googleusercontent.com'
            : null,
        serverClientId:
            '255541559800-jcip3mf8umtscgf5jm8khflm4u83rmcj.apps.googleusercontent.com',
      );

  // Cached persistent userStream to prevent memory leak and listener churn (F10)
  Stream<UserModel?>? _cachedUserStream;

  // In-memory cache to prevent entitlement loss on network hiccup (F41)
  static final Map<String, UserModel> _userCache = {};
  static final StreamController<UserModel> _webUserUpdates =
      StreamController<UserModel>.broadcast();
  static UserModel? _activeWebUser;
  static String? _activeWebUserEmail;
  static void setActiveWebEmail(String email) {
    final clean = email.trim().toLowerCase();
    if (clean.isEmpty) return;
    final prevUid = _activeWebUser?.uid;
    _activeWebUserEmail = clean;
    final uid = 'web_$clean';
    final isVip = UserModel.isVipEmail(clean);
    final user = _userCache[uid] ?? UserModel(
      uid: uid,
      name: clean.split('@').first,
      email: clean,
      photoUrl: '',
      plan: isVip ? 'vip' : AppConstants.planTrial,
      questionsUsed: 0,
      isVip: isVip,
    );
    _activeWebUser = user;
    _userCache[uid] = user;
    if (prevUid != uid) {
      _sessionUidController.add(uid);
    }
    _webUserUpdates.add(user);
  }

  static String? get activeWebUserEmail => _activeWebUserEmail;
  static bool? _lastVpsProvisioningReady;
  static bool? get lastVpsProvisioningReady => _lastVpsProvisioningReady;
  static void setLastVpsProvisioningReady(bool? ready) {
    _lastVpsProvisioningReady = ready;
  }

  static int _authActionGeneration = 0;
  static Future<void> _authMutationTail = Future<void>.value();
  static final _logoutIntent = Expando<bool>('explicit Firebase logout');
  static bool _webLogoutRequested = false;
  static final _authViewChanges = StreamController<FirebaseAuth>.broadcast();
  static const explicitLogoutKey = 'explicit_logout_v1';
  static final _interactiveDepth = Expando<int>('interactive sign-in depth');

  @visibleForTesting
  static void resetWebSessionForTest() {
    _activeWebUser = null;
    _activeWebUserEmail = null;
    _lastVpsProvisioningReady = null;
    _webLogoutRequested = false;
    _userCache.clear();
  }

  bool get _logoutRequested {
    if (_providedAuth != null) return _logoutIntent[_providedAuth!] == true;
    if (Firebase.apps.isEmpty) return _webLogoutRequested;
    return _webLogoutRequested || _logoutIntent[_auth] == true;
  }

  void _setLogoutRequested(bool requested) {
    if (_providedAuth == null) _webLogoutRequested = requested;
    try {
      if (_providedAuth != null || Firebase.apps.isNotEmpty) {
        _logoutIntent[_auth] = requested;
        _authViewChanges.add(_auth);
      }
    } catch (_) {}
  }

  Future<void> _waitForAuthMutationDrain() async {
    try {
      await _authMutationTail.timeout(_authenticationTimeout);
    } on TimeoutException {
      throw FirebaseAuthException(code: 'auth-operation-in-progress');
    }
  }

  /// Reserve the tail synchronously, before awaiting an earlier SDK request.
  /// UI deadlines never release an in-flight native mutation. Cancelled queued
  /// sign-ins are checked again immediately before native dispatch.
  static Future<T?> _queueAuthMutation<T>(
    Future<T> Function() operation, {
    required bool Function() isCurrent,
  }) {
    final previous = _authMutationTail;
    final released = Completer<void>();
    _authMutationTail = released.future;
    return (() async {
      try {
        await previous;
        if (!isCurrent()) return null;
        return await operation();
      } finally {
        released.complete();
      }
    })();
  }

  // ── Cache Helpers ──────────────────────────────────────────────
  static Future<void> cacheUserLocally(UserModel user) => _cacheUserLocally(user);

  static Future<void> _cacheUserLocally(UserModel user,
      {bool Function()? isCurrent}) async {
    if (isCurrent?.call() == false) return;
    _userCache[user.uid] = user;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (isCurrent?.call() == false) return;
      await prefs.setString('current_user_uid', user.uid);
      if (isCurrent?.call() == false) return;
      await prefs.setString(
        'openturath_cached_user_${user.uid}',
        jsonEncode(user.toJsonMap()),
      );
    } catch (_) {}
  }

  static Future<UserModel?> _getCachedUser(String uid) async {
    if (_userCache.containsKey(uid)) {
      return _userCache[uid];
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('openturath_cached_user_$uid');
      if (raw != null && raw.isNotEmpty) {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        final user = UserModel.fromMap(uid, map);
        _userCache[uid] = user;
        return user;
      }
    } catch (_) {}
    return null;
  }

  /// Pengguna contoh untuk pratinjau dan tes render; tidak dipakai di aplikasi.
  @visibleForTesting
  static UserModel? previewUser;

  // ── Current Firebase User ──────────────────────────────────────
  User? get currentUser {
    if (previewUser != null || _logoutRequested) return null;
    if (_providedAuth == null && Firebase.apps.isEmpty) return null;
    return _auth.currentUser;
  }

  Stream<User?> get authStateChanges => Stream<User?>.multi((listener) {
        if (_providedAuth == null && Firebase.apps.isEmpty) {
          listener.add(null);
          return;
        }
        final sdk = _auth.authStateChanges().listen(
              (user) => listener.add(_logoutRequested ? null : user),
              onError: listener.addError,
            );
        final view = _authViewChanges.stream
            .where((auth) => identical(auth, _auth))
            .listen((_) => listener.add(currentUser));
        listener.onCancel = () async {
          await Future.wait([sdk.cancel(), view.cancel()]);
        };
      }, isBroadcast: true);

  bool get hasAuthenticatedSession {
    if (previewUser != null) return true;
    final user = currentUser;
    if (user != null && !user.isAnonymous) return true;
    if (_providedAuth == null && _activeWebUser != null) {
      return !_logoutRequested;
    }
    return false;
  }

  UserModel? get cachedCurrentUser {
    if (previewUser != null) return previewUser;
    if (_logoutRequested) return null;
    if (_providedAuth == null && _activeWebUser != null) return _activeWebUser;
    if (_providedAuth == null && Firebase.apps.isEmpty) return null;
    final user = _auth.currentUser;
    if (user != null && !user.isAnonymous) {
      final email = (user.email ?? '').trim().toLowerCase();
      final cached = _userCache[user.uid] ??
          (email.isNotEmpty ? _userCache['web_$email'] : null);
      if (cached != null) {
        return cached.uid == user.uid
            ? cached
            : UserModel(
                uid: user.uid,
                name: cached.name.isNotEmpty
                    ? cached.name
                    : (user.displayName ?? 'Pengguna'),
                email: email.isNotEmpty ? email : cached.email,
                photoUrl: cached.photoUrl.isNotEmpty
                    ? cached.photoUrl
                    : (user.photoURL ?? ''),
                plan: cached.plan,
                questionsUsed: cached.questionsUsed,
                subscriptionExpiry: cached.subscriptionExpiry,
                entitlements: cached.entitlements,
                isVip: cached.isVip,
              );
      }
      final isVip = UserModel.isVipEmail(email);
      return UserModel(
        uid: user.uid,
        name: user.displayName ?? 'Pengguna',
        email: user.email ?? '',
        photoUrl: user.photoURL ?? '',
        plan: isVip ? 'vip' : AppConstants.planTrial,
        questionsUsed: 0,
        isVip: isVip,
      );
    }
    return null;
  }

  /// Cache hanya memulihkan profil UID yang masih diautentikasi Firebase.
  /// Sesi Firebase tersimpan tetap dapat dipakai offline; profil disk sendiri
  /// tidak membuktikan bahwa pengguna masih masuk.
  Future<UserModel?> restoreSession() async {
    if (previewUser != null) return previewUser;
    if (_providedAuth == null && _activeWebUser != null && !_logoutRequested) {
      _sessionUidController.add(_activeWebUser!.uid);
      return _activeWebUser;
    }
    var active = true;
    final generation = _authActionGeneration;
    try {
      return await _restoreAuthenticatedSession(
        () => active && generation == _authActionGeneration,
      ).timeout(
        _restoreTimeout,
        onTimeout: () {
          active = false;
          return generation == _authActionGeneration ? cachedCurrentUser : null;
        },
      );
    } finally {
      active = false;
    }
  }

  Future<UserModel?> _restoreAuthenticatedSession(
    bool Function() active,
  ) async {
    final hasFirebase = _providedAuth != null || Firebase.apps.isNotEmpty;
    if (hasFirebase && (_interactiveDepth[_auth] ?? 0) > 0) return null;
    final prefs = await SharedPreferences.getInstance()
        .timeout(const Duration(seconds: 2));
    if (!active() || (hasFirebase && (_interactiveDepth[_auth] ?? 0) > 0)) {
      return null;
    }
    if (_logoutRequested || prefs.getBool(explicitLogoutKey) == true) {
      _setLogoutRequested(true);
      // Complete the user's persisted Log Out intent after a process restart.
      // This does not touch Google cookies or perform a silent sign-in.
      if (hasFirebase) {
        await _queueAuthMutation<void>(() => _auth.signOut(),
            isCurrent: () => true).timeout(_authenticationTimeout);
      }
      return null;
    }
    User? firebaseUser = hasFirebase ? _auth.currentUser : null;
    if (firebaseUser == null && hasFirebase) {
      try {
        firebaseUser = await _auth
            .authStateChanges()
            .firstWhere((u) => u != null && !u.isAnonymous)
            .timeout(const Duration(milliseconds: 1200));
      } catch (_) {}
    }
    if (!active()) return null;

    // Prioritaskan pemulihan sesi Google WebKit (1-login) HANYA jika sesi web
    // tercatat aktif DAN pemiliknya sudah terverifikasi oleh alur koneksi Google.
    final webSessionActive = prefs.getBool('web_session_active') == true;
    final verifiedOwner =
        (prefs.getString(PersistentGoogleSession.verifiedOwnerKey) ?? '')
            .trim()
            .toLowerCase();
    if (_providedAuth == null && webSessionActive && verifiedOwner.isNotEmpty) {
      final uid = 'web_$verifiedOwner';
      final cached = await _getCachedUser(uid);
      final isVip = UserModel.isVipEmail(verifiedOwner);
      final user = cached ?? UserModel(
        uid: uid,
        name: verifiedOwner.split('@').first,
        email: verifiedOwner,
        photoUrl: '',
        plan: isVip ? 'vip' : AppConstants.planTrial,
        questionsUsed: 0,
        isVip: isVip,
      );
      _activeWebUser = user;
      _activeWebUserEmail = verifiedOwner;
      _userCache[user.uid] = user;
      _sessionUidController.add(user.uid);
      unawaited(syncUserStatusWithVps(verifiedOwner));
      return user;
    }

    if (firebaseUser == null &&
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      try {
        await _authMutationTail.timeout(_authenticationTimeout);
        if (!active()) return null;
        final googleUser = await _googleSignIn
            .signInSilently()
            .timeout(const Duration(seconds: 4));
        if (!active()) return null;
        if (googleUser != null) {
          final googleAuth = await googleUser.authentication
              .timeout(const Duration(seconds: 4));
          if (!active()) return null;
          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          final result = await _queueAuthMutation<UserCredential>(
            () => _auth.signInWithCredential(credential),
            isCurrent: active,
          ).timeout(const Duration(seconds: 5));
          firebaseUser = result?.user;
        }
      } catch (_) {}
    }
    if (!active()) return null;
    firebaseUser ??= _auth.currentUser;
    if (firebaseUser == null || firebaseUser.isAnonymous) {
      return null;
    }

    final uid = firebaseUser.uid;
    final cached = await _getCachedUser(uid)
        .timeout(const Duration(seconds: 2), onTimeout: () => null);
    if (!active() || _auth.currentUser?.uid != uid) return null;
    if (cached != null) return cached;
    return cachedCurrentUser;
  }

  // ── Google Sign In ─────────────────────────────────────────────
  Future<UserModel?> signInWithGoogle() async {
    final generation = ++_authActionGeneration;
    var active = true;
    _interactiveDepth[_auth] = (_interactiveDepth[_auth] ?? 0) + 1;
    bool current() => active && generation == _authActionGeneration;
    var stage = 'google-authorize';
    try {
      // An older native request must settle before a new account picker opens.
      await _waitForAuthMutationDrain();
      if (!current()) return null;
      User? firebaseUser;

      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS)) {
        // Native GoogleSignIn SDK on Android, iOS, & macOS (Darwin)
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null || !current()) {
          return null; // Pengguna membatalkan login
        }

        stage = 'google-token';
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication.timeout(_authenticationTimeout);
        if (!current()) return null;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        try {
          stage = 'firebase-credential';
          final userCredential = await _queueAuthMutation<UserCredential>(
            () => _auth.signInWithCredential(credential),
            isCurrent: current,
          ).timeout(_authenticationTimeout);
          firebaseUser = userCredential?.user;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'keychain-error' &&
              _auth.currentUser != null &&
              googleUser.email.trim().isNotEmpty &&
              (_auth.currentUser!.email ?? '').trim().toLowerCase() ==
                  googleUser.email.trim().toLowerCase()) {
            firebaseUser = _auth.currentUser;
          } else {
            rethrow;
          }
        }
      } else if (kIsWeb) {
        final result = await _queueAuthMutation<UserCredential>(
          () => _auth.signInWithPopup(GoogleAuthProvider()),
          isCurrent: current,
        ).timeout(const Duration(minutes: 5));
        firebaseUser = result?.user;
      } else if (defaultTargetPlatform == TargetPlatform.windows) {
        // Platform desktop Windows: gunakan DesktopAuthGateway (Loopback + Firebase Web Auth)
        stage = 'desktop-gateway';
        final desktopAuth = await DesktopAuthGateway.signIn();
        if (desktopAuth == null || !current()) {
          return null; // Pengguna membatalkan login
        }

        stage = 'firebase-credential';
        final credential = GoogleAuthProvider.credential(
          accessToken: desktopAuth.accessToken,
          idToken: desktopAuth.idToken,
        );

        final userCredential = await _queueAuthMutation<UserCredential>(
          () => _auth.signInWithCredential(credential),
          isCurrent: current,
        ).timeout(_authenticationTimeout);
        firebaseUser = userCredential?.user;
      } else {
        // Platform desktop lain (Linux) langsung via Firebase OAuth Provider
        final provider = GoogleAuthProvider();
        final userCredential = await _queueAuthMutation<UserCredential>(
          () => _auth.signInWithProvider(provider),
          isCurrent: current,
        ).timeout(const Duration(minutes: 5));
        firebaseUser = userCredential?.user;
      }

      if (firebaseUser == null ||
          !current() ||
          _auth.currentUser?.uid != firebaseUser.uid) {
        return null;
      }
      bool ownsUser() =>
          current() && _auth.currentUser?.uid == firebaseUser!.uid;
      stage = 'profile-resolve';
      final userModel = await _resolveOrCreateFirebaseUser(
        firebaseUser,
        isCurrent: ownsUser,
      ).timeout(const Duration(seconds: 10));
      if (!ownsUser() || userModel == null) return null;
      final effectiveEmail = firebaseUser.email?.trim().toLowerCase();
      if (effectiveEmail != null && effectiveEmail.isNotEmpty) {
        try {
          final prefs = await SharedPreferences.getInstance();
          if (!ownsUser()) return null;
          await prefs.setString('current_user_uid', firebaseUser.uid);
          if (!ownsUser()) return null;
          await prefs.setString('google_session_email', effectiveEmail);
          if (!ownsUser()) return null;
          await prefs.setString('notebook_google_email', effectiveEmail);
        } catch (_) {}
        if (!ownsUser()) return null;
        // Verifikasi kecocokan pemilik sesi WebView secara jujur tanpa memalsukan
        // verifiedOwnerKey (mencegah akun B memakai cookie milik akun A).
        await reconcileWebSession(effectiveEmail);
      }
      if (!ownsUser()) return null;
      final prefs = await SharedPreferences.getInstance();
      if (!ownsUser()) return null;
      await prefs.remove(explicitLogoutKey);
      if (!ownsUser()) return null;
      _setLogoutRequested(false);
      return userModel;
    } catch (e) {
      // Only fixed diagnostic categories: never log OAuth tokens or account data.
      final code = e is PlatformException
          ? e.code
          : e is FirebaseAuthException
              ? e.code
              : e.runtimeType.toString();
      final detail = e is PlatformException ? '${e.details}'.toLowerCase() : '';
      final configurationError = googleSignInNativeCode(e) == 10;
      final category = configurationError
          ? 'configuration'
          : detail.contains('keychain')
              ? 'keychain'
              : detail.contains('cancel')
                  ? 'cancelled'
                  : detail.contains('network')
                      ? 'network'
                      : detail.contains('configuration')
                          ? 'configuration'
                          : 'unspecified';
      final safeCode = configurationError
          ? 'google_oauth_configuration'
          : RegExp(r'^[a-zA-Z0-9_-]{1,80}$').hasMatch(code)
              ? code
              : 'unknown';
      // ignore: avoid_print
      print('OpenTurathAuth stage=$stage code=$safeCode category=$category');
      if (category != 'cancelled' && safeCode != 'sign_in_canceled') {
        AuthFailureReporter.report(
            stage: stage, code: safeCode, category: category);
      }
      rethrow;
    } finally {
      active = false;
      _interactiveDepth[_auth] = (_interactiveDepth[_auth] ?? 1) - 1;
    }
  }

  // ── Helper Resolusi Profil User (100% Mandiri VPS + Cache Lokal) ──
  Future<UserModel?> _resolveOrCreateFirebaseUser(
    User firebaseUser, {
    String? fallbackName,
    String? fallbackEmail,
    required bool Function() isCurrent,
  }) async {
    final rawName = firebaseUser.displayName ?? fallbackName ?? 'Pengguna';
    final effectiveName =
        rawName.length > 120 ? rawName.substring(0, 120) : rawName;
    final effectiveEmail =
        (firebaseUser.email ?? fallbackEmail ?? '').trim().toLowerCase();
    final photoUrl = firebaseUser.photoURL ?? '';

    try {
      final webCached = effectiveEmail.isNotEmpty
          ? (_userCache['web_$effectiveEmail'] ??
              await _getCachedUser('web_$effectiveEmail')
                  .timeout(const Duration(seconds: 2), onTimeout: () => null))
          : null;
      final cached = await _getCachedUser(firebaseUser.uid)
              .timeout(const Duration(seconds: 2), onTimeout: () => null) ??
          webCached;
      if (!isCurrent()) return null;
      final isVip = UserModel.isVipEmail(effectiveEmail);
      final resolved = UserModel(
        uid: firebaseUser.uid,
        name: cached != null && cached.name.isNotEmpty
            ? cached.name
            : effectiveName,
        email: effectiveEmail,
        photoUrl: cached != null && cached.photoUrl.isNotEmpty
            ? cached.photoUrl
            : photoUrl,
        plan: isVip ? 'vip' : (cached?.plan ?? AppConstants.planTrial),
        questionsUsed: cached?.questionsUsed ?? 0,
        subscriptionExpiry: cached?.subscriptionExpiry,
        entitlements: cached?.entitlements ?? const {},
        isVip: isVip || (cached?.isVip ?? false),
      );
      await _cacheUserLocally(resolved, isCurrent: isCurrent);
      if (effectiveEmail.isNotEmpty) {
        unawaited(syncUserStatusWithVps(effectiveEmail));
      }
      return isCurrent() ? resolved : null;
    } catch (_) {
      if (!isCurrent()) return null;
      final cached = await _getCachedUser(firebaseUser.uid)
          .timeout(const Duration(seconds: 2), onTimeout: () => null);
      if (!isCurrent()) return null;
      if (cached != null) return cached;

      final isVip = UserModel.isVipEmail(effectiveEmail);
      return UserModel(
        uid: firebaseUser.uid,
        name: effectiveName,
        email: effectiveEmail,
        photoUrl: photoUrl,
        plan: isVip ? 'vip' : AppConstants.planTrial,
        questionsUsed: 0,
        isVip: isVip,
      );
    }
  }

  // ── Get Current UserModel (100% Otoritas VPS + Cache Lokal) ───
  Future<UserModel?> getCurrentUserModel() async {
    final user = currentUser;
    if (previewUser != null) return previewUser;
    if (user == null || user.isAnonymous) return null;
    final email = (user.email ?? '').trim().toLowerCase();
    try {
      if (email.isNotEmpty) {
        await syncUserStatusWithVps(email)
            .timeout(const Duration(seconds: 4), onTimeout: () {});
      }
      final webMatch = email.isNotEmpty
          ? (_userCache['web_$email'] ?? await _getCachedUser('web_$email'))
          : null;
      final cached = await _getCachedUser(user.uid) ?? webMatch;
      if (currentUser?.uid != user.uid) return null;
      if (cached != null) {
        if (cached.uid == user.uid) return cached;
        return UserModel(
          uid: user.uid,
          name: user.displayName ?? cached.name,
          email: email.isNotEmpty ? email : cached.email,
          photoUrl: user.photoURL ?? cached.photoUrl,
          plan: cached.plan,
          questionsUsed: cached.questionsUsed,
          subscriptionExpiry: cached.subscriptionExpiry,
          entitlements: cached.entitlements,
          isVip: cached.isVip,
        );
      }
      return UserModel(
        uid: user.uid,
        name: user.displayName ?? 'Pengguna',
        email: user.email ?? '',
        photoUrl: user.photoURL ?? '',
        plan: UserModel.isVipEmail(email) ? 'vip' : AppConstants.planTrial,
        questionsUsed: 0,
        isVip: UserModel.isVipEmail(email),
      );
    } catch (_) {
      final cached = await _getCachedUser(user.uid);
      if (currentUser?.uid != user.uid) return null;
      if (cached != null) return cached;

      return UserModel(
        uid: user.uid,
        name: user.displayName ?? 'Pengguna',
        email: user.email ?? '',
        photoUrl: user.photoURL ?? '',
        plan: UserModel.isVipEmail(email) ? 'vip' : AppConstants.planTrial,
        questionsUsed: 0,
        isVip: UserModel.isVipEmail(email),
      );
    }
  }

  static final StreamController<String?> _sessionUidController =
      StreamController<String?>.broadcast();

  Stream<String?> get _sessionUidStream => Stream<String?>.multi((listener) {
        final sdk = authStateChanges.map((u) => u?.uid).listen((uid) {
          if (uid != null) {
            listener.add(uid);
          } else {
            final webUser = _activeWebUser ?? cachedCurrentUser;
            if (webUser != null && webUser.uid.startsWith('web_')) {
              listener.add(webUser.uid);
            } else {
              listener.add(null);
            }
          }
        }, onError: listener.addError);

        final webSub = _sessionUidController.stream.listen((uid) {
          listener.add(uid);
        });

        final initialWeb = _activeWebUser ?? cachedCurrentUser;
        if (initialWeb != null && initialWeb.uid.startsWith('web_')) {
          listener.add(initialWeb.uid);
        }

        listener.onCancel = () async {
          await Future.wait([sdk.cancel(), webSub.cancel()]);
        };
      });

  // ── Stream user changes (real-time with single persistent cached stream, F10 & F41) ──
  Stream<UserModel?> get userStream => previewUser != null
      ? Stream<UserModel?>.value(previewUser)
      : _cachedUserStream ??= _buildUserStream();

  Stream<UserModel?> _buildUserStream() => sessionUserStream<UserModel>(
        auth: _sessionUidStream,
        cached: _getCachedUser,
        watch: (uid) {
          final fbUser = (_providedAuth != null || Firebase.apps.isNotEmpty)
              ? _auth.currentUser
              : null;
          final cleanEmail = uid.startsWith('web_')
              ? uid.substring(4).trim().toLowerCase()
              : (fbUser?.uid == uid
                      ? fbUser?.email
                      : (_userCache[uid]?.email ?? _activeWebUserEmail))
                  ?.trim()
                  .toLowerCase() ??
                  '';
          if (cleanEmail.isNotEmpty && !uid.startsWith('web_')) {
            unawaited(syncUserStatusWithVps(cleanEmail));
          }
          return _webUserUpdates.stream
              .where((u) =>
                  u.uid == uid ||
                  (cleanEmail.isNotEmpty &&
                      u.email.trim().toLowerCase() == cleanEmail))
              .map((u) => u.uid == uid
                  ? u
                  : UserModel(
                      uid: uid,
                      name: u.name,
                      email: u.email,
                      photoUrl: u.photoUrl,
                      plan: u.plan,
                      questionsUsed: u.questionsUsed,
                      subscriptionExpiry: u.subscriptionExpiry,
                      entitlements: u.entitlements,
                      isVip: u.isVip,
                    ));
        },
      );

  static const webSessionOwnerKey = 'webview_session_owner';

  /// Menetapkan pengguna sesi web Google yang terverifikasi ke dalam sesi aplikasi.
  /// Memuat profil cache terlebih dahulu agar status langganan/VIP lokal tidak
  /// pernah diturunkan ke trial saat offline atau sebelum respons VPS tiba.
  static Future<void> establishVerifiedWebUser(String email,
      {String? displayName}) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty) return;
    final uid = 'web_$cleanEmail';
    final prevUid = _activeWebUser?.uid;
    final isVip = UserModel.isVipEmail(cleanEmail);

    final cached = await _getCachedUser(uid);
    final UserModel resolvedUser;
    if (cached != null) {
      resolvedUser = UserModel(
        uid: uid,
        name: cached.name.isNotEmpty
            ? cached.name
            : (displayName ?? cleanEmail.split('@').first),
        email: cleanEmail,
        photoUrl: cached.photoUrl,
        plan: isVip ? 'vip' : cached.plan,
        questionsUsed: cached.questionsUsed,
        subscriptionExpiry: cached.subscriptionExpiry,
        entitlements: cached.entitlements,
        isVip: cached.isVip || isVip,
      );
    } else {
      resolvedUser = UserModel(
        uid: uid,
        name: displayName ?? cleanEmail.split('@').first,
        email: cleanEmail,
        photoUrl: '',
        plan: isVip ? 'vip' : AppConstants.planTrial,
        questionsUsed: 0,
        isVip: isVip,
      );
    }

    if (_activeWebUserEmail != cleanEmail) {
      _lastVpsProvisioningReady = null;
    }
    _activeWebUser = resolvedUser;
    _activeWebUserEmail = cleanEmail;
    _userCache[uid] = resolvedUser;
    AuthService()._setLogoutRequested(false);
    if (prevUid != uid) {
      _sessionUidController.add(uid);
    }
    _webUserUpdates.add(resolvedUser);
    unawaited(syncUserStatusWithVps(cleanEmail));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(explicitLogoutKey, false);
      await prefs.setBool('web_session_active', true);
      await prefs.setString('current_user_uid', uid);
      await prefs.setString(
          PersistentGoogleSession.verifiedOwnerKey, cleanEmail);
      await prefs.setString(webSessionOwnerKey, cleanEmail);
      await prefs.setString('google_session_email', cleanEmail);
      await prefs.setString('notebook_google_email', cleanEmail);
      await prefs.setString(
          'openturath_cached_user_$uid', jsonEncode(resolvedUser.toJsonMap()));
    } catch (_) {}
  }

  /// Menetapkan hak akses aktif (misal dari penukaran voucher atau verifikasi langganan VPS)
  static Future<void> applyActiveGrant(
    String email, {
    DateTime? expiry,
    String? planTitle,
    String? agentId,
    int? durationDays,
    Map<String, ModuleEntitlement>? customEntitlements,
    bool isPaidSubscription = false,
    bool replaceEntitlements = false,
    bool isVipOverride = false,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty) return;
    final isVip = isVipOverride || UserModel.isVipEmail(cleanEmail);
    final cleanAgentId = (agentId ?? '').trim().toLowerCase();
    final isAllSpecialists = cleanAgentId == 'all_specialists' ||
        cleanAgentId == 'all_disciplines';
    final isAll = !isAllSpecialists &&
        (cleanAgentId.isEmpty ||
            cleanAgentId == 'all_access' ||
            cleanAgentId == 'all_ai');

    // Pertahankan hak akses modul lain yang masih aktif, kecuali saat sinkronisasi
    // penuh dari VPS yang membawa daftar entitlement otoritatif terbaru.
    final existingEntitlements = replaceEntitlements
        ? const <String, ModuleEntitlement>{}
        : Map<String, ModuleEntitlement>.from(_activeWebUser?.entitlements ??
            _userCache['web_$cleanEmail']?.entitlements ??
            {});

    final entMap = <String, ModuleEntitlement>{
      ...existingEntitlements,
      if (customEntitlements != null && customEntitlements.isNotEmpty)
        ...customEntitlements
      else if (isAllSpecialists && expiry != null) ...{
        'all_specialists': ModuleEntitlement(
          plan: isPaidSubscription ? 'all_specialists' : 'trial',
          status: 'active',
          expiry: expiry,
          startedAt: DateTime.now(),
          trialDurationDays: durationDays,
          paymentStatus: isPaidSubscription ? 'paid' : 'none',
        ),
      } else if (isAll && expiry != null) ...{
        'all_access': ModuleEntitlement(
          plan: isPaidSubscription ? 'all_access' : 'trial',
          status: 'active',
          expiry: expiry,
          startedAt: DateTime.now(),
          trialDurationDays: durationDays,
          paymentStatus: isPaidSubscription ? 'paid' : 'none',
        ),
        'all_ai': ModuleEntitlement(
          plan: isPaidSubscription ? 'all_ai' : 'trial',
          status: 'active',
          expiry: expiry,
          startedAt: DateTime.now(),
          trialDurationDays: durationDays,
          paymentStatus: isPaidSubscription ? 'paid' : 'none',
        ),
      } else if (cleanAgentId.isNotEmpty && expiry != null) ...{
        cleanAgentId: ModuleEntitlement(
          plan: isPaidSubscription ? 'tholib_1m' : 'trial',
          status: 'active',
          expiry: expiry,
          startedAt: DateTime.now(),
          trialDurationDays: durationDays,
          paymentStatus: isPaidSubscription ? 'paid' : 'none',
        ),
      }
    };

    final effectivePlan = isVip
        ? 'vip'
        : isAllSpecialists
            ? 'all_specialists'
            : (isPaidSubscription
                ? (cleanAgentId.isNotEmpty ? cleanAgentId : 'tholib_1m')
                : (isAll ? 'all_ai' : 'trial'));

    User? fbUser;
    try {
      if (Firebase.apps.isNotEmpty) {
        fbUser = FirebaseAuth.instance.currentUser;
      }
    } catch (_) {}
    final fbMatchesEmail = fbUser != null &&
        !fbUser.isAnonymous &&
        (fbUser.email ?? '').trim().toLowerCase() == cleanEmail;

    final prevUid = _activeWebUser?.uid;
    final existingUid = fbMatchesEmail
        ? fbUser.uid
        : (_activeWebUser != null &&
                _activeWebUser!.email.trim().toLowerCase() == cleanEmail)
            ? _activeWebUser!.uid
            : 'web_$cleanEmail';
    final existingName = (_activeWebUser != null &&
            _activeWebUser!.email.trim().toLowerCase() == cleanEmail &&
            _activeWebUser!.name.isNotEmpty)
        ? _activeWebUser!.name
        : (fbMatchesEmail && (fbUser.displayName ?? '').isNotEmpty
            ? fbUser.displayName!
            : cleanEmail.split('@').first);
    DateTime? maxActiveExpiry = expiry;
    for (final ent in entMap.values) {
      if (ent.isActive &&
          ent.isPremium &&
          ent.expiry != null &&
          (maxActiveExpiry == null || ent.expiry!.isAfter(maxActiveExpiry))) {
        maxActiveExpiry = ent.expiry;
      }
    }

    final user = UserModel(
      uid: existingUid,
      name: existingName,
      email: cleanEmail,
      photoUrl: _activeWebUser?.photoUrl.isNotEmpty == true
          ? _activeWebUser!.photoUrl
          : (fbMatchesEmail ? (fbUser.photoURL ?? '') : ''),
      plan: effectivePlan,
      questionsUsed: _activeWebUser?.questionsUsed ?? 0,
      subscriptionExpiry: maxActiveExpiry,
      entitlements: entMap,
      isVip: isVip,
    );

    _activeWebUser = user;
    _activeWebUserEmail = cleanEmail;
    _userCache[user.uid] = user;
    _userCache['web_$cleanEmail'] = user;
    if (fbMatchesEmail && fbUser.uid != user.uid) {
      _userCache[fbUser.uid] = user;
    }
    await _cacheUserLocally(user, isCurrent: () => true);
    if (prevUid != user.uid) {
      _sessionUidController.add(user.uid);
    }
    _webUserUpdates.add(user);

    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(user.toJsonMap());
      await prefs.setString('openturath_cached_user_web_$cleanEmail', encoded);
      if (fbMatchesEmail && fbUser.uid != 'web_$cleanEmail') {
        await prefs.setString('openturath_cached_user_${fbUser.uid}', encoded);
      }
    } catch (_) {}
  }

  /// Mencabut hak akses aktif ketika masa langganan/voucher telah berakhir
  static Future<void> revokeActiveGrant(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty) return;
    final isVip = UserModel.isVipEmail(cleanEmail) ||
        (_activeWebUser?.email.trim().toLowerCase() == cleanEmail &&
            _activeWebUser?.isVip == true) ||
        _userCache.values.any(
            (u) => u.email.trim().toLowerCase() == cleanEmail && u.isVip);
    if (isVip) return; // Sakral Rule 5: Hak prerogatif VIP tidak pernah dicabut

    User? fbUser;
    try {
      if (Firebase.apps.isNotEmpty) {
        fbUser = FirebaseAuth.instance.currentUser;
      }
    } catch (_) {}
    final fbMatchesEmail = fbUser != null &&
        !fbUser.isAnonymous &&
        (fbUser.email ?? '').trim().toLowerCase() == cleanEmail;

    final prevUid = _activeWebUser?.uid;
    final existingUid = fbMatchesEmail
        ? fbUser.uid
        : (_activeWebUser != null &&
                _activeWebUser!.email.trim().toLowerCase() == cleanEmail)
            ? _activeWebUser!.uid
            : 'web_$cleanEmail';
    final existingName = (_activeWebUser != null &&
            _activeWebUser!.email.trim().toLowerCase() == cleanEmail &&
            _activeWebUser!.name.isNotEmpty)
        ? _activeWebUser!.name
        : (fbMatchesEmail && (fbUser.displayName ?? '').isNotEmpty
            ? fbUser.displayName!
            : cleanEmail.split('@').first);

    final user = UserModel(
      uid: existingUid,
      name: existingName,
      email: cleanEmail,
      photoUrl: _activeWebUser?.photoUrl.isNotEmpty == true
          ? _activeWebUser!.photoUrl
          : (fbMatchesEmail ? (fbUser.photoURL ?? '') : ''),
      plan: AppConstants.planTrial,
      questionsUsed: _activeWebUser?.questionsUsed ?? 0,
      subscriptionExpiry: null,
      entitlements: const {},
      isVip: false,
    );

    _activeWebUser = user;
    _activeWebUserEmail = cleanEmail;
    _userCache[user.uid] = user;
    _userCache['web_$cleanEmail'] = user;
    if (fbMatchesEmail && fbUser.uid != user.uid) {
      _userCache[fbUser.uid] = user;
    }
    await AgentService.clearAssignedUrlCache(cleanEmail);
    await _cacheUserLocally(user, isCurrent: () => true);
    if (prevUid != user.uid) {
      _sessionUidController.add(user.uid);
    }
    _webUserUpdates.add(user);

    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(user.toJsonMap());
      await prefs.setString('openturath_cached_user_web_$cleanEmail', encoded);
      if (user.uid != 'web_$cleanEmail') {
        await prefs.setString('openturath_cached_user_${user.uid}', encoded);
      }
    } catch (_) {}
  }

  /// Sinkronisasi hak akses pengguna secara realtime dengan backend VPS
  static Future<void> syncUserStatusWithVps(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty) return;
    final generation = _authActionGeneration;
    try {
      String? idToken;
      try {
        if (Firebase.apps.isNotEmpty) {
          idToken = await FirebaseAuth.instance.currentUser
              ?.getIdToken()
              .timeout(const Duration(seconds: 3), onTimeout: () => null);
        }
      } catch (_) {}
      final headers = <String, String>{
        'Accept': 'application/json',
        'User-Agent': 'OpenTurathApp/1.0',
        if (idToken != null && idToken.isNotEmpty)
          'Authorization': 'Bearer $idToken',
      };
      final res = await http
          .get(
            Uri.parse(
                'https://maktabah.openturath.id/api/user-status?email=${Uri.encodeQueryComponent(cleanEmail)}'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));
      // Abaikan hasil sinkronisasi basi bila pengguna sudah logout atau ganti akun.
      if (generation != _authActionGeneration) return;
      if (_activeWebUserEmail != null && _activeWebUserEmail != cleanEmail) {
        return;
      }
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map && data['success'] == true) {
          await applyVpsUserStatusPayload(
            cleanEmail,
            Map<String, dynamic>.from(data),
          );
        }
      }
    } catch (_) {}
  }

  /// Menerapkan respons otoritatif `/api/user-status` dari VPS ke state & cache lokal.
  @visibleForTesting
  static Future<void> applyVpsUserStatusPayload(
    String email,
    Map<String, dynamic> data, {
    DateTime? now,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty) return;

    final rawProvReady = data['provisioningReady'];
    final rawPendingShares = data['pendingShareCount'];
    if (rawProvReady is bool) {
      _lastVpsProvisioningReady = rawProvReady;
    } else if (rawPendingShares is num) {
      _lastVpsProvisioningReady = rawPendingShares.toInt() <= 0;
    } else {
      _lastVpsProvisioningReady = null;
    }

    final hasActive = data['hasActiveAccess'] == true;
    final isVip = data['isVip'] == true || UserModel.isVipEmail(cleanEmail);
    final expiryStr = data['expiryIso']?.toString();
    final expiry = expiryStr != null ? DateTime.tryParse(expiryStr) : null;
    final planTitle = data['serviceTitle']?.toString();
    final rawPlan = (data['plan']?.toString() ?? '').trim().toLowerCase();
    final forceReplace = data['replaceEntitlements'] == true;

    final rawEnt = data['entitlements'];
    Map<String, ModuleEntitlement>? granularEntitlements;
    if (rawEnt is Map) {
      granularEntitlements = <String, ModuleEntitlement>{};
      rawEnt.forEach((key, val) {
        if (val is Map) {
          final p = val['plan']?.toString() ?? 'tholib_1m';
          final st = val['status']?.toString() ?? 'active';
          final expStr = val['expiry']?.toString();
          final exp = expStr != null ? DateTime.tryParse(expStr) : null;
          final startStr = val['startsAt']?.toString();
          final startedAt =
              startStr != null ? DateTime.tryParse(startStr) : null;
          final kind = val['kind']?.toString() ?? 'payment';
          final src = val['source']?.toString();

          granularEntitlements![key.toString()] = ModuleEntitlement(
            plan: p,
            status: st,
            expiry: exp,
            startedAt: startedAt,
            sourceTransactionId: src,
            paymentStatus: kind == 'payment' ? 'paid' : 'none',
          );
        }
      });
    }

    final hasPaid =
        granularEntitlements?.values.any((e) => e.paymentStatus == 'paid') ??
            false;

    String resolvedPlan = rawPlan;
    if (resolvedPlan.isEmpty &&
        granularEntitlements != null &&
        granularEntitlements.isNotEmpty) {
      final activeEnts = Map<String, ModuleEntitlement>.fromEntries(
        granularEntitlements.entries
            .where((e) => e.value.isActive && e.value.isPremium),
      );
      if (activeEnts.containsKey('all_access') ||
          activeEnts.containsKey('all_ai')) {
        resolvedPlan = 'all_ai';
      } else if (activeEnts.containsKey('all_specialists') ||
          activeEnts.containsKey('all_disciplines')) {
        resolvedPlan = 'all_specialists';
      } else if (activeEnts.isNotEmpty) {
        resolvedPlan = activeEnts.keys.first;
      }
    }

    final shouldReplace = forceReplace || granularEntitlements != null;
    final refNow = now ?? DateTime.now();

    if (isVip) {
      await applyActiveGrant(
        cleanEmail,
        expiry: expiry,
        planTitle: planTitle,
        agentId: resolvedPlan.isNotEmpty ? resolvedPlan : null,
        customEntitlements: granularEntitlements,
        isPaidSubscription: hasPaid,
        replaceEntitlements: shouldReplace,
        isVipOverride: true,
      );
    } else if (hasActive) {
      final hasValidGranular = granularEntitlements != null &&
          granularEntitlements.values.any((e) => e.isActive && e.isPremium);
      if ((expiry != null && expiry.isAfter(refNow)) || hasValidGranular) {
        await applyActiveGrant(
          cleanEmail,
          expiry: expiry,
          planTitle: planTitle,
          agentId: (resolvedPlan == 'all_ai' || resolvedPlan == 'all_access')
              ? 'all_ai'
              : (resolvedPlan == 'all_specialists' ||
                      resolvedPlan == 'all_disciplines')
                  ? 'all_specialists'
                  : (resolvedPlan.isNotEmpty ? resolvedPlan : null),
          customEntitlements: granularEntitlements,
          isPaidSubscription: hasPaid,
          replaceEntitlements: shouldReplace,
        );
      } else if (forceReplace) {
        await revokeActiveGrant(cleanEmail);
      }
    } else {
      await revokeActiveGrant(cleanEmail);
    }
  }

  /// Mempertahankan owner yang sudah diverifikasi oleh alur koneksi Google.
  /// Callback ruang AI membawa email aplikasi, bukan bukti identitas WebView,
  /// sehingga tidak boleh menetapkan atau mengganti owner sesi.
  static Future<void> rememberWebSessionOwner(String email) async {
    final owner = email.trim().toLowerCase();
    if (owner.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final verifiedOwner =
          (prefs.getString(webSessionOwnerKey) ?? '').trim().toLowerCase();
      final verification =
          (prefs.getString(PersistentGoogleSession.verifiedOwnerKey) ?? '')
              .trim()
              .toLowerCase();
      if (verifiedOwner != owner || verification != owner) return;
      await prefs.setString(webSessionOwnerKey, owner);
    } catch (_) {}
  }

  /// Melepas klaim sesi Google di WebView bila bukan milik [email], agar akun
  /// sebelumnya tidak diakui sebagai ke pengguna berikutnya di perangkat yang sama.
  static Future<void> reconcileWebSession(String email) async {
    final current = email.trim().toLowerCase();
    if (current.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final owner =
          (prefs.getString(webSessionOwnerKey) ?? '').trim().toLowerCase();
      final verifiedOwner =
          (prefs.getString(PersistentGoogleSession.verifiedOwnerKey) ?? '')
              .trim()
              .toLowerCase();
      if (owner.isNotEmpty && owner != current) {
        // Akun aplikasi berganti: lepas klaim kepemilikan saja. Cookie Google
        // tidak dihapus di luar Log Out (Aturan Sakral #8).
        await PersistentGoogleSession.instance.releaseOwnership();
        return;
      }
      if (owner == current && verifiedOwner == current) {
        await PersistentGoogleSession.instance.restoreSessionIfAvailable(current);
      } else {
        PersistentGoogleSession.instance.invalidateLiveSessionCache();
        await prefs.setBool('google_session_ready', false);
      }
    } catch (_) {}
  }

  // ── Sign Out ───────────────────────────────────────────────────
  Future<void> signOut() async {
    _authActionGeneration++;
    _setLogoutRequested(true);
    final hasFirebase = _providedAuth != null || Firebase.apps.isNotEmpty;
    final currentUid = hasFirebase ? _auth.currentUser?.uid : null;
    final localCleanup = Completer<void>();
    unawaited(localCleanup.future
        .then((_) {}, onError: (Object _, StackTrace __) {}));
    // Reserve this mandatory cleanup before any asynchronous work. A later
    // login cannot dispatch until both the earlier request and this Log Out end.
    final drained = _queueAuthMutation<void>(() async {
      try {
        await localCleanup.future;
      } finally {
        if (hasFirebase) {
          await _auth.signOut();
        }
      }
    }, isCurrent: () => true);
    // End the SDK session immediately as well: the mandatory queued sign-out
    // handles an older credential that completes after this immediate one.
    final immediate = hasFirebase
        ? Future<void>.sync(() => _auth.signOut()).catchError((Object _) {})
        : Future<void>.value();
    localCleanup.complete(() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final stored = await prefs.setBool(explicitLogoutKey, true);
        if (!stored) throw StateError('explicit-logout-not-persisted');
      } finally {
        await Future.wait([_prepareLocalSignOut(currentUid), immediate]);
      }
    }());
    try {
      await drained.timeout(_authenticationTimeout);
    } on TimeoutException {
      // The local identity is already signed out and the durable intent remains.
      // Keep the native drain locked; the login screen can report a bounded retry.
    }
  }

  Future<void> _prepareLocalSignOut(String? currentUid) async {
    // Revoke native capabilities before asynchronous SDK/storage cleanup.
    await BrowserCompanionChatService.stop();

    try {
      AgentSessionManager.instance.closeAll();
    } catch (_) {}

    try {
      await PersistentGoogleSession.instance.clearOnSignOut();
    } catch (_) {}

    try {
      await AgentService.clearAssignedUrlCache();
    } catch (_) {}

    try {
      if (kIsWeb || defaultTargetPlatform != TargetPlatform.windows) {
        await _googleSignIn.signOut();
      }
    } catch (_) {}

    try {
      final prevWebEmail = _activeWebUserEmail;
      final prevWebUid = _activeWebUser?.uid;
      _activeWebUser = null;
      _activeWebUserEmail = null;
      _lastVpsProvisioningReady = null;
      _sessionUidController.add(null);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user_uid');
      await prefs.remove('web_session_active');
      await prefs.remove('google_session_ready');
      await prefs.remove('google_session_email');
      await prefs.remove('notebook_google_email');
      await prefs.remove('last_opened_notebook_id');
      for (final key in prefs.getKeys().toList()) {
        if (key.startsWith('ot_assigned_notebook_v1_')) {
          await prefs.remove(key);
        }
      }
      if (prevWebEmail != null && prevWebEmail.isNotEmpty) {
        _userCache.remove('web_$prevWebEmail');
        await prefs.remove('openturath_cached_user_web_$prevWebEmail');
      }
      if (prevWebUid != null && prevWebUid.isNotEmpty) {
        _userCache.remove(prevWebUid);
        await prefs.remove('openturath_cached_user_$prevWebUid');
      }
      if (currentUid != null) {
        _userCache.remove(currentUid);
        await prefs.remove('openturath_cached_user_$currentUid');
      } else {
        _userCache.clear();
      }
    } catch (_) {}
  }

  // ── Delete Account & User Data (Google Play Compliance & Orphan Cleanup, P0) ──
  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user == null || user.isAnonymous) {
      // Pada arsitektur 1-login WebView, pengguna mungkin terautentikasi melalui
      // sesi web Google tanpa akun Firebase Auth aktif. Bersihkan seluruh data
      // lokal dan sesi WebView secara tuntas.
      if (_providedAuth == null &&
          _activeWebUser != null &&
          !_logoutRequested) {
        final webUid = _activeWebUser!.uid;
        _authActionGeneration++;
        _setLogoutRequested(true);
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(explicitLogoutKey, true);
          for (final key in prefs.getKeys().toList()) {
            if (key.startsWith('openturath_${webUid}_') ||
                key == 'openturath_cached_user_$webUid') {
              await prefs.remove(key);
            }
          }
        } catch (_) {}
        await _prepareLocalSignOut(webUid);
        return;
      }
      throw FirebaseAuthException(code: 'requires-recent-login');
    }
    final generation = ++_authActionGeneration;
    var active = true;
    bool current() =>
        active &&
        generation == _authActionGeneration &&
        _auth.currentUser?.uid == user.uid;
    try {
      final deleted = await _queueAuthMutation<bool>(() async {
        await _deleteAccountData(user, current);
        return true;
      }, isCurrent: current)
          .timeout(const Duration(minutes: 5));
      if (deleted != true) {
        throw FirebaseAuthException(code: 'requires-recent-login');
      }
    } finally {
      active = false;
    }
  }

  Future<void> _deleteAccountData(User user, bool Function() current) async {
    final uid = user.uid;
    await BrowserCompanionChatService.stop();

    // Auth deletion enforces recent login. The server trigger owns revocation and recursive cleanup.
    try {
      if (!current()) {
        throw FirebaseAuthException(code: 'requires-recent-login');
      }
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        if (kIsWeb || defaultTargetPlatform != TargetPlatform.windows) {
          final googleUser = await _googleSignIn.signIn();
          if (googleUser != null && current()) {
            final googleAuth = await googleUser.authentication;
            if (!current()) {
              throw FirebaseAuthException(code: 'requires-recent-login');
            }
            final credential = GoogleAuthProvider.credential(
              accessToken: googleAuth.accessToken,
              idToken: googleAuth.idToken,
            );
            await user.reauthenticateWithCredential(credential);
            if (!current()) {
              throw FirebaseAuthException(code: 'requires-recent-login');
            }
            await user.delete();
          } else {
            rethrow;
          }
        } else {
          // Windows: login ulang lewat peramban (OAuth loopback) lalu hapus akun.
          final desktopAuth = await DesktopAuthGateway.signIn();
          if (desktopAuth == null || !current()) rethrow;
          final credential = GoogleAuthProvider.credential(
            accessToken: desktopAuth.accessToken,
            idToken: desktopAuth.idToken,
          );
          await user.reauthenticateWithCredential(credential);
          if (!current()) {
            throw FirebaseAuthException(code: 'requires-recent-login');
          }
          await user.delete();
        }
      } else {
        rethrow;
      }
    }
    AgentSessionManager.instance.closeAll();
    try {
      await PersistentGoogleSession.instance.clearOnSignOut();
    } catch (_) {}

    try {
      await AgentService.clearAssignedUrlCache();
    } catch (_) {}

    // 4. Bersihkan ONLY preferensi spesifik user UID ini (F08 & F41: dilarang prefs.clear())
    try {
      _userCache.remove(uid);
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith('openturath_${uid}_') ||
            key == 'openturath_cached_user_$uid' ||
            key == 'google_session_ready' ||
            key == webSessionOwnerKey ||
            key == 'google_session_email' ||
            key == 'notebook_google_email' ||
            key == 'last_opened_notebook_id') {
          await prefs.remove(key);
        }
      }
    } catch (_) {}

    // 5. Putuskan hubungan Google Sign In
    try {
      if (kIsWeb || defaultTargetPlatform != TargetPlatform.windows) {
        await _googleSignIn.disconnect();
      }
    } catch (_) {
      try {
        if (kIsWeb || defaultTargetPlatform != TargetPlatform.windows) {
          await _googleSignIn.signOut();
        }
      } catch (_) {}
    }

    // 6. Pastikan sign-out bersih
    try {
      await _auth.signOut();
    } catch (_) {}
  }
}
