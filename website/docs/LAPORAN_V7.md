# Laporan Website OpenTurath V7 — selaras aplikasi

Tanggal: 2026-10-14 · Folder: `06_WEBSITE_OPENTURATH_V7` · Branch lokal `v7-desain-aplikasi` (belum di-push, belum di-deploy)

## Dasar
- Isi halaman yang tidak dirombak diambil persis dari openturath.id (171 halaman dicerminkan, `content/live/`), karena situs live lebih baru daripada sumber V6 di Downloads.
- Semua angka berasal dari `assets/data/info_ai.json` aplikasi (V9.2). Build gagal bila angka website berbeda dengan aplikasi (`validateCatalogMetadata`).

## Yang berubah
| Bagian | Perubahan |
|---|---|
| Khazanah | 21 profil → 18 AI sesuai aplikasi (nama, urutan, deskripsi). Fatawa → Perbandingan Mazhab & Fatwa, Qawa'id → Ushul & Kaidah Fikih; slug lama dialihkan. |
| Habib Umar | Profil dan FAQ-nya disembunyikan; `/library/habib-umar/` dialihkan ke Khazanah. |
| Halaman AI | Mengikuti tombol info aplikasi: isi, rentang wafat, asal cetakan, cabang, kitab terbesar, cara disusun, batasan, dan daftar kitab lengkap yang bisa dicari (muhadharah Tahawwulat dengan tautan YouTube). |
| Kurasi (baru) | Kriteria dan angka penyaringan, tanpa nama tokoh yang diblok. |
| Angka | 5.383 kitab · 812,6 juta kata · 3.001 muhadharah · 46.048 rekaman diperiksa · 3.500 berkas. |
| Harga | Paket Tholib Rp 49.000 (id/en/ar, termasuk FAQ dan modul teks). |
| Teks | "khadim" → "asisten", DOKU → Midtrans, "Dua puluh disiplin" → "Delapan belas AI spesialis", Tahawwulat 1444 → 1443 H. |
| Desain | `public/assets/v7.css`: token warna, pil, kartu dari `lib/core/theme.dart` (gelap #0E0E10, aksen sian #22D3EE). Huruf: Outfit, Newsreader, dan Scheherazade New. Font Amiri dihapus. Struktur beranda tetap. |
| Perbaikan | Penghitung hasil Khazanah kini hanya menghitung kartu AI (18), sebelumnya ikut menghitung 7 kitab unggulan. |

## Verifikasi (exit 0)
- `node scripts/build.mjs --release` → 178 halaman, 10.239 tautan, tanpa galat.
- `npm test` → 23/23 test Node + 13/13 test Python lulus. Test V6 yang memeriksa angka lama ditulis ulang untuk V7.
- `cek_paritas.py`: selisih pada halaman yang tidak dirombak hanya berasal dari tautan Kurasi di footer dan penggantian teks yang disengaja.
- Pemindaian `dist/`: tidak ada lagi "Dua puluh", 50.000, 5.370, khadim, FAQ Habib Umar, atau Amiri.
- Pemeriksaan visual di browser: terang/gelap, desktop/ponsel 375px, RTL Arab, tanpa scroll horizontal, konsol bersih.
- Tidak ada berkas `._*`.

## Pembaruan 2026-10-14 (keputusan pemilik)
- **Harga**: semua halaman hanya menyebut "mulai dari Rp 49.000". Paket 299rb/499rb dan paket Tahawwulat 300rb–1,999jt dihapus dari beranda, Akses, Bantuan, dan FAQ.
- **Pembayaran**: hanya Midtrans. Daftar QRIS/VA/E-Wallet dihapus, dan DOKU di `kebijakan-aplikasi-v1.0.md` diganti Midtrans. Penyebutan NotebookLM di dokumen itu tetap, karena merupakan pengungkapan pemrosesan data pihak ketiga.
- **Unduh**: tanpa tautan berkas; semua platform berstatus "Segera Hadir".
- **Tahun wafat**: 12 kitab dikoreksi lewat `04_PIPELINE_DAN_RUANG_KERJA/v9_2/32_koreksi_wafat.py`. Bukti setiap baris ada di `OPENTURATH_V9_STAGING/v9_2/koreksi_wafat_2026_10_14.json`.
  - as-Suyuthi 19 → 911.
  - Ma'mar al-Ashbahani 13 → 564.
  - Mahmud Shafi 1405 → 1376.
  - al-Mikali 1045 → 436.
  - 8 penyair jahili → "قبل الهجرة (… م)" sesuai tabel pengarang Shamela 4.
  - Dampaknya: katalog aplikasi, tombol info, dan website dibangun ulang. Kepala kitab di 8 berkas notebook diperbarui, dan `30_cek_render.py` tetap lulus batas 497.000 kata.
  - Kasus yang buktinya bertentangan tidak diubah (daftar `tidak_diubah` di berkas yang sama).

## Perlu keputusan pemilik
1. **Aplikasi masih memakai DOKU dan harga lama.** `lib/services/doku_service.dart` dan `subscription_screen.dart` memproses pembayaran lewat DOKU; teks profil juga menyebut DOKU. Harga di `constants.dart` 50.000 / 250.000 / 450.000. Migrasi ke Midtrans butuh kunci API dan perubahan backend, jadi tidak saya sentuh.
2. Folder `_cadangan_sebelum_v9_2` di aplikasi membuat `flutter analyze` (seluruh proyek) melaporkan 327 galat; `flutter analyze lib` bersih. Sebaiknya folder itu dipindah keluar proyek.
3. Halaman AI Fikih Tahawwulat berukuran 2,3 MB karena memuat 3.001 muhadharah. Halaman tetap ringan dirender (`content-visibility`), tetapi bisa dipecah per halaman bila diinginkan.
4. Chip cabang ilmu di halaman Arab masih berhuruf Latin, karena data aplikasi hanya punya nama Latin.

## Pembaruan 2026-10-15 (pengecekan shamela.ws dan integrasi aplikasi)
- **Halaman tanpa nomor cetak.** Pengecekan ke shamela.ws/book/17882 (al-Ishthilam) menunjukkan halaman mukadimah jilid 2 tidak bernomor (ص 0). Renderer lama memberi stempel nomor urut internal Shamela, misalnya "2/293", seolah nomor halaman.
  - Perbaikan di `08_render.py`: stempel kini `[judul جزء/بلا رقم · الشاملة N]`, dengan N = nomor halaman di shamela.ws.
  - Cakupan: 711 kitab Shamela 4, 4.494 halaman. Temuan "halaman mundur" turun dari 1.426 ke 917; sisanya penomoran asli sumber.
- **Pengarang dari kartu kitab.** 36 kitab diperbaiki lewat `34_koreksi_pengarang.py`: kartu Maktabah Baru memakai label «تأليف/بقلم/جمع» yang tadinya tidak terbaca, dan ada 3 kolom pengarang berisi potongan kalimat.
  - Akibatnya "البراهين الإنجيلية" ternyata karya Muhammad Taqiyuddin al-Hilali (Salafi) dan diblok sesuai kebijakan Aswaja.
  - Bukti per kitab: `OPENTURATH_V9_STAGING/v9_2/koreksi_pengarang_2026_10_15.json`.
- **Kitab tanpa pengarang atau tahun wafat** (498 kitab). Hampir semuanya kitab tambahan Maktabah Baru ("الشاملة الصوفية/الذهبية") yang tidak ada di shamela.ws, jadi tidak bisa dicek di sana. Tidak ada yang diisi dengan tebakan.
- **Deskripsi Perbandingan Mazhab** dikoreksi: Bidayatul Mujtahid ada di AI Maliki, bukan di korpus 08.
- **Angka akhir:** 5.383 kitab, 812,6 juta kata, 3.001 muhadharah, 3.500 berkas.
