import {escapeHtml as e,pathFor} from './core.mjs';
import {tr,faq} from './copy.mjs';
import {arrow,icon,link,button,eyebrow,nl,collectionCard,faqBlock} from './render.mjs';
import {collectionStats} from './metadata.mjs';
import {adabPreview} from './adab.mjs';
import {methodStory} from './method.mjs';
import {membership} from './membership.mjs';
import {tahawwulatFeature} from './tahawwulat.mjs';

// Beranda menampilkan sebagian bidang; daftar lengkap ada di halaman Khazanah.
const HOME_FIELDS=6;

function problemStory(l) {
  return `<section class="section problem-section" id="verifiability"><div class="container">
    <div class="editorial-heading" data-reveal>
      <div>${eyebrow(tr(l,'problemEyebrow'))}<h2>${nl(tr(l,'problemTitle'))}</h2></div>
      <p>${tr(l,'problemSub')}</p>
    </div>
    <div class="failure-modes-grid">
      <div class="failure-card" data-reveal>
        <span class="failure-index">01</span>
        <h3>${tr(l,'failureAttribution')}</h3>
        <p>${tr(l,'failureAttributionBody')}</p>
      </div>
      <div class="failure-card" data-reveal>
        <span class="failure-index">02</span>
        <h3>${tr(l,'failureCitation')}</h3>
        <p>${tr(l,'failureCitationBody')}</p>
      </div>
      <div class="failure-card" data-reveal>
        <span class="failure-index">03</span>
        <h3>${tr(l,'failureContext')}</h3>
        <p>${tr(l,'failureContextBody')}</p>
      </div>
      <div class="failure-card failure-card-solution" data-reveal>
        <span class="failure-index">04</span>
        <h3>${tr(l,'failureSolution')}</h3>
        <p>${tr(l,'failureSolutionBody')}</p>
      </div>
    </div>
  </div></section>`;
}

export function immersiveHome(l,data,dialog) {
  return `<section class="scholar-hero" aria-labelledby="hero-title">
    <div class="hero-copy container">
      <p class="eyebrow" lang="en" dir="ltr">AI for Islamic Scholarship</p>
      <h1 id="hero-title">${nl(tr(l,'hero'))}</h1>
      <p class="hero-tagline">${tr(l,'heroTagline')}</p>
      <p class="hero-description">${tr(l,'heroSub')}</p>
      <div class="button-row hero-actions"><a class="button" href="${pathFor(l,'research')}">${tr(l,'heroResearchCta')}${arrow}</a><a class="button button-secondary" href="${pathFor(l,'library')}">${tr(l,'heroCta')}${arrow}</a></div>
    </div>
    <div class="hero-art" data-hero-art>
      <span class="hero-calligraphy" data-text="تراث" lang="ar" dir="rtl" aria-hidden="true">تراث</span>
      <img src="/assets/scholarly-books-v6.webp" alt="${tr(l,'booksAlt')}" width="1536" height="1024" fetchpriority="high" decoding="async">
    </div>
    <p class="hero-foot">${tr(l,'heroFoot')}</p>
  </section>
  ${tahawwulatFeature(l,data)}
  ${problemStory(l)}
  ${collectionStats(l,data.catalog)}
  ${methodStory(l)}
  <section class="section catalogue-section" id="assistants"><div class="container" data-search-scope>
    <div class="editorial-heading"><div>${eyebrow(tr(l,'catalogEyebrow'))}<h2>${nl(tr(l,'fieldTitle'))}</h2></div><p>${tr(l,'fieldSub')}</p></div>
    <div class="collection-grid full-grid">${data.catalog.filter(c=>c.id!=='fiqh-tahawwulat').slice(0,HOME_FIELDS).map(c=>`<div class="bento-${c.variant||'standard'}" data-reveal="card" data-search-item data-search-text="${e(Object.values(c.name).join(' ')+' '+c.arabic+' '+Object.values(c.description).join(' '))}" data-group="${c.group}">${collectionCard(l,c)}</div>`).join('')}</div>
    <p class="catalog-more">${link(l,'library',tr(l,'allLibrary'))}</p>
    <p class="fine-print catalog-note">${tr(l,'catalogNote')}</p>
  </div></section>
  <section class="section archive-section"><div class="container archive-layout">
    <div>${eyebrow(tr(l,'archiveEyebrow'))}<h2>${nl(tr(l,'archiveTitle'))}</h2><p>${tr(l,'archiveBody')}</p>${link(l,'research/q001',tr(l,'readFull'))}</div>
    <article class="manuscript-card"><div class="manuscript-meta"><span>Q001 · 03 / 10</span><span>${tr(l,'archiveSample')}</span></div>
      <p class="status-label">${tr(l,'sourcePending')}</p><blockquote lang="ar" dir="rtl">وَلَوْ مَسَّ بِيَدِهِ مَا شَاءَ فَوْقَ بَدَنِهَا مِنْ ثَوْبٍ رَقِيقٍ</blockquote>
      <div class="manuscript-footer"><span lang="ar" dir="rtl">الأم · ج١، ص٣٠</span><button class="text-link" data-dialog="source-dialog">${tr(l,'openSource')}${arrow}</button></div>
    </article>
  </div></section>
  <section class="section membership-section"><div class="container">${membership(l,data.config,{compact:true})}</div></section>
  ${adabPreview(l)}
  <section class="section home-faq"><div class="container faq-layout"><div class="faq-heading" data-reveal><h2>${nl(tr(l,'faqTitle'))}</h2><p class="faq-intro">${tr(l,'faqIntro')}</p></div>${faqBlock(l,faq)}</div></section>${dialog}`;
}
