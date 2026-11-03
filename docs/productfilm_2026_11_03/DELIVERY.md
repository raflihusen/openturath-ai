# OpenTurath AI — Product Film

3 November 2026

[Tonton MP4](../../openturath_motion/out/OpenTurath_Product_Film_30s_9x16.mp4)

Film vertikal 30 detik. Komponen antarmuka dibangun sebagai layer DOM yang bergerak mengikuti frame, dengan satu contoh dari pemilihan bidang hingga membaca ulang jawaban dalam Catatan. Ini ilustrasi percakapan, bukan rekaman sesi AI langsung. Pembesaran, pemekaran panel, dan perpindahan elemen dirancang untuk film.

## Alur

| Waktu | Perubahan yang ditampilkan |
|---|---|
| 0–5,7 dtk | Enam bidang → AI Fikih → Fikih Syafi’i; kartu pilihan menjadi header ruang percakapan. |
| 5,7–8,9 dtk | Pertanyaan diketik; panel tanya membuka ruang jawaban dan teks yang sama menjadi pesan. |
| 8,9–14,4 dtk | Enam fardu wudu muncul berurutan, disusul jeda baca. |
| 14,4–19,5 dtk | Fokus bergeser ke kutipan Arab dan identitas kitab dalam isi contoh jawaban. |
| 19,5–24,1 dtk | Salin jawaban → Simpan → kembali ke shell → Catatan → buka item. |
| 24,1–30 dtk | Jawaban dan rujukan tetap ada di pembaca catatan, kemudian penutup merek. |

[PRODUCT_TRUTH.md](PRODUCT_TRUTH.md) mencatat pemeriksaan matan, lokasi kontrol dalam kode Flutter, dan batas kemampuan yang digambarkan. Film memakai nama kitab dan fasal tanpa nomor halaman atau klaim verifikasi otomatis. Nama bidang tidak menjanjikan akses yang sama untuk setiap akun.

## Berkas dan reproduksi

- Video: H.264, 1080 × 1920, 60 fps, 1.800 frame, durasi stream video 30,000 detik.
- Audio: AAC, 48 kHz, stereo. Durasi container 30,016 detik karena padding audio.
- Ukuran: 4.862.456 byte.
- SHA-256: `27a7e495567ffd8af3b7e3bd00bb34594e19c8a7f2df53c71634881d80f1ee08`.
- Sumber animasi: [Film.tsx](../../openturath_motion/src/productfilm/Film.tsx), contoh isi: [content.ts](../../openturath_motion/src/productfilm/content.ts).
- Ekspor ulang: jalankan `npm run render:product` dari direktori `openturath_motion`.

## Pemeriksaan

`ffprobe` mengonfirmasi resolusi, frame rate, jumlah frame, codec, dan durasi di atas. Seluruh MP4 berhasil didekode dengan FFmpeg tanpa galat. Frame hasil encoding diperiksa untuk teks jawaban, Arab, kontrol salin, panel catatan, dan penutup. Cuplikan transisi juga diperiksa melalui sampel berurutan. Pemeriksaan ini bukan uji penonton atau bukti bahwa film telah memenuhi selera pengguna.

Earshot pada audio AAC hasil encoding: **−14,5 LUFS**, **−1,5 dBTP**, **0 sampel clipping**, LRA 4,2 LU. Angka tersebut memeriksa level; tidak membuktikan keindahan musik atau kecocokan emosional. Model semantik/realness tidak tersedia dan tidak ada penilaian pendengaran manusia dalam proses ini.

Musik: “Digital Clouds” — Alejandro Magaña (A. M.), Mixkit. [Catatan sumber dan lisensi](../../openturath_motion/public/productfilm/audio/CREDITS.md). Musik berbeda dari film Jejak Ilmu sebelumnya; tidak ditambah musik sintetis buatan kode.
