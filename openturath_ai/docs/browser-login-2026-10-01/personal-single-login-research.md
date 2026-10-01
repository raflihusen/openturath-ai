# Riset ulang satu login pribadi untuk OpenTurath dan NotebookLM

Tanggal pemeriksaan: 1 Oktober 2026. Basis kode lokal: `4870518`, branch `codex/browser-session-login-2026-10-01`.

**Status: penelitian sumber dan pemeriksaan kode, bukan perbaikan runtime atau bukti keberhasilan seluruh platform.** Tidak ada kredensial dibaca/diekspor, master token dibuat, akun login, SDK konektor dijalankan, pertanyaan NotebookLM dikirim, atau deployment dilakukan pada penelitian ini.

## Kesimpulan yang diperbarui

Pernyataan mutlak bahwa tidak ada solusi terlalu jauh. Ada kandidat teknis yang dapat menyatukan pengalaman login, mempertahankan akun masing-masing pengguna, dan menampilkan jawaban NotebookLM melalui UI native OpenTurath. Namun belum ada kandidat yang dibuktikan aman dan andal untuk Android, iOS, macOS, Windows, dan web sekaligus.

1. **Firebase tidak membutuhkan layar login terpisah.** Google ID token yang diterbitkan untuk klien OpenTurath dapat langsung menjadi kredensial Firebase. Alternatifnya, backend yang sudah memverifikasi identitas dapat menerbitkan Firebase custom token. [Firebase Flutter](https://firebase.google.com/docs/auth/flutter/federated-auth), [custom authentication](https://firebase.google.com/docs/auth/admin/create-custom-tokens).
2. **NotebookLM asli dapat diakses tanpa menampilkan seluruh halaman NotebookLM.** Konektor tidak resmi terbaru menyediakan backend gRPC layanan mobile, termasuk chat dan sumber. Ini bukti kemampuan mesin, belum bukti autentikasi pihak ketiga yang didukung Google. [Panduan Android penulis konektor](https://github.com/teng-lin/notebooklm-py/blob/main/docs/android/README.md).
3. **Konektor tidak wajib memakai akun operator bersama.** Sesi dapat dipisahkan per pengguna. Akun operator pada prototipe lokal terdahulu adalah pilihan implementasi yang sudah ditolak pengguna; bukan batas bawaan semua konektor. [Profil autentikasi konektor](https://github.com/teng-lin/notebooklm-py/blob/main/docs/installation.md).
4. **Jalur uji pertama yang direkomendasikan adalah desktop dengan browser pendamping.** UI percakapan tetap Flutter; ekstensi menjalankan permintaan di lingkungan browser pengguna dan mengirim jawaban/sitasi ke aplikasi. Ini hipotesis arsitektur, belum implementasi teruji.
5. **Kredensial Google akun penuh tidak direkomendasikan sebagai syarat rilis pelanggan.** Keberhasilan teknis memperoleh token tidak cukup untuk menyatakan akses tersebut sempit, resmi, atau aman.

## Batas kebutuhan produk

Tujuan aktif: aplikasi native OpenTurath, akun Google pribadi masing-masing pengguna, NotebookLM asli, jawaban dan sitasi di UI OpenTurath. Desain, PWA sebagai aplikasi utama, penggantian mesin, dan akun bersama tidak menjadi arah pekerjaan ini.

“Satu login” berarti satu autentikasi Google awal per perangkat/profil, diikuti autentikasi layanan otomatis. Izin pertama kepada OpenTurath, pemilihan akun, aktivasi ekstensi, persetujuan layanan, dan verifikasi ulang Google masih dapat memerlukan interaksi. Google mendokumentasikan bahwa `prompt=none` membutuhkan sesi autentikasi **serta persetujuan OAuth sebelumnya**; ia tidak menghilangkan consent pelanggan baru. [Google OpenID Connect](https://developers.google.com/identity/openid-connect/openid-connect).

## Mengapa kode sekarang belum menyelesaikannya

Pemeriksaan ulang menemukan:

- `lib/services/auth_service.dart` menukar kredensial Google menjadi sesi Firebase pada mobile/desktop; jalur web memakai Firebase popup.
- `lib/services/desktop_google_sign_in.dart` dan `public/desktop-auth.js` mengembalikan ID token melalui callback lokal. Halaman tersebut meminta pemilihan akun; tidak mengembalikan sesi situs NotebookLM.
- `lib/widgets/agent_multi_tab_room.dart` masih mempunyai runtime `InAppWebView`. Penyimpanan sesi browser sistem dan WebView merupakan batas terpisah.
- Prototipe backend chat tetap di balik flag `OPENTURATH_BACKEND_CHAT_PROTOTYPE`, tidak aktif secara default, dan tidak menjadi bukti koneksi per pengguna.

Karena itu keberhasilan Firebase tidak membuktikan NotebookLM sudah login. Google melarang OAuth pada browser tertanam yang dapat dikendalikan developer. Callback browser resmi mengembalikan hasil otorisasi untuk aplikasi; ia tidak otomatis memindahkan cookie situs ke WebView. [Kebijakan Google](https://developers.google.com/identity/protocols/oauth2/policies), [OAuth native](https://developers.google.com/identity/protocols/oauth2/native-app).

## Temuan baru: jalur token mobile benar-benar tersedia

Implementasi terbaru `notebooklm-py` memakai layanan `notebooklm-pa.googleapis.com`. Panduan penulis menyatakan backend Android mencakup sebelas namespace bertipe tanpa fallback operasi ke Web. Nama “Android backend” menjelaskan protokol layanan; bukan bukti bahwa bootstrap login pelanggan native Android/iOS sudah tersedia. Panduan juga mencatat wrapper kompatibilitas v0.x masih mempunyai permintaan homepage Web saat membangun klien. [Panduan backend](https://github.com/teng-lin/notebooklm-py/blob/main/docs/android/README.md).

Source autentikasinya menggunakan identitas paket/sertifikat aplikasi NotebookLM milik Google. Scope mencakup `labs-tailwind`, Drive penuh, foto baca, serta layanan akun lainnya. Ini berbeda dari token Google Sign-In biasa milik proyek OpenTurath. `labs-tailwind` tidak ditemukan pada katalog scope publik yang diperiksa; ketidakhadiran itu bukan bukti mutlak bahwa akses pihak ketiga mustahil, tetapi grant untuk klien OpenTurath belum ditemukan atau dibuktikan. [Source autentikasi](https://github.com/teng-lin/notebooklm-py/blob/main/src/notebooklm/_android/auth.py), [katalog scope Google](https://developers.google.com/identity/protocols/oauth2/scopes).

Penulis mendokumentasikan eksperimen satu bootstrap browser yang menghasilkan master token, kemudian token layanan dan sesi Web. Source yang dikirim sekarang memuat jalur tersebut. Namun kredensial akar itu memberi akses akun Google secara luas; penulis memperingatkan agar memakai akun khusus. Keberhasilan penulis bukan pengujian OpenTurath dan bukan jaminan Google menerima integrasi publik ini ke depan. Tidak ada prosedur pengambilan kredensial dijalankan pada penelitian ini. [Penelitian penulis](https://github.com/teng-lin/notebooklm-py/issues/1638), [implementasi master token](https://github.com/teng-lin/notebooklm-py/blob/main/src/notebooklm/_auth/master_token.py), [penerbitan token/sesi](https://github.com/teng-lin/notebooklm-py/blob/main/src/notebooklm/_auth/mint_service.py).

Wheel lokal `ecosystem/openturath_subscription/notebooklm_py-0.8.0a3-py3-none-any.whl` lebih lama daripada source terbaru yang diteliti. Tidak ada upgrade, instalasi, atau eksekusi wheel. Temuan upstream tidak berarti kode lokal otomatis memperoleh kemampuan tersebut.

## Perbandingan kandidat

| Kandidat | Kesesuaian produk | Bukti dan batas |
|---|---|---|
| Browser pendamping; cookie tetap di browser; UI chat Flutter | Akun pribadi dan UI native; kandidat pertama desktop | API ekstensi/pesan native resmi tersedia. Panggilan chat NotebookLM, sitasi, akun aktif, dan ketahanan sesi dari ekstensi belum diuji. |
| Pemindahan sesi satu kali melalui ekstensi | Secara teoritis memungkinkan konektor native per pengguna | Memindahkan kredensial Google yang luas. Rotasi, binding perangkat, logout, dan transport Android belum terbukti. |
| Master token + gRPC mobile + Firebase otomatis | Secara teknis dapat memakai mesin asli tanpa WebView | Source dan eksperimen penulis tersedia. Kredensial akun penuh serta identitas aplikasi Google membuatnya bukan jalur rilis pelanggan yang direkomendasikan. |
| Workspace Studio atau NotebookLM Enterprise | Integrasi resmi, tetapi model produk berbeda | Tidak membuktikan akses chat bersitasi untuk seluruh akun Gmail pribadi dan notebook consumer yang sudah ada. |

### Kandidat desktop yang mengurangi pemindahan kredensial

Alur usulan, **belum diuji**:

`Login Google di browser → ID token untuk OpenTurath → Firebase otomatis`

`Pertanyaan di Flutter → ekstensi pada profil browser yang sama → NotebookLM akun pengguna → jawaban/sitasi → Flutter`

Chrome mendokumentasikan bahwa host permission membuat permintaan ekstensi ke host tersebut diperlakukan same-site, sehingga cookie `SameSite=Strict` dapat dikirim, dengan batas pengaturan third-party cookies. Pola permintaan ini tidak membutuhkan ekspor nilai cookie atau izin `cookies`. Native messaging menyediakan komunikasi ekstensi dengan proses aplikasi desktop. [Cookie dan penyimpanan Chrome](https://developer.chrome.com/docs/extensions/develop/concepts/storage-and-cookies), [native messaging](https://developer.chrome.com/docs/extensions/develop/concepts/native-messaging).

API browser resmi tersebut tidak menjamin endpoint NotebookLM menerima Origin, CSRF state, akun, format request, atau streaming dari ekstensi. Mungkin diperlukan konteks halaman NotebookLM yang autentik. Iframe pihak ketiga tidak boleh diasumsikan memakai cookie top-level yang sama. Keberhasilan login atau ekspor notebook bukan bukti bahwa chat native bekerja.

| Platform | Batas yang ditemukan |
|---|---|
| macOS/Windows dengan Chrome/Edge | Native messaging tersedia; kandidat desktop pertama. Browser/profil harus cocok dengan login pengguna. |
| macOS dengan Safari | Pesan aplikasi–ekstensi tersedia. Profil, umur proses, dan panggilan NotebookLM perlu uji tersendiri. |
| iOS dengan Safari | Aplikasi containing tidak dapat memulai pesan ke JavaScript ekstensi. Pesan ekstensi ke native tersedia; background tidak persistent. Jembatan yang selalu siap untuk chat native belum terbukti. |
| Android dengan Firefox | Cookies API tersedia, tetapi native messaging add-on biasa tidak tersedia. Ekstensi privileged di GeckoView tidak berbagi profil Firefox eksternal secara otomatis. |
| Web | Masih membutuhkan grant/adapter yang diterima NotebookLM; iframe atau token Firebase saja tidak menyelesaikannya. |

Sumber tabel: [Apple messaging](https://developer.apple.com/documentation/safariservices/messaging-between-the-app-and-javascript-in-a-safari-web-extension), [umur background Safari](https://developer.apple.com/documentation/safariservices/optimizing-your-web-extension-for-safari), [kompatibilitas runtime Mozilla](https://raw.githubusercontent.com/mdn/browser-compat-data/main/webextensions/api/runtime.json), [ekstensi GeckoView](https://firefox-source-docs.mozilla.org/mobile/android/geckoview/consumer/web-extensions.html).

### Pemindahan sesi: kemungkinan mekanis, belum solusi rilis

Ada koreksi penting: Safari/iOS 18 mendukung pengembalian cookie HttpOnly melalui cookies API, menurut data kompatibilitas; source test WebKit juga memuat kasus tersebut. Firefox Android mendukung cookies API. Jadi “iOS tidak bisa membaca cookie HttpOnly” bukan alasan mutlak untuk menutup riset. [Data kompatibilitas cookies](https://raw.githubusercontent.com/mdn/browser-compat-data/main/webextensions/api/cookies.json), [test WebKit](https://raw.githubusercontent.com/WebKit/WebKit/main/Tools/TestWebKitAPI/Tests/WebKit/WKWebView/WKWebExtensionAPICookies.mm).

Namun kemampuan membaca tidak membuktikan sesi NotebookLM dapat dipakai dan diperbarui di native. Cookie `.google.com` dapat memberikan akses melampaui NotebookLM; Keychain/Keystore tidak mempersempit aksesnya. Device Bound Session Credentials di Chrome Windows juga dapat memerlukan pembuktian kunci browser saat refresh. Mengambil snapshot cookie tidak membawa mekanisme tersebut. Penerapan tepatnya pada akun NotebookLM pribadi belum diuji. [Pengumuman Chrome DBSC](https://developer.chrome.com/blog/dbsc-windows-announcement), [rollout Google](https://workspaceupdates.googleblog.com/2026/05/prevent-account-takeovers-with-DBSC-now-generally-available-in-the-Chrome-browser-for-Windows.html).

## Identitas Firebase harus tetap terikat dengan benar

Jalur prioritas adalah Google ID token dengan audience OpenTurath, kemudian Firebase `signInWithCredential`. Custom token adalah alternatif setelah backend memverifikasi identitas dan transaksi login; ia tidak mengautentikasi NotebookLM sendiri.

Mengirim bearer pihak pertama ke Google UserInfo dapat mengidentifikasi akun pemilik token. Itu belum membuktikan consent untuk OpenTurath atau bahwa token milik orang yang sedang menyelesaikan transaksi login ini. Penerimaan token harus memvalidasi identitas, audience yang sesuai, masa berlaku, nonce/state dan perlindungan replay/substitusi sesuai desain grant. [Validasi ID token Google](https://developers.google.com/identity/gsi/web/guides/verify-google-id-token), [OIDC/UserInfo](https://developers.google.com/identity/openid-connect/openid-connect).

Petakan Google `sub` terverifikasi ke provider `google.com` dan **Firebase UID yang sudah ada**. Jangan mencocokkan lewat email semata atau membuat UID baru yang memisahkan pembelian dan hak akses. Custom-token login tidak otomatis menautkan provider Google. Akun NotebookLM aktif juga harus dibuktikan sama; email yang disimpan Firebase bukan bukti sesi situs. [Lookup provider Firebase](https://firebase.google.com/docs/auth/admin/manage-users), [account linking](https://firebase.google.com/docs/auth/flutter/account-linking).

## Dua error pada screenshot memerlukan penanganan berbeda

Screenshot “finance bot”, `403 access_denied`, menyatakan aplikasi sedang testing dan hanya boleh diakses penguji yang disetujui. Itu bukti pembatasan proyek OAuth yang digunakan pada percobaan tersebut. Perbaikannya mencakup pengecekan client/proyek yang benar, daftar tester untuk pengujian, dan konfigurasi branding/publishing/verification yang sesuai untuk rilis. Tidak semua scope memiliki syarat verifikasi yang sama. Nama aplikasi berbeda harus ditelusuri, bukan diasumsikan telah benar. Status live Console proyek belum diaudit pada penelitian ini. [Aturan testing Google](https://developers.google.com/identity/protocols/oauth2/production-readiness/brand-verification), [kesiapan produksi](https://developers.google.com/identity/protocols/oauth2/production-readiness/policy-compliance).

Screenshot login Google di WebView menunjukkan sesi browser/Firebase belum menjadi sesi WebView. Penolakan embedded user-agent dan tantangan keamanan Google tidak diperbaiki dengan menghapus layar kedua atau menambah timeout. Penyimpanan Firebase macOS/Keychain merupakan masalah tambahan tersendiri, bukan jembatan ke NotebookLM.

## Integrasi resmi yang diperiksa

Workspace Studio mempunyai langkah Ask NotebookLM dan API pemicu flow. Tetapi akses akun/edisinya terbatas, pengguna perlu konfigurasi flow, dan langkah NotebookLM didokumentasikan mengembalikan teks tanpa sitasi. Ini belum memenuhi pengalaman kitab yang diminta. [Pengumuman Google](https://workspaceupdates.googleblog.com/2026/05/notebooklm-in-workspace-studio.html), [akses Studio](https://support.google.com/workspace-studio/answer/16444479?hl=en), [kontrak langkah NotebookLM](https://support.google.com/workspace-studio/table/17176961), [pemicu flow](https://developers.google.com/workspace/add-ons/studio/build-a-starter).

NotebookLM Enterprise memiliki API dan integrasi identitas enterprise dengan lisensi/IAM serta resource project/location. Permukaan dokumentasi yang diperiksa tidak memberi bukti grant chat consumer untuk semua akun Gmail pribadi. Mengadopsinya mengubah model akun dan resource produk. [API Enterprise](https://docs.cloud.google.com/gemini/enterprise/notebooklm-enterprise/docs/api-notebooks), [setup identitas/lisensi](https://docs.cloud.google.com/gemini/enterprise/notebooklm-enterprise/docs/set-up-notebooklm).

## Keputusan mengenai Chromium di dalam aplikasi

Pemeriksaan lanjutan pada 1 Oktober 2026 menjawab pertanyaan pengguna: **Chromium tidak diperlukan untuk autentikasi Firebase dan tidak cukup untuk menjamin satu login Firebase + NotebookLM. Jangan mengganti mesin aplikasi sebagai perbaikan autentikasi.**

### Mesin, profil, dan izin layanan adalah tiga hal berbeda

Chromium adalah mesin browser. Profil menyimpan cookie dan data situs. Izin layanan menentukan kredensial yang diterima Firebase atau NotebookLM. Menyamakan mesin tidak otomatis menyamakan profil, dan menyamakan profil tidak mengubah izin yang diberikan Google kepada klien OpenTurath.

Electron mendokumentasikan bahwa halaman dengan partition `persist:` yang sama berbagi sesi persistent **di dalam aplikasi**. WebView2 menyimpan data browser pada user-data folder aplikasi host. Kedua mekanisme itu membantu kontinuitas halaman aplikasi sendiri; tidak menjadi jembatan otomatis ke profil Chrome/Edge pengguna yang dipakai login melalui browser sistem. [Electron session](https://www.electronjs.org/docs/latest/api/session), [WebView2 user-data folder](https://learn.microsoft.com/en-us/microsoft-edge/webview2/concepts/user-data-folder).

Jika Google OAuth dibuka di browser sistem lalu callback dikirim ke aplikasi, hasil yang kembali adalah hasil otorisasi sesuai alur, bukan cookie profil browser. Memasang Chromium pada sisi penerima tidak mengubah isi callback. [Google native OAuth](https://developers.google.com/identity/protocols/oauth2/native-app).

### Mengapa Chromium embedded tetap dapat ditolak

Kebijakan Google mendefinisikan embedded user-agent berdasarkan kendali developer, termasuk kemampuan menyisipkan script, mengubah routing, atau mengakses session cookies. Jadi istilah “Chromium”, “Electron”, atau “WebView2” tidak memberikan pengecualian otomatis. Standar native OAuth juga menilai pemisahan domain keamanan; memindahkan browser ke proses atau jendela lain saja tidak membuktikan pemisahan itu. [Kebijakan Google](https://developers.google.com/identity/protocols/oauth2/policies), [RFC 8252](https://datatracker.ietf.org/doc/html/rfc8252).

Untuk login situs Google biasa, klaimnya tidak perlu dilebihkan menjadi “setiap percobaan pasti gagal”. Google menyatakan sign-in dapat dihentikan pada browser tertanam dan secara khusus meminta developer Chromium Embedded Framework memindahkan Sign in with Google ke browser-based OAuth. Percobaan yang kebetulan lolos tidak menjadi bukti dukungan saat akun baru, challenge, atau re-authentication. [Panduan browser Google](https://support.google.com/accounts/answer/7675428), [panduan developer CEF](https://developers.googleblog.com/en/guidance-to-developers-affected-by-our-effort-to-block-less-secure-browsers-and-applications/).

Browser penuh yang kompatibel, misalnya Chrome/Edge, berbeda dari memasukkan library Chromium ke aplikasi. Menjadi browser penuh yang diterima Google juga tidak menyediakan API chat NotebookLM bagi UI Flutter secara otomatis. Mengganti User-Agent agar menyerupai browser lain tidak dipakai sebagai perbaikan.

### Pilihan arsitektur yang dapat dipertanggungjawabkan

| Pilihan | Keputusan |
|---|---|
| Chromium embedded untuk login Google lalu menyembunyikan NotebookLM | Ditolak sebagai perbaikan login. Tetap mempunyai batas Google authentication dan belum memenuhi seluruh platform. |
| Autentikasi Google resmi; Firebase mengikuti otomatis | Fondasi identitas yang direkomendasikan. Tidak perlu login Firebase kedua. Tidak dengan sendirinya memberi akses NotebookLM. |
| UI Flutter + browser pendamping per pengguna | Eksperimen desktop yang diprioritaskan; belum janji produk semua platform. Browser tetap mengelola sesi situs. |
| UI native + grant API NotebookLM untuk identitas klien OpenTurath | Target arsitektur untuk rilis lintas platform jika grant chat/sitasi tersebut benar-benar tersedia dan tervalidasi. Permukaan resmi yang diperiksa belum membuktikan grant consumer itu. |

Fondasi Firebase didukung dokumentasi [federated authentication](https://firebase.google.com/docs/auth/flutter/federated-auth). Jembatan desktop mempunyai mekanisme [native messaging](https://developer.chrome.com/docs/extensions/develop/concepts/native-messaging), tetapi penerimaan request NotebookLM masih merupakan gate berbeda. Target API pada tabel adalah syarat arsitektur, **bukan klaim bahwa API Enterprise atau token Firebase yang ada telah memenuhi syarat itu**.

Dalam eksperimen pendamping, login Google harus tetap ditangani manusia melalui browser asli. Ekstensi tidak perlu diberi akses ke `accounts.google.com`, menyisipkan script pada halaman login, mengotomasi autentikasi, atau mengekspor nilai cookie. Izin dan kanal komunikasi dipersempit untuk pekerjaan NotebookLM serta aplikasi yang sudah dipasangkan. Ini rancangan pembatasan, belum implementasi yang diuji.

### Apa arti “pasti berhasil” pada keputusan ini

Yang dapat dirancang tanpa layar login kedua adalah pertukaran identitas Google ke Firebase. Yang belum bisa dijanjikan adalah seluruh alur NotebookLM dalam UI native pada semua platform. Persetujuan pertama dan tantangan Google tetap berada pada Google; `prompt=none` hanya berlaku ketika autentikasi dan consent sudah ada. [Google OIDC](https://developers.google.com/identity/openid-connect/openid-connect).

Karena itu keputusan berikutnya bukan membangun Chromium atau menambah retry. Keputusan berikutnya adalah membuktikan akses NotebookLM yang sah, akun yang cocok, jawaban/sitasi, dan pembaruan sesi pada satu implementasi nyata. Jika semua syarat produk tetap wajib, kegagalan gate mobile atau grant upstream harus disebut hambatan rilis, bukan ditutupi dengan klaim bahwa desktop yang lolos menjamin semuanya.

## Pembuktian berikutnya yang bernilai

Rekomendasi penelitian berikutnya adalah eksperimen desktop tanpa ekspor cookie, menggunakan akun uji dan notebook dummy yang disetujui untuk pengujian. Prototipe tidak dinyatakan lolos hanya karena popup Google berhasil atau fixture hijau.

Kriteria hasil yang perlu dicatat:

1. Satu autentikasi awal; Firebase selesai otomatis; pertanyaan asli menghasilkan jawaban dan sitasi di Flutter.
2. Akun Firebase dan NotebookLM sama, termasuk ketika browser mempunyai dua akun Google; akun salah ditolak.
3. Tutup/buka aplikasi, restart proses pendamping, serta expiry/refresh tidak merusak binding akun atau membuat loop login.
4. Logout membatalkan akses/pairing aplikasi; sesi browser Google diperlakukan sebagai mekanisme terpisah dan dijelaskan dengan tepat.
5. Pergantian pengguna, notebook tanpa izin, penolakan consent, dan browser yang tidak tersedia menghasilkan kegagalan yang jelas tanpa kebocoran sesi atau konteks.
6. Sesudah desktop terbukti, uji iOS dan Android secara terpisah. Desktop yang lolos tidak memberi status lolos semua platform.

Jalur gRPC baru layak menjadi kandidat rilis umum apabila grant yang sesuai untuk identitas OpenTurath dapat diperoleh dan diuji, atau desain autentikasi lain benar-benar lolos batas akses, consent, pencabutan, dan isolasi. Menggunakan identitas paket Google atau mengumpulkan master token pelanggan tidak dipakai sebagai jalan pintas untuk menyatakan gate tersebut selesai.

Penelitian ini menghasilkan keputusan uji dan batas pembuktiannya. Sistem aplikasi belum diperbaiki atau dinyatakan siap rilis oleh dokumen ini.
