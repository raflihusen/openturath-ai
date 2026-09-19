# MASTER PROMPT: AUDIT FORENSIK, ELEVASI RADIKAL & OVERHAUL KONSISTENSI UI OPENTURATH AI

> **Target Pengguna Prompt**: AI Coding Assistant / Principal Flutter UI/UX Architect / Design System Engineer  
> **Dasar Analisis**: Seluruh kode sumber terpadu pada berkas `OPENTURATH_AI_FULL_AUDIT_SOURCE.txt` (124 berkas, 32.500+ baris terpadu dan tersanitasi ketat).  
> **Karakter & Visi Desain**: ***The Quiet Islamic Scholar (Monochrome Editorial)*** — Hening, berwibawa, teduh seperti naskah turats di perpustakaan klasik Islam, 100% bebas warna norak, bebas gradien murahan (*zero tacky gradients*), bebas bayangan tebal (*zero heavy shadows*), dan konsisten sempurna pada Mode Terang (Light) maupun Gelap (Dark).

---

## 🏛️ 1. DIAGNOSIS MASALAH: KRISIS INKONSISTENSI VISUAL (*VISUAL FRAGMENTATION*)

Meskipun fondasi sistem desain monokrom (`OTColors`, `OTTypography`, `OTMotion`) telah didefinisikan, aplikasi **OpenTurath AI** masih mengidap inkonsistensi yang merusak adab keilmuan dan keterbacaan:

1. **Warna-Warna Liar & Saturasi Murahan (*Rogue Colors*)**:
   - Di `subscription_screen.dart`: Pernah ditemukan gradien emas/kuning/cokelat mencolok (`0xFF2A200B`, `0xFFFFFBEB`), lencana oranye neon (`0xFFD97706`, `0xFFF59E0B`), dan teks kuning terang (`0xFFFBBF24`). Tampilan ini mereduksi software telaah turats menjadi banner e-commerce/fintech murahan.
   - Di `app_snackbar.dart`: Tiba-tiba menyembul palet aksen Tailwind neon seperti Emerald (`0xFF34D399`), Amber (`0xFFFBBF24`), Rose (`0xFFF87171`), dan Slate (`0xFF94A3B8`).
   - Di `dashboard_screen.dart`: Sisa-sisa abu-abu Zinc liar (`0xFF27272A`, `0xFFF4F4F5`, `0xFF3F3F46`, `0xFFE4E4E7`) yang tidak tersinkronisasi ke `OTColors`.
   - Di `theme.dart`: Sisa token `appleGreen` dan `appleRed` jenuh.

2. **Inkonsistensi Hierarki Spasial & Komponen**:
   - Sebagian kartu memakai radius 24 dengan bayangan tebal melayang (*floating cards*), sebagian radius 16, sebagian berupa baris datar minimalis.
   - Dialog dan bottom sheet memiliki padding dan latar yang tidak seragam antara mobile (Android) dan desktop (macOS).

3. **Cacat Ergonomi Tipografi Naskah Arab**:
   - Di beberapa layar, teks matan dan kutipan Arab terpotong harakat atas (fathah/tanwin/tasydid) atau harakat bawah (kasrah) karena `line-height` terlalu mepet atau tidak dibungkus `TextDirection.rtl`.

---

## 💎 2. 7 SYARAT TERBAIK UNTUK MENINGKATKAN UI SECARA DRASTIS (*THE 7 PILLARS OF RADICAL ELEVATION*)

Untuk mengangkat antarmuka OpenTurath AI dari sekadar "aplikasi yang jalan" menjadi **karya seni digital bertaraf museum (*museum-grade academic software*)**, setiap tindakan modifikasi WAJIB memenuhi 7 syarat mutlak ini:

### 1. Disiplin Monokrom Absolut & Eliminasi Warna Jenuh (*Zero Saturated Accents*)
* **Mode Terang (Light Mode - Kertas Klasik Hangat / Warm Paper)**:
  * `Canvas (Dasar Layar)`: `#F6F6F3`
  * `Surface (Kartu & Lembar Kerja)`: `#FFFFFF`
  * `Surface Subtle (Pill/Badge/Field)`: `#EEEEEB`
  * `Text Primary (Tinta Utama)`: `#171717` (deep charcoal/ink)
  * `Text Secondary (Teks Pendukung/Sitasi)`: `#656560` (pencil graphite)
  * `Border (Garis Batas Halus)`: `#DDDDD8` (ketebalan 0.8–1.0 px, bukan bayangan tebal)
* **Mode Gelap (Dark Mode - Hitam Jelaga Arang / Deep Obsidian)**:
  * `Canvas`: `#111110`
  * `Surface`: `#181817`
  * `Surface Subtle`: `#222220`
  * `Text Primary`: `#F4F4F0` (krem naskah terang)
  * `Text Secondary`: `#B2B2AA`
  * `Border`: `#30302E`
* **Warna Status Fungsional**: Jika mutlak diperlukan indikator kesalahan (error), gunakan **merah batu bata sangat redup (*desaturated brick red* `#991B1B` / `#F87171` lembut)** dengan latar pastel pudar. **HARAM** menggunakan merah/hijau/kuning neon menyala.

### 2. Kesucian Tipografi Arab & Tajuk Editorial Latin (*Typographic Sanctity*)
* **3 Pilar Font Resmi**:
  1. **Newsreader** (Serif Klasik Latin): Khusus untuk tajuk utama, judul kitab, nama pengarang, dan kutipan filosofis editorial.
  2. **Scheherazade New** (Khat Naskh Klasik Arab): Khusus untuk teks Arab, matan kitab, ayat, hadis, dan kutipan ibarah.
     * **Aturan Mutlak Arab**: Wajib `height: 1.85` hingga `2.1`, ukuran minimal 20–24 sp untuk teks panjang, dibungkus `TextDirection.rtl`, dan **DILARANG DIMIRINGKAN (italic)** agar harakat tetap utuh sempurna.
  3. **Outfit** (Sans-Serif Modern Bersih): Khusus untuk label fungsional, tombol aksi, angka metadata, dan navigasi shell.
  * **Haram Mutlak**: Font `Amiri`, `Tajawal`, atau `Roboto` generik.

### 3. Arsitektur Komponen Datar Berwibawa (*Flat Underline & Minimalist Division*)
* Ganti tombol bergradien dan kartu tebal melayang dengan **garis pemisah tipis presisi (*hairline borders*)**.
* Pengalih direktori (kategori korpus/spesialis) wajib menggunakan **tab datar bergaris bawah (*flat underline indicator*)** yang hening, mengacu pada [`corpus_kind_control.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/corpus_kind_control.dart).
* Ganti lencana status (*badges*) norak menjadi kapsul datar monokrom: latar `OTColors.surfaceSubtle`, teks `OTColors.textPrimary`.

### 4. Responsivitas Adaptif: Mobile Thumb-Zone vs Desktop Mac Precision
* **Android / Mobile**:
  * Seluruh target sentuh tombol minimal **44x44 px hingga 48x48 px**.
  * Gunakan lembar geser bawah (*modal bottom sheet*) dengan radius atas 20–24 px untuk menu opsi dan rincian kitab.
  * Navigasi bawah datar (*bottom nav*) yang ramah jangkauan jempol satu tangan.
* **macOS / Desktop**:
  * Tampilan membaca naskah panjang wajib dibatasi lebar maksimalnya: `ConstrainedBox(constraints: BoxConstraints(maxWidth: 720))` agar mata pembaca tidak lelah melintasi layar monitor lebar.
  * Efek kursor `SystemMouseCursors.click` dan hover state halus pada setiap baris direktori yang dapat diklik.

### 5. Mikro-Interaksi Hening & Sentuhan Haptik Apple (*Tactile Discipline*)
* Bungkus seluruh kartu dan tombol interaktif dengan `AppleInteractiveWrapper`:
  * Animasi susut halus saat ditekan (`scale: 0.985`, durasi `100–120ms`, kurva `Curves.easeOutCubic`).
  * Sentuhan haptik lembut: `HapticFeedback.lightImpact()` pada penekanan tombol dan `selectionClick()` saat berpindah tab.
  * Nol getaran kasar (*zero harsh vibrations*).

### 6. Ruang Baca Tanpa Distraksi (*Distraction-Free Scholarly Pane*)
* Di ruang telaah (*agent webview/chat*):
  * Header harus bersih dan ramping, hanya menampilkan judul kitab/mas'alah, nama muhaqqiq, dan tombol aksi esensial (Salin Ibarah, Simpan Catatan, Tutup Tab).
  * Salin teks ibarah wajib menyertakan takhrij marja' kanonikal secara otomatis dan rapi di clipboard.

### 7. Alur Masuk & Transaksional yang Bermartabat (*Dignified Onboarding & Membership*)
* Jangan pernah mengunci pengguna di luar aplikasi: Sediakan opsi *"Masuk sebagai Tamu (Mode Telaah)"* di bawah tombol Google Sign-In.
* Halaman langganan (*membership pass*) tidak boleh menyerupai casino/flash-sale: Tidak ada hitung mundur panik (*no countdown panic*), tidak ada diskon coret berlebihan. Gunakan format paspor akademik / kartu perpustakaan turats yang tenang dengan rincian hak akses yang transparan.

---

## 🛠️ 3. RENCANA EKSEKUSI SPESIFIK BERDASARKAN BERKAS SUMBER

Gunakan berkas `OPENTURATH_AI_FULL_AUDIT_SOURCE.txt` untuk mengaudit dan merefaktor titik-titik krusial berikut:

### Modul 1: Standarisasi Layar Langganan (`lib/screens/subscription_screen.dart`)
- [ ] Sapu bersih seluruh sisa `LinearGradient` emas, cokelat, dan oranye.
- [ ] Ganti kartu paket Sultan menjadi kartu editorial bersahaja berbingkai `OTColors.borderStrong`.
- [ ] Ganti teks kuning `Color(0xFFFBBF24)` dengan `OTColors.textPrimary`.
- [ ] Pertahankan integrasi Midtrans Snap & fallback WhatsApp Concierge resmi (`081292979189` / tersanitasi) tanpa mengubah logika bisnis.

### Modul 2: Harmonisasi Notifikasi Global (`lib/widgets/app_snackbar.dart`)
- [ ] Hilangkan warna Emerald, Amber, dan Rose neon.
- [ ] Jadikan latar snackbar monokrom pekat (`#181817` / `#171717`) dengan garis tepi halus.
- [ ] Gunakan ikon monokrom yang tegas dan teks putih/krem berkontras tinggi.

### Modul 3: Pembersihan Beranda & Direktori Spesialis (`lib/screens/dashboard_screen.dart`)
- [ ] Ganti seluruh kode warna Zinc (`0xFF27272A`, `0xFFF4F4F5`, `0xFF3F3F46`, `0xFFE4E4E7`) dengan token `OTColors`.
- [ ] Pastikan daftar 21 Khadim Turats tampil seperti direktori arsip perpustakaan kuno yang rapi, berjarak ritmis, dan nyaman dibaca.

### Modul 4: Penguatan Tipografi Arab & Salin Ibarah (`lib/utils/arabic_utils.dart` & `lib/core/ot_typography.dart`)
- [ ] Pastikan seluruh kutipan teks Arab di dialog, kartu kitab, dan sitasi menggunakan `GoogleFonts.scheherazadeNew` dengan `height >= 1.85`.
- [ ] Uji fungsionalitas normalisasi pencarian Arab (bebas harakat, hamzah, dan ta marbuthah) agar riset kitab berjalan instan dan akurat.

---

## 🔍 4. DEFINITION OF DONE & VERIFIKASI KETAT
Sebelum menyatakan refactoring selesai, buktikan 4 parameter keberhasilan berikut:
1. **Pemeriksaan Sintaks**: Jalankan `flutter analyze` dan buktikan hasilnya **0 errors, 0 warnings, 0 lints**.
2. **Pembersihan Kode Warna Liar (Regex Proof)**:
   Jalankan perintah ini di terminal dan pastikan **0 matches**:
   ```bash
   grep -rnE "Color\(0xFF(2A200B|1E170A|D97706|F59E0B|FBBF24|34D399|F87171|27272A|F4F4F5|3F3F46|E4E4E7)\)" lib/
   ```
3. **Pengujian Regresi Test Suite**: Jalankan `flutter test` dan pastikan seluruh berkas pengujian lulus 100% (All Green).
4. **Kepatuhan Protokol Checkpoint**: Setiap file yang dimodifikasi wajib langsung dibuatkan Git commit deskriptif: `refactor(ui): [nama perbaikan sesuai standar monokrom editorial]`.

---
*Eksekusi rencana ini secara presisi, metodis, dan pertahankan kesucian serta keagungan khazanah keilmuan Islam dalam setiap piksel antarmuka.*
