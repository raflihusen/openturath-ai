import test from 'node:test';
import assert from 'node:assert/strict';
import {loadBackend} from './audit_harness.ts';

const DAY = 86400000;
const SECRET = 's'.repeat(40);
const caller = {auth: {uid: 'u', token: {email: 'u@example.test', email_verified: true}}};
const FATAWA = 'cmu6hh1nn0043jm04r4h40wdb', SYAFII = 'cms4ls3j60001l20439k1nqh4';

function fixture(rows: Record<string, any[]> = {}) {
  const f = loadBackend();
  f.db.seed('users/u', {email: 'u@example.test', name: 'Pengguna', plan: 'trial', entitlements: {}});
  f.axios.get = async (url: string) => {
    const cuid = Object.keys(rows).find(id => url.includes(`/services/${id}/`));
    return {data: {data: cuid && url.includes('status=PAID') && url.includes('page=1') ? rows[cuid] : []}};
  };
  return f;
}
const row = (extra: any = {}) => ({id: 'pay-1', payerEmail: 'U@Example.test', payerName: 'Pengguna', amount: 50000,
  paidAt: new Date(Date.now() - DAY).toISOString(), priceSchemeTitle: '1 Bulan', serviceTitle: 'Layanan', ...extra});
async function withEnv(values: Record<string, string>, fn: () => Promise<void>) {
  const previous = Object.fromEntries(Object.keys(values).map(k => [k, process.env[k]]));
  Object.assign(process.env, values);
  try { await fn(); } finally {
    for (const [k, v] of Object.entries(previous)) if (v === undefined) delete process.env[k]; else process.env[k] = v;
  }
}
const sync = (fn: () => Promise<void>) => withEnv({AKAL_API_KEY: 'test-only-key'}, fn);
const grants = (db: any) => [...db.docs.entries()].filter(([k]: any) => k.startsWith('access_grants/')).map(([, v]: any) => v);
function response() {
  return {code: 0, body: null as any, status(c: number) { this.code = c; return this; }, json(b: any) { this.body = b; }, send(b: any) { this.body = b; }};
}
const webhook = (data: any) => ({method: 'POST', headers: {}, body: {token: SECRET, data}});
const paid = (extra: any = {}) => ({id: 'wh-1', status: 'PAID', amount: 50000, payer: {email: 'u@example.test', name: 'Pengguna'},
  service: {name: "Super AI Fikih Syafi'i"}, priceScheme: {name: '1 Bulan'}, paidAt: new Date(Date.now() - DAY).toISOString(), ...extra});

test('zero-amount GoAkal transaction never grants access and is quarantined', () => sync(async () => {
  const {api, db} = fixture({[SYAFII]: [row({amount: 0})]});
  const result = await api.syncAkalPurchases({}, caller);
  assert.equal(result.count, 0);
  assert.deepEqual(db.docs.get('users/u').entitlements, {});
  assert.equal(grants(db).length, 0);
  assert.ok([...db.docs.values()].some((d: any) => d.reason === 'invalid_billing_identity_or_amount'));
}));

test('a transaction without a provider ID is quarantined instead of minting a fresh ID', () => sync(async () => {
  const {api, db} = fixture({[SYAFII]: [row({id: undefined})]});
  assert.equal((await api.syncAkalPurchases({}, caller)).count, 0);
  assert.equal(grants(db).length, 0);
}));

test('Fatawa purchase unlocks the scope the Fatawa assistant requires', () => sync(async () => {
  const {api, db, catalog} = fixture({[FATAWA]: [row()]});
  const result = await api.syncAkalPurchases({}, caller);
  assert.deepEqual([...result.synced], ['Super AI Fatawa & Masail']);
  const user = db.docs.get('users/u');
  const required = catalog.AGENT_ENTITLEMENTS.fatawa_masail;
  assert.equal(api.getEntitlementAccess(user, required).active, true);
  assert.equal(api.getEntitlementAccess(user, 'fiqh_tahawwulat').active, false);
  assert.equal(user.plan, 'trial');
  const [grant] = grants(db);
  assert.equal(grant.kind, 'payment'); assert.equal(grant.scope, required); assert.equal(grant.amount, 50000);
  assert.equal(grant.uid, 'u'); assert.equal(grant.provider, 'goakal');
}));

test('sync is idempotent and never shortens a longer entitlement', () => sync(async () => {
  const {api, db} = fixture({[SYAFII]: [row()]});
  const later = Date.now() + 200 * DAY;
  db.docs.get('users/u').entitlements = {fiqh_syafii: {plan: 'voucher_access', status: 'active', expiry: {toMillis: () => later, toDate: () => new Date(later)}}};
  await api.syncAkalPurchases({}, caller);
  await api.syncAkalPurchases({}, caller);
  assert.equal(grants(db).length, 1);
  assert.equal(db.docs.get('users/u').entitlements.fiqh_syafii.plan, 'voucher_access');
}));

test('sync is rate limited per account', () => sync(async () => {
  const {api} = fixture();
  for (let i = 0; i < 3; i++) await api.syncAkalPurchases({}, caller);
  await assert.rejects(api.syncAkalPurchases({}, caller), (e: any) => e.code === 'resource-exhausted');
}));

test('"12 Bulan" is an annual plan and expired periods are ignored', () => sync(async () => {
  const f = fixture({[SYAFII]: [row({id: 'old', paidAt: new Date(Date.now() - 40 * DAY).toISOString()}),
    row({id: 'annual', priceSchemeTitle: '12 Bulan', paidAt: new Date(Date.now() - 40 * DAY).toISOString()})]});
  assert.equal(f.api.detectDurationMonths('12 Bulan', ''), 12);
  await f.api.syncAkalPurchases({}, caller);
  const all = grants(f.db);
  assert.equal(all.length, 1);
  assert.ok(all[0].expires_ms - all[0].starts_ms > 360 * DAY);
}));

test('webhook maps a product to its own module only and leaves the global plan alone', () => withEnv({AKAL_WEBHOOK_SECRET: SECRET}, async () => {
  const {api, db} = fixture();
  const res = response();
  await api.akalWebhook(webhook(paid({service: {name: 'Super AI Fikih Hanafi'}})), res);
  assert.equal(res.code, 200);
  const user = db.docs.get('users/u');
  assert.deepEqual(Object.keys(user.entitlements), ['fiqh_hanafi']);
  assert.equal(user.plan, 'trial');
  assert.equal(user.subscription_expiry, undefined);
  assert.equal(api.getEntitlementAccess(user, 'fiqh_tahawwulat').active, false);
}));

test('webhook quarantines an unknown product and a zero amount', () => withEnv({AKAL_WEBHOOK_SECRET: SECRET}, async () => {
  const {api, db} = fixture();
  for (const data of [paid({service: {name: 'Kelas Lain'}}), paid({amount: 0})]) {
    const res = response();
    await api.akalWebhook(webhook(data), res);
    assert.equal(res.body.verification_required, true);
  }
  assert.deepEqual(db.docs.get('users/u').entitlements, {});
  assert.equal(grants(db).length, 0);
}));

test('webhook replay without paidAt cannot extend the period', () => withEnv({AKAL_WEBHOOK_SECRET: SECRET}, async () => {
  const {api, db} = fixture();
  await api.akalWebhook(webhook(paid({paidAt: undefined})), response());
  const first = db.docs.get('transactions/wh-1').expires_ms;
  db.docs.get('transactions/wh-1').paid_ms -= 5 * DAY; db.docs.get('transactions/wh-1').expires_ms -= 5 * DAY;
  await api.akalWebhook(webhook(paid({paidAt: undefined})), response());
  assert.equal(db.docs.get('transactions/wh-1').expires_ms, first - 5 * DAY);
  assert.equal(grants(db).length, 1);
}));

test('webhook rejects a wrong token', () => withEnv({AKAL_WEBHOOK_SECRET: SECRET}, async () => {
  const {api} = fixture();
  const res = response();
  await api.akalWebhook({method: 'POST', headers: {}, body: {token: 'x'.repeat(40), data: paid()}}, res);
  assert.equal(res.code, 401);
}));

test('a purchase by an unregistered buyer is recorded without grants and restored on signup', () => withEnv({AKAL_WEBHOOK_SECRET: SECRET}, async () => {
  const {api, db} = fixture();
  const res = response();
  await api.akalWebhook(webhook(paid({payer: {email: 'new@example.test'}})), res);
  assert.equal(res.code, 200);
  assert.equal(grants(db).length, 0);
  assert.equal(db.docs.get('transactions/wh-1').customer_email, 'new@example.test');
}));

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

test('an early renewal continues from the end of the previous paid period, once', () => sync(async () => {
  const first = new Date(Date.now() - 20 * DAY).toISOString(), second = new Date(Date.now() - 2 * DAY).toISOString();
  const {api, db} = fixture({[SYAFII]: [row({id: 'p1', paidAt: first}), row({id: 'p2', paidAt: second})]});
  await api.syncAkalPurchases({}, caller);
  await api.syncAkalPurchases({}, caller);
  const all = grants(db).sort((a: any, b: any) => a.starts_ms - b.starts_ms);
  assert.equal(all.length, 2);
  assert.equal(all[1].starts_ms, all[0].expires_ms);
  assert.equal(all[1].expires_ms - all[0].starts_ms, 60 * DAY);
  assert.equal(db.docs.get('users/u').entitlements.fiqh_syafii.expiry.toMillis(), all[1].expires_ms);
}));

test('a chained renewal stays valid even when each period alone would look expired', () => sync(async () => {
  const first = new Date(Date.now() - 40 * DAY).toISOString(), second = new Date(Date.now() - 35 * DAY).toISOString();
  const {api, db} = fixture({[SYAFII]: [row({id: 'p2', paidAt: second}), row({id: 'p1', paidAt: first})]});
  assert.equal((await api.syncAkalPurchases({}, caller)).count, 1);
  const [grant] = grants(db);
  assert.equal(grant.transaction_id, 'p2');
  assert.ok(grant.expires_ms > Date.now() + 19 * DAY && grant.expires_ms < Date.now() + 21 * DAY);
}));
