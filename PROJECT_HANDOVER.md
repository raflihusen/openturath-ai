# OpenTurath AI — Project Handover & Context Snapshot
**Terakhir Diperbarui:** 12 September 2026 (Fase: Copywriting Overhaul Lengkap & Rilis APK v1.0.21+22 Terverifikasi)

Dokumen ini berfungsi sebagai jembatan konteks instan (*zero-friction context handover*). Setiap agen atau sesi chat baru di Antigravity IDE dapat langsung membaca dokumen ini untuk melanjutkan pekerjaan tanpa perlu penjelasan ulang dari pengguna.

---

## 1. Identitas & Batasan Mutlak Proyek (Non-Negotiable)
- **Target Platform**: **Android** (Material 3 Adaptive), **macOS & Windows** (Desktop Adaptive).
- **Versi Rilis Terkini**: **`v1.0.21+22`** (Binary: `/Users/apple/Downloads/ramadhan/app-release-latest.apk`).
- **Batasan Eksplisit**:
  - **TIDAK ADA rilis iOS / App Store**.
  - **TIDAK ADA rilis Google Play Store**. Pembaruan aplikasi mandiri via internal updater berbasis SHA-256.
  - **TIDAK ADA open trial bebas** (kuota pertanyaan terbuka). Digantikan dengan **Sistem Voucher Redeem Kode Terkontrol** (`redeemCode`) terintegrasi Google Cloud NotebookLM share invite.
- **Protokol Wajib `AGENTS.md`**:
  - **Rule 1: Automatic Checkpoint Protocol**: Setiap modifikasi sekecil apapun WAJIB langsung di-commit ke Git secara otomatis (`git add <files> && git commit -m "<type>(<scope>): <pesan>"`).
  - **Rule 2: Integritas Build & Release**: Verifikasi 100% proses kompilasi sebelum rilis, update binary rilis dengan timestamp valid.

---

## 2. Status Terkini: 100% Selesai & Terverifikasi (v1.0.21+22)

### A. Copywriting Overhaul Lengkap (Quiet Scholar Principles)
1. **Pusat String Kanonik (`AppCopy` di `lib/core/app_copy.dart`)**:
   - Single source of truth untuk seluruh teks UI dan pesan dinamis.
   - Bersih dari kata-kata brosur AI (*korpus*, *penelaahan*, *fasilitas*, *komprehensif*, *secara menyeluruh*, *berbasis*, *terintegrasi*, *optimal*, *presisi*, *solusi*).
   - Larangan tanda seru (`!`) pada notifikasi keberhasilan umum (*"Tersimpan ke simpanan."*, *"Jawaban tersalin."*, *"Akun Anda sudah dihapus."*).
2. **Navigasi & Ruang Kajian**:
   - Tab navigasi: `Beranda`, `Kajian`, `Tersimpan`, `Pengaturan`.
   - Slogan resmi: `Membaca kitab, menelusuri ibarah.`
   - Loader tenang: *"Membuka kajian..."*, dialog adab telaah *"Catatan sebelum mulai"*, placeholder *"Tanyakan sesuatu tentang kitab ini..."*.
3. **Backend Cloud Functions & Chat Wrapper (`functions/src/index.ts`)**:
   - Redeem voucher: *"Kode diterima. Akses ke [service] sudah aktif."*
   - Pembayaran: *"Pembayaran terverifikasi. Akses Anda sudah aktif."* dan *"Pembayaran masih menunggu penyelesaian."*
   - Batas kuota: *"Kuota uji coba sudah habis. Berlangganan untuk lanjut."*
   - Web wrapper chat: Prompt terstandardisasi, toast tenang *"Pertanyaan tersalin. Tempelkan di kolom chat."*.
4. **Verifikasi Mutu & Pengujian**:
   - `flutter analyze lib/`: **0 issues found**.
   - `flutter test`: **58 dari 58 test case LULUS 100%** (termasuk unit test suite `test/copywriting_test.dart`).
   - `npm run build` (Functions): **TypeScript tsc 100% BERSIH tanpa error**.
   - **Kompilasi Rilis**: `flutter build apk --release` sukses 100% (58.6 MB, SHA-256: `38170f3b2f6b72be5566ee241db730bf2ac06cf5af10ddf19a570de35e156a7d`).

---

## 3. Katalog Harga Tunggal (Single Source of Truth)
- **Paket Lengkap (Semua Spesialis)**:
  - Bulanan: **Rp 99.000**
  - 6 Bulan: **Rp 499.000**
  - 1 Tahun: **Rp 799.000** (Hemat 25%)
- **Modul Satuan Fikih Tahawwulat**: **Rp 50.000 / bulan**

---

## 4. Git Commits Riwayat Terkini
- `257cdcd`: `chore(release): bump version to 1.0.21+22 for release build`
- `d43d293`: `test(copy): add copywriting regression assertions and update audit pack`
- `4db467b`: `fix(copy): update backend messages, prompts, and wrapper toast in Cloud Functions`
- `ce2b36b`: `fix(copy): align library sheet, error states, and app initialization with AppCopy`
- `66e02a6`: `fix(copy): overhaul navigation, profile, settings, and bookmark screens to calm library tone`
- `7b13c82`: `fix(copy): update model descriptions, suggested prompts, and app tagline to calm library tone`
- `27f642a`: `fix(copy): apply calm scholarly Indonesian copywriting to agent_webview_screen`
- `cf1ec77`: `feat(copy): add centralized AppCopy repository with canonical quiet scholar strings`

---

## 5. Instruksi Cepat untuk Agen di Sesi Baru
Jika pengguna membuka chat baru dan meminta:
- *"Lanjutkan pengerjaan OpenTurath sesuai PROJECT_HANDOVER.md"*:
  1. Langsung pahami seluruh status di atas.
  2. Tanyakan apakah pengguna ingin melakukan kompilasi build APK rilis final, melakukan pengujian di emulator/device, atau ingin mereview tampilan tertentu.
  3. Selalu patuhi **Rule 1 (Git commit otomatis per perubahan)** dan **Rule 2 (Integritas release APK)**.
