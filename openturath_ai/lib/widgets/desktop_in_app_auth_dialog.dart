import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../core/app_platform.dart';
import '../core/constants.dart';
import '../core/design/ot_colors.dart';
import '../core/scholarly_fonts.dart';
import '../core/theme.dart';
import '../services/desktop_google_sign_in.dart';
import '../services/desktop_webview_runtime.dart';
import 'app_loader.dart';
import 'openturath_brand.dart';

/// Halaman browser internal terpadu (InAppWebView) untuk masuk Google.
/// Berjalan sebagai full-page route (bukan modal dialog) agar macOS WKWebView
/// dan Android WebView mendapatkan fokus keyboard, touchpad, dan mouse 100% aktif.
/// Memastikan kuki sesi Google langsung tersimpan di storage aplikasi, sehingga
/// pengguna cukup 1x masuk tanpa perlu masuk berulang saat membuka asisten NotebookLM.
class DesktopInAppAuthDialog extends StatefulWidget {
  const DesktopInAppAuthDialog({super.key});

  /// Menggunakan domain firebaseapp.com yang identik dengan authDomain Firebase
  /// untuk mencegah pemblokiran cross-origin (auth/network-request-failed).
  static const String authUrl =
      'https://open-turath.firebaseapp.com/desktop-auth.html?mode=inapp';

  static const String desktopUserAgent =
      AppConstants.desktopSafariUserAgent;

  /// Menampilkan layar autentikasi in-app sebagai full-screen route
  /// untuk menjamin responsivitas penuh keyboard, touchpad, dan pointer.
  static Future<Map<String, dynamic>?> show(BuildContext context) {
    return Navigator.of(context, rootNavigator: true).push<Map<String, dynamic>>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => const DesktopInAppAuthDialog(),
      ),
    );
  }

  @override
  State<DesktopInAppAuthDialog> createState() => _DesktopInAppAuthDialogState();
}

class _DesktopInAppAuthDialogState extends State<DesktopInAppAuthDialog> {
  InAppWebViewController? _webController;
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

  Future<void> _openInSystemBrowser() async {
    try {
      final credential = await DesktopGoogleSignIn.signIn();
      if (credential != null && credential.idToken != null) {
        String? email;
        try {
          final prefs = await SharedPreferences.getInstance();
          email = prefs.getString('google_session_email') ??
              prefs.getString('notebook_google_email');
        } catch (_) {}
        _finishWithResult({
          'idToken': credential.idToken!,
          'email': email,
          'name': null,
        });
      }
    } catch (e) {
      debugPrint('[InAppAuth] System browser fallback error: $e');
    }
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final canGoBack = await _webController?.canGoBack() ?? false;
        if (canGoBack) {
          await _webController?.goBack();
        } else {
          _finishCancel();
        }
      },
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            color: textPrimary,
            tooltip: 'Kembali',
            onPressed: _finishCancel,
          ),
          title: Row(
            children: [
              const OpenTurathMark(size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Masuk ke Akun Google',
                      style: ScholarlyFonts.newsreader(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '1x login untuk akun & seluruh asisten telaah',
                      style: ScholarlyFonts.outfit(
                        fontSize: 11,
                        color: textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            if (AppPlatform.isDesktop)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: TextButton.icon(
                  onPressed: _openInSystemBrowser,
                  icon: const Icon(Icons.open_in_browser_rounded, size: 16),
                  label: const Text(
                    'Buka di Browser Mac',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: textSecondary,
                  ),
                ),
              ),
            IconButton(
              icon: Icon(Icons.close_rounded, size: 20, color: textSecondary),
              tooltip: 'Tutup',
              onPressed: _finishCancel,
            ),
            const SizedBox(width: 8),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2),
            child: _isLoading && _progress < 1.0
                ? LinearProgressIndicator(
                    value: _progress > 0 ? _progress : null,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? AppTheme.accentDark : AppTheme.accentLight,
                    ),
                    minHeight: 2,
                  )
                : const SizedBox(height: 2),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: AppPlatform.isDesktop ? 860 : double.infinity,
              ),
              child: Container(
                margin: AppPlatform.isDesktop
                    ? const EdgeInsets.fromLTRB(16, 8, 16, 16)
                    : EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.surfaceCardDark
                      : AppTheme.surfaceCardLight,
                  borderRadius: BorderRadius.circular(
                    AppPlatform.isDesktop ? AppTheme.radiusCard : 0,
                  ),
                  border: AppPlatform.isDesktop
                      ? Border.all(color: border, width: 1.0)
                      : null,
                ),
                clipBehavior: Clip.antiAlias,
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
                        userAgent: AppPlatform.isDesktop
                            ? DesktopInAppAuthDialog.desktopUserAgent
                            : AppConstants.chromeMobileUserAgent,
                        forceDark: isDark ? ForceDark.ON : ForceDark.OFF,
                        algorithmicDarkeningAllowed: false,
                      ),
                      onWebViewCreated: (controller) {
                        _webController = controller;
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
                        color: isDark
                            ? AppTheme.surfaceCardDark
                            : AppTheme.surfaceCardLight,
                        child: const Center(
                          child: AppLoader(
                            title: 'Menghubungkan ke Akun Google…',
                            subtitle:
                                'Sesi otomatis disinkronkan untuk telaah kitab',
                            dotSize: 7,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
