> Arsip revisi sebelumnya. Status terbaru ada pada AUDIT_WEBSITE_V4.md dan BROWSER_QA.json.

# OpenTurath — Website Master Specification

**Tagline resmi: AI For Islamic Scholarship.**

Versi 1.0 · 19 September 2026 · Bahasa situs: Indonesia, English, العربية.

Dokumen ini menetapkan arsitektur, naskah inti, perilaku antarmuka, pengelolaan bukti, dan syarat publikasi situs. Ini adalah spesifikasi pembangunan; bukan situs yang telah dibangun atau diterbitkan. Fitur aplikasi yang disebut di sini harus dicocokkan dengan versi aplikasi yang benar-benar akan diunduh, bukan hanya dengan kode rancangan sebelumnya.

## 1. Tujuan dan batas produk

Situs membantu pengunjung memahami OpenTurath, memeriksa contoh hasilnya, mengenali koleksinya, memahami akses dan biaya, lalu mengunduh aplikasi resmi. Audiens utama: santri, pengajar, mahasiswa, peneliti, dan pembaca kitab berbahasa Arab.

Keberhasilan utama: pengunjung dapat menemukan koleksi yang relevan, memeriksa bukti sumber, dan mencapai unduhan yang sesuai perangkat tanpa kebingungan. Klik unduh tidak dianggap sebagai instalasi berhasil.

Keputusan cakupan:

- Situs publik, dapat dibaca tanpa login.
- Kajian dan penggunaan AI berlangsung di aplikasi. Contoh di situs adalah rekaman hasil, diberi label jelas.
- Tidak ada chatbot demonstrasi yang berpura-pura menghasilkan jawaban langsung.
- Situs menampilkan informasi akses; pembayaran dan akun tetap mengikuti alur aplikasi yang sudah terverifikasi.
- Tidak membuat akun situs kedua, dompet, forum, dashboard peneliti, atau pembayaran baru untuk peluncuran ini.
- Semua halaman inti memiliki versi ID, EN, AR. Jawaban pengujian asli mempertahankan bahasa aslinya; terjemahan disajikan terpisah dan diberi label.

Tiga pendekatan telah dipertimbangkan: landing page tunggal mudah dipelihara tetapi terlalu sempit untuk bukti ilmiah; portal kitab penuh memperluas cakupan menjadi aplikasi web; situs editorial dengan katalog dan pengujian adalah pilihan yang sesuai tujuan saat ini.

## 2. Identitas dan suara editorial

Nama produk selalu **OpenTurath**. Tagline **AI For Islamic Scholarship.** dipertahankan dalam bahasa Inggris pada ketiga versi. Pada halaman Arab, tagline menggunakan arah LTR lokal. Terjemahan penjelas boleh muncul di isi, tanpa menggantikan tagline resmi.

Watak: teliti, tenang, bersahaja, akrab dengan kitab, dan jelas tentang kemampuan produk. Penjelasan pendek mendahului perincian. Satu paragraf membawa satu gagasan.

Pedoman penyuntingan:

1. Utamakan kata kerja konkret: telusuri, baca, periksa, bandingkan, simpan.
2. Sebut AI secara terang. Jangan menampilkan asisten seolah-olah ulama yang hidup atau berfatwa melalui aplikasi.
3. Gunakan “kitab” atau “teks” untuk karya cetak/digital; “manuskrip” hanya untuk naskah tulisan tangan yang memang tersedia.
4. Bedakan sumber primer, syarah, hasyiah, ensiklopedia, transkrip, dan penjelasan yang dihasilkan AI.
5. “Rujukan bibliografi” tidak diganti dengan “sanad”. Label sanad hanya untuk rantai periwayatan yang benar-benar disertakan dan ditelaah.
6. Biaya, pembayaran, masa akses, perpanjangan, dan pembatalan disebut langsung. Khidmah menjelaskan tujuan layanan, bukan menyembunyikan transaksi.
7. Hindari “revolusi”, “paling canggih”, “satu-satunya di dunia”, “tanpa halusinasi”, dan “100% akurat” tanpa bukti yang mendukung cakupan persis klaim tersebut.
8. Tidak mengarang riwayat pendiri, hubungan institusional, testimoni, jumlah pengguna, penghargaan, maupun logo mitra.
9. Istilah Arab dijelaskan pada kemunculan pertama ketika diperlukan. Teks Arab sumber tidak disunting agar tampak lebih fasih.
10. Terjemahan judul karya tidak menggantikan judul Arab bibliografis. Pedoman transliterasi digunakan konsisten per bahasa.

## 3. Dasar bahan dan status bukti

Bahan yang menjadi dasar struktur:

| Bahan pengguna | Temuan yang relevan | Penggunaan yang ditetapkan |
|---|---|---|
| Pasted markdown (2).md | Satu pertanyaan tentang sentuhan non-mahram dan wudhu dalam mazhab Syafi'i; jawaban Qaf, Wisqu, Nur AI, AI Fiqh, Usul.ai, dan OpenTurath | Kandidat studi kasus Q001; arsipkan jawaban dan konteks pengujiannya |
| Pasted text (3).txt | Ringkasan evaluasi menyebut 10/10 kutipan cocok dengan Syamilah; juga mengkritik elaborasi, penisbahan, perluasan kesimpulan, cakupan, dan panjang jawaban | Sumber catatan evaluasi terdahulu; bukan sertifikat pemeriksaan independen |
| Pasted markdown(1).md | Cerita produk, kurasi, corpus, dars, dan Tahawwulat; banyak klaim absolut | Dasar wawancara editorial dan inventaris klaim; angka dan klaim memerlukan data pendukung |

Kecocokan sepuluh kutipan pada satu jawaban tidak membuktikan kebenaran semua pernyataan dalam jawaban itu, seluruh korpus, atau semua jawaban masa depan. Pemeriksaan terhadap Syamilah juga berbeda dari pemeriksaan langsung terhadap scan edisi cetak.

Pada versi awal dokumen ini, bahan mentah perbandingan tersedia, tetapi metadata lengkap pengujian dan berkas pemeriksaan sumber per kutipan belum ditetapkan. Tanggal unggah dokumen tidak boleh dijadikan tanggal pengujian. Situs tidak boleh menyatakan bahwa pengujian sudah diaudit independen hanya karena pernah dinilai oleh AI lain.

## 4. Peta situs

Semua rute konten menggunakan awalan `/{locale}`, dengan locale `id`, `en`, atau `ar`. Slug teknis dibuat stabil lintas bahasa; judul yang terlihat diterjemahkan. ID internal mempertahankan hubungan antarbahasa.

| Rute setelah locale | Halaman dan tujuan | Isi wajib | Status peluncuran |
|---|---|---|---|
| `/` | Beranda | Posisi produk, pratinjau, bukti, koleksi, unduh | Wajib |
| `/library` | Pustaka | Kategori, pencarian katalog, filter, cakupan | Wajib |
| `/library/{collection}` | Detail koleksi | Disiplin, isi, batas cakupan, akses | Wajib untuk koleksi tersedia |
| `/books/{book-id}` | Rekam bibliografi | Karya, pengarang, edisi, sumber, status pemeriksaan | Wajib untuk kitab yang dirujuk dalam studi kasus; perluasan katalog bertahap |
| `/how-it-works` | Cara kerja | Alur aplikasi, contoh sumber, batas penggunaan | Wajib |
| `/research` | Pengujian & sumber | Daftar studi kasus, metode, status bukti | Wajib |
| `/research/methodology` | Metode pengujian | Protokol, rubrik, pemilihan sampel, batas hasil | Wajib |
| `/research/{case-id}` | Detail pengujian | Pertanyaan, jawaban, rujukan, hasil pemeriksaan | Q001 saat berkas bukti memadai |
| `/research/corrections` | Koreksi pengujian | Perubahan hasil, alasan, tanggal, versi | Wajib; keadaan kosong jujur |
| `/tahawwulat` | Koleksi khusus | Pengantar, sumber kitab/dars, cakupan, akses | Wajib bila tersedia di rilis |
| `/access` | Akses & biaya | Cakupan paket, periode, harga, mekanisme transaksi | Wajib; mengikuti kondisi aktual |
| `/download` | Unduh | Platform, versi, ukuran, panduan, bantuan | Wajib |
| `/releases` | Catatan rilis | Versi aplikasi dan perubahan pengguna | Wajib, minimal rilis yang ditawarkan |
| `/releases/{version}` | Detail rilis | Perubahan, kompatibilitas, masalah diketahui | Template yang sama untuk tiap rilis |
| `/about` | Tentang | Tujuan, pengelola, pekerjaan kurasi, cerita terkonfirmasi | Wajib |
| `/help` | Pusat bantuan | FAQ bertopik dan pencarian artikel | Wajib |
| `/help/{article}` | Artikel bantuan | Langkah pendek, gambar aktual, tanggal, versi | Wajib untuk unduh, akun, akses, rujukan |
| `/contact` | Hubungi pengelola | Saluran nyata, topik pertanyaan, ekspektasi respons | Wajib |
| `/report` | Laporkan masalah | Koreksi sumber, unduhan, akses, masalah teknis | Wajib; kanal terverifikasi |
| `/privacy` | Privasi | Praktik situs dan aplikasi, tujuan, retensi, kontak | Wajib setelah inventaris data |
| `/terms` | Ketentuan | Operator, layanan, akses, transaksi, batas tanggung jawab | Wajib setelah fakta operasional ditetapkan |
| `/sources-and-rights` | Sumber & hak penggunaan | Provenans, lisensi, izin, permintaan koreksi/penghapusan | Wajib |
| `/accessibility` | Aksesibilitas | Sasaran, hasil pengujian nyata, keterbatasan, kontak | Wajib |
| `/account-deletion` | Penghapusan akun | Cara meminta, verifikasi identitas, data dan retensi | Wajib bila aplikasi memiliki akun |
| `/security` | Pelaporan keamanan | Kanal privat dan panduan laporan | Wajib; kontak operasional |
| `/status` | Status layanan | Data pemantauan nyata atau pembaruan manual bertanggal | Bersyarat: hanya jika dikelola |
| `/journal` dan `/journal/{article}` | Catatan editorial | Artikel kurasi atau panduan riset | Sesudah rilis; jangan luncurkan arsip kosong |

Rute sistem: `/robots.txt`, `/sitemap.xml`, favicon, manifest bila diperlukan, halaman 404 lokal, halaman kegagalan sementara, serta berkas asosiasi tautan aplikasi jika deep link telah diimplementasikan. `/` tanpa locale menampilkan pemilih bahasa ringan dan tautan masuk; tidak menjadi penghalang bagi tautan langsung.

Tidak semua halaman masuk menu utama. Kelengkapan berada pada struktur dan keterhubungan halaman, sementara navigasi tetap ringkas.

## 5. Navigasi global

Desktop: wordmark OpenTurath; **Pustaka · Pengujian · Cara kerja · Tentang**; pemilih bahasa; tombol **Unduh aplikasi**. Akses & biaya selalu dapat ditemukan di footer, halaman unduh, dan detail koleksi. Bila transaksi menjadi pertanyaan dominan pengguna, naikkan Akses ke navigasi utama tanpa menambah submenu besar.

Mobile: wordmark, Unduh, tombol Menu. Panel menu berisi empat tautan utama, Akses & biaya, Bantuan, dan pemilih bahasa. Menu memiliki fokus keyboard terkelola, ditutup dengan Escape, dan mengembalikan fokus ke pemicunya. Tombol unduh tidak menutupi teks atau kontrol browser.

Footer:

- Produk: Pustaka, Cara kerja, Tahawwulat, Akses & biaya, Unduh, Catatan rilis.
- Riset: Pengujian, Metode, Koreksi, Sumber & hak penggunaan.
- OpenTurath: Tentang, Bantuan, Kontak.
- Informasi: Privasi, Ketentuan, Penghapusan akun, Aksesibilitas, Keamanan; Status jika aktif.
- Nama pengelola yang sah, tahun berjalan, tagline, bahasa.

Breadcrumb hanya pada halaman bertingkat. Tautan aktif memakai penanda bentuk/garis dan semantik, bukan perbedaan warna saja.

## 6. Beranda dari awal sampai akhir

### 6.1 Pembuka

Tagline, satu H1, deskripsi dua kalimat paling banyak, dua CTA. Pratinjau menggunakan screenshot rilis aktual; kutipan Arab di luar screenshot berupa teks HTML yang dapat disalin. Tidak ada video otomatis, penghitung dramatis, atau layar splash yang menghalangi konten.

### 6.2 Pengalaman membaca

Tiga langkah: memilih bidang, mengajukan pertanyaan, membuka rujukan. Satu visual berubah mengikuti tab, tinggi wadah stabil. Label jelas bahwa ini pratinjau aplikasi. Jika visual adalah konsep yang belum dirilis, jangan menyajikannya sebagai fitur tersedia.

### 6.3 Bukti hasil

Satu pertanyaan asli Q001, ringkasan ruang lingkup, satu cuplikan pendek per produk yang dipilih, tombol jawaban lengkap, dan panel sumber. Beranda tidak memuat keenam jawaban panjang sekaligus. Satu tautan menuju metode dan keterbatasan berada berdekatan dengan hasil.

### 6.4 Pustaka

Kategori editorial yang berasal dari katalog final; empat sampai enam koleksi pilihan. Tiap entri menunjukkan nama, deskripsi satu kalimat, cakupan, dan status akses. Jumlah kitab berasal dari manifes; bila belum tersedia, hilangkan angka tanpa menggantinya dengan estimasi promosi.

### 6.5 Cara sumber disajikan

Contoh tiga lapisan: teks kitab, penjelasan aplikasi, dan metadata rujukan. Pengunjung dapat membuka detail bibliografi. Tidak mengklaim seluruh kutipan dipetakan ke scan bila bukti hanya berupa teks digital.

### 6.6 Tahawwulat

Satu bidang obsidian dengan tipografi terang. Judul Arab dan ringkasan lokal. Tampilkan sumber kitab dan dars secara berbeda; rekaman memiliki judul, penutur, tanggal jika diketahui, serta penanda waktu. Jumlah dan hak penggunaan mengikuti inventaris.

### 6.7 Akses

Ringkasan apa yang dapat dibaca publik di situs dan bagaimana akses aplikasi diperoleh. Harga hanya berasal dari katalog komersial yang disahkan. Jika layanan berbayar, tautan Akses & biaya tidak disembunyikan di FAQ.

### 6.8 FAQ singkat dan unduh

Maksimal lima pertanyaan paling penting: kegunaan, rujukan, platform, biaya, dan bantuan. Jawaban lengkap berada di bantuan. Tutup dengan CTA unduh dan metadata rilis. Footer menjadi akhir halaman; tidak ada popup keluar atau permintaan email paksa.

## 7. Naskah inti tiga bahasa

Naskah berikut siap menjadi dasar implementasi. Pernyataan kemampuan tetap harus lolos pemeriksaan kesesuaian dengan rilis aplikasi.

### 7.1 Beranda

| Elemen | Indonesia | English | العربية |
|---|---|---|---|
| Tagline | AI For Islamic Scholarship. | AI For Islamic Scholarship. | AI For Islamic Scholarship. |
| H1 | Kembali kepada kitab. | Return to the sources. | عُد إلى المصادر. |
| Pengantar | OpenTurath membantu Anda menelusuri pembahasan dalam kitab-kitab Islam. Baca ibarahnya, ikuti rujukannya, dan lanjutkan telaah Anda. | OpenTurath helps you explore questions across Islamic texts. Read the passages, follow the references, and take your research further. | يعينك OpenTurath على البحث في كتب التراث الإسلامي. اقرأ نصوصها، وتتبع إحالاتها، وواصل النظر في مسائلها. |
| CTA utama | Unduh aplikasi | Download the app | تنزيل التطبيق |
| CTA kedua | Lihat hasil pengujian | Examine the results | اطّلع على نتائج الاختبار |
| Pratinjau—judul | Dari pertanyaan menuju rujukan. | From question to source. | من السؤال إلى المصدر. |
| Pratinjau—isi | Pilih bidang kajian, ajukan pertanyaan, lalu buka rujukan yang menyertai jawaban. | Choose a field, ask a question, then open the references accompanying the answer. | اختر مجال البحث، واطرح سؤالك، ثم افتح الإحالات الواردة مع الإجابة. |
| Label pratinjau | Pratinjau aplikasi | App preview | لمحة عن التطبيق |
| Perbandingan—judul | Pertanyaan yang sama. Periksa hasilnya. | The same question. Examine the answers. | السؤال واحد. تأمّل الإجابات. |
| Perbandingan—isi | Baca jawaban lengkap dan catatan pemeriksaannya. Cocokkan kutipan dan rujukan dengan sumber yang disertakan. | Read the complete answers and review notes. Check quotations and references against the accompanying sources. | اقرأ الإجابات كاملة وملاحظات مراجعتها، وقابل النصوص والإحالات بالمصادر المرفقة. |
| Pustaka—judul | Temukan bidang kajian Anda. | Find your field of study. | اختر مجال دراستك. |
| Pustaka—isi | Kenali isi setiap koleksi sebelum memulai telaah. | Explore what each collection contains before you begin. | تعرّف إلى محتوى كل مجموعة قبل أن تبدأ البحث. |
| Sumber—judul | Baca ibarahnya. Periksa rujukannya. | Read the passage. Check the reference. | اقرأ العبارة، وتحقّق من مرجعها. |
| Sumber—isi | Bedakan teks kitab dari penjelasan aplikasi. Buka keterangan kitab dan edisi untuk menelaah kutipan dalam konteksnya. | Distinguish the source text from the app’s explanation. Open the book and edition details to examine the passage in context. | ميّز نص الكتاب من شرح التطبيق، وافتح بيانات الكتاب والطبعة للنظر في النص ضمن سياقه. |
| Tahawwulat—judul | Fikih Tahawwulat | Fiqh al-Tahawwulat | فقه التحولات |
| Tahawwulat—isi | Telaah karya dan pelajaran Habib Abu Bakar al-Adni al-Masyhur dalam koleksi khusus Fikih Tahawwulat. | Explore the works and lessons of Habib Abu Bakr al-Adani al-Mashhur in a dedicated Fiqh al-Tahawwulat collection. | طالع مؤلفات الحبيب أبي بكر العدني المشهور ودروسه في مجموعة خاصة بفقه التحولات. |
| Akses—judul | Ketahui cakupan akses Anda. | Know what your access includes. | تعرّف إلى ما يشمله اشتراكك. |
| Akses—isi | Periksa koleksi yang tersedia, masa akses, dan biaya sebelum memilih. | Review the available collections, access period, and price before choosing. | راجع المجموعات المتاحة ومدة الإتاحة والتكلفة قبل الاختيار. |
| Unduh—judul | Lanjutkan telaah di OpenTurath. | Continue your research in OpenTurath. | واصل بحثك في OpenTurath. |
| Unduh—isi | Pilih versi yang sesuai dengan perangkat Anda. | Choose the version for your device. | اختر الإصدار المناسب لجهازك. |

### 7.2 Judul halaman dan navigasi

| Indonesia | English | العربية |
|---|---|---|
| Pustaka | Library | المكتبة |
| Pengujian & sumber | Evaluation & Sources | الاختبارات والمصادر |
| Cara kerja | How It Works | طريقة الاستخدام |
| Tentang OpenTurath | About OpenTurath | عن OpenTurath |
| Akses & biaya | Access & Pricing | الإتاحة والأسعار |
| Unduh OpenTurath | Download OpenTurath | تنزيل OpenTurath |
| Catatan rilis | Release Notes | سجل الإصدارات |
| Bantuan | Help | المساعدة |
| Hubungi pengelola | Contact | تواصل معنا |
| Laporkan masalah | Report an Issue | أبلغ عن مشكلة |
| Metode pengujian | Evaluation Methodology | منهجية الاختبار |
| Catatan koreksi | Corrections | سجل التصحيحات |
| Sumber & hak penggunaan | Sources & Usage Rights | المصادر وحقوق الاستخدام |
| Privasi | Privacy | الخصوصية |
| Ketentuan penggunaan | Terms of Use | شروط الاستخدام |
| Penghapusan akun | Account Deletion | حذف الحساب |
| Aksesibilitas | Accessibility | إمكانية الوصول |
| Pelaporan keamanan | Security Reporting | الإبلاغ عن الثغرات الأمنية |

### 7.3 Pengantar halaman pendukung

| Halaman | Indonesia | English | العربية |
|---|---|---|---|
| Pustaka | Telusuri koleksi menurut bidang ilmu. Buka setiap koleksi untuk melihat kitab, cakupan, dan keterangan aksesnya. | Browse collections by field. Open a collection to see its books, scope, and access details. | تصفّح المجموعات بحسب العلوم، وافتح كل مجموعة للاطّلاع على كتبها ونطاقها وبيانات إتاحتها. |
| Metode | Setiap hasil dibaca bersama pertanyaan, kondisi pengujian, dan sumber pemeriksaannya. Halaman ini menjelaskan cara penilaian dilakukan. | Each result is presented with its question, test conditions, and verification sources. This page explains how the assessment is conducted. | تُعرض كل نتيجة مع سؤالها وظروف اختبارها ومصادر التحقّق منها. وتبيّن هذه الصفحة طريقة التقييم. |
| Tentang | OpenTurath dikembangkan untuk membantu pembaca menelusuri khazanah keilmuan Islam dan kembali kepada kitab yang dirujuk. Pekerjaan kami berpusat pada penyajian teks, keterangan sumber, dan kemudahan telaah. | OpenTurath is being developed to help readers explore Islamic scholarship and return to the books it draws on. Our work centres on presenting texts, documenting sources, and supporting close reading. | يُطوَّر OpenTurath لإعانة القرّاء على البحث في التراث الإسلامي والرجوع إلى الكتب التي يستند إليها. وينصبّ عملنا على عرض النصوص، وتوثيق مصادرها، وتيسير دراستها. |
| Bantuan | Temukan panduan pemasangan, akses koleksi, dan pemeriksaan rujukan. | Find guidance on installation, collection access, and checking references. | اطّلع على إرشادات التثبيت، والوصول إلى المجموعات، والتحقّق من الإحالات. |
| Kontak | Sampaikan pertanyaan tentang aplikasi atau koleksi. Untuk koreksi kutipan, sertakan kitab, edisi, dan halaman bila tersedia. | Send a question about the app or its collections. For a quotation correction, include the book, edition, and page where available. | أرسل سؤالك عن التطبيق أو مجموعاته. ولتصحيح نص منقول، أرفق اسم الكتاب والطبعة والصفحة إن توفرت. |
| Koreksi | Koreksi yang diterbitkan mencantumkan bagian yang berubah, alasan perubahan, dan tanggal pembaruan. | Published corrections record what changed, why it changed, and when it was updated. | تبيّن التصحيحات المنشورة موضع التعديل وسببه وتاريخ تحديثه. |

### 7.4 FAQ inti

| Pertanyaan | Indonesia | English | العربية |
|---|---|---|---|
| Apa kegunaannya? | OpenTurath membantu penelusuran teks dan rujukan dalam koleksi yang tersedia. Periksa sumber yang menyertai jawaban sebagai bagian dari telaah Anda. | OpenTurath supports research into texts and references within its available collections. Check the sources accompanying an answer as part of your research. | يعين OpenTurath على البحث في نصوص المجموعات المتاحة وإحالاتها. وراجع المصادر المرفقة بالإجابة في أثناء دراستك. |
| Apakah jawabannya selalu benar? | Jawaban dapat mengandung kekeliruan. Kutipan, rujukan, dan penjelasan perlu diperiksa secara terpisah. Halaman pengujian memperlihatkan hasil pemeriksaan pada contoh yang diterbitkan. | Answers can contain errors. Quotations, references, and explanations require separate checks. The evaluation pages show the findings for the published examples. | قد يقع الخطأ في الإجابة؛ لذا تُراجع النصوص والإحالات والشروح كلٌّ على حدة. وتعرض صفحات الاختبار نتائج مراجعة النماذج المنشورة. |
| Apakah ini layanan fatwa? | OpenTurath adalah alat bantu riset. Untuk penetapan hukum atas keadaan pribadi, rujuk kepada ulama atau lembaga fatwa yang berkompeten. | OpenTurath is a research aid. For a ruling on personal circumstances, consult a qualified scholar or fatwa institution. | OpenTurath أداة مساعدة للبحث. أمّا تنزيل الحكم على حالتك الخاصة، فمرجعه إلى أهل العلم أو جهات الإفتاء المختصة. |
| Dapat digunakan lewat situs ini? | Situs ini memuat informasi produk, katalog, dan contoh pengujian. Unduh aplikasi untuk menggunakan ruang kajian OpenTurath. | This site provides product information, the catalogue, and evaluation examples. Download the app to use OpenTurath’s research workspace. | يضمّ هذا الموقع معلومات المنتج والفهرس ونماذج الاختبار. نزّل التطبيق لاستخدام مساحة البحث في OpenTurath. |
| Bagaimana mengetahui biayanya? | Lihat halaman Akses & biaya untuk cakupan koleksi, masa akses, dan harga yang berlaku. | See Access & Pricing for collection coverage, access periods, and current prices. | راجع صفحة الإتاحة والأسعار لمعرفة المجموعات المشمولة ومدد الإتاحة والأسعار المعتمدة. |

Pertanyaan platform, kebutuhan internet, penyimpanan catatan, dan pemulihan akun diisi dari perilaku rilis aktual; jangan menggunakan jawaban generik yang belum diuji.

## 8. Pustaka dan bibliografi

Pencarian publik hanya mencari metadata katalog yang diterbitkan: judul, pengarang, kategori, dan deskripsi. Jangan menyebutnya pencarian teks penuh jika tidak mengindeks isi kitab. Label input: “Cari judul atau pengarang” / “Search titles or authors” / “ابحث باسم الكتاب أو المؤلف”.

Filter: bidang ilmu, mazhab bila relevan, jenis sumber, dan ketersediaan akses. Filter terpilih tersimpan dalam URL. Tombol hapus filter selalu tersedia. Pencarian Arab boleh menormalkan harakat dan tatweel pada indeks; teks asli untuk tampilan tetap utuh. Uji pencarian judul dengan variasi hamzah dan transliterasi sebelum menetapkan aturan perluasan hasil.

Detail koleksi: nama ID/EN/AR, disiplin, ringkasan, daftar karya tersedia, batas cakupan, status rilis, paket akses terkait, pembaruan data terakhir, dan CTA menuju unduh dengan konteks koleksi. Angka karya unik, edisi, jilid, halaman, rekaman, dan kata adalah metrik terpisah.

Detail kitab: judul Arab, judul transliterasi bila digunakan, pengarang dan identitasnya, tahun wafat jika terverifikasi, editor/tahqiq, penerbit, tempat, tahun/cetakan, jumlah jilid, sumber digital, versi rekam, hak penggunaan, dan tautan bukti. Kolom yang tidak diketahui ditandai “Belum tersedia”; jangan diisi perkiraan.

Sumber rekaman: pembicara, judul seri, episode, asal berkas, rentang waktu, jenis transkrip, status koreksi transkrip, dan izin penggunaan. Penanda menit tidak diperlakukan sebagai nomor halaman.

## 9. Pengujian dan perbandingan nyata

### 9.1 Q001

Pertanyaan yang disimpan verbatim:

> Bagaimana mazhab Syafi'i menjelaskan hukum bersentuhan kulit antara laki-laki dan perempuan non-mahram dalam kaitannya dengan wudhu? Jelaskan batasan dan pengecualiannya.

Produk yang muncul dalam bahan: OpenTurath, Qaf AI, Wisqu AI, Nur AI, AI Fiqh, Usul.ai. Nama versi/model, tanggal uji, paket, akses sumber, dan konfigurasi yang tidak tercatat diberi status “Tidak tercatat”. Jangan menebaknya dari branding produk saat ini.

Penyajian Q001 sebagai arsip historis boleh menyatakan keterbatasan metadata secara terbuka. Skor perbandingan terkontrol membutuhkan protokol dan metadata memadai. Jika arsip belum cukup untuk menyimpulkan keunggulan, tampilkan jawaban dan status pemeriksaannya tanpa skor juara.

### 9.2 Anatomi halaman kasus

1. ID kasus, topik, tanggal pengujian jika diketahui, versi laporan, status telaah.
2. Pertanyaan asli dan kondisi pengujian.
3. Pemilih produk; desktop dua jawaban sejajar, mobile tab; semua jawaban dapat diakses tanpa carousel otomatis.
4. Jawaban asli lengkap, unduh transkrip bila haknya memungkinkan, dan tautan sumber percakapan yang memang dapat dibuka publik.
5. Daftar klaim dan kutipan bernomor; klik menyorot bagian terkait tanpa memotong konteks.
6. Panel bukti: teks sumber, metadata edisi, halaman cetak, nomor halaman PDF terpisah, tautan/faksimili yang boleh ditampilkan.
7. Hasil per dimensi, alasan penilaian, nama/peran penelaah jika disetujui, tanggal pemeriksaan.
8. Keterbatasan, konflik penilaian, catatan koreksi, dan tautan melaporkan masalah.

Jawaban asli tidak diperbaiki diam-diam. Jawaban baru setelah perubahan engine adalah run baru. Terjemahan jawaban tidak masuk penilaian sebagai keluaran asli model. Materi pribadi dalam ekspor disamarkan dengan catatan perubahan.

### 9.3 Dimensi yang dipisahkan

| Dimensi | Unit dan cara penilaian | Hal yang tidak boleh disimpulkan |
|---|---|---|
| Kecocokan kutipan | Setiap kutipan dibandingkan dengan teks rujukan; aturan normalisasi dicatat | Kutipan cocok tidak otomatis membenarkan penjelasan |
| Ketepatan bibliografi | Judul, pengarang, edisi, jilid, halaman diperiksa per rujukan | Metadata Syamilah tidak otomatis membuktikan halaman scan |
| Dukungan terhadap klaim | Setiap klaim substantif ditautkan ke bagian sumber yang mendukungnya | Banyak sitasi tidak otomatis berarti klaim didukung |
| Ketepatan pemahaman | Penelaah bidang ilmu menilai makna, nisbah, dan batas kesimpulan | Panjang jawaban bukan skor kedalaman |
| Kelengkapan | Checklist aspek pertanyaan yang ditetapkan sebelum menilai | Pembahasan tambahan tidak selalu menambah nilai |
| Kesesuaian cakupan | Mazhab, topik, dan bentuk pertanyaan dipatuhi | Koleksi terpisah tidak menjamin nol kesalahan model |
| Ketahanan | Premis salah, sumber tidak ada, pertanyaan ambigu, permintaan di luar korpus | Lulus satu soal tidak mewakili semua kondisi |

Status pemeriksaan: cocok, cocok sebagian, tidak cocok, belum diperiksa, atau tidak dapat diperiksa dari bukti tersedia. Catatan alasan wajib untuk setiap status selain cocok; kecocokan tetap menyertakan sumber.

Jika rasio ditampilkan, tampilkan penyebut: jumlah cocok / jumlah yang diperiksa, serta jumlah total dan yang belum diperiksa. Untuk kumpulan pertanyaan, laporkan juga cakupan klaim bersumber dan kegagalan mengambil sumber, agar jawaban tanpa kutipan tidak tampak unggul akibat penyebut nol. Penyebut nol tampil “Tidak dapat dihitung”. Tidak membuat skor gabungan tanpa bobot dan metode yang diterbitkan.

### 9.4 Aturan klaim publik

- “10 dari 10 kutipan yang diperiksa cocok dengan teks rujukan digital pada kasus Q001” hanya setelah tersedia sepuluh catatan pemeriksaan yang mendukungnya.
- Klaim ini tidak sama dengan “akurasi OpenTurath 100%”.
- “Cocok dengan edisi cetak” membutuhkan pemeriksaan terhadap edisi yang diidentifikasi, bukan sekadar nama penerbit.
- Status penelaah AI, internal manusia, dan independen manusia dibedakan.
- Keunggulan produk pembanding dibatasi pada kasus, versi, dan kondisi uji yang dipublikasikan.
- Cuplikan dipilih berdasarkan pertanyaan riset, bukan untuk menghilangkan bagian benar dari pembanding atau bagian salah dari OpenTurath.
- Hak penayangan transkrip, logo, dan scan diperiksa; bila publikasi ulang tidak diizinkan, gunakan cuplikan yang sesuai izin dan tautan sumber.

### 9.5 Protokol lanjutan yang disarankan

Mulai dengan pilot 30 pertanyaan: enam kategori, masing-masing lima soal—pelacakan teks; nisbah dan bibliografi; perincian mazhab; premis salah; sumber tidak ditemukan; pertanyaan ambigu. Ini rancangan pilot, bukan jumlah yang telah diuji.

Tetapkan pertanyaan, kriteria, dan kondisi sebelum run. Catat apakah yang dibandingkan kemampuan produk dengan sumber bawaan atau kemampuan dengan sumber identik; keduanya eksperimen berbeda. Simpan kegagalan, pengulangan, dan alasan pengulangan. Gunakan dua penelaah bidang ilmu jika tersedia, dengan penyelesaian perbedaan tercatat. Jika hanya satu penelaah, nyatakan. Pilot lintas topik tidak cukup untuk klaim universal; perluasan mengikuti hasil dan kebutuhan pengguna.

## 10. Alur unduhan dan akses

### 10.1 Halaman unduh

Tombol utama global menuju halaman unduh, bukan langsung mengunduh berkas besar. Halaman mendeteksi perangkat sebagai saran; pilihan platform lain tetap terlihat. Tidak ada unduhan otomatis.

Untuk setiap platform yang benar-benar tersedia: nama, nomor versi, tanggal rilis, persyaratan OS, ukuran jika berkas langsung, tautan resmi, catatan rilis, dan panduan pemasangan. Tautan store hanya tampil bila listing resmi aktif. Platform yang belum tersedia mendapat keterangan faktual tanpa tanggal janji yang belum ditetapkan.

Jika Android didistribusikan sebagai APK: gunakan artefak release bertanda tangan; tampilkan versi, ukuran, checksum SHA-256, asal unduhan, dan langkah pemasangan yang tidak menyuruh pengguna mematikan perlindungan perangkat secara umum. Hash harus dihitung dari berkas rilis sebenarnya. Menaruh hash di halaman saja tidak menggantikan tanda tangan paket atau keamanan kanal distribusi.

Desktop: QR menuju URL kanonikal halaman unduh dan tautan biasa di bawahnya. QR tidak mengandung token privat. Perangkat tidak didukung: beri pilihan platform tersedia dan bantuan.

### 10.2 Setelah klik

Pesan hanya menyatakan tautan dibuka atau unduhan diminta. Browser tidak selalu memberi bukti unduhan selesai. Jangan menampilkan “Aplikasi berhasil dipasang” berdasarkan klik.

Kegagalan tautan: tombol coba lagi, tautan alternatif resmi jika memang tersedia, serta panduan. File lama tetap dipisahkan dari rilis aktif; rilis yang dicabut tidak muncul sebagai pilihan yang direkomendasikan.

### 10.3 Akses dan pembayaran

Tiap paket: cakupan koleksi, durasi, mata uang, total harga, pajak/biaya bila berlaku, apakah diperpanjang otomatis, cara berhenti, ketentuan pengembalian yang benar-benar dioperasikan, serta tempat transaksi berlangsung. Tidak membuat diskon atau harga coret tanpa dasar.

Jika akses gratis dan berbayar berdampingan, jelaskan batas masing-masing. Jika Tahawwulat terpisah, jangan menampilkan seolah termasuk akses umum. Situs tidak menentukan entitlement akun dari parameter URL.

### 10.4 Tautan ke aplikasi

Tautan koleksi menggunakan ID stabil. Universal Link/App Link hanya dijanjikan setelah konfigurasi domain dan aplikasi diuji. Fallback selalu membuka detail koleksi di situs dan menawarkan unduh. Menjaga konteks otomatis setelah pemasangan baru memerlukan implementasi tersendiri; jangan menjanjikannya sebelum terbukti.

## 11. Sistem visual dan interaksi

| Komponen | Spesifikasi |
|---|---|
| Kanvas | Warm paper `#F6F6F3`; bidang putih `#FFFFFF` |
| Tinta | `#171717`; teks sekunder awal `#555550`, diuji pada semua bidang |
| Bagian gelap | `#111110`; teks terang `#F6F6F3` |
| Border | `#DADAD4` untuk pemisah dekoratif; batas kontrol interaktif harus memenuhi kontras yang diperlukan |
| Font Latin UI | Inter lokal |
| Tajuk Latin | Cormorant; ketebalan yang tetap terbaca pada mobile |
| Arab | Amiri lokal untuk isi Arab dan judul; fallback yang sesuai |
| Lebar | Shell maksimum 1200 px; artikel 680–720 px; margin mobile 20–24 px |
| Ukuran | Isi Latin 16–18 px; isi Arab 20–24 px; H1 responsif sekitar 44–88 px, diuji tanpa pemotongan |
| Tinggi baris | Latin sekitar 1,5–1,7 untuk isi panjang; Arab sekitar 1,8–2,1, diuji dengan harakat |
| Ruang | Skala 4, 8, 12, 16, 24, 32, 48, 64, 96 px |
| Tombol | Target sentuh desain minimal 48 × 48 CSS px; tidak semua tautan teks harus berupa tombol |
| Bentuk | Radius 10–16 px seperlunya; tidak membungkus setiap paragraf sebagai kartu |
| Ikon | Satu keluarga outline; label pada tindakan yang tidak jelas dari ikon |

Bentuk identitas sementara adalah wordmark OpenTurath. Jangan memakai logo konsep yang sebelumnya ditolak sebagai logo final. Tidak menambahkan pola geometris, masjid, lentera, atau kaligrafi dekoratif hanya agar terlihat Islami. Naskah dan bibliografi menjadi elemen visual utama.

Animasi:

- Hover/focus: perubahan warna atau garis 120–160 ms.
- Tekan tombol: skala sekitar 0,985 selama 100–160 ms jika reduced motion tidak aktif.
- Panel rujukan: 180–240 ms, fokus berpindah dan kembali dengan benar.
- Perubahan tab: opasitas 120–180 ms; tidak mengubah posisi baca secara tiba-tiba.
- Kemunculan bagian: opsional, satu kali, pergeseran maksimal 8–12 px. Konten tetap terlihat jika JavaScript gagal.
- Reduced motion: hilangkan perpindahan dan skala; gunakan perubahan langsung atau opasitas singkat.

Tidak ada scroll hijacking, parallax berat, audio otomatis, kursor kustom, huruf per huruf untuk naskah Arab, atau haptik web yang diasumsikan bekerja di semua perangkat.

## 12. Bahasa, RTL, dan aksesibilitas

Bahasa disimpan sebagai preferensi lokal, tetapi URL adalah sumber utama bahasa halaman. Tautan `/ar/research/q001` selalu membuka Arab walaupun preferensi sebelumnya Indonesia. Pengalih bahasa mempertahankan ID konten, filter yang relevan, dan anchor semantik. Tidak mengembalikan pengguna ke beranda tanpa alasan.

`html lang` dan `dir` ditetapkan saat render awal. Gunakan properti logis CSS: inline/block, margin-inline, padding-inline, inset-inline. Urutan DOM mengikuti urutan baca; jangan membaliknya dengan CSS sehingga urutan fokus berbeda dari visual.

Arab sumber selalu `lang=ar`, `dir=rtl`; angka versi, URL, hash, email, dan nama Latin diisolasi dengan `bdi` atau arah lokal yang sesuai. Panah navigasi dibalik; logo, ikon unduh, jam, pencarian, gambar perangkat, dan screenshot tidak dicerminkan. Tidak memberi letter-spacing pada huruf Arab.

Pilih gaya angka konsisten per locale. ID dan EN memakai angka Latin; AR dapat memakai angka Arab Timur pada tampilan umum, tetapi versi aplikasi, checksum, dan URL tetap utuh. Tanggal teknis rilis memakai tanggal Gregorian yang jelas; kalender Hijriah bersifat tambahan dan harus menyebut metode/otoritas konversi bila ditampilkan.

Target aksesibilitas produk: WCAG 2.2 AA. Ukuran target produk 48 px adalah keputusan desain; minimum WCAG 2.2 AA untuk target memiliki ketentuan 24 px dan pengecualian tertentu, bukan syarat universal 48 px. Acuan: [W3C Target Size Minimum](https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html).

Periksa skip link, landmark, urutan heading, fokus terlihat, keyboard lengkap, pembaca layar, teks alternatif, kontrol form berlabel, status `aria-live` seperlunya, zoom 200%, reflow pada 320 CSS px, kontras, dan orientasi perangkat. Dialog memiliki nama, fokus terkelola, Escape, dan pengembalian fokus. Kontras teks normal ditargetkan minimal 4,5:1, teks besar 3:1, serta elemen kontrol esensial 3:1. Klaim kepatuhan hanya dibuat setelah audit nyata.

## 13. Microcopy dan keadaan antarmuka

| Keadaan | Indonesia | English | العربية |
|---|---|---|---|
| Membuka rujukan | Buka rujukan | Open reference | افتح المرجع |
| Jawaban asli | Jawaban asli | Original answer | الإجابة الأصلية |
| Terjemahan | Terjemahan untuk membantu pembacaan | Translation for reference | ترجمة للاستعانة بها |
| Bukti digital | Cocok dengan sumber digital | Matches the digital source | مطابق للمصدر الرقمي |
| Bukti cetak | Cocok dengan edisi cetak yang diperiksa | Matches the checked print edition | مطابق للطبعة المطبوعة التي روجعت |
| Belum diperiksa | Belum diperiksa | Not yet reviewed | لم يُراجع بعد |
| Tidak tercatat | Tidak tercatat | Not recorded | غير مسجّل |
| Cari kosong | Tidak ada hasil untuk pencarian ini. Ubah kata kunci atau hapus filter. | No results for this search. Try another term or clear the filters. | لا نتائج لهذا البحث. جرّب عبارة أخرى أو أزل المرشّحات. |
| Kosong koreksi | Belum ada koreksi yang diterbitkan. | No corrections have been published. | لم تُنشر تصحيحات بعد. |
| Muat gagal | Bagian ini belum dapat dimuat. Coba kembali. | This section could not be loaded. Try again. | تعذّر تحميل هذا القسم. حاول مرة أخرى. |
| Clipboard sukses | Teks dan rujukan disalin. | Text and reference copied. | نُسخ النص ومرجعه. |
| Clipboard gagal | Teks belum tersalin. Pilih teks untuk menyalinnya secara manual. | Copying failed. Select the text to copy it manually. | تعذّر النسخ. حدّد النص لنسخه يدويًّا. |
| File tak tersedia | Berkas unduhan belum tersedia. Lihat panduan atau hubungi pengelola. | The download is not available. See the guide or contact support. | ملف التنزيل غير متاح. راجع الدليل أو تواصل مع الدعم. |
| 404 | Halaman ini tidak ditemukan. | This page could not be found. | لم يُعثر على هذه الصفحة. |
| Kembali | Kembali ke beranda | Return to the home page | العودة إلى الصفحة الرئيسية |
| Form terkirim | Laporan Anda telah diterima. | Your report has been received. | تم استلام بلاغك. |
| Form gagal | Laporan belum terkirim. Coba kembali atau gunakan saluran kontak yang tersedia. | Your report was not sent. Try again or use the listed contact channel. | لم يُرسل البلاغ. حاول مرة أخرى أو استخدم وسيلة التواصل المبيّنة. |
| Terlalu sering | Terlalu banyak permintaan. Tunggu sebentar, lalu coba kembali. | Too many requests. Please wait, then try again. | أُرسلت طلبات كثيرة. انتظر قليلًا ثم حاول مرة أخرى. |
| Tautan eksternal | Buka sumber di situs penerbit | Open the source on the publisher’s site | افتح المصدر في موقع الناشر |

Form baru menyatakan diterima setelah server menyimpan laporan. Jika hanya membuka aplikasi email, teksnya “Buka aplikasi email”, bukan “Laporan diterima”. Jika clipboard hanya berisi teks karena metadata tidak tersedia, pesan sukses tidak boleh menyebut rujukan ikut disalin.

Semua komponen memiliki keadaan awal, loading bila benar-benar asinkron, berhasil, kosong, gagal, dan disabled bila relevan. Halaman statis tidak diberi skeleton palsu. Label loading tidak menggantikan konten yang sudah tersedia.

## 14. Arsitektur teknis dan data

Pendekatan: halaman publik diprarender atau dirender server agar isi terbaca segera; JavaScript hanya untuk pencarian katalog, filter, panel sumber, menu, dan preferensi. Pilihan framework dan hosting ditetapkan saat implementasi berdasarkan lingkungan proyek; spesifikasi ini tidak mewajibkan layanan berbayar atau membuat migrasi backend aplikasi.

Unit terpisah: shell situs, kamus bahasa, katalog, pengujian, rilis/unduhan, bantuan, formulir, serta aturan publikasi. Tidak membutuhkan akses langsung ke data pengguna aplikasi untuk merender halaman publik.

| Model konten | Data pokok |
|---|---|
| SiteSettings | Brand, tagline, domain kanonikal, identitas pengelola, kontak, locale |
| Collection | ID, judul lokal, bidang, ringkasan, buku terkait, akses, status rilis |
| Work | ID karya unik, judul Arab, pengarang, bidang |
| Edition | ID edisi, karya induk, editor, penerbit, tahun, jilid, sumber digital |
| SourceAsset | Jenis teks/scan/audio/video, locator, asal, hak penggunaan, checksum bila berkas |
| EvaluationCase | ID, prompt asli, topik, protokol, status, tanggal dan versi |
| EvaluationRun | Kasus, produk, model jika diketahui, konfigurasi, waktu, keluaran asli, hash arsip |
| EvidenceRecord | Run, rentang klaim/kutipan, sumber, locator, hasil pemeriksaan, penelaah |
| Review | Kasus/run, dimensi, hasil, alasan, konflik, identitas/peran penelaah |
| Claim | Teks klaim publik, cakupan, bukti, pemilik, tanggal telaah, status publikasi |
| Release | Platform, versi, tanggal, OS minimum, URL, checksum, catatan, status dicabut |
| AccessPlan | Cakupan, periode, harga, mata uang, pembaruan, ketentuan, status |
| Article | ID, tipe bantuan/tentang/metode, terjemahan, pemilik, tanggal telaah |
| Correction | Objek dan versi lama/baru, ringkasan, alasan, tanggal |
| Asset | File, dimensi, alt per bahasa, kredit, izin, fungsi |
| Report | ID privat, topik, kontak opsional sesuai alur, isi, status, retensi |

Relasi inti: karya mempunyai beberapa edisi; koleksi merujuk karya/edisi; satu kasus mempunyai beberapa run; tiap run mempunyai banyak bukti; klaim publik merujuk bukti yang spesifik. ID produk bukan nama model. ID karya bukan ID edisi. Jumlah kitab unik dihitung dari karya, bukan penjumlahan semua edisi.

Satu sumber data menghasilkan angka katalog, detail halaman, naskah lokal, dan metadata. Tidak menyalin angka manual ke tiga kamus bahasa.

Alur konten: draft → periksa fakta → telaah bahasa ID/EN/AR → preview → terbit → arsip/koreksi. Peran pengelola, editor, penelaah, dan penerbit dapat dipegang orang yang sama pada tim kecil, tetapi langkah dan hasilnya tetap dicatat. Jangan menyebut penelaahan internal sebagai independen.

CMS v1 dapat berbasis berkas terstruktur berversi. Jika editor nonteknis membutuhkan antarmuka, gunakan CMS terautentikasi; jangan menambah panel admin publik yang belum diperlukan. Preview privat tidak terindeks. Perubahan publik mempunyai riwayat dan dapat dikembalikan.

Aturan validasi sebelum build/publish:

- Semua kunci bahasa wajib lengkap; tidak ada fallback diam-diam ke Indonesia di halaman Arab.
- Slug dan ID unik; semua relasi buku, sumber, kasus, dan rilis valid.
- CTA wajib mempunyai tujuan nyata; tautan `#` kosong ditolak.
- Rilis aktif wajib memiliki URL resmi yang lolos pemeriksaan dan metadata kompatibilitas.
- Klaim numerik wajib mempunyai bukti dan definisi metrik.
- Gambar wajib mempunyai alt atau penanda dekoratif; sumber wajib mempunyai status hak penggunaan.
- Konten internal dan catatan pemeriksa privat tidak masuk bundle publik.

## 15. SEO, performa, dan distribusi

Setiap bahasa memiliki URL sendiri, title dan description alami, satu H1 yang jelas, canonical ke versi bahasa itu sendiri, dan `hreflang` timbal balik untuk versi yang tersedia. Root pemilih bahasa menjadi `x-default`. Gunakan anotasi HTML sebagai implementasi utama agar pemetaan mudah dipelihara. Acuan: [Google: localized versions](https://developers.google.com/search/docs/specialty/international/localized-versions).

Sitemap hanya memuat halaman kanonikal terbit dengan respons 200. Pencarian internal dan kombinasi filter tidak dibuat sebagai ribuan halaman indeks. Halaman detail koleksi bernilai dapat diindeks. Halaman dihapus mempunyai keputusan eksplisit: 301 bila ada pengganti setara; 404/410 bila tidak ada. Jangan mengarahkan semua halaman hilang ke beranda.

Metadata sosial: nama, judul lokal, deskripsi, gambar yang sesuai bahasa, dan URL kanonikal. Structured data hanya berdasarkan konten nyata: Organization setelah operator terkonfirmasi, SoftwareApplication setelah platform/rilis jelas, BreadcrumbList untuk halaman bertingkat, Article untuk tulisan. Tidak membuat rating, review, jumlah pengguna, atau badge verifikasi palsu.

Target pengalaman lapangan: LCP ≤ 2,5 detik, INP ≤ 200 ms, CLS ≤ 0,1 pada persentil ke-75, dipisahkan menurut perangkat. Ini target, bukan hasil pengukuran saat ini. Situs baru memakai pemeriksaan lab sebagai awal lalu pengukuran lapangan ketika data tersedia. Acuan: [Web Vitals](https://web.dev/articles/vitals).

Anggaran internal awal: JavaScript awal beranda maksimal sekitar 150 KB terkompresi; gambar utama sekitar 250 KB atau kurang bila mutu memungkinkan; font hanya bobot dan bahasa yang diperlukan. Anggaran dievaluasi terhadap visual nyata, bukan menjadi angka pencapaian pemasaran.

Font WOFF2 lokal berlisensi, dimensi gambar eksplisit, AVIF/WebP dengan fallback, lazy-load bagian bawah, caching aset bernama hash. Jangan lazy-load gambar LCP utama. Halaman unduh/rilis memiliki kebijakan cache yang memungkinkan pencabutan rilis bermasalah segera. Dukung koneksi lambat; konten pokok dan tautan tetap berguna tanpa JavaScript.

## 16. Privasi, hak, keamanan, dan formulir

Inventaris data membedakan situs dan aplikasi. Situs publik tidak otomatis mengunggah catatan riset atau mengambil data akun aplikasi. Kebijakan menjelaskan data yang benar-benar diterima: log akses, laporan, preferensi bahasa, dan analitik jika dipasang; beserta tujuan, penerima, retensi, penghapusan, dan kontak operator.

Dokumen privasi dan ketentuan final membutuhkan identitas operator, yurisdiksi yang relevan, penyedia layanan, praktik retensi, dan skema transaksi. Dokumen ini menetapkan isi yang diperlukan; tidak mengarang teks hukum seolah telah disahkan. Persyaratan hukum setempat diperiksa terhadap yurisdiksi nyata saat fakta operator tersedia.

Pilihan awal: analitik agregat minimal tanpa iklan, profiling, perekaman sesi, atau pengumpulan isi pertanyaan. Penggunaan cookie/persetujuan mengikuti teknologi yang benar-benar dipasang dan ketentuan yang berlaku; tidak menampilkan tombol persetujuan yang tidak mengendalikan apa pun.

Form laporan minimal: topik, halaman/kasus terkait, uraian, email bila balasan diperlukan, dan persetujuan penggunaan data untuk menindaklanjuti. Kirim hanya saat pengguna menekan kirim. Jangan meminta kata sandi, token, nomor identitas, atau isi catatan privat. Lampiran tidak diperlukan pada v1; jika ditambahkan, batasi tipe/ukuran dan isolasi penyimpanannya.

Form memiliki validasi server, batas ukuran, rate limit, perlindungan spam, penanganan duplikasi, dan mitigasi CSRF sesuai mekanisme sesi. Konten Markdown/HTML dan keluaran AI disanitasi; tautan sumber hanya skema yang diizinkan. Tidak menjalankan HTML dalam transkrip pembanding.

HTTPS, konfigurasi header keamanan termasuk CSP sesuai aset nyata, pembatasan frame, kebijakan referrer, dependency audit, pemisahan secret, akses admin minimum, dan autentikasi kuat untuk penerbit. Tidak membundel kunci layanan atau token Firebase admin ke browser.

Penghapusan akun: halaman menjelaskan langkah yang benar-benar bekerja, cara verifikasi kepemilikan, apa yang dihapus, apa yang disimpan dan alasannya, serta jadwal yang ditetapkan operator. Selesainya formulir tidak boleh dianggap selesainya penghapusan akun.

Hak sumber dicatat per aset. Karya lama tidak otomatis menjadikan setiap scan, edisi tahqiq, audio, terjemahan, atau transkrip bebas digunakan. Kebijakan permintaan koreksi/penghapusan memiliki kanal nyata. Tidak menyebut proyek open source hanya karena bernama OpenTurath.

## 17. Analitik dan operasi

| Peristiwa | Tujuan | Data minimal |
|---|---|---|
| `download_page_view` | Mengetahui kunjungan unduh | Locale, kelas perangkat |
| `download_click` | Mengukur klik tautan resmi | Platform, versi, asal halaman |
| `evaluation_open` | Mengetahui pembacaan kasus | Case ID, locale |
| `evidence_open` | Mengetahui penggunaan sumber | Case ID, evidence ID |
| `collection_open` | Minat pada koleksi | Collection ID, locale |
| `locale_change` | Kebutuhan bahasa | Bahasa awal/akhir, tipe halaman |
| `report_submit_success` | Keberhasilan saluran laporan | Topik, tanpa isi/email |

Jangan mengirim teks pertanyaan, isi laporan, token URL, atau email ke analitik. Definisikan rasio klik unduh per sesi yang tercatat dan jelaskan bahwa pemblokir analitik memengaruhi pengukuran. Tidak mengklaim konversi instalasi tanpa integrasi pengukuran aplikasi yang sah dan teruji.

Operasional: pemilik konten, pemilik rilis, kontak bantuan, dan penanganan insiden ditetapkan. Untuk tim satu orang, jadwal harus realistis. Jangan menjanjikan dukungan 24/7 atau SLA yang tidak tersedia.

- Setiap rilis: cek URL, tanda tangan/hash, kompatibilitas, catatan perubahan, screenshot, bahasa, dan paket akses.
- Mingguan: periksa laporan, tautan sumber kritis, dan kegagalan unduh.
- Bulanan: telaah katalog/angka, dependensi, analitik agregat, dan perubahan penyedia.
- Berkala: uji pemulihan cadangan dan rollback deployment.
- Insiden unduh: cabut rilis bermasalah, ganti CTA dengan penjelasan, pulihkan versi aman bila kompatibel, catat keputusan.
- Insiden sumber: koreksi klaim dan bukti dengan versi baru; jangan menghapus jejak penilaian lama tanpa catatan.

Status layanan hanya menyebut komponen yang dipantau. Jika pembaruan manual, tampilkan waktu pembaruan; tidak menampilkan “Semua sistem normal” sebagai teks dekoratif permanen.

## 18. Matriks pengujian penerimaan

| Area | Skenario wajib | Syarat lulus |
|---|---|---|
| Navigasi | Desktop/mobile, menu, breadcrumb, kembali | Tidak ada dead end atau tautan kosong |
| Bahasa | Setiap template ID/EN/AR, pindah saat membuka detail | Objek yang sama tetap terbuka; tidak ada string hilang |
| RTL | Arab campur Latin, angka, hash, heading panjang | Urutan baca/fokus benar; tidak ada glyph terpotong |
| Katalog | Cari judul/pengarang, filter, hasil kosong, URL dibagikan | Hasil relevan dan filter pulih dari URL |
| Pengujian | Jawaban asli, panel sumber, terjemahan, hasil belum diperiksa | Tidak ada perubahan substansi atau badge berlebihan |
| Unduh | Semua tautan aktif pada perangkat sesuai | Tujuan resmi benar; versi dan file cocok |
| Akses | Cakupan umum vs Tahawwulat, periode dan harga | Tidak ada paket atau janji akses ambigu |
| Form | Input valid/tidak valid, koneksi putus, kirim berulang | Pesan sesuai hasil server; tidak ada kehilangan isi tanpa pemberitahuan |
| Aksesibilitas | Keyboard, VoiceOver, TalkBack, NVDA sesuai target | Alur utama dapat selesai; hasil manual dicatat |
| Visual | 320, 390, 768, 1024, 1440 px; zoom; teks panjang | Tidak ada overflow atau kontrol tertutup |
| Gerak | Reduced motion dan JS dimatikan | Isi dan tindakan inti tetap tersedia |
| Browser | Safari iOS/macOS, Chrome Android/desktop, Firefox, Edge | Alur inti berfungsi pada versi yang didukung dan dicatat |
| SEO | HTML awal, canonical, alternate, sitemap, 404 | URL dan metadata konsisten, tidak ada draft terindeks |
| Performa | Mobile koneksi lambat, halaman kaya sumber | Anggaran dan hasil lab dicatat; lapangan dipantau setelah rilis |
| Keamanan | Input laporan, rendering transkrip, tautan eksternal | Tidak ada eksekusi konten tak tepercaya atau secret publik |
| Operasi | Rollback rilis, pencabutan unduh, pemulihan konten | Prosedur dapat dijalankan dan pemiliknya jelas |

Tidak semua kemungkinan perangkat dapat dibuktikan sekaligus. Daftar platform yang diuji dan keterbatasan yang tersisa harus menyertai serah terima.

## 19. Urutan produksi dan publikasi

1. Kunci identitas, katalog, rilis unduh, model akses, dan operator.
2. Pisahkan klaim bahan awal menjadi terkonfirmasi, perlu bukti, atau tidak digunakan.
3. Lengkapi Q001: transkrip utuh, metadata yang diketahui, matriks pemeriksaan sumber, dan keterbatasan.
4. Finalkan naskah tiga bahasa, bibliografi, FAQ, bantuan, dan dokumen operasional.
5. Rancang template desktop/mobile: beranda, daftar, detail koleksi, pengujian, unduh, artikel, form.
6. Bangun shell dan komponen, lalu isi konten terstruktur. Hubungkan tindakan hanya ke tujuan yang nyata.
7. Jalankan validasi konten, pengujian alur, pemeriksaan visual, aksesibilitas, dan keamanan yang relevan.
8. Siapkan domain milik pengguna, DNS, TLS, canonical origin, metadata sosial, dan pengalihan host; tidak mengarang nama domain resmi.
9. Publikasikan build yang sudah diperiksa. Uji ulang tautan unduh dan sumber pada URL produksi.
10. Kirim sitemap ke konsol pencarian yang dimiliki pengelola; aktifkan pemantauan dan analitik yang disepakati.
11. Simpan versi rilis, bukti pengujian, dan prosedur rollback; tetapkan pemeliharaan.

Ini urutan kerja dalam spesifikasi. Rencana implementasi berbasis repo dan pilihan framework dibuat setelah spesifikasi disepakati; belum ada estimasi waktu fiktif atau klaim deployment selesai.

## 20. Data yang masih diperlukan untuk publikasi

| Data | Mengapa diperlukan | Bila belum tersedia |
|---|---|---|
| Domain resmi dan akses hosting | Publikasi, canonical, unduhan, deep link | Situs belum dapat diterbitkan pada domain itu |
| Artefak aplikasi/listing resmi | CTA unduh benar-benar bekerja | Jangan menerbitkan tombol unduh aktif palsu |
| Versi, platform, OS minimum, ukuran/hash APK | Kompatibilitas dan integritas rilis | Isi dari artefak aktual sebelum membuka unduhan |
| Katalog final dan definisi hitungan | Cakupan produk dan angka publik | Hilangkan angka yang belum terkonfirmasi; jangan mengarang |
| Paket, harga, periode, pengembalian/perpanjangan | Kejelasan transaksi | Jangan mempublikasikan tabel harga rekaan |
| Scan/tautan sumber dan lembar pemeriksaan Q001 | Bukti rujukan dan klaim hasil | Terbitkan arsip dengan status belum diperiksa; tahan skor verifikasi |
| Tanggal/model/kondisi uji jika tercatat | Batas perbandingan | Nyatakan tidak tercatat; tidak mengaku uji terkontrol |
| Identitas operator dan kontak aktif | Bantuan, privasi, hak, keamanan | Halaman operasional belum final |
| Perilaku data, retensi, penghapusan akun aktual | Kebijakan yang sesuai implementasi | Jangan menerbitkan janji privasi/penghapusan yang belum bekerja |
| Hak font, screenshot, scan, transkrip, logo | Hak penggunaan aset | Gunakan aset yang izinnya tersedia |
| Screenshot rilis aktual dan wordmark yang diterima | Kesesuaian pemasaran dan produk | Pakai teks/editorial; jangan menyajikan konsep sebagai rilis |

Daftar ini merupakan kebutuhan internal produksi, bukan teks placeholder yang boleh muncul di situs. Data yang tidak esensial boleh dihilangkan dari tampilan; data esensial unduhan, transaksi, dan operator harus diselesaikan sebelum alur terkait dipublikasikan.

## 21. Gerbang rilis dan serah terima

Situs siap dinilai untuk publikasi ketika halaman wajib lengkap dalam tiga bahasa, unduhan resmi berfungsi, harga/cakupan benar, bukti diberi status akurat, saluran bantuan berfungsi, kebijakan mengikuti perilaku nyata, serta pemeriksaan teknis inti lulus.

Berkas serah terima pembangunan harus mencakup: source repository; petunjuk build dan deployment; konfigurasi contoh tanpa secret; dataset konten dan kamus; inventaris aset/lisensi; arsip pengujian yang boleh dipublikasikan; hasil QA; daftar keterbatasan; prosedur pembaruan konten/rilis; prosedur rollback; serta daftar pemilik layanan.

Jangan menyebut situs “100% siap produksi” dari kelengkapan dokumen ini saja. Status akhir harus menyebut apa yang benar-benar dibangun, diterbitkan, dan diuji.
