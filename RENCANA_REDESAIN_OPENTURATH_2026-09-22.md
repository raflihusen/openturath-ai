# Rencana desain ulang OpenTurath — Ruang Baca

Tanggal: 22 September 2026. Baseline kode: `bba54a3`, branch `main`.
Status: kajian dan proposal revisi 2; belum mengubah aplikasi. Build APK dan publikasi tidak termasuk tahap ini. Revisi 2 menindaklanjuti penekanan pengguna pada kreativitas menyeluruh, copy ID/EN/AR, seluruh motion/state native, serta eksklusivitas lima tipe Fikih Tahawwulat. Bila berbeda dengan proposal awal, keputusan revisi 2 dalam dokumen ini yang berlaku.

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

### Fikih Tahawwulat: koleksi unggulan eksklusif

Tahawwulat mendapat identitas visual khusus yang hadir konsisten pada pintu masuk Beranda, direktori Asisten, halaman koleksi, katalog sumber dan paketnya. Kartu ringkasan membuka halaman native koleksi yang menyatukan pengenalan, cakupan, lima tipe, dan kitab rujukan. Sediakan akses langsung ke asisten utama dari ringkasan agar pengguna rutin tidak wajib melewati halaman pengenalan. Perlakuan eksklusif dijabarkan pada bagian 13.

Ekspresi khas: halaman judul dengan lambang resmi OpenTurath, judul Arab dan nama koleksi; lima tipe memiliki identitas editorial serta penjelasan peran masing-masing. Data dan jumlah tipe berasal dari model. Warna gelap bukan penanda premium otomatis; susunan tetap berkelas pada light mode.

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
| Aksen | Tinta monokrom untuk aksi utama; olive untuk status yang benar; merah untuk destruktif/error; aksen kuningan redup khusus identitas Tahawwulat | Makna konsisten, flagship memiliki identitas tersendiri |
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
| B — Prototipe arah | Tahawwulat dan lima tipe lebih dahulu; dilanjutkan Beranda, Asisten, detail kitab, Catatan/pembaca; light/dark dan ID/EN/AR, memakai data contoh berlabel | Identitas flagship, komposisi, bahasa, motion, density dan CTA dapat ditinjau sebelum migrasi luas |
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

## 12. Blind spot revisi 2 dan keputusan yang menutupnya

Rencana awal belum cukup untuk menjamin redesain menyeluruh. Kekurangannya bukan hanya jumlah layar yang dibahas, melainkan belum adanya kontrak terukur untuk bahasa, identitas flagship, semua keadaan sementara, dan batas dependensi area AI.

| Blind spot | Bukti / celah | Keputusan revisi |
|---|---|---|
| Tahawwulat masih diperlakukan sebagai kartu besar | Identitas lima tipe belum dirancang satu per satu | Sistem visual koleksi eksklusif + lima profil peran + jalur cepat; menjadi prototipe pertama |
| Tiga bahasa dianggap sebagai penerjemahan label | `Loc.text` mengembalikan sumber bila tidak ditemukan; `Loc.tr` hanya assert pada key hilang; teks dinamis dan panjang tidak tercakup oleh tes kelengkapan katalog | Inventaris copy berdasar permukaan/state; stable keys untuk native baru; QA layout dan makna per bahasa |
| Default error/loading bocor bahasa Indonesia | `app_loader.dart` default Batal; `app_error_state.dart` default judul/isi/tindakan Indonesia dan GoogleFonts langsung | Komponen state khusus native dengan copy wajib terlokalisasi; caller AI lama tetap identik |
| Reduce Motion belum menyeluruh | `AppLoader` menjalankan controller.repeat tanpa pengecekan disableAnimations | Motion policy untuk native baru; loading tetap dapat dipahami tanpa gerak |
| Redesign shared components merembet ke AI | AgentMultiTabRoom memakai AppLoader pada baris 898/1224 dan AppErrorState pada 1033; jalur agent_webview_screen juga memakainya | Jangan mengganti default/implementasi shared widget; pakai versi native baru dan migrasi caller yang berada dalam scope saja |
| Mengubah copy global dapat mengubah UI AI | Locale dan AppCopy/copyCatalog adalah dependensi bersama | Tambahkan namespace/key baru untuk copy native; jangan mengganti key AI yang sama atau mekanisme global tanpa pemeriksaan caller |
| Eksklusivitas berisiko menambah hambatan | Halaman koleksi menambah ketukan bila selalu diwajibkan | Pintu utama dan lima tipe punya akses langsung; pengenalan adalah pilihan, bukan gerbang wajib |
| Lima tipe mudah terkesan lima produk berbayar | Satu parent entitlement dengan beberapa subagent | Status hak akses mengikuti model sebenarnya; jumlah tipe bukan lima lisensi terpisah |
| Copy deskripsi antarbahasa tidak setara | Al-Mukhtabir: Indonesia menyebut ujian pemahaman, Arab juga menyebut nawazil; Al-Muhaqqiq berbeda tingkat rincian | Satu definisi kemampuan per tipe menjadi sumber brief bagi ketiga bahasa |
| Test hijau disamakan dengan kualitas UX | Tes kelengkapan translation memeriksa tiga nilai/placeholder, bukan kualitas Arab/EN, overflow atau fokus | Gabungkan tes perilaku, review linguistik, screenshot state dan uji tugas |
| Kelengkapan native belum memiliki daftar selesai | Dialog, voucher, legal, update, auth dan keyboard bisa tertinggal | Coverage ledger seluruh layar/overlay native; semua baris harus punya desain dan QA |
| Rencana belum memberi batas data baru | Riwayat tipe terakhir belum dibuktikan tersedia; Al-Habib adalah asisten arsip, belum tentu audio player native | Desain bekerja tanpa data baru; rekomendasi/riwayat hanya tampil bila ada sumber yang sah |

## 13. Art direction Tahawwulat — edisi istimewa dalam perpustakaan

### Identitas yang dapat dikenali

Konsep internal: **Lima Pintu Telaah**. Nama ini menjelaskan struktur rancangan; bukan kewajiban menambah slogan pada aplikasi. OpenTurath tetap rumah besarnya, Tahawwulat merupakan koleksi istimewa dengan satu identitas induk dan lima peran yang jelas.

Pengguna memosisikan Tahawwulat sebagai AI khusus pertama di dunia. Itu menjadi konteks positioning dan ambisi desain; kajian ini belum melakukan pembuktian pasar atas klaim pertama di dunia. Dalam rancangan publik, siapkan tempat ringkas untuk klaim tersebut bila substansiasinya tersedia, tanpa membuat tanggal, penghargaan, segel otoritas atau pengesahan palsu. Nilai eksklusif harus sudah terasa melalui kualitas komposisi dan pengalaman, bahkan tanpa headline superlatif.

Signature visual yang diusulkan:

1. **Halaman judul koleksi.** Lambang resmi kecil, judul Arab yang lapang, judul lokal dan atribusi keilmuan. Bingkai tunggal tipis seperti halaman awal edisi khusus, bukan frame berlapis di setiap kartu.
2. **Tinta dan kuningan redup.** Dark: permukaan #171917 dengan aksen awal #C7AD78; light: kertas #F7F5F0 dengan aksen awal #765C2E. Teks utama tetap warna kontras tinggi; warna ini proposal yang harus diukur. Aksen hanya pada penanda koleksi, garis bab, dan keadaan terpilih, bukan seluruh paragraf atau layar.
3. **Daftar isi lima peran.** Lima entri yang sengaja dirancang, dengan nomor urut kecil noninteraktif, nama, deskripsi tujuan, ikon fungsional dari keluarga yang sama, dan affordance Buka. Penomoran memetakan tepat lima tipe; berbeda dari nomor dekoratif acak pada kategori umum.
4. **Momen masuk pendek.** Halaman koleksi muncul melalui fade dan perpindahan kecil 240–300 ms. Judul dan daftar hadir berdekatan, tanpa antrean animasi panjang. Tidak ada intro video, gerbang yang harus ditunggu, efek partikel, atau shimmer emas berulang.
5. **Identitas yang berlanjut.** Detail koleksi, katalog Tahawwulat dan ringkasan paket memakai penanda yang sama. Area percakapan tidak menerima dekorasi, warna, loader, atau perilaku baru dari sistem ini.

Lambang resmi dipakai dari aset existing. Tidak menciptakan kaligrafi ayat, atribusi ulama, sertifikat atau manuskrip palsu sebagai dekorasi. Tipografi Arab dibentuk oleh font, bukan gambar hasil generasi.

### Lima tipe: identitas dan copy konsep

Nama produk/ID tetap mengikuti model pada `models/agent_model.dart:119–164`. Deskripsi berikut adalah draft desain, diselaraskan terhadap tujuan model; tidak mengubah prompt, kemampuan AI atau isi WebView.

| Tipe dan ID suffix | Peran visual | Indonesia | English | العربية |
|---|---|---|---|---|
| Al-Muhaqqiq · المحقق · `muhaqqiq` | Motif tanda rujukan/halaman; ketelitian sumber | Telaah matan, ibarah, dan rujukannya. | Study source texts, passages, and references. | مطالعة المتون والعبارات ومراجعها. |
| Al-Bayan · البيان · `bayan` | Motif anotasi; penjelasan yang terbuka | Pahami konsep dan istilah secara bertahap. | Explore concepts and terms step by step. | فهم المفاهيم والمصطلحات خطوة بخطوة. |
| Al-Mukhtabir · المختبر · `mukhtabir` | Motif pertanyaan; refleksi pemahaman | Uji pemahaman melalui tanya jawab. | Test your understanding through questions and answers. | اختبار الفهم من خلال الأسئلة والأجوبة. |
| Al-Habib · الحبيب · `habib` | Motif arsip suara; khazanah lisan | Telusuri materi muhadharah Habib Abu Bakar. | Explore Habib Abu Bakr’s lecture materials. | استكشاف مواد محاضرات الحبيب أبي بكر. |
| Al-Khatib · الخطيب · `khatib` | Motif susunan naskah; penyampaian | Susun bahan dakwah dan khutbah. | Prepare materials for talks and sermons. | إعداد مواد للدعوة والخطب. |

Al-Habib dipresentasikan sebagai asisten untuk materi muhadharah, bukan percakapan langsung dengan tokoh atau suara tiruan. Ikon arsip tidak berarti tersedia pemutar audio native. Al-Mukhtabir tidak diberi skor, sertifikat atau progres belajar fiktif. Al-Khatib tidak diberi janji validasi ilmiah otomatis.

### Komposisi dan interaksi

Pada ponsel: header kembali → judul koleksi dan atribusi → tindakan utama sesuai akses → lima tipe dalam daftar → Kitab rujukan → Mengenal Fikih Tahawwulat. Header cukup ringkas agar awal daftar terlihat pada viewport normal. Seluruh lima tipe tetap mudah dicapai dengan satu scroll kontinu.

Kelima tipe memiliki bobot yang setara. Hindari susunan 2×2+1 yang tanpa alasan membuat tipe terakhir terlihat sebagai opsi sisa. Pada layar lebar, halaman judul dan ringkasan berada di sisi awal, daftar lima tipe di sisi berikutnya; layout berbalik secara semantik pada RTL.

Ketuk Buka pada tipe → panggil callback existing → pemeriksaan akses existing → ruang AI existing. Ketuk area informasi terpisah → uraian native singkat bila diperlukan. Tidak ada selector yang menyuntik prompt, mengganti notebook URL, atau mengubah tipe secara diam-diam di dalam WebView.

Pintu Tahawwulat di Beranda adalah tautan unggulan ringkas pada komposisi default, bukan promo besar berulang. Pada Asisten, kartu koleksi punya ruang lebih dari baris reguler tetapi tidak memuat seluruh lima tipe sekaligus. Jika sesi Tahawwulat sedang aktif, hero Lanjutkan kajian tetap mengutamakan sesi aktual. Status aktif, terkunci, belum tersedia, atau gagal dimuat dijelaskan dengan label, bukan kuningan semata.

## 14. Sistem copy tiga bahasa sebagai pekerjaan desain

### Kontrak bahasa

- Indonesia: alami, ringkas, menghormati pembaca; istilah mapan seperti Asisten, Catatan, Kitab rujukan, Langganan dipertahankan. Perbaikan copy boleh dilakukan menyeluruh untuk membantu keputusan; tidak mengganti nama demi terlihat baru.
- Inggris: tulisan natural untuk pembaca literatur Islam, bukan meniru susunan kalimat Indonesia. Istilah matan/ibarah dapat dipertahankan pada konteks ilmiah dengan penjelasan singkat bila diperlukan.
- Arab: fusha kontemporer yang tenang, terminologi keilmuan konsisten, tanpa dekorasi harakat berlebihan pada label UI. Naskah kutipan dan judul asli tetap utuh.
- Nama ulama dan kitab mengikuti data sumber; jangan menerjemahkan judul secara spekulatif. Simpan transliterasi secara konsisten. Bahasa UI tidak otomatis menerjemahkan isi catatan atau jawaban AI.

Glossary awal: Asisten / Assistant / المساعد; Catatan / Notes / الملاحظات; Kitab rujukan / Reference works / الكتب المرجعية; Langganan / Subscription / الاشتراك; Lanjutkan kajian / Continue studying / متابعة الدراسة. Periksa perbedaan dengan key lama sebelum diterapkan; perbaikan native memakai key baru bila key lama juga digunakan AI.

### Sampel copy untuk keadaan native

| Maksud | Indonesia | English | العربية |
|---|---|---|---|
| Pilih tipe Tahawwulat | Pilih asisten sesuai kebutuhan kajian Anda. | Choose an assistant for your study needs. | اختر المساعد المناسب لاحتياجات دراستك. |
| Tombol tipe | Buka asisten | Open assistant | فتح المساعد |
| Pustaka loading | Memuat kitab rujukan… | Loading reference works… | جارٍ تحميل الكتب المرجعية… |
| Loading lambat | Masih memuat. Anda dapat kembali dan mencoba lagi. | Still loading. You can go back and try again. | لا يزال التحميل جاريًا. يمكنك الرجوع والمحاولة مجددًا. |
| Tanpa hasil | Tidak ada kitab yang cocok. Coba judul atau nama pengarang lain. | No matching works. Try another title or author. | لم نعثر على كتب مطابقة. جرّب عنوانًا أو اسم مؤلف آخر. |
| Catatan kosong | Belum ada catatan. Simpan rujukan atau tulis catatan pertama Anda. | No notes yet. Save a reference or write your first note. | لا توجد ملاحظات بعد. احفظ مرجعًا أو اكتب ملاحظتك الأولى. |
| Tindakan catatan | Tulis catatan | Write a note | كتابة ملاحظة |
| Simpan lokal berhasil | Catatan tersimpan di perangkat. | Note saved on this device. | حُفظت الملاحظة على هذا الجهاز. |
| Gagal memuat | Belum dapat memuat data. Silakan coba lagi. | Couldn’t load the data. Please try again. | تعذّر تحميل البيانات. يُرجى المحاولة مجددًا. |
| Retry | Coba lagi | Try again | إعادة المحاولة |
| Pembayaran diverifikasi | Pembayaran sedang diperiksa. | Your payment is being verified. | جارٍ التحقق من الدفع. |
| Pembayaran diterima, akses pending | Pembayaran diterima. Akses sedang diaktifkan. | Payment received. Your access is being activated. | تم استلام الدفع. جارٍ تفعيل الوصول. |
| Aktivasi selesai | Akses Anda sudah aktif. | Your access is active. | تم تفعيل وصولك. |

Copy status hanya digunakan ketika state yang mendasarinya benar-benar diketahui. `BookmarkService.isSyncing` saja tidak membuktikan sinkronisasi sukses; jangan menampilkan “Tersinkron” tanpa bukti. Teks “memeriksa pembayaran” tidak dipakai untuk loading katalog. Error jaringan hanya disebut bila penyebabnya diketahui; error umum tidak otomatis menyalahkan koneksi pengguna.

### Engineering dan QA bahasa

1. Buat ledger copy: key, layar/state, ID, EN, AR, placeholder bertipe, catatan konteks, pemilik review dan status validasi. Cakup tooltip, semantics, dialog, toast, empty/error, kebijakan, voucher, menu dan teks aksesibilitas.
2. Gunakan stable semantic keys native; jangan bergantung pada pencarian balik teks `Loc.text` untuk copy baru. Bahasa harus berubah pada layar dan overlay terbuka tanpa restart. Konten dinamis dari model tetap dihormati.
3. Susun kalimat lengkap dengan placeholder; jangan menggabungkan fragmen berdasarkan tata bahasa Indonesia. Jumlah Arab memiliki kategori zero/one/two/few/many/other. Pilihan mekanisme ICU/formatter ditetapkan saat implementasi dengan cakupan native saja; tidak mewajibkan migrasi i18n seluruh aplikasi.
4. Format tanggal/jumlah sesuai locale, tanpa mengganti nilai harga/mata uang. Tentukan kebijakan angka Arab secara konsisten; invoice, URL, email dan kode akses tetap LTR terisolasi. Kalender Hijriah memakai metode yang sudah ada dan label yang jelas; jangan mengubah perhitungannya karena redesign.
5. Layout menggunakan start/end, ikon arah yang benar, urutan fokus RTL yang logis. Ikon nonarah, logo, foto dan angka bukan semuanya dibalik. Naskah Arab pada UI Inggris/Indonesia tetap RTL sendiri; kutipan Latin pada UI Arab tetap terbaca.
6. Font untuk Arab diuji pada judul, body, field input, placeholder, numeral dan tanda baca campuran. Pastikan font offline dan fallback tersedia sebelum mengklaim konsistensi.
7. Periksa seluruh key terpakai, placeholder, teks kosong/key mentah, serta istilah yang tidak diterjemahkan secara sengaja. Tes katalog yang sudah ada dipertahankan, tetapi ditambah pemeriksaan penggunaan dan layout native.
8. Review makna EN/AR terpisah dari tes teknis. Draft tabel bukan bukti sudah ditinjau penutur/editor; review bahasa dicatat eksplisit dan tidak menghalangi pembuatan prototipe.

## 15. Koreografi motion dan semua state native

Motion harus menjelaskan respons, perubahan posisi atau keadaan. Durasi berikut titik awal prototipe, bukan penundaan buatan operasi.

| Peristiwa | Rancangan | Reduced Motion / batas |
|---|---|---|
| Launch | Lambang/wordmark fade singkat maksimal sekitar 200 ms, mengikuti kesiapan auth | Statis; tidak menunggu animasi selesai untuk navigasi |
| Tekan tombol/kartu | Scale 0.985, 140 ms, easing yang ditetapkan | Highlight/statis; haptic selektif dan tanpa duplikasi |
| Berpindah tab | Perubahan konten langsung atau fade 120–160 ms; posisi scroll tersimpan sesuai kontrak | Langsung; tidak menyapu melewati tab di antaranya |
| Halaman detail | Transisi 220–280 ms yang mempertahankan orientasi; Back platform tetap bekerja | Tanpa slide; native page saja |
| Masuk koleksi Tahawwulat | Fade + offset kecil 240–300 ms, hanya pada halaman koleksi | Statis/fade singkat; tidak mengulang animasi untuk setiap rebuild |
| Pilih filter | State terpilih berubah sekitar 140 ms; hasil berubah tanpa seluruh layar berkedip | Perubahan instan; fokus dan input tetap |
| Pemuatan pertama daftar | Skeleton yang mengikuti geometri baris nyata, pulse opacity sangat halus | Skeleton statis + label semantics; tanpa kilatan |
| Refresh data tersedia | Tetap tampilkan data lama dengan indikator kecil; gagal refresh tidak menghapusnya | Label status tanpa gerak |
| Submit/simpan | Tombol mempertahankan lebar; tampilkan busy dan cegah double submit | Label proses; selesai diumumkan sekali |
| Empty/error → data | Crossfade sekitar 160 ms, tanpa layout jump yang besar | Instan; fokus kembali ke lokasi yang masuk akal |
| Sheet/menu | 240–280 ms, menyesuaikan keyboard dan safe area | Tanpa slide; fokus masuk dan kembali ke pemicu saat ditutup |
| Voucher/pembayaran sukses | Check sederhana + pesan jelas, maksimal 200 ms | Ikon statis; tanpa konfeti atau bounce besar |
| Penggantian tema | Adaptasi pendek bila nyaman, tanpa flash putih | Langsung; preferensi sistem dihormati |
| Penggantian bahasa | Layout dihitung ulang atomik, menjaga input dan scroll bila memungkinkan | Tidak ada animasi yang membalik teks secara visual |

Loading kurang dari sekitar 150 ms tidak perlu memunculkan skeleton berkedip. Jika loading masih berlangsung, tampilkan feedback; pada waktu lama (misalnya 8 detik sebagai ambang UX awal) tampilkan penjelasan yang jujur dan pilihan keluar/retry yang aman. Angka ini bukan network timeout baru dan bukan alasan membatalkan payment request. Progress persentase hanya untuk operasi dengan progress terukur, misalnya unduhan update yang sudah disediakan layanan.

State ledger minimal per permukaan: initial, loading, content, empty, no-results, refresh, stale/offline bila data tersedia, recoverable-error, access-required, disabled/busy, success dan cancelled. Tidak semua state harus ada di setiap komponen; tandai yang tidak relevan beserta alasan. Hindari membangun skeleton palsu untuk jenis layar yang memang tidak mengambil data.

Skeleton, indicator, animation controller dan semantik harus berhenti/tidak aktif saat layar native tidak terlihat, lifecycle paused atau navigasi meninggalkannya. Layar tersembunyi di bawah ruang AI tidak boleh terus menggambar efek dekoratif. Target frame budget mengikuti refresh rate perangkat; ukur di perangkat nyata pada tahap implementasi, jangan mengklaim 60/120 fps dari kode saja.

## 16. Coverage seluruh aplikasi dan isolasi AI

Redesain menyeluruh berarti setiap permukaan native memiliki keputusan desain, termasuk yang jarang dibuka. Coverage ledger implementasi harus mencatat desain, copy ID/EN/AR, light/dark, motion, semantics, state dan pengujian untuk:

- Shell/tab/rail dan header native; Beranda; direktori Asisten; filter/korpus; Khazanah Ulama belum tersedia.
- Ringkasan dan halaman koleksi Tahawwulat; lima tipe; pengenalan panjang; kartu fitur terkait.
- Ringkasan pustaka, katalog editorial/canonical, detail kedua jalur, bookmark/save feedback; LibraryScreen/ResearchLibrarySheet lama ditentukan keterjangkauannya sebelum dimigrasi.
- Catatan, search/filter, pembaca, editor, salin/bagikan, konfirmasi hapus dan undo.
- Profil/status akses, portfolio akses, bahasa, tema, Tentang, bantuan, seluruh dokumen legal, logout/hapus akun.
- Login/splash dan area native autentikasi yang terpisah dari WebView; state gagal/batal/menunggu.
- Langganan, pemilih bidang/periode, ringkasan harga, redeem code, checkout chrome dan status native.
- Banner/dialog update, loader/error/toast/dialog umum dalam subtree native.

Ada batas yang tidak dinegosiasikan untuk pekerjaan ini: **isi dan pengalaman area AI berbasis WebView tetap seperti sekarang**. Termasuk HTML/CSS/JS yang disuntikkan, chat chrome di modul AI, prompt, notebook URL, cookies/session, tab retention, bridge, clipboard AI, reload/retry AI, loader/error AI, serta auth flow yang melekat pada WebView. Desain lima tipe berhenti saat callback existing menyerahkan kontrol ke ruang AI.

Token, copy, widget dan motion global yang dipakai AI harus dianggap bagian batas tersebut. Gunakan versi native baru dengan default yang tidak mengubah caller lama. Locale aplikasi yang memang sudah tersedia tetap bekerja; jangan mengubah perilaku bahasa di dalam AI. Checkout pembayaran juga mempertahankan halaman provider dan proses transaksi; hanya presentasi native di luarnya masuk cakupan.

Verifikasi isolasi meliputi hash/diff berkas terlindungi, pemeriksaan dependency/callsite shared, screenshot area AI sebelum/sesudah, serta skenario buka/tutup/kembali yang menggunakan alur existing. File terlindungi tanpa diff belum cukup bila tema atau default shared widget berubah.

## 17. Tahap visual dan ukuran keberhasilan revisi

Deliverable pertama pada implementasi berikutnya adalah prototipe fidelity tinggi halaman koleksi Tahawwulat beserta kelima tipe, dalam ID/EN/AR dan light/dark. Prototipe kemudian mencakup entry card pada Beranda/Asisten, sehingga eksklusivitas dinilai dalam konteks keseluruhan aplikasi. Peragakan loading/empty/error/success dan reduced-motion pada contoh native yang relevan; tidak perlu mensimulasikan ulang chat.

Setelah itu lanjutkan prototipe halaman nonflagship serta migrasi per modul sesuai bagian 9. Arah visual tidak dinilai hanya dari satu screenshot dark mode. Bahasa Arab, light mode dan state gagal harus mendapat tingkat penyelesaian yang sama.

Gate review desain:

1. Pembaca dapat menjelaskan perbedaan kelima tipe dari label dan deskripsinya tanpa membuka WebView untuk mencoba satu per satu.
2. Tahawwulat dapat dikenali dari komposisi dan penanda koleksinya, namun status aktif/terkunci tetap jelas serta tidak bergantung pada warna premium.
3. Semua tugas utama tetap cepat; pengguna kembali tidak dipaksa membaca pengenalan ulang atau menunggu animasi.
4. Ketiga bahasa lengkap pada permukaan native baru, tidak ada key mentah/teks Indonesia tak sengaja, serta tidak ada overflow pada teks besar.
5. State loading/error/pending memberi informasi faktual dan langkah berikutnya; pengalaman tetap jelas saat animasi dinonaktifkan.
6. Area AI, dependensi shared yang melayaninya, dan proses pembayaran tidak berubah akibat desain baru.
7. Semua test lama tetap dijalankan; screenshot, layout dan review bahasa melengkapi hasilnya. Tidak menggunakan nilai skor audit awal sebagai klaim peningkatan tanpa pengukuran ulang.

Rencana ini lebih lengkap, tetapi tidak dinyatakan sempurna: hierarki final, kontras aksen, kepadatan Arab, pemahaman kelima tipe, dan performa motion masih perlu dibuktikan melalui prototipe dan pengujian. Pada tahap sekarang hanya dokumen perencanaan yang berubah.
