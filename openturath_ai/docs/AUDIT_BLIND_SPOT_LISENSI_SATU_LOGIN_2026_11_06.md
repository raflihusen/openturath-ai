# Audit pra-eksekusi: lisensi pembelian, satu login Google, dan WebView

Tanggal: 6 November 2026. Basis sumber: `2e87f0d6` dan dependency native terpasang di checkout ini.

**Putusan: belum siap untuk implementasi luas atau rilis.** Konsep dapat menghilangkan kebutuhan Google OAuth pertama, tetapi rancangan percakapan sebelumnya belum menutup batas identitas, penyediaan akses, pemulihan, penyimpanan kredensial, dan penghapusan. Tidak ada kode produk atau konfigurasi produksi yang diubah dalam audit ini.

Audit dilakukan dengan penelaahan sumber dan tiga tinjauan independen: billing/worker, perangkat/pemulihan, serta produk/WebView. Label kritis berarti penghalang desain sebelum implementasi/rollout, bukan pernyataan bahwa eksploitasi telah terjadi. Ini laporan audit dan usulan koreksi, bukan spesifikasi yang telah disetujui atau bukti keberhasilan runtime.

## 1. Asumsi yang harus ditarik kembali

- Lisensi perangkat **tidak otomatis** membuat notebook siap. Worker sekarang masih mensyaratkan pemilik akun dengan email terverifikasi.
- Firebase anonymous **bukan** identitas pemilik pembelian permanen atau bukti pembayaran. Ia hanya dapat menjadi bootstrap sementara.
- Memegang hak satu modul **bukan** izin mengambil alih UID akun pelanggan dan seluruh profil/catatan/transaksinya.
- Istilah secure storage dalam rancangan belum membuktikan implementasi aman: patch macOS sekarang menambahkan salinan arsip Firebase user ke UserDefaults.
- Pembelian terverifikasi belum membuktikan kepemilikan email yang diketik, akun Google di WebView, atau hak memulihkan semua transaksi pada alamat tersebut.
- Pengikatan perangkat hanya membatasi penggunaan melalui aplikasi. Setelah Google memberi ACL ke suatu akun, akun itu dapat memakai layanan di konteks lain sesuai aturan Google; app device limit bukan DRM lintas situs.
- Menghapus login pertama belum menyelesaikan penolakan Google terhadap embedded browser, batas akun/kuota, atau perubahan halaman provider.

## 2. Temuan penghalang

### B01 — Pemilik transaksi, penerima akses, dan instalasi belum memiliki kontrak terpisah

`createCheckout` mengharuskan token email terverifikasi (`functions/src/index.ts:902–933`), aktivasi mencari `users/{uid}` dan grant milik UID tersebut (`:1086–1118`), inquiry membandingkan UID pemanggil dengan UID transaksi (`:1722–1762`). Tidak cukup mengganti UID tersebut menjadi UID anonymous dan mengisi email dari form.

**Koreksi:** pertahankan canonical owner di ledger; definisikan penerima akses terverifikasi dan instalasi sebagai entitas terpisah. Untuk fase awal gunakan satu penerima akses yang jelas, tanpa transfer/gifting otomatis. Buktikan email penerima melalui saluran terverifikasi; metadata bank/Midtrans atau label DOM bukan buktinya. Jalur V2 berotorisasi lisensi berdampingan dengan V1; jangan menurunkan gate endpoint lama.

### B02 — Worker masih menolak identitas tanpa email terverifikasi

`functions/src/access_worker.ts:134–137` dan `:349–355` membaca Firebase Auth canonical owner, memeriksa `emailVerified` dan kecocokan email. Jika tidak cocok, worker menaruh `identity_review`; paket berstatus paid masih bisa tertahan.

**Koreksi:** buat kontrak bukti penerima akses untuk V2 yang dapat diverifikasi worker, atau pertahankan pemilik yang benar-benar terverifikasi lewat jalur aktivasi yang didukung. Bukti email terverifikasi boleh menjadi dasar yang sah sesuai model baru; jangan memalsukan identitas Google atau reserved token claims. Semua writer/worker harus memahami owner model yang sama sebelum checkout V2 dibuka.

### B03 — UID perangkat dapat membuka data pribadi jika disamakan dengan UID pelanggan

Rules membatasi profil/bookmark/transaksi berdasarkan UID (`firestore.rules:10–48,87–89`). Menerbitkan custom token untuk UID pelanggan hanya karena ada license capability memberi akses jauh lebih besar daripada hak modul.

**Koreksi:** device session mempunyai principal tersendiri dan projection minimal: modul, expiry, status, email tujuan yang disamarkan bila perlu. Tidak ada akses default ke histori pembayaran lengkap, cloud notes/bookmarks, data kontak, atau penghapusan akun owner. Migrasi berdasarkan token akun lama yang benar-benar diverifikasi tetap bisa mempertahankan data, dengan scope yang eksplisit.

### B04 — Penghapusan device identity dapat salah memicu pencabutan pelanggan

`onUserDeleted` memanggil cleanup pelanggan untuk Auth user yang dihapus (`functions/src/index.ts:2894–2898`); cleanup membuat outbox remove, tombstone, dan menghapus profil (`:2847–2877`). Firebase juga menawarkan cleanup anonymous bersyarat konfigurasi. Reinstall/hilangnya sesi tidak boleh disamakan dengan pelanggan menghapus seluruh akunnya.

**Koreksi:** identitas customer dan device harus dibedakan secara server-side dan tetap dapat dikenali setelah Auth record hilang. Menghapus sesi/perangkat hanya melepaskan binding; tidak menghapus transaksi/grant atau VIP. Penghapusan customer adalah tindakan berbeda, berotorisasi sesuai haknya. Audit tombstone/reaper/cleanup sebelum menambahkan tipe Auth baru.

### B05 — Tautan pemulihan bisa mengaktifkan perangkat penyerang

Counterexample rancangan: penyerang meminta aktivasi untuk email korban dengan public key penyerang. Korban mengklik email asli. Jika klik langsung mengaktifkan permintaan asal, server telah membantu penyerang.

**Koreksi:** GET, preview, dan email scanner tidak boleh mengonsumsi/menyetujui aktivasi. Konsumsi harus atomik melalui tindakan eksplisit, memerlukan token sekali pakai serta request/verifier/kunci aplikasi tujuan yang cocok. Tampilkan tujuan aktivasi. Link yang diminta pada perangkat lain tidak boleh otomatis menyetujui perangkat tersebut; cross-device recovery memakai pairing yang disengaja atau bantuan terverifikasi. Wajib ada TTL, rate limit, respons anti-enumerasi, pembatasan percobaan, dan pencabutan request yang digantikan. Jangan mengandalkan nama perangkat yang diklaim penyerang sebagai konfirmasi.

### B06 — Ada jalur penyimpanan archive berkredensial di UserDefaults macOS

`macos/Podfile:46–47` menjalankan patch. `macos/patch_macos_keychain.rb:45–59` menambahkan write archive user sebelum write Keychain dan read UserDefaults sebelum Keychain. Kode dependency terpasang `AuthStoredUserManager.swift:178–182` mengonfirmasi jalur write, `:83–97` jalur read. `User.swift` mengarsipkan tokenService; kelas AuthUserDefaults menggunakan UserDefaults tanpa enkripsi tambahan di kelas itu.

**Koreksi:** sebelum mengandalkan token/kunci perangkat, rencanakan migrasi ke Keychain dengan signing/entitlements yang benar, hentikan fallback archive kredensial ke preferences pada build distribusi, dan verifikasi perilaku saat Keychain ditolak. Jangan menghapus salinan lama secara massal atau memutus sesi sekarang. Temuan ini berasal dari kode build lokal; tidak membaca token pengguna dan bukan bukti kebocoran produksi.

## 3. Blind spot besar lain

| ID | Bukti / kasus | Koreksi yang diperlukan |
|---|---|---|
| B07 | DeviceService memakai ID preferences atau hash hardware/vendor dengan salt statis (`lib/services/device_service.dart:42–72,94–149`) | Jangan pakai fingerprint itu sebagai proof-of-possession. Kunci instalasi harus dapat menandatangani challenge server; kemampuan hardware/secure storage diuji per OS. Device ID bukan secret. |
| B08 | Manifest Android sumber belum menentukan aturan backup/transfer; package belum mempunyai implementasi possession-key baru | Tetapkan apa yang boleh dicadangkan. Restore preferences tanpa key harus memicu pemulihan, bukan membuka lisensi atau menghilangkan hak bayar. Periksa merged release manifest, cloud backup dan D2D; jangan cukup mengandalkan allowBackup=false. |
| B09 | Splash/AuthService/GoogleSessionAuth/room masih memakai UID/email akun: `auth_service.dart:151–162`, `agent_multi_tab_room.dart:1646–1676`, `google_session_auth_screen.dart:63–64` | Tambahkan principal/snapshot lisensi yang jelas. Jangan memakai fake UserModel/email terverifikasi agar gate lama lolos. Dependensi identitas dan session-owner harus dipindahkan secara eksplisit tanpa memotong lifecycle/polling room yang dilindungi. |
| B10 | Catatan lokal dan bookmark diindeks UID; bookmark menyinkronkan user non-null | Migrasi namespace data harus terencana. Jangan membuat catatan tampak hilang atau menyinkronkan cloud pribadi ke device principal baru tanpa hak. Untuk MVP license, cloud pribadi dapat tetap opsional dengan pemulihan terpisah; jangan menghapus data lama. |
| B11 | Webhook duplikat, terlambat, tidak berurutan, refund saat claim/renewal | Pertahankan satu sumber grant per transaksi, deduplikasi atomic, nominal/order/gateway valid, dan monotonic state. Pisahkan status pembayaran, lisensi, binding perangkat, serta readiness Google. Pembayaran lunas tidak boleh memperpanjang lisensi berulang. |
| B12 | Provider ACL masih aktif setelah aplikasi menonaktifkan lisensi | Expiry/refund harus memicu penyediaan/pencabutan yang teramati dan dapat direkonsiliasi. Status revoked di aplikasi tidak membuktikan Google sudah mencabut ACL. Kegagalan worker menjadi pending/review, bukan sukses palsu. Jangan mencabut jika ada grant sah lain atau VIP. |
| B13 | Batas jumlah perangkat tidak mengendalikan akun Google yang dipakai pada browser/perangkat lain | Tentukan apakah batas hanya berlaku di aplikasi. Jangan menjanjikan satu-perangkat menyeluruh untuk situs Google. Cookie/session key perangkat lain tidak boleh diambil atau dicabut paksa untuk meniru DRM. |
| B14 | Satu HP dipakai beberapa orang, atau satu lisensi mempunyai email penerima berbeda dari akun WebView | Profile menunjukkan lisensi/perangkat dan email tujuan, tidak mengaku itu identitas Google aktif. Peralihan binding harus eksplisit; pembatalan/mismatch tidak menghapus cookie. Pisahkan catatan/chat lokal antar-owner sesuai scope yang dapat dibuktikan. |
| B15 | Email recovery hilang/berganti, alamat pihak ketiga didaur ulang, device hilang | Siapkan recovery admin dengan bukti independen yang memadai, notifikasi perubahan, audit, dan proses pencabutan perangkat hilang. Bukti menerima email tidak selalu cukup untuk semua hak lama; jangan otomatis mengambil alih semua akun/VIP yang alamatnya cocok. |
| B16 | Ketergantungan online, refresh gagal, jam perangkat dimundurkan | Waktu server menentukan expiry. Cache boleh menampilkan status terakhir dengan waktunya; jangan menambah hak atau menganggap timeout=expired/ready. Kebijakan lease/offline harus eksplisit, termasuk batas pencabutan; native client tidak dapat menjamin pemutusan chat provider yang sudah terbuka. |
| B17 | Google masih bisa menolak WebView, meminta passkey/2FA/recovery, atau pengguna mencapai batas layanan | Tetap lakukan hardening origin/bridge/iOS cookie-store. Uji penerimaan provider terpisah dari lisensi. Jika embedded ditolak, jangan memaksa login berulang atau membersihkan cookie; tampilkan bantuan dan batas dukungan. Kelulusan satu akun bukan jaminan semua akun. |
| B18 | Notebook privat mempunyai kapasitas berbagi dan sumber tetap dapat diakses viewer | Audit kapasitas notebook/replica, writer aktif, dan antrean sebelum menerima aktivasi baru. UI yang menyembunyikan panel bukan batas kerahasiaan: Google menjelaskan viewer dapat mengakses sumber. Jangan menjanjikan sumber tak dapat ditemukan hanya karena elemen disembunyikan. |
| B19 | Kebijakan satu bulan owner menyebut 30 hari; kode mempunyai addCalendarMonthsClamped (`functions/src/index.ts:158–166,1120–1127`) | Tetapkan kontrak durasi/awal masa akses dan representasi UTC yang konsisten dengan janji penjualan/aturan owner. Jangan mengubah expiry lama/revoke massal saat migrasi. Aktivasi terlambat dan bulan 28/29/31 hari wajib masuk uji. |
| B20 | Prinsip secure storage/App Check terlalu mudah dianggap anti-pembajakan absolut | App Check bukan bukti pembayaran/manusia; perangkat kompromi masih bisa memakai key. Tetapkan threat model, tingkat dukungan per OS, observasi anti-abuse, serta prosedur pemulihan. Jangan mengecualikan perangkat pelanggan secara diam-diam karena attestation lebih ketat. |

## 4. Model revisi minimum

Pisahkan lima tanggung jawab server:

1. **Pemilik hak yang tahan lama:** referensi transaksi/grant/VIP lama dan bukti penerima yang sah. Tidak bergantung pada hidupnya UID instalasi.
2. **Hak paket:** modul, sumber transaksi/owner grant, masa berlaku, status, dan revisi. VIP tetap prioritas dan tidak diubah menjadi transaksi nol rupiah.
3. **Instalasi:** public key, status binding, versi, dan kemampuan platform yang dibuktikan; bukan identitas Google manusia.
4. **Sesi perangkat:** izin terbatas membaca projection paket, membuat/memeriksa order perangkat yang diotorisasi, serta resolve modul. Tidak boleh otomatis membaca atau menghapus profil owner.
5. **Permintaan aktivasi/pemulihan:** token/request sekali pakai, tujuan instalasi, bukti kepemilikan, expiry, konsumsi atomik, dan audit perubahan.

Worker Google harus memahami hubungan owner → penerima akses → grant → assignment. Pemindahan perangkat mengubah binding, bukan menambah masa langganan atau mengganti pemilik ledger. Renewal menambah grant yang benar satu kali; refund merekonsiliasi grant terkait dan menghormati grant lain/VIP.

Pemeriksaan kesiapan dibuat berlapis: payment verified → beneficiary verified → license active → membership ready → Google session usable. Status unknown/pending/error pada satu lapis tidak boleh diubah menjadi aktif/expired pada lapis lain.

## 5. Koreksi perjalanan pengguna

- Pengguna boleh masuk katalog tanpa Google OAuth aplikasi. Saat membuka AI, satu login Google dilakukan di WebView bila diperlukan.
- Sebelum pembayaran pertama, sedapat mungkin periksa kompatibilitas WebView/akun Google untuk menghindari menerima pembayaran dari lingkungan yang jelas tidak didukung. Pemeriksaan ini tidak menyatakan semua modul pasti siap; tetap perlu verifikasi akses modul sesudah provisioning.
- Konfirmasi email tujuan akses harus memiliki bukti yang sah. Ini dapat menambah aktivasi email sekali; jangan menjualnya sebagai nol langkah verifikasi. Pembelian dari instalasi yang sama hanya bisa otomatis aktif setelah semua prasyarat yang diperlukan terpenuhi.
- Pelanggan yang masih mempunyai sesi lama dapat memperoleh binding baru berdasarkan sesi yang diverifikasi. Pelanggan tanpa sesi melakukan recovery; VIP memakai bukti/otorisasi owner yang dilindungi.
- Hapus akun, lepas perangkat, keluar Google, dan refund harus menjadi tindakan berbeda. Jangan menjadikan pemulihan login alasan menghapus seluruh akun atau menghidupkan kembali data yang sengaja dihapus.
- Tujuan produk tetap WebView dan tampilan internal OpenTurath, Midtrans, dan satu Google login untuk situs AI. Penyederhanaan UI tidak boleh menutupi siapa yang memproses data atau menampilkan halaman keamanan Google sebagai formulir OpenTurath.

## 6. Skenario wajib dan bukti penutupan temuan

Semua skenario berikut adalah **rencana penerimaan; belum dijalankan** pada arsitektur baru karena implementasinya belum ada.

| Kelompok | Skenario yang harus lulus |
|---|---|
| Identitas/otorisasi | Device principal tidak dapat membaca profil/transaksi/bookmark owner; email input/DOM/invoice diketahui tidak mengeluarkan lisensi; UID lama tetap benar; anonymous user dihapus tidak mencabut pelanggan. |
| Pembayaran | Paid/refund/partial refund/duplicate/out-of-order; pembayaran ditutup sebelum callback; pergantian perangkat saat pending; invoice hilang owner; perpanjangan paralel; renewal/refund tidak memengaruhi modul atau grant lain. |
| Recovery | Request korban dipicu penyerang; email scanner; GET; link forward; beda perangkat; token expired/replay/dua redeem paralel; key berbeda; request diganti; email tidak tersedia; recovery VIP. |
| Storage | Preferences disalin; key hilang; cloud backup/D2D; reinstall; Keychain ditolak; upgrade signed/ad-hoc; Windows profile dir berubah; device lock/root/attestation tidak didukung; key rotation dan revoke lama. |
| Google/provider | Akun A/B mismatch; 2FA/passkey; recovery opsional/wajib; Google rejected; invitation pending; notebook penuh; sumber terlihat dari luar app; revoke ACL gagal; quota Google; perubahan DOM. |
| Migrasi/UX | V1 dan V2 hidup bersamaan dengan satu writer grant; rollback tidak menghapus sesi/grant; catatan lama tetap tersedia sesuai hak; device loss bukan refund/delete; status paket/koneksi tidak tertukar. |
| Integritas room | Sampel readiness ≥4, elapsed ≥3000ms, jeda 250ms; error full viewport; ≥5 tab macOS tanpa eviction senyap; CSS/clean() yang dilindungi tetap benar. |

## 7. Urutan aman sebelum eksekusi produk

1. Tutup kontrak owner/beneficiary/device, recovery, durasi, penghapusan, offline, dan batas perangkat. Catat keputusan yang belum disepakati; jangan mengisi kekosongan dengan asumsi klien.
2. Selesaikan rancangan secure storage per OS dan migrasi macOS; jangan membangun lisensi di atas fallback yang sudah melemahkan Keychain.
3. Susun spesifikasi V2 terpisah untuk otorisasi, projection profil, worker, dan lifecycle. Pertahankan endpoint V1 serta hak historis.
4. Uji model/kontrak dengan fixture dan negative authorization tests sebelum menghubungkan pembayaran/Google nyata. Tidak perlu menyentuh akun pelanggan/VIP.
5. Setelah desain disetujui, buktikan prototipe terbatas: pembayaran sandbox → aktivasi terverifikasi → worker siap → login Google tunggal → jawaban AI → restart → recovery. Uji penolakan Google sebagai kasus terpisah.
6. Hanya setelah itu tentukan rollout terbatas, observasi, dan rollback. Tidak ada rilis otomatis dari build atau dari kelulusan unit test.

**Go/no-go:** belum boleh rollout arsitektur ini sekarang. Boleh dilanjutkan ke penyempurnaan spesifikasi; implementasi produksi menunggu penutupan penghalang desain dan persetujuan. Jika provider tetap menolak WebView pada platform yang dijanjikan, masalah itu tetap penghalang dukungan walaupun semua uji lisensi lulus.

## 8. Sumber dan batas bukti

- Firebase anonymous temporary/cleanup: https://firebase.google.com/docs/auth/android/anonymous-auth
- Firebase email-link security/Hosting: https://firebase.google.com/docs/auth/flutter/email-link-auth
- Firebase App Check: https://firebase.google.com/docs/app-check
- Midtrans webhook dan status: https://docs.midtrans.com/docs/https-notification-webhooks dan https://docs.midtrans.com/reference/get-transaction-status
- Android backup/transfer: https://developer.android.com/identity/data/autobackup
- Android Keystore dan batas perangkat kompromi: https://developer.android.com/privacy-and-security/keystore
- Recovery token principles: https://cheatsheetseries.owasp.org/cheatsheets/Forgot_Password_Cheat_Sheet.html
- Google sharing, viewer/source access dan batas notebook: https://support.google.com/notebooklm/answer/16206563?hl=en
- Google OAuth policy: https://developers.google.com/identity/protocols/oauth2/policies

Tidak membaca rahasia sesi/cookie pengguna, mengubah layanan cloud, memeriksa deployment aktif, menjalankan transaksi, mencabut akses, atau menghapus akun. Patch dependency lokal membuktikan jalur sumber, bukan paket distribusi mana yang pernah terpasang. Tidak ada pengujian runtime baru atau klaim nol risiko. Peraturan historis VIP/hold dari memori digunakan sebagai konteks; status worker/revocation produksi terkini belum diverifikasi.
