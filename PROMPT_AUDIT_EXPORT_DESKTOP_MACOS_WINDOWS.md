# MASTER PROMPT AUDIT FORENSIK EKSPOR DESKTOP: OPENTURATH AI
### Target Platform: macOS (Apple Silicon & Intel) & Windows (x64)
### Standar: Principal Flutter Desktop Systems Architect, Cross-Platform Runtime Specialist, & Desktop Ergonomics Lead
### Repositori Basis: OpenTurath AI (`openturath_ai`)

---

## 1. MANDAT, PERAN & PRINSIP KERJA AUDITOR

Bertindaklah sebagai **Dewan Auditor Independen Sistem Desktop Tingkat Tertinggi** yang terdiri dari:
1. **Principal Flutter Desktop Systems Architect**: Spesialis C++/AppKit runtime, FFI bindings, embedding layer macOS (`Runner.xcodeproj`, CocoaPods) dan Windows (`CMakeLists.txt`, Win32/UWP), serta siklus hidup aplikasi desktop.
2. **Staff Native Interop & Plugin Parity Auditor**: Peneliti mendalam kompatibilitas pustaka `pubspec.yaml` di luar mobile, pencegah `MissingPluginException`, `UnimplementedError`, dan penata abstraksi multiplatform.
3. **Desktop Ergonomics & Large-Screen UI/UX Lead**: Mengacu pada standar kelas dunia **Apple Human Interface Guidelines (macOS)** dan **Microsoft Fluent Design (Windows)**, spesialis transisi dari *mobile phone container* ke *scholarly desktop workbench* (layar 13" hingga ultrawide 34").
4. **Desktop Security, Sandbox & Entitlements Specialist**: Pakar macOS Hardened Runtime, sandboxing (`com.apple.security`), Keychain sharing, dan Windows MSIX isolation / High-DPI manifest.
5. **Chief Islamic Scholarship Editor**: Penjaga marwah telaah ilmiyah santri dan akademisi agar pengalaman membaca naskah turats di laptop/desktop tetap hening, tenang, dan bebas distraksi.

> **PRINSIP AUDIT (NON-NEGOTIABLE):**
> - **Zero Tolerance for Mobile Assumptions**: Kode yang mengasumsikan layar selalu portrait, selalu memiliki status bar kamera/notch, atau selalu menjalankan OS Android/iOS dianggap **CACAT KRITIS (CRITICAL DEFECT)**.
> - **Zero Tolerance for MissingPluginException**: Setiap pemanggilan plugin atau `MethodChannel` yang belum terbukti berjalan aman di macOS dan Windows tanpa crash wajib dibedah dan diberi mitigasi fallback yang elegan.
> - **No Generic Advice**: Dilarang memberi saran umum seperti *"buatlah UI responsif"*. Setiap temuan **WAJIB** menyebutkan path file, nomor baris, jalur kegagalan (*failure path*), dan **KODE PERBAIKAN LENGKAP SIAP PAKAI (Production-Ready Code Patch)**.

---

## 2. LANDASAN DAN RUANG LINGKUP AUDIT

OpenTurath AI saat ini merupakan aplikasi mobile produksi (Android) berbasis Flutter yang mengintegrasikan:
- Layanan RAG privat Google NotebookLM via `flutter_inappwebview`
- Firebase Ecosystem (`firebase_core`, `firebase_auth`, `cloud_firestore`, `cloud_functions`)
- Google Sign-In & Auth State Management
- SQLite / Shared Preferences & File Storage
- Sistem Pembaruan In-App (`UpdateService` berbasis `.apk`)
- Launcher Khusus Android (`NativeAgentLauncher` via Intent `com.google.android.apps.labs.language.tailwind`)

**Tujuan Audit:** Membedah 100% kode sumber agar OpenTurath AI dapat dikompilasi, dijalankan, dan didistribusasikan pada **macOS** dan **Windows** tanpa ada crash (*zero crash*), tanpa regresi fitur mobile yang sudah stabil, dan memiliki ergonomi desktop sekelas Linear, Notion, atau Apple Books.

---

## 3. SEMBILAN DIMENSI FORENSIK AUDIT DESKTOP

Bedah kode baris demi baris pada 9 dimensi kritis berikut:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                 9 DIMENSI AUDIT FORENSIK EKSPOR DESKTOP                     │
├─────────────────────────────────────────────────────────────────────────────┤
│ 1. DEPENDENSI & PLUGINS      │ 2. METHOD CHANNELS & NATIVE │ 3. WEBVIEW PARITY   │
│ 4. AUTH & FIREBASE DESKTOP   │ 5. STORAGE & DATABASE FFI   │ 6. ERGONOMI LAYAR   │
│ 7. KEYBOARD & MOUSE UX       │ 8. SANDBOX & ENTITLEMENTS   │ 9. UPDATE & PACKAGING│
└─────────────────────────────────────────────────────────────────────────────┘
```

---

### DIMENSI 1: AUDIT MATRIKS DEPENDENSI & PLUGIN PARITY (`pubspec.yaml`)
1. **Pemeriksaan Dukungan Desktop per Plugin**:
   - Audit seluruh dependensi di `pubspec.yaml`:
     - `flutter_inappwebview: ^6.0.0`
     - `firebase_core`, `firebase_auth`, `cloud_firestore`, `cloud_functions`
     - `google_sign_in: ^6.2.1`
     - `path_provider`, `shared_preferences`, `package_info_plus`, `device_info_plus`
     - `open_filex: ^4.7.0`
     - `url_launcher: ^6.3.0`
   - Tandai paket mana yang:
     - *(a)* Memiliki dukungan resmi macOS & Windows out-of-the-box.
     - *(b)* Memiliki dukungan macOS via CocoaPods tetapi **belum/tidak didukung resmi di Windows** (misalnya pustaka resmi Firebase SDK).
     - *(c)* Memerlukan plugin pendamping khusus desktop (misal: FFI bridge, Edge WebView2, dsb).
2. **Pembersihan Dependensi Mobile-Exclusive**:
   - Apakah ada dependensi Android-only atau iOS-only yang akan menggagalkan `cmake` di Windows atau `xcodebuild` di macOS?

---

### DIMENSI 2: METHOD CHANNELS & PLATFORM CALLS NATIVE
1. **Audit `NativeAgentLauncher` (`lib/services/native_agent_launcher.dart`)**:
   - Periksa pemanggilan `MethodChannel('com.openturath.ai/native_launcher')`:
     - Apakah fungsi `isNotebookAppInstalled()`, `launchNotebook()`, dan `shareText()` memiliki pengaman platform yang ketat?
     - Apa yang terjadi jika dipanggil di Windows atau macOS? Apakah melempar `MissingPluginException` yang tidak tertangkap?
   - Rancang arsitektur fallback: Pada macOS dan Windows, peluncuran harus otomatis dialihkan ke browser desktop default via `launchUrl` dengan mode `LaunchMode.externalApplication`.
2. **Audit Berbagi Teks / Share Sheet**:
   - Android menggunakan Intent `shareText`. Pada desktop (macOS & Windows), bagaimana teks kutipan / catatan dibagikan? Rancang fallback ke `Clipboard.setData` dengan notifikasi snackbar yang elegan.

---

### DIMENSI 3: KESIAPAN & PARITAS ENGINE WEBVIEW DESKTOP (`agent_webview_screen.dart`)
1. **Engine InAppWebView pada macOS & Windows**:
   - macOS menggunakan engine WebKit (`WKWebView`). Windows memerlukan **Microsoft Edge WebView2 runtime**.
   - Apakah `flutter_inappwebview: ^6.0.0` pada Windows memerlukan konfigurasi khusus di `windows/CMakeLists.txt`?
   - Bagaimana penanganan jika komputer Windows pengguna belum terpasang WebView2 Runtime? Apakah aplikasi langsung *force close* atau menampilkan instruksi unduh WebView2 yang bersahabat?
2. **Injeksi JavaScript & Fitur Lanjutan**:
   - Uji skrip pembersih UI NotebookLM: `turatsMasterScript`, `notebookUiScript`, dan `applyTurathFontScale`.
   - Apakah `addJavaScriptHandler` (`otCopiedAnswer`) bekerja identik antara Chromium (Windows) dan WebKit (macOS)?
   - Apakah ada perbedaan penanganan navigasi (`shouldOverrideUrlLoading`) antara macOS WKWebView dan Windows WebView2?
3. **Penyimpanan Sesi Akun Google di WebView Desktop**:
   - Apakah sesi login Google di dalam WebView desktop tersimpan persisten (*cookie persistence*) saat aplikasi desktop ditutup dan dibuka kembali?
   - Apakah User-Agent WebView desktop perlu disesuaikan agar Google tidak memblokir login dengan alasan *"This browser or app may not be secure"*?

---

### DIMENSI 4: ARSITEKTUR AUTENTIKASI & FIREBASE DI DESKTOP
1. **Ketersediaan Firebase SDK di Windows**:
   - Di macOS, Firebase didukung resmi via CocoaPods (`macos/Podfile`).
   - Di Windows, plugin resmi `cloud_firestore` dan `firebase_auth` dari Google belum mendukung C++ Windows runner secara native!
   - Audit bagaimana aplikasi menangani inisialisasi Firebase:
     - Apakah pemanggilan `Firebase.initializeApp()` di `lib/main.dart` akan melempar fatal exception di Windows?
     - Berikan arsitektur isolasi: Bagaimana sistem data OpenTurath (buku, bookmark, profil) dapat beroperasi dengan aman di Windows (misalnya via REST API fallback, mode offline-first, atau bridging yang kompatibel)?
2. **Google Sign-In di Lingkungan Desktop**:
   - Di mobile, Google Sign-In menggunakan Google Play Services atau iOS ASWebAuthenticationSession.
   - Pada macOS dan Windows, bagaimana alur Google Sign-In dijalankan? Apakah menggunakan OAuth 2.0 Loopback browser (`desktop_webview_auth` atau redirect HTTP lokal) tanpa mengorbankan keamanan token?

---

### DIMENSI 5: DATABASE LOKAL & STORAGE FFI (`sqflite` vs FFI)
1. **Inisialisasi Database SQLite**:
   - Di mobile, `sqflite` menggunakan Android/iOS SQLite native engine.
   - Di desktop (macOS & Windows), apakah ada penggunaan SQLite yang membutuhkan `sqflite_common_ffi`?
   - Pastikan terdapat kode inisialisasi:
     ```dart
     if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
       sqfliteFfiInit();
       databaseFactory = databaseFactoryFfi;
     }
     ```
2. **Penyimpanan File & Path Direktori (`path_provider`)**:
   - Apakah path penyimpanan catatan (`ApplicationDocumentsDirectory`) terisolasi dengan aman di folder `~/Library/Application Support/` (macOS) dan `%APPDATA%` (Windows)?
   - Apakah ada *hardcoded slash* `/` yang dapat patah di Windows backslash `\`? (Wajib menggunakan `path.join`).

---

### DIMENSI 6: ERGONOMI LAYAR LEBAR & ADAPTIVITAS DESKTOP (RESPONSIVE UI)
1. **Transformasi Navigasi: Bottom Bar ke Sidebar / Navigation Rail**:
   - Di mobile, `main_shell_screen.dart` menggunakan `BottomNavigationBar` di bawah layar.
   - Pada monitor 24" atau layar MacBook 14", bottom navigation bar tampak canggung dan menghabiskan ruang vertikal.
   - Rancang arsitektur layout adaptif:
     - Layar sempit (< 768px): Tetap gunakan Bottom Navigation Bar.
     - Layar lebar (≥ 768px): Berubah menjadi **Adaptive Navigation Rail / Sidebar** di sisi kiri dengan gaya editorial minimalis.
2. **Pusat Telaah Dua Kolom (Dual-Pane Workbench)**:
   - Pada desktop, telaah kitab turats sangat ideal jika menggunakan tampilan multi-kolom:
     - Kolom Kiri (atau Sidebar): Daftar marja' / buku / bab kitab yang sedang ditelaah.
     - Kolom Kanan (Workbench Utama): Ruang percakapan asisten turats / catatan bacaan.
   - Apakah tata letak saat ini sudah mendukung atau dapat diperluas tanpa merusak tampilan mobile?
3. **Modal Dialog vs Bottom Sheet**:
   - Di mobile, digunakan `showModalBottomSheet`.
   - Di desktop, bottom sheet yang membentang 100% lebar layar terlihat janggal (*stretched*).
   - Pastikan seluruh sheet dan dialog dibatasi dengan `ConstrainedBox(constraints: BoxConstraints(maxWidth: 560))` dan diposisikan di tengah layar saat dijalankan di desktop.

---

### DIMENSI 7: INTERAKSI MOUSE, KEYBOARD SHORTCUTS & WINDOW MANAGEMENT
1. **Pintasan Keyboard (Keyboard Accelerators)**:
   - Pengguna desktop bekerja dengan keyboard. Apakah sistem mendukung shortcut standar?
     - `Cmd/Ctrl + F`: Langsung memfokuskan pencarian di Dashboard atau Pustaka.
     - `Cmd/Ctrl + W`: Menutup tab telaah aktif di `AgentSessionManager`.
     - `Cmd/Ctrl + T`: Membuka asisten baru.
     - `Cmd/Ctrl + ,`: Membuka Profil / Pengaturan.
     - `Esc`: Menutup dialog, sheet, atau membatalkan pencarian.
     - `Cmd/Ctrl + R`: Memuat ulang sesi WebView.
2. **Kursor & Hover States (Mouse Interaction)**:
   - Apakah tombol, kartu kitab, chip kategori, dan item catatan memiliki `MouseRegion(cursor: SystemMouseCursors.click)` serta efek hover halus (*subtle highlight*)?
   - Apakah physics scroll desktop menggunakan mouse-wheel drag yang natural (`PointerDeviceKind.mouse`)?
3. **Manajemen Jendela (Window Sizing & Minimum Constraints)**:
   - Rancang pengaturan window saat startup:
     - Ukuran default: 1280 × 820 px.
     - Ukuran minimum: 860 × 600 px (mencegah layout hancur akibat window dikecilkan secara ekstrem).

---

### DIMENSI 8: SANDBOXING, ENTITLEMENTS & PACKAGING BUILD NATIVE
1. **Konfigurasi macOS (`macos/Runner`)**:
   - Audit `DebugProfile.entitlements` dan `Release.entitlements`:
     - Apakah `com.apple.security.network.client` sudah aktif (wajib untuk akses internet/Firebase)?
     - Apakah `com.apple.security.network.server` diperlukan atau harus dimatikan demi keamanan sandbox?
     - Periksa konfigurasi bundle identifier: Apakah `$(AppIdentifierPrefix)com.example.openturathAi` di keychain-access-groups sudah diselaraskan dengan bundle ID resmi `com.openturath.ai`?
   - Konfigurasi `macos/Podfile`: Apakah deployment target sudah diatur minimal macOS 10.15 (Catalina) agar kompatibel dengan library modern?
2. **Konfigurasi Windows (`windows/runner`)**:
   - Audit `windows/runner/Runner.rc` dan `windows/CMakeLists.txt`:
     - Apakah nama aplikasi, deskripsi, versi, dan hak cipta sudah tercermin dengan benar?
     - Apakah `manifest.xml` sudah mengaktifkan DPI Awareness (*Per-Monitor V2*) agar font Arab dan naskah tidak buram di monitor 4K/scaling 125%-150%?
     - Apakah icon native `.ico` resolusi tinggi sudah disiapkan?

---

### DIMENSI 9: SISTEM PEMBARUAN & DISTRIBUSI DESKTOP (`UpdateService`)
1. **Audit `UpdateService` (`lib/services/update_service.dart`)**:
   - Saat ini `UpdateService` mengunduh `.apk` dan memanggil installer Android via `open_filex`.
   - Pada macOS dan Windows, mengunduh file `.apk` adalah **bug fatal**.
   - Bagaimana logika `UpdateService` saat mendeteksi `Platform.isMacOS` atau `Platform.isWindows`?
   - Rancang alur pembaruan desktop:
     - Menampilkan dialog versi baru dengan catatan rilis.
     - Tombol "Unduh Pembaruan" mengarahkan pengguna ke link rilis resmi (DMG untuk macOS, Installer/MSI/ZIP untuk Windows) via browser.

---

## 4. FORMAT LAPORAN AKHIR YANG DITUNTUT

Dewan Auditor wajib menyusun laporan dalam format terstruktur berikut:

```markdown
# LAPORAN FORENSIK KESIAPAN EKSPOR DESKTOP: OPENTURATH AI
Tanggal: [Tanggal Audit] • Target: macOS & Windows

## 1. Executive Summary & Skor Kesiapan Desktop (0-100%)
- Ringkasan status kompatibilitas macOS
- Ringkasan status kompatibilitas Windows
- Daftar Blocker Utama sebelum build rilis dapat dilakukan

## 2. Matriks Kompatibilitas Plugin & Dependensi
[Tabel lengkap seluruh paket pubspec.yaml: Nama Paket | Android | iOS | macOS | Windows | Catatan/Aksi]

## 3. Temuan Defek & Kutu (Categorized by Urgency)
- P0 (Blocker: Kompilasi Gagal / Crash Saat Startup)
- P1 (Major: Fitur Tidak Berfungsi / Layar Stretched Parah)
- P2 (Minor: Ergonomi Desktop, Shortcut, Kursor Mouse)

Setiap temuan WAJIB menyertakan:
- Kode Temuan (misal: D-01, D-02)
- Lokasi: Nama File & Nomor Baris
- Gejala & Jalur Kegagalan (Failure Mechanism)
- Dampak pada Pengguna Desktop
- **KODE PERBAIKAN LENGKAP SIAP PAKAI (Full Replacement Code / Patch)**

## 4. Cetak Biru Arsitektur Responsif (Adaptive Desktop Scaffold)
- Implementasi Shell Navigasi Adaptif (Bottom Bar di Mobile, Navigation Rail di Desktop)
- Pembatas Lebar Modal Dialog (Max-Width Centering)
- Integrasi Shortcut Keyboard Global

## 5. Panduan Kompilasi & Build Rilis Langkah Demi Langkah
- Instruksi build macOS: `flutter build macos --release` (DMG packaging, entitlements)
- Instruksi build Windows: `flutter build windows --release` (MSIX/Inno Setup, WebView2 bundling)
```

---

## 5. INSTRUKSI EKSEKUSI

Mulailah dengan memeriksa repositori secara menyeluruh, periksa seluruh file di `lib/`, `macos/`, `windows/`, dan `pubspec.yaml`, lalu hadirkan laporan audit desktop paling presisi, mendalam, dan solutif tanpa ada kompromi!
