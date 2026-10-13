import test from 'node:test';
import assert from 'node:assert/strict';
import {loadBackend} from './audit_harness.ts';

const DAY = 86400000;
const stamp = (ms: number) => ({toMillis: () => ms, toDate: () => new Date(ms)});
const expiredTx = (email: string, extra: any = {}) => ({customer_email: email, status: 'success', plan: 'tholib_1m', amount: 50000,
  entitlement_key: 'fiqh_syafii', subscription_expires_at: stamp(Date.now() - 5 * DAY), ...extra});
const removals = (db: any) => [...db.docs.entries()].filter(([k, v]: any) => k.startsWith('provisioning_outbox/') && v.action === 'remove');
function seedTx(db: any, id: string, value: any) { db.seed(`transactions/${id}`, {}); Object.assign(db.docs.get(`transactions/${id}`), value); }

test('an expired transaction of a profile-level VIP never queues a removal, even without a transaction UID', async () => {
  const {api, db} = loadBackend();
  db.seed('users/vip', {email: 'ustadz@example.test', is_vip: true, entitlements: {}});
  seedTx(db, 't1', expiredTx('ustadz@example.test'));
  await api.dailyRevoke();
  assert.equal(removals(db).length, 0);
  assert.equal(db.docs.get('transactions/t1').status, 'success');
});

test('every address in the canonical VIP registry is protected in both reaper phases', async () => {
  const {api, db, access} = loadBackend();
  const emails = [...access.VIP_EMAILS];
  assert.ok(emails.length >= 43);
  emails.forEach((email, i) => {
    db.seed(`users/v${i}`, {email, plan: 'trial'});
    db.docs.get(`users/v${i}`).entitlements = {fiqh_syafii: {plan: 'tholib_1m', status: 'active', expiry: stamp(Date.now() - DAY)}};
    seedTx(db, `tx${i}`, expiredTx(email));
  });
  await api.dailyRevoke();
  assert.equal(removals(db).length, 0);
  assert.equal(db.docs.get('users/v0').entitlements.fiqh_syafii.status, 'active');
});

test('an address in access_vip_registry is protected', async () => {
  const {api, db, access} = loadBackend();
  db.seed(`access_vip_registry/${access.keyOf('guest@example.test')}`, {email: 'guest@example.test', permanent: true});
  seedTx(db, 't1', expiredTx('guest@example.test'));
  await api.dailyRevoke();
  assert.equal(removals(db).length, 0);
});

test('a module kept active by another grant survives the expiry of an older transaction', async () => {
  const {api, db} = loadBackend();
  db.seed('users/u', {email: 'u@example.test', plan: 'trial'});
  db.docs.get('users/u').entitlements = {fiqh_syafii: {plan: 'voucher_access', status: 'active', expiry: stamp(Date.now() + 10 * DAY)}};
  seedTx(db, 't1', expiredTx('u@example.test', {uid: 'u'}));
  await api.dailyRevoke();
  assert.equal(removals(db).length, 0);
});

test('a one-month plan past its expiry is detected and only its own module is queued', async () => {
  const {api, db} = loadBackend();
  db.seed('users/u', {email: 'u@example.test', plan: 'trial'});
  db.docs.get('users/u').entitlements = {
    fiqh_syafii: {plan: 'tholib_1m', status: 'active', expiry: stamp(Date.now() - DAY)},
    fiqh_tahawwulat: {plan: 'bahits_1y', status: 'active', expiry: stamp(Date.now() + 200 * DAY)}};
  seedTx(db, 't1', expiredTx('u@example.test', {uid: 'u'}));
  await api.dailyRevoke();
  const keys = new Set(removals(db).map(([, v]: any) => v.entitlement_key));
  assert.deepEqual([...keys], ['fiqh_syafii']);
  const user = db.docs.get('users/u');
  assert.equal(user.entitlements.fiqh_syafii.status, 'expired');
  assert.equal(user.entitlements.fiqh_tahawwulat.status, 'active');
});
