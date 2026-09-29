/// Conversation cleanup and explicit copy capture, restricted to NotebookLM.
const notebookUiScript = r'''
(function () {
  if (window.top !== window || !['notebooklm.google.com', 'notebook.google.com'].includes(location.hostname)) return;
  if (window.otNotebook) {
    window.otOpenLanguageSettings = window.otNotebook.openLanguageSettings;
    window.otDeleteChatHistory = window.otNotebook.deleteChatHistory;
    window.otClearChat = window.otNotebook.clearChat;
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
    if (document.getElementById('ot-conversation-ui')) return;
    const style = document.createElement('style');
    style.id = 'ot-conversation-ui';
    style.textContent = `
      /* Sembunyikan bilah navigasi header NotebookLM dan bilah Google luar */
      body > header,
      top-bar, .top-bar,
      app-header,
      mat-toolbar,
      .notebook-header,
      app-notebook-header,
      app-project-header,
      header[role="banner"],
      [role="banner"],
      app-user-avatar,
      div[class*="gb_"],
      #gb, #gbwa,
      [aria-label*="Google apps" i],
      [aria-label*="Aplikasi Google" i],
      [aria-label*="Google Account" i],
      [aria-label*="Akun Google" i],
      a[href*="myaccount.google.com"],
      button:has(app-user-avatar),
      labs-tailwind-logo, a.logo-link, a[aria-label*="NotebookLM" i], svg[aria-label*="NotebookLM" i] {
        display: none !important;
        visibility: hidden !important;
        height: 0 !important;
        min-height: 0 !important;
        max-height: 0 !important;
        overflow: hidden !important;
        padding: 0 !important;
        margin: 0 !important;
      }

      button[aria-label*="Settings" i], button[aria-label*="Setelan" i],
      button[aria-label*="Pengaturan" i], button[aria-label*="Notebook settings" i] {
        display: none !important;
        visibility: hidden !important;
      }

      /* Sembunyikan kartu hero/guide tengah agar chat bersih */
      app-notebook-guide, notebook-guide, app-guide-intro,
      app-chat-intro, app-project-summary, app-notebook-overview,
      .notebook-guide, .guide-container, .hero-container,
      .cover-image-container, .summary-card, .guide-card,
      [class*="guide-intro" i], [class*="project-summary" i] {
        display: none !important;
        visibility: hidden !important;
      }

      .ot-opening-language [role="menu"],
      .ot-opening-language .mat-mdc-menu-panel { opacity: 0 !important; }
      .cdk-overlay-container { z-index: 99999 !important; }

      /* Elevate chat input and disclaimer */
      .chat-panel-content, .chat-view, .conversation-container, .message-list {
        padding-bottom: max(36px, calc(env(safe-area-inset-bottom, 24px) + 20px)) !important;
      }
      div.chat-input-container, .input-container, app-chat-input, form.chat-input-form,
      [class*="input-container" i], [class*="chat-input" i] {
        margin-bottom: 8px !important;
      }
      /* Sembunyikan Disclaimer Bawah Secara Total */
      .disclaimer, [class*="disclaimer" i], footer, [role="contentinfo"] {
        display: none !important;
        visibility: hidden !important;
        height: 0 !important;
        margin: 0 !important;
        padding: 0 !important;
        overflow: hidden !important;
      }

      .chat-message-pair, .to-user-container, .to-model-container {
        margin-bottom: 18px !important;
      }
      .rendered-markdown, .chat-response {
        font-size: 15.5px !important;
        line-height: 1.8 !important;
      }
      .rendered-markdown p + p, .chat-response p + p { margin-top: 1em !important; }
      ::-webkit-scrollbar { display: none !important; width: 0 !important; }
      html, body, * { scrollbar-width: none !important; }
    `;
    (document.head || document.documentElement).appendChild(style);
  }

  function removeTopToolbars() {
    const selectors = [
      'body > header', 'top-bar', '.top-bar', 'app-header',
      'mat-toolbar', '.notebook-header', 'app-notebook-header', 'app-project-header', 'header[role="banner"]',
      'app-user-avatar', 'div[class*="gb_"]', '#gb', '#gbwa',
      '[aria-label*="Google apps" i]', '[aria-label*="Aplikasi Google" i]',
      '[aria-label*="Google Account" i]', '[aria-label*="Akun Google" i]',
      'a[href*="myaccount.google.com"]',
      'labs-tailwind-logo', 'a.logo-link', 'a[aria-label*="NotebookLM" i]', 'svg[aria-label*="NotebookLM" i]',
      'button[aria-label*="Settings" i]', 'button[aria-label*="Setelan" i]',
      'button[aria-label*="Pengaturan" i]', 'button[aria-label*="Notebook settings" i]'
    ];
    selectors.forEach(sel => {
      document.querySelectorAll(sel).forEach(el => {
        el.style.setProperty('display', 'none', 'important');
      });
    });
    // Hapus badge PRO jika ada
    document.querySelectorAll('button, a, span, div').forEach(el => {
      if (el.children.length === 0 && (el.textContent || '').trim() === 'PRO') {
        const p = el.closest('button, a, div[role="button"], span');
        if (p) p.style.setProperty('display', 'none', 'important');
      }
    });
  }

  function removeHeroCard() {
    const guideSelectors = [
      'app-notebook-guide', 'notebook-guide', 'app-guide-intro',
      'app-chat-intro', 'app-project-summary', 'app-notebook-overview',
      '.notebook-guide', '.guide-container', '.hero-container',
      '.cover-image-container', '.summary-card', '.guide-card',
      '[class*="guide-intro" i]', '[class*="project-summary" i]'
    ];
    guideSelectors.forEach(sel => {
      document.querySelectorAll(sel).forEach(el => {
        el.style.setProperty('display', 'none', 'important');
      });
    });
  }

  function clean() {
    if (!document.documentElement) return;
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

const observer = new MutationObserver(() => {
  if (scheduled) return;
  scheduled = true;
  requestAnimationFrame(() => {
    scheduled = false;
    clean();
    checkGenerationState();
  });
});
observer.observe(document, {subtree:true, childList:true, characterData:true});
ensureStyles();
clean();
})();
''';
