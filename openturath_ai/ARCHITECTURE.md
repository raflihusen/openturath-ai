# Arsitektur OpenTurath AI

> Dokumen rujukan tetap untuk pengembangan dan pemeliharaan.
> Terakhir diperbarui: 5 Agustus 2026 · Versi app: `1.0.1+2`

---

## Daftar Isi

1. [Ringkasan Produk](#1-ringkasan-produk)
2. [Peta Repositori](#2-peta-repositori)
3. [Tumpukan Teknologi](#3-tumpukan-teknologi)
4. [Arsitektur Tingkat Tinggi](#4-arsitektur-tingkat-tinggi)
5. [Model Data Firestore](#5-model-data-firestore)
6. [Kontrak Cloud Functions](#6-kontrak-cloud-functions)
7. [Alur Logika per Layar](#7-alur-logika-per-layar)
8. [Anatomi Script Injeksi WebView](#8-anatomi-script-injeksi-webview)
9. [Sistem Desain](#9-sistem-desain)
10. [Audit: Temuan](#10-audit-temuan)
11. [Keputusan yang Direkomendasikan](#11-keputusan-yang-direkomendasikan)
12. [Roadmap Rilis Play Store](#12-roadmap-rilis-play-store)
13. [Lampiran: Referensi Cepat](#13-lampiran-referensi-cepat)
14. [Sistem Otomasi Pelanggan](#14-sistem-otomasi-pelanggan)

---

## 1. Ringkasan Produk

**OpenTurath AI bukan aplikasi AI.** Ini adalah gerbang berlangganan yang membungkus notebook Google NotebookLM yang sudah dikurasi.

Seluruh kecerdasan — retrieval, penalaran, sitasi — dikerjakan oleh NotebookLM. Aplikasi mengurus tiga hal saja:

1. **Identitas** — siapa pengguna ini (Google Sign-In → Firebase Auth)
2. **Hak akses** — apakah dia berlangganan modul yang diminta (Cloud Function + Firestore)
3. **Penyajian** — membungkus NotebookLM dalam kemasan native dan menyembunyikan asal-usulnya

### Aset yang sesungguhnya

Nilai jual produk ini bukan kode, melainkan **isi notebook**: kitab dan ribuan transkrip muhadoroh Habib Abu Bakar Al-Masyhur yang sudah diunggah dan dikurasi. Wrapper bisa ditulis ulang siapa pun dalam seminggu; korpus itu tidak.

Konsekuensinya: setiap keputusan teknis harus dinilai dari pertanyaan *"apakah ini melindungi dan memperkuat akses ke korpus?"* — bukan dari kecanggihan teknis semata.

### Katalog modul saat ini

| Modul | ID | Status | Sub-agent |
|---|---|---|---|
| Fiqh Tahawwulat AI | `fiqh_tahawwulat` | aktif | Al-Muhaqqiq, Al-Bayan |
| Super AI Fikih Syafi'i | `fiqh_syafii` | aktif | Al-Muhaqqiq Fiqh Syafi'i |
| Nahwu & Sharaf AI | `nahwu_sharaf` | aktif | Al-Mu'rib, Al-Tashrif |
| Ushul Fiqh AI | `ushul_fiqh` | coming soon | — |
| Habib Umar AI | `habib_umar` | coming soon | — |
| Ilmu Hadits AI | `hadits` | coming soon | — |
| Tafsir AI | `tafsir` | coming soon | — |

Pola **sub-agent** adalah keunggulan konseptual yang layak dipertahankan: satu bidang ilmu, dua persona dengan gaya jawaban berbeda. Al-Muhaqqiq menyajikan dalil dan ibarah lengkap; Al-Bayan menyederhanakan. Secara teknis keduanya bisa menunjuk notebook yang sama atau berbeda.

---

## 2. Peta Repositori

```
openturath_ai/
├── lib/                          ← Aplikasi Flutter
│   ├── main.dart                 Entry point, init Firebase, tema, routing
│   ├── firebase_options.dart     Auto-generate flutterfire (project: open-turath)
│   ├── core/
│   │   ├── theme.dart            Token warna, radius, gradient per agent
│   │   ├── constants.dart        Konstanta app, endpoints & konfigurasi
│   │   ├── app_config.dart       Tema & bahasa persisten (SharedPreferences)
│   │   ├── localization.dart     Kamus id/en/ar sederhana (Loc.tr)
│   │   ├── arabic_utils.dart     Utilitas teks bahasa Arab
│   │   └── routes.dart           Nama rute
│   ├── models/
│   │   ├── agent_model.dart      Model agent + katalog default
│   │   ├── sub_agent_model.dart  Persona di dalam sebuah agent
│   │   ├── book_model.dart       Kitab rujukan yang ditampilkan
│   │   ├── bookmark_model.dart   Model bookmark fatwa & riset
│   │   ├── field_model.dart      Bidang keilmuan Islam
│   │   └── user_model.dart       Model user + logika trial/premium/entitlements
│   ├── services/
│   │   ├── auth_service.dart     Google Sign-In, buat user baru, sign out
│   │   ├── agent_service.dart    Ambil katalog + panggil getAgentUrl
│   │   ├── doku_service.dart     Integrasi DOKU Payment Gateway API
│   │   ├── subscription_service.dart  createCheckout DOKU + polling status transaksi
│   │   ├── bookmark_service.dart Bookmark Firestore & offline storage
│   │   └── research_notes_service.dart Catatan riset turath
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── login_screen.dart
│   │   ├── main_shell_screen.dart         Bottom navigation shell
│   │   ├── dashboard_screen.dart          Home feed & kurasi modul
│   │   ├── specialist_list_screen.dart    Daftar pakar turath
│   │   ├── agent_webview_screen.dart      ← INTI: WebView NotebookLM + in-app research
│   │   ├── bookmark_screen.dart           Koleksi simpanan riset
│   │   ├── profile_screen.dart            Profil & status keanggotaan
│   │   ├── subscription_screen.dart       Checkout langganan via DOKU Payment Gateway
│   │   ├── settings_screen.dart           Pengaturan bahasa & tema
│   │   └── google_session_auth_screen.dart Autentikasi sesi Google NotebookLM
│   └── widgets/
│       ├── openturath_brand.dart          Logo & identitas visual
│       ├── evidence_bottom_sheet.dart     Bottom sheet rujukan kitab & ibarah
│       └── app_error_state.dart           Widget error handling & fallback
│
├── functions/src/index.ts        ← Backend Cloud Functions (DOKU Checkout, Webhook, Auth)
├── android/                      Konfigurasi Android
├── ios/                          Kerangka iOS
│
├── README.md                     Panduan setup awal
├── SOP_MAINTENANCE.md            SOP menambah agent & rilis update
└── ARCHITECTURE.md               ← dokumen ini
```

---

## 3. Tumpukan Teknologi

| Lapisan | Pilihan | Versi |
|---|---|---|
| Framework | Flutter | SDK `>=3.0.0 <4.0.0` |
| Autentikasi | firebase_auth + google_sign_in | `^5.1.0` / `^6.2.1` |
| Database | cloud_firestore | `^5.2.0` |
| Backend | cloud_functions (Node/TypeScript) | `^5.0.3` |
| WebView | flutter_inappwebview | `^6.0.0` |
| Tipografi | google_fonts (Outfit, Amiri) | `^6.2.1` |
| Lain-lain | shared_preferences, url_launcher, lottie, shimmer, cached_network_image | — |

**Firebase project:** `open-turath`
**Application ID sekarang:** `com.example.openturath_ai` *(harus diganti — lihat §10)*
**minSdk:** 24 · **NDK:** 28.2.13676358 · **Java:** 17

---

## 4. Arsitektur Tingkat Tinggi

```
┌──────────────────────────┐         ┌─────────────────────────────┐
│   APLIKASI FLUTTER       │         │  FIREBASE / PIHAK KETIGA    │
├──────────────────────────┤         ├─────────────────────────────┤
│                          │         │                             │
│  Splash ─── cek sesi ────┼────────▶│  Firebase Auth              │
│    │                     │         │                             │
│    ▼                     │         │                             │
│  Login ─── Google ───────┼────────▶│  users/{uid} dibuat         │
│    │                     │         │  plan=trial, questions=0    │
│    ▼                     │         │                             │
│  Dashboard               │    ╳    │  (Firestore agents/         │
│    │  katalog hardcoded  │         │   TIDAK PERNAH DIBACA)      │
│    ▼                     │         │                             │
│  Pilih Sub-Agent         │         │                             │
│    │                     │         │                             │
│    ▼                     │         │  CF getAgentUrl             │
│  getAgentUrl(id) ────────┼────────▶│   ├─ cek entitlement        │
│    │                     │         │   ├─ cek expiry             │
│    │◀── URL notebook ────┼─────────┤   ├─ cek kuota trial        │
│    ▼                     │         │   └─ AGENT_URLS[id]         │
│  WebView + inject JS ────┼────────▶│  notebooklm.google.com      │
│    │                     │         │                             │
│    │ QuestionAnswered    │         │                             │
│    ▼                     │         │                             │
│  Paywall (kuota habis)   │         │                             │
│    │                     │         │                             │
│    ▼                     │         │  CF createCheckout          │
│  Halaman Langganan ──────┼────────▶│   └─ transaksi DOKU pending │
│    │                     │         │            │                │
│    │  buka payment URL   │         │            ▼                │
│    └─────────────────────┼────────▶│  DOKU Payment Gateway       │
│                          │         │            │                │
│  StreamBuilder pantau ◀──┼─────────┤  dokuWebhook → entitlement  │
│  dokumen user            │         │                             │
└──────────────────────────┘         └─────────────────────────────┘

Latar belakang (tanpa interaksi user):
  onUserCreate  → sambungkan transaksi lama berdasarkan email
  dailyRevoke   → cron 00:00 WIB, turunkan langganan expired ke trial
  chatGate      → versi web (iframe) yang berjalan paralel dengan app
```

### Prinsip keamanan yang sudah benar

**URL NotebookLM tidak pernah ada di kode client.** Ia hanya hidup di `AGENT_URLS` dalam Cloud Functions, dan hanya dikirim ke perangkat setelah entitlement diverifikasi. Kalau seseorang membongkar APK, dia tidak menemukan satu pun alamat notebook. Ini keputusan yang tepat dan harus dipertahankan.

### Prinsip keamanan yang belum benar

Verifikasi di atas membaca `plan` dan `subscription_expiry` dari dokumen `users/{uid}` — dokumen yang **boleh ditulis sendiri oleh user** menurut aturan Firestore di README. Rinciannya di §10.1.

---

## 5. Model Data Firestore

### `users/{uid}`

```jsonc
{
  "name": "Ahmad Fulan",
  "email": "ahmad@example.com",
  "photo_url": "https://...",

  // Model lama (global, satu langganan untuk semua modul)
  "plan": "trial" | "tholib_1m" | "tholib_6m" | "bahits_1y",
  "subscription_expiry": Timestamp | null,
  "questions_used": 0,

  // Model baru (per modul) — dipakai getAgentUrl lebih dulu
  "entitlements": {
    "fiqh_tahawwulat": { "plan": "tholib_1m", "expiry": Timestamp, "updated_at": Timestamp },
    "fiqh_syafii":     { "plan": "tholib_6m", "expiry": Timestamp, "updated_at": Timestamp },
    "nahwu":           { ... }
  }
}
```

Dua model hidup berdampingan. `getAgentUrl` mencoba `entitlements[key]` dulu, baru jatuh ke `plan` global. Ini transisi yang belum selesai — dan `UserModel` di sisi Flutter **hanya mengenal model lama**, sehingga UI bisa menampilkan status yang berbeda dari yang diputuskan server.

**Peta entitlement key:**

| agentId dimulai dengan | entitlement key |
|---|---|
| `fiqh_tahawwulat_` | `fiqh_tahawwulat` |
| `fiqh_syafii` / `fikih-syafii` | `fiqh_syafii` |
| `nahwu_sharaf_` | `nahwu` |
| *(lainnya)* | `fiqh_tahawwulat` ← default berbahaya |

Default yang jatuh ke `fiqh_tahawwulat` berarti modul baru yang belum dipetakan akan otomatis memakai entitlement Tahawwulat. Harus diubah jadi tolak-secara-default.

### `agents/{agentId}`

Koleksi ini **dirancang tapi tidak dipakai**. `AgentService.getAgents()` langsung mengembalikan `AgentModel.defaultAgents` yang hardcoded. `AgentModel.fromFirestore()` ada tapi tidak pernah dipanggil — dan kalaupun dipanggil, ia tidak membaca `subAgents` maupun `referenceBooks`.

SOP_MAINTENANCE.md menyuruh admin mengedit Firestore untuk mengaktifkan agent; instruksi itu tidak berpengaruh apa-apa pada kondisi kode sekarang.

### `transactions/{trxId}`

```jsonc
{
  "uid": "abc123" | null,          // null jika beli dari website
  "plan": "tholib_1m",
  "amount": 49000,
  "duration_months": 1,
  "status": "pending" | "success",
  "source": "app" | "website",
  "customer_name": "...",
  "customer_email": "...",         // kunci penyambungan ke user
  "customer_phone": "...",
  "entitlement_key": "fiqh_tahawwulat",
  "subscription_expires_at": Timestamp,
  "created_at": Timestamp
}
```

`customer_email` adalah tulang punggung penyambungan: user bisa membeli di website tanpa akun, lalu ketika mendaftar di app, `onUserCreate` mencocokkan email dan mengaktifkan langganannya.

### `config/payment` dan `sharing_log/{id}`

`config/payment` menyimpan URL checkout per plan dengan pola field `{plan}_url` (mis. `tholib_1m_url`). `sharing_log` mencatat setiap add/remove sharing NotebookLM untuk audit.

---

## 6. Kontrak Cloud Functions

Semua berjalan dengan service account `open-turath@appspot.gserviceaccount.com`.

### `getAgentUrl` — callable

```
Masuk:  { agentId: string }
Keluar: { url: string }
Error:  unauthenticated  → belum login
        invalid-argument → agentId kosong
        not-found        → agent/user tidak ada
        permission-denied→ expired, tanpa expiry, atau kuota trial habis
```

Urutan pemeriksaan:

1. Ada `context.auth`? Tidak → tolak.
2. `AGENT_URLS[agentId]` ada? Tidak → tolak.
3. Dokumen user ada? Tidak → tolak.
4. Tentukan entitlement key dari prefix agentId.
5. Ambil plan & expiry dari `entitlements[key]`, fallback ke global.
6. Kalau premium: wajib punya expiry valid **dan** belum lewat. Tanpa expiry → tolak *(fail-closed, benar)*.
7. Kalau bukan premium: `questions_used >= 10` → tolak.
8. Lolos → kembalikan URL.

### `createCheckout` — callable

```
Masuk:  { plan, name, email, phone }   // uid opsional dari context.auth
Keluar: { redirectUrl, paymentUrl, trxId }
```

Harga dan durasi **diambil dari `PLAN_CATALOG` di server**, bukan dari client — ini benar dan penting. Client boleh mengirim `amount`, tapi server mengabaikannya.

Fungsi ini menerima panggilan tanpa auth (agar website bisa memakainya juga).

### `onUserCreate` — trigger `users/{uid}` onCreate

Mencari transaksi `success` dengan email yang sama, ambil yang expiry-nya paling jauh, dan kalau masih berlaku: set `plan`, `subscription_expiry`, reset `questions_used`, sambungkan `uid` ke dokumen transaksi, beri tahu server sharing, catat ke `sharing_log`.

### `dailyRevoke` — pubsub cron `0 0 * * *` Asia/Jakarta

Query user dengan `subscription_expiry <= now`, saring plan premium di memori (menghindari composite index), turunkan ke `trial`, kosongkan expiry, reset kuota, beri tahu server sharing.

### `chatGate` — HTTP request

Versi web dari produk: melayani `/chat/:agentId` dan mengembalikan halaman HTML dengan sidebar modul, daftar prompt contoh, dan `<iframe>` NotebookLM. Punya daftar `AGENTS` sendiri yang **terpisah dari `AGENT_URLS`**.

Terdapat fungsi pendukung yang **sudah tidak terpanggil** dari router: `handleLogin`, `verifySubscriptionHybrid`, `verifySubscriptionFirestore`, `verifyAkalSubscription`, `verifySessionCookie`, `generateCsrfToken`, `getLoginHTML`. Artinya sistem login berbasis cookie HMAC pernah ada lalu dilepas — router sekarang langsung mengarahkan `/`, `/login`, `/logout` ke `/chat/:ref` **tanpa verifikasi apa pun**. Halaman chat web saat ini terbuka untuk siapa saja yang tahu URL-nya.

---

## 7. Alur Logika per Layar

### 7.1 `main.dart` — bootstrap

1. Kunci orientasi ke portrait.
2. `AppConfig.init()` — muat tema & bahasa dari SharedPreferences.
3. Status bar transparan.
4. `Firebase.initializeApp()` dalam `try/catch`. Kalau gagal, tampilkan layar merah berisi instruksi menjalankan `flutterfire configure` — **pesan developer yang tidak boleh sampai ke tangan pengguna akhir.**
5. Bungkus `MaterialApp` dalam dua `ValueListenableBuilder` bertingkat (tema, lalu bahasa) agar keduanya reaktif tanpa state management eksternal.

Catatan: `locale` di-set ke `Locale(currentLocale)` tapi tidak ada `localizationsDelegates` maupun `supportedLocales`. Terjemahan sepenuhnya ditangani `Loc.tr()` buatan sendiri; `locale` bawaan Flutter praktis tidak berpengaruh. Arah teks RTL untuk bahasa Arab juga belum ditangani secara global.

### 7.2 Splash

Animasi masuk berlapis: `_mainCtrl` (2200 ms, stagger), `_pulseCtrl`, `_orbitCtrl`, `_particleCtrl`. Logo geometris 4 warna meniru `galleryLogo.svg` milik AI Edge Gallery. Setelah animasi, cek `FirebaseAuth.currentUser` → dashboard atau login.

### 7.3 Login

Hanya satu jalan masuk: Google Sign-In. Tidak ada email/password, tidak ada tamu.

`AuthService.signInWithGoogle()`:
- `_googleSignIn.signIn()` → batal? kembalikan null.
- Tukar kredensial → `signInWithCredential`.
- Cek `users/{uid}`. Belum ada → buat `UserModel` baru dengan `plan: trial`, `questions_used: 0`.

### 7.4 Dashboard

- `_loadData()` ambil user + katalog agent (hardcoded).
- Body dibungkus `StreamBuilder<UserModel?>` ke `authService.userStream`, sehingga perubahan langganan langsung tercermin tanpa refresh.
- Agent dikelompokkan per `category` ke dalam `Map<String, List<AgentModel>>`, tiap kategori jadi satu `PageView` horizontal dengan `viewportFraction: 0.82` (efek kartu mengintip).
- Header kategori bergaya "section divider": titik berwarna + judul + garis + chip jumlah.
- Banner status memilih satu dari tiga kondisi: langganan aktif (hijau), trial habis (merah, bisa diklik), sisa trial (biru).

**Bug halus:** `PageController` dibuat baru di dalam `itemBuilder` setiap rebuild (`PageController(viewportFraction: 0.82, keepPage: true)`). Controller ini tidak pernah di-`dispose` dan posisinya bisa ter-reset. Seharusnya dibuat sekali per kategori di `initState` dan dibuang di `dispose`.

### 7.5 Pemilihan Sub-Agent

Layar detail bergaya hero: lingkaran gradien besar, nama Latin + Arab, lalu dua bagian:

1. **Kartu sub-agent** — nama, nama Arab, deskripsi, badge, tombol CTA lebar penuh. Menekan tombol membawa `agent` (bukan sub-agent) ke rute WebView.
2. **Daftar kitab rujukan** — daftar `BookModel` bergaya minimal dengan ikon emas.

Bagian kitab rujukan ini adalah **satu-satunya konten asli non-WebView** di seluruh aplikasi. Ini penting untuk argumen Minimum Functionality (§11.2) dan layak diperluas.

### 7.6 WebView — jantung aplikasi

`didChangeDependencies` membaca `agent` dan `user` dari argumen rute, lalu:

```
user.isTrialExhausted ?
  ├─ ya  → tampilkan paywall, WebView tidak pernah dibuat
  └─ tidak → _fetchAgentUrl()
              ├─ ambil ulang UserModel terbaru dari Firestore
              ├─ cek ulang trial habis
              ├─ AgentService.getAgentUrl(agent.id)
              └─ set _agentUrl → bangun InAppWebView
```

Konfigurasi WebView:

| Pengaturan | Nilai | Alasan |
|---|---|---|
| `initialUserScripts` | script yang sama di `AT_DOCUMENT_START` **dan** `AT_DOCUMENT_END` | menangkap render awal Angular |
| `supportZoom` / `builtInZoomControls` / `displayZoomControls` | `false` | terasa seperti app native |
| `shouldOverrideUrlLoading` | izinkan hanya `notebooklm.google.com`, `accounts.google.com`, `*.google.com` | cegah user berkelana keluar |
| `onLoadStop` | injeksi ulang | cadangan |
| `onUpdateVisitedHistory` | injeksi ulang | NotebookLM adalah SPA; rute berubah tanpa reload |

AppBar kustom menimpa header NotebookLM: tombol kembali, chip ikon gradien, judul Latin + Arab, dan chip kuota yang berubah merah saat sisa ≤ 3.

Penanganan kuota:

```dart
_onQuestionAnswered(int) {
  if (_showPaywall) return;
  if (_user?.isPremium == true) return;   // premium tanpa batas
  _localQuestionCount++;
  agentService.incrementQuestionCount(uid);   // FieldValue.increment(1)
  if (_localQuestionCount >= 10) _showPaywall = true;
}
```

### 7.7 Paywall

`PopScope(canPop: false)` — tombol kembali sistem dimatikan sepenuhnya. Latar `BackdropFilter` blur 12 px di atas `bgDeep` opasitas 0.92. Satu-satunya jalan keluar adalah menekan tombol berlangganan.

Mengunci tombol kembali sistem termasuk pola yang dinilai negatif oleh Play (pengguna terperangkap). Sebaiknya diberi jalan keluar ke dashboard.

### 7.8 Langganan

- Tiga kartu paket dengan badge "POPULER" pada satu di antaranya.
- Menekan paket → `createPayment()` catat transaksi pending → `launchUrl(..., LaunchMode.externalApplication)` membuka browser → dialog "Menunggu Pembayaran" yang tidak bisa ditutup dengan tap luar.
- `StreamBuilder` ke `watchUserSubscription(uid)`: begitu webhook mengubah dokumen user, layar otomatis `pop` dan menampilkan snackbar "🎉 Langganan berhasil diaktifkan!".

Nomor telepon di-hardcode `'08123456789'` sebagai placeholder karena app tidak meminta nomor dari pengguna.

### 7.9 Pengaturan

Pemilihan tema (sistem/terang/gelap) dan bahasa (id/en/ar), disimpan ke SharedPreferences lewat `AppConfig`.

---

## 8. Anatomi Script Injeksi WebView

Terletak di `AppConstants.injectionScript` (`lib/core/constants.dart`). Seluruhnya dibungkus IIFE dan langsung keluar kalau hostname bukan `notebooklm.google.com`.

### Bagian A — penyembunyian visual

Menyuntik `<style id="openturath-custom-style">` berisi selektor untuk:

- Logo & tautan dashboard NotebookLM
- One Google Bar, avatar akun Google, Google Apps grid
- Tombol settings, share, create notebook, badge Pro
- Footer dan elemen berkelas `.disclaimer`

Setiap selektor dipaksa dengan `display:none; opacity:0; pointer-events:none; visibility:hidden; width:0; height:0; margin:0; padding:0` — sabuk dan bretel sekaligus.

### Bagian B — penyembunyian disclaimer berbasis teks

`document.createTreeWalker(..., NodeFilter.SHOW_TEXT)` menyisir seluruh node teks mencari kalimat yang mengandung "NotebookLM" **dan** salah satu dari: `inaccurate`, `akurat`, `double check`, `periksa kembali`, `respons`, `responses`. Elemen induknya lalu disembunyikan.

> **Ini bagian paling bermasalah.** Menyembunyikan peringatan akurasi AI dari pengguna adalah tindakan yang sulit dibela — baik dari sisi kebijakan Play, ToS Google, maupun dari sisi tanggung jawab keilmuan. Untuk produk yang menjual ketepatan sitasi ilmu agama, menghapus peringatan "AI bisa keliru" justru bertentangan dengan misinya sendiri. Rekomendasi: hapus bagian ini, ganti dengan disclaimer OpenTurath sendiri yang ditampilkan native.

### Bagian C — penjagaan lewat MutationObserver

`MutationObserver` pada `document.documentElement` dengan `childList: true, subtree: true` menjalankan ulang bagian A dan B setiap kali DOM berubah. Dijaga flag `window.__openturath_observer_active__` agar tidak dobel.

Observer tanpa `requestAnimationFrame`/debounce yang menjalankan `TreeWalker` penuh pada setiap mutasi Angular adalah beban berat — ini kemungkinan besar penyebab utama kalau app terasa panas atau boros baterai.

### Bagian D — pelacakan pertanyaan

Dua listener pada fase *capture*:

- **keydown** — Enter tanpa Shift pada `<textarea>`/`<input>` yang `aria-label`-nya `"Query box"`, atau class-nya mengandung `query-box-input`, atau placeholder-nya mengandung `"ask"`.
- **click** — elemen `<button>` / `[role=button]` / `.send-button` terdekat yang `aria-label`/`title`/`className`/`textContent`-nya mengandung `submit`, `send`, `kirim`, atau `arrow_forward`.

Keduanya memanggil `onQuerySent()`, yang memeriksa textarea masih berisi teks, memasang `window.__openturath_query_lock__` selama 2 detik, lalu memanggil handler Flutter `QuestionAnswered`.

**Kerapuhan:** seluruh deteksi bergantung pada `aria-label` dan nama class internal NotebookLM. Google mengubah satu atribut, penghitungan kuota diam-diam berhenti bekerja — dan tidak ada alarm yang berbunyi. Kuota trial akhirnya menjadi tak terbatas tanpa ada yang tahu.

---

## 9. Sistem Desain

Bahasa visual diambil dari **Google AI Edge Gallery** (lihat `scratch/apk_extract/`). Konsisten diterapkan di seluruh layar.

| Elemen | Penerapan |
|---|---|
| Tipografi | Outfit (UI, `w400`–`w800`, letter-spacing negatif untuk judul) + Amiri (Arab) |
| Permukaan | `bgCanvas` → `surfaceL1` → `surfaceL2` → `surfaceL3` berjenjang |
| Aksen | Empat warna merek: emas, merah, hijau, biru |
| Glassmorphism | `BackdropFilter` blur 12–16 px pada AppBar, paywall, menu |
| Ambient glow | `RadialGradient` opasitas 0.04–0.08 di sudut, hanya mode gelap |
| Gradien per agent | `AppTheme.agentGradient(agentId)` — warna konsisten dari kartu → sub-agent → AppBar WebView |
| Animasi | `RevealingText`, `SwipingText`, `StaggeredCardEntrance` |
| Indikator | Titik pill beranimasi, melebar jadi 20 px saat aktif |

Kualitas UI aplikasi ini sudah di atas rata-rata dan bukan area yang perlu dirombak. Yang kurang justru **kedalaman fungsi**, bukan tampilannya.

---

## 10. Audit: Temuan

Diurutkan menurut tingkat bahaya, bukan menurut urutan pengerjaan.

### 10.1 Paywall bisa dilewati dalam hitungan menit — **KRITIS**

Aturan Firestore di README:

```javascript
match /users/{uid} {
  allow read, write: if request.auth != null && request.auth.uid == uid;
}
```

Setiap pengguna yang login memiliki hak tulis penuh atas dokumennya sendiri. Sementara itu `getAgentUrl` mengambil keputusan berdasarkan dokumen yang sama. Siapa pun dengan Firebase SDK dan project ID (yang tercantum di `google-services.json` dalam APK) bisa menulis:

```js
{ plan: "bahits_1y", subscription_expiry: <tahun 2099>, questions_used: 0 }
```

…lalu mendapat akses seumur hidup ke seluruh modul, gratis.

**Perbaikan:** cabut hak tulis client sepenuhnya. Dokumen user hanya boleh dibaca client dan ditulis Admin SDK.

```javascript
match /users/{uid} {
  allow read: if request.auth != null && request.auth.uid == uid;
  allow write: if false;
}
```

Konsekuensinya `incrementQuestionCount` di client harus dipindah ke Cloud Function.

### 10.2 Kuota trial dihitung di sisi client — **KRITIS**

`_onQuestionAnswered` menaikkan `questions_used` dari perangkat. Bahkan tanpa memanfaatkan §10.1, cukup memblokir satu panggilan Firestore agar kuota tidak pernah bertambah.

Lebih parah: `getAgentUrl` hanya memeriksa kuota **saat URL diminta**. Setelah URL berada di tangan perangkat, sesi WebView bisa berjalan tanpa batas — 10 pertanyaan atau 10.000, server tidak akan tahu.

**Perbaikan:** Cloud Function `consumeQuestion` yang menaikkan counter secara transaksional dan mengembalikan sisa kuota. Client memanggilnya dan mempercayai jawabannya, bukan sebaliknya. Idealnya URL notebook juga berumur pendek dan diperbarui berkala, tapi NotebookLM tidak menyediakan mekanisme itu — ini batas struktural dari pendekatan wrapper.

### 10.3 Halaman chat web terbuka tanpa autentikasi — **KRITIS**

Router `chatGate` mengarahkan `/`, `/login`, `/logout` langsung ke `/chat/:ref`, dan `/chat/:agentId` menyajikan iframe NotebookLM tanpa memeriksa cookie sesi. Seluruh mesin verifikasi (`handleLogin`, `verifySubscriptionHybrid`, `verifySessionCookie`) masih ada dalam kode tapi tidak pernah dipanggil.

Artinya siapa pun yang tahu alamat `chatGate` bisa memakai notebook berbayar lewat browser tanpa membayar.

**Perbaikan:** pulihkan pemeriksaan sesi di route `/chat/:agentId`, atau matikan `chatGate` seluruhnya kalau versi web belum jadi prioritas.

### 10.4 `applicationId` masih `com.example.*` — **BLOKER RILIS**

```kotlin
applicationId = "com.example.openturath_ai"
```

Play menolak paket dengan awalan `com.example`. Menggantinya bukan sekadar mengubah satu baris:

1. Ubah `applicationId` dan `namespace` → mis. `ai.openturath.app`
2. Daftarkan app Android baru di Firebase project `open-turath`
3. Unduh `google-services.json` yang baru
4. Daftarkan SHA-1 (debug **dan** release) untuk Google Sign-In
5. Pindahkan direktori Kotlin `MainActivity` mengikuti paket baru

**Application ID tidak bisa diubah setelah app terbit di Play.** Pilih dengan matang sekarang.

### 10.5 Rilis ditandatangani kunci debug — **BLOKER RILIS**

```kotlin
release {
    signingConfig = signingConfigs.getByName("debug")
}
```

AAB yang ditandatangani kunci debug ditolak saat unggah. Perlu keystore rilis + `key.properties` (jangan di-commit) + daftar ke Play App Signing.

**Kehilangan keystore = kehilangan kemampuan memperbarui app selamanya.** Cadangkan di dua tempat terpisah.

### 10.6 Build gagal sekarang juga — **BLOKER RILIS**

`pubspec.yaml` mendeklarasikan:

```yaml
assets:
  - assets/images/
  - assets/animations/
```

Tidak ada satu pun berkas di bawah `assets/` — foldernya kosong atau tidak ada sama sekali. `flutter build` akan berhenti dengan galat direktori tidak ditemukan. Entah isi folder itu (logo, ilustrasi kondisi kosong, animasi Lottie) atau hapus deklarasinya.

Perlu dicatat: `lottie`, `shimmer`, dan `cached_network_image` ada di dependensi tapi **tidak dirujuk sama sekali** di seluruh `lib/`.

### 10.7 Tenggat target SDK 36 — **31 Agustus 2026**

Mulai 31 Agustus 2026, app baru dan pembaruan wajib menargetkan Android 16 (API 36). Dokumen ini ditulis 5 Agustus 2026 — **tersisa 26 hari.** Perpanjangan bisa diminta sampai 1 November 2026.

`targetSdk` sekarang mengikuti `flutter.targetSdkVersion`, yang berarti bergantung pada versi Flutter SDK yang terpasang. Sebaiknya dikunci eksplisit ke 36 dan diuji.

### 10.8 Kebijakan pembayaran Play — **RISIKO PENOLAKAN TERTINGGI**

Alur sekarang: user menekan paket di dalam app → `launchUrl` membuka goakal.com di browser → bayar di luar Play.

Ini adalah pola yang secara langsung dilarang Play Payments Policy untuk konten digital. Pembahasan opsi ada di §11.1.

### 10.9 Minimum Functionality (Kebijakan 4.3) — **RISIKO TINGGI**

Penegakan otomatis terhadap app pembungkus WebView semakin ketat sepanjang 2026. App yang sekadar memantulkan konten web tanpa nilai tambah khas aplikasi ditolak.

Aplikasi ini punya beberapa hal yang membantu — dashboard native, pemilihan sub-agent, daftar kitab rujukan, pelacakan kuota — tapi begitu pengguna masuk, 95% waktunya dihabiskan di dalam WebView milik pihak lain. Penguatan dibahas di §11.2.

### 10.10 Persyaratan wajib yang belum ada

| Kebutuhan | Status |
|---|---|
| Kebijakan privasi (URL publik) | belum ada |
| Hapus akun di dalam app | belum ada |
| Hapus akun lewat URL web | belum ada |
| Formulir Data Safety | belum diisi |
| Ikon adaptif | belum (hanya `ic_launcher.png` biasa) |
| Splash screen API Android 12+ | belum (masih `launch_background.xml` lama) |
| ProGuard/R8 rules | belum |
| Crashlytics / pelaporan galat | belum |
| `assetlinks.json` untuk deep link `openturath.ai` | belum, padahal `autoVerify="true"` |

App ini mengizinkan pembuatan akun, sehingga **jalur hapus akun di dalam app dan lewat web adalah kewajiban**, bukan pilihan.

### 10.11 Tiga sumber harga yang saling bertentangan

| Sumber | 1 Bulan | 6 Bulan | 1 Tahun |
|---|---|---|---|
| `lib/core/constants.dart` | 299.000 | 1.499.000 | 1.999.000 |
| `agent_model.dart` — Tahawwulat | 1.000.000 | 2.995.000 | 4.995.000 |
| `agent_model.dart` — Fikih Syafi'i | 50.000 | 250.000 | 450.000 |
| `agent_model.dart` — Nahwu Sharaf | 1.000.000 | 2.995.000 | 4.995.000 |
| `functions PLAN_CATALOG` | 49.000 | 249.000 | 449.000 |

Yang benar-benar ditagihkan adalah `PLAN_CATALOG` di server. Angka lain hanya tampilan — artinya **pengguna bisa melihat harga 1.000.000 di layar tetapi ditagih 49.000**, atau sebaliknya, tergantung layar mana yang dibuka. Perlu satu sumber kebenaran, disajikan dari server.

Perhatikan juga Nahwu Sharaf memakai URL Akal dan harga yang identik dengan Fiqh Tahawwulat — kemungkinan besar salin-tempel yang belum diperbaiki.

### 10.12 Katalog agent hardcoded, Firestore diabaikan

```dart
Future<List<AgentModel>> getAgents() async {
  return AgentModel.defaultAgents;   // Firestore tidak pernah disentuh
}
```

Akibatnya:
- Menambah atau mengaktifkan agent **wajib** rilis app baru
- SOP_MAINTENANCE.md yang menyuruh mengedit Firestore menyesatkan
- `AgentModel.fromFirestore()` tidak pernah terpakai, dan kalaupun dipakai tidak membaca `subAgents` maupun `referenceBooks`

Perbaikan yang tepat: baca dari Firestore dengan `defaultAgents` sebagai cadangan offline, dan lengkapi `fromFirestore` agar bisa memuat sub-agent dan kitab.

### 10.13 Skema ID agent yang tidak konsisten

| Konteks | Contoh ID | Notebook nahwu |
|---|---|---|
| App + `AGENT_URLS` | `nahwu_sharaf_muerib` (garis bawah) | `405b035c-5b48-471d-9fe2-54d6ae5d654d` |
| `chatGate AGENTS` | `nahwu-sharaf-muerib` (tanda hubung) | `15bc4cef-4b94-4241-b05a-d50a586bde06` |

Dua notebook berbeda untuk modul yang sama. **Salah satunya menunjuk notebook yang keliru** dan harus dipastikan mana yang benar.

Selain itu `AGENT_URLS` tidak memuat `nahwu_sharaf` (tanpa akhiran sub-agent). Kalau suatu saat `subAgents` dikosongkan, dashboard akan langsung memanggil `getAgentUrl('nahwu_sharaf')` dan gagal dengan `not-found`.

### 10.14 Dua model entitlement hidup berdampingan

Server sudah memakai `entitlements` per modul; `UserModel` di Flutter masih hanya mengenal `plan` global. Gejalanya: banner dashboard bisa berkata "Langganan Aktif" sementara membuka modul tertentu justru ditolak, atau sebaliknya. Migrasi ini harus diselesaikan, tidak dibiarkan setengah jalan.

### 10.15 Masalah tingkat menengah lainnya

- **`PageController` bocor** — dibuat ulang di setiap `itemBuilder` dashboard, tidak pernah `dispose`.
- **Pesan galat developer bocor ke pengguna** — layar merah "jalankan flutterfire configure" di `main.dart`.
- **Paywall mengunci tombol kembali** — `PopScope(canPop: false)` tanpa jalan keluar.
- **Nomor telepon hardcoded** — `'08123456789'` dikirim ke setiap transaksi.
- **Nomor WhatsApp placeholder** — `wa.me/628123456789` di `chatGate`.
- **`MutationObserver` tanpa debounce** — menjalankan `TreeWalker` penuh pada setiap mutasi Angular.
- **Tidak ada penanganan offline** — hanya pesan galat generik.
- **Tes bawaan yang pasti gagal** — `test/widget_test.dart` masih berisi template "Counter increments smoke test" bawaan Flutter, mencari tombol `Icons.add` yang tidak pernah ada di app ini. Setiap `flutter test` akan merah.
- **API Cloud Functions generasi ke-1** — `functions.https.onCall(data, context)` sudah usang; generasi ke-2 memberi kontrol konkurensi dan biaya lebih baik.
- **Locale tanpa dukungan RTL** — bahasa Arab tersedia di pengaturan tapi tata letak tidak berbalik arah.

---

## 11. Keputusan yang Direkomendasikan

### 11.1 Billing: User Choice Billing, dengan Play Billing sebagai rencana cadangan

**Situasi.** Indonesia termasuk negara yang memenuhi syarat program *user choice billing* Google Play, bersama EEA, Korea Selatan, Australia, India, dan Jepang. Ketika pengguna memilih sistem pembayaran alternatif, biaya layanan Google berkurang 4 poin persentase — bukan hilang. Indonesia juga termasuk negara yang mempertahankan struktur biaya lama sampai 30 September 2027, sehingga perubahan biaya Juni 2026 belum berlaku di sini.

**Tiga opsi dan penilaiannya:**

| Opsi | Potongan | Risiko tolak | Kerja | Penilaian |
|---|---|---|---|---|
| Google Play Billing penuh | 15–30% | paling rendah | sedang | Aman, tapi 30% dari 449.000 = 134.700 per transaksi |
| User Choice Billing | ±11–26% | rendah | tinggi (pendaftaran + Alternative Billing API + pelaporan) | Terbaik untuk margin, butuh proses administratif |
| App "akses saja" | 0% | **tinggi** | rendah | Menghemat potongan tapi memperbesar risiko 4.3 |

**Rekomendasi: mulai dari Google Play Billing, migrasi ke User Choice Billing setelah app diterima.**

Alasannya soal urutan, bukan soal angka. Pendaftaran user choice billing butuh app yang **sudah terbit**. Mengejar keduanya sekaligus berarti menunda rilis berminggu-minggu sambil tenggat target SDK 36 (31 Agustus) terus mendekat. Terbitkan dulu dengan Play Billing, lalu ajukan user choice billing sebagai pembaruan.

Yang **jangan** dilakukan: opsi "akses saja". Menghapus seluruh alur pembelian dari app justru memperlemah argumen Minimum Functionality — app jadi terlihat makin seperti pembungkus kosong. Dua risiko digabung jadi satu.

**Catatan penting:** langganan yang sudah dibeli lewat goakal.com harus tetap dihormati. Rancang agar dua jalur pembelian bisa hidup bersama: pembelian di app lewat Play Billing, pembelian di web lewat Akal, keduanya bermuara ke `entitlements` yang sama. `onUserCreate` sudah meletakkan pondasi penyambungan lewat email.

**Konsekuensi harga.** Dengan potongan 30% untuk tahun pertama, harga jual di app perlu disesuaikan agar penerimaan bersih setara penjualan web. Ini keputusan bisnis yang harus diambil sebelum menulis kode Play Billing — sekaligus kesempatan menyatukan tiga daftar harga yang sekarang bertentangan (§10.11).

### 11.2 WebView: perlunak, dan tambahkan bobot native

Anda memilih mempertahankan WebView. Itu keputusan yang masuk akal untuk sekarang — korpus NotebookLM adalah asetnya, dan membangun ulang RAG sendiri berarti menunda rilis berbulan-bulan. Tapi "mempertahankan" harus disertai perubahan.

**Yang harus dihentikan:**

1. **Berhenti menyembunyikan disclaimer akurasi.** Ini bagian paling sulit dibela dan paling kecil manfaatnya. Ganti dengan disclaimer OpenTurath sendiri yang tampil native — justru memperkuat kredibilitas produk yang menjual ketepatan sitasi.
2. **Kurangi penyembunyian branding.** Menyembunyikan tombol navigasi Google yang bisa membawa pengguna keluar (create notebook, settings, share, dashboard) masih bisa dibela sebagai pembatasan navigasi. Menghapus jejak bahwa ini NotebookLM sama sekali adalah cerita berbeda. Pertimbangkan atribusi kecil semacam "Ditenagai Google NotebookLM" di layar sub-agent.
3. **Hapus `MutationObserver` tanpa debounce.** Kalau selektor CSS sudah dipangkas, observer bisa jauh lebih ringan.

**Yang harus ditambahkan** — masing-masing menambah bobot native yang nyata, bukan kosmetik:

| Fitur | Nilai bagi pengguna | Nilai bagi kepatuhan |
|---|---|---|
| **Perpustakaan kitab** | Jelajahi kitab rujukan, biografi penulis, daftar isi | Konten asli substansial, bukan WebView |
| **Riwayat & bookmark** | Simpan jawaban penting, beri tag, cari kembali | Penyimpanan lokal + native UI |
| **Ekspor & bagikan** | Bagikan kutipan dengan sitasi ke WhatsApp/PDF | Integrasi perangkat |
| **Notifikasi push** | Kajian baru, pengingat langganan | Integrasi perangkat, disebut eksplisit dalam panduan kepatuhan |
| **Bank prompt** | Pertanyaan pemantik per modul (sudah ada di `chatGate`, pindahkan ke app) | Native UI |
| **Mode offline** | Kitab dan riwayat tetap bisa dibaca tanpa sinyal | Disebut eksplisit dalam panduan kepatuhan |
| **Onboarding** | Jelaskan Al-Muhaqqiq vs Al-Bayan | Pengalaman khas app |

Dari daftar ini, **perpustakaan kitab dan riwayat/bookmark memberi hasil terbesar**. Keduanya membuat app punya alasan untuk dibuka bahkan ketika pengguna tidak sedang bertanya — itulah pembeda antara aplikasi dan pintasan situs.

`BookModel` sudah ada dan sudah terisi data untuk tiga modul. Pondasinya sudah diletakkan; tinggal dikembangkan jadi layar tersendiri.

### 11.3 Jangka panjang: kapan pindah ke chat native

Pendekatan wrapper punya tiga batas keras yang tidak bisa direkayasa:

1. Kuota tidak bisa ditegakkan secara andal — setelah URL di tangan client, sesi lepas dari kendali server (§10.2).
2. Deteksi pertanyaan bergantung pada DOM internal Google yang bisa berubah kapan saja (§8D).
3. Anda tidak mengendalikan pengalaman inti produk Anda sendiri.

Pindah ke chat native (Gemini API + vector store atas korpus yang sama) menghapus ketiganya sekaligus, ditambah membuka riwayat percakapan, kutipan terstruktur, dan penetapan harga berbasis token.

**Kapan waktunya:** ketika pendapatan bulanan sudah menutupi biaya inferensi dengan nyaman, atau ketika Google mengubah NotebookLM dan wrapper rusak — mana yang lebih dulu. Sampai saat itu, wrapper adalah pilihan yang benar.

**Yang bisa disiapkan dari sekarang:** jaga agar korpus (kitab, transkrip) tersimpan rapi di luar NotebookLM dalam bentuk file sumber. Kalau suatu hari harus pindah, migrasinya jadi soal mengindeks ulang, bukan mengumpulkan ulang dari nol.

---

## 12. Roadmap Rilis Play Store

### Tahap 0 — Agar bisa di-build (setengah hari)

Tanpa ini, tidak ada yang bisa dikerjakan.

- [ ] Buat folder `assets/images/` dan `assets/animations/`, atau hapus deklarasinya dari `pubspec.yaml`
- [ ] Buang dependensi tak terpakai (`lottie`, `shimmer`, `cached_network_image`) atau mulai pakai
- [ ] Pastikan `flutter build appbundle --release` berjalan sampai selesai
- [ ] Pindahkan `scratch/` dan `ui-ux-pro-max-skill-2.5.0/` keluar repo

### Tahap 1 — Identitas & penandatanganan (satu hari)

Kerjakan lebih dulu; keputusan di sini permanen.

- [ ] Tetapkan application ID final (saran: `ai.openturath.app`)
- [ ] Ubah `applicationId` + `namespace`, pindahkan direktori Kotlin
- [ ] Daftarkan app Android baru di Firebase, unduh `google-services.json` baru
- [ ] Buat keystore rilis, **cadangkan di dua tempat terpisah**
- [ ] Buat `android/key.properties`, masukkan ke `.gitignore`
- [ ] Sambungkan `signingConfigs.release` di `build.gradle.kts`
- [ ] Daftarkan SHA-1 debug dan release ke Firebase (Google Sign-In akan rusak tanpa ini)
- [ ] Kunci `targetSdk = 36`, uji di Android 16

### Tahap 2 — Tambal keamanan (dua sampai tiga hari)

Jangan terbitkan sebelum bagian ini beres. Menerbitkan app yang paywall-nya bisa dilewati sama saja membagikan korpus secara gratis.

- [ ] Kunci aturan Firestore: `users` hanya-baca bagi client
- [ ] Cloud Function `consumeQuestion` transaksional; hapus penulisan kuota dari client
- [ ] Pulihkan pemeriksaan sesi di `chatGate`, atau matikan fungsinya
- [ ] Selesaikan migrasi `entitlements`: `UserModel` harus mengenal entitlement per modul
- [ ] Ubah default entitlement key jadi tolak-secara-default, bukan `fiqh_tahawwulat`
- [ ] Satukan sumber harga — server sebagai satu-satunya kebenaran
- [ ] Bereskan skema ID agent; pastikan notebook nahwu mana yang benar
- [ ] Tambahkan `nahwu_sharaf` ke `AGENT_URLS` sebagai pengaman

### Tahap 3 — Kepatuhan (dua sampai tiga hari)

- [ ] Terbitkan kebijakan privasi di URL publik
- [ ] Layar hapus akun di dalam app (hapus dokumen user + cabut sharing)
- [ ] Halaman web permintaan hapus akun
- [ ] Isi formulir Data Safety di Play Console
- [ ] Terbitkan `assetlinks.json` di `openturath.ai`, atau hapus `autoVerify`
- [ ] Ganti layar galat Firebase dengan pesan yang ramah pengguna
- [ ] Beri paywall jalan keluar ke dashboard

### Tahap 4 — Google Play Billing (tiga sampai lima hari)

- [ ] Tetapkan harga app dengan memperhitungkan potongan 15–30%
- [ ] Buat produk langganan di Play Console
- [ ] Integrasikan `in_app_purchase`
- [ ] Cloud Function verifikasi pembelian lewat Google Play Developer API
- [ ] Tangani pembaruan otomatis, pembatalan, masa tenggang, dan pemulihan pembelian
- [ ] Pastikan langganan lama dari goakal.com tetap dihormati
- [ ] Uji dengan akun penguji berlisensi

### Tahap 5 — Bobot native (satu sampai dua minggu)

Ini yang menentukan diterima atau ditolak berdasarkan Kebijakan 4.3.

- [ ] Layar perpustakaan kitab (perluasan `BookModel`)
- [ ] Riwayat & bookmark jawaban
- [ ] Bank prompt per modul (pindahkan dari `chatGate`)
- [ ] Onboarding penjelasan sub-agent
- [ ] Notifikasi push
- [ ] Perlunak script injeksi — kembalikan disclaimer, kurangi penyembunyian branding
- [ ] Penanganan offline yang layak

### Tahap 6 — Poles & rilis (tiga sampai empat hari)

- [ ] Ikon adaptif
- [ ] Splash screen API Android 12+
- [ ] Aturan ProGuard/R8
- [ ] Firebase Crashlytics
- [ ] Materi listing: 8 tangkapan layar, feature graphic 1024×500, deskripsi
- [ ] Uji internal → uji tertutup → produksi

**Perkiraan total: empat sampai enam minggu** untuk rilis yang layak. Tenggat target SDK 36 pada 31 Agustus 2026 kemungkinan besar terlewat — ajukan perpanjangan ke 1 November 2026 lebih awal, jangan menunggu.

### Jalur cepat (kalau harus terbit sebulan)

Tahap 0 → 1 → 2 → 3 → 4, dengan Tahap 5 dipangkas jadi perpustakaan kitab dan bank prompt saja. Risiko penolakan 4.3 naik, tapi masih bisa dibela. Tahap 5 selebihnya menyusul di pembaruan berikutnya.

---

## 13. Lampiran: Referensi Cepat

### Menambah modul AI baru

Dengan kondisi kode sekarang (katalog hardcoded), butuh **tiga** langkah dan satu rilis app:

1. `functions/src/index.ts` → tambahkan entri di `AGENT_URLS`
2. `functions/src/index.ts` → tambahkan pemetaan entitlement key di `getAgentUrl`
3. `lib/models/agent_model.dart` → tambahkan `AgentModel` ke `defaultAgents` dengan `status: 'active'`
4. `firebase deploy --only functions`
5. Naikkan versi di `pubspec.yaml`, build, unggah

*Setelah §10.12 diperbaiki, langkah 3–5 hilang: cukup edit Firestore dan agent langsung muncul.*

### Perintah yang sering dipakai

```bash
flutter pub get
flutter run
flutter build appbundle --release      # untuk Play Store
flutter build apk --release            # untuk bagi langsung

cd functions && npm install && npm run build
firebase deploy --only functions
firebase deploy --only functions:getAgentUrl   # satu fungsi saja

cd android && ./gradlew signingReport   # ambil SHA-1
```

### Aturan penomoran versi

`pubspec.yaml` → `version: <nama>+<kode>`. Kode build **wajib** naik setiap unggahan ke Play.

- Perbaikan kecil: `1.0.1+2` → `1.0.2+3`
- Fitur baru: `1.0.2+3` → `1.1.0+4`
- Perubahan besar: `1.1.0+4` → `2.0.0+5`

### Berkas yang paling sering disentuh

| Keperluan | Berkas |
|---|---|
| Batas kuota trial | `lib/core/constants.dart` → `trialQuestionLimit` |
| Harga (yang sebenarnya menagih) | `functions/src/index.ts` → `PLAN_CATALOG` |
| URL notebook | `functions/src/index.ts` → `AGENT_URLS` |
| Katalog agent | `lib/models/agent_model.dart` → `defaultAgents` |
| Script injeksi | `lib/core/constants.dart` → `injectionScript` |
| Warna & tipografi | `lib/core/theme.dart` |
| Teks antarmuka | `lib/core/localization.dart` |

### Sumber kebijakan

- [Target API level requirements — Play Console Help](https://support.google.com/googleplay/android-developer/answer/11926878?hl=en)
- [Understanding user choice billing — Play Console Help](https://support.google.com/googleplay/android-developer/answer/13821247?hl=en)
- [App account deletion requirements — Play Console Help](https://support.google.com/googleplay/android-developer/answer/13327111?hl=en)
- [Developer Program Policy — Play Console Help](https://support.google.com/googleplay/android-developer/answer/16933379?hl=en)
- [Expanded billing choice and lower fees — Android Developers Blog](https://android-developers.googleblog.com/2026/06/play-expanded-billing.html)

---

## 14. Sistem Otomasi Pelanggan

> [!IMPORTANT]
> **Pembaruan Arsitektur Pembayaran (September 2026):**
> Aplikasi OpenTurath AI dan Cloud Functions kini telah mengintegrasikan **DOKU Payment Gateway** (`doku_service.dart`, `createCheckout`, `dokuWebhook`). Alur lama via eksternal GoAkal telah digantikan sepenuhnya dengan gateway resmi DOKU. Analisis di bawah mengkaji jejak arsitektur dan transisi sistem.

Bagian ini menelusuri satu pertanyaan: **kalau seseorang membayar, apakah aksesnya benar-benar terbuka otomatis?**

Jawabannya: **dengan integrasi DOKU Payment Gateway + webhook, aktivasi entitlement berlangsung realtime dan otomatis.**

### 14.1 Komponen yang terlibat

| Komponen | Lokasi | Peran |
|---|---|---|
| **goakal.com (Akal)** | pihak ketiga | Menerima pembayaran, memancarkan webhook |
| **openturath-subscription** | Cloud Run `asia-southeast2` | Menerima webhook, membuka/menutup sharing NotebookLM |
| **Firebase Functions** | repo ini | `createCheckout`, `onUserCreate`, `dailyRevoke`, `notifySubscriptionServer` |
| **Firestore** | — | `users`, `transactions`, `sharing_log` |
| **NotebookLM** | pihak ketiga | Sumber sebenarnya; akses diatur lewat sharing per email |

> **Catatan penting:** kode Cloud Run `openturath-subscription` **tidak ada di repo ini.** Analisis di bawah menelusuri sisi Firebase saja. Beberapa celah yang saya tandai mungkin sudah ditutup di sisi Cloud Run — tapi kalau belum, ini titik-titik bocornya.

### 14.2 Bentuk payload

`notifySubscriptionServer` mengirim POST ke `https://openturath-subscription-…run.app/webhook` dengan header `X-Internal-Secret`, membawa:

```jsonc
{
  "event": "subscription.paid" | "subscription.expired",
  "data": {
    "status": "PAID" | "EXPIRED",
    "payer":   { "name": "...", "email": "..." },
    "service": { "name": "AI Fikih Tahawwulat" }
  }
}
```

Bentuk ini **meniru payload Akal sendiri**. Artinya Cloud Run dirancang menerima dua sumber lewat satu pintu: webhook asli dari Akal, dan webhook tiruan dari Firebase. Desain yang rapi — satu jalur pemrosesan untuk dua pemicu.

### 14.3 Empat skenario, dan mana yang berhasil

**Skenario A — Beli di web, belum punya akun app.** ✅ *Berjalan*

```
Bayar di goakal.com
  → Akal webhook → Cloud Run → sharing NotebookLM dibuka
  → (Cloud Run menulis transaksi status "success" ke Firestore)
  → User daftar di app → onUserCreate menyala
     → cari transactions dengan email sama & status success
     → ambil expiry terjauh, kalau masih berlaku:
        set plan, subscription_expiry, questions_used = 0
        sambungkan uid ke dokumen transaksi
  → Akses terbuka
```

Ini jalur yang dirancang matang dan bekerja.

**Skenario B — Sudah punya akun app, lalu beli di web.** ❌ *Tidak otomatis*

`onUserCreate` adalah trigger `onCreate` — hanya menyala **sekali seumur hidup dokumen user**. Pengguna yang sudah mendaftar (dan sudah punya dokumen dengan `plan: "trial"`) lalu membeli belakangan tidak akan tersentuh trigger apa pun.

Di repo ini tidak ada trigger `onUpdate` pada `transactions`, tidak ada `onWrite` yang memantau status pembayaran. Kecuali Cloud Run ikut menulis langsung ke `users/{uid}`, **akses pengguna ini tidak akan pernah terbuka di app.**

Ini kemungkinan besar skenario yang paling sering terjadi — orang mencoba app dulu, habis kuota trial, baru membeli.

**Skenario C — Beli lewat app.** ⚠️ *Menggantung*

```
Tekan paket → createCheckout
  → tulis transaksi { status: "pending", customer_email, plan, amount }
  → buka goakal.com di browser
  → app menampilkan dialog "Menunggu Pembayaran"
  → StreamBuilder memantau users/{uid}
```

Tiga masalah di sini:

1. **Tidak ada korelasi.** `createCheckout` mengembalikan URL kursus Akal yang generik — `trxId` tidak pernah dikirim ke Akal. Tidak ada nomor pesanan, tidak ada referensi. Transaksi `pending` di Firestore tidak punya kaitan apa pun dengan pembayaran yang benar-benar terjadi. Penyambungan hanya bisa lewat email, belakangan.
2. **Field wajib tidak ditulis.** `onUserCreate` dan `verifySubscriptionFirestore` sama-sama membaca `subscription_expires_at` dan `entitlement_key`. `createCheckout` tidak menulis keduanya. Transaksi buatan app, kalaupun ditandai `success`, **tidak bisa mengaktifkan apa pun**.
3. **Dialog tidak pernah selesai.** Karena user ini sudah punya dokumen (`onUserCreate` sudah lewat), tidak ada yang mengubah `plan`-nya. Dialog "Menunggu Pembayaran" menggantung selamanya sampai ditutup manual.

Transaksi `pending` juga menumpuk tanpa ada yang membersihkan.

**Skenario D — Perpanjangan langganan.** ❌ *Tidak otomatis*

Sama seperti Skenario B — dokumen user sudah ada, tidak ada trigger yang menyala.

### 14.4 Bug pada daftar layanan

Di `notifySubscriptionServer`:

```typescript
const services = ["AI Fikih Tahawwulat", "AI Hadits", "AI Tafsir"];
for (const service of services) { /* kirim webhook */ }
```

Daftar ini **hardcoded dan tidak melihat modul apa yang sebenarnya dibeli.** Akibatnya:

- Beli modul apa pun → server disuruh membuka sharing untuk **Tahawwulat, Hadits, dan Tafsir sekaligus**. Pembeli satu modul mendapat tiga.
- **"Super AI Fikih Syafi'i" dan "AI Bahasa Arab" tidak ada di daftar** — dua modul yang sudah berstatus `active` di app ini tidak pernah dishare otomatis kepada siapa pun.
- Saat kedaluwarsa, sharing ketiga layanan dicabut serentak tanpa memeriksa apakah pengguna masih berlangganan salah satunya.

"AI Hadits" dan "AI Tafsir" sendiri masih `coming_soon` di app — daftar ini tampaknya peninggalan rencana lama yang tidak pernah diperbarui.

### 14.5 `entitlements` tidak pernah diisi oleh kode yang hidup

`getAgentUrl` memeriksa `entitlements[key]` **lebih dulu** sebelum jatuh ke `plan` global. Tapi di seluruh repo ini, satu-satunya yang menulis `entitlements` adalah `verifySubscriptionFirestore` — dan fungsi itu **tidak pernah dipanggil** karena router `chatGate` sudah tidak memakainya (§10.3).

Artinya model per-modul yang jadi tulang punggung pemisahan akses antar modul hanya bisa terisi lewat Cloud Run atau lewat pengisian manual di konsol. `onUserCreate` dan `dailyRevoke` sama-sama hanya menyentuh `plan` global.

Konsekuensi praktisnya: **membeli satu modul membuka semua modul**, karena `plan` global berlaku untuk apa saja.

### 14.6 Trial gratis yang bisa diperbarui terus

`dailyRevoke` menurunkan pengguna kedaluwarsa dengan:

```typescript
await doc.ref.update({
  plan: "trial",
  subscription_expiry: null,
  questions_used: 0,      // ← kuota trial di-reset
});
```

Setiap kali langganan berakhir, pengguna mendapat **10 pertanyaan gratis lagi**. Berlangganan sebulan, biarkan habis, dapat trial baru. Reset ini masuk akal untuk `onUserCreate` (pengguna baru), tapi salah untuk pencabutan.

`dailyRevoke` juga tidak pernah menyentuh `entitlements`. Entitlement per modul yang sudah kedaluwarsa tidak pernah dibersihkan — untungnya `getAgentUrl` tetap memeriksa tanggal, jadi ini soal kebersihan data, bukan lubang akses.

### 14.7 Rangkuman kondisi

| Aspek | Kondisi |
|---|---|
| Beli di web → daftar app | ✅ berjalan otomatis |
| Sudah punya akun → beli belakangan | ❌ tidak ada trigger |
| Beli lewat app | ⚠️ menggantung, tanpa korelasi |
| Perpanjangan | ❌ tidak ada trigger |
| Pemisahan akses antar modul | ❌ satu beli, semua terbuka |
| Daftar layanan sharing | ❌ hardcoded, dua modul aktif terlewat |
| Kuota trial saat kedaluwarsa | ❌ di-reset, bisa diulang |
| Pembersihan transaksi pending | ❌ tidak ada |

### 14.8 Bentuk yang seharusnya

Masalah akarnya satu: **otomasi digantung pada `onUserCreate`, padahal peristiwa yang sebenarnya penting adalah "transaksi berubah jadi success" — bukan "user mendaftar".**

Perbaikannya adalah memindahkan titik pemicu:

```
Sumber pembayaran (Akal / Play Billing)
        │
        ▼
  webhook masuk (verifikasi tanda tangan + idempoten)
        │
        ▼
  tulis transactions/{id} { status: "success",
                            entitlement_key, subscription_expires_at }
        │
        ▼
  ┌─ TRIGGER onWrite transactions/{id} ────────────┐
  │  1. cari user berdasarkan email                │
  │  2. kalau ada  → perbarui entitlements[key]    │
  │     kalau belum→ simpan ke pending_grants      │
  │  3. panggil server sharing DENGAN nama layanan │
  │     yang sesuai entitlement_key                │
  │  4. catat ke sharing_log                       │
  └────────────────────────────────────────────────┘
        │
        ▼
  onUserCreate → cek pending_grants berdasarkan email
                 (jaring pengaman, bukan mesin utama)
```

Perubahan konkretnya:

1. **Trigger baru `onTransactionSuccess`** — `functions.firestore.document("transactions/{id}").onWrite`, bereaksi saat status berubah jadi `success`. Ini menutup Skenario B, C, dan D sekaligus.
2. **Peta entitlement → nama layanan**, menggantikan array hardcoded di `notifySubscriptionServer`:
   ```typescript
   const SERVICE_NAMES: Record<string, string> = {
     fiqh_tahawwulat: "AI Fikih Tahawwulat",
     fiqh_syafii:     "Super AI Fikih Syafi'i",
     nahwu:           "AI Bahasa Arab",
   };
   ```
3. **`createCheckout` menulis `entitlement_key` dan `subscription_expires_at`**, serta mengirim `trxId` ke Akal sebagai referensi pesanan bila API-nya mendukung.
4. **`dailyRevoke` berhenti me-reset `questions_used`**, dan mulai membersihkan `entitlements` yang kedaluwarsa satu per satu — bukan mencabut ketiga layanan serentak.
5. **`UserModel` di Flutter mengenal `entitlements`**, agar UI dan server sepakat soal siapa berhak atas apa.
6. **Pembersih transaksi pending** — cron yang menandai `expired` transaksi `pending` yang lebih tua dari 24 jam.
7. **Verifikasi tanda tangan + idempotensi** pada webhook Akal di sisi Cloud Run, kalau belum ada.

Butir 1 dan 2 memberi hasil terbesar. Keduanya bisa dikerjakan dalam satu hari dan langsung menutup tiga dari empat skenario yang sekarang gagal.




