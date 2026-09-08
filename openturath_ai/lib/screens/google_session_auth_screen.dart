import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/routes.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';

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
  double _loadProgress = 0.0;

  static const String _chromeUserAgent =
      "Mozilla/5.0 (Linux; Android 14; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.6613.127 Mobile Safari/537.36";

  static const String _targetLoginUrl =
      "https://accounts.google.com/ServiceLogin?continue=https://notebook.google.com/";

  /// Simpan status sesi dan arahkan ke Dashboard
  Future<void> _onSessionAuthenticated() async {
    if (_isSessionReady) return;
    setState(() => _isSessionReady = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('google_session_ready', true);
    } catch (_) {}

    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
  }

  Future<void> _confirmCancelAndSignOut() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.surfaceCardDark : AppTheme.surfaceCardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Batal Hubungkan Google?',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
          ),
        ),
        content: Text(
          'Akun Google wajib dihubungkan agar ruang riset AI dapat langsung digunakan tanpa meminta login berulang kali.',
          style: GoogleFonts.outfit(
            fontSize: 13.5,
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
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 72,
                height: 72,
                child: Lottie.asset(
                  'assets/animations/thinking_ux_icon_looping.json',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Sesi Google Terhubung',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Menyiapkan akses korpus riset kitab...',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: textSecondary,
                ),
              ),
            ],
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
          title: Row(
            children: [
              SvgPicture.asset(
                'assets/images/notebooklm_round.svg',
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hubungkan Akun Google',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    Text(
                      'Login sekali di awal agar riset AI tidak terputus',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: textSecondary,
                      ),
                    ),
                  ],
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
          bottom: _loadProgress < 1.0
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(2),
                  child: LinearProgressIndicator(
                    value: _loadProgress,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(accent),
                  ),
                )
              : null,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(16),
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
                      forceDark: isDark ? ForceDark.ON : ForceDark.OFF,
                      algorithmicDarkeningAllowed: false,
                    ),
                    onWebViewCreated: (controller) => _webController = controller,
                    onProgressChanged: (controller, progress) {
                      setState(() => _loadProgress = progress / 100);
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
