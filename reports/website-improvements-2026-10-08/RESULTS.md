# Hasil perbaikan website OpenTurath — 8 Oktober 2026

Perubahan telah diterapkan pada `website/`, salinan aktif di workspace. Identitas V6 tetap dipertahankan; Fikih Tahawwulat ditempatkan sebagai bagian utama sesudah hero dan memperoleh halaman khusus. Folder `/Users/apple/Downloads/openturath-website 6` dan kode aplikasi tidak ditulis dalam pekerjaan ini. Website belum dideploy.

Preview lokal: http://127.0.0.1:4186/id/ — halaman khusus: http://127.0.0.1:4186/id/tahawwulat/.

## Yang berubah

- Artwork empat bidang memakai aset asli aplikasi, dioptimalkan menjadi WebP sekitar 168 KB. Halaman mengenalkan Iman, Islam, Ihsan, dan tanda-tanda kiamat.
- Lima asisten mengikuti urutan dan fungsi aplikasi: Al-Muhaqqiq, Al-Bayan, Al-Mukhtabir, Al-Habib, Al-Khatib. Enam kitab pengantar mengikuti IntroductionSheet. Ini pengenalan fitur; percakapan AI tetap dijalankan dalam aplikasi.
- Hero, katalog, metode, riset, akses, bantuan dan kebijakan diperbarui dalam Indonesia, Inggris dan Arab. Bahasa lebih terukur; halaman tidak lagi menjanjikan sumber yang sudah terverifikasi ketika bukti masih pending.
- Harga mengikuti sumber aplikasi: asisten umum Rp50.000/299.000/499.000 untuk 1/6/12 bulan; Tahawwulat Rp300.000/1.499.000/1.999.000. Paket 6/12 bulan menampilkan harga total periode.
- Jalur akses mengarah ke kontak, bukan putaran halaman unduhan. Tidak ada tombol unduhan atau QR untuk binary yang belum tersedia. Menyimpan laporan dijelaskan sebagai unduhan draft, bukan pengiriman.
- Halaman corpus menyajikan definisi statistik dan enam perbedaan jumlah kitab. Kartu menandai perbedaannya; angka tidak diubah sepihak atau dipromosikan menjadi jumlah karya unik/indexed.
- Privasi membedakan Research Notes lokal dari bookmark/jawaban tersinkron, dan menyebut Google/Firebase, NotebookLM, Midtrans serta kemungkinan analitik performa Cloudflare.
- Guard publikasi kini membaca proof dan release manifest: label reviewed membutuhkan bukti sumber/reviewer; harga harus cocok dengan sumber app; manifest harus konsisten dengan URL/status rilis. Pending boleh diterbitkan secara jujur.
- Tampilan mobile/RTL, tipografi Arab, spasi, tema gelap, dialog, keyboard dan reduced motion diperiksa. Link metadata di dalam kartu dibenahi agar tidak menghasilkan tautan bersarang.

Sumber app yang digunakan: `openturath_ai/lib/widgets/tahawwulat_ai_picker.dart`, `tahawwulat_introduction_sheet.dart`, metadata koleksi/training, pricing dan glossary yang direkam dalam `website/content/app-facts.json` serta `app-parity.json`.

## Status terhadap audit F01–F20

| Temuan | Perbaikan lokal | Yang masih membutuhkan bukti/operasi |
|---|---|---|
| F01 | Hero dan status kutipan tidak mengklaim verifikasi selesai. | Sepuluh kutipan Q001 tetap belum ditelaah terhadap edisi asli. |
| F02 | Label catatan rujukan, edisi/sumber pending, dan catatan metode diperjelas. | Alur contoh sampai sumber asli memerlukan edisi/link yang autentik. |
| F03 | Klaim pengujian ahli yang tidak terdokumentasi dihapus/dibatasi. | Catatan ahli, tugas, tanggal dan hasil belum disediakan. |
| F04 | Claude Code/R&D dibedakan dari runtime dan workload spesifik. | Bukti usage serta input-output workload masih perlu dokumentasi asli. |
| F05 | Copy indexing/struktur utuh/sitasi terjamin diganti uraian yang terbatas pada fakta sumber. | Manifest ingest/retrieval dan uji runtime corpus belum tersedia dalam bukti website. |
| F06 | Tujuh dimensi diselaraskan antara Research, Q001 dan Methodology. | Rubrik/ground truth dan hasil penilaian masih pending. |
| F07 | Perbedaan enam modul ditampilkan; definisi agregat metadata dijelaskan. | Pemilik data perlu menentukan unit karya/edisi/entri dan merekonsiliasi sumber. |
| F08 | Jalur akses kontak, status distribusi dan tombol diperbaiki. | File rilis publik/demo akses end-to-end belum disediakan. |
| F09 | Penyedia dan alur NotebookLM/Firebase dijelaskan berdasarkan kode app. | Kebijakan harus dicocokkan kembali dengan versi produksi yang didistribusikan. |
| F10 | Klaim absolut tanpa tracker dihapus; analitik performa Cloudflare dijelaskan. | Setting beacon/CDN live belum diubah. |
| F11 | Notes lokal dan bookmark cloud dibedakan. | Perilaku versi produksi masih perlu dicocokkan. |
| F12 | Superlatif dan janji absolut diganti fungsi/limit yang konkret. | — |
| F13 | Copy Arab mengarah pada penelusuran dan penelaahan, bukan janji tahqiq edisi kritis. | Telaah editorial tambahan oleh pembaca ahli tetap dapat dilakukan. |
| F14 | Hero Arab diringkas, tombol ditata vertikal pada layar sempit. | — |
| F15 | Kanal email dan draft lokal dijelaskan; tidak ada klaim sudah terkirim. | Mengaktifkan pengiriman server merupakan pekerjaan operasional terpisah. |
| F16 | Proof/release manifest dihubungkan dengan build guard dan sync. | Bukti verified dan binary publik harus asli sebelum status ditingkatkan. |
| F17 | Konfigurasi header diselaraskan; checker respons live ditambahkan. | Live belum menerapkan seluruh header lokal; perlu deploy/CDN yang diotorisasi. |
| F18 | Harga/cakupan umum dan Tahawwulat dipisahkan, sinkron dengan app source. | Transaksi, entitlement, login dan refund produksi belum diuji. |
| F19 | Pengulangan dan ruang dikurangi; Tahawwulat/status riset lebih mudah ditemukan. | Penerimaan estetika akhir tetap keputusan pengguna. |
| F20 | Title/deskripsi fungsi dan x-default halaman dalam dibenahi. | Pengindeksan mesin pencari tidak diverifikasi. |

## Verifikasi

- Build produksi lokal berhasil: 178 halaman HTML, 21 profil koleksi, enam jawaban asli.
- Pemeriksaan 177 halaman terlokalisasi, 12.051 tautan/aset lokal, seluruh terjemahan, enam hash arsip dan sepuluh record kutipan: lulus.
- Unit/integrasi lokal: 32 tes Node dan 13 tes Python lulus; log ada pada `tests.log`.
- Browser: 117 kombinasi (13 rute × tiga bahasa × tiga lebar 1440/390/320), tanpa overflow, gambar rusak, H1 ganda atau galat JavaScript. Sepuluh kelompok interaksi termasuk keyboard, rute, harga, draft, tema dan bahasa lulus.
- Aksesibilitas otomatis: 42 scan (tujuh rute × tiga bahasa × dua tema), nol pelanggaran WCAG 2 A/AA dan 2.1 AA yang terdeteksi. Ini hasil scan terbatas, bukan sertifikasi.
- Motion: 14 pemeriksaan lulus, termasuk pointer/touch, tahapan manuskrip, pembacaan lebih dari delapan detik, tema gelap, preferensi gerak tersimpan, system reduced motion dan tanpa JavaScript.
- Inspeksi gambar nyata meliputi hero ID/EN/AR, Arab 320px, Tahawwulat desktop/mobile, diagram Arab, daftar kitab, harga dan tema gelap. Screenshot ada di `website/docs/previews/refined/` dan `refined-motion/`.
- Pemeriksaan HTTP live bersifat baca saja dan belum lulus kesesuaian header. Detail: `website/docs/DEPLOYMENT_QA.json`. Ini tidak memengaruhi hasil build lokal dan tidak berarti deployment sudah dilakukan.

Bukti mesin: `website/docs/BUILD_REPORT.json`, `BROWSER_QA.json`, `MOTION_QA.json`. Semua perubahan dibuatkan checkpoint Git; perubahan workspace di luar website/laporan tidak diikutsertakan.

## Menjalankan ulang

Dari folder website: `npm run sync`, `npm run test`, lalu `npm run build:release`. Browser dan motion checks membutuhkan Playwright/Chrome; `AXE_SCRIPT` mengaktifkan scan axe lokal. Setelah publikasi yang diotorisasi, `npm run check:deployment` memeriksa respons live tanpa mengubah server.

Tidak ada deploy, push, pengiriman email, transaksi, unggah binary atau broadcast aplikasi dalam pekerjaan ini.
