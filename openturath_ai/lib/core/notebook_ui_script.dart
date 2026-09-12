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
  function hide(el) { if (el && !el.hasAttribute('data-ot-hidden')) el.setAttribute('data-ot-hidden', ''); }
  function clean() {
    if (!document.documentElement) return;
    if (!document.getElementById('ot-conversation-ui')) {
      const style = document.createElement('style'); style.id = 'ot-conversation-ui';
      style.textContent = `
        [data-ot-hidden], .chat-disclaimer, .disclaimer, .chat-footer-disclaimer,
        .notebook-guide, notebook-guide, .notebook-overview, notebook-overview,
        .notebook-cover, .notebook-cover-container, .notebook-title-card,
        .notebook-header, .project-header, .chat-header, .chat-panel-header,
        .mobile-tab-bar, .mobile-tabs, .mobile-navigation, mat-tab-header {
          display:none!important;
        }
      `;
      (document.head || document.documentElement).appendChild(style);
    }
    document.querySelectorAll('[role="tablist"]').forEach(el => {
      if (/sources|sumber/i.test(text(el)) && /studio/i.test(text(el))) hide(el);
    });
    document.querySelectorAll('p, span, div, footer').forEach(el => {
      if (el.children.length > 2 || el.closest(answerSelector)) return;
      const value = text(el);
      if (value.length < 240 && /(?:Gemini Notebook|NotebookLM) can be inaccurate|please double.check its responses/i.test(value)) hide(el);
    });
    // The cover is identified by its metadata, never by generic answer cards.
    document.querySelectorAll('h1, h2, [class*="notebook-title"], [class*="title-card"], [class*="project-title"]').forEach(el => {
      if (el.closest(answerSelector)) return;
      let card = el;
      for (let i = 0; card && i < 5; i++, card = card.parentElement) {
        if (card.querySelector('textarea, [contenteditable="true"]') || card.querySelector(answerSelector)) break;
        if (/\d+ sources\b|\d+ sumber\b/i.test(text(card)) && text(card).length < 1500) { hide(card); break; }
      }
    });
    // Dismiss only the informational announcement shown in the reported screenshot.
    document.querySelectorAll('[role="dialog"], mat-dialog-container, .cdk-overlay-pane').forEach(dialog => {
      if (!/more flexibility and control/i.test(text(dialog)) || !/limits refresh every 5 hours/i.test(text(dialog))) return;
      if (!dialog.hasAttribute('data-ot-dismissed')) {
        dialog.setAttribute('data-ot-dismissed', '');
        const close = [...dialog.querySelectorAll('button')].find(b => /^(close|dismiss|got it|tutup|mengerti|done)$/i.test((b.getAttribute('aria-label') || text(b)).trim()));
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
  }
  function ready() {
    clean();
    const input = [...document.querySelectorAll('textarea, [contenteditable="true"], [role="textbox"]')].find(visible);
    const loading = [...document.querySelectorAll('[role="progressbar"], mat-spinner, .loading-spinner')].some(visible) || [...document.querySelectorAll('h1, h2, [class*="notebook-title"]')].some(el => /loading notebook|memuat notebook/i.test(text(el)));
    return !!input && !input.disabled && input.getAttribute('aria-disabled') !== 'true' && !loading;
  }
  window.otNotebook = {clean, ready, latest};
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
