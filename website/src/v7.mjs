// OpenTurath V7 — halaman yang dibangun ulang dari data aplikasi.
// Halaman tiap AI mencerminkan tombol info (ⓘ) di aplikasi: Tentang, Isi, Daftar kitab, Cara disusun, Batasan, Contoh tanya-jawab.
import fs from 'node:fs';
import {escapeHtml as e, pick, pathFor} from './core.mjs';
import {collectionCard, pageHead, arrow} from './render.mjs';
import {collectionStats, number, REKAMAN_DIPERIKSA} from './metadata.mjs';

const T = (l, id, en, ar) => ({id, en, ar})[l];
const GANTI = JSON.parse(fs.readFileSync(new URL('../content/v7-ganti-teks.json', import.meta.url), 'utf8'));
const TA = 'غير متوفر في المصدر';
const TA_LABEL = l => T(l, 'tidak tercantum di sumber', 'not stated in the source', TA);

function blok(html, start) {           // ambil satu elemen <div> utuh mulai dari indeks start (seimbang)
  const re = /<div\b|<\/div>/g; re.lastIndex = start; let depth = 0, m;
  while ((m = re.exec(html))) { depth += m[0] === '</div>' ? -1 : 1; if (depth === 0) return [start, re.lastIndex]; }
  return [start, html.length];
}
function gantiBagian(html, kelasSection, baru) {
  const i = html.indexOf(`<section class="${kelasSection}"`); if (i < 0) return html;
  const j = html.indexOf('</section>', i) + '</section>'.length; return html.slice(0, i) + baru + html.slice(j);
}
function gantiGrid(html, isi) {
  const i = html.search(/<div class="collection-grid[^"]*"/); if (i < 0) return html;
  const tagEnd = html.indexOf('>', i) + 1; const [, j] = blok(html, i);
  return html.slice(0, tagEnd) + isi + '</div>' + html.slice(j);
}
function hapusFaqHabibUmar(html) {
  return html.replace(/<details\b(?:(?!<\/details>)[\s\S])*?(?:Habib Umar|الحبيب عمر)(?:(?!<\/details>)[\s\S])*?<\/details>/g, '');
}
function kartu(l, c, rumah) {
  const v = rumah ? (c.variant === 'sovereign' ? 'sovereign' : (c.index <= 3 ? 'featured' : 'standard')) : (c.variant || 'standard');
  return `<div class="bento-${v}" data-reveal="card" data-search-item data-search-text="${e(Object.values(c.name).join(' ') + ' ' + c.arabic + ' ' + Object.values(c.description).join(' '))}" data-group="${c.group}">${collectionCard(l, c)}</div>`;
}

// Semua halaman live: penggantian teks lama (angka korpus, harga, tahun wafat) dan FAQ Habib Umar disembunyikan.
export function gantiTeksLive(l, main) {
  let h = main;
  for (const [lama, baru] of GANTI[l] || []) h = h.split(lama).join(baru);
  return hapusFaqHabibUmar(h);
}
// Halaman live yang dirombak: beranda, pustaka, akses, Fikih Tahawwulat.
export function rombakLive(l, route, d, main) {
  let h = main;
  for (const [lama, baru] of GANTI[l] || []) h = h.split(lama).join(baru);
  h = hapusFaqHabibUmar(h);
  if (route === '' || route === 'library') {
    h = gantiBagian(h, 'collection-scale', collectionStats(l, d.catalog));
    const daftar = route === '' ? d.catalog.slice(0, 6) : d.catalog;
    h = gantiGrid(h, daftar.map(c => kartu(l, c, route === '')).join(''));
    h = h.replace(/(<output class="result-count"[^>]*>)\s*\d+\s*/, `$1${d.catalog.length} `);
  }
  return h;
}

// ── Halaman tiap AI ───────────────────────────────────────────────
function daftarKitab(l, c) {
  let data;
  try { data = JSON.parse(fs.readFileSync(new URL(`../content/katalog/${c.id}.json`, import.meta.url), 'utf8')); } catch { return ''; }
  const kitab = data.kitab || [], video = data.muhadharah || [];
  const nilai = v => (!v || v === TA) ? `<span class="muted">${TA_LABEL(l)}</span>` : e(v);
  const baris = kitab.map(k => `<li class="kitab-row" data-search-item data-search-text="${e([k['الاسم_الكامل'], k['المؤلف'], k['المحقق_أو_المعتني'], k['الناشر']].join(' '))}">
      <p class="kitab-title" lang="ar" dir="rtl">${e(k['الاسم_الكامل'])}</p>
      <p class="kitab-meta" lang="ar" dir="rtl">${nilai(k['المؤلف'])}${k['سنة_الوفاة'] && k['سنة_الوفاة'] !== TA ? ` · ت ${e(k['سنة_الوفاة'])}` : ''}</p>
      <dl class="kitab-edition" lang="ar" dir="rtl">${[['المحقق', 'المحقق_أو_المعتني'], ['الناشر', 'الناشر'], ['الطبعة', 'الطبعة']].filter(([, f]) => k[f] && k[f] !== TA).map(([lab, f]) => `<div><dt>${lab}</dt><dd>${e(k[f])}</dd></div>`).join('')}</dl>
      ${k['ملاحظة'] ? `<p class="kitab-note" lang="ar" dir="rtl">${e(k['ملاحظة'])}</p>` : ''}</li>`).join('');
  const vbaris = video.map(v => `<li class="kitab-row" data-search-item data-search-text="${e(v['عنوان_المحاضرة'] + ' ' + v['القناة'])}">
      <p class="kitab-title" lang="ar" dir="rtl">${e(v['عنوان_المحاضرة'])}</p>
      <p class="kitab-meta"><span lang="ar" dir="rtl">${e(v['القناة'])}</span> · ${e(v['المدة'])} · <a href="${e(v['الرابط'])}" rel="noopener" target="_blank">YouTube${arrow}</a></p></li>`).join('');
  return `<section class="section ai-catalog" id="daftar-kitab"><div class="container" data-search-scope>
    <h2>${T(l, 'Daftar kitab lengkap', 'Complete list of works', 'قائمة الكتب كاملة')}</h2>
    <form class="search-form" data-search-form role="search"><label class="search-box"><span class="sr-only">${T(l, 'Cari', 'Search', 'بحث')}</span><input type="search" name="q" data-search placeholder="${T(l, 'Cari judul, pengarang, atau muhaqqiq…', 'Search title, author, or editor…', 'ابحث بالعنوان أو المؤلف أو المحقق…')}" autocomplete="off"></label>
      <div class="search-meta"><output class="result-count" data-count aria-live="polite">${kitab.length + video.length} ${T(l, 'hasil', 'results', 'نتيجة')}</output></div></form>
    <p class="fine-print">${T(l, 'Semua data bibliografi diambil apa adanya dari kartu kitab di sumber. Bila sumber tidak mencantumkannya, kolom ditandai “tidak tercantum di sumber”, bukan ditebak.', 'All bibliographic data is taken as-is from the source cards. Where the source is silent, the field is marked “not stated in the source” rather than guessed.', 'تؤخذ البيانات الببليوغرافية كما وردت في بطاقات المصدر، وما لم يذكره المصدر يُشار إليه بعبارة «غير متوفر في المصدر» دون تخمين.')}</p>
    <ol class="kitab-list">${baris}</ol>
    ${video.length ? `<h3>${T(l, 'Muhadharah', 'Lectures', 'المحاضرات')} (${number(video.length, l)})</h3><p class="fine-print">${T(l, 'Teks muhadharah adalah transkrip otomatis berbahasa Arab. Setiap kutipan AI menyebut judul muhadharah dan tautan YouTube beserta menitnya.', 'Lecture texts are automatic Arabic transcripts. Every AI quotation names the lecture title and links to the YouTube video at the right minute.', 'نصوص المحاضرات تفريغ آلي باللغة العربية، وكل نقل من الذكاء الاصطناعي يذكر عنوان المحاضرة ورابطها على يوتيوب مع الدقيقة.')}</p><ol class="kitab-list">${vbaris}</ol>` : ''}
    <p class="empty-search" data-empty hidden>${T(l, 'Tidak ada yang cocok.', 'No matches.', 'لا توجد نتائج.')}</p>
  </div></section>`;
}

export function halamanAI(l, c) {
  const x = c.info, isi = x.isi, cara = x.cara_disusun;
  const r = isi.rentang_wafat_pengarang;
  const angka = [
    [number(isi.jumlah_kitab, l), T(l, 'Kitab', 'Works', 'كتاب')],
    ...(isi.jumlah_muhadharah ? [[number(isi.jumlah_muhadharah, l), T(l, 'Muhadharah', 'Lectures', 'محاضرة')]] : []),
    [number(Math.round(isi.jumlah_kata / 1e5) / 10, l, 1) + ' ' + T(l, 'juta', 'million', 'مليون'), T(l, 'Kata teks', 'Words of text', 'كلمة')],
    [number(cara.berkas_notebooklm, l), T(l, 'Berkas terindeks', 'Indexed files', 'ملفًّا مفهرسًا')],
  ];
  const cabang = (isi.cabang_ilmu || []).filter(k => k.nama).map(k => `<li>${e(k.nama)}</li>`).join('');
  const induk = (isi.kitab_induk || []).map(k => `<li lang="ar" dir="rtl"><span>${e(k.judul)}</span><small>${e(k.pengarang || '')}${k.wafat ? ` · ت ${e(String(k.wafat).replace(/\d/g, d => '٠١٢٣٤٥٦٧٨٩'[d]))} هـ` : ''}</small></li>`).join('');
  const asal = Object.entries(isi.perpustakaan_asal || {}).map(([k, v]) => `${({hazmi: 'Maktabah Hazmi', baru: T(l, 'Maktabah Baru', 'Maktabah Baru', 'المكتبة الجديدة'), shamela4: 'Shamela 4', modul_06_kitab: T(l, 'Kitab modul', 'Module books', 'كتب الوحدة'), youtube_tiga_kanal: 'YouTube'})[k] || k} ${number(v, l)}`).join(' · ');
  const batasan = [
    T(l, 'Hanya memuat kitab ulama Ahlussunnah wal Jama’ah. Karya, pensyarah, dan muhaqqiq yang tidak sejalan disaring.', 'Only works by scholars of Ahl al-Sunna wa-l-Jamāʿa are included. Authors, commentators, and editors outside this tradition are filtered out.', 'لا تُدرج إلا كتب علماء أهل السنة والجماعة، وتُستبعد المؤلفات والشروح والتحقيقات المخالفة.'),
    T(l, 'Kitab yang satu-satunya cetakannya ditahqiq oleh muhaqqiq yang disaring dimuat matannya saja; muqaddimah dan catatan kaki muhaqqiq dibuang.', 'Where the only available edition was prepared by a filtered editor, only the original text is included; the editor’s introduction and footnotes are removed.', 'ما لم يتوفر إلا بتحقيق مستبعد يُدرج متنه فقط، وتُحذف مقدمة المحقق وحواشيه.'),
    T(l, 'Jawaban bersumber dari kitab yang dimuat; AI tidak memberi fatwa pribadi dan bisa keliru. Bawa rujukannya kepada guru.', 'Answers draw on the included works only; the AI gives no personal fatwa and can err. Take the references to a teacher.', 'تستند الإجابات إلى الكتب المدرجة فقط، ولا يُصدر الذكاء الاصطناعي فتوى، وقد يخطئ؛ فاعرض الإحالات على أهل العلم.'),
    T(l, 'Rujukan ditulis [judul jilid/halaman] menurut cetakan sumber digital; halaman bisa berbeda dengan cetakan Anda.', 'References are given as [title volume/page] according to the digital source edition; pages may differ from your printed copy.', 'تُكتب الإحالة [العنوان الجزء/الصفحة] بحسب الطبعة الرقمية المعتمدة، وقد تختلف عن طبعتك الورقية.'),
  ];
  const contoh = x.contoh_tanya_jawab || [];
  return `${pageHead(l, T(l, 'AI spesialis', 'Specialist AI', 'مساعد متخصص'), pick(c.name, l), pick(c.description, l))}
  <section class="section ai-info compact-top"><div class="container">
    ${l === 'ar' ? '' : `<p class="ai-arabic" lang="ar" dir="rtl">${e(x.nama_arab)}</p>`}
    ${x.tentang ? `<h2>${T(l, 'Tentang', 'About', 'نبذة')}</h2><p class="lede">${e(x.tentang)}</p>` : ''}
    <h2>${T(l, 'Isi', 'Contents', 'المحتوى')}</h2>
    <dl class="ai-metrics">${angka.map(([v, k]) => `<div><dd><bdi>${e(v)}</bdi></dd><dt>${e(k)}</dt></div>`).join('')}</dl>
    ${r && r.awal ? `<p class="ai-row"><span>${T(l, 'Rentang wafat pengarang', 'Authors’ death dates', 'وفيات المؤلفين')}</span><bdi>${e(pick(c.metadata.period, l))}</bdi></p>` : ''}
    ${asal ? `<p class="ai-row"><span>${T(l, 'Cetakan terpilih dari', 'Editions selected from', 'الطبعات المختارة من')}</span><span>${e(asal)}</span></p>` : ''}
    ${cabang ? `<ul class="ai-chips">${cabang}</ul>` : ''}
    ${induk ? `<h3>${T(l, 'Kitab terbesar', 'Largest works', 'أكبر الكتب')}</h3><ol class="ai-induk">${induk}</ol>` : ''}
    <p><a class="button button-secondary" href="#daftar-kitab">${T(l, 'Lihat daftar kitab lengkap', 'See the complete list', 'اعرض القائمة كاملة')}${arrow}</a></p>
    <h2>${T(l, 'Cara disusun', 'How it was built', 'طريقة الإعداد')}</h2>
    <dl class="ai-facts">
      <div><dt>${T(l, 'Rekaman diperiksa dari tiga perpustakaan', 'Records examined across three libraries', 'سجلًّا مفحوصًا في ثلاث مكتبات')}</dt><dd>${number(cara.rekaman_diperiksa_semua_ilmu || REKAMAN_DIPERIKSA, l)}</dd></div>
      ${cara.rekaman_digabung_ke_kitab_ini ? `<div><dt>${T(l, 'Rekaman dan cetakan yang dibandingkan untuk AI ini', 'Records and editions compared for this AI', 'سجلات وطبعات قورنت لهذا المساعد')}</dt><dd>${number(cara.rekaman_digabung_ke_kitab_ini, l)}</dd></div>` : ''}
      <div><dt>${T(l, 'Karya diblok (semua ilmu)', 'Works blocked (all fields)', 'مؤلفات مستبعدة (كل العلوم)')}</dt><dd>${number(cara.karya_diblok_semua_ilmu, l)}</dd></div>
      <div><dt>${T(l, 'Karya ditahan karena belum terbukti', 'Works held pending evidence', 'مؤلفات موقوفة لعدم ثبوتها')}</dt><dd>${number(cara.karya_ditahan_semua_ilmu, l)}</dd></div>
      <div><dt>${T(l, 'Karya ganda atau termuat yang dibuang', 'Duplicate or contained works removed', 'مكررات أو مضمَّنات حُذفت')}</dt><dd>${number(cara.karya_termuat_semua_ilmu, l)}</dd></div>
    </dl>
    ${cara.catatan_penyusun ? `<p>${e(cara.catatan_penyusun)}</p>` : ''}
    <p class="fine-print">${T(l, 'Penjelasan lengkap aturan penyaringan ada di halaman', 'The full curation rules are on the', 'تفصيل قواعد التنقيح في صفحة')} <a href="${pathFor(l, 'kurasi')}">${T(l, 'Kurasi', 'Curation page', 'التنقيح')}</a>.</p>
    <h2>${T(l, 'Batasan', 'Limits', 'الحدود')}</h2>
    <ul class="ai-limits">${batasan.map(b => `<li>${e(b)}</li>`).join('')}</ul>
    ${contoh.length ? `<h2>${T(l, 'Contoh tanya-jawab', 'Sample questions', 'أمثلة')}</h2>${contoh.map(q => `<article class="ai-qa"><h3>${e(q.tanya || '')}</h3><p>${e(q.jawab || '')}</p>${q.rujukan ? `<p class="fine-print">${e(q.rujukan)}</p>` : ''}</article>`).join('')}` : ''}
    <p><a class="button" href="${pathFor(l, 'download')}">${T(l, 'Buka di aplikasi', 'Open in the app', 'افتح في التطبيق')}${arrow}</a></p>
  </div></section>
  ${daftarKitab(l, c)}`;
}

// ── Halaman Kurasi (kriteria dan angka; tanpa daftar nama tokoh) ──────
export function halamanKurasi(l, d) {
  const tot = d.catalog.reduce((s, c) => s + c.metadata.books, 0);
  const st = d.catalog[0]?.info?.cara_disusun || {};
  const poin = [
    [T(l, 'Hanya Ahlussunnah wal Jama’ah', 'Ahl al-Sunna wa-l-Jamāʿa only', 'أهل السنة والجماعة فقط'), T(l, 'Kitab dimuat bila pengarangnya dari tradisi Ahlussunnah wal Jama’ah: empat mazhab fikih, akidah Asy’ariyyah dan Maturidiyyah, serta tasawuf yang lurus.', 'Works are included when their authors belong to the Sunni tradition: the four schools of law, Ashʿarī and Māturīdī theology, and sound taṣawwuf.', 'تُدرج الكتب إذا كان مؤلفوها من أهل السنة والجماعة: المذاهب الأربعة، والعقيدة الأشعرية والماتريدية، والتصوف السني.')],
    [T(l, 'Penyaringan tiga lapis', 'Three layers of filtering', 'تنقيح على ثلاث طبقات'), T(l, 'Yang diperiksa bukan hanya pengarang, tetapi juga pensyarah dan muhaqqiq cetakannya.', 'Not only the author is checked, but also the commentator and the editor of the edition.', 'لا يُفحص المؤلف وحده، بل الشارح ومحقق الطبعة أيضًا.')],
    [T(l, 'Matan saja bila perlu', 'Original text only where needed', 'المتن فقط عند الحاجة'), T(l, 'Bila satu-satunya cetakan ditahqiq oleh muhaqqiq yang disaring, matan kitab tetap dimuat, tetapi muqaddimah dan catatan kaki muhaqqiq dibuang.', 'If the only edition was prepared by a filtered editor, the work’s text is kept but the editor’s introduction and footnotes are removed.', 'إذا لم تتوفر إلا طبعة بتحقيق مستبعد أُبقي المتن وحُذفت مقدمة المحقق وحواشيه.')],
    [T(l, 'Tanpa tebakan metadata', 'No guessed metadata', 'لا تخمين في البيانات'), T(l, 'Nama pengarang, tahun wafat, muhaqqiq, dan penerbit diambil dari kartu kitab dan tabel pengarang di sumber. Yang tidak tercantum ditandai demikian. Kitab yang pengarang atau tahun wafatnya tidak bisa dibuktikan ditahan, bukan dimuat.', 'Author, death date, editor, and publisher come from the source cards and author tables. Missing fields are marked as missing. Works whose author or death date cannot be established are held back, not included.', 'يؤخذ اسم المؤلف وسنة وفاته والمحقق والناشر من بطاقات المصدر وجداول المؤلفين، ويُشار إلى ما لم يُذكر، وتوقف الكتب التي لم يثبت مؤلفها أو وفاته.')],
    [T(l, 'Satu kitab, satu cetakan terbaik', 'One work, one best edition', 'كتاب واحد بأفضل طبعة'), T(l, 'Salinan yang sama dari tiga perpustakaan digabung lewat sidik isi teksnya, lalu dipilih satu cetakan: bermuhaqqiq yang lolos, lengkap, bernomor halaman sesuai cetakan.', 'Copies of the same work across three libraries are matched by their text fingerprint, then one edition is chosen: a passing editor, complete, with print page numbers.', 'تُوحَّد نسخ الكتاب الواحد من المكتبات الثلاث ببصمة نصه، ثم تُختار طبعة واحدة: محقق مقبول، كاملة، بترقيم مطابق للمطبوع.')],
  ];
  return `${pageHead(l, T(l, 'Kurasi', 'Curation', 'التنقيح'), T(l, 'Bagaimana kitab dipilih', 'How works are selected', 'كيف تُختار الكتب'), T(l, 'Aturan yang sama dipakai untuk semua AI di aplikasi. Halaman ini menjelaskan kriterianya; daftar nama tokoh tidak dipublikasikan.', 'The same rules apply to every AI in the app. This page explains the criteria; lists of individual names are not published.', 'تُطبَّق القواعد نفسها على جميع المساعدين في التطبيق. تشرح هذه الصفحة المعايير دون نشر قوائم بأسماء الأشخاص.'))}
  <section class="section compact-top"><div class="container">
    <dl class="ai-facts kurasi-angka">
      <div><dt>${T(l, 'Rekaman diperiksa dari Maktabah Hazmi, Maktabah Baru, dan Shamela 4', 'Records examined from Maktabah Hazmi, Maktabah Baru, and Shamela 4', 'سجلًّا مفحوصًا من مكتبة الحزمي والمكتبة الجديدة والشاملة ٤')}</dt><dd>${number(REKAMAN_DIPERIKSA, l)}</dd></div>
      <div><dt>${T(l, 'Kitab lolos dan dimuat', 'Works included', 'كتابًا مدرجًا')}</dt><dd>${number(tot, l)}</dd></div>
      <div><dt>${T(l, 'Karya diblok', 'Works blocked', 'مؤلفًا مستبعدًا')}</dt><dd>${number(st.karya_diblok_semua_ilmu || 0, l)}</dd></div>
      <div><dt>${T(l, 'Karya ditahan karena belum terbukti', 'Works held pending evidence', 'مؤلفًا موقوفًا لعدم ثبوته')}</dt><dd>${number(st.karya_ditahan_semua_ilmu || 0, l)}</dd></div>
    </dl>
    <ol class="kurasi-list">${poin.map(([h, p], i) => `<li><span class="serial">${String(i + 1).padStart(2, '0')}</span><h2>${e(h)}</h2><p>${e(p)}</p></li>`).join('')}</ol>
    <p>${T(l, 'Menemukan kesalahan metadata atau kitab yang seharusnya tidak dimuat?', 'Found a metadata error or a work that should not be included?', 'وجدت خطأ في البيانات أو كتابًا لا ينبغي إدراجه؟')} <a href="${pathFor(l, 'report')}">${T(l, 'Laporkan', 'Report it', 'أبلغنا')}</a>.</p>
  </div></section>`;
}

// Pengalihan URL AI yang dilebur / disembunyikan
export const PENGALIHAN = Object.assign(JSON.parse(fs.readFileSync(new URL('../content/pengalihan.json', import.meta.url), 'utf8')), {'habib-umar': ''});
export function halamanAlih(l, tujuan) {
  const url = tujuan ? pathFor(l, 'library/' + tujuan) : pathFor(l, 'library');
  return `${pageHead(l, 'OpenTurath', T(l, 'Halaman ini sudah dipindahkan', 'This page has moved', 'نُقلت هذه الصفحة'))}<section class="container section compact-top"><p><a href="${url}">${T(l, 'Buka halaman barunya', 'Open the new page', 'افتح الصفحة الجديدة')}${arrow}</a></p><meta http-equiv="refresh" content="0; url=${url}"></section>`;
}
