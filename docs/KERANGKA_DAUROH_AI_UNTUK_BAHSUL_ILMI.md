# Kerangka Dauroh: استخدام الذكاء الاصطناعي في مجال البحث العلمي

Dua hari, masing-masing 4 jam. Peserta awam, belum pernah memakai AI.
Disusun 1 November 2026 sebagai draf kerja; belum dipoles menjadi slide.

## Cara membaca dokumen ini

- **Satu benang merah:** AI membantu pada setiap tahap bahsul ilmi, tetapi *kebenaran selalu diperiksa ke kitab*. Kalimat ini diulang di awal tiap sesi.
- **Urutan hari:** Hari 1 membangun fondasi, lalu merancang penelitian (judul sampai kerangka). Hari 2 menjalankan penelitian (sumber sampai kritik) dan menyelesaikannya.
- **Bahasa:** sederhana. Istilah teknis hanya yang perlu, masing-masing dengan satu kalimat penjelasan.
- **Tiap sesi ditutup dengan praktik.** Peserta memakai satu topik penelitian milik sendiri dari awal sampai akhir, sehingga di akhir hari ke-2 mereka membawa pulang rancangan bahsul ilmi yang nyata.
- **Sumber materi dasar:** video Raymond Chin, "Bodoh AI ke Mahir Dalam 30 Menit (Part 1)". Saya hanya berhasil membaca judul, deskripsi, dan daftar bab video itu (transkripnya tidak tersedia), jadi pemetaan di bawah mengikuti bab-babnya: fundamental (LLM dan AI agent, model tertutup vs terbuka), prompting dan manajemen konteks, Skills, Projects, serta MCP dan connectors. Isi ucapannya belum saya periksa.

## Alur penelitian yang menjadi tulang punggung

Sebelas tahap. Slide alur ini ditampilkan di awal dan di tiap pergantian sesi, dengan tahap yang sedang dibahas disorot.

| # | Tahap | Hari / Sesi |
|---|---|---|
| 1 | Menemukan masalah dan judul | H1 · S5 |
| 2 | Rumusan masalah, tujuan, batasan | H1 · S5 |
| 3 | Kerangka bab | H1 · S6 |
| 4 | Mencari dan menyaring sumber | H2 · S7 |
| 5 | Membaca, mencatat, takhrij, muqaranah | H2 · S8 |
| 6 | Menulis draf | H2 · S9 |
| 7 | Memeriksa kutipan dan catatan kaki | H2 · S9 |
| 8 | Memperbaiki bahasa Arab | H2 · S10 |
| 9 | Dikritik: "dosen syadid" | H2 · S11 |
| 10 | Revisi, abstrak, daftar pustaka | H2 · S12 |
| 11 | Simulasi munaqasyah | H2 · S12 |

---

# HARI 1: Memahami AI, lalu merancang penelitian (4 jam)

## Sesi 1 · AI dari nol (20 menit)

**Tujuan:** peserta berhenti menganggap AI sebagai "sihir" atau "ulama digital".

1. **Judul dan tujuan dua hari.** Apa yang akan dibawa pulang: rancangan penelitian, daftar sumber, dan cara memeriksa hasil AI.
2. **Kenapa banyak orang merasa AI itu penipuan.** Biasanya karena pernah dijawab salah dengan nada yakin. Peserta diajak jujur menceritakan pengalaman mereka. (Sejalan dengan pembuka video: orang yang awalnya skeptis lalu belajar dari nol.)
3. **Apa itu AI, dengan kalimat sehari-hari.** Program yang belajar pola dari teks sangat banyak, lalu menebak kata berikutnya. Bukan otak, bukan mesin pencari.
4. **LLM dan AI agent.** LLM: yang menjawab. Agent: LLM yang diberi alat untuk bekerja beberapa langkah (mencari, membuka berkas, menulis). Cukup satu analogi: LLM seperti santri pintar yang hanya bisa bicara; agent seperti santri yang juga boleh membuka perpustakaan dan mencatat.
5. **Bedanya dengan Google.** Google menunjukkan di mana tulisan itu berada; AI *menyusun* jawaban baru. Karena itu AI bisa terdengar benar padahal keliru.

## Sesi 2 · Cara kerja dan bahayanya (30 menit)

**Tujuan:** peserta paham kenapa AI salah dan kenapa itu lebih berbahaya di ilmu syar'i.

6. **Halusinasi.** AI bisa mengarang kitab, pengarang, jilid, halaman, bahkan hadis. Tampilkan contoh nyata yang Anda uji sebelumnya.
7. **Mencampur mazhab, zaman, dan konteks.** Pendapat satu mazhab dinisbatkan ke mazhab lain; kutipan dipotong sehingga maknanya berubah.
8. **Kenapa lebih berat di bidang syar'i.** Kesalahan kecil menjadi penisbatan atau hukum yang keliru. Kaitkan dengan *tatsabbut* (memeriksa kabar).
9. **AI umum vs AI yang dibatasi pada sumber.** AI umum menjawab dari ingatan latihannya. AI berbasis sumber menjawab dari dokumen yang diberikan, jadi lebih mudah diperiksa, tetapi tetap bisa salah. (Dalam slide, sebut jenis ini sebagai "AI berbasis sumber"; tidak perlu menyebut nama produk Google di belakangnya, sesuai arahan Anda.)
10. **Aturan emas.** AI adalah *pembantu pencari*, bukan *sumber*. Tidak ada klaim tanpa rujukan yang sudah dibuka sendiri.
11. **Yang tidak boleh diserahkan ke AI:** menetapkan hukum, berfatwa, menilai sahih-tidaknya hadis, menyimpulkan tanpa melihat kitab.

## Istirahat (10 menit)

## Sesi 3 · Cara berbicara dengan AI: prompt dan konteks (40 menit)

**Tujuan:** peserta bisa menulis perintah yang menghasilkan jawaban berguna. (Pemetaan bab video: Prompting dan Context Management.)

12. **Prompt itu apa.** Perintah yang kita ketik. Kualitas jawaban sangat mengikuti kualitas perintah.
13. **Lima unsur perintah yang baik:** peran, tugas, konteks, batasan, bentuk jawaban. Contoh buruk dan baik berdampingan.
14. **Konteks itu seperti memori kerja.** AI hanya "tahu" apa yang ada di percakapan ini. Percakapan terlalu panjang membuatnya lupa awalnya. Solusi: ringkas, mulai percakapan baru, tempel ringkasan.
15. **Minta AI bertanya balik.** Kalimat kunci: "Sebelum menjawab, ajukan pertanyaan dulu sampai kamu paham." Ini fondasi tahap 1 dan 2 nanti.
16. **Minta rujukan dengan benar.** Nama kitab, pengarang, jilid, halaman, dan ibarah asli, lalu tandai bahwa *semuanya harus dicek*.
17. **Pertanyaan lanjutan sebagai alat uji.** "Dari mana ini?", "Apa pendapat yang berbeda?", "Tunjukkan ibarah Arabnya.", "Bagian mana yang kamu tidak yakin?"
18. **Praktik (10 menit).** Peserta memperbaiki satu perintah mentah menjadi perintah yang baik.

## Sesi 4 · Memilih dan menata alat (25 menit)

**Tujuan:** peserta tahu pilihan alat dan menata pekerjaan mereka agar tidak berantakan. (Pemetaan bab video: Closed vs Open Model, Skills, Projects, MCP dan Connectors.)

19. **Model tertutup vs terbuka.** Tertutup: dijalankan di server penyedia, biasanya lebih kuat, tetapi teks Anda dikirim ke sana. Terbuka: bisa dijalankan di laptop sendiri, teks tidak keluar, biasanya lebih sederhana kemampuannya. Kaitkan dengan naskah yang belum terbit.
20. **Privasi sebagai kebiasaan.** Jangan memasukkan data pribadi, nama jamaah, atau naskah rahasia ke alat yang belum dipahami kebijakannya. Baca pengaturan data sekali di awal.
21. **Projects: satu ruang kerja untuk satu penelitian.** Dokumen, instruksi tetap, dan riwayat tinggal di satu tempat, jadi tidak mengulang penjelasan setiap kali.
22. **Skills: instruksi tersimpan.** Menyimpan "cara kerja" yang sering dipakai sekali saja, misalnya format ringkasan kitab atau format takhrij. Ini akan menjadi "kotak perkakas" peserta.
23. **MCP dan connectors, sekilas.** Cara menyambungkan AI ke tempat penyimpanan berkas atau pengelola referensi agar bisa bekerja langsung dengan bahan Anda. Cukup perkenalan; bukan praktik.
24. **Peta alat untuk dua hari ini.** Satu slide: AI umum untuk berpikir dan menulis, AI berbasis sumber untuk menelusuri kitab, AI khusus bahasa Arab, AI pengkritik. Peserta tidak perlu menghafal nama produk.

## Istirahat (10 menit)

## Sesi 5 · Tahap 1 dan 2: dari kegelisahan menjadi judul dan rumusan masalah (50 menit)

**Tujuan:** setiap peserta pulang dengan satu judul, rumusan masalah, tujuan, dan batasan yang jelas.

25. **Kesalahan paling umum:** langsung menulis judul. Judul yang baik adalah *hasil* dari memahami masalah, bukan titik awal.
26. **Konsep AI pewawancara.** Berbeda dengan chatbot biasa: ia *bertanya dulu*. Contoh pertanyaan: apa yang mengganggu Anda, di bidang apa, untuk jenjang apa, bahasa penulisan, kitab apa yang sudah akrab, waktu yang tersedia, dosen pembimbing menginginkan apa.
27. **Apa yang dikumpulkan AI pewawancara:** bidang, masalah, ruang lingkup, jenis penelitian (kepustakaan, komparatif, analisis tematik, takhrij, dsb.), sumber utama yang mungkin, hasil akhir yang diinginkan.
28. **Dari jawaban menjadi pilihan judul.** AI menawarkan beberapa judul beserta alasan, cakupan, dan risikonya (terlalu luas, sudah banyak dibahas, sumber terlalu sedikit).
29. **Menguji judul.** Tiga pertanyaan: bisakah dijawab dengan sumber yang tersedia? Apa yang baru? Apakah batasannya jelas? AI membantu mempertajam.
30. **Rumusan masalah, tujuan, manfaat, batasan.** Disusun dari jawaban peserta, bukan dikarang AI. Peserta menyunting.
31. **Praktik (30 menit).** Peserta melakukan wawancara dengan AI, memilih satu judul, menulis rumusan masalah. Fasilitator berkeliling.

> **Catatan:** AI pewawancara ini adalah rancangan Anda. Di daftar AI aplikasi saat ini saya tidak menemukan yang sepadan, jadi untuk dauroh pertama bisa dijalankan dengan perintah yang sudah dirancang (lihat Lampiran A) di AI mana pun, lalu dipindahkan ke OpenTurath saat sudah siap.

## Sesi 6 · Tahap 3: dari rumusan menjadi kerangka bab (40 menit)

**Tujuan:** peserta memiliki kerangka bab dan subbab yang runtut.

32. **Kerangka adalah peta, bukan penjara.** Boleh berubah, tetapi harus ada.
33. **Kerangka disusun dari konteks.** AI memakai semua jawaban sesi 5: masalah, ruang lingkup, jenis penelitian, hasil akhir, aturan kampus atau pembimbing.
34. **Pola kerangka umum:** pendahuluan, landasan teori atau tinjauan pustaka, metode, pembahasan, penutup. Dibandingkan dengan pola kajian fikih atau tafsir yang biasanya lebih bertahap (definisi, dalil, pendapat, tarjih).
35. **Menguji kerangka.** Apakah tiap bab menjawab satu bagian dari rumusan masalah? Adakah bagian yang tumpang tindih atau loncat?
36. **Menghubungkan kerangka dengan sumber.** Tiap subbab diberi daftar sumber yang perlu dicari. Ini menjembatani ke hari ke-2.
37. **Praktik (25 menit).** Peserta menyusun dan memperbaiki kerangka bersama AI.

## Penutup Hari 1 (15 menit)

38. **Rekap lima pegangan:** AI itu pembantu; minta rujukan; periksa ke kitab; jaga data; tetap berguru.
39. **PR ringan:** membaca ulang kerangka, menandai tiga subbab yang paling butuh sumber.

---

# HARI 2: Menjalankan penelitian sampai selesai (4 jam)

## Sesi 7 · Tahap 4: mencari sumber kitab dan referensi (50 menit)

**Tujuan:** peserta tahu *di mana* mencari, *bagaimana* menyaring, dan *apa yang boleh* diambil.

40. **Sumber primer dan sekunder.** Kitab asli (turats) vs buku, skripsi, dan jurnal yang membahasnya. Skripsi hanya penunjuk jalan, bukan tempat mengutip.
41. **Perpustakaan digital kitab.** Contoh yang umum dipakai penuntut ilmu: Maktabah Syamilah (shamela.ws), Waqfeya, Turath.io, serta arsip seperti Archive.org dan HathiTrust. *Alamat dan kebijakan situs berubah; periksa kembali sebelum dicetak di slide.*
42. **Perpustakaan khusus bidang.** Contoh: Dorar.net untuk hadis, Islamweb untuk fatwa dan tafsir. *Periksa alamatnya sebelum dipakai.*
43. **Jurnal dan skripsi.** Google Scholar, portal jurnal nasional (Garuda, SINTA), dan basis data Arab berbayar bila tersedia di kampus. Cara memakai kata kunci dalam Arab dan Indonesia.
44. **Telegram dan komunitas berbagi kitab.** Memang praktis, tetapi mutunya tidak seragam: PDF hasil pindai tanpa tahqiq, edisi tidak jelas, nama berkas menyesatkan, dan masalah hak cipta. Yang diajarkan adalah *cara menilainya*, bukan daftar saluran.
45. **Cara menilai satu edisi kitab.** Penerbit, tahun, nomor cetakan, muhaqqiq, kelengkapan jilid, kualitas teks. Cocokkan dengan edisi yang dipakai kampus atau pembimbing.
46. **Adab mengambil sumber.** Hak cipta, tidak membagikan ulang karya berhak cipta, mencatat sumber unduhan, memakai edisi resmi bila ada.
47. **AI membantu mencari, bukan menggantikan.** AI memperluas kata kunci (sinonim istilah fikih), menyarankan kitab yang mungkin relevan, lalu *peserta membuka dan memeriksa sendiri*. Daftar yang tidak ditemukan di sumber nyata dicoret.
48. **Membuat daftar sumber berprioritas.** Wajib, penting, pelengkap. AI membantu menyusun, peserta menentukan.
49. **Praktik (20 menit).** Peserta mencari tiga sumber untuk satu subbab, menilai edisinya, dan mencatat rujukan lengkapnya.

## Sesi 8 · Tahap 5: membaca, mencatat, takhrij, dan muqaranah (35 menit)

**Tujuan:** peserta mempercepat pembacaan tanpa kehilangan ketelitian.

50. **Meringkas kitab tebal dengan terarah.** Minta ringkasan *per pertanyaan penelitian*, bukan ringkasan umum. Selalu minta nomor halaman asal.
51. **Menerjemahkan ibarah.** AI untuk draf kasar; peserta atau guru memeriksa istilah fikih dan nahwunya. Selalu simpan teks Arab di samping terjemahan.
52. **Kartu catatan.** Satu kutipan satu kartu: ibarah, terjemah, rujukan lengkap, catatan peserta. AI membantu merapikan; peserta menambah analisis.
53. **Takhrij dan pengecekan hadis.** AI menunjukkan arah (kitab apa yang mungkin memuatnya); keputusan derajat hadis tetap dari rujukan ahli hadis. Praktik: memeriksa satu hadis ke sumbernya.
54. **Muqaranah mazhab.** Tabel perbandingan pendapat dengan kolom dalil dan rujukan. Hati-hati: AI sering menukar mazhab; setiap sel tabel diperiksa.
55. **Mencari dan memahami istilah.** Menelusuri makna kata di kamus klasik, bukan hanya jawaban AI.
56. **Praktik (15 menit).** Satu kutipan, satu kartu catatan lengkap.

## Istirahat (10 menit)

## Sesi 9 · Tahap 6 dan 7: menulis draf dan memeriksa kutipan (30 menit)

**Tujuan:** peserta menulis dengan suara sendiri, bukan menyalin AI.

57. **Garis batas penulisan.** Gagasan dan analisis milik peserta. AI boleh membantu menyusun ulang, merapikan alur, memberi variasi kalimat.
58. **Menulis dari kartu catatan.** Peserta menyusun paragraf dari kartunya; AI mengusulkan kalimat penghubung.
59. **Parafrase dan kutipan langsung.** Kapan mengutip utuh, kapan memparafrase, dan cara mencantumkan rujukan.
60. **Catatan kaki (hamisy).** Format rujukan kitab: pengarang, judul, jilid, halaman, penerbit, tahun. AI membantu menyeragamkan format; isi rujukannya diperiksa manual.
61. **Pemeriksaan kutipan.** Bandingkan tiap kutipan dengan sumbernya. Contoh kesalahan khas AI: halaman tertukar, jilid tidak ada, kutipan dipotong.
62. **Mengakui penggunaan AI.** Cara menuliskannya secara jujur sesuai aturan kampus atau lembaga.
63. **Praktik (10 menit).** Satu paragraf lengkap dengan rujukan.

## Sesi 10 · Tahap 8: memperbaiki bahasa Arab (35 menit)

**Tujuan:** peserta bisa menemukan dan memperbaiki kesalahan bahasa Arab pada tulisannya, sambil belajar darinya.

64. **Kenapa tulisan Arab penuntut ilmu butuh pemeriksa.** Kesalahan i'rab, kesesuaian (mudzakkar-muannats, mufrad-jama'), huruf jar, kata kerja, dan gaya kalimat.
65. **Konsep AI koreksi bahasa Arab.** Tidak hanya memperbaiki, tetapi *menandai kesalahan, menyebut kaidahnya, lalu memberi beberapa pilihan kalimat yang lebih baik*, dengan perbedaan nuansa tiap pilihan.
66. **Cara membaca hasil koreksi.** Kesalahan nahwu (pasti), kesalahan sharaf, pilihan gaya (selera), kata yang lebih tepat. Peserta memilih, bukan menerima semuanya.
67. **Belajar dari kesalahan.** Catat tiga kesalahan yang paling sering muncul pada tulisan sendiri. Itulah bahan belajar pribadi.
68. **Batas AI dalam bahasa Arab.** AI lebih kuat pada Arab modern daripada Arab klasik; bisa keliru pada tulisan yang bercorak turats. Untuk naskah penting, tetap diperiksa guru nahwu. Jangan mengubah teks kutipan dari kitab.
69. **Praktik (15 menit).** Peserta mengoreksi satu paragraf Arab tulisannya dan memilih perbaikan yang diterima.

> **Catatan:** AI koreksi Arab yang Anda gambarkan belum ada di daftar AI aplikasi. Yang paling dekat adalah `nahwu_sharaf` (dengan sub-AI i'rab), yang berfungsi untuk belajar, bukan untuk menyunting naskah. Perlu dipastikan apakah memakai itu atau membuat AI baru.

## Istirahat (10 menit)

## Sesi 11 · Tahap 9: "dosen syadid" yang mengkritik penelitian (40 menit)

**Tujuan:** peserta menemukan kelemahan sendiri sebelum penguji menemukannya.

70. **Kenapa perlu dikritik sebelum diuji.** Penulis sulit melihat kekurangan tulisannya sendiri.
71. **Konsep AI dosen syadid.** Berperan sebagai dosen penguji yang keras tapi adil. Tugasnya: mencari *blind spot*, kontradiksi, lompatan logika, dalil yang tidak mendukung, klaim tanpa sumber, pembahasan yang tidak menjawab rumusan masalah.
72. **Jenis kritik yang diminta:** konsistensi antarbab, kesesuaian judul dan isi, kekuatan dalil, ada tidaknya pendapat lawan yang belum dibahas, kebaruan.
73. **Cara membaca kritik.** Pisahkan: kritik valid (perbaiki), kritik karena AI salah paham (jelaskan ulang), dan kritik yang membuka pertanyaan baru (pertimbangkan).
74. **Menjaga hati.** Kritik keras itu alat, bukan penilaian terhadap diri. Jangan menyerah atau menerima semua tanpa berpikir.
75. **Siklus revisi.** Kritik, revisi, kritik ulang. Berhenti setelah dua atau tiga putaran agar tidak terjebak.
76. **Praktik (20 menit).** Peserta menyerahkan satu bab (atau bagian) untuk dikritik dan mencatat tiga temuan terpenting.

> **Catatan:** seperti dua AI di atas, "dosen syadid" belum ada di daftar AI aplikasi saat ini. Perintahnya bisa disiapkan dahulu (Lampiran A).

## Sesi 12 · Tahap 10 dan 11: finishing dan simulasi munaqasyah (20 menit)

**Tujuan:** peserta menutup penelitian dengan rapi dan siap diuji.

77. **Abstrak.** AI membantu membuat abstrak dari isi yang sudah ditulis, dalam Indonesia, Inggris, dan Arab. Periksa angka, nama, dan klaim.
78. **Daftar pustaka dan daftar isi.** Menyeragamkan format; memeriksa bahwa semua yang dikutip ada di daftar.
79. **Simulasi munaqasyah.** AI berperan sebagai penguji dan mengajukan pertanyaan paling sulit; peserta berlatih menjawab. Berguna juga untuk menyiapkan presentasi.
80. **Peta lengkap sebelas tahap.** Peserta menandai tahap mana yang paling terbantu AI dan mana yang harus tetap dikerjakan sendiri.

## Penutup Hari 2 (10 menit)

81. **Lima pegangan** (diulang): AI membantu, bukan menggantikan; minta rujukan; periksa ke kitab; jaga data dan hak cipta; tetap berguru.
82. **Langkah setelah dauroh.** Latihan satu minggu, kelompok diskusi alumni, tempat bertanya, bahan bacaan.
83. **Tanya jawab dan evaluasi.**

---

# Lampiran A: Contoh perintah inti

Ini kerangka perintah, bukan teks final. Uji dan sempurnakan sebelum dauroh.

**AI pewawancara judul**
> Kamu adalah pembimbing bahsul ilmi yang sabar. Tugasmu membantu saya menemukan judul dan rumusan masalah. Jangan langsung memberi judul. Ajukan pertanyaan satu per satu: bidang, masalah yang mengganggu, jenjang, jenis penelitian, bahasa penulisan, sumber yang saya kuasai, batas waktu. Setelah cukup, rangkum pemahamanmu, minta saya mengoreksinya, baru tawarkan tiga judul beserta kelebihan dan risikonya.

**AI koreksi bahasa Arab**
> Periksa teks Arab berikut. Untuk setiap kesalahan, tulis: kalimat asal, jenis kesalahan (nahwu, sharaf, gaya), kaidahnya, dan dua atau tiga pilihan perbaikan beserta bedanya. Jangan mengubah teks yang berupa kutipan dari kitab. Jika tidak yakin, katakan tidak yakin.

**AI dosen syadid**
> Berperanlah sebagai dosen penguji yang keras tetapi adil. Baca bagian berikut dan cari: lompatan logika, kontradiksi antarbagian, klaim tanpa sumber, dalil yang tidak mendukung klaimnya, pendapat lawan yang belum dibahas, dan bagian yang tidak menjawab rumusan masalah. Urutkan dari yang paling berat. Jangan memuji berlebihan. Jangan menulis ulang bagian saya.

---

# Lampiran B: Hal yang perlu Anda putuskan

1. **Tiga AI khusus** (pewawancara judul dan kerangka, koreksi Arab, dosen syadid). Di daftar AI aplikasi yang saya baca tidak ada yang sepadan. Apakah dipakai sebagai perintah di AI mana pun lebih dulu, atau dibuat sebagai AI di OpenTurath sebelum dauroh?
2. **Akses peserta.** Apakah peserta mendapat akun OpenTurath untuk praktik (trial atau akses dauroh)? Berapa lama?
3. **Perangkat.** Laptop atau ponsel? Kalau ponsel, praktik yang panjang (kerangka, kritik bab) sebaiknya dipersingkat.
4. **Bahasa pengantar.** Indonesia saja, atau dicampur Arab?
5. **Jenjang peserta.** Penulisan skripsi, atau karya ilmiah umum? Ini memengaruhi tahap 1 sampai 3.
6. **Alamat situs dan saluran Telegram.** Saya sengaja tidak menyebut saluran Telegram tertentu karena tidak bisa memastikannya dari sini. Alamat situs di sesi 7 harus dicek ulang sebelum dicetak.
7. **Contoh nyata** untuk slide 6, 7, 61. Paling meyakinkan bila Anda sendiri yang mengujinya beberapa hari sebelum dauroh.
