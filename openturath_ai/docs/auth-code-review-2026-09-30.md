# Pemeriksaan ulang kode login OpenTurath / NotebookLM

Tanggal: 30 September 2026. Source yang diperiksa: `5863d5f`, termasuk perubahan auth `2e0337a` dan patch macOS `5469523`. Branch: `codex/saas-design-research-2026-09-30`.

**Keputusan: belum dapat dinyatakan berhasil atau aman untuk dirilis.** Pemeriksaan menemukan bug yang dapat direproduksi dan risiko pada alur autentikasi. Rancangan satu profil browser dalam laporan sebelumnya belum diterapkan. NotebookLM tetap dipertahankan.

P1 berarti harus ditangani sebelum rilis alur ini. P2 berarti masalah perilaku atau keandalan yang perlu diperbaiki. Status temuan dibedakan antara reproduksi lokal, fakta source, dan risiko yang belum diuji dengan akun nyata.

## Temuan

### 1. P1 — Patch macOS merusak source SDK pada pemasangan dependensi bersih

Lokasi: `macos/patch_macos_keychain.rb:17–24,60–78`; dipanggil otomatis oleh `macos/Podfile:43–44`. Versi terkunci di `macos/Podfile.lock`: FirebaseAuth 11.15.0.

**Direproduksi.** Dua source asli FirebaseAuth 11.15.0 diambil dari repository resmi dan diuji pada direktori sementara, tanpa mengubah Pods aplikasi. Keduanya lolos parser Swift. Setelah skrip patch proyek diterapkan pada salinan tersebut, keduanya gagal parser:

| File | SDK asli | Setelah patch |
| --- | --- | --- |
| `AuthStoredUserManager.swift` | exit 0 | exit 1: `unexpected conditional compilation block terminator`, `expected '}'` |
| `AuthKeychainServices.swift` | exit 0 | exit 1: `expected #else or #endif at end of conditional compilation block` |

Pada manager, penggantian regex untuk menambahkan `#endif` juga mengenai blok `do` yang baru disisipkan. Pada keychain services, skrip menyisipkan `#if`/`#else` tanpa pasangan `#endif`. Skrip Ruby sendiri keluar dengan exit 0 dan mencetak sukses; itu tidak membuktikan Swift hasil patch valid. Pods yang sudah terpasang memiliki perubahan tambahan yang tidak dihasilkan lengkap oleh skrip ini, sehingga keberadaan build lama tidak membuktikan pemasangan ulang dapat diulang.

Dampak: instalasi Pods baru dapat menghasilkan source yang tidak dapat dikompilasi. Parser bukan build macOS lengkap, tetapi kegagalan sintaks tersebut sudah merupakan penghalang kompilasi.

Perbaikan: pulihkan SDK resmi dan konfigurasi Keychain yang benar. Jangan hanya membetulkan regex sambil mempertahankan penyimpanan token tidak aman pada temuan berikutnya. Source reproduksi: [AuthStoredUserManager 11.15.0](https://github.com/firebase/firebase-ios-sdk/blob/11.15.0/FirebaseAuth/Sources/Swift/SystemService/AuthStoredUserManager.swift), [AuthKeychainServices 11.15.0](https://github.com/firebase/firebase-ios-sdk/blob/11.15.0/FirebaseAuth/Sources/Swift/Storage/AuthKeychainServices.swift).

### 2. P1 — Penyimpanan sesi Firebase macOS dialihkan dari Keychain ke preferensi biasa

Lokasi: `macos/patch_macos_keychain.rb:29–30,65–78`; implementasi aktif juga terlihat pada source Pods terpasang.

**Fakta source.** Patch menyimpan arsip `User` melalui `AuthUserDefaults`. `User.encode` menyertakan `tokenService`; `AuthUserDefaults.setData` memakai persistent domain `UserDefaults`, tanpa enkripsi aplikasi atau perlindungan Keychain. Ini mengurangi perlindungan kredensial agar dialog Keychain hilang. Tidak ada bukti pencurian token; isi kredensial pengguna tidak dibaca dalam audit.

Perbaikan: SDK resmi, penandatanganan dan entitlement yang sesuai, serta Keychain Sharing. Rencanakan migrasi atau invalidasi salinan lama secara terbatas; jangan menghapus semua preferensi pengguna. [Firebase meminta Keychain Sharing untuk aplikasi Mac](https://firebase.google.com/docs/auth/ios/start). [Apple mengarahkan informasi sensitif ke Keychain](https://developer.apple.com/documentation/foundation/userdefaults).

### 3. P1 — Jalur desktop aktif kembali menjalankan OAuth Google di WebView

Lokasi: `lib/screens/login_screen.dart:80–90`; `lib/widgets/desktop_in_app_auth_dialog.dart`, termasuk `authUrl` dengan `mode=inapp` dan user-agent Safari.

**Fakta source; keberhasilan login nyata belum dibuktikan.** Tombol masuk desktop sekarang memilih `DesktopInAppAuthDialog`, lalu meneruskan token ke Firebase. Metode browser sistem pada `AuthService.signInWithGoogle` tetap ada, tetapi bukan jalur utama tombol desktop saat ini. Mengubah user-agent tidak mengubah WKWebView menjadi browser sistem.

Google mendokumentasikan `disallowed_useragent` saat OAuth dibuka melalui WKWebView dan membatasi browser embedded yang dikendalikan aplikasi. Login sesekali yang tampak berhasil tidak menjadi jaminan dukungan alur ini. Lihat [panduan Google untuk native apps](https://developers.google.com/identity/protocols/oauth2/native-app) dan [kebijakan OAuth](https://developers.google.com/identity/protocols/oauth2/policies).

Firebase yang berhasil masuk membuktikan sesi Firebase. Hasil tersebut tidak membuktikan cookie Google, akun, atau izin NotebookLM pada konteks yang digunakan asisten. Fallback ke browser utama juga tidak memindahkan cookie browser utama ke WKWebView.

Perbaikan: gunakan konteks autentikasi yang didukung dan desain ulang batas sesi NotebookLM. Untuk desktop, rancangan satu profil browser tetap masuk akal, tetapi perlu implementasi serta pengujian menyeluruh; bukan fitur yang sudah selesai pada source ini.

### 4. P1 — Hasil login WebView tidak terikat ke origin dan percobaan login

Lokasi: `lib/widgets/desktop_in_app_auth_dialog.dart:243–263,266–274,284–313`; `public/desktop-auth.js:48–56`.

**Fakta source dan risiko keamanan; eksploitasi belum direproduksi.** Handler JavaScript menerima payload dengan token nonkosong tanpa memeriksa origin/frame. Handler navigasi menerima fragment `auth=` dari URL mana pun, tanpa membatasi scheme, host, path atau state percobaan login. Popup juga dimuat ulang pada controller yang sama tanpa batas origin di dialog tersebut. Halaman helper meletakkan payload token pada fragment URL.

Firebase masih memverifikasi credential pada langkah berikutnya. Temuan ini bukan klaim bahwa string token palsu dapat melewati Firebase. Risiko yang tersisa adalah penerimaan hasil dari sumber atau percobaan lain, termasuk token Google valid yang tidak terikat ke login yang sedang dimulai. Token pada fragment juga dapat tertinggal dalam riwayat atau terekspos kepada kode pada halaman; fragment tidak otomatis dikirim pada request HTTP.

Perbaikan: hapus protokol token pada URL dan bridge in-app untuk alur browser yang didukung; batasi callback, kaitkan hasil ke state acak sekali pakai, dan baru percaya identitas setelah verifikasi Firebase. Validator loopback yang sudah diuji tidak melindungi jalur dialog ini.

### 5. P2 — Pengisian Google otomatis dapat menekan tombol yang salah

Lokasi: `lib/screens/agent_webview_screen.dart:106–141`; implementasi serupa pada `lib/widgets/agent_multi_tab_room.dart`.

**Fakta source; belum diuji pada DOM Google nyata.** Selector tombol menggabungkan tombol Next dengan selector umum `button[type="button"]`. `querySelector` memilih elemen pertama yang cocok menurut urutan dokumen, bukan memprioritaskan selector pertama. Jika tombol lain muncul lebih awal, skrip dapat menekannya dan mengatur `_otAutoNextTriggered`, sehingga Next yang benar tidak dijalankan. Pengisian dan klik dijadwalkan berulang tanpa konfirmasi pengguna.

`_getActiveGoogleEmail` juga mengutamakan email Firebase di atas akun NotebookLM pilihan. Ketika kedua pilihan berbeda, skrip dapat mengisi kembali akun Firebase.

Perbaikan: hentikan injeksi serta klik pada halaman autentikasi Google dan gunakan alur resmi. Mempersempit selector saja tidak memperbaiki masalah dukungan WebView atau menyatukan sesi.

### 6. P2 — Preferensi akun dan status sesi disetel terlalu dini

Lokasi: `lib/services/desktop_google_sign_in.dart:87–109`; `lib/services/auth_service.dart:117–125,163–170`.

**Fakta source.** Callback browser menyimpan email dan `google_session_ready = true` sebelum credential diverifikasi Firebase. Callback valid dengan `cancel=1` dan email juga menulis preferensi tersebut sebelum mengembalikan `null`. Jalur Firebase lain mengatur flag yang sama hanya berdasarkan sukses Firebase, tanpa menguji NotebookLM.

Pencarian source saat ini tidak menemukan pembacaan boolean tersebut untuk mengesahkan akses notebook. Karena itu, audit tidak mengklaim bahwa flag ini sendiri melewati izin server. Namun, metadata ini menyatakan status yang belum terbukti dan perubahan akun dapat tetap tersimpan ketika login dibatalkan atau gagal.

Perbaikan: cancel tidak boleh mengubah akun; simpan identitas setelah hasil Firebase terverifikasi; pisahkan preferensi email dari hasil pemeriksaan akses notebook. Status siap NotebookLM harus berasal dari notebook yang berhasil dibuka dan merespons.

### 7. P2 — Fallback error Keychain dapat menerima identitas lama

Lokasi: `lib/services/auth_service.dart:93–98,149–154`.

**Risiko dari source; skenario akun nyata belum direproduksi.** Saat `keychain-error`, kode menganggap `currentUser` yang masih ada sebagai hasil login terbaru tanpa memastikan bahwa itu akun yang baru dipilih. Pada pergantian akun, keberadaan user lama belum membuktikan login baru berhasil.

Perbaikan: tangani error penyimpanan pada konfigurasi SDK; jangan mengganti hasil login gagal dengan user lama. Uji pergantian akun dan kegagalan persistensi secara eksplisit.

## Verifikasi yang selesai

| Pemeriksaan | Hasil akhir | Batas bukti |
| --- | --- | --- |
| `flutter analyze` | exit 0, `No issues found!` | Analisis Dart; tidak memeriksa keamanan atau kompilasi Swift hasil patch. |
| Enam file tes Flutter terkait auth, transport, navigasi dan desktop | exit 0, **32 tes lulus** | Unit/widget test; tidak melakukan login Google nyata atau memverifikasi cookie NotebookLM. |
| `node --check public/desktop-auth.js` | exit 0 | Sintaks JavaScript saja. |
| `ruby -c macos/patch_macos_keychain.rb` | exit 0, `Syntax OK` | Sintaks Ruby saja; hasil Swift tetap rusak. |
| Parser Swift pada SDK asli FirebaseAuth 11.15.0 | exit 0 untuk kedua file | Baseline reproduksi. |
| Parser Swift setelah patch diterapkan pada salinan SDK asli | **exit 1 untuk kedua file** | Bug patch direproduksi; bukan build release lengkap. |

Enam file tes: `desktop_transport_test.dart`, `audit_auth_stream_test.dart`, `agent_session_manager_test.dart`, `audit_navigation_test.dart`, `desktop_interaction_test.dart`, `desktop_release_test.dart`. Test callback memeriksa validator loopback, bukan handler hasil login in-app yang sekarang menjadi jalur utama.

Percobaan pertama analyzer terhenti karena sandbox tidak dapat menulis cache Flutter; eksekusi ulang yang diizinkan selesai dengan exit 0. Dependensi tidak dinaikkan versinya. Tracked source tetap bersih sesudah pemeriksaan.

## Kriteria sebelum mengklaim selesai

1. SDK dan build macOS dapat dipasang ulang dari dependensi bersih; kredensial native tetap pada penyimpanan aman.
2. Google masuk melalui konteks yang didukung, dengan callback terikat ke percobaan login dan tanpa token di URL.
3. Dari sesi baru, akun Firebase sesuai pilihan, notebook berizin dapat dibuka, pertanyaan dikirim, dan jawaban muncul. Ulangi setelah restart.
4. Pergantian akun, cancel, logout, sesi kedaluwarsa, notebook tanpa izin dan MFA berperilaku benar. Catat permintaan kredensial terpisah dari consent/pemilihan akun.

Tidak ada perubahan source produksi, reset Git, penghapusan sesi pengguna, build release, upload atau broadcast pada pemeriksaan ini. Laporan ini disimpan sebagai checkpoint tersendiri. Tidak ada klaim sukses menyeluruh atau jaminan Google tidak meminta verifikasi keamanan lagi.
