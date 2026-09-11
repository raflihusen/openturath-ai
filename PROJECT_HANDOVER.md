# OpenTurath AI — Project Handover & Context Snapshot
**Terakhir Diperbarui:** 11 September 2026 (Fase: Arsitektur UI/UX "Quiet Scholar Adaptive" Selesai & Terverifikasi)

Dokumen ini berfungsi sebagai jembatan konteks instan (*zero-friction context handover*). Setiap agen atau sesi chat baru di Antigravity IDE dapat langsung membaca dokumen ini untuk melanjutkan pekerjaan tanpa perlu penjelasan ulang dari pengguna.

---

## 1. Identitas & Batasan Mutlak Proyek (Non-Negotiable)
- **Target Platform**: **Android** (Material 3 Adaptive), **macOS & Windows** (Desktop Adaptive).
- **Batasan Eksplisit**:
  - **TIDAK ADA rilis iOS / App Store**.
  - **TIDAK ADA rilis Google Play Store**. Pembaruan aplikasi mandiri via internal updater berbasis SHA-256.
  - **TIDAK ADA open trial bebas** (kuota pertanyaan terbuka). Digantikan dengan **Sistem Voucher Redeem Kode Terkontrol** (`redeemCode`) terintegrasi Google Cloud NotebookLM share invite.
  - **DILARANG membuat/menimpa APK rilis final** (`/Users/apple/Downloads/ramadhan/app-release-latest.apk`) sampai pengguna memberikan instruksi eksplisit untuk build rilis.
- **Protokol Wajib `AGENTS.md`**:
  - **Rule 1: Automatic Checkpoint Protocol**: Setiap modifikasi sekecil apapun WAJIB langsung di-commit ke Git secara otomatis (`git add <files> && git commit -m "<type>(<scope>): <pesan>"`).
  - **Rule 2: Integritas Build & Release**: Verifikasi 100% proses kompilasi sebelum rilis.

---

## 2. Status Terkini: 100% Selesai & Terverifikasi (Forensic Audit Hardened)

### A. Resolusi Audit Forensik 360° (Putaran 1 & Putaran 2)
1. **Layer 1 — Client Flutter & Ergonomi UI**:
   - **F-03 & F-10**: Subtitle langganan palsu di Profil dieliminasi. Status langganan kini 100% dinamis dan akurat.
   - **F-09**: Rasio kontras tombol destruktif "Hapus Akun & Data Riset" ditingkatkan hingga memenuhi standar aksesibilitas WCAG AA (>= 4.5:1).
   - **F-10**: `userStream` di-cache sebagai broadcast stream terkelola tunggal (mencegah listener Firestore churn & memory leak saat mengetik di search bar).
   - **F-11**: Tombol Back Android (`onPopInvokedWithResult`) memanggil `_onTabSelected(0)` sehingga `_pageController` tersinkronisasi mulus ke tab Beranda.
   - **F-04**: Pembersihan `window.otMasterObserver` eksplisit di JS dan controller cleanup dalam `finally` pada `dispose()` WebView.
   - **F-12**: Deteksi tahun banner NotebookLM menggunakan regex generik `/\b(19|20)\d{2}\b/`.
   - **F-08**: Debounce timer 200ms pada pencarian katalog perpustakaan.
   - **F-05**: Timeout 5 detik pada antrean mutex `_synchronized` BookmarkService.
   - **F-19**: Serialisasi tanggal ISO-8601 pada `ModuleEntitlement` dan `UserModel` untuk cache offline aman tanpa crash `jsonEncode`.
   - **F-20**: DOKU checkout sheet mendeteksi status `'paid'` (server) di samping `'success'`.
   - **F-31**: Tipografi judul korpus spesialis menerapkan Newsreader serif ilmiah 3 lapis.
   - **F-28**: Slogan konsisten dalam Bahasa Indonesia ilmiah: `'Telaah ibarah dari marja\' mu\'tamad'`.

2. **Layer 2 — Backend Cloud Functions & Aturan Firestore**:
   - **F-01 (P0)**: `dailyRevoke` memeriksa masa aktif tiap modular entitlement di peta `entitlements`, mencabut modul satuan yang telah kedaluwarsa, dan merekam job ke `provisioning_outbox`.
   - **F-02 (P0)**: Cron worker `processProvisioningOutbox` (setiap 5 menit) memproses outbox provisioning/revocation NotebookLM hingga 8 kali percobaan dengan backoff aman.
   - **F-02 (Audit 2)**: Rate-limiting pada callable `checkPaymentStatus` (maksimal 15 panggilan/menit per UID).
   - **F-03 & F-05**: Rate-limiting brute force protection pada `redeemCode` (maksimal 8 percobaan/15 menit per UID).
   - **F-06**: Signature webhook DOKU diverifikasi menggunakan constant-time `crypto.timingSafeEqual` dan penolakan timestamp skew > 15 menit dengan HTTP 401.
   - **F-07**: Tulis dokumen transaksi berstatus `"pending"` sebelum memanggil API checkout gateway DOKU.
   - **F-08**: Eliminasi pembuatan dokumen user ber-ID acak (`db.collection("users").doc()`).
   - **F-01 (Audit 2)**: Cron harian `cleanupOrphanedDeletions` untuk membersihkan dokumen Firestore bertanda `pending_deletion` jika akun Auth telah terhapus.
   - **F-15**: Pemetaan judul spesialis lengkap untuk `aqidah`, `tarikh`, `tasawwuf`, dan `sirah`.
   - **firestore.rules**: Mengunci koleksi server-only (`rate_limits`, `redeem_attempts`, `provisioning_outbox`) dan memvalidasi `photo_url.size() <= 1000`.

3. **Layer 3 — Pengujian Unit & Sinkronisasi Katalog**:
   - **F-29**: Sinkronisasi jumlah katalog menjadi **87 kitab mu'tamad** (sesuai data riil `canonical_syafii.json`).
   - **F-17**: Pengujian unit langsung terhadap kode produksi `AgentWebviewScreen.isAllowedNotebookUrl` dan `SubscriptionService.normalizeCode`.
   - **F-11 (Audit 2)**: Pengujian batas kalender kabisat (29 Februari) dan non-kabisat (28 Februari) pada `HijriDateUtils.addCalendarMonthsClamped`.
   - `flutter analyze lib/`: **0 issues found** (100% bersih).
   - `flutter test`: **52 dari 52 test case LULUS 100%**.
   - `npm run build` (Functions): **Kompilasi TypeScript tsc 100% BERSIH tanpa error**.

---

## 3. Katalog Harga Tunggal (Single Source of Truth)
- **Paket Lengkap (Semua Spesialis)**:
  - Bulanan: **Rp 99.000**
  - 6 Bulan: **Rp 499.000**
  - 1 Tahun: **Rp 799.000** (Hemat 25%)
- **Modul Satuan Fikih Tahawwulat**: **Rp 50.000 / bulan**

---

## 4. Git Commits Riwayat Terkini
- `147befb`: `fix(client): resolve forensic audit findings F-03, F-04, F-05, F-08, F-10, F-11, F-19, F-20, F-22, F-31 in Flutter app`
- `f138228`: `fix(security): lock server collections and permit pending_deletion update in firestore.rules`
- `8d8e6c1`: `fix(backend): resolve forensic audit findings F-01, F-02, F-04, F-06, F-07, F-08, F-15 in Cloud Functions`
- `583e50b`: `test(hardening): verify calendar leap year clamping, test production code directly, and align catalog count to 87`

---

## 5. Instruksi Cepat untuk Agen di Sesi Baru
Jika pengguna membuka chat baru dan meminta:
- *"Lanjutkan pengerjaan OpenTurath sesuai PROJECT_HANDOVER.md"*:
  1. Langsung pahami seluruh status di atas.
  2. Tanyakan apakah pengguna ingin melakukan kompilasi build APK rilis final, melakukan pengujian di emulator/device, atau ingin mereview tampilan tertentu.
  3. Selalu patuhi **Rule 1 (Git commit otomatis per perubahan)** dan **Rule 2 (Integritas release APK)**.
