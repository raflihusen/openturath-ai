# Hasil implementasi redesain native OpenTurath

Tanggal: 22 September 2026. Baseline rencana: `9e5ae94`. Implementasi di branch `main`, dengan checkpoint Git bertahap. Tidak ada build APK, unggahan CDN, broadcast versi, atau transaksi produksi.

## Hasil

Identitas native baru memakai tinta monokrom, halaman editorial, font Latin dan Arab yang dibundel, serta aksen kuningan redup khusus koleksi Tahawwulat. Tema baru dibatasi pada subtree native, bukan seluruh aplikasi yang menaungi ruang AI.

| Permukaan | Perubahan yang diterapkan |
| --- | --- |
| Shell | Palet native, navigasi tab langsung, label dan tinggi adaptif, penghentian ticker native ketika AI terbuka; retensi overlay AI dipertahankan |
| Beranda | Ruang belajar pribadi, lanjutkan sesi berdasarkan data, direktori bidang, pencarian Arab yang konsisten, dua catatan terbaru yang benar-benar tersimpan |
| Direktori Asisten | Cakupan dan akses lebih jelas, tindakan rujukan terpisah, kontrol korpus dan filter diselaraskan |
| Tahawwulat | Ringkasan koleksi, halaman eksklusif, lima tipe dengan ikon dan deskripsi peran terlokalisasi; callback tetap memakai model dan pemeriksaan akses lama |
| Pengenalan | Ringkasan ID/EN/AR dan akses ke artikel asli; isi artikel asli tidak diterjemahkan secara spekulatif |
| Pustaka | Pintu native langsung ke katalog, ringkasan koleksi sekunder, pencarian normalisasi Arab, metadata membungkus, detail dan salin rujukan terlokalisasi |
| Simpan rujukan editorial | Identitas stabil berdasarkan edisi, status tersimpan/busy, penanganan kegagalan; tidak menghapus atau memigrasikan catatan lama |
| Detail canonical | Kontrol rute native mengikuti bahasa aplikasi; presentasi bibliografi Arab dan mode legacy tetap tersedia |
| Catatan | Pencarian/filter, tanggal terlokalisasi, pembeda kosong vs tanpa hasil, pembaca berlebar terkontrol dan arah teks campuran, editor/draft dengan toolbar dan preview |
| Pengaturan | Identitas dan akses responsif, preferensi, bantuan dan kebijakan dapat dibuka langsung |
| Login / splash | Palet terang/gelap, tipografi native, kontras tombol, dukungan reduced motion dan loading native |
| Langganan | Pilihan sesuai konteks asisten, satu ringkasan aktif dan satu CTA pembayaran; sumber harga dan validasi transaksi dipertahankan |
| Checkout / utilitas | Penyelarasan chrome native, font, loading, voucher, update banner/dialog; halaman pembayaran provider tidak didesain ulang |

## Bukti verifikasi

- Baseline: 166 tes lulus sebelum migrasi.
- Akhir: `flutter test --no-pub --reporter expanded` — **188 tes lulus**; tes lama tidak dihapus atau dilemahkan.
- `flutter analyze --no-pub` — **No issues found**.
- 22 tes baru mencakup kelengkapan copy/placeholder; lima callback tipe Tahawwulat pada ID/EN/AR × terang/gelap × teks 100%/200%; pencarian kitab Arab dan tanpa hasil pada 320 px/200%; identitas rujukan lintas bahasa; kontrol canonical tiga bahasa; isolasi tema parent/sibling; loading reduced-motion dan pelepasan timer.
- Pengujian menemukan overflow metadata katalog pada EN/AR di 320 px/200%; komposisinya diperbaiki menjadi metadata yang membungkus dan diuji ulang.
- Font native Arab/Latin beserta lisensi OFL disimpan sebagai asset. Tidak mengubah helper font yang dipakai AI.
- `git diff --exit-code 9e5ae94 -- <daftar terlindungi>` menghasilkan exit 0 untuk WebView/room, script notebook/navigasi, Google session auth, seluruh services/models, tema/token/motion/copy/font global, dan loader/error/interactive wrapper bersama.
- Pemeriksaan struktur shell: `NativeTheme` hanya pada halaman native; `AgentMultiTabRoom` tetap sibling dengan identity dan pengaturan retensi semula.

Tes isolasi tema membuktikan cakupan widget, **bukan** pengganti screenshot dan uji sesi WebView nyata. Hasil test tidak membuktikan bebas bug atau seluruh kombinasi perangkat sudah diperiksa.

## Pratinjau hasil render Flutter

Ini tangkapan widget halaman koleksi dengan font asli, bukan gambar konsep dan bukan capture perangkat. Viewport 390 × 900 logical pixels, pixel ratio capture 2. Cuplikan awal halaman hanya memperlihatkan sebagian daftar; semua lima tipe diuji melalui scrolling dan callback.

| Bahasa | Terang | Gelap |
| --- | --- | --- |
| Indonesia | [Lihat](tahawwulat-id-light.png) | [Lihat](tahawwulat-id-dark.png) |
| English | [View](tahawwulat-en-light.png) | [View](tahawwulat-en-dark.png) |
| العربية | [عرض](tahawwulat-ar-light.png) | [عرض](tahawwulat-ar-dark.png) |

Reproduksi: `flutter test test/native_redesign_test.dart --dart-define=CAPTURE_NATIVE=true`. Capture ditulis ke `/tmp/openturath-<locale>-<theme>.png`.

## Batas dan pemeriksaan lanjutan

Implementasi kode tidak disamakan dengan persetujuan visual akhir atau kesiapan rilis tanpa pengujian berikut:

1. Perangkat Android/iOS nyata: keyboard, safe area, screen reader/fokus, font besar pada seluruh layar, performa animasi dan resume dari background. Matriks baru terfokus, belum merupakan bukti semua layar pada setiap ukuran.
2. Login akun nyata, resume/tutup/buka AI tanpa kehilangan sesi, dan screenshot AI sebelum/sesudah. Tidak menggunakan sesi pengguna atau melakukan login otomatis untuk mengklaim pengujian ini.
3. Checkout sandbox end-to-end: batal, pending, gagal, pembayaran diterima, dan aktivasi hak akses. Tes layanan lama tetap lulus, tetapi belum menggantikan provider nyata.
4. Review editorial oleh penutur Arab/Inggris dan pemilik materi untuk nuansa keilmuan. Nama kitab, metadata sumber, artikel asli, serta dokumen kebijakan resmi tetap pada bahasa sumber dan diberi konteks; tidak dipasarkan sebagai terjemahan resmi lengkap.
5. Penilaian visual langsung seluruh layar nonflagship. Pratinjau yang disertakan saat ini berfokus pada Tahawwulat; belum ada bukti screenshot before/after lengkap semua layar.

Klaim “pertama di dunia” tidak ditambahkan sebagai fakta pemasaran baru tanpa dasar verifikasi. Eksklusivitas diwujudkan melalui identitas koleksi, hierarki dan lima peran, bukan perubahan AI atau klaim kemampuan tambahan.

Metode implementasi menggunakan skill `ecc:dart-flutter-patterns`: pemisahan widget/presentasi, pemeriksaan mounted setelah operasi async, lifecycle/dispose, dan regresi widget. Fondasi visual mengacu pada dokumen rencana redesain workspace.
