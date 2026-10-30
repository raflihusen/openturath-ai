# Audit mendalam login, sesi AI, dan distribusi OpenTurath AI

Tanggal pemeriksaan: **30 Oktober 2026**, Asia/Aden (UTC+3). Pemeriksaan utama sekitar 22.40–23.00.
Sumber awal: cabang `v9-2-integrasi`, commit `727097b8`, versi workspace **1.0.87+88**.

## Kesimpulan untuk pemilik

Keluhan login berulang dan AI tetap meminta masuk mempunyai dasar teknis nyata. Aplikasi menyimpan beberapa status berbeda dengan arti yang belum dipisahkan dengan baik: profil OpenTurath, autentikasi Firebase, sesi Google di WebView, identitas Google aktif, izin notebook, dan kesiapan kolom chat. Berhasil pada satu tahap belum menjamin tahap berikutnya berhasil.

**Dua cacat paling mendesak adalah keberhasilan login palsu dan klaim kepemilikan sesi lintas akun.** Metode login aktual tetap menulis status siap dan keluar dengan hasil sukses ketika pemeriksaan sesi mengembalikan `false` maupun melempar galat. Pergantian akun juga dapat menempelkan nama pemilik baru pada cookie akun lama tanpa memverifikasi identitas Google.

**Temuan baru pada dependency:** walaupun penulisan ulang cookie di kelas Dart sudah dihapus, konfigurasi `sharedCookiesEnabled: true` masih memerintahkan plugin macOS menyalin cookie dari penyimpanan native lain ke penyimpanan WKWebView setiap WebView dibuat. Uji native terisolasi membuktikan operasi itu bisa mengganti cookie baru dengan salinan lama. Belum ada bukti bahwa penyimpanan lain pada perangkat pengguna memang berisi salinan lama; temuan ini adalah mekanisme risiko yang terbukti, bukan kepastian penyebab kejadian tertentu.

Keluhan aplikasi tidak dapat dibuka juga mempunyai masalah distribusi tersendiri. Aplikasi Mac terpasang dan DMG lokal build 88 masih bertanda tangan ad-hoc, ditolak Gatekeeper, dan tidak mempunyai tiket notarisasi. ZIP Windows lokal masih membawa EXE build 86 tanpa prasyarat runtime; jalur bootstrap dalam source juga belum aman untuk PC bersih. Tantangan keamanan Google berbeda dari penolakan keamanan sistem operasi.

Audit ini menghasilkan diagnosis, reproduksi, dan rancangan perbaikan. **Belum ada perbaikan kode aplikasi, build, instalasi, deploy, atau rilis publik dari audit ini.** Tidak ada cookie/sesi pengguna yang diubah, akun yang dilogout, hak akses yang dicabut, atau pesan yang dikirim ke pelanggan.

## 1. Apa yang dibuktikan tangkapan layar

1. Layar langkah 2 masih berada pada Google “Verify it’s you / Confirm you’re not a robot”. Pada saat gambar diambil, Google belum menyatakan proses login web selesai.
2. Layar AI menampilkan Account Chooser dengan label “Signed out”. Itu bukan tampilan notebook yang telah terbuka.
3. Alamat akun pada kedua gambar berbeda. Karena itu kedua gambar tidak boleh dianggap bukti satu akun yang sama berhasil masuk lalu dicabut satu menit kemudian. Hubungan persisnya perlu jejak perjalanan akun/perangkat.
4. Challenge Google tersebut tidak membuktikan aplikasi diretas. Gambar juga tidak membuktikan bahwa cookie hilang dari disk atau bahwa DBSC mencabutnya.

Login OpenTurath memakai GoogleSignIn/AppAuth; login AI memakai WKWebView yang mempunyai konteks web sendiri. OAuth ke Firebase tidak menghasilkan cookie login Google untuk WKWebView. Hal ini menjelaskan mengapa saat ini ada dua langkah login, tetapi tidak membenarkan aplikasi mengklaim sukses sebelum langkah kedua benar-benar selesai. Rute implementasinya ada di [auth_service.dart:171](/Users/apple/Downloads/ramadhan/openturath_ai/lib/services/auth_service.dart:171) dan [google_session_auth_screen.dart:1007](/Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/google_session_auth_screen.dart:1007).

## 2. Bukti produksi yang dibaca ulang

Pembacaan hanya mengambil field diagnostik/kategori dan metadata rilis, tanpa menyalin identitas pelanggan, nilai cookie, atau token.

| Pemeriksaan | Hasil snapshot 30 Oktober |
|---|---|
| `auth_failure_stats` | Satu dokumen: macOS, `room-load`, `google-auth-page`, count 1 |
| Waktu terakhir kejadian itu | **22.42.27 Asia/Aden** (`19:42:27Z`) |
| Log Cloud Functions | Ada eksekusi `reportAuthFailure` sekitar waktu yang sama |
| `diagnostic_reports` | 0 dokumen saat dibaca |
| `client_error_logs`, sejak 23 Oktober UTC | Satu catatan kategori Android/checkout/error |
| Metadata rilis Android/root | 1.0.85, build 86, `updated_at=2026-10-29T10:50:51Z` |
| Metadata rilis Windows | 1.0.85, build 86, SHA256 `00826441e7829e9acae9778d99c97bb8a08d516cd4e23e0881988f0c5190478f` |
| Metadata rilis macOS | 1.0.85, build 86, SHA256 `f867b9d91195b518faae266fd6fdd8f000fdf0fe9b80b88fe98ef107ec7440a9` |

Kejadian 22.42 membuktikan ada ruang AI macOS yang kembali ke halaman autentikasi. Pelaporan ini anonim, sehingga **tidak bisa dihubungkan pasti dengan akun pada screenshot**. Count 1 bukan jumlah seluruh pelanggan terdampak: pelaporan dibatasi, bergantung koneksi, dan hanya mencakup jalur tertentu.

Label versi di laporan auth juga tidak dapat dipercaya sebagai versi binary: [auth_failure_reporter.dart:14](/Users/apple/Downloads/ramadhan/openturath_ai/lib/services/auth_failure_reporter.dart:14) masih mengunci `appVersion='1.0.85'`, walaupun workspace build 88. Laporan diagnostik memakai payload yang sama. Ini membuat investigasi lintas rilis menyesatkan.

Metadata rilis server bukan bukti byte aktual pada URL unduhan. Perbandingan dengan berkas yang dilayani URL perlu dicatat tersendiri. Aplikasi terpasang 1.0.87+88 juga tidak otomatis berarti seluruh pelanggan menerima versi tersebut.

Pemeriksaan URL publik selesai sekitar **22.56 Asia/Aden**:

| Pemeriksaan URL unduhan | macOS | Windows Setup |
|---|---|---|
| Respons binary | HTTP 200, disk image | HTTP 200, executable |
| `Last-Modified` | 29 Oktober, 10.43.10 UTC | 29 Oktober, 10.43.10 UTC |
| Checksum sidecar | `OpenTurath_AI_macOS.dmg.sha256` HTTP 404, berisi HTML | Tersedia; hash cocok dengan Firestore dan Setup lokal build 86 |
| Hash binary lengkap pada pemeriksaan ini | Belum terverifikasi | Belum terverifikasi |

Percobaan transfer paralel dibatasi 45 detik: DMG baru menerima 5.607.133 byte; Setup 6.367.488 dari 32.250.824 byte, lalu keduanya timeout. Hash parsial tidak dipakai. Tidak ada binary yang disimpan atau dijalankan. Ini membatasi bukti audit; bukan bukti semua pelanggan mengalami kecepatan unduh yang sama. Metadata live 29 Oktober tidak boleh disamakan dengan DMG lokal 30 Oktober. Bukti hash/signing paket publik pada audit 29 Oktober adalah bukti historis bertanggal, bukan pengukuran hash penuh baru pada hari ini.

## 3. Temuan sesi dan pembukaan AI

### S01 — P1: proses menyatakan sukses walaupun pemeriksaan sesi gagal

**Bukti:** [google_session_auth_screen.dart:668](/Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/google_session_auth_screen.dart:668), metode `_onSessionAuthenticated()`:

- `_isSessionReady=true` dipasang lebih dahulu.
- `google_session_ready=true` dan email disimpan sebelum hasil pemeriksaan diketahui.
- Hasil boolean `lockAndPersistCookies()` dibuang; exception ditelan.
- Pemilik sesi tetap ditulis dan navigasi tetap mengembalikan hasil sukses.

**Reproduksi:** metode aktual diekstrak tanpa mengubah isinya, lalu dijalankan dalam harness Dart dengan penyimpanan, navigasi, dan pembaca cookie sintetis. Kedua skenario menghasilkan:

| Hasil pemeriksaan sesi sintetis | Ready memori | Ready disk | Owner ditulis | Navigasi sukses |
|---|---|---|---|---|
| `false` | true | true | true | true |
| Exception | true | true | true | true |

Ini membuktikan mekanisme aplikasi, bukan autentikasi langsung terhadap Google. Keberadaan cookie pun belum cukup menjadi bukti sesi diterima server.

**Perbaikan:** gunakan status transisi verifikasi, evaluasi hasilnya, dan tulis ready/owner hanya sesudah bukti akun dan sesi valid. Gagal membaca harus menghasilkan status belum terverifikasi dengan pemulihan yang dapat dicoba lagi.

### S02 — P1: pergantian akun dapat mengklaim sesi akun sebelumnya

**Bukti:** [auth_service.dart:415](/Users/apple/Downloads/ramadhan/openturath_ai/lib/services/auth_service.dart:415), [persistent_google_session.dart:66](/Users/apple/Downloads/ramadhan/openturath_ai/lib/services/persistent_google_session.dart:66), [login_screen.dart:77](/Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/login_screen.dart:77).

Urutannya: pemilik A dilepas, email B langsung disimpan sebagai owner, kemudian restore hanya memeriksa owner tersimpan cocok B dan ada cookie bernama SID/`__Secure-1PSID`. Cookie itu tidak membawa bukti bahwa akun aktifnya B. Layar login dapat melewati langkah koneksi Google berdasarkan hasil ini. Penetapan owner saat login pertama juga bisa terjadi sebelum sesi web diamati (`auth_service.dart:235`).

**Perbaikan:** metadata owner adalah hasil verifikasi, bukan input untuk membuktikan verifikasi. Saat akun berubah, lepaskan klaim siap dan minta pemilihan/verifikasi akun yang sesuai sambil mempertahankan cookie. Jangan melakukan pembersihan global sebagai jalan pintas.

### S03 — P1, bersyarat: plugin masih dapat menulis ulang cookie saat WebView dibuat

**Bukti konfigurasi:** [google_session_auth_screen.dart:1031](/Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/google_session_auth_screen.dart:1031), [agent_multi_tab_room.dart:1769](/Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/agent_multi_tab_room.dart:1769), dan [payment_checkout_sheet.dart:652](/Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/payment_checkout_sheet.dart:652) mengaktifkan `sharedCookiesEnabled`.

**Bukti implementasi dependency yang terpasang:** [InAppWebView.swift:278](/Users/apple/.pub-cache/hosted/pub.dev/flutter_inappwebview_macos-1.1.2/macos/Classes/InAppWebView/InAppWebView.swift:278) menyalin seluruh `HTTPCookieStorage.shared.cookies` ke `configuration.websiteDataStore.httpCookieStore.setCookie(... completionHandler:nil)`. Penulisan tidak ditunggu sebelum pemuatan awal. Plugin sudah memakai process pool bersama dan default persistent WK data store pada baris 246 dan 259–262; opsi shared ini merupakan impor dari jar lain, bukan syarat agar dua WKWebView memakai store yang sama.

**Reproduksi native aman:** cookie bernama `AUDIT_SESSION`, domain `auth.audit.invalid`, dan `WKWebsiteDataStore.nonPersistent()`. Cookie baru mula-mula tersedia; menjalankan operasi penyalinan plugin dengan jar sintetis lama menggantinya dengan nilai lama. Uji tidak membaca atau menulis cookie Google, persistent store, maupun shared jar nyata pengguna.

**Batas bukti:** belum diketahui apakah shared jar nyata berisi cookie Google lama. Tidak boleh menyimpulkan DBSC atau revokasi Google pasti terpicu. Tidak ditemukan observer/sinkronisasi balik WK→native shared jar dalam source plugin yang diperiksa.

**Perbaikan:** pada macOS evaluasi menonaktifkan impor jar native pada seluruh WebView yang berbagi WK store, termasuk checkout. Pertahankan default persistent store dan process pool. Terapkan secara spesifik per platform setelah uji login, restart, lima tab, checkout, dan update; jangan mengubah expiry, SameSite, atau nilai cookie.

### S04 — P1: konfirmasi pengguna dapat menggantikan bukti sesi yang tidak tersedia

**Bukti:** [google_session_auth_screen.dart:339](/Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/google_session_auth_screen.dart:339) dan [google_session_auth_screen.dart:600](/Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/google_session_auth_screen.dart:600).

Pembaca cookie mengembalikan `null` jika platform gagal membaca. Kedua fallback hanya menolak `false`, sehingga `null` tetap menuju konfirmasi “sudah masuk” lalu S01. Tombol lanjut manual juga memakai blacklist substring URL, bukan syarat positif bahwa halaman Notebook tepercaya dan terautentikasi sudah terbuka.

**Perbaikan:** bedakan `unknown`, `absent`, dan `verified`; izinkan hanya asal halaman yang memang dimaksud. Konfirmasi pengguna membantu memilih akun, tetapi tidak boleh menjadi bukti autentikasi. Jangan menjebak pengguna dalam loader bila identitas tidak terbaca: sediakan coba lagi atau akses browser resmi dengan penjelasan sesi yang berbeda.

### S05 — P1: kesiapan kolom chat disamakan dengan kecocokan identitas

**Bukti:** [notebook_ui_script.dart:1324](/Users/apple/Downloads/ramadhan/openturath_ai/lib/core/notebook_ui_script.dart:1324) hanya memeriksa input chat aktif dan penolakan akses. [agent_multi_tab_room.dart:1422](/Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/agent_multi_tab_room.dart:1422) kemudian menyimpan email Firebase sebagai pemilik tanpa membaca identitas Google aktif.

**Reproduksi:** predicate JavaScript aktual dengan fixture composer aktif dan akun Google sintetis berbeda menghasilkan `ready=true`, `accessDenied=false`. Ini tidak membuktikan pengguna memperoleh akses tanpa izin; izin Google tetap berlaku. Cacatnya adalah klaim identitas/kesiapan aplikasi yang salah.

Detektor email onboarding juga terlalu luas: generic `div[aria-label*="@"]` dan email pertama dalam global data dapat mendahului identitas akun yang benar ([google_session_auth_screen.dart:178](/Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/google_session_auth_screen.dart:178)). Fixture dengan email orang lain pada div membuktikan email itu dapat terambil lebih dahulu.

**Perbaikan:** pisahkan verifikasi identitas dari readiness tata letak. Pakai sumber identitas khusus akun yang telah dibuktikan pada halaman aktual; bila tidak tersedia, status tetap belum terverifikasi. Jangan menganggap email pertama pada DOM atau WIZ sebagai kontrak identitas resmi. Pertahankan minimum 4 sampel, 3000 ms, dan jeda 250 ms.

### S06 — P1: batas waktu 45 detik tidak mengatasi panggilan platform yang menggantung

**Bukti:** [agent_multi_tab_room.dart:1337](/Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/agent_multi_tab_room.dart:1337) memasang mutex, lalu menunggu `getUrl()` tanpa deadline. Pemeriksaan 45 detik baru terjadi sesudah pemanggilan itu kembali. Sejumlah `evaluateJavascript()` berikutnya juga tidak dibatasi. `finally` memang ada, tetapi tidak dieksekusi selama Future belum selesai; semua tick berikut ditolak mutex.

Tombol lanjut dan pembaca cookie onboarding juga masih mempunyai await tanpa deadline (`google_session_auth_screen.dart:603`, `504`).

**Perbaikan:** deadline per panggilan platform, hasil pemeriksaan yang tidak boleh dipakai lagi setelah pergantian tab/akun, dan jalur pemulihan terlihat. Pertahankan siklus hidup dan persyaratan stabilisasi WebView yang diwajibkan workspace. Tidak perlu mempercepatnya dengan mengurangi sampel.

### S07 — P1: profil cache masih diterima sebagai keadaan masuk tanpa sesi Firebase

**Bukti:** [auth_service.dart:138](/Users/apple/Downloads/ramadhan/openturath_ai/lib/services/auth_service.dart:138) dapat mengembalikan profil disk tanpa Firebase. [splash_screen.dart:81](/Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/splash_screen.dart:81) menerima `restoredUser != null` untuk masuk dashboard meskipun Firebase tetap kosong. Dashboard menerima cache; `isCachedProfileOnly` sudah tersedia tetapi tidak digunakan oleh kode lain dalam `lib`.

Penambahan wait pada commit `dc8069e3` mengurangi race pemulihan awal, tetapi tidak menutup kondisi tersebut. Pengguna dapat melihat nama/paketnya, lalu operasi online meminta login kembali.

**Perbaikan:** cache boleh mempertahankan tampilan profil/paket saat offline, tetapi operasi online perlu autentikasi yang benar dan pemulihan yang jelas. Jangan menghapus paket berbayar, mengubahnya menjadi trial, atau mencabut hak akibat masalah sesi.

### S08 — P2: membatalkan langkah koneksi melakukan logout global

**Bukti:** [google_session_auth_screen.dart:706](/Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/google_session_auth_screen.dart:706) menampilkan dialog “Batalkan proses masuk”, lalu tombol keluar memanggil `AuthService.signOut()` pada baris 758. Itu menutup semua tab dan memanggil pembersihan cookie global. Jalur ini dipakai Back/Exit dan dialog mismatch, bukan hanya Log Out Pengaturan.

Ini bukan penghapusan otomatis saat startup, tetapi dampaknya jauh lebih besar dari pembatalan satu langkah dan tidak dijelaskan pada dialog.

**Perbaikan:** pembatalan koneksi kembali ke aplikasi dengan status AI belum terhubung; global logout tetap tindakan sadar pada Pengaturan sesuai aturan pemilik.

### S09 — P2: penanganan popup tidak mengikuti kontrak plugin

**Bukti:** [google_session_auth_screen.dart:1044](/Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/google_session_auth_screen.dart:1044) dan [agent_multi_tab_room.dart:1784](/Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/agent_multi_tab_room.dart:1784) memuat URL popup pada induk lalu `return true`, tetapi tidak membuat WebView dengan `windowId`. Kontrak platform plugin mensyaratkan `true` berarti window baru dibuat. Native macOS menyimpan transport popup yang tidak melalui cleanup default pada jalur ini.

**Perbaikan:** tangani lifecycle window sesuai kontrak atau tolak popup secara benar setelah pemindahan navigasi yang memang aman. Perlu uji popup yang relevan dengan Google. Belum terbukti challenge pada screenshot memakai popup, sehingga ini bukan penjelasan pasti screenshot.

## 4. Mengapa Google meminta verifikasi keamanan

Google dapat menolak login dari browser yang ditanam dalam aplikasi. Ini diterangkan langsung pada [panduan browser yang didukung Google](https://support.google.com/accounts/answer/7675428?hl=en). Google juga melarang permintaan **OAuth** diarahkan ke embedded user-agent yang dikuasai developer pada [kebijakan OAuth](https://developers.google.com/identity/protocols/oauth2/policies).

Kedua hal perlu dibedakan: langkah pertama aplikasi menggunakan SDK/browser autentikasi, sedangkan `InteractiveLogin` langkah kedua merupakan login situs di WKWebView; ia tidak otomatis menjadi pelanggaran OAuth hanya karena tertanam. Meski demikian, ketergantungan pada login situs Google di WebView membuat produk terpapar challenge/kebijakan browser yang tidak dapat dijamin aplikasi.

Kesimpulan yang didukung bukti: **ada kelemahan aplikasi yang perlu diperbaiki dan ada ketergantungan autentikasi Google di luar kendali aplikasi**. Belum tersedia bukti sinyal risiko Google spesifik yang memicu CAPTCHA pada akun di screenshot. Tidak tepat menjanjikan bahwa patch cookie akan menghilangkan semua challenge atau bahwa mengganti user-agent menyelesaikannya.

Pemulihan operasional yang layak adalah membuka notebook yang memang sudah diberikan kepada akun pengguna melalui browser yang didukung, bila jalur produk tersebut disiapkan dengan verifikasi akses. Login di Chrome/Safari tidak otomatis menyalakan sesi WKWebView. Jangan menyalin cookie browser, menurunkan keamanan akun, atau mematikan proteksi sistem sebagai solusi pelanggan.

## 5. Distribusi dan pembukaan aplikasi

### D01 — P1: build Mac lokal/terpasang masih ditolak Gatekeeper

`/Applications/OpenTurath AI.app` dan aplikasi di DMG lokal yang termount sama-sama **1.0.87+88**, bundle ID `com.example.openturathAi`, universal arm64/x86_64.

| Pemeriksaan | Hasil |
|---|---|
| `codesign --verify --deep --strict` | Valid on disk |
| Identitas penandatangan | `Signature=adhoc`, `TeamIdentifier=not set` |
| `spctl --assess --type execute` | Rejected |
| `stapler validate` | Tidak ada tiket |
| Entitlement aktual | Termasuk `get-task-allow=true`; hardened-runtime flag tidak terlihat |
| SHA256 DMG lokal/root/public | `abb590259a80ebe939b3d8ca173b1b91c69d03aff148f581e5124b440a519cdb` |

Integritas ad-hoc bukan penerimaan distribusi. [package_macos.sh:24](/Users/apple/Downloads/ramadhan/openturath_ai/tool/package_macos.sh:24) kini mempunyai pemeriksaan publik, tetapi hanya aktif dengan `OPENTURATH_PUBLIC_DIST=1`. Default masih bisa menghasilkan DMG lokal ad-hoc.

**Perbaikan:** Developer ID stabil, hardened runtime dan entitlement yang sesuai, notarisasi/stapling, serta gerbang wajib pada artefak persis yang hendak dipublikasikan. Uji unduhan browser pada Mac dengan keamanan bawaan, termasuk migrasi Keychain/sesi dari instalasi lama. Ikuti [panduan notarisasi Apple](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution).

### D02 — P1: Windows masih memiliki gap prasyarat dan bootstrap

ZIP lokal: 65 entri, EXE **1.0.85+86**, tanpa folder prerequisites, pemasang Microsoft, README, atau DLL runtime yang diimpor (`MSVCP140.dll`, `VCRUNTIME140.dll`, `VCRUNTIME140_1.dll`). Hash ZIP `58a7aaaf1f16b56433bbd23f0e6c757059ce310e44d4f798037fa03f99a990bd`.

EXE utama dan Setup lokal tidak mempunyai embedded Authenticode certificate table. Ini menjelaskan risiko kepercayaan distribusi, tetapi belum membuktikan pesan SmartScreen tertentu dialami setiap pelanggan.

Source core installer sudah ditambah VC++ redist, tetapi [installer_stub.iss:82](/Users/apple/Downloads/ramadhan/openturath_ai/windows/installer_stub.iss:82) membuka UI installer Flutter lebih dahulu. UI itu baru menjalankan core yang memasang VC++. Pada PC bersih ada potensi UI gagal sebelum prasyarat dipasang. Ini mekanisme source; belum ada uji perangkat Windows bersih. Source core juga belum memasang WebView2 dan tidak memeriksa exit code redist secara memadai.

**Perbaikan:** bootstrap native yang dapat berjalan mandiri memasang/memastikan VC++ dan WebView2 sebelum executable Flutter pertama. Periksa kegagalan unduh, versi runtime, exit code dan restart requirement. Kebutuhan WebView2 dijelaskan oleh [Microsoft](https://learn.microsoft.com/en-us/microsoft-edge/webview2/concepts/distribution).

### D03 — P1: paket sekarang tidak memenuhi syarat updater baru

[macos_update.sh:38](/Users/apple/Downloads/ramadhan/openturath_ai/assets/updater/macos_update.sh:38) mensyaratkan signing team dan penerimaan Gatekeeper. Helper Windows mensyaratkan Authenticode valid. Paket lokal di atas tidak memenuhi syarat tersebut. Bypass pengujian secara benar dilarang pada build release.

**Perbaikan:** benahi tanda tangan/paket, pertahankan pemeriksaan updater. Jangan menyiarkan paket baru sebelum pengujian update dari versi pelanggan membuktikan pengunduhan, verifikasi, pemasangan, dan startup berhasil.

### D04 — P2: versi global tidak mewakili semua platform; startup masih terlambat terlihat

`RELEASE_MANIFEST.json` global menyebut 1.0.87+88, tetapi hash Windows masih menunjuk paket lokal berisi EXE 1.0.85+86. Metadata server juga masih build 86. Catat versi, hash, signing, dan smoke test **per platform**.

Startup source kini mempunyai timeout, tetapi persiapan WebView, konfigurasi, preferensi, dan Firebase masih dilakukan berurutan sebelum `runApp()`. Batas terburuk pada await yang diperiksa dapat mencapai sekitar **75 detik**. Itu adalah batas source, bukan pengukuran startup pelanggan. Retry Firebase belum dibatasi waktu.

**Perbaikan:** tampilkan shell startup segera, beri tahap/pemulihan yang jelas, dan batasi retry. Ini dapat menjelaskan sebagian keluhan tidak terbuka, tetapi tidak menyebabkan challenge Google.

## 6. Perbandingan dengan audit 29 Oktober

| Temuan lama | Status kode aktual |
|---|---|
| Vault Dart memperpanjang/replay cookie Google | Sudah dihapus pada `a688045e`; jangan dilaporkan masih aktif |
| Mismatch akun langsung menghapus seluruh cookie | Sudah diganti AccountChooser; jalur cancel masih logout global |
| Pemulihan Firebase langsung menilai null | Ada wait tambahan; cache masih bisa masuk dashboard tanpa Firebase |
| Await onboarding tertentu tidak dibatasi | Sebagian sudah timeout; manual/cookie check/room masih memiliki gap |
| Startup tanpa deadline | Sudah dibatasi; frame pertama masih menunggu rangkaian startup |
| Source packaging tidak memeriksa keamanan publik | Guard ditambah; opt-in dan artefak lokal belum memenuhi syarat |
| Tidak ada rekaman gagal login baru | Sekarang satu kejadian `google-auth-page` tercatat; cakupan belum lengkap |

Perbaikan source, keberhasilan tes, keberhasilan build, pemasangan lokal, dan perbaikan yang diterima pelanggan merupakan tahap berbeda. Status satu tahap tidak boleh dipakai untuk mengklaim tahap berikutnya selesai.

## 7. Urutan perbaikan yang disarankan

| Urutan | Perubahan konkret | Bukti lulus yang wajib ada |
|---|---|---|
| 1 | Tutup sukses palsu S01/S04, klaim owner S02/S05, dan cancel global S08 | Pembacaan gagal/akun beda tidak pernah menghasilkan sukses; cancel mempertahankan sesi |
| 2 | Hentikan impor cookie native macOS pada semua permukaan yang berbagi store | Cookie baru tidak berubah saat login, checkout, buka 5 tab, tutup/buka aplikasi |
| 3 | Deadline platform S06 dan pemisahan cache S07 | Gangguan native/jaringan menghasilkan pemulihan terbatas waktu tanpa menghilangkan paket |
| 4 | Tangani challenge sebagai status yang nyata; siapkan browser resmi sebagai pemulihan | Pengguna tahu verifikasi masih diperlukan; tidak ada klaim sesi WebView dari login browser luar |
| 5 | Signing/notarisasi Mac, Authenticode dan bootstrap runtime Windows | Instalasi dan update berhasil pada perangkat bersih dengan keamanan bawaan |
| 6 | Telemetri versi/build aktual dan tahap perjalanan | Laporan gagal dapat dibedakan menurut binary dan tahap, tanpa data sesi sensitif |
| 7 | Pilot kecil pada rilis kandidat, lalu distribusi hanya sesudah validasi | Bukti pembukaan AI nyata sesudah restart/update dan lintas akun/perangkat |

Perubahan sesi wajib mempertahankan 5 tab, tidak menghapus cookie di luar Log Out eksplisit Pengaturan, tidak menyentuh VIP/entitlement, dan menjaga stabilisasi 4 sampel/3000 ms/250 ms, penggantian viewport galat, serta desain monokrom. Tidak perlu membongkar tata letak atau mengurangi polling.

## 8. Matriks verifikasi sebelum klaim selesai

| Skenario | Hasil yang harus diamati |
|---|---|
| Login pertama dengan satu akun | Firebase dan Google web sama; notebook yang dituju benar-benar dapat dipakai |
| Challenge/CAPTCHA/2FA belum selesai | Tetap memerlukan verifikasi; tidak meloloskan tombol lanjut sebagai sukses |
| Cookie read exception/timeout, DOM belum siap | Status belum terverifikasi, dapat dicoba lagi, tidak macet selamanya |
| Cookie ada tetapi Google menyatakan signed out | Tidak menganggap cookie sebagai bukti sesi hidup |
| Akun A di web, B di aplikasi | Tidak menulis owner B atau melewati koneksi sebelum identitas benar |
| Dua akun Google aktif | Notebook dan identitas akun dipilih benar, tidak mengambil email DOM sembarang |
| Cancel langkah 2 atau mismatch | Cookie dan tab yang sudah sah tetap ada |
| Lima tab, pindah tab, checkout | Sesi baru tidak ditimpa jar lain; tidak ada penutupan tab senyap |
| Restart app dan restart OS | Persistensi bawaan benar-benar diuji, bukan hanya flag siap tersimpan |
| Update dari versi yang dipakai pelanggan | Signing/Keychain/store tetap konsisten; AI dapat dibuka setelah update |
| Profil cache, Firebase kosong | Profil/paket tetap terlihat dengan status jujur; operasi online memulihkan auth |
| Internet lambat/putus dan platform call macet | Frame aplikasi muncul, deadline bekerja, retry memulihkan tanpa reset global |
| Mac bersih via unduhan browser | Gatekeeper menerima aplikasi tanpa mematikan proteksi |
| Windows tanpa VC++/WebView2 | Bootstrap memasang prasyarat sebelum Flutter UI dan menjelaskan kegagalan |
| Updater kandidat gagal signing/hash | Ditolak tanpa merusak aplikasi lama |

## 9. Pengujian yang benar-benar dilakukan dalam audit ini

- **21 tes Flutter terarah lulus** melalui Dart MCP: GoogleSessionAuthFlow, auth stream, desktop OAuth gateway, login-target controller, NotebookNavigation, auth failure payload, diagnostic service, dan WebView release hardening.
- Reproduksi Dart metode `_onSessionAuthenticated()` aktual: dua kasus gagal tetap menghasilkan sukses seperti S01.
- Reproduksi native WK cookie dengan domain/store sintetis: operasi impor cookie lama mengganti cookie baru seperti S03.
- Fixture JavaScript memakai predicate sumber aktual: composer aktif akun lain tetap ready; generic email DOM dapat mendahului identitas akun.
- Inspeksi binary lokal/terpasang, signing, notarisasi, versi, prasyarat, manifest, source updater, dan pembacaan metadata/log produksi.

Tes UI onboarding yang tersedia memakai placeholder WebView. **Kelulusan 21 tes tidak membuktikan login Google, challenge, persistensi restart, Windows runtime, atau perjalanan pelanggan telah lulus.** Audit ini tidak menjalankan login akun pengguna, mengulang challenge, mengganti cookie, atau meminta Google mencabut/memperbarui sesi. Pemeriksaan pembayaran/provisioning/worker menyeluruh pada audit sebelumnya tidak diulang dalam cakupan ini.

Laporan ini adalah dasar perbaikan yang dapat ditinjau. Klaim “sudah beres” baru layak setelah perubahan diterapkan, checkpoint dibuat, dan matriks perangkat/sesi yang relevan dijalankan.
