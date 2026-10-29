# Laporan Masalah OpenTurath AI untuk Audit oleh AI Baru

Disusun 29 Oktober 2026 (sesi Claude Code, repositori `/Users/apple/Downloads/ramadhan`, cabang `v9-2-integrasi`).
Tujuan: menyerahkan seluruh masalah yang sedang dihadapi, beserta konteks, bukti, status perbaikan, dan hal yang
belum terbukti, kepada AI lain agar mengaudit ulang dari nol dan menantang kesimpulan kami.

**Cara membaca dokumen ini.** Setiap klaim diberi tingkat keyakinan:
- **[TERBUKTI]** diperiksa langsung pada data produksi atau kode, dengan bukti di bagian terkait.
- **[HIPOTESIS]** masuk akal berdasarkan kode/arsitektur, belum diuji.
- **[BELUM DIPERIKSA]** diketahui ada, tetapi belum dilihat.
Jangan menganggap [HIPOTESIS] sebagai fakta. Kami sengaja menandainya.

---

## 0. Instruksi untuk AI pengaudit

1. Baca dulu bagian 1 (aturan wajib), bagian 2 (konteks), lalu bagian 3 (peta masalah).
2. Verifikasi ulang temuan [TERBUKTI] secara independen sebelum memercayainya. Data yang dipakai ada di Firestore
   proyek `open-turath` (baca-saja, cara akses di bagian 11).
3. Fokus utama audit: **mengapa pengguna berbayar mengalami kegagalan akses dan login**, padahal di era GoAkal otomasinya
   "tidak pernah bermasalah" (klaim pemilik). Cari akar masalah, bukan gejala.
4. Cari **blind spot** kami. Daftar blind spot yang kami tahu ada di bagian 9, tetapi kami yakin masih ada yang tidak kami
   ketahui.
5. **Jangan** merilis aplikasi, menyiarkan update, men-deploy Functions, atau mengubah konfigurasi produksi tanpa perintah
   eksplisit pemilik. Jangan mencabut akses siapa pun (aturan VIP, bagian 1).

---

## 1. Aturan wajib proyek (dari `AGENTS.md`, mengikat siapa pun yang bekerja di sini)

| # | Aturan | Isi singkat |
|---|---|---|
| 1 | Checkpoint otomatis | Setiap perubahan berkas langsung di-`git add` dan di-commit dengan pesan terstruktur `type(scope): pesan`. |
| 2 | Integritas build | Rilis APK harus lulus kompilasi penuh dan menyalin `app-release-latest.apk` ber-timestamp baru. |
| 3 | Build lokal ≠ rilis publik | `flutter build apk --release` hanya lokal. **DILARANG** mengunggah ke CDN/Hosting atau menyiarkan versi ke Firestore `app_config/version` kecuali pemilik memerintah eksplisit ("updatein", "rilis update sekarang"). `publish_auto_update.py` hanya atas perintah itu. |
| 4 | WebView | **DILARANG** mengubah siklus hidup WebView di `lib/widgets/agent_multi_tab_room.dart` dan `desktop_webview_runtime.dart`. Polling kesiapan sesi NotebookLM minimal 4 sampel berturut-turut, ≥3000 ms, jeda mikro 250 ms. Tampilan galat harus menggantikan seluruh viewport WebView. |
| 5 | VIP sakral | Akun `STATIC_WHITELIST`, `is_vip:true`, `role:"vip"`, dokumen `VIP_PERMANENT` adalah hak mutlak pemilik. **DILARANG** meragukan, menganggap kesalahan, atau mencabutnya. Hak akses dievaluasi independen per modul. Webhook/sinkronisasi tidak boleh menambah durasi berulang tanpa `transaction_id` unik; transaksi `amount: 0.0` tidak memperpanjang otomatis. Reaper harus memantau Master Notebook `01 - FIKIH SYAFII (MASTER)` (`c89d09ca-…`). |
| 6 | Tampilan WebView Syafi'i | Teks rapat ke bawah bilah tab (0 px celah), header Google/NotebookLM dihilangkan dengan CSS dimensi nol, komposer input `.ot-chat-composer` terpasang in-flow, bukan `position: fixed`. Panggil `clean()` tiap pergantian tab. |
| 7 | Multi-tab | Desktop wajib mengizinkan minimal 5 tab (`maxTabs = 5`); dilarang menutup tab pengguna diam-diam. |
| 8 | Sesi Google | **DILARANG** menimpa token sesi Google di WebKit (`__Secure-1PSIDTS`, `SID`, `HSID`, dst.) dengan atribut buatan. `deleteAllCookies`/`clearSession` hanya saat pengguna menekan Log Out. |
| 9 | Desain monokrom | Hitam-putih (#09090B, #18181B, #27272A, #FAFAFA). Satu-satunya pengecualian: banner hitung mundur promo `PromoCountdownBanner` berwarna merah `OTColors.errorLight`. |

Catatan perilaku pemilik: peringatan biaya sesi diabaikan; tindakan berisiko tetap butuh izin.
Dokumen rujukan lain di repo: `openturath_ai/docs/STANDAR_IDEAL_WEBVIEW.md`, `DOKUMENTASI_KECACATAN_SISTEM_DAN_ATURAN_VIP.md`,
`openturath_ai/ARCHITECTURE.md`, `docs/STRATEGI_AKUN_KHUSUS_NOTEBOOKLM.md`.

---

## 2. Konteks produk dan arsitektur

### 2.1 Produk
OpenTurath AI: aplikasi untuk penuntut ilmu syar'i. AI menjawab dari kitab turath dengan ibarah Arab dan rujukan.
Per bidang ilmu (Fikih Syafi'i, Hadis, Tafsir, dll.), Fikih Tahawwulat eksklusif dengan lima asisten
(Al-Bayan, Al-Muhaqqiq, Al-Mukhtabir, Al-Habib, Al-Khatib). Rilis publik 26 Oktober 2026. Trial 7 hari. Harga mulai Rp 49.000/bulan
(AI per bidang) dan Rp 299.000/bulan (Tahawwulat). "Jawaban AI" sebenarnya adalah **NotebookLM milik Google**: setiap bidang ilmu
adalah sebuah notebook NotebookLM yang **dibagikan (viewer, chat-only)** ke email pengguna berbayar. Aplikasi menampilkan notebook itu
dalam WebView.

### 2.2 Stack
- Aplikasi: Flutter (Android, iOS, macOS, Windows, web). Versi saat ini `1.0.85+86`.
- Backend: Firebase proyek **`open-turath`** (nomor 255541559800). Cloud Functions Gen1, Node/TypeScript
  (`openturath_ai/functions/src`), runtime **nodejs20** (**dihentikan 2026-10-30**, lihat M-12), region `us-central1`.
- Basis data: Firestore. Auth: Firebase Auth (Google).
- Pembayaran: **Midtrans Snap (produksi)**. (GoAkal dihentikan 22 Oktober 2026.)
- Otomasi pemberian akses: **worker Node di VPS** (`access_worker.js`) + adapter Python `verified_sharing.py` + pustaka
  `notebooklm-py 0.8.0a3` (di folder `ecosystem/openturath_subscription`). Service Cloud Run `openturath-subscription`
  (asia-southeast2) adalah server generasi lama.
- Telemetri: Telegram (kanal `sales` dan `alert`), bot pemilik `@openturath_bot` di VPS.

### 2.3 Dua generasi otomasi (inti pertanyaan pemilik)
| | Era GoAkal | Sekarang ("vps-v2") |
|---|---|---|
| Pembayaran + pelanggan | GoAkal | Midtrans + ledger Firestore v2 |
| Pemberi akses | `webhook_server.py` (Cloud Run) → `notebooklm_manager.py` | worker VPS → `verified_sharing.py` |
| Sesi Google | **Menyembuhkan diri**: `_ensure_fresh_cookies()` membuat cookie baru dari `master_token.json` bila sesi kedaluwarsa | **Statis**: `storage_state.json` dikirim manual dari laptop (`deploy/push_session.sh`); adapter "never mints Google credentials" |
| Titik gagal | Sedikit | Banyak mata rantai |

Pemilik menyatakan: di era GoAkal "tidak ada masalah sama sekali dengan otomatisasi", dan sistem laptop dengan master token
"selalu berhasil". **Ini klaim pemilik, belum kami verifikasi dengan data historis.**

### 2.4 Rantai setelah pembayaran (sekarang)
```
Midtrans settlement → midtransWebhook → processSuccessfulPayment (index.ts ~1025)
  → users/{uid}: entitlements + access_due_ms = sekarang
  → worker VPS: siklus 15 s membuat access_jobs; job dijalankan tiap 1 s
  → verified_sharing.py → NotebookLM sharing.add_user
  → access_assignments.status = "ready" (+ verified_ms)
  → getAgentUrl → AccessControl.resolve() → URL notebook → aplikasi (validasi regex UUID)
```
Jaring pengaman: `reconcileMidtransPayments` (tiap 1 menit), `monitorAccessHealth` (tiap 1 menit),
`processProvisioningOutbox` (tiap 5 menit, diam bila `writer == vps-v2`).

### 2.5 Koleksi Firestore penting
`users`, `transactions`, `redeem_codes` (+ subkoleksi `redemptions/{uid}`), `device_redemptions` (kunci `dev_<deviceId>_<promoFamily>`),
`trial_claims`, `rate_limits`, `provisioning_outbox`, `access_grants`, `access_jobs`, `access_assignments`, `access_notebooks`,
`access_memberships`, `access_identities`, `access_reviews`, `access_legacy_owners`, `access_legacy_events`, `access_vip_registry`,
`access_control/{runtime,heartbeat,monitor_health,payment_heartbeat,monitor,security,writer_lease}`, `webhook_events`,
`payment_receipts`, `payment_reconciliation`, `client_error_logs`, **baru:** `auth_failure_stats`, `paid_access_alerts`, `payment_audit`.

### 2.6 Penanda status ledger
- `access_control/runtime.writer == "vps-v2"` berarti worker VPS satu-satunya penulis. Saat ini **aktif**.
- `users.access_version == 2` berarti akun dievaluasi lewat ledger; `access_revocation_hold`/`access_legacy_audit_required` menahan akun legacy.
- `revocations_paused` saat ini **false**; `revocation_hourly_limit: 10`.

---

## 3. Peta masalah (ikhtisar)

| ID | Masalah | Keyakinan | Status |
|---|---|---|---|
| M-01 | Login Google gagal di Windows | HIPOTESIS kuat (belum diuji token asli) | Alat diagnosis dibangun; **perbaikan akar belum** |
| M-02 | Voucher: "sudah digunakan di perangkat ini" padahal belum | TERBUKTI dari kode | Diperbaiki + **di-deploy** |
| M-03 | Layar "akses sedang disiapkan" tak pernah tahu siap (ledger v2) | TERBUKTI dari kode | Diperbaiki + **di-deploy** |
| M-04 | Pengguna berbayar "tidak diberi akses" | Sebagian terbukti, sebab utama belum pasti | Pemantau + alarm di-deploy |
| M-05 | "AI belum bisa dihubungkan. Coba lagi." | TERBUKTI penyamarataan pesan | Diperbaiki di aplikasi, **belum dirilis** |
| M-06 | Halaman bayar berhenti tanpa pesan (allowlist WebView) | TERBUKTI celah; dampak belum terukur | Diperbaiki di aplikasi, **belum dirilis** |
| M-07 | Banyak percobaan bayar tak pernah sampai Midtrans (65 dari 92) | TERBUKTI jumlah; sebab BELUM tahu | Terbuka |
| M-08 | Telemetri buta (login gagal tak bisa tercatat) | TERBUKTI | Endpoint tanpa-login di-deploy; klien belum dirilis |
| M-09 | Ketergantungan sesi Google statis di VPS | TERBUKTI desain; kegagalan nyata belum terjadi | Rencana (cara 1/2), **belum dibangun penuh** |
| M-10 | Risiko tabrakan penulis (laptop vs VPS) | TERBUKTI di kode | Lease + penjaga **di-commit, belum dipasang** |
| M-11 | Keepalive Cloud Run selalu 401 | TERBUKTI | **Belum diperbaiki** |
| M-12 | Runtime Node 20 dihentikan 2026-10-30 | TERBUKTI (peringatan Firebase) | **Belum dikerjakan** |
| M-13 | Akun legacy tertahan / satu akun berhak tanpa penugasan | TERBUKTI | Terbuka (butuh keputusan pemilik) |
| M-14 | Entri outbox/job macet permanen | TERBUKTI | Terbuka |
| M-15 | `healthy_until_ms` 286 dari 632 notebook kedaluwarsa | TERBUKTI data; dampak belum jelas | Terbuka |
| M-16 | Pembayar Rp 1.499.000 memiliki `access_revocation_hold` dan review | TERBUKTI data | Terbuka (jangan cabut) |
| M-17 | OTA / pembaruan aplikasi (beberapa keputusan menggantung) | TERBUKTI | Sebagian dikerjakan |
| M-18 | Situs Manuskrip belum dipublikasikan | n/a | Menunggu persetujuan |

---

## 4. Rincian masalah

### M-01 Login Google di Windows gagal
**Gejala.** Layar login Windows menampilkan "Gagal masuk dengan Google. Coba lagi." (`copy_catalog.dart:640`, kunci `googleSignInFailed`).
Pemilik melaporkan "Windows tidak bisa login sama sekali".

**Konteks teknis.**
- Alur Windows sejak commit `c1fae977` (28 Okt): OAuth 2.0 code + PKCE dengan redirect loopback
  `http://127.0.0.1:<port>/oauth2callback` (`lib/services/desktop_auth_gateway.dart`), klien OAuth jenis **Desktop**
  (`lib/core/desktop_oauth_config.dart`). Token ditukar di `oauth2.googleapis.com/token`, lalu
  `FirebaseAuth.signInWithCredential(GoogleAuthProvider.credential(idToken, accessToken))` (`auth_service.dart:199-212`).
- Penyedia Google di Firebase (`defaultSupportedIdpConfigs/google.com`): `clientId` = klien **Web** (`…jcip3mf8…`),
  **tanpa `whitelistedAudiences`**. ID token yang diterbitkan untuk klien Desktop (`…vlqgf0…`) berbeda audiens.
- Versi sebelumnya: `2d5ce26d` "login Google Windows mengirim token Google asli, bukan token ID Firebase"; `47f0bec1` (22 Okt) implementasi awal.
- Semua galat diubah menjadi satu pesan generik (`login_error_message.dart`), sehingga sebab asli tersembunyi.
- Firestore rules `client_error_logs` mensyaratkan `request.auth != null` (`firestore.rules:56`), jadi **kegagalan login tidak dapat
  direkam** (pengguna belum login). Koleksi hanya berisi 1 dokumen.

**Status keyakinan.** [HIPOTESIS] Firebase menolak token karena audiens klien Desktop tidak terdaftar. Alternatif yang belum disingkirkan:
pembatasan API key, galat di langkah `profile-resolve` setelah login, firewall/antivirus pada loopback, layar persetujuan OAuth berstatus Testing.
Pada pemeriksaan tidak ada token Google asli untuk menguji.

**Yang sudah dilakukan.** Endpoint publik `reportAuthFailure` (di-deploy) menerima hanya kode tetap
(`platform, stage, code, category, appVersion`, pola `[a-zA-Z0-9_.:-]{1,80}`, batas 20/jam/IP) ke `auth_failure_stats`
+ Telegram. Klien melaporkan lewat `lib/services/auth_failure_reporter.dart` dan menampilkan kode singkat pada pesan galat
(mis. "(invalid-credential)"). **Efektif hanya setelah build baru dirilis.**

**Yang belum.** Perbaikan akar (mendaftarkan klien Desktop sebagai audiens Firebase, atau mengubah alur), karena butuh kode galat nyata
dan perubahan konfigurasi Firebase (izin pemilik).

**Tugas audit.** Buktikan penyebab sebenarnya. Cara: bangun/jalankan build Windows, lakukan login, baca `auth_failure_stats` atau log lokal
(`OpenTurathAuth stage=… code=…`). Periksa pembatasan API key Firebase (Windows tanpa referrer/paket), status layar persetujuan OAuth,
dan apakah klien Desktop berada di proyek yang sama.

### M-02 Voucher: "sudah digunakan di perangkat ini"
**Gejala.** Sebagian pengguna belum memakai kode tetapi mendapat penolakan perangkat dan tidak bisa memakai trial.

**Akar [TERBUKTI dari kode `redeemCode`, `index.ts` ±1864].**
1. Pemeriksaan perangkat (`device_redemptions`, kunci `dev_<deviceId>_<promoFamily>`) dilakukan **sebelum** pemeriksaan "akun ini sudah menukar kode ini".
2. Semua kode trial berbagi satu keluarga `trial_default` (kecuali `PERDANA`), jadi satu perangkat hanya dapat mengklaim **satu trial apa pun kodenya**.
3. ID perangkat dari klien (ANDROID_ID/UA web) dapat bertabrakan antar pengguna.
4. Akun yang sama yang mengulang klaim dituduh "perangkat sudah dipakai".
5. Batas laju 8 percobaan/15 menit per akun (`rdm_<uid>`).

**Data [TERBUKTI].** `redeem_codes`: 4 dokumen; `TURATH7` (21 terpakai dari 1.000.000, aktif); `trial_claims`: 21;
semua `device_redemptions` sebelumnya terhubung ke pengguna dengan hak (22 dengan, 0 tanpa) sehingga data tidak menunjukkan klaim hantu;
indikasi tabrakan perangkat lintas akun tidak dapat dikesampingkan.

**Perbaikan (commit `b1b14ac3`, di-deploy 29 Okt).** Akun yang sama mendengar "Kode ini sudah aktif di akun Anda"; kalau perangkat dipakai akun
lain, pesan menyebut dua huruf awal akun (`bu***`). Tes: `functions/test/redeem_voucher.test.ts`.

**Tersisa [HIPOTESIS].** Tabrakan ID perangkat antar pengguna sebenarnya tetap menolak pengguna sah; kebijakan satu-trial-per-perangkat
perlu ditinjau ulang (sudah ada `trial_claims` per email).

### M-03 Layar "akses sedang disiapkan" tidak pernah menyatakan siap
**Akar [TERBUKTI].** `getAccessReadiness` menganggap siap hanya jika status outbox `completed`. Pada ledger v2 status outbox berhenti di
`v2_handed_off` (215 entri), tidak pernah `completed`. `AccessPrepareGate` (aplikasi) selalu menunggu penuh 30 detik lalu melepas pengguna,
mungkin sebelum notebook siap.

**Perbaikan (commit `8528dbbc`, di-deploy).** Pada `writer == vps-v2`, kesiapan = setiap kajian dalam paket (`ledgerScopesReady`) punya penugasan
`ready` dengan `verified_ms`. Tes ledger-v2 di `paid_without_access.test.ts`.

### M-04 Pembayar berbayar "tidak diberi akses"
**Bukti [TERBUKTI, data 29 Okt].**
- 7 transaksi `paid` (6 `settlement` di Midtrans + 1 transfer manual BSI). Semua pembelinya memiliki hak dan penugasan `ready`/terverifikasi.
- Satu pembeli diaktifkan ±16 jam terlambat lewat `payment_auto_heal`.
- Pembeli Rp 1.499.000 (akun `sai***`, tx `Vp0Iu7…`, 10 Okt–29 Okt): `access_revocation_hold: true`, 5 job `superseded`, review
  `legacy_payment_evidence_incomplete`, outbox `v2_review`. Kelima penugasan Tahawwulat **`ready`** (jadi server menyatakan siap). Penyebab keluhannya belum terkonfirmasi.
- Tidak ada pembayaran lunas di Midtrans yang hilang (lihat M-07).

**Hipotesis [HIPOTESIS].** Keluhan bersumber dari kombinasi M-03, M-05, M-06, keterlambatan worker (M-09), dan akun legacy (M-13), ditambah orang yang sebenarnya
tidak menyelesaikan pembayaran.

**Yang dibangun (di-deploy).** `monitorPaidWithoutAccess` (tiap 2 menit): transaksi `paid` >3 menit tanpa penugasan `ready` → `users.{uid}.access_due_ms = now`
+ alarm Telegram sekali per transaksi (`paid_access_alerts`). Belum teruji di produksi (hanya tes otomatis).

### M-05 "AI belum bisa dihubungkan. Coba lagi."
**Akar [TERBUKTI].** `agent_multi_tab_room.dart` (~1489) mengganti hampir semua galat `getAgentUrl` dengan satu kalimat, hanya `failed-precondition`
yang menampilkan pesan server. Sumber galat sebenarnya: batas laju (`agent_url_<uid>` 60/60 s), App Check, timeout, `AccessFault` (`resolve()`:
"Akses notebook sedang disiapkan…", "Notebook sedang diperiksa…"), jalur legacy `resolveObservedLegacy` ("Hak akses lama sedang dicocokkan…").
**Perbaikan (`491106a7`):** pesan server untuk `resource-exhausted/unavailable/deadline-exceeded`, kode singkat pada pesan generik. Hanya perubahan teks galat, bukan siklus hidup WebView.
**Belum dirilis.**

**Data [TERBUKTI].** Dari 1.260 penugasan `ready`, semua menunjuk notebook aktif, non-publik, terverifikasi → `resolve()` tidak seharusnya gagal untuk mereka. Log Functions (6 jam terakhir): `getAgentUrl` 31× HTTP 200, 2× 400.

### M-06 Halaman bayar berhenti tanpa pesan
**Akar [TERBUKTI di kode].** Allowlist tujuan navigasi WebView pembayaran (`payment_checkout_sheet.dart`) memakai `endsWith('.bca.co.id')`, tidak cocok dengan apex
`bca.co.id`, dan tidak memuat BSI, KlikBCA, Danamon, Shopee, Akulaku, Kredivo. Navigasi ditolak **diam-diam** (hanya `debugPrint`).
**Perbaikan (`4fad7ef3`):** `lib/core/payment_destination_policy.dart` (apex + subdomain, domain tambahan) dan SnackBar "Buka di peramban".
Domain tiruan tetap ditolak (tes). **Belum dirilis.** Dampak aktual terhadap angka berhenti bayar **belum terukur** [BELUM DIPERIKSA].

### M-07 65 dari 92 percobaan bayar tak pernah sampai Midtrans
**Data [TERBUKTI].** Audit baca-saja ke API Midtrans atas 92 transaksi `gateway=midtrans`:
| Status lokal | Status Midtrans | Jumlah |
|---|---|---|
| paid | settlement | 6 |
| paid | 404 (transfer manual) | 1 |
| expire | expire | 20 |
| abandoned | 404 | 46 |
| pending | 404 | 19 |
- Selisih "lunas di Midtrans, belum lunas lokal": **0**.
- 404 berarti Midtrans tidak pernah melihat percobaan pembayaran untuk sesi Snap itu.
- 39 pengguna; 33 tidak pernah membayar; 17 mengulang percobaan (maks 10 percobaan oleh satu akun). Sebagian jelas pengujian internal (mis. nominal 1.000/50.000/300.000, "M Fulan").
- Harian: 27 Okt (hari rilis) 28 abandoned, 5 expire, 2 paid; 29 Okt 2 paid, 10 pending, 3 expire.
- Definisi `abandoned`: `reconcileOne` (`index.ts` ~1274-1290) menandai setelah `ABANDON_AFTER_MS` bila Midtrans mengembalikan 404.
**Sebab berhentinya [BELUM TAHU].** Kandidat: M-06, kerumitan pilihan metode, harga, ragu, pengujian internal.
**Perubahan pencegah:** `auditMidtransLedger` (di-deploy), harian 02:15 WIB, laporan selisih ke Telegram dan `payment_audit/{tanggal}`; tidak mengubah apa pun.

### M-08 Telemetri buta
Lihat M-01. Tambahan [TERBUKTI]: log Cloud Functions hanya menyimpan ±6 jam; galat `HttpsError` tidak tercatat sebagai ERROR; `client_error_logs` hanya 1 dokumen.
Perlu mekanisme pelaporan galat yang bertahan dan tidak bergantung pada login untuk kegagalan pra-login (sudah dibuat untuk login saja).

### M-09 Sesi Google statis di VPS
**Fakta [TERBUKTI].** Worker memakai `storage_state.json` (cookie `SID`/`__Secure-1PSID` kedaluwarsa 2028; `__Secure-1PSIDTS` sampai Sep 2027; berkas dibuat 24 Sep 2026).
`refreshConsentedSession()` mencoba `notebooklm login --browser-cookies chrome` di VPS yang **tidak punya browser** → pada praktiknya gagal. Pemulihan
bergantung pada operator menjalankan `push_session.sh` dari laptop. Heartbeat: `session_refreshes: 0`. `master_token.json` dibuat 11 Juli 2026, **validitas tidak pernah diuji**.
Pustaka sendiri memperingatkan master token = akses penuh seluruh akun, durable, "infostealer-grade", gunakan akun khusus.
**Keadaan terakhir [TERBUKTI].** Worker sehat saat diperiksa: heartbeat 0,2 menit, 4.129 siklus, 4.168 panggilan, ±50 gagal (1,2%), tanpa `authentication_error`.
**Pilihan:** cara 1 (akun khusus + master token di VPS, lihat `docs/STRATEGI_AKUN_KHUSUS_NOTEBOOKLM.md`) atau cara 2 (token di laptop, sesi dikirim berkala).
**Keputusan pemilik 29 Okt: cara 2.** Skrip penyegaran otomatis cara 2 **belum dibuat** (perintah pembuatan sesi dari master token belum diverifikasi).

### M-10 Risiko tabrakan penulis
**Temuan [TERBUKTI di kode].** `notebooklm_manager.py` (dipakai `manual_sync.py`), `run_reaper_daemon.py`, `clone_master_notebook.py` tidak memeriksa `writer == vps-v2`
(reaper memeriksa lewat `autonomous_reaper.py:423`; `webhook_server.py` memeriksa). Worker VPS menjalankan `engine.repair` yang menghapus anggota yang tidak ada di ledger,
sehingga penulisan manual dari laptop bisa dihapus, dan reaper laptop bisa mencabut. Worker tidak punya penjaga satu-instance.
**Perbaikan (commit `0f2f86d8`, di-commit saja, belum dipasang di VPS):** `functions/src/worker_lease.ts` (sewa `access_control/writer_lease`, primary VPS, standby laptop,
masa tenggang 120 detik, keyakinan lokal 20 detik) + gating pada `runJobs`, `reconcile`, `cycle`; `writer_guard.py` fail-closed pada `add_viewer/remove_viewer`.
6 tes lease + 4 tes Python. **Aman diaktifkan hanya setelah worker VPS dipasang ulang** (`deploy/build_release.sh` + `install_release.sh`).
Perhatian: celah ≤20 detik saat pemindahan pemegang; operasi per-job tetap transaksional.

### M-11 Keepalive Cloud Run 401
Scheduler `openturath-keepalive` (asia-southeast2) memanggil `GET https://openturath-subscription-255541559800.asia-southeast2.run.app/keepalive`
dan selalu mendapat 401 (6 dari 6 sejak 07:00 29 Okt). Layanan ini menerima `/webhook` dari Functions (`notifySubscriptionServer`, `index.ts` ~2838), dan
`/cron/reap` (200). Pada `writer = vps-v2` jalur ini sebagian besar diam, sehingga dampak sekarang kecil [HIPOTESIS]. **Belum diperbaiki** (perubahan infrastruktur butuh izin).

### M-12 Runtime Node.js 20 dihentikan 2026-10-30
Peringatan Firebase saat deploy: setelah 2026-10-30 tidak bisa deploy tanpa upgrade. Fungsi yang berjalan tidak terpengaruh. `firebase.json` memakai
`"runtime": "nodejs20"`; `firebase-functions` juga usang. Mengingat tes memerlukan Node 22 (flag `--experimental-transform-types` tidak ada di Node 26).
**Belum dikerjakan.**

### M-13 Akun legacy
- 236 entri `v2_signup_*` di outbox berstatus `v2_review` (`legacy_evidence_required`). 196 di antaranya tidak punya hak aktif (wajar); 3 punya `access_version=2` tanpa hak; **1 akun (`fikr***`)
  punya hak aktif Fikih Tahawwulat (bayan/mukhtabir/…) tanpa `access_version`, tanpa penahan, tanpa penugasan `ready`** → kemungkinan "Hak akses lama sedang dicocokkan…".
- Pengguna lama (migrasi GoAkal Okt 2026) mungkin perlu "certify ulang setelah 2027-01-15" (memori proyek).
- 45 penugasan `adopted`; 29 penugasan `provisioning` macet 101-116 jam, **semuanya akun legacy** (bukan pembayar).
**Tugas audit.** Tentukan apakah ada pengguna sah yang terkunci tanpa disadari. **Ingat aturan VIP: jangan mencabut.**

### M-14 Entri macet
`provisioning_outbox`: 231 `v2_review` (225 `v2_signup`; 6 lain: 2 gagal HTTP 500 dari Cloud Run, 2 "Entitlements changed during delivery", 1 `identity_or_billing_review`,
1 voucher `PERDANA` "legacy_evidence_required" ), 215 `v2_handed_off`, 78 `completed`. `access_jobs`: 5 `queued` ("Target membership not verified", lewat tenggat ±17,6 jam),
5 `review_required`, 34 `superseded`. Tidak ada alarm untuk entri yang terjebak.

### M-15 `healthy_until_ms` kedaluwarsa pada 286 notebook
`healthy_until_ms` ditulis `observed + 86400000` oleh `refreshNotebook`. 286 dari 632 sudah lewat; umur maksimum 266 jam. `resolve()` tidak memeriksa kolom ini sehingga tidak langsung merusak,
tetapi menandakan pemeriksa kesehatan (`reconcile`, satu notebook per 15 detik, jadi satu putaran 632 notebook ±2,6 jam, jauh di bawah 24 jam) mungkin tidak berjalan sebagaimana mestinya atau melewati sebagian target.
[HIPOTESIS] perlu diperiksa mengapa 286 tertinggal.

### M-16 Pembayar Rp 1.499.000
Lihat M-04. Jangan cabut. Perlu kejelasan: apakah `access_revocation_hold` memengaruhi pengalaman pengguna dan mengapa transaksi ini masuk `legacy_payment_evidence_incomplete`.

### M-17 OTA dan pembaruan aplikasi
Dikerjakan (commit 1daaa263, c593039e, 3d75e1d3, a2c21e76, c38fd7ae): APK berversi `OpenTurath_v{code}.apk`, edisi Guru terpisah (`editions.guru`), `--dry-run`, `manage_ota.py verify-release`, cek ulang saat aplikasi dibuka.
**Menggantung:** APK Guru terpasang (versionCode 77) masih ditawari build standar 85; entri macOS di Firestore usang (68); Windows tanpa entri; belum ada pemaksaan update via `min_supported_version_code`;
belum ada tes HTTP untuk `UpdateService` (singleton terikat Firebase). Rilis `1.0.85+86` sudah dipublikasikan sebelumnya (`5eafc43f`).

### M-18 Situs Manuskrip (`website/manuskrip`)
Landing page produk lain ("OpenTurath Manuskrip", OCR naskah Arab tulisan tangan). Revisi 29 Okt: hero baru, slider tanpa tab, perbandingan harga di awal, matriks fitur, harga per kata, latar hero artefak naskah (mode terang krem, gelap sepia).
**Belum dipublikasikan.** Angka akurasi ("Bukti terukur") masih "Menunggu uji" — **dilarang diisi karangan**. Izin pemindaian belum.

---

## 5. Kronologi perubahan sesi ini (semua di-commit)

| Commit | Isi |
|---|---|
| `b1b14ac3` | redeem: klaim ulang idempoten, pesan perangkat jelas |
| `3d7f6d81` | `monitorPaidWithoutAccess`, `reportAuthFailure`, indeks Firestore, perbaikan 2 tes lama |
| `491106a7` | klien: pelapor gagal login, pesan galat berkode, sebab nyata di ruang AI |
| `8528dbbc` | `getAccessReadiness` memakai penugasan ledger |
| `0c673136` | `auditMidtransLedger` + indeks |
| `4fad7ef3` | allowlist WebView pembayaran + jalan keluar peramban |
| `0f2f86d8` | sewa penulis tunggal + penjaga skrip lama |
| `404f5111` | `docs/STRATEGI_AKUN_KHUSUS_NOTEBOOKLM.md` |
| sebelumnya hari ini | OTA berversi, Guru, Manuskrip, token guard `language_screen`, dsb. |

### Di-deploy ke produksi (atas izin pemilik)
Functions: `redeemCode`, `getAccessReadiness` (diperbarui); `monitorPaidWithoutAccess`, `reportAuthFailure`, `auditMidtransLedger` (baru). Indeks Firestore:
`transactions(status, paid_at)` dan `transactions(gateway, created_at)`. **Tidak** dirilis: APK/Windows/macOS, `publish_auto_update.py`, siaran ke `app_config/version`.
**Tidak** dipasang: worker VPS baru (lease), skrip penjaga di server mana pun.

### Perubahan yang HANYA ada di kode (menunggu rilis aplikasi)
Pelapor login, pesan galat berkode, ruang AI, allowlist pembayaran. Dibawa oleh build berikutnya.

### Tes
Functions: `/Users/apple/.nvm/versions/node/v22.19.0/bin/node --test --experimental-transform-types openturath_ai/functions/test/*.test.ts` → 252 lulus. (Node 26 default tidak mendukung flag.)
Flutter: `cd openturath_ai && flutter test` → 513 lulus, 6 dilewati. Python: `python3 -m unittest test_writer_guard` di `ecosystem/openturath_subscription`.
Tes dengan lapisan nyata (Firebase/Midtrans/NotebookLM) **tidak ada**; semua memakai `MemoryDB`/stub. Fungsi baru di produksi belum teruji end-to-end.

---

## 6. Data produksi (snapshot 29 Okt 2026, ±siang WIB)

| Besaran | Nilai |
|---|---|
| Transaksi | 517 (Midtrans 92; sisanya GoAkal/lainnya) |
| Pembayaran lunas sejak rilis | 7 |
| Penugasan akses | 1.341 total: 1.260 `ready`, 45 `adopted`, 29 `provisioning` (semua legacy), 5 `revoked`, 2 `transferred` |
| Email unik berpenugasan `ready` | ±73 (79 UID) |
| Notebook | 632 (625 aktif, 7 draining) dalam 24 entitas; batas penerimaan 1.995 / keras 2.000; kursi terisi 1.949; terpadat 74 |
| Hibah | `access_grants` 176 |
| Outbox | 231 `v2_review`, 215 `v2_handed_off`, 78 `completed` |
| `access_jobs` | 1.134 `completed`, 34 `superseded`, 5 `queued`, 5 `review_required` |
| `payment_reconciliation` | 92 (abandoned 47, pending 21, closed 18, paid 6) |
| `webhook_events` | 38 (19 completed, 19 pending) |
| Worker VPS | sehat, ±50/4.168 panggilan gagal, 0 refresh sesi, `started` ±19 jam lalu |
| Log Functions | tersedia ±6 jam saja |

Catatan: sebagian data awal diambil di awal sesi dan bisa berubah. Verifikasi ulang sebelum menyimpulkan.

---

## 7. Hipotesis utama yang perlu diuji AI pengaudit

1. **Arsitektur, bukan satu bug.** Dulu satu hop (GoAkal); sekarang >8 mata rantai tanpa pemantauan, sehingga gagal diam-diam. Uji dengan mereplay satu pembayaran sandbox dari awal sampai notebook terbuka dan ukur latensi/kegagalan per tahap.
2. **Login Windows** gagal karena audiens token Desktop tidak terdaftar (M-01). Uji dengan token nyata.
3. **Sesi Google VPS** adalah satu titik gagal besar; belum gagal, tetapi pemulihannya manual (M-09).
4. **Keluhan "sudah bayar"** sebagian berasal dari orang yang tidak menyelesaikan pembayaran (M-06/M-07), bukan kegagalan akses. Uji dengan mencocokkan keluhan nyata (nama/email/waktu) terhadap `transactions` dan Midtrans.
5. **Kebijakan satu-trial-per-perangkat** menolak pengguna sah akibat ID perangkat yang tidak unik (M-02).

---

## 8. Pertanyaan terbuka untuk pemilik (keputusan yang belum diambil)

1. Cara 1 atau cara 2 untuk sesi Google? (diputuskan: **cara 2**, pembangunan skrip penyegaran menunggu uji master token).
2. Boleh memasang worker VPS baru (lease) dan di mana alamat/aksesnya?
3. Boleh mengubah konfigurasi Firebase (audiens klien Desktop) dan memperbaiki scheduler keepalive?
4. Rilis build baru (Android/Windows/macOS) memuat semua perbaikan klien — perlu perintah eksplisit pemilik.
5. Nasib akun `fikr***` dan 5 job `queued`/6 entri outbox macet.
6. Upgrade runtime Node 20 → 22 sebelum 2026-10-30.

---

## 9. Blind spot yang kami tahu masih ada

1. Tidak ada data riwayat era GoAkal untuk membandingkan "tidak ada masalah" secara kuantitatif.
2. Tidak ada log klien (Windows/Android) nyata dari pengguna yang gagal.
3. Tidak ada uji ujung-ke-ujung terhadap NotebookLM, Midtrans, atau Firebase sungguhan; hanya `MemoryDB`.
4. Kuota/batas laju Google terhadap `sharing.add_user` tidak diukur; 50 kegagalan penyedia belum dikategorikan.
5. Rekaman keluhan pengguna (siapa, kapan, apa pesan persis) belum dihimpun; kami hanya punya ringkasan dari pemilik.
6. Perilaku `AccessPrepareGate`, `payment_success_dialog`, dan alur setelah pembayaran di perangkat nyata belum diuji.
7. Dua worker sekaligus (VPS+laptop) hanya diuji pada tingkat lease; keamanan `engine.runJob` di bawah dua instance belum diverifikasi.
8. App Check `access_control/security` tidak ada → mode "off"; efek pada penyalahgunaan belum dinilai.
9. Jalur webhook DOKU (`dokuWebhook`) dan sisa jalur GoAkal belum diaudit ulang.
10. Keamanan: `functions/.env` (kunci Midtrans) ada di disk lokal; `master_token.json`/`storage_state.json` di folder proyek (di `.gitignore`); klien OAuth Desktop menanamkan secret di biner (praktik lazim Google untuk aplikasi desktop, namun periksa). Jangan menyalin nilainya ke dokumen.

---

## 10. Gotcha lingkungan

- Node default `v26.12.1` tidak mendukung `--experimental-transform-types`; pakai Node 22 dari `~/.nvm/versions/node/v22.19.0`.
- `flutter pub get` dapat memodifikasi `pubspec.lock`; periksa `git status` sebelum commit. Commit berkas spesifik, bukan `git add -A` (ada berkas tak terlacak besar: `KATALOG_V9_2/`, `rea-rea-agents-6.8.0/`, video).
- `lib/` di `openturath_ai/functions` adalah hasil build yang **terlacak**; jalankan `tsc` sebelum commit perubahan `src`.
- `firebase deploy` memakai akun `raflimaulan@gmail.com` (gcloud). Deploy fungsi sempat gagal sekali saat mengunggah, berhasil pada percobaan kedua.
- Browser pane aplikasi desktop kadang 1,5 fps/timeout; bukan masalah kode situs.
- Pesan galat Firebase Functions Gen1 `HttpsError` tidak muncul sebagai ERROR di Cloud Logging.

---

## 11. Cara mengakses data (baca-saja)

```bash
TOK=$(gcloud auth print-access-token)
# contoh: dokumen runtime
curl -s -H "Authorization: Bearer $TOK" \
  "https://firestore.googleapis.com/v1/projects/open-turath/databases/(default)/documents/access_control/runtime"
# status Midtrans satu pesanan (kunci server ada di openturath_ai/functions/.env, jangan dicetak)
#   GET https://api.midtrans.com/v2/<order_id>/status  (Basic auth: serverKey:)
# log Cloud Functions
gcloud logging read 'resource.type="cloud_function" AND severity>=WARNING' --project=open-turath --limit=200
# kesehatan worker (di VPS)
curl -s http://127.0.0.1:8091/
```
Dump koleksi besar dilakukan lewat REST berhalaman dengan percobaan ulang (beberapa koleksi memberi `RemoteDisconnected`/timeout).
Skrip bantu sesi ini ada di scratchpad sesi dan **tidak** ada di repo.

---

## 12. Peta kode

| Area | Berkas |
|---|---|
| Pembayaran | `openturath_ai/functions/src/index.ts`: `createCheckout` ~889, `processSuccessfulPayment` ~1025, `midtransWebhook` ~1575, `reconcileOne` ~1260, `checkPaymentStatus` |
| Akses | `access_control.ts` (`AccessControl.resolve` ~310, `reserve`), `access_worker.ts`, `access_catalog.ts`, `notebook_catalog.ts`, `worker_lease.ts` |
| Voucher | `index.ts` `redeemCode`, `getAccessReadiness` |
| Pemantau | `index.ts` `monitorAccessHealth`, `monitorPaidWithoutAccess`, `auditMidtransLedger`, `reportAuthFailure` |
| Klien login | `lib/services/auth_service.dart`, `desktop_auth_gateway.dart`, `auth_failure_reporter.dart`, `lib/core/login_error_message.dart`, `desktop_oauth_config.dart` |
| Klien akses | `lib/services/agent_service.dart` (`getAgentUrl`), `subscription_service.dart` (`isAccessReady`), `lib/widgets/access_prepare_gate.dart`, `payment_success_dialog.dart` |
| Klien bayar | `lib/widgets/payment_checkout_sheet.dart`, `lib/core/payment_destination_policy.dart`, `lib/services/payment_service.dart` |
| Ruang AI | `lib/widgets/agent_multi_tab_room.dart` (**siklus hidup WebView dilarang diubah**) |
| VPS | `ecosystem/openturath_subscription/` (`README_VPS.md`, `verified_sharing.py`, `notebooklm_manager.py`, `writer_guard.py`, `deploy/*`) |
| OTA | `publish_auto_update.py`, `manage_ota.py`, `scripts/test_*.py` |
| Aturan Firestore/indeks | `openturath_ai/firestore.rules`, `firestore.indexes.json`, `firebase.json` |

---

## 13. Hal yang jangan dilakukan oleh pengaudit

- Mengubah atau mencabut hak akses siapa pun, terutama VIP.
- Menjalankan `publish_auto_update.py`, `flutter build` lalu mengunggah, atau menulis ke `app_config/version`.
- Menyentuh logika WebView di dua berkas terlarang.
- Menyalin rahasia (kunci Midtrans, client secret, master token, cookie sesi) ke dokumen, log, atau pesan.
- Mengisi angka akurasi/testimoni Manuskrip dengan data karangan.
- Memercayai klaim di dokumen ini tanpa verifikasi, terutama yang berlabel [HIPOTESIS].
