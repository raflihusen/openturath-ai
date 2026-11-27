/* OpenTurath Manuskrip: slider before/after, kanvas latar hero (dengan tombol jeda), kalkulator, dan form pesan. */
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

    if (imgScan.complete) layout(); else imgScan.addEventListener('load', layout);
    if (window.ResizeObserver) new ResizeObserver(layout).observe(ba); else addEventListener('resize', layout);
    ba.style.setProperty('--ar', String(AR));
    setPos(50); layout();

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

  /* ================= LATAR HERO: LEMBARAN NASKAH ABSTRAK ================= */
  (function () {
    var cv = $('#dots'); if (!cv) return;
    var ctx = cv.getContext('2d'); if (!ctx) return;
    var pauseBtn = $('#motion-toggle');
    var bgc = d.createElement('canvas'); bgc.id = 'dots-bg'; bgc.setAttribute('aria-hidden', 'true');
    cv.parentNode.insertBefore(bgc, cv);

    var W = 0, H = 0, dpr = 1, pal = null, sheets = [], raf = 0, last = 0, running = false, visible = true, userPaused = false, simT = 0;
    var rnd = (function (seed) { return function () { seed = (seed * 16807) % 2147483647; return (seed - 1) / 2147483646; }; })(1369);
    var TAU = Math.PI * 2;

    function palette() {
      pal = {
        p0: '#FFFFFF', p1: '#ECECEC', edge: 'rgba(24,24,27,0.34)',
        ink: 'rgba(24,24,27,0.52)', line: 'rgba(0,0,0,0.06)',
        shadow: 'rgba(0,0,0,0.2)', shade: '0,0,0'
      };
    }
    function rrect(g, x, y, w, h, r) {
      g.beginPath(); g.moveTo(x + r, y); g.arcTo(x + w, y, x + w, y + h, r); g.arcTo(x + w, y + h, x, y + h, r); g.arcTo(x, y + h, x, y, r); g.arcTo(x, y, x + w, y, r); g.closePath();
    }
    function paper(g, x, y, w, h) {
      var pg = g.createLinearGradient(x, y, x + w, y + h); pg.addColorStop(0, pal.p0); pg.addColorStop(1, pal.p1);
      rrect(g, x, y, w, h, Math.min(w, h) * 0.05); g.fillStyle = pg; g.fill(); g.lineWidth = 1.2; g.strokeStyle = pal.edge; g.stroke();
    }
    function scribbleLine(g, x0, x1, y, amp) {
      var x = x1;
      g.beginPath();
      while (x > x0 + 6) {
        var end = Math.max(x0, x - (22 + rnd() * 54)), k = 0, first = true, ph = rnd() * TAU;
        for (var xx = x; xx > end; xx -= 2.4, k++) {
          var yy = y + Math.sin(k * 1.35 + ph) * amp * (0.55 + 0.45 * Math.sin(k * 0.33 + ph * 2));
          if (first) { g.moveTo(xx, yy); first = false; } else g.lineTo(xx, yy);
        }
        x = end - (8 + rnd() * 7);
      }
      g.stroke();
    }
    function scribbleBlock(g, x, y, w, h, gap) {
      g.strokeStyle = pal.ink; g.lineWidth = 1.3; g.lineCap = 'round'; g.lineJoin = 'round';
      for (var yy = y + gap; yy < y + h; yy += gap) {
        var right = x + w, left = x + (rnd() < 0.3 ? rnd() * w * 0.22 : 0);
        scribbleLine(g, left, right, yy, gap * 0.2);
      }
    }
    function swoosh(g, x1, y1, x2, y2, bend, wmax) {
      var mx = (x1 + x2) / 2 - (y2 - y1) * bend, my = (y1 + y2) / 2 + (x2 - x1) * bend, L = [], R = [], n = 28;
      for (var i = 0; i <= n; i++) {
        var t = i / n, u = 1 - t;
        var px = u * u * x1 + 2 * u * t * mx + t * t * x2, py = u * u * y1 + 2 * u * t * my + t * t * y2;
        var dx = 2 * u * (mx - x1) + 2 * t * (x2 - mx), dy = 2 * u * (my - y1) + 2 * t * (y2 - my), dl = Math.sqrt(dx * dx + dy * dy) || 1;
        var wv = wmax * Math.pow(Math.sin(Math.PI * t), 0.8) / 2;
        L.push([px - dy / dl * wv, py + dx / dl * wv]); R.push([px + dy / dl * wv, py - dx / dl * wv]);
      }
      g.beginPath(); g.moveTo(L[0][0], L[0][1]);
      for (i = 1; i <= n; i++) g.lineTo(L[i][0], L[i][1]);
      for (i = n; i >= 0; i--) g.lineTo(R[i][0], R[i][1]);
      g.closePath(); g.fill();
    }
    function sprite(kind, w, h) {
      var pad = 26, q = Math.max(0.5, dpr * 0.55), tw = w + pad * 2, th = h + pad * 2;
      var c = d.createElement('canvas'); c.width = Math.ceil(tw * q); c.height = Math.ceil(th * q);
      var g = c.getContext('2d'); g.setTransform(q, 0, 0, q, 0, 0); g.translate(pad, pad);
      if (kind !== 'strokes') { g.shadowColor = pal.shadow; g.shadowBlur = 16; g.shadowOffsetY = 8; }
      if (kind === 'page') {
        paper(g, 0, 0, w, h); g.shadowColor = 'transparent';
        scribbleBlock(g, w * 0.1, w * 0.08, w * 0.8, h - w * 0.16, w / 9);
      } else if (kind === 'ruled') {
        paper(g, 0, 0, w, h); g.shadowColor = 'transparent';
        g.strokeStyle = pal.line; g.lineWidth = 1;
        for (var yy = w * 0.34; yy < h - w * 0.1; yy += w / 8) { g.beginPath(); g.moveTo(w * 0.1, yy); g.lineTo(w * 0.9, yy); g.stroke(); }
        g.strokeStyle = pal.ink; g.lineWidth = 1.8; g.lineCap = 'round'; scribbleLine(g, w * 0.3, w * 0.9, w * 0.2, w * 0.045);
        g.fillStyle = pal.ink; swoosh(g, w * 0.28, w * 0.27, w * 0.9, w * 0.27, 0.0, 3);
        scribbleBlock(g, w * 0.1, w * 0.3, w * 0.8, h - w * 0.42, w / 8);
      } else {
        g.fillStyle = pal.ink;
        var k = 4, sp = h / (k + 1);
        for (var i = 1; i <= k; i++) swoosh(g, w * 0.06, sp * i, w * 0.94, sp * i - w * 0.05, 0.16 * (i % 2 ? 1 : -1), 2.4 + (i % 3) * 1.1);
      }
      return { img: c, w: w, h: h, tw: tw, th: th, pad: pad };
    }
    function backdrop() {
      bgc.width = Math.round(W * dpr); bgc.height = Math.round(H * dpr);
      var g = bgc.getContext('2d'); g.setTransform(dpr, 0, 0, dpr, 0, 0); g.clearRect(0, 0, W, H);
      var rs = rnd; rnd = (function (seed) { return function () { seed = (seed * 16807) % 2147483647; return (seed - 1) / 2147483646; }; })(7);
      g.strokeStyle = pal.line; g.lineWidth = 1.1; g.lineCap = 'round'; g.lineJoin = 'round';
      var gap = clamp(W / 18, 34, 52);
      for (var y = gap * 0.7; y < H; y += gap) scribbleLine(g, 0, W, y, gap * 0.16);
      g.fillStyle = pal.line;
      swoosh(g, -W * 0.05, H * 0.9, W * 0.55, H * 0.2, 0.22, 7);
      swoosh(g, W * 0.45, H * 1.05, W * 1.05, H * 0.35, -0.2, 7);
      rnd = rs;
    }
    function build() {
      palette();
      var r = cv.getBoundingClientRect(); W = Math.max(1, r.width); H = Math.max(1, r.height);
      dpr = Math.min(1.5, window.devicePixelRatio || 1);
      cv.width = Math.round(W * dpr); cv.height = Math.round(H * dpr);
      backdrop();
      var n = W < 600 ? 6 : 10, kinds = ['page', 'page', 'page', 'ruled', 'ruled', 'strokes'];
      sheets = [];
      for (var i = 0; i < n; i++) {
        var kind = kinds[Math.floor(rnd() * kinds.length)], depth = 0.45 + rnd() * 0.75;
        var base = clamp(W * 0.2, 130, 250) * depth, w = kind === 'strokes' ? base * 1.1 : base, h = kind === 'strokes' ? w * 0.7 : w * 1.34;
        sheets.push({
          s: sprite(kind, w, h), kind: kind, depth: depth,
          x0: rnd() * W, y0: rnd() * (H + h) - h / 2,
          vx: (rnd() - 0.5) * 7 * depth, vy: -(5 + rnd() * 9) * depth,
          rot: (rnd() - 0.5) * 0.9, vr: (rnd() - 0.5) * 0.035, flip: rnd() * TAU, vf: 0.12 + rnd() * 0.18
        });
      }
      sheets.sort(function (a, b) { return a.depth - b.depth; });
    }
    function drawAt(t) {
      ctx.setTransform(1, 0, 0, 1, 0, 0); ctx.clearRect(0, 0, cv.width, cv.height);
      for (var i = 0; i < sheets.length; i++) {
        var p = sheets[i], S = p.s, span = H + S.h * 2;
        var y = ((p.y0 + p.vy * t + S.h) % span + span) % span - S.h;
        var x = p.x0 + p.vx * t + Math.sin(t * 0.25 + i) * 14 * p.depth;
        var sx = 0.78 + 0.22 * Math.cos(p.flip + t * p.vf);
        ctx.globalAlpha = clamp(0.26 + p.depth * 0.34, 0, 0.7);
        ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
        ctx.translate(((x % (W + S.w)) + W + S.w) % (W + S.w) - S.w / 2, y);
        ctx.rotate(p.rot + p.vr * t); ctx.scale(sx, 1);
        ctx.drawImage(S.img, -S.tw / 2, -S.th / 2, S.tw, S.th);
        var sh = (1 - sx) * 1.2;
        if (sh > 0.02 && p.kind !== 'strokes') {
          ctx.fillStyle = 'rgba(' + pal.shade + ',' + sh + ')'; ctx.fillRect(-S.w / 2, -S.h / 2, S.w, S.h);
        }
      }
      ctx.globalAlpha = 1;
    }
    function frame(now) {
      if (!last) last = now;
      simT += Math.min(0.05, (now - last) / 1000); last = now;
      drawAt(simT);
      if (running && visible && !userPaused) raf = requestAnimationFrame(frame);
    }
    function start() { if (running || still || userPaused) return; running = true; last = 0; raf = requestAnimationFrame(frame); }
    function pause() { running = false; cancelAnimationFrame(raf); }
    function draw() { build(); if (still || userPaused) drawAt(simT || 40); else start(); }

    if (pauseBtn) {
      if (still) {
        pauseBtn.hidden = true;
      } else {
        pauseBtn.addEventListener('click', function () {
          userPaused = !userPaused;
          pauseBtn.setAttribute('aria-pressed', String(userPaused));
          pauseBtn.textContent = userPaused ? 'Putar latar' : 'Jeda latar';
          if (userPaused) pause(); else { running = false; start(); }
        });
      }
    }

    draw();
    if (!still && window.IntersectionObserver) {
      new IntersectionObserver(function (es) {
        visible = es[0].isIntersecting;
        if (visible && !userPaused) { running = false; start(); } else pause();
      }).observe(cv);
    }
    d.addEventListener('visibilitychange', function () {
      if (d.hidden) pause(); else if (visible && !still && !userPaused) { running = false; start(); }
    });
    var rt; addEventListener('resize', function () { clearTimeout(rt); rt = setTimeout(function () { pause(); draw(); }, 150); });
  })();

  /* ================= KALKULATOR + JEMBATAN KE FORM ================= */
  (function () {
    var pages = $('#c-pages'); if (!pages) return;
    var words = $('#c-words'), plus = $('#c-plus'), total = $('#c-total'), formula = $('#c-formula'), max = $('#c-max'), applyBtn = $('#calc-apply');
    var rp = function (n) { return 'Rp ' + Math.round(n).toLocaleString('id-ID'); };
    function state() {
      var p = Math.max(0, parseFloat(pages.value) || 0), w = Math.max(0, parseFloat(words.value) || 0);
      var checked = $('input[name=c-type]:checked');
      var baseRate = parseInt((checked && checked.value) || '20', 10);
      var rate = baseRate + (plus.checked ? 10 : 0);
      var kata = p * w, sum = kata * rate;
      return { p: p, w: w, baseRate: baseRate, plus: plus.checked, rate: rate, kata: kata, sum: sum };
    }
    function calc() {
      var s = state();
      total.textContent = rp(s.sum);
      formula.textContent = s.p.toLocaleString('id-ID') + ' × ' + s.w.toLocaleString('id-ID') + ' = ' +
        s.kata.toLocaleString('id-ID') + ' kata × ' + rp(s.rate);
      max.textContent = 'Tagihan akhir tidak melebihi ' + rp(s.sum * 1.1) + ' (perkiraan + 10%).';
    }
    $$('#calc input').forEach(function (i) { i.addEventListener('input', calc); i.addEventListener('change', calc); });
    if (applyBtn) {
      applyBtn.addEventListener('click', function () {
        var s = state(), f = $('#order');
        if (!f) return;
        if (f.elements.jenis) f.elements.jenis.value = s.baseRate === 30 ? 'Tulisan tangan' : 'Cetak';
        if (f.elements.halaman && s.p > 0) f.elements.halaman.value = String(Math.round(s.p));
        if (f.elements.catatan) {
          var paket = (s.baseRate === 30 ? 'Tulisan tangan' : 'Cetak') + (s.plus ? ' + Paket Lengkap' : '');
          f.elements.catatan.value = 'Perkiraan dari kalkulator: ' + Math.round(s.p) + ' halaman (~' + Math.round(s.w) + ' kata/hal.), paket ' + paket + ', kisaran ' + rp(s.sum) + '.';
        }
        var target = $('#pesan');
        if (target) target.scrollIntoView({ behavior: still ? 'auto' : 'smooth' });
        if (f.elements.nama) setTimeout(function () { f.elements.nama.focus(); }, still ? 0 : 400);
      });
    }
    calc();
  })();

  /* ================= FORM PESAN + VALIDASI AKSESIBEL + SALIN ================= */
  (function () {
    var f = $('#order'); if (!f) return;
    var note = $('#order-note'), copyBtn = $('#order-copy');
    var v = function (n) { return (f.elements[n] && f.elements[n].value || '').trim(); };
    function buildBody() {
      return [
        'Nama: ' + (v('nama') || '-'),
        'Email: ' + (v('email') || '-'),
        'Jenis naskah: ' + (v('jenis') || '-'),
        'Perkiraan jumlah halaman: ' + (v('halaman') || '-'),
        'Catatan atau pertanyaan: ' + (v('catatan') || '-'),
        '',
        'Saya menyatakan berhak memproses naskah ini dan menyetujui ketentuan OpenTurath.',
        '',
        '(Lampirkan 3 halaman contoh dalam format JPG/PNG/PDF atau tautan Google Drive.)'
      ].join('\n');
    }
    function validateForm() {
      var fields = [f.elements.nama, f.elements.email, f.elements.izin];
      var firstInvalid = null;
      fields.forEach(function (el) {
        if (!el) return;
        var ok = el.checkValidity();
        el.setAttribute('aria-invalid', String(!ok));
        if (!ok && !firstInvalid) firstInvalid = el;
      });
      if (firstInvalid) {
        note.className = 'small form-status is-error';
        note.textContent = 'Mohon lengkapi nama, alamat email yang valid, dan centang persetujuan hak proses naskah terlebih dahulu.';
        firstInvalid.focus();
        return false;
      }
      note.className = 'small form-status';
      return true;
    }
    ['input', 'change'].forEach(function (ev) {
      f.addEventListener(ev, function (e) {
        if (e.target && e.target.getAttribute('aria-invalid') === 'true' && e.target.checkValidity()) {
          e.target.setAttribute('aria-invalid', 'false');
        }
      });
    });
    f.addEventListener('submit', function (e) {
      e.preventDefault();
      if (!validateForm()) return;
      var body = buildBody();
      location.href = 'mailto:support@openturath.id?subject=' + encodeURIComponent('Uji 3 halaman gratis: OpenTurath Manuskrip') + '&body=' + encodeURIComponent(body);
      note.textContent = 'Aplikasi email Anda dibuka. Lampirkan 3 halaman contoh lalu kirim. Jika tidak terbuka, klik "Salin isi formulir" lalu kirim manual ke support@openturath.id atau DM @openturath.id.';
    });
    if (copyBtn) {
      copyBtn.addEventListener('click', function () {
        if (!validateForm()) return;
        var text = 'Kepada: support@openturath.id\nSubjek: Uji 3 halaman gratis: OpenTurath Manuskrip\n\n' + buildBody();
        if (navigator.clipboard && navigator.clipboard.writeText) {
          navigator.clipboard.writeText(text).then(function () {
            note.textContent = 'Isi formulir berhasil disalin. Tempelkan ke email (support@openturath.id) atau DM Instagram @openturath.id bersama 3 halaman contoh Anda.';
          }, function () {
            note.textContent = 'Gagal menyalin otomatis. Silakan kirim langsung ke support@openturath.id atau DM @openturath.id.';
          });
        } else {
          note.textContent = 'Browser tidak mendukung salin otomatis. Silakan kirim langsung ke support@openturath.id atau DM @openturath.id.';
        }
      });
    }
  })();
})();
