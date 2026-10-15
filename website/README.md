# OpenTurath Website V6

Website trilingual ID / EN / AR dengan kanvas putih murni, mode gelap obsidian netral, logo asli monokrom, dan hierarki angka yang menonjol. Tepat setelah hero: 20 disiplin, 5.370 kitab, 11.901+ jilid, 4.182.803 halaman, 1.148.410.539 kata, dan 2.876 partisi.

## Jalankan

Node.js 22+ dan Python 3.10+. Build dan unit test tidak membutuhkan instalasi paket npm.

```sh
npm run build:release
npm test
npm start
```

Buka `http://localhost:4173/id/`, `/en/`, atau `/ar/`. Aset memakai path absolut situs, sehingga hasil HTML perlu dilayani melalui HTTP.

`npm run dev` membuat preview dengan `noindex`. `npm run build:release` menghasilkan 172 halaman pada `dist/`. ZIP ini memuat source lengkap dan hasil build.

## Apa yang berubah

- 21 deskripsi khadim yang berbeda dalam tiga bahasa, dengan 20 disiplin aktif dan Khazanah Habib Umar dalam persiapan.
- Metadata setiap kartu dan angka agregat dihitung dari data yang sama. Build memeriksa kesesuaian dengan snapshot metadata aplikasi.
- Bento dengan angka kitab hingga 166 px, metadata kartu besar, serta 4 tahap verifikasi yang mengikuti scroll. Animasi tiap bagian tetap aktif setelah lama membaca; preferensi pengurangan gerak tersedia melalui sistem dan kontrol di footer.
- Hero memakai CTA khazanah dan metode. Tombol unduh tetap tersedia pada navbar ponsel.
- Satu banner akses mulai Rp 49.000 per bulan, tanpa tiga kartu paket. Rincian transaksi tetap melalui aplikasi dan DOKU.
- Tujuh prinsip adab dari materi yang diberikan, disusun ulang dalam tiga bahasa dengan atribusi editorial yang jelas.
- Sepuluh FAQ nyata dengan `<details>` / `<summary>`, navigasi keyboard, dan dukungan tanpa JavaScript.

## Acuan kode dan data

| Berkas | Fungsi |
|---|---|
| `src/home.mjs` | Hero, statistik, metode, bento, arsip, keanggotaan, adab, FAQ |
| `public/assets/immersive.css` | Palet, tipografi, tata letak responsif, RTL, dan gerak |
| `public/assets/product-motion.mjs` | Paralaks, spotlight, reveal, dan transisi FAQ |
| `src/copy.mjs` | Seluruh naskah UI dan FAQ dalam tiga bahasa |
| `src/articles.mjs` | Artikel, metode, dan ringkasan kebijakan |
| `src/metadata.mjs` | Format angka, agregasi, metadata kartu, validasi sumber |
| `src/method.mjs` | Visualisasi empat langkah telaah dan contoh arsip |
| `src/adab.mjs` / `content/adab.json` | Tujuh prinsip adab, tiga ringkasan beranda |
| `src/membership.mjs` | Banner akses bersama untuk beranda dan halaman keanggotaan |
| `site.config.json` | Harga acuan, operator, status unduhan, rilis, dan layanan |
| `content/catalog.json` | Profil, deskripsi, status, ID aplikasi, metadata, dan terjemahan periode |
| `content/metadata/` | Snapshot metadata modul serta partisi dari aplikasi |
| `content/glossary-map.json` | Pemetaan istilah bersama ke kamus aplikasi |
| `docs/Kamus_OpenTurath_ID_EN_AR.csv` | Kamus lengkap dari audit aplikasi |
| `public/assets/kebijakan-aplikasi-v1.0.md` | Naskah resmi kebijakan aplikasi, 39 bagian |
| `server/` | API laporan dengan penyimpanan privat, persetujuan, validasi, dan retensi |

Untuk memperbarui metadata, ubah snapshot sumber dan nilai katalog terkait. `metadataKey` menghubungkan nama website dengan modul. Terjemahkan kembali rentang masa jika berubah. Build menolak ketidaksesuaian; jangan mencampur hitungan kitab dari snapshot training yang lebih lama.

## Verifikasi browser

```sh
npm install --no-save playwright axe-core
npx playwright install chromium
npm run build:release
AXE_SCRIPT=./node_modules/axe-core/axe.min.js npm run test:browser
npm run test:visual
```

`BROWSER_EXECUTABLE` dapat menunjuk Chromium yang tersedia. `PLAYWRIGHT_MODULE` dapat menunjuk modul Playwright eksternal. Tanpa `AXE_SCRIPT`, pemeriksaan tata letak dan interaksi tetap berjalan. Pemeriksaan aksesibilitas dilakukan pada tampilan stabil dengan reduced motion; interaksi gerak diperiksa terpisah.

Fixture browser memakai origin lokal dan database laporan sementara. Konfigurasi produksi tidak dilonggarkan dan tidak ada laporan yang dikirim ke luar. Server biasa menolak pengiriman formulir dari origin berbeda sesuai konfigurasi canonical.

Bukti tersimpan di `docs/BUILD_REPORT.json`, `docs/BROWSER_QA.json`, `docs/QA_V6.md`, `docs/verification/`, dan `docs/previews/v6/`.

## Status integrasi aplikasi

Penawaran publik mengikuti arahan terbaru, mulai Rp 49.000 per bulan. Tiga definisi paket tetap disimpan dalam konfigurasi sebagai data komersial, tanpa ditampilkan sebagai kartu. Backend aplikasi yang tersedia dalam audit sebelumnya masih memiliki harga dan entitlement berbeda. `content/app-parity.json` mencatat status tersebut; revisi website ini tidak mengubah transaksi DOKU atau backend Flutter.

Build yang lulus memvalidasi artefak website. Pengujian ini tidak menjalankan transaksi produksi. Arsip Q001 mempertahankan kutipan asli dan status pemeriksaannya. Distribusi APK dikelola pengguna di luar perubahan V6.

## Dokumen dan deployment

Laporan terbaru: `docs/AUDIT_WEBSITE_V6.md`. Laporan V4.1, V4, V3, dan V2 merupakan riwayat audit, bukan spesifikasi hasil terbaru.

Gunakan `docs/DEPLOYMENT.md` dan `docs/OPERATIONS.md`. Untuk hosting statis tanpa API, set `reports.enabled=false` lalu build ulang. Untuk formulir aktif, jalankan WSGI melalui HTTPS dan reverse proxy dengan origin yang sama. Server preview Python hanya untuk pengembangan lokal.
