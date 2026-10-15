# Audit produk dan kode OpenTurath

Tanggal: 23 September 2026, Asia/Aden. Objek: folder `openturath-website 6`, versi website 6.0.0.

**Keputusan: tunda promosi penawaran berbayar sampai cakupan, harga, dan durasinya terbukti konsisten dengan aplikasi. Prioritas desain adalah memperjelas tugas dan bukti, bukan menambahkan dekorasi.** Tidak ditemukan eksploit Critical yang terkonfirmasi pada kode website yang diperiksa. Ini bukan sertifikasi keamanan aplikasi, APK, atau deployment produksi.

Audit ini tidak mengubah implementasi. Dua lampiran menyertai laporan: `route-inventory.csv` mencatat seluruh 57 route template; `copy-inventory.json` mencatat 248 key UI per bahasa, FAQ, artikel, profil, bibliografi, paket, dan catatan rilis. Inventaris juga memuat string lama yang belum tentu dirender. Arsip jawaban asli diperlakukan sebagai sumber historis, bukan copy pemasaran untuk ditulis ulang.

## Dasar pemeriksaan dan batas bukti

- Membaca generator, renderer, routing, copy, artikel, katalog, metadata, konfigurasi komersial, JS interaksi, CSS, API Python, SQLite, deployment, packaging, dokumentasi operasi, dan tes.
- Tidak ada `.git` pada folder ini; riwayat perubahan, status branch, serta CI tidak dapat diverifikasi. Tidak ditemukan AGENTS.md yang berlaku di root proyek.
- `npm test`: **23 tes Node dan 13 tes Python lulus**. `npm run check`: **171 halaman lokal, 9.705 tautan/aset internal, 6 hash arsip, dan 10 catatan kutipan lulus**.
- Build produksi memakai **konfigurasi asli dalam salinan sementara**: 172 halaman berhasil dibuat. Source, konfigurasi, dan `dist/` proyek tidak ditulis ulang untuk audit ini.
- Browser langsung menggunakan server loopback dan SQLite sementara. Formulir sintetis berhasil menyimpan laporan dan mengembalikan ID `OT-…`. Tidak ada pesan dikirim kepada pihak lain.
- Pemeriksaan layout baru: enam route (`/id/`, `/ar/`, `/id/access/`, `/ar/research/q001/`, `/id/report/`, `/id/download/`) pada 320, 768, dan 1440 CSS px. Tambahan katalog ID pada 390 px, katalog EN pada 1920 px, beranda EN/AR pada 390 px, dan panduan rujukan/privacy mobile. Tidak ada overflow halaman pada 18 kombinasi utama tersebut; ini tidak membuktikan seluruh konten bebas clipping atau nyaman dibaca.
- Inspeksi visual langsung meliputi hero light/dark, katalog, kartu, keanggotaan, unduhan, panduan, serta RTL. Pemeriksaan source mencakup seluruh keluarga route; **bukan screenshot manual setiap satu dari 172 halaman**.
- Kontrol perbesar teks arsip mengubah font 16 → 18 px. Pencarian, isi dialog, dan CTA diuji. Log browser yang dibaca tidak memuat error/warning; ini bukan rekaman lengkap seluruh request jaringan.
- Tidak menjalankan ulang suite Playwright/axe bawaan. Hasil browser lama di `docs/` tidak dianggap hasil audit ini. Zoom 200–400%, pembaca layar sungguhan, reduced-motion OS, offline, perangkat Android/iOS nyata, serta seluruh state jaringan masih memerlukan pengujian khusus. Tidak tersedia skrip lint/typecheck pada `package.json`.
- Tidak menginstal/mengeksekusi APK, masuk ke akun, melakukan pembayaran, atau mengaudit backend Flutter/Firebase/NotebookLM yang tidak ada di folder ini. Penilaian bahasa Arab mencakup UI/RTL dan konsistensi, bukan sertifikasi penyuntingan Arab ilmiah.

Jenis temuan: **Bug** = perilaku yang salah; **UX** = hambatan tugas; **Inkonsistensi** = kontradiksi antarpermukaan; **Debt** = risiko pemeliharaan/operasi; **Preferensi** = arah desain yang perlu diuji dengan pengguna. Tingkat prioritas bukan bukti bahwa kode dibuat AI.

## A. Executive summary

1. **High — Kredibilitas penawaran bermasalah.** [content/app-parity.json](</Users/apple/Downloads/openturath-website 6/content/app-parity.json>) menyatakan `pricingParity:false`, sementara website menawarkan Rp49.000/bulan dan konfigurasi menyimpan tiga paket baru. Build produksi tetap lolos. Catatan harga backend adalah bukti ketidaksesuaian yang belum diselesaikan, bukan observasi checkout live terbaru.
2. **High — Janji akses terlalu luas.** Judul “Akses Penuh Khazanah Keilmuan” dipasangkan dengan harga paket yang cakupannya hanya satu asisten. Penjelasan rinci ditunda sampai aplikasi/checkout. Pengguna dapat memahami harga tersebut sebagai akses seluruh koleksi.
3. **High — Janji verifikasi mendahului bukti.** Hero menyebut verifikasi “secara presisi”; semua 10 kutipan contoh berstatus `not-reviewed`, edisi dan catatan penelaah belum tersedia. Penjelasan keterbatasan ada, tetapi muncul setelah impresi pertama terbentuk.
4. **High — Katalog mengutamakan angka, bukan pemilihan.** Pada lebar 390 px, tiga kartu pertama sekitar 693–724 px tinggi; halaman katalog sekitar 18.027 px. Angka kitab mendominasi judul dan cakupan. Beranda ID pada 320 px sekitar 26.178 px panjangnya. Angka ini menunjukkan biaya scroll, bukan skor performa.
5. **High — Ada ketidakcocokan janji interaksi.** “Buka Akses di Aplikasi” membuka `/download/`. Placeholder mencari judul/pengarang tampil pada beranda yang hanya memfilter profil. “Buka rujukan” bisa membuka modal bibliografi atau arsip, bukan sumber edisi.
6. **Medium — Terasa dirancang untuk presentasi sebelum digunakan.** Hero monumental, enam statistik, 21 kartu bento, efek spotlight/paralaks, dan heading berpasangan berulang membuat perjalanan terasa seperti portfolio. Identitas kitab, teks Arab, dan adab tetap khas; menggantinya dengan template SaaS lain akan memperburuk keadaan.
7. **High/Medium — Aksesibilitas memiliki celah konkret.** Dialog tidak diberi accessible name; batas input berkontras rendah; kutipan Arab di dalam jawaban markdown tidak ditandai bahasa; daftar isi hilang pada mobile. Dukungan `dir=rtl`, label form, fokus, dan native details yang sudah ada perlu dipertahankan.
8. **Medium — Kesiapan operasi belum sama dengan lolos build.** Rate limiter bersifat per-proses, retensi bergantung penjadwalan operator, dan error server disembunyikan tanpa pencatatan terstruktur. Build report bahkan masih mengatakan APK belum tersedia padahal berkas aktif ada.
9. **Perubahan terbesar:** buat penawaran yang dapat diperiksa, satu contoh sumber yang benar-benar ditelaah, katalog ringkas, dan CTA yang menjelaskan langkah berikutnya. Kosmetik datang sesudahnya.

## B. AI-slop scorecard

| Aspek | Kategori | Bukti konkret | Penilaian |
| --- | --- | --- | --- |
| Visual AI slop | High | [src/home.mjs:10](</Users/apple/Downloads/openturath-website 6/src/home.mjs:10>), [src/metadata.mjs:29](</Users/apple/Downloads/openturath-website 6/src/metadata.mjs:29>), `immersive.css:200`, kartu 693–724 px mobile | Ukuran monumental dipakai berulang tanpa prioritas tugas; warna hitam pada varian kartu ikut memberi bobot yang tidak menjelaskan relevansi. |
| Copywriting AI slop | High | [src/copy.mjs:15](</Users/apple/Downloads/openturath-website 6/src/copy.mjs:15>), `:26`, `:235`: “Ilmu. Lebih dekat.”, “Ruang bagi setiap telaah”, “Ruang telaah tanpa batas” | Pola kalimat pendek berpasangan dan metafora “ruang/telaah/khazanah” terlalu sering menggantikan informasi. Tidak setiap kalimat puitis perlu dihapus. |
| UX AI slop | High | [src/membership.mjs:9](</Users/apple/Downloads/openturath-website 6/src/membership.mjs:9>), [src/pages.mjs:16](</Users/apple/Downloads/openturath-website 6/src/pages.mjs:16>), [src/home.mjs:29](</Users/apple/Downloads/openturath-website 6/src/home.mjs:29>) | CTA dan pencarian terlihat lengkap tetapi cakupan/tujuannya tidak sesuai ekspektasi. Ini lebih serius daripada gaya visual. |
| Architecture AI slop | Medium | Template besar satu baris di [src/pages.mjs](</Users/apple/Downloads/openturath-website 6/src/pages.mjs>); dua lapis CSS; string lama dan wiring tab yang tidak dipakai | Gejala implementasi bertumpuk. Tidak cukup bukti untuk menyimpulkan asal-usul AI, dan bukan alasan pindah framework. |
| Marketing AI slop | High | `accessTitle`, `heroSub`, `statsTitle`; parity pending; Q001 belum dinilai | Bahasa kepastian lebih kuat daripada bukti yang bisa diperiksa. Angka korpus diperlakukan sebagai sinyal mutu meski tidak membuktikan akurasi. |

Tidak ditemukan pola dominan gradient ungu/navy, emoji sparkle, atau dashboard vanity lengkap. Masalah khas proyek ini adalah **monumentalitas, repetisi retoris, dan demonstrasi kredibilitas yang belum selesai**, bukan semua stereotip AI UI sekaligus.

Jika logo dihapus, tipografi Arab, kitab, dan materi adab tetap mengidentifikasi ranahnya. Identitas unik OpenTurath perlu datang dari kurasi, cakupan, dan jejak pemeriksaan sumber yang nyata; benda dekoratif kitab saja belum cukup.

## C. Audit halaman per halaman

Semua route di bawah tersedia dengan prefiks `/id/`, `/en/`, `/ar/`, kecuali `/`. Route yang berbagi renderer dinilai bersama, dengan seluruh variannya tercatat pada lampiran. P/S/T berarti primary, secondary, tertiary.

| Halaman / purpose | Problems & why it matters | Recommendation dan visual priority | Priority |
| --- | --- | --- | --- |
| `/` — memilih bahasa | “Welcome.” generik; satu langkah tambahan sebelum memahami produk. Redirect hanya setelah pilihan tersimpan, sehingga tidak boleh diasumsikan otomatis mendeteksi bahasa. | P pilih bahasa; S satu kalimat fungsi produk; T slogan. Pilihan manual tetap mudah diakses; jangan memaksa deteksi lokasi. | Low, UX/preferensi |
| Beranda — memahami manfaat dan masuk ke tugas | Hero → enam angka → metode → 21 kartu → contoh → harga → adab → FAQ. Contoh yang dapat dinilai dan informasi biaya terlalu jauh; gambar bukan bukti interaksi aplikasi. | P memahami fungsi melalui satu contoh konkret; S pilih bidang/unduh Android; T statistik rinci. Ringkas katalog beranda ke representasi bidang, sediakan seluruh katalog di halaman khusus. | High, UX |
| `/library/` — memilih koleksi | 21 profil + 7 kitab ikut satu pencarian/counter. Saat JS aktif terlihat 28 hasil, HTML awal 21. Kartu besar mengubur kitab contoh; heading puitis mendahului kontrol. | P bidang dan cakupan; S ketersediaan dan kitab contoh; T jumlah halaman/kata. Bedakan hasil “profil” dan “kitab contoh”; tampilkan pencarian segera. | High, bug/UX |
| `/library/{20 profil aktif}` — mengenali bidang | Deskripsi di page-head diulang di bagian cakupan. Sebagian besar tidak memiliki contoh yang dapat dibuka; metadata mengambil ruang besar; CTA unduh ada di sidebar dan penutup. | P cakupan + contoh pekerjaan; S sumber/status akses; T statistik. Hapus repetisi; satu CTA utama. Contoh yang belum ada jangan direkayasa. | Medium, UX |
| `/library/fiqh-syafii/` — detail dengan tujuh contoh kitab | Hanya profil ini mempunyai daftar kitab contoh; pengguna bidang lain mendapat detail lebih tipis dengan bentuk sama. | Jelaskan “contoh dari arsip Q001”, jangan tampilkan seolah daftar lengkap seluruh korpus. | Medium, clarity |
| `/library/habib-umar/` — koleksi dalam persiapan | Status sudah berbeda, tetapi tetap satu dari “hasil” katalog dan menambah beban pemilihan bidang aktif. | P status belum tersedia; S catatan rilis; T uraian rencana. Pisahkan dari pilihan yang bisa digunakan. | Low, UX |
| `/books/{7 judul}` — bibliografi contoh | Semuanya menampilkan edisi belum tersedia dan status belum diperiksa. Pengguna yang ingin memverifikasi tiba di metadata yang belum cukup. | P status dan batas sumber; S identitas edisi jika sudah diperoleh; T tautan kembali Q001/laporan. Jangan menyebutnya sumber terverifikasi. | High, trust |
| `/research/` — masuk arsip perbandingan | “Bukti yang bisa Anda baca” memberi kesan validasi, padahal hanya satu kasus dan kondisi uji tidak tercatat. | P “Arsip contoh Q001”; S batas metodologi; T nama enam produk. | High, trust |
| `/research/q001/` — membaca dan membandingkan | Dua jawaban panjang baru diikuti dimensi/evidence. Pada RTL 320 px panjang sekitar 36.817 px. Pengguna perlu kembali jauh untuk mengganti jawaban/menemukan bukti. | P membaca satu jawaban dan melompat ke kutipan; S perbandingan; T panjang karakter. Tambahkan tautan dalam halaman ke bukti/metode; pertahankan arsip asli dan status belum diperiksa. | High, UX |
| `/research/methodology/` — memahami batas bukti | Isi jujur tetapi tidak cukup terlihat sebelum pembaca memakai label “pengujian” untuk menilai produk. | P keterbatasan dan status bukti; S metode pencocokan; T hash. Ringkas batas ini dekat kartu kasus. | Medium, IA |
| `/research/corrections/` — melihat koreksi | Empty state tersedia tetapi tidak memberi tanggal cakupan atau hubungan dengan bukti yang masih belum diperiksa. Tidak ada entry mudah dari kartu kasus utama. | P belum ada koreksi terbit; S laporan/kasus; T penjelasan proses. Jangan menyamakan belum ada koreksi dengan bebas kesalahan. | Low, UX |
| `/how-it-works/` — mengerti penggunaan | Menjelaskan metode keilmuan, belum menunjukkan perpindahan Android → akun → koleksi → NotebookLM. | P langkah penggunaan aktual; S metode telaah; T teori verifikasi. Jelaskan layanan pihak ketiga sebelum keputusan membeli. | High, onboarding |
| `/access/` — memutuskan akses berbayar | Klaim penuh + harga satu asisten; CTA menuju unduh; cakupan paket dan batas NotebookLM tidak hadir dekat harga. | P apa yang diperoleh dengan harga tersebut; S durasi, prasyarat, perpanjangan; T metode pembayaran. Tahan penawaran yang belum selaras backend. | High, trust/conversion |
| `/download/` — mendapat aplikasi | Empat kartu berbobot sama meski hanya Android aktif. Tiga platform belum tersedia tetap menampilkan versi/tanggal rilis. Pada desktop 900 px tinggi, CTA unduh berada di bawah bagian awal layar. | P Android aktif dan ukuran/sistem minimum; S panduan dan checksum; T platform rencana dalam satu baris. Tanggal/versi jangan disajikan sebagai rilis platform yang belum ada. | High, UX |
| `/releases/` dan `/releases/1.0.51/` — memahami perubahan | Hanya satu rilis; body membahas “versi yang tercantum dalam konfigurasi pengelola”, bukan apa yang berubah. | P perubahan konkret bagi pengguna; S kendala diketahui; T nomor/tanggal/unduh. Minta fakta rilis, jangan menulis perubahan fiktif. | Medium, copy |
| `/help/` — menemukan bantuan | Empat panduan + FAQ panjang. Hasil kosong generik menyuruh hapus filter padahal halaman ini tidak punya filter/reset. | P pilih masalah/cari panduan; S kontak; T FAQ lain. Beri clear pencarian dan pesan khusus konteks. | Medium, UX |
| `/help/install/` — memasang APK | Menjelaskan saluran/hash, tetapi belum memberi urutan pemasangan, menemukan berkas, pembaruan, dan penanganan kegagalan. | P langkah Android dengan status yang diharapkan; S kegagalan umum; T verifikasi teknis. Jangan meminta mematikan perlindungan perangkat secara menyeluruh. | High, onboarding |
| `/help/references/` — memeriksa kutipan | Penomoran mulai 02,03,04 tanpa 01. Di mobile daftar isi hilang. | P langkah pemeriksaan yang lengkap dan lokal ke halaman; S contoh edisi; T penjelasan lanjutan. | Medium, inkonsistensi |
| `/help/account/` — akun dan catatan | Instruksi singkat, tidak membedakan pemulihan akun OpenTurath, akun Google, dan data perangkat dalam alur pemecahan masalah. | P pilih jenis masalah; S prasyarat/data yang diperlukan; T penjelasan penyimpanan. | Medium, UX |
| `/help/access/` — memecahkan akses/pembayaran | Satu-satunya panduan yang menyebut tiga paket sekaligus dan meminta pengguna berhenti jika penawaran aplikasi berbeda. Beban rekonsiliasi dipindah ke pembeli. | P status pembayaran vs akses; S solusi kendala; T rincian paket yang sudah disahkan. Sinkronkan penawaran secara internal. | High, trust |
| `/contact/` dan `/report/` — bantuan/koreksi | Kedua halaman hampir identik dan topik default “Koreksi rujukan”, bahkan untuk kontak umum. Semua kegagalan API menjadi pesan sama. | P pilih tujuan/pesan; S email opsional; T kebijakan. Gunakan default sesuai konteks, pesan error yang dapat ditindaklanjuti, dan pengakuan SLA dekat keberhasilan bila benar-benar dioperasikan. | Medium, UX |
| `/billing/` — biaya/refund | Durasi bulan di situs berhadapan dengan 30 hari kalender pada naskah resmi; rincian tersebar di FAQ, config, dan artikel. | P harga/cakupan/durasi tunggal; S refund dan aktivasi; T detail penyedia. Perlakukan sebagai konsistensi produk; bukan kesimpulan legal audit ini. | High, consistency |
| `/terms/` — ketentuan | Identitas “Pengelola OpenTurath” belum menjelaskan entitas yang bertanggung jawab; naskah resmi hanya unduhan Markdown bahasa ID. | P ketentuan berlaku dan identitas; S ringkasan; T arsip versi. Tampilkan naskah resmi dalam HTML yang bisa dibaca, tetap sediakan unduhan. | Medium, trust |
| `/privacy/` — praktik data | Klaim laporan dijadwalkan terhapus setelah 30 hari bergantung setup operator yang tidak dibuktikan oleh artefak deployment. | P praktik website vs aplikasi; S retensi dan hak; T penyedia. Buktikan jadwal retensi dan jelaskan backup/log secara proporsional. | Medium, privacy |
| `/account-deletion/` — menghapus akun | Jalur aplikasi/email ada; tidak ada estimasi penyelesaian atau status permohonan pada halaman. | P cara mengajukan; S verifikasi dan data yang tetap disimpan; T batas penghapusan NotebookLM. Tambahkan SLA hanya setelah disepakati operator. | Medium, clarity |
| `/security/` — melaporkan kerentanan | Kanal email ada; tidak ada pengakuan penerimaan atau lingkup penanganan spesifik. | P kanal dan data minimum; S proses tindak lanjut; T praktik umum. Jangan meminta bukti berupa data pengguna lain. | Low, operations |
| `/sources-and-rights/` — hak sumber | Penjelasan prinsip ada, tetapi tidak menyediakan provenance/izin per edisi yang dapat diperiksa. Flag `comparisonRightsConfirmed` bukan bukti hak tersebut. | P asal edisi dan batas pemakaian; S jalur koreksi hak. Audit legal substantif terpisah. | Medium, evidence gap |
| `/about/` — memahami pengelola | Mengulang proposisi homepage; identitas editorial, siapa yang menelaah, dan bentuk organisasi tidak dijelaskan. | P siapa pengelola dan tanggung jawabnya; S metode kurasi; T misi. Nama harus berdasarkan fakta. | Medium, trust |
| `/ai-guidelines/` — adab pemakaian | Tujuh prinsip relevan, tetapi preview beranda menambah repetisi slogan. | P prinsip operasional membaca/menukil; S atribusi editorial; T prosa pengantar. Pertahankan atribusi yang membedakan rumusan editorial dari fatwa tokoh. | Low, polish |
| `/tahawwulat/` — fitur khusus | Menamai lima asisten tetapi tidak mempunyai jalur langsung ke koleksi terkait dari blok isi. Penutup generik report/download. | P peran setiap asisten; S buka detail Fikih Tahawwulat; T penjelasan batas personifikasi. | Medium, discoverability |
| `/accessibility/` — cara mengakses | Menyebut kemampuan yang ada, tetapi tidak mencatat batas seperti dialog tanpa nama atau status pengujian. | P bantuan dan kontrol; S keterbatasan yang diketahui dan kanal masalah. Hindari klaim kepatuhan penuh sebelum verifikasi. | Medium |
| `/404/` — pulih dari URL salah | Halaman lokal tersedia; contoh Nginx menggunakan satu `/404.html` salinan ID untuk semua URL. Pengunjung EN/AR bisa mendapat bahasa ID. | P kembali ke bagian/bahasa asal; S cari/bantuan. Uji route 404 melalui konfigurasi hosting sesungguhnya. | Medium, deployment inconsistency |

### Varian data yang tercakup

20 koleksi aktif: fiqh-syafii, hadits, ushul-fiqh, bahasa-arab, tafsir, fiqh-tahawwulat, tarikh-sirah, fiqh-muqaran, fatawa-masail, syarah-hadits, fiqh-hanafi, fiqh-maliki, fiqh-hanbali, tasawwuf, tajwid-qiraat, qawaid-fiqhiyyah, musthalah-hadits, aqidah, thabaqat-tarajim, bibliografi-faharis; satu persiapan: habib-umar. Tujuh bibliografi: al-umm, al-aziz, al-majmu, fath-al-wahhab, bujairimi, nihayat-al-zayn, mukhtasar-tuhfa. Masalah template berlaku pada seluruh varian tersebut; tidak disimpulkan ada kerusakan unik pada setiap varian tanpa bukti.

## D. Copy audit

Prioritas pertama adalah kebenaran janji, lalu kejelasan label, kemudian gaya. Usulan harga di bawah **hanya boleh dipakai setelah paket benar-benar selaras**. Kutipan jawaban arsip tidak diubah.

| Current Copy | Problem | Recommended Copy | Reason |
| --- | --- | --- | --- |
| Ilmu. Lebih dekat. | Tidak menjelaskan fungsi sebagai H1 utama | Temukan pembahasan dalam kitab-kitab Islam. | Menyebut pekerjaan yang dibantu; slogan lama bisa menjadi elemen sekunder. |
| Khazanah para ulama. Dalam jangkauan Anda. | Mengulang janji kedekatan pada H1 | Pilih bidang kajian, baca kutipan, lalu periksa rujukannya. | Memberi langkah konkret. |
| Menelaah ribuan karya klasik dan kontemporer dengan verifikasi teks Arab, jilid, dan halaman secara presisi. | Kepastian verifikasi tidak didukung contoh yang selesai diperiksa | Telusuri pembahasan dan kutipan Arab beserta rujukan jilid dan halaman. Cocokkan kembali dengan edisi sumber. | Memisahkan penelusuran dari hasil pemeriksaan. |
| Khazanah besar. Ruang telaah tanpa batas. | “Tanpa batas” bertentangan dengan paket dan batas layanan eksternal | 20 bidang kajian dalam khazanah OpenTurath. | Klaim terbatas dan dapat ditelusuri. |
| Khazanah para ulama. Ruang bagi setiap telaah. | Menambah baris sebelum tugas katalog | Pilih bidang kajian | Mempercepat pemindaian halaman. |
| Temukan khadim yang memahami bidang telaah Anda. | Personifikasi kemampuan pemahaman | Pilih khadim sesuai bidang kajian Anda. | Menjelaskan pengelompokan tanpa menjanjikan pemahaman. |
| Cari judul kitab, pengarang, atau bidang… [beranda] | Indeks beranda tidak berisi katalog kitab/pengarang lengkap | Cari bidang kajian atau khadim | Menyesuaikan dengan cakupan pencarian. |
| Jelajahi seluruh pustaka | Tujuan adalah profil dan tujuh kitab contoh, bukan seluruh teks | Lihat semua bidang kajian | Label sesuai isi tujuan. |
| Kenali koordinat cetakan | Jargon teknis untuk tugas sederhana | Cocokkan edisi, jilid, dan halaman | Tindakan spesifik, tidak metaforis. |
| Buka rujukan [modal] | Membuka bibliografi belum terverifikasi, bukan naskah sumber | Lihat rincian rujukan | Tidak menjanjikan akses sumber asli. |
| Buka rujukan [tautan Q001] | Label sama untuk tujuan berbeda | Baca contoh jawaban Q001 | Mengurangi kejutan navigasi. |
| Bukti yang bisa Anda baca. | Menyiratkan validasi terhadap kualitas produk | Arsip jawaban dan catatan pemeriksaan | Menamai isi secara akurat. |
| Bandingkan keluaran asli enam model | Yang tercatat enam produk; versi model justru tidak diketahui | Bandingkan enam jawaban dalam arsip ini. | Tidak mengklaim identitas model yang tidak tercatat. |
| Akses Penuh Khazanah Keilmuan | Berdekatan dengan harga satu asisten | Akses khadim pilihan Anda | Menghindari kesan all-access pada harga masuk. |
| Mulai dari Rp49.000 / bulan | Cakupan tidak terikat langsung ke nominal | Rp49.000 untuk satu khadim selama [durasi yang disahkan] | Membuat unit pembelian jelas. Jika belum sah: “Rincian akses sedang diselaraskan.” |
| Buka Akses di Aplikasi | Saat ini membuka unduhan | Unduh aplikasi Android | Label mengikuti destination aktual; gunakan label buka aplikasi hanya untuk deep link terverifikasi. |
| Tinjauan refund hingga 7 hari kerja | Campuran bahasa dan terasa seperti terjemahan | Ketentuan pengembalian dana | Link menyebut tujuan; SLA dijelaskan di isi. |
| Versi 1.0.51 / tanggal rilis pada macOS, Windows, iOS | Terlihat sudah rilis meski belum tersedia | Belum tersedia | Hilangkan metadata rilis yang belum dibuktikan per platform. |
| Lanjutkan telaah di OpenTurath. [download] | Tujuan operasional tersamar oleh slogan | Unduh OpenTurath untuk Android | Menyebut platform aktif dan aksi. |
| Ada yang ingin Anda ketahui? [help] | Generik; tidak membantu menemukan tugas | Bantuan menggunakan OpenTurath | Menamai halaman. |
| Sampaikan pertanyaan Anda. [report] | Sama dengan kontak umum | Laporkan masalah atau koreksi rujukan | Membedakan maksud formulir. |
| Tidak ada hasil. Ubah kata kunci atau hapus filter. [help] | Tidak ada filter di halaman bantuan | Panduan tidak ditemukan. Coba kata kunci lain atau hubungi bantuan. | Recovery sesuai halaman. |
| Laporan belum terkirim. Coba kembali, atau unduh salinannya. | 429, timeout, 422, 503 tidak dibedakan | 429: “Terlalu banyak percobaan. Tunggu beberapa menit, lalu kirim kembali.” | Saran sesuai penyebab; tetap pertahankan isian dan opsi salinan. |
| Versi aplikasi yang tercantum dalam konfigurasi pengelola adalah 1.0.51. | Bahasa internal implementasi | Versi 1.0.51 — [perubahan yang telah dikonfirmasi] | Changelog harus membantu keputusan pengguna. |
| 21 نتائج / 1 نتائج | Plural Arab generik tidak sesuai semua bilangan | Gunakan bentuk menurut jumlah, mis. نتيجة واحدة untuk satu | Perlu aturan plural dan format angka per locale. |
| Knowledge. Within reach. / The scholarship of generations. Within your reach. | Pengulangan reach, tanpa fungsi yang jelas | Find passages in Islamic reference works. | Terjemahan mengikuti tujuan produk, bukan ritme slogan saja. |

### Vocabulary yang disarankan

| Konsep | ID | EN | AR | Aturan |
| --- | --- | --- | --- | --- |
| Profil asisten bidang | Khadim (asisten bidang kajian) | Specialist assistant | مساعد متخصص | Definisikan “khadim” pada kemunculan pertama ID, jangan bergantian tanpa alasan dengan pustaka. |
| Kelompok materi | Koleksi | Collection | مجموعة | Bedakan koleksi dari asisten dan kitab. “Khazanah” dapat menjadi nama area produk. |
| Unit disiplin | Bidang kajian | Field of study | مجال الدراسة | Konsisten dengan filter dan jumlah 20 bidang aktif. |
| Isi primer | Kutipan kitab / ibarah | Source passage | نص من المصدر | Istilah ibarah dipertahankan bagi audiensnya dengan penjelasan awal. |
| Status bukti | Belum diperiksa / Sudah dicocokkan | Not reviewed / Matched | لم يُراجع / تمت المقابلة | “Matched” hanya untuk kecocokan kutipan, bukan seluruh kesimpulan jawaban. |
| Halaman arsip | Arsip contoh | Example archive | أرشيف أمثلة | “Pengujian” dipakai saat metodologi/kondisi uji tercatat. |
| Biaya | Pengembalian dana | Refund | استرداد المبلغ | Hindari campuran refund/pengembalian di kalimat ID. |
| Satuan waktu | Durasi akses | Access period | مدة الوصول | Pilih kalender bulan atau jumlah hari secara konsisten setelah keputusan komersial. |

Gunakan sentence case pada label Indonesia; pertahankan nama kitab dan transliterasi sebagai nama proper. Pilih ejaan hadis/hadits, akidah/aqidah, wudu/wudhu untuk UI; bentuk judul karya asli boleh berbeda. Query sebaiknya menerima sinonim. Jangan mengubah nama produk/istilah ilmiah hanya demi seragam dengan bahasa umum.

## E. UX flow audit

| Goal, entry, keputusan | Current Flow → Friction → Recommended Flow | Feedback, completion, next action |
| --- | --- | --- |
| Memahami produk; beranda | Slogan → gambar → statistik → metode → kartu → penjelasan NotebookLM di FAQ → ketergantungan platform baru diketahui belakangan → fungsi ringkas + contoh + Android/akun/prasyarat sebelum CTA | Selesai ketika pengguna tahu yang dibeli dan tempat interaksi; lanjut pilih bidang atau unduh. |
| Mencari bidang; beranda/katalog | Query yang sama → beranda 21 profil, katalog 28 item campuran → hasil berbeda tanpa penjelasan → satu indeks dan jenis hasil eksplisit, atau dua pencarian berlabel berbeda | `Al-Nawawi`: beranda 0, katalog 1 terkonfirmasi. Empty state harus menjelaskan cakupan; lanjut buka detail atau ubah query. |
| Memilih bidang; katalog | Kartu sangat tinggi → metadata dominan → detail mengulang deskripsi → unduh → hilang konteks bidang → daftar ringkas → detail cakupan dan contoh → handoff dengan konteks bidang bila aplikasi mendukung | Nyatakan jika pilihan bidang belum dapat dibawa ke aplikasi; jangan membuat deep link palsu. |
| Membeli akses; keanggotaan | “Akses penuh” + harga masuk → “Buka akses” → download → akun/app/checkout eksternal → entitlement belum terbukti sama → cakupan/durasi/prasyarat yang disahkan → label unduh/buka yang tepat → checkout konsisten | Pisahkan dibayar vs akses aktif; masalah pembayaran arahkan bantuan, jangan mendorong bayar ulang. Transaksi aktual di luar cakupan audit. |
| Memasang; download | Empat kartu termasuk tiga belum tersedia → hash/panduan umum → belum ada langkah pemasangan → Android utama → petunjuk langkah → kasus gagal/perbarui | Situs hanya bisa mengonfirmasi tautan dibuka, bukan instalasi berhasil. Tidak boleh memakai klik sebagai metrik instalasi. |
| Memeriksa sumber; cuplikan/Q001 | Klik “rujukan” → modal → bibliografi tanpa edisi → kembali Q001 → evidence di bawah jawaban panjang → status belum diperiksa → status langsung pada cuplikan → detail edisi/source yang tersedia → kembali ke kutipan | Bedakan tersedia/tidak tersedia/belum diperiksa. Beri langkah laporkan atau telusuri edisi, bukan dead end tanpa konteks. |
| Membandingkan; Q001 | Pilih kiri/kanan → gulir teks panjang → temukan evidence → kembali ke selector → lompat navigasi dalam halaman dan kontrol jawaban yang mudah dijangkau | Mobile tab ada dan mode baca/ukuran teks ada. Pilihan `panel` dibaca dari URL tetapi perubahan tab tidak menulisnya kembali: tautan tidak mewakili panel aktif. |
| Melapor; report/contact | Isi form → consent → submit → status ID atau satu error generik → pertahankan draft + error spesifik + nomor laporan | Sukses lokal terkonfirmasi. Email opsional jelas. Partial-success saat isian diubah sambil request berjalan sudah ditangani di JS; pertahankan. |
| Bantuan; footer | Bantuan/Kontak/Laporan/Keamanan terpisah → pengguna menentukan saluran tanpa triase → bantuan menurut tujuan dengan eskalasi jelas | Hindari menambah portal tiket sebelum proses operasional siap. |
| Settings | Tema, bahasa, ukuran baca, gerak tersebar di header/reader/footer → gerak sulit ditemukan setelah halaman puluhan layar → kontrol yang relevan dekat konteks, akses preferensi konsisten | localStorage hanya preferensi situs; tombol tema perlu menyampaikan keadaan saat ini. |
| Login, registrasi, dashboard, chat AI, pembayaran | Tidak diimplementasikan di website ini → tidak dapat diuji end-to-end dari source ini | Tandai sebagai boundary aplikasi eksternal, bukan fitur website rusak. Diperlukan source/test environment aplikasi untuk audit lanjutan. |

### Loading, empty, error, success

- Halaman statis tidak membutuhkan spinner buatan; rendering HTML langsung adalah perilaku yang tepat.
- Search sinkron memberi jumlah hasil dan empty state; jangan menambah debounce/spinner tanpa kebutuhan pada 28 item. Perbaiki jenis hasil dan label lebih dulu.
- Report: sending/disabled, sukses ID, retry, draft download, dan partial success tersedia. Error field/server belum dipetakan ke kontrol terkait; rate limit tidak memberi waktu retry.
- Coming soon dan preparing sudah dibedakan; jangan menampilkan metadata rilis seolah aktif.
- Q001: “Belum diperiksa” adalah state data yang valid, tetapi jangan dibungkus copy yang menyiratkan validasi selesai.
- Tidak ada skeleton/loading chat karena tidak ada chat live di situs. Jangan menambah simulasi chat yang menyerupai respons AI aktual.

## F. Security dan privacy audit

Tidak ditemukan secret frontend, login bypass, SQL injection, command injection, atau XSS yang terkonfirmasi pada jalur website yang dibaca. Markdown melakukan escaping; SQL memakai parameter; URL eksternal dibatasi HTTPS; endpoint hanya membuat laporan dan tidak menyediakan pembacaan publik. Temuan negatif ini terbatas pada source yang tersedia.

| Severity | Location | Vulnerability / gap dan attack scenario | Impact | Fix |
| --- | --- | --- | --- | --- |
| Medium, conditional | [server/app.py:22](</Users/apple/Downloads/openturath-website 6/server/app.py:22>), [server/wsgi.py:11](</Users/apple/Downloads/openturath-website 6/server/wsgi.py:11>), unit systemd | Limiter 8/300 detik hanya di memori proses. Penyerang memakai banyak IP atau mendapat budget baru setelah restart/multi-worker. Header Origin bukan autentikasi bagi klien non-browser. Konfigurasi contoh satu worker mengurangi, tetapi tidak menghapus risiko. | Spam laporan, pertumbuhan penyimpanan, menutup kanal bantuan. Tidak diuji dengan flood. | Batas di reverse proxy/service sesuai volume, batas global/body/storage, limiter bersama bila scale-out; tetap hindari CAPTCHA otomatis untuk semua pengguna. |
| Medium, operational | [server/storage.py:36](</Users/apple/Downloads/openturath-website 6/server/storage.py:36>), [docs/OPERATIONS.md](</Users/apple/Downloads/openturath-website 6/docs/OPERATIONS.md>), `deploy/openturath-reports.service` | Retensi hanya purge saat startup/request atau perintah manual. Dokumen meminta jadwal harian, tetapi tidak ada timer/cron artefak yang dapat diverifikasi. Laporan dapat tersimpan melewati 30 hari ketika layanan sepi dan jadwal belum dipasang. | Ketidaksesuaian janji privasi; eksposur lebih lama jika host/backup diakses tanpa izin. | Sertakan scheduler, bukti last-run dan alert kegagalan; atur lifecycle backup/ekspor terpisah. DELETE bukan penghapusan forensik semua media. |
| Medium, operational | [server/wsgi.py:26](</Users/apple/Downloads/openturath-website 6/server/wsgi.py:26>), [server/app.py:70](</Users/apple/Downloads/openturath-website 6/server/app.py:70>), `app.py:44` | Error ditangkap menjadi `storage_unavailable`; preview mematikan log. API tidak mencatat kategori kegagalan server. Gangguan disk/permission atau abuse berulang dapat tak terlihat dari log aplikasi. Infrastruktur mungkin punya monitoring, tetapi belum dibuktikan. | Kanal laporan gagal tanpa diagnosis cepat. | Log kode/kategori error dan request ID tanpa isi pesan/email; metrik 5xx/429 dan pemeriksaan kesehatan. Jangan mengaktifkan body logging. |
| Low, conditional | [scripts/package.py:8](</Users/apple/Downloads/openturath-website 6/scripts/package.py:8>), [server/manage.py:16](</Users/apple/Downloads/openturath-website 6/server/manage.py:16>) | Packaging memasukkan file umum di docs/server selama bukan nama/sufiks yang dikecualikan. Ekspor `docs/reports.json` tidak akan dikenali sebagai data pribadi. Dokumentasi memang melarang lokasi tersebut. | Kebocoran email/pesan jika operator salah menyimpan ekspor lalu membagikan ZIP. Tidak ditemukan ekspor riil yang bocor pada pemeriksaan ini. | Pisahkan direktori privat di luar proyek secara default; manifest aset publik/allowlist rilis; pre-package pemeriksaan data pribadi yang tidak mencetak isinya. |
| Low, verification gap | [scripts/download-integrity.mjs](</Users/apple/Downloads/openturath-website 6/scripts/download-integrity.mjs>), `/download/` | Hash dan ukuran membuktikan kesesuaian bytes dengan config, bukan identitas penanda tangan APK. Jika bytes+config diganti bersama dalam supply chain, gate ini tidak membuktikan publisher. | Distribusi binary yang salah bisa tetap lolos pemeriksaan checksum. Tidak ada bukti APK berbahaya. | Verifikasi signing certificate/version/minSdk pada pipeline distribusi dan rekam fingerprint tepercaya; jangan jalankan APK untuk sekadar inspeksi metadata. |

### Boundary yang belum dapat dinilai

- Session expiration, logout, token storage, IDOR, entitlement, webhook DOKU, refund execution, Google/Firebase authorization: tidak diimplementasikan dalam repo website.
- AI prompt injection, tool abuse, system-prompt exposure, RAG poisoning, akses sumber lintas pengguna: tidak ada pemanggilan model atau executor tool di repo ini. Arsip Q001 dirender sebagai teks. Risiko aplikasi NotebookLM tidak dapat disimpulkan dari disclaimer website.
- Origin checking dan tanpa CORS permissive adalah proteksi request browser, bukan cara menghentikan seluruh spam internet. Endpoint publik tanpa login bukan dengan sendirinya authorization bypass.
- localStorage yang ditemukan menyimpan tema, bahasa, gerak, dan ukuran baca; tidak ditemukan token sesi website.
- Konfigurasi Nginx membatasi root ke `dist/`, API route khusus, security headers, dan dotfile denial. Keberadaan config contoh tidak membuktikan header/TLS produksi sudah aktif.
- Operator harus membuktikan jadwal retensi, akses backup, penanganan laporan, dan identitas publisher sebelum menyatakan siap produksi. Ini kebutuhan bukti implementasi, bukan kesimpulan kepatuhan hukum.

## G. Accessibility audit

| ID / priority | Issue yang ditemukan | Bukti dan rekomendasi |
| --- | --- | --- |
| A11Y-01 High | Dialog tanpa accessible name | [src/render.mjs:24](</Users/apple/Downloads/openturath-website 6/src/render.mjs:24>), [src/pages.mjs:13](</Users/apple/Downloads/openturath-website 6/src/pages.mjs:13>): `language-dialog`, `menu-dialog`, `source-dialog` tidak punya `aria-labelledby`/`aria-label`. DOM runtime menunjukkan dialog tanpa nama walaupun ada heading anak. Hubungkan heading ID; beri judul menu yang jelas. Uji announce, Escape, trap, dan restore focus. Referensi: [W3C dialog pattern](https://www.w3.org/WAI/ARIA/apg/patterns/dialog-modal/). |
| A11Y-02 High | Batas input light mode terlalu lemah | Form runtime: fill `#f5f5f7`, border `#d8d8dd`, background putih. Border terhadap putih sekitar 1,42:1; fill sekitar 1,09:1. Untuk batas yang diperlukan mengenali kontrol, ini di bawah 3:1. Gunakan token border kontrol tersendiri dan periksa state disabled/focus/dark. Jangan menerapkan 3:1 pada semua garis dekoratif. [WCAG 1.4.11](https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast). |
| A11Y-03 Medium | Bahasa bagian Arab di jawaban belum ditandai | [src/pages.mjs:22](</Users/apple/Downloads/openturath-website 6/src/pages.mjs:22>), [src/core.mjs:27](</Users/apple/Downloads/openturath-website 6/src/core.mjs:27>): seluruh jawaban `lang=id`; markdown membuat `dir=auto`, tetapi tidak menambahkan `lang=ar` pada paragraf/kutipan Arab. Arah visual tidak menentukan bahasa suara. Tambahkan markup bahasa pada rendering tanpa mengubah arsip mentah. |
| A11Y-04 Medium | Label tema tidak memberitahu state | [src/render.mjs:21](</Users/apple/Downloads/openturath-website 6/src/render.mjs:21>), `site.js:13`: “Ubah tema” tetap sama; tombol tidak menyampaikan tema aktif/tujuan. Gunakan nama “Gunakan tema gelap/terang” atau state yang sesuai. |
| A11Y-05 Medium | Daftar isi mobile hilang | `site.css:9` mengatur `.article-toc{display:none}`; aturan `immersive.css:1711` mengubah posisi tetapi tidak memulihkan display. Runtime privacy 390 px: `none`. Ini hambatan navigasi artikel panjang, bukan klaim otomatis pelanggaran WCAG. Gunakan details “Isi halaman” yang bisa dioperasikan keyboard. |
| A11Y-06 Medium | Nama link kartu terlalu panjang | Seluruh deskripsi/status/metadata berada di anchor `collectionCard`, [src/render.mjs:12](</Users/apple/Downloads/openturath-website 6/src/render.mjs:12>). AX memuat satu nama link sangat panjang. Jadikan judul sebagai label link dan pertahankan informasi kartu tetap bisa dibaca berurutan. |
| A11Y-07 Low | Region tabel selalu “Table” | [src/core.mjs:33](</Users/apple/Downloads/openturath-website 6/src/core.mjs:33>): label region scroll tabel hardcoded EN pada seluruh locale. Lokalkan dan beri konteks bila lebih dari satu tabel. |

Fokus terlihat, skip link, native form label, native details, dan `bdi` untuk angka sudah tersedia. Kontras teks utama tidak boleh disamakan dengan kontras border input: hitam/abu teks pada latar utama terlihat memadai, tetapi audit ini tidak mengesahkan semua pasangan warna/states.

RTL tambahan: tombol `.button` berisi panah hero tidak termasuk selector mirror normal, sementara `.text-link` dan kartu tercakup (`site.css:3`). Pada screenshot AR panah CTA masih ke kanan. Seragamkan arah panah navigasi tanpa membalik ikon download. Serial/counter memakai digit Latin sementara metadata memakai Arab-Indic; pilih konvensi dan isolasi token Latin. Hasil pencarian memakai `${n} ${t.results}` tanpa plural rules Arab (`site.js:18`).

Tes axe bawaan hanya mencakup beranda/access/report dengan dialog tertutup dan WCAG sampai 2.1. Bahkan bila lolos, itu belum memeriksa dialog terbuka, kontras semua state, 2.2, screen reader, atau kualitas RTL.

## H. Design system audit

### Inventory aktual

| Bagian | Saat ini | Evaluasi |
| --- | --- | --- |
| Warna light | paper `#fff`, surface `#f5f5f7`, ink `#111`, muted `#65656b`, line `#d8d8dd`, hover `#ededf0` | Basis netral konsisten; border dekorasi dan border kontrol perlu dibedakan. |
| Warna dark | paper `#08090a`, surface `#151517`, ink `#f5f5f7`, muted `#b0b0b7`, line `#343439` | Arah obsidian sesuai karakter; jangan membuat semua kartu featured gelap tanpa arti. |
| Primary/secondary | Tombol solid ink / tombol outline | Sudah terbaca berbeda. Hierarki keseluruhan melemah karena CTA dan angka besar berulang. |
| Success/warning/error | Belum ada token semantic status khusus; feedback laporan berupa teks | Status perlu ikon/teks dan semantic role bila relevan, bukan wajib menambah warna cerah. |
| Display/headings | Newsreader Latin, Scheherazade New Arab; H1 inner 44–76 px; display hero lebih besar | Pertahankan serif editorial; batasi ukuran display pada beranda. |
| Body/caption | Outfit Latin, Scheherazade New Arab; body/detail sekitar 16–18 px, metadata 11–15 px | Arab membutuhkan skala dan line-height sendiri; hindari label Arab terlalu kecil mengikuti Latin. |
| Spacing | 112 px section desktop; banyak 24/26/28/35/38/40/48/64/70/80 dan override | Variasi tidak semuanya salah; belum ada skala semantik yang menjelaskan pemakaian. |
| Radius | token 28 px, tombol 999 px, variasi 8/23/25/26 px dan lainnya | Bahasa bentuk terpecah antara dokumen, kartu, banner. Tentukan kategori, bukan menyamakan semuanya. |
| Shadow/motion | hover button shadow, spotlight kartu, hero pointer parallax, archive rotate, banner/adab translate, reveal, animasi FAQ | Fungsi feedback hover/FAQ dapat dipertahankan; gerak dokumen/harga tidak membantu keputusan. |
| Icons | Inline SVG kustom kecil | Tidak perlu mengganti library. Pastikan arah/label mengikuti fungsi dan RTL. |
| Komponen reusable | layout, pageHead, button/link, collectionCard, faqBlock, membership, metadata, article | Dasar komponen ada. Search markup diduplikasi dan scope berbeda; dialogs belum satu kontrak semantik. |
| Komponen lainnya | Input native, select native, modal native, tabs arsip, status availability, notice, nav/header/footer, article sidebar, table markdown | Tidak perlu dropdown kustom atau dashboard baru. Kartu bukan unit default untuk setiap paragraf. |

### Sistem yang disarankan

- Warna tetap monokrom hangat/netral sesuai identitas. Tambah peran `border-subtle`, `border-control`, `text-muted`, `focus`, `status-error`; tentukan pasangan light/dark yang diuji. Jangan mengganti seluruh palet.
- Skala spacing dasar: **4, 8, 12, 16, 24, 32, 48, 64, 96**. Petakan ke xs/sm/md/lg/xl/2xl sesuai fungsi; pengecualian hanya bila ada alasan komposisi.
- Tiga tingkat radius: kontrol kecil, panel fungsional, banner editorial. Nilai awal 8/16/24 px adalah usulan preferensi, bukan angka yang secara objektif benar. Pill untuk filter boleh; tidak semua CTA harus pill.
- Body Latin 16–18 px, line-height 1,6–1,8; Arab sekitar 20–22 px, 1,8–2 sesuai font dan harakat. Metadata harus tetap terbaca pada mobile. Nilai ini perlu diuji dengan konten nyata.
- Kartu katalog: judul → cakupan singkat → status → jumlah kitab ringkas. Jumlah kata/halaman/masa dipindah ke detail. Kartu hitam hanya jika memiliki makna produk yang bisa dijelaskan, bukan variasi visual acak.
- Modal bersama memiliki title ID, label, close, initial focus, restore focus, dan overflow behavior. Search bersama menerima scope/jenis hasil. Hindari framework migration untuk memperbaiki ini.

### Audit widget statistik dan hierarki

Tidak ada dashboard akun. Modul statistik beranda adalah objek relevan untuk penilaian ini.

| Widget | Keputusan yang dibantu | Tindakan |
| --- | --- | --- |
| 20 bidang | Memastikan bidang pengguna tercakup | Pertahankan, dekat navigasi bidang. |
| 5.370 kitab | Memahami skala korpus | Ringkas; jelaskan agregasi modul, jangan menyebut unik tanpa deduplikasi bibliografi. |
| 11.901+ jilid | Memberi konteks ukuran | Sekunder pada rincian metadata. |
| 4.182.803 halaman | Tidak langsung membantu memilih bidang | Tertiary; jangan lebih dominan daripada contoh sumber. |
| 1.148.410.539 kata | Hampir tidak membantu keputusan pengguna biasa | Turunkan ke halaman metodologi/data. Tidak membuktikan kualitas jawaban. |
| 2.876 partisi | Detail implementasi NotebookLM, bukan tujuan pengguna | Keluarkan dari alur pemasaran utama; tetap boleh di dokumentasi teknis. |

`collectionTotals()` menjumlahkan metadata per modul. Tidak ada deduplikasi berbasis identitas kitab lintas modul, sehingga tidak boleh menyimpulkan jumlah judul unik dari angka agregat. Ini batas interpretasi data, bukan bukti bahwa angka saat ini palsu.

## I. Technical debt dan performance

### Must Fix

1. **Parity komersial sebagai gerbang produk.** `releaseIssues()` memeriksa kelengkapan nilai, tetapi tidak memblokir `pending-backend-mapping`. Build produksi real-config lulus. Tambahkan readiness check yang memisahkan “artefak valid” dari “penawaran siap dipublikasikan”. Kriteria selesai: SKU/cakupan/durasi sama dengan transaksi sandbox yang disahkan.
2. **Label CTA dan scope pencarian.** `membership()` menentukan URL fallback tetapi copy tidak mengikuti fallback. Search global di `site.js:17` ikut mengambil kitab contoh pada library. Kriteria selesai: destination dan label sesuai; jumlah per jenis hasil stabil sebelum/sesudah JS.
3. **Accessible name dialog dan border kontrol.** Perbaikan lokal dengan dampak langsung; jangan menunggu redesign.
4. **Kebenaran claim sumber.** Pisahkan status kutipan dari slogan verifikasi. Kriteria selesai: cuplikan memperlihatkan status; sumber yang disebut verified mempunyai edisi, teks pembanding, penelaah, tanggal, dan tautan yang dapat diuji.

### Should Fix

- **Template multi-tanggung jawab.** [src/pages.mjs](</Users/apple/Downloads/openturath-website 6/src/pages.mjs>) hanya 53 baris tetapi banyak baris berisi seluruh halaman. Panjang baris menyulitkan review escaping, label, kondisi dan diff. Pecah berdasarkan halaman/komponen yang memang berubah bersama, tanpa mengganti arsitektur static generation.
- **Dua stylesheet bertumpuk.** `site.css` 34.946 B dan `immersive.css` 43.410 B. Bug TOC menunjukkan aturan lama dapat tetap menang meskipun override terlihat lengkap. Konsolidasikan bertahap dengan pemeriksaan computed styles dan visual regression; jangan hapus selektor berdasarkan pencarian teks saja.
- **Sumber fakta berulang.** Email/jam layanan/retensi, harga/FAQ dan policyVersion sebagian tertulis ulang di copy/articles/config. Mengubah operator config tidak otomatis memperbarui paragraf artikel. Jadikan fakta operasional data terstruktur dan kalimat tetap dilokalkan.
- **Observability, retensi, packaging** seperti bagian F. Tambahkan bukti operasi dan rollback yang benar-benar dipraktikkan; dokumentasi saja tidak cukup.
- **Build report stale.** [scripts/build.mjs:36](</Users/apple/Downloads/openturath-website 6/scripts/build.mjs:36>) mengeluarkan warning “APK artifact not supplied; website-only mode …” hanya berdasarkan parity pending. Real config memiliki APK 62.682.302 B aktif. Turunkan warning dari kondisi aktual; jangan gunakan report lama sebagai bukti tidak ada APK.
- **Tes cenderung mengunci tampilan/copy.** `browser-qa.mjs` memeriksa hero tepat dua baris dan presence angka. Tambahkan tes yang menangkap scope pencarian, label→destination, dialog terbuka, API error mapping, dan readiness penawaran. Dua baris hero bukan kriteria utama keberhasilan produk.
- **Preview readiness.** README mensyaratkan Python 3.10+, lingkungan shell audit menggunakan 3.9 dan tes tetap lulus; bukan bukti 3.9 didukung. Dokumentasikan dan pin runtime deployment yang benar serta dependensi Gunicorn; tidak ada dependency manifest Python yang dikunci.

### Nice to Have

- Membersihkan aset font legacy Inter/Cormorant/Amiri dan gambar lama setelah analisis pemakaian. Font lama sekitar 1 MB di distribusi, tetapi **tidak otomatis berarti semuanya diunduh browser** karena `fonts.css` aktif memakai font lain.
- Menghapus fungsi `study()`/wiring experience-tab yang tidak punya pemanggil/markup aktif setelah konfirmasi. Jangan mengganti abstraksi sehat demi preferensi clean code.
- Format otomatis dan lint minimal untuk readability. TypeScript tidak wajib untuk skala ini.
- Lokalisasi singular/plural, label region tabel, dan metadata campuran ID/Latin.

### Performance berbasis bukti

| Bukti | Implikasi | Tindakan |
| --- | --- | --- |
| HTML beranda ID sekitar 65,9 KB; Q001 sekitar 169,8 KB sebelum kompresi | Q001 menyematkan enam template jawaban sekaligus; sebagian besar tidak terlihat bersamaan. Ini biaya transfer/parsing, bukan hydration. | Pertahankan fallback no-JS, ukur dulu di perangkat lambat sebelum memutuskan pemuatan terpisah. |
| site.js 11,6 KB + motion 8,0 KB + ui.mjs 59,0 KB + core 5,5 KB, semua raw | Seluruh copy tiga bahasa/FAQ dan fungsi core build ikut tersedia di client pada setiap halaman. Ukuran masih moderat; bukan bundle framework raksasa. | Emit subset UI per bahasa dan load motion hanya ketika diperlukan jika pengukuran mendukung. |
| Hero WebP sekitar 176 KiB, dimensi dan high fetch priority ada | Optimasi dasar tersedia. Hero bukan masalah multi-megabyte. | Pertimbangkan srcset mobile; jangan lazy-load kandidat LCP. |
| Scroll/pointer membaca geometry beberapa blok dan menulis custom properties | Potensi biaya rendering dekoratif, terutama dengan 21 kartu dan halaman panjang. Tidak ada pengukuran CPU/LCP/INP lapangan. | Hapus gerak tak fungsional dahulu, profil pada Android kelas menengah sebelum klaim percepatan. |
| Nginx contoh tidak menetapkan kebijakan compression/cache khusus aset | Infrastruktur live mungkin menambahkannya; belum bisa dianggap aktif. | Version/hash aset sebelum cache immutable; HTML revalidation, kompresi teks, uji invalidasi rilis. |
| Search max 28 item lokal | Kompleksitas kecil; normalisasi ulang bukan bottleneck yang terbukti | Jangan menambah state library, API pencarian, atau debounce hanya untuk terlihat canggih. |
| DB purge pada tiap laporan; limiter membersihkan map tiap request | Potensi biaya pada beban abuse, belum terbukti bottleneck normal | Ukur latency/volume dan batasi ingress; indeks created_at/scheduler hanya jika volume membenarkan. |

Tidak ada React/Vue, hydration, SSR per request, client router, atau query database untuk setiap halaman. Menuduh unnecessary component rerenders pada proyek ini akan salah sasaran. Sasaran performa yang paling terlihat saat ini adalah **waktu pengguna menemukan tindakan**, bukan optimasi mikro rendering.

## J. Benchmark prinsip

- **Zotero:** membedakan koleksi, item, dan informasi bibliografi. Prinsip yang relevan adalah struktur berdasarkan tugas mengelola sumber, bukan mengadopsi tampilan tiga panelnya mentah-mentah. Ini mendukung pemisahan profil asisten dan kitab contoh pada hasil OpenTurath. [Dokumentasi dasar Zotero](https://www.zotero.org/support/quick_start_guide).
- **NotebookLM:** tautan sitasi membawa pembaca ke bagian relevan sumber. Prinsip yang relevan adalah pendeknya perjalanan klaim → kutipan → konteks. OpenTurath sebaiknya menerapkan prinsip itu hanya ketika sumbernya memang tersedia, bukan mensimulasikan “terverifikasi”. [Penjelasan resmi Google](https://blog.google/innovation-and-ai/products/notebooklm-beginner-tips/).
- **W3C/APG:** nama dialog, focus management, label, dan kontras kontrol adalah standar interaksi, bukan branding. [Dialog modal](https://www.w3.org/WAI/ARIA/apg/patterns/dialog-modal/) dan [kontras nonteks](https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast).

Benchmark ini berbasis dokumentasi primer, bukan pengujian akun/live seluruh produk pesaing. Card bento, angka display besar, spotlight, glass header, dan hover lift adalah pilihan/tren visual; tidak menjadi standar kualitas. Serif/kaligrafi/adab adalah pilihan identitas yang layak dipertahankan bila mendukung pembacaan.

## K. Prioritas implementasi

### Phase 1 — Critical: kebenaran penawaran, fungsi, aksesibilitas, trust

Nama fase mengikuti brief; tidak berarti ditemukan kerentanan Critical.

| Urutan | Problem → change | Expected impact / acceptance |
| --- | --- | --- |
| 1 | Parity pending → sahkan SKU, entitlement, durasi dan copy bersama aplikasi; tahan promosi berbayar sampai selesai | Tidak ada penawaran berbeda antara website dan checkout yang disahkan. |
| 2 | Klaim verifikasi → sesuaikan hero/preview dan tampilkan status bukti dekat kutipan | Pengguna tidak menyamakan koordinat bibliografi dengan verifikasi selesai. |
| 3 | Label CTA dan search salah ekspektasi → sesuaikan label destination dan jenis hasil | “Buka aplikasi” tidak menuju download; query yang sama punya scope yang jelas; counter tidak berubah makna setelah JS. |
| 4 | Dialog tanpa nama + input low contrast → perbaikan semantik/token kontrol | Uji dialog terbuka dengan keyboard/screen reader; pasangan kontrol memenuhi kriteria yang relevan. |
| 5 | Retensi/operasi belum dibuktikan → timer, logging aman, monitoring API | Bukti purge/alert tersedia; laporan tidak hilang diam-diam. |

### Phase 2 — High impact: usability, clarity, professionalism

1. Ringkas katalog menjadi pilihan bidang yang bisa dipindai; pindahkan statistik rinci ke detail. Ukur keberhasilan menemukan bidang, bukan jumlah animasi.
2. Jadikan Android satu tindakan utama pada download, dengan panduan pemasangan yang benar-benar operasional.
3. Tempatkan satu contoh dengan sumber/edisi yang lengkap sebelum blok angka besar. Jika bukti belum ada, gunakan status belum diperiksa dengan jelas.
4. Perbaiki navigasi Q001: lompat ke kutipan, status, metodologi; pulihkan daftar isi mobile; pertahankan kontrol baca.
5. Definisikan khadim/koleksi/kitab dan batas NotebookLM sebelum pembelian. Satukan fakta komersial dan kontak.
6. Triase contact/report serta pesan API 422/429/503/timeout. Uji draft tidak hilang.

### Phase 3 — Polish

- Rapikan skala typography/spacing/radius, ejaan, plural Arab, panah RTL, dan metadata tanggal/angka.
- Hilangkan parallax harga/kutipan dan spotlight jika tidak membantu feedback; pertahankan gerak singkat untuk perubahan state yang nyata.
- Konsolidasikan CSS dan hapus aset legacy dengan bukti pemakaian; jangan massive rewrite.
- Ukur LCP/INP/CLS serta transfer di jaringan/perangkat representatif. Jangan menyatakan perbaikan performance hanya dari berkurangnya baris kode.

## L. Final design direction

**Arah: perpustakaan kajian yang tenang, dengan bukti dekat dengan klaim.** Bukan dashboard AI dan bukan pameran statistik.

- **Visual personality:** editorial, teliti, dekat dengan kitab. Logo dan aksara Arab tetap punya karakter. Gambar kitab cukup satu aksen; contoh sumber nyata menjadi pusat kredibilitas.
- **Typography:** serif untuk judul utama, sans untuk navigasi/control; aksara Arab disetel berdasarkan harakat, panjang judul, dan konteks mixed-script. Heading operasional memakai kata tugas, bukan semua berupa slogan dua baris.
- **Color:** monokrom tetap; kontras dipakai untuk primary action dan teks, bukan menonjolkan kartu secara arbitrer. Status selalu dijelaskan dengan teks.
- **Spacing:** beranda boleh lebih lapang; katalog, unduhan, dan bantuan lebih padat. Pada mobile, pengguna sebaiknya dapat membandingkan beberapa pilihan tanpa setiap kartu menghabiskan satu layar—target yang perlu diuji, bukan kontrak pixel mutlak.
- **Components:** pertahankan header, native details/select/dialog, reader tools, dan kartu bibliografi yang bermakna. Sederhanakan kartu katalog dan blok statistik. Hilangkan wrapper/dekorasi yang hanya menambah tinggi.
- **Motion:** animasikan perubahan state seperlunya. Teks sumber, harga, dan konten panjang tidak perlu bergerak mengikuti scroll. Respect reduced motion tetap wajib; kontrol tidak tersembunyi di ujung puluhan layar.
- **Copy:** singkat, faktual, dan beradab. Sebut siapa melakukan verifikasi, apa yang belum tersedia, apa yang dibeli, dan langkah setelah klik. Jangan mengganti ketidakpastian dengan retorika.
- **UX:** setiap halaman memiliki satu tugas utama dan langkah berikutnya yang dapat diprediksi. Perlakukan pembacaan, verifikasi, dan pemilihan bidang sebagai tugas berbeda. Website harus jujur tentang batasnya terhadap aplikasi.

## M. Rencana verifikasi setelah perbaikan

Belum ada perubahan kode dalam audit ini, sehingga tidak ada klaim “regression-free”. Saat implementasi dilakukan:

1. Jalankan tests/check dan production build di lingkungan yang terdokumentasi; lint/typecheck hanya bila toolchain-nya ditambahkan secara sengaja.
2. Uji search scope, counter, clear, empty, perubahan bahasa, dan query Arab/Latin.
3. Uji CTA sampai destination yang benar, termasuk fallback tanpa deep link dan platform belum tersedia.
4. Uji form sukses, 422, 429, 503, timeout, submit ganda, edit saat request berjalan, dan download draft. Gunakan DB sementara.
5. Audit keyboard, dialog terbuka, focus return, screen reader ID/AR, 200–400% zoom, reduced motion, touch targets, dark mode, tabel sempit, dan article TOC.
6. Verifikasi 320/390/768/1440/1920 px pada keluarga halaman, bukan hanya beranda. Periksa console/network serta clipping internal, bukan sekadar `scrollWidth` root.
7. Uji checkout sandbox, entitlement, expiry, webhook idempotency, dan account deletion pada repositori aplikasi terpisah sebelum menyatakan flow produk lengkap.
8. Jalankan pemeriksaan jadwal purge, restore backup, log aman, penanda tangan APK, rollback rilis, dan header deployment nyata.

**Batas keputusan akhir:** source website cukup untuk mengonfirmasi masalah UX/copy/semantik di atas. Ia belum cukup untuk menyatakan aplikasi aman, seluruh kutipan benar, izin semua sumber sah, atau pembayaran produksi konsisten. Pekerjaan berikutnya adalah menyelesaikan bukti dan hambatan tugas tersebut sebelum memperindah tampilannya.
