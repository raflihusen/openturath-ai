# OpenTurath AI — Master Plan Arsitektur, Sesi Permanen, Keamanan VIP & Redesign Pembayaran

**Versi Dokumen:** 2.0 (Production Implementation Blueprint)  
**Target Sistem:** Flutter Client (`v1.0.66+67`), macOS (`WKWebView` Ad-Hoc Signing), Android (`InAppWebView`), dan Firebase Cloud Functions + VPS Worker (`open-turath`)  
**Bahasa Desain:** *Monochrome Editorial — The Quiet Islamic Scholar*

## 1. Ringkasan Eksekutif & Matriks Transformasi Arsitektur

Dokumen perencanaan ini merangkum seluruh temuan audit sistem **OpenTurath AI** beserta solusi kode tingkat produksi (*drop-in production code*) untuk menyelesaikan lima masalah fundamental aplikasi secara permanen:

1. **Penghapusan Masalah "Double Login" & Hilangnya Cookie di macOS**: Mengatasi isolasi kredensial antara `FirebaseAuth` dan `InAppWebView` melalui kombinasi **ServiceLogin-to-OAuth Chaining** (1x login untuk keduanya), **Cookie Expiration Pinning (180 Hari)** agar `WKWebView` macOS tidak menghapus *session cookie* saat aplikasi ditutup (`Cmd+Q`), serta **Brankas Cookie Lokal (`PersistentGoogleSession`)** yang bertahan hingga pengguna menekan tombol **Log Out**.
2. **Redesign Total Pengalaman Pembayaran (*Bithāqah Al-Intisāb* / بطاقة الانتساب العلمي)**: Mengganti tampilan tabel harga SaaS generik pada `SubscriptionScreen`, `PaymentCheckoutSheet`, dan `PaymentSuccessDialog` menjadi antarmuka *Kartu Akses Majelis & Buku Besar Pustaka* yang menyatu 100% dengan estetika monokrom arsitektural OpenTurath.
3. **Kestabilan Siklus Hidup WebView & DOM Injection (`notebook_ui_script.dart`)**: Mencegah *layout thrashing* (infinite reflow) saat streaming jawaban AI, melindungi chip nomor sitasi kitab (`[1]`, `[2]`) agar tidak ikut tersembunyi oleh aturan CSS global, dan menjaga `PlatformView` tetap stabil saat terjadi galat jaringan.
4. **Manajemen Memori Ketat untuk macOS 8GB RAM**: Menurunkan beban RAM dari ~1,5 GB menjadi <600 MB melalui pembatasan `maxTabs = 2` di macOS, pembekuan `MutationObserver` pada tab latar belakang (`window.otSetSuspended`), serta pemaksaan navigasi ke `about:blank` sebelum `disposeKeepAlive`.
5. **Keamanan Hak Akses VIP Mutlak & Isolasi Langganan Per-Modul (*Zero Leakage*)**: Menutup celah kebocoran lintas-modul pada `getEntitlementAccess()` dan `dailyRevoke` (`bahits_1y`), mencegah *compounding loop* perpanjangan ganda pada sinkronisasi GoAkal (`applyAkalPurchase`), serta menyamakan daftar email VIP antara server dan klien (`UserModel`).

| Area Sistem | Kondisi Saat Ini (Sebelum Refactoring) | Kondisi Target (Sesudah Refactoring) | File yang Dimodifikasi / Dibuat |
| :--- | :--- | :--- | :--- |
| **Autentikasi & Sesi WebView** | Login 2x (Native OAuth lalu WebView); `reconcileWebSession()` dan `_resetPendingSession()` menghapus cookie sendiri; cookie `WKWebView` macOS hilang saat aplikasi ditutup. | **1x Login** (atau *Auto-Restore Vault* 0-klik); setiap cookie Google di-*pin* 180 hari ke depan di disk & di-backup di brankas lokal sampai **Log Out**. | `lib/services/persistent_google_session.dart` *(Baru)*, `lib/services/auth_service.dart`, `lib/screens/splash_screen.dart`, `lib/screens/login_screen.dart`, `lib/screens/google_session_auth_screen.dart` |
| **Desain UI/UX Pembayaran** | 2 kalkulator harga ditumpuk sekaligus (6 tombol durasi + 2 tombol bayar); header checkout ramai; animasi memantul (`elasticOut`) bertabrakan dengan tema tenang. | **Kartu Bithāqah Arsitektural Hidup** (dengan lengkung mihrab `otArchPath` & watermark Arab dinamis), **Buku Besar Masa Akses**, **1 Dermaga Bayar**, & **Piagam Aktivasi**. | `lib/screens/subscription_screen.dart`, `lib/widgets/payment_checkout_sheet.dart`, `lib/widgets/payment_success_dialog.dart` |
| **DOM Injection & Siklus WebView** | `composerObserver` tanpa debounce memicu `querySelectorAll('*')` + `getComputedStyle` tiap frame; selector `[class*="chip" i]` menyembunyikan sitasi kitab. | `composerObserver` ter-debounce 180ms tanpa `querySelectorAll('*')`; chip sitasi kitab terlindungi; `window.otSetSuspended` menjeda observer di background. | `lib/core/notebook_ui_script.dart`, `lib/widgets/agent_multi_tab_room.dart` |
| **Memori macOS 8GB RAM** | 3 proses `WKWebViewContentProcess` aktif terus (~1,5 GB RAM); `disposeKeepAlive` tidak mengosongkan DOM `about:blank`. | `maxTabs = 2` di macOS; tab nonaktif membekukan observer JS; `disposeWebResources()` memuat `about:blank` sebelum melepas `keepAlive`. | `lib/services/agent_session_manager.dart`, `lib/widgets/agent_multi_tab_room.dart` |
| **Keamanan VIP & Isolasi Modul** | `bahits_1y` dianggap `all_access` di `dailyRevoke`; `globalPlanPattern` membocorkan 24 modul; `cleanPlan.contains('fiqh')` bocor; ID GoAkal memicu *compounding*. | Isolasi per-modul ketat di server & klien; proteksi VIP mutlak di `dailyRevoke` Phase 1 & `UserModel`; deduplikasi transaksi GoAkal berdasarkan `(scope, paid_ms, amount)`. | `functions/src/index.ts`, `functions/src/native_chat.ts`, `lib/models/user_model.dart` |

## 2. Pilar 1 — Arsitektur "Single Login & Eternal Cookie Vault"

### 2.1 Diagnosis Akar Masalah (Root Cause Analysis)
1. **Isolasi Penyimpanan OS**: Login pertama (`GoogleSignIn` native di `lib/services/auth_service.dart` L162–218) berjalan di `ASWebAuthenticationSession` (macOS/iOS) atau Credential Manager (Android) yang ruang penyimpanannya terpisah dari `WKHTTPCookieStore` milik `InAppWebView` ([Apple Developer Documentation](https://www.google.com/search?q=https%3A%2F%2Fdeveloper.apple.com%2Fdocumentation%2Fauthenticationservices%2Fsupporting-single-sign-on-in-a-web-browser-app)).
2. **Kebijakan `disallowed_useragent` Google**: Membuka `/o/oauth2/v2/auth` secara langsung di *embedded WebView* dengan User-Agent bawaan WebView (`; wv`) ditolak oleh Google dengan galat `403: disallowed_useragent` ([Google Developers Blog](https://www.google.com/search?q=https%3A%2F%2Fdevelopers.googleblog.com%2Fupcoming-security-changes-to-googles-oauth-20-authorization-endpoint-in-embedded-webviews%2F), [Google OAuth 2.0 Docs](https://www.google.com/search?q=https%3A%2F%2Fdevelopers.google.com%2Fidentity%2Fprotocols%2Foauth2%2Fjavascript-implicit-flow)).
3. **Empat Bug Penghancur Sesi di Kode Eksisting**:
   - **Bug 1 (`lib/services/auth_service.dart` L390–399 & `lib/screens/login_screen.dart` L90)**: Sesaat setelah `signInWithGoogle()` selesai, `login_screen.dart` memanggil `AuthService.reconcileWebSession(userEmail)`. Karena `signInWithGoogle()` belum menyimpan `webview_session_owner`, nilai `owner` masih kosong (`''`), sehingga `owner == current` bernilai `false` dan fungsi langsung mengeksekusi `DesktopWebViewRuntime.clearSession()` yang **menghapus seluruh cookie WebView**.
   - **Bug 2 (`lib/screens/google_session_auth_screen.dart` L61–72)**: Fungsi `_resetPendingSession()` di `initState()` langsung mengubah `google_session_ready` menjadi `false` setiap kali layar dibuka.
   - **Bug 3 (`lib/services/auth_service.dart` L425)**: Fungsi `signOut()` menghapus `google_session_ready`, tetapi komentarnya mengasumsikan sesi WebView dipertahankan.
   - **Bug 4 (`WKWebView` macOS Session-Only Cookies)**: Di macOS, sebagian cookie autentikasi Google diterima tanpa atribut `expiresDate` eksplisit. Oleh `WKWebView`, cookie tanpa `expiresDate` dikategorikan sebagai *session-only cookie* yang langsung dimusnahkan begitu aplikasi ditutup (`Cmd+Q`) ([StackOverflow / WebKit Behavior](https://www.google.com/search?q=https%3A%2F%2Fstackoverflow.com%2Fquestions%2F53670770%2Fhow-does-sfauthenticationsession-store-session-related-cookies-in-safari)).

### 2.2 Strategi Solusi Permanen (Dual-Layer Architecture)
Untuk memastikan pengguna mendapatkan pengalaman **1x Login** yang mulus sekaligus menjamin **cookie tidak pernah hilang sampai tombol Log Out ditekan**, kita menerapkan dua mekanisme yang saling mengunci:

1. **Mekanisme A — *ServiceLogin-to-OAuth Chaining* (1x Login untuk Firebase + NotebookLM)**:
   - Alih-alih mengarahkan WebView langsung ke `/o/oauth2/v2/auth`, WebView (dengan `userAgent` Safari macOS / Chrome resmi dari `AppConstants`) diarahkan ke halaman login web pihak pertama Google: `https://accounts.google.com/ServiceLogin?passive=true&continue=<URL_OAUTH_FIREBASE>`.
   - Halaman `ServiceLogin` tidak pernah terkena blokir `disallowed_useragent`. Begitu pengguna login 1 kali di halaman tersebut:
     - Cookie `.google.com` (`SID`, `HSID`, `SSID`, `__Secure-1PSID`, `__Secure-3PSID`) langsung tertanam di `InAppWebView` (sehingga NotebookLM langsung siap dibuka).
     - Google otomatis meneruskan (*redirect*) ke URL `continue` (OAuth Firebase) yang langsung mengeluarkan `id_token` & `access_token` untuk mengautentikasi `FirebaseAuth.instance.signInWithCredential(...)`.
2. **Mekanisme B — *Cookie Expiration Pinning (180 Hari) + Persistent Cookie Vault***:
   - Setiap kali sesi Google terdeteksi aktif di `InAppWebView` (baik dari alur 1x login maupun alur 2 langkah), `PersistentGoogleSession.lockAndPersistCookies()` membaca seluruh cookie `.google.com` dan `notebook.google.com`.
   - Setiap cookie ditulis ulang (*re-set*) ke `CookieManager` dengan memaksa **`expiresDate` = 180 hari ke depan**, mengubah statusnya dari *Session Cookie* menjadi **Persistent Disk Cookie** di macOS `WKHTTPCookieStore`.
   - Salinan JSON seluruh cookie tersebut juga disimpan ke brankas lokal (`ot_persistent_google_cookies_v2`). Saat aplikasi dibuka kembali (`SplashScreen` atau sebelum membuka `AgentMultiTabRoom`), `restoreSessionIfAvailable()` menyuntikkan kembali cookie tersebut ke `CookieManager` jika `WKWebView` kehilangannya akibat ad-hoc signing atau pembaruan aplikasi.

### 2.3 Spesifikasi Kode Implementasi Pilar 1

#### File Baru: `lib/services/persistent_google_session.dart`
```dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/notebook_navigation.dart';
import 'desktop_webview_runtime.dart';

class PersistentGoogleSession {
  PersistentGoogleSession._();
  static final PersistentGoogleSession instance = PersistentGoogleSession._();

  static const String _vaultKey = 'ot_persistent_google_cookies_v2';
  static const String _ownerKey = 'webview_session_owner';
  static const String _readyKey = 'google_session_ready';

  static const String _webClientId =
      '255541559800-jcip3mf8umtscgf5jm8khflm4u83rmcj.apps.googleusercontent.com';
  static const String redirectUri =
      'https://open-turath.firebaseapp.com/__/auth/handler';

  static const Set<String> _googleAuthCookies = {
    'SID',
    'HSID',
    'SSID',
    'APISID',
    'SAPISID',
    '__Secure-1PSID',
    '__Secure-3PSID',
    '__Secure-1PAPISID',
    '__Secure-3PAPISID',
    '__Secure-1PSIDTS',
    '__Secure-3PSIDTS',
    'SIDCC',
    '__Secure-1PSIDCC',
    '__Secure-3PSIDCC',
    'LSID',
  };

  /// Bangun URL "ServiceLogin -> OAuth Chain":
  /// Login 1x di halaman web Google yang sekaligus menanamkan cookie NotebookLM
  /// dan me-redirect ke OAuth Firebase untuk menerbitkan id_token.
  String buildSingleLoginChainUrl({String? loginHint}) {
    final nonce = List<int>.generate(16, (_) => Random.secure().nextInt(256))
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();

    final oauthContinue = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
      'client_id': _webClientId,
      'redirect_uri': redirectUri,
      'response_type': 'id_token token',
      'scope': 'openid email profile',
      'nonce': nonce,
      if (loginHint != null && loginHint.isNotEmpty) 'login_hint': loginHint,
    }).toString();

    return Uri.https('accounts.google.com', '/ServiceLogin', {
      'passive': 'true',
      'continue': oauthContinue,
      if (loginHint != null && loginHint.isNotEmpty) 'Email': loginHint,
    }).toString();
  }

  /// Baca seluruh cookie sesi Google dari WebView, pin expiresDate = 180 hari ke depan
  /// di WKHTTPCookieStore, dan simpan salinannya ke brankas lokal.
  Future<bool> lockAndPersistCookies(
    InAppWebViewController? controller,
    String email,
  ) async {
    final cleanEmail = email.trim().toLowerCase();
    try {
      final cookieManager = DesktopWebViewRuntime.cookies;
      final urls = [
        WebUri('https://google.com'),
        WebUri('https://accounts.google.com'),
        WebUri(NotebookNavigation.canonicalOrigin),
      ];

      final pinnedExpiry =
          DateTime.now().add(const Duration(days: 180)).millisecondsSinceEpoch;
      final Map<String, Map<String, dynamic>> vaultMap = {};

      for (final url in urls) {
        final cookies = await cookieManager.getCookies(
          url: url,
          webViewController: controller,
        );
        for (final c in cookies) {
          final value = c.value?.toString() ?? '';
          if (value.isEmpty) continue;
          if (_googleAuthCookies.contains(c.name) ||
              c.name.startsWith('__Secure-') ||
              c.name.startsWith('__Host-')) {
            final domain = c.domain ?? '.google.com';
            final path = c.path ?? '/';
            final effectiveExpiry =
                (c.expiresDate != null && c.expiresDate! > pinnedExpiry)
                    ? c.expiresDate!
                    : pinnedExpiry;

            final host = domain.replaceFirst(RegExp(r'^\.'), '');
            await cookieManager.setCookie(
              url: WebUri('https://$host'),
              name: c.name,
              value: value,
              domain: domain,
              path: path,
              expiresDate: effectiveExpiry,
              isSecure: c.isSecure ?? true,
              isHttpOnly: c.isHttpOnly ?? true,
              sameSite: HTTPCookieSameSitePolicy.NONE,
            );

            vaultMap['$domain|$path|${c.name}'] = {
              'name': c.name,
              'value': value,
              'domain': domain,
              'path': path,
              'expiresDate': effectiveExpiry,
              'isSecure': c.isSecure ?? true,
              'isHttpOnly': c.isHttpOnly ?? true,
            };
          }
        }
      }

      if (vaultMap.isEmpty) return false;

      final prefs = await SharedPreferences.getInstance();
      if (cleanEmail.isNotEmpty) {
        await prefs.setString(_ownerKey, cleanEmail);
        await prefs.setString('google_session_email', cleanEmail);
        await prefs.setString('notebook_google_email', cleanEmail);
      }
      await prefs.setBool(_readyKey, true);
      await prefs.setString(
        _vaultKey,
        jsonEncode({
          'owner': cleanEmail,
          'savedAt': DateTime.now().millisecondsSinceEpoch,
          'cookies': vaultMap.values.toList(),
        }),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Pulihkan cookie dari brankas ke CookieManager sebelum WebView dibuka.
  Future<bool> restoreSessionIfAvailable(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_vaultKey);
      final cookieManager = DesktopWebViewRuntime.cookies;

      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        final savedOwner = (decoded['owner'] as String? ?? '').toLowerCase();
        if (cleanEmail.isEmpty ||
            savedOwner.isEmpty ||
            savedOwner == cleanEmail) {
          final List<dynamic> list =
              decoded['cookies'] as List<dynamic>? ?? const [];
          final fallbackExpiry = DateTime.now()
              .add(const Duration(days: 180))
              .millisecondsSinceEpoch;

          for (final item in list.whereType<Map<String, dynamic>>()) {
            final domain = (item['domain'] as String?) ?? '.google.com';
            final host = domain.replaceFirst(RegExp(r'^\.'), '');
            await cookieManager.setCookie(
              url: WebUri('https://$host'),
              name: item['name'] as String,
              value: item['value'] as String,
              domain: domain,
              path: (item['path'] as String?) ?? '/',
              expiresDate: (item['expiresDate'] as int?) ?? fallbackExpiry,
              isSecure: item['isSecure'] as bool? ?? true,
              isHttpOnly: item['isHttpOnly'] as bool? ?? true,
              sameSite: HTTPCookieSameSitePolicy.NONE,
            );
          }
          if (list.isNotEmpty) {
            await prefs.setBool(_readyKey, true);
            if (cleanEmail.isNotEmpty) {
              await prefs.setString(_ownerKey, cleanEmail);
            }
            return true;
          }
        }
      }

      final liveCookies = await cookieManager.getCookies(
        url: WebUri(NotebookNavigation.canonicalOrigin),
      );
      final hasLive = liveCookies.any(
        (c) =>
            (c.name == 'SID' || c.name == '__Secure-1PSID') &&
            (c.value?.toString().isNotEmpty ?? false),
      );
      if (hasLive) {
        await lockAndPersistCookies(null, cleanEmail);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Hanya dipanggil saat pengguna benar-benar menekan tombol Keluar (Log Out)
  /// atau berganti ke akun Google yang berbeda.
  Future<void> clearOnSignOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_vaultKey);
      await prefs.remove(_ownerKey);
      await prefs.remove(_readyKey);
      await DesktopWebViewRuntime.clearSession();
    } catch (_) {}
  }
}
```

#### Perubahan pada `lib/services/auth_service.dart`
1. Pada `signInWithGoogle()` (L210–222), simpan `webSessionOwnerKey` jika belum ada pemilik sebelumnya agar sesi tidak dihapus oleh `reconcileWebSession`:
```dart
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
```
2. Pada `reconcileWebSession()` (L390–399) dan `signOut()` (L402–436):
```dart
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

      // Pemilik akun berubah: bersihkan brankas lama dan ikat ke pemilik baru
      await PersistentGoogleSession.instance.clearOnSignOut();
      await prefs.setString(webSessionOwnerKey, current);
    } catch (_) {}
  }
```
*(Di dalam `signOut()`, tambahkan `await PersistentGoogleSession.instance.clearOnSignOut();` agar saat pengguna benar-benar menekan tombol Keluar, brankas ikut dibersihkan secara aman).*

#### Perubahan pada `lib/screens/splash_screen.dart` (L35–53) & `lib/screens/login_screen.dart` (L80–97)
- Di `splash_screen.dart`:
```dart
        final restoredUser = await AuthService().restoreSession();
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (restoredUser != null ||
            (firebaseUser != null && !firebaseUser.isAnonymous)) {
          final currentEmail =
              (firebaseUser?.email ?? restoredUser?.email ?? '')
                  .trim()
                  .toLowerCase();
          final sessionReady = await PersistentGoogleSession.instance
              .restoreSessionIfAvailable(currentEmail);
          targetRoute =
              sessionReady ? AppRoutes.dashboard : AppRoutes.googleSessionAuth;
        }
```
- Di `login_screen.dart`:
```dart
      final user = await _authService.signInWithGoogle();

      if (user != null && mounted) {
        final userEmail = user.email.trim().toLowerCase();
        await AuthService.reconcileWebSession(userEmail);
        final sessionReady = await PersistentGoogleSession.instance
            .restoreSessionIfAvailable(userEmail);
        if (!mounted) return;

        if (sessionReady) {
          Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.googleSessionAuth);
        }
        return;
      }
```

#### Perubahan pada `lib/screens/google_session_auth_screen.dart`
1. Hapus `_resetPendingSession()` di `initState()` (L61–72) dan ganti dengan pemeriksaan auto-restore:
```dart
  @override
  void initState() {
    super.initState();
    _tryAutoRestoreSession();
  }

  Future<void> _tryAutoRestoreSession() async {
    final email = (AuthService().cachedCurrentUser?.email ??
            AuthService().currentUser?.email ??
            '')
        .trim()
        .toLowerCase();
    if (email.isNotEmpty) {
      final restored = await PersistentGoogleSession.instance
          .restoreSessionIfAvailable(email);
      if (restored && mounted) {
        await _onSessionAuthenticated();
      }
    }
  }
```
2. Tambahkan `userAgent` standar pada `InAppWebViewSettings` (L676–699):
```dart
      userAgent: AppPlatform.isDesktop
          ? AppConstants.desktopSafariUserAgent
          : AppConstants.chromeMobileUserAgent,
```
3. Pada `_onSessionAuthenticated()` (L452–477) serta pada `_checkReady()` di `lib/widgets/agent_multi_tab_room.dart` (L1290–1306), kunci cookie ke brankas 180 hari:
```dart
    final email = (AuthService().cachedCurrentUser?.email ??
            AuthService().currentUser?.email ??
            '')
        .trim()
        .toLowerCase();
    await PersistentGoogleSession.instance
        .lockAndPersistCookies(_webController, email);
    await AuthService.rememberWebSessionOwner(email);
```

## 3. Pilar 2 — Redesign Total UI/UX Pembayaran ("Bithāqah Al-Intisāb")

### 3.1 Filosofi & Struktur Visual Baru
Menggantikan pola dua kartu harga SaaS yang berdesakan dengan tata letak editorial satu fokus (**The Scholar's Pass & Archival Ledger**):
- **Bagian 1 — Kartu Bithāqah Hidup (`_ScholarlyPassPreview`)**: Panel gelap (`OTExpressive.hero`) dengan siluet lengkung mihrab (`otArchPath`) dan watermark kaligrafi Arab (`OTInkCard`) yang secara dinamis menampilkan nama bidang ilmu, masa aktif dalam kalender Masehi & Hijriah (`HijriDateUtils`), serta harga tabular.
- **Bagian 2 — Pengalih Jalur Kajian (`_TrackSwitcher`)**: Memilih antara **Koleksi Khusus · Fikih Tahawwulat (5 AI)** (menampilkan indeks bernomor `01`–`05` seperti daftar bab kitab) atau **Satu Bidang Ilmu (20 AI Spesialis)** (menampilkan pemilih katalog dengan pencarian instan).
- **Bagian 3 — Buku Besar Masa Akses (`_EditorialTierLedger`)**: Menyajikan durasi **1 Bulan**, **6 Bulan**, dan **12 Bulan** sebagai baris buku besar horizontal yang lapang, lengkap dengan badge *PILIHAN TERBAIK*, persentase penghematan, harga normal tercoret, dan ekuivalen biaya bulanan.
- **Bagian 4 — Dermaga Pengesahan Bawah (`_AnchoredCheckoutDock`)**: Hanya satu tombol aksi pembayaran utama di bagian bawah layar.
- **Bagian 5 — Slip Checkout Arsip & Piagam Aktivasi (`PaymentCheckoutSheet` & `PaymentSuccessDialog`)**: Mengubah header lembar pembayaran menjadi slip arsip perpustakaan dengan nomor invoice bermonospace (`ScholarlyFonts.jetBrainsMono`) dan mengubah dialog sukses menjadi piagam bermihrab.

### 3.2 Kode Lengkap `lib/screens/subscription_screen.dart`

```dart
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_copy.dart';
import '../core/app_platform.dart';
import '../core/arabic_ui_labels.dart';
import '../core/design/ot_buttons.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_expressive.dart';
import '../core/design/ot_motion.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_typography.dart';
import '../core/hijri_date_utils.dart';
import '../core/localization.dart';
import '../core/product_pricing.dart';
import '../core/scholarly_fonts.dart';
import '../models/agent_model.dart';
import '../models/sub_agent_model.dart';
import '../services/auth_service.dart';
import '../services/subscription_service.dart';
import '../services/telemetry_service.dart';
import '../widgets/adaptive_sheet.dart';
import '../widgets/app_loader.dart';
import '../widgets/ot_arch_motion.dart';
import '../widgets/ot_ink_card.dart';
import '../widgets/ot_motion_widgets.dart';
import '../widgets/payment_checkout_sheet.dart';
import '../widgets/payment_success_dialog.dart';
import '../widgets/redeem_code_sheet.dart';

enum _StudyTrack { flagship, specialist }

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final _service = SubscriptionService();

  _StudyTrack _track = _StudyTrack.flagship;
  String _selectedAgentId = 'fiqh_syafii';
  int _tahawwulatIndex = 2;
  int _specialistIndex = 2;
  bool _processing = false;
  bool _initialized = false;
  String? _checkoutError;

  List<AgentModel> get _specialists => AgentModel.defaultAgents
      .where((a) =>
          a.kind == CorpusKind.discipline &&
          a.isActive &&
          a.id != 'fiqh_tahawwulat')
      .toList();

  AgentModel get _flagshipAgent =>
      AgentModel.defaultAgents.firstWhere((a) => a.id == 'fiqh_tahawwulat');

  AgentModel get _selectedSpecialist => _specialists.firstWhere(
        (a) => a.id == _selectedAgentId,
        orElse: () => _specialists.first,
      );

  AgentModel get _activeAgent =>
      _track == _StudyTrack.flagship ? _flagshipAgent : _selectedSpecialist;

  List<SubscriptionOffer> get _activeOffers => _track == _StudyTrack.flagship
      ? ProductPricing.tahawwulat
      : ProductPricing.specialists;

  int get _activeTierIndex =>
      _track == _StudyTrack.flagship ? _tahawwulatIndex : _specialistIndex;

  SubscriptionOffer get _activeOffer => _activeOffers[_activeTierIndex];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    final agent = args is Map ? args['agent'] : null;
    if (agent is AgentModel) {
      if (agent.id.startsWith('fiqh_tahawwulat')) {
        _track = _StudyTrack.flagship;
      } else if (_specialists.any((a) => a.id == agent.id)) {
        _track = _StudyTrack.specialist;
        _selectedAgentId = agent.id;
      }
    }
  }

  void _selectTrack(_StudyTrack next) {
    if (_processing || _track == next) return;
    OTMotion.selection();
    setState(() {
      _track = next;
      _checkoutError = null;
    });
  }

  void _selectTier(int index) {
    if (_processing) return;
    OTMotion.selection();
    setState(() {
      if (_track == _StudyTrack.flagship) {
        _tahawwulatIndex = index;
      } else {
        _specialistIndex = index;
      }
      _checkoutError = null;
    });
  }

  String _checkoutErrorMessage(FirebaseFunctionsException error) {
    switch (error.code.toLowerCase()) {
      case 'unauthenticated':
        return Loc.tr('checkoutAuthExpired');
      case 'deadline-exceeded':
      case 'unavailable':
        return Loc.tr('checkoutServiceUnavailable');
      case 'failed-precondition':
        return Loc.tr('checkoutPlanUnavailable');
      case 'permission-denied':
        return Loc.tr('checkoutAccountDenied');
      case 'invalid-argument':
        return Loc.tr('checkoutSelectionInvalid');
      default:
        return Loc.tr('checkoutError');
    }
  }

  Future<void> _checkout(AgentModel agent, SubscriptionOffer offer) async {
    if (_processing) return;
    final user = AuthService().currentUser;
    if (user == null || user.isAnonymous) {
      setState(() => _checkoutError = Loc.tr('signInRequired'));
      return;
    }
    setState(() {
      _processing = true;
      _checkoutError = null;
    });
    try {
      final title = '${agent.title} · ${offer.title}';
      final result = await _service.createPayment(
        uid: user.uid,
        agentId: agent.id,
        plan: offer.plan,
        planTitle: title,
        amount: offer.amount,
        name: user.displayName ??
            user.email?.split('@').first ??
            AppCopy.ahlanDefault,
        email: user.email ?? '',
        phone: user.phoneNumber ?? '',
      );
      if (!mounted) return;
      if (result['amount'] != offer.amount ||
          result['pricingRevision'] != ProductPricing.revision) {
        setState(() => _checkoutError = Loc.tr('priceChanged'));
        return;
      }
      final paymentUrl = result['redirectUrl'];
      final invoice = result['invoiceNumber'];
      if (paymentUrl is! String ||
          Uri.tryParse(paymentUrl)?.scheme != 'https' ||
          invoice is! String ||
          invoice.isEmpty) {
        throw const FormatException('Invalid checkout response');
      }
      final paid = await PaymentCheckoutSheet.show(
        context,
        paymentUrl: paymentUrl,
        invoiceNumber: invoice,
        trxId: result['trxId'] as String?,
        planTitle: title,
        amount: offer.amount,
        regularAmount: offer.regularAmount,
        periodLabel: offer.period,
      );
      if (mounted && paid == true) {
        await PaymentSuccessDialog.show(
          context,
          plan: title,
          invoice: invoice,
          amount: offer.amount,
        );
      }
    } on FirebaseFunctionsException catch (error, stack) {
      TelemetryService.instance.reportError(error, stack, context: 'checkout');
      if (mounted) {
        setState(() => _checkoutError = _checkoutErrorMessage(error));
      }
    } on FormatException {
      if (mounted) {
        setState(() => _checkoutError = Loc.tr('checkoutLinkUnavailable'));
      }
    } catch (error, stack) {
      TelemetryService.instance.reportError(error, stack, context: 'checkout');
      if (mounted) setState(() => _checkoutError = Loc.tr('checkoutError'));
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  void _showDisciplinePickerModal(
      BuildContext context, List<AgentModel> specialists) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = OTColors.textPrimary(dark);
    final muted = OTColors.textSecondary(dark);
    final border = OTColors.border(dark);
    final surface = OTColors.surface(dark);

    showAdaptiveSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(OTRadius.dialog)),
      ),
      builder: (ctx) {
        var query = '';
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final filtered = query.isEmpty
                ? specialists
                : specialists.where((a) {
                    final q = query.toLowerCase();
                    return a.title.toLowerCase().contains(q) ||
                        a.titleArabic.contains(q) ||
                        (a.referenceBooks?.any((b) =>
                                b.title.toLowerCase().contains(q) ||
                                b.titleArabic.contains(q)) ??
                            false);
                  }).toList();

            return DraggableScrollableSheet(
              initialChildSize: AppPlatform.isDesktop ? 1 : 0.78,
              minChildSize: AppPlatform.isDesktop ? 1 : 0.5,
              maxChildSize: AppPlatform.isDesktop ? 1 : 0.94,
              expand: false,
              builder: (_, scrollController) {
                return Column(
                  children: [
                    if (AppPlatform.isDesktop)
                      const SizedBox(height: 8)
                    else
                      const SheetGrabber(top: 10, bottom: 10),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                Loc.tr('chooseField'),
                                style: OTTypography.cardTitle(color: ink),
                              ),
                              IconButton(
                                icon: Icon(Icons.close_rounded, color: muted),
                                onPressed: () => Navigator.pop(modalCtx),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            autofocus: false,
                            onChanged: (val) =>
                                setModalState(() => query = val),
                            decoration: InputDecoration(
                              hintText: Loc.tr('searchFieldHint'),
                              prefixIcon: Icon(Icons.search_rounded,
                                  size: 20, color: muted),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) =>
                            Divider(height: 1, color: border),
                        itemBuilder: (_, i) {
                          final a = filtered[i];
                          final isSelected = a.id == _selectedAgentId;
                          return InkWell(
                            onTap: () {
                              OTMotion.selection();
                              setState(() {
                                _selectedAgentId = a.id;
                                _track = _StudyTrack.specialist;
                              });
                              Navigator.pop(modalCtx);
                            },
                            borderRadius: BorderRadius.circular(OTRadius.xs),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 14),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          Loc.text(a.title),
                                          style:
                                              OTTypography.bodyMedium(color: ink)
                                                  .copyWith(
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                          ),
                                        ),
                                        if (a.subtitleAcademic.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            a.subtitleAcademic,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: OTTypography.caption(
                                                color: muted),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  if (!Loc.isArabic &&
                                      a.titleArabic.isNotEmpty) ...[
                                    Text(
                                      ArabicUiLabels.forAgent(
                                          a.id, a.titleArabic),
                                      textDirection: TextDirection.rtl,
                                      style: OTTypography.arabicQuote(
                                          color: muted, height: 1.2),
                                    ),
                                    const SizedBox(width: 12),
                                  ],
                                  Icon(
                                    isSelected
                                        ? Icons.radio_button_checked_rounded
                                        : Icons.radio_button_off_rounded,
                                    color: isSelected ? ink : muted,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final canvas = OTColors.canvas(dark);
    final surface = OTColors.surface(dark);
    final ink = OTColors.textPrimary(dark);
    final muted = OTColors.textSecondary(dark);
    final border = OTColors.border(dark);

    final activeAgent = _activeAgent;
    final activeOffer = _activeOffer;
    final estimatedExpiry = HijriDateUtils.addCalendarMonthsClamped(
      DateTime.now(),
      activeOffer.months,
    );

    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        titleSpacing: otTitleSpacing(context),
        title: Text(AppCopy.subscription),
        backgroundColor: canvas,
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: TextButton.icon(
              onPressed:
                  _processing ? null : () => RedeemCodeSheet.show(context),
              style: OTButtons.quiet(dark),
              icon: const Icon(Icons.confirmation_number_outlined, size: 18),
              label: Text(Loc.tr('redeemAccess')),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, viewport) {
            final wide = viewport.maxWidth >= 960;

            final passPreview = _ScholarlyPassPreview(
              track: _track,
              agent: activeAgent,
              offer: activeOffer,
              estimatedExpiry: estimatedExpiry,
              onChangeSpecialist: _track == _StudyTrack.specialist
                  ? () => _showDisciplinePickerModal(context, _specialists)
                  : null,
            );

            final configurationLedger = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TrackSwitcher(
                  selected: _track,
                  specialistTitle: Loc.text(_selectedSpecialist.title),
                  onSelect: _selectTrack,
                ),
                const SizedBox(height: OTSpacing.base),
                AnimatedSwitcher(
                  duration: OTMotion.normal,
                  switchInCurve: OTMotion.curve,
                  child: _track == _StudyTrack.flagship
                      ? _FlagshipRoomsIndex(
                          key: const ValueKey('flagship-index'),
                          subAgents: _flagshipAgent.subAgents ??
                              const <SubAgentModel>[],
                        )
                      : _SpecialistCatalogSelector(
                          key: const ValueKey('specialist-selector'),
                          selected: _selectedSpecialist,
                          onTap: _processing
                              ? null
                              : () => _showDisciplinePickerModal(
                                    context,
                                    _specialists,
                                  ),
                        ),
                ),
                const SizedBox(height: OTSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppCopy.chooseProPlan.toUpperCase(),
                      style: OTTypography.sectionHeading(color: muted),
                    ),
                    Text(
                      Loc.tr('launchOffer'),
                      style: OTTypography.captionMedium(color: ink),
                    ),
                  ],
                ),
                const SizedBox(height: OTSpacing.sm),
                _EditorialTierLedger(
                  offers: _activeOffers,
                  selectedIndex: _activeTierIndex,
                  onSelect: _selectTier,
                ),
                const SizedBox(height: OTSpacing.base),
                Container(
                  padding: const EdgeInsets.all(OTSpacing.base),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: OTRadius.cardBorder,
                    border: Border.all(color: border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _GuaranteeRow(
                        icon: Icons.verified_outlined,
                        text: _track == _StudyTrack.flagship
                            ? Loc.tr('planFeaturedBenefit1')
                            : Loc.tr('planSingleBenefit1',
                                [Loc.text(activeAgent.title)]),
                        ink: ink,
                      ),
                      const SizedBox(height: OTSpacing.sm),
                      _GuaranteeRow(
                        icon: Icons.menu_book_outlined,
                        text: _track == _StudyTrack.flagship
                            ? Loc.tr('planFeaturedBenefit4')
                            : Loc.tr('planSingleBenefit3'),
                        ink: ink,
                      ),
                      const SizedBox(height: OTSpacing.sm),
                      _GuaranteeRow(
                        icon: Icons.lock_outline_rounded,
                        text: AppCopy.manualRenewalNotice,
                        ink: muted,
                      ),
                    ],
                  ),
                ),
                if (_checkoutError != null) ...[
                  const SizedBox(height: OTSpacing.md),
                  _CheckoutErrorBanner(message: _checkoutError!),
                ],
              ],
            );

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      wide ? OTSpacing.xxl : OTSpacing.lg,
                      OTSpacing.sm,
                      wide ? OTSpacing.xxl : OTSpacing.lg,
                      OTSpacing.xxl,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(maxWidth: wide ? 1080 : 620),
                        child: wide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: OTReveal(child: passPreview),
                                  ),
                                  const SizedBox(width: OTSpacing.xl),
                                  Expanded(
                                    flex: 6,
                                    child: OTReveal(
                                      index: 1,
                                      child: configurationLedger,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  OTReveal(child: passPreview),
                                  const SizedBox(height: OTSpacing.lg),
                                  OTReveal(
                                    index: 1,
                                    child: configurationLedger,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
                _AnchoredCheckoutDock(
                  agentTitle: Loc.text(activeAgent.title),
                  offer: activeOffer,
                  processing: _processing,
                  onCheckout: () => _checkout(activeAgent, activeOffer),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ScholarlyPassPreview extends StatelessWidget {
  const _ScholarlyPassPreview({
    required this.track,
    required this.agent,
    required this.offer,
    required this.estimatedExpiry,
    this.onChangeSpecialist,
  });

  final _StudyTrack track;
  final AgentModel agent;
  final SubscriptionOffer offer;
  final DateTime estimatedExpiry;
  final VoidCallback? onChangeSpecialist;

  @override
  Widget build(BuildContext context) {
    const ink = OTExpressive.white;
    const muted = OTExpressive.whiteMuted;
    final watermark = ArabicUiLabels.forAgent(agent.id, agent.titleArabic);
    final isFlagship = track == _StudyTrack.flagship;

    return OTInkCard(
      watermark: watermark,
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: CustomPaint(painter: _PassArchWatermarkPainter()),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(OTSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: OTSpacing.md,
                        vertical: OTSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: isFlagship ? ink : ink.withValues(alpha: 0.12),
                        borderRadius: OTRadius.chipBorder,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isFlagship
                                ? Icons.workspace_premium_rounded
                                : Icons.auto_stories_outlined,
                            size: 14,
                            color: isFlagship ? OTExpressive.black : ink,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isFlagship
                                ? Loc.tr('planFeaturedLabel')
                                : Loc.tr('planSingleLabel'),
                            style: OTTypography.metadataTag(
                              color: isFlagship ? OTExpressive.black : ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'بطاقة الانتساب',
                      textDirection: TextDirection.rtl,
                      style: OTTypography.arabicQuote(
                        color: muted,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: OTSpacing.xl),
                Text(
                  isFlagship ? AppCopy.planTahawwulat : Loc.text(agent.title),
                  style: OTTypography.editorialHero(color: ink),
                ),
                const SizedBox(height: OTSpacing.xs),
                Text(
                  isFlagship
                      ? Loc.tr('planFeaturedDescription')
                      : agent.subtitleAcademic,
                  style: OTTypography.body(color: muted),
                ),
                if (onChangeSpecialist != null) ...[
                  const SizedBox(height: OTSpacing.md),
                  OutlinedButton.icon(
                    onPressed: onChangeSpecialist,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ink,
                      side: BorderSide(color: ink.withValues(alpha: 0.28)),
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(
                        horizontal: OTSpacing.md,
                      ),
                    ),
                    icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                    label: Text(
                      Loc.tr('chooseField'),
                      style: OTTypography.captionMedium(color: ink),
                    ),
                  ),
                ],
                const SizedBox(height: OTSpacing.xl),
                Divider(height: 1, color: ink.withValues(alpha: 0.14)),
                const SizedBox(height: OTSpacing.base),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Loc.tr('accessTermLabel').toUpperCase(),
                            style: OTTypography.metadataTag(color: muted),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${offer.title} · ${AppCopy.validUntil} ${HijriDateUtils.formatMasehiOnly(estimatedExpiry)}',
                            style: OTTypography.captionMedium(color: ink),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            HijriDateUtils.formatHijriOnly(estimatedExpiry),
                            style: OTTypography.caption(color: muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: OTSpacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (offer.regularAmount > offer.amount)
                          Text(
                            ProductPricing.rupiah(offer.regularAmount),
                            textDirection: TextDirection.ltr,
                            style: OTTypography.caption(color: muted).copyWith(
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        Text(
                          offer.priceLabel,
                          textDirection: TextDirection.ltr,
                          style: OTTypography.price(color: ink).copyWith(
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PassArchWatermarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final archRect = Rect.fromCenter(
      center: Offset(size.width * 0.82, size.height * 0.58),
      width: size.height * 0.72,
      height: size.height * 0.95,
    );
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = OTExpressive.white.withValues(alpha: 0.08);
    canvas.drawPath(otArchPath(archRect, open: true), stroke);

    final innerRect = archRect.deflate(14);
    canvas.drawPath(
      otArchPath(innerRect, open: true),
      stroke..color = OTExpressive.white.withValues(alpha: 0.04),
    );
  }

  @override
  bool shouldRepaint(covariant _PassArchWatermarkPainter oldDelegate) => false;
}

class _TrackSwitcher extends StatelessWidget {
  const _TrackSwitcher({
    required this.selected,
    required this.specialistTitle,
    required this.onSelect,
  });

  final _StudyTrack selected;
  final String specialistTitle;
  final ValueChanged<_StudyTrack> onSelect;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = OTColors.surface(dark);
    final subtle = OTColors.surfaceSubtle(dark);
    final ink = OTColors.textPrimary(dark);
    final muted = OTColors.textSecondary(dark);
    final border = OTColors.border(dark);

    Widget tab({
      required _StudyTrack track,
      required String badge,
      required String title,
      required IconData icon,
    }) {
      final active = selected == track;
      return Expanded(
        child: Semantics(
          button: true,
          selected: active,
          child: InkWell(
            onTap: () => onSelect(track),
            borderRadius: BorderRadius.circular(OTRadius.card),
            child: AnimatedContainer(
              duration: OTMotion.fast,
              curve: OTMotion.curve,
              padding: const EdgeInsets.all(OTSpacing.base),
              decoration: BoxDecoration(
                color: active ? surface : Colors.transparent,
                borderRadius: BorderRadius.circular(OTRadius.card),
                border: Border.all(
                  color:
                      active ? OTColors.borderStrong(dark) : Colors.transparent,
                  width: active ? 1.2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 16, color: active ? ink : muted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          badge.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: OTTypography.metadataTag(
                            color: active ? ink : muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: OTTypography.cardTitle(
                      color: active ? ink : muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(OTSpacing.xs),
      decoration: BoxDecoration(
        color: subtle,
        borderRadius: BorderRadius.circular(OTRadius.card),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          tab(
            track: _StudyTrack.flagship,
            badge: Loc.tr('planExclusive'),
            title: AppCopy.planTahawwulat,
            icon: Icons.workspace_premium_outlined,
          ),
          const SizedBox(width: OTSpacing.xs),
          tab(
            track: _StudyTrack.specialist,
            badge: Loc.tr('planSingleLabel'),
            title: specialistTitle,
            icon: Icons.menu_book_outlined,
          ),
        ],
      ),
    );
  }
}

class _FlagshipRoomsIndex extends StatelessWidget {
  const _FlagshipRoomsIndex({super.key, required this.subAgents});

  final List<SubAgentModel> subAgents;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = OTColors.surface(dark);
    final ink = OTColors.textPrimary(dark);
    final muted = OTColors.textSecondary(dark);
    final border = OTColors.border(dark);
    final subtle = OTColors.surfaceSubtle(dark);

    return Container(
      padding: const EdgeInsets.all(OTSpacing.base),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: OTRadius.cardBorder,
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Loc.tr('planFeaturedIncludes', ['${subAgents.length}'])
                    .toUpperCase(),
                style: OTTypography.sectionHeading(color: muted),
              ),
              Text(
                '٥ مجالس علمية',
                textDirection: TextDirection.rtl,
                style: OTTypography.caption(color: muted),
              ),
            ],
          ),
          const SizedBox(height: OTSpacing.md),
          for (var i = 0; i < subAgents.length; i++) ...[
            if (i > 0) Divider(height: 16, color: OTColors.borderSubtle(dark)),
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: subtle,
                    borderRadius: BorderRadius.circular(OTRadius.xs),
                  ),
                  child: Text(
                    '0${i + 1}',
                    style: ScholarlyFonts.jetBrainsMono(
                      fontSize: OTFontSize.s11,
                      fontWeight: FontWeight.w600,
                      color: muted,
                    ),
                  ),
                ),
                const SizedBox(width: OTSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subAgents[i].name,
                        style: OTTypography.bodyMedium(color: ink),
                      ),
                      Text(
                        subAgents[i].description,
                        style: OTTypography.caption(color: muted),
                      ),
                    ],
                  ),
                ),
                if (!Loc.isArabic && subAgents[i].nameArabic.isNotEmpty)
                  Text(
                    subAgents[i].nameArabic,
                    textDirection: TextDirection.rtl,
                    style: OTTypography.arabicQuote(color: muted, height: 1.2),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SpecialistCatalogSelector extends StatelessWidget {
  const _SpecialistCatalogSelector({
    super.key,
    required this.selected,
    required this.onTap,
  });

  final AgentModel selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = OTColors.surface(dark);
    final subtle = OTColors.surfaceSubtle(dark);
    final ink = OTColors.textPrimary(dark);
    final muted = OTColors.textSecondary(dark);
    final border = OTColors.borderStrong(dark);

    return Material(
      color: surface,
      borderRadius: OTRadius.cardBorder,
      child: InkWell(
        onTap: onTap,
        borderRadius: OTRadius.cardBorder,
        child: Container(
          padding: const EdgeInsets.all(OTSpacing.base),
          decoration: BoxDecoration(
            borderRadius: OTRadius.cardBorder,
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: subtle,
                  borderRadius: BorderRadius.circular(OTRadius.xs),
                ),
                child: Icon(Icons.auto_stories_outlined, color: ink, size: 20),
              ),
              const SizedBox(width: OTSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Loc.tr('chooseField').toUpperCase(),
                      style: OTTypography.metadataTag(color: muted),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Loc.text(selected.title),
                      style: OTTypography.cardTitle(color: ink),
                    ),
                    if (selected.subtitleAcademic.isNotEmpty)
                      Text(
                        selected.subtitleAcademic,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: OTTypography.caption(color: muted),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: OTSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: OTSpacing.md,
                  vertical: OTSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: subtle,
                  borderRadius: OTRadius.chipBorder,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      Loc.tr('chooseFieldPlan'),
                      style: OTTypography.captionMedium(color: ink),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.unfold_more_rounded, size: 16, color: ink),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditorialTierLedger extends StatelessWidget {
  const _EditorialTierLedger({
    required this.offers,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<SubscriptionOffer> offers;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = OTColors.surface(dark);
    final subtle = OTColors.surfaceSubtle(dark);
    final ink = OTColors.textPrimary(dark);
    final muted = OTColors.textSecondary(dark);
    final border = OTColors.border(dark);
    final strongBorder = OTColors.borderStrong(dark);

    return Column(
      children: [
        for (var i = 0; i < offers.length; i++) ...[
          if (i > 0) const SizedBox(height: OTSpacing.sm),
          Builder(
            builder: (context) {
              final offer = offers[i];
              final active = i == selectedIndex;
              final isBestValue = offer.months == 12;
              final monthlyEq = (offer.amount / offer.months).round();

              return Semantics(
                button: true,
                selected: active,
                child: Material(
                  color: active ? surface : subtle.withValues(alpha: 0.55),
                  borderRadius: OTRadius.cardBorder,
                  child: InkWell(
                    onTap: () => onSelect(i),
                    borderRadius: OTRadius.cardBorder,
                    child: AnimatedContainer(
                      duration: OTMotion.fast,
                      curve: OTMotion.curve,
                      padding: const EdgeInsets.symmetric(
                        horizontal: OTSpacing.base,
                        vertical: OTSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: OTRadius.cardBorder,
                        border: Border.all(
                          color:
                              active ? ink : (isBestValue ? strongBorder : border),
                          width: active ? 1.6 : 0.9,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            active
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_off_rounded,
                            size: 20,
                            color: active ? ink : muted,
                          ),
                          const SizedBox(width: OTSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      offer.title,
                                      style: OTTypography.cardTitle(color: ink),
                                    ),
                                    if (isBestValue)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: ink,
                                          borderRadius: OTRadius.chipBorder,
                                        ),
                                        child: Text(
                                          Loc.tr('bestValue').toUpperCase(),
                                          style: OTTypography.metadataTag(
                                            color: OTColors.onAccent(dark),
                                          ),
                                        ),
                                      )
                                    else if (offer.savingsPercent > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: subtle,
                                          borderRadius: OTRadius.chipBorder,
                                          border: Border.all(color: border),
                                        ),
                                        child: Text(
                                          Loc.tr('saving',
                                              ['${offer.savingsPercent}']),
                                          style: OTTypography.metadataTag(
                                              color: muted),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  offer.months > 1
                                      ? Loc.tr('monthlyEquivalent',
                                          [ProductPricing.rupiah(monthlyEq)])
                                      : Loc.tr('planTrustNote'),
                                  style: OTTypography.caption(color: muted),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: OTSpacing.sm),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (offer.regularAmount > offer.amount)
                                Text(
                                  ProductPricing.rupiah(offer.regularAmount),
                                  textDirection: TextDirection.ltr,
                                  style: OTTypography.caption(color: muted)
                                      .copyWith(
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              Text(
                                offer.priceLabel,
                                textDirection: TextDirection.ltr,
                                style: OTTypography.screenTitle(color: ink)
                                    .copyWith(
                                  fontFeatures: const [
                                    FontFeature.tabularFigures()
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}

class _GuaranteeRow extends StatelessWidget {
  const _GuaranteeRow({
    required this.icon,
    required this.text,
    required this.ink,
  });

  final IconData icon;
  final String text;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 16, color: ink),
        ),
        const SizedBox(width: OTSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: OTTypography.body(color: ink),
          ),
        ),
      ],
    );
  }
}

class _CheckoutErrorBanner extends StatelessWidget {
  const _CheckoutErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final color = OTColors.destructive(dark);
    return Container(
      padding: const EdgeInsets.all(OTSpacing.md),
      decoration: BoxDecoration(
        color: OTColors.errorContainer(dark),
        borderRadius: OTRadius.cardBorder,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: color),
          const SizedBox(width: OTSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: OTTypography.caption(color: OTColors.textPrimary(dark)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnchoredCheckoutDock extends StatelessWidget {
  const _AnchoredCheckoutDock({
    required this.agentTitle,
    required this.offer,
    required this.processing,
    required this.onCheckout,
  });

  final String agentTitle;
  final SubscriptionOffer offer;
  final bool processing;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = OTColors.surface(dark);
    final border = OTColors.border(dark);
    final ink = OTColors.textPrimary(dark);
    final muted = OTColors.textSecondary(dark);

    return Container(
      padding: const EdgeInsets.fromLTRB(
        OTSpacing.lg,
        OTSpacing.md,
        OTSpacing.lg,
        OTSpacing.base,
      ),
      decoration: BoxDecoration(
        color: surface,
        border: Border(top: BorderSide(color: border)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$agentTitle · ${offer.title}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: OTTypography.bodyMedium(color: ink),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Loc.tr('planTrustNote'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: OTTypography.caption(color: muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: OTSpacing.base),
              FilledButton.icon(
                onPressed: processing
                    ? null
                    : () {
                        HapticFeedback.mediumImpact();
                        onCheckout();
                      },
                icon: processing
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: AppLoader(
                          dotSize: 5,
                          spacing: 2,
                          color: OTColors.onAccent(dark),
                        ),
                      )
                    : const Icon(Icons.arrow_forward_rounded, size: 18),
                label: Text(
                  Loc.tr('payAmount', [offer.priceLabel]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## 4. Pilar 3 — Kestabilan DOM Injection & Manajemen Memori macOS 8GB RAM

### 4.1 Perbaikan `lib/core/notebook_ui_script.dart`
1. **Proteksi Chip Sitasi Kitab (`L223–226`)**:
   Ganti selector `[class*="chip" i]` dengan selector yang hanya menyasar chip saran prompt di luar artikel jawaban AI:
   ```css
   /* Sembunyikan chip saran prompt di luar balon jawaban agar sitasi kitab tetap utuh */
   button[class*="suggestion" i]:not([role="article"] *),
   [class*="prompt-chip" i]:not([role="article"] *),
   app-suggested-actions, .suggested-actions, [class*="suggested-actions" i],
   app-suggestion-chips, .suggestion-chips, [class*="prompt-chips" i], [class*="prompt-card" i],
   ```
2. **Penghapusan Reflow Thrashing & Penambahan Mode `otSetSuspended` (`L809–824` & `L883–912`)**:
   Hilangkan pemanggilan `[branch, ...branch.querySelectorAll('*')].filter(el => ... getComputedStyle(el).overflowY)` pada setiap frame dan tambahkan dukungan pembekuan observer ketika tab berada di latar belakang:
   ```javascript
   messageBranches.forEach(branch => {
     const scroller = branch.matches('.message-list, [role="log"]')
       ? branch
       : (branch.querySelector('.message-list, [role="log"], .chat-panel-content, .conversation-container') || branch);
     transcripts.add(scroller);
     let wrapper = scroller.parentElement;
     while (wrapper && wrapper !== node) {
       transcriptPaths.add(wrapper);
       wrapper = wrapper.parentElement;
     }
   });
   ```
   ```javascript
   let layoutTimer = 0;
   let isSuspended = false;
   function scheduleConversationLayout() {
     if (isSuspended || layoutTimer) return;
     layoutTimer = setTimeout(() => {
       layoutTimer = 0;
       requestAnimationFrame(anchorConversationInput);
     }, 180);
   }
   window.addEventListener('resize', scheduleConversationLayout);
   window.visualViewport?.addEventListener('resize', scheduleConversationLayout);
   const composerObserver = new MutationObserver(scheduleConversationLayout);
   function observeDom() {
     composerObserver.observe(document.documentElement, {
       subtree: true, childList: true, attributes: true, attributeFilter: ['disabled', 'aria-disabled']
     });
     observer.observe(document.body || document.documentElement, {subtree: true, childList: true});
   }
   window.otSetSuspended = function(suspended) {
     isSuspended = !!suspended;
     if (isSuspended) {
       composerObserver.disconnect();
       observer.disconnect();
       if (layoutTimer) { clearTimeout(layoutTimer); layoutTimer = 0; }
     } else {
       observeDom();
       clean();
     }
   };
   ```

### 4.2 Perbaikan `lib/services/agent_session_manager.dart` (Destruksi Aman `WKWebView` & Batas Tab macOS)
1. **Batasi `maxTabs = 2` di macOS (`L71`)**:
   ```dart
   static int get maxTabs =>
       (!kIsWeb && defaultTargetPlatform == TargetPlatform.macOS) ? 2 : 3;
   ```
2. **Paksa `about:blank` Sebelum `disposeKeepAlive` (`L39–61`)**:
   ```dart
   Future<void> disposeWebResources() async {
     final controller = webController;
     webController = null;
     isSessionReady = false;
     isWebLoading = false;
     hasInjectedEarlyScript = false;

     if (controller != null) {
       try {
         await controller.stopLoading();
         await controller.evaluateJavascript(
           source: 'if (window.otSetSuspended) window.otSetSuspended(true);',
         );
         controller.removeJavaScriptHandler(handlerName: 'otCopiedAnswer');
         controller.removeJavaScriptHandler(handlerName: 'otAnswerState');
         controller.removeJavaScriptHandler(handlerName: 'otAnswerChunk');
         controller.removeJavaScriptHandler(handlerName: 'otDismissMenu');
         await controller.loadUrl(
           urlRequest: URLRequest(url: WebUri('about:blank')),
         );
       } catch (_) {}

       SchedulerBinding.instance.addPostFrameCallback((_) async {
         try {
           await InAppWebViewController.disposeKeepAlive(keepAlive);
         } catch (_) {}
       });
       SchedulerBinding.instance.scheduleFrame();
     }
   }
   ```

## 5. Pilar 4 — Keamanan Hak Akses VIP Mutlak & Isolasi Modul (Zero Leakage)

### 5.1 Perbaikan Backend `functions/src/index.ts`
1. **Isolasi `getEntitlementAccess()` (`L143–184`)**:
   Tolak akses jika `specific?.status === "revoked"`, dan batasi fallback plan tingkat-akun hanya untuk `all_access`/`sultan`/`full` atau akun warisan yang belum memiliki map `entitlements`:
   ```typescript
   function getEntitlementAccess(
     userData: FirebaseFirestore.DocumentData,
     entitlementKey: string
   ): { premiumPlan: boolean; active: boolean } {
     if (isVip(userData)) return { premiumPlan: true, active: true };
     if (userData.account_deleted === true) return { premiumPlan: false, active: false };

     const entitlements =
       userData.entitlements && typeof userData.entitlements === "object"
         ? (userData.entitlements as Record<string, any>)
         : {};
     const now = Date.now();
     const active = (ent: any): boolean => {
       if (!ent || typeof ent.plan !== "string") return false;
       if (ent.status === "revoked" || ent.status === "expired") return false;
       const allowed =
         /^(trial|tholib(?:_1m|_6m)?|bahits(?:_1y)?|premium|all_access|all_ai.*|single|sultan|pro|voucher(?:_.*)?|redeem(?:_.*)?|custom|full)$/.test(
           ent.plan
         );
       const expiry = ent.expiry?.toDate
         ? ent.expiry.toDate()
         : ent.expiry?._seconds
         ? new Date(ent.expiry._seconds * 1000)
         : new Date(ent.expiry ?? "");
       return allowed && Number.isFinite(expiry.getTime()) && expiry.getTime() > now;
     };

     const specific = entitlements[entitlementKey];
     if (specific?.status === "revoked") {
       return { premiumPlan: true, active: false };
     }
     if (active(specific)) return { premiumPlan: true, active: true };

     const all = entitlements.all_access ?? entitlements.all_ai;
     if (all?.status === "revoked") {
       return { premiumPlan: true, active: false };
     }
     if (active(all)) return { premiumPlan: true, active: true };

     const expiry = userData.subscription_expiry?.toDate
       ? userData.subscription_expiry.toDate()
       : new Date(userData.subscription_expiry ?? "");
     const isGlobalExpiryValid = Number.isFinite(expiry.getTime()) && expiry.getTime() > now;

     const trueGlobalPattern = /^(all_access|all_ai.*|full|sultan)$/;
     const legacySingleOrGlobalPattern =
       /^(tholib.*|bahits.*|premium|pro|custom|voucher.*|redeem.*)$/;
     const hasModularEntitlements = Object.keys(entitlements).length > 0;

     if (typeof userData.plan === "string") {
       if (trueGlobalPattern.test(userData.plan)) {
         return { premiumPlan: true, active: isGlobalExpiryValid };
       }
       if (!hasModularEntitlements && legacySingleOrGlobalPattern.test(userData.plan)) {
         return { premiumPlan: true, active: isGlobalExpiryValid };
       }
     }

     return { premiumPlan: Boolean(specific || all), active: false };
   }
   ```
2. **Perbaikan `dailyRevoke` Phase 1 (`L1928–1930`) & Phase 2 (`L2010–2022`)**:
   - Di Phase 1, periksa `access_vip_registry` sebelum menandai entitlement sebagai `expired`.
   - Di Phase 2, hapus variabel `isYearly` dari kondisi `allActiveEmails.add(email)` agar pembeli paket 1 tahun untuk 1 modul tunggal (`bahits_1y`) tidak dikecualikan dari pencabutan modul lain yang sudah kedaluwarsa.
3. **Pencegahan *Compounding Loop* pada `applyAkalPurchase()` (`L2383–2390`)**:
   Sebelum menambahkan durasi di atas `g.expires_ms`, periksa apakah sudah ada grant pembayaran untuk `scope` yang sama dengan `Math.abs((g.paid_ms ?? g.starts_ms ?? 0) - paidMs) < 60000 && Number(g.amount) === p.amount`. Jika ada, kembalikan `duplicateGrant.expires_ms` secara idempoten.

### 5.2 Perbaikan Client `lib/models/user_model.dart`
1. **Hapus `cleanPlan.contains(cleanKey)` (`L198–206`)**:
   Gunakan pencocokan eksak `if (cleanPlan == cleanKey || cleanPlan.startsWith('${cleanKey}_')) return true;` agar langganan `fiqh_syafii` tidak bocor membuka modul `fiqh` (`fatawa_masail`).
2. **Sertakan `_canonicalVipEmails` di `UserModel.fromMap` (`L269–272`)**:
   Pastikan seluruh email dalam `VIP_EMAILS` langsung dikenali sebagai `isVip = true` di sisi Flutter meskipun field `is_vip` pada dokumen Firestore belum terproyeksi oleh worker.

## 6. Urutan Eksekusi Implementasi (Rollout Plan & QA Checklist)

| Fase | Lingkup Pekerjaan | Risiko Regresi | Langkah Verifikasi (QA Gate) |
| :--- | :--- | :--- | :--- |
| **Fase 1: Sesi & Cookie Vault** | Buat `persistent_google_session.dart`, perbarui `auth_service.dart`, `splash_screen.dart`, `login_screen.dart`, dan `google_session_auth_screen.dart`. | Sangat Rendah | 1. Login dengan akun Google baru.<br>2. Buka salah satu asisten AI hingga siap.<br>3. Tutup paksa aplikasi di macOS (`Cmd+Q`) dan buka kembali: pastikan langsung masuk ke Beranda dan ruang AI terbuka **tanpa minta login ulang**.<br>4. Tekan tombol **Keluar (Log Out)** dan pastikan brankas cookie bersih. |
| **Fase 2: Redesign UI Pembayaran** | Ganti `subscription_screen.dart`, `payment_checkout_sheet.dart`, dan `payment_success_dialog.dart`. | Rendah | 1. Buka halaman Langganan di mode Terang & Gelap serta bahasa ID, EN, AR (RTL).<br>2. Uji pergantian tab *Koleksi Khusus (5 AI)* dan *Satu Bidang Ilmu*.<br>3. Buat sesi checkout Midtrans, pastikan slip arsip tampil rapi, dan uji penukaran kode voucher. |
| **Fase 3: Keamanan VIP & Backend** | Deploy patch `getEntitlementAccess`, `dailyRevoke`, dan `applyAkalPurchase` di `functions/src/index.ts` serta `user_model.dart`. | Rendah | 1. Pastikan akun di dalam `VIP_EMAILS` langsung berstatus `VIP` di kartu profil.<br>2. Uji akun dengan `fiqh_syafii` aktif (`bahits_1y`) dan `fiqh_tahawwulat` expired: pastikan `fiqh_tahawwulat` tetap tertutup.<br>3. Panggil `syncAkalPurchases` 2x berturut-turut: pastikan tanggal berakhir tidak bertambah ganda. |
| **Fase 4: Optimasi DOM & RAM macOS** | Terapkan patch `notebook_ui_script.dart`, `agent_session_manager.dart`, dan `agent_multi_tab_room.dart`. | Rendah | 1. Ajukan pertanyaan ke AI dan pastikan chip nomor rujukan kitab (`[1]`, `[2]`) tampil dan bisa diklik.<br>2. Buka 3 asisten berurutan di macOS: pastikan tab ke-3 otomatis menutup tab tertua dan membebaskan RAM melalui `about:blank`. |
| **Fase 5: Cutover Native Chat (Opsional)** | Buka pengunci `testUid` di `native_chat.ts` dan aktifkan `_backendChatPrototype` jika bridge VPS sudah siap. | Sedang | Uji pengiriman pertanyaan melalui `NativeTurathChatView` tanpa `InAppWebView` sama sekali (100% 1x Login murni). |
