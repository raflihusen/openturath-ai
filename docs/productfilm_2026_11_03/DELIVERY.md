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
- Ukuran: 4.814.213 byte.
- SHA-256: `e34c20a4c46b9327a0977aab9f0c2fa83983f215e282cc0b442a38b897f1b782`.
- Sumber animasi: [Film.tsx](../../openturath_motion/src/productfilm/Film.tsx), contoh isi: [content.ts](../../openturath_motion/src/productfilm/content.ts).
- Ekspor ulang: jalankan `npm run render:product` dari direktori `openturath_motion`.

## Pemeriksaan

`ffprobe` mengonfirmasi resolusi, frame rate, jumlah frame, codec, dan durasi di atas. Seluruh MP4 berhasil didekode dengan FFmpeg tanpa galat. TypeScript dan ESLint untuk berkas film baru lulus. Frame hasil encoding diperiksa untuk teks jawaban, Arab, kontrol salin, panel catatan, dan penutup. Pemeriksaan independen meliputi 21,4–24,0 detik tiap 0,2 detik dan 5–8,67 detik tiap 0,33 detik. Setelah perapian transisi teks, hasil ekspor diperiksa kembali tiap 0,1 detik pada 5,1–5,8 dan 23,2–24,4 detik. Pemeriksaan ini bukan uji penonton atau bukti bahwa film telah memenuhi selera pengguna.

Earshot pada audio AAC hasil encoding: **−14,5 LUFS**, **−1,5 dBTP**, **0 sampel clipping**, LRA 4,2 LU. Angka tersebut memeriksa level; tidak membuktikan keindahan musik atau kecocokan emosional. Model semantik/realness tidak tersedia dan tidak ada penilaian pendengaran manusia dalam proses ini.

Perapian terakhir hanya mengubah gambar. Hash stream AAC tetap identik dengan ekspor yang diukur: `2a9f1e8be187f84194f1b8b3477a7f9c` (MD5 stream, untuk pemeriksaan kesamaan audio).

Musik: “Digital Clouds” — Alejandro Magaña (A. M.), Mixkit. [Catatan sumber dan lisensi](../../openturath_motion/public/productfilm/audio/CREDITS.md). Musik berbeda dari film Jejak Ilmu sebelumnya; tidak ditambah musik sintetis buatan kode.
