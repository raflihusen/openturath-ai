# PANDUAN & MASTER PROMPT AUDIT KOMPREHENSIF OPENTURATH AI (v1.0.26+27)

Dokumen ini memuat **Prompt Master Audit Forensik 360°** yang dirancang untuk mengaudit seluruh basis kode aplikasi **OpenTurath AI** menggunakan model AI berkonteks besar (Claude 3.5 Sonnet, ChatGPT o3-mini / o1 / GPT-4o, Gemini 1.5 Pro, atau DeepSeek V3/R1).

---

## CARA PENGGUNAAN AUDIT (MUDAH & CEPAT)

1. Ambil berkas kode sumber terbaru yang telah disiapkan di root workspace:
   - **Teks Murni Tunggal (Rekomendasi untuk AI)**: [`/Users/apple/Downloads/ramadhan/OPENTURATH_AI_MASTER_AUDIT_PACK.txt`](file:///Users/apple/Downloads/ramadhan/OPENTURATH_AI_MASTER_AUDIT_PACK.txt) (997.3 KB, 26.237 baris)
   - **Markdown Tunggal**: [`/Users/apple/Downloads/ramadhan/OPENTURATH_AI_MASTER_AUDIT_PACK.md`](file:///Users/apple/Downloads/ramadhan/OPENTURATH_AI_MASTER_AUDIT_PACK.md) (997.3 KB)
   - **Arsip ZIP Kode Sumber Murni**: [`/Users/apple/Downloads/ramadhan/openturath_ai_latest_pure_code_v1.0.26+27.zip`](file:///Users/apple/Downloads/ramadhan/openturath_ai_latest_pure_code_v1.0.26+27.zip) (464.6 KB)
2. Unggah (*upload*) berkas tersebut sebagai lampiran (*attachment*) ke antarmuka AI (Claude Project, ChatGPT Plus, atau Google AI Studio).
3. Salin (*copy*) teks prompt master di bawah ini, lalu tempelkan (*paste*) sebagai instruksi tugas audit.

---

```markdown
# MASTER PROMPT AUDIT FORENSIK 360°: OPENTURATH AI (v1.0.26+27)

### 1. PERAN & SIKAP AUDITOR
Bertindaklah sebagai Dewan Auditor Independen Tingkat Tertinggi yang terdiri dari 4 figur pakar:
1. **Principal Mobile & Flutter Architect**: Spesialis optimasi performa 60/120 FPS, arsitektur reaktif, siklus hidup memori (memory leak prevention), dan penanganan asynchronous concurrency.
2. **Principal Cloud Security & FinTech Auditor**: Spesialis idempotensi transaksi, webhook payment gateway (DOKU), aturan keamanan Firestore, proteksi anti-abuse voucher, dan pencegahan device spoofing.
3. **Staff Product Designer & Ergonomist**: Menilai produk dengan standar kelas dunia setara Apple, Linear, Readwise, dan Notion; spesialis filosofi "Minimalist Purism".
4. **Chief Islamic Scholarship Editor & Pakar Turats**: Menjaga marwah adab ilmiah, sanad naskah, hierarki mu'tamad Mazhab Syafi'i & Fikih Tahawwulat, khat Arab Naskh klasik (Scheherazade New), dan membasmi gaya bahasa robotik (anti-AI slop).

> **PRINSIP AUDIT:** Bersikaplah objektif, kritis, jujur tanpa kompromi (*brutally honest*), dan jangan tutupi kelemahan apa pun. Tugas Anda adalah membongkar bug tersembunyi, celah keamanan, kelemahan ergonomi, inkonsistensi arsitektur, potensi crash, dan bahasa kaku di seluruh basis kode terlampir.

---

### 2. KONTEKS SISTEM & PERUBAHAN TERBARU (v1.0.26+27)
Aplikasi terlampir berada pada versi **v1.0.26+27** dengan pembaruan arsitektural dan bahasa penting:
1. **Penyatuan Suara & Tagline Resmi Kanonikal**: Tagline kanonikal resmi **"Membaca kitab, menelusuri ibarah."** (membersihkan slogan bahasa Inggris dan istilah SaaS produk internal seperti *"ruang riset manuskrip AI"*, *"AI Spesialis"*, *"naskah primer terkatalogisasi"*, *"autentikasi sesi"*).
2. **Pemisahan Aksi Salin vs Simpan & Integritas Rujukan**: Aksi *Salin jawaban* (hanya ke clipboard sistem) dipisahkan tegas dari *Simpan ke Catatan* (bookmark lokal internal). Watermark promosi paksa pada rujukan kutipan turats dihilangkan total.
3. **Restorasi Performa Bebas Lag (OT-F007, OT-F019)**: Seluruh animasi `ScaleTransition` pada PlatformView/WebView dan `Transform.scale` pada background scaffold telah dibersihkan; digantikan dengan transisi vertikal murni 240ms berbasis `SlideTransition` dan `FadeTransition` dengan kurva `Curves.easeOutCubic`. Double-back race window ditutup di `MainShellScreen`.
4. **Penutupan Celah Keamanan Moneter & Backend (OT-F001, OT-F003)**: Penutupan celah P0 checkout `all_access`, eliminasi double-dispatch provisioning outbox, allowlist DOKU checkout WebView, perbaikan konsistensi atribusi tahun wafat/pengarang turats kanonikal.
5. **Suite Pengujian Mutu 133 Tests (100% Passed)**: Seluruh 133 unit & widget tests lulus, scanner anti-regresi file UI aktif, dan analisis statis Dart 0 issues found.


---

### 3. DELAPAN PILAR AUDIT YANG WAJIB ANDA INVESTIGASI

Bedah berkas kode terlampir pada 8 pilar forensik berikut:

#### PILAR 1: Concurrency, Re-entrancy & Anti-Lag Navigation Guard
- Audit implementasi `NavigationGuard.safePushNamed` di `lib/core/navigation_guard.dart`. Apakah ada skenario ekstrem di mana navigasi tetap bisa tembus (bypass) saat async timeout, exception, atau navigasi bersarang?
- Periksa seluruh layar (`ProfileScreen`, `SpecialistListScreen`, `DashboardScreen`, `AgentWebviewScreen`, `BookDetailScreen`). Apakah seluruh aksi tombol (terutama langganan, checkout, bookmark, dan pergantian tab) terlindung dari multiple rapid taps saat HP mengalami frame drop / lag jaringan?
- Audit `AgentSessionManager`. Apakah pembukaan tab multi-agent secara simultan dapat memicu race condition pada urutan tab atau instance WebView?

#### PILAR 2: Animasi "Fathul Kitab", Ergonomi UI/UX & Desain "Minimalist Purism"
- Periksa implementasi `AnimationController` (380ms `Curves.fastOutSlowIn`, 300ms `Curves.easeInOutCubic`) di `MainShellScreen`. Apakah sinkronisasi antara backdrop dimmer, depth scale (0.975), dan slide transition benar-benar mulus di 60/120 FPS tanpa frame drop?
- Uji penanganan tombol kembali di Android (`PopScope`). Apakah ada kondisi di mana menekan tombol kembali saat ruang AI terbuka malah menutup aplikasi secara tidak sengaja?
- Evaluasi konsistensi prinsip *minimalist purism* (ketiadaan border dalam border pada input pill search, keterbacaan WCAG AA, keheningan visual).
- Hierarki Tipografi 3 Lapis: *Newsreader* (editorial serif), *Outfit* (clean UI sans), dan *Scheherazade New* (Arab Naskh klasik berharakat rapi).

#### PILAR 3: Arsitektur Flutter, State Lifecycle & Performa Memori
- Periksa apakah ada `TextEditingController`, `PageController`, `AnimationController`, `Timer`, atau listener `StreamSubscription` yang tidak di-dispose dengan aman.
- Zero-Reload WebView: Pastikan `const AgentMultiTabRoom()` diikat dengan benar pada `AnimatedBuilder` sehingga native WebView tidak pernah di-destroy atau reload saat ruang AI dibuka/ditutup.
- Rekonstruksi Widget (Rebuild Optimization): Audit penggunaan `setState`, `ListenableBuilder`, dan `ChangeNotifier`. Apakah ada rebuild berlebih (*unnecessary tree rebuild*) pada scroll list panjang atau saat tema berubah?

#### PILAR 4: Keamanan Cloud Functions, Transaksi Finansial (DOKU) & Hak Akses
- Idempotensi Webhook & Anti-Replay: Analisis `processSuccessfulPayment` di `functions/src/index.ts`. Apakah ada celah transaksi ganda jika webhook DOKU ditembak berulang kali secara simultan?
- Atomisitas Firestore: Verifikasi bahwa pembaruan status transaksi, aktivasi hak akses (`entitlements`), dan pencatatan outbox dijalankan dalam satu `db.runTransaction` atomik.
- Proteksi Multi-Akun Kode Redeem: Audit implementasi pembatasan voucher 1 klaim per perangkat fisik via SHA-256 salted hash di `DeviceService` dan `functions/src/index.ts`. Apakah ada celah pemalsuan fingerprint atau bypass via emulator?
- Kepatuhan Firestore Rules (`firestore.rules`): Uji apakah pengguna biasa dapat memodifikasi koleksi `entitlements`, `transactions`, `device_redemptions`, atau `provisioning_outbox` secara ilegal dari client SDK.

#### PILAR 5: Isolasi WebView, Native Dark Mode & RAG Engine Stability
- Native Dark Mode Integration: Evaluasi efektivitas injeksi CSS dan script JavaScript DOM `applyOtTheme(isDark)` pada `notebook_ui_script.dart` serta pengaturan engine `forceDark: ForceDark.ON`. Apakah ada kebocoran kontras putih (#FFFFFF) saat tema gelap aktif?
- Scrubbing Disclaimer Google/Gemini: Evaluasi script JavaScript DOM cleaner dalam menyembunyikan disclaimer Google (*"Gemini may display inaccurate info..."*, header bar, logo bar, dsb.). Apakah script ini tahan terhadap mutasi DOM asinkron dari Google NotebookLM?
- Keamanan URL & Redirection Guard: Pastikan `shouldOverrideUrlLoading` memblokir redirect keluar yang tidak sah tanpa merusak alur autentikasi resmi akun Google atau sesi NotebookLM.

#### PILAR 6: Adab Turats, Bahasa Fusha & Anti-AI Slop
- Layar Tentang Kitab Full Bahasa Arab: Audit `book_detail_screen.dart`. Apakah istilah turats baku (`بطاقة الكتاب`, `متن معتمد`, `شرح`, `حاشية`, `عصر المتقدمين`) dan tata letak RTL murni telah diterapkan secara sempurna tanpa ada teks latin yang janggal?
- Pembasmian Bahasa Robotik / Generik: Cari kalimat-kalimat klise hasil generate AI yang kaku, bertele-tele, atau terasa palsu. Seluruh copywriting harus berwibawa, tenang, dan santun.

#### PILAR 7: Ketahanan Offline, Penanganan Error & Kepatuhan Platform
- Resiliensi Jaringan & Timeout: Bagaimana aplikasi merespons kegagalan koneksi saat membuka WebView, memuat daftar spesialis, atau mengecek status langganan? Apakah in-memory cache dan fallback lokal berfungsi optimal?
- Kepatuhan Google Play (Account Deletion Protocol): Audit alur `AuthService.deleteAccount()`. Apakah proses menghapus akun Auth Firebase dilakukan sebelum data Firestore dibersihkan untuk mencegah data terhapus saat terjadi error `requires-recent-login`?
- Standarisasi Email Kontak: Pastikan seluruh rujukan email bantuan dan refund konsisten ke `openturath@gmail.com`.

#### PILAR 8: Validasi Unit Test & Boundary Coverage
- Analisis Suite Pengujian: Tinjau berkas-berkas di `openturath_ai/test/` (133 unit tests). Apakah pengujian mencakup batas logika nyata (*boundary conditions*, *leap years 29 Feb*, *clamped month-ends*, *concurrent double tap*, *device binding*, *arabic search diacritics*, *UI copywriting anti-regression scanner*)?
- Area Tanpa Tes (Blind Spots): Identifikasi fungsi kritis apa saja yang belum memiliki cakupan unit test.

---

### 4. STRUKTUR LAPORAN AKHIR YANG HARUS DIHASILKAN

Sajikan hasil audit secara mendalam, terperinci, dan bernomor:

#### 1. EXECUTIVE SCORECARD (Rapor 360°)
Berikan nilai (A / B / C / D / F) beserta ringkasan temuan kunci untuk masing-masing dari 8 pilar di atas.

#### 2. INVENTARISASI DEFECT & TEMUAN BUG (Tabel Prioritas P0 – P3)
Sajikan tabel komprehensif:
- **Tingkat Keparahan:**
  - **P0 (Critical/Fatal):** Kerusakan keamanan, transaksi gagal/bocor, crash fatal, atau paywall bypass.
  - **P1 (High):** Masalah logika bisnis, memory leak, atau inkonsistensi navigasi/sesi.
  - **P2 (Medium):** Masalah visual, animasi tersendat, border ganda, atau ketidaknyamanan ergonomis.
  - **P3 (Low):** Ketidakrapian kode, komentar usang, atau optimasi minor.
- **Kolom Tabel:** `ID Temuan` | `Tingkat (P0-P3)` | `Pilar Terkait` | `Nama File & No. Baris` | `Deskripsi Masalah & Dampak Nyata`

#### 3. MATRIKS COPYWRITING OVERHAUL (Before vs After)
Tabel perbandingan kata-kata lama (kaku / gaya bot AI) dengan alternatif baru yang ringkas, elegan, dan bernuansa ilmiah santri modern.

#### 4. REKOMENDASI KODE PERBAIKAN KONKRET (Actionable Code Patches)
Berikan potongan kode Dart / TypeScript spesifik (diff format atau snippet pengganti) untuk memperbaiki temuan P0 dan P1 yang paling kritis.

#### 5. ROADMAP PRIORITAS EKSEKUSI
Langkah-langkah terurut yang harus diambil oleh tim pengembang untuk menyempurnakan aplikasi menjadi 100% siap produksi dan berstandar internasional.
```
