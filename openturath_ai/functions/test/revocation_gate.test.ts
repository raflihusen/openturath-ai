import test from 'node:test';
import assert from 'node:assert/strict';
import {AccessControl, keyOf} from '../src/access_control.ts';
import {MemoryDB} from './audit_harness.ts';
import {loadBackend} from './audit_harness.ts';

const DAY = 86400000, now = 1_800_000_000_000;
function setup(runtime: any = {writer: 'vps-v2'}) {
  const db = new MemoryDB();
  const members = new Map<string, Set<string>>([['m', new Set(['u@x.test'])]]);
  const provider = {
    async observe(id: string) { return {notebookId: id, isPublic: false, complete: true, emails: [...(members.get(id) || [])]}; },
    async apply(id: string, email: string, desired: boolean) {
      if (!members.has(id)) members.set(id, new Set());
      if (desired) members.get(id)!.add(email); else members.get(id)!.delete(email);
      return this.observe(id);
    },
  };
  const engine = new AccessControl(db, {ent: {code: 'ent', name: 'E', masterId: 'm', masterUrl: '', clones: []}}, {ent: 'fiqh_syafii'}, provider, () => now);
  db.seed('access_control/runtime', runtime);
  db.seed('access_notebooks/m', {entity: 'ent', occupied: 1, admission_limit: 10, status: 'active', is_public: false, healthy_until_ms: now + DAY});
  db.seed(`access_assignments/${keyOf('u', 'ent')}`, {uid: 'u', entity: 'ent', scope: 'fiqh_syafii', email: 'u@x.test', notebook_id: 'm', status: 'ready', revision: 1});
  db.seed(`access_identities/${keyOf('u@x.test', 'ent')}`, {uid: 'u', email: 'u@x.test', entity: 'ent'});
  db.seed(`access_memberships/${keyOf('m', 'u@x.test')}`, {uid: 'u', entity: 'ent', email: 'u@x.test', notebook_id: 'm', present: true, counted: true, verified_ms: now});
  return {db, engine, members};
}
const midtrans = (extra: any = {}) => ({uid: 'u', scope: 'fiqh_syafii', kind: 'payment', status: 'active', amount: 49000, gateway: 'midtrans', expires_ms: now - DAY, ...extra});
const goakal = (extra: any = {}) => ({uid: 'u', scope: 'fiqh_syafii', kind: 'payment', status: 'active', amount: 49000, provider: 'goakal', ...extra});
async function runAll(db: MemoryDB, engine: any) {
  for (const d of (await db.collection('access_jobs').get()).docs) await engine.runJob(d.ref);
}

test('expired Midtrans access is removed end to end', async () => {
  const {db, engine, members} = setup();
  db.seed('users/u', {email: 'u@x.test', access_version: 2});
  db.seed('access_grants/g', midtrans());
  await engine.revoke('u', 'ent'); await runAll(db, engine);
  assert.equal(members.get('m')!.has('u@x.test'), false);
});

test('a recent unverified GoAkal period still blocks automated removal', async () => {
  const {engine, db} = setup();
  db.seed('users/u', {email: 'u@x.test'});
  db.seed('access_grants/g', goakal({starts_ms: now - 60 * DAY, expires_ms: now - 30 * DAY}));
  assert.equal((await engine.assessRevocation('u', 'fiqh_syafii')).reason, 'legacy_audit_missing_or_stale');
});

test('a provider-verified GoAkal period is removable once it ends', async () => {
  const {engine, db} = setup();
  db.seed('users/u', {email: 'u@x.test'});
  db.seed('access_grants/g', goakal({starts_ms: now - 60 * DAY, expires_ms: now - 30 * DAY, provider_verified: true}));
  assert.equal((await engine.assessRevocation('u', 'fiqh_syafii')).allowed, true);
});

test('an old GoAkal history no longer taints a later expired Midtrans purchase', async () => {
  const {engine, db} = setup();
  db.seed('users/u', {email: 'u@x.test'});
  db.seed('access_grants/old', goakal({starts_ms: now - 500 * DAY, expires_ms: now - 470 * DAY}));
  db.seed('access_grants/new', midtrans());
  assert.equal((await engine.assessRevocation('u', 'fiqh_syafii')).allowed, true);
});

test('the old sticky legacy flag alone no longer blocks a pure Midtrans buyer', async () => {
  const {engine, db} = setup();
  db.seed('users/u', {email: 'u@x.test', access_legacy_audit_required: true});
  db.seed('access_grants/new', midtrans());
  assert.equal((await engine.assessRevocation('u', 'fiqh_syafii')).allowed, true);
});

test('an active profile entitlement without ledger backing still blocks removal', async () => {
  const {engine, db} = setup();
  db.seed('users/u', {email: 'u@x.test', entitlements: {fiqh_syafii: {status: 'active', source: 'redeem_code', expiry: now + 5 * DAY}}});
  db.seed('access_grants/new', midtrans());
  assert.equal((await engine.assessRevocation('u', 'fiqh_syafii')).reason, 'legacy_audit_missing_or_stale');
});

test('manual owner adjustments still require a certificate', async () => {
  const {engine, db} = setup();
  db.seed('users/u', {email: 'u@x.test'});
  db.seed('access_grants/new', midtrans());
  db.seed('transactions/manual', {uid: 'u', entitlement_key: 'fiqh_syafii', source: 'manual_override', status: 'success', paid_ms: now - 900 * DAY});
  assert.equal((await engine.assessRevocation('u', 'fiqh_syafii')).reason, 'legacy_audit_missing_or_stale');
});

test('unpaid checkouts opened with the buyer address do not change the decision', async () => {
  const {engine, db} = setup();
  db.seed('users/u', {email: 'u@x.test'});
  db.seed('access_grants/new', midtrans());
  const first = await engine.assessRevocation('u', 'fiqh_syafii');
  db.seed('transactions/spam', {uid: 'attacker', customer_email: 'u@x.test', gateway: 'midtrans', status: 'pending', entitlement_key: 'fiqh_syafii'});
  assert.equal((await engine.assessRevocation('u', 'fiqh_syafii')).fingerprint, first.fingerprint);
});

test('refunds keep flowing while ordinary expiry is paused', async () => {
  const {engine, db, members} = setup({writer: 'vps-v2', revocation_pause: {expiry: true, refund: false, account_deleted: false}});
  db.seed('users/u', {email: 'u@x.test', access_version: 2});
  db.seed('access_grants/g', midtrans({status: 'revoked', payment_status: 'refund', expires_ms: now + 20 * DAY}));
  await engine.revoke('u', 'ent'); await runAll(db, engine);
  assert.equal(members.get('m')!.has('u@x.test'), false);
});

test('ordinary expiry respects its own pause', async () => {
  const {engine, db} = setup({writer: 'vps-v2', revocation_pause: {expiry: true, refund: false}});
  db.seed('users/u', {email: 'u@x.test'});
  db.seed('access_grants/g', midtrans());
  assert.equal((await engine.assessRevocation('u', 'fiqh_syafii')).reason, 'incident_pause');
});

test('the kill switch stops every category, refunds included', async () => {
  const {engine, db} = setup({writer: 'vps-v2', revocation_kill_switch: true, revocation_pause: {refund: false}});
  db.seed('users/u', {email: 'u@x.test'});
  db.seed('access_grants/g', midtrans({status: 'revoked', payment_status: 'chargeback'}));
  assert.equal((await engine.assessRevocation('u', 'fiqh_syafii')).reason, 'incident_pause');
});

test('VIP accounts are never removed, even when deleted or refunded', async () => {
  const {engine, db} = setup({writer: 'vps-v2', revocation_pause: {}});
  db.seed('access_legacy_owners/u', {email: 'prilatief@gmail.com', account_deleted: true});
  db.seed(`access_assignments/${keyOf('u', 'ent')}`, {uid: 'u', entity: 'ent', email: 'prilatief@gmail.com', notebook_id: 'm', status: 'ready', revision: 1});
  assert.equal((await engine.assessRevocation('u', 'fiqh_syafii')).reason, 'permanent_vip');
});

test('a deleted account loses its notebook seats through its tombstone', async () => {
  const {engine, db, members} = setup({writer: 'vps-v2', revocation_pause: {expiry: true}});
  db.seed('access_legacy_owners/u', {email: 'u@x.test', account_deleted: true, access_version: 2});
  db.seed('access_grants/g', midtrans({expires_ms: now + 20 * DAY, email: '', account_deleted: true}));
  await engine.revoke('u', 'ent'); await runAll(db, engine);
  assert.equal(members.get('m')!.has('u@x.test'), false);
});

test('signing up again after deleting an account reuses the same Google address', async () => {
  const {engine, db} = setup({writer: 'vps-v2'});
  db.seed('access_legacy_owners/u', {email: 'u@x.test', account_deleted: true});
  db.seed('users/u2', {email: 'u@x.test', access_version: 2});
  db.seed('access_grants/g2', midtrans({uid: 'u2', expires_ms: now + 30 * DAY}));
  const a = await engine.reserve('u2', 'ent');
  assert.equal(a.uid, 'u2');
  // The deleted account's seat is now someone else's: it is settled, not removed.
  await engine.revoke('u', 'ent');
  assert.equal(db.docs.get(`access_assignments/${keyOf('u', 'ent')}`).status, 'transferred');
});

test('an address bound to a live account still needs a human', async () => {
  const {engine, db} = setup({writer: 'vps-v2'});
  db.seed('users/u', {email: 'u@x.test'});
  db.seed('users/u2', {email: 'u@x.test'});
  db.seed('access_grants/g2', midtrans({uid: 'u2', expires_ms: now + 30 * DAY}));
  await assert.rejects(engine.reserve('u2', 'ent'), /ownership recovery/);
});

test('removals beyond the hourly quota wait instead of running', async () => {
  const {engine, db, members} = setup({writer: 'vps-v2', revocation_hourly_limit: 0});
  db.seed('users/u', {email: 'u@x.test'});
  db.seed('access_grants/g', midtrans());
  await engine.revoke('u', 'ent'); await runAll(db, engine);
  assert.equal(members.get('m')!.has('u@x.test'), true);
  const job = (await db.collection('access_jobs').get()).docs[0].data();
  assert.equal(job.status, 'retry'); assert.equal(job.last_error, 'revocation_hourly_quota');
});

test('deleting an account writes the tombstone before the profile disappears', async () => {
  const {api, db} = loadBackend();
  db.seed('users/u', {email: 'u@x.test', access_revocation_hold: false});
  await api.onUserDeleted({uid: 'u', email: 'u@x.test'});
  assert.equal(db.docs.has('users/u'), false);
  const tomb = db.docs.get('access_legacy_owners/u');
  assert.equal(tomb.account_deleted, true); assert.equal(tomb.email, 'u@x.test'); assert.equal(tomb.access_version, 2);
});
