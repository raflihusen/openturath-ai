# Audit OpenTurath AI — 7 Oktober 2026

## Kesimpulan

OpenTurath sudah memiliki identitas visual yang kuat: tenang, monokrom, bertumpu pada naskah Arab, dengan serif editorial yang membedakannya dari aplikasi AI umum. Masalah utama bukan kekurangan rounded corner. Masalahnya adalah terlalu banyak permukaan yang sama kuat, navigasi dan aksi yang kurang jelas, pembacaan jawaban campuran Arab–Indonesia yang rusak, serta data bibliografis yang terlihat lebih pasti daripada bukti yang tersedia.

Arah yang disarankan: ambil kejelasan hierarki, containment, permukaan tonal, bentuk lembut, dan navigasi adaptif dari Material 3 Expressive. Pertahankan karakter ilmiah OpenTurath. Dahulukan integritas pembacaan dan sumber sebelum pemolesan bentuk.

## Ruang lingkup dan batas bukti

- Delapan screenshot pengguna: langganan, pengaturan, detail kitab, daftar kitab, ringkasan pustaka, pilihan asisten fikih, beranda, dan percakapan.
- Pembacaan kode lokal Flutter, renderer native dan WebView, katalog Maliki, layanan pembayaran, telemetry, penyimpanan catatan, serta harness pengujian.
- Analisis statis, seluruh tes Flutter, tes backend yang tersedia, dan render visual opt-in.
- Arah desain berupa HTML terpisah; tidak ada perubahan kode produksi, harga, data katalog, atau deployment.
- Tidak melakukan transaksi, penghapusan akun, pengujian eksploitasi layanan produksi, atau login Google. Tidak mengklaim autentikasi embedded, pembayaran live, atau akurasi isi jawaban telah tervalidasi.
- Identitas pengguna pada screenshot tidak disalin ke contoh desain atau laporan.

Status temuan: **Terbukti** = terlihat pada screenshot/kode/hasil pemeriksaan; **Risiko** = mekanisme yang perlu pengujian runtime; **Usulan** = keputusan produk/desain yang perlu ditinjau. P1 = integritas pengalaman inti atau kepercayaan; P2 = friksi berarti; P3 = pemolesan. Tidak ada P0 yang ditetapkan tanpa bukti kehilangan data, eksploitasi, atau kegagalan produksi.

## Hasil verifikasi saat audit

| Pemeriksaan | Hasil | Batas interpretasi |
|---|---|---|
| Flutter analyze --no-pub | Exit 0; no issues found | Tidak membuktikan alur live atau kualitas visual |
| Flutter test --no-pub | Exit 0; 345 lulus, 1 dilewati | Render visual default hanya placeholder opt-in |
| Node backend tests | Exit 1; 51 lulus, 1 kelompok gagal | webview_script.test.ts membaca file yang sudah tidak ada |
| Render layar opt-in | Exit 0; 45 PNG dihasilkan; tidak ditemukan RENDER ERROR/RENDER NOTE pada log | Harness belum menjadikan setiap galat render sebagai kegagalan tes |
| Pemeriksaan visual baru | dashboard_phone, profile_dark, subscription_ar_new, library_book_detail | Empat sampel diperiksa, bukan klaim semua 45 sudah direview manual |
| Log render | Empat pesan MissingPluginException dari package_info/update check | Lingkungan widget test tidak menyediakan plugin; bukan bukti update live rusak |
| Pratinjau HTML | Desktop 1280×900, ponsel 390×844, chat campuran, filter jilid, pencarian kosong diperiksa | Contoh desain; belum menguji implementasi Flutter |

Log audit tersedia di `/tmp/openturath-audit-20261007-{tests,functions,render}.log`. Render di `/tmp/openturath-audit-20261007-shots/`. Berkas `/tmp` bersifat sementara.

## Prioritas utama dengan bukti dan cara membuktikan perbaikan

| ID / prioritas | Temuan dan status | Bukti | Rekomendasi / kriteria penerimaan |
|---|---|---|---|
| D01 / P1 | Paragraf Indonesia menjadi RTL karena mengandung satu fragmen Arab. Terbukti mekanisme dan gejalanya. | Screenshot chat; `lib/widgets/agent_multi_tab_room.dart:884` menetapkan dir=rtl pada p/li/div yang mengandung Arab | Tentukan arah dasar per paragraf; isolasi fragmen lawan arah. Uji kalimat Indonesia + istilah Arab + nama Latin + angka + tanda kurung; bandingkan tampilan dan hasil salin. Jangan membalik atau menulis ulang isi jawaban. |
| D02 / P1 | Renderer native mempunyai heuristik serupa; seluruh pesan beralih dari Markdown jika ada Arab. | `lib/widgets/native_turath_chat_view.dart:333`, `:426` | Gunakan renderer blok terstruktur; pertahankan Markdown, pilihan teks, link, kutipan, dan sumber. Ini risiko jalur prototype, bukan bukti native adalah jalur screenshot. Flag prototype default off di `agent_multi_tab_room.dart:41`. |
| D03 / P1 | Field nama muhaqqiq berisi penilaian edisi “طبعة أصلية معتمدة”. | Screenshot detail; `assets/data/12_KATALOG_FIKIH_MALIKI.json:7`; detail memakai `book.editor` tanpa membedakan tipe metadata di `book_library_editorial_screen.dart:659` | Pisahkan nama editor, catatan edisi, status verifikasi, dan provenance. Jika nama tidak tercatat, katakan demikian. Jangan menampilkan klaim “terverifikasi” tanpa penelaahan. |
| D04 / P1 | Tahun cetakan “2003 هـ” perlu adjudikasi. Terbukti data, belum terbukti tahun pengganti. | Screenshot detail; katalog Maliki `:9` | Simpan nilai mentah, cek halaman judul/kolofon edisi, tambahkan koreksi berjejak bukti. Jangan langsung mengubah هـ menjadi م. |
| D05 / P1 | 52.244 halaman untuk التبصرة للخمي adalah outlier yang perlu diperiksa. | Screenshot grid; katalog Maliki `:162` | Validasi apakah angka halaman, karakter, atau salah input. Cocokkan agregat setelah perbaikan. Angka yang benar belum ditetapkan audit ini. |
| D06 / P1 | Tes WebView tidak lagi mencapai kode aktif. Terbukti gagal. | `functions/test/webview_script.test.ts:7` membaca `lib/screens/agent_webview_screen.dart`; log ENOENT | Arahkan harness pada sumber aktif; pastikan uji host guard, font scaling, selector keselamatan, dan mixed-direction benar-benar dijalankan. Jangan menonaktifkan tes demi status hijau. |
| D07 / P1 | Galat render dapat dicetak lalu tes tetap berakhir lulus. | `test/visual/render_screens_test.dart:130` | Assert setiap exception dan gagalkan langkah dialog yang tidak terbuka. Tambahkan perbandingan golden yang dikurasi; tangkapan PNG saja bukan detektor perubahan visual. |
| D08 / P1 | Katalog rusak/gagal dibaca menjadi daftar kosong; sulit dibedakan dari “tidak ada kitab”. | `lib/services/open_turath_catalog_repository.dart:140`, `:190` | Bedakan loading, empty, data-unavailable, dan parse-error; log versi aset serta konteks aman. Uji JSON invalid, asset hilang, dan recovery. |
| D09 / P1 | Sanitizer mengklaim email disamarkan, tetapi tidak memiliki masker email umum untuk error/breadcrumb/extra. | `lib/services/telemetry_service.dart:97`; maskEmail hanya diterapkan pada field userEmail, `:177` | Redaksi email di seluruh jalur payload, whitelist konteks, hindari isi prompt/jawaban dan cookie. Uji bentuk nyata serta nested metadata tanpa memakai rahasia produksi. Ini gap kode, bukan klaim kebocoran sudah terjadi. |
| D10 / P1 | Rules memungkinkan create log tanpa auth; dedup 120 detik hanya di klien. | `firestore.rules:59`; `telemetry_service.dart:167` | Audit App Check/ingestion, pembatasan server, ukuran nilai nested, retention, dan biaya. Tidak melakukan abuse test pada produksi; konfigurasi runtime belum diverifikasi. |
| D11 / P2 | Selector WebView luas dan scrollbar disembunyikan global. | `lib/core/notebook_ui_script.dart:295`, `:320`; selector welcome/menu tersebar | Batasi lingkup stylesheet dan versi adapter, deteksi DOM drift, fallback yang dapat dipulihkan. Kembalikan indikasi scroll desktop; audit jangan sampai dialog penting atau sumber terhapus. |
| D12 / P2 | Galat pembayaran ditampilkan tetapi exception umum tidak diteruskan ke telemetry di catch ini. | `lib/screens/subscription_screen.dart:163` | Rekam kode galat, tahap checkout, correlation ID aman; tampilkan recovery sesuai kasus. Hindari data kartu/token dan detail internal di UI. |
| D13 / P2 | Nama dan versi build dalam render widget tidak sama dengan build screenshot. | Screenshot versi 1.0.63+64; render profile memakai fallback 1.0.9, pubspec 1.0.63+64 | Mock package info yang sesuai pada render; verifikasi versi di binary asli. Jangan menafsirkan fallback test sebagai downgrade pengguna. |
| D14 / P2 | “verificationNotice” tersedia di kamus tetapi tidak ditemukan pemakaian di layar lewat pencarian kode. | `lib/core/copy_catalog.dart:283` | Letakkan keterangan pendek dekat metadata edisi dan sediakan provenance rinci; kalimat di kamus tidak berarti pengguna sudah melihatnya. |

## Audit delapan layar

### 1. Langganan

Yang sudah baik: harga besar, pilihan 1/6/12 bulan, CTA jelas, penjelasan tidak diperpanjang otomatis, dan manfaat yang konkret. Kode checkout juga memeriksa amount serta pricingRevision sebelum membuka pembayaran (`subscription_screen.dart:137`); ini pengaman yang perlu dipertahankan.

Masalah: harga muncul di selector dan ringkasan sehingga informasi berulang; kartu pertama sangat panjang pada jendela pengguna; pilihan paket tunggal berada jauh di bawah fold. Daftar lima nama asisten tidak menjelaskan tugasnya. Harga coret dan “Hemat 70%” membutuhkan dasar komersial, bukan hanya rumus hitung. Profil “tanpa batas” belum memberi konteks mengapa pengguna masih perlu membeli.

Usulan: ringkasan paket ringkas, durasi sebagai segmented control, satu total utama, detail manfaat yang dapat dibuka. Untuk 6/12 bulan tampilkan “Rp 1.499.000 untuk 6 bulan” sebagai total dan “≈ Rp 250.000/bulan” sebagai ekuivalen. Penekanan harga bulanan tidak boleh menyerupai penagihan cicilan. Saat checkout tampilkan cakupan, durasi, total, mulai akses, dan status pembayaran. Sediakan “Lihat transaksi” untuk pembayaran tertunda. Desktop cukup lebar dapat membandingkan dua paket berdampingan; ponsel satu kolom. Jangan menambah label “paling populer” tanpa data.

Uji lanjutan: klik ganda; retry setelah timeout; pembayaran berhasil saat aplikasi ditutup; webhook duplikat/tertunda; invoice kedaluwarsa; harga berubah; paket aktif; akses kadaluwarsa; redeem; perbedaan hak akses lima subasisten. Tes lokal bukan pembuktian settlement live.

### 2. Pengaturan

Yang sudah baik: tema, bahasa, paket, dan tindakan akun dikelompokkan. Kontrol tema berbentuk segmented sudah dekat dengan arah Google.

Masalah: kartu identitas memakai kode yang menyerupai nomor kartu, badge PRO, serta “TANPA BATAS”. Ketiganya menarik perhatian lebih kuat daripada status akses yang dibutuhkan. Nama semua kapital dan email pada ruang terbatas rawan desakan. “Akses semua asisten” dan “Siap digunakan” tidak menjelaskan asal/masa hak akses. “Hapus akun” tampak seperti baris biasa dan dapat disangka disabled.

Usulan: kartu akun ringkas berisi nama, paket, cakupan, dan masa akses. Tampilkan kode keanggotaan hanya jika ada penggunaan nyata. Gunakan “Tanpa batas waktu” hanya bila entitlement memang demikian; pisahkan dari batas penggunaan. Kelompok “Preferensi”, “Akses & pembayaran”, “Bantuan”, dan “Akun”. Tindakan hapus diberi label/warna semantik dan dialog dengan akibat serta kebutuhan login ulang. Konfirmasi hapus memang sudah ada di `profile_screen.dart:109`; masalah screenshot adalah penemuan dan hierarki, bukan ketiadaan konfirmasi.

### 3. Detail kitab

Yang sudah baik: judul Arab dominan dan identitas edisi tersedia. Pemisah baris lebih masuk akal daripada satu kartu per metadata.

Masalah: metadata numerik sejajar satu baris, metadata Arab turun ke baris baru sehingga label dan nilainya terpisah jauh. Kartu kategori besar padahal hanya berisi satu nilai. Ikon salin/simpan tidak menjelaskan apa yang disalin/disimpan. Data muhaqqiq dan tahun bermasalah seperti D03/D04. Tidak terlihat lokasi sumber katalog atau tanggal review.

Usulan: header judul/pengarang + chip bidang; tabel label–nilai yang sejajar di desktop dan bertumpuk rapat di mobile. Tambahkan “Salin identitas edisi” dan “Simpan rujukan”; feedback menjelaskan objek. Tampilkan metadata kosong dengan “Belum tercatat” bila penting bagi kutipan. Sediakan sumber katalog, edisi, nomor jilid/halaman asli, dan status pemeriksaan. Jika produk hanya menyediakan katalog, jangan memberi affordance seolah teks kitab dapat dibaca penuh.

### 4. Daftar kitab Maliki

Yang sudah baik: pencarian menonjol, judul/pengarang Arab terbaca, filter sederhana. Normalisasi Arab dan tes pencarian sudah tersedia; temuan lama tentang pencarian tidak boleh dianggap masih terbuka tanpa bukti baru.

Masalah: grid tiga kolom berisi teks panjang; setiap entri setinggi kartu besar, judul dua baris membuat author/metadata terasa tidak konsisten. Border yang lebih gelap pada satu kartu bisa bermakna hover, focus, atau selected; screenshot tidak dapat menentukan state. Filter satu/multi jilid membantu sedikit, sedangkan pengarang, urutan, dan edisi belum tampak. 52.244 halaman menjadi angka mencolok tanpa status pemeriksaan.

Usulan: default daftar editorial ringkas, opsi grid untuk browsing. Setiap baris: judul Arab, pengarang, metadata ringkas, aksi jelas. Sort A–Z Arab/pengarang/jumlah jilid bila datanya valid; filter pengarang/penerbit sebagai progressive disclosure. Pertahankan query, filter, posisi scroll, dan focus ketika kembali dari detail. Hasil normal cukup “86 kitab”; pencarian “12 dari 86 kitab”. Uji composed/decomposed hamzah, harakat, tatweel, paste, pencarian kosong, dan hasil panjang.

### 5. Ringkasan pustaka

Yang sudah baik: scope Maliki jelas dan ada catatan bahwa angka mengikuti katalog.

Masalah: satu layar perantara hanya menyajikan statistik lalu satu tombol menuju daftar. Pengguna melewati pilihan bidang → asisten → overview → daftar → detail untuk tujuan sederhana. Area bawah kosong bukan kesalahan sendiri; persoalannya layar belum memberi keputusan baru. Jumlah kata besar tidak menjelaskan kesiapan korpus dan bisa dianggap jaminan cakupan AI.

Usulan: jadikan statistik header di halaman katalog; detail metodologi angka dibuka saat diperlukan. Bedakan entri katalog, teks yang tersedia, teks yang terhubung pada asisten, dan edisi yang ditelaah. Angka 48,4 juta kata tidak membuktikan seluruh teks digunakan menjawab.

### 6. Pilihan asisten Fikih & Fatwa

Yang sudah baik: mazhab mudah dibandingkan dan akses pustaka berdekatan.

Masalah: judul dan statistik merupakan isi utama, sementara kegunaan asisten tidak dijelaskan. “Mulai telaah” dan “Pustaka” dua tujuan, tetapi Pustaka tampak seperti teks metadata. Seluruh kartu membuka asisten sedangkan TextButton di dalam membuka katalog (`assistant_grid_card.dart:65`, `:137`); ini perlu kejelasan focus dan hit target.

Usulan: satu kalimat per tugas, misalnya “Telaah pembahasan fikih dalam rujukan mazhab Maliki.” Aksi eksplisit “Buka asisten” dan “Lihat rujukan”. Statistik di tingkat ketiga hierarki. Tambahkan status akses yang benar ketika memengaruhi aksi; jangan semua kartu diberi badge. Sediakan riwayat atau favorit agar penggunaan rutin tidak selalu mengulang katalog.

### 7. Beranda

Yang sudah baik: lanjutkan sesi, flagship, pencarian, dan bidang membentuk fondasi navigasi yang masuk akal.

Masalah: tanggal Hijriah menjadi judul terbesar, mendahului tujuan kajian. Resume gelap sangat dominan, flagship putih menyainginya, lalu semua bidang memakai kartu dengan bobot sama. Pada render ponsel 390×844, pencarian baru muncul setelah dua panel besar; pengguna baru harus melewati banyak materi sebelum memilih bidang. Kartu “Adab menggunakan AI” terpotong saat memulai dengan nasihat kesantunan, sementara kemampuan memeriksa jawaban lebih penting pada titik ini.

Usulan: greeting/tujuan utama sebagai heading sans; tanggal sebagai informasi sekunder, tetap menghormati kalender Hijriah. Pencarian lebih awal. Satu fokus primer: melanjutkan sesi untuk pengguna kembali, memilih kajian untuk pengguna baru. Ringkas resume dengan topik dan waktu terakhir. Bidang tidak harus seluruhnya berbentuk bento besar. Panduan utama “Periksa rujukan jawaban” dengan tautan koreksi yang membantu.

Tanggal Hijriah tidak diverifikasi astronomis pada audit ini. Jika aplikasi memakai konversi perhitungan, sebutkan metodenya dalam bantuan dan uji timezone/pergantian hari.

### 8. Ruang percakapan

Ini prioritas tertinggi. Screenshot memperlihatkan paragraf panjang dengan titik, tanda kurung, istilah Arab, dan urutan nama yang berpindah. Gaya heading Arab juga mendominasi jawaban berbahasa Indonesia. Sumber terlihat sebagai teks di bagian bawah, sehingga pembaca sulit menelusuri pernyataan ke kutipan spesifik. Composer sangat pucat dan scroll indicator menutup bagian sumber; state disabled/ready/loading belum jelas dari gambar.

Usulan: lebar baca Latin sekitar 60–75 karakter sebagai sasaran desain, judul bagian sesuai bahasa jawaban, ringkasan pendek, paragraf pendek, blok Arab terpisah, kutipan inline hanya untuk fragmen yang diperlukan. Arah dan font ditentukan per blok/fragmen, bukan satu Regex untuk seluruh jawaban. Sumber dekat klaim dan dapat dibuka untuk melihat edisi/lokasi/kutipan. Composer memiliki permukaan dan focus yang terbaca, tombol kirim/berhenti berbeda, status loading faktual. Tampilkan retry tanpa menggandakan pertanyaan. Auto-scroll hanya jika pengguna dekat dasar; jawaban baru tidak mencuri posisi saat sedang membaca sumber.

Isi jawaban seperti “kebahagiaan palsu”, perbandingan aliran filsafat, atau atribut kepada pengarang harus diperiksa terhadap sumber. Audit screenshot ini tidak menetapkan benar/salah isi teologis. Pisahkan kutipan langsung, terjemahan, penjelasan asisten, dan kesimpulan; jangan membuat formatting rapi seolah-olah sudah membuktikan atribusi.

## Arah desain yang disarankan

Google menekankan warna, bentuk, ukuran, gerak, dan containment untuk menonjolkan aksi dan mengelompokkan informasi. Penerapan OpenTurath dapat tetap monokrom dengan hubungan tonal yang jelas. Ini adaptasi desain, bukan kewajiban meniru seluruh gaya Google.

| Elemen | Arah usulan | Alasan |
|---|---|---|
| Canvas | Netral lembut; surface putih/gelap bertingkat | Mengurangi kebutuhan border di semua kartu |
| Shape | Kartu sekitar 20–24; hero/sheet 28–32; kontrol utama pill | Bentuk dibedakan menurut fungsi; bukan semua 32px |
| Tipografi | Sans untuk judul navigasi dan pengaturan; Newsreader untuk judul koleksi; Scheherazade untuk teks kitab; Noto untuk UI Arab | Judul antarmuka tidak bersaing dengan konten ilmiah |
| Ukuran | Body ID sekitar 16–18 logical px; Arab ditinjau optis sekitar 20–24; label 12–14 | Sasaran prototipe, harus diuji pada font, scaling, dan perangkat asli |
| Spacing | Pertahankan skala 4/8; padding kartu 20–24, gap 12–16, jarak seksi 28–32 | Ringkas tanpa memadatkan teks Arab |
| Outline | Simpan pada kontrol dan batas penting; grup memakai tonal surface | Hindari kesan formulir panjang dan card soup |
| Shadow | Hanya untuk elemen benar-benar mengambang | Hindari composer kabur dan kartu berbayang semua |
| Nav | Label jelas; bottom nav compact, rail medium, sidebar expanded | Pengguna baru tidak harus menghafal ikon |
| Motion | 180–280 ms untuk respons kecil; reduced motion; tidak menari di area teks | Memberi feedback tanpa mengganggu kajian |
| Status | Kata + ikon + warna semantik bila perlu | Monokrom tidak boleh menyamarkan galat atau aksi permanen |

Angka radius/ukuran ini merupakan proposal revisi, bukan token produksi baru. Jika diterapkan nanti, ubah `lib/core/design/`, `DESIGN.md`, guard tes, dan sumber design system terpadu bersama. Jangan menambah nilai ad hoc di setiap layar.

Layout menyesuaikan ruang jendela, bukan sekadar nama perangkat. Acuan Google: compact <600dp, medium 600–839dp, expanded mulai 840dp, dengan kelas large dan extra-large. Terjemahkan ke logical pixel Flutter berdasarkan komponen dan kebutuhan produk; jangan menyalin angka tanpa menguji. Shell saat ini memakai 768/1100 (`main_shell_screen.dart:146`); itu bukan bug otomatis, tetapi perlu konsistensi dengan grid, dialog, dan panel lain. Uji 320/390/600/768/840/1100/1280, tinggi pendek, split screen, RTL, serta text scaling.

Pratinjau `design-preview.html` memperlihatkan tiga ide: beranda dengan pencarian awal, ruang baca dua panel, dan katalog berbentuk daftar. Font diambil dari aset lokal. Seluruh contoh chat diberi label tata letak; tidak ada kutipan ilmiah rekaan. Beberapa tombol hanya menunjukkan pola; pratinjau bukan fitur AI/backend, dan bukan desain final seluruh delapan layar.

## Penilaian visual heuristik

Angka ini penilaian auditor untuk membantu prioritas, bukan hasil riset usability atau sertifikasi. Tidak dirata-rata menjadi skor produk.

| Dimensi | Nilai / status | Bukti dan fokus perbaikan |
|---|---|---|
| Konsistensi warna | 8/10 | Monokrom koheren; bedakan surface dan status; `lib/core/design/ot_colors.dart` |
| Hierarki tipografi | 6/10 | Serif untuk hampir semua judul, date sangat dominan, bidi bermasalah; `dashboard_screen.dart`, D01 |
| Ritme jarak | 7/10 | Grid cukup teratur; row metadata Arab dan whitespace perlu dirapikan; `book_library_editorial_screen.dart:731` |
| Konsistensi komponen | 7/10 | Segmented/chip/button cukup stabil; CTA katalog ambigu; `assistant_grid_card.dart:137` |
| Responsiveness | 6/10 sementara | Render ponsel tidak menunjukkan overflow pada sampel tetapi pencarian terlalu bawah; `render_screens_test.dart:235` |
| Dark mode | 7/10 sementara | Profile gelap terbaca; belum menilai semua WebView dan state live; `profile_screen.dart` |
| Gerak | Belum diberi skor | Screenshot tidak membuktikan motion; perlu real device + reduced motion |
| Aksesibilitas | Belum diberi skor penuh | Label nav, focus, pembesaran teks, dan screen reader perlu pengujian; `main_shell_screen.dart:169` |
| Kepadatan informasi | 6/10 | Katalog teks terlalu tinggi, overview berulang, hero mobile panjang |
| Polish dan states | 5/10 sementara | Perbedaan fallback test, galat katalog disamarkan, indikator chat; D07/D08/D13 |

## Copywriting: penggantian yang membantu keputusan

| Saat ini | Usulan | Catatan |
|---|---|---|
| Sesi terakhir Anda masih terbuka. | Lanjutkan kajian bersama Al-Muhaqqiq. | Tambahkan topik dan waktu terakhir jika benar-benar tersedia |
| Mulai telaah | Buka asisten | Tujuan aksi lebih jelas pada katalog asisten |
| Pustaka | Lihat rujukan | Hindari disangka label metadata |
| Telusuri koleksi kitab | Lihat 86 kitab | Angka harus berasal dari data yang sedang ditampilkan |
| Menampilkan 86 dari 86 kitab | 86 kitab | “x dari y” dipakai saat query/filter aktif |
| Ajukan pertanyaan atau buat konten | Ajukan pertanyaan tentang naskah atau konsep… | Mode penulisan konten bisa punya prompt sendiri |
| Siap digunakan | Akses aktif | Sertakan cakupan/masa akses yang benar |
| TANPA BATAS | Tanpa batas waktu | Jangan disamakan dengan penggunaan tanpa limit |
| Harga perdana | Harga perdana · pembayaran sekali untuk masa akses yang dipilih | Versi ringkas di layar; detail di ringkasan checkout |
| Adab menggunakan AI | Memeriksa jawaban dan rujukan | Kesantunan tetap dapat hadir di panduan, tidak mendahului keandalan |
| Muhaqqiq: طبعة أصلية معتمدة | Nama muhaqqiq belum tercatat | Hanya ketika provenance memang tidak menyediakan nama; simpan catatan edisi terpisah |
| Error umum | Tidak dapat memuat rujukan. Coba lagi. | Sertakan retry dan ID bantuan aman jika relevan |

Peran lima asisten perlu dijelaskan dari kemampuan yang benar-benar tersedia, bukan hanya diterjemahkan dari nama: tugas utama, contoh permintaan, format hasil, sumber yang dipakai, dan batasnya. Pilih istilah “asisten”, “bidang”, “koleksi”, “ruang kajian”, “kitab”, “rujukan”, dan “catatan” dengan makna tetap di semua bahasa. Native loading copy masih hardcoded Indonesia (`native_turath_chat_view.dart:470`); uji ID/EN/AR di seluruh state.

## Blind spot tambahan yang perlu pengujian khusus

1. **Aksesibilitas:** VoiceOver/TalkBack reading order Arab–Latin, semantic label ikon, selected state filter, focus ring, escape/back, keyboard traversal, 200% text scaling, kontras actual compositing, serta target sentuh. Sasaran kontrol mobile 48 logical px; WCAG minimum web 24 CSS px mempunyai pengecualian, bukan pembenaran ikon terlalu kecil.
2. **Catatan dan bookmark:** editor sekarang memiliki flush saat close dan antrean draft; jangan mengulang temuan lama sebagai bug aktif. Tetap uji force-kill sebelum debounce, disk gagal, logout/account switch, offline/resume, konflik dua perangkat, simpan berulang, sumber tetap terbawa, export panjang, dan clipboard mixed direction.
3. **Entitlement:** status tidak boleh stale setelah pembayaran, expiry, redeem, revoke, atau pergantian akun; UI harus menjelaskan akses per bidang/subasisten. “PRO” bukan sumber kebenaran hak akses.
4. **Keandalan layanan:** timeout, 401, 403, 429, 500, koneksi putus saat streaming, gagal login Google, session expiry, serta recovery yang mempertahankan pertanyaan pengguna. Jangan menjelaskan semua kasus sebagai “coba lagi”.
5. **DOM pihak ketiga:** selector NotebookLM mudah berubah. Uji pada halaman terautentikasi yang nyata; fixture dan widget tests tidak membuktikan assistant live berhasil. Hindari aturan global yang merusak sources, dialog login, atau menu.
6. **Kualitas scholarly:** sumber mendukung klaim yang terkait, edisi/jilid/halaman akurat, terjemahan diberi label, sintesis dibedakan dari kutipan, dan jawaban abstain ketika sumber tidak cukup. Bentuk UI bukan bukti RAG benar.
7. **Statistik:** sumber angka, metode hitung, tanggal pembaruan, duplikasi kitab lintas koleksi, jumlah jilid tidak pasti, angka “+”, dan jumlah kata harus dibedakan. Total katalog bukan coverage indeks atau availability teks.
8. **Performance:** cold start, decode katalog besar, filter saat mengetik, scroll dengan judul panjang, frame time, ukuran font, battery, serta tiga WebView paralel. `agent_session_manager.dart:74` maxTabs=3 tetapi komentar menyebut tujuh: dokumentasi sudah drift. Belum ada profiling yang membuktikan masalah memori.
9. **Debugging:** event lifecycle terstruktur, versi app/build/adapter/schema, correlation ID, request outcome, dan “tahap terakhir berhasil”. Snapshot DOM yang disimpan harus dibatasi dan disanitasi. Jangan merekam prompt/isi kitab/cookie secara default.
10. **Privasi dan akun:** jejak data yang dibersihkan saat logout/delete, recent-login recovery, retention remote, sinkronisasi milik akun, dan state browser session. Backend trigger cleanup harus diuji terpisah dari pesan sukses frontend.
11. **Release:** parity version manifest/binary, signing/notarization, update link, rollout serta rollback. Tidak dibangun APK/macOS baru dalam audit ini. Build lokal tidak boleh memicu upload atau broadcast.
12. **Riset pengguna:** uji tugas nyata dengan pemula dan peneliti Arab: memilih asisten, menemukan kitab, memeriksa kutipan, melanjutkan sesi, menyimpan catatan, memahami paket. Ukur waktu, salah klik, keberhasilan, dan keyakinan; jangan menjadikan skor heuristik ini sebagai riset pengguna.

## Urutan pengerjaan yang paling bernilai

1. **Integritas baca dan bukti:** D01–D05, skema metadata, sumber serta clipboard. Selesai bila mixed-direction tetap benar di chat, catatan, salin, dan layar sempit; bibliografi terkoreksi berdasarkan bukti.
2. **Kepercayaan pengujian/debug:** D06–D10, failure states, redaksi, harness fail-on-error, serta jalur WebView aktif. Selesai bila gate tidak dapat hijau pada galat render dan coverage aktif tidak membaca path usang.
3. **Art direction untuk ditinjau:** beranda, chat, katalog/detail sebagai layar representatif. Tinjau desktop, ponsel, dark, Arab sebelum redesign massal; preview audit menjadi bahan diskusi.
4. **Komponen dan copy:** token bentuk/surface/huruf, shell, CTA, search/filter, loading/empty/error, dialog. Sinkronkan kode + DESIGN.md + design system terpadu.
5. **Alur end-to-end terkontrol:** login/session, entitlement, sandbox checkout, notes sync, delete test account, performance dan screen reader. Hindari transaksi produksi sebagai tes pertama.
6. **Review final:** screenshot asli semua state, regresi teknis, daftar gap dan rollback. Release tetap tindakan terpisah dengan instruksi pengguna.

Setiap perubahan nanti dicommit langsung per kelompok kecil sesuai AGENTS.md. Audit ini hanya menambahkan artefak laporan/pratinjau; perubahan/deletions lama di working tree tidak disentuh.

## Referensi yang dibaca

- [Google Design — Material 3 Expressive research](https://design.google/library/expressive-material-design-google-research): penggunaan shape, size, motion, color, containment untuk hierarki dan kegunaan. Rekomendasi monokrom adalah adaptasi OpenTurath.
- [Android Developers — Window size classes](https://developer.android.com/develop/ui/compose/layouts/adaptive/use-window-size-classes): keputusan layout mengikuti ruang jendela dan berubah saat resize.
- [W3C — Inline markup and bidirectional text](https://www.w3.org/International/articles/inline-bidi-markup/index): arah dasar serta isolasi fragmen lawan arah. Untuk WebView pakai markup; untuk Flutter pilih representasi spans/blocks yang sesuai dan uji output.
- [W3C — Target size minimum](https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html): minimum dan pengecualian target kontrol web; tidak sama dengan sasaran 48 logical px mobile.

Riwayat desain dipakai untuk menemukan token dan test yang sudah ada; semua temuan aktif di atas diperiksa ulang pada kode atau gambar saat audit ini. Audit tidak menggunakan angka hasil tes lama sebagai hasil terkini.
