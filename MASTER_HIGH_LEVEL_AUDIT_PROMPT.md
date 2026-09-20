# MASTER AUDIT TINGKAT TINGGI & REFACTOR SOLUTIF — OPENTURATH AI
**Versi Sasaran:** OpenTurath AI v1.0.51+52 (Flutter Cross-Platform: Android & macOS)  
**Tujuan Utama:** Penyempurnaan Menyeluruh pada UI, UX, Ergonomi, Copywriting Santri Alami, Arsitektur 3 Bahasa (ID/EN/AR), Splash Screen Kelas Internasional, Penerapan Logo Vektor Resmi (`OpenTurath_logo_transparent.svg`), Sistem Harga Promo Coret, Eksklusivitas Fikih Tahawwulat, Penataan Pustaka, dan Kartu Pengaturan — **Tanpa Mengubah Bahasa Desain Dasar (Tetap Elegan, Hening, dan Monokrom Editorial).**

---

## 🎯 PERAN & PETUNJUK KERJA AUDITOR
Bertindaklah sebagai **Dewan Pengarah Produk Tingkat Tertinggi** yang memadukan keahlian lintas disiplin:
1. **Principal Mobile UI/UX & Flutter Architect**: Ahli hierarki visual, ritme spasi, mikro-interaksi, dan penyempurnaan komponen tanpa merusak fondasi desain yang sudah ada (*refine, don't rewrite*).
2. **Dewan Editor Bahasa Turats & Senior Santri/Akademisi**: Pakar adab talaqqi, khat Arab, serta pemilihan diksi bahasa yang alami, berwibawa, teduh, dan membasmi seluruh istilah bot/kaku (*anti-AI slop*).
3. **Multilingual Systems Architect**: Ahli lokalisasi aplikasi lintas 3 bahasa (Indonesia, English, Arab RTL) dengan font rendering Arab yang presisi (*Scheherazade New*).
4. **World-Class Creative Copywriter**: Spesialis narasi pembuka (*splash/onboarding*) kelas dunia yang mampu menghadirkan suasana khidmat, sakral, dan berwibawa setara standar editorial internasional.
5. **FinTech & Conversion Strategist**: Spesialis penyajian kartu harga, psikologi harga coret (*anchoring effect*), dan kemasan nilai produk digital premium.

> ⚠️ **PANTANGAN KERAS (GOLDEN RULE):**
> **JANGAN PERNAH merombak bahasa desain secara keseluruhan!** Identitas visual monokrom teduh (*The Quiet Islamic Scholar*), tipografi Newsreader/Outfit/Scheherazade New, serta palet warna yang telah dibangun pengguna adalah aset utama. Tugas Anda adalah **menaikkan kelas (elevate & polish)** apa yang sudah ada hingga mencapai kesempurnaan tertinggi, merapikan yang berantakan, serta mempertegas nilai eksklusif dari setiap elemen.

---

## 📋 INSTRUKSI SPESIFIK & DAFTAR FOKUS PENYEMPURNAAN

### 1. PENERAPAN LOGO VEKTOR RESMI (`OpenTurath_logo_transparent.svg`)
Ganti seluruh aset logo aplikasi lama dengan file vektor resmi:  
📁 **`/Users/apple/Downloads/ramadhan/OpenTurath_logo_transparent.svg`**

- **Spesifikasi & Konversi Aset**:
  - File SVG master ini (1024x1024, path presisi transparan `#100f0e`) wajib dijadikan sumber tunggal untuk menghasilkan:
    1. **Android App Icon**: Generate icon mipmap (`res/mipmap-mdpi`, `hdpi`, `xhdpi`, `xxhdpi`, `xxxhdpi`) beserta *Adaptive Icon* monokrom.
    2. **macOS App Icon**: Generate icon set macOS (`macos/Runner/Assets.xcassets/AppIcon.appiconset/` dari 16px hingga 1024px).
    3. **In-App Vector Rendering**: Terapkan langsung via `flutter_svg` atau aset resolusi tinggi pada Header Beranda, Drawer, Layar Login, dan Dialog Informasi.
    4. **Web Favicon & Brand Mark**: Sinkronkan ke `openturath_ai/public/`.
- **Dokumentasi Filosofi Luhur Logo**:
  Wajib diabadikan di dokumen identitas dan dialog info aplikasi:
  ```
               ╭─────────╮
               │  FIKIH  │  ← Lengkungan Benteng Penjaga
               │TAHAWWULAT│    (Rukun Keempat / Perisai Fitnah Akhir Zaman)
            ╭──┴─────────┴──╮
            │   [ IHSAN ]   │  ← Puncak / Ruhani (Tasawuf & Adab)
            │ [ISLAM] [IMAN]│  ← Sayap Zhahir & Batin (Syariat & Akidah)
            ╰───────────────╯
  ```
  - **Tiga Bilik di Dalam**: Melambangkan **Ats-Tsawabit (Islam, Iman, Ihsan)** dari Hadits Jibril 'Alaihissalam — tiga rukun agama yang konstan, abadi, dan tidak boleh berubah sepanjang zaman.
  - **Lengkungan Kubah Luar yang Membentengi**: Melambangkan **Fikih Tahawwulat (*Ar-Rukn ar-Rābi’*)**, benteng pelindung ketiga rukun tersebut dari badai fitnah akhir zaman (*Al-Mutaghayyirāt khādimah lits-tsawābit*).
  - **Kesatuan Gerbang & Segel (*Al-Bawwābah wal-Khātam*)**: Gerbang ilmu yang terbuka lebar dan stempel otentisitas naskah para ulama mu'tamad.

---

### 2. SPLASH SCREEN DENGAN COPYWRITING KELAS INTERNASIONAL
Bangun komponen **Splash Screen / Layar Pembuka Pengenalan** yang anggun, tenang, dan memukau sebelum masuk ke beranda:
- **Koreografi Visual (The Quiet Scholar Entrance)**:
  - Transisi hening (*quiet entrance*): Munculnya logo vektor `OpenTurath_logo_transparent.svg` dengan efek *subtle breath opacity* (600ms `Curves.easeOutCubic`), disusul hadirnya tagline khidmat.
  - Latar belakang bersih monokrom adaptif (`OTColors.canvasLight` `#F6F6F3` / `OTColors.canvasDark` `#111110`).
- **Naskah Pengenalan Kelas Internasional (Trilingual)**:
  Sajikan narasi berwibawa sesuai bahasa yang aktif:
  - **Bahasa Indonesia**:
    > *“Membaca Kitab, Menelusuri Ibarah.*  
    > *Khazanah klasik para ulama salaf, dibentengi pemahaman tanda zaman, ditelaah dengan adab keilmuan dan ketajaman instrumen modern.”*
  - **English (International Scholarship Standard)**:
    > *“Returning to the Sources. Tracing the Sacred Texts.*  
    > *Classical Islamic scholarship anchored in authentic transmission, shielded by the jurisprudence of crisis, navigated with reverence and modern precision.”*
  - **العربية (Fusha Mu'tamad)**:
    > *«الرجوع إلى الأصول، واستنطاق العبارات.*  
    > *تراث العلماء الأعلام، محروسًا بفقه التحولات، ومطالعًا بأدب العلم وأحدث أدوات العصر.»*

---

### 3. PEMBERSIHAN TOTAL COPYWRITING (MEMBASMI KATA KAKU & GENERIK)
Banyak istilah di aplikasi saat ini yang terasa dipaksakan, canggung, dan tidak mencerminkan adab pesantren/talaqqi. Lakukan pembersihan radikal:
- ❌ **HAPUS KATA CACAT**:  
  - Buang kata **"Bilik"** (misal: "Bilik AI", "4 Bilik Keilmuan") $\rightarrow$ Ganti menjadi **"Ruang Telaah"**, **"Cabang Keilmuan"**, atau **"Majelis Telaah"**.
  - Buang kata **"Korpus"** (misal: "Korpus Fikih", "Korpus Kitab") $\rightarrow$ Ganti menjadi **"Khazanah Rujukan"**, **"Koleksi Kitab"**, atau **"Himpunan Marja'"**.
  - Buang istilah bot kaku seperti "AI Assistant", "Modul Training AI", "Prompt", atau "Engine" pada antarmuka santri.
- ✅ **GUNAKAN ISTILAH BAKU & ALAMI**:
  - *Pertanyaan / Prompt* $\rightarrow$ **Ibarah / Mas'alah**.
  - *Daftar AI* $\rightarrow$ **Daftar Khadim Turats / Pembimbing Telaah Kitab**.
  - *Pustaka RAG* $\rightarrow$ **Pustaka Marja' Mu'tamad**.
  - Bahasa harus mengalir tenang, santun, tidak menggurui, dan menghormati tradisi para ulama.

---

### 4. DUKUNGAN RESMI 3 BAHASA (INDONESIA, ENGLISH, DAN ARAB RTL)
Setelah istilah disanitasi menjadi alami, seluruh antarmuka aplikasi wajib mendukung **3 Bahasa Resmi**:
1. **Bahasa Indonesia (ID)**: Bahasa telaah santri nusantara yang luwes, santun, dan adem.
2. **Bahasa Arab (AR - العربية)**: 
   - Bahasa naskah turats fusha murni yang berwibawa.
   - Tata letak otomatis berbalik arah menjadi **RTL (*Right-to-Left*)** secara sempurna (`Directionality.rtl`).
   - Menggunakan font Arab resmi **Scheherazade New** dengan line-height aman ($\ge 1.85$) agar harakat tidak bertumpuk.
   - Istilah Arab baku: *المسألة*, *المراجع المعتمدة*, *مجلس المطالعة*, *خادم التراث*, *فقه التحولات*, *بطاقة الكتاب*, dll.
3. **Bahasa Inggris (EN)**: Standar akademik internasional (*Islamic Scholarship & Heritage Studies*), elegan dan presisi (*e.g., "Textual Research Chamber", "Canonical Classical Works", "Scholarly Inquiry"*).
- **Pengalih Bahasa (Language Switcher)**: Tempatkan tombol alih bahasa yang hening dan elegan di halaman Pengaturan (*Settings Screen*) dan di header beranda (*Dashboard*).

---

### 5. RESTRUKTURISASI SISTEM HARGA & HARGA CORET (STRIKETHROUGH PRICING)
Terapkan psikologi harga coret resmi dengan visual yang rapi, elegan, dan proporsional di seluruh kartu langganan (`subscription_screen.dart`, katalog GoAkal, dan modal checkout):

#### A. Seluruh AI Spesialis Mandiri (19 Bidang Ilmu)
- **Status Penawaran**: Harga Perdana / Peluncuran Spesial.
- **Harga Coret (Normal)**: `Rp 300.000` *(strikethrough text warna abu-abu netral tipis).*
- **Harga Promo Aktif**: **`Rp 50.000`** *(tipografi tebal berwibawa, jelas, dan kontras).*
- **Label Nilai**: Cantumkan lencana bersahaja seperti *"Harga Perdana · Hemat 83%"*.

#### B. Fikih Tahawwulat (Mahkota Eksklusif Keilmuan)
Fikih Tahawwulat memiliki strata tertinggi dan wajib menampilkan 3 tier durasi sesuai acuan berikut:
1. **Tier 1 Bulan**:
   - Harga Coret: `Rp 1.000.000`
   - Harga Promo: **`Rp 300.000`** `/bulan`
   - Keterangan: `(Hemat 70%)`
   - Manfaat: Akses penuh naskah, analisis sanad tanda zaman, dan telaah karya Al-Habib Abu Bakar Al-Adni Al-Masyhur.
2. **Tier 6 Bulan**:
   - Harga Coret: `Rp 2.995.000`
   - Harga Promo: **`Rp 1.499.000`** `/6 bulan`
   - Keterangan: `(Hemat 50%)`
3. **Tier 12 Bulan (1 Tahun Penuh — Pilihan Terbaik)**:
   - Harga Coret: `Rp 4.995.000`
   - Harga Promo: **`Rp 1.999.000`** `/tahun`
   - Keterangan: `(Hemat 60%)`

---

### 6. DIFERENSIASI VISUAL EKSKLUSIF FIKIH TAHAWWULAT
Fikih Tahawwulat adalah rukun keempat penjaga Tsawabit. Desainnya harus tampil **paling eksklusif dan prestisius**, baik di daftar asisten beranda maupun di kartu langganan:
- **Tetap Satu Bahasa Desain**: Jangan gunakan warna neon atau ornamen norak. Gunakan aksen garis ganda (*double-hairline border*), latar belakang kartu dengan tekstur halus bernuansa perkamen gelap/terang berwibawa, atau aksen *emerald deep* / *champagne antique* yang sangat redup dan tenang.
- **Lencana Pembeda**: Sematkan penanda kehormatan seperti:  
  *“Rukun Keempat · Benteng Penjaga Khazanah”* atau *“Khazanah Khusus Akhir Zaman”*.
- **Di Ruang Chat / Layar Asisten**: Sambutan awal dan visual header memancarkan otoritas talaqqi naskah Al-Habib Abu Bakar Al-Adni secara agung dan khidmat.

---

### 7. PENYEMPURNAAN BERANDA (DASHBOARD) & DAFTAR AI SPESIALIS
- **Setiap AI Harus Terasa Hidup & Berkarakter Spesial**:
  - Jangan buat kartu AI terlihat seragam dan dingin seperti katalog software biasa.
  - Berikan identitas keilmuan yang kuat pada masing-masing figur (misal: Fikih Syafi'i ditonjolkan kitab *Al-Umm* & *Minhajut Thalibin*; Ushul Fikih ditonjolkan *Ar-Risalah* & *Al-Mustashfa*; Hadits ditonjolkan *Kutubus Sittah*).
  - Tampilkan cuplikan bidang kajian utama dan kitab mu'tamad yang dikuasai langsung pada kartu dengan tipografi editorial yang rapi.
- **Hierarki Beranda**:
  - Hero section yang menyambut penuntut ilmu dengan tenang.
  - Penempatan Fikih Tahawwulat sebagai rujukan istimewa di posisi terhormat.
  - Akses cepat ke meja telaah terakhir yang dibuka tanpa visual berdesakan.

---

### 8. PENATAAN ULANG HALAMAN PUSTAKA (LIBRARY YANG BERANTAKAN)
Halaman pustaka (`library_metadata_overview_screen.dart` dan `book_detail_screen.dart`) harus ditata ulang agar bersih, rapi, dan nyaman untuk riset mendalam:
- **Struktur Katalog Kitab**:
  - Pisahkan kitab berdasarkan tingkatan telaah (*Matan Dasar*, *Syarah Mu'tamad*, *Hasyiyah Ilmiah*).
  - Filter disiplin ilmu yang mudah digeser secara halus tanpa memotong teks Arab.
- **Kartu Kitab**:
  - Tampilkan judul Arab (*Khat Scheherazade New*) dengan harakat proporsional, nama pengarang (*Mu'allif*), tahun wafat (*W. H*), dan tebal jilid secara elegan.
  - Hilangkan sisa teks awalan aneh seperti `AI ` atau `Super AI ` pada judul pustaka.
- **Detail Kitab**:
  - Format kartu biografi pengarang (*Tarjamah al-Mu'allif*) dan status pensahihan naskah dibuat terstruktur menyerupai lembar identitas kitab klasik (*Bithāqah al-Kitāb*).

---

### 9. STATUS FITUR SEMENTARA (KHAZANAH ULAMA & PAKET TEMATIK)
- **Khazanah Ulama**:
  - Fitur ini saat ini belum dibuka untuk publik.
  - **Instruksi**: Buat kartu penutup yang elegan dan santun (*Locked / Coming Soon Banner*) yang mengabarkan bahwa tab ini sedang dalam tahap perapihan biografi dan tahqiq sanad para ulama nusantara dan haramain.
- **Paket Tematik AI (Bundling)**:
  - **Instruksi**: Sembunyikan (*hide*) sementara dari antarmuka navigasi dan langganan agar pengguna fokus menikmati promo perdana AI Spesialis (Rp 50.000) dan Fikih Tahawwulat.

---

### 10. KARTU STATUS PELANGGAN DI HALAMAN PENGATURAN (PROFILE CARD)
Kartu keanggotaan pengguna di `profile_screen.dart` harus didesain ulang agar **sangat menarik, membanggakan, dan prestisius**:
- **Visual Passport / Kartu Santri Digital**:
  - Tampilkan nama pengguna, email, dan status langganan (*Misal: "Muhaqqiq Aktif · Akses Fikih Syafi'i" atau "Tholib Turats"*).
  - Tampilkan sisa masa aktif dengan baris tanggal Hijriah & Masehi yang tenang.
  - Desain bingkai kartu minimalis dengan sudut lengkung halus, garis tepi elegan, dan tipografi berkelas tanpa warna gradien norak.

---

## 📤 FORMAT LAPORAN & SOLUSI YANG DIBERIKAN AUDITOR
1. **Matriks Evaluasi Sebelum vs Sesudah**: Analisis titik-titik cacat beserta solusi perbaikannya.
2. **Kamus Istilah Resmi 3 Bahasa (ID, EN, AR)**: Tabel pemetaan kata dan lokalisasi seluruh string utama.
3. **Spesifikasi Kode Lengkap (Ready-to-Paste)**: Berikan blok kode Dart yang siap diterapkan langsung pada:
   - `lib/screens/splash_screen.dart` (Komponen Splash Screen Internasional & Integrasi Logo SVG)
   - `lib/core/localization.dart` & `lib/core/app_copy.dart` (Dukungan 3 Bahasa)
   - `lib/screens/subscription_screen.dart` (Harga Coret & Tier Tahawwulat)
   - `lib/screens/dashboard_screen.dart` (Hierarki Beranda & Logo Baru)
   - `lib/screens/library_metadata_overview_screen.dart` (Pustaka Kitab Rapi)
   - `lib/screens/profile_screen.dart` (Kartu Pelanggan Prestisius)
4. **Verifikasi Kepatuhan**: Pastikan seluruh solusi kode tetap menjaga 0 lint warning dan mempertahankan kelulusan 100% test suite.
