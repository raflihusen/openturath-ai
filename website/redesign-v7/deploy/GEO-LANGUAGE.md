> **Diperbarui 24 Oktober 2026 (keputusan Pemilik):** bahasa bawaan situs selalu Indonesia. Tebakan wilayah dari zona waktu dihapus dari `lang.js`. Pengunjung mengganti bahasa lewat tombol globe, dan pilihannya diingat (`ot-lang`). Bagian di bawah ini hanya catatan historis.

# Deteksi bahasa otomatis

**Aturan produk:** wilayah Arab membuka bahasa Arab; selain itu bahasa Indonesia (bawaan). Tidak ada halaman pilihan bahasa saat masuk. Pilihan manual pengguna selalu mengalahkan perkiraan otomatis.

## Yang sudah aktif (di `site/assets/js/lang.js`)
Perkiraan **wilayah dari zona waktu perangkat** (misalnya `Asia/Riyadh`, `Africa/Cairo`, `Asia/Aden`), tanpa permintaan jaringan. Alasan memilihnya: situs ini statis dan CSP produksi (`connect-src 'self'`) melarang memanggil layanan IP pihak ketiga. Kelemahan: pengguna di wilayah Arab yang zona waktunya diubah, atau memakai VPN, tidak terdeteksi benar.

## IP sungguhan: butuh sisi server
Situs statis tidak dapat membaca IP pengunjung. Hosting saat ini adalah Firebase Hosting (`firebase.json`, situs `openturath`). Dua jalur yang dapat dipertimbangkan, **belum diaktifkan dan belum diuji**:

1. **Firebase Hosting i18n rewrites**: konten berbahasa diletakkan di folder bernama kode negara/bahasa dan Hosting memilihnya berdasarkan lokasi dan `Accept-Language`. Perlu menyesuaikan struktur folder `dist` dan memeriksa dokumentasi Firebase terbaru.
2. **Cloud Function di balik rewrite** `/` pada domain yang sama (cocok dengan `connect-src 'self'`): fungsi membaca negara dari header permintaan, lalu membalas pengalihan 302 ke `/ar/` atau `/id/`. Nama header negara harus diverifikasi pada lingkungan produksi.

Apa pun jalurnya, aturan yang sama: pilihan manual (cookie atau `localStorage`) lebih dulu, kemudian negara, kemudian Indonesia.
