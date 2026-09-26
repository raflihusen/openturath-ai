import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../core/constants.dart';
import 'agent_session_manager.dart';
import 'session_user_stream.dart';
import 'desktop_google_sign_in.dart';
import 'desktop_webview_runtime.dart';
import '../core/app_platform.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: (!kIsWeb &&
            (defaultTargetPlatform == TargetPlatform.iOS ||
                defaultTargetPlatform == TargetPlatform.macOS))
        ? '255541559800-fen41rigfp5o3fsntiieaien3v915ptd.apps.googleusercontent.com'
        : null,
    serverClientId:
        '255541559800-jcip3mf8umtscgf5jm8khflm4u83rmcj.apps.googleusercontent.com',
  );
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Cached persistent userStream to prevent memory leak and listener churn (F10)
  Stream<UserModel?>? _cachedUserStream;

  // In-memory cache to prevent entitlement loss on network hiccup (F41)
  static final Map<String, UserModel> _userCache = {};

  // ── Cache Helpers ──────────────────────────────────────────────
  static Future<void> _cacheUserLocally(UserModel user) async {
    _userCache[user.uid] = user;
    try {
      final prefs = await SharedPreferences.getInstance();
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

  // ── Current Firebase User ──────────────────────────────────────
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  UserModel? get cachedCurrentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
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

  // ── Google Sign In ─────────────────────────────────────────────
  Future<UserModel?> signInWithGoogle() async {
    try {
      User? firebaseUser;

      if (!kIsWeb && AppPlatform.isDesktop) {
        final credential = await DesktopGoogleSignIn.signIn();
        if (credential == null) return null;
        final userCredential = await _auth.signInWithCredential(credential);
        firebaseUser = userCredential.user;
      } else {
        // Android, iOS, macOS, and web use the GoogleSignIn SDK flow.
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null; // User membatalkan login

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await _auth.signInWithCredential(credential);
        firebaseUser = userCredential.user;
      }

      if (firebaseUser == null) return null;
      return await _resolveOrCreateFirebaseUser(firebaseUser);
    } catch (e) {
      rethrow;
    }
  }

  // ── In-App Desktop Google Sign In ──────────────────────────────
  /// Menerima idToken dari InAppWebView (WKWebView), mengautentikasi Firebase Auth,
  /// sekaligus mencatat kuki sesi Google aktif untuk NotebookLM (1x login).
  Future<UserModel?> signInWithDesktopGoogleToken({
    required String idToken,
    String? email,
    String? displayName,
  }) async {
    try {
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) return null;

      final userModel = await _resolveOrCreateFirebaseUser(
        firebaseUser,
        fallbackName: displayName,
        fallbackEmail: email,
      );

      // Simpan penanda bahwa sesi kuki Google di WKWebView sudah siap
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('google_session_ready', true);
        final effectiveEmail = firebaseUser.email ?? email ?? '';
        if (effectiveEmail.isNotEmpty) {
          await prefs.setString(
              'google_session_email', effectiveEmail.trim().toLowerCase());
        }
      } catch (_) {}

      return userModel;
    } catch (e) {
      rethrow;
    }
  }

  // ── Helper Resolusi Profil User Firestore ──────────────────────
  Future<UserModel> _resolveOrCreateFirebaseUser(
    User firebaseUser, {
    String? fallbackName,
    String? fallbackEmail,
  }) async {
    final effectiveName =
        firebaseUser.displayName ?? fallbackName ?? 'Pengguna';
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

  // ── Anonymous / Guest Sign-In ──────────────────────────────────
  Future<UserModel?> signInAnonymously() async {
    try {
      final cred = await _auth.signInAnonymously();
      final firebaseUser = cred.user;
      if (firebaseUser == null) return _localGuestUser();

      try {
        final docRef =
            _db.collection(AppConstants.colUsers).doc(firebaseUser.uid);
        final doc = await docRef.get().timeout(const Duration(seconds: 4));

        if (!doc.exists) {
          final newUser = UserModel(
            uid: firebaseUser.uid,
            name: 'Peneliti Tamu',
            email: '',
            photoUrl: '',
            plan: AppConstants.planTrial,
            questionsUsed: 0,
          );
          await docRef.set({
            'name': newUser.name,
            'email': '',
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
        return _localGuestUser();
      }
    } catch (_) {
      return _localGuestUser();
    }
  }

  static String? _cachedGuestUid;

  UserModel _localGuestUser() {
    _cachedGuestUid ??=
        'guest_${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}';
    return UserModel(
      uid: _cachedGuestUid!,
      name: 'Peneliti Tamu',
      email: 'tamu@openturath.ai',
      photoUrl: '',
      plan: AppConstants.planTrial,
      questionsUsed: 0,
    );
  }

  // ── Get Current UserModel from Firestore ───────────────────────
  Future<UserModel?> getCurrentUserModel() async {
    final user = currentUser;
    if (user == null) return null;
    try {
      final doc = await _db
          .collection(AppConstants.colUsers)
          .doc(user.uid)
          .get()
          .timeout(const Duration(seconds: 4));
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
  Stream<UserModel?> get userStream => _cachedUserStream ??= _buildUserStream();

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

  // ── Sign Out ───────────────────────────────────────────────────
  Future<void> signOut() async {
    final currentUid = _auth.currentUser?.uid;

    try {
      AgentSessionManager.instance.closeAll();
    } catch (_) {}

    try {
      await DesktopWebViewRuntime.clearSession();
    } catch (_) {}

    try {
      if (kIsWeb || defaultTargetPlatform != TargetPlatform.windows) {
        await _googleSignIn.signOut();
      }
    } catch (_) {}

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('google_session_ready');
      await prefs.remove('google_session_email');
      await prefs.remove('last_opened_notebook_id');
      if (currentUid != null) {
        _userCache.remove(currentUid);
        await prefs.remove('openturath_cached_user_$currentUid');
      }
    } catch (_) {}

    // Propagate Auth signOut to avoid half-signed-out UI state (F41)
    await _auth.signOut();
  }

  // ── Increment Question Count ───────────────────────────────────
  Future<void> incrementQuestionCount() async {
    final user = currentUser;
    if (user == null) return;
    try {
      await _db.collection(AppConstants.colUsers).doc(user.uid).update({
        'questions_used': FieldValue.increment(1),
      });
    } catch (_) {}
  }

  // ── Delete Account & User Data (Google Play Compliance & Orphan Cleanup, P0) ──
  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user == null) return;
    final uid = user.uid;

    // Auth deletion enforces recent login. The server trigger owns revocation and recursive cleanup.
    await user.delete();
    AgentSessionManager.instance.closeAll();
    try {
      await DesktopWebViewRuntime.clearSession();
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
            key == 'google_session_email' ||
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
