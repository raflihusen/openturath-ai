/* OpenTurath Manuskrip: slider before/after, titik jadi baris, kalkulator, form pesan.
   Berkas eksternal karena CSP produksi melarang skrip sebaris. */
(function () {
  'use strict';
  var d = document, root = d.documentElement;
  var $ = function (s, c) { return (c || d).querySelector(s); };
  var $$ = function (s, c) { return Array.prototype.slice.call((c || d).querySelectorAll(s)); };
  var reduce = matchMedia('(prefers-reduced-motion: reduce)').matches;
  var nofx = /[?&]nofx=1/.test(location.search) || root.classList.contains('nofx');
  var still = reduce || nofx;
  var clamp = function (v, a, b) { return Math.min(b, Math.max(a, v)); };

  /* ================= SLIDER ================= */
  (function () {
    var ba = $('#ba'); if (!ba) return;
    var handle = $('#ba-handle'), imgScan = $('#img-scan'), imgOut = $('#img-out');
    // Wilayah (x, y, lebar, tinggi; pecahan dari gambar) yang ditampilkan tiap tab, per sisi.
    var TABS = {
      full:  { ar: 0.72, scan: [0, 0, 1, 1],              out: [0, 0, 1, 1] },
      syair: { ar: 4.4,  scan: [0.04, 0.30, 0.92, 0.165], out: [0.04, 0.125, 0.92, 0.13] },
      ayat:  { ar: 2,    scan: [0.04, 0.52, 0.92, 0.32],  out: [0.04, 0.385, 0.92, 0.345] }
    };
    var tab = 'full', pos = 50, interacted = false, anim = 0;

    function place(img, r) {
      var W = img.naturalWidth, H = img.naturalHeight; if (!W || !H) return;
      var cw = ba.clientWidth, ch = ba.clientHeight;
      var s = Math.min(cw / (r[2] * W), ch / (r[3] * H));
      img.style.width = (W * s) + 'px';
      img.style.left = (cw / 2 - (r[0] + r[2] / 2) * W * s) + 'px';
      img.style.top = (ch / 2 - (r[1] + r[3] / 2) * H * s) + 'px';
    }
    function layout() {
      var t = TABS[tab];
      place(imgScan, t.scan); place(imgOut, t.out);
      if (imgScan.naturalWidth && imgOut.naturalWidth) ba.classList.add('ready');
    }
    function setPos(p) {
      pos = clamp(p, 0, 100);
      ba.style.setProperty('--pos', pos + '%');
      var v = Math.round(pos);
      handle.setAttribute('aria-valuenow', String(v));
      handle.setAttribute('aria-valuetext', 'Naskah asli ' + v + ' persen');
    }
    function stop() { if (anim) { cancelAnimationFrame(anim); anim = 0; } }
    function tween(to, ms, done) {
      stop();
      if (still) { setPos(to); if (done) done(); return; }
      var from = pos, t0 = performance.now();
      (function step(now) {
        var k = clamp((now - t0) / ms, 0, 1), e = 1 - Math.pow(1 - k, 3);
        setPos(from + (to - from) * e);
        if (k < 1) anim = requestAnimationFrame(step); else { anim = 0; if (done) done(); }
      })(t0);
    }
    function fromEvent(e) {
      var r = ba.getBoundingClientRect();
      return ((e.clientX - r.left) / r.width) * 100;
    }

    var dragging = false;
    ba.addEventListener('pointerdown', function (e) {
      if (e.pointerType === 'mouse' && e.button !== 0) return;
      interacted = true; stop();
      dragging = true; ba.classList.add('drag');
      try { ba.setPointerCapture(e.pointerId); } catch (_) {}
      var target = fromEvent(e);
      if (Math.abs(target - pos) > 12 && e.target.closest('.ba-handle') === null) tween(target, 240);
      else setPos(target);
    });
    ba.addEventListener('pointermove', function (e) {
      if (!dragging) return;
      stop(); setPos(fromEvent(e));
    });
    var end = function (e) {
      if (!dragging) return; dragging = false; ba.classList.remove('drag');
      try { ba.releasePointerCapture(e.pointerId); } catch (_) {}
    };
    ba.addEventListener('pointerup', end);
    ba.addEventListener('pointercancel', end);
    ba.addEventListener('lostpointercapture', function () { dragging = false; ba.classList.remove('drag'); });

    handle.addEventListener('keydown', function (e) {
      var step = e.shiftKey ? 10 : 3, k = e.key, n = null;
      if (k === 'ArrowLeft' || k === 'ArrowDown') n = pos - step;
      else if (k === 'ArrowRight' || k === 'ArrowUp') n = pos + step;
      else if (k === 'Home') n = 0;
      else if (k === 'End') n = 100;
      if (n === null) return;
      e.preventDefault(); interacted = true; stop(); setPos(n);
    });

    // Tab: ganti wilayah yang ditampilkan.
    var tabs = $$('.ba-tabs [data-tab]');
    tabs.forEach(function (b) {
      b.addEventListener('click', function () {
        if (b.dataset.tab === tab) return;
        tab = b.dataset.tab;
        tabs.forEach(function (x) { x.setAttribute('aria-selected', String(x === b)); });
        ba.classList.remove('ready');
        ba.style.setProperty('--ar', String(TABS[tab].ar));
        requestAnimationFrame(function () { requestAnimationFrame(layout); });
        interacted = true; tween(50, 450);
      });
    });

    [imgScan, imgOut].forEach(function (im) { if (im.complete) layout(); else im.addEventListener('load', layout); });
    if (window.ResizeObserver) new ResizeObserver(layout).observe(ba); else addEventListener('resize', layout);
    ba.style.setProperty('--ar', String(TABS.full.ar));
    setPos(50); layout();

    // Petunjuk sekali saja, saat pertama terlihat: garis bergeser sedikit.
    if (!still && window.IntersectionObserver) {
      var io = new IntersectionObserver(function (es) {
        if (!es[0].isIntersecting) return; io.disconnect();
        setTimeout(function () {
          if (interacted) return;
          tween(30, 700, function () { if (!interacted) tween(70, 900, function () { if (!interacted) tween(50, 600); }); });
        }, 500);
      }, { threshold: 0.6 });
      io.observe(ba);
    }
  })();

  /* ================= TITIK JADI BARIS ================= */
  (function () {
    var cv = $('#dots'); if (!cv) return;
    var ctx = cv.getContext('2d'); if (!ctx) return;
    var W = 0, H = 0, dpr = 1, P = [], rgb = '0,0,0', running = false, raf = 0, t0 = 0, visible = true;

    function readColor() {
      var c = getComputedStyle(cv).color.match(/[\d.]+/g);
      if (c && c.length >= 3) rgb = c[0] + ',' + c[1] + ',' + c[2];
    }
    function build() {
      var r = cv.getBoundingClientRect(); W = Math.max(1, r.width); H = Math.max(1, r.height);
      dpr = Math.min(2, window.devicePixelRatio || 1);
      cv.width = Math.round(W * dpr); cv.height = Math.round(H * dpr);
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
      var rows = W < 600 ? 14 : 12, left = W * 0.07, right = W * 0.93, top = H * 0.10, bot = H * 0.92;
      var spacing = Math.max(5, Math.sqrt((right - left) * rows * 0.78 / 760) * 1.5);
      P = [];
      for (var i = 0; i < rows; i++) {
        var y = top + (bot - top) * (i / (rows - 1));
        var x = right; // dibaca dari kanan ke kiri, seperti tulisan Arab
        while (x > left) {
          var wl = 36 + Math.random() * 96, end = Math.max(left, x - wl);
          for (; x > end; x -= spacing) {
            P.push({ tx: x, ty: y + (Math.random() - 0.5) * 2, x: Math.random() * W, y: Math.random() * H,
                     vx: (Math.random() - 0.5) * 0.25, vy: (Math.random() - 0.5) * 0.25,
                     delay: 500 + Math.random() * 1500 + (1 - x / W) * 500, k: 0.03 + Math.random() * 0.04, a: 0.55 + Math.random() * 0.45 });
          }
          x -= 14 + Math.random() * 14;
        }
      }
    }
    function frame(now) {
      if (!t0) t0 = now;
      var t = now - t0; ctx.clearRect(0, 0, W, H);
      var wave = W - ((t / 14) % (W * 1.4)); // sorot pelan bergerak dari kanan ke kiri
      for (var i = 0; i < P.length; i++) {
        var p = P[i];
        if (still || t > p.delay) { p.x += (p.tx - p.x) * (still ? 1 : p.k); p.y += (p.ty - p.y) * (still ? 1 : p.k); }
        else { p.x += p.vx; p.y += p.vy; if (p.x < 0 || p.x > W) p.vx *= -1; if (p.y < 0 || p.y > H) p.vy *= -1; }
        var settled = Math.abs(p.tx - p.x) < 1.5;
        var glow = settled ? Math.max(0, 1 - Math.abs(p.x - wave) / 140) : 0;
        ctx.fillStyle = 'rgba(' + rgb + ',' + (settled ? (0.28 + 0.5 * glow) * p.a : 0.16 * p.a) + ')';
        ctx.fillRect(p.x - 1, p.y - 1, 2, 2);
      }
      if (running && visible) raf = requestAnimationFrame(frame);
    }
    function start() { if (running || still) return; running = true; raf = requestAnimationFrame(frame); }
    function pause() { running = false; cancelAnimationFrame(raf); }

    readColor(); build();
    if (still) { frame(performance.now() + 1e6); }
    else {
      start();
      if (window.IntersectionObserver) new IntersectionObserver(function (es) { visible = es[0].isIntersecting; if (visible) { running = false; start(); } else pause(); }).observe(cv);
      d.addEventListener('visibilitychange', function () { if (d.hidden) pause(); else if (visible) { running = false; start(); } });
    }
    var rt; addEventListener('resize', function () { clearTimeout(rt); rt = setTimeout(function () { build(); if (still) frame(performance.now() + 1e6); }, 150); });
    new MutationObserver(function () { readColor(); if (still) frame(performance.now() + 1e6); }).observe(root, { attributes: true, attributeFilter: ['data-theme'] });
  })();

  /* ================= KALKULATOR ================= */
  (function () {
    var pages = $('#c-pages'); if (!pages) return;
    var words = $('#c-words'), plus = $('#c-plus'), total = $('#c-total'), formula = $('#c-formula'), max = $('#c-max');
    var rp = function (n) { return 'Rp ' + Math.round(n).toLocaleString('id-ID'); };
    function calc() {
      var p = Math.max(0, parseFloat(pages.value) || 0), w = Math.max(0, parseFloat(words.value) || 0);
      var rate = parseInt(($('input[name=c-type]:checked') || {}).value || '5000', 10) + (plus.checked ? 2500 : 0);
      var std = p * w / 250, sum = std * rate;
      total.textContent = rp(sum);
      formula.textContent = p.toLocaleString('id-ID') + ' × ' + w.toLocaleString('id-ID') + ' kata = ' +
        std.toLocaleString('id-ID', { maximumFractionDigits: 1 }) + ' halaman standar × ' + rp(rate);
      max.textContent = 'Tagihan akhir tidak melebihi ' + rp(sum * 1.1) + ' (perkiraan + 10%).';
    }
    $$('#calc input').forEach(function (i) { i.addEventListener('input', calc); i.addEventListener('change', calc); });
    calc();
  })();

  /* ================= FORM PESAN ================= */
  (function () {
    var f = $('#order'); if (!f) return;
    var note = $('#order-note');
    f.addEventListener('submit', function (e) {
      e.preventDefault();
      if (!f.checkValidity()) { f.reportValidity(); return; }
      var v = function (n) { return (f.elements[n] && f.elements[n].value || '').trim(); };
      var body = [
        'Nama: ' + v('nama'), 'Email: ' + v('email'), 'Jenis naskah: ' + v('jenis'),
        'Perkiraan halaman: ' + (v('halaman') || '-'), 'Catatan: ' + (v('catatan') || '-'), '',
        'Saya berhak memproses naskah ini dan menyetujui ketentuan.', '',
        '(Lampirkan 3 halaman contoh pada email ini.)'
      ].join('\n');
      location.href = 'mailto:support@openturath.id?subject=' + encodeURIComponent('Uji 3 halaman: OpenTurath Manuskrip') + '&body=' + encodeURIComponent(body);
      note.textContent = 'Email terbuka. Lampirkan 3 halaman naskah lalu kirim. Bila email tidak terbuka, tulis langsung ke support@openturath.id.';
    });
  })();
})();
