# Audit dan implementasi OpenTurath Website V6

Versi 6.0.0 · 20 September 2026

V6 mengubah pusat perhatian website: angka khazanah menjadi pesan utama, disusul cara menelaah sumber dan pilihan disiplin. Kanvas terang sekarang putih murni, logo asli mengikuti tema hitam/putih, dan gerak mengikuti perjalanan membaca. Revisi ini dikerjakan pada source website yang tersedia, bukan sekadar gambar konsep.

## Temuan dan perbaikannya

| No. | Blind spot yang ditemukan | Dampak | Perbaikan V6 |
|---|---|---|---|
| 1 | Enam total dipadatkan dalam strip, angka desktop sekitar 34 px dan label kecil | Skala khazanah kehilangan daya jual | Bento asimetris: 5.370 sebagai angka utama sekitar 166 px, angka lain mendapat area tersendiri |
| 2 | Metadata setiap asisten menjadi kapsul 11 px | Pembaca harus mencari nilai terpenting di akhir deskripsi | Angka kitab 112 px pada kartu unggulan, 100 px di ponsel; metadata sekunder 27–29 px |
| 3 | Judul statistik disembunyikan dengan `sr-only` | Angka tidak mempunyai narasi visual | Judul terlihat: “Khazanah besar. Ruang telaah tanpa batas.” |
| 4 | Latar terang `#f6f3ed` dan permukaan `#fffdf7` menguning | Tidak sesuai arahan putih bersih | Kanvas `#ffffff`, permukaan netral `#f5f5f7`, teks `#111111` |
| 5 | Logo selalu menggunakan aksen emas | Identitas tidak mengikuti tema | Bentuk SVG master aplikasi dipertahankan; CSS `currentColor` menjadikannya hitam atau putih |
| 6 | Tema awal dipaksa gelap dan tombol tema disembunyikan di ponsel | Pengalaman terang sulit ditemukan | Pengunjung baru mendapat tema terang; pilihan tersimpan tetap dihormati; tombol tema tersedia di ponsel |
| 7 | `setTimeout(revealAll,8000)` memutus seluruh IntersectionObserver | Animasi hilang setelah pengunjung membaca hero selama 8 detik | Hapus kedaluwarsa global; observer tetap menunggu bagian yang belum dilihat; uji regresi menunggu lebih dari 8 detik |
| 8 | Reveal hanya menargetkan beberapa heading | Kartu, angka, dan mayoritas halaman terasa statis | Entrance terpisah untuk angka, kartu, heading, adab, artikel, dan footer; stagger mengikuti elemen yang masuk viewport |
| 9 | Paralaks hero terlalu kecil dan hampir seluruhnya mengikuti mouse | Pengalaman scroll tidak mempunyai perubahan yang terasa | Kitab dan kaligrafi memakai kedalaman berbeda; skala/posisi turut mengikuti scroll |
| 10 | Verifikasi hanya empat kolom statis | Metode tidak terasa sebagai perjalanan telaah | Naskah contoh sticky di desktop dengan empat keadaan: pertanyaan, ibarah, koordinat, dan bimbingan guru |
| 11 | Aturan `.full-grid .collection-card h3` lama menimpa ukuran baru di ponsel | Judul tetap kecil walaupun CSS baru tampak benar | Specificity komponen diperbaiki; browser memeriksa ukuran judul ponsel 26 px |
| 12 | Asset kitab mempunyai latar gelap menyatu | Menimbulkan bidang gelap saat ditempatkan pada kanvas putih | Asset dekoratif transparan khusus V6, dikonversi ke WebP sekitar 174 KB |
| 13 | Belum ada pilihan pengurangan gerak di website | Pengguna bergantung pada pengaturan sistem | Kontrol “Kurangi gerak” di footer, tersimpan lokal; `prefers-reduced-motion` tetap didahulukan |
| 14 | Animasi berpotensi menyembunyikan elemen saat dinavigasi keyboard | Fokus bisa masuk ke konten yang belum tampak | `focusin` langsung menampilkan elemen beserta induk reveal-nya; tanpa JavaScript semua isi terlihat |
| 15 | Materi adab panjang, repetitif, dan memuat atribusi AI yang terlalu jauh | Panduan terasa defensif dan berisiko disangka kutipan literal ulama | Tujuh prinsip praktis dalam ID/EN/AR, tiga ringkasan beranda, catatan atribusi editorial yang jelas |
| 16 | Panduan editorial adab ditampilkan seolah seluruh isinya naskah legal resmi | Pembaca sulit membedakan rumusan editorial dengan kebijakan kanonis | Panduan baru berdiri sebagai tulisan editorial; tautan dokumen resmi dan versinya tetap ada |
| 17 | Pernyataan hero dan CTA ponsel kurang seimbang | Baris deskripsi terlalu panjang dan CTA bertumpuk | Lebar paragraf diperketat; dua CTA setara dalam satu baris ponsel, unduh tetap berada di navbar |
| 18 | Footer kecil, bernuansa krem, dan menu ponsel menggandakan Keanggotaan | Navigasi terasa padat serta kurang rapi | Footer putih dengan teks 15 px desktop/14 px ponsel; tautan menu duplikat dihapus |
| 19 | Preferensi gerak baru belum tercantum pada penjelasan data website | Ringkasan privasi bisa tertinggal dari perilaku aktual | Pilihan gerak lokal ditambahkan pada ringkasan privasi tiga bahasa |
| 20 | Dokumentasi pembuka masih menjelaskan V4.1 dan palet emas | Paket kode dan tampilan produk tidak konsisten | `package.json`, konfigurasi versi, README, START_HERE, audit dan bukti QA diperbarui ke V6 |

## Pelajaran desain dari Apple

Halaman Apple diamati melalui browser: headline singkat, visual produk berukuran besar, pasangan CTA yang konsisten, perpindahan bidang penuh ke pasangan tile, serta ruang kosong yang membantu fokus. Sampel headline desktop yang terukur adalah 56 px dengan line-height 60 px dan bobot 600; beberapa headline tile 40/44 px. Angka tersebut merupakan pengamatan pada viewport yang diuji, bukan aturan universal Apple. [Sumber: Apple](https://www.apple.com/).

OpenTurath mengambil prinsip hierarki dan pembagian ruang itu, sambil mempertahankan Newsreader, Outfit, Naskh Arab, logo asli, serta ilustrasi kitab. Aksen biru Apple tidak disalin.

## Angka dan sumber data

| Metrik | Nilai sumber | Perlakuan tampilan |
|---|---:|---|
| Disiplin aktif | 20 | Angka besar; dibedakan dari 21 profil |
| Kitab | 5.370 | Angka utama pada bidang hitam |
| Jilid | 11.901+ | Tanda + dipertahankan karena sebagian sumber merupakan batas bawah |
| Halaman | 4.182.803 | 4,1+ juta dengan angka lengkap tetap tampil |
| Kata | 1.148.410.539 | 1,14+ miliar dengan angka lengkap tetap tampil |
| Partisi | 2.876 | Baris penutup berukuran besar |

Total merupakan akumulasi metadata 20 modul, bukan pernyataan bahwa judul antar-modul sudah dideduplikasi. `content/metadata/metadata_modul_lengkap.json` menjadi sumber jumlah kitab/jilid/halaman/kata, sedangkan snapshot training digunakan untuk partisi. `validateCatalogMetadata` menolak perbedaan dengan data kartu. Habib Umar tetap berstatus persiapan dan tidak menambah total aktif.

Kasus yang sebelumnya rawan tertukar tetap benar: Fikih Syafi’i 103 kitab, Hadits 1.141 kitab dan 532.640 **halaman**, Tarikh 499 kitab. Tidak digunakan angka lama 87, 1.173, atau 345 dari narasi yang berbeda snapshot.

## Adab yang lebih natural

Tujuh prinsip pada halaman panduan:

1. Gunakan alatnya. Rawat hubungan dengan guru.
2. Telusuri sumbernya. Baca konteksnya.
3. Hormati mazhab dan keluasan ikhtilaf.
4. Jaga amanah dalam menukil.
5. Timbang jawabannya, bukan kefasihannya.
6. Sambungkan bacaan dengan tradisi ilmu.
7. Arahkan ilmu untuk membawa manfaat.

Rumusan ini mengolah materi pengguna tentang pembaruan sarana, talaqqi, verifikasi, amanah ilmiah, dan manhaj salamah. Tidak menambahkan atribusi bahwa ulama tersebut pernah mengeluarkan fatwa khusus mengenai produk AI ini. Kutipan Arab, nomor halaman, dan judul buku yang belum dicocokkan dengan sumber terbitan tidak dijadikan kutipan langsung baru. Dokumen kebijakan aplikasi kanonis tetap utuh.

## Pemeriksaan fidelitas visual

Konsep berada di `docs/design-concepts/v6/`. Hasil browser berada di `docs/previews/v6/`. Konsep dan tangkapan implementasi dibuka dengan `view_image`; tidak hanya diperiksa lewat DOM. Ukuran konsep dan pengujian visual desktop: **1536 × 1024**. Ponsel diperiksa pada **390 × 844**, dilengkapi pemeriksaan tata letak 320 px dan 1440 px.

| Titik perbandingan | Konsep / sasaran | Hasil dan keputusan |
|---|---|---|
| Palet | Putih murni, tinta hitam, abu netral | Browser mengukur kanvas `rgb(255,255,255)`; logo hitam/putih menurut tema |
| Hierarki total | Satu angka dominan dengan empat tile pendukung | 5.370 sekitar 166 px desktop dan 113 px ponsel; layout besar dipertahankan |
| Anatomi kartu | Judul, angka kitab, metadata pendukung yang terbaca | 112 px pada angka unggulan, 27 px sekunder, judul ponsel 26 px setelah konflik CSS dibetulkan |
| Tipografi hero | Judul serif besar, subjudul, deskripsi dua baris desktop | Hirarki dan copy utama diperiksa; CTA ponsel diperbaiki agar sejajar |
| Aset | Kitab sebagai pusat visual, tanpa mockup ponsel | Komposisi tumpukan kitab yang telah digunakan pengguna dipertahankan; latar transparan menyatu dengan kedua tema |
| Metode | Naskah di kanan, urutan telaah di kiri | Empat tahap scroll berjalan; tidak memakai facsimile hasil generasi sebagai bukti sumber |
| Adab dan FAQ | Ruang lapang, kaligrafi, panduan yang terbaca | Tiga prinsip beranda dan sepuluh jawaban nyata; FAQ native tetap dapat dioperasikan keyboard |
| Responsivitas | Angka besar tetap utuh dalam ID/EN/AR | Tidak ada overflow pada 90 kombinasi yang diuji; font Arab dan arah RTL diperiksa |

Penyesuaian sengaja terhadap gambar konsep: logo master aplikasi menggantikan ikon buku yang diinventarisasi generator; navigasi asli dan sepuluh FAQ tetap dipakai; tidak menambahkan login, daftar, media sosial, atau klaim koleksi yang tidak ada pada source. Foto kitab berlabel spesifik di beberapa konsep tidak digunakan agar tidak mengesankan edisi tersebut telah diverifikasi. Hero tetap memakai tumpukan kitab asli, dengan asset transparan V6. Copy konsep yang berbeda dari fakta source tidak diangkat menjadi fitur produk.

Pemeriksaan teks area awal: eyebrow, H1, tagline, deskripsi, dan kedua CTA tetap sesuai copy yang diminta. Tidak ada klaim “0 halusinasi” atau angka khazanah rekaan. Implementasi diverifikasi terhadap arah desain tersebut; penyesuaian yang disengaja tercatat di atas.

## Hasil pengujian

| Pemeriksaan | Hasil |
|---|---|
| `npm test` | 23 tes Node.js + 13 tes Python lulus; 0 gagal |
| `npm run build:release` | 172 halaman; 9.705 tautan/aset lokal diperiksa; 0 error |
| Konsistensi sumber arsip | 6 hash jawaban dan 10 catatan kutipan tetap valid |
| Browser | 90 kombinasi: ID/EN/AR × 1440/390/320 px × 10 rute |
| Interaksi | 15 alur lulus: pencarian, filter, dialog, tema, bahasa, FAQ, formulir, arsip, tanpa JS |
| Motion dan visual | 14 pemeriksaan lulus, termasuk regresi setelah 8 detik dan keempat tahap metode |
| Aksesibilitas otomatis | 9 audit axe pada tampilan stabil; 0 pelanggaran WCAG A/AA yang terdeteksi |

Browser terhubung menolak alamat localhost dengan `ERR_BLOCKED_BY_CLIENT`; pengujian implementasi memakai Chromium lokal 153.0.8010.0 melalui Playwright. Audit otomatis ini bukan sertifikasi aksesibilitas dan tidak menggantikan pengujian Safari, Firefox, atau perangkat fisik. Formulir diuji pada database sementara, tanpa mengirim laporan ke layanan produksi.

Bukti: `docs/verification/npm-test-v6.log`, `build-release-v6.log`, `browser-v6.log`, `visual-v6.log`, `docs/BROWSER_QA.json`, `docs/MOTION_QA.json`, dan `docs/BUILD_REPORT.json`.

## Cakupan kode dan penggunaan

Source utama: `src/home.mjs`, `src/metadata.mjs`, `src/method.mjs`, `src/adab.mjs`, `src/copy.mjs`, `src/articles.mjs`, `src/render.mjs`, `src/pages.mjs`, `public/assets/immersive.css`, `public/assets/product-motion.mjs`, `public/assets/theme.js`, `site.config.json`, dan `content/adab.json`.

```sh
npm run build:release
npm test
npm start
```

Buka `http://localhost:4173/id/`, `/en/`, atau `/ar/`. Source dan hasil build `dist/` disertakan. Website belum dipublikasikan ke domain produksi. Pengujian V6 tidak menjalankan transaksi pembayaran produksi; catatan integrasi aplikasi yang sudah ada tetap tersedia di `content/app-parity.json`.
