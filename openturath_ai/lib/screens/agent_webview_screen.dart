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
import '../models/agent_model.dart';
import '../models/bookmark_model.dart';
import '../models/user_model.dart';
import '../services/agent_service.dart';
import '../services/auth_service.dart';
import '../services/bookmark_service.dart';

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
          .pro-badge, .disclaimer, [class*="disclaimer" i], [class*="footnote" i],
          footer, .footer, [role="contentinfo"], mat-hint, .mat-hint,
          [class*="compliance" i], .compliance-notice, .legal-text, [class*="legal" i] {
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
          :root, html, body, app-root, .app-root, mat-sidenav-container, mat-sidenav-content,
          main, [role="main"], .conversation-container, .chat-view, .chat-panel-content,
          .message-list, div[class*="chat-panel" i], div[class*="conversation" i] {
            background-color: #0E0E10 !important;
            background: #0E0E10 !important;
            color: #FAFAFA !important;
            --mdc-elevated-card-container-color: transparent !important;
            --mdc-plain-card-container-color: transparent !important;
            --mat-card-background-color: transparent !important;
            --mdc-theme-surface: #0E0E10 !important;
            --mdc-theme-background: #0E0E10 !important;
          }
          /* Hilangkan bingkai dan background kotak abu-abu pada pesan agar teks mengalir mulus ala Claude */
          mat-card, .mat-mdc-card, .mdc-card, div[class*="card" i]:not(.query-box):not([class*="query" i]) {
            background-color: transparent !important;
            background: transparent !important;
            color: #FAFAFA !important;
            border: none !important;
            box-shadow: none !important;
          }
          .chat-message, .message, [role="article"], .bubble, .model-turn, .assistant-turn, div[class*="message" i] {
            background-color: transparent !important;
            background: transparent !important;
            color: #FAFAFA !important;
            border: none !important;
            box-shadow: none !important;
          }
          /* Bubble pesan pengguna dengan aksen halus */
          .user-turn, div[class*="user-turn" i] {
            background-color: #18181B !important;
            background: #18181B !important;
            border: 1px solid #27272A !important;
            border-radius: 18px !important;
            padding: 10px 16px !important;
          }
          /* Container input luar: transparan tanpa garis kotak ganda */
          .chat-input-container, div[class*="chat-input-container" i], div[class*="chat-input" i] {
            background-color: transparent !important;
            background: transparent !important;
            border: none !important;
            box-shadow: none !important;
            padding: 6px 12px 14px 12px !important;
          }
          /* Kotak input tunggal yang bersih (Single capsule pill) */
          .query-box, div[class*="query-box" i] {
            background-color: #18181B !important;
            background: #18181B !important;
            border: 1px solid #27272A !important;
            border-radius: 28px !important;
            box-shadow: none !important;
            color: #FAFAFA !important;
          }
          /* Hilangkan border bersarang dari Material wrapper internal */
          .mat-mdc-form-field-flex, .mat-mdc-text-field-wrapper, .mat-mdc-form-field-infix {
            background: transparent !important;
            border: none !important;
            box-shadow: none !important;
            padding: 0 !important;
          }
          .cdk-text-field-autofill-monitored, textarea, input, .query-box-input {
            background-color: transparent !important;
            background: transparent !important;
            color: #FAFAFA !important;
            border: none !important;
          }
          textarea::placeholder, input::placeholder, .query-box-input::placeholder {
            color: #71717A !important;
          }
          ::-webkit-scrollbar { display: none !important; width: 0px !important; height: 0px !important; }
          html, body, * { scrollbar-width: none !important; -ms-overflow-style: none !important; }
          /* Padding atas yang cukup agar pesan teratas tidak terpotong */
          .chat-panel-content, .chat-view, .conversation-container, .message-list, main {
            padding-top: 18px !important;
            margin-top: 0px !important;
          }
        `;
        (document.head || document.documentElement).appendChild(style);
      }

      // Helper untuk komunikasi aman ke Flutter
      function sendToFlutter(name, data) {
        if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
          window.flutter_inappwebview.callHandler(name, data);
        } else {
          var attempts = 0;
          var poll = setInterval(function() {
            attempts++;
            if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
              clearInterval(poll);
              window.flutter_inappwebview.callHandler(name, data);
            } else if (attempts > 20) {
              clearInterval(poll);
            }
          }, 150);
        }
      }

      // 2. Eradicate Google Disclaimer Secara Total
      function eradicateDisclaimer() {
        try {
          // Direct element sweep
          var allCandidates = document.querySelectorAll('mat-hint, .mat-hint, footer, [role="contentinfo"], .disclaimer, [class*="disclaimer" i], [class*="footnote" i], [class*="compliance" i], p, div, span, small');
          for (var c = 0; c < allCandidates.length; c++) {
            var el = allCandidates[c];
            var txt = (el.innerText || el.textContent || '').trim().toLowerCase();
            if (txt.length > 0 && txt.length < 250 && (
                txt.includes('inaccurate') || 
                txt.includes('double check') || 
                txt.includes('gemini notebook can be') || 
                txt.includes('notebooklm can make') || 
                txt.includes('can make mistakes') ||
                txt.includes('bisa saja tidak akurat') ||
                txt.includes('dapat membuat kesalahan'))) {
              
              el.style.setProperty('display', 'none', 'important');
              el.style.setProperty('visibility', 'hidden', 'important');
              el.style.setProperty('height', '0px', 'important');
              el.style.setProperty('min-height', '0px', 'important');
              el.style.setProperty('max-height', '0px', 'important');
              el.style.setProperty('padding', '0px', 'important');
              el.style.setProperty('margin', '0px', 'important');
              el.style.setProperty('font-size', '0px', 'important');
              el.style.setProperty('line-height', '0px', 'important');
              el.style.setProperty('overflow', 'hidden', 'important');
              el.style.setProperty('opacity', '0', 'important');
              el.style.setProperty('pointer-events', 'none', 'important');
              
              var p = el.parentElement;
              if (p && p !== document.body && p.clientHeight < 70 && !p.querySelector('textarea, input, button')) {
                p.style.setProperty('display', 'none', 'important');
                p.style.setProperty('height', '0px', 'important');
                p.style.setProperty('min-height', '0px', 'important');
                p.style.setProperty('margin', '0px', 'important');
                p.style.setProperty('padding', '0px', 'important');
                p.style.setProperty('overflow', 'hidden', 'important');
              }
            }
          }

          // TreeWalker sweep for detached text nodes
          var walker = document.createTreeWalker(document.body || document.documentElement, NodeFilter.SHOW_TEXT, null, false);
          var node;
          while ((node = walker.nextNode())) {
            var v = (node.nodeValue || '').toLowerCase();
            if (v.includes('inaccurate') || v.includes('double check') || v.includes('gemini notebook can be')) {
              var parent = node.parentElement;
              if (parent) {
                parent.style.setProperty('display', 'none', 'important');
                parent.style.setProperty('height', '0px', 'important');
                parent.style.setProperty('overflow', 'hidden', 'important');
                parent.style.setProperty('visibility', 'hidden', 'important');
              }
            }
          }
        } catch(e) {}
      }

      // 2b. Sembunyikan Kartu Metadata/Landing NotebookLM (SUPER AI, 0 sources, dll)
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

      // 3. Inject Action Buttons (Simpan ke Bookmark & Salin) Tepat di Samping Jempol
      function injectChatActions() {
        var thumbButtons = [];

        // Strategi A: Tombol atau icon yang memiliki label/title/text thumbs
        var candidates = Array.from(document.querySelectorAll('button, [role="button"], mat-icon-button, .mat-mdc-icon-button, [data-testid*="thumb" i]'));
        for (var i = 0; i < candidates.length; i++) {
          var b = candidates[i];
          var aria = (b.getAttribute('aria-label') || '').toLowerCase();
          var title = (b.getAttribute('title') || '').toLowerCase();
          var text = (b.textContent || '').trim().toLowerCase();

          if (aria.includes('thumb') || aria.includes('good') || aria.includes('bad') || 
              aria.includes('like') || aria.includes('suka') || aria.includes('bagus') || 
              aria.includes('buruk') || title.includes('thumb') || title.includes('good') || title.includes('bad')) {
            thumbButtons.push(b);
            continue;
          }
          if (text === 'thumb_up' || text === 'thumb_down' || text.includes('thumb') || text.includes('thum')) {
            thumbButtons.push(b);
            continue;
          }
          var icons = b.querySelectorAll('mat-icon, [data-mat-icon-name], svg, .google-symbols');
          for (var k = 0; k < icons.length; k++) {
            var icName = (icons[k].getAttribute('data-mat-icon-name') || '').toLowerCase();
            var icTxt = (icons[k].textContent || '').trim().toLowerCase();
            if (icName.includes('thumb') || icTxt.includes('thumb') || icTxt.includes('thum') ||
                icTxt === 'thumb_up' || icTxt === 'thumb_down') {
              thumbButtons.push(b);
              break;
            }
          }
        }

        // Strategi B: Direct icons (mat-icon or .google-symbols)
        var iconsDirect = Array.from(document.querySelectorAll('mat-icon, .google-symbols, [data-mat-icon-name]'));
        for (var ic = 0; ic < iconsDirect.length; ic++) {
          var iconEl = iconsDirect[ic];
          var icText = (iconEl.textContent || '').trim().toLowerCase();
          var icAttr = (iconEl.getAttribute('data-mat-icon-name') || '').toLowerCase();
          if (icText.includes('thumb') || icText.includes('thum') || icAttr.includes('thumb')) {
            var parentBtn = iconEl.closest('button, [role="button"], div, span');
            if (parentBtn && thumbButtons.indexOf(parentBtn) === -1) {
              thumbButtons.push(parentBtn);
            }
          }
        }

        // Strategi C: Pencarian teks thumthun (sesuai screenshot user)
        var tw = document.createTreeWalker(document.body || document.documentElement, NodeFilter.SHOW_TEXT, null, false);
        var tn;
        while ((tn = tw.nextNode())) {
          var tVal = (tn.nodeValue || '').trim().toLowerCase();
          if (tVal.includes('thumthun') || tVal === 'thumb_up' || tVal === 'thumb_down') {
            if (tn.parentElement && thumbButtons.indexOf(tn.parentElement) === -1) {
              thumbButtons.push(tn.parentElement);
            }
          }
        }

        var parentMap = [];
        for (var j = 0; j < thumbButtons.length; j++) {
          var p = thumbButtons[j].parentElement;
          if (p && parentMap.indexOf(p) === -1) parentMap.push(p);
        }

        for (var m = 0; m < parentMap.length; m++) {
          var parentEl = parentMap[m];
          if (parentEl.querySelector('.ot-action-btn-group')) continue;

          // Cari tombol acuan terakhir di dalam baris
          var anchor = null;
          for (var c = parentEl.children.length - 1; c >= 0; c--) {
            var child = parentEl.children[c];
            if (thumbButtons.indexOf(child) !== -1 || child.querySelector('mat-icon, .google-symbols, svg') || child.tagName === 'BUTTON') {
              anchor = child;
              break;
            }
          }
          if (!anchor) anchor = parentEl.lastElementChild;
          if (!anchor) continue;

          // Pastikan wadah parent tidak overflow hidden atau tinggi terbatas
          parentEl.style.setProperty('overflow', 'visible', 'important');
          parentEl.style.setProperty('height', 'auto', 'important');
          parentEl.style.setProperty('min-height', '38px', 'important');
          parentEl.style.setProperty('display', 'flex', 'important');
          parentEl.style.setProperty('align-items', 'center', 'important');
          parentEl.style.setProperty('flex-wrap', 'wrap', 'important');
          parentEl.style.setProperty('gap', '6px', 'important');

          var group = document.createElement('div');
          group.className = 'ot-action-btn-group';
          group.style.cssText = 'display: inline-flex !important; align-items: center !important; gap: 6px !important; margin-left: 8px !important; margin-top: 4px !important; margin-bottom: 4px !important; vertical-align: middle !important; flex-wrap: wrap !important; z-index: 999 !important; position: relative !important;';

          var saveBtn = document.createElement('button');
          saveBtn.type = 'button';
          saveBtn.className = 'ot-action-btn ot-save-btn';
          saveBtn.style.cssText = 'display: inline-flex !important; align-items: center !important; gap: 6px !important; background: #047857 !important; color: #ffffff !important; border: 1.5px solid #059669 !important; border-radius: 9999px !important; padding: 6px 14px !important; font-size: 12px !important; font-weight: 600 !important; cursor: pointer !important; line-height: 1.2 !important; box-shadow: 0 2px 5px rgba(0,0,0,0.2) !important; user-select: none !important; -webkit-tap-highlight-color: transparent !important;';
          saveBtn.innerHTML = '<svg style="width: 13px; height: 13px; fill: currentColor;" viewBox="0 0 24 24"><path d="M17 3H7c-1.1 0-2 .9-2 2v16l7-3 7 3V5c0-1.1-.9-2-2-2z"/></svg><span>Simpan ke Bookmark</span>';

          var copyBtn = document.createElement('button');
          copyBtn.type = 'button';
          copyBtn.className = 'ot-action-btn ot-copy-btn';
          copyBtn.style.cssText = 'display: inline-flex !important; align-items: center !important; gap: 5px !important; background: rgba(128,128,128,0.18) !important; color: inherit !important; border: 1px solid rgba(128,128,128,0.35) !important; border-radius: 9999px !important; padding: 6px 12px !important; font-size: 12px !important; font-weight: 500 !important; cursor: pointer !important; line-height: 1.2 !important; user-select: none !important; -webkit-tap-highlight-color: transparent !important;';
          copyBtn.innerHTML = '<svg style="width: 13px; height: 13px; fill: currentColor;" viewBox="0 0 24 24"><path d="M16 1H4c-1.1 0-2 .9-2 2v14h2V3h12V1zm3 4H8c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h11c1.1 0 2-.9 2-2V7c0-1.1-.9-2-2-2zm0 16H8V7h11v14z"/></svg><span>Salin</span>';

          group.appendChild(saveBtn);
          group.appendChild(copyBtn);

          (function(sB, cB, aB) {
            function extractData() {
              var card = null;
              var cur = aB.parentElement;
              for (var d = 0; d < 8 && cur && cur !== document.body && cur !== document.documentElement; d++) {
                // Jangan melompat melewati wadah yang memuat pesan-pesan lain
                if (cur.querySelectorAll && cur.querySelectorAll('.ot-action-btn-group').length > 1) {
                  break;
                }
                var t = (cur.innerText || '').trim();
                if (t.length > 30) {
                  card = cur;
                }
                if (cur.matches && cur.matches('.message-card, .chat-message, [role="article"], .model-turn, .assistant-turn, .response-container, div[class*="message" i], div[class*="turn" i]')) {
                  card = cur;
                  break;
                }
                cur = cur.parentElement;
              }

              var fullText = '';
              var arabicText = '';
              var questionText = '';

              if (card) {
                var clone = card.cloneNode(true);
                var junk = clone.querySelectorAll('button, .ot-action-btn-group, mat-icon, svg, [role="toolbar"], footer, header, .google-symbols');
                for (var j = 0; j < junk.length; j++) junk[j].remove();
                fullText = (clone.innerText || clone.textContent || '').trim();

                var arabicMatches = fullText.match(/[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]{6,}(?:[\s\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF\d،؛؟.]+[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]{4,})*/g);
                if (arabicMatches && arabicMatches.length > 0) {
                  arabicMatches.sort(function(a, b) { return b.length - a.length; });
                  arabicText = arabicMatches.slice(0, 2).join('\n...\n');
                }

                var prev = card.previousElementSibling;
                while (prev) {
                  var prevText = (prev.innerText || '').trim();
                  if (prevText.length > 2 && prevText.length < 500) {
                    questionText = prevText;
                    break;
                  }
                  prev = prev.previousElementSibling;
                }
              }

              if (!fullText || fullText.length < 15) {
                var paras = document.querySelectorAll('p, .chat-panel-content, .message-content');
                var collected = [];
                for (var p = 0; p < paras.length; p++) {
                  var pt = (paras[p].innerText || '').trim();
                  if (pt.length > 20 && !pt.includes('can be inaccurate')) {
                    collected.push(pt);
                  }
                }
                if (collected.length > 0) {
                  fullText = collected.slice(-3).join('\n\n');
                }
              }

              return { fullAnswer: fullText, arabicExcerpt: arabicText, question: questionText };
            }

            sB.addEventListener('click', function(e) {
              e.preventDefault();
              e.stopPropagation();
              var data = extractData();
              sendToFlutter('onSaveBookmark', data);
              sB.style.setProperty('background', '#065f46', 'important');
              sB.style.setProperty('border-color', '#10b981', 'important');
              var sp = sB.querySelector('span');
              if (sp) sp.innerText = '✓ Tersimpan';
            });

            cB.addEventListener('click', function(e) {
              e.preventDefault();
              e.stopPropagation();
              var data = extractData();
              if (navigator.clipboard && navigator.clipboard.writeText) {
                navigator.clipboard.writeText(data.fullAnswer).catch(function(){});
              }
              sendToFlutter('onCopySuccess', { length: data.fullAnswer.length });
              var sp = cB.querySelector('span');
              if (sp) sp.innerText = '✓ Tersalin!';
              setTimeout(function() {
                if (sp) sp.innerText = 'Salin';
              }, 2500);
            });
          })(saveBtn, copyBtn, anchor);

          if (anchor.nextSibling) {
            parentEl.insertBefore(group, anchor.nextSibling);
          } else {
            parentEl.appendChild(group);
          }
        }
      }

      // 4. Font scale
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

      // 5. Master loop & observer
      function runLoop() {
        eradicateDisclaimer();
        sweepNotebookLandingCard();
        injectChatActions();
      }

      runLoop();

      if (!window.__otMasterObserver) {
        window.__otMasterObserver = new MutationObserver(function() {
          runLoop();
        });
        window.__otMasterObserver.observe(document.documentElement || document.body, { childList: true, subtree: true });
        setInterval(runLoop, 300);
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
          _errorMessage = 'Anda belum memiliki akses ke ruang riset ${_agent?.title ?? "ini"}. Silakan aktifkan paket langganan Rp 50.000/bulan atau Paket Promo Semua AI Rp 99.000.';
          _isWebViewLoading = false;
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      try {
        await _webController!.evaluateJavascript(source: """
          (function() {
            var lightStyle = document.getElementById('turath-light-mode-override');
            if (lightStyle && lightStyle.parentNode) {
              lightStyle.parentNode.removeChild(lightStyle);
            }
            var darkStyle = document.getElementById('turath-dark-mode-override');
            if (!darkStyle) {
              darkStyle = document.createElement('style');
              darkStyle.id = 'turath-dark-mode-override';
              (document.head || document.documentElement).appendChild(darkStyle);
            }
            darkStyle.textContent = `
              :root, html, body, .app-root, app-root, main, .chat-panel-content, .chat-view, .conversation-container, mat-sidenav-container, mat-sidenav-content {
                background-color: #0E0E10 !important;
                background: #0E0E10 !important;
                color: #FAFAFA !important;
                --mdc-elevated-card-container-color: transparent !important;
                --mdc-plain-card-container-color: transparent !important;
                --mat-card-background-color: transparent !important;
                --mdc-theme-surface: #0E0E10 !important;
                --mdc-theme-background: #0E0E10 !important;
              }
              .notebook-header, app-notebook-header, .title-card, mat-card.title-card,
              div[class*="title-card" i], div[class*="notebook-header" i],
              div[class*="source-summary" i], div[class*="source-count" i],
              div[class*="notebook-info" i], .project-header, div.source-badge-container,
              div[class*="notebook-title" i], [class*="artifact-card" i],
              .mobile-header, div[class*="mobile-header" i] {
                display: none !important;
                height: 0px !important;
                overflow: hidden !important;
                visibility: hidden !important;
              }
              /* Hilangkan bingkai dan background kotak abu-abu pada pesan agar teks mengalir mulus ala Claude */
              mat-card, .mat-mdc-card, .mdc-card, div[class*="card" i]:not(.query-box):not([class*="query" i]) {
                background-color: transparent !important;
                background: transparent !important;
                color: #FAFAFA !important;
                border: none !important;
                box-shadow: none !important;
              }
              .chat-message, .message, [role="article"], .bubble, .model-turn, .assistant-turn, div[class*="message" i] {
                background-color: transparent !important;
                background: transparent !important;
                color: #FAFAFA !important;
                border: none !important;
                box-shadow: none !important;
              }
              /* Bubble pesan pengguna dengan aksen halus */
              .user-turn, div[class*="user-turn" i] {
                background-color: #18181B !important;
                background: #18181B !important;
                border: 1px solid #27272A !important;
                border-radius: 18px !important;
                padding: 10px 16px !important;
                color: #FAFAFA !important;
              }
              /* Container input luar: transparan tanpa garis kotak ganda */
              .chat-input-container, div[class*="chat-input-container" i], div[class*="chat-input" i] {
                background-color: transparent !important;
                background: transparent !important;
                border: none !important;
                box-shadow: none !important;
                padding: 6px 12px 14px 12px !important;
              }
              /* Kotak input tunggal yang bersih (Single capsule pill) */
              .query-box, div[class*="query-box" i] {
                background-color: #18181B !important;
                background: #18181B !important;
                border: 1px solid #27272A !important;
                border-radius: 28px !important;
                box-shadow: none !important;
                color: #FAFAFA !important;
              }
              /* Hilangkan border bersarang dari Material wrapper internal */
              .mat-mdc-form-field-flex, .mat-mdc-text-field-wrapper, .mat-mdc-form-field-infix {
                background: transparent !important;
                border: none !important;
                box-shadow: none !important;
                padding: 0 !important;
              }
              .cdk-text-field-autofill-monitored, textarea, input, .query-box-input {
                background-color: transparent !important;
                background: transparent !important;
                color: #FAFAFA !important;
                border: none !important;
              }
              textarea::placeholder, input::placeholder, .query-box-input::placeholder {
                color: #71717A !important;
              }
              /* Padding atas yang cukup agar pesan teratas tidak terpotong */
              .chat-panel-content, .chat-view, .conversation-container, .message-list, main {
                padding-top: 18px !important;
                margin-top: 0px !important;
              }
            `;
          })();
        """);
      } catch (_) {}
    } else {
      try {
        await _webController!.evaluateJavascript(source: """
          (function() {
            var darkStyle = document.getElementById('turath-dark-mode-override');
            if (darkStyle && darkStyle.parentNode) {
              darkStyle.parentNode.removeChild(darkStyle);
            }
            var lightStyle = document.getElementById('turath-light-mode-override');
            if (!lightStyle) {
              lightStyle = document.createElement('style');
              lightStyle.id = 'turath-light-mode-override';
              (document.head || document.documentElement).appendChild(lightStyle);
            }
            lightStyle.textContent = `
              :root, html, body, .app-root, app-root, main, .chat-panel-content, .chat-view, .conversation-container, mat-sidenav-container, mat-sidenav-content {
                background-color: #FFFFFF !important;
                background: #FFFFFF !important;
                color: #18181B !important;
                --mdc-elevated-card-container-color: transparent !important;
                --mdc-plain-card-container-color: transparent !important;
                --mat-card-background-color: transparent !important;
                --mdc-theme-surface: #FFFFFF !important;
                --mdc-theme-background: #FFFFFF !important;
              }
              .notebook-header, app-notebook-header, .title-card, mat-card.title-card,
              div[class*="title-card" i], div[class*="notebook-header" i],
              div[class*="source-summary" i], div[class*="source-count" i],
              div[class*="notebook-info" i], .project-header, div.source-badge-container,
              div[class*="notebook-title" i], [class*="artifact-card" i],
              .mobile-header, div[class*="mobile-header" i] {
                display: none !important;
                height: 0px !important;
                overflow: hidden !important;
                visibility: hidden !important;
              }
              mat-card, .mat-mdc-card, .mdc-card, div[class*="card" i]:not(.query-box):not([class*="query" i]) {
                background-color: transparent !important;
                background: transparent !important;
                color: #18181B !important;
                border: none !important;
                box-shadow: none !important;
              }
              .chat-message, .message, [role="article"], .bubble, .model-turn, .assistant-turn, div[class*="message" i] {
                background-color: transparent !important;
                background: transparent !important;
                color: #18181B !important;
                border: none !important;
                box-shadow: none !important;
              }
              .user-turn, div[class*="user-turn" i] {
                background-color: #F4F4F5 !important;
                background: #F4F4F5 !important;
                border: 1px solid #E5E7EB !important;
                border-radius: 18px !important;
                padding: 10px 16px !important;
                color: #18181B !important;
              }
              .chat-input-container, div[class*="chat-input-container" i], div[class*="chat-input" i] {
                background-color: transparent !important;
                background: transparent !important;
                border: none !important;
                box-shadow: none !important;
                padding: 6px 12px 14px 12px !important;
              }
              .query-box, div[class*="query-box" i] {
                background-color: #FFFFFF !important;
                background: #FFFFFF !important;
                border: 1px solid #E5E7EB !important;
                border-radius: 28px !important;
                box-shadow: none !important;
                color: #18181B !important;
              }
              .mat-mdc-form-field-flex, .mat-mdc-text-field-wrapper, .mat-mdc-form-field-infix {
                background: transparent !important;
                border: none !important;
                box-shadow: none !important;
                padding: 0 !important;
              }
              .cdk-text-field-autofill-monitored, textarea, input, .query-box-input {
                background-color: transparent !important;
                background: transparent !important;
                color: #18181B !important;
                border: none !important;
              }
              textarea::placeholder, input::placeholder, .query-box-input::placeholder {
                color: #71717A !important;
              }
              .chat-panel-content, .chat-view, .conversation-container, .message-list, main {
                padding-top: 18px !important;
                margin-top: 0px !important;
              }
            `;
          })();
        """);
      } catch (_) {}
    }
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
        AppSnackBar.error(context, 'Gagal menyalin telaah: $e');
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
        AppSnackBar.error(context, 'Gagal menyimpan bookmark: $e');
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
    final canvas = isDark ? AppTheme.canvasDark : AppTheme.canvasLight;
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
          title: Text(
            _agent?.title ?? 'Ruang Telaah AI',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              color: textPrimary,
            ),
          ),
          actions: [
            if (_user != null && _user!.plan == 'trial')
              Padding(
                padding: const EdgeInsets.only(right: 2),
                child: Center(
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.subscription,
                        arguments: {'agent': _agent, 'user': _user},
                      );
                    },
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: border, width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt_rounded, size: 12, color: accent),
                          const SizedBox(width: 3),
                          Text(
                            '${_user!.questionsRemaining}',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            IconButton(
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: Icon(
                _hasCopied ? Icons.check_circle_rounded : Icons.copy_rounded,
                color: _hasCopied ? const Color(0xFF10B981) : textPrimary,
                size: 19,
              ),
              tooltip: 'Salin Jawaban',
              onPressed: _isCopying ? null : _copyLatestResponse,
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: Icon(
                _hasBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                color: _hasBookmarked ? const Color(0xFFD97706) : textPrimary,
                size: 20,
              ),
              tooltip: 'Bookmark',
              onPressed: _isBookmarking ? null : _bookmarkLatestResponse,
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: Icon(Icons.format_size_rounded, color: textPrimary, size: 20),
              tooltip: 'Ukuran Huruf',
              onPressed: _showFontScalePicker,
            ),
            const SizedBox(width: 4),
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
                      mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                      allowFileAccess: true,
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
                  await _applyCurrentFontScale();
                  await _detectGoogleAccessDenied();
                  Future.delayed(const Duration(milliseconds: 500), () async {
                    await _applyHideScript();
                    await _applyCurrentFontScale();
                    await _detectGoogleAccessDenied();
                  });
                  Future.delayed(const Duration(milliseconds: 1200), () async {
                    await _applyHideScript();
                    await _applyCurrentFontScale();
                    await _detectGoogleAccessDenied();
                  });
                  Future.delayed(const Duration(milliseconds: 2500), () async {
                    await _applyHideScript();
                    await _applyCurrentFontScale();
                    await _detectGoogleAccessDenied();
                  });
                  Future.delayed(const Duration(milliseconds: 4000), () async {
                    await _applyHideScript();
                    await _applyCurrentFontScale();
                    await _detectGoogleAccessDenied();
                  });
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
                      _errorMessage = 'Gagal memuat laman riset (${error.description})';
                    });
                  }
                },
              ),
            ),

            // ── Loading Indicator Screen (Three Dots Minimal Pulse) ──
            if (_isLoadingUrl || (_isWebViewLoading && _errorMessage == null))
              Positioned.fill(
                child: _ThreeDotsMinimalLoader(
                  agent: _agent,
                  isDark: isDark,
                  onCancel: _handleBackPress,
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
    final surface = isDark ? const Color(0xFF18181B) : Colors.white;
    final border = isDark ? const Color(0xFF27272A) : const Color(0xFFE5E7EB);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0E0E10);
    final textSecondary = isDark ? const Color(0xFFA1A1AA) : const Color(0xFF52525B);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: surface,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
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
                        color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
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
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: Text(
                      'Saya Memahami & Menjaga Adab',
                      style: GoogleFonts.outfit(
                        fontSize: 13.5,
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
                  fontSize: 11.5,
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

  void _showFontScalePicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF18181B) : Colors.white;
    final border = isDark ? const Color(0xFF27272A) : const Color(0xFFE5E7EB);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0E0E10);
    final textSecondary = isDark ? const Color(0xFFA1A1AA) : const Color(0xFF52525B);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
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
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Ukuran Teks Telaah',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sesuaikan ukuran huruf naskah dan terjemahan untuk kenyamanan membaca',
                  style: GoogleFonts.outfit(
                    fontSize: 12.5,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                _buildScaleOption(ctx, label: 'Normal (100%)', scale: 1.0, isDark: isDark),
                _buildScaleOption(ctx, label: 'Sedang (115%)', scale: 1.15, isDark: isDark),
                _buildScaleOption(ctx, label: 'Besar (130%)', scale: 1.30, isDark: isDark),
                _buildScaleOption(ctx, label: 'Ekstra Besar (150%)', scale: 1.50, isDark: isDark),
                const SizedBox(height: 8),
              ],
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
    final textPrimary = isDark ? Colors.white : const Color(0xFF0E0E10);
    final textSecondary = isDark ? const Color(0xFFA1A1AA) : const Color(0xFF52525B);
    final accent = isDark ? AppTheme.accentDark : AppTheme.accentLight;

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
        style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? accent : textPrimary,
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

/// ── _ThreeDotsMinimalLoader: Animasi Tiga Titik Berdenyut Minimalis (Identik Pembukaan Aplikasi) ──
class _ThreeDotsMinimalLoader extends StatefulWidget {
  final AgentModel? agent;
  final bool isDark;
  final VoidCallback onCancel;

  const _ThreeDotsMinimalLoader({
    required this.agent,
    required this.isDark,
    required this.onCancel,
  });

  @override
  State<_ThreeDotsMinimalLoader> createState() => _ThreeDotsMinimalLoaderState();
}

class _ThreeDotsMinimalLoaderState extends State<_ThreeDotsMinimalLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canvas = widget.isDark ? const Color(0xFF0E0E10) : const Color(0xFFFFFFFF);
    final textPrimary = widget.isDark ? Colors.white : const Color(0xFF18181B);
    final textSecondary = widget.isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final accent = widget.isDark ? const Color(0xFF10B981) : const Color(0xFF059669);

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: canvas,
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 3 Animated Dots
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (index) {
                      final delay = index * 0.2;
                      final t = (_controller.value - delay) % 1.0;
                      final curveVal = Curves.easeInOutSine.transform(t < 0 ? t + 1.0 : t);
                      final scale = 0.75 + (0.45 * (1.0 - (curveVal - 0.5).abs() * 2));
                      final opacity = 0.3 + (0.7 * (1.0 - (curveVal - 0.5).abs() * 2));

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        child: Transform.scale(
                          scale: scale,
                          child: Opacity(
                            opacity: opacity.clamp(0.25, 1.0),
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: accent,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
              const SizedBox(height: 20),
              Text(
                widget.agent?.title ?? 'Ruang Riset Turats',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Menyiapkan korpus naskah primer...',
                style: GoogleFonts.outfit(
                  fontSize: 12.5,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 28),
              TextButton(
                onPressed: widget.onCancel,
                child: Text(
                  'Batal',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: widget.isDark ? Colors.white60 : Colors.black54,
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

