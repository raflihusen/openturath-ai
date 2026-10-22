import test from 'node:test';
import assert from 'node:assert/strict';
import {MemoryDB} from './audit_harness.ts';
import {runWorker, seedNotebooks} from './worker_harness.ts';

const DAY = 86400000;
function buyer(db: MemoryDB, auth: Map<string, any>, uid: string, now: number, scope = 'fiqh_syafii') {
  db.seed(`users/${uid}`, {email: `${uid}@x.test`, access_version: 2, access_due_ms: now, access_grant_ids: [`g_${uid}`]});
  db.seed(`access_grants/g_${uid}`, {uid, scope, kind: 'payment', status: 'active', amount: 49000, gateway: 'midtrans', expires_ms: now + 30 * DAY});
  auth.set(uid, {email: `${uid}@x.test`, emailVerified: true});
}
const assigned = async (db: MemoryDB, uid: string) =>
  (await db.collection('access_assignments').get()).docs.map((d: any) => d.data()).filter((a: any) => a.uid === uid);

test('signups without a purchase never block buyers in the provisioning queue', async () => {
  const db = new MemoryDB(), auth = new Map<string, any>(), now = Date.now();
  db.seed('access_control/runtime', {writer: 'vps-v2'});
  seedNotebooks(db, now);
  for (let i = 0; i < 250; i++) {
    const uid = 'free' + String(i).padStart(3, '0');
    db.seed(`users/${uid}`, {email: `${uid}@x.test`, access_due_ms: now - DAY + i});
    auth.set(uid, {email: `${uid}@x.test`, emailVerified: true});
  }
  buyer(db, auth, 'zbuyer', now);
  for (let i = 0; i < 3; i++) await runWorker(db, auth);
  assert.ok((await assigned(db, 'zbuyer')).length > 0, 'buyer must receive a notebook seat');
  assert.equal((await db.collection('users').where('access_due_ms', '<=', Date.now()).get()).size, 0, 'free signups leave the queue');
});

test('control: a lone buyer is provisioned in one pass', async () => {
  const db = new MemoryDB(), auth = new Map<string, any>(), now = Date.now();
  db.seed('access_control/runtime', {writer: 'vps-v2'});
  seedNotebooks(db, now);
  buyer(db, auth, 'zbuyer', now);
  await runWorker(db, auth);
  assert.ok((await assigned(db, 'zbuyer')).some((a: any) => a.status === 'provisioning'));
});

test('one failing account does not stop the rest of the batch', async () => {
  const db = new MemoryDB(), auth = new Map<string, any>(), now = Date.now();
  db.seed('access_control/runtime', {writer: 'vps-v2'});
  seedNotebooks(db, now);
  // Any dependency failure while handling one account (here: its membership lookup).
  db.seed('users/abad', {email: 'abad@x.test', access_version: 2, access_due_ms: now - DAY, access_grant_ids: []});
  auth.set('abad', {email: 'abad@x.test', emailVerified: true});
  const collection = db.collection.bind(db);
  (db as any).collection = (name: string) => {
    const q = collection(name);
    if (name !== 'access_memberships') return q;
    return {...q, where: (k: string, op: string, v: any) => v === 'abad@x.test'
      ? {get: async () => { throw new Error('unavailable'); }} : q.where(k, op, v)};
  };
  buyer(db, auth, 'zbuyer', now);
  await runWorker(db, auth);
  assert.ok((await assigned(db, 'zbuyer')).length > 0);
  assert.ok(db.docs.get('users/abad').access_due_ms > now, 'failing account is pushed back, not retried first forever');
});

test('an active subscriber is not re-evaluated every hour', async () => {
  const db = new MemoryDB(), auth = new Map<string, any>(), now = Date.now();
  db.seed('access_control/runtime', {writer: 'vps-v2'});
  seedNotebooks(db, now);
  buyer(db, auth, 'zbuyer', now);
  await runWorker(db, auth);
  const next = db.docs.get('users/zbuyer').access_due_ms;
  assert.ok(next - now >= 12 * 3600000, `next evaluation too soon: ${(next - now) / 3600000}h`);
});

test('an expired subscriber is re-evaluated exactly at expiry', async () => {
  const db = new MemoryDB(), auth = new Map<string, any>(), now = Date.now();
  db.seed('access_control/runtime', {writer: 'vps-v2'});
  seedNotebooks(db, now);
  buyer(db, auth, 'zbuyer', now);
  db.docs.get('access_grants/g_zbuyer').expires_ms = now + 3 * 3600000;
  await runWorker(db, auth);
  assert.equal(db.docs.get('users/zbuyer').access_due_ms, now + 3 * 3600000);
});
