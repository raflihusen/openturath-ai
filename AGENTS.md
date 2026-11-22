# Workspace Rules — OpenTurath AI

> **Pembaruan Terakhir:** 22 November 2026 · **Arsitektur Aktif:** VPS Mandiri (`maktabah.openturath.id`) + Direct Release (APK / DMG / EXE) tanpa Google Play Store dan tanpa ketergantungan utama pada Firestore/Cloud Functions.

## 0. Arsitektur Mandiri VPS & Direct Release (KONTEKS WAJIB)
- **Otoritas Tunggal Backend:** Seluruh akun, status langganan (`/api/user-status`), katalog harga dinamis (`/api/v1/catalog/offers`), daftar agen aktif (`/api/v1/config/agents`), penugasan URL notebook (`/api/getAgentUrl`), webhook Midtrans, dan worker sharing/reaper NotebookLM berjalan di **VPS mandiri `maktabah.openturath.id`** (24 Master Notebook aktif milik `hus180402@gmail.com`).
- **Distribusi Independen:** Aplikasi didistribusikan langsung (Direct Release APK Android, DMG macOS, EXE/ZIP Windows) tanpa Google Play Store. Oleh karena itu:
  - Izin `REQUEST_INSTALL_PACKAGES` dan mekanisme OTA self-update di Android/desktop adalah **fitur resmi**, bukan cacat.
  - Pembayaran langsung via Midtrans / QRIS / Transfer Bank / WhatsApp di dalam aplikasi adalah **alur resmi** (bukan pelanggaran kebijakan toko pihak ketiga).
  - Jangan membuat rekomendasi perbaikan yang mengasumsikan kepatuhan Google Play Billing atau migrasi wajib ke Cloud Functions/Firestore.

## 1. Automatic Checkpoint Protocol (MANDATORY)
- **Setiap perubahan sekecil apa pun WAJIB langsung dibuatkan checkpoint (Git commit) secara otomatis.**
- Setiap kali file kode, aset, UI, konfigurasi, dokumentasi, atau unit test dimodifikasi atau ditambahkan:
  1. Jalankan `git add <files>` (stage hanya file yang relevan dengan pekerjaan saat ini; jangan ikutkan file tidak terkait yang sudah kotor di working tree).
  2. Lakukan commit dengan pesan deskriptif dan terstruktur: `git commit -m "<type>(<scope>): <pesan detail perubahan>"`.
- Jangan membiarkan perubahan menumpuk tanpa checkpoint.

## 2. Integritas Build & Release
- Setiap kompilasi biner rilis (APK / DMG / EXE) wajib memverifikasi proses build selesai 100%, biner disalin ke jalur distribusi resmi (mis. `/Users/apple/Downloads/ramadhan/app-release-latest.apk`, `OpenTurath_AI_macOS.dmg`), dan file checksum `.sha256` selalu disinkronkan dengan biner fisiknya.
- Pastikan tidak ada harga tes (seperti Rp 1.000) yang tertinggal di klien (`product_pricing.dart`, `constants.dart`, `agent_model.dart`) maupun di VPS (`/api/v1/catalog/offers`) sebelum build rilis publik.

## 3. Pemisahan Build Lokal & Broadcast Rilis Publik (MANDATORY)
- Kompilasi biner lokal (`flutter build apk --release`, `flutter build macos --release`) bersifat lokal untuk pengujian dan verifikasi internal.
- DILARANG KERAS mengunggah biner ke CDN/hosting atau menyiarkan versi rilis baru ke endpoint update publik secara otomatis setelah build.
- Broadcast update publik (`publish_auto_update.py` atau update manifest VPS) HANYA BOLEH dijalankan atas instruksi eksplisit pengguna.

## 4. Standar Siklus Hidup & Kecepatan WebView (MANDATORY)
- **Cepat, Bebas Flicker, Anti False-Positive:**
  - `AgentService.getAgentUrl` menggunakan pola *stale-while-revalidate* melalui sticky cache (`ot_assigned_notebook_v1_<email>|<agentId>`) agar tab AI terbuka instan sambil menyegarkan URL kloning dari VPS di latar belakang.
  - Deteksi kesiapan WebView di `agent_multi_tab_room.dart` tidak boleh memakai jeda tunggu artifisial berdetik-detik yang memperlambat pembukaan tab, dan deteksi `accessDenied` wajib menghindari *false-positive* dari teks fikih/jawaban di dalam transkrip.
- **Error State Bersih:** Tampilan galat (**error state**) WAJIB menggantikan seluruh viewport WebView secara bersih (`return ColoredBox(color: canvas, child: state)`). Dilarang menumpuk platform view `InAppWebView` di bawah overlay `Positioned.fill` saat galat terjadi.
- Dokumen rujukan teknis: `openturath_ai/docs/STANDAR_IDEAL_WEBVIEW.md`.

## 5. Hukum Sakral VIP, Paket `all_specialists` & Standar Ekspirasi (MANDATORY)
- **YANG VIP ADALAH VIP SEJATI.** Semua akun yang terdaftar di `_canonicalVipEmails`, `STATIC_WHITELIST`, `is_vip: true`, atau `role: "vip"` adalah hak prerogatif mutlak Pemilik. **DILARANG KERAS meragukan atau mencabut akses akun VIP.**
- **Hak Akses Granular Per-Modul & Paket `all_specialists` (`Semua AI`):**
  - Evaluasi hak akses WAJIB independen per-modul. Kedaluwarsanya satu modul tidak boleh mencabut modul lain yang masih aktif.
  - Paket **`all_specialists`** (judul resmi: **`Semua AI`**, tanpa `*` dan tanpa awalan `"AI "` ganda) mencakup **seluruh 19 Master Notebook disiplin keilmuan aktif KECUALI `fiqh_tahawwulat`** (beserta 5 sub-agennya: `06.1–06.5`).
  - Baik klien (`UserModel.isAgentSubscriptionActive`, `ModuleEntitlement.isPremium`, `ProfileScreen._entitlementTitle`) maupun backend VPS (`/api/getAgentUrl`, `/api/user-status`, `reaper_worker.py`, `access_policy.py`) WAJIB mengakui `all_specialists` untuk semua disiplin non-Tahawwulat dan tetap mengisolasi `fiqh_tahawwulat`.
  - ID bundel virtual (`all_specialists`, `all_disciplines`) tidak boleh dibuka sebagai satu tab notebook tunggal.
- **Idempotensi Transaksi:** Webhook pembayaran dilarang menambahkan durasi berulang kali (*compounding loop*) tanpa deduplikasi `transaction_id`, dan transaksi `amount <= 0` dilarang memicu aktivasi otomatis.

## 6. Standar Baku WebView — Bebas Bar, Tipografi Ibarah, Bidi & Natural Composer (MANDATORY)
- **Bebas Bar & Scrim:** Teks dan tabel obrolan WAJIB rapat ke bawah bilah tab Flutter (0px celah putih, tanpa top scrim pudar). Elemen header Google/NotebookLM (`app-chat-header`, `app-conversation-header`, `app-chat-panel-header`, `mat-toolbar`, `.top-scrim`, `[class*="scrim" i]`, `mat-tab-header`) dieliminasi dengan aturan CSS independen non-`:has(...)` berdimensi nol, dan `-webkit-mask-image` dinonaktifkan pada wadah percakapan.
- **Kesetaraan Ukuran Font Ibarah & Bidi Universal:**
  - Ukuran font kutipan Arab (`.ot-ibarah`) WAJIB **sama** dengan ukuran teks jawaban utama (dengan CSS specificity yang konsisten di `notebook_skin.dart` dan `agent_multi_tab_room.dart`), sehingga saat pengguna memperbesar/memperkecil ukuran teks, ibarah ikut terskala seragam.
  - Arsitektur deteksi Bidi universal, pemisah segmen ibarah anti-streaming-bug, dan tabel responsif wajib dijaga tetap utuh.
- **Natural Flexbox In-Flow Composer:** Wadah input pertanyaan (`.ot-chat-composer`) WAJIB terpasang alami di dasar kolom percakapan (*Natural Flexbox In-Flow Docking*, `position: relative`, `flex: 0 0 auto`, terpusat presisi di `max-width: 720px` selaras dengan `.rendered-markdown`). Dilarang memakai `position: fixed` yang menutupi pesan terbawah.
- Setiap pergantian tab aktif WAJIB memanggil pembersihan instan `clean()`.

## 7. Hak Multi-Tab & Non-Destructive Session (MANDATORY)
- Pada desktop (macOS/Windows), aplikasi WAJIB mengizinkan hingga **minimal 5 tab aktif bersamaan** (`maxTabs = 5`) untuk komparasi lintas kitab/disiplin.
- DILARANG KERAS menutup paksa tab yang sedang dibuka pengguna secara senyap di bawah batas maksimum.

## 8. Standar Sakral Sesi Google & Anti-Tamper Cookie (MANDATORY)
- Mesin WebKit macOS (`WKHTTPCookieStore`) mengelola persistensi cookie Google secara bawaan.
- DILARANG KERAS memutasi/menimpa live cookie sesi Google di WebKit (khususnya `__Secure-1PSIDTS`, `__Secure-3PSIDTS`, `SID`, `HSID`) dengan atribut buatan (`expiresDate` palsu atau `SameSite=None`), karena memicu pertahanan DBSC Google Frontend dan mencabut sesi (*Signed out*). `lockAndPersistCookies()` harus tetap read-only terhadap WebKit.
- Pembersihan sesi global (`deleteAllCookies` / `clearSession`) HANYA BOLEH dijalankan saat pengguna secara eksplisit menekan **Log Out / Keluar** atau saat pemilik akun aplikasi benar-benar berganti.

## 9. Hak Paten Desain Hitam-Putih Monokrom & Standar Checkout (MANDATORY)
- Bahasa desain OpenTurath AI adalah **Monochrome Editorial — The Quiet Islamic Scholar** (palet tinta & kertas via token `OTColors`, tanpa warna oranye/kuning/emas/neon; hanya merah galat `OTColors.destructive` untuk error dan aksi permanen).
- **Layar Langganan (`subscription_screen.dart`):**
  - Penamaan paket bundel resmi adalah **`Semua AI`** (tanpa `*` dan tanpa awalan `"AI "` ganda), dengan keterangan *"Kecuali Fikih Tahawwulat"* di bawah judul.
  - Kartu **Semua AI** ditonjolkan secara monokrom editorial sebagai *Pilihan Terbaik* (bingkai `1.8px`, gradasi tonal halus, lencana solid, strip perbandingan nilai vs satuan, tombol `FilledButton`), sementara paket satuan memakai `OutlinedButton` yang lebih tenang.
- **Checkout & Dialog Sukses (`payment_checkout_sheet.dart`, `payment_success_dialog.dart`, `access_prepare_gate.dart`):**
  - Modal checkout desktop WAJIB tampil **full-window** (tanpa `maxWidth: 620`) dengan perbesaran QRIS Midtrans agar mudah di-scan dari layar laptop.
  - Dialog pembayaran berhasil hanya menampilkan tombol **`Selesai`** (tanpa tombol *"Mulai Bertanya Sekarang"* dan tanpa memaksa membuka tab AI otomatis).
  - Kartu tunggu aktivasi (`AccessPrepareGate`) menampilkan **Adab Menggunakan AI** (bukan contoh pertanyaan).
