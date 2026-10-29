import test from 'node:test';
import assert from 'node:assert/strict';
import {loadBackend} from './audit_harness.ts';

const DAY = 86400000;
const stamp = (ms: number) => ({toMillis: () => ms, toDate: () => new Date(ms)});
const caller = (uid = 'u') => ({auth: {uid, token: {email: `${uid}@example.test`, email_verified: true}}});

function fixture(entitlements: Record<string, any> = {}) {
  const f = loadBackend();
  f.db.seed('users/u', {email: 'u@example.test', name: 'Pengguna', plan: 'trial', entitlements});
  return f;
}
const rejectsWith = (p: Promise<any>, code: string) => assert.rejects(p, (e: any) => e.code === code);

test('satu kode dapat membuka beberapa AI sekaligus, masing-masing dengan hibah dan pekerjaan sendiri', async () => {
  const {api, db} = fixture();
  db.seed('redeem_codes/BUNDLE3', {max_uses: 5, times_used: 0, duration_days: 14,
    entitlement_keys: ['fiqh_syafii', 'hadits', 'fiqh_tahawwulat']});
  const res = await api.redeemCode({code: 'bundle-3'}, caller());
  assert.equal(res.entitlementKeys.join(','), 'fiqh_syafii,hadits,fiqh_tahawwulat');
  assert.equal(res.durationDays, 14);
  assert.match(res.serviceTitle, /Fikih Syafi'i/);
  const user = db.docs.get('users/u');
  for (const k of ['fiqh_syafii', 'hadits', 'fiqh_tahawwulat']) {
    assert.equal(user.entitlements[k].status, 'active', k);
    assert.equal(user.entitlements[k].plan, 'voucher_access', k);
    assert.ok(db.docs.has(`provisioning_outbox/redeem_BUNDLE3_u_${k}`), k);
  }
  assert.equal(user.access_grant_ids.length, 3);
  assert.equal(user.plan, 'trial', 'paket global tidak berubah bila bukan semua AI');
  assert.equal(db.docs.get('redeem_codes/BUNDLE3').times_used, 1);
});

test('kode satu AI tetap memakai id pekerjaan lama', async () => {
  const {api, db} = fixture();
  db.seed('redeem_codes/SOLO', {max_uses: 1, times_used: 0, entitlement_key: 'hadits', duration_days: 7});
  const res = await api.redeemCode({code: 'SOLO'}, caller());
  assert.equal(res.entitlementKey, 'hadits');
  assert.ok(db.docs.has('provisioning_outbox/redeem_SOLO_u'));
});

test('alias all_ai disamakan dengan all_access dan mengubah paket global', async () => {
  const {api, db} = fixture();
  db.seed('redeem_codes/ALLAI', {max_uses: 1, times_used: 0, entitlement_key: 'all_ai', duration_days: 10});
  const res = await api.redeemCode({code: 'ALLAI'}, caller());
  assert.equal(res.entitlementKey, 'all_access');
  const user = db.docs.get('users/u');
  assert.equal(user.plan, 'voucher_access');
  assert.ok(user.subscription_expiry);
  assert.equal(user.entitlements.all_ai, undefined);
});

test('kunci AI yang tidak dikenal ditolak tanpa menulis apa pun', async () => {
  const {api, db} = fixture();
  db.seed('redeem_codes/BADKEY', {max_uses: 1, times_used: 0, entitlement_keys: ['hadits', 'bukan_ai'], duration_days: 7});
  await rejectsWith(api.redeemCode({code: 'BADKEY'}, caller()), 'failed-precondition');
  assert.equal(db.docs.get('redeem_codes/BADKEY').times_used, 0);
  assert.equal(Object.keys(db.docs.get('users/u').entitlements).length, 0);
});

test('durasi tidak valid ditolak, bukan diam-diam menjadi 7 hari; tanpa durasi berarti 7 hari', async () => {
  const {api, db} = fixture();
  for (const [code, days] of [['TOOLONG', 365], ['ZERO', 0], ['FRAC', 2.5], ['TXT', '30']] as const) {
    db.seed(`redeem_codes/${code}`, {max_uses: 1, times_used: 0, entitlement_key: 'hadits', duration_days: days});
    await rejectsWith(api.redeemCode({code}, caller()), 'failed-precondition');
    assert.equal(db.docs.get(`redeem_codes/${code}`).times_used, 0, code);
  }
  db.seed('redeem_codes/NODAYS', {max_uses: 1, times_used: 0, entitlement_key: 'hadits'});
  assert.equal((await api.redeemCode({code: 'NODAYS'}, caller())).durationDays, 7);
});

test('voucher kehormatan boleh sampai 400 hari, trial tidak pernah lebih dari 31 hari', async () => {
  const {api, db} = fixture();
  db.seed('redeem_codes/HONOR1Y', {type: 'honor', max_uses: 1, times_used: 0, entitlement_key: 'hadits', duration_days: 365});
  const res = await api.redeemCode({code: 'HONOR1Y'}, caller());
  assert.equal(res.durationDays, 365);
  assert.ok(new Date(res.expiry).getTime() - Date.now() > 360 * DAY);
  db.seed('redeem_codes/TRIALLONG', {type: 'trial', allow_long_duration: true, max_uses: 1, times_used: 0, entitlement_key: 'fiqh_syafii', duration_days: 90});
  await rejectsWith(api.redeemCode({code: 'TRIALLONG', deviceId: 'a'.repeat(64), isPhysicalDevice: true}, caller('v')), 'failed-precondition');
});

test('voucher tidak menurunkan paket berbayar yang masih berjalan pada AI yang sama', async () => {
  const exp = Date.now() + 100 * DAY;
  const {api, db} = fixture({hadits: {plan: 'bahits_1y', status: 'active', source: 'payment', payment_status: 'paid', expiry: stamp(exp)}});
  db.seed('redeem_codes/EXTRA', {max_uses: 1, times_used: 0, entitlement_key: 'hadits', duration_days: 10});
  await api.redeemCode({code: 'EXTRA'}, caller());
  const ent = db.docs.get('users/u').entitlements.hadits;
  assert.equal(ent.plan, 'bahits_1y');
  assert.equal(ent.payment_status, 'paid');
  assert.equal(ent.source, 'payment');
  assert.equal(ent.voucher_extended, true);
  assert.ok(ent.expiry.toDate().getTime() > exp + 9 * DAY);
});

test('voucher multi-AI tidak menyentuh AI lain yang sudah dimiliki', async () => {
  const exp = Date.now() + 100 * DAY;
  const {api, db} = fixture({fiqh_tahawwulat: {plan: 'bahits_1y', status: 'active', payment_status: 'paid', expiry: stamp(exp)}});
  db.seed('redeem_codes/TWO', {max_uses: 1, times_used: 0, entitlement_keys: ['hadits', 'tafsir'], duration_days: 7});
  await api.redeemCode({code: 'TWO'}, caller());
  assert.equal(db.docs.get('users/u').entitlements.fiqh_tahawwulat.plan, 'bahits_1y');
});

test('kuota kode multi-AI dihitung sekali per penukaran, bukan per AI', async () => {
  const {api, db} = fixture();
  db.docs.set('users/w', {email: 'w@example.test', plan: 'trial', entitlements: {}});
  db.seed('redeem_codes/QUOTA', {max_uses: 1, times_used: 0, entitlement_keys: ['hadits', 'tafsir'], duration_days: 7});
  await api.redeemCode({code: 'QUOTA'}, caller());
  assert.equal(db.docs.get('redeem_codes/QUOTA').times_used, 1);
  await rejectsWith(api.redeemCode({code: 'QUOTA'}, caller('w')), 'resource-exhausted');
});

test('status kesiapan akses: selesai hanya bila semua pekerjaan completed, dan hanya milik pemanggil', async () => {
  const {api, db} = fixture();
  db.seed('redeem_codes/READY2', {max_uses: 3, times_used: 0, entitlement_keys: ['hadits', 'tafsir'], duration_days: 7});
  await api.redeemCode({code: 'READY2'}, caller());
  const first = await api.getAccessReadiness({code: 'READY2'}, caller());
  assert.equal(first.ready, false);
  assert.equal(first.failed, false);
  db.docs.get('provisioning_outbox/redeem_READY2_u_hadits').status = 'completed';
  assert.equal((await api.getAccessReadiness({code: 'READY2'}, caller())).ready, false);
  db.docs.get('provisioning_outbox/redeem_READY2_u_tafsir').status = 'completed';
  assert.equal((await api.getAccessReadiness({code: 'ready-2'}, caller())).ready, true);
  db.docs.get('provisioning_outbox/redeem_READY2_u_tafsir').status = 'failed';
  assert.equal((await api.getAccessReadiness({code: 'READY2'}, caller())).failed, true);
  await rejectsWith(api.getAccessReadiness({code: 'READY2'}, caller('orang-lain')), 'not-found');
  await rejectsWith(api.getAccessReadiness({}, caller()), 'invalid-argument');
  await rejectsWith(api.getAccessReadiness({code: 'READY2'}, {}), 'unauthenticated');
});

test('status kesiapan untuk pembayaran memeriksa kepemilikan invoice', async () => {
  const {api, db} = fixture();
  db.seed('transactions/t1', {invoice_number: 'INV-1', uid: 'u'});
  db.seed('provisioning_outbox/job_INV-1', {status: 'completed'});
  assert.equal((await api.getAccessReadiness({invoice: 'INV-1'}, caller())).ready, true);
  await rejectsWith(api.getAccessReadiness({invoice: 'INV-1'}, caller('x')), 'not-found');
});

test('galat penukaran membawa alasan terstruktur agar aplikasi dapat menerjemahkannya', async () => {
  const {api, db} = fixture();
  const reasonOf = async (p: Promise<any>) => { try { await p; } catch (e: any) { return e.details?.reason; } return 'tidak-ada-galat'; };
  assert.equal(await reasonOf(api.redeemCode({code: 'TIDAKADA'}, caller())), 'not_found');
  db.seed('redeem_codes/MATI', {is_active: false, max_uses: 1, times_used: 0, entitlement_key: 'hadits'});
  assert.equal(await reasonOf(api.redeemCode({code: 'MATI'}, caller())), 'inactive');
  db.seed('redeem_codes/HABIS', {max_uses: 1, times_used: 1, entitlement_key: 'hadits'});
  assert.equal(await reasonOf(api.redeemCode({code: 'HABIS'}, caller())), 'quota');
  db.seed('redeem_codes/RUSAK', {max_uses: 1, times_used: 0, entitlement_key: 'hadits', duration_days: 999});
  assert.equal(await reasonOf(api.redeemCode({code: 'RUSAK'}, caller())), 'misconfigured');
  db.seed('redeem_codes/ONCE', {max_uses: 5, times_used: 0, entitlement_key: 'hadits', duration_days: 7});
  await api.redeemCode({code: 'ONCE'}, caller());
  assert.equal(await reasonOf(api.redeemCode({code: 'ONCE'}, caller())), 'already_redeemed');
  db.seed('redeem_codes/TRIALX', {type: 'trial', max_uses: 5, times_used: 0, entitlement_key: 'fiqh_syafii', duration_days: 7});
  assert.equal(await reasonOf(api.redeemCode({code: 'TRIALX', deviceId: 'e'.repeat(64), isPhysicalDevice: true},
    {auth: {uid: 'u', token: {}}})), 'needs_google');
});

const DEVICE = 'a'.repeat(64);
const detailsOf = (p: Promise<any>) => p.then(() => null, (e: any) => ({code: e.code, reason: e.details?.reason, message: e.message}));

test('akun yang sama mengulang klaim trial mendengar "sudah aktif", bukan tuduhan perangkat', async () => {
  const {api, db} = fixture();
  db.seed('redeem_codes/TRIAL7', {max_uses: 100, times_used: 1, duration_days: 7, entitlement_key: 'hadits'});
  db.seed('redeem_codes/TRIAL7/redemptions/u', {uid: 'u'});
  db.seed(`device_redemptions/dev_${DEVICE}_trial_default`, {uid: 'u', email: 'u@example.test'});
  const r = await detailsOf(api.redeemCode({code: 'TRIAL7', deviceId: DEVICE}, caller()));
  assert.equal(r?.reason, 'already_redeemed');
  assert.match(r!.message, /sudah aktif di akun Anda/);
});

test('perangkat dipakai akun lain: pesan jelas dengan petunjuk akun tersamar', async () => {
  const {api, db} = fixture();
  db.seed('redeem_codes/TRIAL7', {max_uses: 100, times_used: 1, duration_days: 7, entitlement_key: 'hadits'});
  db.seed(`device_redemptions/dev_${DEVICE}_trial_default`, {uid: 'lain', email: 'budi.santoso@example.test'});
  const r = await detailsOf(api.redeemCode({code: 'TRIAL7', deviceId: DEVICE}, caller()));
  assert.equal(r?.reason, 'device_used');
  assert.match(r!.message, /bu\*\*\*/);
  assert.doesNotMatch(r!.message, /budi\.santoso|example\.test/);
});
