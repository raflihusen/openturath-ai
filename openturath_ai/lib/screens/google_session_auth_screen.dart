import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/routes.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';
import '../widgets/app_loader.dart';

/// Gerbang Sesi Google (Pre-Auth Gate)
/// Memastikan kuki autentikasi Google aktif di WebView sehingga pengguna
/// langsung dapat menggunakan korpus riset AI tanpa kendala login berulang.
class GoogleSessionAuthScreen extends StatefulWidget {
  const GoogleSessionAuthScreen({super.key});

  @override
  State<GoogleSessionAuthScreen> createState() =>
      _GoogleSessionAuthScreenState();
}

class _GoogleSessionAuthScreenState extends State<GoogleSessionAuthScreen> {
  InAppWebViewController? _webController;
  bool _isSessionReady = false;
  final ValueNotifier<double> _loadProgress = ValueNotifier<double>(0.0);

  static const String _chromeUserAgent =
      "Mozilla/5.0 (Linux; Android 14; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.6613.127 Mobile Safari/537.36";

  static const String _targetLoginUrl =
      "https://accounts.google.com/ServiceLogin?continue=https://notebook.google.com/";

  @override
  void dispose() {
    _loadProgress.dispose();
    _webController = null;
    super.dispose();
  }

  /// Simpan status sesi dan arahkan ke Dashboard
  Future<void> _onSessionAuthenticated() async {
    if (_isSessionReady) return;
    setState(() => _isSessionReady = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('google_session_ready', true);
    } catch (_) {}

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
  }

  Future<void> _confirmCancelAndSignOut() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.surfaceCardDark : AppTheme.surfaceCardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusCard)),
        title: Text(
          'Batal Hubungkan Google?',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
          ),
        ),
        content: Text(
          'Akun Google diperlukan agar ruang riset manuskrip AI dapat langsung digunakan tanpa meminta login berulang kali.',
          style: GoogleFonts.outfit(
            fontSize: 13,
            color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Tetap di Sini',
              style: GoogleFonts.outfit(
                color: isDark ? AppTheme.accentDark : AppTheme.accentLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.appleRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusPill)),
            ),
            child: Text(
              'Keluar Akun',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (shouldSignOut == true && mounted) {
      await AuthService().signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvas = isDark ? AppTheme.canvasDark : AppTheme.canvasLight;
    final surface = isDark ? AppTheme.surfaceCardDark : AppTheme.surfaceCardLight;
    final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final textPrimary = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final accent = isDark ? AppTheme.accentDark : AppTheme.accentLight;

    if (_isSessionReady) {
      return Scaffold(
        backgroundColor: canvas,
        body: const Center(
          child: AppLoader(
            title: 'Sesi Google Terhubung',
            subtitle: 'Menyiapkan akses korpus riset kitab...',
            dotSize: 10,
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _webController?.canGoBack() ?? false) {
          await _webController?.goBack();
        } else {
          await _confirmCancelAndSignOut();
        }
      },
      child: Scaffold(
        backgroundColor: canvas,
        appBar: AppBar(
          backgroundColor: canvas,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleSpacing: 16,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hubungkan Akun Google',
                style: GoogleFonts.newsreader(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                'Autentikasi sesi riset naskah turats',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: textSecondary,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Keluar Akun',
              icon: Icon(Icons.logout_rounded, size: 20, color: textSecondary),
              onPressed: _confirmCancelAndSignOut,
            ),
            const SizedBox(width: 8),
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
                  valueColor: AlwaysStoppedAnimation<Color>(accent),
                );
              },
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Banner Penjelasan Transparan
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                  border: Border.all(color: border, width: 0.8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 18, color: accent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Masuk ke akun Google Anda agar ruang riset AI langsung aktif tanpa meminta login berulang.',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          height: 1.35,
                          color: textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                    border: Border.all(color: border, width: 1),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InAppWebView(
                    initialUrlRequest: URLRequest(url: WebUri(_targetLoginUrl)),
                    initialSettings: InAppWebViewSettings(
                      userAgent: _chromeUserAgent,
                      javaScriptEnabled: true,
                      domStorageEnabled: true,
                      databaseEnabled: true,
                      sharedCookiesEnabled: true,
                      thirdPartyCookiesEnabled: true,
                      useHybridComposition: true,
                      supportMultipleWindows: true,
                      javaScriptCanOpenWindowsAutomatically: true,
                      mixedContentMode: MixedContentMode.MIXED_CONTENT_NEVER_ALLOW,
                      allowFileAccess: false,
                      allowContentAccess: false,
                      forceDark: isDark ? ForceDark.ON : ForceDark.OFF,
                      algorithmicDarkeningAllowed: false,
                    ),
                    shouldOverrideUrlLoading: (controller, navigationAction) async {
                      final uri = navigationAction.request.url;
                      if (uri == null) return NavigationActionPolicy.CANCEL;

                      final scheme = uri.scheme.toLowerCase();
                      if (scheme != 'https') return NavigationActionPolicy.CANCEL;

                      final host = uri.host.toLowerCase();
                      final isAllowed = host.endsWith('.google.com') ||
                          host == 'google.com' ||
                          host.endsWith('.gstatic.com') ||
                          host.endsWith('.googleusercontent.com');

                      return isAllowed
                          ? NavigationActionPolicy.ALLOW
                          : NavigationActionPolicy.CANCEL;
                    },
                    onWebViewCreated: (controller) => _webController = controller,
                    onProgressChanged: (controller, progress) {
                      _loadProgress.value = progress / 100;
                    },
                    onLoadStop: (controller, url) async {
                      if (url == null) return;
                      final urlStr = url.toString();
                      final host = url.host.toLowerCase();

                      final cookieManager = CookieManager.instance();
                      final cookies = await cookieManager.getCookies(
                        url: WebUri("https://notebook.google.com"),
                      );
                      final hasSession = cookies.any((c) =>
                          c.name == 'SID' ||
                          c.name == 'HSID' ||
                          c.name == 'SSID' ||
                          c.name == 'OSID');

                      if (hasSession ||
                          ((host.contains('notebook.google.com') ||
                                  host.contains('notebooklm.google.com')) &&
                              !urlStr.contains('ServiceLogin') &&
                              !urlStr.contains('signin'))) {
                        await _onSessionAuthenticated();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
