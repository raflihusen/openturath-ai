/// Conversation cleanup and explicit copy capture, restricted to NotebookLM.
const notebookUiScript = r'''
(function () {
  if (window.top !== window || !['notebooklm.google.com', 'notebook.google.com'].includes(location.hostname)) return;
  if (window.otNotebook) {
    window.otOpenLanguageSettings = window.otNotebook.openLanguageSettings;
    window.otDeleteChatHistory = window.otNotebook.deleteChatHistory;
    window.otClearChat = window.otNotebook.clearChat;
    if (typeof window.otNotebook.clean === 'function') {
      window.otNotebook.clean();
    }
    return;
  }
  const answerSelector = '.chat-message[data-sender="model"], .model-message, .response-message, .to-user-container, .to-user-message, .chat-message-pair .answer, [data-message-author-role="assistant"], app-chat-response, app-chat-message, .chat-response, [role="article"]';
  const questionSelector = '.chat-message[data-sender="user"], .user-message, .from-user, .to-model-container, [data-message-author-role="user"], app-chat-query, app-chat-prompt';
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
  function conversation() {
    const nodes = [...document.querySelectorAll(questionSelector + ',' + answerSelector)].filter(visible);
    const entries = [];
    const seen = new Set();
    nodes.forEach(node => {
      const value = answerText(node);
      if (!value || seen.has(value)) return;
      const isQuestion = node.matches(questionSelector) || !!node.closest(questionSelector);
      const role = isQuestion ? 'PERTANYAAN' : 'JAWABAN';
      if (entries.some(entry => entry.role === role && entry.value.includes(value))) return;
      entries.push({role, value});
      seen.add(value);
    });
    if (!entries.some(entry => entry.role === 'JAWABAN')) {
      const answer = latest();
      if (answer) entries.push({role: 'JAWABAN', value: answer});
    }
    if (!entries.length) return '';
    const counters = {PERTANYAAN: 0, JAWABAN: 0};
    return entries.map(entry => {
      counters[entry.role] += 1;
      return `${entry.role} ${counters[entry.role]}\n${entry.value}`;
    }).join('\n\n────────────────────\n\n');
  }
  let lastCopy = '';
  let lastCopyAt = 0;
  function sendCopy(value) {
    if (typeof value !== 'string' || !value.trim() || value.length > 200000) return;
    if (Date.now() - lastCopyAt < 3500) return;
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
    copyUntil = Date.now() + 2000;
    sendCopy(selectedAnswer);
  }, true);
  document.addEventListener('copy', event => {
    var sel = (window.getSelection ? window.getSelection().toString() : '').trim();
    if (sel) {
      sendCopy(sel);
    } else if (Date.now() < copyUntil && selectedAnswer) {
      sendCopy(selectedAnswer);
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

  let presentationEnabled = true;

  function ensureStyles() {
    let style = document.getElementById('ot-conversation-ui');
    if (!style) {
      style = document.createElement('style');
      style.id = 'ot-conversation-ui';
      (document.head || document.documentElement).appendChild(style);
    }
    style.textContent = `
      /* Sembunyikan SEMUA bilah header/navigasi NotebookLM dan Google */
      body > header,
      top-bar, .top-bar,
      app-header, .app-header,
      mat-toolbar, mat-toolbar-row,
      .notebook-header, app-notebook-header,
      .project-header, app-project-header,
      app-chat-header, chat-header, .chat-header,
      app-top-bar, .mobile-header,
      header, [role="banner"],
      .title-container, .title-bar, .notebook-title, .project-title,
      [class*="title-bar" i], [class*="header-row" i],
      [class*="title-container" i], [class*="notebook-title" i], [class*="project-title" i],
      /* Sembunyikan elemen di dalam header */
      app-user-avatar, div[class*="gb_"], #gb, #gbwa,
      [aria-label*="Google apps" i], [aria-label*="Aplikasi Google" i],
      [aria-label*="Google Account" i], [aria-label*="Akun Google" i],
      a[href*="myaccount.google.com"], button:has(app-user-avatar),
      labs-tailwind-logo, a.logo-link, a[aria-label*="NotebookLM" i], svg[aria-label*="NotebookLM" i],
      button[aria-label*="Settings" i], button[aria-label*="Setelan" i],
      button[aria-label*="Pengaturan" i], button[aria-label*="Notebook settings" i],
      .project-header button, app-project-header button,
      mat-toolbar button, .top-bar button,
      /* Sembunyikan kartu hero / overview / summary / intro buku catatan di tengah obrolan */
      app-notebook-guide, notebook-guide, app-guide-intro,
      app-project-summary, app-notebook-overview,
      app-artifact-summary, .artifact-summary,
      .notebook-guide, .guide-container, .hero-container,
      .cover-image-container, .summary-card, .guide-card,
      app-chat-intro, app-conversation-intro, app-notebook-intro,
      app-project-intro, app-chat-empty-state, app-empty-state,
      .chat-intro, .conversation-intro, .notebook-intro, .project-intro,
      .chat-empty-state, .empty-state,
      [class*="guide-intro" i], [class*="project-summary" i],
      [class*="project-overview" i], [class*="notebook-overview" i],
      [class*="chat-intro" i], [class*="conversation-intro" i],
      [class*="notebook-intro" i], [class*="project-intro" i],
      [class*="empty-state" i],
      /* Sembunyikan badge PRO */
      .pro-badge, [class*="pro-badge" i], [class*="tier-badge" i],
      /* Sembunyikan Disclaimer Bawah Secara Total */
      .disclaimer, [class*="disclaimer" i], footer, [role="contentinfo"] {
        display: none !important;
        visibility: hidden !important;
        height: 0 !important;
        min-height: 0 !important;
        max-height: 0 !important;
        overflow: hidden !important;
        padding: 0 !important;
        margin: 0 !important;
      }

      /* Sembunyikan tombol opsi titik tiga di dalam webview obrolan */
      button[aria-label*="chat options" i],
      button[aria-label*="more options" i],
      button[aria-label*="opsi lainnya" i],
      button[aria-label*="opsi obrolan" i],
      button[aria-label*="opsi percakapan" i],
      button[aria-label*="notebook options" i],
      button[aria-label*="opsi buku catatan" i],
      button[aria-label*="opsi proyek" i],
      button[aria-label="More" i],
      button[aria-label="Opsi" i],
      button[aria-label*="More actions" i],
      button[aria-label*="Tindakan lainnya" i],
      .chat-options-button,
      [class*="chat-options" i],
      [class*="chat-actions" i],
      .conversation-actions,
      button:has(mat-icon[data-mat-icon-name="more_vert"]),
      button:has(mat-icon[data-mat-icon-name="more_horiz"]),
      button:has(mat-icon[fonticon="more_vert"]),
      button:has(mat-icon[fonticon="more_horiz"]) {
        opacity: 0 !important;
        pointer-events: none !important;
        position: absolute !important;
        left: -9999px !important;
        top: -9999px !important;
        width: 0 !important;
        height: 0 !important;
        min-width: 0 !important;
        min-height: 0 !important;
        padding: 0 !important;
        margin: 0 !important;
        border: none !important;
        overflow: hidden !important;
      }

      .ot-opening-language [role="menu"],
      .ot-opening-language .mat-mdc-menu-panel { opacity: 0 !important; }
      .cdk-overlay-container { z-index: 99999 !important; }

      /* Ruang bawah obrolan agar pesan tidak tertutup */
      .chat-panel-content, .chat-view, .conversation-container, .message-list, [role="log"] {
        padding-bottom: max(64px, calc(env(safe-area-inset-bottom, 24px) + 48px)) !important;
      }
      div.chat-input-container, .input-container, app-chat-input, form.chat-input-form,
      [class*="input-container" i], [class*="chat-input" i],
      .chat-input-area, [class*="input-area" i], .query-box-container {
        margin-bottom: max(22px, calc(env(safe-area-inset-bottom, 16px) + 14px)) !important;
      }

      .chat-message-pair, .to-user-container, .to-model-container {
        margin-bottom: 18px !important;
      }
      .rendered-markdown, .chat-response {
        font-size: var(--ot-font-size, 15.5px) !important;
        line-height: 1.8 !important;
      }
      .rendered-markdown p + p, .chat-response p + p { margin-top: 1em !important; }
      ::-webkit-scrollbar { display: none !important; width: 0 !important; }
      html, body, * { scrollbar-width: none !important; }
    `;
  }

  function removeTopToolbars() {
    const selectors = [
      'body > header', 'top-bar', '.top-bar', 'app-header', '.app-header',
      'mat-toolbar', 'mat-toolbar-row', '.notebook-header', 'app-notebook-header',
      '.project-header', 'app-project-header', 'header', '[role="banner"]',
      'app-chat-header', 'chat-header', '.chat-header', 'app-top-bar', '.mobile-header',
      'app-user-avatar', 'div[class*="gb_"]', '#gb', '#gbwa',
      '[aria-label*="Google apps" i]', '[aria-label*="Aplikasi Google" i]',
      '[aria-label*="Google Account" i]', '[aria-label*="Akun Google" i]',
      'a[href*="myaccount.google.com"]',
      'labs-tailwind-logo', 'a.logo-link', 'a[aria-label*="NotebookLM" i]', 'svg[aria-label*="NotebookLM" i]',
      'button[aria-label*="Settings" i]', 'button[aria-label*="Setelan" i]',
      'button[aria-label*="Pengaturan" i]', 'button[aria-label*="Notebook settings" i]',
      '.pro-badge', '[class*="pro-badge" i]', '[class*="tier-badge" i]'
    ];
    selectors.forEach(sel => {
      document.querySelectorAll(sel).forEach(el => {
        el.style.setProperty('display', 'none', 'important');
      });
    });

    // Sembunyikan tombol opsi titik tiga (more_vert / more_horiz / options) secara halus
    document.querySelectorAll('mat-icon, [data-mat-icon-name]').forEach(icon => {
      const name = (icon.getAttribute('data-mat-icon-name') || icon.getAttribute('fonticon') || icon.textContent || '').trim().toLowerCase();
      if (name === 'more_vert' || name === 'more_horiz') {
        const btn = icon.closest('button, [role="button"]');
        if (btn && btn.querySelectorAll('textarea, input').length === 0) {
          btn.style.setProperty('opacity', '0', 'important');
          btn.style.setProperty('pointer-events', 'none', 'important');
          btn.style.setProperty('position', 'absolute', 'important');
          btn.style.setProperty('left', '-9999px', 'important');
          btn.style.setProperty('width', '0', 'important');
          btn.style.setProperty('height', '0', 'important');
        }
      }
    });

    document.querySelectorAll('button[aria-label*="options" i], button[aria-label*="opsi" i], button[aria-label*="more" i]').forEach(btn => {
      const label = (btn.getAttribute('aria-label') || '').toLowerCase();
      if (!label.includes('send') && !label.includes('kirim') && !label.includes('mic') && !label.includes('suara')) {
        btn.style.setProperty('opacity', '0', 'important');
        btn.style.setProperty('pointer-events', 'none', 'important');
        btn.style.setProperty('position', 'absolute', 'important');
        btn.style.setProperty('left', '-9999px', 'important');
        btn.style.setProperty('width', '0', 'important');
        btn.style.setProperty('height', '0', 'important');
      }
    });

    // Sembunyikan lencana PRO dengan selektor spesifik (tanpa querySelectorAll(*))
    document.querySelectorAll('.pro-badge, [class*="pro-badge" i], [class*="tier-badge" i], button span, a span').forEach(el => {
      if (el.children.length === 0 && (el.textContent || '').trim().toUpperCase() === 'PRO') {
        const badge = el.closest('button, a, span, div');
        if (badge && badge !== document.body && badge.querySelectorAll('textarea, input').length === 0) {
          badge.style.setProperty('display', 'none', 'important');
        }
      }
    });

    // Sembunyikan baris header atas spesifik tanpa forced layout loop
    document.querySelectorAll('body > div, app-root > div, header, [role="banner"], app-top-bar, .top-bar').forEach(el => {
      if (el.children.length > 0 && el.children.length <= 10) {
        const txt = (el.innerText || el.textContent || '').trim().toLowerCase();
        const hasShared = txt.includes('shared') || txt.includes('dibagikan');
        const hasAvatar = el.querySelector('app-user-avatar, [aria-label*="Google Account" i]');
        if ((hasShared || hasAvatar) && !el.querySelector('textarea, [contenteditable="true"], form')) {
          if (!el.matches('.chat-view, .chat-panel-content, main, [role="main"], app-root')) {
            el.style.setProperty('display', 'none', 'important');
          }
        }
      }
    });
  }

  function removeHeroCard() {
    const guideSelectors = [
      'app-notebook-guide', 'notebook-guide', 'app-guide-intro',
      'app-project-summary', 'app-notebook-overview',
      'app-artifact-summary', '.artifact-summary',
      '.notebook-guide', '.guide-container', '.hero-container',
      '.cover-image-container', '.summary-card', '.guide-card',
      'app-chat-intro', 'app-conversation-intro', 'app-notebook-intro',
      'app-project-intro', 'app-chat-empty-state', 'app-empty-state',
      '.chat-intro', '.conversation-intro', '.notebook-intro', '.project-intro',
      '.chat-empty-state', '.empty-state',
      '[class*="guide-intro" i]', '[class*="project-summary" i]',
      '[class*="project-overview" i]', '[class*="notebook-overview" i]',
      '[class*="chat-intro" i]', '[class*="conversation-intro" i]',
      '[class*="notebook-intro" i]', '[class*="project-intro" i]',
      '[class*="empty-state" i]'
    ];
    guideSelectors.forEach(sel => {
      document.querySelectorAll(sel).forEach(el => {
        el.style.setProperty('display', 'none', 'important');
      });
    });

    // Cari intro "sources" hanya pada area chat / panel utama (sangat hemat CPU)
    document.querySelectorAll('.chat-panel-content, .chat-view, .conversation-container, .message-list, [role="log"], main').forEach(panel => {
      const firstMessage = panel.querySelector('.chat-message, .model-message, .user-message, [role="article"], .chat-message-pair');
      if (firstMessage) {
        let prev = firstMessage.previousElementSibling;
        while (prev) {
          const prevTxt = (prev.textContent || '').toLowerCase();
          if (prevTxt.includes('source') || prevTxt.includes('sumber') || prevTxt.includes('•') || prev.querySelector('img, svg, mat-icon') || prevTxt.length < 80) {
            if (!prev.querySelector('textarea, [contenteditable="true"]')) {
              prev.style.setProperty('display', 'none', 'important');
            }
          }
          prev = prev.previousElementSibling;
        }
      }
    });
  }

  let lastCleanAt = 0;
  function clean() {
    if (!document.documentElement) return;
    const now = Date.now();
    if (now - lastCleanAt < 800) return;
    lastCleanAt = now;
    syncTheme();
    ensureStyles();
    removeTopToolbars();
    removeHeroCard();
  }

  function triggerClick(el) {
    if (!el) return false;
    try {
      el.click();
      return true;
    } catch (e) {
      try {
        return el.dispatchEvent(new MouseEvent('click', { bubbles: true, cancelable: true }));
      } catch (_) { return false; }
    }
  }

  function findOutputLanguageItem() {
    const panels = [...document.querySelectorAll('[role="menu"], .mat-mdc-menu-panel, .cdk-overlay-pane')];
    if (panels.length === 0) return null;
    const candidates = panels.flatMap(panel => [...panel.querySelectorAll('[role="menuitem"], button, mat-list-item')]);
    return candidates.find(candidate => {
      if (!candidate || !document.contains(candidate)) return false;
      const label = (candidate.getAttribute('aria-label') || candidate.innerText || candidate.textContent || '')
        .trim().replace(/\s+/g, ' ').toLowerCase();
      if (label.includes('output language') || label.includes('bahasa output') || label.includes('bahasa keluaran') || label.includes('لغة الإخراج')) {
        return true;
      }
      const icon = candidate.querySelector('mat-icon, i, [data-mat-icon-name]');
      const iconName = icon ? (icon.getAttribute('data-mat-icon-name') || icon.getAttribute('fonticon') || icon.innerText || '').trim().toLowerCase() : '';
      if ((iconName === 'language' || iconName === 'public' || iconName === 'translate') && (label.includes('language') || label.includes('bahasa') || label.includes('output') || label.includes('لغة'))) {
        return true;
      }
      return false;
    });
  }

  function findSettingsButton() {
    let btn = document.querySelector('button[aria-label*="Settings" i], button[aria-label*="Setelan" i], button[aria-label*="Pengaturan" i], button[aria-label*="Notebook settings" i], [data-action*="settings" i]');
    if (btn) return btn;
    const icons = document.querySelectorAll('mat-icon, [data-mat-icon-name]');
    for (const icon of icons) {
      const name = (icon.getAttribute('data-mat-icon-name') || icon.getAttribute('fonticon') || icon.textContent || '').trim().toLowerCase();
      if (name === 'settings' || name.includes('setting')) {
        const parentBtn = icon.closest('button, [role="button"]');
        if (parentBtn) return parentBtn;
      }
    }
    return document.querySelector('button[aria-label*="More" i], button[aria-label*="Opsi" i], button[aria-label*="options" i]');
  }

  window.otOpenLanguageSettings = function() {
    const root = document.documentElement;
    root.classList.add('ot-opening-language');

    function cleanup() { root.classList.remove('ot-opening-language'); }

    const immediate = findOutputLanguageItem();
    if (immediate) {
      triggerClick(immediate);
      cleanup();
      return true;
    }

    const settings = findSettingsButton();
    if (!settings) {
      cleanup();
      return false;
    }

    if (!triggerClick(settings)) {
      cleanup();
      return false;
    }

    const deadline = Date.now() + 2500;
    const interval = setInterval(() => {
      const item = findOutputLanguageItem();
      if (item) {
        clearInterval(interval);
        triggerClick(item);
        cleanup();
        return;
      }
      if (Date.now() > deadline) {
        clearInterval(interval);
        cleanup();
      }
    }, 25);

    return true;
  };
  var otOpenLanguageSettings = window.otOpenLanguageSettings;
  window.otSendPrompt = function(promptText) {
    if (!promptText || typeof promptText !== 'string') return false;
    const input = document.querySelector('textarea, [contenteditable="true"], [role="textbox"], input[type="text"]');
    if (!input) return false;
    userPausedFollow = false;
    input.focus();
    if (input.tagName.toLowerCase() === 'textarea' || input.tagName.toLowerCase() === 'input') {
      input.value = promptText;
      input.dispatchEvent(new Event('input', { bubbles: true }));
      input.dispatchEvent(new Event('change', { bubbles: true }));
    } else {
      input.innerText = promptText;
      input.dispatchEvent(new Event('input', { bubbles: true }));
    }
    setTimeout(() => {
      const sendBtn = document.querySelector('button[aria-label*="send" i], button[aria-label*="kirim" i], [data-action*="send" i], button.send-button, form button[type="submit"]');
      if (sendBtn && !sendBtn.disabled) {
        sendBtn.click();
      } else {
        input.dispatchEvent(new KeyboardEvent('keydown', { key: 'Enter', code: 'Enter', keyCode: 13, which: 13, bubbles: true }));
      }
    }, 60);
    return true;
  };
  function conversationList() {
    const questionSelector = '.chat-message[data-sender="user"], .user-message, .from-user, .to-model-container, [data-message-author-role="user"], app-chat-query, app-chat-prompt';
    const nodes = [...document.querySelectorAll(questionSelector + ',' + answerSelector)].filter(visible);
    const list = [];
    const seen = new Set();
    nodes.forEach(node => {
      const val = answerText(node);
      if (!val || seen.has(val)) return;
      const isQuestion = node.matches(questionSelector) || !!node.closest(questionSelector);
      list.push({ isUser: isQuestion, text: val });
      seen.add(val);
    });
    return JSON.stringify(list);
  }
  window.otGetConversationList = conversationList;

  function isStillLoading() {
    const body = (document.body?.innerText || '').toLowerCase();
    return body.includes('loading notebook') || body.includes('memuat notebook');
  }

  function ready() {
    if (accessDenied()) return false;
    if (isStillLoading()) return false;
    return inputReady();
  }
  function inputReady() {
    const input = document.querySelector('textarea, [contenteditable="true"], [role="textbox"]');
    return !!(input && visible(input));
  }
function accessDenied() {
  if (inputReady()) return false;
  const body = (document.body?.innerText || '').toLowerCase();
  const title = (document.title || '').toLowerCase();
  const hasTextMatch = /anda memerlukan akses|minta akses|you need access|request access|tidak memiliki izin/.test(body) ||
    /anda memerlukan akses|you need access/.test(title);
  const hasElementMatch = !!document.querySelector('[aria-label*="Request access" i], [aria-label*="Minta akses" i], app-access-denied, div[class*="access-denied" i]');
  return hasTextMatch || hasElementMatch;
}
window.otDeleteChatHistory = function() {
  const moreBtns = [
    ...document.querySelectorAll('button[aria-label*="More" i], button[aria-label*="Opsi" i], button[aria-label*="options" i], button[aria-label*="chat options" i], mat-toolbar button, .project-header button')
  ];
  document.querySelectorAll('mat-icon, [data-mat-icon-name]').forEach(icon => {
    const name = (icon.getAttribute('data-mat-icon-name') || icon.getAttribute('fonticon') || icon.textContent || '').trim().toLowerCase();
    if (name === 'more_vert' || name === 'more_horiz') {
      const btn = icon.closest('button, [role="button"]');
      if (btn && !moreBtns.includes(btn)) moreBtns.push(btn);
    }
  });

  function findDeleteMenuItem() {
    const items = [...document.querySelectorAll('[role="menuitem"], .mat-mdc-menu-panel button, .cdk-overlay-pane button, mat-list-item')];
    return items.find(item => {
      const txt = (item.getAttribute('aria-label') || item.innerText || item.textContent || '').toLowerCase();
      return (txt.includes('delete') || txt.includes('hapus') || txt.includes('clear')) && 
             (txt.includes('chat') || txt.includes('history') || txt.includes('riwayat') || txt.includes('obrolan') || txt.includes('percakapan'));
    });
  }

  function confirmDialog() {
    const deadline = Date.now() + 2500;
    const interval = setInterval(() => {
      const dialogBtns = [...document.querySelectorAll('mat-dialog-container button, .cdk-overlay-pane [role="dialog"] button, [role="alertdialog"] button')];
      const confirmBtn = dialogBtns.find(b => {
        const t = (b.getAttribute('aria-label') || b.innerText || b.textContent || '').trim().toLowerCase();
        return (t === 'delete' || t === 'hapus' || t === 'clear' || t.includes('delete') || t.includes('hapus')) && !t.includes('cancel') && !t.includes('batal');
      });
      if (confirmBtn) {
        clearInterval(interval);
        triggerClick(confirmBtn);
      } else if (Date.now() > deadline) {
        clearInterval(interval);
      }
    }, 50);
  }

  const immediate = findDeleteMenuItem();
  if (immediate) {
    triggerClick(immediate);
    confirmDialog();
    return true;
  }

  for (const btn of moreBtns) {
    triggerClick(btn);
    setTimeout(() => {
      const item = findDeleteMenuItem();
      if (item) {
        triggerClick(item);
        confirmDialog();
      }
    }, 80);
  }
  return true;
};

window.otClearChat = function() {
  try {
    window.otDeleteChatHistory();
  } catch (_) {}
  try {
    const messageContainers = document.querySelectorAll('.chat-panel-content, .chat-view, .conversation-container, .message-list, [role="log"]');
    messageContainers.forEach(c => {
      const messages = c.querySelectorAll('.chat-message, .model-message, .user-message, .to-user-container, .to-model-container, app-chat-response, app-chat-query, app-chat-prompt, app-chat-message, [role="article"]');
      messages.forEach(m => m.remove());
    });
  } catch (_) {}
  return true;
};

window.otNotebook = {
  clean,
  activate: () => { presentationEnabled = true; clean(); },
  ready,
  inputReady,
  latest,
  conversation,
  conversationList,
  accessDenied,
  setTheme: syncTheme,
  openLanguageSettings: window.otOpenLanguageSettings,
  deleteChatHistory: window.otDeleteChatHistory,
  clearChat: window.otClearChat
};
let scheduled = false;
let isGenerating = false;
let lastAnswerText = '';
let userPausedFollow = false;
let followScheduled = false;

function chatScrollHost() {
  const candidates = document.querySelectorAll('.chat-panel-content, .chat-view, .conversation-container, .message-list, [role="log"]');
  for (const candidate of candidates) {
    if (candidate.scrollHeight > candidate.clientHeight + 24) return candidate;
  }
  return document.scrollingElement;
}

function followLatestAnswer() {
  if (userPausedFollow || followScheduled) return;
  followScheduled = true;
  requestAnimationFrame(() => {
    followScheduled = false;
    if (!userPausedFollow) {
      const host = chatScrollHost();
      if (host) host.scrollTop = host.scrollHeight;
    }
  });
}

document.addEventListener('touchstart', event => {
  const host = chatScrollHost();
  if (host && host.contains(event.target)) userPausedFollow = true;
}, {passive: true, capture: true});
document.addEventListener('wheel', event => {
  if (event.deltaY < 0) userPausedFollow = true;
}, {passive: true, capture: true});
document.addEventListener('click', event => {
  if (event.target.closest?.('button[type="submit"], button[aria-label*="send" i], button[aria-label*="kirim" i]')) {
    userPausedFollow = false;
  }
}, true);

function checkGenerationState() {
  const stopBtn = document.querySelector('button[aria-label*="Stop" i], button[aria-label*="Hentikan" i], [data-action*="stop" i]');
  const currentlyGenerating = !!(stopBtn && stopBtn.offsetParent !== null);

  // Jika sedang idle dan tidak menghasilkan jawaban, segera keluar (0% CPU saat diam)
  if (!currentlyGenerating && !isGenerating) return;

  const currentAnswer = latest();

  if (currentlyGenerating && !isGenerating) {
    isGenerating = true;
    lastAnswerText = currentAnswer;
    followLatestAnswer();
    if (window.flutter_inappwebview?.callHandler) {
      window.flutter_inappwebview.callHandler('otAnswerState', { state: 'generating', text: currentAnswer });
    }
  } else if (isGenerating) {
    if (currentAnswer && currentAnswer !== lastAnswerText) {
      lastAnswerText = currentAnswer;
      followLatestAnswer();
      if (window.flutter_inappwebview?.callHandler) {
        window.flutter_inappwebview.callHandler('otAnswerChunk', { text: currentAnswer });
      }
    }
    if (!currentlyGenerating) {
      isGenerating = false;
      if (window.flutter_inappwebview?.callHandler) {
        window.flutter_inappwebview.callHandler('otAnswerState', { state: 'completed', text: currentAnswer });
      }
    }
  }
}

// Blokir pintasan reload (Cmd+R, Ctrl+R, F5) agar layout webview tidak ter-reset
window.addEventListener('keydown', function(event) {
  const isR = event.key === 'r' || event.key === 'R' || event.keyCode === 82;
  if ((event.metaKey || event.ctrlKey) && isR) {
    event.preventDefault();
    event.stopPropagation();
    return false;
  }
  if (event.key === 'F5' || event.keyCode === 116) {
    event.preventDefault();
    event.stopPropagation();
    return false;
  }
}, true);

// Gunakan debounce 300ms dan childList saja (tanpa characterData) untuk menghemat baterai & CPU
const observer = new MutationObserver(() => {
  if (scheduled) return;
  scheduled = true;
  setTimeout(() => {
    scheduled = false;
    clean();
    checkGenerationState();
  }, 300);
});
observer.observe(document.body || document.documentElement, {subtree:true, childList:true});
ensureStyles();
clean();
})();
''';
