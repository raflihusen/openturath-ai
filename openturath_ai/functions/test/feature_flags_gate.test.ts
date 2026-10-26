import test from 'node:test';
import assert from 'node:assert/strict';
import {loadBackend, Stamp} from './audit_harness.ts';

const SOON = ['fiqh_tahawwulat_khatib', 'fiqh_tahawwulat_habib', 'fiqh_tahawwulat_mukhtabir'];
const OPEN = ['fiqh_tahawwulat', 'fiqh_tahawwulat_muhaqqiq', 'fiqh_tahawwulat_bayan'];
const caller = (uid = 'u') => ({auth: {uid, token: {email: `${uid}@example.test`, email_verified: true}}});
const paid = () => ({
  fiqh_tahawwulat: {plan: 'bahits_1y', status: 'active', expiry: new Stamp(Date.now() + 30 * 86400000)},
});

function fixture(user: Record<string, unknown> = {}) {
  const f = loadBackend();
  f.db.seed('users/u', {email: 'u@example.test', name: 'Pengguna', plan: 'trial', entitlements: paid(), ...user});
  return f;
}
const code = (e: any) => e?.code;

test('pelanggan Tahawwulat TIDAK bisa membuka tiga sub-AI "segera hadir" tanpa dokumen features', async () => {
  const {api} = fixture();
  for (const id of SOON) {
    await assert.rejects(api.getAgentUrl({agentId: id}, caller()), (e: any) => code(e) === 'failed-precondition', id);
  }
});

test('sub-AI lain dan induk Tahawwulat tetap terbuka bagi pelanggan', async () => {
  const {api} = fixture();
  for (const id of OPEN) {
    assert.ok((await api.getAgentUrl({agentId: id}, caller())).url, id);
  }
});

test('Fikih Syafi\'i tidak tersentuh gerbang ini', async () => {
  const {api} = fixture({entitlements: {fiqh_syafii: {plan: 'tholib_1m', status: 'active',
    expiry: new Stamp(Date.now() + 30 * 86400000)}}});
  assert.ok((await api.getAgentUrl({agentId: 'fiqh_syafii'}, caller())).url);
});

test('akun VIP sejati tetap bisa membuka (Aturan 5), dengan atau tanpa daftar', async () => {
  for (const vip of [{is_vip: true}, {role: 'vip'}, {email: 'prilatief@gmail.com'}]) {
    const {api} = fixture({entitlements: {}, ...vip});
    for (const id of SOON) {
      assert.ok((await api.getAgentUrl({agentId: id}, caller())).url, `${JSON.stringify(vip)} ${id}`);
    }
  }
});

test('dokumen features dengan daftar kosong membuka semua sub-AI (rilis penuh)', async () => {
  const {api, db} = fixture();
  db.seed('app_config/features', {soon_sub_agent_ids: [], introduction_enabled: true});
  for (const id of SOON) {
    assert.ok((await api.getAgentUrl({agentId: id}, caller())).url, id);
  }
});

test('dokumen features dapat menutup sub-AI lain, dan membuka yang tidak tercantum', async () => {
  const {api, db} = fixture();
  db.seed('app_config/features', {soon_sub_agent_ids: ['fiqh_tahawwulat_bayan']});
  await assert.rejects(api.getAgentUrl({agentId: 'fiqh_tahawwulat_bayan'}, caller()),
    (e: any) => code(e) === 'failed-precondition');
  assert.ok((await api.getAgentUrl({agentId: 'fiqh_tahawwulat_khatib'}, caller())).url);
});

test('dokumen rusak jatuh ke bawaan yang tertutup, bukan terbuka', async () => {
  for (const bad of [{soon_sub_agent_ids: 'fiqh_tahawwulat_khatib'}, {soon_sub_agent_ids: 7},
      {soon_sub_agent_ids: null}, {}, {introduction_enabled: true}]) {
    const {api, db} = fixture();
    db.seed('app_config/features', bad);
    await assert.rejects(api.getAgentUrl({agentId: 'fiqh_tahawwulat_khatib'}, caller()),
      (e: any) => code(e) === 'failed-precondition', JSON.stringify(bad));
  }
});

test('elemen daftar tidak valid dibuang tanpa menutup sub-AI lain', async () => {
  const {api, db} = fixture();
  db.seed('app_config/features', {soon_sub_agent_ids: ['fiqh_tahawwulat_habib', 42, null, 'Salah Format', 'a/b', '']});
  await assert.rejects(api.getAgentUrl({agentId: 'fiqh_tahawwulat_habib'}, caller()),
    (e: any) => code(e) === 'failed-precondition');
  assert.ok((await api.getAgentUrl({agentId: 'fiqh_tahawwulat_khatib'}, caller())).url);
});

test('daftar melewati batas dianggap salah ketik: kembali ke bawaan', async () => {
  const {api, db} = fixture();
  db.seed('app_config/features', {soon_sub_agent_ids: Array.from({length: 80}, (_, i) => `agent_${i}`)});
  await assert.rejects(api.getAgentUrl({agentId: 'fiqh_tahawwulat_khatib'}, caller()),
    (e: any) => code(e) === 'failed-precondition');
  assert.ok((await api.getAgentUrl({agentId: 'fiqh_tahawwulat_muhaqqiq'}, caller())).url);
});

test('kegagalan membaca dokumen tidak membuka sub-AI yang segera hadir', async () => {
  const {api, db} = fixture();
  const original = db.doc.bind(db);
  db.doc = (key: string) => {
    const ref = original(key);
    if (key === 'app_config/features') ref.get = async () => { throw new Error('firestore unavailable'); };
    return ref;
  };
  await assert.rejects(api.getAgentUrl({agentId: 'fiqh_tahawwulat_khatib'}, caller()),
    (e: any) => code(e) === 'failed-precondition');
  assert.ok((await api.getAgentUrl({agentId: 'fiqh_tahawwulat'}, caller())).url);
});

test('pembelian paket Tahawwulat induk tidak terpengaruh', async () => {
  const {api} = loadBackend();
  const offer = await api.resolvePlanPricing('fiqh_tahawwulat', 'tholib_1m');
  assert.equal(offer.entitlementKey, 'fiqh_tahawwulat');
  assert.equal(offer.amount, 300000);
});

// ---- askAgent (asisten native): gerbang yang sama ----
const bridgeEnv = ['NOTEBOOK_BRIDGE_TEST_UID', 'NOTEBOOK_BRIDGE_KEY', 'NOTEBOOK_BRIDGE_URL', 'FUNCTIONS_EMULATOR'];
async function withBridge(run: (h: ReturnType<typeof loadBackend>, ctx: any) => Promise<void>) {
  const previous = Object.fromEntries(bridgeEnv.map(n => [n, process.env[n]]));
  Object.assign(process.env, {NOTEBOOK_BRIDGE_TEST_UID: 'u', NOTEBOOK_BRIDGE_KEY: 'k'.repeat(32),
    NOTEBOOK_BRIDGE_URL: 'http://127.0.0.1:8794/ask', FUNCTIONS_EMULATOR: 'true'});
  try {
    const h = loadBackend();
    const context = {auth: {uid: 'u'}, rawRequest: {headers: {authorization: 'Bearer fixture-token'}}};
    await run(h, context);
  } finally {
    for (const n of bridgeEnv) previous[n] === undefined ? delete process.env[n] : process.env[n] = previous[n];
  }
}
const ask = (agentId: string) => ({agentId, question: 'Apa itu fikih?', requestId: 'a'.repeat(32), expectedUid: 'u'});
const reply = {requestId: 'a'.repeat(32), answer: 'Jawaban', citations: []};

test('askAgent menolak sub-AI "segera hadir" walau pengguna berlangganan Tahawwulat', async () => {
  await withBridge(async ({api, db, axios, sent}, ctx) => {
    db.seed('users/u', {email: 'u@example.test', entitlements: paid()});
    axios.post = async (...args: any[]) => { sent.push(args); return {data: reply}; };
    for (const id of SOON) {
      await assert.rejects(api.askAgent(ask(id), ctx), (e: any) => code(e) === 'permission-denied', id);
    }
    assert.equal(sent.length, 0, 'tidak boleh ada permintaan ke jembatan');
  });
});

test('askAgent tetap melayani sub-AI yang terbuka', async () => {
  await withBridge(async ({api, db, axios, sent}, ctx) => {
    db.seed('users/u', {email: 'u@example.test', entitlements: paid()});
    axios.post = async (...args: any[]) => { sent.push(args); return {data: reply}; };
    const result = await api.askAgent(ask('fiqh_tahawwulat_muhaqqiq'), ctx);
    assert.equal(JSON.parse(JSON.stringify(result)).answer, 'Jawaban');
    assert.equal(sent.length, 1);
  });
});

test('askAgent: VIP sejati tidak ditolak oleh gerbang segera hadir', async () => {
  await withBridge(async ({api, db, axios, sent}, ctx) => {
    db.seed('users/u', {email: 'u@example.test', is_vip: true, entitlements: {}});
    axios.post = async (...args: any[]) => { sent.push(args); return {data: reply}; };
    await api.askAgent(ask('fiqh_tahawwulat_khatib'), ctx);
    assert.equal(sent.length, 1);
  });
});
