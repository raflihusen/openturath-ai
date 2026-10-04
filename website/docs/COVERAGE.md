> Arsip revisi sebelumnya. Status terbaru ada pada AUDIT_WEBSITE_V4.md dan BROWSER_QA.json.

# Penerapan 21 bagian spesifikasi

Dokumen ini memetakan implementasi yang diserahkan dan ketergantungan faktualnya. “Tersedia” berarti fitur/konten ada pada paket, bukan bahwa aplikasi atau domain sudah diterbitkan.

| Bagian MASTER_SPEC | Implementasi | Status / batas |
|---|---|---|
| 1. Tujuan dan batas produk | Situs publik → katalog/bukti → halaman unduh; tanpa akun situs | Tersedia; layanan AI berada di aplikasi |
| 2. Identitas dan suara | Tagline persis, wordmark tipografis, editorial monokrom, copy tiga bahasa | Tersedia; bukan klaim logo final yang sudah disetujui |
| 3. Bahan dan bukti | Enam transkrip, SHA-256, arsip mentah, metadata yang diketahui | Tersedia; tidak mengarang verifikasi sumber |
| 4. Peta situs | 53 rute lokal x 3 + pemilih bahasa | 160 dokumen, ditambah file 404 hosting; status/jurnal kondisional tidak diisi fiktif |
| 5. Navigasi global | Header, footer, menu ponsel, bahasa, breadcrumb, CTA | Tersedia; dialog native dan fokus kembali |
| 6. Beranda | Pembuka, contoh sumber, koleksi, hasil, metode, Tahawwulat, akses, FAQ, unduh | Tersedia; tanpa angka pengguna/testimoni rekaan |
| 7. Naskah tiga bahasa | copy.mjs dan articles.mjs; lang/dir tiap halaman | Lengkap secara teknis; telaah editorial penutur asli masih disarankan sebelum rilis |
| 8. Pustaka/bibliografi | 20 koleksi, pencarian judul/pengarang, filter, 7 karya Q001 | Tersedia; bukan publikasi keseluruhan isi kitab; jumlah kitab tidak ditebak |
| 9. Pengujian | Dua panel desktop, tab ponsel, enam jawaban lengkap, 10 panel kutipan, highlight, unduh arsip, 7 dimensi telaah | Tersedia; edisi/scan/lembar penelaahan independen belum disediakan; tidak ada klaim 100% |
| 10. Unduh/akses | CTA → halaman unduh; platform, saran perangkat, hash, metadata, alternatif resmi, rilis dicabut, QR, paket tiga bahasa | Mesin halaman tersedia; URL/APK/harga resmi masih diperlukan; deep link tampil hanya setelah konfigurasi dan penanda telah diuji |
| 11. Sistem visual/interaksi | Font lokal, warna, spasi, panel, light/dark, entrance ringan, hover/focus, reading mode | Tersedia; tanpa video/animasi besar yang menghambat pembacaan |
| 12. Bahasa/aksesibilitas | RTL, Arab/Latin, skip-link, landmark, label, dialog native, tab keyboard, reduced motion, no-JS fallback | Tersedia; sertifikasi WCAG dan tes pembaca layar fisik belum dilakukan |
| 13. Keadaan UI | Loading form, sukses sesuai server, kegagalan, duplikasi, kosong, unavailable, 404, copy failure | Tersedia; kehilangan respons dan penyuntingan saat menunggu ditangani |
| 14. Arsitektur/data | Generator statis, data berkas, konfigurasi, bibliografi, run, bukti, koreksi, SQLite privat | Tersedia; CMS berupa berkas, tidak ada panel admin publik; register klaim kosong |
| 15. SEO/performa | HTML awal, judul/deskripsi, canonical/alternate, sitemap, OG PNG, JSON-LD faktual, font lokal, preview noindex | Tersedia; domain diperlukan; pengukuran lapangan/indeks pencarian baru setelah publikasi |
| 16. Privasi/hak/keamanan | Escaping, URL HTTPS, CSP/header, origin, validasi, rate limit, idempotensi, data privat; kebijakan dan kanal | Implementasi tersedia; identitas/praktik data aplikasi/izin transkrip dan kebijakan final memerlukan pengelola |
| 17. Analitik/operasi | Tanpa tracker; CLI laporan; retensi; panduan backup/rollback/insiden; template WSGI/proxy | Tersedia; integrasi analitik eksternal/status otomatis belum diaktifkan dan tidak diklaim ada |
| 18. Penerimaan | Pengujian unit, API, build produksi terisolasi, integritas arsip, audit ribuan tautan, browser | Hasil dan cakupan nyata dicatat QA.md; perangkat/browser di luar lingkungan ini masih perlu tes |
| 19. Produksi/publikasi | Build preview, gerbang produksi, template deploy, pedoman HTTPS/domain, pemeriksaan setelah unggah | Paket dapat dijalankan; domain eksternal tidak dipublikasikan dalam tugas ZIP |
| 20. Data yang diperlukan | BUILD_REPORT.json dan CONFIGURATION.md | 11 kebutuhan konfigurasi/persetujuan saat serah terima; bukan error generator |
| 21. Serah terima | Source + dist + README + docs + tes + ZIP + manifest SHA256SUMS | Tersedia setelah kemasan diverifikasi; data laporan pribadi dikecualikan |

## Tindakan pemilik yang tidak dapat digantikan oleh kode

1. Masukkan domain dan artefak/listing aplikasi sebenarnya beserta metadata rilis.
2. Tentukan paket akses dan ketentuan nyata dalam tiga bahasa.
3. Isi pengelola/kontak dan selaraskan halaman kebijakan dengan praktik aplikasi/hosting.
4. Pastikan hak font/transkrip/sumber dan persetujuan katalog. Lisensi font yang tersedia disertakan.
5. Jika ingin menerbitkan skor kecocokan sumber, sediakan sumber/edisi dan catatan per kutipan. Klaim universal “100% akurat” tidak didukung oleh satu kasus.
6. Jalankan tes perangkat produksi, verifikasi sumber/unduhan eksternal, lalu publikasi build release pada domain milik Anda.
