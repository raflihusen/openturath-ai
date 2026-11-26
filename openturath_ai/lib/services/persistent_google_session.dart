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
  int _ownershipEpoch = 0;
  static String? _cachedVerifiedOwner;
  static String? _cachedLiveEmail;
  static int _cachedLiveEpoch = -1;

  String? get verifiedOwner => _cachedVerifiedOwner;

  /// Tandai cache live-session di memori sebagai tidak valid (mis. saat WebView
  /// benar-benar dialihkan ke halaman login Google).
  void invalidateLiveSessionCache() {
    _cachedLiveEmail = null;
    _cachedLiveEpoch = -1;
  }

  /// Brankas cookie lama (v3) disimpan di SharedPreferences. Hanya salinan
  /// lokal itu yang dihapus; cookie yang sedang aktif di OS tidak disentuh.
  static const String _legacyVaultKey = 'ot_persistent_google_cookies_v3';
  static const String _ownerKey = 'webview_session_owner';
  static const String _readyKey = 'google_session_ready';

  /// Owner lama dapat berasal dari login Firebase saja. Marker ini hanya
  /// ditulis setelah identitas WebView diverifikasi oleh alur koneksi Google.
  static const String verifiedOwnerKey = 'webview_session_owner_verified_v1';

  /// Cookie sesi hidup dalam 3 status:
  /// - `true`: cookie sesi Google ditemukan.
  /// - `false`: pembacaan cookie berhasil namun sesi Google tidak ditemukan.
  /// - `null`: seluruh pembacaan cookie gagal/timeout sehingga status tidak dapat dipastikan.
  Future<bool?> hasLiveSessionTriState(
      InAppWebViewController? controller) async {
    final cookieManager = DesktopWebViewRuntime.cookies;
    const sessionNames = {'SID', '__Secure-1PSID', '__Secure-3PSID'};
    final urls = [
      WebUri(NotebookNavigation.canonicalOrigin),
      WebUri('https://accounts.google.com'),
    ];
    var anyReadSucceeded = false;
    for (final url in urls) {
      try {
        final cookies = await cookieManager
            .getCookies(url: url, webViewController: controller)
            .timeout(const Duration(seconds: 4));
        anyReadSucceeded = true;
        final live = cookies.any((c) =>
            sessionNames.contains(c.name) &&
            (c.value?.toString().isNotEmpty ?? false));
        if (live) return true;
      } catch (_) {
        // Lanjut ke domain berikutnya; jika semua gagal kembalikan null.
      }
    }
    return anyReadSucceeded ? false : null;
  }

  /// Cookie sesi hidup, dibaca tanpa mengubah apa pun (Aturan Sakral #8).
  Future<bool> hasLiveSession(InAppWebViewController? controller) async =>
      (await hasLiveSessionTriState(controller)) == true;

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
    final epoch = _ownershipEpoch;
    bool current() => epoch == _ownershipEpoch && isCurrent?.call() != false;
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty || !current()) return false;
    try {
      if (!await hasLiveSession(controller)) return false;
      if (!current()) return false;
      final prefs = await SharedPreferences.getInstance();
      if (!current()) return false;
      await _dropLegacyVault(prefs);
      if (!current()) return false;
      if (cleanEmail.isNotEmpty) {
        _cachedVerifiedOwner = cleanEmail;
        _cachedLiveEmail = cleanEmail;
        _cachedLiveEpoch = epoch;
        await prefs.setString(_ownerKey, cleanEmail);
        if (!current()) return false;
        await prefs.setString(verifiedOwnerKey, cleanEmail);
        if (!current()) return false;
        await prefs.setString('google_session_email', cleanEmail);
        if (!current()) return false;
        await prefs.setString('notebook_google_email', cleanEmail);
      }
      if (!current()) return false;
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
    final epoch = _ownershipEpoch;
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty) return false;
    try {
      final prefs = await SharedPreferences.getInstance();
      await _dropLegacyVault(prefs);
      if (epoch != _ownershipEpoch) return false;
      final savedOwner =
          (prefs.getString(_ownerKey) ?? '').trim().toLowerCase();
      final verifiedOwner =
          (prefs.getString(verifiedOwnerKey) ?? '').trim().toLowerCase();
      if (savedOwner != cleanEmail || verifiedOwner != cleanEmail) {
        invalidateLiveSessionCache();
        await prefs.setBool(_readyKey, false);
        return false;
      }

      // Fast-path dalam sesi aplikasi yang sama hanya jika kepemilikan di disk
      // dan flag ready masih cocok dengan cache in-memory di epoch yang sama.
      if (prefs.getBool(_readyKey) == true &&
          _cachedLiveEmail == cleanEmail &&
          _cachedLiveEpoch == epoch &&
          _cachedVerifiedOwner == cleanEmail) {
        return true;
      }

      final live = await hasLiveSessionTriState(null);
      if (epoch != _ownershipEpoch ||
          prefs.getString(_ownerKey)?.trim().toLowerCase() != cleanEmail ||
          prefs.getString(verifiedOwnerKey)?.trim().toLowerCase() !=
              cleanEmail) {
        return false;
      }
      if (live == true) {
        _cachedVerifiedOwner = cleanEmail;
        _cachedLiveEmail = cleanEmail;
        _cachedLiveEpoch = epoch;
        await prefs.setBool(_readyKey, true);
        return true;
      }
      // Hanya hapus _readyKey jika pembacaan cookie benar-benar sukses dan
      // membuktikan sesi tidak ada (false); bila gagal/timeout (null), pertahankan
      // flag disk agar startup offline / WebView2 sibuk tidak merusak status sesi.
      if (live == false) {
        invalidateLiveSessionCache();
        await prefs.setBool(_readyKey, false);
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Mencatat email pengguna yang berhasil login Google sebagai pemilik sesi yang terverifikasi.
  Future<void> establishVerifiedOwner(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty) return;
    final epoch = _ownershipEpoch;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (epoch != _ownershipEpoch) return;
      _cachedVerifiedOwner = cleanEmail;
      _cachedLiveEmail = cleanEmail;
      _cachedLiveEpoch = epoch;
      await prefs.setString(_ownerKey, cleanEmail);
      if (epoch != _ownershipEpoch) return;
      await prefs.setString(verifiedOwnerKey, cleanEmail);
      if (epoch != _ownershipEpoch) return;
      await prefs.setString('google_session_email', cleanEmail);
      if (epoch != _ownershipEpoch) return;
      await prefs.setString('notebook_google_email', cleanEmail);
      if (epoch != _ownershipEpoch) return;
      await prefs.setBool(_readyKey, true);
    } catch (_) {}
  }

  /// Melepas klaim kepemilikan sesi tanpa menghapus cookie WebView, dipakai
  /// saat akun aplikasi berganti. Sesi Google dipilih ulang lewat pemilih akun.
  Future<void> releaseOwnership() async {
    _ownershipEpoch++;
    _cachedVerifiedOwner = null;
    invalidateLiveSessionCache();
    try {
      final prefs = await SharedPreferences.getInstance();
      await _dropLegacyVault(prefs);
      await prefs.remove(_ownerKey);
      await prefs.remove(verifiedOwnerKey);
      await prefs.remove('google_session_email');
      await prefs.remove('notebook_google_email');
      await prefs.setBool(_readyKey, false);
    } catch (_) {}
  }

  /// Pembersihan global: HANYA untuk Log Out atau hapus akun yang dipicu
  /// eksplisit oleh pengguna.
  Future<void> clearOnSignOut() async {
    _ownershipEpoch++;
    _cachedVerifiedOwner = null;
    invalidateLiveSessionCache();
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
