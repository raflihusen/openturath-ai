# OpenTurath promo film

Film promosi 30 detik dengan teks kinetik dan motion graphics 3D, dibuat dengan Remotion dan three.js. Film ini tidak memakai tangkapan layar aplikasi. Lihat `storyboard.md` untuk timeline, copy, dan dasar setiap klaim.

## Hasil

| File | Isi |
| --- | --- |
| `deliverables/openturath-promo-vertical.mp4` | Versi utama, 1080 × 1920, 30 fps, 900 frame, H.264 + AAC |
| `deliverables/openturath-promo-wide.mp4` | Versi 1920 × 1080 dengan scene yang sama |
| `deliverables/openturath-poster-vertical.jpg` | Poster dari frame penutup (frame 880) |
| `deliverables/openturath-thumb-book.jpg` | Thumbnail alternatif: kitab di depan kamera (frame 395) |
| `deliverables/contact-*.jpg` | Contact sheet, satu frame per detik |

## Edit dan render ulang

```sh
npm install
npm run dev                      # Remotion Studio
npx remotion render src/index.ts OpenTurathVertical out/openturath-promo-vertical.mp4 --codec=h264 --crf=16 --gl=angle
npx remotion render src/index.ts OpenTurathWide out/openturath-promo-wide.mp4 --codec=h264 --crf=16 --gl=angle
```

Struktur source:

- `src/theme.ts` berisi palet, font, dan timeline scene.
- `src/Overlay.tsx` berisi semua copy di layar.
- `src/Type.tsx` berisi animasi teks.
- `src/world/World.tsx` berisi kamera, cahaya, kitab, catatan, dan logo 3D.
- `src/world/library.ts` berisi rak, tekstur punggung kitab, dan sampul.

Path logo disalin dari `openturath_ai/assets/images/OpenTurath_logo_transparent.svg`. Judul pada rak dibuat oleh `tools/make_titles.py` dari katalog JSON aplikasi. Musik dibuat oleh `tools/make_audio.py`. `tools/frame_check.py` dan `tools/ocr.swift` dipakai untuk pemeriksaan kecerahan dan OCR per frame.

## Lisensi aset

Font yang dipakai (Newsreader, Outfit, Inter, Scheherazade New) adalah font bawaan aplikasi dengan lisensi OFL. File lisensinya ada di `public/assets/fonts/`. Musiknya disintesis sendiri. Ketentuan lisensi Remotion tergantung ukuran tim: https://www.remotion.dev/docs/license/pricing
