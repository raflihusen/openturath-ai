# Audit ulang desain OpenTurath — 7 Oktober 2026

## Keputusan

**Desain terbaru belum layak disebut selesai secara visual.** Masalahnya sistemik: dekorasi mengganggu informasi, kepadatan berubah tanpa alasan yang jelas, dan beberapa layar masih memakai bahasa desain lama. Rounded corner serta warna monokrom sudah diterapkan, tetapi komposisi belum cukup terarah.

Ini audit atas hasil sendiri, bukan permintaan agar pengguna menjelaskan lagi seleranya. Kode aplikasi, aset, dan paket tidak diubah dalam tahap ini. Dokumen audit mendapat checkpoint Git tersendiri.

## Bukti dan batas penilaian

Saya meninjau komposisi seluruh **64 PNG non-frame** dalam `screens/`, kemudian membuka gambar utama pada ukuran yang memungkinkan teks dibaca: dashboard ID/AR, halaman AI, profil ponsel/Arab/teks besar, katalog kartu/list, detail kitab, harga ponsel, pengenalan ID/AR/ponsel dan bagian panjang, chat ponsel, autentikasi, aktivasi, serta Tentang. Motion ditinjau lewat 12 sampel fase terang dan 6 sampel gelap dari rangkaian 60 frame per tema. Sampel fase ini tidak membuktikan performa animasi di perangkat nyata.

Gambar adalah render Flutter dengan akun contoh. Batas viewport pada halaman yang dapat digulir **bukan otomatis overflow**. Tidak ada klaim rasio kontras, keberhasilan keyboard, pembaca layar, login Google, atau performa perangkat tanpa pemeriksaan tersendiri.

Beberapa gambar adalah fixture yang tidak sama dengan rute lengkap. Temuan semacam ini ditandai sebagai masalah bukti, bukan langsung dinyatakan bug aplikasi.

## Temuan lintas layar

| ID | Prioritas | Cacat dan bukti | Arah koreksi |
|---|---|---|---|
| 01 | P1 | Semua kartu ilmu memakai bentuk, latar, dan watermark yang hampir sama. Enam bidang menjadi massa hitam berulang; tidak ada ritme visual yang membimbing perhatian. `dashboard_id`, `assistants_id`. | Pertahankan kartu gelap sesuai permintaan, tetapi bedakan fungsi melalui komposisi dan kepadatan. Warna hitam tidak cukup menjadi hierarki. |
| 02 | P1 | Watermark Arab berada di belakang metadata/tindakan, bahkan naik di belakang judul pada kartu AI pendek. Huruf besar terpotong di sisi kartu. `assistants_id`, `dashboard_id`, `dashboard_phone`. | Sediakan zona dekorasi yang benar-benar terpisah dari zona informasi. Ukuran/crop ditentukan per bentuk kartu; jangan memakai satu skala untuk semua. |
| 03 | P1 | Judul, angka, tombol, dan label kecil sering memakai bobot tebal serupa. Banyak elemen meminta perhatian sekaligus. `assistants_id`, `subscription_phone`, `profile_phone`. | Tetapkan urutan judul → informasi inti → tindakan → metadata. Batasi bold pada elemen yang memerlukan perhatian. |
| 04 | P1 | Bahasa desain berbeda: katalog lama memakai outline/list penuh, katalog baru memakai kartu putih bernomor, aktivasi memakai medali bergradasi dan shadow tebal, halaman AI memakai sculpture gelap. | Satukan aturan permukaan, tipografi, padding, dan elevasi. Identitas eksklusif tetap khusus pada Tahawwulat. |

## Beranda, kalender, dan angka pustaka

| ID | Prioritas | Cacat dan bukti | Arah koreksi |
|---|---|---|---|
| 05 | P1 | Kalender belum terasa sebagai satu komponen rounded: tanggal terletak di ruang kosong sebelah sapaan dengan tombol info yang jauh. `dashboard_id`, `dashboard_phone`. | Dua tanggal tetap setara dalam satu blok kompak; tombol info melekat pada judul blok. |
| 06 | P1 | Header terlalu tinggi dibanding informasi yang dibawa; di ponsel sapaan, kalender, dan pencarian menghabiskan bagian atas sebelum pilihan bidang. `dashboard_phone`, `shell_phone`. | Rapikan tinggi dan jarak header, bukan mengecilkan semua teks. |
| 07 | P1 | Label jumlah AI menempel dekat watermark; pada Arab label lebih panjang dan bertabrakan secara visual dengan huruf dekorasi. `dashboard_ar`. | Metadata memiliki baris/lapisan bersih dengan ruang aman tersendiri. |
| 08 | P1 | Kartu Bahasa Arab menjadi dua baris pada ponsel, sedangkan bidang lain satu baris. Watermark panjang terpotong tanpa komposisi yang disengaja. `dashboard_phone`. | Siapkan pola judul panjang dan watermark pendek yang tetap konsisten, tanpa menghilangkan nama bidang sebenarnya. |
| 09 | P1 | “Pustaka dalam angka” di desktop ID pecah menjadi dua angka di atas dan satu di bawah; di Arab tiga angka dalam satu baris. Tinggi, susunan, dan ritmenya tidak stabil. `dashboard_id`, `dashboard_ar`, `shell_desktop`. | Tiga metrik memiliki grid yang dirancang menurut lebar komponen, bukan wrap kebetulan. |
| 10 | P2 | Angka dibuat sebagai kapsul di dalam kartu sehingga menambah lapisan permukaan; “20 pustaka bidang ilmu” terasa berat dan kurang langsung. `dashboard_id`. | Gunakan tiga blok angka dengan label singkat yang akurat, tanpa kapsul tambahan jika tidak ada fungsi interaksi. |
| 11 | P2 | Blok adab adalah paragraf panjang dengan tindakan koreksi yang tidak langsung terlihat. Ia bersaing dengan statistik sebagai satu kartu besar. `dashboard_id`. | Ringkas pengantar dan beri tindakan yang jelas; detail tetap tersedia pada panduan. |

Hero Tahawwulat sudah tidak berada di beranda pada gambar terbaru. Ini sesuai koreksi terakhir pengguna dan **harus dipertahankan**.

## Halaman AI dan produk eksklusif

| ID | Prioritas | Cacat dan bukti | Arah koreksi |
|---|---|---|---|
| 12 | P1 | Hero memakai ruang besar, sedangkan kartu AI umum hanya sekitar 124 piksel tinggi dalam fixture desktop. Perbedaan terasa seperti dua desain yang tidak berhubungan. `assistants_id`. | Hero tetap dominan tetapi lebih terukur; kartu AI memiliki ruang yang cukup untuk nama, metadata, dan tindakan tanpa bertumpuk. |
| 13 | P1 | Lima pilihan AI berbentuk tiga kolom lalu dua; slot kanan kosong membuat komposisi tampak belum selesai. `assistants_id`. | Susun lima pilihan dengan pola yang disengaja; jangan menyisakan lubang grid tanpa alasan. |
| 14 | P1 | Kartu umum memuat judul, tiga statistik, watermark, serta dua tindakan pada bidang yang pendek. “Buka AI” dan “Lihat rujukan” berwarna abu-abu dan tenggelam. `assistants_id`. | Satu tindakan utama jelas; tindakan rujukan sekunder. Ringkas statistik yang tidak diperlukan untuk memilih AI. |
| 15 | P2 | “Eksklusif di OpenTurath” sudah ada, tetapi kecil dan terpencil. Label “AKTIF” berada jauh di kanan baris pilihan, kurang jelas status milik koleksi atau pilihan mana. `assistants_id`. | Kelompokkan identitas koleksi dan status akses dengan jelas; eksklusivitas tidak perlu medali tambahan. |

**Batas penting:** fixture `assistants_id/ar` menyusun tiga kolom secara manual. Rute aktif di `specialist_list_screen.dart` memakai breakpoint satu/dua/tiga kolom. Cacat watermark adalah masalah komponen bersama; kepadatan tiga kolom pada fixture tidak boleh dianggap mewakili semua ukuran rute aktif. Gambar AI ponsel melalui rute sebenarnya belum tersedia dalam set ini.

Tidak terlihat subtitle “Matan · Syarah · Hasyiah Mu‘tabarah” di bawah nama AI pada kartu terbaru. Nama bidang “AI Matan Hadits” bukan subtitle tersebut.

## Katalog dan detail kitab

| ID | Prioritas | Cacat dan bukti | Arah koreksi |
|---|---|---|---|
| 16 | P1 | Ada dua katalog dengan struktur berbeda: `catalog_id` dan `library_books`. Label pencarian juga berbeda, “pentahkik” versus “muhaqqiq”. | Tentukan pola katalog bersama untuk kedua jalur, lalu sesuaikan konteks koleksi. |
| 17 | P1 | Toolbar katalog baru memakai banyak baris: keterangan, pencarian, filter, sort/tampilan, jumlah hasil. Hasil pertama mulai rendah. `library_books`, `library_ar_phone`. | Gabungkan kontrol yang berkaitan; prioritasnya pencarian dan hasil. Ponsel tidak perlu meniru toolbar desktop. |
| 18 | P1 | Kartu kitab terlalu tinggi untuk isi pendek. Jarak besar antara pengarang dan footer membuat pengguna menggulir jauh untuk sedikit informasi. `library_books`. | Tinggi mengikuti kebutuhan isi atau gunakan daftar kompak; kepadatan harus sesuai pekerjaan mencari kitab. |
| 19 | P2 | Nomor 01/02 dan kata “kitab” mengambil baris tersendiri, tetapi nomor hanya posisi pengurutan, bukan identitas bibliografis. `library_books`. | Hapus nomor dekoratif kecuali ada fungsi yang jelas; jangan membuatnya tampak seperti nomor rujukan. |
| 20 | P1 | Tahun wafat muncul dalam teks pengarang Arab dan diulang sebagai “w. 676 H” / “w. 926 H”. `library_books`, `catalog_id`. | Tampilkan sekali berdasarkan data terstruktur; jangan menghapus lafaz sumber tanpa aturan editorial. |
| 21 | P1 | Detail kitab memiliki judul/pengarang di kanan, bidang/tahun/tindakan di kiri bawah; hubungan identitasnya terpecah. `library_book_detail`, `library_detail_phone`. | Satu kelompok identitas; arah Arab lokal tetap RTL. Tindakan berdekatan dengan identitas yang ditindak. |
| 22 | P2 | Salin/simpan muncul sebagai ikon di toolbar dan sebagai tombol dalam kartu yang sama. Keterangan kehati-hatian metadata berada sebagai paragraf panjang jauh di bawah. `library_book_detail`. | Kurangi duplikasi kontrol; hubungkan catatan metadata dengan field yang memang perlu diperiksa. |
| 23 | P1 | Overview pustaka adalah layar ringkasan dengan satu kartu dan banyak ruang kosong sebelum pengguna masuk katalog. `library_overview_wide`. | Pertimbangkan ringkasan menyatu dengan katalog sehingga satu tahap navigasi tidak diperlukan hanya untuk statistik. |

Judul panjang pada kartu memakai pembatas baris; keterbacaan judul lengkap saat fokus dan pembaca layar perlu diperiksa. Potongan kartu pada bawah screenshot adalah batas scroll, bukan bukti render overflow. Tahun/edisi yang janggal tidak boleh diperbaiki dengan tebakan.

## Mengenal Fikih Tahawwulat

| ID | Prioritas | Cacat dan bukti | Arah koreksi |
|---|---|---|---|
| 24 | P1 | Hero ponsel sangat tinggi; pada viewport 844 bagian yang terlihat setelahnya baru awal daftar isi. Ada ruang besar antara hero dan daftar isi. `tahawwulat_phone`. | Seimbangkan tinggi artwork dan pengantar sehingga pengguna segera menemukan materi. |
| 25 | P1 | Sampul memakai sans tebal, sementara daftar isi dan judul bab memakai serif. Peralihan terasa seperti dua produk karena ritme/ukuran/spacing belum menyatukan keduanya. `tahawwulat_id`, `tahawwulat_long`. | Sans untuk navigasi, serif editorial boleh dipertahankan dengan skala dan jarak yang terencana. |
| 26 | P1 | Mode Arab menerjemahkan hero tetapi daftar isi dan isi utama tetap Indonesia, lalu ditata ke kanan. `tahawwulat_ar`. | Terjemahkan materi atau nyatakan bahasa materi secara jelas dan pertahankan arah lokal yang benar. Jangan membalik artikel Indonesia karena UI Arab. |
| 27 | P1 | Sculpture yang sama menjadi sampul dan diagram besar dalam isi. Pada diagram, sektor terpilih tidak terlihat berbeda di gambar; chip di bawah yang memberi tahu pilihan. `tahawwulat_long`, `tahawwulat_diagram.dart`. | Artwork sampul boleh statis. Diagram pembelajaran perlu indikator pilihan terlihat, padanan teks, dan hubungan sektor–penjelasan yang nyata. |
| 28 | P2 | Rencana awal menyebut daftar isi sticky desktop; hasil sekarang berupa daftar di awal gulungan. Komentar implementasi menyatakan tanpa panel samping. | Putuskan navigasi membaca yang benar-benar membantu kembali ke bab; catat penyimpangan rencana secara jujur. |

Artwork 3D monokrom lebih mendekati referensi pengguna dibanding diagram awal. Masalah utama sekarang adalah pemakaian dan komposisinya, bukan alasan untuk mengganti seluruh arah seni lagi. Tulisan Arab yang tertanam pada bitmap tetap memerlukan pemeriksaan editorial; bukan teks yang dapat dipilih atau disesuaikan font-nya.

## Profil, langganan, login, dan dialog

| ID | Prioritas | Cacat dan bukti | Arah koreksi |
|---|---|---|---|
| 29 | P1 | Padding kelompok Tampilan dan Bahasa berbeda. Tepi label serta lebar pill tidak sejajar, paling jelas di ponsel. `profile_phone`, `profile_ar`. | Gunakan kerangka komponen yang sama, bukan hanya bentuk pill serupa. |
| 30 | P2 | “Ikuti perangkat” menjadi dua baris pada ponsel, dua pilihan lain satu baris. Pada teks besar, email patah menjadi `openturath.` dan `id`. `profile_phone`, `profile_large_text`. | Rancang label/tinggi kontrol yang konsisten dan pembungkusan email yang terbaca. Reflow pada teks besar benar; pecahan yang buruk tetap perlu diperbaiki. |
| 31 | P2 | Status akses aktif memakai ikon bergaya verified, yang dapat dibaca sebagai verifikasi profil. Identitas/paket/masa aktif belum punya urutan visual kuat. `profile_dark`. | Pakai indikator akses yang tidak ambigu, kelompokkan paket dan masa berlaku, lalu tindakan pengelolaan. |
| 32 | P1 | Harga Tahawwulat dan akses satu AI tampil hampir sama. Pembeda produk utama melemah di halaman harga; nama lima AI menjadi baris panjang yang patah. `subscription_phone`, `subscription_wide`. | Produk utama mendapat penekanan terukur; tampilkan isi akses secara ringkas, tanpa menambah subtitle terlarang. |
| 33 | P2 | Pilihan durasi hanya menunjukkan 1/6/12 bulan. Harga setiap pilihan tidak bisa dibandingkan sekilas dari screenshot default. `subscription_phone`. | Tampilkan harga total dan ekuivalen per bulan yang bersumber dari data sebenarnya. Harga coret sudah ada dan harus tetap akurat. |
| 34 | P1 | Dialog aktivasi masih memakai medali bergradasi, shadow bawah tebal, kartu bertingkat, serif dan copy “Hak Istimewa Perdana”, “terverifikasi”, “tanpa batas”. `dlg_activation`. | Jadikan konfirmasi akses sederhana. Klaim kualitas/kuota harus punya dasar; label eksklusif tidak perlu diterapkan pada setiap akses umum. |
| 35 | P2 | Login desktop memakai ilustrasi kubah panjang dan serif berbeda dari dashboard; login ponsel kehilangan sebagian konteks yang ada pada panel desktop. Tentang berisi dua blok panjang dalam modal. `login_id/phone`, `dlg_about`. | Pertahankan identitas, ringkas pengantar, samakan tipografi UI; materi penjelasan panjang layak halaman baca. |

Kontrol bahasa ID–EN–AR sudah sesuai urutan yang diminta. Profil sudah tanpa garis kubah; perbaikan ini tidak perlu dibatalkan. Hapus akun terpisah pada baris sendiri dan dialog konfirmasi memakai merah; warna semantik konsekuensi bukan cacat palet monokrom.

## Percakapan, loading, WebView, dan kekurangan bukti

- **Chat:** `chat_mixed_phone` lebih tertib arah bacanya daripada screenshot lama: paragraf Indonesia LTR, kutipan Arab RTL tersendiri. Namun tombol salin/simpan terlihat sebagai ikon kecil yang jauh dari sumber. Sumber tertutup tidak menunjukkan konteks rujukan. Fixture pendek tidak menguji jawaban panjang, streaming, keyboard terbuka, atau kutipan nyata. Ini belum bukti WebView hasil redesign.
- **Loading:** sampel fase menunjukkan empat kotak rounded berganti posisi/rotasi dan jarak, tetapi bentuknya masih mudah dibaca sebagai spinner generik. Hubungan dengan identitas OpenTurath tidak terlihat kuat. `loader_light/dark` hanya menunjukkan simbol pada bidang kosong; `loader_id` menunjukkan label proses. Variasi penggunaan ini perlu dijelaskan dan disatukan. Kebutuhan sebenarnya adalah perubahan kecepatan yang nyaman serta status proses jelas, bukan lebih banyak ornamen. Sampling frame belum membuktikan gerak halus di perangkat.
- **WebView — prioritas verifikasi tertinggi:** pengguna telah melaporkan AI tidak terbuka. `room_loadfail` hanya fixture error; ini bukan reproduksi penyebab. Tidak ada screenshot sesi terautentikasi dan jawaban berhasil dalam set ini. Perbaikan adapter tidak boleh disebut pemulihan sebelum alur nyata berhasil.
- **Fixture auth:** `room_auth` menampilkan `{0}` secara literal. Pemeriksaan kode menunjukkan fixture memanggil terjemahan tanpa email; rute aktif memasukkan email/fallback. Jadi gambar ini cacat sebagai bukti, belum bukti placeholder bocor di rute aktif. Tombol dan ikon fixture juga berbeda dari rute aktif.
- **Fixture panduan:** `guideline_id` hanya gambar tombol `open`, sebab dialog tidak dibuka sebelum pengambilan gambar. Isi panduan belum mendapat audit dari gambar ini.
- **Fixture bahasa:** `dlg_language` merupakan profil dengan selector inline; tidak ada dialog. Nama fixture sudah tidak menggambarkan keadaan yang ditangkap.
- **Cakupan:** galeri utama hanya menawarkan 15 screenshot. Set 64 belum menyediakan AI ponsel lewat rute aktif, seluruh halaman artikel hingga penutup, katalog dark/teks besar sebagai bukti visual tersimpan, variasi error jaringan sebenarnya, akses kedaluwarsa nyata, atau interaksi keyboard. Enam splash menangkap fase animasi berbeda; hilangnya logo/nama pada fase awal bukan otomatis bug.
- **Catatan:** `notes_id` menunjukkan keadaan kosong saja. Ia belum mewakili catatan berisi campuran Arab–Indonesia, penyuntingan, atau status penyimpanan.

## Urutan perbaikan yang saya rekomendasikan

1. **Reproduksi kegagalan AI/WebView secara nyata** dan pisahkan autentikasi, pemuatan, izin, serta readiness. Ini syarat pemulihan fungsi, bukan pekerjaan kosmetik.
2. **Benahi struktur kartu ilmu/AI**: zona dekorasi Arab terpisah, informasi ringkas, tombol jelas, ukuran sesuai ruang aktual. Pertahankan monokrom dan AI sebagai nama depan.
3. **Benahi header beranda, kalender, dan tiga metrik pustaka** dengan komposisi yang stabil di desktop dan ponsel.
4. **Satukan katalog**, rapikan toolbar, kurangi ruang kosong, hilangkan duplikasi tahun wafat, dan kelompokkan identitas detail.
5. **Rapikan hero eksklusif dan lima pilihan AI** tanpa membawa hero kembali ke beranda atau mengembalikan subtitle akademik.
6. **Rapikan profil/paket/masa aktif**, kontrol Tampilan–Bahasa, harga, serta dialog lama.
7. **Selesaikan halaman pengenalan**, navigasi bab, bahasa artikel, dan indikator pilihan diagram; pertahankan artwork yang mendekati referensi.
8. **Tinjau loading dalam alur nyata**, bukan simbol berdiri sendiri. Perbaiki fixture yang menyesatkan dan ambil kembali layar lengkap beserta navigasinya.

Sebelum menyebarkan perbaikan berikutnya, satu komposisi beranda dan satu komposisi AI/katalog harus ditinjau dalam konteks layar lengkap desktop serta ponsel. Pengguna tidak perlu menjelaskan ulang arah: rounded, monokrom, tenang, rapi, dan eksklusif pada tempat yang tepat sudah jelas. Kelulusan teknis dan penerimaan visual tetap dicatat terpisah.

## Inventaris screenshot yang ditinjau

Seluruh PNG non-frame berikut ditinjau komposisinya; gambar utama disebut secara khusus di atas. Ini inventaris bukti, bukan daftar layar yang dinyatakan lulus.
- [assistants_ar.png](screens/assistants_ar.png)
- [assistants_id.png](screens/assistants_id.png)
- [catalog_id.png](screens/catalog_id.png)
- [chat_mixed.png](screens/chat_mixed.png)
- [chat_mixed_dark.png](screens/chat_mixed_dark.png)
- [chat_mixed_phone.png](screens/chat_mixed_phone.png)
- [dashboard_ar.png](screens/dashboard_ar.png)
- [dashboard_dark.png](screens/dashboard_dark.png)
- [dashboard_id.png](screens/dashboard_id.png)
- [dashboard_phone.png](screens/dashboard_phone.png)
- [dlg_about.png](screens/dlg_about.png)
- [dlg_access.png](screens/dlg_access.png)
- [dlg_access_dark.png](screens/dlg_access_dark.png)
- [dlg_activation.png](screens/dlg_activation.png)
- [dlg_activation_dark.png](screens/dlg_activation_dark.png)
- [dlg_delete.png](screens/dlg_delete.png)
- [dlg_field.png](screens/dlg_field.png)
- [dlg_language.png](screens/dlg_language.png)
- [dlg_redeem.png](screens/dlg_redeem.png)
- [guideline_id.png](screens/guideline_id.png)
- [library_ar_phone.png](screens/library_ar_phone.png)
- [library_book_detail.png](screens/library_book_detail.png)
- [library_book_detail_wide.png](screens/library_book_detail_wide.png)
- [library_books.png](screens/library_books.png)
- [library_detail_phone.png](screens/library_detail_phone.png)
- [library_overview.png](screens/library_overview.png)
- [library_overview_wide.png](screens/library_overview_wide.png)
- [loader_dark.png](screens/loader_dark.png)
- [loader_id.png](screens/loader_id.png)
- [loader_light.png](screens/loader_light.png)
- [login_ar.png](screens/login_ar.png)
- [login_dark.png](screens/login_dark.png)
- [login_id.png](screens/login_id.png)
- [login_phone.png](screens/login_phone.png)
- [notes_id.png](screens/notes_id.png)
- [profile_ar.png](screens/profile_ar.png)
- [profile_dark.png](screens/profile_dark.png)
- [profile_id.png](screens/profile_id.png)
- [profile_large_text.png](screens/profile_large_text.png)
- [profile_phone.png](screens/profile_phone.png)
- [profile_window.png](screens/profile_window.png)
- [room_auth.png](screens/room_auth.png)
- [room_loadfail.png](screens/room_loadfail.png)
- [shell_desktop.png](screens/shell_desktop.png)
- [shell_phone.png](screens/shell_phone.png)
- [splash_dark_1400.png](screens/splash_dark_1400.png)
- [splash_dark_370.png](screens/splash_dark_370.png)
- [splash_dark_670.png](screens/splash_dark_670.png)
- [splash_light_1400.png](screens/splash_light_1400.png)
- [splash_light_370.png](screens/splash_light_370.png)
- [splash_light_670.png](screens/splash_light_670.png)
- [subscription_ar.png](screens/subscription_ar.png)
- [subscription_ar_new.png](screens/subscription_ar_new.png)
- [subscription_ar_phone.png](screens/subscription_ar_phone.png)
- [subscription_dark.png](screens/subscription_dark.png)
- [subscription_id.png](screens/subscription_id.png)
- [subscription_phone.png](screens/subscription_phone.png)
- [subscription_wide.png](screens/subscription_wide.png)
- [subscription_window.png](screens/subscription_window.png)
- [tahawwulat_ar.png](screens/tahawwulat_ar.png)
- [tahawwulat_id.png](screens/tahawwulat_id.png)
- [tahawwulat_long.png](screens/tahawwulat_long.png)
- [tahawwulat_phone.png](screens/tahawwulat_phone.png)
- [tahawwulat_window.png](screens/tahawwulat_window.png)
