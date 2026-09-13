import os

base_dir = '/Users/apple/Downloads/ramadhan'
output_md = os.path.join(base_dir, 'OPENTURATH_AI_MASTER_AUDIT_PACK.md')
output_txt = os.path.join(base_dir, 'OPENTURATH_AI_MASTER_AUDIT_PACK.txt')

sections = []

header = """# MASTER AUDIT BUNDLE: OPENTURATH AI (v1.0.23+24)
# ==============================================================================
# PERHATIAN UNTUK AI AUDITOR (CLAUDE / CHATGPT / GEMINI / DEEPSEEK):
# Dokumen ini adalah SATU KESATUAN BERKAS TUNGGAL (SINGLE MONOLITHIC AUDIT PACK)
# yang memuat seluruh instrumen audit, spesifikasi arsitektur, dan seluruh
# kode sumber resmi aplikasi OpenTurath AI / Maktabah AI tanpa ada yang dipotong:
#
#   BAGIAN 1: INSTRUKSI & MASTER PROMPT AUDIT FORENSIK 360° (8 PILAR AUDIT)
#   BAGIAN 2: DOKUMENTASI KONTEKS PROYEK & ATURAN KERJA
#   BAGIAN 3: KEAMANAN DATABASE (firestore.rules) & BACKEND (functions/src/index.ts)
#   BAGIAN 4: SELURUH BASIS KODE SUMBER FLUTTER (lengkap di openturath_ai/lib/)
#   BAGIAN 5: SUITE PENGUJIAN UNIT & INTEGRASI (lengkap di openturath_ai/test/)
#
# TUGAS ANDA:
# Pelajari seluruh arsitektur dan baris kode pada Bagian 2 sampai Bagian 5,
# kemudian hasilkan Laporan Audit Forensik 360° sesuai format output yang
# diinstruksikan pada Bagian 1 di bawah ini.
# ==============================================================================

# BAGIAN 1: MASTER PROMPT AUDIT FORENSIK KOMPREHENSIF 360°

### 1. PERAN & SIKAP AUDITOR
Bertindaklah sebagai Dewan Auditor Independen Tingkat Tertinggi yang terdiri dari:
1. **Principal Mobile & Flutter Architect** (Spesialis optimasi performa 60/120 FPS, siklus hidup memori, arsitektur reaktif, dan pencegahan resource leak).
2. **Principal Cloud Security & FinTech Systems Auditor** (Spesialis keamanan transaksi, idempotensi webhook, aturan keamanan Firestore, proteksi anti-abuse voucher, dan isolasi identitas perangkat).
3. **Staff Product Designer & Ergonomist** (Standar produk kelas dunia setara Apple, Linear, Readwise, dan Notion; spesialis "Minimalist Purism").
4. **Chief Islamic Scholarship Editor & Pakar Turats** (Menjaga adab ilmiah, sanad naskah, ketepatan marja' mu'tamad, khat Arab Naskh klasik, dan membasmi bahasa buatan bot / anti-AI slop).

> **PRINSIP AUDIT:** Bersikaplah objektif, kritis, jujur tanpa basa-basi (*brutally honest*), dan jangan tutupi kelemahan apa pun. Tugas Anda adalah membongkar bug tersembunyi, celah keamanan, kelemahan ergonomi, inkonsistensi arsitektur, potensi crash, dan bahasa kaku di seluruh basis kode proyek.

---

### 2. KONTEKS PROYEK & SUMBER DAYA
- **Nama Entitas & Produk:** OpenTurath (Induk Lembaga) & Maktabah AI (Aplikasi Meja Telaah Kitab).
- **Versi Rilis Terkini:** v1.0.23+24
- **Karakter Produk:** Meja Telaah Digital (*Scholarly Research Desk*) naskah primer kitab kuning (turats) berbasis RAG engine Google NotebookLM untuk kalangan santri, asatidz, dan peneliti akademis.
- **Basis Kode Terlampir:** Seluruh dokumen arsitektur, aturan keamanan, backend Cloud Functions, seluruh kode Flutter (`openturath_ai/lib/`), dan suite pengujian unit (`openturath_ai/test/`) telah **TERLAMPIR LENGKAP PADA BAGIAN 2 SAMPAI BAGIAN 5 DI BAWAH INI**.

---

### 3. DELAPAN PILAR AUDIT YANG WAJIB ANDA BEDAH

#### PILAR 1: Concurrency, Re-entrancy & Anti-Lag Navigation Guard
1. **Single-Flight Navigation Guard**: Analisis implementasi `NavigationGuard.safePushNamed` di `lib/core/navigation_guard.dart`. Apakah ada skenario ekstrem di mana navigasi tetap bisa tembus (bypass) saat async timeout, exception, atau navigasi bersarang?
2. **Asynchronous Tap Debounce**: Periksa seluruh layar (`ProfileScreen`, `SpecialistListScreen`, `DashboardScreen`, `AgentWebviewScreen`, `BookDetailScreen`). Apakah semua aksi tombol (terutama langganan, checkout, bookmark, dan pergantian tab) terlindung dari multiple rapid taps saat HP mengalami frame drop / lag jaringan?
3. **Penyimpanan Status Bersama (Session Concurrency)**: Audit `AgentSessionManager`. Apakah pembukaan tab yang bersamaan dapat memicu race condition pada urutan tab atau state WebView?

#### PILAR 2: Animasi "Fathul Kitab", Ergonomi UI/UX & Desain "Minimalist Purism"
1. **Koreografi Buka-Tutup Ruang AI**: Periksa implementasi `AnimationController` (380ms `Curves.fastOutSlowIn`, 300ms `Curves.easeInOutCubic`) di `MainShellScreen`. Apakah sinkronisasi antara backdrop dimmer, depth scale (0.975), dan slide transition benar-benar mulus di 60/120 FPS tanpa frame drop?
2. **Predictive Back Navigation (`PopScope`)**: Uji penanganan tombol kembali di Android. Apakah ada kondisi di mana menekan tombol kembali saat ruang AI terbuka malah menutup aplikasi secara tidak sengaja?
3. **Pembersihan Visual & Clutter**: Evaluasi konsistensi prinsip *minimalist purism* (tanpa logo grafis berlebih, tanpa ikon kotak warna-warni yang mengganggu fokus telaah, tanpa teks deskripsi yang membuat layar penuh sesak).
4. **Hierarki Tipografi 3 Lapis**:
   - *Newsreader* (Serif): Judul korpus, brand, dan aksen editorial.
   - *Outfit* (Sans): UI, navigasi, tombol, metadata.
   - *Scheherazade New* (Khat Naskh Klasik): Teks Arab naskah asli (keterbacaan harakat, penataan margin, Directionality RTL murni).

#### PILAR 3: Arsitektur Flutter, State Lifecycle & Performa Memori
1. **Pencegahan Memory Leak**: Periksa apakah ada `TextEditingController`, `PageController`, `AnimationController`, `Timer`, atau listener `StreamSubscription` yang tidak di-dispose dengan aman.
2. **Zero-Reload WebView**: Periksa apakah `const AgentMultiTabRoom()` diikat dengan benar pada `AnimatedBuilder` sehingga native WebView tidak pernah di-destroy atau reload saat ruang AI dibuka/ditutup.
3. **Rekonstruksi Widget (Rebuild Optimization)**: Audit penggunaan `setState`, `ListenableBuilder`, dan `ChangeNotifier`. Apakah ada rebuild berlebih (*unnecessary tree rebuild*) pada scroll list panjang atau saat tema berubah?

#### PILAR 4: Keamanan Cloud Functions, Transaksi Finansial (DOKU) & Hak Akses
1. **Idempotensi Webhook & Anti-Replay**: Analisis `processSuccessfulPayment` di `functions/src/index.ts`. Apakah ada celah transaksi ganda jika webhook DOKU ditembak berulang kali secara simultan?
2. **Atomisitas Firestore**: Verifikasi bahwa pembaruan status transaksi, aktivasi hak akses (`entitlements`), dan pencatatan outbox dijalankan dalam satu `db.runTransaction` atomik.
3. **Proteksi Multi-Akun Kode Redeem (Device Fingerprinting)**: Audit implementasi pembatasan voucher 1 klaim per perangkat fisik via SHA-256 salted hash di `DeviceService` dan `functions/src/index.ts`. Apakah ada celah pemalsuan fingerprint atau bypass via emulator?
4. **Kepatuhan Firestore Rules (`firestore.rules`)**: Uji apakah pengguna biasa dapat memodifikasi koleksi `entitlements`, `transactions`, `device_redemptions`, atau `provisioning_outbox` secara ilegal dari client SDK.

#### PILAR 5: Isolasi WebView, Native Dark Mode & RAG Engine Stability
1. **Native Dark Mode Integration**: Evaluasi efektivitas injeksi CSS dan script JavaScript DOM `applyOtTheme(isDark)` pada `notebook_ui_script.dart` serta pengaturan engine `forceDark: ForceDark.ON`. Apakah ada kebocoran kontras putih (#FFFFFF) saat tema gelap aktif?
2. **Scrubbing Disclaimer Google/Gemini**: Evaluasi script JavaScript DOM cleaner dalam menyembunyikan disclaimer Google (*"Gemini may display inaccurate info..."*, header bar, logo bar, dsb.). Apakah script ini tahan terhadap mutasi DOM asinkron dari Google NotebookLM?
3. **Keamanan URL & Redirection Guard**: Pastikan `shouldOverrideUrlLoading` memblokir redirect keluar yang tidak sah tanpa merusak alur autentikasi resmi akun Google atau sesi NotebookLM.

#### PILAR 6: Adab Turats, Bahasa Fusha & Anti-AI Slop
1. **Layar Tentang Kitab Full Bahasa Arab**: Audit `book_detail_screen.dart`. Apakah istilah turats baku (`بطاقة الكتاب`, `متن معتمد`, `شرح`, `حاشية`, `عصر المتقدمين`) dan tata letak RTL murni telah diterapkan secara sempurna tanpa ada teks latin yang janggal?
2. **Pembasmian Bahasa Robotik / Generik**: Cari kalimat-kalimat klise hasil generate AI yang kaku, bertele-tele, atau terasa palsu. Seluruh copywriting harus berwibawa, tenang, dan santun.

#### PILAR 7: Ketahanan Offline, Penanganan Error & Kepatuhan Platform
1. **Resiliensi Jaringan & Timeout**: Bagaimana aplikasi merespons kegagalan koneksi saat membuka WebView, memuat daftar spesialis, atau mengecek status langganan? Apakah in-memory cache dan fallback lokal berfungsi optimal?
2. **Kepatuhan Google Play (Account Deletion Protocol)**: Audit alur `AuthService.deleteAccount()`. Apakah proses menghapus akun Auth Firebase dilakukan sebelum data Firestore dibersihkan untuk mencegah data terhapus saat terjadi error `requires-recent-login`?
3. **Standarisasi Email Kontak**: Pastikan seluruh rujukan email bantuan dan refund konsisten ke `openturath@gmail.com`.

#### PILAR 8: Validasi Unit Test & Boundary Coverage
1. **Analisis Suite Pengujian**: Tinjau berkas-berkas di `openturath_ai/test/` (129 unit tests). Apakah pengujian mencakup batas logika nyata (*boundary conditions*, *leap years 29 Feb*, *clamped month-ends*, *concurrent double tap*, *device binding*, *arabic search diacritics*)?
2. **Area Tanpa Tes (Blind Spots)**: Identifikasi fungsi kritis apa saja yang belum memiliki cakupan unit test.

---

### 4. FORMAT LAPORAN AKHIR YANG WAJIB ANDA SAJIKAN

Sajikan hasil audit secara terstruktur dan mendalam dengan sistematika berikut:

#### 1. EXECUTIVE SCORECARD (Rapor 360°)
Berikan nilai (A / B / C / D / F) beserta ringkasan temuan kunci untuk masing-masing dari 8 pilar di atas.

#### 2. INVENTARISASI DEFECT & TEMUAN BUG (Tabel P0 – P3)
Kelompokkan temuan dengan format tabel:
- **Tingkat Keparahan:**
  - **P0 (Critical/Fatal):** Kebocoran keamanan, transaksi rusak, crash fatal, atau hak akses bocor.
  - **P1 (High):** Fitur utama tidak berjalan sebagaimana mestinya, memory leak, atau inkonsistensi status navigasi.
  - **P2 (Medium):** Masalah visual, animasi tersendat, border ganda, atau ketidaknyamanan ergonomis.
  - **P3 (Low):** Ketidakrapian kode, komentar usang, atau ketidakseragaman minor.
- **Kolom Tabel:** `ID Temuan` | `Tingkat (P0-P3)` | `Pilar Terkait` | `Nama File & No. Baris` | `Deskripsi Masalah & Dampak`

#### 3. MATRIKS COPYWRITING OVERHAUL (Before vs After)
Tabel perbandingan kata-kata lama (kaku / gaya bot AI) dengan alternatif baru yang ringkas, elegan, dan bernuansa ilmiah santri modern.

#### 4. REKOMENDASI KODE PERBAIKAN KONKRET (Actionable Code Patches)
Berikan potongan kode Dart / TypeScript spesifik untuk memperbaiki temuan P0 dan P1 yang paling kritis.

#### 5. ROADMAP PRIORITAS EKSEKUSI
Langkah-langkah terurut yang harus diambil oleh tim pengembang untuk menjadikan aplikasi ini 100% siap produksi dan berstandar internasional.
"""

sections.append(header)
sections.append("\n\n" + "="*80 + "\n# BAGIAN 2: DOKUMENTASI KONTEKS PROYEK & ATURAN KERJA\n" + "="*80 + "\n\n")

# Context docs
doc_files = [
    'PROJECT_HANDOVER.md',
    'AGENTS.md',
    'openturath_ai/pubspec.yaml',
    'openturath_ai/android/app/src/main/AndroidManifest.xml',
    'canonical_syafii.json'
]

for rel in doc_files:
    p = os.path.join(base_dir, rel)
    if os.path.exists(p):
        sections.append(f"## DOKUMEN: {rel}\n```\n")
        with open(p, 'r', encoding='utf-8') as f:
            sections.append(f.read())
        sections.append("\n```\n\n")

sections.append("\n\n" + "="*80 + "\n# BAGIAN 3: KEAMANAN DATABASE & BACKEND CLOUD FUNCTIONS\n" + "="*80 + "\n\n")

backend_files = [
    'openturath_ai/firestore.rules',
    'openturath_ai/functions/src/index.ts'
]

for rel in backend_files:
    p = os.path.join(base_dir, rel)
    if os.path.exists(p):
        lang = 'typescript' if rel.endswith('.ts') else 'javascript'
        sections.append(f"## BERKAS BACKEND: {rel}\n```{lang}\n")
        with open(p, 'r', encoding='utf-8') as f:
            sections.append(f.read())
        sections.append("\n```\n\n")

sections.append("\n\n" + "="*80 + "\n# BAGIAN 4: SELURUH BASIS KODE FLUTTER (openturath_ai/lib/)\n" + "="*80 + "\n\n")

lib_dir = os.path.join(base_dir, 'openturath_ai/lib')
dart_files = []
for root, dirs, files in os.walk(lib_dir):
    for f in sorted(files):
        if f.endswith('.dart'):
            rel = os.path.relpath(os.path.join(root, f), base_dir)
            dart_files.append((rel, os.path.join(root, f)))

dart_files.sort(key=lambda x: x[0])
for rel, full_path in dart_files:
    sections.append(f"### FLUTTER FILE: {rel}\n```dart\n")
    with open(full_path, 'r', encoding='utf-8') as f:
        sections.append(f.read())
    sections.append("\n```\n\n")

sections.append("\n\n" + "="*80 + "\n# BAGIAN 5: SUITE PENGUJIAN UNIT & INTEGRASI (openturath_ai/test/)\n" + "="*80 + "\n\n")

test_dir = os.path.join(base_dir, 'openturath_ai/test')
test_files = []
for f in sorted(os.listdir(test_dir)):
    if f.endswith('.dart'):
        rel = os.path.join('openturath_ai/test', f)
        test_files.append((rel, os.path.join(test_dir, f)))

for rel, full_path in test_files:
    sections.append(f"### TEST FILE: {rel}\n```dart\n")
    with open(full_path, 'r', encoding='utf-8') as f:
        sections.append(f.read())
    sections.append("\n```\n\n")

full_text = "".join(sections)

with open(output_md, 'w', encoding='utf-8') as f:
    f.write(full_text)

with open(output_txt, 'w', encoding='utf-8') as f:
    f.write(full_text)

print("SUCCESS")
print(f"Output MD: {output_md} ({os.path.getsize(output_md) / 1024:.1f} KB, {len(full_text.splitlines())} lines)")
print(f"Output TXT: {output_txt} ({os.path.getsize(output_txt) / 1024:.1f} KB, {len(full_text.splitlines())} lines)")
