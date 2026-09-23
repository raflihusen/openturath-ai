import '../services/desktop_webview_runtime.dart';
import '../widgets/desktop_webview_gate.dart';
import '../core/app_platform.dart';
import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_copy.dart';
import '../core/app_snackbar.dart';
import '../core/navigation_guard.dart';
import '../core/routes.dart';
import '../core/constants.dart';
import '../core/notebook_navigation.dart';
import '../core/notebook_ui_script.dart';
import '../core/copied_answer.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_motion.dart';
import '../core/design/ot_typography.dart';
import '../core/scholarly_fonts.dart';
import '../models/agent_model.dart';
import '../services/agent_service.dart';
import '../services/native_agent_launcher.dart';
import '../services/agent_session_manager.dart';
import '../services/auth_service.dart';
import '../services/bookmark_service.dart';
import '../widgets/app_error_state.dart';
import '../widgets/app_loader.dart';
import '../widgets/library_bottom_sheet.dart';

/// AgentMultiTabRoom: Persistent, multi-tab AI Study Room inspired by Google Chrome tabs.
/// Keeps up to 7 AI specialists running concurrently in memory without reloading.
class AgentMultiTabRoom extends StatefulWidget {
  const AgentMultiTabRoom({super.key});

  @override
  State<AgentMultiTabRoom> createState() => _AgentMultiTabRoomState();
}

class _AgentMultiTabRoomState extends State<AgentMultiTabRoom> {
  final AgentSessionManager _sessionManager = AgentSessionManager.instance;
  final BookmarkService _bookmarkService = BookmarkService();
  final AuthService _authService = AuthService();

  Future<void> _copyActiveConversation(AgentSessionTab session) async {
    final controller = session.webController;
    if (controller == null) return;
    try {
      final result = await controller.evaluateJavascript(
        source: 'window.otNotebook ? window.otNotebook.conversation() : ""',
      );
      final text = result is String ? result.trim() : '';
      if (text.isEmpty) {
        if (mounted) AppSnackBar.warning(context, AppCopy.noConversationToCopy);
        return;
      }
      final formatted = text;
      // 1. Simpan langsung ke Catatan (Bookmarks)
      final uid = _authService.currentUser?.uid;
      final bookmark = copiedAnswerBookmark(formatted, session.agent);
      await _bookmarkService.addBookmark(bookmark, userId: uid);

      // 2. Salin ke clipboard perangkat
      await Clipboard.setData(ClipboardData(text: formatted));

      if (mounted) {
        OTMotion.success();
        AppSnackBar.success(context, AppCopy.conversationCopied);
      }
    } catch (_) {
      if (mounted) AppSnackBar.error(context, AppCopy.copyFailed);
    }
  }

  @override
  void initState() {
    super.initState();
    _sessionManager.addListener(_onSessionsChanged);
  }

  @override
  void dispose() {
    _sessionManager.removeListener(_onSessionsChanged);
    super.dispose();
  }

  void _onSessionsChanged() {
    if (mounted) setState(() {});
  }

  void _openLibrarySheet(BuildContext context, AgentModel agent) {
    showResearchLibrary(context, agent: agent);
  }

  void _showFontScaleDialog(BuildContext context, AgentSessionTab session) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = OTColors.surface(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final border = OTColors.border(isDark);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            decoration: BoxDecoration(
              color: surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border.all(color: border, width: 0.8),
            ),
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
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  AppCopy.studyOptions,
                  style: OTTypography.cardTitle(color: textPrimary)
                      .copyWith(fontSize: 17),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sesuaikan ukuran huruf percakapan agar nyaman dibaca.',
                  style: OTTypography.caption(color: textSecondary),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text('A',
                        style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textSecondary)),
                    Expanded(
                      child: Slider(
                        value: session.fontScale,
                        min: 0.85,
                        max: 1.6,
                        divisions: 5,
                        activeColor: textPrimary,
                        inactiveColor: OTColors.border(isDark),
                        onChanged: (val) {
                          setModalState(() => session.fontScale = val);
                          session.webController?.evaluateJavascript(
                            source:
                                'if (typeof applyTurathFontScale === "function") { applyTurathFontScale($val); }',
                          );
                        },
                      ),
                    ),
                    Text('A',
                        style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textPrimary)),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(height: 1, thickness: 0.8, color: border),
                const SizedBox(height: 16),
                Text(
                  'Bahasa Output Jawaban',
                  style: OTTypography.cardTitle(color: textPrimary)
                      .copyWith(fontSize: 15),
                ),
                const SizedBox(height: 6),
                Text(
                  'Atur bahasa jawaban asisten keilmuan (mendukung 50+ bahasa).',
                  style: OTTypography.caption(color: textSecondary),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      session.webController?.evaluateJavascript(
                        source: 'if (typeof otOpenLanguageSettings === "function") { otOpenLanguageSettings(); }',
                      );
                    },
                    icon: Icon(Icons.translate_rounded, size: 18, color: textPrimary),
                    label: Text(
                      'Ganti Bahasa Output (50+ Bahasa)',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: textPrimary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: border, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvas = OTColors.canvas(isDark);
    final surface = OTColors.surface(isDark);
    final surfaceSubtle = OTColors.surfaceSubtle(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    final activeTab = _sessionManager.activeTab;
    final sessions = _sessionManager.tabs;

    if (activeTab == null || sessions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        toolbarHeight: 56,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: canvas,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary, size: 22),
          tooltip: 'Kembali ke Beranda',
          onPressed: () {
            AppSnackBar.clear(context);
            _sessionManager.closeRoom();
          },
        ),
        titleSpacing: 0,
        title: Text(
          activeTab.agent.title,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            letterSpacing: -0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (AppPlatform.isDesktop)
            IconButton(
              tooltip: 'Buka NotebookLM di browser',
              icon: const Icon(Icons.open_in_browser_rounded),
              onPressed: () async {
                final url = activeTab.resolvedUrl;
                final opened = url != null && await NativeAgentLauncher.launchNotebook(url);
                if (!opened && context.mounted) {
                  AppSnackBar.warning(context, url == null
                      ? 'Tunggu hingga asisten selesai dihubungkan.' : 'Browser belum dapat dibuka.');
                }
              },
            ),
          IconButton(
            icon: Icon(Icons.menu_book_outlined, color: textPrimary, size: 20),
            tooltip: AppCopy.referenceBooks,
            onPressed: () => _openLibrarySheet(context, activeTab.agent),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: textPrimary, size: 20),
            tooltip: AppCopy.studyOptions,
            color: surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: border, width: 0.8),
            ),
            onSelected: (val) {
              if (val == 'conversation') {
                _copyActiveConversation(activeTab);
              } else if (val == 'font') {
                _showFontScaleDialog(context, activeTab);
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'conversation',
                child: Row(
                  children: [
                    Icon(Icons.content_copy_rounded,
                        color: textPrimary, size: 18),
                    const SizedBox(width: 12),
                    Text(AppCopy.copyConversationAction,
                        style: OTTypography.body(color: textPrimary)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'font',
                child: Row(
                  children: [
                    Icon(Icons.format_size_rounded,
                        color: textPrimary, size: 18),
                    const SizedBox(width: 12),
                    Text('Ukuran huruf',
                        style: OTTypography.body(color: textPrimary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
        // Chrome-like Multi-Tab Bar (Hanya tampil jika terdapat lebih dari 1 sesi aktif)
        bottom: sessions.length > 1
            ? PreferredSize(
                preferredSize: const Size.fromHeight(42),
                child: Container(
                  height: 42,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: surfaceSubtle,
                    border: Border(
                      top: BorderSide(color: border, width: 0.8),
                      bottom: BorderSide(color: border, width: 0.8),
                    ),
                  ),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    itemCount: sessions.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      final isActive = index == _sessionManager.activeIndex;

                      return Container(
                        decoration: BoxDecoration(
                          color: isActive ? surface : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isActive ? border : Colors.transparent,
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Area klik tab untuk berpindah asisten
                            InkWell(
                              onTap: () {
                                AppSnackBar.clear(context);
                                _sessionManager.selectTab(index);
                              },
                              borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline_rounded,
                                      size: 13,
                                      color: isActive ? textPrimary : textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      session.agent.title.replaceFirst('AI ', ''),
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                                        color: isActive ? textPrimary : textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Tombol tutup tab terpisah tanpa nesting InkWell
                            Semantics(
                              label: 'Tutup tab ${session.agent.title}',
                              button: true,
                              child: Material(
                                color: Colors.transparent,
                                child: InkResponse(
                                  onTap: () {
                                    AppSnackBar.clear(context);
                                    _sessionManager.closeTab(index);
                                  },
                                  radius: 18,
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 15,
                                      color: textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 2),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              )
            : null,
      ),
      body: IndexedStack(
        index: _sessionManager.activeIndex,
        children: [
          for (int i = 0; i < sessions.length; i++)
            _SingleAgentTabWebView(
              key: ValueKey('agent_tab_${sessions[i].agent.id}'),
              session: sessions[i],
              isActive: i == _sessionManager.activeIndex,
            ),
        ],
      ),
    );
  }
}

/// Single AI specialist WebView within the multi-tab IndexedStack.
/// Preserves full state, DOM, and JavaScript execution in memory.
class _SingleAgentTabWebView extends StatefulWidget {
  final AgentSessionTab session;
  final bool isActive;

  const _SingleAgentTabWebView({
    super.key,
    required this.session,
    required this.isActive,
  });

  @override
  State<_SingleAgentTabWebView> createState() => _SingleAgentTabWebViewState();
}

class _SingleAgentTabWebViewState extends State<_SingleAgentTabWebView>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  final AgentService _agentService = AgentService();
  final BookmarkService _bookmarkService = BookmarkService();
  final AuthService _authService = AuthService();

  @override
  bool get wantKeepAlive => true;

  static const String _turatsMasterScript = r"""
    (function() {
      if (window.top !== window || !['notebooklm.google.com', 'notebook.google.com'].includes(location.hostname)) return;

      var styleId = 'ot-hide-controls';
      var existingStyle = document.getElementById(styleId);
      if (!existingStyle) {
        var style = document.createElement('style');
        style.id = styleId;
        style.type = 'text/css';
        style.textContent = `
          top-bar, .top-bar, header, .header, .app-header, app-header,
          mat-toolbar, [role="banner"], .header-container, .header-row,
          .mobile-header, div[class*="mobile-header" i],
          labs-tailwind-logo, a.logo-link, .logo-container,
          a[aria-label*="Homepage" i], a[aria-label*="NotebookLM" i], a[aria-label*="Gemini" i],
          .title-input, input.title-input, .title-container, .notebook-title,
          .notebook-header, app-notebook-header, app-project-header,
          .title-card, mat-card.title-card,
          div[class*="title-card" i], div[class*="notebook-header" i],
          .project-header, div[class*="project-header" i], div.source-badge-container,
          .pro-badge,
          #gb, #gbwa, .gb_C, .gb_9a, .gb_8, .gb_U, div[id*="gb"], div[class*="gb_"],
          button[aria-label*="Settings" i], button[aria-label*="Setelan" i],
          button[aria-label*="More" i], button[aria-label*="Opsi" i],
          button[aria-label*="options" i], button[aria-label*="Notebook options" i],
          button[aria-label*="Option" i],
          button.mat-tonal-button, a[aria-label*="Google" i],
          [aria-label*="Google Account" i], [aria-label*="Akun Google" i],
          footer, div[class*="footer" i],
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
          .chat-disclaimer, .query-disclaimer, .model-disclaimer,
          [class*="disclaimer" i], [aria-label*="disclaimer" i],
          [data-testid*="disclaimer" i] {
            display: block !important;
            visibility: visible !important;
            font-size: 11px !important;
            line-height: 1.4 !important;
            opacity: 0.65 !important;
            text-align: center !important;
            margin: 4px 0 8px 0 !important;
            pointer-events: auto !important;
          }
          ::-webkit-scrollbar { display: none !important; width: 0px !important; }
          html, body, * { scrollbar-width: none !important; }
          .chat-panel-content, .chat-view, .conversation-container, .message-list, main {
            padding-top: 14px !important;
            padding-bottom: 24px !important;
            margin-top: 0px !important;
          }
        `;
        (document.head || document.documentElement).appendChild(style);
      }

      window.otOpenLanguageSettings = function() {
        var btn = document.querySelector('button[aria-label*="Settings" i], button[aria-label*="Setelan" i], button[aria-label*="Notebook settings" i]');
        if (btn) {
          btn.click();
        } else {
          var anyBtn = document.querySelector('button[aria-label*="options" i], button[aria-label*="More" i]');
          if (anyBtn) anyBtn.click();
        }
      };

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
          [lang="ar"], .arabic, [dir="rtl"] {
            font-family: 'Scheherazade New', 'Traditional Arabic', serif !important;
            font-size: ${Math.round(scale * 19)}px !important;
            line-height: 1.8 !important;
          }
        `;
      };
    })();
  """;

  static UserScript _buildCloakScript(bool isDark) {
    final themeInitScript = '''
      (function() {
        try {
          window._otIsDark = $isDark;
          var meta = document.querySelector('meta[name="color-scheme"]');
          if (!meta) {
            meta = document.createElement('meta');
            meta.name = 'color-scheme';
            (document.head || document.documentElement).appendChild(meta);
          }
          meta.content = ${isDark ? "'dark'" : "'light'"};

          var oldStyle = document.getElementById('ot-native-dark-mode');
          if (oldStyle) oldStyle.remove();

          if (document.documentElement) {
            document.documentElement.classList.toggle('dark', $isDark);
            document.documentElement.classList.toggle('dark-theme', $isDark);
            document.documentElement.setAttribute('data-theme', ${isDark ? "'dark'" : "'light'"});
            document.documentElement.style.colorScheme = ${isDark ? "'dark'" : "'light'"};
          }
          if (document.body) {
            document.body.classList.toggle('dark', $isDark);
            document.body.classList.toggle('dark-theme', $isDark);
            document.body.setAttribute('data-theme', ${isDark ? "'dark'" : "'light'"});
            document.body.style.colorScheme = ${isDark ? "'dark'" : "'light'"};
          }

          var canvasStyleId = 'ot-theme-canvas-style';
          var styleEl = document.getElementById(canvasStyleId);
          if (!styleEl) {
            styleEl = document.createElement('style');
            styleEl.id = canvasStyleId;
            (document.head || document.documentElement).appendChild(styleEl);
          }
          styleEl.textContent = ${isDark ? "'html, body { background-color: #202124 !important; color: #E4E4E7 !important; }'" : "'html, body { background-color: #FFFFFF !important; color: #18181B !important; }'"};

          if (window.otNotebook && typeof window.otNotebook.setTheme === 'function') {
            window.otNotebook.setTheme($isDark);
          }
        } catch(e) {}
      })();
    ''';

    return UserScript(
      source:
          'window._otIsDark = $isDark;\n$_turatsMasterScript$notebookUiScript$themeInitScript',
      injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
      forMainFrameOnly: true,
    );
  }

  Timer? _readinessTimer;
  DateTime? _loadingStarted;
  int _readySamples = 0;
  bool _checkingReady = false;
  bool? _lastIsDark;
  DateTime? _lastCopiedToastAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.session.resolvedUrl == null) {
      _fetchUrl();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _readinessTimer?.cancel();
    if (mounted) {
      AppSnackBar.clear(context);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (AppPlatform.isAndroid) {
        unawaited(widget.session.webController?.resume().catchError((Object _) {}) ?? Future<void>.value());
      }
      _verifySurfaceHealth();
    } else if (state == AppLifecycleState.paused) {
      if (AppPlatform.isAndroid) {
        unawaited(widget.session.webController?.pause().catchError((Object _) {}) ?? Future<void>.value());
      }
    }
  }

  Future<void> _verifySurfaceHealth() async {
    final controller = widget.session.webController;
    if (controller == null || !mounted) return;
    try {
      final res = await controller.evaluateJavascript(source: '1+1');
      if (res != 2) {
        controller.reload();
      }
    } catch (_) {
      controller.reload();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentIsDark = Theme.of(context).brightness == Brightness.dark;
    if (_lastIsDark != null && _lastIsDark != currentIsDark) {
      widget.session.webController?.setSettings(
        settings: InAppWebViewSettings(
          forceDark: currentIsDark ? ForceDark.ON : ForceDark.OFF,
          forceDarkStrategy:
              ForceDarkStrategy.PREFER_WEB_THEME_OVER_USER_AGENT_DARKENING,
          algorithmicDarkeningAllowed: true,
        ),
      );
      _applyThemeCss(currentIsDark);
    }
    _lastIsDark = currentIsDark;
  }

  Future<void> _applyThemeCss(bool isDark) async {
    final controller = widget.session.webController;
    if (controller == null) return;
    try {
      final js = '''
        (function() {
          try {
            window._otIsDark = $isDark;
            var meta = document.querySelector('meta[name="color-scheme"]');
            if (!meta) {
              meta = document.createElement('meta');
              meta.name = 'color-scheme';
              (document.head || document.documentElement).appendChild(meta);
            }
            meta.content = ${isDark ? "'dark'" : "'light'"};

            var oldStyle = document.getElementById('ot-native-dark-mode');
            if (oldStyle) oldStyle.remove();

            if (document.documentElement) {
              document.documentElement.classList.toggle('dark', $isDark);
              document.documentElement.classList.toggle('dark-theme', $isDark);
              document.documentElement.setAttribute('data-theme', ${isDark ? "'dark'" : "'light'"});
              document.documentElement.style.colorScheme = ${isDark ? "'dark'" : "'light'"};
            }
            if (document.body) {
              document.body.classList.toggle('dark', $isDark);
              document.body.classList.toggle('dark-theme', $isDark);
              document.body.setAttribute('data-theme', ${isDark ? "'dark'" : "'light'"});
              document.body.style.colorScheme = ${isDark ? "'dark'" : "'light'"};
            }

            var canvasStyleId = 'ot-theme-canvas-style';
            var styleEl = document.getElementById(canvasStyleId);
            if (!styleEl) {
              styleEl = document.createElement('style');
              styleEl.id = canvasStyleId;
              (document.head || document.documentElement).appendChild(styleEl);
            }
            styleEl.textContent = ${isDark ? "'html, body { background-color: #202124 !important; color: #E4E4E7 !important; }'" : "'html, body { background-color: #FFFFFF !important; color: #18181B !important; }'"};

            if (window.otNotebook && typeof window.otNotebook.setTheme === 'function') {
              window.otNotebook.setTheme($isDark);
            }
          } catch(e) {}
        })();
      ''';
      await controller.evaluateJavascript(source: js);
    } catch (_) {}
  }

  void _startReadinessCheck() {
    _readinessTimer?.cancel();
    _loadingStarted = DateTime.now();
    _readySamples = 0;
    _readinessTimer =
        Timer.periodic(const Duration(milliseconds: 500), (_) => _checkReady());
  }

  void _handleAccessDenied(AgentSessionTab session) {
    _readinessTimer?.cancel();
    final user = _authService.cachedCurrentUser;
    final hasSubscription =
        user != null && user.hasAccessToAgent(session.agent.id);

    if (mounted) {
      setState(() {
        session.isWebLoading = false;
        session.isSessionReady = false;
        if (hasSubscription) {
          session.isGooglePermissionError = true;
          session.isPaywallRequired = false;
          session.isTimeoutError = false;
          session.errorMessage =
              'Akun Google ini belum dapat membuka asisten. Gunakan akun Google yang sudah dihubungkan dengan OpenTurath.';
        } else {
          session.isGooglePermissionError = false;
          session.isPaywallRequired = true;
          session.isTimeoutError = false;
          session.errorMessage =
              'Akses untuk asisten ini memerlukan langganan aktif.';
        }
      });
    }
  }

  Future<void> _checkReady() async {
    if (_checkingReady || widget.session.webController == null || !mounted) {
      return;
    }
    _checkingReady = true;
    try {
      final controller = widget.session.webController!;
      final url = await controller.getUrl();
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
        if (mounted) {
          setState(() {
            widget.session.isWebLoading = false;
            widget.session.isSessionReady = false;
            widget.session.isGooglePermissionError = true;
            widget.session.isPaywallRequired = false;
            widget.session.isTimeoutError = false;
            widget.session.errorMessage =
                'Sesi akun Google Anda belum terhubung atau telah kedaluwarsa. Silakan hubungkan akun Google Anda untuk mengakses asisten.';
          });
        }
        return;
      }
      final isDenied = await controller.evaluateJavascript(
          source:
              'window.otNotebook ? window.otNotebook.accessDenied() : false');
      if (isDenied == true) {
        _handleAccessDenied(widget.session);
        return;
      }
      final result = await controller.evaluateJavascript(
          source: 'window.otNotebook ? window.otNotebook.ready() : false');
      _readySamples = result == true ? _readySamples + 1 : 0;
      if (!mounted) return;
      final elapsedMs = _loadingStarted != null
          ? DateTime.now().difference(_loadingStarted!).inMilliseconds
          : 0;
      if (_readySamples >= 2 && elapsedMs >= 1500) {
        _readinessTimer?.cancel();
        if (mounted) {
          setState(() {
            widget.session.isWebLoading = false;
            widget.session.isSessionReady = true;
            widget.session.isTimeoutError = false;
          });
        }
      } else if (DateTime.now().difference(_loadingStarted!).inSeconds >= 25) {
        _readinessTimer?.cancel();
        if (mounted) {
          setState(() {
            widget.session.isWebLoading = false;
            widget.session.isSessionReady = false;
            widget.session.isTimeoutError = true;
            widget.session.errorMessage =
                'Koneksi ke asisten turats membutuhkan waktu lebih lama dari biasanya. Silakan muat ulang atau periksa koneksi internet Anda.';
          });
        }
      }
    } catch (_) {
    } finally {
      _checkingReady = false;
    }
  }

  Future<void> _fetchUrl() async {
    final session = widget.session;
    setState(() {
      session.isUrlLoading = true;
      session.errorMessage = null;
    });

    final user = _authService.cachedCurrentUser;
    final hasAccess = user != null && user.hasAccessToAgent(session.agent.id);
    if (!hasAccess) {
      if (!mounted) return;
      setState(() {
        session.isUrlLoading = false;
        session.isPaywallRequired = true;
        session.isGooglePermissionError = false;
        session.errorMessage =
            'Untuk membuka dan menelaah kitab bersama ${session.agent.title}, silakan aktifkan paket langganan Anda.';
      });
      return;
    }

    try {
      final url = await _agentService.getAgentUrl(session.agent.id);
      if (!mounted) return;
      if (url != null && url.isNotEmpty) {
        setState(() {
          session.resolvedUrl = url;
          session.isUrlLoading = false;
        });
      } else {
        setState(() {
          session.isUrlLoading = false;
          session.isPaywallRequired = true;
          session.errorMessage =
              'Untuk membuka dan menelaah kitab bersama ${session.agent.title}, silakan aktifkan paket langganan Anda.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().toLowerCase();
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
        session.isUrlLoading = false;
        session.isPaywallRequired = isPaywall;
        session.errorMessage = isPaywall
            ? 'Untuk membuka dan menelaah kitab bersama ${session.agent.title}, silakan aktifkan paket langganan Anda.'
            : 'Asisten belum bisa dihubungkan. Coba lagi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DesktopWebViewGate(builder: _buildContent);
  }

  Widget _buildContent(BuildContext context) {
    final session = widget.session;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvas = OTColors.canvas(isDark);

    if (session.isUrlLoading) {
      return AppLoader.fullscreen(
        title: session.agent.title,
        subtitle: AppCopy.loadingReferences,
        onCancel: () => AgentSessionManager.instance.closeRoom(),
      );
    }

    if (session.errorMessage != null) {
      final isGoogleErr = session.isGooglePermissionError;
      final isPaywall = session.isPaywallRequired;
      final isTimeout = session.isTimeoutError;

      if (isPaywall) {
        final textPrimary = OTColors.textPrimary(isDark);
        final textSecondary = OTColors.textSecondary(isDark);
        return Container(
          color: canvas,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
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
                            color: OTColors.border(isDark), width: 1.2),
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
                      session.errorMessage ??
                          'Untuk membuka dan menelaah kitab bersama ${session.agent.title}, silakan aktifkan paket langganan Anda.',
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
                        onPressed: () {
                          NavigationGuard.safePushNamed(
                            context,
                            AppRoutes.subscription,
                            arguments: {
                              'user': _authService.cachedCurrentUser,
                              'agent': session.agent,
                            },
                          );
                        },
                        icon: const Icon(Icons.card_membership_rounded,
                            size: 18),
                        label: Text(
                          'Langganan Sekarang',
                          style: ScholarlyFonts.outfit(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.5,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: OTColors.accent(isDark),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: TextButton(
                        onPressed: () =>
                            AgentSessionManager.instance.closeRoom(),
                        child: Text(
                          'Kembali ke Beranda',
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
          ),
        );
      }

      final title = isGoogleErr
          ? 'Akun Google belum memiliki izin'
          : (isTimeout
              ? 'Asisten belum berhasil dibuka'
              : 'Asisten Belum Bisa Dibuka');

      final icon = isGoogleErr
          ? Icons.account_circle_outlined
          : (isTimeout
              ? Icons.wifi_off_rounded
              : Icons.info_outline_rounded);

      final retryLabel = isGoogleErr ? 'Ganti Akun Google' : 'Coba lagi';

      return Container(
        color: canvas,
        child: AppErrorState(
          title: title,
          message: session.errorMessage!,
          icon: icon,
          retryLabel: retryLabel,
          onRetry: () {
            if (isGoogleErr) {
              NavigationGuard.safePushNamed(
                context,
                AppRoutes.googleSessionAuth,
              );
            } else {
              setState(() {
                session.errorMessage = null;
                session.isTimeoutError = false;
                session.isGooglePermissionError = false;
                session.isWebLoading = true;
                session.isSessionReady = false;
              });
              if (session.webController != null) {
                session.webController!.reload();
                _startReadinessCheck();
              } else {
                _fetchUrl();
              }
            }
          },
          onBack: () => AgentSessionManager.instance.closeRoom(),
          backLabel: 'Kembali ke Beranda',
        ),
      );
    }

    final initialUri = WebUri(session.resolvedUrl!);

    return Container(
      color: canvas,
      child: Stack(
        children: [
          InAppWebView(
                      webViewEnvironment: DesktopWebViewRuntime.environment,
            keepAlive: session.keepAlive,
            initialUrlRequest: URLRequest(url: initialUri),
            initialUserScripts:
                UnmodifiableListView([_buildCloakScript(isDark)]),
            initialSettings: InAppWebViewSettings(
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
              mixedContentMode: MixedContentMode.MIXED_CONTENT_NEVER_ALLOW,
              thirdPartyCookiesEnabled: true,
              sharedCookiesEnabled: true,
              hardwareAcceleration: true,
              useHybridComposition: true,
              useOnRenderProcessGone: true,
              verticalScrollBarEnabled: false,
              horizontalScrollBarEnabled: false,
              forceDark: isDark ? ForceDark.ON : ForceDark.OFF,
              forceDarkStrategy:
                  ForceDarkStrategy.PREFER_WEB_THEME_OVER_USER_AGENT_DARKENING,
              algorithmicDarkeningAllowed: true,
              userAgent: AppPlatform.isDesktop ? null : AppConstants.chromeMobileUserAgent,
            ),
            onReceivedError: (controller, request, error) {
              if (request.isForMainFrame == true && mounted) {
                _readinessTimer?.cancel();
                setState(() {
                  session.isWebLoading = false;
                  session.isSessionReady = false;
                  session.isTimeoutError = true;
                  session.errorMessage =
                      'Gagal memuat asisten turats (${error.description}). Silakan periksa koneksi internet Anda.';
                });
              }
            },
            onReceivedHttpError: (controller, request, errorResponse) {
              final code = errorResponse.statusCode;
              if (request.isForMainFrame == true &&
                  mounted &&
                  code != null &&
                  code >= 400) {
                if (code == 401 || code == 403) {
                  _readinessTimer?.cancel();
                  setState(() {
                    session.isWebLoading = false;
                    session.isSessionReady = false;
                    session.isGooglePermissionError = true;
                    session.errorMessage =
                        'Sesi akun Google Anda belum terhubung atau telah kedaluwarsa. Silakan hubungkan akun Google Anda untuk mengakses asisten.';
                  });
                }
              }
            },
            onRenderProcessGone: (controller, detail) async {
              debugPrint('[OpenTurath] WebView render process gone (didCrash: ${detail.didCrash})');
              if (mounted) {
                setState(() {
                  widget.session.isWebLoading = true;
                  widget.session.isSessionReady = false;
                });
                controller.reload();
                _startReadinessCheck();
              }
            },
            onWebViewCreated: (controller) {
              session.webController = controller;
              controller.addJavaScriptHandler(
                handlerName: 'otCopiedAnswer',
                callback: (args) async {
                  final url = await controller.getUrl();
                  if (url?.scheme != 'https' ||
                      !['notebooklm.google.com', 'notebook.google.com']
                          .contains(url?.host) ||
                      args.isEmpty ||
                      args.first is! String) {
                    return false;
                  }
                  try {
                    final text = (args.first as String).trim();
                    if (text.isNotEmpty && text.length <= 200000) {
                      final now = DateTime.now();
                      if (_lastCopiedToastAt != null &&
                          now.difference(_lastCopiedToastAt!) <
                              const Duration(milliseconds: 3500)) {
                        return true;
                      }
                      _lastCopiedToastAt = now;

                      await Clipboard.setData(ClipboardData(text: text));
                      if (context.mounted) {
                        OTMotion.light();
                        AppSnackBar.success(
                          context,
                          AppCopy.answerCopied,
                          duration: const Duration(milliseconds: 2500),
                          action: SnackBarAction(
                            label: 'Simpan',
                            textColor: OTColors.onInverseSurface,
                            onPressed: () {
                              final uid = _authService.currentUser?.uid;
                              if (uid != null) {
                                unawaited(_bookmarkService.addBookmark(
                                  copiedAnswerBookmark(text, session.agent),
                                  userId: uid,
                                ));
                              }
                            },
                          ),
                        );
                      }
                      return true;
                    }
                  } catch (_) {
                    if (context.mounted) {
                      AppSnackBar.error(context, AppCopy.saveFailed);
                    }
                  }
                  return false;
                },
              );
              if (!session.isSessionReady) {
                _startReadinessCheck();
              }
            },
            onLoadStart: (controller, uri) {
              session.hasInjectedEarlyScript = false;
              // Hanya aktifkan full loader jika sesi BELUM pernah siap sama sekali
              if (mounted && !session.isSessionReady && !session.isWebLoading) {
                setState(() => session.isWebLoading = true);
              }
              if (!session.isSessionReady) {
                _startReadinessCheck();
              }
            },
            onLoadStop: (controller, uri) async {
              await controller.evaluateJavascript(
                  source:
                      'window._otIsDark = $isDark;\n$_turatsMasterScript$notebookUiScript');
              await _applyThemeCss(isDark);
              await controller.evaluateJavascript(
                source:
                    'if (typeof applyTurathFontScale === "function") { applyTurathFontScale(${session.fontScale}); }',
              );
              final denied = await controller.evaluateJavascript(
                  source:
                      'window.otNotebook ? window.otNotebook.accessDenied() : false');
              if (!mounted) return;
              if (denied == true) {
                _handleAccessDenied(session);
                return;
              }
            },
            onProgressChanged: (controller, progress) async {
              if (progress >= 35 && !session.hasInjectedEarlyScript) {
                session.hasInjectedEarlyScript = true;
                await controller.evaluateJavascript(
                    source:
                        'window._otIsDark = $isDark;\n$_turatsMasterScript$notebookUiScript');
                await _applyThemeCss(isDark);
              }
            },
            shouldOverrideUrlLoading: (controller, action) async {
              final uri = action.request.url;
              if (uri == null) return NavigationActionPolicy.CANCEL;
              if (NotebookNavigation.allowed(uri.uriValue)) {
                return NavigationActionPolicy.ALLOW;
              }
              return NavigationActionPolicy.CANCEL;
            },
          ),

          // Fullscreen pulsing loader hanya saat inisialisasi awal
          if (!session.isSessionReady && session.isWebLoading)
            Positioned.fill(
              child: AppLoader.fullscreen(
                title: session.agent.title,
                subtitle: AppCopy.loadingReferences,
                onCancel: () => AgentSessionManager.instance.closeRoom(),
              ),
            ),
        ],
      ),
    );
  }
}
