# OpenTurath Manuskrip (manuskrip.openturath.id)

Situs statis satu halaman. Tanpa framework, tanpa langkah build.

- `index.html`: seluruh naskah halaman.
- `assets/css/site.css`: salinan gaya situs utama (token, tombol, FAQ, footer). `assets/css/m.css`: tambahan khusus halaman ini.
- `assets/js/site.js`, `boot.js`: salinan dari situs utama (tema, menu, efek muncul/ketik). `assets/js/m.js`: slider, lembaran naskah melayang (kanvas), kalkulator per kata, form.
- `assets/img/scan-p7.webp`, `hasil-p7.webp`: halaman contoh كشف الحجاب (scan dan hasil, tidak diubah). `og.png`: gambar pratinjau tautan.

Uji lokal: `python3 -m http.server 8778` di folder ini, lalu buka `http://localhost:8778/`.
Parameter `?nofx=1` mematikan animasi, `?theme=light|dark` memaksa tema.

## Sebelum dipublikasikan
1. Pastikan izin menampilkan scan dan teks halaman contoh.
2. Isi bagian "Bukti terukur" dengan angka uji 45 halaman (kartu "Menunggu uji" di `index.html`).
3. Cek ulang harga, masa simpan file (30 hari), dan cara bayar di FAQ.

## Deploy (belum dijalankan)
1. Firebase Console > Hosting > tambah situs baru (mis. `openturath-manuskrip`) di proyek yang sama.
2. Tambahkan domain khusus `manuskrip.openturath.id`; Firebase memberi record TXT/A untuk Cloudflare.
3. `firebase target:apply hosting manuskrip openturath-manuskrip` lalu deploy folder ini.
