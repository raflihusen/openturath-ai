# ADR usulan: sesi Google, cookie, dan keamanan browser OpenTurath

Tanggal: 6 November 2026. Status: **usulan untuk ditinjau; belum diimplementasikan**.
Basis kode saat audit: `3e326355`, branch `codex/diagnostic-access-session-recovery`.

## 1. Keputusan yang disarankan

Pisahkan keamanan identitas aplikasi, hak paket, dan sesi situs Google. Pertahankan akun/ledger/VIP yang ada selama perbaikan. Jangan memigrasikan pembayaran atau membuka notebook publik untuk menyelesaikan persoalan cookie.

Untuk jalur dengan kompatibilitas login Google paling kuat, gunakan **browser yang didukung dan profil yang sama sepanjang login dan penggunaan AI**. Android dapat memakai Custom Tabs agar tetap terasa berada dalam aplikasi. macOS/Windows dapat memakai browser sistem; iOS harus memilih konteks browser yang jelas. Ini usulan produk yang memiliki konsekuensi tampilan, bukan penggantian diam-diam atas ruang AI saat ini.

Untuk mempertahankan tampilan internal yang sekarang, tetap sediakan WebView dengan persistent store native, batas origin ketat, dan bridge minimum. Perbaiki keamanan jalur ini terlebih dahulu. Jalur embedded bukan janji bahwa Google selalu menerima semua jenis autentikasi. Bila Google menolak konteks embedded, tawarkan melanjutkan **seluruh sesi AI** di browser, bukan login browser lalu menganggap cookie sudah pindah ke WebView.

Urutan keputusan: hardening terukur → prototipe browser pada perangkat bermasalah → pilih jalur default berdasarkan kebutuhan tampilan dan bukti perjalanan lengkap → migrasi bertahap setelah persetujuan. Bukan membangun browser baru, meniru identitas Chrome/Safari, atau memindahkan cookie.

Sasaran penerimaan adalah kredensial tidak bocor, sesi tidak dirusak aplikasi, hak akses tepat, dan pemulihan jelas. Tidak ada arsitektur yang dapat menjamin tidak pernah ada galat/kerentanan atau pertanyaan keamanan Google. Bahkan browser yang didukung masih bisa meminta autentikasi ulang akibat kedaluwarsa, pencabutan sesi, atau kebijakan akun.

## 2. Mengapa browser aplikasi lain tampak lebih lancar

Dokumentasi ChatGPT desktop menyebut browser bawaan memakai browser state sendiri; koneksi ke Chrome memakai profil Chrome yang terpisah. Dokumentasi Claude juga menyebut browser terpisah yang mengingat login, ditambah pilihan impor per situs dan koneksi ke Chrome. Sumber tersebut tidak mengungkap seluruh detail engine/trust Google atau membuktikan pengecualian khusus untuk kedua perusahaan.

Yang layak ditiru: profil persisten yang konsisten, origin halaman terlihat, batas izin, dan kontrol pengguna atas sesi. Bukan menyimpulkan WebKit pasti diterima atau menyalin cookie seperti fitur browser lain. Konfigurasi spesifik Via/Search yang dimaksud pengguna belum diverifikasi.

Mesin perender, aplikasi browser, data store, dan embedded user-agent adalah empat hal berbeda. Android WebView tidak berbagi cookie dengan browser utama; Custom Tabs memakai sesi browser penyedianya. WKWebView memiliki penyimpanan aplikasi sendiri; default store persisten bukan janji berbagi cookie dengan Safari. WebView2 menggunakan folder/profil aplikasinya sendiri, bukan profil Edge pengguna.

Google melarang permintaan OAuth aplikasi di embedded user-agent yang dikendalikan pengembang. Ini berbeda dari login pihak pertama di situs Google: kebijakan OAuth tidak sendirian membuktikan penyebab setiap kegagalan login situs yang teramati. ASWebAuthenticationSession/native SDK dapat menyelesaikan otorisasi aplikasi; hasilnya bukan cookie yang otomatis mengisi WKWebView.

## 3. Temuan sumber saat ini

Temuan defensif di bawah bukan bukti eksploitasi, kebocoran aktual, atau sebab pasti semua keluhan pengguna.

| Prioritas | Bukti | Implikasi dan tindakan |
|---|---|---|
| P0 | Login WebView tidak memiliki pagar main-frame `shouldOverrideUrlLoading`; popup saja diperiksa (`google_session_auth_screen.dart:1294`) | Cegah dokumen tak tepercaya memasuki permukaan login; validasi sebelum navigasi, tampilkan origin yang benar. |
| P0 | Navigasi room mengizinkan main-frame `javascript:`, `data:`, `blob:` dan cabang ekosistem Google yang luas tanpa syarat HTTPS (`agent_multi_tab_room.dart:2373–2415`) | Batasi dokumen utama ke origin HTTPS yang diperlukan. Bedakan dokumen utama dari subresource agar reCAPTCHA/Google tidak rusak. |
| P0 | `otAnswerState`, `otAnswerChunk`, `otStopRequested` belum seragam memeriksa sender origin/frame, schema, ukuran, dan epoch (`agent_multi_tab_room.dart:2131–2202`) | Lindungi semua native callback. URL top-level bukan bukti frame pemanggil. Kode plugin bridge iOS saat ini juga dimuat pada subframe. |
| P1 | `webview_cookie_policy.dart:10–11` mematikan Foundation cookie bridge hanya di macOS | iOS masih memungkinkan replay jar Foundation; kode plugin iOS 1.1.2 menyalin `HTTPCookieStorage.shared.cookies` ke WebKit. Uji pemakaian persistent WebKit store tanpa bridge juga pada iOS. Ini bukan bukti insiden DBSC. |
| P1 | Guard cloak login memakai `host.includes(...)` (`google_session_auth_screen.dart:139`) | Gunakan exact HTTPS origin dan frame guard; jangan cocokkan host lookalike. |
| P1 | Hapus akun memanggil pembersihan sesi global (`auth_service.dart:739`) | Selaraskan dengan aturan owner bahwa pembersihan global hanya dari Log Out eksplisit. Tentukan makna hapus data, logout, dan pencabutan akun secara jelas sebelum mengubah perilaku. |
| Sudah baik | `persistent_google_session.dart` hanya menyimpan marker akun; tidak ditemukan `setCookie` di `lib` | Pertahankan tanpa vault cookie/token Google buatan. Marker dan cookie presence bukan otorisasi server atau bukti sesi diterima Google. |
| Sudah baik | Windows menyiapkan folder `ApplicationSupport/webview2`; login/room non-incognito | Pertahankan lokasi/profil stabil selama update dan pergantian tab. |
| Sudah baik | Tidak ditemukan bypass TLS atau UA spoof pada login/room; mixed content dilarang, Android cleartext false, inspector release tidak diaktifkan melalui kDebugMode | Jangan mengklaim login saat ini menyamar sebagai Safari/Chrome. Payment sheet masih memiliki UA khusus dan perlu penilaian terpisah. |

`safeBrowsing`, akses file/content, dan permission handler belum seluruhnya eksplisit pada login/room. Periksa default plugin/platform yang benar sebelum patch; tidak adanya flag eksplisit tidak otomatis berarti izin terbuka. Gunakan health/version checks untuk WebView/OS/WebView2, bukan mengubah user-agent supaya terlihat lebih baru.

## 4. Kontrak penyimpanan sesi

1. Cookie Google hanya dikelola penyimpanan native/browser pemiliknya. Dilarang mengekspor ke SharedPreferences/JSON/server, memperpanjang expires, mengganti SameSite, atau mengimpor cookie dari Safari/Chrome/Edge. Jangan menganggap semua file cookie selalu terenkripsi di semua OS; verifikasi kemampuan penyimpanan platform dan lindungi direktori/backup sesuai dukungan nyata.
2. Embedded Apple: gunakan persistent WKWebsiteDataStore yang sama untuk login dan tab AI. Hindari Foundation bridge yang menimpa cookie; tidak menghapus store saat mengubah pengaturan. Uji iOS sebelum memperluas perbaikan macOS yang ada.
3. Embedded Android: gunakan cookie store WebView aplikasi yang konsisten, bukan browser utama. Non-incognito untuk sesi yang ingin dipertahankan. Jangan menjadwalkan flush/copy token buatan untuk meniru persistensi. Periksa kebutuhan flush API native bila didukung berdasarkan hasil uji shutdown, bukan sebagai perpanjangan sesi.
4. Embedded Windows: satu environment/UDF per pengguna OS dalam direktori aplikasi yang stabil, tidak di folder sementara/installer. Pergantian versi aplikasi tidak memindahkan atau membuat ulang profil tanpa migrasi. Jangan memakai langsung folder profil Edge/Chrome.
5. Browser path: cookie tetap di browser. OpenTurath tidak mengekspor, membaca, atau menghapus seluruh cookie Google milik browser pribadi. Tombol Keluar aplikasi harus menjelaskan bahwa sesi browser terpisah dapat tetap aktif.
6. Marker lokal hanya memberi petunjuk untuk mencoba memulihkan sesi. Tidak ada keputusan VIP/paket/identitas server berdasarkan marker, nama cookie SID, atau email hasil DOM. Sesi dicabut/expired menjadi perlu dihubungkan, bukan alasan menghapus akun.
7. Account switch membatalkan pekerjaan lama melalui epoch/generation dan melepas klaim pemilik. Jangan menghapus cookie otomatis atau diam-diam mengubah akun Google pengguna. Cocokkan akun aplikasi yang terverifikasi dengan akun tujuan akses; mismatch ditampilkan secara jelas.
8. Startup, timeout, HTTP 403, callback gagal, pembukaan tab baru, dan crash tidak boleh memanggil global cookie/cache clear. Pemulihan membuat ulang view bila diperlukan sambil mempertahankan store. Pembersihan harus tindakan pengguna yang eksplisit sesuai aturan owner.
9. Refresh token/sesi aplikasi tetap di secure storage yang didukung SDK/OS. Cookie situs dan token Firebase/OAuth bukan format yang saling dapat ditukar. Jangan mengirim data cookie ke log, laporan, clipboard, atau server bantuan.
10. Cache/UI bertuliskan siap harus diinvalidasi saat identitas/tujuan berubah. Kesiapan aktual diperiksa per notebook melalui composer dan satu jawaban nyata pada pengujian. URL account/security milik Google dapat menjadi sinyal kembali ke aplikasi, bukan bukti identitas AI.

## 5. Batas keamanan WebView

- Pisahkan aturan main-frame, popup, subframe, dan resource. Main-frame menolak HTTP, kredensial dalam URL, host lookalike, port tak diharapkan, serta file/content/javascript/data/blob yang tidak memiliki kebutuhan eksplisit. `about:blank` hanya untuk bootstrap internal yang dibuktikan, tanpa bridge berprivilege.
- Gunakan HTTPS origin exact untuk login/notebook. Daftar redirect didasarkan pada trace login yang disanitasi; jangan memberi wildcard seluruh Google hanya demi meloloskan satu redirect. Subresource mengikuti mekanisme keamanan browser dan kebutuhan provider, bukan dipaksa memakai allowlist halaman utama.
- Tautan rujukan di luar domain dibuka di browser setelah intent pengguna. Validasi pula target popup dan redirect sebelum dibuka. Jangan mewariskan bridge aplikasi ke jendela baru.
- Tidak ada injeksi CSS, pembacaan formulir/DOM, otomasi input, atau bridge aplikasi di halaman password, OTP, reCAPTCHA, passkey, dan pemulihan Google. Hentikan pula pembacaan body untuk mendeteksi rejection pada halaman autentikasi; gunakan sinyal URL yang aman dan pilihan pelaporan pengguna. Visual Google jangan disamarkan menjadi formulir OpenTurath.
- Injeksi UI hanya di origin notebook yang cocok tepat dan area yang diperlukan. Bridge dinonaktifkan pada auth/untrusted content. Tiap callback memeriksa sender origin, main-frame, tab, sesi/epoch, schema, ukuran payload, dan frekuensi. Jika versi plugin tidak menyediakan informasi asal frame yang andal, kurangi/nonaktifkan handler sensitif atau upgrade terisolasi; nonce dalam JavaScript bukan pengganti validasi origin.
- TLS/certificate error berhenti dengan pesan; tidak ada tombol lanjut tidak aman, custom trust-all, SSL bypass, atau pemasangan sertifikat untuk menyiasati penolakan Google.
- Kamera, mikrofon, lokasi, file, clipboard otomatis, dan download ditolak secara default kecuali fitur membutuhkan dan pengguna memberi tindakan/izin yang jelas. Biometrik/passkey ditangani API/browser yang memang mendukung, bukan diemulasi.
- Aktifkan perlindungan Safe Browsing bila tersedia, inspector off pada release, runtime/OS didukung dan terbarui, serta paket/signature benar. Pemeriksaan OAuth paket/sertifikat tetap dijalankan sebelum artefak Android dibagikan.
- Checkout berbeda trust domain dari akun Google. Rencanakan browser-owned checkout atau isolasi profil pembayaran bila plugin mendukung; jangan memisahkan store login/notebook yang justru harus sama. Uji 3DS, redirect, dan pemulihan sebelum mengubah profil payment yang ada.
- Hapus log console/URL yang bisa memuat isi jawaban, email, query, fragment, kode OAuth, token, atau cookie. Diagnostik memakai stage, kode galat, kategori, versi runtime/aplikasi, dan domain/kategori halaman yang telah disanitasi; jangan mengambil tangkapan layar login otomatis.

## 6. Login tunggal, profil, dan pembayaran

Untuk akses berbayar dengan profil pribadi, backend tetap memerlukan identitas terverifikasi. Firebase dapat tetap internal; tidak perlu formulir khusus Firebase. Pengguna masuk Google untuk akun aplikasi, backend memeriksa token, lalu menampilkan paket per modul. Jangan menghapus UID/data pelanggan untuk mengganti tampilan login.

Hapus kewajiban melewati layar koneksi AI di awal. Setelah sesi aplikasi aktif, masuk beranda; hubungkan AI pada saat diperlukan bila jalur embedded dipilih. Ini menghilangkan hambatan dua tahap di awal, bukan menjamin hanya ada satu prompt sepanjang penggunaan.

Jika browser dijadikan jalur utama, prototipe login aplikasi dengan alur OAuth didukung dalam browser, lalu buka AI di browser/profile yang sama. Callback ke aplikasi membawa hasil otorisasi aplikasi yang diverifikasi, bukan cookie Google. Wajib state/nonce/PKCE sesuai alur, redirect yang didaftarkan, timeout, dan pengikatan satu kali agar akun lama/VIP tidak kehilangan identitas. Consent/pemilih akun/2FA masih mungkin muncul; jangan menyebutnya satu login pasti.

Jika pemilik menghendaki benar-benar tanpa akun aplikasi, profil tidak bisa otomatis menjadi profil paket pribadi hanya karena situs Google sudah login. Pilihan produk: pengaturan lokal + tautan portal paket terautentikasi, atau aktivasi perangkat yang terverifikasi dan dilabeli sebagai hak perangkat. Pembatasan notebook privat tetap dilakukan Google; notebook publik tidak dapat menjadi pagar pembayaran yang kuat.

Status profil harus memisahkan: akun aplikasi terverifikasi; paket per AI beserta expiry/VIP; penyediaan akses; koneksi Google/AI yang benar-benar diperiksa. Paket aktif + koneksi belum terhubung adalah status sah. Gangguan koneksi tidak boleh diberi label expired/tidak membayar. API GoAkal atau Midtrans tidak menyatukan cookie/browser dan tidak menghapus kewajiban pemrosesan data.

## 7. Penjelasan privasi dan penghapusan

Sebelum halaman Google tampil, jelaskan tujuan dan origin: pengguna sedang masuk di Google; pertanyaan alamat/telepon/email pemulihan pada halaman Google berasal dari Google. Lewati hanya bila Google menawarkan Lewati; jangan menjanjikan dapat mengabaikan pemeriksaan wajib.

Sediakan tindakan terpisah: Lanjut ke beranda; Hubungkan Google; Keluar; Bantuan permintaan keamanan Google; dan Hapus akun OpenTurath. Dialog hapus akun menjelaskan bahwa tindakan tidak menghapus akun Google, tidak melewati pemeriksaan keamanan, berdampak pada data/akses aplikasi, dan bukan proses refund. Jangan menghalangi hak penghapusan atau otomatis menghidupkan kembali data yang sengaja dihapus.

Gunakan klaim privasi faktual: data profil/transaksi tetap diproses sesuai fitur, password/OTP tidak diminta untuk dikirim kepada tim. Dalam jalur embedded yang dapat menjalankan JavaScript, jangan membuat klaim teknis bahwa aplikasi secara arsitektur mustahil melihat halaman. Klaim pemisahan kredensial yang paling kuat berasal dari browser autentikasi yang tidak dikendalikan aplikasi dan pembatasan akses yang benar.

## 8. Tahap pekerjaan dan hasil yang harus tersedia

| Tahap | Pekerjaan | Bukti sebelum lanjut |
|---|---|---|
| 0 — klasifikasi | Rekam galat aktual tanpa rahasia: penolakan browser Google, recovery opsional/wajib, OAuth G10, mismatch akun, entitlement, provisioning, jaringan/TLS, crash, DOM belum siap | Satu kategori tidak lagi disamakan dengan kategori lain; tidak menganggap semua peringatan keamanan berarti kebocoran. |
| 1 — hardening terisolasi | Pagar origin, bridge/frame, batas payload, izin minimum, guard script; audit iOS Foundation replay dan alignment logout/delete | Tes negatif host lookalike/redirect/frame/scheme; sesi pelanggan tidak dibersihkan. Tidak mengubah polling/tata letak room. |
| 2 — perjalanan dan profil | Beranda setelah login aplikasi, koneksi AI saat dibutuhkan, profil terpisah, bantuan privasi, dialog hapus akun | Pengguna mengerti asal formulir Google; status unknown/mismatch tidak diubah menjadi expired; VIP/per-modul tetap benar. |
| 3 — prototipe jalur browser | Android Custom Tabs sepanjang AI; Apple/Windows browser didukung; alur identitas aplikasi di browser jika diperlukan | Uji satu akun dan multi-akun; login dan chat benar-benar di konteks yang sama; app return tidak mengklaim WebView sudah login. |
| 4 — keputusan jalur default | Bandingkan jalur embedded yang diperketat dengan browser-owned, khususnya perangkat yang bermasalah | Pemilik melihat konsekuensi UI: Custom Tabs/browser tidak dapat mempertahankan injeksi CSS/DOM dan toolbar Flutter pada halaman provider. Pilih default tanpa menganggap engine baru menyelesaikan kebijakan Google. |
| 5 — migrasi dan rilis terbatas | Flag rute yang dapat dibalik, paket lokal, pengujian perangkat, pengguna uji yang setuju | Tidak ada perubahan hak, gate VIP, payment writer, cookie impor, publikasi notebook, atau broadcast otomatis. Rollback tidak menghapus profil sesi. |

Setiap perubahan kode/config/test langsung di-checkpoint sesuai AGENTS; jangan mencampur migrasi billing dengan keamanan sesi. Pengujian penghapusan/transaksi/refund dilakukan pada akun/data uji, bukan akun pelanggan/VIP.

## 9. Matriks penerimaan

- Platform: Android termasuk POCO yang sebelumnya bermasalah, Android lain dengan runtime berbeda, macOS, Windows, dan iOS bila tetap ditawarkan. Hasil satu platform tidak membuktikan platform lain.
- Akun: instalasi baru; akun sudah login; dua akun Google; akun aplikasi A dan AI B; pembatalan pemilih akun; passkey; 2FA; recovery opsional dan wajib; akun Workspace/terkelola bila didukung.
- Persistensi: tutup/buka tab; restart aplikasi; kill proses/low memory; reboot perangkat; pembaruan aplikasi/runtime; pembersihan oleh pengguna; sesi kedaluwarsa/dicabut. Tidak ada cookie yang diubah agar expired tampak hidup.
- Akses: VIP permanen; paket aktif/expired; dua modul dengan expiry berbeda; pembayaran lunas tetapi undangan pending; belum berlangganan; hak historis; network/backend unknown. Tidak ada akses dibuka dari cache/profile saja.
- Keamanan: host mirip Google; redirect HTTPS ke HTTP; popup tak tepercaya; skema aktif; iframe mencoba bridge; payload salah/terlalu besar; callback tab lama setelah akun berganti; TLS invalid; izin kamera/lokasi tak diminta; diagnostik bebas rahasia.
- UX: domain/origin login terbaca; beranda tetap dapat dibuka sesuai sesi aplikasi; tidak ada relogin loop; bantuan tak menyuruh hapus akun; logout/delete berbeda; pembatalan tidak menghapus data; kembali dari browser tidak dianggap bukti kesiapan internal.
- Bukti perjalanan: akun uji dapat membuka notebook yang memang diizinkan, composer nyata siap, satu pertanyaan mendapat jawaban lengkap, lalu sesi tetap benar setelah restart dan pembukaan tab lain. Cookie ada atau HTTP 200 tidak cukup.
- Invarian room tetap: ≥4 sampel kesiapan, elapsed ≥3000ms, jeda 250ms; error mengganti seluruh viewport; minimal 5 tab macOS tanpa eviction senyap; CSS Syafi'i dan clean() tidak dirusak. Petunjuk skill lama tentang tiga tab desktop ditimpa aturan owner yang lebih baru.
- Go/no-go: tidak ada temuan P0 terbuka; semua perjalanan kritis lulus pada platform yang diklaim didukung; galat provider punya pemulihan yang aman; paket/signature/runtime benar. Pengulangan uji memberi bukti terbatas, tidak jaminan nol galat selamanya. Jika blocked browser masih terjadi, rilis tidak boleh mengklaim embedded Google universal.

## 10. Arah jangka panjang

Jika target mutlak adalah antarmuka chat native yang sepenuhnya dikendalikan OpenTurath tanpa login situs Google, arah jangka panjang ialah layanan chat berbasis API yang didukung dan sumber yang penggunaannya diizinkan. Ini proyek berbeda, memerlukan evaluasi biaya, kualitas, sumber, dan hak data; bukan membungkus endpoint internal NotebookLM atau memakai cookie pemilik di server.

Saat audit ini, Google sudah mendokumentasikan Gemini Notebook API dalam public preview untuk akun personal. Referensi REST yang diperiksa memuat pengelolaan notebook dan sumber, belum endpoint chat. Jadi tidak tepat mengatakan tidak ada API resmi sama sekali, tetapi belum ada dasar menganggap API itu pengganti chat embedded yang siap dipakai saat ini.

## 11. Sumber resmi dan batas verifikasi

- Google OAuth embedded-agent/origin policy: https://developers.google.com/identity/protocols/oauth2/policies
- Android WebView dan Custom Tabs: https://developer.android.com/develop/ui/views/layout/webapps/in-app-browsing-embedded-web
- Batas keamanan Custom Tabs: https://chromium.googlesource.com/chromium/src/+/main/docs/security/custom-tabs-faq.md
- Apple persistent store: https://developer.apple.com/documentation/webkit/wkwebsitedatastore/default()
- Apple auth session: https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession
- Apple/MSAL browser-cookie behavior: https://learn.microsoft.com/en-us/entra/msal/objc/customize-webviews
- Microsoft WebView2 UDF: https://learn.microsoft.com/en-us/microsoft-edge/webview2/concepts/user-data-folder
- ChatGPT built-in browser: https://help.openai.com/en/articles/20001277-using-the-built-in-browser-in-the-chatgpt-desktop-app
- Claude built-in browser: https://support.claude.com/en/articles/16607400-use-the-built-in-browser-in-claude-cowork
- Google Notebook API: https://developers.google.com/notebook/docs
- REST API: https://developers.google.cn/notebook/reference/rest

Audit menggunakan sumber lokal, kode plugin terpasang, riwayat Git, dan dokumentasi resmi. Tidak dilakukan uji login perangkat baru, ekstraksi cookie browser, transaksi, penghapusan akun, deployment, atau rilis pada pekerjaan perencanaan ini. Tidak ada bukti baru insiden telah dieksploitasi. Dokumen internal lama tentang DBSC tidak dipakai sebagai diagnosis server Google yang telah terbukti.
