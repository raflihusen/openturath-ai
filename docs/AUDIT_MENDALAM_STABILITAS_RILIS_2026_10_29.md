# Audit Mendalam Stabilitas Rilis OpenTurath AI

Tanggal: 29 Oktober 2026, zona waktu Asia/Aden (UTC+3).
Sumber lokal yang diaudit: cabang v9-2-integrasi, checkpoint awal 112deecf.
Rilis yang tercatat di produksi saat pemeriksaan: 1.0.85, build 86.

## 1. Kesimpulan untuk pemilik

Keluhan aplikasi tidak terbuka, login berulang lalu sesi habis, pelanggan berbayar tidak dapat membuka AI, dan trial ditolak memiliki beberapa penyebab yang berbeda. Audit menemukan cacat nyata pada paket distribusi, pemulihan autentikasi, pengelolaan cookie, identitas perangkat, dan konsistensi status pekerjaan akses.

**Perbaikan pesan galat dan penambahan alarm yang sudah dilakukan belum menutup akar masalah tersebut.** Ada kondisi yang membuat aplikasi menyatakan pengguna sudah masuk ketika Firebase belum mempunyai sesi. Ada kondisi yang menyatakan akses siap hanya karena hitungan 30 detik habis. Ada pekerjaan di server yang terus dilewati tetapi tidak membuat pemantau menyatakan bermasalah.

Di sisi lain, bukti produksi tidak mendukung kesimpulan bahwa semua pembayaran atau seluruh worker sedang gagal. Enam pembayaran settlement yang diperiksa langsung ke Midtrans telah tercatat paid. Penugasan yang diperlukan untuk tujuh transaksi paid di ledger lengkap pada saat snapshot. Seluruh 346 notebook dalam katalog routing masih mempunyai pengamatan kesehatan yang berlaku. Keberhasilan catatan server ini belum membuktikan pengguna dapat membuka AI dengan sesi Google yang benar.

Solusi yang disarankan adalah memperbaiki rantai yang sudah ada secara bertahap, dimulai dari distribusi dan sesi, lalu menyatukan definisi akses siap serta pemulihan pekerjaan. Menambah penulis otomatis baru atau mengganti sistem pembayaran sebelum celah ini ditutup akan menambah variabel yang harus didiagnosis.

### Prioritas keputusan

| Urutan | Pekerjaan | Hasil yang harus dibuktikan |
|---|---|---|
| Mendesak sebelum 30 Oktober | Migrasi runtime Functions Node 20 ke Node 22 melalui perubahan teruji | Backend dapat dibangun dan diterapkan pada runtime yang masih didukung |
| 1 | Benahi paket Windows dan tanda tangan/notarisasi macOS | Pengguna pada perangkat bersih dapat memasang dan membuka aplikasi |
| 2 | Pisahkan cache profil, sesi Firebase, dan sesi AI; hentikan replay cookie buatan dan penghapusan cookie di luar Log Out | Tutup/buka aplikasi dan pergantian tab tidak merusak sesi; gangguan sesi tidak menghilangkan tampilan hak berbayar |
| 3 | Ganti identitas perangkat trial yang bertabrakan; tangani penolakan lama secara terarah | Dua perangkat bermodel dan berfirmware sama tidak saling memblokir |
| 4 | Satukan pemeriksaan readiness, pemantau pembayaran, dan UI | Akses hanya disebut siap ketika seluruh asisten yang dibeli terverifikasi |
| 5 | Pulihkan pekerjaan/assignment tertinggal setelah pemeriksaan bukti hak | Tidak ada pekerjaan nonterminal yang hilang dari pemantauan atau assignment provisioning tanpa job/review |
| 6 | Benahi lease, health check pemasang, dan pemulihan sesi provider | Failover dan pemasangan worker tidak memberi status sehat palsu |

Ini adalah hasil audit dan rancangan perbaikan. Audit ini tidak mengubah kode aplikasi, akses pelanggan, konfigurasi produksi, layanan VPS, atau rilis publik.

## 2. Cara membaca bukti dan batas audit

Tiga tingkat bukti dipisahkan:

- **Produksi:** pembacaan langsung metadata layanan, Firestore, log, status transaksi gateway, dan pemeriksaan artefak yang hash-nya cocok dengan hash yang diumumkan di produksi.
- **Kode/reproduksi lokal:** jalur kegagalan dibuktikan dari implementasi atau simulasi terhadap fungsi sumber, tanpa memanggil operasi mutasi provider.
- **Belum terbukti pada perangkat:** hubungan cacat tersebut dengan kejadian tertentu di Windows/Android pengguna masih memerlukan log dan uji perangkat nyata.

Dokumen LAPORAN_MASALAH_UNTUK_AUDIT_AI_BARU.md dipakai sebagai bahan yang diuji ulang. Klaim dan instruksi di dalamnya tidak diperlakukan sebagai fakta baru atau otorisasi untuk melakukan perubahan.

Pemeriksaan meliputi startup, paket Windows/macOS/Android, login OAuth/Firebase, sesi WebView, voucher, checkout, hak akses per modul, worker, pemantauan, lease, dan metadata rilis. Situs Manuskrip tidak menjadi sasaran karena tidak menjelaskan kegagalan aplikasi berlangganan ini.

Tidak ada pembelian baru, sharing/revocation NotebookLM, perubahan cookie pengguna, deploy, kompilasi rilis, atau broadcast pembaruan. Tidak ada akun VIP yang dinilai sebagai kesalahan. Angka snapshot diambil melalui pembacaan terpisah pada 29 Oktober; angka dapat berubah dan bukan satu transaksi database atomik. Identitas pelanggan, cookie, kunci pembayaran, dan token tidak disalin ke laporan ini.

## 3. Keadaan produksi yang diverifikasi ulang

| Komponen | Hasil pemeriksaan |
|---|---|
| Runtime Functions | 20 fungsi yang terdaftar memakai nodejs20 dan berstatus ACTIVE |
| Writer akses | vps-v2 |
| Kebijakan pencabutan | revocation_pause.expiry=true; refund=false; account_deleted=false. Nilai umum revocations_paused=false tidak berarti pencabutan expiry aktif |
| Worker heartbeat | Mode active, error kosong, authentication_error=false, pengamatan provider terbaru tersedia |
| Pemantau | monitor_health menyatakan healthy; pending_jobs pada heartbeat berjumlah 5 |
| Lease baru | Dokumen access_control/writer_lease tidak ditemukan; belum ada bukti mekanisme lease baru aktif di produksi |
| App Check | Dokumen access_control/security tidak ditemukan; jangan mengaktifkan enforcement mendadak tanpa uji kompatibilitas klien |
| Assignment | 1.375 total: 1.294 ready, 29 provisioning, 45 adopted, 5 revoked, 2 transferred |
| Job | 1.222 total: 1.178 completed, 34 superseded, 5 queued, 5 review_required |
| Outbox | 530 total: 216 v2_handed_off, 236 v2_review, 78 completed |
| Notebook | 632 record; 346 ada di katalog routing, semuanya fresh; 286 di luar katalog, semuanya stale |
| Telemetri auth baru | auth_failure_stats berisi 0 dokumen saat diperiksa |
| Alarm lunas tanpa akses | paid_access_alerts berisi 0 dokumen saat diperiksa; ini tidak membuktikan tidak pernah ada kegagalan |
| OTA | Android, Windows, dan macOS tercatat build 86. Klaim lama bahwa Windows belum punya entri dan macOS masih build 68 sudah tidak sesuai snapshot |

### Pembayaran: pemeriksaan gateway langsung

Sebanyak **93 transaksi yang diberi label gateway=midtrans** diperiksa melalui GET status untuk invoice yang sudah ada:

| Hasil gateway | Jumlah | Pencocokan ledger |
|---|---:|---|
| settlement | 6 | Semua 6 berstatus paid |
| expire | 20 | Semua 20 berstatus expire |
| status_code 404 / resource tidak ditemukan | 67 | 53 abandoned, 13 pending, 1 paid |

Satu paid yang tidak ditemukan di Midtrans memiliki catatan internal bahwa pembayaran diverifikasi manual melalui transfer BSI. Bukti bank aslinya tidak diperiksa dalam audit ini. Karena itu transaksi tersebut tidak boleh dinyatakan tidak sah, atau dicabut haknya, hanya berdasarkan 404 gateway. Sumber dan bukti pembayaran manual perlu disimpan dalam format terstruktur.

Respons 404 tidak membuktikan pengguna gagal membuka halaman pembayaran. Ia hanya menunjukkan resource invoice tidak ditemukan oleh permintaan status saat audit. Penyebab berhenti bayar memerlukan kejadian klien. Arti status dan zona waktu gateway diperiksa terhadap [dokumentasi status Midtrans](https://docs.midtrans.com/docs/get-status-api-requests).

Tujuh transaksi paid di ledger dimiliki **enam UID unik**. Dua transaksi bernominal Rp1.000, sehingga jangan menyebut semuanya pembelian retail. Cakupan yang dibutuhkan adalah 19 pemeriksaan transaksi/asisten: tiga transaksi Tahawwulat × lima asisten, ditambah empat transaksi Syafi‘i × satu. **19/19 mempunyai assignment ready dengan verified_ms**, tanpa ketidaksesuaian email assignment terhadap email pembayaran pada cakupan tersebut.

Pada enam settlement, selisih settlement_time gateway ke paid_at ledger sekitar 4–5 detik setelah zona waktu gateway GMT+7 diselaraskan. Ini mengukur pencatatan pembayaran, **bukan waktu pertama pengguna dapat memakai AI**. Selisih created_at ke paid_at yang paling lama sekitar 15,964 jam tidak boleh dipakai sebagai bukti keterlambatan pemberian akses 16 jam. Diperlukan settlement_at, first_access_verified_at, dan kejadian pembukaan AI pertama.

## 4. Temuan distribusi dan pembukaan aplikasi

### A01 — P1: paket Windows aktual tidak membawa prasyarat native

**Bukti.** ZIP Windows yang tersedia berisi 65 entri. Executable utama dan plugin WebView mengimpor MSVCP140.dll, VCRUNTIME140.dll, dan VCRUNTIME140_1.dll, tetapi ZIP tidak mempunyai DLL runtime tersebut, pemasang VC++, folder prerequisites, atau README. Hash ZIP lokal sesuai hash yang diumumkan di manifest produksi.

[installer_core.iss:37](/Users/apple/Downloads/ramadhan/openturath_ai/windows/installer_core.iss:37) hanya menyalin exe, DLL, dan data. Tidak ada langkah memasang atau memeriksa VC++ Redistributable/WebView2. Sementara [package_windows.ps1:6](/Users/apple/Downloads/ramadhan/openturath_ai/tool/package_windows.ps1:6) sudah mempunyai jalur penyediaan prasyarat; paket aktual tidak mengikuti keluaran jalur itu.

**Akibat.** Pada Windows yang belum mempunyai runtime Microsoft, proses dapat gagal sebelum Dart berjalan. Log Flutter dan endpoint pelaporan kegagalan login tidak dapat menangkap kegagalan sebelum proses ini. Gap dependensi terbukti dari artefak; belum diuji pada VM Windows bersih.

**Perbaikan.** Gunakan satu jalur packaging resmi untuk ZIP dan Setup. Bootstrapper harus memeriksa dan memasang prasyarat yang sesuai, memeriksa exit code termasuk kebutuhan restart, lalu membuka aplikasi setelah berhasil. Menyertakan pemasang sebagai berkas tanpa menjalankannya belum cukup untuk jalur Setup. Gunakan distribusi resmi sesuai [panduan deployment runtime Microsoft](https://learn.microsoft.com/cpp/windows/redistributing-visual-cpp-files).

**Kriteria lulus.** Windows bersih tanpa Visual Studio/Flutter dan tanpa VC++ runtime dapat memasang, membuka, login, serta membuka AI. Uji juga WebView2 belum ada, koneksi terputus saat memasang prasyarat, serta update dari instalasi lama.

### A02 — P1: DMG macOS yang diumumkan tidak lolos Gatekeeper

**Bukti artefak.** DMG lokal dengan hash sesuai hash produksi dibuka read-only. Aplikasi di dalamnya mempunyai versi 1.0.85 build 86, Signature=adhoc, TeamIdentifier=not set. Pemeriksaan spctl mengembalikan exit 3 dengan hasil rejected. Validasi stapler mengembalikan exit 65 karena tidak ada tiket yang ditempelkan.

[package_macos.sh:7](/Users/apple/Downloads/ramadhan/openturath_ai/tool/package_macos.sh:7) mengizinkan paket lokal ad-hoc. Komentar pada baris 21 menyatakan distribusi publik perlu Developer ID/notarisasi, tetapi jalur packaging tersebut tidak membuktikan syarat itu dipenuhi.

**Akibat.** Hasil build dan DMG yang berhasil dibuat belum membuktikan pengguna dapat membukanya dengan pengaturan keamanan macOS bawaan. Penolakan pada mesin audit sudah terbukti; pengalaman tepat pada setiap Mac pengguna belum direproduksi.

**Perbaikan.** Pisahkan keluaran uji lokal dari keluaran distribusi. Jalur publik harus menandatangani aplikasi dengan identitas distribusi yang stabil, melakukan notarisasi dan stapling, serta menolak publikasi jika pemeriksaan Gatekeeper gagal. Pertahankan identitas aplikasi dan kelompok Keychain dengan migrasi terencana agar pembaruan tidak merusak sesi yang tersimpan. [Panduan distribusi Apple](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution) menjadi dasar proses tersebut.

**Kriteria lulus.** Pasang dari unduhan browser pada Mac bersih dengan Gatekeeper aktif; buka, login, tutup, buka ulang, dan update dari versi sebelumnya. Jangan menjadikan penonaktifan Gatekeeper sebagai langkah instalasi normal.

### A03 — P1: startup menunggu beberapa layanan sebelum frame pertama

**Bukti kode.** [main.dart:60](/Users/apple/Downloads/ramadhan/openturath_ai/lib/main.dart:60) menunggu persiapan WebView sebelum runApp. Konfigurasi/preferences dan Firebase initialization pada baris 64–82 tidak memiliki deadline menyeluruh. Persiapan WebView sudah membatasi beberapa operasi, tetapi pencarian/pembuatan direktori profil belum dibatasi. Jendela Windows baru diperlihatkan sesudah frame pertama, melalui [flutter_window.cpp:32](/Users/apple/Downloads/ramadhan/openturath_ai/windows/runner/flutter_window.cpp:32).

**Akibat.** Operasi platform yang menggantung dapat membuat proses hidup tanpa jendela atau berhenti pada splash. Ini risiko kode yang belum dipasangkan dengan log perangkat pengguna.

**Perbaikan.** Tampilkan layar bootstrap lebih awal dari main.dart. Jalankan tahap konfigurasi, Firebase, dan kesiapan runtime dengan deadline serta tombol coba ulang per tahap. Hindari memblokir profil/offline dashboard pada kesiapan mesin AI. Perubahan harus menjaga seluruh siklus hidup dan polling WebView yang dilindungi AGENTS.md.

**Kriteria lulus.** Dengan penyimpanan lambat, direktori tidak dapat ditulis, runtime WebView tidak tersedia, Firebase timeout, dan internet putus, pengguna tetap melihat penjelasan serta langkah pemulihan.

## 5. Temuan login dan sesi

### A04 — P1: cache profil dapat dianggap sebagai autentikasi yang masih berlaku

**Bukti kode.** [auth_service.dart:131](/Users/apple/Downloads/ramadhan/openturath_ai/lib/services/auth_service.dart:131) mengembalikan profil dari current_user_uid tersimpan meskipun Firebase currentUser tetap null. [splash_screen.dart:67](/Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/splash_screen.dart:67) kemudian mengarahkan pengguna ke dashboard jika restoredUser tidak null. Sebaliknya [callable_gateway.dart:25](/Users/apple/Downloads/ramadhan/openturath_ai/lib/services/callable_gateway.dart:25) membutuhkan token Firebase; token kosong menghasilkan unauthenticated pada baris 82.

**Akibat.** Pengguna melihat dirinya sudah masuk, lalu menerima pesan sesi habis ketika membuka AI atau membayar. Pada Windows tidak ada fallback silent Google sign-in native yang dipakai platform mobile/macOS. Jalur kontradiksi ini terbukti; hilangnya sesi Firebase pada perangkat Windows tertentu masih perlu direkam.

**Perbaikan.** Bedakan status profil tersimpan, sesi Firebase yang sah, dan sesi AI. Profil cache tetap boleh ditampilkan untuk kebutuhan offline, tetapi tidak boleh dijadikan bukti autentikasi. Operasi online melakukan pemulihan sesi atau meminta masuk kembali secara jelas. Hak berbayar tetap ditampilkan sebagai hak tersimpan sambil diverifikasi ulang, tanpa menyimpulkan paket pengguna hilang.

**Kriteria lulus.** Cache ada + Firebase null tidak mengaktifkan operasi berbayar seolah sudah terautentikasi. Setelah masuk kembali dengan akun yang benar, hak yang sama tampil tanpa pembelian ulang.

### A05 — P1: persistensi cookie masih memalsukan expiry dan me-replay snapshot autentikasi

**Bukti kode.** [persistent_google_session.dart:84](/Users/apple/Downloads/ramadhan/openturath_ai/lib/services/persistent_google_session.dart:84) menetapkan expiry 180 hari. Pengecualian baris 105–112 hanya berlaku untuk nama berakhiran TS/CC atau cookie tanpa expiry. SID, HSID, dan beberapa cookie __Secure masih dapat disimpan dengan masa berlaku yang diperpanjang. Restore pada baris 203–214 menulis kembali nilai tersebut melalui setCookie pada baris 54.

Pengecekan sesi hidup hanya memeriksa SID/1PSID pada satu origin. Cookie yang ada belum membuktikan identitas akun atau sesi masih diterima server. Salinan cookie disimpan dalam SharedPreferences menggunakan Base64; Base64 tidak memberikan enkripsi.

**Akibat.** Jalur replay token lama dan atribut buatan terbukti, berlaku juga pada Windows, dan bertentangan dengan aturan proyek. Hubungan khusus dengan pencabutan sesi oleh DBSC pada kejadian pengguna **belum terbukti**.

**Perbaikan.** Andalkan persistensi profil cookie bawaan WebKit/WebView2. Hentikan perpanjangan expiry dan injeksi ulang cookie autentikasi Google. Migrasikan penghentian vault lokal tanpa menghapus cookie OS yang sedang aktif. Gunakan pemeriksaan sesi/identitas yang tidak mengubah token. Jangan mengubah polling kesiapan, tampilan error, atau siklus hidup di dua berkas WebView yang dilindungi.

**Kriteria lulus.** Tidak ada pemanggilan setCookie untuk memulihkan/memanjangkan token Google. Login, tutup/buka, restart OS, dan minimal lima tab tetap diuji. Sesi kadaluwarsa menghasilkan reautentikasi yang jelas, bukan replay snapshot.

### A06 — P1: sesi Google dihapus di luar tombol Log Out

**Bukti kode.** Tombol “Masuk akun yang sesuai” pada [google_session_auth_screen.dart:435](/Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/google_session_auth_screen.dart:435) memanggil deleteAllCookies. [auth_service.dart:425](/Users/apple/Downloads/ramadhan/openturath_ai/lib/services/auth_service.dart:425) memanggil clearOnSignOut saat owner sesi tersimpan berbeda, yang berujung clearSession.

**Akibat.** Semua tab yang berbagi profil cookie kehilangan sesi ketika jalur mismatch dijalankan, meskipun pengguna tidak menekan Log Out di Pengaturan. Ini penyebab sesi terhapus yang konkret dari kode; tidak perlu mengandaikan kebijakan Google berubah.

**Perbaikan.** Arahkan pemilihan akun melalui alur pemilih akun Google. Batasi pembersihan global pada Log Out yang eksplisit sesuai aturan proyek. Jangan menyelesaikan mismatch identitas dengan menghapus seluruh profil cookie.

**Kriteria lulus.** Pengujian tombol mismatch dan pergantian akun tidak memanggil deleteAllCookies/clearSession. Pengujian Log Out tetap membuktikan pembersihan yang dimaksud pengguna.

### A07 — P1/P2: watchdog sesi masih mempunyai await yang dapat menggantung

**Bukti kode.** [google_session_auth_screen.dart:230](/Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/google_session_auth_screen.dart:230) memasang mutex sebelum controller.getUrl tanpa timeout pada baris 234. Watchdog tidak memulai pemeriksaan baru ketika mutex masih aktif. Pada baris 627 sesi sudah ditandai siap sebelum penantian persistensi cookie pada baris 640 selesai. Silent sign-in native di [auth_service.dart:118](/Users/apple/Downloads/ramadhan/openturath_ai/lib/services/auth_service.dart:118) juga tidak memiliki timeout.

**Perbaikan.** Beri deadline pada setiap panggilan platform/penyimpanan; lepaskan flag dalam finally; bedakan memverifikasi, siap, dan perlu pemulihan. Jangan menghentikan watchdog hanya karena proses menyimpan belum selesai. Penghentian vault cookie pada A05 mengurangi salah satu sumber penantian.

**Kriteria lulus.** Plugin yang mengembalikan Future yang tidak pernah selesai tetap berujung layar pemulihan, bukan loader permanen.

### A08 — P2: pemulihan token dan identitas sesi belum konsisten

Tiga celah yang perlu ditutup bersama:

1. Jalur HTTP Windows di [callable_gateway.dart:19](/Users/apple/Downloads/ramadhan/openturath_ai/lib/services/callable_gateway.dart:19) tidak memperoleh force-refresh/retry unauthenticated yang tersedia pada jalur native baris 40–54. getIdToken normal memang dikelola SDK; ini bukan bukti bahwa setiap token yang menua pasti gagal. Tambahkan refresh terarah untuk penolakan autentikasi. Retry mutasi tetap memerlukan idempotency.
2. Ketika email DOM tidak terbaca, konfirmasi manual dapat memanggil _onSessionAuthenticated, lalu menyimpan email Firebase yang diharapkan sebagai owner sesi. Itu bukan email Google yang benar-benar teramati. Bedakan “pengguna mengonfirmasi” dari “identitas terverifikasi”; gunakan perbedaan ini untuk diagnosis permission.
3. Timer shutdown pada [desktop_auth_gateway.dart:228](/Users/apple/Downloads/ramadhan/openturath_ai/lib/services/desktop_auth_gateway.dart:228) menutup _activeServer global sesudah 500 ms, tanpa mengikat server sesi asal. Retry baru yang dimulai dalam rentang itu dapat terkena timer lama. Uji concurrent awal mengalami connection reset, sedangkan rerun sequential lulus; belum terbukti sebagai insiden pengguna. Ikat penutupan ke instance server asal dan batalkan timer lama saat memulai sesi baru.

### A09 — Diagnosis “audience Desktop salah” belum terbukti

Provider Google produksi aktif dan memakai client Web. Namun absennya whitelistedAudiences dari respons endpoint REST v2 bukan bukti whitelist kosong: field itu tidak ada dalam schema v2 yang diperiksa. [Schema API v1](https://docs.cloud.google.com/identity-platform/docs/reference/rest/v1/TopLevel/getProjects) mempunyai field tersebut; percobaan pembacaan v1 pada sesi audit tidak menghasilkan konfigurasi IdP privat yang cukup untuk memutuskan hipotesis ini.

[Dokumentasi Google](https://docs.cloud.google.com/identity-platform/docs/web/google) menjelaskan penambahan external client IDs, tetapi tidak membuktikan bahwa client Desktop proyek ini ditolak. Pembacaan daftar pembatasan API key juga ditolak dengan 403 oleh izin akun audit.

**Langkah pembuktian.** Di Windows nyata, rekam tahap OAuth callback, token exchange, Firebase credential exchange, dan profile resolve; simpan kode galat serta versi, tanpa token atau cookie. Baru ubah konfigurasi audience bila penolakan tersebut terbukti. Jangan mengganti client/config secara spekulatif hanya karena dua client ID berbeda.

## 6. Temuan trial, pembayaran, dan readiness

### A10 — P1: identitas trial Android/web bertabrakan antar pengguna sah

**Bukti kode dan dependensi.** [device_service.dart:94](/Users/apple/Downloads/ramadhan/openturath_ai/lib/services/device_service.dart:94) memakai androidInfo.id dan memberi komentar ANDROID_ID. Implementasi device_info_plus 12.4.0 ternyata mengisi field tersebut dari Android Build.ID, yaitu identitas build OS. Hash pada baris 68–72 hanya menambahkan merek dan model.

Dua HP dengan model dan firmware sama menghasilkan identitas yang sama. Web menggunakan user agent, vendor, dan nama browser pada baris 79–83, yang juga bukan identitas instalasi unik. Server menolak identitas yang sama dalam keluarga trial melalui [index.ts:1971](/Users/apple/Downloads/ramadhan/openturath_ai/functions/src/index.ts:1971) dan baris 1996.

**Reproduksi.** Dua akun baru memakai fingerprint sintetis identik. Akun pertama sukses; akun kedua ditolak already-exists/reason=device_used, walaupun tidak mempunyai redemption sendiri. Mengganti pesan penolakan sebelumnya tidak mengubah akar ini.

**Perbaikan.** Gunakan identitas instalasi acak tersimpan yang sudah tersedia di _persistentId. Pertahankan keunikan klaim berdasarkan email Google terverifikasi. Penanda perangkat lama yang mudah bertabrakan perlu diperlakukan sebagai sinyal peninjauan, bukan bukti tunggal penyalahgunaan. Identitas instalasi dapat berubah setelah reinstall; kebijakan anti-abuse harus menerima keterbatasan itu dan tidak bergantung pada satu fingerprint.

**Pemulihan terdampak.** Cocokkan penolakan dengan klaim email milik pengguna. Tandai fingerprint lama yang ambigu, lalu izinkan klaim sah secara terarah sesuai kebijakan. Jangan mereset riwayat atau menambah durasi trial semua akun.

**Kriteria lulus.** Dua perangkat identik dan dua browser dengan user agent sama tidak saling memblokir. Akun yang benar-benar sudah mengklaim tetap tidak mendapatkan durasi tambahan dari retry.

### A11 — P1: hitungan 30 detik diperlakukan sebagai akses selesai

**Bukti kode.** [access_prepare_gate.dart:65](/Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/access_prepare_gate.dart:65) menurunkan hitungan meskipun readiness false atau error. Builder pada baris 174 menerima done ketika _left==0. [payment_success_dialog.dart:82](/Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/payment_success_dialog.dart:82) lalu mengatakan akses sudah siap. Alur voucher memakai gate yang sama.

**Perbaikan.** Pisahkan pembayaran tercatat dari penyediaan akses selesai. Timeout berarti akses masih diproses, dengan pilihan kembali ke dashboard dan pemeriksaan lanjutan. Tombol pembukaan AI dan kalimat siap bergantung pada readiness server, bukan hitungan.

**Kriteria lulus.** Server selalu false, selalu timeout, dan paket parsial tidak pernah menghasilkan pernyataan “akses sudah siap”; paket lengkap terverifikasi boleh melanjutkan.

### A12 — P1: pemantau pembayar memakai definisi siap yang berbeda

**Bukti kode.** [index.ts:2964](/Users/apple/Downloads/ramadhan/openturath_ai/functions/src/index.ts:2964) cukup menemukan satu assignment ready dengan scope cocok, tanpa verified_ms. Sebaliknya ledgerScopesReady pada baris 2283 memerlukan seluruh entity terverifikasi.

**Reproduksi terhadap fungsi sumber:**

| Kondisi | Readiness | Pemantau sekarang |
|---|---|---|
| Tahawwulat 1 dari 5 asisten siap | Belum siap | Tidak memberi alarm |
| Assignment ready tanpa verified_ms | Belum siap | Tidak memberi alarm |
| All-access seluruh entity terverifikasi | Siap | Memberi alarm palsu karena mencari scope all_access literal |

**Perbaikan.** Satu evaluator kesiapan dipakai oleh getAgentUrl/readiness, pemantau, dan operasi pemulihan, dengan entity yang hilang serta alasan terstruktur. Untuk status ditampilkan kepada pengguna, pisahkan hak aktif, sharing terverifikasi, dan sesi AI yang benar. Jangan menganggap satu assignment mewakili seluruh paket.

**Kriteria lulus.** Ketiga skenario di tabel menjadi tes regresi wajib; evaluator memberikan hasil yang sama di endpoint dan pemantau.

### A13 — P1/P2: alarm bisa hilang permanen dan pembayar lama keluar dari pengawasan

**Bukti.** [index.ts:2970](/Users/apple/Downloads/ramadhan/openturath_ai/functions/src/index.ts:2970) menulis flag sebelum mengetahui pengiriman Telegram berhasil. Iterasi berikutnya melewati transaksi yang sudah mempunyai flag. Reproduksi: pengiriman gagal, flag tetap ada, pemanggilan berikutnya membuat nol upaya pengiriman.

Query pada baris 2959 hanya mengawasi status paid dalam tiga jam terakhir. Gangguan yang berlangsung lama dapat membuat pelanggan yang belum tertangani keluar dari jendela pengawasan.

Selain itu ada 165 baris legacy success/SUCCESS yang tidak termasuk monitor ini; 159 tidak mempunyai UID dan sebagian tidak mempunyai cakupan/waktu pembayaran yang seragam. Itu bukan bukti 165 pelanggan aktif terkunci, dan memperluas query saja tidak menyelesaikan pemetaan identitas.

**Perbaikan.** Simpan insiden open/resolved yang bertahan hingga pulih, bukan sekadar flag pernah diproses. Pisahkan last_attempt, delivery_succeeded_at, next_retry, dan access_resolved_at. Retry pemberitahuan dengan backoff, eskalasi keterlambatan, serta awasi seluruh insiden terbuka. Legacy membutuhkan pemetaan bukti pembayaran, bonus, transfer, VIP, dan cakupan modul sebelum masuk pemulihan.

### A14 — P2: checkout masih dapat berhenti tanpa penjelasan

**Bukti kode.** Perbaikan allowlist utama belum mencakup semua jalur. [payment_checkout_sheet.dart:667](/Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/payment_checkout_sheet.dart:667) hanya mencetak debug untuk popup yang ditolak. Deep link pada baris 710 tidak menangani launchUrl=false; exception juga hanya dicetak.

Pemeriksaan manual pada baris 250 tetap terkena batas _pollAttempts>60, meskipun force=true. Setelah polling habis, tombol cek manual dapat berhenti sebelum inquiry dikirim.

**Perbaikan.** Tangani popup, kegagalan muat, deep link false/exception, dan kembali dari aplikasi pembayaran. Fallback menggunakan sesi checkout HTTPS yang dipercaya; jangan membuka URL asing secara otomatis. Batas polling otomatis dipisahkan dari inquiry manual yang diberi throttling. Jangan menampilkan bahwa belum bayar ketika yang gagal adalah pemeriksaan status.

**Kriteria lulus.** Uji dompet tidak terpasang, bank terpasang, popup 3DS, kembali dari browser, internet putus, dan pembayaran selesai setelah polling otomatis berhenti.

Data 67 resource gateway tidak ditemukan belum membuktikan berapa orang terkena bug checkout ini.

### A15 — P2: harga fallback klien dan server berbeda

[product_pricing.dart:54](/Users/apple/Downloads/ramadhan/openturath_ai/lib/core/product_pricing.dart:54) memakai Rp299.000 untuk Tahawwulat satu bulan; [index.ts:634](/Users/apple/Downloads/ramadhan/openturath_ai/functions/src/index.ts:634) memakai Rp300.000. Expected amount yang berbeda ditolak pada baris 923.

Konfigurasi produksi saat audit berisi Rp299.000, sehingga audit tidak menyatakan seluruh checkout sekarang gagal. Celah muncul jika pembacaan konfigurasi gagal/hilang dan fallback berbeda dipakai.

**Perbaikan.** Satu katalog harga menghasilkan kontrak klien dan server. Saat penawaran kedaluwarsa, kembalikan harga otoritatif untuk ditinjau pengguna. Tambahkan tes kesetaraan fallback dan pemulihan ketika konfigurasi tidak dapat dibaca.

## 7. Temuan worker dan operasi

### A16 — P1: queued dan provisioning yatim tidak mempunyai pemulihan yang lengkap

**Bukti produksi + kode.** Lima job literal queued, attempts=0, berusia sekitar 123 jam dan due lewat sekitar 24 jam, tidak termasuk status yang diterima [access_control.ts:547](/Users/apple/Downloads/ramadhan/openturath_ai/functions/src/access_control.ts:547). Pemantau pada index.ts:1380 juga hanya mencari pending/retry/processing. Reproduksi lokal membuktikan runJob meninggalkannya tanpa memanggil provider.

Ada 29 assignment provisioning pada dua identitas legacy. Lima terkait job queued tersebut; 24 tidak mempunyai job dengan uid/entity/revision yang cocok. [reserve():377](/Users/apple/Downloads/ramadhan/openturath_ai/functions/src/access_control.ts:377) langsung mengembalikan provisioning yang sudah ada, sementara repair pada baris 506 hanya menangani ready. Reproduksi dengan grant sah dan job yang dihilangkan tetap meninggalkan provisioning tanpa job setelah reserve+repair.

**Batas dampak.** Lima queued milik satu identitas legacy dan memiliki metadata deadlettered_by. Jangan langsung mengubahnya menjadi pending: bisa ada alasan operasional penghentian sebelumnya. Dua identitas tersebut tidak sama dengan 29 pelanggan.

**Perbaikan.** Definisikan status job resmi dan migrasi status lama secara eksplisit. Semua status nonterminal harus mempunyai eksekusi, retry, atau review yang dipantau. Assignment provisioning wajib memiliki job aktif atau review dengan alasan yang dapat dilihat operator. Pemulihan harus memvalidasi hak per modul, pemilik email, revisi, dan alasan dead-letter terlebih dahulu.

**Kriteria lulus.** Job status lama/tidak dikenal terdeteksi. Penghapusan job dari assignment aktif dapat dipulihkan secara idempoten setelah bukti sah. Worker berhenti lalu mulai lagi tidak menduplikasi grant atau menambah masa langganan.

### A17 — P1: lease baru belum aman untuk batch dan operasi yang sedang berjalan

**Bukti kode/reproduksi.** [access_worker.ts:500](/Users/apple/Downloads/ramadhan/openturath_ai/functions/src/access_worker.ts:500) memeriksa lease sekali sebelum batch sampai 60 job. Di dalam batch pada baris 511–512 tidak ada pemeriksaan ulang. Reproduksi: job pertama membuat lease hilang, tetapi job kedua tetap dijalankan ketika lease=false.

Provider tidak menerima token generasi writer, sementara lock job adalah per notebook+email. Karena operasi dapat berlangsung puluhan detik, angka keyakinan lokal 20 detik pada worker_lease.ts bukan batas maksimum semua penulisan setelah lease berpindah.

**Perbaikan.** Periksa kepemilikan sebelum tiap job dan tepat sebelum mutasi provider. Hentikan batch saat lease hilang. Rancang drain operasi lama sebelum takeover; jangan menganggap pengambilalihan primary seketika aman untuk request yang sudah dikirim. Gunakan generasi writer pada perubahan ledger dan perlindungan provider sejauh didukung. Uji kembali fungsi rekonsiliasi dan CLI yang dapat menulis di luar loop worker.

**Status produksi.** Lease baru belum terbukti aktif; jangan memasang kode baru itu sebagai solusi failover yang sudah selesai sebelum cacatnya diperbaiki.

### A18 — P1: impor billing dapat menghapus hold yang bukan miliknya

[access_worker.ts:204](/Users/apple/Downloads/ramadhan/openturath_ai/functions/src/access_worker.ts:204) menghapus access_revocation_hold bila review legacy pernah ada dan free_access tidak ada, tanpa mengecek alasan hold saat ini atau apakah review sebelumnya sudah resolved.

**Reproduksi lokal.** Pengguna dengan hold=true dan review lama resolved_by_verified_billing berubah menjadi hold=false setelah impor. Ini risiko kode; audit tidak membuktikan telah terjadi pencabutan produksi akibat celah ini.

**Perbaikan.** Pisahkan hold per alasan dan pencatatnya. Importer hanya menyelesaikan alasan legacy yang memang dimilikinya, dengan pemeriksaan versi/transaksi. Hold pemilik, insiden, VIP, atau migrasi lain tidak boleh terhapus karena keberadaan review lama.

### A19 — P1/P2: pemasang worker menerima status sehat palsu

[install_release.sh:41](/Users/apple/Downloads/ramadhan/ecosystem/openturath_subscription/deploy/install_release.sh:41) mengabaikan HTTP 503 dan hanya mengecek apakah field error kosong. Reproduksi: mode standby, authentication_error=true, last_success_ms=0 tetap diterima bila error kosong.

**Perbaikan.** Pisahkan liveness dari readiness. Gerbang pemasangan primary harus memerlukan respons sehat, versi benar, satu siklus berhasil setelah proses mulai, provider teramati sehat, dan kepemilikan writer yang sesuai. Mode standby memiliki syarat berbeda dan tidak boleh dinilai seolah sudah melayani pemberian akses. Kegagalan syarat harus memicu rollback kode yang dapat diverifikasi.

### A20 — P2: ketergantungan sesi provider statis dan keepalive lama

Adapter verified_sharing.py menyalin sesi yang diberikan operator ke direktori sementara setiap operasi. Tidak ada mekanisme penyegaran kredensial mandiri yang terbukti berjalan. Heartbeat saat audit masih menunjukkan provider sehat, jadi ini risiko pemulihan, bukan bukti sesi provider sedang mati.

Log scheduler membuktikan keepalive Cloud Run berulang kali 401. [webhook_server.py:942](/Users/apple/Downloads/ramadhan/ecosystem/openturath_subscription/webhook_server.py:942) memeriksa CRON_SECRET untuk keepalive; cron/reap pada baris 971 menerima fallback INTERNAL_SECRET dan berhenti menulis bila writer=vps-v2. Perbedaan kontrak autentikasi perlu diperiksa, bukan membuka endpoint tanpa autentikasi. Audit belum membaca/membandingkan secret scheduler dan service.

**Perbaikan.** Pastikan monitoring menilai sesi provider worker yang benar. Tetapkan prosedur reautentikasi operator melalui alur yang didukung dan pemasangan snapshot secara atomik, verifikasi readiness setelahnya, lalu eskalasi sebelum antrean pelanggan menumpuk. Jika ada refresh resmi yang didukung provider/library, uji terisolasi. Jangan memalsukan cookie atau menjanjikan master token tidak akan pernah gagal.

Nilai ulang kebutuhan keepalive generasi lama setelah dependensinya dipetakan. Jangan memperbaiki alarm 401 dengan membangkitkan penulis lama yang sudah dinonaktifkan saat cutover.

### A21 — Mendesak: Node 20 mencapai decommission 30 Oktober 2026

Konfigurasi [firebase.json:8](/Users/apple/Downloads/ramadhan/openturath_ai/firebase.json:8) memakai nodejs20; metadata produksi juga menunjukkan Node 20. [Jadwal resmi Google](https://docs.cloud.google.com/functions/docs/runtime-support) mencantumkan decommission 30 Oktober 2026. Sesudahnya pembuatan/pembaruan workload runtime itu tidak didukung, dan workload lama dapat dinonaktifkan. Pernyataan laporan sebelumnya bahwa fungsi berjalan “tidak terpengaruh” terlalu pasti.

**Perbaikan.** Siapkan migrasi Node 22, periksa kompatibilitas dependency serta build/test dengan Node yang sama, lalu lakukan deployment terencana dengan pemeriksaan fungsi pembayaran, webhook, scheduler, dan akses. Upgrade runtime dipisahkan dari perubahan algoritme akses agar diagnosis dan rollback lebih jelas. Tidak ada migrasi/deployment yang dijalankan dalam audit ini.

### A22 — P2: bukti rilis belum mengikat source, binary, dan hasil uji

Publisher [publish_auto_update.py:239](/Users/apple/Downloads/ramadhan/publish_auto_update.py:239) memilih APK yang ada, lalu mengambil versi dari pubspec pada baris 253, tanpa membandingkan versi embedded APK, signing certificate, atau source commit. Berkas bernama versi pada baris 275 tetap dapat ditimpa. Pemeriksaan live pada baris 141 hanya HEAD/ukuran/tipe, bukan hash isi. Ini celah proses yang dapat menyiarkan metadata baru untuk binary lama atau merusak arti URL immutable; audit tidak menyatakan hal itu sudah terjadi pada build 86.

APK saat audit memang mempunyai versionCode 86/versionName 1.0.85, dan memuat arm64-v8a, armeabi-v7a, serta x86_64. Jadi keterangan manifest yang menyatakan hanya Android ARM64 tidak persis sesuai artefak.

**Perbaikan.** Manifest rilis menyimpan source commit, versi embedded, edisi, platform/arsitektur aktual, sertifikat penandatangan, hash, waktu build, dan hasil pengujian artefak. Tolak sumber binary yang berbeda versi/edisi. Tolak penimpaan URL versi dengan hash baru. Verifikasi hash binary live sebelum broadcast. Kenaikan build harus monoton; perbaikan berikutnya tidak memakai ulang build 86.

Analisis dan tes sumber lokal yang lulus tidak boleh dianggap sudah memasukkan perbaikan ke installer/APK yang diunduh pengguna. Perbaikan klien setelah build 86 membutuhkan binary baru dan instruksi rilis terpisah.

## 8. Koreksi penting terhadap laporan awal

| Klaim lama | Hasil audit ulang |
|---|---|
| Tidak ada whitelistedAudiences pada respons v2, sehingga Desktop kemungkinan ditolak | Field tidak tersedia pada schema itu. Masih hipotesis; perlu bukti Firebase exchange nyata |
| Device ID Android adalah ANDROID_ID | Implementasi yang dipakai adalah Build.ID; tabrakan dua perangkat identik dapat dibuktikan |
| 286 notebook stale menandakan rekonsiliasi mungkin macet | 286 semuanya di luar katalog; 346 yang dirouting semuanya fresh |
| repair menghapus semua anggota Google yang tidak ada di ledger | Tidak sesuai jalur yang diperiksa: repair dipicu untuk membership ledger yang hilang dari Google |
| run_reaper_daemon tidak terlindungi writer guard | Ia memakai run_cycle yang sudah berhenti ketika writer=vps-v2 |
| Lease menutup celah penulis dalam maksimal 20 detik | Batch/in-flight tidak terikat batas itu; reproduksi menunjukkan job berikut masih berjalan setelah lease hilang |
| Windows belum mempunyai entri OTA, macOS masih build 68 | Saat audit keduanya sudah tercatat build 86 |
| Angka 16 jam membuktikan pembayaran terlambat diberi akses | Waktu akses pertama belum tersedia; created_at→paid_at bukan metrik pemberian akses |
| Banyak invoice tidak ditemukan berarti pengguna belum menyelesaikan pembayaran | 404 perlu dibedakan dari pembayaran manual, invoice tidak ditemukan, dan kejadian UI; penyebab berhenti belum terukur |
| Fungsi Node 20 yang sudah berjalan pasti tidak terpengaruh | Dokumentasi resmi menyatakan workload runtime decommissioned dapat dinonaktifkan |

## 9. Rencana perbaikan yang dapat dieksekusi

### Fase 1 — Amankan jalur pengguna yang paling dasar

1. Kerjakan migrasi Node 22 sebagai perubahan tersendiri karena tenggat 30 Oktober.
2. Satukan packaging Windows dan tambahkan bootstrap prasyarat; siapkan distribusi macOS bertanda tangan/notarisasi yang lolos Gatekeeper.
3. Pisahkan status autentikasi/cache, hentikan replay cookie buatan dan pembersihan global di luar Log Out, serta tutup await tanpa deadline.
4. Perbaiki identitas trial dan siapkan daftar penolakan yang dapat ditinjau ulang tanpa reset massal.

Hasil fase ini: binary calon rilis yang bisa dibuka pada perangkat bersih, sesi yang jujur, dan trial tidak saling memblokir. Seluruh perbaikan tetap lokal sampai kriteria artefak dan uji pengguna terpenuhi.

### Fase 2 — Pastikan pembayaran berakhir pada akses yang benar

1. Bentuk satu hasil readiness terstruktur: hak aktif, entity wajib, entity sudah diverifikasi, entity menunggu, alasan, dan nomor pelacakan.
2. Pakai evaluator sama pada UI/pemantau. Timeout UI tidak boleh disebut selesai.
3. Jadikan insiden lunas tanpa akses durable sampai resolved, dengan retry notifikasi dan eskalasi.
4. Tinjau dua identitas legacy yang terkait assignment provisioning; cocokkan bukti, revisi, serta alasan dead-letter sebelum membuat job pemulihan.
5. Simpan pembayaran manual dengan sumber/bukti/verifikator terstruktur, serta pisahkan dari settlement gateway. Pertahankan seluruh hak sah dan VIP.

Hasil fase ini: setiap pelanggan mempunyai jalur diagnosis yang jelas dari invoice ke hak, sharing, dan sesi AI; tidak ada assignment nonterminal yang diam tanpa job/review.

### Fase 3 — Benahi operasi dan failover

1. Tutup celah lease batch/in-flight serta penghapusan hold global.
2. Perkuat readiness pemasang dan verifikasi rollback.
3. Pisahkan health pool routing dari record notebook arsip; jangan menghapus membership hanya untuk membersihkan dashboard.
4. Uji pemulihan sesi provider dan kegagalan Telegram/Firestore/provider tanpa menciptakan penulis ganda.
5. Tambahkan jejak waktu settlement, hak diterapkan, sharing pertama terverifikasi, dan AI pertama terbuka.

Hasil fase ini: klaim “otomatisasi sehat” berarti pelayanan pelanggan terbukti selesai, dengan kegagalan yang dapat ditindaklanjuti.

### Fase 4 — Rilis terkontrol setelah bukti lengkap

Rilis berikutnya memakai nomor build lebih tinggi dari 86, identitas source/binary jelas, dan satu matriks hasil uji. Mulai dengan kelompok kecil pengguna yang mengalami masalah, pantau hasil login/akses, lalu perluas setelah stabil. Persiapan lokal, deployment backend, dan publikasi aplikasi diperlakukan sebagai tahap berbeda. Jangan mencabut hak atau mengubah expiry sebagai efek samping rollback kode.

### Matriks penerimaan wajib

| Skenario | Bukti yang harus diperoleh |
|---|---|
| Windows bersih, runtime belum terpasang | Setup menyelesaikan prasyarat, aplikasi tampil, login dan AI berhasil |
| Mac dari unduhan browser dengan Gatekeeper aktif | Tanda tangan/notarisasi diterima; close/reopen dan update mempertahankan sesi |
| Firebase null, profil cache ada | UI tidak mengaku terautentikasi; masuk kembali memulihkan hak yang sama |
| Tutup/buka, restart OS, lima tab | Tidak ada clear cookie atau replay token buatan; sesi dapat dipulihkan lewat alur resmi |
| Akun Firebase dan sesi AI berbeda | Penyebab dapat dijelaskan dan akun dapat dipilih ulang tanpa reset global |
| Dua HP identik dan dua browser ber-UA sama | Tidak ada penolakan lintas pengguna akibat collision fingerprint |
| Tahawwulat hanya 1/5 asisten siap | UI tetap menunggu; monitor mendeteksi empat entity yang belum siap |
| Semua entity siap dan terverifikasi | UI dan monitor sama-sama menyatakan siap; tidak ada alarm all-access palsu |
| Pembayaran selesai setelah polling habis | Pemeriksaan manual tetap bekerja dan tidak meminta bayar ulang |
| Job hilang/status lama/provider timeout | Recovery idempoten atau review eksplisit; tidak macet diam |
| Dua worker dan lease berpindah di tengah batch | Penulis lama berhenti; tidak ada mutasi tumpang tindih yang tidak terkendali |
| Review legacy lama + hold baru pemilik | Hold baru tetap terlindungi |
| Telegram gagal lebih dari tiga jam | Insiden tetap terbuka, pemberitahuan dicoba ulang dan dieskalasi |
| Webhook diulang, transfer paket, bonus, transaksi nol, VIP | Tidak ada penambahan durasi berulang atau pencabutan hak sah lintas modul |

## 10. Verifikasi yang sudah dijalankan dan yang belum

Sudah dilakukan:

- Pembacaan kode dan pemeriksaan terpisah pada klien, backend pembayaran/akses, serta worker/Python.
- 252 tes backend Node 22 lulus; TypeScript check tanpa menghasilkan output build lulus.
- 27 tes Flutter terarah lulus secara sequential; analisis tujuh berkas startup/auth/session/callable tanpa error.
- 70 tes Python skrip OTA/manajemen lulus; empat tes Python writer guard lulus.
- 35 tes Node worker/lease terarah lulus; jumlah ini beririsan dengan suite backend, bukan tambahan untuk dijumlahkan.
- Reproduksi tambahan untuk collision trial, readiness parsial/all-access, alarm Telegram hilang, queued diabaikan, provisioning tanpa job, lease hilang di tengah batch, hold terhapus, dan health check pemasang menerima layanan belum siap.
- Pembacaan Firestore produksi, metadata Functions, log scheduler, 93 pemeriksaan status invoice Midtrans, metadata APK, isi/dependensi paket Windows, dan tanda tangan/Gatekeeper aplikasi dalam DMG.

Hasil lulus tersebut justru menunjukkan celah cakupan pengujian: banyak tes memakai MemoryDB, token palsu, resolver injeksi, atau placeholder WebView. Harness MemoryDB juga tidak sepenuhnya meniru perbandingan Timestamp Firestore; angka produksi dan filter waktu pada laporan ini tidak disimpulkan dari fixture itu.

Belum dibuktikan:

- Login Google dan pertukaran credential Firebase pada perangkat Windows nyata yang dilaporkan gagal.
- Penyebab hilangnya sesi tertentu, termasuk kemungkinan penolakan OAuth, pembatasan API key, firewall loopback, dan persistensi OS.
- Pembukaan notebook nyata dengan sesi Google pelanggan yang sedang mengeluh, serta kesamaan identitasnya.
- Uji instalasi dan alur penuh pada Windows bersih; uji Mac bersih setelah distribusi bertanda tangan benar.
- Bukti transfer bank asli untuk pembayaran yang dicatat manual.
- Waktu sharing pertama berhasil untuk setiap pembayaran historis; data snapshot ready tidak memberikan seluruh riwayat latensi.
- Kesetaraan penuh binary worker VPS dengan source terbaru. Tidak ada inspeksi SSH langsung atau penggantian layanan VPS pada audit ini.

**Kesimpulan operasional:** ada cukup bukti untuk mengerjakan perbaikan konkret di atas. Belum ada dasar untuk menyatakan masalah pelanggan telah selesai hanya karena tes lulus, heartbeat sehat, atau assignment berstatus ready. Penyelesaian harus ditutup dengan bukti instalasi, sesi, dan pembukaan AI pada artefak yang benar-benar akan diterima pengguna.
