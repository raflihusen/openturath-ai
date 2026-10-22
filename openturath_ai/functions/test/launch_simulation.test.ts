// Phase 4: a launch-sized day in one test. Thousands of accounts flow through the
// real worker scheduler and the real access engine against an in-memory
// Firestore and a fake NotebookLM, then every account's final state is checked.
import test from 'node:test';
import assert from 'node:assert/strict';
import {AccessControl, keyOf} from '../src/access_control.ts';
import {MemoryDB} from './audit_harness.ts';
import {runWorker, seedNotebooks, CATALOG, SCOPES} from './worker_harness.ts';

const DAY = 86400000;
const COUNTS = {free: 1500, buyers: 400, expired: 100, refunded: 30, deleted: 20, vip: 5};

test(`launch day: ${Object.values(COUNTS).reduce((a, b) => a + b)} accounts converge to the correct access`, {timeout: 600000}, async () => {
  const db = new MemoryDB(), auth = new Map<string, any>(), now = Date.now();
  db.seed('access_control/runtime', {writer: 'vps-v2', revocation_pause: {expiry: false, refund: false, account_deleted: false},
    revocation_hourly_limit: 10000});
  seedNotebooks(db, now);
  const ENTITY = '01_FIKIH_SYAFII', master = CATALOG.NOTEBOOK_ENTITIES[ENTITY].masterId;
  const members = new Map<string, Set<string>>();
  const seat = (id: string, email: string) => { if (!members.has(id)) members.set(id, new Set()); members.get(id)!.add(email); };
  const provider = {
    async observe(id: string) { return {notebookId: id, isPublic: false, complete: true, emails: [...(members.get(id) || [])]}; },
    async apply(id: string, email: string, desired: boolean) {
      if (desired) seat(id, email); else members.get(id)?.delete(email);
      return this.observe(id);
    },
  };
  const engine = new AccessControl(db, CATALOG.NOTEBOOK_ENTITIES, SCOPES.ENTITY_SCOPES, provider, Date.now);
  const user = (uid: string, extra: any = {}) => {
    db.seed(`users/${uid}`, {email: `${uid}@x.test`, ...extra});
    auth.set(uid, {email: `${uid}@x.test`, emailVerified: true});
  };
  const grant = (uid: string, extra: any) => db.seed(`access_grants/g_${uid}`, {uid, scope: 'fiqh_syafii', kind: 'payment',
    amount: 49000, gateway: 'midtrans', status: 'active', ...extra});
  // An account that already holds a seat (it bought earlier).
  const seated = (uid: string) => {
    const email = `${uid}@x.test`;
    seat(master, email);
    db.seed(`access_assignments/${keyOf(uid, ENTITY)}`, {uid, entity: ENTITY, scope: 'fiqh_syafii', email, notebook_id: master, status: 'ready', revision: 1, verified_ms: now});
    db.seed(`access_identities/${keyOf(email, ENTITY)}`, {uid, email, entity: ENTITY});
    db.seed(`access_memberships/${keyOf(master, email)}`, {uid, entity: ENTITY, email, notebook_id: master, present: true, counted: true, verified_ms: now});
  };
  const ids = (prefix: string, n: number) => Array.from({length: n}, (_, i) => `${prefix}${String(i).padStart(4, '0')}`);

  // Signed up, never bought; registered before everyone else, so oldest in the queue.
  for (const uid of ids('a_free', COUNTS.free)) user(uid, {access_due_ms: now - 10 * DAY});
  for (const uid of ids('b_buy', COUNTS.buyers)) { user(uid, {access_version: 2, access_due_ms: now, access_grant_ids: [`g_${uid}`]}); grant(uid, {expires_ms: now + 30 * DAY}); }
  for (const uid of ids('c_exp', COUNTS.expired)) { user(uid, {access_version: 2, access_due_ms: now, access_grant_ids: [`g_${uid}`]}); grant(uid, {expires_ms: now - DAY}); seated(uid); }
  for (const uid of ids('d_ref', COUNTS.refunded)) { user(uid, {access_version: 2, access_due_ms: now, access_grant_ids: [`g_${uid}`]});
    grant(uid, {expires_ms: now + 20 * DAY, status: 'revoked', payment_status: 'refund'}); seated(uid); }
  for (const uid of ids('e_del', COUNTS.deleted)) { grant(uid, {expires_ms: now + 20 * DAY}); seated(uid);
    db.seed(`access_legacy_owners/${uid}`, {email: `${uid}@x.test`, account_deleted: true, access_version: 2, access_due_ms: now}); }
  const vips = ['prilatief@gmail.com', 'alkhateeb23@gmail.com', 'omarasb1441@gmail.com', 'mohammedhalahdal@gmail.com', 'yasser110271@gmail.com'];
  vips.forEach((email, i) => { const uid = `f_vip${i}`;
    db.seed(`users/${uid}`, {email, access_version: 2, access_due_ms: now, access_grant_ids: [`g_${uid}`]}); auth.set(uid, {email, emailVerified: true});
    grant(uid, {expires_ms: now - 400 * DAY});
    seat(master, email);
    db.seed(`access_assignments/${keyOf(uid, ENTITY)}`, {uid, entity: ENTITY, scope: 'fiqh_syafii', email, notebook_id: master, status: 'ready', revision: 1, verified_ms: now});
    db.seed(`access_identities/${keyOf(email, ENTITY)}`, {uid, email, entity: ENTITY});
  });

  // Worker passes (each pass = one 15-second cycle in production) and job draining.
  let passes = 0;
  for (; passes < 60; passes++) {
    const due = (await db.collection('users').where('access_due_ms', '<=', Date.now()).get()).size +
      (await db.collection('access_legacy_owners').where('access_due_ms', '<=', Date.now()).get()).size;
    if (!due) break;
    await runWorker(db, auth);
  }
  for (let round = 0; round < 5; round++) {
    const jobs = (await db.collection('access_jobs').where('due_ms', '<=', Date.now()).get()).docs;
    if (!jobs.length) break;
    for (const j of jobs) await engine.runJob(j.ref);
    await runWorker(db, auth); // settles revocations and requeues follow-ups
  }

  const seatedIn = (email: string) => [...members.values()].some(s => s.has(email));
  assert.ok(passes <= 25, `queue drained in ${passes} passes (~${passes * 15}s of production cycles)`);
  for (const uid of ids('b_buy', COUNTS.buyers)) assert.ok(seatedIn(`${uid}@x.test`), `buyer ${uid} has a seat`);
  for (const uid of ids('c_exp', COUNTS.expired)) assert.ok(!seatedIn(`${uid}@x.test`), `expired ${uid} removed`);
  for (const uid of ids('d_ref', COUNTS.refunded)) assert.ok(!seatedIn(`${uid}@x.test`), `refunded ${uid} removed`);
  for (const uid of ids('e_del', COUNTS.deleted)) assert.ok(!seatedIn(`${uid}@x.test`), `deleted ${uid} removed`);
  for (const email of vips) assert.ok(seatedIn(email), `VIP ${email} untouched`);
  for (const uid of ids('a_free', COUNTS.free)) assert.ok(!seatedIn(`${uid}@x.test`), 'free signups get no seat');
  const reviews = (await db.collection('access_reviews').get()).docs.map((d: any) => d.data().code);
  assert.ok(!reviews.includes('assignment_failure'), `no account failed: ${JSON.stringify(reviews.slice(0, 5))}`);
});
