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
  function conversation() {
    const questionSelector = '.chat-message[data-sender="user"], .user-message, .from-user, .to-model-container, [data-message-author-role="user"], app-chat-query, app-chat-prompt';
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
  function clean() {
    if (!document.documentElement) return;
    syncTheme();
    if (!document.getElementById('ot-conversation-ui')) {
      const style = document.createElement('style'); style.id = 'ot-conversation-ui';
      style.textContent = `
        [data-ot-hidden],
        top-bar, .top-bar, header, .header, .app-header, app-header,
        mat-toolbar, [role="banner"], .header-container, .header-row,
        .mobile-header, div[class*="mobile-header" i],
        labs-tailwind-logo, a.logo-link, .logo-container,
        a[aria-label*="Homepage" i], a[aria-label*="NotebookLM" i], a[aria-label*="Gemini" i],
        .title-input, input.title-input, .title-container, .notebook-title,
        .notebook-header, app-notebook-header, app-project-header,
        .title-card, mat-card.title-card, .mat-mdc-card.title-card,
        .project-header, div[class*="project-header" i], div.source-badge-container,
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
        button[aria-label*="Settings" i], button[aria-label*="Setelan" i],
        button[aria-label*="More" i], button[aria-label*="Opsi" i],
        button[aria-label*="options" i], button[aria-label*="Notebook options" i],
        button[aria-label*="Option" i],
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
        .chat-panel-content, .chat-view, .conversation-container, .message-list, main, app-chat-view {
          padding-top: 8px !important;
          padding-bottom: 24px !important;
          margin-top: 0px !important;
        }
        /* Border dan drop-shadow tegas untuk lingkaran kolom input (Light & Dark) */
        .chat-input-container, div[class*="query-box" i], div[class*="chat-input" i],
        div[class*="input-container" i], div[class*="prompt-box" i], app-chat-input,
        form:has(textarea), div:has(> textarea), div:has(> [contenteditable="true"]) {
          border: 2px solid #94A3B8 !important;
          box-shadow: 0 4px 20px rgba(0, 0, 0, 0.14), 0 1px 4px rgba(0, 0, 0, 0.08) !important;
          background-color: #FFFFFF !important;
          border-radius: 28px !important;
          transition: border-color 0.2s ease, box-shadow 0.2s ease !important;
        }
        .chat-input-container:focus-within, div[class*="query-box" i]:focus-within,
        div[class*="chat-input" i]:focus-within, form:has(textarea:focus),
        div:has(> textarea:focus), div:has(> [contenteditable="true"]:focus) {
          border-color: #475569 !important;
          box-shadow: 0 6px 24px rgba(0, 0, 0, 0.22), 0 2px 6px rgba(0, 0, 0, 0.1) !important;
        }
        :root.dark .chat-input-container, :root.dark div[class*="query-box" i],
        :root.dark div[class*="chat-input" i], :root.dark div[class*="input-container" i],
        .dark .chat-input-container, .dark div[class*="query-box" i],
        .dark div:has(> textarea), .dark div:has(> [contenteditable="true"]) {
          border: 1.8px solid rgba(255, 255, 255, 0.38) !important;
          box-shadow: 0 6px 24px rgba(0, 0, 0, 0.55) !important;
          background-color: #26272B !important;
          border-radius: 28px !important;
        }
        :root.dark .chat-input-container:focus-within, :root.dark div[class*="query-box" i]:focus-within,
        .dark .chat-input-container:focus-within, .dark div[class*="query-box" i]:focus-within {
          border-color: rgba(255, 255, 255, 0.65) !important;
          box-shadow: 0 8px 30px rgba(0, 0, 0, 0.75) !important;
        }
        .chat-input-container textarea, div[class*="query-box" i] textarea,
        div[class*="chat-input" i] textarea, [contenteditable="true"] {
          border: none !important;
          outline: none !important;
          box-shadow: none !important;
          background: transparent !important;
        }
        .mat-mdc-text-field-wrapper, .mat-mdc-form-field-flex {
          background: transparent !important;
          border: none !important;
          box-shadow: none !important;
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
    document.querySelectorAll('header, top-bar, .top-bar, app-header, app-notebook-header, app-project-header, .notebook-header, .project-header, #gb, #gbwa, .gb_C, .gb_9a, .gb_8, .gb_U, div[id*="gb"], div[class*="gb_"], [role="banner"], labs-tailwind-logo, a.logo-link, .logo-container, a[aria-label*="Google" i], [aria-label*="Google Account" i], [aria-label*="Akun Google" i], [aria-label*="Google apps" i], [aria-label*="Aplikasi Google" i], app-notebook-guide, notebook-guide, .notebook-guide, app-guide-intro, app-chat-intro, app-project-summary, app-notebook-overview, app-notebook-title, .guide-header, .hero-container, .cover-image-container, .project-info, .notebook-metadata, .summary-card, .guide-card').forEach(el => {
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
    // Perbarui placeholder input ke bahasa santri alami dan perkuat styling lingkarannya
    const targetPlaceholder = 'Ajukan pertanyaan atau masalah';
    const inputElement = document.querySelector('textarea, [contenteditable="true"], [role="textbox"], input[type="text"]');
    if (inputElement) {
      if (inputElement.placeholder && inputElement.placeholder !== targetPlaceholder) {
        inputElement.placeholder = targetPlaceholder;
      }
      if (inputElement.getAttribute('data-placeholder') && inputElement.getAttribute('data-placeholder') !== targetPlaceholder) {
        inputElement.setAttribute('data-placeholder', targetPlaceholder);
      }
      if (inputElement.getAttribute('aria-label') && /ask|ketik|type|pertanyaan|masalah/i.test(inputElement.getAttribute('aria-label'))) {
        inputElement.setAttribute('aria-label', targetPlaceholder);
      }
      let pill = null;
      let cur = inputElement;
      for (let i = 0; i < 6; i++) {
        if (!cur || cur === document.body) break;
        const sendBtn = cur.querySelector('button[aria-label*="send" i], button[aria-label*="kirim" i], [data-action*="send" i], button.send-button, form button[type="submit"]');
        if (sendBtn && sendBtn !== cur) {
          pill = cur;
          break;
        }
        if (cur.classList.contains('chat-input-container') || cur.classList.contains('query-box') || cur.tagName.toLowerCase() === 'form') {
          pill = cur;
          break;
        }
        cur = cur.parentElement;
      }
      if (!pill) {
        pill = inputElement.closest('form') || inputElement.closest('.chat-input-container') || inputElement.closest('[class*="query-box" i]') || inputElement.parentElement;
      }
      if (pill && pill !== document.body) {
        const isDark = !!window._otIsDark;
        pill.style.setProperty('border', isDark ? '1.8px solid rgba(255, 255, 255, 0.38)' : '2px solid #94A3B8', 'important');
        pill.style.setProperty('box-shadow', isDark ? '0 6px 24px rgba(0, 0, 0, 0.55)' : '0 4px 20px rgba(0, 0, 0, 0.14), 0 1px 4px rgba(0, 0, 0, 0.08)', 'important');
        pill.style.setProperty('background-color', isDark ? '#26272B' : '#FFFFFF', 'important');
        pill.style.setProperty('border-radius', '28px', 'important');
        pill.style.setProperty('transition', 'border-color 0.2s ease, box-shadow 0.2s ease', 'important');
      }
    }
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
    function replaceBrandInText(node) {
      if (node.nodeType === Node.TEXT_NODE) {
        if (/gemini(\s+notebook)?|notebooklm/i.test(node.nodeValue)) {
          node.nodeValue = node.nodeValue
            .replace(/gemini\s+notebook/gi, 'OpenTurath AI')
            .replace(/notebooklm/gi, 'OpenTurath AI')
            .replace(/gemini/gi, 'OpenTurath AI');
        }
      } else if (node.nodeType === Node.ELEMENT_NODE && !node.matches(answerSelector)) {
        for (let child of node.childNodes) {
          replaceBrandInText(child);
        }
      }
    }
    document.querySelectorAll('.chat-disclaimer, .query-disclaimer, .model-disclaimer, [class*="disclaimer" i], [aria-label*="disclaimer" i], div, p, span, small').forEach(el => {
      if (el.closest(answerSelector)) return;
      const t = (el.innerText || '').toLowerCase();
      if (t.length < 300 && (/gemini/i.test(t) || /notebooklm/i.test(t) || /tidak akurat|inaccurate/i.test(t))) {
        replaceBrandInText(el);
      }
    });
  }
  window.otOpenLanguageSettings = function() {
    const directBtn = document.querySelector('button[aria-label*="Settings" i], button[aria-label*="Setelan" i], button[aria-label*="Notebook settings" i], [data-action*="settings" i]');
    if (directBtn) {
      directBtn.click();
      return true;
    }
    const menuBtn = document.querySelector('button[aria-label*="options" i], button[aria-label*="More" i], button[aria-label*="Opsi" i], [aria-label*="Menu" i]');
    if (menuBtn) {
      menuBtn.click();
      setTimeout(() => {
        const items = [...document.querySelectorAll('[role="menuitem"], button, mat-list-item, div')];
        const settingItem = items.find(el => {
          const t = (el.innerText || el.getAttribute('aria-label') || '').toLowerCase();
          return t.includes('setting') || t.includes('setelan') || t.includes('bahasa') || t.includes('language');
        });
        if (settingItem) settingItem.click();
      }, 120);
      return true;
    }
    return false;
  };
  window.otSendPrompt = function(promptText) {
    if (!promptText || typeof promptText !== 'string') return false;
    const input = document.querySelector('textarea, [contenteditable="true"], [role="textbox"], input[type="text"]');
    if (!input) return false;
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
window.otNotebook = {clean, ready, latest, conversation, conversationList, accessDenied, setTheme: syncTheme};
let scheduled = false;
let isGenerating = false;
let lastAnswerText = '';

function checkGenerationState() {
  const stopBtn = document.querySelector('button[aria-label*="Stop" i], button[aria-label*="Hentikan" i], [data-action*="stop" i]');
  const currentlyGenerating = !!(stopBtn && stopBtn.offsetParent !== null);
  const currentAnswer = latest();

  if (currentlyGenerating && !isGenerating) {
    isGenerating = true;
    lastAnswerText = currentAnswer;
    if (window.flutter_inappwebview?.callHandler) {
      window.flutter_inappwebview.callHandler('otAnswerState', { state: 'generating', text: currentAnswer });
    }
  } else if (isGenerating) {
    if (currentAnswer && currentAnswer !== lastAnswerText) {
      lastAnswerText = currentAnswer;
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
