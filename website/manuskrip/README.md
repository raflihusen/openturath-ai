# OpenTurath Manuskrip (manuskrip.openturath.id)

Situs statis satu halaman. Tanpa framework, tanpa langkah build.

- `index.html`: seluruh naskah dan struktur halaman (termasuk metadata SEO & JSON-LD).
- `assets/css/site.css`: fondasi gaya OpenTurath V7 (token, tombol, FAQ, footer). `assets/css/m.css`: gaya khusus halaman Manuskrip.
- `assets/js/boot.js`: inisialisasi ringan tema terang dan `?nofx=1`.
- `assets/js/site.js`: menu ponsel dengan focus trap, scroll reveal non-blocking, dan progress bar.
- `assets/js/m.js`: slider before/after, kanvas latar hero (dengan tombol jeda animasi), kalkulator per kata (+ tombol pengisi formulir otomatis), dan formulir pesan (+ salin ke clipboard).
- `assets/fonts/`: `googlesansflex.woff2`, `scheherazade-new-arabic-400-normal.woff2`, `scheherazade-new-arabic-700-normal.woff2`.
- `assets/img/scan-p7.webp`: pindaian halaman 3 kitab كشف الحجاب untuk sisi kiri slider (sisi kanan menggunakan teks Arab HTML hidup). `og.png`: gambar pratinjau tautan.
- `robots.txt` & `sitemap.xml`: siap produksi untuk `https://manuskrip.openturath.id/`.

Uji lokal: `python3 -m http.server 8778 --bind 127.0.0.1` di folder ini, lalu buka `http://localhost:8778/`.
Parameter `?nofx=1` mematikan animasi.

## Sebelum dipublikasikan
1. Pastikan izin menampilkan scan dan teks halaman contoh.
2. Isi bagian "Bukti terukur" dengan angka uji 45 halaman (kartu "Menunggu uji" di `index.html`).
3. Cek ulang harga, masa simpan file (30 hari), dan cara bayar di FAQ.

## Deploy (belum dijalankan)
1. Firebase Console > Hosting > tambah situs baru (mis. `openturath-manuskrip`) di proyek yang sama.
2. Tambahkan domain khusus `manuskrip.openturath.id`; Firebase memberi record TXT/A untuk Cloudflare.
3. Konfigurasikan target hosting `manuskrip` dengan header CSP & HSTS setara situs utama, lalu deploy folder ini atas instruksi eksplisit pemilik.
