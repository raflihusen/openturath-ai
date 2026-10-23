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
      var p = panels[i] && $('p', panels[i]);
      if (p && !reduce) {
        var full = p.getAttribute('data-full') || p.textContent; p.setAttribute('data-full', full); clearInterval(p._t);
        var rest = $$('.ibarah,.src', panels[i]); rest.forEach(function (x) { x.style.opacity = 0; x.style.transition = 'opacity .5s'; });
        var k = 0; p.textContent = '';
        p._t = setInterval(function () { k += 2; p.textContent = full.slice(0, k); if (k >= full.length) { clearInterval(p._t); rest.forEach(function (x) { x.style.opacity = 1; }); } }, 16);
      }
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

  /* hero: medan titik simetris, bergelombang keluar dari logo */
  var cv = $('#ring');
  if (cv) {
    var ctx = cv.getContext('2d'), hero = cv.parentNode, DOTS = [], AV = [], W = 0, H = 0, cx = 0, cy = 0, mx = -999, my = -999, running = false, raf, t0 = performance.now();
    var rgba = function (c, a) {
      var m = /^#([0-9a-f]{6})$/i.exec(c) || [0, '121317']; var v = parseInt(m[1], 16);
      return 'rgba(' + (v >> 16) + ',' + (v >> 8 & 255) + ',' + (v & 255) + ',' + a + ')';
    };
    var color = function () { var c = getComputedStyle(root).getPropertyValue('--on-surface').trim(); if (c.indexOf('#') !== 0) c = '#121317'; return c; };
    var layout = function () {
      var r = hero.getBoundingClientRect(), dpr = Math.min(devicePixelRatio || 1, 2);
      W = r.width; H = r.height; cv.width = W * dpr; cv.height = H * dpr; cv.style.width = W + 'px'; cv.style.height = H + 'px'; ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
      var m = $('.hero-mark', hero).getBoundingClientRect(); cx = W / 2; cy = m.top - r.top + m.height / 2;
      AV = ['.eyebrow-brand', 'h1.hero', '.lede', '.cta-row', '.meta-row'].map(function (s) { var e = $(s, hero); if (!e) return null; var b = e.getBoundingClientRect(); return { l: b.left - r.left - 28, r: b.right - r.left + 28, t: b.top - r.top - 14, b: b.bottom - r.top + 14 }; }).filter(Boolean);
      var gap = W < 760 ? 20 : 25, rmax = Math.hypot(Math.max(cx, W - cx), Math.max(cy, H - cy)) + gap, k, i, n, a, rr, x, y;
      DOTS = [];
      for (k = 3; k * gap < rmax; k++) {
        rr = k * gap; n = Math.max(12, Math.round(6.2832 * rr / gap / 2) * 2);
        for (i = 0; i < n; i++) {
          a = i / n * 6.2832 + (k % 2 ? 3.1416 / n : 0); x = cx + Math.cos(a) * rr; y = cy + Math.sin(a) * rr;
          if (x < -4 || x > W + 4 || y < -4 || y > H + 4) continue;
          DOTS.push({ a: a, r: rr, k: k, x: x, y: y });
        }
      }
    };
    var shade = function (x, y) {
      var f = 1; for (var i = 0; i < AV.length; i++) { var q = AV[i]; if (x > q.l && x < q.r && y > q.t && y < q.b) { f = .12; break; } } return f;
    };
    var draw = function (now) {
      var t = (now - t0) / 1000, e = reduce ? 1 : 1 - Math.pow(1 - Math.min(1, t / 2.2), 3), col = color(), mv = reduce ? 0 : 1, reach = e * (Math.hypot(W, H) + 60);
      ctx.clearRect(0, 0, W, H);
      for (var i = 0; i < DOTS.length; i++) {
        var p = DOTS[i], w = Math.sin(p.r * .021 - t * 1.25 * mv), rad = p.r + w * 3.2 * mv, x = cx + Math.cos(p.a) * rad, y = cy + Math.sin(p.a) * rad;
        if (p.r > reach) continue;
        var dx = x - mx, dy = y - my, d = Math.hypot(dx, dy);
        if (d < 120 && d > 0) { var f = (120 - d) / 120 * 14; x += dx / d * f; y += dy / d * f; }
        var fade = Math.min(1, p.r / 150), edge = Math.min(1, (reach - p.r) / 90), sz = (.9 + p.r / 900 + (w + 1) * .45) * (W < 760 ? .85 : 1);
        var al = (.2 + (w + 1) * .26) * fade * edge * shade(x, y);
        ctx.fillStyle = rgba(col, al); ctx.beginPath(); ctx.arc(x, y, sz, 0, 6.2832); ctx.fill();
      }
    };
    var loop = function (now) { if (!running) return; draw(now); raf = requestAnimationFrame(loop); };
    var start = function () { layout(); draw(performance.now()); if (!reduce && 'IntersectionObserver' in window) new IntersectionObserver(function (es) { var on = es[0].isIntersecting; if (on && !running) { running = true; raf = requestAnimationFrame(loop); } if (!on) { running = false; cancelAnimationFrame(raf); } }).observe(cv); };
    (document.fonts && document.fonts.ready ? document.fonts.ready : Promise.resolve()).then(start);
    if (document.fonts && document.fonts.addEventListener) document.fonts.addEventListener('loadingdone', function () { layout(); if (reduce) draw(performance.now()); });
    var rt; addEventListener('resize', function () { clearTimeout(rt); rt = setTimeout(function () { layout(); if (reduce) draw(performance.now()); }, 150); });
    if (matchMedia('(pointer: fine)').matches) {
      hero.addEventListener('pointermove', function (e) { var r = hero.getBoundingClientRect(); mx = e.clientX - r.left; my = e.clientY - r.top; if (reduce) draw(performance.now()); });
      hero.addEventListener('pointerleave', function () { mx = my = -999; if (reduce) draw(performance.now()); });
    }
    /* paralaks halus saat gulir */
    if (!reduce) addEventListener('scroll', function () { var y = scrollY; if (y < H) { hero.style.setProperty('--sy', Math.min(y, 600)); } }, { passive: true });
  }

  /* sorotan mengikuti kursor pada kartu */
  if (matchMedia('(pointer: fine)').matches && !reduce) {
    d.addEventListener('pointermove', function (e) {
      var c = e.target.closest && e.target.closest('.case,.pillar,.trio>div,.eco a,.eco .e,.steps6>div,.plat,.quad>div'); if (!c) return;
      var r = c.getBoundingClientRect(); c.style.setProperty('--mx', (e.clientX - r.left) + 'px'); c.style.setProperty('--my', (e.clientY - r.top) + 'px');
    }, { passive: true });
  }
  /* garis kemajuan gulir */
  var bar = d.createElement('div'); bar.className = 'progress'; bar.setAttribute('aria-hidden', 'true'); d.body.appendChild(bar);
  var prog = function () { var h = d.documentElement.scrollHeight - innerHeight; bar.style.transform = 'scaleX(' + (h > 0 ? scrollY / h : 0) + ')'; };
  addEventListener('scroll', prog, { passive: true }); prog();

  /* daftar isi halaman hukum: tandai bagian yang sedang dibaca */
  var toc = $$('.legal .toc a');
  if (toc.length && 'IntersectionObserver' in window) {
    var secs = $$('.legal article section');
    var tio = new IntersectionObserver(function (es) {
      es.forEach(function (e) { if (e.isIntersecting) { toc.forEach(function (a) { a.classList.toggle('on', a.getAttribute('href') === '#' + e.target.id); }); } });
    }, { rootMargin: '-20% 0px -70% 0px' });
    secs.forEach(function (s) { tio.observe(s); });
  }
  /* ingat pilihan bahasa */
  $$('#langDrop a').forEach(function (a) { a.addEventListener('click', function () { try { localStorage.setItem('ot-lang', a.getAttribute('hreflang')); } catch (e) {} }); });
})();
