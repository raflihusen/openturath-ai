# Checkpoint koreksi audit

Branch: `codex/visual-audit-fixes-2026-10-07`. Baseline: `c5da070`.

Setiap perubahan source diberi commit langsung. Pilih commit terkait untuk revert selektif; jangan reset seluruh workspace karena ada pekerjaan lain di repository ini.

```text
7edab1c fix(cards): pisahkan zona watermark Arab dari isi dan tindakan
158a6b1 fix(ai): rapikan hierarki kartu dan utamakan tombol buka AI
4beda59 fix(calendar): satukan dua tanggal dalam blok dengan informasi metode
764558f fix(dashboard): stabilkan zona kartu bidang dan susunan tiga angka pustaka
8d77e6d fix(tahawwulat): susun lima pilihan setara dan pusatkan baris pendek
eba02bf fix(hero): kurangi tinggi sculpture dan rapikan ritme produk eksklusif
3266ed9 feat(catalog): tambah kartu identitas kitab bersama tanpa nomor dekoratif
247730b fix(catalog): gunakan arah isi eksplisit dan hindari scroll tersembunyi
51be054 fix(library): rapatkan katalog dan satukan identitas detail tanpa kontrol ganda
75864e2 fix(canonical): terapkan identitas katalog bersama pada daftar kanonikal
dcf8474 fix(profile): sejajarkan kontrol dan jelaskan status akses tanpa simbol verifikasi
71975fd fix(tokens): gunakan langkah padding resmi pada pemilih AI
ceaad0b fix(reader): rapikan sampul dan navigasi bab serta isolasi bahasa artikel
7154dc5 fix(diagram): tampilkan sektor aktif dan padanan aksesibel menurut bahasa
b533a1d feat(motion): gunakan emblem OpenTurath dengan busur berkecepatan periodik
c33adea fix(activation): ganti piagam dekoratif dengan konfirmasi akses faktual
f048b8f fix(pricing): perjelas koleksi eksklusif dan harga nyata setiap durasi
44580f7 fix(webview): pertahankan view saat galat agar retry memakai controller hidup
1d1cbc6 style(dashboard): rapikan cabang layout metrik adaptif
2335430 style(reader): rapikan cabang navigasi jangkar
c7e0511 fix(navigation): gabungkan overview pustaka ke katalog yang dapat ditelusuri
930286d feat(library): tampilkan ringkasan koleksi langsung di katalog
82a6603 fix(login): samakan tipografi masuk dengan antarmuka sans OpenTurath
8cb4e66 fix(chat): beri label jelas pada tindakan salin dan simpan jawaban
39c82ab fix(loading): samakan indikator pemuatan katalog dengan loader bermerek
a65278c test(visual): ambil rute AI nyata enam lebar dan perbaiki fixture panduan serta auth
a78e56c fix(dashboard): avoid intrinsic measurement of responsive statistics
d572bcf style(catalog): use explicit loaded-state branch
35a54ba refactor(profile): keep brand explanation in expandable about section
64fefcb fix(navigation): allow corpus tabs to wrap with larger text
c0a6414 refactor(dashboard): group field names with counts and tighten cards
88bb2df refactor(pricing): compare durations in readable phone rows and emphasize flagship
eb81d20 refactor(catalog): tighten book grid while preserving identity space
a156a8c fix(copy): label the etiquette guide action explicitly
8e5eae3 style(flutter): format book_library_editorial_screen
d89e6ec style(flutter): format dashboard_screen
b75c28c style(flutter): format library_metadata_overview_screen
f2cee53 style(flutter): format profile_screen
56ec6f5 style(flutter): format subscription_screen
4a0f4b0 style(flutter): format agent_multi_tab_room
08619db style(flutter): format app_loader
f41bcbe style(flutter): format assistant_grid_card
7cea71f style(flutter): format book_identity_card
6e48981 style(flutter): format book_row_item
d7b3b55 style(flutter): format corpus_kind_control
dc01d59 style(flutter): format dual_calendar
f403185 style(flutter): format exclusive_activation_dialog
8b6c452 style(flutter): format native_turath_chat_view
d244bc5 style(flutter): format ot_ink_card
e14aa21 style(flutter): format tahawwulat_diagram
203e0a4 style(flutter): format tahawwulat_flagship_card
84cbe3d style(flutter): format tahawwulat_hero
1a11afb style(flutter): format tahawwulat_introduction_sheet
b7cd4a3 style(flutter): format render_screens_test
cff9ee4 docs(design): record audited component composition and verification limits
0350177 docs(tokens): synchronize audited cards calendar catalog and emblem motion
04ebeee fix(dashboard): reserve title wrap space in narrow shell cards
0c7884d fix(profile): wrap enlarged email at the account-domain boundary
c550efd test(activation): verify factual access expiry and absence of unsupported claims
0b14cc6 test(catalog): verify direct loaded library instead of removed overview
9d8bfb2 style(test): remove duplicate catalog import
53c7574 docs(loader): describe native emblem and arc motion
b86aede fix(catalog): reserve Arabic title and wrapped edition facts height
e861311 docs(catalog): record measured Arabic grid height
925bc95 fix(copy): use consistent muhaqqiq terminology across catalog searches
6c00df2 docs(review): preserve full audited Flutter gallery and motion previews
```
