# WEBSITE REVIEWER READINESS AUDIT — OpenTurath

Tanggal: 7 Oktober 2026 · Tujuan: reviewer eksternal memahami nilai riset, kemampuan nyata, dan bukti OpenTurath dalam 30–90 detik.

## Kesimpulan

Website V6 memiliki identitas ilmiah, katalog, alur telaah sumber, halaman kebijakan, dan arsip perbandingan yang transparan. Tetapi pembuktian sebagai infrastruktur riset belum memadai. Hambatan terpenting adalah bukti retrieval yang dapat diperiksa, rekonsiliasi angka corpus, demonstrasi aplikasi nyata, dokumentasi penggunaan Claude, dan catatan penggunaan oleh ahli.

**Skor editorial kesiapan folder V6: 42/100.** Ini penilaian audit website, bukan probabilitas diterima program Anthropic, skor akurasi AI, atau hasil pengujian pengguna. Situs publik diaudit terpisah karena berbeda dari folder ini.

| Dimensi | Maksimum | Nilai | Dasar |
|---|---:|---:|---|
| Kejelasan produk dan posisi | 10 | 7 | Bidang ilmiah jelas; infrastruktur riset dan output konkret belum segera terbaca |
| Penjelasan masalah peneliti | 10 | 6 | Alur sumber ada, biaya pencarian dan kegagalan sitasi kurang dijelaskan |
| Filosofi sumber dan batas klaim | 10 | 8 | Sumber dan guru ditekankan; arsip jujur menyatakan belum terverifikasi |
| Bukti produk dan demo | 15 | 4 | Ada binary APK dan arsip; tidak ada demonstrasi aplikasi nyata pada homepage |
| Evaluasi dan reproduksibilitas | 15 | 3 | Satu pertanyaan, enam jawaban; belum ada ground truth dan skor terverifikasi |
| Corpus dan provenance | 10 | 5 | Metadata tersedia, tetapi dua snapshot berbeda dan indeks aktif belum diaudit |
| Claude dan arsitektur | 10 | 0 | Integrasi/eksperimen Claude belum dibuktikan dalam sumber yang diperiksa |
| Ahli, tim, dan traction | 10 | 2 | Kontak ada; identitas pembuat dan penggunaan ahli belum terdokumentasi |
| Kualitas teknis dan akses | 10 | 7 | Build, tes, tautan lokal dan layout lulus; verifikasi produksi tidak setara tes lokal |
| **Total** | **100** | **42** | |

## Lingkup dan batas bukti

Objek utama: `/Users/apple/Downloads/openturath-website 6`, HEAD `5a5fe16`. Pemeriksaan pendukung: kode dan metadata `/Users/apple/Downloads/ramadhan/openturath_ai`, serta konten proof pada salinan `/Users/apple/Downloads/ramadhan/website`. Salinan terakhir bukan objek pengganti folder V6.

Website asli tidak diubah. Build dan tes dijalankan pada salinan sementara yang terpisah. Sebelum audit, `docs/BUILD_REPORT.json` pada folder asli sudah berstatus modified; perubahan tersebut bukan hasil audit ini. Riwayat desain terdahulu digunakan untuk menjaga arah V6, sedangkan temuan factual di bawah diperiksa kembali.

Situs produksi diperiksa melalui Chrome. Fetch teks dan klien HTTP awal mendapat penolakan 403; browser kemudian dapat membuka situs dengan HTTP 200. Penolakan awal **tidak membuktikan situs down**. Browser CUA tidak berhasil merespons sehingga pemeriksaan dilakukan melalui Playwright pada Chrome terpasang, dengan profil terpisah.

Definisi status: **PASS** = requirement yang disebut dibuktikan dalam lingkup; **WEAK** = ada tetapi belum cukup; **MISSING** = belum ditemukan pada website/kode yang diperiksa; **UNVERIFIED** = klaim belum mempunyai bukti yang memadai. Tidak ditemukannya dokumen bukan bukti bahwa kegiatan tersebut tidak pernah dilakukan.

## Temuan utama

### P0-01 — Hero belum cukup menjelaskan produk dan diferensiasinya

English hero folder V6: “Knowledge. Within reach.” Penjelasannya menyebut penelaahan ribuan karya dan verifikasi teks Arab, jilid, serta halaman. Ini menyampaikan identitas ilmiah, tetapi belum menjawab: apa yang dilakukan aplikasi, masalah mahal apa yang dipecahkan, dan bagaimana peneliti memeriksa hasilnya.

Pada viewport desktop 1440 dan mobile 390, gambar buku mengisi bagian besar layar pertama. Gambar itu sesuai identitas, tetapi bukan bukti produk. Reviewer belum melihat antarmuka pertanyaan → ibarah → kitab/pengarang → lokasi → sumber primer. Navigasi utama berisi Library, How it works, Membership, Adab; Research hanya ada melalui arsip/footer. Jangan menghapus arah V6: perbaiki penjelasan, akses bukti, dan konten di dalam struktur yang sama.

Rujukan: [hero](</Users/apple/Downloads/openturath-website 6/src/home.mjs:11>), [English copy](</Users/apple/Downloads/openturath-website 6/src/copy.mjs:265>), [navigasi](</Users/apple/Downloads/openturath-website 6/src/render.mjs:15>). Screenshot: `evidence/home-en-1440.png`, `evidence/home-en-390.png`.

### P0-02 — Research sudah ada; statusnya arsip, belum benchmark

`/en/research/`, `/en/research/q001/`, dan `/en/research/methodology/` tersedia. Q001 memuat **1 pertanyaan dan 6 jawaban** dari enam produk, bukan enam pertanyaan atau benchmark multi-tugas. Semua run bertanda `unreviewed`; tanggal uji null. Versi model, konfigurasi, paket, dan kondisi uji tidak tercatat. OpenTurath tidak memiliki URL percakapan sumber pada run ini.

**10/10 record kutipan berstatus `not-reviewed`**. Pada semuanya, edisi, halaman cetak/PDF terverifikasi, URL sumber, teks sumber pembanding, penelaah, dan tanggal pemeriksaan belum tersedia. Tujuh dimensi review ditampilkan, tetapi belum dinilai. Hash keenam jawaban valid; hash membuktikan integritas arsip, bukan kesahihan isi.

Ini bukan bukti jawaban salah. Ini berarti akurasi belum dapat dinyatakan berdasarkan paket bukti tersebut. Situs sudah mengambil keputusan yang benar dengan tidak memasang persentase akurasi atau klaim keunggulan umum. Pertahankan kejujuran itu dan lengkapi bukti. Jangan mengubah “ten matches” historis menjadi 100% akurat tanpa record pemeriksaan.

Rujukan: [data evaluasi](</Users/apple/Downloads/openturath-website 6/content/evaluation.json>), [data kutipan](</Users/apple/Downloads/openturath-website 6/content/evidence.json>), [metodologi](</Users/apple/Downloads/openturath-website 6/src/articles.mjs:761>), [status review](</Users/apple/Downloads/openturath-website 6/src/copy.mjs:359>).

### P0-03 — “Open source” belum membuka naskah primer

Tombol “Open source” pada contoh homepage membuka dialog Bibliography yang menyatakan **Not yet reviewed**, dengan edisi **Not yet available**. Isinya kutipan arsip, locator Al-Umm j1 p30, tombol salin, dan tautan bibliografi. Tidak ada halaman scan/PDF atau teks sumber lengkap yang dapat dikolasi.

Dialog berfungsi teknis, tetapi belum memenuhi maksud “researcher inspects primary source”. Bukan screenshot aplikasi atau demo retrieval live. Label contoh arsip sudah ada; tambahkan akses primer yang nyata dan metadata edisi, atau sesuaikan label tombol agar tidak menjanjikan akses yang belum disediakan. Verifikasi lafaz, atribusi, dan konteks harus mendahului pengangkatan contoh sebagai bukti hasil.

Rujukan: [dialog](</Users/apple/Downloads/openturath-website 6/src/pages.mjs:14>), [contoh editorial](</Users/apple/Downloads/openturath-website 6/src/method.mjs:5>). Screenshot: `evidence/source-dialog-en.png`.

### P0-04 — Skala corpus belum mempunyai definisi hitung yang dapat diaudit

Agregat website: 20 disiplin aktif, 21 profil termasuk 1 dalam persiapan, 5.370 kitab, 11.901+ jilid, 4.182.803 halaman, 1.148.410.539 kata, dan 2.876 partisi. Agregat tersebut dihitung konsisten dari `catalog.json` dan `metadata_modul_lengkap.json`.

Tetapi dua sumber metadata di repository **berbeda pada enam jumlah kitab**:

| Modul | `metadata_modul_lengkap.json` | `metadata_training_seluruh_ai.json` |
|---|---:|---:|
| Fikih Syafi’i | 103 | 87 |
| Hadits | 1.141 | 1.173 |
| Tarikh/Sirah | 499 | 345 |
| Fikih Muqaran | 189 | 61 |
| Syarah Hadits | 202 | 172 |
| Musthalah Hadits | 393 | 165 |

Validator mengambil jumlah kitab dari sumber pertama dan partisi dari sumber kedua; ia tidak mengecek kesamaan jumlah kitab antarkedua sumber. Karena itu build lulus walaupun perbedaan ini ada.

Katalog Syafi’i aplikasi juga berisi **87 entri**, dengan 85 judul string unik. Sebanyak 84 entri mempunyai jumlah halaman yang bisa langsung dibaca sebagai integer, dengan subtotal 170.816; tiga entri tidak mempunyai nilai integer pada field tersebut. Subtotal ini **bukan angka pengganti** 170.391: satuan, duplikasi, edisi, dan entri gabungan perlu diaudit terlebih dahulu. Demikian juga 85 judul string bukan jumlah karya unik yang sudah diverifikasi.

Angka 103, 400+, 170.391, 71.627.898 kata, dan rentang 150–1338 H mempunyai sumber metadata internal; statusnya belum menjadi hitungan corpus terverifikasi sampai definisi unit dan selisih 103/87 diselesaikan. Belum ada bukti runtime bahwa seluruh partisi dan teks dapat ditelusuri. Jumlah per-modul juga belum dibuktikan bebas overlap.

Rujukan: [metadata modul](</Users/apple/Downloads/openturath-website 6/content/metadata/metadata_modul_lengkap.json:2>), [metadata training](</Users/apple/Downloads/openturath-website 6/content/metadata/metadata_training_seluruh_ai.json:2>), [validator](</Users/apple/Downloads/openturath-website 6/src/metadata.mjs:53>), [katalog aplikasi](</Users/apple/Downloads/ramadhan/openturath_ai/assets/data/01_KATALOG_FIKIH_SYAFII.json>).

### P0-05 — Hubungan Claude dengan produk belum dibuktikan

Pencarian pada source website, `openturath_ai/lib`, `openturath_ai/functions/src`, dependencies Functions, dan source terkait ecosystem yang diperiksa tidak menemukan adapter atau panggilan Claude/Anthropic. Terms dan Privacy website secara eksplisit menyebut **Google NotebookLM** untuk percakapan. Backend `askAgent` menggunakan Notebook bridge; jalur tersebut berstatus prototype dan dibatasi test UID dalam kode.

Dokumen `ARCHITECTURE.md` lama menyebut aplikasi akses ke NotebookLM. Dokumen itu sendiri tidak dijadikan satu-satunya bukti: kode yang lebih baru menunjukkan adanya jalur native/prototype, tetapi tetap belum menunjukkan Claude. Kurasi corpus, akses, katalog, dan alur ilmiah mempunyai nilai nyata; website perlu menjelaskan kontribusi OpenTurath sendiri secara tepat.

**[NEEDS VERIFICATION]** Claude bisa saja digunakan untuk pemrosesan corpus di luar repository yang diperiksa. Bukti yang diperlukan: lokasi pipeline, model dan tanggal, satu contoh input/output tersanitasi, cakupan tugas, serta catatan pemakaian agregat. Pisahkan penggunaan offline, eksperimen, integrasi runtime, dan rencana. Jangan menulis “Claude powers our retrieval” hanya untuk mencocokkan aplikasi startup.

Rujukan: [Terms tentang NotebookLM](</Users/apple/Downloads/openturath-website 6/src/articles.mjs:207>), [Privacy](</Users/apple/Downloads/openturath-website 6/src/articles.mjs:362>), [backend prototype](</Users/apple/Downloads/ramadhan/openturath_ai/functions/src/index.ts:357>), [batas prototype](</Users/apple/Downloads/ramadhan/openturath_ai/functions/src/native_chat.ts:60>).

### P0-06 — Expert use, pembuat, dan kebutuhan skala belum terlihat

About menjelaskan penggunaan dan dukungan, tetapi pembuat masih “Pengelola OpenTurath”. Tidak ada profil founder, tahap proyek yang jelas, catatan pilot ahli, tugas yang dicoba, durasi, frekuensi penggunaan, atau feedback yang bisa dipublikasikan. Kontak Gmail tersedia; domain email perusahaan belum digunakan. Gmail sendiri tidak membuktikan proyek tidak sah.

Brief founder menyatakan early-stage dan belum menerima external funding. Itu informasi yang diberikan pengguna, bukan hasil audit keuangan. Jangan menambahkan status badan hukum, universitas, endorsement, pengguna, atau revenue tanpa bukti.

Belum ada pemetaan workload Claude: dokumen yang diproses, ekstraksi, evaluasi, token/job, kapasitas saat ini, dan target throughput. Klaim “API capacity would unlock scale” perlu dihubungkan ke tugas dan bottleneck nyata, bukan sekadar ukuran katalog.

Rujukan: [About](</Users/apple/Downloads/openturath-website 6/src/articles.mjs:85>), [konfigurasi operator](</Users/apple/Downloads/openturath-website 6/site.config.json:5>).

## Matriks requirement

| Requirement utama brief | Status | Penilaian |
|---|---|---|
| 0. Tanpa fabrikasi | WEAK | Tidak ada skor akurasi palsu; angka kitab perlu direkonsiliasi |
| 1. Framing infrastruktur riset | WEAK | Bidang ilmiah jelas, posisi infrastruktur belum eksplisit |
| 2. Masalah reliabilitas AI | WEAK | Pedoman ada, risiko salah sumber/atribusi/konteks belum ditonjolkan |
| 3. Rasa sakit pencarian peneliti | WEAK | Langkah telaah ada; friksi pencarian lintas jilid/edisi belum konkret |
| 4. Kemampuan dan status | WEAK | Profil aktif/persiapan ada; available/development/planned belum sistematis |
| 5. Claude nyata dan spesifik | UNVERIFIED | Tidak ada bukti pada sumber yang diperiksa |
| 6. Akurasi sebagai konsep utama | WEAK | Verifikasi ditekankan; belum ada evaluasi terukur |
| 7. Research/benchmark | WEAK | Halaman ada, baru arsip satu pertanyaan |
| 8. Validasi ahli | UNVERIFIED | Record pilot dan izin publikasi belum ditemukan |
| 9. Corpus scale | UNVERIFIED | Agregat metadata ada; unit, overlap, selisih dan indeks aktif belum selesai |
| 10. Narasi homepage | WEAK | Urutan hero → angka → metode → katalog → arsip; problem/demo/bukti masih kurang |
| 11. Supporting pages | WEAK | About, Research, How it works, Privacy, Terms, Contact ada; technical architecture/demo kurang |
| 12. Kredibilitas reviewer | WEAK | Kontak/kebijakan baik; pembuat dan bukti kinerja tidak jelas |
| 13. Konsistensi aplikasi startup | UNVERIFIED | Ringkasan aplikasi menyebut Claude; bukti repository belum mendukung |
| 14. Pertimbangan startup reviewer | WEAK | Corpus ditampilkan, integrasi/traction belum dibuktikan; tidak menebak proses privat |
| 15. Traction yang nyata | UNVERIFIED | Artefak APK ada; penggunaan berulang/ahli belum terukur |
| 16. Beban komputasi | MISSING | Belum ada workload dan bottleneck yang terdokumentasi di website |
| 17. Identitas desain | PASS | Ilmiah, netral, tipografi dominan; perubahan substansi cukup dalam V6 |
| 18. Bahasa Inggris | WEAK | Shell dan kebijakan tersedia; pertanyaan/jawaban Q001 tetap Indonesia |
| 19. Kualitas teknis | WEAK | Lokal lulus; keterbatasan produksi dijelaskan pada lampiran QA |
| 20. Tidak berlebihan tentang Anthropic | PASS | Tidak ada promosi Claude berulang; peran riil masih perlu dijelaskan |
| 22. Pesan diferensiasi utama | WEAK | Traceability tampak sebagai filosofi, belum hasil terverifikasi |

Workflow 21 dipenuhi untuk audit, inventaris klaim, prioritas, dan laporan. Implementasi website belum dijalankan karena permintaan saat ini adalah audit terlebih dahulu.

## Inventaris klaim

| Klaim | Evidence dan sumber | Aman dipublikasikan? | Verifikasi yang diperlukan |
|---|---|---|---|
| Berfokus pada telaah sumber Islam klasik/kontemporer | Homepage, katalog, aplikasi | Ya, sebagai fokus produk | Jangan menyamakannya dengan validasi akurasi |
| AI-native research infrastructure | Arah dalam brief; fitur parsial | Sebagai tujuan/arah, bukan kematangan yang sudah tercapai | Demo dan arsitektur teknis |
| Source first | Metode dan batas arsip | Ya, sebagai prinsip | Sediakan rantai sumber yang benar-benar bisa dibuka |
| 20 disiplin / 21 profil, 1 persiapan | Katalog dan test | Ya untuk snapshot katalog | Ketersediaan layanan runtime bukan dibuktikan oleh flag |
| 5.370 kitab, 11.901+ jilid, 4.182.803 halaman | Agregat metadata modul | Hanya sebagai angka snapshot berlabel; tahan klaim corpus terverifikasi | Manifest, unit, deduplikasi, konflik enam modul |
| 1.148.410.539 kata | Metadata internal | Kondisional | Definisi token/kata, script penghitung, versi dataset |
| 2.876 partisi terindeks | Snapshot training, partisi cocok dengan aplikasi | “Metadata mencatat partisi”; indeks runtime UNVERIFIED | Manifest ingest dan uji retrieval per partisi |
| Koleksi Syafi’i 103 kitab | Modul 103; training dan katalog 87 | Tahan klaim tanpa kualifikasi | Rekonsiliasi karya/edisi/entri/versi |
| Corpus Syafi’i 400+, 170.391 halaman, 71.627.898 kata | Dua snapshot | Kondisional sebagai metadata | Penghitungan sumber dan audit data gabungan |
| Retrieval lexical + semantic milik OpenTurath | Tidak ditemukan bukti custom passage index pada aplikasi yang diperiksa | Belum | Kode/index/log query; bedakan mesin pihak ketiga |
| Normalisasi/search Arab | `CanonicalLibraryService`, `ArabicUtils`, search katalog website | Ya, terbatas pencarian katalog | Jangan klaim full-text corpus berdasarkan search judul |
| Native citation data | `AnswerCitation`, NotebookChatReply, backend prototype | Ya sebagai implementasi/prototype lokal | Bukti runtime dan akurasi sitasi terpisah |
| Akurasi/keunggulan model | Q001 belum dinilai | Tidak | Dataset, ground truth, rubric, runs, reviewer |
| Sepuluh kutipan cocok | Pernyataan review historis; record tidak disertakan | Tidak sebagai hasil terverifikasi | Kolasi setiap kutipan |
| Claude untuk processing/reasoning | Ringkasan brief; belum ada bukti teknis | Belum | Pipeline/model/tanggal/output/log penggunaan |
| Diuji/digunakan ahli | Informasi dalam brief tanpa catatan rinci | Tahan sampai konteks dikonfirmasi | Peran, tugas, durasi, feedback, izin |
| Menghemat jam menjadi menit | Tujuan, tidak ada pengukuran | Sebagai tujuan; tidak sebagai hasil terukur | Baseline dan waktu kerja tugas yang sebanding |
| APK Android tersedia | File 62.682.302 bytes dan hash cocok konfigurasi | Ya sebagai artefak lokal versi 1.0.51 | Instalasi, signatur dan layanan aktual belum diuji |
| Harga spesialis Rp50.000/299.000/499.000 | Config website cocok kode `ProductPricing` | Ya untuk penawaran snapshot | Checkout produksi terpisah; Tahawwulat punya tarif berbeda |
| Early-stage, tanpa external funding | Pernyataan founder pada brief | Ya dengan persetujuan editorial founder | Jangan menambahkan bentuk badan hukum/funding detail |
| Email resmi | Config dan Contact: Gmail | Ya | Email domain jika sudah benar-benar disiapkan |
| User count, revenue, universitas, endorsement | Belum ditemukan bukti | Tidak | Catatan agregat dan izin; jangan mengarang |

## Delapan sasaran evaluasi dari brief

Exact passage, book identification, attribution, reference location, fabricated citation rate, semantic retrieval, context preservation, dan position differentiation semuanya **UNVERIFIED sebagai hasil benchmark**. Adanya kutipan/locator di arsip membuktikan output tersimpan, bukan keberhasilan yang telah diberi skor. Tujuh dimensi review website membantu membentuk kerangka awal, tetapi tidak menggantikan label ground truth dan rubric yang dapat dijalankan ulang.

## Urutan perbaikan

### P0 — sebelum mengandalkan website untuk review startup

1. **Rekonsiliasi arsitektur dan Claude.** Tentukan apa yang dikerjakan OpenTurath, apa yang dikerjakan NotebookLM, dan apa yang benar-benar menggunakan Claude. Jika Claude dipakai offline, tampilkan penggunaan offline; jika baru direncanakan, label Planned.
2. **Selesaikan satu contoh sumber end-to-end.** Pertanyaan nyata, output aplikasi nyata, ibarah lengkap beserta konteks, edisi, pengarang, jilid/halaman, scan/tautan legal, penelaah dan tanggal. Jangan membuat screenshot tiruan. Satu contoh membuktikan workflow, bukan aggregate accuracy.
3. **Rekonsiliasi corpus.** Pilih canonical manifest, definisikan work/edition/file/volume/page, bedakan koleksi/ingested/indexed, cek overlap, dan jelaskan enam selisih kitab. Jangan hanya mengubah 103 menjadi 87 tanpa menelusuri dasar hitung.
4. **Perjelas hero dan dekatkan Research.** Tambahkan kalimat output konkret serta masalah rujukan. Arah editorial yang aman: membantu peneliti menemukan dan menelaah ibarah dengan jejak ke sumber; pengukuran penghematan waktu menunggu bukti.
5. **Jadikan Research paket bukti.** Pertahankan Q001 sebagai arsip historis. Tambahkan dataset dan metodologi evaluasi baru yang nyata: ground truth, rubric, kondisi run, versi model, tanggal, hasil, kegagalan dan keterbatasan. Jika belum ada hasil, katakan evaluasi sedang disiapkan; jangan memasang grafik palsu.
6. **Tampilkan tahap proyek dan pembuat.** Isi About dengan identitas yang disetujui, misi, scope saat ini, serta tahap early-stage. Masukkan expert-use hanya setelah konteks dan izin jelas.
7. **Pastikan checkout/download tidak berlawanan dengan produk.** Website V6 mencantumkan Android 8+ dan APK 1.0.51, sedangkan source aplikasi saat audit 1.0.63+64 dengan minSdk24. APK lama boleh tetap menjadi release publik jika memang keputusan pengelola; jangan menganggap source terbaru sudah dirilis.

P0-1, P0-2, P0-3, P0-5, dan bagian expert-use pada P0-6 mempunyai dependensi bukti. Penyuntingan kata saja tidak menyelesaikannya.

### P1 — memperkuat kredibilitas

- Tambahkan halaman technology atau tingkatkan How it works dengan dua diagram yang diberi status: jalur saat ini dan jalur pengembangan. Pisahkan corpus → retrieval → reasoning → pemeriksaan pengguna.
- Buat ringkasan English Q001 di samping transkrip Indonesia; pertahankan arsip asli dan beri label terjemahan/editorial.
- Publikasikan pilot ahli yang disetujui, termasuk ruang lingkup dan keterbatasan; tanpa klaim “validated by leading scholars”.
- Jelaskan workload Claude lewat tugas konkret dan kapasitas yang tercatat; angka target harus berlabel target.
- Sinkronkan dokumentasi source: README masih menyebut Rp49.000, padahal config/FAQ Rp50.000. `claims.json` kosong; isi registry klaim dengan provenance dan status review.
- Jika dibutuhkan, siapkan email domain dan tampilkan kontak pada footer. Jangan mencantumkan alamat yang belum berfungsi.

### P2 — pengembangan bukti jangka panjang

- Versioned corpus manifest, audit ingest, dan halaman cakupan per koleksi.
- Benchmark lintas disiplin dengan holdout, uji gagal/abstention, serta pemeriksaan ahli.
- Pengukuran pencarian manual versus aplikasi pada tugas nyata; publikasi hasil tanpa cherry-picking.
- Statistik usage/retention agregat dan replikasi evaluasi, jika pengumpulan datanya benar-benar tersedia.

## Bukti yang masih perlu diberikan founder

Permintaan bukti sudah dikirim selama audit. Sampai laporan dibuat, bagian yang belum terkonfirmasi tetap **[NEEDS VERIFICATION]**:

1. Claude: lokasi implementasi/processing, model, tanggal, contoh hasil, penggunaan agregat dan bottleneck kapasitas. Jangan kirim API key atau log berisi data sensitif.
2. Expert testing: jumlah peserta, bidang relevan, demo atau riset nyata, tugas, durasi, umpan balik asli, dan izin identitas/kutipan.
3. Corpus: manifest sumber, definisi satuan, script hitung, versi snapshot, basis selisih 103/87 dan lima modul lain, serta bukti ingest/index aktif.
4. Evaluasi: dataset, ground truth dengan edisi, rubric yang digunakan, run asli, konfigurasi, tanggal, reviewer, hasil dan kegagalan.
5. Produk: rekaman/screenshot asli satu tugas dengan akses sumber sampai selesai; release yang memang tersedia untuk pengunjung.
6. Identitas: profil founder/tim yang boleh dipublikasikan dan tahap proyek. Dokumen aplikasi startup sebenarnya belum diberikan; konsistensi baru dibandingkan dengan ringkasan dalam brief.

## Jawaban setelah 60 detik

**Pada folder V6:** reviewer kemungkinan memahami bahwa OpenTurath menyediakan akses ke khazanah Islam melalui AI, banyak disiplin, dan mendorong pembacaan rujukan serta bimbingan guru. Ia melihat angka corpus dan arah source-first. Ini merupakan pembacaan editorial atas tampilan, bukan hasil studi stopwatch pada reviewer nyata.

Pertanyaan yang masih mengurangi keyakinan: siapa pembuatnya; bagaimana retrieval bekerja; apa yang telah dibangun sendiri; apakah corpus unik dan benar-benar indexed; apakah kutipan cocok dengan edisi; siapa ahli yang menggunakannya; apakah Claude benar-benar dipakai; dan pekerjaan apa yang akan berkembang dengan API capacity.

Website saat ini memberikan alasan untuk tertarik, tetapi belum cukup bukti untuk mempercayai klaim infrastruktur riset yang telah teruji. Prioritasnya melengkapi rantai bukti sambil mempertahankan desain V6.

## QA lokal saat audit

- Preview build dan release build: selesai, keduanya menghasilkan 172 HTML page, termasuk language entry.
- Validator: 171 halaman localized, 9.705 referensi tautan/aset lokal, semua terjemahan UI, 6 hash arsip dan 10 record kutipan diperiksa; tidak ada error.
- Unit tests: 23 Node tests dan 13 Python tests lulus, tanpa fail/skip pada log yang diperiksa.
- Browser baru: 75 kombinasi halaman/locale/viewport. ID/EN/AR, desktop 1440, mobile 390 pada 12 route per bahasa, plus homepage 320. Semua halaman mempunyai satu h1; tidak ada overflow horizontal, broken image pada pemeriksaan setelah load, atau page JavaScript error.
- Interaksi: hero menuju Library dan Method, dialog sumber/Escape/focus, dark-theme persistence, FAQ, menu Arab mobile, search Arab berharakat (1 hasil), filter hadith (3 hasil), tab perbandingan mobile, dan pergantian bahasa berhasil.
- Screenshot yang benar-benar dilihat: hero ID desktop/mobile; hero EN desktop; Research EN; hero AR mobile; hero produksi EN; Research produksi EN; dialog sumber produksi; Downloads produksi. Peninjauan ini bukan pemeriksaan seluruh halaman di semua tema.
- Integritas APK lokal: 62.682.302 bytes; SHA-256 `d217a551514f5efa7ca852209dbd8dd412de6f01f0776a1e52db6c57950c12f5`, cocok konfigurasi. Instalasi perangkat, signing certificate, transaksi, dan backend production tidak diuji.
- Preservation: 388 berkas non-Git pada folder asli sebelum/sesudah identik secara SHA-256; tidak ada berkas ditambah, dihapus, atau dimodifikasi oleh audit.

Seluruh pemeriksaan ini memberikan confidence teknis pada artefak website, **bukan bukti kebenaran ilmiah, jumlah pengguna, atau sukses integrasi Claude**. Validator release saat ini menerima kutipan yang belum direview; successful build tidak berarti klaim siap dipublikasikan.

Full accessibility/axe pada sesi ini, pembacaan screen reader, Safari/iOS/Android, physical collation, produksi API laporan, produksi checkout, penerimaan instalasi APK, dan production Core Web Vitals belum diuji. Log `docs/BROWSER_QA.json` lama di source tidak dipakai sebagai hasil baru. Preview memakai reduced motion untuk pengukuran stabil; animasi penuh tidak diuji ulang secara menyeluruh.

## Perbedaan yang sudah terlihat pada situs publik

Pada [homepage produksi](https://openturath.id/en/) kalimat pendukung sudah lebih konkret: pengunjung diminta mengajukan pertanyaan, lalu membaca jawaban beserta ibarah Arab, jilid, dan halaman. CTA pertama berubah menjadi Download the app, kedua Explore the library. Ini kemajuan kejelasan dibanding folder V6.

Namun [Downloads produksi](https://openturath.id/en/download/) menampilkan Android, macOS, dan Windows sebagai **Coming Soon**, tanpa unduhan aktif yang terlihat. Android minimum 7.0+, sedangkan folder V6 menampilkan APK Android 1.0.51 dan minimum 8.0+. Reviewer yang mengikuti CTA utama belum bisa langsung mencoba produk. Ini temuan P0 tersendiri pada produksi: sediakan jalur mencoba yang benar-benar tersedia, misalnya demo nyata atau proses akses yang jelas; jangan mengaktifkan binary yang belum layak hanya untuk mengisi tombol.

[Research produksi](https://openturath.id/en/research/) masih menampilkan Q001 satu pertanyaan/enam produk tanpa skor akurasi. Dialog sumber produksi masih **Not yet reviewed** dengan edisi belum tersedia. Jadi penjelasan hero yang membaik belum mengatasi celah bukti.

[Privacy tanpa prefix](https://openturath.id/privacy) dan [Terms tanpa prefix](https://openturath.id/terms) berhasil dengan HTTP 200 di browser. Artefak source yang disajikan melalui server statis sederhana tidak mempunyai alias tersebut (404), sementara `/en/privacy/` dan `/en/terms/` lokal tersedia. Jangan menganggap perilaku server lokal sebagai bukti bahwa alias produksi rusak.

**Setelah 60 detik pada produksi:** reviewer lebih mungkin memahami alur pertanyaan menuju ibarah dan koordinat kitab, beserta skala koleksi dan orientasi ilmiahnya. Tetapi belum melihat aplikasi nyata yang dapat langsung dicoba, hasil yang sudah dikolasi, penggunaan oleh ahli, atau posisi Claude yang dapat diperiksa. Keyakinan tentang klaim startup tetap terbatas. Skor 42/100 di atas secara eksplisit untuk folder V6; situs publik tidak disamakan secara byte dengan folder tersebut.


## QA produksi tambahan

18 navigasi browser diperiksa: homepage desktop/mobile EN, mobile AR, Research, Q001, Methodology, About, How it works, Privacy, Terms, Contact, Downloads, alias Privacy/Terms, robots.txt, dan dua route yang memang tidak tersedia. Enam belas navigasi menghasilkan HTTP 200; `/technology` dan route acak menghasilkan HTTP 404 dengan `noindex,nofollow`. Pada seluruh halaman HTML yang diperiksa tidak ada overflow horizontal, dan ada satu h1. Tidak ditemukan page JavaScript error pada sesi ini. Ini bukan crawl semua tautan eksternal atau pengujian semua asset network.

robots.txt mengizinkan indexing dan menunjuk sitemap produksi. Halaman 200 yang diperiksa tidak memuat `noindex`; metadata canonical dan OpenGraph tersedia pada halaman localized. Sitemap belum diperiksa secara menyeluruh. Core Web Vitals produksi belum diukur. Contact menyatakan pengiriman formulir website dinonaktifkan dan menawarkan email serta unduh draft; tidak ada laporan sungguhan dikirim.

## Hasil yang disimpan dan perubahan

Audit ini menambahkan laporan, JSON bukti browser/preservasi, log verifikasi, dan screenshot ke folder laporan ini. Tidak ada perubahan website, aplikasi, backend, deployment, atau release. Semua perubahan laporan dibuatkan checkpoint Git.

- `evidence/browser-audit.json`: 75 pemeriksaan render lokal dan interaksi.
- `evidence/live-audit.json`: observasi halaman produksi; hanya header publik yang relevan disimpan.
- `evidence/preservation-check.json`: bukti folder asli tidak berubah.
- `evidence/build-preview.log`, `evidence/build-release.log`, `evidence/tests.log`: hasil verifikasi pada salinan sementara.
- `evidence/*.png`: screenshot lokal dan produksi.

Saat implementasi berikutnya, jangan menggabungkan begitu saja folder V6 dengan situs publik. Tetapkan checkout yang menjadi source produksi, gunakan salinan kerja sesuai keputusan terdahulu, pertahankan gaya V6, dan selesaikan dependensi bukti sebelum mempromosikan klaim.
