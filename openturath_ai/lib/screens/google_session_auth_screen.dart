import 'dart:async';
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
import '../widgets/app_loader.dart';

import 'package:openturath_ai/core/design/ot_typography.dart';
import 'package:openturath_ai/core/design/ot_radius.dart';
import 'package:openturath_ai/core/design/ot_buttons.dart';

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
      return 'https://accounts.google.com/InteractiveLogin?continue=${NotebookNavigation.canonicalOrigin}/&login_hint=${Uri.encodeComponent(email)}';
    }
    return 'https://accounts.google.com/InteractiveLogin?continue=${NotebookNavigation.canonicalOrigin}/';
  }

  @override
  void initState() {
    super.initState();
    // Cek langsung apakah kuki sesi Google sudah aktif sebelumnya
    _checkInitialSession();
    // Polling periodik cookie untuk memastikan deteksi sesi segera setelah user menyelesaikan login Google
    _cookiePollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted && !_isSessionReady) {
        _checkAndAuthenticateSession(null);
      }
    });
  }

  Future<void> _checkInitialSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionReady = prefs.getBool('google_session_ready') ?? false;
      final sessionEmail = prefs.getString('google_session_email') ?? '';
      final currentEmail = (AuthService().cachedCurrentUser?.email ??
              AuthService().currentUser?.email ??
              '')
          .trim()
          .toLowerCase();

      // Hanya lewati jika sesi sudah terbukti siap dan emailnya cocok
      if (!sessionReady || currentEmail.isEmpty || sessionEmail != currentEmail) {
        return;
      }

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
      if (hasSession && mounted) {
        await _onSessionAuthenticated();
      }
    } catch (_) {}
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
    final currentWebUrl = url ?? await _webController?.getUrl();
    final urlStr = currentWebUrl?.toString() ?? '';

    // Jangan tandai selesai jika pengguna masih berada di halaman formulir masuk
    if (urlStr.contains('ServiceLogin') ||
        urlStr.contains('InteractiveLogin') ||
        urlStr.contains('signin/v2') ||
        urlStr.contains('signin/rejected') ||
        urlStr.contains('challenge') ||
        urlStr.contains('v3/signin') ||
        urlStr.contains('identifier')) {
      return;
    }

    // 1. Deteksi melalui URL AI/Google yang telah berhasil terbuka
    if (currentWebUrl != null &&
        NotebookNavigation.notebook(currentWebUrl.uriValue) &&
        !urlStr.contains('accounts.google')) {
      await _onSessionAuthenticated();
      return;
    }

    // 2. Deteksi melalui kuki sesi resmi Google jika sudah bukan di halaman login
    if (urlStr.isNotEmpty && !urlStr.contains('accounts.google')) {
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
                onPressed: _onSessionAuthenticated,
                child: Text(
                  'Lanjutkan',
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
                              'LANGKAH 2 DARI 2',
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
                            ? 'Silakan login ke Google menggunakan akun yang sama: $currentEmail'
                            : 'Silakan login ke Google menggunakan akun yang sama.',
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
                              mixedContentMode:
                                  MixedContentMode.MIXED_CONTENT_NEVER_ALLOW,
                              thirdPartyCookiesEnabled: true,
                              sharedCookiesEnabled: true,
                              hardwareAcceleration: true,
                              useHybridComposition: true,
                              useOnRenderProcessGone: true,
                              supportMultipleWindows: true,
                              javaScriptCanOpenWindowsAutomatically: true,
                              isInspectable: kDebugMode,
                              forceDark: isDark ? ForceDark.ON : ForceDark.OFF,
                              forceDarkStrategy: ForceDarkStrategy
                                  .PREFER_WEB_THEME_OVER_USER_AGENT_DARKENING,
                              algorithmicDarkeningAllowed: true,
                            ),
                            onCreateWindow:
                                (controller, createWindowAction) async {
                              final targetUrl = createWindowAction.request.url;
                              if (targetUrl != null &&
                                  (NotebookNavigation.signInFlow(
                                          targetUrl.uriValue) ||
                                      NotebookNavigation.allowed(
                                          targetUrl.uriValue))) {
                                await controller.loadUrl(
                                    urlRequest: URLRequest(url: targetUrl));
                                return true;
                              }
                              return false;
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
                            onReceivedError: (controller, request, error) {
                              debugPrint(
                                  '[GoogleSessionAuth] WebView error: ${error.description}');
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
