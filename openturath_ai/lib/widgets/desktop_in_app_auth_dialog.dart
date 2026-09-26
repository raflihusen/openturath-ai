import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../core/design/ot_colors.dart';
import '../core/scholarly_fonts.dart';
import '../core/theme.dart';
import '../services/desktop_webview_runtime.dart';
import 'app_loader.dart';
import 'openturath_brand.dart';

/// Modal dialog yang menyematkan browser internal (InAppWebView) untuk masuk Google.
/// Memastikan kuki sesi Google langsung tersimpan di WKWebsiteDataStore aplikasi,
/// sehingga pengguna tidak diarahkan ke browser eksternal dan tidak perlu masuk 2x
/// ketika membuka Google NotebookLM di ruang telaah.
class DesktopInAppAuthDialog extends StatefulWidget {
  const DesktopInAppAuthDialog({super.key});

  static const String authUrl =
      'https://open-turath.web.app/desktop-auth.html?mode=inapp';

  static const String desktopUserAgent =
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36';

  @override
  State<DesktopInAppAuthDialog> createState() => _DesktopInAppAuthDialogState();
}

class _DesktopInAppAuthDialogState extends State<DesktopInAppAuthDialog> {
  bool _isLoading = true;
  double _progress = 0.0;
  bool _hasResult = false;

  void _finishWithResult(Map<String, dynamic> result) {
    if (_hasResult || !mounted) return;
    _hasResult = true;
    Navigator.of(context, rootNavigator: true).pop(result);
  }

  void _finishCancel() {
    if (_hasResult || !mounted) return;
    _hasResult = true;
    Navigator.of(context, rootNavigator: true).pop(null);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? OTColors.canvasDark : OTColors.surfaceLight;
    final border = isDark ? OTColors.borderDark : OTColors.borderLight;
    final textPrimary =
        isDark ? OTColors.textPrimaryDark : OTColors.textPrimaryLight;
    final textSecondary =
        isDark ? OTColors.textSecondaryDark : OTColors.textSecondaryLight;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 520,
            maxHeight: 680,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                  blurRadius: 36,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                // ── Header Dialog ──
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF141416)
                        : const Color(0xFFF9F9FA),
                    border: Border(bottom: BorderSide(color: border, width: 0.8)),
                  ),
                  child: Row(
                    children: [
                      const OpenTurathMark(size: 26),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
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
                            size: 20, color: textSecondary),
                        tooltip: 'Tutup',
                        onPressed: _finishCancel,
                      ),
                    ],
                  ),
                ),

                // ── Loading Bar ──
                if (_isLoading)
                  LinearProgressIndicator(
                    value: _progress > 0 && _progress < 1.0 ? _progress : null,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? AppTheme.accentDark : AppTheme.accentLight,
                    ),
                    minHeight: 2,
                  )
                else
                  const SizedBox(height: 2),

                // ── InAppWebView Body ──
                Expanded(
                  child: Stack(
                    children: [
                      InAppWebView(
                        webViewEnvironment: DesktopWebViewRuntime.environment,
                        initialUrlRequest: URLRequest(
                          url: WebUri(DesktopInAppAuthDialog.authUrl),
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
                          supportMultipleWindows: true,
                          javaScriptCanOpenWindowsAutomatically: true,
                          userAgent: DesktopInAppAuthDialog.desktopUserAgent,
                          forceDark: isDark ? ForceDark.ON : ForceDark.OFF,
                          algorithmicDarkeningAllowed: false,
                        ),
                        onWebViewCreated: (controller) {
                          // Register JavaScript communication bridge
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

                          // Check if fragment contains auth payload
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

                      if (_isLoading && _progress < 0.3)
                        Container(
                          color: bg,
                          child: const Center(
                            child: AppLoader(
                              title: 'Menyiapkan ruang masuk…',
                              dotSize: 7,
                            ),
                          ),
                        ),
                    ],
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
