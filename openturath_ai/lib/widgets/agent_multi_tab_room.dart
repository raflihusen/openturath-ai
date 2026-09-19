import '../core/l10n/app_localizations.dart';
import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:openturath_ai/core/design/ot_fonts.dart';

import '../core/app_copy.dart';
import '../core/app_snackbar.dart';
import '../core/navigation_guard.dart';
import '../core/routes.dart';
import '../core/notebook_navigation.dart';
import '../core/notebook_ui_script.dart';
import '../core/copied_answer.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_motion.dart';
import '../core/design/ot_typography.dart';
import '../models/agent_model.dart';
import '../services/agent_service.dart';
import '../services/notebook_font_service.dart';
import '../services/agent_session_manager.dart';
import '../services/auth_service.dart';
import '../services/bookmark_service.dart';
import '../widgets/app_error_state.dart';
import '../widgets/app_loader.dart';
import '../widgets/library_bottom_sheet.dart';

/// AgentMultiTabRoom: Persistent, multi-tab AI Study Room inspired by Google Chrome tabs.
/// Keeps up to 3 AI specialists running concurrently in memory without reloading.
class AgentMultiTabRoom extends StatefulWidget {
  const AgentMultiTabRoom({super.key});

  @override
  State<AgentMultiTabRoom> createState() => AgentMultiTabRoomState();
}

class AgentMultiTabRoomState extends State<AgentMultiTabRoom> {
  bool _focusMode = false;
  final AgentSessionManager _sessionManager = AgentSessionManager.instance;
  final BookmarkService _bookmarkService = BookmarkService();
  final AuthService _authService = AuthService();

  Future<void> _copyActiveConversation(AgentSessionTab session) async {
    final controller = session.webController;
    if (controller == null || (session.isDisposed || session.isRetired) ||
        _authService.currentUser?.uid != session.ownerUid) return;
    try {
      final sourceUrl = await controller.getUrl();
      if (sourceUrl == null || !NotebookNavigation.notebook(sourceUrl.uriValue)) return;
      final result = await controller.evaluateJavascript(
        source: 'window.otNotebook ? window.otNotebook.conversation() : ""',
      );
      final text = result is String ? result.trim() : '';
      if (text.isEmpty) {
        if (mounted) AppSnackBar.warning(context, context.tr(AppCopy.noConversationToCopy));
        return;
      }
      final formatted = text;
      // 1. Simpan langsung ke Catatan (Bookmarks)
      if ((session.isDisposed || session.isRetired) || _authService.currentUser?.uid != session.ownerUid) return;
      final uid = session.ownerUid;
      final bookmark = copiedAnswerBookmark(formatted, session.agent);
      await _bookmarkService.addBookmark(bookmark, userId: uid);
      if (session.isDisposed || session.isRetired || _authService.currentUser?.uid != uid) return;

      // 2. Salin ke clipboard perangkat
      await Clipboard.setData(ClipboardData(text: formatted));

      if (mounted) {
        OTMotion.success();
        AppSnackBar.success(context, context.tr(AppCopy.conversationCopied));
      }
    } catch (_) {
      if (mounted) AppSnackBar.error(context, context.tr(AppCopy.copyFailed));
    }
  }

  @override
  void initState() {
    super.initState();
    _sessionManager.addListener(_onSessionsChanged);
    HardwareKeyboard.instance.addHandler(_handleKeyboard);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyboard);
    _sessionManager.removeListener(_onSessionsChanged);
    super.dispose();
  }

  /// The shell owns route Back handling and calls this before closing the room.
  /// Keeping a single PopScope prevents a Back event from doing both actions.
  bool exitFocusMode() {
    if (!mounted || !_sessionManager.isOpen || !_focusMode) return false;
    setState(() => _focusMode = false);
    return true;
  }

  bool _handleKeyboard(KeyEvent event) {
    if (!mounted || event is! KeyDownEvent ||
        event.logicalKey != LogicalKeyboardKey.escape ||
        ModalRoute.of(context)?.isCurrent != true) return false;
    return exitFocusMode();
  }

  void _onSessionsChanged() {
    if (!mounted) return;
    setState(() {
      if (!_sessionManager.isOpen || !_sessionManager.hasSessions) {
        _focusMode = false;
      }
    });
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
          return SingleChildScrollView(child: Container(
            padding: const EdgeInsetsDirectional.fromSTEB(24, 20, 24, 32),
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
                  context.tr(AppCopy.studyOptions),
                  style: OTTypography.cardTitle(color: textPrimary)
                      .copyWith(fontSize: 17),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr('Sesuaikan ukuran huruf percakapan agar nyaman dibaca.'),
                  style: OTTypography.caption(color: textSecondary),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(context.languageCode == 'ar' ? 'أ' : 'A',
                        style: OTFonts.outfit(
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
                    Text(context.languageCode == 'ar' ? 'أ' : 'A',
                        style: OTFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textPrimary)),
                  ],
                ),
              ],
            ),
          ));
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

    final textScaler = MediaQuery.textScalerOf(context);
    final toolbarHeight = 56.0 + (textScaler.scale(20) - 20).clamp(0.0, double.infinity) * 1.6;
    final tabHeight = 60.0 + (textScaler.scale(14) - 14).clamp(0.0, double.infinity) * 1.8;

    final activeTab = _sessionManager.activeTab;
    final sessions = _sessionManager.tabs;

    if (activeTab == null || sessions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: canvas,
      appBar: _focusMode ? null : AppBar(
        toolbarHeight: toolbarHeight,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: canvas,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary, size: 22),
          tooltip: context.tr('Kembali ke Beranda'),
          onPressed: () {
            AppSnackBar.clear(context);
            _sessionManager.closeRoom();
          },
        ),
        titleSpacing: 0,
        title: Text(
          context.agentTitle(activeTab.agent),
          style: OTFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            letterSpacing: -0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu_book_outlined, color: textPrimary, size: 20),
            tooltip: context.tr(AppCopy.referenceBooks),
            onPressed: () => _openLibrarySheet(context, activeTab.agent),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: textPrimary, size: 20),
            tooltip: context.tr(AppCopy.studyOptions),
            color: surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: border, width: 0.8),
            ),
            onSelected: (val) {
              if (val == 'conversation') {
                _copyActiveConversation(activeTab);
              } else if (val == 'focus') {
                setState(() => _focusMode = true);
              } else if (val == 'font') {
                _showFontScaleDialog(context, activeTab);
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'focus',
                child: Builder(builder: (context) => Row(children: [
                  Icon(Icons.fullscreen_rounded, color: textPrimary, size: 18),
                  const SizedBox(width: 12),
                  Flexible(child: Text(context.tr('room.focus'))),
                ])),
              ),
              PopupMenuItem(
                value: 'conversation',
                child: Builder(builder: (context) => Row(
                  children: [
                    Icon(Icons.content_copy_rounded,
                        color: textPrimary, size: 18),
                    const SizedBox(width: 12),
                    Flexible(child: Text(context.tr(AppCopy.copyConversationAction),
                        style: OTTypography.body(color: textPrimary))),
                  ],
                )),
              ),
              PopupMenuItem(
                value: 'font',
                child: Builder(builder: (context) => Row(
                  children: [
                    Icon(Icons.format_size_rounded,
                        color: textPrimary, size: 18),
                    const SizedBox(width: 12),
                    Flexible(child: Text(context.tr('Ukuran huruf'),
                        style: OTTypography.body(color: textPrimary))),
                  ],
                )),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
        // Chrome-like Multi-Tab Bar (Hanya tampil jika terdapat lebih dari 1 sesi aktif)
        bottom: sessions.length > 1
            ? PreferredSize(
                preferredSize: Size.fromHeight(tabHeight),
                child: Container(
                  height: tabHeight,
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
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                              borderRadius: const BorderRadiusDirectional.horizontal(start: Radius.circular(8)).resolve(Directionality.of(context)),
                              child: Container(
                                constraints: const BoxConstraints(minHeight: 48),
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
                                      context.agentTitle(session.agent),
                                      style: OTFonts.outfit(
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
                              label: context.tr('room.closeTab', args: {'name': context.agentTitle(session.agent)}),
                              button: true,
                              child: Material(
                                color: Colors.transparent,
                                child: InkResponse(
                                  onTap: () {
                                    AppSnackBar.clear(context);
                                    _sessionManager.closeTab(index);
                                  },
                                  radius: 24,
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    width: 48,
                                    height: 48,
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
      floatingActionButton: _focusMode
          ? SizedBox(width: 56, height: 56, child: FloatingActionButton(
              heroTag: 'roomExitFocus',
              tooltip: context.tr('room.exitFocus'),
              onPressed: exitFocusMode,
              child: const Icon(Icons.fullscreen_exit_rounded),
            ))
          : null,
      body: SafeArea(top: _focusMode, child: IndexedStack(
        index: _sessionManager.activeIndex,
        children: [
          for (int i = 0; i < sessions.length; i++)
            _SingleAgentTabWebView(
              key: ValueKey('agent_tab_${sessions[i].agent.id}'),
              session: sessions[i],
              isActive: i == _sessionManager.activeIndex,
            ),
        ],
      )),
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
    with AutomaticKeepAliveClientMixin {
  final AgentService _agentService = AgentService();
  final BookmarkService _bookmarkService = BookmarkService();
  final AuthService _authService = AuthService();

  @override
  bool get wantKeepAlive => true;

  static const String _turatsMasterScript = r"""
    (function() {
      if (window.top !== window || !['notebooklm.google.com', 'notebook.google.com'].includes(location.hostname)) return;

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
            line-height: 1.9 !important;
            font-style: normal !important;
          }
        `;
      };
    })();
  """;

  String get _bridgeScript => '''
    if (window.top === window && location.protocol === 'https:' &&
        ['notebooklm.google.com', 'notebook.google.com'].includes(location.hostname)) {
      window.__otCopyNonce = ${jsonEncode(widget.session.bridgeNonce)};
    }
  ''';

  UserScript _buildCloakScript(bool isDark) {
    final themeInitScript = '''
      (function() {
        if (window.top !== window || !['notebooklm.google.com', 'notebook.google.com'].includes(location.hostname)) return;
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
          styleEl.textContent = ${isDark ? "'html, body { background-color: #111110 !important; color: #F4F4F0 !important; }'" : "'html, body { background-color: #F6F6F3 !important; color: #171717 !important; }'"};

          if (window.otNotebook && typeof window.otNotebook.setTheme === 'function') {
            window.otNotebook.setTheme($isDark);
          }
        } catch(e) {}
      })();
    ''';

    return UserScript(
      source:
          '$_bridgeScript\nwindow._otIsDark = $isDark;\n$_turatsMasterScript$notebookUiScript$themeInitScript',
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
  String? _lastCopiedText;

  bool get _ownsSession => !widget.session.isDisposed && !widget.session.isRetired &&
      _authService.currentUser?.uid == widget.session.ownerUid;

  @override
  void initState() {
    super.initState();
    if (widget.session.resolvedUrl == null) {
      _fetchUrl();
    }
  }

  @override
  void dispose() {
    _readinessTimer?.cancel();
    if (mounted) {
      AppSnackBar.clear(context);
    }
    super.dispose();
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
            styleEl.textContent = ${isDark ? "'html, body { background-color: #111110 !important; color: #F4F4F0 !important; }'" : "'html, body { background-color: #F6F6F3 !important; color: #171717 !important; }'"};

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

  void _failLoad(String message, {bool timeout = false}) {
    _readinessTimer?.cancel();
    if (!mounted || !_ownsSession) return;
    setState(() {
      widget.session.isWebLoading = false;
      widget.session.isSessionReady = false;
      widget.session.isUrlLoading = false;
      widget.session.isTimeoutError = timeout;
      widget.session.errorMessage = message;
    });
  }

  Future<void> _checkReady() async {
    if (!mounted || !_ownsSession) { _readinessTimer?.cancel(); return; }
    final elapsed = DateTime.now().difference(_loadingStarted ?? DateTime.now());
    if (elapsed >= const Duration(seconds: 20)) {
      _failLoad('Koneksi memerlukan waktu lebih lama. Periksa jaringan, lalu coba lagi.', timeout: true);
      return;
    }
    if (_checkingReady || widget.session.webController == null) return;
    _checkingReady = true;
    try {
      final controller = widget.session.webController!;
      final url = await controller.getUrl().timeout(const Duration(seconds: 2));
      if (!mounted || !_ownsSession) return;
      if (url == null || !NotebookNavigation.allowed(url.uriValue)) return;
      final isLogin = !NotebookNavigation.notebook(url.uriValue);
      if (isLogin) {
        // Reveal the authentication page without declaring the notebook ready.
        _readinessTimer?.cancel();
        setState(() { widget.session.isWebLoading = false; widget.session.isSessionReady = false; });
        return;
      }
      final denied = await controller.evaluateJavascript(
        source: 'window.otNotebook ? window.otNotebook.accessDenied() : false',
      ).timeout(const Duration(seconds: 2));
      if (!mounted || !_ownsSession) return;
      if (denied == true) { _handleAccessDenied(widget.session); return; }
      final ready = await controller.evaluateJavascript(
        source: 'window.otNotebook ? window.otNotebook.ready() : false',
      ).timeout(const Duration(seconds: 2));
      if (!mounted || !_ownsSession || widget.session.errorMessage != null) return;
      _readySamples = ready == true ? _readySamples + 1 : 0;
      if (_readySamples >= 2) {
        _readinessTimer?.cancel();
        setState(() {
          widget.session.isWebLoading = false;
          widget.session.isSessionReady = true;
          widget.session.isTimeoutError = false;
        });
      }
    } catch (_) {
      // The independent deadline above still fires after script/network failures.
    } finally { _checkingReady = false; }
  }

  Future<void> _fetchUrl() async {
    final session = widget.session;
    if (!mounted || !_ownsSession) return;
    setState(() {
      session.isUrlLoading = true;
      session.errorMessage = null;
    });

    final user = _authService.cachedCurrentUser;
    if (user == null || user.uid != session.ownerUid || !user.hasAccessToAgent(session.agent.id)) {
      if (!mounted) return;
      setState(() {
        session.isUrlLoading = false;
        session.isPaywallRequired = true;
        session.isGooglePermissionError = false;
        session.errorMessage =
            'Akses untuk asisten ini memerlukan langganan aktif.';
      });
      return;
    }

    try {
      final url = await _agentService.getAgentUrl(session.agent.id).timeout(const Duration(seconds: 15));
      if (!mounted || !_ownsSession) return;
      final uri = url == null ? null : Uri.tryParse(url);
      if (uri != null && NotebookNavigation.notebook(uri)) {
        setState(() {
          session.resolvedUrl = url;
          session.isUrlLoading = false;
        });
      } else {
        setState(() {
          session.isUrlLoading = false;
          session.errorMessage = 'Tautan asisten tidak valid.';
        });
      }
    } catch (e) {
      if (!mounted || !_ownsSession) return;
      final msg = e.toString().toLowerCase();
      final isPaywall =
          msg.contains('permission-denied') || msg.contains('berlangganan');
      setState(() {
        session.isUrlLoading = false;
        session.isPaywallRequired = isPaywall;
        session.errorMessage = isPaywall
            ? 'Akses asisten ini memerlukan langganan aktif.'
            : 'Asisten belum bisa dihubungkan. Coba lagi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final session = widget.session;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvas = OTColors.canvas(isDark);

    if (session.isUrlLoading) {
      return AppLoader.fullscreen(
        title: context.agentTitle(session.agent),
        subtitle: context.tr(AppCopy.loadingReferences),
        onCancel: () => AgentSessionManager.instance.closeRoom(),
      );
    }

    if (session.errorMessage != null) {
      final isGoogleErr = session.isGooglePermissionError;
      final isPaywall = session.isPaywallRequired;
      final isTimeout = session.isTimeoutError;

      final title = isPaywall
          ? 'Akses khusus diperlukan'
          : (isGoogleErr
              ? 'Akun Google belum memiliki izin'
              : (isTimeout
                  ? 'Asisten belum berhasil dibuka'
                  : 'Asisten Belum Bisa Dibuka'));

      final icon = isPaywall
          ? Icons.workspace_premium_rounded
          : (isGoogleErr
              ? Icons.account_circle_outlined
              : (isTimeout
                  ? Icons.wifi_off_rounded
                  : Icons.info_outline_rounded));

      final retryLabel = isPaywall
          ? 'Buka Akses Langganan'
          : (isGoogleErr
              ? 'Ganti Akun Google'
              : 'Coba lagi');

      return Container(
        color: canvas,
        child: AppErrorState(
          title: context.tr(title),
          message: context.tr(session.errorMessage!),
          icon: icon,
          retryLabel: context.tr(retryLabel),
          onRetry: () async {
            if (isPaywall) {
              await NavigationGuard.safePushNamed(
                context,
                AppRoutes.subscription,
                arguments: {
                  'user': _authService.cachedCurrentUser,
                  'agent': session.agent,
                },
              );
              if (mounted && _ownsSession) {
                try { await _authService.getFreshCurrentUserModel(); } catch (_) {}
                if (mounted && _ownsSession) await _fetchUrl();
              }
            } else if (isGoogleErr) {
              await NavigationGuard.safePushNamed(
                context,
                AppRoutes.googleSessionAuth,
              );
              if (mounted && _ownsSession) await _fetchUrl();
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
          backLabel: context.tr('Kembali ke Beranda'),
        ),
      );
    }

    final initialUri = WebUri(session.resolvedUrl!);

    return Container(
      color: canvas,
      child: Stack(
        children: [
          InAppWebView(
            keepAlive: session.keepAlive,
            initialUrlRequest: URLRequest(url: initialUri),
            initialUserScripts:
                UnmodifiableListView([_buildCloakScript(isDark)]),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              useShouldOverrideUrlLoading: true,
              javaScriptCanOpenWindowsAutomatically: false,
              supportMultipleWindows: false,
              allowFileAccess: false,
              allowContentAccess: false,
              domStorageEnabled: true,
              databaseEnabled: true,
              useWideViewPort: true,
              loadWithOverviewMode: true,
              cacheEnabled: true,
              clearCache: false,
              transparentBackground: false,
              allowsInlineMediaPlayback: true,
              supportZoom: false,
              displayZoomControls: false,
              mixedContentMode: MixedContentMode.MIXED_CONTENT_NEVER_ALLOW,
              thirdPartyCookiesEnabled: true,
              hardwareAcceleration: true,
              verticalScrollBarEnabled: false,
              horizontalScrollBarEnabled: false,
              forceDark: isDark ? ForceDark.ON : ForceDark.OFF,
              forceDarkStrategy:
                  ForceDarkStrategy.PREFER_WEB_THEME_OVER_USER_AGENT_DARKENING,
              algorithmicDarkeningAllowed: true,
              userAgent:
                  'Mozilla/5.0 (Linux; Android 14; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Mobile Safari/537.36',
            ),
            onWebViewCreated: (controller) {
              if (!_ownsSession) return;
              session.webController = controller;
              controller.addJavaScriptHandler(
                handlerName: 'otCopiedAnswer',
                callback: (args) async {
                  final url = await controller.getUrl();
                  if (!_ownsSession || !mounted || url?.scheme != 'https' ||
                      !['notebooklm.google.com', 'notebook.google.com']
                          .contains(url?.host) ||
                      args.length != 2 || args[1] != session.bridgeNonce ||
                      args.first is! String) {
                    return false;
                  }
                  try {
                    final text = (args.first as String).trim();
                    if (text.isNotEmpty && text.length <= 200000) {
                      final now = DateTime.now();
                      if (_lastCopiedText == text && _lastCopiedToastAt != null &&
                          now.difference(_lastCopiedToastAt!) <
                              const Duration(milliseconds: 3500)) {
                        return true;
                      }
                      _lastCopiedToastAt = now;
                      _lastCopiedText = text;

                      await Clipboard.setData(ClipboardData(text: text));
                      if (context.mounted && _ownsSession) {
                        OTMotion.light();
                        AppSnackBar.success(
                          context,
                          context.tr(AppCopy.answerCopied),
                          duration: const Duration(milliseconds: 2500),
                          action: SnackBarAction(
                            label: context.tr('Simpan'),
                            textColor: OTColors.onInverseSurface,
                            onPressed: () {
                              final uid = session.ownerUid;
                              if (_ownsSession) {
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
                      AppSnackBar.error(context, context.tr(AppCopy.saveFailed));
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
              if (!_ownsSession) return;
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
              if (!_ownsSession || uri == null || !NotebookNavigation.notebook(uri.uriValue)) return;
              try {
                final fonts = await NotebookFontService.injection;
                if (!_ownsSession) return;
                await controller.evaluateJavascript(source: fonts);
              } catch (_) { /* System Arabic fallback keeps the text readable. */ }
              try {
              await controller.evaluateJavascript(
                  source:
                      '$_bridgeScript\nwindow._otIsDark = $isDark;\n$_turatsMasterScript$notebookUiScript');
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
              } catch (_) { /* Readiness deadline handles an incomplete DOM. */ }
            },
            onReceivedError: (controller, request, error) {
              if (request.isForMainFrame == true) {
                _failLoad('Halaman belum dapat dimuat. Periksa koneksi lalu coba lagi.');
              }
            },
            onReceivedHttpError: (controller, request, response) {
              if (request.isForMainFrame == true && (response.statusCode ?? 0) >= 400) {
                _failLoad('Layanan sedang tidak tersedia. Silakan coba kembali.');
              }
            },
            onProgressChanged: (controller, progress) async {
              final uri = await controller.getUrl();
              if (!_ownsSession || uri == null || !NotebookNavigation.notebook(uri.uriValue)) return;
              if (progress >= 35 && !session.hasInjectedEarlyScript) {
                try {
                session.hasInjectedEarlyScript = true;
                await controller.evaluateJavascript(
                    source:
                        '$_bridgeScript\nwindow._otIsDark = $isDark;\n$_turatsMasterScript$notebookUiScript');
                await _applyThemeCss(isDark);
                } catch (_) {}
              }
            },
            shouldOverrideUrlLoading: (controller, action) async {
              final uri = action.request.url;
              if (!_ownsSession || uri == null) return NavigationActionPolicy.CANCEL;
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
                title: context.agentTitle(session.agent),
                subtitle: context.tr(AppCopy.loadingReferences),
                onCancel: () => AgentSessionManager.instance.closeRoom(),
              ),
            ),
        ],
      ),
    );
  }
}


