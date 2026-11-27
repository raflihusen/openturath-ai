/* Inisialisasi ringan sebelum interaksi: set tema terang dan parameter ?nofx=1. */
(function () {
  try {
    var u = new URLSearchParams(location.search), r = document.documentElement;
    if (u.get('nofx') === '1') r.classList.add('nofx');
    r.setAttribute('data-theme', 'light');
  } catch (e) {}
})();
