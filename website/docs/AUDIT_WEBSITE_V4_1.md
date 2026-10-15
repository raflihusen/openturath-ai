# Audit Lanjutan dan Revisi OpenTurath Website V4.1

20 September 2026 · Acuan: kode V4, arahan terbaru pengguna, metadata aplikasi, kamus ID/EN/AR, dan gambar referensi hero.

Revisi ini memperbaiki copy, hierarki visual, metadata khazanah, alur konversi, serta unduhan website. Beranda kini menampilkan ringkasan angka langsung setelah hero, 21 profil dengan deskripsi tersendiri, bento responsif, satu banner keanggotaan, dan sepuluh FAQ interaktif. Hasil build mencakup ID, EN, serta AR dengan RTL.

Paket dapat dibangun dan diuji. Distribusi Android belum aktif karena APK asli tidak terdapat dalam bahan yang diterima. Pemetaan harga/SKU backend aplikasi juga masih berstatus terbuka, sebagaimana tercatat pada audit sebelumnya. Keduanya tidak diklaim selesai oleh kelulusan build website.

## 1. Blind spot yang ditemukan kembali pada V4

| No. | Lokasi | Bukti dan dampak | Perbaikan V4.1 |
|---|---|---|---|
| 1 | `content/catalog.json` | Hanya 9 deskripsi unik untuk 21 profil di setiap bahasa. Delapan kartu fikih, tiga hadits, dua bahasa/bibliografi, dua Al-Qur’an, dan dua sejarah/biografi berbagi teks identik. | 21 deskripsi berbeda per bahasa, dengan fokus disiplin dan karya rujukan yang relevan. Regresi duplikasi diuji otomatis. |
| 2 | Nama Arab kartu | Mahkota Arab panjang hingga beberapa baris, membuat kartu sulit dipindai dan menambah ruang kosong. | Nama Arab ringkas diambil dari `nama_arab` metadata modul; penjelasan tetap pada deskripsi lokal. |
| 3 | Statistik beranda | Angka riil tidak ditampilkan, meskipun snapshot modul telah tersedia. | Enam metrik hasil agregasi muncul tepat setelah hero, sebelum metode. |
| 4 | Versi metadata | Brief memuat angka lama dan baru: Syafi’i 87/103, Hadits 1.173/1.141, Tarikh 345/499. | Hitungan mengikuti `metadata_modul_lengkap.json` terbaru. Snapshot training hanya menjadi sumber jumlah partisi. |
| 5 | Satuan Hadits | Angka 532.640 pernah disebut sebagai jumlah hadits, sementara JSON menamainya `total_halaman`. | Ditampilkan sebagai 532.640 halaman. Tidak mengubah satuan untuk memperbesar klaim. |
| 6 | Identitas modul | ID aplikasi, slug website, dan kunci metadata tidak selalu sama. | `appAgentId`, slug, dan `metadataKey` dipisahkan. Alias Bahasa Arab, Tarikh, dan Thabaqat tetap terpetakan. |
| 7 | Sinkronisasi angka | Menyalin angka ke beberapa template membuat nilai mudah berbeda pada revisi berikutnya. | Kartu dan ringkasan memakai `src/metadata.mjs`. Build menolak angka berbeda dari snapshot, modul ganda, periode yang berubah, atau terjemahan periode hilang. |
| 8 | Nada beranda | Peringatan berulang mendominasi penjelasan metode, arsip, katalog, dan keanggotaan. | Copy berfokus pada manfaat dan metodologi. Keterangan edisi, layanan pihak ketiga, dan pemeriksaan sumber tersedia dalam konteks FAQ serta halaman detail. |
| 9 | Hero | Ukuran judul, tagline sans, CTA kecil, dan kaligrafi datar belum mengikuti arahan serif serta emas berlapis. | Newsreader pada H1/H2, Outfit pada paragraf, eyebrow 13 px, pil CTA, radial mask kitab, gradien dan tekstur CSS emas, serta paralaks dua lapisan. |
| 10 | Mobile | Tombol unduh navbar disembunyikan pada lebar kecil. | Tombol ikon unduh tetap terlihat dengan nama aksesibel dan target halaman unduh lokal. Diuji pada viewport ponsel. |
| 11 | Bento | Semua kartu seragam dan minim metadata. | Kartu unggulan setengah lebar, kartu standar sepertiga lebar, Tahawwulat dua pertiga lebar dengan bingkai ganda; layout mengecil ke dua lalu satu kolom. Metadata memakai kapsul kecil dan sorotan pointer. |
| 12 | Harga | Tiga kartu paket menambah beban keputusan dan tidak mengikuti arahan terbaru. | Satu banner mulai Rp 49.000 per bulan di beranda dan halaman akses. Definisi paket tetap tersimpan sebagai data konfigurasi. |
| 13 | FAQ | Lima judul pernyataan, bukan pertanyaan pengguna. | Sepuluh tanya-jawab ID/EN/AR, native `<details>` / `<summary>`, keyboard Enter/Space, indikator emas, transisi, dan dukungan tanpa JavaScript. |
| 14 | APK | Konfigurasi menyebut URL, ukuran, dan hash, tetapi file fisiknya tidak ditemukan dalam dua ZIP maupun sumber yang tersedia. | Mode `website-only` eksplisit, tanpa tautan biner aktif. Hash yang tidak dapat dicocokkan ke byte dihapus dari publikasi rilis ini. |
| 15 | Gerbang rilis | Validasi konfigurasi saja tidak menjamin APK lokal benar-benar ada. | Build memeriksa keberadaan berkas, SHA-256, ukuran byte, serta header ZIP untuk setiap APK aktif. URL APK aktif harus berasal dari origin yang dibundel. |
| 16 | Memasukkan APK | Belum ada alur untuk memperbarui file dan metadata integritas secara bersamaan. | `npm run release:apk -- /path/ke/openturath-v1.0.51.apk` memeriksa struktur APK, menyalin file, menghitung hash/ukuran, lalu mengaktifkan rilis. |
| 17 | Ketersediaan platform | iOS disebut dalam rencana tetapi belum dicantumkan konsisten pada halaman unduh. | Android menampilkan status berkas; macOS, Windows, dan iOS berstatus persiapan tanpa tautan unduh aktif. |
| 18 | Gerak dan aksesibilitas | Gerak baru berpotensi menyembunyikan isi saat JavaScript/observer tidak berjalan. | Isi terlihat secara default, reveal memiliki mekanisme pemulihan, perubahan reduced motion ditangani langsung, dan input sentuh tidak menerima paralaks pointer. |
| 19 | Pengujian kontras | Pengukuran di tengah transisi opacity menghasilkan temuan sementara yang tidak menggambarkan tampilan akhir. | axe dijalankan pada render stabil dengan reduced motion. Gerak diperiksa terpisah; palet dan isi tetap diperiksa tanpa mengecualikan komponen bermasalah. |
| 20 | Dokumentasi | README dan laporan sebelumnya masih menggambarkan tiga kartu harga, angka tersembunyi, serta hasil QA lama. | README, panduan awal, laporan V4.1, log, dan screenshot diperbarui. Dokumen sebelumnya ditandai sebagai riwayat. |

Laporan `AUDIT_WEBSITE_V4.md` tetap disertakan untuk 40 temuan audit sebelumnya, termasuk API laporan, retensi, hak sumber, kontrak pembayaran, serta arsip Q001. Keputusan tampilan terbaru mengikuti dokumen V4.1 ini.

## 2. Sumber data dan keputusan angka

| Sumber | Fungsi |
|---|---|
| `content/metadata/metadata_modul_lengkap.json` | Jumlah kitab, jilid, halaman, kata, periode, dan muhadharah |
| `content/metadata/metadata_training_seluruh_ai.json` | Jumlah partisi NotebookLM per modul; angka kitab lama di file ini tidak dicampur dengan snapshot modul |
| `content/catalog.json` | Identitas, status, copy trilingual, metadata terstruktur, dan kunci pemetaan |
| `docs/Kamus_OpenTurath_ID_EN_AR.csv` | Kamus lengkap dari audit aplikasi; 13 label bersama tetap diuji terhadap pemetaan kanonik |
| `public/assets/kebijakan-aplikasi-v1.0.md` | Naskah resmi aplikasi, versi 1.0, 13 September 2026, 39 bagian |
| `content/evidence.json` | Sepuluh rekaman kutipan arsip Q001 beserta statusnya |

Angka ini merupakan akumulasi rekaman metadata modul. Audit tidak mengubahnya menjadi klaim deduplikasi semua judul lintas disiplin atau bukti bahwa setiap halaman fisik telah diperiksa ulang.

| Metrik | Total hasil hitung | Tampilan ringkas |
|---|---:|---|
| Disiplin aktif | 20 | 20 |
| Kitab | 5.370 | 5.370 |
| Jilid | 11.901+ | 11.901+ |
| Halaman | 4.182.803 | 4,1+ Juta, dengan angka lengkap di bawah |
| Kata | 1.148.410.539 | 1,14+ Miliar, dengan angka lengkap di bawah |
| Partisi | 2.876 | 2.876 |

Tanda plus pada jilid mempertahankan sifat batas bawah pada data seperti `400+`, `1.500+`, dan `450+`. Ringkasan juta/miliar menggunakan batas bawah dengan tanda plus, sehingga tidak menyatakan angka bulat sebagai hitungan persis. Format angka mengikuti lokal ID, EN, dan AR.

### Rincian disiplin

| Disiplin | Kitab | Jilid | Halaman | Kata | Partisi |
|---|---:|---:|---:|---:|---:|
| Fikih Syafi'i | 103 | 400+ | 170.391 | 71.627.898 | 241 |
| Kutubus Sunnah & Matan Hadits | 1.141 | 1.500+ | 532.640 | 105.700.587 | 233 |
| Ushul Fikih 4 Mazhab | 136 | 320+ | 115.000 | 36.522.580 | 121 |
| Bahasa Arab & Ilmu Alat | 866 | 1.981 | 610.000 | 148.304.518 | 300 |
| Tafsir & 'Ulumul Qur'an | 123 | 450+ | 140.000 | 78.862.654 | 183 |
| Fikih Tahawwulat | 58 | 58 | 12.500 | 5.644.146 | 71 |
| Tarikh & Sirah Nabawiyyah | 499 | 1.374 | 480.000 | 136.531.222 | 300 |
| Fikih Muqaran & Siyasah | 189 | 329 | 135.000 | 27.585.932 | 61 |
| Fatawa & Masail Fiqhiyyah | 221 | 324 | 57.419 | 19.387.054 | 101 |
| Syarah Hadits Nabawi | 202 | 1.007 | 420.000 | 122.463.779 | 300 |
| Fikih Hanafi | 85 | 288 | 110.000 | 39.300.555 | 100 |
| Fikih Maliki | 86 | 339 | 164.214 | 48.363.521 | 120 |
| Fikih Hanbali | 95 | 338 | 163.639 | 34.626.811 | 100 |
| Tasawwuf & Adzkar | 248 | 317 | 95.000 | 18.697.388 | 61 |
| Tajwid & Qira'at | 130 | 182 | 45.000 | 13.714.766 | 50 |
| Qawa'id Fiqhiyyah | 44 | 85 | 32.000 | 8.187.717 | 30 |
| 'Ulumul Hadits & Musthalah | 393 | 748 | 285.000 | 63.241.925 | 137 |
| Aqidah & Ushuluddin | 173 | 249 | 85.000 | 19.175.915 | 43 |
| Thabaqat & Rijalul Hadits | 492 | 1.348 | 420.000 | 130.494.140 | 279 |
| Bibliografi & Tahqiq Turath | 86 | 264 | 110.000 | 19.977.431 | 45 |

Khazanah Habib Umar menjadi profil ke-21 dengan status persiapan. Angka modul tidak direkayasa untuk profil ini. Imam Ghazali tidak ditambahkan sebagai asisten aktif ke-22.

## 3. Copy dan FAQ

Deskripsi disiplin membedakan fikih Syafi’i, Hanafi, Maliki, Hanbali, ushul, qawa’id, fikih muqaran, fatawa, matan hadits, syarah, musthalah, serta disiplin lainnya. Nama karya dipakai pada konteks yang sesuai, misalnya Al-Umm dan Tuhfatul Muhtaj pada Syafi’i, Al-Hidayah dan Raddul Muhtar pada Hanafi, serta Fathul Bari dan Syarah Shahih Muslim pada syarah hadits.

FAQ menjawab sepuluh kebutuhan:

1. Kedudukan khadim terhadap guru dan talaqqi.
2. Penelusuran teks Arab dan proses verifikasi.
3. Perbedaan halaman antar-edisi dan PDF.
4. Kitab rujukan menurut disiplin.
5. Harga awal, pembayaran DOKU, dan perpanjangan manual.
6. Penyimpanan Catatan lokal serta perbedaannya dari percakapan NotebookLM.
7. Status Khazanah Habib Umar.
8. Ketersediaan platform.
9. Prosedur dan tenggat tinjauan refund.
10. Kebutuhan akun Google untuk percakapan NotebookLM.

Bahasa beranda dibuat percaya diri tanpa menambahkan klaim nol halusinasi. Arsip Q001 menampilkan ibarah dan koordinat dari keluaran asli, dengan rekam pemeriksaan tetap dapat dibuka. Tidak ada scan edisi, penelaah, tanggal pencocokan, atau skor akurasi baru yang dibuat tanpa bukti.

## 4. Keputusan visual dan interaksi

| Acuan | Implementasi dan alasan |
|---|---|
| Hero pada gambar pengguna | Komposisi terpusat, buku di bawah CTA, kaligrafi di belakang, H1 serif, tagline serif, paragraf sans dua baris pada desktop 1440 px |
| Palet terbaru | Kanvas `#0a0908` / `#12110f`, teks platinum, emas `#c5a059`; tidak memakai aksen biru Apple |
| Kaligrafi foil | Teks Arab hidup memakai Scheherazade New, gradien emas dan tekstur CSS ringan. Animasi napas delapan detik memakai opacity |
| Ilustrasi | `scholarly-books.webp` yang diberikan, dengan radial mask; tidak menambah mockup ponsel |
| Identitas | Logo master OpenTurath dari sumber dipertahankan. Simbol dekoratif pada konsep bukan pengganti logo resmi |
| Bento | Lebar berirama dipilih agar deskripsi tiga bahasa terbaca dan urutan DOM tetap mengikuti modul. Kartu pencarian tidak ditata ulang dengan `dense` |
| Spotlight | Gradien radial dipindahkan dengan transform sesuai posisi pointer, sehingga tidak menganimasikan seluruh background tiap frame |
| Reveal | Opacity dan translate, 0,7 detik. Blur tidak dianimasikan agar memenuhi arahan akhir penggunaan transform/opacity |
| FAQ | Perubahan layout native dipadukan dengan transisi posisi FLIP dan fade jawaban. Tidak menganimasikan tinggi pada setiap frame |
| Reduced motion | Paralaks, napas, shimmer, dan reveal gerak dihentikan; isi dan kontrol tetap tersedia |
| CTA | Hero mempertahankan “Jelajahi khazanah” serta “Pelajari metodenya” sesuai master prompt terakhir. Unduh selalu tersedia di navbar mobile dengan label aksesibel |
| Banner akses | Satu bingkai emas, harga awal, metode pembayaran, perpanjangan manual, dan tautan refund; tidak memuat tiga kartu paket |

Dua konsep generatif tambahan digunakan untuk menilai komposisi bento dan banner/FAQ. Ornamen berlebihan, foto kitab tambahan, serta kalimat yang tidak terdapat dalam sumber tidak disalin ke produk. Screenshot dalam `docs/previews/v4/` adalah hasil browser dari kode yang diserahkan.

## 5. APK dan kesiapan transaksi

Berkas APK tidak ditemukan pada `openturath_ai_audit_terakhir(1).zip`, ZIP website yang diterima, folder sumber aplikasi, maupun folder website. Path `/Users/apple/Downloads/...` dalam pesan pengguna bukan filesystem yang tersedia pada sesi pengerjaan ini.

Konfigurasi rilis secara terbuka memakai:

```json
"distribution": {
  "mode": "website-only",
  "reason": "awaiting-release-artifact"
}
```

Mode ini hanya valid jika tidak ada unduhan aktif. Build aplikasi aktif tetap memerlukan artefak fisik yang cocok dengan hash dan ukuran konfigurasi. Mode informasi tidak digunakan untuk menyamarkan tautan unduh yang rusak.

Setelah APK asli diberikan:

```sh
npm run release:apk -- /path/ke/openturath-v1.0.51.apk
npm test
npm run build:release
```

Pendaftaran memeriksa container ZIP, `AndroidManifest.xml`, `classes.dex`, dan integritas entri. Versi di dalam manifest serta sertifikat penandatangan perlu dicocokkan dalam proses rilis Android. Skrip tidak mengklaim memverifikasi penandatangan hanya dari nama file.

Harga publik website mengikuti arahan Rp49.000 per bulan. Backend yang diaudit sebelumnya memiliki harga spesialis Rp50.000 dan skema Tahawwulat terpisah; Tematik/All-Access juga memerlukan pemetaan entitlement. Data tersebut tetap tercatat di `content/app-parity.json`. Website ini tidak menerbitkan checkout baru atau mengubah harga server aplikasi.

SLA refund mempertahankan naskah resmi: tinjauan paling lambat tujuh hari kerja setelah data lengkap, disusul pemrosesan paling lambat tujuh hari kerja berikutnya jika disetujui. Situs tidak menjanjikan dana pasti diterima tujuh hari sejak laporan pertama. Perbedaan 30 hari kalender dan bulan kalender dalam dokumen aplikasi sebelumnya masih memerlukan penyelesaian pada sumber resminya.

## 6. Hasil validasi

Hasil akhir dicatat pada `docs/QA_V4_1.md`, `docs/BUILD_REPORT.json`, `docs/BROWSER_QA.json`, `docs/MOTION_QA.json`, dan log di `docs/verification/`.

Build memeriksa 172 halaman yang dihitung generator, 171 halaman lokal tiga bahasa, 9.873 tautan/aset lokal, satu H1 per halaman, metadata, enam hash arsip jawaban, serta sepuluh rekaman kutipan. Pengujian API memakai database sementara. Tidak ada transaksi produksi atau laporan ke pihak luar yang dilakukan.

Pemeriksaan Chromium mencakup lebar 1440, 390, dan 320 px pada sepuluh jenis halaman dalam tiga bahasa. axe memeriksa beranda, keanggotaan, dan formulir di ID, EN, serta AR. Pengujian otomatis ini bukan pengganti pemeriksaan manual semua pembaca layar atau engine browser.

## 7. Berkas utama yang diserahkan

`src/home.mjs`, `public/assets/immersive.css`, `src/copy.mjs`, `src/articles.mjs`, dan `site.config.json` diperbarui lengkap. Perubahan pendukung meliputi renderer, halaman, komponen keanggotaan, formatter/validator metadata, interaksi motion, integritas APK, pengujian, serta dokumentasi.

ZIP memuat source yang dapat dijalankan, `dist/`, data, font lokal dan lisensinya, arsip, checksum paket, serta bukti hasil browser. Kode inti juga disediakan sebagai satu dokumen agar dapat ditinjau tanpa membongkar semua folder.
