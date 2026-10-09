import test from 'node:test';
import assert from 'node:assert/strict';
import {loadBackend} from './audit_harness.ts';
const root=process.env.AUDIT_SOURCE_ROOT || process.cwd();
function setup() {
  const f=loadBackend(root),now=Date.now();
  f.db.seed('access_control/runtime',{writer:'vps-v2',activated_ms:now});
  f.db.seed('access_control/heartbeat',{last_success_ms:now,last_provider_success_ms:now});
  f.db.seed('access_control/payment_heartbeat',{checked_ms:now});return f;
}
test('monitor records an incident without sending messages when owner approval is absent',async()=>{
  const {api,db,sent}=setup();db.docs.get('access_control/heartbeat').authentication_error=true;
  db.seed('access_control/monitor',{enabled:true});
  await api.monitorAccessHealth();
  assert.ok(db.docs.get('access_control/monitor_health').issues.includes('sharing_provider_stale'));
  assert.equal(db.docs.get('access_control/monitor_health').notification_enabled,false);assert.equal(sent.length,0);
});
test('approved monitoring stays quiet while healthy and detects long queued retries',async()=>{
  const {api,db,sent}=setup();db.seed('access_control/monitor',{enabled:true,approved_by_owner:true});
  await api.monitorAccessHealth();assert.equal(sent.length,0);
  db.seed('access_jobs/stuck',{status:'retry',queued_ms:Date.now()-20*60000,due_ms:Date.now()+60000});
  await api.monitorAccessHealth();assert.ok(db.docs.get('access_control/monitor_health').issues.includes('access_queue_overdue'));
});
test('a failed alert delivery is not falsely recorded as delivered and can be retried',async()=>{
  const {api,db,axios}=setup(),oldToken=process.env.TELEGRAM_BOT_TOKEN,oldChat=process.env.TELEGRAM_CHAT_ID;
  process.env.TELEGRAM_BOT_TOKEN='test-only-token';process.env.TELEGRAM_CHAT_ID='test-only-channel';
  db.seed('access_control/monitor',{enabled:true,approved_by_owner:true});
  db.docs.get('access_control/heartbeat').authentication_error=true;
  let attempts=0;axios.post=async()=>{attempts++;return {data:{ok:attempts>1}};};
  try {
    await api.monitorAccessHealth();assert.equal(db.docs.get('access_control/monitor_health').notified_state,undefined);
    await api.monitorAccessHealth();assert.equal(attempts,2);
    await api.monitorAccessHealth();assert.equal(attempts,2);
  } finally {
    if(oldToken===undefined)delete process.env.TELEGRAM_BOT_TOKEN;else process.env.TELEGRAM_BOT_TOKEN=oldToken;
    if(oldChat===undefined)delete process.env.TELEGRAM_CHAT_ID;else process.env.TELEGRAM_CHAT_ID=oldChat;
  }
});
