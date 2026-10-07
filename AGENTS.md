# Workspace Rules — OpenTurath AI

## 1. Automatic Checkpoint Protocol (MANDATORY)
- **Setiap perubahan sekecil apapun WAJIB langsung dibuatkan check point (Git commit) secara otomatis.**
- Setiap kali file kode, aset, UI, konfigurasi, atau unit test dimodifikasi atau ditambahkan:
  1. Jalankan `git add <files>`
  2. Lakukan commit dengan pesan yang deskriptif dan terstruktur: `git commit -m "<type>(<scope>): <pesan detail perubahan>"`
- Jangan pernah membiarkan perubahan menumpuk tanpa check point.
- Check point harus selalu dibuat secara otomatis tanpa menunggu instruksi tambahan dari pengguna.

## 2. Integritas Build & Release
- Setiap pembuatan APK rilis harus memverifikasi bahwa proses kompilasi Gradle selesai 100% dan file binary rilis yang disalin ke `/Users/apple/Downloads/ramadhan/app-release-latest.apk` memiliki timestamp baru yang valid.

## 3. Pemisahan Build Lokal & Broadcast Rilis Publik (MANDATORY)
- Kompilasi APK (`flutter build apk --release`) bersifat lokal semata untuk keperluan pengujian, verifikasi, atau audit internal.
- DILARANG KERAS memicu pengunggahan APK ke CDN / Firebase Hosting maupun menyiarkan versi rilis baru ke Firestore (`app_config/version`) secara otomatis setiap kali APK selesai dikompilasi.
- Otomasi broadcast update (`publish_auto_update.py`) HANYA BOLEH dijalankan jika pengguna memberikan instruksi eksplisit secara langsung (misalnya: *"updatein dong"*, *"rilis update sekarang"*, atau sejenisnya).

## 4. Standar Preservasi Format Ideal WebView (MANDATORY)
- **DILARANG MERUSAK ATAU MENGUBAH LOGIKA SIKLUS HIDUP WEBVIEW** di `openturath_ai/lib/widgets/agent_multi_tab_room.dart` dan `desktop_webview_runtime.dart`.
- Logika kestabilan polling kesiapan sesi NotebookLM (Angular SPA) **WAJIB mempertahankan minimal 4 sampel berturut-turut (2 detik), elapsed waktu minimum 3000ms, dan jeda mikro 250ms**. Dilarang memotongnya menjadi 1-2 sampel demi alasan kecepatan semu karena memicu layout flicker/blank DOM.
- Tampilan galat (**error state**) **WAJIB menggantikan seluruh viewport WebView secara bersih** (`return ColoredBox(color: canvas, child: state)`). Dilarang keras menumpuk platform view `InAppWebView` di bawah overlay `Positioned.fill` saat galat terjadi.
- Dokumen rujukan teknis permanen: `openturath_ai/docs/STANDAR_IDEAL_WEBVIEW.md`.

