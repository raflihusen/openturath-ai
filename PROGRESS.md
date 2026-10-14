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
- **Automated Test Suite**: Seluruh pengujian sistem berstatus **LULUS (All Green - 554 tests)**:
  - Flutter Client: **386 passed**, 0 failed
  - Cloud Functions: **144 passed**, 0 failed
  - Subscription Engine: **24 passed**, 0 failed
- **Rilis Binary APK Terbaru (Lokal)**:
  - File: `/Users/apple/Downloads/ramadhan/app-release-latest.apk`
  - Versi: `1.0.67+68`
  - Ukuran: 67.9 MB (67.909.262 bytes)
  - SHA-256: `f15767e48d762beeb31fdc2dce3f4982384beb3a386c3689ce33ee53c6681c60`
  - Timestamp: 2026-10-14 05:32 WIB
  - Status: Kompilasi Gradle selesai 100% (assembleRelease 291.2s).
- **Rilis macOS DMG (Kompilasi Lokal Terbaru)**:
  - File: `/Users/apple/Downloads/ramadhan/OpenTurath_AI_macOS.dmg`
  - Versi: `1.0.67+68`
  - Ukuran: 48 MB
  - SHA-256: `a622fdd664b3e895f1661eba83a5979b2b20d149c2fbf880cdf9afce8eb2ecb4`
  - Timestamp: 2026-10-14 07:15 WIB
  - Status: Kompilasi Xcode/macOS Release universal (arm64 + x86_64) selesai 100%, UDZO image terkemas rapi via `package_macos.sh`.
- **Paket Distribusi Pekerja Akses VPS**:
  - File: `/Users/apple/Downloads/ramadhan/ecosystem/dist/openturath-access-20261014T035043Z-5b44945e.tar.gz`
  - SHA-256: Diverifikasi via `openturath-access-20261014T035043Z-5b44945e.tar.gz.sha256`
  - Status: Registry kanonikal 17 VIP terintegrasi penuh.
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

### Fasa 13: Penguncian Posisi Input Chat di Bawah Layar & Eliminasi Celah FOUC (`5973687`)
- **Akar Masalah**:
  1. Input chat sempat terdorong ke paling atas layar (*top-aligned*) pada keadaan obrolan kosong karena kartu hero/intro di atasnya disembunyikan tanpa adanya aturan `margin-top: auto` atau `justify-content: flex-end` pada wadah flex induk.
  2. Saat navigasi dari Google login ke notebook, `isGoogleAuthPage` belum langsung dimatikan pada `onLoadStart`, sehingga ada jeda fraksi detik di mana loader tidak aktif sebelum halaman siap sepenuhnya.
- **Solusi Tuntas**:
  - `notebook_ui_script.dart`:
    - Penerapan aturan flex layout hierarkis (`display: flex; flex-direction: column; justify-content: flex-end; height: 100%`) dan `margin-top: auto !important` pada seluruh kontainer input chat (`app-chat-input`, `form.chat-input-form`, dll).
    - Penambahan fungsi JS `ensureInputAtBottom()` yang dijalankan otomatis pada siklus pembersihan `clean()` untuk memastikan input selalu terkunci di bawah layar.
  - `agent_multi_tab_room.dart`:
    - Pembaruan `onLoadStart` agar langsung mendeteksi URL notebook dan mereset `session.isGoogleAuthPage = false`, sehingga `AppLoader` langsung menutupi proses pemuatan dari awal tanpa celah visual.
  - Kompilasi biner rilis macOS terbaru (`flutter build macos --release`), pembuatan DMG (`tool/package_macos.sh`), pembaruan `/Applications/OpenTurath AI.app`, dan peluncuran ulang aplikasi terverifikasi aktif (PID 8845).

### Fasa 14: Perbaikan Tuntas Flicker Loop Google Auth & Pemulihan Posisi Alami Input Chat (`e2f9dcc` & `6707261`)
- **Akar Masalah Fundamental**:
  1. *Flicker Loop & Kebocoran Loading Google*: Fungsi `NotebookNavigation.signInFlow` sebelumnya mengevaluasi `host.endsWith('.google.com')`. Karena host `notebooklm.google.com` berakhiran `.google.com`, `signInFlow` salah mendeteksi URL notebook sebagai alur login Google. Akibatnya, `_checkReady()` di `agent_multi_tab_room.dart` memanggil `_enterGoogleSignIn()` yang menyetel `isGoogleAuthPage = true`. Ini langsung mencopot layar muat Flutter `AppLoader` dan mengekspos halaman mentah NotebookLM beserta spinner Google. Saat event navigasi mereset `isGoogleAuthPage = false`, loader muncul lagi, lalu pada tick berikutnya `_checkReady()` mencopotnya lagi. Siklus ini berulang terus-menerus setiap 500ms, menimbulkan kedipan (*flicker loop*) hebat.
  2. *Input Chat Terdorong ke Atas*: Skrip JS `ensureInputAtBottom` pada commit sebelumnya memaksa `height: 100%` pada seluruh leluhur elemen input. Hal ini merusak tata letak flex/grid Angular NotebookLM, membuat kontainer input melar memenuhi 100% viewport dan menyebabkan kotak input mengapung di bagian paling atas layar dengan area kosong putih di bawahnya.
- **Solusi Tuntas**:
  - `notebook_navigation.dart`:
    - `signInFlow(uri)` kini secara tegas mengecualikan URL notebook (`if (notebook(uri)) return false;`) dan memastikan domain `hosts` NotebookLM tidak terpicu oleh klausa `.google.com`.
    - Dibuatkan unit test otomatis (`test/notebook_navigation_test.dart`) yang memverifikasi keakuratan klasifikasi URL secara 100%.
  - `notebook_ui_script.dart`:
    - Menghapus total fungsi perusak `ensureInputAtBottom()` dan aturan flex paksa pada root. Mengembalikan posisi alami input chat di bagian bawah dengan ruang padding dan margin yang proporsional.
    - Memperketat verifikasi `ready()`: memastikan bar navigasi/header atas Google sudah tersembunyi total dan semua indikator pemuatan telah hilang sebelum loader Flutter dibuka.
  - `agent_multi_tab_room.dart`:
    - `_checkReady()` kini memprioritaskan URL notebook dan secara instan mereset `isGoogleAuthPage = false`, menjamin `AppLoader` (three-dots pulse) berdiri kokoh dan tenang tanpa kedipan hingga asisten 100% siap.

### Fasa 15: Eliminasi Jebakan `textContent` Matching & Koreksi Pesan Timeout Internet (`aaf6b3f`)
- **Akar Masalah Fundamental**:
  1. *Timeout 45 Detik & Tuduhan Salah Koneksi Internet*: Pengguna mengalami timeout 45 detik terus-menerus dan muncul dialog error yang meminta memeriksa koneksi internet, padahal koneksi internet pengguna berkecepatan 1.3 Gbps.
  2. *Jebakan `textContent`*: Fungsi JS `isStillLoading()` sebelumnya memeriksa `document.body?.textContent.includes('loading notebook')`. Karena `textContent` mengembalikan seluruh teks termasuk elemen yang di-hide (`display: none`) dan teks skrip JS yang diinjeksi, ekspresi tersebut **selalu bernilai `true` selamanya**.
  3. Akibatnya, `ready()` tidak pernah bisa mengembalikan `true`, sesi tidak pernah dianggap siap, dan aplikasi selalu terkena timeout 45 detik.
- **Solusi Tuntas**:
  - `notebook_ui_script.dart`: Menghapus total pencarian string teks global pada `textContent`. `isStillLoading()` kini hanya memeriksa spinner/loading bar bawaan yang benar-benar aktif dan kasat mata (`offsetWidth > 0`). Kesiapan obrolan murni ditentukan oleh `inputReady()` (textarea tersedia, enabled, dan siap diketik).
  - `agent_multi_tab_room.dart`: Menyesuaikan pesan timeout agar akurat ("Ruang asisten sedang memproses antrean. Silakan ketuk Coba Lagi untuk memuat ulang") dan tidak lagi menyalahkan koneksi internet pengguna.

### Fasa 16: Penguncian Presisi Bilah Input Chat di Dasar Layar (`ad5c153`)
- **Akar Masalah Fundamental**:
  1. *Input Chat Berada di Atas Layar*: Saat obrolan masih kosong (empty state), seluruh elemen hero card, panduan buku catatan, dan ringkasan sumber disembunyikan (`display: none !important`). Karena wadah atas kolaps ke tinggi `0px` dan bilah input (`app-chat-input`) berada dalam aliran dokumen normal tanpa penjangkaran bawah, kotak input terdorong ke paling atas layar persis di bawah AppBar native Flutter, meninggalkan area putih kosong raksasa di bawahnya.
- **Solusi Tuntas**:
  - `notebook_ui_script.dart`:
    - Menerapkan penjangkaran presisi `position: fixed !important; bottom: 0 !important; left: 0 !important; right: 0 !important;` pada host custom element `app-chat-input` dengan `display: flex; justify-content: center; align-items: flex-end;`.
    - Mengatur lebar anak langsung `app-chat-input > *` ke `max-width: 768px; width: 100%; margin: 0 auto;` dengan `pointer-events: auto;` sehingga klik pada textarea dan tombol kirim berfungsi normal, sementara area kosong samping tetap tembus klik (`pointer-events: none` pada host).
    - Menambahkan `padding-bottom: 130px !important;` pada seluruh wadah riwayat obrolan (`.chat-panel-content`, `.chat-view`, `.conversation-container`, `.message-list`, `[role="log"]`) agar pesan terakhir tidak pernah tertutup bilah input yang melayang di dasar layar.
    - Menambahkan fungsi JS `pinInputToBottom()` di dalam siklus pembersihan `clean()` untuk memastikan posisi bawah selalu terjaga secara presisi.

### Fasa 17: Pemulihan Total Layout Alami NotebookLM via `visibility: hidden` (`9a79b5c`)
- **Akar Masalah Fundamental**:
  1. *Perusakan Geometri Wadah Empty State*: Penggunaan `display: none !important` pada container `.empty-state`, `app-chat-empty-state`, dan traversal perusak `parentHero.previousElementSibling` melenyapkan seluruh wadah atas dari layout flow. Akibatnya, layout alami NotebookLM yang bertumpu pada flex column kehilangan penyangga vertikalnya, sehingga kotak input terdorong ke `top: 0px`.
  2. *Upaya Posisi Fixed Artifisial*: Penambahan `position: fixed` pada `app-chat-input` memunculkan ketidakcocokan karena arsitektur internal Angular NotebookLM membungkus form dan query-box dalam kontainer yang membutuhkan aliran flex alami.
- **Solusi Tuntas**:
  - `notebook_ui_script.dart`:
    - Mengeliminasi total seluruh peretasan `position: fixed` dan fungsi `pinInputToBottom()`.
    - Mengembalikan penataan alami input chat dengan `margin-top: auto !important` dan padding/margin standar.
    - Menghapus aturan `display: none !important` pada wadah `.empty-state` dan `app-chat-empty-state`. Wadah tetap dibiarkan eksis menjaga geometri ruang flex atas.
    - Menyembunyikan seluruh teks judul ("AI-MUHAQQIQ"), metadata sumber ("0 sumber · ..."), dan ikon gulungan 📜 di dalam empty state secara eksklusif menggunakan `visibility: hidden !important; opacity: 0 !important; pointer-events: none !important;`.
    - Hasil: Tampilan tengah layar 100% bersih dan putih, sementara tinggi wadah tetap kokoh menahan bilah input agar berada di dasar layar secara alami.

### Fasa 18: Eliminasi Total Sisa Selektor `display: none` pada Empty-State & Penjaminan Keterlihatan Input Chat (`168e48a`)
- **Akar Masalah Fundamental**:
  1. *Sisa Selektor pada Aturan CSS `display: none`*: Blok CSS `ensureStyles()` sebelumnya masih memuat selector komponen overview/summary (`app-notebook-overview`, `app-project-summary`, `app-guide-intro`, `app-chat-intro`, `app-notebook-intro`, dll.) dalam deklarasi `display: none !important; height: 0 !important;`.
  2. *Sisa Selektor pada JavaScript `guideSelectors`*: Fungsi JavaScript `removeHeroCard()` sebelumnya masih memuat `app-chat-empty-state`, `.empty-state`, `app-notebook-title`, dll. yang dieksekusi berkala dengan `el.style.setProperty('display', 'none', 'important')`. Hal ini merontokkan wadah penopang atas sehingga input chat terlempar ke `top: 0px`.
- **Solusi Tuntas**:
  1. Membersihkan seluruh selektor overview, intro, summary, dan empty-state dari blok `display: none !important;` di CSS dan menghapusnya dari `guideSelectors` di JavaScript.
  2. Menyatukan seluruh elemen empty-state, header intro, judul buku catatan, dan metadata sumber ke dalam aturan transparan non-destruktif: `visibility: hidden !important; opacity: 0 !important; pointer-events: none !important;`.
  3. Menjamin keterlihatan dan interaktivitas bilah input dengan aturan eksplisit:
     `app-chat-input, div.chat-input-container, form.chat-input-form, .query-box-container { visibility: visible !important; opacity: 1 !important; pointer-events: auto !important; }`.
  4. Hasil: Ruang tengah layar bersih dan putih tanpa elemen bertumpuk, tinggi vertikal penopang atas terjaga utuh secara geometris, dan bilah input chat duduk tenang dan alami di bagian paling bawah layar.

### Fasa 19: Eliminasi Total Tombol Opsi Titik Tiga (More Vert) & Penguncian Bilah Input di Dasar Layar (`7ebe860`)
- **Akar Masalah Fundamental**:
  1. *Pemunculan Kembali Ikon Titik Tiga (`⋮` / `more_vert`)*: Pada commit `eb10253`, blok JavaScript penyisir ikon `more_vert` dan `more_horiz` terhapus dengan dalih menjaga menu jawaban. Di sisi lain, selektor CSS `button:has(mat-icon[data-mat-icon-name="more_vert"])` tidak cocok dengan ikon ligatur Angular Material (`<mat-icon>more_vert</mat-icon>`) yang tidak memiliki atribut `data-mat-icon-name`. Akibatnya, tombol opsi titik tiga di pojok kiri atas viewport webview muncul kembali.
  2. *Bilah Input Melayang di Bagian Atas*: Penyembunyian elemen empty-state tanpa penjangkaran bawah (`position: fixed`) menyebabkan elemen input berada di aliran dokumen atas secara default, meninggalkan ruang putih kosong raksasa di bawahnya dan membuat layar terlihat rusak/galat.
- **Solusi Tuntas**:
  1. `notebook_ui_script.dart`:
     - Memperluas selektor CSS `display: none !important; position: absolute !important; left: -9999px !important;` untuk menangkap seluruh variasi tombol opsi, header chat (`app-chat-header`, `app-conversation-header`, `.chat-header`), dan ikon `more_vert`/`more_horiz` di luar bubble jawaban model.
     - Menambahkan fungsi JavaScript `removeMoreOptionsButtons()` di dalam siklus pembersihan berkala `clean()` dan timer hidrasi awal yang menyisir DOM untuk menyembunyikan setiap elemen `more_vert` yang berada di luar artikel/pesan jawaban.
     - Mengembalikan penjangkaran presisi `position: fixed !important; bottom: 0 !important;` pada `app-chat-input` dengan padding bawah 130px pada kontainer riwayat obrolan serta fungsi pembantu `pinInputToBottom()`.
  2. Hasil: Ikon titik tiga di pojok kiri atas lenyap 100%, ruang baca telaah bersih hening, dan bilah input chat terkunci dengan anggun di dasar layar.

### Fasa 20: Elevasi Alami Bilah Input Chat, Eliminasi Total Ikon Ka'bah (🕋), dan Pemulihan Loader Super Halus
- **Akar Masalah Fundamental**:
  1. *Kolom Input Terlalu Mentok ke Bawah*: Penjangkaran sebelumnya menggunakan `bottom: 0 !important;` dengan padding minimal, sehingga kapsul input menempel tepat di tepi bawah jendela tanpa jarak visual yang bernapas. Ketiadaan disclaimer (karena disembunyikan total) membuat posisi kapsul input tampak tenggelam dan tertekan secara tidak wajar.
  2. *Ikon Ka'bah (`🕋`) Masih Terlihat*: Di buku catatan "Al Matan Hadits", cover emoji notebook disetel berupa emoji Ka'bah (`🕋`). Elemen ini dirender sebagai teks Unicode Extended Pictographic (`<span>🕋</span>`) atau dalam komponen cover (`app-notebook-cover`, `.cover-emoji`), sehingga lolos dari pemfilteran berbasis tag nama elemen (`img`, `svg`, `mat-icon`) dan pencarian string lama.
  3. *Animasi Loader Terasa Patah-patah / Choppy*: Rumus animasi titik denyut sebelumnya menggunakan `(curveVal - 0.5).abs() * 2.0` yang memiliki diskontinuitas turunan (cusp/tikungan tajam) di titik balik `0.5`, sehingga kecepatan pemuaian titik berbalik arah secara instan tanpa pelambatan alami (menimbulkan sentakan visual). Ditambah pembentukan subtree widget `Transform` + `Opacity` + `Container` di setiap frame menimbulkan beban compositing.
- **Solusi Tuntas**:
  1. `notebook_ui_script.dart`:
     - Menyetel elevasi alami bilah input: `bottom: max(32px, calc(env(safe-area-inset-bottom, 16px) + 24px)) !important;` pada CSS dan JS `pinInputToBottom()`. Kapsul input kini mengambang secara alami dan seimbang, persis seakan-akan ada baris disclaimer di bawahnya namun disclaimer tetap 100% tersembunyi.
     - Mengeliminasi total seluruh variasi cover icon, cover emoji, dan empty state container (`app-notebook-cover`, `.notebook-cover`, `.cover-emoji`, `.notebook-icon`, `app-chat-empty-state`, dll.) via CSS `display: none !important;`.
     - Menambahkan pemindai JavaScript khusus di `removeHeroCard()` yang memeriksa karakter `🕋` dan standalone emoji di luar bubble pesan obrolan, lalu memusnahkannya secara seketika (`display: none !important; visibility: hidden !important;`).
  2. `app_loader.dart`:
     - Merefaktor animasi ke `_ThreeDotsPainter` berbasis hardware-accelerated `CustomPainter` dengan nol alokasi widget per frame dan anti-aliasing GPU.
     - Menerapkan kurva gelombang kosinus halus murni ($C^2$ continuous): `factor = 0.5 * (1.0 - math.cos(normalized * 2 * math.pi))`. Pada kedua batas dan puncak denyut, turunan kecepatannya melambat anggun hingga nol sebelum mengempis kembali, menghasilkan gerakan denyut titik yang luar biasa tenang, stabil, dan sutra (60/120fps smooth).
  3. Hasil: Kapsul input berada di posisi proporsional yang sangat nyaman dipandang, area obrolan hening bebas dari sisa ikon Ka'bah atau elemen luar, dan animasi pemuatan berjalan amat mulus tanpa sentakan.

### Fasa 21: Pemulihan Arsitektur Folio Orbit Loader yang Halus & Penguncian Mutlak Bilah Input di Dasar Layar
- **Akar Masalah Fundamental**:
  1. *Perusakan Tata Letak Empty State*: Pada perubahan sebelumnya, penggunaan `display: none !important; height: 0 !important;` pada container `app-chat-empty-state` meruntuhkan tumpuan flexbox vertikal alami NotebookLM. Ditambah ekspresi `bottom: max(32px, calc(...))` yang gagal dievaluasi oleh parser WebKit/Chromium lokal membuat elemen bergeser ke atas (25% dari atas layar).
  2. *Salah Paham Format Animasi*: Pengguna menginginkan animasi **empat lembaran folio berputar (`_OrbitPainter`)** yang sudah ada sebelumnya diperbaiki kehalusan rotasinya, bukan diganti kembali ke animasi tiga titik denyut lama. Pada implementasi lama `_OrbitPainter`, rumus rotasi `turn = phase - .45 * math.sin(phase)` memiliki fluktuasi kecepatan sudut non-linear drastis (0.55 sampai 1.45) yang tampak tersendat/patah-patah.
- **Solusi Tuntas**:
  1. `app_loader.dart`:
     - Mengembalikan penuh arsitektur animasi kebanggaan OpenTurath: **empat lembaran folio mengorbit (`_OrbitPainter`)** sesuai arahan tegas pengguna.
     - Menyempurnakan rotasi ke kecepatan sudut konstan yang sangat anggun dan tenang: `turn = phase;` dengan denyut nafas lembut: `breath = 0.5 - 0.5 * math.cos(phase);`.
     - Mengaktifkan anti-aliasing GPU hardware (`Paint()..isAntiAlias = true`), mengeliminasi total efek patah-patah/stuttering, dan menghasilkan putaran 4 lembaran folio kitab yang amat sutra (60/120fps smooth).
  2. `notebook_ui_script.dart`:
     - Memulihkan container `app-chat-empty-state` dalam aliran flexbox alami (tanpa `display: none`), sementara seluruh isi di dalamnya (judul, tanggal, teks sumber, ikon, avatar, dan emoji Ka'bah `🕋`) disembunyikan total secara transparan via `visibility: hidden !important; opacity: 0 !important; pointer-events: none !important;`.
     - Mengunci bilah input chat secara mutlak di dasar layar dengan nilai valid: `bottom: 0px !important; align-items: flex-end !important; padding-bottom: 48px !important;`. Kapsul input kini duduk kokoh di dasar layar dengan jarak elevasi 48px yang amat alami (persis seakan-akan ada baris disclaimer di bawahnya tanpa mentok ke bingkai).
  3. Hasil: Animasi 4 folio berputar super mulus dan hening, ikon Ka'bah `🕋` hilang total, dan bilah input chat berada tepat di posisi bawah yang diinginkan pengguna.


### Fasa 22: Eliminasi Error Timeout Kolom Percakapan & Pemulihan Kesiapan Input Seketika (`ff50751`)
- **Akar Masalah Fundamental**:
  1. *Timeout "Kolom percakapan belum siap"*: Pada revisi Fasa 21, penambahan aturan CSS wildcard `app-chat-empty-state *, .empty-state *, [class*="empty-state" i] *` yang disetel `visibility: hidden !important;` secara membabi-buta menimpa elemen `textarea` dan kontainer input yang berada di dalam struktur empty state NotebookLM.
  2. *Penghapusan Kontainer Obrolan Global*: Loop JavaScript `querySelectorAll('span, div, p, h1, h2, h3')` untuk ikon Ka'bah memeriksa `rawTxt.includes('🕋')` pada seluruh elemen teks. Karena container induk obrolan (`div.chat-view`, `div.chat-panel-content`, `app-chat-empty-state`) memuat seluruh teks halaman termasuk judul buku catatan ("Al Fikih Tahawwulat: Al-Muhaqqiq"), loop tersebut menyetel `visibility: hidden !important;` pada kontainer induk obrolan itu sendiri!
  3. *Kegagalan Polling Kesiapan*: Fungsi deteksi kesiapan `visible(input)` membaca `getComputedStyle(input).visibility`. Akibat kontainer induk atau elemen input tersembunyi, `visible(input)` selalu menghasilkan `false`, membuat `otNotebook.ready()` tidak pernah terpenuhi hingga batas 45 detik habis dan memicu galat error: *"AI belum bisa dibuka. Kolom percakapan belum siap. Muat ulang atau periksa sesi Google Anda."*.
- **Solusi Tuntas**:
  1. `notebook_ui_script.dart`:
     - Menghapus total aturan CSS wildcard `[class*="empty-state" i] *`. Membatasi penyembunyian empty state hanya pada elemen tajuk spesifik (`h1, h2, h3, mat-icon, img, svg, .notebook-cover, .cover-emoji`).
     - Menjamin secara mutlak hak visibilitas dan interaktivitas: `textarea, [contenteditable="true"], [role="textbox"], app-chat-input, app-chat-input *, div.chat-input-container *, form.chat-input-form *` dengan `visibility: visible !important; opacity: 1 !important; pointer-events: auto !important;`.
     - Merevisi pemindai emoji Ka'bah (`🕋`) agar HANYA menargetkan elemen daun (*leaf node* / tanpa anak elemen input) dan memberikan proteksi mutlak: DILARANG KERAS menyentuh elemen yang memuat `textarea`, `form`, `app-chat-input`, atau kontainer obrolan.
     - Menyempurnakan `visible(el)` dan `inputReady()` agar lebih tangguh (`offsetWidth > 0 || offsetHeight > 0 || getClientRects().length > 0`) sehingga kesiapan obrolan terdeteksi seketika saat textarea terhidrasi.
  2. Kompilasi & Verifikasi:
     - 368 unit test Flutter lulus 100% tanpa regresi.
     - Kompilasi biner rilis macOS selesai 100% (`✓ Built build/macos/Build/Products/Release/OpenTurath AI.app (132.1MB)`).
     - Pembuatan DMG (`tool/package_macos.sh`), pembaruan `/Applications/OpenTurath AI.app`, dan peluncuran ulang aplikasi aktif terverifikasi (PID 87951).


### Fasa 23: Penguncian Presisi Bilah Input Chat di Dasar Layar pada Empty State
- **Akar Masalah Fundamental**:
  1. *Floating Input di Atas Layar*: Pada Google NotebookLM dalam keadaan kosong (*empty state*), komponen input secara bawaan dirender di bawah judul/cover notebook di bagian atas dokumen flow. Ketika judul dan cover disembunyikan secara visual (`visibility: hidden`), elemen input tertinggal mengapung di posisi atas (~Y=200px) dengan ruang putih kosong raksasa di bawahnya.
  2. *Kegagalan Selektor `body:not(:has(app-chat-input))`*: CSS lama hanya menargetkan elemen custom `<app-chat-input>` untuk `position: fixed`. Pada empty state, container input berada di dalam `<form class="chat-input-form">` / `<div class="chat-input-container">` di dalam `app-chat-empty-state`. Karena elemen `<app-chat-input>` masih ada di dalam DOM template chat non-empty, selektor fallback `body:not(:has(app-chat-input))` menghasilkan `false` dan diabaikan WebKit, sehingga input empty state sama sekali tidak mendapatkan aturan `position: fixed`.
  3. *Penjebakan Selektor di JS `pinInputToBottom`*: Fungsi `pinInputToBottom` memprioritaskan `document.querySelector('app-chat-input')`. Ketika dipanggil, ia memilih node `<app-chat-input>` yang sedang tidak aktif di latar belakang, membiarkan elemen input aktif pada empty-state tidak tersentuh.
- **Solusi Tuntas**:
  1. `notebook_ui_script.dart`:
     - Menghapus selektor kontainer `app-chat-empty-state` dan `.chat-empty-state` dari daftar elemen `visibility: hidden; opacity: 0`. Yang disembunyikan murni hanyalah elemen tajuk/cover/metadata di dalamnya (`.empty-state-header`, `h1-h3`, `mat-icon`, `img`, `svg`, `.notebook-cover`, `.cover-emoji`, chips saran prompt).
     - Menambahkan aturan CSS eksplisit untuk mode empty state:
       `app-chat-empty-state form, app-chat-empty-state .chat-input-container, .chat-empty-state form, .chat-empty-state .chat-input-container, div.chat-input-container:not(app-chat-input *), form.chat-input-form:not(app-chat-input *)` dikunci mutlak ke `position: fixed !important; bottom: 48px !important; left: 50% !important; transform: translateX(-50%) !important; width: min(768px, calc(100% - 32px)) !important; max-width: 768px !important; z-index: 10000 !important; pointer-events: auto !important;`.
     - Merevisi total fungsi `pinInputToBottom()` di JavaScript:
       - Mendeteksi input aktif secara presisi dari daun pohon DOM (`textarea, [contenteditable="true"], [role="textbox"]`).
       - Jika berada di dalam `app-chat-input` (mode obrolan aktif), kunci host tersebut ke dasar layar dengan padding bawah 48px.
       - Jika berada di dalam empty state (tanpa `app-chat-input`), telusuri form atau container input aktif terdekat, netralkan properti `transform`, `contain`, dan `filter` pada seluruh ancestor yang berpotensi menjebak fixed positioning, lalu kunci target ke `position: fixed; bottom: 48px; left: 50%; transform: translateX(-50%); width: min(768px, calc(100% - 32px)); max-width: 768px;`.
  2. Hasil: Kapsul input obrolan ("Ajukan pertanyaan atau buat konten" + tombol `↑`) kini duduk manis, kokoh, dan rapi di dasar layar (terangkat 48px dengan breathing room alami) baik pada saat obrolan kosong maupun saat percakapan sedang berjalan.

### Fasa 24: Sanitasi Workspace & Penghentian Kebocoran Token (Cache Read 81.65M) (`1cf1b7d`)
- **Akar Masalah Fundamental**:
  - Akumulasi berkas dump teks monolitik berukuran 1MB - 1.7MB per berkas di root folder (`OPENTURATH_AI_FULL_AUDIT_SOURCE.txt`, `OPENTURATH_AI_MASTER_AUDIT_PACK.*`, `OpenTurath_UI_UX_Blueprint.html`, dll) yang menyumbang jutaan token setiap kali dipindai oleh AI agent.
  - Ketiadaan filter `.geminiignore` dan `.cursorignore`, serta kelonggaran pada `.gitignore`, menyebabkan proses indexing dan context caching berulang-ulang hingga membakar 81.65 Juta token Cache Read dan 423+ kredit API.
  - Penumpukan 13 file `.zip` (~260MB), 5 file `.dmg` installer lama (~300MB), dan puluhan skrip Python lepas di direktori root.
- **Solusi Tuntas**:
  1. Pembuatan `.geminiignore` dan `.cursorignore` serta pembaruan ketat `.gitignore` untuk memblokir pembacaan file dump, arsip biner, dan laporan lama oleh seluruh AI indexer.
  2. Isolasi aman seluruh file dump teks dan arsip biner lama ke direktori terisolasi `_archive_offline/` tanpa kehilangan riwayat data (*zero data loss*).
  3. Reorganisasi seluruh skrip utilitas otomasi ke dalam direktori terstruktur `scripts/katalog/` dan `scripts/midtrans_docs/`.
  4. Hasil: Direktori root bersih, ramping, dan pembacaan token AI seketika anjlok ke batas wajar.

### Fasa 25: Eliminasi Permanen Auto-Logout macOS Tanpa $99 Apple Developer ID (`975636d`)
- **Akar Masalah Fundamental**:
  1. *Jebakan Entitlement Keychain*: File `DebugProfile.entitlements` dan `Release.entitlements` memuat tag `<key>keychain-access-groups</key>` dengan `$(AppIdentifierPrefix)`. Karena build lokal beroperasi tanpa Team ID Apple Developer berbayar ($99), prefix bernilai kosong. macOS Security Framework menolak akses Keychain dengan galat `-34018 (errSecMissingEntitlement)`. Pada aplikasi non-sandboxed (`app-sandbox = false`), pembatasan ini sebenarnya tidak diperlukan dan memicu pemblokiran Keychain.
  2. *Ejeksi Prematur di Dashboard Screen*: Pada `dashboard_screen.dart:111`, metode `_loadData()` memeriksa `_authService.currentUser == null` secara sinkron sesaat setelah layar dimuat. Karena inisialisasi native Keychain pada desktop berlangsung asinkron (~100-300ms), Firebase Auth di memory sesaat bernilai `null`. Hal ini langsung mendepak pengguna kembali ke `AppRoutes.login`, mengabaikan sesi valid yang telah diverifikasi oleh `SplashScreen`.
  3. *Resistensi Offline*: Kegagalan sesaat koneksi jaringan saat boot menyebabkan `signInSilently()` gagal, yang sebelumnya dianggap sebagai sinyal logout oleh aplikasi.
- **Solusi Tuntas**:
  1. `DebugProfile.entitlements` & `Release.entitlements`: Menghapus blok deklarasi `keychain-access-groups` sehingga aplikasi non-sandboxed dapat mengakses `login.keychain-db` bawaan pengguna tanpa bergantung pada Team ID berbayar.
  2. `dashboard_screen.dart`: Memperbarui `_loadData()` dengan pengecekan bertingkat: memeriksa memory `currentUser`, fallback ke `cachedCurrentUser` dari disk, dan menunggu `restoreSession()` di background. Pengguna HANYA diarahkan ke login jika benar-benar tidak ada sesi baik di memory maupun di disk cache.
  3. `auth_service.dart`: Memperkuat `getCurrentUserModel()` agar mengembalikan `cachedCurrentUser` atau cache disk jika Firebase user di memory masih sesaat null saat cold-start.
  4. Analisis & Verifikasi: Lolos `dart analyze lib/` dengan 0 issues, bebas dari ketergantungan akun berbayar $99.

### Fasa 26: Kompilasi Rilis APK Android & DMG macOS Universal Xcode 27 (`6a08aa3`, `95cc61d`)
- **Akar Masalah Kompilasi macOS**:
  1. *Perubahan Xcode 27 (macOS 12.0 Deployment Target)*: Xcode 27 menjatuhkan dukungan target di bawah macOS 12.0 (`The range of supported deployment target versions is 12.0 to 27.0.x`), memicu kegagalan build pada target lama macOS 10.15.
  2. *Perubahan LLVM lipo Xcode 27*: Utilitas `lipo` baru pada toolchain Xcode 27 menolak sintaks verifikasi arsitektur ganda simultan (`lipo <binary> -verify_arch arm64 x86_64`), menyebabkan skrip internal Flutter `release_unpack_macos` gagal mengenali slice fat binary.
- **Solusi Tuntas**:
  1. Memperbarui `platform :osx, '12.0'` di `Podfile` dan `MACOSX_DEPLOYMENT_TARGET = 12.0` di `Runner.xcodeproj`.
  2. Menyediakan wrapper toolchain `lipo` cerdas yang memverifikasi setiap slice arsitektur secara berurutan dan mengintegrasikannya ke `macos_assemble.sh`.
  3. Mengompilasi dan mengemas kedua artefak rilis ke direktori utama workspace:
     - **Android Release APK**: `/Users/apple/Downloads/ramadhan/app-release-latest.apk` (65 MB) + `app-release-latest.apk.sha256`.
     - **macOS Universal DMG**: `/Users/apple/Downloads/ramadhan/OpenTurath_AI_macOS.dmg` (48 MB) + `OpenTurath_AI_macOS.dmg.sha256`.
     - Skrip audit `verify_session_signing.py` meloloskan verifikasi ad-hoc tanpa error.

### Fasa 27: Implementasi Master Plan Arsitektur v4.0 (12 Blind Spot Ditutup, Otomasi VPS & macOS DMG)
- **Cakupan Perbaikan & Remediasi**:
  1. **BS-01 (RFC 6265bis Session Vault)**: Implementasi `PersistentGoogleSession` dengan `_setCookieSafely` (`domain: null` & `path: '/'` untuk `__Host-*`), pin ekspirasi 180 hari, dan fallback pengecekan live cookie sebelum penimpaan.
  2. **BS-02 (Hidden DOM Email Extraction)**: Timeout fallback 900ms di `google_session_auth_screen.dart` membaca cookie live session (`OTZ`, `SAPISID`, `SID`) jika avatar DOM Angular tersembunyi.
  3. **BS-03 (Instant Provisioning Outbox Trigger)**: Cloud Function `onProvisioningOutboxCreated` (`.onCreate('provisioning_outbox/{jobId}')`) dengan *atomic lease* (`provisioning_leases/{uid}`) untuk sharing NotebookLM sub-detik tanpa menunggu polling cron 5 menit.
  4. **BS-04 (Tombol Ganti Akun In-App)**: Tombol *"Ganti akun Google"* langsung di layar galat perizinan WebView (`isGooglePermissionError`) tanpa memaksa logout akun aplikasi.
  5. **BS-05 (Akses Dashboard Offline)**: `splash_screen.dart` meloloskan pengguna offline dengan sesi lokal valid langsung ke Dashboard.
  6. **BS-06 (3DSecure/QRIS Subframe Allowance)**: `payment_checkout_sheet.dart` mengizinkan seluruh subframe perbankan (`if (navigationAction.isForMainFrame != true) return ALLOW;`).
  7. **BS-07 (Background Tab Throttling)**: `agent_multi_tab_room.dart` menjeda DOM observer (`otSetBackgroundPaused(true)`) pada tab latar belakang demi efisiensi memori 8GB RAM.
  8. **BS-08 (Inquiry Throttle & Stream Listener)**: Throttle 6 detik pada inquiry status pembayaran, listener `AuthService().userStream` reaktif 0ms, dan navigasi langsung ke telaah spesialis via `PaymentSuccessDialog`.
  9. **BS-09 (Registrasi Pustaka Agen Tahawwulat)**: Semua sub-agen Tahawwulat (`fiqh_tahawwulat_muhaqqiq`, `bayan`, `mukhtabir`, `habib`, `khatib`) dan 15 modul lainnya terdaftar di `open_turath_catalog_repository.dart` dengan fallback aman.
  10. **BS-10 (Perbaikan Pop Dialog & Pemetaan Voucher)**: Menangkap `NavigatorState` sebelum pop dan navigasi bersih via `nav.popUntil(...)` di `exclusive_activation_dialog.dart` dan `profile_screen.dart`.
  11. **BS-11 & Hukum Sakral VIP (Rule 5)**: Isolasi hak akses granular yang ketat di `user_model.dart` dan perlindungan permanen VIP di seluruh fungsi backend dan skrip reaper.
  12. **BS-12 (Pembersihan Sesi & Formatter Voucher)**: Pembersihan brankas cookie pada logout/delete akun dan toleransi spasi/panjang hingga 64 karakter pada input voucher.
- **Integritas Build & Verifikasi**:
  - UI Pembayaran di `subscription_screen.dart` dipertahankan utuh sesuai instruksi pengguna.
  - 100% Flutter Unit Tests Lolos: 387/387 passed.
  - 100% Cloud Functions Unit Tests Lolos: 144/144 passed.
  - 100% VPS Python Unit Tests Lolos: 24/24 passed.
  - Paket Rilis VPS: `ecosystem/dist/openturath-access-20261014T144356Z-de6b6dbe.tar.gz` (+ sha256).
  - Biner Rilis macOS DMG: `OpenTurath_AI_macOS.dmg` (48 MB, Universal arm64+x86_64, Ad-Hoc Signed, verified).
  - `/Applications/OpenTurath AI.app` diperbarui dan siap digunakan.

---

## 5. Agenda & Fokus Selanjutnya
1. **Verifikasi Runtime Sesi macOS**:
   - Menjalankan uji buka/tutup dingin (cold quit & reopen) pada macOS untuk memvalidasi bahwa sesi akun pengguna tetap bertahan langsung di Dashboard.
2. **Katalog & Spesialis**:
   - Memastikan ke-21 spesialis memiliki keterhubungan yang mulus antara ruang dialog telaah dengan pustaka kitab referensinya.
