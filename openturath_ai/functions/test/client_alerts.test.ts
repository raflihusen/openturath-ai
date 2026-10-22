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
