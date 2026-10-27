import test from 'node:test';
import assert from 'node:assert/strict';
import {loadBackend, Stamp} from './audit_harness.ts';

const DAY = 86400000;
const verified = (uid = 'u') => ({auth: {uid, token: {email: `${uid}@example.test`, email_verified: true}}});
// Sesi yang MENGKLAIM email orang lain tanpa verifikasi (atau anonim tanpa email).
const unverified = (uid = 'u') => ({auth: {uid, token: {email: 'korban@example.test', email_verified: false}}});
const anonymous = (uid = 'u') => ({auth: {uid, token: {}}});
const code = (e: any) => e?.code;

function withProfile(email: string, entitlements: Record<string, unknown> = {}) {
  const f = loadBackend();
  f.db.seed('users/u', {email, name: 'Pengguna', plan: 'trial', entitlements});
  return f;
}
const paid = () => ({fiqh_syafii: {plan: 'tholib_1m', status: 'active', expiry: new Stamp(Date.now() + 30 * DAY)}});
const outbox = (db: any) => [...db.docs.entries()].filter(([k]: [string, unknown]) => k.startsWith('provisioning_outbox/')).map(([, v]: any) => v);

// ---- getAgentUrl ----
test('getAgentUrl: sesi tak terverifikasi ditolak walau profil punya entitlement', async () => {
  for (const ctx of [unverified(), anonymous()]) {
    const {api} = withProfile('korban@example.test', paid());
    await assert.rejects(api.getAgentUrl({agentId: 'fiqh_syafii'}, ctx), (e: any) => code(e) === 'failed-precondition');
  }
});

test('getAgentUrl: sesi terverifikasi dengan email sama tetap berhasil', async () => {
  const {api} = withProfile('u@example.test', paid());
  assert.ok((await api.getAgentUrl({agentId: 'fiqh_syafii'}, verified())).url);
});

test('getAgentUrl: email token tidak cocok dengan profil ditolak (tidak boleh membuka akun orang lain)', async () => {
  const {api} = withProfile('lain@example.test', paid());
  await assert.rejects(api.getAgentUrl({agentId: 'fiqh_syafii'}, verified()), (e: any) => code(e) === 'failed-precondition');
});

test('getAgentUrl: VIP sejati dengan email terverifikasi tetap terbuka (Aturan 5)', async () => {
  const f = loadBackend();
  f.db.seed('users/u', {email: 'u@example.test', name: 'V', plan: 'trial', is_vip: true, entitlements: {}});
  assert.ok((await f.api.getAgentUrl({agentId: 'fiqh_tahawwulat'}, verified())).url);
});

// ---- redeemCode ----
function seedCode(db: any, extra: Record<string, unknown> = {}) {
  db.seed('redeem_codes/SANTRI7', {is_active: true, max_uses: 5, times_used: 0, entitlement_key: 'fiqh_syafii', duration_days: 7, ...extra});
}

test('redeemCode: voucher non-trial oleh sesi tak terverifikasi ditolak dan kode TIDAK terpakai', async () => {
  for (const ctx of [unverified(), anonymous()]) {
    const {api, db} = withProfile('korban@example.test');
    seedCode(db);
    await assert.rejects(api.redeemCode({code: 'SANTRI7'}, ctx), (e: any) => code(e) === 'failed-precondition');
    assert.equal(db.docs.get('redeem_codes/SANTRI7').times_used, 0, 'kode tidak boleh terbakar');
    assert.equal(outbox(db).length, 0, 'tidak boleh ada pekerjaan berbagi akses');
    assert.deepEqual(db.docs.get('users/u').entitlements, {}, 'tidak boleh ada entitlement');
  }
});

test('redeemCode: voucher non-trial oleh sesi terverifikasi tetap berhasil dan dikirim ke email token', async () => {
  const {api, db} = withProfile('u@example.test');
  seedCode(db);
  await api.redeemCode({code: 'SANTRI7'}, verified());
  assert.equal(db.docs.get('redeem_codes/SANTRI7').times_used, 1);
  const jobs = outbox(db);
  assert.equal(jobs.length, 1);
  assert.equal(jobs[0].email, 'u@example.test');
});

test('redeemCode: alamat berbagi akses SELALU dari token terverifikasi, bukan dari profil', async () => {
  // Profil lama menyimpan email lain; akses tidak boleh dibagikan ke alamat itu.
  const {api, db} = withProfile('profil-lama@example.test');
  seedCode(db);
  await api.redeemCode({code: 'SANTRI7'}, verified());
  const jobs = outbox(db);
  assert.equal(jobs.length, 1);
  assert.equal(jobs[0].email, 'u@example.test');
  assert.notEqual(jobs[0].email, 'profil-lama@example.test');
});

test('redeemCode: voucher trial tetap mewajibkan Google terverifikasi (perilaku lama tidak berubah)', async () => {
  const {api, db} = withProfile('korban@example.test');
  seedCode(db, {is_trial: true});
  await assert.rejects(api.redeemCode({code: 'SANTRI7'}, unverified()), (e: any) => code(e) === 'failed-precondition');
});

test('redeemCode: VIP sejati dengan email terverifikasi tidak ditolak', async () => {
  const f = loadBackend();
  f.db.seed('users/u', {email: 'u@example.test', name: 'V', plan: 'trial', is_vip: true, entitlements: {}});
  seedCode(f.db);
  await f.api.redeemCode({code: 'SANTRI7'}, verified());
  assert.equal(f.db.docs.get('redeem_codes/SANTRI7').times_used, 1);
});
