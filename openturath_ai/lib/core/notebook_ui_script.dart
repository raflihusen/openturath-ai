/// Conversation cleanup and explicit copy capture, restricted to NotebookLM.
const notebookUiScript = r'''
(function () {
  if (window.top !== window || !['notebooklm.google.com', 'notebook.google.com'].includes(location.hostname)) return;
  if (window.otNotebook) { window.otNotebook.clean(); return; }
  const answerSelector = '.chat-message[data-sender="model"], .model-message, .response-message, .to-user-container, .to-user-message, .chat-message-pair .answer, [data-message-author-role="assistant"], app-chat-response, app-chat-message, .chat-response, [role="article"]';
  const visible = el => !!el && el.getClientRects().length > 0 && getComputedStyle(el).visibility !== 'hidden' && getComputedStyle(el).display !== 'none';
  const text = el => (el?.innerText || el?.textContent || '').trim();
  function answerText(el) {
    if (!el) return '';
    const clone = el.cloneNode(true);
    clone.querySelectorAll('button, [role="button"], .message-actions, .feedback-buttons, [class*="action" i], [class*="feedback" i]').forEach(e => e.remove());
    return text(clone);
  }
  function latest() {
    let answers = [...document.querySelectorAll(answerSelector)].filter(visible);
    if (!answers.length) {
      answers = [...document.querySelectorAll('.rendered-markdown, div[class*="response-container" i], [role="article"]')].filter(visible);
    }
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
  // Tangkap klik pada tombol copy NotebookLM maupun seleksi copy biasa
  let copyUntil = 0;
  let selectedAnswer = '';
  document.addEventListener('click', event => {
    const copyTarget = event.target.closest?.('button, [role="button"], [data-action*="copy" i], [aria-label*="copy" i], [aria-label*="salin" i], .copy-button');
    if (!copyTarget) return;
    const label = [
      copyTarget.getAttribute('aria-label'),
      copyTarget.getAttribute('title'),
      copyTarget.getAttribute('data-action'),
      text(copyTarget),
      copyTarget.className
    ].filter(Boolean).join(' ');
    if (!/\b(copy|salin|content_copy)\b|نسخ/i.test(label) && !copyTarget.classList.toString().toLowerCase().includes('copy')) return;

    let answer = copyTarget.closest(answerSelector) ||
                 copyTarget.closest('.chat-message, .chat-response, app-chat-response, app-chat-message, [role="article"], .to-user-container, div[class*="response" i], div[class*="message" i], mat-card, .rendered-markdown');
    let extracted = answer ? answerText(answer) : '';
    if (!extracted) extracted = latest();
    if (!extracted) return;

    selectedAnswer = extracted;
    copyUntil = Date.now() + 3000;
    sendCopy(selectedAnswer);
  }, true);
  document.addEventListener('copy', event => {
    var sel = (window.getSelection ? window.getSelection().toString() : '').trim();
    if (sel) {
      sendCopy(sel);
    } else if (Date.now() < copyUntil && selectedAnswer) {
      sendCopy(selectedAnswer);
    } else {
      var last = latest();
      if (last) sendCopy(last);
    }
  });
  function syncTheme(isDark) {
    if (typeof isDark !== 'boolean') {
      if (typeof window._otIsDark === 'boolean') {
        isDark = window._otIsDark;
      } else {
        isDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
      }
    }
    window._otIsDark = isDark;
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
        document.body.style.colorScheme = isDark ? 'dark' : 'light';
      }
    } catch(e) {}
  }
  window.otSetTheme = syncTheme;

  function hide(el) { if (el && !el.hasAttribute('data-ot-hidden')) el.setAttribute('data-ot-hidden', ''); }
  function clean() {
    if (!document.documentElement) return;
    syncTheme();
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
  window.otNotebook = {clean, ready, latest, setTheme: syncTheme};
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
