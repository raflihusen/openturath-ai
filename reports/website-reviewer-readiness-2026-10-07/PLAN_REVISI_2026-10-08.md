# Rencana revisi OpenTurath — 8 Oktober 2026

Dasar: [audit 7 Oktober](AUDIT.md), [validasi masukan 8 Oktober](VALIDASI_MASUKAN_2026-10-08.md). Scope sekarang: persiapan bukti dan rencana perubahan; belum implementasi/deploy website.

## Urutan kerja yang direvisi

| Prioritas | Pekerjaan | Hasil konkret | Kriteria selesai / dependensi |
|---|---|---|---|
| P0-A | Susun Evidence Pack dari artefak yang sudah ada | Registry: claim, source, date, scope, review status, izin publikasi, public placement | Tiap klaim bisa ditelusuri ke bukti primer; unknown tetap unknown |
| P0-B | Audit Claude per lapisan | Coding/R&D, corpus/evaluation, API/runtime, planned; tabel model dan periode usage | Screenshot/ekspor asli + task mapping + input/output; autentikasi dan akun billing dicatat tanpa credential |
| P0-C | Selesaikan satu kasus sumber | Pertanyaan → output asli → ibarah/konteks → kitab/pengarang/edisi/jilid/halaman → sumber yang dapat dibuka → review | Lafaz, atribusi, lokasi dan konteks dikolasi; waktu/model/source dicatat |
| P0-D | Inventaris expert testing | Catatan peserta anonim, bidang, workflow, durasi, feedback, permission | Bedakan demo, penggunaan riset, feedback, dan formal validation |
| P0-E | Rekonsiliasi corpus | Manifest canonical, unit hitung, overlap, snapshot dan ingest/index status | Jelaskan 6 selisih jumlah kitab, termasuk 103/87; jangan mengganti angka dengan asumsi |
| P0-F | Audit benchmark yang sudah dilakukan | Daftar produk/model, seluruh kasus dan output, ground truth, scoring, failure cases | Cocokkan klaim sekitar 10 AI dengan arsip nyata; Q001 tetap arsip 1 kasus |
| P0-G | Sediakan jalur melihat produk | Demo asli/video atau akses produk yang memang tersedia | Reviewer dapat mengikuti workflow; CTA tidak berakhir hanya Coming Soon |
| P0-H | Ubah narasi di dalam desain V6 | Hero konkret, problem sumber, source-first, demo/evidence, About, Technology, Research | Klaim dan gambar cocok registry; current/R&D/planned terbaca; source produksi dipastikan |
| P1-A | Jalankan evaluasi baru jika bukti lama belum cukup | Evaluation set versioned, model/config/date, rubric, hasil dan limitations | Definisi ground truth dan scoring dibuat sebelum run; tidak memilih hanya hasil baik |
| P1-B | Pilot Claude API bila memang arah founder | Task terukur, token/job, kualitas, latency/throughput, biaya dan limit | Tidak otomatis mengganti NotebookLM; keputusan memakai hasil pilot dan kebutuhan nyata |
| P1-C | English evidence summaries dan identitas | Ringkasan editorial Q001, profil tim/tahap proyek, kontak valid | Transkrip asli dipertahankan; nama dan kutipan dengan izin |
| P2 | Holdout, lintas disiplin, usage dan penghematan waktu | Evaluasi berulang, statistik agregat, studi workflow | Tidak mengganti benchmark dengan jumlah token/corpus |

P0-A sampai P0-F adalah pekerjaan bukti, bukan tugas membuat klaim yang terdengar meyakinkan. Dahulukan pemeriksaan artefak lama; jangan menjalankan ulang puluhan pengujian jika output lama cukup dan dapat diaudit. Untuk konten factual yang sudah didukung, perbaikan editorial dapat dimulai tanpa menunggu seluruh P1.

## Registry Claude yang perlu diisi

| Field | Yang dicatat |
|---|---|
| Project/task | Keterkaitan konkret dengan OpenTurath dan hasil pekerjaannya |
| Access | Claude Code/Claude.ai/interface lain; subscription/API/provider; dua field terpisah |
| Model | Model ID/version yang sebenarnya; label Opus saja belum cukup |
| Period | Tanggal awal/akhir, timezone, batas agregasi, akun/project yang dicakup |
| Tokens | Input, output, cache write/read; jangan sebut total sebagai corpus unik |
| Artifact | Contoh input/output tersanitasi dan file/commit terkait |
| Status | Manual R&D, automated pipeline, prototype, runtime, atau planned |
| Limitation | Limit yang benar-benar dicapai, task terdampak dan bukti pengulangan |
| Publication | Apa yang boleh dipublikasikan, apakah perlu anonimisasi |

## Penempatan bukti di website dan aplikasi startup

- Homepage: output nyata dan sumber; ringkasan evidence setelah tersedia. Token usage bukan angka utama kualitas produk.
- About: tahap early-stage, identitas yang disetujui, misi dan kontribusi OpenTurath.
- Technology: jalur NotebookLM yang benar-benar tersedia; Claude R&D yang dibuktikan; rencana API diberi status.
- Research: verified case, methodology, original runs, failure cases, limitations dan corpus manifest.
- Aplikasi startup: jawab sesuai wording pertanyaan. R&D subscription usage dijelaskan sebagai R&D; API integration dijelaskan hanya jika ada. Tidak ada janji peningkatan skor/program acceptance.

## Pemeriksaan sebelum perubahan diterapkan

Pastikan checkout source produksi; gunakan salinan kerja dan pertahankan arah V6. Setiap perubahan diberi checkpoint Git segera. Build/test dan browser QA sesuai perubahan. Publikasi tidak berjalan otomatis dari penyelesaian build. Scope WebView dan app tidak diubah oleh pekerjaan website ini.

## Keputusan yang tetap berlaku

Baseline 42/100 tetap nilai audit 7 Oktober, bukan penilaian baru terhadap semua kegiatan internal. Bukti primer Claude belum diperiksa; angka usage belum dipublikasikan. Source-first berarti menghubungkan klaim ke sumber, termasuk klaim tentang Claude dan corpus sendiri.
