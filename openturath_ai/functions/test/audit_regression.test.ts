import test from 'node:test';
import assert from 'node:assert/strict';
import { loadBackend, Stamp } from './audit_harness.ts';

const root = process.env.AUDIT_SOURCE_ROOT || process.cwd();
const future = () => Stamp.fromMillis(Date.now() + 86400000 * 30);
const active = () => ({plan:'tholib_1m', status:'active', expiry:future()});
const authUser = (uid: string, email: string) => ({uid,email,emailVerified:true,providerData:[{providerId:'google.com'}]});

test('A01 missing DOKU secret rejects configuration', () => {
  const previous = process.env.DOKU_SECRET_KEY;
  delete process.env.DOKU_SECRET_KEY;
  try { assert.throws(()=>loadBackend(root).api.getDokuConfig()); }
  finally { if(previous!==undefined) process.env.DOKU_SECRET_KEY=previous; }
});
test('A02 revoked all access cannot be restored by legacy plan', () => {
  const {api}=loadBackend(root);
  assert.equal(api.getEntitlementAccess({plan:'all_ai_1m',subscription_expiry:future(),entitlements:{all_access:{...active(),status:'revoked'}}},'hadits').active,false);
});
test('PERDANA voucher grants time bound Pro trial using its server duration', async () => {
  const {api,db}=loadBackend(root);
  db.seed('users/u',{email:'u@example.test',plan:'trial',entitlements:{}});
  db.seed('redeem_codes/PERDANA7',{type:'perdana',entitlement_key:'all_access',duration_days:7,max_uses:1,times_used:0});
  await api.redeemCode({code:'PERDANA7',deviceId:'a'.repeat(64),isPhysicalDevice:true},{auth:{uid:'u',token:{email:'u@example.test'}}});
  const trial=db.docs.get('users/u').entitlements.all_access;
  assert.equal(trial.plan,'trial');
  assert.equal(trial.status,'active');
  assert.equal(trial.trial_duration_days,7);
  assert.ok(trial.expiry.toMillis()>Date.now());
});
test('a trial voucher starts at redemption and cannot silently stack', async () => {
  const {api,db}=loadBackend(root);
  const existingExpiry=Stamp.fromMillis(Date.now()+86400000 * 4);
  db.seed('users/u',{email:'u@example.test',entitlements:{all_access:{plan:'trial',status:'active',expiry:existingExpiry}}});
  db.seed('redeem_codes/TRIAL1',{type:'trial',entitlement_key:'all_access',duration_days:1,max_uses:1,times_used:0});
  await assert.rejects(
    api.redeemCode({code:'TRIAL1',deviceId:'b'.repeat(64),isPhysicalDevice:true},{auth:{uid:'u',token:{email:'u@example.test'}}}),
    (error: any)=>error.code==='failed-precondition'
  );
  assert.equal(db.docs.get('redeem_codes/TRIAL1').times_used,0);
  assert.equal(db.docs.get('users/u').entitlements.all_access.expiry.toMillis(),existingExpiry.toMillis());
});
test('A02 a revoked module is not restored by paid billing history', async () => {
  const {api,db}=loadBackend(root);
  db.seed('users/u',{email:'u@example.test',entitlements:{hadits:{...active(),status:'revoked'}}});
  db.seed('transactions/t',{uid:'u',customer_email:'u@example.test',status:'paid',entitlement_key:'hadits',subscription_expires_at:future()});
  assert.equal(api.getEntitlementAccess(db.docs.get('users/u'),'hadits').active,false);
  assert.equal(db.docs.get('users/u').entitlements.hadits.status,'revoked');
});
test('A03 new account cannot inherit a transaction owned by another UID', async () => {
  const {api,db,users}=loadBackend(root);
  users.set('b',authUser('b','billing@example.test'));
  db.seed('users/b',{email:'billing@example.test',plan:'trial',entitlements:{}});
  db.seed('transactions/t',{uid:'a',customer_email:'billing@example.test',status:'paid',entitlement_key:'hadits',plan:'tholib_1m',subscription_expires_at:future()});
  await api.onUserCreate(db.snapshot('users/b'),{params:{uid:'b'}});
  assert.equal(Object.keys(db.docs.get('users/b').entitlements).length,0);
});
test('A04 provisioning HTTP failure remains a failed promise', async () => {
  process.env.INTERNAL_SECRET='test-secret';
  const {api,axios}=loadBackend(root);
  axios.post=async()=>{throw Error('upstream 503');};
  await assert.rejects(api.notifySubscriptionServer('u@example.test','U','premium','add','AI Hadits'),/upstream 503/);
});
test('A04 failed outbox request is retried, never marked completed',async()=>{
  process.env.INTERNAL_SECRET='test-secret';
  const {api,db,axios}=loadBackend(root);
  db.seed('users/u',{email:'u@example.test',entitlements:{hadits:active()}});
  db.seed('provisioning_outbox/j',{uid:'u',email:'u@example.test',entitlement_key:'hadits',action:'add',status:'pending',attempts:0});
  axios.post=async()=>{throw Error('upstream 503');};
  await api.processProvisioningOutbox();
  assert.equal(db.docs.get('provisioning_outbox/j').status,'retry');
});
test('A05 expiration checks current snapshot before revoking renewed entitlement',async()=>{
  const {api,db}=loadBackend(root);
  const expired={...active(),expiry:Stamp.fromMillis(Date.now()-1000)};
  db.seed('users/u',{email:'u@example.test',plan:'trial',entitlements:{hadits:expired}});
  const snapshot=db.snapshot.bind(db);
  let injected=false;
  db.snapshot=(key: string)=>{
    const snap=snapshot(key);
    if(key==='users/u' && !injected){
      injected=true;
      db.seed('users/u',{email:'u@example.test',plan:'trial',entitlements:{hadits:active()}});
    }
    return snap;
  };
  await api.dailyRevoke();
  assert.equal(db.docs.get('users/u').entitlements.hadits.status,'active');
});
test('A05 stale removal job reconciles to current paid access',async()=>{
  process.env.INTERNAL_SECRET='test-secret';
  const {api,db,sent}=loadBackend(root);
  db.seed('users/u',{email:'u@example.test',entitlements:{hadits:active()}});
  db.seed('provisioning_outbox/j',{uid:'u',email:'u@example.test',entitlement_key:'hadits',action:'remove',status:'pending',attempts:0});
  await api.processProvisioningOutbox();
  assert.ok(sent.length>0);
  assert.equal(sent[0][1].event,'subscription.paid');
});
test('A06 deleted auth account schedules removal and recursively deletes conversations',async()=>{
  const {api,db}=loadBackend(root);
  db.seed('users/u',{email:'u@example.test',entitlements:{hadits:active()}});
  db.seed('users/u/conversations/c/messages/m',{text:'private'});
  assert.equal(typeof api.onUserDeleted,'function');
  await api.onUserDeleted({uid:'u',email:'u@example.test'});
  assert.equal([...db.docs.keys()].some(k=>k.startsWith('users/u')),false);
  assert.ok([...db.docs].some(([k,v])=>k.startsWith('provisioning_outbox/')&&v.action==='remove'));
});
test('A01 duplicate invoice grants one extension under parallel calls',async()=>{
  const {api,db}=loadBackend(root);
  db.seed('users/u',{email:'u@example.test',entitlements:{hadits:active()}});
  const old=db.docs.get('users/u').entitlements.hadits.expiry.toDate();
  db.seed('access_grants/previous',{uid:'u',scope:'hadits',kind:'payment',status:'active',amount:50000,expires_ms:old.getTime()});
  db.docs.get('users/u').access_grant_ids=['previous'];
  db.seed('transactions/t',{uid:'u',invoice_number:'INV-1',amount:50000,duration_months:1,entitlement_key:'hadits',plan:'tholib_1m',customer_email:'u@example.test'});
  await Promise.all(Array.from({length:30},()=>api.processSuccessfulPayment('INV-1',50000)));
  assert.equal(db.docs.get('users/u').entitlements.hadits.expiry.toMillis(),old.getTime()+30*86400000);
  assert.equal([...db.docs.keys()].filter(k=>k.startsWith('provisioning_outbox/')).length,1);
});
test('A01 signed success with wrong amount cannot activate invoice',async()=>{
  const {api,db}=loadBackend(root);
  db.seed('users/u',{email:'u@example.test',entitlements:{}});
  db.seed('transactions/t',{uid:'u',invoice_number:'INV-1',amount:50000,duration_months:1,entitlement_key:'hadits',plan:'tholib_1m'});
  await assert.rejects(api.processSuccessfulPayment('INV-1',1));
  assert.notEqual(db.docs.get('transactions/t').activation_applied,true);
});
test('redeem capacity survives parallel distinct accounts',async()=>{
  const {api,db}=loadBackend(root);
  db.seed('redeem_codes/CODE',{max_uses:3,times_used:0,entitlement_key:'hadits',duration_days:7});
  const results=await Promise.allSettled(Array.from({length:20},(_,i)=>api.redeemCode({code:'CODE'},{auth:{uid:'u'+i,token:{email:'u'+i+'@example.test'}}})));
  assert.equal(results.filter(r=>r.status==='fulfilled').length,3);
  assert.equal(db.docs.get('redeem_codes/CODE').times_used,3);
});
test('calendar month end clamps January in leap and common years',()=>{
  const {api}=loadBackend(root);
  assert.equal(api.addCalendarMonthsClamped(new Date('2024-01-31T12:00:00Z'),1).toISOString(),'2024-02-29T12:00:00.000Z');
  assert.equal(api.addCalendarMonthsClamped(new Date('2025-01-31T12:00:00Z'),1).toISOString(),'2025-02-28T12:00:00.000Z');
});

function response() {
  return {code:200,body:null as any,status(code: number){this.code=code;return this;},send(body: any){this.body=body;return this;},json(body: any){this.body=body;return this;}};
}
for (const timestamp of ['', 'invalid', '2000-01-01T00:00:00Z', '2999-01-01T00:00:00Z']) {
  test('A01 webhook rejects missing invalid or stale timestamp '+timestamp,async()=>{
    process.env.DOKU_CLIENT_ID='test-client';
    process.env.DOKU_SECRET_KEY='test-key';
    const {api}=loadBackend(root);
    const body={order:{invoice_number:'INV-1',amount:50000},transaction:{status:'SUCCESS'}};
    const raw=Buffer.from(JSON.stringify(body));
    const signature=api.generateDokuSignature('test-client','event-1',timestamp,'/dokuWebhook',raw.toString(),'test-key');
    const res=response();
    await api.dokuWebhook({method:'POST',body,rawBody:raw,path:'/dokuWebhook',originalUrl:'/dokuWebhook',headers:{signature,'client-id':'test-client','request-id':'event-1','request-timestamp':timestamp}},res);
    assert.equal(res.code,401);
  });
}
test('A01 full authenticated webhook activates exact invoice and accepts replay once',async()=>{
  process.env.DOKU_CLIENT_ID='test-client';process.env.DOKU_SECRET_KEY='test-key';
  const {api,db}=loadBackend(root);
  db.seed('users/u',{email:'u@example.test',entitlements:{}});
  db.seed('transactions/t',{uid:'u',invoice_number:'INV-1',amount:50000,duration_months:1,entitlement_key:'hadits',plan:'tholib_1m'});
  const body={order:{invoice_number:'INV-1',amount:'50000.00'},transaction:{status:'SUCCESS'}};
  const raw=Buffer.from(JSON.stringify(body));const timestamp=new Date().toISOString();
  const signature=api.generateDokuSignature('test-client','event-1',timestamp,'/dokuWebhook',raw.toString(),'test-key');
  const req={method:'POST',body,rawBody:raw,path:'/dokuWebhook',originalUrl:'/dokuWebhook',headers:{signature,'client-id':'test-client','request-id':'event-1','request-timestamp':timestamp}};
  const first=response();await api.dokuWebhook(req,first);assert.equal(first.code,200);
  const expiry=db.docs.get('users/u').entitlements.hadits.expiry.toMillis();
  const next=response();await api.dokuWebhook(req,next);assert.equal(next.code,200);
  assert.equal(db.docs.get('users/u').entitlements.hadits.expiry.toMillis(),expiry);
});
test('A04 overlapping workers acquire a single user lease',async()=>{
  process.env.INTERNAL_SECRET='test-secret';
  const {api,db,sent}=loadBackend(root);
  db.seed('users/u',{email:'u@example.test',entitlements:{hadits:active()}});
  db.seed('provisioning_outbox/j',{uid:'u',email:'u@example.test',entitlement_key:'hadits',action:'add',status:'pending',attempts:0});
  await Promise.all([api.processProvisioningOutbox(),api.processProvisioningOutbox()]);
  assert.equal(sent.length,1);
});
test('A05 entitlement changed during delivery leaves reconciliation pending',async()=>{
  process.env.INTERNAL_SECRET='test-secret';
  const {api,db,axios}=loadBackend(root);
  db.seed('users/u',{email:'u@example.test',entitlements:{hadits:active()}});
  db.seed('provisioning_outbox/j',{uid:'u',email:'u@example.test',entitlement_key:'hadits',action:'add',status:'pending',attempts:0});
  axios.post=async()=>{db.seed('users/u',{email:'u@example.test',entitlements:{hadits:{...active(),status:'revoked'}}});return {status:200};};
  await api.processProvisioningOutbox();assert.equal(db.docs.get('provisioning_outbox/j').status,'retry');
});
test('redeem rate limiter admits only eight parallel attempts per UID',async()=>{
  const {api,db}=loadBackend(root);
  const result=await Promise.allSettled(Array.from({length:30},()=>api.redeemCode({code:'ABSENT'},{auth:{uid:'u',token:{email:'u@example.test'}}})));
  assert.equal(db.docs.get('rate_limits/rdm_u').count,8);
  assert.equal(result.filter(r=>r.status==='rejected'&&r.reason.code==='resource-exhausted').length,22);
});
for(const code of [null, {}, '\0CODE', '\u202ECODE', 'a/b/c', "' OR 1=1", 'A'.repeat(500)]) {
  test('voucher rejects malformed input '+JSON.stringify(code),async()=>{
    const {api}=loadBackend(root);
    await assert.rejects(api.redeemCode({code},{auth:{uid:'u',token:{email:'u@example.test'}}}),(e: any)=>e.code==='invalid-argument');
  });
}
test('voucher whitespace and hyphen normalize to the canonical stored code',async()=>{
  const {api,db}=loadBackend(root);
  db.seed('redeem_codes/AB12',{max_uses:1,times_used:0,duration_days:7,entitlement_key:'hadits'});
  const result=await api.redeemCode({code:' ab- 12 '},{auth:{uid:'u',token:{email:'u@example.test'}}});
  assert.equal(result.success,true);
});

test('A06 interrupted recursive deletion already blocks access',async()=>{
  const {api,db}=loadBackend(root);
  db.seed('users/u',{email:'u@example.test',entitlements:{hadits:active()}});
  db.recursiveDelete=async()=>{throw Error('temporary delete failure');};
  await assert.rejects(api.onUserDeleted({uid:'u',email:'u@example.test'}));
  assert.equal(api.getEntitlementAccess(db.docs.get('users/u'),'hadits').active,false);
});
