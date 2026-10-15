import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import {collectionTotals,collectionMetadata,collectionStats,validateCatalogMetadata} from '../src/metadata.mjs';
import {faq} from '../src/copy.mjs';
import {releaseIssues} from '../src/core.mjs';
import {downloadIntegrityIssues} from '../scripts/download-integrity.mjs';
const read=async p=>JSON.parse(await fs.readFile(new URL('../'+p,import.meta.url),'utf8'));
const catalog=await read('content/catalog.json');
const infoAi=await read('content/metadata/info_ai.json');
const config=await read('site.config.json');

test('V7: collection totals equal the 18 AI records in the app (info_ai.json)',()=>{
 const sum=k=>infoAi.reduce((n,x)=>n+(k(x)||0),0);
 assert.deepEqual(collectionTotals(catalog),{disciplines:18,books:sum(x=>x.isi.jumlah_kitab),words:sum(x=>x.isi.jumlah_kata),lectures:sum(x=>x.isi.jumlah_muhadharah),partitions:sum(x=>x.cara_disusun.berkas_notebooklm),records:46048});
 assert.deepEqual([collectionTotals(catalog).books,collectionTotals(catalog).words,collectionTotals(catalog).lectures,collectionTotals(catalog).partitions],[5383,812601332,3001,3500]);
 assert.ok(catalog.every(c=>c.status==='active'));
});
test('each discipline has distinct substantial descriptions and real metadata in three languages',()=>{
 const t=collectionTotals(catalog);
 for(const locale of ['id','en','ar']){
  assert.equal(new Set(catalog.map(c=>c.description[locale])).size,18);
  for(const c of catalog){assert.ok(c.description[locale].length>90);assert.ok(collectionMetadata(locale,c).includes('collection-metrics'));}
  const stats=collectionStats(locale,catalog);
  for(const amount of [t.books,t.words,t.lectures,t.records,t.partitions])assert.ok(stats.includes(`data-value="${amount}"`));
 }
});
test('FAQ asks real questions in all locales and keeps the Habib Umar entry hidden',()=>{
 assert.equal(new Set(faq.map(f=>f.id)).size,faq.length);
 for(const id of ['teacher','verification','edition','sources','payment','notes','platforms','refund','account'])assert.ok(faq.some(f=>f.id===id));
 assert.ok(!faq.some(f=>f.id==='availability'||/Habib Umar|الحبيب عمر/.test(f.q.join(' ')+f.a.join(' '))));
 for(const f of faq)for(let i=0;i<3;i++){assert.match(f.q[i],/[?؟]$/);assert.ok(f.a[i].length>100);}
 const pay=faq.find(f=>f.id==='payment');assert.ok(pay.a[0].includes('Rp 49.000'));assert.ok(pay.a[1].includes('IDR 49,000'));assert.ok(pay.a[2].includes('٤٩٬٠٠٠'));
});
test('website-only release is explicit and cannot silently publish an active download',()=>{
 const draft=structuredClone(config);
 draft.distribution={mode:'website-only',reason:'awaiting-release-artifact'};
 for(const d of draft.downloads){d.comingSoon=true;delete d.sha256;delete d.size;}
 assert.equal(draft.distribution.mode,'website-only');assert.deepEqual(releaseIssues(draft),[]);
 draft.downloads[0].comingSoon=false;
 assert.ok(releaseIssues(draft).some(e=>e.includes('cannot expose')));
 delete draft.distribution;
 assert.ok(releaseIssues(draft).some(e=>e.includes('real APK hash')));
});
test('release integrity blocks missing bytes and mismatched APK hashes or sizes',async()=>{
 const root=await fs.mkdtemp(path.join(os.tmpdir(),'openturath-apk-test-'));
 try{
  const c=structuredClone(config);c.downloads=c.downloads.filter(d=>d.type==='apk');
  Object.assign(c.downloads[0],{comingSoon:false,sha256:'0'.repeat(64),sizeBytes:100});
  assert.ok((await downloadIntegrityIssues(c,root)).some(e=>e.includes('unavailable')));
  await fs.mkdir(path.join(root,'public/downloads'),{recursive:true});
  await fs.writeFile(path.join(root,'public/downloads/openturath-v1.0.51.apk'),'invalid test fixture');
  const issues=await downloadIntegrityIssues(c,root);
  assert.ok(issues.some(e=>e.includes('SHA-256 mismatch')));assert.ok(issues.some(e=>e.includes('byte size mismatch')));assert.ok(issues.some(e=>e.includes('not a ZIP')));
 }finally{await fs.rm(root,{recursive:true,force:true});}
});

test('metadata drift against the app fails validation before a build',()=>{
 assert.deepEqual(validateCatalogMetadata(catalog,infoAi),[]);
 const changed=structuredClone(catalog);changed[1].metadata.books=87;
 assert.ok(validateCatalogMetadata(changed,infoAi).some(e=>e.includes(changed[1].id)));
 assert.ok(validateCatalogMetadata(changed.slice(1),infoAi).some(e=>e.includes('Jumlah AI')));
});
