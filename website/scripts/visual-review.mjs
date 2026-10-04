import path from 'node:path';
import {spawn} from 'node:child_process';
import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
const {chromium}=await import(process.env.PLAYWRIGHT_MODULE||'playwright');
const root=path.resolve(import.meta.dirname,'..'),out=root+'/docs/previews/v6';
await fs.mkdir(out,{recursive:true});
const server=spawn('python3',[root+'/tests/browser_server.py']);
const origin=await new Promise((resolve,reject)=>{server.stdout.once('data',d=>resolve(d.toString().trim()));server.once('exit',c=>reject(Error('Fixture exited '+c)));});
const browser=await chromium.launch({executablePath:process.env.BROWSER_EXECUTABLE||undefined,headless:true,args:['--no-sandbox']});
const checks=[],measurements={};
try{
 const page=await browser.newPage({viewport:{width:1536,height:1024}});
 await page.goto(origin+'/id/');await page.evaluate(()=>document.fonts.ready);await page.waitForTimeout(1500);
 assert.equal(await page.locator('body').evaluate(e=>getComputedStyle(e).backgroundColor),'rgb(255, 255, 255)');
 assert.equal(await page.locator('.brand-mark').first().evaluate(e=>getComputedStyle(e).backgroundColor),'rgb(17, 17, 17)');
 measurements.desktopBook=await page.locator('[data-metric=books] .number-rise').evaluate(e=>parseFloat(getComputedStyle(e).fontSize));assert.ok(measurements.desktopBook>=150);
 checks.push('True-white initial theme, black original logo, desktop corpus number at least 150px');
 await page.screenshot({path:out+'/hero.png'});
 await page.mouse.move(1200,240);await page.waitForTimeout(500);
 const pointer=await page.locator('[data-hero-art]').evaluate(e=>e.style.getPropertyValue('--calligraphy-x'));assert.notEqual(parseFloat(pointer),0);checks.push('Independent hero layers respond to fine pointer movement');
 // Regression for the old eight-second global disconnect. The next section
 // must remain ready to animate after a visitor spends time reading the hero.
 await page.waitForTimeout(9000);
 assert.ok(await page.locator('.collection-scale .reveal-pending').count()>0);
 const go=async selector=>{await page.locator(selector).first().evaluate(e=>scrollTo({top:e.getBoundingClientRect().top+scrollY-100,behavior:'instant'}));};
 await go('.collection-scale');await page.waitForTimeout(1300);
 assert.equal(await page.locator('.collection-scale .editorial-heading').evaluate(e=>e.classList.contains('reveal-pending')),false);
 checks.push('Scroll entrances still run after more than eight seconds on the hero');
 await page.screenshot({path:out+'/scale.png'});
 for(const [n,selector] of [['bento','#assistants'],['cards','.collection-card'],['member','.membership-section'],['adab','.adab-section'],['faq','.home-faq']]){await go(selector);await page.waitForTimeout(1200);await page.screenshot({path:out+'/'+n+'.png'});}
 measurements.cardBook=await page.locator('.metric-primary bdi').first().evaluate(e=>parseFloat(getComputedStyle(e).fontSize));assert.ok(measurements.cardBook>=100);
 measurements.cardSecondary=await page.locator('.collection-metrics li:nth-child(3) bdi').first().evaluate(e=>parseFloat(getComputedStyle(e).fontSize));assert.ok(measurements.cardSecondary>=26);
 checks.push('Featured card numbers retain at least 100px primary and 26px secondary hierarchy');
 await go('.collection-card');await page.locator('.collection-card').first().hover();await page.waitForTimeout(100);assert.notEqual(await page.locator('.collection-card').first().evaluate(e=>e.style.getPropertyValue('--mouse-x')),'');checks.push('Catalogue spotlight responds inside the actual card');
 await page.locator('[data-filter=hadith]').click();assert.equal(await page.locator('[data-search-item]:visible').count(),3);await page.locator('[type=reset]').click();checks.push('Filtering and resetting preserve usable bento layout');
 for(let i=0;i<4;i++){await go(`[data-method-step="${i}"]`);await page.waitForTimeout(800);assert.equal(await page.locator('.method-sheet').getAttribute('data-stage'),String(i));await page.screenshot({path:out+`/method-${i+1}.png`});}
 checks.push('All four manuscript stages update with the corresponding scroll step');
 await go('.home-faq');await page.locator('.home-faq summary').first().click();await page.waitForTimeout(500);assert.equal(await page.locator('.home-faq details').first().evaluate(e=>e.open),true);await page.screenshot({path:out+'/faq-open.png'});checks.push('FAQ opens smoothly while preserving native details state');
 await page.locator('.theme-toggle').click();await page.evaluate(()=>scrollTo({top:0,behavior:'instant'}));await page.waitForTimeout(200);assert.equal(await page.locator('.brand-mark').first().evaluate(e=>getComputedStyle(e).backgroundColor),'rgb(245, 245, 247)');await page.screenshot({path:out+'/hero-dark.png'});checks.push('Dark mode uses white original logo and neutral obsidian canvas');
 await page.locator('[data-motion-control]').click();assert.equal(await page.locator('html').getAttribute('data-motion'),'reduce');assert.equal(await page.locator('.reveal-pending').count(),0);await page.reload();assert.equal(await page.locator('html').getAttribute('data-motion'),'reduce');await page.locator('[data-motion-control]').click();checks.push('Manual reduced-motion preference persists and exposes all content');
 await page.emulateMedia({reducedMotion:'reduce'});assert.equal(await page.locator('.hero-calligraphy').evaluate(e=>getComputedStyle(e).transform),'none');assert.equal(await page.locator('.reveal-pending').count(),0);checks.push('System reduced-motion changes disable parallax immediately');
 const mobile=await browser.newContext({viewport:{width:390,height:844},isMobile:true,hasTouch:true});const touch=await mobile.newPage();await touch.goto(origin+'/id/');await touch.evaluate(()=>document.fonts.ready);await touch.waitForTimeout(1500);
 const before=await touch.locator('[data-hero-art]').evaluate(e=>e.style.getPropertyValue('--calligraphy-x'));await touch.mouse.move(220,200);await touch.waitForTimeout(300);assert.equal(await touch.locator('[data-hero-art]').evaluate(e=>e.style.getPropertyValue('--calligraphy-x')),before);checks.push('Touch devices do not receive mouse parallax');
 measurements.mobileBook=await touch.locator('[data-metric=books] .number-rise').evaluate(e=>parseFloat(getComputedStyle(e).fontSize));assert.ok(measurements.mobileBook>=100);assert.equal(await touch.locator('.theme-toggle').isVisible(),true);measurements.mobileCardTitle=await touch.locator('.collection-card h3').first().evaluate(e=>parseFloat(getComputedStyle(e).fontSize));assert.ok(measurements.mobileCardTitle>=24);
 for(const locale of ['id','ar']){await touch.goto(origin+`/${locale}/`);await touch.evaluate(()=>document.fonts.ready);await touch.waitForTimeout(1500);await touch.screenshot({path:out+`/hero-${locale}-mobile.png`});await touch.locator('.collection-card').first().evaluate(e=>scrollTo({top:e.getBoundingClientRect().top+scrollY-80,behavior:'instant'}));await touch.waitForTimeout(1200);assert.equal(await touch.evaluate(()=>document.documentElement.scrollWidth>innerWidth+1),false);await touch.screenshot({path:out+`/card-${locale}-mobile.png`});}
 checks.push('Mobile ID and AR retain large numbers, accessible theme control and zero overflow');await mobile.close();
 const nojs=await browser.newContext({javaScriptEnabled:false});const plain=await nojs.newPage();await plain.goto(origin+'/id/');assert.equal(await plain.locator('[data-metric=books]').isVisible(),true);assert.equal(await plain.locator('[data-motion-control]').isVisible(),false);assert.equal(await plain.locator('.method-coordinates').evaluate(e=>getComputedStyle(e).opacity),'1');await nojs.close();checks.push('No-JavaScript visitors receive full metrics, manuscript and native navigation');
 await fs.writeFile(root+'/docs/MOTION_QA.json',JSON.stringify({browser:await browser.version(),checks,measurements,errors:[]},null,2)+'\n');console.log(JSON.stringify({motionChecks:checks.length,measurements,errors:[]},null,2));
}finally{await browser.close();server.kill();}
