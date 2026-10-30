import test from 'node:test';
import assert from 'node:assert/strict';
import {loadBackend} from './audit_harness.ts';

const caller = {auth: {uid: 'u', token: {email: 'u@example.test', email_verified: true}}};
async function configured(fn: () => Promise<void>) {
  const previous = process.env.MIDTRANS_SERVER_KEY;
  process.env.MIDTRANS_SERVER_KEY = 'test-only-key';
  try { await fn(); } finally {
    if (previous === undefined) delete process.env.MIDTRANS_SERVER_KEY;
    else process.env.MIDTRANS_SERVER_KEY = previous;
  }
}
function fixture() {
  const f = loadBackend();
  f.db.seed('transactions/t', {uid: 'u', gateway: 'midtrans', invoice_number: 'INV-1', status: 'pending', amount: 49000});
  return f;
}
test('gateway lookup failure is ERROR rather than a genuine PENDING payment', async () => configured(async () => {
  const {api, axios, db} = fixture();
  axios.get = async () => { throw Error('network unavailable'); };
  const failed = await api.checkPaymentStatus({invoiceNumber: 'INV-1'}, caller);
  assert.equal(failed.status, 'ERROR');
  assert.equal(failed.success, false);
  assert.equal(db.docs.get('transactions/t').status, 'pending');
  axios.get = async () => ({data: {transaction_status: 'pending'}});
  const pending = await api.checkPaymentStatus({invoiceNumber: 'INV-1'}, caller);
  assert.equal(pending.status, 'PENDING');
  assert.equal(pending.success, false);
}));
test('expire deny and cancel remain explicit final results', async () => configured(async () => {
  const {api, axios} = fixture();
  for (const status of ['expire', 'deny', 'cancel']) {
    axios.get = async () => ({data: {transaction_status: status}});
    const result = await api.checkPaymentStatus({invoiceNumber: 'INV-1'}, caller);
    assert.equal(result.status, status.toUpperCase());
    assert.equal(result.success, false);
  }
}));
