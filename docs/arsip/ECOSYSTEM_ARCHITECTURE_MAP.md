# PETA ARSITEKTUR LENGKAP EKOSISTEM OPENTURATH AI (END-TO-END)
### Dokumentasi Master Integrasi: Flutter App, Cloud Functions, Cloud Run Microservice, NotebookLM, & Bot Telegram

---

## 1. DIAGRAM ALUR INTEGRASI EKOSISTEM (END-TO-END FLOW)

```
┌───────────────────────────────────────────────────────────────────────────┐
│                      1. FRONTEND: FLUTTER CLIENT                          │
│  - openturath_ai/lib/ (Dashboard, WebView Kajian, Langganan, Tersimpan)   │
└─────────────────────┬───────────────────────────────▲─────────────────────┘
                      │                               │
        [1. Buka AI / │                 [2. InAppWebView Session]
         Tukar Kode / │                     notebooklm.google.com
         Bayar DOKU]  │                     (DOM Cleaner Injected)
                      ▼                               │
┌─────────────────────────────────────────────────────┴─────────────────────┐
│                 2. BACKEND: FIREBASE CLOUD FUNCTIONS                      │
│  - openturath_ai/functions/src/index.ts (Node.js 20, TypeScript)          │
│  - Endpoints: getAgentUrl, redeemCode, createCheckout, checkPaymentStatus │
└─────────┬──────────────────────┬────────────────────────────┬─────────────┘
          │                      │                            │
   [Notifikasi Instan]     [Database Update]          [Trigger Webhook]
          │                      │                     X-Internal-Secret
          ▼                      ▼                            ▼
┌──────────────────┐   ┌───────────────────┐   ┌────────────────────────────┐
│ 3. BOT TELEGRAM  │   │ 4. CLOUD FIRESTORE│   │ 5. CLOUD RUN MICROSERVICE  │
│  @openturath_bot │   │  users/{uid}      │   │  openturath-subscription   │
│  Chat: 2015667548│   │  transactions/    │   │  (Python / Flask Server)   │
│  (Alert Admin)   │   │  redeem_codes/    │   │  webhook_server.py         │
└──────────────────┘   │  outbox_queue/    │   └──────────────┬─────────────┘
                       └───────────────────┘                  │
                                                   [Google Batch RPC: JFMDGd]
                                                   notebooklm_manager.py
                                                              ▼
                                               ┌────────────────────────────┐
                                               │ 6. GOOGLE NOTEBOOKLM (RAG) │
                                               │  7 Notebook Kanonikal:     │
                                               │  - Fikih Syafi'i           │
                                               │  - Ushul Fiqih             │
                                               │  - Hadits & Syarah         │
                                               │  - Tafsir Ahkam & Matsur   │
                                               │  - Bahasa Arab & Nahwu     │
                                               │  - Fikih Tahawwulat Bayan  │
                                               │  - Tahawwulat Muhaqqiq     │
                                               └────────────────────────────┘
```

---

## 2. KOMPONEN-KOMPONEN DI DALAM ARSIP LENGKAP INI

Arsip ZIP ini mengumpulkan **seluruh repositori dan subsistem terkait** agar AI Auditor dapat memahami 100% cara kerja aplikasi:

### A. Aplikasi Klien (`openturath_ai/`)
- **`lib/`**: Seluruh antarmuka Flutter, logika state, sanitasi pencarian Arab (`arabic_search_normalizer.dart`), manajemen bookmark lokal (`bookmark_service.dart`), dan tema syar'i.
- **`lib/screens/agent_webview_screen.dart`**: Layar webview hybrid composition yang memuat Google NotebookLM dengan proteksi URL whitelist dan jembatan bridge JavaScript.
- **`lib/core/notebook_ui_script.dart`**: Skrip injeksi CSS & JavaScript DOM Cleaner yang membersihkan header Google, tombol bagikan, tab sources, dan disclaimer bot.
- **`assets/data/canonical_syafii.json`**: Database rujukan 87 kitab mu'tamad Mazhab Syafi'i (Thabaqat 1 s/d 6).
- **`test/`**: 21 berkas unit & integration tests (98 test case lulus 100%).
- **`android/`, `ios/`, `macos/`, `web/`**: Konfigurasi platform native runner.

### B. Backend Cloud Functions (`openturath_ai/functions/`)
- **`src/index.ts`**:
  - `redeemCode`: Memvalidasi kode voucher (misal `PERDANA`), mengaktifkan hak akses 7 hari di Firestore, mengirim notifikasi instan ke Bot Telegram admin, dan menembak webhook Cloud Run.
  - `getAgentUrl`: Mengambil URL notebook privat berdasar evaluasi entitlement pengguna.
  - `createCheckout`: Menghasilkan URL pembayaran DOKU Hosted Checkout dengan signature HMAC-SHA256.
  - `checkPaymentStatus` / `dokuWebhook`: Idempotent payment verification and transaction state updates.
  - `dailyRevoke`: Scheduled cron function untuk mencabut akses akun yang telah habis masa berlakunya.
  - `sendTelegramNotification`: Helper pengirim pesan instan via Telegram Bot API (`api.telegram.org/bot<TOKEN>/sendMessage`).

### C. Server Provisioning Cloud Run (`ecosystem/openturath_subscription/`)
- **`webhook_server.py`**:
  - Webhook listener yang berjalan di Google Cloud Run (`https://openturath-subscription-255541559800.asia-southeast2.run.app/webhook`).
  - Menerima event `subscription.paid` atau `voucher_access`.
  - Memvalidasi header `X-Internal-Secret`.
  - Memanggil `notebooklm_manager.py` untuk menambahkan email pengguna ke ke-7 notebook Google secara otomatis.
- **`notebooklm_manager.py`**:
  - Menghubungi endpoint internal Google NotebookLM (`https://notebooklm.google.com/_/LabsTailwindUi/data/batchexecute?rpcids=JFMDGd`) menggunakan sesi autentikasi master (`master_token.json` / cookie).
  - Menambahkan email pengguna sebagai *Viewer* tanpa mengirimkan email spam Google.
- **`autonomous_reaper.py`**:
  - Daemon otomatis untuk memindai akun kadaluarsa di Firestore dan mencabut hak pembaca di Google NotebookLM via RPC `QDyure`.
- **`Dockerfile` & `requirements.txt`**:
  - Konfigurasi deployment container produksi di Cloud Run (Python 3.11).

### D. Skrip & Otomasi Pendukung (`ecosystem/scripts/`)
- **`find_notebook_ids.js`**: Skrip inspeksi ID notebook dari Google Workspace.
- **`sharing_daemon.js` & `notebooklm_sharer.js`**: Daemon Node.js alternatif untuk auto-sharing.

### E. Instrumen Audit & Prompt Master (Root)
- **`MASTER_UI_UX_DEFECTS_PROMPT.md`**: Master prompt perbaikan 12 kecacatan visual & flow berdasarkan 5 tangkapan layar pengujian.
- **`MASTER_AUDIT_PROMPT_COMPREHENSIVE.md`**: Master prompt audit komprehensif 7 dimensi (keamanan, performa, UI, alur, logika, fitur, adab).
- **`AUDIT_KOMPREHENSIF_OPENTURATH_AI.md`**: Laporan audit forensik mendalam sebelumnya.
- **`PROJECT_HANDOVER.md` & `AGENTS.md`**: Standar operasional kerja dan katalog harga resmi.
- **`OPENTURATH_AI_MASTER_AUDIT_PACK.txt`**: Dokumen monolitik 22.015 baris yang merangkum seluruh kode Flutter & backend dalam 1 file teks.

---

## 3. ALUR OPERASIONAL DETIL (VOUCHER, PEMBAYARAN, & SHARING)

### A. Alur Klaim Voucher (`PERDANA`):
1. Pengguna membuka menu Pengaturan/Langganan di aplikasi -> Memasukkan kode `PERDANA`.
2. Klien Flutter memanggil Firebase Cloud Function `redeemCode`.
3. `redeemCode` menjalankan transaksi Firestore:
   - Memastikan voucher aktif dan kuota belum habis (`times_used < max_uses`).
   - Mencatat penukaran di `users/{uid}/redeemed_vouchers/PERDANA`.
   - Mengaktifkan `entitlements.all_access` selama 7 hari (`newExpiry = now + 7 days`).
   - Mengubah status akun `isSubscriptionActive: true`, `plan: 'voucher_access'`.
4. **Notifikasi Telegram Seketika**: Cloud Function memanggil `sendTelegramNotification` ke Bot Telegram `@openturath_bot` (Chat ID `2015667548`):
   *"🔔 [VOUCHER SANTRI DIKLAIM] - Kode: PERDANA - Email: user@gmail.com - Durasi: 7 Hari"*.
5. **Auto-Provisioning Cloud Run**: Cloud Function menembak `POST /webhook` ke Cloud Run dengan payload `service = "Paket Semua AI"`.
6. Cloud Run (`webhook_server.py`) memanggil `notebooklm_manager.py`:
   - Melakukan batch RPC Google `JFMDGd` untuk mendaftarkan email `user@gmail.com` sebagai *Viewer* di ke-7 notebook.
7. Pengguna langsung dapat membuka ruang kajian AI tanpa terbentur halaman Google 403.

### B. Alur Pembayaran DOKU:
1. Pengguna memilih paket di aplikasi (`tholib_1m`, `tholib_6m`, `bahits_1y`).
2. Cloud Function `createCheckout` membuat invoice DOKU dan mengembalikan `payment_url`.
3. Pengguna menyelesaikan pembayaran melalui QRIS / Virtual Account / Kartu.
4. Server DOKU mengirim notifikasi HTTP POST ke webhook Cloud Function.
5. Cloud Function memverifikasi signature HMAC-SHA256, mengaktifkan entitlement langganan, mengirim notifikasi Telegram, dan memicu Cloud Run untuk mendaftarkan akun di NotebookLM.

---

## 4. PEMETAAN ID NOTEBOOK KANONIKAL RESMI

| Nama Modul AI | Endpoint Cloud Functions Key | NotebookLM ID |
| :--- | :--- | :--- |
| **AI Fikih Syafi'i** | `fiqh_syafii` | `334e7b83-0e76-4787-a1d6-314642a35862` |
| **AI Ushul Fiqih** | `ushul_fiqh` | `6ab6dae8-0067-435a-85ca-b6bd4e17dd12` |
| **AI Hadits & Syarah** | `hadits` | `b9626501-538c-4358-a44f-6731eaec50b6` |
| **AI Tafsir Al-Qur'an** | `tafsir` | `df92cc50-1106-4221-8748-1663f00fa7fe` |
| **AI Bahasa Arab & Nahwu**| `bahasa_arab` | `15bc4cef-4b94-4241-b05a-d50a586bde06` |
| **AI Fikih Tahawwulat Bayan**| `fiqh_tahawwulat_bayan`| `483d0291-0a70-411c-bff0-f1ea4b83b2fd` |
| **AI Fikih Tahawwulat Muhaqqiq**| `fiqh_tahawwulat` | `dc7ee7e4-f4ad-4db6-9cd0-0013727abbe4` |
