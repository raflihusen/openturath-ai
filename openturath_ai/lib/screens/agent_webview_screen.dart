import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_snackbar.dart';
import '../core/constants.dart';
import '../core/routes.dart';
import '../core/theme.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_motion.dart';
import '../core/design/ot_spacing.dart';
import '../models/agent_model.dart';
import '../models/bookmark_model.dart';
import '../models/user_model.dart';
import '../services/agent_service.dart';
import '../services/auth_service.dart';
import '../services/bookmark_service.dart';
import '../widgets/app_error_state.dart';
import '../widgets/app_loader.dart';

/// AgentWebviewScreen: Tampilan Ruang Riset AI NotebookLM
/// Dilengkapi App Bar native yang bersih di bawah kamera notch/status bar,
/// tombol kembali yang jelas, dan injeksi CSS/JS untuk menyembunyikan header Google.
class AgentWebviewScreen extends StatefulWidget {
  final AgentModel? agent;
  const AgentWebviewScreen({super.key, this.agent});

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
  bool _isBookmarking = false;
  bool _hasCopied = false;
  bool _hasBookmarked = false;

  @override
  void initState() {
    super.initState();
    _loadFontScale();
  }

  Future<void> _loadFontScale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scale = prefs.getDouble('turath_font_zoom_level') ?? 1.0;
      if (mounted) {
        setState(() => _fontScale = scale);
      }
    } catch (_) {}
  }

  Future<void> _setFontScale(double scale) async {
    setState(() => _fontScale = scale);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('turath_font_zoom_level', scale);
    } catch (_) {}
    if (_webController != null) {
      await _webController!.evaluateJavascript(
        source: 'if (typeof applyTurathFontScale === "function") { applyTurathFontScale($scale); }',
      );
    }
  }

  Future<void> _applyCurrentFontScale() async {
    if (_webController == null) return;
    try {
      await _webController!.evaluateJavascript(
        source: 'if (typeof applyTurathFontScale === "function") { applyTurathFontScale($_fontScale); }',
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    try {
      _webController?.stopLoading();
    } catch (_) {}
    _webController = null;
    super.dispose();
  }

  static const String _turatsMasterScript = r"""
    (function() {
      // 1. Injeksi Style CSS Penting
      var styleId = 'ot-hide-controls';
      var existingStyle = document.getElementById(styleId);
      if (!existingStyle) {
        var style = document.createElement('style');
        style.id = styleId;
        style.type = 'text/css';
        style.textContent = `
          top-bar, .top-bar, header, .header, .app-header, app-header,
          mat-toolbar, [role="banner"], .header-container, .header-row,
          div[class*="header" i], div[class*="top-bar" i], div[class*="topbar" i],
          labs-tailwind-logo, a.logo-link, .logo-container,
          a[aria-label*="Homepage" i], a[aria-label*="NotebookLM" i], a[aria-label*="Gemini" i],
          .title-input, input.title-input, .title-container, .notebook-title,
          .notebook-header, app-notebook-header, .title-card, mat-card.title-card,
          div[class*="title-card" i], div[class*="notebook-header" i],
          div[class*="source-summary" i], div[class*="source-count" i],
          div[class*="notebook-info" i], .project-header, div.source-badge-container,
          div[class*="notebook-title" i], [class*="artifact-card" i],
          .mobile-header, div[class*="mobile-header" i],
          button[aria-label*="Copy" i], button[aria-label*="Salin" i],
          button[aria-label*="Create" i], button[aria-label*="Buat" i],
          button[aria-label*="Settings" i], button[aria-label*="Setelan" i],
          button.mat-tonal-button, a[aria-label*="Google" i],
          .gb_C, #gb, #gbwa, .gb_9a, .gb_8, .gb_U, div[id*="gb"],
          .pro-badge {
            display: none !important;
            visibility: hidden !important;
            height: 0px !important;
            min-height: 0px !important;
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
          /* Subtle AI Disclaimer & Compliance (Transparent, Legal & Clean) */
          .disclaimer, [class*="disclaimer" i], [class*="footnote" i], .compliance-notice, .legal-text {
            color: #71717A !important;
            font-size: 11px !important;
            text-align: center !important;
            padding: 6px 12px !important;
            opacity: 0.8 !important;
            border: none !important;
          ::-webkit-scrollbar { display: none !important; width: 0px !important; height: 0px !important; }
          html, body, * { scrollbar-width: none !important; -ms-overflow-style: none !important; }
          /* Padding atas yang cukup agar pesan teratas tidak terpotong */
          .chat-panel-content, .chat-view, .conversation-container, .message-list, main {
            padding-top: 14px !important;
            margin-top: 0px !important;
          }
        `;
        (document.head || document.documentElement).appendChild(style);
      }

      // Helper untuk komunikasi aman ke Flutter
      function sendToFlutter(name, data) {
        if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
          window.flutter_inappwebview.callHandler(name, data);
        }
      }

      // 2. Sembunyikan Kartu Landing NotebookLM yang Memuat Metadata Teknis
      function sweepNotebookLandingCard() {
        try {
          var cards = document.querySelectorAll('mat-card, .mat-mdc-card, [role="region"], div[class*="card" i], div[class*="header" i], div[class*="title" i], div');
          for (var i = 0; i < cards.length; i++) {
            var el = cards[i];
            var txt = (el.innerText || '').toLowerCase();
            if ((txt.includes('sources ·') || txt.includes('0 sources') || txt.includes('super ai') || txt.includes('feb 22') || txt.includes('feb 2026')) && el.clientHeight < 450 && el.clientHeight > 20) {
              if (!el.querySelector('textarea, input, [role="article"]')) {
                el.style.setProperty('display', 'none', 'important');
                el.style.setProperty('visibility', 'hidden', 'important');
                el.style.setProperty('height', '0px', 'important');
                el.style.setProperty('overflow', 'hidden', 'important');
                el.style.setProperty('margin', '0px', 'important');
                el.style.setProperty('padding', '0px', 'important');
              }
            }
          }
        } catch(e) {}
      }

      // 3. Font scale
      window.applyTurathFontScale = function(scale) {
        var id = 'ot-font-scale-style';
        var st = document.getElementById(id);
        if (!st) {
          st = document.createElement('style');
          st.id = id;
          (document.head || document.documentElement).appendChild(st);
        }
        var pct = Math.round(scale * 100);
        var arPct = Math.round(scale * 125);
        st.textContent = `
          .chat-panel-content, .chat-view, .conversation-container, .message-list, p, span, li, blockquote, pre {
            font-size: ${pct}% !important;
            line-height: 1.6 !important;
          }
          [lang="ar"], .arabic, *[class*="arabic" i] {
            font-size: ${arPct}% !important;
          }
        `;
      };

      // 4. Observer Ringan dengan Debounce (Anti CPU Drain & Bebas Perulangan Berantai)
      sweepNotebookLandingCard();
      if (!window.__otMasterObserver) {
        var timeout = null;
        window.__otMasterObserver = new MutationObserver(function() {
          if (timeout) clearTimeout(timeout);
          timeout = setTimeout(function() {
            sweepNotebookLandingCard();
          }, 300);
        });
        window.__otMasterObserver.observe(document.documentElement || document.body, { childList: true, subtree: true });
      }
    })();
  """;

  static final _cloakScript = UserScript(
    source: _turatsMasterScript,
    injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_agent == null) {
      final rawArgs = ModalRoute.of(context)?.settings.arguments;
      if (rawArgs is Map<String, dynamic>) {
        _agent = rawArgs['agent'] as AgentModel?;
        _user = rawArgs['user'] as UserModel?;
      } else if (rawArgs is AgentModel) {
        _agent = rawArgs;
      }
      _agent ??= AgentModel.defaultAgents.first;
      _fetchAgentUrl();
    }
  }

  Future<void> _fetchAgentUrl() async {
    setState(() {
      _isLoadingUrl = true;
      _errorMessage = null;
    });

    // 0. Cek apakah modul masih berstatus 'coming_soon'
    if (_agent != null && _agent!.isComingSoon) {
      setState(() {
        _isLoadingUrl = false;
        _errorMessage = '${_agent!.title} belum tersedia (Segera Hadir) dan sedang dalam proses kurasi naskah kitab primer.';
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
        _errorMessage = 'Modul ${_agent!.title} memerlukan langganan aktif. Silakan pilih paket langganan untuk mengakses ruang riset.';
        _isLoadingUrl = false;
      });
      return;
    }

    try {
      final url = await _agentService.getAgentUrl(_agent!.id);
      if (!mounted) return;
      if (url == null || url.isEmpty) {
        setState(() {
          _errorMessage = 'URL riset tidak tersedia. Silakan hubungi pengelola.';
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
      if (e is AgentAccessException && (e.code == 'permission-denied' || e.code == 'unauthenticated')) {
        setState(() {
          _errorMessage = e.message;
          _isPaywallRequired = true;
          _isLoadingUrl = false;
        });
        return;
      }
      setState(() {
        _errorMessage = e is AgentAccessException
            ? e.message
            : 'Gagal memuat ruang riset. Silakan coba beberapa saat lagi.';
        _isPaywallRequired = false;
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
          if (bodyText.includes('You need access') || 
              bodyText.includes('You do not have access') || 
              bodyText.includes('Request access') ||
              document.querySelector('button[aria-label*="Request access"]') !== null ||
              document.querySelector('.auth-error') !== null) {
            return 'DENIED';
          }
          return 'OK';
        })();
      """);
      if (res == 'DENIED' && mounted) {
        setState(() {
          _isPaywallRequired = true;
          _isLoadingUrl = false;
          _isWebViewLoading = false;
          _errorMessage = 'Anda belum memiliki akses ke ruang riset ${_agent?.title ?? "ini"}. Silakan periksa atau aktifkan paket langganan Anda.';
        });
      }
    } catch (_) {}
  }

  Future<void> _applyHideScript() async {
    if (_webController == null) return;
    try {
      await _webController!.evaluateJavascript(source: _turatsMasterScript);
      await _applyThemeCss();
    } catch (_) {}
  }

  Future<void> _applyThemeCss() async {
    if (_webController == null) return;
    // We let InAppWebViewSettings.forceDark handle dark mode natively,
    // avoiding destructive DOM color injections that cause black-on-black text.
    try {
      await _applyCurrentFontScale();
    } catch (_) {}
  }

  Future<void> _copyLatestResponse() async {
    if (_webController == null) return;
    HapticFeedback.lightImpact();
    setState(() => _isCopying = true);

    try {
      final res = await _webController!.evaluateJavascript(source: """
        (function() {
          var selectors = [
            '.chat-message[data-sender="model"]',
            '.model-message',
            '.response-message',
            '.chat-panel-content .message:last-child',
            '[role="article"]:last-of-type',
            '.markdown-content:last-of-type',
            '.message:last-of-type'
          ];
          for (var i = 0; i < selectors.length; i++) {
            var els = document.querySelectorAll(selectors[i]);
            if (els.length > 0) {
              var lastEl = els[els.length - 1];
              var txt = (lastEl.innerText || lastEl.textContent || '').trim();
              if (txt.length > 10) return txt;
            }
          }
          var main = document.querySelector('main, .chat-panel-content, .conversation-container');
          return main ? (main.innerText || main.textContent || '').trim() : '';
        })();
      """);

      final text = (res as String? ?? '').trim();
      if (text.isEmpty) {
        if (mounted) {
          AppSnackBar.warning(context, 'Belum ada jawaban AI yang dapat disalin.');
        }
      } else {
        await Clipboard.setData(ClipboardData(text: text));
        if (mounted) {
          setState(() => _hasCopied = true);
          AppSnackBar.success(context, 'Hasil telaah AI berhasil disalin!');
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) setState(() => _hasCopied = false);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, 'Tidak dapat menyalin telaah saat ini. Silakan coba kembali.');
      }
    } finally {
      if (mounted) setState(() => _isCopying = false);
    }
  }

  Future<void> _bookmarkLatestResponse() async {
    if (_webController == null) return;
    HapticFeedback.mediumImpact();
    setState(() => _isBookmarking = true);

    try {
      final res = await _webController!.evaluateJavascript(source: """
        (function() {
          var selectors = [
            '.chat-message[data-sender="model"]',
            '.model-message',
            '.response-message',
            '.chat-panel-content .message:last-child',
            '[role="article"]:last-of-type',
            '.markdown-content:last-of-type',
            '.message:last-of-type'
          ];
          var answer = '';
          for (var i = 0; i < selectors.length; i++) {
            var els = document.querySelectorAll(selectors[i]);
            if (els.length > 0) {
              var lastEl = els[els.length - 1];
              answer = (lastEl.innerText || lastEl.textContent || '').trim();
              if (answer.length > 10) break;
            }
          }

          var arabicMatch = answer.match(/[\\u0600-\\u06FF\\u0750-\\u077F\\u08A0-\\u08FF\\uFB50-\\uFDFF\\uFE70-\\uFEFF]{15,}/g);
          var arabicExcerpt = arabicMatch ? arabicMatch.slice(0, 3).join(' ... ') : '';

          return JSON.stringify({
            fullAnswer: answer,
            arabicExcerpt: arabicExcerpt
          });
        })();
      """);

      if (res != null) {
        final Map<String, dynamic> data = jsonDecode(res.toString());
        final fullAnswer = (data['fullAnswer'] as String? ?? '').trim();
        final arabicExcerpt = (data['arabicExcerpt'] as String? ?? '').trim();

        if (fullAnswer.isEmpty) {
          if (mounted) {
            AppSnackBar.warning(context, 'Belum ada telaah AI yang dapat disimpan.');
          }
        } else {
          final bookmark = BookmarkModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'Telaah ${_agent?.title ?? "Naskah Turats"}',
            agentId: _agent?.id ?? 'umum',
            agentTitle: _agent?.title ?? 'Kutubut Turats',
            fieldName: _agent?.category ?? 'Fikih',
            fieldId: (_agent?.category ?? 'fikih').toLowerCase().replaceAll(' ', '_'),
            arabicExcerpt: arabicExcerpt,
            fullAnswer: fullAnswer,
            bookReference: _agent?.title ?? 'Kutubut Turats',
            pageNumber: '',
            createdAt: DateTime.now(),
          );

          await _bookmarkService.addBookmark(bookmark);
          if (mounted) {
            setState(() => _hasBookmarked = true);
            AppSnackBar.success(
              context,
              'Telaah tersimpan di Bookmark!',
              action: SnackBarAction(
                label: 'Lihat',
                textColor: Colors.white,
                onPressed: () => Navigator.pushNamed(context, AppRoutes.bookmark),
              ),
            );
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) setState(() => _hasBookmarked = false);
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, 'Tidak dapat menyimpan bookmark saat ini. Silakan coba kembali.');
      }
    } finally {
      if (mounted) setState(() => _isBookmarking = false);
    }
  }

  Future<void> _handleBackPress() async {
    HapticFeedback.lightImpact();
    if (_webController != null && await _webController!.canGoBack()) {
      await _webController!.goBack();
    } else {
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }



  @override
  Widget build(BuildContext context) {
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
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _agent?.title ?? 'Ruang Riset AI',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: OTTypography.corpusTitle(color: textPrimary).copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Ruang Telaah Naskah Primer',
                style: OTTypography.caption(color: textSecondary).copyWith(fontSize: 11),
              ),
            ],
          ),
          actions: [
            if (_user != null && _user!.plan == 'trial')
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Center(
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.subscription,
                        arguments: {'agent': _agent, 'user': _user},
                      );
                    },
                    borderRadius: OTRadius.chipBorder,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                            style: OTTypography.caption(color: textPrimary).copyWith(
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
              icon: Icon(Icons.more_horiz_rounded, color: textPrimary, size: 22),
              tooltip: 'Opsi Riset',
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
                  color: isDark ? const Color(0xFF0E0E10) : const Color(0xFFFFFFFF),
                  child: InAppWebView(
                    initialUrlRequest: URLRequest(url: WebUri(_agentUrl!)),
                    initialUserScripts: UnmodifiableListView<UserScript>([_cloakScript]),
                    initialSettings: InAppWebViewSettings(
                      userAgent: AppConstants.chromeMobileUserAgent,
                      javaScriptEnabled: true,
                      domStorageEnabled: true,
                      databaseEnabled: true,
                      sharedCookiesEnabled: true,
                      thirdPartyCookiesEnabled: true,
                      cacheEnabled: true,
                      clearCache: false,
                      clearSessionCache: false,
                      useHybridComposition: true,
                      mixedContentMode: MixedContentMode.MIXED_CONTENT_NEVER_ALLOW,
                      allowFileAccess: false,
                      allowContentAccess: true,
                      javaScriptCanOpenWindowsAutomatically: true,
                      supportZoom: true,
                      builtInZoomControls: true,
                      displayZoomControls: false,
                      mediaPlaybackRequiresUserGesture: false,
                      allowsInlineMediaPlayback: true,
                      forceDark: isDark ? ForceDark.ON : ForceDark.OFF,
                      algorithmicDarkeningAllowed: false,
                      transparentBackground: true,
                    ),
                onWebViewCreated: (controller) {
                  _webController = controller;

                  // Injeksi Callback Simpan Bookmark Langsung dari Respon AI
                  controller.addJavaScriptHandler(
                    handlerName: 'onSaveBookmark',
                    callback: (args) async {
                      if (args.isNotEmpty && args[0] is Map) {
                        final map = Map<String, dynamic>.from(args[0] as Map);
                        final fullAnswer = (map['fullAnswer'] as String? ?? '').trim();
                        final arabicExcerpt = (map['arabicExcerpt'] as String? ?? '').trim();
                        final question = (map['question'] as String? ?? '').trim();

                        if (fullAnswer.isEmpty) {
                          if (context.mounted) {
                            AppSnackBar.show(
                              context,
                              message: 'Tidak dapat menyimpan telaah kosong',
                              type: SnackType.error,
                            );
                          }
                          return;
                        }

                        final title = question.isNotEmpty
                            ? (question.length > 55 ? '${question.substring(0, 52)}...' : question)
                            : (_agent?.title != null ? 'Telaah ${_agent!.title}' : 'Telaah Naskah Turats');

                        final category = _agent?.category ?? 'Fikih';

                        final bookmark = BookmarkModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: title,
                          agentId: _agent?.id ?? 'umum',
                          agentTitle: _agent?.title ?? 'Kutubut Turats',
                          fieldName: category,
                          fieldId: category.toLowerCase().replaceAll(' ', '_'),
                          arabicExcerpt: arabicExcerpt,
                          fullAnswer: fullAnswer,
                          bookReference: _agent?.title ?? 'Kutubut Turats',
                          pageNumber: '',
                          createdAt: DateTime.now(),
                        );

                        await _bookmarkService.addBookmark(bookmark);
                        if (context.mounted) {
                          AppSnackBar.show(
                            context,
                            message: 'Telaah tersimpan di Bookmark',
                            type: SnackType.success,
                            action: SnackBarAction(
                              label: 'Lihat',
                              textColor: Colors.white,
                              onPressed: () => Navigator.pushNamed(context, AppRoutes.bookmark),
                            ),
                          );
                        }
                      }
                    },
                  );

                  // Callback Konfirmasi Salin Teks
                  controller.addJavaScriptHandler(
                    handlerName: 'onCopySuccess',
                    callback: (args) {
                      if (mounted) {
                        AppSnackBar.show(
                          context,
                          message: 'Hasil telaah AI berhasil disalin',
                          type: SnackType.info,
                        );
                      }
                    },
                  );
                },
                onPermissionRequest: (controller, request) async {
                  final isAudio = request.resources.contains(PermissionResourceType.MICROPHONE);
                  return PermissionResponse(
                    resources: request.resources,
                    action: isAudio ? PermissionResponseAction.GRANT : PermissionResponseAction.DENY,
                  );
                },
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  final uri = navigationAction.request.url;
                  if (uri == null) return NavigationActionPolicy.ALLOW;

                  // Wajib skema HTTPS
                  if (uri.scheme != 'https') {
                    return NavigationActionPolicy.CANCEL;
                  }

                  final host = uri.host.toLowerCase();
                  const allowedDomains = [
                    'google.com',
                    'gstatic.com',
                    'googleapis.com',
                    'googleusercontent.com',
                  ];
                  final isAllowed = allowedDomains.any((d) => host == d || host.endsWith('.$d'));
                  if (isAllowed) {
                    return NavigationActionPolicy.ALLOW;
                  }

                  try {
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                      return NavigationActionPolicy.CANCEL;
                    }
                  } catch (_) {}
                  return NavigationActionPolicy.CANCEL;
                },
                onLoadStop: (controller, url) async {
                  await _applyHideScript();
                  await _applyCurrentFontScale();
                  await _detectGoogleAccessDenied();
                  if (mounted && _isWebViewLoading) {
                    setState(() => _isWebViewLoading = false);
                  }
                },
                onProgressChanged: (controller, progress) async {
                  if (progress >= 25) {
                    await _applyHideScript();
                    await _detectGoogleAccessDenied();
                  }
                  if (progress >= 45) {
                    await _detectGoogleAccessDenied();
                    if (_isWebViewLoading && mounted) {
                      setState(() => _isWebViewLoading = false);
                    }
                  }
                },
                onReceivedError: (controller, request, error) {
                  if (mounted && (request.isForMainFrame == true)) {
                    setState(() {
                      _isWebViewLoading = false;
                      _errorMessage = 'Tidak dapat memuat sesi riset. Periksa koneksi internet Anda lalu coba kembali.';
                    });
                  }
                },
              ),
            ),

            // ── Loading Indicator Screen (Unified Three Dots Minimal Pulse) ──
            if (_isLoadingUrl || (_isWebViewLoading && _errorMessage == null))
              Positioned.fill(
                child: AppLoader.fullscreen(
                  title: _agent?.title ?? 'Ruang Riset Turats',
                  subtitle: 'Menyiapkan korpus naskah primer...',
                  onCancel: _handleBackPress,
                ),
              ),

            // ── 2. Error State Screen (Unified AppErrorState) ──
            if (_errorMessage != null && !_isLoadingUrl)
              Positioned.fill(
                child: Container(
                  color: canvas,
                  child: AppErrorState(
                    title: _isPaywallRequired
                        ? 'Akses Berlangganan Diperlukan'
                        : 'Kendala Memuat Ruang Riset',
                    message: _errorMessage!,
                    icon: _isPaywallRequired
                        ? Icons.workspace_premium_rounded
                        : Icons.info_outline_rounded,
                    onRetry: _isPaywallRequired
                        ? () {
                            final fbUser = FirebaseAuth.instance.currentUser;
                            final user = fbUser != null
                                ? UserModel(
                                    uid: fbUser.uid,
                                    email: fbUser.email ?? '',
                                    name: fbUser.displayName ?? 'Peneliti Turats',
                                    photoUrl: fbUser.photoURL ?? '',
                                    plan: 'trial',
                                    questionsUsed: 0,
                                  )
                                : null;
                            Navigator.pushNamed(
                              context,
                              AppRoutes.subscription,
                              arguments: {
                                'agent': _agent,
                                'user': user,
                              },
                            );
                          }
                        : _fetchAgentUrl,
                    retryLabel: _isPaywallRequired
                        ? 'Buka Paket Langganan'
                        : 'Coba Muat Ulang',
                    onBack: () => Navigator.pop(context),
                    backLabel: 'Kembali ke Beranda',
                  ),
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
    final surface = isDark ? AppTheme.surfaceCardDark : AppTheme.surfaceCardLight;
    final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final textPrimary = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: surface,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                        color: isDark ? AppTheme.borderDark : AppTheme.pillSecondaryBgLight,
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
                        'Adab Riset & Penafian Talaqqi',
                        style: GoogleFonts.newsreader(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, size: 20, color: textSecondary),
                      onPressed: () => Navigator.pop(dialogCtx),
                      splashRadius: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'التعلم بالتلقي عن الأشياخ هو الأصل',
                  style: GoogleFonts.amiri(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFFD4D4D8) : const Color(0xFF3F3F46),
                  ),
                ),
                const SizedBox(height: 14),
                Divider(height: 1, color: border),
                const SizedBox(height: 14),
                _buildAdabPoint(
                  icon: Icons.menu_book_outlined,
                  title: 'Wasilah Bantu, Bukan Mufti',
                  description:
                      'OpenTurath adalah perkakas digital pelacak ibarah dan komparasi naskah primer kitab kuning, bukan mufti fatwa mandiri.',
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _buildAdabPoint(
                  icon: Icons.people_outline_rounded,
                  title: 'Kewajiban Talaqqi Bersanad',
                  description:
                      'Kajian agama hakiki wajib melalui bimbingan talaqqi dengan masyayikh dan ulama yang kompeten.',
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _buildAdabPoint(
                  icon: Icons.fact_check_outlined,
                  title: 'Sikap Ihtiyath (Wara\')',
                  description:
                      'Selalu verifikasi dalil dan ibarah ke naskah fisik cetakan mu\'tamad sebelum menjadikannya landasan kajian.',
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
                      backgroundColor: isDark ? Colors.white : const Color(0xFF18181B),
                      foregroundColor: isDark ? const Color(0xFF0E0E10) : Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                      ),
                    ),
                    child: Text(
                      'Saya Memahami & Menjaga Adab',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
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
          child: Icon(icon, size: 16, color: isDark ? Colors.white : const Color(0xFF18181B)),
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

    showModalBottomSheet<void>(
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
              'Opsi Ruang Riset',
              style: OTTypography.corpusTitle(color: textPrimary).copyWith(fontSize: 18),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Icon(Icons.format_size_rounded, color: textPrimary, size: 20),
              title: Text('Ukuran Teks Telaah', style: OTTypography.bodyMedium(color: textPrimary)),
              subtitle: Text('Sesuaikan ukuran huruf naskah (${(_fontScale * 100).round()}%)', style: OTTypography.caption(color: textSecondary)),
              onTap: () {
                Navigator.pop(ctx);
                _showFontScalePicker();
              },
            ),
            Divider(height: 1, color: border.withValues(alpha: 0.5)),
            ListTile(
              leading: Icon(_hasCopied ? Icons.check_circle_rounded : Icons.copy_rounded, color: _hasCopied ? OTColors.success : textPrimary, size: 20),
              title: Text('Salin Jawaban AI Terakhir', style: OTTypography.bodyMedium(color: textPrimary)),
              subtitle: Text('Salin teks hasil telaah ke papan klip', style: OTTypography.caption(color: textSecondary)),
              onTap: _isCopying
                  ? null
                  : () {
                      Navigator.pop(ctx);
                      _copyLatestResponse();
                    },
            ),
            Divider(height: 1, color: border.withValues(alpha: 0.5)),
            ListTile(
              leading: Icon(_hasBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, color: _hasBookmarked ? OTColors.sovereignAmber : textPrimary, size: 20),
              title: Text('Simpan ke Rujukan', style: OTTypography.bodyMedium(color: textPrimary)),
              subtitle: Text('Tandai dan simpan ibarah ke koleksi rujukan Anda', style: OTTypography.caption(color: textSecondary)),
              onTap: _isBookmarking
                  ? null
                  : () {
                      Navigator.pop(ctx);
                      _bookmarkLatestResponse();
                    },
            ),
            Divider(height: 1, color: border.withValues(alpha: 0.5)),
            ListTile(
              leading: Icon(Icons.open_in_browser_rounded, color: textPrimary, size: 20),
              title: Text('Buka di Browser Eksternal', style: OTTypography.bodyMedium(color: textPrimary)),
              subtitle: Text('Buka sesi riset di peramban web perangkat', style: OTTypography.caption(color: textSecondary)),
              onTap: () async {
                Navigator.pop(ctx);
                if (_agentUrl != null) {
                  final uri = Uri.parse(_agentUrl!);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                }
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

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
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
                    'Ukuran Teks Telaah',
                    style: OTTypography.corpusTitle(color: textPrimary).copyWith(fontSize: 17),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sesuaikan ukuran huruf naskah dan terjemahan untuk kenyamanan membaca',
                    style: OTTypography.caption(color: textSecondary),
                  ),
                  const SizedBox(height: 14),
                  _buildScaleOption(ctx, label: 'Ringkas (85%)', scale: 0.85, isDark: isDark),
                  _buildScaleOption(ctx, label: 'Normal (100%)', scale: 1.0, isDark: isDark),
                  _buildScaleOption(ctx, label: 'Sedang (120%)', scale: 1.20, isDark: isDark),
                  _buildScaleOption(ctx, label: 'Besar (140%)', scale: 1.40, isDark: isDark),
                  _buildScaleOption(ctx, label: 'Ekstra Besar (165%)', scale: 1.65, isDark: isDark),
                  _buildScaleOption(ctx, label: 'Maksimal Naskah (200%)', scale: 2.00, isDark: isDark),
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
        style: OTTypography.body(color: isSelected ? accent : textPrimary).copyWith(
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


