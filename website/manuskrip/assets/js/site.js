/* OpenTurath Manuskrip — peningkatan progresif: menu ponsel + focus trap, animasi ketik bertahap (non-blocking), scroll reveal, dan progress bar. */
(function () {
  'use strict';
  var d = document, root = d.documentElement;
  root.classList.remove('no-js');
  root.classList.add('js');
  var $ = function (s, c) { return (c || d).querySelector(s); };
  var $$ = function (s, c) { return Array.prototype.slice.call((c || d).querySelectorAll(s)); };
  var reduce = matchMedia('(prefers-reduced-motion: reduce)').matches;
  var nofx = /[?&]nofx=1/.test(location.search) || root.classList.contains('nofx');
  if (nofx) root.classList.add('nofx');
  var still = reduce || nofx;

  /* ================= MENU PONSEL + FOCUS TRAP ================= */
  var mb = $('.menu-btn'), sheet = $('#sheet');
  var setMenu = function (open) {
    if (!mb || !sheet) return;
    sheet.classList.toggle('open', open);
    sheet.setAttribute('aria-hidden', String(!open));
    mb.setAttribute('aria-expanded', String(open));
    d.documentElement.style.overflow = open ? 'hidden' : '';
    d.body.style.overflow = open ? 'hidden' : '';
    var hd = $('header.site');
    if (open && hd) sheet.style.top = Math.max(hd.getBoundingClientRect().bottom, 0) + 'px';
    if (open) {
      var firstLink = $('a, button', sheet);
      if (firstLink) firstLink.focus();
    } else {
      mb.focus();
    }
  };
  if (mb && sheet) {
    sheet.setAttribute('aria-hidden', 'true');
    mb.addEventListener('click', function () { setMenu(!sheet.classList.contains('open')); });
    sheet.addEventListener('click', function (e) { if (e.target.closest('a')) setMenu(false); });
    d.addEventListener('keydown', function (e) {
      if (!sheet.classList.contains('open')) return;
      if (e.key === 'Escape') { e.preventDefault(); setMenu(false); return; }
      if (e.key === 'Tab') {
        var focusables = $$('a[href], button:not([disabled])', sheet);
        if (!focusables.length) return;
        var first = focusables[0], last = focusables[focusables.length - 1];
        if (e.shiftKey && d.activeElement === first) { e.preventDefault(); last.focus(); }
        else if (!e.shiftKey && d.activeElement === last) { e.preventDefault(); first.focus(); }
      }
    });
    addEventListener('resize', function () { if (innerWidth > 1120 && sheet.classList.contains('open')) setMenu(false); });
  }

  /* ================= ANIMASI KETIK BERTAHAP & SCROLL REVEAL ================= */
  var rv = $$('.rv');
  if (!still && 'IntersectionObserver' in window) {
    root.classList.add('typing');

    var prep = function (el) {
      if (el._ch) return el._ch;
      el.setAttribute('aria-label', el.textContent.replace(/\s+/g, ' ').trim());
      var chars = [];
      var walk = function (node) {
        Array.prototype.slice.call(node.childNodes).forEach(function (n) {
          if (n.nodeType === 3) {
            var frag = d.createDocumentFragment(), parts = n.nodeValue.split(/(\s+)/);
            parts.forEach(function (p) {
              if (!p) return;
              if (/^\s+$/.test(p)) { frag.appendChild(d.createTextNode(p)); return; }
              var w = d.createElement('span');
              w.setAttribute('aria-hidden', 'true');
              w.style.whiteSpace = 'nowrap';
              Array.prototype.forEach.call(p, function (c) {
                var s = d.createElement('span');
                s.className = 'ch';
                s.textContent = c;
                w.appendChild(s);
                chars.push(s);
              });
              frag.appendChild(w);
            });
            node.replaceChild(frag, n);
          } else if (n.nodeType === 1) {
            walk(n);
          }
        });
      };
      walk(el);
      el._ch = chars;
      return chars;
    };

    var type = function (el, ms, stepChars, cb) {
      if (el._typed) { if (cb) cb(); return; }
      el._typed = true;
      var chars = prep(el), i = 0;
      var per = Math.max(8, Math.min(ms, 1200 / Math.max(1, chars.length)));
      var tick = function () {
        for (var k = 0; k < stepChars && i < chars.length; k++) chars[i++].classList.add('on');
        if (i < chars.length) setTimeout(tick, per);
        else if (cb) cb();
      };
      tick();
    };

    /* 1. Koreografi Hero bertahap (mulai cepat ~120ms agar tidak terasa menunggu lama) */
    var hero = $('#hero');
    if (hero) {
      var h1 = $('h1.hero', hero);
      var lede = $('.lede', hero);
      var cta = $('.cta-row', hero);
      var mbtn = $('#motion-toggle', hero);
      if (h1) prep(h1);
      if (lede) prep(lede);

      setTimeout(function () {
        if (h1) {
          h1.classList.add('in');
          type(h1, 22, 2, function () {
            if (lede) {
              lede.classList.add('in');
              type(lede, 11, 3, function () {
                if (cta) cta.classList.add('in');
                setTimeout(function () { if (mbtn) mbtn.classList.add('in'); }, 180);
              });
            } else {
              if (cta) cta.classList.add('in');
              if (mbtn) mbtn.classList.add('in');
            }
          });
        }
      }, 120);
    }

    /* 2. Judul tiap seksi diketik saat masuk layar, lalu .lead muncul perlahan */
    var secHeads = $$('.sec-head h2, section.sec > .wrap > .cols2 h2');
    secHeads.forEach(function (h) { prep(h); });
    var hio = new IntersectionObserver(function (es) {
      es.forEach(function (e) {
        if (!e.isIntersecting) return;
        hio.unobserve(e.target);
        var h = e.target, box = h.closest('.sec-head');
        type(h, 20, 2, function () { if (box) box.classList.add('typed'); });
      });
    }, { threshold: 0.25, rootMargin: '0px 0px -6% 0px' });
    secHeads.forEach(function (h) { hio.observe(h); });

    /* 3. Elemen .rv muncul bertahap (non-blocking: tidak pernah tertahan oleh animasi hero) */
    var rvIo = new IntersectionObserver(function (es) {
      es.forEach(function (e) {
        if (!e.isIntersecting) return;
        rvIo.unobserve(e.target);
        e.target.classList.add('in');
      });
    }, { rootMargin: '0px 0px -5% 0px', threshold: 0.04 });
    rv.forEach(function (n) {
      if (n.closest('.welcome')) return;
      rvIo.observe(n);
    });

    /* Saat pengguna klik menu anchor (#harga, #demo, dll.), pastikan seksi tujuan langsung mulai muncul */
    var revealTarget = function () {
      var hash = location.hash;
      if (!hash) return;
      var sec = $(hash);
      if (!sec) return;
      $$('.rv', sec).forEach(function (el) { el.classList.add('in'); rvIo.unobserve(el); });
      $$('.sec-head h2, .cols2 h2', sec).forEach(function (h) {
        var box = h.closest('.sec-head');
        type(h, 16, 3, function () { if (box) box.classList.add('typed'); });
      });
    };
    addEventListener('hashchange', revealTarget);
    if (location.hash) revealTarget();
  } else {
    rv.forEach(function (n) { n.classList.add('in'); });
  }

  /* ================= SOROTAN HALUS KURSOR PADA KARTU ================= */
  if (matchMedia('(pointer: fine)').matches && !still) {
    d.addEventListener('pointermove', function (e) {
      var c = e.target.closest && e.target.closest('.pillar');
      if (!c) return;
      var r = c.getBoundingClientRect();
      c.style.setProperty('--mx', (e.clientX - r.left) + 'px');
      c.style.setProperty('--my', (e.clientY - r.top) + 'px');
    }, { passive: true });
  }

  /* ================= GARIS KEMAJUAN GULIR ================= */
  if (!nofx) {
    var bar = d.createElement('div');
    bar.className = 'progress';
    bar.setAttribute('aria-hidden', 'true');
    d.body.appendChild(bar);
    var prog = function () {
      var h = d.documentElement.scrollHeight - innerHeight;
      bar.style.transform = 'scaleX(' + (h > 0 ? scrollY / h : 0) + ')';
    };
    addEventListener('scroll', prog, { passive: true });
    prog();
  }
})();
