/// Conversation cleanup and explicit copy capture, restricted to NotebookLM.
const notebookUiScript = r'''
(function () {
  if (window.top !== window || !['notebooklm.google.com', 'notebook.google.com'].includes(location.hostname)) return;
  if (window.otNotebook) {
    window.otOpenLanguageSettings = window.otNotebook.openLanguageSettings;
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

  let presentationEnabled = false;
  function clean() {
    if (!presentationEnabled || !document.documentElement) return;
    syncTheme();
    if (document.getElementById('ot-conversation-ui')) return;
    const style = document.createElement('style');
    style.id = 'ot-conversation-ui';
    style.textContent = `
      top-bar, .top-bar, body > header, .app-header, app-header,
      mat-toolbar, [role="banner"], .notebook-header,
      app-notebook-header, app-project-header {
        max-height: 0 !important;
        min-height: 0 !important;
        overflow: visible !important;
        opacity: 0 !important;
        pointer-events: none !important;
      }
      button[aria-label*="Settings" i], button[aria-label*="Setelan" i],
      button[aria-label*="Pengaturan" i], button[aria-label*="Notebook settings" i] {
        opacity: 0 !important;
        pointer-events: none !important;
      }
      labs-tailwind-logo, a.logo-link, .logo-container,
      app-notebook-guide, notebook-guide, app-guide-intro,
      app-chat-intro, app-project-summary, app-notebook-overview,
      .notebook-guide, .guide-container, .hero-container,
      .cover-image-container, .summary-card, .guide-card {
        max-height: 0 !important;
        overflow: hidden !important;
        opacity: 0 !important;
        pointer-events: none !important;
      }
      .ot-opening-language [role="menu"],
      .ot-opening-language .mat-mdc-menu-panel { opacity: 0 !important; }
      .cdk-overlay-container { z-index: 99999 !important; }
      .chat-panel-content, .chat-view, .conversation-container, .message-list {
        padding-bottom: max(28px, env(safe-area-inset-bottom)) !important;
      }
      .chat-message-pair, .to-user-container, .to-model-container {
        margin-bottom: 18px !important;
      }
      .rendered-markdown, .chat-response { line-height: 1.8 !important; }
      .rendered-markdown p + p, .chat-response p + p { margin-top: 1em !important; }
      ::-webkit-scrollbar { display: none !important; width: 0 !important; }
      html, body, * { scrollbar-width: none !important; }
    `;
    (document.head || document.documentElement).appendChild(style);
  }

  function triggerClick(el) {
    if (!el) return;
    try {
      const rect = el.getBoundingClientRect();
      const x = rect.left + (rect.width > 0 ? rect.width / 2 : 0);
      const y = rect.top + (rect.height > 0 ? rect.height / 2 : 0);
      const evtInit = {
        bubbles: true,
        cancelable: true,
        view: window,
        clientX: x,
        clientY: y
      };
      el.dispatchEvent(new PointerEvent('pointerdown', evtInit));
      el.dispatchEvent(new MouseEvent('mousedown', evtInit));
      el.dispatchEvent(new PointerEvent('pointerup', evtInit));
      el.dispatchEvent(new MouseEvent('mouseup', evtInit));
      el.click();
    } catch (e) {
      try { el.click(); } catch (_) {}
    }
  }

  function findOutputLanguageItem() {
    const panels = [...document.querySelectorAll('[role="menu"], .mat-mdc-menu-panel, .cdk-overlay-pane')];
    if (panels.length === 0) return null;
    const candidates = panels.flatMap(panel => [...panel.querySelectorAll('[role="menuitem"], button, mat-list-item, div')]);
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

    function cleanup() {
      setTimeout(() => {
        root.classList.remove('ot-opening-language');
      }, 500);
    }

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

    const oldPosition = settings.style.cssText;
    settings.style.setProperty('top', '8px', 'important');
    settings.style.setProperty('left', '8px', 'important');
    settings.style.setProperty('opacity', '0.001', 'important');
    settings.style.setProperty('pointer-events', 'auto', 'important');
    settings.style.setProperty('visibility', 'visible', 'important');

    triggerClick(settings);

    const deadline = Date.now() + 2500;
    const interval = setInterval(() => {
      const item = findOutputLanguageItem();
      if (item) {
        clearInterval(interval);
        triggerClick(item);
        settings.style.cssText = oldPosition;
        cleanup();
        return;
      }
      if (Date.now() > deadline) {
        clearInterval(interval);
        settings.style.cssText = oldPosition;
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

  function ready() {
    if (accessDenied()) return false;
    if (inputReady()) return true;
    return !!document.querySelector('app-chat-view, .chat-view, .chat-panel-content, [role="log"]');
  }
  function inputReady() {
    return !!document.querySelector('textarea, [contenteditable="true"], [role="textbox"]');
  }
function accessDenied() {
  const body = (document.body?.innerText || '').toLowerCase();
  const title = (document.title || '').toLowerCase();
  const hasTextMatch = /anda memerlukan akses|minta akses|you need access|request access|tidak memiliki izin/.test(body) ||
    /anda memerlukan akses|you need access/.test(title);
  const hasElementMatch = !!document.querySelector('[aria-label*="Request access" i], [aria-label*="Minta akses" i], app-access-denied, div[class*="access-denied" i]');
  return hasTextMatch || hasElementMatch;
}
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
  openLanguageSettings: window.otOpenLanguageSettings
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
    if (presentationEnabled) clean();
    checkGenerationState();
  });
});
observer.observe(document, {subtree:true, childList:true, characterData:true});
})();
''';
