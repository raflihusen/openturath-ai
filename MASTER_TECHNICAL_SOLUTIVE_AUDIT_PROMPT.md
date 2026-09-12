# MASTER PROMPT AUDIT FORENSIK TEKNIKAL & SOLUTIF TINGKAT TINGGI
### Target Proyek: OpenTurath AI (v1.0.21+22) — Zero-Bug Production Readiness
### Berkas Sumber Terlampir: `OPENTURATH_AI_MASTER_AUDIT_PACK.txt` / `openturath_ai_pure_code_ai_prompt.zip`

---

## 1. INSTRUKSI & PERAN AUDITOR (STRICT SENIOR PRINCIPAL ARCHITECT)

Bertindaklah sebagai **Principal Software Engineer, Cloud Security Architect, & Staff Mobile Ergonomist** dengan standar teknis tertinggi setara Google, Apple, Stripe, dan Linear. Anda memiliki tanggung jawab mutlak (*sole accountability*) untuk memastikan aplikasi ini **100% bebas dari segala jenis bug fungsional, kebocoran memori, celah keamanan, race condition, dan cacat ergonomis** sebelum didistribusikan ke ribuan pengguna.

> **SIKAP & METODE KERJA:**
> - **Zero Tolerance for Hand-Waving**: Dilarang memberikan saran generik seperti *"sebaiknya tambahkan error handling"* atau *"pertimbangkan optimasi state"*. 
> - **Sangat Teknikal & Solutif**: Setiap temuan **WAJIB** mencantumkan nomor baris dan nama file yang presisi, analisis akar masalah mekanistis (*root cause analysis*), alur kegagalan spesifik (*reproduction failure path*), serta **KODE PERBAIKAN LENGKAP (Production-Ready Code Patch)** yang siap di-copas tanpa placeholder `// TODO`.
> - **Unit Test Mandatori**: Untuk setiap perbaikan cacat P0 dan P1, wajib sertakan unit test Dart/TypeScript pendamping untuk menjamin tidak terjadi regresi di masa depan.

---

## 2. KONTEKS SISTEM & ARSITEKTUR APLIKASI

- **Identitas Produk**: OpenTurath (v1.0.21+22) — Meja Telaah Naskah Turats Islam (*Scholarly Digital Library Desk*) berbasis RAG Google NotebookLM.
- **Teknologi**:
  - **Client**: Flutter 3 (Dart 3 null-safety murni), Flutter Riverpod, `flutter_inappwebview` (Hybrid Composition), Google Fonts (`Newsreader`, `Outfit`, `Amiri`).
  - **Backend**: Firebase Cloud Functions (Node.js 20, TypeScript, Firestore Native Transactions).
  - **Keamanan Database**: `firestore.rules` (Strict role-based access & server collection isolation).
  - **Payment Gateway**: DOKU Direct API & Webhook (HMAC-SHA256 asymmetric-ready payload signature verification).
  - **Katalog Rujukan**: 87 Kitab Mu'tamad Mazhab Syafi'i (`canonical_syafii.json`).

---

## 3. DELAPAN VEKTOR AUDIT MENDALAM (DEEP TECHNICAL INSPECTION VECTORS)

Bedah seluruh basis kode baris demi baris pada 8 vektor berikut:

### VEKTOR 1: Asinkronitas, Event Loop, Mutex & Race Condition
1. **Async Gap & Context Safety**:
   - Periksa setiap penggunaan `BuildContext` setelah pemanggilan `await`. Apakah ada risiko `use_build_context_synchronously` yang tidak terlindungi oleh `if (!mounted) return;` atau `mounted` check yang diletakkan di tempat keliru?
2. **Stream Lifecycle & Multi-Listener Leak**:
   - Audit `userStream` di `auth_service.dart`. Apakah broadcast controller menutup subscription lama saat user berganti UID atau logout? Apakah ada potensi event loop macet jika Firestore melempar timeout?
3. **Mutex & Semaphore Deadlock**:
   - Analisis `_synchronized` di `bookmark_service.dart`. Apakah ada skenario di mana antrean mutex terkunci permanen (*deadlock*) jika operasi I/O file melempar `FileSystemException` yang tidak tertangkap?
4. **Idempotensi Transaksi Firestore**:
   - Periksa `processSuccessfulPayment` dan `redeemCode` di `functions/src/index.ts`. Apakah pembaruan saldo/entitlement rentan terhadap *concurrent duplicate trigger* jika webhook ditembak secara paralel dalam selang waktu < 100ms?

### VEKTOR 2: Siklus Hidup Memori, Controller Disposal & Tree Rebuilds
1. **Controller Lifecycle & Cleanup**:
   - Periksa seluruh subclass `StatefulWidget`. Apakah semua `TextEditingController`, `ScrollController`, `PageController`, `AnimationController`, dan `FocusNode` selalu di-dispose di dalam `dispose()`?
   - Apakah dialog lokal yang membuat controller ad-hoc (seperti input WhatsApp atau dialog modal) membungkus disposal dalam blok `try ... finally`?
2. **Closure Capture & Retain Cycles**:
   - Apakah ada callback listener (`addListener`, JavaScript handlers, DOM observers) yang menangkap referensi `State` secara implisit sehingga mencegah Garbage Collection bekerja?
3. **Rebuild Boundary Optimization**:
   - Audit widget build tree. Apakah ada pemanggilan `setState` di level parent yang memicu re-render widget scrollable berat? Apakah `const` constructor dan selector `ValueListenableBuilder` sudah diterapkan optimal?

### VEKTOR 3: Isolasi WebView, Kontainerisasi RAG & Keamanan JS Bridge
1. **DOM Sanitization & Asynchronous Observer Leak**:
   - Analisis script `_turatsMasterScript` di `agent_webview_screen.dart`. Apakah `MutationObserver` dan interval DOM cleaner membersihkan listener-nya saat halaman berganti atau controller di-dispose?
   - Apakah skrip injeksi CSS disclaimer Google/Gemini tahan banting terhadap perubahan class name dinamis atau Shadow DOM pada NotebookLM?
2. **Compound Font Scaling Stability**:
   - Audit logika `applyTurathFontScale`. Apakah perkalian skala font menggunakan basis absolut atau multiplikatif relatif yang dapat memicu *font size explosion* jika dieksekusi berulang kali?
3. **URL Filtering & Sandboxing Navigation Guard**:
   - Periksa `shouldOverrideUrlLoading`. Apakah regex dan pemfilteran URL mengizinkan ekosistem autentikasi Google (`accounts.google.com`, `accounts.youtube.com`, OAuth) secara mulus namun secara absolut memblokir phishing dan redirect berbahaya pihak ketiga?

### VEKTOR 4: Keamanan FinTech, Webhook Signature & Aturan Firestore
1. **Constant-Time Cryptographic Verification**:
   - Analisis verifikasi signature DOKU di `functions/src/index.ts`. Apakah signature diverifikasi menggunakan `crypto.timingSafeEqual` pada buffer dengan panjang yang divalidasi terlebih dahulu?
2. **Timestamp Skew & Replay Attacks**:
   - Apakah request DOKU dan webhook divalidasi terhadap jendela toleransi timestamp (maksimal ±5-15 menit) untuk menggagalkan *replay attack*?
3. **Firestore Security Rules Matrix (`firestore.rules`)**:
   - Uji setiap path koleksi (`users`, `transactions`, `redeem_codes`, `provisioning_outbox`, `rate_limits`). Pastikan tidak ada celah client SDK untuk memalsukan data hak akses, memanipulasi kuota pertanyaan, atau membaca riwayat transaksi pengguna lain.
4. **Brute-Force & Rate-Limiting Engine**:
   - Evaluasi mekanisme `enforceRateLimit` di Firestore. Apakah penghitungan attempt tahan terhadap *distributed parallel request*?

### VEKTOR 5: Integritas Data, Serialisasi & Offline Resilience
1. **Karantina Data Korup**:
   - Pada `bookmark_service.dart`, jika file simpanan lokal rusak atau terpotong saat daya mati tiba-tiba, apakah aplikasi melakukan karantina file korup secara terisolasi tanpa menghilangkan data atau menyebabkan crash startup?
2. **ISO-8601 & Timestamp Deserialization**:
   - Apakah konversi antara `Timestamp` Firestore, `DateTime` Dart, dan string JSON menangani timezone, format null, dan format legacy secara aman?
3. **Edge Case Kalender Kabisat**:
   - Evaluasi fungsi penambahan masa aktif langganan bulanan (`addCalendarMonthsClamped`). Apakah penambahan 1 bulan dari 31 Januari menghasilkan 28/29 Februari tanpa melompat ke bulan Maret?

### VEKTOR 6: Ergonomi UI/UX, Aksesibilitas (WCAG) & Navigasi
1. **Konsistensi Sistem Desain "Minimalist Purism"**:
   - Evaluasi kepatuhan terhadap token desain `OTColors`, `OTTypography`, `OTRadius`, dan `OTSpacing`. Pastikan tidak ada warna asing (seperti kebocoran warna emas non-kanonik) di luar token resmi.
2. **Kontras Aksesibilitas WCAG AA / AAA**:
   - Periksa kontras rasio warna teks primer, sekunder, dan tombol aksi (termasuk tombol destruktif hapus akun) baik pada Mode Terang maupun Mode Gelap.
3. **Android Back Button Predictive Handling**:
   - Uji alur `onPopInvokedWithResult` di `main_shell_screen.dart` dan `agent_webview_screen.dart`. Pastikan tombol kembali fisik tidak menutup aplikasi secara tidak sengaja ketika pengguna sedang berada di tab sekunder atau di dalam sesi WebView aktif.

### VEKTOR 7: Standar Bahasa "Quiet Scholar" & Anti-AI Slop
1. **Pembersihan Kata Jargon Brosur**:
   - Pindai seluruh basis kode. Pastikan kata-kata brosur/AI marketing yang dilarang (*korpus*, *penelaahan*, *fasilitas*, *komprehensif*, *secara menyeluruh*, *berbasis*, *terintegrasi*, *optimal*, *presisi*, *solusi*) **100% absen** dari antarmuka pengguna biasa.
2. **Larangan Tanda Seru pada Status Positif**:
   - Pastikan seluruh notifikasi sukses (*snackbars*, *toasts*) menggunakan kalimat deklaratif tenang tanpa tanda seru (`!`).
3. **Akurasi Ilmiah & Adab Turats**:
   - Pastikan transliterasi Arab-Latin, istilah fiqih (*mu'tamad*, *ashab al-wujuh*, *muta'akhkhirin*), dan adab penuntut ilmu disajikan secara proporsional, anggun, dan menghormati tradisi talaqqi ulama.

### VEKTOR 8: Cakupan Pengujian Unit, Boundary Tests & Stress Tests
1. **Blind Spots Pengujian**:
   - Analisis 9 file pengujian di folder `test/`. Fungsi atau percabangan (*branches*) kritis apa yang belum terlindungi oleh pengujian unit?
2. **Boundary & Stress Testing**:
   - Apakah terdapat pengujian untuk input string ekstrim (karakter null byte, unicode RTL-LTR bidi injection, text SQL/NoSQL injection string, dan voucher code dengan spasi liar)?

---

## 4. FORMAT OUTPUT LAPORAN WAJIB

Sajikan laporan audit dalam 5 bagian terstruktur berikut:

### BAGIAN I: EXECUTIVE QUALITY SCORECARD
Tabel penilaian mutu menyeluruh (A+ hingga F) untuk masing-masing dari 8 Vektor Audit di atas beserta ringkasan risiko tertinggi.

### BAGIAN II: DAFTAR TEMUAN CACAT MENDALAM (DEEP DEFECT INVENTORY)
Gunakan format tabel komprehensif berikut:
| ID | Severity (P0/P1/P2/P3) | Vektor | File & Baris | Deskripsi Masalah & Mekanisme Kegagalan | Dampak Teknis & Finansial |

> **Kategori Severity:**
> - **P0 (Critical/Blocker)**: Celah keamanan, kebocoran uang/akses gratis tanpa bayar, kehilangan data permanen, unhandled crash saat startup.
> - **P1 (High)**: Memory leak, race condition state, tombol kembali salah navigasi, fungsi utama gagal di kondisi jaringan tertentu.
> - **P2 (Medium)**: Inkonsistensi UI/UX, contrast ratio tidak lulus WCAG, teks meluap (*overflow*), debounce pencarian kurang mulus.
> - **P3 (Low)**: Code cleanliness, komentar usang, micro-optimization.

### BAGIAN III: ANALISIS AKAR MASALAH & KODE PERBAIKAN LENGKAP (CODE PATCHES)
Untuk **SETIAP** temuan kategori P0 dan P1 yang Anda temukan:
```markdown
#### [ID_TEMUAN] — [Judul Cacat Masalah]
- **File Target**: `path/ke/file.dart` (Baris: XX - YY)
- **Akar Masalah Teknis**: (Penjelasan detail mengapa bug ini terjadi di level runtime/compiler/memory)
- **Skenario Reproduksi**: (Langkah demi langkah memicu bug)
- **Kode Sebelum Perbaikan (Current Code)**:
```dart
// Kode bermasalah
```
- **Kode Solutif Definitif (Production-Ready Fix)**:
```dart
// Kode solusi utuh dan siap pakai
```
- **Automated Regression Test Case**:
```dart
// Unit test konkret untuk memvalidasi perbaikan
```
```

### BAGIAN IV: MATRIKS PENYEMPURNAAN COPYWRITING (BEFORE VS AFTER)
Tabel inventarisasi seluruh kata/kalimat yang masih terasa kaku atau beraroma brosur AI dengan padanan kalimat baru yang tenang, ringkas, dan bernuansa perpustakaan digital berwibawa.

### BAGIAN V: ROADMAP PENERAPAN MENUJU ZERO-DEFECT
Daftar langkah kerja berurutan bagi tim pengembang untuk mengaplikasikan seluruh perbaikan secara aman tanpa merusak fungsionalitas yang ada.
