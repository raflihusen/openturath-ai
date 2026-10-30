# Verifikasi OTA lokal — 30 Oktober 2026

Perubahan ini belum dirilis, diunggah, atau disiarkan ke konfigurasi versi produksi. Nomor versi publik tidak dinaikkan. Implementasi memakai paket lokal terverifikasi untuk macOS, Windows, dan Android; tombol pemasangan tidak lagi membuka tautan unduhan browser.

## Bukti dan batas pengujian

| Pemeriksaan | Hasil | Cakupan sebenarnya |
|---|---|---|
| Tes Dart/Flutter terkait | 48 lulus | HTTP dan berkas lokal nyata, cache lintas pembuatan service, tiga platform, hash/redirect salah, retry tanpa unduh ulang, klik ganda, retensi, konfirmasi startup, serta regresi versi/lokalisasi/transport |
| Analisis Dart | Tidak ada galat | Analisis seluruh proyek; fixture diperiksa ulang setelah perubahan terakhir |
| Pemasang macOS native | 7 lulus | Bundle kecil bertanda tangan ad-hoc, DMG/hdiutil/codesign/open nyata, sukses, rollback, pembatalan, staged bundle diubah, serta penanda data di luar bundle |
| Alur aplikasi Flutter macOS | Berhasil, 26,28 detik | Fixture terisolasi build 87 mengunduh DMG 50.628.522 byte melalui loopback, native quit berstatus 0, berganti ke build 88, terbuka kembali, dan menghasilkan status confirmed |
| Kontrol helper Windows | 5 lulus | PowerShell 7 pada macOS; berkas/hash/backup nyata, API signature dan proses Windows diganti fixture. Sukses, installer gagal, startup gagal, hash salah, penerbit tidak dipercaya |
| Swift Runner | Typecheck berhasil | Channel penghentian native; ada peringatan API showsResizeIndicator lama |
| Kotlin Android/Gradle | Kompilasi berhasil | :app:compileReleaseKotlin offline, target fixture, compileFlutterBuildRelease dikecualikan; bukan keberhasilan build APK lengkap |

Alur Flutter macOS memakai source Runner AppDelegate/MainFlutterWindow aktual, framework Flutter, package_info_plus, path_provider, dan service/helper updater aktual. Bundle ID berbeda (`com.openturath.ota.fixture`); tidak memakai Firebase, login, atau profil Google pengguna. Konfirmasi startup membuktikan frame Flutter baru terbentuk, bukan keberhasilan login atau kesiapan seluruh fitur produksi.

Pengujian menemukan bahwa perintah assemble uji semula hanya meneruskan satu konfigurasi Dart. Diagnostik fixture menunjukkan adHoc=false, dan helper dengan benar menolak DMG ad-hoc. Perintah uji diperbaiki hingga diagnostik adHoc=true; penjagaan release yang menolak bypass tetap dipertahankan.

## Yang belum terbukti

- Instalasi EXE, Windows C++ Runner, Inno Setup, izin/UAC, dan pembukaan ulang pada PC Windows asli. Pengguna memilih menguji sendiri. Ikuti [panduan uji lokal](OTA_LOCAL_TEST_GUIDE.md); script PowerShell yang lulus di macOS bukan pengganti uji Windows.
- Instalasi APK pada Android asli/emulator. Kompilasi native berhasil, tetapi pengambilan dependency debug dan system image emulator gagal karena koneksi unduhan. Tidak ada klaim APK lengkap atau pemasangan Android sudah lulus.
- Build produksi Flutter lengkap dan pembaruan antar binary produksi bertanda tangan resmi. Percobaan kompilasi macOS penuh terhenti karena ruang disk; fixture terisolasi dipakai untuk membuktikan alur updater. Objek compiler release yang dipindah sementara sudah dikembalikan.
- Pembukaan otomatis setelah pemasangan Android dapat dibatasi OS. Persetujuan pemasang sistem dan tombol Buka tetap berlaku.
- Paket distribusi macOS harus memiliki Developer ID/notarisasi yang diterima Gatekeeper; Windows harus memakai penandatanganan yang dipercaya. Fixture ad-hoc tidak membuktikan kesiapan distribusi publik.

## Perilaku yang diperbaiki

Paket yang sudah diunduh disimpan dan diverifikasi ulang sebelum digunakan. Desktop menunggu helper siap sebelum menutup aplikasi dengan tertib. Bila startup versi baru tidak terkonfirmasi, helper mencoba mengembalikan aplikasi sebelumnya. Data profil, cookie, dan Keychain tidak dibersihkan oleh updater.

Instalasi lama yang belum mempunyai helper ini masih memerlukan satu pemasangan transisi. Setelah itu pembaruan berikutnya dapat menggunakan alur baru. Sebelum publikasi, seluruh uji perangkat yang belum terbukti di atas harus diselesaikan; metadata Windows juga wajib menyertakan installer_protocol=1 dan hash paket yang sesuai.
