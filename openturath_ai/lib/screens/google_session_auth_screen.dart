import '../widgets/login_guidance.dart';
import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../core/app_copy.dart';
import '../core/app_platform.dart';
import '../core/constants.dart';
import '../core/design/ot_colors.dart';
import '../core/google_rejection.dart';
import '../core/google_connection_flow.dart';
import '../core/localization.dart';
import '../core/notebook_navigation.dart';
import '../core/routes.dart';
import '../core/scholarly_fonts.dart';
import '../core/theme.dart';
import '../core/webview_cookie_policy.dart';
import '../services/auth_failure_reporter.dart';
import '../services/auth_service.dart';
import '../services/desktop_webview_runtime.dart';
import '../services/persistent_google_session.dart';
import '../widgets/app_loader.dart';
import '../widgets/diagnostic_report_action.dart';
import '../widgets/openturath_brand.dart';

import 'package:openturath_ai/core/design/ot_typography.dart';
import 'package:openturath_ai/core/design/ot_radius.dart';
import '../core/app_snackbar.dart';

/// Layar Autentikasi Sesi Google (Langkah 2 dari 2)
/// Menghubungkan sesi Google / NotebookLM di WebView secara langsung setelah login Firebase,
/// dengan disclaimer jelas bahwa pengguna wajib masuk dengan akun Google yang sama.
class GoogleSessionAuthScreen extends StatefulWidget {
  const GoogleSessionAuthScreen({
    super.key,
    this.webViewBuilder,
    this.purpose = GoogleConnectionPurpose.appEntry,
    this.authService,
  });

  final GoogleConnectionPurpose purpose;
  final AuthService? authService;

  final Widget Function(
    BuildContext context,
    InAppWebViewSettings settings,
    String initialUrl,
  )? webViewBuilder;

  @override
  State<GoogleSessionAuthScreen> createState() =>
      _GoogleSessionAuthScreenState();
}

class _GoogleSessionAuthScreenState extends State<GoogleSessionAuthScreen> {
  late final AuthService _authService;
  String? _openingUid;

  bool get _isAppEntry => widget.purpose == GoogleConnectionPurpose.appEntry;

  bool get _hasOriginalAppSession {
    if (_isAppEntry) {
      if (_openingUid != null && !_authService.hasAuthenticatedSession) {
        return false;
      }
      final current = _authService.cachedCurrentUser;
      if (current != null &&
          current.uid != _openingUid &&
          !current.uid.startsWith('web_')) {
        return false;
      }
      return true;
    }
    return _openingUid != null &&
        _authService.hasAuthenticatedSession &&
        _authService.cachedCurrentUser?.uid == _openingUid;
  }

  InAppWebViewController? _webController;
  bool _isSessionReady = false;
  bool _isCompletingSession = false;
  bool _isCancelDialogOpen = false;
  bool _connectionCancelled = false;
  bool _verificationFailed = false;
  int _connectionEpoch = 0;
  final ValueNotifier<double> _loadProgress = ValueNotifier<double>(0.0);
  bool _isMismatchDialogOpen = false;
  bool _isShieldActive = false;
  bool _isCheckingAccount = false;
  // Halaman penolakan Google ("Couldn't sign you in") terdeteksi: tawarkan
  // tombol kirim laporan agar pemilik dapat menganalisa penyebabnya.
  bool _googleRejected = false;
  String _lastPage = '';
  bool _isConfirmOpen = false;
  Timer? _watchdog;

  String get _targetLoginUrl {
    final email = (_authService.cachedCurrentUser?.email ??
            _authService.currentUser?.email ??
            '')
        .trim();
    return Uri.https('notebook.google.com', '/login', {
      'continue': 'https://notebook.google.com/',
      if (email.isNotEmpty) 'Email': email,
    }).toString();
  }

  // Try the existing WebKit session before asking Google to sign in again.
  String get _initialSessionUrl => '${NotebookNavigation.canonicalOrigin}/';

  bool _isCurrentVerification(int epoch) =>
      mounted &&
      epoch == _connectionEpoch &&
      _hasOriginalAppSession &&
      !_isCancelDialogOpen &&
      !_connectionCancelled &&
      !_verificationFailed;

  void _showVerificationRecovery() {
    if (!mounted || _isCancelDialogOpen || _connectionCancelled) return;
    setState(() {
      _connectionEpoch++;
      _verificationFailed = true;
      _isShieldActive = false;
      _webController = null;
    });
  }

  void _retryVerification() {
    if (!mounted || _isCancelDialogOpen || _connectionCancelled) return;
    _connectionEpoch++;
    if (_verificationFailed) {
      setState(() => _verificationFailed = false);
    } else {
      _webController?.reload();
    }
  }

  /// Menyelaraskan status pelindung visual (Visual Shield) dengan domain navigasi WebView
  void _handleUrlNavigation(InAppWebViewController controller, WebUri? url) {
    if (!identical(controller.platform, _webController?.platform)) return;
    if (!mounted ||
        url == null ||
        _verificationFailed ||
        _connectionCancelled) {
      return;
    }
    final uri = url.uriValue;
    final host = uri.host.toLowerCase();
    final path = uri.path.toLowerCase();

    final isNotebook = NotebookNavigation.notebook(uri);
    final isMyAccount = GoogleConnectionNavigation.isAccountPage(uri) ||
        (uri.scheme == 'https' &&
            host == 'accounts.google.com' &&
            (path.contains('/b/') ||
                path.contains('/recovery') ||
                path.contains('/speedbump') ||
                path.contains('/accountchooser')));
    final isAuthFlow = NotebookNavigation.signInFlow(uri) && !isMyAccount;

    if (isNotebook || isMyAccount) {
      if (!_isShieldActive && mounted) {
        setState(() => _isShieldActive = true);
      }
      // Suntikkan style pelindung cadangan untuk navigasi SPA sisi-klien agar UI web tidak pernah bocor ke layar pengguna
      controller.evaluateJavascript(source: '''
        try {
          var styleId = 'ot-stealth-auth-cloak';
          var style = document.getElementById(styleId) || document.createElement('style');
          style.id = styleId;
          style.textContent = 'html, body { background-color: #09090B !important; color: transparent !important; overflow: hidden !important; } body * { opacity: 0 !important; pointer-events: none !important; }';
          (document.head || document.documentElement).appendChild(style);
        } catch(_) {}
      ''');
    } else if (isAuthFlow &&
        _isShieldActive &&
        !_isMismatchDialogOpen &&
        !_isConfirmOpen) {
      setState(() => _isShieldActive = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
    if (_authService.hasAuthenticatedSession) {
      _openingUid = _authService.cachedCurrentUser?.uid;
    }
    // Verifikasi tidak boleh bergantung pada peristiwa pemuatan halaman saja: SPA
    // NotebookLM bisa selesai tanpa peristiwa baru, dan satu panggilan JavaScript yang
    // menggantung menahan kunci verifikasi. Penjaga ini memeriksa ulang secara berkala.
    _watchdog =
        Timer.periodic(const Duration(seconds: 3), (_) => _watchdogTick());
  }

  Future<void> _watchdogTick() async {
    final controller = _webController;
    if (!mounted ||
        controller == null ||
        _isSessionReady ||
        _isCompletingSession ||
        _isCancelDialogOpen ||
        _connectionCancelled ||
        _verificationFailed ||
        _isCheckingAccount ||
        _isConfirmOpen ||
        _isMismatchDialogOpen) {
      return;
    }
    try {
      final url = await controller.getUrl().timeout(const Duration(seconds: 3));
      if (!mounted || url == null || _isSessionReady) return;
      if (_isAppEntry || NotebookNavigation.notebook(url.uriValue)) {
        await _checkAccountVerification(controller);
      } else if (_isShieldActive) {
        // Halaman perantara Google di bawah pelindung: tampilkan agar pengguna bisa melanjutkan.
        setState(() => _isShieldActive = false);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _watchdog?.cancel();
    _loadProgress.dispose();
    _webController = null;
    super.dispose();
  }

  /// Mengekstrak alamat email akun Google aktif dari DOM NotebookLM / Google header
  Future<String?> _detectGoogleEmail(InAppWebViewController controller) async {
    try {
      final result = await controller.evaluateJavascript(source: '''
(function() {
  try {
    // 1. Cek tombol profil / avatar di Google One-Google header
    var selectors = [
      'a[aria-label*="@"]',
      'button[aria-label*="@"]',
      'div[aria-label*="@"]',
      'img[alt*="@"]',
      '[aria-label*="Google Account"]',
      '[aria-label*="Akun Google"]',
      '[data-identifier*="@"]'
    ];
    for (var i = 0; i < selectors.length; i++) {
      var els = document.querySelectorAll(selectors[i]);
      for (var j = 0; j < els.length; j++) {
        var str = els[j].getAttribute('aria-label') || 
                  els[j].getAttribute('alt') || 
                  els[j].getAttribute('title') || 
                  els[j].getAttribute('data-identifier') || '';
        var match = str.match(/[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}/);
        if (match) return match[0].toLowerCase();
      }
    }
    // 2. Cek variabel global Google WIZ
    if (window.WIZ_global_data) {
      try {
        var strWiz = JSON.stringify(window.WIZ_global_data);
        var mWiz = strWiz.match(/[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}/);
        if (mWiz) return mWiz[0].toLowerCase();
      } catch(_) {}
      for (var k in window.WIZ_global_data) {
        var val = window.WIZ_global_data[k];
        if (typeof val === 'string' && val.indexOf('@') !== -1) {
          var m = val.match(/[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}/);
          if (m) return m[0].toLowerCase();
        }
      }
    }
    // 3. Cek text di header / navbar
    var header = document.querySelector('header') || document.querySelector('nav');
    if (header) {
      var raw = header.textContent || header.innerText || '';
      var m = raw.match(/[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}/);
      if (m) return m[0].toLowerCase();
    }
    // 4. Cek atribut data-email atau data-profile-email
    var emailAttr = document.querySelector('[data-email], [data-profile-email]');
    if (emailAttr) {
      var val = emailAttr.getAttribute('data-email') || emailAttr.getAttribute('data-profile-email');
      if (val && val.indexOf('@') !== -1) return val.toLowerCase();
    }
    // 5. Cek seluruh teks pada halaman (sangat efektif untuk myaccount.google.com)
    if (document.body) {
      var bodyText = document.body.innerText || '';
      var matches = bodyText.match(/[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}/g);
      if (matches && matches.length > 0) {
        for (var b = 0; b < matches.length; b++) {
          var cand = matches[b].toLowerCase();
          if (cand.indexOf('noreply') === -1 && cand.indexOf('support@') === -1 && cand.indexOf('help@') === -1) {
            return cand;
          }
        }
        return matches[0].toLowerCase();
      }
    }
    return null;
  } catch(e) {
    return null;
  }
})();
''').timeout(const Duration(seconds: 3));
      if (result != null && result is String && result.trim().contains('@')) {
        return result.trim().toLowerCase();
      }
    } catch (_) {}
    return null;
  }

  /// Memverifikasi bahwa sesi di WebView telah selesai dan menggunakan akun yang sama.
  /// Dilengkapi mutex guard dan siklus polling adaptif untuk menjamin keandalan pada koneksi lambat.
  /// Tombol laporan mengikuti halaman yang sedang tampil, jadi hilang lagi
  /// saat pengguna mencoba ulang dan Google tidak lagi menolak.
  Future<void> _detectGoogleRejection(
      InAppWebViewController controller, WebUri url) async {
    _lastPage = url.toString();
    final rejected = await isGoogleRejectionPage(controller, url);
    if (!mounted) return;
    if (rejected) {
      AuthFailureReporter.reportOnce(
          stage: 'login-webview', code: 'google-rejected');
    }
    if (rejected != _googleRejected) {
      setState(() => _googleRejected = rejected);
    }
  }

  Future<void> _checkAccountVerification(
      InAppWebViewController controller) async {
    if (_isAppEntry) {
      await _checkApplicationEntry(controller);
      return;
    }
    if (!identical(controller.platform, _webController?.platform)) return;
    if (!mounted ||
        _isSessionReady ||
        _isCompletingSession ||
        _isCancelDialogOpen ||
        _connectionCancelled ||
        _verificationFailed ||
        _isCheckingAccount) {
      return;
    }
    // Mutex dipasang sebelum `await` pertama. Sebelumnya dipasang sesudah
    // `getUrl()`, sehingga onLoadStop dan onUpdateVisitedHistory yang datang
    // nyaris bersamaan sama-sama lolos dan menjalankan dua siklus polling.
    _isCheckingAccount = true;
    final epoch = _connectionEpoch;
    var inconclusive = false;

    try {
      final currentWebUrl = await controller
          .getUrl()
          .timeout(const Duration(seconds: 5), onTimeout: () => null);
      if (!_isCurrentVerification(epoch)) return;
      if (currentWebUrl == null) {
        _showVerificationRecovery();
        return;
      }
      final urlStr = currentWebUrl.toString();

      // Jangan lakukan verifikasi jika masih di formulir login Google
      if (urlStr.contains('accounts.google') ||
          urlStr.contains('InteractiveLogin') ||
          urlStr.contains('ServiceLogin') ||
          urlStr.contains('signin/v2') ||
          urlStr.contains('identifier') ||
          urlStr.contains('challenge') ||
          !NotebookNavigation.notebook(currentWebUrl.uriValue)) {
        return;
      }

      if (!_isShieldActive && mounted) {
        setState(() => _isShieldActive = true);
      }

      final currentEmail = (AuthService().cachedCurrentUser?.email ??
              AuthService().currentUser?.email ??
              '')
          .trim()
          .toLowerCase();

      // Siklus polling: periksa setiap 250ms hingga 32 kali (~8s). WebView
      // Android dengan tata letak seluler memuat SPA NotebookLM lebih lambat.
      for (var attempt = 0; attempt < _maxVerificationAttempts; attempt++) {
        if (!_isCurrentVerification(epoch) || _isSessionReady) return;

        final detectedEmail = await _detectGoogleEmail(controller);
        if (!_isCurrentVerification(epoch)) return;
        if (detectedEmail != null && detectedEmail.isNotEmpty) {
          if (currentEmail.isNotEmpty && detectedEmail != currentEmail) {
            // Tampilkan peringatan jika akun Google berbeda
            await _showAccountMismatchDialog(detectedEmail, currentEmail);
            return;
          }
          // Email Google cocok
          await _onSessionAuthenticated();
          return;
        }

        await Future.delayed(const Duration(milliseconds: 250));
      }
      inconclusive = true;
    } catch (_) {
      if (_isCurrentVerification(epoch)) _showVerificationRecovery();
    } finally {
      _isCheckingAccount = false;
    }

    if (inconclusive && _isCurrentVerification(epoch)) {
      await _handleInconclusiveVerification(controller);
    }
  }

  static const int _maxVerificationAttempts = 32;

  /// Sesi masuk Google ke NotebookLM langsung diverifikasi dan diarahkan ke Dashboard.
  Future<void> _checkApplicationEntry(InAppWebViewController controller) async {
    if (!identical(controller.platform, _webController?.platform) ||
        !_isCurrentVerification(_connectionEpoch) ||
        _isCheckingAccount ||
        _isCompletingSession) {
      return;
    }
    _isCheckingAccount = true;
    final epoch = _connectionEpoch;
    try {
      final url = await controller.getUrl().timeout(const Duration(seconds: 3));
      if (!_isCurrentVerification(epoch) || url == null) {
        return;
      }
      final host = url.host.toLowerCase();
      final path = url.path.toLowerCase();

      final isMyAccount = GoogleConnectionNavigation.isAccountPage(url.uriValue) ||
          (url.uriValue.scheme == 'https' &&
              host == 'accounts.google.com' &&
              (path.contains('/b/') ||
                  path.contains('/recovery') ||
                  path.contains('/speedbump') ||
                  path.contains('/accountchooser')));

      final isNotebookLm = host.contains('notebooklm.google.com') ||
          host.contains('notebook.google.com');

      // 1. Jika masih berada di formulir login Google (email, password, 2FA challenge), biarkan pengguna berinteraksi
      if (!isMyAccount && host.contains('accounts.google.com')) {
        final isAuthForm = path.contains('/signin') ||
            path.contains('/servicelogin') ||
            path.contains('/identifier') ||
            path.contains('/challenge') ||
            path.contains('/v3/signin') ||
            path.contains('/interactivelogin');
        if (isAuthForm) return;
      }

      if (!isMyAccount &&
          (path.contains('/login') ||
              path.contains('/signin') ||
              path.contains('/servicelogin'))) {
        return;
      }

      if (!isNotebookLm && !isMyAccount) {
        return;
      }

      // Aktifkan pelindung visual agar UI NotebookLM / akun Google tidak pernah bocor ke layar pengguna
      if (!_isShieldActive && mounted) {
        setState(() => _isShieldActive = true);
      }

      // 3. Deteksi email Google aktif dari sesi. Pengguna WAJIB memiliki email valid!
      String? email;
      for (var attempt = 0; attempt < 8; attempt++) {
        if (!_isCurrentVerification(epoch)) return;
        email = await _detectGoogleEmail(controller);
        if (email != null && email.isNotEmpty && email.contains('@')) {
          break;
        }
        await Future.delayed(const Duration(milliseconds: 300));
      }

      final cleanEmail = (email != null && email.isNotEmpty && email.contains('@'))
          ? email.trim().toLowerCase()
          : (_authService.cachedCurrentUser?.email ?? '').trim().toLowerCase();

      if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
        // Belum ada email aktif di DOM atau sesi, jangan redirect prematur!
        return;
      }

      // 4. Pastikan sesi cookies Google aktif di WebKit
      final hasSession = await _hasGoogleSession();
      if (!_isCurrentVerification(epoch)) return;
      if (hasSession != true) {
        return;
      }

      // Seluruh 4 kriteria terpenuhi: sesi Google 100% SUKSES!
      final locked = await PersistentGoogleSession.instance
          .lockAndPersistCookies(controller, cleanEmail,
              isCurrent: () => _isCurrentVerification(epoch));
      if (!_isCurrentVerification(epoch) || !locked) return;

      await PersistentGoogleSession.instance
          .establishVerifiedOwner(cleanEmail);
      if (!_isCurrentVerification(epoch)) return;

      await AuthService.rememberWebSessionOwner(cleanEmail);
      await AuthService.establishVerifiedWebUser(cleanEmail);
      if (!_isCurrentVerification(epoch)) return;

      // Jika mendarat di myaccount atau halaman verifikasi lanjutan, arahkan controller ke NotebookLM di latar belakang
      if (isMyAccount) {
        unawaited(controller.loadUrl(
          urlRequest: URLRequest(url: WebUri('https://notebook.google.com/')),
        ));
      }

      await _enterApplication();
    } catch (_) {
      // Browser verification must not block the explicit app-entry action.
    } finally {
      _isCheckingAccount = false;
    }
  }

  Future<void> _enterApplication() async {
    if (!mounted ||
        _isCompletingSession ||
        _isCancelDialogOpen ||
        _connectionCancelled) {
      return;
    }
    _connectionEpoch++;
    _isCompletingSession = true;
    Navigator.pushNamedAndRemoveUntil(
        context, AppRoutes.dashboard, (route) => false);
  }

  /// Email Google tidak terbaca dari DOM sampai polling habis. Pelindung visual
  /// menutup seluruh WebView, jadi tanpa jalur keluar di sini layar macet
  /// selamanya pada "Menyelaraskan sesi akun Google...".
  ///
  /// - Tanpa cookie sesi Google: pengguna belum benar-benar masuk, arahkan
  ///   kembali ke halaman login (pelindung turun otomatis di onLoadStart).
  /// - Cookie tidak bisa dibaca: sesi belum dapat diverifikasi, tanpa logout.
  /// - Cookie ada: konfirmasi hanya meminta pemeriksaan identitas ulang.
  Future<void> _handleInconclusiveVerification(
      InAppWebViewController controller) async {
    final epoch = _connectionEpoch;
    if (!_isCurrentVerification(epoch) ||
        _isSessionReady ||
        _isMismatchDialogOpen) {
      return;
    }
    debugPrint(
        '[GoogleSessionAuth] Email Google tidak terdeteksi setelah $_maxVerificationAttempts percobaan, memakai fallback.');

    final hasSession = await _hasGoogleSession();
    if (!_isCurrentVerification(epoch) || _isSessionReady) return;

    if (hasSession == false) {
      await controller.loadUrl(
        urlRequest: URLRequest(url: WebUri(_targetLoginUrl)),
      );
      return;
    }
    if (hasSession == null) {
      _showVerificationRecovery();
      return;
    }

    final confirmed = await _confirmSameAccount();
    if (!_isCurrentVerification(epoch) || _isSessionReady) return;
    if (confirmed == true) {
      await _onSessionAuthenticated();
    } else if (confirmed == false) {
      // "Periksa lagi": muat ulang agar onLoadStop memicu verifikasi baru.
      await controller.reload();
    }
  }

  /// Menampilkan dialog jika pengguna masuk dengan akun Google yang berbeda
  Future<void> _showAccountMismatchDialog(
      String detectedEmail, String expectedEmail) async {
    if (!mounted || _isMismatchDialogOpen) return;
    _isMismatchDialogOpen = true;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: OTColors.surface(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OTRadius.dialog),
          side: BorderSide(color: OTColors.border(isDark)),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: OTColors.marja(isDark), size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                Loc.tr('googleAccountMismatchTitle'),
                style: ScholarlyFonts.outfit(
                  fontSize: OTFontSize.s16,
                  fontWeight: FontWeight.w700,
                  color: OTColors.textPrimary(isDark),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Loc.tr('googleAccountMismatchApp'),
              style: ScholarlyFonts.outfit(
                fontSize: OTFontSize.s12,
                color: OTColors.textSecondary(isDark),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: OTColors.canvas(isDark),
                borderRadius: BorderRadius.circular(OTRadius.xs),
                border: Border.all(color: OTColors.border(isDark)),
              ),
              child: Text(
                expectedEmail,
                style: ScholarlyFonts.outfit(
                  fontSize: OTFontSize.s14,
                  fontWeight: FontWeight.w600,
                  color: OTColors.accent(isDark),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              Loc.tr('googleAccountMismatchBrowser'),
              style: ScholarlyFonts.outfit(
                fontSize: OTFontSize.s12,
                color: OTColors.textSecondary(isDark),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: OTColors.canvas(isDark),
                borderRadius: BorderRadius.circular(OTRadius.xs),
                border: Border.all(color: OTColors.border(isDark)),
              ),
              child: Text(
                detectedEmail,
                style: ScholarlyFonts.outfit(
                  fontSize: OTFontSize.s14,
                  fontWeight: FontWeight.w600,
                  color: OTColors.marja(isDark),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              Loc.tr('googleAccountMismatchMustMatch'),
              style: ScholarlyFonts.outfit(
                fontSize: OTFontSize.s12,
                height: 1.4,
                color: OTColors.textSecondary(isDark),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _confirmCancelConnection();
            },
            child: Text(
              Loc.tr('exit'),
              style:
                  ScholarlyFonts.outfit(color: OTColors.textSecondary(isDark)),
            ),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (mounted) {
                setState(() => _isShieldActive = false);
              }
              // Pilih akun lewat pemilih akun Google; cookie tidak dihapus.
              if (_webController != null) {
                await _webController!.loadUrl(
                  urlRequest: URLRequest(
                      url: WebUri(
                          'https://accounts.google.com/AccountChooser?continue=${Uri.encodeComponent('${NotebookNavigation.canonicalOrigin}/')}')),
                );
              }
            },
            child: Text(
              Loc.tr('ui_f9d6eb247c'),
              style: ScholarlyFonts.outfit(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
    _isMismatchDialogOpen = false;
  }

  /// Memeriksa cookie sesi Google di WebView. `null` berarti platform tidak
  /// dapat membacanya, sehingga keputusan tidak boleh didasarkan padanya.
  Future<bool?> _hasGoogleSession() async {
    try {
      return await PersistentGoogleSession.instance
          .hasLiveSession(_webController);
    } catch (_) {
      return null;
    }
  }

  /// Dialog konfirmasi akun yang sama. `true` = sudah masuk, `false` = periksa lagi.
  Future<bool?> _confirmSameAccount() async {
    if (!mounted) return null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentEmail = (AuthService().cachedCurrentUser?.email ??
            AuthService().currentUser?.email ??
            '')
        .trim()
        .toLowerCase();
    _isConfirmOpen = true;
    return showDialog<bool>(
      context: context,
      // Tidak boleh ditutup lewat tap di luar: hasil `null` akan membiarkan
      // pelindung visual menutup WebView tanpa jalur keluar.
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: OTColors.surface(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OTRadius.dialog),
          side: BorderSide(color: OTColors.border(isDark)),
        ),
        title: Text(
          Loc.tr('confirmGoogleAccountTitle'),
          style: ScholarlyFonts.outfit(
            fontWeight: FontWeight.w700,
            fontSize: OTFontSize.s16,
            color: OTColors.textPrimary(isDark),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Loc.tr('confirmGoogleAccountDesc'),
              style: ScholarlyFonts.outfit(
                fontSize: OTFontSize.s14,
                color: OTColors.textSecondary(isDark),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: OTColors.canvas(isDark),
                borderRadius: BorderRadius.circular(OTRadius.xs),
                border: Border.all(color: OTColors.border(isDark)),
              ),
              child: Text(
                currentEmail.isNotEmpty
                    ? currentEmail
                    : Loc.tr('sameAccountFallback'),
                style: ScholarlyFonts.outfit(
                  fontSize: OTFontSize.s14,
                  fontWeight: FontWeight.w600,
                  color: OTColors.accent(isDark),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              Loc.tr('checkAgain'),
              style:
                  ScholarlyFonts.outfit(color: OTColors.textSecondary(isDark)),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              Loc.tr('yesAlreadySignedIn'),
              style: ScholarlyFonts.outfit(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ).whenComplete(() => _isConfirmOpen = false);
  }

  /// Tombol Lanjutkan manual untuk memeriksa login dan konfirmasi akun
  Future<void> _handleManualContinue() async {
    if (_isAppEntry) {
      final controller = _webController;
      if (controller != null) {
        await _checkApplicationEntry(controller);
      }
      if (!mounted || _isCompletingSession) return;
      final hasSession = await _hasGoogleSession();
      final email = (AuthService.activeWebUserEmail ??
              _authService.cachedCurrentUser?.email ??
              '')
          .trim();
      if (hasSession == true && email.contains('@')) {
        await _enterApplication();
      } else if (mounted) {
        AppSnackBar.warning(context, Loc.tr('pleaseFinishGoogleLogin'));
      }
      return;
    }
    if (!mounted ||
        _isSessionReady ||
        _isCompletingSession ||
        _isCancelDialogOpen ||
        _connectionCancelled) {
      return;
    }
    if (_verificationFailed) {
      _retryVerification();
      return;
    }
    final epoch = _connectionEpoch;
    final controller = _webController;
    WebUri? currentWebUrl;
    try {
      currentWebUrl =
          await controller?.getUrl().timeout(const Duration(seconds: 5));
    } catch (_) {}
    if (!_isCurrentVerification(epoch)) return;

    if (currentWebUrl == null ||
        !NotebookNavigation.notebook(currentWebUrl.uriValue)) {
      if (mounted) {
        AppSnackBar.warning(
          context,
          Loc.tr('pleaseFinishGoogleLogin'),
        );
      }
      return;
    }

    final currentEmail = (AuthService().cachedCurrentUser?.email ??
            AuthService().currentUser?.email ??
            '')
        .trim()
        .toLowerCase();

    if (controller != null) {
      final detectedEmail = await _detectGoogleEmail(controller);
      if (!_isCurrentVerification(epoch)) return;
      if (detectedEmail != null && detectedEmail.isNotEmpty) {
        if (currentEmail.isNotEmpty && detectedEmail != currentEmail) {
          _showAccountMismatchDialog(detectedEmail, currentEmail);
          return;
        }
        await _onSessionAuthenticated();
        return;
      }
    }

    if (!_isCurrentVerification(epoch)) return;

    // Konfirmasi manual hanya berlaku bila sesi Google benar-benar ada;
    // tanpa itu ruang AI pasti gagal dibuka.
    if (await _hasGoogleSession() != true) {
      if (_isCurrentVerification(epoch)) _showVerificationRecovery();
      return;
    }
    if (!_isCurrentVerification(epoch)) return;

    // Jika belum terbaca dari DOM, tampilkan konfirmasi akun sama
    final confirm = await _confirmSameAccount();
    if (!_isCurrentVerification(epoch)) return;

    if (confirm == true) {
      await _onSessionAuthenticated();
    } else if (_isShieldActive) {
      // "Periksa lagi": muat ulang agar onLoadStop menjalankan verifikasi
      // otomatis kembali, bukan membiarkan layar tertutup pelindung.
      await controller?.reload();
    }
  }

  /// Only a matching account on Notebook can establish session ownership.
  /// Failed reads leave the existing native session intact and remain retryable.
  Future<void> _onSessionAuthenticated() async {
    final epoch = _connectionEpoch;
    if (!_isCurrentVerification(epoch) ||
        _isSessionReady ||
        _isCompletingSession) {
      return;
    }
    _isCompletingSession = true;
    try {
      final controller = _webController;
      final email = (AuthService().cachedCurrentUser?.email ??
              AuthService().currentUser?.email ??
              '')
          .trim()
          .toLowerCase();
      final url =
          await controller?.getUrl().timeout(const Duration(seconds: 5));
      if (!_isCurrentVerification(epoch)) return;
      if (controller == null ||
          email.isEmpty ||
          url == null ||
          !NotebookNavigation.notebook(url.uriValue)) {
        _showVerificationRecovery();
        return;
      }
      final detectedEmail = await _detectGoogleEmail(controller);
      if (!_isCurrentVerification(epoch)) return;
      if (detectedEmail != email) {
        _showVerificationRecovery();
        return;
      }
      final verified = await PersistentGoogleSession.instance
          .lockAndPersistCookies(
              controller, email,
              isCurrent: () =>
                  _isCurrentVerification(epoch) &&
                  (AuthService().cachedCurrentUser?.email ??
                              AuthService().currentUser?.email ??
                              '')
                          .trim()
                          .toLowerCase() ==
                      email);
      if (!_isCurrentVerification(epoch)) return;
      if (!verified) {
        _showVerificationRecovery();
        return;
      }
      setState(() => _isSessionReady = true);
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted || !_isCurrentVerification(epoch)) return;
      if (Navigator.canPop(context)) {
        Navigator.pop(context, GoogleConnectionResult.verified);
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.dashboard,
          (route) => false,
        );
      }
    } catch (_) {
      if (_isCurrentVerification(epoch)) _showVerificationRecovery();
    } finally {
      _isCompletingSession = false;
    }
  }

  /// Postponing an AI connection is separate from signing out in Settings.
  Future<void> _confirmCancelConnection() async {
    if (!mounted || _isCancelDialogOpen || _connectionCancelled) return;
    
    // Pada alur login awal (app entry):
    // DILARANG KERAS menampilkan dialog "Tunda koneksi AI?" atau tombol "Tunda dulu"
    // yang membypass login ke dashboard! Langsung kembali ke LoginScreen secara bersih.
    if (_isAppEntry) {
      _connectionCancelled = true;
      _connectionEpoch++;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
      return;
    }

    _isCancelDialogOpen = true;
    _connectionEpoch++;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = OTColors.textPrimary(isDark);
    final secondary = OTColors.textSecondary(isDark);
    final surface = OTColors.surface(isDark);

    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          side: BorderSide(color: OTColors.border(isDark)),
        ),
        title: Text(
          Loc.tr('cancelGoogleConnectionTitle'),
          style: ScholarlyFonts.outfit(
            fontWeight: FontWeight.w600,
            color: primary,
          ),
        ),
        content: Text(
          Loc.tr('cancelGoogleConnectionDesc'),
          style: ScholarlyFonts.outfit(
            fontSize: OTFontSize.s14,
            color: secondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              Loc.tr('continueGoogleConnection'),
              style: ScholarlyFonts.outfit(
                color: secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              Loc.tr('cancelGoogleConnectionAction'),
              style: OTTypography.button(color: OTColors.onAccent(isDark)),
            ),
          ),
        ],
      ),
    );
    _isCancelDialogOpen = false;

    if (shouldCancel == true && mounted) {
      _connectionCancelled = true;
      _connectionEpoch++;
      if (Navigator.canPop(context)) {
        Navigator.pop(context, GoogleConnectionResult.deferred);
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.dashboard,
          (route) => false,
        );
      }
    }
  }

  Widget _buildVerificationRecovery(bool isDark) => ColoredBox(
        color: OTColors.canvas(isDark),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline_rounded,
                    color: OTColors.textPrimary(isDark), size: 32),
                const SizedBox(height: 16),
                Text(Loc.tr('googleSessionUnverifiedTitle'),
                    textAlign: TextAlign.center,
                    style: ScholarlyFonts.outfit(
                        fontSize: OTFontSize.s16,
                        fontWeight: FontWeight.w600,
                        color: OTColors.textPrimary(isDark))),
                const SizedBox(height: 12),
                Text(Loc.tr('googleSessionUnverified'),
                    textAlign: TextAlign.center,
                    style: ScholarlyFonts.outfit(
                        fontSize: OTFontSize.s14,
                        color: OTColors.textSecondary(isDark))),
                const SizedBox(height: 20),
                FilledButton(
                    onPressed: _retryVerification,
                    child: Text(Loc.tr('tryAgain'))),
                TextButton(
                    onPressed: _confirmCancelConnection,
                    child: Text(Loc.tr('cancelGoogleConnectionAction'))),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvas = OTColors.canvas(isDark);
    final surface = OTColors.surface(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final currentEmail = (AuthService().cachedCurrentUser?.email ??
            AuthService().currentUser?.email ??
            '')
        .trim();

    if (_isSessionReady) {
      return Scaffold(
        backgroundColor: canvas,
        body: Center(
          child: AppLoader(
            title: AppCopy.googleSessionConnected,
            subtitle: AppCopy.googleSessionPreparing,
            dotSize: 10,
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final canGoBack = await _webController?.canGoBack() ?? false;
        if (!mounted) return;
        if (canGoBack) {
          await _webController?.goBack();
        } else {
          await _confirmCancelConnection();
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: canvas,
          systemNavigationBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: canvas,
          appBar: AppBar(
            backgroundColor: canvas,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded,
                  size: 20, color: textSecondary),
              tooltip: Loc.tr('back'),
              onPressed: () async {
                final canGoBack = await _webController?.canGoBack() ?? false;
                if (canGoBack) {
                  await _webController?.goBack();
                } else {
                  await _confirmCancelConnection();
                }
              },
            ),
            title: Text(
              _isAppEntry
                  ? Loc.tr('loginTitle')
                  : Loc.tr('roomSameAccountTitle'),
              style: ScholarlyFonts.newsreader(
                fontSize: OTFontSize.s18,
                fontWeight: FontWeight.w600,
                color: textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            actions: [
              IconButton(
                tooltip: Loc.tr('tryAgain'),
                icon:
                    Icon(Icons.refresh_rounded, size: 20, color: textSecondary),
                onPressed: _retryVerification,
              ),
              if (!_isAppEntry) ...[
                ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * 0.5),
                  child: TextButton(
                    onPressed: _handleManualContinue,
                    child: Text(
                      Loc.tr('ui_5bcbc797a7'),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: OTTypography.button(color: textPrimary),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: Loc.tr('cancelSignIn'),
                  icon:
                      Icon(Icons.close_rounded, size: 20, color: textSecondary),
                  onPressed: _confirmCancelConnection,
                ),
              ],
              const SizedBox(width: 4),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(2),
              child: ValueListenableBuilder<double>(
                valueListenable: _loadProgress,
                builder: (context, progress, child) {
                  if (progress >= 1.0) return const SizedBox(height: 2);
                  return LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(textPrimary),
                    minHeight: 2,
                  );
                },
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Tampilkan panduan akun hanya untuk alur verifikasi ulang, bukan alur login awal
                if (!_isAppEntry)
                  Flexible(
                    flex: 2,
                    fit: FlexFit.loose,
                    child: SingleChildScrollView(
                        child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusCard),
                        border: Border.all(color: border, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lock_outline_rounded,
                                  size: 16, color: textSecondary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  Loc.tr('roomSameAccountTitle'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: ScholarlyFonts.outfit(
                                    fontSize: OTFontSize.s14,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Cukup bilang login dengan akun yang sama
                          Text(
                            currentEmail.isNotEmpty
                                ? '${Loc.tr('pleaseSignInSameAccount')}: $currentEmail'
                                : Loc.tr('pleaseSignInSameAccount'),
                            style: ScholarlyFonts.outfit(
                              fontSize: OTFontSize.s12,
                              height: 1.4,
                              color: textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const LoginGuidance(compact: true),
                          if (currentEmail.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: canvas,
                                borderRadius:
                                    BorderRadius.circular(OTRadius.xs),
                                border: Border.all(color: border, width: 0.8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.account_circle_outlined,
                                      size: 15, color: textPrimary),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      currentEmail,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: ScholarlyFonts.outfit(
                                        fontSize: OTFontSize.s12,
                                        fontWeight: FontWeight.w600,
                                        color: textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ))),

                // ── InAppWebView Halaman Masuk Resmi Google ──
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                      border: Border.all(color: border, width: 1),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _verificationFailed
                        ? _buildVerificationRecovery(isDark)
                        : Stack(
                            children: [
                              Positioned.fill(
                                child: widget.webViewBuilder != null
                                    ? widget.webViewBuilder!(
                                        context,
                                        InAppWebViewSettings(
                                          userAgent: AppPlatform.isDesktop
                                              ? AppConstants.desktopUserAgent
                                              : AppConstants
                                                  .chromeMobileUserAgent,
                                          incognito: false,
                                          sharedCookiesEnabled:
                                              WebViewCookiePolicy
                                                  .sharedCookiesEnabled,
                                        ),
                                        _initialSessionUrl,
                                      )
                                    : InAppWebView(
                                        webViewEnvironment:
                                            DesktopWebViewRuntime.environment,
                                        initialUrlRequest: URLRequest(
                                            url: WebUri(_initialSessionUrl)),
                                        initialUserScripts:
                                            UnmodifiableListView([]),
                                        initialSettings: InAppWebViewSettings(
                                          userAgent: AppPlatform.isDesktop
                                              ? AppConstants.desktopUserAgent
                                              : AppConstants
                                                  .chromeMobileUserAgent,
                                          incognito: false,
                                          javaScriptEnabled: true,
                                          domStorageEnabled: true,
                                          databaseEnabled: true,
                                          useWideViewPort: false,
                                          loadWithOverviewMode: false,
                                          cacheEnabled: true,
                                          clearCache: false,
                                          transparentBackground: false,
                                          allowsInlineMediaPlayback: true,
                                          supportZoom: false,
                                          displayZoomControls: false,
                                          mixedContentMode: MixedContentMode
                                              .MIXED_CONTENT_NEVER_ALLOW,
                                          thirdPartyCookiesEnabled: true,
                                          sharedCookiesEnabled:
                                              WebViewCookiePolicy
                                                  .sharedCookiesEnabled,
                                          hardwareAcceleration: true,
                                          useHybridComposition: true,
                                          useOnRenderProcessGone: true,
                                          supportMultipleWindows: true,
                                          javaScriptCanOpenWindowsAutomatically:
                                              true,
                                          isInspectable: kDebugMode,
                                          forceDark: isDark
                                              ? ForceDark.ON
                                              : ForceDark.OFF,
                                          forceDarkStrategy: ForceDarkStrategy
                                              .PREFER_WEB_THEME_OVER_USER_AGENT_DARKENING,
                                          algorithmicDarkeningAllowed: true,
                                        ),
                                        onCreateWindow: (controller,
                                            createWindowAction) async {
                                          final targetUrl =
                                              createWindowAction.request.url;
                                          if (targetUrl != null &&
                                              (NotebookNavigation.signInFlow(
                                                      targetUrl.uriValue) ||
                                                  NotebookNavigation.allowed(
                                                      targetUrl.uriValue))) {
                                            await controller.loadUrl(
                                                urlRequest:
                                                    URLRequest(url: targetUrl));
                                            return true;
                                          }
                                          return false;
                                        },
                                        onWebViewCreated: (controller) =>
                                            _webController = controller,
                                        onProgressChanged:
                                            (controller, progress) {
                                          if (mounted) {
                                            _loadProgress.value =
                                                progress / 100;
                                          }
                                        },
                                        onLoadStart: (controller, url) {
                                          _handleUrlNavigation(controller, url);
                                        },
                                        onLoadStop: (controller, url) async {
                                          if (!mounted || url == null) return;
                                          _handleUrlNavigation(controller, url);
                                          unawaited(_detectGoogleRejection(
                                              controller, url));
                                          await _checkAccountVerification(
                                              controller);
                                        },
                                        onUpdateVisitedHistory:
                                            (controller, url, isReload) async {
                                          if (!mounted || url == null) return;
                                          _handleUrlNavigation(controller, url);
                                          await _checkAccountVerification(
                                              controller);
                                        },
                                        // Proses halaman mati: muat ulang agar pengguna
                                        // tidak tertinggal di layar kosong.
                                        onRenderProcessGone:
                                            (controller, detail) =>
                                                controller.reload(),
                                        onWebContentProcessDidTerminate:
                                            (controller) => controller.reload(),
                                        onReceivedError:
                                            (controller, request, error) {
                                          debugPrint(
                                              '[GoogleSessionAuth] WebView error: ${error.description}');
                                          if (request.isForMainFrame == true) {
                                            AuthFailureReporter.reportOnce(
                                                stage: 'login-webview',
                                                code:
                                                    'load-${error.type.toNativeValue() ?? 'unknown'}');
                                          }
                                        },
                                      ),
                              ),
                              if (_googleRejected)
                                Positioned(
                                  left: 16,
                                  right: 16,
                                  bottom: 16,
                                  child: SafeArea(
                                    child: FilledButton.icon(
                                      onPressed: () => submitDiagnosticFromUi(
                                        context,
                                        stage: 'login-webview',
                                        code: 'google-rejected',
                                        page: _lastPage,
                                      ),
                                      icon: const Icon(Icons.flag_outlined,
                                          size: 18),
                                      label: Text(Loc.tr('reportSend')),
                                    ),
                                  ),
                                ),
                              if (_isShieldActive)
                                Positioned.fill(
                                  child: ColoredBox(
                                    color: canvas,
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          OpenTurathMark(
                                              size: 38, color: textPrimary),
                                          const SizedBox(height: 20),
                                          Text(
                                            _isAppEntry
                                                ? 'Memuat...'
                                                : Loc.tr('verifyingSessionTitle'),
                                            textAlign: TextAlign.center,
                                            style: ScholarlyFonts.outfit(
                                              fontSize: OTFontSize.s16,
                                              fontWeight: FontWeight.w600,
                                              color: textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 32),
                                            child: Text(
                                              _isAppEntry
                                                  ? 'Mohon tunggu sebentar'
                                                  : Loc.tr(
                                                      'verifyingSessionSubtitle'),
                                              textAlign: TextAlign.center,
                                              style: ScholarlyFonts.outfit(
                                                fontSize: OTFontSize.s12,
                                                height: 1.4,
                                                color: textSecondary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          SizedBox(
                                            width: 140,
                                            child: LinearProgressIndicator(
                                              backgroundColor:
                                                  border.withValues(alpha: 0.3),
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      textPrimary),
                                              minHeight: 2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
