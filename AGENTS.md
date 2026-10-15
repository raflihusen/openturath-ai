# Workspace Rules — OpenTurath AI

## 1. Automatic Checkpoint Protocol (MANDATORY)
- **Setiap perubahan sekecil apapun WAJIB langsung dibuatkan check point (Git commit) secara otomatis.**
- Setiap kali file kode, aset, UI, konfigurasi, atau unit test dimodifikasi atau ditambahkan:
  1. Jalankan `git add <files>`
  2. Lakukan commit dengan pesan yang deskriptif dan terstruktur: `git commit -m "<type>(<scope>): <pesan detail perubahan>"`
- Jangan pernah membiarkan perubahan menumpuk tanpa check point.
- Check point harus selalu dibuat secara otomatis tanpa menunggu instruksi tambahan dari pengguna.

## 2. Integritas Build & Release
- Setiap pembuatan APK rilis harus memverifikasi bahwa proses kompilasi Gradle selesai 100% dan file binary rilis yang disalin ke `/Users/apple/Downloads/ramadhan/app-release-latest.apk` memiliki timestamp baru yang valid.

## 3. Pemisahan Build Lokal & Broadcast Rilis Publik (MANDATORY)
- Kompilasi APK (`flutter build apk --release`) bersifat lokal semata untuk keperluan pengujian, verifikasi, atau audit internal.
- DILARANG KERAS memicu pengunggahan APK ke CDN / Firebase Hosting maupun menyiarkan versi rilis baru ke Firestore (`app_config/version`) secara otomatis setiap kali APK selesai dikompilasi.
- Otomasi broadcast update (`publish_auto_update.py`) HANYA BOLEH dijalankan jika pengguna memberikan instruksi eksplisit secara langsung (misalnya: *"updatein dong"*, *"rilis update sekarang"*, atau sejenisnya).

## 4. Standar Preservasi Format Ideal WebView (MANDATORY)
- **DILARANG MERUSAK ATAU MENGUBAH LOGIKA SIKLUS HIDUP WEBVIEW** di `openturath_ai/lib/widgets/agent_multi_tab_room.dart` dan `desktop_webview_runtime.dart`.
- Logika kestabilan polling kesiapan sesi NotebookLM (Angular SPA) **WAJIB mempertahankan minimal 4 sampel berturut-turut (2 detik), elapsed waktu minimum 3000ms, dan jeda mikro 250ms**. Dilarang memotongnya menjadi 1-2 sampel demi alasan kecepatan semu karena memicu layout flicker/blank DOM.
- Tampilan galat (**error state**) **WAJIB menggantikan seluruh viewport WebView secara bersih** (`return ColoredBox(color: canvas, child: state)`). Dilarang keras menumpuk platform view `InAppWebView` di bawah overlay `Positioned.fill` saat galat terjadi.
- Dokumen rujukan teknis permanen: `openturath_ai/docs/STANDAR_IDEAL_WEBVIEW.md`.

## 5. Hukum Sakral VIP & Standar Ekspirasi (MANDATORY)
- **YANG VIP ADALAH VIP SEJATI.** Semua akun yang terdaftar di `STATIC_WHITELIST`, `is_vip: true`, `role: "vip"`, atau dokumen `VIP_PERMANENT` (seperti `prilatief@gmail.com`, `alkhateeb23@gmail.com`, `omarasb1441@gmail.com`, Asatidz, Masyayikh, dan tamu kehormatan) adalah hak prerogatif mutlak Pemilik (Owner). **DILARANG KERAS meragukan, menganggapnya kesalahan, atau mencoba mencabut akun VIP.**
- **Hak Akses Granular Per-Modul:** Pengguna yang memiliki paket aktif di modul tertentu (misalnya Fikih Tahawwulat 1 Tahun) DILARANG KERAS dicabut dari notebook modul tersebut hanya karena paket di modul lain (Fikih Syafi'i) kedaluwarsa. Evaluasi hak akses WAJIB independen per-modul.
- **Anti-Ghost Sync & Idempotensi:** Webhook atau skrip sinkronisasi dilarang menambahkan durasi berlangganan berulang kali (*compounding loop*) tanpa memeriksa keunikan transaksi (`transaction_id`). Transaksi dengan `amount: 0.0` tidak boleh memicu perpanjangan otomatis tanpa verifikasi admin.
- **Deteksi Kedaluwarsa Presisi:** Evaluasi hak akses wajib memvalidasi transaksi riil, bukan semata-mata membaca field profil yang berpotensi korup. User dengan paket 1 bulan yang telah melewati masa 30 hari WAJIB dideteksi sebagai expired.
- **Sinkronisasi Master Notebook:** Skrip reaper WAJIB memantau Master Notebook aktif `01 - FIKIH SYAFII (MASTER)` (`c89d09ca-4b48-4000-a98d-59e532607fb6`), bukan hanya notebook legacy.
- Dokumen rujukan permanen: `DOKUMENTASI_KECACATAN_SISTEM_DAN_ATURAN_VIP.md`.

## 6. Standar Baku Bebas Bar & Scrim WebView — Gold Standard Syafi'i (MANDATORY)
- **TOLOK UKUR IDEAL TAMPILAN WEBVIEW ADALAH FIKIH SYAFI'I.** Teks dan tabel obrolan WAJIB rapat ke bawah bilah tab Flutter (0px celah putih, tanpa jeda bar kosong 64px, tanpa top scrim pudar).
- Seluruh elemen header Google/NotebookLM (`app-chat-header`, `app-conversation-header`, `app-chat-panel-header`, `mat-toolbar`, `top-bar`, `.top-scrim`, `.scroll-scrim`, `[class*="scrim" i]`, `[class*="gradient" i]`, `[class*="fade-overlay" i]`, `mat-tab-header`) WAJIB dieliminasi dengan aturan CSS independen murni berdimensi nol (`display: none !important; height: 0 !important; padding: 0 !important; margin: 0 !important;`).
- Dilarang menggabungkan selektor `:has(...)` ke dalam blok koma aturan penghilang bilah utama karena kegagalan parsing mesin WebKit akan menggugurkan seluruh aturan penyembunyian.
- Wadah percakapan (`app-chat-view`, `main`, dll) WAJIB menonaktifkan `-webkit-mask-image: none !important; mask-image: none !important;` serta pseudo-elemen `::before`/`::after` untuk mencegah teks atas pudar terpotong.
- Setiap pergantian tab aktif WAJIB memanggil pembersihan instan `clean()` agar tab yang baru aktif langsung rapat dan bebas bar.
- Dokumen rujukan teknis mutlak: `openturath_ai/docs/STANDAR_IDEAL_WEBVIEW.md`.

## 7. Hak Multi-Tab & Non-Destructive Session (MANDATORY)
- Pada lingkungan desktop (macOS), aplikasi WAJIB mengizinkan hingga **minimal 5 tab aktif bersamaan** (`maxTabs = 5`) untuk mendukung komparasi lintas disiplin/kitab turats.
- DILARANG KERAS menutup paksa tab yang sedang dibuka pengguna secara senyap (*silent auto-eviction*) di bawah batas maksimum.

## 8. Standar Sakral Sesi Google & Anti-Tamper Cookie (MANDATORY)
- Mesin WebKit macOS (`WKHTTPCookieStore`) mengelola persistensi cookie Google ke disk secara bawaan dan permanen.
- DILARANG KERAS menimpa (*overwrite/tamper*) token sesi Google yang sedang aktif di WebKit (khususnya `__Secure-1PSIDTS`, `__Secure-3PSIDTS`, `SID`, `HSID`) dengan atribut buatan (`expiresDate` palsu atau `SameSite=None`), karena memicu mekanisme pertahanan DBSC Google Frontend yang mencabut sesi dan memaksa status *Signed out* pada semua akun.
- Pembersihan sesi global (`deleteAllCookies` / `clearSession`) HANYA BOLEH dijalankan ketika pengguna secara sadar dan eksplisit menekan tombol **Log Out / Keluar** di Pengaturan Akun. Dilarang membersihkan cookie saat inisialisasi aplikasi atau saat membuka tab baru.

## 9. Hak Paten Desain Hitam-Putih Monokrom (MANDATORY)
- Bahasa desain OpenTurath AI adalah **Monochrome Editorial — The Quiet Islamic Scholar**.
- Seluruh elemen antarmuka (kartu langganan *Bithāqah Al-Intisāb*, dialog, tombol, dan lembar pembayaran) WAJIB mempertahankan estetika monokrom obsidian murni (#09090B, #18181B, #27272A, #FAFAFA). Dilarang menyisipkan aksen warna oranye, kuning, atau warna kontras lain yang merusak keheningan visual scholarly.


