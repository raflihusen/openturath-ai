import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';

const root = process.env.AUDIT_SOURCE_ROOT || process.cwd();
const uiDart = fs.readFileSync(path.join(root, 'lib/core/notebook_ui_script.dart'), 'utf8');
const skinDart = fs.readFileSync(path.join(root, 'lib/core/notebook_skin.dart'), 'utf8');

const cleanupSrc = uiDart.match(/const _notebookCleanupScript = r'''([\s\S]*?)\n''';/)![1];
const skinSrc = skinDart.match(/const notebookSkinScript = r'''([\s\S]*?)\n''';/)![1];

// Minimal DOM implementation sufficient to execute _notebookCleanupScript + notebookSkinScript
class MockClassList {
  private set = new Set<string>();
  constructor(initial = '') {
    initial.split(/\s+/).filter(Boolean).forEach(c => this.set.add(c));
  }
  contains(c: string) { return this.set.has(c); }
  add(...cs: string[]) { cs.forEach(c => this.set.add(c)); }
  remove(...cs: string[]) { cs.forEach(c => this.set.delete(c)); }
  toggle(c: string, force?: boolean) {
    if (force === undefined) {
      if (this.set.has(c)) { this.set.delete(c); return false; }
      this.set.add(c); return true;
    }
    if (force) this.set.add(c); else this.set.delete(c);
    return force;
  }
  toString() { return [...this.set].join(' '); }
}

class MockNode {
  nodeType: number;
  parentNode: MockElement | null = null;
  childNodes: MockNode[] = [];
  constructor(nodeType: number) { this.nodeType = nodeType; }
  get nextSibling(): MockNode | null {
    if (!this.parentNode) return null;
    const idx = this.parentNode.childNodes.indexOf(this);
    return idx >= 0 && idx + 1 < this.parentNode.childNodes.length ? this.parentNode.childNodes[idx + 1] : null;
  }
  remove() {
    if (!this.parentNode) return;
    const idx = this.parentNode.childNodes.indexOf(this);
    if (idx >= 0) this.parentNode.childNodes.splice(idx, 1);
    this.parentNode = null;
  }
  replaceWith(...nodes: (MockNode | string)[]) {
    if (!this.parentNode) return;
    const p = this.parentNode;
    const idx = p.childNodes.indexOf(this);
    if (idx < 0) return;
    const mapped = nodes.map(n => typeof n === 'string' ? new MockText(n) : n);
    mapped.forEach(n => { n.remove(); n.parentNode = p; });
    p.childNodes.splice(idx, 1, ...mapped);
    this.parentNode = null;
  }
  get textContent(): string { return ''; }
  set textContent(_v: string) {}
  cloneNode(_deep?: boolean): MockNode { return new MockNode(this.nodeType); }
}

class MockText extends MockNode {
  private _val: string;
  constructor(val: string) { super(3); this._val = val; }
  override get textContent() { return this._val; }
  override set textContent(v: string) { this._val = v; }
  override cloneNode() { return new MockText(this._val); }
}

class MockFragment extends MockNode {
  constructor() { super(11); }
  appendChild(node: MockNode) {
    if (node instanceof MockFragment) {
      for (const ch of [...node.childNodes]) this.appendChild(ch);
      return node;
    }
    node.remove();
    node.parentNode = this as unknown as MockElement;
    this.childNodes.push(node);
    return node;
  }
}

class MockElement extends MockNode {
  tagName: string;
  attrs = new Map<string, string>();
  classList: MockClassList;
  dataset: Record<string, string> = {};
  style: Record<string, any> = {
    setProperty(k: string, v: string) { this[k] = v; },
    getPropertyValue(k: string) { return this[k] || ''; },
  };
  offsetParent: any = {};
  constructor(tag: string, className = '') {
    super(1);
    this.tagName = tag.toUpperCase();
    this.classList = new MockClassList(className);
  }
  get id() { return this.attrs.get('id') || ''; }
  set id(v: string) { this.attrs.set('id', v); }
  get className() { return this.classList.toString(); }
  set className(v: string) { this.classList = new MockClassList(v); }
  get firstChild() { return this.childNodes[0] || null; }
  get firstElementChild() { return this.childNodes.find(n => n instanceof MockElement) as MockElement || null; }
  get nextElementSibling(): MockElement | null {
    if (!this.parentNode) return null;
    const siblings = this.parentNode.childNodes;
    const idx = siblings.indexOf(this);
    for (let i = idx + 1; i < siblings.length; i++) {
      if (siblings[i] instanceof MockElement) return siblings[i] as MockElement;
    }
    return null;
  }
  get parentElement() { return this.parentNode; }
  setAttribute(k: string, v: string) { this.attrs.set(k, String(v)); }
  getAttribute(k: string) { return this.attrs.has(k) ? this.attrs.get(k)! : null; }
  removeAttribute(k: string) { this.attrs.delete(k); }
  addEventListener() {}
  getClientRects() { return [{}]; }
  appendChild(node: MockNode) {
    if (node instanceof MockFragment) {
      for (const ch of [...node.childNodes]) this.appendChild(ch);
      return node;
    }
    node.remove();
    node.parentNode = this;
    this.childNodes.push(node);
    return node;
  }
  insertBefore(node: MockNode, ref: MockNode | null) {
    if (!ref) return this.appendChild(node);
    const idx = this.childNodes.indexOf(ref);
    if (idx < 0) return this.appendChild(node);
    if (node instanceof MockFragment) {
      for (const ch of [...node.childNodes]) this.insertBefore(ch, ref);
      return node;
    }
    node.remove();
    node.parentNode = this;
    this.childNodes.splice(idx, 0, node);
    return node;
  }
  replaceChild(newNode: MockNode, oldNode: MockNode) {
    const idx = this.childNodes.indexOf(oldNode);
    if (idx < 0) return oldNode;
    if (newNode instanceof MockFragment) {
      const items = [...newNode.childNodes];
      items.forEach(n => { n.remove(); n.parentNode = this; });
      this.childNodes.splice(idx, 1, ...items);
      oldNode.parentNode = null;
      return oldNode;
    }
    newNode.remove();
    newNode.parentNode = this;
    this.childNodes.splice(idx, 1, newNode);
    oldNode.parentNode = null;
    return oldNode;
  }
  insertAdjacentText(pos: string, text: string) {
    if (pos === 'afterbegin') this.insertBefore(new MockText(text), this.firstChild);
    else if (pos === 'afterend' && this.parentNode) {
      const idx = this.parentNode.childNodes.indexOf(this);
      const t = new MockText(text);
      t.parentNode = this.parentNode;
      this.parentNode.childNodes.splice(idx + 1, 0, t);
    }
  }
  override get textContent(): string {
    return this.childNodes.map(c => c.textContent).join('');
  }
  override set textContent(v: string) {
    this.childNodes.forEach(c => { c.parentNode = null; });
    this.childNodes = v ? [new MockText(v)] : [];
    if (this.childNodes[0]) this.childNodes[0].parentNode = this;
  }
  override cloneNode(deep = false): MockElement {
    const c = new MockElement(this.tagName, this.className);
    this.attrs.forEach((v, k) => c.attrs.set(k, v));
    c.dataset = { ...this.dataset };
    if (deep) {
      for (const ch of this.childNodes) c.appendChild(ch.cloneNode(true));
    }
    return c;
  }
  matches(selector: string): boolean {
    return selector.split(',').some(sel => this.matchSingle(sel.trim()));
  }
  private matchSingle(sel: string): boolean {
    if (!sel) return false;
    const parts = sel.split(/\s+/).filter(Boolean);
    if (parts.length > 1) {
      const last = parts[parts.length - 1];
      if (!this.matchSimple(last)) return false;
      let anc = this.parentNode;
      let pIdx = parts.length - 2;
      while (anc && pIdx >= 0) {
        if (parts[pIdx] === '>') {
          pIdx--;
          if (!anc.matchSimple(parts[pIdx])) return false;
          pIdx--;
          anc = anc.parentNode;
          continue;
        }
        if (anc.matchSimple(parts[pIdx])) pIdx--;
        anc = anc.parentNode;
      }
      return pIdx < 0;
    }
    return this.matchSimple(parts[0]);
  }
  private matchSimple(s: string): boolean {
    if (s === '*' || s === ':scope') return true;
    let rem = s.replace(/^:scope\s*>\s*/, '');
    // Handle :not(.cls)
    const notMatches = [...rem.matchAll(/:not\(([^)]+)\)/g)];
    for (const nm of notMatches) {
      if (this.matchSimple(nm[1])) return false;
    }
    rem = rem.replace(/:not\([^)]+\)/g, '');
    // Handle [attr*="val" i]
    const attrMatches = [...rem.matchAll(/\[([^\]=*]+)(\*=|=)?"?([^"\]]*)"?(?:\s+i)?\]/g)];
    for (const am of attrMatches) {
      const attr = am[1];
      const op = am[2];
      const val = am[3];
      const actual = attr === 'class' ? this.className : (this.getAttribute(attr) || '');
      if (!op) { if (!this.attrs.has(attr)) return false; }
      else if (op === '*=') { if (!actual.toLowerCase().includes(val.toLowerCase())) return false; }
      else if (op === '=') { if (actual.toLowerCase() !== val.toLowerCase()) return false; }
    }
    rem = rem.replace(/\[[^\]]+\]/g, '');
    const classMatches = [...rem.matchAll(/\.([A-Za-z0-9_-]+)/g)];
    for (const cm of classMatches) {
      if (!this.classList.contains(cm[1])) return false;
    }
    const tag = rem.replace(/\.[A-Za-z0-9_-]+/g, '').trim();
    if (tag && this.tagName !== tag.toUpperCase()) return false;
    return true;
  }
  closest(sel: string): MockElement | null {
    let cur: MockElement | null = this;
    while (cur) {
      if (cur.matches(sel)) return cur;
      cur = cur.parentNode;
    }
    return null;
  }
  querySelectorAll(sel: string): MockElement[] {
    const out: MockElement[] = [];
    const visit = (node: MockElement) => {
      for (const ch of node.childNodes) {
        if (ch instanceof MockElement) {
          if (ch.matches(sel)) out.push(ch);
          visit(ch);
        }
      }
    };
    visit(this);
    return out;
  }
  querySelector(sel: string): MockElement | null {
    return this.querySelectorAll(sel)[0] || null;
  }
}

function createHarness() {
  const html = new MockElement('html');
  const head = new MockElement('head');
  const body = new MockElement('body');
  html.appendChild(head);
  html.appendChild(body);
  const document: any = {
    documentElement: html,
    head,
    body,
    createElement: (tag: string) => new MockElement(tag),
    createTextNode: (t: string) => new MockText(t),
    createDocumentFragment: () => new MockFragment(),
    getElementById: (id: string) => html.querySelectorAll('*').find(e => e.id === id) || null,
    querySelector: (sel: string) => html.querySelector(sel),
    querySelectorAll: (sel: string) => html.querySelectorAll(sel),
    addEventListener: () => {},
  };
  const window: any = {
    location: { hostname: 'notebooklm.google.com', href: 'https://notebooklm.google.com/notebook/test' },
    addEventListener: () => {},
    matchMedia: () => ({ matches: false }),
    sessionStorage: { getItem: () => null, setItem: () => {} },
    getComputedStyle: () => ({ visibility: 'visible', display: 'block' }),
    URL,
  };
  window.top = window;
  window.document = document;
  const ctx = {
    window,
    document,
    location: window.location,
    sessionStorage: window.sessionStorage,
    getComputedStyle: window.getComputedStyle,
    URL,
    MutationObserver: class { observe() {} disconnect() {} },
    CustomEvent: class { type: string; init: any; constructor(type: string, init: any) { this.type = type; this.init = init; } },
    setTimeout: () => 1,
    clearTimeout: () => {},
    setInterval: () => 1,
    clearInterval: () => {},
  };
  vm.runInNewContext(cleanupSrc + '\n' + skinSrc, ctx);
  return { window, document, body };
}

test('normalizeYouTubeUrls cleans spaced YouTube URLs without touching kitabs or video IDs', () => {
  const { window } = createHarness();
  const norm = window.__otNormalizeYouTubeUrls;
  assert.equal(
    norm('الرابط: youtu.be / VAjMypi4X7c'),
    'الرابط: https://youtu.be/VAjMypi4X7c',
  );
  assert.equal(
    norm('https: / / www.youtube.com / watch?v=VAjMypi4X7c&t=120s'),
    'https://www.youtube.com/watch?v=VAjMypi4X7c&t=120s',
  );
  assert.equal(
    norm('Tonton di (https://youtube.com / shorts / abc_123-XYZ).'),
    'Tonton di (https://youtube.com/shorts/abc_123-XYZ).',
  );
  assert.equal(
    norm('معرف الفيديو: VAjMypi4X7c\nج 1 / 250 — Arti / Intisari: penjelasan biasa'),
    'معرف الفيديو: VAjMypi4X7c\nج 1 / 250 — Arti / Intisari: penjelasan biasa',
  );
});

test('Screenshot 1: Indonesian lead-in stays LTR outside .ot-ibarah while Arabic quote + metadata stay inside and YouTube link is normalized', () => {
  const { window, document, body } = createHarness();
  const box = document.createElement('div');
  box.className = 'to-user-container';
  const card = document.createElement('div');
  card.className = 'to-user-message-card-content';
  const p = document.createElement('div');
  p.className = 'paragraph';
  p.appendChild(document.createTextNode(
    'Teks penjelasan perampasan mimbar dan narasi opini oleh agen fitnah syaitani:\n' +
    '«فَالْمَوْجُودُ عِنْدَنَا نِسْبَةُ الْوَعْيِ فِي تَوْظِيفِ الْعِلْمِ، الشَّيْطَانُ وَأَتْبَاعُهُ مَلَكُوا زِمَامَ الْحَرَكَةِ»\n' +
    'محاضرة: كشف الستار عن ما تعانية الأمة من صراع\n' +
    'معرف الفيديو: VAjMypi4X7c\n' +
    'الرابط: youtu.be / VAjMypi4X7c'
  ));
  card.appendChild(p);
  const actions = document.createElement('div');
  actions.className = 'chat-actions';
  box.appendChild(card);
  box.appendChild(actions);
  body.appendChild(box);

  window.otSkinApply();

  assert.equal(card.classList.contains('ot-dir-ltr'), true);
  const lead = p.querySelector('.ot-ibarah-trans');
  const ibarah = p.querySelector('.ot-ibarah');
  assert.ok(lead, 'Indonesian lead-in must be split outside .ot-ibarah');
  assert.ok(ibarah, 'Arabic quote + metadata must be in .ot-ibarah');
  assert.equal(lead.getAttribute('dir'), 'ltr');
  assert.match(lead.textContent, /Teks penjelasan perampasan mimbar/);
  assert.equal(ibarah.getAttribute('dir'), 'rtl');
  assert.match(ibarah.textContent, /فَالْمَوْجُودُ/);
  assert.match(ibarah.textContent, /محاضرة:/);
  assert.match(ibarah.textContent, /معرف الفيديو: VAjMypi4X7c/);

  const ytLink = ibarah.querySelector('a.ot-yt-link');
  assert.ok(ytLink, 'Spaced YouTube URL must be linkified inside .ot-ibarah');
  assert.equal(ytLink.getAttribute('href'), 'https://youtu.be/VAjMypi4X7c');
  assert.equal(ytLink.getAttribute('dir'), 'ltr');
  assert.equal(ytLink.textContent, 'https://youtu.be/VAjMypi4X7c');
});

test('Screenshot 2: Numbered Arabic-Indic ibarah (٦. «...») + italic Arti/Intisari inside nested spans splits cleanly into .ot-ibarah + .ot-ibarah-trans', () => {
  const { window, document, body } = createHarness();
  const box = document.createElement('div');
  box.className = 'to-user-container';
  const card = document.createElement('div');
  card.className = 'to-user-message-card-content';

  const p = document.createElement('div');
  p.className = 'paragraph';
  const spanWrap = document.createElement('span');
  const s1 = document.createElement('span');
  s1.textContent = '٦. «خَاتِمَةٌ : أَفْضَلُ الشُّهُورِ لِلصَّوْمِ بَعْدَ رَمَضَانَ الْأَشْهُرُ الْحُرُمُ وَهِيَ ذُو القِعْدَةِ وَذُو الحِجَّةِ وَالْمُحَرَّمُ وَرَجَبٌ» (تحفة المحتاج ج ١٠، ص ٦٥٩٩)\n';
  const em = document.createElement('em');
  em.textContent = 'Arti/Intisari:';
  const s2 = document.createElement('span');
  s2.textContent = ' Bulan-bulan paling utama untuk puasa setelah Ramadan adalah bulan-bulan haram, yang paling utamanya adalah Muharram kemudian Rajab untuk keluar dari perselisihan pendapat ulama yang mengutamakannya.';
  spanWrap.appendChild(s1);
  spanWrap.appendChild(em);
  spanWrap.appendChild(s2);
  p.appendChild(spanWrap);

  card.appendChild(p);
  const actions = document.createElement('div');
  actions.className = 'chat-actions';
  box.appendChild(card);
  box.appendChild(actions);
  body.appendChild(box);

  window.otSkinApply();

  assert.equal(card.classList.contains('ot-dir-ltr'), true);
  const ibarah = p.querySelector('.ot-ibarah');
  const trans = p.querySelector('.ot-ibarah-trans');
  assert.ok(ibarah, 'Numbered Arabic-Indic ibarah must be detected as .ot-ibarah');
  assert.ok(trans, 'Arti/Intisari must be split into .ot-ibarah-trans');
  assert.equal(ibarah.getAttribute('dir'), 'rtl');
  assert.match(ibarah.textContent, /٦\. «خَاتِمَةٌ/);
  assert.equal(trans.getAttribute('dir'), 'ltr');
  assert.match(trans.textContent, /^Arti\/Intisari:/);
});

test('Full-Arabic answer: stays ot-dir-rtl even with Indonesian question + YouTube links; inline book titles do NOT get .ot-ibarah, only standalone quotes/blockquotes do', () => {
  const { window, document, body } = createHarness();

  const pair = document.createElement('div');
  pair.className = 'chat-message-pair';
  const qCard = document.createElement('div');
  qCard.className = 'from-user-message-card-content';
  qCard.textContent = 'Jelaskan hukum puasa bulan Rajab';
  pair.appendChild(qCard);

  const box = document.createElement('div');
  box.className = 'to-user-container';
  const card = document.createElement('div');
  card.className = 'to-user-message-card-content';

  const proseWithBookTitle = document.createElement('div');
  proseWithBookTitle.className = 'paragraph';
  proseWithBookTitle.textContent =
    'ذهب جمهور الفقهاء الشافعية كما ذكر الإمام النووي في كتاب «المجموع شرح المهذب» إلى استحباب صيام الأشهر الحرم، ويُطلق العلماء مصطلح "الماء المستعمل" في باب الطهارة للدلالة على حكم خاص، ويمكن مراجعة الدرس عبر الرابط: youtu.be / VAjMypi4X7c ومعرف الفيديو: VAjMypi4X7c.';

  const standaloneQuote = document.createElement('div');
  standaloneQuote.className = 'paragraph';
  standaloneQuote.textContent =
    '«أَفْضَلُ الشُّهُورِ لِلصَّوْمِ بَعْدَ رَمَضَانَ الْأَشْهُرُ الْحُرُمُ وَأَفْضَلُهَا الْمُحَرَّمُ ثُمَّ رَجَبٌ» (تحفة المحتاج ج ١٠، ص ٦٥٩٩)';

  const bq = document.createElement('blockquote');
  bq.textContent = 'قَالَ الْإِمَامُ النَّوَوِيُّ: يُسْتَحَبُّ صَوْمُ الْأَشْهُرِ الْحُرُمِ بِالِاتِّفَاقِ.';

  card.appendChild(proseWithBookTitle);
  card.appendChild(standaloneQuote);
  card.appendChild(bq);

  const actions = document.createElement('div');
  actions.className = 'chat-actions';
  box.appendChild(card);
  box.appendChild(actions);
  pair.appendChild(box);
  body.appendChild(pair);

  window.otSkinApply();

  assert.equal(card.classList.contains('ot-dir-rtl'), true, 'Full-Arabic answer must stay ot-dir-rtl');
  assert.equal(proseWithBookTitle.classList.contains('ot-ibarah'), false, 'Arabic prose with inline «book title» and "term" must NOT get .ot-ibarah');
  assert.equal(standaloneQuote.classList.contains('ot-ibarah'), true, 'Standalone verbatim Arabic quote MUST get .ot-ibarah');
  assert.equal(bq.classList.contains('ot-ibarah'), true, 'Blockquote MUST get .ot-ibarah');

  const ytLink = proseWithBookTitle.querySelector('a.ot-yt-link');
  assert.ok(ytLink, 'Spaced YouTube URL inside Arabic prose must be linkified');
  assert.equal(ytLink.getAttribute('href'), 'https://youtu.be/VAjMypi4X7c');
  assert.equal(ytLink.getAttribute('dir'), 'ltr');
});
