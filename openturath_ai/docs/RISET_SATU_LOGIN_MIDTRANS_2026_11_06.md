# Riset satu perjalanan login Google dengan Midtrans

Tanggal: 6 November 2026. Status: usulan teknis berdasarkan kode dan dokumentasi; belum diimplementasikan atau diuji dengan akun/perangkat pada pekerjaan ini.

## Kesimpulan

Midtrans dan Firebase dapat dipertahankan. Perubahan yang diperlukan ialah menyatukan konteks browser untuk otorisasi Google aplikasi dan penggunaan situs AI. Firebase tetap mengidentifikasi pemilik paket di belakang layar. Tidak ditemukan mekanisme resmi yang membuat hasil OAuth native otomatis mengisi cookie Google di WebView biasa.

Target yang realistis: satu perjalanan login pengguna pada alur normal, tanpa layar login Google kedua yang diwajibkan aplikasi. Bukan jaminan tidak pernah muncul consent, pilihan akun, 2FA, atau pemeriksaan keamanan Google. Satu browser profile juga dapat berisi banyak akun; pemilihan akun untuk AI harus diuji.

## Fondasi yang benar-benar ada

| Kode | Fungsi dan batas |
|---|---|
| `public/workspace/workspace.mjs:88–108` | Firebase Web Google popup/redirect dan browserLocalPersistence. |
| `public/workspace/workspace.mjs:111–130` | Pembuatan/pembacaan profil UID Google dan panggilan getAgentUrl. |
| `public/workspace/model.mjs:4–18` | Validasi tautan notebook dan hint authuser; hint bukan bukti pemilik sesi. |
| `lib/services/browser_workspace_launcher.dart:44–50` | Peluncur portal ke browser eksternal. |
| `lib/services/desktop_auth_gateway.dart:109–188` | Windows sudah memiliki OAuth browser eksternal, loopback, dan PKCE. Sesi browser tersebut tetap terpisah dari WebView2. |
| `functions/src/index.ts:902–975` | Checkout Midtrans mengikat invoice ke UID server dan identitas token terverifikasi. |
| `functions/src/index.ts:1722–1762` | Pemeriksaan pembayaran menolak transaksi milik UID lain. |
| `functions/src/index.ts:246–330` | Alamat AI diperoleh berdasarkan UID, profil, email terverifikasi, dan hak modul/VIP. |

Workspace saat ini belum memiliki checkout Midtrans, inquiry, dan profil paket lengkap. Peluncur browser tidak memindahkan login ke aplikasi native. Deployment, authorized domains, App Check, dan perjalanan nyata portal belum diverifikasi pada riset ini. Fondasi tersebut bukan fitur satu-login yang telah selesai.

## Pilihan yang direkomendasikan

### Tahap A: prototipe terkecil dalam satu browser

1. Pengguna membuka workspace OpenTurath di browser yang didukung; pada Android dapat memakai Custom Tab non-ephemeral dari browser yang dipilih.
2. Pengguna masuk Google melalui Firebase Web di proyek yang sama. Firebase menautkan ke record Google yang ada; tidak ada pendaftaran akun OpenTurath dengan password terpisah.
3. Workspace membaca profil/paket dan memanggil fungsi Midtrans yang ada. Tambahkan UI checkout/inquiry menggunakan otorisasi UID yang sama; jangan menggandakan writer pembayaran atau ledger.
4. Setelah entitlement dan penyediaan akses siap, notebook privat dibuka pada browser/profile yang sama. Jangan meluncurkan aplikasi Notebook native atau browser lain otomatis karena dapat mengubah konteks akun/sesi.
5. Kembali ke workspace memakai sesi Firebase browser yang sudah ada. Profil menunjukkan paket dan waktu pemeriksaan, bukan mengklaim kesiapan AI hanya karena tautan telah dibuka.

Prototipe ini sengaja tidak memerlukan sinkronisasi login native dulu. Ia membuktikan komponen paling penting: Google sign-in, status paket, pembayaran, dan jawaban AI dalam konteks browser yang sama. Custom Tabs tidak menyediakan kendali CSS/DOM atas situs Google seperti WebView saat ini.

### Tahap B: profil aplikasi native ikut aktif tanpa login Google tambahan

Desain berikut adalah komposisi yang diusulkan, bukan kemampuan turnkey yang sudah ada dalam proyek:

1. Aplikasi membuat permintaan login dengan state acak dan challenge yang terikat rahasia lokal/verifier. Buka portal HTTPS milik OpenTurath dalam browser yang dipilih. Pengikatan ini tidak mengganti perlindungan OAuth Firebase/Google; keduanya diperlukan pada lapis yang sesuai.
2. Portal menyelesaikan Firebase Google sign-in. Server memverifikasi Firebase ID token dan mengambil UID dari token terverifikasi, bukan email/UID yang dikirim sebagai klaim biasa.
3. Server mengeluarkan kode handoff opaque sekali pakai, terikat permintaan/perangkat, UID, dan TTL pendek. Usulan awal TTL 60–120 detik harus diuji untuk aksesibilitas dan kestabilan; bukan batas resmi Firebase.
4. Aplikasi menerima kode melalui callback yang tervalidasi atau polling hasil yang dilindungi challenge. Native menukar kode lewat HTTPS dengan verifier. Konsumsi atomik mencegah replay; callback kedaluwarsa atau callback dari sesi lama dibuang.
5. Server dapat menerbitkan Firebase custom token untuk **UID yang sama**; SDK native memakai signInWithCustomToken tanpa UI Google. Bearer token tidak dimasukkan ke deep link, query, fragment, log, analytics, atau clipboard. Endpoint minting hanya dapat dipakai setelah pembuktian sesi dan request asal.
6. Native membaca profil, paket, VIP, dan transaksi dari akun yang sama. Saat AI dibuka, tetap gunakan browser/profile yang digunakan pada tahap login. Tidak ada perpindahan cookie ke WebView.

Admin custom token mengubah `sign_in_provider` menjadi custom. Fungsi yang diperiksa sekarang terutama mengandalkan UID dan email terverifikasi, tetapi hasil ID token/user tetap harus diuji: email, email_verified, providerData Google, Google sub, rules, dan getAgentUrl. Jangan melonggarkan gate identitas atau memalsukan reserved claims. Untuk pelanggan lama pertahankan mapping provider Google dan UID; jangan membuat UID baru dari email. Akun yang sengaja dihapus tidak otomatis dipulihkan.

Jika memakai OAuth server langsung, verifikasi token Google dan cari record berdasarkan provider google.com + Google sub. Pemilihan desain OAuth/redirect harus sesuai platform; jangan menggunakan loopback desktop untuk Android/iOS atau menaruh rahasia web-server dalam APK. Prioritaskan pola SDK/server yang didukung daripada alur OAuth buatan sendiri.

## Pekerjaan pendukung wajib

- Mobile Firebase redirect mengikuti panduan third-party-storage dan auth helper pada origin yang benar; jangan membuat loop login pada Safari/Chrome.
- Workspace belum menginisialisasi App Check, sementara appCheckGate backend bisa diberlakukan melalui konfigurasi. Integrasikan attestation yang sesuai untuk web dan uji enforcement; jangan mematikan gate agar portal lolos.
- Browser/provider yang dipakai untuk login dan AI harus konsisten dan terlihat oleh pengguna. Google account chooser boleh muncul bila banyak akun; akun browser tidak ditentukan hanya dari parameter authuser.
- Midtrans tetap server-side: invoice, nominal server, verifikasi notifikasi/status, idempotensi, ownership transaksi, dan penyediaan akses. Redirect pembayaran bukan bukti lunas.
- State profil memisahkan akun aplikasi, paket per AI, penyediaan notebook, dan koneksi AI. Membuka URL di browser bukan bukti aplikasi telah mengamati jawaban/composer browser tersebut.
- Cookie situs tetap di browser dan tidak diekspor. Firebase native/browser merupakan sesi aplikasi yang terpisah, dihubungkan melalui identitas terverifikasi, bukan melalui pemindahan cookie.
- Penyimpanan native yang masih memakai UID lama dipertahankan. VIP/per-modul tidak diubah, pembayaran tidak dimigrasikan, dan refund bukan bagian dari pekerjaan ini.

## Batas jika ruang AI wajib tetap di WebView sekarang

Dengan WebView custom saat ini, satu proses OAuth aplikasi belum otomatis membuat sesi situs Google di WebView. Memulai login situs dahulu juga tidak memberikan token identitas aplikasi yang dapat diverifikasi hanya dengan membaca email halaman. Silent Google sign-in dapat membantu pada perangkat tertentu, tetapi bukan jaminan satu login untuk instalasi baru atau akun yang berbeda.

Browser companion desktop dalam proyek memakai protokol web Notebook yang tidak terdokumentasi dan belum didukung Android/iOS; backend native chat juga masih prototipe terbatas. Keduanya tidak dijadikan solusi rilis final. API Google Notebook resmi sudah ada, tetapi REST yang diperiksa belum menyediakan chat, sehingga belum menjadi dasar pengganti chat WebView yang didukung.

Pilihan produk yang jujur: (a) browser-owned AI untuk satu konteks sesi; (b) WebView custom dengan kemungkinan koneksi terpisah; atau (c) chat native berbasis API yang benar-benar mendukung kebutuhan, sebagai proyek berbeda. Midtrans tetap bisa dipakai pada ketiganya.

## Bukti sebelum implementasi luas

Uji prototipe dengan akun uji pada POCO/Android: instalasi baru, Google belum/sudah login, dua akun A/B, cancel, 2FA/recovery, provider browser berubah, restart, sesi dicabut, paket aktif/tidak aktif, VIP, dan expiry berbeda per modul. Tuntaskan satu jawaban AI dalam konteks browser yang sama.

Untuk handoff: UID sebelum/sesudah sama; callback salah/ulang/kedaluwarsa ditolak; logout/account switch mengalahkan callback terlambat; email terverifikasi/rules tidak dilonggarkan; code/token tidak bocor; profil native dan browser konsisten. Uji checkout Midtrans sandbox, notifikasi duplikat, inquiry, kepemilikan invoice, serta aktivasi. Tidak memakai pembayaran/penghapusan nyata pelanggan sebagai eksperimen.

Tidak menjanjikan UI custom WebView tetap identik setelah pindah ke browser. Prototipe terisolasi dan tinjauan UX harus mendahului perubahan default. Tidak ada deploy, konfigurasi cloud, transaksi, atau publikasi dilakukan dalam riset ini.

## Sumber resmi

- Firebase Google web sign-in: https://firebase.google.com/docs/auth/web/google-signin
- Firebase redirect best practices: https://firebase.google.com/docs/auth/web/redirect-best-practices
- Firebase custom token: https://firebase.google.com/docs/auth/admin/create-custom-tokens
- Flutter custom auth: https://firebase.google.com/docs/auth/flutter/custom-auth
- Firebase provider UID lookup: https://firebase.google.com/docs/reference/admin/node/firebase-admin.auth.baseauth
- Android Custom Tabs: https://developer.chrome.com/docs/android/custom-tabs
- Android browser/WebView session distinction: https://developer.android.com/develop/ui/views/layout/webapps/in-app-browsing-embedded-web
- Google desktop OAuth: https://developers.google.com/identity/protocols/oauth2/native-app
- Google ID token verification: https://developers.google.com/identity/gsi/web/guides/verify-google-id-token
- Midtrans notifications: https://docs.midtrans.com/docs/https-notification-webhooks
- Notebook REST: https://developers.google.com/notebook/reference/rest
