import '../widgets/adaptive_sheet.dart';
import '../services/desktop_webview_runtime.dart';
import '../widgets/desktop_webview_gate.dart';
import '../core/app_platform.dart';
import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/notebook_navigation.dart';
import '../core/notebook_ui_script.dart';
import '../core/copied_answer.dart';

import '../core/app_copy.dart';
import '../core/app_snackbar.dart';
import '../core/constants.dart';
import '../core/routes.dart';
import '../core/navigation_guard.dart';
import '../core/theme.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_motion.dart';
import '../core/design/ot_spacing.dart';
import '../core/scholarly_fonts.dart';
import '../models/agent_model.dart';
import '../models/user_model.dart';
import '../services/agent_service.dart';
import '../services/auth_service.dart';
import '../widgets/legal_document_sheet.dart';
import '../services/bookmark_service.dart';
import '../services/telemetry_service.dart';
import '../widgets/app_error_state.dart';
import '../widgets/app_loader.dart';
import '../widgets/library_bottom_sheet.dart';

/// AgentWebviewScreen: Tampilan Ruang Kajian NotebookLM
/// Dilengkapi App Bar native yang bersih di bawah kamera notch/status bar,
/// tombol kembali yang jelas, dan injeksi CSS/JS untuk menyembunyikan header Google.
class AgentWebviewScreen extends StatefulWidget {
  final AgentModel? agent;
  const AgentWebviewScreen({super.key, this.agent});

  /// Kebijakan keamanan URL: Hanya izinkan HTTPS pada ekosistem resmi Google NotebookLM
  static bool isAllowedNotebookUrl(Uri uri) => NotebookNavigation.allowed(uri);

  @override
  State<AgentWebviewScreen> createState() => _AgentWebviewScreenState();
}

class _AgentWebviewScreenState extends State<AgentWebviewScreen> {
  final AgentService _agentService = AgentService();
  final AuthService _authService = AuthService();

  final BookmarkService _bookmarkService = BookmarkService();

  InAppWebViewController? _webController;
  AgentModel? _agent;
  UserModel? _user;

  String? _agentUrl;
  bool _isLoadingUrl = true;
  bool _isWebViewLoading = true;
  bool _isPaywallRequired = false;
  String? _errorMessage;
  double _fontScale = 1.0;
  bool _isCopying = false;
  Timer? _readinessTimer;
  DateTime? _loadingStarted;
  int _readySamples = 0;
  bool _checkingReady = false;
  bool _hasCopied = false;

  bool _isExiting = false;
  bool _isGoingBack = false;

  @override
  void initState() {
    super.initState();
    _loadFontScale();
  }

  Future<void> _loadFontScale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getDouble('turath_font_zoom_level') ?? 1.0;
      final scale = value.isFinite ? value.clamp(0.85, 2.0).toDouble() : 1.0;
      if (mounted) {
        setState(() => _fontScale = scale);
      }
    } catch (_) {}
  }

  Future<void> _setFontScale(double scale) async {
    if (!mounted || !scale.isFinite) return;
    scale = scale.clamp(0.85, 2.0).toDouble();
    setState(() => _fontScale = scale);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('turath_font_zoom_level', scale);
      if (!mounted) return;
      await _applyCurrentFontScale();
    } catch (_) {}
  }

  Future<void> _applyCurrentFontScale() async {
    if (_webController == null) return;
    try {
      await _webController!.evaluateJavascript(
        source:
            'if (typeof applyTurathFontScale === "function") { applyTurathFontScale($_fontScale); }',
      );
    } catch (_) {}
  }

  DateTime? _lastCopiedToastAt;

  @override
  void dispose() {
    _readinessTimer?.cancel();
    if (mounted) {
      AppSnackBar.clear(context);
    }
    final controller = _webController;
    _webController = null;
    if (controller != null) {
      unawaited(_stopWebView(controller));
    }
    super.dispose();
  }

  static Future<void> _stopWebView(InAppWebViewController controller) async {
    try {
      await controller.stopLoading();
    } catch (_) {}
  }

  static const String _turatsMasterScript = r"""
    (function() {
      if (window.top !== window || !['notebooklm.google.com', 'notebook.google.com'].includes(location.hostname)) return;

      // 1. Injeksi Style CSS: Sembunyikan Header Resmi, Logo Google & NotebookLM
      var styleId = 'ot-hide-controls';
      var existingStyle = document.getElementById(styleId);
      if (!existingStyle) {
        var style = document.createElement('style');
        style.id = styleId;
        style.type = 'text/css';
        style.textContent = `
          /* Header, Top Bar, Logo, dan Banner Google NotebookLM */
          labs-tailwind-logo, a.logo-link, .logo-container,
          a[aria-label*="Homepage" i], a[aria-label*="NotebookLM" i], a[aria-label*="Gemini" i],
          .title-input, input.title-input, .title-container, .notebook-title,
          .title-card, mat-card.title-card, .mat-mdc-card.title-card,
          div.source-badge-container,
          .pro-badge,
          /* Sembunyikan kartu keterangan, hero cover, dan panduan notebook di atas chat */
          app-notebook-guide, notebook-guide, app-guide-intro, app-chat-intro,
          app-project-summary, app-notebook-overview, app-notebook-title,
          .notebook-guide, .guide-header, .guide-container, .notebook-guide-container,
          .hero-container, .cover-image-container, .project-info, .notebook-metadata,
          .project-summary, .notebook-summary, .summary-card, .guide-card,
          div:has(> img[alt*="cover" i]), div[class*="hero" i], div[class*="cover" i],
          div[class*="guide" i]:not(.chat-view):not(.conversation-container),
          /* Google Account Bar, App Launcher & Setelan */
          #gb, #gbwa, .gb_C, .gb_9a, .gb_8, .gb_U, div[id*="gb"], div[class*="gb_"],
          button.mat-tonal-button, a[aria-label*="Google" i],
          [aria-label*="Google Account" i], [aria-label*="Akun Google" i],
          [aria-label*="Google apps" i], [aria-label*="Aplikasi Google" i],
          /* Sembunyikan elemen internal bertanda khusus */
          [data-ot-hidden] {
            display: none !important;
            visibility: hidden !important;
            height: 0px !important;
            max-height: 0px !important;
            overflow: hidden !important;
            margin: 0px !important;
            padding: 0px !important;
            font-size: 0px !important;
            line-height: 0px !important;
            opacity: 0 !important;
            pointer-events: none !important;
            border: none !important;
          }
          top-bar, .top-bar, header, .header, .app-header, app-header,
          mat-toolbar, [role="banner"], .header-container, .header-row,
          .mobile-header, div[class*="mobile-header" i],
          .notebook-header, app-notebook-header, app-project-header,
          .project-header, div[class*="project-header" i] {
            position: fixed !important;
            top: -9999px !important;
            left: -9999px !important;
            opacity: 0 !important;
            pointer-events: none !important;
            z-index: -1 !important;
          }
          button[aria-label*="Settings" i], button[aria-label*="Setelan" i],
          button[aria-label*="Pengaturan" i], button[aria-label*="Notebook settings" i],
          button[aria-label*="More" i], button[aria-label*="Opsi" i],
          button[aria-label*="options" i], button[aria-label*="Notebook options" i],
          button[aria-label*="Option" i] {
            position: fixed !important;
            top: -9999px !important;
            left: -9999px !important;
            width: 24px !important;
            height: 24px !important;
            opacity: 0.001 !important;
            pointer-events: auto !important;
            visibility: visible !important;
            z-index: -1 !important;
          }
          .ot-opening-language [role="menu"],
          .ot-opening-language .mat-mdc-menu-panel,
          .ot-opening-language .cdk-overlay-pane:has([role="menu"]) {
            opacity: 0 !important;
          }
          .cdk-overlay-container {
            z-index: 99999 !important;
          }
          [role="dialog"], mat-dialog-container, .mat-mdc-dialog-container {
            opacity: 1 !important;
            visibility: visible !important;
            display: block !important;
            z-index: 100000 !important;
          }
          ::-webkit-scrollbar { display: none !important; width: 0px !important; }
          html, body, * { scrollbar-width: none !important; }
          /* Padding atas dan bawah agar percakapan tidak terpotong */
          .chat-panel-content, .chat-view, .conversation-container, .message-list, main {
            padding-top: 14px !important;
            padding-bottom: 24px !important;
            margin-top: 0px !important;
          }
        `;
        (document.head || document.documentElement).appendChild(style);
      }


      // 2. Font Scale Presisi
      window.applyTurathFontScale = function(value) {
        var scale = Number(value);
        if (!Number.isFinite(scale)) return;
        scale = Math.max(0.85, Math.min(2, scale));
        var fontStyle = document.getElementById('ot-font-scale-style');
        if (!fontStyle) {
          fontStyle = document.createElement('style');
          fontStyle.id = 'ot-font-scale-style';
          (document.head || document.documentElement).appendChild(fontStyle);
        }
        fontStyle.textContent = `
          .chat-panel-content, .chat-view, .conversation-container, .message-list, [role="article"] {
            font-size: ${Math.round(scale * 15)}px !important;
            line-height: 1.65 !important;
          }
          .chat-panel-content p, .chat-view p, [role="article"] p,
          .chat-panel-content span, .chat-view span, [role="article"] span,
          .chat-panel-content li, .chat-view li, [role="article"] li {
            font-size: inherit !important;
            line-height: inherit !important;
          }
          [lang="ar"], .arabic {
            font-size: ${Math.round(scale * 19)}px !important;
            line-height: 1.8 !important;
          }
        `;
      };
    })();
  """;

  static final _cloakScript = UserScript(
    source: _turatsMasterScript + notebookUiScript,
    injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
    forMainFrameOnly: true,
  );

  bool? _lastIsDark;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentIsDark = Theme.of(context).brightness == Brightness.dark;
    if (_lastIsDark != null && _lastIsDark != currentIsDark) {
      _webController?.setSettings(
        settings: InAppWebViewSettings(
          forceDark: currentIsDark ? ForceDark.ON : ForceDark.OFF,
          forceDarkStrategy:
              ForceDarkStrategy.PREFER_WEB_THEME_OVER_USER_AGENT_DARKENING,
          algorithmicDarkeningAllowed: true,
        ),
      );
      _applyThemeCss();
    }
    _lastIsDark = currentIsDark;

    if (_agent == null) {
      final rawArgs = ModalRoute.of(context)?.settings.arguments;
      if (rawArgs is Map<String, dynamic>) {
        _agent = rawArgs['agent'] as AgentModel?;
        _user = rawArgs['user'] as UserModel?;
      } else if (rawArgs is AgentModel) {
        _agent = rawArgs;
      }
      _agent ??= widget.agent ?? AgentModel.defaultAgents.first;
      _fetchAgentUrl();
    }
  }

  Future<void> _fetchAgentUrl() async {
    _readinessTimer?.cancel();
    TelemetryService.instance.leaveBreadcrumb(
      'Membuka telaah modul: ${_agent?.id}',
      category: 'webview',
    );
    setState(() {
      _isLoadingUrl = true;
      _isWebViewLoading = true;
      _isPaywallRequired = false;
      _agentUrl = null;
      _errorMessage = null;
    });

    // 0. Cek apakah modul masih berstatus 'coming_soon'
    if (_agent != null && _agent!.isComingSoon) {
      setState(() {
        _isLoadingUrl = false;
        _errorMessage = AppCopy.preparingModule(_agent!.title);
      });
      return;
    }

    // 1. Pastikan profil pengguna termuat untuk verifikasi hak akses
    _user ??= await _authService.getCurrentUserModel();
    if (!mounted) return;

    // 2. Cek hak akses akun pengguna
    if (_user == null || !_user!.hasAccessToAgent(_agent!.id)) {
      setState(() {
        _isPaywallRequired = true;
        _errorMessage = AppCopy.subscriptionRequiredFor(_agent!.title);
        _isLoadingUrl = false;
      });
      return;
    }

    try {
      final url = await _agentService.getAgentUrl(_agent!.id);
      if (!mounted) return;
      if (url == null || url.isEmpty) {
        setState(() {
          _errorMessage = AppCopy.moduleUnavailable;
          _isLoadingUrl = false;
        });
        return;
      }
      setState(() {
        _agentUrl = url;
        _isLoadingUrl = false;
      });
      _checkAndShowAdabDialog();
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().toLowerCase();
      final hasAccess = _user != null && _user!.hasAccessToAgent(_agent!.id);
      final isPaywall = msg.contains('permission-denied') ||
          msg.contains('berlangganan') ||
          msg.contains('langganan') ||
          msg.contains('subscription') ||
          msg.contains('unauthenticated') ||
          msg.contains('unauthorized') ||
          msg.contains('not-found') ||
          !hasAccess ||
          (e is AgentAccessException &&
              (e.code == 'permission-denied' ||
                  e.code == 'unauthenticated' ||
                  e.code == 'not-found'));

      setState(() {
        _errorMessage = isPaywall
            ? 'Untuk membuka dan menelaah kitab bersama ${_agent?.title ?? 'asisten ini'}, silakan aktifkan paket langganan Anda.'
            : (e is AgentAccessException
                ? e.message
                : AppCopy.studyNotLoadedYet);
        _isPaywallRequired = isPaywall;
        _isLoadingUrl = false;
      });
    }
  }

  Future<void> _detectGoogleAccessDenied() async {
    if (_webController == null) return;
    try {
      final res = await _webController!.evaluateJavascript(source: """
        (function() {
          var bodyText = document.body ? (document.body.innerText || '') : '';
          var href = window.location.href || '';
          if (href.includes('signin/v2/denied') ||
              href.includes('access_denied') ||
              bodyText.includes('You need access') || 
              bodyText.includes('You do not have access') || 
              bodyText.includes('Request access') ||
              bodyText.includes('Anda memerlukan akses') ||
              bodyText.includes('Minta akses') ||
              bodyText.includes('Anda tidak memiliki akses') ||
              bodyText.includes('beralih ke akun yang memiliki akses') ||
              document.querySelector('button[aria-label*="Request access"]') !== null ||
              document.querySelector('button[aria-label*="Minta akses"]') !== null ||
              document.querySelector('.auth-error') !== null) {
            return 'DENIED';
          }
          return 'OK';
        })();
      """);
      if (res == 'DENIED' && mounted) {
        TelemetryService.instance.reportError(
          'Google 403 Access Denied on NotebookLM WebView',
          null,
          context: 'webview_access_denied_403',
          severity: 'warning',
          extra: {
            'agentId': _agent?.id ?? '',
            'agentTitle': _agent?.title ?? '',
            'userEmail': _user?.email ?? '',
          },
        );
        setState(() {
          _isPaywallRequired = true;
          _isLoadingUrl = false;
          _isWebViewLoading = false;
          _errorMessage =
              AppCopy.accessUnavailableFor(_agent?.title ?? AppCopy.studySpace);
        });
      }
    } catch (_) {}
  }

  Future<void> _applyHideScript() async {
    if (_webController == null) return;
    try {
      await _webController!
          .evaluateJavascript(source: _turatsMasterScript + notebookUiScript);
      await _applyThemeCss();
    } catch (_) {}
  }

  Future<void> _applyThemeCss() async {
    if (_webController == null) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    try {
      final themeScript = '''
        (function() {
          try {
            var isDark = $isDark;
            // 1. Standar W3C color-scheme meta tag
            var meta = document.querySelector('meta[name="color-scheme"]');
            if (!meta) {
              meta = document.createElement('meta');
              meta.name = 'color-scheme';
              (document.head || document.documentElement).appendChild(meta);
            }
            meta.content = isDark ? 'dark' : 'light';

            // 2. Sinkronkan class Google Material / NotebookLM tema gelap
            if (document.documentElement) {
              document.documentElement.classList.toggle('dark-theme', isDark);
              document.documentElement.classList.toggle('dark', isDark);
              document.documentElement.setAttribute('data-theme', isDark ? 'dark' : 'light');
              document.documentElement.style.colorScheme = isDark ? 'dark' : 'light';
            }
            if (document.body) {
              document.body.classList.toggle('dark-theme', isDark);
              document.body.classList.toggle('dark', isDark);
              document.body.setAttribute('data-theme', isDark ? 'dark' : 'light');
            }

            // 3. Pastikan latar belakang dasar & elemen internal selaras tanpa flash putih
            var canvasStyleId = 'ot-theme-canvas-style';
            var styleEl = document.getElementById(canvasStyleId);
            if (!styleEl) {
              styleEl = document.createElement('style');
              styleEl.id = canvasStyleId;
              (document.head || document.documentElement).appendChild(styleEl);
            }
            if (isDark) {
              styleEl.textContent = `
                html, body, [role="main"], mat-sidenav-content, mat-sidenav-container,
                .chat-container, .chat-viewport, .to-user-container, .message-content,
                .rendered-markdown, .query-container, .response-container,
                table, tr, td, th, mat-card, .mat-mdc-card, app-chat-message, app-chat-response,
                .chat-message-container, .notebook-content, .scrollable-content,
                .sources-panel, .studio-panel, div.content-container {
                  background-color: #0E0E10 !important;
                  color: #E4E4E7 !important;
                }
                table, th, td {
                  border-color: #27272A !important;
                }
                a {
                  color: #A1A1AA !important;
                }
              `;
            } else {
              styleEl.textContent = 'html, body { background-color: #FFFFFF !important; color: #18181B !important; }';
            }
          } catch(e) {}
        })();
      ''';
      await _webController!.evaluateJavascript(source: themeScript);
      await _applyCurrentFontScale();
    } catch (_) {}
  }

  Future<void> _saveCopiedAnswer(String text, String ownerUid) async {
    text = text.trim();
    if (text.isEmpty ||
        text.length > 200000 ||
        _authService.currentUser?.uid != ownerUid) {
      return;
    }
    final agent = _agent;
    if (agent == null) return;
    await _bookmarkService.addBookmark(copiedAnswerBookmark(text, agent),
        userId: ownerUid);
  }

  Future<void> _copyAnswerToClipboard() async {
    if (_webController == null || _isCopying) return;
    setState(() => _isCopying = true);
    try {
      final result = await _webController!.evaluateJavascript(
          source: 'window.otNotebook ? window.otNotebook.latest() : ""');
      final text = result is String ? result.trim() : '';
      if (text.isEmpty) {
        if (mounted) AppSnackBar.warning(context, AppCopy.noAnswerToCopy);
        return;
      }
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        setState(() => _hasCopied = true);
        AppSnackBar.success(context, AppCopy.answerCopied);
      }
    } catch (_) {
      if (mounted) AppSnackBar.error(context, AppCopy.copyFailed);
    } finally {
      if (mounted) setState(() => _isCopying = false);
    }
  }

  Future<void> _saveAnswerToBookmarks() async {
    if (_webController == null || _isCopying) return;
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;
    setState(() => _isCopying = true);
    try {
      final result = await _webController!.evaluateJavascript(
          source: 'window.otNotebook ? window.otNotebook.latest() : ""');
      final text = result is String ? result.trim() : '';
      if (text.isEmpty) {
        if (mounted) AppSnackBar.warning(context, AppCopy.noAnswerToSave);
        return;
      }
      await _saveCopiedAnswer(text, uid);
      if (mounted) {
        AppSnackBar.success(context, AppCopy.savedSuccess);
      }
    } catch (_) {
      if (mounted) AppSnackBar.error(context, AppCopy.saveFailed);
    } finally {
      if (mounted) setState(() => _isCopying = false);
    }
  }

  void _startReadinessCheck() {
    _readinessTimer?.cancel();
    _loadingStarted = DateTime.now();
    _readySamples = 0;
    _readinessTimer =
        Timer.periodic(const Duration(milliseconds: 500), (_) => _checkReady());
  }

  Future<void> _checkReady() async {
    if (_checkingReady || _webController == null || !mounted) return;
    _checkingReady = true;
    try {
      final url = await _webController!.getUrl();
      final host = url?.host.toLowerCase() ?? '';
      final path = url?.path.toLowerCase() ?? '';
      final isLogin = host.contains('accounts.google') ||
          host == 'accounts.youtube.com' ||
          host == 'consent.google.com' ||
          (host.contains('notebook') &&
              (path.contains('/login') ||
                  path.contains('/signin') ||
                  path.contains('/servicelogin')));
      if (isLogin) {
        _readinessTimer?.cancel();
        setState(() {
          _isWebViewLoading = false;
          _errorMessage =
              'Sesi akun Google Anda belum terhubung atau telah kedaluwarsa. Silakan hubungkan akun Google Anda.';
        });
        return;
      }
      final hasScript = await _webController!.evaluateJavascript(
        source:
            'typeof window.otNotebook !== "undefined" && typeof window.otNotebook.ready === "function"',
      );
      if (hasScript != true) {
        if (!mounted) return;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        await _webController!.evaluateJavascript(
          source:
              'window._otIsDark = $isDark;\n$_turatsMasterScript$notebookUiScript',
        );
        await _applyThemeCss();
      }
      final result = await _webController!.evaluateJavascript(
          source: 'window.otNotebook ? window.otNotebook.ready() : false');
      _readySamples = result == true ? _readySamples + 1 : 0;
      if (!mounted) return;
      final elapsedMs = _loadingStarted != null
          ? DateTime.now().difference(_loadingStarted!).inMilliseconds
          : 0;
      if (_readySamples >= 2 && elapsedMs >= 2000) {
        _readinessTimer?.cancel();
        setState(() => _isWebViewLoading = false);
      } else if (DateTime.now().difference(_loadingStarted!).inSeconds >= 45) {
        _readinessTimer?.cancel();
        setState(() {
          _isWebViewLoading = false;
          _errorMessage = AppCopy.studyNotLoadedYet;
        });
      }
    } catch (_) {
      if (mounted &&
          _loadingStarted != null &&
          DateTime.now().difference(_loadingStarted!).inSeconds >= 45) {
        _readinessTimer?.cancel();
        setState(() {
          _isWebViewLoading = false;
          _errorMessage = AppCopy.cannotLoad;
        });
      }
    } finally {
      _checkingReady = false;
    }
  }

  Future<void> _handleBackPress() async {
    if (!mounted || _isGoingBack) return;
    _isGoingBack = true;
    setState(() => _isExiting = true);
    // Beri jeda 1 frame agar solid canvas overlay ter-render menutupi SurfaceView WebView
    // sehingga transisi pop route halus tanpa tearing/glitch putih di Android
    await Future.delayed(const Duration(milliseconds: 40));
    try {
      await _webController?.stopLoading();
    } catch (_) {}
    if (mounted) {
      AppSnackBar.clear(context);
      Navigator.pop(context);
    }
  }

  bool _isNavigatingToSubscription = false;

  Future<void> _navigateToSubscription() async {
    if (_isNavigatingToSubscription) return;
    _isNavigatingToSubscription = true;
    try {
      final currentUser = _user ?? AuthService().cachedCurrentUser;
      if (!mounted) return;
      await NavigationGuard.safePushNamed(
        context,
        AppRoutes.subscription,
        arguments: {
          'agent': _agent,
          'user': currentUser,
        },
      );
      if (!mounted) return;
      final refreshedUser = await AuthService().getCurrentUserModel();
      if (mounted && refreshedUser != null) {
        setState(() {
          _user = refreshedUser;
        });
        if (_isPaywallRequired &&
            refreshedUser.hasAccessToAgent(_agent?.id ?? '')) {
          _fetchAgentUrl();
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isNavigatingToSubscription = false);
      } else {
        _isNavigatingToSubscription = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) =>
      DesktopWebViewGate(builder: _buildContent);

  Widget _buildContent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvas = OTColors.canvas(isDark);
    final surfaceSubtle = OTColors.surfaceSubtle(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final accent = OTColors.accent(isDark);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackPress();
      },
      child: Scaffold(
        backgroundColor: canvas,
        appBar: AppBar(
          toolbarHeight: 56,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: canvas,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: textPrimary, size: 22),
            tooltip: 'Kembali',
            onPressed: _handleBackPress,
          ),
          titleSpacing: 0,
          title: Text(
            _agent?.title ?? AppCopy.studySpace,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: OTTypography.corpusTitle(color: textPrimary).copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            if (_user != null && _user!.plan == 'trial')
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Center(
                  child: InkWell(
                    onTap: _navigateToSubscription,
                    borderRadius: OTRadius.chipBorder,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: surfaceSubtle,
                        borderRadius: OTRadius.chipBorder,
                        border: Border.all(color: border, width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt_rounded, size: 12, color: accent),
                          const SizedBox(width: 3),
                          Text(
                            '${_user!.questionsRemaining}',
                            style: OTTypography.caption(color: textPrimary)
                                .copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            IconButton(
              icon:
                  Icon(Icons.menu_book_outlined, color: textPrimary, size: 21),
              tooltip: AppCopy.referenceBooks,
              onPressed: () => showResearchLibrary(context, agent: _agent),
            ),
            IconButton(
              icon:
                  Icon(Icons.more_horiz_rounded, color: textPrimary, size: 22),
              tooltip: AppCopy.studyOptions,
              onPressed: _showOverflowMenu,
            ),
            const SizedBox(width: OTSpacing.xs),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Stack(
            children: [
              // ── 1. WebView Layer (Safe Below App Bar) ──
              if (_agentUrl != null)
                Container(
                  color: isDark
                      ? const Color(0xFF0E0E10)
                      : const Color(0xFFFFFFFF),
                  child: InAppWebView(
                    webViewEnvironment: DesktopWebViewRuntime.environment,
                    initialUrlRequest: URLRequest(url: WebUri(_agentUrl!)),
                    initialUserScripts:
                        UnmodifiableListView<UserScript>([_cloakScript]),
                    initialSettings: InAppWebViewSettings(
                      userAgent: AppPlatform.isDesktop
                          ? null
                          : AppConstants.chromeMobileUserAgent,
                      javaScriptEnabled: true,
                      domStorageEnabled: true,
                      databaseEnabled: true,
                      sharedCookiesEnabled: true,
                      thirdPartyCookiesEnabled: true,
                      cacheEnabled: true,
                      clearCache: false,
                      clearSessionCache: false,
                      useHybridComposition: true,
                      mixedContentMode:
                          MixedContentMode.MIXED_CONTENT_NEVER_ALLOW,
                      allowFileAccess: false,
                      allowContentAccess: false,
                      javaScriptCanOpenWindowsAutomatically: false,
                      useShouldOverrideUrlLoading: true,
                      supportZoom: true,
                      builtInZoomControls: true,
                      displayZoomControls: false,
                      mediaPlaybackRequiresUserGesture: false,
                      allowsInlineMediaPlayback: true,
                      forceDark: isDark ? ForceDark.ON : ForceDark.OFF,
                      forceDarkStrategy: ForceDarkStrategy
                          .PREFER_WEB_THEME_OVER_USER_AGENT_DARKENING,
                      algorithmicDarkeningAllowed: true,
                      transparentBackground: false,
                    ),
                    onWebViewCreated: (controller) {
                      _webController = controller;
                      final ownerUid = _authService.currentUser?.uid;
                      controller.addJavaScriptHandler(
                          handlerName: 'otCopiedAnswer',
                          callback: (args) async {
                            final url = await controller.getUrl();
                            if (ownerUid == null ||
                                url?.scheme != 'https' ||
                                ![
                                  'notebooklm.google.com',
                                  'notebook.google.com'
                                ].contains(url?.host) ||
                                args.isEmpty ||
                                args.first is! String) {
                              return false;
                            }
                            try {
                              final text = (args.first as String).trim();
                              if (text.isEmpty || text.length > 200000) {
                                return false;
                              }
                              final now = DateTime.now();
                              if (_lastCopiedToastAt != null &&
                                  now.difference(_lastCopiedToastAt!) <
                                      const Duration(milliseconds: 3500)) {
                                return true;
                              }
                              _lastCopiedToastAt = now;

                              await Clipboard.setData(
                                  ClipboardData(text: text));
                              if (context.mounted) {
                                AppSnackBar.success(
                                  context,
                                  AppCopy.answerCopied,
                                  duration: const Duration(milliseconds: 2500),
                                  action: SnackBarAction(
                                    label: 'Simpan',
                                    textColor: OTColors.onInverseSurface,
                                    onPressed: () => unawaited(
                                        _saveCopiedAnswer(text, ownerUid)),
                                  ),
                                );
                              }
                              return true;
                            } catch (_) {
                              if (context.mounted) {
                                AppSnackBar.error(context, AppCopy.saveFailed);
                              }
                              return false;
                            }
                          });
                      _startReadinessCheck();
                    },
                    onLoadStart: (controller, url) {
                      if (mounted) setState(() => _isWebViewLoading = true);
                      _startReadinessCheck();
                    },
                    onPermissionRequest: (controller, request) async =>
                        PermissionResponse(
                      resources: request.resources,
                      action: PermissionResponseAction.DENY,
                    ),
                    shouldOverrideUrlLoading:
                        (controller, navigationAction) async {
                      final uri = navigationAction.request.url;
                      return uri != null && NotebookNavigation.allowed(uri)
                          ? NavigationActionPolicy.ALLOW
                          : NavigationActionPolicy.CANCEL;
                    },
                    onLoadStop: (controller, url) async {
                      await _applyHideScript();
                      await _applyCurrentFontScale();
                      await _detectGoogleAccessDenied();
                      await _checkReady();
                    },
                    onProgressChanged: (controller, progress) async {
                      if (progress >= 25) {
                        await _applyHideScript();
                        await _detectGoogleAccessDenied();
                      }
                      if (progress >= 45) {
                        await _detectGoogleAccessDenied();
                      }
                    },
                    onReceivedError: (controller, request, error) {
                      if (request.isForMainFrame == true) {
                        TelemetryService.instance.reportError(
                          'WebView Main Frame Error: ${error.description} (code ${error.type})',
                          null,
                          context: 'webview_main_frame_error',
                          severity: 'error',
                          extra: {
                            'agentId': _agent?.id ?? '',
                            'url': request.url.toString(),
                          },
                        );
                      }
                      if (mounted && (request.isForMainFrame == true)) {
                        setState(() {
                          _isWebViewLoading = false;
                          _errorMessage = AppCopy.cannotLoad;
                        });
                      }
                    },
                  ),
                ),

              // ── Loading Indicator Screen (Unified Three Dots Minimal Pulse) ──
              if (_isLoadingUrl || (_isWebViewLoading && _errorMessage == null))
                Positioned.fill(
                  child: AppLoader.fullscreen(
                    title: _agent?.title ?? AppCopy.openStudy,
                    subtitle: AppCopy.loadingReferences,
                    onCancel: _handleBackPress,
                  ),
                ),

              // ── 2. Error / Paywall State Screen ──
              if (_errorMessage != null && !_isLoadingUrl)
                Positioned.fill(
                  child: Container(
                    color: canvas,
                    child: _isPaywallRequired
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 24),
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 400),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 72,
                                      height: 72,
                                      decoration: BoxDecoration(
                                        color: OTColors.surface(isDark),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: OTColors.border(isDark),
                                            width: 1.2),
                                      ),
                                      child: Icon(
                                        Icons.workspace_premium_outlined,
                                        size: 34,
                                        color: OTColors.accent(isDark),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      'Akses Langganan Diperlukan',
                                      textAlign: TextAlign.center,
                                      style: ScholarlyFonts.newsreader(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _errorMessage ??
                                          'Untuk membuka dan menelaah kitab bersama ${_agent?.title ?? 'asisten ini'}, silakan aktifkan paket langganan Anda.',
                                      textAlign: TextAlign.center,
                                      style: ScholarlyFonts.outfit(
                                        fontSize: 13.5,
                                        height: 1.45,
                                        color: textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 46,
                                      child: FilledButton.icon(
                                        onPressed: _navigateToSubscription,
                                        icon: const Icon(
                                            Icons.card_membership_rounded,
                                            size: 18),
                                        label: Text(
                                          'Langganan Sekarang',
                                          style: ScholarlyFonts.outfit(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14.5,
                                          ),
                                        ),
                                        style: FilledButton.styleFrom(
                                          backgroundColor:
                                              OTColors.accent(isDark),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(24),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 44,
                                      child: TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          AppCopy.backToHome,
                                          style: ScholarlyFonts.outfit(
                                            fontWeight: FontWeight.w500,
                                            color: textSecondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : AppErrorState(
                            title: AppCopy.cannotLoadStudy,
                            message: _errorMessage!,
                            icon: Icons.info_outline_rounded,
                            onRetry: _fetchAgentUrl,
                            retryLabel: AppCopy.tryAgain,
                            onBack: () => Navigator.pop(context),
                            backLabel: AppCopy.backToHome,
                          ),
                  ),
                ),

              // ── 3. Solid Exit Overlay (Mencegah glitch/tearing SurfaceView Android saat pop) ──
              if (_isExiting)
                Positioned.fill(
                  child: Container(
                    color: canvas,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkAndShowAdabDialog() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeen = prefs.getBool('has_acknowledged_adab_talaqqi') ?? false;
      if (!hasSeen && mounted) {
        await _showAdabTalaqqiDialog();
        await prefs.setBool('has_acknowledged_adab_talaqqi', true);
      }
    } catch (_) {}
  }

  Future<void> _showAdabTalaqqiDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface =
        isDark ? AppTheme.surfaceCardDark : AppTheme.surfaceCardLight;
    final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final textPrimary =
        isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: surface,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            side: BorderSide(color: border, width: 1.0),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.borderDark
                            : AppTheme.pillSecondaryBgLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.verified_outlined,
                        size: 20,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppCopy.adabDialogTitle,
                        style: GoogleFonts.newsreader(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded,
                          size: 20, color: textSecondary),
                      onPressed: () => Navigator.pop(dialogCtx),
                      splashRadius: 20,
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'التعلم بالتلقي عن الأشياخ هو الأصل',
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.scheherazadeNew(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppCopy.adabDialogLead,
                  style: GoogleFonts.outfit(
                    fontSize: 12.5,
                    height: 1.45,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                Divider(height: 1, color: border),
                const SizedBox(height: 14),
                _buildAdabPoint(
                  icon: Icons.menu_book_outlined,
                  title: AppCopy.adabHeading1,
                  description: AppCopy.adabBody1,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _buildAdabPoint(
                  icon: Icons.people_outline_rounded,
                  title: AppCopy.adabHeading2,
                  description: AppCopy.adabBody2,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _buildAdabPoint(
                  icon: Icons.fact_check_outlined,
                  title: AppCopy.adabHeading3,
                  description: AppCopy.adabBody3,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  isDark: isDark,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(dialogCtx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDark ? Colors.white : const Color(0xFF18181B),
                      foregroundColor:
                          isDark ? const Color(0xFF0E0E10) : Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusPill),
                      ),
                    ),
                    child: Text(
                      AppCopy.adabAcknowledgeButton,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(dialogCtx);
                      LegalDocumentSheet.showAiGuideline(context);
                    },
                    child: Text(
                      'Baca panduan rujukan selengkapnya',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: textSecondary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdabPoint({
    required IconData icon,
    required String title,
    required String description,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon,
              size: 16, color: isDark ? Colors.white : const Color(0xFF18181B)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  height: 1.35,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showOverflowMenu() {
    OTMotion.selection();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = OTColors.surface(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    showAdaptiveSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: OTRadius.sheetBorder,
          border: Border.all(color: border, width: 0.8),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: textSecondary.withValues(alpha: 0.3),
                  borderRadius: OTRadius.chipBorder,
                ),
              ),
            ),
            Text(
              AppCopy.studyOptions,
              style: OTTypography.corpusTitle(color: textPrimary)
                  .copyWith(fontSize: 18),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading:
                  Icon(Icons.translate_rounded, color: textPrimary, size: 20),
              title: Text('Bahasa output (50+ bahasa)',
                  style: OTTypography.bodyMedium(color: textPrimary)),
              onTap: () {
                Navigator.pop(ctx);
                _webController?.evaluateJavascript(
                  source:
                      'if (typeof window.otOpenLanguageSettings === "function") { window.otOpenLanguageSettings(); } else if (typeof otOpenLanguageSettings === "function") { otOpenLanguageSettings(); }',
                );
              },
            ),
            Divider(height: 1, color: border.withValues(alpha: 0.5)),
            ListTile(
              leading:
                  Icon(Icons.format_size_rounded, color: textPrimary, size: 20),
              title: Text('Ukuran teks (${(_fontScale * 100).round()}%)',
                  style: OTTypography.bodyMedium(color: textPrimary)),
              onTap: () {
                Navigator.pop(ctx);
                _showFontScalePicker();
              },
            ),
            Divider(height: 1, color: border.withValues(alpha: 0.5)),
            ListTile(
              leading: Icon(
                  _hasCopied ? Icons.check_circle_rounded : Icons.copy_rounded,
                  color: _hasCopied ? OTColors.marja(isDark) : textPrimary,
                  size: 20),
              title: Text(AppCopy.copyAnswerAction,
                  style: OTTypography.bodyMedium(color: textPrimary)),
              onTap: _isCopying
                  ? null
                  : () {
                      Navigator.pop(ctx);
                      _copyAnswerToClipboard();
                    },
            ),
            ListTile(
              leading: Icon(Icons.bookmark_border_rounded,
                  color: textPrimary, size: 20),
              title: Text(AppCopy.saveAnswerMenu,
                  style: OTTypography.bodyMedium(color: textPrimary)),
              onTap: _isCopying
                  ? null
                  : () {
                      Navigator.pop(ctx);
                      _saveAnswerToBookmarks();
                    },
            ),
          ],
        ),
      ),
    );
  }

  void _showFontScalePicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = OTColors.surface(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    showAdaptiveSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: OTRadius.sheetBorder,
            border: Border.all(color: border, width: 0.8),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: border,
                        borderRadius: OTRadius.chipBorder,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppCopy.studyOptions,
                    style: OTTypography.corpusTitle(color: textPrimary)
                        .copyWith(fontSize: 17),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sesuaikan ukuran huruf percakapan agar nyaman dibaca.',
                    style: OTTypography.caption(color: textSecondary),
                  ),
                  const SizedBox(height: 14),
                  _buildScaleOption(ctx,
                      label: 'Kecil (85%)', scale: 0.85, isDark: isDark),
                  _buildScaleOption(ctx,
                      label: 'Standar (100%)', scale: 1.0, isDark: isDark),
                  _buildScaleOption(ctx,
                      label: 'Sedang (120%)', scale: 1.20, isDark: isDark),
                  _buildScaleOption(ctx,
                      label: 'Besar (140%)', scale: 1.40, isDark: isDark),
                  _buildScaleOption(ctx,
                      label: 'Sangat besar (165%)',
                      scale: 1.65,
                      isDark: isDark),
                  _buildScaleOption(ctx,
                      label: 'Maksimal (200%)', scale: 2.00, isDark: isDark),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildScaleOption(
    BuildContext ctx, {
    required String label,
    required double scale,
    required bool isDark,
  }) {
    final isSelected = (_fontScale - scale).abs() < 0.05;
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final accent = OTColors.accent(isDark);

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        Icons.text_fields_rounded,
        size: (18 * scale).clamp(16.0, 24.0),
        color: isSelected ? accent : textSecondary,
      ),
      title: Text(
        label,
        style: OTTypography.body(color: isSelected ? accent : textPrimary)
            .copyWith(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_rounded, color: accent, size: 20)
          : null,
      onTap: () {
        _setFontScale(scale);
        Navigator.pop(ctx);
      },
    );
  }
}
