> Riwayat QA V4. Lihat `QA_V4_1.md` untuk hasil terbaru.

# Hasil QA V4

- Build produksi: lulus, 172 halaman yang dihitung generator.
- Pemeriksaan statis: 171 halaman lokal dan 9.882 tautan/aset, tanpa error.
- Node: 16 tes lulus.
- Python: 13 tes lulus.
- Chromium 153.0.8010.0: 90 kombinasi halaman/bahasa/lebar layar lulus.
- Interaksi: 12 skenario lulus.
- axe-core 4.13.0: 9 pemeriksaan, 0 pelanggaran otomatis.
- JavaScript runtime: 0 error pada halaman yang diuji.

Bukti rinci: BROWSER_QA.json, verification/build-release.log, verification/npm-test.log, dan previews/v4/.

Browser lokal disediakan melalui paket Chromium pengujian karena runtime tidak menyertakan executable browser. Browser QA menjalankan server dan penyimpanan laporan sementara dalam proses pengujian yang sama. Tidak ada perubahan konfigurasi produksi untuk melonggarkan pemeriksaan origin.

Pemeriksaan visual terakhir membandingkan konsep hero dengan screenshot implementasi, mencakup komposisi, hierarki, palet, logo, dan interaksi. Gambar siap decode sebelum screenshot untuk menghindari tangkapan saat ilustrasi belum selesai dilukis browser.

Batas pemeriksaan: belum ada sertifikasi WCAG, uji pembaca layar fisik, uji lintas seluruh engine browser, transaksi DOKU produksi, atau instalasi APK di perangkat nyata.
