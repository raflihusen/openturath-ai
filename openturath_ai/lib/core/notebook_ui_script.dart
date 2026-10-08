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
  const visible = el => !!el && (el.offsetWidth > 0 || el.offsetHeight > 0 || el.getClientRects().length > 0) && getComputedStyle(el).visibility !== 'hidden' && getComputedStyle(el).display !== 'none';
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
      /* Sembunyikan badge PRO */
      .pro-badge, [class*="pro-badge" i], [class*="tier-badge" i],
      /* Sembunyikan SEMUA elemen dan container loading internal NotebookLM */
      app-loading-screen, .loading-screen, .loading-container,
      [class*="loading-screen" i], [class*="notebook-loading" i], [class*="project-loading" i],
      .cdk-overlay-backdrop:has(mat-spinner), .cdk-overlay-pane:has(mat-spinner),
      mat-spinner, mat-progress-spinner, mat-progress-bar, [role="progressbar"],
      /* Sembunyikan chip saran prompt agar area obrolan bersih */
      button[class*="suggestion" i], [class*="chip" i], [class*="prompt-chip" i], mat-chip, mat-chip-set,
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

      /* Sembunyikan tombol opsi titik tiga dan header chat di dalam webview obrolan */
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
      button[aria-label*="more" i],
      button[aria-label*="opsi" i],
      button[aria-label*="options" i],
      button[aria-label*="tindakan" i],
      button[aria-label*="lainnya" i],
      button[aria-label*="menu" i],
      [role="button"][aria-label*="more" i],
      [role="button"][aria-label*="opsi" i],
      [role="button"][aria-label*="options" i],
      [role="button"][aria-label*="tindakan" i],
      [role="button"][aria-label*="lainnya" i],
      [role="button"][aria-label*="menu" i],
      .chat-options-button,
      [class*="chat-options" i],
      [class*="chat-actions" i],
      .conversation-actions,
      [class*="conversation-actions" i],
      [class*="header-actions" i],
      app-chat-header,
      .chat-header,
      [class*="chat-header" i],
      app-conversation-header,
      .conversation-header,
      [class*="conversation-header" i],
      button:has(mat-icon[data-mat-icon-name*="more"]),
      button:has(mat-icon[fonticon*="more"]),
      mat-icon[data-mat-icon-name*="more"],
      mat-icon[fonticon*="more"] {
        display: none !important;
        visibility: hidden !important;
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

      /* Sembunyikan elemen judul, ikon, cover, emoji Ka'bah, dan sumber di dalam empty state secara visual (transparan)
         sehingga tinggi layout dan posisi alami input di bawah tetap terjaga 100% tanpa kolaps */
      .empty-state-header,
      .chat-empty-state-container .empty-state-header,
      app-notebook-overview,
      .notebook-overview,
      [class*="notebook-overview" i],
      app-project-summary,
      .project-summary,
      [class*="project-summary" i],
      app-guide-intro,
      .guide-intro,
      [class*="guide-intro" i],
      app-chat-intro,
      .chat-intro,
      [class*="chat-intro" i],
      app-conversation-intro,
      .conversation-intro,
      [class*="conversation-intro" i],
      app-notebook-intro,
      .notebook-intro,
      [class*="notebook-intro" i],
      app-project-intro,
      .project-intro,
      [class*="project-intro" i],
      [class*="intro-header" i],
      [class*="hero-header" i],
      app-notebook-title,
      app-project-title,
      app-notebook-cover,
      .notebook-cover,
      [class*="notebook-cover" i],
      app-project-cover,
      .project-cover,
      [class*="project-cover" i],
      .cover-emoji,
      [class*="cover-emoji" i],
      .cover-icon,
      [class*="cover-icon" i],
      .notebook-icon,
      [class*="notebook-icon" i],
      .cover-image-container,
      [class*="cover-image" i],
      app-notebook-icon,
      app-cover-icon,
      app-emoji-picker,
      .emoji-picker,
      .chat-panel-content h1:not(.rendered-markdown *):not([role="article"] *),
      .chat-panel-content h2:not(.rendered-markdown *):not([role="article"] *),
      .chat-panel-content h3:not(.rendered-markdown *):not([role="article"] *),
      .chat-view h1:not(.rendered-markdown *):not([role="article"] *),
      .chat-view h2:not(.rendered-markdown *):not([role="article"] *),
      .chat-view h3:not(.rendered-markdown *):not([role="article"] *),
      app-chat-empty-state h1, app-chat-empty-state h2, app-chat-empty-state h3,
      app-chat-empty-state mat-icon, app-chat-empty-state img, app-chat-empty-state svg,
      app-chat-empty-state .notebook-cover, app-chat-empty-state .cover-emoji,
      app-empty-state h1, app-empty-state h2, app-empty-state h3,
      app-empty-state mat-icon, app-empty-state img, app-empty-state svg,
      .chat-empty-state h1, .chat-empty-state h2, .chat-empty-state h3,
      .chat-empty-state mat-icon, .chat-empty-state img, .chat-empty-state svg,
      .empty-state h1, .empty-state h2, .empty-state h3,
      .empty-state mat-icon, .empty-state img, .empty-state svg {
        visibility: hidden !important;
        opacity: 0 !important;
        pointer-events: none !important;
      }

      /* Sembunyikan saran / chips / prompt kartu di dalam empty state agar bersih */
      app-suggested-actions,
      .suggested-actions,
      [class*="suggested-actions" i],
      app-suggestion-chips,
      .suggestion-chips,
      [class*="prompt-chips" i],
      [class*="prompt-card" i] {
        display: none !important;
        visibility: hidden !important;
        height: 0 !important;
        margin: 0 !important;
        padding: 0 !important;
        overflow: hidden !important;
      }

      /* Pastikan bilah input chat dan komponen di dalamnya selalu terlihat dan interaktif */
      app-chat-input,
      app-chat-input *,
      div.chat-input-container,
      div.chat-input-container *,
      .input-container,
      .input-container *,
      form.chat-input-form,
      form.chat-input-form *,
      .chat-input-area,
      .chat-input-area *,
      .query-box-container,
      .query-box-container *,
      textarea,
      [contenteditable="true"],
      [role="textbox"] {
        visibility: visible !important;
        opacity: 1 !important;
        pointer-events: auto !important;
      }

      /* ========================================================
         KUNCI BILAH INPUT DI DASAR LAYAR DENGAN JARAK ELEVASI ALAMI (SEPERTI ADA DISCLAIMER)
         ======================================================== */
      /* 1. Host wrapper di mode percakapan */
      app-chat-input {
        position: fixed !important;
        bottom: 0px !important;
        left: 0px !important;
        right: 0px !important;
        width: 100% !important;
        max-width: 100% !important;
        margin: 0px !important;
        padding-left: 16px !important;
        padding-right: 16px !important;
        padding-bottom: 48px !important;
        padding-top: 10px !important;
        box-sizing: border-box !important;
        display: flex !important;
        justify-content: center !important;
        align-items: flex-end !important;
        z-index: 10000 !important;
        background: transparent !important;
        pointer-events: none !important;
      }

      app-chat-input > * {
        pointer-events: auto !important;
        width: 100% !important;
        max-width: 768px !important;
        margin-left: auto !important;
        margin-right: auto !important;
        margin-top: 0 !important;
        margin-bottom: 0 !important;
        box-sizing: border-box !important;
      }

      app-chat-input form,
      app-chat-input .chat-input-container,
      app-chat-input form.chat-input-form,
      app-chat-input .query-box-container {
        margin-top: 0 !important;
        margin-bottom: 0 !important;
        width: 100% !important;
        box-sizing: border-box !important;
      }

      /* 2. Host input di mode EMPTY STATE atau di luar app-chat-input */
      app-chat-empty-state form,
      app-chat-empty-state .chat-input-container,
      app-chat-empty-state .query-box-container,
      .chat-empty-state form,
      .chat-empty-state .chat-input-container,
      .chat-empty-state .query-box-container,
      .empty-state form,
      .empty-state .chat-input-container,
      [class*="empty-state" i] form,
      [class*="empty-state" i] .chat-input-container,
      div.chat-input-container:not(app-chat-input *),
      form.chat-input-form:not(app-chat-input *),
      .query-box-container:not(app-chat-input *) {
        position: fixed !important;
        bottom: 48px !important;
        left: 50% !important;
        transform: translateX(-50%) !important;
        width: min(768px, calc(100% - 32px)) !important;
        max-width: 768px !important;
        margin: 0 !important;
        z-index: 10000 !important;
        box-sizing: border-box !important;
        pointer-events: auto !important;
      }

      /* Ruang bawah obrolan agar pesan tidak tertutup oleh bilah input */
      .chat-panel-content, .chat-view, .conversation-container, .message-list, [role="log"], main, app-chat-view {
        padding-bottom: 140px !important;
        box-sizing: border-box !important;
      }

      .chat-message-pair, .to-user-container, .to-model-container {
        margin-bottom: 18px !important;
      }
      .rendered-markdown, .chat-response {
        font-size: var(--ot-font-size, 15.5px) !important;
        line-height: 1.8 !important;
      }
      .rendered-markdown p + p, .chat-response p + p { margin-top: 1em !important; }
      .chat-panel-content, .chat-view, .conversation-container { scrollbar-width: thin; }
      .rendered-markdown { max-width: 720px; margin-inline: auto; }
      .rendered-markdown p, .rendered-markdown li { unicode-bidi: plaintext; }
      .chat-input-container { border-radius: 28px !important; }

      /* Sembunyikan dialog / pop-up selamat datang dan intro Gemini Notebook */
      app-welcome-dialog, app-onboarding-dialog,
      .welcome-dialog, .onboarding-dialog,
      [class*="welcome-dialog" i], [class*="onboarding-dialog" i],
      [class*="feature-dialog" i], [class*="announcement-dialog" i] {
        display: none !important;
        opacity: 0 !important;
        pointer-events: none !important;
      }
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

    // Preserve response menus, citation actions, and keyboard-accessible controls.
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
      'app-notebook-guide', 'notebook-guide',
      'app-artifact-summary', '.artifact-summary',
      '.notebook-guide', '.guide-container', '.hero-container',
      '.cover-image-container', '.summary-card', '.guide-card',
      'app-notebook-cover', '.notebook-cover', '[class*="notebook-cover" i]',
      'app-project-cover', '.project-cover', '[class*="project-cover" i]',
      '.cover-emoji', '[class*="cover-emoji" i]',
      '.cover-icon', '[class*="cover-icon" i]',
      '.notebook-icon', '[class*="notebook-icon" i]',
      'app-notebook-icon', 'app-cover-icon'
    ];
    guideSelectors.forEach(sel => {
      document.querySelectorAll(sel).forEach(el => {
        el.style.setProperty('visibility', 'hidden', 'important');
        el.style.setProperty('opacity', '0', 'important');
        el.style.setProperty('pointer-events', 'none', 'important');
      });
    });

    // Sembunyikan elemen spesifik icon Ka'bah (🕋) atau cover emoji (HANYA elemen daun / leaf element)
    document.querySelectorAll('span, div, p, [role="img"], mat-icon, .cover-emoji, [class*="cover-emoji" i]').forEach(el => {
      // 1. DILARANG KERAS menyentuh container obrolan, form, atau input
      if (el.querySelector('textarea, [contenteditable="true"], [role="textbox"], app-chat-input, form, input')) return;
      if (el.closest('.chat-message, .model-message, .user-message, [role="article"], .rendered-markdown, app-chat-response, app-chat-input, form, textarea, [contenteditable="true"]')) return;
      if (el.tagName === 'BODY' || el.tagName === 'HTML' || el.tagName === 'MAIN') return;
      if (el.matches('.chat-panel-content, .chat-view, .conversation-container, .message-list, [role="log"], app-chat-view, app-chat-panel, .chat-panel')) return;

      const rawTxt = (el.innerText || el.textContent || '').trim();
      if (!rawTxt) return;

      // 2. Pastikan HANYA elemen daun atau elemen kecil yang secara spesifik merupakan emoji/cover (bukan container teks besar)
      const isExactEmoji = rawTxt === '🕋' || rawTxt === '\uD83D\uDDFB';
      const isSmallEmojiHost = (rawTxt.includes('🕋') || (rawTxt.length <= 4 && /\p{Extended_Pictographic}/u.test(rawTxt))) && el.children.length <= 1;
      const isCoverClass = el.matches('.cover-emoji, [class*="cover-emoji" i], .cover-icon, [class*="cover-icon" i], app-notebook-cover, .notebook-cover, [class*="notebook-cover" i]');

      if (isExactEmoji || isSmallEmojiHost || isCoverClass) {
        el.style.setProperty('display', 'none', 'important');
        el.style.setProperty('visibility', 'hidden', 'important');
        el.style.setProperty('opacity', '0', 'important');
        el.style.setProperty('pointer-events', 'none', 'important');
      }
    });

    // Cari intro "sources", judul notebook ("AI-MUHAQQIQ"), tanggal, dan icon scroll
    // baik saat ada pesan obrolan maupun saat obrolan masih kosong (empty state)
    document.querySelectorAll('.chat-panel-content, .chat-view, .conversation-container, .message-list, [role="log"], main, app-chat-view, app-conversation, app-chat-panel, .chat-panel, app-chat').forEach(panel => {
      // 1. Jika ada pesan pertama, sembunyikan semua elemen sebelumnya (header intro)
      const firstMessage = panel.querySelector('.chat-message, .model-message, .user-message, [role="article"], .chat-message-pair');
      if (firstMessage) {
        let prev = firstMessage.previousElementSibling;
        while (prev) {
          if (!prev.querySelector('textarea, [contenteditable="true"], form')) {
            prev.style.setProperty('display', 'none', 'important');
          }
          prev = prev.previousElementSibling;
        }
      } else {
        // 2. Jika belum ada pesan sama sekali (empty chat):
        // Sembunyikan elemen judul, ikon, dan sumber dengan VISIBILITY: HIDDEN (bukan display: none)
        // agar tinggi layout alami tetap utuh dan kotak input tetap berada di dasar layar!
        panel.querySelectorAll('h1, h2, h3, img, svg, mat-icon, [class*="title" i], [class*="source" i], [class*="date" i]').forEach(el => {
          if (!el.querySelector('textarea, [contenteditable="true"], form') && !el.closest('app-chat-input, form, textarea, [contenteditable="true"]')) {
            el.style.setProperty('visibility', 'hidden', 'important');
            el.style.setProperty('opacity', '0', 'important');
            el.style.setProperty('pointer-events', 'none', 'important');
          }
        });

        panel.querySelectorAll('div, p, span').forEach(el => {
          if (el.querySelector('textarea, [contenteditable="true"], form') || el.closest('app-chat-input, form, textarea, [contenteditable="true"]')) return;
          const txt = (el.innerText || el.textContent || '').trim();
          if (!txt) return;
          const isSourceDate = /^\d+\s*(sumber|source|sources)\s*[·•]/i.test(txt) ||
                               /[·•]\s*\d+\s*(jan|feb|mar|apr|mei|jun|jul|agu|sep|okt|nov|des|january|february|march|april|may|june|july|august|september|october|november|december)/i.test(txt) ||
                               ((txt.includes('sumber') || txt.includes('source')) && (txt.includes('·') || txt.includes('•')));
          const isAssistantTitle = txt === 'AI-MUHAQQIQ' || txt.toUpperCase() === 'AI-MUHAQQIQ';
          const isExactEmoji = txt === '🕋' || (txt.includes('🕋') && txt.length <= 4);
          if (isSourceDate || isAssistantTitle || isExactEmoji) {
            el.style.setProperty('visibility', 'hidden', 'important');
            el.style.setProperty('opacity', '0', 'important');
            el.style.setProperty('pointer-events', 'none', 'important');
          }
        });
      }
    });

    // 3. Sembunyikan di seluruh dokumen elemen yang bertuliskan "Loading Notebook..." atau "Memuat Notebook..."
    document.querySelectorAll('div, p, span, h1, h2, h3, h4, h5, section, app-loading-screen, .loading-container').forEach(el => {
      if (el.querySelector('textarea, [contenteditable="true"], form, .chat-message, [role="article"]')) return;
      if (el.closest('app-chat-input, form, textarea, [contenteditable="true"], .chat-message, [role="article"]')) return;
      const txt = (el.innerText || el.textContent || '').trim().toLowerCase();
      if (!txt) return;
      if (txt === 'loading notebook...' || txt === 'memuat notebook...' || txt === 'loading notebook' || txt === 'memuat notebook' || txt.includes('loading notebook') || txt.includes('memuat notebook')) {
        el.style.setProperty('display', 'none', 'important');
      }
    });
  }

  function dismissPopups() {
    try {
      const dialogs = document.querySelectorAll(
        'mat-dialog-container, .mat-mdc-dialog-container, [role="dialog"], [aria-modal="true"], .cdk-overlay-pane, app-welcome-dialog, app-onboarding-dialog'
      );

      let foundPromoOrWelcome = false;
      dialogs.forEach(dialog => {
        // Jangan ganggu dialog pemilihan bahasa / menu asisten yang sengaja dibuka
        if (dialog.querySelector('[role="menu"], .mat-mdc-menu-panel, mat-radio-group, [role="radiogroup"], mat-radio-button')) {
          return;
        }

        const fullText = (dialog.innerText || dialog.textContent || '').trim().toLowerCase();
        const isWelcomeOrPromo =
          fullText.includes('selamat datang') ||
          fullText.includes('welcome') ||
          fullText.includes('gemini notebook') ||
          fullText.includes('fleksibilitas dan kontrol') ||
          fullText.includes('flexibility and control') ||
          fullText.includes('batas diperbarui') ||
          fullText.includes('limits updated') ||
          fullText.includes('data anda dilindungi') ||
          fullText.includes('your data is protected') ||
          fullText.includes('info terbaru');

        if (isWelcomeOrPromo) {
          foundPromoOrWelcome = true;
          // Otomatis klik tombol konfirmasi / tutup agar status tersimpan di backend Google
          const buttons = dialog.querySelectorAll('button, [role="button"]');
          for (const btn of buttons) {
            const btnText = (btn.innerText || btn.textContent || btn.getAttribute('aria-label') || '').trim().toLowerCase();
            const hasCloseIcon = !!btn.querySelector('mat-icon[data-mat-icon-name="close"], mat-icon[fonticon="close"], svg');
            if (btnText === 'oke' || btnText === 'ok' || btnText === 'mengerti' || btnText === 'got it' || btnText === 'close' || btnText === 'tutup' || btnText.includes('close') || hasCloseIcon) {
              try { btn.click(); break; } catch (_) {}
            }
          }

          dialog.style.setProperty('display', 'none', 'important');
          dialog.style.setProperty('opacity', '0', 'important');
          dialog.style.setProperty('pointer-events', 'none', 'important');
          dialog.style.setProperty('visibility', 'hidden', 'important');

          const pane = dialog.closest('.cdk-overlay-pane');
          if (pane) {
            pane.style.setProperty('display', 'none', 'important');
            pane.style.setProperty('opacity', '0', 'important');
            pane.style.setProperty('pointer-events', 'none', 'important');
          }
        }
      });

      if (foundPromoOrWelcome) {
        document.querySelectorAll('.cdk-overlay-backdrop').forEach(bd => {
          const activeMenu = document.querySelector('[role="menu"]:not([style*="display: none"]), .mat-mdc-menu-panel:not([style*="display: none"])');
          if (!activeMenu) {
            bd.style.setProperty('display', 'none', 'important');
            bd.style.setProperty('opacity', '0', 'important');
            bd.style.setProperty('pointer-events', 'none', 'important');
          }
        });
      }
    } catch (_) {}
  }

  function removeMoreOptionsButtons() {
    // Sembunyikan tombol opsi titik tiga (more_vert / more_horiz / options) di luar pesan jawaban
    document.querySelectorAll('mat-icon, [data-mat-icon-name], svg').forEach(icon => {
      const name = (icon.getAttribute('data-mat-icon-name') || icon.getAttribute('fonticon') || icon.textContent || '').trim().toLowerCase();
      if (name === 'more_vert' || name === 'more_horiz' || name.includes('more_vert') || name.includes('more_horiz')) {
        if (icon.closest('.chat-message, .model-message, .user-message, [role="article"], .rendered-markdown, app-chat-response, app-chat-input, form, div.chat-input-container')) {
          return;
        }
        const btn = icon.closest('button, [role="button"], a, .mat-mdc-icon-button') || icon;
        btn.style.setProperty('display', 'none', 'important');
        btn.style.setProperty('visibility', 'hidden', 'important');
        btn.style.setProperty('opacity', '0', 'important');
        btn.style.setProperty('pointer-events', 'none', 'important');
        btn.style.setProperty('position', 'absolute', 'important');
        btn.style.setProperty('left', '-9999px', 'important');
        btn.style.setProperty('top', '-9999px', 'important');
        btn.style.setProperty('width', '0', 'important');
        btn.style.setProperty('height', '0', 'important');
      }
    });

    document.querySelectorAll('button[aria-label*="options" i], button[aria-label*="opsi" i], button[aria-label*="more" i], button[aria-label*="tindakan" i], button[aria-label*="lainnya" i], [role="button"][aria-label*="options" i], [role="button"][aria-label*="opsi" i]').forEach(btn => {
      if (btn.closest('.chat-message, .model-message, .user-message, [role="article"], .rendered-markdown, app-chat-response, app-chat-input, form, div.chat-input-container')) {
        return;
      }
      const label = (btn.getAttribute('aria-label') || '').toLowerCase();
      if (!label.includes('send') && !label.includes('kirim') && !label.includes('mic') && !label.includes('suara')) {
        btn.style.setProperty('display', 'none', 'important');
        btn.style.setProperty('visibility', 'hidden', 'important');
        btn.style.setProperty('opacity', '0', 'important');
        btn.style.setProperty('pointer-events', 'none', 'important');
        btn.style.setProperty('position', 'absolute', 'important');
        btn.style.setProperty('left', '-9999px', 'important');
        btn.style.setProperty('top', '-9999px', 'important');
        btn.style.setProperty('width', '0', 'important');
        btn.style.setProperty('height', '0', 'important');
      }
    });

    document.querySelectorAll('app-chat-header, .chat-header, [class*="chat-header" i], app-conversation-header, .conversation-header, [class*="conversation-actions" i]').forEach(el => {
      if (!el.querySelector('textarea, [contenteditable="true"], form, .chat-message, [role="article"]')) {
        el.style.setProperty('display', 'none', 'important');
        el.style.setProperty('visibility', 'hidden', 'important');
        el.style.setProperty('opacity', '0', 'important');
      }
    });
  }

  function pinInputToBottom() {
    const textarea = document.querySelector('textarea, [contenteditable="true"], [role="textbox"], input[type="text"]');
    if (!textarea) return;

    // 1. Jika ada host custom app-chat-input (mode obrolan aktif dengan pesan)
    const chatInputCustom = textarea.closest('app-chat-input');
    if (chatInputCustom) {
      chatInputCustom.style.setProperty('position', 'fixed', 'important');
      chatInputCustom.style.setProperty('bottom', '0px', 'important');
      chatInputCustom.style.setProperty('left', '0px', 'important');
      chatInputCustom.style.setProperty('right', '0px', 'important');
      chatInputCustom.style.setProperty('width', '100%', 'important');
      chatInputCustom.style.setProperty('z-index', '10000', 'important');
      chatInputCustom.style.setProperty('display', 'flex', 'important');
      chatInputCustom.style.setProperty('justify-content', 'center', 'important');
      chatInputCustom.style.setProperty('align-items', 'flex-end', 'important');
      chatInputCustom.style.setProperty('background', 'transparent', 'important');
      chatInputCustom.style.setProperty('pointer-events', 'none', 'important');
      chatInputCustom.style.setProperty('padding', '10px 16px 48px 16px', 'important');
      chatInputCustom.style.setProperty('box-sizing', 'border-box', 'important');
      chatInputCustom.style.setProperty('margin', '0px', 'important');

      Array.from(chatInputCustom.children).forEach(child => {
        child.style.setProperty('pointer-events', 'auto', 'important');
        child.style.setProperty('width', '100%', 'important');
        child.style.setProperty('max-width', '768px', 'important');
        child.style.setProperty('margin', '0 auto', 'important');
        child.style.setProperty('box-sizing', 'border-box', 'important');
      });
      return;
    }

    // 2. Mode EMPTY STATE (input berada di form / chat-input-container)
    const form = textarea.closest('form');
    const container = textarea.closest('.chat-input-container, [class*="chat-input" i], [class*="input-container" i], .query-box-container');
    const target = form || container || textarea.parentElement;

    if (target && target !== document.body) {
      // Netralkan transform, contain, dan filter pada ancestor agar position: fixed mengikat viewport
      let p = target.parentElement;
      while (p && p !== document.body) {
        if (p.style) {
          const comp = getComputedStyle(p);
          if (comp.transform && comp.transform !== 'none') {
            p.style.setProperty('transform', 'none', 'important');
          }
          if (comp.contain && comp.contain !== 'none') {
            p.style.setProperty('contain', 'none', 'important');
          }
          if (comp.filter && comp.filter !== 'none') {
            p.style.setProperty('filter', 'none', 'important');
          }
        }
        p = p.parentElement;
      }

      target.style.setProperty('position', 'fixed', 'important');
      target.style.setProperty('bottom', '48px', 'important');
      target.style.setProperty('left', '50%', 'important');
      target.style.setProperty('transform', 'translateX(-50%)', 'important');
      target.style.setProperty('width', 'min(768px, calc(100% - 32px))', 'important');
      target.style.setProperty('max-width', '768px', 'important');
      target.style.setProperty('z-index', '10000', 'important');
      target.style.setProperty('margin', '0px', 'important');
      target.style.setProperty('pointer-events', 'auto', 'important');
      target.style.setProperty('box-sizing', 'border-box', 'important');

      if (target === form && container && container !== form) {
        container.style.setProperty('width', '100%', 'important');
        container.style.setProperty('max-width', '100%', 'important');
        container.style.setProperty('margin', '0 auto', 'important');
        container.style.setProperty('box-sizing', 'border-box', 'important');
      }
    }
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
    removeMoreOptionsButtons();
    removeHeroCard();
    dismissPopups();
    pinInputToBottom();
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
    const spinners = document.querySelectorAll('mat-spinner, mat-progress-spinner, mat-progress-bar, app-loading-screen');
    for (const s of spinners) {
      if (s.offsetWidth > 0 && s.offsetHeight > 0 && getComputedStyle(s).display !== 'none' && getComputedStyle(s).visibility !== 'hidden') {
        return true;
      }
    }
    return false;
  }

  function ready() {
    if (accessDenied()) return false;
    // Other panels may keep a source/upload spinner running after chat is usable.
    return inputReady();
  }
  function inputReady() {
    // The page can contain a hidden or disabled input before the live composer.
    const inputs = [...document.querySelectorAll('textarea, [contenteditable="true"], [role="textbox"]')];
    return inputs.some(input => {
      if (input.disabled || input.getAttribute('aria-disabled') === 'true') return false;
      return visible(input) || (input.offsetWidth > 0 && getComputedStyle(input).display !== 'none');
    });
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

ensureStyles();
clean();
dismissPopups();
removeMoreOptionsButtons();
pinInputToBottom();
var _otPopupCounter = 0;
var _otPopupTimer = setInterval(function() {
  dismissPopups();
  removeMoreOptionsButtons();
  pinInputToBottom();
  _otPopupCounter++;
  if (_otPopupCounter > 40) clearInterval(_otPopupTimer);
}, 250);
})();
''';
