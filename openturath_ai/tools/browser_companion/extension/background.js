'use strict';

// Google credentials remain in Chrome. The native host transports typed jobs only.
const NATIVE_HOST = 'com.openturath.browser_companion';
const ORIGINS = ['https://notebooklm.google.com', 'https://notebook.google.com'];
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const NONCE = /^[0-9a-f]{32}$/i;
const LOAD_TIMEOUT_MS = 45000;
const ASK_TIMEOUT_MS = 120000;
const activeJobs = new Map();
let nativePort = null;

const SAFE_CODES = new Set([
  'invalid-argument', 'unavailable', 'unauthenticated', 'account-mismatch',
  'failed-precondition', 'deadline-exceeded', 'uncertain', 'busy',
]);

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
      JSON.stringify(history).length > 250000)) {
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
    return ORIGINS.includes(url.origin) && !url.username && !url.password &&
      !url.hash && url.pathname.toLowerCase() === `/notebook/${job.notebookId.toLowerCase()}` &&
      url.searchParams.getAll('authuser').length === 1 &&
      url.searchParams.get('authuser') === job.email;
  } catch (_) {
    return false;
  }
}

function waitUntilLoaded(tabId, job) {
  return new Promise((resolve, reject) => {
    let finished = false;
    const cleanup = () => {
      clearTimeout(timer);
      chrome.tabs.onUpdated.removeListener(updated);
      chrome.tabs.onRemoved.removeListener(removed);
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
    const timer = setTimeout(() => settle(new Error('deadline-exceeded')), LOAD_TIMEOUT_MS);
    chrome.tabs.onUpdated.addListener(updated);
    chrome.tabs.onRemoved.addListener(removed);
    chrome.tabs.get(tabId).then(inspect, () => settle(new Error('unavailable')));
  });
}

async function notebookTab(job) {
  const tabs = await chrome.tabs.query({url: ORIGINS.map(origin => `${origin}/notebook/*`)});
  const existing = tabs.find(tab => !tab.incognito && notebookLocation(tab.url, job));
  const tab = existing || await chrome.tabs.create({
    url: `${ORIGINS[0]}/notebook/${job.notebookId}?authuser=${encodeURIComponent(job.email)}`,
    active: false,
  });
  if (!Number.isInteger(tab.id)) throw new Error('unavailable');
  return waitUntilLoaded(tab.id, job);
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
  if (activeJobs.has(job.requestId)) {
    // A duplicated delivery cannot generate a second NotebookLM request.
    return;
  }
  if ([...activeJobs.values()].some(entry =>
      entry.job.notebookId === job.notebookId && entry.job.email === job.email)) {
    sendResult(port, failure(job, 'busy'));
    return;
  }
  const entry = {job, port, tabId: null, dispatched: false};
  activeJobs.set(job.requestId, entry);
  let askTimer;
  try {
    const tab = await notebookTab(job);
    if (port !== nativePort || activeJobs.get(job.requestId) !== entry) return;
    const current = await chrome.tabs.get(tab.id);
    if (!notebookLocation(current.url, job)) throw new Error('unauthenticated');
    entry.tabId = tab.id;
    entry.dispatched = true;
    const response = await Promise.race([
      chrome.tabs.sendMessage(tab.id, {type: 'openturath:ask', job}, {frameId: 0}),
      new Promise((_resolve, reject) => {
        askTimer = setTimeout(() => reject(new Error('uncertain')), ASK_TIMEOUT_MS);
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
    if (entry.tabId != null) {
      chrome.tabs.sendMessage(entry.tabId, {
        type: 'openturath:cancel', requestId: job.requestId, epoch: job.epoch,
      }, {frameId: 0}).catch(() => {});
    }
  } finally {
    clearTimeout(askTimer);
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
      chrome.action.setBadgeText({text: message.code === 'ready' ? '' : '!'});
    }
  });
  port.onDisconnect.addListener(() => {
    // Read Chrome's error without logging it or any account data.
    void chrome.runtime.lastError;
    if (nativePort !== port) return;
    nativePort = null;
    for (const entry of activeJobs.values()) {
      if (entry.tabId != null) {
        chrome.tabs.sendMessage(entry.tabId, {
          type: 'openturath:cancel', requestId: entry.job.requestId, epoch: entry.job.epoch,
        }, {frameId: 0}).catch(() => {});
      }
    }
    activeJobs.clear();
    chrome.action.setBadgeText({text: '!'});
    // A user action or a fresh worker start may reconnect; chat is never replayed.
  });
  port.postMessage({type: 'connected', protocol: 1});
}

chrome.action.onClicked.addListener(connectToHost);
chrome.runtime.onStartup.addListener(connectToHost);
chrome.runtime.onInstalled.addListener(connectToHost);
connectToHost();
