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

  /* ================= LATAR HERO: ARTEFAK NASKAH ================= */
  // Dua lapis. Lapis bawah (#dots-bg, digambar sekali): kisi bintang khatam dan cincin astrolab.
  // Lapis atas (#dots, bergerak): lembaran kitab, lembar berhias, medali syamsah, astrolab, dan
  // ubin bintang yang melayang pelan. Palet mengikuti tema: kertas krem dan tinta cokelat (terang)
  // atau abu pudar (gelap). Bagian tengah dipudarkan lewat CSS agar teks tetap terbaca.
  (function () {
    var cv = $('#dots'); if (!cv) return;
    var ctx = cv.getContext('2d'); if (!ctx) return;
    var bgc = d.createElement('canvas'); bgc.id = 'dots-bg'; bgc.setAttribute('aria-hidden', 'true');
    cv.parentNode.insertBefore(bgc, cv);
    var WORDS = ('العلم هذا شريف ولا شيء أشرف منه وقال الله تعالى ثلث بأهل العلم والإنسان يمتثل الأوامر ويجتنب النواهي ' +
      'إذا جاء في المذاكرة شيء من سير السلف فاكتبوه إذا ما انتفعتم به أنتم انتفع به غيركم دونوا سير سلفهم ' +
      'تفوت كرامات الرجال شواردا إذا لم تقيدها علينا الدفاتر وهذا أوان الشروع في المقصود فأقول قال سيدي رضي الله عنه').split(' ');
    var W = 0, H = 0, dpr = 1, light = true, pal = null, sheets = [], raf = 0, last = 0, running = false, visible = true, simT = 0;
    var rnd = (function (seed) { return function () { seed = (seed * 16807) % 2147483647; return (seed - 1) / 2147483646; }; })(1369);
    var TAU = Math.PI * 2;

    function isLight() {
      var t = root.getAttribute('data-theme');
      if (t === 'light') return true; if (t === 'dark') return false;
      return !matchMedia('(prefers-color-scheme: dark)').matches;
    }
    function palette() {
      light = isLight();
      pal = light
        ? { p0: '#F4E9D2', p1: '#E6D4B0', edge: 'rgba(120,88,50,0.5)', ink: 'rgba(74,46,24,0.62)', gold: 'rgba(150,104,36,0.8)', goldFill: 'rgba(176,130,56,0.16)', line: 'rgba(120,88,50,0.16)', shadow: 'rgba(70,45,20,0.3)', shade: '80,50,20' }
        : { p0: 'rgba(250,250,250,0.07)', p1: 'rgba(250,250,250,0.07)', edge: 'rgba(250,250,250,0.22)', ink: 'rgba(250,250,250,0.5)', gold: 'rgba(250,250,250,0.42)', goldFill: 'rgba(250,250,250,0.05)', line: 'rgba(250,250,250,0.07)', shadow: 'transparent', shade: '0,0,0' };
    }
    function star(g, cx, cy, R, r, n, rot) {
      g.beginPath();
      for (var i = 0; i < n * 2; i++) {
        var a = rot + Math.PI * i / n, rr = i % 2 ? r : R;
        g[i ? 'lineTo' : 'moveTo'](cx + Math.cos(a) * rr, cy + Math.sin(a) * rr);
      }
      g.closePath();
    }
    function ring(g, cx, cy, r) { g.beginPath(); g.arc(cx, cy, r, 0, TAU); }
    function rrect(g, x, y, w, h, r) {
      g.beginPath(); g.moveTo(x + r, y); g.arcTo(x + w, y, x + w, y + h, r); g.arcTo(x + w, y + h, x, y + h, r); g.arcTo(x, y + h, x, y, r); g.arcTo(x, y, x + w, y, r); g.closePath();
    }
    function paper(g, x, y, w, h) {
      var pg = g.createLinearGradient(x, y, x + w, y + h); pg.addColorStop(0, pal.p0); pg.addColorStop(1, pal.p1);
      rrect(g, x, y, w, h, Math.min(w, h) * 0.05); g.fillStyle = pg; g.fill(); g.lineWidth = 1.2; g.strokeStyle = pal.edge; g.stroke();
    }
    function textBlock(g, x, y, w, h, size) {
      g.direction = 'rtl'; g.textAlign = 'right'; g.textBaseline = 'alphabetic';
      g.fillStyle = pal.ink; g.font = size + 'px "OT Naskh", "Scheherazade New", serif';
      var lh = size * 1.9, yy = y + size, wi = Math.floor(rnd() * WORDS.length);
      while (yy < y + h) {
        var xx = x + w, left = x + rnd() * w * 0.12;
        while (true) {
          var word = WORDS[wi++ % WORDS.length], mw = g.measureText(word).width;
          if (xx - mw < left) break;
          g.fillText(word, xx, yy + (rnd() - 0.5) * 1.6); xx -= mw + size * 0.35;
        }
        yy += lh;
      }
    }
    // Satu artefak. Mengembalikan kanvas berbantalan (untuk bayangan yang sudah dipanggang) dan ukuran logisnya.
    function sprite(kind, w, h) {
      var pad = light ? 26 : 4, q = Math.max(0.5, dpr * 0.55), tw = w + pad * 2, th = h + pad * 2;
      var c = d.createElement('canvas'); c.width = Math.ceil(tw * q); c.height = Math.ceil(th * q);
      var g = c.getContext('2d'); g.setTransform(q, 0, 0, q, 0, 0); g.translate(pad, pad);
      if (light) { g.shadowColor = pal.shadow; g.shadowBlur = 16; g.shadowOffsetY = 8; }
      var cx = w / 2, cy = h / 2, R = Math.min(w, h) / 2;
      if (kind === 'page') {
        paper(g, 0, 0, w, h); g.shadowColor = 'transparent';
        textBlock(g, w * 0.1, w * 0.1, w * 0.8, h - w * 0.2, w / 11);
      } else if (kind === 'illum') { // lembar berhias: bingkai ganda, kepala lengkung dengan rosetta
        paper(g, 0, 0, w, h); g.shadowColor = 'transparent';
        g.strokeStyle = pal.gold; g.lineWidth = 1.4; rrect(g, w * 0.06, w * 0.06, w * 0.88, h - w * 0.12, 4); g.stroke();
        g.lineWidth = 0.8; rrect(g, w * 0.095, w * 0.095, w * 0.81, h - w * 0.19, 3); g.stroke();
        var hy = w * 0.3; g.fillStyle = pal.goldFill; g.beginPath(); g.moveTo(w * 0.2, hy + w * 0.12); g.lineTo(w * 0.2, hy); g.arc(cx, hy, w * 0.3, Math.PI, 0); g.lineTo(w * 0.8, hy + w * 0.12); g.closePath(); g.fill(); g.stroke();
        star(g, cx, hy, w * 0.13, w * 0.065, 12, 0); g.fillStyle = pal.goldFill; g.fill(); g.stroke(); ring(g, cx, hy, w * 0.028); g.stroke();
        textBlock(g, w * 0.14, hy + w * 0.3, w * 0.72, h - hy - w * 0.4, w / 12);
      } else if (kind === 'medal') { // syamsah: medali bulat bintang 16
        ring(g, cx, cy, R * 0.98); var mg = g.createLinearGradient(0, 0, w, h); mg.addColorStop(0, pal.p0); mg.addColorStop(1, pal.p1); g.fillStyle = mg; g.fill(); g.shadowColor = 'transparent';
        g.strokeStyle = pal.edge; g.lineWidth = 1.2; g.stroke(); g.strokeStyle = pal.gold; g.lineWidth = 1.2; ring(g, cx, cy, R * 0.9); g.stroke();
        star(g, cx, cy, R * 0.86, R * 0.6, 16, 0); g.fillStyle = pal.goldFill; g.fill(); g.stroke();
        star(g, cx, cy, R * 0.5, R * 0.3, 8, Math.PI / 8); g.fill(); g.stroke(); ring(g, cx, cy, R * 0.16); g.stroke(); ring(g, cx, cy, R * 0.07); g.fillStyle = pal.gold; g.fill();
      } else if (kind === 'astro') { // cakram astrolab: skala derajat, salib, dan cakram rete
        ring(g, cx, cy, R * 0.98); g.fillStyle = pal.p0; g.fill(); g.shadowColor = 'transparent';
        g.strokeStyle = pal.edge; g.lineWidth = 1.4; g.stroke(); ring(g, cx, cy, R * 0.86); g.strokeStyle = pal.gold; g.lineWidth = 1; g.stroke();
        for (var i = 0; i < 72; i++) { var a = TAU * i / 72, l = i % 6 ? 0.04 : 0.09; g.beginPath(); g.moveTo(cx + Math.cos(a) * R * 0.86, cy + Math.sin(a) * R * 0.86); g.lineTo(cx + Math.cos(a) * R * (0.86 + l), cy + Math.sin(a) * R * (0.86 + l)); g.stroke(); }
        g.beginPath(); g.moveTo(cx - R * 0.8, cy); g.lineTo(cx + R * 0.8, cy); g.moveTo(cx, cy - R * 0.8); g.lineTo(cx, cy + R * 0.8); g.stroke();
        ring(g, cx, cy, R * 0.55); g.stroke(); ring(g, cx + R * 0.14, cy - R * 0.08, R * 0.5); g.stroke();
        star(g, cx - R * 0.3, cy + R * 0.2, R * 0.1, R * 0.04, 4, 0.4); g.fillStyle = pal.gold; g.fill(); star(g, cx + R * 0.35, cy - R * 0.32, R * 0.08, R * 0.03, 4, 0); g.fill(); ring(g, cx, cy, R * 0.05); g.fill();
      } else { // ubin bintang khatam
        paper(g, 0, 0, w, h); g.shadowColor = 'transparent';
        g.strokeStyle = pal.gold; g.lineWidth = 1.2; g.fillStyle = pal.goldFill;
        star(g, cx, cy, R * 0.9, R * 0.5, 8, Math.PI / 8); g.fill(); g.stroke();
        star(g, cx, cy, R * 0.55, R * 0.3, 8, 0); g.stroke(); ring(g, cx, cy, R * 0.1); g.stroke();
        for (var k = 0; k < 4; k++) { ring(g, k % 2 ? w * 0.9 : w * 0.1, k < 2 ? h * 0.1 : h * 0.9, w * 0.05); g.stroke(); }
      }
      return { img: c, w: w, h: h, tw: tw, th: th, pad: pad };
    }
    // Lapis tetap: kisi khatam dan cincin astrolab besar di sudut-sudut.
    function backdrop() {
      bgc.width = Math.round(W * dpr); bgc.height = Math.round(H * dpr);
      var g = bgc.getContext('2d'); g.setTransform(dpr, 0, 0, dpr, 0, 0); g.clearRect(0, 0, W, H);
      g.strokeStyle = pal.line; g.lineWidth = 1;
      var c = clamp(W / 13, 72, 120), s = c * 0.36;
      for (var y = c / 2; y < H + c; y += c) for (var x = c / 2 + ((Math.round(y / c) % 2) ? c / 2 : 0); x < W + c; x += c) {
        star(g, x, y, s, s * 0.62, 8, Math.PI / 8); g.stroke(); ring(g, x, y, s * 0.2); g.stroke();
      }
      g.lineWidth = 1.2;
      [[0.04, 0.2, 0.62], [0.97, 0.85, 0.7], [0.55, -0.1, 0.5]].forEach(function (a) {
        var cx = W * a[0], cy = H * a[1], R = Math.min(W, H) * a[2];
        for (var k = 1; k <= 4; k++) { ring(g, cx, cy, R * (1 - k * 0.12)); g.stroke(); }
        for (var i = 0; i < 120; i++) { var an = TAU * i / 120, l = i % 5 ? 0.012 : 0.03; g.beginPath(); g.moveTo(cx + Math.cos(an) * R, cy + Math.sin(an) * R); g.lineTo(cx + Math.cos(an) * R * (1 + l), cy + Math.sin(an) * R * (1 + l)); g.stroke(); }
      });
    }
    function build() {
      palette();
      var r = cv.getBoundingClientRect(); W = Math.max(1, r.width); H = Math.max(1, r.height);
      dpr = Math.min(1.5, window.devicePixelRatio || 1);
      cv.width = Math.round(W * dpr); cv.height = Math.round(H * dpr);
      backdrop();
      var n = W < 600 ? 14 : 26, kinds = ['page', 'page', 'page', 'page', 'illum', 'illum', 'medal', 'medal', 'astro', 'tile', 'tile'];
      sheets = [];
      for (var i = 0; i < n; i++) {
        var kind = kinds[Math.floor(rnd() * kinds.length)], depth = 0.45 + rnd() * 0.75;
        var base = clamp(W * 0.2, 130, 250) * depth, w = (kind === 'medal' || kind === 'astro') ? base * 0.9 : base, h = (kind === 'medal' || kind === 'astro') ? w : (kind === 'tile' ? w : w * 1.34);
        sheets.push({
          s: sprite(kind, w, h), kind: kind, depth: depth,
          x0: rnd() * W, y0: rnd() * (H + h) - h / 2,
          vx: (rnd() - 0.5) * 7 * depth, vy: -(5 + rnd() * 9) * depth,
          rot: (rnd() - 0.5) * 0.9, vr: (rnd() - 0.5) * 0.035, flip: rnd() * TAU, vf: 0.12 + rnd() * 0.18
        });
      }
      sheets.sort(function (a, b) { return a.depth - b.depth; }); // yang jauh digambar dulu
    }
    function drawAt(t) {
      ctx.setTransform(1, 0, 0, 1, 0, 0); ctx.clearRect(0, 0, cv.width, cv.height);
      for (var i = 0; i < sheets.length; i++) {
        var p = sheets[i], S = p.s, span = H + S.h * 2;
        var y = ((p.y0 + p.vy * t + S.h) % span + span) % span - S.h;
        var x = p.x0 + p.vx * t + Math.sin(t * 0.25 + i) * 14 * p.depth;
        var sx = 0.78 + 0.22 * Math.cos(p.flip + t * p.vf); // lembar seperti perlahan dibalik
        ctx.globalAlpha = clamp(0.4 + p.depth * 0.5, 0, 0.95);
        ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
        ctx.translate(((x % (W + S.w)) + W + S.w) % (W + S.w) - S.w / 2, y);
        ctx.rotate(p.rot + p.vr * t); ctx.scale(sx, 1);
        ctx.drawImage(S.img, -S.tw / 2, -S.th / 2, S.tw, S.th);
        var sh = (1 - sx) * (light ? 1.3 : 0.9); // sisi yang miring lebih gelap: kesan lengkung
        if (sh > 0.02 && (p.kind === 'page' || p.kind === 'illum' || p.kind === 'tile')) {
          ctx.fillStyle = 'rgba(' + pal.shade + ',' + sh + ')'; ctx.fillRect(-S.w / 2, -S.h / 2, S.w, S.h);
        }
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

    var go = function () { draw(); };
    if (d.fonts && d.fonts.load) d.fonts.load('32px "OT Naskh"', 'العلم').then(go, go); else go();
    if (!still && window.IntersectionObserver) new IntersectionObserver(function (es) { visible = es[0].isIntersecting; if (visible) { running = false; start(); } else pause(); }).observe(cv);
    d.addEventListener('visibilitychange', function () { if (d.hidden) pause(); else if (visible && !still) { running = false; start(); } });
    var rt; addEventListener('resize', function () { clearTimeout(rt); rt = setTimeout(function () { pause(); draw(); }, 150); });
    var retheme = function () { pause(); draw(); };
    new MutationObserver(retheme).observe(root, { attributes: true, attributeFilter: ['data-theme'] });
    var mq = matchMedia('(prefers-color-scheme: dark)'); if (mq.addEventListener) mq.addEventListener('change', retheme);
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
