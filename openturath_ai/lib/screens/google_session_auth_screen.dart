import '../core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:openturath_ai/core/design/ot_fonts.dart';

import '../core/app_copy.dart';
import '../core/routes.dart';
import '../core/notebook_navigation.dart';
import '../core/notebook_ui_script.dart';
import '../widgets/app_error_state.dart';
import '../core/theme.dart';
import '../core/design/ot_colors.dart';
import '../services/auth_service.dart';
import '../widgets/app_loader.dart';

/// Gerbang Sesi Google (Pre-Auth Gate)
/// Memastikan kuki autentikasi Google aktif di WebView sehingga pengguna
/// langsung dapat membuka NotebookLM tanpa kendala masuk berulang.
class GoogleSessionAuthScreen extends StatefulWidget {
  const GoogleSessionAuthScreen({super.key});

  @override
  State<GoogleSessionAuthScreen> createState() =>
      _GoogleSessionAuthScreenState();
}

class _GoogleSessionAuthScreenState extends State<GoogleSessionAuthScreen> {
  InAppWebViewController? _webController;
  bool _isSessionReady = false;
  bool _allowPop = false;
  bool _notebookReached = false;
  String? _loadError;
  late final String? _ownerUid;

  @override
  void initState() {
    super.initState();
    _ownerUid = AuthService().currentUser?.uid;
  }

  bool get _ownsSession => _ownerUid != null && AuthService().currentUser?.uid == _ownerUid;
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
    if (!mounted || !_ownsSession || _isSessionReady) return;
    setState(() => _isSessionReady = true);

    if (!_ownsSession) return;
    await AuthService().markGoogleSessionReady(_ownerUid!);
    if (!mounted || !_ownsSession) return;
    if (Navigator.of(context).canPop()) {
      setState(() => _allowPop = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop(true);
      });
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    }
  }

  Future<void> _confirmCancelAndSignOut() async {
    if (Navigator.of(context).canPop()) {
      setState(() => _allowPop = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop(false);
      });
      return;
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.surfaceCardDark : AppTheme.surfaceCardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusCard)),
        title: Text(
          context.tr(AppCopy.cancelSignInTitle),
          style: OTFonts.outfit(
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
          ),
        ),
        content: Text(
          context.tr(AppCopy.googleSessionSignInSameAccountDesc),
          style: OTFonts.outfit(
            fontSize: 13,
            color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              context.tr(AppCopy.stayHere),
              style: OTFonts.outfit(
                color: isDark ? AppTheme.accentDark : AppTheme.accentLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: OTColors.destructive(isDark),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusPill)),
            ),
            child: Text(
              context.tr(AppCopy.exit),
              style: OTFonts.outfit(fontWeight: FontWeight.w600),
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
          child: AppLoader(
            title: context.tr(AppCopy.googleSessionConnected),
            subtitle: context.tr(AppCopy.googleSessionPreparing),
            dotSize: 10,
          ),
        ),
      );
    }

    return PopScope(
      canPop: _allowPop,
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
      child: Scaffold(
        backgroundColor: canvas,
        appBar: AppBar(
          toolbarHeight: 56.0 + (MediaQuery.textScalerOf(context).scale(20) - 20).clamp(0.0, double.infinity) * 1.6,
          backgroundColor: canvas,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            context.tr(AppCopy.googleSessionConnectTitle),
            style: OTFonts.newsreader(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          actions: [
            IconButton(
              tooltip: context.tr(AppCopy.exit),
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
                margin: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 10),
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
                        context.tr(AppCopy.googleSessionSignInHint),
                        style: OTFonts.outfit(
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
                  margin: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 12),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                    border: Border.all(color: border, width: 1),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _loadError != null
                      ? AppErrorState(
                          title: context.tr('Sesi belum terhubung'),
                          message: context.tr(_loadError!),
                          onRetry: () => setState(() => _loadError = null),
                        )
                      : InAppWebView(
                    initialUrlRequest: URLRequest(url: WebUri(_targetLoginUrl)),
                    initialSettings: InAppWebViewSettings(
                      userAgent: _chromeUserAgent,
                      javaScriptEnabled: true,
                      domStorageEnabled: true,
                      databaseEnabled: true,
                      sharedCookiesEnabled: true,
                      thirdPartyCookiesEnabled: true,
                      useHybridComposition: true,
                      supportMultipleWindows: false,
                      useShouldOverrideUrlLoading: true,
                      javaScriptCanOpenWindowsAutomatically: false,
                      mixedContentMode: MixedContentMode.MIXED_CONTENT_NEVER_ALLOW,
                      allowFileAccess: false,
                      allowContentAccess: false,
                      forceDark: isDark ? ForceDark.ON : ForceDark.OFF,
                      algorithmicDarkeningAllowed: false,
                    ),
                    shouldOverrideUrlLoading: (controller, navigationAction) async {
                      final uri = navigationAction.request.url;
                      if (!_ownsSession || uri == null) return NavigationActionPolicy.CANCEL;

                      return NotebookNavigation.allowed(uri)
                          ? NavigationActionPolicy.ALLOW : NavigationActionPolicy.CANCEL;
                    },
                    onWebViewCreated: (controller) => _webController = controller,
                    onProgressChanged: (controller, progress) {
                      if (mounted) _loadProgress.value = progress / 100;
                    },
                    onReceivedError: (controller, request, error) {
                      if (mounted && request.isForMainFrame == true) {
                        setState(() => _loadError = 'Periksa koneksi internet, lalu coba kembali.');
                      }
                    },
                    onReceivedHttpError: (controller, request, response) {
                      if (mounted && request.isForMainFrame == true && (response.statusCode ?? 0) >= 400) {
                        setState(() => _loadError = 'Layanan masuk sedang tidak tersedia. Coba kembali.');
                      }
                    },
                    onLoadStop: (controller, url) async {
                      if (!mounted || !_ownsSession || url == null ||
                          !NotebookNavigation.notebook(url.uriValue)) return;
                      setState(() => _notebookReached = true);
                      try {
                        await controller.evaluateJavascript(source: notebookUiScript);
                        final ready = await controller.evaluateJavascript(
                          source: 'window.otNotebook ? window.otNotebook.ready() : false',
                        );
                        // A Google cookie alone is not evidence that the notebook opened.
                        if (ready == true && mounted && _ownsSession) {
                          await _onSessionAuthenticated();
                        }
                      } catch (_) { /* The visible Google page remains usable. */ }
                    },
                  ),
                ),
              ),
              if (_notebookReached)
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 48, minWidth: double.infinity),
                    child: OutlinedButton.icon(
                      onPressed: _ownsSession ? _onSessionAuthenticated : null,
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: Text(context.tr('Kembali ke OpenTurath')),
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


