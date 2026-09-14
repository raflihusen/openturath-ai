/// Conversation cleanup and explicit copy capture, restricted to NotebookLM.
const notebookUiScript = r'''
(function () {
  if (window.top !== window || !['notebooklm.google.com', 'notebook.google.com'].includes(location.hostname)) return;
  if (window.otNotebook) { window.otNotebook.clean(); return; }
  const answerSelector = '.chat-message[data-sender="model"], .model-message, .response-message, .to-user-container, .to-user-message, .chat-message-pair .answer, [data-message-author-role="assistant"]';
  const visible = el => !!el && el.getClientRects().length > 0 && getComputedStyle(el).visibility !== 'hidden' && getComputedStyle(el).display !== 'none';
  const text = el => (el?.innerText || el?.textContent || '').trim();
  function answerText(el) {
    const clone = el.cloneNode(true);
    clone.querySelectorAll('button, [role="button"], .message-actions, .feedback-buttons').forEach(e => e.remove());
    return text(clone);
  }
  function latest() {
    const answers = [...document.querySelectorAll(answerSelector)].filter(visible);
    return answers.length ? answerText(answers[answers.length - 1]) : '';
  }
  let lastCopy = '';
  let lastCopyAt = 0;
  function sendCopy(value) {
    if (typeof value !== 'string' || !value.trim() || value.length > 200000) return;
    if (value.trim() === lastCopy && Date.now() - lastCopyAt < 1000) return;
    lastCopy = value.trim(); lastCopyAt = Date.now();
    if (window.flutter_inappwebview?.callHandler) window.flutter_inappwebview.callHandler('otCopiedAnswer', value.trim());
  }
  // Observe only explicit answer-copy gestures; never read the device clipboard.
  let copyUntil = 0;
  let selectedAnswer = '';
  document.addEventListener('click', event => {
    const button = event.target.closest?.('button, [role="button"]');
    if (!button) return;
    const label = [button.getAttribute('aria-label'), button.getAttribute('title'), text(button)].filter(Boolean).join(' ');
    if (!/\b(copy|salin|content_copy)\b|نسخ/i.test(label)) return;
    const answer = button.closest(answerSelector);
    if (!answer) return;
    selectedAnswer = answerText(answer);
    copyUntil = Date.now() + 2000;
    // Save the selected answer even where the host uses a private clipboard API.
    sendCopy(selectedAnswer);
  }, true);
  document.addEventListener('copy', event => {
    if (Date.now() < copyUntil && selectedAnswer) sendCopy(selectedAnswer);
  });
  function applyOtTheme(isDark) {
    if (typeof isDark !== 'boolean') {
      isDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
    }
    try {
      var meta = document.querySelector('meta[name="color-scheme"]');
      if (!meta) {
        meta = document.createElement('meta');
        meta.name = 'color-scheme';
        (document.head || document.documentElement).appendChild(meta);
      }
      meta.content = isDark ? 'dark' : 'light';

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

      var styleEl = document.getElementById('ot-native-dark-mode');
      if (!styleEl) {
        styleEl = document.createElement('style');
        styleEl.id = 'ot-native-dark-mode';
        (document.head || document.documentElement).appendChild(styleEl);
      }
      if (isDark) {
        styleEl.textContent = `
          :root, :host, html, body {
            color-scheme: dark !important;
            --mdc-theme-background: #0E0E10 !important;
            --mdc-theme-surface: #18181B !important;
            --mdc-theme-on-surface: #FAFAFA !important;
            --mat-sys-color-surface: #0E0E10 !important;
            --mat-sys-color-on-surface: #FAFAFA !important;
            --mat-sys-color-surface-container: #18181B !important;
            --mat-sys-color-surface-container-low: #141416 !important;
            --mat-sys-color-surface-container-lowest: #0E0E10 !important;
            --mat-sys-color-surface-container-high: #202024 !important;
            --mat-sys-color-surface-container-highest: #27272A !important;
            --mat-sys-color-on-surface-variant: #A1A1AA !important;
            --mat-sys-color-outline: #3F3F46 !important;
            --mat-sys-color-outline-variant: #27272A !important;
            --mat-sys-color-background: #0E0E10 !important;
            --mat-sys-color-on-background: #FAFAFA !important;
            --mat-sys-color-primary: #FAFAFA !important;
            --mat-sys-color-on-primary: #18181B !important;
          }
          html, body, [role="main"], mat-sidenav-content, mat-sidenav-container,
          .chat-container, .chat-view, .chat-viewport, .conversation-container,
          .chat-panel-content, .message-list, .notebook-content, .scrollable-content,
          div.content-container, app-chat-window, app-chat-message, app-chat-response,
          .chat-message-container, .sources-panel, .studio-panel, main,
          div[class*="chat-panel" i], div[class*="conversation" i], div[class*="chat-view" i] {
            background-color: #0E0E10 !important;
            background: #0E0E10 !important;
            color: #FAFAFA !important;
          }
          .to-user-container, [data-message-author-role="user"], .user-query-container,
          div[class*="user-query" i], div[class*="to-user" i], .chat-message[data-sender="user"] {
            background-color: #27272A !important;
            background: #27272A !important;
            color: #FFFFFF !important;
            border-radius: 16px !important;
            border: 1px solid #3F3F46 !important;
          }
          .to-user-container *, [data-message-author-role="user"] * {
            color: #FFFFFF !important;
          }
          .chat-message[data-sender="model"], .model-message, .response-message,
          [data-message-author-role="assistant"], .rendered-markdown,
          div[class*="response-container" i], .message-content, app-chat-response {
            background-color: transparent !important;
            background: transparent !important;
            color: #FAFAFA !important;
          }
          .rendered-markdown p, .rendered-markdown span, .rendered-markdown div,
          .rendered-markdown li, .rendered-markdown blockquote,
          .rendered-markdown em, .rendered-markdown i,
          .chat-message[data-sender="model"] p, .model-message p, .response-message p,
          .chat-message[data-sender="model"] span, .model-message span, .response-message span {
            color: #FAFAFA !important;
          }
          .rendered-markdown strong, .rendered-markdown b,
          .rendered-markdown h1, .rendered-markdown h2, .rendered-markdown h3, .rendered-markdown h4 {
            color: #FFFFFF !important;
            font-weight: 700 !important;
          }
          .chat-input-container, div[class*="chat-input" i], div[class*="input-container" i],
          .bottom-bar, div[class*="bottom-bar" i], div[class*="bottom-container" i],
          div[class*="dock" i], div[class*="footer" i], div[class*="query-container" i],
          app-chat-input, chat-input, form, .input-area, .query-area,
          .query-box, .input-box, .bottom-sheet-content, footer,
          div[class*="action-bar" i], div[class*="input-row" i],
          .chat-footer, .conversation-footer {
            background-color: #0E0E10 !important;
            background: #0E0E10 !important;
            border-color: #27272A !important;
          }
          div[class*="input-box" i], div[class*="query-input" i], div[class*="search-box" i],
          div[class*="input-wrapper" i], div[class*="query-field" i], div[class*="text-field" i],
          div[class*="composer" i], .chat-composer,
          mat-form-field, .mat-mdc-form-field, .mdc-text-field,
          .mat-mdc-text-field-wrapper, .mat-mdc-form-field-flex,
          textarea, [contenteditable="true"], [role="textbox"], input[type="text"] {
            background-color: #18181B !important;
            background: #18181B !important;
            color: #FAFAFA !important;
            border: 1px solid #27272A !important;
          }
          textarea::placeholder, input::placeholder, [class*="placeholder"],
          .query-placeholder, [data-placeholder] {
            color: #A1A1AA !important;
            -webkit-text-fill-color: #A1A1AA !important;
          }
          button.send-button, button[aria-label*="Send" i], button[aria-label*="Kirim" i],
          button[type="submit"], button.mat-mdc-icon-button,
          button[class*="send" i], button[class*="submit" i] {
            background-color: #27272A !important;
            background: #27272A !important;
            color: #FAFAFA !important;
            border: 1px solid #3F3F46 !important;
          }
          button.send-button *, button[type="submit"] *, button.mat-mdc-icon-button *,
          button[class*="send" i] * {
            color: #FAFAFA !important;
            fill: #FAFAFA !important;
          }
          table, th, td { border-color: #27272A !important; }
          a { color: #93C5FD !important; }
        `;
      } else {
        styleEl.textContent = 'html, body { background-color: #FFFFFF !important; color: #18181B !important; }';
      }
    } catch(e) {}
  }
  window.otSetTheme = applyOtTheme;

  function hide(el) { if (el && !el.hasAttribute('data-ot-hidden')) el.setAttribute('data-ot-hidden', ''); }
  function clean() {
    if (!document.documentElement) return;
    applyOtTheme();
    if (!document.getElementById('ot-conversation-ui')) {
      const style = document.createElement('style'); style.id = 'ot-conversation-ui';
      style.textContent = `
        [data-ot-hidden],
        .tab-bar, app-tab-bar, .tabs-container, nav[class*="tab"], div[class*="tab-bar"],
        [role="tablist"], mat-tab-header, .mobile-tab-bar, .mobile-tabs, .mobile-navigation,
        mat-progress-spinner, mat-spinner, .mdc-circular-progress, [role="progressbar"],
        svg.spinner, div[class*="spinner" i], div[class*="skeleton" i], div[class*="shimmer" i],
        div[class*="placeholder-bar" i],
        button[aria-label*="More" i], button[aria-label*="Opsi" i],
        button[aria-label*="options" i], button[aria-label*="Notebook options" i],
        /* Anti-flicker zero-latency disclaimer suppression (OT-A003) */
        [aria-label*="Gemini" i],
        [aria-label*="disclaimer" i],
        div[role="region"][aria-label*="disclaimer" i],
        .chat-disclaimer, .disclaimer, .chat-footer-disclaimer, [class*="disclaimer" i], footer[class*="disclaimer" i],
        div[class*="disclaimer" i], p[class*="disclaimer" i], span[class*="disclaimer" i],
        app-disclaimer, .disclaimer-container, .disclaimer-text, .bottom-disclaimer,
        .chat-input-subtext, .input-subtext, .query-disclaimer, .model-disclaimer,
        footer, .chat-footer, .conversation-footer,
        div.chat-input-container + div,
        div[class*="input-container" i] + div,
        div[class*="query-container" i] + div,
        .notebook-guide, notebook-guide, .notebook-overview, notebook-overview,
        .notebook-cover, .notebook-cover-container, .notebook-title-card,
        .notebook-header, .project-header, .chat-header, .chat-panel-header,
        .header-content, .title-card, mat-card.title-card,
        .loading-notebook, [class*="skeleton"] {
          display:none!important;
          visibility:hidden!important;
          height:0px!important;
          max-height:0px!important;
          overflow:hidden!important;
          margin:0px!important;
          padding:0px!important;
          opacity:0!important;
          pointer-events:none!important;
          border:none!important;
        }
      `;
      (document.head || document.documentElement).appendChild(style);
    }
    // Sembunyikan tab strip Sources | Chat | Studio
    document.querySelectorAll('nav, div, [role="tablist"], ul').forEach(el => {
      const t = (el.innerText || '').toLowerCase();
      if ((t.includes('sources') || t.includes('sumber')) && (t.includes('studio') || t.includes('chat'))) {
        if (!el.closest(answerSelector) && el.children.length <= 6) hide(el);
      }
    });
    // Sembunyikan disclaimer Google Gemini / NotebookLM secara komprehensif
    const disclaimerPattern = /(?:inaccurate|double-check|double check|can make mistakes|make mistakes|may display inaccurate|tidak akurat|membuat kesalahan|periksa kembali|gemini notebook|notebooklm)/i;
    document.querySelectorAll('p, span, div, footer, small, a').forEach(el => {
      if (el.closest(answerSelector) || el.querySelector('textarea, [contenteditable="true"]') || el.closest('button, [role="button"]')) return;
      const value = text(el);
      if (value.length > 5 && value.length < 350 && disclaimerPattern.test(value)) {
        let target = el;
        for (let i = 0; target && i < 4; i++) {
          if (target.parentElement && 
              !target.parentElement.querySelector('textarea, [contenteditable="true"]') && 
              !target.parentElement.closest(answerSelector) && 
              target.parentElement !== document.body && 
              target.parentElement !== document.documentElement) {
            target = target.parentElement;
          } else {
            break;
          }
        }
        hide(target);
        hide(el);
        try { target.style.setProperty('display', 'none', 'important'); } catch (_) {}
      }
    });
    // Sembunyikan card overview / cover di awal percakapan
    document.querySelectorAll('h1, h2, h3, [class*="notebook-title"], [class*="title-card"], [class*="project-title"]').forEach(el => {
      if (el.closest(answerSelector)) return;
      let card = el;
      for (let i = 0; card && i < 6; i++, card = card.parentElement) {
        if (card.querySelector('textarea, [contenteditable="true"]') || card.querySelector(answerSelector)) break;
        if (/\b\d+\s+(sources|sumber)\b/i.test(text(card)) && text(card).length < 2000) { hide(card); break; }
      }
    });
    // Auto-dismiss dialog pengumuman Google
    document.querySelectorAll('[role="dialog"], mat-dialog-container, .cdk-overlay-pane, [class*="announcement"]').forEach(dialog => {
      const t = text(dialog).toLowerCase();
      if (!t.includes('more flexibility and control') && !t.includes('limits refresh every 5 hours') && !t.includes('gemini notebook')) return;
      if (!dialog.hasAttribute('data-ot-dismissed')) {
        dialog.setAttribute('data-ot-dismissed', '');
        const close = [...dialog.querySelectorAll('button, [role="button"]')].find(b => /^(close|dismiss|got it|tutup|mengerti|done|ok)$/i.test((b.getAttribute('aria-label') || text(b)).trim()));
        if (close) { close.click(); return; }
      }
      const pane = dialog.closest('.cdk-overlay-pane') || dialog;
      hide(pane);
      const wrapper = pane.parentElement;
      if (wrapper?.classList.contains('cdk-global-overlay-wrapper')) {
        hide(wrapper);
        const backdrop = wrapper.previousElementSibling;
        if (backdrop?.classList.contains('cdk-overlay-backdrop')) hide(backdrop);
      }
    });
    // Perbarui placeholder input ke bahasa santri alami
    const targetPlaceholder = 'Ajukan pertanyaan atau masalah';
    document.querySelectorAll('textarea, [contenteditable="true"], [role="textbox"], input[type="text"]').forEach(input => {
      if (input.placeholder && input.placeholder !== targetPlaceholder) {
        input.placeholder = targetPlaceholder;
      }
      if (input.getAttribute('data-placeholder') && input.getAttribute('data-placeholder') !== targetPlaceholder) {
        input.setAttribute('data-placeholder', targetPlaceholder);
      }
      if (input.getAttribute('aria-label') && /ask|ketik|type|pertanyaan|masalah/i.test(input.getAttribute('aria-label'))) {
        input.setAttribute('aria-label', targetPlaceholder);
      }
    });
    document.querySelectorAll('.query-placeholder, [class*="placeholder"]').forEach(el => {
      if (el.closest(answerSelector)) return;
      const t = text(el).toLowerCase();
      if (t.includes('start typing') || t.includes('ask a question') || t.includes('tanyakan') || t.includes('ketik pesan') || t.includes('ajukan')) {
        if (el.innerText !== targetPlaceholder && el.children.length === 0) {
          el.innerText = targetPlaceholder;
        }
      }
    });
  }
  function ready() {
    clean();
    const bodyText = document.body ? (document.body.innerText || '') : '';
    if (/loading notebook|memuat notebook|\b0 sources\b/i.test(bodyText)) {
      return false;
    }
    const hasSpinner = [...document.querySelectorAll('[role="progressbar"], mat-progress-spinner, mat-spinner, .loading-spinner, .mdc-circular-progress, svg.spinner, div[class*="spinner" i], div[class*="skeleton" i], div[class*="shimmer" i]')].some(el => {
      if (!el) return false;
      return el.offsetWidth > 0 || el.offsetHeight > 0 || el.getClientRects().length > 0;
    });
    if (hasSpinner) return false;

    const input = [...document.querySelectorAll('textarea, [contenteditable="true"], [role="textbox"]')].find(visible);
    return !!input && !input.disabled && input.getAttribute('aria-disabled') !== 'true';
  }
  window.otNotebook = {clean, ready, latest, setTheme: applyOtTheme};
  let scheduled = false;
  const observer = new MutationObserver(() => {
    if (scheduled) return;
    scheduled = true;
    requestAnimationFrame(() => { scheduled = false; clean(); });
  });
  observer.observe(document, {subtree:true, childList:true, characterData:true});
  clean();
})();
''';

/// Unified master dark stylesheet for NotebookLM AI workspace.
const otDarkThemeCss = r'''
:root, :host, html, body {
  color-scheme: dark !important;
  --mdc-theme-background: #0E0E10 !important;
  --mdc-theme-surface: #18181B !important;
  --mdc-theme-on-surface: #FAFAFA !important;
  --mat-sys-color-surface: #0E0E10 !important;
  --mat-sys-color-on-surface: #FAFAFA !important;
  --mat-sys-color-surface-container: #18181B !important;
  --mat-sys-color-surface-container-low: #141416 !important;
  --mat-sys-color-surface-container-lowest: #0E0E10 !important;
  --mat-sys-color-surface-container-high: #202024 !important;
  --mat-sys-color-surface-container-highest: #27272A !important;
  --mat-sys-color-on-surface-variant: #A1A1AA !important;
  --mat-sys-color-outline: #3F3F46 !important;
  --mat-sys-color-outline-variant: #27272A !important;
  --mat-sys-color-background: #0E0E10 !important;
  --mat-sys-color-on-background: #FAFAFA !important;
  --mat-sys-color-primary: #FAFAFA !important;
  --mat-sys-color-on-primary: #18181B !important;
}
html, body, [role="main"], mat-sidenav-content, mat-sidenav-container,
.chat-container, .chat-view, .chat-viewport, .conversation-container,
.chat-panel-content, .message-list, .notebook-content, .scrollable-content,
div.content-container, app-chat-window, app-chat-message, app-chat-response,
.chat-message-container, .sources-panel, .studio-panel, main,
div[class*="chat-panel" i], div[class*="conversation" i], div[class*="chat-view" i] {
  background-color: #0E0E10 !important;
  background: #0E0E10 !important;
  color: #FAFAFA !important;
}
.to-user-container, [data-message-author-role="user"], .user-query-container,
div[class*="user-query" i], div[class*="to-user" i], .chat-message[data-sender="user"] {
  background-color: #27272A !important;
  background: #27272A !important;
  color: #FFFFFF !important;
  border-radius: 16px !important;
  border: 1px solid #3F3F46 !important;
}
.to-user-container *, [data-message-author-role="user"] * {
  color: #FFFFFF !important;
}
.chat-message[data-sender="model"], .model-message, .response-message,
[data-message-author-role="assistant"], .rendered-markdown,
div[class*="response-container" i], .message-content, app-chat-response {
  background-color: transparent !important;
  background: transparent !important;
  color: #FAFAFA !important;
}
.rendered-markdown p, .rendered-markdown span, .rendered-markdown div,
.rendered-markdown li, .rendered-markdown blockquote,
.rendered-markdown em, .rendered-markdown i,
.chat-message[data-sender="model"] p, .model-message p, .response-message p,
.chat-message[data-sender="model"] span, .model-message span, .response-message span {
  color: #FAFAFA !important;
}
.rendered-markdown strong, .rendered-markdown b,
.rendered-markdown h1, .rendered-markdown h2, .rendered-markdown h3, .rendered-markdown h4 {
  color: #FFFFFF !important;
  font-weight: 700 !important;
}
.chat-input-container, div[class*="chat-input" i], div[class*="input-container" i],
.bottom-bar, div[class*="bottom-bar" i], div[class*="bottom-container" i],
div[class*="dock" i], div[class*="footer" i], div[class*="query-container" i],
app-chat-input, chat-input, form, .input-area, .query-area,
.query-box, .input-box, .bottom-sheet-content, footer,
div[class*="action-bar" i], div[class*="input-row" i],
.chat-footer, .conversation-footer {
  background-color: #0E0E10 !important;
  background: #0E0E10 !important;
  border-color: #27272A !important;
}
div[class*="input-box" i], div[class*="query-input" i], div[class*="search-box" i],
div[class*="input-wrapper" i], div[class*="query-field" i], div[class*="text-field" i],
div[class*="composer" i], .chat-composer,
mat-form-field, .mat-mdc-form-field, .mdc-text-field,
.mat-mdc-text-field-wrapper, .mat-mdc-form-field-flex,
textarea, [contenteditable="true"], [role="textbox"], input[type="text"] {
  background-color: #18181B !important;
  background: #18181B !important;
  color: #FAFAFA !important;
  border: 1px solid #27272A !important;
}
textarea::placeholder, input::placeholder, [class*="placeholder"],
.query-placeholder, [data-placeholder] {
  color: #A1A1AA !important;
  -webkit-text-fill-color: #A1A1AA !important;
}
button.send-button, button[aria-label*="Send" i], button[aria-label*="Kirim" i],
button[type="submit"], button.mat-mdc-icon-button,
button[class*="send" i], button[class*="submit" i] {
  background-color: #27272A !important;
  background: #27272A !important;
  color: #FAFAFA !important;
  border: 1px solid #3F3F46 !important;
}
button.send-button *, button[type="submit"] *, button.mat-mdc-icon-button *,
button[class*="send" i] * {
  color: #FAFAFA !important;
  fill: #FAFAFA !important;
}
table, th, td { border-color: #27272A !important; }
a { color: #93C5FD !important; }
''';

/// Unified master light stylesheet.
const otLightThemeCss = r'''
html, body {
  background-color: #FFFFFF !important;
  color: #18181B !important;
}
''';
