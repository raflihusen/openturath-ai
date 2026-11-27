/* OpenTurath Manuskrip — peningkatan progresif ringan (menu ponsel + focus trap, scroll reveal non-blocking, progress bar). */
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

  /* menu ponsel + focus trap */
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

  /* scroll reveal non-blocking: tidak pernah menahan konten saat klik anchor */
  var rv = $$('.rv');
  if ('IntersectionObserver' in window && !reduce && !nofx) {
    var io = new IntersectionObserver(function (es) {
      es.forEach(function (e) {
        if (!e.isIntersecting) return;
        io.unobserve(e.target);
        e.target.classList.add('in');
      });
    }, { rootMargin: '0px 0px -4% 0px', threshold: 0.02 });
    rv.forEach(function (n) {
      if (n.closest('.welcome')) { n.classList.add('in'); return; }
      io.observe(n);
    });
    /* Pastikan semua elemen di sekitar target langsung muncul saat lompat via hash */
    var revealNearHash = function () {
      var h = location.hash && $(location.hash);
      if (!h) return;
      $$('.rv', h).forEach(function (el) { el.classList.add('in'); io.unobserve(el); });
    };
    addEventListener('hashchange', revealNearHash);
    if (location.hash) revealNearHash();
  } else {
    rv.forEach(function (n) { n.classList.add('in'); });
  }

  /* sorotan halus mengikuti kursor pada kartu */
  if (matchMedia('(pointer: fine)').matches && !reduce && !nofx) {
    d.addEventListener('pointermove', function (e) {
      var c = e.target.closest && e.target.closest('.pillar');
      if (!c) return;
      var r = c.getBoundingClientRect();
      c.style.setProperty('--mx', (e.clientX - r.left) + 'px');
      c.style.setProperty('--my', (e.clientY - r.top) + 'px');
    }, { passive: true });
  }

  /* garis kemajuan gulir */
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
