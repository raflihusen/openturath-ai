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

Angka gerak splash, loader, dan login dirancang di `motion/src/spec.ts` (Remotion) dan dicerminkan di `OTMotion`.

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
- WebView dipertahankan ketika overlay error tampil sehingga retry tidak menargetkan view yang sudah dilepas. Tidak ada penundaan minimum dekoratif. Pemulihan autentikasi nyata tetap memerlukan percakapan terautentikasi; render fixture dan tes adapter tidak membuktikannya.
- Verifikasi snapshot menggunakan rute AI sebenarnya, enam lebar 320–1440, tema gelap, Arab, dan pembesaran teks. Penerimaan visual pengguna dan performa perangkat dicatat terpisah dari kelulusan tes.


## Penyempurnaan kompak — 7 Oktober 2026

Aturan ini menggantikan komposisi audit sebelumnya: watermark Arab tipis opacity 9% berada di belakang isi, tanpa footer atau padding khusus. Kartu bidang tinggi dasar 144 dan bertumbuh mengikuti skala teks. Beranda menggabungkan sapaan dan lanjut sesi dalam satu kartu.

Tombol Buka AI Fikih Tahawwulat membuka sheet berisi lima AI dengan fungsi singkat dan jalur masing-masing; tidak langsung membuka AI utama. Fungsi ini menjadi pengecualian subtitle hanya di pemilih khusus tersebut. Profil menyatukan nama, email, paket, dan masa berlaku dalam panel kompak. Pilihan tampilan hanya ikon ber-tooltip; pilihan bahasa tetap ID–EN–AR.

Loader kembali ke empat folio rounded yang sebelumnya dipilih pengguna. Katalog memakai garis punggung buku tipis dan metadata dekat judul/pengarang. Pembayaran menggunakan header tonal, durasi pill, harga faktual, dan receipt sukses hanya setelah invoice dikonfirmasi lunas. Permukaan gelap #292929 dan tonal #353535 menjaga siluet rounded terhadap canvas.
