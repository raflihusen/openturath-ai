import test from 'node:test';
import assert from 'node:assert/strict';
import {createRequire} from 'node:module';

const require = createRequire(import.meta.url);
const {handleNativeChat, parseChatReply} = require('../lib/native_chat.js');
const request = {agentId: 'fiqh_syafii', question: 'Pertanyaan uji', requestId: 'a'.repeat(32), expectedUid: 'reader'};
const reply = {requestId: request.requestId, answer: 'Jawaban fixture [1]', citations: [
  {sourceId: '11111111-1111-1111-1111-111111111111', citationNumber: 1, excerpt: 'Kutipan fixture'},
]};

function fixture() {
  const calls: any[] = [];
  const deps = {
    testUid: 'reader',
    authorize: async (...args: any[]) => {calls.push(['authorize', ...args]); return true;},
    rateLimit: async (...args: any[]) => {calls.push(['rate', ...args]);},
    ask: async (...args: any[]) => {calls.push(['ask', ...args]); return reply;},
  };
  return {deps, calls};
}

test('unauthenticated requests never call the operator bridge', async () => {
  const {deps, calls} = fixture();
  await assert.rejects(handleNativeChat(request, undefined, deps), {code: 'unauthenticated'});
  assert.deepEqual(calls, []);
});
test('identity changes before sending are rejected', async () => {
  const {deps, calls} = fixture();
  await assert.rejects(handleNativeChat(request, 'other', deps), {code: 'unauthenticated'});
  assert.deepEqual(calls, []);
});
test('prototype is disabled without explicit test user configuration', async () => {
  const {deps, calls} = fixture();
  deps.testUid = '';
  await assert.rejects(handleNativeChat(request, 'reader', deps), {code: 'failed-precondition'});
  assert.deepEqual(calls, []);
});
test('an unapproved prototype user cannot reach the bridge', async () => {
  const {deps, calls} = fixture();
  await assert.rejects(handleNativeChat({...request, expectedUid: 'other'}, 'other', deps), {code: 'permission-denied'});
  assert.deepEqual(calls, []);
});
test('inactive entitlement blocks chat before rate-limit or Google calls', async () => {
  const {deps, calls} = fixture();
  deps.authorize = async () => false;
  await assert.rejects(handleNativeChat(request, 'reader', deps), {code: 'permission-denied'});
  assert.deepEqual(calls, []);
});
test('client cannot select an upstream notebook, operator or conversation', async () => {
  for (const key of ['uid', 'notebookId', 'conversationId', 'session', 'url']) {
    const {deps, calls} = fixture();
    await assert.rejects(handleNativeChat({...request, [key]: 'injected'}, 'reader', deps), {code: 'invalid-argument'});
    assert.deepEqual(calls, []);
  }
});
test('malformed and oversized questions do not reach the bridge', async () => {
  for (const data of [null, [], {...request, question: ' '}, {...request, question: 'x'.repeat(8001)},
    {...request, requestId: '../../path'}, {...request, agentId: '../agent'}]) {
    const {deps, calls} = fixture();
    await assert.rejects(handleNativeChat(data, 'reader', deps), {code: 'invalid-argument'});
    assert.deepEqual(calls, []);
  }
});
test('success passes only verified identity and strips upstream secrets', async () => {
  const {deps, calls} = fixture();
  deps.ask = async (...args: any[]) => {calls.push(['ask', ...args]); return {...reply,
    session: 'secret-fixture', conversationId: 'internal', raw_response: 'debug'};};
  assert.deepEqual(await handleNativeChat(request, 'reader', deps), reply);
  assert.equal(calls[2][1].uid, 'reader');
  assert.equal('expectedUid' in calls[2][1], false);
  assert.deepEqual(calls.map(item => item[0]), ['authorize', 'rate', 'ask']);
});
test('rate-limited requests do not ask Google', async () => {
  const {deps, calls} = fixture();
  deps.rateLimit = async () => {throw new Error('limited');};
  await assert.rejects(handleNativeChat(request, 'reader', deps));
  assert.equal(calls.some(item => item[0] === 'ask'), false);
});
test('upstream exceptions are sanitized and are never automatically retried', async () => {
  const {deps} = fixture();
  let asks = 0;
  deps.ask = async () => {asks++; throw new Error('Bearer secret-fixture');};
  await assert.rejects(handleNativeChat(request, 'reader', deps), (error: any) =>
    error.code === 'unavailable' && !error.message.includes('secret-fixture'));
  assert.equal(asks, 1);
});
test('wrong request IDs, empty answers and invalid citations fail closed', () => {
  for (const value of [null, {...reply, requestId: 'b'.repeat(32)}, {...reply, answer: ''},
    {...reply, citations: [{sourceId: 'bad', citationNumber: 1, excerpt: null}]},
    {...reply, citations: [{...reply.citations[0], citationNumber: -1}]}]) {
    assert.throws(() => parseChatReply(value, request.requestId), {code: 'unavailable'});
  }
});
