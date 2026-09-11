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

## 2. Status Terkini: 100% Selesai & Terverifikasi

### A. Refactoring Arsitektur UI/UX "Minimalist Purism & AI for Islamic Scholarship"
1. **Desain Minimalis Murni (Pure Minimalist)**:
   - **Tanpa Logo Grafis**: Top bar Beranda menggunakan tipografis murni terpusat `OpenTurath` dalam Newsreader serif tanpa tanggal ganda atau subketerangan.
   - **Slogan Global Konsisten**: `"AI for Islamic Scholarship"` menggantikan seluruh sisa `"Riset kitab turats"`.
   - **Kartu Spesialis Bersih**: Tanpa kotak ikon, tanpa teks Arab pendamping, dan tanpa baris sub-keterangan berantakan. Hanya judul bersih, badge status jika belum tersedia, dan chevron `>`.
   - **Pencarian Stadium Pill Bersih**: Menghilangkan border ganda ("buletan dalam buletan") dari TextField di Beranda dan Keilmuan.
   - **Pembersihan Modal Ruang Riset**: Menghapus opsi "Buka di Browser Eksternal" dan menghapus seluruh sub-penjelasan di bawah tiap opsi.
   - **Pembersihan Disclaimer Gemini**: Seluruh teks disclaimer ("Gemini may display inaccurate info...", dll.) disapu bersih via CSS dan MutationObserver script.
   - **Animasi Antar-Tab Halus**: Mengganti `IndexedStack` dengan `PageView` ber-controller animasi (`Curves.easeOutCubic`, 300ms) untuk transisi tab yang hidup dan mulus.
2. **Hasil Verifikasi**:
   - `flutter analyze lib/`: **0 issues found** (100% bersih).
   - `flutter test`: **51 dari 51 test case LULUS 100%**.
   - **Binary Release APK**: `/Users/apple/Downloads/ramadhan/app-release-latest.apk` (58.6 MB, SHA-256: `f049b00e24a9513bc40d7b5459f1a4ff06353987ee4b4438e30b70f1c7a079a0`).

---

## 3. Katalog Harga Tunggal (Single Source of Truth)
- **Paket Lengkap (Semua Spesialis)**:
  - Bulanan: **Rp 99.000**
  - 6 Bulan: **Rp 499.000**
  - 1 Tahun: **Rp 799.000** (Hemat 25%)
- **Modul Satuan Fikih Tahawwulat**: **Rp 50.000 / bulan**

---

## 4. Git Commits Riwayat Terkini
- `7a47a07`: `fix(ui): eliminate card icons, arabic titles, cluttered descriptions, external browser option, search inner borders, and inject smooth tab animations`
- `8370e00`: `feat(ui): restore minimalist purism, centered wordmark, grouped settings, and AI for Islamic Scholarship slogan`
- `749279c`: `fix(ui): restore tactile Apple micro-interactions, authentic scholarly copywriting, and intuitive academic desk`
- `444f9d9`: `fix(ui): overhaul scholarly dashboard, eliminate NotebookLM header banner, and elevate SpecialistCard aesthetics`
- `cf3f22b`: `fix(ui): dialog ergonomics, checkout navigation safety, and 333-line forensic copy overhaul (F33, F38, F49-F60, C001-C333)`

---

## 5. Instruksi Cepat untuk Agen di Sesi Baru
Jika pengguna membuka chat baru dan meminta:
- *"Lanjutkan pengerjaan OpenTurath sesuai PROJECT_HANDOVER.md"*:
  1. Langsung pahami seluruh status di atas.
  2. Tanyakan apakah pengguna ingin melakukan kompilasi build APK rilis final, melakukan pengujian di emulator/device, atau ingin mereview tampilan tertentu.
  3. Selalu patuhi **Rule 1 (Git commit otomatis per perubahan)** dan **Rule 2 (Integritas release APK)**.
