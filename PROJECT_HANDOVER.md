# OpenTurath AI — Project Handover & Context Snapshot
**Terakhir Diperbarui:** 14 September 2026 (Fase: Resolusi Audit Forensik 360° & Restorasi Performa Bebas Lag — v1.0.24+25)

Dokumen ini berfungsi sebagai jembatan konteks instan (*zero-friction context handover*). Setiap agen atau sesi chat baru di Antigravity IDE dapat langsung membaca dokumen ini untuk melanjutkan pekerjaan tanpa perlu penjelasan ulang dari pengguna.

---

## 1. Identitas & Batasan Mutlak Proyek (Non-Negotiable)
- **Target Platform**: **Android** (Material 3 Adaptive), **macOS & Windows** (Desktop Adaptive).
- **Versi Rilis Terkini**: **`v1.0.24+25`** (Binary: `/Users/apple/Downloads/ramadhan/app-release-latest.apk`).
- **Batasan Eksplisit**:
  - **TIDAK ADA rilis iOS / App Store**.
  - **TIDAK ADA rilis Google Play Store**. Pembaruan aplikasi mandiri via internal updater berbasis SHA-256.
  - **TIDAK ADA open trial bebas** (kuota pertanyaan terbuka). Digantikan dengan **Sistem Voucher Redeem Kode Terkontrol** (`redeemCode`) terintegrasi Google Cloud NotebookLM share invite.
- **Protokol Wajib `AGENTS.md`**:
  - **Rule 1: Automatic Checkpoint Protocol**: Setiap modifikasi sekecil apapun WAJIB langsung di-commit ke Git secara otomatis (`git add <files> && git commit -m "<type>(<scope>): <pesan>"`).
  - **Rule 2: Integritas Build & Release**: Verifikasi 100% proses kompilasi sebelum rilis, update binary rilis dengan timestamp valid.

---

## 2. Status Terkini: 100% Selesai & Terverifikasi (v1.0.24+25)

### A. Keamanan Moneter & Backend Cloud Functions (OT-F001, OT-F003)
1. **Penutupan Celah P0 `all_access`**:
   - `resolvePlanPricing()` menggunakan *strict closed-set whitelist* `PURCHASABLE_AGENTS` dan `MODULE_PLANS`.
   - Caller dilarang keras membeli entitlement global `all_access` atau `all_ai` dengan harga per-modul.
   - `getEntitlementKey()` menolak fallback ke input mentah klien.
2. **Eliminasi Double-Dispatch Provisioning**:
   - Fungsi `redeemCode` mencatat job berstatus `pending` ke `provisioning_outbox` secara atomik di dalam transaksi Firestore.
   - Panggilan langsung ke Cloud Run di luar transaksi dihapus; outbox worker `processProvisioningOutbox` (ber-lease dan ber-retry) menjadi *single source of truth*.
   - Kode voucher mentah pada notifikasi Telegram direduksi (`***`).

### B. Restorasi Performa UI & Animasi Ruang AI Bebas Lag (OT-F007, OT-F019)
1. **Pembersihan GPU Overhead**:
   - Menghapus `Transform.scale` pada seluruh `baseScaffold` (mencegah rasterisasi ulang pohon widget Dashboard/Navigasi pada setiap frame).
   - Menghapus `ScaleTransition` pada `AgentMultiTabRoom` (mencegah deformasi tekstur native Android PlatformView Chromium/WebView yang memicu lag dan stuttering).
2. **Animasi Geser Vertikal Murni (240ms)**:
   - Transisi vertikal murni sumbu Y (`0.12` ➔ `0.0`) dengan kurva `Curves.easeOutCubic` berdurasi 240 ms (penutupan 200 ms). Berjalan stabil di 60/120 FPS pada perangkat Android fisik.
   - Mendukung `MediaQuery.disableAnimations` untuk aksesibilitas *reduced motion*.
3. **Penutupan Double-Back Race Window (OT-F007)**:
   - `PopScope` di `MainShellScreen` memvalidasi `_roomAnimController.isDismissed`. Ketukan Back kedua saat animasi penutupan berlangsung diserap aman dan tidak menutup aplikasi.

### C. Keamanan Payment WebView & Kepatuhan Legal (OT-F005, OT-F006)
1. **Destination Allowlist DOKU Sheet**:
   - `shouldOverrideUrlLoading` memvalidasi skema `https` dan membatasi rute navigasi hanya ke domain resmi DOKU (`*.doku.com`, `*.doku.id`) dan domain aplikasi OpenTurath (`openturath-ai.web.app`, `openturath.ai`). URL di luar itu dibatalkan (`CANCEL`).
2. **Keselarasan Privasi & Penyimpanan**:
   - Teks pada `legal_copy.dart` dan `public/privacy.html` dikoreksi secara faktual menjadi *"penyimpanan aplikasi secara lokal pada perangkat Anda"*.

### D. Integritas Data Bibliografis Turats (OT-F011)
- Konsistensi identitas pengarang dan tahun wafat pada `canonical_syafii.json` divalidasi 100%:
  - *Al-Hidayah ila Auham al-Kifayah*: Atribusi kanonikal Al-Isnawi (w. 772 H).
  - *Bidayat al-Muhtaj fi Syarh al-Minhaj*: Atribusi kanonikal Ibnu Qadhi Syuhbah (w. 874 H).
  - *Ithaf al-Arib bi Syarh al-Ghayah wa at-Taqrib*: Atribusi kanonikal Asy-Syabrawi bin Abi al-Ma'athi.

### E. Verifikasi Mutu & Pengujian
- `flutter analyze lib/`: **0 issues found** (Analisis statis bersih 100%).
- `flutter test`: **132 dari 132 test case LULUS 100%**.
- `npm run build` (Functions): **TypeScript tsc 100% BERSIH tanpa error**.

---

## 3. Riwayat Git Checkpoint Penting
- `ee3d18f`: `fix(catalog): koreksi atribusi pengarang kanonikal dan tahun wafat kontradiktif (OT-F011)`
- `9f1f952`: `fix(legal): selaraskan klaim penyimpanan catatan dengan implementasi lokal perangkat (OT-F006)`
- `b823158`: `security(payment): terapkan destination allowlist ketat pada DOKU checkout WebView (OT-F005)`
- `ad4c449`: `fix(ui): restorasi performa animasi vertikal murni dan tutup double-back race window (OT-F007, OT-F019)`
- `935a571`: `fix(security): tutup celah P0 checkout all_access dan hilangkan double-dispatch provisioning (OT-F001, OT-F003)`
- `78cd4d3`: `security(rules): perketat validasi dan kepemilikan client_error_logs (AUD-04)`
- `0ea400a`: `fix(ui): selaraskan textAlign RTL Arab dan bersihkan peringatan analyzer (AUD-06, AUD-07)`
- `b21ae70`: `fix(session): perbaiki pergeseran indeks tab saat closeTab dan batasi maxTabs 7 (AUD-03)`
- `6cd559f`: `fix(navigation): terapkan per-route in-flight window 450ms pada NavigationGuard (AUD-01)`

---

## 4. Instruksi Cepat untuk Agen di Sesi Baru
Jika pengguna membuka chat baru dan meminta:
- *"Lanjutkan pengerjaan OpenTurath sesuai PROJECT_HANDOVER.md"*:
  1. Langsung pahami seluruh status di atas.
  2. Selalu patuhi **Rule 1 (Git commit otomatis per perubahan)** dan **Rule 2 (Integritas release APK)**.
  3. Periksa ketersediaan test dan lakukan build release hanya setelah verifikasi kode 100% lulus.
