import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_copy.dart';
import '../core/app_platform.dart';
import '../core/constants.dart';
import '../core/design/ot_colors.dart';
import '../core/localization.dart';
import '../core/notebook_navigation.dart';
import '../core/routes.dart';
import '../core/scholarly_fonts.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';
import '../services/desktop_webview_runtime.dart';
import '../widgets/app_loader.dart';

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
  Timer? _cookiePollTimer;

  String get _targetLoginUrl {
    final email = (AuthService().cachedCurrentUser?.email ??
            AuthService().currentUser?.email ??
            '')
        .trim();
    if (email.isNotEmpty) {
      return 'https://accounts.google.com/ServiceLogin?continue=https://notebooklm.google.com/&Email=${Uri.encodeComponent(email)}&login_hint=${Uri.encodeComponent(email)}';
    }
    return 'https://accounts.google.com/ServiceLogin?continue=https://notebooklm.google.com/';
  }

  String get _userAgent {
    if (AppPlatform.isDesktop) {
      return AppConstants.desktopSafariUserAgent;
    }
    return AppConstants.chromeMobileUserAgent;
  }

  @override
  void initState() {
    super.initState();
    // Polling periodik cookie untuk memastikan deteksi sesi segera setelah user menyelesaikan login Google
    _cookiePollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted && !_isSessionReady) {
        _checkAndAuthenticateSession(null);
      }
    });
  }

  @override
  void dispose() {
    _cookiePollTimer?.cancel();
    _loadProgress.dispose();
    _webController = null;
    super.dispose();
  }

  /// Menandai sesi Google terautentikasi dan melanjutkan ke Dashboard
  Future<void> _onSessionAuthenticated() async {
    if (!mounted || _isSessionReady) return;
    setState(() => _isSessionReady = true);
    _cookiePollTimer?.cancel();

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
      }
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.dashboard,
      (route) => false,
    );
  }

  /// Memeriksa kuki dan URL untuk mendeteksi apakah sesi Google telah aktif
  Future<void> _checkAndAuthenticateSession(WebUri? url) async {
    if (!mounted || _isSessionReady) return;
    final urlStr = url?.toString() ?? '';

    // 1. Deteksi melalui URL NotebookLM yang telah berhasil terbuka
    if (url != null &&
        NotebookNavigation.notebook(url.uriValue) &&
        !urlStr.contains('ServiceLogin') &&
        !urlStr.contains('signin') &&
        !urlStr.contains('accounts.google')) {
      await _onSessionAuthenticated();
      return;
    }

    // 2. Deteksi melalui kuki sesi resmi Google
    try {
      final cookieManager = DesktopWebViewRuntime.cookies;
      final cookiesLm = await cookieManager.getCookies(
        url: WebUri('https://notebooklm.google.com'),
      );
      final cookiesNb = await cookieManager.getCookies(
        url: WebUri('https://notebook.google.com'),
      );
      final allCookies = [...cookiesLm, ...cookiesNb];
      final hasSession = allCookies.any((c) =>
          c.name == 'SID' ||
          c.name == 'HSID' ||
          c.name == 'SSID' ||
          c.name == 'OSID');

      if (hasSession) {
        await _onSessionAuthenticated();
      }
    } catch (_) {}
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
            fontSize: 13,
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
            style: FilledButton.styleFrom(
              backgroundColor: OTColors.destructive(isDark),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              Loc.tr('exit'),
              style: ScholarlyFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
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
              icon: Icon(Icons.arrow_back_rounded, size: 20, color: textSecondary),
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
              Loc.tr('googleSessionConnectTitle'),
              style: ScholarlyFonts.newsreader(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            actions: [
              IconButton(
                tooltip: Loc.tr('tryAgain'),
                icon: Icon(Icons.refresh_rounded, size: 20, color: textSecondary),
                onPressed: () {
                  _webController?.reload();
                },
              ),
              IconButton(
                tooltip: Loc.tr('exit'),
                icon: Icon(Icons.logout_rounded, size: 20, color: textSecondary),
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
                // ── Disclaimer Wajib Akun yang Sama (Langkah 2) ──
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: textPrimary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: border,
                                width: 0.6,
                              ),
                            ),
                            child: Text(
                              'LANGKAH 2 DARI 2',
                              style: ScholarlyFonts.outfit(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.6,
                                color: textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Autentikasi Ruang Asisten Google',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: ScholarlyFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Teks Penjelasan Disclaimer
                      Text(
                        Loc.tr('roomAuthBody', [
                          currentEmail.isNotEmpty
                              ? currentEmail
                              : Loc.tr('roomAuthSameAccount')
                        ]),
                        style: ScholarlyFonts.outfit(
                          fontSize: 12,
                          height: 1.4,
                          color: textSecondary,
                        ),
                      ),
                      if (currentEmail.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: canvas,
                            borderRadius: BorderRadius.circular(6),
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
                                    fontSize: 12,
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
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                      border: Border.all(color: border, width: 1),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: widget.webViewBuilder != null
                        ? widget.webViewBuilder!(
                            context,
                            InAppWebViewSettings(
                              incognito: false,
                              userAgent: _userAgent,
                            ),
                            _targetLoginUrl,
                          )
                        : InAppWebView(
                            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                              Factory<OneSequenceGestureRecognizer>(
                                () => EagerGestureRecognizer(),
                              ),
                            },
                            webViewEnvironment: DesktopWebViewRuntime.environment,
                            initialUrlRequest: URLRequest(url: WebUri(_targetLoginUrl)),
                      initialSettings: InAppWebViewSettings(
                        incognito: false,
                        userAgent: _userAgent,
                        javaScriptEnabled: true,
                        domStorageEnabled: true,
                        databaseEnabled: true,
                        sharedCookiesEnabled: true,
                        thirdPartyCookiesEnabled: true,
                        useHybridComposition: true,
                        supportMultipleWindows: false,
                        useShouldOverrideUrlLoading: true,
                        javaScriptCanOpenWindowsAutomatically: false,
                        mixedContentMode:
                            MixedContentMode.MIXED_CONTENT_NEVER_ALLOW,
                        allowFileAccess: false,
                        allowContentAccess: false,
                        forceDark: isDark ? ForceDark.ON : ForceDark.OFF,
                        algorithmicDarkeningAllowed: false,
                      ),
                      shouldOverrideUrlLoading:
                          (controller, navigationAction) async {
                        final uri = navigationAction.request.url;
                        if (uri == null) return NavigationActionPolicy.CANCEL;

                        if (NotebookNavigation.signInFlow(uri.uriValue) ||
                            NotebookNavigation.notebook(uri.uriValue)) {
                          return NavigationActionPolicy.ALLOW;
                        }
                        return NavigationActionPolicy.CANCEL;
                      },
                      onWebViewCreated: (controller) =>
                          _webController = controller,
                      onProgressChanged: (controller, progress) {
                        if (mounted) _loadProgress.value = progress / 100;
                      },
                      onLoadStop: (controller, url) async {
                        if (!mounted || url == null) return;
                        await _checkAndAuthenticateSession(url);
                      },
                      onUpdateVisitedHistory:
                          (controller, url, isReload) async {
                        if (!mounted || url == null) return;
                        await _checkAndAuthenticateSession(url);
                      },
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
