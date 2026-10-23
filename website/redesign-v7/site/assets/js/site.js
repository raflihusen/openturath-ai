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
    drawRing();
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

  /* cincin partikel di hero */
  var cv = $('#ring'), ctx = cv && cv.getContext('2d'), P = [], W = 0, H = 0, mx = -999, my = -999, running = false, raf;
  function size() {
    if (!cv) return;
    var dpr = Math.min(devicePixelRatio || 1, 2);
    W = Math.min(1240, cv.parentNode.clientWidth); H = Math.min(600, Math.round(W * .5));
    cv.width = W * dpr; cv.height = H * dpr; cv.style.width = W + 'px'; cv.style.height = H + 'px';
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    var n = W < 700 ? 90 : 190; P = [];
    for (var i = 0; i < n; i++) {
      var a = Math.random() * Math.PI * 2, band = (Math.random() + Math.random() + Math.random() - 1.5) * .22;
      P.push({ a: a, b: band, v: (Math.random() * .0016 + .0004) * (Math.random() < .5 ? 1 : -1), s: Math.random() * 2 + .6, o: Math.random() * .45 + .12, x: 0, y: 0, dx: 0, dy: 0 });
    }
  }
  function drawRing() {
    if (!cv) return;
    var col = getComputedStyle(root).getPropertyValue('--on-surface').trim() || '#121317';
    ctx.clearRect(0, 0, W, H); ctx.fillStyle = col;
    var cx = W / 2, cy = H * .56, rx = W * .44, ry = H * .46;
    P.forEach(function (p) {
      var k = 1 + p.b, bx = cx + Math.cos(p.a) * rx * k, by = cy + Math.sin(p.a) * ry * k;
      var ddx = bx - mx, ddy = by - my, dist = Math.sqrt(ddx * ddx + ddy * ddy);
      var tx = 0, ty = 0; if (dist < 110) { var f = (110 - dist) / 110 * 26; tx = ddx / dist * f; ty = ddy / dist * f; }
      p.dx += (tx - p.dx) * .08; p.dy += (ty - p.dy) * .08;
      ctx.globalAlpha = p.o; ctx.beginPath(); ctx.arc(bx + p.dx, by + p.dy, p.s, 0, 6.283); ctx.fill();
    });
    ctx.globalAlpha = 1;
  }
  function loop() { if (!running) return; P.forEach(function (p) { p.a += p.v; }); drawRing(); raf = requestAnimationFrame(loop); }
  if (cv) {
    size(); drawRing();
    if (!reduce) {
      cv.parentNode.addEventListener('pointermove', function (e) { var r = cv.getBoundingClientRect(); mx = e.clientX - r.left; my = e.clientY - r.top; });
      cv.parentNode.addEventListener('pointerleave', function () { mx = my = -999; });
      if ('IntersectionObserver' in window) new IntersectionObserver(function (es) {
        var on = es[0].isIntersecting; if (on && !running) { running = true; loop(); } if (!on) { running = false; cancelAnimationFrame(raf); }
      }).observe(cv);
    }
    var rt; addEventListener('resize', function () { clearTimeout(rt); rt = setTimeout(function () { size(); drawRing(); }, 150); });
  }
})();
