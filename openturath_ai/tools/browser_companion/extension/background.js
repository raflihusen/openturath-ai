'use strict';

// Google credentials remain in Chrome. The native host transports typed jobs only.
const NATIVE_HOST = 'com.openturath.browser_companion';
const ORIGINS = ['https://notebooklm.google.com', 'https://notebook.google.com'];
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const NONCE = /^[0-9a-f]{32}$/i;
const LOAD_TIMEOUT_MS = 45000;
const ASK_TIMEOUT_MS = 120000;
const activeJobs = new Map();
const seenRequestIds = new Set();
const retiredEpochs = new Set();
const MAX_SEEN_REQUESTS = 4096;
const MAX_RETIRED_EPOCHS = 64;
let currentEpoch = null;
let nativePort = null;

const SAFE_CODES = new Set([
  'invalid-argument', 'unavailable', 'unauthenticated', 'account-mismatch',
  'failed-precondition', 'deadline-exceeded', 'uncertain', 'busy',
]);

// Match Chrome's known errors; never retain or print the source message.
const NATIVE_ERROR_CODES = new Map([
  ['Specified native messaging host not found.', 'host-not-found'],
  ['Native host has exited.', 'host-exited'],
  ['Failed to start native messaging host.', 'host-exited'],
  ['Access to the specified native messaging host is forbidden.', 'forbidden'],
  ['Error when communicating with the native messaging host.', 'invalid-response'],
]);
const NATIVE_ERROR_TITLES = Object.freeze({
  'host-not-found': 'Penghubung OpenTurath belum terpasang.',
  'host-exited': 'Penghubung OpenTurath berhenti atau belum dapat berjalan.',
  'forbidden': 'Chrome menolak akses penghubung OpenTurath.',
  'invalid-response': 'Pesan penghubung OpenTurath tidak dapat dibaca.',
  'unknown': 'Koneksi penghubung OpenTurath terputus.',
});

function nativeErrorCode(error) {
  return typeof error?.message === 'string'
    ? (NATIVE_ERROR_CODES.get(error.message) || 'unknown') : 'unknown';
}

function showNativeDiagnostic(code) {
  chrome.action.setTitle({title: NATIVE_ERROR_TITLES[code]});
  console.warn(`OpenTurath Browser Companion: ${code}`);
}

function validEmail(value) {
  return typeof value === 'string' && value.length <= 320 &&
    value === value.toLowerCase() && /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value);
}

function validateJob(raw) {
  if (!raw || typeof raw !== 'object' || Array.isArray(raw) ||
      !NONCE.test(raw.requestId || '') || !NONCE.test(raw.epoch || '') ||
      typeof raw.uid !== 'string' || !raw.uid || raw.uid.length > 128 ||
      typeof raw.googleSub !== 'string' || !/^\d{1,64}$/.test(raw.googleSub) ||
      !validEmail(raw.email) || typeof raw.notebookId !== 'string' ||
      !UUID.test(raw.notebookId) || typeof raw.question !== 'string' ||
      !raw.question.trim() || raw.question.length > 8000 ||
      !(raw.conversationId == null ||
        (typeof raw.conversationId === 'string' && UUID.test(raw.conversationId)))) {
    throw new Error('invalid-argument');
  }
  const history = raw.history == null ? null : raw.history;
  if (history !== null && (!Array.isArray(history) || history.length > 80 ||
      history.some(turn => !Array.isArray(turn) || turn.length !== 3 ||
        typeof turn[0] !== 'string' || turn[0].length > 128000 ||
        turn[1] !== null || ![1, 2].includes(turn[2])) ||
      JSON.stringify(history).length > 120000)) {
    throw new Error('invalid-argument');
  }
  return {
    requestId: raw.requestId, epoch: raw.epoch, uid: raw.uid,
    googleSub: raw.googleSub, email: raw.email, notebookId: raw.notebookId,
    question: raw.question, history, conversationId: raw.conversationId ?? null,
  };
}

function tuple(job) {
  return {
    requestId: job.requestId, epoch: job.epoch, uid: job.uid,
    googleSub: job.googleSub, email: job.email, notebookId: job.notebookId,
  };
}

function failure(job, code) {
  return {
    ...tuple(job), answer: '', citations: [], conversationId: null,
    code: SAFE_CODES.has(code) ? code : 'failed-precondition',
  };
}

function notebookLocation(rawUrl, job) {
  try {
    const url = new URL(rawUrl);
    const hints = url.searchParams.getAll('authuser');
    // Google may replace the email hint with an account index after redirect.
    // The content protocol still verifies the observed email before any RPC.
    const validHint = hints.length === 0 || (hints.length === 1 &&
      (hints[0] === job.email || /^(0|[1-9]\d{0,2})$/.test(hints[0])));
    return ORIGINS.includes(url.origin) && !url.username && !url.password &&
      !url.hash && url.pathname.toLowerCase() === `/notebook/${job.notebookId.toLowerCase()}` &&
      validHint;
  } catch (_) {
    return false;
  }
}

function waitUntilLoaded(tabId, job, signal) {
  return new Promise((resolve, reject) => {
    let finished = false;
    const cleanup = () => {
      clearTimeout(timer);
      chrome.tabs.onUpdated.removeListener(updated);
      chrome.tabs.onRemoved.removeListener(removed);
      signal.removeEventListener('abort', aborted);
    };
    const settle = (error, tab) => {
      if (finished) return;
      finished = true;
      cleanup();
      if (error) reject(error);
      else resolve(tab);
    };
    const inspect = tab => {
      if (tab.status !== 'complete') return;
      settle(notebookLocation(tab.url, job) ? null : new Error('unauthenticated'), tab);
    };
    const updated = (changedId, _changes, tab) => {
      if (changedId === tabId) inspect(tab);
    };
    const removed = removedId => {
      if (removedId === tabId) settle(new Error('unavailable'));
    };
    const aborted = () => settle(new Error('unavailable'));
    const timer = setTimeout(() => settle(new Error('deadline-exceeded')), LOAD_TIMEOUT_MS);
    chrome.tabs.onUpdated.addListener(updated);
    chrome.tabs.onRemoved.addListener(removed);
    signal.addEventListener('abort', aborted, {once: true});
    if (signal.aborted) { aborted(); return; }
    chrome.tabs.get(tabId).then(inspect, () => settle(new Error('unavailable')));
  });
}

async function notebookTab(job, signal) {
  const tabs = await chrome.tabs.query({url: ORIGINS.map(origin => `${origin}/notebook/*`)});
  if (signal.aborted) throw new Error('unavailable');
  // An indexed existing tab may belong to another signed-in Google account.
  // Reuse only an explicit matching email; otherwise navigate with our hint.
  const existing = tabs.find(tab => !tab.incognito && notebookLocation(tab.url, job) &&
    new URL(tab.url).searchParams.get('authuser') === job.email);
  const tab = existing || await chrome.tabs.create({
    url: `${ORIGINS[0]}/notebook/${job.notebookId}?authuser=${encodeURIComponent(job.email)}`,
    active: false,
  });
  if (!Number.isInteger(tab.id)) throw new Error('unavailable');
  return waitUntilLoaded(tab.id, job, signal);
}

function cancelEntry(entry) {
  if (activeJobs.get(entry.job.requestId) !== entry) return;
  // Remove first: a response already queued by Chrome must not cross the bridge.
  activeJobs.delete(entry.job.requestId);
  entry.controller.abort();
  clearTimeout(entry.askTimer);
  if (entry.tabId != null) {
    chrome.tabs.sendMessage(entry.tabId, {
      type: 'openturath:cancel', requestId: entry.job.requestId, epoch: entry.job.epoch,
    }, {frameId: 0}).catch(() => {});
  }
}

function cancelJobs({requestId, epoch} = {}) {
  for (const entry of [...activeJobs.values()]) {
    if ((requestId == null || entry.job.requestId === requestId) &&
        (epoch == null || entry.job.epoch === epoch)) cancelEntry(entry);
  }
}

function rememberJob(job, port) {
  if (job.epoch !== currentEpoch) {
    if (retiredEpochs.has(job.epoch) || retiredEpochs.size >= MAX_RETIRED_EPOCHS) {
      sendResult(port, failure(job, 'failed-precondition'));
      return false;
    }
    if (currentEpoch != null) retiredEpochs.add(currentEpoch);
    cancelJobs();
    currentEpoch = job.epoch;
    seenRequestIds.clear();
  }
  if (seenRequestIds.has(job.requestId)) return false;
  // Fail closed at the bound; evicting IDs could permit a duplicated delivery.
  if (seenRequestIds.size >= MAX_SEEN_REQUESTS) {
    sendResult(port, failure(job, 'failed-precondition'));
    return false;
  }
  seenRequestIds.add(job.requestId);
  return true;
}

function handleState(message) {
  if (message.epoch != null && (typeof message.epoch !== 'string' ||
      !NONCE.test(message.epoch) || (currentEpoch != null && message.epoch !== currentEpoch))) return;
  const uncertain = message.status === 'uncertain' || message.code === 'uncertain';
  if (uncertain) {
    if (message.requestId == null) cancelJobs({epoch: message.epoch});
    else if (typeof message.requestId === 'string' && NONCE.test(message.requestId)) {
      cancelJobs({requestId: message.requestId, epoch: message.epoch});
    }
  }
  if (message.status === 'waiting' || message.status === 'disconnected') {
    cancelJobs({epoch: message.epoch});
  }
  chrome.action.setBadgeText({
    text: message.status === 'connected' || message.code === 'ready' ? '' : '!',
  });
  if (message.status === 'connected' || message.code === 'ready') {
    chrome.action.setTitle({title: 'Hubungkan OpenTurath'});
  }
}

function validateResult(raw, job) {
  if (!raw || typeof raw !== 'object' ||
      Object.entries(tuple(job)).some(([key, value]) => raw[key] !== value)) {
    return failure(job, 'uncertain');
  }
  if (raw.code != null) return failure(job, raw.code);
  if (typeof raw.answer !== 'string' || !raw.answer.trim() || raw.answer.length > 128000 ||
      !Array.isArray(raw.citations) || raw.citations.length > 100 ||
      typeof raw.conversationId !== 'string' || !UUID.test(raw.conversationId) ||
      raw.accountEmail !== job.email) {
    return failure(job, 'failed-precondition');
  }
  const citations = [];
  for (const citation of raw.citations) {
    if (!citation || typeof citation.sourceId !== 'string' || !UUID.test(citation.sourceId) ||
        !Number.isInteger(citation.citationNumber) || citation.citationNumber < 1 ||
        citation.citationNumber > 1000 ||
        !(citation.excerpt == null ||
          (typeof citation.excerpt === 'string' && citation.excerpt.length <= 4000))) {
      return failure(job, 'failed-precondition');
    }
    citations.push({
      sourceId: citation.sourceId, citationNumber: citation.citationNumber,
      excerpt: citation.excerpt ?? null,
    });
  }
  const result = {
    ...tuple(job), answer: raw.answer, citations,
    conversationId: raw.conversationId, accountEmail: raw.accountEmail,
  };
  return new TextEncoder().encode(JSON.stringify(result)).length <= 900000
    ? result : failure(job, 'failed-precondition');
}

function sendResult(port, result) {
  if (port !== nativePort) return;
  try {
    port.postMessage({type: 'result', result});
  } catch (_) {
    // The native side treats a lost transport as uncertain; never replay a job.
  }
}

async function executeJob(raw, port) {
  let job;
  try {
    job = validateJob(raw);
  } catch (_) {
    // Echo only a valid correlation tuple, never arbitrary fields from a bad job.
    try {
      const safe = validateJob({...raw, question: 'invalid', history: null, conversationId: null});
      sendResult(port, failure(safe, 'invalid-argument'));
    } catch (_) { /* A malformed envelope cannot safely be correlated. */ }
    return;
  }
  // A validated ID is consumed even when execution fails or ownership is revoked.
  // This survives reconnect within the worker; the native ledger survives restart.
  if (!rememberJob(job, port)) return;
  if ([...activeJobs.values()].some(entry =>
      entry.job.notebookId === job.notebookId && entry.job.email === job.email)) {
    sendResult(port, failure(job, 'busy'));
    return;
  }
  const entry = {job, port, tabId: null, dispatched: false,
    controller: new AbortController(), askTimer: null};
  activeJobs.set(job.requestId, entry);
  try {
    const tab = await notebookTab(job, entry.controller.signal);
    if (port !== nativePort || activeJobs.get(job.requestId) !== entry) return;
    entry.tabId = tab.id;
    const current = await chrome.tabs.get(tab.id);
    if (port !== nativePort || activeJobs.get(job.requestId) !== entry ||
        entry.controller.signal.aborted) return;
    if (!notebookLocation(current.url, job)) throw new Error('unauthenticated');
    entry.dispatched = true;
    const response = await Promise.race([
      chrome.tabs.sendMessage(tab.id, {type: 'openturath:ask', job}, {frameId: 0}),
      new Promise((_resolve, reject) => {
        entry.askTimer = setTimeout(() => reject(new Error('uncertain')), ASK_TIMEOUT_MS);
      }),
    ]);
    if (activeJobs.get(job.requestId) === entry) sendResult(port, validateResult(response, job));
  } catch (error) {
    if (activeJobs.get(job.requestId) === entry) {
      // Once dispatched, a transport error cannot prove whether the request ran.
      const code = entry.dispatched ? 'uncertain' :
        (SAFE_CODES.has(error?.message) ? error.message : 'unavailable');
      sendResult(port, failure(job, code));
    }
    cancelEntry(entry);
  } finally {
    clearTimeout(entry.askTimer);
    if (activeJobs.get(job.requestId) === entry) activeJobs.delete(job.requestId);
  }
}

function connectToHost() {
  if (nativePort) return;
  let port;
  try {
    port = chrome.runtime.connectNative(NATIVE_HOST);
  } catch (_) {
    chrome.action.setBadgeText({text: '!'});
    return;
  }
  nativePort = port;
  port.onMessage.addListener(message => {
    if (nativePort !== port || !message || typeof message !== 'object') return;
    if (message.type === 'job') void executeJob(message.job, port);
    if (message.type === 'state') {
      handleState(message);
    }
  });
  port.onDisconnect.addListener(() => {
    // Consume lastError inside its callback; only a static category may escape.
    const code = nativeErrorCode(chrome.runtime.lastError);
    if (nativePort !== port) return;
    nativePort = null;
    cancelJobs();
    chrome.action.setBadgeText({text: '!'});
    showNativeDiagnostic(code);
    // A user action or a fresh worker start may reconnect; chat is never replayed.
  });
  port.postMessage({type: 'connected', protocol: 1});
}

chrome.action.onClicked.addListener(connectToHost);
chrome.runtime.onStartup.addListener(connectToHost);
chrome.runtime.onInstalled.addListener(connectToHost);
connectToHost();
