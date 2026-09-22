# MASTER PROMPT: KAJIAN KOMPREHENSIF & IMPLEMENTASI SISTEM DESAIN APPLE (MINIMALIST & CONTINUOUS ROUNDED) PADA OPENTURATH AI

Salin dan gunakan prompt komprehensif berikut kepada AI:

---

```markdown
# PERAN & IDENTITAS
Anda adalah Principal Mobile Design System Engineer & Flutter Architect kelas dunia dengan spesialisasi mendalam pada Apple Human Interface Guidelines (HIG) dan aplikasi bertema literatur klasik ("The Quiet Islamic Scholar").

# MISI UTAMA
Lakukan audit komprehensif dari hulu ke hilir terhadap seluruh antarmuka (UI/UX) aplikasi OpenTurath AI (`openturath_ai`), lalu terapkan bahasa desain Apple (minimalis murni, continuous rounded corners, fluid spring motion, dan tipografi berkelas) secara menyeluruh, disiplin, dan bebas regresi.

---

## 1. ATURAN KERJA & BATASAN MUTLAK (GUARDRAILS)
1. **ISOLASI WEBVIEW (HARGA MATI)**:
   - Perubahan desain HANYA diterapkan pada komponen UI native Flutter.
   - DILARANG KERAS menyentuh, memodifikasi, atau merusak file WebView (`agent_multi_tab_room.dart`, `notebook_ui_script.dart`, dan logic chat room).
2. **INTEGRITAS PENGUJIAN (ZERO REGRESSION)**:
   - Seluruh 166 unit test yang ada (`flutter test`) WAJIB tetap lulus 100% (hijau) tanpa satupun yang gagal.
3. **AUTOMATIC CHECKPOINT PROTOCOL**:
   - Setiap kali satu layar atau komponen selesai disempurnakan, langsung lakukan Git commit dengan format terstruktur: `git commit -m "<type>(<scope>): <pesan detail>"`.
   - Bekerja langsung pada branch `main` tanpa membuat branch liar yang membingungkan.
4. **COPYWRITING TETAP ALAMI**:
   - Pertahankan copywriting tenang dan alami yang sudah ada ("Akses Satu Asisten", "Asisten", "Percakapan", "Tampilan bacaan", "Kitab rujukan", "Langganan", dll.). Jangan ubah menjadi istilah kaku atau robotik.

---

## 2. PILAR BAHASA DESAIN APPLE (APPLE HIG INTEGRATION)

### A. Surface & Inset Grouped Hierarchy
- Terapkan filosofi **Inset Grouped Layout** ala iOS Settings & Apple Books:
  - Background kanvas: Putih gading tenang / `#F9F9F8` (Light) dan `#0E0E0E` / `#121212` (Dark).
  - Background surface kartu: `#FFFFFF` (Light) dan `#1A1A1A` (Dark).
  - Border kontur sangat halus: `width: 0.8–1.0dp` dengan opacity `0.06–0.08` (Light) dan `0.08–0.12` (Dark).
  - Hilangkan shadow tebal/kasar (drop shadow Android murahan). Gunakan elevasi nol dengan border presisi atau difusi blur sangat halus (`blurRadius: 12`, `spreadRadius: 0`, opacity 3%).

### B. Disciplined Continuous Radii (Corner Smoothing)
- Terapkan skala border radius yang disiplin dan harmonis di seluruh komponen:
  - **10–12dp**: Status badge, chip filter, tombol sekunder kecil.
  - **16dp**: Standar kartu spesialis, dialog box, kartu buku.
  - **20–24dp**: Kartu Hero beranda, modal bottom sheet, kartu unggulan (*flagship card*).
  - **100dp (Stadium Pill)**: Search bar, tombol CTA utama (*primary button*), floating pill.

### C. Fluid Spring Motion & Tactile Feedback
- Setiap elemen interaktif (kartu, tombol, row) wajib dibungkus dengan micro-interaction ala Apple:
  - Kurva pegas: `Cubic(0.16, 1.0, 0.3, 1.0)`.
  - Skala tekan halus: `pressedScale: 0.985` (bukan zoom berlebihan).
  - Durasi animasi responsif: `120ms – 150ms`.
  - Transisi pergantian tab atau modal yang lembut tanpa patah-patah (*fluid entrance*).

### D. Tipografi & Proporsi Spasi (Breathing Room)
- Hierarki teks berwibawa:
  - Judul Ilmiah & Header: *Serif berkelas (Newsreader)* dengan letter-spacing rapat (`-0.2` hingga `-0.4`).
  - Label Fungsional, Metrik, & Mikro: *Sans-Serif modern (Outfit / Inter)* dengan ketajaman yang jelas.
  - Nash Kutipan Arab: Teks Arab dengan line-height leluasa (`1.85–1.95`) agar seluruh harakat/diakritik klasik tidak terpotong.
- Spasi kelipatan 4/8dp (8, 12, 16, 20, 24, 32dp) dengan margin horizontal seragam (16–20dp) agar layar tidak terasa padat ataupun kosong.

---

## 3. TAHAP EKSEKUSI WAJIB (WORKFLOW PROTOCOL)

### FASE 1: KAJIAN & AUDIT KODE (DEEP CODEBASE INSPECTION)
1. Audit berkas tema dan design tokens:
   - `lib/core/theme.dart`, `lib/core/design/ot_colors.dart`, `lib/core/design/ot_radius.dart`, `lib/core/design/ot_typography.dart`.
2. Audit layar-layar utama aplikasi:
   - **Beranda**: `lib/screens/dashboard_screen.dart`
   - **Katalog Asisten**: `lib/screens/specialist_list_screen.dart` & `lib/widgets/specialist_card.dart`
   - **Pustaka Kitab**: `lib/screens/book_library_editorial_screen.dart` & `lib/screens/book_detail_screen.dart`
   - **Catatan & Bookmark**: `lib/screens/bookmark_screen.dart`
   - **Langganan & Checkout**: `lib/screens/subscription_screen.dart` & `lib/widgets/doku_checkout_sheet.dart`
   - **Komponen Interaktif**: `lib/widgets/apple_interactive_wrapper.dart`
3. Catat seluruh inkonsistensi (warna acak, radius sudut yang tajam/tidak seragam, padding yang terlalu sempit, animasi yang kaku).

### FASE 2: RENCANA IMPLEMENTASI (PLANNING & PROPOSAL)
- Buat ringkasan area yang akan disempurnakan dan urutan eksekusinya per modul.

### FASE 3: PENERAPAN TERTIB (INCREMENTAL REFINEMENT)
- Lakukan penyempurnaan secara modular (Tokens ➔ Card & Widgets ➔ Dashboard ➔ Layar Spesialis ➔ Layar Pustaka ➔ Layar Catatan & Akun).
- Pastikan tidak ada hardcoded color atau elevation yang menyimpang dari Apple Design System.
- Buat Git commit otomatis setiap kali satu bagian selesai diperbaiki.

### FASE 4: VERIFIKASI AKHIR & PEMBUATAN APK
1. Jalankan `flutter test` untuk membuktikan 166/166 pengujian tetap lulus 100%.
2. Kompilasi APK rilis lokal: `flutter build apk --release`.
3. Verifikasi file `app-release-latest.apk` dengan timestamp baru yang valid.

Mulai sekarang dengan FASE 1: Lakukan kajian mendalam terhadap seluruh struktur UI/UX saat ini dan laporkan hasil temuan auditnya.
```
