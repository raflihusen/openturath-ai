# Verifikasi koreksi audit OpenTurath

## Perubahan

Komposisi kartu bidang/AI, kalender dan metrik pustaka, katalog bersama, identitas detail kitab, hero eksklusif Tahawwulat, lima pilihan AI, navigasi bab, bahasa artikel, indikator diagram, profil, durasi harga, dialog aktivasi, tipografi login, tindakan chat, dan loader native telah diperbarui. Data harga, sumber kitab, entitlement, serta artwork 3D dipertahankan.

## Pemeriksaan yang lulus

- `flutter analyze --no-pub`: tanpa issue.
- `flutter test --no-pub --reporter expanded`: 358 lulus, satu tes motion snapshot opt-in dilewati dalam run umum.
- Snapshot layar opt-in: lulus tanpa exception framework. 67 PNG disimpan di `screens/`; AI memakai SpecialistListScreen sebenarnya. Lebar AI 320, 390, 600, 850, 1280, 1440; juga dark, Arab dan pembesaran teks 200%.
- Motion opt-in: lulus. 126 PNG fase pembuka/loader dirender; dua pratinjau GIF disimpan. Sampling tidak mengukur frame time perangkat.
- Adapter WebView Node: 5 tes lulus (halaman login tidak diinjeksi, skala absolut, input nonfinite, kontrol tidak disembunyikan, arah campuran).
- Dialog aktivasi dan katalog locale diuji ulang setelah ekspektasi layar lama diperbarui. Render gagal sebelumnya menemukan pengukuran intrinsic pada statistik, tab teks besar, kartu beranda sempit, dan ruang judul Arab; penyebabnya diperbaiki sebelum snapshot akhir.

## Batas bukti

Seluruh PNG adalah fixture Flutter dengan akun contoh. Galeri bukan bukti pembayaran, autentikasi Google, pertukaran pesan NotebookLM, clipboard WebView nyata, pembaca layar OS, atau performa profile mode. Alat kendali jendela sebelumnya gagal dengan `noWindowsAvailable`; build release terbaru kemudian berhasil dibuka. Layar login dan buka/tutup menu bahasa diamati secara native. Build terbaru belum memiliki sesi terautentikasi untuk pengujian NotebookLM. Perubahan retry menjaga platform view tetap terpasang di belakang overlay; ini belum membuktikan bahwa kegagalan yang dilaporkan pengguna sudah pulih pada sesi terautentikasi.

Tidak ada publikasi, upload APK/DMG, atau broadcast Firestore dalam pekerjaan ini. Perubahan website/favicon dari pekerjaan lain di repository tidak dimasukkan sebagai perubahan desain aplikasi ini. Checkpoint pemulihan selektif ada di `CHECKPOINTS.md`.

## Paket macOS lokal

Build release dan packaging selesai dengan exit 0. DMG diverifikasi melalui hdiutil; aplikasi lolos codesign deep/strict. Binary utama universal arm64/x86_64. Tanda tangan ad hoc, tanpa notarization Apple. Versi aplikasi tetap 1.0.63+64; nama file audit-fixes dan manifest membedakan paket ini dari paket lama. Ukuran, timestamp dan SHA-256 lengkap tercatat pada `DMG_MANIFEST.json`.
