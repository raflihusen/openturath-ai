# Audit tambahan: mengapa pembaruan desktop mengunduh DMG lagi

Tanggal: 30 Oktober 2026, Asia/Aden.
Checkpoint sumber yang diperiksa: 3e4d03f9; riwayat terbaru menyebut rilis 1.0.86+87.
Lingkup: pemeriksaan kode dan rancangan solusi. Tidak ada build, instalasi, perubahan aplikasi, atau publikasi.

## Kesimpulan

Implementasi desktop sekarang adalah pemeriksa versi dan pembuka tautan unduhan. Mekanisme mengunduh di dalam aplikasi, memakai kembali paket yang sudah diunduh, memasang pengganti, dan membuka ulang aplikasi belum dibangun untuk macOS/Windows. Karena itu, perilaku mengunduh DMG melalui browser memang sesuai jalur kode saat ini.

Mengunduh DMG juga belum mengganti aplikasi yang sedang dipakai. Selama aplikasi lama masih dijalankan, pemeriksaan versi tetap menemukan build lama. Tidak ada callback instalasi desktop yang memastikan aplikasi baru sudah menggantikannya.

## Bukti jalur kode

| Tahap | Implementasi aktual | Dampak |
|---|---|---|
| Bandingkan versi | update_service.dart:137–172 membaca build aplikasi berjalan dan metadata server | Versi baru hanya terdeteksi sebagai tawaran pembaruan |
| Siapkan pembaruan desktop | Baris 181–189 mengatur isDownloaded=false dan langsung readyToInstall, lalu return | Pengunduhan dan validasi berkas di jalur berikutnya dilewati |
| Tentukan siap | Baris 86–88 mengembalikan true untuk desktop tanpa berkas lokal | Siap berarti tautan dapat dibuka, bukan paket sudah siap dipasang |
| Tombol pasang | Baris 396–404 memanggil launchUrl dengan externalApplication | Browser membuka URL DMG/installer; tidak memasang berkas yang sudah diunduh |
| Pemakaian cache | Baris 203 dan seterusnya hanya tercapai setelah return desktop; nama berkas lokal berakhiran APK | Tidak ada cache DMG yang dikelola updater aplikasi |
| Ulangi tawaran | dashboard_screen.dart:67,95–99 menyimpan penanda dialog hanya di memori widget | Dashboard/proses baru dapat menampilkan tawaran lagi ketika build berjalan masih lama |

Rujukan:

- [UpdateService](/Users/apple/Downloads/ramadhan/openturath_ai/lib/services/update_service.dart:181)
- [Aksi tombol pembaruan](/Users/apple/Downloads/ramadhan/openturath_ai/lib/services/update_service.dart:396)
- [Pemicu dialog dashboard](/Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/dashboard_screen.dart:93)

Tidak ditemukan integrasi Sparkle, updater native pengganti, SUFeedURL, atau SUPublicEDKey pada source macOS/pubspec yang diperiksa. Info.plist belum mempunyai konfigurasi feed updater.

## Mengapa unduhan terasa berulang

Urutan yang dapat terjadi berdasarkan kode:

1. Aplikasi lama berjalan dan menemukan build server lebih tinggi.
2. Pengguna menekan Perbarui; browser mengunduh DMG.
3. Pengguna membuka DMG tetapi belum mengganti aplikasi lama pada lokasi instalasi, atau menjalankan salinan lama lagi.
4. Aplikasi lama tetap melaporkan nomor build lama.
5. Tombol Perbarui kembali membuka URL yang sama. Updater tidak mengetahui berkas yang sudah ada di Downloads.

Langkah ketiga merupakan skenario yang perlu diperiksa pada perangkat pengguna, bukan kejadian yang telah diamati dalam audit ini. Membuka aplikasi dari volume DMG, mempunyai dua salinan aplikasi, atau shortcut yang mengarah ke salinan lama juga perlu diperiksa bila keluhan berulang setelah pengguna merasa sudah memasang.

Menyimpan penanda “sudah diunduh” saja tidak menyelesaikan masalah: tanpa pemasang, berkas tetap tidak mengganti aplikasi lama. Menyembunyikan notifikasi juga hanya menutupi perbedaan versi.

## Perbedaan platform

- Android sudah mempunyai pengunduhan, cache, dan pemeriksaan SHA-256 di dalam aplikasi. Tombolnya membuka Package Installer sistem. Persetujuan pemasangan tetap mengikuti sistem; kode ini bukan pemasangan tanpa interaksi.
- macOS dan Windows memakai jalur pembuka URL yang sama. Keduanya belum mempunyai pemasangan otomatis dari paket lokal melalui UpdateService.
- DMG dapat tetap digunakan untuk pemasangan awal. Kebutuhan updater adalah mengelola penggantian aplikasi; mengganti ekstensi DMG menjadi ZIP saja tidak membangun kemampuan tersebut.

## Solusi yang direkomendasikan

Untuk macOS, gunakan Sparkle 2 melalui integrasi native pada Runner, dihubungkan ke Flutter bila diperlukan untuk tombol/status. Sparkle menyediakan pemeriksaan feed, pengunduhan, validasi, dan pemasangan/relaunch. Konfigurasi memerlukan framework, feed pembaruan, dan public key; paket pembaruan ditandatangani, disajikan melalui HTTPS, serta aplikasi didistribusikan dengan signing/notarisasi yang sesuai. Lihat [panduan resmi Sparkle](https://sparkle-project.org/documentation/).

Pengalaman yang dituju:

**Versi baru tersedia → unduh di latar belakang → verifikasi → “Pasang dan buka ulang” → aplikasi menutup dengan tertib → updater mengganti aplikasi → versi baru dibuka.**

Rencana implementasi:

1. Tetapkan satu mekanisme updater macOS. Cabang desktop pembuka URL tidak boleh terus menjadi aksi utama jika updater native sudah digunakan.
2. Pisahkan status tersedia, mengunduh, unduhan gagal, paket terverifikasi, memasang, dan selesai. Jangan gunakan readyToInstall sebelum paket benar-benar siap.
3. Siapkan feed dan paket berversi yang tidak ditimpa. Metadata, nomor build embedded, dan tanda tangan harus sesuai artefak.
4. Integrasikan penghentian/relaunch yang tertib. Jangan menghapus cookie, cache profil, direktori WebView, atau Keychain ketika mengganti bundle aplikasi. Identitas aplikasi dan penandatanganan harus stabil.
5. Tampilkan kegagalan dengan tindakan lanjut bila lokasi aplikasi tidak dapat ditulis, aplikasi dijalankan dari DMG, ruang penyimpanan kurang, atau verifikasi gagal. Sistem mungkin tetap meminta otorisasi tergantung lokasi/hak instalasi.
6. Verifikasi build sesudah relaunch; jangan menyatakan selesai hanya karena unduhan atau proses pembuka URL berhasil.
7. Windows memerlukan keputusan pemasang/updater tersendiri; Sparkle bukan solusi untuk Windows.

Patch/delta dapat dipertimbangkan setelah alur paket penuh stabil; pembaruan otomatis tidak berarti setiap rilis pasti hanya mengunduh bagian kecil. Mekanisme pemasangan dan ukuran unduhan merupakan dua keputusan berbeda.

## Transisi untuk aplikasi yang sudah terpasang

Versi lama belum memiliki mesin updater native, sehingga perubahan metadata Firestore saja tidak dapat membuatnya memasang otomatis. Diperlukan satu pembaruan transisi melalui mekanisme yang sudah tersedia untuk memasukkan updater. Sesudah versi transisi terpasang, pembaruan berikutnya dapat menggunakan alur baru.

Temuan tanda tangan DMG build 86 dalam audit 29 Oktober bersifat historis. Karena source sekarang sudah mempunyai checkpoint rilis build 87, status tanda tangan/Gatekeeper artefak baru harus diperiksa lagi; jangan menganggap hasil artefak lama otomatis berlaku untuk yang baru.

## Kriteria penerimaan

| Skenario | Hasil yang wajib diuji |
|---|---|
| Paket sudah diunduh dan valid | Tombol memasang memakai paket tersebut, tanpa unduhan kedua |
| Aplikasi ditutup saat mengunduh | Perilaku cache/retry jelas; paket parsial tidak dianggap siap |
| Paket rusak atau signature tidak cocok | Tidak dipasang; pengguna mendapatkan penjelasan |
| Instalasi berhasil | Aplikasi dibuka kembali dengan build baru; tawaran versi sama hilang |
| Instalasi gagal atau butuh hak tambahan | Aplikasi lama tetap dapat dipakai; status tidak mengaku selesai |
| Pengguna menjalankan salinan lama/dari DMG | Lokasi yang dipakai dapat didiagnosis dan diarahkan ke instalasi yang benar |
| Update dengan sesi Google aktif dan beberapa tab | Data sesi dipertahankan; tidak ada pembersihan cookie sebagai bagian pembaruan |

Audit tambahan ini membuktikan ketiadaan jalur instalasi desktop pada implementasi sekarang. Belum dilakukan pemasangan Sparkle atau uji update antar dua binary nyata.
