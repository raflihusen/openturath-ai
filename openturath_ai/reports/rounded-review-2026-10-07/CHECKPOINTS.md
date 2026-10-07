# Checkpoint redesign rounded

Branch: `codex/rounded-flagship-review-2026-10-07`

Baseline sebelum pekerjaan: `7f00d890cb62d8f2aab4a41fc79c5dae21c0548b`.

Setiap perubahan source dan setiap aset review dicatat segera dengan file eksplisit. Perubahan website dari task lain tidak termasuk daftar berikut. Deletion lama di promo dan artefak lain tetap dipertahankan; tidak ada reset, stash otomatis, push, atau publikasi.

Untuk mengembalikan satu perubahan setelah meninjau commit: `git revert <hash>`. Untuk beberapa commit komponen, revert berurutan dari yang terbaru. Jangan memakai reset terhadap checkout bersama yang memiliki pekerjaan lain.

## Daftar checkpoint

```text
6dfca6d feat(diagram): tambahkan empat sektor monokrom dengan label dan pilihan aksesibel
59f148a fix(diagram): gunakan keluarga font Arab antarmuka yang tersedia
1d5cae4 feat(flagship): buat hero charcoal dominan dengan diagram dan dua tindakan utama
82e0ff9 fix(assistants): hapus subtitle akademik dan pisahkan tindakan kartu
c831c77 feat(calendar): tampilkan dua kalender setara dengan pembaruan tengah malam dan resume
f4ddf9b feat(dashboard): pusatkan hero Tahawwulat kalender setara dan arah bidang bilingual
99e25c5 feat(flagship): gunakan hero unggulan dan hapus subtitle lima asisten
004a235 feat(catalog): tambah grid adaptif urutan tampilan dan navigasi tunggal
68894dd feat(introduction): buat sampul rounded grafik sektor dan hapus judul Arab duplikat
4cb3c79 fix(assistants): hilangkan subtitle akademik dari kartu hasil pencarian
cd19b33 fix(catalog): gunakan helper arah paragraf aktif
dc70145 feat(loading): buat busur dinamis dengan fase kontinu dan penghentian ticker
7597ce8 style(motion): tetapkan siklus loader busur menjadi 1800 milidetik
86dbcfa feat(profile): buat identitas inisial dan panel akses terpisah dengan tanda OpenTurath
349db62 style(tokens): pusatkan peran warna dan bentuk arah monokrom unggulan
508f5f8 refactor(tokens): selaraskan tahawwulat_diagram.dart dengan token monokrom
c82cbb6 refactor(tokens): selaraskan tahawwulat_hero.dart dengan token monokrom
cf30e1a refactor(tokens): selaraskan dual_calendar.dart dengan token monokrom
f826465 refactor(tokens): selaraskan tahawwulat_introduction_sheet.dart dengan token monokrom
5f44bc7 refactor(profile): gunakan radius panel baku
ebc5106 refactor(dashboard): hapus import kalender lama
3710f60 fix(introduction): arahkan mulai membaca ke bagian pertama yang tersedia
b9ac574 fix(assistants): jadikan buka asisten tombol aktif terpisah
195519c fix(catalog): sediakan ruang judul tiga baris dan pengarang dua baris tanpa overflow
17334c5 fix(diagram): tempatkan label di pusat sektor dan hindari pemotongan teks
e365b76 style(profile): jaga baris tindakan akun dalam palet monokrom
c243281 feat(flagship): susun lima pilihan asisten rounded tanpa kartu bertumpuk dan subtitle
b64eb75 refactor(diagram): gunakan ukuran label responsif dari skala token
0cd8447 style(tokens): tetapkan tiga ukuran label diagram menurut lebar
303807d style(profile): tambahkan motif garis identitas yang halus di area profil
0bdd66f docs(design): catat arah flagship dan batas penerimaan contoh visual
6c17d66 docs(tokens): sinkronkan spesifikasi contoh unggulan dan status tinjauan
684138b feat(copy): tambahkan label loading umum dalam tiga bahasa
4bd9c55 fix(loading): gunakan label proses umum yang tersedia
eba6800 test(review): uji kalender aksi hero pilihan diagram dan reduced motion
7a9df56 style(format): rapikan ot_expressive.dart
e7bf32b style(format): rapikan ot_motion.dart
1062980 style(format): rapikan book_library_editorial_screen.dart
af9fba1 style(format): rapikan dashboard_screen.dart
e5fc543 style(format): rapikan profile_screen.dart
fe12c25 style(format): rapikan app_loader.dart
36849be style(format): rapikan assistant_grid_card.dart
fee4510 style(format): rapikan dual_calendar.dart
ba8fd55 style(format): rapikan specialist_card.dart
f0daeb8 style(format): rapikan tahawwulat_diagram.dart
984cec6 style(format): rapikan tahawwulat_flagship_card.dart
1d873bc style(format): rapikan tahawwulat_hero.dart
be39b3b style(format): rapikan tahawwulat_introduction_sheet.dart
c1e731f style(format): rapikan rounded_flagship_review_test.dart
8d4d70b fix(catalog): batasi area judul sesuai kartu dan dekatkan metadata pengarang
36b258e test(motion): tangkap dua belas fase loader dan gagalkan render yang error
458b15e fix(introduction): tampilkan sampul dan grafik juga pada halaman ponsel
9f4726d style(flagship): ringkas ilustrasi ponsel agar pencarian lebih mudah dijangkau
28cb504 fix(flagship): pastikan nama lima asisten kontras pada tombol tonal
3381789 feat(book-detail): satukan identitas arah isi dan tindakan rujukan berlabel
b7feb97 fix(catalog): batasi lebar pilihan urutan untuk pembesaran teks dua kali
a441412 refactor(introduction): tegaskan blok kondisi navigasi dan layout
000fd5c style(format): rapikan book_library_editorial_screen.dart
732950c style(format): rapikan tahawwulat_flagship_card.dart
d55e902 style(format): rapikan render_motion_test.dart
92bc3d2 fix(introduction): tampilkan pilihan nama tanpa subtitle dan pisahkan bantuan
fe02da0 test(assistant): pastikan subtitle akademik tidak muncul pada kartu
3b8485c fix(introduction): hubungkan lokalisasi pemilih asisten
6b73384 style(format): rapikan pilihan asisten dan pengujiannya
dd583e3 style(format): rapikan pilihan asisten dan pengujiannya
67a7a06 fix(introduction): bungkus label lapis penjagaan pada layar sempit
637f231 fix(introduction): letakkan diagram interaktif pada pembahasan empat rukun
779c72a fix(introduction): gunakan warna caption dari tema bagian pembahasan
3ad1e2a style(introduction): rapikan komposisi diagram pembahasan
b12f01e test(motion): rekam satu siklus loader pada 60 fase untuk review gerak
e8324d6 docs(review): simpan render Flutter shell_desktop
f0a8926 docs(review): simpan render Flutter shell_phone
7c4c482 docs(review): simpan render Flutter dashboard_phone
cb7e6c6 docs(review): simpan render Flutter dashboard_ar
72dfd90 docs(review): simpan render Flutter dashboard_dark
5a85f1b docs(review): simpan render Flutter assistants_id
d1b6b2e docs(review): simpan render Flutter assistants_ar
6a3c0fa docs(review): simpan render Flutter library_books
32e037d docs(review): simpan render Flutter library_book_detail
b205d40 docs(review): simpan render Flutter library_ar_phone
cc12db8 docs(review): simpan render Flutter library_detail_phone
43f3bf3 docs(review): simpan render Flutter profile_id
4e5defe docs(review): simpan render Flutter profile_dark
1996c5f docs(review): simpan render Flutter profile_phone
b9b0754 docs(review): simpan render Flutter profile_ar
8479c38 docs(review): simpan render Flutter profile_large_text
3f2a9f0 docs(review): simpan render Flutter tahawwulat_id
aefa905 docs(review): simpan render Flutter tahawwulat_phone
d68a1bf docs(review): simpan render Flutter tahawwulat_ar
80cf2cc docs(motion): simpan siklus loader Flutter tema light
884987d docs(motion): simpan siklus loader Flutter tema dark
3113c19 docs(review): tampilkan galeri Flutter dan video gerak untuk evaluasi visual
```
