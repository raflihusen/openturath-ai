import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/notebook_navigation.dart';
import 'desktop_webview_runtime.dart';

/// Penanda kepemilikan sesi Google di WebView.
///
/// Persistensi cookie sepenuhnya dikelola mesin WebKit/WebView2. Kelas ini
/// TIDAK menyalin, memperpanjang, atau menulis ulang cookie Google (Aturan
/// Sakral #8 AGENTS.md): hanya mencatat akun pemilik sesi dan memeriksa secara
/// baca-saja apakah cookie sesi masih hidup.
class PersistentGoogleSession {
  PersistentGoogleSession._();
  static final PersistentGoogleSession instance = PersistentGoogleSession._();

  /// Brankas cookie lama (v3) disimpan di SharedPreferences. Hanya salinan
  /// lokal itu yang dihapus; cookie yang sedang aktif di OS tidak disentuh.
  static const String _legacyVaultKey = 'ot_persistent_google_cookies_v3';
  static const String _ownerKey = 'webview_session_owner';
  static const String _readyKey = 'google_session_ready';

  /// Owner lama dapat berasal dari login Firebase saja. Marker ini hanya
  /// ditulis setelah identitas WebView diverifikasi oleh alur koneksi Google.
  static const String verifiedOwnerKey = 'webview_session_owner_verified_v1';

  /// Cookie sesi hidup, dibaca tanpa mengubah apa pun.
  Future<bool> _hasLiveSession(InAppWebViewController? controller) async {
    final cookieManager = DesktopWebViewRuntime.cookies;
    for (final url in [
      WebUri(NotebookNavigation.canonicalOrigin),
      WebUri('https://accounts.google.com'),
    ]) {
      final cookies = await cookieManager
          .getCookies(url: url, webViewController: controller)
          .timeout(const Duration(seconds: 5));
      final live = cookies.any((c) =>
          (c.name == 'SID' || c.name == '__Secure-1PSID') &&
          (c.value?.toString().isNotEmpty ?? false));
      if (live) return true;
    }
    return false;
  }

  Future<void> _dropLegacyVault(SharedPreferences prefs) async {
    if (prefs.containsKey(_legacyVaultKey)) await prefs.remove(_legacyVaultKey);
  }

  /// Mencatat [email] yang sudah diverifikasi oleh alur koneksi Google sebagai
  /// pemilik sesi. Cookie hanya membuktikan keberadaan sesi, bukan identitasnya.
  /// Mengembalikan false bila akun kosong atau cookie sesi tidak tersedia.
  Future<bool> lockAndPersistCookies(
    InAppWebViewController? controller,
    String email, {
    bool Function()? isCurrent,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty || isCurrent?.call() == false) return false;
    try {
      if (!await _hasLiveSession(controller)) return false;
      if (isCurrent?.call() == false) return false;
      final prefs = await SharedPreferences.getInstance();
      if (isCurrent?.call() == false) return false;
      await _dropLegacyVault(prefs);
      if (isCurrent?.call() == false) return false;
      if (cleanEmail.isNotEmpty) {
        await prefs.setString(_ownerKey, cleanEmail);
        await prefs.setString(verifiedOwnerKey, cleanEmail);
        await prefs.setString('google_session_email', cleanEmail);
        await prefs.setString('notebook_google_email', cleanEmail);
      }
      await prefs.setBool(_readyKey, true);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Benar bila [email] pemilik sesi tercatat DAN cookie sesi masih hidup di
  /// WebView. Tidak pernah menulis cookie; sesi kedaluwarsa berarti pengguna
  /// harus masuk kembali lewat alur resmi Google.
  Future<bool> restoreSessionIfAvailable(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty) return false;
    try {
      final prefs = await SharedPreferences.getInstance();
      await _dropLegacyVault(prefs);
      final savedOwner =
          (prefs.getString(_ownerKey) ?? '').trim().toLowerCase();
      final verifiedOwner =
          (prefs.getString(verifiedOwnerKey) ?? '').trim().toLowerCase();
      if (savedOwner != cleanEmail || verifiedOwner != cleanEmail) {
        await prefs.setBool(_readyKey, false);
        return false;
      }

      if (await _hasLiveSession(null)) {
        await prefs.setBool(_readyKey, true);
        return true;
      }
      await prefs.setBool(_readyKey, false);
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Melepas klaim kepemilikan sesi tanpa menghapus cookie WebView, dipakai
  /// saat akun aplikasi berganti. Sesi Google dipilih ulang lewat pemilih akun.
  Future<void> releaseOwnership() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await _dropLegacyVault(prefs);
      await prefs.remove(_ownerKey);
      await prefs.remove(verifiedOwnerKey);
      await prefs.setBool(_readyKey, false);
    } catch (_) {}
  }

  /// Pembersihan global: HANYA untuk Log Out atau hapus akun yang dipicu
  /// eksplisit oleh pengguna.
  Future<void> clearOnSignOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_legacyVaultKey);
      await prefs.remove(_ownerKey);
      await prefs.remove(verifiedOwnerKey);
      await prefs.remove(_readyKey);
      await DesktopWebViewRuntime.clearSession();
    } catch (_) {}
  }
}
