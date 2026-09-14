# Rencana Pengalaman Catatan OpenTurath

## Tujuan

Menjadikan Catatan sebagai arsip kajian yang ringkas di ponsel, mudah ditemukan kembali, dan jujur tentang asal serta tingkat verifikasi setiap isi. Catatan bukan sekadar tempat menumpuk jawaban AI.

Keputusan utama: jawaban AI boleh memakai heading pertama sebagai judul, selama respons AI selalu memulai dengan heading yang bersih dan bermakna. Judul tidak boleh berupa label teknis seperti `JAWABAN LANGSUNG`.

## Batasan Produk

- Tidak membangun feed sosial, streak, poin, atau statistik belajar yang dibuat-buat.
- Tidak menyebut jawaban AI sebagai dalil atau rujukan kitab bila kitab, jilid, dan halaman belum tersedia.
- Tidak menambah sistem penyimpanan ketiga. Layar Catatan harus memiliki satu sumber data utama yang jelas.
- Tidak mengubah salinan pengguna yang sudah tersimpan secara destruktif. Normalisasi hanya memperbaiki tampilan atau berjalan saat item baru disimpan.

## Kondisi Saat Ini

- `BookmarkModel` adalah data yang dipakai layar Catatan: memuat judul, asal asisten, isi, kutipan Arab, kitab, halaman, dan waktu.
- Jawaban yang disalin dari AI dapat menjadi `BookmarkModel`; judulnya saat ini mengambil baris pertama respons.
- `ResearchNotesService` menyimpan bentuk data lain. Ini berisiko membuat data riset terpecah bila dua layanan terus berkembang berdampingan.
- Kartu Catatan dapat dibuka memanjang di daftar. Ini membuat jawaban panjang memenuhi layar dan tindakan Edit, Salin, Bagikan, serta Hapus bercampur dalam satu kartu.
- Editor adalah bottom sheet dengan toolbar Markdown permanen; kurang nyaman untuk membaca dan menyunting teks panjang pada ponsel.

## Kontrak Output AI

Setiap respons AI yang akan disimpan harus mengikuti bentuk berikut.

```markdown
# Judul kajian yang singkat dan spesifik

Isi jawaban...
```

Aturan implementasi:

- Ambil heading Markdown pertama sebagai `title`.
- Hilangkan heading tersebut dari cuplikan daftar agar judul tidak muncul dua kali.
- Batasi judul yang ditampilkan menjadi 80 karakter tanpa memotong kata secara kasar.
- Bila heading tidak ditemukan, pakai baris tidak kosong pertama sebagai fallback dan tandai item agar dapat diperbaiki pengguna.
- Bersihkan prefix teknis atau karakter artefak sebelum judul ditampilkan.

## Struktur Informasi Catatan

### Tipe dokumen

| Tipe | Arti | Status sumber yang ditampilkan |
|---|---|---|
| Catatan Pribadi | Teks yang dibuat pengguna | Tidak berlaku |
| Jawaban AI | Respons dari asisten | Belum diverifikasi atau Perlu dicek |
| Rujukan Kitab | Kutipan atau detail yang memiliki kitab | Kitab, jilid, halaman |

Bidang ilmu, nama asisten, tag masalah, dan waktu bukan tipe utama. Semua itu menjadi metadata untuk pencarian dan filter lanjutan.

### Status verifikasi

- `Belum diverifikasi`: respons AI atau catatan tanpa sumber primer yang lengkap.
- `Perlu dicek`: pengguna ingin memeriksa ulang tetapi belum menandainya selesai.
- `Sudah dicocokkan`: pengguna telah mencocokkan dengan kitab asal.

Status ini adalah pernyataan pengguna, bukan klaim otomatis dari aplikasi.

## Desain Layar Daftar

### Prioritas informasi

1. Judul kajian.
2. Tipe dokumen dan asal asisten.
3. Cuplikan paling relevan, maksimal dua baris.
4. Sumber primer bila tersedia atau status verifikasi bila belum tersedia.
5. Waktu relatif.

### Interaksi ponsel

- Kartu daftar selalu ringkas; tidak ada jawaban penuh yang mengembang di dalam daftar.
- Ketuk kartu membuka layar baca/detail.
- Menu `⋯` berisi Edit, Salin, Bagikan, dan Hapus. Hapus selalu memerlukan konfirmasi.
- Bar filter utama hanya: Semua, Catatan, Jawaban AI, Rujukan.
- Bidang, asisten, rentang waktu, status sumber, dan tag masuk ke satu panel Filter.
- Pencarian tetap tersedia, tetapi tidak membuat susunan layar meloncat secara agresif.

### Bahasa visual

- Gunakan gaya arsip kajian: nomor indeks kecil, label jenis dokumen, garis folio halus, dan ruang putih yang cukup.
- Tetap gunakan palet Quiet Scholar monokrom. Warna hanya untuk makna, bukan dekorasi.
- Hindari kartu besar di dalam kartu besar, badge berlebihan, dan tombol panjang pada setiap catatan.

## Desain Detail Catatan

- Gunakan layar baca penuh, bukan isi panjang di dalam kartu daftar.
- Header: kembali, menu `⋯`, tipe dokumen, judul, dan metadata waktu.
- Kutipan Arab memakai arah RTL serta font Arab yang sudah dipakai aplikasi.
- Rujukan kitab ditampilkan sebagai blok metadata yang mudah disalin.
- Jawaban AI tanpa sumber menampilkan label jujur `Belum memiliki rujukan kitab`.
- Tindakan utama bergantung tipe: Edit untuk Catatan Pribadi, Tambahkan sumber untuk Jawaban AI, Buka kitab bila tersedia untuk Rujukan Kitab.

## Desain Editor Ponsel

- Gunakan layar hampir atau sepenuhnya penuh agar teks panjang nyaman dibaca.
- Header sederhana: Batal atau Kembali, status draf, Simpan.
- Judul dan isi tanpa bingkai input berat.
- Toolbar format dipindah ke tombol `Aa` atau pilihan konteks; tidak tampil permanen.
- Pratinjau menjadi tindakan sekunder dan tidak bersaing dengan tombol Simpan.
- Tambahkan bagian Sumber yang dapat dibuka: kitab, pengarang, jilid, halaman, kutipan Arab, dan status verifikasi.
- Draf lokal tetap disimpan otomatis sebelum pengguna menekan Simpan.

## Urutan Implementasi

### Fase 0  Fondasi dan keputusan

- [ ] Tetapkan apakah `Salin` berarti hanya menyalin atau `Salin dan simpan`. Rekomendasi: pisahkan dua tindakan agar arsip tidak terisi tanpa niat pengguna.
- [ ] Jadikan `BookmarkModel` sumber data utama atau rencanakan migrasi jelas dari `ResearchNotesService`; jangan biarkan dua penyimpanan aktif untuk fungsi yang sama.
- [ ] Tambahkan metadata non-destruktif untuk tipe dokumen dan status verifikasi dengan fallback aman untuk data lama.
- [ ] Tetapkan dan uji kontrak heading output AI.

Kriteria selesai: catatan lama tetap terbaca dan sinkron; catatan baru selalu memiliki tipe serta judul yang dapat ditampilkan.

### Fase 1  Daftar Catatan mobile

- [ ] Ganti kartu mengembang dengan kartu ringkas.
- [ ] Buat empat filter tipe utama dan panel filter lanjutan.
- [ ] Pindahkan semua aksi sekunder ke menu `⋯`.
- [ ] Normalisasi judul dan cuplikan saat ditampilkan.
- [ ] Buat keadaan kosong, pencarian kosong, dan pemuatan yang jelas.

Kriteria selesai: daftar 20 catatan tetap mudah dipindai dengan satu ibu jari dan tidak ada jawaban panjang memenuhi layar.

### Fase 2  Detail baca

- [ ] Tambahkan layar detail untuk setiap catatan.
- [ ] Tampilkan sumber, kutipan Arab RTL, dan status verifikasi sesuai tipe.
- [ ] Tambahkan aksi Salin, Bagikan, Edit, Hapus melalui menu yang aman.
- [ ] Buat CTA Tambahkan sumber untuk Jawaban AI tanpa rujukan.

Kriteria selesai: pengguna dapat membaca satu catatan panjang dengan nyaman tanpa kembali ke daftar atau membuka editor.

### Fase 3  Editor yang tenang

- [ ] Ubah editor dari bottom sheet 88 persen menjadi pengalaman layar penuh yang responsif.
- [ ] Sederhanakan header dan sembunyikan toolbar Markdown di balik `Aa`.
- [ ] Pertahankan draf otomatis dan indikator status yang tidak mengganggu.
- [ ] Tambahkan formulir sumber opsional.

Kriteria selesai: membuat catatan sederhana dapat dilakukan tanpa memahami Markdown; catatan panjang tetap nyaman disunting di ponsel.

### Fase 4  Keandalan ilmiah

- [ ] Tambahkan alur Tambahkan sumber dan pilihan status verifikasi.
- [ ] Tampilkan format rujukan yang bersih untuk salin dan bagikan.
- [ ] Pastikan label AI tidak dapat disalahpahami sebagai kutipan kitab.
- [ ] Uji teks campuran Indonesia-Arab, item tanpa judul, item tanpa sumber, dan catatan sangat panjang.

Kriteria selesai: setiap catatan menunjukkan asal kontennya dengan jelas dan rujukan kitab dapat dibaca serta disalin tanpa kehilangan jilid atau halaman.

### Fase 5  Setelah fondasi terbukti berguna

- [ ] Sematkan catatan penting.
- [ ] Tag masalah lintas bidang, misalnya `wudu` atau `jual beli`.
- [ ] Bandingkan dua catatan atau dua rujukan berdampingan.
- [ ] Ekspor satu paket kajian dengan judul, kutipan, rujukan, dan status verifikasi.
- [ ] Buat folder Kajian hanya saat penggunaan membuktikan bahwa pengguna membutuhkan pengelompokan tingkat lanjut.

## Ukuran Keberhasilan

- Pengguna dapat menemukan catatan tertentu melalui judul, asisten, atau sumber dalam kurang dari 30 detik.
- Tidak ada catatan AI yang ditampilkan sebagai rujukan kitab tanpa metadata sumber.
- Pengguna dapat membuka, membaca, dan kembali dari catatan panjang tanpa scroll daftar yang tidak disengaja.
- Catatan lama tetap tersedia setelah pembaruan.
- Semua kontrol utama memiliki target sentuh layak ponsel dan dapat digunakan dalam mode gelap maupun terang.

## Checklist Verifikasi Rilis

- [ ] Uji data lama, offline, sinkronisasi cloud, dan konflik perubahan sederhana.
- [ ] Uji catatan 0, 1, 20, dan 100 item.
- [ ] Uji judul panjang, teks Arab RTL, respons tanpa heading, dan respons dengan heading Markdown.
- [ ] Uji layar sempit Android dan iPhone, mode terang dan gelap, serta ukuran teks besar.
- [ ] Uji hapus, urungkan, salin, bagikan, dan pemulihan draf.
- [ ] Jalankan analisis Flutter dan tes regresi sebelum APK dibuat.
