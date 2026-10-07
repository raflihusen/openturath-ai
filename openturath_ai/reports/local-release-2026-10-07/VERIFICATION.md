# APK dan DMG revisi artwork 3D

Versi: **1.0.63+64**. Distribusi lokal untuk unduhan/pengujian; tidak ada upload CDN, Hosting, atau broadcast Firestore dari pekerjaan ini.

| File | Ukuran byte | SHA-256 |
|---|---:|---|
| app-release-latest.apk | 67418932 | 60885018c40c2437eac6ba4695e76f664f03ca5441c3a7ac15f506af7de667dd |
| OpenTurath_AI_macOS.dmg | 51453510 | 1d198c3f6c9466d2c7f3f1936e634dfbae49db45930e62da7226ef859cf5beb7 |

## Verifikasi

- Build APK release selesai sepenuhnya: Gradle assembleRelease 661,4 detik, exit 0. Bukan hasil lama dari folder build.
- APK sumber dan salinan final memiliki hash sama; kedua timestamp lebih baru dari awal build. PNG sculpture terbaru terdapat di APK dan hash sesuai sumber.
- Tanda tangan APK v2 valid dan sertifikat sama dengan APK sebelumnya. Package com.openturath.ai, versi 1.0.63/code 64, min SDK 24, target SDK 36; ARM 32-bit, ARM 64-bit, x86_64. Tidak ada flag debuggable di badging.
- DMG dibangun dari app macOS terbaru; proses packaging exit 0. hdiutil verify exit 0, checksum internal VALID.
- DMG dipasang read-only untuk memeriksa app dan shortcut Applications; codesign --verify --deep --strict berhasil. Volume kemudian dilepas.
- Seluruh 37 binary native macOS mendukung arm64 dan x86_64. Artwork dalam bundle macOS cocok dengan source.
- macOS menggunakan tanda tangan ad-hoc, tidak memiliki Developer ID atau notarization Apple.
- Tidak dilakukan instalasi di perangkat Android fisik atau verifikasi NotebookLM terautentikasi pada tahap pembuatan paket ini.

## Pemulihan

File sebelum penggantian disimpan di `openturath_ai/build/local-release-backups/2026-10-07-before-artwork-release/`. Binary hasil kompilasi disimpan di luar Git; source, checksum, dan manifest memiliki checkpoint Git eksplisit. Metadata dan waktu Asia/Aden tercatat di manifest.json.
