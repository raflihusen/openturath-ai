# MASTER AUDIT BUNDLE: OPENTURATH AI (v1.0.21+22)
# ==============================================================================
# PERHATIAN UNTUK AI AUDITOR (CLAUDE / CHATGPT / GEMINI):
# Dokumen ini adalah SATU KESATUAN BERKAS TUNGGAL (SINGLE MONOLITHIC AUDIT PACK)
# yang memuat seluruh instrumen audit, spesifikasi arsitektur, dan seluruh
# kode sumber resmi aplikasi OpenTurath AI tanpa ada yang dipotong:
#
#   BAGIAN 1: INSTRUKSI & MASTER PROMPT AUDIT FORENSIK 360° (7 PILAR AUDIT)
#   BAGIAN 2: DOKUMENTASI KONTEKS PROYEK & ATURAN KERJA
#   BAGIAN 3: KEAMANAN DATABASE (firestore.rules) & BACKEND (functions/src/index.ts)
#   BAGIAN 4: SELURUH BASIS KODE SUMBER FLUTTER (52 berkas lengkap di openturath_ai/lib/)
#   BAGIAN 5: SUITE PENGUJIAN UNIT & INTEGRASI (8 berkas lengkap di openturath_ai/test/)
#
# TUGAS ANDA:
# Pelajari seluruh arsitektur dan baris kode pada Bagian 2 sampai Bagian 5,
# kemudian hasilkan Laporan Audit Forensik 360° sesuai 5 format output yang
# diinstruksikan pada Bagian 1 di bawah ini.
# ==============================================================================

# BAGIAN 1: MASTER PROMPT AUDIT FORENSIK KOMPREHENSIF 360°

### 1. PERAN & SIKAP AUDITOR
Bertindaklah sebagai Dewan Auditor Independen Tingkat Tertinggi yang terdiri dari:
1. **Principal Mobile & Flutter Architect** (Spesialis optimasi performa, siklus hidup memori, arsitektur reaktif, dan pencegahan resource leak).
2. **Principal Cloud Security & FinTech Systems Auditor** (Spesialis keamanan transaksi, idempotensi webhook, aturan keamanan Firestore, dan proteksi otentikasi).
3. **Staff Product Designer & Ergonomist** (Standar produk kelas dunia setara Apple, Linear, Readwise, dan Notion; spesialis "Minimalist Purism").
4. **Chief Islamic Scholarship Editor & Pakar Turats** (Menjaga adab ilmiah, sanad naskah, ketepatan marja' mu'tamad, dan membasmi bahasa buatan bot / anti-AI slop).

> **PRINSIP AUDIT:** Bersikaplah objektif, kritis, jujur tanpa basa-basi (*brutally honest*), dan jangan tutupi kelemahan apa pun. Tugas Anda adalah menemukan bug tersembunyi, celah keamanan, kelemahan ergonomi, inkonsistensi arsitektur, dan bahasa yang kaku di seluruh basis kode proyek.

---

### 2. KONTEKS PROYEK & SUMBER DAYA
- **Nama Proyek:** OpenTurath AI (v1.0.21+22)
- **Karakter Produk:** Meja Telaah Digital (*Scholarly Research Desk*) naskah primer kitab kuning (turats) berbasis RAG engine Google NotebookLM untuk kalangan santri, asatidz, dan peneliti akademis.
- **Basis Kode Terlampir:** Seluruh dokumen arsitektur, aturan keamanan, backend Cloud Functions, seluruh kode Flutter (52 berkas), dan suite pengujian unit telah **TERLAMPIR LENGKAP PADA BAGIAN 2 SAMPAI BAGIAN 5 DI BAWAH INI**.
- **Dokumen Referensi Kunci dalam Berkas Ini:**
  - `PROJECT_HANDOVER.md` (Konteks status terkini & katalog harga tunggal).
  - `AGENTS.md` (Protokol ketat pengerjaan & aturan git).
  - `canonical_syafii.json` (Katalog 89 kitab mu'tamad Mazhab Syafi'i).
  - `openturath_ai/lib/` (Seluruh layer antarmuka dan logika Flutter).
  - `openturath_ai/functions/src/index.ts` (Backend Cloud Functions & webhook DOKU).
  - `openturath_ai/firestore.rules` (Aturan keamanan database NoSQL).

---

### 3. TUJUH PILAR AUDIT YANG WAJIB ANDA BEDAH

#### PILAR 1: Ergonomi UI/UX & Desain "Minimalist Purism"
1. **Pembersihan Visual & Clutter**: Evaluasi konsistensi prinsip *minimalist purism* (tanpa logo grafis berlebih, tanpa ikon kotak warna-warni yang mengganggu fokus telaah, tanpa teks deskripsi yang membuat layar penuh sesak).
2. **Hierarki Tipografi**: Periksa penerapan 3 lapis font:
   - *Newsreader* (Serif): Judul korpus, brand, dan aksen editorial.
   - *Outfit* (Sans): UI, navigasi, tombol, metadata.
   - *Amiri* (Arabic): Teks Arab naskah asli (keterbacaan harakat, line-height 1.6–1.8, RTL).
3. **Ergonomi Input & Formulir**: Pastikan tidak ada "border dalam border" pada bilah pencarian stadium pill saat fokus aktif, serta pastikan kontras warna memenuhi standar WCAG AA (minimal 4.5:1 untuk teks normal).
4. **Mikro-Interaksi & Transisi Animasi**: Evaluasi kehalusan transisi antar layar dan tab navigasi (`PageView` kurva `Curves.easeOutCubic`), serta umpan balik taktil pegas (`AppleInteractiveWrapper`).

#### PILAR 2: Arsitektur Flutter, State Lifecycle & Performa Memori
1. **Pencegahan Memory Leak**: Periksa apakah ada `TextEditingController`, `PageController`, `AnimationController`, `Timer`, atau listener `StreamSubscription` yang tidak di-dispose dengan aman pada blok `try...finally`.
2. **Rekonstruksi Widget (Rebuild Optimization)**: Audit penggunaan `setState`, `ValueListenableBuilder`, dan `ChangeNotifier` (`BookmarkService`, `AppConfig`). Apakah ada rebuild berlebih (*unnecessary tree rebuild*) pada daftar scroll panjang?
3. **List Virtualization**: Pastikan seluruh list dinamis menggunakan `.builder` atau `.separated` dengan `shrinkWrap: true` yang tidak memicu lag rendering GPU.

#### PILAR 3: Keamanan Cloud Functions, Transaksi Finansial (DOKU) & Hak Akses
1. **Idempotensi Webhook & Anti-Replay**: Analisis `processSuccessfulPayment` di `functions/src/index.ts`. Apakah ada celah transaksi ganda jika webhook DOKU ditembak berulang kali secara simultan?
2. **Atomisitas Firestore**: Verifikasi bahwa pembaruan status transaksi, aktivasi hak akses (`entitlements`), dan pencatatan outbox dijalankan dalam satu `db.runTransaction` atomik.
3. **Decoupling Identitas Akun**: Pastikan email yang dimasukkan saat pembayaran DOKU tidak pernah menimpa UID atau email autentikasi Firebase pengguna.
4. **Sistem Kode Redeem (Voucher)**: Audit logika `redeemCode`. Apakah tahan terhadap serangan *brute force*, race condition klaim ganda, atau penipuan durasi kedaluwarsa?
5. **Kepatuhan Firestore Rules (`firestore.rules`)**: Uji apakah pengguna biasa dapat memodifikasi koleksi `entitlements`, `transactions`, atau `provisioning_outbox` secara ilegal dari client SDK.

#### PILAR 4: Isolasi WebView, Kontainerisasi RAG & Anti-Disclaimer
1. **Scrubbing Disclaimer Google/Gemini**: Evaluasi efektivitas injeksi CSS dan script JavaScript DOM cleaner dalam menyembunyikan teks disclaimer (*"Gemini may display inaccurate info..."*, *"NotebookLM can be inaccurate"*, *"can make mistakes"*, header Google, logo bar, dsb.). Apakah script ini tahan terhadap mutasi DOM asinkron?
2. **Pencegahan Compound Font Explosion**: Periksa fungsi zoom teks `applyTurathFontScale`. Apakah perkalian font stabil atau memicu lonjakan ukuran eksponensial pada elemen bersarang?
3. **Keamanan URL & Redirection Guard**: Pastikan `shouldOverrideUrlLoading` memblokir redirect keluar yang tidak sah tanpa merusak alur autentikasi resmi akun Google atau sesi NotebookLM.

#### PILAR 5: Anti-AI Slop, Copywriting Ilmiah & Adab Turats
1. **Pembasmian Bahasa Robotik / Generik**: Cari kalimat-kalimat klise hasil generate AI yang kaku, bertele-tele, atau terasa palsu.
2. **Register Bahasa Santri Akademis**: Pastikan seluruh teks navigasi, pesan kesalahan (*AppSnackBar*), dialog langganan, dan empty state menggunakan bahasa Indonesia yang **tenang, ringkas, berwibawa, ilmiah, dan beradab** (misal: menghargai tradisi sanad talaqqi dan kehati-hatian/ihtiyath ilmiah).

#### PILAR 6: Ketahanan Offline, Penanganan Error & Kepatuhan Platform
1. **Resiliensi Jaringan**: Bagaimana aplikasi merespons kegagalan koneksi saat membuka WebView, memuat daftar spesialis, atau mengecek status langganan? Apakah in-memory cache dan fallback lokal berfungsi optimal?
2. **Kepatuhan Google Play (Account Deletion Protocol)**: Audit alur `AuthService.deleteAccount()`. Apakah proses menghapus akun Auth Firebase dilakukan sebelum data Firestore dibersihkan untuk mencegah data terhapus saat terjadi error `requires-recent-login`?
3. **Karantina Data Korup**: Pada `BookmarkService`, apakah kegagalan parsing JSON mengarantina data yang rusak atau langsung menghapus seluruh bookmark pengguna?

#### PILAR 7: Validasi Unit Test & Boundary Coverage
1. **Analisis Suite Pengujian**: Tinjau berkas-berkas di `test/` (51 test case). Apakah tes tersebut menguji batas logika nyata (*boundary conditions*, *leap years*, *clamped month-ends*, *token expiration*) atau hanya *mock assertions* dangkal?
2. **Area Tanpa Tes (Blind Spots)**: Identifikasi fungsi kritis apa saja yang belum memiliki cakupan unit test.

---

### 4. FORMAT LAPORAN AKHIR YANG WAJIB ANDA SAJIKAN

Sajikan hasil audit secara terstruktur dan mendalam dengan sistematika berikut:

#### 1. EXECUTIVE SCORECARD (Rapor 360°)
Berikan nilai (A / B / C / D / F) beserta ringkasan temuan kunci untuk masing-masing dari 7 pilar di atas.

#### 2. INVENTARISASI DEFECT & TEMUAN BUG (Tabel P0 – P3)
Kelompokkan temuan dengan format tabel:
- **Tingkat Keparahan:**
  - **P0 (Critical/Fatal):** Kebocoran keamanan, transaksi rusak, crash fatal, atau hak akses bocor.
  - **P1 (High):** Fitur utama tidak berjalan sebagaimana mestinya, memory leak, atau inkonsistensi status.
  - **P2 (Medium):** Masalah visual, animasi tersendat, border ganda, atau ketidaknyamanan ergonomis.
  - **P3 (Low):** Ketidakrapian kode, komentar usang, atau ketidakseragaman minor.
- **Kolom Tabel:** `ID Temuan` | `Tingkat (P0-P3)` | `Pilar Terkait` | `Nama File & No. Baris` | `Deskripsi Masalah & Dampak`

#### 3. MATRIKS COPYWRITING OVERHAUL (Before vs After)
Tabel perbandingan kata-kata lama (kaku / gaya bot AI) dengan alternatif baru yang ringkas, elegan, dan bernuansa ilmiah santri modern.

#### 4. REKOMENDASI KODE PERBAIKAN KONKRET (Actionable Code Patches)
Berikan potongan kode Dart / TypeScript spesifik untuk memperbaiki temuan P0 dan P1 yang paling kritis.

#### 5. ROADMAP PRIORITAS EKSEKUSI
Langkah-langkah terurut yang harus diambil oleh tim pengembang untuk menjadikan aplikasi ini 100% siap produksi dan berstandar internasional.


================================================================================
# BAGIAN 2: DOKUMENTASI KONTEKS PROYEK & ATURAN KERJA
================================================================================

## DOKUMEN: PROJECT_HANDOVER.md
```
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

```

## DOKUMEN: AGENTS.md
```
# Workspace Rules — OpenTurath AI

## 1. Automatic Checkpoint Protocol (MANDATORY)
- **Setiap perubahan sekecil apapun WAJIB langsung dibuatkan check point (Git commit) secara otomatis.**
- Setiap kali file kode, aset, UI, konfigurasi, atau unit test dimodifikasi atau ditambahkan:
  1. Jalankan `git add <files>`
  2. Lakukan commit dengan pesan yang deskriptif dan terstruktur: `git commit -m "<type>(<scope>): <pesan detail perubahan>"`
- Jangan pernah membiarkan perubahan menumpuk tanpa check point.
- Check point harus selalu dibuat secara otomatis tanpa menunggu instruksi tambahan dari pengguna.

## 2. Integritas Build & Release
- Setiap pembuatan APK rilis harus memverifikasi bahwa proses kompilasi Gradle selesai 100% dan file binary rilis yang disalin ke `/Users/apple/Downloads/ramadhan/app-release-latest.apk` memiliki timestamp baru yang valid.

```

## DOKUMEN: openturath_ai/pubspec.yaml
```
name: openturath_ai
description: "OpenTurath AI - الذكاء الاصطناعي للعلوم الإسلامية"
publish_to: 'none'
version: 1.0.21+22

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # Firebase
  firebase_core: ^3.2.0
  firebase_auth: ^5.1.0
  cloud_firestore: ^5.2.0
  cloud_functions: ^5.0.3

  # Google Sign In
  google_sign_in: ^6.2.1

  # State Management
  flutter_riverpod: ^2.5.1

  # WebView with JS Injection support
  flutter_inappwebview: ^6.0.0

  # UI & UX
  google_fonts: ^6.2.1
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  lottie: ^3.1.0
  flutter_svg: ^2.0.10+1

  # Utils
  shared_preferences: ^2.2.3
  url_launcher: ^6.3.0
  package_info_plus: ^8.0.2
  flutter_markdown: ^0.7.7+1
  crypto: ^3.0.7
  path_provider: ^2.1.6
  open_filex: ^4.7.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/animations/
    - assets/data/

```

## DOKUMEN: openturath_ai/android/app/src/main/AndroidManifest.xml
```
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- ── Izin Internet & Instalasi Pembaruan Mandiri ── -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    <uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES"/>

    <application
        android:label="OpenTurath AI"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:usesCleartextTraffic="false">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:taskAffinity=""
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">

            <!-- ── Deep Link untuk iPaymu Return URL ── -->
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.VIEW"/>
                <category android:name="android.intent.category.DEFAULT"/>
                <category android:name="android.intent.category.BROWSABLE"/>
                <data android:scheme="https"
                      android:host="openturath.ai"
                      android:pathPrefix="/payment"/>
            </intent-filter>

            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

        <!-- ── Provider untuk flutter_inappwebview ── -->
        <provider
            android:name="androidx.core.content.FileProvider"
            android:authorities="${applicationId}.fileprovider"
            android:exported="false"
            android:grantUriPermissions="true">
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/file_paths"/>
        </provider>

        <meta-data
            android:name="flutterEmbedding"
            android:value="2"/>
    </application>

    <!-- ── Queries untuk Google Sign-In & NotebookLM Native App ── -->
    <queries>
        <package android:name="com.google.android.apps.labs.language.tailwind"/>
        <intent>
            <action android:name="android.intent.action.VIEW"/>
            <data android:scheme="https" android:host="notebooklm.google.com"/>
        </intent>
        <intent>
            <action android:name="android.intent.action.VIEW"/>
            <data android:scheme="https"/>
        </intent>
        <intent>
            <action android:name="android.support.customtabs.action.CustomTabsService"/>
        </intent>
    </queries>

</manifest>

```

## DOKUMEN: canonical_syafii.json
```
{
  "الاصطلام - ط المنار": {
    "folder_or_file": "الاصطلام - ط المنار",
    "raw_filename": "الاصطلام - ط المنار",
    "is_directory": true,
    "volumes_count": 2,
    "full_title": "الاصطلام في الخلاف بين الإمامين الشافعي وأبي حنيفة",
    "canonical_short_title": "الاصطلام",
    "author_canonical": "أبو المظفر السمعاني",
    "author_full": "أبو المظفر، منصور بن محمد بن عبد الجبار السمعاني التميمي المروزي (ت 489 هـ)",
    "death_year_hijri": 489,
    "era": "ashab_al_wujuh",
    "text_type": "khilafiyyat",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "د. نايف بن نافع العمري",
    "publisher": "دار المنار للطبع والنشر والتوزيع، القاهرة"
  },
  "الأجوبة العيثاوية عن المسائل الطرابلسية.htm": {
    "folder_or_file": "الأجوبة العيثاوية عن المسائل الطرابلسية.htm",
    "raw_filename": "الأجوبة العيثاوية عن المسائل الطرابلسية.htm",
    "is_directory": false,
    "volumes_count": 1,
    "full_title": "الأجوبة العيثاوية عن المسائل الطرابلسية",
    "canonical_short_title": "الأجوبة العيثاوية",
    "author_canonical": "أحمد بن عبيد الله العيثاوي",
    "author_full": "الحسن بن أبي عبد الله الحسين العيثاوي البقاعي الشافعي",
    "death_year_hijri": 1025,
    "era": "mutaakhkhirin",
    "text_type": "ajwibah",
    "authority_rank": 3,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "عمرو عبد العظيم الحويني",
    "publisher": "دار البشائر الإسلامية للطباعة والنشر والتوزيع، بيروت - لبنان"
  },
  "الأم للشافعي - ط الفكر": {
    "folder_or_file": "الأم للشافعي - ط الفكر",
    "raw_filename": "الأم للشافعي - ط الفكر",
    "is_directory": true,
    "volumes_count": 8,
    "full_title": "الأم",
    "canonical_short_title": "الأم",
    "author_canonical": "الإمام الشافعي",
    "author_full": "أبو عبد الله محمد بن إدريس الشافعي (150 - 204 هـ)",
    "death_year_hijri": 204,
    "era": "mutaqaddimin",
    "text_type": "asl_al_madhhab",
    "authority_rank": 1,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "دار الفكر - بيروت"
  },
  "الإقناع في حل ألفاظ أبي شجاع": {
    "folder_or_file": "الإقناع في حل ألفاظ أبي شجاع",
    "raw_filename": "الإقناع في حل ألفاظ أبي شجاع",
    "is_directory": true,
    "volumes_count": 2,
    "full_title": "الإقناع في حل ألفاظ أبي شجاع",
    "canonical_short_title": "الإقناع للخطيب الشربيني",
    "author_canonical": "الخطيب الشربيني",
    "author_full": "شمس الدين، محمد بن أحمد الخطيب الشربيني الشافعي (ت 977هـ)",
    "death_year_hijri": 977,
    "era": "mutaakhkhirin",
    "text_type": "sharh",
    "authority_rank": 1,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "مكتب البحوث والدراسات - دار الفكر",
    "publisher": "دار الفكر - بيروت"
  },
  "الإقناع للماوردي.htm": {
    "folder_or_file": "الإقناع للماوردي.htm",
    "raw_filename": "الإقناع للماوردي.htm",
    "is_directory": false,
    "volumes_count": 1,
    "full_title": "الإقناع في الفقه الشافعي",
    "canonical_short_title": "الإقناع للماوردي",
    "author_canonical": "الماوردي",
    "author_full": "أبو الحسن علي بن محمد بن محمد بن حبيب البصري البغدادي، الشهير بالماوردي (ت 450هـ)",
    "death_year_hijri": 450,
    "era": "ashab_al_wujuh",
    "text_type": "mukhtashar",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": ""
  },
  "البيان في مذهب الإمام الشافعي": {
    "folder_or_file": "البيان في مذهب الإمام الشافعي",
    "raw_filename": "البيان في مذهب الإمام الشافعي",
    "is_directory": true,
    "volumes_count": 13,
    "full_title": "البيان في مذهب الإمام الشافعي",
    "canonical_short_title": "البيان في مذهب الشافعي",
    "author_canonical": "العمراني",
    "author_full": "أبو الحسين يحيى بن أبي الخير بن سالم العمراني اليمني الشافعي (ت 558هـ)",
    "death_year_hijri": 558,
    "era": "ashab_al_wujuh",
    "text_type": "sharh_mabsuth",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "قاسم محمد النوري",
    "publisher": "دار المنهاج - جدة"
  },
  "التدريب في الفقه الشافعي": {
    "folder_or_file": "التدريب في الفقه الشافعي",
    "raw_filename": "التدريب في الفقه الشافعي",
    "is_directory": true,
    "volumes_count": 4,
    "full_title": "التدريب في الفقه الشافعي المسمى بـ «تدريب المبتدي وتهذيب المنتهي»",
    "canonical_short_title": "التدريب في الفقه",
    "author_canonical": "البلقيني",
    "author_full": "سراج الدين أبي حفص عمر بن رسلان البلقيني الشافعي",
    "death_year_hijri": 805,
    "era": "mutawassithin",
    "text_type": "matn_mabsuth",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "دار القبلتين، الرياض - المملكة العربية السعودية"
  },
  "التذكرة في الفقه الشافعي.htm": {
    "folder_or_file": "التذكرة في الفقه الشافعي.htm",
    "raw_filename": "التذكرة في الفقه الشافعي.htm",
    "is_directory": false,
    "volumes_count": 1,
    "full_title": "التذكرة في الفقه الشافعي",
    "canonical_short_title": "التذكرة لابن الملقن",
    "author_canonical": "ابن الملقن",
    "author_full": "ابن الملقن سراج الدين أبو حفص عمر بن علي بن أحمد الشافعي المصري (ت 804 هـ)",
    "death_year_hijri": 804,
    "era": "mutawassithin",
    "text_type": "mukhtashar",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "محمد حسن محمد حسن إسماعيل",
    "publisher": "دار الكتب العلمية، بيروت - لبنان"
  },
  "التذهيب في أدلة متن الغاية والتقريب.htm": {
    "folder_or_file": "التذهيب في أدلة متن الغاية والتقريب.htm",
    "raw_filename": "التذهيب في أدلة متن الغاية والتقريب.htm",
    "is_directory": false,
    "volumes_count": 1,
    "full_title": "التذهيب في أدلة متن الغاية والتقريب المشهور بـ متن أبي شجاع في الفقه الشافعي",
    "canonical_short_title": "التذهيب أدلة التقريب",
    "author_canonical": "مصطفى ديب البغا",
    "author_full": "مصطفى ديب البغا الميداني الدمشقي الشافعي",
    "death_year_hijri": 1445,
    "era": "muashir",
    "text_type": "adillah",
    "authority_rank": 3,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "دار ابن كثير دمشق - بيروت"
  },
  "التعليقة للقاضي حسين": {
    "folder_or_file": "التعليقة للقاضي حسين",
    "raw_filename": "التعليقة للقاضي حسين",
    "is_directory": true,
    "volumes_count": 2,
    "full_title": "التعليقة للقاضي حسين (على مختصر المزني)",
    "canonical_short_title": "تعليقة القاضي حسين",
    "author_canonical": "القاضي حسين المروزي",
    "author_full": "القاضي أبو محمد (وأبو علي) الحسين بن محمد بن أحمد المَرْوَرُّوْذِيّ (ت 462 هـ)",
    "death_year_hijri": 462,
    "era": "ashab_al_wujuh",
    "text_type": "taliqah",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "علي محمد معوض - عادل أحمد عبد الموجود",
    "publisher": "مكتبة نزار مصطفى الباز - مكة المكرمة"
  },
  "التنبيه في الفقه الشافعي.htm": {
    "folder_or_file": "التنبيه في الفقه الشافعي.htm",
    "raw_filename": "التنبيه في الفقه الشافعي.htm",
    "is_directory": false,
    "volumes_count": 1,
    "full_title": "التنبيه في الفقه الشافعي",
    "canonical_short_title": "التنبيه",
    "author_canonical": "أبو إسحاق الشيرازي",
    "author_full": "أبو اسحاق إبراهيم بن علي بن يوسف الفيروزآبادي الشيرازي (ت 476 هـ).",
    "death_year_hijri": 476,
    "era": "ashab_al_wujuh",
    "text_type": "matn",
    "authority_rank": 1,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "عالم الكتب، بيروت."
  },
  "التهذيب في الفقه الشافعي": {
    "folder_or_file": "التهذيب في الفقه الشافعي",
    "raw_filename": "التهذيب في الفقه الشافعي",
    "is_directory": true,
    "volumes_count": 8,
    "full_title": "التهذيب في فقه الإمام الشافعي",
    "canonical_short_title": "التهذيب للبغوي",
    "author_canonical": "البغوي",
    "author_full": "محيي السنة، أبو محمد الحسين بن مسعود بن محمد بن الفراء البغوي الشافعي (ت 516 هـ)",
    "death_year_hijri": 516,
    "era": "ashab_al_wujuh",
    "text_type": "matn_sharh",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "عادل أحمد عبد الموجود، علي محمد معوض",
    "publisher": "دار الكتب العلمية"
  },
  "التهذيب في الفقه الشافعي - كتاب السير منه.htm": {
    "folder_or_file": "التهذيب في الفقه الشافعي - كتاب السير منه.htm",
    "raw_filename": "التهذيب في الفقه الشافعي - كتاب السير منه.htm",
    "is_directory": false,
    "volumes_count": 1,
    "full_title": "كتاب السير من التهذيب",
    "canonical_short_title": "التهذيب (السير)",
    "author_canonical": "البغوي",
    "author_full": "محيي السنة، أبو محمد الحسين بن مسعود بن محمد بن الفراء البغوي الشافعي (ت 516هـ)",
    "death_year_hijri": 516,
    "era": "ashab_al_wujuh",
    "text_type": "matn_sharh",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "راوية بنت أحمد الظهار",
    "publisher": "الجامعة الاسلامية بالمدينة المنورة"
  },
  "الحاوي الكبير": {
    "folder_or_file": "الحاوي الكبير",
    "raw_filename": "الحاوي الكبير",
    "is_directory": true,
    "volumes_count": 18,
    "full_title": "الحاوي الكبير في فقه مذهب الإمام الشافعي وهو شرح مختصر المزني",
    "canonical_short_title": "الحاوي الكبير",
    "author_canonical": "الماوردي",
    "author_full": "أبو الحسن علي بن محمد بن محمد بن حبيب البصري البغدادي، الشهير بالماوردي (ت 450هـ)",
    "death_year_hijri": 450,
    "era": "ashab_al_wujuh",
    "text_type": "sharh_mabsuth",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "الشيخ علي محمد معوض - الشيخ عادل أحمد عبد الموجود",
    "publisher": "دار الكتب العلمية، بيروت - لبنان"
  },
  "الخلافيات - البيهقي - ت النحال": {
    "folder_or_file": "الخلافيات - البيهقي - ت النحال",
    "raw_filename": "الخلافيات - البيهقي - ت النحال",
    "is_directory": true,
    "volumes_count": 8,
    "full_title": "الخلافيات بين الإمامين الشافعي وأبي حنيفة وأصحابه",
    "canonical_short_title": "الخلافيات للبيهقي",
    "author_canonical": "البيهقي",
    "author_full": "أبو بكر البيهقي (384 هـ - 458 هـ)",
    "death_year_hijri": 458,
    "era": "ashab_al_wujuh",
    "text_type": "khilafiyyat",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "الروضة للنشر والتوزيع، القاهرة - جمهورية مصر العربية"
  },
  "الزبد في الفقه الشافعي.htm": {
    "folder_or_file": "الزبد في الفقه الشافعي.htm",
    "raw_filename": "الزبد في الفقه الشافعي.htm",
    "is_directory": false,
    "volumes_count": 1,
    "full_title": "الزبد في الفقه الشافعي",
    "canonical_short_title": "متن الزبد",
    "author_canonical": "ابن رسلان",
    "author_full": "شهاب الدين أبو العباس أحمد بن حسين بن حسن بن علي ابن رسلان الشافعي (ت 844هـ)",
    "death_year_hijri": 844,
    "era": "mutawassithin",
    "text_type": "manzhumah",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "دار المعرفة - بيروت"
  },
  "السراج الوهاج على متن المنهاج.htm": {
    "folder_or_file": "السراج الوهاج على متن المنهاج.htm",
    "raw_filename": "السراج الوهاج على متن المنهاج.htm",
    "is_directory": false,
    "volumes_count": 1,
    "full_title": "السراج الوهاج على متن المنهاج",
    "canonical_short_title": "السراج الوهاج",
    "author_canonical": "الغمراوي",
    "author_full": "العلامة محمد الزهري الغمراوي [كان حيا سنة 1337 هـ]",
    "death_year_hijri": 1337,
    "era": "mutaakhkhirin",
    "text_type": "sharh",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": ""
  },
  "العزيز شرح الوجيز = الشرح الكبير للرافعي - ط العلمية": {
    "folder_or_file": "العزيز شرح الوجيز = الشرح الكبير للرافعي - ط العلمية",
    "raw_filename": "العزيز شرح الوجيز = الشرح الكبير للرافعي - ط العلمية",
    "is_directory": true,
    "volumes_count": 13,
    "full_title": "العزيز شرح الوجيز المعروف بالشرح الكبير",
    "canonical_short_title": "الشرح الكبير (العزيز)",
    "author_canonical": "الرافعي",
    "author_full": "عبد الكريم بن محمد بن عبد الكريم، أبو القاسم الرافعي القزويني (ت 623هـ)",
    "death_year_hijri": 623,
    "era": "mutawassithin",
    "text_type": "sharh",
    "authority_rank": 1,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "علي محمد عوض - عادل أحمد عبد الموجود",
    "publisher": "دار الكتب العلمية، بيروت - لبنان"
  },
  "الغاية في اختصار النهاية": {
    "folder_or_file": "الغاية في اختصار النهاية",
    "raw_filename": "الغاية في اختصار النهاية",
    "is_directory": true,
    "volumes_count": 8,
    "full_title": "الغاية في اختصار النهاية",
    "canonical_short_title": "الغاية اختصار النهاية",
    "author_canonical": "العز بن عبد السلام",
    "author_full": "عز الدين عبد العزيز بن عبد السلام السلمي (ت 660 هـ)",
    "death_year_hijri": 660,
    "era": "mutawassithin",
    "text_type": "mukhtashar",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "إياد خالد الطباع",
    "publisher": "دار النوادر، بيروت - لبنان"
  },
  "الغرر البهية في شرح البهجة الوردية": {
    "folder_or_file": "الغرر البهية في شرح البهجة الوردية",
    "raw_filename": "الغرر البهية في شرح البهجة الوردية",
    "is_directory": true,
    "volumes_count": 5,
    "full_title": "الغرر البهية في شرح البهجة الوردية",
    "canonical_short_title": "الغرر البهية",
    "author_canonical": "زكريا الأنصاري",
    "author_full": "زكريا بن محمد بن أحمد بن زكريا الأنصاري، زين الدين أبو يحيى السنيكي (ت 926هـ)",
    "death_year_hijri": 926,
    "era": "mutaakhkhirin",
    "text_type": "sharh",
    "authority_rank": 1,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "المطبعة الميمنية"
  },
  "الفتاوى الكبرى الفقهية": {
    "folder_or_file": "الفتاوى الكبرى الفقهية",
    "raw_filename": "الفتاوى الكبرى الفقهية",
    "is_directory": true,
    "volumes_count": 4,
    "full_title": "الفتاوى الكبرى الفقهية",
    "canonical_short_title": "الفتاوى الكبرى لابن حجر",
    "author_canonical": "ابن حجر الهيتمي",
    "author_full": "شهاب الدين، أحمد بن حجر المكي الهيتمي (909 - 974 هـ)",
    "death_year_hijri": 974,
    "era": "mutaakhkhirin",
    "text_type": "fatawa",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": ""
  },
  "الفقه المنهجي على مذهب الإمام الشافعي": {
    "folder_or_file": "الفقه المنهجي على مذهب الإمام الشافعي",
    "raw_filename": "الفقه المنهجي على مذهب الإمام الشافعي",
    "is_directory": true,
    "volumes_count": 8,
    "full_title": "الفقه المنهجي على مذهب الإمام الشافعي رحمه الله تعالى",
    "canonical_short_title": "الفقه المنهجي",
    "author_canonical": "مصطفى الخن والبغا والشربجي",
    "author_full": "مصطفى الخن والبغا والشربجي",
    "death_year_hijri": 1429,
    "era": "muashir",
    "text_type": "muashir",
    "authority_rank": 3,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "دار القلم للطباعة والنشر والتوزيع، دمشق"
  },
  "اللباب في الفقه الشافعي.htm": {
    "folder_or_file": "اللباب في الفقه الشافعي.htm",
    "raw_filename": "اللباب في الفقه الشافعي.htm",
    "is_directory": false,
    "volumes_count": 1,
    "full_title": "اللباب في الفقه الشافعي",
    "canonical_short_title": "اللباب في الفقه الشافعي",
    "author_canonical": "المحاملي",
    "author_full": "أحمد بن محمد بن أحمد بن القاسم الضبي، أبو الحسن ابن المحاملي الشافعيّ (ت 415هـ)",
    "death_year_hijri": 415,
    "era": "ashab_al_wujuh",
    "text_type": "matn",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "عبد الكريم بن صنيتان العمري",
    "publisher": "دار البخارى، المدينة المنورة، المملكة العربية السعودية"
  },
  "المجموع شرح المهذب - ط المنيرية": {
    "folder_or_file": "المجموع شرح المهذب - ط المنيرية",
    "raw_filename": "المجموع شرح المهذب - ط المنيرية",
    "is_directory": true,
    "volumes_count": 9,
    "full_title": "المجموع شرح المهذب",
    "canonical_short_title": "المجموع شرح المهذب",
    "author_canonical": "النووي",
    "author_full": "أبو زكريا محيي الدين بن شرف النووي (ت 676 هـ)",
    "death_year_hijri": 676,
    "era": "mutawassithin",
    "text_type": "sharh_mabsuth",
    "authority_rank": 1,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "(إدارة الطباعة المنيرية، مطبعة التضامن الأخوي) - القاهرة"
  },
  "المقدمة الحضرمية.htm": {
    "folder_or_file": "المقدمة الحضرمية.htm",
    "raw_filename": "المقدمة الحضرمية.htm",
    "is_directory": false,
    "volumes_count": 1,
    "full_title": "المقدمة الحضرمية (مسائل التعليم)",
    "canonical_short_title": "المقدمة الحضرمية",
    "author_canonical": "عبد الله بافضل الحضرمي",
    "author_full": "عبد الله بن عبد الرحمن بن أبي بكر بَافَضل الْحَضْرَمي السعدي المذحجي (ت 918هـ)",
    "death_year_hijri": 918,
    "era": "mutaakhkhirin",
    "text_type": "matn",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "ماجد الحموي",
    "publisher": "الدار المتحدة - دمشق"
  },
  "المنهاج القويم شرح المقدمة الحضرمية.htm": {
    "folder_or_file": "المنهاج القويم شرح المقدمة الحضرمية.htm",
    "raw_filename": "المنهاج القويم شرح المقدمة الحضرمية.htm",
    "is_directory": false,
    "volumes_count": 1,
    "full_title": "المنهاج القويم",
    "canonical_short_title": "المنهاج القويم",
    "author_canonical": "ابن حجر الهيتمي",
    "author_full": "أحمد بن محمد بن علي بن حجر الهيتمي السعدي الأنصاري، شهاب الدين شيخ الإسلام، أبو العباس (ت 974هـ)",
    "death_year_hijri": 974,
    "era": "mutaakhkhirin",
    "text_type": "sharh",
    "authority_rank": 1,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "دار الكتب العلمية"
  },
  "المهذب في فقه الإمام الشافعي - الشيرازي": {
    "folder_or_file": "المهذب في فقه الإمام الشافعي - الشيرازي",
    "raw_filename": "المهذب في فقه الإمام الشافعي - الشيرازي",
    "is_directory": true,
    "volumes_count": 3,
    "full_title": "المهذب في فقه الإمام الشافعي",
    "canonical_short_title": "المهذب",
    "author_canonical": "أبو إسحاق الشيرازي",
    "author_full": "أبو اسحاق إبراهيم بن علي بن يوسف الشيرازي (ت 476 هـ)",
    "death_year_hijri": 476,
    "era": "ashab_al_wujuh",
    "text_type": "matn_mabsuth",
    "authority_rank": 1,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "دار الكتب العلمية"
  },
  "المهمات في شرح الروضة والرافعي": {
    "folder_or_file": "المهمات في شرح الروضة والرافعي",
    "raw_filename": "المهمات في شرح الروضة والرافعي",
    "is_directory": true,
    "volumes_count": 9,
    "full_title": "المهمات في شرح الروضة والرافعي",
    "canonical_short_title": "المهمات للإسنوي",
    "author_canonical": "الإسنوي",
    "author_full": "جمال الدين عبد الرحيم الإسنوي (ت 772 هـ)",
    "death_year_hijri": 772,
    "era": "mutawassithin",
    "text_type": "istidrak_wa_tahrir",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "(مركز التراث الثقافي المغربي - الدار البيضاء - المملكة المغربية)، (دار ابن حزم - بيروت - لبنان)"
  },
  "النجم الوهاج في شرح المنهاج": {
    "folder_or_file": "النجم الوهاج في شرح المنهاج",
    "raw_filename": "النجم الوهاج في شرح المنهاج",
    "is_directory": true,
    "volumes_count": 10,
    "full_title": "النجم الوهاج في شرح المنهاج",
    "canonical_short_title": "النجم الوهاج",
    "author_canonical": "الدميري",
    "author_full": "كمال الدين، محمد بن موسى بن عيسى بن علي الدَّمِيري أبو البقاء الشافعي (ت 808هـ)",
    "death_year_hijri": 808,
    "era": "mutawassithin",
    "text_type": "sharh",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "لجنة علمية",
    "publisher": "دار المنهاج (جدة)"
  },
  "الهداية إلى أوهام الكفاية.htm": {
    "folder_or_file": "الهداية إلى أوهام الكفاية.htm",
    "raw_filename": "الهداية إلى أوهام الكفاية.htm",
    "is_directory": false,
    "volumes_count": 1,
    "full_title": "الهداية إلى أوهام الكفاية",
    "canonical_short_title": "الهداية إلى أوهام الكفاية",
    "author_canonical": "ابن الملقن",
    "author_full": "عبد الرحيم بن الحسن بن علي الإسنوي الشافعيّ، أبو محمد، جمال الدين (ت 772هـ)",
    "death_year_hijri": 804,
    "era": "mutawassithin",
    "text_type": "istidrak",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "مجدي محمد سرور باسلوم",
    "publisher": "دار الكتب العلمي، مطبوع بخاتمة (كفاية النبيه) لابن الرفعة"
  },
  "الوسيط في المذهب": {
    "folder_or_file": "الوسيط في المذهب",
    "raw_filename": "الوسيط في المذهب",
    "is_directory": true,
    "volumes_count": 7,
    "full_title": "الوسيط في المذهب",
    "canonical_short_title": "الوسيط",
    "author_canonical": "أبو حامد الغزالي",
    "author_full": "أبو حامد محمد بن محمد الغزالي الطوسي (ت 505هـ)",
    "death_year_hijri": 505,
    "era": "mutawassithin",
    "text_type": "matn_mabsuth",
    "authority_rank": 1,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "أحمد محمود إبراهيم , محمد محمد تامر",
    "publisher": "دار السلام - القاهرة"
  },
  "أسنى المطالب في شرح روض الطالب - ط الميمنية": {
    "folder_or_file": "أسنى المطالب في شرح روض الطالب - ط الميمنية",
    "raw_filename": "أسنى المطالب في شرح روض الطالب - ط الميمنية",
    "is_directory": true,
    "volumes_count": 4,
    "full_title": "أسنى المطالب في شرح روض الطالب",
    "canonical_short_title": "أسنى المطالب",
    "author_canonical": "زكريا الأنصاري",
    "author_full": "أبو يحيى زكريا الأنصاري الشافعي [ت 926 هـ]",
    "death_year_hijri": 926,
    "era": "mutaakhkhirin",
    "text_type": "sharh_mutamad",
    "authority_rank": 1,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "المطبعة الميمنية، 1313 هـ"
  },
  "إتحاف الأريب بشرح الغاية والتقريب.htm": {
    "folder_or_file": "إتحاف الأريب بشرح الغاية والتقريب.htm",
    "raw_filename": "إتحاف الأريب بشرح الغاية والتقريب.htm",
    "is_directory": false,
    "volumes_count": 1,
    "full_title": "إتحاف الأريب بشرح الغاية والتقريب لأبي شجاع أحمد بن الحسن الأصبهاني الشافعي (ت 593 هـ)",
    "canonical_short_title": "إتحاف الأريب بشرح التقريب",
    "author_canonical": "صادق بن محمد سليم حبنكة الميداني",
    "author_full": "الشبراوي بن أبي المعاطي المصري الحسني",
    "death_year_hijri": 1440,
    "era": "muashir",
    "text_type": "sharh_muashir",
    "authority_rank": 3,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "دار الريادة للنشر والتوزيع، الدقهلية - مصر"
  },
  "إعانة الطالبين على حل ألفاظ فتح المعين": {
    "folder_or_file": "إعانة الطالبين على حل ألفاظ فتح المعين",
    "raw_filename": "إعانة الطالبين على حل ألفاظ فتح المعين",
    "is_directory": true,
    "volumes_count": 4,
    "full_title": "إعانة الطالبين على حل ألفاظ فتح المعين (هو حاشية على فتح المعين بشرح قرة العين بمهمات الدين)",
    "canonical_short_title": "إعانة الطالبين",
    "author_canonical": "السيد البكري شطا الدمياطي",
    "author_full": "أبو بكر (المشهور بالبكري) عثمان بن محمد شطا الدمياطي الشافعي (ت 1310هـ)",
    "death_year_hijri": 1310,
    "era": "mutaakhkhirin",
    "text_type": "hashiyah",
    "authority_rank": 1,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "دار الفكر للطباعة والنشر والتوريع"
  },
  "بحر المذهب للروياني": {
    "folder_or_file": "بحر المذهب للروياني",
    "raw_filename": "بحر المذهب للروياني",
    "is_directory": true,
    "volumes_count": 14,
    "full_title": "بحر المذهب (في فروع المذهب الشافعي)",
    "canonical_short_title": "بحر المذهب",
    "author_canonical": "الروياني",
    "author_full": "الروياني، أبو المحاسن عبد الواحد بن إسماعيل (ت 502 هـ)",
    "death_year_hijri": 502,
    "era": "ashab_al_wujuh",
    "text_type": "sharh_mabsuth",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "طارق فتحي السيد",
    "publisher": "دار الكتب العلمية"
  },
  "بداية المحتاج في شرح المنهاج": {
    "folder_or_file": "بداية المحتاج في شرح المنهاج",
    "raw_filename": "بداية المحتاج في شرح المنهاج",
    "is_directory": true,
    "volumes_count": 4,
    "full_title": "بداية المحتاج في شرح المنهاج",
    "canonical_short_title": "بداية المحتاج",
    "author_canonical": "بدر الدين الزركشي",
    "author_full": "بدر الدين أبو الفضل محمد بن أبي بكر الأسدي الشافعي ابن قاضي شهبة (798 - 874 هـ)",
    "death_year_hijri": 794,
    "era": "mutawassithin",
    "text_type": "sharh",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "دار المنهاج للنشر والتوزيع، جدة - المملكة العربية السعودية"
  },
  "تحرير الفتاوي على التنبيه والمنهاج والحاوي": {
    "folder_or_file": "تحرير الفتاوي على التنبيه والمنهاج والحاوي",
    "raw_filename": "تحرير الفتاوي على التنبيه والمنهاج والحاوي",
    "is_directory": true,
    "volumes_count": 3,
    "full_title": "تحرير الفتاوي على «التنبيه» و «المنهاج» و «الحاوي» المسمى (النكت على المختصرات الثلاث)",
    "canonical_short_title": "تحرير الفتاوي",
    "author_canonical": "ولي الدين العراقي",
    "author_full": "ولي الدين أبو زرعة أحمد بن عبد الرحيم بن الحسين بن عبد الرحمن العراقي الكُردي المِهْراني القاهري الشافعي (762 هـ - 826 هـ)",
    "death_year_hijri": 826,
    "era": "mutawassithin",
    "text_type": "tahrir_fatawa",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "عبد الرحمن فهمي محمد الزواوي",
    "publisher": "دار المنهاج للنشر والتوزيع، جدة - المملكة العربية السعودية"
  },
  "تحفة المحتاج في شرح المنهاج وحواشي الشرواني والعبادي": {
    "folder_or_file": "تحفة المحتاج في شرح المنهاج وحواشي الشرواني والعبادي",
    "raw_filename": "تحفة المحتاج في شرح المنهاج وحواشي الشرواني والعبادي",
    "is_directory": true,
    "volumes_count": 10,
    "full_title": "تحفة المحتاج في شرح المنهاج",
    "canonical_short_title": "تحفة المحتاج",
    "author_canonical": "ابن حجر الهيتمي",
    "author_full": "أحمد بن محمد بن علي بن حجر الهيتمي [ت 974 هـ]",
    "death_year_hijri": 974,
    "era": "mutaakhkhirin",
    "text_type": "sharh_mutamad",
    "authority_rank": 1,
    "has_hashiyah": true,
    "hashiyah_name": "حاشيتا الشرواني والعبادي",
    "hashiyah_authors": "عبد الحميد الشرواني (ت 1301 هـ) وابن قاسم العبادي (ت 994 هـ)",
    "muhaqqiq": "",
    "publisher": "المكتبة التجارية الكبرى بمصر لصاحبها مصطفى محمد"
  },
  "تكملة السبكي على المجموع شرح المهذب - ط التضامن": {
    "folder_or_file": "تكملة السبكي على المجموع شرح المهذب - ط التضامن",
    "raw_filename": "تكملة السبكي على المجموع شرح المهذب - ط التضامن",
    "is_directory": true,
    "volumes_count": 3,
    "full_title": "تكملة المجموع شرح المهذب",
    "canonical_short_title": "تكملة السبكي على المجموع",
    "author_canonical": "تقي الدين السبكي",
    "author_full": "تقي الدين علي بن عبد الكافي السبكي (ت 756 هـ)",
    "death_year_hijri": 756,
    "era": "mutawassithin",
    "text_type": "takmilah",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "مطبعة التضامن الأخوي - القاهرة"
  },
  "تكملة المطيعي على المجموع شرح المهذب - ط السلفية": {
    "folder_or_file": "تكملة المطيعي على المجموع شرح المهذب - ط السلفية",
    "raw_filename": "تكملة المطيعي على المجموع شرح المهذب - ط السلفية",
    "is_directory": true,
    "volumes_count": 8,
    "full_title": "تكملة المجموع شرح المهذب",
    "canonical_short_title": "تكملة المطيعي على المجموع",
    "author_canonical": "محمد نجيب المطيعي",
    "author_full": "محمد نجيب المطيعي [ت 1407 هـ]",
    "death_year_hijri": 1407,
    "era": "muashir",
    "text_type": "takmilah",
    "authority_rank": 3,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "المكتبة السلفية - المدينة المنورة (وهي إعادة صف للتكملة الأولى للمطيعي)"
  },
  "جواهر العقود ومعين القضاة والموقعين والشهود": {
    "folder_or_file": "جواهر العقود ومعين القضاة والموقعين والشهود",
    "raw_filename": "جواهر العقود ومعين القضاة والموقعين والشهود",
    "is_directory": true,
    "volumes_count": 2,
    "full_title": "جواهر العقود ومعين القضاة والموقعين والشهود",
    "canonical_short_title": "جواهر العقود",
    "author_canonical": "شمس الدين الأسيوطي",
    "author_full": "شمس الدين محمد بن أحمد المنهاجي الأسيوطي [ت 880 هـ]",
    "death_year_hijri": 880,
    "era": "mutawassithin",
    "text_type": "watsaiq_wa_qadha",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "دار الكتب العلمية بيروت - لبنان"
  },
  "حاشية البجيرمي على الخطيب = تحفة الحبيب على شرح الخطيب": {
    "folder_or_file": "حاشية البجيرمي على الخطيب = تحفة الحبيب على شرح الخطيب",
    "raw_filename": "حاشية البجيرمي على الخطيب = تحفة الحبيب على شرح الخطيب",
    "is_directory": true,
    "volumes_count": 4,
    "full_title": "تحفة الحبيب على شرح الخطيب = حاشية البجيرمي على الخطيب",
    "canonical_short_title": "حاشية البجيرمي على الخطيب",
    "author_canonical": "البجيرمي",
    "author_full": "سليمان بن محمد بن عمر البُجَيْرَمِيّ المصري الشافعي (ت 1221هـ)",
    "death_year_hijri": 1221,
    "era": "mutaakhkhirin",
    "text_type": "hashiyah",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "دار الفكر"
  },
  "حاشية البجيرمي على شرح المنهج = التجريد لنفع العبيد": {
    "folder_or_file": "حاشية البجيرمي على شرح المنهج = التجريد لنفع العبيد",
    "raw_filename": "حاشية البجيرمي على شرح المنهج = التجريد لنفع العبيد",
    "is_directory": true,
    "volumes_count": 4,
    "full_title": "التجريد لنفع العبيد = حاشية البجيرمي على شرح المنهج (منهج الطلاب اختصره زكريا الأنصاري من منهاج الطالبين للنووي ثم شرحه في شرح منهج الطلاب)",
    "canonical_short_title": "حاشية البجيرمي على المنهج",
    "author_canonical": "البجيرمي",
    "author_full": "سليمان بن محمد بن عمر البُجَيْرَمِيّ المصري الشافعي (ت 1221هـ)",
    "death_year_hijri": 1221,
    "era": "mutaakhkhirin",
    "text_type": "hashiyah",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "مطبعة الحلبي"
  },
  "حاشية الجمل على شرح المنهج = فتوحات الوهاب بتوضيح شرح منهج الطلاب": {
    "folder_or_file": "حاشية الجمل على شرح المنهج = فتوحات الوهاب بتوضيح شرح منهج الطلاب",
    "raw_filename": "حاشية الجمل على شرح المنهج = فتوحات الوهاب بتوضيح شرح منهج الطلاب",
    "is_directory": true,
    "volumes_count": 5,
    "full_title": "فتوحات الوهاب بتوضيح شرح منهج الطلاب المعروف بحاشية الجمل (منهج الطلاب اختصره زكريا الأنصاري من منهاج الطالبين للنووي ثم شرحه في شرح منهج الطلاب)",
    "canonical_short_title": "حاشية الجمل",
    "author_canonical": "سليمان الجمل",
    "author_full": "سليمان بن عمر بن منصور العجيلي الأزهري، المعروف بالجمل (ت 1204هـ)",
    "death_year_hijri": 1204,
    "era": "mutaakhkhirin",
    "text_type": "hashiyah",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "دار الفكر"
  },
  "حاشيتا قليوبي وعميرة": {
    "folder_or_file": "حاشيتا قليوبي وعميرة",
    "raw_filename": "حاشيتا قليوبي وعميرة",
    "is_directory": true,
    "volumes_count": 4,
    "full_title": "حاشيتا قليوبي وعميرة",
    "canonical_short_title": "حاشيتا قليوبي وعميرة",
    "author_canonical": "القليوبي وعميرة",
    "author_full": "أحمد سلامة القليوبي وأحمد البرلسي عميرة",
    "death_year_hijri": 1069,
    "era": "mutaakhkhirin",
    "text_type": "hashiyah",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "دار الفكر - بيروت"
  },
  "حلية العلماء في معرفة مذاهب الفقهاء - أجزاء منه": {
    "folder_or_file": "حلية العلماء في معرفة مذاهب الفقهاء - أجزاء منه",
    "raw_filename": "حلية العلماء في معرفة مذاهب الفقهاء - أجزاء منه",
    "is_directory": true,
    "volumes_count": 3,
    "full_title": "حلية العلماء في معرفة مذاهب الفقهاء",
    "canonical_short_title": "حلية العلماء للشاشي",
    "author_canonical": "الشاشي القفال",
    "author_full": "محمد بن أحمد بن الحسين بن عمر، أبو بكر الشاشي القفال الفارقيّ، الملقب فخر الإسلام، المستظهري الشافعي (ت 507 هـ)",
    "death_year_hijri": 507,
    "era": "mutawassithin",
    "text_type": "fiqh_muqaran",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "د. ياسين أحمد إبراهيم درادكة",
    "publisher": "مؤسسة الرسالة / دار الأرقم - بيروت / عمان"
  },
  "حلية العلماء في معرفة مذاهب الفقهاء - ط الرسالة الحديثة": {
    "folder_or_file": "حلية العلماء في معرفة مذاهب الفقهاء - ط الرسالة الحديثة",
    "raw_filename": "حلية العلماء في معرفة مذاهب الفقهاء - ط الرسالة الحديثة",
    "is_directory": true,
    "volumes_count": 8,
    "full_title": "حلية العلماء في معرفة مذاهب الفقهاء",
    "canonical_short_title": "حلية العلماء للشاشي",
    "author_canonical": "الشاشي القفال",
    "author_full": "سيف الدين أبو بكر محمد بن أحمد الشاشي القفال",
    "death_year_hijri": 507,
    "era": "mutawassithin",
    "text_type": "fiqh_muqaran",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "مكتبة الرسالة الحديثة، المملكة الأردنية الهاشمية، عمان"
  },
  "خبايا الزوايا.htm": {
    "folder_or_file": "خبايا الزوايا.htm",
    "raw_filename": "خبايا الزوايا.htm",
    "is_directory": false,
    "volumes_count": 1,
    "full_title": "خبايا الزوايا",
    "canonical_short_title": "خبايا الزوايا",
    "author_canonical": "بدر الدين الزركشي",
    "author_full": "أبو عبد الله بدر الدين محمد بن عبد الله بن بهادر الزركشي الشافعي (ت 794هـ)",
    "death_year_hijri": 794,
    "era": "mutawassithin",
    "text_type": "furuq_wa_dhowabit",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "عبد القادر عبد الله العاني",
    "publisher": "وزارة الأوقاف والشئون الإسلامية - الكويت"
  },
  "دقائق المنهاج.htm": {
    "folder_or_file": "دقائق المنهاج.htm",
    "raw_filename": "دقائق المنهاج.htm",
    "is_directory": false,
    "volumes_count": 1,
    "full_title": "دقائق المنهاج",
    "canonical_short_title": "دقائق المنهاج",
    "author_canonical": "النووي",
    "author_full": "أبو زكريا محيي الدين يحيى بن شرف النووي (ت 676هـ)",
    "death_year_hijri": 676,
    "era": "mutawassithin",
    "text_type": "tahrir_alfaazh",
    "authority_rank": 1,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "إياد أحمد الغوج",
    "publisher": "دار ابن حزم - بيروت"
  },
  "روضة الطالبين وعمدة المفتين": {
    "folder_or_file": "روضة الطالبين وعمدة المفتين",
    "raw_filename": "روضة الطالبين وعمدة المفتين",
    "is_directory": true,
    "volumes_count": 12,
    "full_title": "روضة الطالبين وعمدة المفتين",
    "canonical_short_title": "روضة الطالبين",
    "author_canonical": "النووي",
    "author_full": "أبو زكريا محيي الدين يحيى بن شرف النووي (ت 676 هـ)",
    "death_year_hijri": 676,
    "era": "mutawassithin",
    "text_type": "tahqiq_mukhtashar",
    "authority_rank": 1,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "المكتب الإسلامي، بيروت- دمشق- عمان"
  },
  "شرح الرحبية للحازمي": {
    "folder_or_file": "شرح الرحبية للحازمي",
    "raw_filename": "شرح الرحبية للحازمي",
    "is_directory": true,
    "volumes_count": 23,
    "full_title": "شرح الرحبية",
    "canonical_short_title": "شرح الرحبية للحازمي",
    "author_canonical": "أحمد بن عمر الحازمي",
    "author_full": "أبو عبد الله، أحمد بن عمر بن مساعد الحازمي",
    "death_year_hijri": 1445,
    "era": "muashir",
    "text_type": "sharh_faraidh",
    "authority_rank": 3,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": ""
  },
  "شرح المقدمة الحضرمية المسمى بشرى الكريم بشرح مسائل التعليم.htm": {
    "folder_or_file": "شرح المقدمة الحضرمية المسمى بشرى الكريم بشرح مسائل التعليم.htm",
    "raw_filename": "شرح المقدمة الحضرمية المسمى بشرى الكريم بشرح مسائل التعليم.htm",
    "is_directory": false,
    "volumes_count": 1,
    "full_title": "شَرح المُقَدّمَة الحضرمية المُسمّى بُشرى الكريم بشَرح مَسَائل التَّعليم",
    "canonical_short_title": "بشرى الكريم",
    "author_canonical": "سعيد بن محمد باعشن",
    "author_full": "سَعيد بن محمد بَاعَليّ بَاعِشن الدَّوْعَنِيُّ الرباطي الحضرمي الشافعي (ت 1270هـ)",
    "death_year_hijri": 1270,
    "era": "mutaakhkhirin",
    "text_type": "sharh",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "دار المنهاج للنشر والتوزيع، جدة"
  },
  "شرح كتاب الحج من نهاية التدريب في نظم غاية التقريب للعمريطي.htm": {
    "folder_or_file": "شرح كتاب الحج من نهاية التدريب في نظم غاية التقريب للعمريطي.htm",
    "raw_filename": "شرح كتاب الحج من نهاية التدريب في نظم غاية التقريب للعمريطي.htm",
    "is_directory": false,
    "volumes_count": 1,
    "full_title": "الحج من نظم الإمام العمريطي الشافعي في «نهاية التدريب في نظم غاية التدريب»",
    "canonical_short_title": "شرح كتاب الحج للعمريطي",
    "author_canonical": "محمد محيي الدين حمادة الغنيمي",
    "author_full": "محمد محيي الدين حمادة الغنيمي",
    "death_year_hijri": 1420,
    "era": "muashir",
    "text_type": "sharh_manzhumah",
    "authority_rank": 3,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "دار اقرأ للطباعة والنشر والتوزيع، دمشق- سوريا"
  },
  "شرح متن أبي شجاع - محمد حسن عبد الغفار": {
    "folder_or_file": "شرح متن أبي شجاع - محمد حسن عبد الغفار",
    "raw_filename": "شرح متن أبي شجاع - محمد حسن عبد الغفار",
    "is_directory": true,
    "volumes_count": 21,
    "full_title": "شرح متن أبي شجاع",
    "canonical_short_title": "شرح أبي شجاع لعبد الغفار",
    "author_canonical": "محمد حسن عبد الغفار",
    "author_full": "محمد حسن عبد الغفار",
    "death_year_hijri": 1445,
    "era": "muashir",
    "text_type": "muhadharat",
    "authority_rank": 3,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": ""
  },
  "شرح مشكل الوسيط": {
    "folder_or_file": "شرح مشكل الوسيط",
    "raw_filename": "شرح مشكل الوسيط",
    "is_directory": true,
    "volumes_count": 5,
    "full_title": "شَرحُ مشكِل الوَسِيطِ",
    "canonical_short_title": "شرح مشكل الوسيط",
    "author_canonical": "ابن الصلاح",
    "author_full": "عثمان بن عبد الرحمن، أبو عمرو، تقي الدين المعروف بابن الصلاح (ت 643هـ)",
    "death_year_hijri": 643,
    "era": "mutawassithin",
    "text_type": "musykilat",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "د. عبد المنعم خليفة أحمد بلال",
    "publisher": "دار كنوز إشبيليا للنشر والتوزيع، المملكة العربية السعودية"
  },
  "عجالة المحتاج إلى توجيه المنهاج": {
    "folder_or_file": "عجالة المحتاج إلى توجيه المنهاج",
    "raw_filename": "عجالة المحتاج إلى توجيه المنهاج",
    "is_directory": true,
    "volumes_count": 4,
    "full_title": "عجالة المحتاج إلى توجيه المنهاج",
    "canonical_short_title": "عجالة المحتاج",
    "author_canonical": "ابن الملقن",
    "author_full": "سراج الدين أبو حفص عمر بن علي بن أحمد المعروف بـ «ابن النحوي» والمشهور بـ «ابن الملقن» (ت 804 هـ)",
    "death_year_hijri": 804,
    "era": "mutawassithin",
    "text_type": "sharh_tawjih",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "دار الكتاب، إربد - الأردن"
  },
  "عمدة السالك وعدة الناسك.htm": {
    "folder_or_file": "عمدة السالك وعدة الناسك.htm",
    "raw_filename": "عمدة السالك وعدة الناسك.htm",
    "is_directory": false,
    "volumes_count": 1,
    "full_title": "عمدة السالِك وَعدة النَّاسِك",
    "canonical_short_title": "عمدة السالك",
    "author_canonical": "ابن النقيب المصري",
    "author_full": "أحمد بن لؤلؤ بن عبد الله الرومي، أبو العباس، شهاب الدين ابن النَّقِيب الشافعي (ت 769هـ)",
    "death_year_hijri": 769,
    "era": "mutawassithin",
    "text_type": "matn",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "الشؤون الدينية، قطر"
  },
  "غاية البيان شرح زبد ابن رسلان.htm": {
    "folder_or_file": "غاية البيان شرح زبد ابن رسلان.htm",
    "raw_filename": "غاية البيان شرح زبد ابن رسلان.htm",
    "is_directory": false,
    "volumes_count": 1,
    "full_title": "غاية البيان شرح زبد ابن رسلان",
    "canonical_short_title": "غاية البيان شرح الزبد",
    "author_canonical": "شمس الدين الرملي",
    "author_full": "شمس الدين محمد بن أبي العباس أحمد بن حمزة شهاب الدين الرملي (ت 1004هـ)",
    "death_year_hijri": 1004,
    "era": "mutaakhkhirin",
    "text_type": "sharh",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "دار المعرفة - بيروت"
  },
  "فتاوى ابن الصلاح": {
    "folder_or_file": "فتاوى ابن الصلاح",
    "raw_filename": "فتاوى ابن الصلاح",
    "is_directory": true,
    "volumes_count": 2,
    "full_title": "فتاوى ابن الصلاح",
    "canonical_short_title": "فتاوى ابن الصلاح",
    "author_canonical": "ابن الصلاح",
    "author_full": "عثمان بن عبد الرحمن، أبو عمرو، تقي الدين المعروف بابن الصلاح (ت 643هـ)",
    "death_year_hijri": 643,
    "era": "mutawassithin",
    "text_type": "fatawa",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "د. موفق عبد الله عبد القادر",
    "publisher": "مكتبة العلوم والحكم , عالم الكتب - بيروت"
  },
  "فتاوى الرملي": {
    "folder_or_file": "فتاوى الرملي",
    "raw_filename": "فتاوى الرملي",
    "is_directory": true,
    "volumes_count": 4,
    "full_title": "فتاوى الرملي",
    "canonical_short_title": "فتاوى الرملي",
    "author_canonical": "شهاب الدين الرملي",
    "author_full": "شهاب الدين أحمد بن حمزة الأنصاري الرملي الشافعي (ت 957هـ)",
    "death_year_hijri": 957,
    "era": "mutaakhkhirin",
    "text_type": "fatawa",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "المكتبة الإسلامية"
  },
  "فتاوى السبكي": {
    "folder_or_file": "فتاوى السبكي",
    "raw_filename": "فتاوى السبكي",
    "is_directory": true,
    "volumes_count": 2,
    "full_title": "فتاوى السبكي",
    "canonical_short_title": "فتاوى السبكي",
    "author_canonical": "تقي الدين السبكي",
    "author_full": "أبو الحسن تقي الدين علي بن عبد الكافي السبكي (ت 756 هـ)",
    "death_year_hijri": 756,
    "era": "mutawassithin",
    "text_type": "fatawa",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "دار المعرفة بيروت (اعتمادًا على طبعة مكتبة القدسي بالقاهرة، مع اختلاف في ترقيم الصفحات!)"
  },
  "فتاوى النووي.htm": {
    "folder_or_file": "فتاوى النووي.htm",
    "raw_filename": "فتاوى النووي.htm",
    "is_directory": false,
    "volumes_count": 1,
    "full_title": "فتاوى النووي",
    "canonical_short_title": "فتاوى النووي",
    "author_canonical": "النووي",
    "author_full": "أبو زكريا محيي الدين يحيى بن شرف النووي (ت 676هـ)",
    "death_year_hijri": 676,
    "era": "mutawassithin",
    "text_type": "fatawa",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "دَارُ البشائرِ الإسلاميَّة للطبَاعَة وَالنشرَ والتوزيع، بَيروت - لبنان"
  },
  "فتاوي الخليلي على المذهب الشافعي": {
    "folder_or_file": "فتاوي الخليلي على المذهب الشافعي",
    "raw_filename": "فتاوي الخليلي على المذهب الشافعي",
    "is_directory": true,
    "volumes_count": 2,
    "full_title": "فتاوي الخليلي على المذهب الشافعي",
    "canonical_short_title": "فتاوى الخليلي",
    "author_canonical": "محمد بن شرف الدين الخليلي",
    "author_full": "محمد بن محمد، ابن شَرَف الدين الخليلي الشافعيّ القادري (ت 1147هـ)",
    "death_year_hijri": 1147,
    "era": "mutaakhkhirin",
    "text_type": "fatawa",
    "authority_rank": 3,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "طبعة مصرية قديمة"
  },
  "فتح الرحمن بشرح زبد ابن رسلان.htm": {
    "folder_or_file": "فتح الرحمن بشرح زبد ابن رسلان.htm",
    "raw_filename": "فتح الرحمن بشرح زبد ابن رسلان.htm",
    "is_directory": false,
    "volumes_count": 1,
    "full_title": "فتح الرحمن بشرح زبد ابن رسلان",
    "canonical_short_title": "فتح الرحمن شرح الزبد",
    "author_canonical": "شهاب الدين الرملي",
    "author_full": "شهاب الدين أبو العباس أحمد بن أحمد بن حمزة الرملي (ت 957 هـ)",
    "death_year_hijri": 957,
    "era": "mutaakhkhirin",
    "text_type": "sharh",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "دار المنهاج، بيروت - لبنان"
  },
  "فتح العزيز بشرح الوجيز = الشرح الكبير للرافعي": {
    "folder_or_file": "فتح العزيز بشرح الوجيز = الشرح الكبير للرافعي",
    "raw_filename": "فتح العزيز بشرح الوجيز = الشرح الكبير للرافعي",
    "is_directory": true,
    "volumes_count": 12,
    "full_title": "فتح العزيز بشرح الوجيز = الشرح الكبير [وهو شرح لكتاب الوجيز في الفقه الشافعي لأبي حامد الغزالي (ت 505 هـ) ]",
    "canonical_short_title": "الشرح الكبير (فتح العزيز)",
    "author_canonical": "الرافعي",
    "author_full": "عبد الكريم بن محمد الرافعي القزويني (ت 623هـ)",
    "death_year_hijri": 623,
    "era": "mutawassithin",
    "text_type": "sharh",
    "authority_rank": 1,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "دار الفكر"
  },
  "فتح القريب المجيب في شرح ألفاظ التقريب = القول المختار في شرح غاية الاختصار.htm": {
    "folder_or_file": "فتح القريب المجيب في شرح ألفاظ التقريب = القول المختار في شرح غاية الاختصار.htm",
    "raw_filename": "فتح القريب المجيب في شرح ألفاظ التقريب = القول المختار في شرح غاية الاختصار.htm",
    "is_directory": false,
    "volumes_count": 1,
    "full_title": "فتح القريب المجيب في شرح ألفاظ التقريب = القول المختار في شرح غاية الاختصار (ويعرف بشرح ابن قاسم على متن أبي شجاع)",
    "canonical_short_title": "فتح القريب المجيب",
    "author_canonical": "ابن قاسم الغزي",
    "author_full": "محمد بن قاسم بن محمد بن محمد، أبو عبد الله، شمس الدين الغزي، ويعرف بابن قاسم وبابن الغرابيلي (ت 918 هـ)",
    "death_year_hijri": 918,
    "era": "mutaakhkhirin",
    "text_type": "sharh",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "الجفان والجابي للطباعة والنشر، دار ابن حزم للطباعة والنشر والتوزيع، بيروت - لبنان"
  },
  "فتح المعين بشرح قرة العين بمهمات الدين.htm": {
    "folder_or_file": "فتح المعين بشرح قرة العين بمهمات الدين.htm",
    "raw_filename": "فتح المعين بشرح قرة العين بمهمات الدين.htm",
    "is_directory": false,
    "volumes_count": 1,
    "full_title": "فتح المعين بشرح قرة العين بمهمات الدين (هو شرح للمؤلف على كتابه هو المسمى قرة العين بمهمات الدين)",
    "canonical_short_title": "فتح المعين",
    "author_canonical": "زين الدين المليباري",
    "author_full": "زين الدين أحمد بن عبد العزيز بن زين الدين بن علي بن أحمد المعبري المليباري الهندي (ت 987هـ)",
    "death_year_hijri": 987,
    "era": "mutaakhkhirin",
    "text_type": "sharh_mutamad",
    "authority_rank": 1,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "دار بن حزم"
  },
  "فتح الوهاب بشرح منهج الطلاب": {
    "folder_or_file": "فتح الوهاب بشرح منهج الطلاب",
    "raw_filename": "فتح الوهاب بشرح منهج الطلاب",
    "is_directory": true,
    "volumes_count": 2,
    "full_title": "فتح الوهاب بشرح منهج الطلاب (هو شرح للمؤلف على كتابه هو منهج الطلاب الذي اختصره المؤلف من منهاج الطالبين للنووي)",
    "canonical_short_title": "فتح الوهاب",
    "author_canonical": "زكريا الأنصاري",
    "author_full": "زكريا بن محمد بن أحمد بن زكريا الأنصاري، زين الدين أبو يحيى السنيكي (ت 926هـ)",
    "death_year_hijri": 926,
    "era": "mutaakhkhirin",
    "text_type": "sharh_mutamad",
    "authority_rank": 1,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "دار الفكر للطباعة والنشر"
  },
  "فقه العبادات على المذهب الشافعي": {
    "folder_or_file": "فقه العبادات على المذهب الشافعي",
    "raw_filename": "فقه العبادات على المذهب الشافعي",
    "is_directory": true,
    "volumes_count": 2,
    "full_title": "فقه العبادات على المذهب الشافعي",
    "canonical_short_title": "فقه العبادات الشافعي",
    "author_canonical": "درية العيطة",
    "author_full": "الحاجة درية العيطة",
    "death_year_hijri": 1435,
    "era": "muashir",
    "text_type": "muashir",
    "authority_rank": 3,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": ""
  },
  "قضاء الأرب في أسئلة حلب.htm": {
    "folder_or_file": "قضاء الأرب في أسئلة حلب.htm",
    "raw_filename": "قضاء الأرب في أسئلة حلب.htm",
    "is_directory": false,
    "volumes_count": 1,
    "full_title": "قضاء الأرب في أسئلة حلب",
    "canonical_short_title": "قضاء الأرب",
    "author_canonical": "تقي الدين السبكي",
    "author_full": "أبو الحسن تقي الدين علي بن عبد الكافي السبكي (ت 756 هـ)",
    "death_year_hijri": 756,
    "era": "mutawassithin",
    "text_type": "ajwibah",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "محمد عالم عبد المجيد الأفغاني (ماجستير)",
    "publisher": "المكتبة التجارية مكة المكرمة - مصطفى أحمد الباز"
  },
  "كتاب الأمر والنهي على معنى الشافعي.htm": {
    "folder_or_file": "كتاب الأمر والنهي على معنى الشافعي.htm",
    "raw_filename": "كتاب الأمر والنهي على معنى الشافعي.htm",
    "is_directory": false,
    "volumes_count": 1,
    "full_title": "الأمر والنهي على معنى الشافعي",
    "canonical_short_title": "الأمر والنهي",
    "author_canonical": "المزني",
    "author_full": "أبو إبراهيم إسماعيل بن يحيى المزني (ت 264 هـ)",
    "death_year_hijri": 264,
    "era": "mutaqaddimin",
    "text_type": "asl",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "دار مدارج للنشر - الرياض"
  },
  "كفاية الأخيار في حل غاية الاختصار.htm": {
    "folder_or_file": "كفاية الأخيار في حل غاية الاختصار.htm",
    "raw_filename": "كفاية الأخيار في حل غاية الاختصار.htm",
    "is_directory": false,
    "volumes_count": 1,
    "full_title": "كفاية الأخيار في حل غاية الإختصار",
    "canonical_short_title": "كفاية الأخيار",
    "author_canonical": "تقي الدين الحصني",
    "author_full": "أبو بكر بن محمد بن عبد المؤمن بن حريز بن معلى الحسيني الحصني، تقي الدين الشافعي (ت 829هـ)",
    "death_year_hijri": 829,
    "era": "mutawassithin",
    "text_type": "sharh",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "علي عبد الحميد بلطجي ومحمد وهبي سليمان",
    "publisher": "دار الخير - دمشق"
  },
  "كفاية النبيه في شرح التنبيه": {
    "folder_or_file": "كفاية النبيه في شرح التنبيه",
    "raw_filename": "كفاية النبيه في شرح التنبيه",
    "is_directory": true,
    "volumes_count": 19,
    "full_title": "كفاية النبيه في شرح التنبيه",
    "canonical_short_title": "كفاية النبيه",
    "author_canonical": "ابن الرفعة",
    "author_full": "أحمد بن محمد بن علي الأنصاري، أبو العباس، نجم الدين، المعروف بابن الرفعة (ت 710هـ)",
    "death_year_hijri": 710,
    "era": "mutawassithin",
    "text_type": "sharh_mabsuth",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "مجدي محمد سرور باسلوم",
    "publisher": "دار الكتب العلمية"
  },
  "متن أبي شجاع المسمى الغاية والتقريب.htm": {
    "folder_or_file": "متن أبي شجاع المسمى الغاية والتقريب.htm",
    "raw_filename": "متن أبي شجاع المسمى الغاية والتقريب.htm",
    "is_directory": false,
    "volumes_count": 1,
    "full_title": "متن أبي شجاع المسمى الغاية والتقريب",
    "canonical_short_title": "متن أبي شجاع",
    "author_canonical": "أبو شجاع الأصفهاني",
    "author_full": "أحمد بن الحسين بن أحمد، أبو شجاع، شهاب الدين أبو الطيب الأصفهاني (ت 593هـ)",
    "death_year_hijri": 593,
    "era": "mutawassithin",
    "text_type": "matn",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "عالم الكتب"
  },
  "مختصر الخلافيات للبيهقي": {
    "folder_or_file": "مختصر الخلافيات للبيهقي",
    "raw_filename": "مختصر الخلافيات للبيهقي",
    "is_directory": true,
    "volumes_count": 5,
    "full_title": "مختصر خلافيات البيهقي",
    "canonical_short_title": "مختصر الخلافيات",
    "author_canonical": "ابن فرح الإشبيلي",
    "author_full": "أحمد بن فرح، اللَّخمى الإشبيلى الشافعي (ت 699 هـ)",
    "death_year_hijri": 699,
    "era": "mutawassithin",
    "text_type": "mukhtashar",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "مكتبة الرشد - السعودية / الرياض"
  },
  "مختصر المزني - ت الداغستاني": {
    "folder_or_file": "مختصر المزني - ت الداغستاني",
    "raw_filename": "مختصر المزني - ت الداغستاني",
    "is_directory": true,
    "volumes_count": 3,
    "full_title": "المختصر من علم الشافعي ومن معنى قوله",
    "canonical_short_title": "مختصر المزني",
    "author_canonical": "المزني",
    "author_full": "أبو إبراهيم إسماعيل بن يحيى المزني (ت 264 هـ)",
    "death_year_hijri": 264,
    "era": "mutaqaddimin",
    "text_type": "mukhtashar",
    "authority_rank": 1,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "دار مدارج للنشر - الرياض"
  },
  "مختصر المزني - ط الفكر بآخر كتاب الأم.htm": {
    "folder_or_file": "مختصر المزني - ط الفكر بآخر كتاب الأم.htm",
    "raw_filename": "مختصر المزني - ط الفكر بآخر كتاب الأم.htm",
    "is_directory": false,
    "volumes_count": 1,
    "full_title": "مختصر المزني",
    "canonical_short_title": "مختصر المزني",
    "author_canonical": "المزني",
    "author_full": "أبو إبراهيم، إسماعيل بن يحيى المزني (ت 264 هـ)",
    "death_year_hijri": 264,
    "era": "mutaqaddimin",
    "text_type": "mukhtashar",
    "authority_rank": 1,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "دار الفكر - بيروت"
  },
  "مختصر تحفة المحتاج بشرح المنهاج": {
    "folder_or_file": "مختصر تحفة المحتاج بشرح المنهاج",
    "raw_filename": "مختصر تحفة المحتاج بشرح المنهاج",
    "is_directory": true,
    "volumes_count": 4,
    "full_title": "مختصر تحفة المحتاج بشرح المنهاج",
    "canonical_short_title": "مختصر تحفة المحتاج",
    "author_canonical": "مصطفى بن سميط",
    "author_full": "مصطفى بن سميط",
    "death_year_hijri": 1430,
    "era": "muashir",
    "text_type": "mukhtashar_muashir",
    "authority_rank": 3,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "مركز النور للدراسات والأبحاث"
  },
  "مغني المحتاج إلى معرفة معاني ألفاظ المنهاج": {
    "folder_or_file": "مغني المحتاج إلى معرفة معاني ألفاظ المنهاج",
    "raw_filename": "مغني المحتاج إلى معرفة معاني ألفاظ المنهاج",
    "is_directory": true,
    "volumes_count": 6,
    "full_title": "مغني المحتاج إلى معرفة معاني ألفاظ المنهاج",
    "canonical_short_title": "مغني المحتاج",
    "author_canonical": "الخطيب الشربيني",
    "author_full": "شمس الدين، محمد بن محمد، الخطيب الشربيني [ت 977 هـ]",
    "death_year_hijri": 977,
    "era": "mutaakhkhirin",
    "text_type": "sharh_mutamad",
    "authority_rank": 1,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "دار الكتب العلمية"
  },
  "منظومة البهجة الوردية - ضمن مجموع «الرفعة».htm": {
    "folder_or_file": "منظومة البهجة الوردية - ضمن مجموع «الرفعة».htm",
    "raw_filename": "منظومة البهجة الوردية - ضمن مجموع «الرفعة».htm",
    "is_directory": false,
    "volumes_count": 1,
    "full_title": "منظومة البهجة الوردية (ضمن مجموع الرفعة في بعض متون فقه المذاهب الأربعة)",
    "canonical_short_title": "البهجة الوردية",
    "author_canonical": "ابن الوردي",
    "author_full": "ابن الوردي",
    "death_year_hijri": 749,
    "era": "mutawassithin",
    "text_type": "manzhumah",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "دار عمار للنشر والتوزيع"
  },
  "منهاج الطالبين وعمدة المفتين في الفقه.htm": {
    "folder_or_file": "منهاج الطالبين وعمدة المفتين في الفقه.htm",
    "raw_filename": "منهاج الطالبين وعمدة المفتين في الفقه.htm",
    "is_directory": false,
    "volumes_count": 1,
    "full_title": "منهاج الطالبين وعمدة المفتين في الفقه",
    "canonical_short_title": "منهاج الطالبين",
    "author_canonical": "النووي",
    "author_full": "أبو زكريا محيي الدين يحيى بن شرف النووي (ت 676هـ)",
    "death_year_hijri": 676,
    "era": "mutawassithin",
    "text_type": "matn_umdah",
    "authority_rank": 1,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "عوض قاسم أحمد عوض",
    "publisher": "دار الفكر"
  },
  "منهج الطلاب في فقه الإمام الشافعي رضي الله عنه.htm": {
    "folder_or_file": "منهج الطلاب في فقه الإمام الشافعي رضي الله عنه.htm",
    "raw_filename": "منهج الطلاب في فقه الإمام الشافعي رضي الله عنه.htm",
    "is_directory": false,
    "volumes_count": 1,
    "full_title": "منهج الطلاب في فقه الإمام الشافعي رضي الله عنه",
    "canonical_short_title": "منهج الطلاب",
    "author_canonical": "زكريا الأنصاري",
    "author_full": "زكريا بن محمد بن أحمد بن زكريا الأنصاري، زين الدين أبو يحيى السنيكي (ت 926هـ)",
    "death_year_hijri": 926,
    "era": "mutaakhkhirin",
    "text_type": "matn",
    "authority_rank": 1,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "صلاح بن محمد بن عويضة",
    "publisher": "دار الكتب العلمية -بيروت"
  },
  "نهاية الإقدام في مآخذ الأحكام.htm": {
    "folder_or_file": "نهاية الإقدام في مآخذ الأحكام.htm",
    "raw_filename": "نهاية الإقدام في مآخذ الأحكام.htm",
    "is_directory": false,
    "volumes_count": 1,
    "full_title": "نهاية الإقدام في مآخذ الأحكام",
    "canonical_short_title": "نهاية الإقدام في مآخذ الأحكام",
    "author_canonical": "شهاب الدين الزنجاني",
    "author_full": "شهاب الدين الزنجاني أبو المناقب محمود بن أحمد الشافعي (ت 656 هـ)",
    "death_year_hijri": 656,
    "era": "mutawassithin",
    "text_type": "maakhidz_al_ahkam",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "حمود بن عبد الله المسعر",
    "publisher": "دار أسفار - الكويت"
  },
  "نهاية التدريب نظم غاية التقريب - ت جراد.htm": {
    "folder_or_file": "نهاية التدريب نظم غاية التقريب - ت جراد.htm",
    "raw_filename": "نهاية التدريب نظم غاية التقريب - ت جراد.htm",
    "is_directory": false,
    "volumes_count": 1,
    "full_title": "نهاية التدريب نظم غاية التقريب",
    "canonical_short_title": "نهاية التدريب نظم التقريب",
    "author_canonical": "العمريطي",
    "author_full": "أبو الخير يحيى شرف الدين بن موسى (نور الدين) العمريطي (ت بعد 989 هـ)",
    "death_year_hijri": 989,
    "era": "mutaakhkhirin",
    "text_type": "manzhumah",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "دار الكتب العلمية - بيروت"
  },
  "نهاية الزين.htm": {
    "folder_or_file": "نهاية الزين.htm",
    "raw_filename": "نهاية الزين.htm",
    "is_directory": false,
    "volumes_count": 1,
    "full_title": "نهاية الزين في إرشاد المبتدئين",
    "canonical_short_title": "نهاية الزين",
    "author_canonical": "النووي البنتني",
    "author_full": "محمد بن عمر نووي الجاوي البنتني إقليما، التناري بلدا (ت 1316هـ)",
    "death_year_hijri": 1316,
    "era": "mutaakhkhirin",
    "text_type": "sharh",
    "authority_rank": 2,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "دار الفكر - بيروت"
  },
  "نهاية المحتاج إلى شرح المنهاج": {
    "folder_or_file": "نهاية المحتاج إلى شرح المنهاج",
    "raw_filename": "نهاية المحتاج إلى شرح المنهاج",
    "is_directory": true,
    "volumes_count": 8,
    "full_title": "نهاية المحتاج إلى شرح المنهاج",
    "canonical_short_title": "نهاية المحتاج",
    "author_canonical": "شمس الدين الرملي",
    "author_full": "شمس الدين محمد بن أبي العباس أحمد بن حمزة شهاب الدين الرملي (ت 1004هـ)",
    "death_year_hijri": 1004,
    "era": "mutaakhkhirin",
    "text_type": "sharh_mutamad",
    "authority_rank": 1,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "دار الفكر، بيروت"
  },
  "نهاية المطلب في دراية المذهب": {
    "folder_or_file": "نهاية المطلب في دراية المذهب",
    "raw_filename": "نهاية المطلب في دراية المذهب",
    "is_directory": true,
    "volumes_count": 22,
    "full_title": "نهاية المطلب في دراية المذهب",
    "canonical_short_title": "نهاية المطلب",
    "author_canonical": "إمام الحرمين الجويني",
    "author_full": "عبد الملك بن عبد الله بن يوسف بن محمد الجويني، أبو المعالي، ركن الدين، الملقب بإمام الحرمين (ت 478هـ)",
    "death_year_hijri": 478,
    "era": "mutawassithin",
    "text_type": "sharh_mabsuth",
    "authority_rank": 1,
    "has_hashiyah": false,
    "hashiyah_name": "",
    "hashiyah_authors": "",
    "muhaqqiq": "",
    "publisher": "دار المنهاج"
  }
}
```



================================================================================
# BAGIAN 3: KEAMANAN DATABASE & BACKEND CLOUD FUNCTIONS
================================================================================

## BERKAS BACKEND: openturath_ai/firestore.rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // ================================================================
    // USERS: perangkat hanya boleh membuat profil trial. Kuota, plan, masa
    // berlaku, dan entitlement hanya boleh diubah oleh Admin SDK/Cloud Functions.
    // ================================================================
    match /users/{userId} {
      // Boleh baca jika login dan uid sama
      allow read: if request.auth != null && request.auth.uid == userId;

      // CREATE: AuthService membuat profil trial ketika login pertama.
      // Nilai akses harus terkunci sejak dokumen pertama dibuat. Entitlements TIDAK boleh disuntik klien.
      allow create: if request.auth != null
        && request.auth.uid == userId
        && request.resource.data.keys().hasOnly([
          'name', 'email', 'photo_url', 'plan', 'questions_used',
          'subscription_expiry', 'entitlements', 'pending_deletion', 'pending_deletion_at'
        ])
        && (
          (request.auth.token.firebase.sign_in_provider != 'anonymous' && request.resource.data.email == request.auth.token.email) ||
          (request.auth.token.firebase.sign_in_provider == 'anonymous' && (!('email' in request.resource.data) || request.resource.data.email == null || request.resource.data.email == ''))
        )
        && request.resource.data.plan == 'trial'
        && request.resource.data.questions_used == 0
        && request.resource.data.subscription_expiry == null
        && (!('photo_url' in request.resource.data) || request.resource.data.photo_url == null || request.resource.data.photo_url.size() <= 1000)
        && (!('entitlements' in request.resource.data) || request.resource.data.entitlements == {});

      // UPDATE: Hanya diizinkan untuk menandai pending_deletion saat penghapusan akun
      allow update: if request.auth != null
        && request.auth.uid == userId
        && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['pending_deletion', 'pending_deletion_at'])
        && request.resource.data.pending_deletion == true;

      // DELETE: Pengguna boleh menghapus datanya sendiri
      allow delete: if false;

      // Sub-koleksi chat / conversations milik user
      match /conversations/{convId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
        
        match /messages/{msgId} {
          allow read, write: if request.auth != null && request.auth.uid == userId;
        }
      }
    }

    // ================================================================
    // APP CONFIG (Termasuk Dynamic Script & Info Aplikasi)
    // ================================================================
    match /app_config/{configId} {
      allow read: if true;
      allow write: if false;
    }

    // ================================================================
    // TRANSACTIONS: Hanya server / webhook yang boleh create/update
    // ================================================================
    match /transactions/{transactionId} {
      allow read: if request.auth != null && (resource == null || resource.data.uid == request.auth.uid);
      allow write: if false;
    }

    // ================================================================
    // SERVER-ONLY COLLECTIONS (Redeem, Webhook, Outbox, Rate Limits)
    // ================================================================
    match /redeem_codes/{codeId} {
      allow read, write: if false;
      match /{allSubcollections=**} {
        allow read, write: if false;
      }
    }

    match /redeem_attempts/{uid} {
      allow read, write: if false;
    }

    match /rate_limits/{limitId} {
      allow read, write: if false;
    }

    match /provisioning_outbox/{jobId} {
      allow read, write: if false;
    }

    match /webhook_events/{eventId} {
      allow read, write: if false;
    }

    // ================================================================
    // DEFAULT: Tolak akses lainnya
    // ================================================================
    match /{document=**} {
      allow read, write: if false;
    }
  }
}

```

## BERKAS BACKEND: openturath_ai/functions/src/index.ts
```typescript
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import axios from "axios";
import * as crypto from "crypto";

admin.initializeApp();
const db = admin.firestore();

// ================================================================
// TELEGRAM NOTIFICATION HELPER
// ================================================================
async function sendTelegramNotification(text: string): Promise<void> {
  const token = process.env.TELEGRAM_BOT_TOKEN || "8935430311:AAHajFoTtJBirH3DfyIh6za5-SVTQRBa_RI";
  const chatId = process.env.TELEGRAM_CHAT_ID || "2015667548";
  if (!token || !chatId) return;

  try {
    await axios.post(
      `https://api.telegram.org/bot${token}/sendMessage`,
      {
        chat_id: chatId,
        text,
        parse_mode: "HTML",
      },
      { timeout: 5000 }
    );
  } catch (err: any) {
    console.error("[Telegram] Failed to send notification:", err?.message || err);
  }
}


// ================================================================
// HARGA & DURASI OTORITATIF — Ditentukan oleh `resolvePlanPricing`
// ================================================================

// URL NotebookLM — HANYA ADA DI SINI, TIDAK DI CLIENT
const AGENT_URLS: Record<string, string> = {
  // Fikih
  fiqh_tahawwulat: "https://notebooklm.google.com/notebook/dc7ee7e4-f4ad-4db6-9cd0-0013727abbe4",
  fiqh_tahawwulat_muhaqqiq: "https://notebooklm.google.com/notebook/dc7ee7e4-f4ad-4db6-9cd0-0013727abbe4",
  fiqh_tahawwulat_bayan: "https://notebooklm.google.com/notebook/483d0291-0a70-411c-bff0-f1ea4b83b2fd",
  fiqh_syafii: "https://notebooklm.google.com/notebook/334e7b83-0e76-4787-a1d6-314642a35862",
  fiqh_syafii_muhaqqiq: "https://notebooklm.google.com/notebook/334e7b83-0e76-4787-a1d6-314642a35862",

  // Hadits
  hadits: "https://notebooklm.google.com/notebook/b9626501-538c-4358-a44f-6731eaec50b6",
  hadits_muhaqqiq: "https://notebooklm.google.com/notebook/b9626501-538c-4358-a44f-6731eaec50b6",
  hadits_takhrij: "https://notebooklm.google.com/notebook/b9626501-538c-4358-a44f-6731eaec50b6",
  hadits_syarah: "https://notebooklm.google.com/notebook/b9626501-538c-4358-a44f-6731eaec50b6",
  hadits_ilal: "https://notebooklm.google.com/notebook/b9626501-538c-4358-a44f-6731eaec50b6",

  // Tafsir
  tafsir: "https://notebooklm.google.com/notebook/df92cc50-1106-4221-8748-1663f00fa7fe",
  tafsir_muhaqqiq: "https://notebooklm.google.com/notebook/df92cc50-1106-4221-8748-1663f00fa7fe",
  tafsir_ahkam: "https://notebooklm.google.com/notebook/df92cc50-1106-4221-8748-1663f00fa7fe",
  tafsir_matsur: "https://notebooklm.google.com/notebook/df92cc50-1106-4221-8748-1663f00fa7fe",
  tafsir_ulumul_quran: "https://notebooklm.google.com/notebook/df92cc50-1106-4221-8748-1663f00fa7fe",

  // Ushul Fiqih
  ushul_fiqh: "https://notebooklm.google.com/notebook/6ab6dae8-0067-435a-85ca-b6bd4e17dd12",
  ushul_muhaqqiq: "https://notebooklm.google.com/notebook/6ab6dae8-0067-435a-85ca-b6bd4e17dd12",
  usul_qawaid: "https://notebooklm.google.com/notebook/6ab6dae8-0067-435a-85ca-b6bd4e17dd12",
  usul_maqashid: "https://notebooklm.google.com/notebook/6ab6dae8-0067-435a-85ca-b6bd4e17dd12",
  usul_istinbath: "https://notebooklm.google.com/notebook/6ab6dae8-0067-435a-85ca-b6bd4e17dd12",

  // Bahasa Arab
  nahwu_sharaf: "https://notebooklm.google.com/notebook/15bc4cef-4b94-4241-b05a-d50a586bde06",
  nahwu_sharaf_muerib: "https://notebooklm.google.com/notebook/15bc4cef-4b94-4241-b05a-d50a586bde06",
  nahwu_sharaf_tashrif: "https://notebooklm.google.com/notebook/15bc4cef-4b94-4241-b05a-d50a586bde06",
  bahasa_arab: "https://notebooklm.google.com/notebook/15bc4cef-4b94-4241-b05a-d50a586bde06",
  lughah_nahwu: "https://notebooklm.google.com/notebook/15bc4cef-4b94-4241-b05a-d50a586bde06",
  lughah_sharaf: "https://notebooklm.google.com/notebook/15bc4cef-4b94-4241-b05a-d50a586bde06",
  lughah_balaghah: "https://notebooklm.google.com/notebook/15bc4cef-4b94-4241-b05a-d50a586bde06",
  lughah_mujam: "https://notebooklm.google.com/notebook/15bc4cef-4b94-4241-b05a-d50a586bde06",
};

// Mapping eksplisit mencegah agent baru "jatuh" ke entitlement default dan
// tidak sengaja terbuka oleh langganan modul lain.
const AGENT_ENTITLEMENTS: Record<string, string> = {
  fiqh_tahawwulat: "fiqh_tahawwulat",
  fiqh_tahawwulat_muhaqqiq: "fiqh_tahawwulat",
  fiqh_tahawwulat_bayan: "fiqh_tahawwulat",
  fiqh_syafii: "fiqh_syafii",
  fiqh_syafii_muhaqqiq: "fiqh_syafii",
  fiqh_hanafi: "fiqh_hanafi",
  fiqh_maliki: "fiqh_maliki",
  fiqh_hanbali: "fiqh_hanbali",
  fiqh_muqaran: "fiqh_muqaran",

  nahwu_sharaf: "nahwu",
  nahwu_sharaf_muerib: "nahwu",
  nahwu_sharaf_tashrif: "nahwu",
  bahasa_arab: "nahwu",
  lughah_nahwu: "nahwu",
  lughah_sharaf: "nahwu",
  lughah_balaghah: "nahwu",
  lughah_mujam: "nahwu",

  ushul_fiqh: "ushul_fiqh",
  ushul_muhaqqiq: "ushul_fiqh",
  usul_qawaid: "ushul_fiqh",
  usul_maqashid: "ushul_fiqh",
  usul_istinbath: "ushul_fiqh",

  tafsir: "tafsir",
  tafsir_muhaqqiq: "tafsir",
  tafsir_ahkam: "tafsir",
  tafsir_matsur: "tafsir",
  tafsir_ulumul_quran: "tafsir",

  hadits: "hadits",
  hadits_muhaqqiq: "hadits",
  hadits_takhrij: "hadits",
  hadits_syarah: "hadits",
  hadits_ilal: "hadits",

  aqidah: "aqidah",
  aqidah_kalam: "aqidah",
  aqidah_ushuluddin: "aqidah",

  tarikh: "tarikh",
  tarikh_khulafa: "tarikh",
  tarikh_thabaqat: "tarikh",

  habib_umar: "tasawwuf",
  tasawwuf_ihya: "tasawwuf",
  tasawwuf_adab: "tasawwuf",

  all_ai: "all_access",
};

const TRIAL_QUESTION_LIMIT = 10;

function getEntitlementKey(agentId: string): string {
  const entitlementKey = AGENT_ENTITLEMENTS[agentId];
  if (!entitlementKey) {
    // Fallback jika ada id modul baru
    return agentId;
  }
  return entitlementKey;
}

export function addCalendarMonthsClamped(baseDate: Date, months: number): Date {
  const result = new Date(baseDate.getTime());
  const originalDay = result.getDate();
  result.setDate(1);
  result.setMonth(result.getMonth() + months);
  const maxDays = new Date(result.getFullYear(), result.getMonth() + 1, 0).getDate();
  result.setDate(Math.min(originalDay, maxDays));
  return result;
}

function getEntitlementAccess(userData: FirebaseFirestore.DocumentData, entitlementKey: string): { premiumPlan: boolean; active: boolean } {
  if (userData.account_deleted === true) return {premiumPlan:false,active:false};
  const entitlements = userData.entitlements && typeof userData.entitlements === "object"
    ? userData.entitlements as Record<string, any> : {};
  const now = Date.now();
  const active = (ent: any): boolean => {
    if (!ent || typeof ent.plan !== "string") return false;
    if (ent.status === "revoked" || ent.status === "expired") return false;
    const allowed = /^(tholib(?:_1m|_6m)?|bahits(?:_1y)?|premium|all_access|all_ai.*|single|sultan|pro|voucher(?:_.*)?|redeem(?:_.*)?|custom|full)$/.test(ent.plan);
    const expiry = ent.expiry?.toDate ? ent.expiry.toDate() : (ent.expiry?._seconds ? new Date(ent.expiry._seconds * 1000) : new Date(ent.expiry ?? ""));
    return allowed && Number.isFinite(expiry.getTime()) && expiry.getTime() > now;
  };
  const all = entitlements.all_access ?? entitlements.all_ai;
  if (active(all)) return { premiumPlan: true, active: true };
  const specific = entitlements[entitlementKey];
  if (active(specific)) return { premiumPlan: true, active: true };

  // Only explicit revocation of all_access blocks global subscription fallback
  if (all && all.status === "revoked") {
    return { premiumPlan: true, active: false };
  }

  // Account-level active subscription
  const expiry = userData.subscription_expiry?.toDate
    ? userData.subscription_expiry.toDate() : new Date(userData.subscription_expiry ?? "");
  const isGlobalExpiryValid = Number.isFinite(expiry.getTime()) && expiry.getTime() > now;

  const globalPlanPattern = /^(all_access|all_ai.*|full|sultan|tholib.*|bahits.*|premium|pro|custom|voucher.*|redeem.*)$/;
  const isGlobalPlan = typeof userData.plan === "string" && globalPlanPattern.test(userData.plan);

  if (isGlobalPlan && isGlobalExpiryValid) {
    return { premiumPlan: true, active: true };
  }

  if (userData.plan === "single") {
    return { premiumPlan: !!specific, active: false };
  }

  const legacy = ["all_access", "all_ai_1m", "all_ai_6m", "all_ai_1y", "all_ai", "full", "sultan", "tholib_1m", "tholib_6m", "bahits_1y", "tholib", "bahits", "premium", "pro", "custom"].includes(userData.plan);
  return { premiumPlan: legacy, active: legacy && isGlobalExpiryValid };
}

// ================================================================
// FUNCTION 1: getAgentUrl
// Dipanggil oleh Flutter saat user membuka agent
// ================================================================
export const getAgentUrl = functions
  .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com" })
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Login diperlukan untuk mengakses agent."
      );
    }

    const uid = context.auth.uid;
    const agentId = data.agentId as string;

    if (!agentId) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "agentId diperlukan."
      );
    }

    const url = AGENT_URLS[agentId];
    if (!url) {
      throw new functions.https.HttpsError(
        "not-found",
        "Agent tidak ditemukan atau belum aktif."
      );
    }

    const userDoc = await db.collection("users").doc(uid).get();
    if (!userDoc.exists) {
      throw new functions.https.HttpsError("not-found", "User tidak ditemukan.");
    }

    const userData = userDoc.data()!;
    const questionsUsed = (userData.questions_used as number) || 0;
    const entitlementKey = getEntitlementKey(agentId);

    const entitlementAccess = getEntitlementAccess(userData, entitlementKey);
    if (entitlementAccess.active) {
      return { url };
    }

    throw new functions.https.HttpsError(
      "permission-denied",
      "Akses modul riset ini membutuhkan langganan aktif atau kode redeem santri. Silakan berlangganan atau masukkan kode akses untuk melanjutkan."
    );
  });

// ================================================================
// FUNCTION 1b: recordQuestion
// Kuota trial hanya dapat berubah melalui transaksi server-side.
// ================================================================
export const recordQuestion = functions
  .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com" })
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Login diperlukan.");
    }
    const agentId = data.agentId as string;
    if (!agentId || !AGENT_URLS[agentId]) {
      throw new functions.https.HttpsError("not-found", "Kajian tidak ditemukan atau belum aktif.");
    }
    const entitlementKey = getEntitlementKey(agentId);
    const userRef = db.collection("users").doc(context.auth.uid);

    return db.runTransaction(async (transaction) => {
      const snapshot = await transaction.get(userRef);
      if (!snapshot.exists) {
        throw new functions.https.HttpsError("not-found", "User tidak ditemukan.");
      }
      const userData = snapshot.data()!;
      const entitlementAccess = getEntitlementAccess(userData, entitlementKey);
      if (entitlementAccess.active) {
        return { isPremium: true, questionsUsed: userData.questions_used || 0, questionsRemaining: null };
      }
      if (entitlementAccess.premiumPlan) {
        throw new functions.https.HttpsError(
          "permission-denied",
          "Langganan Anda untuk kajian ini telah berakhir."
        );
      }

      const questionsUsed = Number.isInteger(userData.questions_used) ? userData.questions_used : 0;
      if (questionsUsed >= TRIAL_QUESTION_LIMIT) {
        throw new functions.https.HttpsError(
          "permission-denied",
          "Kuota uji coba sudah habis. Berlangganan untuk lanjut."
        );
      }
      const updatedQuestionsUsed = questionsUsed + 1;
      transaction.update(userRef, { questions_used: updatedQuestionsUsed });
      return {
        isPremium: false,
        questionsUsed: updatedQuestionsUsed,
        questionsRemaining: TRIAL_QUESTION_LIMIT - updatedQuestionsUsed,
      };
    });
  });

// ================================================================
// DOKU PAYMENT GATEWAY INTEGRATION
// ================================================================

function getDokuConfig() {
  const env = process.env.DOKU_ENV || "sandbox";
  const baseUrl = env === "production" ? "https://api.doku.com" : "https://api-sandbox.doku.com";
  const clientId = process.env.DOKU_CLIENT_ID || "";
  const secretKey = process.env.DOKU_SECRET_KEY || "";
  const apiKey = process.env.DOKU_API_KEY || "";
  if (!clientId || !secretKey) {
    throw new Error("DOKU credentials are not configured");
  }
  return { env, baseUrl, clientId, secretKey, apiKey };
}

function generateDokuSignature(
  clientId: string,
  requestId: string,
  timestamp: string,
  targetPath: string,
  rawBody: string,
  secretKey: string
): string {
  const digest = crypto.createHash("sha256").update(rawBody).digest("base64");
  const signatureComponent =
    `Client-Id:${clientId}\n` +
    `Request-Id:${requestId}\n` +
    `Request-Timestamp:${timestamp}\n` +
    `Request-Target:${targetPath}\n` +
    `Digest:${digest}`;
  const hmac = crypto.createHmac("sha256", secretKey).update(signatureComponent).digest("base64");
  return `HMACSHA256=${hmac}`;
}

function resolvePlanPricing(agentId: string, plan: string): { amount: number; durationMonths: number; label: string; entitlementKey: string } {
  const isAllAi = agentId === "all_ai" || plan.startsWith("all_ai");

  let durationMonths = 1;
  if (plan.includes("1y") || plan.includes("year") || plan === "bahits_1y") durationMonths = 12;
  else if (plan.includes("6m") || plan === "tholib_6m") durationMonths = 6;
  else durationMonths = 1;

  if (isAllAi) {
    const entitlementKey = "all_access";
    if (durationMonths === 12) {
      return { amount: 799000, durationMonths, label: "Paket Lengkap Semua AI (1 Tahun)", entitlementKey };
    } else if (durationMonths === 6) {
      return { amount: 499000, durationMonths, label: "Paket Lengkap Semua AI (6 Bulan)", entitlementKey };
    } else {
      return { amount: 99000, durationMonths, label: "Paket Promo Semua AI (1 Bulan)", entitlementKey };
    }
  }

  // Masing-masing AI per-modul: Rp 50.000 / bulan
  const entitlementKey = getEntitlementKey(agentId);
  const agentTitle = agentId.replace(/_/g, " ").replace(/\b\w/g, (l) => l.toUpperCase());
  if (durationMonths === 12) {
    return { amount: 450000, durationMonths, label: `Modul AI ${agentTitle} (1 Tahun)`, entitlementKey };
  } else if (durationMonths === 6) {
    return { amount: 250000, durationMonths, label: `Modul AI ${agentTitle} (6 Bulan)`, entitlementKey };
  } else {
    return { amount: 50000, durationMonths, label: `Modul AI ${agentTitle} (1 Bulan)`, entitlementKey };
  }
}

async function requestDokuCheckout(params: {
  invoiceNumber: string;
  amount: number;
  itemName: string;
  customerName: string;
  customerEmail: string;
  customerPhone: string;
}): Promise<string> {
  const { baseUrl, clientId, secretKey } = getDokuConfig();
  const requestId = `REQ-${Date.now()}-${Math.floor(1000 + Math.random() * 9000)}`;
  const timestamp = new Date().toISOString().slice(0, 19) + "Z";
  const targetPath = "/checkout/v1/payment";

  const requestBody = {
    order: {
      amount: params.amount,
      invoice_number: params.invoiceNumber,
      callback_url: "https://openturath-ai.web.app",
      line_items: [
        {
          name: params.itemName.slice(0, 50),
          price: params.amount,
          quantity: 1
        }
      ]
    },
    payment: {
      payment_due_date: 120 // 2 jam
    },
    customer: {
      name: params.customerName || "Peneliti OpenTurath",
      email: params.customerEmail,
      phone: params.customerPhone || ""
    }
  };

  const rawJson = JSON.stringify(requestBody);
  const signature = generateDokuSignature(
    clientId,
    requestId,
    timestamp,
    targetPath,
    rawJson,
    secretKey
  );

  console.log(`[DOKU API] Requesting Checkout for ${params.invoiceNumber} (${params.itemName}) - Rp ${params.amount}...`);
  const response = await axios.post(`${baseUrl}${targetPath}`, requestBody, {
    headers: {
      "Client-Id": clientId,
      "Request-Id": requestId,
      "Request-Timestamp": timestamp,
      "Signature": signature,
      "Content-Type": "application/json"
    },
    timeout: 15000
  });

  const paymentUrl = response.data?.response?.payment?.url || response.data?.payment?.url;
  if (!paymentUrl) {
    console.error("[DOKU API] No payment URL in response:", JSON.stringify(response.data));
    throw new Error("DOKU tidak mengembalikan payment URL.");
  }

  return paymentUrl;
}

// ================================================================
// ================================================================
// RATE LIMITING HELPER (In-Memory / Firestore Atomic Window)
// ================================================================
async function enforceRateLimit(
  key: string,
  limit: number,
  windowSeconds: number,
  errorMessage: string
): Promise<void> {
  const now = Date.now();
  const rateLimitRef = db.collection("rate_limits").doc(key);

  await db.runTransaction(async (t) => {
    const snap = await t.get(rateLimitRef);
    if (!snap.exists) {
      t.set(rateLimitRef, {
        count: 1,
        reset_at: admin.firestore.Timestamp.fromMillis(now + windowSeconds * 1000),
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      });
      return;
    }

    const data = snap.data()!;
    const resetAt = data.reset_at?.toMillis ? data.reset_at.toMillis() : (data.reset_at || 0);

    if (now > resetAt) {
      // Window reset
      t.set(rateLimitRef, {
        count: 1,
        reset_at: admin.firestore.Timestamp.fromMillis(now + windowSeconds * 1000),
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      });
      return;
    }

    const currentCount = (data.count || 0) as number;
    if (currentCount >= limit) {
      const waitSec = Math.ceil((resetAt - now) / 1000);
      throw new functions.https.HttpsError(
        "resource-exhausted",
        `${errorMessage} Harap tunggu ${waitSec} detik lagi.`
      );
    }

    t.update(rateLimitRef, {
      count: currentCount + 1,
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    });
  });
}

// ================================================================
// FUNCTION 2: createCheckout
// Dipanggil dari app & web — mengembalikan link DOKU Checkout
// ================================================================
export const createCheckout = functions
  .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com" })
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Login diperlukan untuk melakukan transaksi."
      );
    }
    const { plan, name, email, phone, agentId } = data;

    if (!plan || !name || !email) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Data tidak lengkap (nama dan email diperlukan)."
      );
    }

    const currentAgentId = typeof agentId === "string" && agentId ? agentId : "fiqh_tahawwulat";
    const pricing = resolvePlanPricing(currentAgentId, plan as string);
    const invoiceNumber = `OT-${Date.now()}-${Math.floor(1000 + Math.random() * 9000)}`;

    const trxRef = db.collection("transactions").doc();
    const trxId = trxRef.id;
    const uid = context.auth?.uid || null;

    // F-07: Tulis dokumen transaksi berstatus pending SEBELUM memanggil gateway DOKU
    await trxRef.set({
      uid,
      plan,
      agent_id: currentAgentId,
      gateway: "doku",
      invoice_number: invoiceNumber,
      amount: pricing.amount,
      duration_months: pricing.durationMonths,
      entitlement_key: pricing.entitlementKey,
      status: "pending",
      source: uid ? "app" : "website",
      customer_name: name,
      customer_email: email,
      customer_phone: phone || "",
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    let paymentUrl = "";
    try {
      paymentUrl = await requestDokuCheckout({
        invoiceNumber,
        amount: pricing.amount,
        itemName: pricing.label,
        customerName: name,
        customerEmail: email,
        customerPhone: phone || "",
      });

      // Update URL pembayaran yang berhasil diperoleh
      await trxRef.update({
        payment_url: paymentUrl,
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      });
    } catch (err: any) {
      console.error("[createCheckout] DOKU checkout error:", err.response?.data || err.message);
      await trxRef.update({
        status: "failed",
        error: err.response?.data?.error?.message || err.message || "Kendala teknis DOKU",
        failed_at: admin.firestore.FieldValue.serverTimestamp(),
      }).catch(() => {});
      throw new functions.https.HttpsError(
        "internal",
        "Gagal membuat sesi pembayaran DOKU: " + (err.response?.data?.error?.message || err.message || "Kendala teknis DOKU")
      );
    }

    return {
      redirectUrl: paymentUrl,
      paymentUrl: paymentUrl,
      trxId,
      invoiceNumber
    };
  });

function generateDokuGetSignature(
  clientId: string,
  requestId: string,
  timestamp: string,
  targetPath: string,
  secretKey: string
): string {
  const component = `Client-Id:${clientId}\nRequest-Id:${requestId}\nRequest-Timestamp:${timestamp}\nRequest-Target:${targetPath}`;
  const hmac = crypto.createHmac("sha256", secretKey).update(component).digest("base64");
  return `HMACSHA256=${hmac}`;
}

function getServiceTitleForEntitlement(entitlementKey: string): string {
  if (entitlementKey === "all_access" || entitlementKey === "all_ai") return "Paket Semua AI";
  if (entitlementKey === "fiqh_tahawwulat") return "AI Fikih Tahawwulat";
  if (entitlementKey === "fiqh_syafii") return "AI Fikih Syafi'i";
  if (entitlementKey === "fiqh_hanafi") return "AI Fikih Hanafi";
  if (entitlementKey === "fiqh_maliki") return "AI Fikih Maliki";
  if (entitlementKey === "fiqh_hanbali") return "AI Fikih Hanbali";
  if (entitlementKey === "fiqh_muqaran") return "AI Fikih Perbandingan Mazhab";
  if (entitlementKey === "ushul_fiqh") return "AI Ushul Fiqih";
  if (entitlementKey === "tafsir") return "AI Tafsir";
  if (entitlementKey === "hadits") return "AI Hadits";
  if (entitlementKey === "nahwu" || entitlementKey === "bahasa_arab" || entitlementKey === "nahwu_sharaf") return "AI Bahasa Arab";
  if (entitlementKey === "aqidah" || entitlementKey === "aqidah_kalam" || entitlementKey === "aqidah_ushuluddin") return "AI Aqidah & Ushuluddin";
  if (entitlementKey === "tarikh" || entitlementKey === "tarikh_khulafa" || entitlementKey === "tarikh_thabaqat" || entitlementKey === "sirah") return "AI Tarikh & Sirah Nabawiyah";
  if (entitlementKey === "tasawwuf" || entitlementKey === "habib_umar" || entitlementKey === "tasawwuf_ihya" || entitlementKey === "tasawwuf_adab") return "AI Tasawwuf & Tazkiyatun Nafs";
  return "Modul kajian";
}

async function processSuccessfulPayment(invoiceNumber: string, paidAmount: unknown) {
  const txQuery = await db.collection("transactions")
    .where("invoice_number", "==", invoiceNumber)
    .limit(1)
    .get();

  if (txQuery.empty) {
    console.warn(`[Activation] Transaction not found for invoice: ${invoiceNumber}`);
    throw new Error("Transaction not found");
  }

  const txDocRef = txQuery.docs[0].ref;

  let activationResult = {
    alreadyActivated: false,
    entitlementKey: "fiqh_tahawwulat",
    plan: "premium",
    email: "",
    uid: "",
    serviceTitle: "Ruang Riset",
  };

  // F03, F04, F05: Transaksi Atomik Firestore
  await db.runTransaction(async (t) => {
    const txSnap = await t.get(txDocRef);
    if (!txSnap.exists) {
      throw new Error(`Transaction ${invoiceNumber} tidak ditemukan dalam transaksi`);
    }
    const txData = txSnap.data()!;
    const amount = typeof paidAmount === "string" && /^\d+(?:\.0+)?$/.test(paidAmount)
      ? Number(paidAmount) : paidAmount;
    if (!Number.isSafeInteger(amount) || (amount as number) <= 0 || amount !== txData.amount) {
      throw new Error("Payment amount does not match invoice");
    }

    // F04: Idempotensi invoice - cegah penambahan durasi berulang jika invoice sudah diaktivasi
    if (txData.activation_applied === true) {
      activationResult = {
        alreadyActivated: true,
        entitlementKey: txData.entitlement_key || "fiqh_tahawwulat",
        plan: txData.plan || "premium",
        email: (txData.customer_email || "").trim().toLowerCase(),
        uid: txData.uid || "",
        serviceTitle: getServiceTitleForEntitlement(txData.entitlement_key || "fiqh_tahawwulat"),
      };
      return;
    }

    const uid = txData.uid;
    const email = (txData.customer_email || "").trim().toLowerCase();
    const durationMonths = txData.duration_months || 1;
    const entitlementKey = txData.entitlement_key || "fiqh_tahawwulat";
    const plan = txData.plan || "premium";

    // F07: UID terverifikasi wajib menjadi pemilik dokumen
    if (!uid) {
      throw new Error(`Transaction ${invoiceNumber} tidak memiliki owner UID`);
    }

    const userRef = db.collection("users").doc(uid);
    const uSnap = await t.get(userRef);
    if (!uSnap.exists) throw new Error("Payment owner profile is missing");
    const uData = uSnap.data()!;
    const entitlements = (uData.entitlements || {}) as Record<string, any>;
    const currentEnt = entitlements[entitlementKey];

    // F65: Hitung tanggal kedaluwarsa dengan month-end clamp
    const now = new Date();
    let baseDate = now;
    if (currentEnt && currentEnt.expiry && currentEnt.status === "active") {
      const curExpDate = currentEnt.expiry.toDate ? currentEnt.expiry.toDate() : new Date(currentEnt.expiry);
      if (curExpDate > now) {
        baseDate = curExpDate;
      }
    }
    const expiryDate = addCalendarMonthsClamped(baseDate, durationMonths);

    // F03: Update Status Transaksi Atomik
    t.update(txDocRef, {
      status: "paid",
      activation_applied: true,
      paid_at: admin.firestore.FieldValue.serverTimestamp(),
      subscription_expires_at: admin.firestore.Timestamp.fromDate(expiryDate),
      billing_email: email, // F07: Simpan sebagai billing_email kontak terpisah
    });

    const isAllAccess = entitlementKey === "all_access" || entitlementKey === "all_ai";

    const updatedEntitlements = {
      ...entitlements,
      [entitlementKey]: {
        plan: plan,
        status: "active",
        source: "doku_payment",
        expiry: admin.firestore.Timestamp.fromDate(expiryDate),
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      }
    };

    const userUpdate: any = {
      entitlements: updatedEntitlements,
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    };

    // F01: Hanya ubah plan global jika pembelian adalah paket all_access
    if (isAllAccess) {
      userUpdate.plan = plan;
      userUpdate.subscription_expiry = admin.firestore.Timestamp.fromDate(expiryDate);
    }

    // F07: Jangan menimpa email auth user jika sudah ada
    if (!uData.email && email) {
      userUpdate.email = email;
    }

    t.set(userRef, userUpdate, { merge: true });

    // F10, F11: Rekam durable outbox job dalam transaksi yang sama
    const outboxRef = db.collection("provisioning_outbox").doc(`job_${invoiceNumber}`);
    t.set(outboxRef, {
      invoice_number: invoiceNumber,
      uid: userRef.id,
      email: uData.email || email,
      name: uData.name || txData.customer_name || "Peneliti",
      entitlement_key: entitlementKey,
      plan: plan,
      action: "add",
      status: "pending",
      attempts: 0,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    activationResult = {
      alreadyActivated: false,
      entitlementKey,
      plan,
      email: uData.email || email,
      uid: userRef.id,
      serviceTitle: getServiceTitleForEntitlement(entitlementKey),
    };
  });

  if (activationResult.alreadyActivated) {
    console.log(`[Activation] Invoice ${invoiceNumber} sudah diaktivasi sebelumnya (idempoten).`);
    return { success: true, ...activationResult };
  }

  console.log(`[Activation] Akses berhasil diaktifkan atomik untuk ${activationResult.uid} (Modul: ${activationResult.entitlementKey})`);

  return { success: true, ...activationResult };
}

function safeTimingEqual(a: string, b: string): boolean {
  if (typeof a !== "string" || typeof b !== "string") return false;
  const bufA = Buffer.from(a);
  const bufB = Buffer.from(b);
  if (bufA.length !== bufB.length) return false;
  return crypto.timingSafeEqual(bufA, bufB);
}

// ================================================================
// FUNCTION 2b: dokuWebhook (HTTP Notification dari DOKU)
// Otomatis aktifkan akses santri di Firestore saat bayar sukses
// ================================================================
export const dokuWebhook = functions
  .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com" })
  .https.onRequest(async (req, res) => {
    try {
      if (req.method !== "POST") {
        res.status(405).send("Method Not Allowed");
        return;
      }
      const headers = req.headers;
      const body = req.body || {};

      // F63: Redaksi log sensitif - jangan cetak raw authorization atau full personal payload
      const invoiceNumber = body.order?.invoice_number || body.invoice_number;
      const status = body.transaction?.status || body.transactionStatus || body.status;
      console.log(`[DOKU Webhook] Notifikasi diterima untuk invoice: ${invoiceNumber}, status: ${status}`);

      // Verifikasi Signature DOKU wajib di seluruh environment
      const incomingSignature = (headers["signature"] || headers["Signature"]) as string | undefined;
      const dokuCfg = getDokuConfig();
      if (!incomingSignature) {
        console.error("[DOKU Webhook] Missing signature header.");
        res.status(401).send("Missing signature header");
        return;
      }

      const clientId = headers["client-id"];
      const requestId = headers["request-id"];
      const timestamp = headers["request-timestamp"];
      if (typeof incomingSignature !== "string" || typeof clientId !== "string" ||
          clientId !== dokuCfg.clientId || typeof requestId !== "string" ||
          requestId.length === 0 || requestId.length > 200 ||
          typeof timestamp !== "string" || !timestamp ||
          !Buffer.isBuffer(req.rawBody)) {
        res.status(401).send("Invalid notification headers");
        return;
      }
      const rawBody = req.rawBody.toString("utf8");

      const expectedSig1 = generateDokuSignature(clientId, requestId, timestamp, req.originalUrl || "/dokuWebhook", rawBody, dokuCfg.secretKey);
      const expectedSig2 = generateDokuSignature(clientId, requestId, timestamp, req.path || "/dokuWebhook", rawBody, dokuCfg.secretKey);
      const expectedSig3 = generateDokuSignature(clientId, requestId, timestamp, "/dokuWebhook", rawBody, dokuCfg.secretKey);

      // F-06: Verifikasi signature dengan constant-time comparison mencegah timing attacks
      const isValidSig = safeTimingEqual(incomingSignature, expectedSig1) ||
                         safeTimingEqual(incomingSignature, expectedSig2) ||
                         safeTimingEqual(incomingSignature, expectedSig3);

      if (!isValidSig) {
        console.error(`[DOKU Webhook] Signature mismatch for request ${requestId}`);
        res.status(401).send("Invalid signature");
        return;
      }

      // F-06: Verifikasi skew timestamp mencegah replay attack (toleransi maksimal 15 menit)
      if (timestamp) {
        const reqTime = new Date(timestamp).getTime();
        if (isNaN(reqTime) || Math.abs(Date.now() - reqTime) > 15 * 60 * 1000) {
          console.error(`[DOKU Webhook] Request-Timestamp invalid or skew > 15 min: ${timestamp}`);
          res.status(401).send("Timestamp expired or invalid");
          return;
        }
      }

      if (typeof invoiceNumber !== "string" || !/^[A-Za-z0-9_-]{1,128}$/.test(invoiceNumber)) {
        console.warn("[DOKU Webhook] Missing invoice_number in notification.");
        res.status(400).send("Missing invoice_number");
        return;
      }

      // F06: State Machine Idempotensi Event (received -> processing -> completed / failed)
      let eventRef: FirebaseFirestore.DocumentReference | null = null;
      if (requestId) {
        eventRef = db.collection("webhook_events").doc(crypto.createHash("sha256").update(requestId).digest("hex"));
        const eventSnap = await eventRef.get();
        if (eventSnap.exists) {
          const eventData = eventSnap.data()!;
          if (eventData.status === "completed") {
            console.log(`[DOKU Webhook] Request ID ${requestId} sudah berstatus completed. 200 OK.`);
            res.status(200).json({ status: "ALREADY_PROCESSED", requestId });
            return;
          }
        }
        await eventRef.set({
          invoice_number: invoiceNumber,
          status: "processing",
          received_at: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });
      }

      if (status !== "SUCCESS") {
        console.log(`[DOKU Webhook] Status: ${status}, skipping activation.`);
        if (eventRef) {
          await eventRef.update({ status: "ignored_not_success" });
        }
        res.status(200).json({ status: "OK", message: "Ignored status" });
        return;
      }

      try {
        const actResult = await processSuccessfulPayment(invoiceNumber, body.order?.amount ?? body.amount);
        if (eventRef) {
          await eventRef.update({
            status: "completed",
            completed_at: admin.firestore.FieldValue.serverTimestamp(),
          });
        }
        res.status(200).json({ status: "SUCCESS", invoice: invoiceNumber, details: actResult });
      } catch (err: any) {
        console.error(`[DOKU Webhook] Activation error for invoice ${invoiceNumber}:`, err.message);
        if (eventRef) {
          await eventRef.update({
            status: "failed",
            error: err.message || "Activation failure",
            failed_at: admin.firestore.FieldValue.serverTimestamp(),
          });
        }
        res.status(500).json({ status: "ERROR", message: "Failed to activate payment" });
      }
    } catch (err: any) {
      console.error("[DOKU Webhook] Uncaught error in handler:", err.message);
      res.status(500).json({ error: err.message });
    }
  });

// ================================================================
// FUNCTION 2c: checkPaymentStatus (Active Status Inquiry dari Client/App)
// Memverifikasi status langsung ke DOKU API tanpa menunggu webhook
// ================================================================
export const checkPaymentStatus = functions
  .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com" })
  .https.onCall(async (data, context) => {
    // 0. Wajibkan pengguna terotentikasi
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Login diperlukan untuk memeriksa status pembayaran.");
    }

    const callerUid = context.auth.uid;
    // F-02: Rate limit status inquiry (maksimal 15 panggilan per menit per UID)
    await enforceRateLimit(
      `chk_${callerUid}`,
      15,
      60,
      "Terlalu banyak permintaan pemeriksaan status pembayaran."
    );

    const invoiceNumber = data.invoiceNumber;
    if (!invoiceNumber) {
      throw new functions.https.HttpsError("invalid-argument", "Invoice number diperlukan.");
    }

    // 1. Cek dulu apakah di Firestore transaksi sudah berstatus success
    const txQuery = await db.collection("transactions")
      .where("invoice_number", "==", invoiceNumber)
      .limit(1)
      .get();

    if (txQuery.empty) {
      throw new functions.https.HttpsError("not-found", "Transaksi tidak ditemukan.");
    }

    const txDoc = txQuery.docs[0];
    const txData = txDoc.data();

    // Verifikasi kepemilikan transaksi
    if (txData.uid !== callerUid) {
      throw new functions.https.HttpsError("permission-denied", "Anda tidak memiliki akses untuk memeriksa transaksi ini.");
    }

    if (txData.status === "paid" || txData.status === "success") {
      return { success: true, status: "SUCCESS", message: "Akses langganan sudah aktif." };
    }

    // 2. Jika belum success di Firestore, query langsung ke DOKU Orders Inquiry API
    const dokuCfg = getDokuConfig();
    const targetPath = `/orders/v1/status/${invoiceNumber}`;
    const requestId = `REQ-${Date.now()}-${Math.floor(1000 + Math.random() * 9000)}`;
    const timestamp = new Date().toISOString().slice(0, 19) + "Z";
    const signature = generateDokuGetSignature(dokuCfg.clientId, requestId, timestamp, targetPath, dokuCfg.secretKey);

    try {
      console.log(`[checkPaymentStatus] Inquiring DOKU API for ${invoiceNumber}...`);
      const response = await axios.get(`${dokuCfg.baseUrl}${targetPath}`, {
        headers: {
          "Client-Id": dokuCfg.clientId,
          "Request-Id": requestId,
          "Request-Timestamp": timestamp,
          "Signature": signature,
        },
        timeout: 10000,
      });

      const dokuData = response.data || {};
      const trxStatus = dokuData.transaction?.status || "";

      if (trxStatus === "SUCCESS") {
        console.log(`[checkPaymentStatus] DOKU Inquiry verified SUCCESS for ${invoiceNumber}! Activating subscription...`);
        const actResult = await processSuccessfulPayment(invoiceNumber, dokuData.order?.amount);
        return {
          success: true,
          status: "SUCCESS",
          message: "Pembayaran terverifikasi. Akses Anda sudah aktif.",
          details: actResult
        };
      } else {
        return {
          success: false,
          status: trxStatus || "PENDING",
          message: "Pembayaran masih menunggu penyelesaian."
        };
      }
    } catch (err: any) {
      console.error("[checkPaymentStatus] Error checking DOKU status:", err.response?.data || err.message);
      return {
        success: false,
        status: "PENDING",
        error: err.response?.data || err.message
      };
    }
  });

// ================================================================
// FUNCTION 2d: redeemCode
// Menukarkan Kode Redeem Santri (Voucher Akses 7 Hari, dsb)
// Mengaktifkan entitlement berbatas waktu & trigger email sharing
// ================================================================
export const redeemCode = functions
  .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com", timeoutSeconds: 120 })
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Login diperlukan untuk menukarkan kode akses.");
    }

    if (typeof data?.code !== "string" || data.code.length > 256) {
      throw new functions.https.HttpsError("invalid-argument", "Format kode akses tidak valid.");
    }
    const rawCode = data.code.trim().toUpperCase().replace(/[\s-]/g, "");
    if (!/^[A-Z0-9]{1,64}$/.test(rawCode)) {
      throw new functions.https.HttpsError("invalid-argument", "Format kode akses tidak valid.");
    }
    if (!rawCode) {
      throw new functions.https.HttpsError("invalid-argument", "Kode redeem tidak boleh kosong.");
    }

    const uid = context.auth.uid;
    // F-03 & F-05: Rate limit penukaran voucher per UID (maksimal 8 percobaan per 15 menit)
    await enforceRateLimit(
      `rdm_${uid}`,
      8,
      900,
      "Terlalu banyak percobaan penukaran kode redeem."
    );

    const userEmail = (context.auth.token.email || "").trim().toLowerCase();

    let redeemResult = {
      entitlementKey: "fiqh_syafii",
      durationDays: 7,
      expiryIso: "",
      email: userEmail,
      name: "Peneliti",
      serviceTitle: "AI Fikih Syafi'i",
    };

    await db.runTransaction(async (transaction) => {
      const codeRef = db.collection("redeem_codes").doc(rawCode);
      const codeDoc = await transaction.get(codeRef);

      if (!codeDoc.exists) {
        throw new functions.https.HttpsError("not-found", "Kode redeem tidak ditemukan atau salah.");
      }

      const codeData = codeDoc.data()!;
      if (codeData.is_active === false) {
        throw new functions.https.HttpsError("failed-precondition", "Kode redeem ini sudah tidak aktif.");
      }

      const maxUses = (codeData.max_uses as number) || 1;
      const timesUsed = (codeData.times_used as number) || 0;
      if (timesUsed >= maxUses) {
        throw new functions.https.HttpsError("resource-exhausted", "Batas pemakaian kode redeem ini sudah tercapai.");
      }

      if (codeData.expires_at && codeData.expires_at.toDate() < new Date()) {
        throw new functions.https.HttpsError("deadline-exceeded", "Masa berlaku penukaran kode ini telah kedaluwarsa.");
      }

      // Periksa apakah pengguna sudah pernah menukarkan kode ini
      const redemptionRef = codeRef.collection("redemptions").doc(uid);
      const redemptionDoc = await transaction.get(redemptionRef);
      if (redemptionDoc.exists) {
        throw new functions.https.HttpsError("already-exists", "Anda sudah pernah menukarkan kode ini sebelumnya.");
      }

      const entitlementKey = (codeData.entitlement_key as string) || "fiqh_syafii";
      const durationDays = (codeData.duration_days as number) || 7;

      // Ambil user saat ini
      const userRef = db.collection("users").doc(uid);
      const userDoc = await transaction.get(userRef);
      const userData = userDoc.exists ? userDoc.data()! : {};
      const entitlements = (userData.entitlements || {}) as Record<string, any>;
      const currentEnt = entitlements[entitlementKey];

      let baseDate = new Date();
      if (currentEnt && currentEnt.expiry && currentEnt.status === "active") {
        const curExp = currentEnt.expiry.toDate ? currentEnt.expiry.toDate() : new Date(currentEnt.expiry);
        if (curExp > baseDate) {
          baseDate = curExp;
        }
      }

      const newExpiry = new Date(baseDate.getTime() + durationDays * 24 * 60 * 60 * 1000);

      // 1. Simpan catatan penukaran
      transaction.set(redemptionRef, {
        uid,
        email: userEmail,
        redeemed_at: admin.firestore.FieldValue.serverTimestamp(),
      });

      // 2. Increment pemakaian kode
      transaction.update(codeRef, {
        times_used: timesUsed + 1,
      });

      // 3. Update profil dan entitlement pengguna (F01: isolasi per modul)
      const updatedEntitlements = {
        ...entitlements,
        [entitlementKey]: {
          plan: "voucher_access",
          status: "active",
          source: "redeem_code",
          code_id: rawCode.slice(0, 4) + "****", // Redaksi di entitlement
          expiry: admin.firestore.Timestamp.fromDate(newExpiry),
          updated_at: admin.firestore.FieldValue.serverTimestamp(),
        }
      };

      const userUpdate: any = {
        entitlements: updatedEntitlements,
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      };

      // Hanya set plan global jika voucher adalah all_access
      if (entitlementKey === "all_access") {
        userUpdate.plan = "voucher_access";
        userUpdate.subscription_expiry = admin.firestore.Timestamp.fromDate(newExpiry);
      }

      if (!userData.email && userEmail) {
        userUpdate.email = userEmail;
      }

      transaction.set(userRef, userUpdate, { merge: true });

      // F10: Rekam outbox job untuk provisioning NotebookLM
      const outboxRef = db.collection("provisioning_outbox").doc(`redeem_${rawCode}_${uid}`);
      transaction.set(outboxRef, {
        type: "redeem",
        uid,
        email: userEmail || userData.email || "",
        name: userData.name || "Peneliti",
        entitlement_key: entitlementKey,
        plan: "voucher_access",
        action: "add",
        status: "pending",
        attempts: 0,
        created_at: admin.firestore.FieldValue.serverTimestamp(),
      });

      redeemResult = {
        entitlementKey,
        durationDays,
        expiryIso: newExpiry.toISOString(),
        email: userEmail || userData.email || "",
        name: userData.name || "Peneliti",
        serviceTitle: getServiceTitleForEntitlement(entitlementKey),
      };
    });

    // F63: Redaksi log kode voucher mentah
    console.log(`[Redeem] Voucher berhasil ditukarkan oleh ${uid}. Modul: ${redeemResult.entitlementKey}, aktif s/d ${redeemResult.expiryIso}`);

    // 1. Kirim notifikasi Telegram seketika ke admin
    const tgMessage = 
      `🔔 <b>[VOUCHER SANTRI DIKLAIM]</b>\n` +
      `🕌 OpenTurath AI\n` +
      `🎟️ Kode: <b>${rawCode}</b>\n` +
      `📧 Email: <code>${redeemResult.email}</code>\n` +
      `👤 Nama: <b>${redeemResult.name}</b>\n` +
      `📦 Produk: <b>${redeemResult.serviceTitle}</b>\n` +
      `🏷️ Durasi: <b>${redeemResult.durationDays} Hari</b>\n` +
      `⏳ Berlaku s/d: <code>${redeemResult.expiryIso}</code>\n` +
      `✅ Status: Sukses terdaftar & hak akses aktif.`;
    
    await sendTelegramNotification(tgMessage);

    // 2. Trigger auto-provisioning ke server NotebookLM (Cloud Run)
    try {
      const targetService = redeemResult.entitlementKey === "all_access" ? "Paket Semua AI" : redeemResult.serviceTitle;
      await notifySubscriptionServer(
        redeemResult.email,
        redeemResult.name,
        "voucher_access",
        "add",
        targetService
      );
      await db.collection("provisioning_outbox").doc(`redeem_${rawCode}_${uid}`).update({
        status: "completed",
        provisioned_at: admin.firestore.FieldValue.serverTimestamp(),
      });
    } catch (err: any) {
      console.error("[Redeem] Auto-provisioning via Cloud Run error:", err?.message || err);
    }

    return {
      success: true,
      entitlementKey: redeemResult.entitlementKey,
      durationDays: redeemResult.durationDays,
      expiry: redeemResult.expiryIso,
      message: `Kode diterima. Akses ke ${redeemResult.serviceTitle} sudah aktif.`,
    };
  });

// ================================================================
// FUNCTION 3.5: onUserCreate
// Dipanggil otomatis saat user pertama kali register di app
// Menghubungkan transaksi sukses sebelumnya berdasarkan email
// ================================================================
export const onUserCreate = functions.firestore
  .document("users/{uid}")
  .onCreate(async (snapshot, context) => {
    const uid = context.params.uid;
    const user = await admin.auth().getUser(uid);
    if (!user.emailVerified || !user.email) return null;
    // Only owned historical transactions may repair an empty profile.
    const owned = await db.collection("transactions").where("uid", "==", uid)
      .where("status", "in", ["success", "paid"]).get();
    if (owned.empty) return null;
    await db.runTransaction(async t => {
      const current = await t.get(snapshot.ref);
      if (!current.exists) return;
      const profile = current.data()!;
      if (Object.keys(profile.entitlements || {}).length > 0) return;
      const entitlements: Record<string, any> = {};
      const txs = [];
      for (const doc of owned.docs) txs.push(await t.get(doc.ref));
      for (const tx of txs) {
        const data = tx.data();
        if (!data || data.uid !== uid || !["paid", "success"].includes(data.status)) continue;
        const key = data.entitlement_key;
        const expiry = data.subscription_expires_at;
        if (typeof key !== "string" || !expiry?.toDate || expiry.toDate() <= new Date()) continue;
        if (!entitlements[key] || expiry.toMillis() > entitlements[key].expiry.toMillis()) {
          entitlements[key] = { plan: data.plan || "premium", status: "active", expiry };
        }
      }
      if (!Object.keys(entitlements).length) return;
      t.update(snapshot.ref, { entitlements, updated_at: admin.firestore.FieldValue.serverTimestamp() });
      for (const key of Object.keys(entitlements)) {
        t.set(db.collection("provisioning_outbox").doc(`restore_${uid}_${key}`), {
          uid, email: user.email, entitlement_key: key, action: "add", status: "pending", attempts: 0,
          created_at: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
    });
    return null;
  });

// ================================================================
// FUNCTION 4: dailyRevoke (Cron Job — tiap tengah malam)
// ================================================================
export const dailyRevoke = functions
  .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com", timeoutSeconds: 300 })
  .pubsub.schedule("0 0 * * *").timeZone("Asia/Jakarta")
  .onRun(async () => {
    let cursor: FirebaseFirestore.QueryDocumentSnapshot | undefined;
    while (true) {
      let query = db.collection("users").orderBy(admin.firestore.FieldPath.documentId()).limit(100);
      if (cursor) query = query.startAfter(cursor);
      const page = await query.get();
      if (page.empty) break;
      for (const doc of page.docs) {
        await db.runTransaction(async t => {
          const snap = await t.get(doc.ref);
          if (!snap.exists) return;
          const data = snap.data()!;
          const entitlements = { ...(data.entitlements || {}) };
          const expired: string[] = [];
          for (const [key, value] of Object.entries(entitlements)) {
            const ent = value as any;
            const expiry = ent?.expiry?.toDate ? ent.expiry.toDate() : new Date(ent?.expiry ?? "");
            if (ent?.status === "active" && expiry <= new Date()) {
              entitlements[key] = { ...ent, status: "expired" };
              expired.push(key);
            }
          }
          const legacyExpiry = data.subscription_expiry?.toDate
            ? data.subscription_expiry.toDate() : new Date(data.subscription_expiry ?? "");
          const legacyExpired = ["all_access", "all_ai_1m", "all_ai_6m", "all_ai_1y", "full"].includes(data.plan)
            && legacyExpiry <= new Date();
          if (!expired.length && !legacyExpired) return;
          const update: any = { entitlements, updated_at: admin.firestore.FieldValue.serverTimestamp() };
          if (legacyExpired) { update.plan = "trial"; update.subscription_expiry = null; expired.push("all_access"); }
          t.update(doc.ref, update);
          for (const key of new Set(expired)) {
            t.set(db.collection("provisioning_outbox").doc(`reconcile_${doc.id}_${key}_${crypto.randomUUID()}`), {
              uid: doc.id, email: data.email || "", entitlement_key: key,
              action: "remove", status: "pending", attempts: 0,
              created_at: admin.firestore.FieldValue.serverTimestamp(),
            });
          }
        });
      }
      cursor = page.docs[page.docs.length - 1];
    }
    return null;
  });

// ================================================================
// FUNCTION 4b: processProvisioningOutbox (Cron Worker — tiap 5 menit)
// Memproses antrean durable outbox provisioning & revocation NotebookLM
// ================================================================
const PROVISIONED_KEYS = ["fiqh_tahawwulat", "fiqh_syafii", "ushul_fiqh", "hadits", "tafsir", "nahwu"];

function entitlementRevision(data: any): string {
  return JSON.stringify([data?.plan, data?.subscription_expiry, data?.entitlements]);
}

export const processProvisioningOutbox = functions
  .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com", timeoutSeconds: 300 })
  .pubsub.schedule("every 5 minutes")
  .onRun(async () => {
    const started = Date.now();
    const pending = await db.collection("provisioning_outbox")
      .where("status", "in", ["pending", "retry", "processing"]).limit(25).get();
    for (const candidate of pending.docs) {
      if (Date.now() - started > 210000) break;
      const token = crypto.randomUUID();
      const uid = candidate.data().uid;
      if (typeof uid !== "string" || !uid) {
        await candidate.ref.update({status:"failed",error:"Missing owner UID"});
        continue;
      }
      const lease = db.collection("provisioning_leases").doc(uid);
      const job = await db.runTransaction(async t => {
        const snap = await t.get(candidate.ref);
        const lock = await t.get(lease);
        const data = snap.data();
        if (!data || !["pending", "retry", "processing"].includes(data.status)) return null;
        if ((lock.data()?.until?.toMillis?.() || 0) > Date.now()) return null;
        if ((data.attempts || 0) >= 8) {
          t.update(candidate.ref, {status:"failed",error:"Exceeded retry limit"});
          return null;
        }
        t.set(lease, {token, until:admin.firestore.Timestamp.fromMillis(Date.now()+330000)});
        t.update(candidate.ref, {status:"processing",attempts:(data.attempts||0)+1,lease_token:token});
        return data;
      });
      if (!job) continue;
      let status = "completed";
      let error = "";
      try {
        const user = await db.collection("users").doc(uid).get();
        const data = user.data();
        const email = (data?.email || job.email || "").trim().toLowerCase();
        if (!email.includes("@")) throw new Error("Invalid provisioning email");
        const scope = job.entitlement_key;
        const keys = scope === "all_access" || scope === "all_ai" ? PROVISIONED_KEYS : [scope];
        for (const key of keys) {
          if (!PROVISIONED_KEYS.includes(key)) throw new Error("Unsupported provisioning scope");
          const desired = data && getEntitlementAccess(data,key).active;
          await notifySubscriptionServer(email,data?.name||job.name||"Peneliti",desired ? "premium" : "trial",
            desired ? "add" : "remove",getServiceTitleForEntitlement(key));
        }
        const after = await db.collection("users").doc(uid).get();
        if (entitlementRevision(data) !== entitlementRevision(after.data())) {
          status = "retry";
          error = "Entitlements changed during delivery";
        }
      } catch (err: any) {
        status = "retry";
        error = String(err.message || "Provisioning failure").slice(0,300);
      }
      await db.runTransaction(async t => {
        const lock = await t.get(lease);
        const snap = await t.get(candidate.ref);
        if (lock.data()?.token !== token || snap.data()?.lease_token !== token) return;
        t.update(candidate.ref, {status,last_error:error,last_attempt_at:admin.firestore.FieldValue.serverTimestamp()});
        t.delete(lease);
      });
    }
    return null;
  });

// ================================================================
// FUNCTION 4c: cleanupOrphanedDeletions (Cron Harian — jam 03.00 WIB)
// Membersihkan dokumen user yang bertanda pending_deletion jika akun Auth sudah terhapus
// ================================================================
async function deleteUserData(uid: string, authEmail = ""): Promise<void> {
  const ref = db.collection("users").doc(uid);
  await db.runTransaction(async t => {
    const user = await t.get(ref);
    const email = authEmail || user.data()?.email || "";
    const jobs = [];
    for (const key of PROVISIONED_KEYS) {
      const job = db.collection("provisioning_outbox").doc(`delete_${uid}_${key}`);
      jobs.push({ref:job,snap:await t.get(job),key});
    }
    if (user.exists) t.update(ref,{account_deleted:true});
    for (const job of jobs) {
      if (job.snap.exists) continue;
      t.set(job.ref, {uid,email,entitlement_key:job.key,action:"remove",status:"pending",attempts:0,
        created_at:admin.firestore.FieldValue.serverTimestamp()});
    }
  });
  await db.recursiveDelete(ref);
}

export const onUserDeleted = functions
  .runWith({ serviceAccount:"open-turath@appspot.gserviceaccount.com",timeoutSeconds:300,failurePolicy:true })
  .auth.user().onDelete(async user => {
    await deleteUserData(user.uid,user.email || "");
  });

export const cleanupOrphanedDeletions = functions
  .runWith({ serviceAccount:"open-turath@appspot.gserviceaccount.com",timeoutSeconds:300 })
  .pubsub.schedule("0 3 * * *").timeZone("Asia/Jakarta")
  .onRun(async () => {
    const pending = await db.collection("users").where("pending_deletion","==",true).limit(50).get();
    for (const doc of pending.docs) {
      try { await admin.auth().getUser(doc.id); }
      catch (err: any) {
        if (err.code === "auth/user-not-found") await deleteUserData(doc.id);
        else throw err;
      }
    }
    return null;
  });

// ================================================================
// HELPER: Notify openturath-subscription Cloud Run server
// ================================================================
async function notifySubscriptionServer(
  email: string,
  name: string,
  plan: string,
  action: "add" | "remove",
  serviceName?: string
) {
  const url = "https://openturath-subscription-255541559800.asia-southeast2.run.app/webhook";
  const services = serviceName
    ? [serviceName]
    : [
        "AI Fikih Tahawwulat",
        "AI Fikih Syafi'i",
        "AI Ushul Fiqih",
        "AI Hadits",
        "AI Tafsir",
        "AI Bahasa Arab",
      ];

  for (const service of services) {
    const payload = {
      event: action === "add" ? "subscription.paid" : "subscription.expired",
      data: {
        status: action === "add" ? "PAID" : "EXPIRED",
        payer: {
          name: name,
          email: email,
        },
        service: {
          name: service,
        },
      },
    };

    try {
      const internalSecret = process.env.INTERNAL_SECRET || "";
      if (!internalSecret) {
        throw new Error("INTERNAL_SECRET is not configured");
      }
      await axios.post(url, payload, {
        headers: {
          "Content-Type": "application/json",
          "X-Internal-Secret": internalSecret
        },
        timeout: 10000,
        maxRedirects: 0,
      });
      console.log(`Successfully notified subscription server: ${action} ${email} for ${service}`);
    } catch (err: any) {
      console.error(`Provisioning request failed for ${service}`);
      throw err;
    }
  }
}

// ================================================================
// FUNCTION 5: chatGate (Auth Gate + Iframe for NotebookLM)
// ================================================================

const AGENTS: Record<string, { notebookId: string; akalCuid: string; label: string; entitlementKey: string }> = {
  "fikih-tahawwulat-muhaqqiq": {
    notebookId: "dc7ee7e4-f4ad-4db6-9cd0-0013727abbe4",
    akalCuid: "cmln2i27k0000jx047oabzw8p",
    label: "AI Fikih Tahawwulat (Al-Muhaqqiq)",
    entitlementKey: "fiqh_tahawwulat"
  },
  "fikih-tahawwulat-bayan": {
    notebookId: "483d0291-0a70-411c-bff0-f1ea4b83b2fd",
    akalCuid: "cmln2i27k0000jx047oabzw8p",
    label: "AI Fikih Tahawwulat (Al-Bayan)",
    entitlementKey: "fiqh_tahawwulat"
  },
  "fikih-syafii": {
    notebookId: "334e7b83-0e76-4787-a1d6-314642a35862",
    akalCuid: "cms4ls3j60001l20439k1nph4",
    label: "Super AI Fikih Syafi'i",
    entitlementKey: "fiqh_syafii"
  },
  "fikih-syafii-muhaqqiq": {
    notebookId: "334e7b83-0e76-4787-a1d6-314642a35862",
    akalCuid: "cms4ls3j60001l20439k1nph4",
    label: "Super AI Fikih Syafi'i",
    entitlementKey: "fiqh_syafii"
  },
  "nahwu-sharaf-muerib": {
    notebookId: "15bc4cef-4b94-4241-b05a-d50a586bde06",
    akalCuid: "cmnd7l4o60002l504ab6qq31x",
    label: "AI Bahasa Arab (Al-Mu'rib)",
    entitlementKey: "nahwu"
  },
  "nahwu-sharaf-tashrif": {
    notebookId: "15bc4cef-4b94-4241-b05a-d50a586bde06",
    akalCuid: "cmnd7l4o60002l504ab6qq31x",
    label: "AI Bahasa Arab (Tashrif)",
    entitlementKey: "nahwu"
  }
};

const COOKIE_NAME = "ot_session";
const COOKIE_MAX_AGE = 8 * 60 * 60; // 8 jam dalam detik

function getWebSessionSecret(): string {
  // Prefer environment variables, but retain compatibility with older
  // Firebase Runtime Config deployments while the secret is migrated.
  const runtimeConfigSecret = functions.config().web?.session_secret;
  return process.env.WEB_SESSION_SECRET || runtimeConfigSecret || "";
}

function getAkalApiKey(): string {
  const runtimeConfigKey = functions.config().akal?.api_key;
  return process.env.AKAL_API_KEY || runtimeConfigKey || "";
}

function resolveAgentRef(value: unknown): string {
  return typeof value === "string" && AGENTS[value]
    ? value
    : "fikih-tahawwulat-muhaqqiq";
}

function clearSessionCookie(res: functions.Response): void {
  res.setHeader(
    "Set-Cookie",
    `${COOKIE_NAME}=; Path=/; HttpOnly; Secure; SameSite=Strict; Max-Age=0`
  );
}

export const chatGate = functions
  .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com" })
  .https.onRequest(async (req, res) => {
    const sessionSecret = getWebSessionSecret();
    if (!sessionSecret) {
      console.error("WEB_SESSION_SECRET is not configured; web access is disabled.");
      res.status(503).send("Layanan web sedang tidak tersedia. Silakan gunakan aplikasi OpenTurath.");
      return;
    }

    // Normalize path
    let path = req.path || "";
    if (path.endsWith("/") && path.length > 1) {
      path = path.slice(0, -1);
    }

    const ref = resolveAgentRef(req.query.ref);

    if (path === "/" || path === "") {
      res.redirect(`/login?ref=${encodeURIComponent(ref)}`);
      return;
    }

    if (path === "/login") {
      if (req.method === "GET") {
        const error = typeof req.query.error === "string" ? req.query.error : "";
        res.setHeader("Content-Type", "text/html;charset=UTF-8");
        res.send(getLoginHTML(ref, generateCsrfToken(sessionSecret), error));
        return;
      }

      if (req.method === "POST") {
        await handleLogin(req, res, sessionSecret, getAkalApiKey());
        return;
      }

      res.status(405).send("Method Not Allowed");
      return;
    }

    if (path === "/logout") {
      clearSessionCookie(res);
      res.redirect(`/login?ref=${encodeURIComponent(ref)}`);
      return;
    }

    // ROUTE: GET /chat/:agentId
    const chatMatch = path.match(/^\/chat\/([a-zA-Z0-9-]+)$/);
    if (chatMatch) {
      const agentId = chatMatch[1];
      const agent = AGENTS[agentId];

      if (!agent) {
        res.status(404).send("Agent tidak ditemukan.");
        return;
      }

      const session = verifySessionCookie(req.headers.cookie || "", sessionSecret);
      if (!session) {
        res.redirect(`/login?ref=${encodeURIComponent(agentId)}`);
        return;
      }

      // Re-check the local entitlement on each initial page request. This
      // prevents an old session cookie from bypassing expiry/revocation.
      const hasAccess = await verifySubscriptionFirestore(
        session.email,
        agent.entitlementKey,
        session.uid
      );
      if (!hasAccess) {
        clearSessionCookie(res);
        res.redirect(`/login?ref=${encodeURIComponent(agentId)}&error=not_found`);
        return;
      }

      res.setHeader("Content-Type", "text/html;charset=UTF-8");
      res.send(getChatWrapperHTML(agent, agentId, session.email));
      return;
    }

    res.status(404).send("Not Found");
  });

// ── HELPERS FOR CHAT GATE ──

async function handleLogin(req: functions.Request, res: functions.Response, secret: string, apiKey: string) {
  const idToken = (req.body.id_token as string || (req.headers.authorization ? req.headers.authorization.split("Bearer ")[1] : "") || "").trim();
  const csrfTokenForm = req.body.csrf_token as string || "";
  const ref = req.body.ref as string || "fikih-tahawwulat-muhaqqiq";

  if (!verifyCsrfToken(csrfTokenForm, secret)) {
    res.redirect(`/login?ref=${ref}&error=invalid_request`);
    return;
  }

  // Wajib memiliki idToken terverifikasi dari Firebase Authentication
  if (!idToken) {
    res.redirect(`/login?ref=${ref}&error=auth_required`);
    return;
  }

  let email = "";
  let uid = "";
  try {
    const decodedToken = await admin.auth().verifyIdToken(idToken, true);
    uid = decodedToken.uid;
    email = (decodedToken.email || "").trim().toLowerCase();
    if (!email || decodedToken.email_verified !== true) {
      res.redirect(`/login?ref=${ref}&error=unverified_email`);
      return;
    }
  } catch (err: any) {
    console.error(`[Auth] Gagal memverifikasi idToken Firebase: ${err.message}`);
    res.redirect(`/login?ref=${ref}&error=invalid_token`);
    return;
  }

  const agent = AGENTS[ref] || AGENTS["fikih-tahawwulat-muhaqqiq"];
  const akalCuid = agent.akalCuid;
  const entitlementKey = agent.entitlementKey || "fiqh_tahawwulat";

  const isSubscriber = await verifySubscriptionFirestore(email, entitlementKey, uid);

  if (isSubscriber) {
    const payload = JSON.stringify({ uid, email, iat: Date.now() });
    const payloadB64 = Buffer.from(payload).toString("base64url");
    const sig = crypto.createHmac("sha256", secret).update(payloadB64).digest("base64url");
    const sessionCookie = `${payloadB64}.${sig}`;

    res.setHeader("Set-Cookie", `${COOKIE_NAME}=${sessionCookie}; Path=/; HttpOnly; Secure; SameSite=Strict; Max-Age=${COOKIE_MAX_AGE}`);
    res.redirect(`/chat/${ref}`);
  } else {
    res.redirect(`/login?ref=${ref}&error=not_found`);
  }
}

async function verifySubscriptionHybrid(email: string, entitlementKey: string, serviceCuid: string, apiKey: string): Promise<boolean> {
  // 1. Check local Firestore first (respects manual overrides, bonuses, and active firestore state)
  try {
    const localActive = await verifySubscriptionFirestore(email, entitlementKey);
    if (localActive) {
      console.log(`[Auth] User ${email} verified active locally via Firestore for entitlement '${entitlementKey}'`);
      return true;
    }
  } catch (err: any) {
    console.error(`[Auth] Firestore subscription check failed: ${err.message}`);
  }

  // 2. Fallback to querying GoAkal API directly
  console.log(`[Auth] User ${email} not verified locally. Falling back to GoAkal API...`);
  return await verifyAkalSubscription(email, serviceCuid, apiKey);
}

async function verifySubscriptionFirestore(email: string, entitlementKey: string, uid?: string): Promise<boolean> {
  // Web authorization must carry a verified UID. Billing history is not identity.
  if (!uid) return false;
  const user = await db.collection("users").doc(uid).get();
  if (!user.exists) return false;
  const data = user.data()!;
  if (typeof data.email !== "string" || data.email.toLowerCase() !== email.toLowerCase()) return false;
  return getEntitlementAccess(data, entitlementKey).active;
}

async function verifyAkalSubscription(email: string, serviceCuid: string, apiKey: string): Promise<boolean> {
  const statuses = ["PAID", "SETTLED"];

  for (const status of statuses) {
    let page = 1;
    const maxPages = 5;

    while (page <= maxPages) {
      const apiUrl = `https://goakal.com/service/api/v1/services/${serviceCuid}/transactions?status=${status}&pageSize=100&page=${page}`;

      try {
        const response = await axios.get(apiUrl, {
          headers: { "X-Api-Key": apiKey }
        });

        const result = response.data;
        const txns = result.data || [];

        if (txns.length === 0) break;

        const now = new Date();
        const activeTxn = txns.find((t: any) => {
          if (!t.payerEmail) return false;
          if (t.payerEmail.trim().toLowerCase() !== email) return false;

          if (t.expiryDate) {
            return new Date(t.expiryDate) > now;
          }

          const startStr = t.paidAt || t.createdAt;
          if (!startStr) return false;

          const startDate = new Date(startStr);
          const durationMonths = detectDurationMonths(t.priceSchemeTitle || "", t.serviceTitle || "");
          const expiry = new Date(startDate);
          expiry.setMonth(expiry.getMonth() + durationMonths);

          return expiry > now;
        });

        if (activeTxn) return true;
        if (txns.length < 100) break;
        page++;
      } catch (e: any) {
        console.error(`Akal API fetch error: ${e.message}`);
        break;
      }
    }
  }
  return false;
}

function detectDurationMonths(priceSchemeTitle: string, serviceTitle: string): number {
  const s = (priceSchemeTitle + " " + serviceTitle).toLowerCase();
  if (s.includes("tahun") || s.includes("1y") || s.includes("year") || s.includes("annual")) return 12;
  if (s.includes("6 bulan") || s.includes("6m")) return 6;
  return 1;
}

function verifySessionCookie(cookieHeader: string, secret: string): { uid: string; email: string } | null {
  if (!cookieHeader) return null;

  const cookies: Record<string, string> = {};
  cookieHeader.split(";").forEach(c => {
    const parts = c.trim().split("=");
    if (parts.length >= 2) {
      cookies[parts[0]] = parts.slice(1).join("=");
    }
  });

  const cookieValue = cookies[COOKIE_NAME];
  if (!cookieValue) return null;

  const parts = cookieValue.split(".");
  if (parts.length !== 2) return null;

  const [payloadB64, sigB64] = parts;

  try {
    const expectedSig = crypto.createHmac("sha256", secret).update(payloadB64).digest("base64url");
    if (!safeTimingEqual(sigB64, expectedSig)) return null;

    const payloadStr = Buffer.from(payloadB64, "base64url").toString("utf8");
    const payload = JSON.parse(payloadStr);

    if (typeof payload.uid !== "string" || !payload.uid ||
        typeof payload.email !== "string" || !Number.isFinite(payload.iat) ||
        payload.iat > Date.now() + 60000 || Date.now() - payload.iat > COOKIE_MAX_AGE * 1000) return null;
    return { uid: payload.uid, email: payload.email };
  } catch {
    return null;
  }
}

function generateCsrfToken(secret: string): string {
  const ts = Date.now().toString();
  const signature = crypto.createHmac("sha256", secret).update(ts).digest("base64url");
  return `${ts}.${signature}`;
}

function verifyCsrfToken(token: string, secret: string): boolean {
  if (!token) return false;
  const parts = token.split(".");
  if (parts.length !== 2) return false;
  const [ts, signature] = parts;
  const tsNum = parseInt(ts, 10);
  if (isNaN(tsNum) || Date.now() - tsNum > 3600 * 1000) return false; // 1 jam

  const expectedSig = crypto.createHmac("sha256", secret).update(ts).digest("base64url");
  return signature === expectedSig;
}

function escapeHtml(str: string): string {
  return String(str)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#x27;");
}

function maskEmail(email: string): string {
  if (!email || !email.includes("@")) return email;
  const [local, domain] = email.split("@");
  const masked = local[0] + "***";
  return `${masked}@${domain}`;
}

// ── HTML TEMPLATES ──

function getLoginHTML(ref: string, csrfToken: string, error: string): string {
  const errorMessages: Record<string, string> = {
    not_found: "Email ini tidak terdaftar sebagai pelanggan aktif. Pastikan email sesuai dengan yang digunakan di Akal.",
    invalid_email: "Format email tidak valid.",
    invalid_request: "Permintaan tidak valid. Silakan coba lagi.",
  };
  const errorHTML = error && errorMessages[error]
    ? `<div class="error-box">${errorMessages[error]}</div>`
    : "";

  return `<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>OpenTurath AI — Login</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;600;700&display=swap" rel="stylesheet">
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      background: #0a0e17;
      color: #c9d1d9;
      font-family: 'Outfit', sans-serif;
      display: flex; flex-direction: column;
      justify-content: center; align-items: center;
      min-height: 100vh;
      background-image: radial-gradient(ellipse at 20% 50%, rgba(212,175,55,0.07) 0%, transparent 60%),
                        radial-gradient(ellipse at 80% 20%, rgba(212,175,55,0.04) 0%, transparent 50%);
    }
    .logo {
      font-size: 13px;
      letter-spacing: 3px;
      text-transform: uppercase;
      color: rgba(212,175,55,0.6);
      margin-bottom: 10px;
    }
    h1 {
      font-size: 28px;
      font-weight: 700;
      color: #D4AF37;
      margin-bottom: 6px;
      text-align: center;
    }
    .subtitle {
      font-size: 14px;
      color: rgba(255,255,255,0.4);
      margin-bottom: 36px;
      text-align: center;
    }
    .card {
      background: rgba(255,255,255,0.03);
      border: 1px solid rgba(212,175,55,0.2);
      padding: 36px 32px;
      border-radius: 20px;
      box-shadow: 0 20px 60px rgba(0,0,0,0.5), 0 0 0 1px rgba(212,175,55,0.05);
      width: 360px;
      backdrop-filter: blur(12px);
    }
    label { font-size: 13px; color: rgba(255,255,255,0.5); display: block; margin-bottom: 8px; }
    input[type="email"] {
      width: 100%;
      padding: 13px 16px;
      margin-bottom: 20px;
      border-radius: 10px;
      border: 1px solid rgba(255,255,255,0.1);
      background: rgba(0,0,0,0.25);
      color: #fff;
      font-size: 15px;
      font-family: inherit;
      outline: none;
      transition: border-color 0.2s;
    }
    input[type="email"]:focus { border-color: rgba(212,175,55,0.5); }
    button[type="submit"] {
      width: 100%;
      padding: 13px;
      background: linear-gradient(135deg, #D4AF37, #a8872b);
      color: #000;
      border: none;
      border-radius: 10px;
      font-size: 15px;
      font-weight: 700;
      font-family: inherit;
      cursor: pointer;
      transition: opacity 0.2s, transform 0.1s;
    }
    button[type="submit"]:hover { opacity: 0.9; transform: translateY(-1px); }
    button[type="submit"]:active { transform: translateY(0); }
    .error-box {
      background: rgba(220,60,60,0.12);
      border: 1px solid rgba(220,60,60,0.3);
      border-radius: 8px;
      padding: 12px 14px;
      font-size: 13px;
      color: #ff9090;
      margin-bottom: 20px;
      line-height: 1.5;
    }
    .footer { margin-top: 24px; font-size: 12px; color: rgba(255,255,255,0.2); text-align: center; }
  </style>
</head>
<body>
  <div class="logo">OpenTurath</div>
  <h1>Ruang Kajian</h1>
  <p class="subtitle">Masukkan email akun Anda</p>
  <div class="card">
    ${errorHTML}
    <form method="POST" action="/login">
      <input type="hidden" name="ref" value="${escapeHtml(ref)}">
      <input type="hidden" name="csrf_token" value="${escapeHtml(csrfToken)}">
      <label for="email">Alamat Email</label>
      <input type="email" id="email" name="email" placeholder="nama@email.com" required autocomplete="email">
      <button type="submit">Buka ruang kajian →</button>
    </form>
  </div>
  <p class="footer">Belum berlangganan? Buka langganan melalui aplikasi OpenTurath</p>
</body>
</html>`;
}

function getChatWrapperHTML(agent: any, agentId: string, email: string): string {
  const chatUrl = `https://notebooklm.google.com/notebook/${agent.notebookId}/preview`;
  let descHtml = "";
  let promptsHtml = "";

  if (agentId === "fiqh_tahawwulat") {
    descHtml = `<p>Kajian **Fikih Tahawwulat** menelaah kaidah tanda zaman dan perubahan peradaban berdasarkan kitab-kitab rujukan.</p>`;
    promptsHtml = `
      <div class="prompt-item" onclick="copyPrompt('Bagaimana penjelasan al-ghutsā\\'iyyah dalam kitab?')">
        Penjelasan al-ghutsā'iyyah 📋
      </div>
      <div class="prompt-item" onclick="copyPrompt('Apa yang dimaksud Rukun Keempat dalam Fikih Tahawwulat?')">
        Rukun Keempat Fikih Tahawwulat 📋
      </div>
      <div class="prompt-item" onclick="copyPrompt('Bagaimana para ulama menjelaskan sikap saat masa fitnah?')">
        Sikap saat masa fitnah 📋
      </div>
    `;
  } else if (agentId === "fiqh_syafii") {
    descHtml = `<p>Kajian **Fikih Syafi'i** menelaah masalah ibadah, muamalah, dan fatwa para ulama mazhab Syafi'i dari kitab-kitab mu'tamad.</p>`;
    promptsHtml = `
      <div class="prompt-item" onclick="copyPrompt('Apa rukun wudu menurut pendapat mu\\'tamad dalam mazhab Syafi\\'i?')">
        Rukun wudu mu'tamad Syafi'i 📋
      </div>
      <div class="prompt-item" onclick="copyPrompt('Apa syarat sah salat berjamaah menurut Minhāj al-Ṭālibīn?')">
        Syarat salat berjamaah di Minhāj 📋
      </div>
      <div class="prompt-item" onclick="copyPrompt('Bagaimana ketentuan zakat perdagangan menurut Imam al-Nawawi?')">
        Zakat perdagangan menurut al-Nawawi 📋
      </div>
    `;
  } else if (agentId === "hadits") {
    descHtml = `<p>Kajian **Hadis & Syarah** memuat kitab-kitab hadis induk dan syarahnya untuk memeriksa matan, sanad, dan faedah hukum.</p>`;
    promptsHtml = `
      <div class="prompt-item" onclick="copyPrompt('Bagaimana penjelasan hadis tentang niat dalam Fatḥ al-Bārī?')">
        Penjelasan hadis niat di Fatḥ al-Bārī 📋
      </div>
      <div class="prompt-item" onclick="copyPrompt('Bagaimana menilai sanad riwayat ini?')">
        Penilaian sanad riwayat 📋
      </div>
    `;
  } else {
    descHtml = `<p>Kajian **${escapeHtml(agent.label || "Kitab")}** membantu menelaah kitab-kitab rujukan keilmuan Islam.</p>`;
    promptsHtml = `
      <div class="prompt-item" onclick="copyPrompt('Apa pokok bahasan dalam bab ini?')">
        Pokok bahasan bab 📋
      </div>
      <div class="prompt-item" onclick="copyPrompt('Apa perbedaan pendapat ulama dalam masalah ini?')">
        Perbedaan pendapat ulama 📋
      </div>
    `;
  }

  return `<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${escapeHtml(agent.label)} — OpenTurath AI</title>
  <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700&display=swap" rel="stylesheet">
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    html, body { height: 100%; overflow: hidden; font-family: 'Outfit', sans-serif; background: #0a0e17; color: #ffffff; }

    /* ── Top Bar ── */
    .topbar {
      height: 48px;
      background: #0f1422;
      border-bottom: 1px solid rgba(212,175,55,0.15);
      display: flex;
      align-items: center;
      padding: 0 20px;
      gap: 16px;
      position: relative;
      z-index: 110;
    }
    .menu-toggle {
      display: none;
      background: none;
      border: none;
      color: #D4AF37;
      font-size: 22px;
      cursor: pointer;
      padding: 4px;
    }
    .topbar-brand {
      display: flex;
      align-items: center;
      gap: 10px;
    }
    .topbar-brand .dot {
      width: 8px; height: 8px;
      border-radius: 50%;
      background: #D4AF37;
      box-shadow: 0 0 8px rgba(212,175,55,0.8);
    }
    .topbar-brand .name {
      font-size: 15px;
      font-weight: 700;
      color: #D4AF37;
      letter-spacing: 0.5px;
    }
    .topbar-agent {
      font-size: 12px;
      color: rgba(255,255,255,0.35);
      border-left: 1px solid rgba(255,255,255,0.1);
      padding-left: 16px;
    }
    
    /* ── Dashboard Layout ── */
    .dashboard-container {
      display: flex;
      height: calc(100vh - 48px);
      width: 100%;
      position: relative;
    }

    /* Left Sidebar */
    .sidebar-left {
      width: 250px;
      background: #0f1422;
      border-right: 1px solid rgba(212,175,55,0.15);
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      padding: 20px 16px;
      z-index: 100;
      transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    }
    .sidebar-section {
      display: flex;
      flex-direction: column;
      gap: 16px;
    }
    .section-title {
      font-size: 11px;
      font-weight: 700;
      color: rgba(255,255,255,0.3);
      letter-spacing: 1px;
      text-transform: uppercase;
      margin-bottom: 4px;
    }
    .menu-list {
      display: flex;
      flex-direction: column;
      gap: 6px;
    }
    .menu-item {
      display: flex;
      align-items: center;
      gap: 10px;
      padding: 10px 12px;
      border-radius: 8px;
      color: rgba(255,255,255,0.65);
      text-decoration: none;
      font-size: 13px;
      font-weight: 500;
      transition: all 0.2s;
      border: 1px solid transparent;
    }
    .menu-item:hover {
      background: rgba(255,255,255,0.03);
      color: #ffffff;
    }
    .menu-item.active {
      background: rgba(212,175,55,0.08);
      color: #D4AF37;
      border-color: rgba(212,175,55,0.15);
      font-weight: 600;
    }
    
    /* User Profile Card */
    .user-card {
      background: rgba(255,255,255,0.02);
      border: 1px solid rgba(255,255,255,0.05);
      border-radius: 12px;
      padding: 14px;
      display: flex;
      flex-direction: column;
      gap: 12px;
    }
    .user-info {
      display: flex;
      flex-direction: column;
      gap: 2px;
    }
    .user-email {
      font-size: 12px;
      font-weight: 600;
      color: rgba(255,255,255,0.85);
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }
    .user-status {
      font-size: 10px;
      color: #D4AF37;
      display: flex;
      align-items: center;
      gap: 6px;
    }
    .status-dot {
      width: 6px; height: 6px;
      background: #D4AF37;
      border-radius: 50%;
      box-shadow: 0 0 6px #D4AF37;
    }
    .btn-logout {
      display: block;
      width: 100%;
      text-align: center;
      padding: 8px;
      background: rgba(212,175,55,0.1);
      border: 1px solid rgba(212,175,55,0.2);
      border-radius: 6px;
      color: #D4AF37;
      text-decoration: none;
      font-size: 11px;
      font-weight: 600;
      transition: all 0.2s;
    }
    .btn-logout:hover {
      background: rgba(212,175,55,0.2);
      border-color: rgba(212,175,55,0.3);
    }

    /* Right Sidebar */
    .sidebar-right {
      width: 280px;
      background: #0f1422;
      border-left: 1px solid rgba(212,175,55,0.15);
      padding: 20px 16px;
      display: flex;
      flex-direction: column;
      gap: 20px;
      overflow-y: auto;
      z-index: 100;
    }
    .desc-box {
      font-size: 12px;
      line-height: 1.6;
      color: rgba(255,255,255,0.5);
      background: rgba(255,255,255,0.01);
      padding: 14px;
      border-radius: 10px;
      border: 1px solid rgba(255,255,255,0.03);
    }
    .desc-box strong { color: rgba(255,255,255,0.8); }
    .prompt-list {
      display: flex;
      flex-direction: column;
      gap: 10px;
    }
    .prompt-item {
      padding: 12px;
      background: rgba(255,255,255,0.02);
      border: 1px solid rgba(255,255,255,0.05);
      border-radius: 8px;
      font-size: 12px;
      line-height: 1.5;
      color: rgba(255,255,255,0.7);
      cursor: pointer;
      transition: all 0.2s;
    }
    .prompt-item:hover {
      background: rgba(212,175,55,0.05);
      border-color: rgba(212,175,55,0.25);
      color: #D4AF37;
    }
    
    .btn-help {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 8px;
      padding: 10px;
      background: #25d366;
      color: #ffffff;
      border-radius: 8px;
      font-size: 12px;
      font-weight: 600;
      text-decoration: none;
      transition: opacity 0.2s;
    }
    .btn-help:hover { opacity: 0.9; }

    .btn-full-tab {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 8px;
      padding: 12px;
      background: linear-gradient(135deg, #D4AF37, #a8872b);
      color: #000000;
      border-radius: 8px;
      font-size: 12px;
      font-weight: 700;
      text-decoration: none;
      transition: all 0.2s;
      box-shadow: 0 4px 10px rgba(212,175,55,0.2);
      margin-top: 10px;
    }
    .btn-full-tab:hover {
      opacity: 0.9;
      transform: translateY(-1px);
    }

    /* Center Chat Area */
    .chat-area {
      flex: 1;
      height: 100%;
      background: #0a0e17;
      position: relative;
    }
    iframe {
      width: 100%;
      height: 100%;
      border: none;
      display: block;
    }

    /* Toast Alert */
    .toast {
      position: fixed;
      bottom: 24px;
      left: 50%;
      transform: translateX(-50%) translateY(100px);
      background: rgba(212,175,55,0.95);
      color: #0a0e17;
      padding: 10px 20px;
      border-radius: 8px;
      font-size: 13px;
      font-weight: 600;
      transition: transform 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
      z-index: 1000;
      box-shadow: 0 4px 12px rgba(0,0,0,0.5);
      pointer-events: none;
    }
    .toast.show {
      transform: translateX(-50%) translateY(0);
    }

    /* ── Responsive Styling ── */
    @media (max-width: 991px) {
      .menu-toggle {
        display: block;
      }
      .sidebar-right {
        display: none;
      }
      .sidebar-left {
        position: fixed;
        top: 48px;
        left: -250px;
        height: calc(100% - 48px);
        box-shadow: 10px 0 30px rgba(0,0,0,0.5);
      }
      .sidebar-left.open {
        left: 0;
      }
    }
  </style>
</head>
<body>
  <div class="topbar">
    <button class="menu-toggle" onclick="toggleSidebar()">☰</button>
    <div class="topbar-brand">
      <div class="dot"></div>
      <div class="name">OpenTurath AI</div>
    </div>
    <span class="topbar-agent" id="topbar-agent-label">${escapeHtml(agent.label)}</span>
  </div>
  
  <div class="dashboard-container">
    <!-- Left Sidebar -->
    <aside class="sidebar-left" id="sidebar-left">
      <div class="sidebar-section">
        <div class="section-title">Pilih Kajian</div>
        <nav class="menu-list">
          <a href="/chat/fikih-tahawwulat-muhaqqiq" class="menu-item ${agentId === 'fikih-tahawwulat-muhaqqiq' ? 'active' : ''}">
            <span>📗</span> AI Fikih (Al-Muhaqqiq)
          </a>
          <a href="/chat/fikih-tahawwulat-bayan" class="menu-item ${agentId === 'fikih-tahawwulat-bayan' ? 'active' : ''}">
            <span>📘</span> AI Fikih (Al-Bayan)
          </a>
          <a href="/chat/nahwu-sharaf-muerib" class="menu-item ${agentId === 'nahwu-sharaf-muerib' ? 'active' : ''}">
            <span>📙</span> AI Nahwu (Al-Mu'rib)
          </a>
          <a href="/chat/nahwu-sharaf-tashrif" class="menu-item ${agentId === 'nahwu-sharaf-tashrif' ? 'active' : ''}">
            <span>📕</span> AI Nahwu (Tashrif)
          </a>
        </nav>
        <a href="${chatUrl}" target="_blank" class="btn-full-tab">
          Buka Layar Penuh
        </a>
      </div>

      <div class="user-card">
        <div class="user-info">
          <div class="user-status"><div class="status-dot"></div>Akun Google</div>
          <div style="font-size: 11px; color: rgba(255,255,255,0.45); margin-top: 4px; line-height: 1.4;">
            Gunakan akun Google yang memiliki akses ke ruang ini.
          </div>
        </div>
      </div>
    </aside>

    <!-- Center Chat Area (Iframe) -->
    <main class="chat-area">
      <iframe
        src="${chatUrl}"
        allow="microphone"
        title="${escapeHtml(agent.label)}"
        loading="lazy"
      ></iframe>
    </main>

    <!-- Right Sidebar -->
    <aside class="sidebar-right">
      <div class="sidebar-section">
        <div class="section-title">Tentang kajian ini</div>
        <div class="desc-box">
          ${descHtml}
        </div>
      </div>

      <div class="sidebar-section">
        <div class="section-title">Contoh pertanyaan</div>
        <div class="prompt-list">
          ${promptsHtml}
        </div>
      </div>
      
      <div style="flex-grow: 1;"></div>
      
      <a href="mailto:support@openturath.com" class="btn-help">
        💬 Bantuan
      </a>
    </aside>
  </div>

  <div id="toast" class="toast"></div>

  <script>
    // Toggle Mobile Sidebar Drawer
    function toggleSidebar() {
      document.getElementById('sidebar-left').classList.toggle('open');
    }

    // Close Mobile Sidebar Drawer when clicking outside or switching modules
    document.addEventListener('click', function(event) {
      const sidebar = document.getElementById('sidebar-left');
      const toggleBtn = document.querySelector('.menu-toggle');
      if (window.innerWidth <= 991 && sidebar.classList.contains('open')) {
        if (!sidebar.contains(event.target) && !toggleBtn.contains(event.target)) {
          sidebar.classList.remove('open');
        }
      }
    });

    // Copy prompt helper function
    function copyPrompt(text) {
      navigator.clipboard.writeText(text).then(() => {
        const toast = document.getElementById('toast');
        toast.innerText = 'Pertanyaan tersalin. Tempelkan di kolom chat.';
        toast.classList.add('show');
        setTimeout(() => toast.classList.remove('show'), 3500);
      }).catch(err => {
        console.error('Failed to copy text: ', err);
      });
    }

    // Blokir klik kanan untuk menyembunyikan URL dari context menu
    document.addEventListener('contextmenu', e => e.preventDefault());
  </script>
</body>
</html>`;
}

```



================================================================================
# BAGIAN 4: SELURUH BASIS KODE FLUTTER (openturath_ai/lib/)
================================================================================

### FLUTTER FILE: openturath_ai/lib/core/app_config.dart
```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);
  static final ValueNotifier<String> localeNotifier = ValueNotifier('id'); // 'id', 'en', 'ar'

  static const String _themeKey = 'app_theme_mode';
  static const String _localeKey = 'app_locale';

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Theme (Default: ThemeMode.system)
    final themeStr = prefs.getString(_themeKey);
    if (themeStr == 'light') {
      themeNotifier.value = ThemeMode.light;
    } else if (themeStr == 'dark') {
      themeNotifier.value = ThemeMode.dark;
    } else {
      themeNotifier.value = ThemeMode.system;
    }

    // Load Locale
    final localeStr = prefs.getString(_localeKey);
    if (localeStr != null) {
      localeNotifier.value = localeStr;
    }
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    themeNotifier.value = mode;
    final prefs = await SharedPreferences.getInstance();
    if (mode == ThemeMode.light) {
      await prefs.setString(_themeKey, 'light');
    } else if (mode == ThemeMode.dark) {
      await prefs.setString(_themeKey, 'dark');
    } else {
      await prefs.setString(_themeKey, 'system');
    }
  }

  static Future<void> setLocale(String langCode) async {
    localeNotifier.value = langCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, langCode);
  }
}

```

### FLUTTER FILE: openturath_ai/lib/core/app_copy.dart
```dart
/// AppCopy: Sumber teks kanonik terpusat untuk OpenTurath.
/// Menjaga nada bahasa tetap tenang, ringkas, jelas, dan wajar untuk kajian keislaman.
abstract final class AppCopy {
  // ── Identitas & Merek ──────────────────────────────────────────
  static const appName = 'OpenTurath';
  static const appTagline = 'Membaca kitab, menelusuri ibarah.';
  static const defaultFieldDesc = 'Beragam kajian dari kitab-kitab Islam.';
  static const aboutTitle = 'Tentang OpenTurath';
  static const aboutDescription =
      'OpenTurath membantu Anda membaca, mencari, dan membandingkan keterangan dari kitab-kitab rujukan.';
  static const aboutScholarlyPrinciple =
      'Gunakan jawaban sebagai pintu masuk untuk menelusuri ibarah. Untuk memahami dan menetapkan hukum, tetaplah merujuk kepada guru dan ulama yang berkompeten.';

  // ── Navigasi Utama ─────────────────────────────────────────────
  static const navHome = 'Beranda';
  static const navStudies = 'Asisten AI';
  static const navSaved = 'Tersimpan';
  static const navSettings = 'Pengaturan';

  // ── Istilah Ruang & Kajian ─────────────────────────────────────
  static const studySpace = 'Percakapan AI';
  static const openStudy = 'Membuka AI';
  static const studyOptions = 'Menu percakapan';
  static const referenceBooks = 'Kitab rujukan';
  static const savedCollection = 'Simpanan';
  static const bookDetails = 'Keterangan kitab';

  // ── Loading, Error & Akses ─────────────────────────────────────
  static const loadingReferences = 'Menyiapkan percakapan AI...';
  static const modulePreparing = 'sedang disiapkan.';
  static const moduleUnavailable = 'Modul ini belum dapat dibuka. Coba lagi nanti.';
  static const cannotLoad = 'Tidak dapat dimuat. Periksa koneksi, lalu coba lagi.';
  static const cannotLoadStudy = 'AI belum dapat dibuka';
  static const studyNotLoadedYet = 'Kajian belum bisa dimuat. Coba lagi sebentar.';
  static const subscriptionRequiredTitle = 'Langganan diperlukan';
  static const catalogLoadFailed = 'Daftar kitab belum bisa dimuat.';
  static const inputQuestionHint = 'Tanyakan sesuatu tentang kitab ini...';
  static const viewSubscription = 'Lihat langganan';
  static const tryAgain = 'Coba lagi';

  // Platform & Inisialisasi
  static const deviceNotSupportedTitle = 'Perangkat belum didukung';
  static const deviceNotSupportedMessage =
      'OpenTurath saat ini mendukung Android, macOS, dan Windows. Perangkat ini belum didukung.';
  static const cannotConnectTitle = 'Tidak dapat terhubung';
  static const cannotConnectMessage =
      'Tidak dapat terhubung ke layanan OpenTurath. Periksa koneksi, lalu coba lagi.';

  // ── Dialog Catatan Sebelum Mulai (Adab) ────────────────────────
  static const adabDialogTitle = 'Catatan sebelum mulai';
  static const adabAcknowledgeButton = 'Saya mengerti';

  static const adabHeading1 = 'Alat bantu, bukan pemberi fatwa';
  static const adabBody1 =
      'OpenTurath membantu mencari ibarah dan membandingkan keterangan dalam kitab. Aplikasi ini tidak menggantikan fatwa ulama.';

  static const adabHeading2 = 'Belajar tetap perlu bimbingan';
  static const adabBody2 =
      'Untuk memahami agama dengan baik, belajarlah kepada guru dan ulama yang berkompeten.';

  static const adabHeading3 = 'Periksa kembali rujukan';
  static const adabBody3 =
      'Periksa kembali dalil dan ibarah pada kitab rujukan sebelum menjadikannya pegangan.';

  // ── Umpan Balik Singkat (Toast & Snackbar) ─────────────────────
  static const noAnswerToCopy = 'Belum ada jawaban untuk disalin.';
  static const answerCopied = 'Jawaban tersalin.';
  static const copyFailed = 'Gagal menyalin. Coba lagi.';
  static const noAnswerToSave = 'Belum ada jawaban untuk disimpan.';
  static const savedSuccess = 'Tersimpan.';
  static const saveFailed = 'Gagal menyimpan. Coba lagi.';
  static const emptyAnswerCannotSave = 'Belum ada jawaban untuk disimpan.';

  // ── Simpanan / Bookmark ────────────────────────────────────────
  static const searchSavedHint = 'Cari kitab, topik, atau kutipan...';
  static const searchSavedTooltip = 'Cari simpanan';
  static const noSavedTitle = 'Belum ada simpanan';
  static const noSavedDescription =
      'Simpan jawaban atau ibarah agar mudah dibuka kembali.';
  static const copyIbarahAction = 'Salin ibarah';
  static const viewReferenceAction = 'Lihat rujukan';
  static const shareReferenceTooltip = 'Bagikan rujukan';
  static const saveAnswerMenu = 'Simpan jawaban';

  // ── Akun & Pengaturan ──────────────────────────────────────────
  static const profile = 'Profil';
  static const subscription = 'Langganan';
  static const activeSubscription = 'Langganan aktif';
  static const inactiveSubscription =
      'Belum berlangganan. Akses dibuka dengan voucher atau paket.';
  static const appearance = 'Tampilan';
  static const modeDark = 'Gelap';
  static const modeLight = 'Terang';
  static const modeSystem = 'Sistem';
  static const language = 'Bahasa';
  static const languageIndonesian = 'Bahasa Indonesia';

  static const logoutDialogTitle = 'Keluar dari akun?';
  static const logoutDialogBody = 'Anda akan keluar dari akun ini.';
  static const logoutButton = 'Keluar';

  static const deleteAccountTitle = 'Hapus akun?';
  static const deleteAccountBody =
      'Tindakan ini tidak dapat dibatalkan. Profil, simpanan, dan data akun Anda akan dihapus dari server.';
  static const deleteAccountButton = 'Hapus akun';
  static const deleteAccountSuccess = 'Akun Anda sudah dihapus.';
  static const recentLoginRequired =
      'Untuk menghapus akun, masuk ulang terlebih dahulu.';
  static const networkError = 'Koneksi bermasalah. Coba lagi.';

  // ── Helper Interpolasi Dinamis ─────────────────────────────────
  static String preparingModule(String module) => '$module sedang disiapkan.';

  static String subscriptionRequiredFor(String module) =>
      'Berlangganan untuk membuka $module.';

  static String accessUnavailableFor(String module) =>
      'Akun ini belum mendapat akses ke $module. Aktifkan langganan untuk melanjutkan.';

  static String planWithAgent(String agentTitle, String duration) =>
      '$agentTitle — $duration';
}

```

### FLUTTER FILE: openturath_ai/lib/core/app_snackbar.dart
```dart
import 'package:flutter/material.dart';

import 'theme.dart';

enum SnackType { info, success, warning, error }

class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackType type = SnackType.info,
    Duration? duration,
    SnackBarAction? action,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color backgroundColor;
    Color foregroundColor;
    IconData icon;

    switch (type) {
      case SnackType.success:
        backgroundColor = isDark ? const Color(0xFF0F392B) : const Color(0xFFE6F4EA);
        foregroundColor = isDark ? const Color(0xFF81C995) : const Color(0xFF137333);
        icon = Icons.check_circle_rounded;
        break;
      case SnackType.warning:
        backgroundColor = isDark ? const Color(0xFF3B2F0F) : const Color(0xFFFEF7E0);
        foregroundColor = isDark ? const Color(0xFFFDD663) : const Color(0xFFB06000);
        icon = Icons.warning_amber_rounded;
        break;
      case SnackType.error:
        backgroundColor = isDark ? const Color(0xFF3C1B1B) : const Color(0xFFFCE8E6);
        foregroundColor = isDark ? const Color(0xFFF28B82) : const Color(0xFFC5221F);
        icon = Icons.error_outline_rounded;
        break;
      case SnackType.info:
        backgroundColor = isDark ? const Color(0xFF1F2937) : const Color(0xFFE8F0FE);
        foregroundColor = isDark ? const Color(0xFF93C5FD) : const Color(0xFF1A73E8);
        icon = Icons.info_outline_rounded;
        break;
    }

    final effectiveDuration = duration ??
        (type == SnackType.error
            ? const Duration(seconds: 4)
            : type == SnackType.warning
                ? const Duration(seconds: 3)
                : const Duration(milliseconds: 2200));

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: foregroundColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          side: BorderSide(
            color: foregroundColor.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        duration: effectiveDuration,
        action: action,
      ),
    );
  }

  static void success(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) =>
      show(context, message: message, type: SnackType.success, duration: duration, action: action);

  static void error(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) =>
      show(context, message: message, type: SnackType.error, duration: duration, action: action);

  static void warning(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) =>
      show(context, message: message, type: SnackType.warning, duration: duration, action: action);

  static void info(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) =>
      show(context, message: message, type: SnackType.info, duration: duration, action: action);
}

```

### FLUTTER FILE: openturath_ai/lib/core/arabic_utils.dart
```dart
/// Utility Normalisasi & Pencarian Cerdas Teks Arab (Smart Arabic Search)
/// - Menghilangkan seluruh harakat (fathah, dhommah, kasrah, tanwin, sukun, tasydid)
/// - Menyatukan variasi huruf Alif (أ, إ, آ, ٱ -> ا)
/// - Menyatukan Ta Marbuthah & Ha (ة -> ه)
/// - Menyatukan Ya & Alif Maqshurah (ى -> ي)
/// - Menghilangkan tatweel / kashida (ـ)
class ArabicUtils {
  static final RegExp _harakatRegex = RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]');
  static final RegExp _tatweelRegex = RegExp(r'\u0640');

  /// Normalisasi string Arab & Latin untuk perbandingan pencarian fleksibel
  static String normalize(String text) {
    if (text.isEmpty) return '';
    
    // 1. Hapus harakat & tatweel
    var normalized = text.replaceAll(_harakatRegex, '').replaceAll(_tatweelRegex, '');
    
    // 2. Normalisasi variasi huruf alif
    normalized = normalized
        .replaceAll(RegExp(r'[أإآٱ]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll(RegExp(r'[ؤئ]'), 'ء');
        
    return normalized.toLowerCase().trim();
  }

  /// Cek apakah teks target mengandung query pencarian (baik Arab maupun Latin)
  static bool matches(String source, String query) {
    if (query.trim().isEmpty) return true;
    
    final normSource = normalize(source);
    final normQuery = normalize(query);
    
    // Cek versi normalisasi
    if (normSource.contains(normQuery)) return true;
    
    // Cek versi teks mentah (case-insensitive)
    if (source.toLowerCase().contains(query.toLowerCase().trim())) return true;
    
    return false;
  }
}

```

### FLUTTER FILE: openturath_ai/lib/core/checkout_completion.dart
```dart
class CheckoutCompletion {
  Future<void>? confirmation;
  bool _finishing = false;
  Future<void> finish({required void Function() dismissConfirmation, required void Function() closeCheckout}) async {
    if (_finishing) return;
    _finishing = true;
    dismissConfirmation();
    await confirmation;
    closeCheckout();
  }
}

```

### FLUTTER FILE: openturath_ai/lib/core/constants.dart
```dart
class AppConstants {
  // ── App Info ──────────────────────────────────────────────────
  static const String appName = 'OpenTurath AI';
  static const String appNameArabic = 'الذكاء الاصطناعي للعلوم الإسلامية';
  static const String appTagline = 'Membaca kitab, menelusuri ibarah.';

  // ── Trial Limit Config ────────────────────────────────────────
  static const int trialQuestionLimit = 10;

  // ── Chrome Mobile User Agent Resmi (Mitigasi Error 403 Google) ──
  static const String chromeMobileUserAgent =
      'Mozilla/5.0 (Linux; Android 14; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.6613.127 Mobile Safari/537.36';

  // ── Firestore Collections ─────────────────────────────────────
  static const String colUsers = 'users';
  static const String colAgents = 'agents';
  static const String colTransactions = 'transactions';

  // ── Subscription Plans ────────────────────────────────────────
  static const String planTrial = 'trial';
  static const String planTholib1m = 'tholib_1m';
  static const String planTholib6m = 'tholib_6m';
  static const String planBahits1y = 'bahits_1y';

  // ── Firebase Cloud Functions ───────────────────────────────────
  static const String fnGetAgentUrl = 'getAgentUrl';
  static const String fnCreatePayment = 'createCheckout';
  static const String fnCheckPaymentStatus = 'checkPaymentStatus';

  // ── Pricing (Rupiah) ──────────────────────────────────────────
  static const int priceTholib1m = 50000;
  static const int priceTholib6m = 250000;
  static const int priceBahits1y = 450000;
  static const int priceAllAiPromo1m = 99000;
}

```

### FLUTTER FILE: openturath_ai/lib/core/copied_answer.dart
```dart
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/agent_model.dart';
import '../models/bookmark_model.dart';

BookmarkModel copiedAnswerBookmark(String answer, AgentModel agent) {
  final text = answer.trim();
  if (text.isEmpty || text.length > 200000) throw ArgumentError('Invalid answer length');
  final firstLine = text.split('\n').first;
  return BookmarkModel(
    id: sha256.convert(utf8.encode('${agent.id}:$text')).toString(),
    title: firstLine.length > 80 ? firstLine.substring(0, 80) : firstLine,
    agentId: agent.id, agentTitle: agent.title, fieldName: agent.category, fieldId: agent.fieldId,
    arabicExcerpt: '', fullAnswer: text, bookReference: 'Rujukan belum diidentifikasi', pageNumber: '', createdAt: DateTime.now(),
  );
}

```

### FLUTTER FILE: openturath_ai/lib/core/design/ot_colors.dart
```dart
import 'package:flutter/material.dart';

/// OpenTurath Design System v2 — Color Palette (Quiet Scholar Adaptive)
/// Filosofi: Konten adalah tokoh utama. UI mundur satu langkah.
/// Nuansa islami muncul dari isi teks, aksara Arab, dan keanggunan tata letak, bukan dekorasi berlebihan.
class OTColors {
  // ── 1. Light Canvas & Surfaces (Warm Off-White & Pure Paper) ──
  static const Color canvasLight = Color(0xFFFAFAF9); // Warm stone off-white
  static const Color surfaceLight = Color(0xFFFFFFFF); // Pure white card/sheet
  static const Color surfaceSubtleLight = Color(0xFFF4F4F5); // Inset container bg
  static const Color borderLight = Color(0xFFE4E4E7); // 1px subtle hairline
  static const Color borderSubtleLight = Color(0xFFF1F5F9);

  // ── 2. Light Typography (High Contrast, Readable) ──
  static const Color textPrimaryLight = Color(0xFF18181B); // Ink black
  static const Color textSecondaryLight = Color(0xFF52525B); // Zinc 600 (>4.5:1 WCAG AA)
  static const Color textTertiaryLight = Color(0xFF71717A); // Zinc 500

  // ── 3. Dark Canvas & Surfaces (Deep Obsidian & Slate) ──
  static const Color canvasDark = Color(0xFF0E0E10); // Deep obsidian
  static const Color surfaceDark = Color(0xFF18181B); // Zinc 900 elevated surface
  static const Color surfaceSubtleDark = Color(0xFF27272A); // Zinc 800 inset
  static const Color borderDark = Color(0xFF27272A); // 1px hairline dark border
  static const Color borderSubtleDark = Color(0xFF1E1E22);

  // ── 4. Dark Typography (Clean White & High Contrast Gray) ──
  static const Color textPrimaryDark = Color(0xFFFAFAFA); // Zinc 50
  static const Color textSecondaryDark = Color(0xFFA1A1AA); // Zinc 400 (>7.0:1 WCAG AAA)
  static const Color textTertiaryDark = Color(0xFFA1A1AA); // Zinc 500

  // ── 5. Scholarly Accents (Muted Intellectual Sapphire & Emerald) ──
  static const Color accentLight = Color(0xFF2563EB); // Intellectual sapphire
  static const Color accentDark = Color(0xFF60A5FA); // Soft scholarly sapphire
  static const Color sovereignAmber = Color(0xFFD97706); // Amber for Tahawwulat sovereign corpus
  static const Color sovereignAmberBg = Color(0x1AD97706); // 10% amber wash

  // ── 6. Semantic Colors ──
  static const Color success = Color(0xFF10B981); // Emerald green (hanya saat bermakna)
  static const Color destructive = Color(0xFFDC2626); // Red (hanya logout/delete/error)

  // ── Context-Aware Adaptive Helpers ──
  static Color canvas(bool isDark) => isDark ? canvasDark : canvasLight;
  static Color surface(bool isDark) => isDark ? surfaceDark : surfaceLight;
  static Color surfaceSubtle(bool isDark) => isDark ? surfaceSubtleDark : surfaceSubtleLight;
  static Color border(bool isDark) => isDark ? borderDark : borderLight;
  static Color textPrimary(bool isDark) => isDark ? textPrimaryDark : textPrimaryLight;
  static Color textSecondary(bool isDark) => isDark ? textSecondaryDark : textSecondaryLight;
  static Color textTertiary(bool isDark) => isDark ? textTertiaryDark : textTertiaryLight;
  static Color accent(bool isDark) => isDark ? accentDark : accentLight;
}

```

### FLUTTER FILE: openturath_ai/lib/core/design/ot_motion.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// OpenTurath Design System v2 — Quiet Motion & Haptics
/// Gerakan tenang yang tidak mendominasi konsentrasi telaah ilmiah santri.
class OTMotion {
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 220);
  static const Duration sheet = Duration(milliseconds: 280);
  static const Duration transition = Duration(milliseconds: 320);

  static const Curve curve = Curves.easeOutCubic;
  static const Curve sheetCurve = Curves.easeOutQuart;

  // ── Scholarly Haptic Feedback ──
  static void selection() {
    HapticFeedback.selectionClick();
  }

  static void light() {
    HapticFeedback.lightImpact();
  }

  static void success() {
    HapticFeedback.mediumImpact();
  }
}

```

### FLUTTER FILE: openturath_ai/lib/core/design/ot_radius.dart
```dart
import 'package:flutter/material.dart';

/// OpenTurath Design System v2 — Disciplined Radius System
/// Menghindari pembulatan berlebih yang membuat semua elemen tampak sebagai 'kotak kartu'.
class OTRadius {
  static const double input = 14.0;
  static const double card = 16.0;
  static const double sheet = 24.0;
  static const double dialog = 20.0;
  static const double chip = 999.0;
  static const double button = 999.0;

  static BorderRadius inputBorder = BorderRadius.circular(input);
  static BorderRadius cardBorder = BorderRadius.circular(card);
  static BorderRadius sheetBorder = const BorderRadius.vertical(top: Radius.circular(sheet));
  static BorderRadius dialogBorder = BorderRadius.circular(dialog);
  static BorderRadius chipBorder = BorderRadius.circular(chip);
  static BorderRadius buttonBorder = BorderRadius.circular(button);
}

```

### FLUTTER FILE: openturath_ai/lib/core/design/ot_spacing.dart
```dart
import 'package:flutter/material.dart';

/// OpenTurath Design System v2 — Spacing Tokens (Base-4 Rhythm)
/// Menolak angka acak (13, 19, 27, 31). Menggunakan ritme proporsional kelipatan 4.
class OTSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double base = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double huge = 40.0;
  static const double massive = 48.0;
  static const double jumbo = 64.0;

  // ── Standard Padding Presets ──
  static const EdgeInsets page = EdgeInsets.symmetric(horizontal: base);
  static const EdgeInsets pageVertical = EdgeInsets.symmetric(vertical: base);
  static const EdgeInsets card = EdgeInsets.all(base);
  static const EdgeInsets cardCompact = EdgeInsets.all(md);
  static const EdgeInsets row = EdgeInsets.symmetric(horizontal: base, vertical: md);

  // ── Gap Widgets ──
  static const SizedBox gapXs = SizedBox(height: xs, width: xs);
  static const SizedBox gapSm = SizedBox(height: sm, width: sm);
  static const SizedBox gapMd = SizedBox(height: md, width: md);
  static const SizedBox gapBase = SizedBox(height: base, width: base);
  static const SizedBox gapLg = SizedBox(height: lg, width: lg);
  static const SizedBox gapXl = SizedBox(height: xl, width: xl);
  static const SizedBox gapXxl = SizedBox(height: xxl, width: xxl);
  static const SizedBox gapHuge = SizedBox(height: huge, width: huge);
}

```

### FLUTTER FILE: openturath_ai/lib/core/design/ot_typography.dart
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// OpenTurath Design System v2 — Typography (3-Layer Strict Architecture)
/// 1. Brand Layer: Editorial Serif (hanya untuk Brand, Editorial Hero, dan Judul Korpus)
/// 2. Interface Layer: Clean Sans (untuk tombol, navigasi, pengaturan, formulir, metadata, harga)
/// 3. Arabic Scholarly Layer: Amiri (teks Arab dengan line-height longgar, perataan RTL)
class OTTypography {
  /// Flag to bypass runtime font loading in test and air-gapped environments.
  static bool useSystemFontFallback = false;

  // ── Private font builders with test/offline fallback ──
  static TextStyle _newsreader({
    required double fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
    Color? color,
  }) {
    if (useSystemFontFallback) {
      return TextStyle(
        fontFamily: 'Newsreader',
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
        color: color,
      );
    }
    return GoogleFonts.newsreader(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
      color: color,
    );
  }

  static TextStyle _outfit({
    required double fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
    Color? color,
  }) {
    if (useSystemFontFallback) {
      return TextStyle(
        fontFamily: 'Outfit',
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
        color: color,
      );
    }
    return GoogleFonts.outfit(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
      color: color,
    );
  }

  static TextStyle _amiri({
    required double fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
    Color? color,
  }) {
    if (useSystemFontFallback) {
      return TextStyle(
        fontFamily: 'Amiri',
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
        color: color,
      );
    }
    return GoogleFonts.amiri(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
      color: color,
    );
  }

  // ── 1. Brand & Editorial Layer (Serif / Newsreader) ──
  static TextStyle brandLogo({Color? color}) => _newsreader(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        color: color,
      );

  static TextStyle editorialHero({Color? color}) => _newsreader(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        height: 1.25,
        color: color,
      );

  static TextStyle corpusTitle({Color? color}) => _newsreader(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: color,
      );

  // ── 2. Interface Layer (Modern Sans / Outfit) ──
  static TextStyle screenTitle({Color? color}) => _outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: color,
      );

  static TextStyle sectionHeading({Color? color}) => _outfit(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: color,
      );

  static TextStyle cardTitle({Color? color}) => _outfit(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: color,
      );

  static TextStyle body({Color? color}) => _outfit(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: color,
      );

  static TextStyle bodyMedium({Color? color}) => _outfit(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: color,
      );

  static TextStyle caption({Color? color}) => _outfit(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.35,
        color: color,
      );

  static TextStyle captionMedium({Color? color}) => _outfit(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle button({Color? color}) => _outfit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: color,
      );

  static TextStyle price({Color? color}) => _outfit(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: color,
      );

  // ── 3. Arabic Scholarly Layer (Amiri) ──
  static TextStyle arabicDisplay({Color? color}) => _amiri(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.6,
        color: color,
      );

  static TextStyle arabicReading({Color? color}) => _amiri(
        fontSize: 19,
        fontWeight: FontWeight.w500,
        height: 1.75,
        color: color,
      );

  static TextStyle arabicQuote({Color? color}) => _amiri(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.8,
        color: color,
      );
}

```

### FLUTTER FILE: openturath_ai/lib/core/entitlement_keys.dart
```dart
const entitlementKeys = <String, String>{
  'fiqh_tahawwulat': 'fiqh_tahawwulat',
  'fiqh_tahawwulat_muhaqqiq': 'fiqh_tahawwulat',
  'fiqh_tahawwulat_bayan': 'fiqh_tahawwulat',
  'fiqh_syafii': 'fiqh_syafii',
  'fiqh_syafii_muhaqqiq': 'fiqh_syafii',
  'fiqh_hanafi': 'fiqh_hanafi',
  'fiqh_maliki': 'fiqh_maliki',
  'fiqh_hanbali': 'fiqh_hanbali',
  'fiqh_muqaran': 'fiqh_muqaran',
  'nahwu_sharaf': 'nahwu',
  'nahwu_sharaf_muerib': 'nahwu',
  'nahwu_sharaf_tashrif': 'nahwu',
  'bahasa_arab': 'nahwu',
  'lughah_nahwu': 'nahwu',
  'lughah_sharaf': 'nahwu',
  'lughah_balaghah': 'nahwu',
  'lughah_mujam': 'nahwu',
  'ushul_fiqh': 'ushul_fiqh',
  'ushul_muhaqqiq': 'ushul_fiqh',
  'usul_qawaid': 'ushul_fiqh',
  'usul_maqashid': 'ushul_fiqh',
  'usul_istinbath': 'ushul_fiqh',
  'tafsir': 'tafsir',
  'tafsir_muhaqqiq': 'tafsir',
  'tafsir_ahkam': 'tafsir',
  'tafsir_matsur': 'tafsir',
  'tafsir_ulumul_quran': 'tafsir',
  'hadits': 'hadits',
  'hadits_muhaqqiq': 'hadits',
  'hadits_takhrij': 'hadits',
  'hadits_syarah': 'hadits',
  'hadits_ilal': 'hadits',
  'aqidah': 'aqidah',
  'aqidah_kalam': 'aqidah',
  'aqidah_ushuluddin': 'aqidah',
  'tarikh': 'tarikh',
  'tarikh_khulafa': 'tarikh',
  'tarikh_thabaqat': 'tarikh',
  'habib_umar': 'tasawwuf',
  'tasawwuf_ihya': 'tasawwuf',
  'tasawwuf_adab': 'tasawwuf',
  'all_ai': 'all_access',
};

```

### FLUTTER FILE: openturath_ai/lib/core/hijri_date_utils.dart
```dart
/// Utilitas penanggalan Islam (Hijriah) dan Masehi deterministik & akurat
/// untuk tajuk editorial OpenTurath.
class HijriDateUtils {
  static const List<String> _hijriMonths = [
    'Muharram',
    'Shafar',
    'Rabi\'ul Awwal',
    'Rabi\'uts Tsani',
    'Jumadil Ula',
    'Jumadil Akhir',
    'Rajab',
    'Sya\'ban',
    'Ramadhan',
    'Syawwal',
    'Dzulqa\'dah',
    'Dzulhijjah',
  ];

  static const List<String> _masehiMonths = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static final Map<String, ({int day, int month, int year})> _apiCache = {};

  /// Mengonversi DateTime Masehi ke representasi Hijriah (Tahun, Bulan, Hari).
  /// Memanfaatkan cache API AlAdhan jika tersedia, atau perhitungan deterministik Umm al-Qura.
  static ({int day, int month, int year}) gregorianToHijri(DateTime date) {
    final key = '${date.year}-${date.month}-${date.day}';
    if (_apiCache.containsKey(key)) {
      return _apiCache[key]!;
    }

    int day = date.day;
    int month = date.month;
    int year = date.year;

    int m = month;
    int y = year;
    if (m < 3) {
      y -= 1;
      m += 12;
    }

    int a = y ~/ 100;
    int b = 2 - a + (a ~/ 4);
    int jd = (365.25 * (y + 4716)).toInt() + (30.6001 * (m + 1)).toInt() + day + b - 1524;

    // Menghitung hari Hijriah dari Julian Day (Epoch 1 Muharram 1 H = JD 1948440)
    int l = jd - 1948440 + 10632;
    int n = (l - 1) ~/ 10631;
    l = l - 10631 * n + 354;
    int j = ((10985 - l) ~/ 5316) * ((50 * l) ~/ 17719) + (l ~/ 5670) * ((43 * l) ~/ 15238);
    l = l - ((30 - j) ~/ 15) * ((17719 * j) ~/ 50) - (j ~/ 16) * ((15238 * j) ~/ 43) + 29;
    int hMonth = (24 * l) ~/ 709;
    int hDay = l - (709 * hMonth) ~/ 24;
    int hYear = 30 * n + j - 30;

    return (day: hDay.clamp(1, 30), month: hMonth.clamp(1, 12), year: hYear);
  }

  /// Sinkronisasi tanggal Hijriyah dari AlAdhan API resmi secara senyap di latar belakang.
  static void registerVerifiedHijriDate({required DateTime date, required int day, required int month, required int year}) {
    final key = '${date.year}-${date.month}-${date.day}';
    _apiCache[key] = (day: day, month: month, year: year);
  }

  /// Menghasilkan format tanggal ganda yang anggun dan editorial:
  /// Contoh: "26 Shafar 1448 H • 9 September 2026 M"
  static String formatDualDate([DateTime? date]) {
    final now = date ?? DateTime.now();
    final h = gregorianToHijri(now);

    final hMonthName = (h.month >= 1 && h.month <= 12)
        ? _hijriMonths[h.month - 1]
        : 'Bulan';
    final mMonthName = (now.month >= 1 && now.month <= 12)
        ? _masehiMonths[now.month - 1]
        : '';

    return '${h.day} $hMonthName ${h.year} H • ${now.day} $mMonthName ${now.year} M';
  }

  /// Menghasilkan hanya tanggal Hijriah pendek:
  /// Contoh: "26 Shafar 1448 H"
  static String formatHijriOnly([DateTime? date]) {
    final now = date ?? DateTime.now();
    final h = gregorianToHijri(now);
    final hMonthName = (h.month >= 1 && h.month <= 12)
        ? _hijriMonths[h.month - 1]
        : 'Bulan';
    return '${h.day} $hMonthName ${h.year} H';
  }

  /// Menambahkan durasi bulan kalender dengan month-end clamping deterministik.
  /// Contoh: 31 Januari + 1 bulan = 28 Februari (atau 29 pada kabisat).
  /// 31 Maret + 1 bulan = 30 April.
  static DateTime addCalendarMonthsClamped(DateTime baseDate, int months) {
    var newYear = baseDate.year;
    var newMonth = baseDate.month + months;
    while (newMonth > 12) {
      newYear++;
      newMonth -= 12;
    }
    while (newMonth < 1) {
      newYear--;
      newMonth += 12;
    }
    final daysInTargetMonth = DateTime(newYear, newMonth + 1, 0).day;
    final clampedDay = baseDate.day > daysInTargetMonth ? daysInTargetMonth : baseDate.day;
    return DateTime(
      newYear,
      newMonth,
      clampedDay,
      baseDate.hour,
      baseDate.minute,
      baseDate.second,
      baseDate.millisecond,
      baseDate.microsecond,
    );
  }
}

```

### FLUTTER FILE: openturath_ai/lib/core/localization.dart
```dart
import 'app_config.dart';

class Loc {
  static const Map<String, Map<String, String>> _dict = {
    'id': {
      'app_name': 'OpenTurath AI',
      'available_now': 'Tersedia',
      'coming_soon': 'Belum tersedia',
      'manage_subscription': 'Langganan',
      'settings': 'Profil',
      'logout': 'Keluar',
      'welcome': 'أهلاً',
      'subtitle_dash': 'Pilih ruang riset.',
      'active_sub': 'Akses aktif',
      'valid_until': 'Aktif hingga',
      'full_access': 'Akses semua ruang riset yang tersedia',
      'unlimited_research': 'Telaah ibarah dari marja\' mu\'tamad',
      'explore_corpus': 'Pilih ruang riset.',
      'theme_mode': 'Tampilan Tema',
      'theme_system': 'Sistem Default',
      'theme_light': 'Terang',
      'theme_dark': 'Gelap',
      'language': 'Bahasa',
      'save': 'Simpan',
      'cancel': 'Batal',
      'choose_plan': 'Pilih paket',
    },
    'en': {
      'app_name': 'OpenTurath AI',
      'available_now': 'Available',
      'coming_soon': 'Unavailable',
      'manage_subscription': 'Subscription',
      'settings': 'Profile',
      'logout': 'Sign Out',
      'welcome': 'Welcome',
      'subtitle_dash': 'Select a research space.',
      'active_sub': 'Active Access',
      'valid_until': 'Active until',
      'full_access': 'Access to all available research spaces',
      'unlimited_research': 'Turats manuscript research',
      'explore_corpus': 'Select a research space.',
      'theme_mode': 'Theme Mode',
      'theme_system': 'System Default',
      'theme_light': 'Light',
      'theme_dark': 'Dark',
      'language': 'Language',
      'save': 'Save',
      'cancel': 'Cancel',
      'choose_plan': 'Choose Plan',
    },
    'ar': {
      'app_name': 'أوبن تراث الذكاء الاصطناعي',
      'available_now': 'متاح الآن',
      'coming_soon': 'قريباً',
      'manage_subscription': 'إدارة الاشتراك',
      'settings': 'الإعدادات',
      'logout': 'تسجيل الخروج',
      'welcome': 'أهلاً',
      'subtitle_dash': 'اختر مجال العلم الذي ترغب في البحث فيه.',
      'active_sub': 'الاشتراك نشط',
      'valid_until': 'صالح حتى',
      'full_access': 'وصول كامل للمصادر',
      'unlimited_research': 'بحث غير محدود في التراث',
      'explore_corpus': 'استكشف كتب التراث الإسلامي مع العبارات الأصلية.',
      'theme_mode': 'مظهر التطبيق',
      'theme_system': 'تلقائي',
      'theme_light': 'فاتح',
      'theme_dark': 'داكن',
      'language': 'اللغة',
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'choose_plan': 'اختر هذه الباقة',
    }
  };

  static String tr(String key, [List<String>? args]) {
    final lang = AppConfig.localeNotifier.value;
    String text = _dict[lang]?[key] ?? _dict['en']?[key] ?? key;
    
    if (args != null) {
      for (int i = 0; i < args.length; i++) {
        text = text.replaceAll('{$i}', args[i]);
      }
    }
    return text;
  }
}

```

### FLUTTER FILE: openturath_ai/lib/core/notebook_navigation.dart
```dart
class NotebookNavigation {
  static const hosts = {
    'notebooklm.google.com', 'notebook.google.com',
    'accounts.google.com', 'accounts.youtube.com', 'consent.google.com',
  };
  static bool allowed(Uri uri) => uri.scheme == 'https' && uri.userInfo.isEmpty &&
    uri.port == 443 && hosts.contains(uri.host.toLowerCase());
  static bool notebook(Uri uri) => allowed(uri) &&
    (uri.host == 'notebooklm.google.com' || uri.host == 'notebook.google.com');
}

```

### FLUTTER FILE: openturath_ai/lib/core/notebook_ui_script.dart
```dart
/// Conversation cleanup and explicit copy capture, restricted to NotebookLM.
const notebookUiScript = r'''
(function () {
  if (window.top !== window || !['notebooklm.google.com', 'notebook.google.com'].includes(location.hostname)) return;
  if (window.otNotebook) { window.otNotebook.clean(); return; }
  const answerSelector = '.chat-message[data-sender="model"], .model-message, .response-message, .to-user-container, .to-user-message, .chat-message-pair .answer, [data-message-author-role="assistant"]';
  const visible = el => !!el && el.getClientRects().length > 0 && getComputedStyle(el).visibility !== 'hidden' && getComputedStyle(el).display !== 'none';
  const text = el => (el?.innerText || el?.textContent || '').trim();
  function answerText(el) {
    const clone = el.cloneNode(true);
    clone.querySelectorAll('button, [role="button"], .message-actions, .feedback-buttons').forEach(e => e.remove());
    return text(clone);
  }
  function latest() {
    const answers = [...document.querySelectorAll(answerSelector)].filter(visible);
    return answers.length ? answerText(answers[answers.length - 1]) : '';
  }
  let lastCopy = '';
  let lastCopyAt = 0;
  function sendCopy(value) {
    if (typeof value !== 'string' || !value.trim() || value.length > 200000) return;
    if (value.trim() === lastCopy && Date.now() - lastCopyAt < 1000) return;
    lastCopy = value.trim(); lastCopyAt = Date.now();
    if (window.flutter_inappwebview?.callHandler) window.flutter_inappwebview.callHandler('otCopiedAnswer', value.trim());
  }
  // Observe only explicit answer-copy gestures; never read the device clipboard.
  let copyUntil = 0;
  let selectedAnswer = '';
  document.addEventListener('click', event => {
    const button = event.target.closest?.('button, [role="button"]');
    if (!button) return;
    const label = [button.getAttribute('aria-label'), button.getAttribute('title'), text(button)].filter(Boolean).join(' ');
    if (!/\b(copy|salin|content_copy)\b|نسخ/i.test(label)) return;
    const answer = button.closest(answerSelector);
    if (!answer) return;
    selectedAnswer = answerText(answer);
    copyUntil = Date.now() + 2000;
    // Save the selected answer even where the host uses a private clipboard API.
    sendCopy(selectedAnswer);
  }, true);
  document.addEventListener('copy', event => {
    if (Date.now() < copyUntil && selectedAnswer) sendCopy(selectedAnswer);
  });
  function hide(el) { if (el && !el.hasAttribute('data-ot-hidden')) el.setAttribute('data-ot-hidden', ''); }
  function clean() {
    if (!document.documentElement) return;
    if (!document.getElementById('ot-conversation-ui')) {
      const style = document.createElement('style'); style.id = 'ot-conversation-ui';
      style.textContent = `
        [data-ot-hidden], .chat-disclaimer, .disclaimer, .chat-footer-disclaimer,
        .notebook-guide, notebook-guide, .notebook-overview, notebook-overview,
        .notebook-cover, .notebook-cover-container, .notebook-title-card,
        .notebook-header, .project-header, .chat-header, .chat-panel-header,
        .mobile-tab-bar, .mobile-tabs, .mobile-navigation, mat-tab-header {
          display:none!important;
        }
      `;
      (document.head || document.documentElement).appendChild(style);
    }
    document.querySelectorAll('[role="tablist"]').forEach(el => {
      if (/sources|sumber/i.test(text(el)) && /studio/i.test(text(el))) hide(el);
    });
    document.querySelectorAll('p, span, div, footer').forEach(el => {
      if (el.children.length > 2 || el.closest(answerSelector)) return;
      const value = text(el);
      if (value.length < 240 && /(?:Gemini Notebook|NotebookLM) can be inaccurate|please double.check its responses/i.test(value)) hide(el);
    });
    // The cover is identified by its metadata, never by generic answer cards.
    document.querySelectorAll('h1, h2, [class*="notebook-title"], [class*="title-card"], [class*="project-title"]').forEach(el => {
      if (el.closest(answerSelector)) return;
      let card = el;
      for (let i = 0; card && i < 5; i++, card = card.parentElement) {
        if (card.querySelector('textarea, [contenteditable="true"]') || card.querySelector(answerSelector)) break;
        if (/\d+ sources\b|\d+ sumber\b/i.test(text(card)) && text(card).length < 1500) { hide(card); break; }
      }
    });
    // Dismiss only the informational announcement shown in the reported screenshot.
    document.querySelectorAll('[role="dialog"], mat-dialog-container, .cdk-overlay-pane').forEach(dialog => {
      if (!/more flexibility and control/i.test(text(dialog)) || !/limits refresh every 5 hours/i.test(text(dialog))) return;
      if (!dialog.hasAttribute('data-ot-dismissed')) {
        dialog.setAttribute('data-ot-dismissed', '');
        const close = [...dialog.querySelectorAll('button')].find(b => /^(close|dismiss|got it|tutup|mengerti|done)$/i.test((b.getAttribute('aria-label') || text(b)).trim()));
        if (close) { close.click(); return; }
      }
      const pane = dialog.closest('.cdk-overlay-pane') || dialog;
      hide(pane);
      const wrapper = pane.parentElement;
      if (wrapper?.classList.contains('cdk-global-overlay-wrapper')) {
        hide(wrapper);
        const backdrop = wrapper.previousElementSibling;
        if (backdrop?.classList.contains('cdk-overlay-backdrop')) hide(backdrop);
      }
    });
  }
  function ready() {
    clean();
    const input = [...document.querySelectorAll('textarea, [contenteditable="true"], [role="textbox"]')].find(visible);
    const loading = [...document.querySelectorAll('[role="progressbar"], mat-spinner, .loading-spinner')].some(visible) || [...document.querySelectorAll('h1, h2, [class*="notebook-title"]')].some(el => /loading notebook|memuat notebook/i.test(text(el)));
    return !!input && !input.disabled && input.getAttribute('aria-disabled') !== 'true' && !loading;
  }
  window.otNotebook = {clean, ready, latest};
  let scheduled = false;
  const observer = new MutationObserver(() => {
    if (scheduled) return;
    scheduled = true;
    requestAnimationFrame(() => { scheduled = false; clean(); });
  });
  observer.observe(document, {subtree:true, childList:true, characterData:true});
  clean();
})();

''';

```

### FLUTTER FILE: openturath_ai/lib/core/routes.dart
```dart
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String specialistList = '/specialists';
  static const String bookmark = '/bookmarks';
  static const String profile = '/profile';
  static const String agentWebview = '/agent';
  static const String subscription = '/subscription';
  static const String googleSessionAuth = '/google_session_auth';
  static const String bookCatalog = '/catalog';
  static const String bookDetail = '/book_detail';
}

```

### FLUTTER FILE: openturath_ai/lib/core/theme.dart
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// OpenTurath AI: Google NotebookLM Design System
class AppTheme {
  // ── 1. Light Mode Tokens (Claude Minimalist Aesthetic) ───────────────────
  static const Color canvasLight          = Color(0xFFFFFFFF); // Putih Pekat Murni
  static const Color groupedCanvasLight   = Color(0xFFF6F6F8); // Apple System Grouped Gray Canvas
  static const Color surfaceCardLight     = Color(0xFFFFFFFF); // Pure White Floating Card
  static const Color surfaceHeaderLight   = Color(0xFFFFFFFF); // Header Bar Canvas
  static const Color borderLight          = Color(0xFFE5E7EB); // 1px Subtle Outline (Abu-abu Tipis)
  static const Color borderSubtleLight    = Color(0xFFF1F5F9); 
  static const Color textPrimaryLight     = Color(0xFF18181B); // Main Title & Body
  static const Color textSecondaryLight   = Color(0xFF71717A); // Metadata & Subtitles
  static const Color textTertiaryLight    = Color(0xFF6B7280); // WCAG AA Compliant (4.8:1) Placeholders & Subtitles
  static const Color accentLight          = Color(0xFF18181B); // Refined Monochrome Black
  static const Color pillActionBgLight    = Color(0xFF18181B); // Solid Black Action Pill
  static const Color pillActionTextLight  = Color(0xFFFFFFFF);
  static const Color pillSecondaryBgLight = Color(0xFFF4F4F5);
  static const Color citationBgLight      = Color(0xFFF1F5F9); // Soft Chip
  static const Color citationTextLight    = Color(0xFF18181B); // Citation Text
  static const Color queryBoxBgLight      = Color(0xFFFFFFFF); // Stadium Chat Input
  static const Color queryBoxBorderLight  = Color(0xFFE5E7EB);

  // ── 1b. Apple HIG Specific Tokens ─────────────────────────────────────────
  static const Color appleGreen          = Color(0xFF34C759); // Apple System Green Toggle
  static const Color appleRed            = Color(0xFFFF3B30); // Apple System Destructive Red
  static const Color navBarDark          = Color(0xCC0E0E10); // Translucent 80% Dark Canvas
  static const Color navBarLight         = Color(0xD9FFFFFF); // Translucent 85% Light Canvas
  static const Color navBarBorderDark    = Color(0x26FFFFFF); // 15% Hairline White
  static const Color navBarBorderLight   = Color(0x1F000000); // 12% Hairline Black
  static const double dividerIndent      = 54.0;              // iOS Inset Divider

  // ── 2. Dark Mode Tokens (Claude Pure Deep Black) ─────────────────────────
  static const Color canvasDark           = Color(0xFF0E0E10); // Hitam Pekat Murni
  static const Color groupedCanvasDark    = Color(0xFF0E0E10); // Hitam Pekat Murni Grouped
  static const Color surfaceCardDark      = Color(0xFF18181B); // Elevated Surface Card
  static const Color surfaceHeaderDark    = Color(0xFF0E0E10); // Header Bar Canvas
  static const Color borderDark           = Color(0xFF27272A); // Subtle 1px Dark Outline (Abu-abu Tipis)
  static const Color borderSubtleDark     = Color(0xFF1E1E22);
  static const Color textPrimaryDark      = Color(0xFFFAFAFA); // Main Title & Body
  static const Color textSecondaryDark    = Color(0xFFA1A1AA); // Muted Subtitles
  static const Color textTertiaryDark     = Color(0xFFA1A1AA); // WCAG AA Compliant (7.3:1) Disclaimers
  static const Color accentDark           = Color(0xFF60A5FA); // Scholarly Sapphire Blue (Muted Intellectual Dignity)
  static const Color pillActionBgDark     = Color(0xFFFFFFFF); // Solid White Action Pill
  static const Color pillActionTextDark   = Color(0xFF18181B);
  static const Color pillSecondaryBgDark  = Color(0xFF18181B);
  static const Color citationBgDark       = Color(0xFF1E1E22); // Deep Pill
  static const Color citationTextDark     = Color(0xFF93C5FD); // Soft Scholar Blue Citation Text
  static const Color queryBoxBgDark       = Color(0xFF18181B); // Stadium Chat Input
  static const Color queryBoxBorderDark   = Color(0xFF27272A);
  static const Color surfaceElevated      = Color(0xFF18181B); // Elevated chip / pill container
  static const Color scholarlyIndigo      = Color(0xFF4F46E5); // Intellectual Indigo
  static const Color readingCanvasParchmentLight = Color(0xFFFBF7EE); // Warm parchment reading surface
  static const Color readingCanvasParchmentDark  = Color(0xFF1C1A17);

  // ── 3. Backwards Compatibility Aliases ────────────────────────────────────
  static const Color lmLightCanvas        = canvasLight;
  static const Color lmLightSurface       = surfaceCardLight;
  static const Color lmLightHeader        = surfaceHeaderLight;
  static const Color lmLightInput         = queryBoxBgLight;
  static const Color lmLightBorder        = borderLight;
  static const Color lmLightDivider       = borderSubtleLight;
  static const Color lmLightTextPrimary   = textPrimaryLight;
  static const Color lmLightTextSecondary = textSecondaryLight;
  static const Color lmLightTextTertiary  = textTertiaryLight;
  static const Color lmLightAccent        = accentLight;
  static const Color lmLightCitationBg    = citationBgLight;
  static const Color lmLightCitationText  = citationTextLight;
  static const Color lmLightPillAction    = pillActionBgLight;

  static const Color lmDarkCanvas         = canvasDark;
  static const Color lmDarkSurface        = surfaceCardDark;
  static const Color lmDarkHeader         = surfaceHeaderDark;
  static const Color lmDarkInput          = queryBoxBgDark;
  static const Color lmDarkBorder         = borderDark;
  static const Color lmDarkDivider        = borderSubtleDark;
  static const Color lmDarkTextPrimary    = textPrimaryDark;
  static const Color lmDarkTextSecondary  = textSecondaryDark;
  static const Color lmDarkTextTertiary   = textTertiaryDark;
  static const Color lmDarkAccent         = accentDark;
  static const Color lmDarkCitationBg     = citationBgDark;
  static const Color lmDarkCitationText   = citationTextDark;
  static const Color lmDarkPillAction     = pillActionBgDark;

  static const Color brandRed             = Color(0xFFBA1A1A);
  static const Color brandGreen           = Color(0xFF137333);
  static const Color brandBlue            = accentLight;

  static const Color bgBase               = canvasDark;
  static const Color bgDeep               = Color(0xFF0E0E0F);
  static const Color bgCanvas             = canvasDark;
  static const Color surfaceL1            = surfaceCardDark;
  static const Color surfaceL2            = surfaceHeaderDark;
  static const Color surfaceL3            = borderDark;

  static const Color textPrimary          = textPrimaryDark;
  static const Color textSecondary        = textSecondaryDark;
  static const Color textTertiary         = textTertiaryDark;

  static const Color gold                 = accentLight;
  static const Color goldBright           = accentDark;
  static const Color goldMuted            = citationBgDark;

  static const Color success              = Color(0xFF34A353);
  static const Color error                = Color(0xFFE54335);
  static const Color warning              = Color(0xFFF6B704);
  static const Color info                 = Color(0xFF4280EF);

  static const Color lightBg              = canvasLight;
  static const Color lightSurface         = surfaceCardLight;
  static const Color lightSurfaceL2       = surfaceHeaderLight;
  static const Color lightBorder          = borderLight;
  static const Color lightTextPrimary     = textPrimaryLight;
  static const Color lightTextSecondary   = textSecondaryLight;

  // ── 4. Geometri & Radius Apple HIG (3 Nilai Baku: 8, 16, 100) ───────────────
  static const double radiusXS   = 8.0;   // Kecil: chip / badge / tag
  static const double radiusCard = 16.0;  // Sedang: card / dialog / bottom sheet
  static const double radiusM    = 16.0;  // Alias untuk kompatibilitas
  static const double radiusS    = 8.0;   // Diharmonisasi ke 8.0
  static const double radiusL    = 16.0;  // Diharmonisasi ke 16.0
  static const double radiusXL   = 16.0;  // Diharmonisasi ke 16.0
  static const double radiusFull = 100.0; // Bulat: pill / button / avatar
  static const double radiusPill = 100.0; // Stadium Pills & Buttons
  static const double radiusQuery= 100.0; // Chat Query Stadium Pill

  // ── 5. Gradients ──────────────────────────────────────────────────────────
  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [canvasDark, canvasDark],
  );

  static const LinearGradient lightBgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [canvasLight, canvasLight],
  );

  static const LinearGradient geminiSparkleGradient = LinearGradient(
    colors: [Color(0xFF4285F4), Color(0xFF9B72CB), Color(0xFFD96570)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: accentDark,
        onPrimary: canvasDark,
        primaryContainer: citationBgDark,
        onPrimaryContainer: citationTextDark,
        secondary: pillActionBgDark,
        onSecondary: canvasDark,
        secondaryContainer: pillSecondaryBgDark,
        onSecondaryContainer: textPrimaryDark,
        tertiary: brandGreen,
        onTertiary: Colors.white,
        tertiaryContainer: Color(0xFF0A2914),
        onTertiaryContainer: Color(0xFF7FECA0),
        error: error,
        onError: Colors.white,
        errorContainer: Color(0xFF3B0A07),
        onErrorContainer: Color(0xFFFFB3AC),
        surface: canvasDark,
        onSurface: textPrimaryDark,
        surfaceContainerLowest: Color(0xFF070C11),
        surfaceContainerLow: Color(0xFF0E1620),
        surfaceContainer: surfaceCardDark,
        surfaceContainerHigh: surfaceElevated,
        surfaceContainerHighest: pillSecondaryBgDark,
        outline: borderDark,
        outlineVariant: borderSubtleDark,
        inverseSurface: surfaceCardLight,
        inversePrimary: accentLight,
        scrim: Colors.black,
        shadow: Colors.black,
      ),
      scaffoldBackgroundColor: canvasDark,
      textTheme: _buildTextTheme(Brightness.dark),
      appBarTheme: AppBarTheme(
        backgroundColor: canvasDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: textPrimaryDark, size: 22),
        actionsIconTheme: const IconThemeData(color: textSecondaryDark, size: 22),
      ),
      cardTheme: CardThemeData(
        color: surfaceCardDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
          side: const BorderSide(color: borderDark, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: pillActionBgDark,
          foregroundColor: pillActionTextDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusPill)),
          textStyle: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimaryDark,
          side: const BorderSide(color: borderDark, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusPill)),
          textStyle: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderDark,
        thickness: 1,
        space: 1,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceCardDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusCard)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceElevated,
        contentTextStyle: GoogleFonts.outfit(
          color: textPrimaryDark,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          side: const BorderSide(color: borderDark, width: 1),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: queryBoxBgDark,
        hintStyle: GoogleFonts.outfit(
          color: textTertiaryDark,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          borderSide: const BorderSide(color: borderDark, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          borderSide: const BorderSide(color: borderDark, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          borderSide: const BorderSide(color: accentDark, width: 1.5),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: surfaceElevated,
          borderRadius: BorderRadius.circular(radiusXS),
          border: Border.all(color: borderDark, width: 1),
        ),
        textStyle: GoogleFonts.outfit(
          color: textPrimaryDark,
          fontSize: 12,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceCardDark,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
        ),
        contentTextStyle: GoogleFonts.outfit(
          fontSize: 14,
          color: textSecondaryDark,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusCard)),
          side: BorderSide(color: borderDark, width: 1),
        ),
      ),
    );
  }

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: accentLight,
        onPrimary: Colors.white,
        primaryContainer: citationBgLight,
        onPrimaryContainer: citationTextLight,
        secondary: pillActionBgLight,
        onSecondary: Colors.white,
        secondaryContainer: pillSecondaryBgLight,
        onSecondaryContainer: textPrimaryLight,
        tertiary: brandGreen,
        onTertiary: Colors.white,
        tertiaryContainer: Color(0xFFC7EBD1),
        onTertiaryContainer: Color(0xFF00210B),
        error: error,
        onError: Colors.white,
        errorContainer: Color(0xFFFFDAD6),
        onErrorContainer: Color(0xFF410002),
        surface: canvasLight,
        onSurface: textPrimaryLight,
        surfaceContainerLowest: Color(0xFFFFFFFF),
        surfaceContainerLow: Color(0xFFF7FAFD),
        surfaceContainer: surfaceCardLight,
        surfaceContainerHigh: Color(0xFFE8EEF5),
        surfaceContainerHighest: pillSecondaryBgLight,
        outline: borderLight,
        outlineVariant: borderSubtleLight,
        inverseSurface: surfaceCardDark,
        inversePrimary: accentDark,
        scrim: Colors.black,
        shadow: Colors.black,
      ),
      scaffoldBackgroundColor: canvasLight,
      textTheme: _buildTextTheme(Brightness.light),
      appBarTheme: AppBarTheme(
        backgroundColor: canvasLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimaryLight,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: textPrimaryLight, size: 22),
        actionsIconTheme: const IconThemeData(color: textSecondaryLight, size: 22),
      ),
      cardTheme: CardThemeData(
        color: surfaceCardLight,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
          side: const BorderSide(color: borderLight, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: pillActionBgLight,
          foregroundColor: pillActionTextLight,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusPill)),
          textStyle: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimaryLight,
          side: const BorderSide(color: borderLight, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusPill)),
          textStyle: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderLight,
        thickness: 1,
        space: 1,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceCardLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusCard)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimaryLight,
        contentTextStyle: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: queryBoxBgLight,
        hintStyle: GoogleFonts.outfit(
          color: textTertiaryLight,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          borderSide: const BorderSide(color: borderLight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          borderSide: const BorderSide(color: borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          borderSide: const BorderSide(color: accentLight, width: 1.5),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: textPrimaryLight,
          borderRadius: BorderRadius.circular(radiusXS),
        ),
        textStyle: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceCardLight,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimaryLight,
        ),
        contentTextStyle: GoogleFonts.outfit(
          fontSize: 14,
          color: textSecondaryLight,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusCard)),
          side: BorderSide(color: borderLight, width: 1),
        ),
      ),
    );
  }

  // ── Text Theme Generator ──────────────────────────────────────────────────
  static TextTheme _buildTextTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final primary = isDark ? textPrimaryDark : textPrimaryLight;
    final secondary = isDark ? textSecondaryDark : textSecondaryLight;
    final tertiary = isDark ? textTertiaryDark : textTertiaryLight;

    return TextTheme(
      displayLarge: GoogleFonts.outfit(fontSize: 34, fontWeight: FontWeight.w700, color: primary, letterSpacing: -0.6),
      displayMedium: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w600, color: primary, letterSpacing: -0.4),
      headlineLarge: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w600, color: primary, letterSpacing: -0.3),
      headlineMedium: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600, color: primary, letterSpacing: -0.2),
      titleLarge: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w600, color: primary, letterSpacing: -0.1),
      titleMedium: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: primary),
      titleSmall: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: secondary),
      bodyLarge: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w400, color: primary, height: 1.55),
      bodyMedium: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w400, color: secondary, height: 1.45),
      bodySmall: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w400, color: tertiary, height: 1.4),
      labelLarge: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: primary),
      labelSmall: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w500, color: tertiary, letterSpacing: 0.2),
    );
  }

  static LinearGradient agentGradient(String agentId) {
    return const LinearGradient(
      colors: [Color(0xFF0B57D0), Color(0xFF4285F4)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}

```

### FLUTTER FILE: openturath_ai/lib/firebase_options.dart
```dart
// File generated by FlutterFire CLI with Desktop resilience (F19).
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return ios;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return windows;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBBz789Y0qGeGmKIGGyWt02cKKX9_MUHiU',
    appId: '1:255541559800:android:dbc2844e0ea68e02d2960d',
    messagingSenderId: '255541559800',
    projectId: 'open-turath',
    storageBucket: 'open-turath.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBBz789Y0qGeGmKIGGyWt02cKKX9_MUHiU',
    appId: '1:255541559800:ios:dbc2844e0ea68e02d2960d',
    messagingSenderId: '255541559800',
    projectId: 'open-turath',
    storageBucket: 'open-turath.firebasestorage.app',
    iosBundleId: 'com.openturath.ai',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBBz789Y0qGeGmKIGGyWt02cKKX9_MUHiU',
    appId: '1:255541559800:web:dbc2844e0ea68e02d2960d',
    messagingSenderId: '255541559800',
    projectId: 'open-turath',
    storageBucket: 'open-turath.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBBz789Y0qGeGmKIGGyWt02cKKX9_MUHiU',
    appId: '1:255541559800:android:dbc2844e0ea68e02d2960d',
    messagingSenderId: '255541559800',
    projectId: 'open-turath',
    storageBucket: 'open-turath.firebasestorage.app',
  );
}

```

### FLUTTER FILE: openturath_ai/lib/main.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme.dart';
import 'core/routes.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell_screen.dart';
import 'screens/specialist_list_screen.dart';
import 'screens/bookmark_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/agent_webview_screen.dart';
import 'screens/subscription_screen.dart';
import 'screens/google_session_auth_screen.dart';
import 'screens/book_catalog_screen.dart';
import 'screens/book_detail_screen.dart';
import 'models/book_model.dart';
import 'models/agent_model.dart';
import 'firebase_options.dart';

import 'core/app_config.dart';
import 'core/app_copy.dart';
import 'core/localization.dart';
import 'widgets/app_error_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Kunci orientasi: hanya portrait ──
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load configuration
  try {
    await AppConfig.init();
  } catch (_) {}

  // ── Status bar transparan awal ──
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  try {
    // ── Inisialisasi Firebase ──
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const OpenTurathApp());
  } catch (error, stackTrace) {
    debugPrint('[OpenTurath] Firebase initialization error: $error\n$stackTrace');
    final isUnsupportedPlatform = error is UnsupportedError;
    final title = isUnsupportedPlatform
        ? AppCopy.deviceNotSupportedTitle
        : AppCopy.cannotConnectTitle;
    final message = isUnsupportedPlatform
        ? AppCopy.deviceNotSupportedMessage
        : AppCopy.cannotConnectMessage;

    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: Scaffold(
        backgroundColor: AppTheme.canvasDark,
        body: SafeArea(
          child: AppErrorState(
            title: title,
            message: message,
            onRetry: () => main(),
          ),
        ),
      ),
    ));
  }
}

class OpenTurathApp extends StatelessWidget {
  const OpenTurathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppConfig.themeNotifier,
      builder: (context, currentTheme, _) {
        return ValueListenableBuilder<String>(
          valueListenable: AppConfig.localeNotifier,
          builder: (context, currentLocale, _) {
            final platformBrightness = MediaQuery.maybePlatformBrightnessOf(context) ??
                WidgetsBinding.instance.platformDispatcher.platformBrightness;
            final isDark = currentTheme == ThemeMode.dark || 
                           (currentTheme == ThemeMode.system && platformBrightness == Brightness.dark);

            final overlayStyle = SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
              systemNavigationBarColor: isDark ? AppTheme.canvasDark : AppTheme.canvasLight,
              systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
              systemNavigationBarDividerColor: Colors.transparent,
            );

            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: overlayStyle,
              child: MaterialApp(
                title: Loc.tr('app_name'),
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: currentTheme,
                locale: Locale(currentLocale),
                builder: (context, child) => Directionality(
                  textDirection: currentLocale == 'ar'
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  child: child ?? const SizedBox.shrink(),
                ),

              // ── Initial Route ──
              initialRoute: AppRoutes.splash,

              // ── Dynamic Route Generator with M3 Expressive Transitions ──
              onGenerateRoute: (settings) {
                Widget page;
                switch (settings.name) {
                  case AppRoutes.splash:
                    page = const SplashScreen();
                    break;
                  case AppRoutes.login:
                    page = const LoginScreen();
                    break;
                  case AppRoutes.dashboard:
                    page = const MainShellScreen();
                    break;
                  case AppRoutes.specialistList:
                    page = const SpecialistListScreen();
                    break;
                  case AppRoutes.bookmark:
                    page = const BookmarkScreen();
                    break;
                  case AppRoutes.profile:
                    page = const ProfileScreen();
                    break;
                  case AppRoutes.agentWebview:
                    page = const AgentWebviewScreen();
                    // Slide & cross-fade for immersive agent workspace
                    return PageRouteBuilder(
                      settings: settings,
                      pageBuilder: (context, animation, secondaryAnimation) => page,
                      transitionDuration: const Duration(milliseconds: 360),
                      reverseTransitionDuration: const Duration(milliseconds: 280),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        final curvedAnimation = CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                          reverseCurve: Curves.easeInCubic,
                        );
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.9, 0.0),
                            end: Offset.zero,
                          ).animate(curvedAnimation),
                          child: FadeTransition(
                            opacity: Tween<double>(begin: 0.4, end: 1.0).animate(curvedAnimation),
                            child: child,
                          ),
                        );
                      },
                    );
                  case AppRoutes.subscription:
                    page = const SubscriptionScreen();
                    break;
                  case AppRoutes.googleSessionAuth:
                    page = const GoogleSessionAuthScreen();
                    break;
                  case AppRoutes.bookCatalog:
                    page = BookCatalogScreen(
                      agent: settings.arguments is AgentModel
                          ? settings.arguments as AgentModel
                          : null,
                    );
                    break;
                  case AppRoutes.bookDetail:
                    final book = settings.arguments as CanonicalBookPresentation;
                    page = BookDetailScreen(book: book);
                    break;
                  default:
                    page = const SplashScreen();
                    break;
                }

                // Default Material 3 Expressive transition: FadeUpTransition (fade + subtle 30px slide-up)
                return PageRouteBuilder(
                  settings: settings,
                  pageBuilder: (context, animation, secondaryAnimation) => page,
                  transitionDuration: const Duration(milliseconds: 320),
                  reverseTransitionDuration: const Duration(milliseconds: 240),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    final curvedAnimation = CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                      reverseCurve: Curves.easeInCubic,
                    );
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.04),
                        end: Offset.zero,
                      ).animate(curvedAnimation),
                      child: FadeTransition(
                        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
                        child: child,
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      );
    },
  );
}
}

```

### FLUTTER FILE: openturath_ai/lib/models/agent_model.dart
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sub_agent_model.dart';
import 'book_model.dart';

enum CorpusKind { discipline, scholar }

class AgentModel {
  final String id;
  final String title;
  final String titleArabic;
  final String description;
  final String emoji;
  final String category;
  final String status; // 'active' or 'coming_soon'
  final int sortOrder;
  final String subtitleAcademic;
  final String fieldId;
  final List<String> suggestedPrompts;
  final List<SubAgentModel>? subAgents;
  final List<BookModel>? referenceBooks;
  final String? akalUrl1m;
  final String? akalUrl6m;
  final String? akalUrl1y;
  final int? price1m;
  final int? price6m;
  final int? price1y;
  final CorpusKind kind;
  final List<String> disciplineIds;
  final List<String> scholarIds;
  final String? catalogId;

  AgentModel({
    required this.id,
    required this.title,
    this.titleArabic = '',
    required this.description,
    required this.emoji,
    required this.category,
    required this.status,
    required this.sortOrder,
    this.subtitleAcademic = 'Matan · Syarah · Hasyiyah',
    this.fieldId = 'fiqh',
    this.suggestedPrompts = const [],
    this.subAgents,
    this.referenceBooks,
    this.akalUrl1m,
    this.akalUrl6m,
    this.akalUrl1y,
    this.price1m,
    this.price6m,
    this.price1y,
    this.kind = CorpusKind.discipline,
    this.disciplineIds = const [],
    this.scholarIds = const [],
    this.catalogId,
  });

  bool get isActive => status == 'active';
  bool get isComingSoon => status == 'coming_soon';

  factory AgentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AgentModel(
      id: doc.id,
      title: data['title'] ?? '',
      titleArabic: data['title_arabic'] ?? '',
      description: data['description'] ?? '',
      emoji: data['emoji'] ?? '📖',
      category: data['category'] ?? 'Fiqh',
      status: data['status'] ?? 'coming_soon',
      sortOrder: data['sort_order'] ?? 99,
      subtitleAcademic: data['subtitle_academic'] ?? 'Matan · Syarah · Hasyiyah',
      fieldId: data['field_id'] ?? 'fiqh',
      suggestedPrompts: List<String>.from(data['suggested_prompts'] ?? []),
      akalUrl1m: data['akal_url_1m'],
      akalUrl6m: data['akal_url_6m'],
      akalUrl1y: data['akal_url_1y'],
      price1m: data['price_1m'],
      price6m: data['price_6m'],
      price1y: data['price_1y'],
      kind: data['kind'] == 'scholar' ? CorpusKind.scholar : CorpusKind.discipline,
      disciplineIds: List<String>.from(data['discipline_ids'] ?? []),
      scholarIds: List<String>.from(data['scholar_ids'] ?? []),
      catalogId: data['catalog_id'],
    );
  }

  // ── Hardcoded fallback terstruktur berbasis 8 Bidang Keilmuan ──
  static List<AgentModel> get defaultAgents => [
        // ── 1. FIKIH TAHAWWULAT (SOVEREIGN FLAGSHIP) ─────────
        AgentModel(
          id: 'fiqh_tahawwulat',
          title: 'AI Fikih Tahawwulat',
          titleArabic: 'فقه التحولات',
          description:
              'Membantu menelusuri pembahasan Fikih Tahawwulat dari kitab dan muhadharah Habib Abu Bakar al-Masyhur.',
          emoji: '📜',
          category: 'Fikih Tahawwulat',
          kind: CorpusKind.discipline,
          disciplineIds: const ['fiqh_tahawwulat'],
          scholarIds: const ['habib_abu_bakar'],
          fieldId: 'fiqh_tahawwulat',
          subtitleAcademic: 'Manhaj Abu Bakr al-Masyhur',
          suggestedPrompts: [
            'Bagaimana penjelasan al-ghutsā\'iyyah dalam kitab?',
            'Apa yang dimaksud Rukun Keempat dalam Fikih Tahawwulat?',
            'Bagaimana para ulama menjelaskan sikap saat masa fitnah?',
          ],
          status: 'active',
          sortOrder: 1,
          price1m: 50000,
          price6m: 250000,
          price1y: 450000,
          subAgents: [
            SubAgentModel(
              id: 'fiqh_tahawwulat_muhaqqiq',
              name: 'Al-Muhaqqiq (Riset Dalil)',
              nameArabic: 'المحقق',
              description:
                  'Membantu menemukan dalil, ibarah, dan rujukan yang relevan.',
              descriptionArabic: 'البحث والتحقيق وعزو النصوص إلى مصادرها',
              emoji: '🔍',
              badge: 'Riset Dalil',
            ),
            SubAgentModel(
              id: 'fiqh_tahawwulat_bayan',
              name: 'Al-Bayan (Penjelasan Luas)',
              nameArabic: 'البيان',
              description:
                  'Menjelaskan pokok bahasan dengan bahasa yang lebih ringkas.',
              descriptionArabic: 'الشرح والبيان والتبسيط المنهجي',
              emoji: '💡',
              badge: 'Penjelasan',
            ),
          ],
          referenceBooks: [
            BookModel(
              title: 'Nubdzah Al-Bayan fi Ma\'rifati Sunan Al-Khalaq',
              titleArabic: 'نبذة البيان في معرفة سنن الخلق والبيان',
              author: 'Habib Abu Bakar Al-Masyhur',
              description:
                  'Kitab pengantar dasar metodologi Sunan Al-Khalaq, tanda akhir zaman, dan peta dakwah fikih tahawwulat.',
            ),
            BookModel(
              title: 'Al-Fiqh Al-Manhaji fi Fiqh Al-Tahawwulat',
              titleArabic: 'الفقه المنهجي في فقه التحولات',
              author: 'Habib Abu Bakar Al-Masyhur',
              description:
                  'Panduan pengantar Fikih Tahawwulat untuk pelajar dan peneliti.',
            ),
          ],
        ),
        AgentModel(
          id: 'fiqh_syafii',
          title: 'AI Fikih Syafi\'i',
          titleArabic: 'الفقه الشافعي',
          description:
              'Bantuan untuk mencari keterangan dalam kitab-kitab mazhab Syafi\'i.',
          emoji: '📜',
          category: 'Fiqih',
          kind: CorpusKind.discipline,
          disciplineIds: const ['fiqh'],
          catalogId: 'canonical_syafii',
          fieldId: 'fiqh',
          subtitleAcademic: 'Matan · Syarah · Hasyiyah Mu\'tabarah',
          suggestedPrompts: [
            'Apa rukun wudu menurut pendapat mu\'tamad dalam mazhab Syafi\'i?',
            'Apa syarat sah salat berjamaah menurut Minhāj al-Ṭālibīn?',
            'Bagaimana ketentuan zakat perdagangan menurut Imam al-Nawawi?',
          ],
          status: 'active',
          sortOrder: 2,
          price1m: 50000,
          price6m: 250000,
          price1y: 450000,
          subAgents: [
            SubAgentModel(
              id: 'fiqh_syafii_muhaqqiq',
              name: 'Al-Muhaqqiq Fikih Syafi\'i',
              nameArabic: 'المحقق',
              description:
                  'Membantu menemukan dalil, ibarah, dan rujukan dalam mazhab Syafi\'i.',
              descriptionArabic: 'تحقيق المعتمد في المذهب الشافعي',
              emoji: '⚖️',
              badge: 'Fikih Syafi\'i',
            ),
          ],
          referenceBooks: [
            BookModel(
              title: 'Al-Umm',
              titleArabic: 'الأم',
              author: 'Imam Asy-Syafi\'i',
              description: 'Kitab induk Fikih Mazhab Syafi\'i.',
            ),
            BookModel(
              title: 'Al-Majmu\' Syarah Al-Muhadzdzab',
              titleArabic: 'المجموع شرح المهذب',
              author: 'Imam An-Nawawi',
              description:
                  'Rujukan fikih mazhab Syafi\'i karya Imam An-Nawawi.',
            ),
          ],
        ),
        AgentModel(
          id: 'fiqh_hanafi',
          title: 'AI Fikih Hanafi',
          titleArabic: 'الفقه الحنفي',
          description:
              'Fikih Mazhab Hanafi dengan rujukan Al-Mabsuth, Radd Al-Muhtar, dan Hidayah Al-Marghinani.',
          emoji: '⚖️',
          category: 'Fiqih',
          fieldId: 'fiqh',
          subtitleAcademic: 'Zhahir Ar-Riwayah · Syuruh & Fatawa',
          suggestedPrompts: [
            'Bagaimana kaidah istihsan dalam mazhab Hanafi?',
            'Apa pendapat mu\'tamad mazhab Hanafi mengenai syarat shalat berjamaah?',
            'Bawakan ibarah Radd Al-Muhtar tentang bab muamalat dan tijarah!',
          ],
          status: 'coming_soon',
          sortOrder: 3,
          price1m: 50000,
          price6m: 250000,
          price1y: 450000,
          subAgents: [
            SubAgentModel(
              id: 'fiqh_hanafi_muhaqqiq',
              name: 'Al-Muhaqqiq Fikih Hanafi',
              nameArabic: 'المحقق',
              description: 'Spesialis riset Zhahir Ar-Riwayah dan fatwa mazhab Hanafi.',
              descriptionArabic: 'تحقيق المعتمد في المذهب الحنفي',
              emoji: '⚖️',
              badge: 'Fikih Hanafi',
            ),
          ],
          referenceBooks: [
            BookModel(
              title: 'Al-Mabsuth',
              titleArabic: 'المبسوط',
              author: 'Imam As-Sarakhsi',
              description: 'Kitab ensiklopedi induk fikih mazhab Hanafi.',
            ),
            BookModel(
              title: 'Radd Al-Muhtar \'ala Ad-Durr Al-Mukhtar (Hasyiyah Ibnu Abidin)',
              titleArabic: 'رد المحتار على الدر المختار',
              author: 'Ibnu \'Abidin',
              description: 'Rujukan fatwa mu\'tamad muta\'akhkhirin mazhab Hanafi.',
            ),
          ],
        ),
        AgentModel(
          id: 'fiqh_maliki',
          title: 'AI Fikih Maliki',
          titleArabic: 'الفقه المالكي',
          description:
              'Fikih Mazhab Maliki dan \'Amal Ahlil Madinah dengan rujukan Al-Mudawwanah, Risalah Ibnu Abi Zaid, dan Mukhtashar Khalil.',
          emoji: '⚖️',
          category: 'Fiqih',
          fieldId: 'fiqh',
          subtitleAcademic: 'Al-Mudawwanah · Mukhtashar Khalil & Syarah',
          suggestedPrompts: [
            'Bagaimana kedudukan \'Amal Ahlil Madinah dalam istinbath Maliki?',
            'Rincikan syarat sah shalat menurut Mukhtashar Khalil!',
            'Bawakan ibarah Bidayatul Mujtahid mengenai perbedaan pendapat dalam thaharah!',
          ],
          status: 'coming_soon',
          sortOrder: 4,
          price1m: 50000,
          price6m: 250000,
          price1y: 450000,
          subAgents: [
            SubAgentModel(
              id: 'fiqh_maliki_muhaqqiq',
              name: 'Al-Muhaqqiq Fikih Maliki',
              nameArabic: 'المحقق',
              description: 'Spesialis riset Al-Mudawwanah dan Mukhtashar Khalil.',
              descriptionArabic: 'تحقيق المعتمد في المذهب المالكي',
              emoji: '⚖️',
              badge: 'Fikih Maliki',
            ),
          ],
          referenceBooks: [
            BookModel(
              title: 'Al-Mudawwanah Al-Kubra',
              titleArabic: 'المدونة الكبرى',
              author: 'Imam Sahnun (dari Imam Malik)',
              description: 'Fondasi riwayat fatwa dan hukum mazhab Maliki.',
            ),
            BookModel(
              title: 'Mukhtashar Khalil',
              titleArabic: 'مختصر خليل',
              author: 'Syaikh Khalil bin Ishaq',
              description: 'Matan hukum paling padat dan mu\'tamad di kalangan Malikiyyah.',
            ),
          ],
        ),
        AgentModel(
          id: 'fiqh_hanbali',
          title: 'AI Fikih Hanbali',
          titleArabic: 'الفقه الحنبلي',
          description:
              'Khazanah Fikih Mazhab Hanbali merujuk Al-Mughni Ibnu Qudamah, Kasysyaf Al-Qina\', dan Zad Al-Mustaqni\'.',
          emoji: '⚖️',
          category: 'Fiqih',
          fieldId: 'fiqh',
          subtitleAcademic: 'Al-Mughni · Zad Al-Mustaqni\' & Syuruh',
          suggestedPrompts: [
            'Apa mu\'tamad mazhab Hanbali mengenai pembatalan wudhu?',
            'Bawakan ibarah Al-Mughni tentang hukum jual beli bersyarat!',
            'Bagaimana perbedaan riwayat dari Imam Ahmad dalam masalah ibadah?',
          ],
          status: 'coming_soon',
          sortOrder: 5,
          price1m: 50000,
          price6m: 250000,
          price1y: 450000,
          subAgents: [
            SubAgentModel(
              id: 'fiqh_hanbali_muhaqqiq',
              name: 'Al-Muhaqqiq Fikih Hanbali',
              nameArabic: 'المحقق',
              description: 'Spesialis telaah Al-Mughni dan perbandingan riwayat Imam Ahmad.',
              descriptionArabic: 'تحقيق المعتمد في المذهب الحنبلي',
              emoji: '⚖️',
              badge: 'Fikih Hanbali',
            ),
          ],
          referenceBooks: [
            BookModel(
              title: 'Al-Mughni',
              titleArabic: 'المغني',
              author: 'Ibnu Qudamah Al-Maqdisi',
              description: 'Kitab fikih dalil mazhab Hanbali karya Ibnu Qudamah.',
            ),
            BookModel(
              title: 'Kasysyaf Al-Qina\' \'an Matn Al-Iqna\'',
              titleArabic: 'كشاف القناع عن متن الإقناع',
              author: 'Manshur bin Yunus Al-Buhuti',
              description: 'Syarah mu\'tamad pegangan fatwa ulama Hanbali.',
            ),
          ],
        ),
        AgentModel(
          id: 'fiqh_muqaran',
          title: 'AI Perbandingan Mazhab',
          titleArabic: 'الفقه المقارن',
          description:
              'Komparasi hukum lintas mazhab empat (Arba\'ah), analisis wajh al-dilalah, dan tarjih dalil mu\'tabar.',
          emoji: '⚖️',
          category: 'Fiqih',
          fieldId: 'fiqh',
          subtitleAcademic: 'Perbandingan Mazhab Empat & Tarjih Dalil',
          suggestedPrompts: [
            'Bandingkan pandangan 4 mazhab mengenai rukun nikah!',
            'Apa dalil perbedaan ulama tentang batas menyentuh bukan mahram?',
            'Kompilasi fatwa kontemporer vs klasik mengenai zakat saham dan uang digital!',
          ],
          status: 'coming_soon',
          sortOrder: 6,
          price1m: 50000,
          price6m: 250000,
          price1y: 450000,
          subAgents: [
            SubAgentModel(
              id: 'fiqh_muqaran_muhaqqiq',
              name: 'Al-Muhaqqiq Fikih Muqaran',
              nameArabic: 'المحقق',
              description: 'Spesialis komparasi dalil mazhab Arba\'ah dan tarjih.',
              descriptionArabic: 'المقارنة بين المذاهب والترجيح بالدليل',
              emoji: '⚖️',
              badge: 'Fikih Muqaran',
            ),
          ],
          referenceBooks: [
            BookModel(
              title: 'Bidayatul Mujtahid wa Nihayatul Muqtashid',
              titleArabic: 'بداية المجتهد ونهاية المقتصد',
              author: 'Ibnu Rusyd Al-Hafid',
              description: 'Kajian perbandingan mazhab empat beserta analisis dalil dan sebab perbedaan hukum.',
            ),
            BookModel(
              title: 'Al-Fiqh Al-Islami wa Adillatuh',
              titleArabic: 'الفقه الإسلامي وأدلته',
              author: 'Prof. Dr. Wahbah Az-Zuhaili',
              description: 'Ensiklopedi perbandingan mazhab klasik & kontemporer.',
            ),
          ],
        ),

        // ── 2. HADIS ──────────────────────────────────────────
        AgentModel(
          id: 'hadits',
          title: 'AI Hadits & Syarah Sunnah',
          titleArabic: 'الحديث الشريف',
          description:
              'Kajian matan hadits, perawi, dan syarah dari induk kitab-kitab As-Sunnah (Kutubus Sittah & syuruhnya).',
          emoji: '📖',
          category: 'Hadits',
          fieldId: 'hadith',
          subtitleAcademic: 'Kutubus Sittah · Takhrij & Rijal',
          suggestedPrompts: [
            'Bagaimana penjelasan hadis tentang niat dalam Fatḥ al-Bārī?',
            'Bagaimana menilai sanad riwayat ini?',
            'Bagaimana status perawi hadis talqin dalam Kutubus Sittah?',
          ],
          status: 'active',
          sortOrder: 7,
          price1m: 50000,
          price6m: 250000,
          price1y: 450000,
          subAgents: [
            SubAgentModel(
              id: 'hadits_muhaqqiq',
              name: 'Al-Muhaqqiq (Takhrij Hadits)',
              nameArabic: 'المحقق',
              description:
                  'Spesialis takhrij hadits, telaah rijalul hadits, dan derajat kesahihan sanad.',
              descriptionArabic: 'تخريج الحديث ودراسة الأسانيد والرجال',
              emoji: '🔍',
              badge: 'Takhrij & Rijal',
            ),
          ],
          referenceBooks: [
            BookModel(
              title: 'Shahih Al-Bukhari',
              titleArabic: 'صحيح البخاري',
              author: 'Imam Al-Bukhari',
              description: 'Kitab hadis shahih rujukan induk umat Islam.',
            ),
            BookModel(
              title: 'Shahih Muslim',
              titleArabic: 'صحيح مسلم',
              author: 'Imam Muslim',
              description: 'Kitab shahih kedua dengan sistematika sanad yang sangat rapi.',
            ),
          ],
        ),

        // ── 3. TAFSIR ─────────────────────────────────────────
        AgentModel(
          id: 'tafsir',
          title: 'AI Tafsir Al-Qur\'an',
          titleArabic: 'تفسير القرآن',
          description:
              'Penelusuran makna ayat, asbabun nuzul, dan istinbath hukum dari kitab-kitab tafsir mu\'tabarah.',
          emoji: '🌟',
          category: 'Tafsir',
          fieldId: 'tafsir',
          subtitleAcademic: 'Tafsir Thabari, Ibnu Katsir & Qurtubi',
          suggestedPrompts: [
            'Apa asbabun nuzul surah Al-Baqarah ayat 183?',
            'Bagaimana tafsir ayat Muhkamat dan Mutasyabihat menurut Al-Qurtubi?',
            'Kompilasi pandangan mufassirin tentang tafsir "Ihdinas shiratal mustaqim"!',
          ],
          status: 'active',
          sortOrder: 8,
          price1m: 50000,
          price6m: 250000,
          price1y: 450000,
          subAgents: [
            SubAgentModel(
              id: 'tafsir_muhaqqiq',
              name: 'Al-Muhaqqiq (Tafsir Riwayat)',
              nameArabic: 'المحقق',
              description:
                  'Spesialis kompilasi penafsiran mufassirin salaf dan asbabun nuzul.',
              descriptionArabic: 'تحقيق الروايات وأسباب النزول',
              emoji: '🔍',
              badge: 'Riset Tafsir',
            ),
          ],
          referenceBooks: [
            BookModel(
              title: 'Tafsir Al-Qur\'an Al-\'Azhim',
              titleArabic: 'تفسير ابن كثير',
              author: 'Al-Hafizh Ibnu Katsir',
              description: 'Rujukan tafsir bil-ma\'tsur dengan penekanan pada riwayat shahih dan asbabun nuzul.',
            ),
            BookModel(
              title: 'Al-Jami\' li Ahkam Al-Qur\'an',
              titleArabic: 'تفسير القرطبي',
              author: 'Imam Al-Qurtubi',
              description: 'Tafsir dengan fokus pada hukum-hukum fikih dalam Al-Qur\'an.',
            ),
          ],
        ),

        // ── 4. USUL FIQH ──────────────────────────────────────
        AgentModel(
          id: 'ushul_fiqh',
          title: 'AI Ushul Fiqih',
          titleArabic: 'أصول الفقه',
          description:
              'Metode istinbath hukum dan kaidah usul fikih dari kitab rujukan yang diakui.',
          emoji: '📐',
          category: 'Ushul Fiqih',
          fieldId: 'usul',
          subtitleAcademic: 'Kaidah Istinbath & Maqashid Syariah',
          suggestedPrompts: [
            'Jelaskan perbedaan Mafhum Mukhalafah dan Mafhum Muwafaqah!',
            'Bagaimana kaidah "Al-Amru ba\'dan-nahyi yufidul ibahah"?',
            'Bawakan ibarah Al-Waraqat tentang pembagian hukum taklifi!',
          ],
          status: 'active',
          sortOrder: 9,
          price1m: 50000,
          price6m: 250000,
          price1y: 450000,
          subAgents: [
            SubAgentModel(
              id: 'ushul_muhaqqiq',
              name: 'Al-Muhaqqiq (Kaidah Ushul)',
              nameArabic: 'المحقق',
              description:
                  'Spesialis penelusuran kaidah ushuliyyah dan metode istinbath dalil.',
              descriptionArabic: 'تحقيق القواعد الأصولية والاستنباط',
              emoji: '📐',
              badge: 'Kaidah Ushul',
            ),
          ],
          referenceBooks: [
            BookModel(
              title: 'Matan Al-Waraqat',
              titleArabic: 'متن الورقات',
              author: 'Imam Al-Haramain Al-Juwaini',
              description: 'Matan pondasi metodologi ushul fikih paling tersohor.',
            ),
            BookModel(
              title: 'Jam\'ul Jawami\'',
              titleArabic: 'جمع الجوامع',
              author: 'Tajuddin As-Subki',
              description: 'Karya induk ushul fikih lintas mazhab karya Tajuddin As-Subki.',
            ),
          ],
        ),

        // ── 5. BAHASA ARAB ────────────────────────────────────
        AgentModel(
          id: 'nahwu_sharaf',
          title: 'AI Bahasa Arab & Balaghah',
          titleArabic: 'النحو والصرف',
          description:
              'Nahwu, sharaf, balaghah, dan mu\'jam dengan rujukan kitab bahasa Arab.',
          emoji: '🔤',
          category: 'Bahasa Arab',
          fieldId: 'lughah',
          subtitleAcademic: 'Alfiyah Ibnu Malik & Lisanul Arab',
          suggestedPrompts: [
            'I\'rab kalimat: "إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ" secara mendalam!',
            'Jelaskan faidah wazan Fa\'ala dan Af\'ala dalam ilmu sharaf!',
            'Bawakan kaidah Munada dalam bait Alfiyah Ibnu Malik!',
          ],
          status: 'active',
          sortOrder: 10,
          price1m: 50000,
          price6m: 250000,
          price1y: 450000,
          subAgents: [
            SubAgentModel(
              id: 'nahwu_sharaf_muerib',
              name: 'Al-Mu\'rib (Kaidah Sintaksis)',
              nameArabic: 'المعرب',
              description:
                  'Spesialis i\'rab kata dan analisis sintaksis (nahwu) sesuai kaidah Alfiyah Ibnu Malik.',
              descriptionArabic: 'إعراب الكلمات والتحليل النحوي',
              emoji: '🔍',
              badge: 'Analisis Nahwu',
            ),
            SubAgentModel(
              id: 'nahwu_sharaf_tashrif',
              name: 'Al-Tashrif (Kaidah Morfologi)',
              nameArabic: 'المصرف',
              description:
                  'Spesialis perubahan wazan, derivasi kata (sharaf), dan morfologi bahasa Arab klasik.',
              descriptionArabic: 'تحليل الأوزان والاشتقاق الصرفي',
              emoji: '🔄',
              badge: 'Analisis Sharaf',
            ),
          ],
          referenceBooks: [
            BookModel(
              title: 'Alfiyah Ibnu Malik',
              titleArabic: 'ألفية ابن مالك',
              author: 'Ibnu Malik',
              description:
                  'Nadhom tata bahasa Arab 1.000 bait karya Imam Ibnu Malik.',
            ),
            BookModel(
              title: 'Syarah Ibnu Aqil',
              titleArabic: 'شرح ابن عقيل',
              author: 'Ibnu Aqil',
              description:
                  'Kitab penjelasan paling populer untuk bait-bait Alfiyah Ibnu Malik.',
            ),
          ],
        ),

        // ── 6. AQIDAH ─────────────────────────────────────────
        AgentModel(
          id: 'aqidah',
          title: 'AI Aqidah & Ilmu Kalam',
          titleArabic: 'العقيدة والتوحيد',
          description:
              'Pembahasan ushuluddin, tauhid sifat dua puluh, dan manhaj Ahlussunnah wal Jama\'ah.',
          emoji: '🛡️',
          category: 'Aqidah',
          fieldId: 'aqidah',
          subtitleAcademic: 'Asy\'ariyyah · Maturidiyyah · Dalil Aqli',
          suggestedPrompts: [
            'Jelaskan pembagian sifat Wajib, Mustahil, dan Jaiz bagi Allah!',
            'Bagaimana dalil aqli tentang keesaan Allah menurut Al-Sanusiyyah?',
            'Apa perbedaan pemikiran Asy\'ariyyah dan Mu\'tazilah tentang kalamullah?',
          ],
          status: 'coming_soon',
          sortOrder: 11,
          price1m: 50000,
          price6m: 250000,
          price1y: 450000,
        ),

        // ── 7. SEJARAH & SIRAH ────────────────────────────────
        AgentModel(
          id: 'tarikh',
          title: 'AI Sejarah & Sirah',
          titleArabic: 'السيرة والتاريخ',
          description:
              'Rekam jejak Sirah Nabawiyyah, Khulafaur Rasyidin, dan thabaqat ulama salaf.',
          emoji: '📜',
          category: 'Sejarah',
          fieldId: 'tarikh',
          subtitleAcademic: 'Sirah Ibnu Hisyam & Tarikh Thabari',
          suggestedPrompts: [
            'Rincikan kronologi Perang Badar dari Sirah Ibnu Hisyam!',
            'Bagaimana riwayat musyawarah Tsaqifah Bani Sa\'idah?',
            'Biografi singkat dan thabaqat Imam An-Nawawi!',
          ],
          status: 'coming_soon',
          sortOrder: 12,
          price1m: 50000,
          price6m: 250000,
          price1y: 450000,
        ),

        // ── 8. TASAWUF & ULAMA ────────────────────────────────
        AgentModel(
          id: 'habib_umar',
          title: 'AI Habib Umar bin Hafizh',
          titleArabic: 'الحبيب عمر بن حفيظ',
          description:
              'Kitab dan rekaman muhadharah Habib Umar bin Hafizh dengan rujukan terpercaya.',
          emoji: '🕌',
          category: 'Kajian Ulama',
          kind: CorpusKind.scholar,
          scholarIds: const ['habib_umar'],
          disciplineIds: const ['tasawwuf'],
          fieldId: 'tasawwuf',
          subtitleAcademic: 'Kitab & Ribuan Muhadharah Tarim',
          suggestedPrompts: [
            'Nasihat Habib Umar mengenai adab menuntut ilmu di era fitnah digital.',
            'Kutipan dari kitab Taujih Al-Nabih tentang penyucian hati.',
            'Amalan wirid harian dan dzikir yang diajarkan di Darul Musthafa.',
          ],
          status: 'coming_soon',
          sortOrder: 13,
        ),
        AgentModel(
          id: 'imam_ghazali',
          title: 'AI Hujjatul Islam Al-Ghazali',
          titleArabic: 'حجة الإسلام الغزالي',
          description:
              'Kajian kitab Ihya Ulumuddin, Al-Mustashfa, Tahafut al-Falasifah, dan karya-karya Imam Al-Ghazali.',
          emoji: '🕯️',
          category: 'Kajian Ulama',
          kind: CorpusKind.scholar,
          scholarIds: const ['imam_ghazali'],
          disciplineIds: const ['tasawwuf', 'usul', 'aqidah'],
          fieldId: 'tasawwuf',
          subtitleAcademic: 'Ihya Ulumiddin & Naskah Hujjatul Islam',
          suggestedPrompts: [
            'Bagaimana pembagian ilmu terpuji dan tercela dalam Kitab Al-Ilm Ihya Ulumiddin?',
            'Penjelasan konsep qalb dan ruh menurut Imam Al-Ghazali.',
            'Kaidah maslahah mursalah dan maqashid syariah dalam Al-Mustashfa.',
          ],
          status: 'coming_soon',
          sortOrder: 14,
        ),
      ];
}

```

### FLUTTER FILE: openturath_ai/lib/models/book_model.dart
```dart
import 'dart:convert';

/// Legacy book reference model used in [AgentModel].
class BookModel {
  final String title;
  final String titleArabic;
  final String author;
  final String description;
  final String? url;

  BookModel({
    required this.title,
    required this.titleArabic,
    required this.author,
    required this.description,
    this.url,
  });
}

/// Raw imported canonical catalog entry from dataset (e.g. canonical_syafii.json).
/// Preserves raw bibliographical fields without premature editorial assumptions.
class CanonicalEntry {
  const CanonicalEntry({
    required this.legacyKey,
    required this.titleArabic,
    required this.shortTitleArabic,
    required this.authorArabic,
    required this.authorFull,
    required this.recordedDeathYearHijri,
    required this.eraCode,
    required this.textTypeCode,
    required this.recordedAuthorityRank,
    required this.recordedVolumes,
    required this.publisher,
    required this.muhaqqiq,
    required this.raw,
  });

  final String legacyKey;
  final String titleArabic, shortTitleArabic, authorArabic, authorFull;
  final int? recordedDeathYearHijri;
  final String? eraCode, textTypeCode;
  final int? recordedAuthorityRank, recordedVolumes;
  final String? publisher, muhaqqiq;
  final Map<String, dynamic> raw;

  factory CanonicalEntry.fromLegacy(
    String key,
    Map<String, dynamic> row,
  ) {
    String? text(String name) {
      final value = row[name];
      if (value == null) return null;
      if (value is! String) {
        throw FormatException('$key: $name harus berupa teks');
      }
      final clean = value.trim();
      return clean.isEmpty ? null : clean;
    }

    String requiredText(String name) {
      final value = text(name);
      if (value == null) throw FormatException('$key: $name kosong');
      return value;
    }

    int? integer(String name) {
      final value = row[name];
      if (value == null || value == '') return null;
      if (value is! int || value < 0) {
        throw FormatException('$key: $name harus integer nonnegatif');
      }
      return value;
    }

    return CanonicalEntry(
      legacyKey: key,
      titleArabic: requiredText('full_title'),
      shortTitleArabic: requiredText('canonical_short_title'),
      authorArabic: requiredText('author_canonical'),
      authorFull: requiredText('author_full'),
      recordedDeathYearHijri: integer('death_year_hijri'),
      eraCode: text('era'),
      textTypeCode: text('text_type'),
      recordedAuthorityRank: integer('authority_rank'),
      recordedVolumes: integer('volumes_count'),
      publisher: text('publisher'),
      muhaqqiq: text('muhaqqiq'),
      raw: Map<String, dynamic>.unmodifiable(row),
    );
  }
}

class CanonicalImport {
  const CanonicalImport(this.entries, this.issues);
  final List<CanonicalEntry> entries;
  final List<String> issues; // Internal validation log; bukan copy publik.
}

CanonicalImport parseCanonicalCatalog(String source) {
  final root = jsonDecode(source);
  if (root is! Map<String, dynamic>) {
    throw const FormatException('Root katalog harus object JSON');
  }
  final entries = <CanonicalEntry>[];
  final issues = <String>[];
  for (final item in root.entries) {
    try {
      final row = item.value;
      if (row is! Map<String, dynamic>) {
        throw FormatException('${item.key}: entri bukan object');
      }
      entries.add(CanonicalEntry.fromLegacy(item.key, row));
    } on FormatException catch (error) {
      issues.add(error.message.toString());
    }
  }
  return CanonicalImport(
    List<CanonicalEntry>.unmodifiable(entries),
    List<String>.unmodifiable(issues),
  );
}

/// Presentation model for catalog books reviewed for display.
/// Prevents UI widgets from turning unverified authority ranks into scientific claims.
class CanonicalBookPresentation {
  const CanonicalBookPresentation({
    required this.editionId,
    required this.titleArabic,
    required this.authorArabic,
    this.titleLatin,
    this.authorLatin,
    this.verifiedDeathYearHijri,
    this.reviewedTypeLabel,
    this.reviewedEraLabel,
    this.reviewedAuthorityLabel,
    this.authorityEvidence,
    this.publisher,
    this.muhaqqiq,
    this.volumesCount,
  });

  final String editionId, titleArabic, authorArabic;
  final String? titleLatin, authorLatin;
  final int? verifiedDeathYearHijri;
  final String? reviewedTypeLabel, reviewedEraLabel;
  final String? reviewedAuthorityLabel, authorityEvidence;
  final String? publisher, muhaqqiq;
  final int? volumesCount;

  List<String> get compactLabels => [
        if (reviewedTypeLabel != null) reviewedTypeLabel!,
        if (reviewedEraLabel != null) reviewedEraLabel!,
        if (volumesCount != null && volumesCount! > 1) '$volumesCount Jilid',
      ];

  bool get canShowAuthority =>
      reviewedAuthorityLabel?.isNotEmpty == true &&
      authorityEvidence?.isNotEmpty == true;

  factory CanonicalBookPresentation.fromEntry(CanonicalEntry entry) {
    String? typeLabel;
    if (entry.textTypeCode != null) {
      switch (entry.textTypeCode) {
        case 'asl_al_madhhab':
          typeLabel = 'Asal Mazhab';
          break;
        case 'matn':
          typeLabel = 'Matan';
          break;
        case 'sharh':
          typeLabel = 'Syarah';
          break;
        case 'hashiyah':
          typeLabel = 'Hasyiyah';
          break;
        case 'khilafiyyat':
          typeLabel = 'Khilafiyyah';
          break;
        case 'fatawa':
          typeLabel = 'Fatwa';
          break;
        case 'ajwibah':
          typeLabel = 'Ajwibah';
          break;
        case 'qawaid':
          typeLabel = 'Qawa\'id';
          break;
        default:
          typeLabel = entry.textTypeCode!.replaceAll('_', ' ');
      }
    }

    String? eraLabel;
    if (entry.eraCode != null) {
      switch (entry.eraCode) {
        case 'mutaqaddimin':
          eraLabel = 'Mutaqaddimin';
          break;
        case 'ashab_al_wujuh':
          eraLabel = 'Ashab Al-Wujuh';
          break;
        case 'mutaakhkhirin':
          eraLabel = 'Muta\'akhkhirin';
          break;
        default:
          eraLabel = entry.eraCode!.replaceAll('_', ' ');
      }
    }

    return CanonicalBookPresentation(
      editionId: entry.legacyKey,
      titleArabic: entry.titleArabic,
      authorArabic: entry.authorArabic,
      titleLatin: null,
      authorLatin: null,
      verifiedDeathYearHijri: entry.recordedDeathYearHijri,
      reviewedTypeLabel: typeLabel,
      reviewedEraLabel: eraLabel,
      reviewedAuthorityLabel: null, // Held until editorial consensus
      authorityEvidence: null,
      publisher: entry.publisher,
      muhaqqiq: entry.muhaqqiq,
      volumesCount: entry.recordedVolumes,
    );
  }
}

```

### FLUTTER FILE: openturath_ai/lib/models/bookmark_model.dart
```dart
class BookmarkModel {
  final String id;
  final String title;
  final String agentId;
  final String agentTitle;
  final String fieldName;
  final String fieldId;
  final String arabicExcerpt;
  final String fullAnswer;
  final String bookReference;
  final String pageNumber;
  final String? author;
  final DateTime createdAt;

  BookmarkModel({
    required this.id,
    required this.title,
    required this.agentId,
    required this.agentTitle,
    required this.fieldName,
    required this.fieldId,
    required this.arabicExcerpt,
    required this.fullAnswer,
    required this.bookReference,
    required this.pageNumber,
    this.author,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'agentId': agentId,
      'agentTitle': agentTitle,
      'fieldName': fieldName,
      'fieldId': fieldId,
      'arabicExcerpt': arabicExcerpt,
      'fullAnswer': fullAnswer,
      'bookReference': bookReference,
      'pageNumber': pageNumber,
      'author': author,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    return BookmarkModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      agentId: json['agentId'] as String? ?? '',
      agentTitle: json['agentTitle'] as String? ?? '',
      fieldName: json['fieldName'] as String? ?? '',
      fieldId: json['fieldId'] as String? ?? 'fiqh',
      arabicExcerpt: json['arabicExcerpt'] as String? ?? '',
      fullAnswer: json['fullAnswer'] as String? ?? '',
      bookReference: json['bookReference'] as String? ?? '',
      pageNumber: json['pageNumber'] as String? ?? '',
      author: json['author'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

```

### FLUTTER FILE: openturath_ai/lib/models/field_model.dart
```dart
import 'package:flutter/material.dart';

class FieldModel {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final int specialistCount;
  final List<String> agentIds;

  const FieldModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.specialistCount,
    required this.agentIds,
  });

  /// 9 Bidang Keilmuan Utama Turats Islam
  static const List<FieldModel> defaultFields = [
    FieldModel(
      id: 'fiqh_tahawwulat',
      name: 'Fikih Tahawwulat',
      description: 'Manhaj eskatologi Islam, rukun keempat, tanda-tanda zaman, dan sanad Al-Habib Abu Bakar Al-Masyhur.',
      icon: Icons.hourglass_bottom_rounded,
      specialistCount: 1,
      agentIds: [
        'fiqh_tahawwulat',
      ],
    ),
    FieldModel(
      id: 'fiqh',
      name: 'Fikih',
      description: 'Hukum ibadah, muamalah, fatwa, dan perbandingan mazhab mu\'tabar.',
      icon: Icons.balance_rounded,
      specialistCount: 5,
      agentIds: [
        'fiqh_syafii',
        'fiqh_hanafi',
        'fiqh_maliki',
        'fiqh_hanbali',
        'fiqh_muqaran',
      ],
    ),
    FieldModel(
      id: 'hadith',
      name: 'Hadits',
      description: 'Takhrij sanad, dirayah perawi, dan syarah Kutubus Sittah.',
      icon: Icons.auto_stories_rounded,
      specialistCount: 1,
      agentIds: [
        'hadits',
      ],
    ),
    FieldModel(
      id: 'tafsir',
      name: 'Tafsir',
      description: 'Asbabun nuzul, munasabah, dan khazanah tafsir bil-ma\'tsur wal-ra\'yi.',
      icon: Icons.menu_book_rounded,
      specialistCount: 1,
      agentIds: [
        'tafsir',
      ],
    ),
    FieldModel(
      id: 'aqidah',
      name: 'Aqidah',
      description: 'Kalam Asy\'ariyyah, Maturidiyyah, pembelaan ushuludin, dan dalil aqli-naqli.',
      icon: Icons.shield_outlined,
      specialistCount: 1,
      agentIds: [
        'aqidah',
      ],
    ),
    FieldModel(
      id: 'usul',
      name: 'Usul Fiqh',
      description: 'Kaidah istinbath hukum, dalil ijmali, maqashid syariah, dan qawaid fiqhiyyah.',
      icon: Icons.architecture_rounded,
      specialistCount: 1,
      agentIds: [
        'ushul_fiqh',
      ],
    ),
    FieldModel(
      id: 'lughah',
      name: 'Bahasa Arab',
      description: 'Nahwu, sharaf, balaghah, dan leksikografi kamus mu\'jam klasik.',
      icon: Icons.translate_rounded,
      specialistCount: 1,
      agentIds: [
        'nahwu_sharaf',
      ],
    ),
    FieldModel(
      id: 'tarikh',
      name: 'Sejarah & Sirah',
      description: 'Sirah Nabawiyyah, khulafaur rasyidin, thabaqat ulama, dan peradaban Islam.',
      icon: Icons.history_edu_rounded,
      specialistCount: 1,
      agentIds: [
        'tarikh',
      ],
    ),
    FieldModel(
      id: 'tasawwuf',
      name: 'Tasawuf & Akhlaq',
      description: 'Penyucian jiwa (tazkiyatun nafs), adab suluk, dan hikmah ulama salafush shalih.',
      icon: Icons.spa_rounded,
      specialistCount: 2,
      agentIds: [
        'habib_umar',
        'imam_ghazali',
      ],
    ),
  ];

  static FieldModel? findById(String id) {
    for (final f in defaultFields) {
      if (f.id == id) return f;
    }
    return null;
  }

  static FieldModel getById(String id) {
    return findById(id) ??
        const FieldModel(
          id: 'umum',
          name: 'Umum & Turats',
          description: 'Beragam kajian dari kitab-kitab Islam.',
          icon: Icons.menu_book_rounded,
          specialistCount: 0,
          agentIds: [],
        );
  }
}

```

### FLUTTER FILE: openturath_ai/lib/models/sub_agent_model.dart
```dart
class SubAgentModel {
  final String id;
  final String name;
  final String nameArabic;
  final String description;
  final String descriptionArabic;
  final String emoji;
  final String badge; // e.g. "Riset Mendalam", "Penjelasan Luas"

  SubAgentModel({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.description,
    required this.descriptionArabic,
    required this.emoji,
    required this.badge,
  });
}

```

### FLUTTER FILE: openturath_ai/lib/models/user_model.dart
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';
import '../core/entitlement_keys.dart';

/// Model Hak Akses Per Modul Notebook / Kitab (Canonical Entitlement)
class ModuleEntitlement {
  final String plan;
  final DateTime? expiry;
  final String status; // 'active', 'expired', 'trial'
  final String? sourceTransactionId;
  final DateTime? updatedAt;

  const ModuleEntitlement({
    required this.plan,
    this.expiry,
    this.status = 'active',
    this.sourceTransactionId,
    this.updatedAt,
  });

  bool get isPremium => RegExp(r'^(tholib(?:_1m|_6m)?|bahits(?:_1y)?|premium|all_access|all_ai.*|single|sultan|pro|voucher(?:_.*)?|redeem(?:_.*)?|custom|full)$').hasMatch(plan);

  bool get isActive =>
      status != 'revoked' &&
      status != 'expired' &&
      expiry != null &&
      expiry!.isAfter(DateTime.now());

  factory ModuleEntitlement.fromMap(Map<String, dynamic> map) {
    return ModuleEntitlement(
      plan: map['plan'] ?? AppConstants.planTrial,
      expiry: map['expiry'] != null
          ? (map['expiry'] is Timestamp
              ? (map['expiry'] as Timestamp).toDate()
              : DateTime.tryParse(map['expiry'].toString()))
          : null,
      status: map['status'] ?? 'active',
      sourceTransactionId: map['source_transaction_id'] ?? map['trx_id'],
      updatedAt: map['updated_at'] != null
          ? (map['updated_at'] is Timestamp
              ? (map['updated_at'] as Timestamp).toDate()
              : DateTime.tryParse(map['updated_at'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'plan': plan,
        'expiry': expiry != null ? Timestamp.fromDate(expiry!) : null,
        'status': status,
        'source_transaction_id': sourceTransactionId,
        'updated_at': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      };

  Map<String, dynamic> toJsonMap() => {
        'plan': plan,
        'expiry': expiry?.toIso8601String(),
        'status': status,
        'source_transaction_id': sourceTransactionId,
        'updated_at': updatedAt?.toIso8601String(),
      };
}

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String photoUrl;
  final String plan; // Legacy global plan fallback
  final int questionsUsed;
  final DateTime? subscriptionExpiry; // Legacy global expiry fallback
  final Map<String, ModuleEntitlement> entitlements;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.plan,
    required this.questionsUsed,
    this.subscriptionExpiry,
    this.entitlements = const {},
  });

  // ── Global Legacy Helpers ──
  bool get isTrial => plan == AppConstants.planTrial || plan == 'trial';
  bool get isGuest => email.isEmpty || uid.startsWith('guest_');
  bool get isPremium =>
      !isTrial &&
      plan != 'free' &&
      (plan == AppConstants.planTholib1m ||
          plan == AppConstants.planTholib6m ||
          plan == AppConstants.planBahits1y ||
          plan == 'tholib' ||
          plan == 'bahits' ||
          plan == 'all_ai_1m' ||
          plan == 'all_ai_6m' ||
          plan == 'all_ai_1y' ||
          plan == 'all_access' ||
          plan == 'all_ai' ||
          plan == 'full' ||
          plan == 'sultan' ||
          plan == 'pro' ||
          plan == 'premium' ||
          plan.startsWith('all_ai') ||
          plan.startsWith('redeem') ||
          plan.startsWith('voucher') ||
          plan == 'custom' ||
          (subscriptionExpiry != null && subscriptionExpiry!.isAfter(DateTime.now())));

  bool get isSubscriptionActive {
    if (isPremium && subscriptionExpiry != null) {
      return subscriptionExpiry!.isAfter(DateTime.now());
    }
    return false;
  }

  bool get hasAccess {
    if (isSubscriptionActive) return true;
    if (isTrial && questionsUsed < AppConstants.trialQuestionLimit) return true;
    return false;
  }

  int get questionsRemaining {
    if (isPremium) return 9999;
    return AppConstants.trialQuestionLimit - questionsUsed;
  }

  bool get isTrialExhausted =>
      isTrial && questionsUsed >= AppConstants.trialQuestionLimit;

  // ── Modular Entitlement Helpers ──
  ModuleEntitlement? getEntitlement(String agentId) => entitlements[entitlementKeys[agentId] ?? agentId];

  bool isAgentSubscriptionActive(String agentId) {
    // 1. Explicit all_access entitlement
    final all = entitlements['all_access'] ?? entitlements['all_ai'];
    if (all != null && all.isActive && all.isPremium) return true;

    // 2. Specific module entitlement
    final specific = getEntitlement(agentId);
    if (specific != null && specific.isActive && specific.isPremium) return true;

    // If an explicit all_access was REVOKED, deny fallback
    if (all != null && all.status == 'revoked') {
      return false;
    }

    // 3. Account-level active subscription (tholib_1m, tholib_6m, bahits_1y, all_ai*, sultan, full, voucher, etc.)
    if (isSubscriptionActive) {
      if (plan == 'single') {
        return specific != null && specific.isActive && specific.isPremium;
      }
      return true;
    }

    // 4. Fallback legacy plan check
    const legacyPlans = [
      'all_access',
      'all_ai_1m',
      'all_ai_6m',
      'all_ai_1y',
      'all_ai',
      'full',
      'sultan',
      'tholib_1m',
      'tholib_6m',
      'bahits_1y',
      'tholib',
      'bahits',
      'pro',
      'premium',
      'custom',
    ];
    final isLegacyMatching = legacyPlans.contains(plan) ||
        plan.startsWith('all_ai') ||
        plan.startsWith('redeem') ||
        plan.startsWith('voucher');
    return isLegacyMatching && isSubscriptionActive;
  }

  bool hasAccessToAgent(String agentId) {
    // Akses notebook memerlukan hak akses langganan atau voucher aktif (F24: hapus jalur trial tanpa batas server)
    return isAgentSubscriptionActive(agentId);
  }

  int questionsRemainingForAgent(String agentId) {
    if (isAgentSubscriptionActive(agentId)) return 9999;
    return AppConstants.trialQuestionLimit - questionsUsed;
  }

  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    // Parse entitlements map
    final Map<String, ModuleEntitlement> parsedEntitlements = {};
    if (data['entitlements'] != null && data['entitlements'] is Map) {
      final rawMap = data['entitlements'] as Map<String, dynamic>;
      rawMap.forEach((key, val) {
        if (val is Map<String, dynamic>) {
          parsedEntitlements[key] = ModuleEntitlement.fromMap(val);
        }
      });
    }

    DateTime? expiry;
    if (data['subscription_expiry'] != null) {
      final exp = data['subscription_expiry'];
      if (exp is Timestamp) {
        expiry = exp.toDate();
      } else if (exp is String) {
        expiry = DateTime.tryParse(exp);
      } else if (exp is int) {
        expiry = DateTime.fromMillisecondsSinceEpoch(exp);
      }
    }

    return UserModel(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photo_url'] ?? '',
      plan: data['plan'] ?? AppConstants.planTrial,
      questionsUsed: data['questions_used'] ?? 0,
      subscriptionExpiry: expiry,
      entitlements: parsedEntitlements,
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel.fromMap(doc.id, data);
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'photo_url': photoUrl,
        'plan': plan,
        'questions_used': questionsUsed,
        'subscription_expiry': subscriptionExpiry != null
            ? Timestamp.fromDate(subscriptionExpiry!)
            : null,
        'entitlements': entitlements.map((k, v) => MapEntry(k, v.toMap())),
      };

  Map<String, dynamic> toJsonMap() => {
        'name': name,
        'email': email,
        'photo_url': photoUrl,
        'plan': plan,
        'questions_used': questionsUsed,
        'subscription_expiry': subscriptionExpiry?.toIso8601String(),
        'entitlements': entitlements.map((k, v) => MapEntry(k, v.toJsonMap())),
      };

  UserModel copyWith({
    int? questionsUsed,
    String? plan,
    DateTime? subscriptionExpiry,
    Map<String, ModuleEntitlement>? entitlements,
  }) {
    return UserModel(
      uid: uid,
      name: name,
      email: email,
      photoUrl: photoUrl,
      plan: plan ?? this.plan,
      questionsUsed: questionsUsed ?? this.questionsUsed,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      entitlements: entitlements ?? this.entitlements,
    );
  }
}

```

### FLUTTER FILE: openturath_ai/lib/screens/agent_webview_screen.dart
```dart
import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/notebook_navigation.dart';
import '../core/notebook_ui_script.dart';
import '../core/copied_answer.dart';

import '../core/app_copy.dart';
import '../core/app_snackbar.dart';
import '../core/constants.dart';
import '../core/routes.dart';
import '../core/theme.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_motion.dart';
import '../core/design/ot_spacing.dart';
import '../models/agent_model.dart';
import '../models/user_model.dart';
import '../services/agent_service.dart';
import '../services/auth_service.dart';
import '../services/bookmark_service.dart';
import '../widgets/app_error_state.dart';
import '../widgets/app_loader.dart';
import '../widgets/library_bottom_sheet.dart';

/// AgentWebviewScreen: Tampilan Ruang Kajian NotebookLM
/// Dilengkapi App Bar native yang bersih di bawah kamera notch/status bar,
/// tombol kembali yang jelas, dan injeksi CSS/JS untuk menyembunyikan header Google.
class AgentWebviewScreen extends StatefulWidget {
  final AgentModel? agent;
  const AgentWebviewScreen({super.key, this.agent});

  /// Kebijakan keamanan URL: Hanya izinkan HTTPS pada ekosistem resmi Google NotebookLM
  static bool isAllowedNotebookUrl(Uri uri) => NotebookNavigation.allowed(uri);

  @override
  State<AgentWebviewScreen> createState() => _AgentWebviewScreenState();
}

class _AgentWebviewScreenState extends State<AgentWebviewScreen> {
  final AgentService _agentService = AgentService();
  final AuthService _authService = AuthService();

  final BookmarkService _bookmarkService = BookmarkService();

  InAppWebViewController? _webController;
  AgentModel? _agent;
  UserModel? _user;

  String? _agentUrl;
  bool _isLoadingUrl = true;
  bool _isWebViewLoading = true;
  bool _isPaywallRequired = false;
  String? _errorMessage;
  double _fontScale = 1.0;
  bool _isCopying = false;
  Timer? _readinessTimer;
  DateTime? _loadingStarted;
  int _readySamples = 0;
  bool _checkingReady = false;
  bool _hasCopied = false;

  bool _isGoingBack = false;

  @override
  void initState() {
    super.initState();
    _loadFontScale();
  }

  Future<void> _loadFontScale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getDouble('turath_font_zoom_level') ?? 1.0;
      final scale = value.isFinite ? value.clamp(0.85, 2.0).toDouble() : 1.0;
      if (mounted) {
        setState(() => _fontScale = scale);
      }
    } catch (_) {}
  }

  Future<void> _setFontScale(double scale) async {
    if (!mounted || !scale.isFinite) return;
    scale = scale.clamp(0.85, 2.0).toDouble();
    setState(() => _fontScale = scale);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('turath_font_zoom_level', scale);
      if (!mounted) return;
      await _applyCurrentFontScale();
    } catch (_) {}
  }

  Future<void> _applyCurrentFontScale() async {
    if (_webController == null) return;
    try {
      await _webController!.evaluateJavascript(
        source: 'if (typeof applyTurathFontScale === "function") { applyTurathFontScale($_fontScale); }',
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _readinessTimer?.cancel();
    final controller = _webController;
    _webController = null;
    if (controller != null) {
      unawaited(_stopWebView(controller));
    }
    super.dispose();
  }

  static Future<void> _stopWebView(InAppWebViewController controller) async {
    try { await controller.stopLoading(); } catch (_) {}
  }

  static const String _turatsMasterScript = r"""
    (function() {
      if (window.top !== window || !['notebooklm.google.com', 'notebook.google.com'].includes(location.hostname)) return;

      // 1. Injeksi Style CSS: Sembunyikan Header Resmi, Logo Google & NotebookLM
      var styleId = 'ot-hide-controls';
      var existingStyle = document.getElementById(styleId);
      if (!existingStyle) {
        var style = document.createElement('style');
        style.id = styleId;
        style.type = 'text/css';
        style.textContent = `
          /* Header, Top Bar, Logo, dan Banner Google NotebookLM */
          top-bar, .top-bar, header, .header, .app-header, app-header,
          mat-toolbar, [role="banner"], .header-container, .header-row,
          .mobile-header, div[class*="mobile-header" i],
          labs-tailwind-logo, a.logo-link, .logo-container,
          a[aria-label*="Homepage" i], a[aria-label*="NotebookLM" i], a[aria-label*="Gemini" i],
          .title-input, input.title-input, .title-container, .notebook-title,
          .notebook-header, app-notebook-header, .title-card, mat-card.title-card,
          div[class*="title-card" i], div[class*="notebook-header" i],
          .project-header, div.source-badge-container,
          app-chat-guide, .chat-guide, div[class*="landing" i], div[class*="banner" i],
          .pro-badge,
          /* Google Account Bar, App Launcher & Setelan */
          #gb, #gbwa, .gb_C, .gb_9a, .gb_8, .gb_U, div[id*="gb"],
          button[aria-label*="Settings" i], button[aria-label*="Setelan" i],
          button.mat-tonal-button, a[aria-label*="Google" i] {
            display: none !important;
            visibility: hidden !important;
            height: 0px !important;
            max-height: 0px !important;
            overflow: hidden !important;
            margin: 0px !important;
            padding: 0px !important;
            font-size: 0px !important;
            line-height: 0px !important;
            opacity: 0 !important;
            pointer-events: none !important;
            border: none !important;
          }
          ::-webkit-scrollbar { display: none !important; width: 0px !important; }
          html, body, * { scrollbar-width: none !important; }
          /* Padding atas dan bawah agar percakapan tidak terpotong */
          .chat-panel-content, .chat-view, .conversation-container, .message-list, main {
            padding-top: 14px !important;
            padding-bottom: 24px !important;
            margin-top: 0px !important;
          }
        `;
        (document.head || document.documentElement).appendChild(style);
      }

      // 2. Font Scale Presisi
      window.applyTurathFontScale = function(value) {
        var scale = Number(value);
        if (!Number.isFinite(scale)) return;
        scale = Math.max(0.85, Math.min(2, scale));
        var fontStyle = document.getElementById('ot-font-scale-style');
        if (!fontStyle) {
          fontStyle = document.createElement('style');
          fontStyle.id = 'ot-font-scale-style';
          (document.head || document.documentElement).appendChild(fontStyle);
        }
        fontStyle.textContent = `
          .chat-panel-content, .chat-view, .conversation-container, .message-list, [role="article"] {
            font-size: ${Math.round(scale * 15)}px !important;
            line-height: 1.65 !important;
          }
          .chat-panel-content p, .chat-view p, [role="article"] p,
          .chat-panel-content span, .chat-view span, [role="article"] span,
          .chat-panel-content li, .chat-view li, [role="article"] li {
            font-size: inherit !important;
            line-height: inherit !important;
          }
          [lang="ar"], .arabic {
            font-size: ${Math.round(scale * 19)}px !important;
            line-height: 1.8 !important;
          }
        `;
      };
    })();
  """;

  static final _cloakScript = UserScript(
    source: _turatsMasterScript + notebookUiScript,
    injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
    forMainFrameOnly: true,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_agent == null) {
      final rawArgs = ModalRoute.of(context)?.settings.arguments;
      if (rawArgs is Map<String, dynamic>) {
        _agent = rawArgs['agent'] as AgentModel?;
        _user = rawArgs['user'] as UserModel?;
      } else if (rawArgs is AgentModel) {
        _agent = rawArgs;
      }
      _agent ??= widget.agent ?? AgentModel.defaultAgents.first;
      _fetchAgentUrl();
    }
  }

  Future<void> _fetchAgentUrl() async {
    _readinessTimer?.cancel();
    setState(() {
      _isLoadingUrl = true;
      _isWebViewLoading = true;
      _isPaywallRequired = false;
      _agentUrl = null;
      _errorMessage = null;
    });

    // 0. Cek apakah modul masih berstatus 'coming_soon'
    if (_agent != null && _agent!.isComingSoon) {
      setState(() {
        _isLoadingUrl = false;
        _errorMessage = AppCopy.preparingModule(_agent!.title);
      });
      return;
    }

    // 1. Pastikan profil pengguna termuat untuk verifikasi hak akses
    _user ??= await _authService.getCurrentUserModel();
    if (!mounted) return;

    // 2. Cek hak akses akun pengguna
    if (_user == null || !_user!.hasAccessToAgent(_agent!.id)) {
      setState(() {
        _isPaywallRequired = true;
        _errorMessage = AppCopy.subscriptionRequiredFor(_agent!.title);
        _isLoadingUrl = false;
      });
      return;
    }

    try {
      final url = await _agentService.getAgentUrl(_agent!.id);
      if (!mounted) return;
      if (url == null || url.isEmpty) {
        setState(() {
          _errorMessage = AppCopy.moduleUnavailable;
          _isLoadingUrl = false;
        });
        return;
      }
      setState(() {
        _agentUrl = url;
        _isLoadingUrl = false;
      });
      _checkAndShowAdabDialog();
    } catch (e) {
      if (!mounted) return;
      if (e is AgentAccessException && (e.code == 'permission-denied' || e.code == 'unauthenticated')) {
        setState(() {
          _errorMessage = e.message;
          _isPaywallRequired = true;
          _isLoadingUrl = false;
        });
        return;
      }
      setState(() {
        _errorMessage = e is AgentAccessException
            ? e.message
            : AppCopy.studyNotLoadedYet;
        _isPaywallRequired = false;
        _isLoadingUrl = false;
      });
    }
  }

  Future<void> _detectGoogleAccessDenied() async {
    if (_webController == null) return;
    try {
      final res = await _webController!.evaluateJavascript(source: """
        (function() {
          var bodyText = document.body ? (document.body.innerText || '') : '';
          if (bodyText.includes('You need access') || 
              bodyText.includes('You do not have access') || 
              bodyText.includes('Request access') ||
              document.querySelector('button[aria-label*="Request access"]') !== null ||
              document.querySelector('.auth-error') !== null) {
            return 'DENIED';
          }
          return 'OK';
        })();
      """);
      if (res == 'DENIED' && mounted) {
        setState(() {
          final alreadyEntitled = _user?.hasAccessToAgent(_agent?.id ?? '') ?? false;
          _isPaywallRequired = !alreadyEntitled;
          _isLoadingUrl = false;
          _isWebViewLoading = false;
          _errorMessage = alreadyEntitled
              ? 'Hak akses sudah tercatat. NotebookLM belum mengenali akun ini. Pastikan akun Google sesuai, lalu coba muat kembali.'
              : AppCopy.accessUnavailableFor(_agent?.title ?? 'kajian ini');
        });
      }
    } catch (_) {}
  }

  Future<void> _applyHideScript() async {
    if (_webController == null) return;
    try {
      await _webController!.evaluateJavascript(source: _turatsMasterScript + notebookUiScript);
      await _applyThemeCss();
    } catch (_) {}
  }

  Future<void> _applyThemeCss() async {
    if (_webController == null) return;
    // We let InAppWebViewSettings.forceDark handle dark mode natively,
    // avoiding destructive DOM color injections that cause black-on-black text.
    try {
      await _applyCurrentFontScale();
    } catch (_) {}
  }

  Future<void> _saveCopiedAnswer(String text, String ownerUid) async {
    text = text.trim();
    if (text.isEmpty || text.length > 200000 || _authService.currentUser?.uid != ownerUid) return;
    final agent = _agent;
    if (agent == null) return;
    await _bookmarkService.addBookmark(copiedAnswerBookmark(text, agent), userId: ownerUid);
  }

  Future<void> _copyLatestResponse() async {
    if (_webController == null || _isCopying) return;
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;
    setState(() => _isCopying = true);
    try {
      final result = await _webController!.evaluateJavascript(source: 'window.otNotebook ? window.otNotebook.latest() : ""');
      final text = result is String ? result.trim() : '';
      if (text.isEmpty) {
        if (mounted) AppSnackBar.warning(context, AppCopy.noAnswerToCopy);
        return;
      }
      await Clipboard.setData(ClipboardData(text: text));
      await _saveCopiedAnswer(text, uid);
      if (mounted) {
        setState(() => _hasCopied = true);
        AppSnackBar.success(context, 'Jawaban disalin dan ditambahkan ke Tersimpan.');
      }
    } catch (_) {
      if (mounted) AppSnackBar.error(context, 'Jawaban belum berhasil disalin dan disimpan. Coba lagi.');
    } finally {
      if (mounted) setState(() => _isCopying = false);
    }
  }

  void _startReadinessCheck() {
    _readinessTimer?.cancel();
    _loadingStarted = DateTime.now();
    _readySamples = 0;
    _readinessTimer = Timer.periodic(const Duration(milliseconds: 500), (_) => _checkReady());
  }

  Future<void> _checkReady() async {
    if (_checkingReady || _webController == null || !mounted) return;
    _checkingReady = true;
    try {
      final url = await _webController!.getUrl();
      final isLogin = url?.host == 'accounts.google.com' || url?.host == 'accounts.youtube.com' || url?.host == 'consent.google.com';
      final result = await _webController!.evaluateJavascript(source: 'window.otNotebook ? window.otNotebook.ready() : false');
      _readySamples = result == true ? _readySamples + 1 : 0;
      if (!mounted) return;
      if (isLogin || _readySamples >= 3) {
        _readinessTimer?.cancel();
        setState(() => _isWebViewLoading = false);
      } else if (DateTime.now().difference(_loadingStarted!).inSeconds >= 45) {
        _readinessTimer?.cancel();
        setState(() {
          _isWebViewLoading = false;
          _errorMessage = 'AI belum siap merespons. Periksa koneksi lalu coba muat kembali.';
        });
      }
    } catch (_) {
      if (mounted && _loadingStarted != null && DateTime.now().difference(_loadingStarted!).inSeconds >= 45) {
        _readinessTimer?.cancel();
        setState(() { _isWebViewLoading = false; _errorMessage = AppCopy.cannotLoad; });
      }
    } finally { _checkingReady = false; }
  }

  Future<void> _handleBackPress() async {
    if (!mounted || _isGoingBack) return;
    _isGoingBack = true;
    final controller = _webController;
    try {
      final canGoBack = await controller?.canGoBack() ?? false;
      if (!mounted) return;
      if (canGoBack && controller != null && identical(controller, _webController)) {
        await controller.goBack();
      } else {
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) Navigator.pop(context);
    } finally {
      _isGoingBack = false;
    }
  }

  Future<void> _navigateToSubscription() async {
    final currentUser = _user ?? await AuthService().getCurrentUserModel();
    if (!mounted) return;
    await Navigator.pushNamed(
      context,
      AppRoutes.subscription,
      arguments: {
        'agent': _agent,
        'user': currentUser,
      },
    );
    if (!mounted) return;
    final refreshedUser = await AuthService().getCurrentUserModel();
    if (mounted && refreshedUser != null) {
      setState(() {
        _user = refreshedUser;
      });
      if (_isPaywallRequired && refreshedUser.hasAccessToAgent(_agent?.id ?? '')) {
        _fetchAgentUrl();
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvas = OTColors.canvas(isDark);
    final surfaceSubtle = OTColors.surfaceSubtle(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final accent = OTColors.accent(isDark);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackPress();
      },
      child: Scaffold(
        backgroundColor: canvas,
        appBar: AppBar(
          toolbarHeight: 56,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: canvas,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: textPrimary, size: 22),
            tooltip: 'Kembali',
            onPressed: _handleBackPress,
          ),
          titleSpacing: 0,
          title: Text(
            _agent?.title ?? AppCopy.studySpace,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: OTTypography.corpusTitle(color: textPrimary).copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            if (_user != null && _user!.plan == 'trial')
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Center(
                  child: InkWell(
                    onTap: _navigateToSubscription,
                    borderRadius: OTRadius.chipBorder,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: surfaceSubtle,
                        borderRadius: OTRadius.chipBorder,
                        border: Border.all(color: border, width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt_rounded, size: 12, color: accent),
                          const SizedBox(width: 3),
                          Text(
                            '${_user!.questionsRemaining}',
                            style: OTTypography.caption(color: textPrimary).copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            IconButton(
              icon: Icon(Icons.menu_book_outlined, color: textPrimary, size: 21),
              tooltip: AppCopy.referenceBooks,
              onPressed: () => showResearchLibrary(context, agent: _agent),
            ),
            IconButton(
              icon: Icon(Icons.more_horiz_rounded, color: textPrimary, size: 22),
              tooltip: AppCopy.studyOptions,
              onPressed: _showOverflowMenu,
            ),
            const SizedBox(width: OTSpacing.xs),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Stack(
            children: [
              // ── 1. WebView Layer (Safe Below App Bar) ──
              if (_agentUrl != null)
                Container(
                  color: isDark ? const Color(0xFF0E0E10) : const Color(0xFFFFFFFF),
                  child: InAppWebView(
                    initialUrlRequest: URLRequest(url: WebUri(_agentUrl!)),
                    initialUserScripts: UnmodifiableListView<UserScript>([_cloakScript]),
                    initialSettings: InAppWebViewSettings(
                      userAgent: AppConstants.chromeMobileUserAgent,
                      javaScriptEnabled: true,
                      domStorageEnabled: true,
                      databaseEnabled: true,
                      sharedCookiesEnabled: true,
                      thirdPartyCookiesEnabled: true,
                      cacheEnabled: true,
                      clearCache: false,
                      clearSessionCache: false,
                      useHybridComposition: true,
                      mixedContentMode: MixedContentMode.MIXED_CONTENT_NEVER_ALLOW,
                      allowFileAccess: false,
                      allowContentAccess: false,
                      javaScriptCanOpenWindowsAutomatically: false,
                      useShouldOverrideUrlLoading: true,
                      supportZoom: true,
                      builtInZoomControls: true,
                      displayZoomControls: false,
                      mediaPlaybackRequiresUserGesture: false,
                      allowsInlineMediaPlayback: true,
                      forceDark: isDark ? ForceDark.ON : ForceDark.OFF,
                      algorithmicDarkeningAllowed: false,
                      transparentBackground: true,
                    ),
                onWebViewCreated: (controller) {
                  _webController = controller;
                  final ownerUid = _authService.currentUser?.uid;
                  controller.addJavaScriptHandler(handlerName: 'otCopiedAnswer', callback: (args) async {
                    final url = await controller.getUrl();
                    if (ownerUid == null || url?.scheme != 'https' || !['notebooklm.google.com', 'notebook.google.com'].contains(url?.host) || args.isEmpty || args.first is! String) return false;
                    try {
                      await _saveCopiedAnswer(args.first as String, ownerUid);
                      if (context.mounted) AppSnackBar.success(context, 'Jawaban ditambahkan ke Tersimpan.');
                      return true;
                    } catch (_) {
                      if (context.mounted) AppSnackBar.error(context, 'Jawaban belum tersimpan. Coba salin lagi.');
                      return false;
                    }
                  });
                  _startReadinessCheck();
                },
                onLoadStart: (controller, url) {
                  if (mounted) setState(() => _isWebViewLoading = true);
                  _startReadinessCheck();
                },
                onPermissionRequest: (controller, request) async => PermissionResponse(
                  resources: request.resources, action: PermissionResponseAction.DENY,
                ),
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  final uri = navigationAction.request.url;
                  return uri != null && NotebookNavigation.allowed(uri)
                    ? NavigationActionPolicy.ALLOW : NavigationActionPolicy.CANCEL;
                },
                onLoadStop: (controller, url) async {
                  await _applyHideScript();
                  await _applyCurrentFontScale();
                  await _detectGoogleAccessDenied();
                  await _checkReady();
                },
                onProgressChanged: (controller, progress) async {
                  if (progress >= 25) {
                    await _applyHideScript();
                    await _detectGoogleAccessDenied();
                  }
                  if (progress >= 45) {
                    await _detectGoogleAccessDenied();

                  }
                },
                onReceivedError: (controller, request, error) {
                  if (mounted && (request.isForMainFrame == true)) {
                    setState(() {
                      _isWebViewLoading = false;
                      _errorMessage = AppCopy.cannotLoad;
                    });
                  }
                },
              ),
            ),

            // ── Loading Indicator Screen (Unified Three Dots Minimal Pulse) ──
            if (_isLoadingUrl || (_isWebViewLoading && _errorMessage == null))
              Positioned.fill(
                child: AppLoader.fullscreen(
                  title: _agent?.title ?? AppCopy.openStudy,
                  subtitle: AppCopy.loadingReferences,
                  onCancel: _handleBackPress,
                ),
              ),

            // ── 2. Error State Screen (Unified AppErrorState) ──
            if (_errorMessage != null && !_isLoadingUrl)
              Positioned.fill(
                child: Container(
                  color: canvas,
                  child: AppErrorState(
                    title: _isPaywallRequired
                        ? AppCopy.subscriptionRequiredTitle
                        : AppCopy.cannotLoadStudy,
                    message: _errorMessage!,
                    icon: _isPaywallRequired
                        ? Icons.workspace_premium_rounded
                        : Icons.info_outline_rounded,
                    onRetry: _isPaywallRequired
                        ? _navigateToSubscription
                        : _fetchAgentUrl,
                    retryLabel: _isPaywallRequired
                        ? AppCopy.viewSubscription
                        : AppCopy.tryAgain,
                    onBack: () => Navigator.pop(context),
                    backLabel: 'Kembali ke Beranda',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkAndShowAdabDialog() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeen = prefs.getBool('has_acknowledged_adab_talaqqi') ?? false;
      if (!hasSeen && mounted) {
        await _showAdabTalaqqiDialog();
        await prefs.setBool('has_acknowledged_adab_talaqqi', true);
      }
    } catch (_) {}
  }

  Future<void> _showAdabTalaqqiDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppTheme.surfaceCardDark : AppTheme.surfaceCardLight;
    final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final textPrimary = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: surface,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            side: BorderSide(color: border, width: 1.0),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.borderDark : AppTheme.pillSecondaryBgLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.verified_outlined,
                        size: 20,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppCopy.adabDialogTitle,
                        style: GoogleFonts.newsreader(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, size: 20, color: textSecondary),
                      onPressed: () => Navigator.pop(dialogCtx),
                      splashRadius: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'التعلم بالتلقي عن الأشياخ هو الأصل',
                  style: GoogleFonts.amiri(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFFD4D4D8) : const Color(0xFF3F3F46),
                  ),
                ),
                const SizedBox(height: 14),
                Divider(height: 1, color: border),
                const SizedBox(height: 14),
                _buildAdabPoint(
                  icon: Icons.menu_book_outlined,
                  title: AppCopy.adabHeading1,
                  description: AppCopy.adabBody1,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _buildAdabPoint(
                  icon: Icons.people_outline_rounded,
                  title: AppCopy.adabHeading2,
                  description: AppCopy.adabBody2,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _buildAdabPoint(
                  icon: Icons.fact_check_outlined,
                  title: AppCopy.adabHeading3,
                  description: AppCopy.adabBody3,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  isDark: isDark,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(dialogCtx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.white : const Color(0xFF18181B),
                      foregroundColor: isDark ? const Color(0xFF0E0E10) : Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                      ),
                    ),
                    child: Text(
                      AppCopy.adabAcknowledgeButton,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdabPoint({
    required IconData icon,
    required String title,
    required String description,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 16, color: isDark ? Colors.white : const Color(0xFF18181B)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  height: 1.35,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showOverflowMenu() {
    OTMotion.selection();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = OTColors.surface(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: OTRadius.sheetBorder,
          border: Border.all(color: border, width: 0.8),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: textSecondary.withValues(alpha: 0.3),
                  borderRadius: OTRadius.chipBorder,
                ),
              ),
            ),
            Text(
              AppCopy.studyOptions,
              style: OTTypography.corpusTitle(color: textPrimary).copyWith(fontSize: 18),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Icon(Icons.format_size_rounded, color: textPrimary, size: 20),
              title: Text('Ukuran teks (${(_fontScale * 100).round()}%)', style: OTTypography.bodyMedium(color: textPrimary)),
              onTap: () {
                Navigator.pop(ctx);
                _showFontScalePicker();
              },
            ),
            Divider(height: 1, color: border.withValues(alpha: 0.5)),
            ListTile(
              leading: Icon(_hasCopied ? Icons.check_circle_rounded : Icons.copy_rounded, color: _hasCopied ? OTColors.success : textPrimary, size: 20),
              title: Text('Salin jawaban', style: OTTypography.bodyMedium(color: textPrimary)),
              onTap: _isCopying
                  ? null
                  : () {
                      Navigator.pop(ctx);
                      _copyLatestResponse();
                    },
            ),
          ],
        ),
      ),
    );
  }

  void _showFontScalePicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = OTColors.surface(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: OTRadius.sheetBorder,
            border: Border.all(color: border, width: 0.8),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: border,
                        borderRadius: OTRadius.chipBorder,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ukuran teks',
                    style: OTTypography.corpusTitle(color: textPrimary).copyWith(fontSize: 17),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sesuaikan ukuran teks untuk kenyamanan membaca',
                    style: OTTypography.caption(color: textSecondary),
                  ),
                  const SizedBox(height: 14),
                  _buildScaleOption(ctx, label: 'Ringkas (85%)', scale: 0.85, isDark: isDark),
                  _buildScaleOption(ctx, label: 'Normal (100%)', scale: 1.0, isDark: isDark),
                  _buildScaleOption(ctx, label: 'Sedang (120%)', scale: 1.20, isDark: isDark),
                  _buildScaleOption(ctx, label: 'Besar (140%)', scale: 1.40, isDark: isDark),
                  _buildScaleOption(ctx, label: 'Ekstra Besar (165%)', scale: 1.65, isDark: isDark),
                  _buildScaleOption(ctx, label: 'Maksimal (200%)', scale: 2.00, isDark: isDark),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildScaleOption(
    BuildContext ctx, {
    required String label,
    required double scale,
    required bool isDark,
  }) {
    final isSelected = (_fontScale - scale).abs() < 0.05;
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final accent = OTColors.accent(isDark);

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        Icons.text_fields_rounded,
        size: (18 * scale).clamp(16.0, 24.0),
        color: isSelected ? accent : textSecondary,
      ),
      title: Text(
        label,
        style: OTTypography.body(color: isSelected ? accent : textPrimary).copyWith(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_rounded, color: accent, size: 20)
          : null,
      onTap: () {
        _setFontScale(scale);
        Navigator.pop(ctx);
      },
    );
  }
}



```

### FLUTTER FILE: openturath_ai/lib/screens/book_catalog_screen.dart
```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_copy.dart';
import '../core/routes.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_spacing.dart';
import '../models/agent_model.dart';
import '../models/book_model.dart';
import '../services/canonical_library_service.dart';
import '../widgets/book_row_item.dart';
import '../widgets/apple_interactive_wrapper.dart';

/// Halaman Katalog Naskah Penuh (Full-Screen Route).
/// Menggantikan modal bottom sheet sempit agar pengguna memiliki ruang baca yang lapang,
/// tenang, dan mudah ditelusuri sesuai standar Apple HIG.
class BookCatalogScreen extends StatefulWidget {
  final AgentModel? agent;
  final String? initialQuery;

  const BookCatalogScreen({
    super.key,
    this.agent,
    this.initialQuery,
  });

  @override
  State<BookCatalogScreen> createState() => _BookCatalogScreenState();
}

class _BookCatalogScreenState extends State<BookCatalogScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final CanonicalLibraryService _service = CanonicalLibraryService.instance;
  Timer? _debounce;

  List<CanonicalBookPresentation>? _allBooks;
  List<CanonicalBookPresentation>? _filteredBooks;
  bool _isLoading = true;
  String? _errorMessage;

  String? _selectedEra;
  String? _selectedType;
  String _searchQuery = '';

  final List<String> _eras = [
    'Mutaqaddimin',
    'Ashab Al-Wujuh',
    'Muta\'akhkhirin',
  ];

  final List<String> _types = [
    'Asal Mazhab',
    'Matan',
    'Syarah',
    'Hasyiyah',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchCtrl.text = widget.initialQuery!;
      _searchQuery = widget.initialQuery!;
    }
    _loadCatalog();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadCatalog() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final books = await _service.loadSyafiiCatalog();
      if (!mounted) return;
      setState(() {
        _allBooks = books;
        _isLoading = false;
        _applyFilters();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = AppCopy.catalogLoadFailed;
      });
    }
  }

  void _onSearchChanged(String val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _searchQuery = val.trim();
          _applyFilters();
        });
      }
    });
  }

  void _applyFilters() {
    if (_allBooks == null) return;
    _filteredBooks = _service.filterBooks(
      _allBooks!,
      _searchQuery,
      eraFilter: _selectedEra,
      typeFilter: _selectedType,
    );
  }

  void _clearFilters() {
    _searchCtrl.clear();
    setState(() {
      _searchQuery = '';
      _selectedEra = null;
      _selectedType = null;
      _applyFilters();
    });
  }

  void _openBookDetail(CanonicalBookPresentation book) {
    Navigator.pushNamed(
      context,
      AppRoutes.bookDetail,
      arguments: book,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = OTColors.surface(isDark);
    final background = OTColors.canvas(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final primaryAccent = OTColors.accent(isDark);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
          tooltip: 'Kembali',
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pustaka Kitab Kanonikal',
              style: OTTypography.screenTitle(color: textPrimary).copyWith(fontSize: 18),
            ),
            Text(
              '87 Kitab Mazhab Syafi\'i',
              style: OTTypography.caption(color: textSecondary).copyWith(fontSize: 11),
            ),
          ],
        ),
        actions: [
          if (_selectedEra != null || _selectedType != null || _searchQuery.isNotEmpty)
            TextButton(
              onPressed: _clearFilters,
              child: Text(
                'Reset',
                style: OTTypography.button(color: primaryAccent).copyWith(fontSize: 13),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // ── SEARCH CONTAINER ──
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: OTSpacing.lg,
                vertical: OTSpacing.sm,
              ),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: border, width: 0.8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, size: 20, color: textSecondary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: _onSearchChanged,
                        style: GoogleFonts.outfit(fontSize: 13.5, color: textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Cari judul Arab/Latin, pengarang, muhaqqiq...',
                          hintStyle: GoogleFonts.outfit(
                            fontSize: 13.5,
                            color: textSecondary.withValues(alpha: 0.7),
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          filled: false,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchCtrl.clear();
                          setState(() {
                            _searchQuery = '';
                            _applyFilters();
                          });
                        },
                        child: Icon(Icons.close_rounded, size: 18, color: textSecondary),
                      ),
                  ],
                ),
              ),
            ),

            // ── HORIZONTAL ERA & TYPE FILTER CHIPS ──
            SizedBox(
              height: 38,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: OTSpacing.lg),
                children: [
                  _filterChip(
                    label: 'Semua Era',
                    isSelected: _selectedEra == null,
                    onTap: () {
                      setState(() {
                        _selectedEra = null;
                        _applyFilters();
                      });
                    },
                    isDark: isDark,
                    border: border,
                    surface: surface,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                  for (final era in _eras)
                    _filterChip(
                      label: era,
                      isSelected: _selectedEra == era,
                      onTap: () {
                        setState(() {
                          _selectedEra = _selectedEra == era ? null : era;
                          _applyFilters();
                        });
                      },
                      isDark: isDark,
                      border: border,
                      surface: surface,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    width: 1,
                    color: border,
                  ),
                  for (final type in _types)
                    _filterChip(
                      label: type,
                      isSelected: _selectedType == type,
                      onTap: () {
                        setState(() {
                          _selectedType = _selectedType == type ? null : type;
                          _applyFilters();
                        });
                      },
                      isDark: isDark,
                      border: border,
                      surface: surface,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                ],
              ),
            ),

            const SizedBox(height: OTSpacing.sm),

            // ── RESULTS COUNT HEADER ──
            if (!_isLoading && _filteredBooks != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: OTSpacing.lg,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Text(
                      'Menampilkan ${_filteredBooks!.length} naskah rujukan',
                      style: OTTypography.caption(color: textSecondary).copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (_selectedEra != null || _selectedType != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: primaryAccent.withValues(alpha: isDark ? 0.12 : 0.06),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          [
                            if (_selectedEra != null) _selectedEra!,
                            if (_selectedType != null) _selectedType!,
                          ].join(' · '),
                          style: OTTypography.caption(color: primaryAccent).copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            // ── MAIN CONTENT LIST / EMPTY / ERROR / LOADING ──
            Expanded(
              child: _buildContent(
                isDark: isDark,
                surface: surface,
                border: border,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                primaryAccent: primaryAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent({
    required bool isDark,
    required Color surface,
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
    required Color primaryAccent,
  }) {
    if (_isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(OTSpacing.lg),
        itemCount: 8,
        itemBuilder: (ctx, i) => _buildSkeletonItem(surface, border),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(OTSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: textSecondary),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: OTTypography.body(color: textPrimary),
              ),
              const SizedBox(height: 16),
              AppleInteractiveWrapper(
                onTap: _loadCatalog,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: primaryAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    AppCopy.tryAgain,
                    style: OTTypography.button(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredBooks == null || _filteredBooks!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(OTSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off_rounded, size: 48, color: textSecondary),
              const SizedBox(height: 12),
              Text(
                'Tidak ditemukan kitab yang sesuai.',
                style: OTTypography.bodyMedium(color: textPrimary).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Coba gunakan kata kunci Arab, nama pengarang, atau hapus filter era.',
                textAlign: TextAlign.center,
                style: OTTypography.caption(color: textSecondary),
              ),
              const SizedBox(height: 16),
              AppleInteractiveWrapper(
                onTap: _clearFilters,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Hapus Semua Filter',
                    style: OTTypography.button(color: textPrimary).copyWith(fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCatalog,
      color: primaryAccent,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.symmetric(
          horizontal: OTSpacing.lg,
          vertical: OTSpacing.sm,
        ),
        itemCount: _filteredBooks!.length,
        itemBuilder: (context, index) {
          final book = _filteredBooks![index];
          return BookRowItem(
            book: book,
            searchQuery: _searchQuery,
            onTap: () => _openBookDetail(book),
          );
        },
      ),
    );
  }

  Widget _buildSkeletonItem(Color surface, Color border) {
    return Container(
      margin: const EdgeInsets.only(bottom: OTSpacing.sm),
      height: 72,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 0.8),
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    required Color border,
    required Color surface,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final activeBg = textPrimary;
    final activeFg = isDark ? Colors.black : Colors.white;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: AppleInteractiveWrapper(
        onTap: onTap,
        pressedScale: 0.94,
        hapticType: HapticFeedbackType.selection,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? activeBg : surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? activeBg : border,
              width: 0.8,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: OTTypography.caption(color: isSelected ? activeFg : textSecondary).copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

```

### FLUTTER FILE: openturath_ai/lib/screens/book_detail_screen.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_copy.dart';
import '../core/app_snackbar.dart';
import '../core/routes.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../models/agent_model.dart';
import '../models/book_model.dart';
import '../models/bookmark_model.dart';
import '../services/bookmark_service.dart';
import '../services/research_notes_service.dart';
import '../widgets/apple_interactive_wrapper.dart';

/// Halaman Detail Edisi Kitab Mandiri (Full-Screen Route).
/// Mengeliminasi pola anti-desain modal bertingkat (sheet-on-sheet) sesuai Apple HIG.
class BookDetailScreen extends StatefulWidget {
  final CanonicalBookPresentation book;
  final AgentModel? agent;

  const BookDetailScreen({
    super.key,
    required this.book,
    this.agent,
  });

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final ResearchNotesService _notesService = ResearchNotesService();
  bool _isSaving = false;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
  }

  Future<void> _checkIfSaved() async {
    try {
      final noteId = 'book_${widget.book.editionId}';
      final isBookmarked = await BookmarkService().isBookmarked(noteId);
      if (mounted) {
        setState(() => _isSaved = isBookmarked);
      }
    } catch (_) {}
  }

  Future<void> _toggleSaveBook() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final noteId = 'book_${widget.book.editionId}';
      if (_isSaved) {
        await _notesService.deleteNote(noteId);
        await BookmarkService().deleteBookmark(noteId);
        if (mounted) {
          setState(() {
            _isSaved = false;
            _isSaving = false;
          });
          AppSnackBar.show(context, message: 'Rujukan dihapus dari Catatan Riset.');
        }
      } else {
        final agent = _resolveTargetAgent();
        final deathYearStr = widget.book.verifiedDeathYearHijri != null
            ? ' (w. ${widget.book.verifiedDeathYearHijri} H)'
            : '';
        final publisherStr = widget.book.publisher != null
            ? ', Terbitan ${widget.book.publisher}'
            : '';
        final muhaqqiqStr = widget.book.muhaqqiq != null
            ? ', Tahqiq: ${widget.book.muhaqqiq}'
            : '';

        final newNote = ResearchNote(
          id: noteId,
          agentId: agent.id,
          agentTitle: agent.title,
          title: widget.book.titleArabic,
          excerpt:
              'Kitab ${widget.book.titleArabic}, karya ${widget.book.authorArabic}$deathYearStr$publisherStr$muhaqqiqStr.',
          bookTitle: widget.book.titleArabic,
          bookVolume: widget.book.volumesCount?.toString(),
          tags: [
            'Rujukan Kitab',
            if (widget.book.reviewedTypeLabel != null) widget.book.reviewedTypeLabel!,
            if (widget.book.reviewedEraLabel != null) widget.book.reviewedEraLabel!,
          ],
          createdAt: DateTime.now(),
        );

        final newBookmark = BookmarkModel(
          id: noteId,
          title: widget.book.titleArabic,
          agentId: agent.id,
          agentTitle: agent.title,
          fieldName: 'Rujukan Kitab',
          fieldId: 'fiqh',
          arabicExcerpt: widget.book.titleArabic,
          fullAnswer:
              'Kitab ${widget.book.titleArabic}, karya ${widget.book.authorArabic}$deathYearStr$publisherStr$muhaqqiqStr.',
          bookReference: widget.book.titleArabic,
          pageNumber: widget.book.volumesCount != null
              ? '${widget.book.volumesCount} Jilid'
              : '1 Jilid',
          author: widget.book.authorArabic,
          createdAt: DateTime.now(),
        );

        await _notesService.saveNote(newNote);
        await BookmarkService().addBookmark(newBookmark);
        if (mounted) {
          setState(() {
            _isSaved = true;
            _isSaving = false;
          });
          HapticFeedback.mediumImpact();
          AppSnackBar.success(context, 'Kitab disimpan ke Catatan Riset.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        AppSnackBar.error(context, 'Gagal memperbarui catatan riset.');
      }
    }
  }

  AgentModel _resolveTargetAgent() {
    if (widget.agent != null) return widget.agent!;
    try {
      return AgentModel.defaultAgents.firstWhere(
        (a) => a.catalogId == 'canonical_syafii' || a.id == 'fiqh',
        orElse: () => AgentModel.defaultAgents.first,
      );
    } catch (_) {
      return AgentModel.defaultAgents.first;
    }
  }

  void _openStudySpace() {
    final agent = _resolveTargetAgent();
    Navigator.pushNamed(
      context,
      AppRoutes.agentWebview,
      arguments: agent,
    );
  }

  void _copyScholarlyCitation() {
    final deathYearStr = widget.book.verifiedDeathYearHijri != null
        ? ' (w. ${widget.book.verifiedDeathYearHijri} H)'
        : '';
    final publisherStr = widget.book.publisher != null
        ? ', ${widget.book.publisher}'
        : '';
    final muhaqqiqStr = widget.book.muhaqqiq != null
        ? ', Tahqiq: ${widget.book.muhaqqiq}'
        : '';
    final volStr = widget.book.volumesCount != null
        ? ', ${widget.book.volumesCount} Jilid'
        : '';

    final citation =
        '${widget.book.authorArabic}$deathYearStr. ${widget.book.titleArabic}$volStr$publisherStr$muhaqqiqStr. OpenTurath AI Canonical Corpus.';

    Clipboard.setData(ClipboardData(text: citation));
    HapticFeedback.selectionClick();
    AppSnackBar.success(context, 'Sitasi standar ilmiah tersalin ke papan klip.');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = OTColors.surface(isDark);
    final background = OTColors.canvas(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final primaryAccent = OTColors.accent(isDark);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
          tooltip: 'Kembali',
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppCopy.bookDetails,
          style: OTTypography.screenTitle(color: textPrimary).copyWith(fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: _isSaved ? primaryAccent : textSecondary,
            ),
            tooltip: _isSaved ? 'Hapus Rujukan' : 'Simpan Rujukan',
            onPressed: _toggleSaveBook,
          ),
          IconButton(
            icon: Icon(Icons.share_outlined, color: textSecondary),
            tooltip: 'Salin Sitasi Standar',
            onPressed: _copyScholarlyCitation,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: OTSpacing.lg,
            vertical: OTSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── KARTU 1: IDENTITAS KITAB (ARABIC HERO) ──
              _buildCard(
                isDark: isDark,
                surface: surface,
                border: border,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: primaryAccent.withValues(alpha: isDark ? 0.15 : 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Naskah Kanonikal · Syafi\'i',
                            style: OTTypography.caption(color: primaryAccent).copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          widget.book.editionId,
                          style: OTTypography.caption(color: textSecondary).copyWith(
                            fontFamily: 'Courier',
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: OTSpacing.md),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        widget.book.titleArabic,
                        textAlign: TextAlign.right,
                        style: OTTypography.arabicDisplay(color: textPrimary).copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          height: 1.6,
                        ),
                      ),
                    ),
                    if (widget.book.titleLatin != null &&
                        widget.book.titleLatin!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.book.titleLatin!,
                        style: OTTypography.body(color: textSecondary).copyWith(
                          fontStyle: FontStyle.italic,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: OTSpacing.md),

              // ── KARTU 2: MUALLIF / PENGARANG ──
              _buildCard(
                isDark: isDark,
                surface: surface,
                border: border,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('MUALLIF / PENGARANG', textSecondary),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 20,
                          color: primaryAccent,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.book.authorArabic,
                                style: OTTypography.bodyMedium(color: textPrimary).copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (widget.book.authorLatin != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  widget.book.authorLatin!,
                                  style: OTTypography.caption(color: textSecondary),
                                ),
                              ],
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2.5,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.06)
                                      : Colors.black.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  widget.book.verifiedDeathYearHijri != null
                                      ? 'Wafat: ${widget.book.verifiedDeathYearHijri} Hijriyah'
                                      : 'Wafat: Dalam verifikasi sanad',
                                  style: OTTypography.caption(color: textSecondary).copyWith(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: OTSpacing.md),

              // ── KARTU 3: KLASIFIKASI ILMIAH & THABAQAT ──
              _buildCard(
                isDark: isDark,
                surface: surface,
                border: border,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('KLASIFIKASI ILMIAH', textSecondary),
                    const SizedBox(height: 12),
                    _buildMetaRow(
                      icon: Icons.category_outlined,
                      label: 'Tipe Naskah',
                      value: widget.book.reviewedTypeLabel ?? 'Kitab Referensi Mazhab',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const Divider(height: 16, thickness: 0.5),
                    _buildMetaRow(
                      icon: Icons.history_edu_rounded,
                      label: 'Era Keilmuan',
                      value: widget.book.reviewedEraLabel ?? 'Ulama Mazhab Syafi\'i',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const Divider(height: 16, thickness: 0.5),
                    _buildMetaRow(
                      icon: Icons.auto_stories_outlined,
                      label: 'Jumlah Jilid',
                      value: widget.book.volumesCount != null
                          ? '${widget.book.volumesCount} Jilid'
                          : '1 Jilid / Naskah Tunggal',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    if (widget.book.canShowAuthority) ...[
                      const Divider(height: 16, thickness: 0.5),
                      _buildMetaRow(
                        icon: Icons.verified_outlined,
                        label: 'Derajat Mu\'tabar',
                        value: widget.book.reviewedAuthorityLabel!,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: OTSpacing.md),

              // ── KARTU 4: DATA EDISI & TAHQIQ ──
              _buildCard(
                isDark: isDark,
                surface: surface,
                border: border,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('DATA EDISI & TAHQIQ', textSecondary),
                    const SizedBox(height: 12),
                    _buildMetaRow(
                      icon: Icons.business_outlined,
                      label: 'Penerbit Rujukan',
                      value: widget.book.publisher ?? 'Informasi penerbit belum tersedia',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const Divider(height: 16, thickness: 0.5),
                    _buildMetaRow(
                      icon: Icons.edit_note_rounded,
                      label: 'Pentahqiq / Muhaqqiq',
                      value: widget.book.muhaqqiq ?? 'Cetakan klasik / belum tercatat',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: OTSpacing.md),

              // ── KARTU 5: STATUS KORPUS & AKSI RISET ──
              _buildCard(
                isDark: isDark,
                surface: surface,
                border: border,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionHeader('AKSI & TELAAH RISET', textSecondary),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryAccent.withValues(alpha: isDark ? 0.08 : 0.04),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: primaryAccent.withValues(alpha: isDark ? 0.2 : 0.1),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: primaryAccent,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Naskah kanonikal ini telah dikodifikasi dalam basis data rujukan. Ruang dialog AI dapat langsung menelusuri ibarah dan dalil dari kitab ini.',
                              style: OTTypography.caption(color: textSecondary).copyWith(
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: OTSpacing.md),

                    // Primary Action Button: Buka Ruang Kajian
                    AppleInteractiveWrapper(
                      onTap: _openStudySpace,
                      pressedScale: 0.98,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: primaryAccent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.auto_awesome_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Buka Ruang Kajian',
                              style: OTTypography.button(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Secondary Action: Simpan / Hapus Rujukan
                    AppleInteractiveWrapper(
                      onTap: _toggleSaveBook,
                      pressedScale: 0.98,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.black.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: border, width: 0.8),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isSaved
                                  ? Icons.bookmark_remove_outlined
                                  : Icons.bookmark_add_outlined,
                              size: 18,
                              color: textPrimary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isSaved
                                  ? 'Hapus dari Catatan Riset'
                                  : 'Simpan ke Catatan Riset',
                              style: OTTypography.button(color: textPrimary).copyWith(
                                fontSize: 13.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: OTSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required bool isDark,
    required Color surface,
    required Color border,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(OTSpacing.lg),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(OTRadius.card),
        border: Border.all(color: border, width: 0.8),
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Text(
      title,
      style: OTTypography.sectionHeading(color: color),
    );
  }

  Widget _buildMetaRow({
    required IconData icon,
    required String label,
    required String value,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: textSecondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: OTTypography.caption(color: textSecondary),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: OTTypography.bodyMedium(color: textPrimary).copyWith(
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

```

### FLUTTER FILE: openturath_ai/lib/screens/bookmark_screen.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_copy.dart';
import '../core/app_snackbar.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_motion.dart';
import '../core/design/ot_spacing.dart';
import '../core/routes.dart';
import '../models/bookmark_model.dart';
import '../models/book_model.dart';
import '../services/bookmark_service.dart';
import '../services/canonical_library_service.dart';
import '../widgets/evidence_bottom_sheet.dart';
import 'main_shell_screen.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  final BookmarkService _bookmarkService = BookmarkService();
  final TextEditingController _searchCtrl = TextEditingController();
  List<BookmarkModel> _allBookmarks = [];
  List<BookmarkModel> _filteredBookmarks = [];
  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  bool _isLoading = true;
  bool _showSearch = false;

  static const List<String> _categories = [
    'Semua',
    'Kutipan Ibarah',
    'Rujukan Kitab',
    'Fikih',
    'Hadis',
    'Tafsir',
    'Akidah',
    'Usul Fikih',
    'Bahasa Arab',
    'Sejarah',
    'Tasawuf',
  ];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
    _bookmarkService.addListener(_onBookmarksChanged);
  }

  void _onBookmarksChanged() {
    if (mounted) {
      _loadBookmarks();
    }
  }

  @override
  void dispose() {
    _bookmarkService.removeListener(_onBookmarksChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadBookmarks() async {
    final list = await _bookmarkService.getBookmarks();
    if (mounted) {
      setState(() {
        _allBookmarks = list;
        _filter();
        _isLoading = false;
      });
    }
  }

  void _filter() {
    final q = _searchQuery.toLowerCase().trim();
    _filteredBookmarks = _allBookmarks.where((b) {
      final fieldLower = b.fieldName.toLowerCase();
      final isBookRef = b.id.startsWith('book_') || fieldLower.contains('rujukan kitab');

      bool matchesCategory;
      if (_selectedCategory == 'Semua') {
        matchesCategory = true;
      } else if (_selectedCategory == 'Rujukan Kitab') {
        matchesCategory = isBookRef;
      } else if (_selectedCategory == 'Kutipan Ibarah') {
        matchesCategory = !isBookRef;
      } else {
        matchesCategory = fieldLower.contains(_selectedCategory.toLowerCase()) ||
            (_selectedCategory == 'Hadis' && fieldLower.contains('hadits')) ||
            (_selectedCategory == 'Sejarah' && fieldLower.contains('tarikh')) ||
            (_selectedCategory == 'Akidah' && fieldLower.contains('aqidah')) ||
            (_selectedCategory == 'Usul Fikih' && fieldLower.contains('ushul')) ||
            (_selectedCategory == 'Tasawuf' && fieldLower.contains('tasawwuf'));
      }

      if (!matchesCategory) return false;
      if (q.isEmpty) return true;
      return b.title.toLowerCase().contains(q) ||
          b.agentTitle.toLowerCase().contains(q) ||
          b.bookReference.toLowerCase().contains(q) ||
          b.arabicExcerpt.contains(q) ||
          b.fullAnswer.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _deleteBookmark(BookmarkModel item) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = OTColors.surface(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(borderRadius: OTRadius.dialogBorder),
          title: Text(
            'Hapus Rujukan?',
            style: OTTypography.screenTitle(color: textPrimary).copyWith(fontSize: 18),
          ),
          content: Text(
            'Rujukan ini akan dihapus dari simpanan Anda.',
            style: OTTypography.body(color: textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Batal',
                style: OTTypography.button(color: textSecondary),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: OTColors.destructive,
                shape: RoundedRectangleBorder(borderRadius: OTRadius.buttonBorder),
              ),
              child: Text(
                'Hapus',
                style: OTTypography.button(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _bookmarkService.deleteBookmark(item.id);
      if (mounted) {
        AppSnackBar.show(
          context,
          message: 'Rujukan telah dihapus dari simpanan.',
          action: SnackBarAction(
            label: 'Urungkan',
            textColor: OTColors.accent(isDark),
            onPressed: () => _bookmarkService.addBookmark(item),
          ),
        );
      }
    }
  }

  void _copyIbarah(String ibarah) {
    OTMotion.light();
    Clipboard.setData(ClipboardData(text: ibarah));
    AppSnackBar.success(context, 'Ibarah tersalin.');
  }

  void _shareBookmark(BookmarkModel item) {
    final buffer = StringBuffer();
    if (item.arabicExcerpt.isNotEmpty) {
      buffer.writeln('"${item.arabicExcerpt}"');
      buffer.writeln();
    }
    buffer.write('— ');
    if (item.bookReference.isNotEmpty) {
      buffer.write('Kitab ${item.bookReference}');
      if (item.pageNumber.isNotEmpty) {
        buffer.write(' (Hal. ${item.pageNumber})');
      }
    } else {
      buffer.write(item.title);
    }
    if (item.author != null && item.author!.isNotEmpty) {
      buffer.write(', karya ${item.author}');
    }
    buffer.writeln('.');
    buffer.write('Disimpan melalui OpenTurath AI (${item.agentTitle}).');

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    AppSnackBar.success(
      context,
      'Sitasi standar ilmiah tersalin ke papan klip.',
    );
  }

  Future<void> _openBookmarkItem(BookmarkModel item) async {
    if (item.id.startsWith('book_')) {
      final editionId = item.id.replaceFirst('book_', '');
      var books = CanonicalLibraryService.instance.cachedSyafiiBooks;
      if (books == null) {
        try {
          books = await CanonicalLibraryService.instance.loadSyafiiCatalog();
        } catch (_) {}
      }
      final matchedBook = books?.firstWhere(
        (b) => b.editionId == editionId,
        orElse: () => CanonicalBookPresentation(
          editionId: editionId,
          titleArabic: item.title,
          authorArabic: item.author ?? '',
        ),
      );

      if (matchedBook != null && mounted) {
        Navigator.pushNamed(
          context,
          AppRoutes.bookDetail,
          arguments: matchedBook,
        );
        return;
      }
    }

    _showEvidence(item);
  }

  void _showEvidence(BookmarkModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EvidenceBottomSheet(
        citationNumber: 1,
        bookName: item.bookReference.isNotEmpty ? item.bookReference : 'Rujukan Naskah',
        author: item.author ?? '',
        pageNumber: item.pageNumber,
        category: item.fieldName,
        arabicExcerpt: item.arabicExcerpt,
        explanation: item.fullAnswer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvas = OTColors.canvas(isDark);
    final surface = OTColors.surface(isDark);
    final surfaceSubtle = OTColors.surfaceSubtle(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final accent = OTColors.accent(isDark);

    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        backgroundColor: canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Tersimpan',
          style: OTTypography.corpusTitle(color: textPrimary).copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showSearch ? Icons.close_rounded : Icons.search_rounded,
              color: textPrimary,
            ),
            tooltip: _showSearch ? 'Tutup pencarian' : AppCopy.searchSavedTooltip,
            onPressed: () {
              OTMotion.selection();
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchCtrl.clear();
                  _searchQuery = '';
                  _filter();
                }
              });
            },
          ),
          const SizedBox(width: OTSpacing.sm),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Search Field (collapsible) ──
            if (_showSearch)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: OTSpacing.lg,
                  vertical: OTSpacing.xs + 2,
                ),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: surfaceSubtle,
                    borderRadius: OTRadius.inputBorder,
                    border: Border.all(color: border, width: 1),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    autofocus: true,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                        _filter();
                      });
                    },
                    style: OTTypography.body(color: textPrimary),
                    decoration: InputDecoration(
                      hintText: AppCopy.searchSavedHint,
                      hintStyle: OTTypography.body(color: textSecondary),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: textSecondary,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: textSecondary,
                              ),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _filter();
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                ),
              ),

            // ── Horizontal Filter Pills ──
            Container(
              height: 38,
              margin: const EdgeInsets.symmetric(vertical: OTSpacing.xs + 2),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: OTSpacing.lg),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: OTSpacing.sm),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;

                  return GestureDetector(
                    onTap: () {
                      OTMotion.selection();
                      setState(() {
                        _selectedCategory = cat;
                        _filter();
                      });
                    },
                    child: AnimatedContainer(
                      duration: OTMotion.fast,
                      curve: OTMotion.curve,
                      padding: const EdgeInsets.symmetric(
                        horizontal: OTSpacing.md + 2,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? textPrimary : surface,
                        borderRadius: OTRadius.chipBorder,
                        border: Border.all(
                          color: isSelected ? textPrimary : border.withValues(alpha: 0.7),
                          width: 0.8,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          cat,
                          style: OTTypography.caption(
                            color: isSelected ? canvas : textSecondary,
                          ).copyWith(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── List of Saved Bookmarks ──
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: accent,
                      ),
                    )
                  : _filteredBookmarks.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: OTSpacing.xl),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 68,
                                  height: 68,
                                  decoration: BoxDecoration(
                                    color: surfaceSubtle,
                                    borderRadius: OTRadius.cardBorder,
                                    border: Border.all(color: border, width: 1.0),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.collections_bookmark_outlined,
                                      size: 30,
                                      color: textSecondary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: OTSpacing.lg),
                                Text(
                                  AppCopy.noSavedTitle,
                                  style: OTTypography.cardTitle(color: textPrimary).copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: OTSpacing.xs + 2),
                                Text(
                                  AppCopy.noSavedDescription,
                                  textAlign: TextAlign.center,
                                  style: OTTypography.body(color: textSecondary).copyWith(
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: OTSpacing.xl),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    OTMotion.light();
                                    final shell = MainShellController.of(context);
                                    shell?.switchTab(1);
                                  },
                                  icon: const Icon(Icons.menu_book_outlined, size: 16),
                                  label: const Text('Buka kajian'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: textPrimary,
                                    side: BorderSide(color: border, width: 1.0),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: OTSpacing.lg,
                                      vertical: OTSpacing.md,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: OTRadius.buttonBorder,
                                    ),
                                    textStyle: OTTypography.button(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            OTSpacing.lg,
                            OTSpacing.sm,
                            OTSpacing.lg,
                            108,
                          ),
                          itemCount: _filteredBookmarks.length,
                          separatorBuilder: (_, __) => const SizedBox(height: OTSpacing.md),
                          itemBuilder: (context, index) {
                            final item = _filteredBookmarks[index];
                            return _BookmarkCard(
                              item: item,
                              surface: surface,
                              surfaceSubtle: surfaceSubtle,
                              border: border,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              accent: accent,
                              onCopy: () => _copyIbarah(item.arabicExcerpt),
                              onOpen: () => _openBookmarkItem(item),
                              onShare: () => _shareBookmark(item),
                              onDelete: () => _deleteBookmark(item),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookmarkCard extends StatelessWidget {
  final BookmarkModel item;
  final Color surface;
  final Color surfaceSubtle;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;
  final VoidCallback onCopy;
  final VoidCallback onOpen;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const _BookmarkCard({
    required this.item,
    required this.surface,
    required this.surfaceSubtle,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
    required this.onCopy,
    required this.onOpen,
    required this.onShare,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isBookRef = item.id.startsWith('book_') || item.fieldName == 'Rujukan Kitab';

    return Container(
      padding: const EdgeInsets.all(OTSpacing.base),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: OTRadius.cardBorder,
        border: Border.all(color: border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Category Pill + Agent Title + Delete
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: OTRadius.chipBorder,
                      ),
                      child: Text(
                        isBookRef ? 'Rujukan Kitab' : item.fieldName,
                        style: OTTypography.captionMedium(color: accent).copyWith(
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: OTSpacing.sm),
                    Flexible(
                      child: Text(
                        item.agentTitle,
                        style: OTTypography.caption(color: textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: textSecondary.withValues(alpha: 0.7),
                ),
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                tooltip: 'Hapus Rujukan',
                onPressed: onDelete,
              ),
            ],
          ),

          const SizedBox(height: OTSpacing.sm),

          // Title
          Text(
            item.title,
            style: OTTypography.cardTitle(color: textPrimary),
          ),

          const SizedBox(height: OTSpacing.sm),

          // Book Reference Pill
          if (item.bookReference.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: surfaceSubtle,
                borderRadius: OTRadius.chipBorder,
                border: Border.all(color: border.withValues(alpha: 0.6), width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.menu_book_rounded, size: 14, color: accent),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      '${item.bookReference}${item.pageNumber.isNotEmpty ? " · Hlm. ${item.pageNumber}" : ""}',
                      style: OTTypography.captionMedium(color: textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          if (item.arabicExcerpt.isNotEmpty) ...[
            const SizedBox(height: OTSpacing.md),
            // Arabic Excerpt Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: surfaceSubtle,
                borderRadius: BorderRadius.circular(OTRadius.input),
                border: Border.all(color: border.withValues(alpha: 0.4), width: 0.8),
              ),
              child: Text(
                item.arabicExcerpt,
                textDirection: TextDirection.rtl,
                style: GoogleFonts.amiri(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  height: 1.7,
                  color: textPrimary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],

          const SizedBox(height: OTSpacing.md),

          // Action Buttons
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: onCopy,
                icon: const Icon(Icons.copy_rounded, size: 14),
                label: const Text(AppCopy.copyIbarahAction),
                style: OutlinedButton.styleFrom(
                  foregroundColor: textPrimary,
                  side: BorderSide(color: border, width: 0.8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: OTTypography.captionMedium(),
                  shape: RoundedRectangleBorder(borderRadius: OTRadius.buttonBorder),
                ),
              ),
              const SizedBox(width: OTSpacing.sm),
              FilledButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.menu_book, size: 14),
                label: const Text(AppCopy.viewReferenceAction),
                style: FilledButton.styleFrom(
                  backgroundColor: surfaceSubtle,
                  foregroundColor: textPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: OTTypography.captionMedium(),
                  shape: RoundedRectangleBorder(borderRadius: OTRadius.buttonBorder),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onShare,
                icon: const Icon(Icons.share_outlined, size: 18),
                tooltip: AppCopy.shareReferenceTooltip,
                color: textSecondary,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

```

### FLUTTER FILE: openturath_ai/lib/screens/dashboard_screen.dart
```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../core/routes.dart';
import '../core/design/ot_colors.dart';
import '../core/app_snackbar.dart';
import '../core/hijri_date_utils.dart';
import '../models/agent_model.dart';
import '../models/user_model.dart';
import '../models/bookmark_model.dart';
import '../models/book_model.dart';
import '../services/agent_service.dart';
import '../services/auth_service.dart';
import '../services/bookmark_service.dart';
import '../services/canonical_library_service.dart';
import '../services/update_service.dart';
import '../widgets/update_ready_banner.dart';
import '../widgets/specialist_card.dart';
import '../widgets/library_bottom_sheet.dart';
import '../widgets/apple_interactive_wrapper.dart';
import '../widgets/evidence_bottom_sheet.dart';
import 'main_shell_screen.dart';

/// Beranda OpenTurath AI (Tactile Scholarly Research Desk)
/// Dilengkapi animasi Apple Interactive micro-compression, pantulan pegas halus,
/// penanggalan ganda Hijriah, pencarian naskah seketika, dan portal keilmuan interaktif.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();
  final AgentService _agentService = AgentService();
  final TextEditingController _searchController = TextEditingController();

  UserModel? _initialUser;
  List<AgentModel> _agents = AgentModel.defaultAgents;
  List<BookmarkModel> _recentNotes = [];
  String? _lastOpenedAgentId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
    UpdateService().checkForUpdatesSilently();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      if (_authService.currentUser == null) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.login);
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final lastId = prefs.getString('last_opened_notebook_id');

      final results = await Future.wait([
        _authService.getCurrentUserModel(),
        _agentService.getAgents(),
        BookmarkService().getBookmarks(),
      ]).timeout(
        const Duration(seconds: 4),
        onTimeout: () => [null, AgentModel.defaultAgents, <BookmarkModel>[]],
      );

      if (!mounted) return;
      setState(() {
        _lastOpenedAgentId = lastId;
        _initialUser = results[0] as UserModel?;
        _agents = results[1] as List<AgentModel>;
        final notes = results[2] as List<BookmarkModel>;
        _recentNotes = notes.take(3).toList();
      });
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openNotebook(AgentModel agent, UserModel? user) async {
    if (agent.isComingSoon) {
      AppSnackBar.warning(
        context,
        '${agent.title} sedang dalam tahap kurasi naskah kitab primer (Segera Hadir).',
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_opened_notebook_id', agent.id);
      if (mounted) {
        setState(() => _lastOpenedAgentId = agent.id);
      }
    } catch (_) {}

    // Cek akses pengguna ke agent (paywall)
    if (user != null && !user.hasAccessToAgent(agent.id)) {
      if (!mounted) return;
      Navigator.pushNamed(
        context,
        AppRoutes.subscription,
        arguments: {'user': user, 'agent': agent},
      );
      return;
    }

    if (!mounted) return;
    Navigator.pushNamed(
      context,
      AppRoutes.agentWebview,
      arguments: {'agent': agent, 'user': user},
    );
  }

  Future<void> _openBookmarkItem(BookmarkModel item) async {
    if (item.id.startsWith('book_')) {
      final editionId = item.id.replaceFirst('book_', '');
      var books = CanonicalLibraryService.instance.cachedSyafiiBooks;
      if (books == null) {
        try {
          books = await CanonicalLibraryService.instance.loadSyafiiCatalog();
        } catch (_) {}
      }
      final matchedBook = books?.firstWhere(
        (b) => b.editionId == editionId,
        orElse: () => CanonicalBookPresentation(
          editionId: editionId,
          titleArabic: item.title,
          authorArabic: item.author ?? '',
        ),
      );

      if (matchedBook != null && mounted) {
        Navigator.pushNamed(
          context,
          AppRoutes.bookDetail,
          arguments: matchedBook,
        );
        return;
      }
    }

    _showEvidence(item);
  }

  void _showEvidence(BookmarkModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EvidenceBottomSheet(
        citationNumber: 1,
        bookName: item.bookReference.isNotEmpty ? item.bookReference : 'Rujukan Naskah',
        author: item.author ?? '',
        pageNumber: item.pageNumber,
        category: item.fieldName,
        arabicExcerpt: item.arabicExcerpt,
        explanation: item.fullAnswer,
      ),
    );
  }

  bool _isLoading = false;

  List<AgentModel> _getRecentAgents() {
    final List<AgentModel> recents = [];
    if (_lastOpenedAgentId != null && _lastOpenedAgentId!.isNotEmpty) {
      final match = _agents.where((a) => a.id == _lastOpenedAgentId && a.isActive);
      if (match.isNotEmpty) {
        recents.add(match.first);
      }
    }
    for (final a in _agents) {
      if (recents.length >= 3) break;
      if (!recents.any((r) => r.id == a.id) && a.isActive) {
        recents.add(a);
      }
    }
    if (recents.isEmpty && _agents.isNotEmpty) {
      final activeAgents = _agents.where((a) => a.isActive).toList();
      recents.addAll(activeAgents.take(2));
    }
    return recents;
  }

  static const List<({String fieldId, String name, int specialistCount})> _curatedDisciplines = [
    (fieldId: 'fiqh', name: 'Fikih', specialistCount: 6),
    (fieldId: 'hadith', name: 'Hadits', specialistCount: 1),
    (fieldId: 'tafsir', name: 'Tafsir', specialistCount: 1),
    (fieldId: 'aqidah', name: 'Aqidah', specialistCount: 1),
    (fieldId: 'usul', name: 'Usul Fiqh', specialistCount: 1),
    (fieldId: 'lughah', name: 'Bahasa Arab', specialistCount: 1),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final canvas = OTColors.canvas(isDark);
    final surface = OTColors.surface(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final accent = OTColors.accent(isDark);

    return StreamBuilder<UserModel?>(
      stream: _authService.userStream,
      builder: (context, snapshot) {
        final curFirebaseUser = _authService.currentUser;
        final user = snapshot.data ??
            _initialUser ??
            UserModel(
              uid: curFirebaseUser?.uid ?? 'user',
              name: curFirebaseUser?.displayName?.isNotEmpty == true
                  ? curFirebaseUser!.displayName!
                  : 'Santri Peneliti',
              email: curFirebaseUser?.email ?? '',
              photoUrl: curFirebaseUser?.photoURL ?? '',
              plan: AppConstants.planTrial,
              questionsUsed: 0,
            );

        final recentAgents = _getRecentAgents();

        return Scaffold(
          backgroundColor: canvas,
          body: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: _loadData,
              color: accent,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 1. Header Centered: OpenTurath ──
                    Center(
                      child: Text(
                        'OpenTurath',
                        style: GoogleFonts.newsreader(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.4,
                          color: textPrimary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Banner pembaruan jika tersedia
                    const UpdateReadyBanner(),

                    // ── 2. Editorial Desk Header: Dual Date & Scholarly Greeting ──
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: border)),
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Row(children: [
                          Expanded(child: Text(HijriDateUtils.formatDualDate().split(' • ').last, textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 11, color: textSecondary))),
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text('•', style: TextStyle(color: textSecondary))),
                          Expanded(child: Text(HijriDateUtils.formatHijriOnly(), textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 11, color: textSecondary))),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.name.isNotEmpty ? 'Ahlan, ${user.name}' : 'Ahlan, Peneliti Turats',
                      style: GoogleFonts.newsreader(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                        color: textPrimary,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ── 3. Ergonomic Search Bar (Stadium Pill) ──
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: border, width: 1.0),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search_rounded, size: 20, color: textSecondary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) => setState(() => _searchQuery = val.trim()),
                              style: GoogleFonts.outfit(fontSize: 13.5, color: textPrimary),
                              decoration: InputDecoration(
                                hintText: 'Cari spesialis, bab fikih, atau kitab...',
                                hintStyle: GoogleFonts.outfit(fontSize: 13.5, color: textSecondary),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                filled: false,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                              child: Icon(Icons.close_rounded, size: 18, color: textSecondary),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ── 4. Jika Sedang Mencari (Hasil Realtime) ──
                    if (_searchQuery.isNotEmpty) ...[
                      Text(
                        'Hasil Penelusuran',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Builder(
                        builder: (context) {
                          final q = _searchQuery.toLowerCase();
                          final matches = _agents.where((a) {
                            final title = a.title.toLowerCase();
                            final arabic = a.titleArabic;
                            final subtitle = a.subtitleAcademic.toLowerCase();
                            final category = a.category.toLowerCase();
                            final books = a.referenceBooks?.any((b) => b.title.toLowerCase().contains(q)) ?? false;
                            return title.contains(q) || arabic.contains(q) || subtitle.contains(q) || category.contains(q) || books;
                          }).toList();

                          if (matches.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 36),
                              child: Center(
                                child: Text(
                                  'Tidak ditemukan naskah atau spesialis yang sesuai.',
                                  style: GoogleFonts.outfit(fontSize: 13.5, color: textSecondary),
                                ),
                              ),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: matches.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, idx) {
                              final agent = matches[idx];
                              return SpecialistCard(
                                title: agent.title,
                                statusLabel: agent.isComingSoon ? 'Segera Hadir' : null,
                                onOpen: () => _openNotebook(agent, user),
                                onOpenLibrary: agent.catalogId != null
                                    ? () => showResearchLibrary(context, agent: agent)
                                    : null,
                              );
                            },
                          );
                        },
                      ),
                    ] else ...[
                      // ── 6. Catatan Riset Terbaru ──
                      _buildRecentNotesSection(
                        context: context,
                        notes: _recentNotes,
                        isDark: isDark,
                        surface: surface,
                        border: border,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        accent: accent,
                      ),

                      const SizedBox(height: 28),

                      // ── 8. Section: Pilih Bidang Ilmu ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Pilih Bidang Ilmu',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              color: textPrimary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              final shell = MainShellController.of(context);
                              if (shell != null) {
                                shell.switchTab(1);
                              } else {
                                Navigator.pushNamed(context, AppRoutes.specialistList);
                              }
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Lihat Semua',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Icon(Icons.chevron_right_rounded, size: 16, color: textPrimary),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // 2-Column Minimalist Purism Grid (6 Cards, Aspect Ratio 1.45)
                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.45,
                        ),
                        itemCount: _curatedDisciplines.length,
                        itemBuilder: (context, index) {
                          final disc = _curatedDisciplines[index];
                          return AppleInteractiveWrapper(
                            onTap: () {
                              final shell = MainShellController.of(context);
                              if (shell != null) {
                                shell.switchTab(1, fieldId: disc.fieldId);
                              } else {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.specialistList,
                                  arguments: {'fieldId': disc.fieldId},
                                );
                              }
                            },
                            pressedScale: 0.96,
                            hapticType: HapticFeedbackType.light,
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              decoration: BoxDecoration(
                                color: surface,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: border, width: 1.0),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    disc.name,
                                    style: GoogleFonts.newsreader(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.2,
                                      color: textPrimary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '${disc.specialistCount} spesialis',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12.5,
                                      color: textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 28),

                      // ── 9. Section: Modul Riset (Specialist Modules) ──
                      Text(
                        'Modul Riset',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 14),

                      if (_isLoading)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: CircularProgressIndicator(color: textPrimary, strokeWidth: 2),
                          ),
                        )
                      else if (recentAgents.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: border, width: 1.0),
                          ),
                          child: Center(
                            child: Text(
                              'Belum ada riwayat sesi riset.',
                              style: GoogleFonts.outfit(fontSize: 13, color: textSecondary),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: recentAgents.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final agent = recentAgents[index];
                            final isFirst = index == 0;
                            final timeLabel = isFirst ? 'Modul Aktif' : 'Siap Dikaji';

                            return AppleInteractiveWrapper(
                              onTap: () => _openNotebook(agent, user),
                              pressedScale: 0.98,
                              hapticType: HapticFeedbackType.selection,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                                decoration: BoxDecoration(
                                  color: surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: border, width: 1.0),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  agent.title,
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                    letterSpacing: -0.2,
                                                    color: textPrimary,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: isDark ? const Color(0xFF27272A) : const Color(0xFFF1F5F9),
                                                  borderRadius: BorderRadius.circular(100),
                                                ),
                                                child: Text(
                                                  timeLabel,
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 10.5,
                                                    fontWeight: FontWeight.w600,
                                                    color: textSecondary,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(
                                      Icons.arrow_outward_rounded,
                                      size: 18,
                                      color: textPrimary,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 28),

                      // ── 10. Adab & Prinsip Peneliti Turats ──
                      _buildScholarlyAdabCard(
                        isDark: isDark,
                        surface: surface,
                        border: border,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),

                      const SizedBox(height: 28),

                      // ── 11. Announcement Carousel (Diposisikan tenang di bawah) ──
                      _DashboardAnnouncementCarousel(
                        isDark: isDark,
                        surface: surface,
                        border: border,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        accent: accent,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentNotesSection({
    required BuildContext context,
    required List<BookmarkModel> notes,
    required bool isDark,
    required Color surface,
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
    required Color accent,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Catatan Riset Terbaru',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () {
                final shell = MainShellController.of(context);
                if (shell != null) {
                  shell.switchTab(2);
                } else {
                  Navigator.pushNamed(context, AppRoutes.bookmark);
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Lihat Semua',
                    style: GoogleFonts.outfit(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.chevron_right_rounded, size: 16, color: textPrimary),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (notes.isEmpty)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border, width: 1.0),
            ),
            child: Row(
              children: [
                Icon(Icons.bookmark_outline_rounded, size: 22, color: textSecondary),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Belum ada catatan atau kutipan ibarah tersimpan. Simpan catatan naskah saat menelaah.',
                    style: GoogleFonts.outfit(fontSize: 12.5, color: textSecondary, height: 1.4),
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: notes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, idx) {
              final note = notes[idx];
              final isBookRef = note.id.startsWith('book_');
              final subtitle = note.bookReference.isNotEmpty
                  ? '${note.bookReference}${note.pageNumber.isNotEmpty ? ' (Hal. ${note.pageNumber})' : ''}'
                  : (note.author != null && note.author!.isNotEmpty
                      ? '${note.author} · ${note.agentTitle}'
                      : note.agentTitle);

              return AppleInteractiveWrapper(
                onTap: () => _openBookmarkItem(note),
                pressedScale: 0.985,
                hapticType: HapticFeedbackType.selection,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: border, width: 1.0),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(
                          isBookRef ? Icons.menu_book_rounded : Icons.bookmark_added_rounded,
                          size: 16,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note.title,
                              style: GoogleFonts.outfit(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: GoogleFonts.outfit(
                                fontSize: 11.5,
                                color: textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.chevron_right_rounded, size: 16, color: textSecondary),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildScholarlyAdabCard({
    required bool isDark,
    required Color surface,
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_outlined, size: 17, color: textPrimary),
              const SizedBox(width: 8),
              Text(
                'Adab & Prinsip Peneliti Turats',
                style: GoogleFonts.outfit(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildAdabItem(
            number: '1',
            title: 'Talaqqi Bersanad',
            desc: 'AI adalah sarana komparasi dan indeksasi naskah; bukan mufti dan bukan pengganti bimbingan guru.',
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildAdabItem(
            number: '2',
            title: 'Ihtiyath & Verifikasi Naskah',
            desc: 'Selalu luangkan waktu untuk membuka dan memeriksa naskah fisik primer sebelum menyimpulkan.',
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildAdabItem(
            number: '3',
            title: 'Amanah Ilmiah',
            desc: 'Sertakan judul kitab, nama muallif, bab, dan nomor halaman dalam menukil ibarah.',
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildAdabItem({
    required String number,
    required String title,
    required String desc,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 18,
          height: 18,
          alignment: Alignment.center,
          margin: const EdgeInsets.only(top: 1),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.outfit(fontSize: 12, height: 1.4, color: textSecondary),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary),
                ),
                TextSpan(text: desc),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DashboardAnnouncementCarousel extends StatefulWidget {
  final bool isDark;
  final Color surface;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;

  const _DashboardAnnouncementCarousel({
    required this.isDark,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
  });

  @override
  State<_DashboardAnnouncementCarousel> createState() =>
      _DashboardAnnouncementCarouselState();
}

class _DashboardAnnouncementCarouselState
    extends State<_DashboardAnnouncementCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoPlayTimer;

  static const List<_AnnouncementSlide> _slides = [
    _AnnouncementSlide(
      badge: 'TENTANG OPENTURATH',
      title: 'Mengenal OpenTurath AI',
      summary:
          'Membaca kitab dan menelusuri ibarah dari naskah rujukan.',
      detailedContent:
          'Gunakan OpenTurath untuk mencari rujukan dan membandingkan matan dengan syarah. Periksa hasilnya pada kitab asal, lalu diskusikan dengan guru.',
    ),
    _AnnouncementSlide(
      badge: 'KEUNGGULAN RISET',
      title: 'Menelusuri Sanad dan Takhrij',
      summary:
          'Dilengkapi kutipan ibarah teks asli, nomor halaman kitab muktamad, serta komparasi silang antar-mazhab.',
      detailedContent:
          'Setiap jawaban dan analisis yang dihasilkan OpenTurath selalu disertai rujukan langsung ke naskah primer. Peneliti dapat meninjau teks Arab asli, nama kitab, bab pembahasan, hingga nama pensyarah guna menjaga akurasi transmisi keilmuan Islam yang berakar kuat pada tradisi sanad.',
    ),
    _AnnouncementSlide(
      badge: 'ADAB & DISCLAIMER',
      title: 'Wasilah Bantu, Bukan Pengganti Guru',
      summary:
          'Kajian agama hakiki wajib melalui talaqqi dengan masyayikh bersanad. AI hanyalah sarana penunjang riset.',
      detailedContent:
          'PENTING DIPAHAMI:\n\nTeknologi kecerdasan buatan hanyalah perkakas indeksasi dan komparasi literatur, bukan mufti dan bukan pengganti otoritas guru (masyayikh). Pemahaman fikih, fatwa hukum, dan kedalaman spiritual tetap wajib dikonfirmasi langsung melalui proses talaqqi dan bimbingan ulama yang kompeten.',
    ),
    _AnnouncementSlide(
      badge: 'PANDUAN RISET',
      title: 'Gunakan dengan Sikap Wara\' & Bijak',
      summary:
          'Verifikasi setiap kutipan dalil ke naskah fisik primer sebelum dijadikan landasan kajian atau karya ilmiah.',
      detailedContent:
          'Sebagai seorang peneliti turats, sikap wara\' dan kehati-hatian (ihtiyath) adalah adab utama. Selalu luangkan waktu untuk membuka dan mengonfirmasi naskah cetak fisik kitab primer sebelum mengutip atau menyebarluaskan hasil telaah ke khalayak luas.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.93);
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (!mounted) return;
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _slides.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _showDetailModal(_AnnouncementSlide slide) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: widget.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: widget.border, width: 1.0),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: widget.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  slide.badge,
                  style: GoogleFonts.outfit(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: widget.accent,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                slide.title,
                style: GoogleFonts.newsreader(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  color: widget.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                slide.detailedContent,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  height: 1.55,
                  color: widget.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: FilledButton.styleFrom(
                    backgroundColor: widget.isDark ? Colors.white : const Color(0xFF18181B),
                    foregroundColor: widget.isDark ? const Color(0xFF18181B) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Text(
                    'Mengerti & Tutup',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 146,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification) {
                _autoPlayTimer?.cancel();
              } else if (notification is ScrollEndNotification) {
                _startAutoPlay();
              }
              return false;
            },
            child: PageView.builder(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              itemCount: _slides.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                final slide = _slides[index];
                return InkWell(
                  onTap: () => _showDetailModal(slide),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: widget.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: widget.border,
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: widget.accent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                slide.badge,
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                  color: widget.accent,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Baca Selengkapnya',
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: widget.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 14,
                                  color: widget.textSecondary,
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          slide.title,
                          style: GoogleFonts.newsreader(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                            color: widget.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          slide.summary,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: widget.textSecondary,
                            height: 1.35,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _slides.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == i ? 18 : 5,
              height: 5,
              decoration: BoxDecoration(
                color: _currentPage == i
                    ? (widget.isDark ? Colors.white : const Color(0xFF18181B))
                    : widget.border,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AnnouncementSlide {
  final String badge;
  final String title;
  final String summary;
  final String detailedContent;

  const _AnnouncementSlide({
    required this.badge,
    required this.title,
    required this.summary,
    required this.detailedContent,
  });
}

```

### FLUTTER FILE: openturath_ai/lib/screens/google_session_auth_screen.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/routes.dart';
import '../core/notebook_navigation.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';
import '../widgets/app_loader.dart';

/// Gerbang Sesi Google (Pre-Auth Gate)
/// Memastikan kuki autentikasi Google aktif di WebView sehingga pengguna
/// langsung dapat menggunakan korpus riset AI tanpa kendala login berulang.
class GoogleSessionAuthScreen extends StatefulWidget {
  const GoogleSessionAuthScreen({super.key});

  @override
  State<GoogleSessionAuthScreen> createState() =>
      _GoogleSessionAuthScreenState();
}

class _GoogleSessionAuthScreenState extends State<GoogleSessionAuthScreen> {
  InAppWebViewController? _webController;
  bool _isSessionReady = false;
  final ValueNotifier<double> _loadProgress = ValueNotifier<double>(0.0);

  static const String _chromeUserAgent =
      "Mozilla/5.0 (Linux; Android 14; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.6613.127 Mobile Safari/537.36";

  static const String _targetLoginUrl =
      "https://accounts.google.com/ServiceLogin?continue=https://notebook.google.com/";

  @override
  void dispose() {
    _loadProgress.dispose();
    _webController = null;
    super.dispose();
  }

  /// Simpan status sesi dan arahkan ke Dashboard
  Future<void> _onSessionAuthenticated() async {
    if (!mounted || _isSessionReady) return;
    setState(() => _isSessionReady = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('google_session_ready', true);
    } catch (_) {}

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
  }

  Future<void> _confirmCancelAndSignOut() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.surfaceCardDark : AppTheme.surfaceCardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusCard)),
        title: Text(
          'Batal Hubungkan Google?',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
          ),
        ),
        content: Text(
          'Akun Google diperlukan agar ruang riset manuskrip AI dapat langsung digunakan tanpa meminta login berulang kali.',
          style: GoogleFonts.outfit(
            fontSize: 13,
            color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Tetap di Sini',
              style: GoogleFonts.outfit(
                color: isDark ? AppTheme.accentDark : AppTheme.accentLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.appleRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusPill)),
            ),
            child: Text(
              'Keluar Akun',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (shouldSignOut == true && mounted) {
      await AuthService().signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvas = isDark ? AppTheme.canvasDark : AppTheme.canvasLight;
    final surface = isDark ? AppTheme.surfaceCardDark : AppTheme.surfaceCardLight;
    final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final textPrimary = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final accent = isDark ? AppTheme.accentDark : AppTheme.accentLight;

    if (_isSessionReady) {
      return Scaffold(
        backgroundColor: canvas,
        body: const Center(
          child: AppLoader(
            title: 'Sesi Google Terhubung',
            subtitle: 'Menyiapkan akses kitab.',
            dotSize: 10,
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final canGoBack = await _webController?.canGoBack() ?? false;
        if (!mounted) return;
        if (canGoBack) {
          await _webController?.goBack();
        } else {
          await _confirmCancelAndSignOut();
        }
      },
      child: Scaffold(
        backgroundColor: canvas,
        appBar: AppBar(
          backgroundColor: canvas,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleSpacing: 16,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hubungkan Akun Google',
                style: GoogleFonts.newsreader(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                'Autentikasi sesi riset naskah turats',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: textSecondary,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Keluar Akun',
              icon: Icon(Icons.logout_rounded, size: 20, color: textSecondary),
              onPressed: _confirmCancelAndSignOut,
            ),
            const SizedBox(width: 8),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2),
            child: ValueListenableBuilder<double>(
              valueListenable: _loadProgress,
              builder: (context, progress, child) {
                if (progress >= 1.0) return const SizedBox(height: 2);
                return LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(accent),
                );
              },
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Banner Penjelasan Transparan
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                  border: Border.all(color: border, width: 0.8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 18, color: accent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Masuk ke akun Google Anda agar ruang riset AI langsung aktif tanpa meminta login berulang.',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          height: 1.35,
                          color: textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                    border: Border.all(color: border, width: 1),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InAppWebView(
                    initialUrlRequest: URLRequest(url: WebUri(_targetLoginUrl)),
                    initialSettings: InAppWebViewSettings(
                      userAgent: _chromeUserAgent,
                      javaScriptEnabled: true,
                      domStorageEnabled: true,
                      databaseEnabled: true,
                      sharedCookiesEnabled: true,
                      thirdPartyCookiesEnabled: true,
                      useHybridComposition: true,
                      supportMultipleWindows: false,
                      useShouldOverrideUrlLoading: true,
                      javaScriptCanOpenWindowsAutomatically: false,
                      mixedContentMode: MixedContentMode.MIXED_CONTENT_NEVER_ALLOW,
                      allowFileAccess: false,
                      allowContentAccess: false,
                      forceDark: isDark ? ForceDark.ON : ForceDark.OFF,
                      algorithmicDarkeningAllowed: false,
                    ),
                    shouldOverrideUrlLoading: (controller, navigationAction) async {
                      final uri = navigationAction.request.url;
                      if (uri == null) return NavigationActionPolicy.CANCEL;

                      return NotebookNavigation.allowed(uri)
                          ? NavigationActionPolicy.ALLOW : NavigationActionPolicy.CANCEL;
                    },
                    onWebViewCreated: (controller) => _webController = controller,
                    onProgressChanged: (controller, progress) {
                      if (mounted) _loadProgress.value = progress / 100;
                    },
                    onLoadStop: (controller, url) async {
                      if (!mounted || url == null) return;
                      final urlStr = url.toString();

                      final cookieManager = CookieManager.instance();
                      final cookies = await cookieManager.getCookies(
                        url: WebUri("https://notebook.google.com"),
                      );
                      final hasSession = cookies.any((c) =>
                          c.name == 'SID' ||
                          c.name == 'HSID' ||
                          c.name == 'SSID' ||
                          c.name == 'OSID');

                      if (hasSession ||
                          (NotebookNavigation.notebook(url) &&
                              !urlStr.contains('ServiceLogin') &&
                              !urlStr.contains('signin'))) {
                        await _onSessionAuthenticated();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

```

### FLUTTER FILE: openturath_ai/lib/screens/library_screen.dart
```dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../models/agent_model.dart';
import '../models/book_model.dart';
import '../services/canonical_library_service.dart';
import '../widgets/library_bottom_sheet.dart';

/// Full screen view for the research library.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key, this.agent});

  final AgentModel? agent;

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final CanonicalLibraryService _service = CanonicalLibraryService.instance;
  Timer? _searchDebounce;

  List<CanonicalBookPresentation>? _allBooks;
  List<CanonicalBookPresentation>? _filteredBooks;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 200), () {
      if (_allBooks == null || !mounted) return;
      setState(() {
        _filteredBooks = _service.filterBooks(
          _allBooks!,
          _searchController.text,
        );
      });
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final books = await _service.loadSyafiiCatalog();
      if (!mounted) return;
      setState(() {
        _allBooks = books;
        _filteredBooks = books;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Katalog rujukan belum dapat dimuat saat ini.';
        _isLoading = false;
      });
    }
  }

  void _showEditionDetails(CanonicalBookPresentation book) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = OTColors.surface(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final border = OTColors.border(isDark);

    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(OTSpacing.lg),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rincian Edisi Naskah',
                        style: OTTypography.sectionHeading(color: textSecondary),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: textSecondary),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: OTSpacing.sm),
                  Text(
                    book.titleArabic,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: OTTypography.arabicReading(color: textPrimary).copyWith(
                      fontSize: 22,
                      height: 1.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: OTSpacing.xs),
                  Text(
                    book.authorArabic,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: OTTypography.arabicReading(color: textSecondary).copyWith(
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: OTSpacing.base),
                  Divider(color: border, height: 1),
                  const SizedBox(height: OTSpacing.base),
                  if (book.verifiedDeathYearHijri != null)
                    _detailRow('Tahun Wafat', '${book.verifiedDeathYearHijri} H', textPrimary, textSecondary),
                  if (book.reviewedTypeLabel != null)
                    _detailRow('Kategori Teks', book.reviewedTypeLabel!, textPrimary, textSecondary),
                  if (book.reviewedEraLabel != null)
                    _detailRow('Masa Penulisan', book.reviewedEraLabel!, textPrimary, textSecondary),
                  if (book.volumesCount != null)
                    _detailRow('Jumlah Jilid', '${book.volumesCount} Jilid', textPrimary, textSecondary),
                  if (book.publisher != null && book.publisher!.isNotEmpty)
                    _detailRow('Penerbit', book.publisher!, textPrimary, textSecondary),
                  if (book.muhaqqiq != null && book.muhaqqiq!.isNotEmpty)
                    _detailRow('Tahqiq / Editor', book.muhaqqiq!, textPrimary, textSecondary),
                  _detailRow('Pengidentifikasi Edisi', book.editionId, textPrimary, textSecondary),
                  const SizedBox(height: OTSpacing.base),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value, Color textPrimary, Color textSecondary) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: OTTypography.caption(color: textSecondary),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: OTTypography.bodyMedium(color: textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvas = OTColors.canvas(isDark);
    final surface = OTColors.surface(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final border = OTColors.border(isDark);

    final title = widget.agent != null
        ? 'Pustaka ${widget.agent!.title}'
        : 'Pustaka Rujukan';

    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        backgroundColor: canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: OTTypography.corpusTitle(color: textPrimary).copyWith(fontSize: 18),
            ),
            if (_allBooks != null)
              Text(
                '${_filteredBooks?.length ?? 0} naskah primer terkatalogisasi',
                style: OTTypography.caption(color: textSecondary).copyWith(fontSize: 11),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(OTSpacing.lg),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari judul kitab atau pengarang...',
                hintStyle: OTTypography.caption(color: textSecondary),
                prefixIcon: Icon(Icons.search_rounded, size: 20, color: textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded, size: 18, color: textSecondary),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: OTRadius.inputBorder,
                  borderSide: BorderSide(color: border, width: 0.8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: OTRadius.inputBorder,
                  borderSide: BorderSide(color: border, width: 0.8),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.menu_book_outlined, size: 48, color: textSecondary),
                            const SizedBox(height: OTSpacing.md),
                            Text(_errorMessage!, style: OTTypography.body(color: textSecondary)),
                            const SizedBox(height: OTSpacing.base),
                            OutlinedButton(onPressed: _loadData, child: const Text('Coba Lagi')),
                          ],
                        ),
                      )
                    : _filteredBooks == null || _filteredBooks!.isEmpty
                        ? Center(
                            child: Text(
                              'Tidak ada naskah yang cocok dengan pencarian',
                              style: OTTypography.body(color: textSecondary),
                            ),
                          )
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: OTSpacing.lg, vertical: OTSpacing.xs),
                            itemCount: _filteredBooks!.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (ctx, index) {
                              final item = _filteredBooks![index];
                              return CanonicalBookTile(
                                book: item,
                                onOpenEdition: () => _showEditionDetails(item),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

```

### FLUTTER FILE: openturath_ai/lib/screens/login_screen.dart
```dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/routes.dart';
import '../core/theme.dart';
import '../core/app_snackbar.dart';
import '../services/auth_service.dart';
import '../widgets/apple_interactive_wrapper.dart';

/// LoginScreen: Gerbang Masuk Ruang Riset OpenTurath AI
/// Mengadopsi filosofi desain minimalis modern Claude:
/// - Dark mode hitam pekat (pure deep black)
/// - Light mode putih pekat (pure clean white)
/// - Shape minimalis dengan garis abu-abu tipis (subtle hairline border)
/// - Slogan resmi: "AI for Islamic Scholarship" dengan tipografi editorial serif
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () => _openLegalUrl('https://openturath.ai/terms');
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () => _openLegalUrl('https://openturath.ai/privacy');
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  Future<void> _openLegalUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.error(context, 'Tidak dapat membuka tautan halaman.');
      }
    }
  }

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.signInWithGoogle();
      if (!mounted || user == null) return;
      Navigator.pushReplacementNamed(context, AppRoutes.googleSessionAuth);
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().contains('network') || e.toString().contains('SocketException')
          ? 'Koneksi internet bermasalah. Periksa jaringan Anda.'
          : 'Gagal masuk akun Google. Silakan coba kembali.';
      AppSnackBar.error(context, message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _stagger({required int delayMs, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 350 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, animChild) {
        return Transform.translate(
          offset: Offset(0, 18 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: animChild,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg = AppTheme.canvasDark;
    const textPrimary = AppTheme.textPrimaryDark;
    const textMuted = AppTheme.textSecondaryDark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: bg,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),

                  // ── 1. Visual Symbol: Arch Artwork dengan Fade Bawah Mulus ──
                  _stagger(
                    delayMs: 40,
                    child: SizedBox(
                      height: 170,
                      width: 170,
                      child: ShaderMask(
                        shaderCallback: (rect) {
                          return const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black, Colors.black, Colors.transparent],
                            stops: [0.0, 0.86, 1.0],
                          ).createShader(rect);
                        },
                        blendMode: BlendMode.dstIn,
                        child: Image.asset(
                          'assets/images/arch_dark_transparent.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── 2. Brand Wordmark: "OpenTurath" ──
                  _stagger(
                    delayMs: 90,
                    child: Text(
                      'OpenTurath',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.newsreader(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.6,
                        color: textPrimary,
                        height: 1.15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── 3. Academic Editorial Slogan: "AI for Islamic Scholarship" ──
                  _stagger(
                    delayMs: 140,
                    child: Text(
                      'AI for Islamic Scholarship',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.newsreader(
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 0.1,
                        color: textMuted,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 56),

                  // ── 4. High-Contrast Solid White Action Pill ──
                  _stagger(
                    delayMs: 200,
                    child: AppleInteractiveWrapper(
                      onTap: _isLoading ? null : _signIn,
                      hapticType: HapticFeedbackType.medium,
                      child: SizedBox(
                        height: 52,
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _signIn,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF0E0E10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF0E0E10),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _GoogleGVector(),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Lanjutkan dengan Google',
                                      style: GoogleFonts.outfit(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: -0.1,
                                        color: const Color(0xFF0E0E10),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── 5. Minimalist Legal Disclaimer (Proporsional 2-Baris Seimbang) ──
                  _stagger(
                    delayMs: 260,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: Text.rich(
                        TextSpan(
                          text: 'Dengan masuk, Anda menyetujui\n',
                          style: GoogleFonts.outfit(
                            color: textMuted,
                            fontSize: 12,
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(
                              text: 'Ketentuan Layanan',
                              style: const TextStyle(
                                color: textPrimary,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w500,
                              ),
                              recognizer: _termsRecognizer,
                            ),
                            const TextSpan(text: ' & '),
                            TextSpan(
                              text: 'Kebijakan Privasi',
                              style: const TextStyle(
                                color: textPrimary,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w500,
                              ),
                              recognizer: _privacyRecognizer,
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
}

class _GoogleGVector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="20px" height="20px">
  <path fill="#FFC107" d="M43.611,20.083H42V20H24v8h11.303c-1.649,4.657-6.08,8-11.303,8c-6.627,0-12-5.373-12-12c0-6.627,5.373-12,12-12c3.059,0,5.842,1.154,7.961,3.039l5.657-5.657C34.046,6.053,29.268,4,24,4C12.955,4,4,12.955,4,24c0,11.045,8.955,20,20,20c11.045,0,20-8.955,20-20C44,22.659,43.862,21.35,43.611,20.083z"/>
  <path fill="#FF3D00" d="M6.306,14.691l6.571,4.819C14.655,15.108,18.961,12,24,12c3.059,0,5.842,1.154,7.961,3.039l5.657-5.657C34.046,6.053,29.268,4,24,4C16.318,4,9.656,8.337,6.306,14.691z"/>
  <path fill="#4CAF50" d="M24,44c5.166,0,9.86-1.977,13.409-5.192l-6.19-5.238C29.211,35.091,26.715,36,24,36c-5.202,0-9.619-3.317-11.283-7.946l-6.522,5.025C9.505,39.556,16.227,44,24,44z"/>
  <path fill="#1976D2" d="M43.611,20.083H42V20H24v8h11.303c-0.792,2.237-2.231,4.166-4.087,5.571c0.001-0.001,0.002-0.001,0.003-0.002l6.19,5.238C36.971,39.205,44,34,44,24C44,22.659,43.862,21.35,43.611,20.083z"/>
</svg>
''',
      width: 20,
      height: 20,
    );
  }
}

```

### FLUTTER FILE: openturath_ai/lib/screens/main_shell_screen.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_config.dart';
import '../core/app_copy.dart';
import '../core/theme.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_motion.dart';
import '../models/agent_model.dart';
import '../models/field_model.dart';
import 'dashboard_screen.dart';
import 'specialist_list_screen.dart';
import 'bookmark_screen.dart';
import 'profile_screen.dart';
import '../widgets/openturath_brand.dart';

class MainShellController extends InheritedWidget {
  final void Function(int index, {String? fieldId, CorpusKind? kind}) switchTab;

  const MainShellController({
    super.key,
    required this.switchTab,
    required super.child,
  });

  static MainShellController? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MainShellController>();
  }

  @override
  bool updateShouldNotify(MainShellController oldWidget) => false;
}

class MainShellScreen extends StatefulWidget {
  final int initialTab;

  const MainShellScreen({super.key, this.initialTab = 0});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late int _currentIndex;
  late final PageController _pageController;
  String? _selectedFieldId;
  CorpusKind? _selectedKind;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index, {String? fieldId, CorpusKind? kind}) {
    if (_pageController.hasClients && _currentIndex != index) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
    setState(() {
      _currentIndex = index;
      _selectedFieldId = fieldId;
      _selectedKind = kind;
    });
  }

  List<Widget> _buildScreens() {
    final field = _selectedFieldId != null
        ? FieldModel.defaultFields.firstWhere(
            (f) => f.id == _selectedFieldId,
            orElse: () => FieldModel.defaultFields.first,
          )
        : null;

    return [
      const DashboardScreen(),
      SpecialistListScreen(
        key: ValueKey('${_selectedFieldId}_${_selectedKind?.name}'),
        field: field,
      ),
      const BookmarkScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvas = isDark ? AppTheme.canvasDark : AppTheme.canvasLight;
    final surface = isDark ? AppTheme.surfaceCardDark : AppTheme.surfaceCardLight;
    final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final accent = isDark ? AppTheme.accentDark : AppTheme.accentLight;
    final unselected = isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiaryLight;

    final isWideScreen = MediaQuery.of(context).size.width >= 768;
    final screens = _buildScreens();

    return MainShellController(
      switchTab: _onTabSelected,
      child: PopScope(
        canPop: _currentIndex == 0,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && _currentIndex != 0) {
            _onTabSelected(0);
          }
        },
        child: isWideScreen
            ? Scaffold(
                backgroundColor: canvas,
                body: Row(
                  children: [
                    Container(
                      width: 76,
                      decoration: BoxDecoration(
                        color: surface,
                        border: Border(right: BorderSide(color: border, width: 1)),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          OpenTurathMark(size: 36, color: accent),
                          const SizedBox(height: 32),
                          _RailItem(
                            icon: Icons.home_outlined,
                            activeIcon: Icons.home_rounded,
                            label: AppCopy.navHome,
                            isSelected: _currentIndex == 0,
                            accent: accent,
                            unselected: unselected,
                            onTap: () => _onTabSelected(0),
                          ),
                          const SizedBox(height: 16),
                          _RailItem(
                            icon: Icons.auto_awesome_outlined,
                            activeIcon: Icons.auto_awesome_rounded,
                            label: AppCopy.navStudies,
                            isSelected: _currentIndex == 1,
                            accent: accent,
                            unselected: unselected,
                            onTap: () => _onTabSelected(1),
                          ),
                          const SizedBox(height: 16),
                          _RailItem(
                            icon: Icons.bookmark_border_rounded,
                            activeIcon: Icons.bookmark_rounded,
                            label: AppCopy.navSaved,
                            isSelected: _currentIndex == 2,
                            accent: accent,
                            unselected: unselected,
                            onTap: () => _onTabSelected(2),
                          ),
                          const SizedBox(height: 16),
                          _RailItem(
                            icon: Icons.settings_outlined,
                            activeIcon: Icons.settings_rounded,
                            label: AppCopy.navSettings,
                            isSelected: _currentIndex == 3,
                            accent: accent,
                            unselected: unselected,
                            onTap: () => _onTabSelected(3),
                          ),
                          const Spacer(),
                          IconButton(
                            tooltip: isDark ? 'Beralih ke Tema Terang' : 'Beralih ke Tema Gelap',
                            icon: Icon(
                              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                              color: unselected,
                              size: 20,
                            ),
                            onPressed: () {
                              AppConfig.setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: screens,
                      ),
                    ),
                  ],
                ),
              )
            : Scaffold(
                backgroundColor: canvas,
                body: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: screens,
                ),
                extendBody: true,
                bottomNavigationBar: Container(
                  decoration: BoxDecoration(
                    color: surface,
                    border: Border(
                      top: BorderSide(
                        color: border,
                        width: 0.8,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      height: 64,
                      child: Row(
                        children: [
                          Expanded(
                            child: _GoogleNavBarItem(
                              icon: Icons.home_outlined,
                              activeIcon: Icons.home_rounded,
                              label: AppCopy.navHome,
                              isSelected: _currentIndex == 0,
                              onTap: () => _onTabSelected(0),
                            ),
                          ),
                          Expanded(
                            child: _GoogleNavBarItem(
                              icon: Icons.auto_awesome_outlined,
                              activeIcon: Icons.auto_awesome_rounded,
                              label: AppCopy.navStudies,
                              isSelected: _currentIndex == 1,
                              onTap: () => _onTabSelected(1),
                            ),
                          ),
                          Expanded(
                            child: _GoogleNavBarItem(
                              icon: Icons.bookmark_border_rounded,
                              activeIcon: Icons.bookmark_rounded,
                              label: AppCopy.navSaved,
                              isSelected: _currentIndex == 2,
                              onTap: () => _onTabSelected(2),
                            ),
                          ),
                          Expanded(
                            child: _GoogleNavBarItem(
                              icon: Icons.settings_outlined,
                              activeIcon: Icons.settings_rounded,
                              label: AppCopy.navSettings,
                              isSelected: _currentIndex == 3,
                              onTap: () => _onTabSelected(3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _GoogleNavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoogleNavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeBg = isDark ? Colors.white : const Color(0xFF18181B);
    final activeFg = isDark ? const Color(0xFF18181B) : Colors.white;
    final unselected = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final labelColor = isSelected
        ? (isDark ? Colors.white : const Color(0xFF18181B))
        : unselected;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: 56,
              height: 30,
              decoration: BoxDecoration(
                color: isSelected ? activeBg : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? activeFg : unselected,
                  size: 21,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: -0.1,
                color: labelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final Color accent;
  final Color unselected;
  final VoidCallback onTap;

  const _RailItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.accent,
    required this.unselected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeBg = isDark ? Colors.white : const Color(0xFF18181B);
    final activeFg = isDark ? const Color(0xFF18181B) : Colors.white;

    return InkWell(
      onTap: () {
        OTMotion.selection();
        onTap();
      },
      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: OTMotion.normal,
              curve: OTMotion.curve,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? activeBg : Colors.transparent,
                borderRadius: BorderRadius.circular(AppTheme.radiusPill),
              ),
              child: AnimatedScale(
                scale: isSelected ? 1.0 : 0.95,
                duration: OTMotion.normal,
                curve: Curves.easeOutBack,
                child: Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? activeFg : unselected,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: OTTypography.captionMedium(
                color: isSelected ? (isDark ? Colors.white : const Color(0xFF18181B)) : unselected,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

```

### FLUTTER FILE: openturath_ai/lib/screens/profile_screen.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../core/routes.dart';
import '../core/app_config.dart';
import '../core/app_copy.dart';
import '../core/app_snackbar.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../models/user_model.dart';
import '../models/agent_model.dart';
import '../services/auth_service.dart';
import '../widgets/apple_interactive_wrapper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  bool _isLoggingOut = false;
  bool _isDeletingAccount = false;
  String _appVersion = '1.0.9';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() => _appVersion = '${info.version}+${info.buildNumber}');
      }
    } catch (_) {}
  }

  Future<void> _logout() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = OTColors.surface(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(borderRadius: OTRadius.dialogBorder),
          title: Text(
            AppCopy.logoutDialogTitle,
            style: OTTypography.cardTitle(color: textPrimary).copyWith(fontSize: 18),
          ),
          content: Text(
            AppCopy.logoutDialogBody,
            style: OTTypography.body(color: textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Batal', style: OTTypography.button(color: textSecondary)),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: OTColors.destructive,
                shape: RoundedRectangleBorder(borderRadius: OTRadius.buttonBorder),
              ),
              child: Text(AppCopy.logoutButton, style: OTTypography.button(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (!mounted || confirm != true) return;

    setState(() => _isLoggingOut = true);
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  Future<void> _deleteAccount() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = OTColors.surface(isDark);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(borderRadius: OTRadius.dialogBorder),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: OTColors.destructive, size: 24),
              const SizedBox(width: OTSpacing.sm),
              Expanded(
                child: Text(
                  AppCopy.deleteAccountTitle,
                  style: OTTypography.cardTitle(color: OTColors.destructive).copyWith(fontSize: 18),
                ),
              ),
            ],
          ),
          content: Text(
            AppCopy.deleteAccountBody,
            style: OTTypography.body(color: OTColors.textSecondary(isDark)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Batal', style: OTTypography.button(color: OTColors.textSecondary(isDark))),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: OTColors.destructive,
                shape: RoundedRectangleBorder(borderRadius: OTRadius.buttonBorder),
              ),
              child: Text(AppCopy.deleteAccountButton, style: OTTypography.button(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (!mounted || confirm != true) return;

    setState(() => _isDeletingAccount = true);
    try {
      await _authService.deleteAccount();
      if (mounted) {
        AppSnackBar.success(context, AppCopy.deleteAccountSuccess);
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeletingAccount = false);
        final errText = e.toString().contains('requires-recent-login')
            ? AppCopy.recentLoginRequired
            : AppCopy.networkError;
        AppSnackBar.error(context, errText);
      }
    }
  }

  Future<void> _openSubscription() async {
    final user = await _authService.getCurrentUserModel();
    if (!mounted) return;

    Navigator.pushNamed(
      context,
      AppRoutes.subscription,
      arguments: {
        'user': user,
        'agent': AgentModel.defaultAgents.firstWhere(
          (a) => a.id == 'fiqh_tahawwulat',
          orElse: () => AgentModel.defaultAgents.first,
        ),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvas = OTColors.canvas(isDark);
    final surface = OTColors.surface(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        backgroundColor: canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          AppCopy.navSettings,
          style: GoogleFonts.newsreader(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
            color: textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<UserModel?>(
          stream: _authService.userStream,
          builder: (context, snapshot) {
            final userModel = snapshot.data;
            final fbUser = FirebaseAuth.instance.currentUser;

            final displayName = userModel?.name.isNotEmpty == true
                ? userModel!.name
                : (fbUser?.displayName ?? 'Pengguna');
            final email = userModel?.email.isNotEmpty == true
                ? userModel!.email
                : (fbUser?.email ?? 'pengguna@openturath.id');
            final plan = userModel?.plan ?? 'trial';
            final isSubscribed =
                userModel?.isSubscriptionActive ?? (userModel?.isPremium ?? false);

            final exp = userModel?.subscriptionExpiry;
            final expStr = exp != null ? ' · Aktif sampai ${exp.day}/${exp.month}/${exp.year}' : '';
            final String subscriptionSubtitle;

            if (isSubscribed) {
              if (plan == 'sultan' || plan == 'all_access' || plan == 'all_ai_1m' || plan == 'all_ai') {
                subscriptionSubtitle = 'Semua Kajian$expStr';
              } else if (plan == 'field') {
                subscriptionSubtitle = 'Rumpun Kajian$expStr';
              } else if (plan == 'single') {
                subscriptionSubtitle = 'Kajian Satuan$expStr';
              } else {
                subscriptionSubtitle = '${AppCopy.activeSubscription}$expStr';
              }
            } else {
              subscriptionSubtitle = AppCopy.inactiveSubscription;
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 108),
              physics: const BouncingScrollPhysics(),
              children: [
                // ── Card 1: Akun & Status Hak Akses ──
                Container(
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border, width: 1.0),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.05),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(Icons.person_outline_rounded, size: 22, color: textPrimary),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.2,
                                      color: textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    email,
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      color: textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSubscribed
                                    ? (isDark ? Colors.white : const Color(0xFF18181B))
                                    : (isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5)),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                isSubscribed ? 'Aktif' : 'Gratis',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isSubscribed
                                      ? (isDark ? const Color(0xFF18181B) : Colors.white)
                                      : textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1, color: border),
                      _SettingsTile(
                        icon: Icons.credit_card_outlined,
                        title: AppCopy.subscription,
                        subtitle: subscriptionSubtitle,
                        trailing: Icon(Icons.chevron_right_rounded, color: textSecondary, size: 20),
                        onTap: _openSubscription,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Card 2: Mode Tampilan 3 Pilihan & Bahasa ──
                Container(
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border, width: 1.0),
                  ),
                  child: Column(
                    children: [
                      ValueListenableBuilder<ThemeMode>(
                        valueListenable: AppConfig.themeNotifier,
                        builder: (context, currentMode, _) {
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.palette_outlined, size: 20, color: textSecondary),
                                    const SizedBox(width: 10),
                                    Text(
                                      AppCopy.appearance,
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: textPrimary,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      currentMode == ThemeMode.system
                                          ? AppCopy.modeSystem
                                          : currentMode == ThemeMode.dark
                                              ? AppCopy.modeDark
                                              : AppCopy.modeLight,
                                      style: GoogleFonts.outfit(
                                        fontSize: 12.5,
                                        color: textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      _buildThemeOption(
                                        title: 'Ikuti Sistem',
                                        icon: Icons.brightness_auto_rounded,
                                        isSelected: currentMode == ThemeMode.system,
                                        isDark: isDark,
                                        textPrimary: textPrimary,
                                        textSecondary: textSecondary,
                                        onTap: () => AppConfig.setThemeMode(ThemeMode.system),
                                      ),
                                      _buildThemeOption(
                                        title: 'Terang',
                                        icon: Icons.light_mode_rounded,
                                        isSelected: currentMode == ThemeMode.light,
                                        isDark: isDark,
                                        textPrimary: textPrimary,
                                        textSecondary: textSecondary,
                                        onTap: () => AppConfig.setThemeMode(ThemeMode.light),
                                      ),
                                      _buildThemeOption(
                                        title: 'Gelap',
                                        icon: Icons.dark_mode_rounded,
                                        isSelected: currentMode == ThemeMode.dark,
                                        isDark: isDark,
                                        textPrimary: textPrimary,
                                        textSecondary: textSecondary,
                                        onTap: () => AppConfig.setThemeMode(ThemeMode.dark),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      Divider(height: 1, color: border),
                      _SettingsTile(
                        icon: Icons.translate_rounded,
                        title: AppCopy.language,
                        subtitle: AppCopy.languageIndonesian,
                        trailing: Icon(Icons.chevron_right_rounded, color: textSecondary, size: 20),
                        onTap: () => _showLanguageModal(
                          context,
                          isDark,
                          textPrimary,
                          textSecondary,
                          surface,
                          border,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Card 4: Legal & About ──
                Container(
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border, width: 1.0),
                  ),
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.article_outlined,
                        title: 'Ketentuan Layanan',
                        subtitle: 'Syarat dan ketentuan OpenTurath',
                        trailing: Icon(Icons.chevron_right_rounded, color: textSecondary, size: 20),
                        onTap: () => _showTermsOfService(
                          context,
                          isDark,
                          textPrimary,
                          textSecondary,
                          surface,
                          border,
                        ),
                      ),
                      Divider(height: 1, color: border),
                      _SettingsTile(
                        icon: Icons.security_outlined,
                        title: 'Kebijakan Privasi',
                        subtitle: 'Perlindungan kerahasiaan data pengguna',
                        trailing: Icon(Icons.chevron_right_rounded, color: textSecondary, size: 20),
                        onTap: () => _showPrivacyPolicy(
                          context,
                          isDark,
                          textPrimary,
                          textSecondary,
                          surface,
                          border,
                        ),
                      ),
                      Divider(height: 1, color: border),
                      _SettingsTile(
                        icon: Icons.info_outline_rounded,
                        title: AppCopy.aboutTitle,
                        subtitle: 'Versi $_appVersion · ${AppCopy.appTagline}',
                        trailing: Icon(Icons.chevron_right_rounded, color: textSecondary, size: 20),
                        onTap: () => _showAboutModal(
                          context,
                          isDark,
                          textPrimary,
                          textSecondary,
                          surface,
                          border,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Card 5: Log out ──
                Container(
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border, width: 1.0),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: (_isLoggingOut || _isDeletingAccount) ? null : _logout,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.logout_rounded,
                              color: Color(0xFFF87171),
                              size: 20,
                            ),
                            const SizedBox(width: 14),
                            Text(
                              _isLoggingOut ? 'Sedang keluar...' : AppCopy.logoutButton,
                              style: GoogleFonts.outfit(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFF87171),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Quiet Google Play Compliance: Delete Account ──
                Center(
                  child: TextButton(
                    onPressed: (_isLoggingOut || _isDeletingAccount) ? null : _deleteAccount,
                    child: _isDeletingAccount
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: OTColors.destructive),
                          )
                        : Text(
                            AppCopy.deleteAccountButton,
                            style: GoogleFonts.outfit(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
                            ),
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showAboutModal(
    BuildContext context,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
    Color surface,
    Color border,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: OTRadius.dialogBorder,
          side: BorderSide(color: border, width: 0.8),
        ),
        title: Text(
          AppCopy.aboutTitle,
          style: OTTypography.corpusTitle(color: textPrimary).copyWith(fontSize: 20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Versi $_appVersion · ${AppCopy.appTagline}',
              style: OTTypography.captionMedium(color: textSecondary),
            ),
            const SizedBox(height: 12),
            Text(
              AppCopy.aboutDescription,
              style: OTTypography.body(color: textPrimary),
            ),
            const SizedBox(height: 12),
            Text(
              AppCopy.aboutScholarlyPrinciple,
              style: OTTypography.caption(color: textSecondary),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(
              backgroundColor: textPrimary,
              foregroundColor: isDark ? const Color(0xFF18181B) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: OTRadius.buttonBorder),
            ),
            child: Text('Tutup', style: OTTypography.button()),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(
    BuildContext context,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
    Color surface,
    Color border,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.8,
        decoration: BoxDecoration(
          color: surface,
          borderRadius: OTRadius.sheetBorder,
          border: Border.all(color: border, width: 0.8),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: textSecondary.withValues(alpha: 0.3),
                  borderRadius: OTRadius.chipBorder,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ketentuan Layanan',
                  style: OTTypography.corpusTitle(color: textPrimary).copyWith(fontSize: 20),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: Icon(Icons.close_rounded, size: 20, color: textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegalSection(
                      title: '1. Ruang Lingkup & Tujuan Riset',
                      content:
                          'OpenTurath membantu pembaca mencari ibarah, membandingkan matan dan syarah, serta menelusuri rujukan kitab. Hasilnya perlu diperiksa kembali pada naskah asli.',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 14),
                    _buildLegalSection(
                      title: '2. Batasan Tanggung Jawab & Penafian Fatwa',
                      content:
                          'Hasil analisis, transkripsi, dan kutipan teks yang disajikan oleh sistem kecerdasan buatan bersifat sebagai referensi riset awal. OpenTurath BUKAN mufti dan tidak berwenang mengeluarkan fatwa syar\'i mandiri. Pengguna diwajibkan untuk mengonfirmasi hasil telaah dengan ulama dan guru yang bersanad (talaqqi) serta merujuk ke naskah fisik kitab primer.',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 14),
                    _buildLegalSection(
                      title: '3. Akun Pengguna & Hak Akses',
                      content:
                          'Pengguna bertanggung jawab menjaga keamanan kredensial akun Google yang digunakan. Setiap paket langganan (Akses Penuh maupun Modul Spesialis) bersifat personal dan tidak diperkenankan untuk diperjualbelikan kembali atau dieksploitasi melalui bot otomatis tanpa izin tertulis.',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 14),
                    _buildLegalSection(
                      title: '4. Ketentuan Pembayaran & Berlangganan',
                      content:
                          'Seluruh transaksi langganan diproses secara resmi melalui payment gateway terverifikasi (DOKU). Pengguna berhak mengakses ruang riset sesuai paket dan durasi yang dipilih.',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx),
                style: FilledButton.styleFrom(
                  backgroundColor: textPrimary,
                  foregroundColor: isDark ? const Color(0xFF18181B) : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: OTRadius.buttonBorder),
                ),
                child: Text('Saya Pahami & Setuju', style: OTTypography.button()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicy(
    BuildContext context,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
    Color surface,
    Color border,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.8,
        decoration: BoxDecoration(
          color: surface,
          borderRadius: OTRadius.sheetBorder,
          border: Border.all(color: border, width: 0.8),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: textSecondary.withValues(alpha: 0.3),
                  borderRadius: OTRadius.chipBorder,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kebijakan Privasi',
                  style: OTTypography.corpusTitle(color: textPrimary).copyWith(fontSize: 20),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: Icon(Icons.close_rounded, size: 20, color: textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegalSection(
                      title: '1. Pengumpulan & Penggunaan Data',
                      content:
                          'OpenTurath hanya mengumpulkan data profil dasar (nama, alamat email, dan foto profil publik) yang diotorisasi saat Anda masuk menggunakan Akun Google. Data ini digunakan secara eksklusif untuk otentikasi sesi riset dan personalisasi akun.',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 14),
                    _buildLegalSection(
                      title: '2. Kerahasiaan Sesi & Catatan Riset',
                      content:
                          'Pertanyaan kajian, kutipan ibarah, dan riwayat bookmark naskah kitab yang Anda telusuri dienkripsi dengan standar keamanan industri. OpenTurath tidak membagikan, mempublikasikan, ataupun memperjualbelikan data riset Anda kepada pihak ketiga manapun.',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 14),
                    _buildLegalSection(
                      title: '3. Keamanan Sesi Google & NotebookLM',
                      content:
                          'Koneksi sesi telaah dengan Google NotebookLM berjalan di lingkungan aman melalui enkripsi SSL/TLS. Kredensial kata sandi Anda tidak pernah disimpan di server OpenTurath.',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 14),
                    _buildLegalSection(
                      title: '4. Hak Penghapusan Data Pengguna',
                      content:
                          'Anda memiliki hak mutlak untuk menghapus akun Anda beserta seluruh riwayat telaah dan bookmark kapan saja melalui menu Pengaturan > Hapus Akun & Data.',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx),
                style: FilledButton.styleFrom(
                  backgroundColor: textPrimary,
                  foregroundColor: isDark ? const Color(0xFF18181B) : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: OTRadius.buttonBorder),
                ),
                child: Text('Tutup', style: OTTypography.button()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageModal(
    BuildContext context,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
    Color surface,
    Color border,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: OTRadius.dialogBorder,
          side: BorderSide(color: border, width: 0.8),
        ),
        title: Text(
          'Bahasa Aplikasi',
          style: OTTypography.corpusTitle(color: textPrimary).copyWith(fontSize: 20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Menu tersedia dalam bahasa Indonesia. Teks Arab dapat dibaca dengan atau tanpa harakat.',
              style: OTTypography.body(color: textPrimary),
            ),
            const SizedBox(height: 10),
            Text(
              'Dukungan antarmuka penuh Bahasa Arab (العربية) dan Inggris (English) sedang dalam proses finalisasi kurasi kebahasaan.',
              style: OTTypography.caption(color: textSecondary),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(
              backgroundColor: textPrimary,
              foregroundColor: isDark ? const Color(0xFF18181B) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: OTRadius.buttonBorder),
            ),
            child: Text('Tutup', style: OTTypography.button()),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalSection({
    required String title,
    required String content,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: OTTypography.bodyMedium(color: textPrimary).copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: OTTypography.caption(color: textSecondary).copyWith(height: 1.5),
        ),
      ],
    );
  }

  Widget _buildThemeOption({
    required String title,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    required VoidCallback onTap,
  }) {
    final activeBg = isDark ? const Color(0xFF18181B) : Colors.white;
    final activeFg = isDark ? Colors.white : const Color(0xFF18181B);
    final inactiveFg = textSecondary;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: isSelected ? activeFg : inactiveFg),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? activeFg : inactiveFg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    return AppleInteractiveWrapper(
      onTap: onTap,
      pressedScale: 0.985,
      hapticType: HapticFeedbackType.light,
      borderRadius: BorderRadius.circular(10),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: OTSpacing.base, vertical: 2),
        leading: Icon(
          icon,
          size: 21,
          color: textPrimary,
        ),
        title: Text(
          title,
          style: OTTypography.bodyMedium(color: textPrimary),
        ),
        subtitle: Text(
          subtitle,
          style: OTTypography.caption(color: textSecondary),
        ),
        trailing: trailing,
      ),
    );
  }
}

```

### FLUTTER FILE: openturath_ai/lib/screens/specialist_list_screen.dart
```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/arabic_utils.dart';
import '../core/routes.dart';
import '../core/app_snackbar.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_motion.dart';
import '../models/field_model.dart';
import '../models/agent_model.dart';
import '../services/agent_service.dart';
import '../services/auth_service.dart';
import '../widgets/corpus_kind_control.dart';
import '../widgets/specialist_card.dart';
import '../widgets/library_bottom_sheet.dart';
import '../widgets/apple_interactive_wrapper.dart';

class SpecialistListScreen extends StatefulWidget {
  final FieldModel? field; // Nullable if opened as general Specialist tab

  const SpecialistListScreen({super.key, this.field});

  @override
  State<SpecialistListScreen> createState() => _SpecialistListScreenState();
}

class _SpecialistListScreenState extends State<SpecialistListScreen> {
  final AgentService _agentService = AgentService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;

  List<AgentModel> _allAgents = [];
  String? _selectedFieldId;
  String _searchQuery = '';
  bool _isLoading = true;
  CorpusKind _corpusKind = CorpusKind.discipline;

  @override
  void initState() {
    super.initState();
    _selectedFieldId = widget.field?.id;
    _loadAgents();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadAgents() async {
    try {
      final agents = await _agentService.getAgents();
      if (mounted) {
        setState(() {
          _allAgents = agents;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _allAgents = AgentModel.defaultAgents;
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) {
        setState(() {
          _searchQuery = val.trim();
        });
      }
    });
  }

  List<AgentModel> _computeFilteredAgents() {
    return _allAgents.where((agent) {
      // 1. Filter by CorpusKind
      if (agent.kind != _corpusKind) return false;

      // 2. Filter by discipline field if in discipline mode
      if (_corpusKind == CorpusKind.discipline) {
        final matchesField = _selectedFieldId == null ||
            _selectedFieldId == 'all' ||
            agent.fieldId == _selectedFieldId;
        if (!matchesField) return false;
      }

      // 3. Filter by search query
      if (_searchQuery.isEmpty) return true;

      return ArabicUtils.matches(agent.title, _searchQuery) ||
          ArabicUtils.matches(agent.titleArabic, _searchQuery) ||
          ArabicUtils.matches(agent.subtitleAcademic, _searchQuery) ||
          ArabicUtils.matches(agent.description, _searchQuery);
    }).toList();
  }

  Future<void> _openAgent(AgentModel agent) async {
    OTMotion.light();
    if (agent.isComingSoon) {
      AppSnackBar.warning(
        context,
        '${agent.title} belum tersedia (Segera Hadir). Modul ini sedang dalam tahap kurasi naskah kitab primer.',
      );
      return;
    }

    final user = await _authService.getCurrentUserModel();
    if (!mounted) return;

    if (user != null && !user.hasAccessToAgent(agent.id)) {
      _openSubscriptionForAgent(agent);
      return;
    }

    if (!mounted) return;
    Navigator.pushNamed(
      context,
      AppRoutes.agentWebview,
      arguments: {'agent': agent, 'user': user},
    );
  }

  void _openSubscriptionForAgent(AgentModel agent) {
    _authService.getCurrentUserModel().then((user) {
      if (!mounted) return;
      Navigator.pushNamed(
        context,
        AppRoutes.subscription,
        arguments: {'agent': agent, 'user': user},
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final canvas = OTColors.canvas(isDark);
    final surface = OTColors.surface(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    final isGeneralTab = widget.field == null;
    final title = isGeneralTab ? 'Asisten AI' : widget.field!.name;
    final filtered = _computeFilteredAgents();

    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        title: Text(
          title,
          style: OTTypography.corpusTitle(color: textPrimary).copyWith(fontSize: 20),
        ),
        centerTitle: false,
        backgroundColor: canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: isGeneralTab
            ? null
            : IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Search & Controls Container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: OTSpacing.lg, vertical: OTSpacing.sm),
              child: Column(
                children: [
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: border, width: 1.0),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded, size: 20, color: textSecondary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: _onSearchChanged,
                            style: GoogleFonts.outfit(fontSize: 13.5, color: textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Cari spesialis, kitab, atau bab...',
                              hintStyle: GoogleFonts.outfit(fontSize: 13.5, color: textSecondary),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              filled: false,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                            child: Icon(Icons.close_rounded, size: 18, color: textSecondary),
                          ),
                      ],
                    ),
                  ),

                  if (isGeneralTab) ...[
                    const SizedBox(height: OTSpacing.md),
                    // Dual Taxonomy Switcher
                    CorpusKindControl(
                      value: _corpusKind,
                      onChanged: (k) {
                        setState(() {
                          _corpusKind = k;
                          _selectedFieldId = null;
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),

            // Discipline Filter Chips (only in discipline mode)
            if (isGeneralTab && _corpusKind == CorpusKind.discipline) ...[
              SizedBox(
                height: 38,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: OTSpacing.lg),
                  children: [
                    _filterChip(
                      label: 'Semua Bidang',
                      isSelected: _selectedFieldId == null || _selectedFieldId == 'all',
                      onTap: () => setState(() => _selectedFieldId = 'all'),
                      isDark: isDark,
                      border: border,
                      surface: surface,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(width: 8),
                    ...FieldModel.defaultFields.map((field) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _filterChip(
                          label: field.name,
                          isSelected: _selectedFieldId == field.id,
                          onTap: () => setState(() => _selectedFieldId = field.id),
                          isDark: isDark,
                          border: border,
                          surface: surface,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: OTSpacing.sm),
            ],

            // Content List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(OTSpacing.xl),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.search_off_rounded, size: 40, color: textSecondary),
                                const SizedBox(height: OTSpacing.sm),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'Tidak ditemukan rujukan atau spesialis yang sesuai.'
                                      : 'Belum ada ruang riset untuk bidang ini.',
                                  style: OTTypography.body(color: textSecondary),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : Builder(
                          builder: (context) {
                            final sorted = List<AgentModel>.from(filtered);
                            if (_searchQuery.isEmpty) {
                              sorted.sort((a, b) {
                                if (a.isActive && !b.isActive) return -1;
                                if (!a.isActive && b.isActive) return 1;
                                return 0;
                              });
                            }

                            return ListView.separated(
                              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                              padding: const EdgeInsets.fromLTRB(OTSpacing.lg, OTSpacing.xs, OTSpacing.lg, 96),
                              itemCount: sorted.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final agent = sorted[index];
                                return SpecialistCard(
                                  title: agent.title,
                                  statusLabel: agent.isComingSoon ? 'Segera Hadir' : null,
                                  onOpen: () => _openAgent(agent),
                                  onOpenLibrary: agent.catalogId != null
                                      ? () => showResearchLibrary(context, agent: agent)
                                      : null,
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    required Color border,
    required Color surface,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final activeBg = textPrimary;
    final activeFg = isDark ? Colors.black : Colors.white;

    return AppleInteractiveWrapper(
      onTap: onTap,
      pressedScale: 0.94,
      hapticType: HapticFeedbackType.selection,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeBg : border,
            width: 0.8,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: OTTypography.caption(color: isSelected ? activeFg : textSecondary).copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

```

### FLUTTER FILE: openturath_ai/lib/screens/splash_screen.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/routes.dart';
import '../core/theme.dart';
import '../widgets/app_loader.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
    _checkAuthAndNavigate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndNavigate() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      String targetRoute;

      if (user != null && !user.isAnonymous) {
        final prefs = await SharedPreferences.getInstance()
            .timeout(const Duration(seconds: 3));
        final isSessionReady = prefs.getBool('google_session_ready') ?? false;
        if (!isSessionReady) {
          targetRoute = AppRoutes.googleSessionAuth;
        } else {
          targetRoute = AppRoutes.dashboard;
        }
      } else {
        targetRoute = AppRoutes.login;
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, targetRoute);
    } catch (_) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = AppTheme.canvasDark;
    const textPrimary = AppTheme.textPrimaryDark;
    const accent = AppTheme.textSecondaryDark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: bg,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: bg,
        body: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'OpenTurath',
                    style: GoogleFonts.newsreader(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.6,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const AppLoader(color: accent, dotSize: 7, spacing: 3.5),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

```

### FLUTTER FILE: openturath_ai/lib/screens/subscription_screen.dart
```dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_snackbar.dart';
import '../core/constants.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_motion.dart';
import '../core/design/ot_spacing.dart';
import '../models/agent_model.dart';
import '../models/user_model.dart';
import '../services/subscription_service.dart';
import '../widgets/doku_checkout_sheet.dart';
import '../widgets/redeem_code_sheet.dart';
import '../widgets/apple_interactive_wrapper.dart';

/// Halaman Langganan Ruang Riset OpenTurath AI (Quiet Scholar Adaptive)
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final SubscriptionService _subService = SubscriptionService();
  UserModel? _user;
  AgentModel? _agent;
  bool _isProcessing = false;
  int _selectedDurationIndex = 0; // 0: 1 Bulan, 1: 6 Bulan, 2: 1 Tahun

  List<AgentModel> get _activeAgents =>
      AgentModel.defaultAgents.where((a) => a.isActive).toList();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_user == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is UserModel) {
        _user = args;
      } else if (args is Map<String, dynamic>) {
        _user = args['user'] as UserModel?;
        _agent = args['agent'] as AgentModel?;
      }

      final fbUser = FirebaseAuth.instance.currentUser;
      if (_user == null && fbUser != null) {
        _user = UserModel(
          uid: fbUser.uid,
          email: fbUser.email ?? '',
          name: fbUser.displayName ??
              (fbUser.email?.split('@').first ?? 'Santri Peneliti'),
          photoUrl: fbUser.photoURL ?? '',
          plan: 'trial',
          questionsUsed: 0,
        );
      }

      _agent ??= AgentModel.defaultAgents.firstWhere(
        (a) => a.id == 'fiqh_tahawwulat',
        orElse: () => AgentModel.defaultAgents.first,
      );
      if (_agent != null && _agent!.isComingSoon && _activeAgents.isNotEmpty) {
        _agent = _activeAgents.first;
      }
    }
  }

  Future<String?> _getOrPromptPhone() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final phoneKey = 'openturath_${uid}_user_phone';
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(phoneKey) ?? '';
      if (saved.isNotEmpty && saved.length >= 8) {
        return saved;
      }
    } catch (_) {}

    if (!mounted) return null;
    final textController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = OTColors.surface(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    String? phone;
    try {
      phone = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(
            borderRadius: OTRadius.dialogBorder,
            side: BorderSide(color: border, width: 0.8),
          ),
          title: Text(
            'Nomor WhatsApp Konfirmasi',
            style: OTTypography.cardTitle(color: textPrimary).copyWith(fontSize: 17),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Masukkan nomor WhatsApp aktif untuk pengiriman bukti aktivasi langganan dan rincian transaksi riset Anda.',
                style: OTTypography.body(color: textSecondary).copyWith(fontSize: 13),
              ),
              const SizedBox(height: OTSpacing.base),
              TextField(
                controller: textController,
                keyboardType: TextInputType.phone,
                autofocus: true,
                style: OTTypography.body(color: textPrimary),
                decoration: InputDecoration(
                  hintText: 'Contoh: 081234567890',
                  hintStyle: OTTypography.body(color: textSecondary),
                  prefixIcon: const Icon(Icons.phone_iphone_rounded, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: OTRadius.inputBorder,
                    borderSide: BorderSide(color: border),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                OTMotion.light();
                Navigator.pop(ctx, null);
              },
              child: Text('Batal', style: OTTypography.button(color: textSecondary)),
            ),
            FilledButton(
              onPressed: () {
                final val = textController.text.trim();
                if (val.length < 8) {
                  AppSnackBar.warning(ctx, 'Masukkan nomor telepon yang valid.');
                  return;
                }
                OTMotion.success();
                Navigator.pop(ctx, val);
              },
              style: FilledButton.styleFrom(
                backgroundColor: textPrimary,
                foregroundColor: isDark ? const Color(0xFF18181B) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: OTRadius.buttonBorder),
              ),
              child: Text('Lanjutkan Pembayaran', style: OTTypography.button()),
            ),
          ],
        ),
      );
    } finally {
      textController.dispose();
    }

    if (phone != null && phone.isNotEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(phoneKey, phone);
      } catch (_) {}
    }
    return phone;
  }

  Future<void> _handleSubscribe({
    required String plan,
    required String planTitle,
    required int price,
    AgentModel? targetAgent,
  }) async {
    final fbUser = FirebaseAuth.instance.currentUser;
    if (_user == null && fbUser != null) {
      _user = UserModel(
        uid: fbUser.uid,
        email: fbUser.email ?? '',
        name: fbUser.displayName ?? 'Santri Peneliti',
        photoUrl: fbUser.photoURL ?? '',
        plan: 'trial',
        questionsUsed: 0,
      );
    }

    if (_user == null) {
      AppSnackBar.warning(
        context,
        'Silakan masuk akun terlebih dahulu untuk berlangganan.',
      );
      return;
    }

    final phone = await _getOrPromptPhone();
    if (phone == null || phone.isEmpty) return;

    final currentAgent = targetAgent ?? _agent;

    setState(() {
      _isProcessing = true;
    });

    String? dokuUrl;
    String invoiceNumber = '';
    String trxId = '';

    try {
      final userName = _user!.name.trim().isNotEmpty
          ? _user!.name.trim()
          : (_user!.email.isNotEmpty ? _user!.email.split('@').first : 'Santri Peneliti');

      final result = await _subService
          .createPayment(
            uid: _user!.uid,
            agentId: currentAgent?.id ?? 'all_ai',
            plan: plan,
            planTitle: planTitle,
            amount: price,
            name: userName,
            email: _user!.email,
            phone: phone,
          )
          .timeout(const Duration(seconds: 20));

      final redirectUrl = result['redirectUrl'] as String?;
      invoiceNumber = (result['invoiceNumber'] as String?) ?? '';
      trxId = (result['trxId'] as String?) ?? '';
      if (redirectUrl != null && redirectUrl.isNotEmpty) {
        dokuUrl = redirectUrl;
      } else {
        throw Exception('DOKU PG tidak mengembalikan URL pembayaran valid');
      }
    } catch (err) {
      if (!mounted) return;
      AppSnackBar.error(
        context,
        'Terjadi kendala saat menyiapkan sesi pembayaran. Periksa koneksi internet Anda lalu coba kembali.',
      );
      if (mounted) setState(() => _isProcessing = false);
      return;
    }

    try {
      if (!mounted) return;
      final isPaid = await DokuCheckoutSheet.show(
        context,
        paymentUrl: dokuUrl,
        invoiceNumber: invoiceNumber,
        trxId: trxId,
        planTitle: planTitle,
        amount: price,
      );

      if (isPaid == true) {
        if (!mounted) return;
        AppSnackBar.success(
          context,
          'Alhamdulillah! Pembayaran berhasil. Akses ruang riset Anda telah aktif!',
          duration: const Duration(seconds: 4),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.error(
        context,
        'Tidak dapat membuka sesi pembayaran saat ini. Silakan coba kembali.',
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvas = OTColors.canvas(isDark);
    final surface = OTColors.surface(isDark);
    final surfaceSubtle = OTColors.surfaceSubtle(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final accent = OTColors.accent(isDark);

    final activeList = _activeAgents;

    // Pricing tiers for Akses Penuh
    const fullAccessTiers = [
      {'name': 'Bulanan', 'price': 99000, 'label': 'Rp 99.000', 'period': '/ bulan', 'planId': 'all_ai_1m'},
      {'name': '6 Bulan', 'price': 499000, 'label': 'Rp 499.000', 'period': '/ 6 bulan', 'planId': 'all_ai_6m'},
      {'name': '1 Tahun · Hemat 33%', 'price': 799000, 'label': 'Rp 799.000', 'period': '/ tahun', 'planId': 'all_ai_1y'},
    ];

    final currentTier = fullAccessTiers[_selectedDurationIndex];
    final tierPrice = currentTier['price'] as int;
    final tierLabel = currentTier['label'] as String;
    final tierPeriod = currentTier['period'] as String;
    final tierPlanId = currentTier['planId'] as String;

    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        backgroundColor: canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Langganan',
          style: OTTypography.corpusTitle(color: textPrimary).copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: AbsorbPointer(
        absorbing: _isProcessing,
        child: Column(
          children: [
            if (_isProcessing)
              LinearProgressIndicator(
                minHeight: 2.5,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(accent),
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(OTSpacing.lg, OTSpacing.sm, OTSpacing.lg, 108),
                children: [
                  // Editorial Header
                  Text(
                    'Pilih akses',
                    style: OTTypography.editorialHero(color: textPrimary).copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Akses ruang riset turats Islam dengan analisis naskah primer.',
                    style: OTTypography.body(color: textSecondary).copyWith(fontSize: 13),
                  ),

                  const SizedBox(height: OTSpacing.sm),

                  // Satu pintu masuk redeem kode akses
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppleInteractiveWrapper(
                      onTap: () => RedeemCodeSheet.show(context, onSuccess: () {
                        if (mounted) setState(() {});
                      }),
                      pressedScale: 0.96,
                      hapticType: HapticFeedbackType.selection,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.confirmation_number_outlined, size: 16, color: accent),
                            const SizedBox(width: 6),
                            Text(
                              'Punya voucher atau kode redeem santri? Klaim di sini',
                              style: OTTypography.button(color: accent).copyWith(fontSize: 13.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: OTSpacing.sm),

                  // ── Hero Package Card: Akses Penuh Semua AI ──
                  Container(
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: OTRadius.cardBorder,
                      border: Border.all(
                        color: textPrimary,
                        width: 1.2,
                      ),
                    ),
                    padding: const EdgeInsets.all(OTSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'AKSES PENUH',
                              style: OTTypography.sectionHeading(color: accent),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: surfaceSubtle,
                                borderRadius: OTRadius.chipBorder,
                              ),
                              child: Text(
                                'SEMUA 11+ MODUL',
                                style: OTTypography.captionMedium(color: textSecondary).copyWith(fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: OTSpacing.sm),
                        Text(
                          'Paket Seluruh AI Keilmuan',
                          style: OTTypography.corpusTitle(color: textPrimary).copyWith(fontSize: 21),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Fikih 4 mazhab, Tahawwulat, hadits, tafsir, aqidah, ushul, dan sastra bahasa.',
                          style: OTTypography.body(color: textSecondary).copyWith(fontSize: 13),
                        ),

                        const SizedBox(height: OTSpacing.lg),

                        // Segmented Control Durasi
                        Container(
                          height: 38,
                          decoration: BoxDecoration(
                            color: surfaceSubtle,
                            borderRadius: OTRadius.chipBorder,
                            border: Border.all(color: border, width: 0.8),
                          ),
                          child: Row(
                            children: List.generate(fullAccessTiers.length, (idx) {
                              final tier = fullAccessTiers[idx];
                              final isSelected = _selectedDurationIndex == idx;
                              return Expanded(
                                child: AppleInteractiveWrapper(
                                  onTap: () {
                                    OTMotion.selection();
                                    setState(() => _selectedDurationIndex = idx);
                                  },
                                  pressedScale: 0.94,
                                  hapticType: HapticFeedbackType.selection,
                                  child: AnimatedContainer(
                                    duration: OTMotion.fast,
                                    curve: OTMotion.curve,
                                    decoration: BoxDecoration(
                                      color: isSelected ? textPrimary : Colors.transparent,
                                      borderRadius: OTRadius.chipBorder,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      tier['name'] as String,
                                      style: OTTypography.caption(
                                        color: isSelected ? canvas : textSecondary,
                                      ).copyWith(
                                        fontSize: 11,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),

                        const SizedBox(height: OTSpacing.lg),

                        // Price Display
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              tierLabel,
                              style: OTTypography.price(color: textPrimary),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              tierPeriod,
                              style: OTTypography.caption(color: textSecondary),
                            ),
                          ],
                        ),

                        const SizedBox(height: OTSpacing.base),
                        Divider(color: border.withValues(alpha: 0.6), height: 1),
                        const SizedBox(height: OTSpacing.base),

                        // Core Benefits
                        _benefitRow('Akses ke seluruh kajian dan kitab', textPrimary),
                        const SizedBox(height: OTSpacing.sm),
                        _benefitRow('Penelusuran mendalam tanpa batas kuota pertanyaan harian', textPrimary),
                        const SizedBox(height: OTSpacing.sm),
                        _benefitRow('Sitasi marja\' kitab asli, nomor halaman & matan lengkap', textPrimary),
                        const SizedBox(height: OTSpacing.sm),
                        _benefitRow('Prioritas pembaruan naskah dan kurasi kitab primer', textPrimary),

                        const SizedBox(height: OTSpacing.lg),

                        // CTA Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: AppleInteractiveWrapper(
                            onTap: _isProcessing
                                ? null
                                : () {
                                    final allAiAgent = AgentModel(
                                      id: 'all_ai',
                                      title: 'Semua Ruang Riset',
                                      description: 'Akses ke seluruh modul AI OpenTurath',
                                      emoji: '✨',
                                      category: 'All Access',
                                      status: 'active',
                                      sortOrder: 0,
                                    );
                                    _handleSubscribe(
                                      plan: tierPlanId,
                                      planTitle: 'Paket Akses Penuh (${currentTier['name']})',
                                      price: tierPrice,
                                      targetAgent: allAiAgent,
                                    );
                                  },
                            pressedScale: 0.97,
                            hapticType: HapticFeedbackType.light,
                            borderRadius: BorderRadius.circular(OTRadius.button),
                            child: FilledButton(
                              onPressed: _isProcessing
                                  ? null
                                  : () {
                                      final allAiAgent = AgentModel(
                                        id: 'all_ai',
                                        title: 'Semua Ruang Riset',
                                        description: 'Akses ke seluruh modul AI OpenTurath',
                                        emoji: '✨',
                                        category: 'All Access',
                                        status: 'active',
                                        sortOrder: 0,
                                      );
                                      _handleSubscribe(
                                        plan: tierPlanId,
                                        planTitle: 'Paket Akses Penuh (${currentTier['name']})',
                                        price: tierPrice,
                                        targetAgent: allAiAgent,
                                      );
                                    },
                              style: FilledButton.styleFrom(
                                backgroundColor: textPrimary,
                                foregroundColor: canvas,
                                shape: RoundedRectangleBorder(borderRadius: OTRadius.buttonBorder),
                                elevation: 0,
                              ),
                              child: Text(
                                'Pilih Paket Ini ($tierLabel)',
                                style: OTTypography.button(color: canvas),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: OTSpacing.xl),

                  // ── Add-On / Modul Satuan Terpisah ──
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 6),
                    child: Text(
                      'PILIHAN MODUL SATUAN',
                      style: OTTypography.sectionHeading(color: textSecondary),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: OTRadius.cardBorder,
                      border: Border.all(color: border, width: 0.8),
                    ),
                    padding: const EdgeInsets.all(OTSpacing.base),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '1 Modul Spesialis Terpilih',
                                    style: OTTypography.cardTitle(color: textPrimary),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Fokus telaah pada satu disiplin keilmuan tertentu',
                                    style: OTTypography.caption(color: textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'Rp50.000 / bulan',
                              style: OTTypography.bodyMedium(color: textPrimary).copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: OTSpacing.md),

                        DropdownButtonFormField<String>(
                          initialValue: _agent?.id ?? 'fiqh_tahawwulat',
                          isExpanded: true,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            filled: true,
                            fillColor: surfaceSubtle,
                            border: OutlineInputBorder(
                              borderRadius: OTRadius.inputBorder,
                              borderSide: BorderSide(color: border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: OTRadius.inputBorder,
                              borderSide: BorderSide(color: border),
                            ),
                          ),
                          dropdownColor: surface,
                          items: activeList.map((a) {
                            return DropdownMenuItem<String>(
                              value: a.id,
                              child: Text(
                                a.title,
                                style: OTTypography.bodyMedium(color: textPrimary).copyWith(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _agent = activeList.firstWhere((a) => a.id == val);
                              });
                            }
                          },
                        ),

                        const SizedBox(height: OTSpacing.md),

                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: AppleInteractiveWrapper(
                            onTap: _isProcessing
                                ? null
                                : () => _handleSubscribe(
                                      plan: AppConstants.planTholib1m,
                                      planTitle: '1 Bulan ${_agent?.title ?? "Modul AI"}',
                                      price: _agent?.price1m ?? AppConstants.priceTholib1m,
                                    ),
                            pressedScale: 0.97,
                            hapticType: HapticFeedbackType.light,
                            borderRadius: BorderRadius.circular(OTRadius.button),
                            child: OutlinedButton(
                              onPressed: _isProcessing
                                  ? null
                                  : () => _handleSubscribe(
                                        plan: AppConstants.planTholib1m,
                                        planTitle: '1 Bulan ${_agent?.title ?? "Modul AI"}',
                                        price: _agent?.price1m ?? AppConstants.priceTholib1m,
                                      ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: textPrimary,
                                side: BorderSide(color: border, width: 0.8),
                                shape: RoundedRectangleBorder(borderRadius: OTRadius.buttonBorder),
                              ),
                              child: Builder(
                                builder: (context) {
                                  final p = _agent?.price1m ?? AppConstants.priceTholib1m;
                                  final formatted = 'Rp ${p.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
                                  return Text(
                                    'Langganan Modul ($formatted)',
                                    style: OTTypography.button(),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _benefitRow(String text, Color textPrimary) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(
            Icons.check_circle_rounded,
            size: 15,
            color: OTColors.success,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: OTTypography.body(color: textPrimary).copyWith(
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

```

### FLUTTER FILE: openturath_ai/lib/services/agent_service.dart
```dart
import 'package:cloud_functions/cloud_functions.dart';
import '../models/agent_model.dart';
import '../core/constants.dart';

class AgentService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // ── Ambil daftar semua agent dari Firestore / model lokal ────
  Future<List<AgentModel>> getAgents() async {
    return AgentModel.defaultAgents;
  }

  // ── Ambil URL agent dari Cloud Function secara aman (Server-Side Entitlement) ────
  Future<String?> getAgentUrl(String agentId) async {
    try {
      final callable = _functions.httpsCallable(AppConstants.fnGetAgentUrl);
      final result = await callable.call({'agentId': agentId});
      final data = Map<String, dynamic>.from(result.data);
      final url = data['url'] as String?;
      if (url != null && url.isNotEmpty) {
        return url;
      }
      throw const AgentAccessException('empty-url', 'URL ruang riset belum tersedia untuk modul ini.');
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'permission-denied') {
        throw AgentAccessException(
          'permission-denied',
          e.message ?? 'Langganan aktif diperlukan untuk mengakses modul riset ini.',
        );
      }
      throw AgentAccessException(e.code, e.message ?? 'Gagal menghubungi server riset.');
    } catch (e) {
      if (e is AgentAccessException) rethrow;
      throw AgentAccessException('unknown-error', e.toString());
    }
  }

  // ── Catat pertanyaan trial secara atomik di Cloud Functions ───
  Future<TrialUsage> recordQuestion(String agentId) async {
    try {
      final callable = _functions.httpsCallable('recordQuestion');
      final result = await callable.call({'agentId': agentId});
      final data = Map<String, dynamic>.from(result.data);
      return TrialUsage(
        isPremium: data['isPremium'] == true,
        questionsUsed: (data['questionsUsed'] as num?)?.toInt() ?? 0,
        questionsRemaining: (data['questionsRemaining'] as num?)?.toInt(),
      );
    } on FirebaseFunctionsException catch (e) {
      throw AgentAccessException(e.code, e.message ?? 'Gagal mencatat kuota pertanyaan.');
    } catch (e) {
      if (e is AgentAccessException) rethrow;
      throw AgentAccessException('record-error', e.toString());
    }
  }
}

class TrialUsage {
  const TrialUsage({
    required this.isPremium,
    required this.questionsUsed,
    required this.questionsRemaining,
  });

  final bool isPremium;
  final int questionsUsed;
  final int? questionsRemaining;
}

class AgentAccessException implements Exception {
  const AgentAccessException(this.code, this.message);
  final String code;
  final String message;

  @override
  String toString() => 'AgentAccessException($code): $message';
}

```

### FLUTTER FILE: openturath_ai/lib/services/auth_service.dart
```dart
import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../core/constants.dart';
import 'session_user_stream.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '255541559800-jcip3mf8umtscgf5jm8khflm4u83rmcj.apps.googleusercontent.com',
  );
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Cached persistent userStream to prevent memory leak and listener churn (F10)
  Stream<UserModel?>? _cachedUserStream;

  // In-memory cache to prevent entitlement loss on network hiccup (F41)
  static final Map<String, UserModel> _userCache = {};

  // ── Cache Helpers ──────────────────────────────────────────────
  static Future<void> _cacheUserLocally(UserModel user) async {
    _userCache[user.uid] = user;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'openturath_cached_user_${user.uid}',
        jsonEncode(user.toJsonMap()),
      );
    } catch (_) {}
  }

  static Future<UserModel?> _getCachedUser(String uid) async {
    if (_userCache.containsKey(uid)) {
      return _userCache[uid];
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('openturath_cached_user_$uid');
      if (raw != null && raw.isNotEmpty) {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        final user = UserModel.fromMap(uid, map);
        _userCache[uid] = user;
        return user;
      }
    } catch (_) {}
    return null;
  }

  // ── Current Firebase User ──────────────────────────────────────
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Google Sign In ─────────────────────────────────────────────
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User membatalkan login

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) return null;

      // ── Cek apakah user sudah ada di Firestore ──
      try {
        final docRef =
            _db.collection(AppConstants.colUsers).doc(firebaseUser.uid);
        final doc = await docRef.get().timeout(const Duration(seconds: 4));

        if (!doc.exists) {
          // ── User baru: buat dokumen dengan plan trial ──
          final newUser = UserModel(
            uid: firebaseUser.uid,
            name: firebaseUser.displayName ?? 'Pengguna',
            email: firebaseUser.email ?? '',
            photoUrl: firebaseUser.photoURL ?? '',
            plan: AppConstants.planTrial,
            questionsUsed: 0,
          );
          await docRef.set({
            'name': newUser.name,
            'email': newUser.email,
            'photo_url': newUser.photoUrl,
            'plan': newUser.plan,
            'questions_used': newUser.questionsUsed,
            'subscription_expiry': null,
          }).timeout(const Duration(seconds: 4));
          await _cacheUserLocally(newUser);
          return newUser;
        } else {
          final userModel = UserModel.fromFirestore(doc);
          await _cacheUserLocally(userModel);
          return userModel;
        }
      } catch (_) {
        // Fallback user jika Firestore lambat / offline: cek cache terlebih dahulu (F41)
        final cached = await _getCachedUser(firebaseUser.uid);
        if (cached != null) return cached;

        final fallback = UserModel(
          uid: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'Pengguna',
          email: firebaseUser.email ?? '',
          photoUrl: firebaseUser.photoURL ?? '',
          plan: AppConstants.planTrial,
          questionsUsed: 0,
        );
        return fallback;
      }
    } catch (e) {
      rethrow;
    }
  }

  // ── Anonymous / Guest Sign-In ──────────────────────────────────
  Future<UserModel?> signInAnonymously() async {
    try {
      final cred = await _auth.signInAnonymously();
      final firebaseUser = cred.user;
      if (firebaseUser == null) return _localGuestUser();

      try {
        final docRef =
            _db.collection(AppConstants.colUsers).doc(firebaseUser.uid);
        final doc = await docRef.get().timeout(const Duration(seconds: 4));

        if (!doc.exists) {
          final newUser = UserModel(
            uid: firebaseUser.uid,
            name: 'Peneliti Tamu',
            email: '',
            photoUrl: '',
            plan: AppConstants.planTrial,
            questionsUsed: 0,
          );
          await docRef.set({
            'name': newUser.name,
            'email': '',
            'photo_url': newUser.photoUrl,
            'plan': newUser.plan,
            'questions_used': newUser.questionsUsed,
            'subscription_expiry': null,
          }).timeout(const Duration(seconds: 4));
          await _cacheUserLocally(newUser);
          return newUser;
        } else {
          final userModel = UserModel.fromFirestore(doc);
          await _cacheUserLocally(userModel);
          return userModel;
        }
      } catch (_) {
        return _localGuestUser();
      }
    } catch (_) {
      return _localGuestUser();
    }
  }

  static String? _cachedGuestUid;

  UserModel _localGuestUser() {
    _cachedGuestUid ??= 'guest_${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}';
    return UserModel(
      uid: _cachedGuestUid!,
      name: 'Peneliti Tamu',
      email: 'tamu@openturath.ai',
      photoUrl: '',
      plan: AppConstants.planTrial,
      questionsUsed: 0,
    );
  }

  // ── Get Current UserModel from Firestore ───────────────────────
  Future<UserModel?> getCurrentUserModel() async {
    final user = currentUser;
    if (user == null) return null;
    try {
      final doc = await _db
          .collection(AppConstants.colUsers)
          .doc(user.uid)
          .get()
          .timeout(const Duration(seconds: 4));
      if (!doc.exists) {
        final fallback = UserModel(
          uid: user.uid,
          name: user.displayName ?? 'Pengguna',
          email: user.email ?? '',
          photoUrl: user.photoURL ?? '',
          plan: AppConstants.planTrial,
          questionsUsed: 0,
        );
        return fallback;
      }
      final userModel = UserModel.fromFirestore(doc);
      await _cacheUserLocally(userModel);
      return userModel;
    } catch (_) {
      // Pertahankan snapshot terakhir jika ada (F41)
      final cached = await _getCachedUser(user.uid);
      if (cached != null) return cached;

      return UserModel(
        uid: user.uid,
        name: user.displayName ?? 'Pengguna',
        email: user.email ?? '',
        photoUrl: user.photoURL ?? '',
        plan: AppConstants.planTrial,
        questionsUsed: 0,
      );
    }
  }

  // ── Stream user changes (real-time with single persistent cached stream, F10 & F41) ──
  Stream<UserModel?> get userStream => _cachedUserStream ??= _buildUserStream();

  Stream<UserModel?> _buildUserStream() => sessionUserStream<UserModel>(
    auth: _auth.authStateChanges().map((user) => user?.uid),
    cached: _getCachedUser,
    watch: (uid) => _db.collection(AppConstants.colUsers).doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      final user = UserModel.fromFirestore(doc);
      if (_auth.currentUser?.uid == uid) { unawaited(_cacheUserLocally(user)); }
      return user;
    }),
  );

  // ── Sign Out ───────────────────────────────────────────────────
  Future<void> signOut() async {
    final currentUid = _auth.currentUser?.uid;

    try {
      final cookieManager = CookieManager.instance();
      await cookieManager.deleteAllCookies();
      await cookieManager.removeSessionCookies();
      await InAppWebViewController.clearAllCache();
      await WebStorageManager.instance().deleteAllData();
    } catch (_) {}

    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('google_session_ready');
      await prefs.remove('last_opened_notebook_id');
      if (currentUid != null) {
        _userCache.remove(currentUid);
        await prefs.remove('openturath_cached_user_$currentUid');
      }
    } catch (_) {}

    // Propagate Auth signOut to avoid half-signed-out UI state (F41)
    await _auth.signOut();
  }

  // ── Increment Question Count ───────────────────────────────────
  Future<void> incrementQuestionCount() async {
    final user = currentUser;
    if (user == null) return;
    try {
      await _db.collection(AppConstants.colUsers).doc(user.uid).update({
        'questions_used': FieldValue.increment(1),
      });
    } catch (_) {}
  }

  // ── Delete Account & User Data (Google Play Compliance & Orphan Cleanup, P0) ──
  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user == null) return;
    final uid = user.uid;

    // Auth deletion enforces recent login. The server trigger owns revocation and recursive cleanup.
    await user.delete();
    try {
      await CookieManager.instance().deleteAllCookies();
      await InAppWebViewController.clearAllCache();
      await WebStorageManager.instance().deleteAllData();
    } catch (_) {}

    // 4. Bersihkan ONLY preferensi spesifik user UID ini (F08 & F41: dilarang prefs.clear())
    try {
      _userCache.remove(uid);
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith('openturath_${uid}_') ||
            key == 'openturath_cached_user_$uid' ||
            key == 'google_session_ready' ||
            key == 'last_opened_notebook_id') {
          await prefs.remove(key);
        }
      }
    } catch (_) {}

    // 5. Putuskan hubungan Google Sign In
    try {
      await _googleSignIn.disconnect();
    } catch (_) {
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
    }

    // 6. Pastikan sign-out bersih
    try {
      await _auth.signOut();
    } catch (_) {}
  }
}

```

### FLUTTER FILE: openturath_ai/lib/services/bookmark_service.dart
```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/bookmark_model.dart';
import 'scoped_json_store.dart';

class BookmarkService extends ChangeNotifier {
  static final BookmarkService _instance = BookmarkService._internal();
  factory BookmarkService() => _instance;
  BookmarkService._internal();

  final _store = ScopedJsonListStore<BookmarkModel>(
    storage: PreferencesStringStore(), decode: BookmarkModel.fromJson,
    encode: (bookmark) => bookmark.toJson(),
  );

  String _key(String? userId) {
    final uid = userId ?? FirebaseAuth.instance.currentUser?.uid;
    return uid == null || uid.isEmpty ? 'openturath_saved_bookmarks' : 'openturath_${uid}_saved_bookmarks';
  }

  Future<List<BookmarkModel>> getBookmarks({String? userId}) => _store.read(_key(userId));

  Future<void> saveAll(List<BookmarkModel> bookmarks, {String? userId}) async {
    final key = _key(userId);
    await _store.replace(key, bookmarks);
    notifyListeners();
  }

  Future<void> addBookmark(BookmarkModel bookmark, {String? userId}) async {
    final key = _key(userId);
    await _store.update(key, (items) {
      items.removeWhere((item) => item.id == bookmark.id);
      items.insert(0, bookmark);
      return items;
    });
    notifyListeners();
  }

  Future<void> deleteBookmark(String id, {String? userId}) async {
    final key = _key(userId);
    await _store.update(key, (items) => items..removeWhere((item) => item.id == id));
    notifyListeners();
  }

  Future<bool> isBookmarked(String id, {String? userId}) async =>
    (await getBookmarks(userId: userId)).any((item) => item.id == id);
}

```

### FLUTTER FILE: openturath_ai/lib/services/canonical_library_service.dart
```dart
import 'package:flutter/services.dart';
import '../core/arabic_utils.dart';
import '../models/book_model.dart';

/// Service to load, cache, and search canonical book catalogs with diacritic-tolerant Arabic search.
class CanonicalLibraryService {
  CanonicalLibraryService._();
  static final CanonicalLibraryService instance = CanonicalLibraryService._();

  CanonicalImport? _syafiiCatalog;
  List<CanonicalBookPresentation>? _syafiiPresentations;

  /// Normalizes Arabic text by stripping diacritics and unifying letter variants.
  static String normalizeArabic(String text) => ArabicUtils.normalize(text);

  /// Loads the canonical Syafi'i catalog from asset bundle.
  Future<List<CanonicalBookPresentation>> loadSyafiiCatalog() async {
    if (_syafiiPresentations != null) {
      return _syafiiPresentations!;
    }

    try {
      final jsonStr = await rootBundle.loadString('assets/data/canonical_syafii.json');
      final catalog = parseCanonicalCatalog(jsonStr);
      _syafiiCatalog = catalog;
      _syafiiPresentations = catalog.entries
          .map((e) => CanonicalBookPresentation.fromEntry(e))
          .toList();
      return _syafiiPresentations!;
    } catch (e) {
      // Re-throw so UI can display specific failure state
      rethrow;
    }
  }

  /// Get cached presentations or null if not yet loaded.
  List<CanonicalBookPresentation>? get cachedSyafiiBooks => _syafiiPresentations;

  /// Get parsed canonical import or null if not yet loaded.
  CanonicalImport? get rawSyafiiCatalog => _syafiiCatalog;

  /// Filter books by query string with diacritic-tolerant Arabic & Latin normalization.
  List<CanonicalBookPresentation> filterBooks(
    List<CanonicalBookPresentation> books,
    String query, {
    String? eraFilter,
    String? typeFilter,
  }) {
    final cleanQuery = query.trim();

    return books.where((book) {
      if (eraFilter != null && eraFilter.isNotEmpty && book.reviewedEraLabel != eraFilter) {
        return false;
      }
      if (typeFilter != null && typeFilter.isNotEmpty && book.reviewedTypeLabel != typeFilter) {
        return false;
      }

      if (cleanQuery.isEmpty) return true;

      final matchTitle = ArabicUtils.matches(book.titleArabic, cleanQuery) ||
          (book.titleLatin != null && ArabicUtils.matches(book.titleLatin!, cleanQuery));
      final matchAuthor = ArabicUtils.matches(book.authorArabic, cleanQuery) ||
          (book.authorLatin != null && ArabicUtils.matches(book.authorLatin!, cleanQuery));
      final matchPublisher = book.publisher != null && ArabicUtils.matches(book.publisher!, cleanQuery);
      final matchMuhaqqiq = book.muhaqqiq != null && ArabicUtils.matches(book.muhaqqiq!, cleanQuery);

      return matchTitle || matchAuthor || matchPublisher || matchMuhaqqiq;
    }).toList();
  }
}

```

### FLUTTER FILE: openturath_ai/lib/services/doku_service.dart
```dart
import 'package:cloud_functions/cloud_functions.dart';
import '../core/constants.dart';

/// DokuService — Layanan checkout DOKU yang aman & terpusat.
/// Seluruh kalkulasi signature HMAC dan interaksi ke API DOKU
/// dieksekusi secara eksklusif oleh Cloud Functions (server-side),
/// sehingga tidak ada Secret Key yang tersimpan di dalam client/APK.
class DokuService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Buat sesi pembayaran checkout resmi melalui Cloud Function createCheckout
  Future<Map<String, dynamic>> createCheckoutSession({
    required String uid,
    required String agentId,
    required String plan,
    required String planTitle,
    required int amount,
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      final callable = _functions.httpsCallable(AppConstants.fnCreatePayment);
      final result = await callable.call({
        'uid': uid,
        'agentId': agentId,
        'plan': plan,
        'planTitle': planTitle,
        'amount': amount,
        'name': name,
        'email': email,
        'phone': phone,
      });

      final data = Map<String, dynamic>.from(result.data as Map);
      return {
        'redirectUrl': data['paymentUrl'] ?? data['redirectUrl'],
        'paymentUrl': data['paymentUrl'] ?? data['redirectUrl'],
        'trxId': data['trxId'] ?? '',
        'invoiceNumber': data['invoiceNumber'] ?? '',
        'status': 'pending',
      };
    } catch (e) {
      throw Exception('Gagal membuat sesi pembayaran DOKU: $e');
    }
  }

  /// Periksa status pembayaran secara aktif langsung ke Cloud Functions
  /// yang memverifikasi transaksi langsung ke DOKU Orders API.
  Future<Map<String, dynamic>> checkPaymentStatus({
    required String invoiceNumber,
  }) async {
    try {
      final callable = _functions.httpsCallable(AppConstants.fnCheckPaymentStatus);
      final result = await callable.call({'invoiceNumber': invoiceNumber});
      return Map<String, dynamic>.from(result.data as Map);
    } catch (e) {
      return {
        'success': false,
        'status': 'ERROR',
        'error': e.toString(),
      };
    }
  }
}

```

### FLUTTER FILE: openturath_ai/lib/services/native_agent_launcher.dart
```dart
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// NativeAgentLauncher: Menangani pembukaan ruang riset langsung ke aplikasi resmi
/// Google Gemini Notebook (com.google.android.apps.labs.language.tailwind) secara instan (0.1 detik)
/// tanpa overhead browser atau webview jika aplikasi terinstal.
class NativeAgentLauncher {
  static const MethodChannel _channel = MethodChannel('com.openturath.ai/native_launcher');

  /// Cek apakah aplikasi resmi Google Gemini Notebook terpasang di perangkat
  static Future<bool> isNotebookAppInstalled() async {
    if (!Platform.isAndroid) return false;
    try {
      final bool? installed = await _channel.invokeMethod<bool>('isNotebookAppInstalled');
      return installed == true;
    } catch (_) {
      return false;
    }
  }

  /// Buka URL notebook langsung di aplikasi resmi native Gemini Notebook
  /// Mengembalikan `true` jika berhasil diluncurkan langsung ke aplikasi native.
  static Future<bool> launchNotebook(String url) async {
    final cleanUrl = url.replaceAll('/preview', '');

    // 1. Prioritaskan peluncuran Intent langsung ke com.google.android.apps.labs.language.tailwind
    if (Platform.isAndroid) {
      try {
        final bool? success = await _channel.invokeMethod<bool>('openInNotebookApp', {
          'url': cleanUrl,
        });
        if (success == true) {
          return true;
        }
      } catch (_) {}
    }

    // 2. Coba peluncuran non-browser via url_launcher
    try {
      final uri = Uri.parse(cleanUrl);
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalNonBrowserApplication,
      );
      if (launched) return true;
    } catch (_) {}

    return false;
  }

  /// Membuka Share Sheet native Android untuk membagikan modul AI
  static Future<bool> shareText({required String text, String title = 'Bagikan Modul'}) async {
    if (!Platform.isAndroid) return false;
    try {
      final bool? success = await _channel.invokeMethod<bool>('shareText', {
        'text': text,
        'title': title,
      });
      return success == true;
    } catch (_) {
      return false;
    }
  }
}

```

### FLUTTER FILE: openturath_ai/lib/services/research_notes_service.dart
```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'scoped_json_store.dart';

/// Model Catatan Riset / Bookmark Hasil Pencarian Kitab
class ResearchNote {
  final String id;
  final String agentId;
  final String agentTitle;
  final String title;
  final String excerpt;
  final String? bookTitle;
  final String? bookVolume;
  final String? bookPage;
  final List<String> tags;
  final DateTime createdAt;

  ResearchNote({
    required this.id,
    required this.agentId,
    required this.agentTitle,
    required this.title,
    required this.excerpt,
    this.bookTitle,
    this.bookVolume,
    this.bookPage,
    this.tags = const [],
    required this.createdAt,
  });

  String get citationFormatted {
    final buffer = StringBuffer();
    buffer.writeln('"$excerpt"');
    buffer.writeln();
    buffer.write('Sumber: OpenTurath AI ($agentTitle)');
    if (bookTitle != null && bookTitle!.isNotEmpty) {
      buffer.write(', Kitab $bookTitle');
      if (bookVolume != null && bookVolume!.isNotEmpty) buffer.write(' Juz $bookVolume');
      if (bookPage != null && bookPage!.isNotEmpty) buffer.write(' Hal $bookPage');
    }
    return buffer.toString();
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'agent_id': agentId,
        'agent_title': agentTitle,
        'title': title,
        'excerpt': excerpt,
        'book_title': bookTitle,
        'book_volume': bookVolume,
        'book_page': bookPage,
        'tags': tags,
        'created_at': createdAt.toIso8601String(),
      };

  factory ResearchNote.fromMap(Map<String, dynamic> map) => ResearchNote(
        id: map['id'] ?? '',
        agentId: map['agent_id'] ?? '',
        agentTitle: map['agent_title'] ?? '',
        title: map['title'] ?? '',
        excerpt: map['excerpt'] ?? '',
        bookTitle: map['book_title'],
        bookVolume: map['book_volume'],
        bookPage: map['book_page'],
        tags: List<String>.from(map['tags'] ?? []),
        createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      );
}

/// Service Penyimpanan Catatan & Bookmark Riset Lokal (Offline-first)
class ResearchNotesService {
  final _store = ScopedJsonListStore<ResearchNote>(
    storage: PreferencesStringStore(), decode: ResearchNote.fromMap,
    encode: (note) => note.toMap(),
  );
  String _key(String? userId) {
    final uid = userId ?? FirebaseAuth.instance.currentUser?.uid;
    return uid == null || uid.isEmpty ? 'openturath_research_notes_v1' : 'openturath_${uid}_research_notes_v1';
  }
  Future<List<ResearchNote>> getNotes({String? agentId, String? userId}) async {
    final key = _key(userId);
    final notes = await _store.read(key);
    notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return agentId == null || agentId.isEmpty ? notes : notes.where((n) => n.agentId == agentId).toList();
  }
  Future<void> saveNote(ResearchNote note, {String? userId}) {
    final key = _key(userId);
    return _store.update(key, (notes) {
      notes.removeWhere((n) => n.id == note.id);
      notes.insert(0, note);
      return notes;
    });
  }
  Future<void> deleteNote(String noteId, {String? userId}) {
    final key = _key(userId);
    return _store.update(key, (notes) => notes..removeWhere((n) => n.id == noteId));
  }
}

```

### FLUTTER FILE: openturath_ai/lib/services/scoped_json_store.dart
```dart
import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class StringStore {
  Future<String?> read(String key);
  Future<bool> write(String key, String value);
}

class PreferencesStringStore implements StringStore {
  @override
  Future<String?> read(String key) async => (await SharedPreferences.getInstance()).getString(key);
  @override
  Future<bool> write(String key, String value) async => (await SharedPreferences.getInstance()).setString(key, value);
}

class ScopedJsonListStore<T> {
  final StringStore storage;
  final T Function(Map<String, dynamic>) decode;
  final Map<String, dynamic> Function(T) encode;
  static final Map<String, Future<void>> _tails = {};

  ScopedJsonListStore({required this.storage, required this.decode, required this.encode});

  Future<R> _locked<R>(String key, Future<R> Function() action) async {
    final previous = _tails[key];
    final done = Completer<void>();
    _tails[key] = done.future;
    try {
      if (previous != null) await previous;
      return await action();
    } finally {
      done.complete();
      if (identical(_tails[key], done.future)) _tails.remove(key);
    }
  }

  Future<List<T>> _read(String key) async {
    final raw = await storage.read(key);
    if (raw == null || raw.isEmpty) return <T>[];
    try {
      final data = jsonDecode(raw);
      if (data is! List) throw const FormatException('Expected a list');
      return data.map((row) {
        if (row is! Map) throw const FormatException('Expected an object');
        return decode(Map<String, dynamic>.from(row));
      }).toList();
    } on Object {
      final digest = sha256.convert(utf8.encode(raw));
      final quarantine = '${key}_corrupt_$digest';
      if (await storage.read(quarantine) != raw && !await storage.write(quarantine, raw)) {
        throw StateError('Cannot preserve damaged saved data');
      }
      return <T>[];
    }
  }

  Future<List<T>> read(String key) => _locked(key, () => _read(key));

  Future<void> replace(String key, List<T> items) {
    final snapshot = List<T>.of(items);
    return _locked(key, () async {
      await _read(key); // Preserve corrupt old bytes before replacing them.
      await _write(key, snapshot);
    });
  }

  Future<void> update(String key, List<T> Function(List<T>) edit) => _locked(key, () async {
    final current = await _read(key);
    await _write(key, edit(current));
  });

  Future<void> _write(String key, List<T> items) async {
    final raw = jsonEncode(items.map(encode).toList());
    if (!await storage.write(key, raw)) throw StateError('Saved data could not be written');
  }
}

```

### FLUTTER FILE: openturath_ai/lib/services/session_user_stream.dart
```dart
import 'dart:async';

Stream<T?> sessionUserStream<T>({
  required Stream<String?> auth,
  required Future<T?> Function(String) cached,
  required Stream<T?> Function(String) watch,
}) {
  final listeners = <MultiStreamController<T?>>{};
  StreamSubscription<String?>? authSub;
  StreamSubscription<T?>? documentSub;
  var generation = 0;
  var hasValue = false;
  T? last;

  bool current(int token) => token == generation && listeners.isNotEmpty;
  void emit(int token, T? value) {
    if (!current(token)) return;
    hasValue = true;
    last = value;
    for (final listener in listeners.toList()) { listener.add(value); }
  }
  void error(int token, Object value, StackTrace stack) {
    if (!current(token)) return;
    for (final listener in listeners.toList()) { listener.addError(value, stack); }
  }
  Future<void> cancel(StreamSubscription<dynamic>? sub) async {
    try { await sub?.cancel(); } catch (_) { /* Generation already invalidates events. */ }
  }
  Future<void> switchUser(String? uid) async {
    final token = ++generation;
    final previous = documentSub;
    documentSub = null;
    emit(token, null); // Clear prior identity before asynchronous cache lookup.
    await cancel(previous);
    if (!current(token) || uid == null) return;
    try {
      final value = await cached(uid).timeout(const Duration(seconds: 5));
      if (!current(token)) return;
      if (value != null) emit(token, value);
    } catch (_) { /* Continue with the authoritative snapshot stream. */ }
    if (!current(token)) return;
    try {
      documentSub = watch(uid).listen(
        (value) => emit(token, value),
        onError: (Object e, StackTrace stack) => error(token, e, stack),
      );
    } catch (e, stack) { error(token, e, stack); }
  }

  return Stream<T?>.multi((listener) {
    listeners.add(listener);
    if (hasValue) listener.add(last);
    if (listeners.length == 1) {
      authSub = auth.listen((uid) { unawaited(switchUser(uid)); },
        onError: (Object e, StackTrace stack) => error(generation, e, stack));
    }
    listener.onCancel = () async {
      listeners.remove(listener);
      if (listeners.isNotEmpty) return;
      generation++;
      hasValue = false;
      last = null;
      final oldAuth = authSub;
      final oldDocument = documentSub;
      authSub = null;
      documentSub = null;
      await Future.wait([cancel(oldAuth), cancel(oldDocument)]);
    };
  }, isBroadcast: true);
}

```

### FLUTTER FILE: openturath_ai/lib/services/subscription_service.dart
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../core/constants.dart';
import '../models/user_model.dart';
import 'doku_service.dart';

class SubscriptionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final DokuService _dokuService = DokuService();

  /// Normalisasi kode voucher: hapus spasi, ubah huruf kapital, hapus tanda strip
  static String normalizeCode(String input) {
    return input.trim().toUpperCase().replaceAll(RegExp(r'[\s-]'), '');
  }

  static String redeemErrorMessage(String code) {
    switch (code.toLowerCase().replaceAll('_', '-')) {
      case 'not-found': return 'Kode akses tidak ditemukan. Periksa kembali kode yang Anda masukkan.';
      case 'already-exists': return 'Kode ini sudah pernah Anda gunakan.';
      case 'deadline-exceeded': return 'Kode sudah kedaluwarsa atau layanan terlalu lama merespons. Coba lagi, atau gunakan kode lain.';
      case 'failed-precondition': return 'Kode akses ini sudah tidak aktif.';
      case 'resource-exhausted': return 'Batas penggunaan kode atau percobaan telah tercapai. Coba lagi nanti.';
      case 'unauthenticated': return 'Silakan masuk ke akun Anda lalu coba kembali.';
      case 'invalid-argument': return 'Format kode belum sesuai. Periksa kembali kode Anda.';
      case 'permission-denied': return 'Kode ini tidak dapat digunakan untuk akun Anda.';
      case 'unavailable': return 'Layanan belum dapat dihubungi. Periksa koneksi lalu coba lagi.';
      default: return 'Kode belum dapat diaktifkan. Silakan coba lagi sebentar.';
    }
  }

  // ── Klaim Kode Redeem Santri (Voucher Akses 7 Hari, dsb) ─────
  Future<Map<String, dynamic>> redeemAccessCode(String code) async {
    try {
      final normalized = normalizeCode(code);
      final callable = FirebaseFunctions.instance.httpsCallable('redeemCode');
      final result = await callable.call({'code': normalized});
      final data = result.data;
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return {'success': true, 'message': 'Kode akses sudah aktif.'};
    } on FirebaseFunctionsException catch (e) {
      return {'success': false, 'message': redeemErrorMessage(e.code)};
    } catch (e) {
      return {'success': false, 'message': 'Koneksi bermasalah. Periksa internet Anda lalu coba lagi.'};
    }
  }

  // ── Buat Payment Request resmi ke DOKU Payment Gateway ───────
  Future<Map<String, dynamic>> createPayment({
    required String uid,
    required String agentId,
    required String plan,
    required String name,
    required String email,
    required String phone,
    String? planTitle,
    int? amount,
  }) async {
    final resolvedAmount = amount ?? _getPriceForPlan(plan);
    final resolvedTitle = planTitle ?? _getTitleForPlan(plan);

    // Eksekusi checkout DOKU melalui Cloud Functions
    return await _dokuService.createCheckoutSession(
      uid: uid,
      agentId: agentId,
      plan: plan,
      planTitle: resolvedTitle,
      amount: resolvedAmount,
      name: name,
      email: email,
      phone: phone,
    );
  }

  // ── Cek status transaksi secara aktif (inquiry ke DOKU API via Cloud Function) ──
  Future<Map<String, dynamic>> verifyPaymentStatus({
    required String invoiceNumber,
    String? trxId,
  }) async {
    // 1. Panggil checkPaymentStatus Cloud Function yang inquiry langsung ke DOKU
    final res = await _dokuService.checkPaymentStatus(invoiceNumber: invoiceNumber);
    if (res['status'] == 'SUCCESS' || res['success'] == true) {
      return res;
    }

    // 2. Fallback cek Firestore transaction jika ada trxId
    if (trxId != null && trxId.isNotEmpty) {
      final doc = await _db.collection(AppConstants.colTransactions).doc(trxId).get();
      if (doc.exists && doc.data()?['status'] == 'success') {
        return {'success': true, 'status': 'SUCCESS'};
      }
    }

    return res;
  }

  // ── Legacy polling helper ────────────────────────────────────
  Future<String> checkPaymentStatus(String trxId) async {
    final doc =
        await _db.collection(AppConstants.colTransactions).doc(trxId).get();
    if (!doc.exists) return 'pending';
    return (doc.data()?['status'] ?? 'pending') as String;
  }

  // ── Stream status user secara real-time ───────────────────────
  Stream<UserModel?> watchUserSubscription(String uid) {
    return _db
        .collection(AppConstants.colUsers)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  int _getPriceForPlan(String plan) {
    switch (plan) {
      case AppConstants.planTholib1m:
        return AppConstants.priceTholib1m;
      case AppConstants.planTholib6m:
        return AppConstants.priceTholib6m;
      case AppConstants.planBahits1y:
        return AppConstants.priceBahits1y;
      case 'all_ai_1m':
        return AppConstants.priceAllAiPromo1m;
      default:
        return AppConstants.priceTholib1m;
    }
  }

  String _getTitleForPlan(String plan) {
    switch (plan) {
      case AppConstants.planTholib1m:
        return 'Paket Tholib (1 Bulan)';
      case AppConstants.planTholib6m:
        return 'Paket Tholib (6 Bulan)';
      case AppConstants.planBahits1y:
        return 'Paket Bahits (1 Tahun)';
      case 'all_ai_1m':
        return 'Paket Promo Semua AI (1 Bulan)';
      default:
        return 'Langganan OpenTurath AI';
    }
  }
}

```

### FLUTTER FILE: openturath_ai/lib/services/update_service.dart
```dart
import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

enum UpdateStatus {
  idle,
  checking,
  downloading,
  readyToInstall,
  error,
}

class UpdateInfo {
  final String latestVersion;
  final int latestVersionCode;
  final String apkUrl;
  final String releaseNotes;
  final String? sha256Hash;
  final bool isDownloaded;
  final String? localFilePath;
  final double downloadProgress; // 0.0 to 1.0

  const UpdateInfo({
    required this.latestVersion,
    required this.latestVersionCode,
    required this.apkUrl,
    required this.releaseNotes,
    this.sha256Hash,
    this.isDownloaded = false,
    this.localFilePath,
    this.downloadProgress = 0.0,
  });

  UpdateInfo copyWith({
    String? latestVersion,
    int? latestVersionCode,
    String? apkUrl,
    String? releaseNotes,
    String? sha256Hash,
    bool? isDownloaded,
    String? localFilePath,
    double? downloadProgress,
  }) {
    return UpdateInfo(
      latestVersion: latestVersion ?? this.latestVersion,
      latestVersionCode: latestVersionCode ?? this.latestVersionCode,
      apkUrl: apkUrl ?? this.apkUrl,
      releaseNotes: releaseNotes ?? this.releaseNotes,
      sha256Hash: sha256Hash ?? this.sha256Hash,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      localFilePath: localFilePath ?? this.localFilePath,
      downloadProgress: downloadProgress ?? this.downloadProgress,
    );
  }
}

/// UpdateService: Background Auto-Downloader & Instant One-Click Installer
/// - Mengunduh file APK di latar belakang secara diam-diam (silent download) di Android
/// - Di macOS/Windows: Membuka laman unduh rilis desktop via browser eksternal
/// - Dilengkapi mutex unduhan, sanitasi sink I/O, dan verifikasi integritas SHA-256
class UpdateService extends ChangeNotifier {
  static final UpdateService _instance = UpdateService._internal();
  factory UpdateService() => _instance;
  UpdateService._internal();

  UpdateStatus _status = UpdateStatus.idle;
  UpdateStatus get status => _status;

  UpdateInfo? _updateInfo;
  UpdateInfo? get updateInfo => _updateInfo;

  bool get isUpdateReady {
    if (_status != UpdateStatus.readyToInstall || _updateInfo == null) return false;
    if (!kIsWeb && !Platform.isAndroid) {
      // Desktop: siap membuka URL unduhan desktop
      return true;
    }
    return _updateInfo!.isDownloaded && _updateInfo!.localFilePath != null;
  }

  bool _isChecking = false;
  bool _isDownloading = false;

  /// Hitung SHA-256 secara streaming tanpa memuat seluruh file 60MB ke memori RAM (F20)
  static Future<String> _computeFileSha256(File file) async {
    final digest = await sha256.bind(file.openRead()).first;
    return digest.toString();
  }

  /// Memulai pengecekan versi dan unduhan otomatis di background
  Future<void> checkForUpdatesSilently() async {
    if (_isChecking || _isDownloading) return;
    _isChecking = true;

    try {
      _status = UpdateStatus.checking;
      notifyListeners();

      final packageInfo = await PackageInfo.fromPlatform();
      final currentCode = int.tryParse(packageInfo.buildNumber) ?? 0;

      // Ambil konfigurasi versi dari Firestore (collection: app_config, doc: version)
      final doc = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('version')
          .get();

      if (!doc.exists) {
        _status = UpdateStatus.idle;
        _isChecking = false;
        notifyListeners();
        return;
      }

      final data = doc.data()!;
      final latestCode = (data['latest_version_code'] as num?)?.toInt() ?? 0;
      final latestVersion = (data['latest_version'] as String?) ?? packageInfo.version;
      final apkUrl = (data['apk_url'] as String?) ?? '';
      final releaseNotes = (data['release_notes'] as String?) ?? 'Pembaruan aplikasi OpenTurath AI';
      final sha256Hash = (data['sha256'] as String?)?.trim();

      // Jika versi di server lebih baru dari versi yang sedang terpasang
      if (latestCode > currentCode && apkUrl.isNotEmpty) {
        _updateInfo = UpdateInfo(
          latestVersion: latestVersion,
          latestVersionCode: latestCode,
          apkUrl: apkUrl,
          releaseNotes: releaseNotes,
          sha256Hash: sha256Hash,
        );

        if (!kIsWeb && !Platform.isAndroid) {
          // macOS / Windows Desktop: tampilkan banner siap update (buka URL)
          _updateInfo = _updateInfo!.copyWith(
            isDownloaded: true,
            downloadProgress: 1.0,
          );
          _status = UpdateStatus.readyToInstall;
          notifyListeners();
          return;
        }

        // Android: Periksa apakah APK versi tersebut SUDAH pernah terunduh di cache (F44)
        final localFile = await _getLocalApkFile(latestCode);
        bool isCachedValid = false;
        if (await localFile.exists() && (await localFile.length()) > 5 * 1024 * 1024) {
          if (sha256Hash != null && sha256Hash.isNotEmpty) {
            try {
              final cachedSha = await _computeFileSha256(localFile);
              if (cachedSha.toLowerCase() == sha256Hash.toLowerCase()) {
                isCachedValid = true;
              } else {
                debugPrint('[UpdateService] Cached APK hash mismatch: $cachedSha vs $sha256Hash');
                await localFile.delete();
              }
            } catch (e) {
              debugPrint('[UpdateService] Error checking cached hash: $e');
              try {
                await localFile.delete();
              } catch (_) {}
            }
          } else {
            isCachedValid = true;
          }
        }

        if (isCachedValid) {
          _updateInfo = _updateInfo!.copyWith(
            isDownloaded: true,
            localFilePath: localFile.path,
            downloadProgress: 1.0,
          );
          _status = UpdateStatus.readyToInstall;
          notifyListeners();
        } else {
          // Belum terunduh atau cache tidak valid: Jalankan silent background download otomatis
          _startSilentDownload(apkUrl, localFile, sha256Hash);
        }
      } else {
        _status = UpdateStatus.idle;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[UpdateService] Error checking updates: $e');
      _status = UpdateStatus.idle;
      notifyListeners();
    } finally {
      _isChecking = false;
    }
  }

  /// Unduh APK di latar belakang tanpa mengganggu user dengan mutex dan try-finally sink
  Future<void> _startSilentDownload(String url, File targetFile, String? expectedSha256) async {
    if (_isDownloading) return;
    _isDownloading = true;

    final client = HttpClient();
    try {
      _status = UpdateStatus.downloading;
      notifyListeners();

      // Bersihkan file update lama sebelum mulai unduh baru
      await _cleanOldUpdates(targetFile.path);

      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode != 200) {
        _status = UpdateStatus.idle;
        notifyListeners();
        return;
      }

      final contentLength = response.contentLength;
      final tempFile = File('${targetFile.path}.tmp');
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      final sink = tempFile.openWrite();
      int receivedBytes = 0;

      try {
        await for (final chunk in response) {
          sink.add(chunk);
          receivedBytes += chunk.length;
          if (contentLength > 0) {
            final progress = receivedBytes / contentLength;
            _updateInfo = _updateInfo?.copyWith(downloadProgress: progress);
          }
        }
        await sink.flush();
      } finally {
        await sink.close();
      }

      // Validasi integritas ukuran file
      final tempLength = await tempFile.length();
      if (tempLength < 5 * 1024 * 1024 || (contentLength > 0 && tempLength < contentLength)) {
        debugPrint('[UpdateService] Unduhan tidak lengkap ($tempLength bytes)');
        if (await tempFile.exists()) await tempFile.delete();
        _status = UpdateStatus.idle;
        notifyListeners();
        return;
      }

      // Validasi SHA-256 secara streaming jika disediakan oleh Firestore app_config/version (F20)
      if (expectedSha256 != null && expectedSha256.isNotEmpty) {
        final calculatedSha256 = await _computeFileSha256(tempFile);
        if (calculatedSha256.toLowerCase() != expectedSha256.toLowerCase()) {
          debugPrint('[UpdateService] SHA256 checksum mismatch: $calculatedSha256 vs $expectedSha256');
          if (await tempFile.exists()) await tempFile.delete();
          _status = UpdateStatus.idle;
          notifyListeners();
          return;
        }
      }

      // Rename dari temp ke final APK
      if (await targetFile.exists()) {
        await targetFile.delete();
      }
      await tempFile.rename(targetFile.path);

      _updateInfo = _updateInfo?.copyWith(
        isDownloaded: true,
        localFilePath: targetFile.path,
        downloadProgress: 1.0,
      );
      _status = UpdateStatus.readyToInstall;
      notifyListeners();
      debugPrint('[UpdateService] Background download complete: ${targetFile.path}');
    } catch (e) {
      debugPrint('[UpdateService] Background download error: $e');
      _status = UpdateStatus.idle;
      notifyListeners();
    } finally {
      _isDownloading = false;
      client.close();
    }
  }

  /// Bersihkan file APK atau file sementara lama di direktori update
  Future<void> _cleanOldUpdates(String currentPath) async {
    try {
      final dir = await getApplicationSupportDirectory();
      final updateDir = Directory('${dir.path}/updates');
      if (await updateDir.exists()) {
        final list = updateDir.listSync();
        for (final entity in list) {
          if (entity.path != currentPath && (entity.path.endsWith('.apk') || entity.path.endsWith('.tmp'))) {
            try {
              entity.deleteSync();
            } catch (_) {}
          }
        }
      }
    } catch (_) {}
  }

  /// Lokasi file APK di penyimpanan privat aplikasi
  Future<File> _getLocalApkFile(int versionCode) async {
    final dir = await getApplicationSupportDirectory();
    final updateDir = Directory('${dir.path}/updates');
    if (!await updateDir.exists()) {
      await updateDir.create(recursive: true);
    }
    return File('${updateDir.path}/OpenTurath_v$versionCode.apk');
  }

  /// Tombol "Pasang Sekarang" dipanggil:
  /// - Android: Langsung buka Package Installer sistem
  /// - Desktop (macOS/Windows): Buka tautan pembaruan langsung di browser
  Future<void> installNow() async {
    if (!isUpdateReady || _updateInfo == null) return;

    if (!kIsWeb && !Platform.isAndroid) {
      final downloadUrl = _updateInfo!.apkUrl;
      final uri = Uri.tryParse(downloadUrl);
      if (uri != null) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return;
    }

    final filePath = _updateInfo!.localFilePath;
    if (filePath == null) return;

    final file = File(filePath);
    if (!await file.exists()) {
      _status = UpdateStatus.idle;
      notifyListeners();
      return;
    }

    try {
      final result = await OpenFilex.open(
        filePath,
        type: 'application/vnd.android.package-archive',
      );
      debugPrint('[UpdateService] OpenFilex result: ${result.type} - ${result.message}');
    } catch (e) {
      debugPrint('[UpdateService] Install error: $e');
    }
  }
}

```

### FLUTTER FILE: openturath_ai/lib/widgets/app_error_state.dart
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

/// AppErrorState: Komponen visual baku penanganan galat dan koneksi terputus.
/// Menghindarkan aplikasi dari layar kosong atau error bisu tanpa pemulihan.
class AppErrorState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;
  final String retryLabel;
  final VoidCallback? onBack;
  final String backLabel;

  const AppErrorState({
    super.key,
    this.title = 'Koneksi terputus',
    this.message = 'Tidak dapat memuat data saat ini. Periksa koneksi internet lalu coba lagi.',
    this.icon = Icons.wifi_off_rounded,
    this.onRetry,
    this.retryLabel = 'Coba lagi',
    this.onBack,
    this.backLabel = 'Kembali',
  });

  const AppErrorState.network({
    super.key,
    this.title = 'Koneksi Terputus',
    this.message = 'Tidak dapat memuat data naskah saat ini. Periksa koneksi internet lalu coba lagi.',
    this.icon = Icons.wifi_off_rounded,
    this.onRetry,
    this.retryLabel = 'Coba lagi',
    this.onBack,
    this.backLabel = 'Kembali',
  });

  const AppErrorState.unauthorized({
    super.key,
    this.title = 'Akses Dibatasi',
    this.message = 'Sesi akun kedaluwarsa atau modul riset membutuhkan peningkatan hak akses.',
    this.icon = Icons.lock_outline_rounded,
    this.onRetry,
    this.retryLabel = 'Buka Langganan',
    this.onBack,
    this.backLabel = 'Kembali',
  });

  const AppErrorState.empty({
    super.key,
    this.title = 'Naskah Tidak Ditemukan',
    this.message = 'Tidak ada naskah atau catatan yang sesuai dengan kata kunci atau filter.',
    this.icon = Icons.find_in_page_outlined,
    this.onRetry,
    this.retryLabel = 'Reset Pencarian',
    this.onBack,
    this.backLabel = 'Kembali',
  });

  const AppErrorState.generic({
    super.key,
    this.title = 'Terjadi Kendala Teknis',
    this.message = 'Sistem mengalami kendala saat memproses telaah naskah. Silakan coba kembali sesaat lagi.',
    this.icon = Icons.error_outline_rounded,
    this.onRetry,
    this.retryLabel = 'Muat Ulang',
    this.onBack,
    this.backLabel = 'Kembali',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final accent = isDark ? AppTheme.accentDark : AppTheme.accentLight;
    final surface = isDark ? AppTheme.surfaceCardDark : AppTheme.surfaceCardLight;
    final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: border, width: 1.2),
                ),
                child: Icon(icon, size: 32, color: accent),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  height: 1.45,
                  color: textSecondary,
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(
                      retryLabel,
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                    ),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                      ),
                    ),
                  ),
                ),
              ],
              if (onBack != null) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: TextButton(
                    onPressed: onBack,
                    child: Text(
                      backLabel,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w500,
                        color: textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

```

### FLUTTER FILE: openturath_ai/lib/widgets/app_loader.dart
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

/// AppLoader: Komponen visual baku tiga titik berdenyut (Three-Dots Pulse Loader).
/// Menyatukan 4 implementasi loader berbeda menjadi satu komponen berstandar Apple HIG.
class AppLoader extends StatefulWidget {
  final double dotSize;
  final double spacing;
  final Color? color;
  final String? title;
  final String? subtitle;
  final VoidCallback? onCancel;
  final String cancelLabel;
  final bool isFullscreen;

  const AppLoader({
    super.key,
    this.dotSize = 9.0,
    this.spacing = 5.0,
    this.color,
    this.title,
    this.subtitle,
    this.onCancel,
    this.cancelLabel = 'Batal',
    this.isFullscreen = false,
  });

  const AppLoader.fullscreen({
    super.key,
    this.dotSize = 10.0,
    this.spacing = 5.0,
    this.color,
    this.title,
    this.subtitle,
    this.onCancel,
    this.cancelLabel = 'Batal',
  }) : isFullscreen = true;

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultAccent = isDark ? AppTheme.accentDark : AppTheme.accentLight;
    final dotColor = widget.color ?? defaultAccent;
    final textPrimary = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final canvas = isDark ? AppTheme.canvasDark : AppTheme.canvasLight;

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                final delay = index * 0.2;
                final t = (_controller.value - delay) % 1.0;
                final curveVal = Curves.easeInOutSine.transform(t < 0 ? t + 1.0 : t);
                final scale = 0.75 + (0.45 * (1.0 - (curveVal - 0.5).abs() * 2));
                final opacity = 0.3 + (0.7 * (1.0 - (curveVal - 0.5).abs() * 2));

                return Container(
                  margin: EdgeInsets.symmetric(horizontal: widget.spacing),
                  child: Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: opacity.clamp(0.25, 1.0),
                      child: Container(
                        width: widget.dotSize,
                        height: widget.dotSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: dotColor,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
        if (widget.title != null) ...[
          const SizedBox(height: 20),
          Text(
            widget.title!,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
        ],
        if (widget.subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.subtitle!,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: textSecondary,
            ),
          ),
        ],
        if (widget.onCancel != null) ...[
          const SizedBox(height: 24),
          TextButton(
            onPressed: widget.onCancel,
            style: TextButton.styleFrom(
              minimumSize: const Size(80, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusPill),
              ),
            ),
            child: Text(
              widget.cancelLabel,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: textSecondary,
              ),
            ),
          ),
        ],
      ],
    );

    if (widget.isFullscreen) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: canvas,
        child: SafeArea(
          child: Center(child: content),
        ),
      );
    }

    return Center(child: content);
  }
}

```

### FLUTTER FILE: openturath_ai/lib/widgets/apple_interactive_wrapper.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wrapper interaktif bergaya Apple iOS dengan animasi kompresi mikro
/// (press-down scale), pantulan pegas halus, dan getaran haptic feedback taktil.
class AppleInteractiveWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressedScale;
  final Duration duration;
  final bool enableHaptic;
  final HapticFeedbackType hapticType;
  final BorderRadius? borderRadius;
  final String? semanticLabel;

  const AppleInteractiveWrapper({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.975,
    this.duration = const Duration(milliseconds: 110),
    this.enableHaptic = true,
    this.hapticType = HapticFeedbackType.light,
    this.borderRadius,
    this.semanticLabel,
  });

  @override
  State<AppleInteractiveWrapper> createState() => _AppleInteractiveWrapperState();
}

enum HapticFeedbackType {
  light,
  medium,
  selection,
  none,
}

class _AppleInteractiveWrapperState extends State<AppleInteractiveWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pressedScale,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _triggerHaptic() {
    if (!widget.enableHaptic) return;
    switch (widget.hapticType) {
      case HapticFeedbackType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.selection:
        HapticFeedback.selectionClick();
        break;
      case HapticFeedbackType.none:
        break;
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null || widget.onLongPress != null) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null || widget.onLongPress != null) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null || widget.onLongPress != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAction = widget.onTap != null || widget.onLongPress != null;
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    Widget result = reduceMotion
        ? widget.child
        : AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              );
            },
            child: widget.child,
          );

    if (hasAction) {
      result = Semantics(
        button: true,
        enabled: true,
        label: widget.semanticLabel,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: reduceMotion ? null : _handleTapDown,
          onTapUp: reduceMotion ? null : _handleTapUp,
          onTapCancel: reduceMotion ? null : _handleTapCancel,
          onTap: () {
            _triggerHaptic();
            widget.onTap?.call();
          },
          onLongPress: widget.onLongPress != null
              ? () {
                  HapticFeedback.mediumImpact();
                  widget.onLongPress?.call();
                }
              : null,
          child: result,
        ),
      );
    }

    return result;
  }
}

```

### FLUTTER FILE: openturath_ai/lib/widgets/book_row_item.dart
```dart
import 'package:flutter/material.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_spacing.dart';
import '../models/book_model.dart';
import 'apple_interactive_wrapper.dart';

/// Item baris naskah kanonikal dengan tinggi adaptif, tipografi Amiri berharakat,
/// isolasi arah baca RTL, dan target sentuh ramah Apple HIG (>= 48px).
class BookRowItem extends StatelessWidget {
  const BookRowItem({
    super.key,
    required this.book,
    required this.onTap,
    this.searchQuery,
  });

  final CanonicalBookPresentation book;
  final VoidCallback onTap;
  final String? searchQuery;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = OTColors.surface(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final primaryAccent = OTColors.accent(isDark);

    return Padding(
      padding: const EdgeInsets.only(bottom: OTSpacing.sm),
      child: AppleInteractiveWrapper(
        onTap: onTap,
        pressedScale: 0.98,
        hapticType: HapticFeedbackType.light,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 68),
          padding: const EdgeInsets.symmetric(
            horizontal: OTSpacing.md,
            vertical: OTSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 0.8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Leading Icon / Book Badge
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: primaryAccent.withValues(alpha: isDark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: primaryAccent.withValues(alpha: isDark ? 0.3 : 0.2),
                    width: 0.8,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.menu_book_rounded,
                  size: 20,
                  color: primaryAccent,
                ),
              ),
              const SizedBox(width: OTSpacing.md),

              // Title and Meta Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Arabic Title with RTL Isolation
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        book.titleArabic,
                        textAlign: TextAlign.right,
                        style: OTTypography.arabicReading(
                          color: textPrimary,
                        ).copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),

                    // Author & Death Year
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            book.authorArabic,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: OTTypography.caption(color: textSecondary).copyWith(
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                        if (book.verifiedDeathYearHijri != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : Colors.black.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'w. ${book.verifiedDeathYearHijri} H',
                              style: OTTypography.caption(color: textSecondary).copyWith(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Tags & Labels (Type, Era, Volumes)
                    if (book.compactLabels.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: book.compactLabels.map((lbl) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: primaryAccent.withValues(alpha: isDark ? 0.12 : 0.06),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              lbl,
                              style: OTTypography.caption(color: primaryAccent).copyWith(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: textSecondary.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

```

### FLUTTER FILE: openturath_ai/lib/widgets/corpus_kind_control.dart
```dart
import 'package:flutter/material.dart';
import '../models/agent_model.dart';

/// Reusable SegmentedButton control to toggle between [CorpusKind.discipline] (Bidang Ilmu)
/// and [CorpusKind.scholar] (Karya Ulama).
class CorpusKindControl extends StatelessWidget {
  const CorpusKindControl({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final CorpusKind value;
  final ValueChanged<CorpusKind> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final largeText = MediaQuery.textScalerOf(context).scale(14) > 20;
        return SegmentedButton<CorpusKind>(
          direction: constraints.maxWidth < 340 || largeText
              ? Axis.vertical
              : Axis.horizontal,
          expandedInsets: EdgeInsets.zero,
          showSelectedIcon: true,
          segments: const [
            ButtonSegment(
              value: CorpusKind.discipline,
              label: Text('Bidang Ilmu'),
              icon: Icon(Icons.category_outlined, size: 18),
            ),
            ButtonSegment(
              value: CorpusKind.scholar,
              label: Text('Karya Ulama'),
              icon: Icon(Icons.person_outline_rounded, size: 18),
            ),
          ],
          selected: {value},
          onSelectionChanged: (selection) => onChanged(selection.single),
          style: SegmentedButton.styleFrom(
            minimumSize: const Size(48, 48),
            tapTargetSize: MaterialTapTargetSize.padded,
          ),
        );
      },
    );
  }
}

```

### FLUTTER FILE: openturath_ai/lib/widgets/doku_checkout_sheet.dart
```dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants.dart';
import '../core/checkout_completion.dart';
import '../core/theme.dart';
import '../services/subscription_service.dart';
import 'app_loader.dart';

/// DokuCheckoutSheet: In-App Modal Pembayaran DOKU dengan Deteksi Otomatis
/// Menampilkan halaman DOKU di dalam modal aplikasi tanpa perlu terlempar ke Chrome.
/// Dilengkapi background status synchronization (inquiry real-time) yang otomatis
/// mendeteksi keberhasilan pembayaran dan menutup pop-up seketika transaksi tuntas.
class DokuCheckoutSheet extends StatefulWidget {
  final String paymentUrl;
  final String invoiceNumber;
  final String? trxId;
  final String? planTitle;
  final int? amount;

  const DokuCheckoutSheet({
    super.key,
    required this.paymentUrl,
    required this.invoiceNumber,
    this.trxId,
    this.planTitle,
    this.amount,
  });

  /// Helper untuk membuka modal secara elegan dari layar manapun
  static Future<bool?> show(
    BuildContext context, {
    required String paymentUrl,
    required String invoiceNumber,
    String? trxId,
    String? planTitle,
    int? amount,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      isDismissible: false,
      builder: (context) => DokuCheckoutSheet(
        paymentUrl: paymentUrl,
        invoiceNumber: invoiceNumber,
        trxId: trxId,
        planTitle: planTitle,
        amount: amount,
      ),
    );
  }

  @override
  State<DokuCheckoutSheet> createState() => _DokuCheckoutSheetState();
}

class _DokuCheckoutSheetState extends State<DokuCheckoutSheet> {
  final SubscriptionService _subService = SubscriptionService();

  InAppWebViewController? _webController;
  Timer? _pollTimer;
  StreamSubscription<QuerySnapshot>? _txSubscription;
  double _loadProgress = 0.0;
  bool _isChecking = false;
  bool _isSuccess = false;
  int _pollAttempts = 0;
  bool _isShowingConfirmDialog = false;
  bool _hasPopped = false;
  final _completion = CheckoutCompletion();
  BuildContext? _confirmationContext;

  @override
  void initState() {
    super.initState();

    // 1. Real-time Firestore Listener: mendeteksi instan saat status berubah jadi 'success' (< 1s)
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (widget.invoiceNumber.isNotEmpty && currentUid != null) {
      _txSubscription = FirebaseFirestore.instance
          .collection(AppConstants.colTransactions)
          .where('uid', isEqualTo: currentUid)
          .where('invoice_number', isEqualTo: widget.invoiceNumber)
          .limit(1)
          .snapshots()
          .listen(
            (snap) {
              if (snap.docs.isNotEmpty) {
                final data = snap.docs.first.data() as Map<String, dynamic>?;
                final status = (data?['status'] ?? '').toString().toLowerCase();
                if (status == 'paid' || status == 'success') {
                  _triggerSuccess();
                }
              }
            },
            onError: (_) {
              // Jika query ditolak atau gagal, biarkan fail-safe polling tetap berjalan
            },
          );
    }

    // 2. Active inquiry polling setiap 2 detik sebagai fail-safe
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkPaymentStatus();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _txSubscription?.cancel();
    _webController = null;
    super.dispose();
  }

  void _triggerSuccess() async {
    if (_isSuccess || _hasPopped || !mounted) return;
    _pollTimer?.cancel();
    _txSubscription?.cancel();
    setState(() {
      _isSuccess = true;
    });

    // Beri jeda 2.2 detik agar pengguna menikmati animasi sukses
    await Future.delayed(const Duration(milliseconds: 2200));
    await _completion.finish(
      dismissConfirmation: () {
        final dialogContext = _confirmationContext;
        if (dialogContext != null && dialogContext.mounted && ModalRoute.of(dialogContext)?.isCurrent == true) {
          Navigator.of(dialogContext).pop(false);
        }
      },
      closeCheckout: () {
        if (mounted && !_hasPopped && ModalRoute.of(context)?.isCurrent == true) {
          _hasPopped = true;
          Navigator.of(context).pop(true);
        }
      },
    );
  }

  Future<void> _checkPaymentStatus() async {
    if (_isChecking || _isSuccess || _hasPopped || !mounted) return;
    if (widget.invoiceNumber.isEmpty) return;

    _pollAttempts++;
    // F33: Batas maksimal polling 150 kali (5 menit) agar tidak memboroskan sumber daya
    if (_pollAttempts > 60) {
      _pollTimer?.cancel();
      return;
    }

    _isChecking = true;
    try {
      final res = await _subService.verifyPaymentStatus(
        invoiceNumber: widget.invoiceNumber,
        trxId: widget.trxId,
      );

      if (res['status'] == 'SUCCESS' || res['success'] == true) {
        _triggerSuccess();
      }
    } catch (_) {
      // Polling background gagal sementara, lanjut ke tick berikutnya
    } finally {
      if (mounted) {
        _isChecking = false;
      }
    }
  }

  Future<bool> _handleWillPop() async {
    if (_isSuccess || _hasPopped) return false;
    if (_isShowingConfirmDialog) return false;

    _isShowingConfirmDialog = true;
    final confirmationDone = Completer<void>();
    _completion.confirmation = confirmationDone.future;
    try {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          _confirmationContext = ctx;
          return AlertDialog(
          backgroundColor: isDark ? AppTheme.surfaceCardDark : AppTheme.surfaceCardLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusCard)),
          title: Text(
            'Tutup Laman Pembayaran?',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
            ),
          ),
          content: Text(
            'Apakah Anda ingin menutup sesi pembayaran? Transaksi Anda tetap tercatat di sistem.',
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'Lanjutkan Bayar',
                style: GoogleFonts.outfit(
                  color: isDark ? AppTheme.accentDark : AppTheme.accentLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                'Ya, Tutup',
                style: GoogleFonts.outfit(
                  color: AppTheme.appleRed,
                ),
              ),
            ),
          ],
          );
        },
      );

      return !_isSuccess && (confirm ?? false);
    } finally {
      _confirmationContext = null;
      _isShowingConfirmDialog = false;
      confirmationDone.complete();
      _completion.confirmation = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppTheme.surfaceCardDark : AppTheme.surfaceCardLight;
    final textPrimary = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final accent = isDark ? AppTheme.accentDark : AppTheme.accentLight;

    final screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _handleWillPop();
        if (shouldPop && context.mounted && !_hasPopped) {
          _hasPopped = true;
          Navigator.of(context).pop(false);
        }
      },
      child: Container(
        height: screenHeight * 0.92,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusCard)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 100 : 40),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusCard)),
          child: Stack(
            children: [
              // ── 1. Main Sheet Content (Header + WebView) ──
              Column(
                children: [
                  // Top Drag Handle & Title Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      border: Border(bottom: BorderSide(color: border, width: 1)),
                    ),
                    child: Column(
                      children: [
                        // Drag Indicator
                        Center(
                          child: Container(
                            width: 36,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: border,
                              borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withAlpha(30),
                                borderRadius: BorderRadius.circular(AppTheme.radiusXS),
                              ),
                              child: const Icon(
                                Icons.lock_rounded,
                                size: 18,
                                color: Color(0xFF10B981),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pembayaran Aman DOKU',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: textPrimary,
                                    ),
                                  ),
                                  if (widget.invoiceNumber.isNotEmpty)
                                    Text(
                                      widget.invoiceNumber,
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        letterSpacing: 0.3,
                                        color: textSecondary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // Tombol Cek Manual / Refresh
                            IconButton(
                              onPressed: _isChecking
                                  ? null
                                  : () {
                                      _webController?.reload();
                                      _checkPaymentStatus();
                                    },
                              icon: _isChecking
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : Icon(Icons.sync_rounded, size: 20, color: textSecondary),
                              tooltip: 'Periksa Status Pembayaran & Muat Ulang',
                            ),
                            // Close Button
                            IconButton(
                              onPressed: () async {
                                final shouldPop = await _handleWillPop();
                                if (shouldPop && context.mounted && !_hasPopped) {
                                  _hasPopped = true;
                                  Navigator.of(context).pop(false);
                                }
                              },
                              icon: Icon(Icons.close_rounded, size: 22, color: textSecondary),
                              tooltip: 'Tutup',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Linear Progress Bar saat memuat halaman WebView
                  if (_loadProgress < 1.0)
                    LinearProgressIndicator(
                      value: _loadProgress,
                      backgroundColor: Colors.transparent,
                      color: accent,
                      minHeight: 2.5,
                    ),

                  // WebView DOKU
                  Expanded(
                    child: InAppWebView(
                      initialUrlRequest: URLRequest(url: WebUri(widget.paymentUrl)),
                      initialSettings: InAppWebViewSettings(
                        javaScriptEnabled: true,
                        domStorageEnabled: true,
                        databaseEnabled: true,
                        sharedCookiesEnabled: true,
                        thirdPartyCookiesEnabled: true,
                        useHybridComposition: true,
                        mixedContentMode: MixedContentMode.MIXED_CONTENT_NEVER_ALLOW,
                        allowFileAccess: false,
                        allowContentAccess: true,
                        javaScriptCanOpenWindowsAutomatically: true,
                        supportZoom: true,
                        builtInZoomControls: true,
                        displayZoomControls: false,
                        forceDark: isDark ? ForceDark.ON : ForceDark.OFF,
                        transparentBackground: false,
                      ),
                      onWebViewCreated: (controller) {
                        _webController = controller;
                      },
                      onProgressChanged: (controller, progress) {
                        if (mounted) {
                          setState(() {
                            _loadProgress = progress / 100.0;
                          });
                        }
                      },
                      shouldOverrideUrlLoading: (controller, navigationAction) async {
                        final uri = navigationAction.request.url;
                        if (uri == null) return NavigationActionPolicy.ALLOW;

                        final urlStr = uri.toString().toLowerCase();

                        // Intersep jika DOKU mengarah ke callback URL kita atau URL sukses
                        if (urlStr.contains('openturath-ai.web.app') ||
                            urlStr.contains('callback') ||
                            urlStr.contains('finish') ||
                            urlStr.contains('checkout-success')) {
                          _checkPaymentStatus();
                          return NavigationActionPolicy.ALLOW;
                        }

                        return NavigationActionPolicy.ALLOW;
                      },
                      onLoadStop: (controller, url) async {
                        if (mounted) {
                          setState(() => _loadProgress = 1.0);
                        }

                        final urlStr = url?.toString().toLowerCase() ?? '';
                        if (urlStr.contains('openturath-ai.web.app') ||
                            urlStr.contains('checkout-link') ||
                            urlStr.contains('success')) {
                          _checkPaymentStatus();
                        }

                        // Deteksi instan jika DOM DOKU menampilkan halaman Payment Successful
                        try {
                          final isPaidDom = await controller.evaluateJavascript(source: """
                            (function() {
                              var text = (document.body ? document.body.innerText : '') || '';
                              if (text.includes('Payment Successful') || 
                                  text.includes('Pembayaran Berhasil') || 
                                  text.includes('Berhasil!')) {
                                return true;
                              }
                              return false;
                            })();
                          """);
                          if (isPaidDom == true) {
                            _checkPaymentStatus();
                          }
                        } catch (_) {}
                      },
                    ),
                  ),
                ],
              ),

              // ── 2. Celebratory Success Overlay ──
              if (_isSuccess)
                _CelebratorySuccessView(
                  surfaceColor: surfaceColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  accent: accent,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CelebratorySuccessView extends StatelessWidget {
  final Color surfaceColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;

  const _CelebratorySuccessView({
    required this.surfaceColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: Container(
            color: surfaceColor,
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Spring bounce scale for the checkmark badge
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 750),
                      curve: Curves.elasticOut,
                      builder: (context, scale, _) {
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF10B981).withValues(alpha: 0.16),
                              border: Border.all(
                                color: const Color(0xFF10B981),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
                                  blurRadius: 28,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 50,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    // "Alhamdulillah!" with fade-up
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return Opacity(
                          opacity: value.clamp(0.0, 1.0),
                          child: Transform.translate(
                            offset: Offset(0, (1.0 - value) * 16),
                            child: Text(
                              'Alhamdulillah!',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w800,
                                fontSize: 26,
                                letterSpacing: -0.5,
                                color: textPrimary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    // "Pembayaran Berhasil Diverifikasi"
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return Opacity(
                          opacity: value.clamp(0.0, 1.0),
                          child: Transform.translate(
                            offset: Offset(0, (1.0 - value) * 14),
                            child: Text(
                              'Pembayaran Berhasil Diverifikasi',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    // Description
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return Opacity(
                          opacity: value.clamp(0.0, 1.0),
                          child: Transform.translate(
                            offset: Offset(0, (1.0 - value) * 12),
                            child: Text(
                              'Akses ke ruang riset Anda telah aktif secara otomatis. Mengalihkan...',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: textSecondary,
                                height: 1.45,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    // Unified AppLoader
                    AppLoader(color: accent, dotSize: 8, spacing: 4),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}


```

### FLUTTER FILE: openturath_ai/lib/widgets/evidence_bottom_sheet.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme.dart';
import '../core/app_snackbar.dart';

class EvidenceBottomSheet extends StatelessWidget {
  final int citationNumber;
  final String bookName;
  final String author;
  final String pageNumber;
  final String category;
  final String arabicExcerpt;
  final String explanation;
  final String? externalUrl;

  const EvidenceBottomSheet({
    super.key,
    required this.citationNumber,
    required this.bookName,
    required this.author,
    required this.pageNumber,
    required this.category,
    required this.arabicExcerpt,
    required this.explanation,
    this.externalUrl,
  });

  Future<void> _launchExternal(BuildContext context) async {
    final query = Uri.encodeComponent(bookName);
    final url = externalUrl != null && externalUrl!.isNotEmpty
        ? Uri.parse(externalUrl!)
        : Uri.parse('https://shamela.ws/search?q=$query');

    try {
      final canLaunch = await canLaunchUrl(url);
      if (canLaunch) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          AppSnackBar.error(context, 'Tidak dapat membuka rujukan eksternal: $url');
        }
      }
    } catch (_) {}
  }

  void _copyIbarah(BuildContext context) {
    Clipboard.setData(ClipboardData(text: arabicExcerpt));
    AppSnackBar.success(context, 'Teks disalin');
  }

  void _shareEvidence(BuildContext context) {
    final buffer = StringBuffer();
    buffer.writeln('📖 *Rujukan Ilmiah: $bookName*');
    buffer.writeln('Musannif/Pengarang: $author');
    buffer.writeln('Disiplin: $category | Halaman: $pageNumber');
    buffer.writeln();
    if (arabicExcerpt.isNotEmpty) {
      buffer.writeln('نص العبارة:');
      buffer.writeln('« $arabicExcerpt »');
      buffer.writeln();
    }
    if (explanation.isNotEmpty) {
      buffer.writeln('Taqrir & Syarah:');
      buffer.writeln(explanation);
      buffer.writeln();
    }
    buffer.writeln('—');
    buffer.writeln('Disimpan melalui *OpenTurath*');

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    AppSnackBar.success(context, 'Sitasi disalin');
  }

  Widget _stagger(int index, Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 260 + (index * 60)),
      curve: Curves.easeOutCubic,
      builder: (context, value, animChild) {
        return Transform.translate(
          offset: Offset(0, 16 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: animChild,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppTheme.surfaceCardDark : AppTheme.surfaceCardLight;
    final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final textPrimary = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final accent = isDark ? AppTheme.accentDark : AppTheme.accentLight;

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.94,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusCard)),
            border: Border.all(color: border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 30,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Drag Handle ──
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: border,
                    borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  ),
                ),
              ),

              // ── Header Bar (Figma Screen 10) ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.menu_book_rounded, size: 20, color: accent),
                        const SizedBox(width: 8),
                        Text(
                          'Sumber $citationNumber',
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: textSecondary, size: 22),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // ── Scrollable Body with Stagger Reveal ──
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    // 1. Book Name (Arabic / Latin)
                    _stagger(
                      0,
                      Text(
                        bookName,
                        style: GoogleFonts.outfit(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 2. Metadata Grid (Penulis, Halaman, Kategori)
                    _stagger(
                      1,
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.surfaceCardDark : AppTheme.groupedCanvasLight,
                          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                          border: Border.all(color: border, width: 1),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Penulis', style: GoogleFonts.outfit(fontSize: 12, color: textSecondary)),
                                Flexible(
                                  child: Text(
                                    author,
                                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Divider(height: 1, color: border),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Halaman', style: GoogleFonts.outfit(fontSize: 12, color: textSecondary)),
                                Text(
                                  pageNumber,
                                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Divider(height: 1, color: border),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Kategori', style: GoogleFonts.outfit(fontSize: 12, color: textSecondary)),
                                Text(
                                  category,
                                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: accent),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 3. Section: Teks Asli Kitab (Ibarah) with subtle border glow
                    _stagger(
                      2,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.format_quote_rounded, size: 18, color: accent),
                              const SizedBox(width: 6),
                              Text(
                                'Kutipan Ibarah Asli (Arab)',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.surfaceElevated : AppTheme.citationBgLight,
                              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                              border: Border.all(
                                color: accent.withValues(alpha: isDark ? 0.35 : 0.25),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withValues(alpha: isDark ? 0.08 : 0.04),
                                  blurRadius: 16,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: SelectableText(
                              arabicExcerpt,
                              textDirection: TextDirection.rtl,
                              style: GoogleFonts.amiri(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                height: 1.7,
                                color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 4. Section: Intisari & Penjelasan Kontekstual
                    _stagger(
                      3,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Intisari & Analisis Kontekstual',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            explanation,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // 5. Action Buttons
                    _stagger(
                      4,
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _copyIbarah(context),
                              icon: const Icon(Icons.copy_rounded, size: 16),
                              label: const Text('Salin Teks'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: accent,
                                side: BorderSide(color: accent.withValues(alpha: 0.6)),
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                                ),
                                textStyle: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => _launchExternal(context),
                              icon: const Icon(Icons.open_in_new_rounded, size: 16),
                              label: const Text('Cari di Syamilah'),
                              style: FilledButton.styleFrom(
                                backgroundColor: accent,
                                foregroundColor: isDark
                                    ? AppTheme.canvasDark
                                    : Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                                ),
                                textStyle: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filledTonal(
                            onPressed: () => _shareEvidence(context),
                            icon: const Icon(Icons.share_outlined, size: 18),
                            tooltip: 'Salin sitasi',
                            style: IconButton.styleFrom(
                              padding: const EdgeInsets.all(13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

```

### FLUTTER FILE: openturath_ai/lib/widgets/library_bottom_sheet.dart
```dart
import 'package:flutter/material.dart';
import '../core/app_copy.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../core/routes.dart';
import '../models/agent_model.dart';
import '../models/book_model.dart';
import '../services/canonical_library_service.dart';
import 'apple_interactive_wrapper.dart';

/// Opens the Canonical Research Library as a dedicated full-screen scholarly catalog route.
/// Eliminates sheet-on-sheet anti-pattern per Apple HIG.
Future<void> showResearchLibrary(
  BuildContext context, {
  AgentModel? agent,
}) {
  return Navigator.pushNamed(
    context,
    AppRoutes.bookCatalog,
    arguments: agent,
  );
}

class ResearchLibrarySheet extends StatefulWidget {
  const ResearchLibrarySheet({super.key, this.agent});

  final AgentModel? agent;

  @override
  State<ResearchLibrarySheet> createState() => _ResearchLibrarySheetState();
}

class _ResearchLibrarySheetState extends State<ResearchLibrarySheet> {
  final TextEditingController _searchController = TextEditingController();
  final CanonicalLibraryService _service = CanonicalLibraryService.instance;

  List<CanonicalBookPresentation>? _allBooks;
  List<CanonicalBookPresentation>? _filteredBooks;
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedEra;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_allBooks == null) return;
    setState(() {
      _filteredBooks = _service.filterBooks(
        _allBooks!,
        _searchController.text,
        eraFilter: _selectedEra,
      );
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final books = await _service.loadSyafiiCatalog();
      if (!mounted) return;
      setState(() {
        _allBooks = books;
        _filteredBooks = books;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = AppCopy.catalogLoadFailed;
        _isLoading = false;
      });
    }
  }

  void _showEditionDetails(CanonicalBookPresentation book) {
    Navigator.pushNamed(
      context,
      AppRoutes.bookDetail,
      arguments: book,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final canvas = OTColors.canvas(isDark);
    final surface = OTColors.surface(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final border = OTColors.border(isDark);

    final title = widget.agent != null
        ? 'Kitab rujukan ${widget.agent!.title}'
        : 'Kitab rujukan Mazhab Syafi\'i';

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: canvas,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: border, width: 0.8),
          ),
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 8),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: OTSpacing.lg, vertical: OTSpacing.xs),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: OTTypography.corpusTitle(color: textPrimary).copyWith(fontSize: 18),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_allBooks != null)
                            Text(
                              '${_filteredBooks?.length ?? 0} dari ${_allBooks!.length} kitab rujukan',
                              style: OTTypography.caption(color: textSecondary),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Search field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: OTSpacing.lg, vertical: OTSpacing.sm),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari judul, pengarang, penerbit, atau tahqiq...',
                    hintStyle: OTTypography.caption(color: textSecondary),
                    prefixIcon: Icon(Icons.search_rounded, size: 20, color: textSecondary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear_rounded, size: 18, color: textSecondary),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    filled: true,
                    fillColor: surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: OTRadius.inputBorder,
                      borderSide: BorderSide(color: border, width: 0.8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: OTRadius.inputBorder,
                      borderSide: BorderSide(color: border, width: 0.8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: OTSpacing.xs),

              // Content
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(OTSpacing.xl),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.menu_book_outlined, size: 48, color: textSecondary),
                                  const SizedBox(height: OTSpacing.md),
                                  Text(
                                    _errorMessage!,
                                    style: OTTypography.body(color: textSecondary),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: OTSpacing.base),
                                  OutlinedButton(
                                    onPressed: _loadData,
                                    child: const Text('Coba lagi'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _filteredBooks == null || _filteredBooks!.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(OTSpacing.xl),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.search_off_rounded, size: 40, color: textSecondary),
                                      const SizedBox(height: OTSpacing.sm),
                                      Text(
                                        'Tidak ada kitab yang cocok dengan pencarian',
                                        style: OTTypography.body(color: textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.separated(
                                controller: scrollController,
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: OTSpacing.lg,
                                  vertical: OTSpacing.sm,
                                ),
                                itemCount: _filteredBooks!.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (ctx, index) {
                                  final item = _filteredBooks![index];
                                  return CanonicalBookTile(
                                    book: item,
                                    onOpenEdition: () => _showEditionDetails(item),
                                  );
                                },
                              ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Bibliographical book tile adhering strictly to Audit Specification 6.4.
class CanonicalBookTile extends StatelessWidget {
  const CanonicalBookTile({
    super.key,
    required this.book,
    required this.onOpenEdition,
  });

  final CanonicalBookPresentation book;
  final VoidCallback onOpenEdition;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = OTColors.surface(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final accent = OTColors.accent(isDark);

    final latinAuthor = book.authorLatin;

    return Semantics(
      button: true,
      label: '${book.titleArabic}, ${book.authorArabic}',
      child: AppleInteractiveWrapper(
        onTap: onOpenEdition,
        pressedScale: 0.98,
        hapticType: HapticFeedbackType.light,
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: border, width: 0.8),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Arabic title
                Text(
                  book.titleArabic,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: OTTypography.arabicReading(color: textPrimary).copyWith(
                    fontSize: 20,
                    height: 1.6,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (book.titleLatin != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    book.titleLatin!,
                    style: OTTypography.bodyMedium(color: textPrimary),
                  ),
                ],
                const SizedBox(height: 8),

                // Author
                Text(
                  latinAuthor ?? book.authorArabic,
                  textDirection: latinAuthor == null ? TextDirection.rtl : TextDirection.ltr,
                  textAlign: latinAuthor == null ? TextAlign.right : TextAlign.left,
                  style: latinAuthor == null
                      ? OTTypography.arabicReading(color: textSecondary).copyWith(fontSize: 15)
                      : OTTypography.caption(color: textSecondary),
                ),

                if (book.verifiedDeathYearHijri != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'w. ${book.verifiedDeathYearHijri} H',
                    style: OTTypography.caption(color: textSecondary),
                  ),
                ],

                if (book.compactLabels.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: book.compactLabels.map((lbl) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: OTColors.surfaceSubtle(isDark),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: border.withValues(alpha: 0.5), width: 0.6),
                        ),
                        child: Text(
                          lbl,
                          style: OTTypography.caption(color: textSecondary).copyWith(fontSize: 11),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Keterangan kitab',
                      style: OTTypography.button(color: accent).copyWith(fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios_rounded, size: 10, color: accent),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

```

### FLUTTER FILE: openturath_ai/lib/widgets/openturath_brand.dart
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme.dart';

/// Ikon Gerbang Kubah Resmi OpenTurath
class OpenTurathMark extends StatelessWidget {
  const OpenTurathMark({super.key, this.size = 36, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      label: 'OpenTurath',
      image: true,
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          isDark
              ? 'assets/images/arch_dark_transparent.png'
              : 'assets/images/arch_light_transparent.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

/// Logo Header Resmi OpenTurath (Arch + Wordmark Newsreader)
class OpenTurathBrand extends StatelessWidget {
  const OpenTurathBrand({
    super.key,
    this.compact = false,
    this.onDark = false,
    this.showSlogan = false,
  });

  final bool compact;
  final bool onDark;
  final bool showSlogan;

  @override
  Widget build(BuildContext context) {
    final isDark = onDark || Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final iconSize = compact ? 22.0 : 28.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          isDark
              ? 'assets/images/arch_dark_transparent.png'
              : 'assets/images/arch_light_transparent.png',
          width: iconSize,
          height: iconSize,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 10),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'OpenTurath',
              style: GoogleFonts.newsreader(
                fontSize: compact ? 18 : 21,
                fontWeight: FontWeight.w600,
                color: textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            if (showSlogan) ...[
              const SizedBox(height: 1),
              Text(
                'AI for Islamic Scholarship',
                style: GoogleFonts.newsreader(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: textSecondary,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

```

### FLUTTER FILE: openturath_ai/lib/widgets/redeem_code_sheet.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_snackbar.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../services/subscription_service.dart';
import 'app_loader.dart';

class RedeemCodeSheet extends StatefulWidget {
  final VoidCallback? onSuccess;

  const RedeemCodeSheet({
    super.key,
    this.onSuccess,
  });

  static Future<void> show(BuildContext context, {VoidCallback? onSuccess}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => RedeemCodeSheet(onSuccess: onSuccess),
    );
  }

  @override
  State<RedeemCodeSheet> createState() => _RedeemCodeSheetState();
}

class _RedeemCodeSheetState extends State<RedeemCodeSheet> {
  final TextEditingController _codeController = TextEditingController();
  final SubscriptionService _subscriptionService = SubscriptionService();
  bool _isLoading = false;
  String? _inlineError;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleRedeem() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _inlineError = 'Masukkan kode akses');
      return;
    }

    setState(() {
      _isLoading = true;
      _inlineError = null;
    });

    final result = await _subscriptionService.redeemAccessCode(code);
    if (!mounted) return;
    setState(() => _isLoading = false);

    final success = result['success'] == true;
    final message = (result['message'] as String?) ??
        (success ? 'Akses berhasil diaktifkan' : 'Kode tidak valid atau sudah kedaluwarsa');

    if (success) {
      AppSnackBar.show(
        context,
        message: 'Akses berhasil diaktifkan',
        type: SnackType.success,
      );
      widget.onSuccess?.call();
      Navigator.of(context).pop();
    } else {
      setState(() => _inlineError = message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bgSurface = OTColors.surface(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final borderColor = OTColors.border(isDark);
    final canvas = OTColors.canvas(isDark);

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: bgSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: borderColor, width: 0.8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: OTSpacing.base),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gunakan kode akses',
                  style: OTTypography.cardTitle(color: textPrimary).copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, size: 20, color: textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: OTSpacing.md),
            TextField(
              controller: _codeController,
              enabled: !_isLoading,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\-_]')),
                LengthLimitingTextInputFormatter(25),
              ],
              onChanged: (_) {
                if (_inlineError != null) setState(() => _inlineError = null);
              },
              style: OTTypography.bodyMedium(color: textPrimary).copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
              decoration: InputDecoration(
                hintText: 'Masukkan kode akses',
                hintStyle: OTTypography.body(color: textSecondary).copyWith(
                  letterSpacing: 0,
                  fontSize: 14,
                ),
                errorText: _inlineError,
                errorStyle: const TextStyle(fontSize: 12),
                filled: true,
                fillColor: canvas,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: OTRadius.inputBorder,
                  borderSide: BorderSide(color: borderColor, width: 0.8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: OTRadius.inputBorder,
                  borderSide: BorderSide(color: borderColor, width: 0.8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: OTRadius.inputBorder,
                  borderSide: BorderSide(color: textPrimary, width: 1.2),
                ),
              ),
            ),
            const SizedBox(height: OTSpacing.lg),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: _isLoading ? null : _handleRedeem,
                style: FilledButton.styleFrom(
                  backgroundColor: textPrimary,
                  foregroundColor: canvas,
                  shape: RoundedRectangleBorder(
                    borderRadius: OTRadius.buttonBorder,
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? AppLoader(dotSize: 6, color: canvas)
                    : Text(
                        'Aktifkan',
                        style: OTTypography.button(color: canvas),
                      ),
              ),
            ),
            const SizedBox(height: OTSpacing.sm),
          ],
        ),
      ),
    );
  }
}

```

### FLUTTER FILE: openturath_ai/lib/widgets/specialist_card.dart
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design/ot_colors.dart';
import 'apple_interactive_wrapper.dart';

/// Minimalist Purism Specialist Card
/// Clean, typographic, rounded corners (16), no icons, no Arabic clutter, no subtitle lines.
class SpecialistCard extends StatelessWidget {
  const SpecialistCard({
    super.key,
    required this.title,
    this.scopeLabel,
    required this.onOpen,
    this.titleArabic,
    this.emoji,
    this.icon,
    this.statusLabel,
    this.onOpenLibrary,
  });

  final String title;
  final String? scopeLabel;
  final String? titleArabic;
  final String? emoji;
  final IconData? icon;
  final String? statusLabel;
  final VoidCallback? onOpen;
  final VoidCallback? onOpenLibrary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = OTColors.surface(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final surfaceSubtle = OTColors.surfaceSubtle(isDark);

    return AppleInteractiveWrapper(
      onTap: onOpen,
      pressedScale: 0.98,
      hapticType: HapticFeedbackType.light,
      borderRadius: BorderRadius.circular(16),
      child: Material(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border, width: 1.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Pure Title & Optional Minimal Status Badge
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: GoogleFonts.newsreader(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                          color: textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (statusLabel != null && statusLabel!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF27272A) : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: isDark ? border : const Color(0xFFFDE68A),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          statusLabel!,
                          style: GoogleFonts.outfit(
                            color: isDark ? textSecondary : const Color(0xFFB45309),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Action Buttons: Optional Pustaka + Chevron
              if (onOpenLibrary != null) ...[
                const SizedBox(width: 8),
                AppleInteractiveWrapper(
                  onTap: onOpenLibrary,
                  pressedScale: 0.94,
                  hapticType: HapticFeedbackType.selection,
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: surfaceSubtle,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: border, width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.menu_book_outlined, size: 13, color: textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          'Pustaka',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              if (onOpen != null) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: textSecondary.withValues(alpha: 0.5),
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

```

### FLUTTER FILE: openturath_ai/lib/widgets/update_ready_banner.dart
```dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../services/update_service.dart';

class UpdateReadyBanner extends StatelessWidget {
  const UpdateReadyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final updateService = UpdateService();

    return AnimatedBuilder(
      animation: updateService,
      builder: (context, _) {
        if (!updateService.isUpdateReady) {
          return const SizedBox.shrink();
        }

        final isDesktop = !kIsWeb && !Platform.isAndroid && !Platform.isIOS;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final surface = isDark ? AppTheme.surfaceCardDark : AppTheme.surfaceCardLight;
        final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
        final textPrimary = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
        final textSecondary = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
        final info = updateService.updateInfo;
        final version = info?.latestVersion ?? '';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            border: Border.all(
              color: border,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.borderDark : AppTheme.pillSecondaryBgLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.system_update_rounded,
                  color: AppTheme.appleGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDesktop ? 'Pembaruan v$version Tersedia' : 'Pembaruan v$version Siap Dipasang',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isDesktop
                          ? 'Ketuk untuk membuka tautan pembaruan versi desktop terbaru.'
                          : 'Selesai diunduh di latar belakang. Ketuk pasang untuk menerapkan.',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: () => updateService.installNow(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.appleGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: const Size(64, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isDesktop ? 'Perbarui' : 'Pasang',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

```



================================================================================
# BAGIAN 5: SUITE PENGUJIAN UNIT & INTEGRASI (openturath_ai/test/)
================================================================================

### TEST FILE: openturath_ai/test/active_subscription_access_test.dart
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/models/user_model.dart';
import 'package:openturath_ai/core/constants.dart';

void main() {
  group('Active Subscription Access Verification', () {
    final futureExpiry = DateTime.now().add(const Duration(days: 365));
    final pastExpiry = DateTime.now().subtract(const Duration(days: 1));

    test('Active subscriber with plan tholib_1m has access to all agents even with empty entitlements', () {
      final user = UserModel(
        uid: 'user_active_tholib',
        name: 'Rafli Husen',
        email: 'chenhuha135@gmail.com',
        photoUrl: '',
        plan: AppConstants.planTholib1m,
        subscriptionExpiry: futureExpiry,
        questionsUsed: 0,
        entitlements: {},
      );

      expect(user.isPremium, isTrue);
      expect(user.isSubscriptionActive, isTrue);
      expect(user.hasAccess, isTrue);
      expect(user.hasAccessToAgent('fiqh_syafii'), isTrue);
      expect(user.hasAccessToAgent('hadits'), isTrue);
      expect(user.hasAccessToAgent('ushul_fiqh'), isTrue);
      expect(user.hasAccessToAgent('nahwu_sharaf'), isTrue);
    });

    test('Active subscriber with plan bahits_1y or tholib_6m has full access', () {
      for (final planName in [AppConstants.planBahits1y, AppConstants.planTholib6m, 'sultan', 'all_ai_1m', 'full']) {
        final user = UserModel(
          uid: 'user_full_$planName',
          name: 'Peneliti',
          email: 'peneliti@example.com',
          photoUrl: '',
          plan: planName,
          subscriptionExpiry: futureExpiry,
          questionsUsed: 0,
          entitlements: {},
        );

        expect(user.isSubscriptionActive, isTrue, reason: planName);
        expect(user.hasAccessToAgent('fiqh_syafii'), isTrue, reason: planName);
        expect(user.hasAccessToAgent('tafsir'), isTrue, reason: planName);
      }
    });

    test('Active subscriber with redeem voucher code has full access', () {
      final user = UserModel(
        uid: 'user_redeem',
        name: 'Santri',
        email: 'santri@example.com',
        photoUrl: '',
        plan: 'redeem_1y',
        subscriptionExpiry: futureExpiry,
        questionsUsed: 0,
        entitlements: {},
      );

      expect(user.isSubscriptionActive, isTrue);
      expect(user.hasAccessToAgent('fiqh_syafii'), isTrue);
    });

    test('Expired subscriber is denied access', () {
      final user = UserModel(
        uid: 'user_expired',
        name: 'Expired User',
        email: 'expired@example.com',
        photoUrl: '',
        plan: AppConstants.planTholib1m,
        subscriptionExpiry: pastExpiry,
        questionsUsed: 0,
        entitlements: {},
      );

      expect(user.isSubscriptionActive, isFalse);
      expect(user.hasAccessToAgent('fiqh_syafii'), isFalse);
    });

    test('Single-module subscriber only has access to entitled module', () {
      final user = UserModel(
        uid: 'user_single',
        name: 'Single User',
        email: 'single@example.com',
        photoUrl: '',
        plan: 'single',
        subscriptionExpiry: futureExpiry,
        questionsUsed: 0,
        entitlements: {
          'fiqh_syafii': ModuleEntitlement(
            plan: 'single',
            expiry: futureExpiry,
            status: 'active',
          ),
        },
      );

      expect(user.isSubscriptionActive, isTrue);
      expect(user.hasAccessToAgent('fiqh_syafii'), isTrue);
      expect(user.hasAccessToAgent('hadits'), isFalse);
    });
  });
}

```

### TEST FILE: openturath_ai/test/application_states_test.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/widgets/app_loader.dart';
import 'package:openturath_ai/widgets/app_error_state.dart';
import 'package:openturath_ai/models/user_model.dart';
import 'package:openturath_ai/core/constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Milestone 4: 14 Application States Verification', () {
    testWidgets('State 2 & 3: AppLoader renders inline and fullscreen pulse states', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppLoader(
              title: 'Menelaah Naskah...',
              subtitle: 'Menghubungkan ke korpus kitab',
            ),
          ),
        ),
      );

      expect(find.text('Menelaah Naskah...'), findsOneWidget);
      expect(find.text('Menghubungkan ke korpus kitab'), findsOneWidget);
    });

    testWidgets('State 9: AppErrorState.network renders peaceful scholarly network error', (tester) async {
      bool retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppErrorState.network(
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('Koneksi Terputus'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);

      await tester.tap(find.text('Coba lagi'));
      expect(retried, isTrue);
    });

    testWidgets('State 10: AppErrorState.unauthorized renders locked module state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppErrorState.unauthorized(),
          ),
        ),
      );

      expect(find.text('Akses Dibatasi'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
    });

    testWidgets('State 7 & 8: AppErrorState.empty renders scholarly empty state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppErrorState.empty(),
          ),
        ),
      );

      expect(find.text('Naskah Tidak Ditemukan'), findsOneWidget);
      expect(find.byIcon(Icons.find_in_page_outlined), findsOneWidget);
    });

    testWidgets('State 11: AppErrorState.generic renders serene fallback state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppErrorState.generic(),
          ),
        ),
      );

      expect(find.text('Terjadi Kendala Teknis'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    test('State 13: Disabled/Locked entitlement check accurately enforces paywall', () {
      final freeUser = UserModel(
        uid: 'user_free',
        name: 'Santri Pemula',
        email: 'santri@openturath.ai',
        photoUrl: '',
        plan: AppConstants.planTrial,
        questionsUsed: 50,
      );

      // Free user without entitlements does not have access to notebook agents
      expect(freeUser.hasAccessToAgent('fiqh_muamalat'), isFalse);
      expect(freeUser.hasAccessToAgent('fiqh_syafii'), isFalse);
    });

    test('State 12: Active selected agent entitlement check allows access for subscribed user', () {
      final futureExpiry = DateTime.now().add(const Duration(days: 30));
      final fullUser = UserModel(
        uid: 'user_subscribed',
        name: 'Kyai Peneliti',
        email: 'kyai@openturath.ai',
        photoUrl: '',
        plan: 'all_access',
        questionsUsed: 5,
        subscriptionExpiry: futureExpiry,
        entitlements: {
          'all_access': ModuleEntitlement(
            plan: 'all_access',
            expiry: futureExpiry,
            status: 'active',
          ),
        },
      );

      expect(fullUser.hasAccessToAgent('fiqh_muamalat'), isTrue);
      expect(fullUser.hasAccessToAgent('fiqh_tahawwulat'), isTrue);
    });
  });
}

```

### TEST FILE: openturath_ai/test/arabic_search_normalization_test.dart
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/arabic_utils.dart';
import 'package:openturath_ai/models/book_model.dart';
import 'package:openturath_ai/services/canonical_library_service.dart';

void main() {
  group('Milestone 2 — Arabic Search Normalization & Scholarly Citations', () {
    test('ArabicUtils strips all diacritics and tatweel', () {
      const withTashkil = 'كِتَابُ الأُمِّ لِلإِمَامِ الشَّافِعِيِّ';
      final normalized = ArabicUtils.normalize(withTashkil);

      // Harakat removed and alif variants normalized to 'ا'
      expect(normalized, isNot(contains('\u064E'))); // Fathah
      expect(normalized, isNot(contains('\u0650'))); // Kasrah
      expect(normalized, isNot(contains('\u064F'))); // Dammah
      expect(normalized, isNot(contains('\u0651'))); // Shaddah
      expect(normalized, equals('كتاب الام للامام الشافعي'));
    });

    test('ArabicUtils unifies alif variants (أ, إ, آ, ٱ -> ا)', () {
      expect(ArabicUtils.normalize('أحمد'), equals('احمد'));
      expect(ArabicUtils.normalize('إبراهيم'), equals('ابراهيم'));
      expect(ArabicUtils.normalize('آدم'), equals('ادم'));
      expect(ArabicUtils.normalize('ٱبن'), equals('ابن'));
    });

    test('ArabicUtils unifies Ta Marbuthah and Ya Makhfufah', () {
      expect(ArabicUtils.normalize('رسالة'), equals('رساله'));
      expect(ArabicUtils.normalize('موسى'), equals('موسي'));
      expect(ArabicUtils.normalize('فتوى'), equals('فتوي'));
    });

    test('ArabicUtils.matches matches text with and without harakat', () {
      const source = 'الإِمَامُ أَبُو حَامِدٍ الغَزَالِيُّ';
      expect(ArabicUtils.matches(source, 'الغزالي'), isTrue);
      expect(ArabicUtils.matches(source, 'أبو حامد'), isTrue);
      expect(ArabicUtils.matches(source, 'ابو حامد'), isTrue); // Bare alif matches
      expect(ArabicUtils.matches(source, 'الامام'), isTrue); // Bare alif matches
    });

    test('CanonicalLibraryService.filterBooks finds books with diacritic variations', () {
      final books = [
        const CanonicalBookPresentation(
          editionId: 'umm',
          titleArabic: 'كِتَابُ الأُمِّ',
          authorArabic: 'الإِمَامُ مُحَمَّدُ بْنُ إِدْرِيسَ الشَّافِعِيُّ',
          titleLatin: 'Kitab Al-Umm',
          authorLatin: 'Imam Asy-Syafi\'i',
          reviewedEraLabel: 'Mutaqaddimin',
          reviewedTypeLabel: 'Asal Mazhab',
          publisher: 'Darul Kutub Al-Ilmiyyah',
          muhaqqiq: 'Dr. Rifa\'at',
        ),
        const CanonicalBookPresentation(
          editionId: 'tanbih',
          titleArabic: 'التَّنْبِيهُ فِي الفِقْهِ الشَّافِعِيِّ',
          authorArabic: 'أَبُو إِسْحَاقَ الشِّيرَازِيُّ',
          titleLatin: 'At-Tanbih',
          reviewedEraLabel: 'Mutaqaddimin',
          reviewedTypeLabel: 'Matan',
        ),
      ];

      final service = CanonicalLibraryService.instance;

      // Search with bare alif 'الام'
      final res1 = service.filterBooks(books, 'الام');
      expect(res1.length, equals(1));
      expect(res1.first.editionId, equals('umm'));

      // Search with unvowelled 'الشافعي'
      final res2 = service.filterBooks(books, 'الشافعي');
      expect(res2.length, equals(2)); // Both mention Syafi'i (author / title)

      // Search with unvowelled 'الشيرازي'
      final res3 = service.filterBooks(books, 'الشيرازي');
      expect(res3.length, equals(1));
      expect(res3.first.editionId, equals('tanbih'));

      // Search by publisher
      final res4 = service.filterBooks(books, 'Ilmiyyah');
      expect(res4.length, equals(1));
      expect(res4.first.editionId, equals('umm'));

      // Search by muhaqqiq
      final res5 = service.filterBooks(books, 'Rifa\'at');
      expect(res5.length, equals(1));
      expect(res5.first.editionId, equals('umm'));
    });
  });
}

```

### TEST FILE: openturath_ai/test/audit_auth_stream_test.dart
```dart
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/services/session_user_stream.dart';

Future<void> tick() => Future<void>.delayed(Duration.zero);
void main() {
  test('A09 delayed old cache cannot emit or subscribe after logout', () async {
    final auth = StreamController<String?>.broadcast(sync: true);
    final oldCache = Completer<String?>();
    final watched = <String>[];
    final stream = sessionUserStream<String>(
      auth: auth.stream,
      cached: (uid) => oldCache.future,
      watch: (uid) { watched.add(uid); return const Stream<String?>.empty(); },
    );
    final values = <String?>[];
    final sub = stream.listen(values.add);
    auth.add('A');
    await tick();
    auth.add(null);
    await tick();
    oldCache.complete('A cached');
    await tick();
    expect(values.last, isNull);
    expect(values, isNot(contains('A cached')));
    expect(watched, isEmpty);
    await sub.cancel();
    await auth.close();
  });
  test('A09 final cancellation invalidates pending cache and later listeners restart', () async {
    final auth = StreamController<String?>.broadcast(sync: true);
    final cache = Completer<String?>();
    var watches = 0;
    final stream = sessionUserStream<String>(auth: auth.stream, cached: (_) => cache.future,
      watch: (_) { watches++; return const Stream<String?>.empty(); });
    final sub = stream.listen((_) {});
    auth.add('A');
    await tick();
    await sub.cancel();
    cache.complete('A');
    await tick();
    expect(watches, 0);
    final values = <String?>[];
    final next = stream.listen(values.add);
    auth.add(null);
    await tick();
    expect(values.last, isNull);
    await next.cancel();
    await auth.close();
  });
}

```

### TEST FILE: openturath_ai/test/audit_checkout_completion_test.dart
```dart
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/checkout_completion.dart';
void main() {
  test('A12 completion dismisses confirmation before closing checkout exactly once', () async {
    final gate = CheckoutCompletion();
    final events = <String>[];
    final done = Completer<void>();
    gate.confirmation = done.future;
    final first = gate.finish(dismissConfirmation: () { events.add('dialog'); done.complete(); },
      closeCheckout: () => events.add('checkout'));
    final second = gate.finish(dismissConfirmation: () => events.add('duplicate'),
      closeCheckout: () => events.add('duplicate'));
    await Future.wait([first, second]);
    expect(events, ['dialog', 'checkout']);
  });
}

```

### TEST FILE: openturath_ai/test/audit_entitlement_test.dart
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/models/user_model.dart';

void main() {
  ModuleEntitlement entitlement({String status = 'active'}) => ModuleEntitlement(
    plan: 'tholib_1m', status: status, expiry: DateTime.now().add(const Duration(days: 1)));
  UserModel user(Map<String, ModuleEntitlement> entitlements) => UserModel(
    uid: 'u', name: 'U', email: 'u@example.test', photoUrl: '', plan: 'trial',
    questionsUsed: 0, entitlements: entitlements);
  test('A10 specific paid module survives revoked all-access', () {
    final u = user({'all_access': entitlement(status: 'revoked'), 'hadits': entitlement()});
    expect(u.hasAccessToAgent('hadits'), isTrue);
    expect(u.hasAccessToAgent('tafsir'), isFalse);
  });
  test('A10 all language aliases use the same canonical entitlement', () {
    final u = user({'nahwu': entitlement()});
    for (final id in ['nahwu_sharaf', 'bahasa_arab', 'lughah_nahwu', 'lughah_mujam']) {
      expect(u.hasAccessToAgent(id), isTrue, reason: id);
    }
  });
  test('A10 unrelated prefix cannot open a new module', () {
    expect(user({'fiqh': entitlement()}).hasAccessToAgent('fiqh_syafii'), isFalse);
  });
}

```

### TEST FILE: openturath_ai/test/audit_navigation_test.dart
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/notebook_navigation.dart';
void main() {
  test('A11 exact HTTPS authentication hosts allowed', () {
    for (final host in ['notebooklm.google.com', 'accounts.google.com', 'accounts.youtube.com']) {
      expect(NotebookNavigation.allowed(Uri.parse('https://$host/')), isTrue);
    }
  });
  test('A11 user content origins, custom ports and deceptive URLs blocked', () {
    for (final url in ['https://sites.google.com/site/phishing',
      'https://evil.googleusercontent.com/', 'https://accounts.google.com.evil.test/',
      'https://user@accounts.google.com/', 'https://accounts.google.com:8443/',
      'http://accounts.google.com/', 'javascript:alert(1)', 'file:///etc/passwd']) {
      expect(NotebookNavigation.allowed(Uri.parse(url)), isFalse, reason: url);
    }
  });
}

```

### TEST FILE: openturath_ai/test/audit_storage_test.dart
```dart
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/services/scoped_json_store.dart';

class MemoryStrings implements StringStore {
  final values = <String, String>{};
  bool fail = false;
  Completer<void>? gate;
  int writes = 0;
  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<bool> write(String key, String value) async {
    writes++;
    await gate?.future;
    if (fail) return false;
    values[key] = value;
    return true;
  }
}

void main() {
  ScopedJsonListStore<String> store(MemoryStrings io) => ScopedJsonListStore(
    storage: io, decode: (map) => map['value'] as String,
    encode: (value) => {'value': value},
  );
  test('A07 values never cross account keys or caller mutation', () async {
    final io = MemoryStrings();
    final data = store(io);
    await data.replace('user-a', ['private']);
    expect(await data.read('user-b'), isEmpty);
    final a = await data.read('user-a');
    a.clear();
    expect(await data.read('user-a'), ['private']);
  });
  test('A08 parallel updates through separate instances preserve both records', () async {
    final io = MemoryStrings();
    final a = store(io);
    final b = store(io);
    await Future.wait([
      a.update('notes', (rows) => rows..add('A')),
      b.update('notes', (rows) => rows..add('B')),
    ]);
    expect(await a.read('notes'), ['A', 'B']);
  });
  testWidgets('A08 slow write does not release exclusion after five seconds', (tester) async {
    final io = MemoryStrings()..gate = Completer<void>();
    final data = store(io);
    final first = data.replace('slow', ['A']);
    final next = data.update('slow', (rows) => rows..add('B'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 6));
    expect(io.writes, 1);
    io.gate!.complete();
    await tester.pump();
    await Future.wait([first, next]);
    expect(await data.read('slow'), ['A', 'B']);
  });
  test('A08 failed write surfaces error and releases queue', () async {
    final io = MemoryStrings()..fail = true;
    final data = store(io);
    await expectLater(data.replace('k', ['lost']), throwsStateError);
    io.fail = false;
    await data.replace('k', ['saved']);
    expect(await data.read('k'), ['saved']);
  });
  test('A07 corrupted payload is preserved before any replacement', () async {
    final io = MemoryStrings()..values['a'] = '[broken';
    final data = store(io);
    await data.update('a', (rows) => rows..add('new'));
    expect(io.values.entries.where((e) => e.key.startsWith('a_corrupt_')).single.value, '[broken');
    expect(await data.read('b'), isEmpty);
  });
  test('A07 failed quarantine prevents overwriting corrupt original', () async {
    final io = MemoryStrings()..values['a'] = '[broken'..fail = true;
    await expectLater(store(io).replace('a', ['new']), throwsStateError);
    expect(io.values['a'], '[broken');
  });
}

```

### TEST FILE: openturath_ai/test/book_catalog_navigation_test.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/routes.dart';
import 'package:openturath_ai/models/book_model.dart';
import 'package:openturath_ai/screens/book_catalog_screen.dart';
import 'package:openturath_ai/screens/book_detail_screen.dart';
import 'package:openturath_ai/widgets/book_row_item.dart';

void main() {
  group('Milestone 1 — Book Catalog & Navigation Architecture', () {
    final sampleBook = CanonicalBookPresentation(
      editionId: 'kitab_al_umm_shafii',
      titleArabic: 'كتاب الأم',
      authorArabic: 'الإمام محمد بن إدريس الشافعي',
      titleLatin: 'Kitab Al-Umm',
      authorLatin: 'Imam Muhammad bin Idris Asy-Syafi\'i',
      verifiedDeathYearHijri: 204,
      reviewedTypeLabel: 'Asal Mazhab',
      reviewedEraLabel: 'Mutaqaddimin',
      publisher: 'Darul Kutub Al-Ilmiyyah',
      muhaqqiq: 'Dr. Rifa\'at Fauzi Abdul Muthalib',
      volumesCount: 8,
    );

    testWidgets('BookRowItem displays Arabic title in RTL and compact tags', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookRowItem(
              book: sampleBook,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      // Verify Arabic Title and author
      expect(find.text('كتاب الأم'), findsOneWidget);
      expect(find.text('الإمام محمد بن إدريس الشافعي'), findsOneWidget);
      expect(find.text('w. 204 H'), findsOneWidget);
      expect(find.text('Asal Mazhab'), findsOneWidget);
      expect(find.text('Mutaqaddimin'), findsOneWidget);
      expect(find.text('8 Jilid'), findsOneWidget);

      // Tap the item
      await tester.tap(find.byType(BookRowItem));
      expect(tapped, isTrue);
    });

    testWidgets('BookDetailScreen renders 5 scholarly metadata sections', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BookDetailScreen(book: sampleBook),
        ),
      );

      // Card 1: Identitas Kitab
      expect(find.text('كتاب الأم'), findsOneWidget);
      expect(find.text('kitab_al_umm_shafii'), findsOneWidget);

      // Card 2: Muallif
      expect(find.text('MUALLIF / PENGARANG'), findsOneWidget);
      expect(find.text('الإمام محمد بن إدريس الشافعي'), findsOneWidget);

      // Card 3: Klasifikasi Ilmiah
      expect(find.text('KLASIFIKASI ILMIAH'), findsOneWidget);
      expect(find.text('Asal Mazhab'), findsOneWidget);
      expect(find.text('Mutaqaddimin'), findsOneWidget);
      expect(find.text('8 Jilid'), findsOneWidget);

      // Card 4: Data Edisi & Tahqiq
      expect(find.text('DATA EDISI & TAHQIQ'), findsOneWidget);
      expect(find.text('Darul Kutub Al-Ilmiyyah'), findsOneWidget);
      expect(find.text('Dr. Rifa\'at Fauzi Abdul Muthalib'), findsOneWidget);

      // Card 5: Aksi Riset
      expect(find.text('AKSI & TELAAH RISET'), findsOneWidget);
      expect(find.text('Buka Ruang Kajian'), findsOneWidget);
      expect(find.text('Simpan ke Catatan Riset'), findsOneWidget);
    });

    testWidgets('BookCatalogScreen displays title and search input', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BookCatalogScreen(),
        ),
      );

      expect(find.text('Pustaka Kitab Kanonikal'), findsOneWidget);
      expect(find.text('87 Kitab Mazhab Syafi\'i'), findsOneWidget);
      expect(find.text('Semua Era'), findsOneWidget);
    });

    testWidgets('AppRoutes contains bookCatalog and bookDetail', (tester) async {
      expect(AppRoutes.bookCatalog, equals('/catalog'));
      expect(AppRoutes.bookDetail, equals('/book_detail'));
    });
  });
}

```

### TEST FILE: openturath_ai/test/canonical_catalog_test.dart
```dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/models/book_model.dart';

void main() {
  group('Canonical Syafi\'i Catalog Parser Tests', () {
    test('parses canonical_syafii.json correctly with 87 entries', () {
      final file = File('assets/data/canonical_syafii.json');
      expect(file.existsSync(), isTrue, reason: 'assets/data/canonical_syafii.json must exist');

      final content = file.readAsStringSync();
      final result = parseCanonicalCatalog(content);

      expect(result.entries.isNotEmpty, isTrue);
      expect(result.entries.length, equals(87), reason: 'Expected 87 canonical books');
      expect(result.issues.isEmpty, isTrue, reason: 'Expected 0 format issues in catalog: ${result.issues}');

      // Verify sample entry: Al-Umm
      final alUmm = result.entries.firstWhere((e) => e.shortTitleArabic == 'الأم');
      expect(alUmm.titleArabic, equals('الأم'));
      expect(alUmm.authorArabic, equals('الإمام الشافعي'));
      expect(alUmm.recordedDeathYearHijri, equals(204));
      expect(alUmm.recordedVolumes, equals(8));
      expect(alUmm.publisher, isNotNull);

      // Verify Presentation conversion does not leak raw authority badges prematurely
      final presentation = CanonicalBookPresentation.fromEntry(alUmm);
      expect(presentation.reviewedAuthorityLabel, isNull);
      expect(presentation.canShowAuthority, isFalse);
      expect(presentation.reviewedTypeLabel, equals('Asal Mazhab'));
      expect(presentation.reviewedEraLabel, equals('Mutaqaddimin'));
      expect(presentation.compactLabels, contains('Asal Mazhab'));
      expect(presentation.compactLabels, contains('8 Jilid'));
    });
  });
}

```

### TEST FILE: openturath_ai/test/copied_answer_test.dart
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:openturath_ai/core/copied_answer.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/services/bookmark_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('Copied answer persists in Saved, keeps full text, and never crosses accounts', () async {
    final service = BookmarkService();
    final agent = AgentModel.defaultAgents.first;
    final answer = copiedAnswerBookmark('Jawaban pertama\nالنص العربي', agent);
    await service.addBookmark(answer, userId: 'alice');
    final saved = await service.getBookmarks(userId: 'alice');
    expect(saved.single.fullAnswer, 'Jawaban pertama\nالنص العربي');
    expect(saved.single.agentId, agent.id);
    expect(await service.getBookmarks(userId: 'bob'), isEmpty);
  });
  test('Repeated copy deduplicates but different answers and assistants stay separate', () async {
    final service = BookmarkService();
    final agents = AgentModel.defaultAgents;
    for (var i = 0; i < 2; i++) {
      await service.addBookmark(copiedAnswerBookmark('Jawaban satu', agents.first), userId: 'alice');
    }
    expect((await service.getBookmarks(userId: 'alice')).length, 1);
    await service.addBookmark(copiedAnswerBookmark('Jawaban dua', agents.first), userId: 'alice');
    await service.addBookmark(copiedAnswerBookmark('Jawaban satu', agents[1]), userId: 'alice');
    expect((await service.getBookmarks(userId: 'alice')).length, 3);
  });
  test('Empty copies cannot create a saved item', () {
    expect(() => copiedAnswerBookmark('  ', AgentModel.defaultAgents.first), throwsArgumentError);
  });
}

```

### TEST FILE: openturath_ai/test/copywriting_test.dart
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_copy.dart';
import 'package:openturath_ai/models/agent_model.dart';

void main() {
  group('OpenTurath Copywriting Overhaul — Quiet Scholar Principles', () {
    test('Canonical navigation labels use concise, quiet terms', () {
      expect(AppCopy.navHome, equals('Beranda'));
      expect(AppCopy.navStudies, equals('Asisten AI'));
      expect(AppCopy.navSaved, equals('Tersimpan'));
      expect(AppCopy.navSettings, equals('Pengaturan'));
    });

    test('Canonical app name and tagline are concise and avoid superlatives', () {
      expect(AppCopy.appName, equals('OpenTurath'));
      expect(AppCopy.appTagline, equals('Membaca kitab, menelusuri ibarah.'));
    });

    test('Success toasts never use exclamation marks (!)', () {
      expect(AppCopy.savedSuccess.contains('!'), isFalse,
          reason: 'Success messages should be calm and not use exclamation marks');
      expect(AppCopy.answerCopied.contains('!'), isFalse,
          reason: 'Copy action should be quiet and not use exclamation marks');
      expect(AppCopy.deleteAccountSuccess.contains('!'), isFalse);
    });

    test('Public strings do not contain prohibited marketing or academic jargon', () {
      final prohibitedWords = [
        'korpus',
        'penelaahan',
        'fasilitas',
        'komprehensif',
        'secara menyeluruh',
        'berbasis',
        'terintegrasi',
        'optimal',
        'presisi',
        'solusi',
      ];

      final samplePublicStrings = [
        AppCopy.aboutDescription,
        AppCopy.aboutScholarlyPrinciple,
        AppCopy.adabHeading1,
        AppCopy.adabBody1,
        AppCopy.adabHeading2,
        AppCopy.adabBody2,
        AppCopy.deviceNotSupportedTitle,
        AppCopy.deviceNotSupportedMessage,
        AppCopy.cannotConnectTitle,
        AppCopy.cannotConnectMessage,
        AppCopy.noSavedTitle,
        AppCopy.noSavedDescription,
        AppCopy.catalogLoadFailed,
        AppCopy.activeSubscription,
        AppCopy.inactiveSubscription,
      ];

      for (final text in samplePublicStrings) {
        final lower = text.toLowerCase();
        for (final word in prohibitedWords) {
          expect(lower.contains(word), isFalse,
              reason: 'String "$text" should not contain prohibited word "$word"');
        }
      }
    });

    test('AgentModel defaultAgents descriptions and titles avoid banned jargon', () {
      final prohibitedInAgents = [
        'korpus',
        'fasilitas',
        'komprehensif',
        'secara menyeluruh',
        'solusi',
        'optimal',
      ];

      for (final agent in AgentModel.defaultAgents) {
        final refTitles = (agent.referenceBooks ?? []).map((b) => '${b.title} ${b.description}').join(' ');
        final combined = '${agent.title} ${agent.description} $refTitles'.toLowerCase();
        for (final word in prohibitedInAgents) {
          expect(combined.contains(word), isFalse,
              reason: 'Agent ${agent.id} contains prohibited word "$word": $combined');
        }
      }
    });

    test('Dynamic interpolation helpers produce serene, well-formed phrases', () {
      expect(AppCopy.preparingModule('Fikih Syafi\'i'),
          equals('Fikih Syafi\'i sedang disiapkan.'));
      expect(AppCopy.subscriptionRequiredFor('Fikih Syafi\'i'),
          equals('Berlangganan untuk membuka Fikih Syafi\'i.'));
      expect(AppCopy.accessUnavailableFor('Fikih Syafi\'i'),
          equals('Akun ini belum mendapat akses ke Fikih Syafi\'i. Aktifkan langganan untuk melanjutkan.'));
      expect(AppCopy.planWithAgent('Fikih Syafi\'i', '1 Bulan'),
          equals('Fikih Syafi\'i — 1 Bulan'));
    });
  });
}

```

### TEST FILE: openturath_ai/test/dashboard_and_theme_restructure_test.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/hijri_date_utils.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/models/bookmark_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Milestone 3: 3-Mode Theme & Dashboard Restructuring', () {
    test('AppConfig supports ThemeMode.system, ThemeMode.light, and ThemeMode.dark', () async {
      await AppConfig.setThemeMode(ThemeMode.light);
      expect(AppConfig.themeNotifier.value, ThemeMode.light);

      await AppConfig.setThemeMode(ThemeMode.dark);
      expect(AppConfig.themeNotifier.value, ThemeMode.dark);

      await AppConfig.setThemeMode(ThemeMode.system);
      expect(AppConfig.themeNotifier.value, ThemeMode.system);
    });

    test('HijriDateUtils formatDualDate produces elegant scholarly date with H and M', () {
      final now = DateTime(2026, 9, 12);
      final dual = HijriDateUtils.formatDualDate(now);
      expect(dual.contains('H'), isTrue);
      expect(dual.contains('M'), isTrue);
      expect(dual.contains('•'), isTrue);
      expect(dual.contains('September'), isTrue);
      expect(dual.contains('2026'), isTrue);
    });

    test('HijriDateUtils formatHijriOnly produces valid Hijri format', () {
      final now = DateTime(2026, 9, 12);
      final hijriOnly = HijriDateUtils.formatHijriOnly(now);
      expect(hijriOnly.contains('H'), isTrue);
      expect(hijriOnly.isNotEmpty, isTrue);
    });

    test('Dashboard resume session selects matching active agent when last opened exists', () {
      final agents = AgentModel.defaultAgents;
      final target = agents.firstWhere((a) => a.id == 'fiqh_syafii');
      final lastOpenedId = target.id;

      final matched = agents.where((a) => a.id == lastOpenedId && a.isActive).firstOrNull;
      expect(matched, isNotNull);
      expect(matched!.id, 'fiqh_syafii');
    });

    test('Recent notes can store and format canonical book and ibarah citations', () {
      final note1 = BookmarkModel(
        id: 'book_minhaj_al_talibin',
        title: 'منهاج الطالبين وعمدة المفتين',
        agentId: 'fiqh_syafii',
        agentTitle: 'Spesialis Fiqh Syafi\'i',
        fieldName: 'Fikih',
        fieldId: 'fiqh',
        arabicExcerpt: 'كتاب الطهارة: يرفع الحدث وينجس الخbث بالماء المطلق',
        fullAnswer: 'Teks asal bab Thaharah',
        bookReference: 'Minhaj al-Talibin',
        pageNumber: '12',
        author: 'Imam an-Nawawi',
        createdAt: DateTime.now(),
      );

      expect(note1.id.startsWith('book_'), isTrue);
      expect(note1.author, 'Imam an-Nawawi');
      expect(note1.bookReference, 'Minhaj al-Talibin');
    });
  });
}

```

### TEST FILE: openturath_ai/test/deep_test.dart
```dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/arabic_utils.dart';
import 'package:openturath_ai/core/localization.dart';
import 'package:openturath_ai/core/theme.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/models/book_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('1. Asset Files & Animation Integrity Tests', () {
    test('All Lottie JSON animation files are valid and parseable', () {
      final dir = Directory('assets/animations');
      expect(dir.existsSync(), isTrue, reason: 'assets/animations directory must exist');

      final files = dir.listSync().whereType<File>().where((f) => f.path.endsWith('.json'));
      expect(files.isNotEmpty, isTrue, reason: 'Must contain Lottie JSON animation files');

      for (final file in files) {
        final content = file.readAsStringSync();
        expect(content.isNotEmpty, isTrue, reason: '${file.path} must not be empty');

        final dynamic decoded = jsonDecode(content);
        expect(decoded, isA<Map<String, dynamic>>(), reason: '${file.path} must be valid JSON object');
        final map = decoded as Map<String, dynamic>;
        expect(map.containsKey('v') || map.containsKey('layers') || map.containsKey('fr'), isTrue,
            reason: '${file.path} must have valid Lottie animation structure');
      }
    });

    test('All SVG vector files are valid XML and well-formed', () {
      final dir = Directory('assets/images');
      expect(dir.existsSync(), isTrue, reason: 'assets/images directory must exist');

      final files = dir.listSync().whereType<File>().where((f) => f.path.endsWith('.svg'));
      expect(files.isNotEmpty, isTrue, reason: 'Must contain SVG files');

      for (final file in files) {
        final content = file.readAsStringSync().trim();
        expect(content.isNotEmpty, isTrue, reason: '${file.path} must not be empty');
        expect(content.contains('<svg') && content.contains('</svg>'), isTrue,
            reason: '${file.path} must contain valid <svg> tags');
      }
    });

    test('Core official Google NotebookLM SVGs and Lottie files are present', () {
      const requiredFiles = [
        'assets/images/notebooklm_round.svg',
        'assets/images/gemini_notebook_with_text_only_light.svg',
        'assets/images/gemini_notebook_with_text_only_dark.svg',
        'assets/animations/thinking_ux_icon_looping.json',
      ];

      for (final path in requiredFiles) {
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: 'Required official asset $path must exist on disk');
        expect(file.lengthSync() > 100, isTrue, reason: 'Asset $path must not be an empty dummy stub');
      }
    });

    test('Old raster logo_openturath.png is permanently eliminated', () {
      final oldLogo = File('assets/images/logo_openturath.png');
      expect(oldLogo.existsSync(), isFalse, reason: 'Old logo must not exist');
    });
  });

  group('2. Design System & Theme Engine Invariants', () {
    test('Official Google NotebookLM color tokens are exact', () {
      expect(AppTheme.canvasLight, equals(const Color(0xFFFFFFFF)));
      expect(AppTheme.canvasDark, equals(const Color(0xFF0E0E10)));
      expect(AppTheme.surfaceCardLight, equals(const Color(0xFFFFFFFF)));
      expect(AppTheme.surfaceCardDark, equals(const Color(0xFF18181B)));
      expect(AppTheme.borderLight, equals(const Color(0xFFE5E7EB)));
      expect(AppTheme.borderDark, equals(const Color(0xFF27272A)));
      expect(AppTheme.accentLight, equals(const Color(0xFF18181B)));
      expect(AppTheme.accentDark, equals(const Color(0xFF60A5FA)));
      expect(AppTheme.citationBgLight, equals(const Color(0xFFF1F5F9)));
      expect(AppTheme.citationBgDark, equals(const Color(0xFF1E1E22)));
    });

    test('Radius tokens conform to Apple HIG 3-token system', () {
      expect(AppTheme.radiusPill, equals(100.0));
      expect(AppTheme.radiusFull, equals(100.0));
      expect(AppTheme.radiusXS, equals(8.0));
      expect(AppTheme.radiusCard, equals(16.0));
      expect(AppTheme.radiusM, equals(16.0));
      expect(AppTheme.radiusS, equals(8.0));
    });
  });

  group('3. Agent Catalog & Module Entitlements Tests', () {
    test('Default catalog contains core Turats disciplines with full metadata', () {
      final agents = AgentModel.defaultAgents;
      expect(agents.length, greaterThanOrEqualTo(5));

      for (final a in agents) {
        expect(a.id, isNotEmpty, reason: 'Agent ID must not be empty');
        expect(a.title, isNotEmpty, reason: 'Agent Title must not be empty');
        expect(a.titleArabic, isNotEmpty, reason: 'Agent Arabic Title must not be empty');
        expect(a.category, isNotEmpty, reason: 'Agent Category must not be empty');

        if (a.isActive) {
          expect(a.price1m, isNotNull, reason: 'Active agent must have pricing configured');
          expect(a.price1m! > 0, isTrue);
        }
      }
    });

    test('Active agent books contain valid titles, authors, and descriptions', () {
      final activeAgents = AgentModel.defaultAgents.where((a) => a.isActive);
      expect(activeAgents.isNotEmpty, isTrue);

      for (final a in activeAgents) {
        for (final BookModel b in a.referenceBooks!) {
          expect(b.title, isNotEmpty);
          expect(b.titleArabic, isNotEmpty);
          expect(b.author, isNotEmpty);
        }
      }
    });

    test('Sub-agents represent valid specialized research modes', () {
      for (final a in AgentModel.defaultAgents) {
        if (a.subAgents != null && a.subAgents!.isNotEmpty) {
          for (final sub in a.subAgents!) {
            expect(sub.id, isNotEmpty);
            expect(sub.name, isNotEmpty);
            expect(sub.nameArabic, isNotEmpty);
            expect(sub.description, isNotEmpty);
            expect(sub.emoji, isNotEmpty);
          }
        }
      }
    });
  });

  group('4. Smart Arabic Search & Text Normalization Tests', () {
    test('Arabic diacritics stripping is exhaustive', () {
      const input = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';
      final cleaned = ArabicUtils.normalize(input);
      expect(cleaned, equals('بسم الله الرحمن الرحيم'));
    });

    test('Alef variations are unified to bare alef', () {
      expect(ArabicUtils.normalize('إِسْلَام'), equals('اسلام'));
      expect(ArabicUtils.normalize('أُصُول'), equals('اصول'));
      expect(ArabicUtils.normalize('آدَاب'), equals('اداب'));
    });

    test('Arabic search correctly finds substrings regardless of voweling', () {
      const text = 'مَتْنُ سَفِينَةِ النَّجَاةِ فِي أُصُولِ الدِّينِ وَالْفِقْهِ';
      expect(ArabicUtils.matches(text, 'سفينة'), isTrue);
      expect(ArabicUtils.matches(text, 'النجاة'), isTrue);
      expect(ArabicUtils.matches(text, 'اصول'), isTrue);
      expect(ArabicUtils.matches(text, 'الفقه'), isTrue);
      expect(ArabicUtils.matches(text, 'بخاري'), isFalse);
    });
  });

  group('5. Localization Dictionary Exhaustive Tests', () {
    test('All language keys exist across Indonesian, English, and Arabic', () {
      final keys = [
        'app_name',
        'choose_plan',
        'save',
        'cancel',
        'settings',
        'theme_mode',
        'theme_system',
        'theme_light',
        'theme_dark',
        'language',
      ];

      for (final key in keys) {
        expect(Loc.tr(key), isNotEmpty, reason: 'Key "$key" must be translated');
      }
    });
  });
}

```

### TEST FILE: openturath_ai/test/design_system_test.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openturath_ai/core/design/ot_colors.dart';
import 'package:openturath_ai/core/design/ot_typography.dart';
import 'package:openturath_ai/core/design/ot_radius.dart';
import 'package:openturath_ai/core/design/ot_motion.dart';
import 'package:openturath_ai/core/design/ot_spacing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  OTTypography.useSystemFontFallback = true;

  group('Quiet Scholar Design System — Tokens Suite', () {
    test('OTColors provides calm, scholarly palettes without gold leaks', () {
      // 1. Light palette checks
      expect(OTColors.canvasLight, const Color(0xFFFAFAF9));
      expect(OTColors.surfaceLight, const Color(0xFFFFFFFF));
      expect(OTColors.textPrimaryLight, const Color(0xFF18181B));
      expect(OTColors.textSecondaryLight, const Color(0xFF52525B));

      // 2. Dark palette checks
      expect(OTColors.canvasDark, const Color(0xFF0E0E10));
      expect(OTColors.surfaceDark, const Color(0xFF18181B));
      expect(OTColors.textPrimaryDark, const Color(0xFFFAFAFA));
      expect(OTColors.textSecondaryDark, const Color(0xFFA1A1AA));

      // 3. Scholarly sapphire accents
      expect(OTColors.accentLight, const Color(0xFF2563EB));
      expect(OTColors.accentDark, const Color(0xFF60A5FA));

      // 4. Adaptive context helpers
      expect(OTColors.canvas(false), OTColors.canvasLight);
      expect(OTColors.canvas(true), OTColors.canvasDark);
      expect(OTColors.surface(false), OTColors.surfaceLight);
      expect(OTColors.surface(true), OTColors.surfaceDark);
      expect(OTColors.textPrimary(false), OTColors.textPrimaryLight);
      expect(OTColors.textPrimary(true), OTColors.textPrimaryDark);
      expect(OTColors.textSecondary(false), OTColors.textSecondaryLight);
      expect(OTColors.textSecondary(true), OTColors.textSecondaryDark);
      expect(OTColors.accent(false), OTColors.accentLight);
      expect(OTColors.accent(true), OTColors.accentDark);
    });

    test('OTTypography strictly separates Brand, Interface, and Arabic layers', () {
      // 1. Brand / Editorial layer (Newsreader)
      final brand = OTTypography.brandLogo();
      expect(brand.fontSize, 22);
      expect(brand.fontWeight, FontWeight.w600);

      final hero = OTTypography.editorialHero();
      expect(hero.fontSize, 26);
      expect(hero.fontWeight, FontWeight.w600);
      expect(hero.height, 1.25);

      final corpus = OTTypography.corpusTitle();
      expect(corpus.fontSize, 18);
      expect(corpus.fontWeight, FontWeight.w600);

      // 2. Interface layer (Outfit)
      final screen = OTTypography.screenTitle();
      expect(screen.fontSize, 20);
      expect(screen.fontWeight, FontWeight.w600);

      final card = OTTypography.cardTitle();
      expect(card.fontSize, 15);
      expect(card.fontWeight, FontWeight.w600);

      final body = OTTypography.body();
      expect(body.fontSize, 14);
      expect(body.fontWeight, FontWeight.w400);

      final caption = OTTypography.caption();
      expect(caption.fontSize, 12);

      final button = OTTypography.button();
      expect(button.fontSize, 14);
      expect(button.fontWeight, FontWeight.w600);

      // 3. Arabic Scholarly layer (Amiri)
      final arDisplay = OTTypography.arabicDisplay();
      expect(arDisplay.fontSize, 24);
      expect(arDisplay.fontWeight, FontWeight.w700);
      expect(arDisplay.height, 1.6);

      final arReading = OTTypography.arabicReading();
      expect(arReading.fontSize, 19);
      expect(arReading.fontWeight, FontWeight.w500);
      expect(arReading.height, 1.75);

      final arQuote = OTTypography.arabicQuote();
      expect(arQuote.fontSize, 16);
      expect(arQuote.height, 1.8);
    });

    test('OTRadius enforces disciplined curvature without bubble-boxing', () {
      expect(OTRadius.input, 14.0);
      expect(OTRadius.card, 16.0);
      expect(OTRadius.sheet, 24.0);
      expect(OTRadius.dialog, 20.0);
      expect(OTRadius.chip, 999.0);
      expect(OTRadius.button, 999.0);

      expect(OTRadius.inputBorder, BorderRadius.circular(14.0));
      expect(OTRadius.cardBorder, BorderRadius.circular(16.0));
      expect(OTRadius.dialogBorder, BorderRadius.circular(20.0));
      expect(OTRadius.chipBorder, BorderRadius.circular(999.0));
      expect(OTRadius.buttonBorder, BorderRadius.circular(999.0));
    });

    test('OTMotion provides quiet, restrained animations and easing', () {
      expect(OTMotion.fast, const Duration(milliseconds: 180));
      expect(OTMotion.normal, const Duration(milliseconds: 220));
      expect(OTMotion.sheet, const Duration(milliseconds: 280));
      expect(OTMotion.transition, const Duration(milliseconds: 320));

      expect(OTMotion.curve, Curves.easeOutCubic);
      expect(OTMotion.sheetCurve, Curves.easeOutQuart);
    });

    test('OTSpacing maintains strict base-4 rhythm', () {
      expect(OTSpacing.xs, 4.0);
      expect(OTSpacing.sm, 8.0);
      expect(OTSpacing.md, 12.0);
      expect(OTSpacing.base, 16.0);
      expect(OTSpacing.lg, 20.0);
      expect(OTSpacing.xl, 24.0);
      expect(OTSpacing.xxl, 32.0);
      expect(OTSpacing.huge, 40.0);
      expect(OTSpacing.massive, 48.0);
      expect(OTSpacing.jumbo, 64.0);

      // Verify all spacing values are strictly divisible by 4
      for (final val in [
        OTSpacing.xs,
        OTSpacing.sm,
        OTSpacing.md,
        OTSpacing.base,
        OTSpacing.lg,
        OTSpacing.xl,
        OTSpacing.xxl,
        OTSpacing.huge,
        OTSpacing.massive,
        OTSpacing.jumbo,
      ]) {
        expect(val % 4.0, 0.0);
      }
    });
  });
}

```

### TEST FILE: openturath_ai/test/doku_direct_test.dart
```dart
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DOKU Signature generation satisfies DOKU HMACSHA256 protocol specification', () {
    const clientId = 'TEST-CLIENT-ID-123';
    const secretKey = 'TEST-SECRET-KEY-456';
    const requestId = 'REQ-12345';
    const timestamp = '2026-09-07T12:00:00Z';
    const targetPath = '/checkout/v1/payment';
    const rawBody = '{"order":{"amount":50000}}';

    final digest = base64Encode(sha256.convert(utf8.encode(rawBody)).bytes);
    final signatureComponent =
        'Client-Id:$clientId\nRequest-Id:$requestId\nRequest-Timestamp:$timestamp\nRequest-Target:$targetPath\nDigest:$digest';
    final hmac = base64Encode(Hmac(sha256, utf8.encode(secretKey)).convert(utf8.encode(signatureComponent)).bytes);
    final signature = 'HMACSHA256=$hmac';

    expect(signature.startsWith('HMACSHA256='), isTrue);
    expect(signature.length, greaterThan(20));
  });

  test('Direct DOKU Checkout API returns HTTP 200 with checkout URL when env configured', () async {
    final clientId = Platform.environment['DOKU_CLIENT_ID'];
    final secretKey = Platform.environment['DOKU_SECRET_KEY'];
    if (clientId == null || secretKey == null) {
      // Lewati live API call jika kredensial privat tidak di-inject via CI/CD environment
      return;
    }
    const baseUrl = 'https://api-sandbox.doku.com';
    const targetPath = '/checkout/v1/payment';

    final invoiceNumber = 'DART-TEST-${DateTime.now().millisecondsSinceEpoch}';
    final requestBody = {
      'order': {
        'amount': 49000,
        'invoice_number': invoiceNumber,
        'callback_url': 'https://openturath-ai.web.app',
        'line_items': [
          {
            'name': 'Test Paket Tholib (1 Bulan)',
            'price': 49000,
            'quantity': 1,
          }
        ],
      },
      'payment': {
        'payment_due_date': 120,
      },
      'customer': {
        'name': 'Peneliti Test',
        'email': 'test.peneliti@openturath.ai',
        'phone': '081234567890',
      },
    };

    final rawBody = jsonEncode(requestBody);
    final requestId = 'REQ-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(9000) + 1000}';
    final timestamp = '${DateTime.now().toUtc().toIso8601String().substring(0, 19)}Z';

    final digest = base64Encode(sha256.convert(utf8.encode(rawBody)).bytes);
    final signatureComponent = 'Client-Id:$clientId\nRequest-Id:$requestId\nRequest-Timestamp:$timestamp\nRequest-Target:$targetPath\nDigest:$digest';
    final hmac = base64Encode(Hmac(sha256, utf8.encode(secretKey)).convert(utf8.encode(signatureComponent)).bytes);
    final signature = 'HMACSHA256=$hmac';

    final client = HttpClient();
    try {
      final request = await client.postUrl(Uri.parse('$baseUrl$targetPath'));
      request.headers.set('Client-Id', clientId);
      request.headers.set('Request-Id', requestId);
      request.headers.set('Request-Timestamp', timestamp);
      request.headers.set('Signature', signature);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.add(utf8.encode(rawBody));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      expect(response.statusCode, 200);
      final json = jsonDecode(responseBody) as Map<String, dynamic>;
      final url = json['response']?['payment']?['url'] as String?;
      expect(url, isNotNull);
      expect(url!.startsWith('https://staging.doku.com/checkout-link-v2/'), isTrue);
    } on SocketException catch (_) {
      // Offline / Sandbox test environment
    } finally {
      client.close();
    }
  });
}

```

### TEST FILE: openturath_ai/test/fiqh_specialists_and_theme_test.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/models/field_model.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/theme.dart';

void main() {
  group('Fikih Specialists & Theme Verification', () {
    test('FieldModel fiqh has 5 specialists and fiqh_tahawwulat is independent field', () {
      final fiqhField = FieldModel.getById('fiqh');
      expect(fiqhField.specialistCount, 5);
      expect(fiqhField.agentIds.length, 5);
      expect(fiqhField.agentIds, containsAll([
        'fiqh_syafii',
        'fiqh_hanafi',
        'fiqh_maliki',
        'fiqh_hanbali',
        'fiqh_muqaran',
      ]));

      final tahawwulatField = FieldModel.getById('fiqh_tahawwulat');
      expect(tahawwulatField.specialistCount, 1);
      expect(tahawwulatField.agentIds, contains('fiqh_tahawwulat'));
    });

    test('AgentModel defaultAgents contains 5 standard fiqh specialists and 1 independent tahawwulat', () {
      final fiqhAgents = AgentModel.defaultAgents.where((a) => a.fieldId == 'fiqh').toList();
      expect(fiqhAgents.length, 5);

      final fiqhIds = fiqhAgents.map((a) => a.id).toSet();
      expect(fiqhIds, containsAll([
        'fiqh_syafii',
        'fiqh_hanafi',
        'fiqh_maliki',
        'fiqh_hanbali',
        'fiqh_muqaran',
      ]));

      // Check all 5 fiqh specialists have titles
      for (final agent in fiqhAgents) {
        expect(agent.title.isNotEmpty, isTrue);
        expect(agent.titleArabic.isNotEmpty, isTrue);
      }

      // Sovereign Tahawwulat agent check
      final tahawwulatAgent = AgentModel.defaultAgents.firstWhere((a) => a.id == 'fiqh_tahawwulat');
      expect(tahawwulatAgent.fieldId, 'fiqh_tahawwulat');
      expect(tahawwulatAgent.price1m, 50000);
      expect(tahawwulatAgent.isActive, isTrue);
    });

    test('AgentModel defaultAgents contains valid active specialists', () {
      final activeAgents = AgentModel.defaultAgents.where((a) => a.isActive).toList();
      expect(activeAgents.length, equals(6));
      expect(activeAgents.map((a) => a.id), contains('fiqh_tahawwulat'));
      expect(activeAgents.map((a) => a.id), contains('hadits'));
    });

    test('Default ThemeMode is system for fresh installs', () {
      expect(AppConfig.themeNotifier.value, ThemeMode.system);
    });

    test('AppTheme defines scholarly sapphire accent and parchment reading surface tokens', () {
      expect(AppTheme.accentDark, const Color(0xFF60A5FA));
      expect(AppTheme.accentLight, const Color(0xFF18181B));
      expect(AppTheme.readingCanvasParchmentLight, const Color(0xFFFBF7EE));
      expect(AppTheme.readingCanvasParchmentDark, const Color(0xFF1C1A17));
      expect(AppTheme.scholarlyIndigo, const Color(0xFF4F46E5));
    });
  });
}


```

### TEST FILE: openturath_ai/test/hardening_and_redeem_test.dart
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/hijri_date_utils.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/models/user_model.dart';
import 'package:openturath_ai/screens/agent_webview_screen.dart';
import 'package:openturath_ai/services/subscription_service.dart';

void main() {
  group('System Hardening & Entitlement Suite', () {
    test('All active agents have consistent pricing catalog', () {
      final activeAgents = AgentModel.defaultAgents.where((a) => a.isActive).toList();
      expect(activeAgents.isNotEmpty, isTrue);

      for (final agent in activeAgents) {
        expect(agent.price1m, isNotNull);
        expect(agent.price1m!, greaterThan(0));
        // All individual monthly plans are unified at 50,000 IDR
        expect(agent.price1m, equals(50000));
      }
    });

    test('UserModel modular entitlement grants access when active and not expired', () {
      final futureExpiry = DateTime.now().add(const Duration(days: 7));
      final user = UserModel(
        uid: 'user_active_7d',
        name: 'Santri Riset',
        email: 'santri@example.com',
        photoUrl: '',
        plan: 'custom',
        questionsUsed: 0,
        entitlements: {
          'fiqh_syafii': ModuleEntitlement(
            plan: 'redeem_7d',
            expiry: futureExpiry,
            status: 'active',
          ),
        },
      );

      expect(user.hasAccessToAgent('fiqh_syafii'), isTrue);
      // Does not grant access to unowned agents
      expect(user.hasAccessToAgent('hadits'), isFalse);
    });

    test('UserModel modular entitlement denies access when expired', () {
      final pastExpiry = DateTime.now().subtract(const Duration(days: 1));
      final user = UserModel(
        uid: 'user_expired',
        name: 'Santri Expired',
        email: 'santri_exp@example.com',
        photoUrl: '',
        plan: 'custom',
        questionsUsed: 0,
        entitlements: {
          'fiqh_syafii': ModuleEntitlement(
            plan: 'redeem_7d',
            expiry: pastExpiry,
            status: 'expired',
          ),
        },
      );

      expect(user.hasAccessToAgent('fiqh_syafii'), isFalse);
    });

    test('Full bundle plan grants access to all active agents regardless of individual entitlements', () {
      final futureExpiry = DateTime.now().add(const Duration(days: 30));
      final user = UserModel(
        uid: 'user_full_bundle',
        name: 'Santri Riset Lengkap',
        email: 'santri_full@example.com',
        photoUrl: '',
        plan: 'full',
        questionsUsed: 0,
        subscriptionExpiry: futureExpiry,
      );

      expect(user.hasAccessToAgent('fiqh_syafii'), isTrue);
      expect(user.hasAccessToAgent('hadits'), isTrue);
      expect(user.hasAccessToAgent('fiqh_tahawwulat'), isTrue);
    });

    test('URL security policy allows Google NotebookLM ecosystem and blocks external redirects (Production Code)', () {
      bool check(String urlStr) {
        final uri = Uri.tryParse(urlStr);
        if (uri == null) return false;
        return AgentWebviewScreen.isAllowedNotebookUrl(uri);
      }

      expect(check('https://notebooklm.google.com/notebook/abc-123'), isTrue);
      expect(check('https://accounts.google.com/ServiceLogin'), isTrue);
      expect(check('https://fonts.gstatic.com/s/roboto/v20/xyz.woff2'), isFalse); // Resource URL is not a top-level destination.
      expect(check('https://apis.google.com/js/api.js'), isFalse);
      expect(check('http://notebooklm.google.com'), isFalse); // HTTP insecure rejected
      expect(check('https://evil-phishing.com/notebooklm.google.com'), isFalse);
      expect(check('javascript:alert(1)'), isFalse);
      expect(check('file:///android_asset/something.html'), isFalse);
    });

    test('Redeem code normalization handles whitespace, casing, and dashes (Production Code)', () {
      expect(SubscriptionService.normalizeCode('  santri-7hari  '), equals('SANTRI7HARI'));
      expect(SubscriptionService.normalizeCode('FIKIH-SYAFII-2026'), equals('FIKIHSYAFII2026'));
      expect(SubscriptionService.normalizeCode('  voucher 123  '), equals('VOUCHER123'));
      expect(SubscriptionService.normalizeCode(' santri_123 '), equals('SANTRI_123'));
    });

    test('addCalendarMonthsClamped correctly handles leap year 29 Feb and non-leap 28 Feb boundary conditions (F-11)', () {
      // 1. Tahun kabisat (2024): 31 Januari + 1 bulan = 29 Februari 2024
      final jan31Leap = DateTime(2024, 1, 31);
      final febLeap = HijriDateUtils.addCalendarMonthsClamped(jan31Leap, 1);
      expect(febLeap.year, equals(2024));
      expect(febLeap.month, equals(2));
      expect(febLeap.day, equals(29));

      // 2. Tahun non-kabisat (2025): 31 Januari + 1 bulan = 28 Februari 2025
      final jan31NonLeap = DateTime(2025, 1, 31);
      final febNonLeap = HijriDateUtils.addCalendarMonthsClamped(jan31NonLeap, 1);
      expect(febNonLeap.year, equals(2025));
      expect(febNonLeap.month, equals(2));
      expect(febNonLeap.day, equals(28));

      // 3. Dari 29 Februari kabisat (2024) + 12 bulan (1 tahun) = 28 Februari 2025 (non-kabisat)
      final leapFeb29 = DateTime(2024, 2, 29);
      final nextYearFeb = HijriDateUtils.addCalendarMonthsClamped(leapFeb29, 12);
      expect(nextYearFeb.year, equals(2025));
      expect(nextYearFeb.month, equals(2));
      expect(nextYearFeb.day, equals(28));

      // 4. 31 Maret + 1 bulan = 30 April
      final mar31 = DateTime(2024, 3, 31);
      final apr30 = HijriDateUtils.addCalendarMonthsClamped(mar31, 1);
      expect(apr30.month, equals(4));
      expect(apr30.day, equals(30));

      // 5. 31 Mei + 1 bulan = 30 Juni
      final may31 = DateTime(2024, 5, 31);
      final jun30 = HijriDateUtils.addCalendarMonthsClamped(may31, 1);
      expect(jun30.month, equals(6));
      expect(jun30.day, equals(30));
    });
  });
}

```

### TEST FILE: openturath_ai/test/resilience_and_compliance_test.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/theme.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/models/user_model.dart';
import 'package:openturath_ai/core/localization.dart';
import 'package:openturath_ai/models/bookmark_model.dart';
import 'package:openturath_ai/services/agent_service.dart';
import 'package:openturath_ai/widgets/app_error_state.dart';

void main() {
  group('Resilience & Compliance Suite', () {
    testWidgets('AppErrorState renders properly with retry and back buttons', (tester) async {
      bool retried = false;
      bool backPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: AppErrorState(
              title: 'Gagal Memuat Korpus',
              message: 'Terjadi kendala koneksi saat menghubungi server.',
              onRetry: () => retried = true,
              onBack: () => backPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Gagal Memuat Korpus'), findsOneWidget);
      expect(find.text('Terjadi kendala koneksi saat menghubungi server.'), findsOneWidget);
      expect(find.text('Coba lagi'), findsOneWidget);
      expect(find.text('Kembali'), findsOneWidget);

      await tester.tap(find.text('Coba lagi'));
      expect(retried, isTrue);

      await tester.tap(find.text('Kembali'));
      expect(backPressed, isTrue);
    });

    test('AgentModel defaultAgents have complete Arabic metadata and no null pointer risks', () {
      for (final agent in AgentModel.defaultAgents) {
        expect(agent.id, isNotEmpty);
        expect(agent.title, isNotEmpty);
        expect(agent.titleArabic, isNotEmpty);
        expect(agent.category, isNotEmpty);

        if (agent.isActive) {
          expect(agent.referenceBooks, isNotNull);
          expect(agent.referenceBooks!.isNotEmpty, isTrue);
          expect(agent.price1m, isNotNull);
        }

        if (agent.subAgents != null) {
          for (final sub in agent.subAgents!) {
            expect(sub.nameArabic, isNotEmpty);
            expect(sub.name, isNotEmpty);
          }
        }
      }
    });

    test('Anonymous guest user model properties are valid', () {
      final guest = UserModel(
        uid: 'guest_test_123',
        name: 'Peneliti Tamu',
        email: '',
        photoUrl: '',
        plan: 'trial',
        questionsUsed: 0,
      );

      expect(guest.isGuest, isTrue);
      expect(guest.isTrial, isTrue);
      expect(guest.questionsRemaining, equals(10));
      expect(guest.hasAccess, isTrue);
    });

    test('AppTheme Obsidian standard does not leak gold color #D4AF37', () {
      expect(AppTheme.lmDarkCanvas, equals(AppTheme.canvasDark));
      expect(AppTheme.lmDarkSurface, equals(AppTheme.surfaceCardDark));
      expect(AppTheme.lmDarkBorder, equals(AppTheme.borderDark));
      expect(AppTheme.lmDarkAccent, equals(AppTheme.accentDark));

      // Light mode
      expect(AppTheme.lmLightCanvas, equals(AppTheme.canvasLight));
      expect(AppTheme.lmLightSurface, equals(AppTheme.surfaceCardLight));
      expect(AppTheme.lmLightBorder, equals(AppTheme.borderLight));
      expect(AppTheme.lmLightAccent, equals(AppTheme.accentLight));
    });

    test('AgentAccessException encapsulates code, message, and string representation', () {
      const exc = AgentAccessException(
        'permission-denied',
        'Batas uji coba 10 pertanyaan telah tercapai.',
      );
      expect(exc.code, equals('permission-denied'));
      expect(exc.message, contains('10 pertanyaan'));
      expect(exc.toString(), contains('AgentAccessException(permission-denied)'));
    });

    test('UserModel hasAccessToAgent respects modular entitlements and expiry', () {
      final now = DateTime.now();
      final future = now.add(const Duration(days: 30));
      final past = now.subtract(const Duration(days: 1));

      final activeUser = UserModel(
        uid: 'user_active_1',
        email: 'santri@openturath.ai',
        name: 'Santri Aktif',
        photoUrl: '',
        plan: 'premium',
        questionsUsed: 0,
        entitlements: {
          'fiqh_tahawwulat': ModuleEntitlement(
            plan: 'tholib_1m',
            status: 'active',
            expiry: future,
          ),
        },
      );

      expect(activeUser.hasAccessToAgent('fiqh_tahawwulat'), isTrue);

      final expiredUser = UserModel(
        uid: 'user_expired_1',
        email: 'santri_exp@openturath.ai',
        name: 'Santri Expired',
        photoUrl: '',
        plan: 'trial',
        questionsUsed: 10,
        entitlements: {
          'fiqh_tahawwulat': ModuleEntitlement(
            plan: 'tholib_1m',
            status: 'expired',
            expiry: past,
          ),
        },
      );

      expect(expiredUser.hasAccessToAgent('fiqh_tahawwulat'), isFalse);
      expect(expiredUser.isTrialExhausted, isTrue);
    });

    test('ThemeData dark and light include hardened component themes', () {
      final darkTheme = AppTheme.darkTheme;
      expect(darkTheme.snackBarTheme.behavior, equals(SnackBarBehavior.floating));
      expect(darkTheme.inputDecorationTheme.filled, isTrue);
      expect(darkTheme.dialogTheme.backgroundColor, equals(AppTheme.surfaceCardDark));

      final lightTheme = AppTheme.lightTheme;
      expect(lightTheme.snackBarTheme.behavior, equals(SnackBarBehavior.floating));
      expect(lightTheme.inputDecorationTheme.filled, isTrue);
      expect(lightTheme.dialogTheme.backgroundColor, equals(AppTheme.surfaceCardLight));
    });

    test('Localization contains valid cancel key in all three languages', () {
      AppConfig.localeNotifier.value = 'id';
      expect(Loc.tr('cancel'), equals('Batal'));

      AppConfig.localeNotifier.value = 'en';
      expect(Loc.tr('cancel'), equals('Cancel'));

      AppConfig.localeNotifier.value = 'ar';
      expect(Loc.tr('cancel'), equals('إلغاء'));

      // Restore default
      AppConfig.localeNotifier.value = 'id';
    });

    test('BookmarkModel serializes and deserializes correctly', () {
      final now = DateTime.now();
      final bm = BookmarkModel(
        id: 'bm_test_1',
        title: 'Kaidah Fiqh',
        agentId: 'fiqh_syafii',
        agentTitle: 'AI Fikih Syafi\'i',
        fieldName: 'Fikih',
        fieldId: 'fiqh',
        arabicExcerpt: 'الْأُمُورُ بِمَقَاصِدِهَا',
        fullAnswer: 'Segala perkara bergantung pada niatnya.',
        bookReference: 'Al-Asybah wan-Nazhair',
        pageNumber: 'Hal. 10',
        createdAt: now,
      );

      final json = bm.toJson();
      final restored = BookmarkModel.fromJson(json);

      expect(restored.id, equals('bm_test_1'));
      expect(restored.title, equals('Kaidah Fiqh'));
      expect(restored.arabicExcerpt, equals('الْأُمُورُ بِمَقَاصِدِهَا'));
      expect(restored.fieldId, equals('fiqh'));
    });
  });
}

```

### TEST FILE: openturath_ai/test/ui_copy_regression_test.dart
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/services/subscription_service.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/core/app_copy.dart';

void main() {
  test('Voucher errors remain natural even for uppercase transport codes', () {
    expect(SubscriptionService.redeemErrorMessage('NOT_FOUND'), contains('Kode akses tidak ditemukan'));
    expect(SubscriptionService.redeemErrorMessage('INTERNAL'), isNot(contains('INTERNAL')));
    expect(SubscriptionService.redeemErrorMessage('already-exists'), contains('sudah pernah'));
    expect(SubscriptionService.redeemErrorMessage('unauthenticated'), contains('masuk'));
  });
  test('All assistant titles identify AI without changing entitlement IDs', () {
    for (final agent in AgentModel.defaultAgents) {
      expect(agent.title, startsWith('AI '));
      expect(agent.id, isNot(startsWith('AI ')));
    }
  });
  test('Conversation loading and menu describe their actions', () {
    expect(AppCopy.loadingReferences, 'Menyiapkan percakapan AI...');
    expect(AppCopy.studyOptions, 'Menu percakapan');
  });
}

```

### TEST FILE: openturath_ai/test/widget_test.dart
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/arabic_utils.dart';
import 'package:openturath_ai/core/constants.dart';
import 'package:openturath_ai/core/localization.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/models/user_model.dart';
import 'package:openturath_ai/services/research_notes_service.dart';

void main() {
  group('UserModel & ModuleEntitlement Unit Tests', () {
    test('User trial calculation correctly counts remaining quota', () {
      final user = UserModel(
        uid: 'test_uid_1',
        name: 'Peneliti Turats',
        email: 'peneliti@openturath.id',
        photoUrl: '',
        plan: AppConstants.planTrial,
        questionsUsed: 4,
      );

      expect(user.isTrial, isTrue);
      expect(user.isPremium, isFalse);
      expect(user.questionsRemaining, equals(6));
      expect(user.isTrialExhausted, isFalse);
      expect(user.hasAccess, isTrue);
    });

    test('User trial is exhausted when questions reach limit', () {
      final user = UserModel(
        uid: 'test_uid_2',
        name: 'Peneliti Turats',
        email: 'peneliti@openturath.id',
        photoUrl: '',
        plan: AppConstants.planTrial,
        questionsUsed: 10,
      );

      expect(user.isTrialExhausted, isTrue);
      expect(user.questionsRemaining, equals(0));
      expect(user.hasAccess, isFalse);
    });

    test('Modular entitlement gives exclusive access to entitled module only', () {
      final futureExpiry = DateTime.now().add(const Duration(days: 30));
      final userWithTahawwulatOnly = UserModel(
        uid: 'test_uid_3',
        name: 'Tholib Ilmu',
        email: 'tholib@openturath.id',
        photoUrl: '',
        plan: AppConstants.planTrial,
        questionsUsed: 10, // trial habis
        entitlements: {
          'fiqh_tahawwulat': ModuleEntitlement(
            plan: AppConstants.planTholib1m,
            expiry: futureExpiry,
            status: 'active',
          ),
        },
      );

      // Harusnya bisa akses Fikih Tahawwulat dan sub-agennya
      expect(userWithTahawwulatOnly.hasAccessToAgent('fiqh_tahawwulat'), isTrue);
      expect(userWithTahawwulatOnly.hasAccessToAgent('fiqh_tahawwulat_muhaqqiq'), isTrue);
      expect(userWithTahawwulatOnly.hasAccessToAgent('fiqh_tahawwulat_bayan'), isTrue);

      // Tapi TIDAK BISA akses Fikih Syafi'i karena trial habis dan modul tidak dibeli
      expect(userWithTahawwulatOnly.hasAccessToAgent('fiqh_syafii'), isFalse);
      expect(userWithTahawwulatOnly.hasAccessToAgent('hadits'), isFalse);
    });

    test('Expired module entitlement correctly denies premium access', () {
      final pastExpiry = DateTime.now().subtract(const Duration(days: 1));
      final userExpired = UserModel(
        uid: 'test_uid_4',
        name: 'User Expired',
        email: 'expired@openturath.id',
        photoUrl: '',
        plan: AppConstants.planTrial,
        questionsUsed: 10,
        entitlements: {
          'fiqh_tahawwulat': ModuleEntitlement(
            plan: AppConstants.planTholib1m,
            expiry: pastExpiry,
            status: 'active',
          ),
        },
      );

      expect(userExpired.isAgentSubscriptionActive('fiqh_tahawwulat'), isFalse);
      expect(userExpired.hasAccessToAgent('fiqh_tahawwulat'), isFalse);
    });
  });

  group('AgentModel Catalog Tests', () {
    test('Default catalog contains core modules with complete metadata', () {
      final agents = AgentModel.defaultAgents;
      expect(agents.isNotEmpty, isTrue);

      final tahawwulat = agents.firstWhere((a) => a.id == 'fiqh_tahawwulat');
      expect(tahawwulat.title, contains('Tahawwulat'));
      expect(tahawwulat.subAgents?.length, equals(2));
      expect(tahawwulat.referenceBooks?.isNotEmpty, isTrue);
    });
  });

  group('ResearchNote & Citation Generator Tests', () {
    test('ResearchNote formats citation correctly with book, volume, and page', () {
      final note = ResearchNote(
        id: 'note_123',
        agentId: 'fiqh_tahawwulat',
        agentTitle: 'Fiqh Tahawwulat AI',
        title: 'Konsep Sunnah Mawaqif',
        excerpt: 'Sunnah mawaqif adalah ketetapan sikap kenabian dalam menghadapi perubahan zaman.',
        bookTitle: 'Al-Bayan',
        bookVolume: '1',
        bookPage: '45',
        createdAt: DateTime.now(),
      );

      final citation = note.citationFormatted;
      expect(citation, contains('Sunnah mawaqif'));
      expect(citation, contains('OpenTurath AI (Fiqh Tahawwulat AI)'));
      expect(citation, contains('Kitab Al-Bayan Juz 1 Hal 45'));
    });
  });

  group('ArabicUtils Smart Arabic Search Tests', () {
    test('ArabicUtils.normalize strips harakat and unifies letter forms', () {
      const textWithHarakat = 'فِقْهُ التَّحَوُّلَاتِ';
      final normalized = ArabicUtils.normalize(textWithHarakat);
      expect(normalized, equals('فقه التحولات'));
    });

    test('ArabicUtils.matches matches plain query with harakat text', () {
      const sourceArabic = 'فِقْهُ التَّحَوُّلَاتِ وَسُنَّةُ الْمَوَاقِفِ';
      
      // Pencarian tanpa harakat
      expect(ArabicUtils.matches(sourceArabic, 'فقه'), isTrue);
      expect(ArabicUtils.matches(sourceArabic, 'التحولات'), isTrue);
      expect(ArabicUtils.matches(sourceArabic, 'سنة'), isTrue);
      expect(ArabicUtils.matches(sourceArabic, 'المواقف'), isTrue);

      // Pencarian kata yang tidak ada
      expect(ArabicUtils.matches(sourceArabic, 'نحو'), isFalse);
    });

    test('ArabicUtils.matches supports Latin search in bilingual metadata', () {
      const sourceLatin = 'Fiqh Tahawwulat & Al-Manhaji';
      expect(ArabicUtils.matches(sourceLatin, 'tahawwulat'), isTrue);
      expect(ArabicUtils.matches(sourceLatin, 'manhaji'), isTrue);
      expect(ArabicUtils.matches(sourceLatin, 'hadits'), isFalse);
    });
  });

  group('Localization & AppConfig Tests', () {
    test('Localization dictionary returns valid strings for all supported languages', () {
      expect(Loc.tr('app_name'), equals('OpenTurath AI'));
      expect(Loc.tr('choose_plan'), isNotEmpty);
      expect(Loc.tr('save'), isNotEmpty);
    });
  });
}

```

