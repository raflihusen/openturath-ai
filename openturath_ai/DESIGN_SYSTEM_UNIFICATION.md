# OpenTurath — Kontrak Penyatuan Bahasa Desain

Dokumen ini menjadi acuan wajib untuk seluruh UI Flutter native, kecuali layar
Ruang AI berbasis WebView dan alur login Google yang sengaja dipertahankan.

## Karakter visual

- Editorial, tenang, dan mudah dibaca; bukan tampilan promosi teknologi.
- Mode terang memakai latar kertas netral. Mode gelap tetap tersedia sebagai
  pilihan pengguna, bukan gaya wajib untuk kartu tertentu.
- Garis tipis, ruang kosong, dan hierarki tipografi membentuk kedalaman.
- Tidak memakai gradien dekoratif, glow, warna emas, kartu bertumpuk, atau
  label berlebihan.

## Tipografi

- Newsreader: judul halaman, judul bidang, judul kitab, dan angka utama.
- Outfit: navigasi, tombol, input, metadata, label, dan isi antarmuka.
- Scheherazade New: judul Arab, kutipan Arab, matan, syarah, dan ibarah.
- Maksimal tiga tingkat penekanan pada satu permukaan.

## Bentuk dan jarak

- Radius kecil 8: badge dan elemen mikro.
- Radius sedang 12: input, tombol sekunder, dan baris tindakan.
- Radius utama 16: kartu dan panel.
- Radius sheet 24 hanya untuk sudut atas bottom sheet.
- Semua jarak mengikuti skala 4, 8, 12, 16, 20, 24, 32, 40, 48, 64.
- Pil penuh hanya untuk filter pilihan tunggal dan tombol aksi utama.

## Bahasa antarmuka

Gunakan bahasa yang langsung menjelaskan fungsi. Hindari istilah promosi,
metafora berlebihan, dan istilah teknis internal.

| Hindari | Gunakan |
|---|---|
| Daulat / Sovereign / Flagship | Paket lengkap atau tanpa label |
| Korpus | Koleksi kitab |
| Indeks korpus | Pilih bidang |
| Ruang kajian | Percakapan |
| Asisten kajian | Asisten |
| Arsip kajian | Catatan tersimpan |
| Khazanah ulama | Karya ulama |
| Super AI | Asisten |
| Masa akses terdekat berakhir | Aktif hingga |
| Tervalidasi | Terverifikasi |

Kata Arab atau istilah keilmuan tetap dipakai bila memang merupakan nama ilmu,
judul kitab, kutipan, atau istilah yang lazim bagi pengguna sasaran.

## Anatomi layar

1. Judul halaman dan satu keterangan singkat bila diperlukan.
2. Kontrol utama: pencarian, filter, atau aksi.
3. Isi utama dalam daftar atau kartu dengan anatomi yang konsisten.
4. Keadaan kosong, memuat, gagal, dan terkunci memakai komponen sistem.
5. Maksimal satu tombol primer yang dominan dalam satu bagian layar.

## Kriteria selesai

- Tidak ada warna mentah atau `Colors.*` untuk tampilan produk.
- Tidak ada radius dan padding bebas di luar token sistem.
- Semua target sentuh minimal 44 dp.
- Teks tetap terbaca pada skala 1.3 dan layar 360 dp.
- Tampilan terang dan gelap memiliki hierarki yang setara.
- Semua teks antarmuka lolos pemeriksaan istilah alami.
- `flutter analyze`, seluruh test, dan build APK rilis berhasil.
