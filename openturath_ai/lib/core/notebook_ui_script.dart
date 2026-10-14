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
  const answerSelector = '.chat-message[data-sender="model"], .model-message, .response-message, .to-user-container, .to-user-message, .chat-message-pair .answer, [data-message-author-role="assistant"], app-chat-response, app-chat-message, .chat-response, [role="article"], app-chat-turn, chat-turn, [class*="model-turn" i], [class*="model-response" i]';
  const questionSelector = '.chat-message[data-sender="user"], .user-message, .from-user, .to-model-container, [data-message-author-role="user"], app-chat-query, app-chat-prompt, [class*="user-turn" i], [class*="user-query" i], [class*="user-prompt" i]';
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
      /* Sembunyikan badge PRO */
      .pro-badge, [class*="pro-badge" i], [class*="tier-badge" i],
      /* Sembunyikan SEMUA elemen dan container loading internal NotebookLM */
      app-loading-screen, .loading-screen, .loading-container,
      [class*="loading-screen" i], [class*="notebook-loading" i], [class*="project-loading" i],
      .cdk-overlay-backdrop:has(mat-spinner), .cdk-overlay-pane:has(mat-spinner),
      mat-spinner, mat-progress-spinner, mat-progress-bar, [role="progressbar"],
      /* Sembunyikan chip saran prompt agar area obrolan bersih */
      button[class*="suggestion" i], [class*="chip" i], [class*="prompt-chip" i], mat-chip, mat-chip-set,
      app-suggested-actions, .suggested-actions, [class*="suggested-actions" i],
      app-suggestion-chips, .suggestion-chips, [class*="prompt-chips" i], [class*="prompt-card" i],
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
      app-chat-header button,
      .chat-header button,
      [class*="chat-header" i] button,
      app-notebook-header button,
      .notebook-header button,
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
        display: none !important;
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
      mat-sidenav-container.ot-chat-path,
      mat-sidenav-container {
        display: block !important;
        position: relative !important;
        height: 100% !important;
        min-height: 100% !important;
        overflow: hidden !important;
      }
      mat-sidenav {
        position: absolute !important;
        top: 0 !important;
        bottom: 0 !important;
        z-index: 3 !important;
      }
      mat-sidenav-content.ot-chat-path,
      mat-sidenav-content {
        position: relative !important;
        display: flex !important;
        flex-direction: column !important;
        height: 100% !important;
        min-height: 100% !important;
        overflow: auto !important;
        box-sizing: border-box !important;
      }


      /* Grow the viewport and transcript; keep input-only branches at natural height. */
      html, body { height: 100% !important; margin: 0 !important; }
      body.ot-chat-layout { height: var(--ot-chat-height, 100dvh) !important; }
      .ot-chat-path {
        display: flex !important;
        flex-direction: column !important;
        flex: 1 1 auto !important;
        min-height: 100% !important;
        min-width: 0 !important;
        height: 100% !important;
        align-items: stretch !important;
        justify-content: flex-start !important;
        box-sizing: border-box !important;
        padding-top: 0 !important;
        margin-top: 0 !important;
      }
      .ot-chat-composer-path {
        flex: 0 0 auto !important;
        height: auto !important;
        min-height: 0 !important;
        max-height: none !important;
        padding: 0 !important;
        margin: 0 !important;
      }
      .ot-chat-transcript-path {
        display: flex !important;
        flex-direction: column !important;
        flex: 1 1 auto !important;
        min-height: 100% !important;
        height: 100% !important;
        max-height: none !important;
      }
      .ot-chat-transcript {
        display: flex !important;
        flex-direction: column !important;
        height: 100% !important;
        min-height: 100% !important;
        max-height: none !important;
        flex: 1 1 auto !important;
        overflow-y: auto !important;
        -webkit-overflow-scrolling: touch !important;
        box-sizing: border-box !important;
        padding-bottom: 150px !important;
      }
      .chat-panel-content, .chat-view, .conversation-container, .message-list, [role="log"] {
        position: relative !important;
        display: flex !important;
        flex-direction: column !important;
        height: 100% !important;
        min-height: 100% !important;
        flex: 1 1 auto !important;
        overflow-y: auto !important;
        -webkit-overflow-scrolling: touch !important;
        box-sizing: border-box !important;
        padding-bottom: 150px !important;
      }
      main, [role="main"], app-chat-view, app-conversation, app-chat-panel, .chat-panel, app-chat {
        position: relative !important;
        display: flex !important;
        flex-direction: column !important;
        flex: 1 1 auto !important;
        height: 100% !important;
        min-height: 0 !important;
        box-sizing: border-box !important;
      }
      .chat-message, .model-message, .user-message, .chat-message-pair,
      app-chat-response, app-chat-message, app-chat-query, app-chat-prompt,
      .to-user-container, .to-model-container, [role="article"], .rendered-markdown,
      app-chat-turn, chat-turn, [data-message-author-role] {
        display: block !important;
        visibility: visible !important;
        opacity: 1 !important;
      }
      .dark-theme .rendered-markdown, .dark .rendered-markdown,
      .dark-theme .chat-response, .dark .chat-response,
      .dark-theme .chat-message, .dark .chat-message,
      .dark-theme .model-message, .dark .model-message,
      .dark-theme .user-message, .dark .user-message,
      .dark-theme [role="article"], .dark [role="article"],
      [data-theme="dark"] .rendered-markdown, [data-theme="dark"] .chat-response,
      [data-theme="dark"] .chat-message, [data-theme="dark"] [role="article"] {
        color: #E4E4E7 !important;
      }
      .chat-message-pair:last-child,
      .model-message:last-child,
      .user-message:last-child,
      app-chat-response:last-child,
      app-chat-message:last-child,
      app-chat-turn:last-child,
      chat-turn:last-child,
      .chat-message:last-child,
      [role="article"]:last-child {
        margin-bottom: 150px !important;
        padding-bottom: 24px !important;
      }
      .ot-chat-composer {
        position: fixed !important;
        bottom: max(22px, env(safe-area-inset-bottom, 0px)) !important;
        left: 50% !important;
        transform: translateX(-50%) !important;
        width: calc(100% - 32px) !important;
        max-width: 768px !important;
        box-sizing: border-box !important;
        margin: 0 !important;
        z-index: 1000 !important;
        pointer-events: auto !important;
      }
      .ot-chat-composer textarea::placeholder,
      .ot-chat-composer input::placeholder { color: transparent !important; }

      /* Sembunyikan elemen judul, ikon, cover, kartu guide, dan tab-bar agar tampilan bersih murni obrolan */
      .empty-state-header,
      .chat-empty-state-container .empty-state-header,
      app-notebook-guide,
      notebook-guide,
      .notebook-guide,
      [class*="notebook-guide" i],
      app-guide-card,
      .guide-card,
      [class*="guide-card" i],
      app-artifact-summary,
      .artifact-summary,
      [class*="artifact-summary" i],
      app-project-summary,
      .project-summary,
      [class*="project-summary" i],
      app-notebook-overview,
      .notebook-overview,
      [class*="notebook-overview" i],
      app-guide-intro,
      .guide-intro,
      [class*="guide-intro" i],
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
      app-cover-card,
      .cover-card,
      [class*="cover-card" i],
      .cover-image-container,
      [class*="cover-image" i],
      [class*="cover-container" i],
      .summary-card,
      [class*="summary-card" i],
      [class*="hero-card" i],
      [class*="hero-container" i],
      [class*="title-card" i],
      [class*="overview-card" i],
      /* Sembunyikan bilah tab Sources | Chat | Studio dan tombol add/upload non-obrolan */
      [role="tablist"],
      mat-button-toggle-group, .mat-button-toggle-group, .mat-mdc-button-toggle-group,
      .tab-bar, app-tab-bar, .tabs-container, nav[class*="tab" i], div[class*="tab-bar" i],
      mat-tab-header, .mat-mdc-tab-header, .mobile-tab-bar, .mobile-tabs, .mobile-navigation,
      button:has(mat-icon[fonticon="add"]),
      button:has(mat-icon[data-mat-icon-name="add"]),
      button:has(svg path[d*="M19 13"]),
      button:has(svg path[d*="M12 4v16m8-8H4"]),
      button[aria-label*="Add source" i], button[aria-label*="Tambah sumber" i],
      button[aria-label*="Add" i], button[aria-label*="Tambah" i],
      button[aria-label*="Insert" i], button[aria-label*="Sisipkan" i],
      button[aria-label*="Upload" i], button[aria-label*="Unggah" i],
      button[aria-label*="Share" i], button[aria-label*="Bagikan" i],
      .add-source-button, [class*="add-source" i],
      .sources-panel-header, .sources-header, [class*="sources-header" i],
      [class*="sources-panel" i] button, [class*="source-list" i] button,
      mat-sidenav button:has(mat-icon), .sources-container button,
      app-chat-empty-state h1, app-chat-empty-state h2, app-chat-empty-state h3,
      app-chat-empty-state mat-icon, app-chat-empty-state img, app-chat-empty-state svg,
      app-empty-state h1, app-empty-state h2, app-empty-state h3,
      app-empty-state mat-icon, app-empty-state img, app-empty-state svg,
      .chat-empty-state h1, .chat-empty-state h2, .chat-empty-state h3,
      .chat-empty-state mat-icon, .chat-empty-state img, .chat-empty-state svg,
      .empty-state h1, .empty-state h2, .empty-state h3,
      .empty-state mat-icon, .empty-state img, .empty-state svg {
        display: none !important;
        visibility: hidden !important;
        height: 0 !important;
        min-height: 0 !important;
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
      textarea *,
      [contenteditable="true"],
      [contenteditable="true"] *,
      [role="textbox"],
      [role="textbox"] * {
        visibility: visible !important;
        opacity: 1 !important;
        pointer-events: auto !important;
      }

      /* Sembunyikan tombol penghitung sumber / pemilih sumber di dalam maupun di luar bilah obrolan */
      app-chat-input button:not([type="submit"]):not([aria-label*="send" i]):not([aria-label*="kirim" i]):has(mat-icon[fonticon*="source"], mat-icon[data-mat-icon-name*="source"], mat-icon[fonticon*="filter"], mat-icon[data-mat-icon-name*="filter"]),
      app-chat-input button[aria-label*="source" i],
      app-chat-input button[aria-label*="sumber" i],
      app-chat-input button[aria-label*="filter" i],
      app-chat-input .sources-button,
      app-chat-input [class*="source-button" i],
      app-chat-input [class*="sources-button" i],
      app-chat-input [class*="source-pill" i],
      app-chat-input [class*="source-count" i],
      app-chat-input [class*="sources-count" i],
      app-chat-input [class*="sources-chip" i],
      app-chat-input [class*="source-chip" i],
      app-chat-input [class*="sources-badge" i],
      app-chat-input [class*="source-badge" i],
      app-chat-input mat-chip,
      app-chat-input mat-chip-set,
      .chat-input-container button[aria-label*="source" i],
      .chat-input-container button[aria-label*="sumber" i],
      .chat-input-container [class*="source-count" i],
      .chat-input-container [class*="source-pill" i] {
        display: none !important;
        visibility: hidden !important;
        opacity: 0 !important;
        pointer-events: none !important;
        width: 0 !important;
        height: 0 !important;
        min-width: 0 !important;
        min-height: 0 !important;
        padding: 0 !important;
        margin: 0 !important;
        border: none !important;
        overflow: hidden !important;
        position: absolute !important;
        left: -9999px !important;
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
      'button[aria-label*="Share" i]', 'button[aria-label*="Bagikan" i]',
      'mat-button-toggle-group',
      '.pro-badge', '[class*="pro-badge" i]', '[class*="tier-badge" i]'
    ];
    selectors.forEach(sel => {
      document.querySelectorAll(sel).forEach(el => {
        el.style.setProperty('display', 'none', 'important');
      });
    });

    // Preserve response menus, citation actions, and keyboard-accessible controls.
    // Sembunyikan tombol opsi titik tiga (more_vert / more_horiz / options) dan tombol Add (+) di luar balon pesan obrolan
    document.querySelectorAll('mat-icon, [data-mat-icon-name], svg').forEach(icon => {
      const name = (icon.getAttribute('data-mat-icon-name') || icon.getAttribute('fonticon') || icon.textContent || '').trim().toLowerCase();
      if (name === 'more_vert' || name === 'more_horiz' || name === 'add' || name === 'plus' || name === 'note_add' || name === 'post_add') {
        if (icon.closest('.chat-message, .model-message, .user-message, [role="article"], .rendered-markdown, app-chat-response')) {
          return;
        }
        const btn = icon.closest('button, [role="button"]') || icon;
        btn.style.setProperty('display', 'none', 'important');
        btn.style.setProperty('visibility', 'hidden', 'important');
        btn.style.setProperty('opacity', '0', 'important');
        btn.style.setProperty('pointer-events', 'none', 'important');
      }
    });

    // Sembunyikan tombol apapun yang berdiri sendiri di luar form yang hanya berisi teks "+"
    document.querySelectorAll('button, [role="button"]').forEach(btn => {
      if (btn.closest('textarea, [contenteditable="true"]')) return;
      if (btn.closest('.chat-message, .model-message, .user-message, app-chat-response')) return;
      const txt = (btn.textContent || '').trim();
      if (txt === '+' || txt === '＋') {
        btn.style.setProperty('display', 'none', 'important');
        btn.style.setProperty('visibility', 'hidden', 'important');
        btn.style.setProperty('opacity', '0', 'important');
        btn.style.setProperty('pointer-events', 'none', 'important');
      }
    });

    // Sembunyikan tombol/elemen penghitung jumlah sumber di dalam bilah obrolan (mis. "(240)", "240 sources", dsb)
    document.querySelectorAll('app-chat-input button, .chat-input-container button, form button').forEach(btn => {
      if (btn.getAttribute('type') === 'submit' || btn.matches('[aria-label*="send" i], [aria-label*="kirim" i], [class*="send" i]')) {
        return;
      }
      if (btn.querySelector('mat-icon[fonticon*="send"], mat-icon[data-mat-icon-name*="send"], svg path[d*="M2.01 21L23 12 2.01 3"]')) {
        return;
      }
      const txt = (btn.textContent || '').trim();
      const aria = (btn.getAttribute('aria-label') || '').toLowerCase();
      const isSourceCounter = /^\(?\d+\)?$/.test(txt) ||
                              /\(\d+\)/.test(txt) ||
                              /\d+\s*(sumber|source|sources|مصدر|مصادر)/i.test(txt) ||
                              aria.includes('source') || aria.includes('sumber') || aria.includes('filter');
      if (isSourceCounter) {
        btn.style.setProperty('display', 'none', 'important');
        btn.style.setProperty('visibility', 'hidden', 'important');
        btn.style.setProperty('opacity', '0', 'important');
        btn.style.setProperty('pointer-events', 'none', 'important');
        btn.style.setProperty('width', '0px', 'important');
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
    document.querySelectorAll('header, [role="banner"], app-top-bar, .top-bar, app-header, mat-toolbar').forEach(el => {
      if (el.children.length > 0 && el.children.length <= 10) {
        const txt = (el.innerText || el.textContent || '').trim().toLowerCase();
        const hasShared = txt.includes('shared') || txt.includes('dibagikan');
        const hasAvatar = el.querySelector('app-user-avatar, [aria-label*="Google Account" i]');
        const hasModeTabs = (txt.includes('sources') || txt.includes('sumber')) && (txt.includes('studio') || txt.includes('chat'));
        if ((hasShared || hasAvatar || hasModeTabs) && !el.querySelector('textarea, [contenteditable="true"], form')) {
          if (!el.matches('.chat-view, .chat-panel-content, main, [role="main"], app-root')) {
            el.style.setProperty('display', 'none', 'important');
          }
        }
      }
    });
  }

  function removeHeroCard() {
    const isComposerOrInput = el => !el || !!el.closest('app-chat-input, form, .chat-input-container, .query-box-container, textarea, [contenteditable="true"]');
    const isMessageOrBubble = el => !el || !!el.closest('.chat-message, .model-message, .user-message, [role="article"], .rendered-markdown, app-chat-response, app-chat-query, app-chat-prompt, app-chat-turn, chat-turn, [data-message-author-role]');

    // 1. Sembunyikan elemen guide / overview / cover melalui selektor spesifik
    const guideSelectors = [
      'app-notebook-guide', 'notebook-guide', '.notebook-guide', '[class*="notebook-guide" i]',
      'app-guide-card', '.guide-card', '[class*="guide-card" i]',
      'app-artifact-summary', '.artifact-summary', '[class*="artifact-summary" i]',
      'app-project-summary', '.project-summary', '[class*="project-summary" i]',
      'app-notebook-overview', '.notebook-overview', '[class*="notebook-overview" i]',
      'app-guide-intro', '.guide-intro', '[class*="guide-intro" i]',
      'app-notebook-intro', '.notebook-intro', '[class*="notebook-intro" i]',
      'app-project-intro', '.project-intro', '[class*="project-intro" i]',
      'app-notebook-title', 'app-project-title',
      'app-notebook-cover', '.notebook-cover', '[class*="notebook-cover" i]',
      'app-project-cover', '.project-cover', '[class*="project-cover" i]',
      'app-cover-card', '.cover-card', '[class*="cover-card" i]',
      '.cover-image-container', '[class*="cover-image" i]', '[class*="cover-container" i]',
      '.summary-card', '[class*="summary-card" i]',
      '[class*="hero-card" i]', '[class*="hero-container" i]', '[class*="hero-header" i]',
      '[class*="title-card" i]', '[class*="overview-card" i]',
      '.empty-state-header'
    ];
    guideSelectors.forEach(sel => {
      document.querySelectorAll(sel).forEach(el => {
        if (!isComposerOrInput(el) && !isMessageOrBubble(el)) {
          el.style.setProperty('display', 'none', 'important');
          el.style.setProperty('height', '0px', 'important');
          el.style.setProperty('overflow', 'hidden', 'important');
        }
      });
    });

    // 2. Deteksi kartu sampul berbasis teks spesifik "0 sumber · [tanggal]" / "X sources · [date]"
    document.querySelectorAll('span, p, div, small').forEach(el => {
      if (isComposerOrInput(el) || isMessageOrBubble(el)) return;
      if (el.children.length > 2) return;
      const txt = (el.innerText || el.textContent || '').trim();
      if (!txt || txt.length > 60) return;

      const isSourceCount = /^\d+\s*(sumber|source|sources)\s*[·•]/i.test(txt) ||
                            ((txt.includes('sumber') || txt.includes('source')) && (txt.includes('·') || txt.includes('•')) && /\b202\d\b/.test(txt));
      if (!isSourceCount) return;

      // Temukan kartu pembungkusnya (maksimal 3 tingkat ke atas, JANGAN PERNAH menyembunyikan main/chat-view!)
      let target = el;
      for (let i = 0; i < 3 && target.parentElement; i++) {
        const parent = target.parentElement;
        if (parent === document.body || parent.matches('main, [role="main"], app-chat-view, app-chat-panel, app-chat, .chat-panel-content, .chat-view, .conversation-container, .message-list, [role="log"]')) {
          break;
        }
        if (parent.querySelector('textarea, [contenteditable="true"], form')) {
          break;
        }
        if (parent.querySelector('.user-turn, .model-turn, .chat-message, app-chat-response, [role="article"]')) {
          break;
        }
        target = parent;
        if (target.matches('mat-card, [class*="card" i], [class*="guide" i], [class*="hero" i], [class*="cover" i], [class*="summary" i]')) {
          break;
        }
      }
      target.style.setProperty('display', 'none', 'important');
      target.style.setProperty('height', '0px', 'important');
      target.style.setProperty('min-height', '0px', 'important');
      target.style.setProperty('max-height', '0px', 'important');
      target.style.setProperty('margin', '0px', 'important');
      target.style.setProperty('padding', '0px', 'important');
      target.style.setProperty('overflow', 'hidden', 'important');
    });

    // 3. Pastikan tab Chat selalu aktif jika antarmuka mobile/tab NotebookLM terbuka
    try {
      const tabs = document.querySelectorAll('[role="tab"], button, a, [role="button"]');
      for (const tab of tabs) {
        if (isComposerOrInput(tab) || isMessageOrBubble(tab)) continue;
        const txt = (tab.innerText || tab.textContent || '').trim().toLowerCase();
        if (txt === 'chat' || txt === 'obrolan' || txt === 'percakapan') {
          const isSelected = tab.getAttribute('aria-selected') === 'true' ||
                             tab.classList.contains('active') ||
                             tab.classList.contains('selected') ||
                             tab.classList.contains('mat-mdc-tab-active');
          if (!isSelected) {
            tab.click?.();
          }
          break;
        }
      }
    } catch (_) {}

    // 4. Panel pesan obrolan: bersihkan elemen header/cover di atas pesan pertama
    const messageSel = questionSelector + ',' + answerSelector + ', .chat-message-pair, app-chat-turn, chat-turn, app-chat-message, app-chat-response, [data-message-author-role]';
    document.querySelectorAll('.chat-panel-content, .chat-view, .conversation-container, .message-list, [role="log"]').forEach(panel => {
      const messages = [...panel.querySelectorAll(messageSel)].filter(el => !isComposerOrInput(el));
      const firstMessage = messages[0];
      if (firstMessage) {
        let prev = firstMessage.previousElementSibling;
        while (prev) {
          if (!isComposerOrInput(prev)) {
            const prevTxt = (prev.innerText || prev.textContent || '').trim();
            const isSourceHeader = /^\d+\s*(sumber|source|sources)\s*[·•]/i.test(prevTxt) ||
                                   (prev.querySelector('img, svg, mat-icon') && !prev.matches('.user-turn, .model-turn'));
            if (prev.matches('.empty-state-header, app-notebook-guide, notebook-guide, .notebook-guide, app-guide-card, .guide-card, app-notebook-title, app-project-title, app-notebook-cover, .notebook-cover, .cover-emoji, .cover-image-container, app-artifact-summary, .artifact-summary, .summary-card, [class*="hero-header" i], [class*="intro-header" i], app-suggestion-chips, .suggestion-chips') ||
                prev.querySelector('.empty-state-header, app-notebook-cover, .cover-image-container, app-artifact-summary, .artifact-summary, .summary-card') ||
                isSourceHeader) {
              prev.style.setProperty('display', 'none', 'important');
              prev.style.setProperty('height', '0px', 'important');
              prev.style.setProperty('overflow', 'hidden', 'important');
            }
          }
          prev = prev.previousElementSibling;
        }
      } else {
        panel.querySelectorAll('.empty-state-header, app-notebook-guide, notebook-guide, .notebook-guide, app-guide-card, .guide-card, app-notebook-title, app-notebook-cover, .notebook-cover, .cover-emoji, [class*="hero-header" i], [class*="intro-header" i], app-chat-empty-state mat-icon, app-chat-empty-state img, app-chat-empty-state svg, app-empty-state mat-icon, app-empty-state img, app-empty-state svg').forEach(el => {
          if (!isComposerOrInput(el) && !isMessageOrBubble(el)) {
            el.style.setProperty('display', 'none', 'important');
            el.style.setProperty('height', '0px', 'important');
            el.style.setProperty('overflow', 'hidden', 'important');
          }
        });
      }
    });

    // Sembunyikan emoji cover / Ka'bah (🕋) jika berdiri sendiri di luar obrolan
    document.querySelectorAll('span, div, p, [role="img"]').forEach(el => {
      if (isComposerOrInput(el) || el.closest('.chat-message, .model-message, .user-message, [role="article"], .rendered-markdown, app-chat-response')) return;
      if (el.children.length === 0) {
        const t = (el.innerText || el.textContent || '').trim();
        if (t === '🕋' || (t.includes('🕋') && t.length <= 4)) {
          el.style.setProperty('display', 'none', 'important');
        }
      }
    });

    // Sembunyikan pesan loading hanya pada leaf node
    document.querySelectorAll('app-loading-screen, .loading-container, div, p, span, h1, h2, h3, h4, h5').forEach(el => {
      if (isComposerOrInput(el) || el.querySelector('.chat-message, [role="article"]')) return;
      if (el.matches('app-loading-screen, .loading-container')) {
        el.style.setProperty('display', 'none', 'important');
        return;
      }
      if (el.children.length === 0) {
        const txt = (el.innerText || el.textContent || '').trim().toLowerCase();
        if (txt && txt.length < 35 && (txt === 'loading notebook...' || txt === 'memuat notebook...' || txt === 'loading notebook' || txt === 'memuat notebook' || txt.includes('loading notebook') || txt.includes('memuat notebook'))) {
          el.style.setProperty('display', 'none', 'important');
        }
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
          fullText.includes('persyaratan layanan') ||
          fullText.includes('terms of service') ||
          fullText.includes('info terbaru');

        if (isWelcomeOrPromo) {
          foundPromoOrWelcome = true;
          // Otomatis klik tombol konfirmasi / tutup agar status tersimpan di backend Google
          const buttons = dialog.querySelectorAll('button, [role="button"]');
          for (const btn of buttons) {
            const btnText = (btn.innerText || btn.textContent || btn.getAttribute('aria-label') || '').trim().toLowerCase();
            const hasCloseIcon = !!btn.querySelector('mat-icon[data-mat-icon-name="close"], mat-icon[fonticon="close"], svg');
            if (btnText === 'oke' || btnText === 'ok' || btnText === 'mengerti' || btnText === 'got it' ||
                btnText === 'close' || btnText === 'tutup' || btnText.includes('close') || hasCloseIcon ||
                btnText === 'lanjutkan' || btnText === 'continue' || btnText === 'setuju' || btnText === 'agree' ||
                btnText === 'mulai' || btnText === 'get started' || btnText === 'accept' || btnText === 'terima') {
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

  function anchorConversationInput() {
    // A disabled input still owns the layout while NotebookLM generates a response.
    const inputs = [...document.querySelectorAll('textarea, [contenteditable="true"], [role="textbox"]')];
    const enabledInputs = inputs.filter(visible);
    const input = enabledInputs.find(el => el.closest('app-chat-input, .chat-input-container, form.chat-input-form, .chat-input-area, .query-box-container, app-chat, app-chat-view, app-chat-panel, .chat-panel, .chat-view, .chat-panel-content')) || enabledInputs[0] || inputs[0];
    const oldNodes = [...document.querySelectorAll('.ot-chat-path, .ot-chat-transcript, .ot-chat-composer, .ot-chat-composer-path, .ot-chat-transcript-path')];
    const path = new Set();
    const transcripts = new Set();
    const composerPaths = new Set();
    const transcriptPaths = new Set();
    let composer = null;
    if (input) {
      const panelSelector = 'app-chat, app-chat-view, app-chat-panel, .chat-panel, .chat-view, .chat-panel-content, .conversation-container, main, [role="main"]';
      const composerSelector = 'app-chat-input, .chat-input-container, .input-container, form.chat-input-form, .chat-input-area, .query-box-container';
      composer = input.closest(composerSelector);
      // Fallback for changed upstream class names: retain the entire send control.
      if (!composer) {
        let node = input.parentElement;
        while (node && node !== document.body && !node.matches(panelSelector)) {
          if (node.querySelector('button, [role="button"]')) { composer = node; break; }
          node = node.parentElement;
        }
      }
      if (composer) {
        // Nested input wrappers belong to the composer, not to the flex path.
        while (composer.parentElement && composer.parentElement.matches(composerSelector)) {
          composer = composer.parentElement;
        }
        const ancestors = [];
        let node = composer.parentElement;
        let conversationRoot = null;
        while (node && node !== document.documentElement) {
          ancestors.push(node);
          // The first shared parent owns the transcript and input as separate rows.
          // Input-only wrappers below it must never receive flex: 1.
          const siblings = [...node.children].filter(child => child !== composer && !child.contains(composer));
          const messageBranches = siblings.filter(child =>
            child.matches('.message-list, [role="log"], .chat-panel-content, .chat-view, .conversation-container') ||
            child.querySelector(answerSelector + ',' + questionSelector));
          if (!conversationRoot && messageBranches.length) {
            conversationRoot = node;
            messageBranches.forEach(branch => {
              const scrollers = [branch, ...branch.querySelectorAll('*')].filter(el => {
                if (!el.querySelector(answerSelector + ',' + questionSelector)) return false;
                return el.matches('.message-list, [role="log"]') || /auto|scroll/.test(getComputedStyle(el).overflowY);
              });
              const scroller = scrollers[scrollers.length - 1] || branch;
              transcripts.add(scroller);
              let wrapper = scroller.parentElement;
              while (wrapper && wrapper !== node) {
                transcriptPaths.add(wrapper);
                wrapper = wrapper.parentElement;
              }
            });
          }
          node = node.parentElement;
        }
        if (transcripts.size === 0) {
          const panels = document.querySelectorAll('.chat-panel-content, .chat-view, .conversation-container, .message-list, [role="log"], app-chat-view');
          for (const p of panels) {
            if (!p.contains(composer)) {
              transcripts.add(p);
              break;
            } else {
              const sibling = [...p.children].find(c => c !== composer && !c.contains(composer));
              if (sibling) {
                transcripts.add(sibling);
                break;
              }
            }
          }
        }
        let belowRoot = !!conversationRoot;
        ancestors.forEach(ancestor => {
          if (ancestor === conversationRoot) belowRoot = false;
          path.add(ancestor);
          if (belowRoot) composerPaths.add(ancestor);
        });
        // Keep the original accessible name when removing a placeholder-only label.
        const placeholder = input.getAttribute('placeholder');
        if (placeholder) {
          if (!input.hasAttribute('aria-label') && !input.hasAttribute('aria-labelledby')) {
            input.setAttribute('aria-label', placeholder);
          }
          input.removeAttribute('placeholder');
        }
        composer.querySelectorAll('mat-label, .mat-mdc-floating-label, [data-placeholder]').forEach(label => {
          if (/^ajukan pertanyaan atau buat konten[.\s]*$/i.test(text(label))) label.style.setProperty('display', 'none', 'important');
        });
      }
    }
    // Reconcile every pass, including empty -> messages -> cleared / replaced DOM.
    oldNodes.forEach(node => {
      if (!path.has(node)) node.classList.remove('ot-chat-path');
      if (!transcripts.has(node)) node.classList.remove('ot-chat-transcript');
      if (node !== composer) node.classList.remove('ot-chat-composer');
      if (!composerPaths.has(node)) node.classList.remove('ot-chat-composer-path');
      if (!transcriptPaths.has(node)) node.classList.remove('ot-chat-transcript-path');
    });
    path.forEach(node => node.classList.add('ot-chat-path'));
    transcripts.forEach(node => node.classList.add('ot-chat-transcript'));
    composerPaths.forEach(node => node.classList.add('ot-chat-composer-path'));
    transcriptPaths.forEach(node => node.classList.add('ot-chat-transcript-path'));
    if (composer) composer.classList.add('ot-chat-composer');
    document.body?.classList.toggle('ot-chat-layout', !!composer);
    const height = window.visualViewport ? window.visualViewport.height : window.innerHeight;
    const value = height + 'px';
    if (document.documentElement.style.getPropertyValue('--ot-chat-height') !== value) {
      document.documentElement.style.setProperty('--ot-chat-height', value);
    }
  }

  let layoutFrame = 0;
  function scheduleConversationLayout() {
    if (layoutFrame) return;
    layoutFrame = requestAnimationFrame(() => {
      layoutFrame = 0;
      anchorConversationInput();
    });
  }
  window.addEventListener('resize', scheduleConversationLayout);
  window.visualViewport?.addEventListener('resize', scheduleConversationLayout);
  const composerObserver = new MutationObserver(scheduleConversationLayout);
  composerObserver.observe(document.documentElement, {
    subtree: true, childList: true, attributes: true, attributeFilter: ['placeholder', 'disabled', 'aria-disabled']
  });

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
    anchorConversationInput();
    dismissPopups();
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
  const candidates = document.querySelectorAll('.ot-chat-transcript, .chat-panel-content, .chat-view, .conversation-container, .message-list, [role="log"], mat-sidenav-content, main');
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
  if (event.target.closest?.('button[type="submit"], button[aria-label*="send" i], button[aria-label*="kirim" i], .send-button, form button')) {
    userPausedFollow = false;
    setTimeout(followLatestAnswer, 50);
    setTimeout(followLatestAnswer, 250);
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

let _otBackgroundPaused = false;
window.otSetBackgroundPaused = function(paused) {
  _otBackgroundPaused = !!paused;
};

// Gunakan debounce 300ms dan childList saja (tanpa characterData) untuk menghemat baterai & CPU
const observer = new MutationObserver(() => {
  if (_otBackgroundPaused || scheduled) return;
  scheduled = true;
  setTimeout(() => {
    scheduled = false;
    if (_otBackgroundPaused) return;
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
var _otPopupCounter = 0;
var _otPopupTimer = setInterval(function() {
  dismissPopups();
  _otPopupCounter++;
  if (_otPopupCounter > 40) clearInterval(_otPopupTimer);
}, 250);
})();
''';
