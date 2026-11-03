# Revisi: pengenalan lengkap 18 AI

3 November 2026

[Video revisi 30 detik](../../openturath_motion/out/OpenTurath_18_Ilmu_30s_9x16.mp4)

Kekurangan versi sebelumnya diperbaiki: seluruh 18 nama AI utama diperkenalkan pada sekitar 12 detik pertama. Katalog berada pada satu grid panjang yang bergeser melalui tiga kelompok enam kartu; nama panjang memakai dua baris. Kartu Fikih Syafi’i yang dipilih kemudian menjadi penghubung menuju contoh penggunaan. Versi sebelumnya tetap tersedia sebagai berkas terpisah.

## Waktu tampil

| Bagian | Waktu |
|---|---|
| Tahawwulat; Syafi’i; Hanafi; Maliki; Hanbali; Perbandingan Mazhab & Fatwa | 0–3,6 dtk |
| Hadits; Syarah Hadits; Ilmu Hadits; Rijal & Biografi Ulama; Tafsir; Tajwid & Qira’at | Sekitar 4,15–7,3 dtk |
| Ushul & Kaidah Fikih; Bahasa Arab; Aqidah; Tasawuf; Sejarah & Sirah; Bibliografi Kitab | Sekitar 7,85–11 dtk |
| Pencarian dan pemilihan Fikih Syafi’i → pertanyaan | 11–14,5 dtk |
| Jawaban → kutipan dan nama kitab | 14,5–21,3 dtk |
| Salin → Simpan → kembali → Catatan → pembaca | 21,3–26,55 dtk |
| Penutup merek | 26,55–30 dtk |

Daftar dicocokkan dengan `AgentModel.defaultAgents`: **18 ID, 18 unik, 0 hilang, 0 tambahan**. Lima sub-AI Tahawwulat tidak dihitung ulang. [CATALOG_18.md](CATALOG_18.md) mencatat sumber dan batas ketersediaan. Footer film berbunyi “Lihat ketersediaan dan akses di aplikasi.”

## Pemeriksaan dan reproduksi

- H.264, 1080 × 1920, 60 fps, 1.800 frame, durasi video 30,000 detik.
- AAC stereo; durasi container 30,016 detik. Ukuran 4.260.863 byte.
- SHA-256: `f8eb21d3b8a0522ac01e6e1e31a45544000fe6a2e23c8df9be9e971f57b43895`.
- FFmpeg berhasil mendekode seluruh file tanpa galat. TypeScript dan ESLint berkas film baru lulus.
- Tiga kelompok diperiksa pada frame terenkode 2,2; 5,5; dan 9,2 detik. Seluruh nama terbaca pada tampilan selebar 360 piksel. Transisi katalog → demo diperiksa tiap 0,2 detik pada 11–13 detik. Pemeriksa kedua meninjau ketiga kelompok dan mencocokkan cakupannya.
- Audio tidak diubah; hash stream AAC identik dengan versi yang sudah diukur Earshot: `2a9f1e8be187f84194f1b8b3477a7f9c` (MD5). Level −14,5 LUFS, true peak −1,5 dBTP, nol clipping. Tidak ada klaim penilaian selera atau sinkronisasi musikal dari angka tersebut.
- Komposisi: `OpenTurath18Ilmu`. Ekspor ulang dari `openturath_motion` dengan `npm run render:18ilmu`.
- Sumber: [CatalogFilm.tsx](../../openturath_motion/src/productfilm/CatalogFilm.tsx), [catalog.ts](../../openturath_motion/src/productfilm/catalog.ts). [Manifest cue](../../openturath_motion/public/productfilm/audio/cues-18ilmu.json) memakai pemetaan waktu revisi.

Contoh percakapan, kutipan, dan alur penyimpanan tetap mengikuti [PRODUCT_TRUTH.md](PRODUCT_TRUTH.md). Ini ilustrasi antarmuka dan contoh jawaban yang ditulis untuk film, bukan sesi AI langsung atau uji ketersediaan konfigurasi produksi. [Sumber musik dan lisensi](../../openturath_motion/public/productfilm/audio/CREDITS.md) tetap sama.
