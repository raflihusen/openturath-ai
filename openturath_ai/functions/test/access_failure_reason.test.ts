import test from 'node:test';
import assert from 'node:assert/strict';
import {loadBackend} from './audit_harness.ts';

const caller={auth:{uid:'u',token:{email:'u@example.test',email_verified:true}}};
function fixture(ledger=false) {
  const f=loadBackend();
  f.db.seed('users/u',{email:'u@example.test',plan:'trial',access_version:ledger?2:1,entitlements:{}});
  if(ledger)f.db.seed('access_control/runtime',{writer:'vps-v2'});
  return f;
}
async function reason(f:any,want:string,code:string) {
  await assert.rejects(f.api.getAgentUrl({agentId:'fiqh_syafii'},caller),(e:any)=>{
    assert.equal(e.code,code);assert.equal(e.details?.reason,want);
    assert.match(e.details?.request_id||'',/^[a-f0-9-]{36}$/);return true;
  });
}
test('tidak ada hak modul dibedakan dari gangguan penyiapan',async()=>{
  await reason(fixture(),'entitlement_required','permission-denied');
});
test('pelanggan berbayar tanpa assignment menerima alasan penyiapan, bukan beli ulang',async()=>{
  const f=fixture(true);
  f.db.seed('access_grants/g',{uid:'u',scope:'fiqh_syafii',kind:'payment',amount:49000,status:'active',expires_ms:Date.now()+86400000});
  await reason(f,'access_provisioning','failed-precondition');
  assert.equal(f.db.docs.get('access_grants/g').amount,49000);
});
test('VIP tanpa assignment tetap VIP dan menerima status penyiapan',async()=>{
  const f=fixture(true);f.db.docs.get('users/u').is_vip=true;
  await reason(f,'access_provisioning','failed-precondition');
  assert.equal(f.db.docs.get('users/u').is_vip,true);
});
test('hold legacy tetap terlindungi ketika bukti notebook belum cocok',async()=>{
  const f=fixture(true);f.db.docs.get('users/u').access_revocation_hold=true;
  await reason(f,'legacy_review','failed-precondition');
  assert.equal(f.db.docs.get('users/u').access_revocation_hold,true);
});
