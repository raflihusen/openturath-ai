import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../core/constants.dart';
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
  late final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Cached persistent userStream to prevent memory leak and listener churn (F10)
  Stream<UserModel?>? _cachedUserStream;

  // In-memory cache to prevent entitlement loss on network hiccup (F41)
  static final Map<String, UserModel> _userCache = {};
  static int _authActionGeneration = 0;
  static Future<void> _authMutationTail = Future<void>.value();
  static final _logoutIntent = Expando<bool>('explicit Firebase logout');
  static final _authViewChanges = StreamController<FirebaseAuth>.broadcast();
  static const explicitLogoutKey = 'explicit_logout_v1';
  static final _interactiveDepth = Expando<int>('interactive sign-in depth');

  bool get _logoutRequested => _logoutIntent[_auth] == true;

  void _setLogoutRequested(bool requested) {
    _logoutIntent[_auth] = requested;
    _authViewChanges.add(_auth);
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
  User? get currentUser =>
      previewUser != null || _logoutRequested ? null : _auth.currentUser;

  Stream<User?> get authStateChanges => Stream<User?>.multi((listener) {
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
    return user != null && !user.isAnonymous;
  }

  UserModel? get cachedCurrentUser {
    if (previewUser != null) return previewUser;
    if (_logoutRequested) return null;
    final user = _auth.currentUser;
    if (user != null && !user.isAnonymous) {
      return _userCache[user.uid] ??
          UserModel(
            uid: user.uid,
            name: user.displayName ?? 'Pengguna',
            email: user.email ?? '',
            photoUrl: user.photoURL ?? '',
            plan: AppConstants.planTrial,
            questionsUsed: 0,
          );
    }
    return null;
  }

  /// Cache hanya memulihkan profil UID yang masih diautentikasi Firebase.
  /// Sesi Firebase tersimpan tetap dapat dipakai offline; profil disk sendiri
  /// tidak membuktikan bahwa pengguna masih masuk.
  Future<UserModel?> restoreSession() async {
    if (previewUser != null) return previewUser;
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
    if ((_interactiveDepth[_auth] ?? 0) > 0) return null;
    final prefs = await SharedPreferences.getInstance()
        .timeout(const Duration(seconds: 2));
    if (!active() || (_interactiveDepth[_auth] ?? 0) > 0) return null;
    if (_logoutRequested || prefs.getBool(explicitLogoutKey) == true) {
      _setLogoutRequested(true);
      // Complete the user's persisted Log Out intent after a process restart.
      // This does not touch Google cookies or perform a silent sign-in.
      await _queueAuthMutation<void>(() => _auth.signOut(),
          isCurrent: () => true).timeout(_authenticationTimeout);
      return null;
    }
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      try {
        firebaseUser = await _auth
            .authStateChanges()
            .firstWhere((u) => u != null && !u.isAnonymous)
            .timeout(const Duration(milliseconds: 1200));
      } catch (_) {}
    }
    if (!active()) return null;

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
            .timeout(const Duration(seconds: 10));
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
    if (firebaseUser == null || firebaseUser.isAnonymous) return null;

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
      final category = detail.contains('keychain')
          ? 'keychain'
          : detail.contains('cancel')
              ? 'cancelled'
              : detail.contains('network')
                  ? 'network'
                  : detail.contains('configuration')
                      ? 'configuration'
                      : 'unspecified';
      final safeCode =
          RegExp(r'^[a-zA-Z0-9_-]{1,80}$').hasMatch(code) ? code : 'unknown';
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

  // ── Helper Resolusi Profil User Firestore ──────────────────────
  Future<UserModel?> _resolveOrCreateFirebaseUser(
    User firebaseUser, {
    String? fallbackName,
    String? fallbackEmail,
    required bool Function() isCurrent,
  }) async {
    // Firestore rules cap the stored name at 120 characters.
    final rawName = firebaseUser.displayName ?? fallbackName ?? 'Pengguna';
    final effectiveName =
        rawName.length > 120 ? rawName.substring(0, 120) : rawName;
    final effectiveEmail = firebaseUser.email ?? fallbackEmail ?? '';
    final photoUrl = firebaseUser.photoURL ?? '';

    try {
      final docRef =
          _db.collection(AppConstants.colUsers).doc(firebaseUser.uid);
      final doc = await docRef.get().timeout(const Duration(seconds: 4));
      if (!isCurrent()) return null;
      if (!doc.exists) {
        final newUser = UserModel(
          uid: firebaseUser.uid,
          name: effectiveName,
          email: effectiveEmail,
          photoUrl: photoUrl,
          plan: AppConstants.planTrial,
          questionsUsed: 0,
        );
        await docRef.set({
          'name': newUser.name,
          'email': newUser.email,
          'photo_url': newUser.photoUrl,
          'plan': newUser.plan,
          'questions_used': newUser.questionsUsed,
          'subscription_expiry': null,
        }).timeout(const Duration(seconds: 4));
        if (!isCurrent()) return null;
        await _cacheUserLocally(newUser, isCurrent: isCurrent);
        return isCurrent() ? newUser : null;
      } else {
        final userModel = UserModel.fromFirestore(doc);
        await _cacheUserLocally(userModel, isCurrent: isCurrent);
        return isCurrent() ? userModel : null;
      }
    } catch (_) {
      if (!isCurrent()) return null;
      final cached = await _getCachedUser(firebaseUser.uid)
          .timeout(const Duration(seconds: 2), onTimeout: () => null);
      if (!isCurrent()) return null;
      if (cached != null) return cached;

      final fallback = UserModel(
        uid: firebaseUser.uid,
        name: effectiveName,
        email: effectiveEmail,
        photoUrl: photoUrl,
        plan: AppConstants.planTrial,
        questionsUsed: 0,
      );
      return fallback;
    }
  }

  // ── Get Current UserModel from Firestore ───────────────────────
  Future<UserModel?> getCurrentUserModel() async {
    final user = currentUser;
    if (previewUser != null) return previewUser;
    if (user == null || user.isAnonymous) return null;
    try {
      final doc = await _db
          .collection(AppConstants.colUsers)
          .doc(user.uid)
          .get()
          .timeout(const Duration(seconds: 4));
      if (currentUser?.uid != user.uid) return null;
      if (!doc.exists) {
        final fallback = UserModel(
          uid: user.uid,
          name: user.displayName ?? 'Pengguna',
          email: user.email ?? '',
          photoUrl: user.photoURL ?? '',
          plan: AppConstants.planTrial,
          questionsUsed: 0,
        );
        return fallback;
      }
      final userModel = UserModel.fromFirestore(doc);
      await _cacheUserLocally(userModel,
          isCurrent: () => currentUser?.uid == user.uid);
      return currentUser?.uid == user.uid ? userModel : null;
    } catch (_) {
      // Pertahankan snapshot terakhir jika ada (F41)
      final cached = await _getCachedUser(user.uid);
      if (currentUser?.uid != user.uid) return null;
      if (cached != null) return cached;

      return UserModel(
        uid: user.uid,
        name: user.displayName ?? 'Pengguna',
        email: user.email ?? '',
        photoUrl: user.photoURL ?? '',
        plan: AppConstants.planTrial,
        questionsUsed: 0,
      );
    }
  }

  // ── Stream user changes (real-time with single persistent cached stream, F10 & F41) ──
  Stream<UserModel?> get userStream => previewUser != null
      ? Stream<UserModel?>.value(previewUser)
      : _cachedUserStream ??= _buildUserStream();

  Stream<UserModel?> _buildUserStream() => sessionUserStream<UserModel>(
        auth: authStateChanges.map((user) => user?.uid),
        cached: _getCachedUser,
        watch: (uid) => _db
            .collection(AppConstants.colUsers)
            .doc(uid)
            .snapshots()
            .map((doc) {
          if (!doc.exists) return null;
          final user = UserModel.fromFirestore(doc);
          if (_auth.currentUser?.uid == uid) {
            unawaited(_cacheUserLocally(user,
                isCurrent: () => _auth.currentUser?.uid == uid));
          }
          return user;
        }),
      );

  static const webSessionOwnerKey = 'webview_session_owner';

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
      if (owner != current) {
        // Akun aplikasi berganti: lepas klaim kepemilikan saja. Cookie Google
        // tidak dihapus di luar Log Out (Aturan Sakral #8); layar sesi akan
        // meminta pemilihan akun yang sesuai.
        await PersistentGoogleSession.instance.releaseOwnership();
        return;
      }
      await PersistentGoogleSession.instance.restoreSessionIfAvailable(current);
    } catch (_) {}
  }

  // ── Sign Out ───────────────────────────────────────────────────
  Future<void> signOut() async {
    _authActionGeneration++;
    _setLogoutRequested(true);
    final currentUid = _auth.currentUser?.uid;
    final localCleanup = Completer<void>();
    unawaited(localCleanup.future.then((_) {}, onError: (Object _, StackTrace __) {}));
    // Reserve this mandatory cleanup before any asynchronous work. A later
    // login cannot dispatch until both the earlier request and this Log Out end.
    final drained = _queueAuthMutation<void>(() async {
      try {
        await localCleanup.future;
      } finally {
        await _auth.signOut();
      }
    }, isCurrent: () => true);
    // End the SDK session immediately as well: the mandatory queued sign-out
    // handles an older credential that completes after this immediate one.
    final immediate = Future<void>.sync(() => _auth.signOut())
        .catchError((Object _) {});
    localCleanup.complete(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(explicitLogoutKey, true);
      await Future.wait([_prepareLocalSignOut(currentUid), immediate]);
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
      if (kIsWeb || defaultTargetPlatform != TargetPlatform.windows) {
        await _googleSignIn.signOut();
      }
    } catch (_) {}

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user_uid');
      await prefs.remove('google_session_ready');
      await prefs.remove('google_session_email');
      await prefs.remove('notebook_google_email');
      await prefs.remove('last_opened_notebook_id');
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
      if (!current())
        throw FirebaseAuthException(code: 'requires-recent-login');
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        if (kIsWeb || defaultTargetPlatform != TargetPlatform.windows) {
          final googleUser = await _googleSignIn.signIn();
          if (googleUser != null && current()) {
            final googleAuth = await googleUser.authentication;
            if (!current())
              throw FirebaseAuthException(code: 'requires-recent-login');
            final credential = GoogleAuthProvider.credential(
              accessToken: googleAuth.accessToken,
              idToken: googleAuth.idToken,
            );
            await user.reauthenticateWithCredential(credential);
            if (!current())
              throw FirebaseAuthException(code: 'requires-recent-login');
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
          if (!current())
            throw FirebaseAuthException(code: 'requires-recent-login');
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
