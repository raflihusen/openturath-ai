# Audit mendalam login Google kedua: penghalang masuk OpenTurath

Tanggal: 4 November 2026. Baseline: commit c7a8c906, sumber aplikasi 1.0.87+88.

Status: audit kode dan pengujian lokal terisolasi selesai; perbaikan aplikasi belum diterapkan.

## 1. Maksud pengguna dan kesimpulan audit

Pengguna menjelaskan bahwa setelah berhasil login Google kedua, OpenTurath seharusnya dapat dibuka tanpa menunggu NotebookLM tampil. Halaman saran penambahan alamat pemulihan, privasi, atau pengelolaan keamanan akun tidak seharusnya menjadi syarat tambahan untuk mengakses beranda aplikasi.

**Keluhan tersebut mempunyai penyebab nyata dalam kode saat ini.** Penyelesaian koneksi Google disyaratkan terjadi pada domain NotebookLM, dengan email WebView yang dapat dibaca dan cookie sesi yang dikenali. Halaman Google Account lain ditolak sebagai jalur penyelesaian, baik oleh pemeriksaan otomatis maupun tombol Lanjutkan.

Penjelasan teknis yang presisi: layar login kedua tidak menguji composer chat. Ia menunggu host NotebookLM dan identitas yang dibaca dari DOM halaman tersebut. Kesiapan composer adalah pemeriksaan lain di bilik AI. Keduanya harus dibedakan dari izin memasuki aplikasi.

Keberhasilan enam skenario audit berarti perilaku penghalang berhasil direproduksi, bukan berarti masalah sudah diperbaiki.

## 2. Jalur yang berjalan saat ini

1. Login Firebase berhasil dan profil pengguna tersedia.
2. LoginScreen menjalankan rekonsiliasi sesi WebView.
3. Jika sesi Google sebelumnya belum mempunyai owner terverifikasi yang cocok, aplikasi mengganti layar login dengan GoogleSessionAuthScreen.
4. Layar tersebut mula-mula membuka halaman utama notebook.google.com; ketika perlu login, alur Google dapat menuju halaman akun dan keamanan.
5. Selama URL belum kembali ke domain NotebookLM, pemeriksaan otomatis tidak memverifikasi penyelesaian.
6. Menekan Lanjutkan pada halaman Google Account juga ditolak.
7. Untuk menyelesaikan alur normal, URL harus berada di NotebookLM, email yang dibaca harus cocok, dan cookie sesi harus lolos pemeriksaan.
8. Baru kemudian layar kembali ke pemanggil atau menuju dashboard.

Jadi pengguna dapat sudah memiliki sesi Google di WebView, tetapi tetap tidak memenuhi syarat navigasi aplikasi.

## 3. Temuan terkonfirmasi

### L2-01 — Prioritas tinggi: domain NotebookLM menjadi syarat masuk aplikasi

Lokasi: GoogleSessionAuthScreen._checkAccountVerification, baris 323–331; _watchdogTick, baris 198–205.

Pemeriksaan mengembalikan hasil lebih awal bila URL memuat accounts.google, bagian URL login/challenge tertentu, atau bukan domain NotebookLM. Watchdog tiga detik juga hanya memanggil verifikasi ketika URL adalah NotebookLM.

Dampak: halaman myaccount.google.com/security atau halaman akun Google lain tidak mempunyai jalur otomatis menuju penyelesaian. Penambahan watchdog tidak menyelesaikan kondisi ini, karena watchdog mempertahankan syarat domain yang sama.

Bukti: fixture dengan cookie sesi sintetis dan email akun yang tersedia tetap berada di layar koneksi pada dua URL Google Account. Setelah beberapa putaran watchdog, pemeriksaan email dan pembacaan cookie sesi belum dilakukan.

### L2-02 — Prioritas tinggi: tombol Lanjutkan bukan jalan masuk mandiri

Lokasi: GoogleSessionAuthScreen._handleManualContinue, baris 679–687.

Tombol memeriksa apakah URL saat ini adalah NotebookLM sebelum memeriksa email atau keberadaan sesi Google. Jika bukan, pengguna mendapat pesan “Selesaikan dulu proses masuk Google.”

Dampak: orang yang sudah berada di halaman pengelolaan keamanan akun tetap dianggap belum menyelesaikan login. Tombol tidak memberi jalan keluar dari ketergantungan domain.

Bukti: dua fixture Google Account menghasilkan pesan tersebut meskipun cookie sesi sintetis tersedia.

### L2-03 — Prioritas tinggi: konfirmasi “Ya, sudah masuk” tetap bergantung pada email NotebookLM

Lokasi: _handleManualContinue, baris 711–724; _handleInconclusiveVerification, baris 397–414; _onSessionAuthenticated, baris 749–763.

Fallback dapat menemukan cookie dan menampilkan konfirmasi akun yang sama. Namun memilih “Ya, sudah masuk” memanggil fungsi akhir yang kembali mensyaratkan URL NotebookLM dan email DOM yang cocok. Jika email belum terbaca, pengguna dibawa ke status sesi belum dapat diverifikasi.

Dampak: teks konfirmasi memberi kesan alur dapat dilanjutkan, padahal kondisi teknis yang belum terpenuhi diperiksa kembali.

Batas interpretasi: pemeriksaan kecocokan akun tetap diperlukan untuk mengklaim owner WebView dan menggunakan bilik. Masalahnya adalah menjadikannya syarat global beranda, bukan perlunya menghapus pemeriksaan identitas tersebut.

Bukti: cookie SID sintetis ada, pengguna memilih konfirmasi, tetapi alur tetap tidak selesai ketika email DOM tidak terbaca.

### L2-04 — Prioritas tinggi: aturan login baru berbeda dari pembukaan ulang aplikasi

Lokasi: LoginScreen._signIn, baris 76–85; SplashScreen._checkAuthAndNavigate, baris 74–86.

Login baru memilih dashboard hanya jika restoreSessionIfAvailable mengembalikan true. Sebaliknya, SplashScreen mengizinkan dashboard untuk Firebase user non-anonymous yang sah, sambil memperlakukan kesiapan Google sebagai pemeriksaan terpisah.

Dampak: sesi aplikasi yang sama dapat tertahan setelah login baru, tetapi diizinkan masuk melalui jalur startup. Ini menunjukkan bahwa ketergantungan beranda pada NotebookLM bukan persyaratan yang konsisten dalam aplikasi.

Bukti: fixture SplashScreen dengan Firebase user sah dan tanpa kesiapan Google mencapai dashboard. Ini pengujian jalur startup dengan dependensi autentikasi palsu, bukan bukti restart pada perangkat pelanggan.

### L2-05 — Prioritas menengah: kriteria cookie pada fallback dan penyimpanan berbeda

Lokasi: GoogleSessionAuthScreen._hasGoogleSession, baris 558–569; PersistentGoogleSession._hasLiveSession, baris 27–40.

Fallback mengenali SID, __Secure-1PSID, dan __Secure-3PSID. Pemeriksaan akhir penyimpanan hanya mengenali SID atau __Secure-1PSID, dengan pemeriksaan dua origin.

Dampak pada fixture: cookie __Secure-3PSID saja cukup untuk menampilkan konfirmasi fallback, tetapi tidak cukup untuk menyelesaikan penyimpanan meskipun email kemudian terbaca.

Batas interpretasi: ini inkonsistensi yang teruji pada data sintetis. Belum diketahui apakah pelanggan terdampak benar-benar mempunyai himpunan cookie tersebut. Keberadaan cookie juga tidak sendirian membuktikan identitas atau keberhasilan challenge Google.

### L2-06 — Prioritas menengah: jalur keluar yang benar tersembunyi di tindakan pembatalan

Lokasi: _confirmCancelConnection, baris 800–867; copy_catalog.dart, baris 561–574.

Kode sudah menyediakan dialog “Tunda koneksi AI?” dengan penjelasan bahwa pengguna tetap masuk ke OpenTurath, sesi dan tab dipertahankan. Tindakan “Tunda dulu” kembali ke pemanggil atau dashboard sesuai susunan route.

Dampak: aplikasi sebenarnya mampu membedakan akses aplikasi dari koneksi AI, tetapi jalur ini ditempatkan di tombol X/Back berlabel pembatalan. Pengguna yang merasa sudah sukses login lebih mungkin menekan Lanjutkan yang justru masih memblokir.

Batas interpretasi: bila layar dibuka dari bilik AI, penundaan mengembalikan hasil false dan bilik mempertahankan status pemulihannya; itu tidak otomatis menyatakan AI siap.

## 4. Batas waktu dan pengamatan tambahan dari kode

- Polling email berjumlah 32 percobaan dengan jeda 250 ms, tetapi tiap pemeriksaan JavaScript mempunyai timeout tiga detik. Komentar “sekitar delapan detik” berlaku bila pemeriksaan cepat; bila semuanya habis timeout, durasi teoritis loop mendekati 104 detik, di luar langkah lain. Ini perhitungan dari kode, belum pengukuran perangkat.
- Di halaman Google non-NotebookLM, verifikasi berhenti sebelum masuk loop tersebut. Tidak ada batas tunggu keseluruhan yang otomatis mengalihkan pengguna ke beranda.
- Pembacaan email mencari beberapa elemen header serta string email dalam WIZ_global_data. Kestabilan dan makna identitas pada seluruh variasi halaman belum dibuktikan. Jangan memperluas klaim owner hanya berdasarkan sembarang email yang ditemukan.
- Hasil koneksi saat ini berupa boolean. Pemanggil bilik mengartikan true sebagai koneksi selesai dan memulai kembali pemuatan. Menggunakan true untuk sekadar “boleh masuk aplikasi” akan mencampurkan makna dan memerlukan koreksi kontrak.

## 5. Bukti pengujian

Pengujian dijalankan melalui Dart MCP pada salinan proyek terisolasi. Paket dependency mengikuti pubspec dan lockfile yang sama. Sebanyak 179 file Dart dalam lib dibandingkan dan identik dengan sumber workspace.

| Kelompok | Jumlah | Hasil |
|---|---:|---|
| Skenario audit tambahan | 6 | Perilaku yang ditargetkan berhasil direproduksi |
| google_session_recovery_test.dart | 7 | Lulus |
| google_session_auth_flow_test.dart | 2 | Lulus |
| persistent_google_session_test.dart | 8 | Lulus |
| room_google_connection_result_test.dart | 4 | Lulus |
| Total | 27 | Lulus sebagai pengujian perilaku sumber saat ini |

Enam skenario tambahan:

1. Halaman Google Account Security dengan cookie sintetis tetap tertahan, termasuk setelah watchdog dan tombol Lanjutkan.
2. Halaman utama Google Account menghasilkan kondisi yang sama.
3. Fixture yang sama baru selesai ketika URL dipindahkan ke NotebookLM.
4. Cookie ada dan pengguna memilih “Ya, sudah masuk”, tetapi tidak selesai bila email NotebookLM tidak terbaca.
5. Cookie __Secure-3PSID saja diterima fallback tetapi ditolak pemeriksaan akhir.
6. Startup dengan Firebase user sah menuju dashboard walaupun kesiapan Google false.

Artefak reproduksi: characterization_test.dart. Catatan hasil: test-results.txt dan verification.json di folder dokumen audit ini.

Untuk mengulang tanpa mengubah aplikasi utama: salin lib, pubspec, lockfile dan empat test yang disebutkan ke proyek audit; sediakan assets yang sama secara baca-saja; letakkan characterization_test.dart sebagai test tambahan; ambil dependency sesuai lockfile; jalankan lima berkas melalui Dart MCP. Jangan menjalankan fixture ini sebagai persetujuan bahwa perilaku yang direproduksi sudah sesuai kebutuhan baru.

Cookie, identitas, dan penyedia WebView pada fixture adalah palsu. Tidak ada login interaktif Google, perubahan akun pelanggan, pemasangan aplikasi, atau pembuktian perangkat fisik dalam pengujian ini.

## 6. Perilaku yang seharusnya dituju

Tiga status harus dipisahkan:

| Status | Bukti dan fungsi |
|---|---|
| Akses aplikasi | Firebase user yang sah dan sesuai sesi; mengizinkan beranda, akun, langganan, serta navigasi aplikasi. |
| Sesi Google WebView | Keberadaan sesi dan kecocokan akun yang mempunyai tingkat bukti tersendiri; tidak diwarisi otomatis dari Firebase. |
| Kesiapan bilik | Hak modul, notebook yang sesuai, serta composer siap melalui pemeriksaan bilik yang sudah ada. |

Setelah login Google kedua berhasil teramati, pengguna masuk aplikasi tanpa diwajibkan membuka NotebookLM. Jika pengguna berada pada tindak lanjut akun yang opsional dan bukti owner WebView belum lengkap, beranda tetap boleh dibuka dengan sesi aplikasi yang sah. Koneksi AI tetap ditandai belum terverifikasi sampai ada bukti yang cukup.

Halaman saran penambahan data dan challenge wajib tidak boleh disamakan. Pemeriksaan OTP, password, passkey, atau “verifikasi bahwa ini Anda” tidak dianggap selesai hanya karena URL berada di domain Google atau cookie lama masih ada.

## 7. Solusi implementasi yang direkomendasikan

### 7.1 Pisahkan izin navigasi dari klaim sesi Google

- Gunakan autentikasi aplikasi yang sah untuk mengizinkan beranda, konsisten dengan SplashScreen.
- Jangan menjadikan domain NotebookLM, email DOM NotebookLM, atau composer sebagai prasyarat global memasuki aplikasi.
- Sediakan tindakan “Masuk ke OpenTurath” yang jelas selama sesi aplikasi sah. Tindakan tersebut tidak menulis marker owner WebView atau status AI siap.
- Untuk perpindahan otomatis setelah login kedua, gunakan bukti penyelesaian yang tersedia pada alur Google dan rute pascalogin yang sudah dikenali. Jangan memakai aturan “semua halaman myaccount/accounts berarti sukses”.
- Jika bukti penyelesaian Google belum dapat dipastikan, jalur masuk beranda tetap tersedia; ketidakpastian koneksi AI tidak berubah menjadi autentikasi palsu.

### 7.2 Bedakan konteks pembukaan layar dan hasilnya

- Bedakan layar yang dibuka setelah login aplikasi dari layar yang dibuka untuk memperbaiki bilik.
- Setelah onboarding akun, penyelesaian atau penundaan koneksi mengantar pengguna ke dashboard dengan pemeriksaan sesi aplikasi yang masih sah.
- Dari bilik, hasil harus membedakan koneksi terverifikasi, belum terverifikasi/ditunda, dan dibatalkan. Jangan mengembalikan true bila hanya akses aplikasi yang diizinkan.
- Verifikasi owner dan hak modul tetap berlaku sebelum penggunaan bilik yang memerlukannya.
- Jika akun berubah, logout terjadi, atau layar ditutup, callback lama tidak boleh menavigasi memakai identitas sebelumnya.

### 7.3 Pertahankan perlindungan sesi

- Tidak menulis google_session_ready=true atau verifiedOwnerKey hanya karena cookie ada, pengguna menekan konfirmasi, atau Firebase sudah login.
- Tidak menghapus, memperpanjang, atau menyalin ulang cookie.
- Tidak mengubah polling empat sampel/3000 ms/250 ms atau lifecycle bilik dan desktop runtime.
- Tidak mengubah VIP, grant, expiry, undangan, atau keputusan akses per modul.
- Penyamaan kriteria cookie dilakukan sebagai konsistensi pemeriksaan baca-saja setelah bukti platform tersedia, bukan dengan membuat cookie baru.

### 7.4 Lengkapi pencatatan tahap

Catat fase pascalogin Google, halaman tindak lanjut akun, penundaan koneksi, bukti owner yang belum cukup, dan pembukaan dashboard secara terpisah. Gunakan host/pola rute aman tanpa isi formulir, query, email pribadi, kode verifikasi, atau nilai cookie. Jangan mengubah status pascalogin normal menjadi alarm gagal login.

## 8. Pengujian penerimaan untuk perbaikan berikutnya

- Firebase sah + login Google berhasil + halaman saran recovery: dashboard dapat dibuka tanpa kunjungan NotebookLM.
- Firebase sah + halaman keamanan akun: tindakan masuk aplikasi tetap berfungsi; tidak memberi klaim owner tanpa bukti.
- Firebase sah + NotebookLM lambat/tidak tersedia: beranda tetap dapat dipakai.
- Firebase tidak sah: tidak boleh masuk dashboard hanya berdasarkan cookie atau cache profil.
- Challenge Google yang belum selesai: tidak diklaim sebagai sesi Google terverifikasi.
- Akun Google berbeda: tidak diwariskan sebagai owner akun aplikasi; panduan diberikan pada jalur koneksi AI.
- Dibuka setelah login dibanding dari bilik: hasil navigasi dan status pemulihan tepat untuk masing-masing konteks.
- DOM email tidak terbaca: tidak memblokir beranda dan tidak memalsukan status AI siap.
- Tutup-buka aplikasi dan respons terlambat: tidak ada regresi sesi atau navigasi.
- Android, Windows, dan macOS: uji perangkat terpisah, termasuk halaman pascalogin yang benar-benar dilihat pengguna.

## 9. Urutan tindak lanjut

1. Prioritaskan pemisahan akses aplikasi dari penyelesaian koneksi NotebookLM dalam rencana utama.
2. Tetapkan kontrak hasil koneksi dan aturan navigasi untuk dua konteks pembukaan layar.
3. Tambahkan pengujian kebutuhan baru yang mengharapkan dashboard terbuka; fixture audit saat ini hanya mendokumentasikan perilaku lama.
4. Implementasikan perubahan pada entry flow dan adapter hasil, dengan lifecycle bilik tetap dipertahankan.
5. Jalankan regresi identitas, cookie, tab, dan route, lalu verifikasi pada perangkat.
6. Build, deployment, dan publikasi tetap mempunyai bukti dan otorisasi tersendiri.

## 10. Keterbatasan dan sumber

Kode yang diperiksa mampu menghasilkan gejala yang dijelaskan pengguna. Namun audit tidak mengamati langsung halaman Google pelanggan, sehingga belum memastikan URL atau jenis saran keamanan yang muncul pada setiap kejadian. Halaman uji adalah representasi skenario, bukan rekaman navigasi pelanggan.

Keberhasilan 27 pengujian lokal tidak membuktikan Google menerima login di Android, Windows, atau macOS nyata. Sesi Google dan cookie produksi tidak dibaca atau dimodifikasi untuk reproduksi ini.

Rujukan primer Google:
- https://support.google.com/accounts/answer/46526 — Security Checkup dan rekomendasi keamanan akun.
- https://support.google.com/accounts/answer/6316959 — pengelolaan alamat email dan email pemulihan.

Sumber utama kode:
- openturath_ai/lib/screens/google_session_auth_screen.dart
- openturath_ai/lib/screens/login_screen.dart
- openturath_ai/lib/screens/splash_screen.dart
- openturath_ai/lib/services/persistent_google_session.dart
- openturath_ai/lib/widgets/agent_multi_tab_room.dart
- openturath_ai/lib/core/copy_catalog.dart
