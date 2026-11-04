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

const callDiag = async (api: any, body: any, method = 'POST', ip = '203.0.113.20', headers = {}) => {
  const out: any = {};
  const res = {status(c: number) { out.status = c; return res; }, send(b: any) { out.body = b; return res; }};
  await api.submitDiagnosticReport({method, body, ip, headers}, res);
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

test('halaman login Google dicatat sebagai fase dan tidak dihitung gagal login', async () => {
  const f = loadBackend();
  await call(f.api, {platform:'android',stage:'room-load',code:'google-auth-page',category:'webview',appVersion:'1.0.87'});
  assert.equal([...f.db.docs.keys()].filter(k=>k.startsWith('auth_failure_stats/')).length,0);
  assert.equal([...f.db.docs.keys()].filter(k=>k.startsWith('auth_flow_stats/')).length,1);
  assert.equal(f.sent.length,0);
});

test('statistik baru memisahkan build sehingga versi lama tidak menimpa versi kejadian', async () => {
  const f=loadBackend();
  for(const buildNumber of ['89','90']) await call(f.api,{schema_version:2,platform:'android',stage:'room-load',code:'not-ready-timeout',category:'webview',appVersion:'1.0.87',buildNumber,edition:'standard'});
  const docs=[...f.db.docs.entries()].filter(([k])=>k.startsWith('auth_failure_stats_v2/')).map(([,v])=>v);
  assert.equal(docs.length,2);
  assert.deepEqual(new Set(docs.map(d=>d.buildNumber)),new Set(['89','90']));
});

const detailed = {schema_version:2,platform:'android',stage:'agent-url',code:'failed-precondition',category:'webview',appVersion:'1.0.87',buildNumber:'89',edition:'standard',attempt_id:'a'.repeat(32),event_id:'b'.repeat(32),agent_id:'fiqh_syafii',reason:'access_provisioning',request_id:'11111111-2222-4333-8444-555555555555'};

test('metadata memiliki bentuk terbatas dan skema navigasi tetap teramati', async()=>{
  const f=loadBackend();
  const r=await callDiag(f.api,{...detailed,buildNumber:'private.token.value',
    edition:'private.token.value',attempt_id:'private.token.value',event_id:'private.token.value',
    request_id:'private.token.value',reason:'private.token.value',page_scheme:'intent'});
  const d=f.db.docs.get(`diagnostic_reports/${r.body.ref}`);
  assert.equal(JSON.stringify(d).includes('private.token.value'),false);
  assert.equal(d.page_scheme,'intent');
});

test('alasan berbeda tidak saling menimpa dalam statistik baru', async()=>{
  const f=loadBackend();
  for(const reason of ['access_provisioning','legacy_review']) await call(f.api,{...detailed,reason});
  const docs=[...f.db.docs.entries()].filter(([k])=>k.startsWith('auth_failure_stats_v2/')).map(([,v])=>v);
  assert.equal(docs.length,2);
  assert.deepEqual(new Set(docs.map(d=>d.reason)),new Set(['access_provisioning','legacy_review']));
});

test('server menyamarkan segmen alamat email dalam URL klien lama', async()=>{
  const f=loadBackend();
  const r=await callDiag(f.api,{...detailed,page:'https://accounts.google.com/user/reader%40example.invalid?token=secret'});
  const d=f.db.docs.get(`diagnostic_reports/${r.body.ref}`);
  assert.equal(d.page.includes('reader'),false);
  assert.equal(d.page.includes('secret'),false);
});

test('laporan baru mempertahankan konteks sebelum URL diterima tanpa mengarang halaman',async()=>{
  const f=loadBackend(),r=await callDiag(f.api,detailed);
  const d=f.db.docs.get(`diagnostic_reports/${r.body.ref}`);
  assert.equal(d.schema_version,2);
  assert.equal(d.buildNumber,'89');assert.equal(d.agent_id,'fiqh_syafii');
  assert.equal(d.reason,'access_provisioning');assert.equal(d.attempt_id,detailed.attempt_id);
  assert.equal(d.request_id,detailed.request_id);assert.equal(d.page,'unknown');
});

test('pengiriman ulang event yang sama mengembalikan tiket yang sama',async()=>{
  const f=loadBackend();
  const a=await callDiag(f.api,detailed),b=await callDiag(f.api,detailed);
  assert.equal(a.body.ref,b.body.ref);
  assert.equal([...f.db.docs.keys()].filter(k=>k.startsWith('diagnostic_reports/')).length,1);
});

test('identitas tiket berasal dari token terverifikasi dan bukan klaim body',async()=>{
  const f=loadBackend();
  const r=await callDiag(f.api,{...detailed,uid:'forged-owner',is_vip:true},'POST','203.0.113.20',{authorization:'Bearer fixture-token'});
  const d=f.db.docs.get(`diagnostic_reports/${r.body.ref}`);
  assert.equal(d.owner_uid,'u');assert.equal(d.auth_context,'verified');
  assert.equal(JSON.stringify(d).includes('fixture-token'),false);
  assert.equal(JSON.stringify(d).includes('forged-owner'),false);
});

test('token invalid tidak mengarang owner dan tetap mendukung laporan anonim',async()=>{
  const f=loadBackend();f.auth.verifyIdToken=async()=>{throw Error('invalid fixture token');};
  const r=await callDiag(f.api,{...detailed,uid:'forged-owner'},'POST','203.0.113.20',{authorization:'Bearer invalid-fixture'});
  assert.equal(r.status,200);
  const d=f.db.docs.get(`diagnostic_reports/${r.body.ref}`);
  assert.equal(d.owner_uid,undefined);assert.equal(d.auth_context,'unverified');
});
