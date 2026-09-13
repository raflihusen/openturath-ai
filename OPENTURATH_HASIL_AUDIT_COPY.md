# Audit teks dan copy OpenTurath

Audit editorial, 13 September 2026

**OpenTurath membutuhkan bahasa yang lebih dekat dengan kegiatan pembaca.** Banyak teks lama menjelaskan istilah dan proses di balik aplikasi, sementara pengguna sedang memilih asisten, membaca kitab, menyimpan kutipan, atau membayar paket. Revisi mengutamakan tindakan tersebut, mempertahankan istilah keilmuan yang berguna, dan mengurangi klaim yang tidak dapat dipastikan dari inventaris.

Seluruh 12 bagian dalam dokumen yang dilampirkan telah dibaca. Hasil ini berlaku untuk inventaris tersebut. Kode sumber, perilaku aplikasi aktif, isi lengkap kebijakan di situs, dan jawaban yang dihasilkan NotebookLM belum diperiksa pada sesi ini. Karena itu, tidak ada klaim bahwa aplikasi telah diperbarui atau bahwa inventaris ini pasti mencakup setiap teks yang muncul saat aplikasi dijalankan.

**Isi berkas hasil**

| Berkas | Kegunaan |
| --- | --- |
| AUDIT_MASTER_SEMUA_COPY_DAN_TEKS_APLIKASI.md | Membaca versi revisi lengkap menurut susunan layar dalam dokumen asal |
| OPENTURATH_HASIL_AUDIT_COPY.md | Melihat diagnosis, keputusan bahasa, kondisi penerapan, dan seluruh pasangan teks lama dengan penggantinya |
| OPENTURATH_PETA_PENGGANTIAN_COPY.json | Mencocokkan perubahan dengan 72 konstanta AppCopy dan lokasi pada inventaris asal |

**Catatan penggunaan:** peta penggantian merupakan bahan implementasi. Nomor baris menunjuk dokumen inventaris, bukan baris kode Dart. Jangan menjalankan penggantian global dari pasangan kata di dalamnya.

## 1. Hasil pemeriksaan

- **12 bagian utama** dibaca, termasuk deskripsi model, contoh permintaan, dan ringkasan kebijakan.
- **72 konstanta AppCopy** diperiksa. Sebanyak **34 diubah** dan **38 dipertahankan**.
- **312 pasangan pemeriksaan** disusun, terdiri atas **310 pasangan dengan perubahan** dan **2 pasangan yang sengaja dipertahankan**. Satu pasangan dapat berlaku di beberapa tempat.
- Di dalamnya terdapat **273 entri siap secara redaksional**, **31 entri yang memerlukan pemeriksaan perilaku atau data**, serta **8 draf kebijakan yang belum siap tayang**.
- **6 penyesuaian tambahan bergantung pada konteks** dicatat terpisah, mencakup badge ketersediaan, tombol rujukan dan hapus, pengaturan teks Arab, serta informasi jumlah jilid dan penahkik yang belum tersedia.
- **321 teks tampilan unik dalam backtick** diinventarisasi pada JSON setelah konstanta, ID, jalur berkas, dan URL dipisahkan. Angka ini mencakup contoh dinamis dan tidak mewakili jumlah semua string dalam aplikasi.

Angka perubahan bukan skor kualitas. Beberapa entri menyangkut ejaan, sementara lainnya membutuhkan penjelasan perilaku yang lebih penting daripada panjang teks.

Teks seperti **Beranda**, **Asisten AI**, **Pengaturan**, **Lanjutkan dengan Google**, **Coba lagi**, **Batal**, **Tutup**, dan **Belum ada catatan** dipertahankan. Tagline **Membaca kitab, menelusuri ibarah.** juga tetap layak. Ia singkat, sesuai kegiatan pengguna, dan memiliki identitas yang lebih kuat daripada slogan yang sarat istilah akademik.

Temuan dikelompokkan menurut dampaknya, bukan sekadar jumlah kata yang diganti.

| Prioritas | Temuan | Dampak dan keputusan |
| --- | --- | --- |
| P0 | Badge HEMAT 15% pada paket 6 bulan tidak sesuai angka | Hapus klaim tersebut. Perbandingan hitungan terdapat di bagian pembayaran |
| P0 | Paket terpilih bercampur dengan klaim seluruh modul dan tanpa batas | Tampilkan cakupan akses dari data paket yang sebenarnya |
| P0 | Salin dan simpan digabung dalam satu pesan | Bedakan keberhasilan masing-masing tindakan, termasuk hasil sebagian |
| P0 | Pembayaran sukses langsung dianggap aktivasi selesai | Tampilkan status pembayaran dan aktivasi secara terpisah |
| P0 | Klaim catatan terenkripsi dan semua data dihapus | Periksa lokasi penyimpanan, cakupan penghapusan, dan perlindungan yang benar-benar diterapkan |
| P1 | Kitab, naskah primer, korpus, dan kanonikal dipakai seolah setara | Gunakan kitab atau kumpulan kitab untuk objek yang memang berupa koleksi kitab |
| P1 | Spesialis, modul, asisten, kajian, dan ruang riset saling bertukar | Tetapkan Asisten AI, Percakapan, Catatan, dan Kitab rujukan sesuai objeknya |
| P1 | Verifikasi sanad dipakai untuk data tahun wafat | Ubah menjadi Tahun wafat belum tersedia |
| P1 | Sitasi disebut standar tanpa format yang ditetapkan | Gunakan Salin rujukan dan bedakan identitas kitab dari kutipan halaman tertentu |
| P1 | Arah teks RTL dicampur dengan perataan | Pisahkan pengaturan arah tulisan dari rata kanan-kiri |
| P1 | Pesan pencarian kosong disamakan dengan koleksi kosong | Berikan pesan dan tindakan yang sesuai kondisi |
| P2 | Ejaan, kapitalisasi, dan tanda baca tidak konsisten | Terapkan kamus istilah dan pola penulisan yang sama pada semua layar |

P0 berarti teks berpotensi memengaruhi keputusan pembayaran atau pemahaman terhadap tindakan penting. P1 berkaitan dengan pemahaman fungsi dan ketepatan makna. P2 menyangkut kerapian editorial. Pengelompokan ini merupakan prioritas produk, bukan penilaian hukum.

## 2. Suara bahasa yang ditetapkan

Nada OpenTurath sebaiknya **tenang, jelas, akrab, dan tetap menghormati tradisi keilmuan**. Sapaan Ahlan dapat dipertahankan. Gunakan Anda ketika diperlukan, tanpa menyisipkannya ke setiap tombol atau notifikasi.

Tombol memakai kata kerja yang menjelaskan hasil, misalnya Buka asisten, Simpan catatan, dan Gunakan voucher. Judul cukup menyebut objek atau tindakan. Penjelasan panjang ditempatkan pada bantuan atau detail, sedangkan istilah di kontrol utama dibuat singkat.

| Unsur | Ketetapan | Contoh |
| --- | --- | --- |
| Kapitalisasi | Huruf besar di awal kalimat dan nama diri | Tampilan bacaan, Gunakan voucher |
| Tombol | Tanpa titik dan tanpa tanda seru | Simpan catatan |
| Notifikasi selesai | Kalimat pendek dengan hasil yang pasti | Catatan disimpan. |
| Status berjalan | Kata kerja sesuai proses, dengan elipsis | Menyiapkan percakapan… |
| Kolom isian | Label tetap terlihat, placeholder membantu mengisi | Nomor WhatsApp dan Contoh: 081234567890 |
| Kegagalan | Sebut objek yang gagal, lalu langkah berikutnya | Daftar kitab belum bisa dimuat. Coba lagi. |
| Kesalahan pengguna | Sebut perbaikan yang dapat dilakukan | Masukkan kode voucher terlebih dahulu. |
| Konfirmasi berisiko | Judul tindakan, dampak singkat, tombol spesifik | Hapus catatan, Batal, Hapus catatan |
| Harga | Format rupiah konsisten | Rp49.000 |
| Durasi | Mengikuti periode yang benar-benar dijual | 30 hari hanya jika paket memang berlangsung 30 hari |
| Pengingat ilmiah | Satu tindakan konkret per pesan | Cocokkan kutipan dengan kitab asal. |

Kata gagal tetap boleh dipakai bila statusnya memang kegagalan akhir, seperti Pembayaran gagal. Frasa belum bisa lebih cocok untuk kendala sementara yang masih dapat dicoba kembali. Kealamian bahasa tidak mengharuskan semua kegagalan dilunakkan menjadi belum.

## 3. Kamus istilah yang dipakai

| Istilah lama atau variasi | Pilihan utama | Batas pemakaian |
| --- | --- | --- |
| Korpus, khazanah naskah kanonikal | Kumpulan kitab atau kitab rujukan | Gunakan sesuai objek. Jangan mengganti kata yang terdapat dalam kutipan atau judul ilmiah |
| Naskah primer | Kitab asal atau sumber asal | Naskah tetap tepat untuk manuskrip. Status sumber primer harus ditentukan berdasarkan konteks penelitian |
| Spesialis AI, modul riset | Asisten AI | Modul dapat tetap menjadi istilah kode internal |
| Ruang riset, kajian, sesi riset | Percakapan | Kajian tetap berguna untuk menyebut isi pembahasan, bukan nama sesi |
| Catatan Riset, simpanan | Catatan | Di dalamnya dapat ada catatan, ibarah, dan rujukan kitab |
| Sitasi, salinan sitasi standar | Rujukan, Salin rujukan | Sitasi dapat dipakai bila tersedia fitur format akademik yang jelas |
| Muallif atau penulis pada identitas kitab | Pengarang | Nama pengarang dan judul bibliografis tetap mengikuti sumber |
| Muhaqqiq, pentahqiq | Penahkik | Tambahkan bantuan singkat tentang penyuntingan atau pemeriksaan teks edisi |
| Hadits | Hadis | Pilihan ejaan antarmuka, tanpa mengubah ID hadits |
| Aqidah | Akidah | Nama atau judul sumber yang menggunakan ejaan lain tidak diubah otomatis |
| Usul Fiqh, Usul Fiqih, Ushul Fiqih | Usul Fikih | Gunakan usul fikih di dalam kalimat |
| Sharaf, balaghah, akhlaq | Saraf, balagah, akhlak | Konsisten pada teks Indonesia, pertahankan transliterasi judul bibliografis |
| Wasilah bantu | Bantuan | Makna tetap jelas tanpa dua istilah yang saling mengulang |
| Komparasi, telaah | Bandingkan, pelajari, baca | Telaah boleh dipakai pada tulisan ilmiah jika konteks membutuhkannya |
| Klaim akses, tukar kode, redeem | Gunakan voucher | Jika kode akses dan voucher berbeda secara produk, bedakan secara eksplisit |
| Segera hadir | Dalam persiapan | Segera hadir lebih tepat jika ada kepastian peluncuran dalam waktu dekat |
| Ekosistem NotebookLM | NotebookLM | Nama layanan tetap terlihat ketika membantu memahami tujuan login |

**Ibarah dipertahankan secara selektif.** Pada pengenalan pertama, gunakan penjelasan ibarah, yaitu kutipan teks dari kitab. Setelah itu, Salin ibarah sudah cukup untuk kutipan kitab. Tombol menyalin jawaban AI tetap bernama Salin jawaban karena jawabannya dapat berisi ringkasan atau penjelasan, bukan teks sumber yang dikutip apa adanya.

Matan, syarah, hasyiyah, sanad, takhrij, dan istilah mazhab tetap dapat dipakai dalam materi dan filter khusus. Pengguna baru dapat dibantu melalui keterangan pendek yang dibuka sesuai kebutuhan. Jangan menempelkan definisi panjang ke setiap chip kategori.

Ejaan di atas merupakan keputusan editorial antarmuka. Audit ini tidak mengganti judul kitab, menormalisasi nama semua pengarang, atau menetapkan transliterasi ilmiah baru. Teks Arab dari sumber juga tetap dipertahankan. Empat label kategori Arab mendapat pendamping bahasa Indonesia agar mudah dipindai.

## 4. Temuan dan keputusan untuk setiap bagian

| Bagian | Penilaian | Revisi yang sudah disusun | Hal yang masih perlu dicocokkan |
| --- | --- | --- | --- |
| AppCopy | Navigasi cukup baik, istilah sesi dan pesan aksi belum konsisten | 72 konstanta diperiksa, 34 diubah | Pemakaian konstanta pada setiap widget, terutama salin, simpan, dan hapus |
| Bidang dan asisten | Deskripsi padat jargon, beberapa nama terasa seperti gelar otoritas AI | Deskripsi 9 bidang, profil 6 asisten aktif, 8 calon asisten, dan 18 contoh permintaan diperbaiki | Kesesuaian materi, cakupan sumber, dan status aktif sebenarnya |
| Masuk dan sesi Google | Kredensial Google Cloud dan ekosistem terlalu teknis | Menyiapkan percakapan dan Memeriksa akun Google | Tahap login sebenarnya, kebutuhan dua sesi, dan layanan yang menerima data |
| Beranda | Sapaan Peneliti Turats mengasumsikan identitas pengguna, carousel mengulang peringatan | Fallback Ahlan, pencarian lebih spesifik, setiap slide memiliki tujuan berbeda | Cakupan indeks pencarian, kebenaran tanggal, dan hitungan asisten aktif |
| Daftar asisten | Khazanah asisten riset naskah primer terasa seperti metadata internal | Pilih asisten sesuai bidang ilmu atau karya ulama yang ingin Anda pelajari | Badge Tersedia harus terpisah dari Langganan aktif |
| Percakapan | Menutup, menyimpan, dan menyalin belum dibedakan | Tampilan bacaan, status percakapan, dialog tutup lebih jelas | Riwayat NotebookLM, draf lokal, hasil salin parsial, arah dan perataan teks |
| Katalog dan detail | Bahasa bibliografis dipakai sebagai klaim kualitas | Kitab rujukan, Detail kitab, Pengarang, Penahkik, Salin rujukan | Kelengkapan edisi, dasar klasifikasi, filter periode, dan sumber metadata |
| Catatan | Label riset terlalu dominan dan aksi Kitab kurang menjelaskan tujuan | Catatan, Ubah catatan, Simpan catatan, placeholder lebih sederhana | Validasi kolom, penyimpanan lokal, cadangan, dan hasil pencarian kosong |
| Langganan dan DOKU | Janji akses dan penghematan tidak konsisten | Copy paket netral, alur pembayaran singkat, nama metode tanpa daftar merek statis | Harga aktif, durasi, cakupan paket, metode merchant, dan aktivasi akses |
| Voucher | Klaim, tukar, kode akses, dan voucher dipakai bergantian | Gunakan voucher di seluruh alur | Arti kode akses, batas pakai per akun atau global, serta hasil aktivasi |
| Profil dan kebijakan | Tampilan dan Kebahasaan kaku, beberapa klaim menyangkut data | Tampilan dan bahasa, Tentang sumber rujukan, draf kebijakan lebih jelas | Isi kebijakan lengkap dan kenyataan pengelolaan data |
| Ibarah, pembaruan, dan error | Asli, siap dipasang, dan server naskah bisa melebihi fakta status | Ibarah dan rujukan, Versi baru tersedia, error tanpa dugaan penyebab | Asal teks, tahap unduh pembaruan, dan penyebab error yang terdeteksi |

Jumlah 9 bidang memperbaiki judul sumber yang menyebut 6 disiplin, padahal daftarnya berisi 9. Angka katalog yang dicantumkan menghasilkan 87 + 1.173 + 241 + 449 + 218 + 58 = **2.226**. Perhitungan ini memeriksa konsistensi dokumen, belum membuktikan semua kitab dapat dibuka atau tersedia penuh dalam setiap paket.

Nama AI Kajian Habib Umar bin Hafizh dan AI Kajian Imam al-Ghazali membantu menjelaskan bahwa asisten dipakai untuk menelusuri karya tokoh. Nama tersebut tidak menyatakan dukungan resmi, afiliasi, atau bahwa sistem mewakili pribadi tokoh. Pertahankan penanda Asisten AI pada profil Al-Muhaqqiq, Al-Mufassir, dan nama peran lain agar fungsi otomatisnya tetap jelas.

**Pembagian isi carousel**

| Slide | Tujuan | Judul revisi |
| --- | --- | --- |
| 1 | Mengenalkan kegunaan | Mengenal OpenTurath |
| 2 | Menjelaskan peran bimbingan | Tetap belajar bersama guru |
| 3 | Mendorong pemeriksaan kutipan | Cocokkan dengan kitab asal |
| 4 | Membantu mencantumkan sumber | Cantumkan rujukan dengan jelas |
| 5 | Mengarahkan pengguna membuka rujukan | Lihat sumber kutipan |

Kelima slide tidak perlu mengulang paragraf peringatan yang sama. Pengingat ringkas di percakapan dapat berbunyi **Jawaban AI bisa keliru. Periksa kutipan pada kitab asal.** Gunakan penjelasan panjang pada pengenalan atau panduan yang sengaja dibuka pengguna.

## 5. Ketepatan copy pembayaran

Harga di bawah hanya berasal dari dokumen pengguna, bukan pemeriksaan harga jual saat ini.

| Paket | Harga dalam dokumen | Pembanding bulanan | Hasil hitungan |
| --- | --- | --- | --- |
| 1 bulan | Rp49.000 | Rp49.000 | Dasar pembanding |
| 6 bulan | Rp299.000 | 6 × Rp49.000 = Rp294.000 | Lebih mahal Rp5.000, sehingga badge HEMAT 15% tidak didukung angka ini |
| 1 tahun | Rp499.000 | 12 × Rp49.000 = Rp588.000 | Selisih Rp89.000, sekitar 15,14% lebih rendah |

Master memakai badge durasi yang netral. **Hemat Rp89.000 dibanding paket bulanan selama 12 bulan** dapat dipakai untuk paket tahunan hanya setelah cakupan akses, durasi efektif, biaya, dan dasar harga pembanding dinyatakan setara. Jika tidak ada informasi tambahan yang berguna, badge durasi yang mengulang judul paket boleh dihilangkan.

Kartu paket perlu menjelaskan nama asisten atau kelompok asisten yang terbuka. Frasa sesuai cakupan paket hanya cocok sebagai ringkasan bila cakupannya benar-benar ditampilkan di dekatnya. Deskripsi yang lebih alami tidak menyelesaikan ketidakjelasan hak akses.

Format isi yang perlu tersedia pada layar pembelian:

| Komponen | Teks atau data yang ditampilkan |
| --- | --- |
| Nama | Paket 30 hari, bila durasi produk memang 30 hari |
| Cakupan | Nama asisten atau daftar akses dari data paket |
| Total | Harga yang benar-benar dibayar, dengan biaya tambahan bila ada |
| Masa berlaku | Tanggal mulai dan berakhir, atau aturan mulai yang jelas |
| Perpanjangan | Keterangan otomatis atau manual hanya setelah mekanismenya dipastikan |
| Voucher | Akses dan durasi yang diberikan oleh kode tersebut |
| Tombol | Lanjut ke pembayaran |

Jangan menambahkan Tanpa biaya tambahan, Sekali bayar, Tidak diperpanjang otomatis, atau Bisa dibatalkan kapan saja sebelum ketentuannya terbukti. Audit ini tidak menetapkan kebijakan komersial baru.

## 6. Pesan menurut kondisi aplikasi

Tabel berikut merupakan **usulan tambahan untuk kondisi yang belum dipisahkan dalam inventaris**. Nama kondisi bersifat editorial, bukan nama event atau field di kode. Tampilkan hanya ketika aplikasi dapat mengenali kondisi tersebut.

| Kondisi | Teks yang disarankan | Aksi atau catatan |
| --- | --- | --- |
| Salin jawaban berhasil | Jawaban disalin. | Cocok untuk tombol Salin jawaban |
| Simpan jawaban berhasil | Jawaban disimpan di Catatan. | Cocok untuk tombol Simpan ke Catatan |
| Salin dan simpan berhasil | Jawaban disalin dan disimpan di Catatan. | Dua hasil harus sudah terkonfirmasi |
| Salin berhasil, simpan gagal | Jawaban disalin, tetapi belum tersimpan di Catatan. | Coba simpan lagi |
| Simpan berhasil, salin gagal | Jawaban disimpan di Catatan, tetapi belum bisa disalin. | Coba salin lagi |
| Keduanya gagal | Jawaban belum bisa disalin atau disimpan. Coba lagi. | Jangan memberi notifikasi sukses |
| Jawaban kosong | Belum ada jawaban untuk disalin. | Sudah tersedia dan dipertahankan |
| Salin saja sebagai fungsi tombol | Salin jawaban | Bila salin juga menyimpan, pertimbangkan Salin dan simpan atau pisahkan aksinya |
| Catatan pertama belum ada | Belum ada catatan | Simpan jawaban, kutipan, atau rujukan kitab di sini. |
| Catatan ada, pencarian kosong | Catatan belum ditemukan | Coba kata kunci lain atau hapus filter. |
| Katalog ada, pencarian kosong | Kitab belum ditemukan | Coba kata kunci lain atau hapus filter. |
| Katalog benar-benar kosong | Belum ada kitab dalam daftar ini | Jangan menyuruh pengguna mengubah kata kunci |
| Asisten sedang disiapkan | Asisten ini sedang disiapkan | Hindari menyuruh pengguna mencoba berulang bila belum dirilis |
| Asisten tersedia tetapi akses belum aktif | Aktifkan akses untuk membuka asisten ini | Lihat paket dan Gunakan voucher |
| Langganan sudah berakhir | Langganan berakhir pada [Tanggal] | Lihat paket |
| Pembayaran belum dilakukan | Menunggu pembayaran | Tampilkan batas waktu bila tersedia |
| Pembayaran diterima, aktivasi berlangsung | Pembayaran diterima. Akses sedang diaktifkan. | Periksa status, tanpa mendorong pembayaran ulang |
| Pembayaran dan aktivasi selesai | Pembayaran berhasil. Langganan Anda sudah aktif. | Buka asisten |
| Pembayaran gagal | Pembayaran belum berhasil. | Tampilkan cara melanjutkan berdasarkan respons penyedia |
| Tagihan kedaluwarsa | Batas waktu pembayaran sudah lewat. | Buat pembayaran baru hanya bila alurnya didukung |
| Transaksi dibatalkan | Pembayaran dibatalkan. | Jangan tampilkan hanya karena halaman ditutup |
| Status belum dapat diperiksa | Status pembayaran belum bisa diperiksa. Coba lagi. | Periksa status |
| Halaman ditutup, tagihan tetap aktif | Halaman pembayaran akan ditutup. Tagihan tetap aktif hingga [Waktu]. | Gunakan hanya jika perilaku dan tenggat telah terkonfirmasi |
| Halaman ditutup, transaksi dibatalkan | Pembayaran yang belum selesai akan dibatalkan. | Label tombol Batalkan pembayaran |
| Voucher diproses | Memeriksa voucher… | Tombol tidak mengirim permintaan berulang |
| Voucher valid, aktivasi berlangsung | Voucher diterima. Akses sedang diaktifkan. | Pisahkan dari aktivasi selesai |
| Voucher dan aktivasi selesai | Voucher berhasil digunakan. Akses Anda sudah aktif. | Nama akses dan tanggal berakhir bila tersedia |
| Kode dibatasi per akun | Anda sudah menggunakan voucher ini. | Hanya jika riwayat penggunaan milik akun yang sama |
| Kuota global kode habis | Voucher ini sudah mencapai batas penggunaan. | Bedakan dari kode tidak ditemukan |
| Judul dan isi sama-sama kosong, salah satu cukup | Isi judul atau tulis catatan terlebih dahulu. | Sesuai varian master |
| Judul wajib | Isi judul catatan. | Tampilkan dekat kolom judul |
| Isi wajib | Tulis isi catatan. | Tampilkan dekat kolom isi |
| Rujukan tidak memiliki informasi halaman | Informasi halaman belum tersedia. | Jangan menambahkan angka rekaan |
| Teks hanya salinan keluaran AI | Kutipan dari jawaban AI | Hindari label kutipan asli yang belum dibuktikan |
| Kutipan benar-benar diambil dari kitab | Ibarah dari kitab | Sertakan identitas sumber dan konteks |
| Pembaruan baru tersedia | Versi baru OpenTurath tersedia | Unduh pembaruan jika tombol memulai unduhan |
| Pembaruan selesai diunduh | Pembaruan siap dipasang | Pasang pembaruan jika tombol memulai instalasi |

**Teks tambahan untuk kontrol yang belum memiliki label dalam inventaris**

| Kontrol | Label yang disarankan |
| --- | --- |
| Silang pada tab | Tutup percakapan [Nama Asisten] |
| Silang di kolom pencarian | Hapus pencarian |
| Tombol Kitab pada kartu catatan | Lihat rujukan, jika membuka sumber yang tercatat |
| Tombol hapus dalam konfirmasi catatan | Hapus catatan |
| Kelompok pengaturan arah tulisan | Arah teks |
| Kelompok pengaturan perataan | Perataan teks |
| Kelompok ukuran teks | Ukuran teks |
| Label tetap kolom editor | Judul catatan, Isi catatan, Judul kitab, Jilid dan halaman |
| Bantuan pada penahkik | Penyunting yang menyiapkan atau memeriksa teks edisi ini. |
| Nama layanan dalam halaman bantuan | NotebookLM |

Label aksesibilitas menyebut tindakan atau objek. Jangan membacakan nama ikon seperti close, bookmark, atau more. Ketersediaan ikon dan perilakunya belum diuji, sehingga tabel ini merupakan spesifikasi tambahan.

## 7. Katalog, teks Arab, dan ketepatan sumber

**Identitas kitab harus dipisahkan dari sumber jawaban.** Tercantumnya kitab di katalog belum membuktikan bahwa kutipan tertentu berasal dari kitab itu. Salin rujukan pada detail kitab menyalin identitas bibliografis, sedangkan salin rujukan pada ibarah perlu memuat lokasi kutipan yang memang tersedia.

| Objek salinan | Template |
| --- | --- |
| Identitas kitab | [Pengarang]. [Judul Kitab]. Tahkik: [Muhaqqiq]. [Penerbit], [Tahun Cetak]. [Jumlah Jilid] jilid. |
| Kutipan pada lokasi tertentu | [Pengarang]. [Judul Kitab]. [Edisi atau penerbit], [tahun terbit], jilid [nomor jilid], hlm. [nomor halaman]. |
| Keterangan asal penelusuran | Ditemukan melalui OpenTurath. Tulis terpisah bila memang ingin dicantumkan |

Template di atas belum menyatakan kepatuhan pada satu gaya sitasi akademik. Segmen yang datanya kosong harus dihilangkan dengan tanda baca yang rapi. Nama pengarang, judul, penahkik, penerbit, dan angka halaman tidak boleh diisi berdasarkan perkiraan.

Dokumen menampilkan Naskah Tunggal sebagai kemungkinan nilai Jumlah Jilid. Istilah tersebut tidak cukup untuk menyimpulkan 1 jilid. Jika jumlahnya belum diketahui, tampilkan Jumlah jilid belum tersedia. Nilai Cetakan klasik juga bukan nama penahkik dan tidak boleh dipakai menggantikan identitas orang.

Filter tahun dalam master mempertahankan batas tanggal dari sumber. Label seperti Salaf, Mutaqaddimin, dan Mu'ashir tidak otomatis cocok untuk pembagian tahun lintas disiplin. Pengelompokan ilmiah yang tetap dipakai, misalnya Ashab al-Wujuh, memerlukan dasar dan keterangan tersendiri. Jangan menempatkannya sebagai kategori kronologis yang seolah setara dengan semua filter era tanpa meninjau model datanya.

Teks Arab kitab, ayat, hadis, nama pengarang, dan judul rujukan tidak diedit melalui normalisasi copy. Harakat pada kutipan juga tidak boleh ditambahkan diam-diam oleh AI lalu disebut teks asli. Jika sistem menyediakan perubahan harakat atau transliterasi, label hasilnya perlu menjelaskan bahwa itu merupakan olahan.

## 8. Kebijakan, penghapusan akun, dan layanan eksternal

Inventaris hanya memuat ringkasan butir kebijakan. Revisi pada bagian tersebut adalah draf bahasa, belum menjadi dokumen kebijakan lengkap atau hasil pemeriksaan kepatuhan hukum.

| Pernyataan dalam inventaris | Masalah yang ditemukan | Informasi yang perlu tersedia |
| --- | --- | --- |
| Catatan disimpan di perangkat | Belum diketahui ada atau tidaknya sinkronisasi dan cadangan | Lokasi penyimpanan, pengaruh keluar akun, dan perpindahan perangkat |
| Simpanan dihapus dari server | Tidak selaras dengan deskripsi penyimpanan lokal | Cakupan hapus di perangkat dan layanan aplikasi |
| Catatan aman dan terenkripsi | Mekanisme perlindungannya tidak dijelaskan | Perlindungan dalam pengiriman dan penyimpanan beserta cakupannya |
| Seluruh data dihapus kapan saja | Belum menjelaskan data transaksi atau data pada layanan lain | Jenis data yang dihapus, kemungkinan penyimpanan sementara, dan jangka waktu |
| Sesi memakai OAuth resmi | Tidak dibuktikan oleh inventaris | Cara masuk, izin yang diminta, dan cara sesi dipertahankan |
| Nomor WhatsApp untuk bukti aktivasi | Pengiriman pesan belum dibuktikan | Tujuan penggunaan nomor dan alur konfirmasi yang nyata |

Copy penghapusan harus menyebut dampak yang benar. Kalimat singkat Akun Anda akan dihapus secara permanen. Tindakan ini tidak dapat dibatalkan. adalah draf awal, lalu perlu dilengkapi dengan cakupan data yang telah diperiksa. Jika catatan tetap ada di perangkat atau percakapan berada pada akun Google, pengguna perlu diberi keterangan tersebut pada tempat yang relevan.

Pada halaman masuk, Ketentuan Layanan dan Kebijakan Privasi perlu tetap dapat dibuka. Pembedaan antara persetujuan atas ketentuan, pemberitahuan privasi, dan izin data harus mengikuti alur serta kebijakan yang benar. Audit ini tidak menganggap satu kalimat persetujuan sebagai bukti bahwa semua izin telah diperoleh.

Dialog kebijakan yang hanya dibuka untuk dibaca ulang cukup memakai Tutup. Tombol Setuju digunakan saat ada persetujuan yang memang diperlukan dan prosesnya benar-benar ditangani. Bagian draf yang masih memakai isian dalam kurung siku wajib dilengkapi sebelum tayang.

## 9. Penerapan pada kode dan pemeriksaan tampilan

Urutan berikut langsung mengikuti temuan yang masih memiliki risiko makna atau perilaku.

1. Cocokkan inventaris dengan versi kode aplikasi yang akan diubah. Gunakan nama berkas yang tercantum sebagai petunjuk, lalu temukan konstanta dan string di widget.
2. Tetapkan satu istilah untuk setiap objek. Pakai AppCopy pada layar yang mengulang Catatan, Percakapan, Asisten AI, atau Kitab rujukan.
3. Terapkan perubahan redaksional yang sudah jelas. Pertahankan ID seperti fiqh_syafii, ushul_fiqh, hadits, dan nahwu_sharaf agar perubahan label tidak merusak data.
4. Selesaikan kondisi salin, simpan, tutup percakapan, pembayaran, voucher, dan hapus akun. Sambungkan setiap pesan ke hasil operasi yang sesuai.
5. Ambil harga, cakupan, tanggal, versi, dan jumlah kitab dari data yang benar. Format tampilan Indonesia diterapkan setelah nilainya diperoleh.
6. Periksa teks Arab dan metadata bibliografis secara terpisah dari copy antarmuka. Hasil pencarian tidak boleh mengubah bentuk kutipan yang disimpan.
7. Lengkapi draf kebijakan berdasarkan aliran data aplikasi. Hilangkan semua isian editorial dari teks yang akan ditampilkan.
8. Tinjau hasil pada layar ponsel dengan teks besar dan judul asisten panjang, serta pada desktop. Periksa pemotongan label, dialog, arah tulisan Arab, dan nama kontrol untuk pembaca layar.
9. Periksa juga teks dari WebView, dialog sistem, layanan masuk, DOKU, notifikasi, dan jawaban AI. Teks milik layanan eksternal tidak selalu dapat diubah melalui AppCopy.

Jangan mengganti korpus menjadi kitab atau riset menjadi belajar secara menyeluruh di semua berkas. Kata yang sama dapat menjadi nama kelas, ID, konsep ilmiah, judul sumber, atau bagian kutipan. Penggantian perlu mengikuti konteks, dan peta JSON sengaja tidak menjadi skrip otomatis.

Pemeriksaan penerapan dianggap cukup ketika string yang dituju sudah terpasang, pesan penting sesuai hasil operasi, data dinamis benar, dan kontrol utama terbaca pada perangkat sasaran. Audit editorial ini tidak melakukan uji aplikasi tersebut karena lampiran saat ini hanya berupa inventaris Markdown.

## 10. Matriks lengkap teks lama dan pengganti

Setiap ID di bawah juga tersedia pada peta JSON. Kutipan pada kolom Teks lama dipertahankan sebagai bukti teks sumber, termasuk tanda tanya yang memang terdapat dalam salinan asal. Status siap secara redaksional berarti penggantinya telah diperiksa dari sisi bahasa. Status tersebut tidak membuktikan bahwa kode atau perilaku aplikasi sudah diuji.

### 1. Kamus Teks Kanonikal Terpusat (AppCopy)

| ID | Teks lama | Teks pengganti | Alasan dan status |
| --- | --- | --- | --- |
| COPY-001 | Beragam kajian dari kitab-kitab Islam. | Pelajari berbagai bidang ilmu melalui kitab-kitab Islam. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-002 | Gunakan jawaban sebagai pintu masuk untuk menelusuri ibarah. Untuk memahami dan menetapkan hukum, tetaplah merujuk kepada guru dan ulama yang berkompeten. | Gunakan jawaban AI untuk membantu menelusuri rujukan. Periksa kutipannya pada kitab asal dan mintalah bimbingan guru atau ulama saat mempelajari persoalan agama. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-004 | Membuka AI | Membuka percakapan… | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-005 | Pengaturan Tampilan & Baca | Tampilan bacaan | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-006 | Keterangan kitab | Detail kitab | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-007 | Menghubungkan AI dan Maktabah | Menyiapkan percakapan… | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-008 | sedang disiapkan. | sedang disiapkan. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-009 | Modul ini belum dapat dibuka. Coba lagi nanti. | Asisten ini belum tersedia. Coba lagi nanti. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-010 | Tidak dapat dimuat. Periksa koneksi, lalu coba lagi. | Konten belum bisa dimuat. Coba lagi. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-011 | AI belum dapat dibuka | Percakapan belum bisa dibuka | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-012 | Kajian belum bisa dimuat. Coba lagi sebentar. | Percakapan belum bisa dimuat. Coba lagi sebentar. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-013 | Langganan diperlukan | Pilih paket untuk melanjutkan | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-014 | Tanyakan sesuatu tentang kitab ini... | Tulis pertanyaan tentang kitab ini | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-015 | Lihat langganan | Lihat paket | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-016 | Tidak dapat terhubung | Belum bisa terhubung | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-017 | Tidak dapat terhubung ke layanan OpenTurath. Periksa koneksi, lalu coba lagi. | OpenTurath belum bisa terhubung. Periksa koneksi internet, lalu coba lagi. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-018 | Saya mengerti | Mengerti | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-019 | Perkakas Telaah & Komparasi Naskah | Bantuan untuk membaca kitab | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-020 | OpenTurath membantu mencari ibarah dan membandingkan keterangan dalam kitab. Setiap kutipan dan ibarah perlu dicocokkan dengan sumber aslinya di Maktabah Syamilah atau naskah cetak fisik. | OpenTurath membantu mencari ibarah, yaitu kutipan teks dari kitab, dan membandingkan penjelasannya. Jawaban AI bisa keliru. Cocokkan kutipan dengan kitab asal di Maktabah Syamilah atau edisi cetaknya. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-021 | Untuk memahami agama dengan baik, belajarlah kepada guru dan ulama yang berkompeten. | Pelajari persoalan agama bersama guru atau ulama yang memahami bidangnya. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-022 | Periksa kembali dalil dan ibarah pada kitab rujukan sebelum menjadikannya pegangan. | Baca konteks pembahasan dalam kitab sebelum menggunakan atau membagikan jawaban. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-023 | Gagal menyalin. Coba lagi. | Belum bisa menyalin. Coba lagi. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-024 | Tersimpan ke Catatan. | Tersimpan di Catatan. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-025 | Gagal menyimpan. Coba lagi. | Belum bisa menyimpan. Coba lagi. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-026 | Cari catatan, topik, atau kutipan... | Cari catatan, topik, atau kutipan | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-027 | Simpan telaah atau ibarah ke dalam catatan riset Anda. | Simpan jawaban, kutipan, atau rujukan kitab di sini. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-028 | Belum berlangganan. Akses dibuka dengan voucher atau paket. | Pilih paket atau gunakan voucher untuk mengakses asisten AI. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-030 | Keluar dari akun? | Keluar dari akun | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-031 | Hapus akun? | Hapus akun | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-032 | Untuk menghapus akun, masuk ulang terlebih dahulu. | Masuk kembali untuk melanjutkan penghapusan akun. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-033 | Koneksi bermasalah. Coba lagi. | Koneksi internet bermasalah. Coba lagi. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-034 | Jawaban disalin dan disimpan ke Catatan Riset. | Jawaban disalin dan disimpan di Catatan. | Hanya tampil setelah salin dan simpan sama-sama berhasil. Sediakan status terpisah untuk hasil sebagian. Status: perlu pemeriksaan perilaku. |
| COPY-035 | Tindakan ini tidak dapat dibatalkan. Profil, simpanan, dan data akun Anda akan dihapus dari server. | Akun Anda akan dihapus secara permanen. Tindakan ini tidak dapat dibatalkan. | Draf ringkas. Tambahkan cakupan data yang benar-benar terhapus dan yang tetap tersimpan setelah alur penghapusan diperiksa. Dokumen menyebut catatan lokal sekaligus penghapusan simpanan dari server. Status: perlu pemeriksaan perilaku. |

### 2. Data Master Asisten AI, Disiplin Ilmu & Literatur (Models)

| ID | Teks lama | Teks pengganti | Alasan dan status |
| --- | --- | --- | --- |
| COPY-036 | Manhaj eskatologi Islam, rukun keempat, tanda-tanda zaman, dan sanad Al-Habib Abu Bakar Al-Masyhur. | Pembahasan perubahan zaman dan tanda-tanda akhir zaman dalam pemikiran Habib Abu Bakar al-Masyhur. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-037 | Hukum ibadah, muamalah, fatwa, dan perbandingan mazhab mu'tabar. | Pelajari hukum ibadah, muamalah, fatwa, dan perbedaan pendapat antarmazhab. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-038 | Takhrij sanad, dirayah perawi, dan syarah Kutubus Sittah. | Telusuri sumber hadis, keterangan tentang perawi, dan penjelasan ulama dalam Kutubus Sittah. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-039 | Asbabun nuzul, munasabah, dan khazanah tafsir bil-ma'tsur wal-ra'yi. | Pelajari penafsiran Al-Qur'an, sebab turunnya ayat, dan hubungan antarayat. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-040 | Kalam Asy'ariyyah, Maturidiyyah, pembelaan ushuludin, dan dalil aqli-naqli. | Pelajari akidah Asy'ariyyah dan Maturidiyyah beserta dalil dan penjelasannya. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-041 | Kaidah istinbath hukum, dalil ijmali, maqashid syariah, dan qawaid fiqhiyyah. | Pelajari cara ulama menggali hukum, memahami dalil, serta membahas tujuan syariat dan kaidah fikih. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-042 | Nahwu, sharaf, balaghah, dan leksikografi kamus mu'jam klasik. | Pelajari nahwu, saraf, balagah, dan kosakata dalam kamus Arab klasik. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-043 | Sirah Nabawiyyah, khulafaur rasyidin, thabaqat ulama, dan peradaban Islam. | Telusuri kehidupan Nabi, Khulafaur Rasyidin, biografi ulama, dan sejarah peradaban Islam. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-044 | Penyucian jiwa (tazkiyatun nafs), adab suluk, dan hikmah ulama salafush shalih. | Pelajari penyucian jiwa, adab, akhlak, dan nasihat para ulama. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-045 | Membantu menelusuri pembahasan Fikih Tahawwulat dari kitab dan muhadharah Habib Abu Bakar al-Masyhur. | Telusuri pembahasan Fikih Tahawwulat dalam kitab dan ceramah Habib Abu Bakar al-Masyhur. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-046 | Manhaj Abu Bakr al-Masyhur | Pemikiran Habib Abu Bakar al-Masyhur | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-047 | Matan · Syarah · Hasyiyah Mu'tabarah | Matan · Syarah · Hasyiyah | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-048 | Bantuan untuk mencari keterangan dalam kitab-kitab mazhab Syafi'i. | Temukan penjelasan fikih dalam kitab-kitab mazhab Syafi'i. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-049 | Membantu menelusuri sanad, matan, derajat hadits, dan syarah para ulama ahli hadits. | Telusuri teks hadis, sanad, penilaian derajat hadis, dan penjelasan para ulama. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-050 | Tafsir bil Ma'tsur & bil Ra'yi | Tafsir ayat dan ilmu tafsir | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-051 | Membantu menelaah tafsir ayat Al-Qur'an, asbabun nuzul, qira'at, dan kaidah tafsir. | Pelajari tafsir ayat Al-Qur'an, sebab turunnya ayat, ragam bacaan, dan kaidah tafsir. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-052 | Risalah · Jam'ul Jawami' · Mustashfa | Dalil · Kaidah · Metode penetapan hukum | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-053 | Menelaah kaidah istinbath, dalil ijmali, qawaid fiqhiyyah, dan metodologi ushuliyyah. | Pelajari cara ulama memahami dalil dan menggali hukum, beserta kaidah usul fikih dan kaidah fikih. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-054 | Nahwu · Sharaf · Balaghah · Ma'ajim | Nahwu · Saraf · Balagah · Kamus | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-055 | Bantuan menelaah sintaksis (i'rab), morfologi (sharaf), balaghah, dan leksikon bahasa Arab turats. | Pelajari susunan kalimat, perubahan bentuk kata, gaya bahasa, dan kosakata dalam kitab berbahasa Arab. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-056 | Membantu menemukan dalil, ibarah, dan rujukan yang relevan. | Telusuri dalil, ibarah, dan sumber rujukannya. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-057 | Menjelaskan pokok bahasan dengan bahasa yang lebih ringkas. | Membantu memahami pokok bahasan melalui penjelasan yang lebih sederhana. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-058 | Membantu menemukan dalil, ibarah, dan rujukan dalam mazhab Syafi'i. | Telusuri dalil, ibarah, dan rujukan dalam mazhab Syafi'i. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-059 | Spesialis penelusuran riwayat, takhrij sanad, dan syarah hadits. | Membantu menelusuri sumber riwayat dan penjelasan ulama tentang hadis. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-060 | Penelaah ayat Al-Qur'an berbasis rujukan tafsir mu'tabar. | Membantu memahami penjelasan ayat Al-Qur'an dalam kitab tafsir. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-061 | Spesialis metodologi dalil, kaidah ushuliyyah, dan qawa'id fiqhiyyah. | Membantu mempelajari dalil, kaidah usul fikih, dan kaidah fikih. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-062 | Spesialis i'rab kalimat, timbangan sharaf, dan uslub balaghah. | Membantu memahami susunan kalimat, pola perubahan kata, dan gaya bahasa Arab. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-063 | Bagaimana penjelasan al-ghutsā'iyyah dalam kitab? | Jelaskan makna al-ghutsā'iyyah berdasarkan kitab rujukan. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-064 | Apa yang dimaksud Rukun Keempat dalam Fikih Tahawwulat? | Jelaskan istilah Rukun Keempat dalam Fikih Tahawwulat menurut Habib Abu Bakar al-Masyhur. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-065 | Bagaimana para ulama menjelaskan sikap saat masa fitnah? | Telusuri penjelasan ulama tentang sikap menghadapi masa fitnah. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-066 | Apa rukun wudu menurut pendapat mu'tamad dalam mazhab Syafi'i? | Jelaskan rukun wudu menurut pendapat mu'tamad dalam mazhab Syafi'i dan sertakan rujukannya. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-067 | Apa syarat sah salat berjamaah menurut Minhāj al-Ṭālibīn? | Jelaskan syarat sah salat berjamaah dalam Minhāj al-Ṭālibīn. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-068 | Bagaimana ketentuan zakat perdagangan menurut Imam al-Nawawi? | Telusuri ketentuan zakat perdagangan menurut Imam al-Nawawi. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-069 | Bagaimana takhrij hadits innamal a'malu bin niyyat dalam Kutubus Sittah? | Telusuri sumber hadis innamal a'malu bin niyyat dalam Kutubus Sittah. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-070 | Bagaimana syarah Ibnu Hajar terhadap hadits niat dalam Fathul Bari? | Jelaskan uraian Ibnu Hajar tentang hadis niat dalam Fathul Bari. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-071 | Apa saja hadits mutawatir tentang larangan berdusta atas nama Rasulullah? | Telusuri hadis tentang larangan berdusta atas nama Rasulullah dan penilaian ulama terhadap riwayatnya. | Tidak mengarahkan keluaran untuk menetapkan derajat hadis sejak awal. Minta penilaian ulama dan rujukannya. Status: siap secara redaksional. |
| COPY-072 | Apa asbabun nuzul surah Al-Baqarah ayat 183 tentang kewajiban puasa? | Telusuri keterangan tentang sebab turunnya Surah Al-Baqarah ayat 183. Jika tidak ditemukan riwayat yang mendukung, sampaikan keterbatasannya. | Mencegah anggapan bahwa riwayat sebab turun tertentu pasti tersedia. Audit ini tidak menetapkan ada atau tidaknya riwayat tersebut. Status: siap secara redaksional. |
| COPY-073 | Bagaimana penjelasan Thabari dan Ibnu Katsir mengenai ayat kursi? | Bandingkan penjelasan Thabari dan Ibnu Katsir tentang Ayat Kursi. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-074 | Apa penafsiran ulama tentang makna lafadz hikmah dalam Al-Qur'an? | Jelaskan penafsiran ulama tentang kata hikmah dalam Al-Qur'an, disertai ayat dan rujukannya. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-075 | Apa perbedaan muthlaq dan 'amm serta implikasinya dalam istinbath hukum? | Jelaskan perbedaan muthlaq dan 'amm beserta pengaruhnya dalam penetapan hukum. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-076 | Bagaimana kaidah al-ashlu fil amri lil wujub menurut ulama ushul? | Jelaskan kaidah al-ashlu fil amri lil wujub menurut ulama usul fikih. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-077 | Apa saja rukun qiyas dan contoh penerapannya dalam kasus kontemporer? | Uraikan rukun qiyas dan contoh penerapannya dalam persoalan masa kini berdasarkan rujukan. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-078 | Jelaskan i'rab bismillahirrahmanirrahim secara terperinci! | Jelaskan i'rab bismillahirrahmanirrahim kata demi kata. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-079 | Apa wazan dan makna fa'ala, taf'il, dan istif'al dalam kaidah sharaf? | Bandingkan bentuk dan makna fa'ala, taf'il, dan istif'al berdasarkan kaidah saraf. | Tidak menyamakan semua bentuk sebagai kategori morfologi yang identik. Minta perbandingan bentuk dan makna dengan rujukan. Status: siap secara redaksional. |
| COPY-080 | Apa rahasia balaghah taqdim dan ta'khir dalam surah Al-Fatihah? | Jelaskan taqdim dan ta'khir beserta contoh yang didukung rujukan dalam Surah Al-Fatihah. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-081 | Fikih Mazhab Hanafi dengan rujukan Al-Mabsuth, Radd Al-Muhtar, dan Hidayah Al-Marghinani. | Pelajari fikih mazhab Hanafi melalui Al-Mabsuth, Radd Al-Muhtar, dan Hidayah Al-Marghinani. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-082 | Fikih Mazhab Maliki berbasis naskah Al-Mudawwanah, Mukhtashar Khalil, dan Al-Qawanin Al-Fiqhiyyah. | Pelajari fikih mazhab Maliki melalui Al-Mudawwanah, Mukhtashar Khalil, dan Al-Qawanin Al-Fiqhiyyah. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-083 | Fikih Mazhab Hanbali merujuk Al-Mughni, Al-Inshaf, dan Zad Al-Mustaqni'. | Pelajari fikih mazhab Hanbali melalui Al-Mughni, Al-Inshaf, dan Zad Al-Mustaqni'. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-084 | Komparasi dalil dan pandangan 4 mazhab mu'tabar (Hanafi, Maliki, Syafi'i, Hanbali). | Bandingkan pendapat dan dalil dalam mazhab Hanafi, Maliki, Syafi'i, dan Hanbali. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-085 | Kajian teologi Islam Asy'ariyyah, Maturidiyyah, dalil aqli-naqli, dan bantahan syubhat. | Pelajari akidah Asy'ariyyah dan Maturidiyyah, beserta dalil dan penjelasan atas persoalan yang dibahas. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-086 | Sirah Nabawiyyah, khulafaur rasyidin, tarikh daulah Islam, dan thabaqat ulama. | Telusuri kehidupan Nabi, Khulafaur Rasyidin, sejarah pemerintahan Islam, dan biografi ulama. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-087 | Kumpulan fatwa, khutbah, risalah, dan arahan dakwah Al-Habib Umar bin Hafizh. | Telusuri fatwa, khutbah, tulisan, dan nasihat dakwah Habib Umar bin Hafizh. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-088 | Khazanah pemikiran tasawuf, akhlaq, ushul, dan karya agung Ihya Ulumiddin. | Pelajari pemikiran Imam al-Ghazali tentang tasawuf, akhlak, dan usul fikih, termasuk dalam Ihya Ulumiddin. | Deskripsi mengutamakan kegiatan pembaca. Istilah khusus dipertahankan saat menjadi pokok bahasan, dengan atribusi dan permintaan rujukan yang lebih jelas. Status: siap secara redaksional. |
| COPY-089 | Hadits | Hadis | Ejaan tampilan konsisten. Nama kajian tokoh memperjelas bahwa asisten menelusuri karya, bukan mewakili tokoh. ID internal dan judul bibliografis tidak diubah. Status: siap secara redaksional. |
| COPY-090 | Aqidah | Akidah | Ejaan tampilan konsisten. Nama kajian tokoh memperjelas bahwa asisten menelusuri karya, bukan mewakili tokoh. ID internal dan judul bibliografis tidak diubah. Status: siap secara redaksional. |
| COPY-091 | Usul Fiqh | Usul Fikih | Ejaan tampilan konsisten. Nama kajian tokoh memperjelas bahwa asisten menelusuri karya, bukan mewakili tokoh. ID internal dan judul bibliografis tidak diubah. Status: siap secara redaksional. |
| COPY-093 | AI Ushul Fiqih | AI Usul Fikih | Ejaan tampilan konsisten. Nama kajian tokoh memperjelas bahwa asisten menelusuri karya, bukan mewakili tokoh. ID internal dan judul bibliografis tidak diubah. Status: siap secara redaksional. |
| COPY-094 | AI Hadits & Syarah Sunnah | AI Hadis dan Syarah | Ejaan tampilan konsisten. Nama kajian tokoh memperjelas bahwa asisten menelusuri karya, bukan mewakili tokoh. ID internal dan judul bibliografis tidak diubah. Status: siap secara redaksional. |
| COPY-095 | AI Bahasa Arab & Balaghah | AI Bahasa Arab dan Balagah | Ejaan tampilan konsisten. Nama kajian tokoh memperjelas bahwa asisten menelusuri karya, bukan mewakili tokoh. ID internal dan judul bibliografis tidak diubah. Status: siap secara redaksional. |
| COPY-096 | Sejarah & Sirah | Sejarah dan Sirah | Ejaan tampilan konsisten. Nama kajian tokoh memperjelas bahwa asisten menelusuri karya, bukan mewakili tokoh. ID internal dan judul bibliografis tidak diubah. Status: siap secara redaksional. |
| COPY-097 | Tasawuf & Akhlaq | Tasawuf dan Akhlak | Ejaan tampilan konsisten. Nama kajian tokoh memperjelas bahwa asisten menelusuri karya, bukan mewakili tokoh. ID internal dan judul bibliografis tidak diubah. Status: siap secara redaksional. |
| COPY-098 | AI Aqidah & Ilmu Kalam | AI Akidah dan Ilmu Kalam | Ejaan tampilan konsisten. Nama kajian tokoh memperjelas bahwa asisten menelusuri karya, bukan mewakili tokoh. ID internal dan judul bibliografis tidak diubah. Status: siap secara redaksional. |
| COPY-099 | AI Sejarah & Sirah | AI Sejarah dan Sirah | Ejaan tampilan konsisten. Nama kajian tokoh memperjelas bahwa asisten menelusuri karya, bukan mewakili tokoh. ID internal dan judul bibliografis tidak diubah. Status: siap secara redaksional. |
| COPY-100 | AI Habib Umar bin Hafizh | AI Kajian Habib Umar bin Hafizh | Ejaan tampilan konsisten. Nama kajian tokoh memperjelas bahwa asisten menelusuri karya, bukan mewakili tokoh. ID internal dan judul bibliografis tidak diubah. Status: siap secara redaksional. |
| COPY-101 | AI Hujjatul Islam Al-Ghazali | AI Kajian Imam al-Ghazali | Ejaan tampilan konsisten. Nama kajian tokoh memperjelas bahwa asisten menelusuri karya, bukan mewakili tokoh. ID internal dan judul bibliografis tidak diubah. Status: siap secara redaksional. |
| COPY-145 | Segera Hadir | Dalam persiapan | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-229 | Rp 49.000 | Rp49.000 | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-230 | Rp 299.000 | Rp299.000 | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-231 | Rp 499.000 | Rp499.000 | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |

### 3. Layar Masuk & Autentikasi (Login & Session Auth)

| ID | Teks lama | Teks pengganti | Alasan dan status |
| --- | --- | --- | --- |
| COPY-102 | AI for Islamic Scholarship | Asisten AI untuk membaca dan mempelajari kitab. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-104 | Tidak dapat membuka tautan halaman. | Tautan belum bisa dibuka. Coba lagi. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-105 | Koneksi internet bermasalah. Periksa jaringan Anda. | Koneksi internet bermasalah. Periksa koneksi, lalu coba lagi. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-106 | Gagal masuk akun Google. Silakan coba kembali. | Belum bisa masuk dengan Google. Coba lagi. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-107 | Menyiapkan Sesi Riset | Menyiapkan percakapan | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-108 | Menghubungkan akun Google Anda dengan ekosistem NotebookLM OpenTurath. | Gunakan akun Google untuk melanjutkan ke percakapan di NotebookLM. | Tetap menyebut NotebookLM karena menjelaskan layanan yang digunakan pengguna. Hindari klaim integrasi resmi yang tidak dibuktikan. Status: perlu pemeriksaan perilaku. |
| COPY-109 | Memverifikasi kredensial Google Cloud... | Memeriksa akun Google… | Menghapus diagnosis teknis yang tidak terbukti. Status ini hanya cocok bila proses memang memeriksa akun. Status: perlu pemeriksaan perilaku. |
| COPY-110 | Buka Ruang Riset | Buka percakapan | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-111 | Kembali ke Masuk | Kembali | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |

### 4. Layar Beranda / Dashboard Utama

| ID | Teks lama | Teks pengganti | Alasan dan status |
| --- | --- | --- | --- |
| COPY-112 | Ahlan, Peneliti Turats | Ahlan | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-113 | Cari spesialis, bab fikih, atau kitab... | Cari asisten atau kitab | Dokumen belum membuktikan pencarian tingkat bab. Varian utama hanya menyebut asisten dan kitab. Sesuaikan dengan indeks yang benar-benar dicari. Status: perlu pemeriksaan perilaku. |
| COPY-114 | Hasil Penelusuran | Hasil pencarian | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-115 | Tidak ditemukan naskah atau spesialis yang sesuai. | Asisten atau kitab belum ditemukan. Coba kata kunci lain. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-116 | Pilih Bidang Ilmu | Pilih bidang ilmu | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-117 | Lihat Semua | Lihat semua | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-118 | TENTANG OPENTURATH | Tentang OpenTurath | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-119 | Mengenal OpenTurath AI | Mengenal OpenTurath | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-120 | Penelaahan ibarat dan rujukan langsung dari naskah primer turats. | Temukan penjelasan dan rujukan untuk membantu membaca kitab. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-121 | Gunakan OpenTurath untuk mencari rujukan dan membandingkan matan dengan syarah. Periksa hasilnya pada kitab asal, lalu diskusikan dengan guru dan ulama yang berkompeten. | Gunakan OpenTurath untuk mencari rujukan dan membandingkan penjelasan dalam kitab. Cocokkan hasilnya dengan sumber asal, lalu pelajari bagian yang belum jelas bersama guru. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-122 | ADAB TALAQQI | Adab belajar | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-123 | Wasilah Bantu, Bukan Pengganti Guru | Tetap belajar bersama guru | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-124 | Kajian agama hakiki wajib melalui bimbingan guru dan ulama bersanad. | Bimbingan guru membantu Anda memahami konteks dan maksud pembahasan. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-125 | PENTING DIPAHAMI: ↵  ↵ Kecerdasan buatan hanyalah perkakas indeksasi dan komparasi literatur ilmiah untuk mempercepat pencarian teks dan matan. Pemahaman fikih dan fatwa tetap membutuhkan bimbingan guru dan ulama yang bersanad. | OpenTurath membantu mencari teks dan membandingkan penjelasan dalam kitab. Untuk memahami persoalan agama dan pembahasan fatwa, tetaplah belajar bersama guru atau ulama yang memahami bidangnya. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-126 | IHTIYATH | Periksa sumber | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-127 | Verifikasi Naskah Primer | Cocokkan dengan kitab asal | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-128 | Selalu luangkan waktu memeriksa naskah Maktabah Syamilah atau cetak fisik. | Periksa kutipan pada kitab asal di Maktabah Syamilah atau edisi cetaknya. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-129 | Sikap wara' dan kehati-hatian (ihtiyath) menuntut peneliti untuk meninjau langsung naskah fisik primer sebelum menyimpulkan dan menyebarluaskan hasil kajian ke khalayak. | AI bisa keliru mengutip atau memahami teks. Baca bagian sebelum dan sesudah kutipan pada kitab asal sebelum menyimpulkan atau membagikannya. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-130 | AMANAH ILMIAH | Amanah ilmiah | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-131 | Ketepatan Sitasi Turats | Cantumkan rujukan dengan jelas | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-132 | Sertakan nama muallif, kitab, bab, dan nomor halaman dalam menukil ibarah. | Saat mengutip, sertakan nama pengarang, judul kitab, serta jilid dan halaman jika tersedia. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-133 | Dalam tradisi keilmuan Islam, amanah ilmiah dijaga dengan menyertakan rujukan yang sahih: judul kitab asli, nama pengarang, bab pembahasan, serta nomor jilid dan halaman. | Cantumkan pengarang, judul kitab, edisi, serta jilid dan halaman sesuai sumber yang digunakan. Jika ada data yang belum tersedia, lengkapi dari kitab asal sebelum memakai kutipan untuk keperluan akademik. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-134 | SANAD & TAKHRIJ | Telusuri rujukan | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-135 | Penelusuran Rujukan Ilmiah | Lihat sumber kutipan | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-136 | Dilengkapi kutipan ibarat teks asli dan penomoran jilid dari kitab muktamad. | Gunakan informasi rujukan yang tersedia untuk menelusuri asal kutipan. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-137 | Setiap rujukan yang ditampilkan mengacu langsung ke naskah turats, memudahkan santri dan peneliti meninjau matan dan syarah secara tertib dan presisi. | Buka informasi rujukan untuk melihat asal kutipan. Cocokkan judul, edisi, jilid, dan halaman dengan kitab yang Anda gunakan. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-138 | Baca Selengkapnya | Baca selengkapnya | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-139 | Mengerti & Tutup | Tutup | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |

### 5. Layar Eksplorasi Spesialis AI (Specialist List)

| ID | Teks lama | Teks pengganti | Alasan dan status |
| --- | --- | --- | --- |
| COPY-140 | Khazanah asisten riset naskah primer turats | Pilih asisten sesuai bidang ilmu atau karya ulama yang ingin Anda pelajari. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-141 | Berdasarkan Disiplin Ilmu | Bidang ilmu | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-142 | Berdasarkan Tokoh Ulama | Tokoh ulama | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-143 | Semua Bidang | Semua bidang | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-144 | Buka AI | Buka asisten | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-146 | ${agent.title} sedang dalam tahap kurasi naskah kitab primer (Segera Hadir). | ${agent.title} sedang disiapkan dan belum bisa dibuka. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-147 | Belum ada spesialis pada kategori ini. | Belum ada asisten dalam kategori ini. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |

### 6. Layar Ruang Percakapan AI / Webview & Multi-Tab

| ID | Teks lama | Teks pengganti | Alasan dan status |
| --- | --- | --- | --- |
| COPY-148 | Buka AI Lain | Buka asisten lain | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-149 | Tutup Percakapan AI? | Tutup percakapan | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-150 | Tutup Percakapan | Tutup percakapan | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-151 | Katalog Kitab Rujukan | Kitab rujukan | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-152 | Menghubungkan AI dan Maktabah... | Menyiapkan percakapan… | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-153 | Ekstra Besar (130%) | Sangat besar (130%) | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-154 | Kanan ke Kiri (RTL) | Kanan ke kiri | Arah tulisan dan perataan adalah kontrol berbeda. Label ini harus berada dalam pengaturan arah teks, bukan pilihan perataan. Status: perlu pemeriksaan perilaku. |
| COPY-155 | Justified / Rata Kanan-Kiri | Rata kanan-kiri | Gunakan untuk perataan. Jangan ditempatkan sebagai alternatif langsung terhadap arah RTL. Status: perlu pemeriksaan perilaku. |
| COPY-156 | Terapkan Pengaturan | Terapkan | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-157 | Navigasi ke situs eksternal dibatasi demi keamanan sesi riset. | Tautan ini tidak bisa dibuka dari percakapan. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-197 | Sesi percakapan akan diakhiri. Catatan yang belum disimpan ke catatan riset akan tertutup. | Percakapan ini akan ditutup. Simpan bagian yang ingin Anda baca kembali ke Catatan sebelum melanjutkan. | Menjelaskan tindakan menutup tanpa menyatakan riwayat pasti hilang. Periksa apakah ada draf yang hilang atau percakapan yang benar-benar diakhiri. Status: perlu pemeriksaan perilaku. |
| COPY-198 | Jawaban belum tersimpan. Coba salin lagi. | Jawaban belum bisa disalin. Coba lagi. | Gunakan hanya untuk kegagalan salin. Kegagalan simpan setelah salin berhasil membutuhkan pesan lain. Status: perlu pemeriksaan perilaku. |

### 7. Katalog Naskah Kanonikal 2.226 Kitab (Katalog & Detail Kitab)

| ID | Teks lama | Teks pengganti | Alasan dan status |
| --- | --- | --- | --- |
| COPY-158 | Daftar Kitab Rujukan | Kitab rujukan | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-159 | 87 Kitab Mazhab Syafi'i | 87 kitab fikih Syafi'i | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-160 | 1.173 Kitab AI Hadits & Syarah Sunnah | 1.173 kitab hadis dan syarah | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-161 | 241 Kitab AI Ushul Fiqih | 241 kitab usul fikih | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-162 | 449 Kitab AI Bahasa Arab & Balaghah | 449 kitab bahasa Arab dan balagah | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-163 | 218 Kitab AI Tafsir Al-Qur'an | 218 kitab tafsir Al-Qur'an | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-164 | 58 Kitab AI Fikih Tahawwulat | 58 kitab Fikih Tahawwulat | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-165 | Cari judul Arab/Latin, pengarang, muhaqqiq... | Cari judul kitab, pengarang, atau penahkik | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-166 | Semua Bagian | Semua kategori | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-167 | Semua Era | Semua periode | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-168 | Ashab Al-Wujuh | Ashab al-Wujuh | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-169 | Salaf (≤ 300 H) | Hingga 300 H | Mempertahankan batas tahun dari data, tanpa mengklaim pembagian generasi keilmuan berlaku universal. Status: siap secara redaksional. |
| COPY-170 | Mutaqaddimin (301-600 H) | 301–600 H | Mempertahankan batas tahun. Definisi mutaqaddimin berbeda menurut disiplin dan tidak ditetapkan lewat label tanggal ini. Status: siap secara redaksional. |
| COPY-171 | Muta'akhkhirin (601-1100 H) | 601–1100 H | Mempertahankan batas tahun tanpa memberikan klasifikasi ilmiah baru. Status: siap secara redaksional. |
| COPY-172 | Mu'ashir (> 1100 H) | Setelah 1100 H | Setelah 1100 H tidak dengan sendirinya berarti kontemporer. Label tahun lebih tepat untuk filter kronologis ini. Status: siap secara redaksional. |
| COPY-173 | Menampilkan X dari Y naskah | Menampilkan X dari Y kitab | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-174 | Reset | Hapus filter | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-175 | Tidak ditemukan kitab yang sesuai. | Kitab belum ditemukan | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-176 | Coba gunakan kata kunci judul Arab, nama pengarang, atau muhaqqiq. | Coba judul dalam huruf Arab atau Latin, nama pengarang, atau penahkik. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-177 | Hapus Semua Filter | Hapus filter | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-178 | Simpan Rujukan | Simpan rujukan | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-179 | Hapus Rujukan | Hapus dari Catatan | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-180 | Salin Sitasi Standar | Salin rujukan | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-181 | المختصر: [Nama Pendek] | Judul singkat: [Nama Pendek] | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-182 | MUALLIF / PENGARANG | Pengarang | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-183 | Wafat: [Tahun] Hijriyah | Wafat: [Tahun] H | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-184 | Wafat: Dalam verifikasi sanad | Tahun wafat belum tersedia | Tahun wafat yang belum tersedia bukan verifikasi sanad. Jangan mengaku sedang memeriksa bila tidak ada proses pemeriksaan. Status: siap secara redaksional. |
| COPY-185 | KLASIFIKASI ILMIAH | Jenis dan periode kitab | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-186 | Tipe Naskah | Jenis kitab | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-187 | Era Keilmuan | Periode | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-188 | Jumlah Jilid | Jumlah jilid | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-189 | Derajat Mu'tabar | Kedudukan dalam mazhab | Jangan jadikan kedudukan mazhab sebagai skor kualitas otomatis. Tampilkan hanya beserta keterangan dan dasar rujukan yang dapat diperiksa. Status: perlu pemeriksaan data. |
| COPY-190 | DATA EDISI & TAHQIQ | Edisi dan tahkik | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-191 | Penerbit Rujukan | Penerbit | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-192 | Pentahqiq / Muhaqqiq | Penahkik | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-193 | Tahun / Edisi Cetak | Tahun atau edisi cetak | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-194 | Sitasi standar ilmiah tersalin ke papan klip. | Rujukan disalin. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-195 | Kitab disimpan ke Catatan Riset. | Rujukan kitab disimpan di Catatan. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-196 | Rujukan dihapus dari Catatan Riset. | Rujukan dihapus dari Catatan. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-199 | [Pengarang] (w. [Tahun] H). [Judul Kitab], [Jumlah Jilid] Jilid, [Muhaqqiq], Penerbit: [Penerbit], Th. [Tahun Cetak]. OpenTurath AI Canonical Corpus. | [Pengarang]. [Judul Kitab]. Tahkik: [Muhaqqiq]. [Penerbit], [Tahun Cetak]. [Jumlah Jilid] jilid. | Template identitas kitab, bukan kutipan halaman atau format standar universal. Hilangkan segmen kosong, jangan mengarang data. Tahun wafat tidak disamakan dengan tahun terbit. Perlu template lain untuk jilid dan halaman tertentu. Status: perlu pemeriksaan data. |
| COPY-308 | النحو والصرف | Nahwu dan saraf · النحو والصرف | Label Indonesia membantu pemindaian katalog. Istilah Arab kategori tetap disertakan. Nilai filter di data tidak diubah. Status: siap secara redaksional. |
| COPY-309 | البلاغة | Balagah · البلاغة | Label Indonesia membantu pemindaian katalog. Istilah Arab kategori tetap disertakan. Nilai filter di data tidak diubah. Status: siap secara redaksional. |
| COPY-310 | الغريب والمعاجم | Kosakata sulit dan kamus · الغريب والمعاجم | Label Indonesia membantu pemindaian katalog. Istilah Arab kategori tetap disertakan. Nilai filter di data tidak diubah. Status: siap secara redaksional. |
| COPY-311 | كتب اللغة | Ilmu bahasa · كتب اللغة | Label Indonesia membantu pemindaian katalog. Istilah Arab kategori tetap disertakan. Nilai filter di data tidak diubah. Status: siap secara redaksional. |
| COPY-312 | Asal Mazhab | Rujukan dasar mazhab | Label Indonesia membantu pemindaian katalog. Istilah Arab kategori tetap disertakan. Nilai filter di data tidak diubah. Status: siap secara redaksional. |

### 8. Layar Catatan Riset, Simpanan & Editor Catatan (Bookmark & Notes)

| ID | Teks lama | Teks pengganti | Alasan dan status |
| --- | --- | --- | --- |
| COPY-092 | Usul Fiqih | Usul Fikih | Ejaan tampilan konsisten. Nama kajian tokoh memperjelas bahwa asisten menelusuri karya, bukan mewakili tokoh. ID internal dan judul bibliografis tidak diubah. Status: siap secara redaksional. |
| COPY-201 | Tambah Catatan Baru | Buat catatan | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-202 | Kutipan Ibarah | Ibarah | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-203 | Rujukan Kitab | Rujukan kitab | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-205 | Hapus Catatan | Hapus catatan | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-206 | Buka kajian | Pilih asisten | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-207 | Hapus Catatan Riset? | Hapus catatan | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-208 | Catatan riset telah dihapus. | Catatan dihapus. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-209 | Edit Catatan | Ubah catatan | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-210 | Catatan Baru | Catatan baru | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-211 | Judul Catatan... | Judul catatan | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-212 | Tulis atau edit telaah, ibarat naskah, dan catatan riset... | Tulis catatan atau tempel kutipan di sini | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-213 | Daftar Poin | Daftar poin | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-214 | Kutipan Arab | Kutipan Arab | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-215 | Judul Bab | Judul bagian | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-216 | Sub-bab | Subjudul | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-217 | Nama kitab rujukan... | Judul kitab | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-218 | Jilid/Hal... | Contoh: jilid 2, halaman 45 | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-219 | Simpan Perubahan | Simpan perubahan | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-220 | Simpan Catatan | Simpan catatan | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-221 | Catatan riset berhasil disimpan. | Catatan disimpan. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-222 | Catatan ini akan dihapus secara permanen dari penyimpanan perangkat Anda. | Catatan ini akan dihapus dari perangkat ini dan tidak dapat dipulihkan. | Sesuai penyimpanan lokal yang disebut dokumen. Ganti jika catatan tersinkron, ada cadangan, atau fitur pemulihan. Status: perlu pemeriksaan perilaku. |
| COPY-223 | Judul atau isi catatan tidak boleh kosong. | Isi judul atau tulis catatan terlebih dahulu. | Varian ini hanya untuk aturan minimal salah satu kolom terisi. Jika keduanya wajib, gunakan pesan per kolom. Status: perlu pemeriksaan perilaku. |

### 9. Layar Langganan, Paket Riset & Checkout DOKU

| ID | Teks lama | Teks pengganti | Alasan dan status |
| --- | --- | --- | --- |
| COPY-224 | Langganan & Akses AI | Langganan | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-226 | Langganan Aktif | Langganan aktif | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-227 | Belum Berlangganan | Belum berlangganan | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-228 | Akses penuh dibuka dengan paket atau voucher. | Pilih paket atau gunakan voucher untuk mengakses asisten AI. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-232 | Akses riset intensif modul terpilih selama 30 hari penuh. | Akses asisten yang dipilih selama 30 hari. | Dokumen menyebut 30 hari dan nama paket 1 bulan. Pastikan durasi efektif, tanggal mulai, dan asisten yang tercakup sebelum ditayangkan. Status: perlu pemeriksaan data. |
| COPY-233 | HEMAT 15% | 6 bulan | Hapus klaim diskon pada paket 6 bulan. Enam kali Rp49.000 adalah Rp294.000, lebih rendah Rp5.000 daripada Rp299.000. Status: siap secara redaksional. |
| COPY-234 | Pilihan ideal untuk santri dan peneliti tugas akhir. | Pilih durasi 6 bulan untuk melanjutkan belajar secara rutin. | Salinan singkat untuk durasi. Kartu paket tetap harus menampilkan cakupan asisten yang benar, harga total, dan ketentuan perpanjangan. Status: perlu pemeriksaan data. |
| COPY-235 | PALING HEMAT | 1 tahun | Pakai label durasi yang netral. Potongan paket tahunan baru boleh disebut jika cakupan akses dan biaya tambahan setara. Status: siap secara redaksional. |
| COPY-236 | Akses tanpa batas setahun penuh untuk seluruh khazanah naskah. | Pilih durasi 1 tahun untuk belajar secara berkelanjutan. | Menghapus janji tanpa batas dan seluruh koleksi. Lengkapi daftar akses serta batas penggunaan dari konfigurasi paket. Status: perlu pemeriksaan data. |
| COPY-237 | Akses tanpa batas ke ribuan naskah turats kanonikal. | Telusuri rujukan kitab sesuai cakupan paket. | Daftar kitab tidak otomatis berarti seluruh teks tersedia bagi semua pelanggan. Cocokkan dengan isi sumber dan hak akses paket. Status: perlu pemeriksaan data. |
| COPY-238 | Pencarian ibarah presisi dengan kutipan jilid dan halaman asli. | Cari ibarah dan periksa informasi rujukan yang tersedia. | Tidak menjamin ketepatan keluaran AI atau kelengkapan penomoran. Tampilkan data rujukan yang memang tersedia. Status: siap secara redaksional. |
| COPY-239 | Multi-Room: Buka banyak asisten sekaligus tanpa memuat ulang. | Buka beberapa asisten dalam tab terpisah. | Menjelaskan fungsi tab tanpa menjanjikan sesi selalu dipertahankan saat memori perangkat berubah. Status: siap secara redaksional. |
| COPY-240 | Penyimpanan Catatan Riset tak terbatas langsung di perangkat. | Simpan catatan dan kutipan di perangkat Anda. | Menghapus tanpa batas. Lokasi lokal masih perlu diperiksa dan keterangan cadangan harus sesuai implementasi. Status: perlu pemeriksaan perilaku. |
| COPY-241 | Nomor WhatsApp Konfirmasi | Nomor WhatsApp | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-242 | Masukkan nomor WhatsApp aktif untuk pengiriman bukti aktivasi langganan dan rincian transaksi riset Anda. | Masukkan nomor WhatsApp aktif untuk menerima konfirmasi langganan dan rincian pembayaran. | Gunakan hanya jika konfirmasi memang dikirim ke WhatsApp. Jika untuk bantuan transaksi, ubah tujuan pengumpulan sesuai kenyataan. Status: perlu pemeriksaan perilaku. |
| COPY-243 | Lanjutkan Pembayaran | Lanjut ke pembayaran | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-244 | Masukkan nomor telepon yang valid. | Masukkan nomor WhatsApp lengkap, misalnya 081234567890. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-245 | Pembayaran Aman DOKU | Pembayaran melalui DOKU | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-246 | Transaksi terenkripsi dan diverifikasi secara instan. | Pilih metode pembayaran yang tersedia di DOKU. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-247 | QRIS (GoPay, OVO, Dana, ShopeePay, BCA, dll.) | QRIS | Sebut QRIS tanpa daftar merek yang mudah tidak sesuai. Tampilkan hanya jika metode aktif pada merchant dan transaksi. Status: perlu pemeriksaan data. |
| COPY-248 | Virtual Account (BCA, Mandiri, BNI, BRI, Permata) | Virtual account | Daftar bank mengikuti metode yang tersedia dalam checkout, bukan daftar statis. Status: perlu pemeriksaan data. |
| COPY-249 | Gerai Retail / Minimarket | Gerai retail atau minimarket | Tampilkan hanya jika tersedia pada transaksi yang sedang dibuat. Status: perlu pemeriksaan data. |
| COPY-250 | Periksa Status Pembayaran & Muat Ulang | Periksa status pembayaran | Cocok untuk pengecekan status. Jika tombol hanya memuat ulang WebView, gunakan Muat ulang pembayaran. Status: perlu pemeriksaan perilaku. |
| COPY-251 | Tutup Laman Pembayaran? | Tutup pembayaran | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-252 | Lanjutkan Bayar | Lanjutkan pembayaran | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-253 | Ya, Tutup | Tutup | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-254 | Menunggu konfirmasi pembayaran dari DOKU. | Menunggu konfirmasi pembayaran. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-255 | Apakah Anda ingin menutup sesi pembayaran? Transaksi Anda tetap tercatat di sistem. | Halaman pembayaran akan ditutup. | Draf minimum. Jelaskan apakah tagihan tetap aktif atau ikut dibatalkan berdasarkan perilaku DOKU yang benar-benar diterapkan. Jangan menyamakan menutup halaman dengan membatalkan transaksi. Status: perlu pemeriksaan perilaku. |
| COPY-256 | Pembayaran berhasil dikonfirmasi! Akses langganan telah aktif. | Pembayaran berhasil. Langganan Anda sudah aktif. | Hanya setelah pembayaran terkonfirmasi dan akses berhasil diaktifkan. Siapkan pesan untuk aktivasi yang masih diproses. Status: perlu pemeriksaan perilaku. |
| COPY-257 | Sesi pembayaran telah berakhir atau dibatalkan. | Pembayaran belum selesai. Periksa status pembayaran untuk melihat detailnya. | Pesan umum hanya jika status rinci belum diketahui dan tersedia aksi pemeriksaan. Gunakan pesan terpisah untuk gagal, kedaluwarsa, atau dibatalkan ketika status tersedia. Status: perlu pemeriksaan perilaku. |

### 10. Lembar Klaim Voucher Akses (Redeem Code Sheet)

| ID | Teks lama | Teks pengganti | Alasan dan status |
| --- | --- | --- | --- |
| COPY-258 | Tukar Kode Voucher | Gunakan voucher | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-259 | Masukkan kode akses atau voucher khusus untuk mengaktifkan langganan modul riset OpenTurath. | Masukkan kode voucher untuk mengaktifkan akses sesuai ketentuannya. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-260 | Masukkan kode akses | Kode voucher | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-261 | Klaim Akses Sekarang | Gunakan voucher | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-262 | Silakan masukkan kode akses terlebih dahulu. | Masukkan kode voucher terlebih dahulu. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-263 | Kode voucher tidak ditemukan. Periksa kembali penulisan kode Anda. | Kode voucher tidak ditemukan. Periksa penulisannya, lalu coba lagi. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-264 | Anda sudah pernah menukarkan kode voucher ini. | Anda sudah menggunakan voucher ini. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-265 | Kuota penukaran untuk kode voucher ini sudah habis. | Voucher ini sudah mencapai batas penggunaan. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-266 | Masa berlaku kode voucher ini telah berakhir. | Voucher ini sudah kedaluwarsa. | Pesan untuk kode yang kedaluwarsa, bukan jaringan terputus atau kode tidak ditemukan. Status: siap secara redaksional. |
| COPY-298 | Voucher berhasil ditukarkan! Akses modul telah diaktifkan. | Voucher berhasil digunakan. Akses Anda sudah aktif. | Tampilkan setelah penukaran dan aktivasi berhasil. Jika aktivasi belum selesai, gunakan status sedang diproses. Status: perlu pemeriksaan perilaku. |

### 11. Layar Profil, Pengaturan Akun & Dokumen Legal (Terms, Privacy, Adab)

| ID | Teks lama | Teks pengganti | Alasan dan status |
| --- | --- | --- | --- |
| COPY-267 | Tampilan & Kebahasaan | Tampilan dan bahasa | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-268 | Ikuti Sistem | Ikuti perangkat | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-269 | Santri Peneliti | Pengguna OpenTurath | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-270 | OpenTurath adalah platform kecerdasan buatan terapan untuk literatur dan turats Islam klasik. Dibangun untuk mempermudah santri, asatidz, akademisi, dan peneliti dalam menelusuri matan, syarah, takhrij, dan ibarah mu'tabarah secara terstruktur. | OpenTurath membantu Anda membaca dan mempelajari kitab-kitab Islam dengan bantuan AI. Telusuri penjelasan dan rujukan, bandingkan pembahasan, lalu simpan bagian penting ke Catatan. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-271 | 1. Ruang Lingkup & Tujuan Riset | 1. Kegunaan OpenTurath | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-272 | 2. Verifikasi Sumber Asli & Batasan Penggunaan | 2. Ketepatan jawaban dan pemeriksaan sumber | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-273 | 3. Akun Pengguna & Hak Akses | 3. Akun dan akses | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-274 | 4. Ketentuan Pembayaran & Berlangganan | 4. Pembayaran dan langganan | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-275 | Saya Pahami & Setuju | Setuju | Setuju hanya untuk persetujuan yang benar-benar diperlukan dan direkam. Modal baca ulang cukup memakai Tutup. Status: perlu pemeriksaan perilaku. |
| COPY-276 | Kebijakan Privasi Pengguna | Kebijakan Privasi | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-277 | 1. Pengumpulan & Penggunaan Data | 1. Data yang digunakan | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-278 | 2. Kerahasiaan Sesi & Catatan Riset | 2. Penyimpanan percakapan dan catatan | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-279 | 3. Keamanan Sesi Google & NotebookLM | 3. Penggunaan Google dan NotebookLM | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-280 | 4. Hak Penghapusan Data Pengguna | 4. Penghapusan akun dan data | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-281 | Metodologi Naskah & Sanad Rujukan | Tentang sumber rujukan | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-282 | Setiap asisten AI di OpenTurath terhubung dengan korpus naskah primer yang telah diverifikasi kelengkapan jilid, nama muallif, dan tahun wafat hijriyahnya berstandar Maktabah Syamilah. | Setiap asisten memiliki daftar kitab rujukan sesuai bidangnya. Buka detail kitab untuk melihat informasi pengarang dan edisi yang tersedia. Cocokkan kutipan AI dengan kitab asal sebelum menggunakannya. | Menghapus klaim verifikasi menyeluruh dan standar yang tidak dijelaskan. Status kelengkapan sumber harus berasal dari pemeriksaan katalog. Status: perlu pemeriksaan data. |
| COPY-283 | Keluar dari Akun | Keluar dari akun | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-284 | Hapus Akun & Data Riset | Hapus akun | Menghapus cakupan yang belum dibuktikan. Dialog harus menerangkan dampak terhadap catatan lokal, akun aplikasi, dan sesi layanan lain. Status: perlu pemeriksaan perilaku. |
| COPY-299 | Akses Penuh Seluruh Modul AI · Aktif sampai [Tanggal] | Langganan aktif hingga [Tanggal] | Ringkasan status tanpa janji semua asisten terbuka. Tampilkan daftar akses paket pada baris terpisah dari data langganan. Status: perlu pemeriksaan data. |
| COPY-300 | Digunakan untuk riset akademis dan literatur keislaman. | OpenTurath digunakan untuk membantu mempelajari dan menelusuri rujukan dalam kitab-kitab Islam. | Draf redaksional dari ringkasan kebijakan, bukan dokumen hukum lengkap. Lengkapi berdasarkan aliran data, persetujuan, dan ketentuan layanan yang berlaku. Status: draf kebijakan, belum siap tayang. |
| COPY-301 | Kecerdasan buatan bukan pemberi fatwa mutlak. Pengguna wajib mencocokkan kutipan dengan naskah fisik. | Jawaban AI merupakan bantuan untuk mempelajari sumber dan tidak berfungsi sebagai fatwa. Periksa kutipan pada kitab asal dan pelajari persoalan agama bersama guru atau ulama. | Draf redaksional dari ringkasan kebijakan, bukan dokumen hukum lengkap. Lengkapi berdasarkan aliran data, persetujuan, dan ketentuan layanan yang berlaku. Status: draf kebijakan, belum siap tayang. |
| COPY-302 | Akun bersifat personal dan tidak boleh disalahgunakan. | Gunakan akun pribadi Anda dan patuhi ketentuan akses OpenTurath. | Draf redaksional dari ringkasan kebijakan, bukan dokumen hukum lengkap. Lengkapi berdasarkan aliran data, persetujuan, dan ketentuan layanan yang berlaku. Status: draf kebijakan, belum siap tayang. |
| COPY-303 | Pembayaran resmi diproses melalui gateway pembayaran terlisensi. | Pembayaran langganan diproses melalui DOKU. Periksa harga, durasi, dan cakupan akses sebelum membayar. | Draf redaksional dari ringkasan kebijakan, bukan dokumen hukum lengkap. Lengkapi berdasarkan aliran data, persetujuan, dan ketentuan layanan yang berlaku. Status: draf kebijakan, belum siap tayang. |
| COPY-304 | Mengumpulkan data email dan profil Google dasar demi kelancaran otentikasi. | Alamat email dan informasi profil Google digunakan untuk membantu proses masuk ke akun. | Draf redaksional dari ringkasan kebijakan, bukan dokumen hukum lengkap. Lengkapi berdasarkan aliran data, persetujuan, dan ketentuan layanan yang berlaku. Status: draf kebijakan, belum siap tayang. |
| COPY-305 | Catatan riset dan bookmark disimpan secara aman dan terenkripsi. | Catatan dan rujukan disimpan di [lokasi penyimpanan yang telah diperiksa]. [Jelaskan cara perlindungan data yang benar-benar diterapkan]. | Draf redaksional dari ringkasan kebijakan, bukan dokumen hukum lengkap. Lengkapi berdasarkan aliran data, persetujuan, dan ketentuan layanan yang berlaku. Status: draf kebijakan, belum siap tayang. |
| COPY-306 | Mematuhi protokol otentikasi resmi Google OAuth. | Percakapan menggunakan NotebookLM. [Jelaskan data yang diteruskan ke Google, cara sesi dikelola, dan kebijakan yang berlaku]. | Draf redaksional dari ringkasan kebijakan, bukan dokumen hukum lengkap. Lengkapi berdasarkan aliran data, persetujuan, dan ketentuan layanan yang berlaku. Status: draf kebijakan, belum siap tayang. |
| COPY-307 | Pengguna berhak menghapus akun dan seluruh datanya kapan saja. | Anda dapat meminta penghapusan akun melalui Pengaturan. [Jelaskan data yang dihapus, data yang disimpan sementara, alasannya, dan jangka waktunya]. | Draf redaksional dari ringkasan kebijakan, bukan dokumen hukum lengkap. Lengkapi berdasarkan aliran data, persetujuan, dan ketentuan layanan yang berlaku. Status: draf kebijakan, belum siap tayang. |

### 12. Komponen Pendukung: Bukti Ibarah, Banner Update & Pesan Sistem

| ID | Teks lama | Teks pengganti | Alasan dan status |
| --- | --- | --- | --- |
| COPY-285 | Kutipan Ibarah Asli | Ibarah dan rujukan | Jangan memakai Asli untuk keluaran AI yang belum dicocokkan. Teks verbatim dari sumber tetap wajib memiliki asal yang jelas. Status: siap secara redaksional. |
| COPY-286 | Penulis | Pengarang | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-287 | Salin Teks | Salin teks | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-288 | Cari di Syamilah | Cari di Maktabah Syamilah | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-289 | Salin sitasi | Salin rujukan | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-290 | PEMBARUAN TERSEDIA | Pembaruan tersedia | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-291 | Versi Baru OpenTurath Siap Dipasang | Versi baru OpenTurath tersedia | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-292 | Pembaruan sistem membawa perbaikan stabilitas dan penambahan naskah kitab rujukan. | Perbarui OpenTurath untuk menggunakan versi terbaru. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-293 | Perbarui Sekarang | Perbarui sekarang | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-294 | Nanti Saja | Nanti | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-295 | Gagal Memuat Data | Data belum bisa dimuat | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-296 | Terjadi kendala saat menghubungkan ke server naskah. Periksa sambungan internet Anda. | Coba lagi dalam beberapa saat. | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |
| COPY-297 | Muat Ulang Halaman | Coba lagi | Bahasa lebih langsung dan konsisten dengan istilah antarmuka. Status: siap secara redaksional. |


## 11. Seluruh konstanta AppCopy

Daftar ini mencakup konstanta yang diubah maupun dipertahankan. Ia membantu memastikan tidak ada konstanta dalam tabel AppCopy asal yang terlewat.

| Konstanta | Teks final | Keputusan |
| --- | --- | --- |
| appName | OpenTurath | Dipertahankan. pertahankan. |
| appTagline | Membaca kitab, menelusuri ibarah. | Dipertahankan. pertahankan. |
| defaultFieldDesc | Pelajari berbagai bidang ilmu melalui kitab-kitab Islam. | Diubah. siap secara redaksional. |
| aboutTitle | Tentang OpenTurath | Dipertahankan. pertahankan. |
| aboutDescription | OpenTurath membantu Anda membaca, mencari, dan membandingkan keterangan dari kitab-kitab rujukan. | Dipertahankan. pertahankan. |
| aboutScholarlyPrinciple | Gunakan jawaban AI untuk membantu menelusuri rujukan. Periksa kutipannya pada kitab asal dan mintalah bimbingan guru atau ulama saat mempelajari persoalan agama. | Diubah. siap secara redaksional. |
| navHome | Beranda | Dipertahankan. pertahankan. |
| navStudies | Asisten AI | Dipertahankan. pertahankan. |
| navSaved | Catatan | Dipertahankan. pertahankan. |
| navSettings | Pengaturan | Dipertahankan. pertahankan. |
| studySpace | Percakapan | Diubah. siap secara redaksional. |
| openStudy | Membuka percakapan… | Diubah. siap secara redaksional. |
| studyOptions | Tampilan bacaan | Diubah. siap secara redaksional. |
| referenceBooks | Kitab rujukan | Dipertahankan. pertahankan. |
| savedCollection | Catatan | Dipertahankan. pertahankan. |
| bookDetails | Detail kitab | Diubah. siap secara redaksional. |
| loadingReferences | Menyiapkan percakapan… | Diubah. siap secara redaksional. |
| modulePreparing | sedang disiapkan. | Dipertahankan. siap secara redaksional. |
| moduleUnavailable | Asisten ini belum tersedia. Coba lagi nanti. | Diubah. siap secara redaksional. |
| cannotLoad | Konten belum bisa dimuat. Coba lagi. | Diubah. siap secara redaksional. |
| cannotLoadStudy | Percakapan belum bisa dibuka | Diubah. siap secara redaksional. |
| studyNotLoadedYet | Percakapan belum bisa dimuat. Coba lagi sebentar. | Diubah. siap secara redaksional. |
| subscriptionRequiredTitle | Pilih paket untuk melanjutkan | Diubah. siap secara redaksional. |
| catalogLoadFailed | Daftar kitab belum bisa dimuat. | Dipertahankan. pertahankan. |
| inputQuestionHint | Tulis pertanyaan tentang kitab ini | Diubah. siap secara redaksional. |
| viewSubscription | Lihat paket | Diubah. siap secara redaksional. |
| tryAgain | Coba lagi | Dipertahankan. pertahankan. |
| deviceNotSupportedTitle | Perangkat belum didukung | Dipertahankan. pertahankan. |
| deviceNotSupportedMessage | OpenTurath saat ini mendukung Android, macOS, dan Windows. Perangkat ini belum didukung. | Dipertahankan. pertahankan. |
| cannotConnectTitle | Belum bisa terhubung | Diubah. siap secara redaksional. |
| cannotConnectMessage | OpenTurath belum bisa terhubung. Periksa koneksi internet, lalu coba lagi. | Diubah. siap secara redaksional. |
| adabDialogTitle | Catatan sebelum mulai | Dipertahankan. pertahankan. |
| adabAcknowledgeButton | Mengerti | Diubah. siap secara redaksional. |
| adabHeading1 | Bantuan untuk membaca kitab | Diubah. siap secara redaksional. |
| adabBody1 | OpenTurath membantu mencari ibarah, yaitu kutipan teks dari kitab, dan membandingkan penjelasannya. Jawaban AI bisa keliru. Cocokkan kutipan dengan kitab asal di Maktabah Syamilah atau edisi cetaknya. | Diubah. siap secara redaksional. |
| adabHeading2 | Belajar tetap perlu bimbingan | Dipertahankan. pertahankan. |
| adabBody2 | Pelajari persoalan agama bersama guru atau ulama yang memahami bidangnya. | Diubah. siap secara redaksional. |
| adabHeading3 | Periksa kembali rujukan | Dipertahankan. pertahankan. |
| adabBody3 | Baca konteks pembahasan dalam kitab sebelum menggunakan atau membagikan jawaban. | Diubah. siap secara redaksional. |
| noAnswerToCopy | Belum ada jawaban untuk disalin. | Dipertahankan. pertahankan. |
| answerCopied | Jawaban disalin dan disimpan di Catatan. | Diubah. perlu pemeriksaan perilaku. |
| copyFailed | Belum bisa menyalin. Coba lagi. | Diubah. siap secara redaksional. |
| noAnswerToSave | Belum ada jawaban untuk disimpan. | Dipertahankan. pertahankan. |
| savedSuccess | Tersimpan di Catatan. | Diubah. siap secara redaksional. |
| saveFailed | Belum bisa menyimpan. Coba lagi. | Diubah. siap secara redaksional. |
| searchSavedHint | Cari catatan, topik, atau kutipan | Diubah. siap secara redaksional. |
| searchSavedTooltip | Cari catatan | Dipertahankan. pertahankan. |
| noSavedTitle | Belum ada catatan | Dipertahankan. pertahankan. |
| noSavedDescription | Simpan jawaban, kutipan, atau rujukan kitab di sini. | Diubah. siap secara redaksional. |
| copyIbarahAction | Salin ibarah | Dipertahankan. pertahankan. |
| viewReferenceAction | Lihat rujukan | Dipertahankan. pertahankan. |
| shareReferenceTooltip | Bagikan catatan | Dipertahankan. pertahankan. |
| saveAnswerMenu | Simpan ke Catatan | Dipertahankan. pertahankan. |
| profile | Profil | Dipertahankan. pertahankan. |
| subscription | Langganan | Dipertahankan. pertahankan. |
| activeSubscription | Langganan aktif | Dipertahankan. pertahankan. |
| inactiveSubscription | Pilih paket atau gunakan voucher untuk mengakses asisten AI. | Diubah. siap secara redaksional. |
| appearance | Tampilan | Dipertahankan. pertahankan. |
| modeDark | Gelap | Dipertahankan. pertahankan. |
| modeLight | Terang | Dipertahankan. pertahankan. |
| modeSystem | Ikuti perangkat | Diubah. siap secara redaksional. |
| language | Bahasa | Dipertahankan. pertahankan. |
| languageIndonesian | Bahasa Indonesia | Dipertahankan. pertahankan. |
| logoutDialogTitle | Keluar dari akun | Diubah. siap secara redaksional. |
| logoutDialogBody | Anda akan keluar dari akun ini. | Dipertahankan. pertahankan. |
| logoutButton | Keluar | Dipertahankan. pertahankan. |
| deleteAccountTitle | Hapus akun | Diubah. siap secara redaksional. |
| deleteAccountBody | Akun Anda akan dihapus secara permanen. Tindakan ini tidak dapat dibatalkan. | Diubah. perlu pemeriksaan perilaku. |
| deleteAccountButton | Hapus akun | Dipertahankan. pertahankan. |
| deleteAccountSuccess | Akun Anda sudah dihapus. | Dipertahankan. pertahankan. |
| recentLoginRequired | Masuk kembali untuk melanjutkan penghapusan akun. | Diubah. siap secara redaksional. |
| networkError | Koneksi internet bermasalah. Coba lagi. | Diubah. siap secara redaksional. |

## 12. Batas pemeriksaan dan hasil validasi berkas

- Seluruh 72 nama konstanta AppCopy dipertahankan tanpa penambahan atau penghapusan pada tabel master.
- Setiap pasangan teks dalam peta penggantian ditemukan pada inventaris sumber.
- Struktur 12 bagian utama, jalur berkas Dart, dan ID asisten dipertahankan.
- Variabel `${agent.title}` tetap utuh. Format [Tanggal], angka contoh katalog, dan harga tetap memerlukan sumber data yang benar pada implementasi.
- Judul kitab dan identitas sumber Arab tidak dinormalisasi melalui penggantian istilah antarmuka.
- Master revisi bebas tanda tanya dalam teks penggantinya, titik koma, dan em dash. Tanda tanya pada matriks audit hanya terdapat di kolom kutipan teks lama.
- Peta JSON dapat dibaca sebagai JSON dan secara eksplisit melarang penerapan otomatis.
- Pemeriksaan ini memvalidasi dokumen hasil. Tidak ada pengujian widget, login, pembayaran, database, atau aplikasi aktif.

Teks asli lampiran tetap menjadi acuan pembandingan. Daftar harga, bibliografi, platform yang didukung, contoh tanggal, dan versi aplikasi mengikuti inventaris. Data tersebut belum diperiksa terhadap aplikasi yang berjalan. Contoh tanggal Masehi dan Hijriah perlu berasal dari perhitungan kalender aplikasi yang benar, bukan disalin sebagai tanggal yang dianggap selalu sesuai.

Lampiran juga menyebut beberapa daftar dengan keterangan dll. Bagian yang tidak dituliskan lengkap, teks aksesibilitas yang belum tercantum, dan pesan dinamis dari layanan lain belum dapat dinyatakan selesai diaudit. Tahap perubahan langsung pada aplikasi memerlukan kode sumber versi yang akan digunakan.
