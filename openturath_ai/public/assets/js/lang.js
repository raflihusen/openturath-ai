/* Pengalih bahasa di akar situs. Urutan: pilihan manual (tombol globe) > bahasa Indonesia (bawaan).
   Tidak ada tebakan wilayah atau bahasa peramban: pengunjung baru selalu mendapat bahasa Indonesia. */
(function () {
  var l = 'id';
  try {
    var s = localStorage.getItem('ot-lang');
    if (s === 'id' || s === 'en' || s === 'ar') l = s;
  } catch (e) {}
  location.replace(l + '/index.html' + location.search + location.hash);
})();
