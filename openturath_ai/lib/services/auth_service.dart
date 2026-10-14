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

class AuthService {
  // Ditunda sampai dipakai, agar layar bisa dirender tanpa Firebase (pratinjau, tes).
  late final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
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
    if (user != null) {
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
    // Only an unambiguous cached profile may stand in; with several accounts
    // in memory there is no way to know which one this session belongs to.
    if (_userCache.length == 1) {
      return _userCache.values.single;
    }
    return null;
  }

  /// Memulihkan sesi pengguna secara aman dari Firebase Auth atau cache disk lokal
  Future<UserModel?> restoreSession() async {
    if (previewUser != null) return previewUser;
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      try {
        firebaseUser = await _auth
            .authStateChanges()
            .firstWhere((u) => u != null)
            .timeout(const Duration(milliseconds: 1200));
      } catch (_) {}
    }

    // Silent Sign-in Fallback: Pulihkan kredensial Google OAuth tanpa prompt jika sesi Firebase belum siap
    if (firebaseUser == null &&
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      try {
        final googleUser = await _googleSignIn.signInSilently();
        if (googleUser != null) {
          final googleAuth = await googleUser.authentication;
          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          final userCredential = await _auth.signInWithCredential(credential);
          firebaseUser = userCredential.user;
        }
      } catch (_) {}
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      // The cached profile is keyed by the UID of the last verified sign-in.
      // Never guess from other cached profiles: that could surface another
      // account's name and entitlements on a shared device.
      final uid = firebaseUser?.uid ?? prefs.getString('current_user_uid');

      if (uid != null && uid.isNotEmpty) {
        final cached = await _getCachedUser(uid);
        if (cached != null) {
          _userCache[cached.uid] = cached;
          return cached;
        }
      }
    } catch (_) {}

    if (firebaseUser != null) {
      final fallback = UserModel(
        uid: firebaseUser.uid,
        name: firebaseUser.displayName ?? 'Pengguna',
        email: firebaseUser.email ?? '',
        photoUrl: firebaseUser.photoURL ?? '',
        plan: AppConstants.planTrial,
        questionsUsed: 0,
      );
      _userCache[fallback.uid] = fallback;
      return fallback;
    }

    return null;
  }

  // ── Google Sign In ─────────────────────────────────────────────
  Future<UserModel?> signInWithGoogle() async {
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
      } else {
        // Platform desktop lain (Windows/Linux) langsung via Firebase OAuth Provider
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
          final previousOwner =
              (prefs.getString(webSessionOwnerKey) ?? '').trim().toLowerCase();
          await prefs.setString('current_user_uid', firebaseUser.uid);
          await prefs.setString('google_session_email', effectiveEmail);
          await prefs.setString('notebook_google_email', effectiveEmail);
          if (previousOwner.isEmpty) {
            await prefs.setString(webSessionOwnerKey, effectiveEmail);
          }
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
      final safeCode = RegExp(r'^[a-zA-Z0-9_-]{1,80}$').hasMatch(code)
          ? code
          : 'unknown';
      // ignore: avoid_print
      print('OpenTurathAuth stage=$stage code=$safeCode category=$category');
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
    if (user == null) {
      if (cachedCurrentUser != null) return cachedCurrentUser;
      try {
        final prefs = await SharedPreferences.getInstance();
        final uid = prefs.getString('current_user_uid');
        if (uid != null && uid.isNotEmpty) {
          final cached = await _getCachedUser(uid);
          if (cached != null) return cached;
        }
      } catch (_) {}
      return null;
    }
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

  /// Mencatat akun pemilik sesi Google yang tersimpan di WebView.
  static Future<void> rememberWebSessionOwner(String email) async {
    final owner = email.trim().toLowerCase();
    if (owner.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(webSessionOwnerKey, owner);
    } catch (_) {}
  }

  /// Menghapus sesi Google di WebView bila bukan milik [email], agar akun
  /// sebelumnya tidak terbawa ke pengguna berikutnya di perangkat yang sama.
  static Future<void> reconcileWebSession(String email) async {
    final current = email.trim().toLowerCase();
    if (current.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final owner =
          (prefs.getString(webSessionOwnerKey) ?? '').trim().toLowerCase();
      if (owner.isEmpty || owner == current) {
        await prefs.setString(webSessionOwnerKey, current);
        await PersistentGoogleSession.instance.restoreSessionIfAvailable(current);
        return;
      }
      await PersistentGoogleSession.instance.clearOnSignOut();
      await prefs.setString(webSessionOwnerKey, current);
    } catch (_) {}
  }

  // ── Sign Out ───────────────────────────────────────────────────
  Future<void> signOut() async {
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
    if (user == null) return;
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
          rethrow;
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
