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
