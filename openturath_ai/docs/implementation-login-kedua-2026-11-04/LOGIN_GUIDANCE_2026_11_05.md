# Penjelasan login, privasi, dan pencegahan kegagalan konfigurasi

Tanggal: 5 November 2026. Status: perubahan lokal dan APK debug; belum dirilis publik.

## Perilaku pengguna

- Sebelum tombol Google, layar login menjelaskan tahap 1 untuk mengenali akun dan memeriksa hak akses OpenTurath, serta tahap 2 untuk menghubungkan layanan AI memakai akun Google yang sama. Sesi aktif tidak perlu diulang.
- Layar penghubung Google menampilkan penjelasan ringkas tahap kedua. Penjelasan baru tersedia dalam bahasa Indonesia, Inggris, dan Arab, tanpa menyebut nama layanan di balik AI.
- Formulir alamat, telepon, atau email pemulihan pada halaman Google dijelaskan sebagai proses Google. Pengguna boleh melewati hanya apabila Google menyediakan pilihan tersebut; pemeriksaan wajib tetap harus diselesaikan.
- Akun aplikasi yang sudah aktif dapat masuk beranda melalui Masuk ke OpenTurath; koneksi AI dapat diselesaikan kemudian. Permintaan keamanan Google tidak memerlukan penghapusan akun OpenTurath.
- Tombol Penjelasan login & privasi membuka rincian dan tautan Kebijakan Privasi yang berfungsi.

## Pernyataan data yang sesuai implementasi

Klaim "tidak mengambil data sama sekali" tidak digunakan: aplikasi menerima nama, email, dan foto profil Google untuk akun, serta memproses data layanan dan diagnostik sesuai kebijakan. Naskah menjelaskan bahwa untuk login tim OpenTurath tidak meminta pengguna mengirim kata sandi Google, OTP, alamat rumah, atau informasi pemulihan; kredensial diisi hanya di halaman Google asli.

## Pencegahan teknis

- Pemeriksa APK mencocokkan paket aplikasi, sertifikat penandatanganan, Android OAuth client, dan web OAuth client dengan konfigurasi sumber. Sertifikat pada paket lama tidak diterima sebagai kecocokan.
- Pemeriksa dipasang pada alur CI sebelum pengunggahan artefak Android. Perubahan workflow belum dijalankan pada CI jarak jauh; pemeriksa telah dijalankan lokal.
- Galat native Google `ApiException: 10` ditandai G10 dengan penjelasan masalah konfigurasi aplikasi dan bahwa penghapusan akun tidak memperbaikinya. Kode lain tidak disalahklasifikasikan sebagai G10; data SDK mentah tidak ditampilkan.
- Pemeriksa lokal tidak membuktikan konfigurasi cloud terkini maupun keberhasilan semua akun. Uji login perangkat tetap diperlukan.
- Tidak mengubah hak VIP, evaluasi akses per modul, pembersihan cookie, maupun siklus hidup/readiness WebView ruang AI. Perubahan layar penghubung terbatas pada penjelasan dan tata letak responsif.

## Validasi

- Suite Flutter penuh terakhir: **704 lulus, 6 ekspor visual opsional dilewati, tidak ada kegagalan**. Rekaman JSON: `/tmp/openturath-guidance-full-final-20261105.jsonl`.
- Analisis statis seluruh aplikasi: tidak ada galat.
- 39 skenario panduan login mencakup tiga bahasa, ukuran ponsel/desktop, pembesaran teks, dialog rincian, dan pembukaan Kebijakan Privasi.
- Lima unit test pemeriksa OAuth lulus, termasuk penolakan sertifikat di paket lama. Pemeriksaan APK aktual final lulus; konfigurasi lama juga sudah diuji dan ditolak pada APK build 90 sebelumnya dengan sertifikat yang sama.
- Dua temuan pada putaran penuh awal sudah diselesaikan: penggunaan tipografi mentah diganti token desain; tes logout bersamaan menunggu selesainya pembersihan SDK yang nyata, sambil tetap memeriksa identitas aplikasi segera hilang. Tidak mengubah siklus hidup autentikasi produksi untuk menyesuaikan tes.
- APK **Standard debug 1.0.87+90** selesai dikompilasi (Gradle exit 0). Lokasi: `build/app/outputs/flutter-apk/app-debug.apk`.
- SHA-256 APK final: `b00bcbb588e75f1a09cadafea80a0f458ccd4931263c5c2372d6c7f4e9b87278`.
- Pada pemeriksaan USB terakhir, tidak ada perangkat Android terdeteksi. APK 90 belum dipasang dan panduan baru belum diuji fisik. Bukti login, persistensi sesi, dan jawaban AI di POCO F1 pada build 89 tetap tercatat terpisah dalam `android-poco-2026-11-05.json`; itu bukan bukti UI build 90.

Tidak ada upload, broadcast versi, perubahan akses pengguna, atau rilis publik dalam pekerjaan ini. Tidak ada jaminan semua galat pada semua perangkat dapat dihilangkan hanya dengan tes lokal.
