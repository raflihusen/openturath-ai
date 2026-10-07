# Revisi artwork Fikih Tahawwulat

Pengguna meminta penggantian puzzle datar dengan ilustrasi 3D monokrom berdasarkan referensi yang diberikan, tipografi Arab lebih anggun, dan latar abstrak elegan.

Aset baru: `assets/images/tahawwulat-sculpture-v2.png`, 1254 x 1254, sekitar 2.2 MB. Dibuat melalui built-in imagegen dengan referensi pengguna. Tulisan visual diperiksa: الإيمان, الإسلام, الإحسان, علامات الساعة; posisi mengikuti referensi. Tidak ada judul Arab duplikat pada pembukaan Indonesia.

Hero dashboard, pilihan asisten utama, pembukaan pengenalan, dan diagram interaktif memakai aset yang sama. Empat sisi gambar dibuat memudar oleh shader UI. Permukaan hero memakai kurva arsitektural berkontras rendah; teks dan tombol tetap native Flutter. Legenda teks dan area sektor mempertahankan keyboard, sentuh, semantics, dan penjelasan ID/EN/AR.

Verifikasi revisi:
- Analyzer: No issues found, exit 0.
- Pengujian komponen dan penjagaan token: 11 passed, exit 0.
- Render layar final: 1 passed, exit 0, exception render menggagalkan pengujian.
- Desktop, ponsel, dark, dan pembukaan pengenalan diperiksa secara visual dari render Flutter. Fixture tidak membuktikan sesi akun langsung.
- Render sebelumnya dipertahankan; versi baru memiliki suffix `_sculpture_v2`.

Checkpoint sebelum revisi: `e43d72e`. Pemulihan dilakukan dengan revert per commit yang terkait, tanpa reset checkout bersama.

```text
fe266ce feat(artwork): tambahkan ilustrasi Tahawwulat 3D monokrom hasil imagegen
a9b5e8f feat(hero): integrasikan artwork 3D dan permukaan lipatan abstrak halus
95d3efe feat(hero): gunakan ilustrasi baru dan komposisi abstrak pada produk utama
b987529 feat(introduction): samakan latar hero abstrak dengan artwork utama
1ea33e3 feat(diagram): gantikan sektor datar dengan ilustrasi 3D dan legenda aksesibel
0c41531 fix(diagram): buat area sektor sentuh dan fokus keyboard pada ilustrasi
c149d5c style(artwork): rapikan integrasi ilustrasi Tahawwulat
d42b8ee style(artwork): rapikan integrasi ilustrasi Tahawwulat
cde9b23 style(artwork): rapikan integrasi ilustrasi Tahawwulat
02375fe style(artwork): rapikan integrasi ilustrasi Tahawwulat
657b17b docs(design): catat arah artwork 3D monokrom dan permukaan abstrak
eefa4bc docs(tokens): sinkronkan aset sculpture dan latar hero abstrak
18cbc58 fix(artwork): lembutkan empat tepi ilustrasi agar menyatu dengan hero
81adb63 style(artwork): rapikan shader penyatuan hero
ee756c1 feat(tokens): tambahkan mask transparan monokrom untuk artwork
3bda273 fix(tokens): gunakan warna dan radius bersama pada artwork
3b43f52 fix(tokens): gunakan radius panel untuk pilihan sektor
eda401d docs(review): simpan render sculpture v2 shell_desktop
286059b docs(review): simpan render sculpture v2 shell_phone
3daff67 docs(review): simpan render sculpture v2 dashboard_phone
a66eb44 docs(review): simpan render sculpture v2 dashboard_dark
a6754ad docs(review): simpan render sculpture v2 dashboard_ar
3d83413 docs(review): simpan render sculpture v2 assistants_id
8edc056 docs(review): simpan render sculpture v2 assistants_ar
e543926 docs(review): simpan render sculpture v2 tahawwulat_id
d867ad2 docs(review): simpan render sculpture v2 tahawwulat_phone
bbba9b3 docs(review): simpan render sculpture v2 tahawwulat_ar
d34f853 docs(gallery): tampilkan render revisi sculpture 3D terbaru
```
