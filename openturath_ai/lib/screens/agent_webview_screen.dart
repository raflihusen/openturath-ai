import 'dart:async';
import 'dart:collection';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants.dart';
import '../core/routes.dart';
import '../core/theme.dart';
import '../core/app_snackbar.dart';
import '../models/agent_model.dart';
import '../models/user_model.dart';
import '../services/agent_service.dart';
import '../services/auth_service.dart';
import '../services/native_agent_launcher.dart';

/// AgentWebviewScreen: Tampilan Ruang Riset AI NotebookLM
/// Dilengkapi App Bar native yang bersih di bawah kamera notch/status bar,
/// tombol kembali yang jelas, dan injeksi CSS/JS untuk menyembunyikan header Google.
class AgentWebviewScreen extends StatefulWidget {
  const AgentWebviewScreen({super.key});

  @override
  State<AgentWebviewScreen> createState() => _AgentWebviewScreenState();
}

class _AgentWebviewScreenState extends State<AgentWebviewScreen> {
  final AgentService _agentService = AgentService();
  final AuthService _authService = AuthService();

  InAppWebViewController? _webController;
  AgentModel? _agent;
  UserModel? _user;

  String? _agentUrl;
  bool _isLoadingUrl = true;
  bool _isWebViewLoading = true;
  bool _isPaywallRequired = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _webController = null;
    super.dispose();
  }

  static const String _hideElementsCss = """
    /* Header bar atas Google (Logo & Profil Akun Google) */
    mat-toolbar .logo-container,
    mat-toolbar a.logo-link,
    mat-toolbar labs-tailwind-logo,
    mat-toolbar a[aria-label*="Homepage" i],
    mat-toolbar a[aria-label*="NotebookLM" i],
    mat-toolbar a[aria-label*="Gemini" i],
    mat-toolbar .title-container,
    mat-toolbar input.title-input,
    mat-toolbar button[aria-label*="Copy" i],
    mat-toolbar button[aria-label*="Salin" i],
    mat-toolbar a[aria-label*="Google" i],
    mat-toolbar #gb,
    mat-toolbar #gbwa,
    #gb,
    #gbwa,
    .gb_C,
    .gb_9a,
    .gb_8,
    .gb_U,
    div[id*="gb"],

    /* Logos & brand links di luar toolbar */
    labs-tailwind-logo,
    a.logo-link,
    a[aria-label*="Homepage" i],
    a[aria-label*="NotebookLM" i],
    a[aria-label*="Gemini" i],

    /* Badges & disclaimers */
    .pro-badge,
    .disclaimer,
    .disclaimer-text,
    .footer-disclaimer,
    [class*="disclaimer" i],
    .compliance-notice,
    div[class*="disclaimer"] {
      display: none !important;
      visibility: hidden !important;
      height: 0px !important;
      min-height: 0px !important;
      max-height: 0px !important;
      overflow: hidden !important;
      margin: 0px !important;
      padding: 0px !important;
      pointer-events: none !important;
      border: none !important;
    }

    /* Sembunyikan top banner Google jika ada, tapi pastikan chat panel aman */
    mat-toolbar:not(:has(chat-view)),
    [role="banner"]:not(:has(chat-view)) {
      display: none !important;
      height: 0px !important;
      min-height: 0px !important;
    }

    /* JAMINAN: Tombol Titik Tiga (Chat Options) & Header Panel Chat WAJIB tampak */
    button[aria-label*="Chat options" i],
    button[aria-label*="Opsi chat" i],
    button[aria-label*="options" i],
    [aria-label*="Chat options" i],
    .chat-panel-header,
    .chat-panel-header * {
      display: inline-flex !important;
      visibility: visible !important;
      opacity: 1 !important;
      pointer-events: auto !important;
    }

    /* Sembunyikan scrollbar browser WebKit agar tampilan 100% native */
    ::-webkit-scrollbar {
      display: none !important;
      width: 0px !important;
      height: 0px !important;
      background: transparent !important;
    }
    ::-webkit-scrollbar-thumb,
    ::-webkit-scrollbar-track,
    ::-webkit-scrollbar-corner {
      display: none !important;
      background: transparent !important;
      border: none !important;
    }
    html, body, * {
      scrollbar-width: none !important;
      -ms-overflow-style: none !important;
    }

    /* Auto-fit Responsif: Pastikan tampilan chat besar dan normal di layar ponsel */
    html, body {
      width: 100% !important;
      max-width: 100vw !important;
      overflow-x: hidden !important;
      -webkit-text-size-adjust: 100% !important;
      font-size: 15px !important;
    }
    chat-view,
    .chat-view,
    .chat-container,
    .conversation-container,
    .chat-panel-content {
      width: 100% !important;
      max-width: 100% !important;
      box-sizing: border-box !important;
      padding-top: 0px !important;
      margin-top: 0px !important;
    }
  """;

  static final _cloakScript = UserScript(
    source: """
      (function() {
        function ensureViewportAndStyles() {
          // 1. Pastikan meta viewport terpasang agar tidak mengecil di HP
          var meta = document.querySelector('meta[name="viewport"]');
          if (!meta) {
            meta = document.createElement('meta');
            meta.name = 'viewport';
            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=3.0, user-scalable=yes';
            document.head.appendChild(meta);
          } else {
            meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=3.0, user-scalable=yes');
          }

          // 2. Injeksi style cloaking
          if (!document.getElementById('ot-hide-controls')) {
            var style = document.createElement('style');
            style.id = 'ot-hide-controls';
            style.type = 'text/css';
            style.innerHTML = `$_hideElementsCss`;
            var head = document.head || document.getElementsByTagName('head')[0] || document.documentElement;
            if (head) {
              head.appendChild(style);
            }
          }
        }
        ensureViewportAndStyles();
        document.addEventListener('DOMContentLoaded', ensureViewportAndStyles);

        // Persistent MutationObserver to neutralize Google branding
        try {
          var observer = new MutationObserver(function(mutations) {
            ensureViewportAndStyles();
            var selectors = [
              'mat-toolbar:not(:has(chat-view))', '[role="banner"]:not(:has(chat-view))',
              'a.logo-link', 'labs-tailwind-logo',
              '#gb', '#gbwa', '.gb_C', '.pro-badge', '.disclaimer'
            ];
            for (var s = 0; s < selectors.length; s++) {
              var els = document.querySelectorAll(selectors[s]);
              for (var i = 0; i < els.length; i++) {
                if (els[i].closest && els[i].closest('chat-view')) continue;
                els[i].style.setProperty('display', 'none', 'important');
                els[i].style.setProperty('visibility', 'hidden', 'important');
              }
            }
          });
          observer.observe(document.documentElement || document.body, { childList: true, subtree: true });
        } catch(e) {}
      })();
    """,
    injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
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
        _agentUrl = url.replaceAll('/preview', '');
        _isLoadingUrl = false;
      });
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
          _errorMessage = 'Anda belum memiliki akses ke ruang riset ${_agent?.title ?? "ini"}. Silakan aktifkan paket langganan Rp 50.000/bulan atau Paket Promo Semua AI Rp 99.000.';
          _isWebViewLoading = false;
        });
      }
    } catch (_) {}
  }

  Future<void> _applyHideScript() async {
    if (_webController == null) return;
    try {
      await _webController!.evaluateJavascript(source: """
        (function() {
          // 1. Pastikan meta viewport responsif
          var meta = document.querySelector('meta[name="viewport"]');
          if (!meta) {
            meta = document.createElement('meta');
            meta.name = 'viewport';
            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=3.0, user-scalable=yes';
            document.head.appendChild(meta);
          } else {
            meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=3.0, user-scalable=yes');
          }

          var sel = [
            'mat-toolbar:not(:has(chat-view))',
            '[role="banner"]:not(:has(chat-view))',
            'labs-tailwind-logo',
            'a.logo-link',
            '.logo-container',
            'a[aria-label*="Homepage" i]',
            'a[aria-label*="NotebookLM" i]',
            'a[aria-label*="Gemini" i]',
            '.title-input',
            'input.title-input',
            'button[aria-label*="Copy" i]',
            'button[aria-label*="Salin" i]',
            'a[aria-label*="Google" i]',
            '.gb_C',
            '#gb',
            '#gbwa',
            '.gb_9a',
            '.gb_8',
            '.gb_U',
            'div[id*="gb"]',
            '.pro-badge',
            '.disclaimer',
            '.compliance-notice',
            '[class*="disclaimer" i]'
          ];

          function hideElements() {
            for (var i = 0; i < sel.length; i++) {
              try {
                var els = document.querySelectorAll(sel[i]);
                for (var j = 0; j < els.length; j++) {
                  var el = els[j];
                  if (el.getAttribute && (el.getAttribute('aria-label') || '').toLowerCase().includes('chat')) {
                    continue;
                  }
                  if (el.closest && el.closest('chat-view')) {
                    continue;
                  }
                  el.style.setProperty('display', 'none', 'important');
                  el.style.setProperty('visibility', 'hidden', 'important');
                  el.style.setProperty('height', '0px', 'important');
                  el.style.setProperty('min-height', '0px', 'important');
                  el.style.setProperty('max-height', '0px', 'important');
                  el.style.setProperty('overflow', 'hidden', 'important');
                  el.style.setProperty('margin', '0px', 'important');
                  el.style.setProperty('padding', '0px', 'important');
                  el.style.setProperty('pointer-events', 'none', 'important');
                }
              } catch(_) {}
            }

            try {
              var gaps = document.querySelectorAll('.chat-panel-content, chat-view, .chat-container, .conversation-container, main, .main-content');
              gaps.forEach(function(el) {
                el.style.setProperty('padding-top', '0px', 'important');
                el.style.setProperty('margin-top', '0px', 'important');
                el.style.setProperty('width', '100%', 'important');
                el.style.setProperty('max-width', '100%', 'important');
              });
            } catch(_) {}
          }

          hideElements();

          if (!window.__otHideObserverInstalled) {
            window.__otHideObserverInstalled = true;
            var observer = new MutationObserver(function() {
              hideElements();
            });
            observer.observe(document.documentElement || document.body, { childList: true, subtree: true });

            var count = 0;
            var timer = setInterval(function() {
              hideElements();
              count++;
              if (count > 50) clearInterval(timer);
            }, 250);
          }
        })();
      """);
    } catch (_) {}
  }

  Future<void> _handleBackPress() async {
    if (_webController != null && await _webController!.canGoBack()) {
      await _webController!.goBack();
    } else {
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _confirmDeleteChatHistory() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppTheme.surfaceCardDark : AppTheme.surfaceCardLight;
    final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final textPrimary = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: border, width: 1),
        ),
        title: Text(
          'Hapus Riwayat Percakapan?',
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus riwayat pesan pada sesi riset ini? Seluruh percakapan akan dibersihkan.',
          style: GoogleFonts.outfit(
            fontSize: 13.5,
            color: textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _executeDeleteChatHistory();
            },
            child: Text(
              'Hapus',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _executeDeleteChatHistory() async {
    if (_webController == null) return;

    // Script interaktif untuk memicu aksi hapus chat native NotebookLM (Desktop & Mobile)
    const jsDelete = """
      (async function() {
        try {
          // 1. Cari tombol menu opsi chat (titik tiga)
          let optBtn = document.querySelector('button[aria-label*="Chat options" i], button[aria-label*="Opsi chat" i], button[aria-label*="options" i]');
          if (!optBtn) {
            const allBtns = Array.from(document.querySelectorAll('button, [role="button"]'));
            optBtn = allBtns.find(b => {
              const aria = (b.getAttribute('aria-label') || '').toLowerCase();
              const icon = b.querySelector('mat-icon');
              const iconTxt = icon ? (icon.textContent || '').toLowerCase() : '';
              return aria.includes('chat options') || aria.includes('opsi chat') || 
                     iconTxt.includes('more_vert') || (aria.includes('chat') && iconTxt.includes('more'));
            });
          }

          if (optBtn) {
            optBtn.click();
            await new Promise(r => setTimeout(r, 260));

            // 2. Cari menu item "Delete chat history" di overlay menu Angular Material
            const menuItems = Array.from(document.querySelectorAll('.cdk-overlay-container [role="menuitem"], .mat-mdc-menu-item, [role="menuitem"]'));
            const deleteItem = menuItems.find(m => {
              const t = (m.textContent || '').toLowerCase();
              const a = (m.getAttribute('aria-label') || '').toLowerCase();
              return t.includes('delete chat') || t.includes('delete history') || 
                     t.includes('clear chat') || t.includes('clear history') ||
                     t.includes('hapus chat') || t.includes('hapus riwayat') || t.includes('hapus histori') ||
                     t.includes('hapus percakapan') || t.includes('bersihkan percakapan') ||
                     a.includes('delete chat') || a.includes('hapus chat');
            });

            if (deleteItem) {
              deleteItem.click();
              await new Promise(r => setTimeout(r, 320));

              // 3. Konfirmasi di dialog Google ("Delete")
              const dialogBtns = Array.from(document.querySelectorAll('.cdk-overlay-container button, mat-dialog-actions button, [role="dialog"] button, .mat-mdc-dialog-actions button'));
              const confirmBtn = dialogBtns.find(b => {
                const t = (b.textContent || '').toLowerCase();
                return (t.includes('delete') || t.includes('hapus') || t.includes('clear') || t.includes('ya') || t.includes('ok')) &&
                       !t.includes('cancel') && !t.includes('batal') && !t.includes('kembali');
              });

              if (confirmBtn) {
                confirmBtn.click();
                await new Promise(r => setTimeout(r, 350));
                return 'deleted_native';
              }
            } else {
              // Tutup menu jika tidak ada aksi delete
              const backdrop = document.querySelector('.cdk-overlay-backdrop');
              if (backdrop) backdrop.click();
            }
          }

          // Fallback pembersihan DOM
          document.querySelectorAll('chat-turn, conversation-turn, [class*="turn"], [class*="chat-turn"]').forEach(el => el.remove());
          try { sessionStorage.clear(); } catch(e) {}
          return 'fallback_cleared';
        } catch (e) {
          return 'error: ' + e.toString();
        }
      })();
    """;

    try {
      final res = await _webController!.evaluateJavascript(source: jsDelete);
      if (res == 'deleted_native') {
        if (mounted) {
          AppSnackBar.success(context, 'Riwayat chat telah dihapus');
        }
      } else {
        await InAppWebViewController.clearAllCache();
        if (_agentUrl != null) {
          await _webController!.loadUrl(urlRequest: URLRequest(url: WebUri(_agentUrl!)));
        }
        if (mounted) {
          AppSnackBar.success(context, 'Riwayat chat telah dibersihkan');
        }
      }
    } catch (_) {
      await InAppWebViewController.clearAllCache();
      if (_agentUrl != null) {
        await _webController!.loadUrl(urlRequest: URLRequest(url: WebUri(_agentUrl!)));
      }
      if (mounted) {
        AppSnackBar.success(context, 'Sesi chat telah dimuat ulang');
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
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  _agent?.title ?? 'Ruang Telaah AI',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                    color: textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                visualDensity: VisualDensity.compact,
                splashRadius: 18,
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: isDark ? Colors.red.shade300 : Colors.red.shade600,
                  size: 20,
                ),
                tooltip: 'Hapus Riwayat Chat',
                onPressed: _confirmDeleteChatHistory,
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.open_in_new_rounded, color: textPrimary, size: 20),
              tooltip: 'Buka di Gemini Notebook Native',
              onPressed: () async {
                if (_agentUrl != null) {
                  final launched = await NativeAgentLauncher.launchNotebook(_agentUrl!);
                  if (!launched && mounted) {
                    try {
                      await launchUrl(Uri.parse(_agentUrl!), mode: LaunchMode.externalApplication);
                    } catch (_) {}
                  }
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.share_outlined, color: textPrimary, size: 20),
              tooltip: 'Bagikan Informasi Modul',
              onPressed: () {
                final agentName = _agent?.title ?? 'Turats Islam';
                final shareText = 'Telaah kitab "$agentName" bersama OpenTurath AI - Platform Riset Turats Islam.\nhttps://openturath-ai.web.app';
                Clipboard.setData(ClipboardData(text: shareText));
                AppSnackBar.success(context, 'Tautan OpenTurath disalin ke papan klip');
              },
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: textPrimary, size: 22),
              tooltip: 'Opsi Notebook',
              color: surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: border, width: 1),
              ),
              onSelected: (value) async {
                switch (value) {
                  case 'open_native':
                    if (_agentUrl != null) {
                      final launched = await NativeAgentLauncher.launchNotebook(_agentUrl!);
                      if (!launched && mounted) {
                        try {
                          await launchUrl(Uri.parse(_agentUrl!), mode: LaunchMode.externalApplication);
                        } catch (_) {}
                      }
                    }
                    break;
                  case 'delete_chat':
                    _confirmDeleteChatHistory();
                    break;
                  case 'reload':
                    setState(() => _isWebViewLoading = true);
                    _webController?.reload();
                    break;
                  case 'subscribe':
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
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'open_native',
                  child: Row(
                    children: [
                      Icon(Icons.open_in_new_rounded, size: 18, color: textPrimary),
                      const SizedBox(width: 10),
                      Text('Buka di Aplikasi Resmi', style: GoogleFonts.outfit(fontSize: 13, color: textPrimary)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete_chat',
                  child: Row(
                    children: [
                      Icon(Icons.speaker_notes_off_outlined, size: 18, color: textPrimary),
                      const SizedBox(width: 10),
                      Text('Hapus Riwayat Chat', style: GoogleFonts.outfit(fontSize: 13, color: textPrimary)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'reload',
                  child: Row(
                    children: [
                      Icon(Icons.refresh_rounded, size: 18, color: textSecondary),
                      const SizedBox(width: 10),
                      Text('Muat Ulang Halaman', style: GoogleFonts.outfit(fontSize: 13, color: textPrimary)),
                    ],
                  ),
                ),
                if (_isPaywallRequired) ...[
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'subscribe',
                    child: Row(
                      children: [
                        const Icon(Icons.credit_card_rounded, size: 18, color: Color(0xFFD97706)),
                        const SizedBox(width: 10),
                        Text(
                          'Kelola Langganan AI',
                          style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFFD97706)),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Stack(
            children: [
              // ── 1. WebView Layer (Safe Below App Bar) ──
              if (_agentUrl != null)
              InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(_agentUrl!)),
                initialUserScripts: UnmodifiableListView<UserScript>([_cloakScript]),
                initialSettings: InAppWebViewSettings(
                  userAgent: AppConstants.chromeDesktopUserAgent,
                  javaScriptEnabled: true,
                  domStorageEnabled: true,
                  databaseEnabled: true,
                  sharedCookiesEnabled: true,
                  thirdPartyCookiesEnabled: true,
                  cacheEnabled: true,
                  clearCache: false,
                  clearSessionCache: false,
                  useHybridComposition: true,
                  mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                  allowFileAccess: true,
                  allowContentAccess: true,
                  javaScriptCanOpenWindowsAutomatically: true,
                  supportZoom: true,
                  builtInZoomControls: true,
                  displayZoomControls: false,
                  useWideViewPort: true,
                  loadWithOverviewMode: false,
                  textZoom: 100,
                  mediaPlaybackRequiresUserGesture: false,
                  allowsInlineMediaPlayback: true,
                  forceDark: isDark ? ForceDark.ON : ForceDark.OFF,
                  algorithmicDarkeningAllowed: false,
                  transparentBackground: true,
                ),
                onWebViewCreated: (controller) {
                  _webController = controller;
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

                  final host = uri.host.toLowerCase();
                  if (host.contains('google.com') ||
                      host.contains('gstatic.com') ||
                      host.contains('googleapis.com') ||
                      host.contains('googleusercontent.com')) {
                    return NavigationActionPolicy.ALLOW;
                  }

                  try {
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                      return NavigationActionPolicy.CANCEL;
                    }
                  } catch (_) {}
                  return NavigationActionPolicy.ALLOW;
                },
                onLoadStop: (controller, url) async {
                  await _applyHideScript();
                  await _detectGoogleAccessDenied();
                  Future.delayed(const Duration(milliseconds: 500), () async {
                    await _applyHideScript();
                    await _detectGoogleAccessDenied();
                  });
                  Future.delayed(const Duration(milliseconds: 1200), () async {
                    await _applyHideScript();
                    await _detectGoogleAccessDenied();
                  });
                  Future.delayed(const Duration(milliseconds: 2500), () async {
                    await _applyHideScript();
                    await _detectGoogleAccessDenied();
                  });
                  Future.delayed(const Duration(milliseconds: 4000), () async {
                    await _applyHideScript();
                    await _detectGoogleAccessDenied();
                  });
                  if (mounted && _isWebViewLoading) {
                    setState(() => _isWebViewLoading = false);
                  }
                },
                onProgressChanged: (controller, progress) async {
                  if (progress >= 30) {
                    await _applyHideScript();
                    await _detectGoogleAccessDenied();
                  }
                  if (progress >= 70) {
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
                      _errorMessage = 'Gagal memuat laman riset (${error.description})';
                    });
                  }
                },
              ),

            // ── Loading Indicator Screen ──
            if (_isLoadingUrl || (_isWebViewLoading && _errorMessage == null))
              Positioned.fill(
                child: Container(
                  color: canvas,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 38,
                          height: 38,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(accent),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Menyiapkan Ruang Telaah Kitab...',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _agent?.title ?? 'Modul Turats AI',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // ── 2. Error State Screen ──
            if (_errorMessage != null && !_isLoadingUrl)
              Container(
                width: double.infinity,
                height: double.infinity,
                color: canvas,
                padding: const EdgeInsets.all(28),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isPaywallRequired
                            ? Icons.workspace_premium_rounded
                            : Icons.info_outline_rounded,
                        size: 48,
                        color: _isPaywallRequired
                            ? const Color(0xFFD97706)
                            : (isDark ? AppTheme.accentDark : AppTheme.accentLight),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        _isPaywallRequired
                            ? 'Akses Berlangganan Diperlukan'
                            : 'Kendala Memuat Ruang Riset',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 13.5,
                          height: 1.45,
                          color: textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_isPaywallRequired)
                        FilledButton.icon(
                          onPressed: () {
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
                          },
                          icon: const Icon(Icons.workspace_premium_rounded, size: 18),
                          label: const Text('Buka Paket Langganan'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFD97706),
                            foregroundColor: Colors.white,
                          ),
                        )
                      else ...[
                        FilledButton.icon(
                          onPressed: _fetchAgentUrl,
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Coba Muat Ulang'),
                          style: FilledButton.styleFrom(
                            backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFF1F1F1F),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Kembali ke Beranda'),
                      ),
                    ],
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
