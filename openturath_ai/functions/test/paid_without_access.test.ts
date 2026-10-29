import test from 'node:test';
import assert from 'node:assert/strict';
import {loadBackend, Stamp} from './audit_harness.ts';

const seedPaid = (db: any, id: string, minutesAgo: number) => {
  db.seed('users/u', {email: 'u@example.test', access_version: 2});
  db.seed(`transactions/${id}`, {status: 'paid', uid: 'u', entitlement_key: 'fiqh_syafii', invoice_number: 'OT-1',
    paid_at: new Stamp(Date.now() - minutesAgo * 60000)});
};

test('lunas > 3 menit tanpa penugasan ready: akses dipercepat dan pemilik diberi tahu sekali', async () => {
  process.env.TELEGRAM_BOT_TOKEN = 't'; process.env.TELEGRAM_CHAT_ID = 'c';
  const {api, db, sent} = loadBackend();
  seedPaid(db, 't1', 10);
  await api.monitorPaidWithoutAccess();
  await api.monitorPaidWithoutAccess();
  assert.ok(db.docs.get('users/u').access_due_ms > 0);
  assert.ok(db.docs.has('paid_access_alerts/t1'));
  assert.equal(sent.filter((m: any) => JSON.stringify(m).includes('AKSES BELUM SIAP')).length, 1);
});

test('lunas baru (< 3 menit) atau sudah ready tidak memicu apa pun', async () => {
  const a = loadBackend();
  seedPaid(a.db, 't2', 1);
  await a.api.monitorPaidWithoutAccess();
  assert.equal(a.db.docs.has('paid_access_alerts/t2'), false);
  const b = loadBackend();
  seedPaid(b.db, 't3', 10);
  b.db.seed('access_assignments/x', {uid: 'u', scope: 'fiqh_syafii', status: 'ready'});
  await b.api.monitorPaidWithoutAccess();
  assert.equal(b.db.docs.has('paid_access_alerts/t3'), false);
});

test('getAccessReadiness ledger v2: siap hanya bila setiap kajian paket sudah punya penugasan ready', async () => {
  const f = loadBackend();
  const caller = {auth: {uid: 'u', token: {email: 'u@example.test', email_verified: true}}};
  f.db.seed('access_control/runtime', {writer: 'vps-v2'});
  f.db.seed('transactions/t9', {uid: 'u', invoice_number: 'OT-9', entitlement_key: 'fiqh_tahawwulat', status: 'paid'});
  f.db.seed('provisioning_outbox/job_OT-9', {status: 'v2_handed_off'});
  const entities = Object.entries(f.catalog.ENTITY_SCOPES).filter(([, sc]) => sc === 'fiqh_tahawwulat').map(([e]) => e);
  assert.ok(entities.length > 1);
  assert.equal((await f.api.getAccessReadiness({invoice: 'OT-9'}, caller)).ready, false);
  entities.slice(0, -1).forEach((e, i) => f.db.seed(`access_assignments/a${i}`, {uid: 'u', scope: 'fiqh_tahawwulat', entity: e, status: 'ready', verified_ms: 1}));
  assert.equal((await f.api.getAccessReadiness({invoice: 'OT-9'}, caller)).ready, false, 'satu kajian belum siap');
  f.db.seed('access_assignments/last', {uid: 'u', scope: 'fiqh_tahawwulat', entity: entities.at(-1), status: 'ready', verified_ms: 1});
  assert.equal((await f.api.getAccessReadiness({invoice: 'OT-9'}, caller)).ready, true);
});

test('rekonsiliasi Midtrans: lunas di Midtrans tapi belum di sistem ditandai; sisanya tidak', () => {
  const {api} = loadBackend();
  assert.equal(api.midtransLedgerMismatch('pending', 'settlement', 49000, '49000.00'), 'paid_at_midtrans_not_locally');
  assert.equal(api.midtransLedgerMismatch('abandoned', 'capture', 49000, '299000.00'), 'paid_amount_differs');
  assert.equal(api.midtransLedgerMismatch('paid', 'settlement', 49000, '49000.00'), null);
  assert.equal(api.midtransLedgerMismatch('abandoned', 'expire', 49000, '49000.00'), null);
});
