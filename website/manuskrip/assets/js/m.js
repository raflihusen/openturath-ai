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

  /* ================= NASKAH DITULIS ================= */
  // Halaman naskah Arab yang "ditulis" dari kanan ke kiri dengan kalam, baris demi baris,
  // lalu sorot pemindai menyapu halaman. Kata-kata diambil dari halaman contoh di bawah.
  (function () {
    var cv = $('#dots'); if (!cv) return;
    var ctx = cv.getContext('2d'); if (!ctx) return;
    var WORDS = ('العلم هذا شريف ولا شيء أشرف منه وقال الله تعالى ثلث بأهل العلم والإنسان يمتثل الأوامر ويجتنب النواهي ' +
      'إذا جاء في المذاكرة شيء من سير السلف فاكتبوه إذا ما انتفعتم به أنتم انتفع به غيركم دونوا سير سلفهم ' +
      'تفوت كرامات الرجال شواردا إذا لم تقيدها علينا الدفاتر وهذا أوان الشروع في المقصود فأقول قال سيدي رضي الله عنه').split(' ');
    var W = 0, H = 0, dpr = 1, rgb = '0,0,0', lines = [], page = null, raf = 0, t0 = 0, running = false, visible = true, ready = false;
    var rnd = (function (seed) { return function () { seed = (seed * 16807) % 2147483647; return (seed - 1) / 2147483646; }; })(20261029);
    var WRITE = 900, GAP = 420, HOLD = 2600; // ms per baris, jeda antar baris, tahan sebelum mengulang

    function readColor() {
      var c = getComputedStyle(cv).color.match(/[\d.]+/g);
      if (c && c.length >= 3) rgb = c[0] + ',' + c[1] + ',' + c[2];
    }
    function build() {
      var r = cv.getBoundingClientRect(); W = Math.max(1, r.width); H = Math.max(1, r.height);
      dpr = Math.min(2, window.devicePixelRatio || 1);
      cv.width = Math.round(W * dpr); cv.height = Math.round(H * dpr);
      page = document.createElement('canvas'); page.width = cv.width; page.height = cv.height;
      var g = page.getContext('2d'); g.setTransform(dpr, 0, 0, dpr, 0, 0);
      g.direction = 'rtl'; g.textAlign = 'right'; g.textBaseline = 'alphabetic';
      var size = clamp(W / 26, 20, 40), lh = size * 1.95, rows = Math.max(4, Math.floor((H * 0.86) / lh));
      var left = W * 0.06, right = W * 0.94, top = H * 0.08 + lh * 0.8;
      lines = []; var wi = Math.floor(rnd() * WORDS.length), marked = 0;
      for (var i = 0; i < rows; i++) {
        var y = top + i * lh + (rnd() - 0.5) * 3, x = right, tilt = (rnd() - 0.5) * 0.012, startX = x, gapW = size * 0.34;
        g.save(); g.translate(0, y); g.rotate(tilt); g.translate(0, -y);
        while (true) {
          var w = WORDS[wi++ % WORDS.length], sz = size * (0.94 + rnd() * 0.14);
          g.font = sz + 'px "OT Naskh", "Scheherazade New", serif';
          var mw = g.measureText(w).width;
          if (x - mw < left) break;
          var dy = (rnd() - 0.5) * 3.2, a = 0.55 + rnd() * 0.4;
          g.fillStyle = 'rgba(' + rgb + ',' + a + ')'; g.fillText(w, x, y + dy);
          // satu kata di beberapa baris diberi kotak putus: bagian tak terbaca ditandai, tidak ditebak.
          if (i % 3 === 1 && marked < 3 && x < W * 0.55 && rnd() < 0.18) {
            marked++; g.save(); g.strokeStyle = 'rgba(' + rgb + ',0.7)'; g.lineWidth = 1.2; g.setLineDash([4, 3]);
            g.strokeRect(x - mw - 3, y - sz * 0.82, mw + 6, sz * 1.25); g.restore();
          }
          x -= mw + gapW * (0.8 + rnd() * 0.7);
        }
        g.restore();
        lines.push({ y: y, h: lh, x0: startX, x1: x + gapW, t: i * (WRITE + GAP) });
      }
      ready = true;
    }
    function total() { return lines.length ? lines[lines.length - 1].t + WRITE + HOLD : 1; }
    function frame(now, freeze) {
      if (!ready) return;
      if (!t0) t0 = now;
      var t = freeze ? 1e9 : (now - t0) % (total() + 1600);
      ctx.setTransform(1, 0, 0, 1, 0, 0); ctx.clearRect(0, 0, cv.width, cv.height);
      var pen = null, endAll = lines.length ? lines[lines.length - 1].t + WRITE : 0;
      // pudar halus di akhir putaran sebelum menulis ulang
      var fade = freeze ? 1 : (t > endAll + HOLD ? 1 - clamp((t - endAll - HOLD) / 1400, 0, 1) : 1);
      ctx.globalAlpha = fade;
      for (var i = 0; i < lines.length; i++) {
        var L = lines[i], k = freeze ? 1 : clamp((t - L.t) / WRITE, 0, 1); if (k <= 0) continue;
        var e = 1 - Math.pow(1 - k, 2), span = L.x0 - L.x1, cut = L.x0 - span * e; // tepi kiri bagian yang sudah tertulis
        ctx.save(); ctx.beginPath(); ctx.rect(cut * dpr, (L.y - L.h * 0.78) * dpr, (L.x0 - cut + 8) * dpr, L.h * dpr); ctx.clip();
        ctx.drawImage(page, 0, 0); ctx.restore();
        if (k < 1) pen = { x: cut, y: L.y };
      }
      if (pen) { // ujung kalam: titik tinta kecil dengan cahaya
        ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
        var gr = ctx.createRadialGradient(pen.x, pen.y - 6, 0, pen.x, pen.y - 6, 16);
        gr.addColorStop(0, 'rgba(' + rgb + ',0.55)'); gr.addColorStop(1, 'rgba(' + rgb + ',0)');
        ctx.fillStyle = gr; ctx.fillRect(pen.x - 16, pen.y - 22, 32, 32);
        ctx.fillStyle = 'rgba(' + rgb + ',0.9)'; ctx.beginPath(); ctx.arc(pen.x, pen.y - 6, 2.2, 0, 6.283); ctx.fill();
      } else if (!freeze && t > endAll && t < endAll + HOLD) { // sorot pemindai menyapu halaman dari kanan ke kiri
        ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
        var sx = W * 1.05 - (t - endAll) / HOLD * W * 1.1;
        var sg = ctx.createLinearGradient(sx - 90, 0, sx + 90, 0);
        sg.addColorStop(0, 'rgba(' + rgb + ',0)'); sg.addColorStop(0.5, 'rgba(' + rgb + ',0.14)'); sg.addColorStop(1, 'rgba(' + rgb + ',0)');
        ctx.fillStyle = sg; ctx.fillRect(sx - 90, 0, 180, H);
      }
      ctx.globalAlpha = 1;
      if (running && visible && !freeze) raf = requestAnimationFrame(frame);
    }
    function start() { if (running || still) return; running = true; raf = requestAnimationFrame(frame); }
    function pause() { running = false; cancelAnimationFrame(raf); }
    function draw() { build(); if (still) frame(0, true); else { t0 = 0; start(); } }

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
