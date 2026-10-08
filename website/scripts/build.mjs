import {publicationIntegrityIssues} from './publication-integrity.mjs';
import fs from 'node:fs/promises';
import {validateCatalogMetadata} from '../src/metadata.mjs';
import {downloadIntegrityIssues} from './download-integrity.mjs';
import {execFileSync} from 'node:child_process';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {releaseIssues,locales,pathFor,escapeHtml as e} from '../src/core.mjs';
import {renderPage,allRoutes} from '../src/pages.mjs';
import {layout} from '../src/render.mjs';
const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const read=async name=>JSON.parse(await fs.readFile(path.join(root,name),'utf8'));
const config=await read('site.config.json');
const production=process.argv.includes('--release');
const integrity=publicationIntegrityIssues({config,proof:await read('content/proof.json'),evidence:await read('content/evidence.json'),releases:await read('content/releases.json'),appFacts:await read('content/app-facts.json')});
if(integrity.length)throw new Error(integrity.join('\n'));
const issues=[...releaseIssues(config),...await downloadIntegrityIssues(config,root)];
if(production&&issues.length){console.error('Production release blocked:\n'+issues.map(x=>' - '+x).join('\n'));process.exit(1);}
const data={config,catalog:await read('content/catalog.json'),books:await read('content/books.json'),evaluation:await read('content/evaluation.json'),evidence:await read('content/evidence.json'),corrections:await read('content/corrections.json'),training:await read('content/metadata/metadata_training_seluruh_ai.json')};
const metadataIssues=validateCatalogMetadata(data.catalog,await read('content/metadata/metadata_modul_lengkap.json'),await read('content/metadata/metadata_training_seluruh_ai.json'));
if(metadataIssues.length)throw new Error(metadataIssues.join('\n'));
for(const c of data.catalog){const n=data.training[c.metadataKey]?.total_kitab;if(n!=null&&n!==c.metadata?.books)c.countReview={trainingBooks:n};}
const dist=path.join(root,'dist');await fs.mkdir(dist,{recursive:true});
// Only remove our generated directory; never touch config, source or report data.
await fs.rm(dist,{recursive:true,force:true});await fs.mkdir(dist,{recursive:true});await fs.cp(path.join(root,'public'),dist,{recursive:true});
await fs.writeFile(path.join(dist,'assets/corpus-metadata.json'),JSON.stringify({source:'app metadata snapshots',uniqueWorksVerified:false,collections:data.catalog.filter(c=>c.status==='active').map(c=>({id:c.id,name:c.name,moduleBooks:c.metadata.books,trainingBooks:data.training[c.metadataKey]?.total_kitab,partitions:c.metadata.partitions}))},null,2));
await fs.copyFile(path.join(root,'src/copy.mjs'),path.join(dist,'assets/ui.mjs'));
await fs.copyFile(path.join(root,'src/core.mjs'),path.join(dist,'assets/core.mjs'));
await fs.copyFile(path.join(root,'content/q001-original.md'),path.join(dist,'assets/q001-original.md'));
if(config.canonicalUrl)for(const l of locales)execFileSync('python3',[path.join(root,'scripts/qr.py'),new URL(pathFor(l,'download'),config.canonicalUrl).href,path.join(dist,'assets','download-'+l+'.svg')]);
const routes=allRoutes(data);
if(new Set(routes).size!==routes.length||routes.some(r=>r&&!/^[a-zA-Z0-9][a-zA-Z0-9./-]*$/.test(r)||r.includes('..')))throw Error('Unsafe or duplicate route');
for(const l of locales)for(const route of routes){const p=renderPage(l,route,data);let html=layout({l,route,...p,config,production});html=html.replace('<script src="/assets/site.js" defer>','<script src="/assets/site.js" type="module">');const dest=path.join(dist,l,route,'index.html');await fs.mkdir(path.dirname(dest),{recursive:true});await fs.writeFile(dest,html);}
const idHomePage = await fs.readFile(path.join(dist, 'id/index.html'), 'utf8');
const rootPage = idHomePage.replace('<head>', '<head><script src="/assets/entry.js"></script>');
await fs.writeFile(path.join(dist, 'index.html'), rootPage);
await fs.copyFile(path.join(dist,'id/404/index.html'),path.join(dist,'404.html'));
const urls=config.canonicalUrl?locales.flatMap(l=>routes.filter(r=>r!=='404').map(r=>new URL(pathFor(l,r),config.canonicalUrl).href)):[];
await fs.writeFile(path.join(dist,'sitemap.xml'),`<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">${urls.map(u=>`<url><loc>${e(u)}</loc></url>`).join('')}</urlset>`);
await fs.writeFile(path.join(dist,'robots.txt'),production?`User-agent: *\nAllow: /\nDisallow: /api/\nSitemap: ${config.canonicalUrl.replace(/\/$/,'')}/sitemap.xml\n`:'User-agent: *\nDisallow: /\n');
await fs.writeFile(path.join(dist,'_headers'),`/*\n  X-Content-Type-Options: nosniff\n  Referrer-Policy: strict-origin-when-cross-origin\n  X-Frame-Options: DENY\n  Permissions-Policy: camera=(), microphone=(), geolocation=()\n  Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; font-src 'self'; img-src 'self' data:; connect-src 'self'; frame-ancestors 'none'; base-uri 'none'; form-action 'self'\n`);
await fs.writeFile(path.join(root,'docs/BUILD_REPORT.json'),JSON.stringify({generatedAt:new Date().toISOString(),mode:production?'production':'preview',routes:routes.length*3+1,locales,collections:data.catalog.length,responses:data.evaluation.runs.length,productionBlockers:issues,validationScope:"website artifact only",distribution:config.distribution||{mode:"app-release"},operationalWarnings:config.appCommercialParity!=="verified-production"?["Prices match local app source; production checkout and entitlements remain unverified.","APK artifact not supplied; website-only mode exposes no active binary download.","Production transactions and infrastructure are not verified by this build."]:[]},null,2));
console.log(`Built ${routes.length*3+1} HTML pages; ${data.catalog.length} collections; ${data.evaluation.runs.length} original answers. Mode: ${production?'production':'preview (noindex)'}.`);
if(issues.length)console.log(`${issues.length} owner configuration requirements recorded in docs/BUILD_REPORT.json.`);

execFileSync(process.execPath,[path.join(root,'scripts/check.mjs')],{stdio:'inherit'});
