/* Sanad demo. Everything else comes from OpenTurath's site.js. */
(function () {
  var demo = document.querySelector('.demo-card');
  if (!demo) return;
  var data = JSON.parse(demo.querySelector('script').textContent);
  var views = demo.querySelectorAll('.view'), side = demo.querySelector('.side'), tabs = demo.querySelectorAll('.demo-tabs button');
  function show(name) {
    views.forEach(function (v) { v.hidden = v.dataset.v !== name; });
    tabs.forEach(function (b) { b.setAttribute('aria-selected', b.dataset.v === name); });
    if (name !== 'chains') {
      var view = demo.querySelector('.view[data-v=' + name + ']');
      view.scrollLeft = view.scrollWidth;
      view.scrollTop = (view.scrollHeight - view.clientHeight) / 2;
    }
  }
  tabs.forEach(function (b) { b.addEventListener('click', function () { show(b.dataset.v); }); });
  show(innerWidth < 700 ? 'chains' : 'tree');
  function text(tag, value, cls) { var el = document.createElement(tag); el.textContent = value; if (cls) el.className = cls; return el; }
  function pick(node) {
    var svg = node.closest('svg'), set = node.dataset.c.split(',');
    svg.classList.add('pick');
    svg.querySelectorAll('.n,.e').forEach(function (el) {
      el.classList.toggle('on', el.dataset.c.split(',').some(function (c) { return set.indexOf(c) > -1; }));
      el.classList.remove('sel');
    });
    node.classList.add('sel');
    var id = node.dataset.id, chains = set.map(function (c) { return data.chains[c]; });
    var link = chains[0].links.filter(function (l) { return l.id === id; })[0], grade = data.grades[id] || [];
    var books = chains.map(function (c) { return c.book; }).filter(function (b, i, a) { return a.indexOf(b) === i; });
    side.replaceChildren(text('h3', link.name));
    if (grade[0]) side.append(text('p', grade[0], 'small'));
    if (grade[1]) side.append(text('p', grade[1], 'small'));
    side.append(text('p', chains.length + ' ' + demo.dataset.routes + ' · ' + books.length + ' ' + demo.dataset.books));
    var list = document.createElement('ul');
    books.forEach(function (b) { list.append(text('li', b)); });
    side.append(list);
  }
  demo.querySelectorAll('.n').forEach(function (node) {
    node.addEventListener('click', function () { pick(node); });
    node.addEventListener('keydown', function (e) { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); pick(node); } });
  });
})();
