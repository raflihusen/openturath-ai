import test from 'node:test';
import assert from 'node:assert/strict';
import {loadBackend} from './audit_harness.ts';

const call = async (api: any, body: any, method = 'POST') => {
  const out: any = {};
  const res = {status(c: number) { out.status = c; return res; }, send(b: any) { out.body = b; return res; }};
  await api.reportAuthFailure({method, body, ip: '203.0.113.9'}, res);
  return out;
};

test('laporan gagal login: hanya kode tetap yang disimpan, nilai liar menjadi unknown', async () => {
  const {api, db} = loadBackend();
  const r = await call(api, {platform: 'windows', stage: 'firebase-credential', code: 'invalid-credential',
    category: 'x@y.com <script>', appVersion: '1.0.85'});
  assert.equal(r.status, 204);
  const [doc] = [...db.docs.entries()].filter(([k]: any) => k.startsWith('auth_failure_stats/')).map(([, v]: any) => v);
  assert.equal(doc.code, 'invalid-credential');
  assert.equal(doc.stage, 'firebase-credential');
  assert.equal(doc.category, 'unknown');
  assert.equal(JSON.stringify(doc).includes('x@y.com'), false);
});

test('laporan gagal login: metode selain POST ditolak dan laju dibatasi 20 per jam per IP', async () => {
  const {api} = loadBackend();
  assert.equal((await call(api, {}, 'GET')).status, 405);
  let last: any;
  for (let i = 0; i < 21; i++) last = await call(api, {platform: 'windows', stage: 's', code: 'c'});
  assert.equal(last.status, 429);
});

const callDiag = async (api: any, body: any, method = 'POST', ip = '203.0.113.20') => {
  const out: any = {};
  const res = {status(c: number) { out.status = c; return res; }, send(b: any) { out.body = b; return res; }};
  await api.submitDiagnosticReport({method, body, ip}, res);
  return out;
};

test('laporan rinci: kode rujukan keluar, jejak langkah disamarkan, URL tanpa query', async () => {
  const {api, db} = loadBackend();
  const r = await callDiag(api, {
    platform: 'macos', stage: 'room-load', code: 'google-rejected', category: 'webview', appVersion: '1.0.85',
    page: 'https://accounts.google.com/signin/v2/challenge?token=abc&email=a@b.com#frag',
    flags: {sid_cookie: true, bad: 'x'},
    breadcrumbs: [{message: 'login a@b.com Bearer abc.def SID=zzz', category: 'action'}],
  });
  assert.equal(r.status, 200);
  assert.match(r.body.ref, /^OT-[0-9A-F]{6}$/);
  const doc: any = db.docs.get(`diagnostic_reports/${r.body.ref}`);
  assert.equal(doc.page, 'https://accounts.google.com/signin/v2/challenge');
  assert.deepEqual(doc.flags, {sid_cookie: true});
  const dump = JSON.stringify(doc);
  assert.equal(dump.includes('a@b.com'), false);
  assert.equal(dump.includes('abc.def'), false);
  assert.equal(dump.includes('zzz'), false);
});

test('laporan rinci: bukan POST ditolak dan laju 5 per jam per IP', async () => {
  const {api} = loadBackend();
  assert.equal((await callDiag(api, {}, 'GET')).status, 405);
  let last: any;
  for (let i = 0; i < 6; i++) last = await callDiag(api, {platform: 'ios', stage: 's', code: 'c'}, 'POST', '203.0.113.21');
  assert.equal(last.status, 429);
});
