# Laporan Bukti Rekayasa Balik (REA Evidence Ledger): Jāmi‘ Khādim al-Ḥaramayn al-Sharīfayn (`khademhrf`)

> **Lokasi Artefak Sumber:** `/Users/apple/Downloads/khademhrf/جامع خادم الحرمين الشريفين/`  
> **Target Rekonstruksi:** Modul & Workspace Native **Flutter macOS** di `/Users/apple/Downloads/ramadhan/openturath_ai/`  
> **Tujuan Utama:** Menghidupkan kembali seluruh kapabilitas *Jāmi‘ Khādim al-Ḥaramayn* (Matan, Takhrij, Muqāranat al-Mutūn, Al-Matn al-Mujamma‘, Tasyjīr al-Asānīd, Laporan ‘Ilal & Madār, serta Rijal) dalam bahasa desain **OpenTurath Monochrome Editorial** sekaligus memperluas cakupan takhrij dari **33 kitab statis** menjadi **ribuan kitab hadis secara algoritmik (UATE)**.

---

## 1. Inventaris Biner, Pustaka Dinamis (DLL), & Sumber Daya (`Source/`)

| Berkas Artefak | Ukuran | Tanggal | Jenis Biner | Fungsi Hasil Bedah Arsitektur |
| :--- | :---: | :---: | :--- | :--- |
| `Source/HadithEncyProj.exe` | 67,8 MB | 2014-03-10 | PE32 Native C++/MFC | Executable utama aplikasi; memuat kontrol antarmuka Codejock (`ToolkitPro1122vc80`), handler protokol URI XSLT, serta orkestrasi kueri ke `HadithDB`. |
| `02الباتش/Patch.zip` | 3,5 MB | 2016-06-08 | ZIP Archive | Paket pembaruan pasca-rilis 2014 untuk perbaikan stabilitas mesin dan pembacaan indeks. |
| `Source/Engine0200.dll` | 1,0 MB | 2013-07-17 | PE32 Native C++ | Mesin basis data relasional/hierarkis yang mengeksekusi kueri pohon *Nested Set* (`LeftValue`, `RightValue`, `ParentID`, `IsLeaf`) sesuai pemetaan `Configraution.XML`. |
| `Source/LibCore0200.dll` | 856 KB | 2013-07-17 | PE32 Native C++ | Pustaka struktur data dasar, manajemen buffer UTF-16, dan serialisasi XML internal. |
| `Source/EngineViewCom0200.dll` | 276 KB | 2010-05-18 | PE32 COM DLL | Jembatan COM antara kontrol tampilan HTML/XSLT (`MSHTML`) dan mesin C++ (`Engine0200.dll`). |
| `Source/HarfMMMP01.dll` | 2,8 MB | 2013-07-17 | PE32 Native C++ | **Harf Morphological Analyzer**: mengupas *sawābiq* (prefiks), *lawāḥiq* (sufiks), *wazan* (pola morfologis), dan *jadzr* (akar kata) menggunakan berkas biner di `Source/HarfMMMP/` dan `Source/Derivative/`. |
| `Source/BuraqLib.dll` & `HLS.dll` | 868 KB & 224 KB | 2013-07-17 | PE32 Native C++ | **Harf Linguistic Search**: mesin indeks terbalik (*inverted index*) untuk pencarian leksikal, morfologis, akar kata, dan *proximity search* (berurutan maupun berjauhan). |
| `Source/AsaneedReport.dll` | 256 KB | 2014-03-06 | PE32 Native C++ | **Automated Isnad Report Generator**: menentukan *al-Rāwī al-A‘lā*, *Rāwī al-Madār al-Ra’īs*, *Rāwī al-Madār al-Far‘ī*, serta merakit teks laporan otomatis *ittiṣāl/inqiṭā‘* dan *ikhtilāf ‘alā al-madār*. |
| `Source/HadithGraphSharp.dll` | 62 KB | 2014-02-24 | .NET CLI Assembly | Modul visualisasi graf pohon sanad (*Tasyjīr al-Asānīd*) berbasis WPF (`GraphSharp.dll`, `QuickGraph.dll`, `DiagramDesigner.dll`, `WPFExtensions.dll`). |
| `Source/Data/Asanedviewer.swf` & `Timeline.swf` | 64 KB & 29 KB | 2009 | Shockwave Flash | Applet legacy untuk penampil pohon sanad alternatif dan lini masa kronologis sejarah matan (*Tawārīkh al-Mutūn* dari البعثة hingga الوفاة). |

---

## 2. Bedah Berkas Indeks Biner (`HarfMMMP/`, `Derivative/`, `Services/`)

1. **`Source/HarfMMMP/` (Indeks Morfologi & Pencarian Matan Utama):**
   - `Roots.bin` (46 KB): Tabel kamus akar kata bahasa Arab (trilateral & kuadrilateral) yang dipetakan ke ID numerik 16-bit.
   - `MPS.Bin` (40 KB): Tabel *Morphological Patterns & Affixes* (kombinasi *sawābiq*, *lawāḥiq*, dan *awzān*).
   - `HarfRecs.dat` (164 KB): Rekaman pemetaan dokumen/paragraf hadis.
   - `HarfIndex1.Dat` (654 KB), `HarfIndex2.Dat` (1,2 MB), `HarfIndex3.Dat` (38 KB), `HarfIndex4.Dat` (4 KB), `HarfIndex5.Dat` (2 KB), `HarfIndex6.Dat` (233 KB): Berkas *posting list* bertingkat untuk pencarian kata, frasa, stem, dan akar kata.
2. **`Source/Derivative/` (Kamus Derivasi Kata Benda & Kata Kerja):**
   - `HarfDN.dat` (518 KB): Kamus derivasi *Ism* (kata benda / *Derivative Nouns*).
   - `HarfDV.dat` (826 KB): Kamus derivasi *Fi‘l* (kata kerja / *Derivative Verbs*).
   - `HarfDerivative.dat` (453 KB) & `HarfDRootInx.dat` (92 KB): Indeks silang antara akar kata dan seluruh turunan morfologisnya.
3. **`Source/Services/` (Indeks Kitab Khadami — Syarah, Rijal, Gharib, Mustalah):**
   - `HarfLIndex1..7.Dat` (total ~949 KB) & `HarflexW.Dat` (218 KB): Indeks leksikal terpisah khusus untuk kitab-kitab layanan (*Kutub Khadamiyyah*).

---

## 3. Skema Basis Data (`Configraution.XML`) & Protokol URI Internal (`*.xsl`)

### A. Tabel Inti di `HadithDB`
- **Tabel Hirarki & Konten Kitab (Model *Nested Set* `LeftValue` / `RightValue`):**
  - `BookToc_Hadith`: Menyimpan 33 kitab matan (`MainID`, `BookID`, `BookName`, `ParentID`, `ParagraphID`, `IsLeaf`, `LeftValue`, `RightValue`, `Tarf`, `TarqeemMatboa1`, `Content`).
  - `BookTOC_Services`, `BookTOC_Sharh`, `BookTOC_Magem`, `BookTOC_Feqh`: Menyimpan kitab-kitab syarah, takhrij, rijal, gharib, dan fikih.
- **Tabel Takhrij, *Jāmi‘ al-Matn*, & *Muqāranat al-Mutūn*:**
  - `HadithTakhreegList`: Daftar takhrij per hadis (`MainID`, `Tarf`, `BookName`, `TarqeemMatboa1`).
  - `CM_MainAhadith` (`HCompoundMatn`): Menyimpan teks **Al-Matn al-Mujamma‘** (`CmpID`, `Tarf`, `BookName`, `TarqeemMatboa1`, `Content`, `MainID`).
  - `CompareMatchSort` (urutan kemiripan lafaz), `CompareLengthSort` (urutan panjang matan), `CompareStrongSort` (urutan tingkat keshahihan kitab).
- **Tabel Rijal, *Jarḥ wa Ta‘dīl*, & *‘Ilal*:**
  - `Nouns` & `TaragemRwa`: Basis data identitas perawi (`ID`, `Name`, `EsmShuhra`, `Laqab`, `Kunia`, `Nasab`, `LivingCity`, `Mazhb`, `BirthYear`, `DeathYear`, `Tabaqa`, `TabaqaNum`, `MartabaIbnHajar`, `MartabaZahabi`, `IsMobham`).
  - `RawiShyoukh` / `RawiTalamiz` (`NounsShyoukhTalamize`): Graf relasi guru-murid beserta `HadithsCount`.
  - `ScientistsCriticizeRawi`, `NounsGarhOrder`, `RawiFawaaed`: Pernyataan *Jarḥ wa Ta‘dīl*, *Ikhtilāṭ*, *Tadlīs*, dan *Irsāl*.
  - `HadithScientestsJudge` & `HadithScJudgeSays`: Hukum para imam ahli hadis atas hadis tertentu.
- **Tabel Pohon Tematik & Ulumul Hadis:**
  - `Subject` & `SubjectHit` (Pohon Tematik *al-Rabṭ al-Mauḍū‘ī*), `MutonDates` (*Tawārīkh al-Mutūn*), `HadithControversialTree` (*Mukhtalaf al-Ḥadīts*), `HadithNaskhTree` (*al-Nāsikh wa al-Mansūkh*), `HadithExpressionsTree` (*Muṣṭalaḥ al-Ḥadīts*).

### B. Protokol URI Internal pada XSLT (`HadithXSLN.xsl`, `TakhreegXSL.xsl`, `PaneXSL.xsl`, `DialogsXSL.xsl`)
- `HadithNewChild-({@MainID}) ({@SayID})`: Membuka detail riwayat hadis hasil takhrij di jendela/tab anak.
- `HadithNewCompare-({@MainID}) ({@SayID})`: Membuka layar perbandingan redaksi (*Muqāranat al-Mutūn*) antara hadis aktif dan hadis pembanding.
- `ServiceBookNewChild-({@MainID}) ({@BookID}) ({@BookName}) ({@HadithNum}) ({@SayID})`: Membuka kutipan kitab syarah/takhrij/rijal pada juz dan halaman terkait.
- `AsaneedReportRawyID:{@ID}` & `RawiLink-{@ربط}`: Membuka kartu biografi perawi (*Tarjamat al-Rāwī*).
- `MMHits_HIDs{@HIDs}_MMID{@MMID}`: Menampilkan daftar kitab sumber untuk potongan tambahan (*Zawā’id*) ke-`MMID` pada *Al-Matn al-Mujamma‘*.

---

## 4. Spesifikasi Eksak 27 Aturan *Muqāranat al-Mutūn* (`WorkingGroups.pdf` hlm. 59–63)

Perbandingan dilakukan setelah menghapus `قائمة الكلمات المهملة` (seperti `ﷺ`, `رضي الله عنه`) dan menyamakan kata yang memiliki **akar (*jadzr*) dan pola (*wazan*) yang sama** meskipun berbeda *sawābiq* atau *lawāḥiq*:

### Kelompok I — `بلفظه` (Kecocokan 100% Akar & Wazan Kata)
1. **`بلفظه`**: Kedua matan cocok 100% tanpa tambahan maupun pengurangan kata yang berpengaruh pada makna.
2. **`بلفظه بزيادة في أوله...` / `بلفظه بزيادة في آخره...`**: Cocok 100% disertai klausa tambahan terukur di awal atau di akhir hadis.
3. **`بلفظه مطولاً`**: Matan ringkas 100% termuat di dalam matan panjang, dengan jumlah kata tambahan ≥ 30% yang tersebar di awal/tengah/akhir.
4. **`بلفظه مطولاً وزاد فيه...`**: Sama seperti aturan (3), tetapi tambahan katanya terlokalisasi sehingga dapat dikutip langsung.
5. **`بلفظه مختصراً`**: Matan asal yang panjang dibandingkan dengan matan target yang ringkas (selisih ≥ 30% kata) dan tambahan tidak terlokalisasi.
6. **`بلفظه مختصراً دون قوله...`**: Matan target lebih ringkas karena tidak memuat 1 atau 2 segmen kalimat tertentu dari matan asal (masing-masing segmen ≤ 15 kata).
7. **`مختصراً بلفظ...`**: Matan target sangat pendek (panjangnya ≤ 25% dari matan asal dan total katanya ≤ 15 kata), sehingga seluruh teks target dikutip penuh.

### Kelompok II — `بمثله` (Kecocokan ≥ 90% di Satu Pihak, ≥ 65% di Pihak Lain, Urutan Kata ≥ 50%)
8. **`بمثله`**: Terdapat perbedaan ringan (pergantian sinonim/derivasi kata), kecocokan ≥ 90% di satu pihak, ≥ 65% di pihak pembanding, dan sekuens urutan kata ≥ 50%.
9. **`بمثله دون قوله...`**: Memenuhi syarat `بمثله` (kecocokan ≥ 90%), tetapi matan target tidak memuat klausa tertentu dari matan asal.
10. **`بمثله مختصراً دون قوله...`**: Memenuhi syarat `بمثله` (kecocokan ≥ 90%) dengan pengurangan 1–2 segmen terukur (≤ 15 kata).
11. **`بمثله وقال فيه...`**: Memenuhi syarat `بمثله` disertai perbedaan/tambahan ungkapan yang dapat dikutip secara presisi.
12. **`بمثله مختصراً بلفظ...`**: Memenuhi syarat `بمثله` pada matan target yang sangat ringkas (≤ 15 kata).
13. **`بمثله مطولاً`**: Memenuhi syarat `بمثله` namun matan target lebih panjang ≥ 30% kata.
14. **`بمثله مطولاً وقال في أوله...` / `وقال في آخره...`**: Memenuhi syarat (13) dengan tambahan terukur di awal atau akhir.
15. **`بمثله مطولاً وقال فيه...`**: Memenuhi syarat (13) dengan tambahan terukur di tengah matan.
16. **`بمثله موقوفاً`**: Memenuhi syarat `بمثله`, tetapi riwayat pembanding berstatus *mauqūf* (perkataan sahabat).

### Kelompok III — `بنحوه` (Urutan Kata المتطابق ≥ 40%, Jarak Renggang المتباعد ≤ 50%)
17. **`بنحوه`**: Terdapat variasi redaksi ringan dengan sekuens kata yang berurutan ≥ 40% dan jarak renggang ≤ 50% (hanya mencatat perbedaan pada matan target).
18. **`بنحوه مطولاً`**: Memenuhi syarat `بنحوه` dengan matan target lebih panjang ≥ 30%.
19. **`بنحوه مختصراً`**: Memenuhi syarat `بنحوه` dengan matan asal lebih panjang ≥ 30%.
20. **`بنحوه مختصراً بلفظ...`**: Memenuhi syarat `بنحوه` dengan panjang target ≤ 25% dari asal dan ≤ 15 kata.
21. **`بنحوه وقال فيه...`**: Memenuhi syarat `بنحوه` dengan perbedaan klausa di tengah yang terukur.
22. **`بنحوه وقال في أوله...`**: Memenuhi syarat `بنحوه` dengan perbedaan klausa di awal.
23. **`بنحوه وقال في آخره...`**: Memenuhi syarat `بنحوه` dengan perbedaan klausa di akhir.

### Kelompok IV — `بمعناه` & Riwayat Tanpa Lafaz Terkait (Kecocokan ≥ 20%, Urutan ≥ 30%)
24. **`بمعناه`**: Terjadi perbedaan kata, tambahan/pengurangan, serta *taqdīm wa ta’khīr* (pergeseran posisi kata), namun kecocokan akar kata ≥ 20% dan urutan ≥ 30%.
25. **`بمعناه مختصراً`**: Memenuhi syarat `بمعناه` dengan matan target lebih ringkas.
26. **`بمعناه مطولاً`**: Memenuhi syarat `بمعناه` dengan matan target lebih panjang.
27. **`بمعناه مختصراً بلفظ...` / `من غير ذكر هذا اللفظ`**: Memenuhi syarat `بمعناه` dengan target ≤ 15 kata (`بمعناه مختصراً بلفظ...`), atau riwayat pembanding memuat kisah hadis yang sama namun memotong bagian lafaz yang sedang diperbandingkan (`من غير ذكر هذا اللفظ`).
