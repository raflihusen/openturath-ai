# Riset ulang: memperkenalkan OpenTurath melalui motion graphics

3 November 2026 · Tahap riset, audit, dan rekomendasi. Tidak ada film baru yang diproduksi dalam tahap ini.

## Kesimpulan utama

Arah paling masuk akal untuk OpenTurath saat ini adalah **cerita produk dengan komponen antarmuka sebagai pelaku utama**. Penonton perlu melihat kebutuhan, tindakan, dan hasil yang berhubungan. Tipografi, kamera, metafora, serta musik mendukung hubungan itu.

Ini rekomendasi untuk produk dan kondisi produksi kita, bukan resep universal atau peringkat efektivitas iklan. Riset mencakup tiga film software yang diperiksa melalui sampel frame, dua studi produksi tambahan, proses studio, dan audit sumber film terakhir. Tidak dilakukan uji penonton atau penilaian pendengaran baru. Tidak ada film, gambar, desain, atau audio referensi yang dimasukkan ke repositori untuk dipakai ulang.

## Referensi yang relevan dan apa yang dipelajari

| Acuan | Kegunaan untuk riset ini | Batas bukti |
|---|---|---|
| [Linear Agent — Linear, 2026](https://linear.app/changelog/2026-03-24-introducing-linear-agent) | Kontinuitas satu pekerjaan dalam antarmuka. | Sampel frame film, bukan evaluasi produk saat ini. |
| [Gemini — Ordinary Folk untuk Google, 2024](https://www.ordinaryfolk.co/project/gemini) | Gerak internal input, percakapan, dan hasil. | Sampel frame; tidak menilai audio. |
| [Webflow Ecommerce — Ordinary Folk, 2019](https://www.ordinaryfolk.co/project/webflow-ecommerce) | Hubungan antara objek desain, ruang, dan editor. | Film historis; bukan acuan UI Webflow terkini. |
| [Dropbox — The Collected Works](https://www.tcw.studio/project/dropbox) | Metafora ruang yang diberi fungsi produk. | Studi tertulis pembuat dan ilustrasi pada halaman; film lengkap tidak dianalisis. |
| [Config 2025 — Figma Brand Studio](https://www.figma.com/blog/how-we-shaped-the-visual-identity-for-config-2025/) | Mengembangkan identitas, motion, dan suara secara terpadu. | Laporan produksi acara dan peluncuran; bukan film pengenalan aplikasi tunggal. |

Catatan waktu dan metode dua referensi pertama ada dalam [REFERENCE_SHOT_LOG.md](REFERENCE_SHOT_LOG.md). Di antaranya, bagian Gemini sekitar **0:17–0:26** paling berguna untuk melihat perubahan keadaan sebuah komponen.

### Webflow: yang benar-benar diperiksa

Tautan film lengkap berasal dari [pemutar yang ditautkan studio](https://framerate.tv/watch/0XptQzSk). Berkas berdurasi 72,043 detik. Sampel diambil tiap empat detik sepanjang film, lalu tiap setengah detik pada 0:12–0:28 dan 0:44–1:00; waktu perkiraan ±0,5 detik.

Pada sekitar 0:04–0:12, editor dan grid objek muncul. Pada 0:12–0:28, bentuk geometris yang berulang berkembang dalam ruang. Pada 0:44–1:00, panel, pilihan bentuk, dan kanvas menyusun kembali antarmuka editor serta hasil desain. Studio menjelaskan bahwa script, konsep, 2D/3D dan UI dikembangkan bersama.

**Interpretasi:** bentuk fisik mengulang bahan yang sedang didesain di aplikasi. Pelajaran yang relevan adalah menghubungkan metafora dengan pekerjaan produk, bukan mengambil palet warna atau bentuk film itu. Sampel tidak membuktikan pengalaman penonton atau keterpaduan dengan musik.

### Dua catatan produksi tambahan

Dalam [studi Dropbox](https://www.tcw.studio/project/dropbox), studio memberi tiap ruang fokus fitur, menghubungkan portal dengan navigasi, serta menjelaskan tombol yang bereaksi saat hover dan klik. Artinya, arsitektur memiliki pekerjaan dalam cerita. Ini keterangan pembuat, bukan hasil menonton seluruh film. **Adaptasi yang layak diuji:** satu motif OpenTurath harus membantu menjelaskan tindakan atau isi, bukan menjadi tujuan perjalanan tersendiri.

[Laporan Figma](https://www.figma.com/blog/how-we-shaped-the-visual-identity-for-config-2025/) menjelaskan pengembangan motion sejak identitas dirancang, storyboard serta toolkit gerak, dan kerja Sounds Like These untuk palet audio yang saling berhubungan. Figma juga membedakan gerak tipografi ekspresif dan fungsional. **Interpretasi untuk proyek ini:** semua elemen tidak perlu bergerak dengan gaya dan durasi yang sama; pilih ekspresi berdasarkan peran informasinya.

## Audit film kita: masalah yang dapat ditunjukkan

Audit ini merujuk pada `openturath_motion/src/jejak/Film.tsx` dan pemeriksaan frame pada produksi sebelumnya. Penolakan pengguna adalah bukti bahwa hasil belum memenuhi permintaan; temuan berikut tidak mengklaim mengetahui seluruh penyebab selera pengguna.

| Bagian | Yang dibuat | Kekurangan komunikasi |
|---|---|---|
| 0–9 detik | Tinta, lengkung halaman, dan tiga nama bidang. | Hampir sepertiga film berlalu sebelum tindakan produk terlihat. Konteks kebutuhan dan manfaat belum konkret. |
| 9–14,8 detik | Daftar asisten dan contoh pertanyaan yang diketik. | Ada awal tindakan, tetapi belum ada hasil yang dapat dinilai penonton. |
| 14,9–18,8 detik | Teks tentang membaca penjelasan dan menelusuri rujukan. | Klaim tindakan menggantikan demonstrasi. Isi penjelasan dan identitas sumber tidak tampak. |
| 20,05–23,3 detik | Kartu contoh catatan dibuat tersendiri. | Tidak terlihat bagian jawaban mana yang dipilih dan bagaimana bagian itu menjadi catatan. |
| 25,1–30 detik | Logo dan alamat situs di atas buku. | Penutup merek ada, tetapi perjalanan produk sebelumnya belum terselesaikan. |

Bukti paling jelas: `ChatScreen` dipasang dengan `answerProgress={0}`. `LibraryScreen` dan `NoteReaderScreen` diimpor serta diekspor sebagai alternatif, tetapi tidak dipakai dalam adegan film. Karena itu, kalimat tentang jawaban dan rujukan belum memiliki bukti visual dalam film tersebut.

Masalah craft juga nyata: pratinjau 3D masih jauh dari material dan pencahayaan pada papan konsep, tetapi produksi tetap dilanjutkan. Memastikan teks tidak tertutup dan file berhasil diekspor hanya memeriksa sebagian kecil mutu film. Gambar konsep imagegen tidak membuktikan kemampuan menghasilkan animasi dengan tampilan yang sama.

## Bagaimana motion seharusnya bekerja untuk OpenTurath

### 1. Tentukan apa yang harus dipahami penonton

Sebelum menentukan bentuk, tulis tiga jawaban: OpenTurath alat apa, pekerjaan apa yang dibantu, dan hasil konkret apa yang dapat dilihat dalam contoh. Pilih satu kebutuhan penuntut ilmu yang relevan. Keluasan bidang tetap ditunjukkan melalui struktur produk yang benar, lalu satu contoh diperlihatkan sampai selesai.

Memuat banyak nama modul belum menjelaskan manfaatnya. Menampilkan satu contoh juga belum cukup bila jawaban dan kelanjutan belajarnya tidak diperlihatkan. Keduanya perlu dihubungkan dalam cerita singkat.

### 2. Susun perubahan keadaan, bukan urutan gambar layar

Contoh rancangan gerak untuk diuji:

- **Memilih:** beberapa kartu bidang masuk sebagai satu susunan yang dikenali; satu pilihan menonjol, dan pilihan yang sama tetap terbaca pada header percakapan berikutnya.
- **Bertanya:** kolom input diberi ruang besar. Setelah dikirim, teks yang sama tetap menjadi jangkar perhatian saat berpindah ke bubble percakapan.
- **Memahami:** bagian jawaban yang relevan muncul dan diberi waktu untuk dibaca. Kamera mendekat pada informasi yang sedang dijelaskan, lalu mengembalikan konteks.
- **Memeriksa:** satu rujukan yang valid difokuskan. Tindakan berikutnya mengikuti kontrol dan kemampuan aplikasi yang benar-benar ada; jangan menciptakan navigasi sumber yang belum didukung produk.
- **Menyimpan:** uji transisi menuju catatan dengan isi yang tetap berhubungan dengan pertanyaan dan jawaban. Bila aplikasi mendukung penyimpanan bagian terpilih, pertahankan bagian itu sebagai jangkar visual. Jika belum, gunakan alur catatan yang memang tersedia; jangan menyiratkan fitur seleksi atau penyimpanan otomatis yang belum dibuktikan.

Ini rancangan transisi film, bukan pernyataan bahwa aplikasi saat ini mempunyai animasi tersebut. Keadaan awal/akhir, kontrol, data, dan hubungan fiturnya harus sesuai produk. Gerak bisa dirancang khusus tanpa mengarang kemampuan.

### 3. Bangun hierarki gerak

Pada setiap beat, tentukan satu hal yang harus dilihat dahulu. Objek utama melakukan tindakan; layout merespons; detail sekunder menyusul seperlunya. Beri jeda setelah informasi penting tiba. Hindari gerak latar yang terus menyaingi teks atau semua kartu yang masuk bersamaan dengan bobot sama.

Perubahan skala berguna saat mengarahkan perhatian. Rotasi perangkat, blur, grain, cahaya dan bayangan perlu mendapat alasan dari adegan. Memindahkan bingkai layar saja belum memperlihatkan perubahan pekerjaan pengguna.

### 4. Rancang 9:16 sejak awal

Susun ulang komposisi untuk tinggi layar, bukan memangkas film horizontal. Periksa pada ukuran tampilan ponsel yang sebenarnya. Teks UI yang tampak besar di kanvas 1080 piksel bisa menjadi terlalu kecil setelah ditampilkan di layar selebar sekitar 360 piksel.

Tampilkan konteks secukupnya, lalu besarkan isi yang perlu dibaca. Jaga posisi caption, tombol, subtitle bila ada, dan area tepi platform. Untuk Arab, pertahankan RTL, sambungan huruf, diakritik dan baris yang masuk akal. Animasi reveal sebaiknya mempertahankan bentuk kata utuh; jangan menjadikan nash sebagai serpihan dekoratif.

### 5. Rancang audio bersama cerita

[Proses Ordinary Folk](https://www.ordinaryfolk.co/process) menempatkan pesan/script, desain/storyboard, animasi dan audio dalam pekerjaan yang saling berkaitan. Mereka menyatakan suara, musik dan VO dipikirkan sejak awal; komposer bekerja setelah animatik tersedia.

Penerapannya: tentukan dulu bagian yang mengundang rasa ingin tahu, bagian yang memerlukan baca, aksi yang membutuhkan penegasan, dan penyelesaian. Kemudian pilih musik serta efek yang mendukung fungsi itu. Musik berlisensi atau karya komposer profesional tetap memerlukan penilaian kecocokan dengan film. Earshot membantu level, clipping, mono dan penempatan cue; angka itu tidak menilai selera. Pada lingkungan ini, model semantik/realness belum tersedia dan tidak ada penilaian pendengaran baru.

## Bentuk produksi yang saya rekomendasikan

Untuk percobaan berikutnya, gunakan **komponen UI yang dibangun sebagai layer animasi, dengan kedalaman secukupnya**, mempertahankan monokrom editorial OpenTurath. Besarkan hal yang sedang beraksi; pertahankan satu objek/data sebagai penghubung. Ini pilihan berdasarkan kegagalan produksi dan relevansi referensi, bukan klaim bahwa 3D atau metafora selalu salah.

Satu urutan kerja yang dapat diuji adalah: kebutuhan pembaca → bidang/asisten → pertanyaan → jawaban contoh → pemeriksaan rujukan → catatan → merek. Bagian jawaban dan rujukan perlu diisi dengan contoh yang telah diperiksa. Jika kontennya belum siap, jangan menutup kekosongan itu dengan slogan atau lokator rekaan.

Pembagian awal untuk animatik 30 detik dapat berupa 0–3 konteks/manfaat; 3–7 pilihan yang relevan; 7–15 pertanyaan dan hasil; 15–23 pemeriksaan serta penyimpanan; 23–27 hasil belajar; 27–30 merek/ajakan. Ini usulan ritme untuk diuji, bukan standar industri. Potong tindakan bila informasi tidak terbaca; jangan mempercepat semua bagian untuk mengejar daftar fitur.

## Cara menguji sebelum ekspor penuh

1. **Animatik cerita:** gambar sederhana dengan urutan, gerak besar dan durasi. Uji apakah penonton baru dapat menyebut alat, tindakan, dan hasil. Uji tanpa musik untuk mendeteksi cerita yang belum jelas.
2. **Potongan representatif:** buat satu bagian yang mencakup input → hasil → transisi berikutnya dengan kualitas gerak, teks, dan renderer yang benar-benar akan dipakai. Nilai animasinya melalui pemutaran, bukan hanya styleframe.
3. **Pemeriksaan produk:** cocokkan keadaan UI, kemampuan, Arab dan contoh sumber dengan bahan yang dimiliki. Jangan menyatakan seluruh jawaban AI terverifikasi.
4. **Penyatuan audio:** tinjau musik dan gambar bersama; ukur hasil akhir setelah encoding. Jika pemeriksaan artistik belum dilakukan, nyatakan batas itu.
5. **Ekspor penuh:** lanjutkan setelah masalah yang terlihat pada uji tadi diselesaikan. Kriteria cerita dan craft tetap berlaku walaupun render berhasil.

Ini rekomendasi proses kerja, bukan permintaan izin tambahan atau klaim bahwa uji penonton telah dilaksanakan. Tahap saat ini selesai pada riset dan arahan; belum ada desain atau video pengganti yang dinyatakan layak.
