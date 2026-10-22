import test from 'node:test';
import assert from 'node:assert/strict';
import {createRequire} from 'node:module';
import {AccessControl, keyOf} from '../src/access_control.ts';
import {MemoryDB} from './audit_harness.ts';

const require = createRequire(import.meta.url);
const {applyDecisions, certify} = require('../tool/legacy_decisions.cjs');
const DAY = 86400000, now = 1_800_000_000_000;
function setup() {
  const db = new MemoryDB();
  db.seed('access_control/runtime', {writer: 'vps-v2'});
  const engine = new AccessControl(db, {ent: {code: 'ent', name: 'E', masterId: 'm', masterUrl: '', clones: []}}, {ent: 'fiqh_tahawwulat'}, undefined, () => now);
  return {db, engine};
}

test('an orphan paid grant is linked to its buyer, who is then active again', async () => {
  const {db, engine} = setup();
  db.seed('access_legacy_owners/legacy_a', {email: 'a@x.test', access_grant_ids: []});
  db.seed('access_grants/orphan', {email: 'a@x.test', scope: 'fiqh_tahawwulat', kind: 'payment', amount: 300000, status: 'active', provider: 'goakal', expires_ms: now + 20 * DAY});
  const log = await applyDecisions(db, [{approved: true, action: 'link_orphan_grant', uid: 'legacy_a', grant: 'orphan'}], {engine, now});
  assert.equal(log[0].result, 'applied');
  assert.equal(db.docs.get('access_grants/orphan').uid, 'legacy_a');
  assert.equal((await engine.assessRevocation('legacy_a', 'fiqh_tahawwulat')).reason, 'active_scope');
});

test('a grant that belongs to someone else cannot be linked', async () => {
  const {db, engine} = setup();
  db.seed('access_legacy_owners/legacy_a', {email: 'a@x.test'});
  db.seed('access_grants/g', {uid: 'other', email: 'a@x.test', scope: 'fiqh_tahawwulat', kind: 'payment', amount: 1, status: 'active'});
  const log = await applyDecisions(db, [{approved: true, action: 'link_orphan_grant', uid: 'legacy_a', grant: 'g'}], {engine, now});
  assert.equal(log[0].result, 'grant_not_orphan_or_mismatch');
  assert.equal(db.docs.get('access_grants/g').uid, 'other');
});

test('a bonus is honored to its promised date, then the access is removable with a valid certificate', async () => {
  const {db, engine} = setup();
  db.seed('access_legacy_owners/legacy_b', {email: 'b@x.test', access_revocation_hold: true, access_grant_ids: ['paid']});
  db.seed('access_grants/paid', {uid: 'legacy_b', scope: 'fiqh_tahawwulat', kind: 'payment', amount: 999000, status: 'active', provider: 'goakal', provider_verified: true, expires_ms: now - 2 * DAY});
  db.seed('transactions/AKL-1', {customer_email: 'b@x.test', source: 'akal', status: 'success', amount: 999000, entitlement_key: 'fiqh_tahawwulat',
    bonus_reason: 'launch bonus', subscription_expires_at: now + 3 * DAY});
  const decisions = [
    {approved: true, action: 'honor_until', uid: 'legacy_b', scope: 'fiqh_tahawwulat', until_ms: now + 3 * DAY, source_transaction: 'AKL-1', reason: 'bonus +5 hari'},
    {approved: true, action: 'lift_hold', uid: 'legacy_b'},
  ];
  await applyDecisions(db, decisions, {engine, now});
  assert.equal(db.docs.get('access_legacy_owners/legacy_b').access_revocation_hold, false);
  // Until the bonus date the member keeps the seat, even though the paid grant ended.
  assert.equal((await engine.assessRevocation('legacy_b', 'fiqh_tahawwulat')).reason, 'active_scope');
  const later = new AccessControl(db, engine.entities, engine.scopes, undefined, () => now + 4 * DAY);
  assert.equal((await later.assessRevocation('legacy_b', 'fiqh_tahawwulat')).reason, 'legacy_audit_missing_or_stale');
  const log = await certify(db, decisions, {engine: later, now: now + 4 * DAY});
  assert.equal(log[0].result, 'issued');
  assert.equal((await later.assessRevocation('legacy_b', 'fiqh_tahawwulat')).allowed, true);
});

test('a transferred purchase is ended for the sender and certified as void', async () => {
  const {db, engine} = setup();
  db.seed('users/sender', {email: 's@x.test', access_revocation_hold: true, entitlements: {fiqh_tahawwulat: {status: 'active', expiry: now + 100 * DAY}}});
  db.seed('transactions/T', {customer_email: 's@x.test', source: 'akal', status: 'TRANSFERRED', amount: 1999000, entitlement_key: 'fiqh_tahawwulat',
    bonus_reason: 'x', subscription_expires_at: now + 100 * DAY});
  const decisions = [{approved: true, action: 'end_access', uid: 'sender', scope: 'fiqh_tahawwulat', reason: 'dipindahkan ke penerima transfer'},
    {approved: true, action: 'lift_hold', uid: 'sender', certify: ['fiqh_tahawwulat']}];
  await applyDecisions(db, decisions, {engine, now});
  assert.equal(db.docs.get('users/sender').entitlements.fiqh_tahawwulat.status, 'revoked');
  const log = await certify(db, decisions, {engine, now});
  assert.ok(log.every((l: any) => l.result === 'issued'));
  const cert = db.docs.get(`access_legacy_audits/${keyOf('sender', 'fiqh_tahawwulat')}`);
  assert.equal(cert.adjustments.T.action, 'void_owner_confirmed');
});

test('an adjustment without a decision blocks the certificate', async () => {
  const {db, engine} = setup();
  db.seed('users/u', {email: 'u@x.test'});
  db.seed('transactions/T', {customer_email: 'u@x.test', source: 'manual_override', status: 'success', amount: 0, entitlement_key: 'fiqh_tahawwulat', subscription_expires_at: now + 50 * DAY});
  const log = await certify(db, [{approved: true, action: 'lift_hold', uid: 'u', certify: ['fiqh_tahawwulat']}], {engine, now});
  assert.equal(log[0].result, 'adjustment_without_decision');
});

test('unapproved entries and VIP accounts are never changed', async () => {
  const {db, engine} = setup();
  db.seed('users/v', {email: 'prilatief@gmail.com', access_revocation_hold: true});
  db.seed('users/w', {email: 'w@x.test', access_revocation_hold: true});
  const log = await applyDecisions(db, [
    {approved: true, action: 'lift_hold', uid: 'v'},
    {approved: false, action: 'lift_hold', uid: 'w'},
  ], {engine, now});
  assert.equal(log.length, 1); assert.equal(log[0].result, 'vip_untouched');
  assert.equal(db.docs.get('users/v').access_revocation_hold, true);
  assert.equal(db.docs.get('users/w').access_revocation_hold, true);
});
