'use strict';

// Synthetic Chrome APIs only. This suite cannot open a browser or make requests.
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const assert = require('node:assert/strict');
const test = require('node:test');

const sourcePath = process.argv[2] || path.join(__dirname, 'extension', 'background.js');
const workerSource = fs.readFileSync(sourcePath, 'utf8');
const notebookId = '11111111-1111-1111-1111-111111111111';
const conversationId = '22222222-2222-2222-2222-222222222222';
const fixtureJob = {
  requestId: 'a'.repeat(32), epoch: 'b'.repeat(32), uid: 'fixture-user',
  googleSub: '123456', email: 'fixture@example.com', notebookId,
  question: 'Synthetic fixture question', history: null, conversationId: null,
};

function event() {
  const listeners = new Set();
  return {
    addListener: listener => listeners.add(listener),
    removeListener: listener => listeners.delete(listener),
    fire: (...args) => { for (const listener of [...listeners]) listener(...args); },
  };
}

function deferred() {
  let resolve, reject;
  const promise = new Promise((success, failure) => { resolve = success; reject = failure; });
  return {promise, resolve, reject};
}

function typedReply(job) {
  return {
    ...job, answer: 'Synthetic answer', citations: [], conversationId,
    accountEmail: job.email, bootstrap: 'MUST_NOT_ESCAPE',
  };
}

async function flush() {
  for (let count = 0; count < 8; count++) await new Promise(setImmediate);
}

function harness() {
  const ports = [], asks = [], cancellations = [], created = [], badges = [];
  const timers = new Map();
  let timerSequence = 0;
  let tab = {id: 7, status: 'complete', incognito: false,
    url: `https://notebooklm.google.com/notebook/${notebookId}?authuser=fixture%40example.com`};
  let answer = async message => typedReply(message.job);
  let query = async () => [tab];
  let get = async () => tab;
  const chrome = {
    runtime: {
      connectNative(host) {
        assert.equal(host, 'com.openturath.browser_companion');
        const port = {onMessage: event(), onDisconnect: event(), messages: [],
          postMessage(message) { this.messages.push(message); }};
        ports.push(port);
        return port;
      },
      onStartup: event(), onInstalled: event(), lastError: null,
    },
    action: {onClicked: event(), setBadgeText(value) { badges.push(value.text); }},
    tabs: {
      onUpdated: event(), onRemoved: event(),
      query: (...args) => query(...args), get: (...args) => get(...args),
      async create(options) {
        created.push(options);
        tab = {id: 8, status: 'complete', incognito: false, url: options.url};
        return tab;
      },
      async sendMessage(tabId, message, options) {
        assert.equal(options.frameId, 0);
        if (message.type === 'openturath:cancel') {
          cancellations.push({tabId, ...message});
          return;
        }
        assert.equal(message.type, 'openturath:ask');
        asks.push({tabId, job: message.job});
        return answer(message);
      },
    },
  };
  vm.runInNewContext(workerSource, {
    chrome, URL, TextEncoder, AbortController,
    setTimeout(callback, delay) { const id = ++timerSequence; timers.set(id, {callback, delay}); return id; },
    clearTimeout(id) { timers.delete(id); },
  }, {filename: sourcePath});
  return {
    ports, asks, cancellations, created, badges, timers,
    currentPort: () => ports.at(-1),
    emit: message => ports.at(-1).onMessage.fire(message),
    job: (job = fixtureJob) => ports.at(-1).onMessage.fire({type: 'job', job}),
    results: () => ports.flatMap(port => port.messages.filter(message => message.type === 'result')),
    setAnswer: implementation => { answer = implementation; },
    setQuery: implementation => { query = implementation; },
    setGet: implementation => { get = implementation; },
    setTab: value => { tab = value; },
    reconnect() { chrome.action.onClicked.fire(); },
    disconnect() { ports.at(-1).onDisconnect.fire(); },
    async close() { ports.at(-1).onDisconnect.fire(); await flush(); assert.equal(timers.size, 0); },
  };
}

test('worker sends protocol hello and only a typed successful result', async () => {
  const h = harness();
  assert.equal(JSON.stringify(h.currentPort().messages[0]), '{"type":"connected","protocol":1}');
  h.emit({type: 'state', status: 'waiting', code: 'waiting'});
  assert.equal(h.cancellations.length, 0);
  h.emit({type: 'state', status: 'connected', code: 'ready'});
  assert.equal(h.badges.at(-1), '');
  h.job(); await flush();
  assert.equal(h.asks.length, 1);
  assert.equal(h.results()[0].result.answer, 'Synthetic answer');
  assert.equal(JSON.stringify(h.results()).includes('MUST_NOT_ESCAPE'), false);
  assert.equal('question' in h.results()[0].result, false);
  await h.close();
});

test('completed delivery IDs cannot dispatch again on the same epoch or a fresh native port', async () => {
  const h = harness();
  h.job(); await flush();
  h.job(); await flush();
  assert.equal(h.asks.length, 1);
  assert.equal(h.results().length, 1);
  h.disconnect(); h.reconnect(); h.job(); await flush();
  assert.equal(h.ports.length, 2);
  assert.equal(h.asks.length, 1);
  assert.equal(h.results().length, 1);
  await h.close();
});

test('in-flight duplicate delivery is suppressed', async () => {
  const h = harness(), pending = deferred();
  h.setAnswer(() => pending.promise);
  h.job(); await flush(); h.job(); await flush();
  assert.equal(h.asks.length, 1);
  pending.resolve(typedReply(fixtureJob)); await flush();
  assert.equal(h.results().length, 1);
  await h.close();
});

test('request uncertainty cancels content while native messaging remains open and discards late success', async () => {
  const h = harness(), pending = deferred();
  h.setAnswer(() => pending.promise);
  h.job(); await flush();
  h.emit({type: 'state', status: 'uncertain', code: 'uncertain', requestId: fixtureJob.requestId});
  await flush();
  assert.equal(h.ports.length, 1);
  assert.equal(h.cancellations.length, 1);
  assert.equal(h.cancellations[0].epoch, fixtureJob.epoch);
  assert.equal(h.timers.size, 0);
  pending.resolve(typedReply(fixtureJob)); await flush();
  assert.equal(h.results().length, 0);
  h.emit({type: 'state', status: 'connected', code: 'ready'});
  h.job(); await flush(); assert.equal(h.asks.length, 1);
  await h.close();
});

test('a state with a foreign epoch cannot revoke the active request', async () => {
  const h = harness(), pending = deferred();
  h.setAnswer(() => pending.promise);
  h.job(); await flush();
  h.emit({type: 'state', status: 'uncertain', code: 'uncertain',
    epoch: 'c'.repeat(32), requestId: fixtureJob.requestId});
  assert.equal(h.cancellations.length, 0);
  pending.resolve(typedReply(fixtureJob)); await flush();
  assert.equal(h.results().length, 1);
  await h.close();
});

for (const status of ['waiting', 'disconnected']) {
  test(`${status} state cancels active work without closing the native port or replaying it`, async () => {
    const h = harness(), pending = deferred();
    h.setAnswer(() => pending.promise);
    h.job(); await flush();
    h.emit({type: 'state', status, code: status}); await flush();
    assert.equal(h.cancellations.length, 1);
    pending.resolve(typedReply(fixtureJob)); await flush();
    assert.equal(h.results().length, 0);
    h.emit({type: 'state', status: 'connected', code: 'ready'});
    h.job(); await flush(); assert.equal(h.asks.length, 1);
    await h.close();
  });
}

test('native-port disconnection cancels unresolved content and reconnect never replays', async () => {
  const h = harness(), pending = deferred();
  h.setAnswer(() => pending.promise);
  h.job(); await flush();
  h.disconnect(); h.reconnect();
  assert.equal(h.cancellations.length, 1);
  pending.resolve(typedReply(fixtureJob)); await flush();
  assert.equal(h.results().length, 0);
  assert.equal(h.asks.length, 1);
  h.job(); await flush(); assert.equal(h.asks.length, 1);
  await h.close();
});

test('revocation during tab discovery prevents a tab or content request from being created', async () => {
  const h = harness(), discovery = deferred();
  h.setQuery(() => discovery.promise);
  h.job(); await flush();
  h.emit({type: 'state', status: 'waiting', code: 'waiting'});
  discovery.resolve([]); await flush();
  assert.equal(h.created.length, 0);
  assert.equal(h.asks.length, 0);
  assert.equal(h.results().length, 0);
  await h.close();
});

test('revocation during final URL verification prevents dispatch after an await', async () => {
  const h = harness(), verification = deferred();
  let reads = 0;
  const tab = {id: 7, status: 'complete', incognito: false,
    url: `https://notebooklm.google.com/notebook/${notebookId}?authuser=fixture%40example.com`};
  h.setGet(async () => ++reads === 1 ? tab : verification.promise);
  h.job(); await flush();
  assert.equal(reads, 2);
  h.emit({type: 'state', status: 'uncertain', code: 'uncertain', requestId: fixtureJob.requestId});
  verification.resolve(tab); await flush();
  assert.equal(h.asks.length, 0);
  assert.equal(h.results().length, 0);
  await h.close();
});

test('a new runtime epoch cancels old work and a retired epoch cannot return', async () => {
  const h = harness(), pending = deferred();
  const next = {...fixtureJob, requestId: 'd'.repeat(32), epoch: 'c'.repeat(32)};
  h.setAnswer(message => message.job.epoch === fixtureJob.epoch ? pending.promise : typedReply(message.job));
  h.job(); await flush(); h.job(next); await flush();
  assert.equal(h.cancellations.length, 1);
  assert.equal(h.asks.length, 2);
  pending.resolve(typedReply(fixtureJob)); await flush();
  assert.equal(h.results().length, 1);
  assert.equal(h.results()[0].result.epoch, next.epoch);
  h.job({...fixtureJob, requestId: 'e'.repeat(32)}); await flush();
  assert.equal(h.asks.length, 2);
  assert.equal(h.results().at(-1).result.code, 'failed-precondition');
  await h.close();
});

test('completed-ID memory is bounded without evicting a consumed ID', async () => {
  const h = harness(), pending = deferred();
  h.setAnswer(() => pending.promise);
  h.job(); await flush();
  for (let index = 0; index < 4095; index++) {
    h.job({...fixtureJob, requestId: index.toString(16).padStart(32, '0')});
  }
  h.job({...fixtureJob, requestId: 'f'.repeat(32)}); await flush();
  assert.equal(h.asks.length, 1);
  assert.equal(h.results().at(-1).result.code, 'failed-precondition');
  pending.resolve(typedReply(fixtureJob)); await flush();
  h.job(); await flush(); assert.equal(h.asks.length, 1);
  await h.close();
});

test('a missing content listener causes one uncertain result and no retry', async () => {
  const h = harness();
  h.setAnswer(async () => { throw new Error('private transport detail'); });
  h.job(); await flush();
  assert.equal(h.asks.length, 1);
  assert.equal(h.results().length, 1);
  assert.equal(h.results()[0].result.code, 'uncertain');
  assert.equal(JSON.stringify(h.results()).includes('private transport detail'), false);
  h.job(); await flush(); assert.equal(h.asks.length, 1);
  await h.close();
});
