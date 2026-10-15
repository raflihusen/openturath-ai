# Publikasi

Paket belum diunggah ke domain publik. Lengkapi data asli di `site.config.json`, kemudian:

```sh
npm test
npm run build:release
npm run check
```

Konfigurasi yang disediakan kini lolos build artefak. Harga dan entitlement aplikasi, APK, serta transaksi DOKU produksi tetap perlu diverifikasi sebelum peluncuran komersial. Kegagalan build karena konfigurasi wajib kosong adalah perilaku yang diharapkan. Jangan menghapus gerbang atau `noindex` secara manual untuk menyatakan siap produksi. Setelah lolos, `dist/` merupakan hasil statis siap hosting. Aktifkan HTTPS dan origin kanonikal yang sama dengan konfigurasi; host lain dialihkan ke origin tersebut.

## A. Hosting statis

Atur `reports.enabled=false` sebelum build. Unggah **isi** `dist/` sebagai root situs. Mendukung hosting yang dapat melayani folder `index.html`: setiap URL seperti `/ar/library/` harus membuka dokumen yang sesuai. Gunakan `404.html` sebagai respons 404 dengan status HTTP 404, bukan fallback SPA berstatus 200.

`dist/_headers` menyediakan konfigurasi untuk host yang mendukung format itu. Pada host lain, terapkan header setara melalui panel/server: CSP, nosniff, referrer, frame restriction, permissions policy. Jangan berasumsi file `_headers` dijalankan oleh semua host. `sitemap.xml`, `robots.txt`, gambar sosial, font dan seluruh aset harus ikut diunggah.

Formulir dalam mode ini memberikan salinan unduhan dan kontak resmi; tidak ada penyimpanan server. Jangan mengaktifkan tombol pengiriman tanpa API.

## B. Nginx + laporan privat

Gunakan Node hanya saat build. Nginx melayani `dist/`, sedangkan proses Python WSGI hanya menerima `/api/reports`. Contoh di `deploy/nginx.conf.example` dan `deploy/openturath-reports.service.example` harus disesuaikan dengan domain, direktori, sertifikat, dan user server yang benar. File `.example` tidak aktif. Domain di contoh sudah diisi openturath.id, sedangkan sertifikat dan direktori harus tersedia pada server sebenarnya.

1. Tempatkan sumber di `/srv/openturath/current`, hasil build di subfolder `dist`.
2. Buat user layanan tanpa akses login; sediakan `/var/lib/openturath` mode 0700 milik user tersebut. Database tidak boleh ada di webroot.
3. Buat virtualenv Python dan instal Gunicorn versi yang diuji oleh operator. Dependensi ini hanya untuk produksi WSGI; tidak diperlukan untuk preview lokal. Kunci versi dalam proses deployment Anda.
4. Jalankan satu worker, beberapa thread: pembatas permintaan lokal berada di memori satu proses. Untuk skala banyak worker/node, gunakan rate limiting bersama pada reverse proxy/gateway.
5. Bind Gunicorn ke `127.0.0.1:8001`. Nginx menimpa `X-Real-IP` dengan alamat koneksi; set `OT_TRUST_LOCAL_PROXY=1` hanya pada konfigurasi proxy lokal ini. Backend tidak boleh terbuka ke internet secara langsung.
6. Jalankan purge terjadwal setiap hari dan backup privat dengan masa retensi yang sesuai.
7. Tes laporan sintetis pada domain produksi, pastikan nomor laporan muncul dan baris tersimpan. Hapus laporan tes setelah verifikasi.

API menolak origin berbeda, konten selain JSON, body terlalu besar, consent kosong, isian tidak valid dan frekuensi berlebih. Tidak ada CORS wildcard atau admin HTTP. API tidak mengirim email. Operator membaca laporan menggunakan CLI privat.

Jangan memakai `python3 server/app.py` sebagai server internet produksi. Itu server preview untuk pengembangan.

## Pengujian setelah unggah

- `/`, `/id/`, `/en/`, `/ar/`, deep route koleksi dan Q001 dapat dibuka langsung.
- URL tidak ada mengembalikan status 404; domain alternatif mengarah ke canonical.
- Tidak ada `noindex` pada halaman publik produksi; halaman 404 tetap tidak diindeks.
- QR mengarah ke halaman unduh resmi; scan memakai ponsel nyata.
- Setiap APK/listing sesuai versi, sistem minimum, ukuran, tanda tangan dan hash.
- Form sesuai mode, kontak dapat digunakan, tidak ada data laporan di URL/analytics/log publik.
- Sumber eksternal dapat dibuka; URL percakapan arsip mungkin memerlukan sesi/izin pihak ketiga, jangan mengklaim semuanya publik tanpa tes.
- Uji Safari/iOS, Chrome/Android, Firefox/Edge dan pembaca layar pada perangkat sasaran. Hasil yang sudah tersedia ada di QA.md.
- Daftarkan sitemap pada konsol pencarian milik pengelola jika diinginkan.

## Rollback

Simpan setiap build produksi sebagai direktori versi. Ubah symlink `current` secara atomik setelah pemeriksaan staging, pertahankan versi sebelumnya untuk rollback. Data laporan berada di `/var/lib/openturath`, terpisah dari build. Jangan menimpa database dengan arsip konten. Jika rilis aplikasi dicabut, nonaktifkan rilis di konfigurasi, build ulang, dan bersihkan cache halaman unduh sebelum mengumumkan pengganti.
