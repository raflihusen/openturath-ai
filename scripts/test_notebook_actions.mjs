// Regression checks execute the action code extracted from the shipped Dart JS.
// Run from the workspace root: node --test scripts/test_notebook_actions.mjs
import fs from 'node:fs';
import vm from 'node:vm';
import test from 'node:test';
import assert from 'node:assert/strict';
const source = fs.readFileSync(new URL('../openturath_ai/lib/core/notebook_ui_script.dart', import.meta.url), 'utf8');
const skin = fs.readFileSync(new URL('../openturath_ai/lib/core/notebook_skin.dart', import.meta.url), 'utf8');
const visible = () => true;
function message(role, value, children = []) {
  const node = {role, innerText: value, children, parent: null,
    getClientRects: () => [1], querySelectorAll: () => [],
    matches: selector => role === 'user' && !selector.includes('app-chat-response'),
    contains(other) { return children.some(child => child === other || child.contains(other)); },
    closest(selector) { return this.matches(selector) ? this : this.parent?.closest(selector); },
    cloneNode() { return this; },
  };
  children.forEach(child => { child.parent = node; });
  return node;
}
function exportConversation(nodes) {
  const block = source.slice(source.indexOf('  const answerSelector'), source.indexOf("  let lastCopy = ''));
  const context = vm.createContext({document: {querySelectorAll: () => nodes}, getComputedStyle: () => ({visibility: 'visible', display: 'block'})});
  vm.runInContext(block + ';this.output = conversation();', context);
  return context.output;
}
test('export retains identical questions and answers in separate turns', () => {
  const result = exportConversation([message('user', 'Q'), message('assistant', 'A'), message('user', 'Q'), message('assistant', 'A')]);
  assert.match(result, /PERTANYAAN 2\nQ/);
  assert.match(result, /JAWABAN 2\nA/);
});
test('export deduplicates nested wrappers without merging separate repeated turns', () => {
  const q = message('user', 'Q'); const a = message('assistant', 'A');
  const aw = message('assistant', 'A extra', [a]);
  const turn = message('assistant', 'Q A extra', [q, aw]);
  const result = exportConversation([turn, q, aw, a, message('user', 'Q'), message('assistant', 'A extra')]);
  assert.match(result, /JAWABAN 1\nA extra/);
  assert.match(result, /JAWABAN 2\nA extra/);
  assert.equal(result.includes('JAWABAN 3'), false);
  assert.equal(result.includes('Q A extra'), false);
});
function clipboard(bridge) {
  const context = vm.createContext({window: {flutter_inappwebview: {callHandler: bridge}}, navigator: {}, Date, Promise});
  vm.runInContext(source.slice(source.indexOf("  let lastCopy = ''"), source.indexOf('  // Tangkap klik')) + ';this.copy = sendCopy;', context);
  return context.copy;
}
test('two different answers copied rapidly both reach the device clipboard', async () => {
  const writes = []; const copy = clipboard(async (_, text) => { writes.push(text); return true; });
  assert.equal(await copy('Answer A'), true);
  assert.equal(await copy('Answer B'), true);
  assert.deepEqual(writes, ['Answer A', 'Answer B']);
});
test('duplicate click and native copy events share one acknowledged clipboard write', async () => {
  let writes = 0; const copy = clipboard(async () => { writes++; return true; });
  const [first, second] = await Promise.all([copy('A'), copy('A')]);
  assert.equal(first, true); assert.equal(second, true); assert.equal(writes, 1);
});
test('failed clipboard acknowledgement permits immediate retry', async () => {
  let writes = 0; const copy = clipboard(async () => ++writes === 2);
  assert.equal(await copy('A'), false); assert.equal(await copy('A'), true); assert.equal(writes, 2);
});
test('copy label changes only after successful clipboard acknowledgement', () => {
  let listener; const btn = {addEventListener: (_, cb) => { listener = cb; }};
  const label = {textContent: 'Salin jawaban'};
  const start = skin.indexOf("        btn.addEventListener('ot-copy-result'");
  const end = skin.indexOf('\n        });', start) + '\n        });'.length;
  vm.runInNewContext(skin.slice(start, end), {btn, label, LABELS: {id: {copied: 'Tersalin', copyFailed: 'Gagal menyalin'}}, lang: () => 'id', clearTimeout() {}, setTimeout() {}});
  assert.equal(label.textContent, 'Salin jawaban');
  listener({detail: false}); assert.equal(label.textContent, 'Gagal menyalin');
  listener({detail: true}); assert.equal(label.textContent, 'Tersalin');
});
async function deleteHistory(mode) {
  let now = 0; let messages = [message('user', 'Q'), message('assistant', 'A')];
  let localRemovals = 0; let providerClicks = 0; let dialog = false; let failed = false;
  messages.forEach(node => { node.remove = () => { localRemovals++; }; });
  const confirm = {innerText: 'Delete', getAttribute: () => null, click() {
    providerClicks++; dialog = false;
    if (mode === 'success' || mode === 'transient') messages = [];
    if (mode === 'failure') failed = true;
  }};
  const menu = {innerText: 'Delete chat history', getAttribute: () => null, click() {
    providerClicks++; dialog = mode !== 'no-confirmation';
  }};
  const querySelectorAll = selector => {
    if (selector.includes('[data-sender')) {
      if (mode === 'transient' && now >= 500) return [message('assistant', 'Still present')];
      return messages;
    }
    if (selector.includes('[role="menuitem"]')) return mode === 'no-menu' ? [] : [menu];
    if (selector === 'mat-icon, [data-mat-icon-name]') return [];
    if (selector.includes('mat-dialog-container,')) return dialog ? [{innerText: 'Delete chat history?', querySelectorAll: () => [confirm]}] : [];
    if (selector.includes('[role="alert"]')) return failed ? [{innerText: 'Delete failed'}] : [];
    return [];
  };
  const window = {};
  const context = vm.createContext({window, document: {querySelectorAll}, questionSelector: '[data-sender="user"]', answerSelector: '[data-sender="model"]', visible, inputReady: () => true,
    triggerClick: el => { el.click(); return true; }, Date: {now: () => now}, setTimeout: callback => { now += 100; queueMicrotask(callback); }, Promise,
  });
  vm.runInContext(source.slice(source.indexOf('window.otDeleteChatHistory = '), source.indexOf('\nwindow.otNotebook = {')), context);
  const result = await window.otClearChat();
  return {result, localRemovals, providerClicks, messages, elapsed: now};
}
test('unavailable provider delete menu returns failure and preserves the transcript', async () => {
  const result = await deleteHistory('no-menu');
  assert.equal(result.result, false); assert.equal(result.localRemovals, 0); assert.equal(result.messages.length, 2); assert.equal(result.providerClicks, 0);
});
test('missing confirmation and failed provider request never claim deletion', async () => {
  for (const mode of ['no-confirmation', 'failure']) {
    const result = await deleteHistory(mode);
    assert.equal(result.result, false, mode); assert.equal(result.localRemovals, 0); assert.equal(result.messages.length, 2);
  }
});
test('successful deletion waits for provider UI completion with stable empty chat', async () => {
  const result = await deleteHistory('success');
  assert.equal(result.result, true); assert.equal(result.localRemovals, 0); assert.equal(result.providerClicks, 2); assert.ok(result.elapsed >= 1000);
});
test('temporary empty chat while the provider updates is not deletion success', async () => {
  const result = await deleteHistory('transient');
  assert.equal(result.result, false); assert.equal(result.localRemovals, 0);
});
