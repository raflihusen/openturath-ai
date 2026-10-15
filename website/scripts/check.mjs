import fs from 'node:fs/promises';
import path from 'node:path';
import crypto from 'node:crypto';
import {copy} from '../src/copy.mjs';
import {allRoutes} from '../src/pages.mjs';
import {locales} from '../src/core.mjs';
const root=path.resolve(import.meta.dirname,'..'),dist=path.join(root,'dist');
const json=async f=>JSON.parse(await fs.readFile(path.join(root,f),'utf8'));
const d={config:await json('site.config.json'),catalog:await json('content/catalog.json'),books:await json('content/books.json'),evaluation:await json('content/evaluation.json'),evidence:await json('content/evidence.json')};
const errors=[];const check=(ok,message)=>{if(!ok)errors.push(message);};
for(const l of locales)for(const [key,value] of Object.entries(copy.id))check(typeof copy[l][key]==='string'&&copy[l][key].trim(),`Translation ${l}:${key}`);
for(const type of ['catalog','books','evidence'])check(new Set(d[type].map(x=>x.id)).size===d[type].length,`Duplicate ${type} IDs`);
for(const c of d.catalog)for(const l of locales)for(const f of ['name','description'])check(Boolean(c[f][l]),`Collection ${c.id} ${f}:${l}`);
const original=await fs.readFile(path.join(root,'content/q001-original.md'),'utf8');
for(const r of d.evaluation.runs){check(crypto.createHash('sha256').update(r.text).digest('hex')===r.sha256,`Transcript changed: ${r.id}`);check(original.includes(r.text),`Original provenance missing: ${r.id}`);}
const run=d.evaluation.runs.find(r=>r.id==='openturath');
for(const v of d.evidence){check(run.text.includes(v.quote),`Quote altered: ${v.id}`);check(['not-reviewed','matched','partial','mismatch','unverifiable'].includes(v.status),`Evidence status ${v.id}`);if(v.status!=='not-reviewed'){check(Boolean(v.reviewer&&v.reviewDate&&v.note),`Evidence review metadata: ${v.id}`);if(v.status==='matched')check(Boolean(v.sourceText&&v.edition&&v.sourceUrl),`Matched evidence lacks source: ${v.id}`);}}
let links=0,files=0;const routes=allRoutes(d);
for(const l of locales)for(const route of routes){const file=path.join(dist,l,route,'index.html');const html=await fs.readFile(file,'utf8');files++;check(html.includes(`<html lang="${l}" dir="${l==='ar'?'rtl':'ltr'}">`),`Locale/RTL ${file}`);check((html.match(/<h1[ >]/g)||[]).length===1,`One h1 ${file}`);check(!/\b(?:undefined|NaN)\b/.test(html),`Missing value ${file}`);
 const ids=new Set([...html.matchAll(/\bid="([^"]+)"/g)].map(m=>m[1]));
 for(const m of html.matchAll(/(?:href|src)="([^"]*)"/g)){const u=m[1];check(u!==''&&u!=='#',`Empty link ${file}`);if(u.startsWith('#')){check(ids.has(u.slice(1)),`Missing fragment ${u} ${file}`);continue;}if(!u.startsWith('/'))continue;links++;let dest=path.join(dist,u.split(/[?#]/)[0]);if(u.split(/[?#]/)[0].endsWith('/'))dest=path.join(dest,'index.html');try{await fs.access(dest);}catch{errors.push(`Broken internal link ${u} from ${file}`);}}
}
if(errors.length){console.error(errors.join('\n'));process.exit(1);}console.log(`Checked ${files} localized pages, ${links} local links/assets, all translations, 6 archive hashes, and ${d.evidence.length} quotation records. No errors.`);
