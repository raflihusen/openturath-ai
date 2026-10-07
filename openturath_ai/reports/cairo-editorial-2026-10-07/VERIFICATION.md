# Verifikasi Cairo dan katalog editorial — 7 Oktober 2026

Implementasi berada pada branch `codex/cairo-editorial-2026-10-07`, baseline `e8c6861`. Perubahan produksi, font, tes, dokumentasi, dan bukti render mempunyai commit dengan file eksplisit. Tidak ada upload, push, atau broadcast versi.

## Hasil yang sudah diperiksa

- Cairo lokal static asli 400/600/700, slant normal, lisensi OFL disertakan. Outfit tetap ID/EN; Scheherazade tetap untuk sumber Arab. Font tidak membutuhkan unduhan runtime.
- Watermark dekoratif Cairo 700: label ringkas, sekitar 85% lebar, opacity 8%, tidak mengambil tinggi dan tidak masuk pembaca layar. Label Bahasa Arab `علوم العربية`; ID internal tetap.
- Kartu AI terpusat, dua kontrol terpisah 72×48 dan 48×48, tooltip serta nama pembaca layar. Tidak ada target navigasi tambahan pada seluruh kartu.
- Tombol flagship membuka pemilih lima AI dengan fungsi masing-masing. Ikon rujukan di dalam hero membuka katalog Tahawwulat; detail kitab menampilkan metadata edisi asli.
- Katalog default daftar editorial dengan tinggi fleksibel, metadata jilid/halaman berdekatan; grid alternatif tetap tersedia. Placeholder kosong tidak ditampilkan sebagai angka nol.
- Sapaan dan sesi memakai satu panel ber-divider; kalender terstruktur dari satu snapshot. Statistik memakai panel selebar konten, terpisah dari adab. Adab memakai ID dan ikon stabil.
- Lima dokumen, 46 section: paritas ID/EN/AR, isi offline, resolver locale reaktif, termasuk judul/subtitle/isi/penutup. Sumber kitab tidak diterjemahkan.
- Loader empat folio dipertahankan; kontinuitas fase periodik, repaint langsung, reduced motion dan lifecycle tetap aktif.

## Pengujian

- Suite penuh pada tahap integrasi: 368 lulus, 1 pengujian opt-in dilewati, exit 0. Ini dilakukan sebelum koreksi native terakhir pada panel statistik dan semantics ikon.
- Pengujian terarah setelah koreksi native: 18 lulus, exit 0 (lokalisasi, layout ponsel, token desain).
- Analyzer: tidak ada masalah, exit 0.
- Harness render: exit 0, 85 PNG. Widget produksi dan font asli, dengan akun/data contoh yang ditandai fixture.
- Matriks representatif memuat lebar 320/390/600/850/1280/1440, tema gelap, Arab, teks besar hingga 200%, nama panjang, metadata, dokumen Inggris/Arab, dan spesimen bobot Cairo. Ini bukan seluruh kombinasi setiap layar × ukuran × bahasa × tema × skala.
- Pergantian locale saat dokumen terbuka, paritas dokumen, isolasi email/URL, nama kontrol, serta callback buka/rujukan diuji secara terarah.

## Pemeriksaan native macOS

Host review terpisah memakai bundle ID `com.openturath.cairo.reviewfixture` dan akun contoh. Dart/Flutter dikompilasi AOT profile; native Runner diambil dari build Release lokal sebelumnya, karena file native tidak berubah. Salinan host mendapat tanda tangan ad-hoc dan pemeriksaan `codesign --verify --deep --strict` berhasil.

Cold build Xcode profile membutuhkan provisioning development yang tidak tersedia. Percobaan build Xcode berikutnya dihentikan ketika host terbebani; tidak dinyatakan sebagai clean production build yang berhasil. Host review ini merupakan fixture native, bukan paket rilis atau DMG distribusi.

Pemeriksaan langsung mencakup dashboard dan statistik, kartu AI dan nama tombol rujukan di accessibility tree, pemilih lima AI sebagai lima tombol, katalog Tahawwulat → detail edisi → kembali, profil dan kontrol tampilan/bahasa, Tentang Inggris/Arab, panduan Inggris, serta bantuan Arab dan email LTR. Sepuluh dokumen Inggris/Arab lainnya dirender oleh harness; tidak semuanya diklik secara manual pada sesi native.

## Pengukuran loading nyata

`motion-profile.json`: mode native macOS profile, pengukuran 18.000 ms = sepuluh siklus, 1.073 frame. Build p95 0,446 ms, maksimum 2,715 ms; raster p95 1,131 ms, maksimum 7,409 ms. Tidak ada frame di atas 16,67 ms pada pengukuran hangat ini. Pengukuran dingin sebelumnya mencatat frame lambat; hasil hangat bukan jaminan performa seluruh perangkat.

Lifecycle produksi tetap aktif; pengukuran menunggu window benar-benar resumed. Rekaman terpisah berisi 178 sampel selama 18.042 ms, sekitar 10 fps. GIF merupakan sampling visual loop, bukan rekaman 60 fps; sampling tidak ikut masuk pengukuran frame timing. Tidak ada penundaan proses demi menghabiskan animasi.

## Batas verifikasi

Tidak ada transaksi nyata, login Google, atau tanya-jawab NotebookLM terautentikasi dilakukan dalam review ini. WebView tidak diubah terhadap baseline. Fixture pembayaran sukses tidak membuktikan aktivasi nyata. Penerimaan visual pengguna tetap terpisah dari kelulusan tes. Tidak ada DMG/APK baru atau publikasi pada tahap penyempurnaan ini.
