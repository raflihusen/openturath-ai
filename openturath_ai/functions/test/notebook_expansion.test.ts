// Seat expansion: master fills first, then clone 01, 02, ... and the app is
// handed the clone link. Missing clones are skipped and their members moved.
import test from 'node:test';
import assert from 'node:assert/strict';
import {AccessControl, keyOf} from '../src/access_control.ts';
import {MemoryDB} from './audit_harness.ts';

const now = 1_800_000_000_000, DAY = 86400000;
const entity = {code: 'ent', name: 'E', masterId: 'master', masterUrl: '',
  clones: [1, 2, 3, 4, 5].map(i => ({id: `clone${i}`, name: `E - 0${i}`, url: ''}))};
function setup(limit = 3) {
  const db = new MemoryDB();
  const members = new Map<string, Set<string>>();
  const provider = {
    async observe(id: string) { return {notebookId: id, isPublic: false, complete: true, emails: [...(members.get(id) || [])]}; },
    async apply(id: string, email: string, desired: boolean) {
      if (!members.has(id)) members.set(id, new Set());
      if (desired) members.get(id)!.add(email); else members.get(id)!.delete(email);
      return this.observe(id);
    },
  };
  const engine = new AccessControl(db, {ent: entity}, {ent: 'fiqh_syafii'}, provider, () => now);
  db.seed('access_control/runtime', {writer: 'vps-v2'});
  for (const id of ['master', ...entity.clones.map(c => c.id)])
    db.seed(`access_notebooks/${id}`, {entity: 'ent', occupied: 0, admission_limit: limit, status: 'active', is_public: false, healthy_until_ms: now + DAY});
  const buyer = (uid: string) => {
    db.seed(`users/${uid}`, {email: `${uid}@x.test`, access_version: 2});
    db.seed(`access_grants/g_${uid}`, {uid, scope: 'fiqh_syafii', kind: 'payment', status: 'active', amount: 49000, gateway: 'midtrans', expires_ms: now + 30 * DAY});
  };
  const drain = async () => { for (const d of (await db.collection('access_jobs').get()).docs) await engine.runJob(d.ref); };
  return {db, engine, members, buyer, drain};
}

test('buyer N+1 overflows from a full master to clone 01, then 02, and the app gets the clone link', async () => {
  const {engine, buyer, drain} = setup(3);
  const seats: string[] = [];
  for (let i = 0; i < 8; i++) { buyer(`u${i}`); seats.push((await engine.reserve(`u${i}`, 'ent')).notebook_id); }
  assert.deepEqual(seats, ['master', 'master', 'master', 'clone1', 'clone1', 'clone1', 'clone2', 'clone2']);
  await drain();
  const opened = await engine.resolve('u3', 'ent');
  assert.equal(opened.notebookId, 'clone1');
  assert.equal(opened.isMaster, false);
  assert.ok(opened.url.endsWith('/notebook/clone1'));
});

test('missing and unhealthy clones are skipped by the waterfall', async () => {
  const {db, engine, buyer} = setup(1);
  db.docs.get('access_notebooks/clone1').status = 'missing';
  db.docs.get('access_notebooks/clone2').healthy_until_ms = now - 1;
  const seats: string[] = [];
  for (let i = 0; i < 3; i++) { buyer(`u${i}`); seats.push((await engine.reserve(`u${i}`, 'ent')).notebook_id); }
  assert.deepEqual(seats, ['master', 'clone3', 'clone4']);
});

test('when every notebook is full the payment is kept and the buyer waits for capacity', async () => {
  const {engine, buyer} = setup(1);
  for (let i = 0; i < 6; i++) { buyer(`u${i}`); await engine.reserve(`u${i}`, 'ent'); }
  buyer('late');
  await assert.rejects(engine.reserve('late', 'ent'), (e: any) => e.code === 'resource-exhausted');
});

test('members of a clone that disappears are moved to the next healthy notebook and can open it', async () => {
  const {db, engine, members, buyer, drain} = setup(2);
  for (let i = 0; i < 3; i++) { buyer(`u${i}`); await engine.reserve(`u${i}`, 'ent'); }
  await drain();
  assert.ok(members.get('clone1')!.has('u2@x.test'));
  db.docs.get('access_notebooks/clone1').status = 'missing';
  assert.equal(await engine.relocate('u2', 'ent'), true);
  await drain();
  const opened = await engine.resolve('u2', 'ent');
  assert.equal(opened.notebookId, 'clone2');
  assert.ok(members.get('clone2')!.has('u2@x.test'));
});

test('expiry after a relocation does not try to remove the viewer from the missing clone', async () => {
  const {db, engine, buyer, drain} = setup(2);
  for (let i = 0; i < 3; i++) { buyer(`u${i}`); await engine.reserve(`u${i}`, 'ent'); }
  await drain();
  db.docs.get('access_notebooks/clone1').status = 'missing';
  await engine.relocate('u2', 'ent'); await drain();
  db.docs.get('access_grants/g_u2').expires_ms = now - 1;
  await engine.revoke('u2', 'ent');
  const targets = (await db.collection('access_jobs').get()).docs.map((d: any) => d.data()).filter((j: any) => j.desired === false).map((j: any) => j.notebook_id);
  assert.deepEqual(targets, ['clone2']);
});

test('expired members are not re-seated when their clone disappears', async () => {
  const {db, engine, buyer} = setup(2);
  for (let i = 0; i < 3; i++) { buyer(`u${i}`); await engine.reserve(`u${i}`, 'ent'); }
  db.docs.get('access_grants/g_u2').expires_ms = now - 1;
  db.docs.get('access_notebooks/clone1').status = 'missing';
  assert.equal(await engine.relocate('u2', 'ent'), false);
  assert.equal(db.docs.get(`access_assignments/${keyOf('u2', 'ent')}`).notebook_id, 'clone1');
});

test('catalog: every notebook ID is unique and every module has at least five clones', async () => {
  const {NOTEBOOK_ENTITIES} = await import('../src/notebook_catalog.ts');
  const ids = Object.values<any>(NOTEBOOK_ENTITIES).flatMap(e => [e.masterId, ...e.clones.map((c: any) => c.id), ...(e.legacyIds || [])]);
  assert.equal(new Set(ids).size, ids.length);
  for (const e of Object.values<any>(NOTEBOOK_ENTITIES)) {
    assert.ok(e.clones.length >= 5, `${e.code} has ${e.clones.length} clones`);
    for (const c of e.clones) assert.ok(c.url.endsWith(c.id), `${c.name} url matches id`);
  }
});
