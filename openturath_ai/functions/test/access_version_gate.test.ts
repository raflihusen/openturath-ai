import test from 'node:test';
import assert from 'node:assert/strict';
import {loadBackend} from './audit_harness.ts';

const DAY = 86400000;
const stamp = (ms: number) => ({toMillis: () => ms, toDate: () => new Date(ms)});
const caller = {auth: {uid: 'u', token: {email: 'u@example.test', email_verified: true}}};
const active = (plan = 'tholib_1m') => ({plan, status: 'active', expiry: stamp(Date.now() + 30 * DAY)});

function fixture(writer?: string) {
  const f = loadBackend();
  if (writer) f.db.seed('access_control/runtime', {writer});
  f.db.seed('users/u', {email: 'u@example.test', name: 'Pengguna', plan: 'trial', entitlements: {}});
  f.db.docs.get('users/u').entitlements = {fiqh_tahawwulat: active('bahits_1y')};
  f.db.seed('redeem_codes/SANTRI7', {is_active: true, max_uses: 10, times_used: 0, entitlement_key: 'fiqh_syafii', duration_days: 7});
  return f;
}

test('before cutover a voucher keeps the account on legacy evaluation and every module working', async () => {
  const {api, db} = fixture();
  await api.redeemCode({code: 'SANTRI7'}, caller);
  const user = db.docs.get('users/u');
  assert.notEqual(user.access_version, 2);
  for (const agent of ['fiqh_tahawwulat', 'fiqh_syafii']) {
    assert.ok((await api.getAgentUrl({agentId: agent}, caller)).url, agent);
  }
});

test('an account already marked v2 still opens paid modules while the VPS writer is not active', async () => {
  const {api, db} = fixture();
  db.docs.get('users/u').access_version = 2;
  assert.ok((await api.getAgentUrl({agentId: 'fiqh_tahawwulat'}, caller)).url);
});

test('after cutover a voucher moves the account to the ledger and holds unbacked legacy modules', async () => {
  const {api, db} = fixture('vps-v2');
  await api.redeemCode({code: 'SANTRI7'}, caller);
  const user = db.docs.get('users/u');
  assert.equal(user.access_version, 2);
  assert.equal(user.access_revocation_hold, true);
  assert.equal(user.access_legacy_audit_required, true);
  assert.equal(user.entitlements.fiqh_tahawwulat.status, 'active');
});

test('after cutover an account whose modules are all ledger-backed is not placed on hold', async () => {
  const {api, db} = fixture('vps-v2');
  db.seed('access_grants/g', {uid: 'u', scope: 'fiqh_tahawwulat', kind: 'payment', amount: 1999000, status: 'active', expires_ms: Date.now() + 300 * DAY});
  db.docs.get('users/u').access_grant_ids = ['g'];
  await api.redeemCode({code: 'SANTRI7'}, caller);
  assert.equal(db.docs.get('users/u').access_revocation_hold, undefined);
});

test('checkout input is typed, bounded and rate limited', async () => {
  const {api} = loadBackend();
  const base = {agentId: 'fiqh_syafii', plan: 'tholib_1m', name: 'Reader', email: 'reader@example.test'};
  for (const bad of [{...base, name: {a: 1}}, {...base, email: 'not-an-email'}, {...base, plan: 5}]) {
    await assert.rejects(api.createCheckout(bad, {auth: {uid: 'r'}}), (e: any) => e.code === 'invalid-argument');
  }
});

test('deleting an account removes device bindings and contact details outside the profile', async () => {
  const {api, db} = loadBackend();
  db.seed('users/u', {email: 'u@example.test', name: 'Pengguna'});
  db.seed('users/u/bookmarks/b', {text: 'catatan'});
  db.seed('device_redemptions/d', {uid: 'u', email: 'u@example.test', model: 'X'});
  db.seed('device_redemptions/other', {uid: 'someone', email: 's@example.test'});
  db.seed('transactions/t', {uid: 'u', customer_email: 'u@example.test', customer_name: 'Pengguna', customer_phone: '0812', amount: 50000});
  db.seed('access_grants/g', {uid: 'u', email: 'u@example.test', scope: 'hadits'});
  await api.onUserDeleted({uid: 'u', email: 'u@example.test'});
  assert.equal(db.docs.has('users/u'), false);
  assert.equal(db.docs.has('users/u/bookmarks/b'), false);
  assert.equal(db.docs.has('device_redemptions/d'), false);
  assert.equal(db.docs.has('device_redemptions/other'), true);
  const payment = db.docs.get('transactions/t');
  assert.equal(payment.customer_name, ''); assert.equal(payment.customer_phone, ''); assert.equal(payment.amount, 50000);
  assert.equal(db.docs.get('access_grants/g').email, '');
});
