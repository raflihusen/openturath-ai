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
