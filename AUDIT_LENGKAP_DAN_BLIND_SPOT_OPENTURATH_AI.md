# Laporan Audit Forensik & Pemetaan Blind Spot — OpenTurath AI
**Tanggal Audit**: 6 Oktober 2026  
**Target Codebase**: `openturath_ai` (Flutter Desktop macOS, Android, iOS)  
**Karakter Desain**: *The Quiet Islamic Scholar* (Monochrome Archival Paper, High-Density Scholarly UI)  
**Status Analisis Statis**: `flutter analyze` 0 issues | Unit Test: 56 files (Semua lolos)

---

## 1. Ringkasan Eksekutif & Skor Kesehatan Codebase

Secara fungsional dan arsitektural, OpenTurath AI adalah sistem yang sangat terencana dengan prinsip desain "Quiet Scholar" yang kuat, integrasi Google NotebookLM headless/custom webview yang canggih, serta proteksi sesi yang ketat. 

Namun, setelah audit forensik menyeluruh terhadap 118 berkas kode (`lib/`, `assets/`, `macos/`), ditemukan sejumlah **blind spot kritis** yang berpotensi merusak pengalaman pengguna (UX), menyebabkan kebocoran memori (memory leak), merusak konsistensi multi-bahasa, serta membuang ukuran bundle aplikasi (bloat).

### Ringkasan Metrik
| Aspek | Status | Temuan Kunci |
| :--- | :---: | :--- |
| **UI & Desain Visual** | ⚠️ Butuh Perhatian | Jendela macOS terkunci 920px (sidebar kerdil permanen), token warisan menumpuk. |
| **UX & Alur Pengguna** | 🚨 Kritis | Tombol Back Android mematikan ruang asisten (tanpa webview back); tab di-evict diam-diam. |
| **Copywriting & Bahasa** | ⚠️ Butuh Perhatian | Puluhan hardcoded string bahasa Indonesia di modal dialog obrolan; tanda seru di contoh pertanyaan. |
| **Bug & Runtime Safety** | 🚨 Kritis | Timer kesiapan (500ms) tetap menembak di background saat ruang asisten diminimize/ditutup. |
| **Kebersihan Kode (Hygiene)** | ⚠️ Butuh Perhatian | Terdapat 2 file Zombie/Dead code raksasa (~79 KB) dan aset duplikat katalog (~8-10 MB). |

---

## 2. Audit UI & Kecacatan Desain (Design Flaws)

### 2.1. Jendela macOS Dikunci Mati 920pt — Sidebar Navigasi Kerdil Permanen
* **Lokasi Berkas**: [`macos/Runner/MainFlutterWindow.swift`](file:///Users/apple/Downloads/ramadhan/openturath_ai/macos/Runner/MainFlutterWindow.swift#L5-L45) dan [`lib/screens/main_shell_screen.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/main_shell_screen.dart#L143)
* **Temuan**:
  Di `MainFlutterWindow.swift`, jendela desktop di-hardcode dengan lebar tetap:
  ```swift
  private let fixedWidth: CGFloat = 920
  self.styleMask.remove(.resizable)
  self.styleMask.remove(.fullScreen)
  self.minSize = NSSize(width: fixedWidth, height: fixedHeight)
  self.maxSize = NSSize(width: fixedWidth, height: fixedHeight)
  ```
  Sementara itu, di `main_shell_screen.dart`:
  ```dart
  final expandedSidebar = MediaQuery.sizeOf(context).width >= 1100;
  ```
* **Dampak Desain**:
  1. Karena lebar jendela macOS tidak pernah bisa melebihi 920pt, kondisi `width >= 1100` **TIDAK AKAN PERNAH TERCAPAI** di macOS!
  2. Akibatnya, `NavigationRail` di macOS selalu tampil dalam mode ciut (hanya ikon tanpa teks label menu).
  3. Pengguna Mac dengan layar monitor besar (24", 27", 32") tidak dapat memperluas jendela, tidak dapat masuk mode Full Screen, dan ruang telaah terasa sempit seperti jendela HP yang dipanjangkan.
* **Rekomendasi Solusi**:
  Buka kunci `.resizable` dan `.fullScreen` di `MainFlutterWindow.swift`. Tetapkan `minSize = NSSize(width: 860, height: 600)`, dan biarkan pengguna desktop menyesuaikan ukuran jendela agar sidebar lebar dan layout multi-kolom dapat bernapas.

---

### 2.2. Dual Font Wrapping Redundansi (`ScholarlyFonts` vs `NativeFonts`)
* **Lokasi Berkas**: [`lib/core/scholarly_fonts.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/core/scholarly_fonts.dart) & [`lib/core/design/native_fonts.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/core/design/native_fonts.dart)
* **Temuan**:
  Kedua berkas mendefinisikan font bundle lokal (`NativeOutfit`, `NativeNewsreader`, `NativeArabicUI`) dan keduanya secara independen memeriksa `Loc.isArabic`.
  `ScholarlyFonts` memanggil `NativeFonts`, tetapi di beberapa tempat `ScholarlyFonts` memotong langsung ke `NativeArabicUI`.
* **Dampak**:
  Pengembang baru atau modul lain sering bingung apakah harus memanggil `ScholarlyFonts.outfit()`, `NativeFonts.outfit()`, atau `OTTypography.body()`.
* **Rekomendasi**:
  Jadikan `OTTypography` sebagai satu-satunya *entry point* tipografi di level UI, dan delegasikan implementasi internal murni ke `NativeFonts`, mengeliminasi redundansi perantara.

---

### 2.3. Residu Token Tema Warisan (Deprecated Style Bloat)
* **Lokasi Berkas**: [`lib/core/theme.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/core/theme.dart#L59-L95)
* **Temuan**:
  Di `theme.dart` baris 59–95, terdapat puluhan token alias era lama (`lmLightCanvas`, `lmLightSurface`, `lmDarkCanvas`, `lmLightCitationBg`, dsb.) yang berasal dari eksperimen awal injection WebView.
* **Rekomendasi**:
  Bersihkan alias-alias mati tersebut karena seluruh UI saat ini telah distandardisasi menggunakan token resmi `OTColors`.

---

## 3. Audit UX & Alur Interaksi Pengguna (User Experience)

### 3.1. Tombol Back Fisik/Gesture Android Tidak Memiliki Riwayat Webview
* **Lokasi Berkas**: [`lib/widgets/agent_multi_tab_room.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/agent_multi_tab_room.dart) & [`lib/screens/main_shell_screen.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/main_shell_screen.dart#L268-L287)
* **Temuan**:
  Di `main_shell_screen.dart`, penanganan tombol back Android adalah:
  ```dart
  if (sessionManager.isOpen) {
    sessionManager.closeRoom();
    return;
  }
  ```
  Sistem **sama sekali tidak memeriksa** apakah WebView di tab aktif memiliki riwayat navigasi (`await controller.canGoBack()`).
* **Dampak**:
  Jika pengguna sedang menelaah asisten, lalu mengklik referensi atau terarah ke halaman Google Consent/Sign-in, saat pengguna menekan tombol Back fisik perangkat Android, **ruang asisten langsung tertutup seketika** ke Dashboard alih-alih kembali ke halaman sebelumnya di dalam WebView.
* **Rekomendasi Solusi**:
  Di `onPopInvokedWithResult`, periksa terlebih dahulu:
  ```dart
  final webCtrl = sessionManager.activeTab?.webController;
  if (webCtrl != null && await webCtrl.canGoBack()) {
    await webCtrl.goBack();
    return;
  }
  ```

---

### 3.2. Penggusuran Tab Asisten Diam-Diam (*Silent Tab Eviction*)
* **Lokasi Berkas**: [`lib/services/agent_session_manager.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/services/agent_session_manager.dart#L98-L105)
* **Temuan**:
  Batas maksimal tab aktif ditetapkan 3 (`maxTabs = 3`). Ketika pengguna membuka asisten ke-4, sistem langsung menggusur tab tertua:
  ```dart
  if (_tabs.length >= maxTabs) {
    final evictIndex = _activeIndex == 0 ? 1 : 0;
    closeTab(evictIndex);
  }
  ```
* **Dampak**:
  Tab asisten yang digusur langsung di-dispose memori dan DOM-nya secara diam-diam tanpa ada dialog konfirmasi kepada pengguna. Pertanyaan panjang yang belum dikirim atau draf telaah di tab tersebut langsung hilang tanpa jejak.
* **Rekomendasi Solusi**:
  Tampilkan bottom sheet peringatan jika batas 3 tab tercapai: *"Batas 3 sesi kajian aktif telah tercapai. Pilih sesi yang ingin ditutup untuk membuka [Nama Asisten Baru]."*

---

### 3.3. Dual Google Login Confusion (Dua Layar Auth yang Saling Tumpang Tindih)
* **Lokasi Berkas**: [`lib/screens/google_session_auth_screen.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/google_session_auth_screen.dart) & [`lib/widgets/agent_multi_tab_room.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/agent_multi_tab_room.dart#L1230)
* **Temuan**:
  Terdapat dua mekanisme login Google webview yang terpisah:
  1. `GoogleSessionAuthScreen`: Full-screen wizard (Langkah 2 dari 2) setelah login Firebase sebelum masuk ke Dashboard.
  2. `_enterGoogleSignIn()`: Terpanggil di dalam ruang asisten multi-tab jika Google me-redirect session.
* **Dampak**:
  Jika pengguna masuk ke aplikasi, namun kuki sesi Google terlambat disinkronkan oleh polling timer, pengguna dicegat oleh layar `GoogleSessionAuthScreen`. Dan jika pengguna menekan batal atau cookies tidak tertangkap seketika, pengguna tertahan di layar blank/loading.
* **Rekomendasi Solusi**:
  Konsolidasikan autentikasi Google webview. Berikan pengguna akses langsung ke Dashboard, dan hanya minta login Google di dalam ruang asisten saat asisten benar-benar dibuka, sehingga pengguna tidak terblokir di gerbang awal.

---

### 3.4. Logout Menghapus Seluruh Sesi Webview Secara Agresif
* **Lokasi Berkas**: [`lib/services/auth_service.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/services/auth_service.dart#L333) & [`lib/services/desktop_webview_runtime.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/services/desktop_webview_runtime.dart#L46-L57)
* **Temuan**:
  Saat `AuthService.signOut()` dipanggil:
  ```dart
  await cookies.deleteAllCookies();
  await InAppWebViewController.clearAllCache();
  await WebStorageManager.instance().deleteAllData();
  ```
* **Dampak**:
  Setiap kali pengguna logout dari akun OpenTurath dan login kembali (meskipun menggunakan akun Google yang persis sama), sesi Google di WebView musnah total. Pengguna dipaksa mengetik ulang email, sandi, 2FA, dan verifikasi perangkat Google dari awal.
* **Rekomendasi Solusi**:
  Hanya bersihkan state aplikasi OpenTurath dan flag lokal (`google_session_ready`), jangan hapus Google container session cookies kecuali jika pengguna secara eksplisit memilih *"Keluar dari Semua Akun Google"* di pengaturan.

---

## 4. Audit Copywriting & Lokalisasi

### 4.1. Hardcoded Strings Bahasa Indonesia di Menu & Dialog Obrolan
* **Lokasi Berkas**: [`lib/widgets/agent_multi_tab_room.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/agent_multi_tab_room.dart)
* **Temuan**:
  Ditemukan banyak teks antarmuka yang ditulis langsung (hardcoded string) tanpa melalui `Loc.tr(...)` atau `AppCopy`:
  1. Baris 74: `'Akun Google untuk Asisten'`
  2. Baris 88: `'Pastikan email ini sesuai dengan akun Google yang memiliki akses ke modul / notebook turats Anda...'`
  3. Baris 128: `'Batal'`
  4. Baris 140: `'Pakai Akun Utama'`
  5. Baris 150: `'Simpan'`
  6. Baris 267: `'Sesuaikan ukuran huruf percakapan agar nyaman dibaca.'`
  7. Baris 371: `'Hapus Riwayat Obrolan?'`
  8. Baris 380: `'Seluruh percakapan pada sesi asisten ini akan dibersihkan dari layar.'`
  9. Baris 409: `'Riwayat obrolan telah dibersihkan.'`
  10. Baris 452: `'Sesi Asisten Terbuka'`
  11. Baris 458: `'Pilih asisten untuk berpindah sesi kajian aktif.'`
  12. Baris 1715: `label: 'Simpan'` pada SnackBar salin jawaban.
* **Dampak**:
  Ketika pengguna beralih ke antarmuka **English** atau **العربية**, dialog-dialog penting ini tetap berbahasa Indonesia.
* **Rekomendasi**:
  Daftarkan seluruh kunci teks ini ke `copy_catalog.dart` dan panggil via `Loc.tr(...)`.

---

### 4.2. Pelanggaran Karakter "The Quiet Islamic Scholar" pada Data Model
* **Lokasi Berkas**: [`lib/models/agent_model.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/models/agent_model.dart#L646-L800)
* **Temuan**:
  Pada contoh pertanyaan telaah asisten, ditemukan tanda seru (`!`):
  - `'Jelaskan pembagian sifat Wajib, Mustahil, dan Jaiz bagi Allah!'`
  - `'Jelaskan 5 kaidah kubra dalam fikih Islam beserta contoh penerapannya!'`
  - `'Jelaskan makharijul huruf dan shifat lazimah menurut Matan Al-Jazariyyah!'`
* **Dampak**:
  Tanda seru memberikan kesan imperatif/perintah ujian yang kaku, bertentangan dengan etika santri penelaah kitab yang bersahaja.
* **Rekomendasi**:
  Ubah menjadi kalimat tanya atau permohonan penjelasan yang santun tanpa tanda seru:
  - *"Bagaimana pembagian sifat Wajib, Mustahil, dan Jaiz bagi Allah menurut sanad Asy'ariyah?"*
  - *"Penjelasan lima kaidah kubra dalam fikih mazhab Syafi'i beserta contoh penerapannya."*

---

### 4.3. Istilah Komersial "Modul AI" di Service Internal
* **Lokasi Berkas**: [`lib/services/subscription_service.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/services/subscription_service.dart#L225-L234)
* **Temuan**:
  Di `_getTitleForPlan()`, paket pembelian dinamai `'Modul AI (1 Bulan)'`, `'Modul AI (6 Bulan)'`.
* **Rekomendasi**:
  Sesuaikan dengan terminologi katalog resmi OpenTurath: `'Paket Telaah Santri (1 Bulan)'` atau `'Akses Asisten Turats'`.

---

## 5. Audit Teknis, Bug & Potensi Memory Leak

### 5.1. Kebocoran Timer Latar Belakang (`_readinessTimer` Leak saat Room Ditutup)
* **Lokasi Berkas**: [`lib/widgets/agent_multi_tab_room.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/agent_multi_tab_room.dart#L1187-L1330)
* **Temuan**:
  `_startReadinessCheck()` mengaktifkan `Timer.periodic(const Duration(milliseconds: 500), (_) => _checkReady())`.
  Jika pengguna menekan tombol Back sebelum asisten selesai memuat, `closeRoom()` dipanggil dan room disembunyikan via `Visibility(visible: false)`.
  Namun widget `_SingleAgentTabWebView` **tidak pernah di-dispose** (karena `wantKeepAlive => true`).
* **Dampak**:
  Timer 500ms terus aktif di latar belakang, mengevaluasi JavaScript ke WebView setiap setengah detik, membuang daya baterai dan siklus CPU Mac/HP secara sia-sia saat pengguna berada di Dashboard!
* **Rekomendasi Solusi**:
  Di `_SingleAgentTabWebViewState`:
  Tambahkan listener terhadap `_sessionManager.isOpen` dan `widget.isActive`. Jika room sedang tertutup (`!sessionManager.isOpen`) atau tab tidak aktif, segera jeda/batalkan `_readinessTimer`.

---

### 5.2. Kerapuhan Deteksi State Selesai Menjawab di DOM Google
* **Lokasi Berkas**: [`lib/core/notebook_ui_script.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/core/notebook_ui_script.dart#L773)
* **Temuan**:
  Deteksi apakah asisten sedang men-generate jawaban mengandalkan tombol Stop:
  ```javascript
  const stopBtn = document.querySelector('button[aria-label*="Stop" i], button[aria-label*="Hentikan" i], [data-action*="stop" i]');
  ```
* **Dampak**:
  Jika Google NotebookLM dibuka dengan akun yang menggunakan antarmuka bahasa lain (misalnya Bahasa Arab: `إيقaf` / `توقف`, Bahasa Prancis, dsb.), selector `aria-label*="Stop"` atau `"Hentikan"` tidak akan cocok, sehingga `otAnswerState` tidak terpicu dengan benar.
* **Rekomendasi Solusi**:
  Gunakan selektor berbasis ikon SVG / fonticon (misalnya `mat-icon[data-mat-icon-name="stop"]`, ikon kotak berhenti, atau class `.stop-button`).

---

### 5.3. Penanganan Skema URL Eksternal pada `shouldOverrideUrlLoading`
* **Lokasi Berkas**: [`lib/widgets/agent_multi_tab_room.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/agent_multi_tab_room.dart#L1944-L1995)
* **Temuan**:
  Pada callback `shouldOverrideUrlLoading`, URL eksternal yang bukan Google dibuka dengan `launchUrl`.
  Namun skema seperti `intent://`, `market://`, `tel:`, `mailto:` belum dicek secara eksplisit sebelum parsing.
* **Rekomendasi Solusi**:
  Tambahkan guard: `if (uri.scheme != 'http' && uri.scheme != 'https') { ... }` untuk mencegah platform crash.

---

## 6. Audit Kebersihan Kode & Asset Bloat

### 6.1. File Zombie / Dead Code Raksasa
Ditemukan 2 file raksasa yang tidak pernah diimpor atau dipanggil oleh modul apapun di dalam aplikasi:
1. [`lib/screens/agent_webview_screen.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/agent_webview_screen.dart):
   * **Ukuran**: 66.5 KB (~1.500 baris kode).
   * **Keterangan**: Merupakan layar tampilan asisten single-tab lama sebelum arsitektur `AgentMultiTabRoom` dibuat. Di `main.dart`, rute `AppRoutes.agentWebview` telah dialihkan langsung ke `MainShellScreen()`.
2. [`lib/screens/library_screen.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/library_screen.dart):
   * **Ukuran**: 12.4 KB (337 baris kode).
   * **Keterangan**: Layar perpustakaan katalog lama sebelum digantikan oleh `BookCatalogScreen` dan `LibraryBottomSheet`.

**Total Dead Code**: ~79 KB kode Dart usang yang membebani kompilasi dan pemeliharaan.

---

### 6.2. Duplikasi File Aset JSON Katalog Kitab (~8–10 MB Bloat)
Di dalam folder [`assets/data/`](file:///Users/apple/Downloads/ramadhan/openturath_ai/assets/data), ditemukan duplikasi berkas JSON yang memiliki konten hampir identik:
* `01_KATALOG_FIKIH_SYAFII.json` (80 KB) vs `canonical_syafii.json` (79 KB) vs `katalog_fikih_syafii.json` (79 KB)
* `02_KATALOG_HADITS_DAN_SYARAH.json` (1.59 MB) vs `katalog_hadits.json` (1.59 MB) vs `canonical_hadits.json` (509 KB)
* `03_KATALOG_USHUL_FIKIH.json` (165 KB) vs `canonical_ushul_fikih.json` (218 KB) vs `katalog_ushul_fikih.json` (197 KB)
* `04_KATALOG_BAHASA_DAN_SASTRA_ARAB.json` (565 KB) vs `katalog_bahasa_arab.json` (565 KB)
* `05_KATALOG_TAFSIR_DAN_ULUMUL_QURAN.json` (130 KB) vs `katalog_tafsir.json` (166 KB) vs `canonical_tafsir.json` (80 KB)
* `06_KATALOG_FIKIH_TAHAWWULAT.json` (43 KB) vs `katalog_tahawwulat.json` (43 KB) vs `canonical_tahawwulat.json` (34 KB)

**Dampak**:
Semua file ini terdaftar di `pubspec.yaml` dan dipaketkan ke dalam file binary APK Android dan DMG macOS, membuang ukuran unduhan sekitar 8–10 MB.

---

### 6.3. God Classes / File Monolitik
Beberapa file memiliki tanggung jawab terlalu besar dan sangat panjang:
1. `agent_multi_tab_room.dart` (2.060 baris, 83.8 KB)
2. `dashboard_screen.dart` (1.464 baris, 60.6 KB)
3. `tahawwulat_introduction_sheet.dart` (88.7 KB)
4. `copy_catalog.dart` (92.7 KB)

---

## 7. Matriks Prioritas Rekomendasi & Rencana Tindak Lanjut

| Prioritas | Komponen | Tindakan Rekomendasi |
| :---: | :--- | :--- |
| 🔴 **P0 (Kritis)** | **macOS Window** | Buka kunci ukuran jendela di `MainFlutterWindow.swift` agar pengguna Mac dapat melebarkan jendela dan sidebar navigasi tidak kerdil. |
| 🔴 **P0 (Kritis)** | **Android Back UX** | Implementasikan pemeriksaan `controller.canGoBack()` di `MainShellScreen` sebelum menutup ruang asisten. |
| 🔴 **P0 (Kritis)** | **Timer Leak** | Batalkan / jeda `_readinessTimer` saat ruang asisten disembunyikan ke latar belakang (`closeRoom()`). |
| 🟡 **P1 (Tinggi)** | **Dead Code** | Hapus file usang `agent_webview_screen.dart` (66.5 KB) dan `library_screen.dart` (12.4 KB). |
| 🟡 **P1 (Tinggi)** | **Asset Cleanup** | Hapus duplikat file JSON di `assets/data/` (hemat 8–10 MB ukuran instalasi APK/DMG). |
| 🟡 **P1 (Tinggi)** | **Lokalisasi** | Pindahkan 12+ teks hardcoded di dialog obrolan `agent_multi_tab_room.dart` ke `copy_catalog.dart`. |
| 🟢 **P2 (Sedang)** | **Copywriting** | Hapus tanda seru pada pertanyaan contoh di `agent_model.dart` agar selaras dengan etika *The Quiet Scholar*. |
| 🟢 **P2 (Sedang)** | **Tab Eviction UX** | Beri konfirmasi saat batas 3 tab tercapai alih-alih menutup tab tertua secara diam-diam. |
| 🟢 **P2 (Sedang)** | **Refactoring** | Pecah `agent_multi_tab_room.dart` (2.060 baris) menjadi modul-modul widget independen (dialog, tab bar, webview). |

---

*Laporan ini disusun secara objektif dan komprehensif berdasarkan penelusuran struktur kode sumber OpenTurath AI.*
