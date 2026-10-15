> Arsip audit V4. Arahan dan hasil terbaru tersedia pada `AUDIT_WEBSITE_V4_1.md`, termasuk publikasi metadata, banner tunggal, FAQ, dan mode unduhan.

# Audit dan Rebuild Website OpenTurath V4

Tanggal audit: 20 September 2026.

Website dibangun ulang menjadi artefak trilingual dengan desain obsidian, platinum, dan aksen emas halus. Kode, build statis, pengujian, serta dokumentasi tersedia lengkap. Status artefak website berbeda dari status peluncuran komersial. Paket ini belum diterbitkan ke domain publik dan tidak membuktikan transaksi produksi DOKU atau ketersediaan APK.

## Kesimpulan utama

1. Instruksi harga terbaru diterapkan persis pada website: Tholib Rp49.000 untuk 1 bulan, Tematik Rp149.000 untuk 3 bulan, Sultan All-Access Rp499.000 untuk 1 tahun.
2. Aplikasi hasil audit sebelumnya memiliki skema harga berbeda. Karena itu, klaim bahwa harga dan entitlement telah 100% sinkron tidak dapat diberikan. Perbedaan dicatat pada `content/app-parity.json` dan dijelaskan pada halaman keanggotaan.
3. Beranda memakai satu sumber katalog berisi 21 profil. Dua puluh bidang tersedia pada aplikasi. Khazanah Habib Umar ditampilkan sebagai dalam persiapan tanpa tombol akses atau pembelian.
4. Empat tahap penelusuran ditampilkan sebagai proses telaah dan verifikasi. Janji nol halusinasi serta klaim seluruh sumber sudah terverifikasi dihapus karena tidak didukung bahan audit.
5. Ketentuan, privasi, refund, dan adab tersedia sebagai ringkasan ID, EN, dan AR yang menautkan salinan lengkap naskah resmi aplikasi versi 1.0. Ini bukan sertifikasi hukum internasional atau pengesahan terjemahan legal.

## Sumber pembanding dan batas audit

| Sumber | Pemakaian |
|---|---|
| `openturath_website_terupdate.zip` | Baseline seluruh source dan aset website |
| Aplikasi `lib/core/product_pricing.dart` | Bukti harga promo dan periode paket pada revisi aplikasi sebelumnya |
| Aplikasi `lib/models/agent_model.dart` | Profil, jenis korpus, status, dan peran subasisten |
| Aplikasi `assets/data/metadata_modul_lengkap.json` | Pembanding metadata katalog, bukan bukti bahwa semua edisi telah diverifikasi |
| Aplikasi `lib/core/legal_copy.dart` | Naskah resmi, identitas pengelola, kontak, SLA, Catatan lokal, dan layanan pihak ketiga |
| `Kamus_OpenTurath_ID_EN_AR.csv` | Kamus 532 entri dari pekerjaan aplikasi sebelumnya |
| `content/evaluation.json`, `evidence.json`, `q001-original.md` | Enam jawaban arsip dan sepuluh rekaman kutipan |
| SVG logo master aplikasi | Bentuk logo dipertahankan tanpa digambar ulang |

Audit menelaah source website, perilaku generator, API laporan, data yang diberikan, serta interaksi hasil build melalui Chromium. Tidak ada akses ke konsol produksi Firebase, dashboard merchant DOKU, kepemilikan domain, atau berkas APK yang dapat dicocokkan byte demi byte. Percobaan akses URL APK tidak menghasilkan bukti HTTP yang dapat dipakai untuk mengesahkan unduhan.

## Daftar blind spot dan perbaikannya

| No. | Prioritas | Temuan baseline | Perbaikan atau status V4 |
|---|---|---|---|
| 01 | Kritis | Model harga website dan aplikasi berbeda | Harga mengikuti instruksi terbaru pengguna. Ketidaksesuaian backend dicatat, tidak disamarkan sebagai sinkron |
| 02 | Kritis | Tematik dan All-Access pada konfigurasi website sama-sama berdurasi satu bulan | Diubah menjadi 3 bulan dan 1 tahun. Field `months` menyimpan 1, 3, dan 12 secara eksplisit |
| 03 | Kritis | Cakupan All-Access mengesankan 21 asisten sudah terbuka dan tanpa batas | Cakupan terikat paket aktif, status asisten ditampilkan, kebutuhan akun dan batas layanan pihak ketiga dijelaskan |
| 04 | Kritis | Hero/statistik menyatakan 100% verifikasi atau tidak berhalusinasi | Diganti proses pemeriksaan yang dapat ditelusuri dan batas AI yang jujur |
| 05 | Tinggi | Grid 21 profil beranda berbeda dari katalog 20 koleksi | Beranda, perpustakaan, dan detail memakai `content/catalog.json` yang sama |
| 06 | Tinggi | Profil Habib Umar tampak setara dengan bidang aktif | Status `preparing`, keterangan belum dapat diakses/dibeli, dan halaman detail tanpa CTA akses |
| 07 | Tinggi | Nama profil pada website belum memetakan ID aplikasi | Ditambahkan `appAgentId` dan pemetaan alias Bahasa Arab, Tarikh, serta Thabaqat |
| 08 | Tinggi | Angka 5.074 kitab dan hitungan per koleksi tidak konsisten dengan metadata aplikasi | Angka agregat dan hitungan edisi yang tidak dapat dibuktikan dihapus dari pemasaran. Tidak diganti angka baru yang memberi kesan verifikasi |
| 09 | Tinggi | Judul kitab dan koordinat dari jawaban dianggap sudah cocok dengan cetakan | Arsip menampilkan status belum diperiksa, edisi belum tersedia, dan perbedaan halaman cetak/PDF |
| 10 | Tinggi | Sepuluh rekaman bukti Q001 semuanya `not-reviewed` | Status dipertahankan. Tidak dibuat bukti edisi, penelaah, tanggal, atau scan fiktif |
| 11 | Tinggi | Perbandingan enam jawaban berpotensi dibaca sebagai benchmark umum | Metodologi menyatakan satu kasus, metadata model/tanggal tidak tercatat, dan tidak ada pemenang universal |
| 12 | Tinggi | Pernyataan Catatan tersinkron cloud berbeda dari implementasi aplikasi | Semua panduan baru menjelaskan penyimpanan lokal, risiko hilang, dan cara mencadangkan |
| 13 | Tinggi | Peran Google NotebookLM tidak cukup terbuka sebelum membeli | Dijelaskan pada ketentuan, FAQ, cara kerja, dan panduan akses |
| 14 | Tinggi | SLA refund 7 hari terkesan menjamin dana tiba sejak laporan pertama | Dipisahkan konfirmasi 2 hari kerja, pemeriksaan 7 hari kerja, dan pemrosesan setelah persetujuan 7 hari kerja |
| 15 | Tinggi | Klaim seluruh pajak sudah termasuk belum memiliki bukti | Diubah menjadi kewajiban menampilkan jumlah akhir pada checkout |
| 16 | Tinggi | Metode QRIS, VA, dan E-Wallet dianggap selalu tersedia | Dinyatakan mengikuti metode yang tersedia pada checkout DOKU |
| 17 | Tinggi | Pembayaran berhasil dianggap sama dengan akses aktif | Dibedakan dan diberi arahan menghubungi bantuan sebelum membayar ulang |
| 18 | Tinggi | Semua karya klasik dianggap bebas hak cipta | Hak tahkik, terjemahan, reproduksi, dan edisi modern dijelaskan secara terpisah |
| 19 | Tinggi | Kebijakan website tidak memiliki rujukan versi yang jelas ke aplikasi | Versi 1.0, tanggal 13 September 2026, kontak resmi, salinan Dart, dan naskah Indonesia lengkap disertakan |
| 20 | Tinggi | Identitas badan hukum dan alamat rinci belum tersedia | Menggunakan identitas faktual dari aplikasi, Pengelola OpenTurath, Indonesia. Tidak mengarang PT, nomor registrasi, atau sertifikasi |
| 21 | Tinggi | Kartu macOS/Windows masih mempunyai tautan aktif walau bergaya nonaktif | Tautan unduh dan alternatif benar-benar tidak dirender untuk `comingSoon` |
| 22 | Tinggi | Gerbang produksi dapat menganggap rilis yang masih coming soon sebagai rilis aktif | Validasi kini mensyaratkan setidaknya satu rilis yang tidak revoked dan tidak coming soon |
| 23 | Tinggi | Persetujuan formulir hanya diperiksa, tidak ikut dipersistenkan | Payload menyimpan `consent: true` dan `consentVersion` yang ditetapkan server |
| 24 | Sedang | URL halaman laporan menerima bentuk `//host` dan carriage return | Validasi menolak kedua bentuk tersebut |
| 25 | Sedang | Harga berupa string diterima oleh validator | Harga kini harus berupa angka finite nonnegatif |
| 26 | Sedang | Sumber harga beranda dan halaman akses mudah berbeda | Keduanya memakai komponen `membership.mjs` dan konfigurasi yang sama |
| 27 | Sedang | Kunci terjemahan berpotensi hilang tanpa terlihat | `tr()` melempar error pada kunci yang tidak tersedia, tes memeriksa paritas semua kunci dan artikel |
| 28 | Sedang | Istilah bersama berbeda dari kamus aplikasi | Tiga belas label dipetakan persis melalui `content/glossary-map.json` dan diuji. Kamus lengkap 532 entri disertakan |
| 29 | Sedang | Font Arab dan Latin bertumpuk dari beberapa revisi CSS | Tipografi disatukan pada Newsreader, Outfit, dan Scheherazade New dengan font lokal dan lisensi |
| 30 | Sedang | Palet biru Apple dan identitas visual generik mendominasi | Aksen biru dihapus, logo asli digunakan, kanvas obsidian, platinum, dan emas dipakai konsisten |
| 31 | Sedang | Hierarki hero dan jarak teks/ilustrasi tidak stabil | Hero mengikuti teks yang diminta, deskripsi dua baris pada desktop 1440 px, ilustrasi radial mask, tanpa mockup ponsel |
| 32 | Sedang | Gerak dekoratif dapat menahan visibilitas konten | Konten terlihat secara default. Paralaks kecil hanya pada kaligrafi dan berhenti pada reduced motion |
| 33 | Sedang | Mobile tanpa JavaScript kehilangan navigasi utama | Navigasi `noscript` ditambahkan. Isi utama tetap prarender |
| 34 | Sedang | Pencarian beranda berisiko memilih elemen dari bagian lain | Lingkup pencarian dapat dibatasi dengan `data-search-scope` |
| 35 | Sedang | Dokumentasi lama menyebut warna, jumlah halaman, dan status build yang tidak sesuai | README, panduan awal, deployment, lisensi, dan laporan V4 diperbarui. Dokumen lama diberi label arsip |
| 36 | Sedang | Build pass mudah disalahartikan sebagai bukti siap transaksi produksi | `BUILD_REPORT.json` membedakan validasi artefak dan peringatan operasional |
| 37 | Sedang | Penghapusan laporan setelah retensi hanya berjalan saat proses/request aktif | Jadwal purge harian tetap wajib pada deployment. Kebijakan dan panduan operasi menjelaskan batas ini |
| 38 | Sedang | Pembatasan permintaan berada pada memori satu proses | Tetap didokumentasikan sebagai satu worker. Skala banyak worker membutuhkan rate limit bersama |
| 39 | Sedang | Logo wordmark Arab sempat mengikuti font serif warisan | Wordmark dipertahankan konsisten dengan Outfit, sedangkan teks Arab memakai font Arab khusus |
| 40 | Sedang | Kontras kaligrafi dekoratif pada pemeriksaan otomatis sedikit di bawah 3:1 | Opasitas disesuaikan, lalu pemeriksaan aksesibilitas diulang |

## Harga dan keputusan sinkronisasi

Instruksi terbaru pengguna menjadi acuan harga website. Nilai aplikasi sebelumnya dipertahankan sebagai bukti audit, bukan diam-diam dianggap sama.

| Produk | Website V4 sesuai brief | Aplikasi hasil audit sebelumnya | Status |
|---|---:|---:|---|
| Tholib / satu spesialis | Rp49.000 / 1 bulan | Spesialis Rp50.000 / 1 bulan | Harga dan SKU perlu diselaraskan |
| Tematik | Rp149.000 / 3 bulan | Bundle publik disembunyikan | Perlu SKU, daftar cakupan, dan entitlement eksplisit |
| Sultan All-Access | Rp499.000 / 12 bulan | All-Access publik disembunyikan | Perlu SKU, cakupan, batas, dan entitlement eksplisit |
| Tahawwulat | Mengikuti cakupan yang disahkan pada checkout, tidak dipasarkan sebagai paket lama yang berbeda | Rp300.000 / 1 bulan, Rp1.499.000 / 6 bulan, Rp1.999.000 / 12 bulan | Kebijakan inklusi pada Tematik/All-Access perlu ditetapkan |

Sebagian entitlement aplikasi masih berbagi rumpun, misalnya hadits, syarah, dan musthalah. Satu nama kartu tidak selalu berarti satu namespace pembelian yang terisolasi. Menambahkan tiga kartu website tidak membuat backend otomatis mengenali tiga produk baru.

Penyelarasan yang diperlukan sebelum menjual penawaran baru adalah menetapkan ID produk kanonik, daftar asisten yang dibuka, aturan periode kalender, harga server, validasi callback DOKU, idempotensi aktivasi, dan tampilan harga akhir aplikasi. Jangan memperbaikinya hanya dengan mengganti label frontend aplikasi.

## Jumlah asisten dan katalog

Source aplikasi memuat 20 bidang publik dan dua profil ulama yang terkunci, Habib Umar serta Imam Ghazali. Website memenuhi permintaan 21 profil dengan menampilkan 20 bidang dan Habib Umar dalam persiapan. Imam Ghazali tidak dipasarkan sebagai profil aktif tambahan.

Metadata dua puluh modul menjumlahkan 5.370 rekaman `total_kitab`, berbeda dari klaim lama 5.074. Penjumlahan metadata bukan deduplikasi karya, bukan jumlah edisi cetak yang diperiksa, dan bukan bukti bahwa semua sumber aktif di sesi NotebookLM. Karena itu, angka pasti tersebut tidak diterbitkan sebagai metrik pemasaran baru.

Deskripsi hero “ribuan karya” dipertahankan sesuai brief pengguna. Kalimat itu merupakan cakupan koleksi, bukan pernyataan bahwa seluruh kutipan keluaran AI telah dicocokkan dengan cetakan fisik.

## Kebijakan dan paritas bahasa

`public/assets/kebijakan-aplikasi-v1.0.md` memuat seluruh 39 bagian dari empat kelompok kebijakan resmi aplikasi dengan konstanta kontak dan identitas diselesaikan. Salinan sumber Dart disimpan untuk audit. Enam belas artikel website memakai ID, EN, dan AR, termasuk ringkasan ketentuan, privasi, refund, dan adab.

Ringkasan bukan pengganti naskah hukum lengkap yang telah disahkan. Teks EN dan AR merupakan terjemahan ringkasan website, bukan dokumen legal baru yang diklaim telah disetujui penasihat hukum. Klaim kepatuhan GDPR, sertifikasi SOC 2, atau kepatuhan semua yurisdiksi tidak ditambahkan.

Ada inkonsistensi yang masih berasal dari aplikasi: naskah refund versi 1.0 menyebut 30 hari kalender, sedangkan implementasi produk sebelumnya menggunakan bulan kalender. Naskah resmi tidak diubah diam-diam. Website menjelaskan periode penawaran terbaru dan meminta kesesuaian tanggal akhir pada checkout. Pembaruan resmi dokumen aplikasi perlu menyelesaikan perbedaan ini.

Paritas kamus diterapkan pada label yang memiliki pasangan kanonik, bukan dengan menyalin semua 532 string aplikasi yang tidak digunakan website. Pemetaan mencakup Beranda, Catatan, Bahasa, Tutup, Ketentuan Layanan, Privasi, Pembayaran dan Pengembalian Dana, Panduan AI, Bantuan/Kontak, pencarian kitab, Tahawwulat, Ruang Telaah, dan Pustaka Marja' Mu'tamad. Nama koleksi dan naskah website baru memiliki terjemahan tersendiri dengan struktur tiga bahasa yang sama.

## Hasil pengujian

Hasil final tersedia pada `docs/BUILD_REPORT.json`, `docs/BROWSER_QA.json`, `docs/verification/build-release.log`, dan `docs/verification/npm-test.log`.

| Pemeriksaan | Cakupan |
|---|---|
| Build produksi | 172 halaman yang dihitung generator, termasuk pemilih bahasa. Ada salinan tambahan `404.html` di root |
| Pemeriksaan statis | 171 halaman lokal ID/EN/AR, 9.882 tautan/aset lokal, metadata, satu H1 per halaman, RTL, kelengkapan terjemahan |
| Integritas arsip | Enam hash jawaban asli dan sepuluh rekaman kutipan |
| Unit/integrasi Node | 16 tes, termasuk harga/periode, status profil, paritas bahasa, kamus, kebijakan, unduhan, dan gerbang build |
| API/penyimpanan Python | 13 tes, termasuk persetujuan, versi kebijakan, validasi, origin, rate limit, idempotensi, dan retensi |
| Browser Chromium | 90 kombinasi dari 3 bahasa, 3 lebar layar (1440, 390, 320), dan 10 jenis halaman |
| Interaksi browser | 12 skenario termasuk pencarian Arab, filter, keadaan kosong, reset, dialog, tema, bahasa, menu RTL, formulir sukses/gagal, arsip, reduced motion, dan tanpa JavaScript |
| Aksesibilitas otomatis | axe-core pada beranda, keanggotaan, dan formulir dalam ketiga bahasa. 9 pemeriksaan selesai dengan 0 pelanggaran otomatis |

Pemeriksaan browser dilakukan dengan server dan database lokal sementara. Skenario kegagalan API dibuat sengaja untuk memastikan pesan tidak hilang dan salinan dapat diunduh. Tidak ada laporan yang dikirim ke pihak luar.

Aksesibilitas otomatis bukan sertifikasi WCAG penuh. Pembaca layar nyata, Safari/iOS, Firefox, proses DOKU produksi, serta instalasi APK pada perangkat fisik belum diuji dalam pekerjaan website ini.

## Review visual

Acuan konsep utama adalah gambar hero `exec-adf1f627-f417-4425-8282-a938d54adbfd.png`. Konsep dipakai untuk arah komposisi, bukan sebagai bukti hasil implementasi. Screenshot hasil browser berada pada `docs/previews/v4/`.

| Aspek yang dibandingkan | Hasil implementasi |
|---|---|
| Komposisi | Hero terpusat, ilustrasi kitab di bawah aksi, kaligrafi dekoratif, tanpa ponsel |
| Hierarki | Eyebrow kecil, H1 besar, tagline, deskripsi dengan dua baris desktop |
| Warna | Kanvas obsidian, teks platinum, emas terbatas pada label dan kaligrafi |
| Identitas | SVG logo asli menggantikan simbol generik dalam konsep |
| Interaksi | CTA, filter, menu, tema, dialog, dan formulir benar-benar berjalan |

Perubahan yang disengaja dari konsep generatif adalah penggunaan logo master, tombol yang lebih tenang, katalog tetap gelap, harga mengikuti instruksi terbaru, dan penghilangan klaim persentase atau ketersediaan yang tidak didukung. Dua konsep sekunder yang menghasilkan bidang putih atau angka promo berbeda tidak dijadikan sumber fakta.

## Batas yang masih terbuka sebelum peluncuran komersial

| Hal | Bukti atau tindakan yang masih diperlukan |
|---|---|
| Sinkronisasi harga | Perubahan SKU, harga server, entitlement, dan layar pembelian aplikasi sesuai tiga paket terbaru |
| Cakupan Tematik dan All-Access | Daftar asisten eksplisit, inklusi/eksklusi Tahawwulat, kuota, dan ketergantungan akun Google |
| Dokumen kebijakan | Penyelesaian 30 hari vs bulan kalender dan pengesahan penawaran terbaru pada dokumen aplikasi |
| Unduhan Android | APK sebenarnya, checksum terukur, tanda tangan rilis, dan pemeriksaan URL publik |
| macOS dan Windows | Artefak distribusi yang terbit. Sampai itu tersedia, tombol unduhan tetap tidak aktif |
| Verifikasi sumber | Edisi/scan, teks pembanding, penelaah, tanggal, dan rekam koreksi per kutipan |
| Hak konten | Bukti hak publikasi untuk edisi, terjemahan, tahkik, dan materi pembanding |
| Identitas pengelola | Identitas legal dan alamat rinci bila diperlukan untuk yurisdiksi penjualan |
| Operasional | HTTPS, proses API, purge terjadwal, backup privat, pemantauan, dan penanganan laporan |

Paket ini menyelesaikan perubahan kode website yang dapat diuji dari bahan tersedia. Status yang belum dapat dibuktikan tetap dinyatakan terbuka agar peluncuran tidak dibangun di atas klaim palsu.
