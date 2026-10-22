import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
import path from 'node:path';
import {stripTypeScriptTypes} from 'node:module';
import * as AC from '../src/access_control.ts';
import {MemoryDB} from './audit_harness.ts';

const {AccessControl, keyOf, rights} = AC;
// owner_ops.ts imports "./access_control" without an extension (CommonJS build);
// evaluate it with the real module injected.
const mod: any = {};
vm.runInNewContext(stripTypeScriptTypes(fs.readFileSync(path.join(import.meta.dirname, '../src/owner_ops.ts'), 'utf8')
  .replace(/^import \{([^}]*)\} from "\.\/access_control";/m, 'const {$1} = AC;')
  .replace(/^export (class|function|const) /gm, '$1 '), {mode: 'transform'}) + '\nexports.OwnerOps = OwnerOps; exports.parseDuration = parseDuration;',
  {AC, exports: mod, Date, Math, Number, String, Object, Array, Set, Map, Error, JSON, Promise});
const {OwnerOps, parseDuration} = mod;

const DAY = 86400000, now = 1_800_000_000_000;
const entities: any = {ent_h: {code: 'ent_h', name: 'H', masterId: 'mh', masterUrl: '', clones: []},
  ent_t: {code: 'ent_t', name: 'T', masterId: 'mt', masterUrl: '', clones: []}};
const scopes = {ent_h: 'hadits', ent_t: 'fiqh_tahawwulat'};
const labels = {hadits: 'AI Hadits', fiqh_tahawwulat: 'AI Fikih Tahawwulat', all_access: 'Semua AI'};
function setup(runtime: any = {writer: 'vps-v2', revocation_pause: {expiry: true}}) {
  const db = new MemoryDB();
  db.seed('access_control/runtime', runtime);
  const ops = new OwnerOps(db, entities, scopes, labels, () => now);
  const gate = new AccessControl(db, entities, scopes, undefined, () => now);
  return {db, ops, gate};
}
const seat = (db: MemoryDB, uid: string, email: string, entity: string) =>
  db.seed(`access_assignments/${keyOf(uid, entity)}`, {uid, entity, email, notebook_id: 'm', status: 'ready', revision: 1});

test('durations: days, months, years and permanent; nonsense is rejected', () => {
  assert.equal(parseDuration('7h', now), now + 7 * DAY);
  assert.equal(parseDuration('30 hari', now), now + 30 * DAY);
  assert.equal(parseDuration('1b', now), now + 30 * DAY);
  assert.ok(parseDuration('1t', now) > now + 364 * DAY);
  assert.ok(parseDuration('permanen', now) > now + 50 * 365 * DAY);
  assert.throws(() => parseDuration('banyak', now));
  assert.throws(() => parseDuration('200b', now));
});

test('manual one-month access for one AI works for an address without an app account', async () => {
  const {db, ops, gate} = setup();
  const action = {type: 'grant', email: 'Santri@X.test', scopes: ['hadits'], duration: '1b', reason: 'beasiswa pondok'};
  const p = await ops.preview(action);
  assert.ok(p.ok, p.error);
  assert.ok(p.lines.some((l: string) => l.includes('santri@x.test')));
  await ops.execute(action, 'tg:1');
  const uid = `legacy_${keyOf('santri@x.test')}`;
  const owner = await gate.owner(uid);
  assert.equal(rights(owner.user, owner.grants, 'hadits', now + 29 * DAY), true);
  assert.equal(rights(owner.user, owner.grants, 'hadits', now + 31 * DAY), false);
  assert.equal(rights(owner.user, owner.grants, 'fiqh_tahawwulat', now), false);
  assert.equal(db.docs.get(`access_legacy_owners/${uid}`).access_due_ms, now);
  assert.equal((await db.collection('owner_audit').get()).size, 1);
});

test('access to every AI and extension from the current end date', async () => {
  const {ops, gate, db} = setup();
  db.seed('users/u', {email: 'u@x.test', name: 'Ustadz U', access_grant_ids: ['p']});
  db.seed('access_grants/p', {uid: 'u', scope: 'hadits', kind: 'payment', amount: 49000, status: 'active', expires_ms: now + 10 * DAY});
  await ops.execute({type: 'extend', email: 'u@x.test', scope: 'hadits', duration: '1b', reason: 'kompensasi gangguan'}, 'tg:1');
  let o = await gate.owner('u');
  assert.equal(rights(o.user, o.grants, 'hadits', now + 39 * DAY), true);
  assert.equal(rights(o.user, o.grants, 'hadits', now + 41 * DAY), false);
  await ops.execute({type: 'grant', email: 'u@x.test', scopes: ['semua'], duration: '3b', reason: 'tamu kehormatan'}, 'tg:1');
  o = await gate.owner('u');
  assert.equal(rights(o.user, o.grants, 'fiqh_tahawwulat', now + 80 * DAY), true);
});

test('VIP: every AI, never removable, and the registry protects even before signup', async () => {
  const {ops, gate, db} = setup();
  await ops.execute({type: 'vip', email: 'syaikh@x.test', reason: 'masyayikh pembina'}, 'tg:1');
  assert.ok(db.docs.has(`access_vip_registry/${keyOf('syaikh@x.test')}`));
  const uid = `legacy_${keyOf('syaikh@x.test')}`;
  const o = await gate.owner(uid);
  assert.equal(rights(o.user, o.grants, 'fiqh_tahawwulat', now + 3650 * DAY), true);
  const p = await ops.preview({type: 'revoke', email: 'syaikh@x.test', scopes: ['all'], reason: 'uji'});
  assert.equal(p.ok, false); assert.match(p.error!, /VIP/);
  assert.equal((await ops.preview({type: 'vip', email: 'syaikh@x.test', reason: 'lagi'})).ok, false);
});

test('owner revocation lists the person and seats first, then is removable despite pause on expiry, holds and legacy evidence', async () => {
  const {ops, gate, db} = setup();
  db.seed('users/g', {email: 'gift@x.test', name: 'Penerima Hadiah', access_revocation_hold: true, access_grant_ids: ['p']});
  db.seed('access_grants/p', {uid: 'g', scope: 'fiqh_tahawwulat', kind: 'payment', amount: 300000, status: 'active', provider: 'goakal', starts_ms: now - DAY, expires_ms: now + 20 * DAY});
  db.seed('transactions/manual', {customer_email: 'gift@x.test', source: 'manual_override', status: 'success', amount: 0, entitlement_key: 'hadits'});
  seat(db, 'g', 'gift@x.test', 'ent_t'); seat(db, 'g', 'gift@x.test', 'ent_h');
  const action = {type: 'revoke', email: 'gift@x.test', scopes: ['all'], reason: 'penyalahgunaan akun'};
  const p = await ops.preview(action);
  assert.ok(p.ok, p.error);
  assert.ok(p.lines.some((l: string) => l.includes('Penerima Hadiah') && l.includes('gift@x.test')));
  assert.ok(p.lines.some((l: string) => l.includes('Kursi notebook yang akan dilepas: 2')));
  assert.ok(p.lines.some((l: string) => l.includes('Masih aktif')));
  await ops.execute(action, 'tg:1');
  for (const s of ['fiqh_tahawwulat', 'hadits']) {
    const r = await gate.assessRevocation('g', s);
    assert.equal(r.allowed, true, `${s}: ${r.reason}`);
    assert.equal(r.category, 'owner_revoke');
  }
});

test('a seat with no recorded right at all can be revoked by the owner', async () => {
  const {ops, gate, db} = setup({writer: 'vps-v2'});
  db.seed('users/m', {email: 'm@x.test', access_grant_ids: []});
  seat(db, 'm', 'm@x.test', 'ent_h');
  assert.equal((await gate.assessRevocation('m', 'hadits')).reason, 'missing_scope_evidence');
  await ops.execute({type: 'revoke', email: 'm@x.test', scopes: ['hadits'], reason: 'kursi tanpa dasar hak'}, 'tg:1');
  assert.equal((await gate.assessRevocation('m', 'hadits')).allowed, true);
});

test('a later grant cancels an earlier owner revocation', async () => {
  const {ops, gate, db} = setup({writer: 'vps-v2'});
  db.seed('users/r', {email: 'r@x.test', access_grant_ids: []});
  await ops.execute({type: 'revoke', email: 'r@x.test', scopes: ['hadits'], reason: 'salah kirim'}, 'tg:1');
  const later = new OwnerOps(db, entities, scopes, labels, () => now + 1000);
  await later.execute({type: 'grant', email: 'r@x.test', scopes: ['hadits'], duration: '1b', reason: 'dipulihkan'}, 'tg:1');
  const g2 = new AccessControl(db, entities, scopes, undefined, () => now + 2000);
  assert.equal((await g2.assessRevocation('r', 'hadits')).reason, 'active_scope');
});

test('the kill switch and an owner_revoke pause still stop owner revocations', async () => {
  for (const runtime of [{writer: 'vps-v2', revocation_kill_switch: true}, {writer: 'vps-v2', revocation_pause: {owner_revoke: true}}]) {
    const {ops, gate, db} = setup(runtime);
    db.seed('users/k', {email: 'k@x.test', access_grant_ids: []});
    seat(db, 'k', 'k@x.test', 'ent_h');
    await ops.execute({type: 'revoke', email: 'k@x.test', scopes: ['hadits'], reason: 'uji pause'}, 'tg:1');
    assert.equal((await gate.assessRevocation('k', 'hadits')).reason, 'incident_pause');
  }
});

test('guards: reason required, unknown module, partial revoke of an all-AI holder, ambiguous accounts', async () => {
  const {ops, db} = setup();
  assert.equal((await ops.preview({type: 'grant', email: 'a@x.test', scopes: ['hadits'], duration: '1b', reason: ''})).ok, false);
  assert.match((await ops.preview({type: 'grant', email: 'a@x.test', scopes: ['sihir'], duration: '1b', reason: 'x y z'})).error!, /tidak dikenal/);
  db.seed('users/s', {email: 's@x.test', access_grant_ids: ['all']});
  db.seed('access_grants/all', {uid: 's', scope: 'all_access', kind: 'admin', admin_verified: true, status: 'active', expires_ms: now + DAY});
  assert.match((await ops.preview({type: 'revoke', email: 's@x.test', scopes: ['hadits'], reason: 'uji coba'})).error!, /SEMUA AI/);
  db.seed('users/d1', {email: 'dup@x.test'}); db.seed('users/d2', {email: 'dup@x.test'});
  assert.match((await ops.preview({type: 'grant', email: 'dup@x.test', scopes: ['hadits'], duration: '1b', reason: 'uji coba'})).error!, /lebih dari satu/);
});

test('status and expiring list read back what the owner needs', async () => {
  const {ops, db} = setup();
  db.seed('users/u', {email: 'u@x.test', name: 'U', access_grant_ids: ['p']});
  db.seed('access_grants/p', {uid: 'u', scope: 'hadits', kind: 'payment', gateway: 'midtrans', amount: 49000, status: 'active', expires_ms: now + 3 * DAY});
  const st = await ops.status('u@x.test');
  assert.match(st.access['AI Hadits'], /aktif s\/d/);
  const soon = await ops.expiring(7);
  assert.equal(soon.length, 1); assert.equal(soon[0].email, 'u@x.test');
});
