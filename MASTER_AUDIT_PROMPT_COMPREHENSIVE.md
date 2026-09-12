# MASTER PROMPT AUDIT FORENSIK MULTIDIMENSI: OPENTURATH AI (v1.0.21+22)
### Standar: Senior Principal Architect, Cloud Security Auditor, & Staff Mobile Ergonomist
### Target Arsip: `openturath_ai_latest_full_source.zip` / `OPENTURATH_AI_MASTER_AUDIT_PACK.txt`

---

## 1. MANDAT, PERAN & PRINSIP KERJA AUDITOR

Bertindaklah sebagai **Dewan Auditor Independen Tingkat Tertinggi** yang beranggotakan:
1. **Principal Mobile & Flutter Performance Architect**: Spesialis siklus hidup Flutter, 60/120 FPS jank elimination, memory leaks, stream subscription hygiene, dan state reconstruction optimization.
2. **Staff Cloud Security & FinTech Infrastructure Auditor**: Spesialis keamanan database NoSQL (Firestore), webhook idempotency, cryptographic signatures, token lifecycle, dan zero-trust backend architecture.
3. **Staff Product Ergonomist & UI/UX Designer**: Berstandar Apple Design Award, Linear, Readwise, dan Notion; spesialis "Minimalist Purism", kontras aksesibilitas (WCAG AA), dan hierarki tipografi editorial.
4. **Senior Systems Reliability & QA Automation Lead**: Spesialis penanganan edge cases, offline resilience, race condition detection, boundary test coverage, dan defensive programming.
5. **Chief Islamic Scholarship Editor (Pakar Adab & Naskah Turats)**: Penjaga marwah ilmiah santri, sanad talaqqi, ketepatan peristilahan mazhab Syafi'i, dan pembasmi bahasa generik bot (*anti-AI slop*).

> **PRINSIP AUDIT (NON-NEGOTIABLE):**
> - **Zero Tolerance for Hand-Waving**: Dilarang memberikan saran generik (seperti *"tambahkan error handling"* atau *"optimalkan state"*). Setiap temuan **WAJIB** merujuk nama file, nomor baris, analisis mekanisme kegagalan (*root cause failure path*), dan **KODE PERBAIKAN LENGKAP SIAP PAKAI (Production-Ready Patch)**.
> - **Brutally Honest**: Laporkan setiap celah sekecil apapun, dari race condition hingga typo satu spasi atau kontras warna yang kurang 0.1 dari standar WCAG AA.
> - **Solutif & Berkesinambungan**: Sertakan unit test pendamping untuk setiap bug kritis (P0/P1) agar tidak terjadi regresi.

---

## 2. KONTEKS ARSITEKTUR & SISTEM PRODUK

- **Identitas Produk**: OpenTurath AI (v1.0.21+22) — Meja Telaah Digital (*Scholarly Digital Library Desk*) berbasis RAG Google NotebookLM privat yang dikurasi dengan 87 kitab kanonikal rujukan induk Mazhab Syafi'i.
- **Teknologi Utama**:
  - **Client**: Flutter 3 (Dart 3 null-safety murni), Hybrid Composition `flutter_inappwebview`, Provider/StateNotifier, Fonts (*Newsreader*, *Outfit*, *Amiri*).
  - **Backend**: Firebase Cloud Functions (Node.js 20, TypeScript, Firestore Native Transactions).
  - **Provisioning Engine**: Cloud Run Microservice (`openturath-subscription`) via Google NotebookLM internal batch RPC (`JFMDGd`, `QDyure`).
  - **Keamanan & Autentikasi**: Firebase Auth (Google Sign-In), Firestore Security Rules terisolasi.
  - **Payment & Voucher**: DOKU Direct Payment API + Webhook HMAC-SHA256, Sistem Voucher Terkontrol (`redeemCode`).
  - **Notifikasi**: Admin Telegram Bot (`@openturath_bot`).

---

## 3. TUJUH DIMENSI AUDIT YANG WAJIB DIBEDAH BARIS DEMI BARIS

Lakukan audit forensik menyeluruh pada 7 dimensi berikut:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    7 DIMENSI AUDIT FORENSIK 360°                        │
├─────────────────────────────────────────────────────────────────────────┤
│ 1. KEAMANAN & DATABASE   │ 2. KELANCARAN & PERFORMA │ 3. ERGONOMI & UI  │
│ 4. JALUR & ALUR PENGGUNA │ 5. LOGIKA & ENTITLEMENT  │ 6. FITUR & RAG    │
│                          7. ADAB & ANTI-AI SLOP                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

### DIMENSI 1: KEAMANAN, DATABASE & BACKEND (SECURITY & FINTECH)
1. **Firestore Security Rules (`firestore.rules`)**:
   - Apakah ada celah di mana pengguna biasa dapat menulis/mengubah field `entitlements`, `isSubscriptionActive`, `plan`, atau status transaksi dari client SDK?
   - Apakah koleksi `redeem_codes`, `transactions`, `provisioning_outbox`, dan `system_configs` terisolasi 100% dari akses tulis publik?
   - Apakah validasi ukuran field dan kepemilikan dokumen (`request.auth.uid == userId`) konsisten di seluruh subkoleksi (termasuk `bookmarks` dan `redeemed_vouchers`)?
2. **Idempotensi & Keamanan Webhook (`functions/src/index.ts`)**:
   - Audit penanganan webhook DOKU: Apakah tahan terhadap serangan *replay attack*, *duplicate delivery*, dan *concurrent race condition*?
   - Apakah verifikasi signature HMAC-SHA256 kebal terhadap *timing attack* (`crypto.timingSafeEqual`)?
   - Apakah pembaruan transaksi DOKU, pengaktifan entitlement, dan pembuatan antrean outbox berada dalam satu `db.runTransaction` atomik?
3. **Keamanan Sistem Voucher (`redeemCode`)**:
   - Apakah fungsi `redeemCode` tahan terhadap *brute force* tebakan kode voucher? Apakah ada rate-limiting / per-UID throttling?
   - Apakah klaim voucher terlindungi dari race condition jika pengguna menekan tombol tukar berkali-kali secara simultan?
4. **Keamanan Sesi WebView (`agent_webview_screen.dart`)**:
   - Apakah whitelist navigasi (`shouldOverrideUrlLoading`) hanya mengizinkan domain resmi Google (`notebooklm.google.com`, `accounts.google.com`) dan memblokir seluruh skema eksternal berbahaya?
   - Apakah JavaScript handler (`TurathBridge`) memvalidasi origin pesan dan tipe argumen sebelum mengeksekusi aksi client?
   - Apakah ada risiko kebocoran kredensial atau token sesi ke log aplikasi (`console.log`)?

---

### DIMENSI 2: KELANCARAN, SIKLUS HIDUP & PERFORMA (PERFORMANCE & MEMORY)
1. **Pencegahan Memory Leak & Disposal Resource**:
   - Periksa setiap layar Flutter: Apakah semua `TextEditingController`, `ScrollController`, `PageController`, `AnimationController`, `Timer`, dan `StreamSubscription` di-dispose dengan sempurna?
   - Apakah ada listener global atau event stream di `auth_service.dart` dan `bookmark_service.dart` yang terus berjalan di latar belakang saat pengguna logout?
2. **Optimasi Rebuild & Framerate (60/120 FPS)**:
   - Audit `dashboard_screen.dart`, `subscription_screen.dart`, dan `profile_screen.dart`. Apakah ada rebuild berlebih pada widget tree saat terjadi perubahan state kecil?
   - Apakah list dinamis (katalog kitab, riwayat simpanan) menggunakan `ListView.builder` / `SliverList` dengan delegasi key yang stabil?
3. **Async Gap & Context Safety**:
   - Telusuri seluruh pemanggilan `await` di layer UI dan service. Apakah ada penggunaan `BuildContext` setelah jeda asinkron tanpa perlindungan `if (!mounted) return;`?
4. **Konkurensi & Mutex Deadlock**:
   - Analisis antrean mutex `_synchronized` di `bookmark_service.dart`. Apakah ada skenario di mana antrean mutex terkunci permanen (*deadlock*) saat operasi I/O file lokal melempar `FileSystemException`?
5. **Performa InAppWebView**:
   - Apakah injeksi skrip `turatsMasterScript` dan `notebookUiScript` efisien dan tidak membebani JavaScript event loop WebView?
   - Apakah fungsi penskalaan font (`applyTurathFontScale`) mencegah *exponential compound font explosion* pada elemen bersarang?

---

### DIMENSI 3: ERGONOMI, TIPOGRAFI & DESAIN VISUAL (UI/UX PURISM)
1. **Filosofi "Minimalist Purism" (Meja Telaah Tenang)**:
   - Evaluasi layar: Apakah ada elemen visual berlebih, banner promosi agresif, atau ikon kotak warna-warni yang merusak fokus telaah santri?
   - Apakah layout memberikan ruang bernapas yang cukup (*whitespace discipline*) sesuai standar aplikasi kelas dunia?
2. **Sistem Tiga Lapis Tipografi**:
   - *Newsreader (Editorial Serif)*: Apakah proporsional untuk nama kitab, tajuk utama, dan kutipan ilmiyah?
   - *Outfit (Functional Sans)*: Apakah jelas, rapi, dan mudah dipindai pada label tombol, navigasi, dan metadata?
   - *Amiri (Arabic Naskh)*: Apakah memiliki line-height yang cukup (1.6 – 1.8) agar tanda harakat, tanwin, dan tanda waqaf tidak bertumpuk atau terpotong?
3. **Aksesibilitas & Kontras Warna (WCAG AA)**:
   - Uji rasio kontras teks terhadap latar belakang pada tema Terang maupun Gelap: Apakah seluruh teks normal memenuhi rasio minimal 4.5:1 dan teks tebal/besar minimal 3:1?
   - Apakah ada elemen abu-abu redup (*low-contrast disabled text*) yang sulit dibaca di bawah pencahayaan redup?
4. **Pembersihan "Border dalam Border"**:
   - Periksa bilah pencarian stadium pill dan kartu-kartu kajian: Apakah ada tumpukan border ganda saat state fokus aktif?

---

### DIMENSI 4: JALUR APLIKASI, NAVIGASI & RESILIENSI (USER JOURNEY & RESILIENCE)
1. **Alur Onboarding & Google Sign-In**:
   - Bagaimana perilaku aplikasi saat login pertama kali, pergantian akun, atau ketika koneksi terputus di tengah proses sign-in?
   - Apakah alur `onUserCreate` di Cloud Functions menghubungkan transaksi lama secara presisi tanpa menimpa data baru?
2. **Alur Pembayaran & Aktivasi Hak Akses**:
   - Telusuri perjalanan pengguna dari memilih paket -> DOKU checkout -> instruksi bayar -> verifikasi webhook -> pembaruan UI lokal secara reaktif. Apakah pengguna harus restart aplikasi atau UI langsung terbuka otomatis?
3. **Alur Klaim Voucher (`PERDANA`)**:
   - Apakah lembar input voucher (`redeem_code_sheet.dart`) menangani loading state dengan jelas, mencegah multi-tap, dan memberikan pesan kesalahan yang santun dan akurat jika kuota habis atau kode salah?
4. **Ketahanan Jaringan & Mode Offline**:
   - Bagaimana respon aplikasi jika pengguna membuka kitab dalam kondisi offline? Apakah in-memory cache katalog kanonikal (`canonical_library_service.dart`) menampilkan fallback data lokal tanpa layar putih (*blank screen*)?
5. **Penanganan Back Button & Navigasi**:
   - Apakah penekanan tombol back Android (`PopScope`) di ruang kajian WebView mengarahkan ke riwayat halaman web terlebih dahulu sebelum menutup layar kajian?

---

### DIMENSI 5: LOGIKA BISNIS, TANGGAL & ENTITLEMENT (BUSINESS LOGIC)
1. **Hierarki Evaluasi Hak Akses (`UserModel.isAgentSubscriptionActive`)**:
   - Apakah urutan evaluasi konsisten: `all_access` -> hak akses modul spesifik -> paket akun aktif (`tholib_1m`, `tholib_6m`, `bahits_1y`, `voucher_access`)?
   - Apakah ketiadaan atribut `status` pada dokumen Firestore diinterpretasikan dengan benar selama tanggal `expiry` masih aktif di masa depan?
2. **Aritmatika Tanggal & Batas Bulan**:
   - Bagaimana penambahan durasi langganan (30 hari, 1 bulan, 6 bulan, 1 tahun, 7 hari voucher) menangani akhir bulan pendek (28/29 Februari, 30 vs 31 hari)? Apakah ada potensi *date clamping bug*?
3. **Pengelolaan Antrean Outbox Cloud Run**:
   - Audit siklus hidup `provisioning_outbox`: Apakah status berpindah dari `pending` ke `completed` secara konsisten? Bagaimana mekanisme retry jika Cloud Run mengembalikan timeout (504) atau 429?
4. **Protokol Penghapusan Akun (`AuthService.deleteAccount`)**:
   - Apakah penghapusan akun Firebase Auth dilakukan setelah atau sebelum data Firestore dibersihkan? Bagaimana jika Firebase Auth melempar error `requires-recent-login`? Apakah data pengguna aman dari kondisi setengah terhapus (*orphaned state*)?

---

### DIMENSI 6: FITUR KAJIAN, ARABIC NORMALIZATION & RAG (FEATURES)
1. **Integrasi 7 Modul AI Spesialis**:
   - Fikih Syafi'i, Ushul Fiqih, Tafsir, Hadits, Bahasa Arab, Fikih Tahawwulat Bayan, dan Fikih Tahawwulat Muhaqqiq.
   - Apakah pemetaan ID notebook di Cloud Functions (`getAgentUrl`, `chatGate`) dan client `AgentModel` 100% sinkron tanpa ada ID yang tertukar?
2. **Normalisasi Pencarian Naskah Arab (`ArabicSearchNormalizer`)**:
   - Apakah mesin pencari katalog kitab mampu menormalisasi:
     - Bentuk Alif (`أ`, `إ`, `آ` -> `ا`).
     - Ya dan Alif Maqshurah (`ي`, `ى` -> `ي`).
     - Ta Marbuthah dan Ha (`ة` -> `ه`).
     - Penghilangan seluruh harakat (fathah, kasrah, dhammah, sukun, syaddah, tanwin).
   - Apakah pencarian toleran terhadap transliterasi latin santri (misal: *"I'anatut Tholibin"* vs *"Ianatuth Thalibin"*)?
3. **Fitur Simpanan & Kutipan Ilmiah**:
   - Bagaimana mekanisme penyalinan jawaban kajian? Apakah tombol "Salin Jawaban" mengambil teks bersih tanpa tag HTML dan menyertakan metadata rujukan kitab secara otomatis?

---

### DIMENSI 7: ADAB ILMIAH SANTRI & PEMBASMIAN AI SLOP (SCHOLARLY TONE)
1. **Pembasmian Istilah Brosur AI (*Anti-AI Slop*)**:
   - Cari dan musnahkan istilah-istilah generik seperti: *korpus digital, terintegrasi, komprehensif, solusi optimal, penelaahan mutakhir, presisi tinggi, teknologi canggih*.
   - Ganti dengan bahasa santri akademis yang bersahaja: *ruang kajian, kitab rujukan, telaah ibarah, marja' mu'tamad, catatan telaah*.
2. **Konsistensi Kamus Kanonik (`AppCopy`)**:
   - Pastikan seluruh string antarmuka merujuk ke `AppCopy` di `lib/core/app_copy.dart` dan tidak ada teks hardcoded liar di dalam widget.
3. **Ketiadaan Tanda Seru (!) pada Pesan Sistem**:
   - Pastikan notifikasi keberhasilan berkarakter tenang tanpa tanda seru: *"Tersimpan ke simpanan."*, *"Jawaban tersalin."*, *"Akses aktif."*

---

## 4. FORMAT LAPORAN AKHIR YANG WAJIB ANDA HASILKAN

Sajikan hasil audit secara terstruktur, mendalam, dan langsung dapat dieksekusi:

### 📊 1. SCORECARD EKSEKUTIF (RAPOR 360°)
Berikan nilai huruf (**A / B / C / D / F**) dan persentase skor kesiapan produksi untuk masing-masing dari 7 Dimensi di atas, disertai ringkasan 2 kalimat temuan paling kritis.

### 🐛 2. INVENTARISASI DEFECT & TEMUAN BUG LENGKAP
Sajikan temuan dalam tabel terperinci dengan klasifikasi:
- **P0 (Critical/Blocker)**: Celah keamanan, kebocoran akses, transaksi gagal, data korup, crash fatal.
- **P1 (High)**: Fitur utama pincang, memory leak, race condition, inkonsistensi status.
- **P2 (Medium)**: Masalah kelancaran UI, border ganda, kontras rendah, teks terpotong.
- **P3 (Low)**: Ketidakrapian kode, komentar usang, inkonsistensi minor.

| ID | Tingkat | Dimensi | Berkas & No. Baris | Deskripsi Masalah & Root Cause | Dampak Nyata |
| :--- | :--- | :--- | :--- | :--- | :--- |

### 📝 3. MATRIKS COPYWRITING & ADAB (Before vs After)
Tabel koreksi bahasa yang membandingkan kalimat lama (kaku / gaya brosur AI) dengan alternatif baru yang ringkas, ilmiah, dan mencerminkan adab tholibul ilmi.

### 🛠️ 4. KODE PERBAIKAN LENGKAP (PRODUCTION-READY PATCHES)
Untuk **seluruh temuan P0 dan P1**, berikan potongan kode perbaikan lengkap (Dart / TypeScript / Firestore Rules) yang siap disalin tanpa placeholder `// TODO`.

### 🧪 5. UNIT TEST PENJAMIN REGRESI
Sertakan kode pengujian unit baru untuk memastikan defect P0/P1 yang diperbaiki tidak akan pernah kambuh di masa depan.

### 🗺️ 6. ROADMAP PRIORITAS IMPLEMENTASI
Urutan aksi teknis terstruktur (Fase 1: Keamanan & Crash -> Fase 2: Performa & State -> Fase 3: Ergonomi & Copywriting).
