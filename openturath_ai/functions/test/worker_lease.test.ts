import test from 'node:test';
import assert from 'node:assert/strict';
import {MemoryDB} from './audit_harness.ts';
import {WorkerLease} from '../src/worker_lease.ts';

const mk = (db: any, id: string, role: 'primary' | 'standby', now: {t: number}) =>
  new WorkerLease(db, id, role, () => now.t, 60000, 120000, 20000);

test('hanya satu pemegang sewa pada satu waktu', async () => {
  const db = new MemoryDB(); const now = {t: 1_000_000};
  const vps = mk(db, 'vps', 'primary', now), mac = mk(db, 'mac', 'standby', now);
  assert.equal(await vps.renew(), true);
  assert.equal(await mac.renew(), false);
  assert.equal(vps.holds(), true); assert.equal(mac.holds(), false);
});

test('standby mengambil alih hanya setelah sewa primary mati lebih dari masa tenggang', async () => {
  const db = new MemoryDB(); const now = {t: 1_000_000};
  const vps = mk(db, 'vps', 'primary', now), mac = mk(db, 'mac', 'standby', now);
  await vps.renew();
  now.t += 61_000;                      // sewa habis, tetapi belum melewati tenggang
  assert.equal(await mac.renew(), false);
  now.t += 120_000;                     // VPS mati > 3 menit
  assert.equal(await mac.renew(), true);
});

test('primary merebut kembali dari standby dan standby berhenti menulis', async () => {
  const db = new MemoryDB(); const now = {t: 1_000_000};
  const vps = mk(db, 'vps', 'primary', now), mac = mk(db, 'mac', 'standby', now);
  await vps.renew(); now.t += 200_000;
  assert.equal(await mac.renew(), true);
  assert.equal(await vps.renew(), true, 'primary kembali memegang');
  assert.equal(await mac.renew(), false, 'standby tidak lagi memegang');
  assert.equal(mac.holds(), false);
});

test('keyakinan lokal kedaluwarsa cepat bila pembaruan terhenti', async () => {
  const db = new MemoryDB(); const now = {t: 1_000_000};
  const vps = mk(db, 'vps', 'primary', now);
  await vps.renew(); assert.equal(vps.holds(), true);
  now.t += 21_000; assert.equal(vps.holds(), false);
});

test('galat Firestore berarti tidak ada hak menulis', async () => {
  const bad: any = {collection: () => ({doc: () => ({})}), runTransaction: async () => { throw Object.assign(new Error('x'), {code: 'unavailable'}); }};
  const l = new WorkerLease(bad, 'vps', 'primary');
  assert.equal(await l.renew(), false);
  assert.equal(l.lastError, 'unavailable');
});

test('release melepas sewa agar penerus langsung mengambil', async () => {
  const db = new MemoryDB(); const now = {t: 1_000_000};
  const vps = mk(db, 'vps', 'primary', now), vps2 = mk(db, 'vps2', 'primary', now);
  await vps.renew(); await vps.release();
  assert.equal(await vps2.renew(), true);
});
