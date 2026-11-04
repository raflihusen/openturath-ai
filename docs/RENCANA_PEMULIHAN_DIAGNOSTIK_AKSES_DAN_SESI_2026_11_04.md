# Rencana Pemulihan Diagnostik, Akses Modul, dan Sesi Google OpenTurath AI

Tanggal: 4 November 2026, zona waktu laporan kepada pemilik Asia/Aden.

Status: **rencana implementasi untuk ditinjau; belum merupakan persetujuan menjalankan implementasi atau rilis**.

Workspace: `/Users/apple/Downloads/ramadhan`.

Baseline kode saat penyusunan: branch `v9-2-integrasi`, HEAD `d8befd8b470852f225f8d2edd3f8ffcc7b4de2c6`, versi sumber aplikasi `1.0.87+88`.

**Pembaruan setelah audit login kedua:** akses beranda harus dipisahkan dari keberhasilan membuka NotebookLM. Audit lanjutan berhasil mereproduksi penghalang tersebut melalui enam skenario tambahan dan menjalankan 21 regresi sesi pada salinan sumber yang identik. Perbaikan alur masuk ini menjadi prioritas awal, sebelum menunggu penyebab seluruh tiket historis teridentifikasi. Rincian ada pada bagian 14 dan `docs/audit-login-kedua-2026-11-04/AUDIT.md`.

## 1. Tujuan dan hasil akhir

Memastikan setiap kegagalan membuka bilik mempunyai bukti penyebab yang cukup, pengguna menerima langkah pemulihan yang sesuai, pelanggan berhak tidak diminta membeli ulang, dan keberhasilan dibuktikan melalui pemakaian bilik di perangkat.

Pekerjaan menghasilkan:

1. Jalur laporan yang mempertahankan tahap dan kode kegagalan asli, termasuk kegagalan sebelum WebView terbentuk.
2. Keputusan tampilan yang membedakan kebutuhan paket, penyiapan akses, sesi aplikasi, sesi Google, penolakan notebook, dan gangguan pemuatan.
3. Pemeriksaan akses yang tetap mengikuti keputusan pemilik, VIP permanen, hak per modul, dan bukti transaksi atau pemberian akses yang sah.
4. Pengujian kontrak server–aplikasi, perilaku layar, privasi, dan regresi sesi.
5. Bukti pemakaian nyata di Android, Windows, dan macOS; hasil tiap platform dilaporkan sendiri.
6. Paket kandidat dengan asal kode dan nomor build yang jelas, rencana pemulihan, dan pemisahan antara build lokal, pemasangan uji, deployment server, dan publikasi.

Keberhasilan bukan sekadar jumlah laporan berkurang. Ukuran utamanya adalah penyebab dapat ditelusuri dan pengguna yang berhak benar-benar dapat menggunakan bilik.

## 2. Dasar bukti dan ketidakpastian

Angka berikut adalah **snapshot pembacaan audit sebelumnya pada 4 November 2026**, bukan kueri yang diperbarui terus-menerus.

| Bukti | Temuan | Implikasi untuk rencana |
|---|---|---|
| `diagnostic_reports` | 17 tiket; 16 `load-failed` dengan halaman `unknown` dan seluruh flags galat `false` | Perbaiki kehilangan konteks sebelum menyimpulkan penyebab masing-masing tiket. |
| Tiket izin Google | Satu `google-permission`, mengarah ke notebook Tafsir legacy | Penolakan teramati; identitas akun dan alasan penolakan belum terhubung. |
| Breadcrumbs tiket | Hanya jejak aplikasi dimulai | Tahap pengambilan URL, jawaban server, dan pemuatan bilik belum dapat direkonstruksi. |
| Identitas tiket | Tidak ada identitas terverifikasi untuk korelasi transaksi | Status berbayar pelapor tidak dapat ditentukan dari tiket tersebut saja. |
| `auth_failure_stats` | 18 dokumen agregat, total 24 kejadian; 13 `google-auth-page` | Kejadian meminta login bercampur dengan kegagalan; bukan jumlah pengguna unik. |
| Versi Windows pada agregat | Menampilkan `1.0.87` | Hipotesis hanya versi `1.0.86` tidak memadai. Versi pada agregat lama juga bukan riwayat versi per kejadian. |
| Kode Windows | Login browser dengan PKCE sudah ada | Uji alur yang ada dan pisahkan dari sesi Google WebView; jangan membangun ulang berdasarkan asumsi bahwa PKCE belum ada. |
| Commit `10fefed5` | Tidak ditemukan di checkout yang diperiksa | Jangan menganggap perbaikan yang disebut laporan sudah ada atau sudah terpasang. |
| Cloud Logging dan metadata fungsi | Pembacaan belum berhasil dengan akses yang tersedia | Asal fungsi yang berjalan dan galat server historis belum terbukti. |

Pembagian penyebab 75%–15%–10% belum dapat dipakai sebagai dasar keputusan. Sebanyak 16 tiket lama tetap berstatus `penyebab_belum_teridentifikasi` sampai ada bukti tambahan. Penyebabnya tidak boleh diisi ulang dengan dugaan setelah perubahan aplikasi.

Kekurangan data historis tidak menghalangi perbaikan lokal pada pelaporan dan pengujian kontrak. Kekurangan tersebut menghalangi klaim bahwa seluruh insiden lama sudah diketahui atau selesai.

## 3. Batas pekerjaan dan aturan yang dipertahankan

### 3.1 Termasuk dalam pekerjaan

- Pelaporan kegagalan membuka bilik, pengambilan alamat, pengelompokan hasil autentikasi, dan tindakan pemulihan di layar.
- Kontrak alasan terstruktur pada jalur `getAgentUrl`, beserta adapter aplikasi.
- Konfirmasi kesiapan akses setelah pembayaran atau penukaran kode dan pengujian konsistensinya.
- Perbaikan spesifik yang kemudian dibuktikan melalui reproduksi, bukan seluruh dugaan dalam laporan lama sekaligus.
- Kompatibilitas aplikasi lama dengan server baru dan aplikasi baru dengan jawaban server lama.

### 3.2 Aturan mutlak

- VIP dari whitelist, flag, role, registry, atau `VIP_PERMANENT` tetap dihormati sesuai keputusan pemilik. Edisi Guru pada klien bukan bukti otorisasi server.
- Hak akses dievaluasi per modul. Modul yang habis tidak menggugurkan modul lain yang masih aktif.
- Tidak ada penghapusan massal `access_revocation_hold`. Flag tersebut merupakan perlindungan terhadap pencabutan dan juga dapat terkait preservasi akses legacy.
- Tidak ada pemberian atau pencabutan akses pelanggan, replay transaksi, penggantian expiry, atau perubahan status VIP sebagai bagian pengujian lokal.
- Transaksi unik tetap idempoten; nominal nol tidak dijadikan perpanjangan otomatis tanpa dasar pemberian akses yang sah.
- Siklus hidup WebView dalam `agent_multi_tab_room.dart` dan `desktop_webview_runtime.dart` dipertahankan. Perubahan adapter pelaporan tidak boleh mengubah timer, proses navigasi, keep-alive, mounting, atau kepemilikan controller.
- Polling tetap minimal empat sampel berturut-turut, elapsed minimum 3000 ms, dan jeda stabilisasi 250 ms. Tidak ada pemangkasan untuk mengejar kesan cepat.
- Galat tetap menggantikan seluruh viewport dengan `ColoredBox`; tidak ada platform view tersembunyi di bawah overlay galat.
- Cookie Google aktif tidak ditulis ulang, diperpanjang secara buatan, disalin dari browser lain, atau dihapus saat inisialisasi, membuka tab, retry, maupun pergantian akun aplikasi. Pembersihan global hanya melalui Log Out yang dipilih pengguna.
- macOS tetap mendukung minimal lima tab tanpa eviksi sebelum batas tersebut. Perpindahan tab tetap mempertahankan `clean()`.
- CSS rapat, bebas scrim, composer di dalam alur flex, dan desain monokrom dipertahankan. Pengecualian banner promo merah tetap sesuai aturan workspace.
- Setiap unit perubahan file langsung mendapat checkpoint Git dengan file yang disebutkan eksplisit. Perubahan atau penghapusan yang sudah ada di working tree tidak diikutkan.

Rujukan: `AGENTS.md`, `openturath_ai/docs/STANDAR_IDEAL_WEBVIEW.md`, dan `DOKUMENTASI_KECACATAN_SISTEM_DAN_ATURAN_VIP.md`.

## 4. Peta komponen dan perubahan yang direncanakan

| Komponen | Lokasi | Perubahan yang direncanakan |
|---|---|---|
| Kegagalan bertipe | `openturath_ai/lib/services/agent_service.dart` | Pertahankan kode server, alasan terstruktur, dan ID permintaan; jangan hanya membawa pesan tampilan. |
| Model bukti kegagalan | File baru kecil di `openturath_ai/lib/models/` | Snapshot tidak berubah untuk satu percobaan, terpisah dari controller WebView dan flags tampilan. |
| Pemetaan pemulihan | File baru kecil di `openturath_ai/lib/core/` | Pemetaan alasan ke pesan dan tindakan yang dapat diuji tanpa menjalankan WebView. |
| Transport callable | `openturath_ai/lib/services/callable_gateway.dart` | Bawa ID percobaan opsional dan pertahankan `details` tanpa mengubah serialisasi autentikasi atau retry token yang sudah ada. |
| Pengambilan URL dan tombol laporan | `openturath_ai/lib/widgets/agent_multi_tab_room.dart` | Adapter minimal untuk menangkap bukti saat kegagalan terjadi dan mengirim snapshot; tidak merombak siklus hidup. |
| Data percobaan tab | `openturath_ai/lib/services/agent_session_manager.dart` | Tambahkan konteks diagnostik per percobaan bila diperlukan; jangan ubah manajemen resource atau batas tab. |
| Pengiriman laporan | `openturath_ai/lib/services/diagnostic_report_service.dart` | Skema tambahan yang tervalidasi, nomor build, sanitasi rute, dan konteks autentikasi opsional. |
| Tombol laporan | `openturath_ai/lib/widgets/diagnostic_report_action.dart` | Cegah pengiriman ganda insiden yang sama; tampilkan nomor tiket yang sama untuk pengulangan request. |
| Statistik autentikasi | `openturath_ai/lib/services/auth_failure_reporter.dart` | Pisahkan status proses, pembatalan, dan kegagalan; deduplikasi sesuai percobaan, bukan menyembunyikan kejadian selamanya selama satu proses aplikasi. |
| Login Google WebView | `openturath_ai/lib/screens/google_session_auth_screen.dart` | Catat kode native, tahap, dan skema rute yang aman; penanganan navigasi baru hanya setelah rute penyebab terbukti. |
| Kontrak server | `openturath_ai/functions/src/index.ts` | Alasan terstruktur, penerimaan skema diagnostik tambahan, korelasi server, kompatibilitas versi lama, dan pembatasan notifikasi. |
| Pemeriksaan akses | `openturath_ai/functions/src/access_control.ts` | Pertahankan keputusan otorisasi; tambah konteks alasan dari pemeriksaan yang sudah ada. Tidak mengubah grant/revocation engine untuk memperbaiki tampilan. |
| Penyiapan akses | `openturath_ai/lib/services/subscription_service.dart`, `openturath_ai/lib/widgets/access_prepare_gate.dart` | Audit seluruh pemanggil; pastikan habis waktu tidak ditampilkan sebagai siap saat pemeriksaan tidak tersedia atau gagal. |
| Teks dan tata letak | Lokalisasi aplikasi dan widget status | Bahasa Indonesia, Arab RTL, dan Inggris; tindakan utama jelas, tanpa pesan internal server mentah. |

Nama file baru ditentukan saat implementasi mengikuti konvensi sumber saat itu. Bagian di luar daftar hanya disentuh jika reproduksi membuktikan hubungan langsung dan perubahan tersebut dicatat dalam lingkup akhir.

## 5. Model keadaan dan tindakan pengguna

Keadaan diturunkan dari bukti yang berbeda: autentikasi aplikasi, hak modul server, penyiapan undangan, sesi Google di WebView, dan kesiapan composer. Satu penanda `siap` tidak boleh mewakili semuanya.

| Keadaan | Bukti minimum | Tindakan utama | Perlakuan laporan |
|---|---|---|---|
| `app_session_required` | Sesi aplikasi tidak sah setelah pemulihan token yang sudah ada | Masuk kembali ke aplikasi | Kegagalan autentikasi aplikasi bila benar-benar gagal. |
| `entitlement_required` | Server memastikan tidak ada hak modul dan tidak ada keadaan preservasi yang belum terselesaikan | Lihat paket atau tukarkan kode | Penolakan yang diharapkan; bukan alarm kerusakan layanan. |
| `entitlement_expired` | Hak modul telah habis berdasarkan dasar akses yang sah | Perpanjang modul terkait | Tidak memengaruhi modul lain. |
| `access_provisioning` | Hak tercatat, assignment belum siap | Periksa kembali penyiapan akses | Tidak mengarahkan membeli ulang. |
| `capacity_waiting` | Server memastikan penyiapan menunggu kapasitas | Tampilkan akses sedang disiapkan dan jalur bantuan | Insiden operasional, bukan kesalahan pengguna. |
| `legacy_review` | Akses lama sedang dicocokkan; bukti belum lengkap | Tampilkan pemeriksaan akses dan bantuan | Pertahankan perlindungan yang ada; tidak memberi hak baru berdasarkan dugaan. |
| `identity_mismatch` | Identitas aplikasi terverifikasi tidak sesuai profil yang dipakai server | Jelaskan akun yang perlu dipakai | Jangan meminta membeli ulang. |
| `google_session_required` | Halaman login Google teramati | Hubungkan akun Google yang sesuai | Status proses; belum menjadi kegagalan hanya karena halaman login muncul. |
| `google_permission_denied` | HTTP 403 notebook atau detektor penolakan yang sudah ada | Periksa hak server dan kesesuaian akun | Tidak menyimpulkan belum membeli atau salah akun tanpa bukti tambahan. |
| `provider_rejected` | Halaman penolakan Google yang dikenali | Petunjuk khusus sesuai kode yang teramati | Simpan alasan aman; tidak menjanjikan penyelesaian dengan mengutak-atik cookie. |
| `navigation_unsupported_scheme` | Platform dan kode native yang cocok; Android `-10` | Penanganan sesuai skema tautan yang berhasil diidentifikasi | Bukan kegagalan lisensi. |
| `transport_failure` | Galat jaringan, HTTP, TLS, atau koneksi yang terklasifikasi | Coba lagi sesuai jenis gangguan | Pertahankan kode native dan platform. |
| `readiness_timeout` | Batas kesiapan yang berlaku tercapai tanpa composer siap | Coba ulang bilik atau bantuan | Jangan langsung menyebut autentikasi gagal. |
| `cancelled` | Pembatalan eksplisit yang dikenali | Kembali ke keadaan netral | Tidak mengirim alarm gagal login. |
| `unclassified_failure` | Penyebab belum dapat ditentukan | Coba lagi dan kirim laporan | Tulis ketidakpastian dengan jelas; pertahankan bukti mentah yang aman. |
| `ready` | Alamat sah, sesi sesuai, dan kriteria kesiapan yang ada terpenuhi | Gunakan bilik | Uji akhir tetap memerlukan pertanyaan dan jawaban nyata. |

Aturan konflik: bila cache klien dan server berbeda, ikuti keputusan server yang terverifikasi. Ketidakpastian legacy atau VIP tetap diselesaikan melalui aturan preservasi, bukan pemaksaan paywall. Flag edisi dan flags diagnostik dari klien tidak menjadi sumber hak akses.

## 6. Kontrak bukti dan kompatibilitas

### 6.1 Konteks per percobaan

| Field | Sumber dan batas |
|---|---|
| `schema_version` | Nilai tetap untuk skema baru; laporan lama tetap dapat dibaca. |
| `attempt_id` | ID acak per pembukaan atau retry yang nyata; tidak dibuat setiap polling. Tidak memakai email, token, atau identitas perangkat. |
| `event_id` | ID pengiriman untuk idempotensi; retry request yang sama membawa ID yang sama. |
| `agent_id` dan modul | Nilai dari katalog yang dikenali; server memvalidasi hubungan sub-AI ke modul. |
| Versi, nomor build, platform, edisi | Metadata paket; klaim klien hanya untuk diagnostik, bukan otorisasi. |
| Tahap dan kode asli | Misalnya pengambilan URL, navigasi Google, pemuatan dokumen, atau kesiapan composer; transport code dipisahkan dari reason. |
| `reason` | Enum yang dikenali; galat baru yang tidak dikenal tetap `unclassified_failure`. |
| ID permintaan server | Dibuat server dan dikembalikan pada hasil atau galat terstruktur bila handler sempat berjalan. Tidak dijanjikan untuk penolakan yang terjadi sebelum handler. |
| Rute aman | Host, skema, dan pola path yang disaring; query, fragmen, userinfo, dan segmen sensitif dibuang. |
| Konteks pemuatan | Boolean URL diterima/controller tersedia/script tersedia/composer siap, elapsed, serta kode HTTP/native bila tersedia; tanpa isi DOM atau teks percakapan. |
| Identitas dan status akses terverifikasi | Diturunkan server dari token yang diverifikasi, bukan `uid`, email, atau `is_vip` yang dikirim dalam body. Tidak diteruskan sebagai data pribadi ke Telegram. |
| Waktu bukti | Timestamp server untuk tiket dan pemeriksaan akses; bukti membership lama tidak dilabel sebagai verifikasi Google saat ini. |

Snapshot kegagalan diambil saat penyebab masih tersedia. Tombol laporan tidak bergantung pada controller yang mungkin telah dilepas atau berada di `about:blank`. URL yang tidak valid tidak menimpa URL notebook aman yang sudah diketahui. Snapshot dari percobaan lama tidak terbawa ke retry atau pergantian akun.

### 6.2 Kontrak alasan server

- Pertahankan kode callable standar, misalnya `permission-denied`, `failed-precondition`, dan `unavailable`.
- Tambahkan `details` dengan alasan terbatas, ID permintaan, dan konteks modul yang aman. Klien tidak memutuskan tindakan dengan mencari potongan kalimat pesan server.
- Keputusan otorisasi tetap berasal dari jalur pemeriksaan yang ada. Telemetry tidak memanggil `reserve`, `repair`, `revoke`, atau operasi berbagi notebook.
- Tahap pertama menggunakan `getAgentUrl` beserta pemeriksaan yang sudah tersedia. Tidak membuat layanan provisioning atau endpoint perbaikan akses baru hanya untuk mengatasi laporan generik.
- `getAccessReadiness` tetap untuk penukaran kode atau invoice milik pengguna; tidak dipaksakan menjadi pemeriksaan modul umum tanpa kontrak yang jelas.

### 6.3 Identitas, keamanan, dan kompatibilitas

- Laporan sebelum login tetap didukung. Konteks anonim berarti status pelanggan tidak diketahui.
- Token opsional hanya diverifikasi di server, tidak disimpan, tidak dicetak, dan tidak diteruskan ke bot. Telemetry tidak memulai login atau refresh token interaktif.
- Token tidak ada, kedaluwarsa, atau gagal diverifikasi tidak menghasilkan identitas tepercaya. Penanganan laporan anonim tetap terpisah dari pembacaan data pemilik.
- Penambahan field bersifat opsional. Server baru menerima payload lama; klien baru mempunyai fallback aman terhadap jawaban lama atau `details` yang tidak dikenal.
- Laporan tanpa nomor build tidak diberi nomor build hasil tebakan. Field versi agregat lama tidak dipakai untuk mengklaim versi semua kejadian di dalamnya.
- Data lama tidak dimigrasikan menjadi diagnosis pasti. Tidak ada penghapusan koleksi lama untuk merapikan statistik.
- Aturan akses Firestore untuk data diagnostik tetap membatasi pembacaan data lintas akun; tidak ada pembukaan koleksi kepada seluruh pengguna demi dashboard.

## 7. Rencana pelaksanaan berurutan

### P0 — Baseline, preservasi, dan daftar bukti

1. Verifikasi kembali workspace, HEAD, branch, status staged/unstaged, dan versi paket sebelum implementasi.
2. Catat perubahan atau penghapusan yang sudah ada; jangan restore, stash, reset, clean, atau ikut meng-commit pekerjaan tersebut.
3. Buat branch kerja `codex/diagnostic-access-session-recovery` dengan baseline yang dicatat. Jangan memindahkan pekerjaan lain tanpa kebutuhan.
4. Simpan matriks bukti: temuan pasti, dugaan, cara membuktikan, dan keterbatasan akses. Pisahkan waktu kejadian UTC dari waktu laporan Asia/Aden.
5. Catat hash kandidat lama dan asal artefak bila tersedia. Snapshot kode tidak dianggap bukti bahwa paket pengguna berasal dari kode tersebut.
6. Jalankan baseline uji relevan dengan harness terisolasi dan stub jaringan/Telegram. Bedakan kegagalan lama dari regresi baru.

**Keluaran:** catatan baseline dan inventaris pengujian. **Syarat lanjut:** perubahan pihak lain terlindungi dan baseline dapat ditelusuri.

### P1 — Pertahankan penyebab asli sampai tiket

1. Tambahkan model konteks kegagalan yang kecil dan tidak bergantung pada WebView.
2. Pertahankan code dan reason pada `AgentAccessException`; teruskan `details` yang aman dari server.
3. Tangkap kegagalan sebelum URL diperoleh, termasuk unauthenticated, pemeriksaan identitas, penyiapan akses, kuota permintaan, gangguan layanan, dan format URL tidak valid.
4. Hubungkan konteks tersebut ke tombol laporan melalui adapter minimal. Pertahankan seluruh logika lifecycle yang dilindungi.
5. Tambahkan versi dan build aktual; catat URL resolved yang aman tanpa melakukan pembacaan controller tambahan yang dapat menggantung.
6. Perbarui validasi server untuk field tambahan; tetap lakukan redaksi di kedua sisi.
7. Tambahkan korelasi identitas server opsional dan idempotensi pengiriman. Pastikan penolakan telemetry tidak menggagalkan login atau bilik.

**Keluaran:** satu galat terkontrol sebelum WebView dapat ditelusuri dari pemicu sampai tiket. **Syarat lanjut:** kode asli tidak berubah menjadi `load-failed`, tidak ada kebocoran rahasia, dan klien lama tetap diterima.

### P2 — Kontrak alasan dan pemetaan tindakan

1. Petakan setiap cabang keputusan `getAgentUrl` dan resolver akses ke reason yang konsisten, tanpa mengubah siapa yang berhak.
2. Bedakan tidak punya hak, hak habis, penyiapan tertunda, kapasitas, pemeriksaan legacy, ketidakcocokan identitas, dan notebook tidak tersedia.
3. Tambahkan pemetaan reason ke tindakan di helper terpisah; jangan menyebarkan pemeriksaan string pesan ke widget.
4. Pertahankan paywall hanya untuk penolakan hak yang sudah dikonfirmasi. VIP, voucher aktif, pelanggan aktif, dan kasus penyiapan tidak diminta membeli ulang.
5. Pastikan permintaan modul A tidak memengaruhi modul B dan sub-AI memeriksa scope induk yang benar.
6. Audit pemanggil `AccessPrepareGate`: tidak ada hasil sukses berbasis waktu semata jika kesiapan server diperlukan. Jalur tanpa pemeriksaan harus menyatakan belum terkonfirmasi.
7. Periksa kembali status setelah penyiapan dengan mekanisme yang ada, tanpa loop retry tanpa batas atau mutasi undangan dari klien.

**Keluaran:** tabel kontrak yang digunakan server, aplikasi, dan pengujian. **Syarat lanjut:** semua keadaan terkontrol memberikan tindakan yang sesuai dan hak akses tidak berubah.

### P3 — Pisahkan login aplikasi, sesi Google, dan kegagalan pemuatan

1. Perlakukan tampilan halaman login Google sebagai fase `google_session_required`, bukan langsung alarm gagal login.
2. Pisahkan pembatalan eksplisit dari penolakan penyedia, gangguan jaringan, dan timeout credential. Jangan mengabaikan galat hanya karena kata tertentu muncul dalam pesan bebas.
3. Untuk Windows, uji OAuth browser yang sudah ada sampai Firebase menerima credential, lalu uji sesi Google WebView secara terpisah.
4. Rekam platform dan native code pada galat pemuatan. Android `-10`, Windows `9`, dan macOS `-1005` tidak dipetakan berdasarkan angka tanpa platform.
5. Reproduksi Android `-10` untuk memperoleh skema rute penyebab yang aman. Pilih handler hanya setelah rute diketahui: tautan yang sah didukung melalui jalur platform yang sesuai, sementara rute tak dikenal tidak dibuka sembarangan.
6. Untuk penolakan notebook, bandingkan hak server, assignment yang dipilih, bukti membership beserta waktunya, dan akun yang sudah dapat diverifikasi. Bila akun WebView tidak dapat dipastikan, tulis `unknown` dan arahkan pemeriksaan pengguna.
7. Pertahankan cookie, polling, composer, dan tata letak yang dilindungi. Perubahan arsitektur login atau presentasi NotebookLM berada di luar rencana ini.

**Keluaran:** hasil login dan pemuatan dapat dibedakan dalam tiket maupun statistik. **Syarat lanjut:** tidak ada mutasi cookie di luar Log Out dan tidak ada penurunan kemampuan bilik yang sebelumnya berfungsi.

### P4 — Reproduksi penyebab operasional yang tersisa

1. Gunakan kode dan ID korelasi baru untuk mempersempit kegagalan yang benar-benar terjadi.
2. Bila akses baca minimum tersedia, cocokkan log fungsi yang berjalan, waktu deployment, build klien, dan keputusan akses. Jangan memperluas IAM atau mengganti credential pengguna secara otomatis.
3. Jika log historis tetap tidak tersedia, gunakan reproduksi terisolasi dan kandidat uji; tandai keterbatasan untuk tiket lama.
4. Jika bukti menunjukkan assignment, kapasitas, provider, token, atau jaringan sebagai penyebab, buat perbaikan kecil yang khusus untuk reproduksi itu.
5. Replay undangan atau perbaikan data produksi hanya dapat menjadi tindakan terpisah setelah bukti per akun/modul, dampak, dan pemulihannya jelas serta pemilik mengizinkan.
6. Ulangi hanya pengujian yang terdampak perubahan baru, lalu lanjutkan uji integrasi akhir.

**Keluaran:** catatan insiden yang menghubungkan gejala, bukti, reproduksi, perubahan, dan hasil. **Syarat lanjut:** tidak ada klaim tuntas untuk kasus yang belum dapat direproduksi atau dibuktikan.

### P5 — Statistik dan notifikasi yang mencerminkan kejadian

1. Pisahkan hasil `ready`, `failed`, `cancelled`, penolakan hak yang diharapkan, dan percobaan yang tidak diketahui akhirnya.
2. Bila persentase keberhasilan diperlukan, rekam awal dan hasil akhir percobaan secara terbatas, maksimal satu awal dan satu hasil terminal per percobaan; jangan mengirim event setiap polling.
3. Gunakan skema agregat baru yang menyertakan build dan reason yang terbatas. Jangan mencampur hitungan baru dengan agregat lama yang dimensinya berbeda.
4. Percobaan tanpa event akhir tetap terlihat sebagai belum diketahui; tidak dihilangkan untuk memperbaiki angka keberhasilan.
5. Bedakan rasio keberhasilan teknis bilik bagi akun berhak dari rasio semua pembukaan termasuk paywall dan pembatalan. Definisi denominator selalu dicantumkan.
6. Terapkan deduplikasi tiket pada retry request yang sama dan pengelompokan alarm pada penyebab yang sama. Jangan menekan laporan pelanggan berhak demi menurunkan jumlah pesan.
7. Pertahankan pembatasan laju; evaluasi pengaruh IP bersama dari bukti sebelum mengubah limit. Pisahkan prioritas laporan pelanggan berhak dari status login normal.
8. Gunakan ID tiket dan metadata aman pada Telegram; status biasa tidak mengirim alarm. Pengiriman notifikasi baru tidak diaktifkan selama pengujian lokal.

**Keluaran:** laporan angka yang menjelaskan periode, platform, build, jumlah percobaan, hasil, dan ketidakpastian. **Syarat lanjut:** angka dapat dihitung ulang dan pengiriman ulang tidak menggandakan insiden.

### P6 — Uji terpadu dan bukti perangkat

1. Jalankan pemeriksaan statis dan kelompok uji terarah untuk setiap unit perubahan; checkpoint tetap dibuat segera, tanpa menumpuk perubahan.
2. Setelah seluruh rangkaian terhubung, jalankan suite regresi relevan secara terpadu. Suite penuh dilakukan sekali pada kandidat akhir; ulangi bila ada perubahan atau kegagalan yang relevan.
3. Siapkan kandidat lokal dengan nomor build baru dan identitas paket yang jelas. Standard dan Guru mempunyai artefak, hash, dan jalur verifikasi terpisah.
4. Pada Android release, pastikan kompilasi Gradle selesai sepenuhnya, binary berasal dari build yang selesai, dan salinan `app-release-latest.apk` memiliki timestamp baru yang valid.
5. Verifikasi paket terpasang dan versi yang benar-benar berjalan sebelum menguji alur pengguna. Integritas, signing, pemasangan, dan fungsi runtime dicatat terpisah.
6. Uji Android, Windows, dan macOS menurut matriks di bawah. Platform yang belum tersedia diberi status belum diuji; keberhasilan platform lain tidak menggantikannya.
7. Gunakan akun serta notebook uji yang memang disediakan untuk pengujian. Pembayaran memakai lingkungan uji; jangan membuat pembayaran nyata atau mengubah akun pelanggan demi mereproduksi kasus.

**Keluaran:** bukti per skenario dan platform, termasuk tiket diagnostik terkontrol. **Syarat lanjut:** seluruh pengujian kritis platform yang akan dirilis telah lulus dan tidak ada regresi perlindungan akses/sesi.

### P7 — Kandidat rilis, deployment terpisah, dan pemulihan

1. Siapkan daftar perubahan, checkpoint, hasil pengujian, batas yang belum terverifikasi, artefak, checksum, dan prosedur pemulihan yang dapat ditinjau.
2. Uji kompatibilitas server baru dengan klien lama dahulu; kandidat aplikasi baru kemudian diuji dengan kontrak server lama dan baru.
3. Deployment server, pemasangan kandidat pada perangkat, publikasi artefak, dan broadcast pembaruan adalah tindakan yang berbeda. Persetujuan build bukan persetujuan salah satu tindakan lainnya.
4. Setelah izin deployment yang sesuai, terapkan dukungan server yang kompatibel lebih dahulu, lalu uji kandidat terbatas sebelum publikasi yang diizinkan.
5. `publish_auto_update.py`, Firebase Hosting/CDN, dan perubahan `app_config/version` hanya dilakukan jika pemilik secara langsung memerintahkan rilis atau broadcast terkait.
6. Pantau hasil kandidat dengan periode dan jumlah percobaan yang dilaporkan apa adanya. Waktu observasi saja atau sampel kecil tidak dinyatakan bukti stabilitas seluruh pengguna.

**Keluaran:** keputusan rilis berbasis bukti dan catatan observasi. **Syarat selesai:** definisi selesai pada bagian 12 terpenuhi untuk cakupan platform yang disepakati.

## 8. Matriks pengujian kritis

Seluruh pengujian kontrak memakai data sintetis, penyedia palsu, dan Telegram stub. Pengujian perangkat adalah pekerjaan terpisah dengan akun/notebook uji yang sah.

| ID | Skenario | Hasil yang harus dibuktikan | Tingkat uji |
|---|---|---|---|
| T01 | Server menolak sebelum URL karena sesi aplikasi tidak sah | Tiket mempertahankan tahap dan kode asli; tindakan masuk kembali, bukan membeli | Kontrak + perilaku layar |
| T02 | Tidak ada hak modul | Paket/redeem tampil; tidak mengaku jaringan rusak | Kontrak + layar + perangkat |
| T03 | Pelanggan aktif, assignment provisioning | Tidak ada tombol beli ulang; kesiapan menunggu bukti server | Kontrak + layar + perangkat |
| T04 | Assignment `ready` tanpa bukti verifikasi atau notebook tidak tersedia | Belum dianggap siap; alasan notebook/penyiapan sesuai | Backend + kontrak |
| T05 | VIP dari setiap jalur perlindungan yang berlaku | Tidak terkena paywall dan tidak menjadi target pencabutan | Backend + regresi akses |
| T06 | Tahawwulat aktif, Syafi'i habis | Hanya status Syafi'i dinyatakan habis; Tahawwulat dapat digunakan | Backend + model + perangkat |
| T07 | Voucher aktif dibanding tanpa voucher | Voucher sah tidak diklasifikasikan sebagai akun tanpa lisensi | Backend + layar |
| T08 | Legacy dengan hold dan membership yang teramati | Tidak menghapus hold atau merelokasi notebook demi menghilangkan pesan galat | Backend + regresi |
| T09 | Server dan cache lokal berbeda | Keputusan server yang terverifikasi dipakai tanpa mengabaikan preservasi VIP/legacy | Kontrak + layar |
| T10 | Google meminta login dan pengguna menyelesaikannya | Status proses tidak dihitung sebagai gagal; bilik lanjut siap | Layar + perangkat |
| T11 | Pengguna membatalkan login | Keadaan netral; tidak ada alarm kegagalan teknis | Unit + layar + perangkat |
| T12 | Penolakan notebook, hak aktif, akun Google berbeda atau belum terverifikasi | Panduan akun dan pemeriksaan akses; tidak menjual ulang paket | Integrasi + perangkat |
| T13 | Windows OAuth browser berhasil tetapi WebView belum login | Kedua tahap dibedakan; tidak menganggap token Firebase sebagai cookie NotebookLM | Kontrak + perangkat Windows |
| T14 | Android kode `-10` | Tiket menyebut platform dan skema aman; handler diuji setelah rute diketahui | Unit + perangkat Android |
| T15 | Windows kode `9` dan macOS `-1005` | Klasifikasi sesuai platform; tidak disamakan dengan pembatalan pengguna | Unit + perangkat terkait |
| T16 | Gangguan jaringan, HTTP, TLS, timeout credential | Kode penyebab tetap utuh; retry tidak menggandakan efek mutasi | Kontrak + integrasi |
| T17 | Composer belum siap setelah waktu tunggu yang berlaku | Timeout kesiapan tercatat; tidak memalsukan sukses atau diagnosis autentikasi | Layar + perangkat |
| T18 | Empat sampel, minimum 3000 ms, jeda 250 ms | Adapter baru tidak mengubah stabilisasi yang diwajibkan | Regresi perilaku + perangkat |
| T19 | Menutup layar, retry, background/resume, atau berganti akun saat laporan berjalan | Tidak ada state lama salah menempel, navigasi basi, atau error controller | Layar + integrasi |
| T20 | Lima tab macOS dan pergantian tab | Lima sesi tetap tersedia, tidak ada eviksi sebelum batas, composer dan teks tetap normal | Regresi + perangkat macOS |
| T21 | Buka login/AI/pembayaran dan tutup-buka aplikasi | Sesi Google aktif terpelihara tanpa replay atau penghapusan cookie | Regresi + perangkat |
| T22 | Payload memuat token, email, cookie, query, atau segmen URL sensitif | Rahasia tidak muncul dalam dokumen atau notifikasi | Kontrak + redaksi |
| T23 | `uid`, status VIP, flags, atau nomor build palsu dalam body | Tidak menghasilkan hak akses atau identitas server yang dipercaya | Kontrak keamanan |
| T24 | Token diagnostik hilang, invalid, atau kedaluwarsa | Tidak ada identitas palsu; jalur anonim tetap aman dan tidak mengganggu UI | Kontrak + integrasi |
| T25 | Tombol diklik cepat, request diulang, respons hilang, atau server menolak laju | Satu insiden mempunyai satu tiket; pengiriman gagal ditampilkan jujur | Kontrak + layar |
| T26 | Klien lama/server baru dan klien baru/server lama | Fallback aman; unknown tetap terlihat; tidak ada pemaksaan upgrade tanpa dasar | Kontrak kompatibilitas |
| T27 | Penyiapan akses lewat 30 detik, pemeriksaan gagal, atau tidak dipasang | Tidak menampilkan siap berdasarkan habisnya timer saja | Widget + integrasi pemanggil |
| T28 | Transaksi yang sama diproses ulang dan nominal nol tanpa verifikasi | Tidak menambah durasi atau akses baru sebagai efek samping perbaikan | Regresi backend |
| T29 | Bahasa Indonesia, Arab RTL, Inggris; ukuran layar kecil/besar | Pesan serta tombol dapat dibaca; tidak bocor detail internal; monokrom terjaga | Widget + visual perangkat |
| T30 | Akun berhak membuka bilik lalu mengirim pertanyaan | Jawaban benar-benar diterima; versi berjalan, modul, dan hasil dicatat | Perangkat Android/Windows/macOS |
| T31 | Google kedua berhasil, lalu muncul saran pemulihan opsional | Dashboard dapat dimasuki tanpa kunjungan ke NotebookLM; owner WebView tidak dipalsukan | Widget + perangkat |
| T32 | Sesi aplikasi sah, pengguna berada di halaman keamanan Google | Tindakan masuk aplikasi tersedia dan tidak mensyaratkan domain NotebookLM | Widget + perangkat |
| T33 | Email DOM Google/NotebookLM tidak terbaca | Tidak memblokir beranda; status koneksi AI tetap sesuai tingkat bukti | Widget + kontrak hasil koneksi |
| T34 | NotebookLM lambat atau tidak tersedia setelah login aplikasi | Beranda dan bagian aplikasi lain tetap dapat dipakai | Integrasi + perangkat |
| T35 | Login baru dibanding startup untuk akun sah yang sama | Persyaratan akses beranda konsisten pada kedua jalur | Widget + integrasi |
| T36 | Koneksi dibuka dari bilik lalu ditunda atau belum terverifikasi | Tidak mengembalikan sukses AI palsu dan tidak menghapus status pemulihan bilik | Widget + integrasi |
| T37 | Google masih meminta challenge wajib | Tidak dinyatakan sebagai owner/sesi Google terverifikasi hanya karena URL atau cookie ada | Kontrak + perangkat |
| T38 | Cookie Google ada tetapi sesi Firebase tidak sah | Tidak dapat masuk beranda hanya berdasarkan cookie atau cache profil | Regresi autentikasi |
| T39 | Himpunan cookie dikenali fallback tetapi berbeda dengan pemeriksaan akhir | Keputusan baca-saja konsisten; tidak ada penulisan atau pembuatan cookie | Regresi sesi |
| T40 | Identitas berubah, logout, atau layar ditutup sebelum callback pascalogin | Tidak ada navigasi dan penetapan owner memakai identitas lama | Widget + regresi sesi |

Pengujian fokus pada keputusan dan akibat yang dapat diamati. Tidak menambah tes untuk getter trivial atau sekadar menyalin baris implementasi. Pemeriksaan teks sumber saja tidak menggantikan uji perilaku atau bukti perangkat.

## 9. Pengujian yang sudah tersedia dan celah yang ditutup

| Area | Berkas tersedia | Penggunaan dalam pekerjaan |
|---|---|---|
| Redaksi dan laporan | `diagnostic_report_service_test.dart`, `auth_failure_reporter_test.dart`, `functions/test/auth_failure_report.test.ts` | Perluas sampai preservasi penyebab sebelum WebView, identitas opsional, idempotensi, build, dan kompatibilitas. |
| Hak akses | `active_subscription_access_test.dart`, `audit_entitlement_test.dart`, `functions/test/access_control.test.ts`, `revocation_gate.test.ts` | Gunakan fixture VIP dan granularitas yang sah; jangan menjadikan cache klien sumber kebenaran. |
| Penyiapan akses | `access_prepare_gate_test.dart`, `functions/test/paid_without_access.test.ts` | Uji seluruh pemanggil serta penyiapan sebagian paket; pertahankan deteksi belum siap. |
| Login dan sesi | `desktop_auth_gateway_test.dart`, `auth_startup_recovery_test.dart`, `google_session_auth_flow_test.dart`, `google_session_recovery_test.dart` | Uji pemisahan proses login dan kegagalan, kegagalan yang terlambat, serta pemulihan tanpa mengubah cookie. |
| Cookie dan tab | `persistent_google_session_test.dart`, `agent_session_manager_test.dart` | Perluas ke lima tab macOS dan interaksi laporan dengan sesi yang hidup. |
| Transport dan worker | `desktop_transport_test.dart`, `functions/test/access_worker_queue.test.ts`, `worker_lease.test.ts`, `access_monitoring.test.ts` | Jalankan regresi jika kontrak atau konteks menyentuh jalur ini; tidak merombak worker tanpa reproduksi. |

Berkas tersebut dibaca saat penyusunan rencana awal dan belum dijalankan pada tahap awal itu. Audit login kedua kemudian menjalankan empat berkas regresi sesi (21 kasus) dan enam kasus reproduksi tambahan, seluruhnya lulus pada salinan sumber yang identik. Hasil tersebut memverifikasi perilaku kode saat audit, termasuk penghalang yang harus diperbaiki; **bukan hasil kandidat perbaikan**. Berkas lain dalam tabel tidak otomatis dianggap sudah dijalankan.

## 10. Prioritas, dependensi, dan checkpoint

| Urutan | Paket kerja | Dependensi | Checkpoint contoh |
|---|---|---|---|
| 1 | Baseline dan catatan bukti | Tidak ada | `docs(recovery): catat baseline dan batas bukti insiden bilik` |
| 2 | Model konteks kegagalan dan uji perilakunya | Baseline | `feat(diagnostics): simpan konteks kegagalan per percobaan` |
| 3 | Dukungan server untuk skema laporan tambahan | Kontrak model | `feat(diagnostics): terima konteks laporan dan verifikasi identitas opsional` |
| 4 | Penyebab asli dari pengambilan URL ke tiket | Model + dukungan kontrak | `fix(room): pertahankan penyebab pengambilan URL pada laporan` |
| 5 | Alasan akses terstruktur dan pemetaan tindakan | Kontrak server–aplikasi | `fix(access): bedakan hak modul penyiapan dan gangguan layanan` |
| 6 | Status login, pembatalan, dan kode native | Model + router | `fix(auth): pisahkan langkah login pembatalan dan galat pemuatan` |
| 7 | Koreksi spesifik berdasarkan reproduksi | Bukti insiden | `fix(<komponen>): <penyebab yang sudah dibuktikan>` |
| 8 | Deduplikasi, statistik, dan prioritas notifikasi | Identitas percobaan stabil | `fix(telemetry): pisahkan hasil percobaan dan cegah laporan ganda` |
| 9 | Bukti integrasi, perangkat, dan kandidat lokal | Implementasi terhubung | `docs(verification): catat hasil kandidat per platform` |

Tabel merupakan urutan dependensi, bukan izin membiarkan banyak file berubah tanpa checkpoint. Setiap unit perubahan file langsung di-stage secara eksplisit dan di-commit. Hindari `git add -A`. Pisahkan catatan rencana, kode, kontrak server, dan bukti verifikasi agar dapat dipulihkan sendiri-sendiri.

P0–P3 merupakan prioritas utama. P4 bersifat berdasarkan bukti yang muncul. P5 tidak boleh menunda pembetulan laporan yang kehilangan kode asli. P6 wajib sebelum klaim perbaikan runtime. P7 baru dijalankan sesuai izin tindakan eksternal yang relevan.

## 11. Risiko nyata dan prosedur pemulihan

| Risiko | Pencegahan dan tindakan jika muncul |
|---|---|
| Pelanggan aktif diminta membeli ulang | Uji keputusan server/cache/VIP/pending. Hentikan kandidat bila kasus ini muncul; pulihkan router baru tanpa mengubah hak pelanggan. |
| Cookie atau WebView yang sehat terganggu | Adapter pelaporan dipisahkan dari lifecycle. Hentikan kandidat dan revert commit terkait; jangan membersihkan cookie untuk menyamarkan regresi. |
| Statistik tampak membaik karena data hilang | Perlihatkan coverage, unknown, pembatalan, start tanpa terminal, dan build. Jangan menilai hanya dari jumlah alarm. |
| Payload lama ditolak server baru | Skema tambahan opsional dan contract test dua arah. Pulihkan dukungan endpoint sebelumnya yang kompatibel. |
| Data pribadi ikut tiket atau Telegram | Redaksi dua sisi, route allowlist, identitas dari server, dan fixture berisi rahasia sintetis. Hentikan pengiriman field bermasalah jika verifikasi gagal. |
| Perbaikan undangan menggandakan efek | Tidak ada mutasi undangan pada jalur laporan. Perbaikan provider terpisah, per modul, dan idempoten jika kemudian diperlukan serta diizinkan. |
| Rilis salah edisi atau paket lama tersalin | Periksa edition, versi/build, sumber commit, signing, hash, timestamp, pemasangan, dan versi berjalan secara terpisah. |
| Log produksi tidak tersedia | Lanjutkan kontrak dan reproduksi lokal; catat batas bukti. Jangan menebak diagnosis tiket lama atau memperluas akses secara otomatis. |

Rollback memakai revert checkpoint yang relevan atau deployment versi sebelumnya yang telah diverifikasi. Tidak menggunakan reset/clean untuk menghapus pekerjaan lain. Dukungan server untuk payload lama dipertahankan selama kandidat klien dipulihkan. Artefak pembanding dan snapshot bukti tetap disimpan; pemulihan tidak mengubah VIP, transaksi, expiry, atau membership pelanggan.

## 12. Definisi selesai dan bukti yang diserahkan

Pekerjaan kode dan pengujian lokal selesai bila:

- [ ] Seluruh penyebab terkontrol mempertahankan tahap, kode asli, modul, build, dan ID percobaan sampai tiket.
- [ ] Pelanggan berhak, VIP, voucher aktif, penyiapan tertunda, serta akses legacy terlindungi tidak diklasifikasikan sembarang sebagai perlu membeli.
- [ ] Galat yang belum dikenali tetap tercatat sebagai belum teridentifikasi, bukan dibuang atau diberi alasan palsu.
- [ ] Kontrak lama/baru, redaksi, autentikasi opsional, idempotensi, dan pembatasan laju lulus.
- [ ] Pengujian kritis akses granular, transaksi unik, cookie, polling, error viewport, dan lima tab macOS lulus dalam cakupannya.
- [ ] Tidak ada perubahan akun, transaksi, undangan, atau sesi produksi sebagai efek samping pengujian.

Pemulihan runtime selesai untuk suatu platform bila:

- [ ] Kandidat dengan nomor build yang diketahui benar-benar terpasang dan sedang berjalan.
- [ ] Akun uji berhak dapat membuka bilik, menyelesaikan login bila diperlukan, mengirim pertanyaan, dan menerima jawaban.
- [ ] Penolakan yang diharapkan dan kegagalan yang disengaja menghasilkan petunjuk serta laporan yang benar.
- [ ] Tutup-buka aplikasi, background/resume, dan alur tab terkait tidak merusak sesi.
- [ ] Bukti platform tersebut tersedia; platform lain tetap dilaporkan sendiri.

Penyelesaian insiden historis dan publikasi dicatat terpisah:

- [ ] Setiap tiket lama diberi status terbukti, didukung reproduksi, atau masih tidak cukup bukti; tidak semua otomatis dianggap selesai karena kandidat baru lulus.
- [ ] Deployment dan publikasi, bila diminta, mempunyai bukti tersendiri. Build lokal bukan broadcast atau bukti semua pengguna telah menerima perbaikan.

Dokumen akhir harus memuat: checkpoint dan perubahan final, matriks hasil aktual, bukti perangkat, artefak serta asalnya, kasus belum terverifikasi, dan cara pemulihan. Hasil build, hash, tes lokal, pemasangan, penggunaan nyata, dan publikasi tidak digabung menjadi satu klaim sukses.

## 13. Kebutuhan pelaksanaan dan keputusan yang belum tersedia

- Lingkungan pengujian Android, Windows, dan macOS, berikut akun/notebook uji yang sah; ketersediaan Windows nyata harus dipastikan sebelum menjanjikan kelulusan Windows.
- Akses baca minimum log dan metadata fungsi bila diperlukan untuk mengunci galat server historis. Kekurangannya bukan alasan menghentikan pekerjaan lokal yang independen.
- Konfirmasi asal binary yang menghasilkan tiket jika dapat diperoleh; nomor versi saja tidak cukup untuk menghubungkan paket ke commit.
- Instruksi pelaksanaan implementasi merupakan tahap setelah rencana ini. Persetujuan deployment, perubahan data produksi, dan broadcast mengikuti tindakan konkretnya serta otorisasi yang sudah diberikan dalam sesi.

Estimasi durasi baru dibuat setelah baseline pengujian, ketersediaan perangkat, dan kebutuhan koreksi P4 diketahui. Rencana ini tidak menjanjikan tenggat untuk penyebab yang masih belum dapat direproduksi. Kemajuan dinilai dari paket bukti yang selesai, bukan dari jumlah commit atau turunnya jumlah notifikasi.

## 14. Prioritas baru: keluar dari login Google kedua tanpa menunggu NotebookLM

### 14.1 Penyebab yang sudah berhasil direproduksi

- Pemeriksaan otomatis dan watchdog hanya menyelesaikan koneksi ketika URL berada di domain NotebookLM.
- Tombol Lanjutkan menolak halaman Google lain sebelum memeriksa sesi.
- Konfirmasi “Ya, sudah masuk” masih memerlukan email yang terbaca dari NotebookLM pada pemeriksaan akhir.
- Login baru menahan pengguna melalui syarat koneksi Google, sedangkan startup sudah mengizinkan dashboard untuk Firebase user sah tanpa syarat tersebut.

Secara teknis login kedua menunggu domain dan identitas pada halaman NotebookLM, bukan composer. Composer tetap merupakan syarat kesiapan bilik yang diperiksa terpisah.

### 14.2 Perubahan urutan kerja

Setelah baseline P0, dahulukan kontrak navigasi berikut dan uji T31–T40. Pekerjaan ini dapat berjalan tanpa menunggu akses Cloud Logging atau diagnosis 16 tiket lama.

1. Bedakan izin memasuki aplikasi, bukti sesi Google WebView, dan kesiapan bilik. Firebase user yang sah mengizinkan beranda; cookie atau cache saja tidak cukup.
2. Tetapkan konteks layar koneksi: dibuka sesudah login aplikasi atau untuk memulihkan bilik. Jangan hanya mengandalkan susunan Navigator untuk menentukan makna hasil.
3. Bedakan hasil koneksi terverifikasi, belum terverifikasi/ditunda, dan dibatalkan. Hasil “boleh masuk beranda” tidak dipakai sebagai true/sukses pemulihan AI.
4. Izinkan perpindahan ke dashboard setelah keberhasilan login Google teramati, tanpa domain NotebookLM sebagai syarat. Halaman tindak lanjut yang opsional tidak menjadi penghalang global aplikasi.
5. Jika status Google belum dapat disimpulkan, sediakan tindakan masuk OpenTurath yang jelas selama sesi aplikasi sah. Koneksi AI tetap belum terverifikasi; tidak menulis marker verified owner atau google_session_ready secara palsu.
6. Pertahankan verifikasi akun dan hak modul sebelum penggunaan bilik yang memerlukannya. Jangan menganggap semua halaman Google atau cookie lama membuktikan challenge berhasil.
7. Sesuaikan teks, fallback, dan telemetry agar penundaan koneksi bukan pembatalan login aplikasi.
8. Jalankan regresi route, pergantian akun, cookie, dan hasil pemulihan bilik, lalu uji perangkat dengan halaman pascalogin yang benar-benar muncul.

Siklus hidup WebView bilik, polling yang diwajibkan, cookie, VIP, dan data akses tetap dipertahankan. Audit ini belum menerapkan perubahan runtime atau mempublikasikan kandidat.
