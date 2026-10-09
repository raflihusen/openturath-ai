import test from 'node:test';
import assert from 'node:assert/strict';
import {loadBackend} from './audit_harness.ts';
const root=process.env.AUDIT_SOURCE_ROOT || process.cwd();
function fixture() {
  const f=loadBackend(root);
  f.db.seed('access_control/runtime',{writer:'vps-v2'});
  f.db.seed('users/u',{email:'u@example.test',entitlements:{}});
  f.db.seed('transactions/t',{uid:'u',gateway:'midtrans',invoice_number:'INV-1',status:'pending',amount:50000,
    duration_months:1,entitlement_key:'hadits',plan:'tholib_1m',customer_email:'u@example.test'});
  f.db.seed('payment_reconciliation/INV-1',{invoice_number:'INV-1',transaction_document:'t',uid:'u',gateway:'midtrans',state:'pending',due_ms:0,attempts:0});
  return f;
}
const verified=(status='settlement',extra={})=>({order_id:'INV-1',gross_amount:'50000.00',transaction_id:'transaction-1',currency:'IDR',transaction_status:status,...extra});
async function configured(fn:()=>Promise<void>) {
  const previous=process.env.MIDTRANS_SERVER_KEY;process.env.MIDTRANS_SERVER_KEY='test-only-key';
  try {await fn();} finally {if(previous===undefined)delete process.env.MIDTRANS_SERVER_KEY;else process.env.MIDTRANS_SERVER_KEY=previous;}
}
test('missed payment webhook is recovered with one duration extension even after another inquiry',async()=>configured(async()=>{
  const {api,db,axios}=fixture();axios.get=async()=>({data:verified()});
  await api.reconcileMidtransPayments();
  assert.equal(db.docs.get('transactions/t').activation_applied,true);
  const first=db.docs.get('users/u').entitlements.hadits.expiry.toMillis();
  db.docs.get('payment_reconciliation/INV-1').due_ms=0;
  await api.reconcileMidtransPayments();
  assert.equal(db.docs.get('users/u').entitlements.hadits.expiry.toMillis(),first);
  assert.equal([...db.docs.values()].filter(x=>x.kind==='payment').length,1);
}));
test('verified full refund revokes its grant and preserves another module',async()=>configured(async()=>{
  const {api,db,axios}=fixture();axios.get=async()=>({data:verified()});await api.reconcileMidtransPayments();
  db.seed('access_grants/other',{uid:'u',scope:'fiqh_tahawwulat',kind:'payment',amount:50000,status:'active',expires_ms:Date.now()+86400000});
  axios.get=async()=>({data:verified('refund')});db.docs.get('payment_reconciliation/INV-1').due_ms=0;
  await api.reconcileMidtransPayments();
  assert.equal(db.docs.get('transactions/t').status,'refund');
  assert.equal([...db.docs.values()].find(x=>x.transaction_id==='transaction-1'&&x.kind==='payment').status,'revoked');
  assert.equal(db.docs.get('access_grants/other').status,'active');
}));
test('a failed gateway inquiry never removes a paid grant and remains queued',async()=>configured(async()=>{
  const {api,db,axios}=fixture();axios.get=async()=>({data:verified()});await api.reconcileMidtransPayments();
  axios.get=async()=>{throw Error('network unavailable');};db.docs.get('payment_reconciliation/INV-1').due_ms=0;
  await api.reconcileMidtransPayments();
  assert.equal([...db.docs.values()].find(x=>x.transaction_id==='transaction-1'&&x.kind==='payment').status,'active');
  assert.ok(db.docs.get('payment_reconciliation/INV-1').due_ms>Date.now());
  assert.equal(db.docs.get('access_control/payment_heartbeat').failed,1);
}));
test('partial refunds require policy review; mismatched transaction IDs cannot revoke access',async()=>configured(async()=>{
  const {api,db,axios}=fixture();axios.get=async()=>({data:verified()});await api.reconcileMidtransPayments();
  await api.applyMidtransRefund('INV-1',verified('partial_refund'));
  const grant=[...db.docs.values()].find(x=>x.transaction_id==='transaction-1'&&x.kind==='payment');
  assert.equal(grant.status,'active');assert.equal(grant.review_required,true);
  assert.ok([...db.docs.values()].some(x=>x.code==='partial_refund_policy_review'));
  await assert.rejects(api.applyMidtransRefund('INV-1',verified('refund',{transaction_id:'another-transaction'})),/identity mismatch/);
  assert.equal([...db.docs.values()].find(x=>x.transaction_id==='transaction-1'&&x.kind==='payment').status,'active');
}));
