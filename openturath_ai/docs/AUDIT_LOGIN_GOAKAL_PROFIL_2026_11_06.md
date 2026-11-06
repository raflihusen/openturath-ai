# Audit login, GoAkal, status AI, dan penghapusan akun

Tanggal: 6 November 2026. Audit kode lokal dan dokumentasi resmi; bukan perubahan arsitektur atau pembayaran produksi.

## Kesimpulan keputusan

Mengganti gateway pembayaran tidak menyatukan sesi identitas aplikasi dan sesi situs Google. GoAkal dapat menjadi sumber pembayaran, tetapi aplikasi tetap memerlukan bukti identitas atau bukti kepemilikan hak akses untuk menampilkan paket pribadi secara aman. Menghapus Firebase Authentication berarti mengganti fungsi tersebut atau menerima keterbatasan profil; bukan sekadar menghapus tombol login pertama.

Firebase tidak mewajibkan pengguna memasukkan kata sandi dua kali: kode saat ini memperoleh kredensial Google, lalu menukarkannya dengan sesi Firebase tanpa formulir kedua. Prompt tambahan berasal dari sesi Google dalam WebView yang terpisah. Tidak ada bukti dalam audit ini bahwa kredensial OAuth aplikasi dapat langsung dipakai untuk membentuk cookie login situs Google.

Rekomendasi segera: pertahankan pembayaran dan identitas yang berjalan, hilangkan kewajiban koneksi AI sebelum beranda, jelaskan batas privasi pada titik permintaan, dan pisahkan status paket dari kesiapan koneksi. Untuk sasaran satu konteks login, evaluasi alur portal web dan AI di browser yang sama melalui prototipe terisolasi. Jangan menjanjikan satu prompt di semua perangkat sebelum pengujian; tantangan keamanan Google tetap berada di luar kontrol aplikasi.

## Bukti kode

| Lokasi | Temuan dan akibat |
|---|---|
| `lib/services/auth_service.dart:281–299` | GoogleSignIn memilih akun dan memperoleh token; signInWithCredential memakai token tersebut untuk Firebase. Firebase di sini bukan formulir kata sandi kedua. |
| `lib/screens/google_session_auth_screen.dart:59–103` | Layar mengharuskan sesi aplikasi asal masih aktif dan membuka InteractiveLogin di konteks WebView untuk tujuan appEntry. Kode saat ini tetap mengarahkan appEntry ke layar ini meskipun telah tersedia tombol melanjutkan beranda. |
| `lib/services/persistent_google_session.dart` | Menyimpan penanda pemilik sesi setelah verifikasi WebView. Penanda lokal tidak membuktikan identitas kepada server dan bukan token Google ID untuk aplikasi. |
| `lib/services/agent_service.dart:136` dan `functions/src/index.ts:246–375` | Alamat AI berasal dari fungsi berautentikasi: token email terverifikasi, profil, dan entitlement diperiksa server. Penghapusan Firebase tanpa pengganti memutus akses ini. |
| `lib/services/payment_service.dart` | Checkout saat ini memakai Cloud Functions/Midtrans. |
| `functions/src/index.ts:2970` | Jalur akalWebhook/syncAkalPurchases dinyatakan dipensiunkan pada 22 Oktober 2026; hak historis tetap ada di ledger. Ini bukti sumber lokal, bukan pemeriksaan deployment aktif. |
| `ecosystem/openturath_subscription/akal_client.py` dan `webhook_server.py` di root workspace | Masih ada komponen integrasi GoAkal berbasis API server dan webhook. Keberadaannya tidak membuktikan endpoint produksi aktif atau aman diaktifkan kembali tanpa audit cutover. |
| `lib/screens/profile_screen.dart:335–348` | Profil mengikuti AuthService.userStream dan resolveMembershipPass(UserModel), bukan pemeriksaan langsung sesi Google/AI. |
| `lib/core/membership_pass_state.dart` | Status kartu bersumber dari entitlement dan masa berlaku profil, dengan prioritas VIP. Status ini tidak menjamin notebook dapat dibuka atau composer siap. |
| `lib/core/copy_catalog.dart:900` | Dialog hapus akun menyebut penghapusan dan akses berakhir, tetapi belum membedakan hapus akun aplikasi, keluar Google, pertanyaan keamanan Google, dan pembatalan/refund transaksi. |
| `lib/services/auth_service.dart:663–739` | Hapus akun memanggil user.delete(), dapat meminta autentikasi ulang, menutup sesi/tab, dan membersihkan sesi Google lokal. Ini tindakan nyata, bukan pemecahan gangguan login. |
| `functions/src/index.ts:2847–2898` | Penghapusan Auth memicu penghapusan profil rekursif, tombstone, dan antrean pencabutan akses; sebagian jejak transaksi dipertahankan/disamarkan. Login baru setelah penghapusan tidak boleh diasumsikan otomatis memulihkan entitlement UID lama. |
| `lib/services/bookmark_service.dart` | Ada sinkronisasi penanda buku ke cloud saat login. Klaim semua data selalu hanya lokal atau tidak ada data diproses tidak sesuai implementasi. |

## Mengapa GoAkal saja belum cukup

Dokumentasi GoAkal menjelaskan API ber-kunci untuk pengelola dan webhook transaksi. Contoh webhook membawa email/telepon pembeli, produk, harga, status, dan identitas transaksi; bukan bukti sesi login Google di perangkat yang sedang membuka profil. Dalam dokumentasi yang diperiksa tidak ditemukan kontrak SSO pembeli yang dapat langsung menyatukan GoAkal, aplikasi, dan sesi situs Google. Jangan mengasumsikan fitur itu tersedia hanya karena ada endpoint API.

Kunci organisasi GoAkal wajib tinggal di server. Menaruhnya di APK akan memberi klien kewenangan membaca data transaksi organisasi. Email yang diketik pengguna, hasil pembacaan DOM, atau penanda SharedPreferences tidak cukup sebagai otorisasi server untuk membaca paket pribadi.

Alur pembayaran yang benar tetap membutuhkan: event tervalidasi → deduplikasi transaksi atomik → hak per modul dan expiry → penyediaan akses notebook → status kesiapan. Status PAID tidak sama dengan undangan notebook sudah siap. Jalur refund/chargeback, nol rupiah, pemulihan webhook tertunda, dan perpindahan identitas harus ditentukan sebelum cutover. Dokumentasi webhook publik yang diperiksa hanya menyebut event/status PAID, sehingga kemampuan lifecycle lainnya belum terbukti.

## Opsi arsitektur yang realistis

| Pilihan | Pengalaman | Batas dan keputusan |
|---|---|---|
| Pertahankan Firebase, koneksi AI saat diperlukan | Login Google aplikasi → beranda; hubungkan AI ketika dibuka jika sesi belum aktif | Paling kecil dampak migrasi. Menghilangkan gerbang dua tahap di awal, tetapi bukan jaminan satu autentikasi saat AI pertama kali digunakan. Gateway pembayaran bebas dipilih terpisah. |
| Hapus identitas aplikasi; akses notebook privat dikendalikan Google | Beranda tanpa akun → buka AI → Google memeriksa akses email | Pembayaran harus membagikan/mencabut akses pada email Google yang tepat. Profil pribadi otomatis tidak tersedia tanpa pengenal yang dapat diverifikasi. Undangan tertunda dan batas notebook tetap perlu ditangani. |
| Tanpa Firebase Auth, memakai sesi backend sendiri dan Google OIDC | Google login → server memverifikasi token → profil dan paket | Mengganti Firebase, bukan menghapus kebutuhan autentikasi. Tidak otomatis mengisi sesi Google dalam WebView; migrasi data dan keamanan bertambah. |
| Portal OpenTurath dan notebook dibuka dalam konteks browser yang sama | Satu sesi browser Google berpotensi mengurangi prompt berulang | Perlu prototipe per platform. Browser dapat memakai sesi Google yang sama, tetapi consent, pemilihan akun, dan pemeriksaan keamanan masih mungkin muncul. Tidak memindahkan cookie browser ke WebView. |

Untuk pilihan tanpa identitas aplikasi, alternatif profil ialah tautan Kelola paket di portal pembayaran yang terautentikasi, atau bukti aktivasi perangkat bertanda tangan dari server. Bukti perangkat harus dilabeli sebagai hak yang diaktifkan pada perangkat, bukan identitas akun Google yang sedang terbuka; ia tidak membuktikan keduanya sama. Bisa memerlukan langkah aktivasi/OTP tersendiri, pemulihan saat ganti HP, serta pengendalian penyalinan dan kedaluwarsa. Ini bukan satu login otomatis tanpa kompromi.

OAuth resmi aplikasi harus memakai browser/SDK yang didukung. Google melarang permintaan OAuth aplikasi melalui embedded user-agent yang dikendalikan pengembang. Jangan mengakali dengan menyuntikkan cookie, mengambil token Google dari halaman, atau membuat Firebase custom token hanya dari email DOM. Alur login pihak pertama situs Google dan otorisasi aplikasi adalah dua hal berbeda; aturan tersebut tidak otomatis membuktikan penyebab galat semua pengguna yang sekarang.

## Profil yang disarankan

Tiga bagian terpisah, masing-masing punya sumber dan waktu pemeriksaan:

1. **Identitas akun:** akun OpenTurath terverifikasi; akun Google AI terhubung/berbeda/belum terverifikasi. Jangan menampilkan akun AI sebagai sudah diverifikasi hanya dari cache atau akun Firebase.
2. **Paket per AI:** Aktif sampai [tanggal], VIP permanen, belum berlangganan, pembayaran diverifikasi, atau belum berhasil diperiksa. Server memutuskan hak; offline/timeout bukan bukti expired. VIP dan cakupan modul tetap independen.
3. **Koneksi AI:** belum dihubungkan, menghubungkan, perlu pemeriksaan Google, akses disiapkan, siap setelah pemeriksaan aktual, akses ditolak, atau gangguan koneksi. Paket aktif tidak boleh diberi label siap hanya karena invoice lunas. Hasil kesiapan satu notebook tidak digeneralisasi ke semua AI.

Contoh: Fikih Tahawwulat — paket aktif sampai [tanggal]; koneksi AI perlu dihubungkan; tindakan Hubungkan Google. Pesan tidak menuduh paket habis dan tidak menyarankan menghapus akun.

## Perbaikan privasi dan hapus akun yang diprioritaskan

- Pertahankan penjelasan baru dua tahap dan tambahkan konteks sebelum membuka halaman Google: permintaan keamanan pada halaman Google berasal dari Google; lewati hanya jika pilihan tersebut disediakan.
- Tampilkan asal halaman Google secara jelas, tanpa menyembunyikan konteks sehingga formulir Google tampak milik OpenTurath. Jangan pernah menjamin tim tidak bisa mengakses sesuatu hanya berdasarkan nama SDK; audit minimisasi data dan jalur logging tetap diperlukan.
- Profil menyediakan bantuan Saya diminta alamat/nomor pemulihan, Hubungkan ulang Google, dan Keluar sebagai tindakan yang berbeda dari penghapusan data. Pemulihan tidak boleh diam-diam membersihkan cookie.
- Dialog penghapusan menjelaskan: hanya akun OpenTurath yang dihapus, bukan akun Google; bukan cara melewati keamanan Google; konsekuensi pada akses berbayar/catatan; bukan permintaan refund. Hak penghapusan tetap mudah diakses dan tidak diblokir dengan pola antarmuka manipulatif.
- Penghapusan saat ini juga membersihkan cookie, padahal aturan workspace membatasi pembersihan global pada Log Out. Catat ini sebagai keputusan terpisah yang perlu diselaraskan secara eksplisit; audit ini tidak mengubah perilaku tersebut.
- Jangan memulihkan akun yang sengaja dihapus atau mengaitkan transaksi ke UID baru secara otomatis tanpa dasar verifikasi/persetujuan yang sesuai. Sediakan jalur bantuan pemulihan hak pembelian yang aman.
- Sesuaikan kebijakan dan pemberitahuan data jika GoAkal diaktifkan: perpindahan gateway tidak menghapus pemrosesan data; GoAkal pun membawa data kontak/transaksi.

## Urutan implementasi dan penerimaan sebelum rilis

1. Perbaiki navigasi agar sesi aplikasi aktif langsung ke beranda. Tawarkan koneksi Google saat membuka AI; jangan memodifikasi polling/viewport atau CSS room yang dilindungi.
2. Tambahkan pemisahan status profil dan bantuan privasi/hapus akun. Hasil pemeriksaan tak tersedia harus tetap tak diketahui, bukan dibuat aktif/expired.
3. Uji prototipe browser bersama untuk menentukan apakah target satu prompt layak pada Android, iOS/macOS, dan Windows. Dokumentasikan konsekuensi jika percakapan berjalan di browser eksternal.
4. Setelah pilihan identitas jelas, putuskan gateway. Jika GoAkal: siapkan kontrak transaksi/expiry/refund, dual-read hak historis dengan satu writer, simulasi webhook duplikat dan tertunda, serta rollback. Tidak merombak gateway untuk mengatasi persoalan sesi browser.
5. Sebelum rilis uji: instalasi baru; Google sudah login/belum login; banyak akun dan akun berbeda dari pembayaran; keamanan Google opsional/wajib; paket aktif tapi penyediaan tertunda; expiry satu modul sementara modul lain aktif; VIP; putus internet/timeout; webhook duplikat/refund; ganti HP; restart; logout; penghapusan dibatalkan/dikonfirmasi; pemulihan pembelian setelah penghapusan; data catatan lama. Jangan menjalankan penghapusan atau pencabutan nyata pada akun pelanggan untuk pengujian.

## Batas bukti audit

Tidak mengukur jumlah penghapusan akun atau sebabnya. Laporan pemilik adalah dasar kebutuhan produk, bukan metrik sebab-akibat terverifikasi. Tidak memeriksa data pelanggan, dashboard GoAkal, atau deployment cloud terkini. Tidak menjalankan transaksi, hapus akun, perubahan sharing, atau tes perjalanan perangkat pada turn ini. Tidak mengubah kode aplikasi, VIP, gateway, maupun publikasi. Dokumen ini adalah hasil audit yang dapat ditinjau sebelum implementasi.

## Sumber resmi yang diperiksa

- GoAkal API: https://goakal.com/docs/developer/api
- GoAkal webhook: https://goakal.com/docs/developer/webhook
- Firebase Flutter Google credential flow: https://firebase.google.com/docs/auth/flutter/federated-auth
- Verifikasi identitas Google di server: https://developers.google.com/identity/gsi/web/guides/verify-google-id-token
- Kebijakan OAuth/browser: https://developers.google.com/identity/protocols/oauth2/policies
- Keamanan token dan permintaan izin sesuai kebutuhan: https://developers.google.com/identity/protocols/oauth2/resources/best-practices
