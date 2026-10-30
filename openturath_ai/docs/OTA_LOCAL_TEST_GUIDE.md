# OTA: alur baru dan pengujian lokal

Tanggal: 30 Oktober 2026. Seluruh pekerjaan pada dokumen ini adalah lokal.
Tidak ada deploy Hosting/Functions, penulisan konfigurasi versi produksi, atau broadcast update.

## Perubahan

- macOS, Windows, dan Android memakai cache paket terverifikasi. Tombol pemasangan memakai berkas lokal, bukan membuka browser.
- Status tersedia, mengunduh, siap dipasang, dan menyiapkan pemasangan dipisahkan. Siap hanya diberikan setelah checksum cocok.
- Paket rusak atau redirect menuju host yang tidak dipercaya ditolak. Percobaan ulang pemasangan menggunakan cache yang masih valid.
- Cache mempertahankan paket saat ini, satu versi sebelumnya, dan paket yang sedang dipakai pemasang. Cadangan yang terkonfirmasi dibatasi berdasarkan kepemilikan target.
- Tidak ada perubahan pada dua berkas siklus hidup WebView yang dilindungi. Tidak ada penghapusan cookie, perubahan hak langganan, atau operasi VIP.

## macOS

Pemasang membaca DMG lokal, memeriksa hash, bundle identifier, build, signature, dan kebijakan Gatekeeper. Aplikasi disiapkan di folder sebelah target sebelum aplikasi berjalan ditutup. Penutupan dilakukan melalui NSApplication, bukan penghentian proses Dart secara paksa.

Helper menunggu proses lama berakhir, mempertahankan bundle lama, mengganti aplikasi, dan membukanya kembali. Build baru harus mengonfirmasi frame pertama dari lokasi instalasi dan nomor build yang benar. Jika tidak ada konfirmasi dalam batas waktu, helper memulihkan bundle lama.

Aplikasi yang dijalankan dari volume DMG atau lokasi yang tidak dapat ditulis ditolak sebelum proses lama ditutup. Dalam distribusi normal, paket ad-hoc/tidak dipercaya ditolak. Mode penandatanganan uji hanya untuk debug dan dilarang pada build release.

Implementasi mengikuti metadata rilis yang sudah ada, dengan helper lokal. Ini bukan integrasi Sparkle dan tidak memerlukan feed Sparkle baru.

## Windows

- Gunakan pemasang baru yang mempunyai protokol OTA. Pemasang lama belum memahami perintah pembaruan dan tidak boleh ditandai kompatibel.
- Metadata platforms.windows perlu installer_protocol=1, SHA-256 paket yang benar, nomor build embedded yang sesuai, dan URL EXE.
- Helper memeriksa hash dan signature pemasang, menunggu aplikasi menutup melalui pesan jendela, menjalankan core installer, memeriksa exit code, dan membuka aplikasi kembali.
- Salinan aplikasi sebelumnya disimpan untuk pemulihan bila pemasang gagal atau build baru tidak mengonfirmasi startup. Profil pengguna tidak termasuk objek yang diganti.
- Folder instalasi harus dapat ditulis oleh pengguna yang menjalankan updater. Instalasi khusus yang dilindungi izin administrator masih memerlukan pengujian/perencanaan hak akses pada PC Windows.
- Build helper/pemasang harus diuji pada Windows asli. Tes PowerShell di Mac menggunakan fixture untuk API proses dan penandatanganan, sehingga bukan bukti UAC, kunci berkas Windows, atau keberhasilan Inno Setup pada perangkat.

Pemilik menyatakan akan menguji Windows sendiri. Tidak ada EXE Windows baru yang dibangun pada host macOS ini.

## Android

APK lokal diperiksa lagi sebelum diteruskan ke pemasang: identitas paket harus sama, nomor versi harus lebih tinggi dan sesuai penawaran, serta signature harus cocok dengan penerbit yang sudah terpasang. Jika izin memasang aplikasi belum diberikan, Android membuka pengaturan izin. Setelah izin disetujui, pemasang melanjutkan dengan berkas tersimpan tanpa mengunduh lagi.

Konfirmasi Android tetap berlaku. Receiver mencatat penggantian paket sendiri dan mencoba membuka aplikasi kembali. Sistem Android tertentu dapat membatasi pembukaan dari latar belakang; tombol Open/Buka dari pemasang sistem tetap menjadi jalan yang sah. Implementasi tidak meminta root, device-owner, atau menonaktifkan perlindungan sistem.

Untuk uji APK debug, gunakan emulator/perangkat uji yang terpisah. Jangan menghapus aplikasi pengguna beserta datanya hanya untuk mengatasi perbedaan signature debug/release. Uji pembaruan pada instalasi berdata nyata memerlukan paket dengan identitas penandatanganan yang sama.

## Tes otomatis lokal

Tes Dart/Flutter:

- test/ota_install_flow_test.dart: HTTP lokal sungguhan, cache setelah proses dibuat kembali, ketiga platform, hash salah, paket yang diubah, HTTP gagal, redirect berbahaya, retry pemasang, klik ganda, serta retensi paket.
- test/ota_startup_confirmation_test.dart: build lama, salinan aplikasi lain, status rollback, direktori staging asing, dan pembatasan cadangan tidak boleh mengonfirmasi/menghapus objek yang salah.
- test/update_service_recheck_test.dart, platform_release_edition_test.dart, desktop_release_test.dart, launch_localization_test.dart, desktop_transport_test.dart menjadi pemeriksaan regresi terkait.

Tes pemasang macOS nyata dengan bundle kecil terpisah:

```sh
python3 tool/test_macos_update.py
```

Tes ini membuat DMG, memakai hdiutil/codesign/open yang nyata, menunggu proses sebelumnya, menguji penggantian dan pembukaan ulang, menguji rollback startup gagal, serta memeriksa berkas data di luar bundle tetap ada. Fixture bukan akun/profil pengguna produksi dan menggunakan ad-hoc secara eksplisit.

Tes kontrol helper Windows:

```powershell
powershell -NoProfile -File tool/test_windows_update.ps1
```

Tes ini menjalankan source helper sesungguhnya. Operasi berkas/hash nyata; proses OS/signature memakai fixture. Hasil lulus tetap perlu dilanjutkan dengan pemasang sungguhan pada Windows.

## Fixture desktop tanpa backend produksi

Entry tool/ota_desktop_smoke.dart hanya untuk pengujian. Ia tidak menjalankan Firebase/login. Manifest dibaca dari berkas lokal yang ditentukan saat build, dan paket dilayani lewat HTTP loopback. Service unduh, cache, handoff native, serta konfirmasi startup yang dipakai adalah implementasi yang sama.

Contoh manifest lokal, dengan nilai paket, versi, dan hash yang sesuai binary uji:

```json
{
  "package": "C:\\path\\to\\local-test-installer.exe",
  "build": 87,
  "version": "1.0.86",
  "sha256": "HASH_SHA256_PAKET_UJI"
}
```

Nomor tersebut hanya contoh fixture. Build target wajib lebih tinggi daripada aplikasi uji yang berjalan. Pada macOS, package menunjuk DMG lokal.

Untuk Windows, langkah pengujian pada checkout uji adalah:

1. Bangun entry fixture sebagai aplikasi debug dengan build lebih rendah. Tentukan OT_OTA_LOCAL_MANIFEST menuju JSON uji dan OT_OTA_ALLOW_ADHOC_TEST=true. Salin SELURUH bundle exe/DLL/data ke folder uji yang dapat ditulis.
2. Bangun calon versi lebih tinggi dari entry fixture, siapkan payload lengkap beserta prasyarat Microsoft, lalu bangun pemasang OTA baru. Jangan menggunakan pemasang lama.
3. Gunakan opsi -LocalOnly -PayloadDirectory pada tool/build_windows_installer.ps1. EXE uji ditulis ke build/installer_stage/OpenTurath_AI_Windows_LocalTest_Setup.exe; opsi ini tidak menyalin EXE ke direktori distribusi public.
4. Tulis manifest lokal sesuai hash EXE uji dan versi embedded. Jalankan salinan aplikasi debug di folder uji, pilih Check local update, tunggu siap, kemudian Install and restart fixture.
5. Pastikan aplikasi lama menutup, pemasang tidak membuka browser, build baru muncul, dan status staging menjadi confirmed. Putuskan internet setelah paket siap untuk membuktikan pemasangan memakai berkas lokal.
6. Uji pembatalan, signature tidak dipercaya, paket diubah setelah diunduh, lokasi tidak dapat ditulis, dan kegagalan startup. Versi lama harus tetap dapat dipakai atau dipulihkan; tidak boleh ada keberhasilan palsu.

Mode uji tidak boleh dimasukkan ke rilis publik. Aplikasi release menolak bypass penandatanganan. Build normal tetap memerlukan penandatanganan/notarisasi yang sesuai platform.

## Batas dan syarat sebelum publikasi

- Instalasi pengguna yang masih memakai updater lama memerlukan satu pemasangan transisi untuk mendapatkan kode updater ini. Konfigurasi server tidak dapat menambahkan helper ke binary lama.
- Nomor build rilis berikutnya harus meningkat; jangan memakai ulang build produksi 87 untuk binary baru. Versi tidak dinaikkan dan metadata produksi tidak disentuh dalam pekerjaan lokal ini.
- Pembaruan pada platform/edisi lain tetap dipisahkan. Metadata versi tidak boleh menunjuk binary atau pemasang yang berbeda dari yang telah diuji.
- APK/DMG/EXE untuk distribusi tidak dibuat dari entry fixture. Entry produksi tetap lib/main.dart.
- Keberhasilan tes unit, kompilasi native, fixture, dan uji perangkat harus dilaporkan sebagai bukti yang berbeda. Tidak ada klaim seluruh perangkat sudah lulus sebelum pengujian nyata selesai.
