import {tr} from './copy.mjs';
import {nl,link} from './render.mjs';
export function methodStory(l) {
 return `<section class="section verification-section" id="verification"><div class="container"><div class="editorial-heading" data-reveal><h2>${nl(tr(l,'verifyTitle'))}</h2><p>${tr(l,'verifySub')}</p></div><div class="method-story" data-method-story>
 <div class="method-visual" aria-hidden="true"><div class="method-sheet" data-stage="0"><div class="method-meta"><span>${tr(l,'methodSample')}</span><span class="method-counter">01 / 04</span></div><p class="method-question">${tr(l,'methodQuestion')}</p><div class="method-extract"><span lang="ar" dir="rtl">كتاب الأم</span><blockquote lang="ar" dir="rtl">وَلَوْ مَسَّ بِيَدِهِ مَا شَاءَ فَوْقَ بَدَنِهَا مِنْ ثَوْبٍ رَقِيقٍ</blockquote></div><dl class="method-coordinates"><div><dt>${tr(l,'methodBook')}</dt><dd lang="ar">الأم</dd></div><div><dt>${tr(l,'methodVolume')}</dt><dd>1</dd></div><div><dt>${tr(l,'methodPage')}</dt><dd>30</dd></div></dl><p class="method-teacher">${tr(l,'heroFoot')}</p><div class="method-progress"><span></span></div></div></div>
 <ol class="verification-grid">${[1,2,3,4].map(n=>`<li data-method-step="${n-1}" data-reveal><span class="step-number" aria-hidden="true">0${n}</span><h3>${tr(l,'step'+n)}</h3><p>${tr(l,'step'+n+'Body')}</p></li>`).join('')}</ol></div>
 <div class="method-caption"><p>${tr(l,'methodNote')}</p>${link(l,'research/q001',tr(l,'openSource'))}${link(l,'how-it-works',tr(l,'heroSecondary'))}</div>
 </div></section>`;
}
