# OpenTurath — Design System Unification Walkthrough

Tanggal verifikasi: 21 September 2026 (Asia/Aden)

## Titik pemulihan

- Branch pengerjaan: `codex/design-system-unification`
- Tag sebelum perubahan: `pre-design-unification-20260921`
- Commit awal yang ditandai: `d0db418e9d2c00c1cbbfb540f55b16ae5177e92f`
- Perubahan disimpan dalam 20 checkpoint terpisah agar dapat ditinjau atau dipulihkan secara bertahap.

## Bahasa desain final

- Satu palet monokrom adaptif untuk mode terang dan gelap; warna sage hanya dipakai sebagai status bermakna.
- Geometri baku: radius kecil 8, kontrol 12, kartu/dialog 16, dan sheet 24.
- Tombol tidak lagi otomatis berbentuk kapsul; bentuk kapsul hanya untuk chip atau status.
- Newsreader dipakai untuk judul editorial, Outfit untuk antarmuka, dan Scheherazade New untuk teks Arab.
- Animasi memakai satu kurva tenang `Cubic(0.16, 1, 0.3, 1)` dengan durasi bersama.
- Warna, radius, tipografi, jarak, dan gerak mengambil token pusat, bukan nilai lepas per layar.

## Perubahan utama

### Beranda dan navigasi

- Kartu utama Beranda menjadi panel editorial yang berbeda jelas dari ringkasan akun di Pengaturan.
- Tanggal Masehi dan Hijriah berada dalam panel tersendiri yang rapi di bagian bawah kartu.
- Kartu bidang, pencarian, navigasi bawah, indikator, dan pengumuman mengikuti geometri yang sama.
- Copy seperti “indeks korpus” dan “ruang kajian” diganti dengan bahasa pengguna yang lebih langsung.

### Asisten dan Fikih Tahawwulat

- Kartu asisten reguler dan unggulan memakai satu keluarga visual tanpa warna emas, panel hijau, atau efek eksklusif yang bertabrakan.
- Istilah seperti “daulat”, “sovereign”, “Super AI”, dan metrik semu dihapus dari teks yang terlihat pengguna.
- Keistimewaan Fikih Tahawwulat disampaikan lewat hierarki isi, bukan bahasa visual yang terpisah dari aplikasi.

### Pengaturan dan langganan

- Kartu akun disederhanakan menjadi ringkasan identitas, status, asisten yang tersedia, dan masa aktif.
- Struktur lama yang menimbulkan bayangan status bertumpuk dihapus.
- Pemilih tema, daftar pengaturan, dialog, voucher, paket, dan checkout memakai kontrol 12 dp serta panel 16 dp yang konsisten.
- Copy akses disederhanakan menjadi istilah natural seperti “Aktif hingga”, “Asisten”, dan “Kelola langganan”.

### Catatan

- Daftar, pembaca, editor, pratinjau, toolbar, tombol simpan, dan blok kutipan memakai geometri serta warna yang sama.
- Judul jawaban tetap mengambil heading pertama, sedangkan label teknis dan judul ganda dihapus.
- Copy dan hierarki metadata dibuat lebih ringkas untuk layar ponsel.

### Pustaka

- Halaman ringkasan, katalog, pencarian, filter, kartu kitab, detail kitab, metadata, dan bottom sheet disatukan.
- Kartu kitab memprioritaskan judul Arab, pengarang, tahun wafat, jilid, serta fakta edisi yang benar-benar berguna.
- Permukaan putih/gelap mentah dan radius acak diganti token adaptif yang sama dengan aplikasi utama.

## Batasan yang sengaja dipertahankan

- `lib/widgets/agent_multi_tab_room.dart` tidak diubah.
- `lib/core/notebook_ui_script.dart` tidak diubah.
- Ruang AI, halaman internal WebView, dan login Google tidak didesain ulang sesuai arahan pengguna.
- Tidak ada unggahan APK, perubahan CDN, ataupun broadcast versi.
- Berkas pengguna dan cache Firebase yang sudah ada tidak disentuh.

## Hasil verifikasi

- Audit istilah dan token native: bersih di luar batasan yang dipertahankan.
- `flutter analyze`: lulus, 0 masalah.
- `flutter test`: 164/164 tes lulus.
- `flutter build apk --release`: berhasil 100%.
- APK lokal: `/Users/apple/Downloads/ramadhan/app-release-latest.apk`
- Ukuran: 64.112.246 byte.
- Timestamp: `2026-09-21 19:03:23 +0300`.
- SHA-256: `b70deaf127f57b767fa30e6b773c494361162b53002ca990f11db6a743cc6f4f`.
