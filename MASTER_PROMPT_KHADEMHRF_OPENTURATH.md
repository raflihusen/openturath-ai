# MASTER PROMPT: Rekonstruksi Menyeluruh "Jami' Khadim al-Haramayn" (Khademhrf) ke Flutter macOS Berbasis Bahasa Desain OpenTurath (App + Website V6 + Meja Telaah) & Mesin Takhrij Algoritmik Skala Ribuan Kitab

Dokumen ini adalah blueprint arsitektur dan panduan instruksi lengkap untuk menghidupkan kembali aplikasi **Jāmi‘ Khādim al-Ḥaramayn al-Sharīfayn li-l-Sunnah al-Nabawiyyah al-Muṭahharah** (`/Users/apple/Downloads/khademhrf`) menjadi modul dan aplikasi native **Flutter macOS** di dalam ekosistem **OpenTurath** (`/Users/apple/Downloads/ramadhan/openturath_ai`), sekaligus merombak mesin takhrijnya dari **33 kitab statis** menjadi **ribuan kitab hadis secara algoritmik (Universal Algorithmic Takhrij Engine / UATE)**.

---

## BAGIAN I: PETA ARTEFAK TARGET (`khademhrf`) & PROTOKOL INVESTIGASI REA

Seluruh artefak sumber berada di `/Users/apple/Downloads/khademhrf/جامع خادم الحرمين الشريفين/`:

1. **Arsip Pembaruan & Installer:**
   - `02الباتش/Patch.zip` (3,5 MB, 2016-06-08): Berisi pembaruan biner terhadap rilis 2014 di `01جامع خادم الحرمين الشريفين/Source/`.
2. **Biner Utama & Mesin C++ Native (PE32 x86):**
   - `Source/HadithEncyProj.exe` (67,8 MB): Executable utama C++/MFC + embedded resources & static tables, mengakses `DatabaseName=HadithDB;Folder=Data\HadithDB`.
   - `Source/Engine0200.dll` (1,0 MB), `Source/LibCore0200.dll` (856 KB), `Source/EngineViewCom0200.dll` (276 KB): Mesin kueri hierarki *Nested Set* (`LeftValue`, `RightValue`, `ParentID`, `IsLeaf`) dan resolusi tabel (`BookToc_Hadith`, `BookTOC_Services`, `BookTOC_Sharh`, `BookTOC_Magem`, `BookTOC_Feqh`).
   - `Source/HarfMMMP01.dll` (2,8 MB), `Source/BuraqLib.dll` (868 KB), `Source/HLS.dll` (224 KB): *Harf Morphological Analyzer* & *Harf Linguistic Search* yang membaca:
     - `Source/HarfMMMP/` (`Roots.bin` 46 KB, `MPS.Bin` 40 KB, `HarfRecs.dat` 164 KB, `HarfIndex1..6.Dat`)
     - `Source/Derivative/` (`HarfDN.dat` 518 KB, `HarfDV.dat` 826 KB, `HarfDerivative.dat` 453 KB, `HarfDRootInx.dat` 92 KB)
     - `Source/Services/` (`HarfLIndex1..7.Dat`, `HarflexW.Dat` 218 KB)
   - `Source/AsaneedReport.dll` (256 KB): Generator laporan otomatis sanad (`التقرير الآلي للأسانيد`), penentu *al-Rāwī al-A‘lā*, *Rāwī al-Madār al-Ra’īs*, *Rāwī al-Madār al-Far‘ī*, serta evaluasi *ittiṣāl*, *inqiṭā‘*, *irsāl*, *ta‘līq*, *i‘ḍāl*, *tadlīs*, dan *ikhtilāṭ*.
3. **Biner Managed .NET / WPF & Komponen Visualisasi:**
   - `Source/HadithGraphSharp.dll` (62 KB) & `Source/DiagramDesigner.dll` (191 KB): Visualisasi graf pohon sanad (*Tasyjīr al-Asānīd*).
   - `Source/Translations/ResourceArSa.dll` (40 KB): Tabel string antarmuka.
   - `Source/Data/Asanedviewer.swf` (64 KB), `Timeline.swf` (29 KB), `arbtyp.swf` (9 KB), dan `Help.chm` (6,3 MB).
4. **Protokol URI Internal & Transformasi XSLT:**
   - `HadithXSLN.xsl`, `TakhreegXSL.xsl`, `PaneXSL.xsl`, `DialogsXSL.xsl`, `ServiceBooksXSL.xsl`, `DocXSL.xsl`, `DocwaXSL.xsl`, dan `StyleTemplate`:
     - `HadithNewChild-({@MainID}) ({@SayID})`
     - `HadithNewCompare-({@MainID}) ({@SayID})`
     - `ServiceBookNewChild-({@MainID}) ({@BookID}) ({@BookName}) ({@HadithNum}) ({@SayID})`
     - `AsaneedReportRawyID:{@ID}`
     - `RawiLink-{@ربط}`
     - `MMHits_HIDs{@HIDs}_MMID{@MMID}`
     - `Linking-{@ربط}`

---

## BAGIAN II: ARSITEKTUR UNIVERSAL ALGORITHMIC TAKHRIJ ENGINE (UATE) — DARI 33 KITAB KE RIBUAN KITAB

1. **Lapisan 1 — *Canonical Corpus Ingestion & Multi-Edition Tarqīm Resolver*:**
   - Mendukung ribuan kitab dari korpus OpenTurath / Shamela / OpenITI dengan pemetaan penomoran ganda (`CanonicalHadithURI` <-> `HarfNum`, `TarqeemMatboa1` [al-Risālah / Fu’ād ‘Abd al-Bāqī / al-‘Ālamiyyah], dan `[Juz/Halaman]`).
   - Mengganti *hardcode* `@BookID='26'` dengan metadata `BookTaxonomy`:
     - `musnad_primary` -> `أخرجه [المصنف] في "[الكتاب]"`
     - `zawaid_narrator` -> `أخرجه [الراوي] في زوائده على "[الكتاب]"`
     - `secondary_compilation` (*al-Maṭālib al-‘Āliyah*, *Majma‘ al-Zawā’id*, *Kanz al-‘Ummāl*, *Jāmi‘ al-Uṣūl*) -> `أورده [المصنف] في "[الكتاب]"`
     - `mustakhraj` (*Abū ‘Awānah*, *al-Ismā‘īlī*, *Abū Nu‘aym*) -> ditautkan ke hadis *aṣl* di *Ṣaḥīḥayn*.
     - `muqaddimah` -> `أخرجه [المصنف] في "مقدمة كتابه"`
     - `service_sharh_takhrij` -> ditautkan sebagai rujukan syarah, *aṭrāf*, dan *aqwāl al-ḥukm ‘alā al-ḥadīts*.
2. **Lapisan 2 — *Automated Sanad-Matn Segmenter & Iḥālah Expander*:**
   - Memisahkan rantai sanad (termasuk *Taḥwīl al-Sanad* `ح`), *al-Rāwī al-A‘lā*, dan teks matan (*marfū‘*, *mauqūf*, *maqṭū‘*), serta mengekspansi rujukan *iḥālah* (`مثله`, `بنحوه`) menjadi `<متن_مخفي>` / `<سند_مخفي>` untuk pengindeksan penuh.
3. **Lapisan 3 — *Morphological Root Shingling + LSH MinHash + Two-Stage Threshold Clustering*:**
   - Membaca kamus morfologi `Roots.bin` & `HarfDRootInx.dat` untuk mengubah setiap matan menjadi sekuens `(RootID, WaznID)` bebas *stop words* (`قائمة الكلمات المهملة`).
   - Mengindeks jutaan hadis dengan **LSH MinHash + Inverted Root-Trigram Index** dan menjalankan *Two-Stage Clustering* (Ambang 80% untuk penyatuan langsung + Ambang 50% dengan *Subsequence Containment* untuk menyatukan riwayat *mukhtaṣar* dan *muṭawwal* yang memiliki *Rāwī A‘lā* sama, serta memisahkan *Syawāhid*).
4. **Lapisan 4 — *Graph-Viterbi Ta‘yīn al-Ruwāt (Disambiguasi Perawi)*:**
   - Menyelesaikan nama perawi yang *muhmal* ("سفيان", "حماد") atau *mubham* menggunakan algoritma Viterbi di atas graf Guru-Murid (`RawiShyoukh` <-> `RawiTalamiz`), filter *Ṭabaqah*, rentang tahun wafat, dan *cross-chain corroboration* dalam klaster takhrij yang sama.
5. **Lapisan 5 — *Automated Madār, Mutāba‘āt & ‘Ilal DAG Engine*:**
   - Membangun *Directed Acyclic Graph (DAG)* sanad untuk menentukan *al-Rāwī al-A‘lā*, *Rāwī al-Madār al-Ra’īs*, *Rāwī al-Madār al-Far‘ī*, *Mutāba‘ah Tāmmah*, *Mutāba‘ah Qāṣirah*, deteksi *ittiṣāl / inqiṭā‘ / tadlīs / ikhtilāṭ*, serta laporan otomatis *Ikhtilāf ‘alā al-Madār*.
6. **Lapisan 6 — *Deterministic 27-Rule Muqāranat al-Mutūn & MSA Al-Matn al-Mujamma‘*:**
   - Mengimplementasikan ke-27 aturan perbandingan redaksi (`WorkingGroups.pdf` hlm. 59–63: `بلفظه`, `بلفظه مطولاً`, `بلفظه مختصراً دون قوله...`, `بمثله`, `بنحوه`, `بمعناه`, `من غير ذكر هذا اللفظ`, dll.) beserta aturan pemotongan segmen ≤ 15 kata dan 5 daftar kata bantu.
   - Merakit **Al-Matn al-Mujamma‘** secara otomatis dengan sisipan `[...]` bertautan sumber dan `[وفي رواية: ...]`.
7. **Lapisan 7 — *Automated Manuscript Takhrij Engine (التخريج الآلي للأبحاث العلمية)*:**
   - Memindai naskah makalah/riset yang berisi banyak kutipan hadis, melakukan takhrij otomatis lintas ribuan kitab, dan menyusun hasil beserta catatan kaki ilmiahnya.

---

## BAGIAN III: KONTRAK DESAIN OPENTURATH (ZERO-VIOLATION TOKEN GUARD)

1. **Lulus 100% `test/design_token_guard_test.dart`:**
   - Tidak ada `fontSize:` berangka di `lib/screens` dan `lib/widgets` (hanya `OTFontSize` `[11, 12, 14, 16, 18, 20, 22, 26, 36]` & `OTTypography`).
   - Tidak ada `circular(` berangka (hanya `OTRadius`).
   - Tidak ada `Color(0x...)` atau `Colors.*` selain `Colors.transparent` (hanya `OTColors`).
   - Tidak ada `.styleFrom(` di `lib/screens` (hanya tombol tema atau `OTButtons`).
   - Tidak ada angka `EdgeInsets` di luar `{0, 2, 4, 8, 12, 16, 20, 24, 32, 40, 48, 56, 64, 72, 96}` (hanya `OTSpacing`).
   - Hanya tiga bobot huruf: `FontWeight.w400`, `FontWeight.w600`, `FontWeight.w700`.
2. **Estetika *The Quiet Islamic Scholar*:**
   - Monokrom kertas arsip (`#F6F6F6` / `#FFFFFF` / `#EDEDED`) & tinta obsidian (`#151515` / `#292929` / `#353535`).
   - Tipografi 3-Pilar: `Scheherazade New` (teks Arab berharakat, `height >= 1.85`), `Newsreader` (judul editorial/kitab), `Outfit` & `Cairo` (antarmuka & angka monumental).
   - Menggunakan komponen resmi `OTBentoTile`, `OTChip`, `OTReveal`, `OTActiveFade`, `OTFlipCard`, dan `OTSkeletonList`.
