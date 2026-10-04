// Skrip kecil tanpa dependensi: tema, pengalihan bahasa di akar situs,
// tombol unduh sesuai perangkat, dan salin alamat email.
(function () {
  var root = document.documentElement;
  try {
    var saved = localStorage.getItem('ot-theme');
    if (saved === 'light' || saved === 'dark') root.dataset.theme = saved;
  } catch (_) {}

  var script = document.currentScript;
  if (script && script.hasAttribute('data-root')) {
    var lang = (navigator.language || 'id').slice(0, 2).toLowerCase();
    location.replace('/' + (lang === 'ar' || lang === 'en' ? lang : 'id') + '/');
    return;
  }

  document.addEventListener('DOMContentLoaded', function () {
    var toggle = document.querySelector('[data-theme-toggle]');
    if (toggle) {
      toggle.addEventListener('click', function () {
        var dark = root.dataset.theme
          ? root.dataset.theme === 'dark'
          : matchMedia('(prefers-color-scheme: dark)').matches;
        root.dataset.theme = dark ? 'light' : 'dark';
        try { localStorage.setItem('ot-theme', root.dataset.theme); } catch (_) {}
      });
    }

    var ua = navigator.userAgent;
    var os = /Android/i.test(ua) ? 'android' : /Windows/i.test(ua) ? 'windows'
      : /Macintosh/i.test(ua) && !('ontouchend' in document) ? 'macos' : null;
    document.querySelectorAll('[data-download]').forEach(function (link) {
      var url = os && link.dataset[os];
      if (!url) return;
      link.href = url;
      link.firstChild.textContent = link.dataset[os + 'Label'];
    });

    document.querySelectorAll('[data-copy]').forEach(function (button) {
      button.addEventListener('click', function () {
        var status = document.querySelector('[data-copy-status]');
        navigator.clipboard.writeText(button.dataset.copy).then(function () {
          if (status) status.textContent = button.dataset.copied;
        }).catch(function () {});
      });
    });

    document.addEventListener('click', function (event) {
      document.querySelectorAll('details.lang[open]').forEach(function (menu) {
        if (!menu.contains(event.target)) menu.removeAttribute('open');
      });
    });
  });
})();
