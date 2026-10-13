# Status implementasi desktop OpenTurath AI

Tanggal: 23 September 2026. Target: Windows x64, macOS Apple Silicon dan Intel.

## Kesimpulan

Perbaikan aplikasi, konfigurasi native, pengujian, dan pengemasan sudah dibuat serta dicatat dalam checkpoint Git. Analyzer setelah koreksi Esc beranda: **tanpa masalah** (5,1 detik). Seluruh suite: **186 tes lulus**; setelah koreksi terakhir, 11 tes beranda/interaksi terkait juga lulus. Ini belum merupakan sertifikasi bahwa seluruh fungsi berjalan pada binary desktop: build macOS terhenti sebelum kompilasi karena `xcodebuild` tidak tersedia, dan host Windows tidak tersedia dalam sesi ini.

Laporan ini melengkapi audit awal `AUDIT_FORENSIK_DESKTOP_OPENTURATH_2026-09-23.md`. Patch di repositori adalah implementasi aktual; contoh patch dalam audit awal bukan konfigurasi akhir.

## Perubahan yang diterapkan

| Area | Implementasi aktual | Lokasi utama |
|---|---|---|
| Cloud Functions Windows | Transport HTTPS callable dengan Firebase ID token, envelope data/result/error, timeout, tanpa retry otomatis pada transaksi | `openturath_ai/lib/services/callable_gateway.dart` |
| Firebase desktop | Konfigurasi Windows dan macOS disesuaikan dengan aplikasi yang terdaftar pada project `open-turath` | `openturath_ai/lib/firebase_options.dart` |
| Login Windows | Browser eksternal, listener loopback sementara, state acak sekali pakai, token melalui POST, timeout dan pembatalan | `openturath_ai/lib/services/desktop_google_sign_in.dart`, `public/desktop-auth.html`, `public/desktop-auth.js` |
| Login macOS | Google Sign-In native dengan client ID dan URL scheme Apple yang terdaftar | `lib/services/auth_service.dart`, `macos/Runner/Info.plist` |
| WebView2 | Pemeriksaan runtime, profil writable di Application Support, petunjuk pemasangan dan retry | `lib/services/desktop_webview_runtime.dart`, `lib/widgets/desktop_webview_gate.dart` |
| NotebookLM | User agent engine asli di desktop, tombol browser eksternal, pengamanan error injeksi JS dan lifecycle Android-only | `lib/widgets/agent_multi_tab_room.dart` |
| Sesi | Pelepasan keep-alive setelah tab keluar dari widget tree; pembersihan sesi saat logout dan hapus akun | `lib/services/agent_session_manager.dart`, `lib/services/auth_service.dart` |
| Pembayaran | Callable Windows dan fallback browser ketika runtime WebView tidak tersedia; tetap memakai status pembayaran dari server | `lib/services/doku_service.dart`, `lib/widgets/doku_checkout_sheet.dart` |
| Perangkat | Identitas Windows dan fallback acak persisten menggantikan identitas darurat yang sama untuk semua perangkat | `lib/services/device_service.dart` |
| Update | Metadata versi terpisah android/macos/windows; desktop menolak APK; HTTPS dan host/ekstensi diperiksa; kegagalan membuka installer ditampilkan | `lib/core/platform_release.dart`, `lib/services/update_service.dart` |
| Dialog | Sheet desktop terpusat maksimal 560 px; layout panjang dibatasi dan dapat digulir; mobile tetap sheet | `lib/widgets/adaptive_sheet.dart`, `lib/core/theme.dart` |
| Workbench | Navigasi rail yang sudah ada dipertahankan; panel kitab 300 px saat desktop >=1100 px, pencarian Arab, detail kitab | `lib/widgets/desktop_reference_panel.dart`, `lib/widgets/agent_multi_tab_room.dart` |
| Keyboard | Cmd/Ctrl F, W, T, koma, R; Escape; halaman tersembunyi dikeluarkan dari fokus keyboard | `lib/widgets/desktop_shortcuts.dart`, `lib/screens/main_shell_screen.dart` |
| Mouse | Kursor klik, hover, indikator fokus dan aktivasi keyboard pada kartu interaktif | `lib/widgets/apple_interactive_wrapper.dart` |
| Jendela | Default 1280×820, batas minimum 860×600 disesuaikan area layar; skala DPI Windows; judul OpenTurath AI | `macos/Runner/MainFlutterWindow.swift`, `windows/runner/` |
| macOS native | Podfile 10.15 dan include konfigurasi Pods; nama produk, skema, test host diselaraskan; izin network.server dilepas pada release | `macos/Podfile`, `macos/Flutter/`, `macos/Runner.xcodeproj/` |
| Packaging | Flutter 3.38.4 dipatok; analyzer dan tes menjadi prasyarat CI; paket Windows menyertakan pemasang Microsoft bertanda tangan; paket macOS memeriksa semua Mach-O arm64+x86_64 | `.github/workflows/release_all_platforms.yml`, `openturath_ai/tool/package_windows.ps1`, `openturath_ai/tool/package_macos.sh` |

## Koreksi terhadap asumsi audit awal

- Firebase Auth/Core/Firestore memiliki implementasi Windows C++ dalam versi dependensi yang terkunci. `cloud_functions` tidak memiliki implementasi Windows pada versi ini; adapter HTTPS menangani gap tersebut. Status dukungan produksi vendor tidak berubah hanya karena patch aplikasi.
- `SignInWithProvider` pada Firebase C++ desktop bukan jalur Google login yang dapat diandalkan. Jalur Windows kini memakai credential dari browser.
- Bundle ID Apple tetap `com.example.openturathAi` karena itulah identitas yang terdaftar dan cocok dengan kredensial Firebase/Google yang tersedia. Mengubah teks menjadi `com.openturath.ai` tanpa registrasi Firebase dan OAuth baru akan merusak login. Migrasi identitas resmi membutuhkan registrasi dan konfigurasi server bersama.
- Tidak ada database SQLite langsung milik aplikasi yang harus dimigrasikan ke FFI. Cache gambar memilih repositori JSON pada Windows melalui dependensinya. Catatan memakai penyimpanan lokal dan sinkronisasi Firestore yang sudah diuji.
- Rail lebar >=768 px dan ikon merek macOS sudah ada. Ikon Windows memuat resolusi 16/32/48/256. Tidak dibuat ulang tanpa kebutuhan.
- Tidak ada asumsi bahwa login browser membagikan cookie ke WebView. Sesi browser dan WebView terpisah; tombol browser membuka notebook yang diberikan server.

## Bukti verifikasi

- `flutter analyze --no-pub`: No issues found, 5.4 detik pada pemeriksaan penuh.
- `flutter test --no-pub --reporter expanded`: 186 passed, sekitar 24 detik.
- Tes baru: autentikasi callable, envelope dan error, larangan retry pembayaran, validasi callback/state login, isolasi update per platform, penolakan URL tidak tepercaya, pintasan Ctrl/Cmd, Escape, aktivasi kartu, dialog 860×600 dan 1920×1080.
- `plutil -lint`: Info.plist, kedua entitlements, project.pbxproj lolos.
- `ruby -c macos/Podfile`: Syntax OK.
- `bash -n tool/package_macos.sh`: lolos.
- Workflow YAML dapat diparse; job validate/windows/macos/android tersedia.
- `node --check`: halaman login JS dan tiga skrip NotebookLM lolos sintaks. Ini tidak membuktikan kompatibilitas DOM NotebookLM live.
- `git diff --check`: bersih.
- Percobaan build macOS: gagal dengan exit 72, `xcrun: error: unable to find utility "xcodebuild"`. Tidak menghasilkan DMG baru.
- Skrip PowerShell, kompilasi C++, link CocoaPods/Swift, runtime WebView2/WKWebView, dan login/pembayaran live belum diuji pada perangkat target.

## Aktivasi yang masih diperlukan

1. **Hosting login Windows — sudah aktif.** Pengguna menyetujui publikasi. Halaman `https://open-turath.web.app/desktop-auth.html` dan JS diterbitkan pada 23 September 2026, 04:12:35 UTC. Keduanya merespons HTTP 200, sesuai berkas lokal, dengan Cache-Control no-store dan X-Frame-Options DENY. Google provider aktif dan domain hosting masuk authorizedDomains. Login lengkap dengan akun pada aplikasi Windows tetap perlu diuji.
2. **Xcode lengkap.** Pasang Xcode, pilih developer directory dan selesaikan first launch; saat ini yang aktif hanya Command Line Tools.
3. **Build Windows.** Jalankan workflow pada runner Windows atau mesin dengan Visual Studio desktop C++, Windows SDK, Flutter 3.38.4 dan NuGet.
4. **Pengujian perangkat nyata.** Login baru/batal/timeout/restart/logout/ganti akun, buka tiga tab dan tutup, offline lalu online, salin/simpan catatan, tebus kode, checkout batal/pending/berhasil, buka tautan pembaruan sesuai OS, skala Windows 100/125/150/200%, keyboard ketika fokus di native WebView, macOS Intel dan Apple Silicon.
5. **Distribusi publik.** Siapkan Developer ID signing/notarization macOS dan Authenticode Windows. Paket CI saat ini adalah artefak pengujian. Jangan menyebut ZIP sebagai installer MSI/MSIX. Metadata update desktop hanya diisi setelah artefak yang sesuai tersedia.

## Perintah build lokal

Dengan Flutter 3.38.4 dan toolchain target yang lengkap:

```sh
cd openturath_ai
flutter pub get --enforce-lockfile
flutter analyze --no-pub
flutter test --no-pub
```

macOS:

```sh
flutter build macos --release
bash tool/package_macos.sh
```

Windows PowerShell:

```powershell
flutter build windows --release
pwsh -File tool/package_windows.ps1
```

Skrip pengemasan Windows memerlukan internet untuk mengunduh prasyarat bertanda tangan Microsoft. Lihat [distribusi WebView2](https://learn.microsoft.com/microsoft-edge/webview2/concepts/distribution) dan [build Windows Flutter](https://docs.flutter.dev/platform-integration/windows/building).

## Kontrak update desktop

Dokumen Firestore `app_config/version` dapat mempertahankan field Android yang lama dan menambahkan `platforms.windows` serta `platforms.macos`, masing-masing berisi `build`, `version`, `url`, `notes`, dan opsional `sha256`. Build masing-masing dibandingkan dengan nomor build aplikasi yang terpasang. URL harus HTTPS pada host OpenTurath yang diizinkan dan ekstensi yang sesuai OS.

## Bukti publikasi halaman login

- Versi aktif baru: `sites/open-turath/versions/be002e08b8bb99d0`.
- Versi sebelumnya untuk pemulihan: `sites/open-turath/versions/44e174319f5382fc`.
- Release: `sites/open-turath/channels/live/releases/1790136755580000`.
- Manifest sebelumnya 19 berkas, manifest baru 21 berkas. Pembandingan API sesudah publikasi membuktikan seluruh 19 hash lama tetap identik; konfigurasi yang sudah ada juga tetap sama.
- Hanya `/desktop-auth.html`, `/desktop-auth.js`, dan header khusus keduanya yang ditambahkan.
- Pemeriksaan Chrome: halaman login tampil dan tombol Batal kembali ke listener loopback. Hasil diagnostik: method POST, path /callback, Origin null, state cocok, cancel=1, tanpa token. Ini membuktikan penanganan opaque origin diperlukan; state acak tetap wajib.
- Tidak menjalankan sign-in akun atau transaksi pembayaran sungguhan saat pengujian browser ini.
- Publikasi terarah tersedia melalui `openturath_ai/tool/deploy_desktop_login.cjs`; tanpa argumen hanya meninjau rencana. `--publish` diperlukan secara eksplisit untuk membuat release hosting. Skrip mempertahankan manifest aktif dan berhenti bila release berubah selama persiapan.

Tidak ada penulisan metadata versi, upload APK, atau pemanggilan `publish_auto_update.py` dalam pekerjaan ini. Perubahan source dan artefak build internal tidak menyiarkan rilis publik.
