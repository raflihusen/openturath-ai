import test from 'node:test';
import assert from 'node:assert/strict';
import {loadBackend} from './audit_harness.ts';

const specialists = ['fiqh_syafii','fiqh_hanafi','fiqh_maliki','fiqh_hanbali',
  'fiqh_muqaran','fatawa_masail','qawaid_fiqhiyyah','hadits','syarah_hadits',
  'musthalah_hadits','tafsir','tajwid_qiraat','ushul_fiqh','tarikh',
  'thabaqat_rijal','tasawwuf','aqidah','nahwu_sharaf','bibliografi_faharis'];

test('all 19 published disciplines resolve to the launch price without global access', () => {
  const {api} = loadBackend();
  for (const agent of specialists) {
    const offer = api.resolvePlanPricing(agent, 'tholib_1m');
    assert.equal(offer.amount, 50000, agent);
    assert.equal(offer.durationMonths, 1, agent);
    assert.ok(!['all_access','all_ai'].includes(offer.entitlementKey), agent);
  }
});
test('Tahawwulat duration prices and aliases retain the correct calendar months', () => {
  const {api} = loadBackend();
  for (const [plan, amount, months] of [
    ['tholib_1m',300000,1], ['tholib_6m',1499000,6], ['bahits_1y',1999000,12],
    ['1m',300000,1], ['6m',1499000,6], ['1y',1999000,12],
  ] as const) {
    const offer = api.resolvePlanPricing('fiqh_tahawwulat', plan);
    assert.equal(offer.amount, amount);
    assert.equal(offer.durationMonths, months);
    assert.equal(offer.entitlementKey, 'fiqh_tahawwulat');
  }
});
test('stale offer is rejected before invoice creation or gateway calls', async () => {
  const {api,db,sent} = loadBackend();
  await assert.rejects(api.createCheckout({agentId:'fiqh_syafii',plan:'tholib_1m',
    name:'Reader',email:'reader@example.test',phone:'+628123456789',
    expectedAmount:49000,pricingRevision:'perdana-2026-09-20'}, {auth:{uid:'reader'}}),
    (error:any) => error.code === 'failed-precondition');
  assert.equal([...db.docs.keys()].filter(k=>k.startsWith('transactions/')).length,0);
  assert.equal(sent.length,0);
});
test('old pricing revision and noninteger expected prices are rejected', async () => {
  const {api,db} = loadBackend();
  for (const [amount,revision] of [[50000,'old'],['50000','perdana-2026-09-20'],[NaN,'perdana-2026-09-20']]) {
    await assert.rejects(api.createCheckout({agentId:'fiqh_syafii',plan:'tholib_1m',
      name:'Reader',email:'reader@example.test',expectedAmount:amount,pricingRevision:revision},
      {auth:{uid:'reader'}}));
  }
  assert.equal(db.docs.size,0);
});
test('hidden all-access and unknown products remain unavailable for checkout', () => {
  const {api} = loadBackend();
  for (const id of ['all_ai','all_access','unknown','fiqh_syafii_evil']) {
    assert.throws(()=>api.resolvePlanPricing(id,'tholib_1m'));
  }
});
