import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {articles} from '../src/articles.mjs';
import {copy,faq} from '../src/copy.mjs';
const {principles}=JSON.parse(fs.readFileSync(new URL('../content/adab.json',import.meta.url)));
test('adab page and teacher FAQ share the supplied seven-principle editorial source',()=>{
 assert.equal(principles.length,7);assert.equal(new Set(principles.map(p=>p.id)).size,7);
 assert.deepEqual(articles['ai-guidelines'].blocks.slice(0,7),principles.map(({heading,body})=>({heading,body})));
 assert.deepEqual(faq.find(f=>f.id==='teacher').a,principles[0].body);
 for(const p of principles)for(const field of ['heading','body']){assert.equal(p[field].length,3);assert.ok(p[field].every(s=>s.trim().length>10));}
 assert.deepEqual(articles['ai-guidelines'].blocks[7].body,['id','en','ar'].map(l=>copy[l].adabSourceNote));
});
