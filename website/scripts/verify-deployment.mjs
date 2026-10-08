import fs from 'node:fs/promises';
import path from 'node:path';
const root=path.resolve(import.meta.dirname,'..');
const config=JSON.parse(await fs.readFile(path.join(root,'site.config.json'),'utf8'));
const base=process.env.DEPLOYMENT_URL||config.canonicalUrl;
const hosting=JSON.parse(await fs.readFile(path.join(root,'firebase.json'),'utf8'));
const expected=hosting.hosting.headers.find(r=>r.source==='**').headers;
const pages=await Promise.all(['id/','en/','ar/','id/tahawwulat/','id/privacy/'].map(async route=>{
 const url=new URL(route,base.endsWith('/')?base:base+'/').href;
 try{const response=await fetch(url,{signal:AbortSignal.timeout(15000)});const html=await response.text();
 return {url,status:response.status,headers:expected.map(({key,value})=>({name:key,expected:value,actual:response.headers.get(key),matches:response.headers.get(key)===value})),cloudflareBeacon:html.includes('static.cloudflareinsights.com')||html.includes('data-cf-beacon')};
 }catch(e){return {url,error:e.message};}
}));
const report={checkedAt:new Date().toISOString(),base,scope:'Read-only HTTP checks; no deployment or CDN changes',pages,passed:pages.every(p=>p.status===200&&p.headers.every(h=>h.matches))};
await fs.writeFile(path.join(root,'docs/DEPLOYMENT_QA.json'),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify(report,null,2));if(!report.passed)process.exitCode=1;
