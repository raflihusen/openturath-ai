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
const modules=await read('content/metadata/metadata_modul_lengkap.json');
const training=await read('content/metadata/metadata_training_seluruh_ai.json');
const config=await read('site.config.json');

test('collection totals match all 20 module snapshots and never include preparing profiles',()=>{
 assert.deepEqual(collectionTotals(catalog),{disciplines:20,books:5370,volumes:11901,pages:4182803,words:1148410539,partitions:2876,volumesLowerBound:true});
 for(const c of catalog.filter(c=>c.status==='active')){
  const m=modules[c.appAgentId]||modules[c.metadataKey]||Object.values(modules).find(m=>m.nama===c.name.id);
  assert.ok(m,`Source metadata for ${c.id}`);
  assert.equal(c.metadata.books,m.total_kitab);assert.equal(c.metadata.pages,m.total_halaman);assert.equal(c.metadata.words,m.total_kata);
 }
 assert.equal(Object.values(training).reduce((n,m)=>n+(m.total_partisi_notebooklm||0),0),collectionTotals(catalog).partitions);
 const preparing=catalog.find(c=>c.status==='preparing');
 assert.equal(collectionMetadata('id',preparing),'');
});
test('each discipline has distinct substantial descriptions and real metadata in three languages',()=>{
 for(const locale of ['id','en','ar']){
  assert.equal(new Set(catalog.map(c=>c.description[locale])).size,21);
  for(const c of catalog){assert.ok(c.description[locale].length>90);if(c.status==='active')assert.ok(collectionMetadata(locale,c).includes('collection-metrics'));}
  const stats=collectionStats(locale,catalog);
  for(const amount of [5370,11901,4182803,1148410539,2876])assert.ok(stats.includes(`data-value="${amount}"`));
 }
});
test('FAQ asks real questions in all locales and covers the full adoption journey',()=>{
 assert.equal(new Set(faq.map(f=>f.id)).size,faq.length);
 for(const id of ['teacher','verification','edition','sources','payment','notes','availability','platforms','refund','account'])assert.ok(faq.some(f=>f.id===id));
 for(const f of faq)for(let i=0;i<3;i++){assert.match(f.q[i],/[?؟]$/);assert.ok(f.a[i].length>100);}
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
  await fs.writeFile(path.join(root,'public',new URL(c.downloads[0].url).pathname),'invalid test fixture');
  const issues=await downloadIntegrityIssues(c,root);
  assert.ok(issues.some(e=>e.includes('SHA-256 mismatch')));assert.ok(issues.some(e=>e.includes('byte size mismatch')));assert.ok(issues.some(e=>e.includes('not a ZIP')));
 }finally{await fs.rm(root,{recursive:true,force:true});}
});

test('metadata drift and duplicate modules fail validation before a build',()=>{
 assert.deepEqual(validateCatalogMetadata(catalog,modules,training),[]);
 const changed=structuredClone(catalog);changed[0].metadata.books=87;
 assert.ok(validateCatalogMetadata(changed,modules,training).some(e=>e.includes('fiqh-syafii.books')));
 changed[1].metadataKey=changed[0].metadataKey;
 assert.ok(validateCatalogMetadata(changed,modules,training).some(e=>e.includes('Duplicate module')));
});
