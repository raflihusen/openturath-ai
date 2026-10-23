# OpenTurath Website V7: Blueprint UX dan Desain

Versi 1.0 · 23 Oktober 2026 · Prototipe: `website/redesign-v7/site/` (sembilan halaman, statis)
Jalankan: `python3 build.py` lalu buka `site/index.html` lewat server (config `openturath-v7-prototype`, port 4180).

## 1. Keputusan desain

| Hal | Keputusan | Alasan |
|:---|:---|:---|
| Arah visual | Bahasa desain terinspirasi antigravity.google, dari prototipe `redesign-antigravity/v4`: hero tengah dengan cincin partikel, judul sangat besar dan rapat, tombol pil, sudut besar (16/24/36/48), bayangan berlapis, penjelajah daftar-kiri kartu-kanan | Pilihan Pemilik |
| Warna | **Monokrom murni** (abu netral Antigravity, tanpa biru). Fokus dan ikon pakai tinta | Aturan Sakral #9 identitas |
| Huruf | Google Sans Flex (UI dan judul), Scheherazade New (teks Arab) | Sesuai prototipe; Arab kitab tetap naskh |
| Logo | Simbol asli OpenTurath dalam kotak 92 px (menggantikan huruf "ت" pada prototipe) | Identitas resmi |
| Tagline | "Menjaga asal, membuka cakrawala." **Tanpa versi Arab** | Keputusan Pemilik (terjemahan Arab dinilai cacat) |
| Mode | Terang, gelap, dan ikut sistem; pilihan tersimpan | Bahasa Antigravity |

Dua perbedaan yang disengaja dari prototipe v4: (1) logo asli, bukan huruf; (2) tidak ada angka korpus, harga, dan klaim "terverifikasi" atau "bukan karangan mesin".

## 2. Audit website yang sekarang (openturath.id)

| Temuan | Dampak |
|:---|:---|
| Halaman beranda setinggi sekitar 12.000 px dengan sembilan bagian; bagian asisten sendiri hampir 3.000 px, bagian verifikasi lebih dari 2.200 px | Pengunjung lelah sebelum sampai ke tombol unduh |
| Pintu masuk `/` hanya pemilih bahasa ("Welcome.") | Satu klik tambahan sebelum melihat produk |
| Hero memakai animasi yang terkait gulir dengan gambar buku | Terasa berat, tidak menjelaskan produk |
| Bahasa kaku dan berbahasa Inggris campur: "AI for Islamic Scholarship", "Source First", "Infrastruktur Riset", "telaah" berulang | Tidak selaras dengan suara OpenTurath; kata "telaah" dilarang |
| Judul menjanjikan "Sumber yang Terverifikasi" dan memajang angka persis (kitab, kata, rekaman) | Klaim yang sulit dipertanggungjawabkan; Pemilik meminta tanpa angka |
| Tidak ada ekosistem (Maktabah, Manuskrip, Akademi), tidak ada cerita perintis | Visi besar tidak tersampaikan |
| Tidak ada demo jawaban yang bisa dicoba | Nilai produk harus dibayangkan, bukan dilihat |
| Penyedia pembayaran dan harga tertulis di beranda | Mudah usang dan berbeda dari aplikasi |

## 3. Sasaran

1. Dalam **lima detik** pengunjung paham: ini AI Islami berbasis turath, setiap jawaban punya rujukan, dan ia bukan pengganti guru.
2. Dalam **satu menit** pengunjung melihat jawaban nyata (demo), lalu mengunduh.
3. Pengunjung yang skeptis (ulama, guru) menemukan jawaban atas kekhawatirannya tanpa mencari: Pedoman keilmuan dan batas yang jujur.

Metrik yang diusulkan: klik "Unduh" per kunjungan; interaksi demo; kedalaman gulir hingga bagian unduh; klik Pedoman keilmuan; laporan kesalahan terkirim.

## 4. Pengunjung dan kebutuhannya

| Pengunjung | Mencari | Jalur terpendek |
|:---|:---|:---|
| Santri dan pemula | "Apakah ini bisa membantu saya membaca kitab?" | Hero, demo, unduh |
| Mahasiswa dan peneliti | Bidang, kitab, metadata, rujukan | Bidang (pencarian), cara kerja |
| Pengajar, penceramah, khatib | Apakah dalilnya bisa diperiksa | Demo, cara kerja, pedoman |
| Ulama dan guru (skeptis) | Apakah ini fatwa, siapa di baliknya, bagaimana kurasinya | Pedoman keilmuan, tentang |
| Mitra dan media | Siapa kami, ekosistem, cara menyebut | Tentang, ekosistem, kontak |
| Pengguna lama | Unduh ulang, bantuan, lapor kesalahan | Unduh, bantuan |

## 5. Arsitektur informasi

```
Beranda
├─ Bidang ▾ (panel tarik-turun per rumpun)  → Bidang ilmu (daftar + pencarian)
│                                             └─ Fikih Tahawwulat (halaman khusus)
├─ Cara kerja
├─ Pedoman keilmuan  (wasathiyyah syar'iyyah, tiga lapis, adab)
├─ Ekosistem         (OpenTurath AI, Maktabah, AI Manuskrip, Akademi)
├─ Tentang           (perintis, tonggak, nilai)
├─ Unduh             (Android, macOS, Windows; platform terdeteksi)
└─ Bantuan           (FAQ, lapor kesalahan, kontak, kebijakan)
```

Navigasi utama: Bidang ▾ · Cara kerja · Pedoman keilmuan · Ekosistem · Tentang, dengan tombol **Unduh** selalu terlihat (menjadi ikon pada ponsel). Pil pengumuman di atas menaut ke Unduh dan menandai rilis. Footer memuat empat kolom, kontak, dan pernyataan layanan mandiri.

## 6. Alur pengguna

**A. Pembaca baru → unduh**
1. Masuk ke beranda → membaca janji (hero) dan tiga penanda (ditinjau ulama, wasathiyyah syar'iyyah, bukan pengganti guru).
2. Menggulir ke "Jawaban yang selalu menunjuk ke kitabnya" → memilih satu dari tiga pertanyaan → melihat penjelasan, ibarah Arab, dan rujukan.
3. Menggulir ke Bidang → memilih rumpun → membaca deskripsi asisten → "Buka di aplikasi".
4. Bagian Unduh: platform perangkatnya sudah ditandai → mengunduh.

**B. Guru yang skeptis → percaya**
1. Beranda → membaca "Bukan pengganti guru" pada hero → bagian Pagar keilmuan.
2. Pedoman keilmuan → membaca ukuran kurasi dan batas.
3. Tentang → mengetahui siapa perintis dan siapa gurunya.
4. Bantuan → lapor kesalahan bila menemukan sesuatu.

**C. Peneliti → bidang tertentu**
1. Menu Bidang ▾ → rumpun → halaman Bidang dengan filter aktif (alamat `bidang.html#hadis`).
2. Pencarian "Minhajuth Thalibin" → asisten yang memuatnya → deskripsi dan kegunaan.
3. Cara kerja → memahami rujukan dan batasnya → unduh.

**D. Pengguna lama**
Unduh (pilih platform) atau Bantuan (FAQ, formulir laporan yang membuka surel terisi).

## 7. Spesifikasi beranda

| # | Bagian | Tujuan | Isi dan interaksi |
|:-:|:---|:---|:---|
| 1 | Pil pengumuman + navigasi | Orientasi dan pembaruan | Rilis perdana, menaut ke Unduh |
| 2 | **Hero** | Janji dalam lima detik | Simbol dalam kotak, cincin partikel yang bereaksi pada kursor, tagline, kalimat penjelas, dua tombol, tiga penanda |
| 3 | Mengapa OpenTurath | Menamai masalah | Tiga kartu: bahasa dan istilah, mencari ibarah, AI tanpa sandaran; masing-masing dengan jawaban satu kalimat |
| 4 | **Demo jawaban** | Bukti, bukan klaim | Penjelajah: tiga pertanyaan di kiri, kartu jawaban di kanan (penjelasan, ibarah Arab, rujukan). Isi dari materi Pengantar Fikih Tahawwulat di aplikasi |
| 5 | Untuk siapa | Membuat pengunjung merasa dikenali | Tiga kartu pembaca dengan contoh pertanyaan |
| 6 | **Bidang ilmu** | Menunjukkan cakupan tanpa angka | Chip rumpun, kartu asisten, panel rincian dengan "Gunakan untuk" |
| 7 | **Fikih Tahawwulat** | Pembeda dan cerita logo | Panel gelap: logo yang menyala per bagian (Islam, Iman, Ihsan, Tahawwulat) mengikuti sorotan daftar; lima cabang |
| 8 | Pagar keilmuan | Kepercayaan | Empat kartu + pernyataan "AI hanyalah alat. Gurunya tetap guru." |
| 9 | Ekosistem | Visi besar | Empat lini dengan penanda status |
| 10 | Perintis | Wajah manusia | Pil "Dibuat oleh pelajar, untuk para pelajar." + dua kalimat |
| 11 | **Unduh** | Konversi | Panel gelap, tiga platform, platform perangkat ditandai |
| 12 | FAQ | Menjawab keraguan terakhir | Tujuh pertanyaan, `<details>` |

Urutan mengikuti pola Antigravity: janji → bukti → cakupan → kepercayaan → ajakan. Tinggi beranda kini sekitar 11.000 px pada 1440 lebar (dari 12.157), tetapi setiap bagian satu tugas, dan demo serta bidang hanya menampilkan satu kelompok pada satu waktu.

## 8. Halaman lain

| Halaman | Fungsi | Isi utama |
|:---|:---|:---|
| Bidang ilmu | Direktori | Chip "Semua" dan rumpun, pencarian teks, kartu, panel rincian; alamat `#rumpun` membuka filter |
| Fikih Tahawwulat | Halaman unggulan | Empat rukun, ibarah dan sumber, tabel lima asisten dengan contoh pertanyaan, 15 bab video pengantar |
| Cara kerja | Mengajarkan alur | Enam langkah, enam prinsip korpus, batas yang jujur |
| Pedoman keilmuan | Kepercayaan | Wasathiyyah syar'iyyah, tiga lapis kurasi, dua penjagaan, enam adab (dari `adab.json`), tautan lapor |
| Ekosistem | Visi | Empat lini lengkap dengan poin dan status |
| Tentang | Cerita | Perintis, tonggak (2023, 2023–2026, 7 Mei 2026, 23 Oktober 2026), enam nilai |
| Unduh | Konversi | Tiga platform dengan langkah pemasangan, tiga langkah pertama |
| Bantuan | Dukungan | FAQ, formulir lapor kesalahan (membuka surel terisi), kontak, kebijakan |

## 9. Sistem desain web

**Token.** Abu netral Antigravity: terang `#FFFFFF / #F8F9FC / #EFF2F7`, teks `#121317`; gelap `#121317 / #18191D / #212226`, teks `#F8F9FC`. Sudut `8/16/24/36/48 px`, pil `9999`. Bayangan berlapis tiga. Kontras teks utama di atas permukaan melampaui 15 : 1 pada kedua mode.

**Komponen.** Pil pengumuman; navigasi 56 px dengan panel tarik-turun; tombol primer, tonal, terbalik, garis terbalik; penjelajah daftar-kartu; kartu kasus; chip rumpun; panel terbalik (`.band`) dengan sudut 48; pernyataan; kartu ekosistem; kartu platform; FAQ; garis waktu; formulir.

**Gerak.** Muncul perlahan saat terlihat (satu kali), cincin partikel (berhenti di luar layar, statis bila "kurangi gerak"), logo menyala bergantian satu kali saat panel Fikih Tahawwulat terlihat, kartu terangkat 3 px saat disorot. Semua gerak mati bila pengguna memilih kurangi gerak.

**Aksesibilitas.** Tautan lewati-ke-konten; landmark; tab dan panel memakai peran ARIA dan panah papan ketik; fokus terlihat; target sentuh minimal 40 px; konten terbaca tanpa JavaScript (detail bidang dan demo tampil semua pada mode tanpa JS); RTL siap lewat properti logis CSS.

**Performa.** Tanpa permintaan pihak ketiga, tanpa gambar raster; CSS 30 KB, JS 9 KB. Font terbesar adalah Scheherazade New (327 KB reguler, 589 KB tebal); **perlu subset** sebelum produksi.

## 10. Aturan salinan di situs

- Tanpa angka korpus (kitab, kata, rekaman, asisten); gunakan "puluhan" bila perlu.
- Tanpa harga dan penyedia pembayaran di beranda. Cukup "akses per modul, perpanjangan manual, tanpa auto-debit".
- Tanpa klaim "terverifikasi", "dijamin", "100 persen", "bukan karangan mesin".
- Tanpa kata "telaah" dan "ruang kajian"; tanpa menyebut nama produk atau model AI pihak lain.
- Penyebutan Google: "memanfaatkan teknologi Google", layanan mandiri, tidak berafiliasi.
- Tanpa teks Arab pada tagline. Teks Arab hanya untuk nama bidang, ibarah kitab, dan istilah (Scheherazade New).

## 11. Teknis dan integrasi

- **Prototipe:** `build.py` membangun sembilan HTML dari data aplikasi (`info_ai.json`, `pengantar_tahawwulat.json`) dan `website/content/adab.json`; aset di `site/assets`.
- **Integrasi ke website V6 (172 halaman, tiga bahasa, `src/*.mjs`):** pindahkan token dan komponen CSS ke `public/assets`, ubah `home.mjs`, `membership.mjs`, `copy.mjs` agar memakai markup baru, pertahankan `catalog.json` sebagai sumber data, dan jalankan tes yang ada (`npm test`, `npm run test:browser`). Dilakukan setelah desain dan salinan disetujui.
- **Bahasa:** ID lengkap. EN dan AR belum diterjemahkan; pemilih bahasa menandainya "Segera". Layout sudah memakai properti logis sehingga RTL tidak memerlukan pekerjaan ulang. Salinan Arab sebaiknya ditinjau guru atau ahli bahasa Arab.
- **SEO:** judul dan deskripsi per halaman, Open Graph dasar. Belum ada: JSON-LD, sitemap, kartu sosial gambar, hreflang.
- **Peristiwa analitik yang diusulkan:** `download_click{platform}`, `demo_select{id}`, `field_select{id}`, `field_search`, `report_submit`, `theme_toggle`.

## 12. Yang sudah diuji dan yang belum

Sudah (Chrome): sembilan halaman pada 1440 px, terang dan gelap; beranda pada 390 px (tanpa luapan horizontal, menu ponsel, panel Fikih Tahawwulat); dropdown Bidang, tab demo, filter rumpun, tombol tema; tanpa galat konsol.
Belum: Safari dan Firefox, tablet, pembaca layar, keyboard-only menyeluruh, kinerja (Lighthouse), RTL nyata, cetak.

## 13. Butir terbuka untuk Pemilik

1. Tautan unduh resmi tiap platform (prototipe menaut ke halaman unduh yang ada) dan nomor versi.
2. Apakah akses dan harga ditampilkan di web, dan penyedia pembayarannya.
3. Apakah ada kebutuhan Masuk di web (sekarang tidak ada; akun hanya di aplikasi).
4. Lisensi Google Sans Flex untuk produksi (prototipe memakai berkas dari paket yang Anda berikan).
5. Salinan Inggris dan Arab, dan peninjau bahasa Arabnya.
6. Foto atau tangkapan layar aplikasi asli untuk menggantikan mockup demo.
7. Kebijakan kurasi pada halaman Pedoman (tiga lapis): konfirmasi sesuai praktik.
8. Apakah halaman Maktabah, Manuskrip, dan Akademi cukup di halaman Ekosistem, atau ingin halaman sendiri saat dirilis.
