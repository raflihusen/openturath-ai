import '../widgets/adaptive_sheet.dart';
import '../services/desktop_webview_runtime.dart';
import '../widgets/desktop_webview_gate.dart';
import '../core/app_platform.dart';
import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/turath_chat_message.dart';

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
import '../core/scholarly_fonts.dart';
import '../models/agent_model.dart';
import '../services/agent_service.dart';
import '../services/agent_session_manager.dart';
import '../services/auth_service.dart';
import '../services/persistent_google_session.dart';
import '../services/bookmark_service.dart';
import '../services/native_agent_launcher.dart';
import '../widgets/app_error_state.dart';
import '../widgets/app_loader.dart';
import '../widgets/library_bottom_sheet.dart';
import 'notebook_backend_chat_tab.dart';
import 'browser_companion_chat_tab.dart';
import '../core/localization.dart';

import 'package:openturath_ai/core/design/ot_radius.dart';

// Explicit local prototype opt-in; remains off in normal/release builds.
const _backendChatPrototype =
    bool.fromEnvironment('OPENTURATH_BACKEND_CHAT_PROTOTYPE');
const _browserCompanionPrototype =
    bool.fromEnvironment('OPENTURATH_BROWSER_COMPANION');
const _nativeChat = _backendChatPrototype || _browserCompanionPrototype;

/// AgentMultiTabRoom: Persistent, multi-tab AI Study Room inspired by Google Chrome tabs.
/// Keeps up to 7 AI specialists running concurrently in memory without reloading.
class AgentMultiTabRoom extends StatefulWidget {
  const AgentMultiTabRoom({super.key});

  /// Dialog pemilihan akun Google khusus untuk asisten NotebookLM.
  /// Memastikan browser eksternal membuka akun yang tepat (/u/<index> atau AccountChooser).
  static Future<void> showChangeGoogleAccountDialog(
      BuildContext context) async {
    final currentEmail = await NativeAgentLauncher.getActiveNotebookEmail();
    if (!context.mounted) return;
    final controller = TextEditingController(text: currentEmail);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final newEmail = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            isDark ? OTColors.surfaceSubtleDark : OTColors.surfaceLight,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(OTRadius.card)),
        title: Row(
          children: [
            Icon(Icons.manage_accounts_rounded,
                color: OTColors.accent(isDark), size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                Loc.tr('googleAccountDialogTitle'),
                style: ScholarlyFonts.outfit(
                  fontSize: OTFontSize.s16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? OTColors.surfaceLight : OTColors.surfaceDark,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Loc.tr('googleAccountDialogDesc'),
              style: ScholarlyFonts.outfit(
                fontSize: OTFontSize.s12,
                color: isDark
                    ? OTColors.textSecondaryDark
                    : OTColors.borderStrongLight,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              style: ScholarlyFonts.outfit(
                fontSize: OTFontSize.s14,
                color: isDark ? OTColors.surfaceLight : OTColors.surfaceDark,
              ),
              decoration: InputDecoration(
                hintText: 'nama@gmail.com',
                prefixIcon: const Icon(Icons.email_outlined, size: 18),
                filled: true,
                fillColor: isDark
                    ? OTColors.surfaceSubtleDark
                    : OTColors.surfaceSubtleLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(OTRadius.input),
                  borderSide: BorderSide(
                    color: isDark
                        ? OTColors.borderDark
                        : OTColors.borderSubtleLight,
                  ),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              Loc.tr('cancel'),
              style: ScholarlyFonts.outfit(
                  color: isDark
                      ? OTColors.surfaceLight.withValues(alpha: 0.7)
                      : OTColors.shadow.withValues(alpha: 0.87)),
            ),
          ),
          if (AuthService().currentUser?.email != null)
            TextButton(
              onPressed: () {
                final def = AuthService().currentUser?.email ?? '';
                controller.text = def;
              },
              child: Text(
                Loc.tr('usePrimaryAccount'),
                style: ScholarlyFonts.outfit(color: OTColors.accent(isDark)),
              ),
            ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: OTColors.accent(isDark),
            ),
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(
              Loc.tr('save'),
              style: ScholarlyFonts.outfit(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (newEmail != null && context.mounted) {
      await NativeAgentLauncher.setActiveNotebookEmail(newEmail);
      if (context.mounted) {
        final display =
            newEmail.isEmpty ? Loc.tr('primaryLoginAccount') : newEmail;
        AppSnackBar.info(
            context, Loc.tr('assistantGoogleAccountSet', [display]));
      }
    }
  }

  @override
  State<AgentMultiTabRoom> createState() => _AgentMultiTabRoomState();
}

class _AgentMultiTabRoomState extends State<AgentMultiTabRoom> {
  final AgentSessionManager _sessionManager = AgentSessionManager.instance;
  final BookmarkService _bookmarkService = BookmarkService();
  final AuthService _authService = AuthService();

  Future<void> _copyActiveConversation(AgentSessionTab session) async {
    final owner = _authService.currentUser?.uid;
    if (owner == null) return;
    final controller = session.webController;
    if (!_nativeChat && controller == null) return;
    try {
      final result = _nativeChat
          ? session.chatMessages
              .map((message) => [message.text, ...message.citations].join('\n'))
              .join('\n\n')
          : await controller!.evaluateJavascript(
              source:
                  'window.otNotebook ? window.otNotebook.conversation() : ""',
            );
      final text = result is String ? result.trim() : '';
      if (_authService.currentUser?.uid != owner) return;
      if (text.isEmpty) {
        if (mounted) AppSnackBar.warning(context, AppCopy.noConversationToCopy);
        return;
      }
      final formatted = text;
      // 1. Simpan langsung ke Catatan (Bookmarks)
      final bookmark = copiedAnswerBookmark(formatted, session.agent);
      await _bookmarkService.addBookmark(bookmark, userId: owner);
      if (_authService.currentUser?.uid != owner) return;

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

    showAdaptiveSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(OTRadius.dialog)),
              border: Border.all(color: border, width: 0.8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(child: SheetGrabber()),
                const SizedBox(height: 18),
                Text(
                  AppCopy.studyOptions,
                  style: OTTypography.cardTitle(color: textPrimary)
                      .copyWith(fontSize: OTFontSize.s16),
                ),
                const SizedBox(height: 6),
                Text(
                  Loc.tr('readingFontSizeHint'),
                  style: OTTypography.caption(color: textSecondary),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text('A',
                        style: ScholarlyFonts.outfit(
                            fontSize: OTFontSize.s14,
                            fontWeight: FontWeight.w700,
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
                          AgentSessionTab.defaultFontScale = val;
                          SharedPreferences.getInstance().then((prefs) {
                            prefs.setDouble('turath_font_zoom_level', val);
                          }).catchError((_) {});
                          session.webController?.evaluateJavascript(
                            source: '''
                              (function() {
                                if (typeof applyTurathFontScale === "function") {
                                  applyTurathFontScale($val);
                                } else {
                                  var scale = $val;
                                  var basePx = Math.round(scale * 15);
                                  var arabicPx = Math.round(scale * 19);
                                  var fontStyle = document.getElementById('ot-font-scale-style');
                                  if (!fontStyle) {
                                    fontStyle = document.createElement('style');
                                    fontStyle.id = 'ot-font-scale-style';
                                    (document.head || document.documentElement).appendChild(fontStyle);
                                  }
                                  fontStyle.textContent = `
                                    :root, html, body { --ot-font-size: \${basePx}px !important; }
                                    .rendered-markdown, .rendered-markdown *, .chat-response, .chat-response *, [role="article"], [role="article"] *,
                                    .chat-panel-content, .chat-panel-content * {
                                      font-size: \${basePx}px !important;
                                      line-height: 1.7 !important;
                                    }
                                    [lang="ar"], .arabic, [dir="rtl"] {
                                      font-size: \${arabicPx}px !important;
                                    }
                                  `;
                                }
                              })();
                            ''',
                          );
                        },
                      ),
                    ),
                    Text('A',
                        style: ScholarlyFonts.outfit(
                            fontSize: OTFontSize.s22,
                            fontWeight: FontWeight.w700,
                            color: textPrimary)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmDeleteChatHistory(
      BuildContext context, AgentSessionTab session) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = OTColors.surface(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    showAdaptiveSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(OTRadius.dialog)),
          border: Border.all(color: border, width: 0.8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: SheetGrabber()),
            const SizedBox(height: 18),
            Row(
              children: [
                const Icon(Icons.delete_outline_rounded,
                    color: OTColors.borderStrongDark, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    Loc.tr('clearChatHistoryTitle'),
                    style: OTTypography.cardTitle(color: textPrimary)
                        .copyWith(fontSize: OTFontSize.s16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              Loc.tr('clearChatHistoryDesc'),
              style: OTTypography.body(color: textSecondary),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(Loc.tr('cancel'),
                      style: OTTypography.body(color: textSecondary)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OTColors.borderStrongDark,
                    foregroundColor: OTColors.surfaceLight,
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    session.webController?.evaluateJavascript(
                      source:
                          'if (typeof window.otClearChat === "function") { window.otClearChat(); } else if (typeof window.otDeleteChatHistory === "function") { window.otDeleteChatHistory(); }',
                    );
                    if (mounted) {
                      AppSnackBar.success(
                          context, Loc.tr('chatHistoryCleared'));
                    }
                  },
                  child: Text(Loc.tr('delete'),
                      style: ScholarlyFonts.outfit(
                          fontWeight: FontWeight.w600,
                          color: OTColors.surfaceLight)),
                ),
              ],
            ),
          ],
        ),
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
          tooltip: Loc.tr('backToHomeTooltip'),
          onPressed: () {
            AppSnackBar.clear(context);
            _sessionManager.closeRoom();
          },
        ),
        titleSpacing: 0,
        title: Text(
          activeTab.agent.title,
          style: ScholarlyFonts.outfit(
            fontSize: OTFontSize.s16,
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
            tooltip: AppCopy.referenceBooks,
            onPressed: () => _openLibrarySheet(context, activeTab.agent),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: textPrimary, size: 20),
            tooltip: AppCopy.studyOptions,
            color: surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(OTRadius.input),
              side: BorderSide(color: border, width: 0.8),
            ),
            onOpened: () {
              setState(() => activeTab.isMenuOpen = true);
              activeTab.webController?.evaluateJavascript(
                source: '''
(function() {
  if (typeof window.otSetMenuOpen === "function") window.otSetMenuOpen(true);
  var old = document.getElementById('ot-menu-backdrop');
  if (old) old.remove();
  var b = document.createElement('div');
  b.id = 'ot-menu-backdrop';
  b.style.cssText = 'position:fixed!important;top:0!important;left:0!important;width:100vw!important;height:100vh!important;z-index:2147483647!important;background:transparent!important;cursor:default!important;-webkit-tap-highlight-color:transparent!important;';
  function dismiss(e) {
    try { e.preventDefault(); e.stopPropagation(); } catch (_) {}
    b.remove();
    if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
      window.flutter_inappwebview.callHandler('otDismissMenu');
    }
  }
  b.addEventListener('pointerdown', dismiss, true);
  b.addEventListener('mousedown', dismiss, true);
  b.addEventListener('touchstart', dismiss, true);
  b.addEventListener('click', dismiss, true);
  (document.body || document.documentElement).appendChild(b);
})();
''',
              );
            },
            onCanceled: () {
              setState(() => activeTab.isMenuOpen = false);
              activeTab.webController?.evaluateJavascript(
                source:
                    'if (typeof window.otSetMenuOpen === "function") window.otSetMenuOpen(false); var b = document.getElementById("ot-menu-backdrop"); if (b) b.remove();',
              );
            },
            onSelected: (val) {
              setState(() => activeTab.isMenuOpen = false);
              activeTab.webController?.evaluateJavascript(
                source:
                    'if (typeof window.otSetMenuOpen === "function") window.otSetMenuOpen(false); var b = document.getElementById("ot-menu-backdrop"); if (b) b.remove();',
              );
              if (val == 'conversation') {
                _copyActiveConversation(activeTab);
              } else if (val == 'language') {
                activeTab.webController?.evaluateJavascript(
                  source:
                      'if (typeof window.otOpenLanguageSettings === "function") { window.otOpenLanguageSettings(); } else if (typeof otOpenLanguageSettings === "function") { otOpenLanguageSettings(); }',
                );
              } else if (val == 'delete_chat') {
                _confirmDeleteChatHistory(context, activeTab);
              } else if (val == 'font') {
                _showFontScaleDialog(context, activeTab);
              }
            },
            itemBuilder: (ctx) => [
              if (!_nativeChat)
                PopupMenuItem(
                  value: 'language',
                  child: Row(
                    children: [
                      Icon(Icons.language_rounded,
                          color: textPrimary, size: 18),
                      const SizedBox(width: 12),
                      Text(Loc.tr('outputLanguage'),
                          style: OTTypography.body(color: textPrimary)),
                    ],
                  ),
                ),
              if (!_nativeChat)
                PopupMenuItem(
                  value: 'delete_chat',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded,
                          color: OTColors.destructive(
                              Theme.of(ctx).brightness == Brightness.dark),
                          size: 18),
                      const SizedBox(width: 12),
                      Text(Loc.tr('clearChatHistory'),
                          style: OTTypography.body(
                              color: OTColors.destructive(
                                  Theme.of(ctx).brightness ==
                                      Brightness.dark))),
                    ],
                  ),
                ),
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
              if (!_nativeChat)
                PopupMenuItem(
                  value: 'font',
                  child: Row(
                    children: [
                      Icon(Icons.format_size_rounded,
                          color: textPrimary, size: 18),
                      const SizedBox(width: 12),
                      Text(Loc.tr('fontSizeLabel'),
                          style: OTTypography.body(color: textPrimary)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(width: 4),
        ],
        // Chrome-like Multi-Tab Bar (Tampil di semua platform jika terdapat lebih dari 1 sesi aktif)
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
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    itemCount: sessions.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      final isActive = index == _sessionManager.activeIndex;

                      return Container(
                        decoration: BoxDecoration(
                          color: isActive ? surface : Colors.transparent,
                          borderRadius: BorderRadius.circular(OTRadius.xs),
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
                              borderRadius:
                                  const BorderRadiusDirectional.horizontal(
                                          start: Radius.circular(OTRadius.xs))
                                      .resolve(Directionality.of(context)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline_rounded,
                                      size: 13,
                                      color: isActive
                                          ? textPrimary
                                          : textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      session.agent.title,
                                      style: ScholarlyFonts.outfit(
                                        fontSize: OTFontSize.s12,
                                        fontWeight: isActive
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        color: isActive
                                            ? textPrimary
                                            : textSecondary,
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
                                  borderRadius:
                                      BorderRadius.circular(OTRadius.input),
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
        key: const ValueKey('study-webviews'),
        index: _sessionManager.activeIndex,
        children: [
          for (int i = 0; i < sessions.length; i++)
            if (_browserCompanionPrototype)
              BrowserCompanionChatTab(
                key: ValueKey('companion_agent_tab_${sessions[i].agent.id}'),
                session: sessions[i],
              )
            else if (_backendChatPrototype)
              NotebookBackendChatTab(
                key: ValueKey('native_agent_tab_${sessions[i].agent.id}'),
                session: sessions[i],
              )
            else
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

      window.applyTurathFontScale = function(value) {
        var scale = Number(value);
        if (!Number.isFinite(scale)) return;
        scale = Math.max(0.85, Math.min(2, scale));
        var basePx = Math.round(scale * 15);
        var arabicPx = Math.round(scale * 19);

        if (document.documentElement && document.documentElement.style && typeof document.documentElement.style.setProperty === 'function') {
          document.documentElement.style.setProperty('--ot-font-size', basePx + 'px');
        }
        if (document.body && document.body.style && typeof document.body.style.setProperty === 'function') {
          document.body.style.setProperty('--ot-font-size', basePx + 'px');
        }

        try {
          // Direction follows the first letter, never the presence of an Arabic quote.
          // Do not change wrapper divs: their children can have different directions.
          var arabicLetter = /[\u0620-\u064A\u066E-\u06D3\u06FA-\u06FC\u0750-\u077F\u08A0-\u08C9\uFB50-\uFDFF\uFE70-\uFEFF]/;
          var firstLetter = /[A-Za-z\u00C0-\u024F\u0620-\u064A\u066E-\u06D3\u06FA-\u06FC\u0750-\u077F\u08A0-\u08C9\uFB50-\uFDFF\uFE70-\uFEFF]/;
          var els = document.querySelectorAll('.rendered-markdown p, .rendered-markdown li, [role="article"] p, [role="article"] li');
          if (els && typeof els.forEach === 'function') {
            els.forEach(function(el) {
              var first = (el.textContent || '').match(firstLetter);
              var rtl = !!first && arabicLetter.test(first[0]);
              el.setAttribute('dir', rtl ? 'rtl' : 'ltr');
              if (el.classList && typeof el.classList.toggle === 'function') el.classList.toggle('arabic', rtl);
              if (el.style) { el.style.textAlign = rtl ? 'right' : 'left'; el.style.unicodeBidi = 'plaintext'; }
            });
          }
        } catch (_) {}

        var fontStyle = document.getElementById('ot-font-scale-style');
        if (!fontStyle) {
          fontStyle = document.createElement('style');
          fontStyle.id = 'ot-font-scale-style';
          (document.head || document.documentElement).appendChild(fontStyle);
        }
        fontStyle.textContent = `
          :root, html, body {
            --ot-font-size: ${basePx}px !important;
          }
          .chat-panel-content, .chat-view, .conversation-container, .message-list, [role="article"],
          .rendered-markdown, .chat-response, .chat-message, .model-message, .user-message,
          .to-user-container, .to-model-container, app-chat-message {
            font-size: ${basePx}px !important;
            line-height: 1.7 !important;
          }
          .rendered-markdown p, .rendered-markdown span, .rendered-markdown li, .rendered-markdown div,
          .chat-response p, .chat-response span, .chat-response li, .chat-response div,
          [role="article"] p, [role="article"] span, [role="article"] li, [role="article"] div,
          .chat-panel-content p, .chat-panel-content span, .chat-panel-content li, .chat-panel-content div,
          .to-user-container p, .to-user-container span, .to-user-container li, .to-user-container div,
          .to-model-container p, .to-model-container span, .to-model-container li, .to-model-container div {
            font-size: ${basePx}px !important;
            line-height: 1.7 !important;
          }
          [lang="ar"], .arabic, [dir="rtl"] {
            font-size: ${arabicPx}px !important;
            line-height: 1.85 !important;
          }
        `;
      };

      var _otMenuIsOpen = false;
      function _otDismiss() {
        if (!_otMenuIsOpen) return;
        _otMenuIsOpen = false;
        try {
          var el = document.getElementById('ot-menu-backdrop');
          if (el) el.remove();
        } catch (_) {}
        try {
          if (window.flutter_inappwebview && typeof window.flutter_inappwebview.callHandler === 'function') {
            window.flutter_inappwebview.callHandler('otDismissMenu');
          }
        } catch (_) {}
      }

      function _otHandleOutsideInteraction(e) {
        if (!_otMenuIsOpen) return;
        try {
          e.preventDefault();
          e.stopPropagation();
          if (typeof e.stopImmediatePropagation === 'function') {
            e.stopImmediatePropagation();
          }
        } catch (_) {}
        _otDismiss();
      }

      window.otSetMenuOpen = function(isOpen) {
        _otMenuIsOpen = !!isOpen;
        try {
          var old = document.getElementById('ot-menu-backdrop');
          if (old) old.remove();
        } catch (_) {}

        if (typeof window.removeEventListener === 'function') {
          window.removeEventListener('pointerdown', _otHandleOutsideInteraction, true);
          window.removeEventListener('mousedown', _otHandleOutsideInteraction, true);
          window.removeEventListener('touchstart', _otHandleOutsideInteraction, true);
          window.removeEventListener('click', _otHandleOutsideInteraction, true);
        }

        if (_otMenuIsOpen) {
          if (typeof window.addEventListener === 'function') {
            window.addEventListener('pointerdown', _otHandleOutsideInteraction, true);
            window.addEventListener('mousedown', _otHandleOutsideInteraction, true);
            window.addEventListener('touchstart', _otHandleOutsideInteraction, true);
            window.addEventListener('click', _otHandleOutsideInteraction, true);
          }
          try {
            if (document && document.body && typeof document.createElement === 'function' && typeof document.body.appendChild === 'function') {
              var backdrop = document.createElement('div');
              backdrop.id = 'ot-menu-backdrop';
              backdrop.setAttribute('style', 'position:fixed!important;top:0!important;left:0!important;width:100vw!important;height:100vh!important;z-index:2147483647!important;background:transparent!important;cursor:default!important;-webkit-tap-highlight-color:transparent!important;');
              backdrop.addEventListener('pointerdown', _otHandleOutsideInteraction, true);
              backdrop.addEventListener('mousedown', _otHandleOutsideInteraction, true);
              backdrop.addEventListener('touchstart', _otHandleOutsideInteraction, true);
              backdrop.addEventListener('click', _otHandleOutsideInteraction, true);
              document.body.appendChild(backdrop);
            }
          } catch (_) {}
        }
      };
    })();
  """;

  static UserScript _buildCloakScript(bool isDark) {
    final themeInitScript = '''
      (function() {
        try {
          if (!['notebooklm.google.com', 'notebook.google.com'].includes(window.location.hostname)) {
            return;
          }
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
          styleEl.textContent = ${isDark ? "'html, body { background-color: #18181B !important; color: #E4E4E7 !important; }'" : "'html, body { background-color: #FFFFFF !important; color: #18181B !important; }'"};

          if (window.otNotebook && typeof window.otNotebook.setTheme === 'function') {
            window.otNotebook.setTheme($isDark);
          }
        } catch(e) {}
      })();
    ''';

    return UserScript(
      source: '$_turatsMasterScript\n$notebookUiScript\n$themeInitScript',
      injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
      forMainFrameOnly: true,
    );
  }

  Timer? _readinessTimer;
  Timer? _inputRetryTimer;
  DateTime? _loadingStarted;
  int _readySamples = 0;
  int _accessDeniedRetryCount = 0;
  bool _checkingReady = false;
  bool? _lastIsDark;
  DateTime? _lastCopiedToastAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AgentSessionManager.instance.addListener(_onSessionManagerChanged);
    if (widget.session.resolvedUrl == null) {
      _fetchUrl();
    }
  }

  void _onSessionManagerChanged() {
    if (!mounted) return;
    final isOpen = AgentSessionManager.instance.isOpen;
    if (!isOpen) {
      // Room ditutup/disembunyikan: jeda/batalkan timer agar tidak memboroskan CPU
      _readinessTimer?.cancel();
      _readinessTimer = null;
      _inputRetryTimer?.cancel();
      _inputRetryTimer = null;
      _loadingStarted = null;
      try {
        widget.session.webController?.evaluateJavascript(
          source:
              'window.otSetBackgroundPaused && window.otSetBackgroundPaused(true);',
        );
      } catch (_) {}
    } else if (widget.isActive &&
        !widget.session.isSessionReady &&
        _readinessTimer == null) {
      // Room dibuka kembali dan sesi belum siap: lanjutkan polling kesiapan
      try {
        widget.session.webController?.evaluateJavascript(
          source:
              'window.otSetBackgroundPaused && window.otSetBackgroundPaused(false);',
        );
      } catch (_) {}
      _startReadinessCheck();
    }
  }

  @override
  void didUpdateWidget(_SingleAgentTabWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive && !widget.isActive) {
      // Tab ini beralih ke background: hentikan polling dan bekukan observer DOM
      _readinessTimer?.cancel();
      _readinessTimer = null;
      _inputRetryTimer?.cancel();
      _inputRetryTimer = null;
      try {
        widget.session.webController?.evaluateJavascript(
          source:
              'window.otSetBackgroundPaused && window.otSetBackgroundPaused(true);',
        );
      } catch (_) {}
    } else if (!oldWidget.isActive && widget.isActive) {
      _verifySurfaceHealth();
      try {
        widget.session.webController?.evaluateJavascript(
          source:
              'window.otSetBackgroundPaused && window.otSetBackgroundPaused(false); window.otNotebook && window.otNotebook.clean && window.otNotebook.clean();',
        );
      } catch (_) {}
      if (!widget.session.isSessionReady &&
          AgentSessionManager.instance.isOpen) {
        _startReadinessCheck();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AgentSessionManager.instance.removeListener(_onSessionManagerChanged);
    _readinessTimer?.cancel();
    _readinessTimer = null;
    _inputRetryTimer?.cancel();
    _inputRetryTimer = null;
    if (mounted) {
      AppSnackBar.clear(context);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (AppPlatform.isAndroid) {
        unawaited(
            widget.session.webController?.resume().catchError((Object _) {}) ??
                Future<void>.value());
      }
      _verifySurfaceHealth();
    } else if (state == AppLifecycleState.paused) {
      if (AppPlatform.isAndroid) {
        unawaited(
            widget.session.webController?.pause().catchError((Object _) {}) ??
                Future<void>.value());
      }
    }
  }

  Future<void> _verifySurfaceHealth() async {
    // Jangan pernah mengganggu atau me-reload WebView yang sedang loading atau belum siap
    if (widget.session.isWebLoading || !widget.session.isSessionReady) return;
    final controller = widget.session.webController;
    if (controller == null || !mounted) return;
    try {
      final res = await controller.evaluateJavascript(source: '1+1');
      if (res != 2) {
        controller.reload();
      }
    } catch (_) {
      // Jeda fokus mikro tidak boleh langsung memicu reload agresif
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
            styleEl.textContent = ${isDark ? "'html, body { background-color: #18181B !important; color: #E4E4E7 !important; }'" : "'html, body { background-color: #FFFFFF !important; color: #18181B !important; }'"};

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
    _inputRetryTimer?.cancel();
    _loadingStarted ??= DateTime.now();
    _readySamples = 0;
    _readinessTimer =
        Timer.periodic(const Duration(milliseconds: 500), (_) => _checkReady());
    _inputRetryTimer = Timer(const Duration(seconds: 15), _recoverMissingInput);
  }

  Future<void> _recoverMissingInput() async {
    final controller = widget.session.webController;
    if (!mounted || controller == null) return;
    try {
      final url = await controller.getUrl();
      if (url == null || !NotebookNavigation.notebook(url.uriValue)) return;
      final inputReady = await controller.evaluateJavascript(
        source: 'window.otNotebook?.inputReady() === true',
      );
      if (inputReady != true) {
        await controller.evaluateJavascript(source: notebookUiScript);
      }
    } catch (_) {
      // Navigasi atau penutupan tab dapat membatalkan pemeriksaan ini.
    }
  }

  void _handleAccessDenied(AgentSessionTab session) {
    final user = AuthService().cachedCurrentUser;
    final hasActiveEntitlement = user != null &&
        (user.isVip ||
            (user.isSubscriptionActive &&
                user.isAgentSubscriptionActive(session.agent.id)));

    if (hasActiveEntitlement && _accessDeniedRetryCount < 5) {
      _accessDeniedRetryCount++;
      _readinessTimer?.cancel();
      Future.delayed(const Duration(seconds: 4), () {
        if (!mounted) return;
        session.webController?.reload();
        _startReadinessCheck();
      });
      return;
    }

    _readinessTimer?.cancel();
    _loadingStarted = null;
    if (mounted) {
      setState(() {
        session.isWebLoading = false;
        session.isSessionReady = false;
        session.isGooglePermissionError = true;
        session.isPaywallRequired = false;
        session.isTimeoutError = false;
        session.errorMessage = Loc.tr('roomGooglePermissionDetail');
      });
    }
  }

  /// Halaman masuk Google ditampilkan apa adanya secara bersih tanpa banner.
  void _enterGoogleSignIn() {
    // Jangan batalkan _readinessTimer agar saat Google selesai redirect/autentikasi,
    // kesiapan sesi AI langsung terdeteksi otomatis.
    _inputRetryTimer?.cancel();
    _loadingStarted = null;
    if (!mounted) return;
    setState(() {
      final session = widget.session;
      session.isWebLoading = false;
      session.isSessionReady = false;
      session.isGoogleAuthPage = true;
      session.errorMessage = null;
    });
  }

  Future<void> _checkReady() async {
    if (_checkingReady ||
        widget.session.webController == null ||
        !mounted ||
        !AgentSessionManager.instance.isOpen ||
        !widget.isActive) {
      return;
    }
    _checkingReady = true;
    try {
      final controller = widget.session.webController!;
      final url = await controller.getUrl();
      if (url != null && NotebookNavigation.notebook(url.uriValue)) {
        if (widget.session.isGoogleAuthPage && mounted) {
          setState(() {
            widget.session.isGoogleAuthPage = false;
            widget.session.errorMessage = null;
            widget.session.isWebLoading = true;
          });
        }
      } else if (url != null && NotebookNavigation.signInFlow(url.uriValue)) {
        _loadingStarted = null;
        if (!widget.session.isGoogleAuthPage) _enterGoogleSignIn();
        return;
      }
      if (widget.session.isGoogleAuthPage) {
        _loadingStarted = null;
        return;
      }

      _loadingStarted ??= DateTime.now();
      final elapsedSec = DateTime.now().difference(_loadingStarted!).inSeconds;
      if (elapsedSec >= 45) {
        if (kDebugMode) {
          Object? title;
          try {
            title = await controller.evaluateJavascript(
                source: 'document.title + " | inputs=" + '
                    'document.querySelectorAll(\'textarea, [contenteditable="true"], [role="textbox"]\').length');
          } catch (_) {}
          debugPrint(
              '[OpenTurath] Readiness timeout: host=${url?.host} path=${url?.path} page=$title');
        }
        _readinessTimer?.cancel();
        _inputRetryTimer?.cancel();
        _loadingStarted = null;
        if (mounted) {
          setState(() {
            widget.session.isWebLoading = false;
            widget.session.isSessionReady = false;
            widget.session.isTimeoutError = true;
            widget.session.errorMessage = Loc.tr('roomNotReadyBody');
          });
        }
        return;
      }

      if (url == null || !NotebookNavigation.notebook(url.uriValue)) {
        return;
      }
      if (widget.session.isGoogleAuthPage) {
        if (mounted) {
          setState(() {
            widget.session.isGoogleAuthPage = false;
            widget.session.errorMessage = null;
          });
        } else {
          widget.session.isGoogleAuthPage = false;
          widget.session.errorMessage = null;
        }
      }
      final hasScript = await controller.evaluateJavascript(
        source:
            'typeof window.otNotebook !== "undefined" && typeof window.otNotebook.ready === "function"',
      );
      if (hasScript != true) {
        if (!mounted) return;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        await controller.evaluateJavascript(
          source:
              'window._otIsDark = $isDark;\n$_turatsMasterScript$notebookUiScript',
        );
        await _applyThemeCss(isDark);
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
      // Wajib stabil: minimal 4 sampel berturut-turut (2 detik) dan minimal 3000ms berlalu
      // agar tidak ada flicker atau pemunculan dini sebelum layout Angular selesai sempurna.
      if (_readySamples >= 4 && elapsedMs >= 3000) {
        _readinessTimer?.cancel();
        _inputRetryTimer?.cancel();
        _loadingStarted = null;
        await controller.evaluateJavascript(
          source: 'window.otNotebook?.activate()',
        );
        // Jeda mikro stabilisasi 250ms agar rendering WebKit rampung sebelum fade-out loader
        await Future.delayed(const Duration(milliseconds: 250));
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('google_session_ready', true);
        } catch (_) {}
        await AuthService.rememberWebSessionOwner(
            _authService.currentUser?.email ?? '');
        if (!mounted) return;
        setState(() {
          widget.session.isWebLoading = false;
          widget.session.isSessionReady = true;
          widget.session.isGooglePermissionError = false;
          widget.session.errorMessage = null;
          widget.session.isTimeoutError = false;
        });
        _syncInitialHistory();
      }
    } catch (_) {
    } finally {
      _checkingReady = false;
    }
  }

  Future<void> _syncInitialHistory() async {
    final controller = widget.session.webController;
    if (controller == null) return;
    try {
      final dynamic raw = await controller.evaluateJavascript(
        source:
            'window.otGetConversationList ? window.otGetConversationList() : "[]"',
      );
      dynamic decoded = raw;
      if (raw is String) {
        try {
          decoded = jsonDecode(raw);
        } catch (_) {
          decoded = [];
        }
      }
      if (decoded != null && decoded is List && mounted) {
        final messages = <TurathChatMessage>[];
        for (var i = 0; i < decoded.length; i++) {
          final item = decoded[i];
          if (item is Map) {
            final text = item['text']?.toString() ?? '';
            final isUser = item['isUser'] == true;
            if (text.isNotEmpty) {
              messages.add(TurathChatMessage(
                id: 'history_$i',
                text: text,
                isUser: isUser,
                timestamp: DateTime.now()
                    .subtract(Duration(minutes: decoded.length - i)),
              ));
            }
          }
        }
        if (messages.isNotEmpty) {
          setState(() {
            widget.session.chatMessages
              ..clear()
              ..addAll(messages);
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchUrl() async {
    final session = widget.session;
    setState(() {
      session.isUrlLoading = true;
      session.errorMessage = null;
      session.isPaywallRequired = false;
    });

    if (_authService.currentUser == null) {
      await _authService.restoreSession();
    }

    // The server owns current rights; a stale local profile must not turn a
    // paid-but-provisioning assignment into a request to purchase again.
    final openingUid =
        _authService.currentUser?.uid ?? _authService.cachedCurrentUser?.uid;

    try {
      final url = await _agentService.getAgentUrl(session.agent.id);
      final currentUid =
          _authService.currentUser?.uid ?? _authService.cachedCurrentUser?.uid;
      if (!mounted ||
          (openingUid != null &&
              currentUid != null &&
              currentUid != openingUid)) {
        return;
      }
      if (url != null && url.isNotEmpty) {
        setState(() {
          session.resolvedUrl = url;
          session.isUrlLoading = false;
          session.isPaywallRequired = false;
          session.errorMessage = null;
        });
      } else {
        final user = _authService.cachedCurrentUser;
        final isVip = user?.isVip == true;
        setState(() {
          session.isUrlLoading = false;
          session.isPaywallRequired = !isVip;
          session.errorMessage = isVip
              ? 'Sesi AI sedang disiapkan. Coba lagi sebentar.'
              : 'Aktifkan paket langganan untuk membuka ${session.agent.title}.';
        });
      }
    } catch (e) {
      final currentUid =
          _authService.currentUser?.uid ?? _authService.cachedCurrentUser?.uid;
      if (!mounted ||
          (openingUid != null &&
              currentUid != null &&
              currentUid != openingUid)) {
        return;
      }
      final msg = e.toString().toLowerCase();

      final user = _authService.cachedCurrentUser;
      final isVip = user?.isVip == true;
      final hasAgentAccess =
          user != null && user.hasAccessToAgent(session.agent.id);

      // Rule 5: Akun VIP sejati atau pengguna dengan akses aktif DILARANG KERAS terkena paywall.
      // Paywall HANYA aktif jika server eksplisit menolak hak akses ('permission-denied')
      // DAN pengguna memang bukan VIP serta tidak memiliki akses aktif ke modul ini.
      final isPaywall = !isVip &&
          !hasAgentAccess &&
          (msg.contains('permission-denied') ||
              (e is AgentAccessException && e.code == 'permission-denied'));

      final isAuthError = msg.contains('unauthenticated') ||
          (e is AgentAccessException && e.code == 'unauthenticated');

      setState(() {
        session.isUrlLoading = false;
        session.isPaywallRequired = isPaywall;
        session.errorMessage = isPaywall
            ? 'Aktifkan paket langganan untuk membuka ${session.agent.title}.'
            : isAuthError
                ? 'Sesi masuk Anda belum terhubung. Muat ulang atau masuk kembali.'
                : e is AgentAccessException && e.code == 'failed-precondition'
                    ? e.message
                    : 'AI belum bisa dihubungkan. Coba lagi.';
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
      void close() => AgentSessionManager.instance.closeRoom();

      Future<void> openInBrowser() async {
        final url = session.resolvedUrl;
        if (url == null) return;
        final email = await NativeAgentLauncher.getActiveNotebookEmail();
        await NativeAgentLauncher.launchNotebook(url,
            email: email.isNotEmpty ? email : null);
      }

      void retry() {
        setState(() {
          session.errorMessage = null;
          session.isTimeoutError = false;
          session.isGooglePermissionError = false;
          session.isPaywallRequired = false;
          session.isWebLoading = true;
          session.isSessionReady = false;
        });
        _loadingStarted = DateTime.now();
        if (session.webController != null) {
          session.webController!.reload();
          _startReadinessCheck();
        } else {
          _fetchUrl();
        }
      }

      // Satu tampilan untuk empat keadaan; naskahnya mengikuti penyebab,
      // bukan pesan teknis dari WebView.
      final AppErrorState state;
      if (session.isPaywallRequired) {
        state = AppErrorState(
          icon: Icons.lock_outline_rounded,
          title: Loc.tr('roomPaywallTitle'),
          message: Loc.tr('roomPaywallBody', [Loc.text(session.agent.title)]),
          retryLabel: Loc.tr('roomSeePlans'),
          retryIcon: Icons.arrow_forward_rounded,
          onRetry: () => NavigationGuard.safePushNamed(
            context,
            AppRoutes.subscription,
            arguments: {
              'user': _authService.cachedCurrentUser,
              'agent': session.agent,
            },
          ),
          onBack: close,
          backLabel: Loc.tr('back'),
        );
      } else if (session.isGoogleAuthPage) {
        final email = _authService.currentUser?.email?.trim() ?? '';
        state = AppErrorState(
          icon: Icons.link_rounded,
          title: Loc.tr('roomSameAccountTitle'),
          message: email.isNotEmpty
              ? Loc.tr('roomSameAccountBody', [email])
              : Loc.tr('roomSameAccountBodyPlain'),
          retryLabel: Loc.tr('roomLoginNow'),
          retryIcon: Icons.login_rounded,
          onRetry: () async {
            await Navigator.pushNamed(context, AppRoutes.googleSessionAuth);
            if (!mounted) return;
            if (session.resolvedUrl != null) {
              setState(() {
                session.errorMessage = null;
                session.isGoogleAuthPage = false;
                session.isWebLoading = true;
                session.isSessionReady = false;
              });
              _loadingStarted = null;
              session.webController?.loadUrl(
                urlRequest: URLRequest(url: WebUri(session.resolvedUrl!)),
              );
              _startReadinessCheck();
            }
          },
          secondaryLabel: Loc.tr('roomOpenInBrowser'),
          onSecondary: session.resolvedUrl == null ? null : openInBrowser,
          onBack: close,
          backLabel: Loc.tr('back'),
        );
      } else if (session.isGooglePermissionError) {
        state = AppErrorState(
          icon: Icons.account_circle_outlined,
          title: Loc.tr('roomPermissionTitle'),
          message: Loc.tr('roomPermissionBody'),
          retryLabel: Loc.tr('ui_f9d6eb247c'),
          retryIcon: Icons.switch_account_outlined,
          onRetry: () async {
            await PersistentGoogleSession.instance.clearOnSignOut();
            if (context.mounted) {
              await Navigator.pushNamed(context, AppRoutes.googleSessionAuth);
              if (!mounted) return;
              if (session.resolvedUrl != null) {
                setState(() {
                  session.errorMessage = null;
                  session.isGooglePermissionError = false;
                  session.isGoogleAuthPage = false;
                  session.isWebLoading = true;
                  session.isSessionReady = false;
                });
                _loadingStarted = null;
                session.webController?.loadUrl(
                  urlRequest: URLRequest(url: WebUri(session.resolvedUrl!)),
                );
                _startReadinessCheck();
              }
            }
          },
          secondaryLabel: Loc.tr('roomOpenInBrowser'),
          onSecondary: session.resolvedUrl == null ? null : openInBrowser,
          onBack: close,
          backLabel: Loc.tr('back'),
        );
      } else {
        state = AppErrorState(
          icon: Icons.public_off_rounded,
          title: Loc.tr('roomLoadFailTitle'),
          message: session.errorMessage ?? Loc.tr('roomLoadFailBody'),
          retryLabel: Loc.tr('tryAgain'),
          onRetry: retry,
          onBack: close,
          backLabel: Loc.tr('back'),
        );
      }
      return ColoredBox(color: canvas, child: state);
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
              incognito: false,
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
              supportMultipleWindows: true,
              javaScriptCanOpenWindowsAutomatically: true,
              isInspectable: true,
              forceDark: isDark ? ForceDark.ON : ForceDark.OFF,
              forceDarkStrategy:
                  ForceDarkStrategy.PREFER_WEB_THEME_OVER_USER_AGENT_DARKENING,
              algorithmicDarkeningAllowed: true,
            ),
            onCreateWindow: (controller, createWindowAction) async {
              final targetUrl = createWindowAction.request.url;
              if (targetUrl != null &&
                  (NotebookNavigation.signInFlow(targetUrl.uriValue) ||
                      NotebookNavigation.allowed(targetUrl.uriValue))) {
                await controller.loadUrl(
                    urlRequest: URLRequest(url: targetUrl));
                return true;
              }
              return false;
            },
            onReceivedError: (controller, request, error) async {
              if (request.isForMainFrame != true || !mounted) return;
              // Navigasi yang kita batalkan sendiri (mis. ke halaman masuk
              // Google) dilaporkan WebKit sebagai "frame load interrupted";
              // itu bukan gangguan jaringan dan keadaannya sudah ditangani.
              final detail = error.description.toLowerCase();
              if (session.isGoogleAuthPage ||
                  error.type == WebResourceErrorType.CANCELLED ||
                  detail.contains('interrupted') ||
                  detail.contains('cancel')) {
                return;
              }
              debugPrint(
                  '[OpenTurath] Main-document load failed: ${error.type}');
              final current = await controller.getUrl();
              if (!mounted) return;
              if (session.isSessionReady &&
                  current != null &&
                  NotebookNavigation.notebook(current.uriValue) &&
                  current.toString() != request.url.toString()) {
                return;
              }
              _readinessTimer?.cancel();
              setState(() {
                session.isWebLoading = false;
                session.isSessionReady = false;
                session.isTimeoutError = true;
                session.errorMessage = Loc.tr('roomLoadFailBody');
              });
            },
            onReceivedHttpError: (controller, request, errorResponse) {
              final code = errorResponse.statusCode;
              final requestUri = request.url.uriValue;
              if (request.isForMainFrame == true &&
                  mounted &&
                  NotebookNavigation.notebook(requestUri)) {
                if (code == 403) {
                  _readinessTimer?.cancel();
                  setState(() {
                    session.isWebLoading = false;
                    session.isSessionReady = false;
                    session.isGooglePermissionError = true;
                    session.isPaywallRequired = false;
                    session.errorMessage = Loc.tr('roomGooglePermissionDetail');
                  });
                } else if (code != null && code >= 400) {
                  _readinessTimer?.cancel();
                  _inputRetryTimer?.cancel();
                  setState(() {
                    session.isWebLoading = false;
                    session.isSessionReady = false;
                    session.isTimeoutError = false;
                    session.errorMessage = Loc.tr('roomHttpFailure', ['$code']);
                  });
                }
              }
            },
            onRenderProcessGone: (controller, detail) async {
              debugPrint(
                  '[OpenTurath] WebView render process gone (didCrash: ${detail.didCrash})');
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
                  try {
                    final owner = _authService.currentUser?.uid;
                    if (owner == null) return false;
                    final url = await controller.getUrl();
                    if (_authService.currentUser?.uid != owner) return false;
                    if (url?.scheme != 'https' ||
                        !['notebooklm.google.com', 'notebook.google.com']
                            .contains(url?.host) ||
                        args.isEmpty ||
                        args.first is! String) {
                      return false;
                    }
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
                      if (context.mounted &&
                          _authService.currentUser?.uid == owner) {
                        OTMotion.light();
                        AppSnackBar.success(
                          context,
                          AppCopy.answerCopied,
                          duration: const Duration(milliseconds: 2500),
                          action: SnackBarAction(
                            label: Loc.tr('save'),
                            textColor: OTColors.onInverseSurface,
                            onPressed: () {
                              if (_authService.currentUser?.uid == owner) {
                                unawaited(_bookmarkService.addBookmark(
                                  copiedAnswerBookmark(text, session.agent),
                                  userId: owner,
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
              controller.addJavaScriptHandler(
                handlerName: 'otAnswerState',
                callback: (args) {
                  if (!mounted || args.isEmpty) return;
                  final first = args.first;
                  String? state;
                  String? currentText;
                  if (first is Map) {
                    state = first['state']?.toString();
                    currentText = first['text']?.toString();
                  } else {
                    state = first?.toString();
                  }

                  if (state == 'generating') {
                    setState(() {
                      session.isGenerating = true;
                    });
                  } else if (state == 'completed') {
                    setState(() {
                      session.isGenerating = false;
                      if (currentText != null && currentText.isNotEmpty) {
                        if (session.chatMessages.isNotEmpty &&
                            !session.chatMessages.last.isUser) {
                          final last = session.chatMessages.last;
                          session.chatMessages[session.chatMessages.length -
                              1] = last.copyWith(text: currentText);
                        } else {
                          session.chatMessages.add(TurathChatMessage(
                            id: 'bot_${DateTime.now().millisecondsSinceEpoch}',
                            text: currentText,
                            isUser: false,
                            timestamp: DateTime.now(),
                          ));
                        }
                      }
                    });
                  }
                },
              );
              controller.addJavaScriptHandler(
                handlerName: 'otAnswerChunk',
                callback: (args) {
                  if (!mounted || args.isEmpty) return;
                  final first = args.first;
                  String text = '';
                  if (first is Map) {
                    text = first['text']?.toString() ?? '';
                  } else if (first is String) {
                    text = first;
                  }
                  if (text.isEmpty) return;

                  setState(() {
                    session.isGenerating = false;
                    if (session.chatMessages.isNotEmpty &&
                        !session.chatMessages.last.isUser) {
                      final last = session.chatMessages.last;
                      session.chatMessages[session.chatMessages.length - 1] =
                          last.copyWith(text: text);
                    } else {
                      session.chatMessages.add(TurathChatMessage(
                        id: 'bot_${DateTime.now().millisecondsSinceEpoch}',
                        text: text,
                        isUser: false,
                        timestamp: DateTime.now(),
                      ));
                    }
                  });
                },
              );
              controller.addJavaScriptHandler(
                handlerName: 'otDismissMenu',
                callback: (args) {
                  // The page reports one tap through several pointer events.
                  // Only the first may close the menu; a later call with no
                  // menu open would otherwise pop the study room itself.
                  if (mounted && session.isMenuOpen) {
                    setState(() => session.isMenuOpen = false);
                    final nav = Navigator.of(context, rootNavigator: false);
                    if (nav.canPop()) {
                      nav.pop();
                    } else {
                      final rootNav =
                          Navigator.of(context, rootNavigator: true);
                      if (rootNav.canPop()) {
                        rootNav.pop();
                      }
                    }
                  }
                  return true;
                },
              );
              if (!session.isSessionReady) {
                _startReadinessCheck();
              }
            },
            onLoadStart: (controller, uri) async {
              session.hasInjectedEarlyScript = false;
              _loadingStarted = DateTime.now();
              if (uri != null) {
                if (NotebookNavigation.notebook(uri.uriValue)) {
                  if (session.isGoogleAuthPage && mounted) {
                    setState(() {
                      session.isGoogleAuthPage = false;
                      session.isWebLoading = true;
                      session.errorMessage = null;
                    });
                  }
                } else if (NotebookNavigation.signInFlow(uri.uriValue)) {
                  if (!session.isGoogleAuthPage) _enterGoogleSignIn();
                  return;
                }
              }
              if (session.isGoogleAuthPage &&
                  uri != null &&
                  !NotebookNavigation.notebook(uri.uriValue)) {
                return;
              }
              final host = uri?.host.toLowerCase() ?? '';
              if (host.startsWith('accounts.google') ||
                  host == 'consent.google.com') {
                session.isSessionReady = false;
              }
              // Hanya aktifkan full loader jika sesi BELUM pernah siap sama sekali dan bukan pada halaman akun Google
              if (mounted &&
                  !session.isSessionReady &&
                  !session.isWebLoading &&
                  !host.startsWith('accounts.google') &&
                  host != 'consent.google.com') {
                setState(() => session.isWebLoading = true);
              }
              if (!session.isSessionReady) {
                _startReadinessCheck();
              }
            },
            onLoadStop: (controller, uri) async {
              if (!mounted || uri == null) return;

              final host = uri.host.toLowerCase();
              if (host.startsWith('accounts.google') ||
                  host == 'accounts.youtube.com' ||
                  host == 'consent.google.com') {
                return;
              }

              if (!NotebookNavigation.notebook(uri.uriValue)) {
                return;
              }

              if (session.isGoogleAuthPage && mounted) {
                setState(() {
                  session.isGoogleAuthPage = false;
                  session.errorMessage = null;
                });
              }

              try {
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
              } catch (_) {
                // A navigation or closed tab can invalidate an in-flight script.
              }
            },
            onUpdateVisitedHistory: (controller, uri, isReload) async {
              if (!mounted || uri == null) return;
              if (NotebookNavigation.notebook(uri.uriValue)) {
                if (session.isGoogleAuthPage && mounted) {
                  setState(() {
                    session.isGoogleAuthPage = false;
                    session.errorMessage = null;
                  });
                }
                _startReadinessCheck();
              } else if (NotebookNavigation.signInFlow(uri.uriValue)) {
                if (!session.isGoogleAuthPage && mounted) {
                  _enterGoogleSignIn();
                }
              }
            },
            onProgressChanged: (controller, progress) async {
              final currentUrl = await controller.getUrl();
              if (currentUrl != null &&
                  NotebookNavigation.notebook(currentUrl.uriValue)) {
                if (session.isGoogleAuthPage && mounted) {
                  setState(() {
                    session.isGoogleAuthPage = false;
                    session.errorMessage = null;
                  });
                }
              }
              if (currentUrl == null ||
                  !NotebookNavigation.notebook(currentUrl.uriValue)) {
                return;
              }
              if (mounted &&
                  progress >= 35 &&
                  !session.hasInjectedEarlyScript) {
                session.hasInjectedEarlyScript = true;
                try {
                  await controller.evaluateJavascript(
                      source:
                          'window._otIsDark = $isDark;\n$_turatsMasterScript$notebookUiScript');
                  await _applyThemeCss(isDark);
                } catch (_) {
                  session.hasInjectedEarlyScript = false;
                  _loadingStarted = DateTime.now();
                }
              }
            },
            onConsoleMessage: (controller, consoleMessage) {
              if (consoleMessage.messageLevel == ConsoleMessageLevel.ERROR) {
                debugPrint(
                    '[OpenTurath WebView JS Error] ${consoleMessage.message}');
              }
            },
            shouldOverrideUrlLoading: (controller, action) async {
              final uri = action.request.url;
              if (uri == null) return NavigationActionPolicy.CANCEL;

              // 1. Izinkan selalu jika bukan navigasi frame utama (iframe, background XHR, token, botguard)
              if (action.isForMainFrame != true) {
                return NavigationActionPolicy.ALLOW;
              }

              // 2. Izinkan skema internal
              final scheme = uri.scheme.toLowerCase();
              if (scheme == 'about' ||
                  scheme == 'data' ||
                  scheme == 'blob' ||
                  scheme == 'javascript') {
                return NavigationActionPolicy.ALLOW;
              }

              // 3. Izinkan seluruh ekosistem Google dan NotebookLM
              final host = uri.host.toLowerCase();
              final isGoogleEcosystem = host == 'google.com' ||
                  host.endsWith('.google.com') ||
                  host.endsWith('.google.co.id') ||
                  host.endsWith('.gstatic.com') ||
                  host.endsWith('.googleusercontent.com') ||
                  host.endsWith('.googleapis.com') ||
                  host.endsWith('.recaptcha.net') ||
                  host.endsWith('.youtube.com');

              if (isGoogleEcosystem ||
                  NotebookNavigation.signInFlow(uri.uriValue) ||
                  NotebookNavigation.allowed(uri.uriValue)) {
                if (NotebookNavigation.allowed(uri.uriValue)) {
                  if (session.isGoogleAuthPage && mounted) {
                    setState(() {
                      session.isGoogleAuthPage = false;
                      session.isWebLoading = true;
                      session.errorMessage = null;
                    });
                    _startReadinessCheck();
                  }
                }
                return NavigationActionPolicy.ALLOW;
              }

              // 4. Jika tautan eksternal diklik di main frame (misal referensi di luar Google),
              // buka di browser bawaan sistem agar tidak mengganggu ruang percakapan asisten.
              try {
                if (await canLaunchUrl(uri.uriValue)) {
                  await launchUrl(uri.uriValue,
                      mode: LaunchMode.externalApplication);
                }
              } catch (_) {}
              return NavigationActionPolicy.CANCEL;
            },
          ),

          // Penutup transparan saat menu titik tiga sedang terbuka (khususnya untuk sentuhan Android / Flutter layer)
          if (session.isMenuOpen)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() => session.isMenuOpen = false);
                  session.webController?.evaluateJavascript(
                    source:
                        'var b = document.getElementById("ot-menu-backdrop"); if (b) b.remove();',
                  );
                  final nav = Navigator.of(context, rootNavigator: false);
                  if (nav.canPop()) {
                    nav.pop();
                  } else {
                    final rootNav = Navigator.of(context, rootNavigator: true);
                    if (rootNav.canPop()) {
                      rootNav.pop();
                    }
                  }
                },
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),

          // Layar muat hanya saat inisialisasi awal; memudar ke konten saat siap.
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              switchOutCurve: Curves.easeOut,
              child: (!session.isSessionReady && !session.isGoogleAuthPage)
                  ? AppLoader.fullscreen(
                      key: const ValueKey('room-loader'),
                      title: session.agent.title,
                      subtitle: AppCopy.loadingReferences,
                      onCancel: () => AgentSessionManager.instance.closeRoom(),
                    )
                  : const IgnorePointer(
                      key: ValueKey('room-ready'),
                      child: SizedBox.expand(),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
