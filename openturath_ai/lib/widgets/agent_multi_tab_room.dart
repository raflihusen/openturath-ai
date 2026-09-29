import '../widgets/adaptive_sheet.dart';
import '../services/desktop_webview_runtime.dart';
import '../widgets/desktop_webview_gate.dart';
import '../core/app_platform.dart';
import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/turath_chat_message.dart';

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
import '../services/agent_session_manager.dart';
import '../services/auth_service.dart';
import '../services/bookmark_service.dart';
import '../services/native_agent_launcher.dart';
import '../widgets/app_error_state.dart';
import '../widgets/app_loader.dart';
import '../widgets/library_bottom_sheet.dart';

/// AgentMultiTabRoom: Persistent, multi-tab AI Study Room inspired by Google Chrome tabs.
/// Keeps up to 7 AI specialists running concurrently in memory without reloading.
class AgentMultiTabRoom extends StatefulWidget {
  const AgentMultiTabRoom({super.key});

  /// Dialog pemilihan akun Google khusus untuk asisten NotebookLM.
  /// Memastikan browser eksternal membuka akun yang tepat (/u/<index> atau AccountChooser).
  static Future<void> showChangeGoogleAccountDialog(BuildContext context) async {
    final currentEmail = await NativeAgentLauncher.getActiveNotebookEmail();
    if (!context.mounted) return;
    final controller = TextEditingController(text: currentEmail);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final newEmail = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E22) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.manage_accounts_rounded, color: OTColors.accent(isDark), size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Akun Google untuk Asisten',
                style: ScholarlyFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF18181B),
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
              'Pastikan email ini sesuai dengan akun Google yang memiliki akses ke modul / notebook turats Anda. Browser akan langsung memilih akun ini tanpa salah masuk ke akun lain (/u/0/).',
              style: ScholarlyFonts.outfit(
                fontSize: 12,
                color: isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              style: ScholarlyFonts.outfit(
                fontSize: 14,
                color: isDark ? Colors.white : const Color(0xFF18181B),
              ),
              decoration: InputDecoration(
                hintText: 'nama@gmail.com',
                prefixIcon: const Icon(Icons.email_outlined, size: 18),
                filled: true,
                fillColor: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: ScholarlyFonts.outfit(color: isDark ? Colors.white70 : Colors.black87),
            ),
          ),
          if (AuthService().currentUser?.email != null)
            TextButton(
              onPressed: () {
                final def = AuthService().currentUser?.email ?? '';
                controller.text = def;
              },
              child: Text(
                'Pakai Akun Utama',
                style: ScholarlyFonts.outfit(color: OTColors.accent(isDark)),
              ),
            ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: OTColors.accent(isDark),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(
              'Simpan',
              style: ScholarlyFonts.outfit(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (newEmail != null && context.mounted) {
      await NativeAgentLauncher.setActiveNotebookEmail(newEmail);
      if (context.mounted) {
        final display = newEmail.isEmpty ? 'Akun Masuk Utama' : newEmail;
        AppSnackBar.info(context, 'Akun Google asisten diatur ke: $display');
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

    showAdaptiveSheet(
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
                        source:
                            'if (typeof window.otOpenLanguageSettings === "function") { window.otOpenLanguageSettings(); } else if (typeof otOpenLanguageSettings === "function") { otOpenLanguageSettings(); }',
                      );
                    },
                    icon: Icon(Icons.language_rounded,
                        size: 18, color: textPrimary),
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

  void _confirmDeleteChatHistory(BuildContext context, AgentSessionTab session) {
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
            Row(
              children: [
                const Icon(Icons.delete_outline_rounded,
                    color: Colors.redAccent, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Hapus Riwayat Obrolan?',
                    style: OTTypography.cardTitle(color: textPrimary)
                        .copyWith(fontSize: 17),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Seluruh percakapan pada sesi asisten ini akan dibersihkan dari layar.',
              style: OTTypography.body(color: textSecondary),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Batal',
                      style: OTTypography.body(color: textSecondary)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    session.webController?.evaluateJavascript(
                      source:
                          'if (typeof window.otClearChat === "function") { window.otClearChat(); } else if (typeof window.otDeleteChatHistory === "function") { window.otDeleteChatHistory(); }',
                    );
                    if (mounted) {
                      AppSnackBar.success(
                          context, 'Riwayat obrolan telah dibersihkan.');
                    }
                  },
                  child: Text('Hapus',
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSessionSwitcher(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = OTColors.surface(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final sessions = _sessionManager.tabs;

    showAdaptiveSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
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
                const SizedBox(height: 16),
                Text(
                  'Sesi Asisten Terbuka',
                  style: OTTypography.cardTitle(color: textPrimary)
                      .copyWith(fontSize: 17),
                ),
                const SizedBox(height: 6),
                Text(
                  'Pilih asisten untuk berpindah sesi kajian aktif.',
                  style: OTTypography.caption(color: textSecondary),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: sessions.length,
                    separatorBuilder: (_, __) => Divider(
                        height: 1, color: border.withValues(alpha: 0.5)),
                    itemBuilder: (context, index) {
                      final s = sessions[index];
                      final isActive = index == _sessionManager.activeIndex;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          isActive
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: isActive
                              ? OTColors.marja(isDark)
                              : textSecondary,
                          size: 20,
                        ),
                        title: Text(
                          s.agent.title,
                          style: OTTypography.bodyMedium(
                            color: isActive ? textPrimary : textSecondary,
                          ).copyWith(
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.close_rounded,
                              size: 18, color: textSecondary),
                          tooltip: 'Tutup sesi',
                          onPressed: () {
                            _sessionManager.closeTab(index);
                            setSheetState(() {});
                            if (_sessionManager.tabs.isEmpty) {
                              Navigator.pop(ctx);
                            }
                          },
                        ),
                        onTap: () {
                          Navigator.pop(ctx);
                          _sessionManager.selectTab(index);
                        },
                      );
                    },
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
            onOpened: () {
              setState(() => activeTab.isMenuOpen = true);
              activeTab.webController?.evaluateJavascript(
                source:
                    'if (typeof window.otSetMenuOpen === "function") window.otSetMenuOpen(true);',
              );
            },
            onCanceled: () {
              setState(() => activeTab.isMenuOpen = false);
              activeTab.webController?.evaluateJavascript(
                source:
                    'if (typeof window.otSetMenuOpen === "function") window.otSetMenuOpen(false);',
              );
            },
            onSelected: (val) {
              setState(() => activeTab.isMenuOpen = false);
              activeTab.webController?.evaluateJavascript(
                source:
                    'if (typeof window.otSetMenuOpen === "function") window.otSetMenuOpen(false);',
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
              } else if (val == 'switch_session') {
                _showSessionSwitcher(context);
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'language',
                child: Row(
                  children: [
                    Icon(Icons.language_rounded,
                        color: textPrimary, size: 18),
                    const SizedBox(width: 12),
                    Text('Bahasa Output',
                        style: OTTypography.body(color: textPrimary)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete_chat',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline_rounded,
                        color: Colors.redAccent, size: 18),
                    const SizedBox(width: 12),
                    Text('Hapus Riwayat Obrolan',
                        style: OTTypography.body(color: Colors.redAccent)),
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
              if (!AppPlatform.isDesktop && sessions.length > 1)
                PopupMenuItem(
                  value: 'switch_session',
                  child: Row(
                    children: [
                      Icon(Icons.tab_rounded,
                          color: textPrimary, size: 18),
                      const SizedBox(width: 12),
                      Text('Sesi Asisten Terbuka (${sessions.length})',
                          style: OTTypography.body(color: textPrimary)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(width: 4),
        ],
        // Chrome-like Multi-Tab Bar (Hanya tampil di Desktop jika terdapat lebih dari 1 sesi aktif)
        bottom: (AppPlatform.isDesktop && sessions.length > 1)
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
                              borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(8)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
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
                                      session.agent.title
                                          .replaceFirst('AI ', ''),
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
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
        key: const ValueKey('study-webviews'),
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
          var rtlRegex = /[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]/;
          var els = document.querySelectorAll('.rendered-markdown p, .rendered-markdown li, .rendered-markdown div, [role="article"] p, [role="article"] li');
          if (els && typeof els.forEach === 'function') {
            els.forEach(function(el) {
              if (rtlRegex.test(el.textContent || '')) {
                el.setAttribute('dir', 'rtl');
                el.classList.add('arabic');
              }
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
      source:
          '$_turatsMasterScript\n$notebookUiScript\n$themeInitScript',
      injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
      forMainFrameOnly: true,
    );
  }

  Timer? _readinessTimer;
  Timer? _inputRetryTimer;
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
  void didUpdateWidget(_SingleAgentTabWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) {
      _verifySurfaceHealth();
      if (!widget.session.isSessionReady) {
        _startReadinessCheck();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _readinessTimer?.cancel();
    _inputRetryTimer?.cancel();
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
    _loadingStarted = DateTime.now();
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
    _readinessTimer?.cancel();
    if (mounted) {
      setState(() {
        session.isWebLoading = false;
        session.isSessionReady = false;
        session.isGooglePermissionError = true;
        session.isPaywallRequired = false;
        session.isTimeoutError = false;
        session.errorMessage =
            'Akun Google yang aktif belum dapat membuka notebook ini. Periksa akun Google yang digunakan dan izin Viewer pada notebook.';
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
        // Halaman autentikasi Google sedang aktif di dalam WebView internal.
        // JANGAN batalkan _readinessTimer dan JANGAN blokir tampilan dengan error buntu!
        // Berikan ruang pada InAppWebView agar pengguna dapat memilih/memasukkan akun
        // Google secara langsung (inline) dengan dukungan penuh keyboard & mouse.
        if (mounted && (widget.session.isWebLoading || widget.session.errorMessage != null || !widget.session.isGoogleAuthPage)) {
          setState(() {
            widget.session.isWebLoading = false;
            widget.session.isSessionReady = false;
            widget.session.isGooglePermissionError = false;
            widget.session.isGoogleAuthPage = true;
            widget.session.errorMessage = null;
          });
        }
        return;
      } else {
        if (widget.session.isGoogleAuthPage && mounted) {
          setState(() {
            widget.session.isGoogleAuthPage = false;
            if (!widget.session.isSessionReady) {
              widget.session.isWebLoading = true;
            }
          });
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
      if (_readySamples >= 2 && elapsedMs >= 1500) {
        _readinessTimer?.cancel();
        await controller.evaluateJavascript(
          source: 'window.otNotebook?.activate()',
        );
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('google_session_ready', true);
        } catch (_) {}
        if (!mounted) return;
        if (mounted) {
          setState(() {
            widget.session.isWebLoading = false;
            widget.session.isSessionReady = true;
            widget.session.isGooglePermissionError = false;
            widget.session.errorMessage = null;
            widget.session.isTimeoutError = false;
          });
          _syncInitialHistory();
        }
      } else if (DateTime.now().difference(_loadingStarted!).inSeconds >= 45) {
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
                        icon:
                            const Icon(Icons.card_membership_rounded, size: 18),
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

      final needsGoogleLogin =
          isGoogleErr && session.errorMessage!.startsWith('Sesi akun Google');
      final title = isGoogleErr
          ? (needsGoogleLogin
              ? 'Hubungkan akun Google'
              : 'Akun Google belum memiliki izin')
          : (isTimeout
              ? 'Asisten belum berhasil dibuka'
              : 'Asisten Belum Bisa Dibuka');

      final icon = isGoogleErr
          ? Icons.account_circle_outlined
          : (isTimeout ? Icons.wifi_off_rounded : Icons.info_outline_rounded);

      final retryLabel = isGoogleErr ? 'Buka di Browser Asli' : 'Coba lagi';

      return Container(
        color: canvas,
        child: AppErrorState(
          title: title,
          message: session.errorMessage!,
          icon: icon,
          retryLabel: retryLabel,
          onRetry: () async {
            if (isGoogleErr) {
              final url = session.resolvedUrl;
              if (url != null) {
                await NativeAgentLauncher.launchNotebook(url);
              }
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
              userAgent: AppPlatform.isDesktop
                  ? AppConstants.desktopSafariUserAgent
                  : AppConstants.chromeMobileUserAgent,
            ),
            onCreateWindow: (controller, createWindowAction) async {
              final targetUrl = createWindowAction.request.url;
              if (targetUrl != null) {
                await controller.loadUrl(urlRequest: URLRequest(url: targetUrl));
                return true;
              }
              return false;
            },
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
                    session.errorMessage =
                        'Akun Google yang aktif belum dapat membuka notebook ini. Periksa akun Google yang digunakan dan izin Viewer pada notebook.';
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
                    final url = await controller.getUrl();
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
                          session.chatMessages[session.chatMessages.length - 1] =
                              last.copyWith(text: currentText);
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
                  if (mounted) {
                    final nav = Navigator.of(context, rootNavigator: false);
                    if (nav.canPop()) {
                      nav.pop();
                    }
                  }
                  return true;
                },
              );
              if (!session.isSessionReady) {
                _startReadinessCheck();
              }
            },
            onLoadStart: (controller, uri) {
              session.hasInjectedEarlyScript = false;
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
              if (!mounted ||
                  uri == null ||
                  !NotebookNavigation.notebook(uri.uriValue)) {
                return;
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
            onProgressChanged: (controller, progress) async {
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
                }
              }
            },
            shouldOverrideUrlLoading: (controller, action) async {
              if (action.isForMainFrame != true) {
                return NavigationActionPolicy.ALLOW;
              }
              final uri = action.request.url;
              if (uri == null) return NavigationActionPolicy.CANCEL;
              if (NotebookNavigation.allowed(uri.uriValue)) {
                return NavigationActionPolicy.ALLOW;
              }
              return NavigationActionPolicy.CANCEL;
            },
          ),

          // Penutup transparan saat menu titik tiga sedang terbuka (khususnya untuk sentuhan Android / Flutter layer)
          if (session.isMenuOpen)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  final nav = Navigator.of(context, rootNavigator: false);
                  if (nav.canPop()) {
                    nav.pop();
                  }
                },
                child: const ColoredBox(color: Colors.transparent),
              ),
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

          // Banner penolong saat sesi Google belum terhubung / halaman login aktif
          if (session.isGoogleAuthPage)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(14),
                color: isDark ? const Color(0xFF27272A) : const Color(0xFFFFFFFF),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: OTColors.accent(isDark).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.account_circle_rounded,
                          color: OTColors.accent(isDark),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FutureBuilder<String>(
                          future: NativeAgentLauncher.getActiveNotebookEmail(),
                          builder: (context, snapshot) {
                            final targetEmail = snapshot.data ??
                                _authService.currentUser?.email ??
                                'Google';
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Buka Sebagai: ',
                                      style: ScholarlyFonts.outfit(
                                        fontSize: 12,
                                        color: isDark
                                            ? const Color(0xFFA1A1AA)
                                            : const Color(0xFF71717A),
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        targetEmail,
                                        style: ScholarlyFonts.outfit(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? Colors.white
                                              : const Color(0xFF18181B),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Buka langsung di browser utama tanpa salah akun (/u/0/).',
                                  style: ScholarlyFonts.outfit(
                                    fontSize: 11,
                                    color: isDark
                                        ? const Color(0xFFA1A1AA)
                                        : const Color(0xFF71717A),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        onPressed: () async {
                          await AgentMultiTabRoom.showChangeGoogleAccountDialog(context);
                          if (mounted) setState(() {});
                        },
                        child: Text(
                          'Ganti Akun',
                          style: ScholarlyFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: OTColors.accent(isDark),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.open_in_browser_rounded, size: 16),
                        label: Text(
                          'Buka di Browser',
                          style: ScholarlyFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        onPressed: () async {
                          final url = session.resolvedUrl;
                          if (url != null) {
                            await NativeAgentLauncher.launchNotebook(url);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
