# 🏛️ AUDIT KOMPREHENSIF EKOSISTEM OPENTURATH AI

> **Jenis:** Audit teknis, arsitektur, keamanan, produk & kepatuhan menyeluruh (full-stack).
> **Tanggal audit:** September 2026
> **Dasar:** Pembacaan langsung kode sumber (bukan sekadar dokumentasi) seluruh repositori di workspace `/Users/apple/Downloads/ramadhan/`, lintas semua komponen.
> **Versi aplikasi yang diaudit:** `openturath_ai` `1.0.3+4` · Aplikasi Flutter Android + Firebase Cloud Functions + Python Cloud Run + Cloudflare Worker + Chrome Extension + Landing Page.
> **Status:** Tidak ada berkas yang diubah selama audit. Semua referensi baris mengacu pada kondisi berkas saat dibaca.

---

## DAFTAR ISI

1. [Ringkasan Eksekutif](#1-ringkasan-eksekutif)
2. [Peta Repositori & Komponen](#2-peta-repositori--komponen)
3. [Model Bisnis & Aset Sesungguhnya](#3-model-bisnis--aset-sesungguhnya)
4. [Arsitektur Tingkat Tinggi](#4-arsitektur-tingkat-tinggi)
5. [Alur Pembayaran → Aktivasi Akses (End-to-End)](#5-alur-pembayaran--aktivasi-akses-end-to-end)
6. [Katalog Produk, Harga & Entitlement](#6-katalog-produk-harga--entitlement)
7. [Audit Aplikasi Flutter](#7-audit-aplikasi-flutter)
8. [Audit Backend Cloud Functions](#8-audit-backend-cloud-functions)
9. [Audit Server Subscription Python](#9-audit-server-subscription-python)
10. [Audit Proxy Cloudflare](#10-audit-proxy-cloudflare)
11. [Audit Chrome Extension](#11-audit-chrome-extension)
12. [Audit Landing Page](#12-audit-landing-page)
13. [Matriks Temuan Keamanan](#13-matriks-temuan-keamanan)
14. [Matriks Temuan Arsitektur & Kebersihan Kode](#14-matriks-temuan-arsitektur--kebersihan-kode)
15. [Kepatuhan Rilis Google Play](#15-kepatuhan-rilis-google-play)
16. [Prioritas Tindakan Rekomendasi](#16-prioritas-tindakan-rekomendasi)

---

## 1. RINGKASAN EKSEKUTIF

**OpenTurath AI bukan aplikasi AI.** Ia adalah **gerbang berlangganan berbayar (paywall wrapper)** yang membungkus **Google NotebookLM** yang telah dikurasi dengan korpus kitab klasik dan transkrip ceramah ulama (Habib Abu Bakar Al-Adni, Syekh Ahmad Ma'bad). Seluruh kecerdasan—retrieval, nalar, sitasi—dikerjakan oleh NotebookLM. Aplikasi hanya menangani tiga hal:

1. **Identitas** — siapa pengguna (Google Sign-In → Firebase Auth).
2. **Hak akses** — apakah dia berlangganan modul yang diminta (Cloud Function + Firestore entitlement).
3. **Penyajian** — membungkus NotebookLM dalam kemasan "native" dan menyembunyikan asal-usulnya (WebView/iframe + suntikan CSS/JS).

**Aset yang sesungguhnya adalah korpus**, bukan kodenya. Konsekuensinya, setiap keputusan teknis harus dinilai dari pertanyaan *"apakah ini melindungi dan memperkuat akses ke korpus?"*.

### ⚡ Kondisi keseluruhan saat audit

| Dimensi | Kondisi | Catatan |
|---|---|---|
| **Visual/UI** | 🟢 Matang (±80–85%) | Desain terinspirasi NotebookLM/Gemini, konsisten, shell 4-tab modern. |
| **Keamanan akses server-side** | 🟢 Sangat membaik | Firestore rules terkunci; entitlement per-modul; server otoritatif. |
| **Keamanan secret & kredensial** | 🔴 **Kritis** | Secret produksi plaintext di disk, beberapa hardcode di source & APK. |
| **Otomasi pelanggan** | 🟠 Sebagian | Aktivasi bergantung webhook; tidak ada trigger DB; dua jalur paralel. |
| **Kesesuaian harga & data** | 🔴 **Kritis** | Harga & ID notebook inkonsisten di banyak tempat. |
| **Kebersihan kode** | 🟠 Banyak dead code | `PLAN_CATALOG`, `drive_sharing.ts`, variabel env tak terpakai. |
| **Kepatuhan Play Store** | 🟠 Menengah | applicationId `com.example`, tanda tangan debug, sebagian compliance sudah ada. |
| **Ketergantungan platform** | 🟠 Berisiko | Seluruh produk bergantung pada NotebookLM (iframe + RPC internal). |

---

## 2. PETA REPOSITORI & KOMPONEN

```
/Users/apple/Downloads/ramadhan/
├── openturath_ai/                ← APLIKASI FLUTTER + FIREBASE (inti produk)
│   ├── lib/                      Aplikasi Flutter (Android/iOS/Web)
│   │   ├── main.dart             Entry point, init Firebase, routing, RTL global
│   │   ├── firebase_options.dart Auto-generate flutterfire (project: open-turath)
│   │   ├── core/                 theme, constants, localization, app_config, routes, arabic_utils
│   │   ├── models/               agent, user, sub_agent, book, bookmark, field
│   │   ├── screens/              splash, login, main_shell, dashboard, specialist_list,
│   │   │                         agent_webview, subscription, bookmark, profile, settings,
│   │   │                         google_session_auth
│   │   ├── services/             auth, agent, subscription, doku, bookmark, research_notes
│   │   └── widgets/              app_error_state, evidence_bottom_sheet, openturath_brand
│   ├── functions/src/            index.ts (Cloud Functions) + drive_sharing.ts (tidak dipakai)
│   ├── android/                  Konfigurasi Android
│   ├── assets/                   Sudah terisi (images + animations)
│   ├── test/                     Sudah berisi tes nyata
│   ├── firestore.rules           Aturan keamanan (sudah diperketat)
│   └── *.apk                     Berkas rilis/cadangan
│
├── openturath_subscription/      ← SERVER PYTHON CLOUD RUN (otomasi payment→sharing)
│   ├── webhook_server.py         Server HTTP utama
│   ├── notebooklm_manager.py     Sharing NotebookLM via RPC internal (cookie)
│   ├── akal_client.py            Client REST API GoAkal/Akal
│   ├── autonomous_reaper.py, chat_only_sentinel.py, run_reaper_daemon.py
│   ├── sync_akal_to_firestore.py, manual_sync.py, akal_sync.py
│   ├── clone_master_notebook.py, stress_test_notebooklm.py, export_auth.py
│   ├── Dockerfile, .env, env.yaml, master_token.json, storage_state.json
│
├── openturath_proxy/             ← CLOUDFLARE WORKER (auth-gate web + iframe)
│   ├── wrangler.toml
│   └── src/index.js
│
├── openturath_extension/         ← CHROME EXTENSION MV3 (skin + perpustakaan jawaban)
│   ├── manifest.json, content.js/css, popup, dashboard, lib/constants.js
│
├── openturath_landing_page.tsx   ← HALAMAN MARKETING (React/TSX, standalone)
│
├── *.md                          Banyak dokumen PRD/arsitektur/rencana (banyak yg sudah kedaluwarsa)
├── *.ipynb / *.py / *.js         Skrip ingestion transkripsi & otomasi content (produksi korpus)
└── *.apk, LOGO, korpus turats    Aset pendukung & file sensitif (service-account.json, dll)
```

> ⚠️ **Catatan penting:** Ruang kerja ini bukan satu repo git yang bersih—ia adalah *working folder* berisi produk + banyak skrip produksi konten + dokumen + file sensitif yang **tidak boleh** pernah di-commit (lihat §13).

---

## 3. MODEL BISNIS & ASET SESUNGGUHNYA

### 3.1 Cara menghasilkan uang
- Pelanggan membeli **langganan modul** melalui **GoAkal (goakal.com)** atau langsung di dalam aplikasi via **DOKU** (gateway pembayaran).
- Produk yang dijual: akses ke **NotebookLM** berisi kitab/ceramah tertentu selama periode tertentu.

### 3.2 Katalog modul saat ini (di aplikasi, `defaultAgents`)
6 modul **active** + 3 **coming_soon**:

| # | ID | Judul | Bidang Ilmu | Status | Harga server (1bln/6bln/1thn) |
|---|---|---|---|---|---|
| 1 | `fiqh_tahawwulat` | AI Fikih Tahawwulat | Fikih | active | 49k / 249k / 449k |
| 2 | `fiqh_syafii` | AI Fikih Syafi'i | Fikih | active | 25k / 125k / 225k |
| 3 | `hadits` | AI Hadits & Syarah Sunnah | Hadis | active | 25k / 125k / 225k |
| 4 | `tafsir` | AI Tafsir Al-Qur'an | Tafsir | active | 25k / 125k / 225k |
| 5 | `ushul_fiqh` | AI Ushul Fiqih | Usul Fiqh | active | 25k / 125k / 225k |
| 6 | `nahwu_sharaf` | AI Bahasa Arab & Balaghah | Bahasa Arab | active | 25k / 125k / 225k |
| 7 | `aqidah` | AI Aqidah & Ilmu Kalam | Aqidah | coming_soon | 25k / 125k / 225k |
| 8 | `tarikh` | AI Sejarah & Sirah | Sejarah | coming_soon | 25k / 125k / 225k |
| 9 | `habib_umar` | AI Habib Umar bin Hafiz | Tasawuf | coming_soon | — |

> **Perhatian:** Di UI, katalog *berstatus active* hanya 6 modul, tetapi beberapa bagian app mempromosikan "**Paket Sultan (Semua 30 AI)**". Angka "30 AI" tidak cocok dengan 6 modul aktif — ini merupakan ketidaksesuaian pemasaran/UI yang harus diputuskan.

### 3.3 8 Bidang Ilmu (konsep baru UI `FieldModel`)
Dashboard "Beranda" dikelompokkan per **bidang ilmu**, bukan per agent:
`Fikih`, `Hadis`, `Tafsir`, `Aqidah`, `Usul Fiqh`, `Bahasa Arab`, `Sejarah & Sirah`, `Tasawuf & Akhlaq`. Setiap bidang menunjuk satu/lebih `agentIds`. Ini merupakan evolusi signifikan dari desain lama berbasis kartu agent.

### 3.4 Sub-agent (persona)
Satu bidang/modul bisa punya beberapa **persona**: mis. `Al-Muhaqqiq` (dalil + ibarah lengkap), `Al-Bayan` (penyederhana), `Al-Mu'rib`/`Al-Tashrif` (nahwu). Secara teknis bisa menunjuk notebook sama/beda.

---

## 4. ARSITEKTUR TINGKAT TINGGI

```
┌────────────────────────┐      ┌──────────────────────────────────────────────┐
│  APLIKASI FLUTTER      │      │  FIREBASE / PIHAK KETIGA                      │
│  (Android)             │      ├──────────────────────────────────────────────┤
│                        │      │ Firebase Auth (Google Sign-In)               │
│  Splash → Login Google ┼─────▶│ users/{uid} (plan trial awal)                │
│  MainShell (4 tab)     │      │                                              │
│  Beranda/Spesialis/    │      │ CF getAgentUrl / recordQuestion              │
│  Bookmark/Profil       │      │   └─ cek entitlements + kuota → URL notebook │
│  │  pilih bidang →     │      │                                              │
│  │  spesialis → WebView┼─────▶│ notebooklm.google.com (iframe)               │
│  │                      │      │                                              │
│  Subscription (DOKU)   │      │ CF createCheckout / dokuWebhook              │
└────────────────────────┘      │ transactions • users.entitlements           │
                                └──────────────┬───────────────────────────────┘
                                               │ webhook payment
                                ┌──────────────▼──────────────────────────────┐
                                │  SERVER PYTHON CLOUD RUN (openturath_sub)  │
                                │  webhook_server.py + notebooklm_manager    │
                                │  → tulis Firestore                         │
                                │  → share email sbg VIEWER CHAT_ONLY ke      │
                                │    NotebookLM via RPC internal (cookie)     │
                                └────────────────────────────────────────────┘

  JALUR WEB (paralel):
  Cloudflare Worker (openturath_proxy) → login email + cek langganan Akal
      → cookie HMAC sesi → iframe NotebookLM (ai.openturath.com)

  CHROME EXTENSION → skin + simpan jawaban (chrome.storage.local)
  LANDING PAGE     → marketing statis, tidak terhubung ke produk
```

**Prinsip keamanan yang sudah benar:**
- URL NotebookLM **tidak pernah** ada di kode client Flutter; hanya di Cloud Functions/server, dan baru dikirim setelah entitlement diverifikasi. Jika APK dibongkar, tidak ditemukan alamat notebook dari sisi client.
- Firestore rules sudah membatasi penulisan `users`/`transactions` ke server (Admin SDK / Cloud Functions).
- Harga/durasi langganan dihitung server-side (tidak mempercayai angka client).

---

## 5. ALUR PEMBAYARAN → AKTIVASI AKSES (END-TO-END)

Bagian ini menelusuri satu pertanyaan terpenting: **"Kalau seseorang membayar, apakah aksesnya benar-benar terbuka otomatis?"**

### 5.1 Dua jalur pembayaran yang hidup berdampingan

**Jalur A — GoAkal/Akal (web + mayoritas):**
```
Bayar di goakal.com
  → Akal kirim webhook → openturath_subscription/webhook_server.py
  → verifikasi token
  → tulis transactions (idempoten) + update users/{email} entitlements
  → notebooklm_manager tambah email sbg VIEWER CHAT_ONLY ke notebook
  → notifikasi Telegram
```

**Jalur B — DOKU (langsung di dalam aplikasi):**
```
User tekan paket di app → SubscriptionService → DokuService.createCheckoutSession
  (panggil api-sandbox.doku.com; fallback ke CF createCheckout)
  → tulis transactions/{INV-...} status pending
  → buka URL pembayaran DOKU di browser eksternal
  → user bayar → DOKU kirim webhook → CF dokuWebhook
  → update users/{uid}.entitlements + transactions status success + reset kuota
  → notify server sharing (untuk buka NotebookLM)
```

### 5.2 Titik-titik yang perlu diperhatikan

1. **Dua bentuk transaksi berbeda.** Jalur client (DokuService) menyimpan dok `transactions/{INV-<epoch>}` dengan field `trxId`/`invoiceNumber`; jalur server (`createCheckout`) menyimpan dok id-otomatis dengan invoice `OT-<ts>-<rand>` dan field `entitlement_key`. Webhook DOKU mencocokkan berdasarkan `invoice_number` → **hanya akan merekonsiliasi transaksi ala-server**, tidak transaksi yang dibuat langsung oleh client `DokuService`. Dua jalur menghasilkan dua skema yang berbeda.
2. **Client vs server amount.** Jalur client mengirim *amount yang dihitung client* langsung ke DOKU; jalur server menghitung ulang otoritatif via `resolvePlanPricing`. Ini melanggar prinsip "jangan percaya amount client" bila jalur client yang dipakai.
3. **Tidak ada trigger Firestore `onWrite/onUpdate` pada `transactions`.** Aktivasi utama hanya terjadi lewat webhook HTTP. Bila webhook gagal/terlewat, tidak ada mesin DB yang memicu ulang (kecuali jalur lazy di web `chatGate` dan `onUserCreate` untuk pendaftar baru).
4. **`onUserCreate`** (trigger saat dokumen user baru dibuat) mencocokkan email ke transaksi `success` & mengaktifkan—tetapi **hanya transaksi expiry terjauh** dan **tidak menulis `entitlements`** (hanya `plan` global). Ini berbeda dari `dokuWebhook`/server Python yang menulis peta `entitlements` per-modul.
5. **Pengguna yang sudah punya akun lalu membeli belakangan** tidak disentuh trigger apa pun dari sisi DB — bergantung penuh pada webhook DOKU/Akal yang masuk.

### 5.3 Akses nyata ke konten (mekanisme)
- Python `notebooklm_manager` menambah email customer sebagai **VIEWER + CHAT_ONLY** pada notebook milik akun owner Google, lewat **RPC internal NotebookLM** (library `notebooklm-py` yang di-autentikasi dengan cookie sesi Google asli dari `master_token.json`/`storage_state.json`). **Bukan** Google Drive API/service account.
- Pelanggan memakai notebook saat login ke Google dengan email yang telah dishare; disajikan lewat iframe app/Cloudflare.

---

## 6. KATALOG PRODUK, HARGA & ENTITLEMENT

### 6.1 Model entitlement (`users/{uid}`)
- **Modern:** `entitlements = { <module_key>: { plan, expiry, status, updated_at } }`.
- **Legacy:** `plan`, `subscription_expiry`, `questions_used` (global, satu untuk semua modul).
- Server membaca `entitlements[key]` dulu, lalu fallback ke legacy. `all_access` memberi akses semua modul.

### 6.2 Pemetaan agent → entitlement key
`fiqh_tahawwulat_*` → `fiqh_tahawwulat`; `fiqh_syafii*` → `fiqh_syafii`; `nahwu*`/`bahasa_arab` → `nahwu`; `ushul_fiqh` → `ushul_fiqh`; `tafsir` → `tafsir`; `hadits` → `hadits`; `all_ai` → `all_access`. Agent tak dikenal → fallback ke namanya sendiri (bisa salah entitlement untuk agent baru yang belum dipetakan).

### 6.3 🔴 KETIDAKSESUAIAN HARGA (lintas sumber)
| Sumber | 1 Bulan | 6 Bulan | 1 Tahun | Keterangan |
|---|---|---|---|---|
| `PLAN_CATALOG` di server (`index.ts:15-19`) | 49k | 249k | 449k | **Dead code** — tidak pernah dibaca |
| `resolvePlanPricing` — Tahawwulat | 49k | 249k | 449k | **Harga yang sebenarnya ditagih** |
| `resolvePlanPricing` — modul standar | 25k | 125k | 225k | Harga modul syafii/hadits/tafsir/ushul/nahwu |
| `resolvePlanPricing` — `all_ai` (Paket Sultan) | 99k | 499k | 799k | Paket semua modul |
| `constants.dart` (`priceTholib1m` dst) | 49k | 249k | 449k | Label "Tholib/Bahits" generik |
| `agent_model.dart` — Tahawwulat | 49k | 249k | 449k | Tampilan per-modul |
| `agent_model.dart` — modul standar | 25k | 125k | 225k | Tampilan per-modul |

**Dampak:** Tidak ada satu sumber kebenaran harga. `PLAN_CATALOG` mengaku "satu-satunya sumber" padahal mati. Angka tampilan vs angka tagihan bisa berbeda tergantung layar. **Rekomendasi:** jadikan `resolvePlanPricing` (atau satu katalog) sebagai satu-satunya sumber, dan sajikan harga dari server ke UI.

### 6.4 ID notebook (perhatian lintas komponen)
Skema ID agent tidak seragam antara app/Cloud Functions (snake_case, mis. `nahwu_sharaf_muerib`) dan web/`AGENTS` (kebab-case, mis. `nahwu-sharaf-muerib`). Di beberapa komponen notebook Nahwu/Arab menunjuk UUID berbeda (`405b035c-…` vs `15bc4cef-…`). **Harus dipastikan mana yang benar** karena salah satu menunjuk notebook keliru (lihat §10–§11).

---

## 7. AUDIT APLIKASI FLUTTER (`openturath_ai/`)

### 7.1 Bootstrap & navigasi
- `main()`: orientasi portrait, `AppConfig.init()` (tema/bahasa dari SharedPreferences), Firebase init dalam try/catch (bila gagal tampil layar merah pesan developer—**jangan sampai ke pengguna akhir**).
- `OpenTurathApp` membungkus `MaterialApp` dalam `ValueListenableBuilder` untuk tema & bahasa; **RTL** ditangani global via `Directionality` bila bahasa `ar`.
- Route string-based: `/dashboard` dan `/main` **dua-duanya** memuat `MainShellScreen` (`/main` tidak pernah dipakai → dead route).
- Shell 4 tab: **Beranda | Spesialis | Bookmark | Profil** (`IndexedStack`), responsive (NavigationRail desktop / NavigationBar mobile), dengan kontrol tab via `InheritedWidget`.

### 7.2 Layar & fitur
- **Dashboard/Beranda:** grid 8 bidang ilmu, kutipan Arab, daftar "Lanjutkan Riset" dengan label waktu statis palsu (`'2 jam lalu'`/`'Kemarin'`), nama default `'Rafli Husen'` (sisa developer). Tidak lagi menampilkan kartu agent/order langsung (beberapa revisi lain menampilkan—lihat §7.6).
- **Spesialis:** daftar ramping agent per bidang, pencarian, metadata kitab, status akses.
- **WebView (inti):** §7.3.
- **Subscription:** paket modul (bulanan/tahunan) + "Paket Sultan (Semua 30 AI) Rp 99.000"; DOKU; mengumpulkan nomor WhatsApp (default `081234567890`).
- **Bookmark:** perpustakaan jawaban tersimpan (local).
- **Profil & Settings:** manajemen langganan, hubungkan sesi Google, tema, bahasa, logout, hapus akun, privasi/terms. Ada **duplikasi fitur** antara Profil dan Settings.
- **GoogleSessionAuth:** layar perantara untuk sesi Google kedua (potensi friksi "double login").

### 7.3 Agent WebView — jantung produk
- Meminta URL lewat `getAgentUrl` (Cloud Function) → error `permission-denied` memicu paywall dengan CTA ke subscription. **Enforcement akses server-side.**
- Menyuntik CSS/JS (`_hideElementsCss`, `_cloakScript`) untuk menyembunyikan logo/header/toolbar/disclaimer/akun Google NotebookLM, plus `MutationObserver` + re-injeksi pada `onLoadStop`/progress.
- **Kuota trial:** counter pertanyaan-per-pertanyaan di client **tidak terpasang**—`recordQuestion`/`incrementQuestionCount`/helper `hasAccessToAgent` **tidak dipanggil** di layar mana pun (verified via grep). Pengguna yang lolos gerbang awal bisa bertanya tanpa batas di sesi itu; batas 10 hanya dicek server saat meminta URL.
- **"Google session auth"** ada sebagai layar terpisah, bukan inline di webview.
- Evidence/citation modal dari ruang agent **statis/placeholder** (ibarah & buku contoh hardcoded), tidak mengurai jawaban asli.

### 7.4 Keamanan & ketahanan
- **Kredensial DOKU dikompilasi di APK** (`doku_service.dart:9-10`: clientId `BRN-…`, secretKey `SK-…`) + fallback hardcode di server.
- Webview `shouldOverrideUrlLoading` membatasi domain (`.google.com` dst) — masih cukup lebar.
- Banyak `catch (_)` senyap (resilience rendah).
- Offline handling hampir tidak ada.
- Aksesibilitas (Semantics/semanticLabel) minim.

### 7.5 Pengujian
- `test/` sekarang berisi **tes nyata**: `deep_test.dart`, `doku_direct_test.dart`, `resilience_and_compliance_test.dart`, `widget_test.dart` (bukan lagi semata template Flutter). Masih perlu cakupan lebih pada alur login-gagal/offline/webhook.

### 7.6 Catatan: kode sedang dalam fluktuasi
Beberapa berkas (dashboard, main_shell, specialist_list) berubah saat audit. Terdapat dua varian desain dashboard dalam riwayat (satu versi berbasis kartu agent + order "Sultan"; satu versi berbasis grid bidang). **Pastikan snapshot mana yang benar-benar di-deploy** sebelum mengambil keputusan desain/monetisasi.

---

## 8. AUDIT BACKEND CLOUD FUNCTIONS (`functions/src/index.ts`, 1832 baris)

### 8.1 Fungsi ter-deploy
| Nama | Tipe | Fungsi |
|---|---|---|
| `getAgentUrl` | callable | Cek entitlement/kuota trial → kembalikan URL notebook |
| `recordQuestion` | callable | Increment `questions_used` transaksional |
| `createCheckout` | callable | Bangun checkout DOKU, simpan transaksi pending |
| `dokuWebhook` | HTTP | Terima notifikasi DOKU; sukses → aktifkan entitlement |
| `onUserCreate` | trigger `users` onCreate | Rekonsiliasi transaksi sukses lama per email |
| `dailyRevoke` | cron `0 0 * * *` | Turunkan entitlement/plan kedaluwarsa ke trial |
| `chatGate` | HTTP | Versi web: login email + sesi cookie + iframe |

### 8.2 Yang SUDAH membaik dibanding audit terdahulu
- Firestore rules terkunci (user hanya-baca; create dibatasi plan trial; `transactions` write:false). **Tidak ada lagi celah "user menulis plan sendiri".**
- Ada `recordQuestion` server-side transaksional.
- `chatGate` (versi functions) kini **menerapkan login email + cookie HMAC sesi + verifikasi entitlement per-request** (berbeda dengan laporan lama yang menyebutnya terbuka).

### 8.3 Temuan yang MASIH bertahan
- 🔴 **`PLAN_CATALOG` dead code** (diduga "satu-satunya sumber harga", tak pernah dibaca).
- 🔴 **Tidak ada trigger Firestore pada `transactions`** yang bereaksi terhadap `status=success`; aktivasi bergantung webhook HTTP.
- 🟠 `onUserCreate` tidak menulis `entitlements`, hanya legacy; hanya mengaktifkan transaksi expiry terjauh.
- 🟠 `dokuWebhook` **percaya sandbox tanpa tanda tangan** (tolak hanya bila `production`). `DOKU_PUBLIC_KEY` di env tak pernah dipakai (verifikasi asimetris tidak diimplementasikan).
- 🟠 `createCheckout` saat error memalsukan URL sandbox (`https://sandbox.doku.com/...`) dan tetap menyimpan transaksi `pending`.
- 🟠 Kredensial DOKU **hardcoded fallback** di source.
- 🟠 Daftar nama layanan sharing (untuk notify server) hardcoded & bisa tidak sinkron dgn modul yang aktif.
- 🟢 Server-side pricing (amount tidak dipercaya dari client) — benar.
- 🟡 `drive_sharing.ts` **tidak pernah di-import** (dead code; sharing nyata di server Python).
- 🟡 `getDokuConfig().apiKey`/`DOKU_API_KEY` dan `DOKU_PUBLIC_KEY` dibaca tapi tidak dipakai.
- 🟡 `.env` menyimpan `COOKIE_SECRET` tetapi kode mengharap `WEB_SESSION_SECRET` (config drift).

---

## 9. AUDIT SERVER SUBSCRIPTION PYTHON (`openturath_subscription/`)

### 9.1 Arsitektur
Cloud Run (Dockerfile, port 8080). `webhook_server.py` (server HTTP utama) menerima `POST /webhook`, `POST /telegram`, `GET /health`, `/keepalive`, `/cron/reap`. Membantu `notebooklm_manager.py` melakukan sharing NotebookLM. Terdapat banyak skrip daemon/CLI lain (`autonomous_reaper`, `chat_only_sentinel`, `run_reaper_daemon`, `sync_*`, `manual_sync`, `clone_master_notebook`, `stress_test`).

### 9.2 Alur
1. Akal kirim webhook → `parse_akal_payload` → `verify_akal_token` (HMAC constant-time vs secret di body) → `determine_plan_and_expiry` → `process_firestore_updates` (tulis `transactions` idempoten + update `users/{email}.entitlements` + legacy) → `notebooklm_manager` share/unshare → notifikasi Telegram.

### 9.3 🔴 Temuan keamanan & teknis
- 🔴 **Hardcoded kredensial Telegram nyata di source** (`autonomous_reaper.py:34-37` fallback env `TELEGRAM_BOT_TOKEN`/`TELEGRAM_CHAT_ID`).
- 🔴 **Secret produksi plaintext di disk**: `.env`/`env.yaml` berisi API key Akal, webhook secret, internal secret, bot Telegram, dan **`NOTEBOOKLM_AUTH_JSON` = cookie Google lengkap**; `master_token.json`, `storage_state.json`, `service-account.json` juga ada di workspace. Dige-pun, tetapi eksposur file/config = **pengambilalihan penuh akun owner** + API pembayaran.
- 🟠 **Bug telemetry**: `webhook_server.py` `/reap` & `/sync` membaca `authorized_count`/`errors` yang tidak ada di kembalian `AutonomousReaper.run_cycle()` → KeyError; `run_reaper_daemon.py` memanggil method `send_midnight_heartbeat` yang tak ada → daemon reaper tidak berfungsi benar.
- 🟠 **Ketergantungan pada API NotebookLM tidak resmi** (RPC internal + cookie minting via `notebooklm-py`/rookiepy/gpsoauth). Rapuh terhadap perubahan Google & rate-limit 429.
- 🟠 Storage-path cookie tidak konsisten antar daemon (relative `storage_state.json` vs `~/.notebooklm/profiles/...`).
- 🟠 Mapping produk→entitlement & notebook duplikat/drift; Nahwu tidak punya kunci produk di `PRODUCT_TO_NOTEBOOKS` padahal ada di `PRODUCT_TO_ENTITLEMENT_KEY`.
- 🟡 Tidak ada rate-limiting/ukuran body cap pada server HTTP.
- 🟡 `sync_akal_to_firestore.py` hardcode path lokal (`/Users/apple/.config/gcloud/...`) — hanya jalan lokal.

---

## 10. AUDIT PROXY CLOUDFLARE (`openturath_proxy/`)

- **Peran:** Worker auth-gate web: login email → verifikasi langganan Akal server-side → cookie sesi HMAC (HttpOnly, Secure, SameSite=Strict, 8 jam) → serve iframe `notebooklm.google.com/notebook/<id>/preview`.
- ✅ API key Akal hanya dipakai server-side (tidak bocor ke browser). Cookie ditandatangani (tamper-resistant). Error generik `not_found` (tidak membocorkan status).
- 🔴 **CSRF fallback `"fallback-not-secure"`** bila `COOKIE_SECRET` tidak diset → fail-open (tidak konsisten dgn verifikasi session yg fail-closed). CSRF berbasis timestamp+HMAC tanpa random.
- 🟠 **Duplikasi logika verifikasi langganan Akal** (tidak memanggil server Python/Firestore) → risiko drift.
- 🟠 Window akses stale hingga 8 jam setelah revoke (cookie tidak divalidasi ulang).
- 🟠 Nahwu agent menunjuk notebook `405b035c…` sedangkan server Python mem-provisi `15bc4cef…`; CUID Akal Nahwu memakai CUID Tahawwulat.

---

## 11. AUDIT CHROME EXTENSION (`openturath_extension/`)

- **Peran:** skin/whitelabel NotebookLM untuk pelanggan + "Jawaban Tersimpan" (`chrome.storage.local`, offline-only). Tidak ada backend/auth sendiri.
- Izin minimal (`storage`, `activeTab`, `clipboardWrite`), hanya untuk notebooklm.google.com → risiko rendah.
- 🟠 Prompt yang tersimpan kadang salah (diambil dari value input saat klik, bukan prompt asli yang menghasilkan jawaban). Scraping DOM NotebookLM rapuh.
- 🟠 Inkonsistensi ID notebook: menu modul dibangun dari `AGENTS` (`15bc4cef…`) sedangkan popup/dashboard hardcode Nahwu `405b035c…` yang tidak ada di `AGENTS` → sidebar tidak muncul di notebook itu.
- 🟡 `dashboard.html` terdaftar sebagai web_accessible_resource tapi tidak terjangkau → orphan.
- 🟠 Nomor WhatsApp placeholder (`628123456789`).
- 🔵 Tidak memvalidasi status langganan (hanya bergantung pada akses ke notebook yang sudah dishare server).

---

## 12. AUDIT LANDING PAGE (`openturath_landing_page.tsx`)

- **Peran:** halaman marketing React/TSX, estetika premium (emas `#D4AF37`, biru `#0071E3`, mode gelap/terang), narasi "zero-hallucination / ekstraksi verbatim", pricing tahunan Rp 3.000.000.
- ❗ **Semua CTA inert** (tanpa `onClick`/`href`); tidak ada tautan ke produk nyata (proxy `ai.openturath.com`, web app, ekstensi, APK, atau checkout Akal/GoAkal).
- Narasi marketing **tidak selaras** dgn produk nyata (NotebookLM + langganan) dan berpotensi overclaim kepatuhan.
- Skrip scroll `ImmersiveArchitecture` tanpa `passive`; offset-by-one minor pada index clamp.

---

## 13. MATRIKS TEMUAN KEAMANAN

| # | Severity | Temuan | Lokasi | Rekomendasi |
|---|---|---|---|---|
| 1 | 🔴 Kritis | Google session cookies lengkap & token (Note `NOTEBOOKLM_AUTH_JSON`), service account, API key plaintext di disk | `.env`, `env.yaml`, `master_token.json`, `storage_state.json`, `service-account.json` (root) | Rotasi sekarang; pindah ke Secret Manager/GCP; log out semua sesi Google; jangan pernah commit. |
| 2 | 🔴 Kritis | Token bot Telegram & chat ID hardcoded di source | `autonomous_reaper.py:34-37` | Hapus literal; baca env saja. |
| 3 | 🔴 Kritis | Kredensial DOKU (clientId & secretKey) dikompilasi di APK & fallback di source server | `doku_service.dart:9-10`; `functions/src/index.ts` | Pindah ke backend-only; jangan tanam secret di client. |
| 4 | 🟠 High | Webhook DOKU percaya traffic sandbox tanpa tanda tangan; `DOKU_PUBLIC_KEY` tak dipakai | `index.ts` dokuWebhook | Verifikasi signature selalu (aktifkan asimetris/RSA); wajibkan signature di semua env. |
| 5 | 🟠 High | Aktivasi bergantung webhook; tak ada trigger DB / retry / backfill pada `transactions` | seluruh stack | Tambah trigger `onWrite` transaksi sukses + mekanisme retry. |
| 6 | 🟠 High | CSRF fallback secret publik `"fallback-not-secure"` (fail-open) | proxy `index.js` | Fail-closed; wajibkan secret; tambah randomness. |
| 7 | 🟠 High | Secret internal lemah & dipakai lintas service tanpa rotasi | `.env` INTERNAL_SECRET | Generate acak ≥64 char; rotasi berkala; pisah per service. |
| 8 | 🟠 Medium | Kuota trial tidak ditegakkan per-pertanyaan setelah URL dibuka | `agent_webview_screen.dart` | Perkuat (batas struktural wrapper); ideal pindah ke chat native. |
| 9 | 🟠 Medium | `host.endsWith('.google.com')` terlalu lebar (potensi exfiltration) | `agent_webview_screen.dart` | Sempitkan whitelist domain. |
| 10 | 🟠 Medium | Tidak ada rate-limiting/body-cap pada server webhook | `webhook_server.py` | Tambah rate limit & max body. |
| 11 | 🔵 Low/Info | Email login web tanpa OTP/2FA (verifikasi hanya lewat status Akal) | proxy | Pertimbangkan OTP bila web jadi prioritas. |

---

## 14. MATRIKS TEMUAN ARSITEKTUR & KEBERSIHAN KODE

| # | Jenis | Temuan | Lokasi |
|---|---|---|---|
| 1 | Dead code | `PLAN_CATALOG` tidak pernah dibaca padahal diklaim "satu-satunya sumber harga" | `functions/src/index.ts:15` |
| 2 | Dead code | `drive_sharing.ts` tidak pernah di-import | `functions/src/drive_sharing.ts` |
| 3 | Dead code | Variabel env `DOKU_PUBLIC_KEY`, `DOKU_API_KEY`, `COOKIE_SECRET`, Midtrans tidak terpakai | `.env`, `.env.midtrans.backup` |
| 4 | Dead route | `/main` dan `/dashboard` memuat layar sama; `/main` tak dinavigasi | `lib/main.dart`, `lib/core/routes.dart` |
| 5 | Dead helper | `recordQuestion`, `incrementQuestionCount`, `hasAccessToAgent`, `watchUserSubscription`, `checkPaymentStatus` tak dipanggil | `lib/services/*`, `lib/models/user_model.dart` |
| 6 | Inkonsistensi | Harga bertentangan di ≥4 sumber (lihat §6.3) | constants, agent_model, index.ts |
| 7 | Inkonsistensi | ID agent snake_case vs kebab_case; notebook Nahwu berbeda antar komponen | app vs proxy vs extension vs server |
| 8 | Inkonsistensi | Dua skema transaksi (client `INV-…` vs server `OT-…`) | `doku_service.dart` vs `index.ts` |
| 9 | Bug | `onUserCreate` tidak menulis `entitlements`; hanya expiry terjauh | `index.ts` |
| 10 | Bug | Reaper telemetry baca key tak ada; panggil method tak ada | `webhook_server.py`, `run_reaper_daemon.py` |
| 11 | Duplikasi | Verifikasi langganan Akal di banyak tempat | functions, proxy, server, client |
| 12 | Duplikasi | Fitur Profil & Settings tumpang tindih | `profile_screen.dart`, `settings_screen.dart` |
| 13 | Placeholder | Nama user `'Rafli Husen'`, label waktu palsu, ibarah evidence statis, nomor WA/HP placeholder | dashboard, webview, settings, proxy, extension |
| 14 | Ketergantungan | Seluruh produk bergantung pada NotebookLM (iframe + RPC internal) — single point of failure | seluruh stack |

---

## 15. KEPATUHAN RILIS GOOGLE PLAY

| Kebutuhan | Status |
|---|---|
| Privacy policy URL publik | ✅ Ada (di-link `https://openturath.ai/privacy`) |
| Hapus akun di dalam app | ✅ Ada (`deleteAccount` di Profil & Settings) |
| Hapus akun via URL web | ⚠️ Belum jelas (perlu dipastikan) |
| Formulir Data Safety | ⚠️ Belum/tidak diverifikasi |
| Ikon adaptif | ⚠️ Perlu dipastikan |
| Splash screen Android 12+ | ⚠️ Perlu dipastikan |
| `applicationId` bukan `com.example` | 🔴 **Belum** (`com.example.openturath_ai`) — **penghambat** |
| Tanda tangan rilis (bukan debug) | 🔴 **Belum** — pakai debug key (`build.gradle.kts:40`) |
| Crashlytics / error reporting | ❌ Belum ada |
| `assetlinks.json` untuk deep link | ⚠️ `autoVerify` mungkin aktif tanpa file |
| Target SDK 36 (tenggat 31 Agu 2026 / perpanjangan 1 Nov 2026) | ⚠️ targetSdk mengikuti Flutter (belum dikunci) |
| Google Play Billing (konten digital) | ❌ Belum — DOKU/eksternal = risiko kebijakan pembayaran |
| Minimum Functionality (Kebijakan 4.3) | 🟠 Risiko — 95% waktu di WebView pihak lain |
| Lokalisasi lengkap | ⚠️ Sebagian besar UI masih hardcode Indonesia; RTL per-string |

---

## 16. PRIORITAS TINDAKAN REKOMENDASI

> Urutan berdasar dampak, bukan kemudahan. Bagian ini adalah rekomendasi audit; eksekusi menunggu keputusan Anda.

### P0 — Keamanan & aset (segera, < 1 hari)
1. **Rotasi semua secret produksi** (Google cookies/session, service account, API key Akal, secret DOKU, INTERNAL_SECRET, bot Telegram). Pindahkan ke Secret Manager/GCP/CF secrets, bukan `.env`/source.
2. **Hapus literal kredensial** dari `autonomous_reaper.py`, `doku_service.dart`, dan fallback di `index.ts`.
3. Tambahkan/verifikasi `.gitignore` root yang mengecualikan `.env`, `env.yaml`, `*.json` secret, `*.apk`, `chrome_session/`, `*.log`.

### P1 — Kelengkapan & konsistensi data (1–2 hari)
4. **Jadikan satu sumber kebenaran harga** (hapus `PLAN_CATALOG` dead atau pindahkan logika ke satu katalog) dan sajikan harga dari server ke UI.
5. **Samakan ID agent & notebook** antar app, proxy, extension, server; pastikan notebook Nahwu/Arab yang benar; perbaiki CUID Akal Nahwu.
6. **Satukan skema transaksi** (client vs server) agar webhook DOKU bisa merekonsiliasi semua.

### P2 — Otomasi pelanggan yang tangguh (1–2 hari)
7. Tambah **trigger Firestore `onWrite` pada `transactions`** yang memicu aktivasi saat `status=success`; buat `onUserCreate` menulis `entitlements`; sertakan backfill/retry.
8. Perbaiki bug daemon reaper & telemetry (`run_reaper_daemon.py`, `webhook_server.py`).

### P3 — Kepatuhan & rilis (2–4 hari)
9. Ubah `applicationId`/`namespace` ke ID final (mis. `ai.openturath.app`); daftar ulang Firebase; keystore rilis + `key.properties` di `.gitignore`; daftarkan SHA-1.
10. Kunci `targetSdk = 36`; lengkapi ikon adaptif, splash Android 12+, Data Safety, `assetlinks.json`, Crashlytics.
11. Putuskan strategi **Play Billing** (vs DOKU eksternal) untuk konten digital.
12. Perlunak WebView (kembalikan disclaimer akurasi, kurangi penyembunyian branding) + tambah bobot native (perpustakaan kitab, riwayat, bank prompt) untuk memperkuat argumen Minimum Functionality.

### P4 — Ketahanan UX & kebersihan (mingguan)
13. Ganti `catch (_)` dengan penanganan + pesan manusiawi + widget `AppErrorState(onRetry)`; tambah deteksi offline.
14. Hapus kode mati (`PLAN_CATALOG`, `drive_sharing.ts`, dead route, helper tak terpakai, `home_screen` bila ada); rapikan duplikasi Profil/Settings.
15. Tambah Semantics/semanticLabel & dukung textScaler; rampingkan top bar WebView.

---

## LAMPIRAN A — Perintah yang sering dipakai
```bash
# Flutter
cd openturath_ai
flutter pub get
flutter run
flutter build apk --release
flutter build appbundle --release
flutter test

# Cloud Functions
cd openturath_ai/functions
npm install && npm run build
cd .. && firebase deploy --only functions

# SHA-1 (Android)
cd openturath_ai/android && ./gradlew signingReport
```

## LAMPIRAN B — Catatan metodologi
- Audit dilakukan dengan pembacaan langsung kode (model/models, services, screens, widgets, functions/src, server Python, proxy, extension, landing) + pencarian lintas komponen + pembandingan dokumen PRD/arsitektur yang ada.
- Dokumen di repo (`ARCHITECTURE.md`, `RENCANA_KERJA.md`, `AUDIT_*`, `SECURITY_AUDIT_*`, PRD) sudah **sebagian kedaluwarsa** terhadap kondisi kode saat ini (yang telah banyak berubah: shell 4-tab, DOKU, entitlement per-modul, rules terkunci, dsb.). Dokumen ini mencatat kondisi **kode saat audit**.
- Karena beberapa berkas berubah selama audit, sejumlah referensi baris adalah akurat untuk kondisi akhir pembacaan; pastikan snapshot yang di-deploy sebelum bertindak atas temuan desain/monetisasi.

---
*— Akhir audit komprehensif OpenTurath AI —*
