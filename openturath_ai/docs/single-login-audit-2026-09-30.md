# Satu login Google untuk OpenTurath dan NotebookLM

Tanggal: 30 September 2026, Asia/Aden. Status: diagnosis dan keputusan arsitektur yang disarankan; belum ada implementasi atau keberhasilan login menyeluruh pada iterasi ini. NotebookLM tetap merupakan mesin yang wajib dipertahankan.

## Jawaban yang dapat dipertanggungjawabkan

Pengguna dapat memiliki satu pintu masuk Google dan, pada kondisi normal, cukup memasukkan kredensial Google sekali. Firebase menerima hasil autentikasi Google; NotebookLM memakai sesi Google pada browser yang sama. Secara teknis tetap ada dua sesi layanan. Persetujuan OAuth awal, pemilihan akun, verifikasi dua langkah, pencabutan sesi, dan pemeriksaan risiko Google tidak dapat dijanjikan hilang.

Pada wadah Flutter + WKWebView saat ini, login Firebase di browser utama tidak menciptakan sesi NotebookLM di WKWebView. Mengisi email, memilih `authuser`, atau menyimpan boolean siap tidak mengubah batas tersebut. Google mendokumentasikan risiko `disallowed_useragent` pada WKWebView dan melarang OAuth melalui embedded user-agent yang dikendalikan aplikasi. Lihat [OAuth native apps](https://developers.google.com/identity/protocols/oauth2/native-app) dan [kebijakan browser OAuth Google](https://developers.google.com/identity/protocols/oauth2/policies).

## Bukti kasus aktual

Screenshot `9.40.16 PM` menunjukkan formulir masuk Google standar di dalam OpenTurath. Banner aplikasi mengenali email pilihan, tetapi formulir masih kosong. Screenshot ini sendiri tidak membuktikan akun dibobol atau OAuth aplikasi belum diverifikasi.

Pembacaan accessibility aplikasi yang sedang berjalan mengonfirmasi:

```text
OpenTurath AI
  Sign in - Google Accounts
  accounts.google.com/v3/signin/identifier
    continue → notebook.google.com/login
    continue → notebook.google.com/notebook/<id>
  Email or phone
  Next
```

Notebook ID dan alamat email tidak disalin ke laporan. Perbandingan notebook pada browser utama sempat dicoba, tetapi browser berubah saat operasi berjalan. Pemeriksaan dihentikan; akses NotebookLM melalui browser utama belum dinyatakan berhasil atau gagal. Tidak ada password, cookie, token akun, atau data preferensi kredensial yang dibaca untuk audit ini.

Screenshot “finance bot” sebelumnya bukan bukti konfigurasi OpenTurath. Source yang dibaca memakai Firebase `open-turath` dan OAuth client berprefiks proyek `255541559800`. Konfigurasi consent produksi belum diperiksa melalui Cloud Console. [Dokumentasi audience Google](https://support.google.com/cloud/answer/15549945) juga menjelaskan pengecualian mode Testing untuk autentikasi yang hanya meminta identitas dasar; menambahkan test user atau mengubah publikasi proyek tidak memperbaiki sesi WKWebView yang kosong.

## Jalur yang menyebabkan login ganda

```text
Tombol masuk OpenTurath
  → DesktopGoogleSignIn
  → halaman Firebase di browser utama
  → autentikasi Google
  → credential Google dikirim ke aplikasi
  → Firebase.signInWithCredential
  → profil OpenTurath tersedia

Buka asisten
  → URL NotebookLM
  → InAppWebView / WKWebView
  → penyimpanan sesi WebView belum memiliki sesi Google
  → halaman Email or phone
```

Temuan source saat dibaca:

| Lokasi | Fakta dan implikasi |
| --- | --- |
| `lib/services/auth_service.dart:88` | Desktop memakai browser untuk Firebase; setelah login, baris 125 mengatur `google_session_ready = true` tanpa pemeriksaan NotebookLM. |
| `lib/services/desktop_google_sign_in.dart:97` | Callback juga mengatur boolean tersebut sebelum pertukaran credential Firebase selesai. Ia bukan bukti sesi browser NotebookLM. |
| `lib/widgets/agent_multi_tab_room.dart` dan `lib/screens/agent_webview_screen.dart` | NotebookLM tetap dimuat di InAppWebView; halaman akun Google diizinkan tampil inline. User-agent diberi identitas Safari/Chrome. Mengubah string ini tidak mengubah WebView menjadi browser sistem. |
| `lib/screens/google_session_auth_screen.dart` | Masih menyediakan login Google di WebView, serta pemeriksaan nama cookie/URL. Cookie atau URL saja tidak membuktikan akun dan izin notebook yang dimaksud. |
| `lib/services/native_agent_launcher.dart` | Browser dibuka melalui AccountChooser dan petunjuk akun. Petunjuk akun bukan autentikasi, bukan pemindahan cookie, dan bukan jaminan akses. |

Head awal audit: `5469523`. Beberapa file auth berubah secara lokal saat audit berlangsung. Laporan ini menjaga perubahan tersebut dan tidak mengedit atau memasukkannya ke commit laporan. Fakta source di atas harus diperiksa kembali saat implementasi berikutnya.

## Rekomendasi desktop: satu profil browser yang didukung

Gunakan browser sungguhan untuk kedua alur, dengan profil yang sama dan mode biasa. NotebookLM menjadi halaman utama; OpenTurath hadir sebagai navigasi, pustaka, catatan dan pengelolaan akses di panel pendamping. Ini mempertahankan NotebookLM asli dan mengubah wadah desktop agar sesi Google tidak terpisah.

Untuk pengalaman yang menyatu dalam satu jendela, **extension Chrome dengan Side Panel** merupakan opsi konkret. [API Side Panel resmi](https://developer.chrome.com/docs/extensions/reference/api/sidePanel) mendukung UI pendamping yang tetap tersedia di sebelah halaman. Firebase menyediakan [alur autentikasi extension resmi](https://firebase.google.com/docs/auth/web/chrome-extension), termasuk metode federasi melalui halaman offscreen milik pengembang dan popup browser. Halaman akun Google tetap merupakan konteks browser resmi, bukan iframe login atau DOM login yang dibaca OpenTurath.

```text
Satu profil Chrome
├─ Google sign-in: satu identitas dan sesi browser
├─ NotebookLM: tab utama, tetap di domain Google
└─ OpenTurath: panel aplikasi
   ├─ hasil Google sign-in → Firebase Auth
   ├─ entitlement melalui Firebase/backend
   └─ katalog dan catatan
```

Alur normal: pengguna menekan Masuk Google, memilih akun/menyetujui akses jika perlu, lalu membuka notebook di profil yang sama. Sesi Google yang sudah aktif dapat digunakan tanpa mengetik password lagi, selama masih valid dan Google tidak meminta pemeriksaan tambahan. Ini adalah rancangan yang layak berdasarkan dukungan platform; belum diuji menyeluruh dengan akun pengguna.

Tradeoff penting: extension/side panel adalah perubahan wadah desktop dan membutuhkan penyiapan serta pemasangan extension. Ia bukan APK Flutter, dan tidak memberikan antarmuka NotebookLM di dalam WKWebView yang lama. Alternatif transisi adalah mempertahankan Flutter untuk fitur native dan menggunakan browser utama untuk notebook; itu mengurangi perubahan, tetapi memakai dua jendela. Sekadar membuat PWA tidak otomatis membuat situs NotebookLM dapat di-iframe pada domain OpenTurath.

| Opsi | Hasil yang realistis |
| --- | --- |
| Extension + tab NotebookLM pada satu profil | Disarankan untuk satu jendela desktop dan penggunaan ulang sesi Google; perlu implementasi dan uji akun. |
| Flutter + browser utama untuk NotebookLM | Transisi dengan browser yang didukung; masih ada perpindahan jendela. |
| Flutter + WKWebView lama | Tidak memberi penyatuan sesi browser; login embedded tetap berisiko ditolak. |
| Electron/CEF atau user-agent palsu | Bukan pengganti browser yang didukung untuk OAuth. |
| Notebook publik | Tidak menyediakan jalan pintas tanpa akun; [panduan publik](https://support.google.com/gemininotebook/answer/16322204?hl=id) tetap mengacu pada akun Google dan memperluas akses notebook. |

Di Android/iOS, alur browser/native resmi perlu dirancang dan diuji terpisah. Google Sign-In SDK untuk Firebase tidak dengan sendirinya membuat cookie Google pada WebView seluler. Tidak ada klaim bahwa solusi desktop berlaku otomatis pada APK.

## Temuan keamanan yang harus ditangani

1. **Kredensial macOS dialihkan ke preferensi biasa.** `macos/patch_macos_keychain.rb` mengubah Firebase AuthStoredUserManager dan AuthKeychainServices untuk menyimpan data ke AuthUserDefaults. Pod terpasang memperlihatkan penerapan aktif; AuthUserDefaults memakai persistent domain UserDefaults, sedangkan objek User menyertakan tokenService. Ini adalah pelemahan penyimpanan kredensial, bukan perbaikan Keychain yang aman. Tidak ada bukti token telah bocor, dan data kredensial pengguna tidak dibaca. [Apple mengarahkan data sensitif ke Keychain](https://developer.apple.com/documentation/foundation/userdefaults), dan [Firebase meminta Keychain Sharing pada macOS](https://firebase.google.com/docs/auth/ios/start). Pulihkan SDK resmi, capability/entitlement dan penandatanganan aplikasi yang benar. Rancang migrasi/invalidation salinan lama secara eksplisit; jangan menghapus preferensi pengguna secara massal.
2. **Jalur login WebView dan token pada fragment URL masih ada.** `public/desktop-auth.js:48–56` menyediakan bridge in-app dan memasukkan payload termasuk token ke hash. Hapus jalur tersebut pada arsitektur browser baru; jangan membaca DOM login, menyalin cookie Google, atau menaruh token dalam URL/log. Callback aplikasi harus terikat ke percobaan login, dibatasi, dan kredensial diverifikasi oleh Firebase sebelum dipercaya.
3. **Status siap dicampur dengan petunjuk akun.** Email pilihan hanya boleh menjadi preferensi. Pisahkan status Firebase, sesi browser Google, dan akses notebook. Status terakhir harus berasal dari hasil membuka notebook yang sebenarnya, bukan boolean setelah login Firebase.
4. **Kegagalan penyimpanan tidak boleh mengesahkan akun yang salah.** Fallback `keychain-error` yang mengambil `currentUser` perlu memastikan identitas hasil login terbaru, khususnya ketika mengganti akun. Mengabaikan error tidak memperbaiki kemampuan persistensi SDK.

Google tetap dapat meminta MFA/passkey atau autentikasi ulang pada perangkat, akun atau sesi yang dinilai berisiko. Keamanan yang baik mempertahankan pemeriksaan itu. Sasaran produk adalah menghilangkan login berulang akibat wadah yang salah dan menunjukkan sebab kegagalan yang benar, bukan menjanjikan bebas seluruh pemeriksaan keamanan.

## Rencana penerapan dan kriteria selesai

1. Hentikan percobaan mengisi Google login di WKWebView. Tetapkan wadah browser sebagai keputusan produk desktop, dengan masa transisi Flutter yang jelas.
2. Implementasikan satu pintu Google sign-in dengan scope identitas minimum; gunakan SDK Firebase resmi. Jangan meminjam OAuth client aplikasi lain atau meminta Drive/Gmail untuk membuka UI NotebookLM.
3. Buat pendamping browser dengan izin minimum dan tanpa izin cookie/accounts.google.com. Simpan state Firebase melalui SDK resmi, lindungi UI dari XSS, dan pisahkan akses server dari tampilan notebook. Jika komunikasi ke aplikasi native diperlukan, gunakan saluran pesan terverifikasi dengan data minimum; jangan memakai cookie akun Google sebagai token aplikasi.
4. Pertahankan domain Google dan indikator keamanan browser saat autentikasi. Notebook dibuka pada konteks utama; izin notebook tetap diatur di NotebookLM, bukan disimpulkan dari entitlement Firebase.
5. Pulihkan penyimpanan aman pada jalur native macOS yang masih dipakai. Buat checkpoint sebelum migrasi, lalu uji penandatanganan, persistensi, dan pergantian akun. Jangan memublikasikan build sebelum pemeriksaan selesai.
6. Uji akun baru tanpa sesi → satu kali kredensial Google → Firebase benar → notebook berizin → kirim pertanyaan → jawaban muncul → restart → buka kembali. Uji pula multi-akun, notebook tanpa izin, cancel, sesi kedaluwarsa, MFA, profil berbeda dan logout. Catat langkah tambahan yang diminta Google; jangan menyebut setiap consent sebagai kegagalan login.

Kriteria penerimaan: tidak ada halaman identifier kedua karena penyimpanan WebView terpisah; Firebase UID/email sesuai akun yang dipilih; notebook benar dan dapat merespons; reload/restart memakai sesi sah; akun tanpa izin tetap ditolak; token tidak muncul dalam URL/log atau preferensi native biasa. Jumlah klik dan permintaan kredensial dibedakan dalam bukti uji.

## Checkpoint dan batas pekerjaan audit

Tag baseline: `codex/single-login-audit-base-2026-09-30` menunjuk `5469523` dan tidak memuat perubahan lokal yang belum di-commit. Laporan ini disimpan dalam commit sendiri. Gunakan `git show` untuk membandingkan; tidak dilakukan reset, perubahan desain, pemasangan extension, perubahan Cloud Console, penghapusan sesi pengguna, build release, upload, atau broadcast versi.

Skill `security-review` dipakai untuk pemeriksaan kredensial, sesi dan callback. Verifikasi iterasi ini adalah pembacaan source, runtime accessibility dan dokumentasi primer. Tidak ada klaim tes/build atau login berhasil setelah suatu perubahan kode, karena audit ini tidak mengubah source aplikasi.
