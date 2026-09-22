# Audit produk dan kode OpenTurath

Tanggal: 22 September 2026 • Baseline: `5b98e92` • Versi sumber: `1.0.51+52`.

Audit tanpa perubahan kode aplikasi, deploy, broadcast versi, transaksi pembayaran, atau pengujian eksploitasi terhadap layanan produksi. Skill yang digunakan: [ecc:production-audit](/Users/apple/.codex/plugins/cache/ecc/ecc/2.0.0-rc.1/skills/production-audit/SKILL.md). Kategori risiko mengikuti permintaan pengguna, tanpa skor numerik.

## Dasar bukti dan batas pemeriksaan

- **Kode:** aplikasi aktif `openturath_ai/lib`, rules Firebase, Cloud Functions TypeScript, website `openturath_ai/public`, layanan Python `ecosystem/openturath_subscription`, konfigurasi dan workflow rilis. Salinan audit/ZIP, proyek kamus terpisah, dan file untracked lama bukan baseline aplikasi aktif.
- **Visual aktual:** website lokal dari checkout ini, di browser pada 360×800, 768×1024, dan 1440×900; screenshot desktop dan mobile diperiksa. Halaman download juga diperiksa pada 360×800.
- **Visual historis:** `app_screenshot_beranda.jpg` dan `app_screenshot_tahawwulat.jpg`, bertanggal file 16 September. Keduanya bukan bukti tampilan build 1.0.51. Warna emas pada screenshot Tahawwulat tidak otomatis dianggap masih ada pada semua halaman sekarang.
- **Validasi:** 166 tes Flutter lulus; TypeScript `tsc --noEmit` lulus; 40 dari 41 tes backend/script lulus; analyzer menghasilkan dua informasi lint. Rincian dan keterbatasannya ada di akhir laporan.
- **Belum dibuktikan:** rendering aplikasi Android terbaru, TalkBack/VoiceOver, keyboard seluruh aplikasi, pembayaran sungguhan, konfigurasi IAM Cloud Run, rules yang terpasang di produksi, hak akses notebook aktual, pencabutan akses lintas akun, memori/FPS perangkat, dan ketepatan ilmiah seluruh corpus. Perangkat yang ditemukan hanya macOS dan Chrome; tidak ada perangkat Android terhubung.
- Istilah **terbukti** berarti terlihat pada kode atau pengukuran lokal. **Risiko** berarti jalur kegagalan didukung kode tetapi dampaknya masih memerlukan kondisi tertentu. **Penilaian desain** bukan bug objektif. Label “AI slop” menilai pola produk, bukan membuktikan siapa/apa yang menulis kode.

## A. Executive summary

1. **Tunda perluasan rilis publik sampai batas keamanan layanan pendukung diperbaiki.** Ada token bot Telegram literal di file yang dilacak Git; handler `/telegram`, `/cron/reap`, dan `/keepalive` tidak memverifikasi identitas pengirim di aplikasinya. IAM produksi belum diperiksa, sehingga keterjangkauan publik bersifat kondisional, tetapi kelemahan kode nyata.
2. **Janji utama—jawaban yang bisa ditelusuri kembali—belum utuh.** Jawaban tersimpan sebagai teks, `bookReference` dan `pageNumber` dikosongkan, sedangkan halaman pemasaran menjanjikan rujukan fisik untuk setiap penelusuran. Ini lebih merusak kredibilitas daripada radius atau shadow.
3. **Logout belum menutup seluruh konteks kajian.** Singleton tab WebView tidak direset ketika keluar/ganti akun; `closeAll()` tersedia tetapi tidak dipanggil dari kode aplikasi. Pembersihan cookie/cache tidak sama dengan menghancurkan halaman dan konteks yang masih hidup.
4. **Sinkronisasi catatan memiliki celah rekonsiliasi.** Edit/hapus lokal yang lebih baru hanya dikirim saat tindakan awal; sinkronisasi berikutnya tidak mengirim ulang versi baru jika ID sudah ada di cloud. Bila push awal gagal, perangkat lain bisa tetap melihat versi lama.
5. **Kesan generik muncul dari keputusan produk yang saling bertentangan.** Beranda/katalog memakai editorial turats, Catatan beralih ke palet biru dan Inter, dan langganan kembali ke kartu premium, badge “Eksklusif”, serta “Super AI”. Menghapus semua karakter turats justru salah arah.
6. **Alur pertama terlalu menuntut sebelum nilai produk terlihat.** Login Google aplikasi dilanjutkan login sesi Google WebView; pengguna kemudian memilih bidang/paket. Kebutuhan dua sesi perlu dijelaskan pada saat relevan, bukan dijadikan teka-teki onboarding.
7. **Pencarian tidak sesuai label.** Beranda menawarkan pencarian “marja', topik, atau ibarah”, tetapi implementasinya memfilter metadata asisten. Pencarian teks kitab bukan hasil yang diberikan kontrol tersebut.
8. **Accessibility memiliki masalah konkret:** warna label navigasi light mode hanya sekitar 3,13:1 terhadap surface putih; tombol hapus pencarian berukuran ikon 18 tanpa target memadai; kartu GestureDetector tidak menyediakan aktivasi keyboard; orientasi dipaksa portrait.
9. **Website dan aplikasi belum menceritakan produk yang sama.** Website menyebut enam bidang pada hero namun 19 bidang pada harga; versi unduh masih 1.0.21, sementara sumber 1.0.51. CTA unduh nyata terpotong pada 360 piksel.
10. **Perubahan terbesar:** amankan akses, pastikan catatan/sesi tidak salah akun, kemudian rapikan alur *pilih bidang → bertanya → periksa sumber → simpan*. Setelah itu satukan token visual dan ringkas bahasa. Tidak perlu massive rewrite.

## Peta arsitektur dan permukaan produk

| Area | Implementasi yang ditemukan | Implikasi audit |
|---|---|---|
| Framework | Flutter/Dart, Material, Firebase; Android utama, folder target desktop/iOS/web tersedia | Keberadaan folder platform bukan bukti fiturnya sudah valid di platform itu |
| Routing | `main.dart:onGenerateRoute`, named routes, `PageRouteBuilder`; shell `PageView` empat tab; route lokal tambahan lewat `MaterialPageRoute` | Navigasi tidak sepenuhnya terpusat; route lama agent dialihkan ke shell |
| State | `StatefulWidget/setState`, singleton `AgentSessionManager` dan `BookmarkService`, `ChangeNotifier`, `ValueNotifier`, stream Firebase | Riverpod tercantum sebagai dependency, tetapi pemakaian provider tidak ditemukan di `lib` |
| Data | Firebase Auth/Firestore/Functions; katalog JSON lokal; SharedPreferences untuk catatan/preferensi/cache; dua model katalog | Perlu membedakan data metadata, jawaban AI, dan naskah asli |
| AI | URL notebook diperoleh lewat callable ber-entitlement, dibuka di WebView; JavaScript/CSS memodifikasi DOM layanan pihak ketiga | Rendering, login dan ekstraksi jawaban bergantung struktur DOM eksternal |
| Auth/access | Google Sign-In + Firebase; sesi cookie Google WebView terpisah; entitlement server; rules pemilik UID | Ada kontrol akses server yang nyata, tetapi lifecycle sesi lokal belum terpadu |
| Pembayaran | DOKU checkout, signature webhook, nominal server, transaksi atomik dan provisioning outbox; GoAkal sync/webhook; Python provisioning | Keberhasilan bayar dan keberhasilan akses notebook adalah dua tahap berbeda |
| Styling | `AppTheme`, `OTColors/OTTypography`, `NativeColors/NativeType/NativeTypography`, `ScholarlyFonts`, GoogleFonts langsung, CSS website | Banyak definisi tumpang tindih, sebagian nama font tidak cocok dengan font aktual |
| Komponen | `SpecialistCard`, `AppleInteractiveWrapper`, `AppLoader`, `AppErrorState`, library sheet/overview, checkout/redeem sheets, native rows, multi-tab room | Reuse ada, tetapi banyak layar membangun ulang tombol, card, spacing, dan typography |
| Halaman | Splash, login, sesi Google, shell, beranda, asisten, subscription, katalog overview/list/detail, Catatan/editor/reader, pengaturan, AI room; website/unduh/kebijakan | Matriks C membedakan jalur aktif dan jalur lama |
| Release | GitHub Actions build Windows/macOS/APK; hosting static tiga site; aturan Git checkpoints lokal | Pipeline tidak menjalankan analyzer/tests sebelum build; Flutter channel stable tidak dipin |

Lokasi utama: [main.dart](/Users/apple/Downloads/ramadhan/openturath_ai/lib/main.dart:91), [pubspec](/Users/apple/Downloads/ramadhan/openturath_ai/pubspec.yaml:1), [Firebase](/Users/apple/Downloads/ramadhan/openturath_ai/firebase.json:1), [workflow](/Users/apple/Downloads/ramadhan/.github/workflows/release_all_platforms.yml:1).

## B. AI-slop scorecard

| Dimensi | Kategori | Bukti konkret | Keputusan yang diperlukan |
|---|---|---|---|
| Visual AI slop | Medium | Beranda memakai enam card direktori setinggi 156, nomor urut, panah, dan garis dekoratif dengan panjang `32 + (index % 3) * 12`; langganan memakai badge bertumpuk, shadow dan card tier di dalam card | Card bukan kesalahan sendiri. Kurangi ornamentasi yang tidak membantu memilih bidang/paket |
| Copywriting AI slop | High | “Ibarah & Istinbath Turats”, “Perbendaharaan Catatan”, “KORPUS UTAMA · 5 BILIK AI”, serta paragraf panjang persona pada checkout | Bedakan istilah keilmuan yang dibutuhkan dari bahasa antarmuka yang harus segera dipahami |
| UX AI slop | High | Pencarian dijanjikan lebih luas dari hasil; ringkasan corpus mendahului katalog; copy jawaban vs copy percakapan memiliki efek simpan berbeda | Susun tindakan sesuai tujuan pengguna, bukan daftar fitur |
| Architecture AI slop | High | Tiga keluarga token, helper `newsreader()` yang mengembalikan NativeInter, tiga lokasi skrip notebook, singleton sesi tanpa logout reset, file backend 3.160 baris | Ini sinyal penambahan fitur tanpa kontrak bersama, bukan bukti penggunaan AI sebagai penulis |
| Marketing AI slop | High | “Pertama Di Dunia”, “dilatih dari 50+ kitab”, “Anti-Halusinasi Dalil”, janji “Setiap penelusuran” punya halaman cetak | Ganti klaim absolut dengan kemampuan terukur; tampilkan bukti corpus/edisi dan batas hasil |

Bukti: [dekorasi direktori](/Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/dashboard_screen.dart:439), [copy langganan](/Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/subscription_screen.dart:343), [klaim web](/Users/apple/Downloads/ramadhan/openturath_ai/public/index.html:108), [font native](/Users/apple/Downloads/ramadhan/openturath_ai/lib/core/design/native_fonts.dart:31).

Jika nama dan logo dihapus, tipografi Arab, metadata edisi, istilah matan/syarah dan corpus Tahawwulat masih memberi identitas. Kartu bidang berulang, sparkle navigasi, kartu “Eksklusif” dan layout premium tidak khas OpenTurath. Identitas sebaiknya dibangun melalui mutu penelusuran dan pembacaan, bukan penambahan jargon atau ornamen.

## C. Page-by-page audit

P/S/T = primary/secondary/tertiary visual priority yang disarankan. Penilaian aplikasi berasal dari kode kecuali disebut screenshot historis; masalah overflow native yang belum dirender diberi label risiko.

| Page / purpose | Problems dan dampaknya | Recommendation serta P/S/T | Priority |
|---|---|---|---|
| **Splash** — menentukan sesi awal | Selalu dark, animasi sendiri; flag `google_session_ready` persisten dijadikan routing gate meskipun bukan validasi cookie terkini. Setelah sign-in macOS gate dilewati, tetapi splash berikutnya tetap memeriksa flag. Alur awal dapat berbeda antar peluncuran | Routing dari status sesi yang eksplisit, retry sesuai kegagalan; P masuk layar tujuan, S status koneksi, T logo. [Kode](/Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/splash_screen.dart:48) | Medium |
| **Login/registrasi** — masuk dan membuat profil | Registrasi melekat pada Google login; tidak ada registrasi terpisah. Login gate ada sebelum eksplorasi aplikasi. Link legal memakai domain/path `openturath.ai/terms` dan `/privacy`, sedangkan hosting lokal berkas `.html` dan canonical `.id`; tujuan live belum diverifikasi. Tombol memakai wrapper gesture | Jelaskan Google diperlukan untuk akses kajian; pertimbangkan katalog tanpa login; uji legal URL kanonik. P “Masuk dengan Google”, S penjelasan akun, T kebijakan. [Kode](/Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/login_screen.dart:38) | High |
| **Sesi Google WebView** — menyiapkan NotebookLM | Login kedua setelah Firebase; batal menawarkan keluar akun aplikasi. Navigasi bergantung cookie dan deteksi URL; pengguna bisa memilih akun berbeda | Tampilkan email akun OpenTurath dan alasan sesi tambahan; izinkan kembali ke katalog; minta sesi NotebookLM saat pertama membuka kajian. P sambungkan akun yang sesuai, S status, T bantuan. [Kode](/Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/google_session_auth_screen.dart:27) | High |
| **Shell/navigasi** — berpindah tugas | State AI dipertahankan di overlay; tab tidak terikat UID; label nav kecil dan muted; `_selectedKind` memengaruhi key tetapi tidak diteruskan sebagai filter pada konstruksi SpecialistListScreen | Lindungi sesi per UID, semantics selected, satu kontrak filter; P empat tujuan konsisten, S sesi aktif, T tema. [Kode](/Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/main_shell_screen.dart:88) | High |
| **Beranda** — mulai/melanjutkan kajian | Search mismatch; tanggal dua kalender mengambil ruang sebelum bidang; card 156 tinggi, nomor urut/garis dekoratif tak membantu keputusan. Riwayat dicatat sebelum paywall, sehingga “lanjutkan” dapat menunjuk asisten yang belum pernah berhasil dibuka. `_loadData` menelan error | P lanjutkan sesi yang benar-benar berhasil, S cari/pilih bidang, T kalender ringkas. Simpan riwayat setelah akses berhasil. Gunakan data jumlah asisten dinamis. [Kode](/Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/dashboard_screen.dart:112) | High |
| **Asisten/bidang** — memilih spesialis | Filter, pencarian, corpus unggulan, subpersona dan jalur Pustaka bersaing. Pengguna perlu mengerti pembagian persona sebelum menyelesaikan pertanyaan. Screenshot historis menunjukkan kompleksitas ini, bukan bukti palet terkini | P pilih berdasarkan tujuan/bidang, S cakupan sumber dan akses, T penjelasan persona. Jelaskan tiap peran dalam satu kalimat kerja; jangan menghapus diferensiasi Tahawwulat. [Kode](/Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/specialist_list_screen.dart:350) | High |
| **Tahawwulat/penjelasan corpus** — memahami peran dan sumber | Card menyediakan banyak pintu masuk; introduction sheet 1.929 baris memuat materi panjang. Ini berguna sebagai bacaan opsional, berat jika harus dilalui untuk bertanya | P mulai telaah, S pilih fungsi bila memang berbeda, T baca pengantar panjang. Gunakan ringkasan dengan detail terbuka atas permintaan. [Komponen](/Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/tahawwulat_flagship_card.dart:195) | Medium |
| **AI room aktif** — bertanya, membaca, memeriksa | CSS menyembunyikan header/settings/menu yang luas; `not-found` dan unauthenticated diperlakukan seperti paywall; copy percakapan otomatis menyimpan, copy jawaban menawarkan Simpan hanya lewat snackbar 2,5 detik. Tab keempat menutup tab lain tanpa pilihan | P pertanyaan/jawaban, S sumber dan Simpan, T tampilan/tab. Bedakan login hilang, paket habis, corpus hilang dan koneksi; fallback UI asli jika adapter gagal; beri kendali saat batas tiga tab tercapai. [Kode](/Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/agent_multi_tab_room.dart:831) | High |
| **AgentWebviewScreen lama** — jalur percakapan alternatif | Berkas 1.359 baris masih berisi implementasi/script, tetapi named route diarahkan ke shell; tes script menargetkan berkas lama. Hasil tes dapat tidak mewakili jalur aktif | Audit seluruh pemanggil sebelum menghapus; uji shared adapter yang dipakai runtime aktif. [Routing](/Users/apple/Downloads/ramadhan/openturath_ai/lib/main.dart:155) | Medium |
| **Ringkasan pustaka** — memahami koleksi | Tombol Pustaka membuka overview dulu; jumlah halaman/kata menjadi lapisan tambahan sebelum daftar kitab. Catch `_handleOpenCatalog` hanya mematikan loading sehingga gagal diam-diam | Buka daftar kitab langsung; overview jadi “Tentang koleksi”; pada gagal tampilkan Coba lagi. P cari kitab, S filter/edisi, T statistik corpus. [Kode](/Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/library_metadata_overview_screen.dart:68) | High |
| **Katalog editorial aktif** — mencari kitab | Query hanya lowercase+contains; normalisasi harakat/alif yang ada di katalog canonical tidak dipakai. Teks UI Indonesia dan GoogleFonts langsung melewati Loc/ScholarlyFonts | Pakai pipeline pencarian Arab bersama, label sesuai bahasa UI; tampilkan hasil count/clear filters. P hasil, S penulis/edisi, T indeks urut. [Kode](/Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/book_library_editorial_screen.dart:61) | High |
| **BookCatalogScreen fallback** — katalog canonical | Lebih kaya metadata/normalisasi, tetapi memakai model dan detail berbeda dari editorial. Pengguna mendapat kemampuan berbeda menurut jalur masuk | Satu kontrak query, metadata dan status sumber; pertahankan model jika masih diperlukan adapter data. P daftar, S filter, T statistik. [Kode](/Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/book_catalog_screen.dart:1) | Medium |
| **LibraryScreen/ResearchLibrarySheet lama** — browsing koleksi | Tiga jalur daftar/sheet/rute menambah beban pemeliharaan; sebagian class tidak ditemukan sebagai entry utama. Jangan menganggap semuanya tampak bersamaan | Tetapkan entry aktif; hapus jalur mati hanya setelah cek pemanggil/test. [Router pustaka](/Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/library_bottom_sheet.dart:18) | Low |
| **Detail kitab editorial/canonical** — menilai dan menyimpan edisi | Dua implementasi detail; canonical memakai tooltip/error Arab bahkan locale Indonesia dan menyimpan ke dua store. `fieldId: 'fiqh'` tetap untuk bookmark canonical, termasuk buku dari bidang lain | UI mengikuti locale, judul Arab tetap RTL; satu penyimpanan referensi; field mengikuti kitab/agent. Jangan memberi kesan halaman metadata adalah pembaca teks lengkap. P judul/pengarang/edisi, S simpan/salin, T metadata lanjutan. [Kode](/Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/book_detail_screen.dart:101) | Medium |
| **Catatan** — menemukan bahan tersimpan | Keluarga NativeColors/NativeFonts berbeda dari shell; label “Perbendaharaan Catatan” berlebihan. Tidak ada status gagal sinkron yang jelas meski cloud push ditelan | P cari/buka catatan, S status tersimpan lokal/tersinkron, T klasifikasi. Perbaiki rekonsiliasi sebelum styling. [Sync](/Users/apple/Downloads/ramadhan/openturath_ai/lib/services/bookmark_service.dart:142) | High |
| **Editor/reader catatan** — menulis dan membaca | Reader punya batas 760 dan arah teks memakai Bidi, patut dipertahankan. Sumber jawaban hanya plain text; tautan citation struktural hilang. Tombol copy reader memberi toast sebelum Clipboard future selesai | P isi, S rujukan/edit/simpan, T metadata. Pertahankan RTL per blok; sediakan sumber terstruktur dan feedback clipboard setelah selesai. [Reader](/Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/note_reader_screen.dart:61) | High |
| **Langganan** — memilih cakupan/durasi | Flagship ditaruh pertama walau masuk dari spesialis lain; badge “Eksklusif”, “5 Bilik AI” dan klaim dunia/latihan mendominasi. Row tier tiga kolom dan badge non-flex berisiko sempit/text scaling | P paket bidang asal+harga total+masa berlaku, S kebutuhan akun dan cakupan, T alternatif paket. Tampilkan harga reguler hanya bila dasar promonya dapat dibuktikan. [Kode](/Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/subscription_screen.dart:304) | High |
| **Checkout/redeem** — bayar/aktifkan akses | Status paid menutup checkout sebelum notebook provisioning terbukti selesai; jeda sukses 2,2 detik hanya dekoratif. Polling berhenti setelah 60 upaya dan error background diam. Voucher device ID bermasalah | Pisahkan “Pembayaran diterima” dan “Akses sedang disiapkan”, status yang bisa dibuka lagi dan retry bantuan; redeem hasilkan tanggal/cakupan jelas. P status, S next action, T animasi. [Checkout](/Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/doku_checkout_sheet.dart:94) | High |
| **Pengaturan/profil** — mengelola akun/akses | Akun, langganan, legal, filosofi produk, tema/bahasa dan delete dalam layar 1.152 baris. Logout gagal hanya mengembalikan tombol tanpa penjelasan; session singleton tidak dibersihkan | Kelompok akun & akses / tampilan / bantuan & kebijakan; konfirmasi tetap untuk delete, logout normal cukup jelas. P pengaturan yang dipakai, S akses, T narasi produk. [Kode](/Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/profile_screen.dart:54) | High |
| **Website utama** — memahami dan mencoba | Visual desktop relatif tenang, namun halaman panjang; dua eyebrow hero redundan, klaim verifikasi lebih kuat daripada kemampuan; enam vs 19 bidang. Mobile menyembunyikan nav tanpa menu pengganti, harga jauh di bawah | P manfaat dan CTA unduh/demo, S contoh verifikasi nyata & harga, T narasi organisasi. Ringkas halaman, anchor menu mobile, label “contoh” dan tautan kutipan spesifik. [HTML](/Users/apple/Downloads/ramadhan/openturath_ai/public/index.html:94) | High |
| **Unduh** — mendapatkan rilis benar | CTA terpotong nyata; 58 MB pada download vs 60 MB pada index; versi 1.0.21 usang terhadap source. Link `OpenTurath_AI.apk` tidak ada dalam folder public lokal audit | Kaitkan copy, ukuran, checksum, versi dan URL ke satu manifest; verifikasi deployment aktual sebelum menyimpulkan 404 publik. P unduh kompatibel, S versi/integritas, T panduan. [HTML](/Users/apple/Downloads/ramadhan/openturath_ai/public/download.html:63) | High |
| **Kebijakan/legal** — mengetahui pemrosesan dan hak pengguna | Privacy web menyebut catatan lokal, tidak menjelaskan sync isi catatan ke Firestore; daftar mitra tidak menyebut jalur alert Telegram. Halaman kebijakan memang tersedia, bukan missing seluruhnya | Selaraskan fakta pemrosesan dengan implementasi, retensi dan mekanisme penghapusan; jangan menyatakan kepatuhan hukum berdasarkan audit ini. [Privacy](/Users/apple/Downloads/ramadhan/openturath_ai/public/privacy.html:133) | High |

### Dashboard: kelayakan tiap widget

| Widget | Keputusan yang dibantu | Frekuensi/nilai | Putusan |
|---|---|---|---|
| Lanjutkan telaah | Kembali ke pekerjaan terakhir | Tinggi bila sesi benar-benar pernah dibuka | Pertahankan; bedakan sesi hidup vs hanya asisten terakhir dipilih |
| Dua kalender | Mengetahui tanggal | Tidak langsung membantu penelusuran kitab pada mayoritas sesi | Turunkan menjadi metadata ringkas; jangan hilangkan nilai budaya Hijriah tanpa riset |
| Search | Menemukan bidang/asisten | Tinggi | Samakan label dengan cakupan yang nyata |
| Enam direktori bidang | Memilih disiplin | Tinggi pada awal, lebih rendah untuk pengguna rutin | Gunakan baris atau grid yang lebih padat/adaptif |
| Nomor 01–06 dan garis acak | Tidak ada keputusan eksplisit | Dekoratif | Hapus kecuali memang ada urutan kurikulum |
| Jumlah asisten | Membandingkan cakupan | Berguna jika count akurat dan menjelaskan perbedaan | Hitung dari data aktif, bukan konstanta editorial |
| Banner+dialog update | Memasang pembaruan | Sesekali | Satu pesan nonmodal untuk update biasa; jangan rebut fokus membaca |

## D. Copy audit

Audit meliputi katalog pusat 532 entri (ID/EN/AR), teks inline pada layar utama, script ruang AI, pesan backend, serta website/legal. [Inventaris katalog lengkap](/Users/apple/Downloads/ramadhan/reports/INVENTARIS_COPY_2026-09-22.csv) memuat 1.596 varian bahasa, lokasi dan triase. Inventaris bukan klaim bahwa semua terjemahan Arab/Inggris atau semua string dinamis pihak ketiga sudah diuji secara linguistik. Copy yang tidak perlu diubah tidak dipaksa menjadi temuan.

| Current Copy | Problem | Recommended Copy | Reason |
|---|---|---|---|
| Cari marja', topik, atau ibarah… | Menjanjikan pencarian teks yang tidak dijalankan beranda | Cari asisten atau bidang… | Sesuai fungsi saat ini; gunakan label lebih luas hanya setelah mesin pencarian diperluas |
| Ibarah & Istinbath Turats | Label pintu masuk abstrak, terdengar menampilkan kemampuan istinbath | Mulai menelusuri kitab | Menjelaskan pekerjaan yang bisa dilakukan |
| Perbendaharaan Catatan | Nama panjang untuk tujuan navigasi sederhana | Catatan | Konsisten dengan tab bawah |
| Buka kembali marja' dan catatan telaah sebelumnya. | Riwayat hanya ID asisten, bukan jaminan pemulihan catatan/rujukan | Buka kembali asisten terakhir. | Jangan menjanjikan state yang tidak disimpan |
| Sesi telaah siap dibuka kembali. | “Siap” bisa salah bila cookie expired | Lanjutkan percakapan terakhir. | Tidak menjamin readiness sebelum diperiksa |
| KORPUS UTAMA · 5 BILIK AI | Istilah internal dan uppercase padat | 5 asisten Fikih Tahawwulat | Objek dan cakupan jelas |
| Eksklusif | Tidak menjelaskan hak yang berbeda | Hapus, atau jelaskan cakupan khusus | Kata status tanpa manfaat bukan informasi pemilihan |
| Akses Eksklusif ke Super AI Fikih Tahawwulat yang Pertama Di Dunia | Superlatif tidak disertai pembuktian | Akses asisten Fikih Tahawwulat | Hindari klaim keunggulan yang tidak terverifikasi |
| …yang dilatih dari 50+ kitab otoritatif & ribuan jam transkrip… | Implementasi menunjukkan notebook/source, bukan bukti pelatihan model; angka belum diverifikasi | Menggunakan koleksi kitab dan transkrip kajian Fikih Tahawwulat. Lihat daftar sumber. | Benar secara mekanisme; jumlah hanya bila terhubung data tervalidasi |
| Akses 5 Persona AI spesialis (…) | Persona jargon; daftar nama panjang di benefit yang diulang | Lima asisten untuk membaca teks, memahami pembahasan, dan berlatih. | Jelaskan tugas; pastikan fungsi setiap asisten cocok sebelum diterbitkan |
| Pilih Paket Fikih Tahawwulat ({durasi}) | Mengulang heading dan membuat tombol terlalu panjang | Lanjut ke pembayaran | Paket, durasi dan total tetap tampak di dekat tombol |
| Bahasa Output Jawaban | Campuran jargon dan kapitalisasi | Bahasa jawaban | Istilah antarmuka langsung |
| Ganti Bahasa Output (50+ Bahasa) | Angka bukan kebutuhan utama, tidak dilokalkan | Ubah bahasa jawaban | Fokus pada tindakan; daftar bahasa ada di pemilih |
| Atur bahasa jawaban asisten keilmuan (mendukung 50+ bahasa). | Menjelaskan ulang tombol dengan klaim jumlah | Pilih bahasa untuk jawaban berikutnya. | Menjelaskan efek perubahan |
| Untuk membuka dan menelaah kitab bersama {asisten}, silakan aktifkan paket langganan Anda. | Dipakai juga untuk not-found/unauthenticated | Paket belum aktif. / Masuk kembali untuk melanjutkan. / Asisten belum tersedia. | Pesan dipilih berdasarkan error code, bukan substring pesan |
| Kembali ke Beranda | Tombol hanya menutup overlay; layar asal bisa Asisten/Catatan | Tutup percakapan | Menjelaskan tindakan sebenarnya |
| Simpan (snackbar 2,5 detik) | Aksi penting cepat hilang | Simpan ke Catatan, sebagai aksi menetap | Label eksplisit dan bisa ditemukan ulang |
| Anti-Halusinasi Dalil | Menyiratkan jaminan tidak salah | Periksa jawaban pada sumber | Mengarahkan perilaku tanpa klaim absolut |
| Setiap penelusuran menyajikan…nomor halaman cetak… | “Setiap” tidak dijamin model/adapter | Jika tersedia, periksa kutipan, edisi, jilid, dan halaman yang dirujuk. | Sesuaikan dengan kelengkapan data aktual |
| NASKAH TERVERIFIKASI | Tidak ada identitas pemeriksa/proses/tanggal pada contoh | Contoh kutipan dan rujukan | “Terverifikasi” hanya untuk sumber yang punya rekam verifikasi |
| Buka di Maktabah Syamilah | Menuju homepage, bukan kutipan terkait | Buka halaman rujukan — dengan link spesifik | CTA harus membawa ke objek yang dijanjikan; jika hanya homepage, tulis “Kunjungi…” |
| Khadim Turats Spesialis | Pengguna harus menerjemahkan kategori paket | Akses satu bidang | Jelaskan produk yang dibeli |
| Ruang telaah satu bidang ilmu… | “Ruang” ambigu terhadap cakupan akses | Akses asisten dan koleksi rujukan untuk satu bidang. | Sebut objek paket; pastikan rujukan memang dapat diakses |
| 1 Tahun · Pilihan Terbaik | Terbaik tergantung kebutuhan pengguna | 1 tahun — {harga efektif}/bulan | Membantu perbandingan tanpa memaksakan preferensi |
| Unduh Berkas APK (Versi 1.0.21 · 58 MB) | Panjang, usang, terpotong | Unduh untuk Android | Versi/ukuran dari manifest menjadi teks di bawah tombol |
| pengalaman muthala'ah yang hening, cepat… | Abstrak dan bercampur janji performa | Cari rujukan dan simpan catatan di Android. | Manfaat teramati |
| تمت إزالة الكتاب من الملاحظات | Pesan Arab tetap pada UI Indonesia | Referensi kitab dihapus dari Catatan. | Lokal bahasa UI, judul kitab tetap Arab |
| Gagal membuat sesi pembayaran DOKU: {err.message} | Error internal/vendor bisa bocor dan sulit dipahami | Pembayaran belum dapat dibuka. Coba lagi. | Detail teknis dicatat di server dengan ID dukungan |
| “trial” pada model vs “Pro” pada membership pass | Bisa dikira pelanggan berbayar | Uji coba aktif — berakhir {tanggal} | Pisahkan jenis akses dan masa berlaku |

Lokasi: [copy pusat](/Users/apple/Downloads/ramadhan/openturath_ai/lib/core/copy_catalog.dart:18), [inline AI](/Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/agent_multi_tab_room.dart:170), [langganan](/Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/subscription_screen.dart:373), [detail Arab](/Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/book_detail_screen.dart:65), [backend checkout](/Users/apple/Downloads/ramadhan/openturath_ai/functions/src/index.ts:658).

### Vocabulary yang disarankan

| Konsep | Gunakan | Batas makna |
|---|---|---|
| Objek percakapan | Asisten | Hindari berganti Agent, Super AI, persona dan bilik untuk objek sama |
| Klasifikasi | Bidang ilmu; label singkat “Bidang” | Bukan paket/ruang/persona |
| Aktivitas | Telaah / penelusuran | “Telaah” untuk kegiatan umum, “Cari” untuk fungsi query |
| Hasil teks asli | Kutipan kitab (ibarah) | Istilah Arab diberi pengantar sekali, lalu boleh dipakai pada konteks ilmiah |
| Sumber bibliografis | Rujukan / identitas kitab | Bedakan judul koleksi dari kutipan halaman tertentu |
| Penyimpanan | Catatan; Simpan ke Catatan | Salin hanya berarti clipboard kecuali label jelas menyebut dua tindakan |
| Pembelian | Paket; Akses aktif; Masa akses | Pembayaran diterima berbeda dari notebook siap digunakan |
| Nama disiplin | Fikih, Hadis, Usul Fikih | ID backend lama seperti `hadits` boleh tetap; jangan merusak API demi ejaan UI |
| UI multilingual | Locale mengikuti pengaturan; Arab sumber tetap Arab | RTL diterapkan pada blok Arab, bukan memaksa semua metadata Latin/angka berbalik |

“Santri”, “ibarah”, “matan”, “syarah”, “Tahawwulat” tidak perlu dihapus. Istilah khas tepat bila membawa makna, bukan hiasan otoritas. Kapitalisasi kalimat untuk CTA, tanpa uppercase panjang pada mobile. Terjemahan harus mempertahankan fungsi dan batas klaim, bukan hanya placeholder yang sama.

## E. UX flow audit

| Flow / goal | Current flow → friction → recommended flow |
|---|---|
| Onboarding/registrasi | Buka → Firebase init → Google sign-in → pembuatan profil → login Google WebView → shell. Keputusan akun terjadi dua kali; batal gate berarti keluar aplikasi. **Usulan:** penjelasan ringkas + lihat katalog → masuk saat menyimpan/membuka akses → jelaskan dan sambungkan sesi notebook saat diperlukan. Completion: asisten siap; next: pertanyaan pertama |
| Pengguna kembali | Splash membaca flag sesi → beranda → lanjutkan asisten; history bisa berasal dari klik paywall. **Usulan:** resume hanya dari sesi berhasil, tampilkan reconnect jika expired. Completion: konteks terbuka, bukan sekadar WebView putih |
| Pencarian | Search beranda berlabel ibarah → filter metadata asisten → pilih → AI. **Usulan sekarang:** label “Cari asisten atau bidang”; kemudian pencarian katalog terpisah berlabel judul/pengarang. Completion: objek yang sesuai label ditemukan; no result memberi clear query/filter |
| AI | Pilih asisten → cek cache → callable → load notebook → adapter/readiness → ketik. Cache/unauth/not-found dapat berakhir paywall. **Usulan:** state autentikasi, entitlement, provisioning, jaringan dan kesiapan terpisah; pemulihan berdasarkan sebab. Next: periksa sumber atau simpan |
| Sumber/rujukan | Pustaka → metadata overview → daftar → detail bibliografi; jawaban AI disalin sebagai teks. **Usulan:** citation → kutipan+sumber+edisi+locator → simpan kutipan dengan provenance. Pustaka langsung daftar; overview opsional. Tunjukkan “lokasi belum tersedia” bila metadata belum lengkap |
| Simpan hasil | Copy jawaban → clipboard → toast Simpan 2,5 detik; copy percakapan → otomatis simpan+clipboard. **Usulan:** dua aksi tetap “Salin” dan “Simpan ke Catatan”, masing-masing feedback dan retry sendiri. Completion: catatan lokal ada; cloud status tidak disamakan dengan lokal |
| Catatan offline | Edit/hapus → lokal sukses → cloud push unawaited → gagal ditelan → sync melihat ID sudah ada dan tidak push versi baru. **Usulan:** outbox lokal, compare revision, retry, status pending; konflik lintas perangkat diselesaikan deterministik |
| Subscription | Asisten terkunci → halaman flagship dahulu → cari paket bidang → checkout → paid → sukses. **Usulan:** paket bidang asal terpilih dan terlihat pertama → ringkasan harga/durasi/cakupan/akun → bayar → konfirmasi transaksi → status provisioning → buka asisten |
| Voucher | Masukkan kode → fingerprint klien → backend memeriksa hash+flag fisik → akses. **Usulan:** validasi eligibility server, device attestation bila diperlukan, tanggal/cakupan hasil; jangan menuduh pengguna emulator berdasarkan flag tak tepercaya |
| Pengaturan/keluar | Keluar → dialog → bersihkan cookies/preferences → Firebase signOut → login; singleton tab tetap ada. **Usulan:** reset semua konteks UID, dispose keepalive, hapus state terikat user, signOut, lalu login. Completion: tidak ada jawaban/konteks akun lama |
| Hapus akun | Konfirmasi → Firebase user.delete → trigger cleanup/revoke server. **Usulan:** pertahankan konfirmasi, jelaskan perlu login ulang bila recent-login diperlukan, tracking cleanup gagal. Jangan klaim semua data pihak ketiga terhapus hanya dari keberhasilan client |
| Download mobile | Website → download → CTA panjang terpotong; paket lokal tidak hadir pada public checkout. **Usulan:** CTA pendek, metadata rilis terpisah, kompatibilitas dan hasil download diverifikasi dari manifest |

### Loading, empty, error, success dan partial success

| Area | Yang ada | Celah yang perlu ditutup |
|---|---|---|
| Init | Firebase fallback + Retry | Retry mengulang `main`; perlu uji idempotensi bootstrap, bukan spinner dekoratif |
| Beranda | Default agent list, cached user, refresh | Kegagalan ditelan; pengguna tidak tahu access sedang tidak terverifikasi |
| AI | Loader, timeout, paywall, permission error | Error klasifikasi terlalu luas; readiness fallback berdasarkan body text bukan selalu chat siap |
| Katalog | Loading/error pada canonical | Overview catch diam; kegagalan membuka katalog perlu tindakan retry nyata |
| Catatan | Lokal cepat, empty state, editor/reader | Belum ada feedback pending/gagal sync yang dapat ditindaklanjuti |
| Checkout | Snapshot status dan polling, konfirmasi keluar | Paid ≠ provisioning complete; polling habis harus terlihat dan status dapat dibuka ulang |
| Update | Checking/downloading/ready/error | Unduhan otomatis dan modal dapat mengganggu sesi baca; hormati koneksi dan pilihan pengguna |

## F. Security dan privacy audit

Severity menilai dampak jika jalur terkait dijalankan. Tidak ada endpoint produksi yang diserang. Tidak ada nilai rahasia diulang di laporan.

| ID / Severity | Location | Vulnerability dan attack scenario | Impact | Fix |
|---|---|---|---|---|
| S01 **Critical** | [autonomous_reaper.py:34](/Users/apple/Downloads/ramadhan/ecosystem/openturath_subscription/autonomous_reaper.py:34) | Fallback `TELEGRAM_BOT_TOKEN` literal di file tracked. Siapa pun yang memperoleh source/history berpotensi memakai bot bila token masih valid. Chat ID fallback juga tersedia; validitas token sengaja tidak diuji | Kendali bot, penyalahgunaan notifikasi; memperbesar risiko jalur admin Telegram | Cabut/rotasi token di penyedia; pindah ke secret runtime; jangan fallback credential; bersihkan distribusi/history secara terencana setelah rotasi. Menyunting file saja tidak mencabut token |
| S02 **Critical jika route dapat dijangkau** | [webhook_server.py:1018](/Users/apple/Downloads/ramadhan/ecosystem/openturath_subscription/webhook_server.py:1018), [command handler:624](/Users/apple/Downloads/ramadhan/ecosystem/openturath_subscription/webhook_server.py:624) | `/telegram` menerima JSON tanpa secret header Telegram. Otorisasi memakai `message.chat.id` dari payload; pengirim dapat memalsukannya. `/reap` atau `/sync` memicu pekerjaan administratif | Pemicu operasi revoke/sync, spam alert/log, konsumsi resource. Akses internet bergantung IAM/proxy yang belum diverifikasi | Verifikasi secret webhook sebelum parse/dispatch, batasi sender/operator ID dan command, deduplikasi update; IAM/network boundary untuk route admin |
| S03 **High** | [webhook_server.py:968](/Users/apple/Downloads/ramadhan/ecosystem/openturath_subscription/webhook_server.py:968) dan [:998](/Users/apple/Downloads/ramadhan/ecosystem/openturath_subscription/webhook_server.py:998) | GET `/keepalive` menjalankan koneksi NotebookLM, `/cron/reap*` menjalankan reaper tanpa auth handler. Pemanggil dapat mengulang pekerjaan mahal; HTTPServer sinkron memperburuk antrean | Denial of service dan pemicu mutasi administratif. Tidak membuktikan pencabutan user aktif secara arbitrer | POST terautentikasi dari scheduler/service identity, lease/mutex, rate limit, batas waktu; health endpoint tidak melakukan operasi berprivilege |
| S04 **High** | [firestore.rules:73](/Users/apple/Downloads/ramadhan/openturath_ai/firestore.rules:73), [forwarder](/Users/apple/Downloads/ramadhan/openturath_ai/functions/src/index.ts:3136) | Create log tanpa login diizinkan dengan `userId=unauthenticated`; `extra`, breadcrumbs, stack/context tidak dibatasi menyeluruh. Client dapat menulis banyak error unik dan severity error/critical, lalu fungsi mengirim ke Telegram; dedup client mudah dilewati | Biaya write/trigger, alert flooding, konten tidak tepercaya masuk pesan HTML Telegram | Ingestion endpoint dengan kuota server/App Check, schema+size ketat, dedup di server, escape HTML, batasi alert agregat; minimalkan payload anonim |
| S05 **High** | [session manager](/Users/apple/Downloads/ramadhan/openturath_ai/lib/services/agent_session_manager.dart:40), [logout](/Users/apple/Downloads/ramadhan/openturath_ai/lib/services/auth_service.dart:273) | Singleton tab tidak memiliki owner UID dan `closeAll()` tidak dipanggil saat logout/delete/auth-change. Halaman keepalive dan resolved URL bertahan dalam proses; login akun kedua dapat memperoleh state tab lama | Risiko paparan isi/konteks akun sebelumnya di perangkat bersama. Tampilan isi lama belum direproduksi pada Android, tetapi lifecycle reset yang hilang terbukti | Ikat sesi ke UID; tutup dan dispose semua WebView keepalive pada auth change; invalidate URL/readiness; tes akun A → keluar → B tanpa restart |
| S06 **High** | [fallback produk Python](/Users/apple/Downloads/ramadhan/ecosystem/openturath_subscription/webhook_server.py:482) | Produk tak dikenal atau mapping hilang difallback ke “Paket Semua AI”; partial substring match juga dipakai. Event sah untuk produk baru yang belum dimapping bisa memberi notebook lebih luas | Overgrant sumber meski entitlement aplikasi tampak terbatas. Bukan bypass tanpa webhook sah | Fail closed pada product ID tak dikenal; mapping ID exact, satu registry lintas TS/Python; karantina event dan alert operator |
| S07 **High** | [Python idempotency](/Users/apple/Downloads/ramadhan/ecosystem/openturath_subscription/webhook_server.py:309) | Transaksi yang sudah ada selalu dilewati tanpa memeriksa perubahan status/event; read-then-write bukan transaksi atomik. Event berikutnya atau retry partial failure dapat gagal menyelaraskan akses; beberapa instance dapat race | Perbedaan pembayaran/entitlement/notebook, pencabutan tidak konsisten | Idempotensi berdasarkan event+state transition, write atomik, durable outbox, reconciling status tujuan; jangan salin pendekatan ini ke jalur TS yang sudah atomik |
| S08 **Medium** | [redeemCode](/Users/apple/Downloads/ramadhan/openturath_ai/functions/src/index.ts:1108), [fingerprint Android](/Users/apple/Downloads/ramadhan/openturath_ai/lib/services/device_service.dart:74) | `deviceId`, model dan `isPhysicalDevice` dipercaya dari callable payload; hash acak 64 hex lolos bentuk. Selain itu `androidInfo.id` adalah build ID, bukan ANDROID_ID sesuai komentar | Batas satu perangkat dapat dielakkan; perangkat model/build sama berpotensi ditolak bersama. Kuota kode/per-user masih membatasi—bukan akses tak terbatas otomatis | Jangan gunakan fingerprint klaim client sebagai proof; verifikasi eligibility server, App Check/attestation sesuai target, mekanisme identitas instalasi yang tepat dan pemulihan false positive |
| S09 **Medium** | [createCheckout](/Users/apple/Downloads/ramadhan/openturath_ai/functions/src/index.ts:579) | Auth diwajibkan tetapi tidak ada rate limit/idempotency checkout; tiap pemanggilan menulis transaksi dan menghubungi gateway. Caller terautentikasi dapat spam invoice | Biaya API/Firestore, invoice ganda dan confusion retry | Rate limit UID+global, reuse pending invoice dengan idempotency key, validasi panjang/tipe input. Harga harus tetap server authoritative |
| S10 **Medium** | [session cookie](/Users/apple/Downloads/ramadhan/openturath_ai/functions/src/index.ts:2462) | Cookie HMAC 8 jam diperiksa tanda tangan/umur dan entitlement, tetapi bukan Firebase revocation/disabled-user setiap request. Cookie yang dicuri dapat bertahan setelah revoke token jika entitlement masih aktif | Window penggunaan sesi lama; bukan cookie unsigned atau IDOR yang sudah dibuktikan | Session revocation version per UID atau sesi Firebase terverifikasi-revoked; revoke server saat tindakan akun sensitif |
| S11 **Medium** | [privacy](/Users/apple/Downloads/ramadhan/openturath_ai/public/privacy.html:133), [sync](/Users/apple/Downloads/ramadhan/openturath_ai/lib/services/bookmark_service.dart:124) | Dokumen menyebut catatan lokal, tetapi isi catatan dikirim cloud; alert Telegram tidak dijelaskan dalam daftar penerima. `sanitizeData` meredaksi pola token, bukan semua email bebas dalam string error | Ketidaksesuaian ekspektasi privasi; potensi data pribadi dalam error/breadcrumb diteruskan | Dokumentasikan data flow aktual; allowlist field log, redaksi server, masa retensi dan kontrol akses; jangan menganggap masking email profil menutupi semua PII |
| S12 **Low** | [webhook_server.py:197](/Users/apple/Downloads/ramadhan/ecosystem/openturath_subscription/webhook_server.py:197) | Log mismatch memuat prefix secret yang diharapkan dan token input | Kebocoran sebagian credential ke log; membantu korelasi/penyalahgunaan log | Catat request ID dan hasil verifikasi saja, tanpa potongan secret |

### Hal yang diperiksa dan tidak boleh salah dilaporkan

- DOKU sudah memeriksa signature secara constant-time dan nominal transaksi; aktivasi TS memakai transaksi Firestore, marker `activation_applied`, dan durable outbox. Jangan melaporkan “webhook DOKU tanpa verifikasi/idempotency”. Kelemahan Python adalah jalur berbeda.
- `getAgentUrl` memeriksa auth, rate limit dan entitlement; `checkPaymentStatus` memeriksa UID pemilik. Rules `users/{uid}` membatasi profil ke pemilik dan melarang klien mengubah entitlement.
- Firebase API key publik/OAuth client ID pada aplikasi bukan bukti secret server bocor. Token bot literal berbeda sifatnya.
- WebView memakai allowlist HTTPS host dan menolak mixed content. Handler copy mengecek host, tipe dan panjang. Namun pemeriksaan URL top-level saja belum membuktikan origin setiap frame/gesture bridge; pengujian ini belum dilakukan.
- Test event Python tanpa token berhenti pada acknowledgement; dari cabang itu tidak terbukti aktivasi akses berbayar.
- Tidak ditemukan SQL database pada alur inti, sehingga tidak tepat mengarang SQL injection. XSS pada markdown native juga tidak dapat disamakan dengan HTML browser. HTML/template TS memiliki escaping pada helper; audit ini tidak membuktikan semua sink browser bebas XSS.

### AI-specific security dan integritas sumber

1. **Chat-only bukan perlindungan dari pengambilan informasi melalui jawaban.** Komentar manager menyebut viewer tidak bisa membaca/menyalin database sumber, sementara fungsi AI memang memberi jawaban berbasis sumber. Tanpa uji ekstraksi, jangan menjanjikan kerahasiaan isi corpus dari pembaca yang sudah diberi akses. [Manager](/Users/apple/Downloads/ramadhan/ecosystem/openturath_subscription/notebooklm_manager.py:95).
2. **Indirect prompt injection / corpus poisoning masih belum terukur.** Repo memperlihatkan katalog dan provisioning, tidak menyediakan paket evaluasi yang membuktikan model menolak instruksi jahat dalam sumber. Uji corpus berisi instruksi menyimpang, kutipan palsu, konflik edisi dan output berbahaya; hasil model tidak boleh menjadi instruksi privileged backend.
3. **Belum ada bukti model dapat memanggil fungsi pembayaran/admin secara langsung.** Jangan mengklaim tool abuse atau data exfiltration server hanya karena produk memakai AI. Bridge yang terlihat terutama clipboard/save.
4. **Hilangnya provenance adalah temuan nyata.** `answerText` menghapus tombol/actions dan mengubah DOM menjadi teks; `copiedAnswerBookmark` tidak menyimpan source locator. Angka citation dalam teks tidak setara tautan sumber yang bisa dibuka.
5. **Strategi akses operasional bertentangan.** Sentinel memaksa restricted; `akal_sync.py` justru melewati add/remove dengan alasan public chat-only. Ini bukti konfigurasi/kode drift, bukan bukti semua notebook produksi publik. Tetapkan satu mode akses dan audit status notebook sebenarnya.

## G. Accessibility dan responsive audit

| Issue | Bukti | Dampak / rekomendasi | Status |
|---|---|---|---|
| Kontras label navigasi light | `OTColors.textTertiaryLight=#92928C` dipakai nav 11,5 pada surface putih | Rasio dihitung 3,13:1; terhadap canvas #F6F6F3 2,89:1. Gunakan muted yang memenuhi 4,5:1 untuk teks normal | Terbukti dari pasangan token; dark pasangan #85857F/#181817 ≈4,79:1, jangan pukul rata |
| Tombol clear search kecil tanpa nama eksplisit | Dashboard GestureDetector membungkus Icon close ukuran 18 tanpa padding/tooltip | Target motorik kecil; gunakan IconButton target 48 logical px dan label “Hapus pencarian” | Terbukti di kode |
| Kartu tidak menyediakan keyboard activation | AppleInteractiveWrapper memakai Semantics+GestureDetector, tanpa Focus/Actions/Shortcuts | Semantics button membantu screen reader tetapi tidak otomatis memberi Tab/Enter/Space. Gunakan kontrol focusable dengan focus ring | Terbukti struktur; test keyboard runtime belum dilakukan |
| Orientasi dikunci portrait | `main.dart:31` memanggil setPreferredOrientations portraitUp/Down | Menghambat perangkat dipasang landscape dan pengguna pembesaran; izinkan landscape kecuali esensial | Terbukti kode; penerapan aktual mengikuti platform |
| Nav selected state | `_GoogleNavBarItem` memakai warna/icon/garis, tanpa `Semantics(selected:...)` | Status aktif tidak dijelaskan eksplisit pada semantic tree oleh komponen kustom | Perlu semantic test |
| Focus search hilang | Semua border dashboard termasuk focusedBorder `InputBorder.none` | Fokus hanya mengandalkan caret; berikan ring/border focus yang jelas | Terbukti styling |
| Reduce motion tidak konsisten | Wrapper menghormati disableAnimations; custom route/overview dan page animation durasi tetap | Pertahankan dukungan yang ada dan terapkan ke route/splash; jangan menyatakan seluruh app tidak mendukung reduce motion | Gap kode |
| Text scaling native | Grid extent 156, nav height 64, tier 3 kolom, badge dua sisi | Risiko clipping pada 200% terutama Arab. Jangan mengunci textScale; ubah grid dan wrap menjadi responsif | Risiko, belum direproduksi |
| Zoom ruang AI | `supportZoom:false`, slider maksimal 1,6 | Pembesaran percakapan terbatas dan berbeda dari pengaturan sistem; uji ukuran besar dan sediakan kontrol baca yang cukup | Terbukti setting, dampak device belum diukur |
| RTL/UI bahasa | Book detail tooltip Arab tetap; katalog editorial tidak memakai Loc; daftar bidang dashboard literal Indonesia | Bahasa UI tidak konsisten; gunakan lokal UI dan Directionality per blok sumber | Terbukti kode |
| Arab search | Canonical normalisasi tersedia, editorial hanya lowercase | Query tanpa harakat bisa tidak menemukan judul berharakat. Satukan normalisasi alif/harakat/tatweel | Terbukti algoritme |
| Website mobile overflow | 360 px → root scrollWidth 394 pada index dan 395 pada download; tombol unduh melebar keluar viewport | CTA terpotong nyata. `white-space:nowrap` plus padding/label panjang; ubah label, allow wrap dan max-width | Terukur di browser |
| Mobile navigation hilang | CSS max-width 680 menyembunyikan nav tanpa menu pengganti | Harga/kebijakan sulit dicapai tanpa scroll panjang. Gunakan menu ringkas/anchor yang dapat dioperasikan keyboard | Terlihat browser+CSS |
| Tabel website | Wrapper `overflow-x:auto` memuat tabel lebar | Horizontal scroll tabel adalah kebutuhan konten, bukan otomatis bug root overflow. Tambah petunjuk scroll/nama region dan uji keyboard | Risiko discoverability |

WCAG 2.2 menetapkan 4,5:1 untuk teks normal dan 3:1 untuk teks besar; persyaratan minimum target memiliki pengecualian, sedangkan 48 logical px di sini adalah rekomendasi kenyamanan mobile, bukan klaim angka wajib WCAG. Lihat [kontras W3C](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html), [WCAG 2.2](https://www.w3.org/TR/WCAG22/) dan [orientasi W3C](https://www.w3.org/WAI/WCAG22/Understanding/orientation.html). Audit ini bukan sertifikasi WCAG.

### Matriks responsive

| Surface | Mobile/narrow | Tablet | Desktop/wide |
|---|---|---|---|
| Website index | Overflow CTA terbukti pada 360×800 | Root tidak overflow pada 768×1024 | Root tidak overflow pada 1440×900; ruang kosong hero cukup besar tetapi fokus CTA jelas |
| Website download | CTA dan header terpotong pada 360×800 | Belum screenshot khusus | Belum screenshot khusus |
| Shell Flutter | Nav bawah; risiko label scaling | Rail mulai 768; perlu uji RTL/keyboard | Rail 76, tetapi beranda tetap grid dua kolom tanpa max-width |
| Langganan | Badge/tier/CTA panjang perlu reflow | Batas konten 760 tersedia | Batas 760 wajar; jangan melebarkan hanya untuk mengisi layar |
| Katalog/reader | Arab+Latin+angka perlu mixed-direction test | Overview breakpoint 900 | Overview max 1280, reader 760; perlu kesatuan lebar bacaan berdasarkan tugas |

### Visual judgement yang bukan bug

Radius 18 dibanding 16, serif dibanding sans-serif, card hitam flagship, dan salam “Ahlan” bukan bug dengan sendirinya. Yang menjadi masalah adalah perubahan makna/hierarki, rendahnya kontras, inkonsistensi fungsi, atau dekorasi yang mengambil ruang tugas utama. Screenshot historis menunjukkan card/tanggal mendominasi fold; kode terbaru masih mempertahankan struktur grid/tanggal, tetapi tidak membuktikan semua ornamen screenshot masih dipakai.

## H. Design system audit

### Inventaris aktual

| Role | OT system | Native system / implementasi lain |
|---|---|---|
| Primary/accent | Ink #171717 / cream #F4F4F0 | Blue #0066CC / #2997FF |
| Background | #F6F6F3 / #111110 | #F5F5F7 / #101010 |
| Surface | #FFFFFF / #181817 | #FFFFFF / #1A1A1A |
| Border | #DDDDD8 / #30302E | Alpha #14191919 / #1FFFFFFF |
| Text primary | #171717 / #F4F4F0 | #1D1D1F / #F5F5F7 |
| Muted | #656560 / #B2B2AA; tertiary #92928C/#85857F | #616168/#C4C4CC; tertiary #70706A/#A0A099 |
| Secondary | Tidak ada role tunggal yang konsisten; surfaceSubtle tersedia | Warna aksen/collection/brass alias bercampur |
| Success/reference | Marja olive #3D4A3E/#9CAF9E | Native juga memiliki role marja; jangan samakan hasil AI dengan “terverifikasi” |
| Warning | Tidak terlihat kontrak role warning terpadu di dua file token utama | Tentukan semantic warning, bukan warna ad hoc pada snackbar |
| Error | Destructive #8C2F2F/#C97B74 | #8C2F2F/#E49A93 |
| Display/title | Newsreader pada ScholarlyFonts; OTTypography tersendiri | NativeTypography menyebut Newsreader tetapi NativeFonts.newsreader mengembalikan NativeInter |
| Body/interface | Outfit atau Scheherazade New lewat ScholarlyFonts | NativeFonts.outfit juga mengembalikan NativeInter |
| Arabic reading | Scheherazade New, height umumnya ≥1,85 | NativeArabic dengan height ≥1,85/1,9; direct TextStyle perlu diaudit per pemakai |
| Caption/metadata | 12 pada tokens; dashboard memakai 9,5/11,5/12,5 | Native label dan halaman lain memiliki ukuran inline |
| Spacing | 4/8/12/16/20/24/32/40/48/64 | Banyak penggunaan literal 5/6/10/14/18/22 di layar |
| Radius | input14/card16/sheet24/dialog20/button999 | card18/inner17/tier10/tag6; beberapa beda fungsional, beberapa drift |
| Shadow | Tidak wajib pada editorial | Subscription shadow black .35 blur20 offset8 menambah dominasi flagship |

Bukti: [OT palette](/Users/apple/Downloads/ramadhan/openturath_ai/lib/core/design/ot_colors.dart:10), [Native palette](/Users/apple/Downloads/ramadhan/openturath_ai/lib/core/design/native_design.dart:5), [typography](/Users/apple/Downloads/ramadhan/openturath_ai/lib/core/design/native_typography.dart:5), [native helper](/Users/apple/Downloads/ramadhan/openturath_ai/lib/core/design/native_fonts.dart:6).

### Inventaris komponen

- **Buttons:** Filled/Outlined/Text/IconButton bercampur InkWell/GestureDetector dan wrapper custom. Samakan semantic, focus, target, disabled/loading. Tidak semua button harus pill.
- **Inputs:** TextField dengan hint dan border manual; tetapkan label, hint, error dan focus state. Jangan hilangkan label hanya demi minimalisme.
- **Cards/rows:** SpecialistCard, study entry, flagship, tier, native rows, book editorial. Gunakan row untuk katalog berulang, card bila satu kelompok tindakan benar-benar utuh.
- **Modal/sheet:** redeem, DOKU, evidence, legal, note editor, font options. Tetapkan max-width, SafeArea, scroll saat keyboard muncul dan perilaku back.
- **Dropdown/tabs:** ChoiceChip/filter, popup menus, multi-tab AI dan bottom nav kustom. Selected state harus eksplisit secara visual dan semantic.
- **Tooltip/badge/alert:** tooltip tersedia pada banyak IconButton tetapi gesture icon tidak merata; badge status faktual berbeda dari “Eksklusif”; alert harus membawa tindakan.
- **Navigation/sidebar/table:** rail 768, bottom nav 64, tabel editorial website. Jangan memasukkan jargon database dalam nama navigasi.
- **Icons:** Material outline/filled bercampur, termasuk `auto_awesome` untuk asisten. Sparkle tidak melanggar usability sendiri, tetapi buku/percakapan lebih konkret untuk tugas produk; keputusan terakhir diuji pada pengguna.

### Sistem yang diusulkan

Satu sumber role warna dan semantic type; sementara sediakan adapter alias agar migrasi tidak merusak semua layar sekaligus. Pertahankan warna kertas/tinta; pilih satu aksen untuk tindakan yang perlu ditemukan. Jika biru Catatan dipertahankan, tetapkan alasan fungsional dan konsistensinya, bukan sekadar “Apple”. Body 16–17, metadata umumnya 12–13 yang berkontras cukup; judul 24–28; Arab sekitar 20–24 untuk pembacaan panjang dengan line-height diuji pada harakat. Ini titik awal desain, bukan ukuran mutlak.

Gunakan skala spacing yang ada; nilai kecil berbeda boleh untuk optical alignment bila disengaja. Card16/18 harus diputuskan sekali per role, sheet24, pill hanya selector/badge yang tepat. Standarkan lebar bacaan 680–760 dan direktori adaptif lebih lebar. Bundel font yang benar-benar dipakai; nama helper harus mencerminkan hasilnya. Jangan mengganti seluruh font semata untuk mengikuti tren.

## I. Technical debt, reliability dan performance

### Must Fix

- **Security S01–S07:** rotasi secret, autentikasi route administratif, pembatasan telemetry, reset sesi dan fail-closed provisioning.
- **Offline sync versi lokal baru:** loop `localMap` hanya push jika cloud tidak memiliki ID; tambahkan push bila local.syncTime lebih baru, termasuk tombstone. Gunakan durable retry dan tes dua perangkat/offline. Bug tetap relevan meskipun Firestore SDK sering mengantre write otomatis—service harus memulihkan write yang benar-benar gagal/ditolak.
- **Sumber dan klaim:** provenance terstruktur; jangan hilangkan makna rujukan saat menyimpan; hapus janji absolut yang belum terbukti.
- **User-facing error:** pisahkan unauthorized/not-found/pending provisioning; jangan mengarahkan semua orang membayar lagi.
- **Tes script gagal dan target lama:** `webview_script.test.ts` gagal pada invariant tidak menyembunyikan arbitrary content. Jangan sekadar menghapus assertion; tetapkan allowlist UI yang boleh diubah dan tes script aktif juga.
- **Checkout gating CI:** workflow build tanpa tests/analyzer memungkinkan regresi yang diketahui tetap dipaketkan.

### Should Fix

- **Kontrak katalog:** canonical dan editorial punya model, pencarian dan detail berbeda; satukan perilaku melalui adapter, bukan menghapus semua data/model sekaligus.
- **File besar:** `functions/src/index.ts` 3.160 baris (billing, entitlements, auth, HTML, notifications); room 1.248, dashboard 1.171, profile 1.152, bookmarks 1.114. Pisahkan sesuai batas perubahan yang sering diuji: billing/access/session/copy. Jumlah baris bukan alasan rewrite sendiri.
- **Lifecycle WebView:** tiga tab maksimum, bukan tujuh seperti komentar. `disposeWebResources` stop/remove handler tetapi tidak terlihat dispose keepalive native; hidden room maintainAnimation=true. Ukur native memory setelah buka/tutup berulang sebelum menetapkan “memory leak”; implementasi sekarang jelas mempertahankan resource dengan sengaja.
- **Observer DOM:** selector luas dan MutationObserver pada notebook, serta injeksi berlapis; ukur biaya selama streaming jawaban, debounce perubahan, hindari traversal ulang yang tidak perlu. Tidak ada bukti FPS buruk dari audit statis ini.
- **Penyimpanan catatan:** seluruh koleksi cloud dibaca dengan `.get()` tanpa pagination; seluruh JSON lokal ditulis ulang. Dengan catatan hingga 200.000 karakter per jawaban, koleksi besar menambah IO/memori dan waktu startup. Gunakan delta sync/penyimpanan yang sesuai setelah benchmark ukuran nyata.
- **Font:** aset NativeInter/Outfit/Newsreader/Arabic dibundel, tetapi sejumlah halaman masih memakai GoogleFonts. Perilaku offline/cache font perlu diverifikasi; jangan mengklaim selalu terjadi download baru.
- **Update:** entry dashboard memicu check+silent download; konsumsi data/jaringan dan dialog bisa bersaing dengan bacaan. Tawarkan kontrol unduh dengan ukuran file, jangan ubah menjadi broadcast otomatis.
- **Python single HTTPServer:** operasi panjang di handler memblokir request lain dalam instance; scheduler/admin queue terpisah akan lebih dapat dipantau.
- **Konfigurasi platform:** FirebaseOptions Windows/Linux memakai konfigurasi Android, macOS memakai iOS options; ini perlu pemeriksaan registrasi platform dan plugin aktual. Tidak cukup menyimpulkan runtime pasti gagal hanya dari nama variabel.
- **Copy/localization:** 532 entry terjemahan tidak mencakup semua literal inline. Tes jumlah bahasa/placeholder tidak membuktikan seluruh UI berubah bahasa.

### Nice to Have

- Hapus dependency tak terpakai setelah verifikasi import dan kebutuhan platform; Riverpod tidak ditemukan dipakai di lib. Jangan mengklaim semua dependency masuk bundle jika tree shaking mungkin membuangnya.
- Kurangi spacing/radius literal ketika menyentuh komponen terkait; tidak perlu PR besar hanya mengganti angka.
- Rapikan komentar usang “7 tabs”, “polling 2 detik”, “Android ID” dan bahasa “zero-glitch/100%”. Komentar bukan bukti performa/keamanan.
- Catat ownership modul, keputusan desain, dan diagram alur provisioning yang benar-benar berjalan.

### Performance: ukuran dan hal yang tidak relevan

Aset lokal kira-kira: data 9,7 MB, image 1,5 MB, native fonts 1,3 MB, animasi 700 KB. Ini belum membuktikan APK terlalu besar; ukuran release aktual/ABI belum diukur. Katalog menggunakan cache dan list builder pada beberapa jalur, sehingga klaim “tidak ada caching/lazy rendering” salah. Flutter native tidak mempunyai masalah SSR/hydration React; website ini HTML statis, bukan SPA dengan hydration. Fokus profiling pada startup, font, parsing katalog, WebView, sync catatan, dan antrean provisioning.

## J. Prioritas eksekusi

| Phase | Pekerjaan | Hasil yang harus terbukti sebelum dianggap selesai |
|---|---|---|
| **1 — Critical** | Cabut token, pindahkan secret; autentikasi Telegram/cron/keepalive; batasi telemetry; fail-closed product mapping dan state transition Python | Request tanpa identitas ditolak sebelum side effect; unknown product tidak menambah notebook; secret lama tidak berlaku; duplicate/out-of-order event tidak mengubah akses salah |
| **1 — Critical** | Reset session per UID dan dispose keepalive; perbaiki offline sync | A→logout→B tak melihat tab/teks A; edit/hapus offline terkirim setelah retry dan tidak kembali dari perangkat kedua |
| **1 — Critical** | Hilangkan janji absolut; pisahkan paid/provisioning; perbaiki CTA mobile dan masalah kontras/keyboard inti | Pengguna tahu status akses sebenarnya; download dapat dibaca dan dioperasikan di 360 px; jalur masuk/pilih/simpan dapat dioperasikan tanpa pointer |
| **2 — High impact** | Satukan perilaku search; akses pustaka langsung; provenance tersimpan; paket sesuai bidang asal; pesan error actionable | Tugas cari bidang→pertanyaan→sumber→catatan selesai tanpa label menyesatkan atau langkah overview wajib |
| **2 — High impact** | Sinkronkan website, kebijakan, pricing dan manifest rilis; CI menjalankan tes aktif | Harga/cakupan/versi sama lintas permukaan; pipeline menolak tes gagal; kebijakan menggambarkan cloud notes dan alert aktual |
| **3 — Polish** | Satukan role warna/type/radius, rapikan density, typography Arab, motion dan ikon | Identitas turats tetap terlihat; scrolling lebih pendek; tidak ada penambahan dekorasi tanpa fungsi |

Ukuran keberhasilan produk sebaiknya: waktu menemukan asisten relevan, tingkat berhasil membuka sumber, persentase pembayaran menjadi akses siap, kegagalan sync, dan keberhasilan kembali ke catatan. Angka target perlu baseline; tidak ada analytics/conversion study dalam audit ini sehingga uplift tidak boleh direkayasa.

## K. Benchmark yang relevan

- **Zotero:** hubungan catatan dan bahan pustaka, serta pencarian catatan, merupakan acuan pekerjaan riset yang konkret. Ambil prinsip sumber–catatan yang dapat ditemukan kembali, bukan meniru tampilan desktop. [Notes](https://www.zotero.org/support/notes), [Searching](https://www.zotero.org/support/searching).
- **NotebookLM / dokumentasi Google saat audit berjudul Gemini Notebook:** citation mengarah ke kutipan dalam konteks; penyimpanan note dapat mempertahankan inline citations. Inferensi untuk OpenTurath: adapter yang mengubah semuanya ke plain text mengurangi nilai penelusuran yang sudah tersedia pada layanan sumber. Ketersediaan setiap fitur pada akun/chat-only OpenTurath masih perlu uji. [Dokumentasi chat resmi](https://support.google.com/gemininotebook/answer/16179559?hl=en).
- **W3C:** kontras, orientasi, fokus dan target adalah prinsip usability/accessibility yang stabil, bukan branding. Bandingkan terhadap requirement yang relevan, bukan selera “premium”. [WCAG 2.2](https://www.w3.org/TR/WCAG22/).

**Standar pola:** tujuan tindakan jelas, status akses benar, sumber dapat ditelusuri, search sesuai label, focus terlihat. **Branding:** serif editorial, istilah ibarah, penanggalan Hijriah, karakter Tahawwulat. **Tren opsional:** glass/pill/shadow/sparkle, animasi pegas, badge eksklusif. Tren bukan otomatis salah, tetapi tak boleh mengorbankan dua kelompok pertama.

## L. Arah desain final: ruang baca dengan sumber yang jelas

**Visual personality.** Tenang, padat secukupnya, seperti indeks perpustakaan yang dapat dipakai setiap hari. Judul kitab, pengarang, kutipan dan status sumber menjadi pembeda. Jangan meniru Apple/Linear/ChatGPT sebagai identitas baru.

**Typography.** Satu keluarga UI yang konsisten, satu gaya editorial untuk judul bila memang membantu, satu font Arab yang terbaca dengan harakat. Jangan mengganti serif menjadi Inter melalui helper bernama newsreader secara tersembunyi. Caption bukan tempat menyimpan informasi penting dengan ukuran 9,5.

**Color.** Kertas/tinta tetap dasar. Aksen terbatas untuk aksi/selection. Warna status harus berarti hal yang sama; hijau/olive tidak boleh menyiratkan “divalidasi ulama” jika hanya status teknis.

**Spacing/density.** Direktori ringkas, reader nyaman, formulir cukup lega. Kalender sebagai tambahan kecil. Jangan membungkus setiap metadata dalam card. Lebar teks harus mengikuti bacaan, bukan seluruh monitor.

**Components.** Pertahankan pengelompokan bidang, pemilihan asisten, metadata kitab, Catatan, RTL dan mode gelap. Sederhanakan badge flagship, ornamentasi angka/garis, overview sebelum katalog, dan varian komponen yang tidak berbeda fungsi. Satu tombol simpan yang dapat ditemukan ulang lebih berguna daripada toast sementara.

**Motion.** Animasi singkat untuk perubahan posisi/status bila membantu orientasi; hormati reduced motion. Hilangkan jeda sukses 2,2 detik yang hanya menunda pengguna. Jangan membuat preload/visibility diinterpretasikan sebagai bukti sesi siap.

**Copy.** Bahasa Indonesia langsung dan hormat. Istilah Arab menjelaskan objek keilmuan, bukan menaikkan gengsi tombol. Klaim jumlah/cakupan harus datang dari data; tidak menggunakan “Super”, “Pertama di Dunia”, “Anti-Halusinasi” tanpa bukti yang layak.

**UX.** Pertahankan konteks tugas: asisten yang dipilih, sumber yang diperiksa, catatan yang disimpan dan status akses. Satu tindakan punya satu efek yang bisa diperkirakan. Pengguna tidak perlu memahami provisioning, cookie atau nama model internal untuk menyelesaikan pekerjaan.

## M. Verifikasi audit dan pekerjaan yang belum dilakukan

| Pemeriksaan | Hasil | Makna dan batas |
|---|---|---|
| `flutter analyze --no-pub` | Dua info lint di subscription:338,340 | Bukan error kompilasi; analyzer belum bersih sepenuhnya |
| `flutter test --no-pub` | **166 passed** | Ada tes kontrak/source inspection. Test DOKU direct dapat kembali tanpa pengujian network jika env tidak tersedia dan menelan SocketException; angka lulus bukan bukti checkout produksi |
| `functions/node_modules/.bin/tsc --noEmit` | **Lulus** | Tidak mengubah output build; tidak memverifikasi runtime IAM/provider |
| `node --experimental-transform-types --test functions/test/*.test.ts` | **40 passed, 1 failed** | Failure “reading styles never hide arbitrary content or toolbar elements”, webview_script.test.ts:32. Percobaan awal strip-only gagal karena parameter property TS; rerun transform-types adalah hasil yang dipakai |
| Rules Firestore | Inspeksi statis | Belum menjalankan emulator rules suite; izin deployment aktual belum dikonfirmasi |
| Visual browser | CTA clipped pada mobile; root overflow index394/download395 vs viewport360 | Tablet/desktop index tidak root overflow pada ukuran yang diuji; tidak berarti seluruh breakpoint selalu aman |
| Browser console | Tidak ada warn/error yang tertangkap pada sesi index yang diperiksa | Tidak mencakup checkout, autentikasi atau network produksi |
| Secret scan lokal terarah | Satu token-format Telegram ditemukan di tracked Python | Tidak membuktikan tidak ada secret jenis lain/history; token tidak diuji ke penyedia |
| Android E2E, RTL native, screen reader, 200% text scale | Belum dilakukan | Tidak ada Android terhubung; akses akun uji notebook/pembayaran tidak digunakan |
| APK/production build | Tidak dibuat | Audit tidak mengubah kode; bukan sertifikat build/release. Tidak menyalin APK, deploy atau broadcast |

### Acceptance tests untuk fase perbaikan

1. Akun A membuka jawaban; keluar; akun B masuk di proses yang sama. Tidak ada tab/teks/clipboard otomatis/konteks A yang dipulihkan.
2. Catatan sudah ada di cloud, diedit dan dihapus saat push dibuat gagal; retry mengirim versi/tombstone terbaru dan perangkat kedua merekonsiliasi.
3. Webhook admin tanpa secret, chat ID palsu, event duplikat/out-of-order, unknown product, dan invoice mismatch ditolak atau diproses tanpa overgrant.
4. Pembayaran diterima tetapi provisioning gagal: UI menyebut pembayaran diterima, menawarkan recovery, dan tidak meminta bayar lagi.
5. Query Arab berharakat/tanpa harakat menemukan kitab sama pada semua katalog. Teks Arab/Latin/angka tetap benar pada locale ID/EN/AR.
6. 320/360/390/768/1440 piksel, landscape, text scale 100/150/200%; keyboard Tab/Enter/Space; screen reader menyebut nama/selected/status dengan benar.
7. Adapter notebook berubah selector: error terdeteksi, tidak menampilkan layar kosong selamanya, sumber tetap dapat ditelusuri, fallback jelas.
8. Manifest rilis, link download, versi, ukuran dan hash konsisten; build APK hanya lokal dan tidak memicu publikasi otomatis.

Kesimpulan audit: kualitas matang akan datang dari keandalan akses, kejujuran klaim, dan hubungan jawaban–sumber–catatan. Redesign kosmetik besar sebelum tiga hal tersebut selesai akan mempertahankan masalah yang sama dalam tampilan baru.
