# Pratinjau UI OpenTurath

Iterasi ini berisi riset desain SaaS, token dan prototipe interaktif. Layar perwakilan adalah Pustaka Fikih Syafi’i dengan 87 metadata asli. Alur pendamping mencakup pencarian, filter, detail, catatan lokal, pemilihan asisten, serta status koneksi yang jelas.

**Belum diterapkan ke source Flutter atau dirilis.** NotebookLM tetap diperlukan; prototipe tidak mengautentikasi pengguna dan tidak membuktikan penyatuan login Firebase + NotebookLM.

## Meninjau hasil

Pratinjau: [http://127.0.0.1:8794/](http://127.0.0.1:8794/). Browser pratinjau dipertahankan pada layar pustaka. Jika server sudah berhenti, jalankan dari direktori workspace:

```sh
cd /Users/apple/Downloads/ramadhan
python3 -m http.server 8794 --bind 127.0.0.1 --directory openturath_ai/docs/saas-redesign-2026-09-30/prototype
```

Data catatan hanya tersimpan pada browser dan origin lokal tersebut. Server tidak menyediakan sinkronisasi akun, penyimpanan cloud, atau layanan autentikasi. Mode gelap tersedia melalui tombol di header atau halaman akun.

- [RESEARCH.md](RESEARCH.md): diagnosis desain sebelumnya, referensi produk primer, skill GitHub beserta versi sumber, dan rencana.
- [DESIGN.md](DESIGN.md): struktur dan keputusan yang benar-benar dibangun.
- [design-tokens.json](design-tokens.json): token lokal untuk pemetaan ke Flutter setelah arah ditinjau.
- [VERIFICATION.md](VERIFICATION.md): hasil pemeriksaan browser, sembilan screenshot asli, dan batas verifikasi.
- [Pustaka desktop](screenshots/01-desktop-library.jpg) dan [ponsel](screenshots/04-mobile-library.jpg): bukti render perwakilan.

Panduan Anthropic, Vercel, Impeccable dan skill ECC lokal diadopsi pada bagian yang sesuai dengan aplikasi kerja OpenTurath. Tidak ada pemasangan otomatis semua skill, framework React, launcher eksternal atau binary GitHub.

## Checkpoint dan restore

- Branch kerja: `codex/saas-design-research-2026-09-30`.
- Baseline sebelum iterasi ini: `codex/saas-design-base-2026-09-30`, commit `3c3f74b`.
- Tag review hasil akhir: `codex/saas-design-review-2026-09-30`.
- Setiap perubahan disimpan dalam commit terarah, termasuk screenshot dan dokumen. Source aplikasi dan prototipe terdahulu tetap tersedia pada baseline.

Periksa riwayat dan tag tanpa mengubah file:

```sh
git log --oneline codex/saas-design-base-2026-09-30..codex/saas-design-review-2026-09-30
git show --stat codex/saas-design-review-2026-09-30
```

Untuk membuka versi baseline sebagai checkout terpisah yang dapat dibandingkan, gunakan direktori baru yang belum ada:

```sh
git worktree add --detach /Users/apple/Downloads/ramadhan/openturath-saas-baseline codex/saas-design-base-2026-09-30
```

Perintah tersebut adalah petunjuk untuk pemulihan nanti; checkout tambahan tidak dibuat pada iterasi ini. Ia mempertahankan file kerja saat ini. Jangan gunakan reset paksa untuk meninjau hasil karena workspace juga memuat file pengguna di luar artefak ini.

Pada baseline, source aplikasi berada di `openturath_ai/`; folder riset ini belum ada. Untuk meninjau versi hasil akhir dalam checkout terpisah, pakai tag review dan nama direktori baru yang berbeda pada perintah yang sama.
