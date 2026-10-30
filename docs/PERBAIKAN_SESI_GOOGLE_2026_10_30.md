# Perbaikan lokal untuk mempertahankan sesi Google yang sudah berhasil

Tanggal: 30 Oktober 2026, Asia/Aden.
Dasar: [audit login dan distribusi](/Users/apple/Downloads/ramadhan/docs/AUDIT_LOGIN_SESI_DISTRIBUSI_2026_10_30.md).

## Hasil yang dituju

Sesi Google yang masih sah digunakan kembali saat membuka AI. Pembatalan koneksi, membuka tab, atau membuka checkout tidak boleh menghapus atau menimpa sesi yang sudah ada. Keberhasilan koneksi hanya dilaporkan sesudah identitas dan keberadaan sesi berhasil diperiksa.

## Perubahan yang sudah diterapkan pada kode

1. **Pemakaian ulang sesi lebih dahulu.** Layar koneksi membuka halaman Notebook dengan penyimpanan WebView yang ada. `InteractiveLogin` menjadi fallback ketika pemeriksaan tidak menemukan sesi. Ini memungkinkan sesi lama yang masih sah diverifikasi kembali tanpa aplikasi langsung memulai formulir login baru.
2. **Hentikan impor cookie native pada macOS.** Login, ruang AI, dan checkout memakai `WebViewCookiePolicy.sharedCookiesEnabled`. Nilainya false pada macOS native, sehingga plugin tidak mengimpor cookie Foundation ke WKWebView ketika membuat tampilan baru. Default persistent WK store tetap dipakai. Platform lain mempertahankan pengaturan sebelumnya.
3. **Pembatalan mempertahankan sesi.** Tombol tutup/Back menyediakan pilihan menunda koneksi AI. Tindakan ini kembali ke layar sebelumnya atau beranda dengan hasil false, tanpa memanggil `AuthService.signOut`, menutup tab, atau membersihkan cookie. Log Out Pengaturan tetap jalur logout yang terpisah.
4. **Pemilik sesi harus terverifikasi.** Login Firebase dan callback kesiapan composer tidak boleh membuat atau mengganti pemilik Google web. Pergantian akun melepas klaim metadata tanpa menghapus cookie.
5. **Migrasi penanda lama.** `webview_session_owner_verified_v1` hanya dibuat setelah verifikasi koneksi. Owner dari versi lama yang belum mempunyai marker perlu pemeriksaan pasif melalui halaman Notebook. Cookie lama tetap disimpan. Bila Google menyatakan sesinya tidak sah atau meminta challenge, pengguna tetap perlu menyelesaikan verifikasi Google.
6. **Keberhasilan palsu ditutup.** Halaman harus berasal dari Notebook yang diizinkan, email yang terbaca harus sama dengan akun aplikasi, dan pemeriksaan cookie harus berhasil. Hasil false, exception, atau identitas yang belum terbaca tidak lagi menghasilkan navigasi sukses.
7. **Pemulihan yang dapat dicoba lagi.** Gagal verifikasi menggantikan viewport native dengan status dan tombol coba lagi/tunda. Watchdog berhenti mengulang saat status ini tampil. Coba lagi membuat tampilan Notebook baru dengan store yang sama.
8. **Pengaman respons terlambat.** Dialog pembatalan dan generasi pemeriksaan mencegah hasil lama menyelesaikan koneksi sesudah dibatalkan. Callback dari WebView yang sudah diganti diabaikan berdasarkan identitas controller platform. Pemeriksaan tersebut memakai objek platform karena pembungkus controller pada plugin dapat berbeda antar callback.

## Verifikasi yang telah dijalankan

**40 tes terarah lulus** melalui Dart MCP pada sumber akhir, dan analisis terarah melaporkan **No errors**.

| Kelompok | Jumlah tes | Bukti utama |
|---|---:|---|
| Pemulihan layar koneksi | 7 | Cookie hilang/gagal dibaca tidak sukses; sesi valid sukses; cancel menjaga tab/cookie; retry berhasil; dialog tidak ditutup otomatis; callback lama tidak merusak tampilan baru |
| Kepemilikan/persistensi sesi | 8 | Akun B tidak mewarisi cookie A; metadata lama perlu verifikasi; pembatalan saat pembacaan berlangsung tidak menulis owner; nol penulisan/penghapusan cookie native pada fixture |
| Kebijakan cookie | 7 | Pengaturan macOS tidak mengimpor jar; semua lokasi WebView menerapkan kebijakan; platform lain tetap sama |
| Gate terdekat yang sudah ada | 18 | UI onboarding, tab/sub-AI, hardening WebView, routing Notebook, dan auth stream |

Regresi sebelum perbaikan benar-benar direproduksi: cookie kosong/gagal dibaca dan konfirmasi manual semula menghasilkan hasil navigasi true. Pemeriksaan saat dialog pembatalan terbuka semula menutup dialog secara otomatis. Callback lama setelah retry semula merusak WebView baru. Tes sesudah patch menolak seluruh perilaku tersebut.

Pemeriksaan diff juga membuktikan:

- `agent_multi_tab_room.dart` hanya berubah pada import kebijakan dan satu pengaturan cookie.
- `desktop_webview_runtime.dart` tidak berubah.
- Polling minimum 4 sampel, elapsed 3000 ms, jeda 250 ms, CSS, dan siklus hidup ruang AI dipertahankan.
- Layar koneksi tidak lagi memanggil logout global.
- Tidak ada perubahan entitlement/VIP, worker, atau operasi produksi.

## Batas hasil dan status pengiriman

Ini adalah **perbaikan kode lokal**, dengan checkpoint Git. Belum dibuat binary baru dari patch ini, belum dipasang ke `/Applications`, dan belum dipublikasikan sebagai pembaruan. Aplikasi terpasang dan paket publik belum menerima perbaikan ini melalui audit/perubahan lokal tersebut.

Tes memakai platform WebView dan cookie sintetis. Tes tidak membuktikan login Google nyata, persistensi setelah restart macOS, migrasi Keychain, challenge/CAPTCHA, atau pengalaman pengguna pada perangkatnya. Tidak ada cookie Google nyata yang dibaca/diubah oleh fixture, sesi yang dilogout, atau challenge akun pengguna yang dijalankan.

Verifikasi perangkat berikutnya perlu membuktikan: sesi yang pernah membuka AI tetap dapat dipakai setelah tutup/buka aplikasi dan restart OS; lima tab dan checkout tidak mengganggunya; menunda koneksi mempertahankan sesi; update dari versi pelanggan tetap menyimpan sesi; challenge Google menampilkan pemulihan yang jujur. Persyaratan signing/notarisasi distribusi dari audit tetap perlu dipenuhi sebelum rilis.

Google dapat mencabut atau meminta verifikasi ulang sesi. Patch ini menjaga aplikasi memakai penyimpanan sesi secara benar; ia tidak menjanjikan sesi permanen atau melewati pemeriksaan Google. Deteksi identitas juga masih bergantung pada struktur halaman Google, sehingga perlu uji halaman aktual sebelum klaim perbaikan pada perangkat.
