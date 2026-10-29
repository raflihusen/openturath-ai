/* Dimuat sebelum render agar tema tidak berkedip. Berkas eksternal karena CSP produksi melarang skrip sebaris. */
(function () { try { var u = new URLSearchParams(location.search), r = document.documentElement; if (u.get('nofx')) r.classList.add('nofx'); r.setAttribute('data-theme', 'light'); } catch (e) {} })();
