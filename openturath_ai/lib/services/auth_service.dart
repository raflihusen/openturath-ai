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
  })  : _providedAuth = auth,
        _providedGoogleSignIn = googleSignIn,
        _restoreTimeout = restoreTimeout;

  final FirebaseAuth? _providedAuth;
  final GoogleSignIn? _providedGoogleSignIn;
  final Duration _restoreTimeout;
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
  static bool _lastAuthActionWasSignOut = false;

  // ── Cache Helpers ──────────────────────────────────────────────
  static Future<void> _cacheUserLocally(UserModel user) async {
    _userCache[user.uid] = user;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user_uid', user.uid);
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
  User? get currentUser => previewUser != null ? null : _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  UserModel? get cachedCurrentUser {
    if (previewUser != null) return previewUser;
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
        generation,
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
    int generation,
  ) async {
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
          final pending = _auth.signInWithCredential(credential);
          unawaited(_discardRestoreAfterSignOut(pending, generation));
          final result = await pending.timeout(const Duration(seconds: 5));
          firebaseUser = result.user;
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

  Future<void> _discardRestoreAfterSignOut(
    Future<UserCredential> pending,
    int generation,
  ) async {
    try {
      final result = await pending;
      // An SDK credential request cannot be cancelled. Honor an explicit Log Out
      // even if its earlier credential request finishes afterwards.
      if (generation != _authActionGeneration &&
          _lastAuthActionWasSignOut &&
          result.user != null &&
          _auth.currentUser?.uid == result.user!.uid) {
        await _auth.signOut();
      }
    } catch (_) {}
  }

  // ── Google Sign In ─────────────────────────────────────────────
  Future<UserModel?> signInWithGoogle() async {
    _authActionGeneration++;
    _lastAuthActionWasSignOut = false;
    var stage = 'google-authorize';
    try {
      User? firebaseUser;

      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS)) {
        // Native GoogleSignIn SDK on Android, iOS, & macOS (Darwin)
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null; // Pengguna membatalkan login

        stage = 'google-token';
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        try {
          stage = 'firebase-credential';
          final userCredential = await _auth.signInWithCredential(credential);
          firebaseUser = userCredential.user;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'keychain-error' && _auth.currentUser != null) {
            firebaseUser = _auth.currentUser;
          } else {
            rethrow;
          }
        }
      } else if (kIsWeb) {
        final result = await _auth.signInWithPopup(GoogleAuthProvider());
        firebaseUser = result.user;
      } else if (defaultTargetPlatform == TargetPlatform.windows) {
        // Platform desktop Windows: gunakan DesktopAuthGateway (Loopback + Firebase Web Auth)
        stage = 'desktop-gateway';
        final desktopAuth = await DesktopAuthGateway.signIn();
        if (desktopAuth == null) return null; // Pengguna membatalkan login

        stage = 'firebase-credential';
        final credential = GoogleAuthProvider.credential(
          accessToken: desktopAuth.accessToken,
          idToken: desktopAuth.idToken,
        );

        final userCredential = await _auth.signInWithCredential(credential);
        firebaseUser = userCredential.user;
      } else {
        // Platform desktop lain (Linux) langsung via Firebase OAuth Provider
        final provider = GoogleAuthProvider();
        final userCredential = await _auth.signInWithProvider(provider);
        firebaseUser = userCredential.user;
      }

      if (firebaseUser == null) return null;
      stage = 'profile-resolve';
      final userModel = await _resolveOrCreateFirebaseUser(firebaseUser);
      final effectiveEmail = firebaseUser.email?.trim().toLowerCase();
      if (effectiveEmail != null && effectiveEmail.isNotEmpty) {
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('current_user_uid', firebaseUser.uid);
          await prefs.setString('google_session_email', effectiveEmail);
          await prefs.setString('notebook_google_email', effectiveEmail);
        } catch (_) {}
      }
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
    }
  }

  // ── Helper Resolusi Profil User Firestore ──────────────────────
  Future<UserModel> _resolveOrCreateFirebaseUser(
    User firebaseUser, {
    String? fallbackName,
    String? fallbackEmail,
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
        await _cacheUserLocally(newUser);
        return newUser;
      } else {
        final userModel = UserModel.fromFirestore(doc);
        await _cacheUserLocally(userModel);
        return userModel;
      }
    } catch (_) {
      final cached = await _getCachedUser(firebaseUser.uid);
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
      await _cacheUserLocally(userModel);
      return userModel;
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
        auth: _auth.authStateChanges().map((user) => user?.uid),
        cached: _getCachedUser,
        watch: (uid) => _db
            .collection(AppConstants.colUsers)
            .doc(uid)
            .snapshots()
            .map((doc) {
          if (!doc.exists) return null;
          final user = UserModel.fromFirestore(doc);
          if (_auth.currentUser?.uid == uid) {
            unawaited(_cacheUserLocally(user));
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
    _lastAuthActionWasSignOut = true;
    final currentUid = _auth.currentUser?.uid;
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

    // Propagate Auth signOut to avoid half-signed-out UI state (F41)
    await _auth.signOut();
  }

  // ── Delete Account & User Data (Google Play Compliance & Orphan Cleanup, P0) ──
  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user == null || user.isAnonymous) {
      throw FirebaseAuthException(code: 'requires-recent-login');
    }
    _authActionGeneration++;
    _lastAuthActionWasSignOut = true;
    final uid = user.uid;
    await BrowserCompanionChatService.stop();

    // Auth deletion enforces recent login. The server trigger owns revocation and recursive cleanup.
    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        if (kIsWeb || defaultTargetPlatform != TargetPlatform.windows) {
          final googleUser = await _googleSignIn.signIn();
          if (googleUser != null) {
            final googleAuth = await googleUser.authentication;
            final credential = GoogleAuthProvider.credential(
              accessToken: googleAuth.accessToken,
              idToken: googleAuth.idToken,
            );
            await user.reauthenticateWithCredential(credential);
            await user.delete();
          } else {
            rethrow;
          }
        } else {
          // Windows: login ulang lewat peramban (OAuth loopback) lalu hapus akun.
          final desktopAuth = await DesktopAuthGateway.signIn();
          if (desktopAuth == null) rethrow;
          final credential = GoogleAuthProvider.credential(
            accessToken: desktopAuth.accessToken,
            idToken: desktopAuth.idToken,
          );
          await user.reauthenticateWithCredential(credential);
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
