# Laporan Audit Forensik & Pemetaan Blind Spot Komprehensif
## OpenTurath AI — Arsitektur, UI/UX, Copywriting, Stabilitas, Kebersihan Kode & Keamanan

* **Tanggal Audit**: 6 Oktober 2026
* **Target Codebase**: `openturath_ai` (Flutter Multiplatform: macOS Desktop, Android, iOS)
* **Karakter & Etos Desain**: *The Quiet Islamic Scholar* (Monochrome Archival Paper, High-Density Scholarly UI)
* **Versi Aplikasi**: `1.0.63+64` | Dart SDK: `>=3.0.0 <4.0.0`
* **Cakupan Pemeriksaan**: 125 berkas kode Dart (36.937 baris kode), 58 berkas unit test (6.714 baris kode), 22 berkas gambar, 36 berkas animasi Lottie, 35 berkas data katalog JSON, konfigurasi platform Android (`AndroidManifest.xml`), konfigurasi platform macOS (`MainFlutterWindow.swift`), dan aturan keamanan backend (`firestore.rules`).

---

## 1. Ringkasan Eksekutif & Skor Kesehatan Codebase (Radar Risiko)

Secara visi produk dan arsitektur dasar, OpenTurath AI adalah sistem yang sangat ambisius dan kaya fitur. Aplikasi ini menggabungkan khazanah keilmuan Islam klasik (21 asisten spesialis turats lintas mazhab) dengan arsitektur webview headless Google NotebookLM yang disuntikkan skrip kustom (DOM injection), integrasi gerbang pembayaran DOKU, pembaruan aplikasi mandiri di latar belakang (*silent auto-update*), serta sistem catatan penelitian lokal berbasis enkripsi dan karantina data (*quarantine corruption*).

Namun, audit forensik menyeluruh menemukan bahwa lapisan implementasi teknis menyimpan **sejumlah blind spot kritis dan kerapuhan struktural**. Celah-celah ini menyebabkan pemborosan sumber daya baterai/CPU di latar belakang, mematahkan pengalaman pengguna (UX) pada gestur navigasi dasar perangkat keras, merusak tata letak visual pada layar desktop macOS monitor besar, membuang ukuran unduhan aplikasi (*bundle bloat*) hingga belasan megabyte, dan meninggalkan puluhan teks statis yang tidak terlokalisasi.

### Radar Risiko & Metrik Kesehatan Codebase

| Aspek / Domain | Skor | Tingkat Risiko | Temuan Utama |
| :--- | :---: | :---: | :--- |
| **Arsitektur & State** | **78 / 100** | 🟡 Sedang | Retensi memori multi-tab tidak terkontrol (`Visibility(maintainState: true)`), tidak ada sinkronisasi siklus hidup webview. |
| **UI & Desain Visual** | **68 / 100** | 🚨 Kritis | Jendela macOS terkunci mati pada 920pt (`MainFlutterWindow.swift`), mematikan `NavigationRail` lebar; fragmentasi 3 lapisan token desain. |
| **UX & Alur Navigasi** | **62 / 100** | 🚨 Kritis | Tombol Back fisik Android menutup ruang kajian tanpa memeriksa riwayat webview; penggusuran tab tertua secara diam-diam tanpa konfirmasi. |
| **Copywriting & Bahasa** | **74 / 100** | ⚠️ Perhatian | 12+ teks antarmuka di ruang asisten berbahasa Indonesia statis; pelanggaran etos tenang melalui tanda seru pada pertanyaan contoh. |
| **Bug & Runtime Safety** | **65 / 100** | 🚨 Kritis | Timer kesiapan 500ms bocor di background saat ruang asisten ditutup; alur hapus akun patah jika terkena `requires-recent-login`. |
| **Kebersihan Kode & Bloat**| **58 / 100** | 🚨 Kritis | 6 file zombie/dead code (~136 KB), 36 animasi Lottie tidak terpakai (~700 KB), 21 gambar mati (~1.5 MB), duplikat katalog (~3.7 MB). |
| **Keamanan & Kepatuhan** | **82 / 100** | 🟢 Terjaga | Aturan Firestore ketat, sanitasi telemetri baik, namun deep link pembayaran dari luar belum memiliki handler parser di Dart. |

---

## 2. Arsitektur Sistem & Aliran Data (Architecture & Data Flow)

### 2.1. Topologi Komponen & Pola Dependensi
Arsitektur OpenTurath AI berpusat pada hierarki berikut:
1. **Entry Point & Lifecycle**:
   [`main.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/main.dart) menginisialisasi `AppConfig`, Firebase Core, dan `TelemetryService`. Jika inisialisasi Firebase gagal, aplikasi menampilkan fallback `AppErrorState`.
2. **Presentation Shell**:
   [`MainShellScreen`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/main_shell_screen.dart) bertindak sebagai root scaffolding yang membungkus:
   - `Scaffold` utama (Dashboard, Katalog, Bookmark, Profil).
   - `Stack` overlay yang menampung [`AgentMultiTabRoom`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/agent_multi_tab_room.dart) di atasnya dengan widget `Visibility(maintainState: true)`.
3. **Session Management**:
   [`AgentSessionManager`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/services/agent_session_manager.dart) adalah singleton `ChangeNotifier` yang mengelola maksimal 3 tab kajian aktif (`AgentSessionTab`). Setiap tab menyimpan referensi ke `InAppWebViewController` masing-masing.
4. **Data Persistence**:
   - `SharedPreferences`: Menyimpan flag sesi Google (`google_session_ready`, `google_session_email`), ukuran font zoom (`turath_font_zoom_level`), dan tema aplikasi.
   - [`ScopedJsonListStore`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/services/scoped_json_store.dart): Menyimpan bookmark dan catatan riset dengan hashing SHA-256 untuk karantina file korup jika terjadi kegagalan penulisan I/O.
   - Cloud Firestore: Menyimpan profil pengguna, status langganan, entitlement akses, dan telemetri error klien.

### 2.2. Diagram Aliran Data & Siklus Hidup Sesi
```
[Pengguna] 
    │
    ▼
[LoginScreen] ──(Google Sign-In)──► [Firebase Auth] ──► [Firestore /users]
    │                                                          │
    ▼                                                          ▼
[GoogleSessionAuthScreen] (Gating Sesi Webview) ◄──────────────┘
    │  - Polling kuki SID/HSID/SSID via DesktopWebViewRuntime
    ▼
[MainShellScreen]
    ├── [DashboardScreen] (Katalog Kitab, Pencarian Arab, Bookmark)
    │
    └── [AgentMultiTabRoom] (IndexedStack: Maks 3 Tab InAppWebView)
            │
            ├── Suntik `_turatsMasterScript` (CSS Isolasi & Pembersihan Header)
            ├── Suntik `notebookUiScript` (Intersepsi Salin Jawaban & Status Generate)
            └── Polling Kesiapan DOM via `_readinessTimer` (Setiap 500ms)
```

---

## 3. Audit UI & Kecacatan Desain Visual (Design Flaws & Inconsistencies)

### 3.1. Kuncian Jendela macOS 920pt — Kematian Permanen Layout Desktop & Sidebar
* **Lokasi Berkas**: 
  - [`macos/Runner/MainFlutterWindow.swift:L5-L46`](file:///Users/apple/Downloads/ramadhan/openturath_ai/macos/Runner/MainFlutterWindow.swift#L5-L46)
  - [`lib/screens/main_shell_screen.dart:L143`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/main_shell_screen.dart#L143)
  - [`lib/screens/dashboard_screen.dart:L220`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/dashboard_screen.dart#L220)
* **Analisis Kode Aktual**:
  Di `MainFlutterWindow.swift`:
  ```swift
  private let fixedWidth: CGFloat = 920

  override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
      ...
      constrained.size.width = fixedWidth
      return constrained
  }

  override func awakeFromNib() {
      ...
      self.styleMask.remove(.resizable)
      self.styleMask.remove(.fullScreen)
      self.minSize = NSSize(width: fixedWidth, height: fixedHeight)
      self.maxSize = NSSize(width: fixedWidth, height: fixedHeight)
      self.standardWindowButton(.zoomButton)?.isEnabled = false
      self.standardWindowButton(.zoomButton)?.isHidden = true
  }
  ```
  Di `main_shell_screen.dart`:
  ```dart
  final expandedSidebar = MediaQuery.sizeOf(context).width >= 1100;
  ```
  Di `dashboard_screen.dart`:
  ```dart
  constraints: const BoxConstraints(maxWidth: 1040),
  ```
* **Kecacatan Desain yang Terjadi**:
  1. Jendela macOS dipaksa memiliki lebar tetap 920 pixel tanpa kemampuan resize, tanpa tombol maximize/zoom, dan tanpa mode Full Screen.
  2. Karena lebar tidak pernah bisa mencapai 1100 pixel, kondisi `expandedSidebar` **SECARA MATEMATIS TIDAK AKAN PERNAH AKTIF DI MACOS**. Pengguna Mac dengan layar 24" hingga 32" terpaksa melihat sidebar sempit berbentuk ikon kerdil tanpa label teks.
  3. Desain kontainer dashboard yang telah dioptimalkan untuk lebar 1040 pixel terpotong paksa menjadi ~848 pixel (920px dikurangi margin dan sidebar).
* **Solusi Perbaikan**:
  Hapus pembatasan `fixedWidth` dan kembalikan mask `.resizable` serta `.fullScreen` di `MainFlutterWindow.swift`. Atur batas minimum `NSSize(width: 880, height: 620)` dan biarkan pengguna desktop menikmati tampilan luas.

---

### 3.2. Fragmentasi Tiga Lapisan Desain Token (Tri-Token Chaos)
* **Lokasi Berkas**:
  - [`lib/core/design/ot_colors.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/core/design/ot_colors.dart)
  - [`lib/core/design/native_design.dart:L8-L55`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/core/design/native_design.dart#L8-L55)
  - [`lib/core/theme.dart:L20-L58`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/core/theme.dart#L20-L58)
  - [`lib/core/design/ot_typography.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/core/design/ot_typography.dart) vs [`lib/core/scholarly_fonts.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/core/scholarly_fonts.dart) vs [`lib/core/design/native_fonts.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/core/design/native_fonts.dart)
* **Analisis Kode**:
  Terdapat 3 sistem token warna dan 3 sistem tipografi yang berjalan berdampingan dan saling membungkus:
  - `NativeColors` di `native_design.dart` mendefinisikan ulang 40 konstanta warna yang hanya meneruskan nilai dari `OTColors` (`static const canvasLight = OTColors.canvasLight;`).
  - `AppTheme` di `theme.dart` mendefinisikan konstanta warna ketiga (`canvasLight`, `surfaceCardLight`, dsb.).
  - Tipografi: Ditemukan **297 pemanggilan** `ScholarlyFonts`, **28 pemanggilan** `NativeFonts`, dan **161 pemanggilan** `OTTypography` di seluruh widget.
* **Dampak**:
  Pengembang baru atau pemelihara kode mengalami disorientasi ketika membuat komponen baru. Inkonsistensi kerap terjadi saat mengubah satu warna tema namun lupa memperbarui alias di lapisan pembungkus lainnya.
* **Solusi**:
  Jadikan `OTColors` dan `OTTypography` sebagai satu-satunya *Single Source of Truth*. Depresiasi dan hapus kelas alias `NativeColors` dan alihkan seluruh panggilan `ScholarlyFonts` langsung ke `OTTypography`.

---

### 3.3. Timbunan Token Warisan Usang di `theme.dart` (Deprecated Style Bloat)
* **Lokasi Berkas**: [`lib/core/theme.dart:L59-L110`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/core/theme.dart#L59-L110)
* **Temuan**:
  Terdapat puluhan konstanta era lama yang sudah tidak memiliki relevansi dengan etos *The Quiet Scholar*:
  ```dart
  static const Color lmLightCanvas = canvasLight;
  static const Color lmLightSurface = surfaceCardLight;
  static const Color brandRed = Color(0xFF171717);
  static const Color brandGreen = OTColors.textSecondaryLight;
  static const Color brandBlue = accentLight;
  static const Color bgBase = canvasDark;
  static const Color bgDeep = Color(0xFF111111);
  static const Color surfaceL1 = surfaceCardDark;
  static const Color surfaceL2 = surfaceHeaderDark;
  static const Color surfaceL3 = borderDark;
  static const Color gold = accentLight;
  static const Color goldBright = accentDark;
  static const Color goldMuted = citationBgDark;
  ```
* **Dampak**:
  Penamaan seperti `brandRed`, `brandBlue`, dan `gold` membingungkan karena nilainya di-remap secara paksa ke warna monokrom (`Color(0xFF171717)` dan `accentLight`). Ini adalah artefak sisa rebranding masa lalu yang harus dibersihkan total.

---

### 3.4. Pelanggaran Kontras Mode Gelap (Dark Mode Inconsistencies)
* **Lokasi Berkas**: [`lib/widgets/doku_checkout_sheet.dart:L489-L496`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/doku_checkout_sheet.dart#L489-L496)
* **Analisis Kode**:
  Pada header modal checkout pembayaran DOKU:
  ```dart
  decoration: BoxDecoration(
    color: OTColors.borderStrongLight.withAlpha(30),
    borderRadius: BorderRadius.circular(AppTheme.radiusXS),
  ),
  child: const Icon(
    Icons.lock_rounded,
    size: 18,
    color: OTColors.borderStrongLight,
  ),
  ```
* **Kecacatan Desain**:
  Ikon gembok keamanan menggunakan token warna tetap `OTColors.borderStrongLight` tanpa memeriksa apakah tema sedang dalam mode gelap (`isDark`). Pada mode gelap, warna border terang ini menghasilkan kontras yang redup dan kusam, menyimpang dari pedoman palet *Neutral Ink*.
* **Solusi**:
  Ganti dengan helper adaptif: `color: OTColors.borderStrong(isDark)`.

---

## 4. Audit UX & Alur Interaksi Pengguna (User Experience Traps & Blind Spots)

### 4.1. Tombol Back Fisik Android Membunuh Ruang Kajian (Back Button Interception Flaw)
* **Lokasi Berkas**: 
  - [`lib/screens/main_shell_screen.dart:L268-L287`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/main_shell_screen.dart#L268-L287)
  - [`lib/widgets/agent_multi_tab_room.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/agent_multi_tab_room.dart)
* **Analisis Kode**:
  Di `main_shell_screen.dart`:
  ```dart
  onPopInvokedWithResult: (didPop, result) async {
    if (didPop) return;
    if (sessionManager.isOpen) {
      sessionManager.closeRoom();
      return;
    }
    ...
  }
  ```
* **Skenario Masalah Nyata**:
  1. Pengguna membuka asisten fikih di Android.
  2. Di dalam WebView, pengguna mengklik tautan dokumen referensi, beralih ke halaman consent Google, atau membuka halaman login sekunder.
  3. Ketika pengguna ingin kembali ke percakapan sebelumnya dan menekan tombol **Back** fisik/gesture Android, sistem **TIDAK MEMERIKSA** apakah WebView memiliki riwayat (`controller.canGoBack()`).
  4. Hasilnya: Ruang asisten langsung ditutup paksa ke Dashboard. Ketika ruang asisten dibuka kembali, pengguna masih berada di halaman eksternal tersebut alih-alih kembali ke halaman obrolan.
* **Solusi**:
  ```dart
  final activeWebCtrl = sessionManager.activeTab?.webController;
  if (activeWebCtrl != null && await activeWebCtrl.canGoBack()) {
    await activeWebCtrl.goBack();
    return;
  }
  if (sessionManager.isOpen) {
    sessionManager.closeRoom();
    return;
  }
  ```

---

### 4.2. Penggusuran Tab Kajian Diam-Diam Tanpa Konfirmasi (Silent Tab Eviction)
* **Lokasi Berkas**: [`lib/services/agent_session_manager.dart:L98-L105`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/services/agent_session_manager.dart#L98-L105)
* **Analisis Kode**:
  ```dart
  if (_tabs.length >= maxTabs) {
    // Tab limit reached: close oldest non-active tab to preserve WebView memory
    final evictIndex = _activeIndex == 0 ? 1 : 0;
    closeTab(evictIndex);
  }
  _tabs.add(AgentSessionTab(agent: agent));
  ```
* **Kecacatan UX**:
  Ketika pengguna sedang membuka 3 asisten kajian, lalu dari Dashboard pengguna memilih asisten ke-4, sistem langsung **menggusur tab tertua tanpa pemberitahuan apapun**.
  Fungsi `closeTab` langsung mengeksekusi `tabToClose.disposeWebResources()`, mematikan WebView, membersihkan cache DOM, dan menghapus draf pertanyaan yang sedang diketik di tab tersebut.
* **Solusi**:
  Sebelum mengeksekusi `openAgent`, periksa jika `_tabs.length >= maxTabs`. Tampilkan bottom sheet konfirmasi: *"Batas 3 Sesi Kajian Telah Tercapai. Pilih sesi mana yang ingin Anda tutup untuk membuka [Nama Asisten Baru]."*

---

### 4.3. Penjebakan Gating Sesi Google pada `GoogleSessionAuthScreen`
* **Lokasi Berkas**: [`lib/screens/google_session_auth_screen.dart:L180-L240`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/google_session_auth_screen.dart#L180-L240)
* **Analisis Kode**:
  Ketika pengguna berada di layar Langkah 2 (Sinkronisasi Akun Google untuk NotebookLM) dan menekan tombol Batal / Keluar:
  ```dart
  if (shouldSignOut == true && mounted) {
    await AuthService().signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
  }
  ```
* **Kecacatan UX**:
  Jika pengguna mengalami kendala koneksi ke server Google atau belum ingin menyambungkan akun NotebookLM, aplikasi **memaksa logout total dari Firebase**.
  Pengguna sama sekali tidak diizinkan masuk ke Dashboard untuk sekadar membaca Katalog Kitab Offline, melihat Bibliografi Kitab, ataupun membaca Catatan Riset yang sudah tersimpan secara lokal.
* **Solusi**:
  Beri opsi: *"Lanjutkan ke Perpustakaan Tanpa Asisten AI"*, arahkan ke `AppRoutes.dashboard`, dan hanya minta autentikasi Google saat pengguna benar-benar mengetuk salah satu asisten di ruang kajian.

---

### 4.4. Amnesia Logout yang Agresif (Over-Aggressive Cookie Purge)
* **Lokasi Berkas**: 
  - [`lib/services/auth_service.dart:L333-L337`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/services/auth_service.dart#L333-L337)
  - [`lib/services/desktop_webview_runtime.dart:L46-L57`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/services/desktop_webview_runtime.dart#L46-L57)
* **Analisis Kode**:
  ```dart
  await cookies.deleteAllCookies();
  await InAppWebViewController.clearAllCache();
  await WebStorageManager.instance().deleteAllData();
  ```
* **Kecacatan UX**:
  Saat pengguna melakukan `signOut()` dari akun OpenTurath, sistem menghapus seluruh kuki WebView Google (`deleteAllCookies()`). Jika pengguna login kembali 5 menit kemudian menggunakan akun Google yang sama, mereka dipaksa mengetik ulang alamat email, sandi, melakukan verifikasi 2FA, dan persetujuan perangkat dari awal. Ini menimbulkan rasa frustrasi (*auth fatigue*) yang berat bagi pengguna.
* **Solusi**:
  Hanya hapus preferensi sesi aplikasi OpenTurath (`google_session_ready = false`). Jangan menghapus kuki container Google kecuali jika pengguna secara sadar memilih tombol *"Keluar dari Seluruh Akun Google"* di pengaturan aplikasi.

---

### 4.5. Lubang Hitam Deep Link Pembayaran (Payment Return Deep Link Black Hole)
* **Lokasi Berkas**: [`android/app/src/main/AndroidManifest.xml:L24-L35`](file:///Users/apple/Downloads/ramadhan/openturath_ai/android/app/src/main/AndroidManifest.xml#L24-L35)
* **Analisis Kode**:
  Di `AndroidManifest.xml` terdaftar:
  ```xml
  <intent-filter android:autoVerify="true">
      <action android:name="android.intent.action.VIEW"/>
      <category android:name="android.intent.category.DEFAULT"/>
      <category android:name="android.intent.category.BROWSABLE"/>
      <data android:scheme="https" android:host="openturath.id" android:pathPrefix="/payment"/>
      <data android:scheme="https" android:host="openturath.ai" android:pathPrefix="/payment"/>
  </intent-filter>
  ```
* **Temuan Forensik**:
  Di seluruh folder `lib/`, **TIDAK ADA SATUPUN KODE ATAU PAKET** (seperti `app_links` atau `uni_links`) yang mendengarkan event tautan masuk (`getInitialUri` atau `uriLinkStream`).
* **Dampak Kegagalan Nyata**:
  Ketika pengguna menyelesaikan pembayaran DOKU / QRIS / Transfer Bank di browser eksternal atau aplikasi m-Banking, sistem pembayaran mengarahkan kembali ke `https://openturath.ai/payment?invoice=...`.
  Aplikasi OpenTurath AI memang terbuka, namun Flutter hanya memulai alur normal dari `SplashScreen` -> `DashboardScreen`, **benar-benar mengabaikan parameter URL pembayaran**. Status langganan pengguna tidak langsung terverifikasi seketika di layar.
* **Solusi**:
  Tambahkan pustaka `app_links` ke `pubspec.yaml`, buat handler pada `main.dart` untuk menangkap rute `/payment`, dan picu `SubscriptionService.verifyPayment(invoiceNumber)` secara otomatis.

---

## 5. Audit Copywriting, Lokalisasi & Etos Keilmuan (Tone & Language)

### 5.1. Pelanggaran Etos "The Quiet Islamic Scholar" pada Pertanyaan Contoh
* **Lokasi Berkas**: [`lib/models/agent_model.dart:L647, L755, L799`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/models/agent_model.dart#L647)
* **Analisis Teks**:
  Ditemukan kalimat imperatif yang menggunakan tanda seru (`!`):
  - Baris 647 (Aqidah): `'Jelaskan pembagian sifat Wajib, Mustahil, dan Jaiz bagi Allah!'`
  - Baris 755 (Qawaid Fiqhiyyah): `'Jelaskan 5 kaidah kubra dalam fikih Islam beserta contoh penerapannya!'`
  - Baris 799 (Tajwid & Qiraat): `'Jelaskan makharijul huruf dan shifat lazimah menurut Matan Al-Jazariyyah!'`
* **Penyimpangan Etos**:
  Prinsip dasar OpenTurath AI adalah santun, hening, dan bersahaja seperti seorang penuntut ilmu (*thalibul ilmi*). Nada kalimat imperatif dengan tanda seru memberi kesan soal ujian yang keras dan kaku.
* **Rekomendasi Revisi**:
  - *"Bagaimana uraian sifat Wajib, Mustahil, dan Jaiz bagi Allah menurut akidah Ahlussunnah?"*
  - *"Uraian lima kaidah kubra dalam fikih mazhab Syafi'i beserta contoh penerapannya."*
  - *"Bagaimana perincian makharijul huruf dan shifat lazimah menurut Matan Al-Jazariyyah?"*

---

### 5.2. 12+ Teks Hardcoded Bahasa Indonesia pada Dialog Obrolan Asisten
* **Lokasi Berkas**: [`lib/widgets/agent_multi_tab_room.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/agent_multi_tab_room.dart)
* **Daftar String Statis Tanpa `Loc.tr`**:
  1. Baris 73: `'Akun Google untuk Asisten'`
  2. Baris 88: `'Pastikan email ini sesuai dengan akun Google yang memiliki akses ke modul / notebook turats Anda...'`
  3. Baris 105: `'nama@gmail.com'` (Hint text statis)
  4. Baris 128: `'Batal'`
  5. Baris 140: `'Pakai Akun Utama'`
  6. Baris 150: `'Simpan'`
  7. Baris 267: `'Sesuaikan ukuran huruf percakapan agar nyaman dibaca.'`
  8. Baris 371: `'Hapus Riwayat Obrolan?'`
  9. Baris 380: `'Seluruh percakapan pada sesi asisten ini akan dibersihkan dari layar.'`
  10. Baris 409: `'Riwayat obrolan telah dibersihkan.'`
  11. Baris 452: `'Sesi Asisten Terbuka'`
  12. Baris 458: `'Pilih asisten untuk berpindah sesi kajian aktif.'`
  13. Baris 1715: `label: 'Simpan'` pada SnackBar salin jawaban.
* **Dampak**:
  Ketika pengguna berganti ke bahasa Arab (`العربية`) atau bahasa Inggris (`English`), seluruh dialog pengaturan akun, pengubahan ukuran huruf, dan pembersihan riwayat obrolan di atas tetap tampil dalam bahasa Indonesia.

---

### 5.3. Teks Hardcoded pada Pembaruan Aplikasi (Update Dialog & Banner)
* **Lokasi Berkas**:
  - [`lib/widgets/update_ready_dialog.dart:L79, L98, L166, L177`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/update_ready_dialog.dart#L79)
  - [`lib/widgets/update_ready_banner.dart:L71, L82, L101, L114`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/update_ready_banner.dart#L71)
* **Daftar String Statis**:
  - `'Pembaruan Tersedia'` / `'Pembaruan Telah Siap'`
  - `'Versi $version'`
  - `'Penyempurnaan stabilitas telaah dan sistem keilmuan.'`
  - `'Unduh Pembaruan'` / `'Pasang & Muat Ulang Sekarang'`
  - `'Pembaruan belum dapat dibuka. Silakan coba kembali.'`
  - `'Ketuk untuk membuka tautan pembaruan versi desktop terbaru.'`
* **Solusi**:
  Daftarkan seluruh kunci string ini ke `copy_catalog.dart` dalam 3 bahasa (ID, EN, AR) dan akses via `Loc.tr(...)`.

---

### 5.4. Kerapuhan Mekanisme Reverse Lookup `Loc.text`
* **Lokasi Berkas**: [`lib/core/localization.dart:L27-L30, L75-L78`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/core/localization.dart#L27-L30)
* **Analisis Kode**:
  ```dart
  static final Map<String, String> _sourceKeys = {
    for (final entry in copyCatalog.entries)
      for (final value in entry.value) value: entry.key,
  };

  static String text(String source) {
    final key = _sourceKeys[source];
    return key == null ? source : tr(key);
  }
  ```
* **Kelemahan Sistem**:
  Fungsi ini memetakan nilai teks terjemahan kembali ke kuncinya. Jika terdapat dua kunci berbeda yang memiliki terjemahan bahasa Indonesia yang identik (misalnya `'Batal'`, `'Simpan'`, atau `'Tutup'`), pemetaan `_sourceKeys` akan saling menimpa (*collision*). Selain itu, jika teks diubah sedikit saja di UI, fungsi ini gagal menemukan kuncinya dan secara diam-diam mengembalikan teks sumber tanpa menerjemahkannya.
* **Solusi**:
  Hilangkan ketergantungan pada `Loc.text(source)` dan wajibkan pemanggilan menggunakan kunci terdaftar: `Loc.tr('keyName')`.

---

## 6. Audit Bug Teknis, Memory Leak & Kerentanan Runtime

### 6.1. Kebocoran Timer Latar Belakang & Pemborosan CPU (`_readinessTimer` Leak)
* **Lokasi Berkas**: 
  - [`lib/widgets/agent_multi_tab_room.dart:L1187-L1268`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/agent_multi_tab_room.dart#L1187-L1268)
  - [`lib/screens/main_shell_screen.dart:L295-L302`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/main_shell_screen.dart#L295-L302)
* **Analisis Bug Terverifikasi**:
  1. Di `_SingleAgentTabWebViewState`:
     ```dart
     _readinessTimer = Timer.periodic(const Duration(milliseconds: 500), (_) => _checkReady());
     ```
  2. Di `main_shell_screen.dart`, ruang asisten multi-tab dibungkus dengan:
     ```dart
     Visibility(
       visible: sessionManager.isOpen,
       maintainState: true,
       child: child!,
     )
     ```
  3. Ketika pengguna menutup ruang asisten (`sessionManager.closeRoom()`), widget `_SingleAgentTabWebView` **TIDAK DI-DISPOSE** karena `maintainState: true`.
  4. Akibatnya, `_readinessTimer` **TERUS BERJALAN SETIAP 500 MILIDETIK DI BACKGROUND**, terus-menerus mengevaluasi JavaScript ke WebView, membuang baterai dan siklus CPU Mac/Android saat pengguna sedang berada di Dashboard!
  5. Lebih parah lagi: Pada detik ke-45 (`elapsedSec >= 45`), logika timer menandai tab sebagai timeout error:
     ```dart
     widget.session.isTimeoutError = true;
     widget.session.errorMessage = 'Koneksi ke asisten turats membutuhkan waktu lebih lama...';
     ```
     Sehingga saat pengguna membuka kembali ruang asisten beberapa saat kemudian, asisten sudah berada dalam status rusak/error padahal sebenarnya pengguna hanya sempat menutupnya sementara!
* **Solusi Perbaikan**:
  Dengarkan perubahan `_sessionManager.isOpen` dan status `widget.isActive`. Jika room sedang ditutup atau tab sedang tidak aktif di layar, segera hentikan / jeda `_readinessTimer`.

---

### 6.2. Kegagalan Senyap pada Penghapusan Akun (`requires-recent-login` Swallowed)
* **Lokasi Berkas**:
  - [`lib/services/auth_service.dart:L359-L370`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/services/auth_service.dart#L359-L370)
  - [`lib/screens/profile_screen.dart:L158-L174`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/profile_screen.dart#L158-L174)
  - [`firestore.rules:L39`](file:///Users/apple/Downloads/ramadhan/openturath_ai/firestore.rules#L39)
* **Analisis Bug**:
  Firebase Auth mewajibkan otentikasi baru sebelum mengeksekusi operasi sensitif `user.delete()`. Jika pengguna sudah login lebih dari beberapa jam yang lalu, `user.delete()` akan melempar exception:
  `[firebase_auth/requires-recent-login] This operation is sensitive and requires recent authentication.`
  Di `profile_screen.dart`:
  ```dart
  } catch (e) {
    if (mounted) {
      setState(() => _isDeletingAccount = false);
      final errText = e.toString().contains('requires-recent-login')
          ? AppCopy.recentLoginRequired
          : AppCopy.networkError;
      AppSnackBar.error(context, errText);
    }
  }
  ```
* **Dampak**:
  Aplikasi hanya memunculkan SnackBar bertuliskan *"Login ulang diperlukan"*. Tidak ada dialog verifikasi sandi/Google credential ulang. Pengguna menekan tombol hapus akun berulang kali namun selalu gagal. Ditambah lagi, aturan Firestore `match /users/{userId} { allow delete: if false; }` mencegah klien menghapus dokumennya sendiri. Ini berpotensi melanggar kebijakan *Google Play Account Deletion Requirement*.
* **Solusi**:
  Sediakan alur reautentikasi otomatis: jika error `requires-recent-login` tertangkap, picu dialog `GoogleSignIn.signIn()` untuk mendapatkan kredensial baru, lakukan `user.reauthenticateWithCredential()`, lalu ulangi pemanggilan `user.delete()`.

---

### 6.3. Kerapuhan Selektor Status Selesai Menjawab di Google DOM
* **Lokasi Berkas**: [`lib/core/notebook_ui_script.dart:L773`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/core/notebook_ui_script.dart#L773)
* **Analisis Kode**:
  Deteksi apakah model sedang menghasilkan jawaban mengandalkan atribut teks tombol Stop:
  ```javascript
  const stopBtn = document.querySelector('button[aria-label*="Stop" i], button[aria-label*="Hentikan" i], [data-action*="stop" i]');
  ```
* **Kerapuhan**:
  Jika akun Google pengguna menggunakan antarmuka bahasa Arab (`إيقاف`), bahasa Urdu, bahasa Turki, atau bahasa lainnya, selektor teks ini gagal mendeteksi tombol berhenti. Akibatnya, `otAnswerState` tidak terpicu dengan tepat dan status loading di UI Flutter bisa menggantung.
* **Solusi**:
  Gunakan penanda berbasis tag ikon SVG / Material Icon (misalnya `mat-icon`, class `.stop-generating`, atau deteksi perubahan mutasi streaming pada elemen `.chat-message-pair`).

---

### 6.4. Regresi Unit Test: Pesan Galat `notebook-session-required` Desinkron
* **Lokasi Berkas**: 
  - [`test/notebook_chat_controller_login_target_test.dart:L33`](file:///Users/apple/Downloads/ramadhan/openturath_ai/test/notebook_chat_controller_login_target_test.dart#L33)
  - [`lib/services/notebook_chat_controller.dart:L87-L89`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/services/notebook_chat_controller.dart#L87-L89)
* **Analisis Kegagalan Nyata**:
  Hasil pengujian unit test (`flutter test`) mendeteksi 1 kegagalan dari 342 pengujian:
  ```
  Expected: contains 'NotebookLM'
    Actual: 'Buka ruang asisten di profil Chrome tempat penghubung dipasang, lalu masuk dengan akun Google yang sama dengan OpenTurath.'
     Which: does not contain 'NotebookLM'
  ```
  Kata `'NotebookLM'` telah dihapus dari string error di `notebook_chat_controller.dart` demi dekopling merek, namun test assertion tidak disinkronkan. Ini membuktikan pentingnya pengujian regresi otomatis sebelum proses rilis.
* **Solusi**:
  Perbarui ekspektasi assertion pada `test/notebook_chat_controller_login_target_test.dart` agar sesuai dengan copy terbaru.

---

## 7. Audit Kebersihan Kode, Dead Code & Asset Bloat

### 7.1. Daftar 6 Berkas Dart Zombie (Dead Code) Sebesar ~136.2 KB
Berdasarkan analisis graf ketergantungan menyeluruh, ditemukan 6 berkas kode Dart yang sama sekali tidak pernah diimpor ataupun dipanggil oleh berkas manapun di seluruh aplikasi:

| No | Berkas | Ukuran | Baris | Status & Keterangan |
| :---: | :--- | :---: | :---: | :--- |
| 1 | [`lib/screens/agent_webview_screen.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/agent_webview_screen.dart) | **65 KB** | 1.542 | **Dead Code**. Layar asisten single-tab lama. Seluruh navigasi rute `/agent` sudah dialihkan ke `MainShellScreen`. |
| 2 | [`lib/core/goakal_catalog_registry.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/core/goakal_catalog_registry.dart) | **33 KB** | 788 | **Dead Code**. Registri katalog versi awal, digantikan oleh `OpenTurathCatalogRepository`. |
| 3 | [`lib/widgets/evidence_bottom_sheet.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/evidence_bottom_sheet.dart) | **16 KB** | 412 | **Dead Code**. Modal penampil marja' lama. Hanya tersisa di 1 unit test statis. |
| 4 | [`lib/screens/library_screen.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/library_screen.dart) | **12 KB** | 337 | **Dead Code**. Layar perpustakaan usang sebelum dibuatnya `BookCatalogScreen` & `LibraryBottomSheet`. |
| 5 | [`lib/widgets/tahawwulat_feature.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/tahawwulat_feature.dart) | **6.5 KB** | 203 | **Dead Code**. Widget fitur Tahawwulat awal, digantikan oleh `TahawwulatFlagshipCard`. |
| 6 | [`lib/widgets/desktop_reference_panel.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/desktop_reference_panel.dart) | **3.7 KB** | 137 | **Dead Code**. Panel referensi desktop yang tidak pernah dipasang di layout manapun. |

**Total Dead Code**: **~136.2 KB** kode Dart usang (3.419 baris) yang membebani kompilasi dan pemeliharaan arsitektur.

---

### 7.2. 36 Berkas Animasi Lottie Mati (~700 KB) & Dependensi Sia-Sia
* **Lokasi Berkas**: Folder [`assets/animations/`](file:///Users/apple/Downloads/ramadhan/openturath_ai/assets/animations) & [`pubspec.yaml:L35`](file:///Users/apple/Downloads/ramadhan/openturath_ai/pubspec.yaml#L35)
* **Temuan Forensik**:
  - Ditemukan **36 file animasi Lottie** berukuran total **700 KB** di dalam folder `assets/animations/`.
  - Pemeriksaan `grep` terhadap seluruh file di `lib/` membuktikan bahwa: **TIDAK ADA SATUPUN BERKAS ANIMASI LOTTIE YANG DIGUNAKAN DALAM KODE DART**. Kata kunci `Lottie` memiliki **0 kemunculan** di `lib/`!
  - Namun di `pubspec.yaml`, dependensi `lottie: ^3.1.0` tetap dipasang dan seluruh 36 berkas tersebut di-include di bawah deklarasi `assets: - assets/animations/`.
* **Dampak**:
  Aplikasi menanggung beban dependensi pihak ketiga yang tidak terpakai serta membuang 700 KB ukuran binary APK Android dan installer macOS DMG.
* **Solusi**:
  Hapus pustaka `lottie` dari `pubspec.yaml`, bersihkan deklarasi folder `assets/animations/`, dan hapus ke-36 berkas JSON animasi tersebut.

---

### 7.3. 21 Aset Gambar Mati (~1.5 MB) di `assets/images/`
* **Lokasi Berkas**: Folder [`assets/images/`](file:///Users/apple/Downloads/ramadhan/openturath_ai/assets/images)
* **Temuan Forensik**:
  Dari total **22 berkas gambar** (SVG dan PNG) berukuran **1.5 MB**, **HANYA 1 GAMBAR YANG DIGUNAKAN** yaitu `OpenTurath_logo_transparent.svg`.
  Sebanyak **21 gambar lainnya sama sekali tidak pernah direferensikan dalam kode Dart**:
  - `arch_dark_transparent.png`
  - `arch_light_transparent.png`
  - `openturath_arch_only.png`
  - `openturath_hero_arch.jpg`
  - 10 badge langganan lama (`plus_badge_*`, `pro_badge_*`, `ultra_badge_*`, `gemnova_badge_*`)
  - 7 logo warisan Google (`notebooklm_logo_*`, `gemini_notebook_*`)
* **Solusi**:
  Hapus 21 berkas gambar mati tersebut untuk menghemat 1.5 MB ukuran installer.

---

### 7.4. Duplikasi Dataset Katalog Kitab JSON (~3.7 MB Uncompressed)
* **Lokasi Berkas**: Folder [`assets/data/`](file:///Users/apple/Downloads/ramadhan/openturath_ai/assets/data)
* **Temuan Forensik**:
  Repositori katalog resmi [`OpenTurathCatalogRepository`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/services/open_turath_catalog_repository.dart) memuat berkas dengan format penomoran: `01_KATALOG_FIKIH_SYAFII.json`, `02_KATALOG_HADITS_DAN_SYARAH.json`, dst.
  Namun di folder yang sama, terdapat **13 berkas JSON salinan/duplikat lama** yang berukuran **~3.7 MB** yang memiliki **0 kemunculan** di kode aplikasi:
  - `20_KATALOG_TAKHIJ_ATHRAF_DAN_ILAL.json` (248 KB)
  - `canonical_hadits.json` (497 KB)
  - `canonical_syafii.json` (77 KB)
  - `canonical_tafsir.json` (78 KB)
  - `canonical_tahawwulat.json` (34 KB)
  - `canonical_ushul_fikih.json` (214 KB)
  - `katalog_bahasa_arab.json` (552 KB)
  - `katalog_fikih_syafii.json` (78 KB)
  - `katalog_hadits.json` (1.5 MB)
  - `katalog_tafsir.json` (162 KB)
  - `katalog_tahawwulat.json` (42 KB)
  - `katalog_ushul_fikih.json` (193 KB)
  - `metadata_modul_lengkap.json` (6.5 KB)
* **Solusi**:
  Hapus 13 berkas JSON duplikat tersebut. Penghematan ukuran aset murni adalah **~3.7 MB**.

---

### 7.5. God Classes / Berkas Monolitik Raksasa
Beberapa berkas memiliki kompleksitas yang terlalu tinggi dan menggabungkan terlalu banyak tanggung jawab (*Single Responsibility Principle Violation*):
1. [`lib/widgets/agent_multi_tab_room.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/agent_multi_tab_room.dart): **2.060 baris** (83.8 KB). Menggabungkan tab switcher bar, dialog akun Google, dialog hapus obrolan, slider zoom font, gesture controller, WebView lifecycle, timer kesiapan, dan penanganan error paywall ke dalam satu berkas raksasa.
2. [`lib/screens/dashboard_screen.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/dashboard_screen.dart): **1.464 baris** (60.6 KB). Menggabungkan kalender Hijriah ganda, pencarian lokal Arab, grid 21 asisten, banner auto-update, kartu resume terakhir, dan modal pratinjau kitab.
3. [`lib/screens/profile_screen.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/profile_screen.dart): **1.328 baris** (51.1 KB).
4. [`lib/widgets/doku_checkout_sheet.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/doku_checkout_sheet.dart): **931 baris** (36.5 KB).

---

## 8. Audit Keamanan & Kepatuhan Privasi (Security & Privacy)

### 8.1. Analisis Aturan Keamanan Firestore (`firestore.rules`)
* **Status**: **Sangat Baik & Terlindungi**.
* **Temuan Positif**:
  - `match /users/{userId}`: Perangkat hanya diizinkan membuat dokumen berstatus `plan == 'trial'`, `questions_used == 0`, dan melarang injeksi hak akses (`entitlements == {}`). Modifikasi kuota dan masa berlaku hanya dapat dilakukan oleh Admin SDK server melalui Cloud Functions.
  - `client_error_logs`: Dibatasi secara ketat dengan skema validasi tipe data dan ukuran string (maksimal error 2500 karakter, stackTrace 6000 karakter, `createdAt == request.time`). Operasi `read`, `update`, dan `delete` dimatikan total untuk umum.
* **Catatan Perbaikan**:
  - Di `match /users/{userId}`, aturan `allow delete: if false;` mengharuskan penghapusan dokumen pengguna ditangani oleh server trigger Auth `onDelete`. Pastikan Cloud Functions server trigger untuk penghapusan user berjalan stabil agar tidak ada dokumen yatim (*orphaned documents*).

### 8.2. Sanitasi Telemetri & Perlindungan Data Pengguna
* **Status**: **Sangat Baik**.
* **Temuan**:
  [`TelemetryService.sanitizeData`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/services/telemetry_service.dart#L106-L126) secara aktif melakukan regex scrubbing terhadap token sensitif, voucher redeem code (`[REDACTED_CODE]`), serta melakukan penyamaran email pengguna (`maskEmail`).

---

## 9. Matriks Remediasi Presisi & Rencana Tindak Lanjut Terstruktur

### 🔴 Prioritas 0 (P0 — Kritis: Showstopper, Memory Leak & Bug Fatal)

| No | Target Komponen & Berkas | Lokasi Kode | Tindakan Remediasi Konkrit |
| :---: | :--- | :--- | :--- |
| **01** | **macOS Fixed Window Lock** | [`macos/Runner/MainFlutterWindow.swift:L5-L46`](file:///Users/apple/Downloads/ramadhan/openturath_ai/macos/Runner/MainFlutterWindow.swift#L5-L46) | Hapus kuncian `fixedWidth = 920`, kembalikan mask `.resizable` dan `.fullScreen`. Izinkan pengguna Mac melebarkan jendela agar `expandedSidebar` di `main_shell_screen.dart:L143` aktif. |
| **02** | **Android Back Button Interception** | [`lib/screens/main_shell_screen.dart:L268-L287`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/main_shell_screen.dart#L268-L287) | Periksa `webCtrl.canGoBack()` sebelum menutup ruang asisten. Jika webview memiliki riwayat, lakukan `webCtrl.goBack()`. |
| **03** | **Readiness Timer Leak di Background** | [`lib/widgets/agent_multi_tab_room.dart:L1187-L1268`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/agent_multi_tab_room.dart#L1187-L1268) | Tambahkan listener terhadap `_sessionManager.isOpen`. Jika room disembunyikan/ditutup, batalkan `_readinessTimer` agar tidak membuang CPU dan tidak memicu timeout 45 detik palsu. |
| **04** | **Reauth Flow pada Hapus Akun** | [`lib/services/auth_service.dart:L366`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/services/auth_service.dart#L366) & [`lib/screens/profile_screen.dart:L160`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/profile_screen.dart#L160) | Tangani exception `requires-recent-login` dengan meminta reautentikasi Google interaktif sebelum mengulang `user.delete()`. |

---

### 🟡 Prioritas 1 (P1 — Tinggi: Penghematan Asset Bloat & Pembersihan Dead Code)

| No | Target Komponen & Berkas | Lokasi Kode | Tindakan Remediasi Konkrit |
| :---: | :--- | :--- | :--- |
| **05** | **Pembersihan 6 Berkas Dart Dead Code** | 6 Berkas di `lib/screens/`, `lib/core/`, `lib/widgets/` | Hapus permanen: `agent_webview_screen.dart` (65KB), `library_screen.dart` (12KB), `goakal_catalog_registry.dart` (33KB), `evidence_bottom_sheet.dart` (16KB), `tahawwulat_feature.dart` (6.5KB), `desktop_reference_panel.dart` (3.7KB). **Hemat ~136 KB kode Dart**. |
| **06** | **Eliminasi 36 Animasi Lottie Mati** | `assets/animations/*.json` & `pubspec.yaml` | Hapus seluruh 36 berkas JSON di `assets/animations/`, hapus deklarasi folder di `pubspec.yaml`, dan copot paket `lottie: ^3.1.0`. **Hemat ~700 KB**. |
| **07** | **Pembersihan 21 Gambar Mati** | `assets/images/*` | Hapus 21 gambar tidak terpakai, sisakan hanya `OpenTurath_logo_transparent.svg`. **Hemat ~1.5 MB**. |
| **08** | **Pembersihan 13 Duplikat JSON Data** | `assets/data/canonical_*` & `assets/data/katalog_*` | Hapus 13 berkas duplikat JSON yang memiliki 0 referensi di kode. **Hemat ~3.7 MB**. |
| **09** | **Penyambungan Handler Deep Link** | `lib/main.dart` & `pubspec.yaml` | Pasang pustaka `app_links` untuk menangkap return URL `/payment` dari gateway pembayaran DOKU yang telah didaftarkan di `AndroidManifest.xml`. |

---

### 🟢 Prioritas 2 (P2 — Sedang: Konsistensi UI/UX, Lokalisasi & Copywriting)

| No | Target Komponen & Berkas | Lokasi Kode | Tindakan Remediasi Konkrit |
| :---: | :--- | :--- | :--- |
| **10** | **Lokalisasi 12+ Teks Modal Obrolan** | [`lib/widgets/agent_multi_tab_room.dart:L73-L458`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/agent_multi_tab_room.dart#L73) | Pindahkan teks hardcoded dialog akun Google, dialog hapus obrolan, slider font, dan label snackbar ke `copy_catalog.dart` via `Loc.tr(...)`. |
| **11** | **Dialog Konfirmasi Batas 3 Tab** | [`lib/services/agent_session_manager.dart:L98-L105`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/services/agent_session_manager.dart#L98-L105) | Tampilkan sheet konfirmasi saat tab ke-4 dibuka alih-alih menggusur tab tertua secara diam-diam. |
| **12** | **Penyelarasan Nada Etos Keilmuan** | [`lib/models/agent_model.dart:L647, L755, L799`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/models/agent_model.dart#L647) | Hapus tanda seru pada pertanyaan contoh asisten Aqidah, Qawaid Fiqhiyyah, dan Tajwid agar mencerminkan adab thalibul ilmi yang hening. |
| **13** | **Akses Fleksibel Tanpa Paksaan Logout** | [`lib/screens/google_session_auth_screen.dart:L232`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/google_session_auth_screen.dart#L232) | Berikan opsi masuk ke Dashboard mode baca offline jika pengguna membatalkan sinkronisasi Google di Langkah 2. |
| **14** | **Perbaikan Kontras Dark Mode Checkout** | [`lib/widgets/doku_checkout_sheet.dart:L489`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/doku_checkout_sheet.dart#L489) | Ganti `OTColors.borderStrongLight` dengan `OTColors.borderStrong(isDark)`. |

---

### 🔵 Prioritas 3 (P3 — Rendah: Refaktorisasi Arsitektur Jangka Panjang)

| No | Target Komponen & Berkas | Lokasi Kode | Tindakan Remediasi Konkrit |
| :---: | :--- | :--- | :--- |
| **15** | **Pembersihan Ghost Tokens di `theme.dart`** | [`lib/core/theme.dart:L59-L110`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/core/theme.dart#L59-L110) | Hapus alias lama `brandRed`, `brandBlue`, `gold`, `lmLightCanvas`, `surfaceL1`, dsb. |
| **16** | **Konsolidasi Tipografi & Token Desain** | `native_design.dart` vs `ot_colors.dart` | Satukan `NativeColors` ke `OTColors`, dan arahkan seluruh panggilan tipografi ke `OTTypography`. |
| **17** | **Pemisahan God Classes Monolitik** | `agent_multi_tab_room.dart` (2.060 baris) | Pecah menjadi sub-widget independen: `AgentTabTabBar`, `AgentGoogleAccountDialog`, `AgentFontSizeSheet`, dan `AgentWebViewContainer`. |

---

## 10. Kesimpulan Audit

OpenTurath AI telah memiliki fondasi teknologi yang sangat kuat dan berani dalam mengintegrasikan AI turats modern ke dalam platform Flutter. Namun, keberhasilan sebuah produk riset akademik premium bergantung pada **ketelitian terhadap detail mikro (zero-glitch polish)**.

Dengan mengeksekusi rencana remediasi di atas secara bertahap:
1. **Performa runtime** akan meningkat drastis dengan eliminasi timer leak dan penurunan beban CPU.
2. **Ukuran unduhan aplikasi** akan berkurang **~6 MB** secara instan melalui pembersihan aset mati dan duplikasi JSON.
3. **Pengalaman pengguna di desktop macOS dan ponsel Android** akan menjadi jauh lebih responsif, stabil, dan selaras dengan etos keilmuan *The Quiet Islamic Scholar*.

---
*Laporan disusun secara forensik, independen, dan objektif berdasarkan telaah menyeluruh atas setiap baris kode sumber OpenTurath AI.*
