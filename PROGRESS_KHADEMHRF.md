# Progress & Todo Tracker: Rekonstruksi Khademhrf ke Flutter macOS (OpenTurath) & Mesin UATE Ribuan Kitab

> **Cara Melanjutkan Jika Sesi Terputus / Error (Crash Recovery):**
> Buka percakapan baru lalu instruksikan:
> **"Baca `/Users/apple/Downloads/ramadhan/PROGRESS_KHADEMHRF.md` dan `/Users/apple/Downloads/ramadhan/MASTER_PROMPT_KHADEMHRF_OPENTURATH.md`, lalu lanjutkan item `[ ]` atau `[/]` berikutnya."**

---

## Daftar Todo Misi Panjang (Master Todo List)

### Fase 0: Inisialisasi Blueprint & Tracker
- [x] **T0.1** Kaji seluruh struktur biner, konfigurasi XML/XSLT, dan PDF metodologi di `/Users/apple/Downloads/khademhrf`.
- [x] **T0.2** Kaji seluruh aturan desain aplikasi Flutter (`openturath_ai/lib/core/design/`, `design_token_guard_test.dart`, `AGENTS.md`) dan Website V6 (`immersive.css`, `open_turath_meja_telaah_v5.html`).
- [x] **T0.3** Simpan blueprint paripurna di `/Users/apple/Downloads/ramadhan/MASTER_PROMPT_KHADEMHRF_OPENTURATH.md`.
- [x] **T0.4** Buat dokumen pelacakan mandiri `/Users/apple/Downloads/ramadhan/PROGRESS_KHADEMHRF.md`.

### Fase 1: Rekayasa Balik (REA) Artefak Biner, Kamus Morfologi, & Skema `khademhrf`
- [x] **T1.1** Bedah struktur biner kamus morfologi & indeks (`HarfMMMP/Roots.bin`, `MPS.Bin`, `HarfRecs.dat`, `HarfIndex1..6.Dat`, `Derivative/HarfDN.dat`, `HarfDV.dat`, `HarfDerivative.dat`, `HarfDRootInx.dat`, serta `Services/HarfLIndex1..7.Dat`, `HarflexW.Dat`).
- [x] **T1.2** Analisis `02الباتش/Patch.zip` dan biner PE/CLI (`HadithEncyProj.exe`, `Engine0200.dll`, `LibCore0200.dll`, `HarfMMMP01.dll`, `BuraqLib.dll`, `HLS.dll`, `AsaneedReport.dll`, `HadithGraphSharp.dll`) serta sisa akhir `Configraution.XML` dan `Introduction.pdf` (daftar 33 kitab matan & kitab khadami).
- [x] **T1.3** Tulis laporan bukti lengkap rekayasa balik di `/Users/apple/Downloads/ramadhan/docs/REA_KHADEMHRF_EVIDENCE_LEDGER.md`.

### Fase 2: Pembangunan Mesin "Universal Algorithmic Takhrij Engine (UATE)" di `openturath_ai`
- [x] **T2.1** Buat model data & taksonomi ribuan kitab (`lib/models/hadith_takhrij_models.dart`):
  - Mencakup `HadithBookTaxonomy` (`musnadPrimary`, `zawaidNarrator`, `secondaryCompilation`, `mustakhraj`, `muqaddimah`, `serviceSharhTakhrij`), `CanonicalHadithRecord`, `SanadGraphNode`, `SanadGraphEdge`, `MadarAndIlalReport`, `MatnComparisonOutcome` (27 label), dan `MujammaSegment`.
- [x] **T2.2** Buat pembaca kamus morfologi biner Harf & penganalisis akar kata Arab (`lib/services/harf_morphology_service.dart`):
  - Membaca langsung `Roots.bin` / `HarfDRootInx.dat` (dengan fallback algoritmik *sawābiq/lawāḥiq/wazan/jadzr* cepat untuk macOS/lintas-platform) + 5 daftar kata bantu (`قائمة الكلمات المهملة`, dll.).
- [x] **T2.3** Buat mesin inti **UATE 7-Lapis** (`lib/services/universal_takhrij_engine.dart`):
  - **Lapisan 1 & 2:** *Automated Sanad-Matn Segmenter & Iḥālah Expander* + *Multi-Edition Tarqīm & BookTaxonomy Attribution Formatter* (`أخرجه` vs `أورده` vs `في زوائده على`).
  - **Lapisan 3:** *Morphological Root Shingling + LSH MinHash + Two-Stage Threshold Clustering (80% High-Overlap & 50% Containment)* untuk skala ribuan kitab.
  - **Lapisan 4 & 5:** *Graph-Viterbi Ta‘yīn al-Ruwāt* + *Automated Madār, Mutāba‘āt & ‘Ilal DAG Engine* (menghasilkan pohon sanad terpadu, titik *madār*, status *ittiṣāl/inqiṭā‘/tadlīs/ikhtilāṭ*, dan teks laporan *Ikhtilāf ‘alā al-Madār*).
  - **Lapisan 6 & 7:** *Deterministic 27-Rule Muqāranat al-Mutūn* + *MSA Al-Matn al-Mujamma‘ Synthesizer* + *Automated Manuscript Takhrij Engine* (pemindai takhrij makalah otomatis).

### Fase 3: Implementasi UI Flutter macOS Berbahasa Desain OpenTurath
- [x] **T3.1** Buat widget kanvas vektor pohon sanad monokrom & komponen takhrij (`lib/widgets/hadith_isnad_dag_canvas.dart` & `lib/widgets/hadith_takhrij_components.dart`):
  - Kanvas interaktif *Tasyjīr al-Asānīd* monokrom (pengganti `HadithGraphSharp.dll` & `Asanedviewer.swf`), kartu perbandingan 27 aturan *Muqāranat al-Mutūn*, penampil interaktif *Al-Matn al-Mujamma‘* (`[...]` & `[وفي رواية: ...]`), serta lembar inspector *Tarjamat al-Rāwī & Jarḥ wa Ta‘dīl*.
- [x] **T3.2** Buat layar utama **Meja Telaah Hadis & Takhrij Ribuan Kitab** (`lib/screens/hadith_takhrij_workspace_screen.dart`):
  - Mengusung tata letak 3-kolom desktop macOS (*Minimal Scholarly Workspace*), mendukung multi-tab (`maxTabs = 5`), tab *Takhrij & 27 Kaidah Lafaz*, *Matan, Sanad & Al-Matn al-Mujamma‘*, *Tasyjīr Sanad & Laporan ‘Ilal*, *Disambiguasi Rijal Muhmal*, serta *Takhrij Otomatis Makalah*.
- [x] **T3.3** Integrasikan akses ke layar *Meja Telaah Hadis & Takhrij* dari `dashboard_screen.dart`, `routes.dart`, dan `main.dart` tanpa merusak alur WebView atau layar yang sudah ada.

### Fase 4: Pengujian, Verifikasi Token Guard, & Git Checkpoint
- [x] **T4.1** Buat suite unit test komprehensif (`test/universal_takhrij_engine_test.dart`) yang menguji ke-27 aturan *Muqāranat al-Mutūn*, klasterisasi 80%/50% *Jāmi‘ al-Matn*, pembaca akar kata `Roots.bin`, deteksi *Madār* & *Ikhtilāf*, sintesis *Al-Matn al-Mujamma‘*, dan taksonomi ribuan kitab.
- [x] **T4.2** Verifikasi kepatuhan 100% terhadap seluruh aturan regex di `test/design_token_guard_test.dart` (0 pelanggaran token).
- [x] **T4.3** Perbarui `PROGRESS_KHADEMHRF.md` dan `PROGRESS.md`, lalu buat Git commit checkpoint sesuai protokol `AGENTS.md`.

---

## Log Progres Eksekusi
- **2026-10-26 23:48**: Fase 0 selesai (`MASTER_PROMPT_KHADEMHRF_OPENTURATH.md` dan `PROGRESS_KHADEMHRF.md` dibuat).
- **2026-10-26 23:54**: Fase 1 selesai (`docs/REA_KHADEMHRF_EVIDENCE_LEDGER.md` dibuat dengan hasil pembedahan biner PE/CLI, kamus morfologi `Roots.bin`, dan skema database `khademhrf`).
- **2026-10-26 23:59**: Fase 2 selesai (`hadith_takhrij_models.dart`, `harf_morphology_service.dart`, dan `universal_takhrij_engine.dart` selesai dibangun).
- **2026-10-27 00:05**: Fase 3 & Fase 4 selesai (`hadith_isnad_dag_canvas.dart`, `hadith_takhrij_components.dart`, `hadith_takhrij_workspace_screen.dart`, `universal_takhrij_engine_test.dart`, integrasi `routes.dart`/`main.dart`/`dashboard_screen.dart`, audit 6 regex `design_token_guard_test.dart` 100% bersih, dan Git checkpoint commit).
