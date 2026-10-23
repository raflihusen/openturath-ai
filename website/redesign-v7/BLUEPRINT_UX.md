# OpenTurath Website V7.1: Blueprint UX, Audit, dan Desain

Versi 1.1 · 23 Oktober 2026 · Prototipe: `website/redesign-v7/site/` (sembilan halaman × tiga bahasa)
Jalankan: `python3 build.py` lalu buka lewat server (config `openturath-v7-prototype`, port 4180).

## 1. Keputusan desain

| Hal | Keputusan |
|:---|:---|
| Arah visual | Bahasa desain terinspirasi antigravity.google (prototipe `redesign-antigravity/v4`): tipografi Google Sans Flex yang besar dan rapat, tombol pil, sudut besar, bayangan berlapis, penjelajah daftar-kiri kartu-kanan, panel terbalik |
| Warna | Monokrom murni (Aturan Sakral #9). Biru dan hijau pada prototipe v4 diganti tinta |
| Logo | Simbol asli OpenTurath (bukan huruf "ت") |
| Identitas visual hero | **Lengkung bersarang**: enam lengkung runcing (bentuk gerbang pada logo) yang melebar seperti cakrawala, melingkupi isi hero dengan logo sebagai batu kunci di puncak. Di sepanjang lengkung mengalir judul kitab beraksara Arab (Al-Umm, Al-Majmu', Tuhfatul Muhtaj, Fathul Bari, Ihya' Ulumiddin, dan lainnya) seperti catatan tepi naskah. Menggantikan titik-titik partikel. Lengkung bergerak halus mengikuti kursor |
| Tiga bahasa | Indonesia, Inggris, Arab (RTL penuh) |
| Tagline | Indonesia: "Menjaga asal, membuka cakrawala." Inggris: "Rooted in origins. Open to new horizons." **Arab: tidak ada** (dibatalkan Pemilik). Halaman Arab memakai judul deskriptif "ذكاء اصطناعي إسلامي قائم على التراث" sampai Pemilik menetapkan tagline Arab |
| Perataan | Pasangan Arab + Latin (nama bidang, lima cabang, rukun) **diratakan tengah**. Paragraf penjelas tetap rata awal baca |

## 2. Audit website lama (openturath.id)

Beranda sembilan bagian dan hampir 12.000 px; bagian asisten sendiri hampir 3.000 px. Pintu masuk hanya pemilih bahasa. Hero memakai animasi terkait gulir. Bahasa campur Inggris dan kaku ("Source First", "Infrastruktur Riset"), "telaah" berulang. Klaim "terverifikasi" dan angka persis. Tidak ada demo jawaban, ekosistem, atau cerita perintis.

## 3. Audit blind spot prototipe V7

### 3.1 Sudah ditemukan dan diperbaiki pada putaran ini
| Temuan | Perbaikan |
|:---|:---|
| Titik-titik partikel tidak mewakili identitas | Lengkung bersarang + judul kitab (bagian 1) |
| Pasangan Arab dan Indonesia rata kiri | Diratakan tengah pada kartu bidang, panel rincian, lima cabang, tabel asisten |
| "فِقْهُ التَّحَوُّلَاتِ" dengan harakat membuat ligatur lam-alif berantakan | Judul memakai aksara polos "فقه التحولات", sama seperti data aplikasi |
| Rukun keempat tidak dijelaskan | Ditambah: yang tetap (Islam, Iman, Ihsan) dan yang berubah (Fikih Tahawwulat); **dua tugas rukun keempat** (memperbarui bahasa dakwah; menjaga ilmu-ilmu yang tetap dari kekacauan perubahan, menjaga kehormatan keadilan dan sanad); definisi. Sumber: An-Nubdzah ash-Shughra hlm. 13, 14, 17 |
| Lima cabang tidak jelas maksudnya | Judul "Lima cabang AI Fikih Tahawwulat", arti nama (sang pentahkik, penjelasan, sang penguji, arsip ceramah, penyusun khutbah), tugas satu kalimat, contoh pertanyaan |
| Hanya satu bahasa | ID, EN, AR; folder `id/ en/ ar/`; pemilih bahasa yang benar-benar berpindah halaman; `hreflang`, canonical, sitemap; huruf Cairo untuk UI Arab; jarak huruf nol pada Arab agar sambungan huruf tidak rusak; tata letak cermin penuh |
| Halaman Cara kerja membuka rincian jalur data ("basis data kitab resmi", "pemeriksaan otomatis") | Diganti pernyataan umum yang tidak membuka mekanisme dan sumber |
| Tautan kebijakan hanya jangkar | Menaut ke halaman kebijakan yang sudah tayang di openturath.id (ketentuan, privasi, langganan, sumber dan hak cipta, penghapusan akun, keamanan) |
| Tidak ada momen kepercayaan | Ditambah: "Diumumkan di Universitas Al-Wasatiyah, Hadramaut, 7 Mei 2026, di hadapan para ulama" pada bagian perintis |
| Kekurangan aset teknis | Ditambah: gambar Open Graph, favicon, `sitemap.xml`, `robots.txt`, `404.html`, pengalih bahasa di akar |

### 3.2 Masih terbuka (blind spot yang tidak bisa saya tutup sendiri)
| # | Blind spot | Mengapa penting | Yang dibutuhkan |
|:-:|:---|:---|:---|
| 1 | **Terjemahan Inggris dan Arab belum ditinjau penutur ahli** | Pemilik sudah menemukan satu kalimat Arab yang cacat; halaman Arab dibaca para ulama | Peninjau bahasa Arab (guru) dan Inggris |
| 2 | **Tagline Arab belum ada** | Halaman Arab kini memakai judul deskriptif | Rumusan dari Pemilik atau gurunya |
| 3 | **Tangkapan layar aplikasi terbaru** | Demo kini berupa mockup HTML; tangkapan layar yang ada di repositori masih desain lama (oranye, kopi "Majelis Telaah") | Tangkapan layar v1.0.69 |
| 4 | **Klaim ketepatan** | Dokumen verifikasi internal mencatat 59,7 persen kutipan cocok dengan teks fisik (korpus lama). "Sangat tinggi" tanpa data dapat dipertanyakan | Hasil pengujian terbaru dan cara menampilkannya |
| 5 | **Hak cipta kitab dan ceramah** | Maktabah OpenTurath yang menaut unduhan banyak sumber, dan AI berbasis ceramah, memerlukan kebijakan hak cipta dan takedown yang jelas | Kebijakan tertulis; halaman "Sumber dan hak cipta" di situs lama sudah ada, perlu diselaraskan |
| 6 | **Bukti "ditinjau para ulama"** | Klaim ini tampil tiga kali | Deskripsi proses tinjauan (tanpa nama) |
| 7 | **Halaman kebijakan berbahasa Inggris dan Arab** | Tautan mengandaikan `/en/terms/` dan `/ar/terms/` ada di situs yang tayang | Verifikasi tiap tautan |
| 8 | Tautan unduh resmi dan versi | Tombol masih menaut ke halaman unduh yang ada | Tautan akhir |
| 9 | Harga dan penyedia pembayaran | Sengaja tidak ditampilkan | Keputusan Pemilik |
| 10 | Font: Scheherazade New 327 KB dan 589 KB; Google Sans Flex lisensi produksi; Cairo tiga berkas | Kinerja dan lisensi | Subset font; konfirmasi lisensi |
| 11 | Pengujian: Safari, Firefox, tablet, pembaca layar, Lighthouse | Baru Chrome yang diuji | Putaran QA |
| 12 | JSON-LD, analitik, halaman kabar rilis, kit pers, badge toko aplikasi | Belum ada | Prioritas setelah rilis |

## 4. Apa yang ditampilkan dan apa yang tidak

| Ditampilkan | Alasan |
|:---|:---|
| Janji, demo jawaban nyata, bidang, Fikih Tahawwulat, pagar keilmuan, ekosistem, perintis, unduh, FAQ | Menjawab lima pertanyaan pengunjung: apa ini, apakah bisa dipercaya, bagaimana kelihatannya, siapa di baliknya, bagaimana memulai |
| Cita-cita besar (Maktabah terbesar di dunia, AI manuskrip paling akurat di dunia, garda terdepan AI Islami) **sebagai tujuan** | Visi menarik dan benar sebagai arah |
| Momen pengumuman di Hadramaut | Bukti kepercayaan yang nyata |
| Nama bidang, deskripsi, dan arti nama lima cabang | Membantu pembaca memahami |

| Tidak ditampilkan | Alasan |
|:---|:---|
| Angka pasti (kitab, kata, rekaman, asisten) | Permintaan Pemilik; cepat usang |
| Harga dan penyedia pembayaran | Berubah; berbeda antara aplikasi dan web |
| Rincian jalur data dan alat internal | Tidak dibutuhkan pembaca dan membuka permukaan risiko |
| Nama ulama untuk dihidupkan kembali sebagai AI, nama guru selain Al-Habib Abu Bakar | Keputusan Pemilik |
| Kontak WhatsApp | Keputusan Pemilik |
| Perbandingan dengan nama produk AI lain | Keputusan Pemilik |
| Tagline Arab | Dibatalkan Pemilik |
| Tangkapan layar desain lama | Tidak sesuai produk sekarang |

## 5. Mengapa klaim "terbesar di dunia" dan "paling akurat di dunia" tidak ditulis sebagai fakta

Pertanyaan yang adil, dan ini jawabannya:

1. **Superlatif tentang fakta harus bisa dibuktikan oleh pembaca.** "Terbesar di dunia" dan "paling akurat di dunia" adalah pernyataan perbandingan. Begitu ada satu pembaca, pesaing, atau wartawan yang meminta bukti, Anda diminta menunjukkan datanya. Untuk Maktabah, produknya masih dibangun, jadi belum ada yang diukur. Untuk AI Manuskrip, hasil pembandingan memang Anda miliki, tetapi belum tampil di situs.
2. **Yang tidak bisa dibuktikan merugikan klaim yang bisa.** Satu klaim lemah menurunkan kepercayaan pada klaim kuat lainnya, termasuk klaim terpenting: rujukan ibarah.
3. **Ada pelajaran dari data sendiri.** Dokumen verifikasi internal mencatat angka 59,7 persen untuk kecocokan kutipan dengan teks fisik pada korpus lama. Bila situs menyatakan "paling akurat di dunia" dan ada yang membandingkan, angka itulah yang akan diminta.
4. **Cara yang saya pakai sekarang:** keduanya **ditulis sebagai tujuan** ("Cita-citanya: menjadi pusat unduh kitab terbesar di dunia"; "Tujuannya: menjadi AI manuskrip paling akurat di dunia. Pada pengujian kami, akurasinya sangat tinggi"). Itu jujur, tetap menampilkan ambisi, dan tidak bisa dibantah sebagai fakta palsu. Bila Anda menerbitkan hasil pembandingan yang bisa diperiksa, barulah kalimat itu boleh berubah menjadi pernyataan fakta, lengkap dengan tautan buktinya.

Keputusan akhir tetap milik Pemilik.

## 6. Arsitektur informasi dan alur

```
/  (pengalih bahasa)  →  /id/  /en/  /ar/
   Beranda
   ├─ Bidang ▾ → Bidang ilmu (daftar + pencarian) → Fikih Tahawwulat
   ├─ Cara kerja
   ├─ Pedoman keilmuan
   ├─ Ekosistem
   ├─ Tentang
   ├─ Unduh
   └─ Bantuan (FAQ, lapor kesalahan, kontak, kebijakan)
```
Alur pembaca baru: hero → demo jawaban → bidang → Fikih Tahawwulat → unduh. Alur guru yang skeptis: hero → pagar keilmuan → Pedoman keilmuan → Tentang → Bantuan. Alur peneliti: Bidang ▾ → rumpun → pencarian → Cara kerja → unduh.

## 7. Beranda, bagian demi bagian

1. Pil pengumuman + navigasi dengan panel Bidang ▾ dan pemilih bahasa.
2. **Hero** dengan lengkung bersarang, logo di puncak, tagline, kalimat penjelas, dua tombol, tiga penanda.
3. Mengapa OpenTurath: tiga kesulitan dan jawaban satu kalimat.
4. **Demo jawaban**: tiga pertanyaan, jawaban dengan ibarah Arab dan rujukan (isi dari Pengantar Fikih Tahawwulat di aplikasi, tiga bahasa).
5. Untuk siapa: tiga kartu.
6. **Bidang ilmu**: chip rumpun, kartu asisten (rata tengah), panel rincian.
7. **Fikih Tahawwulat**: logo yang menyala per bagian; empat rukun dengan keterangan "tetap" dan "berubah"; dua tugas rukun keempat; lima cabang beserta arti nama.
8. Pagar keilmuan + "AI hanyalah alat. Gurunya tetap guru."
9. Ekosistem: empat lini dengan cita-cita.
10. Perintis dengan momen Hadramaut.
11. Unduh.
12. FAQ.

## 8. Sistem desain web

Token abu netral (terang `#FFFFFF/#F8F9FC/#EFF2F7`, gelap `#121317/#18191D/#212226`); sudut 8/16/24/36/48 dan pil; bayangan berlapis. Komponen: pil pengumuman, navigasi dengan panel, tombol primer/tonal/terbalik, penjelajah, kartu kasus, chip rumpun, panel terbalik, kartu ekosistem, kartu platform, FAQ, garis waktu, formulir.
**Gerak:** lengkung tergambar bertahap dan "bernapas" halus; judul kitab muncul perlahan; logo menyala per bagian saat panel Fikih Tahawwulat terlihat; semua gerak mati bila pengguna memilih kurangi gerak.
**Arab dan RTL:** properti logis CSS, huruf Cairo untuk UI, Scheherazade New untuk teks kitab, jarak huruf nol, ikon panah dibalik.
**Aksesibilitas:** tautan lewati-ke-konten, landmark, peran ARIA pada tab, fokus terlihat, target sentuh 40 px, konten terbaca tanpa JavaScript.

## 9. Teknis

`build.py` membangun sembilan halaman × tiga bahasa dari data aplikasi, `catalog.json`, dan `adab.json` (nama dan deskripsi EN/AR bidang berasal dari katalog website yang sudah ada). Satu sumber untuk semua bahasa; mengubah teks cukup di satu tempat. Integrasi ke website V6 (172 halaman) dilakukan setelah desain dan salinan disetujui; situs yang tayang tidak disentuh.

## 10. Diuji

Chrome: sembilan halaman, tiga bahasa, terang dan gelap, 1440 dan 390 px; panel Bidang, tab demo, filter, pemilih bahasa, tombol tema, sorotan logo; tanpa galat konsol; tanpa luapan horizontal pada ponsel (ID dan AR). Belum: Safari, Firefox, tablet, pembaca layar, kinerja.
