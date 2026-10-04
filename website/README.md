# OpenTurath — landing page

Situs statis tiga bahasa (ID, EN, AR) untuk mengenalkan OpenTurath dan mengarahkan pengunjung ke unduhan. Tanpa dependensi npm; butuh Node.js 22+.

```sh
npm run sync           # baca versi, harga, dan Android minimum dari ../openturath_ai
npm run build          # pratinjau (noindex) ke dist/
npm test               # paritas fakta, pedoman suara, tautan, gerbang rilis
npm run build:release  # menolak berjalan bila ada fakta yang belum beres
```

## Sumber kebenaran

| Hal | Sumber | Catatan |
|---|---|---|
| Versi, harga, Android minimum | `content/app-facts.json` | Dihasilkan `npm run sync` dari kode aplikasi; tes gagal bila berbeda |
| Bidang ilmu dan angka katalog | `content/catalog.json` | Total dihitung saat build |
| Contoh ibarah di beranda | `content/proof.json` | `reviewed` harus `true` sebelum rilis |
| Berkas unduhan | `content/releases.json` | Isi `url`, `sizeBytes`, `sha256`, `date`; selama kosong tampil "Segera tersedia" |
| Naskah | `src/copy.mjs` | Tiga bahasa per entri; mengikuti `openturath_ai/DESIGN.md` |
| Kebijakan | `src/articles.mjs` | Ringkasan; naskah lengkap di `public/assets/kebijakan-aplikasi-v1.0.md` |

## Yang menahan rilis

`npm run build:release` berhenti bila: fakta aplikasi berubah tanpa `npm run sync`, contoh ibarah belum ditinjau, atau data unduhan tidak lengkap (URL bukan https, SHA-256 tidak sah).

## Halaman yang dirilis

Beranda, Unduh, Akses, Ketentuan, Privasi, Pembayaran dan pengembalian dana, Penghapusan akun, Panduan AI, Kontak, dan 404. Daftarnya ada di `site.config.json` (`releaseRoutes`).

## Hosting

Firebase Hosting dengan konfigurasi sendiri di `firebase.json` (header keamanan dan cache). Situs memakai nama `openturath-landing`; buat dulu di konsol Firebase atau ganti nilainya dengan situs yang sudah ada. Konfigurasi aplikasi di `../openturath_ai/firebase.json` tidak disentuh.

```sh
npm run build:release
firebase hosting:channel:deploy pratinjau --config firebase.json --project <id-proyek>   # URL sementara
firebase deploy --only hosting --config firebase.json --project <id-proyek>              # produksi
```

Berkas APK, DMG, dan installer tidak di-hosting di sini: paket gratis Firebase hanya memberi 360 MB transfer per hari. Taruh di GitHub Releases lalu isi `content/releases.json`.
