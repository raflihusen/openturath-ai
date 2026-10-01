'use strict';

(() => {
  // This script and notebook_protocol.js run in Chrome's isolated content world.
  // Only a normalized answer can cross the native boundary; no page HTML or tokens do.
  const ORIGINS = new Set(['https://notebooklm.google.com', 'https://notebook.google.com']);
  const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
  const NONCE = /^[0-9a-f]{32}$/i;
  const active = new Map();
  const fetchImpl = globalThis.fetch.bind(globalThis);
  const errorCodes = Object.freeze({
    INVALID_INPUT: 'invalid-argument',
    INVALID_ORIGIN: 'failed-precondition',
    BOOTSTRAP_INVALID: 'failed-precondition',
    ACCOUNT_UNVERIFIED: 'unauthenticated',
    ACCOUNT_MISMATCH: 'account-mismatch',
    SESSION_REQUIRED: 'unauthenticated',
    RESPONSE_TOO_LARGE: 'failed-precondition',
    PROTOCOL_CHANGED: 'failed-precondition',
    RPC_REJECTED: 'failed-precondition',
    RATE_LIMITED: 'unavailable',
    FOREIGN_REFERENCE: 'failed-precondition',
    EMPTY_ANSWER: 'failed-precondition',
    NETWORK_FAILURE: 'unavailable',
    REQUEST_CANCELLED: 'uncertain',
    REQUEST_UNCERTAIN: 'uncertain',
    CONVERSATION_UNVERIFIED: 'failed-precondition',
  });

  function tuple(job) {
    return {
      requestId: job.requestId, epoch: job.epoch, uid: job.uid,
      // This sub is request correlation. The protocol verifies observed email.
      googleSub: job.googleSub, email: job.email, notebookId: job.notebookId,
    };
  }

  function failure(job, code) {
    return {...tuple(job), answer: '', citations: [], conversationId: null, code};
  }

  function validJob(job) {
    if (!job || typeof job !== 'object' || Array.isArray(job) ||
        typeof job.requestId !== 'string' || !NONCE.test(job.requestId) ||
        typeof job.epoch !== 'string' || !NONCE.test(job.epoch) ||
        typeof job.uid !== 'string' || !job.uid || job.uid.length > 128 ||
        typeof job.googleSub !== 'string' || !/^\d{1,64}$/.test(job.googleSub) ||
        typeof job.email !== 'string' || job.email.length > 320 ||
        job.email !== job.email.toLowerCase() || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(job.email) ||
        typeof job.notebookId !== 'string' || !UUID.test(job.notebookId) ||
        typeof job.question !== 'string' || !job.question.trim() || job.question.length > 8000 ||
        !(job.conversationId == null ||
          (typeof job.conversationId === 'string' && UUID.test(job.conversationId)))) return false;
    if (job.history == null) return true;
    return Array.isArray(job.history) && job.history.length <= 80 &&
      job.history.every(turn => Array.isArray(turn) && turn.length === 3 &&
        typeof turn[0] === 'string' && turn[0].length <= 128000 &&
        turn[1] === null && [1, 2].includes(turn[2])) &&
      JSON.stringify(job.history).length <= 120000;
  }

  function currentNotebook(job) {
    const url = new URL(location.href);
    return window === window.top && ORIGINS.has(url.origin) &&
      !url.username && !url.password && !url.hash &&
      url.pathname.toLowerCase() === `/notebook/${job.notebookId.toLowerCase()}` &&
      url.searchParams.getAll('authuser').length === 1 &&
      url.searchParams.get('authuser') === job.email;
  }

  function normalizeReply(reply, job) {
    if (!reply || typeof reply !== 'object' ||
        typeof reply.answer !== 'string' || !reply.answer.trim() || reply.answer.length > 128000 ||
        !Array.isArray(reply.citations) || reply.citations.length > 100 ||
        typeof reply.conversationId !== 'string' || !UUID.test(reply.conversationId) ||
        reply.accountEmail !== job.email) return failure(job, 'failed-precondition');
    const citations = [];
    for (const citation of reply.citations) {
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
      ...tuple(job), answer: reply.answer, citations,
      conversationId: reply.conversationId, accountEmail: reply.accountEmail,
    };
    return new TextEncoder().encode(JSON.stringify(result)).length <= 900000
      ? result : failure(job, 'failed-precondition');
  }

  async function ask(job) {
    if (!validJob(job)) return failure(job || {}, 'invalid-argument');
    if (!currentNotebook(job)) return failure(job, 'unauthenticated');
    if (active.size) return failure(job, 'busy');
    const protocol = globalThis.OpenTurathNotebookProtocol;
    if (!protocol || typeof protocol.performAsk !== 'function') {
      return failure(job, 'failed-precondition');
    }
    const controller = new AbortController();
    const entry = {epoch: job.epoch, controller};
    active.set(job.requestId, entry);
    const timer = setTimeout(() => controller.abort(), 120000);
    try {
      const reply = await protocol.performAsk({
        origin: location.origin, notebookId: job.notebookId, email: job.email,
        question: job.question, history: job.history ?? null,
        conversationId: job.conversationId ?? null,
        fetchImpl, signal: controller.signal,
      });
      if (controller.signal.aborted || !currentNotebook(job)) {
        return failure(job, 'uncertain');
      }
      return normalizeReply(reply, job);
    } catch (error) {
      const code = error?.uncertain === true ? 'uncertain' :
        (errorCodes[error?.code] || 'failed-precondition');
      return failure(job, code);
    } finally {
      clearTimeout(timer);
      if (active.get(job.requestId) === entry) active.delete(job.requestId);
    }
  }

  chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
    if (sender.id !== chrome.runtime.id || !message || typeof message !== 'object') return false;
    if (message.type === 'openturath:cancel') {
      const entry = active.get(message.requestId);
      if (entry && message.epoch === entry.epoch) entry.controller.abort();
      return false;
    }
    if (message.type !== 'openturath:ask') return false;
    ask(message.job).then(sendResponse, () => {
      sendResponse(failure(message.job || {}, 'uncertain'));
    });
    return true;
  });
})();
