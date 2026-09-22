# Rencana desain ulang OpenTurath — Ruang Baca

Tanggal: 22 September 2026. Baseline kode: `bba54a3`, branch `main`.
Status: kajian dan proposal; belum mengubah aplikasi. Build APK dan publikasi tidak termasuk tahap ini.

## 1. Keputusan desain utama

OpenTurath perlu terasa sebagai tempat belajar yang ingin dibuka kembali: pembaca tahu kajian yang dapat dilanjutkan, memahami cakupan asisten sebelum membukanya, dapat memeriksa kitab rujukan, dan menemukan kembali catatannya.

Nama arah desain internal: **Ruang Baca OpenTurath**. Ini bukan penggantian nama produk atau label navigasi.

Karakter visual: halaman judul buku ilmiah, katalog perpustakaan yang rapi, dan kontrol mobile yang ringan. Newsreader menjadi suara editorial; Outfit memandu tindakan; Scheherazade New menjaga martabat dan keterbacaan naskah Arab. Konten menjadi pembeda layar, bukan ornamen yang terus berulang.

Tiga arah dipertimbangkan:

| Arah | Kekuatan | Trade-off | Keputusan |
|---|---|---|---|
| Galeri produk seperti situs Apple | Hero sangat kuat dan mudah menarik perhatian | Porsi promosi besar menghambat pekerjaan belajar berulang | Ambil disiplin hierarki dan ruangnya saja |
| Meja riset padat | Cepat untuk pengguna ahli dan koleksi besar | Terasa administratif di ponsel; pengguna baru perlu banyak memahami kontrol | Ambil ketelitian metadata dan keterhubungan sumber |
| Ruang baca editorial | Tenang, khas turats, mendukung penggunaan harian | Perlu disiplin agar tidak menjadi halaman kosong dengan teks kecil | Arah utama; padukan hero yang bermakna dengan daftar yang informatif |

Prinsip yang diterapkan: satu tindakan utama per konteks; informasi keputusan terlihat sebelum ketukan; ruang kosong mengikuti prioritas; metadata tidak bersaing dengan judul; setiap keadaan layar memiliki langkah berikutnya yang jelas.

## 2. Basis kajian dan batas kepastian

Kajian menelusuri shell, rute, beranda, asisten, kartu Tahawwulat, dua jalur pustaka dan detail kitab, Catatan, pembaca catatan, Pengaturan, login, langganan, checkout, model catatan, layanan penyimpanan, helper font, token dan tes desain. Inventaris `screens/` + `widgets/` berisi 38 berkas Dart; kedalaman pembacaan berfokus pada jalur aktif dan dependensinya.

Dua screenshot lokal telah diperiksa. Screenshot Tahawwulat masih menunjukkan aksen emas sedangkan kartu di kode sekarang monokrom; screenshot Beranda memiliki dekorasi hero yang tidak cocok dengan implementasi yang diperiksa. Keduanya referensi sejarah visual, bukan rekaman runtime baseline ini.

Belum dilakukan pengujian aplikasi berjalan, ukur frame timing, screen reader, pembesaran teks, atau observasi pengguna. Temuan kode adalah fakta statis; akibat visual yang belum terlihat pada runtime diberi status risiko. Hipotesis pengalaman pengguna harus diperiksa lewat prototipe.

Koreksi audit sebelumnya:

- Pola pencarian `Colors.` sebelumnya ikut menghitung `OTColors.`. Angka 112/564 tidak valid sebagai jumlah warna mentah. Pemindaian ulang dengan batas kata pada delapan berkas prioritas menemukan 28 baris yang berisi literal `Color(0x...)` atau `Colors.*`; termasuk transparansi yang sah, sehingga bukan 28 cacat.
- Tidak adanya `textScaler` eksplisit tidak membuktikan Flutter tidak mendukung pembesaran teks. Risiko yang perlu diuji adalah tinggi tetap, ellipsis, dan susunan horizontal yang tidak dapat mengalir.
- Kelas carousel pengumuman ada dalam berkas Beranda, tetapi tidak ditemukan pemanggilannya di sana. Jangan menganggap animasinya sebagai pengalaman aktif Beranda.
- Terdapat 166 deklarasi `test`/`testWidgets` dalam 33 berkas; ini inventaris statis, bukan bukti 166 tes telah lulus.

## 3. Temuan yang menentukan rancangan

| Prioritas | Bukti kode | Dampak / hipotesis UX | Keputusan desain |
|---|---|---|---|
| P1 | `widgets/specialist_card.dart:16` menerima `scopeLabel`/`referenceLabel`, tetapi tampilan mulai baris 73 hanya memberi judul dan tindakan | Pengguna sulit menilai perbedaan cakupan asisten; kesederhanaan menghilangkan informasi keputusan | Tampilkan judul, satu kalimat cakupan, akses, dan pintu rujukan yang jelas |
| P1 | `screens/specialist_list_screen.dart:405` menempatkan flagship beserta seluruh subasisten di dalam daftar yang sama | Koleksi utama berpotensi menguasai beberapa layar sebelum asisten lain terlihat | Ringkasan flagship pendek dalam direktori; uraian dan subasisten di halaman koleksi |
| P1 | `widgets/library_bottom_sheet.dart:18` → `library_metadata_overview_screen.dart:68` → katalog editorial → detail | Pencarian kitab harus melewati ringkasan; jalur metadata dan fallback punya presentasi berbeda | Tombol Kitab rujukan langsung ke katalog kontekstual; ringkasan tetap tersedia sebagai Tentang koleksi |
| P1 | `screens/book_library_editorial_screen.dart:415` dan `:635` memakai teks Arab dengan tinggi 1.25; flagship `:185` memakai 1.5 | Jalur langsung GoogleFonts melewati aturan 1.85; risiko harakat rapat/terpotong | Semua teks Arab memakai style khusus per aksara dengan tinggi 1.85–1.95, termasuk saat UI Indonesia |
| P1 | `screens/note_reader_screen.dart:112` dan `:136` memakai Newsreader/Outfit langsung untuk konten yang bisa bercampur Arab | Fallback glyph dan ritme baca tidak konsisten antarjenis catatan | Tata huruf campuran ditentukan dari isi/run teks, bukan bahasa UI semata |
| P1 | `screens/subscription_screen.dart:33` membaca asisten asal, tetapi `:270` selalu menampilkan Tahawwulat terlebih dahulu | Pilihan yang diminta pengguna bisa terdorong ke bawah | Paket sesuai konteks berada di atas; pilihan lain menjadi bagian sekunder |
| P1 | `agent_multi_tab_room.dart:93` dan `:220` mengonsumsi token global yang sama | Mengganti token global dapat mengubah ruang percakapan meskipun berkasnya tidak diedit | Token baru diberi cakupan pada subtree native yang didesain ulang |
| P2 | `screens/dashboard_screen.dart:441` memakai grid dua kolom dengan tinggi 156; jumlah asisten pada daftar kurasi hardcoded | Ruang untuk kategori besar, jumlah dapat menyimpang dari ketersediaan | Direktori bidang lebih ringkas; jumlah dihitung dari data aktif atau tidak ditampilkan |
| P2 | Beranda memakai `contains`; Asisten memakai `ArabicUtils.matches` | Hasil pencarian Arab dapat berbeda untuk masukan yang sama | Kontrak pencarian asisten yang sama, dengan normalisasi Arab dan label lingkup jelas |
| P2 | `screens/profile_screen.dart:829` menetapkan kartu akses setinggi 198 | Status akses menjadi elemen dominan; risiko pemotongan pada nama/teks panjang | Identitas ringkas + daftar akses yang dapat mengalir, status dan masa berlaku tetap utama |
| P2 | Katalog editorial berisi string Indonesia langsung; detail canonical `book_detail_screen.dart:234` memaksa seluruh halaman RTL | Bahasa kontrol dan arah konten tidak seragam | UI mengikuti bahasa pilihan; judul/matan Arab punya arah sendiri |
| P2 | Pencarian Asisten memiliki tinggi 48, filter Catatan 38, grid Beranda tinggi tetap, kartu akses tinggi tetap | Kandidat overflow pada layar sempit dan teks besar | Tinggi minimum, wrapping, serta tata letak satu kolom saat ruang tidak cukup |
| P2 | Jalur named route Asisten di `main.dart:150` tidak meneruskan field; shell memiliki jalur field tersendiri | Navigasi fallback dapat kehilangan konteks filter | Konteks bidang diuji pada kedua pintu masuk ketika navigasi native dirapikan |
| P2 | `test/design_system_test.dart` mengunci hex, radius, ukuran dan kurva lama | Mengganti token lama akan membuat persyaratan 166 tes lama tetap hijau berbenturan dengan desain baru | Tambahkan token versi baru untuk layar native; tes lama tetap dijalankan tanpa dilonggarkan |

Lokasi di tabel relatif terhadap `openturath_ai/lib/`, kecuali test. Nomor baris berlaku pada baseline ini.

### Penilaian awal menurut rubric desain

Skor berikut adalah penilaian heuristik dari kode dan referensi historis, bukan hasil audit visual runtime atau skor kepatuhan. Nilainya membantu mengurutkan pekerjaan, tidak dipakai untuk mengklaim peningkatan kuantitatif.

| Dimensi | Skor /10 | Dasar utama |
|---|---:|---|
| Konsistensi warna | 6 | OTColors tersedia; flagship, kartu akses dan checkout punya palet sendiri |
| Hierarki tipografi | 6 | Tiga keluarga sudah tepat; helper dilewati dan metadata sering terlalu kecil |
| Ritme spasi | 6 | OTSpacing tersedia; grid besar dan angka lokal masih menentukan banyak layout |
| Konsistensi komponen | 5 | Beberapa search, kartu, detail kitab dan jalur modal memiliki kontrak berbeda |
| Responsivitas | 5 | Shell memiliki rail ≥768 dan ringkasan pustaka adaptif; banyak konten masih berukuran tetap |
| Dark mode | 6 | Palet adaptif sudah ada; flagship selalu gelap dan beberapa foreground lokal |
| Animasi | 5 | Wrapper mengenali reduce motion; kurva, skala, dan navigasi belum terpadu |
| Aksesibilitas | 4 | Tooltip/semantics ada sebagian; area tekan kecil, Arab dan layout teks besar perlu dibuktikan |
| Kepadatan informasi | 5 | Beranda memberi ruang besar untuk kategori; asisten justru menyembunyikan cakupan |
| Kelengkapan keadaan | 6 | Empty/error/payment state tersedia; presentasi dan tindak lanjut perlu disatukan |

## 4. Arsitektur pengalaman yang diusulkan

Empat tab tetap menjadi kerangka utama: **Beranda · Asisten · Catatan · Pengaturan**. Ini mempertahankan kebiasaan pengguna dan mencegah tab bertambah sebelum kebutuhan pustaka mandiri terbukti.

Pustaka menjadi tujuan yang mudah ditemukan dari asisten dan koleksi. Beranda mendapat akses Kitab rujukan untuk asisten terakhir jika konteks itu tersedia; jangan membuka koleksi Syafi'i diam-diam ketika pengguna mengira sedang membuka semua pustaka.

Alur yang dirancang:

1. Kembali belajar: Beranda → Lanjutkan kajian → ruang percakapan yang sudah ada.
2. Memilih asisten: Asisten → memahami cakupan dan akses di daftar → Buka asisten / Langganan sesuai entitlement.
3. Memeriksa sumber: Kitab rujukan → katalog koleksi → detail kitab → simpan / salin rujukan.
4. Mengolah hasil: Catatan → baca penuh → salin / edit / bagikan melalui kemampuan yang sudah tersedia.
5. Membeli akses: pilihan asisten → paket relevan → ringkasan harga dan masa akses → checkout → status pembayaran dan aktivasi.

Target alur adalah satu ketukan dari Beranda ke sesi tersedia, satu ketukan dari pintu rujukan ke katalog, dan maksimal dua ketukan dari pintu rujukan ke detail kitab. Angka ini target desain, belum hasil pengukuran runtime.

## 5. Rancangan per layar

### Beranda: meja belajar pribadi

Komposisi dari atas: wordmark kecil + tanggal ringkas; sapaan; satu kartu Lanjutkan kajian atau Mulai kajian; direktori bidang padat; dua catatan terakhir jika ada. Search di Beranda tetap berlingkup Asisten dan tidak dipresentasikan sebagai pencarian isi seluruh kitab.

Hero memakai permukaan tenang, judul serif 26–30, dan satu tombol utama. Tanggal Masehi/Hijriah menjadi satu baris metadata yang bisa membungkus. Enam kartu 156 px diganti direktori dua kolom dengan tinggi berbasis konten, atau satu kolom pada teks besar. Tiap bidang cukup nama dan jumlah yang berasal dari data. Hilangkan nomor urut dan garis dekoratif yang tidak menjelaskan isi.

Catatan terakhir memakai BookmarkService yang sudah ada, urut berdasarkan effectiveTime. Jika kosong, tampilkan ajakan ringan ke Catatan; jangan mengarang riwayat atau statistik belajar. Banner pembaruan hanya muncul ketika keadaan layanan memang memerlukannya.

### Asisten: direktori keilmuan

Judul besar rata awal, pencarian, pilihan jenis korpus, lalu filter bidang. Tahawwulat tampil sebagai satu kartu unggulan pendek. Asisten lain tampil sebagai baris editorial dalam kelompok, dengan judul, cakupan maksimal dua baris, status akses, dan tindakan rujukan terpisah yang luas.

Status “Segera hadir” tidak tampak sama dengan asisten yang dapat dibuka. Khazanah Ulama tetap dapat ditemukan, tetapi keadaan belum tersedia mendapat bobot sekunder yang jujur. Pencarian tidak menempatkan flagship di atas hasil yang lebih relevan.

Ketukan utama tetap membuka asisten sesuai hak akses. Pustaka memakai tombol berlabel dengan sasaran tekan sendiri; tidak menumpuk dua gesture detector yang membuat tindakan ambigu.

### Fikih Tahawwulat: halaman koleksi yang khas

Kartu ringkasan membuka halaman native koleksi yang menyatukan pengenalan, cakupan, subasisten, dan kitab rujukan. Sediakan akses langsung ke asisten utama dari ringkasan agar pengguna rutin tidak wajib melewati halaman pengenalan.

Ekspresi khas: judul Arab sebagai bagian halaman judul, diikuti nama koleksi dan deskripsi pendek; subasisten tersusun seperti daftar isi dengan penjelasan peran. Data dan jumlah subasisten berasal dari model. Warna gelap bukan penanda premium otomatis; susunan tetap berkelas pada light mode.

Pengenalan panjang yang sudah ada dibuka sebagai bacaan lanjut. Jangan mengganti seluruh isi pengenalan, menambah slogan besar, atau membuat fungsi belajar baru. Akses tiap subasisten memakai pemeriksaan entitlement yang sekarang.

### Pustaka: katalog bibliografis

Tujuan pertama langsung menampilkan nama koleksi, cari kitab/pengarang, jumlah hasil, dan daftar. Ringkasan koleksi menjadi tindakan sekunder. Filter jilid yang sudah ada dipertahankan; filter baru hanya ditambahkan bila datanya lengkap dan membantu pencarian.

Setiap entri menampilkan judul Arab, pengarang, serta maksimal tiga fakta edisi yang tersedia. Judul Arab memiliki area penuh dan line-height aman. Metadata kosong disembunyikan. Nomor urut bukan identitas kitab. Tidak memakai sampul buatan yang seolah-olah merupakan sampul edisi sebenarnya.

Jalur katalog editorial dan canonical memakai bahasa komponen yang sama dengan adapter presentasi. Kedua sumber data tetap dipertahankan; jangan menggabungkan ID, atribusi edisi atau status verifikasi secara spekulatif.

### Detail kitab: halaman judul dan identitas edisi

Bagian atas berupa judul Arab, judul pendamping bila tersedia, dan pengarang. Setelahnya informasi edisi dikelompokkan: penerbit/tahun, tahqiq, jilid/halaman, cakupan. Tindakan utama Simpan rujukan; Salin rujukan sebagai tindakan pendamping. Keadaan tersimpan terlihat dan konsisten pada dua jalur data.

Bahasa kontrol mengikuti aplikasi; konten Arab RTL. Dukungan seleksi teks dipertahankan. Jangan memberi tombol Baca kitab jika aplikasi hanya memiliki metadata, atau menjanjikan halaman penuh yang tidak tersedia.

### Catatan, pembaca dan editor: hasil belajar sebagai pusat

Daftar memakai judul, pratinjau singkat, jenis dokumen, sumber, dan waktu. Tiga jenis yang sudah ada—catatan pribadi, jawaban AI, rujukan kitab—dibedakan lewat label dan struktur, bukan warna semata. Filter bidang lama tetap dapat dicapai; filter jenis bisa memakai documentKind yang sudah tersedia.

Ketukan baris membuka bacaan penuh, sehingga daftar tidak perlu mengembang menjadi kartu panjang dengan banyak tombol. Tindakan rutin tampil di pembaca; menu lainnya menampung tindakan sekunder. Hapus tetap dikonfirmasi/dapat dibatalkan sesuai mekanisme yang ada.

Pembaca menggunakan lebar teks terkontrol, paragraf 16–17, kutipan Arab 20–24 dengan tinggi 1.85–1.95. Editor menjaga keyboard, kursor dan draft. Model penyimpanan, sinkronisasi, dan identitas akun tidak diubah untuk keperluan styling.

### Pengaturan: akun dan preferensi yang mudah dipindai

Header profil ringkas; kelompok Langganan; kelompok Tampilan dan Bahasa; kelompok Bantuan dan Kebijakan; tindakan akun terpisah. Nama paket, status aktivasi, serta tanggal berakhir lebih menonjol daripada nomor atau ornamen kartu anggota. Status pending tidak digambarkan sebagai aktif.

Pilihan terang/gelap/sistem tetap tiga opsi. Kebijakan dan kontak yang sudah ada mudah dijangkau dari kelompok bantuan, tanpa harus memahami dialog Tentang terlebih dahulu. Struktur header rata awal disamakan dengan layar utama.

### Langganan dan checkout: keputusan yang jelas

Jika dibuka dari satu asisten, tampilkan pilihan itu terlebih dahulu beserta cakupan dan harga sebenarnya. Jika masuk dari Pengaturan, tampilkan status akses lalu pilihan yang relevan. Selector periode, harga, masa akses, perpanjangan manual dan tombol pembayaran berada dalam satu kelompok keputusan.

Satu ringkasan pilihan + satu tombol utama aktif mengurangi dua CTA bersaing. Harga tetap dari ProductPricing dan validasi respons backend dipertahankan. Kode akses tersedia sebagai tindakan sekunder.

Desain ulang checkout hanya menyentuh header, loading/error/success native, dan container luarnya. WebView pembayaran, navigasi URL, polling, callback, verifikasi invoice dan aturan keluar tidak diganti. Keadaan “pembayaran diterima” dan “akses aktif” tetap dibedakan.

### Login, splash, dialog dan keadaan sistem

Login memakai wordmark, manfaat singkat yang sudah ada, tombol Google, pilihan bahasa dan tautan kebijakan. Splash menjadi jembatan singkat menuju keadaan autentikasi sebenarnya. Google session auth dianggap batas integrasi; hanya area native yang benar-benar terpisah boleh diselaraskan.

Empty state menjelaskan konteks dan satu tindakan. Error memuat langkah pemulihan. Loading mempertahankan konteks, tanpa angka kemajuan palsu. Dialog mengutamakan judul, isi singkat, dan konsekuensi tindakan. Semua sheet dapat bergulir saat keyboard atau teks besar mengurangi ruang.

## 6. Spesifikasi visual awal

Nilai berikut proposal untuk prototipe; bukan angka universal yang diwajibkan Apple HIG.

| Elemen | Proposal | Alasan |
|---|---|---|
| Kanvas | Light #F9F9F8; dark #101010 | Netral untuk bacaan panjang |
| Permukaan | #FFFFFF / #1A1A1A; permukaan sekunder terpisah | Membentuk lapisan tanpa banyak shadow |
| Teks | Utama sekitar #191919 / #F2F2EF; sekunder dipilih berdasarkan uji kontras | Keterbacaan, bukan opacity dekoratif |
| Aksen | Tinta monokrom untuk aksi utama; olive hanya untuk status yang benar; merah untuk destruktif/error | Makna konsisten |
| Border | 0.8–1 dp dekoratif dengan alpha 6–8% / 8–12%; fokus kontrol memakai token lebih kuat | Hairline tidak menjadi satu-satunya pembeda kontrol |
| Radius | Chip 10–12; card/dialog 16; hero 24; sheet 24; CTA/search stadium | Hierarki bentuk; tidak semua elemen menjadi pill |
| Sudut | Shape continuous bila didukung SDK yang terpasang; fill, clip, border dan hit area konsisten | BorderRadius.circular saja bukan corner smoothing |
| Typography | Display 28–32; heading 20–24; body 16; label 14; metadata 12–13 | Mengurangi ketergantungan teks mikro |
| Naskah Arab | 20–24 untuk bacaan, line-height 1.85–1.95, tracking 0 | Harakat dan kenyamanan baca |
| Spasi | 4, 8, 12, 16, 20, 24, 32, 40; gutter 20 ponsel | Ritme konsisten dengan kelonggaran nyata |
| Tekanan | 0.985, 140 ms, Cubic(0.16, 1, 0.3, 1) | Respons halus; cubic easing bukan simulasi pegas fisik |
| Navigasi | 220–300 ms berdasarkan jenis transisi; Reduce Motion meniadakan perpindahan dekoratif | Menjaga orientasi dan preferensi pengguna |

Kartu bukan wadah default untuk semua informasi: hero memakai kartu; direktori memakai baris; bacaan memakai halaman; pengaturan memakai kelompok inset. Inilah variasi komposisi yang membuat aplikasi terasa dirancang menyeluruh.

Area tekan minimum direncanakan 48×48 logical pixels. Kontras sasaran 4.5:1 untuk teks normal, 3:1 untuk teks besar dan batas/indikator kontrol yang diperlukan. Ini sasaran verifikasi, belum klaim lulus. Haptic selektif untuk pilihan/konfirmasi; tidak wajib pada setiap sentuhan.

## 7. Tata letak adaptif

- Ponsel sempit 320–359: satu kolom jika label tidak muat; metadata membungkus; tidak mengunci tinggi komponen teks.
- Ponsel 360–599: gutter 20, tab bawah dengan label, daftar satu kolom; direktori bidang boleh dua kolom jika ukuran teks memungkinkan.
- Medium 600–839: konten memakai max-width; navigasi menyesuaikan hasil pengujian, bukan ukuran ponsel yang diperbesar begitu saja.
- Lebar ≥840: rail berlabel atau sidebar; daftar dan detail dapat berdampingan untuk pustaka/catatan bila state navigasi siap. Pada tahap pertama, max-width yang rapi lebih diutamakan daripada membuat sistem navigasi baru.
- Layout diuji di teks 100%, 150%, 200%; bahasa ID/EN/AR; light/dark/system; keyboard terbuka; safe area; nama panjang; judul Arab berharakat dan campuran angka.

## 8. Strategi implementasi dan batas perubahan

Pekerjaan berikutnya dilakukan pada `main`, satu checkpoint per komponen/layar selesai. Jangan memindahkan desain eksperimen langsung ke semua layar sekaligus.

Gunakan ThemeExtension atau lapisan token native baru yang dicakup hanya pada halaman target. Token lama tetap untuk jalur terlindungi dan kompatibilitas tes lama. Native theme harus diterapkan per halaman/rute dan pada baseScaffold shell; jangan membungkus seluruh Stack yang memuat AgentMultiTabRoom. Periksa juga dialog pada root navigator agar tema baru tidak bocor atau hilang.

Komponen minimum: NativePageHeader, NativeSearchField, InsetGroup, AssistantRow, CollectionHero, BibliographicRow, NoteListItem, AccessStatusRow, PrimaryAction, AdaptiveSheet, serta state loading/empty/error bersama. Nama akhir mengikuti konvensi proyek. Komponen menerima data dan callback; tidak memindahkan layanan pembayaran/autentikasi ke lapisan desain.

File `agent_multi_tab_room.dart`, seluruh `notebook_ui_script.dart`, serta logika chat/session/bridge tetap di luar perubahan. Integrasi shell mempertahankan identity, maintainState, urutan overlay, dan perilaku Back. Screenshot sebelum/sesudah perlu memastikan ruang chat tetap sama, karena diff file kosong saja tidak cukup membuktikan isolasi tema.

Refaktor model katalog bukan prasyarat visual. Adapter tampilan menyatukan komponen tanpa menghapus provenance data, ID penyimpanan, atau kemampuan fallback. Font offline perlu diperiksa: deklarasi asset saat ini belum menunjukkan direktori font dan pencarian asset lokal tidak menemukan TTF/OTF; jangan menjanjikan font selalu tersedia tanpa membuktikannya.

## 9. Urutan kerja dan keluaran tiap tahap

| Tahap | Keluaran | Kriteria selesai |
|---|---|---|
| A — Baseline visual | Capture aplikasi dari commit baseline, state dan jalur aktif; catat 166 tes sebagai baseline runtime | Tampilan aktual dibedakan dari screenshot lama; kegagalan lama terdokumentasi |
| B — Prototipe arah | Empat layar representatif: Beranda, Asisten, detail kitab, Catatan/pembaca; light dan dark, memakai data contoh yang diberi label | Komposisi, tipografi Arab, density, dan CTA dapat ditinjau sebelum migrasi luas |
| C — Fondasi native | Token scoped, shape, typography, search, group, button, state | Isolasi chat terbukti; semantics dan ukuran teks diuji pada komponen representatif |
| D — Shell dan Beranda | Navigasi, resume, pencarian, direktori, catatan terakhir | Resume dan filter menuju konteks benar; tidak ada riwayat/jumlah palsu |
| E — Asisten dan Tahawwulat | Direktori informatif, ringkasan koleksi, halaman koleksi | Cakupan terbaca; akses utama cepat; semua subasisten dan pustaka tetap terjangkau |
| F — Pustaka dan detail | Jalur katalog langsung + komponen konsisten di dua sumber | Cari, fallback, simpan, salin dan identitas edisi tetap benar |
| G — Catatan dan Pengaturan | Daftar, pembaca/editor, akses, preferensi, kebijakan | Simpan/edit/hapus/undo, sinkronisasi dan bahasa tetap bekerja |
| H — Login, langganan, checkout native | Gerbang masuk dan keputusan pembelian konsisten | Harga/invoice/entitlement tetap terjaga; state gagal/pending/aktif berbeda |
| I — Review akhir | Matriks QA dan perubahan per layar, screenshot before/after, hasil tes | Semua skenario yang relevan lolos atau blocker dinyatakan; tanpa build APK |

Tahap B adalah keluaran visual pertama yang disarankan. Setelah arah dapat dilihat, implementasi dilakukan per modul dengan checkpoint; feedback komposisi tidak perlu menunggu seluruh aplikasi selesai.

## 10. Verifikasi yang direncanakan

Baseline dan akhir menjalankan suite `flutter test` yang ada. Selama implementasi, jalankan tes yang relevan dengan modul serta analyze pada kode yang berubah; suite penuh tidak perlu diulang tanpa alasan pada setiap perubahan kecil. Tes lama tidak dihapus atau dilemahkan hanya untuk mendapatkan warna hijau.

Tambahkan tes hanya untuk risiko baru: penerusan filter, konteks paket, pemilihan sumber katalog, Arabic layout, semantic actions, reduce motion, dan isolasi tema. Hindari tes yang hanya menyalin konstanta desain baru tanpa memeriksa perilaku. Golden/widget layout terfokus berguna untuk 320/390/768, RTL, dan text scale 2.0.

Skenario pengguna minimum: pengguna baru tanpa catatan; pengguna kembali dengan sesi; akses aktif/berakhir/pending; pencarian tanpa hasil; gagal memuat pustaka; metadata tidak lengkap; judul Arab panjang; simpan dan buka kembali; pembayaran batal/gagal/terverifikasi; kembali dari ruang chat tanpa kehilangan tab. Pengujian pembayaran memakai mock/sandbox yang sudah diizinkan, tidak membuat transaksi produksi.

Definisi selesai desain: layar pertama menjelaskan tindakan utama; daftar memberi cukup informasi memilih; fungsi lama tetap terjangkau; teks penting tidak terpotong; navigasi dan fokus dapat dipahami; font Arab aman; dark mode disusun secara sengaja; sumber dan status akses tetap jujur.

## 11. Rujukan desain

- [Apple.com](https://www.apple.com/): referensi yang diberikan pengguna; disiplin fokus dan hierarki, bukan spesifikasi UI Flutter.
- [Apple Books](https://www.apple.com/apple-books/): menghubungkan penemuan bacaan dan kembali melanjutkan. Adaptasi OpenTurath adalah resume kajian; tidak mengadopsi fitur goals atau sinkronisasi bacaan yang belum ada.
- [Readwise Reader](https://readwise.io/read): bacaan dan anotasi sebagai aktivitas inti. Adaptasi adalah membuat catatan mudah dibaca kembali, tanpa menambah impor/feed/highlight engine.
- [Zotero](https://www.zotero.org/): orientasi pengelolaan sumber penelitian. Adaptasi adalah kejelasan metadata dan tindakan rujukan.
- [Apple HIG Layout](https://developer.apple.com/design/human-interface-guidelines/layout), [Typography](https://developer.apple.com/design/human-interface-guidelines/typography), [Color](https://developer.apple.com/design/human-interface-guidelines/color), [Motion](https://developer.apple.com/design/human-interface-guidelines/motion): landasan prinsip. Hex, keluarga font dan cubic dalam proposal adalah keputusan OpenTurath.

Metode audit dibantu skill `ecc:design-system`. Review runtime dan prototipe visual masih merupakan tahap berikutnya; laporan ini tidak menyatakan aplikasi sudah didesain ulang atau semua tes sudah lulus.
