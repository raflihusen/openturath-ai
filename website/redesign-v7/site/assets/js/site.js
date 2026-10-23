/* OpenTurath V7 — peningkatan progresif. Semua konten terbaca tanpa JavaScript. */
(function () {
  var d = document, root = d.documentElement;
  root.classList.remove('no-js'); root.classList.add('js');
  var $ = function (s, c) { return (c || d).querySelector(s); };
  var $$ = function (s, c) { return Array.prototype.slice.call((c || d).querySelectorAll(s)); };
  var reduce = matchMedia('(prefers-reduced-motion: reduce)').matches;

  /* tema */
  var KEY = 'ot-theme', tb = $('.theme-btn');
  if (tb) tb.addEventListener('click', function () {
    var cur = root.getAttribute('data-theme') || (matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');
    var next = cur === 'dark' ? 'light' : 'dark';
    root.setAttribute('data-theme', next);
    try { localStorage.setItem(KEY, next); } catch (e) {}
  });

  /* panel tarik-turun (Bidang, Bahasa) */
  var btns = $$('[data-drop]');
  var closeAll = function () { btns.forEach(function (b) { b.setAttribute('aria-expanded', 'false'); var p = d.getElementById(b.dataset.drop); if (p) p.classList.remove('open'); }); };
  btns.forEach(function (b) {
    b.addEventListener('click', function (e) {
      e.stopPropagation();
      var p = d.getElementById(b.dataset.drop), was = b.getAttribute('aria-expanded') === 'true';
      closeAll();
      if (!was) { b.setAttribute('aria-expanded', 'true'); p.classList.add('open'); }
    });
  });
  d.addEventListener('click', function (e) { if (!e.target.closest('.drop')) closeAll(); });
  d.addEventListener('keydown', function (e) { if (e.key === 'Escape') closeAll(); });

  /* menu ponsel */
  var mb = $('.menu-btn'), sheet = $('.sheet');
  if (mb && sheet) mb.addEventListener('click', function () {
    var o = sheet.classList.toggle('open'); mb.setAttribute('aria-expanded', o); d.body.style.overflow = o ? 'hidden' : '';
    var hd = $('header.site'); if (o && hd) sheet.style.top = Math.max(hd.getBoundingClientRect().bottom, 0) + 'px';
  });

  /* muncul perlahan */
  var rv = $$('.rv');
  if ('IntersectionObserver' in window && !reduce) {
    var io = new IntersectionObserver(function (es) {
      es.forEach(function (e) { if (e.isIntersecting) { e.target.classList.add('in'); io.unobserve(e.target); } });
    }, { rootMargin: '0px 0px -6% 0px', threshold: .06 });
    rv.forEach(function (n) { io.observe(n); });
  } else rv.forEach(function (n) { n.classList.add('in'); });

  /* demo jawaban */
  var qs = $$('.fx-item[role="tab"]');
  if (qs.length) {
    var panels = $$('.reply[role="tabpanel"]'), asked = $('#asked'), who = $('#who');
    var pick = function (i, focus) {
      qs.forEach(function (q, k) { q.setAttribute('aria-selected', k === i); q.tabIndex = k === i ? 0 : -1; });
      panels.forEach(function (p, k) { p.hidden = k !== i; });
      if (asked) asked.textContent = qs[i].getAttribute('data-q');
      if (who) who.textContent = qs[i].getAttribute('data-who');
      if (focus) qs[i].focus();
    };
    qs.forEach(function (q, i) {
      q.addEventListener('click', function () { pick(i); });
      q.addEventListener('keydown', function (e) {
        if (e.key === 'ArrowDown') { e.preventDefault(); pick((i + 1) % qs.length, true); }
        if (e.key === 'ArrowUp') { e.preventDefault(); pick((i - 1 + qs.length) % qs.length, true); }
      });
    });
    pick(0);
  }

  /* penjelajah bidang */
  var ex = $('.explorer');
  if (ex) {
    var cards = $$('.acard', ex), dets = $$('.detail', ex), rps = $$('.rumpun button');
    var show = function (id) {
      cards.forEach(function (c) { c.setAttribute('aria-pressed', c.dataset.id === id); });
      dets.forEach(function (x) { x.hidden = x.dataset.id !== id; });
    };
    cards.forEach(function (c) { c.addEventListener('click', function () { show(c.dataset.id); }); });
    var filter = function (g) {
      rps.forEach(function (x) { x.setAttribute('aria-pressed', x.dataset.g === g); });
      var first = null;
      cards.forEach(function (c) { var ok = g === 'all' || c.dataset.g === g; c.hidden = !ok; if (ok && !first) first = c; });
      if (first) show(first.dataset.id);
    };
    rps.forEach(function (b) { b.addEventListener('click', function () { filter(b.dataset.g); }); });
    var cari = $('#cari');
    if (cari) cari.addEventListener('input', function () {
      var q = cari.value.trim().toLowerCase(), first = null;
      cards.forEach(function (c) { var ok = !q || c.dataset.q.indexOf(q) > -1; c.hidden = !ok; if (ok && !first) first = c; });
      if (q) rps.forEach(function (x) { x.setAttribute('aria-pressed', x.dataset.g === 'all'); });
      if (first) show(first.dataset.id);
    });
    var def = $('.rumpun button[aria-pressed="true"]');
    var hash = location.hash.replace('#', '');
    if (hash && $('.rumpun button[data-g="' + hash + '"]')) filter(hash); else if (def) filter(def.dataset.g); else show(cards[0].dataset.id);
  }

  /* gerbang: sorot bagian logo */
  var gate = $('.gate');
  if (gate) {
    var rks = $$('.rk');
    var hl = function (v) { gate.setAttribute('data-hl', v || ''); rks.forEach(function (r) { r.classList.toggle('act', r.dataset.hl === v); }); };
    rks.forEach(function (r) {
      ['mouseenter', 'focus'].forEach(function (ev) { r.addEventListener(ev, function () { hl(r.dataset.hl); }); });
      ['mouseleave', 'blur'].forEach(function (ev) { r.addEventListener(ev, function () { hl(''); }); });
    });
    if ('IntersectionObserver' in window && !reduce) {
      var seq = ['islam', 'iman', 'ihsan', 'tahaw'];
      var go = new IntersectionObserver(function (es) {
        es.forEach(function (e) {
          if (!e.isIntersecting) return; go.disconnect();
          seq.forEach(function (v, i) { setTimeout(function () { if (!gate.matches(':hover')) hl(v); }, 500 + i * 650); });
          setTimeout(function () { hl(''); }, 500 + seq.length * 650 + 500);
        });
      }, { threshold: .5 });
      go.observe(gate);
    }
  }

  /* unduh: tandai platform */
  var ua = (navigator.userAgent || '').toLowerCase(), os = /android/.test(ua) ? 'android' : /mac/.test(ua) ? 'macos' : /win/.test(ua) ? 'windows' : '';
  $$('.plat').forEach(function (p) { if (p.dataset.os === os) { p.classList.add('rec'); var b = $('.rec-badge', p); if (b) b.hidden = false; } });

  /* lapor kesalahan -> mailto */
  var f = $('#report');
  if (f) f.addEventListener('submit', function (e) {
    e.preventDefault();
    var v = function (n) { return (f.elements[n] || {}).value || ''; };
    var body = 'Kutipan yang dipertanyakan:\n' + v('kutipan') + '\n\nKitab dan edisi yang saya pegang:\n' + v('kitab') + '\n\nAlasan:\n' + v('alasan');
    location.href = 'mailto:support@openturath.id?subject=' + encodeURIComponent('Laporan kesalahan: ' + v('bidang')) + '&body=' + encodeURIComponent(body);
  });

  /* paralaks lengkung di hero */
  var hero = $('.welcome');
  if (hero && !reduce && matchMedia('(pointer: fine)').matches) {
    hero.addEventListener('pointermove', function (e) { var r = hero.getBoundingClientRect(); hero.style.setProperty('--px', ((e.clientX - r.left) / r.width - .5) * 2); });
    hero.addEventListener('pointerleave', function () { hero.style.setProperty('--px', 0); });
  }
  /* ingat pilihan bahasa */
  $$('#langDrop a').forEach(function (a) { a.addEventListener('click', function () { try { localStorage.setItem('ot-lang', a.getAttribute('hreflang')); } catch (e) {} }); });
})();
