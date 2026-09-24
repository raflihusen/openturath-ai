/// Conversation cleanup and explicit copy capture, restricted to NotebookLM.
const notebookUiScript = r'''
(function () {
  if (window.top !== window || !['notebooklm.google.com', 'notebook.google.com'].includes(location.hostname)) return;
  if (window.otNotebook) {
    window.otOpenLanguageSettings = window.otNotebook.openLanguageSettings;
    window.otNotebook.clean();
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

  function hide(el) { if (el && !el.hasAttribute('data-ot-hidden')) el.setAttribute('data-ot-hidden', ''); }
  function replaceBrandInText(node) {
    if (node.nodeType === Node.TEXT_NODE) {
      if (/gemini(\s+notebook)?|notebooklm/i.test(node.nodeValue)) {
        node.nodeValue = node.nodeValue
          .replace(/gemini\s+notebook/gi, 'OpenTurath AI')
          .replace(/notebooklm/gi, 'OpenTurath AI')
          .replace(/gemini/gi, 'OpenTurath AI');
      }
    } else if (node.nodeType === Node.ELEMENT_NODE && !node.matches(answerSelector)) {
      for (const child of node.childNodes) replaceBrandInText(child);
    }
  }
  function clean() {
    if (!document.documentElement) return;
    syncTheme();
    if (!document.getElementById('ot-conversation-ui')) {
      const style = document.createElement('style'); style.id = 'ot-conversation-ui';
      style.textContent = `
        [data-ot-hidden],
        labs-tailwind-logo, a.logo-link, .logo-container,
        a[aria-label*="Homepage" i], a[aria-label*="NotebookLM" i], a[aria-label*="Gemini" i],
        .title-input, input.title-input, .title-container, .notebook-title,
        .title-card, mat-card.title-card, .mat-mdc-card.title-card,
        div.source-badge-container,
        .pro-badge,
        /* Sembunyikan kartu keterangan, hero cover, dan panduan notebook di atas chat */
        app-notebook-guide, notebook-guide, app-guide-intro, app-chat-intro,
        app-project-summary, app-notebook-overview, app-notebook-title,
        .notebook-guide, .guide-header, .guide-container, .notebook-guide-container,
        .hero-container, .cover-image-container, .project-info, .notebook-metadata,
        .project-summary, .notebook-summary, .summary-card, .guide-card,
        div:has(> img[alt*="cover" i]), div[class*="hero" i], div[class*="cover" i],
        div[class*="guide" i]:not(.chat-view):not(.conversation-container),
        #gb, #gbwa, .gb_C, .gb_9a, .gb_8, .gb_U, div[id*="gb"], div[class*="gb_"],
        button.mat-tonal-button, a[aria-label*="Google" i],
        [aria-label*="Google Account" i], [aria-label*="Akun Google" i],
        [aria-label*="Google apps" i], [aria-label*="Aplikasi Google" i] {
          display: none !important;
          visibility: hidden !important;
          height: 0px !important;
          max-height: 0px !important;
          overflow: hidden !important;
          margin: 0px !important;
          padding: 0px !important;
          opacity: 0 !important;
          pointer-events: none !important;
          border: none !important;
        }
        top-bar, .top-bar, header, .header, .app-header, app-header,
        mat-toolbar, [role="banner"], .header-container, .header-row,
        .mobile-header, div[class*="mobile-header" i],
        .notebook-header, app-notebook-header, app-project-header,
        .project-header, div[class*="project-header" i] {
          position: fixed !important;
          top: -9999px !important;
          left: -9999px !important;
          opacity: 0 !important;
          pointer-events: none !important;
          z-index: -1 !important;
        }
        button[aria-label*="Settings" i], button[aria-label*="Setelan" i],
        button[aria-label*="Pengaturan" i], button[aria-label*="Notebook settings" i],
        button[aria-label*="More" i], button[aria-label*="Opsi" i],
        button[aria-label*="options" i], button[aria-label*="Notebook options" i],
        button[aria-label*="Option" i] {
          position: fixed !important;
          top: -9999px !important;
          left: -9999px !important;
          width: 24px !important;
          height: 24px !important;
          opacity: 0.001 !important;
          pointer-events: auto !important;
          visibility: visible !important;
          z-index: -1 !important;
        }
        .ot-opening-language [role="menu"],
        .ot-opening-language .mat-mdc-menu-panel,
        .ot-opening-language .cdk-overlay-pane:has([role="menu"]) {
          opacity: 0 !important;
        }
        .cdk-overlay-container {
          z-index: 99999 !important;
        }
        [role="dialog"], mat-dialog-container, .mat-mdc-dialog-container {
          opacity: 1 !important;
          visibility: visible !important;
          display: block !important;
          z-index: 100000 !important;
        }
        .chat-panel-content, .chat-view, .conversation-container, .message-list, main, app-chat-view {
          padding-top: 8px !important;
          padding-bottom: 24px !important;
          margin-top: 0px !important;
        }
        .chat-message-pair, .to-user-container, .to-model-container {
          margin-bottom: 18px !important;
        }
        .rendered-markdown p + p, .chat-response p + p {
          margin-top: 1em !important;
        }
        .chat-disclaimer, .query-disclaimer, .model-disclaimer,
        [class*="disclaimer" i], [aria-label*="disclaimer" i],
        [data-testid*="disclaimer" i] {
          display: block !important;
          visibility: visible !important;
          opacity: 0.65 !important;
          font-size: 11px !important;
          line-height: 1.4 !important;
          text-align: center !important;
          margin: 4px 0 8px 0 !important;
          pointer-events: auto !important;
          height: auto !important;
          max-height: none !important;
        }
      `;
      (document.head || document.documentElement).appendChild(style);
    }
    // Sembunyikan header, kartu cover/guide, dan Google account bar secara presisi
    document.querySelectorAll('#gb, #gbwa, .gb_C, .gb_9a, .gb_8, .gb_U, div[id*="gb"], div[class*="gb_"], labs-tailwind-logo, a.logo-link, .logo-container, a[aria-label*="Google" i], [aria-label*="Google Account" i], [aria-label*="Akun Google" i], [aria-label*="Google apps" i], [aria-label*="Aplikasi Google" i], app-notebook-guide, notebook-guide, .notebook-guide, app-guide-intro, app-chat-intro, app-project-summary, app-notebook-overview, app-notebook-title, .guide-header, .hero-container, .cover-image-container, .project-info, .notebook-metadata, .summary-card, .guide-card').forEach(el => {
      hide(el);
      el.style.setProperty('display', 'none', 'important');
      el.style.setProperty('visibility', 'hidden', 'important');
      el.style.setProperty('height', '0px', 'important');
    });
    // Hapus kartu intro/cover yang memuat ringkasan sumber di atas timeline obrolan
    document.querySelectorAll('app-notebook-guide, notebook-guide, .notebook-guide, app-project-summary, .project-summary, app-guide-intro, .guide-header, .hero-container, .cover-image-container, mat-card, .mat-mdc-card, div[class*="guide" i]:not(.chat-view):not(.conversation-container), div[class*="summary" i]').forEach(card => {
      if (card.closest(answerSelector) || card.closest(questionSelector) || card.querySelector(answerSelector)) return;
      const txt = (card.innerText || '').toLowerCase();
      if (txt.includes('sources') || txt.includes('sumber') || txt.includes('super ai') || txt.includes('bridging turath') || txt.includes('berbasis turath') || txt.includes('openturath') || card.querySelector('img') || card.matches('app-notebook-guide, notebook-guide, .notebook-guide, app-project-summary, .hero-container, .cover-image-container')) {
        hide(card);
        card.style.setProperty('display', 'none', 'important');
        card.style.setProperty('height', '0px', 'important');
        card.style.setProperty('visibility', 'hidden', 'important');
      }
    });
    // Pastikan tab Chat terpilih jika berada di tampilan tab responsive
    try {
      const tabs = [...document.querySelectorAll('[role="tab"], .mat-mdc-tab, button')];
      const chatTab = tabs.find(t => {
        const txt = (t.innerText || t.getAttribute('aria-label') || '').trim().toLowerCase();
        return (txt === 'chat' || txt === 'obrolan' || txt === 'percakapan') && t.offsetParent !== null;
      });
      if (chatTab && chatTab.getAttribute('aria-selected') !== 'true') {
        chatTab.click();
      }
    } catch(_) {}
    // Auto-dismiss dialog pengumuman Google (tapi jangan pernah tutup dialog bahasa!)
    document.querySelectorAll('[role="dialog"], mat-dialog-container, .cdk-overlay-pane, [class*="announcement"]').forEach(dialog => {
      const t = text(dialog).toLowerCase();
      if (t.includes('language') || t.includes('bahasa') || t.includes('output') || t.includes('لغة')) return;
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
    // Tampilkan disclaimer dengan nama OpenTurath AI (menggantikan Gemini Notebook / NotebookLM)
    document.querySelectorAll('.chat-disclaimer, .query-disclaimer, .model-disclaimer, [class*="disclaimer" i], [aria-label*="disclaimer" i], div, p, span, small').forEach(el => {
      if (el.closest(answerSelector)) return;
      const t = (el.innerText || '').toLowerCase();
      if (t.length < 300 && (/gemini/i.test(t) || /notebooklm/i.test(t) || /tidak akurat|inaccurate/i.test(t))) {
        replaceBrandInText(el);
      }
    });
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
    const candidates = panels.flatMap(panel => [...panel.querySelectorAll('[role="menuitem"], button, mat-list-item')]);
    return candidates.find(candidate => {
      if (!candidate || !document.contains(candidate)) return false;
      const label = (candidate.getAttribute('aria-label') || candidate.innerText || candidate.textContent || '')
        .trim().replace(/\s+/g, ' ').toLowerCase();
      return /^(output language|bahasa output|bahasa keluaran|لغة الإخراج)(?:\s|$)/i.test(label);
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
    return null;
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
    clean();
    if (accessDenied()) return false;
    const input = document.querySelector('textarea, [contenteditable="true"], [role="textbox"], input[type="text"]');
    if (input) return true;
    const hasMessage = document.querySelector(answerSelector) || document.querySelector('.chat-message, .chat-response, app-chat-response, app-chat-message, [role="article"]');
    if (hasMessage) return true;
    const chatContainer = document.querySelector('.chat-input-container, .query-box, app-chat-guide, .chat-guide, notebook-guide, app-notebook-guide');
    if (chatContainer) return true;
    const bodyText = (document.body?.innerText || '').toLowerCase();
    if (bodyText.length > 50 && !/loading notebook|memuat notebook/i.test(bodyText)) {
      return true;
    }
    return false;
  }
function accessDenied() {
  const body = (document.body?.innerText || '').toLowerCase();
  const title = (document.title || '').toLowerCase();
  const hasTextMatch = /anda memerlukan akses|minta akses|you need access|request access|tidak memiliki izin/.test(body) ||
    /anda memerlukan akses|you need access/.test(title);
  const hasElementMatch = !!document.querySelector('[aria-label*="Request access" i], [aria-label*="Minta akses" i], app-access-denied, div[class*="access-denied" i]');
  return hasTextMatch || hasElementMatch;
}
window.otNotebook = {clean, ready, latest, conversation, conversationList, accessDenied, setTheme: syncTheme, openLanguageSettings: window.otOpenLanguageSettings};
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

const observer = new MutationObserver((mutations) => {
  for (const m of mutations) {
    for (const node of m.addedNodes) {
      if (node.nodeType === Node.ELEMENT_NODE || node.nodeType === Node.TEXT_NODE) {
        replaceBrandInText(node);
      }
    }
  }
  if (scheduled) return;
  scheduled = true;
  requestAnimationFrame(() => {
    scheduled = false;
    clean();
    checkGenerationState();
  });
});
observer.observe(document, {subtree:true, childList:true, characterData:true});
clean();
})();
''';
