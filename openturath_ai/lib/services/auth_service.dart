import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../core/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '255541559800-jcip3mf8umtscgf5jm8khflm4u83rmcj.apps.googleusercontent.com',
  );
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Current Firebase User ──────────────────────────────────────
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Google Sign In ─────────────────────────────────────────────
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User membatalkan login

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) return null;

      // ── Cek apakah user sudah ada di Firestore ──
      try {
        final docRef =
            _db.collection(AppConstants.colUsers).doc(firebaseUser.uid);
        final doc = await docRef.get().timeout(const Duration(seconds: 4));

        if (!doc.exists) {
          // ── User baru: buat dokumen dengan plan trial ──
          final newUser = UserModel(
            uid: firebaseUser.uid,
            name: firebaseUser.displayName ?? 'Pengguna',
            email: firebaseUser.email ?? '',
            photoUrl: firebaseUser.photoURL ?? '',
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
          return newUser;
        } else {
          return UserModel.fromFirestore(doc);
        }
      } catch (_) {
        // Fallback user jika Firestore lambat / offline
        return UserModel(
          uid: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'Pengguna',
          email: firebaseUser.email ?? '',
          photoUrl: firebaseUser.photoURL ?? '',
          plan: AppConstants.planTrial,
          questionsUsed: 0,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // ── Guest / Anonymous Sign In (Fallback jika Google Play Services gagal) ──
  Future<UserModel?> signInAsGuest() async {
    try {
      final UserCredential userCredential = await _auth.signInAnonymously();
      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) return _localGuestUser();

      try {
        final docRef =
            _db.collection(AppConstants.colUsers).doc(firebaseUser.uid);
        final doc = await docRef.get().timeout(const Duration(seconds: 4));

        if (!doc.exists) {
          final newUser = UserModel(
            uid: firebaseUser.uid,
            name: 'Peneliti Tamu',
            email: 'tamu@openturath.ai',
            photoUrl: '',
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
          return newUser;
        } else {
          return UserModel.fromFirestore(doc);
        }
      } catch (_) {
        return _localGuestUser();
      }
    } catch (_) {
      return _localGuestUser();
    }
  }

  UserModel _localGuestUser() {
    return UserModel(
      uid: 'guest_user',
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
        return UserModel(
          uid: user.uid,
          name: user.displayName ?? 'Pengguna',
          email: user.email ?? '',
          photoUrl: user.photoURL ?? '',
          plan: AppConstants.planTrial,
          questionsUsed: 0,
        );
      }
      return UserModel.fromFirestore(doc);
    } catch (_) {
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

  // ── Stream user changes (real-time) ───────────────────────────
  Stream<UserModel?> get userStream {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) return Stream.value(null);
      return _db
          .collection(AppConstants.colUsers)
          .doc(user.uid)
          .snapshots()
          .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
    });
  }

  // ── Sign Out ───────────────────────────────────────────────────
  Future<void> signOut() async {
    try {
      // Clear all cookies, session cookies, cache, and web storage in WebView first
      final cookieManager = CookieManager.instance();
      await cookieManager.deleteAllCookies();
      await cookieManager.removeSessionCookies();
      await InAppWebViewController.clearAllCache();
      await WebStorageManager.instance().deleteAllData();
    } catch (e) {
      // Ignore if not supported on current platform/test
    }

    try {
      await _googleSignIn.signOut();
    } catch (e) {
      // Ignore
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('google_session_ready');
      await prefs.remove('last_opened_notebook_id');
    } catch (_) {}

    try {
      await _auth.signOut();
    } catch (e) {
      // Ignore
    }
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

  // ── Delete Account & User Data (Google Play Compliance) ─────────
  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user == null) return;

    // 1. Hapus dokumen profil di Firestore jika ada
    try {
      await _db
          .collection(AppConstants.colUsers)
          .doc(user.uid)
          .delete()
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      // Abaikan jika offline / rule restricted
    }

    // 2. Bersihkan seluruh session cookies, cache, dan data lokal WebView
    try {
      final cookieManager = CookieManager.instance();
      await cookieManager.deleteAllCookies();
      await cookieManager.removeSessionCookies();
      await InAppWebViewController.clearAllCache();
      await WebStorageManager.instance().deleteAllData();
    } catch (_) {}

    // 3. Bersihkan seluruh penyimpanan lokal SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (_) {}

    // 4. Putuskan hubungan Google Sign In
    try {
      await _googleSignIn.disconnect();
    } catch (_) {
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
    }

    // 5. Hapus akun pengguna secara permanen dari Firebase Auth
    try {
      await user.delete();
    } catch (e) {
      // Jika require recent login, logout dan sign out
      await _auth.signOut();
      rethrow;
    }

    // 6. Pastikan sign out bersih
    try {
      await _auth.signOut();
    } catch (_) {}
  }
}
