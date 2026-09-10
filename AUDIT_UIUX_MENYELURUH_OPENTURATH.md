# 🔍 AUDIT UI/UX MENYELURUH — OPENTURATH AI

> **Versi diaudit:** `1.0.18+19` · **Metode:** pembacaan langsung 11.713 baris kode `lib/` + pengukuran kuantitatif setiap nilai desain.
> **Keluhan pengguna:** *"sangat berantakan, tidak konsisten, tidak minimalist, banyak kecacatan."*
> **Vonis:** **Terbukti — dan angkanya jauh lebih buruk dari perkiraan.**
> Status: read-only, tidak ada berkas diubah.

---

## 1. RINGKASAN EKSEKUTIF

Ini bukan masalah selera. Ini masalah **tidak adanya sistem**. Aplikasi punya `theme.dart` berisi 508 baris token desain yang lengkap — **dan hampir seluruhnya tidak dipakai.**

### Bukti kuantitatif (dihitung dari kode, bukan opini)

| Metrik | Nilai terukur | Standar Apple/kelas dunia | Verdict |
|---|---|---|---|
| **Warna hardcode** (`Color(0xFF…)` di UI) | **165 pemakaian, 62 warna unik** | 0 (semua lewat token) | 🔴 |
| **Nilai radius berbeda** | **11** (2,6,8,10,12,14,16,18,20,24,100) | 2–3 | 🔴 |
| **Ukuran font berbeda** | **25** (10 di antaranya pecahan: 10.5, 11.5, 12.5, 13.5, 14.5, 15.5, 16.5, 17.5) | 6–8 | 🔴 |
| **Nilai spacing berbeda** | **19**, dengan **9 keluar grid 4pt** (1,2,3,5,6,10,14,18,22) | grid 4/8pt | 🔴 |
| **Pemakaian `Theme.of(context).textTheme`** | **0 kali** | seluruh teks | 🔴 |
| **Panggilan `GoogleFonts.*` langsung di UI** | **172 kali** | 0 | 🔴 |
| **Percabangan `isDark ?` manual** | **171 kali** tersebar di 8 layar | 0 (ThemeExtension) | 🔴 |
| **Komponen bersama (design system)** | **0 folder, 0 komponen** | wajib ada | 🔴 |
| **Varian loader/spinner** | **6 bahasa berbeda** | 1 | 🔴 |
| **`Semantics` / `semanticLabel`** | **2 / 3** di seluruh app | seluruh kontrol | 🔴 |
| **Dukungan `textScaler` (Dynamic Type)** | **0** | wajib | 🔴 |
| **Kode mati (widget tak dipakai)** | **315 baris** (`AppErrorState` 118 + `TurathCrystallizationOverlay` 197) | 0 | 🔴 |
| **Layar inti = string JS/CSS** | **672 dari 1.800 baris (37,3%)** | 0% | 🔴 |
| **`!important` dalam file Dart** | **205** | 0 | 🔴 |

### Tiga akar masalah

1. **Design system ada tapi mati.** `theme.dart` mendefinisikan warna, radius, tipografi, bahkan `BottomSheetThemeData` — tetapi `textTheme` dipakai **0 kali**, token radius dipakai **1 kali**, dan setiap layar membangun ulang paletnya sendiri lewat 171 ternary `isDark ?`.
2. **Tidak ada komponen bersama.** Tidak ada folder `design_system/` atau `shared/`. Setiap layar menulis kartu, baris, header, dan loader-nya sendiri dari nol → 3 loader "tiga titik" yang berbeda ukuran & durasi, 8 gaya kartu berbeda.
3. **Layar inti bukan UI, tapi scraper.** 37,3% `agent_webview_screen.dart` adalah CSS/JS untuk melawan DOM pihak ketiga — termasuk **menyembunyikan disclaimer akurasi AI**.

---

## 2. 🔴 TEMUAN PALING SERIUS (di luar estetika)

### 2.1 Disclaimer akurasi AI disembunyikan secara sengaja
`agent_webview_screen.dart:126-128` — 13 selector CSS menargetkan persis tempat NotebookLM merender peringatan akurasi:
```css
.disclaimer, [class*="disclaimer" i], [class*="compliance" i],
.compliance-notice, .legal-text, [class*="legal" i], mat-hint,
[role="contentinfo"], footer { display: none !important; ... }
```
Buktinya disengaja — `:426` menyaring kalimatnya dari teks yang disalin:
```javascript
if (pt.length > 20 && !pt.includes('can be inaccurate')) {
```
Dan ada upaya menutupi jejak di `:240-241`: fungsi `eradicateDisclaimer()` **dikosongkan** dengan komentar *"Menghormati disclaimer akurasi bawaan secara transparan"* — padahal CSS di atasnya tetap bekerja.

**Risiko:** pelanggaran ToS NotebookLM, kebijakan AI-Generated Content Google Play, dan — untuk aplikasi fikih/fatwa — pengguna membaca output AI **tanpa peringatan akurasi sama sekali**. Dialog Adab hanya muncul **sekali seumur instalasi** (`:1403`), bukan pengganti disclaimer per-jawaban.

### 2.2 Error teknis mentah bocor ke pengguna di layar pertama
`login_screen.dart:69`:
```dart
AppSnackBar.error(context, 'Gagal masuk: $e. Silakan coba lagi.');
```
Pengguna melihat: *"Gagal masuk: PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 10: , null, null). Silakan coba lagi."*

`main.dart:54` bahkan menyuruh pengguna akhir membuka terminal:
> *"Silakan jalankan **"flutterfire configure"** di terminal komputer Anda"*

### 2.3 Loader bisa berputar selamanya
`_detectGoogleAccessDenied()` (`:615-621`) menyetel `_errorMessage` + `_isWebViewLoading=false` **tapi tidak menyentuh `_isLoadingUrl`**. Karena layer error hanya dirender bila `!_isLoadingUrl` (`:1299`), pengguna melihat **tiga titik berputar tanpa akhir** padahal state internal sudah "paywall". Tidak ada timeout.

### 2.4 Kebocoran performa permanen
`agent_webview_screen.dart:504-510`:
```javascript
new MutationObserver(function() { runLoop(); })
  .observe(document.documentElement, { childList: true, subtree: true });
setInterval(runLoop, 300);
```
- `runLoop()` melakukan **full-document scan** (`querySelectorAll('…, div')` + TreeWalker seluruh text node).
- **3,3 scan/detik = 12.000/jam, selamanya**, bahkan saat idle/background.
- **Tidak pernah** ada `clearInterval` maupun `.disconnect()`. `dispose()` (`:93-97`) hanya `_webController = null`.
- Skrip 21.121 byte diinjeksi **~12× per page load** (UserScript + onLoadStop t=0/500/1200/2500/4000ms + onProgressChanged).

---

## 3. KENAPA TERASA "BERANTAKAN" — BUKTI PER ASPEK

### 3.1 Warna: 62 palet liar bersaing
Token resmi ada di `theme.dart`, tapi UI memakai 62 warna hardcode. Yang paling sering:

| Warna | Dipakai | Masalah |
|---|---|---|
| `0xFF18181B` | **37×** | Duplikat `AppTheme.surfaceCardDark` / `textPrimaryLight` |
| `0xFF10B981` | **11×** | Hijau emerald — **tidak ada di theme** |
| `0xFF0E0E10` | **11×** | Duplikat `AppTheme.canvasDark` |
| `0xFFA1A1AA` | 7× | Duplikat `textSecondaryDark` |
| `0xFFD97706` | 3× | Amber — tidak ada di theme |
| `0xFF2E7D32`, `0xFF1B5E20` | 3× | **Material Green** — palet asing |

Akibatnya **minimal 5 keluarga warna** hidup bersamaan: monokrom Zinc (resmi), biru aksen `#60A5FA`, emerald `#10B981`, amber `#D97706`, Material Green (banner update), plus Tailwind Slate di `turath_crystallization_overlay`.

Satu file bahkan punya **dua merah berbeda**: `profile_screen.dart:539` (`AppTheme.appleRed #FF3B30`) dan `:559` (`#DC2626`) — dua spinner merah berdampingan.

### 3.2 Tipografi: 25 ukuran, 3 font, tanpa aturan
- Rentang 11–14 punya **8 langkah** (11, 11.5, 12, 12.5, 13, 13.5, 14, 14.5). Selisih 0,5px tidak terlihat mata tapi menghancurkan ritme.
- Wordmark "OpenTurath" ditulis **3 ukuran**: 34 (splash) → 35 (login) → 24 (dashboard). Splash→login transisi langsung: **logo melompat 1px**.
- Judul AppBar: Outfit 16 (`agent_webview:1024`) vs Newsreader 17 (`google_session:174`) vs tema Outfit 18 — elemen sama, 3 perlakuan.
- Judul sheet: 17/w700 (evidence) vs 15/w600 (doku) vs 16/w600 (font sheet).
- `app_snackbar.dart:59-64` memakai **`TextStyle` polos tanpa GoogleFonts** — satu-satunya teks berfont sistem di seluruh app.

### 3.3 Radius: token lengkap, adopsi 1 dari ~230
`theme.dart:118-125` punya 7 token (3 di antaranya duplikat nilai). **Dipakai 1 kali** (`subscription_screen.dart:92`). Sisanya literal: 2, 6, 8, 10, 12, 14, 16, 18, 20, 24, 100.

`BottomSheetThemeData` mendefinisikan radius **28** — **nol dari 4 sheet memakainya** (semua override manual ke 24 atau 20).

Tombol: pill (100) di tema, tapi `evidence_bottom_sheet:349,371` dan `update_ready_banner:96` pakai 12 → **pengguna melihat tombol pill di satu layar, kotak-membulat di layar lain untuk aksi setara.**

### 3.4 Komponen: tidak ada yang dibagikan
Tidak ada `design_system/`. Setiap layar bikin sendiri:

| Komponen | Varian | Bukti |
|---|---|---|
| Loader "3 titik" | **3 implementasi** | `_PulsingDots` 7px/1100ms · `_ThreeDotsMinimalLoader` 10px/1200ms · `_CheckoutPulsingDots` 8px/900ms |
| Spinner | +3 lagi | `CircularProgressIndicator` (8 lokasi, warna beda-beda), `LinearProgressIndicator`, `Lottie` |
| Handle drag sheet | **3 varian** | 40×4 border · 36×4 border · 36×4 `white24/black12` |
| Error state | **2, satu tak dipakai** | `AppErrorState` (118 baris, **0 pemakaian**) vs error state 90 baris yang ditulis ulang di webview |
| Press interaction | **3 bahasa** | `AppleInteractiveWrapper` (1 pemakaian) · `InkWell` ripple (10×) · `AnimatedScale` manual (6×) |

`AppleInteractiveWrapper` adalah satu-satunya komponen yang menghormati reduce-motion (`:110`) — **dipakai 1 dari 12 layar.** `login_screen.dart:185-192` malah menulis ulang press-scale dari nol dengan `0.975`/120ms (wrapper: `0.975`/110ms).

### 3.5 Duplikasi fitur di layar inti
Copy & Bookmark punya **dua jalur paralel** (native AppBar + tombol HTML injeksi), dengan pesan berbeda:
- `:876` `'Hasil telaah AI berhasil disalin!'` → **hijau (success)**
- `:1203` `'Hasil telaah AI berhasil disalin'` → **biru (info)**

Dua tombol, fungsi sama, warna feedback berbeda. Ini definisi harfiah "berantakan".

### 3.6 Kode mati yang tetap mengotori
- `AppErrorState` — 118 baris, **0 pemakaian**, padahal 0 warna hardcode (paling patuh token).
- `TurathCrystallizationOverlay` — 197 baris, **0 pemakaian**, menyumbang 8 warna asing (Tailwind Slate + cyan `#00E5FF`).
- `Loc.tr()` — sistem i18n lengkap 22 kunci × 3 bahasa, **dipanggil 1 kali** (`main.dart:93`, untuk judul yang tak pernah terlihat). Menu bahasa di profil mengubah state tapi **tidak mengubah apa pun di layar**.

---

## 4. ONBOARDING: 10 LANGKAH, 2,2 DETIK DELAY BUATAN

| # | Layar | Masalah |
|---|---|---|
| 1 | Splash | **1.200ms `Future.delayed` murni** + 300ms fade — tidak menunggu apa pun (Firebase sudah siap di `main.dart:42`) |
| 2-3 | Login + Google picker | OK |
| 4 | **GoogleSessionAuth** | **Login Google KEDUA di WebView** — form password lengkap di `accounts.google.com/ServiceLogin` |
| 5 | "Sesi Terhubung" | **700ms delay paksa** |
| 6-8 | Dashboard → Spesialis → Loader | |
| 9 | **Dialog Adab** | `barrierDismissible: false`, 3 paragraf padat, memblokir tepat saat pengguna ingin mencoba |
| 10 | Ruang riset | **nilai produk baru terlihat di sini** |

**Double-login tidak dijelaskan.** Layar hanya berisi judul *"Hubungkan Akun Google"* + subtitle jargon 11,5px *"Autentikasi sesi riset naskah turats"*. Penjelasan sesungguhnya baru muncul **jika pengguna menekan back**:
> *"Akun Google wajib dihubungkan agar ruang riset AI dapat langsung digunakan tanpa meminta login berulang kali."*

Kalimat ini membenarkan login berulang dengan alasan menghindari login berulang — dan satu-satunya jalan keluar adalah tombol merah **"Keluar Akun"**.

Pola ini juga **identik dengan phishing** (form password Google di WebView aplikasi pihak ketiga), yang mengapa kode harus memalsukan User-Agent Chrome (`:27-28`) untuk menghindari blokir Google.

---

## 5. COPYWRITING: PANJANG, JARGON, CAMPUR BAHASA

### 5.1 String terlalu panjang
| Panjang | String | Alternatif |
|---|---|---|
| **153** | *"Anda belum memiliki akses ke ruang riset {title}. Silakan aktifkan paket langganan Rp 50.000/bulan atau Paket Promo Semua AI Rp 99.000."* (`:618`) | *"Modul ini butuh langganan aktif."* + tombol |
| **118** | *"OpenTurath adalah perkakas digital pelacak ibarah dan komparasi naskah primer kitab kuning, bukan mufti fatwa mandiri."* (`:1477`) | *"OpenTurath membantu mencari ibarah kitab. Bukan pengganti fatwa."* |
| **109** | *"Akun Google wajib dihubungkan agar ruang riset AI…"* (`google_session:64`) | *"Tanpa akun Google, ruang riset tidak bisa dibuka."* |
| **98** | *"…belum tersedia (Segera Hadir) dan sedang dalam proses kurasi naskah kitab primer."* (`:545`) | *"{title} belum tersedia."* |

**Harga di-hardcode dalam pesan error** (`:618`) — akan basi tanpa rilis app baru.

### 5.2 Jargon menumpuk
- `:1495` — *"Sikap Ihtiyath (Wara')"* — dua istilah Arab dalam judul 4 kata, satu menjelaskan yang lain, keduanya asing.
- `:1463` — teks Arab **tanpa terjemahan** (`التعلم بالتلقي عن الأشياخ هو الأصل`) di tengah dialog berbahasa Indonesia.
- `evidence:312` — *"Intisari & Analisis Kontekstual"* untuk sekadar menampilkan penjelasan. Cukup: *"Penjelasan"*.
- Berulang tanpa penjelasan: "korpus naskah primer", "ibarah", "Musannif/Pengarang", "Taqrir & Syarah", "penafian talaqqi".

### 5.3 Campur bahasa dalam satu layar
Login screen, 5 elemen berurutan:
```
'OpenTurath'                     → brand
'AI for Islamic Scholarship'     → INGGRIS, italic serif
'Lanjutkan dengan Google'        → INDONESIA
'Dengan masuk, Anda menyetujui'  → INDONESIA
```
Dan `localization.dart:13` menyapa pengguna **locale Indonesia** dengan huruf Arab: `'welcome': 'أهلاً'`.

### 5.4 Label duplikat dengan wording berbeda
| Konsep | Varian yang ada |
|---|---|
| Coming soon | 3 wording ("proses kurasi" vs "tahap kurasi" vs "Segera") |
| Salin sukses | 2 wording + **2 warna berbeda** (hijau vs biru) |
| Batal/Kembali | 6 varian: "Batal", "Kembali", "Kembali ke Beranda", "Tetap di Sini", "Lanjutkan Bayar", "Ya, Tutup" |

### 5.5 Klaim berlebihan
- *"AI for Islamic Scholarship"* — hal **pertama** yang dibaca pengguna, berbenturan dengan disclaimer "bukan mufti" yang baru muncul di langkah ke-9.
- *"Pembayaran Aman DOKU"* (`doku:283`) — pada WebView dengan `MIXED_CONTENT_ALWAYS_ALLOW` (`:356`) dan `allowFileAccess: true` (`:357`).
- *"Ketuk untuk memasang seketika"* — instalasi APK butuh konfirmasi sistem.

---

## 6. AKSESIBILITAS: NYARIS NOL

| Indikator | Temuan | Dampak |
|---|---|---|
| `Semantics` | **2** di seluruh app | Screen reader tidak mengenali kartu sebagai tombol |
| `semanticLabel` | **3** | Ikon terbaca "button" tanpa nama |
| `textScaler` | **0** | **Layout pecah** saat pengguna memperbesar font sistem |
| Reduce-motion | **1** (hanya di widget yang dipakai 1×) | Animasi looping dipaksakan |
| Target sentuh <44pt | Badge kuota ~19px (`:1032-1070`), tombol hapus bookmark (`bookmark:642`), tombol tutup sheet (`evidence:159-160`) | Salah tap, aksi destruktif berisiko |

Untuk aplikasi yang penggunanya mencakup **ulama/kiai sepuh**, ketiadaan Dynamic Type adalah cacat paling serius.

---

## 7. RENCANA PERBAIKAN — URUT DAMPAK

### P0 — Hentikan pendarahan (1–2 hari)
1. **Kembalikan disclaimer akurasi AI.** Hapus 13 selector di `:126-128` dan filter `:426`. Ganti dengan disclaimer OpenTurath sendiri yang tampil native — justru memperkuat kredibilitas produk fikih.
2. **Hentikan kebocoran performa:** hapus `setInterval(runLoop, 300)`, tambahkan `.disconnect()` observer, panggil `_webController.dispose()`, batalkan 5 `Future.delayed` saat dispose.
3. **Perbaiki loader menggantung:** setel `_isLoadingUrl = false` di `_detectGoogleAccessDenied` + tambahkan timeout.
4. **Hentikan kebocoran error teknis:** petakan exception ke pesan manusiawi; hapus instruksi "flutterfire configure" dari `main.dart`.

### P1 — Bangun sistem desain yang benar-benar dipakai (3–5 hari)
5. **Buat `lib/design_system/`** berisi: `AppSpacing` (4/8/12/16/24/32), `AppRadius` (8/16/999 — **hanya 3**), `AppTypography` (**7 ukuran**: 11/13/15/17/20/24/32), `AppColors` semantik.
6. **Aktifkan `textTheme`.** Ganti 172 panggilan `GoogleFonts.*` langsung → `Theme.of(context).textTheme.*`. Masukkan Newsreader ke tema sebagai `displayLarge/Medium` saja (peran editorial), Outfit untuk sisanya.
7. **Hapus 171 ternary `isDark ?`** → pindahkan ke `ThemeExtension`. Layar cukup memanggil `context.colors.surface`.
8. **Migrasi 165 warna hardcode → token.** Tetapkan **satu** aksen (rekomendasi: monokrom + 1 aksen), hapus emerald/amber/Material Green/Slate liar.

### P2 — Satukan komponen (2–3 hari)
9. **Satu loader** (`AppLoader`) menggantikan 6 varian. **Satu** `AppErrorState` (sudah ada, tinggal dipakai — hapus error state duplikat 90 baris di webview). **Satu** `AppBottomSheet` (handle, radius, padding seragam).
10. **Hapus kode mati:** `TurathCrystallizationOverlay` (197 baris), duplikasi Copy/Bookmark jalur JS (pertahankan native saja).
11. **Pakai `AppleInteractiveWrapper` di semua permukaan tap** — hapus press-scale manual di login.

### P3 — Sederhanakan alur & teks (2–3 hari)
12. **Pangkas onboarding 10→7 langkah:** hapus delay 1.200ms + 700ms (hemat 2 detik), pindahkan dialog Adab jadi banner non-blocking, jelaskan double-login **sebelum** WebView terbuka (atau hilangkan dengan cookie injection dari token OAuth pertama).
13. **Sunting seluruh copywriting sekali oleh manusia:** potong string >80 karakter, hapus jargon ganda, satukan wording duplikat, keluarkan harga dari pesan error, pilih satu register bahasa.

### P4 — Aksesibilitas (2–3 hari)
14. Dukung `textScaler` + longgarkan fixed-height. Naikkan semua target sentuh ke ≥44pt. Tambah `Semantics` pada seluruh kontrol kustom. Hormati reduce-motion.

### P5 — Keputusan strategis
15. **Evaluasi ulang pendekatan WebView.** 672 baris JS/CSS melawan DOM Google akan rusak setiap Google deploy. Opsi: (A) chat native via API — menghilangkan seluruh kelas masalah ini; (B) WebView dengan CSS statis sekali di `AT_DOCUMENT_START`, tanpa JS runtime, tanpa observer, disclaimer dikembalikan.

---

## 8. TARGET TERUKUR SESUDAH PERBAIKAN

| Metrik | Sekarang | Target |
|---|---|---|
| Warna hardcode di UI | 165 | **0** |
| Warna unik | 62 | **≤12 token** |
| Nilai radius | 11 | **3** |
| Ukuran font | 25 | **7** |
| Nilai spacing | 19 (9 off-grid) | **6, semua kelipatan 4** |
| `textTheme` dipakai | 0 | **seluruh teks** |
| `isDark ?` manual | 171 | **0** |
| Varian loader | 6 | **1** |
| Kode mati | 315 baris | **0** |
| `Semantics` | 2 | **seluruh kontrol** |
| Dukungan textScaler | 0 | **penuh** |
| Langkah onboarding | 10 | **7** |
| JS/CSS di layar inti | 672 baris (37,3%) | **≤50 baris CSS statis** |

---

## LAMPIRAN — BUKTI RINGKAS

| Temuan | Lokasi |
|---|---|
| Disclaimer AI disembunyikan | `agent_webview_screen.dart:126-128`, filter `:426`, fungsi kosong `:240-241` |
| `setInterval` 300ms selamanya | `agent_webview_screen.dart:509` |
| Observer tanpa disconnect | `:504-508`, `dispose()` `:93-97` |
| Loader menggantung | `:615-621` vs `:1299` |
| Error mentah ke pengguna | `login_screen.dart:69`, `:56`, `evidence_bottom_sheet.dart:42`, `main.dart:54` |
| Wordmark 3 ukuran | `splash:112` (34) · `login:154` (35) · `dashboard:244` (24) |
| Sheet abaikan tema | `theme.dart:245/411` (28) vs doku (24) / evidence (24) / font sheet (20) |
| Dua merah di satu file | `profile_screen.dart:539` vs `:559` |
| Copy sukses beda warna | `:876` (hijau) vs `:1203` (biru) |
| Kode mati | `app_error_state.dart` (118), `turath_crystallization_overlay.dart` (197) |
| i18n mati | `localization.dart` (22 kunci) vs `main.dart:93` (1 panggilan) |
| Double-login | `google_session_auth_screen.dart:30-31` |
| Delay buatan | `splash_screen.dart:50` (1200ms), `google_session_auth_screen.dart:44` (700ms) |

---
*Audit selesai — OpenTurath AI v1.0.18+19*
