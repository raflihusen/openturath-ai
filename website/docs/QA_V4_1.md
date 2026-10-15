# Hasil QA OpenTurath V4.1

20 September 2026. Bukti berasal dari source dan build yang diserahkan.

| Pemeriksaan | Hasil |
|---|---|
| npm test — Node.js | 22 lulus, 0 gagal |
| npm test — Python | 13 lulus, 0 gagal |
| npm run build:release | 172 halaman, 0 kesalahan |
| Pemeriksaan lokal | 171 halaman bahasa, 9.873 tautan/aset lokal |
| Integritas arsip | 6 hash jawaban dan 10 rekaman kutipan |
| Chromium 153.0.8010.0 | 90 kombinasi halaman/bahasa/lebar layar |
| Skenario interaksi | 15 lulus |
| Pemeriksaan motion | 5 lulus |
| axe-core | 9 pemeriksaan, 0 pelanggaran otomatis |
| Runtime / respons halaman | 0 error tak terduga |

## Interaksi utama

- Arabic diacritic search, discipline filter, empty state, reset, URL state
- Desktop Indonesian hero description occupies two lines
- Source dialog opens, Escape closes, keyboard focus restored
- Theme persists after reload
- Language switch preserves route, query and fragment
- Arabic mobile menu navigation
- Unavailable platforms expose no download links
- Mobile first viewport contains a working accessible download link
- Ten real FAQ answers toggle with Enter and Space, preserving focus
- Six computed metadata totals appear immediately after the hero
- Report saved through real local API with report ID
- Failed report retains content and offers draft download
- Mobile archive tabs and reading mode
- Reduced-motion preference disables parallax
- Core Arabic content and navigation available without JavaScript

## Motion

- Hero pointer movement updates independent book and calligraphy layers
- Bento spotlight follows pointer position
- Filtered bento cards retain layout and keyboard DOM order
- Changing reduced-motion preference at runtime disables motion and reveals all content
- Touch devices do not receive pointer-driven parallax

## Kondisi pemeriksaan

Ukuran layar: 1440, 390, dan 320 px. Bahasa: Indonesia, Inggris, dan Arab RTL. Jenis halaman: beranda, khazanah, keanggotaan, unduh, ketentuan, privasi, pembayaran, adab, formulir, dan arsip Q001.

Kontras diukur setelah font siap dan dengan gerak dinonaktifkan agar opacity transisi tidak menghasilkan pembacaan sementara. Gerak tetap diuji terpisah dalam keadaan aktif. Formulir memakai database sementara, termasuk simulasi gagal kirim 503 untuk memastikan teks tetap tersimpan pada formulir dan salinan dapat diunduh.

`npm run test:visual` mengambil screenshot dan memeriksa pointer, bento, reduced motion, serta perangkat sentuh. Gunakan dependensi Playwright yang sama dengan panduan README.

Bukti: `BUILD_REPORT.json`, `BROWSER_QA.json`, `MOTION_QA.json`, `verification/npm-test.log`, `verification/build-release.log`, `verification/browser-qa.log`, dan `verification/visual-qa.log`.

## Batas validasi

Mode distribusi saat diserahkan: `website-only`. Tidak ada APK asli yang dapat diuji instalasinya. Transaksi DOKU produksi, pemetaan harga/entitlement backend, Safari/Firefox, dan pembaca layar perangkat nyata tidak diuji oleh rangkaian ini. Kelulusan otomatis bukan sertifikasi WCAG menyeluruh.
