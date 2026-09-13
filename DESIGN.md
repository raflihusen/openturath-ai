# OpenTurath Design System & Philosophy Manual
**The Quiet Scholar (Al-'Alim Al-Khamus / العالم الخامل الذكر)**  
*Pedoman Desain, Arsitektur UI/UX, dan Filosofi Produk untuk Ekosistem Aplikasi OpenTurath AI*

---

## 1. Filosofi Inti: The Quiet Scholar (Al-'Alim Al-Khamus)

> **"Konten adalah tokoh utama. Antarmuka mundur satu langkah."**  
> *(Content is the protagonist; the UI takes one step back.)*

Aplikasi kajian turats, manuskrip keislaman, dan riset fatwa bukan sekadar aplikasi komersial biasa. Pengguna kita adalah santri, asatidz, peneliti, akademisi, dan kyai yang menghabiskan waktu berjam-jam membaca naskah klasik berharakat rapat, membedah ibarah rumit, dan membandingkan syarah kitab.

### Pilar Filosofis
1. **Kesahajaan & Keteduhan (Sobriety & Calm)**  
   Menolak estetika startup Silicon Valley yang hiperaktif, gradien neon mencolok, badge diskon yang berkedip, animasi berlebihan, atau pop-up agresif. Antarmuka harus menghadirkan ketenangan seperti ruang perpustakaan pesantren di keheningan malam.
2. **Kebenaran Data Tanpa Fabrikasi (Truth in Data / Zero Fabrication)**  
   Tidak boleh ada data palsu, rekayasa kategori, atau klaim asal demi mempercantik tampilan kartu. Jika suatu naskah belum memiliki data era atau tahkik yang terverifikasi di Maktabah Syamilah, biarkan kosong secara jujur atau tampilkan status apa adanya.
3. **Adab & Kehati-hatian Ilmiah (Scholarly Adab)**  
   Aplikasi menegaskan posisinya sebagai alat bantu penelusuran ibarah naskah, bukan mufti digital atau pengganti guru yang bersanad. Nada bahasa (*tone of voice*) selalu bersahaja, santun, dan menghindari klaim mutlak.
4. **Haram Tanda Seru (!) pada Pesan Sistem**  
   Pesan sukses, notifikasi, dan toast tidak pernah menggunakan tanda seru (`!`). Keberhasilan aksi (seperti menyalin teks atau menyimpan catatan) adalah hal biasa yang tenang: *"Ibarah tersalin."*, *"Catatan disimpan."*, bukan *"Berhasil Disalin!"*.
5. **Perpaduan Presisi Apple HIG & Minimalisme Google Camera**  
   Struktur dan tata letak mengadopsi ketelitian *Apple Human Interface Guidelines* (ritme tombol, kurva radius terdisiplin, gestur sentuh haptik halus) yang dipadukan dengan keringkasan panel informasi Google Camera (informasi teknis padat disajikan dalam bentuk micro-pill EXIF yang rapi dan elegan).

---

## 2. Palet Warna: Obsidian & Kertas Kitab (Parchment)

### Prinsip Utama: Anti-Gold & Monokrom Disiplin
- **LARANGAN KERAS WARNA EMAS / GOLD**:  
  Warna emas komersial (`#D4AF37`, `#FFD700`, aksen kuning mengkilap) **DIHARAMKAN SECARA PATEN**. Warna emas murah menimbulkan kesan aplikasi religius komersial yang norak (*tacky*).
- **Dominasi Monokrom & Netral**:  
  Nuansa islami dan kewibawaan lahir dari isi teks, tipografi Arab yang anggun, dan perataan tata letak, bukan dari ornamen kubah atau kaligrafi warna-warni yang mengganggu fokus membaca.

---

### A. Dark Mode (Deep Obsidian Canvas)
Mode gelap adalah kanvas utama penelitian malam hari. Menghindari warna abu-abu kebiruan murahan; menggunakan obsidian pekat dengan kontras tinggi berstandar WCAG AAA.

| Token | Nilai Hex | Peran & Penggunaan |
|---|---|---|
| `canvasDark` | `#0E0E10` | Latar belakang utama layar (Deep Obsidian). Memberikan kedalaman absolut tanpa silau. |
| `surfaceDark` | `#18181B` | Permukaan kartu, sheet modal, dialog, dan app bar (Zinc 900). |
| `surfaceSubtleDark` | `#27272A` | Wadah inset, latar belakang micro-pill, dan kontainer sekunder (Zinc 800). |
| `borderDark` | `#27272A` | Garis tepi batas kartu dan pemisah (0.8px - 1px hairline border). |
| `borderSubtleDark` | `#1E1E22` | Garis pemisah tipis antar baris metadata naskah. |
| `textPrimaryDark` | `#FAFAFA` | Teks utama, judul Arab, nama pengarang (Zinc 50, kontras maksimal). |
| `textSecondaryDark` | `#A1A1AA` | Label metadata, sub-judul, teks penjelasan (Zinc 400, >7.0:1 WCAG AAA). |
| `textTertiaryDark` | `#71717A` | Placeholder input teks, nomor jilid tidak aktif, waktu riwayat (Zinc 500). |
| `accentDark` | `#60A5FA` | Aksen safir intelektual lembut untuk ikon aktif, tautan, dan indikator pilihan. |

---

### B. Light Mode (Warm Stone / Kertas Kitab Tua)
Menolak warna putih murni yang menusuk mata (`#FFFFFF` murni pada seluruh kanvas layar). Menggunakan warna hangat batu alam dan kertas naskah klasik.

| Token | Nilai Hex | Peran & Penggunaan |
|---|---|---|
| `canvasLight` | `#FAFAF9` | Latar belakang layar (Warm Stone Off-White). Nyaman di mata untuk membaca lama. |
| `surfaceLight` | `#FFFFFF` | Permukaan kartu dan sheet modal (Pure Paper White). |
| `surfaceSubtleLight` | `#F4F4F5` | Wadah inset micro-pill dan kolom input pencarian (Zinc 100). |
| `borderLight` | `#E4E4E7` | Garis tepi batas kartu (0.8px hairline neutral border). |
| `borderSubtleLight` | `#F1F5F9` | Garis pemisah tipis di dalam kartu. |
| `textPrimaryLight` | `#18181B` | Teks utama, judul naskah, teks matan Arab (Ink Black). |
| `textSecondaryLight` | `#52525B` | Label naskah, nama penahkik, keterangan terbit (Zinc 600, >4.5:1 WCAG AA). |
| `textTertiaryLight` | `#71717A` | Metadata sekunder dan hint pencarian. |
| `accentLight` | `#2563EB` | Aksen safir intelektual terarah untuk status terpilih dan tombol aksi utama. |

---

### C. Aksen Semantik Khusus
| Token | Nilai Hex | Peran & Penggunaan |
|---|---|---|
| `sovereignAmber` | `#D97706` | Khusus korpus independen istimewa (seperti Fikih Tahawwulat). Memberi penanda berwibawa tanpa norak. |
| `sovereignAmberBg` | `#1AD97706` | 10% amber wash untuk wadah lencana korpus independen. |
| `success` | `#10B981` | Emerald Green lembut, hanya dipakai saat ada konfirmasi penting (misal status aktif langganan). |
| `destructive` | `#DC2626` | Deep Crimson, eksklusif untuk tombol hapus catatan atau tindakan permanen. |

---

## 3. Tipografi: 3-Layer Strict Architecture

Sistem tipografi OpenTurath membagi hierarki teks ke dalam 3 lapisan fungsional yang pantang dicampuradukkan:

```
┌─────────────────────────────────────────────────────────────┐
│ 1. BRAND & EDITORIAL LAYER       (Newsreader Serif)         │
│    Digunakan untuk Identitas Brand & Judul Literatur         │
├─────────────────────────────────────────────────────────────┤
│ 2. INTERFACE LAYER               (Outfit Sans)              │
│    Digunakan untuk Tombol, Input, Metadata, Navigasi, Angka │
├─────────────────────────────────────────────────────────────┤
│ 3. ARABIC SCHOLARLY LAYER        (Amiri Naskh)              │
│    Digunakan untuk Matan, Kutipan Ibarah, Teks Arab Kitab   │
└─────────────────────────────────────────────────────────────┘
```

### 1. Brand & Editorial Layer (`Newsreader`)
Memberikan sentuhan penerbitan buku literatur klasik dan percetakan ilmiah terkemuka.
- **Brand Wordmark**: `Newsreader`, 21-22px, `FontWeight.w600`, `letterSpacing: -0.4`.
- **Editorial Hero**: `Newsreader`, 26px, `FontWeight.w600`, `letterSpacing: -0.5`, `height: 1.25`.
- **Corpus Title**: `Newsreader`, 18px, `FontWeight.w600`, `letterSpacing: -0.2`.

### 2. Interface Layer (`Outfit`)
Sans-serif geometris humanis kontemporer yang sangat tajam pada resolusi retina. Karakter huruf dirapatkan sedikit (*tight tracking*) untuk kesan modern, bersih, dan ringkas.
- **Screen Title**: `Outfit`, 20px, `FontWeight.w600`, `letterSpacing: -0.3`.
- **Card Title / Author**: `Outfit`, 15px, `FontWeight.w600`, `letterSpacing: -0.1`.
- **Body Regular**: `Outfit`, 14px, `FontWeight.w400`, `height: 1.45`.
- **Body Medium**: `Outfit`, 14px, `FontWeight.w500`, `height: 1.40`.
- **Caption**: `Outfit`, 12px, `FontWeight.w400`, `height: 1.35`.
- **Micro Label / Section Header**: `Outfit`, 11px, `FontWeight.w600`, `letterSpacing: 0.8` (Uppercase).
- **Button Action**: `Outfit`, 14px, `FontWeight.w600`, `letterSpacing: 0.1`.
- **Price Metric**: `Outfit`, 24px, `FontWeight.w700`, `letterSpacing: -0.5`.

### 3. Arabic Scholarly Layer (`Amiri`)
Tulisan Arab klasik menggunakan khat Naskh berbobot proporsional yang menjaga kejelasan syakal/harakat.
- **Aturan Wajib Teks Arab**:
  1. Wajib menggunakan `textDirection: TextDirection.rtl`.
  2. Wajib menggunakan `height: 1.6` hingga `1.8` agar harakat atas (fathah, tanwin, fathatain) dan harakat bawah (kasrah) tidak terpotong tepi baris (*clipping*).
  3. Warna teks Arab pada mode gelap wajib putih bersih (`#FAFAFA` atau `#F8FAFC`).
- **Tingkatan Ukuran Arab**:
  - `arabicDisplay` (Judul Utama Kitab): `Amiri`, 22-24px, `FontWeight.w700`, `height: 1.6`.
  - `arabicReading` (Daftar Baris Naskah): `Amiri`, 18-19px, `FontWeight.w600` - `w700`, `height: 1.7`.
  - `arabicQuote` (Ibarah & Sanad): `Amiri`, 16-17px, `FontWeight.w500`, `height: 1.8`.

---

## 4. Sistem Spasi & Geometri Radius

### Ritme Kelipatan 4 (Base-4 Rhythm)
Menolak angka ganjil atau acak (seperti 13, 19, 27, 31). Seluruh jarak tata letak menggunakan proporsi matematis kelipatan 4:
```dart
static const double xs = 4.0;
static const double sm = 8.0;
static const double md = 12.0;
static const double base = 16.0;
static const double lg = 20.0;
static const double xl = 24.0;
static const double xxl = 32.0;
static const double huge = 40.0;
```

### Sistem 3 Radius Terdisiplin (Disciplined Curvature)
Menghindari tren *"bubble-boxing"* (pembulatan berlebihan seperti 28px-36px pada kotak kartu persegi yang membuatnya terlihat seperti bantal kartun).
1. **Pill Curvature (`999px`)**:  
   Khusus untuk tombol aksi (*buttons*), filter chip, search bar utama, dan micro-badge EXIF.
2. **Container / Card Radius (`16px`)**:  
   Baku untuk seluruh kartu naskah (`BookRowItem`), kartu asisten (`SpecialistCard`), dan kartu catatan.
3. **Modal Sheet Radius (`24px`)**:  
   Hanya untuk sudut kiri atas dan kanan atas lembar dialog bawah (*bottom sheet*).
4. **Dialog Radius (`20px`)**:  
   Untuk modal konfirmasi di tengah layar.
5. **Inner Input Field (`14px`)**:  
   Untuk kotak formulir isian data.

---

## 5. Blueprint Komponen Unggulan

### A. Kartu Naskah Bergaya Google Camera EXIF (`BookRowItem`)
Kartu naskah tidak menggunakan pita vertikal warna-warni. Menggunakan bahasa desain informasi lensa kamera Google:
1. **Top Bar**:
   - Nomor edisi `#kitab_id` dalam wadah abu-abu halus.
   - Tag disiplin ilmu (`القسم`) di sisi kiri.
   - Tahun wafat mualif: `w. [Tahun] H` di sisi kanan dengan border 0.5px.
2. **Hero Area**:
   - Judul Arab berukuran 18px (Amiri RTL Bold).
   - Nama pengarang (Latin atau Arab) dengan ikon orang monokrom.
3. **Strip Informasi EXIF Micro-Pill (Horizontal Wrap)**:
   - Deretan pil mikro dengan ikon outline 12px dan teks 11px:
     `[ ≡ 8 jilid ]` · `[ 📄 420 hlm ]` · `[ Tahkik: Nama ]` · `[ Penerbit: Nama ]` · `[ Thn: 1421 H ]`.
   - 100% monokrom netral (abu-abu slate). Tidak ada elemen biru mencolok.

```
┌─────────────────────────────────────────────────────────────┐
│  #1402  الفقه الشافعي                               w. 204 H│
│                                                             │
│                                           كتاب الأم         │
│  👤 Imam Muhammad bin Idris Asy-Syafi'i                     │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ ≡ 8 jilid  ·  📄 4.200 hlm  ·  Tahkik: Dr. Rifa'at    │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

### B. Lembar Rujukan & Kutipan Ilmiah (`EvidenceBottomSheet`)
- **Header**: Berjudul tenang `'Ibarah & rujukan'`.
- **Naskah Asli**: Ditampilkan dalam kontainer berbingkai halus dengan font Amiri ukuran 19px, teks RTL, teks tebal berharakat.
- **Intisari & Penjelasan**: Bagian syarah dan penjelasan kontekstual.
- **Aksi Baku**:
  - Tombol kiri: `Salin ibarah` (Ikon Copy, Outlined Button).
  - Tombol tengah: `Buka di Maktabah Syamilah` (Ikon Open in New, Filled Button).
  - Tombol kanan: `Salin rujukan ilmiah` (Ikon Share, Tonal Button).

---

### C. Ruang Percakapan Multi-Tab Keep-Alive
- **Filosofi**: Seperti tab pada browser Google Chrome.
- **Perilaku**:
  - Membuka spesialis AI tidak boleh memuat ulang (*reload*) jika sesi sudah pernah dibuka sebelumnya.
  - Tab berjalan di latar belakang (*offstage keep-alive*) agar percakapan dan telaah tidak hilang saat pengguna beralih membaca katalog kitab.
  - Penutupan tab memerlukan konfirmasi yang tenang: *"Tutup percakapan?"*.

---

### D. Penanganan Kendala Tenang (`AppErrorState`)
Layar kendala tidak boleh panik atau menyalahkan pengguna:
- **Koneksi Terputus**: *"Tidak dapat memuat data rujukan saat ini. Periksa koneksi internet lalu coba lagi."* (Aksi: `Coba lagi`).
- **Akses Dibatasi**: *"Sesi akun kedaluwarsa atau modul telaah membutuhkan paket langganan aktif."* (Aksi: `Lihat paket langganan`).
- **Rujukan Tidak Ditemukan**: *"Tidak ada kitab atau catatan yang sesuai dengan kata kunci atau saringan."* (Aksi: `Atur ulang pencarian`).
- **Kendala Teknis**: *"Sistem mengalami kendala saat memproses telaah. Silakan coba kembali beberapa saat lagi."* (Aksi: `Muat ulang`).

---

### E. Loader Tiga Titik Berdenyut (`AppLoader`)
- Menggantikan spinner roda berputar (*circular progress*) yang melelahkan mata.
- Tiga bulatan kecil berukuran 9px yang berdenyut berurutan (*wave pulse*) dengan jeda 200ms per titik. Memberikan kesan aplikasi sedang berpikir mendalam.

---

## 6. Standar Interaksi & Sentuhan (Haptics & Motion)

### Umpan Balik Sentuh (Apple Interactive Wrapper)
Setiap elemen kartu dan tombol interaktif wajib dibungkus dengan wrapper interaktif yang menghasilkan:
1. **Pressed Scale**: Reduksi ukuran halus ke `0.985` saat ditekan, lalu kembali ke `1.0` dengan kurva `Curves.easeOutCubic`.
2. **Haptic Feedback**:
   - `HapticFeedback.lightImpact()` pada sentuhan kartu dan tombol utama.
   - `HapticFeedback.selectionClick()` pada pergantian tab navigasi atau filter chip.
   - `HapticFeedback.mediumImpact()` khusus saat menyimpan naskah ke catatan.
3. **Durasi Transisi**:
   - Cepat (micro-interaction): `180ms`.
   - Normal (dialog/fade): `220ms`.
   - Lembar Bawah (sheet slide): `280ms`.

---

## 7. Kamus Istilah Baku & Pedoman Copywriting

### A. Tabel Istilah Baku (Wajib Dipatuhi)

| Istilah Terlarang / Usang | Istilah Baku Wajib | Alasan & Konteks Keilmuan |
|---|---|---|
| *Karya Ulama* / *Daftar Ulama* | **`Khazanah Ulama`** | Nama resmi kategori ulama. Pantang diubah atau disederhanakan. |
| *Kategori* / *Korpus* | **`Bidang Ilmu`** | Menggambarkan disiplin keislaman secara ilmiah dan alami. |
| *Teks Naskah* / *Kutipan Arab* | **`Ibarah`** (`عبارة`) | Istilah autentik turats untuk nukilan teks kitab rujukan. |
| *Salin Teks* (pada jawaban AI) | **`Salin jawaban`** | Jawaban AI adalah penjelasan/elaborasi, bukan naskah kitab asli. |
| *Salin Teks* (pada kutipan kitab) | **`Salin ibarah`** | Menghormati kedudukan nukilan teks matan/ibarah asli. |
| *Penyunting* / *Pentahqiq* / *Tahqiq* | **`Penahkik`** / Label **`Tahkik:`** | Transliterasi baku bahasa Indonesia untuk *muhaqqiq* naskah. |
| *Saraf* / *Ilmu Saraf* | **`Nahwu, Sharaf, dan Balaghah`** | Kata "Saraf" berkonotasi medis (urat syaraf). Wajib menggunakan `Sharaf`. |
| *Ushul Fiqh* / *Ushul Fiqih* | **`Usul Fikih`** | Ejaan baku bahasa keislaman akademis. |
| *Hadits* / *Hadist* | **`Hadis`** | Ejaan baku KBBI/akademis untuk ilmu riwayat hadis. |
| *Aqidah* / *Teologi* | **`Akidah`** | Ejaan baku transliterasi keislaman. |
| *Tasawuf & Perilaku* | **`Tasawuf & Akhlak`** | Terminologi pesantren yang dihormati dan baku. |
| *Pustaka Syafi'i* | **`Kitab rujukan`** | Menyatakan rujukan ilmiah yang relevan untuk setiap disiplin/ulama. |
| *Ruang Kajian* | **`Percakapan`** / **`Tampilan bacaan`** | Menghindari kesan bombastis atau ruang kelas virtual palsu. |

---

### B. Daftar Kosakata Pemasaran yang Dilarang Keras
Kata-kata berikut **DILARANG DIGUNAKAN** di seluruh antarmuka aplikasi:
- ❌ *Korpus* (terlalu kaku/akademis linguistik dingin)
- ❌ *Penelaahan* (diganti dengan kata yang lebih natural seperti *kajian*, *telaah*, atau *bacaan*)
- ❌ *Komprehensif* (klaim berlebih)
- ❌ *Secara menyeluruh* (klaim berlebih)
- ❌ *Solusi terlengkap / Solusi mutakhir* (jargon sales SaaS)
- ❌ *Terintegrasi* (jargon korporat)
- ❌ *Optimal / Presisi* (klaim hiperbolis teknologi)
- ❌ *Berbasis AI paling canggih* (bombastis dan merendahkan martabat ilmu turats)

---

## 8. Prinsip Kerahasiaan Akses & Voucher

- **PEMBERSIHAN KODE VOUCHER RAHASIA**:  
  Seluruh kode promo atau voucher perdana rahasia (seperti kode `PERDANA`) **HARAM DIBOCORKAN** di dalam teks layar aplikasi.
- Label tombol penukaran kode adalah: **`Tukar Kode Akses`** atau **`Gunakan Kode Akses`**.
- Input field hanya memuat placeholder: *"Masukkan kode akses..."* tanpa pernah mencantumkan contoh kode rahasia.

---

## 9. Checklist Kepatuhan Desain untuk Fitur / Aplikasi Baru

Gunakan checklist ini sebelum merilis modul, layar, atau aplikasi turunan baru:

- [ ] **Tanpa Warna Emas**: Apakah sama sekali tidak ada warna kuning emas `#D4AF37` di seluruh layar?
- [ ] **Integritas Dark Mode**: Apakah latar belakang pada mode gelap menggunakan `#0E0E10` pekat dan border hairline `#27272A` (bukan abu-abu terang)?
- [ ] **Tipografi 3-Lapis**: Apakah judul brand memakai `Newsreader`, antarmuka memakai `Outfit`, dan teks Arab memakai `Amiri`?
- [ ] **Line-Height Teks Arab**: Apakah teks Arab berharakat memiliki line-height minimal `1.6` - `1.8` dan RTL?
- [ ] **Format Kartu EXIF Minimalis**: Apakah kartu naskah menggunakan badge micro-pill EXIF horizontal tanpa strip pita biru?
- [ ] **Bebas Tanda Seru**: Apakah seluruh pesan sukses, toast, dan dialog konfirmasi 100% bebas dari tanda seru (`!`)?
- [ ] **Konsistensi Istilah**: Apakah menggunakan istilah `Khazanah Ulama`, `Ibarah`, `Salin jawaban`, `Salin ibarah`, `Tahkik:`, dan `Nahwu, Sharaf, dan Balaghah`?
- [ ] **Kerahasiaan Voucher**: Apakah tidak ada teks publik yang membocorkan kode voucher rahasia?
- [ ] **Haptik & Sentuhan**: Apakah seluruh elemen yang dapat ditekan menggunakan `AppleInteractiveWrapper` dengan `lightImpact`?
- [ ] **Uji Unit & Analisis Statis**: Apakah `flutter analyze lib/` menghasilkan 0 error dan seluruh pengujian lolos 100%?
