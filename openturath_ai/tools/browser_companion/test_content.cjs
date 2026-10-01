'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const source = fs.readFileSync(require.resolve('./extension/content.js'), 'utf8');
const notebookId = '11111111-1111-4111-8111-111111111111';
const conversationId = '22222222-2222-4222-8222-222222222222';
const extensionId = 'hbbeklipfbgookgdmkmodkanoflegbok';
const job = {requestId: 'a'.repeat(32), epoch: 'b'.repeat(32), uid: 'fixture-uid',
  googleSub: '123456', email: 'fixture@example.com', notebookId,
  question: 'Fixture source question', conversationId: null, history: null};

function harness(hint, implementation) {
  let listener;
  const calls = [];
  const window = {}; window.top = window;
  const href = `https://notebook.google.com/notebook/${notebookId}${hint}`;
  vm.runInNewContext(source, {window, location: {href, origin: new URL(href).origin},
    URL, TextEncoder, AbortController, setTimeout, clearTimeout,
    fetch: async () => { throw new Error('Unexpected fixture network access'); },
    OpenTurathNotebookProtocol: {async performAsk(options) {
      calls.push(options);
      if (implementation) return implementation(options);
      return {answer: 'Fixture answer', citations: [], conversationId, accountEmail: job.email};
    }},
    chrome: {runtime: {id: extensionId, onMessage: {addListener(value) { listener = value; }}}},
  }, {filename: 'content.js'});
  return {calls, ask: () => new Promise(resolve => {
    assert.equal(listener({type: 'openturath:ask', job}, {id: extensionId}, resolve), true);
  })};
}

for (const hint of ['?authuser=0&pli=1', '?authuser=2', '']) {
  test(`normalized hint ${hint || 'absent'} still invokes account verification`, async () => {
    const h = harness(hint);
    const result = await h.ask();
    assert.equal(h.calls.length, 1);
    assert.equal(h.calls[0].email, job.email);
    assert.equal(result.accountEmail, job.email);
    assert.equal(result.answer, 'Fixture answer');
  });
}

test('numeric URL hint cannot override a protocol account mismatch', async () => {
  const h = harness('?authuser=0', () => {
    const error = new Error('Synthetic mismatch'); error.code = 'ACCOUNT_MISMATCH'; throw error;
  });
  const result = await h.ask();
  assert.equal(result.code, 'account-mismatch');
  assert.equal(result.answer, '');
});

test('a reply for another account cannot cross the native boundary', async () => {
  const h = harness('?authuser=0', () => ({answer: 'Foreign fixture', citations: [],
    conversationId, accountEmail: 'other@example.com'}));
  const result = await h.ask();
  assert.equal(result.code, 'failed-precondition');
  assert.equal(result.answer, '');
});

for (const hint of ['?authuser=other%40example.com', '?authuser=0&authuser=1', '?authuser=invalid']) {
  test(`invalid hint ${hint} is rejected before any protocol request`, async () => {
    const h = harness(hint);
    assert.equal((await h.ask()).code, 'unauthenticated');
    assert.equal(h.calls.length, 0);
  });
}
