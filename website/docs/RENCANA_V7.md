# Rencana Website OpenTurath V7: selaras dengan aplikasi dan korpus V9.2

Status: usulan revisi 2 (setelah audit blind spot), menunggu persetujuan pemilik. Branch kerja: `v7-selaras-aplikasi` (salinan kerja di `AKSARAMAH DEV/05_WEBSITE_OPENTURATH`; folder asli di Downloads tidak diubah).

## 1. Temuan pada website V6

| Aspek | Keadaan V6 | Yang benar sekarang (aplikasi + V9.2) |
|---|---|---|
| Jumlah AI | 20 disiplin + Khazanah Habib Umar | 18 AI; Qawa'id dilebur ke Ushul, Fatawa ke Muqaran |
| Angka korpus | 5.370 kitab, 1.148.410.539 kata, 4.182.803 halaman, 11.901+ jilid, 2.876 partisi | 5.339 kitab, ±979 juta kata (berkas), ±3.500 berkas NotebookLM; jilid/halaman hanya yang tercatat di sumber |
| Angka per kartu | metadata lama, sebagian dibulatkan ("400+ Jilid", "115.000 halaman") | angka persis dari `info_ai.json` dan katalog, tanpa pembulatan promosi |
| Fikih Tahawwulat | 1.099 muhadharah | 58 kitab + 3.001 muhadharah dengan judul dan tautan |
| Kitab yang disebut di deskripsi | termasuk *Nailul Authar* (asy-Syaukani, diblok pemilik) | hanya kitab yang benar-benar ada di katalog V9.2 |
| Kebijakan kurasi | tidak dijelaskan | Ahlussunnah wal Jama'ah; Wahabi/salafi diblok (pengarang, pensyarah, muhaqqiq); matan saja untuk tahqiq salafi |
| Nama AI | "Kutubus Sunnah & Matan Hadits", "Ushul Fikih 4 Mazhab", dst. | sama dengan aplikasi: "AI Hadits", "AI Ushul & Kaidah Fikih", dst. |
| Tombol info aplikasi | tidak ada padanannya | halaman tiap AI memakai lima bagian yang sama: Tentang, Isi, Cara disusun, Batasan, Contoh tanya-jawab |

## 2. Prinsip

1. **Satu sumber data.** Katalog website dibangun otomatis dari `info_ai.json` dan `KATALOG_V9_2`, tidak diketik ulang. Build gagal bila angka website berbeda dari aset aplikasi.
2. **Nol klaim tanpa bukti.** Tidak ada "100% akurat", "400+", "jutaan". Angka persis atau tidak ditampilkan.
3. **Bahasa visual aplikasi.** Kanvas putih/hitam pekat, tombol pil hitam, Outfit untuk UI, Newsreader untuk judul editorial, **Scheherazade New untuk Arab (Amiri tidak dipakai di mana pun; aplikasi juga sudah diganti)**; aksen cyan hanya di mode gelap (sama dengan `theme.dart`).
4. **Tiga bahasa tetap** (ID, EN, AR, RTL).
5. **Komersial mengikuti aplikasi.** Harga dan paket dari `site.config.json` yang sudah diselaraskan dengan `product_pricing.dart`; transaksi tetap di aplikasi (DOKU).

## 3. Alur dan arsitektur informasi

**Beranda (diringkas dari 8 menjadi 7 bagian):**
1. Hero: satu kalimat nilai, dua tombol (Lihat 18 AI · Unduh aplikasi).
2. Angka korpus: 5.339 kitab · 18 AI · ±979 juta kata · 3 perpustakaan sumber · 3.001 muhadharah.
3. Cara kerja: tanya → ibarah Arab → rujukan jilid/halaman → telaah bersama guru (contoh Q001 dipertahankan).
4. Prinsip kurasi (bagian baru): Aswaja, penyaringan pengarang/muhaqqiq, pemilihan cetakan, matan saja.
5. 18 AI: kartu sesuai aplikasi (judul, nama Arab, angka nyata), dikelompokkan per rumpun seperti `field_model.dart`.
6. Akses dan harga, satu banner.
7. FAQ (diperbarui) dan footer.

**Halaman tiap AI (`/library/<id>`)**, cermin tombol info aplikasi:
Tentang · Isi (angka, cabang, kitab terbesar) · Daftar kitab lengkap yang bisa dicari · Cara disusun · Batasan · Contoh tanya-jawab (tampil bila sudah diisi).

**Halaman baru "Kurasi"** (`/kurasi`): aturan Aswaja, daftar kelompok yang diblok, alasan matan saja, angka pemetaan (46.048 rekaman → 5.339 kitab), dan cara melaporkan kesalahan metadata.

Halaman lain dipertahankan dan diperbarui isinya: metode, riset Q001, unduh, rilis, akses, bantuan, kontak/lapor, kebijakan.

## 4. Copywriting

- Kalimat pendek dan konkret, tanpa jargon promosi ("Super AI", "4D", "prestisius").
- Istilah konsisten dengan kamus aplikasi (`glossary-map.json`).
- Setiap klaim kemampuan disertai batasnya (AI bukan pengganti guru; rujukan mengikuti cetakan sumber).
- Deskripsi tiap AI hanya menyebut kitab yang ada di katalognya, diambil otomatis dari daftar kitab terbesar.

## 5. Pengerjaan teknis

1. `scripts/sync-app.mjs` (baru): membaca `info_ai.json`, `metadata_training_seluruh_ai.json`, dan katalog aplikasi, lalu menulis `content/catalog.json` dan `content/library/<id>.json`.
2. Uji baru: angka website = aset aplikasi; tidak ada judul kitab di deskripsi yang tidak ada di katalog; tidak ada nama terblok.
3. Desain ulang `immersive.css` mengikuti token warna dan tipografi aplikasi.
4. Uji yang ada (`npm test`, uji browser, aksesibilitas) tetap harus lulus.

## 6. Keputusan yang dibutuhkan

1. **Arah desain:** (a) mengikuti aplikasi persis (disarankan), atau (b) mempertahankan gaya editorial V6 dan hanya memperbarui isi.
2. **Khazanah Habib Umar:** tetap tampil sebagai "dalam persiapan", atau disembunyikan sampai siap.
3. **Harga di beranda:** satu banner "mulai Rp 50.000/bulan" (sesuai `site.config.json`), atau tampilkan ketiga paket aplikasi.

## 7. Audit blind spot (revisi 2)

### A. Ketepatan data dan rujukan

| # | Blind spot | Bukti | Tindakan |
|---|---|---|---|
| A1 | **Contoh Q001 di beranda tidak cocok dengan cetakan yang dipakai AI.** Website menulis «ولو مس بيده… من ثوب رقيق» = *al-Umm* ج١ ص٣٠; di cetakan V9.2 (ط الوفاء) kutipan itu ada di **ج٢ ص٣٨**. Sepuluh kutipan Q001 juga masih berstatus "belum diperiksa" (`app-parity.json`). | pencarian langsung di berkas render notebook 01 | Ulang Q001 terhadap notebook baru; tampilkan cetakan yang dipakai; periksa kesepuluh kutipan sebelum dipublikasi. |
| A2 | Ukuran "kata" belum didefinisikan. Berkas render ±979 jt kata (termasuk stempel dan header); teks kitab ±812 jt + catatan kaki ±117 jt. | perhitungan V9.2 | Publik memakai **kata teks kitab** (sama dengan angka di tombol info aplikasi), bukan kata berkas. |
| A3 | "Halaman" dan "jilid" tidak setara. Halaman di register = halaman digital; jilid hanya diketahui untuk sebagian kitab. | katalog: 2.265 entri tanpa jumlah jilid | Tampilkan kitab, kata, dan rentang wafat; jilid hanya bila sumbernya mencatat; halaman tidak ditampilkan sebagai "halaman cetak". |
| A4 | Angka akan berubah (3 kitab masih diproses; penambahan kitab di masa depan). | | Sinkronisasi otomatis dari aset aplikasi + tanggal data di footer + uji build yang menolak selisih. |
| A5 | Halaman kitab (`books.json`, 7 kitab) memuat data bibliografi yang belum tentu sama dengan cetakan V9.2. | *al-Umm* website vs ط الوفاء | Ambil dari katalog V9.2 atau hapus. |
| A6 | Deskripsi menyebut kitab yang diblok (*Nailul Authar*) atau tidak ada di katalog. | `catalog.json:347` | Uji build: setiap judul kitab di teks harus ada di katalog dan tidak ada di daftar blok. |
| A7 | Tahun wafat Habib Abu Bakar di materi lama 1444 H. | wafat 28 Dzulhijjah 1443 H (al-Ain, 28/7/2022) | Seragamkan 1443 H. |
| A8 | Transkrip muhadharah adalah tafrigh otomatis. | sumber JSONL | Disebut terang di halaman Fikih Tahawwulat dan Batasan. |
| A9 | 240 entri katalog tanpa nama pengarang di sumber; label "غير متوفر في المصدر" perlu padanan ID/EN. | `_PEMERIKSAAN_KATALOG.csv` | Label tiga bahasa; tidak diisi tebakan. |

### B. Keselarasan dengan aplikasi

| # | Blind spot | Tindakan |
|---|---|---|
| B1 | Aplikasi sendiri belum seragam: `field_model.dart` masih memuat profil `habib_umar`, dan `app-parity.json` mencatat `imam_ghazali` terkunci; website punya 21 profil. | Tetapkan satu daftar resmi (18 AI + profil terkunci, bila ada) dan pakai di keduanya. |
| B2 | Harga: README menyebut Rp 49.000, `site.config.json` Rp 50.000 / 299.000 / 499.000; `app-parity.json` mencatat kebijakan refund 30 hari vs produk berbasis bulan, dan entitlement backend yang belum dicek. | Cocokkan dengan konstanta harga aplikasi terbaru sebelum ditampilkan; isu refund diselesaikan di naskah kebijakan. |
| B3 | Tautan dari website ke AI tertentu di aplikasi (`appDeepLinkBase` kosong). | Siapkan deep link per AI bila aplikasi mendukung; bila tidak, tombol menuju unduh. |
| B4 | Nama AI, cabang, dan angka harus sama persis dengan aplikasi. | Diambil otomatis dari `info_ai.json`/`metadata_training_seluruh_ai.json`. |

### C. Alur dan UX

| # | Blind spot | Tindakan |
|---|---|---|
| C1 | URL lama AI yang dilebur (Fatawa, Qawa'id) akan 404 dan kehilangan SEO. | Pengalihan 301 ke AI tujuan + entri di sitemap. |
| C2 | Katalog lengkap 5.326 entri (7,5 MB) tidak boleh dimuat sekaligus; Hadits saja 1.138 kitab. | Halaman per AI dengan daftar statis bertahap + indeks pencarian ringan per AI. |
| C3 | Mayoritas pengguna di ponsel Android (APK). | Desain mobile-first; anggaran ukuran halaman; uji di lebar 360 px. |
| C4 | Distribusi hanya APK; iOS dan Play Store belum ada. | Dikatakan terang di halaman unduh; SHA-256 tetap ditampilkan. |
| C5 | Teks Arab dan Inggris untuk naskah baru. | Draf saya, lalu diperiksa pemilik/penutur sebelum terbit; tidak memakai terjemahan mesin tanpa pemeriksaan. |
| C6 | Belum ada tangkapan layar aplikasi asli. | Ambil dari simulator setelah UI aplikasi final; tidak memakai gambar rekaan. |

### D. Risiko isi

| # | Blind spot | Tindakan |
|---|---|---|
| D1 | Halaman Kurasi yang menyebut nama tokoh terblok dapat memicu polemik/risiko hukum. | Usulan: tampilkan **kriteria dan angka**, bukan daftar nama tokoh. |
| D2 | Klaim "verifikasi" bisa dibaca sebagai jaminan bebas salah. | Bahasa yang sama dengan kebijakan aplikasi: rujukan dapat ditelusuri, AI tetap bisa keliru, guru tetap rujukan. |
| D3 | Q001 membandingkan enam model AI bernama. | Pertahankan faktual, tanpa logo; ulang setelah A1. |
| D4 | Naskah kebijakan v1.0 perlu dicek terhadap jumlah modul dan nama baru. | Diperiksa dan diselaraskan; versi kebijakan dinaikkan bila isinya berubah. |

### E. Teknis dan proses

| # | Blind spot | Tindakan |
|---|---|---|
| E1 | Uji lama (`content-v6`, `parity`) mengunci angka V6. | Ditulis ulang untuk V7 dan sumber data aplikasi. |
| E2 | Ada dua salinan situs (Downloads dan proyek). | Satu sumber: salinan proyek di branch `v7-selaras-aplikasi`; hasil akhir diserahkan ke pemilik; tidak ada push/deploy tanpa izin. |
| E3 | Berkas font Amiri masih ada di `public/assets/fonts`. | Dihapus dari aset agar tidak terpakai. |
| E4 | Aksesibilitas: kontras teks abu-abu, urutan fokus, RTL. | Uji axe dan uji browser tetap wajib lulus. |

### Keputusan tambahan

4. **Halaman Kurasi:** kriteria + angka saja (disarankan), atau juga daftar nama tokoh yang diblok?
5. **Profil terkunci** (Habib Umar, Imam al-Ghazali): tampil sebagai "dalam persiapan" di aplikasi dan website, atau keduanya disembunyikan?
6. **Q001:** diulang terhadap notebook baru setelah diunggah (disarankan), atau sementara diturunkan dari beranda?
