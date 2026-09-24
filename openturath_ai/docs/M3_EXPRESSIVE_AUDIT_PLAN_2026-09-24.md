# Audit dan rencana Material 3 Expressive OpenTurath AI

Status: **arah desain dan rencana implementasi, belum diterapkan pada UI produksi**. Tanggal: 24 September 2026.

## Keputusan produk

OpenTurath adalah ruang telaah kitab. Ekspresi visual dipakai untuk membantu pengguna menemukan bidang ilmu, memilih asisten yang tepat, dan memahami tindakan berikutnya. Ketika pengguna membaca matan, syarah, sitasi, atau catatan, antarmuka memberi ruang kepada teks. Ini adalah tafsir OpenTurath atas Material 3 Expressive, bukan salinan tampilan Google.

Repositori [anti-slop](https://github.com/miqdadbadjuber/anti-slop) adalah saringan kualitas, bukan sumber palet atau tata letak. Setiap aksen, bentuk, ilustrasi, metrik, dan gerak harus punya fungsi yang dapat dijelaskan. Rujukan desain utama: [riset Google tentang M3 Expressive](https://design.google/library/expressive-material-design-google-research), [panduan Material untuk Flutter](https://docs.flutter.dev/ui/design/material), [migrasi Material 3 Flutter](https://docs.flutter.dev/release/breaking-changes/material-3-migration), [adaptasi ukuran jendela](https://docs.flutter.dev/ui/adaptive-responsive/general), dan [internasionalisasi Flutter](https://docs.flutter.dev/ui/internationalization).

## Bukti dan batas pemeriksaan

- Bukti visual: delapan tangkapan layar yang diberikan pengguna pada percakapan ini, meliputi Beranda, Asisten, Pengaturan, Langganan, ringkasan pustaka, dan detail rujukan. Ini memperlihatkan kepadatan kartu, daftar asisten yang monoton, metrik pustaka yang mendominasi, kontras harga yang gagal, serta halaman detail dengan ruang kosong dan metadata yang kurang tersusun.
- Bukti kode: `lib/main.dart`, `lib/core/theme.dart`, `lib/core/design/{ot_colors,native_design,ot_typography,ot_motion,ot_radius}.dart`, `lib/widgets/native_theme.dart`, `lib/screens/main_shell_screen.dart`, seluruh 16 berkas `lib/screens/`, model agen, lokalisasi, dan berkas katalog yang dipakai oleh layar.
- Kode sudah memakai `useMaterial3: true`, tetapi banyak komponen penting digambar sendiri. Material 3 aktif **tidak** berarti seluruh pengalaman sudah mengikuti M3 Expressive.
- Audit ini belum memeriksa setiap keadaan pada perangkat nyata. `flutter --version` di lingkungan saat ini gagal karena akses tulis ke cache SDK `engine.stamp` ditolak. Perangkat iOS simulator juga belum tersedia melalui `xcrun simctl`. Jangan menyebut render widget terdahulu sebagai penerimaan visual.
- Berkas `.firebase/hosting.cHVibGlj.cache` dan berbagai berkas tidak terlacak sudah ada sebelum rencana ini. Jangan masukkan berkas tersebut ke commit desain.

## Temuan terurut

| Prioritas | Jenis | Bukti yang dapat ditelusuri | Dampak | Keputusan |
| --- | --- | --- | --- | --- |
| P0 | Bug visual | Screenshot Langganan: harga utama pada kartu gelap hampir tidak terlihat. `subscription_screen.dart` mencampur warna literal, `OTColors`, dan teks promosi. | Harga dan keputusan pembelian tidak terbaca. | Periksa semua keadaan harga, pilihan periode, loading, error, dan tema sebelum mengubah dekorasi. |
| P0 | Lokalisasi | `subscription_screen.dart` masih mempunyai banyak teks UI Indonesia langsung. `Loc.text` hanya menerjemahkan string yang cocok persis dengan entri katalog. | Bahasa Inggris dan Arab dapat bercampur Indonesia. | Pisahkan string UI dari data kitab dan wajibkan tiga padanan untuk UI. |
| P0 | Konsistensi sistem | `AppTheme`, `OTColors`, dan `NativeColors` mempunyai palet berbeda; `NativeTheme` mengubah sebagian tema secara lokal. | Layar dan overlay tampak sebagai produk berbeda. | Satu `ColorScheme` semantik dan satu skala tipe/bentuk/ruang untuk UI native; adaptasi khusus konten dijelaskan eksplisit. |
| P1 | UX Asisten | `specialist_list_screen.dart` merender hampir semua agen melalui `ListView.separated` dan `SpecialistCard` yang sama. Screenshot menunjukkan deretan baris berulang dengan label Pustaka. | Dedikasi setiap asisten tidak terlihat; sulit memahami kapan harus memilih satu agen. | Pengenalan singkat berbasis peran nyata, sumber nyata, dan langkah masuk yang jelas. Pertahankan daftar efisien untuk hasil pencarian. |
| P1 | UX Pustaka | Ada dua jalur, `book_catalog_screen.dart`/`book_detail_screen.dart` dan `book_library_editorial_screen.dart`/detail editorial. Screenshot ringkasan pustaka menonjolkan empat angka sebelum pekerjaan utama. | Model mental pengguna terpecah antara koleksi, kitab, dan edisi. | Satukan pola pencarian, filter, baris kitab, detail bibliografi, serta hubungan ke asisten. Metrik pendukung ditempatkan setelah aksi utama. |
| P1 | Adaptivitas | Navigasi ponsel dan desktop dibuat manual dalam `main_shell_screen.dart`; banyak halaman memakai inset fisik `fromLTRB` dan baris berukuran tetap. | Risiko posisi Arab/RTL salah, teks panjang terpotong, pengalaman desktop tidak menyatu. | `NavigationBar`/`NavigationRail` sebagai dasar, `EdgeInsetsDirectional`, dan lebar berdasarkan ruang tersedia. |
| P1 | Tipografi/offline | Font lokal sudah dibundel, tetapi `ScholarlyFonts` masih memanggil `GoogleFonts`. Pratinjau otomatis sebelumnya tidak dapat memuat font dengan setia tanpa jaringan. | Rasa visual berubah menurut koneksi dan hasil verifikasi bisa menipu. | Pastikan keluarga font lokal benar dan gunakan jalur tunggal untuk teks UI dan Arab. Verifikasi pada perangkat offline. |
| P1 | Keadaan UI | `specialist_list_screen.dart` mengganti kegagalan pemuatan dengan `defaultAgents` tanpa memberi tahu pengguna; layar yang lain punya pola loading/error/empty berbeda. | Kegagalan layanan dapat tampak sebagai daftar normal. | Kontrak loading, kosong, error, retry yang sama; data fallback diberi konteks jujur. |
| P2 | Preferensi visual | Screenshot Beranda, Pengaturan, dan Langganan menunjukkan radius, kepadatan, judul, dan kontras yang tidak senada. | Kesan produk terfragmentasi. | Gunakan bentuk dan containment sesuai hierarki, bukan satu kartu untuk setiap informasi. |
| P2 | Aksesibilitas | Kontrol kustom seperti bar navigasi dan filter perlu audit fokus, semantik, ukuran target, serta reduced motion. | Pengguna keyboard dan pembaca layar mungkin kesulitan. | Komponen Material standar lebih dulu, lalu uji aksesibilitas untuk semua kontrol kustom. |

Temuan visual berasal dari screenshot pengguna. Temuan kode berasal dari pemeriksaan statis. Kegagalan pada semua perangkat belum dapat dipastikan tanpa pemeriksaan interaktif.

## Kontrak desain yang akan diuji

1. **Warna:** palet netral hangat OpenTurath dan satu aksen tindakan dari identitas yang sudah ada. Turunkan peran tonal terang/gelap melalui `ColorScheme`; gunakan `primary`, `onPrimary`, `surfaceContainer`, `onSurfaceVariant`, `outlineVariant`, dan `error` sesuai fungsinya. Jangan mengunci warna teks manual di atas latar yang dapat berubah. Warna tidak dipakai untuk mengarang status keilmuan.
2. **Tipografi:** sans-serif lokal untuk navigasi, kontrol, label, angka, dan teks UI; aksen editorial hanya untuk judul karya yang memang dibaca sebagai judul; font Arab lokal untuk matan dan judul Arab dengan ruang harakat. Hirarki M3 `headline`, `title`, `body`, `label` dipetakan ke keluarga font tersebut. Ukuran font mengikuti pengaturan aksesibilitas.
3. **Bentuk:** bentuk membedakan fungsi. Pencarian dan tindakan utama nyaman disentuh, kelompok informasi memakai containment seperlunya, daftar kitab yang padat tidak dipaksa menjadi kartu tinggi. Bentuk besar ditujukan pada fokus dan pilihan penting, bukan diterapkan ke semua komponen.
4. **Gerak:** transisi pilihan filter, perpindahan tujuan, buka lembar detail, dan perubahan state memberi orientasi. Tidak ada animasi masuk berulang pada setiap baris. Kurangi atau matikan gerak saat preferensi sistem meminta reduced motion; hentikan auto-scroll ketika pengguna mengambil alih.
5. **Konten:** asisten dibedakan berdasarkan mandat, cakupan, kitab rujukan, dan status akses yang benar-benar tersedia. Tidak ada avatar, angka, reputasi, atau klaim akurasi rekaan. Judul dan metadata kitab mengikuti data sumber, bukan diterjemahkan otomatis tanpa otoritas bibliografi.
6. **Tata letak:** konten utama memakai ukuran baca maksimum pada tablet/desktop. Pada ponsel sempit, prioritas dipertahankan lewat reflow, bukan huruf kecil dan pemotongan. Arah navigasi mengikuti bahasa UI; blok kutipan Arab diisolasi RTL; kode, harga, email, dan sitasi campuran diisolasi sesuai arah masing-masing.

## Peta layar dan perubahan yang direncanakan

| Permukaan | Pekerjaan utama | Komponen/pola sasaran |
| --- | --- | --- |
| Shell ponsel dan desktop | Navigasi empat tujuan dan ruang kajian yang bertahan saat berpindah | `NavigationBar` / `NavigationRail`, state terpilih, label jelas, fokus keyboard, overlay agen tetap hidup |
| Beranda | Masuk ke telaah dan menemukan bidang | Satu aksi utama; bidang sebagai pilihan terstruktur; kalender sebagai informasi sekunder |
| Asisten | Memilih spesialis yang tepat | Kelompok bidang, pencarian, ringkasan mandat/sumber per agen, detail pendek saat diperlukan, keadaan tersedia/akan hadir |
| Ruang AI/WebView/multi-tab | Bertanya dan berpindah agen tanpa kehilangan sesi | Shell native selaras warna, safe area, keyboard, fokus, status koneksi; DOM NotebookLM diperlakukan terpisah dan diuji ulang |
| Ringkasan pustaka | Mengetahui koleksi lalu membuka katalog | Identitas koleksi dan aksi di atas; statistik terverifikasi menjadi rincian pendukung |
| Kedua jalur katalog | Mencari kitab, menyaring, meninjau hasil | SearchBar, filter yang reflow, baris kitab yang padat, jumlah hasil, loading/kosong/error |
| Kedua jalur detail kitab | Membaca identitas kitab, metadata edisi, menyalin sitasi | Judul Arab dengan arah benar, urutan bibliografi jelas, tindakan simpan/salin, metadata kosong dihilangkan |
| Catatan, bookmark, pembaca catatan | Menemukan dan melanjutkan telaah | Hierarki daftar, pencarian/filter, kutipan Arab, aksi edit/hapus dengan undo atau konfirmasi |
| Pengaturan, profil | Memahami akses, mengganti tema/bahasa | Ringkasan akun yang ringkas, kelompok pengaturan, segmented control yang dapat reflow |
| Langganan dan pembayaran | Membandingkan harga dan menyelesaikan checkout | Harga terbaca, satu pilihan paket yang nyata, perincian durasi, status transaksi/error, tanpa klaim promosi rekaan |
| Login, sesi Google, splash | Masuk dan pulih dari kendala | Bentuk/warna tema yang sama, feedback jelas, fokus dan state aksesibel |
| Dialog, sheet, snackbar, update | Menyelesaikan tugas sekunder | Token semantik dan standar interaksi bersama, lebar adaptif, aman terhadap keyboard |

## Urutan pelaksanaan setelah rencana ini

1. **Baseline visual dan data.** Catat screenshot layar penuh dari alur nyata untuk ID/EN/AR, terang/gelap, ponsel kecil/besar, serta jendela desktop. Catat setiap tombol dan keadaan kosong/loading/error. Selesaikan akses SDK dan perangkat uji. Jangan membuat APK rilis.
2. **Satu prototipe representatif yang setia.** Mulai dari direktori Asisten karena masalah identitas setiap AI paling terasa. Gunakan agen dan rujukan yang ada dalam model, bukan sampel palsu. Periksa tampilan, scroll, pemilihan agen, pintu Pustaka, filter, dan Arab/RTL secara interaktif. Tunjukkan hasil layar penuh untuk penilaian visual sebelum pola disebar ke layar lain.
3. **Fondasi bersama.** Konsolidasikan token warna, tipe, bentuk, ruang, motion, dan keadaan komponen. Migrasikan navigasi ke widget M3 tanpa menghilangkan sesi AI. Hilangkan percabangan tema yang saling bertentangan dan font UI yang bergantung jaringan.
4. **Alur pustaka ujung ke ujung.** Ringkasan koleksi, katalog, detail, sitasi, bookmark; satukan dua jalur dan selesaikan data arah tulisan serta lokalisasi UI tiga bahasa.
5. **Alur lain.** Beranda, catatan, pengaturan, autentikasi, langganan, checkout, WebView/sheet, layar error dan pembaruan. Setiap perubahan layar punya checkpoint Git sendiri dan tidak menumpuk dengan pekerjaan lain.
6. **Verifikasi akhir.** Jalankan analisis dan tes yang relevan, kemudian audit visual/interaksi nyata untuk kombinasi bahasa, tema, ukuran layar, skala teks, input keyboard, pembaca layar, dan kegagalan jaringan. Pantau performa scroll dan jangan memuat ulang sesi AI. APK lokal hanya setelah pengguna meminta; publikasi versi tetap memerlukan instruksi rilis terpisah.

## Kriteria penerimaan

- Setiap asisten punya alasan pemilihan yang terbaca dari data nyata, tanpa 21 kartu seragam dan tanpa mengorbankan pencarian cepat.
- Semua teks **antarmuka** di alur utama memiliki ID/EN/AR; teks sumber kitab tetap dalam bahasa aslinya. Tidak ada potongan Indonesia saat UI berada dalam Arab atau Inggris.
- RTL mengubah urutan navigasi dan posisi kontrol dengan benar; kutipan Arab serta string campuran tidak membalik angka, nama berhuruf Latin, email, atau sitasi.
- Tidak ada clipping/overflow pada lebar 320, 360, 390, 600, dan 1024 logical px, skala teks 1.0/1.3/1.6, serta keyboard perangkat terbuka.
- Teks dan harga lolos pemeriksaan kontras; seluruh kontrol punya label, target sentuh, fokus, dan tindakan yang nyata.
- Mode terang/gelap, loading/kosong/error, akses aktif/tidak aktif, offline, dan sesi yang dipulihkan diperiksa secara visual.
- Pergantian tab, katalog, catatan, dan ruang AI terasa satu aplikasi tanpa reload percakapan atau lonjakan layout.
- Tidak ada klaim “desain selesai” berdasarkan tes widget saja. Bukti akhir mencakup screenshot layar penuh dan catatan klik alur utama.

## Yang belum dilakukan

Belum ada perubahan pada UI produksi, belum ada prototipe visual yang disetujui, belum ada verifikasi perangkat nyata, dan belum ada APK. Dokumen ini adalah gerbang perencanaan agar perubahan berikutnya dapat dinilai sebelum menyebar ke seluruh aplikasi.
