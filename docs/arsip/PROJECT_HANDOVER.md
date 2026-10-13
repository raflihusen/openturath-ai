# OpenTurath AI — Project Handover & Context Snapshot
**Terakhir Diperbarui:** 14 September 2026 (Fase: Transformasi Bahasa & Penyatuan Tone of Voice Quiet Scholar v2 — v1.0.26+27)

Dokumen ini berfungsi sebagai jembatan konteks instan (*zero-friction context handover*). Setiap agen atau sesi chat baru di Antigravity IDE dapat langsung membaca dokumen ini untuk melanjutkan pekerjaan tanpa perlu penjelasan ulang dari pengguna.

---

## 1. Identitas & Batasan Mutlak Proyek (Non-Negotiable)
- **Target Platform**: **Android** (Material 3 Adaptive), **macOS & Windows** (Desktop Adaptive).
- **Versi Rilis Terkini**: **`v1.0.26+27`** (Binary: `/Users/apple/Downloads/ramadhan/app-release-latest.apk`, Size: 60.6 MB, SHA-256: `5e69bfe02881a40fbb66eca733301cff38c195b190ebb724314501bb02254947`).
- **Batasan Eksplisit**:
  - **TIDAK ADA rilis iOS / App Store**.
  - **TIDAK ADA rilis Google Play Store**. Pembaruan aplikasi mandiri via internal updater berbasis SHA-256.
  - **TIDAK ADA open trial bebas** (kuota pertanyaan terbuka). Digantikan dengan **Sistem Voucher Redeem Kode Terkontrol** (`redeemCode`) terintegrasi Google Cloud NotebookLM share invite.
- **Protokol Wajib `AGENTS.md`**:
  - **Rule 1: Automatic Checkpoint Protocol**: Setiap modifikasi sekecil apapun WAJIB langsung di-commit ke Git secara otomatis (`git add <files> && git commit -m "<type>(<scope>): <pesan>"`).
  - **Rule 2: Integritas Build & Release**: Verifikasi 100% proses kompilasi sebelum rilis, update binary rilis dengan timestamp valid.

---

## 2. Status Terkini: 100% Selesai & Terverifikasi (v1.0.26+27)

### A. Transformasi Bahasa & Tone of Voice Kanonikal (Quiet Scholar v2)
1. **Eliminasi Istilah SaaS Produk Internal**:
   - Menghapus frasa kaku seperti *"ruang riset manuskrip AI"*, *"AI Spesialis"*, *"naskah primer terkatalogisasi"*, *"autentikasi sesi riset naskah turats"*, dan *"kurasi kebahasaan"*.
   - Mengganti dengan terminologi tradisi keilmuan yang tenang, bersahaja, dan alami: *"bidang"*, *"asisten"*, *"kitab"*, *"rujukan"*, dan *"hubungkan akun Google"*.
2. **Penyatuan Suara & Tagline Resmi**:
   - Menetapkan satu tagline kanonikal tunggal di seluruh aplikasi: **"Membaca kitab, menelusuri ibarah."** (menghilangkan variasi slogan bahasa Inggris).
3. **Pemisahan Aksi Salin vs Simpan & Integritas Rujukan**:
   - Memisahkan aksi pada menu percakapan: **Salin jawaban** (hanya ke clipboard sistem) dan **Simpan ke Catatan** (ke bookmark lokal).
   - Menghilangkan watermark promosi paksa (*"Disimpan melalui OpenTurath AI..."*) pada sitasi ilmiah guna menjaga otentisitas kutipan turats para peneliti.
4. **Pencegahan Regresi Copywriting UI**:
   - `test/copywriting_test.dart` diperluas dengan scanner regex yang memindai langsung file UI (`subscription_screen.dart`, `google_session_auth_screen.dart`, `profile_screen.dart`, `dashboard_screen.dart`, `library_screen.dart`, dsb.) untuk memastikan kata-kata terlarang tidak muncul kembali.

### B. Keamanan Moneter & Backend Cloud Functions (OT-F001, OT-F003)
1. **Penutupan Celah P0 `all_access`**:
   - `resolvePlanPricing()` menggunakan *strict closed-set whitelist* `PURCHASABLE_AGENTS` dan `MODULE_PLANS`.
   - Caller dilarang keras membeli entitlement global `all_access` atau `all_ai` dengan harga per-modul.
   - `getEntitlementKey()` menolak fallback ke input mentah klien.
2. **Eliminasi Double-Dispatch Provisioning**:
   - Fungsi `redeemCode` mencatat job berstatus `pending` ke `provisioning_outbox` secara atomik di dalam transaksi Firestore.
   - Panggilan langsung ke Cloud Run di luar transaksi dihapus; outbox worker `processProvisioningOutbox` (ber-lease dan ber-retry) menjadi *single source of truth*.
   - Kode voucher mentah pada notifikasi Telegram direduksi (`***`).

### C. Restorasi Performa UI & Animasi Ruang AI Bebas Lag (OT-F007, OT-F019)
1. **Pembersihan GPU Overhead**:
   - Menghapus `Transform.scale` pada seluruh `baseScaffold` (mencegah rasterisasi ulang pohon widget Dashboard/Navigasi pada setiap frame).
   - Menghapus `ScaleTransition` pada `AgentMultiTabRoom` (mencegah deformasi tekstur native Android PlatformView Chromium/WebView yang memicu lag dan stuttering).
2. **Animasi Geser Vertikal Murni (240ms)**:
   - Transisi vertikal murni sumbu Y (`0.12` ➔ `0.0`) dengan kurva `Curves.easeOutCubic` berdurasi 240 ms (penutupan 200 ms). Berjalan stabil di 60/120 FPS pada perangkat Android fisik.
   - Mendukung `MediaQuery.disableAnimations` untuk aksesibilitas *reduced motion*.
3. **Penutupan Double-Back Race Window (OT-F007)**:
   - `PopScope` di `MainShellScreen` memvalidasi `_roomAnimController.isDismissed`. Ketukan Back kedua saat animasi penutupan berlangsung diserap aman dan tidak menutup aplikasi.

### D. Keamanan Payment WebView & Kepatuhan Legal (OT-F005, OT-F006)
1. **Destination Allowlist DOKU Sheet**:
   - `shouldOverrideUrlLoading` memvalidasi skema `https` dan membatasi rute navigasi hanya ke domain resmi DOKU (`*.doku.com`, `*.doku.id`) dan domain aplikasi OpenTurath (`openturath-ai.web.app`, `openturath.ai`). URL di luar itu dibatalkan (`CANCEL`).
2. **Keselarasan Privasi & Penyimpanan**:
   - Teks pada `legal_copy.dart` dan `public/privacy.html` dikoreksi secara faktual menjadi *"penyimpanan aplikasi secara lokal pada perangkat Anda"*.

### E. Integritas Data Bibliografis Turats (OT-F011)
- Konsistensi identitas pengarang dan tahun wafat pada `canonical_syafii.json` divalidasi 100%:
  - *Al-Hidayah ila Auham al-Kifayah*: Atribusi kanonikal Al-Isnawi (w. 772 H).
  - *Bidayat al-Muhtaj fi Syarh al-Minhaj*: Atribusi kanonikal Ibnu Qadhi Syuhbah (w. 874 H).
  - *Ithaf al-Arib bi Syarh al-Ghayah wa at-Taqrib*: Atribusi kanonikal Asy-Syabrawi bin Abi al-Ma'athi.

### F. Verifikasi Mutu & Pengujian
- `flutter analyze lib/`: **0 issues found** (Analisis statis bersih 100%).
- `flutter test`: **133 dari 133 test case LULUS 100%**.
- `npm run build` (Functions): **TypeScript tsc 100% BERSIH tanpa error**.

---

## 3. Riwayat Git Checkpoint Penting
- `569f70b`: `chore(release): bump version ke 1.0.26+27 untuk rilis Quiet Scholar Copywriting v2`
- `6a17e78`: `test(regression): perbarui ekspektasi gelar asisten dan status error sesuai kamus kanonikal v2`
- `d636d56`: `test(copy): perluas pengujian copywriting untuk memindai file UI dan menegakkan kamus kanonikal v2`
- `edff1eb`: `fix(copy): selaraskan pesan error state dan exception sesuai kamus kanonikal v2`
- `96d804b`: `fix(copy): pisahkan aksi salin jawaban vs simpan catatan dan hapus watermark rujukan`
- `b67db6f`: `fix(copy): perbaiki istilah katalog perpustakaan menjadi kitab dan rapikan detail edisi`
- `8a92fb6`: `fix(copy): selaraskan teks profil, tier langganan, dan dialog bahasa sesuai kamus kanonikal v2`
- `c3de8c6`: `fix(copy): tetapkan tagline resmi kanonikal dan rapikan teks dashboard ke sentence case`
- `229a6fa`: `fix(copy): sederhanakan alur hubungkan akun Google tanpa istilah ruang riset manuskrip`
- `46675e8`: `fix(copy): selaraskan copywriting paket langganan dan hilangkan istilah AI Spesialis`
- `390b9a1`: `fix(copy): selaraskan penamaan asisten, sub-agen, dan suggested prompts ke gaya Quiet Scholar v2`
- `47efca9`: `fix(copy): terapkan Kamus Kanonikal v2 dan tata bahasa santri Quiet Scholar pada AppCopy`
- `ad4c449`: `fix(ui): restorasi performa animasi vertikal murni dan tutup double-back race window (OT-F007, OT-F019)`
- `935a571`: `fix(security): tutup celah P0 checkout all_access dan hilangkan double-dispatch provisioning (OT-F001, OT-F003)`

---

## 4. Instruksi Cepat untuk Agen di Sesi Baru
Jika pengguna membuka chat baru dan meminta:
- *"Lanjutkan pengerjaan OpenTurath sesuai PROJECT_HANDOVER.md"*:
  1. Langsung pahami seluruh status di atas.
  2. Selalu patuhi **Rule 1 (Git commit otomatis per perubahan)** dan **Rule 2 (Integritas release APK)**.
  3. Periksa ketersediaan test dan lakukan build release hanya setelah verifikasi kode 100% lulus.

