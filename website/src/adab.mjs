import {readFileSync} from 'node:fs';
import {escapeHtml as e} from './core.mjs';
import {tr,localized} from './copy.mjs';
import {nl,link} from './render.mjs';
const {principles}=JSON.parse(readFileSync(new URL('../content/adab.json',import.meta.url),'utf8'));
export function adabPreview(l) {
 const ids=['sources','honesty','role'];
 return `<section class="section adab-section"><div class="container adab-layout"><span class="adab-calligraphy" lang="ar" dir="rtl" aria-hidden="true">أدب</span><div class="adab-copy" data-reveal><h2>${nl(tr(l,'adabTitle'))}</h2><p>${tr(l,'adabBody')}</p><ol class="adab-principles">${ids.map((id,i)=>`<li data-reveal><span aria-hidden="true">0${i+1}</span><h3>${e(localized(principles.find(p=>p.id===id).heading,l))}</h3></li>`).join('')}</ol>${link(l,'ai-guidelines',tr(l,'aiGuidelines'))}</div></div></section>`;
}
