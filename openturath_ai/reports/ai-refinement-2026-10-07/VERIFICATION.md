# Verifikasi AI refinement — 7 Oktober 2026

Perubahan diterapkan pada kode Flutter aktif. Tahawwulat berada pada halaman AI dengan label eksklusif; beranda memakai kartu ilmu charcoal dan watermark Arab. Profil tanpa garis kubah, masa aktif menyatu dengan akses, kontrol bahasa ID–EN–AR seragam dengan tampilan. Katalog mengelompokkan judul/pengarang, nomor urut, dan metadata pill. Harga coret memakai regularAmount tercatat. Loader memakai empat folio rounded dengan fase periodik, reduced motion dan pause lifecycle.

## Pemeriksaan

| Pemeriksaan | Hasil |
|---|---|
| Flutter analyzer | Bersih, exit 0 |
| Suite Flutter | 358 lulus, 1 tes motion opsional dilewati; exit 0 |
| Pemeriksaan tambahan copy/localization | 14 lulus; exit 0 |
| Render UI dari font native | Lulus setelah memperbaiki overflow judul Arab; 64 gambar tinjauan |
| Script VM WebView | 9 lulus: 5 arah/font/cleanup, 4 kesiapan input |
| Animasi | 60 frame native per tema; H.264 390×844, siklus 1,8 detik |
| macOS release | Exit 0, 132,4 MB bundle; universal arm64/x86_64 |
| Tanda tangan macOS | codesign verify deep/strict lulus; ad-hoc, belum notarized |
| DMG | hdiutil verify lulus |
| APK release | Gradle selesai 159,5 detik, exit 0; timestamp baru terverifikasi |
| APK salinan terbaru | Checksum sama dengan output Gradle; signature OpenTurath APK v2 valid |

## Paket lokal

APK: `/Users/apple/Downloads/ramadhan/app-release-latest.apk` — 67,550,328 byte. Timestamp salinan: 2026-10-07 14:35:29 +03.

SHA-256: `c3aea04f4a28687c6ed945745afbdf925a57b15f98145b5cb6914c6b0469c328`

DMG: `/Users/apple/Downloads/ramadhan/OpenTurath-AI-2026-10-07-refinement.dmg` — 52,100,066 byte.

SHA-256: `c08ddd5df9a455d249e49162ad8f08d5f97941518cd11426eb50ec827e23c3a7`

Versi tetap 1.0.63+64; paket dibangun ulang dari source revision `01f5ae9`. Tidak ada upload APK/DMG atau pemanggilan publish_auto_update.py oleh pekerjaan ini. Manifest mesin: artifacts.json. Pemulihan source: CHECKPOINTS.md.

## WebView: yang diperbaiki dan yang belum terbukti

Adapter memilih input percakapan yang benar-benar terlihat dan aktif, sehingga input tersembunyi pertama tidak menutupi composer berikutnya. Spinner panel sumber lain tidak menghambat sesi percakapan yang sudah siap. Batas waktu dimulai lagi saat dokumen utama berpindah; galat lama dari sesi yang sudah digantikan diabaikan. Galat HTTP utama dan status belum siap tampil dengan alasan yang sesuai, tanpa menuduh koneksi internet secara otomatis atau mengklaim antrean layanan.

Tes VM menggunakan DOM/input sintetis; bukan sesi NotebookLM nyata. Pemeriksaan aplikasi terpasang bisa mengambil screenshot, tetapi kendali jendelanya mengembalikan noWindowsAvailable/elementHasNoFrame sehingga pembukaan AI tidak berhasil diuji lewat alat tersebut. Penyebab kegagalan spesifik pada sesi Google pengguna belum dikonfirmasi. Dibutuhkan pembukaan AI dan satu pertanyaan/jawaban berhasil pada sesi nyata sebelum alur ini dinyatakan pulih.

Penanganan error mengikuti pemisahan error pemuatan, HTTP, dan navigasi dalam [dokumentasi resmi InAppWebView](https://inappwebview.dev/docs/webview/in-app-webview/). Login Google dan pemeriksaan sertifikat tidak dimodifikasi.

## Batas pemeriksaan visual

Galeri merender komponen aplikasi dengan akun representatif, tema ID/AR, terang/gelap, ponsel dan desktop, serta teks besar. Tes katalog menguji lebar 320, 390, 850, 1440, bahasa ID/EN/AR dan kedua tema pada pembesaran teks 2×. Ini belum mencakup pengukuran frame profile pada semua perangkat atau pemasangan APK di Android fisik. Kelulusan tes bukan penerimaan estetika pengguna.

Perubahan cache Firebase yang muncul selama pengerjaan dan penghapusan lama pada direktori lain tetap di luar checkpoint pekerjaan ini.
