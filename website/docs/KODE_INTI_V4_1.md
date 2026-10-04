# Kode Inti OpenTurath Website V4.1

Semua berkas di bawah ditampilkan utuh. ZIP menyertakan seluruh dependensi lokal, aset, data, server, tes, dan hasil build. Gunakan ZIP sebagai proyek yang dapat dijalankan.

```sh
npm run build:release
npm test
npm start
```

APK asli belum disertakan; lihat README untuk pendaftaran artefak dan status integrasi backend.

## src/home.mjs

```javascript
import {escapeHtml as e,pathFor} from './core.mjs';
import {tr,faq} from './copy.mjs';
import {arrow,icon,link,button,eyebrow,nl,collectionCard,faqBlock} from './render.mjs';
import {collectionStats} from './metadata.mjs';
import {membership} from './membership.mjs';

export function immersiveHome(l,data,dialog) {
  const groups=['all','fiqh','hadith','quran','language','history','spirituality','theology','special'];
  return `<section class="scholar-hero" aria-labelledby="hero-title">
    <div class="hero-copy container">
      <p class="eyebrow" lang="en" dir="ltr">AI for Islamic Scholarship</p>
      <h1 id="hero-title">${tr(l,'hero')}</h1>
      <h2 class="hero-tagline">${tr(l,'heroTagline')}</h2>
      <p class="hero-description">${tr(l,'heroSub')}</p>
      <div class="button-row hero-actions"><a class="button" href="${pathFor(l,'library')}">${tr(l,'heroCta')}${arrow}</a><a class="button button-secondary" href="${pathFor(l,'how-it-works')}">${tr(l,'heroSecondary')}${arrow}</a></div>
    </div>
    <div class="hero-art" data-hero-art>
      <span class="hero-calligraphy" data-text="تراث" lang="ar" dir="rtl" aria-hidden="true">تراث</span>
      <img src="/assets/scholarly-books.webp" alt="${tr(l,'booksAlt')}" width="1200" height="800" fetchpriority="high" decoding="async">
    </div>
    <p class="hero-foot">${tr(l,'heroFoot')}</p>
  </section>
  ${collectionStats(l,data.catalog)}
  <section class="section verification-section" id="verification"><div class="container">
    <div class="editorial-heading"><div>${eyebrow(tr(l,'verifyEyebrow'))}<h2>${nl(tr(l,'verifyTitle'))}</h2></div><p>${tr(l,'verifySub')}</p></div>
    <ol class="verification-grid">${[1,2,3,4].map((n)=>`<li><span class="step-number" aria-hidden="true">0${n}</span><h3>${tr(l,'step'+n)}</h3><p>${tr(l,'step'+n+'Body')}</p></li>`).join('')}</ol>
    ${link(l,'how-it-works',tr(l,'heroSecondary'))}
  </div></section>
  <section class="section catalogue-section" id="assistants"><div class="container" data-search-scope>
    <div class="editorial-heading"><div>${eyebrow(tr(l,'catalogEyebrow'))}<h2>${nl(tr(l,'fieldTitle'))}</h2></div><p>${tr(l,'fieldSub')}</p></div>
    <form class="search-form" data-search-form role="search"><label class="search-box">${icon('search')}<span class="sr-only">${tr(l,'search')}</span><input type="search" name="q" data-search placeholder="${tr(l,'search')}" autocomplete="off"></label>
      <div class="filter-list" role="group" aria-label="${tr(l,'collections')}">${groups.map((g,i)=>`<button type="button" data-filter="${g}" aria-pressed="${i===0}">${tr(l,g==='language'?'languageGroup':g==='special'?'specialGroup':g)}</button>`).join('')}</div>
      <div class="search-meta"><output class="result-count" data-count aria-live="polite">${data.catalog.length} ${tr(l,'results')}</output><button class="quiet-button" type="reset">${tr(l,'clear')}</button></div>
    </form>
    <div class="collection-grid full-grid">${data.catalog.map(c=>`<div class="bento-${c.variant||'standard'}" data-search-item data-search-text="${e(Object.values(c.name).join(' ')+' '+c.arabic+' '+Object.values(c.description).join(' '))}" data-group="${c.group}">${collectionCard(l,c)}</div>`).join('')}</div>
    <p class="empty-search" data-empty hidden>${tr(l,'noResults')}</p>
    <p class="fine-print catalog-note">${tr(l,'catalogNote')}</p>
  </div></section>
  <section class="section archive-section"><div class="container archive-layout">
    <div>${eyebrow(tr(l,'archiveEyebrow'))}<h2>${nl(tr(l,'archiveTitle'))}</h2><p>${tr(l,'archiveBody')}</p>${link(l,'research/q001',tr(l,'readFull'))}</div>
    <article class="manuscript-card"><div class="manuscript-meta"><span>Q001 · 03 / 10</span><span>${tr(l,'archiveSample')}</span></div>
      <blockquote lang="ar" dir="rtl">وَلَوْ مَسَّ بِيَدِهِ مَا شَاءَ فَوْقَ بَدَنِهَا مِنْ ثَوْبٍ رَقِيقٍ</blockquote>
      <div class="manuscript-footer"><span lang="ar" dir="rtl">الأم · ج١، ص٣٠</span><button class="text-link" data-dialog="source-dialog">${tr(l,'openSource')}${arrow}</button></div>
    </article>
  </div></section>
  <section class="section membership-section"><div class="container">${membership(l,data.config,{compact:true})}</div></section>
  <section class="section adab-section"><div class="container adab-layout"><span class="adab-calligraphy" lang="ar" dir="rtl" aria-hidden="true">أدب</span><div>${eyebrow('OpenTurath')}<h2>${nl(tr(l,'adabTitle'))}</h2><p>${tr(l,'adabBody')}</p>${link(l,'ai-guidelines',tr(l,'aiGuidelines'))}</div></div></section>
  <section class="section home-faq"><div class="container">${eyebrow(tr(l,'help'))}<h2>${tr(l,'faq')}</h2><p class="faq-intro">${tr(l,'faqIntro')}</p>${faqBlock(l,faq)}</div></section>${dialog}`;
}
```

## public/assets/immersive.css

```css
/* OpenTurath — warm obsidian, scholarly type, restrained antique gold. */
:root,:root[data-theme=dark]{--paper:#0a0908;--surface:#12110f;--ink:#f5f5f7;--muted:#aaa69e;--line:#343029;--hover:#1e1b16;--dark:#0a0908;--dark-ink:#f5f5f7;--gold:#c5a059;--glass:rgba(255,255,255,.025);--gold-line:rgba(197,160,89,.2);--body:Outfit,'Scheherazade New',sans-serif;--display:Newsreader,'Scheherazade New',Georgia,serif;--radius:16px;color-scheme:dark}
:root[data-theme=light]{--paper:#f6f3ed;--surface:#fffdf7;--ink:#201c16;--muted:#635b4f;--line:#d7cebd;--hover:#eee8dc;--dark:#12110f;--gold:#80612b;--glass:rgba(255,255,255,.5);--gold-line:rgba(128,97,43,.26);color-scheme:light}
html{scroll-padding-top:100px}body{font-size:16px;line-height:1.7;background:var(--paper)}
h1,h2{font-weight:400;letter-spacing:-.035em}h3{font-weight:500}p{color:var(--muted)}
button,input,select,textarea{font-family:var(--body)}
a,button{outline-offset:5px}a:focus-visible,button:focus-visible,summary:focus-visible,input:focus-visible,select:focus-visible,textarea:focus-visible{outline:2px solid var(--gold)}
::selection{background:#c5a059;color:#0a0908}
.container{width:min(1200px,calc(100% - 96px))}.section{padding-block:100px}.compact-top{padding-top:0}
.eyebrow{font:500 11px/1.5 var(--body);letter-spacing:.18em;text-transform:uppercase;color:var(--gold);margin-bottom:22px}
.fine-print,.field-hint,.small-label,.serial,.result-count{color:var(--muted)}.fine-print{font-size:12px;line-height:1.8}
.text-link{color:var(--ink);gap:12px;font-size:14px}.text-link svg{width:19px}
.button{position:relative;overflow:hidden;min-height:48px;padding:13px 24px;gap:14px;border:1px solid transparent;border-radius:999px;background:var(--ink);color:var(--paper);font-size:14px;font-weight:500;line-height:1.4;text-align:center;white-space:normal;transition:transform .28s cubic-bezier(.16,1,.3,1)}
.button::after{content:'';position:absolute;inset:0;pointer-events:none;background:linear-gradient(110deg,transparent 20%,#fff2 48%,transparent 72%);transform:translateX(-120%);transition:transform .7s}
.button:hover{background:var(--ink);border-color:transparent;transform:translateY(-2px);box-shadow:0 8px 24px #c5a05912}.button:hover::after{transform:translateX(120%)}
.button-secondary{background:var(--glass);border-color:var(--gold-line);color:var(--ink);backdrop-filter:blur(20px)}
.button-secondary:hover{background:var(--glass);border-color:var(--gold);color:var(--ink)}
.button:active,.collection-card:active{transform:scale(.985)}.button-row{gap:16px}.quiet-button{min-height:44px;color:var(--muted)}
.icon-button{min-width:40px;min-height:44px;color:var(--ink)}
.site-header{height:76px;position:sticky;top:0;z-index:40;border-bottom:1px solid var(--gold-line);background:color-mix(in srgb,var(--paper) 90%,transparent);backdrop-filter:blur(20px)}
.nav-inner{width:min(1280px,calc(100% - 80px));height:100%;padding-inline:0;gap:24px}
.wordmark{display:inline-flex;align-items:center;gap:10px;font:400 29px/1 var(--display);letter-spacing:-.03em}.wordmark span{color:inherit}
.brand-mark{width:37px;height:32px;background:var(--gold);mask:url('/assets/openturath-mark.svg') center/contain no-repeat;-webkit-mask:url('/assets/openturath-mark.svg') center/contain no-repeat}
.desktop-nav{gap:32px}.desktop-nav a{font-size:13px;white-space:nowrap;color:var(--muted)}.desktop-nav a:hover,.desktop-nav a[aria-current]{color:var(--ink)}
.nav-tools{gap:12px}.nav-tools>.nav-download{min-height:42px;padding:10px 20px;font-size:13px;border-color:var(--line)}.nav-download svg{width:19px}
.locale-trigger{font-size:12px;min-height:44px;min-width:42px}.theme-toggle svg{width:17px}.mobile-menu{display:none}.no-script-nav{display:flex;gap:18px;flex-wrap:wrap;padding-block:16px}

/* Real artwork and live Arabic type form separate depth layers. */
.scholar-hero{position:relative;isolation:isolate;min-height:860px;overflow:hidden;text-align:center;background:radial-gradient(ellipse at 50% 60%,#c5a0590d,transparent 65%),#0a0908;color:#f5f5f7;border-bottom:1px solid #c5a05926}
.hero-copy{position:relative;z-index:2;padding-top:50px;pointer-events:none}.hero-copy a{pointer-events:auto}
.hero-copy .eyebrow{display:flex;align-items:center;justify-content:center;gap:13px;color:#c5a059;margin-bottom:19px;font:400 13px/1.5 Outfit,sans-serif;letter-spacing:.18em;text-transform:none}
.hero-copy .eyebrow::before,.hero-copy .eyebrow::after{content:'';width:29px;height:1px;background:#c5a059;opacity:.7}
.hero-copy h1{font-size:clamp(76px,6.5vw,90px);line-height:1.08;margin:0 auto 8px;letter-spacing:-.042em;color:#fff}
.hero-copy .hero-tagline{font:400 28px/1.45 var(--display);color:#e5e2dc;letter-spacing:-.015em;margin:0 auto 14px}
.hero-description{max-width:590px;font:400 16px/1.8 Outfit,sans-serif;color:#aaa69e;margin:0 auto 24px;text-wrap:pretty}
.hero-actions{justify-content:center}.hero-actions .button{background:#f5f5f7;color:#171511;min-height:50px;padding-inline:25px}
.hero-actions .button-secondary{background:#ffffff03;color:#f5f5f7;border-color:#c5a05944}
.hero-art{position:absolute;left:50%;bottom:33px;width:min(1120px,100%);height:440px;transform:translateX(-50%);pointer-events:none;isolation:isolate}
.hero-art img{position:absolute;top:0;left:50%;width:auto;max-width:none;height:100%;object-fit:contain;translate:-50% 0;transform:translate3d(var(--book-x,0px),var(--book-y,0px),0);mask-image:radial-gradient(ellipse 50% 64% at 50% 51%,#000 40%,#000e 62%,transparent 100%);-webkit-mask-image:radial-gradient(ellipse 50% 64% at 50% 51%,#000 40%,#000e 62%,transparent 100%)}
.hero-calligraphy{position:absolute;inset-inline:0;top:-150px;font:400 360px/1.45 'Scheherazade New',serif;background:linear-gradient(135deg,#fff1c5 0%,#d4af37 35%,#aa7c11 70%,#5e4304 100%);color:transparent;background-clip:text;-webkit-background-clip:text;transform:translate3d(var(--calligraphy-x,0px),var(--calligraphy-y,0px),0) scaleX(1.8);z-index:-1;opacity:.57;animation:foil-breathe 8s ease-in-out infinite}
.hero-calligraphy::after{content:attr(data-text);position:absolute;inset:0;background-image:repeating-conic-gradient(from 40deg,#fff6 0% 18%,#0004 23% 40%,transparent 48% 100%),repeating-conic-gradient(from 115deg,transparent 0% 30%,#ffedb555 40% 55%,transparent 65% 100%);background-size:3px 5px,7px 9px;background-clip:text;-webkit-background-clip:text;color:transparent;opacity:.2}
.hero-foot{display:block;position:absolute;inset-inline:20px;bottom:19px;margin:0;padding:0;border:0;color:#aaa69e;font-size:11px;letter-spacing:.035em}.hero-foot::after{content:'';display:block;width:40px;height:1px;background:#c5a05980;margin:14px auto 0}
@keyframes foil-breathe{0%,100%{opacity:.47}50%{opacity:.65}}

/* The six totals are computed from the same metadata as the collection cards. */
.collection-scale{padding:55px 0 40px;background:radial-gradient(ellipse at 50% 0,#c5a05908,transparent 70%);border-bottom:1px solid var(--gold-line);text-align:center}
.collection-scale .eyebrow{margin-bottom:15px}.collection-scale h2{margin:0}.collection-scale .eyebrow{margin-bottom:30px}
.scale-grid{display:grid;grid-template-columns:repeat(6,minmax(0,1fr));gap:0;margin:0}
.scale-grid>div{display:flex;flex-direction:column;padding:0 14px;min-width:0}.scale-grid>div+div{border-inline-start:1px solid var(--gold-line)}
.scale-grid dt{order:2;font-size:12px;color:var(--muted);margin-top:10px}.scale-grid dd{margin:0;display:flex;flex-direction:column;color:var(--gold);font:400 clamp(24px,2.5vw,34px)/1.2 var(--display);letter-spacing:-.015em;min-height:58px}
.scale-unit{font:400 16px/1.2 var(--body);letter-spacing:0}.scale-grid small{font:400 10px/1.5 var(--body);color:var(--muted);margin-top:7px;letter-spacing:.02em}
.scale-source{font-size:11px;margin:30px 0 0}
.editorial-heading{display:grid;grid-template-columns:1.25fr 1fr;align-items:end;gap:90px;margin-bottom:45px}.editorial-heading h2{font-size:54px;line-height:1.1;margin:0}.editorial-heading>p{font-size:15px;line-height:1.85;max-width:430px;margin:0}
.verification-grid{display:grid;grid-template-columns:repeat(4,1fr);list-style:none;margin:0 0 20px;padding:0;border-top:1px solid var(--gold-line)}
.verification-grid li{padding:30px 24px 20px 0}.verification-grid li+li{padding-inline-start:24px;border-inline-start:1px solid var(--gold-line)}
.step-number{font:400 40px/1 var(--display);color:var(--gold);display:block;margin-bottom:24px}.verification-grid h3{font-size:16px;line-height:1.5;margin-bottom:12px}.verification-grid p{font-size:13px;line-height:1.85;margin-bottom:0}
.catalogue-section{background:radial-gradient(ellipse at 80% 10%,#c5a05905,transparent 55%);border-block:1px solid var(--gold-line)}
.search-form{margin-bottom:28px}.search-box{max-width:470px;min-height:50px;background:var(--glass);border:1px solid var(--line);border-radius:999px;padding:0 20px;margin-bottom:20px}
.search-box input{min-width:0;height:48px;font-size:14px;color:var(--ink)}.search-box input::placeholder{color:var(--muted);opacity:1}.search-box svg{width:18px;color:var(--muted)}
.filter-list{display:flex;gap:6px;flex-wrap:wrap;margin:0 0 10px}.filter-list button{border:1px solid transparent;background:transparent;color:var(--muted);font-size:12px;min-height:40px;padding:8px 13px;border-radius:999px}
.filter-list button:hover{background:var(--hover)}.filter-list button[aria-pressed=true]{background:var(--glass);border-color:var(--gold-line);color:var(--gold)}
.search-meta{display:flex;justify-content:space-between;align-items:center;gap:20px}.result-count,.search-meta .quiet-button{font-size:12px}
.collection-grid.full-grid{grid-template-columns:repeat(6,minmax(0,1fr));gap:18px;align-items:stretch}
.collection-grid>div{min-width:0;grid-column:span 2}.collection-grid>.bento-featured{grid-column:span 3}.collection-grid>.bento-sovereign,.collection-grid>div:last-child:nth-child(3n){grid-column:span 4}
.collection-card{position:relative;isolation:isolate;overflow:hidden;display:flex;flex-direction:column;justify-content:flex-start;height:100%;min-height:350px;padding:26px 24px;background:var(--glass);border:1px solid var(--gold-line);border-radius:16px;backdrop-filter:blur(20px);box-shadow:0 2px 4px #0001,0 16px 40px #0002;transition:transform .35s cubic-bezier(.16,1,.3,1)}
.collection-card::before{content:'';position:absolute;left:0;top:0;width:800px;height:800px;z-index:-1;pointer-events:none;background:radial-gradient(circle,rgba(197,160,89,.1),transparent 80%);transform:translate3d(calc(var(--mouse-x,0px) - 400px),calc(var(--mouse-y,0px) - 400px),0);opacity:0;transition:opacity .35s}.collection-card:hover::before{will-change:transform,opacity}
.collection-card:hover{background:var(--glass);border-color:#c5a05965;transform:translateY(-3px)}.collection-card:hover::before{opacity:1}.collection-card:active{transform:scale(.985)}
.bento-featured .collection-card{padding:28px 30px}.bento-sovereign .collection-card{border-color:#c5a05980;background:linear-gradient(130deg,#c5a05909,transparent),var(--glass)}
.bento-sovereign .collection-card::after{content:'';position:absolute;inset:6px;border:1px solid var(--gold-line);border-radius:11px;pointer-events:none}
.collection-top{display:flex;align-items:center;gap:10px;margin-bottom:17px}.collection-top .serial{font-size:11px}.collection-top svg{width:17px;margin-inline-start:auto;color:var(--gold)}
.availability{font-size:10px;color:var(--muted);line-height:1.5}.availability.is-preparing{color:var(--gold)}
.collection-ar{font:400 32px/1.7 'Scheherazade New',serif;color:var(--gold);margin:0 0 17px;text-align:start}.bento-featured .collection-ar,.bento-sovereign .collection-ar{font-size:38px}
.collection-copy{margin-bottom:24px}.collection-card h3{font:500 18px/1.4 var(--body);margin:0 0 10px;letter-spacing:-.015em}.bento-featured h3,.bento-sovereign h3{font-size:22px}
.collection-card .collection-copy>p{font:400 13px/1.8 var(--body);margin:0;color:var(--muted)}
.collection-metrics{display:flex;gap:7px;flex-wrap:wrap;list-style:none;margin:0;padding:0;margin-top:auto}
.collection-metrics li{font:400 11px/1.6 var(--body);padding:5px 9px;background:var(--glass);border:1px solid var(--gold-line);border-radius:999px;color:var(--muted)}.collection-metrics bdi{color:var(--gold);font-weight:500}.collection-metrics .metric-period{color:var(--muted)}
.reading-content>.collection-metrics{margin-bottom:30px}.catalog-note{margin:27px 0 0}
.archive-section{background:var(--surface);border-bottom:1px solid var(--gold-line)}.archive-layout{display:grid;grid-template-columns:1fr 1.1fr;gap:80px;align-items:center}.archive-layout h2{font-size:52px}.archive-layout>div>p:not(.eyebrow){font-size:15px;line-height:1.85}
.manuscript-card{border:1px solid #c5a05950;padding:32px 36px;border-radius:12px;background:linear-gradient(135deg,#c5a0590a,transparent);box-shadow:0 20px 60px #0002}.manuscript-meta{display:flex;align-items:center;justify-content:space-between;gap:12px;font-size:10px;color:var(--muted)}
.manuscript-card blockquote{font:400 32px/2.05 'Scheherazade New',serif;text-align:center;color:var(--ink);padding:35px 0}.manuscript-footer{display:flex;align-items:center;justify-content:space-between;gap:16px;border-top:1px solid var(--gold-line);padding-top:20px}.manuscript-footer>span{font:400 20px/1.7 'Scheherazade New',serif;color:var(--gold)}.manuscript-footer button{font-size:12px}
.membership-banner{position:relative;display:grid;grid-template-columns:1fr auto;align-items:center;gap:65px;padding:55px 48px;border:1px solid #c5a05965;border-radius:18px;background:radial-gradient(ellipse at 0% 100%,#c5a0590d,transparent 70%),var(--glass);box-shadow:0 20px 60px #0002}
.membership-banner::before{content:'';position:absolute;inset:7px;border:1px solid var(--gold-line);border-radius:13px;pointer-events:none}.membership-banner .eyebrow{margin-bottom:20px}.membership-banner h2{font-size:43px;line-height:1.15;margin-bottom:18px}.membership-price{font:400 36px/1.3 var(--display);color:var(--gold);margin-bottom:22px}.membership-price>span{font:400 15px/1.6 var(--body);color:var(--muted)}.membership-description{max-width:600px;font-size:14px;line-height:1.8;margin-bottom:22px}
.membership-payments{display:flex;flex-wrap:wrap;gap:6px 15px;margin:0;font-size:11px;color:var(--muted)}.membership-payments bdi{font-weight:600;color:var(--ink)}.membership-payments span{padding-inline-start:15px;border-inline-start:1px solid var(--gold-line)}
.membership-action{text-align:center;max-width:300px}.membership-action .button{font-size:13px}.membership-action>p{font-size:11px;margin:14px 0 5px}.membership-action .text-link{color:var(--muted);font-size:11px;min-height:40px}.membership-detail{margin-top:24px}
.refund-panel{margin-top:36px;padding:28px;border:1px solid var(--gold-line);border-radius:12px;max-width:850px}.refund-panel .eyebrow{margin-bottom:14px}.refund-panel>p:not(.eyebrow){font-size:14px}
.adab-section{border-block:1px solid var(--gold-line);background:var(--surface)}.adab-layout{display:grid;grid-template-columns:1fr 1.2fr;gap:70px;align-items:center}.adab-calligraphy{font:400 220px/1.4 'Scheherazade New',serif;text-align:center;color:var(--gold);opacity:.65}.adab-layout h2{font-size:52px}.adab-layout p:not(.eyebrow){max-width:500px;font-size:15px;line-height:1.85}
.home-faq .container{max-width:930px}.home-faq h2{font-size:48px;margin-bottom:16px}.faq-intro{font-size:15px;margin-bottom:36px}
.faq-list details{overflow-anchor:none;position:relative;border-color:var(--gold-line)}.faq-list summary{display:flex;align-items:center;justify-content:space-between;gap:22px;padding:24px 20px;font-size:16px;line-height:1.6;cursor:pointer;list-style:none}.faq-list summary::-webkit-details-marker{display:none}.faq-list summary svg{width:18px;color:var(--gold);transition:transform .45s cubic-bezier(.16,1,.3,1)}.faq-list details[open] summary svg{transform:rotate(45deg)}
.faq-list details::before{content:'';position:absolute;inset-block:20px;inset-inline-start:0;width:2px;background:var(--gold);opacity:0;transition:opacity .3s}.faq-list details[open]::before{opacity:1}
.faq-list .faq-answer{padding:0 60px 25px 20px}.faq-answer p{margin:0;font-size:14px;line-height:1.85}.faq-list details[open]{background:var(--glass)}
/* JS uses transform/opacity only; without JS everything starts visible. */
[data-reveal]{opacity:1}.motion-ready [data-reveal].reveal-pending{opacity:0;transform:translateY(24px)}
.motion-ready [data-reveal]{transition:opacity .7s cubic-bezier(.16,1,.3,1),transform .7s cubic-bezier(.16,1,.3,1)}
/* Inner pages retain the same reading and interaction system. */
.breadcrumb{font-size:12px;color:var(--muted);padding-block:22px}.page-head{padding-block:58px 64px;background:transparent;color:var(--ink)}.page-head h1{font-size:clamp(44px,5.3vw,76px);max-width:960px;line-height:1.13}.page-head .lede{font-size:17px;max-width:760px;color:var(--muted)}.page-head.dark{background:var(--surface)}.article-layout{gap:80px;padding-bottom:100px}.article-toc a{font-size:13px}.article-toc{top:110px}.reading-content{font-size:16px;line-height:1.9}.reading-content h2{font-family:var(--body);font-size:24px;letter-spacing:-.02em;line-height:1.45;margin-bottom:16px}.reading-content section{scroll-margin-top:115px}.policy-meta{padding:26px;border:1px solid var(--line);border-radius:8px;margin-bottom:42px;background:var(--surface)}.policy-meta .eyebrow{font-size:10px;letter-spacing:.1em}.policy-meta p{font-size:14px}.policy-meta a{font-size:13px}.side-note{background:var(--surface);border-color:var(--line)}.side-note h2{font-size:34px;line-height:1.2}.side-note .button{margin-block:12px}.notice{background:var(--surface);border:1px solid var(--line);border-inline-start:2px solid var(--gold);color:var(--muted);border-radius:4px}.book-row,.guide-card,.bibliography-sheet,.question-box,.answer-column,.download-card,.access-card,.research-case{background:var(--surface);border-color:var(--line)}.book-row h3{font-family:'Scheherazade New',serif;line-height:1.85}.download-card h2{font-size:36px}.download-card[data-coming-soon]{opacity:1}.coming-soon-badge{display:inline-block;color:var(--gold);border:1px solid var(--line);padding:5px 10px;border-radius:4px;font-size:12px}.download-card .button{width:100%;margin-block:16px}.download-card details{margin-top:20px}.download-cta{background:var(--surface);color:var(--ink)}.download-cta p{color:var(--muted)}.metadata dd{overflow-wrap:anywhere}.report-form input,.report-form select,.report-form textarea,.answer-picker select{background:var(--surface);border:1px solid var(--line);border-radius:6px;color:var(--ink)}.report-form input[type=checkbox]{accent-color:var(--gold)}.report-form>label{font-size:14px}.report-form .field-hint{font-size:12px}.report-form .form-status{color:var(--ink)}.status-label{color:var(--gold);background:transparent}.contact-email{font-size:17px;overflow-wrap:anywhere}.source-dialog{background:var(--surface)}dialog{background:var(--surface);color:var(--ink);border:1px solid var(--line);box-shadow:0 24px 100px #0007}dialog::backdrop{background:#000a;backdrop-filter:blur(7px)}dialog h2{font-size:30px;line-height:1.3}.language-list a:hover{background:var(--hover)}.language-list a{border-color:var(--line)}.source-dialog blockquote,.arabic-display{font-family:'Scheherazade New',serif;line-height:1.9}.comparison-workspace{gap:20px}.answer-text{color:var(--ink)}.answer-text p{color:inherit}.answer-text [lang=ar],blockquote[lang=ar]{font-family:'Scheherazade New',serif;line-height:1.95}.answer-provenance,.answer-end,.reader-toolbar,.evidence-index{border-color:var(--line)}.quote-highlight{background:#c9a84c26;outline-color:var(--gold)}.evidence-list summary{gap:14px}.evidence-list blockquote{font-size:27px;line-height:1.95}.toast{background:var(--ink);color:var(--paper)}.site-footer{background:var(--paper);border-top:1px solid var(--line);padding-block:60px 24px}.footer-top{align-items:center;gap:24px}.footer-top p{font-size:12px}.footer-grid{margin-top:42px}.footer-heading{font-size:12px;color:var(--ink)}.footer-grid a{color:var(--muted);font-size:12px;line-height:1.7}.footer-grid a:hover{color:var(--ink)}.footer-bottom{font-size:10px;color:var(--muted);gap:22px}.footer-bottom p{margin:0;font-size:10px}.choose-language{background:var(--paper)}.choose-language h1{font-size:80px}.empty-state h2{font-size:34px}.hash{overflow-wrap:anywhere;word-break:break-all}.reveal,.reveal.pending{opacity:1;transform:none}
/* Localised flow, touch layouts, and motion preferences. */
html[lang=ar] body{font-family:'Scheherazade New',serif;font-size:20px;line-height:1.9}html[lang=ar] h1,html[lang=ar] h2,html[lang=ar] h3{font-family:'Scheherazade New',serif;letter-spacing:0;line-height:1.5}
html[lang=ar] .wordmark{font-family:Newsreader,serif}html[lang=ar] .eyebrow{letter-spacing:0;font-size:16px}html[lang=ar] .hero-copy .eyebrow{font:400 13px/1.5 Outfit,sans-serif;letter-spacing:.18em}
html[lang=ar] .hero-copy h1{font-size:80px;line-height:1.35;margin-bottom:0}html[lang=ar] .hero-copy .hero-tagline{font:400 30px/1.6 'Scheherazade New',serif}html[lang=ar] .hero-description{font:400 21px/1.8 'Scheherazade New',serif}
html[lang=ar] .button{font:400 18px/1.5 'Scheherazade New',serif}html[lang=ar] .desktop-nav a{font-size:19px}html[lang=ar] .nav-tools>.nav-download{font-size:18px}
html[lang=ar] .editorial-heading>p,html[lang=ar] .archive-layout>div>p,html[lang=ar] .adab-layout p{font-size:21px;line-height:1.9}
html[lang=ar] .verification-grid h3{font-size:22px}html[lang=ar] .verification-grid p{font-size:19px}html[lang=ar] .filter-list button,html[lang=ar] .text-link{font-size:18px}
html[lang=ar] .collection-card h3{font:400 25px/1.5 'Scheherazade New',serif}html[lang=ar] .collection-card .collection-copy>p{font:400 19px/1.9 'Scheherazade New',serif}html[lang=ar] .availability{font-size:15px}html[lang=ar] .collection-metrics li{font:400 16px/1.6 'Scheherazade New',serif}
html[lang=ar] .scale-grid dt{font-size:18px}html[lang=ar] .scale-grid dd{font-family:'Scheherazade New',serif;font-size:34px}html[lang=ar] .scale-grid small{font-size:13px}html[lang=ar] .fine-print{font-size:17px}
html[lang=ar] .membership-description{font-size:20px}html[lang=ar] .membership-price>span{font:400 21px/1.6 'Scheherazade New',serif}html[lang=ar] .membership-action>p{font-size:17px}html[lang=ar] .membership-action .text-link{font-size:17px}
html[lang=ar] .faq-list summary{font-size:23px}html[lang=ar] .faq-answer p{font-size:21px}html[lang=ar] .reading-content{font-size:22px;line-height:2}html[lang=ar] .reading-content h2{font-size:29px}html[lang=ar] .article-toc a{font-size:18px}html[lang=ar] .footer-grid a{font-size:17px}html[lang=ar] .policy-meta p{font-size:19px}
@media(max-width:1100px){.desktop-nav{gap:20px}.nav-inner{width:calc(100% - 48px);gap:18px}.nav-tools{gap:5px}.editorial-heading{gap:45px}.archive-layout{gap:45px}.membership-banner{gap:35px;padding:45px 35px}.collection-card{padding:24px 20px}.scale-grid>div{padding-inline:10px}.scale-grid dd{font-size:27px}}
@media(max-width:900px){.desktop-nav{display:none}.mobile-menu{display:inline-flex}.nav-tools{margin-inline-start:auto;gap:8px}.container{width:calc(100% - 48px)}.section{padding-block:80px}.compact-top{padding-top:0}.scholar-hero{min-height:850px}.hero-copy{padding-top:55px}.hero-copy h1{font-size:76px}.hero-art{height:460px;bottom:30px;width:980px;max-width:none}.hero-calligraphy{font-size:350px;top:-42px;transform:translate3d(var(--calligraphy-x,0px),var(--calligraphy-y,0px),0) scaleX(1.65)}
.scale-grid{grid-template-columns:repeat(3,minmax(0,1fr));row-gap:30px}.scale-grid>div:nth-child(4){border-inline-start:0}.scale-grid dd{font-size:34px}.editorial-heading h2{font-size:43px}.verification-grid{grid-template-columns:repeat(2,1fr)}.verification-grid li:nth-child(3){border-inline-start:none;padding-inline-start:0}
.collection-grid.full-grid{grid-template-columns:repeat(2,minmax(0,1fr))}.collection-grid>div{grid-column:span 1}.collection-grid>.bento-featured,.collection-grid>.bento-sovereign,.collection-grid>div:last-child:nth-child(3n){grid-column:span 2}.archive-layout{gap:30px}.archive-layout h2{font-size:43px}.manuscript-card{padding:25px}.manuscript-meta{flex-wrap:wrap}.membership-banner{grid-template-columns:1fr;gap:26px}.membership-action{text-align:start;max-width:none}.membership-action .text-link{margin-inline-start:0}.membership-action>p{margin-top:18px}.adab-layout{gap:35px}.adab-layout h2{font-size:43px}.adab-calligraphy{font-size:170px}.article-layout{gap:35px}}
@media(max-width:640px){.container{width:calc(100% - 40px)}.nav-inner{width:calc(100% - 28px);gap:5px}.site-header{height:66px}.wordmark{font-size:23px;gap:7px}.brand-mark{width:26px;height:28px}.nav-tools{gap:0}.nav-tools .theme-toggle{display:none}.icon-button{width:36px;min-width:36px}.locale-trigger{min-width:36px;font-size:11px}
.nav-tools>.nav-download,html[lang=ar] .nav-tools>.nav-download{display:inline-flex;min-height:40px;min-width:40px;padding:8px;margin-inline:4px}.nav-download span{display:none}.nav-download svg{width:19px}
.scholar-hero{min-height:755px}.hero-copy{padding-top:43px}.hero-copy h1{font-size:clamp(45px,12vw,66px);line-height:1.1;margin-bottom:15px}.hero-copy .eyebrow,html[lang=ar] .hero-copy .eyebrow{font-size:10px;letter-spacing:.11em;gap:8px;margin-bottom:22px}.hero-copy .eyebrow::before,.hero-copy .eyebrow::after{width:20px}
.hero-copy .hero-tagline{font-size:23px;line-height:1.35;max-width:330px;margin-bottom:18px}.hero-description{font-size:14px;line-height:1.8;max-width:340px;margin-bottom:24px}.hero-actions{flex-direction:row;gap:10px;flex-wrap:nowrap}.hero-actions .button{font-size:11px;padding:12px 14px;gap:9px;min-height:46px}.hero-actions svg{width:16px}
.hero-art{width:680px;height:355px;bottom:42px}.hero-calligraphy{font-size:255px;top:-30px;transform:translate3d(var(--calligraphy-x,0px),var(--calligraphy-y,0px),0) scaleX(1.45)}.hero-foot{font-size:10px;bottom:17px;max-width:310px;margin-inline:auto}
.section{padding-block:66px}.compact-top{padding-top:0}.collection-scale{padding:40px 0 30px}.collection-scale h2{font-size:29px;margin-bottom:30px}.collection-scale .eyebrow{font-size:10px}.scale-grid{grid-template-columns:repeat(2,minmax(0,1fr));gap:26px 0}.scale-grid>div{border:0!important}.scale-grid>div:nth-child(even){border-inline-start:1px solid var(--gold-line)!important}.scale-grid dd{font-size:32px;min-height:54px}.scale-grid dt{font-size:11px}.scale-source{font-size:10px;max-width:300px;margin-inline:auto}
.editorial-heading{grid-template-columns:1fr;gap:22px;margin-bottom:34px}.editorial-heading h2{font-size:40px}.editorial-heading>p{font-size:14px;max-width:none}.eyebrow{font-size:10px;margin-bottom:20px}.verification-grid li{padding:25px 15px 22px 0}.verification-grid li+li{padding-inline-start:15px}.verification-grid li:nth-child(3){padding-inline-start:0}.verification-grid h3{font-size:15px}.verification-grid p{font-size:12px}.step-number{font-size:35px}
.collection-grid.full-grid{grid-template-columns:1fr;gap:16px}.collection-grid>div,.collection-grid>.bento-featured,.collection-grid>.bento-sovereign,.collection-grid>div:last-child:nth-child(3n){grid-column:auto}.collection-card,.bento-featured .collection-card{min-height:0;padding:25px 23px}.collection-ar,.bento-featured .collection-ar,.bento-sovereign .collection-ar{font-size:33px;margin-bottom:13px}.collection-card h3,.bento-featured h3,.bento-sovereign h3{font-size:20px}.collection-card .collection-copy>p{font-size:13px}.collection-metrics li{font-size:11px}.filter-list{gap:3px}.filter-list button{font-size:11px;padding-inline:10px}.catalog-note{font-size:11px}
.archive-layout{grid-template-columns:1fr;gap:35px}.archive-layout h2{font-size:40px}.manuscript-card{padding:25px}.manuscript-card blockquote{font-size:30px;padding-block:28px}.manuscript-footer{flex-wrap:wrap}
.membership-banner{padding:35px 27px;gap:25px}.membership-banner h2{font-size:37px}.membership-price{font-size:33px}.membership-price>span{font-size:13px}.membership-description{font-size:13px}.membership-payments{gap:8px 10px;font-size:10px}.membership-payments span{padding-inline-start:10px}.membership-action .button{font-size:12px;padding-inline:18px}.membership-action .text-link{font-size:11px}.refund-panel{padding:23px}
.adab-layout{grid-template-columns:1fr;gap:15px}.adab-calligraphy{font-size:130px;line-height:1.15;text-align:start}.adab-layout h2{font-size:40px}.adab-layout p:not(.eyebrow){font-size:14px}.home-faq h2{font-size:38px}.faq-intro{font-size:14px}.faq-list summary{padding:22px 14px;font-size:15px;gap:16px}.faq-list .faq-answer{padding:0 28px 24px 14px}.faq-answer p{font-size:13px}
.page-head{padding-block:35px 48px}.page-head h1{font-size:43px}.page-head .lede{font-size:15px}.breadcrumb{font-size:11px;padding-block:18px}.article-layout{display:block;padding-bottom:70px}.article-toc{position:static;border-bottom:1px solid var(--line);padding-bottom:24px;margin-bottom:36px}.reading-content{font-size:15px}.reading-content h2{font-size:23px}.policy-meta{padding:22px}.two-column{gap:38px}.download-grid{grid-template-columns:1fr}.footer-top{flex-direction:column;gap:15px}.footer-grid{grid-template-columns:repeat(2,minmax(0,1fr));gap:30px 20px}.footer-bottom{flex-wrap:wrap;gap:14px}.site-footer{padding-top:46px}.dialog-head{gap:16px}.source-dialog{padding:24px}.source-dialog h2{font-size:26px}
html[lang=ar] .hero-copy h1{font-size:58px;line-height:1.45}html[lang=ar] .hero-copy .hero-tagline{font-size:26px;line-height:1.6}html[lang=ar] .hero-description{font-size:20px;line-height:1.9}html[lang=ar] .scholar-hero{min-height:855px}html[lang=ar] .hero-actions .button{font-size:16px;padding-inline:13px}html[lang=ar] .verification-grid{grid-template-columns:1fr}html[lang=ar] .verification-grid li+li{border-inline-start:0;border-top:1px solid var(--gold-line);padding-inline-start:0}html[lang=ar] .editorial-heading h2,html[lang=ar] .adab-layout h2{font-size:40px}html[lang=ar] .page-head h1{font-size:42px}}
@media(max-width:360px){.container{width:calc(100% - 32px)}.wordmark{font-size:21px}.brand-mark{width:24px}.hero-copy{padding-top:36px}.hero-copy h1{font-size:44px}.hero-copy .hero-tagline{font-size:21px}.hero-description{font-size:13px}.hero-actions .button{font-size:10px;padding-inline:12px;gap:7px}.hero-art{width:600px;height:335px}.membership-price{font-size:29px}.membership-price>span{font-size:12px}}
@media(prefers-reduced-motion:reduce){html{scroll-behavior:auto}*,*::before,*::after{animation:none!important;transition:none!important}.hero-calligraphy,.hero-art img,.button,.collection-card{transform:none!important}.motion-ready [data-reveal].reveal-pending{opacity:1;transform:none}.collection-card::before{display:none}}
@media print{.site-header,.site-footer,.hero-art,.hero-actions,.search-form,.adab-calligraphy{display:none}.scholar-hero{min-height:0;padding:20px;background:white;color:black}.hero-copy{padding:0}.hero-copy h1,.hero-description,.hero-copy .hero-tagline{color:black}.hero-foot{position:static}.section{padding-block:30px}.collection-grid.full-grid{grid-template-columns:repeat(2,1fr)}.collection-card,.manuscript-card{break-inside:avoid}body{background:white;color:black}p{color:#333}}
```

## src/copy.mjs

```javascript
// Shared ID / EN / AR interface copy. Missing translations fail the build.
export const copy = {
  "id": {
    "skip": "Lewati ke isi",
    "home": "Beranda",
    "library": "Khazanah",
    "research": "Pengujian",
    "how": "Cara kerja",
    "about": "Tentang",
    "download": "Unduh aplikasi",
    "language": "Bahasa",
    "menu": "Menu",
    "close": "Tutup",
    "theme": "Ubah tema",
    "hero": "Ilmu. Lebih dekat.",
    "heroSub": "Menelaah ribuan karya klasik dan kontemporer dengan verifikasi teks Arab, jilid, dan halaman secara presisi.",
    "seeResults": "Lihat hasil pengujian",
    "scroll": "Mulai menelaah",
    "opening": "Setiap pertanyaan, sebuah jalan menuju sumber.",
    "openingSub": "OpenTurath membantu Anda menemukan pembahasan dalam kitab-kitab Islam. Sumber tetap terbuka untuk dibaca, ditelaah, dan diperiksa.",
    "example": "Contoh telaah",
    "originalQuery": "Pertanyaan asli · Indonesia",
    "sourceText": "Kutipan dalam jawaban",
    "sourceNote": "Kutipan dari arsip Q001. Pemeriksaan edisi ditampilkan terpisah.",
    "openSource": "Buka rujukan",
    "readFull": "Baca jawaban lengkap",
    "fieldTitle": "Khazanah para ulama.\nRuang bagi setiap telaah.",
    "fieldSub": "Dua puluh disiplin keilmuan, dari fikih mazhab hingga tahqiq naskah. Temukan khadim yang memahami bidang telaah Anda.",
    "allLibrary": "Jelajahi seluruh pustaka",
    "compareTitle": "Pertanyaan yang sama.\nPeriksa hasilnya.",
    "compareSub": "Enam jawaban, ditampilkan sebagaimana tersimpan dalam bahan pengujian. Baca teksnya. Telusuri rujukannya. Nilai perbedaannya.",
    "compareCta": "Buka perbandingan",
    "caseLabel": "Studi kasus",
    "topic": "Sentuhan dan wudhu dalam mazhab Syafi’i",
    "methodTitle": "Ibarahnya terbaca.\nRujukannya dapat ditelaah.",
    "methodSub": "Teks kitab, penjelasan aplikasi, dan keterangan bibliografi memiliki tempatnya masing-masing. Agar Anda tahu apa yang sedang dibaca.",
    "sourceLayer": "Teks sumber",
    "explanationLayer": "Penjelasan aplikasi",
    "referenceLayer": "Keterangan rujukan",
    "special": "Koleksi khusus",
    "tahawwulat": "Fikih Tahawwulat",
    "tahaTitle": "Membaca perubahan.\nMenelaah tuntunan.",
    "tahaSub": "Telaah karya dan pelajaran Habib Abu Bakar al-Adni al-Masyhur dalam koleksi khusus Fikih Tahawwulat.",
    "exploreCollection": "Kenali koleksi",
    "access": "Keanggotaan",
    "billing": "Pembayaran dan Pengembalian Dana",
    "aiGuidelines": "Panduan Penggunaan AI & Rujukan",
    "accessTitle": "Akses Penuh Khazanah Keilmuan",
    "accessSub": "Pilih khadim spesialis disiplin ilmu yang ingin Anda telaah. Akses dan aktivasi diproses resmi di aplikasi melalui DOKU, tanpa perpanjangan otomatis.",
    "downloadTitle": "Lanjutkan telaah\ndi OpenTurath.",
    "downloadSub": "Pilih platform Anda untuk melanjutkan telaah. Ketersediaan rilis dan panduan pemasangan tercantum di bawah.",
    "faq": "Pertanyaan yang sering diajukan",
    "help": "Bantuan",
    "contact": "Bantuan dan Kontak",
    "report": "Laporkan masalah",
    "releases": "Catatan rilis",
    "methods": "Metode pengujian",
    "corrections": "Catatan koreksi",
    "privacy": "Kebijakan Privasi",
    "terms": "Ketentuan Layanan",
    "rights": "Sumber & hak penggunaan",
    "accessibility": "Aksesibilitas",
    "deletion": "Penghapusan akun",
    "security": "Pelaporan keamanan",
    "product": "Produk",
    "scholarship": "Riset",
    "information": "Informasi",
    "search": "Cari judul kitab, pengarang, atau bidang…",
    "searchCollections": "Cari koleksi atau bidang ilmu",
    "all": "Semua",
    "collections": "Koleksi",
    "books": "Kitab dalam contoh",
    "fiqh": "Fikih",
    "hadith": "Hadis",
    "quran": "Al-Qur’an",
    "languageGroup": "Bahasa & bibliografi",
    "history": "Sejarah & biografi",
    "spirituality": "Tazkiyah",
    "theology": "Akidah",
    "specialGroup": "Koleksi khusus",
    "noResults": "Tidak ada hasil. Ubah kata kunci atau hapus filter.",
    "clear": "Hapus filter",
    "results": "hasil",
    "catalogNote": "Angka khazanah bersumber dari metadata modul aplikasi. Status ketersediaan ditampilkan pada setiap koleksi.",
    "contents": "Cakupan kajian",
    "bibliography": "Bibliografi",
    "author": "Pengarang",
    "edition": "Edisi",
    "locator": "Rujukan dalam jawaban",
    "unknown": "Belum tersedia",
    "recorded": "Tercatat dalam arsip jawaban",
    "unverified": "Belum diperiksa",
    "verifyNote": "Data ini merekam rujukan yang diberikan dalam jawaban asli. Kesesuaian teks dan edisi belum diverifikasi ulang pada situs ini.",
    "linkedCase": "Lihat dalam studi kasus",
    "researchTitle": "Bukti yang bisa Anda baca.",
    "researchSub": "Pertanyaan, jawaban asli, dan catatan pemeriksaan disajikan bersama. Kesimpulan mengikuti bukti yang tersedia.",
    "archive": "Arsip perbandingan",
    "scopeNote": "Satu pertanyaan. Enam produk. Hasil ini tidak mewakili seluruh kemampuan setiap produk.",
    "date": "Tanggal pengujian",
    "notRecorded": "Tidak tercatat",
    "reviewStatus": "Status pemeriksaan",
    "original": "Jawaban asli",
    "compareWith": "Bandingkan dengan",
    "sourceConversation": "Percakapan sumber",
    "sourceAccess": "Tautan sumber mungkin memerlukan akun.",
    "archiveDownload": "Unduh arsip asli",
    "notes": "Catatan",
    "references": "Rujukan yang disebut",
    "reviewDetail": "Arsip ini memuat kutipan dan rujukan bibliografi. Penilaian terdahulu menyebut kecocokan sepuluh kutipan dengan Syamilah, tetapi berkas pemeriksaan per kutipan belum disertakan. Karena itu, tidak ada skor akurasi yang ditetapkan di sini.",
    "issuesDetail": "Catatan evaluasi terdahulu juga menyoroti elaborasi di luar teks, ketidakjelasan penisbahan, perluasan kesimpulan, dan pembahasan di luar pertanyaan. Temuan tersebut tetap menjadi bagian dari pembacaan kasus ini.",
    "focus": "Mode baca",
    "exitFocus": "Keluar dari mode baca",
    "copy": "Salin teks & rujukan",
    "copied": "Teks dan rujukan disalin.",
    "copyFailed": "Belum tersalin. Pilih teks untuk menyalin manual.",
    "installGuide": "Panduan pemasangan",
    "releasePending": "Tautan unduhan resmi belum diterbitkan.",
    "releasePendingSub": "Panduan penggunaan dan contoh hasil tetap dapat Anda baca di situs ini.",
    "version": "Versi",
    "minimumOS": "Sistem minimum",
    "size": "Ukuran",
    "releaseDate": "Tanggal rilis",
    "downloadPlatform": "Unduh untuk",
    "noReleases": "Belum ada rilis aplikasi yang dicantumkan.",
    "noPlans": "Rincian akses dan biaya belum diterbitkan.",
    "noPlansSub": "Informasi akan mencantumkan koleksi, masa akses, harga, dan ketentuan perpanjangannya.",
    "helpTitle": "Ada yang ingin Anda ketahui?",
    "helpSearch": "Cari panduan",
    "contactTitle": "Sampaikan pertanyaan Anda.",
    "contactSub": "Tentang aplikasi, koleksi, atau rujukan yang perlu ditelaah kembali.",
    "email": "Email",
    "subject": "Topik",
    "message": "Uraian",
    "emailHint": "Opsional, jika Anda menginginkan balasan.",
    "reportSource": "Koreksi rujukan",
    "reportTechnical": "Masalah teknis",
    "reportAccess": "Akses & pembayaran",
    "reportOther": "Pertanyaan lain",
    "reportHint": "Sertakan judul kitab, edisi, halaman, atau langkah yang memunculkan masalah. Jangan sertakan kata sandi atau data pribadi yang tidak diperlukan.",
    "consent": "Saya menyetujui penggunaan informasi ini untuk menindaklanjuti laporan.",
    "submit": "Kirim laporan",
    "sending": "Mengirim…",
    "sent": "Laporan telah disimpan. Nomor laporan:",
    "failed": "Laporan belum terkirim. Coba kembali, atau unduh salinannya.",
    "saveReport": "Unduh salinan laporan",
    "contactPending": "Alamat kontak resmi belum dicantumkan.",
    "formRetention": "Laporan disimpan selama 30 hari pada layanan formulir situs.",
    "noCorrections": "Belum ada koreksi yang diterbitkan.",
    "notFound": "Halaman ini tidak ditemukan.",
    "backHome": "Kembali ke beranda",
    "back": "Kembali",
    "readGuide": "Baca panduan",
    "policyNotice": "Informasi operasional belum lengkap. Kebijakan final akan memuat identitas pengelola dan praktik layanan yang berlaku.",
    "updated": "Terakhir diperbarui",
    "export": "Unduh",
    "chooseLanguage": "Pilih bahasa",
    "chooseLanguageSub": "Khazanah yang sama. Bahasa pilihan Anda.",
    "privacyShort": "Tanpa pelacak analitik eksternal.",
    "unavailable": "Belum tersedia",
    "textSize": "Ukuran teks",
    "increaseText": "Perbesar teks",
    "decreaseText": "Perkecil teks",
    "originalLanguage": "Keluaran asli dipertahankan dalam bahasa Indonesia.",
    "bookshelf": "Jejak rujukan",
    "goMethod": "Baca metode pemeriksaan",
    "noFullBooks": "Halaman ini menyajikan metadata dan rujukan contoh. Pembacaan koleksi berlangsung di aplikasi.",
    "publicAccess": "Dapat dibaca tanpa akun",
    "publicAccessBody": "Katalog, panduan, dan arsip pengujian di situs ini tersedia untuk dibaca.",
    "appAccess": "Akses dalam aplikasi",
    "chars": "karakter",
    "share": "Salin tautan",
    "linkCopied": "Tautan disalin.",
    "heroTagline": "Khazanah para ulama. Dalam jangkauan Anda.",
    "heroCta": "Jelajahi khazanah",
    "heroSecondary": "Pelajari metodenya",
    "heroFoot": "Berpijak pada sumber. Bertumbuh bersama bimbingan guru.",
    "booksAlt": "Kitab klasik dengan halaman terbuka",
    "verifyEyebrow": "METODE TELAAH",
    "verifyTitle": "Dari mas’alah,\nkembali ke sumber.",
    "verifySub": "Empat langkah sistematis untuk menelaah naskah asli: pertanyaan terarah, penelusuran teks primer, pencocokan koordinat cetakan, dan telaah bersama guru.",
    "step1": "Ajukan pertanyaan",
    "step1Body": "Pilih khadim sesuai disiplin ilmu, lalu uraikan masalah dan konteks yang ingin Anda dalami.",
    "step2": "Telusuri teks primer",
    "step2Body": "Telusuri ibarah Arab dalam kitab rujukan. Baca kutipan beserta pembahasan yang mengitarinya.",
    "step3": "Kenali koordinat cetakan",
    "step3Body": "Judul kitab, edisi, jilid, dan halaman menjadi panduan untuk mencocokkan ibarah dengan naskah sumber.",
    "step4": "Telaah bersama guru",
    "step4Body": "Bawa ibarah beserta rujukannya ke majelis ilmu. Perdalam makna, timbang konteks, dan susun kesimpulan dengan bimbingan guru.",
    "verifyLimit": "AI dapat keliru. Verifikasi merupakan proses pemeriksaan, bukan jaminan bahwa setiap keluaran bebas kesalahan.",
    "catalogEyebrow": "DISIPLIN KEILMUAN",
    "available": "Tersedia di aplikasi",
    "preparing": "Dalam persiapan",
    "preparingBody": "Koleksi ini sedang dikurasi dan ditata sebelum dibuka untuk umum. Perkembangan ketersediaannya akan diumumkan melalui catatan rilis.",
    "archiveEyebrow": "JEJAK RUJUKAN",
    "archiveTitle": "Ibarah terbuka.\nTelaah yang transparan.",
    "archiveBody": "Baca bagaimana OpenTurath menyajikan ibarah Al-Umm beserta nomor jilid dan halaman dalam arsip Q001. Bandingkan keluaran asli enam model dan telusuri catatan pemeriksaan sumbernya.",
    "memberEyebrow": "AKSES KEILMUAN",
    "chooseMembership": "Buka Akses di Aplikasi",
    "memberManual": "Perpanjangan manual. Tanpa auto-debit.",
    "memberPayment": "DOKU · QRIS · Virtual Account · E-Wallet",
    "memberMethods": "Rincian paket, metode pembayaran, dan total biaya ditampilkan sebelum transaksi.",
    "memberRefund": "Permohonan refund ditinjau paling lambat 7 hari kerja setelah data lengkap. Jika disetujui, pemrosesan paling lambat 7 hari kerja berikutnya, mengikuti penyedia pembayaran.",
    "memberNotice": "Aktivasi keanggotaan melalui aplikasi OpenTurath.",
    "featuredPlan": "Cakupan terluas",
    "adabTitle": "Berpijak pada sumber.\nBertumbuh bersama guru.",
    "adabBody": "Menghubungkan kecerdasan buatan dengan keaslian naskah ulama, mempermudah pelacakan ibarah tanpa menggantikan bimbingan guru. Jaga nisbah kutipan, hormati ikhtilaf, dan hidupkan tradisi talaqqi.",
    "legalVersion": "Ringkasan kebijakan aplikasi · v1.0 · 13 September 2026",
    "legalCanonical": "Baca naskah resmi bahasa Indonesia",
    "policySummary": "Halaman ini merangkum naskah resmi aplikasi. Rincian penawaran terbaru dan ketentuan khusus website dijelaskan terpisah di bawah.",
    "downloadIntegrity": "SHA-256 dihitung dari berkas APK yang disertakan dalam rilis website ini.",
    "studySpace": "Ruang Telaah",
    "referenceBooks": "Pustaka Marja' Mu'tamad",
    "archiveSample": "Kutipan arsip Q001",
    "memberFrom": "Mulai dari",
    "memberPerMonth": "/ bulan",
    "memberReview": "Tinjauan refund hingga 7 hari kerja",
    "faqIntro": "Bekal sebelum memulai telaah.",
    "navAdab": "Adab",
    "navDownload": "Unduh",
    "awaitingArtifact": "Berkas rilis sedang disiapkan",
    "statsEyebrow": "SKALA KHAZANAH",
    "statsTitle": "Warisan ilmu. Dalam satu khazanah.",
    "statsSource": "Akumulasi metadata 20 modul aplikasi · 21 profil khadim, termasuk 1 dalam persiapan.",
    "metricDisciplines": "Disiplin ilmu aktif",
    "metricBooks": "Kitab turats",
    "metricVolumes": "Jilid naskah",
    "metricPages": "Halaman",
    "metricWords": "Kata teks turats",
    "metricPartitions": "Partisi terindeks",
    "metaBooks": "Kitab",
    "metaVolumes": "Jilid",
    "metaPages": "Halaman",
    "metaWords": "Kata",
    "metaLectures": "Muhadharah",
    "metaMillion": "Juta",
    "metaBillion": "Miliar",
    "collectionMetrics": "Metadata khazanah",
    "statsEra": "Dari masa pra-Hijrah hingga era modern.",
    "paymentVA": "Rekening virtual",
    "paymentWallet": "Dompet digital"
  },
  "en": {
    "skip": "Skip to content",
    "home": "Home",
    "library": "Library",
    "research": "Evaluation",
    "how": "How it works",
    "about": "About",
    "download": "Download the app",
    "language": "Language",
    "menu": "Menu",
    "close": "Close",
    "theme": "Change theme",
    "hero": "Knowledge. Within reach.",
    "heroSub": "Explore thousands of classical and contemporary works through careful verification of Arabic text, volumes, and pages.",
    "seeResults": "Examine the results",
    "scroll": "Begin exploring",
    "opening": "Every question, a way back to the source.",
    "openingSub": "OpenTurath helps you find discussions across Islamic texts. The sources remain there to be read, studied, and checked.",
    "example": "A research example",
    "originalQuery": "Original question · Indonesian",
    "sourceText": "Passage in the answer",
    "sourceNote": "Passage from the Q001 archive. Edition review is documented separately.",
    "openSource": "Open reference",
    "readFull": "Read the full answer",
    "fieldTitle": "A scholarly heritage.\nA place for every enquiry.",
    "fieldSub": "Twenty scholarly disciplines, from the schools of fiqh to manuscript study. Find an assistant dedicated to your field.",
    "allLibrary": "Explore the library",
    "compareTitle": "The same question.\nExamine the answers.",
    "compareSub": "Six answers, preserved as supplied in the evaluation archive. Read the text. Follow the references. Consider the differences.",
    "compareCta": "Open the comparison",
    "caseLabel": "Case study",
    "topic": "Touch and ablution in Shāfiʿī fiqh",
    "methodTitle": "Read the passage.\nExamine the reference.",
    "methodSub": "Source text, the app’s explanation, and bibliographic details each have their place. So you know what you are reading.",
    "sourceLayer": "Source text",
    "explanationLayer": "App explanation",
    "referenceLayer": "Reference details",
    "special": "A dedicated collection",
    "tahawwulat": "Fiqh al-Tahawwulat",
    "tahaTitle": "Study change.\nConsider its guidance.",
    "tahaSub": "Explore the works and lessons of Habib Abu Bakr al-Adani al-Mashhur in a dedicated Fiqh al-Tahawwulat collection.",
    "exploreCollection": "Explore the collection",
    "access": "Membership",
    "billing": "Payment & Refunds",
    "aiGuidelines": "AI Use & Reference Verification",
    "accessTitle": "A home for deeper scholarship",
    "accessSub": "Choose a specialist assistant for the discipline you wish to study. Access and activation are handled in the app through DOKU, with manual renewal.",
    "downloadTitle": "Continue your research\nin OpenTurath.",
    "downloadSub": "Choose your platform to continue studying. Release availability and installation guidance are listed below.",
    "faq": "Frequently asked questions",
    "help": "Help",
    "contact": "Support & Contact",
    "report": "Report an issue",
    "releases": "Release notes",
    "methods": "Methodology",
    "corrections": "Corrections",
    "privacy": "Privacy Policy",
    "terms": "Terms of Service",
    "rights": "Sources & usage rights",
    "accessibility": "Accessibility",
    "deletion": "Account deletion",
    "security": "Security reporting",
    "product": "Product",
    "scholarship": "Research",
    "information": "Information",
    "search": "Search titles, authors, or disciplines…",
    "searchCollections": "Search collections or fields",
    "all": "All",
    "collections": "Collections",
    "books": "Books in the example",
    "fiqh": "Fiqh",
    "hadith": "Hadith",
    "quran": "Qur’an",
    "languageGroup": "Language & bibliography",
    "history": "History & biography",
    "spirituality": "Spirituality",
    "theology": "Theology",
    "specialGroup": "Special collection",
    "noResults": "No results. Try another term or clear the filters.",
    "clear": "Clear filters",
    "results": "results",
    "catalogNote": "Collection figures come from the app’s module metadata. Each collection displays its availability.",
    "contents": "Scope of study",
    "bibliography": "Bibliography",
    "author": "Author",
    "edition": "Edition",
    "locator": "Reference in the answer",
    "unknown": "Not yet available",
    "recorded": "Recorded in the answer archive",
    "unverified": "Not yet reviewed",
    "verifyNote": "This record preserves the reference given in the original answer. Text and edition correspondence have not been reverified for this site.",
    "linkedCase": "View in the case study",
    "researchTitle": "Evidence you can read.",
    "researchSub": "Questions, original answers, and review notes are presented together. Conclusions follow the available evidence.",
    "archive": "Comparison archive",
    "scopeNote": "One question. Six products. These results do not represent each product’s full capabilities.",
    "date": "Test date",
    "notRecorded": "Not recorded",
    "reviewStatus": "Review status",
    "original": "Original answer",
    "compareWith": "Compare with",
    "sourceConversation": "Source conversation",
    "sourceAccess": "The source link may require an account.",
    "archiveDownload": "Download original archive",
    "notes": "Notes",
    "references": "References cited",
    "reviewDetail": "The archive contains quotations and bibliographic references. An earlier assessment reported ten matches against Shamela, but its individual verification records were not supplied. No accuracy score is therefore assigned here.",
    "issuesDetail": "Earlier review notes also flagged elaboration beyond the text, unclear attribution, extended inferences, and discussion outside the question. These observations remain part of the case record.",
    "focus": "Reading mode",
    "exitFocus": "Exit reading mode",
    "copy": "Copy text & reference",
    "copied": "Text and reference copied.",
    "copyFailed": "Could not copy. Select the text to copy manually.",
    "installGuide": "Installation guide",
    "releasePending": "The official download link has not been published yet.",
    "releasePendingSub": "You can still explore the guides and research examples on this site.",
    "version": "Version",
    "minimumOS": "Minimum system",
    "size": "Size",
    "releaseDate": "Release date",
    "downloadPlatform": "Download for",
    "noReleases": "No app releases have been listed yet.",
    "noPlans": "Access and pricing details have not been published yet.",
    "noPlansSub": "The details will identify included collections, access periods, prices, and renewal terms.",
    "helpTitle": "What would you like to know?",
    "helpSearch": "Search the guides",
    "contactTitle": "Get in touch.",
    "contactSub": "About the app, a collection, or a reference that needs another look.",
    "email": "Email",
    "subject": "Topic",
    "message": "Details",
    "emailHint": "Optional, if you would like a reply.",
    "reportSource": "Reference correction",
    "reportTechnical": "Technical issue",
    "reportAccess": "Access & payment",
    "reportOther": "Other question",
    "reportHint": "Include the book, edition, page, or steps that led to the issue. Do not include passwords or unnecessary personal information.",
    "consent": "I agree to the use of this information to address my report.",
    "submit": "Submit report",
    "sending": "Sending…",
    "sent": "Your report has been saved. Reference:",
    "failed": "Your report was not sent. Try again, or download a copy.",
    "saveReport": "Download report copy",
    "contactPending": "An official contact address has not been listed yet.",
    "formRetention": "Reports are stored for 30 days by the site’s form service.",
    "noCorrections": "No corrections have been published.",
    "notFound": "This page could not be found.",
    "backHome": "Return home",
    "back": "Back",
    "readGuide": "Read the guide",
    "policyNotice": "Operational information is incomplete. The final policy will identify the operator and applicable service practices.",
    "updated": "Last updated",
    "export": "Download",
    "chooseLanguage": "Choose your language",
    "chooseLanguageSub": "The same scholarship. Your preferred language.",
    "privacyShort": "No external analytics trackers.",
    "unavailable": "Not available yet",
    "textSize": "Text size",
    "increaseText": "Increase text size",
    "decreaseText": "Decrease text size",
    "originalLanguage": "Original outputs are preserved in Indonesian.",
    "bookshelf": "A trail of references",
    "goMethod": "Read the review method",
    "noFullBooks": "This page presents metadata and sample references. Collection research takes place in the app.",
    "publicAccess": "Read without an account",
    "publicAccessBody": "The catalogue, guides, and evaluation archive on this site are available to read.",
    "appAccess": "Access in the app",
    "chars": "characters",
    "share": "Copy link",
    "linkCopied": "Link copied.",
    "heroTagline": "The scholarship of generations. Within your reach.",
    "heroCta": "Explore the library",
    "heroSecondary": "Discover the method",
    "heroFoot": "Rooted in sources. Guided by teachers.",
    "booksAlt": "Classical books with open pages",
    "verifyEyebrow": "THE STUDY METHOD",
    "verifyTitle": "From enquiry,\nback to the source.",
    "verifySub": "Four considered steps through the original sources: a focused question, primary-text search, edition matching, and study with a teacher.",
    "step1": "Ask a question",
    "step1Body": "Choose the assistant for your discipline and describe the question and its context.",
    "step2": "Locate primary texts",
    "step2Body": "Trace the Arabic passage in the reference works. Read the quotation alongside its surrounding discussion.",
    "step3": "Locate the printed edition",
    "step3Body": "Title, edition, volume, and page guide you to match the passage against its source.",
    "step4": "Study with a teacher",
    "step4Body": "Bring the passage and its reference to your teacher. Explore its meaning, weigh the context, and develop your conclusions together.",
    "verifyLimit": "AI can make mistakes. Verification is a review process, not a guarantee that every output is error-free.",
    "catalogEyebrow": "FIELDS OF SCHOLARSHIP",
    "available": "Available in the app",
    "preparing": "In preparation",
    "preparingBody": "This collection is being curated and organised for public access. Availability updates will appear in the release notes.",
    "archiveEyebrow": "A TRACEABLE REFERENCE",
    "archiveTitle": "Open passages.\nTransparent enquiry.",
    "archiveBody": "Explore how OpenTurath presents passages from Al-Umm with volume and page references in the Q001 archive. Compare six original model responses and examine the source-review records.",
    "memberEyebrow": "MEMBERSHIP",
    "chooseMembership": "Access in the app",
    "memberManual": "Manual renewal. No automatic debit.",
    "memberPayment": "DOKU · QRIS · Virtual Account · E-Wallet",
    "memberMethods": "Plan details, payment methods, and the total are shown before you pay.",
    "memberRefund": "Refund requests are reviewed within 7 business days of complete information. Approved refunds are processed within a further 7 business days, subject to the payment provider.",
    "memberNotice": "Membership is activated in the OpenTurath app.",
    "featuredPlan": "Broadest scope",
    "adabTitle": "Rooted in sources.\nGuided by teachers.",
    "adabBody": "Connecting artificial intelligence with the scholars’ original texts, making passages easier to find while preserving the teacher’s guidance. Attribute quotations, respect scholarly differences, and continue the tradition of talaqqi.",
    "legalVersion": "App policy summary · v1.0 · 13 September 2026",
    "legalCanonical": "Read the official Indonesian text",
    "policySummary": "This page summarizes the official app policy. Current offer details and website-specific terms are explained separately below.",
    "downloadIntegrity": "SHA-256 is calculated from the APK file included in this website release.",
    "studySpace": "Study Room",
    "referenceBooks": "Authoritative References",
    "archiveSample": "Q001 archive excerpt",
    "memberFrom": "From",
    "memberPerMonth": "/ month",
    "memberReview": "Refund review within 7 business days",
    "faqIntro": "A few things to help you begin.",
    "navAdab": "Adab",
    "navDownload": "Download",
    "awaitingArtifact": "Release file in preparation",
    "statsEyebrow": "THE COLLECTION IN NUMBERS",
    "statsTitle": "A scholarly heritage. One collection.",
    "statsSource": "Combined metadata from 20 app modules · 21 assistant profiles, including 1 in preparation.",
    "metricDisciplines": "Active disciplines",
    "metricBooks": "Scholarly works",
    "metricVolumes": "Volumes",
    "metricPages": "Pages",
    "metricWords": "Words of turath",
    "metricPartitions": "Indexed partitions",
    "metaBooks": "Works",
    "metaVolumes": "Volumes",
    "metaPages": "Pages",
    "metaWords": "Words",
    "metaLectures": "Lectures",
    "metaMillion": "Million",
    "metaBillion": "Billion",
    "collectionMetrics": "Collection metadata",
    "statsEra": "From the pre-Hijra era to modern scholarship.",
    "paymentVA": "Virtual Account",
    "paymentWallet": "E-Wallet"
  },
  "ar": {
    "skip": "انتقل إلى المحتوى",
    "home": "الرئيسية",
    "library": "الخزانة",
    "research": "الاختبارات",
    "how": "طريقة الاستخدام",
    "about": "عن المشروع",
    "download": "تنزيل التطبيق",
    "language": "اللغة",
    "menu": "القائمة",
    "close": "إغلاق",
    "theme": "تغيير المظهر",
    "hero": "العلم. أقرب إليك.",
    "heroSub": "تأمّل آلاف المؤلفات التراثية والمعاصرة مع العناية بالتحقّق من النص العربي والجزء والصفحة.",
    "seeResults": "اطّلع على النتائج",
    "scroll": "ابدأ التصفّح",
    "opening": "كل سؤال طريق إلى مصدره.",
    "openingSub": "يعينك OpenTurath على العثور على مباحث المسائل في كتب التراث، لتظل المصادر بين يديك قراءةً ودراسةً وتحقّقًا.",
    "example": "نموذج بحث",
    "originalQuery": "السؤال الأصلي · الإندونيسية",
    "sourceText": "النص المنقول في الإجابة",
    "sourceNote": "نص من أرشيف Q001. تُبيَّن مراجعة الطبعة على حدة.",
    "openSource": "افتح المرجع",
    "readFull": "اقرأ الإجابة كاملة",
    "fieldTitle": "تراث العلماء.\nوآفاق لكل بحث.",
    "fieldSub": "عشرون تخصصًا علميًّا، من فقه المذاهب إلى تحقيق النصوص. اختر المساعد المختص بمجال بحثك.",
    "allLibrary": "تصفّح المكتبة كاملة",
    "compareTitle": "السؤال واحد.\nتأمّل الإجابات.",
    "compareSub": "ست إجابات محفوظة كما وردت في مواد الاختبار. اقرأ النصوص، وتتبع الإحالات، وانظر في الفروق.",
    "compareCta": "افتح المقارنة",
    "caseLabel": "دراسة حالة",
    "topic": "اللمس والوضوء في المذهب الشافعي",
    "methodTitle": "اقرأ العبارة.\nوانظر في مرجعها.",
    "methodSub": "لنص الكتاب وشرح التطبيق وبيانات المرجع موضعٌ يميّز كلًّا منها، لتعرف ما تقرأه.",
    "sourceLayer": "نص المصدر",
    "explanationLayer": "شرح التطبيق",
    "referenceLayer": "بيانات المرجع",
    "special": "مجموعة خاصة",
    "tahawwulat": "فقه التحولات",
    "tahaTitle": "قراءة التحولات.\nوالنظر في هديها.",
    "tahaSub": "طالع مؤلفات الحبيب أبي بكر العدني المشهور ودروسه في مجموعة خاصة بفقه التحولات.",
    "exploreCollection": "تعرّف إلى المجموعة",
    "access": "العضوية",
    "billing": "الدفع والاسترداد",
    "aiGuidelines": "استخدام الذكاء الاصطناعي والتحقق من المراجع",
    "accessTitle": "آفاق أرحب لمطالعة التراث",
    "accessSub": "اختر المساعد المختص بالعلم الذي تريد دراسته. يُفعّل الوصول رسميًّا داخل التطبيق عبر DOKU، مع تجديد يدوي.",
    "downloadTitle": "واصل بحثك\nفي OpenTurath.",
    "downloadSub": "اختر منصتك لمواصلة المطالعة. تجد أدناه حالة الإصدارات وإرشادات التثبيت.",
    "faq": "الأسئلة الشائعة",
    "help": "المساعدة",
    "contact": "المساعدة والتواصل",
    "report": "أبلغ عن مشكلة",
    "releases": "سجل الإصدارات",
    "methods": "منهجية الاختبار",
    "corrections": "سجل التصحيحات",
    "privacy": "سياسة الخصوصية",
    "terms": "شروط الخدمة",
    "rights": "المصادر وحقوق الاستخدام",
    "accessibility": "إمكانية الوصول",
    "deletion": "حذف الحساب",
    "security": "الإبلاغ عن الثغرات",
    "product": "المنتج",
    "scholarship": "البحث",
    "information": "معلومات",
    "search": "ابحث عن عنوان أو مؤلف أو مجال…",
    "searchCollections": "ابحث عن مجموعة أو علم",
    "all": "الكل",
    "collections": "المجموعات",
    "books": "كتب النموذج",
    "fiqh": "الفقه",
    "hadith": "الحديث",
    "quran": "القرآن",
    "languageGroup": "اللغة والفهارس",
    "history": "التاريخ والتراجم",
    "spirituality": "التزكية",
    "theology": "العقيدة",
    "specialGroup": "مجموعة خاصة",
    "noResults": "لا نتائج. جرّب عبارة أخرى أو أزل المرشّحات.",
    "clear": "إزالة المرشّحات",
    "results": "نتائج",
    "catalogNote": "أعداد الخزانة مأخوذة من بيانات وحدات التطبيق، وتُبيّن كل مجموعة حالة إتاحتها.",
    "contents": "نطاق البحث",
    "bibliography": "بيانات الكتاب",
    "author": "المؤلف",
    "edition": "الطبعة",
    "locator": "الإحالة في الإجابة",
    "unknown": "غير متاح بعد",
    "recorded": "مسجّل في أرشيف الإجابة",
    "unverified": "لم يُراجع بعد",
    "verifyNote": "يحفظ هذا السجل الإحالة الواردة في الإجابة الأصلية. لم تُراجع مطابقة النص والطبعة من جديد لهذا الموقع.",
    "linkedCase": "اعرض في دراسة الحالة",
    "researchTitle": "شواهد يمكنك قراءتها.",
    "researchSub": "تُعرض الأسئلة والإجابات الأصلية وملاحظات المراجعة معًا، وتُبنى النتائج على الشواهد المتاحة.",
    "archive": "أرشيف المقارنة",
    "scopeNote": "سؤال واحد وستة منتجات. لا تمثل هذه النتائج جميع قدرات كل منتج.",
    "date": "تاريخ الاختبار",
    "notRecorded": "غير مسجّل",
    "reviewStatus": "حالة المراجعة",
    "original": "الإجابة الأصلية",
    "compareWith": "قارن مع",
    "sourceConversation": "المحادثة الأصلية",
    "sourceAccess": "قد يتطلب رابط المصدر حسابًا.",
    "archiveDownload": "نزّل الأرشيف الأصلي",
    "notes": "الملاحظات",
    "references": "المراجع المذكورة",
    "reviewDetail": "يتضمن الأرشيف نصوصًا منقولة وإحالات ببليوغرافية. ذكرت مراجعة سابقة مطابقة عشرة نصوص للمكتبة الشاملة، لكن سجلات التحقّق المفردة لم تُرفق؛ لذا لا تُمنح هنا نسبة للدقة.",
    "issuesDetail": "أشارت ملاحظات سابقة أيضًا إلى زيادات على النص، وغموض في العزو، وتوسّع في الاستنتاج، وخروج عن السؤال. وتظل هذه الملاحظات جزءًا من سجل الحالة.",
    "focus": "وضع القراءة",
    "exitFocus": "الخروج من وضع القراءة",
    "copy": "انسخ النص والمرجع",
    "copied": "نُسخ النص ومرجعه.",
    "copyFailed": "تعذّر النسخ. حدّد النص لنسخه يدويًّا.",
    "installGuide": "دليل التثبيت",
    "releasePending": "لم يُنشر رابط التنزيل الرسمي بعد.",
    "releasePendingSub": "يمكنك الآن الاطّلاع على الأدلة ونماذج البحث في هذا الموقع.",
    "version": "الإصدار",
    "minimumOS": "النظام المطلوب",
    "size": "الحجم",
    "releaseDate": "تاريخ الإصدار",
    "downloadPlatform": "تنزيل لنظام",
    "noReleases": "لم تُدرج إصدارات التطبيق بعد.",
    "noPlans": "لم تُنشر تفاصيل الإتاحة والأسعار بعد.",
    "noPlansSub": "ستبيّن التفاصيل المجموعات المشمولة ومدد الإتاحة والأسعار وشروط التجديد.",
    "helpTitle": "ما الذي تودّ معرفته؟",
    "helpSearch": "ابحث في الأدلة",
    "contactTitle": "تواصل معنا.",
    "contactSub": "بشأن التطبيق أو المجموعات أو إحالة تحتاج إلى مراجعة.",
    "email": "البريد الإلكتروني",
    "subject": "الموضوع",
    "message": "التفاصيل",
    "emailHint": "اختياري، إذا رغبت في تلقّي رد.",
    "reportSource": "تصحيح إحالة",
    "reportTechnical": "مشكلة تقنية",
    "reportAccess": "الإتاحة والدفع",
    "reportOther": "سؤال آخر",
    "reportHint": "أرفق اسم الكتاب والطبعة والصفحة، أو الخطوات التي ظهرت عندها المشكلة. لا تذكر كلمات المرور أو بيانات شخصية غير لازمة.",
    "consent": "أوافق على استخدام هذه المعلومات لمتابعة بلاغي.",
    "submit": "أرسل البلاغ",
    "sending": "جارٍ الإرسال…",
    "sent": "حُفظ بلاغك. رقم البلاغ:",
    "failed": "لم يُرسل البلاغ. حاول مرة أخرى، أو نزّل نسخة منه.",
    "saveReport": "نزّل نسخة من البلاغ",
    "contactPending": "لم يُدرج عنوان التواصل الرسمي بعد.",
    "formRetention": "تُحفظ البلاغات مدة ٣٠ يومًا في خدمة النماذج بالموقع.",
    "noCorrections": "لم تُنشر تصحيحات بعد.",
    "notFound": "لم يُعثر على هذه الصفحة.",
    "backHome": "العودة إلى الرئيسية",
    "back": "عودة",
    "readGuide": "اقرأ الدليل",
    "policyNotice": "المعلومات التشغيلية غير مكتملة. ستبيّن السياسة النهائية هوية القائم على الخدمة وممارساتها المعتمدة.",
    "updated": "آخر تحديث",
    "export": "تنزيل",
    "chooseLanguage": "اختر لغتك",
    "chooseLanguageSub": "التراث نفسه، باللغة التي تختارها.",
    "privacyShort": "دون متتبّعات تحليلية خارجية.",
    "unavailable": "غير متاح بعد",
    "textSize": "حجم النص",
    "increaseText": "تكبير النص",
    "decreaseText": "تصغير النص",
    "originalLanguage": "حُفظت الإجابات بلغتها الأصلية، الإندونيسية.",
    "bookshelf": "مسار الإحالات",
    "goMethod": "اقرأ منهج المراجعة",
    "noFullBooks": "تعرض هذه الصفحة البيانات وإحالات النموذج. ويجري البحث في المجموعات داخل التطبيق.",
    "publicAccess": "متاح للقراءة دون حساب",
    "publicAccessBody": "الفهرس والأدلة وأرشيف الاختبارات في هذا الموقع متاحة للقراءة.",
    "appAccess": "الإتاحة داخل التطبيق",
    "chars": "حرفًا",
    "share": "انسخ الرابط",
    "linkCopied": "نُسخ الرابط.",
    "heroTagline": "تراث العلماء. بين يديك.",
    "heroCta": "استكشف الخزانة",
    "heroSecondary": "تعرّف على المنهج",
    "heroFoot": "على أصول المصادر، وبإرشاد أهل العلم.",
    "booksAlt": "كتب تراثية مفتوحة الصفحات",
    "verifyEyebrow": "منهج المطالعة",
    "verifyTitle": "من المسألة،\nإلى المصدر.",
    "verifySub": "أربع خطوات منهجية لمطالعة الأصول: سؤال محدد، وتتبع للنص، ومقابلة بيانات الطبعة، ومدارسة مع أهل العلم.",
    "step1": "اطرح السؤال",
    "step1Body": "اختر المساعد المختص، ثم بيّن المسألة وسياقها الذي تريد دراسته.",
    "step2": "تتبّع النص الأصلي",
    "step2Body": "تتبّع العبارة العربية في كتب المصادر، واقرأ النص مع سياقه وما يتصل به.",
    "step3": "حدّد موضع النص في الطبعة",
    "step3Body": "يهديك عنوان الكتاب وبيانات الطبعة والجزء والصفحة إلى مقابلة العبارة بالمصدر.",
    "step4": "دارس النص مع أهل العلم",
    "step4Body": "اعرض العبارة ومرجعها على أهل العلم، وتعمّق في معناها وسياقها، وابنِ النتائج بإرشادهم.",
    "verifyLimit": "قد يخطئ الذكاء الاصطناعي. التحقّق عملية مراجعة، ولا يضمن خلوّ كل مخرج من الخطأ.",
    "catalogEyebrow": "حقول المعرفة",
    "available": "متاح في التطبيق",
    "preparing": "قيد الإعداد",
    "preparingBody": "تخضع هذه المجموعة للمراجعة والتنظيم تمهيدًا لإتاحتها. وتُعلن مستجداتها في ملاحظات الإصدار.",
    "archiveEyebrow": "أثر الإحالة",
    "archiveTitle": "نصوص بين يديك.\nوبحث واضح المعالم.",
    "archiveBody": "اقرأ كيف يعرض OpenTurath عبارات الأم مع أرقام الأجزاء والصفحات في أرشيف Q001. قارن الإجابات الأصلية لستة نماذج واطّلع على سجلات مراجعة المصادر.",
    "memberEyebrow": "عضوية المطالعة",
    "chooseMembership": "ابدأ الوصول عبر التطبيق",
    "memberManual": "تجديد يدوي. دون خصم تلقائي.",
    "memberPayment": "DOKU · QRIS · حساب افتراضي · محفظة إلكترونية",
    "memberMethods": "تُعرض تفاصيل الباقة ووسائل الدفع والمبلغ الإجمالي قبل إتمام المعاملة.",
    "memberRefund": "تُراجع طلبات الاسترداد خلال ٧ أيام عمل من اكتمال البيانات. وبعد الموافقة تُعالج خلال ٧ أيام عمل أخرى، وفق مزود الدفع.",
    "memberNotice": "تُفعّل العضوية داخل تطبيق OpenTurath.",
    "featuredPlan": "النطاق الأوسع",
    "adabTitle": "على أصول المصادر.\nوبإرشاد أهل العلم.",
    "adabBody": "نصل الذكاء الاصطناعي بأصول نصوص العلماء لتيسير تتبّع العبارات مع حفظ مكانة إرشاد المعلم. نصون نسبة النقول، ونحترم الخلاف العلمي، ونُحيي سنّة التلقّي.",
    "legalVersion": "ملخص سياسات التطبيق · الإصدار 1.0 · ١٣ سبتمبر ٢٠٢٦",
    "legalCanonical": "اقرأ النص الرسمي بالإندونيسية",
    "policySummary": "تلخّص هذه الصفحة سياسة التطبيق الرسمية. وتُبيّن تفاصيل العرض الحالي وأحكام الموقع الخاصة بصورة منفصلة أدناه.",
    "downloadIntegrity": "تُحسب قيمة SHA-256 من ملف APK المرفق بإصدار الموقع هذا.",
    "studySpace": "مجلس المطالعة",
    "referenceBooks": "المراجع المعتمدة",
    "archiveSample": "مقتطف من أرشيف Q001",
    "memberFrom": "ابتداءً من",
    "memberPerMonth": "/ شهر",
    "memberReview": "مراجعة الاسترداد خلال ٧ أيام عمل",
    "faqIntro": "ما يعينك على بدء المطالعة.",
    "navAdab": "آداب الطلب",
    "navDownload": "تنزيل",
    "awaitingArtifact": "ملف الإصدار قيد الإعداد",
    "statsEyebrow": "الخزانة بالأرقام",
    "statsTitle": "ميراث علمي في خزانة واحدة.",
    "statsSource": "مجموع بيانات ٢٠ وحدة في التطبيق · ٢١ ملف مساعد، منها ملف واحد قيد الإعداد.",
    "metricDisciplines": "تخصصات متاحة",
    "metricBooks": "كتب تراثية",
    "metricVolumes": "مجلدات",
    "metricPages": "صفحات",
    "metricWords": "كلمات تراثية",
    "metricPartitions": "أقسام مفهرسة",
    "metaBooks": "كتاب",
    "metaVolumes": "مجلد",
    "metaPages": "صفحة",
    "metaWords": "كلمة",
    "metaLectures": "محاضرة",
    "metaMillion": "مليون",
    "metaBillion": "مليار",
    "collectionMetrics": "بيانات الخزانة",
    "statsEra": "من عصر ما قبل الهجرة إلى العصر الحديث.",
    "paymentVA": "الحساب الافتراضي",
    "paymentWallet": "المحفظة الإلكترونية"
  }
};
export function tr(locale,key) { const value=copy[locale]?.[key]; if(typeof value!=="string") throw new Error(`Missing translation ${locale}:${key}`); return value; }
export const localized=(values,locale)=>values[{id:0,en:1,ar:2}[locale]];
export const faq = [
  {
    "id": "teacher",
    "q": [
      "Apakah OpenTurath menggantikan peran guru atau ulama?",
      "Does OpenTurath replace a teacher or scholar?",
      "هل يحل OpenTurath محلّ المعلم أو العالم؟"
    ],
    "a": [
      "OpenTurath adalah khadimul ’ilmi: asisten riset untuk mempercepat penelusuran ibarah dan rujukan. Pendalaman makna, kesimpulan hukum, dan fatwa tetap bertumpu pada talaqqi serta bimbingan guru yang berkompeten.",
      "OpenTurath is a khadim al-‘ilm: a research assistant for finding passages and references. Deeper understanding, legal conclusions, and fatwas remain grounded in talaqqi and the guidance of qualified teachers.",
      "OpenTurath خادم للعلم: مساعد بحث ييسّر الوصول إلى العبارات والمراجع. أمّا التعمّق في المعاني والاستنباط والفتوى فمبناها على التلقّي وإرشاد أهل العلم المؤهلين."
    ]
  },
  {
    "id": "verification",
    "q": [
      "Bagaimana cara kerja verifikasi teks Arab dan rujukan kitab?",
      "How are Arabic passages and book references verified?",
      "كيف تُراجع النصوص العربية وإحالات الكتب؟"
    ],
    "a": [
      "Penelusuran dimulai dari korpus kitab pada asisten yang Anda pilih. Kutipan Arab, judul kitab, jilid, dan halaman menjadi titik temu dengan naskah sumber. Verifikasi dilengkapi dengan mencocokkan ibarah serta edisi cetakannya, sehingga kutipan dapat ditelaah dalam konteks yang utuh.",
      "Research starts with the book corpus of your chosen assistant. Arabic quotations, titles, volumes, and pages point you back to the source. Verification is completed by matching the passage and its edition, so the quotation can be studied in its full context.",
      "يبدأ البحث من مجموعة مصادر المساعد الذي تختاره. وتدلّك العبارة العربية وعنوان الكتاب والجزء والصفحة على موضع النص. وتكتمل المراجعة بمقابلة العبارة وطبعتها، لقراءة النقل في سياقه التام."
    ]
  },
  {
    "id": "edition",
    "q": [
      "Mengapa halaman rujukan bisa berbeda dengan kitab cetakan saya?",
      "Why might a reference differ from the page in my printed book?",
      "لماذا قد يختلف رقم الصفحة عن نسختي المطبوعة؟"
    ],
    "a": [
      "Tiap penerbit dan edisi dapat memakai tata letak serta pembagian jilid yang berbeda. Cocokkan nama penerbit, tahun cetak, dan nomor jilid terlebih dahulu, lalu telusuri bab atau awal ibarahnya. Nomor halaman cetak juga dapat berbeda dari penghitung halaman PDF.",
      "Publishers and editions can use different layouts and volume divisions. First compare the publisher, publication year, and volume, then find the chapter or opening words of the passage. Printed page numbers may also differ from a PDF viewer’s page counter.",
      "تختلف الطبعات في تنسيق الصفحات وتقسيم المجلدات. قابل اسم الناشر وسنة الطبع والجزء أولًا، ثم تتبّع الباب أو مطلع العبارة. وقد يختلف رقم الصفحة المطبوعة عن عدّاد صفحات PDF."
    ]
  },
  {
    "id": "sources",
    "q": [
      "Kitab apa saja yang menjadi rujukan setiap disiplin?",
      "Which works are used in each discipline?",
      "ما الكتب المعتمدة في كل تخصص؟"
    ],
    "a": [
      "Setiap khadim memiliki cakupan tersendiri. Fikih Syafi’i menelaah antara lain Al-Umm, Minhajuth Thalibin, dan Tuhfatul Muhtaj; hadits menelusuri Kutubus Sittah; ushul fikih mengkaji Al-Mustashfa, Al-Luma’, dan Al-Burhan. Buka kartu khazanah untuk mengenali fokus, cakupan, dan metadata bidangnya.",
      "Each assistant has a distinct scope. Shafi‘i fiqh studies works such as Al-Umm, Minhaj al-Talibin, and Tuhfat al-Muhtaj; hadith searches the Six Books; usul al-fiqh studies Al-Mustasfa, Al-Luma‘, and Al-Burhan. Open a collection card to explore its focus, scope, and metadata.",
      "لكل مساعد نطاق خاص. فمن مصادر الفقه الشافعي الأم ومنهاج الطالبين وتحفة المحتاج، ومن مصادر الحديث الكتب الستة، ومن أصول الفقه المستصفى واللمع والبرهان. افتح بطاقة الخزانة للتعرّف على موضوعها ونطاقها وبياناتها."
    ]
  },
  {
    "id": "payment",
    "q": [
      "Berapa biaya keanggotaan dan bagaimana cara membayarnya?",
      "How much does membership cost, and how do I pay?",
      "ما تكلفة العضوية وكيف أسدّدها؟"
    ],
    "a": [
      "Akses khadim spesialis dimulai dari Rp 49.000 per bulan. Pilih paket dan lakukan aktivasi di aplikasi melalui DOKU. QRIS, Virtual Account, dan E-Wallet tersedia sesuai pilihan pada halaman pembayaran. Perpanjangan dilakukan manual, tanpa auto-debit; total biaya serta masa akses ditampilkan sebelum transaksi.",
      "Specialist access starts at IDR 49,000 per month. Choose a plan and activate it in the app through DOKU. QRIS, Virtual Account, and E-Wallet options depend on the payment screen. Renewal is manual with no automatic debit; the total and access period are shown before payment.",
      "يبدأ الوصول إلى المساعد المختص من ٤٩٬٠٠٠ روبية إندونيسية شهريًّا. اختر الباقة وفعّلها داخل التطبيق عبر DOKU، باستخدام QRIS أو الحساب الافتراضي أو المحفظة الإلكترونية بحسب الخيارات المعروضة. التجديد يدوي دون خصم تلقائي، ويظهر المبلغ ومدة الوصول قبل الدفع."
    ]
  },
  {
    "id": "notes",
    "q": [
      "Di mana catatan telaah saya disimpan?",
      "Where are my study notes stored?",
      "أين تُحفظ ملاحظات المطالعة؟"
    ],
    "a": [
      "Catatan yang Anda simpan melalui fitur Catatan berada secara lokal di perangkat Anda. Gunakan fitur ekspor atau pencadangan yang tersedia sebelum mengganti perangkat atau menghapus data aplikasi. Percakapan pada Google NotebookLM dikelola oleh layanan tersebut dan terpisah dari Catatan lokal.",
      "Notes saved through the Notes feature are stored locally on your device. Use the available export or backup features before changing devices or clearing app data. Google NotebookLM conversations are managed by that service, separately from local Notes.",
      "تُحفظ الملاحظات التي تسجّلها في ميزة الملاحظات محليًّا على جهازك. استخدم خيارات التصدير أو النسخ الاحتياطي المتاحة قبل تغيير الجهاز أو مسح بيانات التطبيق. أمّا محادثات Google NotebookLM فتديرها تلك الخدمة بصورة منفصلة."
    ]
  },
  {
    "id": "availability",
    "q": [
      "Mengapa Khazanah Habib Umar berstatus “Dalam persiapan”?",
      "Why is the Habib Umar collection marked “In preparation”?",
      "لماذا تُعرض خزانة الحبيب عمر بوصفها «قيد الإعداد»؟"
    ],
    "a": [
      "Koleksi karya, dars, dan risalah Al-Habib Umar bin Hafidz sedang dikurasi dan ditata sebelum dibuka. Situs menampilkan 20 disiplin aktif dan satu profil dalam persiapan. Perkembangan koleksi ini diumumkan melalui catatan rilis; aksesnya dibuka setelah tersedia di aplikasi.",
      "The works, lessons, and writings of Al-Habib Umar bin Hafiz are being curated and organised for access. The site presents 20 active disciplines and one profile in preparation. Release notes will announce availability, with access opening when the collection is ready in the app.",
      "تُراجع مؤلفات الحبيب عمر بن حفيظ ودروسه ورسائله وتُنظّم تمهيدًا لإتاحتها. يعرض الموقع ٢٠ تخصصًا متاحًا وملفًا واحدًا قيد الإعداد. تُعلن الإتاحة في ملاحظات الإصدار، ويُفتح الوصول عند جاهزية المجموعة في التطبيق."
    ]
  },
  {
    "id": "platforms",
    "q": [
      "Apakah OpenTurath dapat digunakan selain di Android?",
      "Can I use OpenTurath on a platform other than Android?",
      "هل يمكن استخدام OpenTurath على غير Android؟"
    ],
    "a": [
      "Android adalah platform distribusi APK OpenTurath. Halaman Unduh menampilkan versi, status berkas, dan persyaratan perangkat terbaru. Versi macOS, Windows, dan iOS sedang dipersiapkan; ketersediaannya akan diumumkan melalui saluran resmi.",
      "Android is the platform for OpenTurath APK distribution. Downloads shows the version, file availability, and current device requirements. macOS, Windows, and iOS versions are in preparation; availability will be announced through official channels.",
      "Android هو منصة توزيع APK الخاصة بـ OpenTurath. تُبيّن صفحة التنزيل الإصدار وحالة الملف ومتطلبات الجهاز. إصدارات macOS وWindows وiOS قيد الإعداد، وتُعلن إتاحتها عبر القنوات الرسمية."
    ]
  },
  {
    "id": "refund",
    "q": [
      "Bagaimana mengajukan pengembalian dana?",
      "How can I request a refund?",
      "كيف أطلب استرداد المبلغ؟"
    ],
    "a": [
      "Kirim nomor transaksi, bukti pembayaran, dan uraian kendala ke openturath@gmail.com. Permohonan ditinjau paling lambat 7 hari kerja setelah data lengkap. Jika disetujui, pengembalian diproses paling lambat 7 hari kerja berikutnya, mengikuti bank atau dompet asal. Ketentuan lengkap tersedia pada halaman Pembayaran dan Pengembalian Dana.",
      "Send your transaction number, payment evidence, and a description of the issue to openturath@gmail.com. Requests are reviewed within 7 business days of complete information. Approved refunds are processed within a further 7 business days, subject to the original bank or wallet. See Payments and Refunds for the full terms.",
      "أرسل رقم المعاملة وإثبات الدفع ووصف المشكلة إلى openturath@gmail.com. يُراجع الطلب خلال ٧ أيام عمل من اكتمال البيانات. وبعد الموافقة يُعالج الاسترداد خلال ٧ أيام عمل أخرى وفق البنك أو المحفظة الأصلية. راجع صفحة الدفع والاسترداد للتفاصيل."
    ]
  },
  {
    "id": "account",
    "q": [
      "Apakah percakapan memerlukan akun Google?",
      "Do conversations require a Google account?",
      "هل تتطلب المحادثات حساب Google؟"
    ],
    "a": [
      "Percakapan dengan khadim berlangsung melalui Google NotebookLM. Masuklah dengan akun Google yang memenuhi persyaratan layanan tersebut. Keanggotaan OpenTurath mengatur akses koleksi, sementara batas penggunaan dan pemrosesan percakapan mengikuti ketentuan NotebookLM.",
      "Conversations with assistants take place through Google NotebookLM. Sign in with a Google account that meets its service requirements. OpenTurath membership controls collection access; conversation processing and usage limits follow NotebookLM’s terms.",
      "تجري المحادثات مع المساعدين عبر Google NotebookLM. سجّل الدخول بحساب Google يستوفي متطلبات الخدمة. تنظّم عضوية OpenTurath الوصول إلى المجموعات، وتخضع معالجة المحادثات وحدود استخدامها لشروط NotebookLM."
    ]
  }
];
```

## src/articles.mjs

```javascript
export const articles = {
  "how-it-works": {
    "key": "how",
    "intro": [
      "Dari pertanyaan menuju rujukan.",
      "From question to source.",
      "من السؤال إلى المصدر."
    ],
    "blocks": [
      {
        "heading": [
          "Ajukan pertanyaan",
          "Ask a question",
          "اطرح السؤال"
        ],
        "body": [
          "Pilih khadim sesuai disiplin ilmu, lalu uraikan masalah dan konteks yang ingin Anda dalami.",
          "Choose the assistant for your discipline and describe the question and its context.",
          "اختر المساعد المختص، ثم بيّن المسألة وسياقها الذي تريد دراسته."
        ]
      },
      {
        "heading": [
          "Telusuri teks primer",
          "Locate primary texts",
          "تتبّع النص الأصلي"
        ],
        "body": [
          "Telusuri ibarah Arab dalam kitab rujukan. Baca kutipan beserta pembahasan yang mengitarinya.",
          "Trace the Arabic passage in the reference works. Read the quotation alongside its surrounding discussion.",
          "تتبّع العبارة العربية في كتب المصادر، واقرأ النص مع سياقه وما يتصل به."
        ]
      },
      {
        "heading": [
          "Kenali koordinat cetakan",
          "Locate the printed edition",
          "حدّد موضع النص في الطبعة"
        ],
        "body": [
          "Judul kitab, edisi, jilid, dan halaman menjadi panduan untuk mencocokkan ibarah dengan naskah sumber.",
          "Title, edition, volume, and page guide you to match the passage against its source.",
          "يهديك عنوان الكتاب وبيانات الطبعة والجزء والصفحة إلى مقابلة العبارة بالمصدر."
        ]
      },
      {
        "heading": [
          "Telaah bersama guru",
          "Study with a teacher",
          "دارس النص مع أهل العلم"
        ],
        "body": [
          "Bawa ibarah beserta rujukannya ke majelis ilmu. Perdalam makna, timbang konteks, dan susun kesimpulan dengan bimbingan guru.",
          "Bring the passage and its reference to your teacher. Explore its meaning, weigh the context, and develop your conclusions together.",
          "اعرض العبارة ومرجعها على أهل العلم، وتعمّق في معناها وسياقها، وابنِ النتائج بإرشادهم."
        ]
      },
      {
        "heading": [
          "Mengapa halaman rujukan bisa berbeda dengan kitab cetakan saya?",
          "Why might a reference differ from the page in my printed book?",
          "لماذا قد يختلف رقم الصفحة عن نسختي المطبوعة؟"
        ],
        "body": [
          "Tiap penerbit dan edisi dapat memakai tata letak serta pembagian jilid yang berbeda. Cocokkan nama penerbit, tahun cetak, dan nomor jilid terlebih dahulu, lalu telusuri bab atau awal ibarahnya. Nomor halaman cetak juga dapat berbeda dari penghitung halaman PDF.",
          "Publishers and editions can use different layouts and volume divisions. First compare the publisher, publication year, and volume, then find the chapter or opening words of the passage. Printed page numbers may also differ from a PDF viewer’s page counter.",
          "تختلف الطبعات في تنسيق الصفحات وتقسيم المجلدات. قابل اسم الناشر وسنة الطبع والجزء أولًا، ثم تتبّع الباب أو مطلع العبارة. وقد يختلف رقم الصفحة المطبوعة عن عدّاد صفحات PDF."
        ]
      },
      {
        "heading": [
          "Mendokumentasikan hasil telaah",
          "Documenting your review",
          "توثيق نتائج المطالعة"
        ],
        "body": [
          "Catat teks, edisi, penelaah, dan tanggal pencocokan sebelum menandai rujukan sebagai terverifikasi. Jejak pemeriksaan inilah yang membuat hasil telaah dapat ditelusuri ulang.",
          "Record the text, edition, reviewer, and review date before marking a reference as verified. This record makes your findings reproducible.",
          "دوّن النص والطبعة واسم المراجع وتاريخ المقابلة قبل إثبات التحقّق من الإحالة. بهذا السجل يمكن إعادة تتبّع نتائج البحث."
        ]
      }
    ]
  },
  "about": {
    "key": "about",
    "intro": [
      "Ilmu lebih dekat. Adab tetap dijaga.",
      "Knowledge within reach. Adab preserved.",
      "العلم أقرب. والأدب محفوظ."
    ],
    "blocks": [
      {
        "heading": [
          "Ruang telaah turats",
          "A space for turath study",
          "مساحة لمطالعة التراث"
        ],
        "body": [
          "OpenTurath membantu penelusuran literatur Islam, pembacaan ibarah, dan penyimpanan Catatan lokal. AI membantu persiapan belajar, sedangkan pemahaman mendalam tetap membutuhkan guru dan sumber asli.",
          "OpenTurath supports Islamic literature research, close reading, and local Notes. AI assists study preparation, while deeper understanding still requires teachers and original sources.",
          "يعين OpenTurath على البحث في الكتب الإسلامية وقراءة العبارات وحفظ الملاحظات محليًا. ويساعد الذكاء الاصطناعي في الإعداد للدراسة مع بقاء الحاجة إلى أهل العلم والمصادر الأصلية."
        ]
      },
      {
        "heading": [
          "Katalog dan ketersediaan",
          "Catalogue and availability",
          "الفهرس والإتاحة"
        ],
        "body": [
          "Dua puluh disiplin keilmuan, dari fikih mazhab hingga tahqiq naskah. Temukan khadim yang memahami bidang telaah Anda. Akumulasi metadata 20 modul aplikasi · 21 profil khadim, termasuk 1 dalam persiapan.",
          "Twenty scholarly disciplines, from the schools of fiqh to manuscript study. Find an assistant dedicated to your field. Combined metadata from 20 app modules · 21 assistant profiles, including 1 in preparation.",
          "عشرون تخصصًا علميًّا، من فقه المذاهب إلى تحقيق النصوص. اختر المساعد المختص بمجال بحثك. مجموع بيانات ٢٠ وحدة في التطبيق · ٢١ ملف مساعد، منها ملف واحد قيد الإعداد."
        ]
      },
      {
        "heading": [
          "Pengelola dan bantuan",
          "Operator and support",
          "الجهة المشغلة والدعم"
        ],
        "body": [
          "Pengelola OpenTurath, Indonesia. Kontak resmi openturath@gmail.com. Jam layanan Senin sampai Jumat, 09.00 sampai 17.00 WIB. Tanggapan awal diupayakan dalam 2 hari kerja.",
          "Pengelola OpenTurath, Indonesia. Official contact: openturath@gmail.com. Service hours are Monday to Friday, 09:00 to 17:00 WIB (UTC+7). Initial support response is targeted within 2 business days.",
          "الجهة المشغلة: Pengelola OpenTurath، إندونيسيا. التواصل: openturath@gmail.com. ساعات الخدمة من الاثنين إلى الجمعة، من ٠٩:٠٠ إلى ١٧:٠٠ بتوقيت جاكرتا (UTC+7). الرد الأولي خلال يومي عمل."
        ]
      }
    ]
  },
  "terms": {
    "key": "terms",
    "intro": [
      "Ketentuan Layanan",
      "Terms of Service",
      "شروط الخدمة"
    ],
    "blocks": [
      {
        "heading": [
          "Pengelola, persetujuan, dan akun",
          "Operator, consent, and accounts",
          "الجهة المشغلة والموافقة والحسابات"
        ],
        "body": [
          "Layanan dikelola Pengelola OpenTurath di Indonesia. Pendaftaran mandiri untuk pengguna berusia 18 tahun ke atas yang berwenang membuat perjanjian. Akun bersifat pribadi. Pembelian individu tidak otomatis memberikan hak akses lembaga.",
          "The service is operated by Pengelola OpenTurath in Indonesia. Self-registration is for people aged 18 or older who can enter an agreement. Accounts are personal. Individual purchases do not automatically grant institutional access.",
          "تدير الخدمة Pengelola OpenTurath في إندونيسيا. التسجيل الذاتي لمن بلغ ١٨ عامًا وكان مؤهلًا للتعاقد. الحساب شخصي، ولا يمنح الشراء الفردي وصولًا مؤسسيًا تلقائيًا."
        ]
      },
      {
        "heading": [
          "Fungsi layanan dan hak pengguna",
          "Service purpose and user rights",
          "وظيفة الخدمة وحقوق المستخدم"
        ],
        "body": [
          "AI membantu penelusuran, bukan fatwa resmi atau pengganti guru. Periksa teks, atribusi, terjemahan, dan edisi sebelum menggunakannya. Keterbatasan AI tidak menghapus tanggung jawab pengelola atau hak konsumen yang dilindungi hukum.",
          "AI assists research and is not an official fatwa or a replacement for teachers. Check text, attribution, translation, and edition before using it. AI limitations do not remove the operator’s responsibilities or legally protected consumer rights.",
          "يساعد الذكاء الاصطناعي في البحث، وليس فتوى رسمية ولا بديلًا عن المعلم. راجع النص والنسبة والترجمة والطبعة قبل الاستعمال. ولا تُسقط حدود التقنية مسؤولية المشغّل أو حقوق المستهلك المحمية قانونًا."
        ]
      },
      {
        "heading": [
          "Paket dan pihak ketiga",
          "Plans and third parties",
          "الباقات والجهات الخارجية"
        ],
        "body": [
          "Harga total, cakupan, batas penggunaan, dan tanggal akhir akses perlu dibaca sebelum pembayaran. Perpanjangan manual tanpa auto-debit. DOKU memproses pembayaran. Percakapan memakai Google NotebookLM dengan ketentuannya sendiri. Pembelian OpenTurath tidak menaikkan paket Google Anda.",
          "Read the total price, scope, usage limits, and expiry before payment. Renewal is manual with no automatic debit. DOKU processes payments. Conversations use Google NotebookLM under its own terms. Buying OpenTurath does not upgrade your Google plan.",
          "اقرأ السعر الإجمالي والنطاق وحدود الاستخدام وانتهاء الوصول قبل الدفع. التجديد يدوي دون خصم تلقائي. تعالج DOKU المدفوعات، وتستخدم المحادثات Google NotebookLM بشروطه. لا يرقّي شراء OpenTurath باقة Google."
        ]
      },
      {
        "heading": [
          "Penggunaan dan hak cipta",
          "Use and copyright",
          "الاستخدام وحقوق النشر"
        ],
        "body": [
          "Dilarang mengambil alih akun, menghindari kontrol akses, menjual kembali akses tanpa izin, atau memalsukan kutipan. Hak atas Catatan tetap milik penulisnya. Catatan disimpan lokal. Hak kitab, tahkik, dan terjemahan mengikuti pemegang hak masing-masing.",
          "Account takeover, bypassing access controls, unauthorized resale, and fabricated quotations are prohibited. Authors retain rights to their Notes, which are stored locally. Books, edited editions, and translations retain their respective rights.",
          "يُحظر الاستيلاء على الحسابات وتجاوز ضوابط الوصول وإعادة البيع دون إذن وتزوير النقول. تبقى حقوق الملاحظات لأصحابها وتُحفظ محليًا. وتتبع الكتب والتحقيقات والترجمات حقوق أصحابها."
        ]
      },
      {
        "heading": [
          "Perubahan, pembatasan, dan pemulihan",
          "Changes, restrictions, and remedies",
          "التغييرات والقيود والمعالجة"
        ],
        "body": [
          "Pemeliharaan dapat memengaruhi layanan. Pengurangan manfaat berbayar yang material memerlukan penyelesaian yang wajar. Pembatasan akun harus proporsional dengan masalah. Jika memungkinkan, alasan dan kesempatan klarifikasi diberikan. Perubahan kebijakan tidak menghapus hak pembelian yang telah timbul.",
          "Maintenance may affect service. Material reductions in paid benefits require a reasonable remedy. Account restrictions should be proportionate, with reasons and an opportunity to clarify where possible. Policy changes do not remove accrued purchase rights.",
          "قد تؤثر الصيانة في الخدمة. ويستلزم النقص الجوهري في المنافع المدفوعة معالجة معقولة. تكون قيود الحساب متناسبة، مع بيان الأسباب وإتاحة التوضيح متى أمكن. ولا تُسقط التغييرات الحقوق الناشئة عن الشراء."
        ]
      },
      {
        "heading": [
          "Pengaduan dan hukum yang berlaku",
          "Complaints and governing law",
          "الشكاوى والقانون المطبق"
        ],
        "body": [
          "Hubungi openturath@gmail.com untuk pengaduan dan klarifikasi. Perkembangan awal penanganan disampaikan dalam 2 hari kerja sesuai naskah resmi. Ketentuan aplikasi tunduk pada hukum Republik Indonesia.",
          "Contact openturath@gmail.com for complaints and clarification. An initial handling update is provided within 2 business days under the official policy. The app terms are governed by Indonesian law.",
          "تواصل عبر openturath@gmail.com للشكاوى والتوضيح. يُقدّم تحديث أولي خلال يومي عمل وفق السياسة الرسمية. تخضع شروط التطبيق لقانون جمهورية إندونيسيا."
        ]
      }
    ],
    "policy": true
  },
  "privacy": {
    "key": "privacy",
    "intro": [
      "Kebijakan Privasi",
      "Privacy Policy",
      "سياسة الخصوصية"
    ],
    "blocks": [
      {
        "heading": [
          "Data aplikasi dan tujuannya",
          "App data and purposes",
          "بيانات التطبيق وأغراضها"
        ],
        "body": [
          "Aplikasi memproses identitas Google, status akses, data transaksi DOKU, kontak transaksi, sesi percakapan, serta data bantuan sesuai fitur yang dipakai. Data diperlukan untuk autentikasi, penyediaan layanan, pembayaran, dan kewajiban pencatatan. Pengelola menyatakan tidak menjual data pribadi atau menggunakan percakapan untuk iklan bertarget.",
          "The app processes Google identity, access status, DOKU transaction data, transaction contacts, conversation sessions, and support data as needed by each feature. Purposes include authentication, service delivery, payment, and required records. The operator states that personal data is not sold and conversations are not used for targeted advertising.",
          "يعالج التطبيق هوية Google وحالة الوصول وبيانات معاملات DOKU وجهات اتصال المعاملات والمحادثات والدعم بحسب الميزة. تشمل الأغراض المصادقة وتقديم الخدمة والدفع والسجلات المطلوبة. ويصرّح المشغّل بعدم بيع البيانات أو استخدام المحادثات للإعلانات الموجّهة."
        ]
      },
      {
        "heading": [
          "Catatan lokal dan layanan eksternal",
          "Local Notes and external services",
          "الملاحظات المحلية والخدمات الخارجية"
        ],
        "body": [
          "Catatan disimpan pada perangkat dan dapat hilang saat data aplikasi dihapus. Cadangkan melalui salin atau bagikan. Google menangani autentikasi dan NotebookLM, DOKU menangani pembayaran, dan Firebase/Google Cloud menangani data transaksi serta akses. Pemrosesan penyedia dapat berlangsung lintas negara.",
          "Notes are stored on your device and may be lost when app data is deleted. Back up using copy or share. Google handles authentication and NotebookLM, DOKU handles payments, and Firebase/Google Cloud handles transaction and access data. Provider processing may cross borders.",
          "تُحفظ الملاحظات على جهازك وقد تُفقد عند حذف بيانات التطبيق. انسخها أو شاركها للاحتفاظ بها. تتولى Google المصادقة وNotebookLM، وDOKU الدفع، وFirebase/Google Cloud بيانات المعاملات والوصول. قد تجري معالجة المزوّدين عبر الحدود."
        ]
      },
      {
        "heading": [
          "Data pada website",
          "Data on this website",
          "البيانات في هذا الموقع"
        ],
        "body": [
          "Website menyimpan pilihan bahasa, tema, dan ukuran baca di localStorage. Tidak ada analitik eksternal yang diaktifkan. Formulir menyimpan topik, email opsional, isi pesan, persetujuan, bahasa, halaman, ID permintaan, dan waktu laporan. Hindari mengirim kata sandi, OTP, data kartu, atau data sensitif.",
          "The website stores language, theme, and reading-size preferences in localStorage. No external analytics are enabled. The form stores topic, optional email, message, consent, language, page, request ID, and report time. Do not submit passwords, OTPs, card data, or sensitive information.",
          "يحفظ الموقع تفضيلات اللغة والمظهر وحجم القراءة في localStorage. لا تحليلات خارجية مفعّلة. يحفظ النموذج الموضوع والبريد الاختياري والرسالة والموافقة واللغة والصفحة ومعرّف الطلب ووقته. لا ترسل كلمات المرور أو رموز التحقّق أو بيانات البطاقات أو المعلومات الحساسة."
        ]
      },
      {
        "heading": [
          "Retensi dan penghapusan",
          "Retention and deletion",
          "الاحتفاظ والحذف"
        ],
        "body": [
          "Data akun mengikuti masa aktif dan permohonan penghapusan. Catatan lokal berada dalam kendali perangkat Anda. Transaksi dapat dipertahankan untuk kewajiban hukum. Laporan website dijadwalkan untuk dihapus setelah 30 hari. Cadangan dan log infrastruktur mengikuti pengaturan operasional pengelola.",
          "Account data follows account lifetime and deletion requests. Local Notes remain under your device’s control. Transactions may be retained for legal obligations. Website reports are scheduled for deletion after 30 days. Backups and infrastructure logs follow the operator’s operational settings.",
          "ترتبط بيانات الحساب بمدة نشاطه وطلبات الحذف. وتبقى الملاحظات المحلية تحت تحكم جهازك. قد تُحفظ المعاملات للالتزامات القانونية. يُجدول حذف بلاغات الموقع بعد ٣٠ يومًا، وتتبع النسخ الاحتياطية وسجلات البنية إعدادات المشغّل."
        ]
      },
      {
        "heading": [
          "Hak privasi dan pengguna di bawah umur",
          "Privacy rights and minors",
          "حقوق الخصوصية والقاصرون"
        ],
        "body": [
          "Ajukan akses, koreksi, atau penghapusan data melalui openturath@gmail.com. Pendaftaran mandiri dibatasi untuk usia 18 tahun ke atas. Hubungi pengelola jika ditemukan akun anak yang tidak memenuhi ketentuan. Naskah resmi menjelaskan ruang lingkup dan tanggung jawab data aplikasi.",
          "Request access, correction, or deletion through openturath@gmail.com. Self-registration is restricted to ages 18 and above. Contact the operator about an ineligible child account. The official policy explains the scope and responsibilities for app data.",
          "اطلب الاطلاع أو التصحيح أو الحذف عبر openturath@gmail.com. التسجيل الذاتي لمن بلغ ١٨ عامًا. تواصل مع المشغّل عند العثور على حساب طفل غير مستوفٍ للشروط. توضح السياسة الرسمية نطاق بيانات التطبيق والمسؤوليات."
        ]
      }
    ],
    "policy": true
  },
  "billing": {
    "key": "billing",
    "intro": [
      "Pembayaran dan Pengembalian Dana",
      "Payments and Refunds",
      "الدفع والاسترداد"
    ],
    "blocks": [
      {
        "heading": [
          "Penawaran dan durasi",
          "Offers and duration",
          "العروض والمدة"
        ],
        "body": [
          "Akses khadim spesialis dimulai dari Rp 49.000 per bulan. Pilih khadim spesialis disiplin ilmu yang ingin Anda telaah. Akses dan aktivasi diproses resmi di aplikasi melalui DOKU, tanpa perpanjangan otomatis. Rincian paket, metode pembayaran, dan total biaya ditampilkan sebelum transaksi.",
          "Specialist access starts at IDR 49,000 per month. Choose a specialist assistant for the discipline you wish to study. Access and activation are handled in the app through DOKU, with manual renewal. Plan details, payment methods, and the total are shown before you pay.",
          "يبدأ الوصول إلى المساعد المختص من ٤٩٬٠٠٠ روبية إندونيسية شهريًّا. اختر المساعد المختص بالعلم الذي تريد دراسته. يُفعّل الوصول رسميًّا داخل التطبيق عبر DOKU، مع تجديد يدوي. تُعرض تفاصيل الباقة ووسائل الدفع والمبلغ الإجمالي قبل إتمام المعاملة."
        ]
      },
      {
        "heading": [
          "DOKU dan aktivasi",
          "DOKU and activation",
          "DOKU والتفعيل"
        ],
        "body": [
          "Pembayaran memakai DOKU melalui QRIS, Virtual Account, atau E-Wallet yang tersedia pada checkout. Status dibayar dan status akses aktif perlu dikonfirmasi terpisah. Jika dana terpotong tetapi akses belum aktif, hubungi bantuan dengan nomor transaksi sebelum membayar ulang.",
          "Payments use available DOKU methods such as QRIS, Virtual Account, or E-Wallet. Payment status and active access must be confirmed separately. If funds are deducted but access is inactive, contact support with the transaction number before paying again.",
          "تتم المدفوعات عبر وسائل DOKU المتاحة مثل QRIS والحساب الافتراضي والمحفظة الإلكترونية. تُراجع حالة الدفع وتفعيل الوصول كلٌّ على حدة. إذا خُصم المبلغ دون تفعيل، تواصل مع الدعم برقم المعاملة قبل إعادة الدفع."
        ]
      },
      {
        "heading": [
          "Perpanjangan dan voucher",
          "Renewal and vouchers",
          "التجديد والقسائم"
        ],
        "body": [
          "Semua perpanjangan dilakukan manual tanpa auto-debit. Akses berakhir sesuai tanggal pada akun. Voucher mengikuti cakupan, masa berlaku, dan batas penukaran yang diterbitkan. Voucher tidak dapat diuangkan.",
          "All renewals are manual with no automatic debit. Access expires on the date shown in your account. Vouchers follow their published scope, validity, and redemption limits. Vouchers cannot be exchanged for cash.",
          "كل تجديد يدوي دون خصم تلقائي. ينتهي الوصول في التاريخ المبيّن في الحساب. تتبع القسائم نطاقها وصلاحيتها وحدود استخدامها المنشورة، ولا تُستبدل نقدًا."
        ]
      },
      {
        "heading": [
          "Dasar refund",
          "Grounds for a refund",
          "أسباب الاسترداد"
        ],
        "body": [
          "Pengembalian dana dapat diminta untuk pembayaran ganda, akses yang tidak aktif setelah verifikasi, atau gangguan inti berbayar berkepanjangan yang tidak dapat dipulihkan. Penyelesaian dapat berupa pemulihan, penyesuaian masa akses dengan persetujuan Anda, atau pengembalian dana penuh.",
          "A refund can be requested for duplicate payment, access not activated after verification, or prolonged unrecoverable failure of a core paid service. Remedies may include restored access, an agreed extension, or a full refund.",
          "يمكن طلب الاسترداد للدفع المكرر أو عدم التفعيل بعد التحقّق أو عطل طويل غير قابل للإصلاح في خدمة مدفوعة أساسية. وقد تكون المعالجة باستعادة الوصول أو تمديد متفق عليه أو استرداد كامل."
        ]
      },
      {
        "heading": [
          "Prosedur dan SLA",
          "Process and service targets",
          "الإجراء ومواعيد المعالجة"
        ],
        "body": [
          "Kirim email akun, nomor transaksi, bukti bayar, dan penjelasan kendala ke openturath@gmail.com. Konfirmasi penerimaan paling lambat 2 hari kerja. Pemeriksaan dan keputusan paling lambat 7 hari kerja setelah informasi lengkap. Jika disetujui, pemrosesan pengembalian dana paling lambat 7 hari kerja berikutnya mengikuti bank atau dompet asal.",
          "Send your account email, transaction number, payment evidence, and issue description to openturath@gmail.com. Receipt is acknowledged within 2 business days. Review and decision take up to 7 business days after complete information. Approved refunds are processed within a further 7 business days subject to the original bank or wallet.",
          "أرسل بريد الحساب ورقم المعاملة وإثبات الدفع ووصف المشكلة إلى openturath@gmail.com. يُؤكّد الاستلام خلال يومي عمل، وتتم المراجعة والقرار خلال ٧ أيام عمل بعد اكتمال البيانات. ثم يُعالج الاسترداد الموافق عليه خلال ٧ أيام عمل أخرى وفق البنك أو المحفظة الأصلية."
        ]
      }
    ],
    "policy": true
  },
  "ai-guidelines": {
    "key": "aiGuidelines",
    "intro": [
      "Adab penggunaan AI dan rujukan.",
      "Adab for AI use and references.",
      "أدب استخدام الذكاء الاصطناعي والمراجع."
    ],
    "blocks": [
      {
        "heading": [
          "Peran alat bantu",
          "The role of a study aid",
          "دور الأداة المساعدة"
        ],
        "body": [
          "Gunakan AI untuk memperluas bacaan dan menyiapkan pertanyaan kepada guru. Kalimat yang meyakinkan atau nomor halaman tidak membuktikan kebenaran jawaban.",
          "Use AI to broaden your reading and prepare questions for a teacher. Confident wording or a page number does not establish an answer’s accuracy.",
          "استخدم الذكاء الاصطناعي لتوسيع القراءة وإعداد أسئلة للمعلم. لا تثبت العبارة الواثقة أو رقم الصفحة صحة الإجابة."
        ]
      },
      {
        "heading": [
          "Kutipan dan konteks",
          "Quotation and context",
          "النقل والسياق"
        ],
        "body": [
          "Baca sebelum dan sesudah ibarah. Cocokkan syarat, pengecualian, edisi, jilid, dan halaman. Bedakan naskah asli, terjemahan, dan sintesis AI.",
          "Read before and after the passage. Check conditions, exceptions, edition, volume, and page. Distinguish original text, translation, and AI synthesis.",
          "اقرأ ما قبل العبارة وما بعدها. راجع الشروط والاستثناءات والطبعة والجزء والصفحة. ميّز الأصل والترجمة وتلخيص الذكاء الاصطناعي."
        ]
      },
      {
        "heading": [
          "Ikhtilaf dan bimbingan",
          "Scholarly difference and guidance",
          "الخلاف العلمي والتوجيه"
        ],
        "body": [
          "Hormati perbedaan mazhab. Istilah mu’tamad, sanad, dan derajat hadis memiliki metodologi khusus. Penetapan hukum dan pemahaman mendalam memerlukan ulama yang berkompeten.",
          "Respect differences between schools. Terms such as muʿtamad, isnad, and hadith grading have specific methodologies. Legal conclusions and deep understanding require qualified scholars.",
          "احترم اختلاف المذاهب. لمصطلحات المعتمد والإسناد ودرجات الحديث مناهج خاصة. وتحتاج الأحكام والفهم العميق إلى أهل العلم المؤهلين."
        ]
      },
      {
        "heading": [
          "Atribusi dan koreksi",
          "Attribution and correction",
          "النسبة والتصحيح"
        ],
        "body": [
          "Cantumkan hanya sumber yang benar-benar diperiksa. Jangan mengesankan telah membaca kitab utuh jika hanya membaca ringkasan. Laporkan kesalahan dengan pertanyaan, judul kitab, edisi, kutipan, dan usulan koreksi.",
          "Cite only sources you have actually checked. Do not imply you read an entire book if you only read a summary. Report errors with the question, title, edition, passage, and proposed correction.",
          "لا تنسب التحقّق إلا إلى مصادر راجعتها فعلًا. ولا توهم بقراءة كتاب كامل عند الاكتفاء بملخص. أبلغ عن الخطأ مع السؤال والعنوان والطبعة والنص والتصحيح المقترح."
        ]
      }
    ],
    "policy": true
  },
  "tahawwulat": {
    "key": "tahawwulat",
    "intro": [
      "Fikih Tahawwulat. Lima ruang telaah.",
      "Fiqh Tahawwulat. Five study spaces.",
      "فقه التحولات. خمس مساحات للدراسة."
    ],
    "blocks": [
      {
        "heading": [
          "Al-Muhaqqiq dan Al-Bayan",
          "Al-Muhaqqiq and Al-Bayan",
          "المحقق والبيان"
        ],
        "body": [
          "Al-Muhaqqiq membantu telaah matan dan ibarah. Al-Bayan membantu penyederhanaan konsep dan istilah. Tetap cocokkan penjelasan dengan sumber dan pengajaran guru.",
          "Al-Muhaqqiq supports close reading of texts and passages. Al-Bayan supports explanations of concepts and terms. Check both against sources and a teacher’s instruction.",
          "يساعد المحقق في مطالعة المتون والعبارات، والبيان في شرح المفاهيم والمصطلحات. قابل الشرح بالمصادر وتعليم أهل العلم."
        ]
      },
      {
        "heading": [
          "Al-Mukhtabir",
          "Al-Mukhtabir",
          "المختبر"
        ],
        "body": [
          "Latihan pemahaman untuk meninjau kembali materi yang dipelajari. Hasil latihan bukan sertifikasi keilmuan.",
          "Comprehension exercises to revisit what you have studied. Exercise results are not scholarly certification.",
          "تدريبات للفهم ومراجعة ما دُرس. لا تُعد نتائجها شهادة علمية."
        ]
      },
      {
        "heading": [
          "Al-Habib dan Al-Khatib",
          "Al-Habib and Al-Khatib",
          "الحبيب والخطيب"
        ],
        "body": [
          "Al-Habib menelaah arsip muhadharah Habib Abu Bakar Al-Masyhur. Al-Khatib membantu penyusunan bahan dakwah dan khutbah. Asisten bukan percakapan langsung dengan tokoh yang namanya disebut.",
          "Al-Habib studies the lecture archive of Habib Abu Bakar Al-Masyhur. Al-Khatib helps prepare teaching and sermon material. An assistant is not a live conversation with the named scholar.",
          "يتناول الحبيب أرشيف محاضرات الحبيب أبي بكر المشهور، ويساعد الخطيب في إعداد مواد الدعوة والخطب. والمساعد ليس محادثة مباشرة مع العالم المذكور."
        ]
      }
    ]
  },
  "research/methodology": {
    "key": "methods",
    "intro": [
      "Bukti yang dapat ditelaah.",
      "Evidence open to examination.",
      "أدلة قابلة للمراجعة."
    ],
    "blocks": [
      {
        "heading": [
          "Arsip terbatas",
          "A limited archive",
          "أرشيف محدود"
        ],
        "body": [
          "Q001 menyimpan satu pertanyaan dan enam jawaban asli. Tanggal uji, versi model, paket, dan kondisi lengkap tidak tercatat. Arsip ini tidak membuktikan keunggulan menyeluruh suatu layanan.",
          "Q001 preserves one question and six original answers. Test date, model versions, plans, and full conditions were not recorded. This archive does not prove a service’s overall superiority.",
          "يحفظ Q001 سؤالًا واحدًا وست إجابات أصلية. لم تُسجّل تواريخ الاختبار وإصدارات النماذج والباقات والظروف الكاملة. لا يثبت الأرشيف تفوق خدمة بصورة عامة."
        ]
      },
      {
        "heading": [
          "Status sepuluh kutipan",
          "Status of ten quotations",
          "حالة النقول العشرة"
        ],
        "body": [
          "Sepuluh kutipan memiliki status belum ditelaah. Teks pembanding edisi, nomor halaman cetak, penelaah, dan tanggal verifikasi belum tersedia. Hash arsip menjaga integritas teks tersimpan, bukan membuktikan kebenarannya.",
          "Ten quotations remain not reviewed. Edition comparison text, verified print pages, reviewer, and verification date are not available. Archive hashes protect saved-text integrity, not factual accuracy.",
          "النقول العشرة لم تُراجع بعد. ولا تتوفر نصوص المقابلة والصفحات المحققة والمراجع وتاريخ التحقّق. تحمي البصمات سلامة النص المحفوظ ولا تثبت صحته العلمية."
        ]
      },
      {
        "heading": [
          "Koreksi yang terdokumentasi",
          "Documented corrections",
          "التصحيحات الموثقة"
        ],
        "body": [
          "Koreksi perlu menyertakan sumber edisi dan alasan perubahan. Teks jawaban asli dipertahankan agar riwayat dapat diperiksa. Gunakan formulir laporan untuk mengirim temuan.",
          "Corrections need an edition source and a reason for the change. Original answers are preserved for an inspectable history. Use the report form to submit findings.",
          "يلزم للتصحيح مصدر الطبعة وسبب التغيير. تُحفظ الإجابات الأصلية لإتاحة مراجعة التاريخ. أرسل الملاحظات عبر نموذج البلاغ."
        ]
      }
    ]
  },
  "help/install": {
    "key": "help",
    "intro": [
      "Memasang aplikasi.",
      "Install the app.",
      "تثبيت التطبيق."
    ],
    "blocks": [
      {
        "heading": [
          "Saluran resmi",
          "Official channels",
          "القنوات الرسمية"
        ],
        "body": [
          "Buka halaman Unduh aplikasi dan pilih platform yang tersedia. Platform dalam persiapan belum memiliki tombol unduh aktif. Persyaratan versi tercantum pada tiap kartu.",
          "Open Downloads and choose an available platform. Platforms in preparation have no active download button. Version requirements are listed on each card.",
          "افتح صفحة التنزيل واختر منصة متاحة. لا يوجد زر تنزيل نشط للمنصات قيد الإعداد. تُعرض متطلبات الإصدار في كل بطاقة."
        ]
      },
      {
        "heading": [
          "Integritas berkas",
          "File integrity",
          "سلامة الملف"
        ],
        "body": [
          "Cocokkan SHA-256 berkas Android dengan nilai pada halaman unduhan. Jangan menonaktifkan perlindungan perangkat secara menyeluruh. Hubungi bantuan jika berkas tidak tersedia atau tanda tangan pemasangan berbeda.",
          "Compare the Android file’s SHA-256 with the download page. Do not disable device protection globally. Contact support if the file is unavailable or its installation signature differs.",
          "قارن SHA-256 لملف Android بالقيمة المنشورة. لا تعطّل حماية الجهاز بصورة شاملة. تواصل مع الدعم إذا تعذر الملف أو اختلف توقيع التثبيت."
        ]
      }
    ]
  },
  "help/references": {
    "key": "help",
    "intro": [
      "Memeriksa rujukan.",
      "Check a reference.",
      "فحص الإحالة."
    ],
    "blocks": [
      {
        "heading": [
          "02 · Teks primer",
          "02 · Primary text",
          "٠٢ · النص الأصلي"
        ],
        "body": [
          "Telusuri ibarah dalam korpus rujukan. Bedakan kutipan asli, terjemahan, dan penjelasan AI. Tidak ditemukannya teks bukan bukti bahwa pembahasannya tidak ada.",
          "Find passages in the reference corpus. Distinguish original quotations, translations, and AI explanations. A missing search result does not prove that a discussion does not exist.",
          "تتبّع العبارة في المصادر. ميّز النص الأصلي والترجمة وشرح الذكاء الاصطناعي. عدم العثور على نص لا يثبت عدم وجود المسألة."
        ]
      },
      {
        "heading": [
          "03 · Koordinat edisi",
          "03 · Edition coordinates",
          "٠٣ · بيانات الطبعة"
        ],
        "body": [
          "Cocokkan judul, pengarang, penerbit, edisi, jilid, dan halaman cetak. Nomor halaman PDF dapat berbeda. Jangan menganggap koordinat yang disebut AI telah dicocokkan dengan naskah fisik.",
          "Match title, author, publisher, edition, volume, and printed page. PDF pagination may differ. Coordinates supplied by AI do not by themselves prove a match to a physical edition.",
          "قابل العنوان والمؤلف والناشر والطبعة والجزء والصفحة المطبوعة. قد يختلف ترقيم PDF. ذكر الإحداثيات لا يثبت مقابلتها بالنسخة المادية."
        ]
      },
      {
        "heading": [
          "04 · Pemeriksaan sebelum kesimpulan",
          "04 · Review before concluding",
          "٠٤ · المراجعة قبل الاستنتاج"
        ],
        "body": [
          "Baca konteks dan minta bimbingan guru. Tandai rujukan sebagai telah dicocokkan hanya setelah teks sumber, edisi, penelaah, dan tanggal pemeriksaan tercatat. Sistem ini tidak menjanjikan nol halusinasi.",
          "Read the context and seek a teacher’s guidance. Mark a reference as matched only after recording the source text, edition, reviewer, and review date. This system does not promise zero hallucinations.",
          "اقرأ السياق واستعن بأهل العلم. لا تُثبت المقابلة إلا بعد توثيق النص والطبعة والمراجع وتاريخ المراجعة. لا يضمن النظام انعدام الأخطاء."
        ]
      }
    ]
  },
  "help/account": {
    "key": "help",
    "intro": [
      "Akun dan Catatan.",
      "Accounts and Notes.",
      "الحسابات والملاحظات."
    ],
    "blocks": [
      {
        "heading": [
          "Akses akun",
          "Account access",
          "الوصول إلى الحساب"
        ],
        "body": [
          "Gunakan akun Google yang sama dengan akun pembelian. Jangan membagikan kode masuk. Jika akses tidak sesuai, sertakan nomor transaksi saat menghubungi bantuan.",
          "Use the same Google account used for purchase. Do not share sign-in codes. If access is incorrect, include your transaction number when contacting support.",
          "استخدم حساب Google نفسه المستخدم للشراء. لا تشارك رموز الدخول. إذا اختلف الوصول، أرفق رقم المعاملة عند التواصل مع الدعم."
        ]
      },
      {
        "heading": [
          "Cadangkan Catatan",
          "Back up Notes",
          "نسخ الملاحظات احتياطيًا"
        ],
        "body": [
          "Catatan disimpan lokal, bukan sinkronisasi cloud lintas perangkat. Salin atau bagikan materi penting sebelum menghapus data atau mencopot aplikasi.",
          "Notes are stored locally, not synchronized through the cloud across devices. Copy or share important material before clearing data or uninstalling.",
          "تُحفظ الملاحظات محليًا ولا تتزامن سحابيًا بين الأجهزة. انسخ المواد المهمة أو شاركها قبل حذف البيانات أو إزالة التطبيق."
        ]
      }
    ]
  },
  "help/access": {
    "key": "help",
    "intro": [
      "Mengelola keanggotaan.",
      "Manage membership.",
      "إدارة العضوية."
    ],
    "blocks": [
      {
        "heading": [
          "Penawaran dan durasi",
          "Offers and duration",
          "العروض والمدة"
        ],
        "body": [
          "Penawaran website terbaru adalah Tholib Rp49.000 untuk 1 bulan, Tematik Rp149.000 untuk 3 bulan, dan Sultan All-Access Rp499.000 untuk 1 tahun. Pastikan cakupan, durasi kalender, jumlah akhir, dan tanggal berakhir yang sama ditampilkan pada aplikasi sebelum membayar. Jangan melanjutkan jika penawarannya berbeda.",
          "Current website offers are Tholib at IDR49,000 for 1 month, Thematic at IDR149,000 for 3 months, and Sultan All-Access at IDR499,000 for 1 year. Confirm the same scope, calendar duration, final total, and expiry in the app before paying. Do not proceed if the offer differs.",
          "عروض الموقع الحالية: الطالب بسعر ٤٩٬٠٠٠ روبية لشهر، والموضوعية بسعر ١٤٩٬٠٠٠ لثلاثة أشهر، وسلطان بسعر ٤٩٩٬٠٠٠ لسنة. تأكّد من مطابقة النطاق والمدة التقويمية والمبلغ النهائي والانتهاء في التطبيق قبل الدفع. لا تتابع عند الاختلاف."
        ]
      },
      {
        "heading": [
          "DOKU dan aktivasi",
          "DOKU and activation",
          "DOKU والتفعيل"
        ],
        "body": [
          "Pembayaran memakai DOKU melalui QRIS, Virtual Account, atau E-Wallet yang tersedia pada checkout. Status dibayar dan status akses aktif perlu dikonfirmasi terpisah. Jika dana terpotong tetapi akses belum aktif, hubungi bantuan dengan nomor transaksi sebelum membayar ulang.",
          "Payments use available DOKU methods such as QRIS, Virtual Account, or E-Wallet. Payment status and active access must be confirmed separately. If funds are deducted but access is inactive, contact support with the transaction number before paying again.",
          "تتم المدفوعات عبر وسائل DOKU المتاحة مثل QRIS والحساب الافتراضي والمحفظة الإلكترونية. تُراجع حالة الدفع وتفعيل الوصول كلٌّ على حدة. إذا خُصم المبلغ دون تفعيل، تواصل مع الدعم برقم المعاملة قبل إعادة الدفع."
        ]
      },
      {
        "heading": [
          "Perpanjangan dan voucher",
          "Renewal and vouchers",
          "التجديد والقسائم"
        ],
        "body": [
          "Semua perpanjangan dilakukan manual tanpa auto-debit. Akses berakhir sesuai tanggal pada akun. Voucher mengikuti cakupan, masa berlaku, dan batas penukaran yang diterbitkan. Voucher tidak dapat diuangkan.",
          "All renewals are manual with no automatic debit. Access expires on the date shown in your account. Vouchers follow their published scope, validity, and redemption limits. Vouchers cannot be exchanged for cash.",
          "كل تجديد يدوي دون خصم تلقائي. ينتهي الوصول في التاريخ المبيّن في الحساب. تتبع القسائم نطاقها وصلاحيتها وحدود استخدامها المنشورة، ولا تُستبدل نقدًا."
        ]
      }
    ]
  },
  "sources-and-rights": {
    "key": "rights",
    "intro": [
      "Sumber dan hak penggunaan.",
      "Sources and usage rights.",
      "المصادر وحقوق الاستخدام."
    ],
    "blocks": [
      {
        "heading": [
          "Hak setiap edisi",
          "Rights in each edition",
          "حقوق كل طبعة"
        ],
        "body": [
          "Karya klasik tidak otomatis membuat semua tahkik, terjemahan, atau reproduksi modern bebas hak cipta. Akses aplikasi tidak memberikan izin umum untuk menyalin atau menjual isi kitab.",
          "A classical work does not automatically place modern editions, translations, or reproductions in the public domain. App access does not grant blanket permission to copy or sell book contents.",
          "لا يجعل قِدم المؤلف كل تحقيق أو ترجمة أو تصوير حديث مباح الحقوق. ولا يمنح الوصول إلى التطبيق إذنًا عامًا بنسخ الكتب أو بيعها."
        ]
      },
      {
        "heading": [
          "Atribusi dan permohonan koreksi",
          "Attribution and correction requests",
          "النسبة وطلبات التصحيح"
        ],
        "body": [
          "Cantumkan karya, pengarang, dan edisi yang digunakan. Pemegang hak dapat menghubungi openturath@gmail.com dengan identitas karya, lokasi materi, bukti hak, dan permintaan yang jelas.",
          "Credit the work, author, and edition used. Rights holders can contact openturath@gmail.com with the work’s identity, material location, rights evidence, and a clear request.",
          "اذكر العمل والمؤلف والطبعة المستخدمة. يمكن لأصحاب الحقوق التواصل عبر openturath@gmail.com مع هوية العمل وموقع المادة وإثبات الحق وطلب واضح."
        ]
      }
    ]
  },
  "accessibility": {
    "key": "accessibility",
    "intro": [
      "Dapat dibaca, dapat digunakan.",
      "Readable and usable.",
      "قابل للقراءة والاستخدام."
    ],
    "blocks": [
      {
        "heading": [
          "Navigasi dan preferensi",
          "Navigation and preferences",
          "التنقل والتفضيلات"
        ],
        "body": [
          "Gunakan tautan lewati ke isi, navigasi papan ketik, dan kontrol ukuran teks pada arsip telaah. Dialog dapat ditutup dengan Escape. Tema dan bahasa disimpan pada perangkat jika penyimpanan diizinkan.",
          "Use the skip link, keyboard navigation, and reading-size controls in the study archive. Close dialogs with Escape. Theme and language preferences are stored on your device when storage is allowed.",
          "استخدم رابط تجاوز التنقل ولوحة المفاتيح وضوابط حجم النص في الأرشيف. أغلق الحوارات بزر Escape. تُحفظ تفضيلات المظهر واللغة على الجهاز عند السماح بالتخزين."
        ]
      },
      {
        "heading": [
          "Arab dan pengurangan gerak",
          "Arabic and reduced motion",
          "العربية وتقليل الحركة"
        ],
        "body": [
          "Halaman Arab menggunakan RTL dan font Arab lokal. Efek paralaks mengikuti preferensi pengurangan gerak. Konten utama tetap tersedia tanpa JavaScript. Laporkan hambatan akses melalui halaman kontak.",
          "Arabic pages use RTL and locally served Arabic fonts. Parallax respects reduced-motion preferences. Core content remains available without JavaScript. Report accessibility barriers through Contact.",
          "تستخدم الصفحات العربية اتجاه RTL وخطوطًا عربية محلية. تراعي الحركة تفضيل تقليلها. يبقى المحتوى الأساسي متاحًا دون JavaScript. أبلغ عن عوائق الاستخدام عبر التواصل."
        ]
      }
    ]
  },
  "account-deletion": {
    "key": "deletion",
    "intro": [
      "Penghapusan akun dan data.",
      "Delete your account and data.",
      "حذف الحساب والبيانات."
    ],
    "blocks": [
      {
        "heading": [
          "Mengajukan permohonan",
          "Make a request",
          "تقديم طلب"
        ],
        "body": [
          "Gunakan fitur penghapusan akun dalam aplikasi atau hubungi openturath@gmail.com dari email akun. Pengelola dapat meminta verifikasi kepemilikan yang proporsional. Jangan mengirim kata sandi atau OTP.",
          "Use account deletion in the app or contact openturath@gmail.com from your account email. The operator may request proportionate ownership verification. Never send a password or OTP.",
          "استخدم حذف الحساب داخل التطبيق أو راسل openturath@gmail.com من بريد الحساب. قد يُطلب تحقّق متناسب من الملكية. لا ترسل كلمة مرور أو رمز تحقّق."
        ]
      },
      {
        "heading": [
          "Data yang berbeda tempat penyimpanan",
          "Data stored in different places",
          "البيانات في مواضع مختلفة"
        ],
        "body": [
          "Cadangkan Catatan lokal sebelum menghapus data aplikasi. Penghapusan akun OpenTurath tidak otomatis menghapus data pada akun Google/NotebookLM. Data transaksi yang wajib disimpan secara hukum dapat dikecualikan dari penghapusan langsung.",
          "Back up local Notes before deleting app data. Deleting OpenTurath does not automatically delete data in your Google/NotebookLM account. Transaction records legally required for retention may be exempt from immediate deletion.",
          "انسخ الملاحظات المحلية قبل حذف بيانات التطبيق. لا يحذف حذف حساب OpenTurath بيانات Google/NotebookLM تلقائيًا. وقد تُستثنى سجلات المعاملات الواجب حفظها قانونًا من الحذف الفوري."
        ]
      }
    ],
    "policy": true
  },
  "security": {
    "key": "security",
    "intro": [
      "Keamanan dan pelaporan.",
      "Security and reporting.",
      "الأمن والإبلاغ."
    ],
    "blocks": [
      {
        "heading": [
          "Melindungi akses",
          "Protecting access",
          "حماية الوصول"
        ],
        "body": [
          "Jangan membagikan kata sandi, kode sekali pakai, atau tautan akun pribadi. Gunakan perangkat yang tepercaya dan periksa alamat resmi sebelum masuk atau membayar.",
          "Do not share passwords, one-time codes, or private account links. Use trusted devices and check official addresses before signing in or paying.",
          "لا تشارك كلمات المرور أو الرموز المؤقتة أو روابط الحساب الخاصة. استخدم أجهزة موثوقة وتحقّق من العنوان الرسمي قبل الدخول أو الدفع."
        ]
      },
      {
        "heading": [
          "Laporan kerentanan",
          "Vulnerability reports",
          "بلاغات الثغرات"
        ],
        "body": [
          "Kirim deskripsi kerentanan dan langkah reproduksi minimum ke openturath@gmail.com. Hindari mengambil data pengguna lain atau mengganggu layanan. Pengamanan operasional, cadangan, dan pemantauan tetap menjadi tanggung jawab pengelola deployment.",
          "Send a vulnerability description and minimal reproduction steps to openturath@gmail.com. Avoid accessing other users’ data or disrupting service. Operational security, backups, and monitoring remain the deployment operator’s responsibility.",
          "أرسل وصف الثغرة وخطوات إعادة إنتاج محدودة إلى openturath@gmail.com. تجنّب الوصول إلى بيانات الآخرين أو تعطيل الخدمة. تبقى الحماية التشغيلية والنسخ الاحتياطية والمراقبة مسؤولية مشغّل النشر."
        ]
      }
    ]
  }
};
```

## site.config.json

```json
{
  "name": "OpenTurath",
  "tagline": "AI for Islamic Scholarship",
  "canonicalUrl": "https://openturath.id",
  "operator": {
    "name": "Pengelola OpenTurath",
    "email": "openturath@gmail.com",
    "jurisdiction": "Indonesia",
    "privacyEmail": "openturath@gmail.com",
    "securityEmail": "openturath@gmail.com"
  },
  "downloads": [
    {
      "platform": "Android",
      "type": "apk",
      "version": "1.0.51",
      "date": "2026-09-20",
      "minimumOS": "Android 8.0+",
      "url": "https://openturath.id/downloads/openturath-v1.0.51.apk",
      "comingSoon": true,
      "unavailableReason": "awaiting-release-artifact"
    },
    {
      "platform": "macOS",
      "type": "web",
      "version": "1.0.51",
      "date": "2026-09-20",
      "minimumOS": "macOS 13+",
      "url": "https://openturath.id/download",
      "comingSoon": true
    },
    {
      "platform": "Windows",
      "type": "web",
      "version": "1.0.51",
      "date": "2026-09-20",
      "minimumOS": "Windows 10+",
      "url": "https://openturath.id/download",
      "comingSoon": true
    },
    {
      "platform": "iOS",
      "type": "web",
      "version": "1.0.51",
      "date": "2026-09-20",
      "minimumOS": "iOS",
      "url": "https://openturath.id/download",
      "comingSoon": true
    }
  ],
  "plans": [
    {
      "renewal": {
        "id": "Perpanjangan manual. Tanpa auto-debit.",
        "en": "Manual renewal. No automatic debit.",
        "ar": "تجديد يدوي. دون خصم تلقائي."
      },
      "refund": {
        "id": "Permohonan refund ditinjau paling lambat 7 hari kerja setelah data lengkap. Jika disetujui, pemrosesan paling lambat 7 hari kerja berikutnya, mengikuti penyedia pembayaran.",
        "en": "Refund requests are reviewed within 7 business days of complete information. Approved refunds are processed within a further 7 business days, subject to the payment provider.",
        "ar": "تُراجع طلبات الاسترداد خلال ٧ أيام عمل من اكتمال البيانات. وبعد الموافقة تُعالج خلال ٧ أيام عمل أخرى، وفق مزود الدفع."
      },
      "taxes": {
        "id": "Metode yang tersedia mengikuti checkout DOKU. Jumlah akhir dan tanggal berakhir akses ditampilkan sebelum transaksi.",
        "en": "Available methods depend on DOKU checkout. The final amount and access expiry are shown before the transaction.",
        "ar": "تعتمد الوسائل المتاحة على صفحة الدفع لدى DOKU. يُعرض المبلغ النهائي وتاريخ انتهاء الوصول قبل المعاملة."
      },
      "cancellation": {
        "id": "Akses berakhir sesuai tanggal pada akun. Tidak ada perpanjangan otomatis.",
        "en": "Access ends on the date shown in your account. No automatic renewal.",
        "ar": "ينتهي الوصول في التاريخ المبيّن في حسابك. لا تجديد تلقائي."
      },
      "paymentLocation": {
        "id": "Melalui checkout DOKU resmi di aplikasi.",
        "en": "Through official DOKU checkout in the app.",
        "ar": "عبر صفحة الدفع الرسمية لدى DOKU في التطبيق."
      },
      "id": "tholib",
      "price": 49000,
      "currency": "IDR",
      "months": 1,
      "name": {
        "id": "Paket Tholib",
        "en": "Tholib Plan",
        "ar": "باقة الطالب"
      },
      "period": {
        "id": "1 bulan",
        "en": "1 month",
        "ar": "شهر واحد"
      },
      "coverage": {
        "id": "Satu asisten spesialis pilihan sesuai cakupan pada checkout.",
        "en": "One selected specialist assistant, as specified at checkout.",
        "ar": "مساعد متخصص واحد تختاره وفق النطاق المبيّن عند الدفع."
      }
    },
    {
      "renewal": {
        "id": "Perpanjangan manual. Tanpa auto-debit.",
        "en": "Manual renewal. No automatic debit.",
        "ar": "تجديد يدوي. دون خصم تلقائي."
      },
      "refund": {
        "id": "Permohonan refund ditinjau paling lambat 7 hari kerja setelah data lengkap. Jika disetujui, pemrosesan paling lambat 7 hari kerja berikutnya, mengikuti penyedia pembayaran.",
        "en": "Refund requests are reviewed within 7 business days of complete information. Approved refunds are processed within a further 7 business days, subject to the payment provider.",
        "ar": "تُراجع طلبات الاسترداد خلال ٧ أيام عمل من اكتمال البيانات. وبعد الموافقة تُعالج خلال ٧ أيام عمل أخرى، وفق مزود الدفع."
      },
      "taxes": {
        "id": "Metode yang tersedia mengikuti checkout DOKU. Jumlah akhir dan tanggal berakhir akses ditampilkan sebelum transaksi.",
        "en": "Available methods depend on DOKU checkout. The final amount and access expiry are shown before the transaction.",
        "ar": "تعتمد الوسائل المتاحة على صفحة الدفع لدى DOKU. يُعرض المبلغ النهائي وتاريخ انتهاء الوصول قبل المعاملة."
      },
      "cancellation": {
        "id": "Akses berakhir sesuai tanggal pada akun. Tidak ada perpanjangan otomatis.",
        "en": "Access ends on the date shown in your account. No automatic renewal.",
        "ar": "ينتهي الوصول في التاريخ المبيّن في حسابك. لا تجديد تلقائي."
      },
      "paymentLocation": {
        "id": "Melalui checkout DOKU resmi di aplikasi.",
        "en": "Through official DOKU checkout in the app.",
        "ar": "عبر صفحة الدفع الرسمية لدى DOKU في التطبيق."
      },
      "id": "tematik",
      "price": 149000,
      "currency": "IDR",
      "months": 3,
      "name": {
        "id": "Paket Tematik",
        "en": "Thematic Plan",
        "ar": "الباقة الموضوعية"
      },
      "period": {
        "id": "3 bulan",
        "en": "3 months",
        "ar": "٣ أشهر"
      },
      "coverage": {
        "id": "Satu rumpun kajian sesuai daftar asisten pada checkout.",
        "en": "One study group, with assistants listed at checkout.",
        "ar": "مجموعة دراسية واحدة وفق قائمة المساعدين عند الدفع."
      }
    },
    {
      "renewal": {
        "id": "Perpanjangan manual. Tanpa auto-debit.",
        "en": "Manual renewal. No automatic debit.",
        "ar": "تجديد يدوي. دون خصم تلقائي."
      },
      "refund": {
        "id": "Permohonan refund ditinjau paling lambat 7 hari kerja setelah data lengkap. Jika disetujui, pemrosesan paling lambat 7 hari kerja berikutnya, mengikuti penyedia pembayaran.",
        "en": "Refund requests are reviewed within 7 business days of complete information. Approved refunds are processed within a further 7 business days, subject to the payment provider.",
        "ar": "تُراجع طلبات الاسترداد خلال ٧ أيام عمل من اكتمال البيانات. وبعد الموافقة تُعالج خلال ٧ أيام عمل أخرى، وفق مزود الدفع."
      },
      "taxes": {
        "id": "Metode yang tersedia mengikuti checkout DOKU. Jumlah akhir dan tanggal berakhir akses ditampilkan sebelum transaksi.",
        "en": "Available methods depend on DOKU checkout. The final amount and access expiry are shown before the transaction.",
        "ar": "تعتمد الوسائل المتاحة على صفحة الدفع لدى DOKU. يُعرض المبلغ النهائي وتاريخ انتهاء الوصول قبل المعاملة."
      },
      "cancellation": {
        "id": "Akses berakhir sesuai tanggal pada akun. Tidak ada perpanjangan otomatis.",
        "en": "Access ends on the date shown in your account. No automatic renewal.",
        "ar": "ينتهي الوصول في التاريخ المبيّن في حسابك. لا تجديد تلقائي."
      },
      "paymentLocation": {
        "id": "Melalui checkout DOKU resmi di aplikasi.",
        "en": "Through official DOKU checkout in the app.",
        "ar": "عبر صفحة الدفع الرسمية لدى DOKU في التطبيق."
      },
      "id": "sultan",
      "price": 499000,
      "currency": "IDR",
      "months": 12,
      "name": {
        "id": "Sultan All-Access",
        "en": "Sultan All-Access",
        "ar": "سلطان للوصول الشامل"
      },
      "period": {
        "id": "1 tahun",
        "en": "1 year",
        "ar": "سنة واحدة"
      },
      "coverage": {
        "id": "Seluruh asisten yang tercakup dalam paket aktif. Profil yang masih dalam persiapan belum termasuk akses.",
        "en": "All assistants covered by the active plan. Profiles in preparation are not yet accessible.",
        "ar": "جميع المساعدين المشمولين بالباقة المفعّلة. الملفات قيد الإعداد غير متاحة بعد."
      }
    }
  ],
  "releaseNotes": [
    {
      "version": "1.0.51",
      "date": "2026-09-20",
      "summary": {
        "id": "Antarmuka trilingual, katalog asisten, dan Catatan lokal.",
        "en": "Trilingual interface, assistant catalogue, and local Notes.",
        "ar": "واجهة بثلاث لغات وفهرس المساعدين وملاحظات محلية."
      },
      "body": {
        "id": "Versi aplikasi yang tercantum dalam konfigurasi pengelola adalah 1.0.51. Ketersediaan asisten mengikuti status pada aplikasi. Catatan disimpan lokal pada perangkat. Referensi dan hasil AI tetap memerlukan pemeriksaan.",
        "en": "The app version listed in the publisher configuration is 1.0.51. Assistant availability follows the status in the app. Notes are stored locally on the device. References and AI outputs still require review.",
        "ar": "إصدار التطبيق المبيّن في إعدادات الجهة المشغلة هو 1.0.51. تتبع إتاحة المساعدين حالتهم في التطبيق. تُحفظ الملاحظات محليًا على الجهاز، وتظل المراجع ومخرجات الذكاء الاصطناعي محتاجة إلى المراجعة."
      }
    }
  ],
  "policiesApproved": true,
  "catalogReviewed": true,
  "comparisonRightsConfirmed": true,
  "reports": {
    "enabled": true,
    "retentionDays": 30
  },
  "analytics": {
    "enabled": false
  },
  "appDeepLinkBase": "",
  "commercialRevision": "website-brief-2026-09-20",
  "appCommercialParity": "pending-backend-mapping",
  "policyVersion": "1.0",
  "policyEffectiveDate": "2026-09-13",
  "distribution": {
    "mode": "website-only",
    "reason": "awaiting-release-artifact"
  }
}
```

## content/catalog.json

```json
[
  {
    "id": "fiqh-syafii",
    "sourceId": "fiqh_syafii",
    "index": 1,
    "name": {
      "id": "Fikih Syafi'i",
      "en": "Shāfiʿī Fiqh",
      "ar": "الفقه الشافعي المعتمد"
    },
    "arabic": "الفقه الشافعي",
    "group": "fiqh",
    "description": {
      "id": "Telaah fikih Syafi’i melalui Al-Umm, Minhajuth Thalibin, Tuhfatul Muhtaj, dan Nihayatul Muhtaj. Temukan ibarah, perincian hukum, serta rujukan jilid dan halamannya.",
      "en": "Study Shāfiʿī law through Al-Umm, Minhāj al-Ṭālibīn, Tuḥfat al-Muḥtāj, and Nihāyat al-Muḥtāj. Explore source passages, legal distinctions, and volume and page references.",
      "ar": "طالع الفقه الشافعي في الأم ومنهاج الطالبين وتحفة المحتاج ونهاية المحتاج، وتتبّع العبارات وتفصيل الأحكام وإحالات الأجزاء والصفحات."
    },
    "source": "metadata_modul_lengkap.json (counts), metadata_training_seluruh_ai.json (partitions), supplied project data 2026-09-20",
    "countsPublished": true,
    "status": "active",
    "appAgentId": "fiqh_syafii",
    "variant": "featured",
    "metadata": {
      "books": 103,
      "volumes": 400,
      "volumesLowerBound": true,
      "pages": 170391,
      "words": 71627898,
      "lectures": 0,
      "partitions": 241,
      "period": {
        "id": "150 – 1338 H",
        "en": "150–1338 AH",
        "ar": "١٥٠–١٣٣٨ هـ"
      }
    },
    "metadataKey": "fiqh_syafii"
  },
  {
    "id": "hadits",
    "sourceId": "hadits",
    "index": 2,
    "name": {
      "id": "Kutubus Sunnah & Matan Hadits",
      "en": "Hadith Collections",
      "ar": "متون الحديث النبوي وكتب السنة"
    },
    "arabic": "الحديث الشريف",
    "group": "hadith",
    "description": {
      "id": "Telusuri matan dan jalur sanad dalam Kutubus Sittah, musnad, dan kitab hadits induk. Bandingkan lafaz riwayat, letak bab, dan penomoran hadits.",
      "en": "Trace texts and chains of transmission in the Six Books, musnad collections, and major hadith sources. Compare wording, chapter placement, and hadith numbering.",
      "ar": "تتبّع المتون والأسانيد في الكتب الستة والمسانيد وأمهات كتب الحديث، وقارن ألفاظ الروايات وأبوابها وأرقامها."
    },
    "source": "metadata_modul_lengkap.json (counts), metadata_training_seluruh_ai.json (partitions), supplied project data 2026-09-20",
    "countsPublished": true,
    "status": "active",
    "appAgentId": "hadits",
    "variant": "featured",
    "metadata": {
      "books": 1141,
      "volumes": 1500,
      "volumesLowerBound": true,
      "pages": 532640,
      "words": 105700587,
      "lectures": 0,
      "partitions": 233,
      "period": {
        "id": "Abad 2 – 10 H",
        "en": "2–10 c. AH",
        "ar": "القرن ٢–١٠ هـ"
      }
    },
    "metadataKey": "hadits"
  },
  {
    "id": "ushul-fiqh",
    "sourceId": "ushul_fiqh",
    "index": 3,
    "name": {
      "id": "Ushul Fikih 4 Mazhab",
      "en": "Principles of Islamic Law",
      "ar": "أصول الفقه المقارن وقواعد الاستنباط"
    },
    "arabic": "أصول الفقه",
    "group": "fiqh",
    "description": {
      "id": "Kaji dalalatul alfaz, qiyas, dan metode istinbath lintas empat mazhab. Baca pembahasan ushul melalui Al-Mustashfa, Al-Luma’, dan Al-Burhan.",
      "en": "Examine textual indications, analogy, and methods of legal inference across the four schools, with discussions from Al-Mustaṣfā, Al-Lumaʿ, and Al-Burhān.",
      "ar": "ادرس دلالات الألفاظ والقياس ومناهج الاستنباط في المذاهب الأربعة، من خلال مباحث المستصفى واللمع والبرهان."
    },
    "source": "metadata_modul_lengkap.json (counts), metadata_training_seluruh_ai.json (partitions), supplied project data 2026-09-20",
    "countsPublished": true,
    "status": "active",
    "appAgentId": "ushul_fiqh",
    "variant": "standard",
    "metadata": {
      "books": 136,
      "volumes": 320,
      "volumesLowerBound": true,
      "pages": 115000,
      "words": 36522580,
      "lectures": 0,
      "partitions": 121,
      "period": {
        "id": "Abad 2 – 14 H",
        "en": "2–14 c. AH",
        "ar": "القرن ٢–١٤ هـ"
      }
    },
    "metadataKey": "ushul_fiqh"
  },
  {
    "id": "bahasa-arab",
    "sourceId": "bahasa_arab",
    "index": 4,
    "name": {
      "id": "Bahasa Arab & Ilmu Alat",
      "en": "Arabic Language & Literature",
      "ar": "علوم الآلة واللغة والأدب والنحو والبلاغة والمنطق"
    },
    "arabic": "علوم اللغة العربية",
    "group": "language",
    "description": {
      "id": "Bedah struktur ibarah melalui nahwu, sharaf, balaghah, mantiq, dan mu’jam. Telusuri pemakaian lafaz serta nuansa makna dalam bahasa dan sastra Arab.",
      "en": "Read passages through grammar, morphology, rhetoric, logic, and lexicons. Trace word usage and shades of meaning across Arabic language and literature.",
      "ar": "حلّل بنية العبارة بالنحو والصرف والبلاغة والمنطق والمعاجم، وتتبّع استعمال الألفاظ ودقائق المعاني في اللغة والأدب العربي."
    },
    "source": "metadata_modul_lengkap.json (counts), metadata_training_seluruh_ai.json (partitions), supplied project data 2026-09-20",
    "countsPublished": true,
    "status": "active",
    "appAgentId": "nahwu_sharaf",
    "variant": "standard",
    "metadata": {
      "books": 866,
      "volumes": 1981,
      "volumesLowerBound": false,
      "pages": 610000,
      "words": 148304518,
      "lectures": 0,
      "partitions": 300,
      "period": {
        "id": "Jahiliyyah – Abad 20 M",
        "en": "Pre-Islamic era – 20th c. CE",
        "ar": "الجاهلية – القرن ٢٠ م"
      }
    },
    "metadataKey": "bahasa_arab"
  },
  {
    "id": "tafsir",
    "sourceId": "tafsir",
    "index": 5,
    "name": {
      "id": "Tafsir & 'Ulumul Qur'an",
      "en": "Tafsir & Qur’anic Studies",
      "ar": "التفسير المأثور وعلوم القرآن والتأويل"
    },
    "arabic": "التفسير وعلوم القرآن",
    "group": "quran",
    "description": {
      "id": "Telaah ayat melalui Tafsir Ath-Thabari, Ibnu Katsir, dan Al-Qurthubi. Hubungkan penjelasan bil-ma’tsur dan dirayah dengan asbabun nuzul, nasikh-mansukh, serta kaidah tafsir.",
      "en": "Study verses through the commentaries of al-Ṭabarī, Ibn Kathīr, and al-Qurṭubī. Connect transmitted and analytical interpretation with occasions of revelation, abrogation, and principles of tafsir.",
      "ar": "طالع الآيات في تفاسير الطبري وابن كثير والقرطبي، واربط التفسير بالمأثور والدراية بأسباب النزول والناسخ والمنسوخ وقواعد التفسير."
    },
    "source": "metadata_modul_lengkap.json (counts), metadata_training_seluruh_ai.json (partitions), supplied project data 2026-09-20",
    "countsPublished": true,
    "status": "active",
    "appAgentId": "tafsir",
    "variant": "standard",
    "metadata": {
      "books": 123,
      "volumes": 450,
      "volumesLowerBound": true,
      "pages": 140000,
      "words": 78862654,
      "lectures": 0,
      "partitions": 183,
      "period": {
        "id": "Abad 2 – 14 H",
        "en": "2–14 c. AH",
        "ar": "القرن ٢–١٤ هـ"
      }
    },
    "metadataKey": "tafsir"
  },
  {
    "id": "fiqh-tahawwulat",
    "sourceId": "fiqh_tahawwulat",
    "index": 6,
    "name": {
      "id": "Fikih Tahawwulat",
      "en": "Fiqh al-Tahawwulat",
      "ar": "فقه التحولات وسنن المتغيرات"
    },
    "arabic": "فقه التحولات",
    "group": "special",
    "description": {
      "id": "Dalami karya Habib Abu Bakar Al-Adni Al-Masyhur tentang tanda-tanda zaman, pergeseran peradaban, dan sunanul mughayyarat, melalui kitab serta arsip muhadharah.",
      "en": "Explore Habib Abu Bakr al-Adni al-Mashhur’s works on signs of the times, civilizational change, and sunan al-mughayyarāt through books and lecture archives.",
      "ar": "تعمّق في مؤلفات الحبيب أبي بكر العدني المشهور عن علامات الزمان وتحولات الحضارات وسنن المتغيرات، من خلال الكتب وأرشيف المحاضرات."
    },
    "source": "metadata_modul_lengkap.json (counts), metadata_training_seluruh_ai.json (partitions), supplied project data 2026-09-20",
    "countsPublished": true,
    "status": "active",
    "appAgentId": "fiqh_tahawwulat",
    "variant": "sovereign",
    "metadata": {
      "books": 58,
      "volumes": 58,
      "volumesLowerBound": false,
      "pages": 12500,
      "words": 5644146,
      "lectures": 1099,
      "partitions": 71,
      "period": {
        "id": "Era Kontemporer",
        "en": "Contemporary period",
        "ar": "العصر المعاصر"
      }
    },
    "metadataKey": "fiqh_tahawwulat"
  },
  {
    "id": "tarikh-sirah",
    "sourceId": "tarikh_sirah",
    "index": 7,
    "name": {
      "id": "Tarikh & Sirah Nabawiyyah",
      "en": "History & Prophetic Biography",
      "ar": "التاريخ الإسلامي والسيرة والبلدان والرحلات والأنساب"
    },
    "arabic": "السيرة والتاريخ",
    "group": "history",
    "description": {
      "id": "Ikuti sirah Nabi, masa khulafaur rasyidin, dan perkembangan peradaban Islam. Telaah urutan peristiwa, jalur riwayat, serta konteks tempat dan zamannya.",
      "en": "Follow the Prophet’s biography, the rightly guided caliphs, and the development of Islamic civilization. Examine chronology, transmitted accounts, and geographical and historical context.",
      "ar": "تتبّع السيرة النبوية وعصر الخلفاء الراشدين وتطور الحضارة الإسلامية، وادرس تسلسل الوقائع وطرق الرواية وسياق المكان والزمان."
    },
    "source": "metadata_modul_lengkap.json (counts), metadata_training_seluruh_ai.json (partitions), supplied project data 2026-09-20",
    "countsPublished": true,
    "status": "active",
    "appAgentId": "tarikh",
    "variant": "standard",
    "metadata": {
      "books": 499,
      "volumes": 1374,
      "volumesLowerBound": false,
      "pages": 480000,
      "words": 136531222,
      "lectures": 0,
      "partitions": 300,
      "period": {
        "id": "Pra-Hijrah – Abad 14 H",
        "en": "Before Hijrah – 14th c. AH",
        "ar": "ما قبل الهجرة – القرن ١٤ هـ"
      }
    },
    "metadataKey": "tarikh_sirah"
  },
  {
    "id": "fiqh-muqaran",
    "sourceId": "fiqh_muqaran",
    "index": 8,
    "name": {
      "id": "Fikih Muqaran & Siyasah",
      "en": "Comparative Fiqh",
      "ar": "الفقه المقارن والسياسة الشرعية وقسمة الفرائض"
    },
    "arabic": "الفقه المقارن",
    "group": "fiqh",
    "description": {
      "id": "Bandingkan dalil dan konstruksi hukum antarmazhab. Perluas telaah ke siyasah syar’iyyah, tata kelola negara, serta pembahasan sengketa dan persoalan kontemporer.",
      "en": "Compare evidence and legal reasoning across schools. Extend your study to Islamic governance, public institutions, disputes, and contemporary legal questions.",
      "ar": "قارن الأدلة وبناء الأحكام بين المذاهب، ووسّع المطالعة إلى السياسة الشرعية ونظم الحكم ومباحث المنازعات والمسائل المعاصرة."
    },
    "source": "metadata_modul_lengkap.json (counts), metadata_training_seluruh_ai.json (partitions), supplied project data 2026-09-20",
    "countsPublished": true,
    "status": "active",
    "appAgentId": "fiqh_muqaran",
    "variant": "standard",
    "metadata": {
      "books": 189,
      "volumes": 329,
      "volumesLowerBound": false,
      "pages": 135000,
      "words": 27585932,
      "lectures": 0,
      "partitions": 61,
      "period": {
        "id": "Abad 2 – 14 H",
        "en": "2–14 c. AH",
        "ar": "القرن ٢–١٤ هـ"
      }
    },
    "metadataKey": "fiqh_muqaran"
  },
  {
    "id": "fatawa-masail",
    "sourceId": "fatawa_masail",
    "index": 9,
    "name": {
      "id": "Fatawa & Masail Fiqhiyyah",
      "en": "Fatwas & Legal Questions",
      "ar": "الفتاوى الكبرى والنوازل الفقهية"
    },
    "arabic": "الفتاوى والمسائل",
    "group": "fiqh",
    "description": {
      "id": "Telusuri fatwa ulama klasik dan kontemporer beserta konteks pertanyaannya. Kaji nawazil, pertimbangan hukum, dan ragam jawaban atas persoalan masyarakat.",
      "en": "Explore classical and contemporary fatwas alongside the questions that prompted them. Study new cases, legal considerations, and differing responses to community issues.",
      "ar": "تتبّع فتاوى العلماء المتقدمين والمعاصرين مع سياق أسئلتها، وادرس النوازل واعتبارات الحكم وتنوع الأجوبة عن قضايا المجتمع."
    },
    "source": "metadata_modul_lengkap.json (counts), metadata_training_seluruh_ai.json (partitions), supplied project data 2026-09-20",
    "countsPublished": true,
    "status": "active",
    "appAgentId": "fatawa_masail",
    "variant": "standard",
    "metadata": {
      "books": 221,
      "volumes": 324,
      "volumesLowerBound": false,
      "pages": 57419,
      "words": 19387054,
      "lectures": 0,
      "partitions": 101,
      "period": {
        "id": "Abad 6 – 14 H",
        "en": "6–14 c. AH",
        "ar": "القرن ٦–١٤ هـ"
      }
    },
    "metadataKey": "fatawa_masail"
  },
  {
    "id": "syarah-hadits",
    "sourceId": "syarah_hadits",
    "index": 10,
    "name": {
      "id": "Syarah Hadits Nabawi",
      "en": "Hadith Commentaries",
      "ar": "شروح الحديث النبوي وفقه الآثار"
    },
    "arabic": "شروح الحديث",
    "group": "hadith",
    "description": {
      "id": "Dalami kandungan hadits melalui Fathul Bari, Syarah Shahih Muslim, dan Nailul Authar. Temukan penjelasan lafaz, faedah hukum, dan perbedaan pembacaan para pensyarah.",
      "en": "Study hadith through Fatḥ al-Bārī, the commentary on Ṣaḥīḥ Muslim, and Nayl al-Awṭār. Explore wording, legal lessons, and differences among commentators.",
      "ar": "تعمّق في معاني الحديث من خلال فتح الباري وشرح صحيح مسلم ونيل الأوطار، وتعرّف إلى شرح الألفاظ والفوائد الفقهية واختلاف أنظار الشُرّاح."
    },
    "source": "metadata_modul_lengkap.json (counts), metadata_training_seluruh_ai.json (partitions), supplied project data 2026-09-20",
    "countsPublished": true,
    "status": "active",
    "appAgentId": "syarah_hadits",
    "variant": "standard",
    "metadata": {
      "books": 202,
      "volumes": 1007,
      "volumesLowerBound": false,
      "pages": 420000,
      "words": 122463779,
      "lectures": 0,
      "partitions": 300,
      "period": {
        "id": "Abad 4 – 14 H",
        "en": "4–14 c. AH",
        "ar": "القرن ٤–١٤ هـ"
      }
    },
    "metadataKey": "syarah_hadits"
  },
  {
    "id": "fiqh-hanafi",
    "sourceId": "fiqh_hanafi",
    "index": 11,
    "name": {
      "id": "Fikih Hanafi",
      "en": "Hanafi Fiqh",
      "ar": "الفقه الحنفي المعتمد وظاهر الرواية"
    },
    "arabic": "الفقه الحنفي",
    "group": "fiqh",
    "description": {
      "id": "Telaah tradisi fikih Hanafi dari Zhahirur Riwayah hingga Al-Hidayah dan Raddul Muhtar. Ikuti hubungan matan, syarah, dan fatwa dalam perincian masalah mazhab.",
      "en": "Explore Hanafi jurisprudence from Ẓāhir al-Riwāyah to Al-Hidāyah and Radd al-Muḥtār. Follow the relationship between foundational texts, commentaries, and fatwas.",
      "ar": "طالع الفقه الحنفي من ظاهر الرواية إلى الهداية ورد المحتار، وتتبّع صلة المتون والشروح والفتاوى بتفصيل مسائل المذهب."
    },
    "source": "metadata_modul_lengkap.json (counts), metadata_training_seluruh_ai.json (partitions), supplied project data 2026-09-20",
    "countsPublished": true,
    "status": "active",
    "appAgentId": "fiqh_hanafi",
    "variant": "standard",
    "metadata": {
      "books": 85,
      "volumes": 288,
      "volumesLowerBound": false,
      "pages": 110000,
      "words": 39300555,
      "lectures": 0,
      "partitions": 100,
      "period": {
        "id": "Abad 2 – 13 H",
        "en": "2–13 c. AH",
        "ar": "القرن ٢–١٣ هـ"
      }
    },
    "metadataKey": "fiqh_hanafi"
  },
  {
    "id": "fiqh-maliki",
    "sourceId": "fiqh_maliki",
    "index": 12,
    "name": {
      "id": "Fikih Maliki",
      "en": "Maliki Fiqh",
      "ar": "الفقه المالكي المعتمد ومدونة سحنون"
    },
    "arabic": "الفقه المالكي",
    "group": "fiqh",
    "description": {
      "id": "Jelajahi fikih Maliki melalui Al-Mudawwanah, Mukhtashar Khalil, dan tradisi fatwa ulama Maghribi. Perhatikan dasar riwayat, amalan, dan rincian pendapat mazhab.",
      "en": "Explore Maliki law through Al-Mudawwanah, Mukhtaṣar Khalīl, and the Maghribi fatwa tradition, attending to transmitted positions, practice, and distinctions within the school.",
      "ar": "استكشف الفقه المالكي في المدونة ومختصر خليل وتراث فتاوى علماء المغرب، مع العناية بالروايات والعمل وتفصيل أقوال المذهب."
    },
    "source": "metadata_modul_lengkap.json (counts), metadata_training_seluruh_ai.json (partitions), supplied project data 2026-09-20",
    "countsPublished": true,
    "status": "active",
    "appAgentId": "fiqh_maliki",
    "variant": "standard",
    "metadata": {
      "books": 86,
      "volumes": 339,
      "volumesLowerBound": false,
      "pages": 164214,
      "words": 48363521,
      "lectures": 0,
      "partitions": 120,
      "period": {
        "id": "Abad 2 – 14 H",
        "en": "2–14 c. AH",
        "ar": "القرن ٢–١٤ هـ"
      }
    },
    "metadataKey": "fiqh_maliki"
  },
  {
    "id": "fiqh-hanbali",
    "sourceId": "fiqh_hanbali",
    "index": 13,
    "name": {
      "id": "Fikih Hanbali",
      "en": "Hanbali Fiqh",
      "ar": "الفقه الحنبلي المعتمد ومسائل الإمام أحمد"
    },
    "arabic": "الفقه الحنبلي",
    "group": "fiqh",
    "description": {
      "id": "Telusuri Al-Mughni, Al-Muqni’, dan Al-Inshaf untuk membaca fikih Hanbali. Bandingkan riwayat Imam Ahmad, wajah pendapat, serta penjelasan ulama mazhab.",
      "en": "Read Hanbali law through Al-Mughnī, Al-Muqniʿ, and Al-Inṣāf. Compare reports from Imam Aḥmad, legal positions, and explanations by the school’s scholars.",
      "ar": "تتبّع الفقه الحنبلي في المغني والمقنع والإنصاف، وقارن الروايات عن الإمام أحمد والأوجه الفقهية وبيان علماء المذهب."
    },
    "source": "metadata_modul_lengkap.json (counts), metadata_training_seluruh_ai.json (partitions), supplied project data 2026-09-20",
    "countsPublished": true,
    "status": "active",
    "appAgentId": "fiqh_hanbali",
    "variant": "standard",
    "metadata": {
      "books": 95,
      "volumes": 338,
      "volumesLowerBound": false,
      "pages": 163639,
      "words": 34626811,
      "lectures": 0,
      "partitions": 100,
      "period": {
        "id": "Abad 3 – 14 H",
        "en": "3–14 c. AH",
        "ar": "القرن ٣–١٤ هـ"
      }
    },
    "metadataKey": "fiqh_hanbali"
  },
  {
    "id": "tasawwuf",
    "sourceId": "tasawwuf",
    "index": 14,
    "name": {
      "id": "Tasawwuf & Adzkar",
      "en": "Spirituality & Remembrance",
      "ar": "التصوف السني والتزكية والأذكار النبوية"
    },
    "arabic": "التصوف والتزكية",
    "group": "spirituality",
    "description": {
      "id": "Pelajari tazkiyatun nufus, adab suluk, wirid, dan ratib dalam tradisi ulama. Telaah Ihya’ ‘Ulumiddin dan Al-Adzkar untuk menghubungkan ilmu, amal, serta pembinaan hati.",
      "en": "Study purification of the soul, spiritual discipline, litanies, and remembrance. Read Iḥyāʾ ʿUlūm al-Dīn and Al-Adhkār to connect knowledge, practice, and cultivation of the heart.",
      "ar": "ادرس تزكية النفوس وآداب السلوك والأوراد والأذكار في تراث العلماء، وطالع إحياء علوم الدين والأذكار لربط العلم بالعمل وتربية القلب."
    },
    "source": "metadata_modul_lengkap.json (counts), metadata_training_seluruh_ai.json (partitions), supplied project data 2026-09-20",
    "countsPublished": true,
    "status": "active",
    "appAgentId": "tasawwuf",
    "variant": "standard",
    "metadata": {
      "books": 248,
      "volumes": 317,
      "volumesLowerBound": false,
      "pages": 95000,
      "words": 18697388,
      "lectures": 0,
      "partitions": 61,
      "period": {
        "id": "Abad 3 – 14 H",
        "en": "3–14 c. AH",
        "ar": "القرن ٣–١٤ هـ"
      }
    },
    "metadataKey": "tasawwuf"
  },
  {
    "id": "tajwid-qiraat",
    "sourceId": "tajwid_qiraat",
    "index": 15,
    "name": {
      "id": "Tajwid & Qira'at",
      "en": "Tajwid & Qur’anic Readings",
      "ar": "التجويد والقراءات المتواترة ورسم المصحف"
    },
    "arabic": "التجويد والقراءات",
    "group": "quran",
    "description": {
      "id": "Kaji makharijul huruf, sifat huruf, dan kaidah tartil. Kenali perbedaan qira’at sepuluh, jalur periwayatan, serta landasan bacaan untuk mendampingi talaqqi.",
      "en": "Study articulation, letter qualities, and principles of measured recitation. Explore the ten readings, their transmission paths, and their textual foundations alongside oral instruction.",
      "ar": "ادرس مخارج الحروف وصفاتها وأحكام الترتيل، وتعرّف إلى أوجه القراءات العشر وطرقها وأصولها بما يعين على التلقّي والمشافهة."
    },
    "source": "metadata_modul_lengkap.json (counts), metadata_training_seluruh_ai.json (partitions), supplied project data 2026-09-20",
    "countsPublished": true,
    "status": "active",
    "appAgentId": "tajwid_qiraat",
    "variant": "standard",
    "metadata": {
      "books": 130,
      "volumes": 182,
      "volumesLowerBound": false,
      "pages": 45000,
      "words": 13714766,
      "lectures": 0,
      "partitions": 50,
      "period": {
        "id": "Abad 4 – 14 H",
        "en": "4–14 c. AH",
        "ar": "القرن ٤–١٤ هـ"
      }
    },
    "metadataKey": "tajwid_qiraat"
  },
  {
    "id": "qawaid-fiqhiyyah",
    "sourceId": "qawaid_fiqhiyyah",
    "index": 16,
    "name": {
      "id": "Qawa'id Fiqhiyyah",
      "en": "Legal Maxims",
      "ar": "القواعد الفقهية والأشباه والنظائر والفروق"
    },
    "arabic": "القواعد الفقهية",
    "group": "fiqh",
    "description": {
      "id": "Susun peta hukum melalui kaidah asasiyyah, kaidah furu’iyyah, dan dhowabith. Hubungkan pembahasan al-asybah wan-nazha’ir dengan contoh penerapan serta pengecualiannya.",
      "en": "Organize legal questions through overarching maxims, subsidiary rules, and disciplinary principles. Connect al-ashbāh wa-l-naẓāʾir with applications and exceptions.",
      "ar": "نظّم المسائل بالقواعد الكبرى والقواعد الفرعية والضوابط، واربط مباحث الأشباه والنظائر بتطبيقاتها واستثناءاتها."
    },
    "source": "metadata_modul_lengkap.json (counts), metadata_training_seluruh_ai.json (partitions), supplied project data 2026-09-20",
    "countsPublished": true,
    "status": "active",
    "appAgentId": "qawaid_fiqhiyyah",
    "variant": "standard",
    "metadata": {
      "books": 44,
      "volumes": 85,
      "volumesLowerBound": false,
      "pages": 32000,
      "words": 8187717,
      "lectures": 0,
      "partitions": 30,
      "period": {
        "id": "Abad 7 – 14 H",
        "en": "7–14 c. AH",
        "ar": "القرن ٧–١٤ هـ"
      }
    },
    "metadataKey": "qawaid_fiqhiyyah"
  },
  {
    "id": "musthalah-hadits",
    "sourceId": "musthalah_hadits",
    "index": 17,
    "name": {
      "id": "'Ulumul Hadits & Musthalah",
      "en": "Hadith Sciences",
      "ar": "علوم الحديث ومصطلحه ومناهج التخريج والعلل"
    },
    "arabic": "مصطلح الحديث",
    "group": "hadith",
    "description": {
      "id": "Pelajari kritik sanad, klasifikasi hadits, jarh wa ta’dil, dan ‘ilal. Telusuri landasan metodologinya melalui Muqaddimah Ibnu Shalah dan Tadribur Rawi.",
      "en": "Study isnad criticism, hadith classification, narrator evaluation, and hidden defects through the methodological discussions of Ibn al-Ṣalāḥ’s introduction and Tadrīb al-Rāwī.",
      "ar": "ادرس نقد الأسانيد وأقسام الحديث والجرح والتعديل والعلل، وتتبّع أصول المنهج في مقدمة ابن الصلاح وتدريب الراوي."
    },
    "source": "metadata_modul_lengkap.json (counts), metadata_training_seluruh_ai.json (partitions), supplied project data 2026-09-20",
    "countsPublished": true,
    "status": "active",
    "appAgentId": "musthalah_hadits",
    "variant": "standard",
    "metadata": {
      "books": 393,
      "volumes": 748,
      "volumesLowerBound": false,
      "pages": 285000,
      "words": 63241925,
      "lectures": 0,
      "partitions": 137,
      "period": {
        "id": "Abad 2 – 10 H",
        "en": "2–10 c. AH",
        "ar": "القرن ٢–١٠ هـ"
      }
    },
    "metadataKey": "musthalah_hadits"
  },
  {
    "id": "aqidah",
    "sourceId": "aqidah",
    "index": 18,
    "name": {
      "id": "Aqidah & Ushuluddin",
      "en": "Theology",
      "ar": "العقيدة وأصول الدين والمذاهب والفرق الإسلامية"
    },
    "arabic": "العقيدة والتوحيد",
    "group": "theology",
    "description": {
      "id": "Telaah akidah Ahlussunnah wal Jama’ah dalam tradisi Asy’ariyyah dan Maturidiyyah. Kaji dalil aqli-naqli, istilah ushuluddin, serta jawaban ulama terhadap persoalan pemikiran.",
      "en": "Study Sunni creed in the Ashʿari and Maturidi traditions. Examine rational and transmitted evidence, theological terminology, and scholarly responses to questions of belief.",
      "ar": "طالع عقيدة أهل السنة والجماعة في المدرستين الأشعرية والماتريدية، وادرس الأدلة العقلية والنقلية ومصطلحات أصول الدين وأجوبة العلماء عن مسائل الاعتقاد."
    },
    "source": "metadata_modul_lengkap.json (counts), metadata_training_seluruh_ai.json (partitions), supplied project data 2026-09-20",
    "countsPublished": true,
    "status": "active",
    "appAgentId": "aqidah",
    "variant": "standard",
    "metadata": {
      "books": 173,
      "volumes": 249,
      "volumesLowerBound": false,
      "pages": 85000,
      "words": 19175915,
      "lectures": 0,
      "partitions": 43,
      "period": {
        "id": "Abad 2 – 14 H",
        "en": "2–14 c. AH",
        "ar": "القرن ٢–١٤ هـ"
      }
    },
    "metadataKey": "aqidah"
  },
  {
    "id": "thabaqat-tarajim",
    "sourceId": "thabaqat_tarajim",
    "index": 19,
    "name": {
      "id": "Thabaqat & Rijalul Hadits",
      "en": "Biographical Literature",
      "ar": "التراجم والطبقات ورجال الحديث والجرح والتعديل"
    },
    "arabic": "التراجم والطبقات",
    "group": "history",
    "description": {
      "id": "Kenali perawi, fuqaha, dan ulama melalui kitab thabaqat serta tarajim. Telusuri Tahdzibut Tahdzib dan Siyar A’lamin Nubala untuk membaca jaringan guru-murid dan catatan perawi.",
      "en": "Explore narrators, jurists, and scholars through biographical dictionaries. Read Tahdhīb al-Tahdhīb and Siyar Aʿlām al-Nubalāʾ for teaching networks and narrator assessments.",
      "ar": "تعرّف إلى الرواة والفقهاء والعلماء في كتب الطبقات والتراجم، واستعن بتهذيب التهذيب وسير أعلام النبلاء في تتبّع الشيوخ والتلاميذ وأحوال الرواة."
    },
    "source": "metadata_modul_lengkap.json (counts), metadata_training_seluruh_ai.json (partitions), supplied project data 2026-09-20",
    "countsPublished": true,
    "status": "active",
    "appAgentId": "thabaqat_rijal",
    "variant": "standard",
    "metadata": {
      "books": 492,
      "volumes": 1348,
      "volumesLowerBound": false,
      "pages": 420000,
      "words": 130494140,
      "lectures": 0,
      "partitions": 279,
      "period": {
        "id": "Abad 1 – 14 H",
        "en": "1–14 c. AH",
        "ar": "القرن ١–١٤ هـ"
      }
    },
    "metadataKey": "thabaqat_tarajim"
  },
  {
    "id": "bibliografi-faharis",
    "sourceId": "bibliografi_faharis",
    "index": 20,
    "name": {
      "id": "Bibliografi & Tahqiq Turath",
      "en": "Bibliography & Textual Editing",
      "ar": "فهارس الكتب والأدلة والمخطوطات ومناهج التحقيق"
    },
    "arabic": "فهارس التراث",
    "group": "language",
    "description": {
      "id": "Telusuri judul, pengarang, manuskrip, dan riwayat cetakan melalui Kasyfuz Zhunun serta kamus bibliografi. Pelajari metode tahqiq dan pemeriksaan penisbatan karya.",
      "en": "Trace titles, authors, manuscripts, and publication histories through Kashf al-Ẓunūn and bibliographical dictionaries. Study textual editing and the assessment of authorship.",
      "ar": "تتبّع العناوين والمؤلفين والمخطوطات وتاريخ الطبعات في كشف الظنون والمعاجم الببليوغرافية، وادرس مناهج التحقيق وفحص نسبة المؤلفات."
    },
    "source": "metadata_modul_lengkap.json (counts), metadata_training_seluruh_ai.json (partitions), supplied project data 2026-09-20",
    "countsPublished": true,
    "status": "active",
    "appAgentId": "bibliografi_faharis",
    "variant": "standard",
    "metadata": {
      "books": 86,
      "volumes": 264,
      "volumesLowerBound": false,
      "pages": 110000,
      "words": 19977431,
      "lectures": 0,
      "partitions": 45,
      "period": {
        "id": "Abad 4 – 14 H",
        "en": "4–14 c. AH",
        "ar": "القرن ٤–١٤ هـ"
      }
    },
    "metadataKey": "bibliografi_faharis"
  },
  {
    "id": "habib-umar",
    "sourceId": "habib_umar",
    "index": 21,
    "name": {
      "id": "Khazanah Habib Umar",
      "en": "Habib Umar Collection",
      "ar": "خزانة الحبيب عمر"
    },
    "arabic": "خزانة الحبيب عمر",
    "group": "special",
    "description": {
      "id": "Khazanah dars, fatwa, risalah dakwah, dan mutaba’ah ilmiah Al-Habib Umar bin Hafidz dari Tarim, Hadramaut. Koleksi sedang dipersiapkan untuk telaah yang tertata.",
      "en": "Lessons, fatwas, writings on daʿwah, and scholarly guidance from Habib Umar bin Hafiz of Tarim, Hadramaut. The collection is being prepared for structured study.",
      "ar": "خزانة الدروس والفتاوى ورسائل الدعوة والمتابعات العلمية للحبيب عمر بن حفيظ بتريم، حضرموت. يجري إعداد المجموعة للمطالعة المنظمة."
    },
    "status": "preparing",
    "source": "App scholar corpus is locked",
    "countsPublished": false,
    "appAgentId": "habib_umar",
    "variant": "standard"
  }
]
```

## src/metadata.mjs

```javascript
import {escapeHtml as e, pick} from './core.mjs';
import {tr} from './copy.mjs';

export const number = (value, locale, digits=0) => new Intl.NumberFormat(
  {id:'id-ID', en:'en-US', ar:'ar-EG'}[locale], {maximumFractionDigits:digits}
).format(value);

export function collectionTotals(catalog) {
  return catalog.filter(c => c.status === 'active' && c.metadata).reduce((sum,c) => {
    sum.disciplines++;
    for (const key of ['books','volumes','pages','words','partitions']) sum[key] += c.metadata[key];
    sum.volumesLowerBound ||= c.metadata.volumesLowerBound;
    return sum;
  }, {disciplines:0,books:0,volumes:0,pages:0,words:0,partitions:0,volumesLowerBound:false});
}

export function collectionMetadata(l,c) {
  if (!c.metadata || c.status !== 'active') return '';
  const m=c.metadata;
  const values=[
    [number(m.books,l),'metaBooks'],
    [number(m.volumes,l)+(m.volumesLowerBound?'+':''),'metaVolumes'],
    [number(m.pages,l),'metaPages'],
    [number(m.words/1e6,l,1)+' '+tr(l,'metaMillion'),'metaWords'],
    ...(m.lectures?[[number(m.lectures,l),'metaLectures']]:[])
  ];
  return `<ul class="collection-metrics" aria-label="${tr(l,'collectionMetrics')}">${values.map(([value,key])=>`<li><bdi>${e(value)}</bdi> <span>${tr(l,key)}</span></li>`).join('')}<li class="metric-period">${e(pick(m.period,l))}</li></ul>`;
}

export function collectionStats(l,catalog) {
  const totals=collectionTotals(catalog);
  const rows=[
    ['disciplines','metricDisciplines'],['books','metricBooks'],['volumes','metricVolumes'],
    ['pages','metricPages'],['words','metricWords'],['partitions','metricPartitions']
  ];
  return `<section class="collection-scale" aria-labelledby="scale-title"><div class="container">
    <p class="eyebrow">${tr(l,'statsEyebrow')}</p><h2 id="scale-title" class="sr-only">${tr(l,'statsTitle')}</h2>
    <dl class="scale-grid">${rows.map(([key,label])=>{
      const exact=number(totals[key],l)+(key==='volumes'&&totals.volumesLowerBound?'+':'');
      const prominent=key==='pages'?number(Math.floor(totals[key]/1e5)/10,l,1)+'+':key==='words'?number(Math.floor(totals[key]/1e7)/100,l,2)+'+':exact;
      const unit=key==='pages'?tr(l,'metaMillion'):key==='words'?tr(l,'metaBillion'):'';
      return `<div data-metric="${key}" data-value="${totals[key]}"><dt>${tr(l,label)}</dt><dd><bdi>${prominent}${unit?` <span class="scale-unit">${unit}</span>`:''}</bdi>${prominent!==exact?`<small><bdi>${exact}</bdi></small>`:''}</dd></div>`;
    }).join('')}</dl><p class="fine-print scale-source">${tr(l,'statsSource')} <span>${tr(l,'statsEra')}</span></p>
  </div></section>`;
}

export function validateCatalogMetadata(catalog,modules,training) {
  const errors=[],seen=new Set();
  for(const c of catalog.filter(c=>c.status==='active')){
    const source=modules[c.metadataKey],partitions=training[c.metadataKey];
    if(!source||!partitions){errors.push(`Metadata source missing: ${c.id}`);continue;}
    if(seen.has(c.metadataKey))errors.push(`Duplicate module: ${c.metadataKey}`);
    seen.add(c.metadataKey);
    const expected={books:source.total_kitab,volumes:Number(String(source.total_jilid).replace(/\D/g,'')),pages:source.total_halaman,words:source.total_kata,lectures:source.total_dars||0,partitions:partitions.total_partisi_notebooklm};
    for(const [key,value] of Object.entries(expected)){
      if(!Number.isSafeInteger(value)||value<0||c.metadata?.[key]!==value)errors.push(`Metadata mismatch: ${c.id}.${key}`);
    }
    if(c.metadata?.volumesLowerBound!==String(source.total_jilid).includes('+'))errors.push(`Volume precision mismatch: ${c.id}`);
    if(c.metadata?.period?.id!==source.rentang_masa)errors.push(`Period mismatch: ${c.id}`);
    for(const locale of ['id','en','ar'])if(!c.metadata?.period?.[locale]?.trim())errors.push(`Period translation missing: ${c.id}.${locale}`);
  }
  if(seen.size!==Object.keys(modules).length)errors.push('Active catalogue does not cover all source modules.');
  return errors;
}
```

## src/membership.mjs

```javascript
import {escapeHtml as e,pathFor,safeExternal} from './core.mjs';
import {tr} from './copy.mjs';
import {arrow,link,eyebrow} from './render.mjs';
import {number} from './metadata.mjs';

export function membership(l,config,{compact=false}={}) {
  const entry=config.plans.find(p=>p.id==='tholib')||config.plans[0];
  const price=entry?number(entry.price,l):'';
  const href=config.appLinksVerified&&safeExternal(config.appDeepLinkBase)
    ?new URL('access',config.appDeepLinkBase.replace(/\/?$/,'/')).href:pathFor(l,'download');
  return `<div class="membership-banner">
    <div class="membership-message">${eyebrow(tr(l,'memberEyebrow'))}
      <h2>${tr(l,'accessTitle')}</h2>
      <p class="membership-price"><span>${tr(l,'memberFrom')}</span> <bdi>${l==='id'?'Rp ':''}${price}${l!=='id'?' IDR':''}</bdi> <span>${tr(l,'memberPerMonth')}</span></p>
      <p class="membership-description">${tr(l,'accessSub')}</p>
      <p class="membership-payments"><bdi>DOKU</bdi><span>QRIS</span><span>${tr(l,'paymentVA')}</span><span>${tr(l,'paymentWallet')}</span></p>
    </div>
    <div class="membership-action"><a class="button" href="${e(href)}">${tr(l,'chooseMembership')}${arrow}</a><p>${tr(l,'memberManual')}</p>${link(l,'billing',tr(l,'memberReview'))}</div>
  </div>
  ${compact?'':`<p class="fine-print membership-detail">${tr(l,'memberMethods')}</p><div class="refund-panel">${eyebrow(tr(l,'billing'))}<p>${tr(l,'memberRefund')}</p>${link(l,'billing',tr(l,'billing'))}</div>`}`;
}
```

## src/render.mjs

```javascript
import {escapeHtml as e,pathFor,locales,pick,safeExternal} from './core.mjs';
import {tr,localized} from './copy.mjs';
import {collectionMetadata} from './metadata.mjs';
export const arrow='<svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 12h15m-6-6 6 6-6 6" stroke="currentColor" stroke-width="1.5"/></svg>';
export const icons={sun:'<circle cx="12" cy="12" r="4"/><path d="M12 2v2m0 16v2M2 12h2m16 0h2M5 5l1.5 1.5m11 11L19 19M5 19l1.5-1.5m11-11L19 5"/>',menu:'<path d="M4 8h16M4 16h16"/>',close:'<path d="m6 6 12 12M6 18 18 6"/>',search:'<circle cx="10.5" cy="10.5" r="6.5"/><path d="m16 16 5 5"/>',download:'<path d="M12 3v12m-5-5 5 5 5-5M4 17v4h16v-4"/>',plus:'<path d="M12 5v14M5 12h14"/>',book:'<path d="M12 6v15M12 6C8 3 4 4 2 5v14c3-1 6-1 10 2 4-3 7-3 10-2V5c-3-1-6-2-10 1Z"/>',check:'<path d="m5 12 4 4L19 6"/>'};
export const icon=(k)=>`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">${icons[k]||icons.book}</svg>`;
export const link=(l,route,label,cls='text-link')=>`<a class="${cls}" href="${pathFor(l,route)}">${e(label)}${cls.includes('button')?'':arrow}</a>`;
export const button=(l,route,label,secondary=false)=>link(l,route,label,`button ${secondary?'button-secondary':''}`);
export const eyebrow=(s)=>`<p class="eyebrow">${e(s)}</p>`;
export const nl=s=>e(s).replaceAll('\n','<br>');
export function pageHead(l,label,title,desc='',dark=false){return `<section class="page-head ${dark?'dark':''}"><div class="container">${eyebrow(label)}<h1>${nl(title)}</h1>${desc?`<p class="lede">${e(desc)}</p>`:''}</div></section>`;}
export function collectionCard(l,c){return `<a class="collection-card" data-spotlight href="${pathFor(l,'library/'+c.id)}"><div class="collection-top"><span class="serial">${String(c.index).padStart(2,'0')}</span><span class="availability ${c.status==='preparing'?'is-preparing':''}">${tr(l,c.status==='preparing'?'preparing':'available')}</span>${arrow}</div><p class="collection-ar" lang="ar" dir="rtl">${e(c.arabic)}</p><div class="collection-copy"><h3>${e(pick(c.name,l))}</h3><p>${e(pick(c.description,l))}</p></div>${collectionMetadata(l,c)}</a>`;}
export function empty(l,title,body='',route='help',cta='help'){return `<div class="empty-state">${icon('book')}<h2>${e(title)}</h2>${body?`<p>${e(body)}</p>`:''}${link(l,route,tr(l,cta))}</div>`;}
export function faqBlock(l,items){return `<div class="faq-list" data-faq>${items.map(x=>`<details><summary><span>${e(localized(x.q,l))}</span>${icon('plus')}</summary><div class="faq-answer"><p>${e(localized(x.a,l))}</p></div></details>`).join('')}</div>`;}
const nav=[['library','library'],['how-it-works','how'],['access','access'],['ai-guidelines','navAdab']];
const footerGroups=[['product',[['library','library'],['tahawwulat','tahawwulat'],['access','access'],['download','download'],['releases','releases']]],['scholarship',[['research','research'],['research/methodology','methods'],['ai-guidelines','aiGuidelines'],['sources-and-rights','rights']]],['help',[['help','help'],['contact','contact'],['report','report'],['account-deletion','deletion'],['security','security']]],['information',[['about','about'],['privacy','privacy'],['terms','terms'],['billing','billing'],['accessibility','accessibility']]]];
export function layout({l,route,title,description,body,config,production=false}){
 const canonical=config.canonicalUrl?new URL(pathFor(l,route),config.canonicalUrl).href:null;
 const navHtml=nav.map(([r,k])=>`<a href="${pathFor(l,r)}" ${route===r||route.startsWith(r+'/')?'aria-current="page"':''}>${tr(l,k)}</a>`).join('');
 const langLinks=locales.map(loc=>`<a href="${pathFor(loc,route)}" lang="${loc}" dir="${loc==='ar'?'rtl':'ltr'}" data-locale="${loc}" ${loc===l?'aria-current="true"':''}><span>${{id:'Bahasa Indonesia',en:'English',ar:'العربية'}[loc]}</span><span>${loc.toUpperCase()}${loc===l?' ✓':''}</span></a>`).join('');
 return `<!doctype html><html lang="${l}" dir="${l==='ar'?'rtl':'ltr'}"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>${e(title)} — OpenTurath</title><meta name="description" content="${e(description)}"><meta name="theme-color" content="#0a0908"><meta name="color-scheme" content="light dark">${(!production||route==='404')?'<meta name="robots" content="noindex,nofollow">':''}${canonical?`<link rel="canonical" href="${e(canonical)}">${locales.map(loc=>`<link rel="alternate" hreflang="${loc}" href="${e(new URL(pathFor(loc,route),config.canonicalUrl).href)}">`).join('')}<link rel="alternate" hreflang="x-default" href="${e(config.canonicalUrl)}">`:''}<meta property="og:type" content="website"><meta property="og:site_name" content="OpenTurath"><meta property="og:title" content="${e(title)} — OpenTurath"><meta property="og:description" content="${e(description)}">${canonical?`<meta property="og:url" content="${e(canonical)}"><script type="application/ld+json">${JSON.stringify({'@context':'https://schema.org','@type':route?'WebPage':'WebSite',name:route?title:'OpenTurath',description,url:canonical,inLanguage:l}).replaceAll('<','\\u003c')}</script>`:''}<meta name="twitter:card" content="summary_large_image">${canonical?`<meta property="og:image" content="${e(new URL('/assets/social-card.png',config.canonicalUrl).href)}"><meta property="og:image:width" content="1200"><meta property="og:image:height" content="630">`:""}<link rel="icon" href="/assets/favicon.svg" type="image/svg+xml"><link rel="preload" href="/assets/fonts/${l==='ar'?'scheherazade-new-arabic-400-normal':'outfit-latin-400-normal'}.woff2" as="font" type="font/woff2" crossorigin><link rel="stylesheet" href="/assets/fonts.css"><link rel="stylesheet" href="/assets/site.css"><link rel="stylesheet" href="/assets/immersive.css"><script src="/assets/theme.js"></script><script src="/assets/site.js" defer></script></head><body data-locale="${l}" data-route="${e(route)}"><a class="skip-link" href="#main">${tr(l,'skip')}</a><header class="site-header"><div class="nav-inner"><a class="wordmark" href="${pathFor(l)}" aria-label="OpenTurath — ${tr(l,'home')}" dir="ltr"><span class="brand-mark" aria-hidden="true"></span><span>OpenTurath</span></a><nav class="desktop-nav" aria-label="${tr(l,'menu')}">${navHtml}</nav><div class="nav-tools"><button class="icon-button theme-toggle" type="button" aria-label="${tr(l,'theme')}">${icon('sun')}</button><button type="button" class="locale-trigger" data-dialog="language-dialog" aria-label="${tr(l,'language')}">${l.toUpperCase()}<span aria-hidden="true">⌄</span></button><a class="button nav-download button-secondary" href="${pathFor(l,'download')}" aria-label="${tr(l,'download')}">${icon('download')}<span>${tr(l,'navDownload')}</span></a><button class="icon-button mobile-menu" data-dialog="menu-dialog" aria-label="${tr(l,'menu')}">${icon('menu')}</button></div></div></header>
 <noscript><nav class="container no-script-nav" aria-label="${tr(l,'menu')}">${navHtml}</nav></noscript><main id="main" tabindex="-1">${route?`<nav class="breadcrumb container" aria-label="${localized(["Jejak halaman","Breadcrumb","مسار الصفحة"],l)}"><a href="${pathFor(l)}">${tr(l,'home')}</a><span aria-hidden="true">/</span>${route.includes('/')?`<a href="${pathFor(l,route.startsWith('books/')?'library':route.split('/')[0])}">${tr(l,route.startsWith('books/')?'library':route.split('/')[0])}</a><span aria-hidden="true">/</span>`:''}<span aria-current="page">${e(title)}</span></nav>`:''}${body}</main>
 <footer class="site-footer"><div class="container"><div class="footer-top"><a class="wordmark" href="${pathFor(l)}" dir="ltr"><span class="brand-mark" aria-hidden="true"></span><span>OpenTurath</span></a><p dir="ltr">AI for Islamic Scholarship</p></div><div class="footer-grid">${footerGroups.map(([k,links])=>`<div><p class="footer-heading">${tr(l,k)}</p>${links.map(([r,t])=>`<a href="${pathFor(l,r)}">${tr(l,t)}</a>`).join('')}</div>`).join('')}</div><noscript><div class="language-list">${langLinks}</div></noscript><div class="footer-bottom"><span>© ${new Date().getFullYear()} OpenTurath${config.operator.name?' · '+e(config.operator.name):''}</span><p>${tr(l,'privacyShort')}</p><button class="quiet-button" data-dialog="language-dialog">${{id:'Bahasa Indonesia',en:'English',ar:'العربية'}[l]}</button></div></div></footer>
 <dialog id="language-dialog" class="small-dialog"><div class="dialog-head"><h2>${tr(l,'chooseLanguage')}</h2><button class="icon-button" data-close aria-label="${tr(l,'close')}">${icon('close')}</button></div><div class="language-list">${langLinks}</div></dialog>
 <dialog id="menu-dialog" class="menu-dialog"><div class="dialog-head"><span class="wordmark" dir="ltr">OpenTurath.</span><button class="icon-button" data-close aria-label="${tr(l,'close')}">${icon('close')}</button></div><nav>${navHtml}<a href="${pathFor(l,'access')}">${tr(l,'access')}</a><a href="${pathFor(l,'help')}">${tr(l,'help')}</a></nav><div class="language-list">${langLinks}</div></dialog><div id="toast" class="toast" role="status" aria-live="polite"></div><button class="focus-exit button" type="button" data-focus-exit>${tr(l,'exitFocus')}</button></body></html>`;
}
```

## src/pages.mjs

```javascript
import {collectionMetadata} from './metadata.mjs';
import {membership} from './membership.mjs';
import {immersiveHome} from './home.mjs';
import {escapeHtml as e,pick,pathFor,markdown,safeExternal} from './core.mjs';
import {tr,localized,faq} from './copy.mjs';
import {articles} from './articles.mjs';
import {arrow,icon,link,button,eyebrow,nl,pageHead,collectionCard,empty,faqBlock} from './render.mjs';
const quote='وَلَوْ مَسَّ بِيَدِهِ مَا شَاءَ فَوْقَ بَدَنِهَا مِنْ ثَوْبٍ رَقِيقٍ';
const quoteRef='الأم · ج١، ص٣٠ · Q001';
const desc=(l)=>tr(l,'heroSub');
const intro=(l,k,title,sub)=>pageHead(l,k,title,sub);
export function allRoutes(data){return ['', 'library','research','research/q001','research/corrections','download','releases','access','help','contact','report',...Object.keys(articles),...data.catalog.map(c=>'library/'+c.id),...data.books.map(b=>'books/'+b.id),...data.config.releaseNotes.map(r=>'releases/'+r.version),'404'];}
function study(l){return `<div class="study-spread"><div class="study-question">${eyebrow(tr(l,'example')+' / Q001')}<span class="small-label">${tr(l,'originalQuery')}</span><p class="question-text" lang="id" dir="ltr">Bagaimana mazhab Syafi'i menjelaskan hukum bersentuhan kulit antara laki-laki dan perempuan non-mahram dalam kaitannya dengan wudhu? Jelaskan batasan dan pengecualiannya.</p>${link(l,'research/q001',tr(l,'readFull'))}</div><div class="study-source"><div class="source-meta"><span>${tr(l,'sourceText')}</span><span dir="ltr">03 / 10</span></div><blockquote lang="ar" dir="rtl">${quote}</blockquote><div class="citation-line"><span lang="ar" dir="rtl">الأم، ج١، ص٣٠</span><button class="text-link" data-dialog="source-dialog">${tr(l,'openSource')}${arrow}</button></div></div></div>`;}
function sourceDialog(l){return `<dialog class="source-dialog" id="source-dialog"><div class="dialog-head"><h2>${tr(l,'bibliography')}</h2><button class="icon-button" data-close aria-label="${tr(l,'close')}">${icon('close')}</button></div>${eyebrow('Q001 · 03')}<h3 class="arabic-display" lang="ar" dir="rtl">الأم</h3><blockquote lang="ar" dir="rtl">${quote}</blockquote><p class="status-label">${tr(l,'unverified')}</p><p>${tr(l,'sourceNote')}</p><dl class="metadata"><dt>${tr(l,'author')}</dt><dd lang="ar" dir="rtl">الإمام الشافعي</dd><dt>${tr(l,'locator')}</dt><dd lang="ar" dir="rtl">ج١، ص٣٠</dd><dt>${tr(l,'edition')}</dt><dd>${tr(l,'unknown')}</dd></dl><div class="button-row"><button class="button" data-copy="${e(quote+'\n'+quoteRef)}">${tr(l,'copy')}</button>${link(l,'books/al-umm',tr(l,'bibliography'))}</div></dialog>`;}
function home(l,d){return immersiveHome(l,d,sourceDialog(l));}
function downloadCta(l){return `<section class="download-cta"><div class="container">${eyebrow('OpenTurath')}<h2>${nl(tr(l,'downloadTitle'))}</h2><p>${tr(l,'downloadSub')}</p>${button(l,'download',tr(l,'download'))}</div></section>`;}
function library(l,d){let groupKeys=['all','fiqh','hadith','quran','language','history','spirituality','theology','special'];return `${intro(l,tr(l,'library'),tr(l,'fieldTitle'),tr(l,'fieldSub'))}<section class="container section compact-top"><form class="search-form" data-search-form><label class="search-box">${icon('search')}<span class="sr-only">${tr(l,'search')}</span><input type="search" name="q" data-search placeholder="${tr(l,'search')}" autocomplete="off"></label><div class="filter-list" role="group" aria-label="${tr(l,'collections')}">${groupKeys.map((g,i)=>`<button type="button" data-filter="${g}" aria-pressed="${i===0}">${tr(l,g==='language'?'languageGroup':g==='special'?'specialGroup':g)}</button>`).join('')}</div><button type="reset" class="quiet-button">${tr(l,'clear')}</button><output class="result-count" data-count aria-live="polite">${d.catalog.length} ${tr(l,'results')}</output></form><div class="collection-grid full-grid">${d.catalog.map(c=>`<div class="bento-${c.variant||'standard'}" data-search-item data-search-text="${e(Object.values(c.name).join(' ')+' '+Object.values(c.description).join(' '))}" data-group="${c.group}">${collectionCard(l,c)}</div>`).join('')}</div><p class="empty-search" data-empty hidden>${tr(l,'noResults')}</p><p class="fine-print catalog-note">${tr(l,'catalogNote')}</p><div class="section-heading spaced">${eyebrow('Q001')}<h2>${tr(l,'books')}</h2></div><div class="book-list">${d.books.map(b=>`<div data-search-item data-search-text="${e(b.arabic+' '+b.title+' '+(b.author||'')+' '+(b.authorArabic||''))}" data-group="fiqh">${bookRow(l,b)}</div>`).join('')}</div></section>`;}
const bookRow=(l,b)=>`<a class="book-row" href="${pathFor(l,'books/'+b.id)}"><span class="book-index">${icon('book')}</span><div><h3 lang="ar" dir="rtl">${e(b.arabic)}</h3><p>${e(l==='ar'?(b.authorArabic||tr(l,'unverified')):b.title+(b.author?' · '+b.author:''))}</p></div>${arrow}</a>`;
function collection(l,c,d){if(c.status==='preparing')return `${pageHead(l,tr(l,'preparing'),pick(c.name,l),pick(c.description,l))}<section class="container section compact-top"><div class="notice"><p>${tr(l,'preparingBody')}</p>${link(l,'releases',tr(l,'releases'))}</div>${link(l,'library',tr(l,'allLibrary'))}</section>`;return `${pageHead(l,tr(l,'library'),pick(c.name,l),pick(c.description,l))}<section class="container section compact-top two-column"><div class="reading-content"><p class="arabic-display" lang="ar" dir="rtl">${e(c.arabic)}</p>${collectionMetadata(l,c)}<h2>${tr(l,'contents')}</h2><p>${e(pick(c.description,l))}</p><p>${tr(l,'noFullBooks')}</p>${c.id==='fiqh-syafii'?`<h2>${tr(l,'books')}</h2><div class="book-list">${d.books.map(b=>bookRow(l,b)).join('')}</div>`:''}</div><aside class="side-note">${eyebrow(tr(l,'appAccess'))}<h2>${tr(l,'accessTitle')}</h2><p>${tr(l,'accessSub')}</p>${d.config.appDeepLinkBase&&d.config.appLinksVerified?`<a class="button" href="${e(new URL('collection/'+c.id,d.config.appDeepLinkBase.replace(/\/?$/,'/')).href)}">${localized(['Buka koleksi di aplikasi','Open collection in the app','افتح المجموعة في التطبيق'],l)}</a>`:button(l,'download',tr(l,'download'))}${link(l,'access',tr(l,'access'))}<hr><p class="fine-print">${tr(l,'catalogNote')}</p></aside></section>${downloadCta(l)}`;}
function book(l,b){return `${pageHead(l,tr(l,'bibliography'),l==='ar'?b.arabic:b.title,b.author||'')}<section class="container section compact-top two-column"><div><div class="bibliography-sheet"><h2 lang="ar" dir="rtl">${e(b.arabic)}</h2><dl class="metadata"><dt>${tr(l,'author')}</dt><dd>${e(l==='ar'?(b.authorArabic||tr(l,'unverified')):(b.author||tr(l,'unverified')))}</dd><dt>${tr(l,'edition')}</dt><dd>${tr(l,'unknown')}</dd><dt>${tr(l,'locator')}</dt><dd lang="ar" dir="rtl">${e(b.locator)}</dd><dt>${tr(l,'reviewStatus')}</dt><dd>${tr(l,'unverified')}</dd></dl></div><p class="notice">${tr(l,'verifyNote')}</p></div><aside class="side-note">${eyebrow('Q001')}<h2>${tr(l,'topic')}</h2>${link(l,'research/q001',tr(l,'linkedCase'))}${link(l,'report',tr(l,'report'))}</aside></section>`;}
function research(l,d){return `${pageHead(l,tr(l,'research'),tr(l,'researchTitle'),tr(l,'researchSub'))}<section class="container section compact-top"><a class="research-case" href="${pathFor(l,'research/q001')}"><div><span class="serial">Q001</span><p class="status-label">${tr(l,'archive')}</p></div><div><h2>${tr(l,'topic')}</h2><p>${tr(l,'scopeNote')}</p><div class="product-list">${d.evaluation.runs.map(r=>`<span dir="ltr">${e(r.name)}</span>`).join('')}</div></div>${arrow}</a><div class="two-column spaced"><div><h2>${tr(l,'methods')}</h2><p>${tr(l,'researchSub')}</p>${link(l,'research/methodology',tr(l,'goMethod'))}</div><div class="notice"><h3>${tr(l,'reviewStatus')}</h3><p>${tr(l,'reviewDetail')}</p></div></div></section>`;}
function casePage(l,d){const runs=d.evaluation.runs;const options=(active)=>runs.map(r=>`<option value="${r.id}" ${r.id===active?'selected':''}>${e(r.name)}</option>`).join('');return `${pageHead(l,'Q001 · '+tr(l,'archive'),tr(l,'topic'),tr(l,'scopeNote'))}<section class="container case-section"><div class="question-box">${eyebrow(tr(l,'originalQuery'))}<p lang="id" dir="ltr">${e(d.evaluation.question)}</p><div class="case-metadata"><span>${tr(l,'date')}: ${e(d.evaluation.date||tr(l,'notRecorded'))}</span><span>${tr(l,'reviewStatus')}: ${tr(l,'unverified')}</span></div></div><div class="reader-toolbar"><div><button class="quiet-button" data-focus>${tr(l,'focus')}</button><button class="icon-button" data-font="-1" aria-label="${tr(l,'decreaseText')}">A−</button><button class="icon-button" data-font="1" aria-label="${tr(l,'increaseText')}">A+</button></div><a class="quiet-button" href="/assets/q001-original.md" download>${tr(l,'archiveDownload')}</a></div><p class="fine-print">${tr(l,'originalLanguage')}</p><div class="comparison-mobile-tabs" role="tablist" aria-label="${tr(l,'compareWith')}"><button role="tab" id="compare-tab-left" aria-controls="compare-left" aria-selected="true" data-mobile-tab="left">OpenTurath</button><button role="tab" id="compare-tab-right" aria-controls="compare-right" aria-selected="false" data-mobile-tab="right" tabindex="-1">Qaf AI</button></div><div class="comparison-workspace" data-compare><section class="answer-column" id="compare-left"><label class="answer-picker">${tr(l,'original')}<select data-answer-select="left">${options('openturath')}</select></label><div data-answer-slot="left"></div></section><section class="answer-column" id="compare-right"><label class="answer-picker">${tr(l,'compareWith')}<select data-answer-select="right">${options('qaf')}</select></label><div data-answer-slot="right"></div></section></div>${dimensionsPanel(l)}${evidencePanel(l,d)}${runs.map(r=>`<template id="answer-${r.id}"><div class="answer-provenance"><span dir="ltr">${e(r.name)}</span><span>${tr(l,'original')}</span></div><p class="fine-print">${localized(["Model, tanggal, paket & kondisi uji: tidak tercatat.","Model, date, plan & test conditions: not recorded.","النموذج والتاريخ والخطة وظروف الاختبار: غير مسجّلة."],l)}</p><article class="answer-text" lang="id" dir="ltr">${markdown(r.text)}</article><div class="answer-end"><span>${[...r.text].length.toLocaleString(l)} ${tr(l,'chars')}</span>${safeExternal(r.url)?`<a href="${e(r.url)}" target="_blank" rel="noopener noreferrer">${tr(l,'sourceConversation')} ↗</a>`:''}</div></template>`).join('')}<noscript>${runs.map(r=>`<details><summary>${e(r.name)}</summary><article class="answer-text" lang="id" dir="ltr">${markdown(r.text)}</article></details>`).join('')}</noscript><p class="fine-print">${tr(l,'sourceAccess')}</p><div class="review-block" id="review"><div><h2>${tr(l,'notes')}</h2><p>${tr(l,'reviewDetail')}</p><p>${tr(l,'issuesDetail')}</p>${link(l,'research/methodology',tr(l,'goMethod'))}</div><div><h2>${tr(l,'references')}</h2><div class="book-list">${d.books.map(b=>bookRow(l,b)).join('')}</div></div></div>${link(l,'report',tr(l,'report'))}</section>`;}
function article(l,route,a,d){return `${pageHead(l,tr(l,a.key),localized(a.intro,l))}<section class="container article-layout"><aside class="article-toc"><p class="eyebrow">${tr(l,'contents')}</p>${a.blocks.map((b,i)=>`<a href="#section-${i+1}">${e(localized(b.heading,l))}</a>`).join('')}${link(l,'help',tr(l,'help'))}</aside><article class="reading-content">${['terms','privacy','billing','ai-guidelines','account-deletion'].includes(route)?`<div class="policy-meta"><p class="eyebrow">${tr(l,'legalVersion')}</p><p>${tr(l,'policySummary')}</p><a class="text-link" href="/assets/kebijakan-aplikasi-v1.0.md" download>${tr(l,'legalCanonical')}${arrow}</a></div>`:''}${a.policy&&!d.config.policiesApproved?`<p class="notice">${tr(l,'policyNotice')}</p>`:''}${a.blocks.map((b,i)=>`<section id="section-${i+1}"><h2>${e(localized(b.heading,l))}</h2><p>${e(localized(b.body,l)).replaceAll('\n','<br>')}</p></section>`).join('')}${route==='about'&&d.config.operator.name?`<p>${e(d.config.operator.name)} · ${e(d.config.operator.jurisdiction)}</p>`:''}${route==='security'&&d.config.operator.securityEmail?`<a href="mailto:${e(d.config.operator.securityEmail)}">${e(d.config.operator.securityEmail)}</a>`:''}${route==='privacy'&&d.config.operator.privacyEmail?`<a href="mailto:${e(d.config.operator.privacyEmail)}">${e(d.config.operator.privacyEmail)}</a>`:''}<div class="article-end">${link(l,'report',tr(l,'report'))}${link(l,'download',tr(l,'download'))}</div></article></section>`;}
function downloads(l,d){d={...d,config:{...d.config,downloads:d.config.downloads.filter(r=>!r.revoked)}};return `${pageHead(l,'OpenTurath',tr(l,'downloadTitle'),tr(l,'downloadSub'))}<section class="container section compact-top">${d.config.downloads.length?`<div class="download-grid">${d.config.downloads.map(r=>`<article class="download-card" data-platform="${e(r.platform.toLowerCase())}"${r.comingSoon?' data-coming-soon':''}>${icon('download')}<h2>${e(r.platform)}</h2><p>${tr(l,'version')} ${e(r.version)}</p>${r.comingSoon?`<span class="coming-soon-badge">${r.unavailableReason?tr(l,'awaitingArtifact'):localized(["Segera Hadir","Coming Soon","قريبًا"],l)}</span>`:''}<p class="fine-print" data-device-hint hidden>${localized(["Saran untuk perangkat ini","Suggested for this device","مقترح لهذا الجهاز"],l)}</p><dl class="metadata"><dt>${tr(l,'minimumOS')}</dt><dd>${e(r.minimumOS)}</dd><dt>${tr(l,'releaseDate')}</dt><dd>${e(r.date)}</dd>${r.size?`<dt>${tr(l,'size')}</dt><dd>${e(r.size)}</dd>`:''}</dl>${!r.comingSoon&&safeExternal(r.url)?`<a class="button" href="${e(r.url)}" rel="noopener noreferrer" target="_blank" data-download>${tr(l,'downloadPlatform')} ${e(r.platform)}</a>`:''}${!r.comingSoon&&safeExternal(r.alternativeUrl)?`<a class="text-link" href="${e(r.alternativeUrl)}" target="_blank" rel="noopener noreferrer">${localized(['Tautan resmi alternatif','Alternative official link','رابط رسمي بديل'],l)}</a>`:''}${!r.comingSoon&&r.sha256?`<details><summary>SHA-256</summary><p class="fine-print">${tr(l,'downloadIntegrity')}</p><code class="hash" dir="ltr">${e(r.sha256)}</code></details>`:''}</article>`).join('')}</div>`:empty(l,tr(l,'releasePending'),tr(l,'releasePendingSub'),'help/install','installGuide')}${d.config.canonicalUrl?`<div class="download-qr"><img src="/assets/download-${l}.svg" width="160" height="160" alt="${localized(['Kode QR ke halaman unduh','QR code to the download page','رمز QR لصفحة التنزيل'],l)}"><div><h2>${localized(['Lanjutkan di ponsel.','Continue on your phone.','تابع على هاتفك.'],l)}</h2><a class="text-link" href="${e(new URL(pathFor(l,'download'),d.config.canonicalUrl).href)}">${tr(l,'download')}</a></div></div>`:''}<div class="download-help"><div><h2>${tr(l,'installGuide')}</h2><p>${tr(l,'downloadSub')}</p>${link(l,'help/install',tr(l,'readGuide'))}</div><div><h2>${tr(l,'releases')}</h2><p>${tr(l,'releaseDate')} · ${tr(l,'minimumOS')}</p>${link(l,'releases',tr(l,'releases'))}</div></div></section>`;}
function access(l,d){return `${pageHead(l,'OpenTurath',tr(l,'access'))}<section class="container section compact-top">${membership(l,d.config)}<div class="spaced">${faqBlock(l,faq.filter(x=>['payment','refund','account'].includes(x.id)))}</div></section>`;}
function help(l){const links=['help/install','help/references','help/account','help/access'];return `${pageHead(l,tr(l,'help'),tr(l,'helpTitle'))}<section class="container section compact-top"><form class="search-form" data-search-form><label class="search-box">${icon('search')}<span class="sr-only">${tr(l,'helpSearch')}</span><input type="search" name="q" data-search placeholder="${tr(l,'helpSearch')}"></label><output data-count class="result-count" aria-live="polite"></output></form><div class="help-grid">${links.map((r,i)=>`<a class="guide-card" data-search-item data-search-text="${e(localized(articles[r].intro,l)+' '+articles[r].blocks.map(b=>localized(b.body,l)).join(' '))}" href="${pathFor(l,r)}"><span class="serial">0${i+1}</span><h2>${e(localized(articles[r].intro,l))}</h2>${arrow}</a>`).join('')}</div><p data-empty hidden>${tr(l,'noResults')}</p><div class="spaced">${faqBlock(l,faq)}</div></section>`;}
function reportForm(l,d){return `<form class="report-form" method="post" action="/api/reports" data-report-form data-retention="${e(d.config.reports.retentionDays)}"><label>${tr(l,'subject')}<select name="topic" required>${['reportSource','reportTechnical','reportAccess','reportOther'].map((k,i)=>`<option value="${['reference','technical','access','other'][i]}">${tr(l,k)}</option>`).join('')}</select></label><label>${tr(l,'email')}<span class="field-hint">${tr(l,'emailHint')}</span><input type="email" name="email" maxlength="254" autocomplete="email"></label><label>${tr(l,'message')}<textarea name="message" rows="7" minlength="10" maxlength="10000" required aria-describedby="report-hint"></textarea></label><p id="report-hint" class="field-hint">${tr(l,'reportHint')}</p><label class="honeypot" aria-hidden="true">Website<input name="website" tabindex="-1" autocomplete="off"></label><label class="check-label"><input name="consent" type="checkbox" required><span>${tr(l,'consent')}</span></label><p class="fine-print">${d.config.reports.enabled?localized([`Laporan disimpan selama ${d.config.reports.retentionDays} hari pada layanan formulir situs.`,`Reports are stored for ${d.config.reports.retentionDays} days by the site’s form service.`,`تُحفظ البلاغات مدة ${d.config.reports.retentionDays} يومًا في خدمة النماذج بالموقع.`],l):localized(["Pengiriman melalui situs tidak aktif. Unduh salinan laporan atau gunakan alamat kontak yang tersedia.","Site submissions are disabled. Download a report copy or use the listed contact address.","الإرسال عبر الموقع غير مفعّل. نزّل نسخة من البلاغ أو استخدم عنوان التواصل المبيّن."],l)}</p><div class="button-row">${d.config.reports.enabled?`<button class="button js-required" type="submit">${tr(l,'submit')}</button>`:""}<button class="quiet-button js-required" type="button" data-save-report>${tr(l,'saveReport')}</button></div><noscript><p>${localized(["Aktifkan JavaScript untuk mengirim laporan, atau gunakan alamat kontak yang dicantumkan.","Enable JavaScript to submit a report, or use the listed contact address.","فعّل JavaScript لإرسال البلاغ، أو استخدم عنوان التواصل المبيّن."],l)}</p></noscript><p class="form-status" role="status" aria-live="polite"></p></form>`;}
function contact(l,d,isReport=false){return `${pageHead(l,tr(l,isReport?'report':'contact'),tr(l,'contactTitle'),tr(l,'contactSub'))}<section class="container section compact-top two-column"><div>${reportForm(l,d)}</div><aside class="side-note"><h2>${tr(l,'contact')}</h2>${d.config.operator.email?`<a href="mailto:${e(d.config.operator.email)}" class="contact-email">${e(d.config.operator.email)}</a>`:`<p>${tr(l,'contactPending')}</p>`}<hr>${link(l,'help',tr(l,'help'))}${link(l,'privacy',tr(l,'privacy'))}${link(l,'security',tr(l,'security'))}</aside></section>`;}
export function renderPage(l,route,d){let title=tr(l,'home'),body='';
 if(!route)body=home(l,d);
 else if(route==='library'){title=tr(l,'library');body=library(l,d);}
 else if(route.startsWith('library/')){const c=d.catalog.find(c=>route==='library/'+c.id);title=pick(c.name,l);body=collection(l,c,d);}
 else if(route.startsWith('books/')){const b=d.books.find(b=>route==='books/'+b.id);title=l==='ar'?b.arabic:b.title;body=book(l,b);}
 else if(route==='research'){title=tr(l,'research');body=research(l,d);}
 else if(route==='research/q001'){title=tr(l,'topic');body=casePage(l,d);}
 else if(route==='research/corrections'){title=tr(l,'corrections');body=pageHead(l,tr(l,'research'),title)+`<section class="container section compact-top">${d.corrections.length?d.corrections.map(c=>`<article class="reading-content"><p class="eyebrow">${e(c.id)} · ${e(c.date)}</p><h2>${e(pick(c.title,l))}</h2><p>${e(pick(c.body,l))}</p><p>${e(c.fromVersion)} → ${e(c.toVersion)}</p></article>`).join(''):empty(l,tr(l,'noCorrections'),'','research','research')}</section>`;}
 else if(articles[route]){title=tr(l,articles[route].key);body=article(l,route,articles[route],d);}
 else if(route==='download'){title=tr(l,'download');body=downloads(l,d);}
 else if(route==='access'){title=tr(l,'access');body=access(l,d);}
 else if(route==='help'){title=tr(l,'help');body=help(l);}
 else if(route==='contact'||route==='report'){title=tr(l,route);body=contact(l,d,route==='report');}
 else if(route==='releases'){title=tr(l,'releases');body=pageHead(l,'OpenTurath',title)+`<section class="container section compact-top">${d.config.releaseNotes.length?d.config.releaseNotes.map(r=>`<a class="book-row" href="${pathFor(l,'releases/'+r.version)}"><span>${e(r.version)}</span><p>${e(pick(r.summary,l))}</p>${arrow}</a>`).join(''):empty(l,tr(l,'noReleases'),'','download','download')}</section>`;}
 else if(route.startsWith('releases/')){const r=d.config.releaseNotes.find(r=>route==='releases/'+r.version);title=r.version;body=pageHead(l,tr(l,'releases'),r.version,r.date)+`<article class="container reading-content section">${markdown(pick(r.body,l))}</article>`;}
 else {title=tr(l,'notFound');body=pageHead(l,'404',title)+`<section class="container section compact-top">${button(l,'',tr(l,'backHome'))}</section>`;}
 return {title,description:route?title+'. '+desc(l):desc(l),body};
}

function evidencePanel(l,d){const word=words=>localized(words,l);return `<section class="evidence-index" id="evidence"><div class="section-heading">${eyebrow('Q001 · 10')}<h2>${word(['Ikuti jejak kutipannya.','Follow the quotations.','تتبّع النصوص المنقولة.'])}</h2><p>${word(['Sepuluh kutipan pada bagian B jawaban OpenTurath. Teks di bawah adalah keluaran yang diarsipkan; pembandingan dengan edisi sumber belum tersedia.','Ten quotations from section B of the OpenTurath answer. These are archived outputs; comparison against source editions is not yet available.','عشرة نصوص من القسم B لإجابة OpenTurath. النصوص أدناه من المخرجات المؤرشفة؛ ولم تتوفر بعد المقابلة بطبعات المصادر.'])}</p></div><div class="evidence-list">${d.evidence.map(r=>`<details id="${r.id}"><summary><span class="serial">${String(r.number).padStart(2,'0')}</span><span lang="ar" dir="rtl">${e(r.locator)}</span><span class="fine-print">${evidenceStatus(l,r.status)}</span>${icon('plus')}</summary><div class="evidence-body"><div lang="id" dir="ltr">${markdown(r.context)}</div><blockquote lang="ar" dir="rtl">${e(r.quote)}</blockquote><dl class="metadata"><dt>${word(['Rujukan dalam jawaban','Reference in the answer','الإحالة في الإجابة'])}</dt><dd lang="ar" dir="rtl">${e(r.locator)}</dd><dt>${word(['Edisi terverifikasi','Verified edition','الطبعة المتحقّق منها'])}</dt><dd>${e(r.edition||tr(l,'notRecorded'))}</dd><dt>${word(['Halaman cetak terverifikasi','Verified printed page','الصفحة المطبوعة المتحقّق منها'])}</dt><dd>${e(r.printPage||tr(l,'notRecorded'))}</dd><dt>${word(['Halaman PDF','PDF page','صفحة PDF'])}</dt><dd>${e(r.pdfPage||tr(l,'notRecorded'))}</dd><dt>${word(['Penelaah · tanggal','Reviewer · date','المراجع · التاريخ'])}</dt><dd>${e(r.reviewer||tr(l,'notRecorded'))} · ${e(r.reviewDate||tr(l,'notRecorded'))}</dd></dl>${r.note?`<p>${e(pick(r.note,l))}</p>`:''}${r.sourceText?`<blockquote lang="ar" dir="rtl">${e(r.sourceText)}</blockquote>`:''}${safeExternal(r.sourceUrl)?`<a class="text-link" href="${e(r.sourceUrl)}" target="_blank" rel="noopener noreferrer">${tr(l,'references')} ↗</a>`:''}<div class="button-row"><button class="quiet-button" data-copy="${e(r.quote+' — '+r.locator)}">${tr(l,'copy')}</button><button class="quiet-button" data-locate-quote="${r.id}">${word(['Temukan dalam jawaban','Find in the answer','اعثر عليه في الإجابة'])}</button><a class="quiet-button" href="${pathFor(l,'report')}?evidence=${r.id}">${tr(l,'report')}</a></div><template id="quote-${r.id}">${e(r.quote)}</template></div></details>`).join('')}</div><p class="fine-print">${evidenceSummary(l,d.evidence)}</p></section>`;}

function evidenceStatus(l,s){return localized({'not-reviewed':['Belum diperiksa','Not reviewed','لم يُراجع'],'matched':['Cocok','Matched','مطابق'],'partial':['Cocok sebagian','Partially matched','مطابق جزئيًّا'],'mismatch':['Tidak cocok','Mismatch','غير مطابق'],'unverifiable':['Tidak dapat diperiksa','Unverifiable','يتعذّر التحقّق']}[s]||['Belum diperiksa','Not reviewed','لم يُراجع'],l);}

function evidenceSummary(l,rows){const reviewed=rows.filter(r=>['matched','partial','mismatch'].includes(r.status)).length,matched=rows.filter(r=>r.status==='matched').length;return localized([`${matched} cocok dari ${reviewed} kutipan yang dapat dinilai; ${rows.length} kutipan tercatat. ${reviewed?'Rasio ini hanya mengenai kecocokan kutipan yang diperiksa.':'Rasio kecocokan tidak dapat dihitung karena belum ada kutipan yang dinilai.'}`,`${matched} matched out of ${reviewed} assessable quotations; ${rows.length} quotations recorded. ${reviewed?'This ratio concerns only the quotations reviewed.':'A match rate cannot be calculated because no quotations have been assessed.'}`,`${matched} مطابق من ${reviewed} نصوص قابلة للتقييم؛ مجموع النصوص المسجّلة ${rows.length}. ${reviewed?'تخص هذه النسبة النصوص المراجعة فقط.':'لا يمكن حساب نسبة المطابقة لعدم تقييم أي نص بعد.'}`],l);}
function dimensionsPanel(l){const names=[['Kecocokan kutipan','Quotation match','مطابقة النصوص'],['Ketepatan bibliografi','Bibliographic accuracy','دقة الإحالات'],['Dukungan terhadap klaim','Support for claims','إسناد الادّعاءات'],['Ketepatan pemahaman','Interpretive accuracy','دقة الفهم'],['Kelengkapan','Completeness','الاكتمال'],['Kesesuaian cakupan','Scope alignment','موافقة النطاق'],['Ketahanan','Robustness','المتانة']];return `<section class="review-dimensions"><h2>${localized(['Dimensi pemeriksaan','Review dimensions','جوانب المراجعة'],l)}</h2><p>${localized(['Belum ada penilaian terverifikasi untuk keenam jawaban pada dimensi berikut. Status ini tidak menyatakan bahwa jawabannya benar atau salah.','Verified assessments are not yet available for the six answers on these dimensions. This status does not establish that an answer is correct or incorrect.','لا تتوفر بعد تقييمات متحقّق منها للإجابات الست في هذه الجوانب. ولا تعني هذه الحالة إثبات صحة الإجابة أو خطئها.'],l)}</p><dl class="dimensions-list">${names.map(n=>`<div><dt>${localized(n,l)}</dt><dd>${tr(l,'unverified')}</dd></div>`).join('')}</dl></section>`;}
```

## public/assets/product-motion.mjs

```javascript
// Progressive enhancement: native links and details work without this module.
export function initProductMotion() {
  const reduced=matchMedia('(prefers-reduced-motion: reduce)');
  const fine=matchMedia('(hover: hover) and (pointer: fine)');
  const hero=document.querySelector('.scholar-hero');
  const art=document.querySelector('[data-hero-art]');
  let frame=0, pointer={x:0,y:0}, current={x:0,y:0};
  const update=()=>{
    frame=0;
    if(!art||reduced.matches)return;
    current.x+=(pointer.x-current.x)*.13;
    current.y+=(pointer.y-current.y)*.13;
    art.style.setProperty('--book-x',`${current.x*5}px`);
    art.style.setProperty('--book-y',`${current.y*3}px`);
    art.style.setProperty('--calligraphy-x',`${current.x*-10}px`);
    art.style.setProperty('--calligraphy-y',`${current.y*-6+Math.min(scrollY*.025,16)}px`);
    if(Math.abs(pointer.x-current.x)+Math.abs(pointer.y-current.y)>.01)frame=requestAnimationFrame(update);
  };
  const schedule=()=>{if(!frame&&!reduced.matches)frame=requestAnimationFrame(update);};
  hero?.addEventListener('pointermove',event=>{
    if(!fine.matches||reduced.matches)return;
    const rect=hero.getBoundingClientRect();
    pointer={x:(event.clientX-rect.left)/rect.width*2-1,y:(event.clientY-rect.top)/rect.height*2-1};
    schedule();
  },{passive:true});
  hero?.addEventListener('pointerleave',()=>{pointer={x:0,y:0};schedule();});
  if(hero)addEventListener('scroll',()=>{if(scrollY<hero.offsetHeight)schedule();},{passive:true});
  for(const card of document.querySelectorAll('[data-spotlight]')){
    let pending=0,position;
    card.addEventListener('pointermove',event=>{
      if(reduced.matches||!fine.matches)return;
      const rect=card.getBoundingClientRect();position={x:event.clientX-rect.left,y:event.clientY-rect.top};
      if(!pending)pending=requestAnimationFrame(()=>{
        pending=0;if(reduced.matches)return;
        card.style.setProperty('--mouse-x',`${position.x}px`);card.style.setProperty('--mouse-y',`${position.y}px`);
      });
    },{passive:true});
  }

  let observer;
  const revealAll=()=>{
    observer?.disconnect();
    document.querySelectorAll('.reveal-pending').forEach(el=>el.classList.remove('reveal-pending'));
  };
  if('IntersectionObserver' in window&&!reduced.matches){
    try{
      observer=new IntersectionObserver(entries=>{
        for(const entry of entries)if(entry.isIntersecting){entry.target.classList.remove('reveal-pending');observer.unobserve(entry.target);}
      },{threshold:.06,rootMargin:'0px 0px 40px 0px'});
      const sections=document.querySelectorAll('.editorial-heading,.membership-banner,.adab-layout,.home-faq h2');
      document.documentElement.classList.add('motion-ready');
      for(const section of sections){
        section.setAttribute('data-reveal','');
        if(section.getBoundingClientRect().top>innerHeight){section.classList.add('reveal-pending');observer.observe(section);}
      }
      // Content must fail open if a browser never delivers observer callbacks.
      setTimeout(revealAll,8000);
    }catch{revealAll();}
  }

  const animations=new Set();
  const animate=(el,frames,options)=>{
    const animation=el.animate(frames,options);animations.add(animation);
    animation.finished.catch(()=>{}).finally(()=>animations.delete(animation));
  };
  for(const list of document.querySelectorAll('[data-faq]')){
    list.addEventListener('click',event=>{
      const summary=event.target.closest('summary');
      if(!summary||!list.contains(summary)||reduced.matches||!Element.prototype.animate)return;
      event.preventDefault();
      const details=summary.parentElement;
      const moving=[...list.querySelectorAll('details'),...list.parentElement.children,document.querySelector('.site-footer')]
        .filter(el=>el&&el!==details&&el!==list&&el.getBoundingClientRect().top>details.getBoundingClientRect().top);
      const before=new Map(moving.map(el=>[el,el.getBoundingClientRect().top]));
      for(const animation of animations)animation.cancel();
      const wasOpen=details.open;
      details.open=!wasOpen;
      for(const el of moving){
        const delta=before.get(el)-el.getBoundingClientRect().top;
        if(Math.abs(delta)>.5)animate(el,[{transform:`translateY(${delta}px)`},{transform:'translateY(0)'}],{duration:420,easing:'cubic-bezier(.16,1,.3,1)'});
      }
      if(!wasOpen)animate(details.querySelector('.faq-answer'),[{opacity:0,transform:'translateY(-6px)'},{opacity:1,transform:'translateY(0)'}],{duration:330,easing:'cubic-bezier(.16,1,.3,1)'});
    });
  }
  reduced.addEventListener('change',()=>{
    if(reduced.matches){
      cancelAnimationFrame(frame);frame=0;pointer=current={x:0,y:0};
      for(const key of ['--book-x','--book-y','--calligraphy-x','--calligraphy-y'])art?.style.removeProperty(key);
      for(const animation of animations)animation.cancel();
      revealAll();
    }
  });
}
```

## scripts/download-integrity.mjs

```javascript
import fs from 'node:fs/promises';
import path from 'node:path';
import {createHash} from 'node:crypto';

// Same-origin APK URLs are part of this artifact, not remote promises.
export async function downloadIntegrityIssues(config,root) {
  const issues=[];
  for(const release of config.downloads||[]){
    if(release.revoked||release.comingSoon||release.type!=='apk')continue;
    let url;
    try{url=new URL(release.url);}catch{continue;}
    if(url.origin!==new URL(config.canonicalUrl).origin){
      issues.push('Active APK must be bundled under the canonical origin for integrity verification.');continue;
    }
    const relative=decodeURIComponent(url.pathname).replace(/^\/+/, '');
    const publicRoot=path.resolve(root,'public');
    const file=path.resolve(publicRoot,relative);
    if(!file.startsWith(publicRoot+path.sep)){issues.push('APK path escapes public directory.');continue;}
    try{
      const bytes=await fs.readFile(file);
      const hash=createHash('sha256').update(bytes).digest('hex');
      if(hash!==release.sha256)issues.push(`APK SHA-256 mismatch: ${relative}`);
      if(bytes.length!==release.sizeBytes)issues.push(`APK byte size mismatch: ${relative}`);
      if(bytes.subarray(0,4).toString('hex')!=='504b0304')issues.push(`APK is not a ZIP container: ${relative}`);
    }catch(error){issues.push(`APK file unavailable: ${relative} (${error.code||error.message})`);}
  }
  return issues;
}
```

## scripts/register-apk.mjs

```javascript
import fs from 'node:fs/promises';
import path from 'node:path';
import {createHash} from 'node:crypto';
import {execFileSync} from 'node:child_process';
const root=path.resolve(import.meta.dirname,'..');
const input=process.argv[2];
if(!input)throw Error('Usage: npm run release:apk -- /absolute/path/openturath-v1.0.51.apk');
const source=path.resolve(input);
// Inspect structure, never execute the binary. This is not a signature audit.
execFileSync('python3',['-c',
  'import sys,zipfile\nz=zipfile.ZipFile(sys.argv[1]); names=set(z.namelist()); assert "AndroidManifest.xml" in names and "classes.dex" in names, "Not an Android APK"; assert z.testzip() is None, "Corrupt APK"',source]);
const configPath=path.join(root,'site.config.json');
const config=JSON.parse(await fs.readFile(configPath,'utf8'));
const android=config.downloads.find(d=>d.type==='apk'&&d.platform==='Android');
if(!android)throw Error('Android release is not configured.');
const fileName=`openturath-v${android.version}.apk`;
if(path.basename(source)!==fileName)throw Error(`Expected ${fileName}; register the correct release file.`);
const bytes=await fs.readFile(source);
const destination=path.join(root,'public','downloads',fileName);
await fs.mkdir(path.dirname(destination),{recursive:true});
if(source!==destination)await fs.writeFile(destination,bytes);
android.sha256=createHash('sha256').update(bytes).digest('hex');
android.sizeBytes=bytes.length;
android.size=`${(bytes.length/1e6).toFixed(1)} MB`;
android.url=new URL('/downloads/'+fileName,config.canonicalUrl).href;
android.comingSoon=false;delete android.unavailableReason;
config.distribution={mode:'app-release'};
await fs.writeFile(configPath,JSON.stringify(config,null,2)+'\n');
console.log(`Registered ${fileName}: ${bytes.length} bytes. SHA-256 ${android.sha256}`);
console.log('Run npm test and npm run build:release. Confirm APK version and signing certificate on a device before distributing.');
```

## scripts/build.mjs

```javascript
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
const issues=[...releaseIssues(config),...await downloadIntegrityIssues(config,root)];
if(production&&issues.length){console.error('Production release blocked:\n'+issues.map(x=>' - '+x).join('\n'));process.exit(1);}
const data={config,catalog:await read('content/catalog.json'),books:await read('content/books.json'),evaluation:await read('content/evaluation.json'),evidence:await read('content/evidence.json'),corrections:await read('content/corrections.json')};
const metadataIssues=validateCatalogMetadata(data.catalog,await read('content/metadata/metadata_modul_lengkap.json'),await read('content/metadata/metadata_training_seluruh_ai.json'));
if(metadataIssues.length)throw new Error(metadataIssues.join('\n'));
const dist=path.join(root,'dist');await fs.mkdir(dist,{recursive:true});
// Only remove our generated directory; never touch config, source or report data.
await fs.rm(dist,{recursive:true,force:true});await fs.mkdir(dist,{recursive:true});await fs.cp(path.join(root,'public'),dist,{recursive:true});
await fs.copyFile(path.join(root,'src/copy.mjs'),path.join(dist,'assets/ui.mjs'));
await fs.copyFile(path.join(root,'src/core.mjs'),path.join(dist,'assets/core.mjs'));
await fs.copyFile(path.join(root,'content/q001-original.md'),path.join(dist,'assets/q001-original.md'));
if(config.canonicalUrl)for(const l of locales)execFileSync('python3',[path.join(root,'scripts/qr.py'),new URL(pathFor(l,'download'),config.canonicalUrl).href,path.join(dist,'assets','download-'+l+'.svg')]);
const routes=allRoutes(data);
if(new Set(routes).size!==routes.length||routes.some(r=>r&&!/^[a-zA-Z0-9][a-zA-Z0-9./-]*$/.test(r)||r.includes('..')))throw Error('Unsafe or duplicate route');
for(const l of locales)for(const route of routes){const p=renderPage(l,route,data);let html=layout({l,route,...p,config,production});html=html.replace('<script src="/assets/site.js" defer>','<script src="/assets/site.js" type="module">');const dest=path.join(dist,l,route,'index.html');await fs.mkdir(path.dirname(dest),{recursive:true});await fs.writeFile(dest,html);}
const languagePage=`<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>OpenTurath — AI For Islamic Scholarship.</title><meta name="description" content="Explore OpenTurath in Bahasa Indonesia, English or العربية.">${production?`<link rel="canonical" href="${e(config.canonicalUrl)}">`:'<meta name="robots" content="noindex,nofollow">'}<link rel="stylesheet" href="/assets/fonts.css"><link rel="stylesheet" href="/assets/site.css"><link rel="stylesheet" href="/assets/immersive.css"><link rel="icon" href="/assets/favicon.svg"><script src="/assets/theme.js"></script><script src="/assets/entry.js" defer></script></head><body><main class="choose-language"><div class="wordmark">OpenTurath.</div><p class="eyebrow">AI For Islamic Scholarship.</p><h1>Welcome.</h1><div class="language-list"><a href="/id/" lang="id"><span>Bahasa Indonesia</span><span>ID →</span></a><a href="/en/" lang="en"><span>English</span><span>EN →</span></a><a href="/ar/" lang="ar" dir="rtl"><span>العربية</span><span>AR ←</span></a></div></main></body></html>`;
await fs.writeFile(path.join(dist,'index.html'),languagePage);
await fs.copyFile(path.join(dist,'id/404/index.html'),path.join(dist,'404.html'));
const urls=config.canonicalUrl?locales.flatMap(l=>routes.filter(r=>r!=='404').map(r=>new URL(pathFor(l,r),config.canonicalUrl).href)):[];
await fs.writeFile(path.join(dist,'sitemap.xml'),`<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">${urls.map(u=>`<url><loc>${e(u)}</loc></url>`).join('')}</urlset>`);
await fs.writeFile(path.join(dist,'robots.txt'),production?`User-agent: *\nAllow: /\nDisallow: /api/\nSitemap: ${config.canonicalUrl.replace(/\/$/,'')}/sitemap.xml\n`:'User-agent: *\nDisallow: /\n');
await fs.writeFile(path.join(dist,'_headers'),`/*\n  X-Content-Type-Options: nosniff\n  Referrer-Policy: strict-origin-when-cross-origin\n  X-Frame-Options: DENY\n  Permissions-Policy: camera=(), microphone=(), geolocation=()\n  Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; font-src 'self'; img-src 'self' data:; connect-src 'self'; frame-ancestors 'none'; base-uri 'none'; form-action 'self'\n`);
await fs.writeFile(path.join(root,'docs/BUILD_REPORT.json'),JSON.stringify({generatedAt:new Date().toISOString(),mode:production?'production':'preview',routes:routes.length*3+1,locales,collections:data.catalog.length,responses:data.evaluation.runs.length,productionBlockers:issues,validationScope:"website artifact only",distribution:config.distribution||{mode:"app-release"},operationalWarnings:config.appCommercialParity==="pending-backend-mapping"?["Website offer SKUs are not yet aligned with the audited app backend.","APK artifact not supplied; website-only mode exposes no active binary download.","Production transactions and infrastructure are not verified by this build."]:[]},null,2));
console.log(`Built ${routes.length*3+1} HTML pages; ${data.catalog.length} collections; ${data.evaluation.runs.length} original answers. Mode: ${production?'production':'preview (noindex)'}.`);
if(issues.length)console.log(`${issues.length} owner configuration requirements recorded in docs/BUILD_REPORT.json.`);

execFileSync(process.execPath,[path.join(root,'scripts/check.mjs')],{stdio:'inherit'});
```

## tests/content-v41.test.mjs

```javascript
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
  await fs.writeFile(path.join(root,'public/downloads/openturath-v1.0.51.apk'),'invalid test fixture');
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
```
