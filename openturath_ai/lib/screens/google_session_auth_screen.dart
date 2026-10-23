import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_copy.dart';
import '../core/design/ot_colors.dart';
import '../core/localization.dart';
import '../core/notebook_navigation.dart';
import '../core/routes.dart';
import '../core/scholarly_fonts.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';
import '../services/desktop_webview_runtime.dart';
import '../services/persistent_google_session.dart';
import '../widgets/app_loader.dart';

import 'package:openturath_ai/core/design/ot_typography.dart';
import 'package:openturath_ai/core/design/ot_radius.dart';
import 'package:openturath_ai/core/design/ot_buttons.dart';
import '../core/app_snackbar.dart';

/// Layar Autentikasi Sesi Google (Langkah 2 dari 2)
/// Menghubungkan sesi Google / NotebookLM di WebView secara langsung setelah login Firebase,
/// dengan disclaimer jelas bahwa pengguna wajib masuk dengan akun Google yang sama.
class GoogleSessionAuthScreen extends StatefulWidget {
  const GoogleSessionAuthScreen({
    super.key,
    this.webViewBuilder,
  });

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
  InAppWebViewController? _webController;
  bool _isSessionReady = false;
  final ValueNotifier<double> _loadProgress = ValueNotifier<double>(0.0);
  bool _isMismatchDialogOpen = false;
  bool _isShieldActive = false;
  bool _isCheckingAccount = false;

  String get _targetLoginUrl {
    final email = (AuthService().cachedCurrentUser?.email ??
            AuthService().currentUser?.email ??
            '')
        .trim();
    if (email.isNotEmpty) {
      return 'https://accounts.google.com/InteractiveLogin?continue=${NotebookNavigation.canonicalOrigin}/&login_hint=${Uri.encodeComponent(email)}';
    }
    return 'https://accounts.google.com/InteractiveLogin?continue=${NotebookNavigation.canonicalOrigin}/';
  }

  /// Skrip penyembunyi antarmuka NotebookLM di level mesin WebKit (Document Start Cloak).
  /// Menjamin tidak ada 1 piksel pun antarmuka NotebookLM yang pernah digambar ke layar,
  /// sementara struktur DOM dan objek JavaScript Google (WIZ_global_data) tetap utuh di memori.
  static UserScript _buildStealthCloakScript(bool isDark) {
    const script = '''
      (function() {
        try {
          var host = (window.location.hostname || '').toLowerCase();
          if (!host.includes('notebooklm.google.com') && !host.includes('notebook.google.com')) {
            return;
          }
          var styleId = 'ot-stealth-auth-cloak';
          var style = document.getElementById(styleId);
          if (!style) {
            style = document.createElement('style');
            style.id = styleId;
            (document.head || document.documentElement).appendChild(style);
          }
          style.textContent = 'html, body { background-color: #09090B !important; color: transparent !important; overflow: hidden !important; } body * { opacity: 0 !important; pointer-events: none !important; }';
        } catch(e) {}
      })();
    ''';
    return UserScript(
      source: script,
      injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
      forMainFrameOnly: true,
    );
  }

  /// Menyelaraskan status pelindung visual (Visual Shield) dengan domain navigasi WebView
  void _handleUrlNavigation(InAppWebViewController controller, WebUri? url) {
    if (!mounted || url == null) return;
    final uri = url.uriValue;
    final isNotebook = NotebookNavigation.notebook(uri);
    final isAuthFlow = NotebookNavigation.signInFlow(uri);

    if (isNotebook) {
      if (!_isShieldActive && mounted) {
        setState(() => _isShieldActive = true);
      }
      // Suntikkan style pelindung cadangan untuk navigasi SPA sisi-klien
      controller.evaluateJavascript(source: '''
        try {
          var styleId = 'ot-stealth-auth-cloak';
          var style = document.getElementById(styleId) || document.createElement('style');
          style.id = styleId;
          style.textContent = 'html, body { background-color: #09090B !important; color: transparent !important; overflow: hidden !important; } body * { opacity: 0 !important; pointer-events: none !important; }';
          (document.head || document.documentElement).appendChild(style);
        } catch(_) {}
      ''');
    } else if (isAuthFlow && _isShieldActive && !_isMismatchDialogOpen) {
      setState(() => _isShieldActive = false);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
    return null;
  } catch(e) {
    return null;
  }
})();
''');
      if (result != null && result is String && result.trim().contains('@')) {
        return result.trim().toLowerCase();
      }
    } catch (_) {}
    return null;
  }

  /// Memverifikasi bahwa sesi di WebView telah selesai dan menggunakan akun yang sama.
  /// Dilengkapi mutex guard dan siklus polling adaptif untuk menjamin keandalan pada koneksi lambat.
  Future<void> _checkAccountVerification(
      InAppWebViewController controller) async {
    if (!mounted || _isSessionReady || _isCheckingAccount) return;
    final currentWebUrl = await controller.getUrl();
    if (currentWebUrl == null) return;
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

    _isCheckingAccount = true;
    if (!_isShieldActive && mounted) {
      setState(() => _isShieldActive = true);
    }

    final currentEmail = (AuthService().cachedCurrentUser?.email ??
            AuthService().currentUser?.email ??
            '')
        .trim()
        .toLowerCase();

    try {
      // Siklus Polling Adaptif: periksa setiap 250ms hingga 15 kali (~3.75s)
      const maxAttempts = 15;
      for (var attempt = 0; attempt < maxAttempts; attempt++) {
        if (!mounted || _isSessionReady) return;

        final detectedEmail = await _detectGoogleEmail(controller);
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
    } finally {
      _isCheckingAccount = false;
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
              _confirmCancelAndSignOut();
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
              try {
                await DesktopWebViewRuntime.cookies.deleteAllCookies();
              } catch (_) {}
              if (mounted) {
                setState(() => _isShieldActive = false);
              }
              if (_webController != null) {
                await _webController!.loadUrl(
                  urlRequest: URLRequest(url: WebUri(_targetLoginUrl)),
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
      final cookies = await DesktopWebViewRuntime.cookies.getCookies(
        url: WebUri(NotebookNavigation.canonicalOrigin),
        webViewController: _webController,
      );
      const names = {'SID', '__Secure-1PSID', '__Secure-3PSID'};
      return cookies.any((cookie) =>
          names.contains(cookie.name) &&
          (cookie.value?.toString().isNotEmpty ?? false));
    } catch (_) {
      return null;
    }
  }

  /// Tombol Lanjutkan manual untuk memeriksa login dan konfirmasi akun
  Future<void> _handleManualContinue() async {
    if (!mounted || _isSessionReady) return;
    final controller = _webController;
    final currentWebUrl = await controller?.getUrl();
    final urlStr = currentWebUrl?.toString() ?? '';

    if (urlStr.isEmpty ||
        urlStr.contains('accounts.google') ||
        urlStr.contains('InteractiveLogin') ||
        urlStr.contains('ServiceLogin') ||
        urlStr.contains('signin/v2')) {
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
      if (!mounted) return;
      if (detectedEmail != null && detectedEmail.isNotEmpty) {
        if (currentEmail.isNotEmpty && detectedEmail != currentEmail) {
          _showAccountMismatchDialog(detectedEmail, currentEmail);
          return;
        }
        await _onSessionAuthenticated();
        return;
      }
    }

    if (!mounted) return;

    // Konfirmasi manual hanya berlaku bila sesi Google benar-benar ada;
    // tanpa itu ruang AI pasti gagal dibuka.
    if (await _hasGoogleSession() == false) {
      if (mounted) {
        AppSnackBar.warning(
          context,
          Loc.tr('pleaseFinishGoogleLogin'),
        );
      }
      return;
    }
    if (!mounted) return;

    // Jika belum terbaca dari DOM, tampilkan konfirmasi akun sama
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirm = await showDialog<bool>(
      context: context,
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
    );

    if (confirm == true && mounted) {
      await _onSessionAuthenticated();
    }
  }

  /// Menandai sesi Google terautentikasi dan melanjutkan
  Future<void> _onSessionAuthenticated() async {
    if (!mounted || _isSessionReady) return;
    setState(() => _isSessionReady = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('google_session_ready', true);
      final email = (AuthService().cachedCurrentUser?.email ??
              AuthService().currentUser?.email ??
              '')
          .trim()
          .toLowerCase();
      if (email.isNotEmpty) {
        await prefs.setString('google_session_email', email);
        await prefs.setString('notebook_google_email', email);
        await PersistentGoogleSession.instance
            .lockAndPersistCookies(_webController, email);
      }
    } catch (_) {}
    await AuthService.rememberWebSessionOwner(
        AuthService().cachedCurrentUser?.email ??
            AuthService().currentUser?.email ??
            '');

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    if (Navigator.canPop(context)) {
      Navigator.pop(context, true);
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.dashboard,
        (route) => false,
      );
    }
  }

  /// Dialog konfirmasi jika pengguna membatalkan / keluar dari langkah ke-2
  Future<void> _confirmCancelAndSignOut() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = OTColors.textPrimary(isDark);
    final secondary = OTColors.textSecondary(isDark);
    final surface = OTColors.surface(isDark);

    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          side: BorderSide(color: OTColors.border(isDark)),
        ),
        title: Text(
          Loc.tr('cancelSignInTitle'),
          style: ScholarlyFonts.outfit(
            fontWeight: FontWeight.w600,
            color: primary,
          ),
        ),
        content: Text(
          Loc.tr('googleSessionSignInSameAccountDesc'),
          style: ScholarlyFonts.outfit(
            fontSize: OTFontSize.s14,
            color: secondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              Loc.tr('cancel'),
              style: ScholarlyFonts.outfit(
                color: secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: OTButtons.destructive(isDark),
            child: Text(
              Loc.tr('exit'),
              style: OTTypography.button(color: OTColors.onAccent(isDark)),
            ),
          ),
        ],
      ),
    );

    if (shouldSignOut == true && mounted) {
      await AuthService().signOut();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

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
          await _confirmCancelAndSignOut();
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
                  await _confirmCancelAndSignOut();
                }
              },
            ),
            title: Text(
              Loc.tr('roomSameAccountTitle'),
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
                onPressed: () {
                  _webController?.reload();
                },
              ),
              TextButton(
                onPressed: _handleManualContinue,
                child: Text(
                  Loc.tr('ui_5bcbc797a7'),
                  style: OTTypography.button(color: textPrimary),
                ),
              ),
              IconButton(
                tooltip: Loc.tr('exit'),
                icon:
                    Icon(Icons.logout_rounded, size: 20, color: textSecondary),
                onPressed: _confirmCancelAndSignOut,
              ),
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
                // ── Info Wajib Akun yang Sama (Langkah 2) ──
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                    border: Border.all(color: border, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: textPrimary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(OTRadius.xs),
                              border: Border.all(
                                color: border,
                                width: 0.6,
                              ),
                            ),
                            child: Text(
                              Loc.tr('stepTwoOfTwo'),
                              style: ScholarlyFonts.outfit(
                                fontSize: OTFontSize.s11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                                color: textPrimary,
                              ),
                            ),
                          ),
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
                      if (currentEmail.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: canvas,
                            borderRadius: BorderRadius.circular(OTRadius.xs),
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
                ),

                // ── InAppWebView Halaman Masuk Resmi Google ──
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                      border: Border.all(color: border, width: 1),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: widget.webViewBuilder != null
                              ? widget.webViewBuilder!(
                                  context,
                                  InAppWebViewSettings(
                                    incognito: false,
                                  ),
                                  _targetLoginUrl,
                                )
                              : InAppWebView(
                                  webViewEnvironment:
                                      DesktopWebViewRuntime.environment,
                                  initialUrlRequest:
                                      URLRequest(url: WebUri(_targetLoginUrl)),
                                  initialUserScripts: UnmodifiableListView([
                                    _buildStealthCloakScript(isDark),
                                  ]),
                                  initialSettings: InAppWebViewSettings(
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
                                    sharedCookiesEnabled: true,
                                    hardwareAcceleration: true,
                                    useHybridComposition: true,
                                    useOnRenderProcessGone: true,
                                    supportMultipleWindows: true,
                                    javaScriptCanOpenWindowsAutomatically: true,
                                    isInspectable: kDebugMode,
                                    forceDark:
                                        isDark ? ForceDark.ON : ForceDark.OFF,
                                    forceDarkStrategy: ForceDarkStrategy
                                        .PREFER_WEB_THEME_OVER_USER_AGENT_DARKENING,
                                    algorithmicDarkeningAllowed: true,
                                  ),
                                  onCreateWindow:
                                      (controller, createWindowAction) async {
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
                                  onProgressChanged: (controller, progress) {
                                    if (mounted) {
                                      _loadProgress.value = progress / 100;
                                    }
                                  },
                                  onLoadStart: (controller, url) {
                                    _handleUrlNavigation(controller, url);
                                  },
                                  onLoadStop: (controller, url) async {
                                    if (!mounted || url == null) return;
                                    _handleUrlNavigation(controller, url);
                                    await _checkAccountVerification(controller);
                                  },
                                  onUpdateVisitedHistory:
                                      (controller, url, isReload) async {
                                    if (!mounted || url == null) return;
                                    _handleUrlNavigation(controller, url);
                                    await _checkAccountVerification(controller);
                                  },
                                  onReceivedError:
                                      (controller, request, error) {
                                    debugPrint(
                                        '[GoogleSessionAuth] WebView error: ${error.description}');
                                  },
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
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: surface,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: border, width: 1.2),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.verified_user_outlined,
                                          size: 26,
                                          color: textPrimary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    Text(
                                      Loc.tr('verifyingSessionTitle'),
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
                                        Loc.tr('verifyingSessionSubtitle'),
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
