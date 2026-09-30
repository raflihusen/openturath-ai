# Riset ulang UI OpenTurath — 30 September 2026

Status: arah desain dan prototipe untuk ditinjau. Belum diterapkan ke layar Flutter. Desain sebelumnya disimpan di `docs/redesign-2026-09-30/`; baseline Git iterasi ini adalah tag `codex/saas-design-base-2026-09-30` (3c3f74b).

## Produk dan tugas pengguna

OpenTurath membantu santri, pengajar, mahasiswa, dan peneliti menelusuri ibarah serta memeriksa rujukan kitab. Dasar konteks: `OpenTurath_Identitas_dan_Kebijakan.md`, model bidang/asisten aplikasi, katalog JSON, dan arahan pengguna. NotebookLM wajib tetap menjadi mesin percakapan. UI harus memudahkan memilih asisten, mencari kitab, membaca metadata, dan menyimpan catatan. Asumsi penggunaan: pekerjaan berulang pada desktop dan ponsel, dengan judul Arab panjang dan navigasi Indonesia.

Instruksi terbaru pengguna mengganti arah visual lama dalam `DESIGN.md`: modern, minimalist, sekelas aplikasi SaaS internasional. Prinsip kebenaran sumber dan identitas produk tetap berlaku. Ornamen religius, slogan, statistik buatan, dan dekorasi buku tidak diperlukan untuk menyatakan identitas itu.

## Diagnosis desain yang ditolak

| Temuan pada prototipe lama | Implikasi | Keputusan baru |
| --- | --- | --- |
| Judul Newsreader 38–42 px, slogan seperti “Mulai sebuah telaah” | Halaman terasa seperti editorial/landing page | Judul tugas 24 px; sans-serif UI; kata-kata langsung |
| Eyebrow huruf besar, penomoran modul, bingkai buku ganda | Perangkat dekoratif mengalahkan isi | Hilangkan label dekoratif; gunakan pengelompokan yang bermakna |
| Kartu kitab minimal 233 px | Sedikit isi terlihat; perbandingan metadata lambat | Daftar/tabel dengan judul, pengarang, tahun dan jumlah jilid |
| Hijau tersebar pada ornamen, teks dan kontrol | Prioritas tindakan tidak jelas | Netral dominan; biru terbatas pada tindakan/pilihan |
| Dialog metadata memutus konteks katalog | Pengguna kehilangan hubungan dengan daftar | Panel detail sejajar pada desktop; layar detail kembali-ke-daftar pada ponsel |
| Tampilan akun contoh dan login simulasi | Bisa dikira sesi sungguhan | Status pratinjau eksplisit; tanpa akun atau autentikasi buatan |

Ini penilaian desain berdasarkan kode dan render terdahulu, bukan hasil studi pengguna atau skor kepuasan.

## Rujukan produk primer

| Sumber | Yang dipelajari | Penerapan pada OpenTurath |
| --- | --- | --- |
| [Linear: Custom Views](https://linear.app/docs/custom-views) | Daftar dengan filter dekat konten dan panel untuk konteks; dokumentasi memuat screenshot produk | Pencarian, filter, urutan dan daftar sejajar; metadata terbuka tanpa meninggalkan daftar |
| [GitHub Primer: Navigation](https://primer.style/product/ui-patterns/navigation/) | Orientasi jelas, sedikit pilihan utama, navigasi parent/detail, adaptasi sidebar pada layar sempit | Asisten/Pustaka/Catatan konsisten; tautan kembali; sidebar desktop menjadi navigasi ringkas seluler |
| [Stripe: Dashboard basics](https://docs.stripe.com/dashboard/basics) | Navigasi berdasarkan tugas, pencarian, shortcut, serta pembukaan detail dari daftar | Nama menu konkret, shortcut pencarian, detail kitab dari daftar |
| [Primer: Typography](https://primer.style/product/css-utilities/typography/) | Skala UI 12/14/16/20/24 px dengan hierarki semantik | Hierarki rapat dan terbaca; judul Arab mendapat tinggi baris yang cukup |

Linear dan Primer diperiksa lewat browser, termasuk contoh UI pada dokumentasi. Stripe dibaca lewat dokumentasi resmi; akses browser tidak digunakan sebagai bukti inspeksi dashboard akun Stripe. Tidak ada login atau pengiriman data pengguna ke layanan referensi.

## Skill GitHub yang ditinjau

Tiga pencarian terarah menghasilkan sumber berikut. Versi dicatat dari API commit GitHub publik. Membaca dan mengadopsi panduan tidak berarti seluruh paket atau binary dipasang.

| Skill / sumber | Versi sumber yang dibaca | Adopsi |
| --- | --- | --- |
| [Anthropic frontend-design](https://github.com/anthropics/skills/blob/41bbe19d1a1a7eaab5e7bb9050a417e5c6cffc8f/skills/frontend-design/SKILL.md) | 41bbe19, 3 September 2026 | Isi nyata, keputusan visual disengaja, satu penekanan utama, copy fungsional, kritik render; hindari eyebrow, kartu seragam, serif editorial otomatis |
| [Vercel web-design-guidelines](https://github.com/vercel-labs/agent-skills/blob/ba46938889d4e58635362fb8f618e1178ac3ec46/skills/web-design-guidelines/SKILL.md) dan [aturan](https://github.com/vercel-labs/web-interface-guidelines/blob/e3d624baaf29dc1fc645aff3e38f03e564d2d6b1/command.md) | ba46938 / e3d624b | HTML semantik, label, focus-visible, status aksesibel, URL menyimpan filter/halaman, reduksi gerak, penanganan judul panjang, pagination |
| [Impeccable](https://github.com/pbakaus/impeccable/blob/351e7a8410a96dee1107630e2691c8edb05ae32a/plugin/skills/impeccable/SKILL.md), referensi Operate dan Craft floor | 351e7a8, 25 September 2026, v4.4.0 | Familiaritas kontrol, satu keluarga sans UI, hierarki rapat, warna netral, progressive disclosure, keadaan kosong/error/loading, inspeksi visual terbatas dua putaran |

Panduan ECC lokal yang dibaca: skill-scout, frontend-design-direction, design-system, make-interfaces-feel-better. Semuanya diterapkan sesuai konteks produk. Impeccable ditinjau sebagai sumber panduan; launcher yang dapat mengunduh binary, hook, dan ritual pemilihan arah otomatis tidak dijalankan. Pengguna sudah menentukan gaya yang diinginkan. Aturan font ekspresif untuk pemasaran tidak dipaksakan pada aplikasi kerja. Aturan Title Case Inggris tidak mengubah sentence case Indonesia. Framework React/Next tidak diadopsi ke aplikasi Flutter.

## Rencana yang mengikat prototipe

1. Layar perwakilan: Pustaka Fikih Syafi’i dengan seluruh 87 metadata asli. Main area memuat judul ringkas, toolbar, daftar; panel detail hanya muncul setelah kitab dipilih. Tidak ada sampul buatan atau angka penggunaan.
2. Tampilan netral putih/abu, aksen biru #0066cc, antarmuka Inter lokal. Noto Sans Arabic untuk metadata UI Arab; font naskah ilmiah tetap milik layar baca aplikasi. Ukuran UI 12/14/16/24 px, Arab 16–20 px; jarak dasar 4 px. Radius kontrol 6 px, tanpa bayangan pada daftar.
3. Daftar paginasi 12 baris; pencarian judul/pengarang, filter periode, urutan judul, dan nomor halaman disimpan di URL. Kembali dari detail mengembalikan konteks filter. Judul lengkap tersedia di detail.
4. Layar kecil memakai baris kitab yang ditata ulang, bukan tabel desktop yang diperkecil. Detail menjadi permukaan penuh dengan kembali ke daftar. Kontrol sentuh 44 px; konten tidak tertutup navigasi bawah.
5. Alur pendamping untuk penilaian: pustaka → metadata → catatan, pencarian tanpa hasil → reset, memilih asisten → status ruang NotebookLM. Catatan hanya lokal dan diberi label. NotebookLM tidak disimulasikan dengan jawaban buatan.
6. Pemeriksaan pertama mencakup desktop, tablet, ponsel, keyboard, metadata panjang, halaman terakhir, hasil kosong, catatan bertahan saat navigasi/reload. Satu putaran perbaikan gabungan lalu konfirmasi. Hasil aktual dicatat di VERIFICATION.md.

## Batas teknis dan penerapan berikutnya

Prototipe lokal menguji arah tampilan dan interaksi. Ia tidak membuktikan login tunggal, hak akses notebook, atau percakapan berhasil. Penyatuan Firebase dan NotebookLM tetap memerlukan keputusan wadah browser yang didukung; mengganti warna atau tombol tidak menyatukan cookie WebView. Perubahan produksi UI lintas layar baru dilakukan setelah layar perwakilan ini ditinjau.

Saat arah ini diterapkan ke Flutter: petakan token ke `lib/core/design/`, gunakan widget navigasi responsif, komponen baris katalog dan panel detail bersama, pertahankan provider/kontrak backend serta model katalog, lalu inspeksi seluruh alur pada runtime sebenarnya. Tidak ada rilis publik atau broadcast otomatis pada iterasi ini.
