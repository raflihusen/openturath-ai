/* Garis tinta menyambungkan matan, perawi, dan kitab, dari posisi nyata di halaman. */
(function () {
  var root = document.documentElement, reduce = matchMedia('(prefers-reduced-motion: reduce)').matches;
  try { var saved = localStorage.getItem('takhrij-theme'); if (saved) root.dataset.theme = saved; } catch (e) {}
  document.querySelector('[data-theme-toggle]').addEventListener('click', function () {
    var dark = root.dataset.theme ? root.dataset.theme === 'dark' : matchMedia('(prefers-color-scheme:dark)').matches;
    root.dataset.theme = dark ? 'light' : 'dark';
    try { localStorage.setItem('takhrij-theme', root.dataset.theme); } catch (e) {}
  });
  var frame = document.querySelector('.frame'), svg = document.getElementById('line');
  if (!svg || innerWidth <= 860) return;
  var NS = 'http://www.w3.org/2000/svg', links = [];
  function rect(el) {
    var f = frame.getBoundingClientRect(), r = el.getBoundingClientRect();
    return { l: r.left - f.left, r: r.right - f.left, t: r.top - f.top, b: r.bottom - f.top, y: (r.top + r.bottom) / 2 - f.top, x: (r.left + r.right) / 2 - f.left };
  }
  function add(d, t, dur) {
    var p = document.createElementNS(NS, 'path');
    p.setAttribute('d', d); p.setAttribute('pathLength', '1');
    p.style.setProperty('--t', t + 's'); p.style.setProperty('--dur', dur + 's');
    if (reduce) p.style.strokeDashoffset = 0;
    svg.appendChild(p); return p;
  }
  function draw() {
    svg.replaceChildren();
    var h1 = rect(document.querySelector('.matn h1')), rawi = [].slice.call(document.querySelectorAll('.sanad li')), kitab = [].slice.call(document.querySelectorAll('.kutub li'));
    var r = rawi.map(rect), k = kitab.map(rect), edge = r[0].l - 12, start = Math.min(h1.r + 4, r[0].l - 40);
    add('M' + start + ' ' + h1.y + 'C' + (start + 34) + ' ' + h1.y + ' ' + (edge - 18) + ' ' + r[0].y + ' ' + edge + ' ' + r[0].y, 1.75, .5);
    r.slice(1).forEach(function (n, i) {
      var a = r[i];
      add('M' + edge + ' ' + (a.y + 12) + 'V' + (n.y - 12), 2.15 + i * .25, .25);
    });
    var last = r[r.length - 1], x = k[0].r + 12, join = k[k.length - 1].b + 18;
    add('M' + edge + ' ' + (last.y + 12) + 'C' + edge + ' ' + (join + 8) + ' ' + (edge - 30) + ' ' + join + ' ' + (edge - 60) + ' ' + join + 'H' + (x + 40), 3.0, .55);
    k.forEach(function (b) {
      add('M' + (x + 40) + ' ' + join + 'C' + (x + 14) + ' ' + join + ' ' + (x + 26) + ' ' + b.y + ' ' + x + ' ' + b.y, 3.5, .35);
    });
  }
  (document.fonts ? document.fonts.ready : Promise.resolve()).then(draw);
  var wait; addEventListener('resize', function () { clearTimeout(wait); wait = setTimeout(function () {
    svg.querySelectorAll('path').forEach(function (p) { p.style.animation = 'none'; p.style.strokeDashoffset = 0; }); 
    var was = reduce; reduce = true; draw(); reduce = was;
  }, 150); });
})();
