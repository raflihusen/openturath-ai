# Distribusi Android

APK asli belum disertakan dalam bahan audit. Folder ini tidak berisi berkas APK pengganti.

Dari root proyek, jalankan `npm run release:apk -- /path/ke/openturath-v1.0.51.apk` untuk mendaftarkan rilis asli, menyalin file, dan menghitung hash serta ukurannya. Lalu jalankan `npm test` dan `npm run build:release`.
