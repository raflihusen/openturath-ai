# MASTER PROMPT: AUDIT FORENSIK & OVERHAUL TOTAL KONSISTENSI UI OPENTURATH AI
> **Target Pengguna Prompt**: AI Coding Assistant / Senior Flutter UI/UX Architect / Design System Engineer  
> **Dasar Analisis**: Seluruh kode sumber terpadu pada berkas `OPENTURATH_AI_FULL_AUDIT_SOURCE.txt` (122 berkas, 32.450+ baris).  
> **Karakter & Visi Desain**: *The Quiet Islamic Scholar (Monochrome Editorial)* — Tenang, berwibawa, seperti naskah turats di perpustakaan klasik, bebas warna norak, bebas gradien murahan, dan konsisten 100% pada mode Terang (Light) maupun Gelap (Dark).

---

## 🏛️ 1. LATAR BELAKANG & PROBLEM STATEMENT
Aplikasi **OpenTurath AI** saat ini mengalami **krisis inkonsistensi visual (*visual fragmentation*) yang parah**. Meskipun sudah memiliki fondasi sistem desain monokrom (`OTColors`), di lapangan antarmuka masih dihinggapi **warna-warna aneh, gradien liar, dan gaya visual yang bertabrakan antar layar**:

1. **Warna Aneh & Campur Aduk (Rogue Colors)**:
   - Di `subscription_screen.dart`: Ditemukan gradien emas/kuning/cokelat mencolok (`Color(0xFF2A200B)`, `Color(0xFFFFFBEB)`), lencana oranye neon (`Color(0xFFD97706)`, `Color(0xFFF59E0B)`), dan teks kuning terang (`Color(0xFFFBBF24)`, `Color(0xFFFDE68A)`). Tampilan ini menyerupai banner e-commerce/fintech murahan, bukan ruang kajian turats islami.
   - Di `app_snackbar.dart`: Tiba-tiba muncul warna aksen Tailwind/modern neon seperti Emerald (`Color(0xFF34D399)`), Amber (`Color(0xFFFBBF24)`), Rose (`Color(0xFFF87171)`), dan Slate (`Color(0xFF94A3B8)`).
   - Di `dashboard_screen.dart`: Masih ada palet abu-abu Zinc liar (`Color(0xFF27272A)`, `Color(0xFFF4F4F5)`, `Color(0xFF3F3F46)`, `Color(0xFFE4E4E7)`) yang tidak terdaftar di `OTColors`.
   - Di `theme.dart`: Ditemukan token `appleGreen (0xFF34C759)` dan `appleRed (0xFFFF3B30)`.

2. **Gaya Komponen Bertabrakan**:
   - Sebagian kartu memakai radius 24 dengan bayangan tebal (`BoxShadow`), sebagian radius 16 tanpa bayangan, sebagian lagi berupa tab bergaris bawah tipis.
   - Inkonsistensi implementasi tema: ada widget yang mengambil warna dari `OTColors.xyz(isDark)`, ada yang mengambil dari `Theme.of(context)`, dan ada yang menembak langsung kode Hex `Color(0xFF...)`.

---

## 🎯 2. MANDAT UTAMA & ATURAN MUTLAK (NON-NEGOTIABLE)

### A. Larangan Keras (Pantangan Haram)
1. **DILARANG** menggunakan warna Hex langsung (`Color(0x...)`) di dalam file `screens/` dan `widgets/`. Seluruh warna WAJIB bersumber dari `OTColors` atau `AppTheme`.
2. **DILARANG** menggunakan `Colors.xyz` bawaan Flutter (seperti `Colors.white`, `Colors.black`, `Colors.grey`, `Colors.amber`, `Colors.orange`), KECUALI `Colors.transparent`.
3. **DILARANG** menggunakan gradien dekoratif (`LinearGradient`) pada kartu, header, modal, ataupun tombol. Desain harus datar (*flat*), bersahaja, dan mengandalkan kontras garis tipis (*border*).
4. **DILARANG** menggunakan `BoxShadow` hitam tebal yang melayang (*floating card effect*). Gunakan garis batas tipis (`0.8` hingga `1.0 px`) dengan `OTColors.border(isDark)`.
5. **DILARANG** menggunakan font lain di luar **3 Pilar Resmi**:
   - Judul & Tajuk Latin: **Newsreader** (Google Fonts).
   - Teks Arab, Matan, & Kutipan Ibarah: **Scheherazade New** (Google Fonts).
   - Teks Fungsional, Tombol, & Navigasi: **Outfit** (Google Fonts).
   - *Haram*: Font `Amiri`, `Tajawal`, atau `Roboto` generik.

### B. Standar Baku Palet Monokrom Editorial (`OTColors`)
Seluruh komponen harus patuh pada palet baku ini:
* **Mode Terang (Light)**:
  - Canvas (Latar Belakang Dasar): `#F6F6F3` (kertas klasik hangat / warm paper)
  - Surface (Kartu & Lembar Kerja): `#FFFFFF` (putih bersih)
  - Surface Subtle (Latar Sekunder/Pill/Badge): `#EEEEEB`
  - Text Primary (Tinta Utama): `#171717` (deep charcoal/ink)
  - Text Secondary (Teks Pendukung/Sitasi): `#656560` (subtle pencil grey)
  - Text Tertiary (Keterangan Halus): `#8C8C84`
  - Border (Garis Batas Halus): `#DDDDD8`
  - Border Strong: `#B8B8B1`
  - Accent / Tinta Penanda: `#171717` (monokrom) atau `#3D4A3E` (hijau sage zaitun sangat tua, hanya untuk status marja')
* **Mode Gelap (Dark)**:
  - Canvas: `#111110` (hitam jelaga arang / deep charcoal obsidian)
  - Surface: `#181817`
  - Surface Subtle: `#222220`
  - Text Primary: `#F4F4F0` (krem naskah terang)
  - Text Secondary: `#B2B2AA` (abu-abu tenang)
  - Text Tertiary: `#7A7A73`
  - Border: `#30302E`
  - Border Strong: `#4B4B47`
  - Accent: `#F4F4F0`

---

## 🛠️ 3. RENCANA AKSI PERBAIKAN SPESIFIK (STEP-BY-STEP CHECKLIST)

### Langkah 1: Pembersihan Total Layar Langganan (`subscription_screen.dart`)
- **Masalah**: Banner paket Sultan dan card langganan masih menggunakan gradien emas/kuning/oranye mencolok (`0xFF2A200B`, `0xFFD97706`, `0xFFFBBF24`).
- **Tindakan**:
  1. Hapus seluruh `LinearGradient` kuning/oranye. Ganti latar kartu dengan `OTColors.surface(isDark)`.
  2. Berikan bingkai kartu dengan `OTColors.border(isDark)` atau `OTColors.borderStrong(isDark)` untuk paket unggulan.
  3. Ganti lencana status (badge promo/hemat) menjadi badge editorial monokrom: latar `OTColors.surfaceSubtle(isDark)` dengan teks `OTColors.textPrimary(isDark)`.
  4. Selaraskan seluruh tombol aksi menggunakan gaya `OTTypography.button` dengan latar `OTColors.textPrimary` dan teks `OTColors.surface`.

### Langkah 2: Harmonisasi Notifikasi & Indikator Status (`app_snackbar.dart`)
- **Masalah**: Snackbar memunculkan warna Emerald, Rose, dan Amber yang merusak ketenangan visual.
- **Tindakan**:
  1. Ubah latar belakang snackbar menjadi monokrom pekat: `isDark ? Color(0xFF181817) : Color(0xFF171717)` dengan border halus `OTColors.border(isDark)`.
  2. Ganti indikator warna-warni menjadi ikon monokrom yang tegas (misal `Icons.check_circle_outline` untuk sukses, `Icons.error_outline` untuk gagal) dengan warna `isDark ? OTColors.textPrimaryDark : Colors.white`.
  3. Hindari saturasi tinggi. Jika memerlukan diferensiasi status gagal/kritis, gunakan merah batu bata redup (*desaturated brick red* `#991B1B` / `#F87171` dengan opacity rendah), bukan merah neon.

### Langkah 3: Sapu Bersih Hardcoded Colors di Beranda (`dashboard_screen.dart`)
- **Masalah**: Bagian filter, tab bawah, dan dialog masih menembak warna Hex Zinc (`0xFF27272A`, `0xFFF4F4F5`, `0xFF3F3F46`, `0xFFE4E4E7`).
- **Tindakan**:
  1. Ganti `Color(0xFF27272A)` $\rightarrow$ `OTColors.surfaceSubtle(isDark)`.
  2. Ganti `Color(0xFFF4F4F5)` $\rightarrow$ `OTColors.surfaceSubtle(isDark)`.
  3. Ganti `Color(0xFF3F3F46)` $\rightarrow$ `OTColors.border(isDark)`.
  4. Ganti percabangan `widget.isDark ? Colors.white : const Color(0xFF18181B)` $\rightarrow$ `OTColors.textPrimary(isDark)`.

### Langkah 4: Standardisasi Navigasi Datar & Tap Target (`corpus_kind_control.dart` & `main_shell_screen.dart`)
- **Masalah**: Masih ada sisa-sisa kartu tebal yang membingungkan fungsi navigasi vs konten.
- **Tindakan**:
  1. Pastikan seluruh pengalih direktori menggunakan model **tab datar bergaris bawah (*flat underline indicator*)** seperti yang sudah dirintis di `corpus_kind_control.dart`.
  2. Pastikan `BottomNavigationBar` atau `NavigationRail` memiliki latar tembus pandang lembut dengan pembatas 1 garis (`Border(top: BorderSide(color: OTColors.border))`).
  3. Pertahankan tinggi area sentuh minimal 44–48 px untuk kenyamanan navigasi jempol.

### Langkah 5: Unifikasi Tipografi Naskah Arab (`Scheherazade New`)
- **Masalah**: Beberapa dialog dan sheet kutipan masih memiliki fallback font sistem atau ukuran font Arab yang kekecilan/tergencet.
- **Tindakan**:
  1. Pastikan setiap teks Arab dibungkus `TextDirection.rtl` jika berada di dalam baris tersendiri.
  2. Gunakan `GoogleFonts.scheherazadeNew` dengan `height: 1.8` s.d. `2.0` agar harakat, tanda waqaf, dan tanwin tidak terpotong oleh batas kontainer widget.
  3. Jangan pernah memberikan huruf miring (*italic*) pada font Arab.

---

## 🔍 4. PROTOKOL PENGUJIAN & VERIFIKASI (DEFINITION OF DONE)
Setelah melakukan refactoring:
1. **Pemeriksaan Kompilasi**: Jalankan `flutter analyze` dan pastikan **0 errors, 0 warnings, 0 lints**.
2. **Pemeriksaan Regex Pembersihan**:
   Jalankan pemeriksaan pencarian berikut dan buktikan hasilnya **0 matches**:
   ```bash
   grep -rnE "Color\(0xFF(2A200B|1E170A|D97706|F59E0B|FBBF24|34D399|F87171|27272A|F4F4F5|3F3F46|E4E4E7)\)" lib/
   ```
3. **Pengujian Regresi Test Suite**: Jalankan `flutter test` dan pastikan seluruh 32 berkas pengujian lulus 100%.
4. **Kaidah Git Checkpoint**: Setiap file yang diperbaiki langsung dibuatkan Git commit terstruktur: `refactor(ui): bersihkan warna aneh dan harmonisasikan [nama komponen] ke otcolors`.

---
*Lakukan refactoring secara presisi, satu per satu, tanpa merusak alur data dan fungsi bisnis yang sudah berjalan.*
EOF
