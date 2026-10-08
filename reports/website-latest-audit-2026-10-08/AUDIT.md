# Audit website OpenTurath terbaru — 8 Oktober 2026

**Kesimpulan:** arah komunikasi sudah membaik, tetapi janji ilmiahnya meningkat lebih cepat daripada bukti yang dapat diperiksa. Identitas V6 layak dipertahankan. Prioritas perbaikan adalah ketepatan klaim, contoh sumber yang benar-benar dapat dibuka, kejelasan tahap produk, dan konsistensi antarahalaman. Memperbesar bahasa teknis tidak menyelesaikan kekurangan bukti.

## Dasar dan batas audit

- Situs utama: [openturath.id](https://openturath.id/), diperiksa langsung melalui Chrome pada 8 Oktober 2026. Respons tambahan bertanggal server 04:55 UTC.
- 38 kunjungan kombinasi halaman/viewport: beranda ID/EN/AR pada lebar 1440, 390, dan 320 px; halaman produk, koleksi, riset, metodologi, kebijakan, bantuan, kontak, dan rilis; robots, sitemap, serta satu URL tidak dikenal. Pemeriksaan tambahan mencakup tiga hero pada 320 px dan dimensi Q001.
- Sumber lokal yang dibandingkan: `/Users/apple/Downloads/ramadhan/website`. Commit website terakhir saat diperiksa: `1425cce`. Working tree website bersih. Pemeriksaan aplikasi dilakukan terbatas pada kode lokal; ini bukan verifikasi konfigurasi backend produksi.
- Tidak mengubah website, aplikasi, atau folder asli `/Users/apple/Downloads/openturath-website 6`. Tidak login, mengirim formulir, melakukan transaksi, atau deploy.
- Bukti: [rekaman live](live.json), [pemeriksaan tambahan](supplement.json), [temuan sumber dan hash](source-findings.json), serta screenshot dalam folder laporan ini. Audit terdahulu merupakan konteks historis, bukan pengganti pemeriksaan terbaru.
- Catatan AI dan angka pemakaian Claude yang sebelumnya diberikan pengguna tetap bahan pertimbangan. Screenshot asli, tanggal, kepemilikan project, dan hubungan workload dengan OpenTurath belum tersedia dalam bahan audit ini. Angka tersebut tidak diangkat menjadi fakta terverifikasi.

**Cara membaca status:** TERKONFIRMASI berarti terlihat pada situs/kode yang diperiksa. BELUM TERBUKTI berarti klaim mungkin benar, tetapi bukti yang diperlukan belum tersedia. PENILAIAN EDITORIAL merupakan pertimbangan bahasa/desain, bukan hasil benchmark. P1 perlu dibenahi sebelum situs dipakai sebagai bukti kesiapan produk/riset kepada reviewer; P2 memperbaiki kejelasan dan kualitas. Tidak ada eksploitasi atau audit penetrasi dalam cakupan ini.

## Yang sudah membaik dan perlu dipertahankan

1. Hero kini menyebut penelitian, teks Arab, atribusi, jilid/halaman, dan sumber primer. Reviewer lebih cepat memahami masalah yang dituju.
2. Research dan About masuk navigasi utama. Tombol utama hero benar-benar menuju Research; jalur bukti lebih dekat.
3. Homepage membatasi pratinjau pada enam bidang. Daftar lengkap tetap tersedia melalui Library.
4. Halaman Q001 mengakui satu pertanyaan, enam produk, dan batas generalisasi. Status belum diperiksa serta ketiadaan skor tetap ditampilkan.
5. Kata-kata tentang guru, pembacaan konteks, dan kejujuran atribusi menjaga identitas ilmiah OpenTurath.
6. Pada halaman HTML yang diperiksa tidak ditemukan overflow horizontal, gambar tanpa atribut alt, atau galat JavaScript. Lang/dir sesuai bahasa dan setiap halaman HTML memiliki satu H1.
7. Dialog rujukan/menu dapat ditutup dengan Escape; FAQ dapat dibuka dengan keyboard; tema gelap bertahan setelah reload. Pencarian Arab dengan harakat menemukan satu koleksi relevan; filter hadis menampilkan tiga koleksi.

Ini adalah hasil pemeriksaan terbatas, bukan sertifikasi aksesibilitas, kebenaran ilmiah, atau kesiapan transaksi.

## Temuan yang harus diprioritaskan

| ID | Prioritas / aspek | Temuan dan status | Dampak / perbaikan |
|---|---|---|---|
| F01 | P1 — kredibilitas | **TERKONFIRMASI:** hero ID menjanjikan “Sumber yang Terverifikasi”; Q001 berisi 10 kutipan, semuanya `not-reviewed`, tanpa `sourceUrl`. | “Sudah terverifikasi” berbeda dari “dapat diperiksa”. Gunakan bahasa bantuan penelusuran; status verifikasi harus mengikuti setiap bukti. |
| F02 | P1 — bukti produk | **TERKONFIRMASI:** “Open reference” membuka bibliografi dengan “Not yet reviewed”, “Edition: Not yet available”, tanpa sumber yang bisa dibuka. | Demonstrasi belum menutup alur pertanyaan → ibarah → edisi → sumber. Ubah label menjadi “Lihat catatan rujukan” sampai akses sumber benar-benar tersedia. |
| F03 | P1 — pengguna ahli | **BELUM TERBUKTI:** About menyatakan pengujian terus-menerus bersama peneliti naskah, akademisi, dan ulama pesantren; tidak ada catatan peserta/tugas/tanggal/hasil dalam bahan yang diperiksa. | Reviewer tidak bisa membedakan demo informal, pemakaian riset, dan penelaahan ilmiah. Sediakan catatan anonim bila nama tidak boleh disebut; klaim ini tidak boleh diasumsikan benar dari copy saja. |
| F04 | P1 — Claude | **BELUM TERBUKTI:** About menyebut workflow aktif untuk pemahaman Arab long-context, ontology modeling, dan audit otomatis halusinasi kutipan. | Bukti pemakaian Claude Code untuk R&D tidak otomatis membuktikan ketiga workload tersebut. Pisahkan coding/R&D, eksperimen corpus/evaluation, dan integrasi runtime; lampirkan input-output dan artefak masing-masing. |
| F05 | P1 — arsitektur | **BELUM TERBUKTI:** About menyebut indexing 5.370 karya dan memastikan setiap sitasi langsung dapat diverifikasi. How it works menjanjikan struktur matan/syarah/hasyiyah dipertahankan utuh. | Statistik katalog bukan bukti ingest/index/runtime. Tampilkan diagram pipeline aktual, manifest dan contoh retrieval. Tidak ditemukannya artefak pada audit ini bukan bukti bahwa eksperimen eksternal tidak ada. |
| F06 | P1 — konsistensi riset | **TERKONFIRMASI:** Research dan Methodology menyebut empat dimensi; Q001 menampilkan tujuh: quotation match, bibliographic accuracy, support for claims, interpretive accuracy, completeness, scope alignment, robustness. | Kerangka evaluasi tidak konsisten. Pilih kerangka canonical dan jelaskan pemetaan jika empat dimensi utama mempunyai subdimensi. Jangan hanya mengganti angka tanpa menyelaraskan definisi. |
| F07 | P1 — corpus | **TERKONFIRMASI:** enam modul memiliki jumlah kitab berbeda pada dua sumber metadata yang dipakai website. | Angka presisi memberi kesan lebih matang daripada definisi satuannya. Rekonsiliasi karya/edisi/entri, versi data, overlap, dan status diproses/terindeks. |
| F08 | P1 — akses produk | **TERKONFIRMASI:** Android, macOS, Windows semuanya Coming Soon; tombol membership “Access in the app” juga menuju Download. | Jalur penggunaan publik berakhir tanpa aplikasi. Pilih status yang jelas—misalnya distribusi terbatas—dan arahkan ke demo atau permintaan akses yang benar-benar tersedia. Tidak membuktikan aplikasi lokal tidak ada. |
| F09 | P1 — privasi/arsitektur | **TERKONFIRMASI:** Privacy menyebut “isolated research computing sessions” dan penyedia generik “Authentication & Computing Infrastructure”; kode lokal masih menunjuk NotebookLM/bridge. | Penyedia pemroses percakapan dan batas tanggung jawab kabur. Kebijakan harus menjelaskan arus data aktual, penyedia, penyimpanan, serta batas kendali OpenTurath. Ini audit transparansi, bukan putusan kepatuhan hukum. |
| F10 | P1 — analitik | **TERKONFIRMASI:** footer “No external analytics trackers”; live memuat script dari `static.cloudflareinsights.com` dan melakukan request `/cdn-cgi/rum`. | Pernyataan absolut tidak menggambarkan instrumentasi live. Nonaktifkan beacon jika itu kebijakan yang dipilih, atau jelaskan analitik performa Cloudflare secara akurat. Tidak ada bukti di sini tentang profiling iklan atau data percakapan dikirim ke beacon. |
| F11 | P2 — penyimpanan data | **TERKONFIRMASI pada kode lokal:** `BookmarkService` menyinkronkan isi bookmark ke Firestore; model mencakup fullAnswer, kutipan, sitasi, dan personalNote. Privacy berfokus pada notes lokal serta database transaksi/entitlement. | Bedakan Research Notes yang lokal dari bookmark/jawaban tersimpan yang tersinkron. Perlu pencocokan dengan versi aplikasi yang didistribusikan sebelum menerbitkan pernyataan kebijakan final. |
| F12 | P2 — nada akademik | **PENILAIAN EDITORIAL:** “systematically ... catastrophic failure modes”, “every citation”, “dramatically accelerating”, “strictly”, “rigorous”, dan “شفافية كاملة” terlalu absolut. | Nada seperti proposal AI generik; kemampuan yang lebih spesifik memerlukan bukti lebih spesifik. Jelaskan kegagalan konkret dengan bahasa terukur, lalu tunjukkan contoh. |
| F13 | P2 — bahasa Arab | **PENILAIAN EDITORIAL:** “تحقيق التراث” berpotensi dibaca sebagai kerja tahqiq/edisi kritis; “استكشف أبحاث التحقق” terasa tidak alami dan tidak menjelaskan arsip. | Gunakan kosakata penelusuran/penelaahan teks sesuai fungsi aktual, dan bedakan تحقيق النصوص dari pemeriksaan kutipan. |
| F14 | P2 — hero/mobile | **TERKONFIRMASI:** pada AR 320×844, bagian tombol mulai di y=898; ID/EN y=674. Judul Arab menjadi lima baris; subjudul masih mengulang positioning. | Tombol Arab keluar dari layar pertama. Ringkas judul dan subjudul dahulu, lalu atur tipografi/spasi per bahasa. Tidak perlu mengganti gaya V6. |
| F15 | P2 — koreksi ilmiah | **TERKONFIRMASI:** Methodology mengarahkan pembaca ke kanal pelaporan formal, tetapi pengiriman situs dinonaktifkan. Kontak menyediakan unduhan laporan dan email. | Sebut jalur aktual “kirim melalui email” dan jelaskan unduhan hanya menyimpan file; jangan membuat pengguna mengira laporan sudah terkirim. |
| F16 | P2 — kontrol publikasi | **TERKONFIRMASI pada sumber:** catatan `proof.json` menyatakan build rilis ditolak jika reviewed=false, tetapi build tidak membaca file itu. `releases.json` juga bukan sumber yang dibaca renderer/build saat ini. | Pengelola bisa mengira flag/URL tersebut mengendalikan publikasi. Hapus konfigurasi usang atau hubungkan kontrol yang benar. Publikasi arsip berstatus pending dapat sah; yang perlu dicegah adalah promosi pending menjadi verified. |
| F17 | P2 — keamanan konfigurasi | **TERKONFIRMASI:** respons live EN berisi HSTS, tetapi tidak berisi CSP, nosniff, X-Frame-Options, Referrer-Policy atau Permissions-Policy yang tercantum di konfigurasi Firebase lokal. | Ada perbedaan konfigurasi dan respons yang diterima browser. Periksa site/deploy/CDN aktif. Ini celah hardening yang perlu ditelusuri, bukan bukti adanya eksploit. |
| F18 | P2 — penawaran | **TERKONFIRMASI pada sumber:** konfigurasi masih `pending-backend-mapping`; harga tahawwulat lokal mulai Rp300.000/bulan, berbeda dari harga modul umum Rp50.000. | “Mulai Rp50.000” sendiri benar sebagai harga minimum. Namun beri contoh cakupan dan pengecualian supaya pembaca tidak mengasumsikan seluruh disiplin mempunyai tarif tersebut. Jangan menyimpulkan checkout produksi salah tanpa mengujinya. |
| F19 | P2 — panjang halaman | **TERKONFIRMASI / PENILAIAN EDITORIAL:** homepage sekitar 11.800 px desktop dan 15.900–16.500 px pada mobile 390 px, termasuk footer dan ruang layout. | Materi yang paling menentukan kepercayaan masih tersebar. Dekatkan satu contoh bukti selesai dan status produk ke hero; pendekkan pengulangan dan ruang antarseksi pada mobile. Panjang sendiri bukan bug. |
| F20 | P2 — SEO/penemuan | **TERKONFIRMASI:** title beranda EN hanya “Home — OpenTurath”; metadata deskripsi sangat panjang dan mengulang positioning. Canonical, hreflang, robots dan sitemap tersedia. | Buat title yang menyebut fungsi produk dan deskripsi singkat tanpa janji berlebih. Mapping x-default pada halaman dalam perlu ditinjau dari renderer; indeks Google dan hasil pencarian belum diperiksa. |

Rujukan F10: [dokumentasi Cloudflare mengenai sumber beacon dan pengumpulan data](https://developers.cloudflare.com/web-analytics/data-metrics/data-origin-and-collection/). Beacon analitik performa harus dibedakan dari tracker iklan. Sejumlah request RUM tercatat aborted saat navigasi dalam audit; itu tidak membuktikan semua kiriman berhasil, maupun bahwa tidak ada pengumpulan.

## Corpus: selisih yang masih terbuka

| Modul | Metadata modul | Metadata training |
|---|---:|---:|
| Fikih Syafi’i | 103 | 87 |
| Hadis | 1.141 | 1.173 |
| Tarikh/Sirah | 499 | 345 |
| Fikih Muqaran | 189 | 61 |
| Syarah Hadis | 202 | 172 |
| Musthalah Hadis | 393 | 165 |

Katalog Syafi’i aplikasi lokal mempunyai 87 entri. Ini tidak menetapkan 87 sebagai jumlah karya unik yang benar: entri, edisi, karya gabungan, dan duplikasi perlu dibedakan. Jangan langsung mengganti 103 menjadi 87.

`validateCatalogMetadata` mencocokkan angka kitab dengan metadata modul dan angka partisi dengan metadata training; ia tidak menguji kesamaan jumlah kitab di antara keduanya. Karena itu konsistensi terhadap satu sumber tidak membuktikan konsistensi antarsumber. Jumlah 5.370 merupakan agregat modul aktif, belum terbukti sebagai total karya unik bebas overlap atau jumlah karya yang seluruhnya berhasil ditelusuri melalui runtime.

Sumber: [validator](/Users/apple/Downloads/ramadhan/website/src/metadata.mjs), [metadata modul](/Users/apple/Downloads/ramadhan/website/content/metadata/metadata_modul_lengkap.json), [metadata training](/Users/apple/Downloads/ramadhan/website/content/metadata/metadata_training_seluruh_ai.json), [katalog aplikasi](/Users/apple/Downloads/ramadhan/openturath_ai/assets/data/01_KATALOG_FIKIH_SYAFII.json).

## Audit copy: bagian yang paling perlu ditulis ulang

Usulan di bawah adalah draft editorial, belum diterapkan. Klaim operasional tetap harus dicocokkan dengan bukti pemilik project.

| Copy sekarang | Masalah | Arah pengganti |
|---|---|---|
| “Riset Khazanah Keilmuan Klasik dengan Sumber yang Terverifikasi” | Panjang; mengubah prinsip pemeriksaan menjadi hasil yang sudah disahkan. | “Telusuri teks turats. Periksa rujukannya.” |
| “AI-Native Research Infrastructure for Classical Islamic Scholarship” sebagai subjudul hero | Identitas tepat untuk reviewer, tetapi mengulang headline dan menambah jargon untuk pengguna umum. | Tempatkan sebagai satu kalimat positioning pada About; hero menjelaskan pekerjaan dan output. |
| “Locate exact Arabic passages...” | “Exact” adalah target kualitas yang belum dibuktikan oleh benchmark tersedia. | “Explore Arabic passages and their bibliographic references.” Tambahkan verifikasi hanya bila tautan sumber sudah tersedia. |
| “Edition review is documented separately” | Terdengar sudah ada dokumentasi review lengkap; edisi belum tersedia. | “Pemeriksaan terhadap edisi sumber belum selesai. Rujukan berikut berasal dari jawaban yang diarsipkan.” |
| “Traceable Scholarly Evidence & Textual Verification” | Memperkenalkan kumpulan bukti seolah verifikasi sudah dilakukan. | “Arsip perbandingan dan status pemeriksaan sumber.” |
| “four evaluation dimensions ... manuscript collation notes presented openly” | Empat vs tujuh; catatan collation aktual belum disediakan. | “Pertanyaan, jawaban asli, dan status pemeriksaan kutipan ditampilkan di sini. Penilaian ilmiah masih menunggu bukti sumber.” |
| “systematically exhibit catastrophic failure modes” | Klaim populasi model dan tingkat kegagalan tanpa pengukuran. | “Jawaban AI dapat salah menisbahkan pendapat, mengubah redaksi, atau memberi rujukan yang tidak dapat ditemukan.” |
| “an unverifiable citation renders an entire inquiry invalid” | Menyamakan kekurangan satu rujukan dengan batalnya seluruh penelitian. | “Rujukan yang tidak dapat diperiksa melemahkan klaim yang bergantung padanya.” |
| “ungrounded syncretism (talfiq)” / “talfiq al-batil” | Mencampur kegagalan atribusi AI dengan penilaian fikih yang memerlukan konteks tersendiri. | “Mencampur pendapat dari mazhab berbeda tanpa menjelaskan sumber dan batasnya.” |
| “dramatically accelerating” / “ensuring every citation” | Janji kecepatan dan cakupan universal tanpa pengukuran. | “Membantu peneliti menemukan ibarah dan menelaah rujukannya.” |
| Klaim kolaborasi ahli berkelanjutan | Belum ada peserta/tugas/hasil yang dapat diperiksa. | Isi hanya berdasarkan catatan pengujian. Jika pengujian belum terdokumentasi, jangan menerbitkan narasi keberhasilan; jelaskan kebutuhan evaluasinya. |
| Klaim Claude ontology/citation auditing aktif | Melampaui bukti penggunaan yang tersedia dalam percakapan. | Jika pemilik mengonfirmasi: “Claude digunakan dalam pengembangan dan riset OpenTurath.” Workload khusus dan API ditambahkan setelah artefaknya tersedia. |
| “isolated ... rigorous privacy protections” | Kata jaminan tanpa penyedia, batas isolasi, atau kondisi sesi. | Jelaskan penyedia dan arus data aktual dengan bahasa biasa. Jangan menggantinya dengan jaminan keamanan generik. |
| “Begin your study in OpenTurath” / “Access in the app” | Mengajak mulai segera ketika unduhan publik belum tersedia. | Gunakan status distribusi yang benar dan CTA menuju demo/permintaan akses yang berfungsi. |
| “تحقيق التراث الإسلامي” | Makna tahqiq lebih khusus daripada penelusuran referensi. | “تصفّح نصوص التراث، وتحقّق من إحالاتها” |
| “استكشف أبحاث التحقق” | Kurang alami dan samar. | “اطّلع على أرشيف المقارنة” untuk CTA menuju arsip perbandingan. |

### Contoh hero tiga bahasa yang lebih ringkas

**Indonesia**

Telusuri teks turats. Periksa rujukannya.

OpenTurath dikembangkan untuk membantu penelitian khazanah Islam dengan mengutamakan ibarah, konteks, dan rujukan kitab. Lihat contoh jawaban serta status pemeriksaan sumbernya.

CTA: **Lihat arsip perbandingan** · **Jelajahi khazanah**

**English**

Explore classical texts. Examine their sources.

OpenTurath is being developed to support research in classical Islamic scholarship, with attention to Arabic passages, context, and bibliographic references. Explore archived answers and their source-review status.

CTA: **View the comparison archive** · **Explore the library**

**العربية**

تصفّح نصوص التراث، وتحقّق من إحالاتها

يُطوَّر OpenTurath لخدمة البحث في التراث الإسلامي، مع العناية بعبارات النصوص وسياقها وإحالاتها. اطّلع على نماذج الإجابات وحالة مراجعة مصادرها.

CTA: **اطّلع على أرشيف المقارنة** · **تصفّح الخزانة**

Positioning “infrastruktur riset” tetap dipertahankan pada About. Setelah satu contoh end-to-end terverifikasi tersedia, subcopy dapat diperkuat dengan menjelaskan langkah pemeriksaan sumber yang benar-benar bisa dilakukan pengguna.

## Desain, alur, aksesibilitas, SEO, dan performa

**Desain:** serif editorial, monokrom, foto kitab, grid koleksi, dan nada tenang masih selaras dengan V6. Kekurangannya ada pada hierarki informasi: headline besar, subjudul besar, dan paragraf panjang menjelaskan hal yang serupa. Screenshot [ID mobile](id-390.png), [EN desktop](en-1440.png), dan [AR 320](ar-320.png) menunjukkan dampaknya. Pertahankan identitas, ringkas copy, lalu sesuaikan ukuran/spasi Arab.

**Alur pengguna:** jalur Research sudah bekerja, tetapi hasilnya adalah arsip belum ditelaah. Jalur membership berakhir pada Download tanpa berkas. QR mengarah ke halaman download; QR tidak menyediakan binary atau mengatasi Coming Soon. Kartu “Available in the app” perlu diberi konteks distribusi aplikasi yang jelas.

**Aksesibilitas:** hasil dasar cukup baik: tidak ada overflow pada viewport yang diuji, tombol terlihat memiliki nama, FAQ keyboard dan Escape berfungsi. Pemeriksaan awal sempat menandai tombol dalam panel bukti yang tersembunyi; pemeriksaan tambahan atas tombol yang terlihat tidak menemukan tombol tanpa label. Ini bukan defect yang harus diperbaiki berdasarkan scan awal. Target navbar mobile berkisar 38–43 px lebarnya; pertimbangkan 44 px untuk kenyamanan sentuh, bukan menyatakan gagal WCAG hanya dari ukuran itu. Screen reader, fokus seluruh dialog, kontras terukur, zoom 200%, Safari/Firefox dan perangkat nyata belum diaudit lengkap.

**SEO:** canonical/hreflang/JSON-LD tersedia dan robots mengizinkan indeks; URL acak mengembalikan 404. Title beranda dapat lebih bermakna. Sitemap berhasil dibuka, tetapi semua URL sitemap, pengindeksan mesin pencari, dan preview share eksternal belum divalidasi. Jangan mengubah deskripsi SEO menjadi klaim verifikasi yang lebih kuat daripada isi halaman.

**Performa:** tidak ada gambar rusak yang tercatat pada HTML yang diperiksa. Waktu navigasi dalam `live.json` bersifat diagnostik: terdapat pengaruh cache, jaringan dan browser audit. Ini bukan hasil Lighthouse atau Core Web Vitals. Angka transfer yang nol pada sebagian resource tidak cukup untuk menyimpulkan payload nol atau performa baik. Audit ini tidak memberikan skor performa. Animasi normal dan no-JavaScript belum diuji lengkap; screenshot utama menggunakan preferensi reduced motion.

**Keamanan/transparansi:** HSTS teramati; header hardening lain pada konfigurasi lokal tidak muncul dalam respons live. Perlu memastikan konfigurasi yang benar-benar melayani domain, termasuk injeksi CDN. Jangan menyebut situs “aman” hanya karena HTTPS atau karena tidak ada galat JavaScript.

**Pembayaran/kebijakan:** Midtrans sudah konsisten dalam copy terbaru; temuan lama tentang nama penyedia lain tidak diulang sebagai cacat versi sekarang. Nominal minimum cocok dengan modul umum pada kode backend lokal. Pembayaran, webhook, aktivasi, refund, autentikasi dan penghapusan akun produksi belum dijalankan.

**Hak sumber:** halaman kebijakan penggunaan tersedia, tetapi Q001 belum menyediakan edisi dan URL sumber per kutipan. Sebelum menambahkan scan/PDF, dokumentasikan izin atau dasar akses masing-masing edisi. Tidak ada kesimpulan pelanggaran hak cipta dari audit ini.

## Jawaban atas tujuan reviewer 30–90 detik

| Pertanyaan reviewer | Keadaan versi terbaru |
|---|---|
| Apa OpenTurath dan masalahnya? | Lebih jelas: riset turats dan ketepatan rujukan. |
| Apa yang sudah dibangun? | Aplikasi/katalog/arsip terlihat pada bahan lokal; fungsi runtime dan pipeline penuh belum ditunjukkan dalam demo publik yang diperiksa. |
| Bukti bahwa sistem bekerja? | Satu arsip, enam produk, sepuluh kutipan pending. Belum ada skor atau contoh sumber terbuka yang selesai. |
| Siapa yang menguji? | Copy mengklaim komunitas ahli; bukti peserta dan hasil belum tersedia. |
| Claude relevan untuk apa? | Narasi lebih spesifik, tetapi workload spesifik belum mempunyai artefak yang dapat diperiksa. |
| Apa yang tambahan API capacity akan buka? | Roadmap menyebut ingestion, collation dan evaluation; belum ada satu workload dengan volume, throughput, biaya, baseline, dan hasil kecil yang tervalidasi. |
| Bisa dicoba sekarang? | Jalur unduhan publik berakhir pada Coming Soon. |

Reviewer kini lebih cepat memahami ambisi project. Ia masih kesulitan memastikan batas antara fitur nyata, eksperimen aktif, dan target berikutnya.

## Perubahan prioritas untuk plan

1. **Rapikan klaim yang sudah live.** Selaraskan verified/verifiable; empat/tujuh dimensi; expert testing; Claude workload; privacy/analytics. Ini perubahan editorial terarah, bukan redesign.
2. **Selesaikan satu contoh sumber end-to-end.** Pakai pertanyaan dan output aplikasi nyata, kutipan berkonteks, identitas edisi, jilid/halaman, scan atau tautan yang boleh diakses, reviewer/tanggal dan catatan keterbatasan. Contoh ini membuktikan workflow, tidak membuktikan akurasi keseluruhan.
3. **Buat catatan Claude per lapisan.** Coding/R&D, corpus processing, retrieval/reasoning, evaluation, runtime: masing-masing current/experimental/planned, metode akses/model/tanggal, satu input-output, dan bottleneck terukur. Jangan menafsirkan cache-read sebagai volume unik corpus.
4. **Rekonsiliasi manifest corpus.** Definisikan work/edition/file/volume/page, hitung duplikasi, bedakan katalog/processed/indexed, dan selesaikan enam selisih di atas.
5. **Tegaskan status distribusi dan penawaran.** Selaraskan availability, CTA, download, catatan rilis dan harga per bidang dengan aplikasi yang benar-benar diberikan kepada pengguna.
6. **Perbaiki pengalaman baca secara terbatas.** Ringkas hero/intro About, dekatkan bukti, sesuaikan hero Arab 320 px, kurangi pengulangan dan panjang mobile tanpa mengganti gaya V6.
7. **Periksa deployment dan kebijakan aktual.** Cocokkan header/CDN/beacon, Notes vs bookmarks cloud, penyedia pemrosesan dan kanal koreksi dengan implementasi produksi.
8. **Verifikasi hasil pada browser sesudah perubahan.** Jalankan pemeriksaan teknis yang relevan, lalu lihat ulang ID/EN/AR, desktop/mobile, gelap/terang, keyboard dan alur CTA. Kelulusan build tidak menyatakan copy benar atau bukti ilmiah selesai.

Sumber implementasi: [copy](/Users/apple/Downloads/ramadhan/website/src/copy.mjs), [artikel](/Users/apple/Downloads/ramadhan/website/src/articles.mjs), [halaman](/Users/apple/Downloads/ramadhan/website/src/pages.mjs), [membership](/Users/apple/Downloads/ramadhan/website/src/membership.mjs), [build](/Users/apple/Downloads/ramadhan/website/scripts/build.mjs), [konfigurasi](/Users/apple/Downloads/ramadhan/website/site.config.json), [Firebase hosting](/Users/apple/Downloads/ramadhan/website/firebase.json), [backend aplikasi](/Users/apple/Downloads/ramadhan/openturath_ai/functions/src/index.ts), [bookmark sync](/Users/apple/Downloads/ramadhan/openturath_ai/lib/services/bookmark_service.dart), [model bookmark](/Users/apple/Downloads/ramadhan/openturath_ai/lib/models/bookmark_model.dart).
