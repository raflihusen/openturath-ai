import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {copy,tr,faq} from '../src/copy.mjs';
import {articles} from '../src/articles.mjs';
import {renderPage} from '../src/pages.mjs';
import {releaseIssues} from '../src/core.mjs';
const json=p=>JSON.parse(fs.readFileSync(new URL('../'+p,import.meta.url),'utf8'));
const data={config:json('site.config.json'),catalog:json('content/catalog.json')};

test('single membership offer retains commercial source data and manual renewal',()=>{
 assert.deepEqual(data.config.plans.map(p=>[p.id,p.price,p.months]),[['tholib',49000,1],['tholib_6m',299000,6],['bahits',499000,12]]);
 assert.equal(data.config.appCommercialParity,'aligned-with-app-v1.0');
 for(const locale of ['id','en','ar']){
  const html=renderPage(locale,'access',data).body;
  assert.ok(html.includes('class="membership-banner"'));
  assert.ok(!/Rp 50\.000|IDR 50,000|٥٠٬٠٠٠/.test(html));
 }
});
test('V7: 18 AI profiles from the app; merged and hidden slugs redirect',()=>{
 assert.equal(data.catalog.length,18);
 assert.equal(data.catalog.filter(c=>c.status==='active').length,18);
 assert.ok(!data.catalog.some(c=>c.id==='habib-umar'));
 for(const slug of ['habib-umar','fatawa-masail','qawaid-fiqhiyyah'])for(const locale of ['id','en','ar']){
  const html=renderPage(locale,'library/'+slug,data).body;assert.match(html,/http-equiv="refresh"|<h1/);
 }
 for(const c of data.catalog){const html=renderPage('id','library/'+c.id,data).body;assert.ok(html.includes('id="daftar-kitab"'));const esc=s=>s.replaceAll('&','&amp;').replaceAll("'",'&#39;');assert.ok(html.includes(esc(c.name.id)));}
});
test('home keeps the live structure with V7 numbers',()=>{
 const html=renderPage('id','',data).body;
 assert.equal((html.match(/data-search-item /g)||[]).length,6);
 assert.ok(html.includes('data-value="5383"'));assert.ok(html.includes('data-value="812601332"'));
 assert.ok(!/Habib Umar|5\.370|Dua puluh/.test(html));
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
