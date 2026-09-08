# AUDIT KOMPREHENSIF V2 — OpenTurath AI v1.0.8+9

**Tanggal:** 2026-09-07 · **Cakupan:** 100% `lib/` (±10.2 ribu baris Dart), Cloud Functions (`functions/src/index.ts`, ±1.990 baris), `firestore.rules`, Android manifest & Gradle, aset, dependensi, test suite, secrets.
**Catatan:** File proyek sedang diedit sesi lain selama audit berlangsung (dashboard, agent_webview, native_agent_launcher berubah mtime 19:39–19:50). Laporan ini merefleksikan kondisi disk per 19:50.

---

## RINGKASAN EKSEKUTIF

Aplikasi ini pada dasarnya adalah **shell berbayar di atas Google NotebookLM publik**. Kualitas visualnya tinggi dan pembayaran DOKU-nya relatif matang, tetapi ada **4 celah yang membuat paywall praktis tidak berfungsi**, **kredensial live yang ter-commit di repo**, dan **±40% kode mati** (fitur setengah jadi). Model bisnisnya juga rawan secara legal karena menyamarkan UI NotebookLM dan menjual ulang aksesnya.

**Skor ringkas:**
| Area | Skor | Catatan |
|---|---|---|
| Keamanan/monetisasi | 2/10 | Paywall bisa dilewati 4 cara berbeda; secrets bocor |
| Kebenaran logika | 5/10 | Kuota trial tak pernah dicatat; nama plan kacau |
| UI/UX | 6.5/10 | Visual bagus, tapi banyak "set dressing" menyesatkan |
| Copywriting | 5/10 | Banyak frasa AI-aneh & janji yang tak ditepati |
| Kebersihan kode | 5/10 | Banyak dead code & duplikasi; test mengetes hal sepele |
| Legal/kepatuhan | 3/10 | Menjual akses NotebookLM + menyembunyikan branding Google |

---

## A. KEAMANAN & MONETISASI (KRITIS)

### A1. URL NotebookLM berbayar di-hardcode di dalam APK — paywall bocor total 🔴
`lib/services/agent_service.dart:14-35` — `defaultAgentUrls` berisi URL notebook untuk semua modul berbayar. Padahal komentar di `functions/src/index.ts:14` berbunyi *"URL NotebookLM — HANYA ADA DI SINI, TIDAK DI CLIENT"*. Kontradiksinya:

- `AgentService.getAgentUrl()` **selalu** jatuh ke fallback ini saat error teknis apapun selain `permission-denied` (timeout, `unavailable`, `deadline-exceeded`, offline) — `agent_service.dart:53-64`.
- Di `agent_webview_screen.dart` error state ada tombol **"Buka Langsung Mode Riset"** yang langsung membuka fallback URL.
- Di dashboard & specialist list (versi terbaru): `(await getAgentUrl(id)) ?? AgentService.defaultAgentUrls[id]`.
- Tombol share di appbar webview **menyalin URL mentah NotebookLM ke clipboard** — pengguna bisa sebarkan link berbayar ke siapa pun.
- URL ini adalah string biasa di APK — decompile 5 menit dapat semua notebook "berbayar".

**Fix:** hapus `defaultAgentUrls` dari client sepenuhnya; server memang sudah benar polanya. Ganti tombol share dengan share ke product page, bukan URL notebook.

### A2. Kuota trial 10 pertanyaan TIDAK PERNAH dicatat 🔴
Cloud Function `recordQuestion` (transaksi atomik, bagus) sudah ada, tetapi `grep` menunjukkan **tidak ada satu pun layar yang memanggilnya** — hanya didefinisikan di `agent_service.dart:73`. Akibatnya:
- `questions_used` selalu 0 → `getAgentUrl` server selalu lolos jalur trial (`questionsUsed >= 10` tak pernah tercapai).
- UI profil menampilkan "Free Trial · Sisa N pertanyaan" — angka yang tidak pernah berkurang. Paywall hanya aktif jika `permission-denied` terkirim, yang hanya terjadi untuk plan premium expired.
**Kesimpulan:** kombinasi A1+A2 = pengguna baru mendapat akses gratis tanpa batas selamanya.

### A3. Webhook DOKU bisa dipalsukan di mode sandbox 🔴
`functions/src/index.ts:607-630`: verifikasi signature hanya dijalankan **jika header signature ada** atau jika `DOKU_ENV=production`. `.env` saat ini `DOKU_ENV=sandbox`. Siapa pun yang tahu URL function bisa `POST` payload `SUCCESS` palsu → `processSuccessfulPayment()` → entitlement premium aktif + `questions_used` direset + notifikasi ke server sharing. **Fix:** wajibkan signature selalu; matikan aktivasi di sandbox.

### A4. Kredensial live ter-commit di folder proyek 🔴
| File | Isi |
|---|---|
| `functions/.env` | DOKU Secret Key + API key, Akal API key (`ak_054...`), INTERNAL_SECRET, cookie secret |
| `functions/.env.midtrans.backup` | Midtrans **server** key sandbox |
| `test/doku_direct_test.dart:10-11` | DOKU client-id & **secret key** hardcoded dalam source test |
| `/Users/apple/Downloads/ramadhan/service-account.json` | **Private key penuh service account Firebase Admin** (project `open-turath`) |
| `android/key.properties` + `.jks` di repo | Password keystore release plaintext |

Selama folder ini pernah tersinkron/ dibagikan, semua kredensial dianggap bocor. **Fix:** rotasi SEMUA kunci di atas, pindah ke secret manager, tambah `.gitignore` (folder ini bahkan bukan repo git — tidak ada version control sama sekali, lihat G1).

### A5. Kerentanan tingkat menengah 🟠
- `onPermissionRequest` webview agent **men-GRANT semua** permintaan izin (mikrofon/kamera) tanpa konfirmasi (`agent_webview_screen.dart:744`).
- `checkPaymentStatus` tidak memverifikasi kepemilikan invoice oleh pemanggil — invoice number deterministic `OT-{timestamp}-{4digit}` mudah ditebak; bisa dipakai memantau status transaksi orang lain (kebocoran data ringan).
- `UpdateService` mengunduh APK dari URL di Firestore `app_config` yang **bisa dibaca publik** (`firestore.rules:47`) tanpa verifikasi checksum/signature. Kompromi satu dokumen = APK arbitrer didorong ke semua pengguna.
- Firestore listener di `DokuCheckoutSheet` query `transactions where invoice_number == X` — **pasti ditolak rules** (tidak ada filter `uid`), jadi listener realtime itu dead weight; deteksi sukses bertumpu pada polling 2 detik (dan polling ini jalan selamanya selama sheet terbuka — boros).

---

## B. BUG & KECACATAN LOGIKA

1. **Versi aplikasi hardcoded "1.0.4"** di profil (`profile_screen.dart:469`) padahal app 1.0.8. `package_info_plus` sudah jadi dependensi tapi tidak dipakai di sini.
2. **Nama plan kacau tiga arah:** constants (`tholib_1m/tholib_6m/bahits_1y`), profil mengecek plan hantu `sultan`/`field`/`single` ("Paket Sultan (Akses 30 AI)" — tidak ada di backend mana pun), subscription pakai `all_ai_1m`. Pengguna yang bayar Paket Promo akan melihat label "Langganan Aktif" generik atau salah label.
3. **Angka kuota tidak konsisten:** server & constants = 10 pertanyaan; profil menampilkan fallback `isGuest ? 10 : 20`.
4. **Alur tamu mati:** `signInAsGuest()` tidak pernah dipanggil dari UI manapun (login hanya Google), tapi profil punya seluruh logika `isGuest`/"Akses Tamu".
5. **Layarar webview BLANK selama fetch URL:** saat `_isLoadingUrl == true`, body Stack tidak menampilkan apa pun (indikator progres justru baru dihapus di edit terakhir — lihat warning analyzer `unused_field _loadingProgress`). 1–4 detik layar kosong tanpa feedback.
6. **State tab hilang tiap pindah tab:** `MainShellScreen` membangun ulang seluruh 4 layar dan memakai `AnimatedSwitcher` tanpa `IndexedStack` — posisi scroll, hasil fetch, dan animasi stagger di-replay setiap kali pindah tab (juga refetch Firestore berulang).
7. **`_isLoading` dashboard tidak pernah true** → cabang loading UI-nya dead code; data dimuat async 4 detik tanpa indikator.
8. **Promise 10 AI, realita 6:** kartu promo "Akses SELURUH 10 modul AI ... mencakup 6 Spesialis Fikih (Hanafi, Maliki, Hanbali, Muqaran)" — 4 dari 6 itu `coming_soon`; total aktif hanya 6 dari 13 agen. Menjual fitur yang belum ada.
9. **Nomor telepon customer dummy `081234567890`** dihardcode untuk SEMUA transaksi DOKU (`subscription_screen.dart:95`) — notifikasi SMS/konfirmasi pembayaran pengguna tidak akan pernah sampai. Link WA bantuan `wa.me/628123456789` juga placeholder.
10. **Fallback paymentUrl palsu:** jika DOKU error, `createCheckout` menyimpan `https://sandbox.doku.com/checkout/payment?invoice=...` (URL yang tidak berfungsi) ke transaksi lalu tetap mengembalikannya ke client — user dibawa ke halaman mati dan transaksi pending menggantung.
11. **`_executeDeleteChatHistory`** menebak-nebak tombol DOM NotebookLM berdasarkan teks; versi terbaru mengecek return value, tapi semua cabang tetap menampilkan snackbar sukses ("Riwayat chat telah dihapus/dibersihkan/dimasukkan ulang") meski aksinya gagal — feedback menyesatkan.
12. **`_detectGoogleAccessDenied` hanya mencocokkan string Inggris** dan bisa false-positive jika isi chat pengguna mengandung "Request access".
13. **Deep link dideklarasikan tapi tidak ada handlernya:** manifest punya intent-filter `openturath.ai/payment` (komentar: "iPaymu" — payment gateway yang bahkan sudah tidak dipakai), `MainActivity` tidak memprosesnya, `FlutterRouter` tidak configure.
14. **`dailyRevoke` mereset `questions_used: 0`** untuk user expired — memberi trial 10 pertanyaan baru berulang; dan cron hanya memproses user yang punya `subscription_expiry` global, entitlement modular expired tidak pernah tersentuh (efeknya kosmetik saja).
15. **Harga 6 bulan (`tholib_6m` Rp 250.000, `all_ai` 6 bulan Rp 499.000, `all_ai` 1 tahun Rp 799.000) ada di backend tapi tidak ada di UI** — SKU tersembunyi, dan kartu harga tahunan per-modul memakai `price1y` dari model lokal (Rp 450.000) yang harus disinkronkan manual dengan `resolvePlanPricing` server (sudah sama hari ini, tapi dua sumber kebenaran = risiko drift).
16. **`flutter analyze` (per 19:50):** 2 warning — `_loadingProgress` unused dan `accent` unused di `agent_webview_screen` (sisa refactor yang belum selesai).
17. **AgentService.getAgents() mengabaikan Firestore** dan selalu return list hardcoded, padahal `AgentModel.fromFirestore` + koleksi `agents` + field `akal_url_*` disiapkan — dua sumber data yang akan berbeda diam-diam. `FieldModel.specialistCount` juga hardcoded (6/4/4/…) dan sudah tidak akurat.

---

## C. KECACATAN UI/UX

1. **Double login Google tanpa penjelasan** — pengguna login Google di app (Firebase), lalu dihadapkan layar "Hubungkan Akun Google" untuk login Google KEDUA kali di webview. Copy "Login sekali di awal agar riset AI tidak terputus" tidak menjelaskan kenapa harus dua kali. Ini titik drop-off terbesar.
2. **Search bar palsu di dashboard** — berbentuk input field dengan chip "Cari", padahal cuma tombol pindah tab. Melanggar prinsip affordance; pengguna mengetik? Tidak bisa.
3. **Indikator "Ruang Riset Aktif" (titik hijau) fake** — dekorasi status yang tidak merefleksikan apa pun (bukan health check backend).
4. **Tab Bookmark adalah pulau kosong:** empty state menyuruh "Tandai ibarah kitab dari ruang riset AI" — **tidak ada satu pun UI yang bisa membuat bookmark** (`BookmarkService.addBookmark` hanya dipanggil oleh tombol Undo). Fitur Etalase tanpa etalase.
5. **Bottom nav icon-only saat tidak aktif** (label muncul hanya pada tab terpilih) — discoverability "Bookmark"/"Profil" rendah bagi pengguna baru.
6. **Overanimasi:** stagger entrance di-replay setiap rebuild/pindah tab (karena poin B6); animasi masuk di semua list padahal konteks bukan onboarding.
7. **Judul appbar webview UPPERCASE** (`_agent?.title.toUpperCase()`) — terkesan berteriak dan memperburuk truncation untuk judul panjang.
8. **Dialog bahasa campur:** 'Delete chat history?' / 'Cancel' / 'Delete' berbahasa Inggris di aplikasi berbahasa Indonesia.
9. **Webview memblokir zoom** (`supportZoom: false`) untuk teks Arab kecil di NotebookLM — masalah aksesibilitas bagi pengguna tua.
10. **Error state pembayaran/langganan tidak menampilkan total, metode, atau batas waktu** yang jelas sebelum membuka webview DOKU (semua доверено ke halaman DOKU).
11. Tidak ada: pull-to-refresh bookmark, indikator offline, retry eksplisit saat dashboard gagal fetch (diam-diam fallback ke data default).
12. **Update APK diam-diam diunduh di background tanpa persetujuan** (kuota data pengguna) — banner barunya bagus, tapi unduhan tanpa consent + permission `REQUEST_INSTALL_PACKAGES` adalah red flag Play Store policy (sideload update bisa jadi alasan penolakan/takedown).

---

## D. COPYWRITING "SANGAT AI" & MENYESATKAN

**Frasa AI-aneh (terdengar seperti LLM, bukan produk):**
- "Khazanah Turats Ilmiah. Ditopang Nalar AI." (login)
- "Ruang Riset" / "Ruang Riset Aktif" / "Ruang Telaah" dipakai di mana-mana untuk hal yang orang sebut "chat AI"
- "Eksplorasi modul spesialis berdasarkan rumpun" → seharusnya "Jelajahi…"
- "Kendala Memuat Ruang Riset", "Buka Langsung Mode Riset" (maksudnya: buka webview)
- "Dukungan asistensi teknis santri" (fitur list harga — tidak ada kanal support-nya)
- "Alhamdulillah! Pembayaran berhasil. Akses ruang riset Anda telah aktif!" (double tanda seru + religious tone berlebih di flow transaksi)
- Tiga nama fallback berbeda untuk persona yang sama: "Santri Peneliti" / "Peneliti Turats" / "Santri OpenTurath".

**Klaim berisiko/tidak benar:**
- Badge login **"Gemini 2.5 Flash"** — klaim model yang tak bisa diverifikasi & mengikat brand ke Google.
- **"Puluhan Ribu Ibarah"** — sumbernya hanya ±6 notebook; angka marketing kosong.
- **"Sitasi ibarah kitab asli dan nomor halaman"** — NotebookLM tidak menjamin nomor halaman.
- **"Versi 1.0.4 · Didukung Google NotebookLM Engine"** — versi stale + klaim "engine" resmi.
- Matematika marketing: "Rp 99.000 untuk 10 AI (dibanding Rp 50.000 x 10)" — 4 dari 10 AI belum ada.
- Aset & branding memakai logo/spiral **NotebookLM resmi** (`notebooklm_round.svg`, `OpenTurathMark` ber-label Semantics "Gemini Notebook") — aplikasi berbayar menyaru identitas visual Google. Ini bukan sekadar copywriting — risiko trademark/ToS nyata (lihat F).

---

## E. HAL-HAL YANG TIDAK PERLU (DEAD WEIGHT)

**Kode mati (didefinisikan, tidak pernah dipakai):**
| Item | Lokasi |
|---|---|
| `TurathCrystallizationOverlay` (widget loading 197 baris) | tidak direferensikan dimanapun |
| `ResearchNotesService` + `ResearchNote` (114 baris) | tidak pernah dipanggil |
| `signInAsGuest()` + logika guest di profil | tidak ada pintu masuk |
| Sistem lokalisasi 3 bahasa (`Loc`, locale notifier, RTL di main.dart) | `Loc.tr()` dipakai **1x** (judul app); tile bahasa di profil cuma menampilkan snackbar "Bahasa Indonesia adalah bahasa sistem default" |
| `AgentModel.fromFirestore`, `subAgents`, `suggestedPrompts`, `referenceBooks`, `akalUrl1m/6m/1y` | tidak pernah dirender — 643 baris data (beserta kitab-kitab rujukan yang bagus) tidak pernah dilihat pengguna |
| `AppErrorState` widget | hanya dipakai test |
| `UserModel.hasAccess`, `questionsRemainingForAgent`, `isTrialExhausted` | tidak dipanggil UI |
| `_openSubscriptionForAgent`'s `onOrder` (versi lama) → kini terpakai, tapi `checkPaymentStatus(String trxId)` legacy di `subscription_service.dart:60` tetap mati |
| `priceTholib6m` di constants | tidak ada SKU 6 bulan di UI |

**Dependensi tak terpakai di pubspec:** `flutter_markdown`, `crypto`, `cached_network_image`, `shimmer` (0 import di lib/).

**Aset bengkak:** 39 file Lottie (±semua brand NotebookLM: mindmap/quiz/slides/infographic loader…) — hanya **2** yang dipakai (`thinking_ux_icon_looping` & varian dark). 17 SVG — hanya `notebooklm_round.svg` + 2 gemini text yang dipakai. Sisanya memperbesar APK tanpa fungsi. (Ironis: `deep_test.dart` punya test "Old raster logo is permanently eliminated" — membersihkan logo lama sambil menimbun 34 animasi tak terpakai.)

---

## F. LEGAL & KEPATUHAN (STRATEGIS, BUKAN TEKNIS)

1. **Model bisnis:** menjual akses (Rp 50rb–799rb) ke notebook NotebookLM milik akun Google sendiri, dengan CSS/JS yang **secara aktif menyembunyikan header, logo, dan disclaimer Google** (`_hideElementsCss` menyembunyikan `[class*="disclaimer"]`!). Ini melanggar semangat (dan hampir pasti huruf) ToS Google & trademark. Risiko: notebook di-takedown/akun Google dibekal → seluruh "produk" mati dalam sehari. Mitigasi minimal: tampilkan atribusi Google, jangan sembunyikan disclaimer, atau migrasi ke backend LLM sendiri (korpus sudah ada di `data_corpus/`).
2. **Play Store:** mekanisme update sideload APK + pembayaran di luar Play Billing untuk digital goods adalah pelanggaran policy Play yang klasik → risiko takedown.
3. `public/` berisi halaman privacy/terms/refund/aup — bagus — tapi privacy policy tidak menyebut bahwa seluruh konten percakapan diproses Google.

---

## G. KUALITAS KODE & ARSITEKTUR

1. **Tidak ada version control** — folder bukan repo git. Dengan 8 versi APK tersebar di Downloads dan dua sesi mengedit file yang sama hari ini, ini resep kehilangan kode.
2. **Boilerplate tema duplikat** — pola `final isDark = Theme.of...; final canvas = isDark ? ... : ...` diulang ±40x di semua layar, padahal sudah ada `ThemeData` lengkap. Pakai `ThemeExtension`.
3. **String harga & pesan paywall diduplikasi** di ≥5 file ("Rp 50.000/bln atau Paket Promo Semua AI Rp 99.000" muncul 3x dengan redaksi berbeda).
4. **Widget 600–950 baris** (dashboard/agent_webview/subscription) tanpa pemisahan; tanpa state management (setState + StreamBuilder manual).
5. **Test mengetes hal yang salah:** 37 test lulus — menguji token warna "exact NotebookLM color tokens", kekayaan dictionary bahasa (yang mati), dan **live API call DOKU sandbox dengan secret di source**. Nol test untuk: alur paywall, recordQuestion, parsing webhook, ekspirasi entitlement.
6. Pulsing dots di-copy-paste dua kali (splash & checkout sheet). Empty `initState()` override. `dart:collection` import untuk satu `UnmodifiableListView`.
7. `functions/src/index.ts` ~2.000 baris mencampur: payment, gate HTML template (CSS inline ribuan baris), cron, sharing — sebaiknya dipecah.
8. Konkurensi edit hari ini mengindikasikan **tidak ada linting/CI gate** — `NativeAgentLauncher` sempat undefined-name beberapa menit di disk.

---

## H. FITUR WAJIB YANG HILANG (PRIORITAS)

1. **Penegakan & tampilan kuota trial** — integrasikan `recordQuestion` (panggil saat user mengirim pertanyaan pertama per sesi webview, atau pindah gate ke server proxy), dan tampilkan sisa kuota yang benar di profil.
2. **Riwayat chat/riset lokal** — percakapan tersimpan di akun Google, app tidak punya riwayat apa pun; tambahkan bookmark dari webview (sudah setengah jadi: `EvidenceBottomSheet` + `BookmarkService` tinggal dihubungkan ke aksi di webview).
3. **Riwayat & struk pembelian** — koleksi `transactions` sudah ada, tidak pernah ditampilkan. Wajib untuk kepercayaan + kepatuhan.
4. **Restore pembelian** — saat ini hanya otomatis via `onUserCreate` (email match); butuh tombol eksplisit + tampilkan status entri per modul.
5. **Crash reporting & analitik** (Crashlytics/Analytics) — arsitektur webview-cloaking ini rapuh terhadap perubahan DOM Google; tanpa telemetry Anda tidak akan tahu saat `hide script` mulai bocor header Google.
6. **Onboarding singkat** — menjelaskan double login Google, cara pakai notebook, dan disclaimer verifikasi dalil.
7. **Dukungan pelanggan nyata** — nomor WA asli (sekarang placeholder), FAQ, dan status langganan per modul.
8. **Penanganan offline/deep-link** yang dideklarasikan di manifest.

---

## I. FIX PRIORITAS (URUTAN EKSEKUSI DISARANKAN)

| # | Aksi | Dampak | Effort |
|---|---|---|---|
| 1 | Rotasi semua kredensial (A4), pindah ke secret manager, init git + .gitignore | Menghentikan kebocoran aktif | 0,5 hari |
| 2 | Hapus `defaultAgentUrls` dari client + tombol "Buka Langsung Mode Riset" + share URL mentah (A1) | Menutup bypass utama | 0,5 hari |
| 3 | Wajibkan signature webhook DOKU di semua environment (A3) | Menutup forgery premium gratis | 1 jam |
| 4 | Wiring `recordQuestion` + UI kuota trial (A2, H1) | Monetisasi trial jalan | 1 hari |
| 5 | Hapus plan hantu (`sultan/field/single`), satukan sumber label plan, versi dari `package_info_plus`, telepon customer real | Kebenaran data pengguna | 0,5 hari |
| 6 | Perbaiki blank screen fetch URL + IndexedStack untuk tab + loading state dashboard | UX instan | 0,5 hari |
| 7 | Bersihkan dead code & dependensi & 34 aset Lottie mati (bagian E) | Ukuran APK, maintainabilitas | 0,5 hari |
| 8 | Kompilasi ulang copywriting (bagian D) — hilangkan klaim "10 AI/Gemini 2.5 Flash/puluhan ribu ibarah" | Kepercayaan & risiko hukum | 0,5 hari |
| 9 | Keputusan strategis arsitektur: tetap shell NotebookLM (dengan atribusi & tanpa cloaking disclaimer) vs backend LLM sendiri | Eksistensi jangka panjang | diskusi |
| 10 | Crashlytics + test alur bayar/gate, hapus live API call dari test suite | Keandalan | 1–2 hari |

---

## LAMPIRAN — BUKTI BARIS KODE KUNCI
- Fallback URL client: `lib/services/agent_service.dart:14-35, 53-64`
- Tombol buka langsung & share URL: `lib/screens/agent_webview_screen.dart` (error state & appbar actions)
- Webhook tanpa signature sandbox: `functions/src/index.ts:606-630`
- `recordQuestion` tak dipanggil: hanya `lib/services/agent_service.dart:73`
- Versi stale: `lib/screens/profile_screen.dart:469`
- Plan hantu: `lib/screens/profile_screen.dart:196-209`
- Telepon dummy: `lib/screens/subscription_screen.dart:95`, `functions/src/index.ts:364,437`
- Rules app_config publik: `firestore.rules:45-49`
- Grant semua izin webview: `lib/screens/agent_webview_screen.dart:744-749`
- Cloaking disclaimer Google: `lib/screens/agent_webview_screen.dart:106-124`
