# OpenTurath AI — Unified Design System Specification
> **Karakter Visual Utama:** *Monochrome Editorial — The Quiet Islamic Scholar*  
> **Filosofi Inti:** Suasana perpustakaan manuskrip klasik, ruang telaah akademik hening, dan katalog kitab digital modern. Bukan aplikasi SaaS generik, fintech, dashboard warna-warni, ataupun AI dengan efek neon/gradient. Kedalaman visual dibangun melalui kontras monokromatis, hierarki tipografi editorial, proporsi ruang kosong (*negative space*), *hairline border*, dan tekstur kertas arsip.

---

## 📑 Daftar Isi
1. [Prinsip Filosofis & Pantangan](#1-prinsip-filosofis--pantangan)
2. [Palet Warna Monokromatis (Color Palette)](#2-palet-warna-monokromatis-color-palette)
3. [Sistem Sudut Membulat (Disciplined Radius)](#3-sistem-sudut-membulat-disciplined-radius)
4. [Arsitektur Tipografi 3-Pilar (Typography System)](#4-arsitektur-tipografi-3-pilar-typography-system)
5. [Skala Ritme Jarak (Base-4 Spacing System)](#5-skala-ritme-jarak-base-4-spacing-system)
6. [Hierarki Border, Garis & Elevasi (Borders & Elevation)](#6-hierarki-border-garis--elevasi-borders--elevation)
7. [Anatomi Komponen Baku (Component Tokens)](#7-anatomi-komponen-baku-component-tokens)
8. [Durasi Animasi & Haptik (Motion & Haptics)](#8-durasi-animasi--haptik-motion--haptics)
9. [Format Ekspor Token (CSS & JSON Ready)](#9-format-ekspor-token-css--json-ready)

---

## 1. Prinsip Filosofis & Pantangan

### 🏛️ The Quiet Islamic Scholar
* **Ketenangan Intelektual:** Antarmuka tidak boleh bersaing merebut perhatian dari teks kitab dan dalil syar'i yang sedang ditelaah santri/peneliti.
* **Kejelasan Tipografi:** Teks Arab matan dan syarah memiliki pembacaan yang lapang (*line-height* longgar), dipadukan dengan aksen *serif editorial* untuk judul Latin dan *sans-serif geometris* untuk kontrol antarmuka.
* **Kontras Murni (Bukan Gradien):** Struktur visual dibentuk oleh pergeseran bidang terang-gelap yang tegas (kertas ke tinta).

### 🚫 Pantangan Keras (Strict Prohibitions)
1. **DILARANG MENGGUNAKAN WARNA SAAS / FINTECH:** Tidak ada warna oranye, kuning, emas mencolok, cyan, ungu neon, atau gradien warna-warni pada kartu langganan, tombol, maupun badge. (Aturan Sakral #9 AGENTS.md).
2. **ZERO AMBER / ZERO ORANGE PADA TAHAWWULAT:** Seluruh elemen Fikih Tahawwulat wajib tunduk pada palet monokrom obsidian murni.
3. **TIDAK ADA SHADOW TEBAL / BLURRY DROPSHADOW:** Kedalaman dicapai menggunakan *hairline border* (0.5px – 1px) dan perbedaan kontras tonal latar, bukan bayangan hitam tebal yang mengotori bidang.
4. **TIDAK ADA FONT SANS-SERIF UNTUK TEKS ARAB:** Teks Arab haram menggunakan font UI modern seperti Tajawal atau Arial. Teks Arab wajib menggunakan karakter naskh murni turats (*Scheherazade New*).

---

## 2. Palet Warna Monokromatis (Color Palette)

### A. Light Mode (Neutral Paper — Kertas Arsip Hangat)
Digunakan saat santri membaca di siang hari atau lingkungan terang. Memberi sensasi kertas kitab klasik yang tidak menyilaukan mata.

| Token Name | Hex Code | Deskripsi & Peruntukan |
| :--- | :--- | :--- |
| `canvasLight` | `#F6F6F6` | Latar belakang kanvas utama aplikasi (kertas hangat) |
| `surfaceLight` | `#FFFFFF` | Permukaan panel, dialog, kartu kitab, sheet, input field |
| `surfaceSubtleLight` | `#EDEDED` | Kontainer tonal sekunder, kotak kutipan, latar badge |
| `textPrimaryLight` | `#171717` | Teks judul, teks baca utama, ikon aktif |
| `textSecondaryLight` | `#606060` | Keterangan penulis, bab, rujukan, metadata |
| `textTertiaryLight` | `#6B6B6B` | Placeholder form, hint, ikon non-aktif |
| `borderLight` | `#DADADA` | Garis batas kartu, pemisah baris reguler |
| `borderSubtleLight` | `#EBEBEB` | Garis pembatas halus antar butir daftar (*hairline*) |
| `borderStrongLight` | `#767676` | Garis tepi tombol outline, pembatas aktif |
| `accentLight` | `#171717` | Warna aksen utama (tinta pekat tombol primer) |
| `primaryContainerLight` | `#F0F0F0` | Wadah aksen tonal lembut |
| `onPrimaryContainerLight`| `#171717` | Teks di atas wadah tonal lembut |

---

### B. Dark Mode (Neutral Ink — Obsidian Gelap Pekat)
Digunakan saat telaah malam hari di ruang belajar santri. Menghilangkan silau tanpa membuat teks kabur.

| Token Name | Hex Code | Deskripsi & Peruntukan |
| :--- | :--- | :--- |
| `canvasDark` | `#151515` | Latar belakang kanvas malam pekat |
| `surfaceDark` | `#292929` | Permukaan kartu, panel navigasi, modal dialog |
| `surfaceSubtleDark` | `#353535` | Latar tombol sekunder, chip filter, hover state |
| `textPrimaryDark` | `#F5F5F5` | Teks utama, judul bab, aksen tombol di mode gelap |
| `textSecondaryDark` | `#B8B8B8` | Subtitle, metadata, nama pensyarah |
| `textTertiaryDark` | `#9A9A9A` | Hint, placeholder, ikon sekunder |
| `borderDark` | `#454545` | Garis batas modul, kartu, dan pembatas daftar |
| `borderSubtleDark` | `#2D2D2D` | Garis pembagi halus di mode malam |
| `borderStrongDark` | `#808080` | Garis tepi tombol outline fokus |
| `accentDark` | `#F5F5F5` | Aksen terang di atas latar gelap |
| `primaryContainerDark` | `#222222` | Wadah aksen tonal gelap |
| `onPrimaryContainerDark` | `#F5F5F5` | Teks di atas wadah tonal gelap |

---

### C. Tinta Balik & Status Semantik
Pengganti mutlak `Colors.white` dan `Colors.black` bebas yang berisiko merusak kontras.

| Token Name | Nilai (Light) | Nilai (Dark) | Fungsi |
| :--- | :--- | :--- | :--- |
| `onAccent` | `#FFFFFF` | `#171717` | Teks/ikon di atas tombol berwarna `accent` |
| `inverseSurface` | `#171717` | `#2B2B2B` | Permukaan terbalik (Snackbar, tooltip melayang) |
| `onInverseSurface` | `#F5F5F5` | `#F5F5F5` | Teks di dalam snackbar / tooltip terbalik |
| `marja` | `#4A4A4A` | `#C4C4C4` | Penanda kitab rujukan terverifikasi (*marja' mu'tamad*) |
| `destructive` | `#B91C1C` | `#F87171` | Satu-satunya aksen merah: konfirmasi hapus, batal |
| `errorContainer` | `#FEF2F2` | `#2F1616` | Latar belakang kotak pesan peringatan/galat |
| `shadow` | `#000000` *(alpha)* | `#000000` *(alpha)* | Bayangan optis dan scrim redup |

---

## 3. Sistem Sudut Membulat (Disciplined Radius)

Menghindari tren pembulatan balon (*bubble UI*) yang kekanak-kanakan. Setiap tingkatan kelengkungan memiliki peruntukan fungsional yang baku:

```
┌────────────────────────────────────────────────────────┐
│  xs: 8px         [Tag / Handle]                        │
│  card: 24px      [Kartu Modul & Kitab]                 │
│  dialog: 28px    [Pop-up Konfirmasi & Dialog]          │
│  input: 28px     [Kolom Input Teks & Pencarian]        │
│  hero/sheet: 32px[Panel Utama & Lembar Bottom Sheet]   │
│  chip/button: 999px (Pill Penuh)                       │
└────────────────────────────────────────────────────────┘
```

| Radius Token | Nilai Piksel | Implementasi Border Radius | Contoh Elemen |
| :--- | :---: | :--- | :--- |
| `OTRadius.xs` | **8.0 px** | `BorderRadius.circular(8)` | Pegangan sheet (*drag handle*), tag persegi, butir daftar |
| `OTRadius.card` | **24.0 px** | `BorderRadius.circular(24)` | Kartu kajian disiplin, kartu kitab turats, panel ringkasan |
| `OTRadius.input` | **28.0 px** | `BorderRadius.circular(28)` | Kolom input pencarian, kotak input pertanyaan (*composer*) |
| `OTRadius.dialog`| **28.0 px** | `BorderRadius.circular(28)` | Dialog konfirmasi, pop-up pembayaran *Bithāqah* |
| `OTRadius.sheet` | **32.0 px** | `BorderRadius.vertical(top: 32)` | Lembar bawah modal (*bottom sheet* navigasi & pengaturan) |
| `OTRadius.hero` | **32.0 / 36.0 px**| `BorderRadius.circular(32)` | Kartu flagship utama (Al-Muhaqqiq, Fikih Syafi'i Master) |
| `OTRadius.button`| **999.0 px** | `BorderRadius.circular(999)` | Bentuk pil penuh untuk tombol primer, sekunder, dan aksi |
| `OTRadius.chip` | **999.0 px** | `BorderRadius.circular(999)` | Filter kategori disiplin, pil indikator status (*verified badge*) |

---

## 4. Arsitektur Tipografi 3-Pilar (Typography System)

Tipografi adalah tulang punggung estetika *The Quiet Islamic Scholar*. Menggunakan **3 keluarga huruf khusus** yang tidak boleh dicampuradukkan:

```
                  ┌───────────────────────────────┐
                  │ 1. Newsreader (Serif)         │ ── Editorial, Judul Kitab, Display
                  ├───────────────────────────────┤
                  │ 2. Outfit (Geometric Sans)    │ ── UI, Tombol, Metadata, Label
                  ├───────────────────────────────┤
                  │ 3. Scheherazade New (Naskh)   │ ── Teks Arab Turats, Matan, Syarah
                  └───────────────────────────────┘
```

### A. Skala Ukuran Huruf Tertutup (Closed Scale)
Dilarang menggunakan ukuran font sembarang. Semua teks harus merujuk ke 9 langkah skala ini:

| Skala Token | Ukuran | Bobot (Weight) | Karakter Huruf | Kegunaan Utama |
| :--- | :---: | :---: | :--- | :--- |
| `s11` | **11 px** | 600 (*SemiBold*) | `Outfit` (Tracking +0.8) | Kepala seksi kapital, micro-pill, label kategori |
| `s12` | **12 px** | 400 / 600 | `Outfit` (Height 1.35) | Keterangan penerbit, tahun wafat mualif, metadata |
| `s14` | **14 px** | 400 / 600 | `Outfit` (Tracking +0.1) | Teks antarmuka, label tombol, teks baca ringkas |
| `s16` | **16 px** | 600 (*SemiBold*) | `Outfit` / `Newsreader` | Judul kartu modul, kutipan baca Latin, ringkasan |
| `s18` | **18 px** | 400 / 600 | `Newsreader` / `Scheherazade` | Judul seksi, teks baca Arab di dalam daftar bab |
| `s20` | **20 px** | 600 (*SemiBold*) | `Newsreader` (Tracking -0.3) | Judul kitab Latin (*Tuhfatut Thullab, Al-Umm*) |
| `s22` | **22 px** | 600 (*SemiBold*) | `Newsreader` / `Scheherazade` | Wordmark OpenTurath AI, teks Arab syarah kitab |
| `s26` | **26 px** | 600 / 700 | `Newsreader` / `Scheherazade` | Judul halaman besar, teks Arab matan primer |
| `s36` | **36 px** | 600 (*SemiBold*) | `Newsreader` (Tracking -1.0) | Display headline utama layar pembuka |

### B. Aturan Ketinggian Baris Teks Arab (*Line Height / Leading*)
* **Teks Latin:** Memiliki *height* antara `1.2` s/d `1.5` agar kompak dan mudah dipindai.
* **Teks Arab:** **WAJIB minimal `height: 1.85`**. Ini mutlak diperlukan untuk memberi ruang bagi tanda harakat (*syakl*), tanwin, dan tanda waqaf tanpa terpotong (*clipped*) oleh kotak baris.

---

## 5. Skala Ritme Jarak (Base-4 Spacing System)

Menghilangkan angka acak (13px, 17px, 21px). Seluruh jarak margin, padding, dan celah (*gap*) dibangun dari kelipatan 4:

| Token Spacing | Ukuran Piksel | Penggunaan Standar |
| :--- | :---: | :--- |
| `OTSpacing.xxs` | **2 px** | Celah optis mikro, penyesuaian ikon dengan teks |
| `OTSpacing.xs` | **4 px** | Jarak antar tag kecil, jarak vertikal label ke input |
| `OTSpacing.sm` | **8 px** | Celah horizontal ikon dengan teks tombol, jarak badge |
| `OTSpacing.md` | **12 px** | Padding kartu ringkas (*compact*), celah antar tombol |
| `OTSpacing.base`| **16 px** | Margin horizontal halaman standar, padding kartu standar |
| `OTSpacing.lg` | **20 px** | Padding dalam modal dialog dan bottom sheet |
| `OTSpacing.xl` | **24 px** | Jarak vertikal antar seksi konten utama |
| `OTSpacing.xxl` | **32 px** | Margin atas judul layar, jarak antar kelompok besar |
| `OTSpacing.huge`| **40 px** | Pemisah bagian hero dengan daftar kajian |
| `OTSpacing.massive` | **48 px** | Ruang kosong dramatis editorial di layar perkenalan |
| `OTSpacing.jumbo` | **64 px** | Jarak batas paling bawah transkrip agar leluasa di-scroll |

---

## 6. Hierarki Border, Garis & Elevasi (Borders & Elevation)

### A. Garis Tepi (Hairline Borders)
* **Ketebalan:** `1.0 px` murni (atau `0.5 px` di layar Retina beresolusi tinggi).
* **Warna:**
  * Mode Terang: `borderLight` (`#DADADA`) untuk kartu reguler; `borderSubtleLight` (`#EBEBEB`) untuk pembatas list.
  * Mode Gelap: `borderDark` (`#454545`) untuk kartu reguler; `borderSubtleDark` (`#2D2D2D`) untuk pembatas list.
* **Tujuan:** Membatasi bidang secara presisi seperti garis cetak percetakan kitab klasik.

### B. Filosofi Elevasi Datar (Flat Layering)
* Tidak menggunakan bayangan buram tebal (*heavy blur drop shadow*).
* Kedalaman dibuat secara bertingkat:
  1. **Tingkat 0 (Kanvas Dasar):** `#F6F6F6` (Light) / `#151515` (Dark).
  2. **Tingkat 1 (Kartu Konten):** `#FFFFFF` (Light) / `#292929` (Dark) dengan garis tepi `border`.
  3. **Tingkat 2 (Elemen Mengambang):** Modal dialog dan bottom sheet dengan bayangan redup halus:  
     `BoxShadow(color: Color(0x0D000000), blurRadius: 16, offset: Offset(0, 4))`

---

## 7. Anatomi Komponen Baku (Component Tokens)

### A. Tombol (Buttons)
Bentuk baku adalah **kapsul pil sempurna** (`Radius: 999px`):
1. **Primary Button (Filled):**
   * Latar: `accent` (`#171717` di light / `#F5F5F5` di dark).
   * Teks: `onAccent` (`#FFFFFF` di light / `#171717` di dark), font `Outfit s14 SemiBold`.
   * Tinggi: `48 px` (standar) atau `52 px` (CTA utama).
2. **Secondary / Outlined Button:**
   * Latar: Transparan.
   * Garis Tepi: `1.5 px` berwarna `borderStrong`.
   * Teks: `textPrimary`.
3. **Compact Tonal Button:**
   * Latar: `surfaceSubtle`.
   * Tinggi: `36 px`, padding horizontal `12 px`, teks `s12 SemiBold`.
4. **Destructive Button:**
   * Latar: `destructive` (`#B91C1C` / `#F87171`).
   * Teks: `onAccent`.

### B. Kartu Kajian & Kitab (Cards)
* Sudut: `24.0 px` (`OTRadius.cardBorder`).
* Latar: `surface` (`#FFFFFF` di light / `#292929` di dark).
* Garis Tepi: `1 px solid border`.
* Padding: `16 px` s/d `20 px`.
* Hover State: Garis tepi beralih menjadi `borderStrong` secara halus (durasi 180ms).

### C. Kolom Input & Kolom Pertanyaan (Composer)
* Sudut: `28.0 px` (`OTRadius.inputBorder`).
* Latar: `surface` dengan batas `1 px borderSubtle`.
* Posisi di Layar Obrolan: **Docking alami di bawah kolom baca** (*In-Flow Docking*), maksimal lebar `720 px`, terkunci presisi di tengah (*mathematical horizontal centering*). Dilarang mengambang secara absolut yang menutupi teks terakhir.

---

## 8. Durasi Animasi & Haptik (Motion & Haptics)

Gerakan di OpenTurath bersifat **tenang, presisi, dan tidak mengganggu konsentrasi**.

| Token Motion | Durasi | Kurva Akselerasi | Penggunaan |
| :--- | :---: | :--- | :--- |
| `OTMotion.fast` | **180 ms** | `Curves.easeOutCubic` | Hover state tombol, perubahan warna tab aktif |
| `OTMotion.normal` | **220 ms** | `Curves.easeOutCubic` | Transisi kartu, ekspansi akordeon daftar kitab |
| `OTMotion.sheet` | **280 ms** | `Curves.easeOutQuart` | Munculnya bottom sheet dari bawah layar |
| `OTMotion.transition`| **320 ms** | `Curves.easeInOutCubic`| Perpindahan layar halaman penuh (*page route*) |

### Scholarly Haptic Feedback
* `OTMotion.selection()`: Ketukan haptik sangat ringan saat memilih tab atau mengganti kitab.
* `OTMotion.light()`: Haptik saat menekan tombol aksi sekunder.
* `OTMotion.success()`: Haptik lembut medium saat transaksi berhasil atau jawaban AI selesai dimuat.

---

## 9. Format Ekspor Token (CSS & JSON Ready)

Bagi pengembang web atau antarmuka lain yang ingin mereplikasi desain OpenTurath AI, berikut adalah definisi token siap pakai:

### A. CSS Custom Properties (Variables)
```css
:root {
  /* ── Light Palette (Neutral Paper) ── */
  --ot-canvas-light: #F6F6F6;
  --ot-surface-light: #FFFFFF;
  --ot-surface-subtle-light: #EDEDED;
  --ot-text-primary-light: #171717;
  --ot-text-secondary-light: #606060;
  --ot-text-tertiary-light: #6B6B6B;
  --ot-border-light: #DADADA;
  --ot-border-subtle-light: #EBEBEB;
  --ot-border-strong-light: #767676;
  --ot-accent-light: #171717;
  --ot-on-accent-light: #FFFFFF;

  /* ── Dark Palette (Obsidian Ink) ── */
  --ot-canvas-dark: #151515;
  --ot-surface-dark: #292929;
  --ot-surface-subtle-dark: #353535;
  --ot-text-primary-dark: #F5F5F5;
  --ot-text-secondary-dark: #B8B8B8;
  --ot-text-tertiary-dark: #9A9A9A;
  --ot-border-dark: #454545;
  --ot-border-subtle-dark: #2D2D2D;
  --ot-border-strong-dark: #808080;
  --ot-accent-dark: #F5F5F5;
  --ot-on-accent-dark: #171717;

  /* ── Disciplined Radius ── */
  --ot-radius-xs: 8px;
  --ot-radius-card: 24px;
  --ot-radius-input: 28px;
  --ot-radius-dialog: 28px;
  --ot-radius-sheet: 32px;
  --ot-radius-hero: 32px;
  --ot-radius-pill: 999px;

  /* ── Typography Stack ── */
  --ot-font-editorial: 'Newsreader', Georgia, serif;
  --ot-font-ui: 'Outfit', -apple-system, BlinkMacSystemFont, sans-serif;
  --ot-font-arabic: 'Scheherazade New', 'Amiri', serif;

  /* ── Transitions ── */
  --ot-motion-fast: 180ms cubic-bezier(0.215, 0.61, 0.355, 1);
  --ot-motion-normal: 220ms cubic-bezier(0.215, 0.61, 0.355, 1);
  --ot-motion-sheet: 280ms cubic-bezier(0.165, 0.84, 0.44, 1);
}
```

### B. JSON Tokens
```json
{
  "system": "OpenTurath Monochrome Editorial",
  "version": "2.0.0",
  "colors": {
    "light": {
      "canvas": "#F6F6F6",
      "surface": "#FFFFFF",
      "surfaceSubtle": "#EDEDED",
      "textPrimary": "#171717",
      "textSecondary": "#606060",
      "border": "#DADADA",
      "accent": "#171717"
    },
    "dark": {
      "canvas": "#151515",
      "surface": "#292929",
      "surfaceSubtle": "#353535",
      "textPrimary": "#F5F5F5",
      "textSecondary": "#B8B8B8",
      "border": "#454545",
      "accent": "#F5F5F5"
    }
  },
  "radii": {
    "xs": 8,
    "card": 24,
    "input": 28,
    "dialog": 28,
    "sheet": 32,
    "hero": 32,
    "button": 999,
    "chip": 999
  },
  "fonts": {
    "editorial": "Newsreader",
    "interface": "Outfit",
    "arabic": "Scheherazade New"
  },
  "motion": {
    "fastMs": 180,
    "normalMs": 220,
    "sheetMs": 280
  }
}
```

---
*Dokumen ini merupakan rujukan paten desain resmi OpenTurath AI. Seluruh komponen baru wajib merujuk pada spesifikasi di atas untuk menjaga keutuhan visual "The Quiet Islamic Scholar".*
