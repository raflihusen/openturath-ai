import fs from 'node:fs/promises';
import path from 'node:path';
import assert from 'node:assert/strict';
import {spawn} from 'node:child_process';
const {chromium}=await import(process.env.PLAYWRIGHT_MODULE||'playwright');
const root=path.resolve(import.meta.dirname,'..');
const server=spawn('python3',[path.join(root,'tests/browser_server.py')]);
server.stderr.on('data',d=>process.stderr.write(d));
const origin=await new Promise((resolve,reject)=>{server.stdout.once('data',d=>resolve(d.toString().trim()));server.once('exit',code=>reject(new Error('Fixture server exited '+code)))});
const results={browser:'',pages:[],interactions:[],accessibility:[],errors:[],accessibilityMode:'Stable rendering with reduced motion; motion tested separately'};
let browser;
try{
 browser=await chromium.launch({executablePath:process.env.BROWSER_EXECUTABLE||undefined,headless:true,args:['--no-sandbox','--disable-dev-shm-usage','--disable-gpu']});results.browser=await browser.version();
 const page=await browser.newPage({viewport:{width:1440,height:1080}});
 page.on('pageerror',e=>results.errors.push(e.message));
 page.on('response',r=>{if(r.status()>=400&&!r.url().includes('/api/reports'))results.errors.push(`${r.status()} ${r.url()}`)});
 for(const locale of ['id','en','ar'])for(const width of [1440,390,320])for(const route of ['','library/','access/','download/','terms/','privacy/','billing/','ai-guidelines/','report/','research/q001/']){
  await page.setViewportSize({width,height:width===1440?1080:844});await page.goto(`${origin}/${locale}/${route}`);await page.evaluate(async()=>{await document.fonts.ready;await Promise.all([...document.images].map(i=>i.decode().catch(()=>{})));await new Promise(r=>requestAnimationFrame(()=>requestAnimationFrame(r)));});
  const metrics=await page.evaluate(()=>({overflow:document.documentElement.scrollWidth>innerWidth+1,dir:document.documentElement.dir,h1:document.querySelectorAll('h1').length}));
  assert.equal(metrics.overflow,false,`${locale}/${route} overflows at ${width}`);assert.equal(metrics.dir,locale==='ar'?'rtl':'ltr');assert.equal(metrics.h1,1);
  results.pages.push({locale,route,width,...metrics});
  if(route===''&&width!==320)await page.screenshot({path:path.join(root,`docs/previews/v6/home-${locale}-${width}.png`),fullPage:false});
  if(route==='access/'&&locale==='id'&&width===1440)await page.screenshot({path:path.join(root,'docs/previews/v6/membership-id.png'),fullPage:true});
 }
 await page.setViewportSize({width:1440,height:1080});await page.goto(origin+'/id/');
 assert.equal(await page.locator('[data-search-item]:visible').count(),21);
 await page.locator('[data-search]').fill('الْفِقْه الشَّافِعِي');assert.equal(await page.locator('[data-search-item]:visible').count(),1);
 await page.locator('[type=reset]').click();await page.locator('[data-filter=hadith]').click();assert.equal(await page.locator('[data-search-item]:visible').count(),3);
 await page.locator('[data-search]').fill('no-such-discipline');assert.equal(await page.locator('[data-search-item]:visible').count(),0);assert.equal(await page.locator('[data-empty]').isVisible(),true);
 await page.locator('[type=reset]').click();assert.equal(await page.locator('[data-search-item]:visible').count(),21);
 results.interactions.push('Arabic diacritic search, discipline filter, empty state, reset, URL state');
 const description=await page.locator('.hero-description').evaluate(e=>({height:e.clientHeight,lineHeight:parseFloat(getComputedStyle(e).lineHeight)}));assert.ok(Math.abs(description.height/description.lineHeight-2)<.1);results.interactions.push('Desktop Indonesian hero description occupies two lines');
 await page.locator('[data-dialog=source-dialog]').click();assert.equal(await page.locator('#source-dialog').evaluate(e=>e.open),true);await page.keyboard.press('Escape');assert.equal(await page.locator('[data-dialog=source-dialog]').evaluate(e=>e===document.activeElement),true);results.interactions.push('Source dialog opens, Escape closes, keyboard focus restored');
 await page.locator('.theme-toggle').click();await page.reload();assert.equal(await page.locator('html').getAttribute('data-theme'),'dark');await page.screenshot({path:path.join(root,'docs/previews/v6/light-id.png')});await page.locator('.theme-toggle').click();results.interactions.push('Theme persists after reload');
 await page.goto(origin+'/id/?q=hadits&field=hadith#assistants');await page.locator('.locale-trigger').click();await page.locator('#language-dialog [data-locale=ar]').click();assert.ok(page.url().includes('/ar/?q=hadits&field=hadith#assistants'));results.interactions.push('Language switch preserves route, query and fragment');
 await page.setViewportSize({width:390,height:844});await page.goto(origin+'/ar/');await page.locator('.mobile-menu').click();await page.locator('#menu-dialog nav a[href="/ar/access/"]').first().click();assert.ok(page.url().endsWith('/ar/access/'));results.interactions.push('Arabic mobile menu navigation');
 await page.goto(origin+'/id/download/');assert.equal(await page.locator('[data-coming-soon] a[data-download]').count(),0);results.interactions.push('Unavailable platforms expose no download links');
 await page.goto(origin+'/id/');
 const mobileDownload=await page.locator('.nav-download').boundingBox();assert.ok(mobileDownload&&mobileDownload.y>=0&&mobileDownload.y+mobileDownload.height<844);await page.locator('.nav-download').click();assert.ok(page.url().endsWith('/id/download/'));results.interactions.push('Mobile first viewport contains a working accessible download link');
 await page.goto(origin+'/id/');const firstFAQ=page.locator('.home-faq details').first();assert.equal(await page.locator('.home-faq details').count(),10);await firstFAQ.locator('summary').focus();await page.keyboard.press('Enter');assert.equal(await firstFAQ.evaluate(e=>e.open),true);await page.keyboard.press('Space');assert.equal(await firstFAQ.evaluate(e=>e.open),false);results.interactions.push('Ten real FAQ answers toggle with Enter and Space, preserving focus');
 for(const [metric,value] of Object.entries({disciplines:'20',books:'5370',volumes:'11901',pages:'4182803',words:'1148410539',partitions:'2876'}))assert.equal(await page.locator(`[data-metric="${metric}"]`).getAttribute('data-value'),value);
 assert.equal(await page.locator('.scholar-hero').evaluate(e=>e.nextElementSibling.classList.contains('collection-scale')),true);results.interactions.push('Six computed metadata totals appear immediately after the hero');
 await page.goto(origin+'/id/report/');await page.locator('[name=message]').fill('Synthetic browser QA report, no personal data.');await page.locator('[name=consent]').check();await page.locator('[type=submit]').click();await page.locator('.form-status').filter({hasText:/OT-/}).waitFor();results.interactions.push('Report saved through real local API with report ID');
 await page.route('**/api/reports',route=>route.fulfill({status:503,contentType:'application/json',body:'{"error":"reports_unavailable"}'}));await page.locator('[name=message]').fill('Synthetic failed delivery test for browser QA.');await page.locator('[name=consent]').check();await page.locator('[type=submit]').click();await page.waitForFunction(()=>document.querySelector('[type=submit]').disabled===false);assert.ok((await page.locator('.form-status').textContent()).length>5);assert.ok((await page.locator('[name=message]').inputValue()).includes('Synthetic'));const downloaded=page.waitForEvent('download');await page.locator('[data-save-report]').click();await downloaded;await page.unroute('**/api/reports');results.interactions.push('Failed report retains content and offers draft download');
 await page.goto(origin+'/id/research/q001/');await page.locator('[data-mobile-tab=right]').click();assert.equal(await page.locator('#compare-left').isVisible(),false);assert.equal(await page.locator('#compare-right').isVisible(),true);await page.locator('[data-focus]').click();assert.equal(await page.locator('body').evaluate(e=>e.classList.contains('reading-mode')),true);await page.keyboard.press('Escape');results.interactions.push('Mobile archive tabs and reading mode');
 const quiet=await browser.newContext({reducedMotion:'reduce'});const quietPage=await quiet.newPage();await quietPage.goto(origin+'/id/');await quietPage.evaluate(()=>scrollTo(0,300));assert.equal(await quietPage.locator('.hero-calligraphy').evaluate(e=>getComputedStyle(e).transform),'none');await quiet.close();results.interactions.push('Reduced-motion preference disables parallax');
 const nojs=await browser.newContext({javaScriptEnabled:false});const plain=await nojs.newPage();await plain.goto(origin+'/ar/');assert.equal(await plain.locator('.collection-card').count(),21);assert.equal(await plain.locator('.no-script-nav').isVisible(),true);await plain.locator('.home-faq summary').first().click();assert.equal(await plain.locator('.home-faq details').first().evaluate(e=>e.open),true);await nojs.close();results.interactions.push('Core Arabic content and navigation available without JavaScript');
 if(process.env.AXE_SCRIPT){
  for(const locale of ['id','en','ar'])for(const route of ['','access/','report/']){
   await page.emulateMedia({reducedMotion:'reduce'});await page.goto(`${origin}/${locale}/${route}`);await page.evaluate(()=>document.fonts.ready);await page.evaluate(await fs.readFile(process.env.AXE_SCRIPT,'utf8'));
   const report=await page.evaluate(async()=>await axe.run(document,{runOnly:{type:'tag',values:['wcag2a','wcag2aa','wcag21aa']}}));
   results.accessibility.push({locale,route,violations:report.violations.map(v=>({id:v.id,impact:v.impact,nodes:v.nodes.map(n=>({target:n.target,summary:n.failureSummary}))}))});
  }
 }
 assert.deepEqual(results.errors,[]);
 await fs.writeFile(path.join(root,'docs/BROWSER_QA.json'),JSON.stringify(results,null,2)+'\n');
 const violations=results.accessibility.flatMap(r=>r.violations);console.log(JSON.stringify({pages:results.pages.length,interactions:results.interactions.length,browser:results.browser,errors:results.errors,accessibilityViolations:violations},null,2));
 assert.equal(violations.length,0,'Accessibility violations must be reviewed');
}finally{await browser?.close();server.kill();}
