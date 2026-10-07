# Verifikasi kartu baca — 8 Oktober 2026

Baseline `570962b`, branch `codex/reading-cards-2026-10-08`. Arah monokrom, Cairo, watermark, artwork Tahawwulat dan loader yang sudah diterima dipertahankan.

## Empat perubahan

1. Hasil pencarian hanya memuat identitas AI, tanpa badge bidang atau ikon rujukan di setiap baris. Baris tetap membuka AI; rujukan tersedia pada halaman AI.
2. Delapan adab memakai kartu tonal terpisah. Ikon berada di samping judul: kiri untuk LTR, kanan untuk Arab. Seluruh isi dan terjemahan dipertahankan.
3. Hero sekarang bernama AI Fikih Tahawwulat, termasuk padanan UI EN/AR.
4. Kedua jalur katalog memakai kartu bibliografi dengan judul, pengarang, dan metadata jilid/halaman berkelompok. Dua kartu berdampingan pada lebar konten 800+ dan skala teks di bawah 150%; satu kolom pada layar sempit atau teks besar. Tinggi mengikuti isi. Pembagian identitas/metadata 70/30 dihapus. Grid alternatif tetap tersedia. Data JSON, metadata edisi, filter, pencarian, dan tujuan detail tidak diubah.

## Bukti teknis dan visual

- Analyzer exit 0: No issues found.
- 58 tes terkait katalog, navigasi, lokalisasi, layout ponsel dan token desain lulus, exit 0. Pengujian katalog mencakup ID/AR, terang/gelap, teks 200%, dan ukuran hingga 1440.
- Render harness exit 0, 91 PNG widget produksi. Galeri ini menampilkan 12 gambar yang paling relevan. Data kitab asli dari repository aplikasi; identitas pengguna dan akses adalah fixture.
- Pemeriksaan gambar mencakup pencarian tanpa ikon, kartu adab ID/AR, Tahawwulat 390/850/1280, katalog gelap, serta teks besar. Judul dan pengarang panjang membungkus; metadata tetap berada di kartu yang sama.
- Bundle Dart/Flutter AOT profile macOS berhasil, exit 0. Host native review memakai Runner Release lokal terdahulu, dengan bundle ID review terpisah dan tanda tangan ad-hoc yang diverifikasi. Ini bukan clean build Xcode atau paket rilis distribusi.
- Aplikasi native dibuka dan judul hero AI Fikih Tahawwulat terbaca dalam accessibility tree. Pemeriksaan interaktif lanjutan tidak dinyatakan lengkap karena keadaan jendela berubah saat review berlangsung; katalog dan adab baru diperiksa lewat render widget produksi, bukan klaim walkthrough native lengkap.

Tidak ada upload, broadcast, APK/DMG baru, transaksi nyata, atau login NotebookLM pada tahap ini. Setiap perubahan mempunyai checkpoint dengan file eksplisit. Lihat CHECKPOINTS.md untuk pemulihan selektif.
