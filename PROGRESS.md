# OpenTurath AI — Master Progress & Context Tracker

> **Panduan Awet Konteks & Ringan Memori**:
> File ini adalah *Single Source of Truth* status proyek OpenTurath AI. Ketika sesi chat terasa panjang (>15-20 turn), buka **Chat Baru (New Conversation)** lalu cukup instruksikan:
> **"Baca PROGRESS.md dan lanjutkan task berikutnya."**
> Agent akan langsung memahami 100% konteks proyek tanpa membebani RAM laptop.

---

## 1. Identitas & Visi Produk
- **Aplikasi**: OpenTurath AI (`openturath_ai`) — platform riset dan talaqqi khazanah turats Islam berbasis AI (Flutter Cross-Platform: Android & macOS).
- **Filosofi Visual**: *The Quiet Islamic Scholar* — desain monokrom teduh, tipografi editorial klasik, hening, minim distraksi, tanpa gradien mencolok (*zero tacky gradients*), tanpa bayangan tebal (*zero heavy shadows*), mengedepankan adab keilmuan dan keterbacaan teks marja'.

---

## 2. Riwayat Konteks & Master Plan (Audit Forensik Independen)
Berdasarkan `AUDIT_OPENTURATH_AI.md`, dokumen perancangan pustaka, dan keluhan keras pengguna terhadap UI yang sempat dinilai terlalu ramai/tacky ("najis"):

### Fasa 1 s.d. Fasa 7: Status Eksekusi (100% Selesai & Ter-commit)
1. **Fasa 1: Data Katalog Kitab & Kamus Kanonikal (`a5a72e1`)**
   - 21 berkas JSON katalog kitab keilmuan (Fikih Syafi'i s.d. Adab Akhlak) dan kamus kanonikal disinkronkan ke `assets/data/`.
   - `metadata_training_seluruh_ai.json` terdaftar resmi di `pubspec.yaml`.
2. **Fasa 2: Keamanan Transaksi & Zero 404 (`e0459f6`, `6f3fde8`, `79d5e2b`)**
   - Penutupan celah validasi client-side Firestore pada `subscription_service.dart`.
   - Restrukturisasi harga katalog GoAkal (Paket Sultan All-Access Rp 499rb, Bundle Rp 149–199rb).
   - Smart fallback WhatsApp Admin Resmi (`081292979189`) untuk paket belum aktif (eliminasi total link 404).
3. **Fasa 3: Stabilitas Memori WebView & Navigasi Mobile (`e958a39`, `73626a5`, `2abd1fb`)**
   - Pencegahan kebocoran memori WebView dengan `disposeWebResources()` dan pembersihan controller pada `agent_session_manager.dart`.
   - Pemisahan tombol close tab (area ketuk 44x44 px) tanpa nesting `InkWell`.
   - Perbaikan `PopScope` tombol Back Android pada `main_shell_screen.dart` agar tidak terjebak riwayat SPA internal.
4. **Fasa 4: Pustaka Metadata & Katalog Editorial (`4f849df`, `46cf302`, `a2fbf06`)**
   - Pembuatan entitas `OpenTurathBook` dan repositori `OpenTurathCatalogRepository`.
   - Integrasi `library_metadata_overview_screen.dart` dan detail kitab editorial.
   - Pendaftaran rute riset pustaka ke dalam shell navigasi utama.
5. **Fasa 5: Unifikasi Token Desain Monokrom Editorial (`2f2540c`, `a6d9f8c`, `3cef1ce`)**
   - Standarisasi `OTColors` adaptif (Light Canvas `#F6F6F3`, Dark Canvas `#111110`, Border lembut, tanpa warna jenuh).
   - Tipografi 3 Pilar di `OTTypography`:
     - **Newsreader**: Judul dan subjudul editorial Latin.
     - **Scheherazade New**: Seluruh teks Arab, matan, kutipan ibarah (pembersihan total font *Amiri* & *Tajawal*).
     - **Outfit**: Label navigasi, tombol, dan teks fungsional.
6. **Fasa 6: Overhaul Copywriting Adab Turats (`a471023`, `0941a92`, `6f6e0ae`)**
   - Unifikasi kamus resmi pada `app_copy.dart` dan `legal_copy.dart`:
     - *Prompt / Pertanyaan* $\rightarrow$ *Ibarah / Mas'alah*
     - *Sumber Referensi* $\rightarrow$ *Marja' Mu'tamad*
     - *Ruang Chat* $\rightarrow$ *Ruang Telaah Ilmiah*
     - *Asisten AI* $\rightarrow$ *Khadim Turats / Muhaqqiq*
7. **Fasa 7: Pembersihan UI Tacky & Penyederhanaan Beranda (`780e037`, `9947497`, `ef185a4`)**
   - Penghapusan linear gradient gelap dan box shadow norak pada `dashboard_screen.dart`.
   - Penyatuan indikator navigasi shell secara hening.
   - Transformasi pengalih korpus pada `corpus_kind_control.dart` dari kartu tebal/segmented button menjadi tab datar bergaris bawah (*flat underline tabs*).
8. **Fasa 8: Overhaul Konsistensi UI Monokrom Editorial & Audit Forensik (`55da31c`)**
   - **Modul 1 (Subscription Screen)**: Pembersihan sisa `LinearGradient`, eliminasi teks kuning neon `0xFFFBBF24` dan bayangan tebal, digantikan kartu bersahaja `OTColors.borderStrong` dan `OTColors.textPrimary`.
   - **Modul 2 (App SnackBar)**: Standarisasi latar monokrom pekat `OTColors.inverseSurface` dengan garis tepi hairline netral dan aksen galat merah bata redup `OTColors.destructiveDark` (zero neon).
   - **Modul 3 (Dashboard Screen & Multi-Tab)**: Penyelarasan seluruh sisa kode warna Zinc liar (`0xFF27272A`, `0xFFF4F4F5`, `0xFF3F3F46`, `0xFFE4E4E7`) ke token `OTColors`.
   - **Modul 4 (Tipografi Arab & Normalisasi Pencarian)**: Font `Scheherazade New` dengan line-height aman $\ge 1.85$ untuk matan/ibarah Arab (`OTTypography.arabicIbarah`), serta verifikasi algoritma normalisasi pencarian Arab (`ArabicUtils.normalize` & `matches`).
   - **Verifikasi**: `flutter analyze` (0 issues), Regex Rogue Color Audit (0 matches), `flutter test` (159/159 tests passed 100%).
9. **Fasa 9: Konsolidasi Ensiklopedia Fikih Tahawwulat & Audit Sumber (`2d4fe21`)**
   - Kompilasi berkas tunggal `KUMPULAN_TEKS_MENGENAL_TAHAWWULAT.txt` (1.316 baris, 100.6 KB) yang menyatukan seluruh materi Fikih Tahawwulat di dalam aplikasi: Buku Panduan 10 Bab, teks antarmuka modal interaktif, blueprint 5 bilik AI, dan katalog kanonikal 58 kitab resmi karya Habib Abu Bakar Al-Adni.
   - Pembaruan berkas konsolidasi kode sumber tersanitasi `OPENTURATH_AI_FULL_AUDIT_SOURCE.txt` (127 berkas terpadu).
10. **Fasa 10: Eliminasi Mode Tamu & Hardening Keamanan Non-Desain (`1.0.51+52`)**
    - **Penghapusan Mode Tamu**: Tombol dan handler `Masuk sebagai Tamu (Mode Telaah)` dihapus sepenuhnya dari `login_screen.dart` atas permintaan pengguna, mengembalikan login murni terautentikasi (Google Auth) dengan zero visual alteration pada elemen lainnya.
    - **Perbaikan S03 (Status Pembayaran)**: Hardening fungsi `verifyPaymentStatus` pada `subscription_service.dart` agar hanya merespon `success: true` jika transaksi berstatus final (`SUCCESS`, `SETTLED`, atau `PAID`), menutup celah bypass saat status gateway masih `PENDING`.
    - **Perbaikan S04 (Deep Link Allowlist)**: Penerapan `_allowedExternalPaymentSchemes` ketat pada `doku_checkout_sheet.dart` (hanya mengizinkan aplikasi perbankan/e-wallet resmi seperti GoPay, ShopeePay, OVO, DANA, LinkAja, BCA, Mandiri, BRI, BNI), memblokir skema berbahaya seperti `javascript:`, `file:`, `content:`, `data:`.
    - **Optimasi Gradle**: Penambahan `org.gradle.daemon.idletimeout=60000` pada `android/gradle.properties` untuk mencegah daemon zombie di Mac 8GB.
    - **Auto-Update Pop-Up Dialog (`UpdateReadyDialog`)**: Menambahkan modal pop-up hening yang otomatis muncul di beranda saat berkas APK pembaruan selesai diunduh di latar belakang, menyajikan tombol *'Pasang & Muat Ulang Sekarang'* secara instan.

---

## 3. Konfigurasi Sistem Ramah Memori (Anti-Hang Mac 8GB)
- **Gradle JVM Heap**: Dibatasi maksimal **2048 MB** (`-Xmx2048m -XX:MaxMetaspaceSize=512m`) pada proyek dan `~/.gradle/gradle.properties`.
- **Idle Timeout**: Daemon otomatis mati setelah 60 detik idle (`idletimeout=60000`), mencegah penumpukan daemon zombie.
- **Language Server Tuning**: Ekstensi Java RedHat & Gradle disetel ke mode `LightWeight` (Flutter dijalankan mandiri via CLI).
- **Cache Pruning**: 13.000 file rekaman peramban lama (1.3 GB) telah dibersihkan.
- **File Watcher Excludes**: Mengabaikan folder `.gradle/`, `build/`, `.dart_tool/`, dan `.gemini/` untuk meringankan I/O disk.

---

## 4. Status Pengujian, Rilis APK & macOS
- **Syntax & Type Check**: `flutter analyze` $\rightarrow$ **0 issues**.
- **Automated Test Suite**: Seluruh 32 berkas pengujian unit/widget di `openturath_ai/test/` berstatus **LULUS (All Green - 159+ tests)**.
- **Rilis Binary APK Terbaru (Lokal)**:
  - File: `/Users/apple/Downloads/ramadhan/app-release-latest.apk`
  - Versi: `1.0.51+52`
  - Ukuran: 62.7 MB (62.682.302 bytes)
  - Timestamp: 2026-09-20 08:42:38 WIB
  - Status: Kompilasi Gradle selesai 100% (Full assembleRelease 167.7s).
  - Termasuk penghapusan Mode Tamu di layar login, hardening keamanan transaksi pembayaran, pembersihan nama Arab redundan, dan proteksi total desain asli.
- **Rilis macOS DMG (Kompilasi Lokal Terbaru)**:
  - File: `/Users/apple/Downloads/ramadhan/OpenTurath_AI_macOS.dmg`
  - Ukuran: 47 MB (49.427.583 bytes)
  - SHA-256: `07fffeaa34510042256e785c28fd23d8f06d43924d8925d4d59b952b989a258d`
  - Timestamp: 2026-10-06 13:39 WIB
  - Status: Kompilasi Xcode/macOS Release selesai 100%, UDZO image terkemas rapi via `package_macos.sh`, dan `/Applications/OpenTurath AI.app` diperbarui langsung.
  - Perbaikan Kritis:
    1. Eliminasi SyntaxError fatal pada `notebook_ui_script.dart` (`[class*="zero-state" i]`) yang menyebabkan `window.otNotebook` gagal dievaluasi sehingga AI macet loading selamanya.
    2. Pembersihan menyeluruh empty state: teks nama asisten (Al-Muhaqqiq dll), rincian `X sumber · tanggal`, serta loading internal NotebookLM disembunyikan bersih sebelum obrolan siap.
    3. Komponen loading terstandarisasi penuh ke Three-Dots Pulse Loader elegan (titik tiga berdenyut baku), bebas dari animasi lengkung/bar linear lama.
    4. Seluruh naskah pedoman adab disatukan menjadi 8 poin rapi tanpa rujukan nomor kitab/halaman.
- **Rilis macOS DMG (Cloud GitHub Actions)**:
  - Workflow: `.github/workflows/release_all_platforms.yml` (Job `build-macos-dmg`).
  - Output Artifact: `OpenTurath_AI_macOS.dmg`.
  - Fix Google Sign-In macOS (`304a530`):
    - Mengganti Web Client ID dengan Apple OAuth Client ID resmi (`255541559800-fen41rigfp5o3fsntiieaien3v915ptd.apps.googleusercontent.com`) pada `Info.plist` dan `auth_service.dart`.
    - Memperbaiki URL Scheme redirect `com.googleusercontent.apps.255541559800-fen41rigfp5o3fsntiieaien3v915ptd`.
    - Menambahkan `keychain-access-groups` pada `Release.entitlements` dan `DebugProfile.entitlements`.
    - Mengembalikan pemanggilan native `GoogleSignIn` SDK (bukan `signInWithProvider` yang unsupported di desktop macOS).
    - Menambahkan tombol akses darurat: "Masuk sebagai Tamu (Mode Telaah)" agar riset turats tidak pernah terblokir.

### Fasa 11: Solusi Definitif Jebakan Login Google & Timeout Loader Asisten (`91c5031`)
- **Akar Masalah**:
  1. Pada WebView macOS (`InAppWebView`), saat dialihkan ke formulir masuk Google (`accounts.google.com`), `AppLoader.fullscreen` menutup seluruh layar karena kondisi hanya memeriksa `!session.isSessionReady` tanpa mengecualikan `session.isGoogleAuthPage`. Akibatnya formulir Google terhalang total oleh layar muat.
  2. Fungsi `_checkReady()` menghitung timeout 45 detik tanpa mengecualikan halaman masuk Google. Setelah 45 detik, status kesalahan dipicu dan memunculkan kartu "Masuk dengan Akun yang Sama".
  3. Saat pengguna menekan "Masuk dengan Google", siklus yang sama berulang sehingga pengguna terjebak selamanya.
- **Solusi Tuntas**:
  - `agent_multi_tab_room.dart`: Pengecualian mutlak `(!session.isSessionReady && !session.isGoogleAuthPage)` sehingga formulir masuk Google ditampilkan bersih dan dapat diisi pengguna.
  - Reset `_loadingStarted = null` saat navigasi ke `signInFlow` atau saat dalam keadaan `isGoogleAuthPage`, mencegah timeout prematur.
  - Kompilasi biner rilis macOS (`flutter build macos --release`), pembuatan DMG (`tool/package_macos.sh`), pembaruan `/Applications/OpenTurath AI.app`, dan peluncuran ulang aplikasi terverifikasi aktif (PID baru).

### Fasa 12: Eliminasi Total Teks Loading Notebook & Penstabilan Transisi Bebas Flicker (`c60d31e`)
- **Akar Masalah**:
  1. Ambang batas kesiapan `_checkReady()` sebelumnya terlalu dini (`_readySamples >= 2 && elapsedMs >= 1500`), sehingga layar muat `AppLoader` memudar sebelum layout Angular NotebookLM stabil. Hal ini menimbulkan loncatan/kedipan (*flicker*) visual.
  2. Teks "Loading Notebook..." dan indikator loading bawaan NotebookLM sempat terlihat di WebView saat transisi karena selector CSS belum mencakup kontainer pemuatan internal Google (`app-loading-screen`, `mat-spinner`, dll.) dan belum ada penyisiran global berbasis teks di seluruh dokumen.
- **Solusi Tuntas**:
  - `notebook_ui_script.dart`:
    - Penambahan aturan CSS `display: none !important; visibility: hidden !important;` pada selector internal pemuatan NotebookLM (`app-loading-screen`, `.loading-container`, `mat-spinner`, dsb).
    - Penyisiran DOM global di `clean()` untuk menghapus seluruh elemen yang memuat teks "Loading Notebook..." atau "Memuat Notebook...".
    - Penyempurnaan `isStillLoading()` dan `ready()`: wajib memastikan spinner bawaan hilang, chat panel utama sudah terbentuk, dan input textarea siap serta tidak dalam status *disabled*.
  - `agent_multi_tab_room.dart`:
    - Peningkatan syarat kesiapan sesi ke minimal 4 sampel stabil berturut-turut ($\ge 2$ detik) dan durasi tunggu minimal 3000ms.
    - Penambahan jeda mikro stabilisasi WebKit 250ms sebelum memudarkan loader, serta pemanjangan kurva transisi `AnimatedSwitcher` ke 320ms yang mulus.
  - Kompilasi biner rilis macOS terbaru (`flutter build macos --release`), pembuatan DMG (`tool/package_macos.sh`), pembaruan `/Applications/OpenTurath AI.app`, dan peluncuran ulang aplikasi aktif (PID 5864).

---

## 5. Agenda & Fokus Selanjutnya
1. **Inspeksi Estetika Layar Nyata (Android APK & macOS DMG)**:
   - Pasang `app-release-latest.apk` pada perangkat target dan unduh `OpenTurath_AI_macOS.dmg` dari GitHub Actions untuk dipasang di folder Applications Mac.
   - Memastikan tidak ada lagi sisa warna jenuh pada modal dan layar transaksional di desktop maupun mobile.
2. **Katalog & Spesialis**:
   - Memastikan ke-21 spesialis memiliki keterhubungan yang mulus antara ruang dialog telaah dengan pustaka kitab referensinya.
EOF
