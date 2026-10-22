import test from 'node:test';
import assert from 'node:assert/strict';
import {loadBackend} from './audit_harness.ts';

async function withEnv(values: Record<string, string>, fn: () => Promise<void>) {
  const previous = Object.fromEntries(Object.keys(values).map(k => [k, process.env[k]]));
  Object.assign(process.env, values);
  try { await fn(); } finally {
    for (const [k, v] of Object.entries(previous)) if (v === undefined) delete process.env[k]; else process.env[k] = v;
  }
}
const fixture = () => loadBackend();

test('GoAkal billing endpoints are retired and cannot mint grants', () => {
  const {api} = loadBackend();
  assert.equal(api.akalWebhook, undefined);
  assert.equal(api.syncAkalPurchases, undefined);
  assert.equal(api.applyAkalPurchase, undefined);
});

test('client error alerts are escaped and bounded per account', async () => {
  const {api, db, sent} = fixture();
  await withEnv({TELEGRAM_BOT_TOKEN: 't', TELEGRAM_CHAT_ID: '1'}, async () => {
    const event = {data: () => ({severity: 'error', userId: 'u', error: '<a href="https://evil.test">x</a>', context: '<b>ctx</b>'})};
    for (let i = 0; i < 9; i++) await api.onClientErrorLogged(event, {params: {logId: `l${i}`}});
  });
  assert.equal(sent.length, 5);
  assert.ok(!sent[0][1].text.includes('<a href'));
  assert.ok(sent[0][1].text.includes('&lt;a href'));
  assert.ok(db.docs.has('rate_limits/client_alert_u'));
});

test('the sales feed masks customer addresses and is bounded per minute', async () => {
  const {api, db, sent} = fixture();
  db.seed('users/u', {email: 'customer@example.test', entitlements: {}});
  db.seed('redeem_codes/SANTRI', {type: 'voucher', entitlement_key: 'fiqh_syafii', duration_days: 7, max_uses: 100, times_used: 0});
  await withEnv({TELEGRAM_BOT_TOKEN: 't', TELEGRAM_CHAT_ID: '1'}, async () => {
    for (let i = 0; i < 20; i++) {
      db.seed(`users/v${i}`, {email: `v${i}@example.test`, entitlements: {}});
      await api.redeemCode({code: 'SANTRI'}, {auth: {uid: `v${i}`, token: {email: `v${i}@example.test`, email_verified: true}}});
    }
  });
  assert.equal(sent.length, 15);
  assert.ok(sent.every((call: any) => !/v\d+@example\.test/.test(call[1].text)));
  assert.ok(sent[0][1].text.includes('v***@example.test'));
});

test('App Check gate: off by default, monitor lets calls through, enforce rejects calls without a token', async () => {
  const {api, db} = fixture();
  const call = (app?: any) => api.checkPaymentStatus({}, {auth: {uid: 'u', token: {}}, ...(app ? {app} : {})});
  await assert.rejects(call(), (e: any) => e.code === 'invalid-argument');
  db.seed('access_control/security', {app_check: 'enforce'});
  const real = Date.now; Date.now = () => real() + 120000;
  try {
    await assert.rejects(call(), (e: any) => e.code === 'failed-precondition');
    await assert.rejects(call({appId: 'a'}), (e: any) => e.code === 'invalid-argument');
  } finally { Date.now = real; }
});
