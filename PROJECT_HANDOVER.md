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

### A. Refactoring Arsitektur UI/UX "Quiet Scholar Adaptive" (Layer 1 – Layer 9)
Filosofi: *"Konten adalah tokoh utama. UI harus mundur satu langkah."* (Digital scholarly research desk, minimal, tenang, bebas kebocoran warna emas neon).
1. **Core Design Tokens (`lib/core/design/`)**:
   - `OTColors`: Warm off-white canvas (`#FAFAF9`), deep obsidian dark canvas (`#0E0E10`), zinc contrast (`#18181B` / `#FAFAFA`), scholarly sapphire accent (`#2563EB` / `#60A5FA`), hairline borders 0.5px.
   - `OTTypography`: 3-Layer Strict Architecture:
     - Brand & Editorial: `Newsreader` (Serif) untuk logo, editorial hero, judul korpus.
     - Interface: `Outfit` (Sans) untuk navigasi, tombol, formulir, metadata, chip.
     - Arabic Scholarly: `Amiri` untuk teks Arab ilmiah (line-height `1.6`–`1.8`, RTL native). Dilengkapi `useSystemFontFallback` untuk test instan.
   - `OTSpacing`: Ritme kelipatan 4 (`xs:4, sm:8, md:12, base:16, lg:20, xl:24, xxl:32, huge:40, massive:48, jumbo:64`).
   - `OTRadius`: Kurva terukur (`input:14, card:16, sheet:24, dialog:20, chip:999, button:999`).
   - `OTMotion`: Durasi tenang (`fast:180ms, normal:220ms, sheet:280ms`) dan haptik.
2. **8 Layar Direfaktor Penuh**:
   - `main_shell_screen.dart`: Tanpa `BackdropFilter` 20px blur berat GPU; permukaan solid/subtle bersih dengan garis batas hairline 0.5px; adaptive bottom bar (mobile) & navigation rail (desktop).
   - `dashboard_screen.dart`: Editorial hero heading, pencarian real-time lintas spesialis, kartu Fikih Tahawwulat berdaulat dengan kaligrafi Arab Amiri, badge "Segera hadir" eksplisit.
   - `specialist_list_screen.dart`: Desain seragam ilmiah, chip filter bersih, indikator status modul.
   - `bookmark_screen.dart`: Unboxed empty state dengan CTA langsung `[ Mulai Menelusuri ]`, format kartu sitasi ilmiah dengan badge kitab/juz/halaman.
   - `profile_screen.dart`: Inset grouped sections, modal sheet tema 3 pilihan (`Ikuti Sistem`, `Mode Terang`, `Mode Gelap`), integrasi voucher redeem.
   - `subscription_screen.dart`: Progressive disclosure (kartu hero tunggal Rp 99.000 dengan durasi Bulanan/6 Bulan/1 Tahun), 4 manfaat inti, modul spesialis satuan di bawahnya, form klaim voucher.
   - `agent_webview_screen.dart`: **Menghapus 200+ baris CSS override destruktif** (`#0E0E10 !important` & `#FAFAFA !important`) yang sebelumnya memicu bug teks hitam di atas latar hitam pada NotebookLM. Top bar tenang dengan tombol overflow `•••` bottom sheet.
3. **Hasil Verifikasi**:
   - `flutter analyze`: **0 issues found** (100% bersih).
   - `flutter test`: **50 dari 50 test case LULUS 100%**.

---

## 3. Katalog Harga Tunggal (Single Source of Truth)
- **Paket Lengkap (Semua Spesialis)**:
  - Bulanan: **Rp 99.000**
  - 6 Bulan: **Rp 499.000**
  - 1 Tahun: **Rp 799.000** (Hemat 25%)
- **Modul Satuan Fikih Tahawwulat**: **Rp 50.000 / bulan**

---

## 4. Git Commits Riwayat Terkini
- `ead39ea`: `test(design): add Quiet Scholar token verification suite and test font fallback support`
- `16057cc`: `feat(webview): implement Quiet Scholar top bar with overflow sheet and eliminate destructive color overrides`
- `8a967dc`: `feat(subscription): implement progressive disclosure layout, segmented duration control, and disciplined Quiet Scholar design`
- `90312fb`: `feat(profile): implement Quiet Scholar layout, 3-choice theme modal sheet, and inset grouped settings`
- `fef9f35`: `feat(bookmarks): implement Quiet Scholar layout, unboxed empty state with CTA, and refined citations`
- `f5f4bf8`: `feat(specialists): apply Quiet Scholar tokens, clean category chips, and explicit Segera hadir badges`
- `ab42d11`: `feat(home): implement Quiet Scholar layout, global realtime search, and explicit status labels`
- `a030805`: `feat(shell): adapt navigation to Quiet Scholar design, eliminate heavy BackdropFilter blur, and use OT tokens`
- `e1e13ae`: `feat(design): implement Quiet Scholar Adaptive core token system (colors, typography, spacing, radius, motion)`

---

## 5. Instruksi Cepat untuk Agen di Sesi Baru
Jika pengguna membuka chat baru dan meminta:
- *"Lanjutkan pengerjaan OpenTurath sesuai PROJECT_HANDOVER.md"*:
  1. Langsung pahami seluruh status di atas.
  2. Tanyakan apakah pengguna ingin melakukan kompilasi build APK rilis final, melakukan pengujian di emulator/device, atau ingin mereview tampilan tertentu.
  3. Selalu patuhi **Rule 1 (Git commit otomatis per perubahan)** dan **Rule 2 (Integritas release APK)**.
