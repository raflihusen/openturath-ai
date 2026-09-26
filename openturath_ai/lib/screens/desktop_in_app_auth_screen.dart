import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../core/design/ot_colors.dart';
import '../core/scholarly_fonts.dart';
import '../core/theme.dart';
import '../services/desktop_webview_runtime.dart';
import '../widgets/app_loader.dart';
import '../widgets/openturath_brand.dart';

/// Halaman autentikasi desktop internal berbasis InAppWebView.
/// Menggunakan rute layar penuh (Scaffold) tanpa ModalBarrier modal dialog,
/// sehingga interaksi mouse, touchpad, dan input keyboard macOS 100% aktif
/// dan langsung terfokus pada kolom pengisian email/sandi Google.
class DesktopInAppAuthScreen extends StatefulWidget {
  const DesktopInAppAuthScreen({super.key});

  static const String authUrl =
      'https://open-turath.web.app/desktop-auth.html?mode=inapp';

  static const String desktopUserAgent =
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36';

  @override
  State<DesktopInAppAuthScreen> createState() => _DesktopInAppAuthScreenState();
}

class _DesktopInAppAuthScreenState extends State<DesktopInAppAuthScreen> {
  bool _isLoading = true;
  double _progress = 0.0;
  bool _hasResult = false;

  void _finishWithResult(Map<String, dynamic> result) {
    if (_hasResult || !mounted) return;
    _hasResult = true;
    Navigator.of(context).pop(result);
  }

  void _finishCancel() {
    if (_hasResult || !mounted) return;
    _hasResult = true;
    Navigator.of(context).pop(null);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? OTColors.canvasDark : OTColors.surfaceLight;
    final headerBg =
        isDark ? const Color(0xFF141416) : const Color(0xFFF9F9FA);
    final border = isDark ? OTColors.borderDark : OTColors.borderLight;
    final textPrimary =
        isDark ? OTColors.textPrimaryDark : OTColors.textPrimaryLight;
    final textSecondary =
        isDark ? OTColors.textSecondaryDark : OTColors.textSecondaryLight;
    final accent = isDark ? AppTheme.accentDark : AppTheme.accentLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: headerBg,
            border: Border(bottom: BorderSide(color: border, width: 0.8)),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const OpenTurathMark(size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Masuk dengan Google',
                          style: ScholarlyFonts.newsreader(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          'Sesi tersinkronisasi otomatis untuk ruang telaah',
                          style: ScholarlyFonts.outfit(
                            fontSize: 11,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded,
                        size: 22, color: textSecondary),
                    tooltip: 'Batal',
                    onPressed: _finishCancel,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Loading Bar ──
          if (_isLoading)
            LinearProgressIndicator(
              value: _progress > 0 && _progress < 1.0 ? _progress : null,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
              minHeight: 2,
            )
          else
            const SizedBox(height: 2),

          // ── InAppWebView Body ──
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    ),
                  },
                  webViewEnvironment: DesktopWebViewRuntime.environment,
                  initialUrlRequest: URLRequest(
                    url: WebUri(DesktopInAppAuthScreen.authUrl),
                  ),
                  initialSettings: InAppWebViewSettings(
                    incognito: false,
                    javaScriptEnabled: true,
                    domStorageEnabled: true,
                    databaseEnabled: true,
                    sharedCookiesEnabled: true,
                    thirdPartyCookiesEnabled: true,
                    cacheEnabled: true,
                    clearCache: false,
                    clearSessionCache: false,
                    useHybridComposition: true,
                    transparentBackground: false,
                    supportMultipleWindows: true,
                    javaScriptCanOpenWindowsAutomatically: true,
                    userAgent: DesktopInAppAuthScreen.desktopUserAgent,
                    forceDark: isDark ? ForceDark.ON : ForceDark.OFF,
                    algorithmicDarkeningAllowed: false,
                  ),
                  onWebViewCreated: (controller) {
                    controller.addJavaScriptHandler(
                      handlerName: 'onDesktopAuthSuccess',
                      callback: (args) {
                        if (args.isEmpty) return;
                        final data = args[0];
                        if (data is Map) {
                          final status = data['status']?.toString();
                          if (status == 'cancel') {
                            _finishCancel();
                            return;
                          }
                          final idToken = data['idToken']?.toString();
                          if (idToken != null && idToken.isNotEmpty) {
                            _finishWithResult({
                              'idToken': idToken,
                              'email': data['email']?.toString(),
                              'name': data['name']?.toString(),
                            });
                          }
                        }
                      },
                    );
                  },
                  onCreateWindow: (controller, createWindowAction) async {
                    final targetUrl = createWindowAction.request.url;
                    if (targetUrl != null) {
                      await controller.loadUrl(
                        urlRequest: URLRequest(url: targetUrl),
                      );
                      return true;
                    }
                    return false;
                  },
                  onProgressChanged: (controller, progress) {
                    if (mounted) {
                      setState(() {
                        _progress = progress / 100.0;
                        if (progress >= 95) _isLoading = false;
                      });
                    }
                  },
                  onLoadStop: (controller, url) async {
                    if (mounted) setState(() => _isLoading = false);
                    if (url == null) return;

                    // Pastikan input form Google langsung mendapatkan fokus aktif
                    try {
                      await controller.evaluateJavascript(source: """
                        setTimeout(function() {
                          var inp = document.querySelector('input[type="email"], input[type="text"], input#identifierId');
                          if (inp) {
                            inp.focus();
                            inp.click();
                          }
                        }, 250);
                      """);
                    } catch (_) {}

                    // Periksa fragmen hash callback
                    if (url.fragment.startsWith('auth=')) {
                      try {
                        final raw =
                            Uri.decodeComponent(url.fragment.substring(5));
                        final map = jsonDecode(raw) as Map<String, dynamic>;
                        final idToken = map['idToken']?.toString();
                        if (idToken != null && idToken.isNotEmpty) {
                          _finishWithResult(map);
                        }
                      } catch (_) {}
                    }
                  },
                  onUpdateVisitedHistory: (controller, url, isReload) {
                    if (url == null) return;
                    if (url.fragment.startsWith('auth=')) {
                      try {
                        final raw =
                            Uri.decodeComponent(url.fragment.substring(5));
                        final map = jsonDecode(raw) as Map<String, dynamic>;
                        final idToken = map['idToken']?.toString();
                        if (idToken != null && idToken.isNotEmpty) {
                          _finishWithResult(map);
                        }
                      } catch (_) {}
                    }
                  },
                ),

                if (_isLoading && _progress < 0.25)
                  Container(
                    color: bg,
                    child: const Center(
                      child: AppLoader(
                        title: 'Menghubungkan ke Google…',
                        dotSize: 7,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
