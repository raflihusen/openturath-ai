import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {copy,tr,faq} from '../src/copy.mjs';
import {articles} from '../src/articles.mjs';
import {renderPage} from '../src/pages.mjs';
import {releaseIssues} from '../src/core.mjs';
const json=p=>JSON.parse(fs.readFileSync(new URL('../'+p,import.meta.url),'utf8'));
const data={config:json('site.config.json'),catalog:json('content/catalog.json')};

const appFacts=JSON.parse(await (await import('node:fs/promises')).readFile(new URL('../content/app-facts.json',import.meta.url),'utf8'));
test('single membership offer retains commercial source data and manual renewal',()=>{
 // Harga dan masa akses harus sama dengan aplikasi (content/app-facts.json).
 assert.deepEqual(data.config.plans.map(p=>[p.price,p.months]),appFacts.pricing.specialist.map(o=>[o.amount,o.months]));
 assert.equal(data.config.appCommercialParity,'pending-backend-mapping');
 for(const locale of ['id','en','ar']){
  const html=renderPage(locale,'access',data).body;
  assert.ok(html.includes('class="membership-banner"'));
  assert.ok(!html.includes('class="membership-card'));
  assert.ok(html.includes(copy[locale].memberFrom));
  assert.ok(html.includes(copy[locale].memberManual));
  assert.ok(html.includes(copy[locale].memberRefund));
 }
});
test('21 profiles include 20 active fields and an explicitly unavailable scholar',()=>{
 assert.equal(data.catalog.length,21);
 assert.equal(data.catalog.filter(c=>c.status==='active').length,20);
 const scholar=data.catalog.find(c=>c.id==='habib-umar');assert.equal(scholar.status,'preparing');
 for(const locale of ['id','en','ar']){
  const html=renderPage(locale,'library/habib-umar',data).body;
  assert.ok(html.includes(copy[locale].preparingBody));assert.ok(!html.includes('/download/'));
 }
});
test('home preserves the requested hero, catalogue and contextual verification FAQ',()=>{
 const html=renderPage('id','',data).body;
 assert.ok(html.includes(copy.id.hero));assert.ok(html.includes('AI for Islamic Scholarship'));
 assert.equal((html.match(/data-search-item /g)||[]).length,6);
 assert.equal((html.match(/class="step-number"/g)||[]).length,4);
 assert.ok(html.includes(faq.find(f=>f.id==='edition').q[0]));assert.ok(html.includes(copy.id.archiveBody));
 assert.ok(html.includes('/assets/scholarly-books-v6.webp'));assert.ok(!/100%|5\.074|170\.000/.test(html));
});
test('all UI and article strings have three nonempty translations, without silent fallback',()=>{
 assert.deepEqual(Object.keys(copy.id).sort(),Object.keys(copy.en).sort());
 assert.deepEqual(Object.keys(copy.id).sort(),Object.keys(copy.ar).sort());
 for(const l of ['id','en','ar'])for(const key of Object.keys(copy.id))assert.ok(tr(l,key).trim());
 assert.throws(()=>tr('ar','missing-test-key'),/Missing translation/);
 for(const article of Object.values(articles)){
  for(const values of [article.intro,...article.blocks.flatMap(b=>[b.heading,b.body])]){
   assert.equal(values.length,3);assert.ok(values.every(s=>typeof s==='string'&&s.trim()));
  }
 }
 for(const item of faq)for(const field of ['q','a'])assert.equal(item[field].length,3);
});
test('coming-soon platforms render no actionable download or alternative URL',()=>{
 const config=structuredClone(data.config);config.downloads=config.downloads.map(d=>({...d,comingSoon:true,alternativeUrl:'https://example.invalid/fallback'}));config.distribution={mode:'website-only',reason:'awaiting-release-artifact'};
 assert.deepEqual(releaseIssues(config),[]);
 delete config.distribution;
 assert.ok(releaseIssues(config).some(x=>x.includes('at least one')));
 const html=renderPage('en','download',{config}).body;
 assert.ok(!html.includes('data-download'));assert.ok(!html.includes('https://example.invalid/fallback'));
});
test('canonical app policy is linked across all policy pages and languages',()=>{
 for(const l of ['id','en','ar'])for(const route of ['terms','privacy','billing','ai-guidelines','account-deletion']){
  const html=renderPage(l,route,data).body;assert.ok(html.includes('/assets/kebijakan-aplikasi-v1.0.md'));
  assert.ok(html.includes(copy[l].legalVersion));
 }
 const legal=fs.readFileSync(new URL('../public/assets/kebijakan-aplikasi-v1.0.md',import.meta.url),'utf8');
 assert.equal((legal.match(/^### /gm)||[]).length,39);assert.ok(!/\$manager|\$contact|\$refund/.test(legal));
});
test('release gate rejects string prices',()=>{
 const config=structuredClone(data.config);config.plans[0].price='49000';
 assert.ok(releaseIssues(config).some(x=>x.includes('plans.price')));
});

test('shared glossary labels match the application dictionary in every locale',()=>{
 const glossary=json('content/glossary-map.json');
 for(const [website,app] of Object.entries(glossary.mapping))for(const [i,locale] of ['id','en','ar'].entries())assert.equal(copy[locale][website],glossary.terms[app][i]);
});
