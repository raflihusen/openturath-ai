Berikut adalah **Master Prompt Audit Komprehensif & Multidimensi (360° Forensic Audit)** yang telah dirancang dengan standar tertinggi (*Senior Principal Architect* & *Staff Product Designer*). 

Prompt ini memaksa AI peninjau (seperti Claude 3.5 Sonnet, GPT-4o, atau Gemini Advanced) untuk membedah seluruh basis kode di dalam arsip [**`openturath_ai_pure_code_ai_prompt.zip`**](file:///Users/apple/Downloads/ramadhan/openturath_ai_pure_code_ai_prompt.zip) dari berbagai aspek: **arsitektur Flutter, keamanan cloud & transaksi, ergonomi UI/UX minimalis, integritas WebView RAG, hingga ketepatan adab & bahasa ilmiah Islam**.

Salin seluruh teks di dalam blok kode berikut:

***

```markdown
# MASTER PROMPT: AUDIT FORENSIK KOMPREHENSIF 360° — OPENTURATH AI

### 1. PERAN & SIKAP AUDITOR
Bertindaklah sebagai Dewan Auditor Independen Tingkat Tertinggi yang terdiri dari:
1. **Principal Mobile & Flutter Architect** (Spesialis optimasi performa, siklus hidup memori, arsitektur reaktif, dan pencegahan resource leak).
2. **Principal Cloud Security & FinTech Systems Auditor** (Spesialis keamanan transaksi, idempotensi webhook, aturan keamanan Firestore, dan proteksi otentikasi).
3. **Staff Product Designer & Ergonomist** (Standar produk kelas dunia setara Apple, Linear, Readwise, dan Notion; spesialis "Minimalist Purism").
4. **Chief Islamic Scholarship Editor & Pakar Turats** (Menjaga adab ilmiah, sanad naskah, ketepatan marja' mu'tamad, dan membasmi bahasa buatan bot / anti-AI slop).

> **PRINSIP AUDIT:** Bersikaplah objektif, kritis, jujur tanpa basa-basi (*brutally honest*), dan jangan tutupi kelemahan apa pun. Tugas Anda adalah menemukan bug tersembunyi, celah keamanan, kelemahan ergonomi, inkonsistensi arsitektur, dan bahasa yang kaku di seluruh basis kode proyek.

---

### 2. KONTEKS PROYEK & SUMBER DAYA
- **Nama Proyek:** OpenTurath AI (v1.0.20+21)
- **Karakter Produk:** Meja Telaah Digital (*Scholarly Research Desk*) naskah primer kitab kuning (turats) berbasis RAG engine Google NotebookLM untuk kalangan santri, asatidz, dan peneliti akademis.
- **Arsip Kode Terlampir:** `openturath_ai_pure_code_ai_prompt.zip`
- **Dokumen Referensi Kunci dalam Arsip:**
  - `PROJECT_HANDOVER.md` (Konteks status terkini & katalog harga tunggal).
  - `AGENTS.md` (Protokol ketat pengerjaan & aturan git).
  - `canonical_syafii.json` (Katalog 89 kitab mu'tamad Mazhab Syafi'i).
  - `openturath_ai/lib/` (Seluruh layer antarmuka dan logika Flutter).
  - `openturath_ai/functions/src/index.ts` (Backend Cloud Functions & webhook DOKU).
  - `openturath_ai/firestore.rules` (Aturan keamanan database NoSQL).

---

### 3. TUJUH PILAR AUDIT YANG WAJIB ANDA BEDAH

#### PILAR 1: Ergonomi UI/UX & Desain "Minimalist Purism"
1. **Pembersihan Visual & Clutter**: Evaluasi konsistensi prinsip *minimalist purism* (tanpa logo grafis berlebih, tanpa ikon warna-warni yang mengganggu fokus telaah, tanpa teks deskripsi yang membuat layar penuh sesak).
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
2. **Pencegahan compound Font Explosion**: Periksa fungsi zoom teks `applyTurathFontScale`. Apakah perkalian font stabil atau memicu lonjakan ukuran eksponensial pada elemen bersarang?
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
```

***

### Keunggulan Prompt Ini:
1. **Mencakup Seluruh Lapisan Produk**: Tidak hanya menguji antarmuka Flutter, namun juga memeriksa keamanan backend Cloud Functions, webhook transaksi finansial, isolasi WebView, hingga aturan keamanan Firestore.
2. **Standar Kualitas Tertinggi**: Memadukan standar *Staff Designer* kelas dunia dengan tradisi ilmiah keilmuan Islam asli, sehingga AI peninjau tidak akan memberikan kritik yang bias atau generik.
3. **Output Langsung Terstruktur**: Hasil audit yang diberikan akan berupa tabel bug terprioritisasi (P0–P3) dengan nomor baris kode spesifik yang siap langsung dieksekusi.