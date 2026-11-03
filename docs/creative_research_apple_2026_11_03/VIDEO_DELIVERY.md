# Jejak Ilmu — video pertama

Tanggal: 3 November 2026. Status: ekspor lokal selesai dan file diperiksa.

[Putar atau unduh MP4](../../openturath_motion/out/OpenTurath_Jejak_Ilmu_30s_9x16.mp4) · [Kredit audio](../../openturath_motion/public/jejak/audio/CREDITS.md)

## Hasil

Film 30 detik dalam format vertikal 9:16, dengan garis tinta yang tumbuh, perjalanan kamera melalui lembar melengkung, contoh interaksi produk, halaman yang terbuka, penanda catatan, dan buku pada penutup. Geometri dan kamera dianimasikan berdasarkan frame. Papan styleframe imagegen tidak dipakai sebagai gambar yang digeser atau diperbesar dalam film.

Hasil ini memakai Remotion dan adegan Three.js yang dibuat khusus. Tampilannya merupakan animasi 3D bergaya; papan konsep tetap merupakan eksplorasi fotografis tersendiri. Skrip Blender yang tersimpan adalah alternatif authoring dan bukan mesin render yang menghasilkan file ini.

Contoh UI diambil dari rekonstruksi produk yang telah ada: pemilih asisten, composer, serta bentuk catatan. Pertanyaan rukun wudu mengikuti contoh di `openturath_ai/lib/models/agent_model.dart`, baris 279. Pertanyaan dan catatan ditandai sebagai contoh. Film tidak memakai kutipan Al-Umm atau nomor halaman yang belum memiliki bukti verifikasi edisi.

## Pemeriksaan file

| Pemeriksaan | Hasil |
|---|---|
| Gambar | H.264, 1080 × 1920, 30 fps |
| Jumlah frame | 900 |
| Durasi video | 30,000 detik |
| Audio | AAC, stereo, 48 kHz |
| Durasi container/audio | 30,016 detik, termasuk padding encoding |
| Ukuran file | 15.956.295 byte |
| Dekode menyeluruh | Selesai tanpa galat FFmpeg |
| Pemeriksaan sumber | TypeScript lulus |

Sampel frame terenkode pada 2,0; 3,5; 10,0; 21,67; dan 27,0 detik diperiksa kembali. Teks utama, empat kartu utama, catatan, logo, dan URL terbaca. Ujung kartu berikutnya terlihat sedikit di batas viewport direktori, sesuai sifat daftar yang berlanjut. Pemeriksaan sampel bukan peninjauan gerak kontinu.

Earshot pada audio AAC terdekode mengukur −15,9 LUFS, true peak −4,1 dBTP, tanpa sampel clipping, LRA 3,4 LU, korelasi stereo 0,913, dan perubahan RMS downmix mono −0,192 dB. Model semantik dan realness tidak tersedia. Pengukuran ini tidak membuktikan mutu komposisi, kecocokan musik, atau sinkronisasi artistik.

SHA-256:

```text
ab05997be6cca0bdff03883a2fde47447774dd995b5c67d25e85fbaf77b4f02c
```

## Musik dan penggunaan

“Reawakening” karya Scott Buckley dipakai berdasarkan CC BY 4.0. Potongan musik disunting, stereo dipersempit dan diberi fade. Efek balik halaman berasal dari Mixkit. Kredit ringkas ada pada tiga detik terakhir video; salin kredit lengkap dari berkas pendamping ke deskripsi saat membagikannya.

File video di-checkpoint pada commit `1a7afa7b`. Perintah ekspor yang menghasilkan file: `npm run render:jejak` di proyek `openturath_motion`. Jalur ekspor memakai tangkapan frame biasa dan pengodean setelah seluruh frame selesai, setelah percobaan shared-memory terhenti sebelum menghasilkan MP4 lengkap.
