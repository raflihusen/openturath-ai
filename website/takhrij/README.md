# Website تخريج الحديث

Situs privat. Tidak di-deploy, dan semua halaman `noindex`, sampai ada izin pemilik data.

```sh
node build.mjs
cd dist && python3 -m http.server 4190 --bind 127.0.0.1
```

- `src/copy.mjs`: naskah tiga bahasa. Teks Arab perlu diperiksa penutur asli.
- `assets/css/site.css` dan `assets/js/site.js`: salinan langsung dari website OpenTurath. Jangan diubah; tambahan ada di `assets/takhrij.css`.
- `assets/tree.mjs`: pohon dan graf sanad.
- `data/`: sanad hadis «إنما الأعمال بالنيات» dan panduan, diekspor dari aplikasi.

Sebelum terbit, baca `docs/product/KERANGKA_WEBSITE_TAKHRIJ_2026_11_01.md` di repo aplikasi.
