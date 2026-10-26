# Progress & Todo Tracker: Rekonstruksi Khademhrf ke Flutter macOS (OpenTurath V7) & Mesin UATE Ribuan Kitab

> **Cara Melanjutkan Jika Sesi Terputus / Error (Crash Recovery):**
> Buka percakapan baru lalu instruksikan:
> **"Baca `/Users/apple/Downloads/ramadhan/PROGRESS_KHADEMHRF.md` dan `/Users/apple/Downloads/ramadhan/MASTER_PROMPT_KHADEMHRF_OPENTURATH.md`, lalu lanjutkan item `[ ]` atau `[/]` berikutnya."**

---

## Daftar Todo Misi Panjang (Master Todo List)

### Fase 0: Inisialisasi Blueprint & Tracker
- [x] **T0.1** Kaji seluruh struktur biner, konfigurasi XML/XSLT, dan PDF metodologi di `/Users/apple/Downloads/khademhrf`.
- [x] **T0.2** Kaji seluruh aturan desain aplikasi Flutter (`openturath_ai/lib/core/design/`, `design_token_guard_test.dart`, `AGENTS.md`) dan Website V7 (`website/src/v7.mjs`, `website/public/assets/v7.css`, `website/public/assets/site.css`).
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
  - **Lapisan 1 & 2:** *Automated Sanad-Matn Segmenter & Dynamic Sanad Chain Parser (`parseSanadChainFromText`) & Iḥālah Expander* + *Multi-Edition Tarqīm & BookTaxonomy Attribution Formatter* (`أخرجه` vs `أورده` vs `في زوائده على`).
  - **Lapisan 3:** *Morphological Root Shingling + Inverted Root & Trigram Index + Two-Stage Threshold Clustering (80% High-Overlap & 50% Containment)* untuk skala ribuan kitab.
  - **Lapisan 4 & 5:** *Graph-Viterbi Ta‘yīn al-Ruwāt* + *Automated Madār, Mutāba‘āt & ‘Ilal DAG Engine* (menghasilkan pohon sanad terpadu, titik *madār*, status *ittiṣāl/inqiṭā‘/tadlīs/ikhtilāṭ*, dan teks laporan *Ikhtilāf ‘alā al-Madār*).
  - **Lapisan 6 & 7:** *Deterministic 27-Rule Muqāranat al-Mutūn* + *MSA Al-Matn al-Mujamma‘ Synthesizer* + *Automated Manuscript Takhrij Engine* (pemindai takhrij makalah otomatis).

### Fase 3: Implementasi & Penyempurnaan UI Flutter macOS Berbahasa Desain OpenTurath V7
- [x] **T3.1** Bangun & sempurnakan kanvas vektor arsitektural minimalis pohon sanad (`lib/widgets/hadith_isnad_dag_canvas.dart`):
  - Koordinat deterministik `(x, y)` per lapisan thabaqah dengan kurva Bézier vektor anti-aliased (`_ArchitecturalSanadPainter`) yang menghubungkan titik tengah setiap Guru ke Murid.
  - Pil interaktif *Sighah al-Taḥdīts* (`حدثنا`, `أخبرنا`, `عن`) yang dapat diklik untuk memeriksa status *Ittiṣāl / Inqiṭā‘ / ‘An‘anah Mudallis* beserta kitab pendukungnya.
  - Sorotan jalur aktif (*Active Lineage Highlighting*), filter fokus kitab mukharrij, pengubah arah pohon (*Sahabat → Mukharrij* vs *Mukharrij → Sahabat*), kontrol Zoom (`85%–130%`), mode kartu ringkas/lengkap, dan strip metrik V7 (`_V7MetricCell`).
- [x] **T3.2** Bangun & sempurnakan komponen takhrij bergaya Website V7 (`lib/widgets/hadith_takhrij_components.dart`):
  - `MujammaMatnCard` bergaya `study-spread` & `kurasi-list` dengan nomor seri `01`, `02`, tombol *Salin Matan Komposit*, dan *Simpan ke Tersimpan*.
  - `MatnComparisonOutcomeCard` bergaya `case-preview` dengan nomor seri, lencana Kaidah #1–27, metrik tabular, kutipan perbedaan kata ($\le 15$ kata), serta tombol *Salin* & *Buka di Tab Baru*.
  - `RawiBiographyInspectorCard` bergaya `bibliography-sheet` & `dl.ai-facts` dengan navigasi interaktif Guru (*Syuyūkh*) dan Murid (*Talāmīdz*) yang dapat diklik langsung.
- [x] **T3.3** Bangun & sempurnakan layar utama **Meja Telaah Hadis & Takhrij Ribuan Kitab** (`lib/screens/hadith_takhrij_workspace_screen.dart`):
  - Terintegrasi penuh dengan `BookmarkService` & `ResearchNotesService` (tombol *Simpan Takhrij* langsung masuk ke tab **Tersimpan** aplikasi).
  - Dilengkapi dialog **＋ Indeks Riwayat Baru** yang memisahkan sanad & matan, mengekstrak rantai perawi secara dinamis (`parseSanadChainFromText`), dan mengindeks hadis baru secara *real-time* ke dalam mesin 27 kaidah & pohon *Tasyjīr*.
  - Dilengkapi filter kategori kaidah lafaz (`بلفظه`, `بمثله`, `بنحوه`, `بمعناه`), penampil *Tawārīkh al-Mutūn*, serta chip interaktif *Syajarat al-Mawḍū‘āt* (`thematicTags`).
  - Terhubung dari Beranda (`dashboard_screen.dart`) dan halaman Studi/Spesialis (`specialist_list_screen.dart`).

### Fase 4: Pengujian, Verifikasi Token Guard, & Git Checkpoint
- [x] **T4.1** Buat & jalankan suite unit test komprehensif (`test/universal_takhrij_engine_test.dart`, 14 suite verifikasi otomatis lulus 100%).
- [x] **T4.2** Verifikasi `dart analyze` (`No issues found!`) dan kepatuhan 100% terhadap seluruh 6 penjaga regex di `test/design_token_guard_test.dart` (0 pelanggaran token).
- [x] **T4.3** Perbarui `PROGRESS_KHADEMHRF.md` dan `PROGRESS.md`, lalu buat Git commit checkpoint sesuai protokol `AGENTS.md`.

---

## Log Progres Eksekusi
- **2026-10-26 23:48**: Fase 0 selesai (`MASTER_PROMPT_KHADEMHRF_OPENTURATH.md` dan `PROGRESS_KHADEMHRF.md` dibuat).
- **2026-10-26 23:54**: Fase 1 selesai (`docs/REA_KHADEMHRF_EVIDENCE_LEDGER.md` dibuat).
- **2026-10-26 23:59**: Fase 2 selesai (`hadith_takhrij_models.dart`, `harf_morphology_service.dart`, dan `universal_takhrij_engine.dart` selesai dibangun).
- **2026-10-27 00:05**: Fase 3 & Fase 4 awal selesai (`42a77826`).
- **2026-10-27 00:26**: Penyempurnaan menyeluruh bergaya **Website V7 & App Native Terbaru**: kanvas *Tasyjīr al-Asānīd* vektor Bézier deterministik dengan inspeksi *Sighah* & *Zoom*, integrasi penyimpanan ke `BookmarkService` & `ResearchNotesService`, dialog **＋ Indeks Riwayat Baru** dengan parser sanad dinamis `parseSanadChainFromText`, filter kaidah lafaz & topik, integrasi ke `specialist_list_screen.dart`, verifikasi `dart analyze` (`No issues found!`) & 14 test suite (`100% PASS`).
