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
| `canvas` | `#FAFAFA` | `#111111` | Latar layar |
| `surface` | `#FFFFFF` | `#191919` | Kartu, sheet, dialog, input |
| `surfaceSubtle` | `#F2F2F2` | `#242424` | Wadah tonal, micro-pill |
| `textPrimary` | `#171717` | `#F5F5F5` | Teks utama dan seluruh teks Arab |
| `textSecondary` | `#606060` | `#B8B8B8` | Metadata, label |
| `textTertiary` | `#6B6B6B` | `#9A9A9A` | Placeholder, hint |
| `border` | `#DADADA` | `#454545` | Garis kartu 0,8px |
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

Tiga lapis yang tidak dicampur: **Newsreader** (judul), **Outfit** (antarmuka dan angka), **Scheherazade New** (seluruh teks Arab kitab). Antarmuka berbahasa Arab memakai Noto Sans Arabic.

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
| `input` | 14 | Kolom isian, snackbar |
| `card` | 16 | Kartu |
| `dialog` | 20 | Dialog |
| `sheet` | 24 | Sudut atas lembar bawah |
| `chip`, `button` | 999 | Tombol, chip, pencarian |

Kedalaman dibangun dengan garis `border`, bukan bayangan.

## 5. Komponen bersama

| Kebutuhan | Pakai | Berkas |
|---|---|---|
| Tombol | `FilledButton`, `OutlinedButton`, `TextButton` tanpa `style` | bentuk pil dan tinggi 48 dari `AppTheme` |
| Varian tombol | `OTButtons.destructive`, `.onInk`, `.quiet`, `.compactOutlined`, `.compactTonal` | `lib/core/design/ot_buttons.dart` |
| Chip pilihan | `OTChip` | `lib/widgets/ot_components.dart` |
| Judul halaman | `AppBar(title: Text(...))` tanpa `style` | Newsreader `s20` dari tema |
| Kartu yang bisa dibuka | `OTBentoTile` | `lib/widgets/ot_motion_widgets.dart` |
| Tanda "buka" | `otChevronIcon(context)` | mengikuti arah baca |

Layar tidak menulis `styleFrom` sendiri; tes penjaga menolaknya.

## 5a. Kerangka layar

- Judul halaman, paling banyak satu baris kontrol, lalu isi.
- Kartu hanya untuk benda yang bisa dibuka: kitab, asisten, catatan.
- Satu tombol primer per layar.
- Tanpa hiasan yang tidak bermakna: nomor urut pada hal yang bukan urutan, panah serong, slogan kapital.
- Kartu bidang ilmu menampilkan nama Arabnya.

## 6. Gerak dan sentuhan

Angka gerak splash, loader, dan login dirancang di `motion/src/spec.ts` (Remotion) dan dicerminkan di `OTMotion`.

Cepat 180ms, normal 220ms, lembar 280ms, transisi 320ms; kurva `easeOutCubic` (lembar: `easeOutQuart`). Elemen yang ditekan mengecil ke 0,985. Memuat ditandai tiga titik berdenyut, bukan roda berputar. Getar: `selection()` untuk tab dan chip, `light()` untuk kartu dan tombol, `success()` saat menyimpan catatan.

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
