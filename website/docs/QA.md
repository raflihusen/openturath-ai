> Arsip revisi sebelumnya. Status terbaru ada pada AUDIT_WEBSITE_V4.md dan BROWSER_QA.json.

# Riwayat QA versi 1

Pengujian tambahan tercatat di `REDESIGN_V2.md` dan `REDESIGN_V3.md`. Angka ukuran aset di bawah adalah pengukuran V1; `ASSET_SIZES.json` berisi ukuran V3 saat ini.

# Verifikasi serah terima

Tanggal: 19 September 2026. Lingkungan: Node.js 24.19, Python 3.12, browser Chromium melalui preview lokal. Ini laporan pengujian website; bukan penilaian akurasi keilmuan AI.

## Otomatis

| Pemeriksaan | Hasil |
|---|---|
| Build preview | 160 dokumen HTML; 20 koleksi; 6 jawaban asli |
| `npm run check` | 159 halaman lokal, 8.034 referensi tautan/aset internal, tanpa kesalahan |
| Bahasa | Kunci kamus ID/EN/AR lengkap; `lang`/`dir`, judul utama dan route diperiksa |
| Arsip | Enam SHA-256 cocok; teks run ditemukan dalam ekspor asli; 10 kutipan ditemukan persis dalam jawaban |
| Node tests | 8 pengujian lulus: escaping, normalisasi Arab, URL, gerbang, Markdown, build release terisolasi, catatan rilis, pencabutan unduhan |
| Python tests | 11 pengujian lulus: validasi, penyimpanan, duplikasi, konflik, retensi, origin, mode nonaktif, rate limit, JSON/body |
| Build produksi memakai fixture terpisah | Lulus; menghasilkan QR tiga bahasa, metadata/schema, canonical, robots, halaman rilis dan mode laporan nonaktif. Fixture memakai domain `.invalid`, tidak ada koneksi eksternal |
| Build produksi konfigurasi pengguna saat ini | Ditolak sebagaimana dirancang: 11 kebutuhan data/persetujuan belum diisi; preview tidak dihapus |
| Sintaks | JS/module dan seluruh modul Python utama lolos parse/compile |
| Kemasan | ZIP dan manifest diperiksa setelah dibuat; database laporan, cache, backup konfigurasi dan secret tidak dimasukkan |

Pengecekan URL eksternal resmi tidak dilakukan karena listing APK/domain belum diberikan. Audit tautan di atas adalah tautan internal, bukan bukti semua URL percakapan pihak ketiga dapat dibuka publik.

## Browser yang dijalankan

- Beranda desktop diperiksa visual pada mode terang dan gelap; font lokal termuat.
- Beranda pada frame 390/320 CSS px; konten efektif 375/305 px dengan scrollbar. Tidak ada overflow horizontal pada pengukuran tersebut.
- Beranda Arab RTL dan menu ponsel diperiksa visual; dialog dibuka/ditutup, jumlah dialog terbuka kembali nol.
- Pencarian `الأُمّ` mengembalikan dua hasil; pencarian kosong/tidak cocok menunjukkan keadaan sesuai; filter Hadis menampilkan tiga hasil.
- Pergantian bahasa Arab → English pada detail Fikih Syafi'i mempertahankan route dan `?q=test`.
- Q001 memulihkan pembanding `right=nur` dari URL dan memasukkan dua jawaban lengkap ke panel.
- Tab ponsel menampilkan satu panel dan menyembunyikan panel lain; pemilih pembanding dapat diubah.
- Panel kutipan E03 dibuka; “Temukan dalam jawaban” menyorot teks yang tepat; mode baca masuk/keluar.
- Formulir mengisi konteks `q001-e03`; laporan sintetis berhasil tersimpan dan mengembalikan ID server. Tidak ada pesan yang dikirim ke orang lain. Data sintetis dikecualikan dari ZIP.
- Konsol pada sesi browser akhir: tidak ada error dari kode situs. Pesan ekstensi browser lingkungan tidak dihitung sebagai error aplikasi.

Bug yang ditemukan dan diselesaikan: selector bahasa sebelumnya mengenai elemen body dan menghentikan JS; fallback UUID untuk origin preview; form nonaktif; retry saat payload berubah; perlindungan draft yang diedit saat menunggu respons; kewajiban catatan rilis; rilis dicabut disembunyikan.

Reviewer kode terpisah memeriksa alur formulir, penyimpanan, escaping, origin, konfigurasi dan gerbang rilis. Tiga temuan penting diperbaiki, kemudian dikonfirmasi ulang.

## Anggaran dan batas pengukuran

Ukuran nyata ada di `ASSET_SIZES.json`. Pada build ini, JavaScript interaksi sekitar 10,4 KB mentah (3,9 KB gzip), CSS sekitar 35 KB (7,7 KB gzip), beranda Indonesia sekitar 18 KB (4,6 KB gzip). Halaman Q001 lebih besar karena memuat seluruh jawaban dan fallback tanpa JavaScript. Kompresi HTTP perlu diaktifkan di host agar ukuran gzip tersebut berlaku. Font lokal dimuat per kebutuhan bahasa; tidak ada framework runtime, video latar, remote font atau tracker.

Belum dilakukan: Lighthouse pada hosting produksi/koneksi seluler nyata; metrik Core Web Vitals lapangan; Safari/iOS/Android fisik, Firefox/Edge; audit VoiceOver/TalkBack/NVDA; audit formal WCAG; scan QR dari layar dengan ponsel fisik; uji TLS/DNS/SMTP/store/instalasi aplikasi; validasi independen sumber kitab; tinjauan legal operator. Mekanisme reduced-motion dan fallback tanpa JS tersedia dalam kode, belum diklaim sebagai sertifikasi aksesibilitas menyeluruh.

## Persyaratan rilis yang masih membutuhkan fakta

Domain resmi, lima kolom pengelola/kontak, minimal satu rilis aplikasi resmi beserta catatannya, paket akses yang disetujui, kebijakan final, persetujuan katalog, dan hak publikasi perbandingan. Lihat BUILD_REPORT.json. Tidak ada fakta tersebut yang diisi dengan contoh untuk membuat gerbang tampak lulus.
