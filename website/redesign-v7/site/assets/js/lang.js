/* Pengalih bahasa di akar situs. Urutan: pilihan manual > perkiraan wilayah > bahasa Indonesia (bawaan).
   Perkiraan wilayah memakai zona waktu perangkat, bukan IP (situs statis tidak bisa membaca IP; lihat deploy/GEO-LANGUAGE.md untuk IP sungguhan). */
(function () {
  var ARAB = /^(Asia\/(Riyadh|Aden|Dubai|Muscat|Kuwait|Qatar|Bahrain|Baghdad|Damascus|Beirut|Amman|Gaza|Hebron)|Africa\/(Cairo|Tripoli|Tunis|Algiers|Casablanca|El_Aaiun|Khartoum|Juba|Djibouti|Mogadishu|Nouakchott)|Indian\/Comoro)$/;
  var l = 'id';
  try {
    var s = localStorage.getItem('ot-lang');
    if (s === 'id' || s === 'en' || s === 'ar') l = s;
    else { var tz = Intl.DateTimeFormat().resolvedOptions().timeZone || ''; if (ARAB.test(tz)) l = 'ar'; }
  } catch (e) {}
  location.replace(l + '/index.html' + location.search + location.hash);
})();
