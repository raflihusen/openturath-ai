/* OpenTurath Manuskrip: slider before/after, naskah ditulis, kalkulator, form pesan.
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
    var handle = $('#ba-handle'), imgScan = $('#img-scan');
    var FULL = [0, 0, 1, 1], AR = 0.72, pos = 50, interacted = false, anim = 0;

    function place(img, r) {
      var W = img.naturalWidth, H = img.naturalHeight; if (!W || !H) return;
      var cw = ba.clientWidth, ch = ba.clientHeight;
      var s = Math.min(cw / (r[2] * W), ch / (r[3] * H));
      img.style.width = (W * s) + 'px';
      img.style.left = (cw / 2 - (r[0] + r[2] / 2) * W * s) + 'px';
      img.style.top = (ch / 2 - (r[1] + r[3] / 2) * H * s) + 'px';
    }
    function layout() {
      place(imgScan, FULL);
      if (imgScan.naturalWidth) ba.classList.add('ready');
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

    [imgScan].forEach(function (im) { if (im.complete) layout(); else im.addEventListener('load', layout); });
    if (window.ResizeObserver) new ResizeObserver(layout).observe(ba); else addEventListener('resize', layout);
    ba.style.setProperty('--ar', String(AR));
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

  /* ================= LEMBARAN NASKAH MELAYANG ================= */
  // Lembaran kitab abstrak yang melayang pelan dan berputar di belakang hero, seperti
  // tumpukan halaman yang dibalik. Sengaja pudar dan kabur (blur CSS) agar tak mengganggu bacaan.
  (function () {
    var cv = $('#dots'); if (!cv) return;
    var ctx = cv.getContext('2d'); if (!ctx) return;
    var WORDS = ('العلم هذا شريف ولا شيء أشرف منه وقال الله تعالى ثلث بأهل العلم والإنسان يمتثل الأوامر ويجتنب النواهي ' +
      'إذا جاء في المذاكرة شيء من سير السلف فاكتبوه إذا ما انتفعتم به أنتم انتفع به غيركم دونوا سير سلفهم ' +
      'تفوت كرامات الرجال شواردا إذا لم تقيدها علينا الدفاتر وهذا أوان الشروع في المقصود فأقول قال سيدي رضي الله عنه').split(' ');
    var W = 0, H = 0, dpr = 1, rgb = '0,0,0', light = false, sheets = [], raf = 0, last = 0, running = false, visible = true, simT = 0;
    var rnd = (function (seed) { return function () { seed = (seed * 16807) % 2147483647; return (seed - 1) / 2147483646; }; })(1369);

    function readColor() {
      var c = getComputedStyle(cv).color.match(/[\d.]+/g);
      if (c && c.length >= 3) rgb = c[0] + ',' + c[1] + ',' + c[2];
      var bg = getComputedStyle(d.body).backgroundColor.match(/[\d.]+/g);
      light = !!bg && bg.length >= 3 && (0.299 * bg[0] + 0.587 * bg[1] + 0.114 * bg[2]) > 140;
    }
    // Satu lembar: kartu bersudut membulat berisi baris-baris Arab dari kanan ke kiri.
    function sprite(w, h) {
      var q = Math.max(0.5, dpr * 0.55); // resolusi rendah: lembar tampak lembut tanpa filter yang berat
      var c = document.createElement('canvas'); c.width = Math.ceil(w * q); c.height = Math.ceil(h * q);
      var g = c.getContext('2d'); g.setTransform(q, 0, 0, q, 0, 0);
      var r = Math.min(w, h) * 0.05;
      g.beginPath(); g.moveTo(r, 0); g.arcTo(w, 0, w, h, r); g.arcTo(w, h, 0, h, r); g.arcTo(0, h, 0, 0, r); g.arcTo(0, 0, w, 0, r); g.closePath();
      if (light) { // mode terang: kertas krem kecokelatan, tinta cokelat tua
        var pg = g.createLinearGradient(0, 0, w, h); pg.addColorStop(0, '#F4E9D2'); pg.addColorStop(1, '#E6D4B0');
        g.fillStyle = pg; g.fill(); g.lineWidth = 1.2; g.strokeStyle = 'rgba(120,88,50,0.45)'; g.stroke();
      } else { g.fillStyle = 'rgba(' + rgb + ',0.07)'; g.fill(); g.lineWidth = 1.2; g.strokeStyle = 'rgba(' + rgb + ',0.22)'; g.stroke(); }
      g.direction = 'rtl'; g.textAlign = 'right'; g.textBaseline = 'alphabetic';
      var size = w / 11, lh = size * 1.9, pad = w * 0.1, y = pad + size, wi = Math.floor(rnd() * WORDS.length);
      g.fillStyle = light ? 'rgba(74,46,24,0.62)' : 'rgba(' + rgb + ',0.5)'; g.font = size + 'px "OT Naskh", "Scheherazade New", serif';
      while (y < h - pad * 0.8) {
        var x = w - pad, left = pad + rnd() * w * 0.12;
        while (true) {
          var word = WORDS[wi++ % WORDS.length], mw = g.measureText(word).width;
          if (x - mw < left) break;
          g.fillText(word, x, y + (rnd() - 0.5) * 1.6); x -= mw + size * 0.35;
        }
        y += lh;
      }
      return c;
    }
    function build() {
      var r = cv.getBoundingClientRect(); W = Math.max(1, r.width); H = Math.max(1, r.height);
      dpr = Math.min(1.5, window.devicePixelRatio || 1);
      cv.width = Math.round(W * dpr); cv.height = Math.round(H * dpr);
      var n = W < 600 ? 7 : 11; sheets = [];
      for (var i = 0; i < n; i++) {
        var depth = 0.45 + rnd() * 0.75, w = clamp(W * 0.22, 150, 260) * depth, h = w * 1.34;
        sheets.push({
          img: sprite(w, h), w: w, h: h, depth: depth,
          x0: rnd() * W, y0: rnd() * (H + h) - h / 2,
          vx: (rnd() - 0.5) * 7 * depth, vy: -(5 + rnd() * 9) * depth, // px per detik, naik perlahan
          rot: (rnd() - 0.5) * 0.9, vr: (rnd() - 0.5) * 0.035, flip: rnd() * 6.283, vf: 0.12 + rnd() * 0.18
        });
      }
    }
    function drawAt(t) {
      ctx.setTransform(1, 0, 0, 1, 0, 0); ctx.clearRect(0, 0, cv.width, cv.height);
      for (var i = 0; i < sheets.length; i++) {
        var p = sheets[i], span = H + p.h * 2;
        var y = ((p.y0 + p.vy * t + p.h) % span + span) % span - p.h;
        var x = p.x0 + p.vx * t + Math.sin(t * 0.25 + i) * 14 * p.depth;
        var sx = 0.78 + 0.22 * Math.cos(p.flip + t * p.vf); // lembar seperti perlahan dibalik
        ctx.globalAlpha = clamp(0.35 + p.depth * 0.5, 0, 0.95);
        ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
        ctx.translate(((x % (W + p.w)) + W + p.w) % (W + p.w) - p.w / 2, y);
        ctx.rotate(p.rot + p.vr * t); ctx.scale(sx, 1);
        if (light) { ctx.shadowColor = 'rgba(70,45,20,0.28)'; ctx.shadowBlur = 20 * p.depth; ctx.shadowOffsetY = 10 * p.depth; }
        ctx.drawImage(p.img, -p.w / 2, -p.h / 2, p.w, p.h);
        if (light) { ctx.shadowColor = 'transparent'; }
        // sisi lembar yang miring ke arah cahaya lebih gelap: kesan lengkung dan kedalaman
        var sh = (1 - sx) * (light ? 1.3 : 0.9);
        if (sh > 0.02) { ctx.fillStyle = light ? 'rgba(80,50,20,' + sh + ')' : 'rgba(0,0,0,' + sh + ')'; ctx.fillRect(-p.w / 2, -p.h / 2, p.w, p.h); }
      }
      ctx.globalAlpha = 1;
    }
    function frame(now) {
      if (!last) last = now;
      simT += Math.min(0.05, (now - last) / 1000); last = now;
      drawAt(simT);
      if (running && visible) raf = requestAnimationFrame(frame);
    }
    function start() { if (running || still) return; running = true; last = 0; raf = requestAnimationFrame(frame); }
    function pause() { running = false; cancelAnimationFrame(raf); }
    function draw() { build(); if (still) drawAt(40); else start(); }

    readColor();
    var go = function () { draw(); };
    if (d.fonts && d.fonts.load) d.fonts.load('32px "OT Naskh"', 'العلم').then(go, go); else go();
    if (!still && window.IntersectionObserver) new IntersectionObserver(function (es) { visible = es[0].isIntersecting; if (visible) { running = false; start(); } else pause(); }).observe(cv);
    d.addEventListener('visibilitychange', function () { if (d.hidden) pause(); else if (visible && !still) { running = false; start(); } });
    var rt; addEventListener('resize', function () { clearTimeout(rt); rt = setTimeout(function () { pause(); draw(); }, 150); });
    new MutationObserver(function () { readColor(); pause(); draw(); }).observe(root, { attributes: true, attributeFilter: ['data-theme'] });
  })();

  /* ================= KALKULATOR ================= */
  (function () {
    var pages = $('#c-pages'); if (!pages) return;
    var words = $('#c-words'), plus = $('#c-plus'), total = $('#c-total'), formula = $('#c-formula'), max = $('#c-max');
    var rp = function (n) { return 'Rp ' + Math.round(n).toLocaleString('id-ID'); };
    function calc() {
      var p = Math.max(0, parseFloat(pages.value) || 0), w = Math.max(0, parseFloat(words.value) || 0);
      var rate = parseInt(($('input[name=c-type]:checked') || {}).value || '20', 10) + (plus.checked ? 10 : 0);
      var kata = p * w, sum = kata * rate;
      total.textContent = rp(sum);
      formula.textContent = p.toLocaleString('id-ID') + ' × ' + w.toLocaleString('id-ID') + ' = ' +
        kata.toLocaleString('id-ID') + ' kata × ' + rp(rate);
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
