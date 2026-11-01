// Private build on top of OpenTurath's own stylesheet and script.
// Every page is noindex and nothing here is deployed.
import { mkdirSync, readFileSync, writeFileSync, rmSync, cpSync } from 'node:fs';
import { LANGS, copy } from './src/copy.mjs';
import { home as H } from './src/home.mjs';
import { treeSvg, graphSvg, bare } from './assets/tree.mjs';
import { naskahPage, naskahText } from './src/naskah.mjs';

const sanad = JSON.parse(readFileSync('data/sanad.json', 'utf8'));
const guide = JSON.parse(readFileSync('data/guide.json', 'utf8'));
const esc = (s) => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/"/g, '&quot;');
const pages = ['index', 'fitur', 'kisah', 'panduan', 'metode', 'unduh', 'hak'];
const svg = (d) => `<svg class="ic" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">${d}</svg>`;
const I = {
  globe: svg('<circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3c3 3 3 15 0 18M12 3c-3 3-3 15 0 18"/>'),
  sun: svg('<circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M2 12h2M20 12h2M5 5l1.5 1.5M17.5 17.5 19 19M5 19l1.5-1.5M17.5 6.5 19 5"/>'),
  moon: svg('<path d="M20 14.5A8.5 8.5 0 0 1 9.5 4a8.5 8.5 0 1 0 10.5 10.5Z"/>'),
  menu: svg('<path d="M4 7h16M4 12h16M4 17h16"/>'),
  down: svg('<path d="M12 4v11M7 11l5 5 5-5M5 20h14"/>'),
  check: svg('<circle cx="12" cy="12" r="9"/><path d="m8.5 12 2.5 2.5 4.5-5"/>'),
  book: svg('<rect x="4" y="5" width="4" height="15" rx="1"/><rect x="10" y="8" width="4" height="12" rx="1"/><path d="m16 8.5 3.5-1 3 12-3.5 1z"/>'),
  doc: svg('<path d="M6 3h9l4 4v14H6z"/><path d="M9 12h7M9 16h7"/>'),
  user: svg('<circle cx="12" cy="8" r="4"/><path d="M4 21c1-5 4.500-7 8-7s7 2 8 7"/>'),
  quote: svg('<path d="M6 7h5v5H8c0 2 1 3 3 3M14 7h5v5h-3c0 2 1 3 3 3"/>'),
  tree: svg('<circle cx="12" cy="5" r="2"/><circle cx="5" cy="19" r="2"/><circle cx="12" cy="19" r="2"/><circle cx="19" cy="19" r="2"/><path d="M12 7v10M12 12c-5 0-7 2-7 5M12 12c5 0 7 2 7 5"/>'),
  grad: svg('<path d="M2 9l10-5 10 5-10 5z"/><path d="M6 11v5c3 2 9 2 12 0v-5"/>'),
  mic: svg('<rect x="9" y="3" width="6" height="11" rx="3"/><path d="M5 11a7 7 0 0 0 14 0M12 18v3"/>'),
  shield: svg('<path d="M12 3l8 3v6c0 5-3.500 8-8 9-4.500-1-8-4-8-9V6z"/>'),
  stop: svg('<circle cx="12" cy="12" r="9"/><path d="M6 6l12 12"/>'),
  arrow: svg('<path d="M5 12h14M13 6l6 6-6 6"/>').replace('class="ic"', 'class="ic arr"'),
};
const logo = (cls = '') => `<img class="mark-l ${cls}" src="/assets/takhrij_mark_light.svg" alt=""><img class="mark-d ${cls}" src="/assets/takhrij_mark_dark.svg" alt="">`;

rmSync('dist', { recursive: true, force: true });
cpSync('assets', 'dist/assets', { recursive: true });
const tree = treeSvg(sanad.chains), graph = graphSvg(sanad.chains);
// Written as in the books: the compiler first, each formula before the next name.
const isnad = (c) => c.links.slice().reverse().map((l, i, all) => {
  const formula = i ? all[i].phrase : '';
  return `${formula ? `<i>${esc(bare(formula))}</i> ` : ''}${esc(l.name)}`;
}).join(' ');
const chainList = sanad.chains.map((c) => `<div class="chain"><b>${esc(c.book)} · ${esc(c.number)}</b><p>${isnad(c)}</p></div>`).join('');
const json = JSON.stringify({ chains: sanad.chains, grades: sanad.grades }).replace(/</g, '\\u003c');

function shell(l, page, title, body) {
  const t = copy[l], h = H[l], url = (p) => `/${l}/${p === 'index' ? '' : `${p}.html`}`;
  const links = ['fitur', 'kisah', 'panduan', 'metode'].map((p) => `<a href="${url(p)}"${p === page ? ' aria-current="page"' : ''}>${t.nav[p]}</a>`).join('');
  const langs = LANGS.map((o) => `<a class="row" href="/${o}/${page === 'index' ? '' : `${page}.html`}" hreflang="${o}"${o === l ? ' aria-current="true"' : ''}><span>${copy[o].name}</span><span class="soon">${o === l ? '✓' : o.toUpperCase()}</span></a>`).join('');
  const foot = h.foot.map(([head, items]) => `<div><h4>${head}</h4><ul>${items.map(([p, s]) => `<li><a href="${url(p)}">${s}</a></li>`).join('')}</ul></div>`).join('');
  return `<!doctype html><html lang="${l}" dir="${t.dir}" class="no-js"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="robots" content="noindex,nofollow"><title>${esc(title)}</title><meta name="description" content="${esc(t.desc)}"><meta name="theme-color" content="#FFFFFF"><link rel="stylesheet" href="/assets/css/site.css"><link rel="stylesheet" href="/assets/takhrij.css"><link rel="icon" href="/assets/takhrij_mark_light.svg"><link rel="preload" href="/assets/fonts/googlesansflex.woff2" as="font" type="font/woff2" crossorigin><script src="/assets/js/boot.js"></script></head><body><a class="skip" href="#main">${t.skip}</a>
<div class="anno"><a href="${url('hak')}">${t.privateNote}</a></div>
<header class="site"><div class="hbar"><a class="wordmark" href="${url('index')}" aria-label="تخريج الحديث">${logo()}<span lang="ar">تخريج الحديث</span></a><nav class="main" aria-label="Menu">${links}</nav><div class="hactions"><button class="langbtn" data-drop="langDrop" aria-expanded="false" aria-controls="langDrop" aria-label="${t.name}">${I.globe}<span>${l.toUpperCase()}</span></button><button class="iconbtn theme-btn" aria-label="${t.theme}"><span class="sun">${I.sun}</span><span class="moon">${I.moon}</span></button><a class="btn primary sm hideS" href="${url('unduh')}">${I.down}${h.dl}</a><button class="iconbtn menu-btn" aria-label="${t.nav.fitur}" aria-expanded="false">${I.menu}</button></div></div><div class="drop lang" id="langDrop">${langs}</div></header>
<div class="sheet" id="sheet">${links.replaceAll('<a ', '<a class="l" ')}<a class="btn primary" href="${url('unduh')}">${I.down}${h.dl}</a></div>
<main id="main">${body}</main>
<footer class="site"><div class="wrap"><div class="fgrid"><div class="fbrand"><a class="wordmark" href="${url('index')}">${logo()}<span lang="ar">تخريج الحديث</span></a></div>${foot}</div><div class="fbar"><span>${esc(t.story.note)}</span><span>OpenTurath</span></div></div></footer>
<script src="/assets/js/site.js" defer></script><script src="/assets/js/takhrij.js" defer></script></body></html>`;
}

const storyBody = (t) => `<div class="story-body rv">${t.story.p.map((p) => `<p>${esc(p)}</p>`).join('')}</div>`;
const timeline = (t) => `<div class="rukun rv" role="list" style="margin-top:40px">${t.story.time.map(([y, s], i) => `<div class="rk" role="listitem"><span class="i">${String(i + 1).padStart(2, '0')}</span><span class="tt">${y}<small>${esc(s)}</small></span></div>`).join('')}</div>`;

function home(l) {
  const t = copy[l], h = H[l], url = (p) => `/${l}/${p}.html`, d = h.demo, p = h.problem;
  const icons = [I.grad, I.doc, I.mic], statIcons = [I.book, I.doc, I.user, I.quote], guardIcons = [I.doc, I.stop, I.shield, I.grad];
  const shelves = '<svg class="bk" viewBox="0 0 380 270" preserveAspectRatio="xMaxYMid slice" fill="none" stroke="currentColor" stroke-width="1.3" aria-hidden="true"><g><rect x="14" y="70" width="34" height="170" rx="4"/><rect x="52" y="40" width="26" height="200" rx="4"/><rect x="82" y="92" width="38" height="148" rx="4"/><rect x="124" y="56" width="30" height="184" rx="4"/><rect x="158" y="30" width="34" height="214" rx="4"/><rect x="196" y="78" width="28" height="156" rx="4"/><rect x="228" y="46" width="36" height="196" rx="4"/><rect x="268" y="64" width="30" height="164" rx="4"/><rect x="302" y="34" width="32" height="206" rx="4"/><rect x="338" y="84" width="34" height="152" rx="4"/></g></svg>';
  return `<section class="welcome" id="hero"><canvas id="ring" aria-hidden="true"></canvas>
<p class="eyebrow-brand rv">${h.brand}</p><div class="hero-mark rv">${logo()}</div>
<h1 class="hero hero-wide rv d1"><span class="tl">${h.h1[0]}</span> <span class="tl">${h.h1[1]}</span><span class="hero-sub">${h.sub}</span></h1>
<p class="lede rv d2">${esc(h.lede)}</p><div class="cta-row rv d3"><a class="btn primary" href="#demo">${h.cta}</a><a class="btn tonal" href="${url('kisah')}">${h.cta2}</a></div>
<div class="meta-row rv d3">${h.meta.map((m) => `<span>${I.check}${m}</span>`).join('')}</div></section>
<section class="sec"><div class="wrap"><div class="sec-head rv"><div class="kicker">${p.k}</div><h2>${p.h}</h2><p class="lead">${p.p}</p></div><p class="sublabel rv">${p.label}</p><div class="trio3">${p.trio.map(([a, b], i) => `<div class="rv${i ? ` d${i}` : ''}"><div class="n">0${i + 1}</div><h3>${a}</h3><p>${b}</p></div>`).join('')}</div>
<div class="answer rv"><div><p class="sublabel" style="color:inherit;opacity:.7">${p.ans}</p><h3>${p.ansH}</h3><p class="lead2">${p.ansP}</p></div><ul>${p.list.map(([a, b]) => `<li>${I.check}<span><b>${a}</b>${b}</span></li>`).join('')}</ul></div></div></section>
<section class="sec" id="demo"><div class="wrap"><div class="sec-head rv"><div class="kicker">${d.k}</div><h2>${d.h}</h2><p class="lead">${esc(d.p)}</p></div><div class="rv"><div class="q1"><div class="qbox"><span class="tag">${d.matn}</span><p class="asked ar" lang="ar">${esc(sanad.matn)}</p><span class="tag">${d.tk}</span><div class="sum tk" lang="ar">${esc(sanad.takhrij.split('\n').slice(0, 3).join('\n'))}</div></div><div class="refs"><h3>${d.refsH}</h3><p>${d.refsP}</p><div class="reflist">${sanad.chains.slice(0, 3).map((c, i) => `<div class="ref"><div class="rh"><span class="no">${i + 1}</span><span class="loc">${esc(c.book)} · ${esc(c.number)}</span></div><div class="quote">${isnad(c)}</div></div>`).join('')}</div></div></div></div>
<div class="demo-card rv" data-routes="${t.demo.routes}" data-books="${t.demo.books}"><script type="application/json">${json}</script><div class="demo-top"><h3>${d.live}</h3><div class="demo-tabs" role="tablist" dir="rtl"><button role="tab" data-v="tree" aria-selected="true">الشجرة</button><button role="tab" data-v="chains">الطرق</button><button role="tab" data-v="graph">الرسم</button></div></div><div class="stage"><div><div class="view" data-v="tree">${tree}</div><div class="view" data-v="chains">${chainList}</div><div class="view" data-v="graph">${graph}</div></div><aside class="side" aria-live="polite"><p class="small">${d.liveP}</p></aside></div></div><p class="small rv" style="margin-top:14px">${t.demo.note}</p></div></section>
<section class="sec"><div class="wrap"><div class="sec-head rv"><div class="kicker">${h.who.k}</div><h2>${h.who.h}</h2></div><div class="cases">${h.who.list.map(([a, b], i) => `<div class="case rv${i ? ` d${i}` : ''}">${icons[i]}<h3>${a}</h3><p>${b}</p></div>`).join('')}</div></div></section>
<section class="sec" id="angka"><div class="wrap"><div class="sec-head rv"><div class="kicker">${h.num.k}</div><h2>${h.num.h}</h2><p class="lead">${h.num.p}</p></div><div class="stats rv">${h.num.items.map(([n, s], i) => i === 0 ? `<div class="stat big">${shelves}<div class="sic">${statIcons[i]}</div><div><div class="num">${n}</div><div class="lab">${s}</div></div></div>` : `<div class="stat"><div class="sic">${statIcons[i]}</div><div class="num">${n}</div><div><div class="lab">${s}</div></div></div>`).join('')}</div></div></section>
<section class="sec band" id="kisah"><div class="wrap"><div class="sec-head rv"><div class="kicker">${h.story.k}</div><h2>${t.story.h}</h2></div>${storyBody(t)}${timeline(t)}<p class="rv" style="margin-top:28px"><a class="btn inv" href="${url('kisah')}">${t.story.more}</a></p></div></section>
<section class="sec"><div class="wrap"><div class="sec-head rv"><div class="kicker">${h.flow.k}</div><h2>${h.flow.h}</h2></div><div class="shots">${t.flow.steps.map(([s, c], i) => `<figure class="rv${i ? ` d${i}` : ''}"><img src="/assets/shots/${s}.png" alt="${esc(c)}" loading="lazy" width="1280" height="800"><h3>${c}</h3></figure>`).join('')}</div></div></section>
<section class="sec"><div class="wrap"><div class="sec-head rv"><div class="kicker">${h.guard.k}</div><h2>${h.guard.h}</h2></div><div class="pillars">${h.guard.list.map(([a, b], i) => `<div class="pillar rv${i ? ` d${i}` : ''}"><div class="bic">${guardIcons[i]}</div><h3>${a}</h3><p>${b}</p></div>`).join('')}</div><div class="statement rv"><div><p>${h.guard.st}</p></div><div><p class="small">${h.guard.stP}</p><a class="btn inv-o sm" href="${url('metode')}">${h.guard.stB}</a></div></div></div></section>
<section class="sec band" id="unduh"><div class="wrap" style="text-align:center"><div class="sec-head center"><h2>${h.dl2.h}</h2><p class="lead">${h.dl2.p}</p></div><div class="pchips rv"><span class="pchip">macOS</span><span class="pchip">Windows</span><span class="pchip">Android</span></div><p class="rv" style="margin-top:28px"><a class="btn inv" href="${url('unduh')}">${h.dl2.b}</a></p></div></section>
<section class="sec"><div class="wrap"><div class="sec-head rv"><div class="kicker">${h.faqK}</div><h2>${h.faqH}</h2></div><div class="rv"><div class="faq">${t.faq.list.map(([q, a]) => `<details><summary><span>${q}</span><span class="pm" aria-hidden="true"></span></summary><div class="a">${a}</div></details>`).join('')}</div></div></div></section>`;
}

function page(l, p) {
  const t = copy[l], h = H[l], i = LANGS.indexOf(l), [title, lead] = t.pages[p];
  const head = (kicker, heading, sub) => `<section class="phead"><div class="wrap"><div class="kicker">${kicker}</div><h1>${heading}</h1>${sub ? `<p class="lead">${esc(sub)}</p>` : ''}</div></section>`;
  if (p === 'fitur') return head(title, t.feat.h, lead) + `<section class="sec"><div class="wrap">${t.feat.list.map(([a, b, img]) => `<div class="feat rv"><div><h2>${a}</h2><p>${b}</p></div><img src="/assets/shots/${img}.png" alt="${esc(b)}" loading="lazy" width="1280" height="800"></div>`).join('')}</div></section>`;
  if (p === 'kisah') return head(title, t.story.h, lead) + `<section class="sec"><div class="wrap"><div class="cols2"><div class="rv"><h2 style="margin-bottom:20px">${t.story.people}</h2></div><div class="rv d1">${t.story.names.map((n) => `<p class="lead" style="margin-bottom:16px">${esc(n)}</p>`).join('')}</div></div></div></section><section class="sec band"><div class="wrap">${storyBody(t)}${timeline(t)}</div></section><section class="sec"><div class="wrap"><div class="sec-head rv"><h2>${t.story.why}</h2><p class="lead">${esc(t.story.whyP)}</p></div><p class="small">${t.story.note}</p></div></section>`;
  if (p === 'panduan') return head(title, title, lead) + Object.values(guide).map((g) => `<section class="sec"><div class="wrap"><div class="cols2"><div class="rv"><h2 style="margin-bottom:12px">${esc(g.t[i])}</h2><p class="lead">${esc(g.s[i])}</p></div><div class="rv d1 page-sec"><ol>${g.steps.map((s) => `<li>${esc(s[i])}</li>`).join('')}</ol><p class="small">${esc(g.n[i])}</p></div></div></div></section>`).join('');
  if (p === 'metode') return head(title, title, lead) + `<section class="sec"><div class="wrap"><div class="pillars">${t.method.map(([a, b], n) => `<div class="pillar rv"><div class="bic">${[I.book, I.doc, I.tree, I.stop, I.globe, I.shield][n]}</div><h3>${a}</h3><p>${esc(b)}</p></div>`).join('')}</div></div></section>`;
  if (p === 'unduh') return head(title, t.dl.h, t.dl.p) + `<section class="sec band"><div class="wrap" style="text-align:center"><div class="pchips rv">${t.dl.plats.map(([a, b]) => `<span class="pchip">${a} · ${b}</span>`).join('')}</div></div></section>`;
  return head(title, title, '') + `<section class="sec"><div class="wrap page-sec">${t.rights.map((s) => `<p class="lead">${esc(s)}</p>`).join('')}</div></section>`;
}

for (const l of LANGS) {
  mkdirSync(`dist/${l}`, { recursive: true });
  for (const p of pages) {
    const name = p === 'index' ? copy[l].title : `${copy[l].pages[p][0]} · تخريج الحديث`;
    writeFileSync(`dist/${l}/${p}.html`, shell(l, p, name, p === 'index' ? home(l) : page(l, p)));
  }
}
mkdirSync('dist/naskah', { recursive: true });
for (const l of Object.keys(naskahText)) writeFileSync(`dist/naskah/${l}.html`, naskahPage(l, sanad.takhrij));
writeFileSync('dist/index.html', '<!doctype html><meta charset="utf-8"><meta name="robots" content="noindex"><meta http-equiv="refresh" content="0;url=/id/"><title>تخريج الحديث</title>');
console.log('built', LANGS.length * pages.length, 'pages');
