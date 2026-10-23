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

  /* hero: nama-nama ilmu (Arab) yang saling tersambung dan bermuara ke logo */
  var cv = $('#ring');
  if (cv) {
    var SC = [['التفسير','quran'],['علوم القرآن','quran'],['التجويد','quran'],['القراءات','quran'],['الحديث','hadis'],['مصطلح الحديث','hadis'],['الجرح والتعديل','hadis'],['التراجم','hadis'],['شروح الحديث','hadis'],
              ['الفقه','fikih'],['الفقه الشافعي','fikih'],['الفقه المقارن','fikih'],['الفرائض','fikih'],['الفتاوى','fikih'],['أصول الفقه','ushul'],['القواعد الفقهية','ushul'],['المقاصد','ushul'],
              ['العقيدة','akidah'],['علم الكلام','akidah'],['التصوف','akidah'],['التزكية','akidah'],['فقه التحولات','tahaw'],['النحو','bahasa'],['الصرف','bahasa'],['البلاغة','bahasa'],['المنطق','bahasa'],
              ['السيرة','bahasa'],['التاريخ','bahasa'],['الفهارس','bahasa'],['الأنساب','bahasa'],['الأدب','bahasa']];
    var ctx = cv.getContext('2d'), hero = cv.parentNode, N = [], D = [], P = [], W = 0, H = 0, cx = 0, cy = 0, mx = -999, my = -999, hov = -1, running = false, raf, t0 = performance.now(), glow = 0;
    var rng = function (s) { return function () { s |= 0; s = s + 0x6D2B79F5 | 0; var t = Math.imul(s ^ s >>> 15, 1 | s); t = t + Math.imul(t ^ t >>> 7, 61 | t) ^ t; return ((t ^ t >>> 14) >>> 0) / 4294967296; }; };
    var rgba = function (c, a) {
      var m = /^#([0-9a-f]{6})$/i.exec(c) || [0, '121317']; var v = parseInt(m[1], 16);
      return 'rgba(' + (v >> 16) + ',' + (v >> 8 & 255) + ',' + (v & 255) + ',' + a + ')';
    };
    var color = function () { var c = getComputedStyle(root).getPropertyValue('--on-surface').trim(); if (c.indexOf('#') !== 0) c = '#121317'; return c; };
    var layout = function () {
      var r = hero.getBoundingClientRect(), dpr = Math.min(devicePixelRatio || 1, 2);
      W = r.width; H = r.height; cv.width = W * dpr; cv.height = H * dpr; cv.style.width = W + 'px'; cv.style.height = H + 'px'; ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
      var m = $('.hero-mark', hero).getBoundingClientRect(); cx = m.left - r.left + m.width / 2; cy = m.top - r.top + m.height / 2;
      var av = ['.eyebrow-brand', 'h1.hero', '.lede', '.cta-row', '.meta-row'].map(function (s) { var e = $(s, hero); if (!e) return null; var b = e.getBoundingClientRect(); return { l: b.left - r.left, r: b.right - r.left, t: b.top - r.top - 40, b: b.bottom - r.top + 40 }; }).filter(Boolean);
      var small = W < 760, list = small ? SC.filter(function (_, i) { return i % 2 === 0; }) : SC, R = rng(11);
      N = []; D = [];
      list.forEach(function (s, idx) {
        var x, y, tries = 0, a, f, bad, fs = (small ? 15 : 19) + R() * 5, w = s[0].length * fs * .5 + 8;
        do {
          a = (idx / list.length) * 6.2832 + (R() - .5) * 1.6 + tries * .37; f = .42 + R() * .58; x = cx + Math.cos(a) * W * .47 * f; y = cy + Math.sin(a) * Math.max(H * .52, cy + 20) * f; tries++;
          bad = x < 50 || x > W - 50 || y < 26 || y > H - 26 || Math.hypot(x - cx, y - cy) < 120 ||
            av.some(function (q) { return x > q.l - 90 && x < q.r + 90 && y > q.t && y < q.b; }) ||
            N.some(function (q) { return Math.abs(q.bx - x) < (q.w + w) / 2 + 18 && Math.abs(q.by - y) < 36; });
        } while (bad && tries < 400);
        if (!bad) N.push({ s: s[0], g: s[1], bx: x, by: y, w: w, ph: R() * 6.28, amp: 4 + R() * 7, sp: .25 + R() * .35, o: .5 + R() * .4, fs: fs, x: x, y: y });
      });
      N.forEach(function (n, i) { n.nb = N.map(function (m, j) { return [j, Math.hypot(m.bx - n.bx, m.by - n.by)]; }).filter(function (p) { return p[0] !== i; }).sort(function (a, b) { return a[1] - b[1]; }).slice(0, 2).map(function (p) { return p[0]; }); });
      var nd = small ? 46 : 120;
      for (var i = 0; i < nd; i++) { var a2 = R() * 6.2832, f2 = .4 + R() * .7, x2 = cx + Math.cos(a2) * W * .5 * f2, y2 = cy + Math.sin(a2) * Math.max(H * .55, cy) * f2; if (av.some(function (q) { return x2 > q.l && x2 < q.r && y2 > q.t && y2 < q.b; })) continue; D.push({ bx: x2, by: y2, ph: R() * 6.28, s: .6 + R() * 1.5, o: .14 + R() * .3 }); }
    };
    var draw = function (now) {
      var t = (now - t0) / 1000, e = reduce ? 1 : 1 - Math.pow(1 - Math.min(1, t / 1.9), 3), col = color(), mv = reduce ? 0 : 1;
      ctx.clearRect(0, 0, W, H);
      N.forEach(function (n) {
        var px = n.bx + Math.cos(t * n.sp + n.ph) * n.amp * mv, py = n.by + Math.sin(t * n.sp * 1.3 + n.ph) * n.amp * mv, dx = px - mx, dy = py - my, d = Math.hypot(dx, dy);
        if (d < 130 && d > 0) { var f = (130 - d) / 130 * 16; px += dx / d * f; py += dy / d * f; }
        n.x = cx + (px - cx) * e; n.y = cy + (py - cy) * e; n.qx = (n.x + cx) / 2 + (n.y - cy) * .14; n.qy = (n.y + cy) / 2 - (n.x - cx) * .14;
      });
      ctx.lineWidth = 1;
      N.forEach(function (n, i) { ctx.strokeStyle = rgba(col, (hov === i ? .55 : .12) * e); ctx.beginPath(); ctx.moveTo(n.x, n.y); ctx.quadraticCurveTo(n.qx, n.qy, cx, cy); ctx.stroke(); });
      N.forEach(function (n, i) { n.nb.forEach(function (j) { if (j < i && N[j].nb.indexOf(i) > -1) return; var m = N[j]; ctx.strokeStyle = rgba(col, .075 * e); ctx.beginPath(); ctx.moveTo(n.x, n.y); ctx.lineTo(m.x, m.y); ctx.stroke(); }); });
      D.forEach(function (d) { var x = d.bx + Math.cos(t * .3 + d.ph) * 6 * mv, y = d.by + Math.sin(t * .4 + d.ph) * 6 * mv; ctx.fillStyle = rgba(col, d.o * e); ctx.beginPath(); ctx.arc(cx + (x - cx) * e, cy + (y - cy) * e, d.s, 0, 6.2832); ctx.fill(); });
      if (!reduce && e > .98) {
        if (Math.random() < .07 && P.length < 9) P.push({ i: (Math.random() * N.length) | 0, p: 0, v: .006 + Math.random() * .006 });
        P = P.filter(function (q) {
          q.p += q.v; var n = N[q.i]; if (!n) return false; var p = q.p, u = 1 - p;
          if (p >= 1) { glow = 1; return false; }
          ctx.fillStyle = rgba(col, .75); ctx.beginPath(); ctx.arc(u * u * n.x + 2 * u * p * n.qx + p * p * cx, u * u * n.y + 2 * u * p * n.qy + p * p * cy, 2.2, 0, 6.2832); ctx.fill(); return true;
        });
      }
      if (glow > .01) { ctx.strokeStyle = rgba(col, glow * .3); ctx.lineWidth = 1.5; ctx.beginPath(); ctx.arc(cx, cy, 52 + (1 - glow) * 22, 0, 6.2832); ctx.stroke(); glow *= .94; }
      ctx.textAlign = 'center'; ctx.textBaseline = 'middle';
      N.forEach(function (n, i) {
        var hv = hov === i; ctx.font = Math.round(n.fs * (hv ? 1.15 : 1)) + 'px "OT Naskh","Scheherazade New",serif';
        ctx.fillStyle = rgba(col, (hv ? 1 : n.o) * Math.min(1, e * 1.5)); ctx.fillText(n.s, n.x, n.y);
      });
    };
    var loop = function (now) { if (!running) return; draw(now); raf = requestAnimationFrame(loop); };
    var start = function () { layout(); draw(performance.now()); if (!reduce && 'IntersectionObserver' in window) new IntersectionObserver(function (es) { var on = es[0].isIntersecting; if (on && !running) { running = true; raf = requestAnimationFrame(loop); } if (!on) { running = false; cancelAnimationFrame(raf); } }).observe(cv); };
    (document.fonts && document.fonts.load ? document.fonts.load('20px "OT Naskh"', 'التفسير').catch(function () {}) : Promise.resolve()).then(function () { return document.fonts && document.fonts.ready ? document.fonts.ready : null; }).then(start);
    if (document.fonts && document.fonts.addEventListener) document.fonts.addEventListener('loadingdone', function () { layout(); if (reduce) draw(performance.now()); });
    var rt; addEventListener('resize', function () { clearTimeout(rt); rt = setTimeout(function () { layout(); if (reduce) draw(performance.now()); }, 150); });
    if (matchMedia('(pointer: fine)').matches) {
      hero.addEventListener('pointermove', function (e) {
        var r = hero.getBoundingClientRect(); mx = e.clientX - r.left; my = e.clientY - r.top; var best = -1, bd = 36;
        N.forEach(function (n, i) { var d = Math.hypot(n.x - mx, n.y - my); if (d < bd) { bd = d; best = i; } });
        hov = best; hero.style.cursor = best > -1 && !e.target.closest('a,button,h1,p') ? 'pointer' : '';
        if (reduce) draw(performance.now());
      });
      hero.addEventListener('pointerleave', function () { mx = my = -999; hov = -1; hero.style.cursor = ''; if (reduce) draw(performance.now()); });
      hero.addEventListener('click', function (e) { if (hov > -1 && !e.target.closest('a,button')) location.href = 'bidang.html#' + N[hov].g; });
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
