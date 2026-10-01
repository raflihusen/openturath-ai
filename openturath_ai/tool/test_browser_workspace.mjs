import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
import { WorkspaceController } from '../public/workspace/controller.mjs';
import { canonicalWorkspace, notebookLink, redirectFallbackAllowed } from '../public/workspace/model.mjs';

const userA = { uid: 'alice', email: 'alice@example.test' };
const userB = { uid: 'bob', email: 'bob@example.test' };
const notebook = 'https://notebooklm.google.com/notebook/334e7b83-0e76-4787-a1d6-314642a35862';
test('the web.app alias uses the same Firebase origin without forwarding credentials', () => {
  const canonical = new URL(canonicalWorkspace('https://open-turath.web.app/workspace/?agent=fiqh_syafii&idToken=secret#auth=secret'));
  assert.equal(canonical.origin, 'https://open-turath.firebaseapp.com');
  assert.deepEqual([...canonical.searchParams.keys()], ['agent']);
  assert.equal(canonical.hash, '');
  assert.equal(canonicalWorkspace('https://open-turath.firebaseapp.com/workspace/'), null);
});
const deferred = () => { let resolve, reject; const promise = new Promise((a, b) => { resolve = a; reject = b; }); return { promise, resolve, reject }; };
function fixture(overrides = {}) {
  const calls = { login: 0, access: 0 };
  const adapter = {
    ensureProfile: async () => {}, signIn: async () => { calls.login++; },
    getAgentUrl: async () => { calls.access++; return { url: notebook }; },
    signOut: async () => {}, redeemCode: async () => ({ message: 'Akses aktif' }), ...overrides,
  };
  return { calls, controller: new WorkspaceController(adapter, () => {}) };
}
test('a persisted Firebase session resumes without opening Google login again', async () => {
  const { controller, calls } = fixture();
  await controller.sessionChanged(userA);
  await controller.signIn();
  await controller.openAgent('fiqh_syafii');
  assert.equal(calls.login, 0);
  assert.equal(calls.access, 1);
  assert.equal(new URL(controller.state.link).searchParams.get('authuser'), userA.email);
});
test('two rapid login presses dispatch exactly one OAuth request', async () => {
  const pending = deferred(); let count = 0;
  const { controller } = fixture({ signIn: async () => { count++; await pending.promise; } });
  await controller.sessionChanged(null);
  const first = controller.signIn();
  await controller.signIn();
  assert.equal(count, 1);
  pending.resolve(); await first;
});
test('a cancelled OAuth popup neither establishes a user nor invokes redirect retry', async () => {
  const error = { code: 'auth/popup-closed-by-user' };
  const { controller } = fixture({ signIn: async () => { throw error; } });
  await controller.sessionChanged(null); await controller.signIn();
  assert.equal(controller.state.user, null);
  assert.equal(controller.state.busy, false);
  assert.equal(redirectFallbackAllowed(error), false);
  assert.equal(redirectFallbackAllowed({ code: 'auth/unauthorized-domain' }), false);
  assert.equal(redirectFallbackAllowed({ code: 'auth/popup-blocked' }), true);
});
test('popup completion alone never claims the Firebase session is ready', async () => {
  const { controller } = fixture();
  await controller.sessionChanged(null); await controller.signIn();
  assert.equal(controller.state.phase, 'signed-out');
  assert.equal(controller.state.link, null);
});
test('an anonymous visitor cannot request a notebook URL', async () => {
  const { controller, calls } = fixture();
  await controller.sessionChanged(null); await controller.openAgent('fiqh_syafii');
  assert.equal(calls.access, 0);
});
test('server entitlement denial cannot yield a notebook link', async () => {
  const { controller } = fixture({ getAgentUrl: async () => { throw { code: 'functions/permission-denied' }; } });
  await controller.sessionChanged(userA); await controller.openAgent('fiqh_syafii');
  assert.equal(controller.state.link, null);
  assert.equal(controller.state.error.code, 'functions/permission-denied');
});
test('a delayed notebook response cannot survive logout', async () => {
  const pending = deferred();
  const { controller } = fixture({ getAgentUrl: () => pending.promise });
  await controller.sessionChanged(userA);
  const opening = controller.openAgent('fiqh_syafii');
  await controller.signOut(); pending.resolve({ url: notebook }); await opening;
  assert.equal(controller.state.link, null); assert.equal(controller.state.user, null);
});
test('a delayed response for account A cannot expose a link to account B', async () => {
  const pending = deferred();
  const { controller } = fixture({ getAgentUrl: () => pending.promise });
  await controller.sessionChanged(userA);
  const opening = controller.openAgent('fiqh_syafii');
  await controller.sessionChanged(userB); pending.resolve({ url: notebook }); await opening;
  assert.equal(controller.state.user.uid, userB.uid); assert.equal(controller.state.link, null);
});
test('a stale profile initialization cannot restore the old account', async () => {
  const pending = deferred();
  const { controller } = fixture({ ensureProfile: user => user.uid === userA.uid ? pending.promise : Promise.resolve() });
  const first = controller.sessionChanged(userA);
  await controller.sessionChanged(userB); pending.resolve(); await first;
  assert.equal(controller.state.user.uid, userB.uid); assert.equal(controller.state.phase, 'ready');
});
test('logout failure still hides a previously resolved notebook link', async () => {
  const { controller } = fixture({ signOut: async () => { throw new Error('offline'); } });
  await controller.sessionChanged(userA); await controller.openAgent('fiqh_syafii');
  assert.ok(controller.state.link); await controller.signOut();
  assert.equal(controller.state.link, null); assert.equal(controller.state.phase, 'logout-error');
});
test('a stale logout completion does not overwrite a newer session', async () => {
  const pending = deferred();
  const { controller } = fixture({ signOut: () => pending.promise });
  await controller.sessionChanged(userA);
  const exiting = controller.signOut(); await controller.sessionChanged(userB);
  pending.resolve(); await exiting;
  assert.equal(controller.state.user.uid, userB.uid);
});
test('credential-like query parameters and fragments are never forwarded to Google', () => {
  const link = new URL(notebookLink(notebook + '?idToken=secret&continue=https://evil.test#auth=secret', userA.email));
  assert.deepEqual([...link.searchParams.keys()], ['authuser']); assert.equal(link.hash, '');
});
const notebookPath = new URL(notebook).pathname;
for (const target of [`http://notebooklm.google.com${notebookPath}`, `https://notebooklm.google.com.evil.test${notebookPath}`, `https://user:pass@notebooklm.google.com${notebookPath}`, 'https://accounts.google.com/signin', 'javascript:alert(1)', `https://notebooklm.google.com:8443${notebookPath}`]) {
  test(`rejects unexpected notebook destination ${target}`, () => assert.throws(() => notebookLink(target)));
}
test('public catalog has every server entity and exposes no notebook IDs or URLs', () => {
  const raw = fs.readFileSync(new URL('../public/workspace/catalog.json', import.meta.url), 'utf8');
  const catalog = JSON.parse(raw);
  assert.equal(catalog.length, 24); assert.ok(catalog.some(item => item.aliases.includes('fiqh_syafii')));
  assert.equal(new Set(catalog.map(item => item.id)).size, catalog.length);
  assert.ok(!raw.includes('https://')); assert.ok(!/[a-f0-9]{8}(?:-[a-f0-9]{4}){3}-[a-f0-9]{12}/i.test(raw));
});
test('offline cache ignores OAuth helpers, authenticated APIs, external Google pages and requests with state', () => {
  const handlers = {};
  const self = { registration: { scope: 'https://open-turath.firebaseapp.com/workspace/' }, location: { origin: 'https://open-turath.firebaseapp.com' }, addEventListener: (name, handler) => { handlers[name] = handler; } };
  vm.runInNewContext(fs.readFileSync(new URL('../public/workspace/sw.js', import.meta.url), 'utf8'), { self, URL, Set });
  for (const url of ['https://open-turath.firebaseapp.com/__/auth/handler', 'https://open-turath.firebaseapp.com/workspace/?state=abc', 'https://us-central1-open-turath.cloudfunctions.net/getAgentUrl', notebook]) {
    let intercepted = false;
    handlers.fetch({ request: { url, method: 'GET' }, respondWith: () => { intercepted = true; } });
    assert.equal(intercepted, false, url);
  }
});
