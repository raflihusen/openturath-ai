// Merender seluruh halaman landing dari data dan naskah. Tanpa dependensi.
import {copy, t, LOCALES} from './copy.mjs';
import {articles} from './articles.mjs';

export const e = s => String(s).replace(/[&<>"]/g, c => ({'&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;'}[c]));
export const fill = (s, ...args) => args.reduce((out, value, i) => out.replaceAll(`{${i}}`, value), s);
export const pathFor = (l, route = '') => `/${l}/${route ? route + '/' : ''}`;
const DIR = {id: 'ltr', en: 'ltr', ar: 'rtl'};
const NUM = {id: 'id-ID', en: 'en-US', ar: 'ar-EG'};
export const num = (n, l) => new Intl.NumberFormat(NUM[l]).format(n);
export const rupiah = (n, l) => (l === 'ar' ? `${num(n, l)} روبية` : `Rp ${num(n, l)}`);
const dateLong = (iso, l) => new Intl.DateTimeFormat(NUM[l], {dateStyle: 'long'}).format(new Date(iso));
const megabytes = (bytes, l) => `${new Intl.NumberFormat(NUM[l], {maximumFractionDigits: 1}).format(bytes / 1e6)} MB`;
const monthsLabel = (m, l) =>
  m === 1 ? t(copy.access.month1, l) : m === 12 ? t(copy.access.month12, l) : fill(t(copy.access.months, l), num(m, l));

// Lengkung runcing logo; bentuk yang sama dengan motion/src/spec.ts.
const arch = (x, y, w, h, open = false) => {
  const s = y + h * 0.4, cx = x + w / 2, f = v => v.toFixed(1);
  return `M${f(x)} ${f(y + h)}L${f(x)} ${f(s)}C${f(x)} ${f(y + h * 0.19)} ${f(cx - w * 0.2)} ${f(y + h * 0.075)} ${f(cx)} ${f(y)}` +
    `C${f(cx + w * 0.2)} ${f(y + h * 0.075)} ${f(x + w)} ${f(y + h * 0.19)} ${f(x + w)} ${f(s)}L${f(x + w)} ${f(y + h)}${open ? '' : 'Z'}`;
};
function archEcho() {
  const W = 520, H = 440, layers = 7, top = H * 0.1, bottom = H * 1.12, vanish = H * 0.6;
  const width = Math.min(W * 0.62, (bottom - top) * 0.74), cx = W / 2;
  const paths = Array.from({length: layers}, (_, i) => {
    const depth = i / (layers - 1), scale = 1 - depth * 0.74, w = width * scale;
    const y = vanish - (vanish - top) * scale, h = vanish + (bottom - vanish) * scale - y;
    return `<g class="echo d${layers - 1 - i}"><path d="${arch(cx - w / 2, y, w, h)}" fill="url(#fade)" fill-opacity="${(0.02 + depth * 0.012).toFixed(3)}"/>` +
      `<path d="${arch(cx - w / 2, y, w, h, true)}" fill="none" stroke="url(#fade)" stroke-opacity="${(0.1 + 0.05 * depth).toFixed(3)}"/></g>`;
  }).join('');
  return `<svg class="arch" viewBox="0 0 ${W} ${H}" aria-hidden="true" focusable="false"><defs>` +
    `<linearGradient id="fade" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#fff"/><stop offset=".55" stop-color="#fff"/><stop offset="1" stop-color="#fff" stop-opacity="0"/></linearGradient>` +
    `<radialGradient id="glow"><stop offset="0" stop-color="#fff" stop-opacity=".14"/><stop offset="1" stop-color="#fff" stop-opacity="0"/></radialGradient></defs>` +
    `<circle class="glow" cx="${cx}" cy="${(vanish + 40).toFixed(0)}" r="${(width * 0.5).toFixed(0)}" fill="url(#glow)"/>${paths}</svg>`;
}

const arrow = '<svg class="arrow" viewBox="0 0 24 24" aria-hidden="true"><path d="M5 12h14m-6-6 6 6-6 6" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"/></svg>';

export const catalogTotals = catalog =>
  catalog.filter(c => c.status === 'active').reduce((sum, c) => ({
    fields: sum.fields + 1,
    books: sum.books + c.metadata.books,
    volumes: sum.volumes + c.metadata.volumes,
    pages: sum.pages + c.metadata.pages,
    lowerBound: sum.lowerBound || !!c.metadata.volumesLowerBound,
  }), {fields: 0, books: 0, volumes: 0, pages: 0, lowerBound: false});

const available = d => d.releases.platforms.filter(p => p.url);

function downloadButton(l, d, cls = 'btn btn-primary') {
  const ready = available(d);
  if (!ready.length) {
    return `<a class="${cls} is-pending" href="${pathFor(l, 'download')}">${e(t(copy.download.soon, l))}</a>`;
  }
  // Tanpa JavaScript tombol menuju halaman unduh; site.js mengarahkannya langsung ke berkas perangkat pengunjung.
  const data = ready.map(p => `data-${p.id}="${e(p.url)}" data-${p.id}-label="${e(fill(t(copy.download.cta, l), p.name))}"`).join(' ');
  return `<a class="${cls}" href="${pathFor(l, 'download')}" data-download ${data}>${e(t(copy.nav.download, l))} OpenTurath${arrow}</a>`;
}

function header(l, route) {
  const item = (href, label, current) => `<a href="${href}"${current ? ' aria-current="page"' : ''}>${e(label)}</a>`;
  const links =
    item(`${pathFor(l)}#how`, t(copy.nav.how, l)) + item(`${pathFor(l)}#fields`, t(copy.nav.fields, l)) +
    item(pathFor(l, 'access'), t(copy.nav.access, l), route === 'access');
  const langs = LOCALES.map(x => `<a href="${pathFor(x, route === '404' ? '' : route)}" lang="${x}" hreflang="${x}"${x === l ? ' aria-current="true"' : ''}>${e(t(copy.langName, x))}</a>`).join('');
  return `<a class="skip" href="#main">${e(t(copy.skip, l))}</a><header class="site-header"><div class="wrap bar">
<a class="brand" href="${pathFor(l)}" dir="ltr"><span class="mark" aria-hidden="true"></span>OpenTurath</a>
<nav class="nav" aria-label="${e(t(copy.menu, l))}">${links}</nav>
<div class="tools">
<details class="lang"><summary aria-label="${e(t(copy.language, l))}">${l.toUpperCase()}</summary><div class="pop">${langs}</div></details>
<button class="icon-btn" type="button" data-theme-toggle aria-label="${e(t(copy.theme, l))}"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 3a9 9 0 1 0 9 9 7 7 0 0 1-9-9Z" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/></svg></button>
<a class="btn btn-primary btn-sm" href="${pathFor(l, 'download')}">${e(t(copy.nav.download, l))}</a>
</div></div><nav class="nav-mobile wrap" aria-label="${e(t(copy.menu, l))}">${links}</nav></header>`;
}

function footer(l) {
  const a = (route, label) => `<li><a href="${pathFor(l, route)}">${e(label)}</a></li>`;
  return `<footer class="site-footer"><div class="wrap foot">
<div><a class="brand" href="${pathFor(l)}" dir="ltr"><span class="mark" aria-hidden="true"></span>OpenTurath</a><p class="muted">${e(t(copy.tagline, l))}</p></div>
<div><h2>${e(t(copy.footer.product, l))}</h2><ul>${a('', t(copy.footer.home, l))}${a('download', t(copy.nav.download, l))}${a('access', t(copy.nav.access, l))}</ul></div>
<div><h2>${e(t(copy.footer.policies, l))}</h2><ul>${['terms', 'privacy', 'billing', 'account-deletion'].map(r => a(r, t(copy.legal[r], l))).join('')}</ul></div>
<div><h2>${e(t(copy.footer.help, l))}</h2><ul>${a('ai-guidelines', t(copy.legal['ai-guidelines'], l))}${a('contact', t(copy.contact.title, l))}</ul></div>
</div><div class="wrap foot-note"><p class="muted">${e(t(copy.footer.rights, l))}</p><p class="muted" dir="ltr">© ${new Date().getFullYear()} OpenTurath</p></div></footer>`;
}

function offerCard(l, name, body, offers) {
  const rows = offers.map(o => {
    const per = o.months > 1 ? `<span class="muted">${e(fill(t(copy.access.perMonth, l), rupiah(Math.round(o.amount / o.months / 1000) * 1000, l)))}</span>` : '';
    return `<li><span>${e(monthsLabel(o.months, l))}</span><span class="price"><bdi>${e(rupiah(o.amount, l))}</bdi>${per}</span></li>`;
  }).join('');
  return `<article class="card offer"><p class="label">${e(t(copy.access.intro, l))}</p><h3>${e(name)}</h3><p class="muted">${e(body)}</p><ul class="rows">${rows}</ul></article>`;
}
const offers = (l, d) => `<div class="grid-2">${offerCard(l, t(copy.access.tahawwulat.name, l), t(copy.access.tahawwulat.body, l), d.facts.pricing.tahawwulat)}${offerCard(l, t(copy.access.one.name, l), t(copy.access.one.body, l), d.facts.pricing.specialist)}</div><p class="muted fine">${e(t(copy.access.terms, l))}</p>`;

function home(l, d) {
  const p = d.proof, totals = catalogTotals(d.catalog);
  const fields = d.catalog.filter(c => c.status === 'active').map(c =>
    `<li><span class="field-name">${e(c.name[l])}</span>${l === 'ar' ? '' : `<span class="field-ar" lang="ar" dir="rtl">${e(c.arabic)}</span>`}<span class="muted">${e(fill(t(copy.fields.books, l), num(c.metadata.books, l)))}</span></li>`).join('');
  const stat = (value, label, plus) => `<div><dt>${e(label)}</dt><dd><bdi>${e(num(value, l))}${plus ? '+' : ''}</bdi></dd></div>`;
  const locator = fill(t(copy.proof.locator, l), l === 'ar' ? p.book.ar : p.book.latin, num(p.volume, l), num(p.page, l));
  return `<section class="hero"><div class="wrap hero-grid"><div class="hero-copy">
<p class="eyebrow" lang="${l === 'ar' ? 'ar' : 'en'}">${e(t(copy.eyebrow, l))}</p>
<h1>${e(t(copy.tagline, l))}</h1><p class="lead">${e(t(copy.hero.lead, l))}</p>
<div class="actions">${downloadButton(l, d)}<a class="btn btn-outline" href="#how">${e(t(copy.hero.secondary, l))}</a></div>
<p class="muted fine">${e(t(copy.hero.audience, l))}</p></div>
<div class="hero-art">${archEcho()}</div></div></section>

<section class="section" id="proof" aria-labelledby="proof-title"><div class="wrap split">
<div><h2 id="proof-title">${e(t(copy.proof.title, l))}</h2><p class="muted">${e(t(copy.proof.body, l))}</p></div>
<article class="card proof"><p class="label">${e(t(copy.proof.question, l))}</p><p class="q">${e(p.question[l])}</p>
<p class="label">${e(t(copy.proof.answer, l))}</p><p>${e(p.answer[l])}</p>
<p class="label">${e(t(copy.proof.passage, l))}</p><blockquote lang="ar" dir="rtl">${e(p.quote)}</blockquote>
<p class="label">${e(t(copy.proof.reference, l))}</p><p class="ref"><bdi>${e(locator)}</bdi> · ${e(p.author[l])}</p>
<p class="muted fine">${e(t(copy.proof.note, l))}</p></article></div></section>

<section class="section tone" id="how" aria-labelledby="how-title"><div class="wrap"><h2 id="how-title">${e(t(copy.how.title, l))}</h2>
<ol class="steps">${copy.how.steps.map(s => `<li><h3>${e(t(s.title, l))}</h3><p class="muted">${e(t(s.body, l))}</p></li>`).join('')}</ol></div></section>

<section class="section" id="fields" aria-labelledby="fields-title"><div class="wrap"><div class="head"><h2 id="fields-title">${e(fill(t(copy.fields.title, l), num(totals.fields, l)))}</h2><p class="muted">${e(t(copy.fields.body, l))}</p></div>
<ul class="fields">${fields}</ul>
<dl class="stats">${stat(totals.books, t(copy.numbers.books, l))}${stat(totals.volumes, t(copy.numbers.volumes, l), totals.lowerBound)}${stat(totals.pages, t(copy.numbers.pages, l))}${stat(totals.fields, t(copy.numbers.fields, l))}</dl>
<p class="muted fine">${e(t(copy.numbers.note, l))}</p></div></section>

<section class="section tone" id="adab" aria-labelledby="adab-title"><div class="wrap narrow"><h2 id="adab-title">${e(t(copy.adab.title, l))}</h2><p class="lead">${e(t(copy.adab.body, l))}</p>
<a class="link" href="${pathFor(l, 'ai-guidelines')}">${e(t(copy.adab.link, l))}${arrow}</a></div></section>

<section class="section" id="access" aria-labelledby="access-title"><div class="wrap"><h2 id="access-title">${e(t(copy.access.title, l))}</h2>${offers(l, d)}
<a class="link" href="${pathFor(l, 'access')}">${e(t(copy.access.more, l))}${arrow}</a></div></section>

<section class="section tone" id="faq" aria-labelledby="faq-title"><div class="wrap narrow"><h2 id="faq-title">${e(t(copy.faq.title, l))}</h2>
<div class="faq">${copy.faq.items.map(x => `<details><summary>${e(t(x.q, l))}</summary><p>${e(t(x.a, l))}</p></details>`).join('')}</div></div></section>

<section class="section cta" aria-labelledby="cta-title"><div class="wrap narrow"><h2 id="cta-title">${e(t(copy.tagline, l))}</h2>
<div class="actions">${downloadButton(l, d)}<a class="btn btn-outline" href="${pathFor(l, 'download')}">${e(t(copy.download.all, l))}</a></div></div></section>`;
}

const pageHead = (title, intro = '') => `<section class="page-head"><div class="wrap narrow"><h1>${e(title)}</h1>${intro ? `<p class="lead">${e(intro)}</p>` : ''}</div></section>`;

function download(l, d) {
  const cards = d.releases.platforms.map(p => {
    const minimum = p.id === 'android' ? `Android ${d.facts.android.name}` : p.minimum;
    const meta = [[t(copy.download.requires, l), `<bdi>${e(minimum)}+</bdi>`]];
    if (p.url) {
      meta.push([t(copy.download.size, l), `<bdi>${e(megabytes(p.sizeBytes, l))}</bdi>`], [t(copy.download.released, l), e(dateLong(p.date, l))]);
    }
    const action = p.url
      ? `<a class="btn btn-primary" href="${e(p.url)}" rel="noopener">${e(fill(t(copy.download.cta, l), p.name))}</a><p class="muted fine">${e(fill(t(copy.download.version, l), d.facts.version))}</p><details class="sha"><summary>${e(t(copy.download.checksum, l))}</summary><code dir="ltr">${e(p.sha256)}</code></details>`
      : `<p class="pending">${e(t(copy.download.soon, l))}</p>`;
    return `<article class="card platform"><h2 dir="ltr">${e(p.name)}</h2><dl>${meta.map(([k, v]) => `<div><dt>${e(k)}</dt><dd>${v}</dd></div>`).join('')}</dl>${action}<p class="muted fine">${e(t(copy.download.install[p.id], l))}</p></article>`;
  }).join('');
  return `${pageHead(t(copy.download.title, l), t(copy.download.intro, l))}<section class="section compact"><div class="wrap"><div class="grid-3">${cards}</div><p class="muted">${e(t(copy.download.ios, l))}</p></div></section>`;
}

const access = (l, d) => `${pageHead(t(copy.access.pageTitle, l), t(copy.access.title, l))}<section class="section compact"><div class="wrap">${offers(l, d)}<a class="link" href="${pathFor(l, 'billing')}">${e(t(copy.access.details, l))}${arrow}</a></div></section>`;

function legal(l, route, d) {
  const a = articles[route], i = LOCALES.indexOf(l);
  const blocks = a.blocks.map(b => `<h2>${e(b.heading[i])}</h2>${b.body[i].split(/\n+/).map(para => `<p>${e(para)}</p>`).join('')}`).join('');
  const effective = fill(t(copy.legal.effective, l), dateLong(d.config.policy.effectiveDate, l), d.config.policy.version);
  return `${pageHead(t(copy.legal[route], l), a.intro[i])}<section class="section compact"><div class="wrap narrow prose"><p class="muted fine">${e(effective)}</p>${blocks}<p><a class="link" href="/assets/kebijakan-aplikasi-v1.0.md">${e(t(copy.legal.full, l))}${arrow}</a></p></div></section>`;
}

const contact = (l, d) => `${pageHead(t(copy.contact.title, l), t(copy.contact.body, l))}<section class="section compact"><div class="wrap narrow"><p class="email"><a href="mailto:${e(d.config.contact.email)}" dir="ltr">${e(d.config.contact.email)}</a> <button class="btn btn-outline btn-sm" type="button" data-copy="${e(d.config.contact.email)}" data-copied="${e(t(copy.contact.copied, l))}">${e(t(copy.contact.copy, l))}</button></p><p class="muted" role="status" data-copy-status></p><p class="muted">${e(t(copy.contact.hint, l))}</p></div></section>`;

const notFound = l => `${pageHead(t(copy.notFound.title, l), t(copy.notFound.body, l))}<section class="section compact"><div class="wrap narrow"><a class="btn btn-primary" href="${pathFor(l)}">${e(t(copy.footer.home, l))}</a></div></section>`;

export function pageTitle(l, route) {
  if (route === '') return `OpenTurath — ${t(copy.tagline, l)}`;
  const name = route === 'download' ? t(copy.download.title, l) : route === 'access' ? t(copy.access.pageTitle, l)
    : route === 'contact' ? t(copy.contact.title, l) : route === '404' ? t(copy.notFound.title, l) : t(copy.legal[route], l);
  return `${name} — OpenTurath`;
}
export function pageDescription(l, route) {
  if (route === '') return t(copy.hero.lead, l);
  if (route === 'download') return t(copy.download.intro, l);
  if (route === 'access') return t(copy.access.terms, l);
  if (route === 'contact') return t(copy.contact.body, l);
  if (route === '404') return t(copy.notFound.body, l);
  return articles[route].intro[LOCALES.indexOf(l)];
}
export function renderBody(l, route, d) {
  if (route === '') return home(l, d);
  if (route === 'download') return download(l, d);
  if (route === 'access') return access(l, d);
  if (route === 'contact') return contact(l, d);
  if (route === '404') return notFound(l);
  return legal(l, route, d);
}

export function page(l, route, d, {release = false} = {}) {
  const base = d.config.canonicalUrl, url = base + pathFor(l, route === '404' ? '' : route);
  const title = pageTitle(l, route), description = pageDescription(l, route);
  const alternates = route === '404' ? '' : LOCALES.map(x => `<link rel="alternate" hreflang="${x}" href="${base}${pathFor(x, route)}">`).join('') + `<link rel="alternate" hreflang="x-default" href="${base}${pathFor('id', route)}">`;
  const lowest = Math.min(...d.facts.pricing.specialist.map(o => o.amount));
  const ld = route === ''
    ? {'@context': 'https://schema.org', '@type': 'SoftwareApplication', name: 'OpenTurath', applicationCategory: 'EducationalApplication', operatingSystem: 'Android, macOS, Windows', softwareVersion: d.facts.version, description, url, offers: {'@type': 'Offer', price: lowest, priceCurrency: 'IDR'}}
    : {'@context': 'https://schema.org', '@type': 'WebPage', name: title, description, url};
  return `<!doctype html><html lang="${l}" dir="${DIR[l]}"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>${e(title)}</title><meta name="description" content="${e(description)}">${release && route !== '404' ? '' : '<meta name="robots" content="noindex">'}
<link rel="canonical" href="${url}">${alternates}
<meta property="og:type" content="website"><meta property="og:site_name" content="OpenTurath"><meta property="og:title" content="${e(title)}"><meta property="og:description" content="${e(description)}"><meta property="og:url" content="${url}"><meta property="og:image" content="${base}/assets/social-card.png"><meta name="twitter:card" content="summary_large_image">
<meta name="theme-color" content="#fafafa" media="(prefers-color-scheme: light)"><meta name="theme-color" content="#111111" media="(prefers-color-scheme: dark)">
<link rel="icon" href="/assets/favicon.svg"><link rel="preload" href="/assets/fonts/newsreader-latin-600-normal.woff2" as="font" type="font/woff2" crossorigin>
<link rel="stylesheet" href="/assets/fonts.css"><link rel="stylesheet" href="/assets/site.css"><script src="/assets/site.js"></script>
<script type="application/ld+json">${JSON.stringify(ld).replaceAll('<', '\\u003c')}</script></head>
<body>${header(l, route)}<main id="main">${renderBody(l, route, d)}</main>${footer(l)}</body></html>`;
}

export function rootPage(d) {
  const links = LOCALES.map(l => `<a class="btn btn-outline" href="${pathFor(l)}" lang="${l}" hreflang="${l}">${e(t(copy.langName, l))}</a>`).join('');
  return `<!doctype html><html lang="id"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>OpenTurath</title>
<meta name="description" content="${e(t(copy.tagline, 'id'))}"><link rel="canonical" href="${d.config.canonicalUrl}/id/">
<link rel="icon" href="/assets/favicon.svg"><link rel="stylesheet" href="/assets/fonts.css"><link rel="stylesheet" href="/assets/site.css"><script src="/assets/site.js" data-root></script></head>
<body><main class="root"><a class="brand" href="/id/" dir="ltr"><span class="mark" aria-hidden="true"></span>OpenTurath</a><div class="actions">${links}</div></main></body></html>`;
}
