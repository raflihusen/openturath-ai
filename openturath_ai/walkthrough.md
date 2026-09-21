# OpenTurath Native UI — V6 Walkthrough

Tanggal verifikasi: 21 September 2026 (Asia/Aden)

## Titik pemulihan

- Tag sebelum pengerjaan: `pre-v6-redesign-v2`
- Commit awal yang ditandai: `809cf8d6c9ceb93976ceec7f2e8ccf30c3acc0c3`
- Setiap tahap desain disimpan sebagai commit terpisah agar dapat dipulihkan secara granular.

## Fondasi desain

- Newsreader 400/500/600 untuk judul editorial, nama kitab, dan angka monumental.
- Outfit 400/500/600/700 untuk antarmuka, metadata, tombol, dan navigasi.
- Scheherazade New 400/700 untuk teks Arab dengan fallback global dan tinggi baris aman 1.85–1.90.
- Seluruh font berasal dari aset lokal website OpenTurath V6 dan tidak bergantung pada jaringan.
- Palet native memakai token adaptif tunggal untuk mode terang dan gelap.
- Kurva interaksi V6: `Cubic(0.16, 1, 0.3, 1)`, 140 ms, skala tekan 0.985.
- Entrance bertahap menghormati preferensi reduced motion perangkat.

## Perubahan utama

### Beranda

- Hero kajian diberi watermark `تراث` yang halus.
- Ditambahkan Skala Pustaka monumental: 5.370 kitab, 1,1 M kata, 4,1 juta halaman, 11.901+ jilid, dan 20 disiplin.
- Kartu bidang mendapat nomor seri dan aksen kaligrafi Arab tanpa mengorbankan keterbacaan.

### Asisten

- Kartu spesialis dirombak menjadi arsitektur Bento V6: nomor seri, status, aksen Arab, judul editorial, ruang lingkup, dan metrik pustaka.
- Hadis memakai varian inverted yang terukur.
- Fikih Tahawwulat memakai Sovereign Card eksklusif: radius 24 dp, double hairline, watermark `تحولات`, dan aksen brass yang hanya digunakan pada flagship.

### Pustaka, bacaan, dan catatan

- Katalog, metadata pustaka, daftar kitab, detail kitab, bookmark, pembaca catatan, editor, serta lembar sitasi memakai keluarga font lokal yang sama.
- Kutipan Arab memakai Scheherazade New Bold dengan tinggi baris 1.9 agar harakat tidak terpotong.
- Warna hard-coded pada UI native dipindahkan ke token desain pusat.

## Batasan yang dipertahankan

- `lib/widgets/agent_multi_tab_room.dart` tidak diubah.
- `lib/core/notebook_ui_script.dart` tidak diubah.
- Alur login Google dan pengalaman internal WebView tidak didesain ulang.
- Tidak ada unggahan APK, perubahan CDN, atau broadcast versi Firestore.
- Aset publik SEO tidak dihapus atau dimodifikasi.

## Hasil verifikasi

- `flutter analyze`: lulus, 0 masalah.
- `flutter test`: 55/55 test yang tersedia di repositori lulus.
- `flutter build apk --release`: berhasil 100%.
- APK lokal: `/Users/apple/Downloads/ramadhan/app-release-latest.apk`
- Ukuran: 64.194.270 byte.
- Timestamp: `2026-09-21 14:01:00 +03`.
- SHA-256: `dac042962bf82af2ef724cb4ba6735ff3fd48162ba2c5371825193694549e4a3`.
