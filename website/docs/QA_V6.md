# Verifikasi V6

- Node.js: 23 lulus, 0 gagal.
- Python: 13 lulus, 0 gagal.
- Release: 172 halaman, 9.705 tautan/aset lokal, 6 hash arsip, 10 catatan kutipan; 0 error.
- Chromium 153.0.8010.0: 90 kombinasi halaman/bahasa/viewport, 15 interaksi.
- Axe: 9 pemeriksaan, 0 pelanggaran terdeteksi.
- Motion: 14 pemeriksaan, termasuk penundaan membaca lebih dari 8 detik, empat tahap verifikasi, keyboard, reduced motion, touch, dan no-JS.
- Angka corpus desktop 165,888 px; ponsel 113,1 px. Angka kartu unggulan 112 px, sekunder 27 px. Judul kartu ponsel 26 px.

Log final berada di `docs/verification/*-v6.log`; `visual-v6.log` memuat pemeriksaan motion. Rincian JSON berada di `docs/BROWSER_QA.json`, `docs/MOTION_QA.json`, dan `docs/BUILD_REPORT.json`.

Konsep dan tangkapan browser dibandingkan secara visual pada 1536×1024; ponsel 390×844; pemeriksaan layout tambahan 1440/390/320 px. Browser terhubung tidak dapat mengakses localhost sehingga implementasi diperiksa di Chromium lokal. Tidak ada transaksi atau laporan yang dikirim ke produksi. Safari/Firefox dan perangkat fisik belum diuji.

Lihat `AUDIT_WEBSITE_V6.md` untuk ledger visual, daftar perubahan, sumber, dan batas verifikasi.
