# 🔬 AUDIT MENDALAM UI/UX · FITUR · COPYWRITING · KODE — OPENTURATH AI

> **Jenis:** Audit produk & kode menyeluruh (bukan audit keamanan infra — itu dokumen terpisah).
> **Tanggal:** September 2026 · **Basis:** pembacaan langsung seluruh `lib/` kode sumber (bukan dokumen).
> **Versi yang diaudit:** `1.0.8+9` · Fokus: kecacatan UI/UX, fitur yang tidak perlu, copywriting "berasa AI", bug, dead code, dan fitur wajib yang hilang.
> **Status:** Read-only. Tidak ada berkas yang diubah.

---

## DAFTAR ISI

1. [Ringkasan Eksekutif](#1-ringkasan-eksekutif)
2. [🔴 Temuan Kritis (Monetisasi & Kebenaran Produk)](#2--temuan-kritis-monetisasi--kebenaran-produk)
3. [Cacat UI/UX](#3-cacat-uiux)
4. [Copywriting yang Berasa AI / Tidak Autentik](#4-copywriting-yang-berasa-ai--tidak-autentik)
5. [Fitur & Elemen yang Tidak Perlu (Clutter)](#5-fitur--elemen-yang-tidak-perlu-clutter)
6. [Cacat Kode & Bug](#6-cacat-kode--bug)
7. [Desain Sistem (Theme) yang Bocor](#7-desain-sistem-theme-yang-bocor)
8. [Fitur Wajib yang Hilang](#8-fitur-wajib-yang-hilang)
9. [Prioritas Perbaikan](#9-prioritas-perbaikan)

---

## 1. RINGKASAN EKSEKUTIF

**Kondisi visual aplikasi ini sudah matang (±80%)** — desain Material 3 Expressive rapi, konsisten, shell 4-tab modern, animasi stagger halus, RTL dasar ada. Namun di balik tampilan yang bagus, ada **tiga masalah besar yang jauh lebih penting daripada estetika**:

### 1. Tiga dosa struktural
| # | Masalah | Dampak |
|---|---|---|
| 🔴 | **Paywall bisa dilewati dalam satu klik** — fallback ke URL NotebookLM hardcoded di kode client | Seluruh monetisasi jadi teater; siapa pun dapat semua modul gratis |
| 🟠 | **Produk aslinya adalah "bungkus NotebookLM" yang rapuh** — ~350 baris DOM-scraping untuk menyembunyikan UI Google | Rusak setiap kali Google mengubah DOM; jank; risiko ToS |
| 🟠 | **Jualan konten digital via checkout web DOKU eksternal** | Melanggar kebijakan pembayaran Play/App Store → risiko ditolak/diturunkan |

### 2. Kebenaran produk goyah
- Aplikasi **tidak bisa memutuskan berapa AI yang ia punya**: catalog punya **13 agent** (6 aktif), UI subscription mengklaim **"10 AI"**, profile mengklaim **"30 AI"**. Tiga angka berbeda di tiga layar.
- Dashboard mengiklankan **"32 spesialis"** di 8 bidang, tetapi hanya 13 agent ada di kode — banyak ID "hantu" yang tidak pernah didefinisikan.

### 3. Copywriting
Sekitar **75% copy sudah baik dan "berasa manusiawi/santri"** (terutama bagian fiqh mazhab). Tetapi sisanya adalah **klaim superlatif palsu, jargon menumpuk, campur bahasa Inggris-Indonesia, dan instruksi ke fitur yang tidak ada** — ciri khas copy yang dihasilkan AI tanpa penyuntingan manusia.

---

## 2. 🔴 TEMUAN KRITIS (MONETISASI & KEBENARAN PRODUK)

### 2.1 🔴 PAYWALL BYPASS — monetisasi jadi teater
Ini temuan paling parah. Akses ke konten premium bisa dilewati karena **URL NotebookLM asli disimpan hardcoded di kode client** dan dipakai sebagai "fallback".

`lib/services/agent_service.dart:14-35` — 9 URL NotebookLM produksi di-hardcode:
```dart
static const Map<String, String> defaultAgentUrls = {
  'fiqh_tahawwulat': 'https://notebooklm.google.com/notebook/dc7ee7e4-.../preview',
  'fiqh_syafii':     'https://notebooklm.google.com/notebook/334e7b83-.../preview',
  // ... 9 modul, termasuk yang premium
};
```

Lalu dipakai di 3 tempat untuk **mengalahkan** gerbang server:
- `agent_service.dart:54,61,67` — bila Cloud Function `getAgentUrl` error/not-found → kembalikan URL hardcoded.
- `agent_webview_screen.dart:237-244` — bila URL `null` → pakai fallback.
- `agent_webview_screen.dart:905-918` — **tombol "Buka Langsung Mode Riset"** di layar paywall membuka notebook premium langsung:
```dart
if (_agent != null && AgentService.defaultAgentUrls.containsKey(_agent!.id)) ...
  label: const Text('Buka Langsung Mode Riset'),   // ← backdoor eksplisit
```

**Akibatnya:** pengguna tidak perlu membayar. Cukup membuka layar agent; ketika ditolak server, ada tombol "Buka Langsung Mode Riset". Ini bertentangan langsung dengan model bisnis. **URL NotebookLM seharusnya hanya hidup di server dan dikirim setelah entitlement terverifikasi — jangan pernah di client.**

### 2.2 🔴 TRIAL GATE client rusak — pengguna trial langsung ditolak
`lib/screens/agent_webview_screen.dart:224`:
```dart
if (_user == null || !_user!.hasAccessToAgent(_agent!.id)) { ...paywall... }
```
`lib/models/user_model.dart:140` `hasAccessToAgent` hanya mengecek langganan aktif, **bukan kuota trial**. Pengguna baru (trial, `questionsUsed < 10`) akan `hasAccessToAgent == false` → **langsung kena paywall di klik pertama**, padahal konstanta `trialQuestionLimit = 10` menjanjikan 10 pertanyaan gratis. Kuota trial dicek **tidak di mana pun** di jalur WebView (`recordQuestion` ada tapi tidak dipanggil). Trial efektif mati.

### 2.3 🔴 Angka AI yang saling bertentangan (kebohongan UI)
| Sumber | Klaim | Fakta |
|---|---|---|
| `agent_model.dart` (katalog) | 13 top-level agent (6 aktif, 7 coming soon) | — |
| `subscription_screen.dart:377,379,386` | "SELURUH **10** modul AI", "Beli Semua **10** AI" | 13, bukan 10 |
| `profile_screen.dart:197` | "Paket Sultan (Akses **30** AI)" | 13, bukan 30 |
| `field_model.dart` (dashboard) | total **32** spesialis di 8 bidang | hanya 13 agent ada |

Pengguna yang membayar "Semua 10 AI" padahal hanya 6 yang aktif, atau melihat "30 AI" di profil padahal 13 di kode, adalah **ketidakbenaran produk yang bisa jadi sengketa konsumen**.

### 2.4 🔴 ID agent "hantu" di dashboard
`lib/models/field_model.dart:42-48, 55-61, dst.` mendeklarasikan `specialistCount` dan `agentIds` yang **tidak pernah didefinisikan** di `agent_model.dart`:
```
hadith → specialistCount: 4, agentIds: [hadits, hadits_takhrij, hadits_syarah, hadits_ilal]
         (padahal hanya 'hadits' yang ada — 3 lainnya hantu)
lughah → specialistCount: 5  (padahal hanya 'nahwu_sharaf' yang ada)
```
Dashboard menampilkan "4 spesialis" / "5 spesialis" untuk bidang yang hanya punya 1 agent nyata. Ini **kedalaman produk palsu**.

### 2.5 🟠 Pembayaran dengan identitas palsu
- `subscription_screen.dart:95` — `const phone = '081234567890';` nomor **palsu** dikirim ke DOKU untuk setiap transaksi.
- `subscription_screen.dart:115` — nama fallback `'Santri OpenTurath'`; `profile_screen.dart:180` email fallback `'peneliti@openturath.ai'`.
- Real-money invoice bisa terbit atas nama/telepon placeholder.

### 2.6 🟠 "Hapus riwayat chat" adalah konfirmasi palsu
`agent_webview_screen.dart:538-553` — bila tidak menemukan tombol hapus asli, kode hanya menghapus node DOM secara lokal (`messages.forEach(m => m.remove())`) lalu menampilkan sukses `'Riwayat chat telah dihapus'`. Pesan **tidak benar-benar terhapus di server Google**; akan muncul lagi saat reload. Ini jenis "kebohongan UX" terburuk.

---

## 3. CACAT UI/UX

### 3.1 Tinggi (fungsional)
1. **Tidak ada layar Settings terpisah** — `settings_screen.dart` dan route `/settings` **tidak ada**. Pengaturan digabung di Profile. Namun ada tile **"Bahasa Antarmuka" dengan chevron yang tidak melakukan apa-apa** (`profile_screen.dart:406-413`) — hanya memunculkan snackbar "Bahasa Indonesia adalah bahasa default". **Jangan tampilkan chevron untuk jalan buntu.**
2. **Perilaku tombol Back tidak konsisten** — di shell, back dari tab non-Beranda lompat ke tab 0 (`main_shell:86-94`); di WebView `canPop:false` dengan handler kustom; di GoogleSessionAuth back membuka dialog sign-out. Tiga semantik back berbeda.
3. **Loading WebView bisa menggantung** — `onLoadStop`/progress mungkin tidak pernah beres pada redirect cache Google; tidak ada timeout di `_fetchAgentUrl` (`agent_webview:204`) dan tidak ada tombol retry pada state loading.
4. **Avatar rusak tanpa inisial** — `profile_screen.dart:262-274`: bila `NetworkImage` gagal, `onBackgroundImageError` menelan error tetapi `child` (inisial) null → lingkaran kosong.
5. **Force-dark bertabrakan dengan CSS injeksi** — `agent_webview:726` `forceDark: ON` sekaligus menyuntik stylesheet warna eksplisit, plus `algorithmicDarkeningAllowed:false` (`:727`) yang kontradiktif → kontras tak terduga di webview gelap.

### 3.2 Menengah (polesan)
6. **Target sentuh <48dp** — tombol hapus bookmark (`bookmark_screen:503-512`, padding zero, ikon 18px) dan item nav pill tak-terpilih (~37dp).
7. **Radii tidak sistematis** — 10+ nilai radius berbeda (6,8,10,12,14,16,18,20,24,100) tanpa token yang konsisten.
8. **Padding bawah magic `108`** dipakai juga di layar full-route tanpa bottom nav (`subscription_screen:232`) → ruang mati.
9. **Animasi stagger replay tiap rebuild** — `subscription_screen` (unkeyed `TweenAnimationBuilder`) memutar ulang seluruh halaman saat tombol "Beli" men-set state.
10. **Ikon tab "Spesialis" tidak konsisten** — rail pakai `grid_view`, bottom nav pakai `auto_awesome` untuk tujuan yang sama.
11. **Empty state bookmark pakai animasi "thinking"** (loading), bukan ikon "kosong" → pengguna menunggu sesuatu yang tak datang.

---

## 4. COPYWRITING YANG BERASA AI / TIDAK AUTENTIK

> Pola umum: campuran jargon akademik berlebihan, em-dash (—) di mana-mana, superlatif palsu, terjemahan mesin, dan instruksi ke fitur yang tidak ada. Di bawah ini yang paling menonjol, dengan alternatif yang lebih manusiawi.

### 4.1 Klaim superlatif palsu (paling tidak bisa dibela)
| Lokasi | Kutipan | Masalah | Alternatif |
|---|---|---|---|
| `agent_model:180` | Al-Majmu' "Ensiklopedi Fikih Syafi'i **terbesar dan paling rinci**" | Marketing; cendekiawan akan hati-hati | "Rujukan fikih Syafi'i yang komprehensif" |
| `agent_model:312` | "Ensiklopedi fikih dalil **terbesar** mazhab Hanbali" | Formula sama dengan :180 & :511 | "Kitab fikih dalil utama Hanbali" |
| `agent_model:511` | Jam'ul Jawami' "Ensiklopedi ushul fikih lintas madzhab **terlengkap**" | Tiga buku tak mungkin sama-sama "terbesar" | "Kitab ushul lintas mazhab yang lengkap" |
| `agent_model:424,473` | tafsir/ushul "dari **seluruh kitab** mu'tabarah di **Maktabah Syamilah**" | Satu notebook NotebookLM tidak memuat ribuan jilid | "dari kitab-kitab tafsir mu'tabarah" |
| `agent_model:522` | "**Seluruh** ilmu bahasa Arab ... dari literatur **terlengkap**" | "Seluruh"+"terlengkap" menumpuk | "Nahwu, Sharaf, Balaghah dari kitab utama" |
| `agent_model:565` | Alfiyah "Kitab nadhom **legendaris** ... terdiri dari **1.000 bait syi'ir**" | "legendaris" = slop; "bait syi'ir" redundan | "Kitab nadhom tata bahasa Arab (1.000 bait)" |

### 4.2 Jargon menumpuk & "ruang riset" (istilah internal yang bocor ke UI)
- `agent_webview:595,847` — **"Ruang Riset AI"** / **"Kendala Memuat Ruang Riset"**. "Ruang Riset" adalah label menggelembung untuk kotak chat NotebookLM. Tidak ada yang menyebut chat box "ruang riset". → cukup nama agent, atau "Tanya AI".
- `agent_webview:214` — "sedang dalam proses **kurasi naskah kitab primer**" → "Kami sedang menyiapkan kitab-kitabnya."
- `subscription_screen:240` — "Pilih **Paket Ruang Riset**" + "Beli paket **1 AI satuan**" → "Pilih Paket" / "Akses satu modul, atau semua modul."
- `profile_screen:444-445` — "**Panduan Peneliti Turats** · **Metodologi sitasi & riset berbasis AI**" → judul "Panduan", subjudul "Cara memakai OpenTurath".
- `google_session_auth:141` — "**Menyiapkan akses korpus riset kitab...**" → "Menyiapkan…" / "Mohon tunggu…".

### 4.3 Campur bahasa Inggris-Indonesia dalam satu menu/dialog (sangat AI-codegen)
- `agent_webview:663-686` — menu berisi **`Delete chat history`** (Inggris) tepat di atas **`Muat Ulang Halaman`** (Indonesia) dan **`Kelola Langganan AI`**. Tidak ada tim manusia yang merilis menu seperti ini. → "Hapus Riwayat Chat".
- `agent_webview:438-446` — seluruh dialog hapus chat berbahasa Inggris ("Delete chat history for this notebook? All messages in this session will be permanently cleared.") padahal dialog lain semua Indonesia. → "Hapus riwayat chat? Semua pesan di sesi ini akan dihapus."

### 4.4 Instruksi ke fitur yang TIDAK ADA (halusinasi yang dikirim ke produksi)
- `profile_screen:454` — "Selalu verifikasi dalil dengan menekan nomor sitasi [1] atau **tombol Maktabah Syamilah**." Tidak ada tombol Maktabah Syamilah di layar mana pun yang diaudit. Ini **instruksi palsu** ke fitur yang tidak ada.

### 4.5 Nama meminjam merek produk lain
- `profile_screen:393` — **"Mode Gelap (Obsidian)"** / **"Mode Terang (Gemini)"**. Obsidian & Gemini adalah merek produk lain. → "Mode Gelap" / "Mode Terang".
- `profile_screen:469` — "Didukung **Google NotebookLM Engine**" (selain membocorkan vendor) dan versi hardcoded `1.0.4` (padahal pubspec `1.0.8+9`).

### 4.6 Hard-sell harga di dalam pesan error
- `agent_webview:227,303` — error paywall menyertakan daftar harga penuh "...Rp 50.000/bln atau Paket Promo Semua AI Rp 99.000...". Harga seharusnya di layar paywall, bukan di dalam pesan error. → "Modul ini khusus pelanggan. Lihat pilihan paket untuk melanjutkan."

### 4.7 Campuran register "Alhamdulillah" + bahasa sistem
- `subscription_screen:154` — "**Alhamdulillah!** Pembayaran berhasil. **Akses ruang riset Anda telah aktif!**" → "Alhamdulillah, pembayaran berhasil. Akses Anda sudah aktif."

### 4.8 Inkonsistensi ejaan/kata
- `field_model:39` pakai **"Hadis"** tetapi `agent_model` pakai **"Hadits"** (kata yang paling sering dipakai di app). Pilih satu.
- `agent_model` deskripsi `habib_umar:628` tulis "muhadoroh" (salah) tetapi `subtitle:633` tulis "Muhadharah" (benar) — file berdebat dengan dirinya sendiri dalam 5 baris.
- Dua nama app Arab berbeda: `constants:4` `'الذكاء الاصطناعي للعلوم الإسلامية'` vs `localization` `'أوبن تراث الذكاء الاصطناعي'`.

**Skor copywriting:** ~75% baik (bagian fiqh mazhab otentik), ~25% "AI-slop" (superlatif, jargon, campur bahasa, instruksi hantu). Perlu satu kali penyuntingan manusia menyeluruh.

---

## 5. FITUR & ELEMEN YANG TIDAK PERLU (CLUTTER)

1. **Perang menyembunyikan UI Google** (`agent_webview:55-410`) — ~350 baris CSS/JS + MutationObserver + 4 timer untuk menghapus bagian produk milik orang lain. Over-engineering yang menjamin jank & kerapuhan. **Sederhanakan:** muat URL `/preview` apa adanya, atau bangun chat native.
2. **Tombol "Buka Langsung Mode Riset"** (`agent_webview:905-918`) — backdoor paywall yang eksplisit. **Hapus.**
3. **Tile "Bahasa Antarmuka" yang tidak berfungsi** (`profile:406-413`) — hanya snackbar. Hapus sampai multi-bahasa benar-benar ada.
4. **Duplikat toggle tema** — di Profile (`:384-404`) dan rail desktop (`main_shell:151-161`).
5. **3 jalur masuk ke paywall dari satu layar** — menu WebView + tombol error + tile Profile.
6. **Tombol "Share/Bagikan" yang hanya menyalin** (`agent_webview:606-614`) — label berlebihan; implementasi share sheet nyata atau hapus.
7. **Dua layanan bookmark/notes yang identik** — `BookmarkService` (`openturath_saved_bookmarks`) vs `ResearchNotesService` (`openturath_research_notes_v1`). Gabung.
8. **Nama plan berbeda-beda untuk hal yang sama** — Profile ("Sultan/Rumpun/Satuan") vs Subscription ("Promo/Tahunan"). Satukan.
9. **Subjudul AppBar dekoratif di Bookmark** (`:182-188`) — hanya mengulang apa itu bookmark.
10. **Komentar `// ── ... ──` dan em-dash sebagai gaya** — tanda tangan AI-codegen yang bertebaran.

---

## 6. CACAT KODE & BUG

### 6.1 Keamanan/secret
- `auth_service.dart:12` — **Google OAuth `serverClientId` di-hardcode** di source.
- `agent_service.dart:14-35` — 9 URL NotebookLM produksi di-hardcode (lihat §2.1).
- `agent_webview:717-720` & `doku_checkout_sheet` — WebView sangat permisif (`MIXED_CONTENT_ALWAYS_ALLOW`, `allowFileAccess`, third-party cookies, `javaScriptCanOpenWindowsAutomatically`, `onPermissionRequest` GRANT semua). Berbahaya pada halaman yang berurusan dengan pembayaran/auth.

### 6.2 Kebocoran memori & siklus hidup
- `agent_webview:181,398` MutationObserver + `:401-405` `setInterval` 50× **tidak pernah diputus** saat dispose.
- `agent_webview:762-777` empat `Future.delayed` yang menangkap `this` dan memanggil kerja setelah dispose; `dispose()` hanya men-null controller.
- `update_service.dart:153` `HttpClient` tidak pernah di-`close()`; file `.tmp` download yang menggantung tidak dibersihkan.
- `main_shell:56-70,167,194` `_buildScreens()` dipanggil tiap build & `AnimatedSwitcher` me-recreate layar aktif tiap pindah tab → **state tab (scroll, webview) hilang setiap ganti tab**.

### 6.3 Bug logika
- `app_config.dart:15-20` — `ThemeMode.system` disimpan tapi **tidak pernah direstore** saat restart (selalu jatuh ke dark/light). Setting "Sistem Default" rusak.
- `user_model.dart:84` `isGuest` vs `auth_service.dart:99` (guest diberi email `'tamu@openturath.ai'`) → anonymous Firebase user salah diklasifikasi.
- `user_model.dart:118-122` `getEntitlement` prefix-match non-deterministik bila ada dua kunci yang saling prefix.
- `arabic_utils.dart:23` — normalisasi mengubah `ؤ/ئ → ء` memecah kata (`مؤمن→مءمن`); normalizer pencarian Arab yang keliru.
- `update_service.dart:89` — `int.tryParse(buildNumber) ?? 0` → bila buildNumber kosong, **setiap** versi server memicu "update paksa".
- `bookmark_screen:63-64` — filter kategori substring (`Fikih` cocok juga `Usul Fiqh`) → hasil salah.
- `subscription_screen:291` — `DropdownButtonFormField` pakai `initialValue` (bukan `value`) → bisa snap-back ke nilai awal saat rebuild.
- `field_model.getById` — unknown id diam-diam mengembalikan bidang pertama (Fikih) = jawaban salah yang diam-diam.

### 6.4 Dead code
- `auth_service.dart:78-80` `catch (e) { rethrow; }` (mati).
- `agent_service.dart:66-69` blok fallback tak terjangkau setelah try/catch sudah return.
- `agent_model.dart` field `akalUrl1m/6m/1y` di-parse tapi tak pernah dipakai.
- `subscription_service.dart:60-65` `checkPaymentStatus` "Legacy" yang tidak dipakai.
- `user_model.dart:140` `hasAccessToAgent` = passthrough mati; `:103-106` & `:144-147` dua implementasi `questionsRemaining` duplikat.
- Dua penghitung pertanyaan bersaing: `AgentService.recordQuestion` vs `AuthService.incrementQuestionCount` (keduanya tidak dipakai di jalur WebView).

### 6.5 catch(_) menelan error (~20 tempat)
Beresiko tinggi: penghitungan kuota trial gagal diam-diam (user bisa melewati batas), korupsi bookmark → hilang tanpa jejak, kegagalan hapus akun tak terlihat. Tanpa telemetry/Crashlytics, bug produksi tidak akan pernah terlihat.

---

## 7. DESAIN SISTEM (THEME) YANG BOCOR

- **Tiga sistem penamaan paralel** untuk warna yang sama (`canvasDark` / `lmDarkCanvas` / `bgCanvas`) + ~55 baris **alias mati** (`theme.dart:43-101`). Hapus.
- **Token `gold`/`goldBright`/`goldMuted` menipu** — isinya biru/cyan (`theme.dart:87-89`), bukan emas. Nama warisan yang menyesatkan.
- **4 keluarga aksen bercampur**: biru Google (light), cyan elektrik (dark), emerald (sukses bayar), hijau material (banner update) — dua merek berbeda dalam satu app.
- **Widget melewati token** — ~35 warna hex hardcode di `app_snackbar`, `turath_crystallization_overlay` (emerald `0xFF10B981` + cyan `0xFF00E5FF` yang off-brand), `doku_checkout_sheet`, `update_ready_banner`, `evidence_bottom_sheet`.
- **Dead code tema**: `agentGradient(agentId)` mengabaikan parameter; `bgGradient` = "gradien" antara warna & dirinya sendiri; `radiusFull` == `radiusPill`.
- **Tipografi**: semuanya `GoogleFonts.outfit` (baik), tapi Arab `titleArabic` tidak konsisten memakai Amiri — fallback sistem tak terduga; ukuran non-standar (13.5, 11.5) tersebar.

---

## 8. FITUR WAJIB YANG HILANG

| # | Fitur | Kenapa wajib |
|---|---|---|
| 1 | **In-App Purchase (Google Play Billing / App Store IAP)** | Menjual akses digital via webview eksternal = pelanggaran kebijakan; app bisa ditolak/diturunkan. Perlu restore purchase, verifikasi receipt, lifecycle langganan. |
| 2 | **Layar Settings** | Tidak ada. Perlu: ukuran font Arab (kritis untuk app kitab), notifikasi, ekspor data. |
| 3 | **Privacy Policy & Terms links + Licenses** | Bagian "Legalitas" hanya berisi panduan & about. Play mewajibkan privacy policy (ada pembayaran + hapus akun + webview login Google). |
| 4 | **Hapus akun yang benar + URL web** | `deleteAccount` ada tapi tidak bisa menghapus data NotebookLM (tidak diakui), menelan kegagalan Firestore, dan tidak ada jalur web. |
| 5 | **Offline/connectivity awareness** | Tidak ada banner offline, retry queue; error webview membocorkan teks engine mentah. |
| 6 | **Share/Export nyata** | Riset tanpa ekspor sitasi tidak lengkap; "share" sekarang hanya salin URL. |
| 7 | **Crash reporting + consent** | Tidak ada Crashlytics/analytics gate; padahal app membaca cookie sesi Google. |
| 8 | **Aksesibilitas (a11y)** | Tidak ada Semantics/semanticLabel, target <48dp, tidak ada dukungan textScale (penting untuk ulama sepuh). |
| 9 | **Remote Config / katalog dinamis** | Harga, nama plan, agent, URL notebook semua hardcoded → perubahan harga butuh rilis app. |
| 10 | **Onboarding penjelasan dependensi NotebookLM** | Pengguna dipaksa login Google dua kali tanpa penjelasan kenapa / data apa yang dilihat Google. |
| 11 | **Guest mode yang benar** | Ada `signInAsGuest` di service tapi **tidak ada tombolnya di UI**; guest pakai satu UID tetap `guest_user` (tabrakan data semua tamu). |

---

## 9. PRIORITAS PERBAIKAN

> Urut dampak, bukan kemudahan.

### P0 — Monetisasi & kebenaran (hari ini)
1. **Hapus `defaultAgentUrls` dari client** dan tombol "Buka Langsung Mode Riset". URL NotebookLM hanya dari server setelah entitlement valid.
2. **Perbaiki trial gate**: pengguna trial harus bisa membuka agent dan dihitung lewat `recordQuestion` (server) per pertanyaan — bukan ditolak di depan.
3. **Satu angka AI**: sinkronkan "13 katalog / 10 / 30" menjadi satu kebenaran (jumlah modul aktif nyata). Perbaiki `field_model` `specialistCount`/`agentIds` agar sesuai kenyataan (atau isi agent-nya).
4. **Hapus nomor/nama/email palsu** dari jalur pembayaran; minta input nyata atau ambil dari akun.

### P1 — Kebijakan & kejujuran UX (minggu ini)
5. Putuskan & implementasi **Play Billing** (atau risiko ditolak). Hormati langganan lama.
6. Hapus **konfirmasi palsu** ("Riwayat chat dihapus" padahal tidak; "hapus akun menyeluruh" padahal tidak menyentuh data Google).
7. Tambah **Privacy Policy / Terms / Licenses**; perbaiki klaim hapus akun.
8. Hentikan copy **instruksi ke fitur yang tidak ada** (Maktabah Syamilah).

### P2 — Copywriting & konsistensi (1–2 hari, satu penyuntingan manusia)
9. Edit menyeluruh: hapus superlatif palsu, jargon menumpuk, campur bahasa, em-dash berlebih. Ganti "Ruang Riset/Obsidian/Gemini/Paket Sultan" dgn istilah netral yang konsisten. Satukan ejaan "Hadis/Hadits", satu nama app Arab, satu nama per-plan.
10. Hapus tile/elemen yang tidak berfungsi (Bahasa Antarmuka), gabungkan dua layanan bookmark.

### P3 — Kode & ketahanan (mingguan)
11. Bersihkan dead code & alias tema; satukan satu sistem token; pindahkan warna hardcode ke token.
12. Perbaiki kebocoran memori (MutationObserver/timer/HttpClient) & state tab yang hilang di shell.
13. Ganti ~20 `catch(_)` dengan penanganan + Crashlytics + pesan manusiawi; tambah deteksi offline + retry.
14. Perbaiki `ThemeMode.system` restore, guest detection, filter kategori, `DropdownButtonFormField` controlled, `update_service` buildNumber.

### P4 — Aksesibilitas & pemolesan
15. Tambah Semantics/semanticLabel, target ≥48dp, dukung textScale; setting ukuran font Arab.
16. Sederhanakan top bar WebView; kurangi DOM-scraping; pertimbangkan jalan panjang ke chat native (lihat ARCHITECTURE.md §11.3).

---

## LAMPIRAN — Bukti cepat (file:baris)
| Temuan | Bukti |
|---|---|
| Paywall bypass (fallback URL) | `services/agent_service.dart:14-35,54,61,67` · `screens/agent_webview_screen.dart:237-244,905-918` |
| Trial gate rusak | `screens/agent_webview_screen.dart:224` · `models/user_model.dart:140` |
| Angka AI bertentangan | `models/agent_model.dart` (13) · `screens/subscription_screen.dart:377-386` (10) · `screens/profile_screen.dart:197` (30) |
| ID agent hantu | `models/field_model.dart:42-124` vs `models/agent_model.dart` |
| Identitas palsu bayar | `screens/subscription_screen.dart:95,115` · `screens/profile_screen.dart:180` |
| Hapus chat palsu | `screens/agent_webview_screen.dart:538-553` |
| Settings tidak ada | `core/routes.dart` · tidak ada `screens/settings_screen.dart` |
| Tile bahasa buntu | `screens/profile_screen.dart:406-413` |
| Copy superlatif | `models/agent_model.dart:180,312,424,473,511,522,565` |
| Fitur hantu | `screens/profile_screen.dart:454` (Maktabah Syamilah) |
| Theme bocor | `core/theme.dart:43-101,87-89,114-130` |
| ThemeMode.system rusak | `core/app_config.dart:15-20` |
| WebView permisif | `screens/agent_webview_screen.dart:717-720,733-738` |

---
*— Akhir audit UI/UX · Fitur · Copywriting · Kode —*
