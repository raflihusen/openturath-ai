# Firebase dan NotebookLM: diagnosis serta keputusan integrasi

## Kesimpulan yang dapat dibuktikan

NotebookLM tetap digunakan. Token Google/Firebase yang diterima aplikasi tidak membuat cookie Google pada WKWebView. Mengisi email, menulis `google_session_ready=true`, mengubah user-agent, atau memperpanjang timeout tidak menyelesaikan batas sesi tersebut.

Google menyebut browser yang diotomasi atau ditanam dalam aplikasi sebagai lingkungan yang dapat ditolak untuk login. Dokumentasi OAuth juga menjelaskan risiko `disallowed_useragent` pada WKWebView. Screenshot pengguna memperlihatkan “Something went wrong” pada halaman Google dan bantuan verifikasi perangkat/passkey; **screenshot itu tidak membuktikan kode error tersebut, kompromi akun, atau penyebab tunggal**. Yang sudah terbukti adalah penggunaan wadah serta intervensi Google yang bermasalah pada kode. [Google Account Help](https://support.google.com/accounts/answer/7675428?hl=en), [Google OAuth untuk aplikasi native](https://developers.google.com/identity/protocols/oauth2/native-app).

## Jalur sebelum perubahan

1. `LoginScreen._signIn()` pada desktop memanggil `DesktopInAppAuthDialog`, bukan jalur browser yang sudah ada di `AuthService`.
2. Dialog membuka halaman Firebase dalam WKWebView. Popup Google diarahkan kembali ke WebView yang sama; user-agent meniru Safari.
3. Halaman Google menjalankan login dan verifikasi di lingkungan embedded. Mengubah user-agent tidak mengubah lingkungan itu menjadi Safari.
4. Jika token diterima, `signInWithDesktopGoogleToken()` mengautentikasi Firebase, lalu menulis penanda sesi NotebookLM siap tanpa pemeriksaan sesi NotebookLM.
5. Saat membuka asisten, callable `getAgentUrl` memeriksa akun dan entitlement Firebase, lalu mengembalikan URL notebook.
6. Ruang asisten memuat NotebookLM di WebView. Halaman Google dapat muncul lagi karena sesi WebView berbeda dari browser sistem, atau akses notebook belum tersedia pada akun Google tersebut.
7. Callback WebView menyuntikkan email dan menekan tombol provider secara otomatis. Handler navigasi juga menulis ulang URL akun Google selama alur challenge.

Sesi Firebase, cookie Google, dan hak akses Google pada notebook merupakan tiga keadaan berbeda. Pada handler `getAgentUrl` yang diperiksa, pengembalian URL bukan pertukaran token untuk login Google dan bukan bukti hak Viewer pada NotebookLM.

## Perbaikan lokal yang diterapkan

Login desktop diarahkan ke browser sistem. Halaman hosting yang sudah tersedia mengembalikan ID token Google melalui POST ke listener loopback dengan state sekali pakai; Firebase memvalidasi credential tersebut. Token tidak ditambahkan ke URL callback atau preferensi oleh jalur ini. Ini bukan implementasi native authorization-code PKCE; jangan melabelinya demikian.

Halaman masuk sekarang memakai `open-turath.firebaseapp.com`, sesuai `authDomain` pada helper hosting yang diperiksa. GET pada halaman `web.app` dan `firebaseapp.com` sama-sama menghasilkan HTTP 200 dengan penanda versi v3. Pemeriksaan HTTP ini hanya membuktikan halaman tersedia. Firebase menjelaskan masalah penyimpanan lintas domain pada redirect dan pengecualian bagi hosting `firebaseapp.com`. [Firebase: praktik redirect sign-in](https://firebase.google.com/docs/auth/web/redirect-best-practices).

Penanda sesi NotebookLM tidak lagi dibuat dari token Firebase. Intervensi form dan URL Google pada ruang asisten dihapus. Pengguna tidak diminta mengurangi pengamanan Google atau memindahkan cookie browser ke aplikasi.

**Batas hasil:** ruang NotebookLM aktif masih memakai WebView. Perbaikan Firebase tidak membuat sesi browser sistem berpindah ke sana. Keberhasilan kompilasi dan tes tidak membuktikan satu login berhasil sampai percakapan NotebookLM.

## Pilihan wadah, dengan NotebookLM tetap wajib

| Arah | Peluang sesi bersama | Konsekuensi UI dan integrasi |
| --- | --- | --- |
| Desktop memakai browser yang didukung, dengan arah aplikasi web/PWA | Firebase web dan NotebookLM dapat memakai sesi Google pada browser/profil yang sama | NotebookLM perlu navigasi top-level atau jendela browser tersendiri. PWA tidak otomatis mengizinkan iframe atau penyatuan origin Google dengan OpenTurath. Perlu prototipe packaging nyata. |
| Desktop tetap Flutter; NotebookLM dibuka pada browser yang didukung | Sesi Google dapat dipakai ulang jika autentikasi dan notebook benar-benar menggunakan browser/profil yang sama | Flutter tetap menjadi pengelola pustaka, catatan, dan akses. Ruang NotebookLM tidak memakai WKWebView; transisi dan kembali ke OpenTurath perlu dirancang. |
| Android memakai Custom Tabs untuk konten Google | Custom Tabs berbagi state/cookie dengan browser yang menyediakannya | Integrasi login Firebase harus diuji pada browser yang sama; token Google Sign-In SDK saja tidak membuktikan browser punya sesi. Custom Tabs tidak menawarkan injeksi DOM seperti WebView. |
| Flutter + WKWebView tetap menjadi wadah seluruh login dan NotebookLM | Tidak ada jalur resmi yang ditemukan untuk menjamin satu autentikasi dari token Firebase menuju cookie NotebookLM | Login Google embedded dapat tetap ditolak. Ini bukan arah yang dapat saya nyatakan memenuhi kedua persyaratan. |

Google menyarankan browser OAuth atau migrasi PWA kepada pembuat aplikasi desktop yang memakai CEF. Ini juga berarti mengganti WKWebView dengan Electron/CEF saja tidak menyelesaikan masalah. Custom Tabs Android mempunyai cookie jar bersama dengan browser; karakteristik itu berbeda dari WebView. [Google Account Help](https://support.google.com/accounts/answer/7675428?hl=en), [Chrome: Custom Tabs](https://developer.chrome.com/docs/android/custom-tabs).

Pada Apple, `ASWebAuthenticationSession` menerima callback autentikasi dari layanan yang mendukungnya. Itu bukan API untuk memasukkan sesi situs pihak ketiga ke WKWebView. NotebookLM konsumen tidak menyediakan callback aplikasi milik OpenTurath yang ditemukan dalam penelitian ini. [Apple: ASWebAuthenticationSession](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession), [WebKit: pilihan untuk autentikasi](https://webkit.org/blog/10882/app-bound-domains/).

**Rekomendasi:** prototipekan desktop berbasis browser yang didukung, mempertahankan NotebookLM sebagai layanan sebenarnya dan OpenTurath sebagai pengelola kajian. Jika sidebar harus mendampingi NotebookLM pada origin Google, kemampuan tambahan seperti ekstensi browser perlu dibahas dan diuji tersendiri; jangan menganggap iframe atau script dari origin OpenTurath akan mendapat akses tersebut. Pilihan wadah telah ditanyakan kepada pengguna dan belum disetujui pada saat dokumen ini ditulis.

Targetnya satu autentikasi Google yang digunakan kembali, bukan satu token yang mengautentikasi semua layanan. Pemilihan akun, consent pertama, atau verifikasi yang diwajibkan Google tidak boleh disembunyikan atau dianggap dapat dihapus oleh aplikasi.

## NotebookLM Enterprise

NotebookLM Enterprise memiliki API resmi untuk pengelolaan notebook dan dukungan identitas organisasi. Itu tidak membuat URL NotebookLM konsumen yang sekarang dipakai menerima Firebase token. Dokumentasi API yang diperiksa membahas create/get/list/delete/share, bukan kontrak chat konsumen yang menyelesaikan integrasi ini. Enterprise juga memerlukan konfigurasi organisasi, IAM, dan lisensi. Tidak ada migrasi Enterprise atau penggantian mesin yang dijalankan. [API NotebookLM Enterprise](https://docs.cloud.google.com/gemini/enterprise/notebooklm-enterprise/docs/api-notebooks), [penyiapan identitas Enterprise](https://docs.cloud.google.com/gemini/enterprise/notebooklm-enterprise/docs/set-up-notebooklm).

## Cara membuktikan “satu login”

Sebelum menyatakan selesai, jalankan alur pada paket nyata dan browser yang dipilih:

1. Mulai dengan satu akun uji dan profil browser yang diketahui. Autentikasi Google dilakukan oleh pengguna, lalu pastikan Firebase mengenali UID yang benar.
2. Buka notebook yang memang sudah dibagikan kepada akun itu. Pastikan percakapan tersedia; bukan hanya halaman muka NotebookLM atau flag preferensi.
3. Pindah modul, tutup/buka aplikasi, dan pastikan sesi dipakai kembali tanpa membuat cookie store baru.
4. Dengan dua akun Google, periksa bahwa akun Firebase dan akun NotebookLM yang dipakai sesuai. Parameter email pada URL hanya petunjuk, bukan bukti identitas atau hak akses.
5. Pisahkan penolakan entitlement OpenTurath dari penolakan hak akses notebook Google. Keduanya membutuhkan penanganan berbeda.
6. Uji pembatalan, timeout, sesi kedaluwarsa, dan kembali ke aplikasi. Jangan melaporkan sesi siap setelah pengguna sekadar membuka browser.
7. Keluar OpenTurath harus menghentikan akses aplikasi dan membersihkan data akun yang dimilikinya. Jangan menjanjikan tindakan itu juga mengeluarkan seluruh sesi Google pada browser milik pengguna.

Catat browser/profil/platform, hasil setiap tahap, serta error yang sudah disanitasi. Jangan simpan token, password, kode verifikasi, cookie Google, atau screenshot akun pribadi dalam laporan.

## Keadaan implementasi

- Jalur login Firebase desktop yang lebih tepat: diterapkan dan dikompilasi secara lokal.
- Penanda kesiapan NotebookLM palsu dan otomatisasi halaman Google aktif: dihapus.
- UI baru: pratinjau interaktif; belum diterapkan menyeluruh pada Flutter.
- Migrasi wadah NotebookLM: belum dijalankan, menunggu keputusan pengguna.
- Login Firebase → notebook dengan satu autentikasi pada paket baru: belum diverifikasi.
- Deployment hosting, broadcast rilis, perubahan ACL notebook, dan upload sumber: tidak dilakukan dalam pekerjaan ini.
