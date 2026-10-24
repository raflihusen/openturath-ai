# OpenTurath — Pedoman Desain

> Konten adalah tokoh utama. Antarmuka mundur satu langkah.

Dokumen ini ditulis dari kode. Bila dokumen dan kode berbeda, kode di `lib/core/design/` yang benar, lalu dokumen ini diperbarui. Acuan lengkap lintas media (web, slide, media sosial, dokumen) ada di design system OpenTurath.

## 1. Satu sumber token

| Hal | Berkas | Aturan |
|---|---|---|
| Warna | `ot_colors.dart` → `OTColors` | Satu-satunya tempat nilai warna ditulis |
| Huruf | `ot_typography.dart` → `OTFontSize`, `OTTypography` | Sembilan ukuran, tiga bobot |
| Jarak | `ot_spacing.dart` → `OTSpacing` | Kelipatan 4 |
| Radius | `ot_radius.dart` → `OTRadius` | Lima langkah dan pil |
| Gerak | `ot_motion.dart` → `OTMotion` | 180 / 220 / 280 / 320 ms |

`AppTheme` hanya merakit `ThemeData` dari token itu; konstanta radius di sana adalah alias `OTRadius`. `NativeColors` dan `NativeType` adalah pembungkus tipis untuk layar native; kode baru memakai `OT*` langsung.

`lib/screens` dan `lib/widgets` tidak boleh memuat `fontSize:` berangka, `circular(` berangka, `Color(0x…)`, atau `Colors.*` selain `Colors.transparent`. `test/design_token_guard_test.dart` gagal bila aturan ini dilanggar.

## 2. Warna

Tinta dan kertas untuk segala hal yang bukan isyarat.

| Token | Terang | Gelap | Pakai untuk |
|---|---|---|---|
| `canvas` | `#F6F6F6` | `#151515` | Latar layar |
| `surface` | `#FFFFFF` | `#292929` | Kartu, sheet, dialog, input |
| `surfaceSubtle` | `#EDEDED` | `#353535` | Wadah tonal, micro-pill |
| `textPrimary` | `#171717` | `#F5F5F5` | Teks utama dan seluruh teks Arab |
| `textSecondary` | `#606060` | `#B8B8B8` | Metadata, label |
| `textTertiary` | `#6B6B6B` | `#9A9A9A` | Placeholder, hint |
| `border` | `#DADADA` | `#454545` | Pemisah isi dan batas sekunder |
| `borderSubtle` | `#EBEBEB` | `#2D2D2D` | Pemisah di dalam kartu |
| `borderStrong` | `#767676` | `#808080` | Batas kontrol |
| `accent` / `onAccent` | `#171717` / `#FFFFFF` | `#F5F5F5` / `#171717` | Tombol primer |
| `marja` | `#4A4A4A` | `#C4C4C4` | Status rujukan, bersama ikon dan label |
| `error`, `destructive` | `#B91C1C` | `#F87171` | Galat dan aksi permanen, bersama ikon dan pesan |
| `errorContainer` | `#FEF2F2` | `#2F1616` | Latar pesan galat |
| `shadow` | `#000000` | `#000000` | Dasar bayangan dan scrim, selalu dengan alpha |

- Merah adalah satu-satunya warna di luar tinta dan kertas di aplikasi.
- Warna emas (`#D4AF37`, `#FFD700`) dan gradasi amber dilarang.
- Teks di atas `accent` memakai `onAccent`, bukan putih atau hitam.
- Semua pasangan teks lolos WCAG AA (≥ 4,5:1) di kedua tema; diuji di `test/design_system_test.dart`.

## 3. Tipografi

Tiga lapis yang tidak dicampur: **Newsreader** (judul koleksi dan kitab), **Outfit** (antarmuka dan angka), **Scheherazade New** (seluruh teks Arab kitab). Antarmuka berbahasa Arab memakai Noto Sans Arabic.

### Skala `OTFontSize`

| Langkah | Peran |
|---|---|
| `s11` | Kepala seksi kapital, micro-pill |
| `s12` | Keterangan, metadata |
| `s14` | Teks antarmuka, tombol |
| `s16` | Teks baca Latin, judul kartu |
| `s18` | Judul seksi, Arab di daftar |
| `s20` | Judul kitab Latin, judul layar |
| `s22` | Arab syarah, wordmark |
| `s26` | Judul halaman, Arab matan, harga |
| `s36` | Display, satu kali per layar |

Tidak ada ukuran di luar skala dan tidak ada pecahan. Bobot hanya `w400`, `w600`, dan `w700`.

### Teks Arab

1. `TextDirection.rtl`, rata awal, spasi huruf 0.
2. Tinggi baris 1,85–1,9 agar harakat tidak terpotong.
3. Teks berharakat minimal `s18`; `s16` hanya untuk metadata pendek tanpa harakat.
4. Warna selalu `textPrimary` (metadata: `textSecondary`).

### Catatan fon

Bobot asli dibundel: Outfit 400/600/700, Newsreader 400/600, Scheherazade New 400/700. Tidak ada penebalan sintetis.

## 4. Jarak dan radius

`OTSpacing`: 4, 8, 12, 16, 20, 24, 32, 40, 48, 64.

| `OTRadius` | Nilai | Pakai untuk |
|---|---|---|
| `xs` | 8 | Tag, pegangan, butir daftar |
| `input` | 28 | Kolom isian, snackbar |
| `card` | 24 | Kartu |
| `dialog` | 28 | Dialog |
| `sheet`, `hero` | 32 | Sudut atas lembar bawah |
| `chip`, `button` | 999 | Tombol, chip, pencarian |

Permukaan utama dipisahkan oleh warna tonal dan jarak. Hindari garis luar pada setiap kartu; gunakan garis untuk pemisah isi, fokus, dan batas kontrol yang memerlukannya.

## 5. Komponen bersama

| Kebutuhan | Pakai | Berkas |
|---|---|---|
| Tombol | `FilledButton`, `OutlinedButton`, `TextButton` tanpa `style` | bentuk pil dan tinggi 48 dari `AppTheme` |
| Varian tombol | `OTButtons.destructive`, `.onInk`, `.quiet`, `.compactOutlined`, `.compactTonal` | `lib/core/design/ot_buttons.dart` |
| Chip pilihan | `OTChip` | `lib/widgets/ot_components.dart` |
| Judul halaman | `AppBar(title: Text(...))` tanpa `style` | Outfit `s20` dari tema |
| Kartu yang bisa dibuka | `OTBentoTile` | `lib/widgets/ot_motion_widgets.dart` |
| Tanda "buka" | `otChevronIcon(context)` | mengikuti arah baca |

Layar tidak menulis `styleFrom` sendiri; tes penjaga menolaknya.

## 5a. Kerangka layar

- Judul halaman, paling banyak satu baris kontrol, lalu isi.
- Kartu hanya untuk benda yang bisa dibuka: kitab, asisten, catatan.
- Satu aksi primer per konteks; masing-masing paket langganan memiliki aksi pembayaran sendiri.
- Tanpa hiasan yang tidak bermakna: nomor urut pada hal yang bukan urutan, panah serong, slogan kapital.
- Kartu bidang ilmu menampilkan nama Arabnya.

## 6. Gerak dan sentuhan

Angka gerak loader dan login dirancang di `motion/src/spec.ts` (Remotion) dan dicerminkan di `OTMotion`. Splash didefinisikan hanya di `OTMotion` (sekitar 2,3 detik): tujuh punggung kitab naik satu per satu, lengkung digambar menaunginya, kitab melebur menjadi logo (lengkung, kubah, dua halaman); seluruh susunan membesar mengikuti sisi terpendek layar (1× sampai 2×), wordmark huruf demi huruf, garis tipis, lalu semboyan tiga bahasa. Ketuk melompat ke akhir; gerak dikurangi menampilkan bingkai akhir 700 ms. Warna layar luncur bawaan (Android `launch_background_color`, iOS `LaunchBackground`) wajib sama dengan `canvasLight` (#F6F6F6) dan `canvasDark` (#151515).

Cepat 180ms, normal 220ms, lembar 280ms, transisi 320ms; kurva `easeOutCubic` (lembar: `easeOutQuart`). Elemen yang ditekan mengecil ke 0,985. Status memuat memakai indikator dan teks yang sesuai konteks; katalog menyediakan aksi mencoba kembali. Getar: `selection()` untuk tab dan chip, `light()` untuk kartu dan tombol, `success()` saat menyimpan catatan.

## 7. Suara dan istilah

Tenang, santun, apa adanya. Pesan sistem tidak memakai tanda seru: "Ibarah tersalin.", "Catatan disimpan.", "Belum dapat memuat data."

| Pakai | Bukan |
|---|---|
| Khazanah ulama | Karya ulama, daftar ulama |
| Bidang ilmu | Kategori, korpus |
| Ibarah | Teks naskah, kutipan Arab |
| Salin ibarah · Salin jawaban | Salin teks |
| Penahkik · Tahkik: | Pentahqiq, penyunting |
| Hadis · Akidah · Usul Fikih | Hadits · Aqidah · Ushul Fiqh |
| Nahwu, Sharaf, dan Balaghah | Saraf |
| Tasawuf & Akhlak | Tasawuf & Perilaku |

Tidak dipakai: komprehensif, terlengkap, terintegrasi, optimal, mutakhir, "AI paling canggih".

Data yang belum terverifikasi dibiarkan kosong. Kode voucher tidak pernah ditulis di layar; placeholder hanya "Masukkan kode akses".

## 8. Daftar periksa sebelum rilis

- [ ] `flutter analyze` tanpa temuan dan seluruh tes lulus, termasuk tes penjaga token.
- [ ] Tidak ada warna di luar tinta, kertas, dan merah galat.
- [ ] Teks Arab RTL, minimal `s18` bila berharakat, tinggi baris ≥ 1,85.
- [ ] Satu tombol primer per layar; target sentuh ≥ 44px.
- [ ] Pesan sistem tanpa tanda seru dan memakai istilah baku.
- [ ] Tidak ada kode voucher atau data karangan di layar.

## 2026-10-07 — Minimal scholarly workspace

Antarmuka memakai judul Outfit; Newsreader untuk koleksi dan kitab. Permukaan
bertingkat menggantikan garis di semua kartu. Canvas #F6F6F6 / #151515,
surface #FFFFFF / #292929, tonal #EDEDED / #353535.
Radius: input/dialog 28, card 24, sheet/hero 32, pill 999, xs 8.
Pencarian hadir sebelum panel beranda, navigasi berlabel, katalog berupa daftar
editorial. Kutipan Arab memiliki arah sendiri; satu istilah Arab tidak boleh
mengubah seluruh paragraf Indonesia menjadi RTL.

## Kontrak implementasi 7 Oktober 2026

Sumber terpadu lokal: `docs/design-system.json`, disinkronkan dengan kode token.
Proposal SaaS pada direktori bertanggal 30 September tetap merupakan arsip proposal.

- Beranda: sapaan, tanggal pendukung, pencarian sebelum konten utama, tiga kolom bidang pada desktop.
- Navigasi: rail berlabel mulai 600 px, sidebar diperluas mulai 1100 px, navigasi bawah pada ponsel.
- Pengaturan: identitas dan masa akses; pilihan tema vertikal pada layar sempit dengan teks besar.
- Koleksi: daftar kitab dengan tinggi mengikuti isi; kategori, jumlah, dan filter dalam satu alur.
- Langganan: durasi sebagai pilihan, satu harga utama dan total pada CTA. Nilai bisnis tidak diubah; harga coret tidak ditampilkan tanpa konteks pembanding.
- Jawaban: `ScholarlyAnswer` mempertahankan Markdown, paragraf bilingual, blok kode, dan sumber. Kutipan Arab dalam paragraf Latin tidak mengubah arah seluruh paragraf.
- Data: catatan edisi tidak disajikan sebagai nama muhaqqiq; angka dan tahun yang mencurigakan diberi catatan review tanpa mengarang koreksi.
- Semua perubahan bersifat lokal. Fixture visual memakai akun dan jawaban contoh, bukan bukti layanan terautentikasi.

Bukti dan batas verifikasi disimpan pada `reports/redesign-2026-10-07/IMPLEMENTATION.md`.

## Arah rounded flagship — tinjauan 7 Oktober 2026

Status: contoh Flutter terimplementasi lokal; penerimaan visual dan penyebaran menyeluruh masih menunggu tinjauan pengguna. `ot_expressive.dart` memuat peran monokrom untuk contoh flagship. Hero 36/28, panel 24; antarmuka sans dominan. Kalender ganda setara memakai satu waktu lokal, diperbarui tengah malam dan saat resume. Tidak ada subtitle akademik di kartu pemilihan asisten. Grafik empat sektor adalah ilustrasi editorial dengan atribusi, bukan data statistik. Loader dua busur rounded mengitari emblem OpenTurath dengan fase periodik 1800 ms dan berhenti untuk reduced motion/lifecycle tidak aktif.

Checkpoint awal: `7f00d89`. Perubahan website dan penghapusan yang sudah ada tidak termasuk pekerjaan ini. Golden diperbarui hanya setelah arah visual diterima.

## Ilustrasi Tahawwulat 3D — revisi visual 7 Oktober 2026

Permintaan pengguna menggantikan sektor datar dengan artwork hasil imagegen: `assets/images/tahawwulat-sculpture-v2.png`. Empat label Arab mengikuti posisi referensi; hero memakai fade tepi agar menyatu dengan charcoal, dan lipatan abstrak berkontras rendah menjaga area teks tetap terbaca. Pengenalan menggunakan aset yang sama dengan legenda teks dan area sektor untuk mouse, sentuh, keyboard, serta semantics. Artwork adalah ilustrasi editorial, bukan kutipan sumber atau grafik statistik. Sumber generasi disimpan terpisah; aset lama tidak dihapus.

## Koreksi pengguna — 7 Oktober 2026, AI refinement

Beranda tidak menampilkan hero Tahawwulat; produk utama tampil eksklusif pada halaman AI. Kartu ilmu dan AI memakai charcoal dengan watermark Arab besar pada opacity 10%, terpisah dari nama serta kontrol. Semua nama AI mendapat prefix AI; istilah asisten pada naskah antarmuka Indonesia diganti AI. Label Arab dekoratif dikecualikan dari semantics.

Pustaka dalam angka memakai kapsul metrik dengan angka dari katalog. Katalog mempertahankan RTL lokal, menambahkan identitas buku dan metadata pill. Profil tanpa pola kubah; masa berlaku menyatu dengan panel akses. Bahasa ID–EN–AR menggunakan kontrol pill yang sama dengan tampilan. Harga coret menggunakan regularAmount yang memang tercatat.

Loader dua busur mengitari emblem OpenTurath dengan fase periodik, kecepatan berubah, reduced motion dan lifecycle tetap dihormati. WebView memeriksa semua input yang terlihat, tidak menunggu spinner panel lain, dan menampilkan pesan kesiapan aktual. Tes adapter bukan bukti autentikasi Google end-to-end.


## Koreksi audit visual — 7 Oktober 2026

- Kartu bidang dan AI memakai zona dekorasi Arab tersendiri di footer. Judul dan jumlah AI berdekatan; tombol utama terang dan rujukan sekunder. Tidak ada subtitle akademik.
- Fikih Tahawwulat tetap hanya pada halaman AI, memakai sculpture 3D yang sudah diterima sebagai arah seni. Lima pilihan disusun lima kolom pada desktop dan baris terpusat ketika membungkus.
- Kalender ganda berada dalam satu panel dengan tombol metode. Statistik pustaka memakai tiga kolom atau susunan vertikal berdasarkan ruang komponen.
- Kedua katalog berbagi BookIdentityCard. Metadata berdekatan, toolbar ringkas, judul sumber tidak diedit. Jika nama pengarang sudah mengandung angka, label tahun tambahan disembunyikan; ini aturan tampilan, bukan koreksi metadata.
- Profil menggunakan inisial, paket dan masa berlaku faktual; bahasa ID–EN–AR sejajar dengan Tampilan. Penjelasan identitas pada Tentang dapat diperluas.
- Harga coret berasal dari regularAmount. Perbandingan durasi berupa baris pada ponsel, kartu sejajar pada desktop. Dialog aktivasi hanya menjelaskan akses yang benar-benar diberikan.
- Artikel pengenalan Indonesia tetap LTR dalam UI Arab, dengan pemberitahuan bahasa materi dan menu bab. Diagram memiliki indikator sektor terpilih.
- Loader native dua busur berujung rounded mengitari emblem OpenTurath; siklus 1800 ms, reduced motion statis, lifecycle/TickerMode dihormati.
- Status galat menggantikan seluruh viewport WebView dengan ColoredBox sesuai docs/STANDAR_IDEAL_WEBVIEW.md. Polling mempertahankan empat sampel berturut-turut, elapsed minimum 3000 ms, dan jeda 250 ms. Pemulihan autentikasi nyata tetap memerlukan percakapan terautentikasi; render fixture dan tes adapter tidak membuktikannya.
- Verifikasi snapshot menggunakan rute AI sebenarnya, enam lebar 320–1440, tema gelap, Arab, dan pembesaran teks. Penerimaan visual pengguna dan performa perangkat dicatat terpisah dari kelulusan tes.


## Penyempurnaan kompak — 7 Oktober 2026

Aturan ini menggantikan komposisi audit sebelumnya: watermark Arab tipis opacity 9% berada di belakang isi, tanpa footer atau padding khusus. Kartu bidang tinggi dasar 144 dan bertumbuh mengikuti skala teks. Beranda menggabungkan sapaan dan lanjut sesi dalam satu kartu.

Tombol Buka AI Fikih Tahawwulat membuka sheet berisi lima AI dengan fungsi singkat dan jalur masing-masing; tidak langsung membuka AI utama. Fungsi ini menjadi pengecualian subtitle hanya di pemilih khusus tersebut. Profil menyatukan nama, email, paket, dan masa berlaku dalam panel kompak. Pilihan tampilan hanya ikon ber-tooltip; pilihan bahasa tetap ID–EN–AR.

Loader kembali ke empat folio rounded yang sebelumnya dipilih pengguna. Katalog memakai garis punggung buku tipis dan metadata dekat judul/pengarang. Pembayaran menggunakan header tonal, durasi pill, harga faktual, dan receipt sukses hanya setelah invoice dikonfirmasi lunas. Permukaan gelap #292929 dan tonal #353535 menjaga siluet rounded terhadap canvas.


## Cairo dan katalog editorial — 7 Oktober 2026

Kontrak ini menggantikan rincian komposisi sebelumnya: Cairo asli 400/600/700 dibundel untuk UI Arab (lisensi OFL di aset); Outfit tetap untuk ID/EN dan Scheherazade untuk sumber kitab. Watermark ringkas Cairo 700 mengisi sekitar 85% lebar, opacity 8%, tanpa ruang tambahan dan dikeluarkan dari semantics. AI umum berjudul dan bermetadata terpusat, dengan pill ikon percakapan 72×48 dan lingkaran rujukan 48 terpisah. Hero eksklusif menyimpan tombol lima AI dan ikon rujukan di dalamnya. Logo rail 40 dalam area 56.

Katalog memakai daftar editorial sebagai default, tinggi mengikuti isi: identitas 70% dan metadata 30% pada desktop; bertumpuk pada ponsel. Tidak ada punggung buku dekoratif. Data kosong tidak menjadi nol. Beranda memakai divider antara identitas dan akses/sesi, kalender field terstruktur setara (angka hari 32), statistik berikon tanpa kapsul bertumpuk, dan adab ber-ID serta ikon stabil.

Loader empat folio memakai fase linear periodik 1800 ms dengan sudut theta − 0,45 sin(theta), repaint langsung dari controller; reduced motion dan lifecycle dipertahankan. Lima dokumen lokal dengan 46 section tersedia penuh ID/EN/AR melalui resolver reaktif, bukan teks Indonesia yang disalin ke dialog. Visual fixture dan hasil tes tidak membuktikan transaksi nyata atau autentikasi NotebookLM.

Statistik dashboard memakai panel selebar konten, terpisah dari adab, agar tiga metrik tidak berubah menjadi kolom sempit dan tinggi pada desktop menengah. Kontrol ikon menyertakan nama pada semantics ikon native; tooltip tetap tersedia tanpa label ganda. Nama navigasi AI konsisten pada ID/EN/AR.

## Kartu baca — 8 Oktober 2026

Arah Cairo, monokrom, watermark, artwork, dan motion yang telah diterima dipertahankan. Hasil pencarian AI memakai baris teks tanpa ikon dekoratif maupun tombol ikon tambahan; seluruh baris membuka AI dan rujukan tetap tersedia pada halaman AI. Hero memakai nama AI Fikih Tahawwulat. Setiap adab mempunyai kartu tonal tersendiri, ikon di sisi judul mengikuti arah UI, dan isi lengkap dipertahankan.

Katalog menggantikan pembagian 70/30 yang menyisakan ruang kosong dengan satu identitas bibliografis: judul dan pengarang mengikuti arah sumber, lalu divider halus dan metadata pill berkelompok pada sisi yang sama. Mode baca utama memakai dua kartu berdampingan bila lebar konten minimal 800 dan skala teks di bawah 150%; selain itu satu kartu per baris, tinggi mengikuti isi. Mode grid alternatif tetap tersedia. JSON, metadata, pencarian, filter, pengurutan, dan tujuan detail tetap dipertahankan.


## Kolom input WebView — 9 Oktober 2026

Presentasi NotebookLM memakai parent bersama terdekat antara pesan dan composer untuk membagi ruang secara vertikal. Jalur viewport dan transcript tumbuh mengisi layar; pembungkus yang hanya berisi input memakai tinggi alami dan tidak mengambil separuh ruang jawaban. Rantai menuju scroller pesan melepas batas tinggi lama agar jawaban panjang memakai sisa viewport dan tetap dapat digulir. Composer memiliki jarak bawah 22 px (atau safe area yang lebih besar), dengan susunan internal textarea dan tombol tetap asli.

Input yang terlihat tetap menjadi pemilik layout saat disabled selama generasi. Pemilihan ini terpisah dari polling kesiapan yang tetap mensyaratkan input aktif. Tinggi mengikuti visualViewport dengan fallback innerHeight. Kelas direkonsiliasi saat pesan muncul, DOM diganti, atau chat dikosongkan; node Angular tidak dipindahkan dan composer tidak diberi fixed positioning. Placeholder visual dihapus dengan mempertahankan label aksesibilitas.

Uji regresi WebKit mencakup cabang transcript/composer terpisah, pembungkus input dengan min-height/padding lama, scroller dengan max-height lama, serta transisi input disabled/aktif. Kasus tersebut gagal sebelum koreksi dan lulus sesudahnya. Uji juga mencakup empty/populated, jawaban panjang, resize, pergantian DOM, dan script lengkap. Pemeriksaan ini tidak membuktikan layout pada sesi NotebookLM asli; pemeriksaan runtime masih memerlukan sesi masuk. Lifecycle, empat sampel polling, minimum 3000 ms, jeda 250 ms, dan penggantian viewport galat tetap mengikuti docs/STANDAR_IDEAL_WEBVIEW.md.

## Alamat Google Notebook — 9 Oktober 2026

URL notebook dari server divalidasi terlebih dahulu, lalu hanya host lama notebooklm.google.com dinormalisasi ke notebook.google.com, tujuan redirect 301 Google yang terverifikasi. ID notebook, path, hak akses server, dan penolakan URL tidak tepercaya tetap dipertahankan. Halaman penghubung sesi Google juga memakai origin yang sama. Ini menghindari ketergantungan pada koneksi ke host lama sebelum redirect bisa dimulai; tidak mengganti ID notebook atau memintas TLS.

Audit lokal menemukan timeout TCP ke alamat hasil DNS host lama, sementara host tujuan dan Google Accounts merespons. Kegagalan tersebut terjadi sebelum dokumen/JavaScript dimuat, sehingga bukan akibat aturan layout composer. Lifecycle WebView, polling minimal empat sampel/3000 ms/250 ms, dan penggantian seluruh viewport pada galat tidak diubah. Perubahan host tidak menjamin ketersediaan layanan Google atau jaringan; verifikasi percakapan nyata tetap diperlukan.

## Persistensi login macOS — 10 Oktober 2026

Startup aplikasi tidak boleh menghapus entri sesi milik Firebase SDK. Pembersihan legacy sebelumnya memakai nama domain/key yang juga digunakan SDK resmi sebagai fallback macOS ketika Keychain ditolak, sehingga sesi terhapus pada setiap peluncuran. AppDelegate sekarang menyerahkan pemulihan/penyimpanan sesi sepenuhnya kepada SDK; logout tetap merupakan tindakan eksplisit pengguna.

Untuk versi lokal yang dipilih pemilik tanpa akun Developer berbayar, build memakai signature ad-hoc tanpa profil sementara atau entitlement Keychain yang membutuhkan izin Apple. Firebase SDK resmi tetap mengelola fallback macOS; aplikasi tidak membuat penyimpanan token sendiri. tool/macos/verify_firebase_fallback.py membuktikan data sintetis pada kelas SDK yang terpasang dapat dibaca oleh proses baru setelah proses pertama keluar. Bukti ini bukan pengganti login akun nyata dan uji tutup/buka. Pengemasan memverifikasi signature, versi sumber, kedua arsitektur, dan ketiadaan entitlement terlarang/profil kedaluwarsa. Distribusi yang diverifikasi Apple tetap memerlukan Developer ID dan notarisasi. Hak VIP/modul dan lifecycle WebView tidak diubah.

## Account subscription visibility — 2026-10-10

Beranda dan profil menampilkan tombol Langganan berlabel jelas langsung di bawah identitas pengguna. Tombol menggantikan ikon tune tersembunyi pada kartu profil dan membuka rute langganan yang sama. Status VIP dari profil server selalu mengungguli paket berbayar/expired. Paket aktif diberi PRO; masa coba diberi TRIAL; pembayaran tertunda tidak mengklaim PRO. Label ini hanya presentasi, tanpa mengubah otorisasi per modul maupun siklus hidup WebView. Kontrol memakai Wrap agar tetap terbaca pada layar sempit dan teks diperbesar.
