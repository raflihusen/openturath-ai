# 🍎 AUDIT APPLE-LEVEL DESIGN — OPENTURATH AI

> **Jenis:** Audit UI/UX mendalam berbasis kode, dibandingkan terhadap **Apple Human Interface Guidelines (HIG)** dan standar "Apple-level design".
> **Versi yang diaudit:** `1.0.14+15` · **Tanggal:** September 2026
> **Metode:** Pembacaan langsung seluruh kode sumber `lib/` (7 layar + 27 file models/services/widgets/core) dan pemetaan ke 6 pilar HIG Apple: **Clarity, Deference, Consistency, Typography, Interaction & Motion, States/Resilience**, plus copywriting, aksesibilitas, dan kualitas kode.
> **Status:** Read-only. Tidak ada berkas yang diubah.

---

## DAFTAR ISI

1. [Ringkasan Eksekutif & Skor](#1-ringkasan-eksekutif--skor)
2. [Enam Pilar Apple HIG — Bedah Mendalam](#2-enam-pilar-apple-hig--bedah-mendalam)
   - 2.1 Clarity · 2.2 Deference · 2.3 Consistency · 2.4 Typography · 2.5 Interaction & Motion · 2.6 States & Resilience
3. [Aksesibilitas (Accessibility)](#3-aksesibilitas-accessibility)
4. [Copywriting — AI-Slop vs Manusiawi](#4-copywriting--ai-slop-vs-manusiawi)
5. [Lokalisasi, RTL & Tipografi Arab](#5-lokalisasi-rtl--tipografi-arab)
6. [Cacat Kode, Bug & Kebocoran Memori](#6-cacat-kode-bug--kebocoran-memori)
7. [Clutter & Over-Engineering](#7-clutter--over-engineering)
8. [Fitur yang Hilang untuk Standar Premium](#8-fitur-yang-hilang-untuk-standar-premium)
9. [Peta Jalan Menuju Apple-Level (Prioritas)](#9-peta-jalan-menuju-apple-level-prioritas)

---

## 1. RINGKASAN EKSEKUTIF & SKOR

### Penilaian keseluruhan
Aplikasi ini **melek visual** — jelas meniru estetika minimalis Claude/Apple, dan melakukan banyak hal dengan benar: disiplin token di shell, cakupan haptics yang baik, paritas dark/light yang nyata, whitespace yang lega, dan kartu dengan hairline 1px + elevation 0. Itu fondasi yang kuat.

Namun ia **belum mencapai standar Apple** karena empat masalah struktural:

1. **Layar inti adalah WebView DOM-scraping yang rapuh** — bukan antarmuka native. Ini menentang platform *dan* melawan app pihak ketiga yang dibungkusnya.
2. **Tipografi "skizofrenia"** — dua sistem (serif Newsreader + sans Outfit) tanpa aturan hierarki yang ditegakkan.
3. **Sistem desain dilanggar puluhan kali** — warna/radius/spacing hardcode melewati token yang seharusnya jadi sumber kebenaran.
4. **Copywriting "AI-slop"** — jargon menumpuk, klaim berlebihan, campur bahasa, dan instruksi ke fitur yang tidak ada.

### Skor per pilar (0–10, benchmark Apple = 9–10)

| Pilar HIG | Skor | Alasan singkat |
|---|---|---|
| **Clarity** | 5.5 | Dua H1 bersaing di dashboard; hierarki terbalik; kontras teks tersier gagal AA; truncation di layar kecil. |
| **Deference** | 6.0 | Chrome native cukup bersih, tapi WebView **menghapus disclaimer vendor** (bertentangan dengan deference konten). |
| **Consistency** | 4.0 | Terlemah. 3+ palet aksen, 12 nilai radius vs 6 token, spacing keluar grid 4/8pt, ikon berbeda untuk konsep sama. |
| **Typography** | 4.5 | Dua font tanpa aturan; ukuran fraksional (11.5/13.5/16.5); Newsreader di luar theme; tidak ada Dynamic Type; Arab tidak konsisten. |
| **Interaction & Motion** | 6.0 | Haptics bagus, tapi target sentuh <44pt di layar inti; animasi replay tiap rebuild; carousel auto-play tanpa kontrol pause. |
| **States & Resilience** | 4.5 | Error mentah bocor ke pengguna; tidak ada state offline; paywall menyesatkan; ~12 `catch(_)` senyap. |
| **Accessibility** | 3.5 | Kritis. Tidak ada Dynamic Type, Semantics hampir nol, kontras gagal, reduced-motion diabaikan. |
| **Copywriting** | 5.0 | ~70% otentik (fiqh), ~30% AI-slop (superlatif palsu, jargon, campur bahasa). |
| **Craft/Polish** | 5.5 | Detail ada, tapi banyak placeholder, hardcode, dan dead code. |

**Skor komposit: ±5.0/10** — "sangat bagus untuk Flutter", tapi belum "Apple-level".

---

## 2. ENAM PILAR APPLE HIG — BEDAH MENDALAM

### 2.1 CLARITY (Kejelasan)

Apple: *"Teks mudah dibaca, ikon presisi, elemen dekoratif menopang (bukan mendistraksi), dan fungsi jelas dari bentuk."*

| # | Temuan | Lokasi |
|---|---|---|
| 2.1.1 | **Dua H1 bersaing di satu layar.** `'OpenTurath'` (Newsreader 24, w600) dan `'Ahlan, {nama}'` (Newsreader 24/26, w500) ditumpuk berjarak ~40px → tidak ada titik fokus dominan. Apple memakai satu Large Title, sapaan jadi subjudul. | `dashboard:195`, `dashboard:259` |
| 2.1.2 | **Hierarki terbalik.** Judul seksi "Pilih Bidang Ilmu" (Outfit 16, w700) lebih kecil dari dua header 24pt di atasnya, padahal itu elemen paling bisa ditindak. | `dashboard:440` |
| 2.1.3 | **Kartu carousel terlalu padat.** `height:146` fixed dengan 3 blok teks → akan truncate pada text-scale >1.15 atau layar kecil; tidak ada penanganan `MediaQuery.textScaler`. | `dashboard:918` |
| 2.1.4 | **Judul pricing bisa melar.** Judul plan interpolasi nama agent 40+ karakter, Newsreader 20 tanpa `maxLines`/overflow → wrap jelek dan mempertinggi kartu. | `subscription:602` |
| 2.1.5 | **AppBar WebView padat.** 4 widget trailing (trial pill + copy + bookmark + font) masing-masing 36px memeras judul agent hingga ellipsis tidak berguna di layar 320dp. | `agent_webview:1077-1157` |
| 2.1.6 | 🔴 **Kontras teks tersier GAGAL WCAG AA.** `textTertiaryLight #A1A1AA` di atas putih = **2.5:1**; `textTertiaryDark #71717A` di atas `#0E0E10` = **2.9:1**. Keduanya < 4.5:1. Dipakai untuk konten nyata (hint pencarian, label nav non-aktif), bukan sekadar dekorasi. | `theme.dart:14,32` |
| 2.1.7 | **Baris spesialis membuang subtitle/deskripsi.** Model punya `subtitleAcademic` & `description`, dicari saat search, tapi **tidak pernah dirender** — pengguna tidak bisa membedakan agent hanya dari judul telanjang. Minimalisme yang menghapus informasi yang dibutuhkan. | `specialist_list:449-460` |
| 2.1.8 | **Klaim data hardcode di UI.** `'1.500+ Muhadharah Suara & Kitab Lengkap...'` ditulis literal di kartu, bukan dari model. Bila korpus berubah, UI berbohong. | `specialist_list:610` |
| 2.1.9 | **Grid kartu center-aligned** mengurangi scannability (Apple grid = left-align); label `'N spesialis'` tidak konsisten kapitalisasi dengan cabang singular. | `dashboard:535-562` |

### 2.2 DEFERENCE (Menghormati konten)

Apple: *"UI cair dan tajam yang menopang konten, bukan bersaing dengannya."* Konten di sini = **kitab & telaah**.

| # | Temuan | Lokasi |
|---|---|---|
| 2.2.1 | ✅ Chrome native cukup terkendali (hairline 1px, elevation 0, tanpa bayangan/gradien berlebih). Ini kekuatan nyata. | `theme.dart:187,358` |
| 2.2.2 | 🔴 **WebView me-re-skin app orang lain secara paksa** (110+ baris CSS `!important`) — bukan deference, tapi pembungkusan. Selector over-broad (menyembunyikan semua tombol berlabel "Copy/Create/Settings" Inggris+Indonesia) berisiko menghapus UI sah. | `agent_webview:108-218,121-124` |
| 2.2.3 | 🔴 **Disclaimer akurasi AI vendor DIHAPUS**, bukan di-defer. `eradDisclaimer` menyapu DOM mencari "inaccurate/can make mistakes/bisa saja tidak akurat" lalu menyembunyikannya — sementara dialog Adab app sendiri bilang "bukan mufti". Menghapus peringatan Google sambil mengklaim ketelitian keilmuan = **kontradiksi langsung & potensi pelanggaran ToS**. | `agent_webview:241-298` |
| 2.2.4 | Bahasa kedalaman tidak konsisten: native 100% flat, satu-satunya drop-shadow justru ada di tombol hijau yang di-injeksi ke dalam WebView. | `agent_webview:419` |
| 2.2.5 | ✅ Whitespace lega (`20,16,20,96`) adalah kekuatan. | `dashboard:181` |

### 2.3 CONSISTENCY (Konsistensi) — *terlemah*

Sistem desain (`AppTheme`) ada, tapi **dilanggar rutin**.

| # | Temuan | Lokasi |
|---|---|---|
| 2.3.1 | 🔴 **Puluhan warna hardcode melewati token.** Palet "slate/blue" paralel (`0xFF14171F`, `0xFF1E283A`, `0xFF93C5FD`, `0xFF2563EB`, `0xFF1E293B`, `0xFF334155`, `0xFF94A3B8`) di dashboard & kartu Tahawwulat — tidak ada di token. Success `0xFF10B981` & warning `0xFFD97706` & error `0xFFEF4444` tersebar mentah, padahal `AppTheme.success/error/warning` ada tapi tidak dipakai. Hasil: **≥3 sistem aksen bersaing** (hitam monokrom / cyan neon / slate-biru / hijau emerald / amber). | `dashboard:290-346`, `specialist_list:532-592`, `agent_webview:1133-1426` |
| 2.3.2 | 🔴 **12 nilai radius vs 6 token.** Token: 8/12/16/20/28/100. Dipakai juga: 5,6,8,10,12,14,16,18,20,24,28,100. Tombol/kartu/dialog/sheet masing-masing pakai radius berbeda; `cardTheme` bilang 20, kartu buatan tangan pakai 16. | `theme.dart:104-111`, berbagai layar |
| 2.3.3 | **Spacing keluar grid 4/8pt.** Banyak nilai fraksional/arbitrary: `2.5`, `3.5`, `7`, `15`, `18`, `22`. | `dashboard:202,331,352`, `agent_webview:1103`, dst. |
| 2.3.4 | **Ikon berbeda untuk konsep sama.** "Buka/lanjut" pakai 4 glyph berbeda (`arrow_forward_ios`, `chevron_right`, `arrow_forward`, `arrow_outward`). | `dashboard:364,480,704,987` |
| 2.3.5 | **Pola press-scale tidak konsisten** — 3 implementasi berbeda (`AppleInteractiveWrapper` vs `_PricingCard` vs `_SlimSpecialistRow`) dengan durasi & skala berbeda (0.98/0.985/0.975, 120/140ms), dan sebagian permukaan hanya `InkWell` tanpa scale. | `apple_interactive_wrapper`, `subscription:559`, `specialist_list:424` |
| 2.3.6 | **Font judul AppBar tidak konsisten** — Newsreader (24/21/22) di 3 layar, Outfit (18/16) di 3 layar; `centerTitle` juga tidak konsisten. Top bar terasa berbeda di tiap tab. | `dashboard:195`, `profile:181`, `subscription:297`, `bookmark:207`, `specialist:182`, `agent_webview:1081` |

### 2.4 TYPOGRAPHY

| # | Temuan | Lokasi |
|---|---|---|
| 2.4.1 | 🔴 **Newsreader sepenuhnya di luar theme.** `_buildTextTheme` hanya pakai Outfit — tidak ada satu pun gaya Newsreader yang ikut `Theme.of(context).textTheme`. Setiap pemakaian serif hardcode ukuran/weight/tracking sendiri. Tidak ada aturan "serif untuk X, sans untuk Y". | `theme.dart:471-484` |
| 2.4.2 | 🔴 **Ukuran fraksional non-standar** di mana-mana: 9.5, 10.5, 11.5, 12.5, 13.5, 15.5, 16.5. Apple memakai skala modular (11/13/15/17/20/22/28/34). **9pt & 9.5pt di bawah batas keterbacaan.** | `dashboard:968,343`, dll |
| 2.4.3 | 🔴 **Tidak ada Dynamic Type / text-scale.** Semua `fontSize:` tetap; tidak ada `textScaler` clamping; kontainer fixed-height (carousel 146, search 48, pill 42/38) akan pecah pada teks besar. Zoom font in-app hanya menskalakan WebView via CSS injeksi, bukan UI native. **Kesenjangan aksesibilitas terbesar.** | seluruh layar |
| 2.4.4 | **Tipografi Arab tidak konsisten.** Amiri dipakai di 3 tempat dengan weight berbeda (w700 vs bold) & hanya satu yang set line-height 1.6/1.7 (penting agar harakat tidak terpotong). Dialog Adab Arab tanpa `textDirection: rtl`. | `agent_webview:1524`, `specialist_list:588`, `bookmark:597` |
| 2.4.5 | **Letter-spacing serampangan** (-0.2 s/d -0.8 tanpa token). | berbagai |
| 2.4.6 | **Harga lebih keras dari nama produk** (`FontWeight.w800` 26pt) — secara tipografis harga tidak boleh mengalahkan nama produk. | `subscription:615-617` |

### 2.5 INTERACTION & MOTION

| # | Temuan | Lokasi |
|---|---|---|
| 2.5.1 | 🔴 **Target sentuh <44pt di layar inti.** Tiga IconButton dipaksa `BoxConstraints(minWidth:36, minHeight:36)` + `VisualDensity.compact`. Untuk aksi salin/bookmark yang sering dipakai, ini regresi kegunaan & aksesibilitas demi memuat 4 aksi. | `agent_webview:1128-1156` |
| 2.5.2 | 🔴 **Tombol hapus bookmark berbahaya** — ikon 18px dalam IconButton `padding:EdgeInsets.zero, constraints:BoxConstraints()` → target ~18-24px. Aksi destruktif sub-20px di sebelah tombol share. | `bookmark:527-536,640` |
| 2.5.3 | ✅ **Haptics cakupan bagus** (selectionClick/lightImpact/mediumImpact). Di atas rata-rata Flutter. | `main_shell:279`, `profile:939`, dll |
| 2.5.4 | **Animasi looping yang boros/jank.** Loader 3-titik `repeat()` di atas WebView live; carousel auto-play tiap **8 detik** tanpa kontrol pause (WCAG 2.2.2). | `agent_webview:1760`, `dashboard:801` |
| 2.5.5 | **Pill `GestureDetector` tanpa feedback visual** — hanya haptic, tanpa ripple/highlight/opacity. HIG mewajibkan feedback sentuh terlihat. | `specialist_list:279`, `bookmark:319` |
| 2.5.6 | 🔴 **Animasi entrance replay tiap rebuild.** `TweenAnimationBuilder` di dalam `StreamBuilder` pada `userStream` → tiap update user, list recent re-animate dari 0 → flicker. | `dashboard:152,631-643` |

### 2.6 STATES & RESILIENCE

| # | Temuan | Lokasi |
|---|---|---|
| 2.6.1 | 🔴 **Error mentah bocor ke pengguna.** `'Gagal menyalin telaah: $e'`, `'Gagal memuat laman riset (${error.description})'`, `'Gagal membuat pembayaran DOKU: $err'` — stack/enum engine tampil ke santri. | `agent_webview:941,1029,1341`, `subscription:234,264` |
| 2.6.2 | 🔴 **Paywall menyesatkan.** Bila Google menolak akses ("You need access"), app menampilkan "beli paket Rp 50rb/99rb" — padahal masalahnya di sisi Google, membeli tidak menyelesaikan. Error → CTA yang salah. | `agent_webview:672-678` |
| 2.6.3 | **Tidak ada state offline.** Timeout 4s diam-diam fallback ke data default tanpa banner "Anda offline / menampilkan cache". Pengguna tak bisa membedakan data live vs stale. | `dashboard:48-74` |
| 2.6.4 | **Empty state tidak konsisten** (Bookmark bagus; Specialist minimal; Dashboard recent hampir tak terjangkau karena `_getRecentAgents` selalu back-fill). | `dashboard:115-140,600-619` |
| 2.6.5 | **~12 `catch(_)` senyap** → kegagalan tak terlihat oleh pengguna & developer (tanpa logging). Bug lapangan tak ter-debug. | banyak file |

---

## 3. AKSESIBILITAS (ACCESSIBILITY) — *paling kritis untuk audiens ulama sepuh*

| # | Temuan | Dampak |
|---|---|---|
| 3.1 | 🔴 **Tidak ada Dynamic Type** — teks tetap, kontainer fixed-height, ukuran 9–11.5pt. | Pengguna yang memperbesar font sistem melihat layout pecah/terpotong. |
| 3.2 | 🔴 **Kontras teks tersier gagal WCAG AA** (2.5–2.9:1). | Sulit dibaca pengguna dengan penglihatan menurun. |
| 3.3 | 🔴 **Semantics hampir nol.** Hanya 1 `Semantics()` di seluruh app (`openturath_brand`). `AppleInteractiveWrapper` pakai `GestureDetector` → **tidak menambah semantik "button"**; TalkBack/VoiceOver tidak mengenali kartu sebagai actionable. | App praktis tidak bisa dipakai pengguna screen reader. |
| 3.4 | **Target sentuh <44pt** di aksi inti & destruktif. | Fat-finger & salah hapus. |
| 3.5 | **Reduced-motion diabaikan** — loader looping, elastic bounce, pulsing overlay tidak menghormati `disableAnimations`. | Masalah vestibular. |
| 3.6 | **Ibarah Arab tanpa `semanticsLabel`** — screen reader membaca glyph Arab sebagai Latin. | Konten inti tak terbaca. |
| 3.7 | **Snackbar durasi 2.2 detik** terlalu singkat untuk dibaca pada teks besar. | Pesan hilang sebelum dibaca. |

---

## 4. COPYWRITING — AI-SLOP VS MANUSIAWI

**Skor: ~70% otentik (khususnya fiqh mazhab), ~30% AI-slop.** Register pesantren (`ibarah`, `mu'tabarah`, `qaul mu'tamad`) autentik & domain-benar. Tapi terseret oleh klaim kuantitatif tak terverifikasi, superlatif sistematis, pengulangan template, dan campur bahasa.

### 4.1 Klaim palsu / berlebihan di produk BERBAYAR (risiko sengketa)
| Lokasi | Kutipan | Masalah |
|---|---|---|
| `agent_model:82` | "**1.500+ muhadharah** suara & naskah kitab **lengkap**" | Angka presisi-palsu + "lengkap" absolut |
| `agent_model:226` | "Rujukan fatwa **pamungkas** mazhab Hanafi" | "pamungkas" = hiperbola poster |
| `agent_model:358` | "**Karya agung** perbandingan mazhab" | pujian subjektif, bukan deskripsi |
| `agent_model:424` | "**Khazanah** tafsir ... **komprehensif** berbasis **korpus** kitab tafsir **mu'tabarah**" | 5 buzzword dalam 10 kata |
| `agent_model:456` | "Tafsir bil ma'tsur **paling muktamad dan masyhur di dunia Islam**" | superlatif ganda + klaim global |
| `agent_model:407` | "Kitab hadits **paling shahih rujukan utama** umat Islam" | filler |
| `dashboard:336` | "Akses **komprehensif** ke korpus naskah primer ... dengan **analisis komparatif instan**" | marketer-speak |

### 4.2 Jargon menumpuk (tidak manusiawi)
- `dashboard:764` — "mengintegrasikan ribuan halaman naskah primer ... dengan **kemampuan pemrosesan bahasa alami** ... secara presisi" → *"membantu menelusuri kitab kuning asli, dengan rujukan halaman."*
- `dashboard:780` — "**perkakas indeksasi dan komparasi literatur**, bukan mufti" → *"alat bantu mencari referensi — bukan mufti."*
- `profile:864` — "**finalisasi kurasi kebahasaan**" → *"Bahasa Arab & Inggris segera hadir."*
- `subscription:357` — "sekaligus **secara simultan**" (redundan) → hapus salah satu.
- `agent_webview:1537` — "perkakas digital pelacak ibarah dan komparasi" → *"alat bantu menelusuri ibarah kitab kuning."*

### 4.3 Campur bahasa & register tidak konsisten
- `profile:484` "Log out" (Inggris) di UI Indonesia; `bookmark:160` "Kecerdasan Buatan Turats Islam" (terjemahan kaku); badge kadang value-prop kadang nama agent. **Pilih satu register.**
- Inkonsistensi ejaan: **Fiqh/Fikih**, **Hadits/Hadis**, **mu'tamad/muktamad**, **Ushul Fiqih/Usul Fiqh** — dalam file yang sama.

### 4.4 Instruksi ke fitur yang tidak ada (halusinasi ke produksi)
- Masih ada penyebutan **tombol Maktabah Syamilah / nomor sitasi [1]** sebagai aksi yang harus ditekan — padahal itu bukan UI yang konsisten ada.

### 4.5 Kesalahan faktual/linguistik
- `agent_model:121-122` — Judul Latin "…Sunan Al-Khalaq" vs Arab "…سنن الخلق **والبيان**" (Arab punya kata ekstra).
- `field_model:25` — satu bidang dinamai "sanad Al-Habib Abu Bakar Al-Masyhur" (mencampur bidang ilmu dengan merek seorang ulama).

---

## 5. LOKALISASI, RTL & TIPOGRAFI ARAB

| # | Temuan | Lokasi |
|---|---|---|
| 5.1 | 🔴 **Lokalisasi hanya ~1%.** `localization.dart` punya 22 key × 3 bahasa, tapi `Loc.tr(` hanya dipanggil **1×** di seluruh app (`main.dart:93`). Ratusan string hardcode Indonesia. Kamus `en`/`ar` = dead code. Menawarkan "locale Arab" yang hanya mengubah judul app lebih buruk daripada tidak menawarkan. | `localization.dart`, `main.dart:93` |
| 5.2 | **RTL ada tapi kosong.** `Directionality(rtl)` di main saat locale `ar` — tapi kamus `ar` tak dipakai, jadi tak berarti. | `main.dart:99-102` |
| 5.3 | **Fallback salah arah** — key hilang jatuh ke Inggris, bukan Indonesia; bila hilang total, render raw key seperti `'manage_subscription'`. | `localization.dart:78` |
| 5.4 | **Normalisasi Arab tidak lengkap** — hamza seat `ؤ/ئ → ء` lossy & tak tangani `ٵٲٳ`; varian kaf Farsi `ک`/ya `ی` tak dinormalisasi → pencarian gagal saat paste dari Shamela/keyboard Persia. Normalisasi juga jalan sebelum exact-match → hasil lebih longgar dari niat. | `arabic_utils.dart:20-39` |
| 5.5 | 🔴 **`hijri_date_utils` contoh dokumen salah** (tulis "26 Shafar 1448" padahal algoritma → 26 Rabi'ul Awwal). `.clamp(1,30)/(1,12)` menutup overflow diam-diam; fallback bulan "Bulan" (placeholder nonsense). Kalender tabular bisa beda ±1 hari dari Umm al-Qura tanpa disclaimer. | `hijri_date_utils.dart` |
| 5.6 | **Amiri tidak dijamin untuk semua `titleArabic`** — hanya 4 tempat pakai Amiri eksplisit. | `agent_model.dart` vs widgets |

---

## 6. CACAT KODE, BUG & KEBOCORAN MEMORI

### 6.1 Keamanan & secret
- 🔴 **`update_service` mengunduh & menjalankan APK tanpa verifikasi signature/checksum** (hanya cek ukuran >5MB). Siapa pun yang menguasai doc `apk_url` Firestore bisa mengirim kode arbitrer ke semua pengguna. **Lubang supply-chain kritis.** Bila didistribusikan via Play, silent self-update juga **melanggar kebijakan Play**. (`update_service.dart:121,131-132`)
- `auth_service.dart:12` OAuth `serverClientId` hardcode; `constants.dart:11` UA Chrome pinned (versi 128) yang menua; `evidence_bottom_sheet:34` URL Shamela hardcode.

### 6.2 Kebocoran memori / resource
- `update_service.dart:153` `HttpClient` tidak di-`close()`; file `.tmp`/APK lama tidak dibersihkan → storage membengkak.
- `agent_webview` — script master di-injeksi ≥6 cara/waktu (UserScript + onLoadStop + 4× delayed + onProgress + `setInterval(300ms)` internal) → DOM sweep berulang sepanjang hidup WebView (boros CPU/baterai). MutationObserver sebenarnya sudah cukup.
- `doku_checkout_sheet` — polling 2 detik ke Cloud Function **di samping** listener Firestore → ~1.800 pemanggilan CF per jam per pengguna (biaya + baterai).

### 6.3 Bug logika
- 🔴 **Guest pakai UID tetap `guest_user`** → semua tamu berbagi satu identitas (tabrakan data/bookmark). (`auth_service.dart:126`, `user_model.dart:84`)
- 🔴 **Entitlement tanpa expiry = premium seumur hidup** (`isActive` true bila `expiry==null`). (`user_model.dart:26-31`)
- 🔴 **`getEntitlement` prefix-match ambigu** — `'fiqh'` bisa cocokkan `'fiqh_tahawwulat_muhaqqiq'` sebelum kunci yang lebih spesifik. (`user_model.dart:118-122`)
- 🔴 **`FieldModel.getById` & `BookmarkModel.fieldId` default ke 'fiqh'/field pertama** → lookup gagal diam-diam mengarah ke produk flagship Rp 2,7jt. (`field_model.dart:118-123`, `bookmark_model.dart:51`)
- `doku_service.dart:43-45` membungkus `FirebaseFunctionsException` jadi `Exception` generik → kode error (unauth/quota/network) hilang.
- `agent_service.dart:18` cast `result.data` bisa lempar TypeError tak tertangkap kontrak.

### 6.4 Dead code & inkonsistensi
- Dua layanan bookmark/notes paralel (`bookmark_service` vs `research_notes_service`) — `research_notes_service` **0 pengguna** (fitur mati/migrasi setengah jadi). Gabung.
- `agent_model.akalUrl*` diparse tapi tak pernah dibaca; `colAgents` dideklarasi tak dipakai; `getAgents()` mengaku Firestore tapi hanya return hardcode.
- `_buildStaggeredItem(int, child) { return child; }` — abstraksi mati yang berpura-pura menganimasi. (`subscription:271-273`)
- `catch (e) { rethrow; }` murni noise (`auth_service.dart:78-80`).
- Dua mekanisme kuota paralel (`incrementQuestionCount` client vs `recordQuestion` server) yang bisa berbeda, dan catch senyap menjamin drift tak terlihat.
- `hijri`/`update_ready_banner`/`turath_crystallization_overlay` — banyak widget over-engineered untuk hal kecil.

---

## 7. CLUTTER & OVER-ENGINEERING

1. **Perang menyembunyikan UI Google** (~350 baris) — over-engineering terbesar; rapuh & boros.
2. **Deteksi sukses pembayaran 4× redundan** (Firestore listener + polling 2s + intercept URL + DOM sniff "Berhasil!"). Satu (listener) cukup.
3. **Disclaimer "bukan mufti" muncul di 4 tempat** (carousel + dialog first-launch + Terms + Privacy) — satu yang tepat cukup; empat = nagging.
4. **Upsell "Pro" ditampilkan ke pengguna yang sudah Pro** (dashboard Pro card tanpa gate `isSubscribed`).
5. **Sistem salin/bookmark ganda** (native app bar + tombol injeksi hijau di WebView) — dua jalur kode, dua gaya, dua snackbar.
6. **Empty state dashboard yang tak terjangkau** (karena back-fill aktif).
7. **~50 alias token mati** di `theme.dart:43-101` + `bgGradient` solid + `agentGradient` mengabaikan parameter.
8. **Emoji 👑 di agent flagship** — off-register untuk produk keilmuan.

---

## 8. FITUR YANG HILANG UNTUK STANDAR PREMIUM

| # | Fitur | Kenapa penting |
|---|---|---|
| 1 | **Dynamic Type / aksesibilitas nyata** | Audiens ulama sepuh; paling urgen. |
| 2 | **Offline / cached reading** | Baca kitab tersimpan tanpa sinyal. |
| 3 | **Kustomisasi membaca** (font Arab, line-height, tema sepia, ukuran per-bookmark) | Standar app baca. |
| 4 | **Ekspor sitasi** (PDF/Markdown/footnote: kitab, bab, halaman, cetakan) + folder/tag bookmark | Riset tanpa ekspor = tak lengkap. |
| 5 | **Share sheet OS nyata** (`Share.share`), bukan sekadar salin | Ekspektasi dasar. |
| 6 | **Pencarian korpus nyata** | Search bar di home hanya pindah tab; tidak mencari isi kitab. |
| 7 | **Riwayat sesi riset / resume** | Tiap sesi WebView ephemeral. |
| 8 | **Layout iPad/adaptive** (sidebar+detail, grid multi-kolom) | Konten tidak adaptif di layar lebar. |
| 9 | **Infrastruktur i18n (ARB/intl)** | String tersebar literal → mustahil multi-bahasa. |
| 10 | **Support/kontak, restore-purchase, notifikasi & pengaturan haptic, ekspor data (GDPR)** | Tidak ada jalan bagi pengguna bermasalah pembayaran → risiko kebijakan. |

---

## 9. PETA JALAN MENUJU APPLE-LEVEL (PRIORITAS)

> Urut dampak. UI polish tidak berarti bila fondasi bocor.

### P0 — Fondasi & kepercayaan (sebelum satu piksel berubah)
1. **Perbaiki paywall & trial gate** (masih dari temuan sebelumnya): hapus `defaultAgentUrls` + tombol bypass; biarkan trial masuk & hitung via `recordQuestion`.
2. **Amankan auto-updater** (verifikasi signature/checksum APK) atau hapus bila via Play.
3. **Berhenti menghapus disclaimer akurasi vendor** di WebView — ganti dengan disclaimer OpenTurath sendiri (justru memperkuat kredibilitas).
4. **Satu angka AI & satu sumber harga** — sinkronkan 13/10/30/11; harga dari server/Remote Config; format via satu helper.

### P1 — Aksesibilitas (Apple HIG non-negotiable)
5. **Dynamic Type**: hormati `MediaQuery.textScalerOf`, longgarkan kontainer fixed-height, naikkan floor font ke ≥11pt, perbaiki kontras tersier ke ≥4.5:1.
6. **Semantics**: bungkus semua kontrol kustom (`AppleInteractiveWrapper`, kartu) dengan `Semantics(button: true, label: …)`; tambah `semanticsLabel` untuk ibarah Arab; perbesar target sentuh ke ≥44pt; hormati reduced-motion.

### P2 — Sistem desain yang ditegakkan
7. **Satu palet aksen** (putuskan monochrome ATAU satu warna — bukan 4); pindahkan semua hex hardcode ke token; hapus ~50 alias mati.
8. **Disiplin radius** ke token (hapus nilai liar); **spacing ke grid 4/8pt**; satu glyph untuk "lanjut/buka".
9. **Skala tipografi**: tetapkan aturan serif-vs-sans yang tegas (mis. Newsreader hanya untuk display/editorial, Outfit untuk UI), masukkan Newsreader ke `TextTheme`, hapus ukuran fraksional, satu gaya Arab (Amiri + height ≥1.6 + rtl).

### P3 — Motion, states & copy
10. Animasi entrance jalan sekali (keyed/gated), beri kontrol pause pada carousel, kurangi DOM-sweep WebView (satu MutationObserver saja).
11. **Humanisasi error** (petakan kode → pesan manusiawi), tambah state offline eksplisit, perbaiki CTA paywall yang menyesatkan.
12. **Sunting copywriting satu kali oleh manusia**: hapus superlatif palsu, jargon, campur bahasa; satu register; hapus instruksi fitur hantu; satukan ejaan.

### P4 — Fitur premium & kepatuhan
13. i18n (ARB/intl), ekspor sitasi, share sheet, pencarian korpus, layout iPad, support contact, restore-purchase.
14. Gabung dua layanan bookmark; hapus dead code; tutup kebocoran memori (HttpClient, timer, interval).

---

## LAMPIRAN — Bukti cepat (file:baris)

| Temuan | Bukti |
|---|---|
| Dua H1 bersaing | `dashboard_screen.dart:195,259` |
| Kontras tersier gagal AA | `core/theme.dart:14,32` |
| WebView hapus disclaimer vendor | `screens/agent_webview_screen.dart:241-298` |
| 3+ palet aksen | `dashboard:290-346`, `specialist_list:532-592`, `agent_webview:1133+` |
| 12 radius vs 6 token | `core/theme.dart:104-111` + berbagai layar |
| Newsreader di luar theme | `core/theme.dart:471-484` |
| Tidak ada Dynamic Type | tidak ada `textScaler` di seluruh `lib/` |
| Target <44pt | `agent_webview:1128-1156`, `bookmark:527-536` |
| Semantics ~nol | hanya `widgets/openturath_brand.dart:16` |
| Error mentah bocor | `agent_webview:941,1341`, `subscription:234` |
| Paywall menyesatkan | `agent_webview:672-678` |
| AI-slop copywriting | `agent_model:82,226,358,424,456`, `dashboard:764,780` |
| Lokalisasi 1% | `localization.dart` (22 key) vs `main.dart:93` (1 panggilan) |
| APK tanpa verifikasi | `services/update_service.dart:121,131` |
| Guest UID tetap | `auth_service.dart:126`, `user_model.dart:84` |
| Entitlement tanpa expiry = lifetime | `user_model.dart:26-31` |

---
*— Akhir audit Apple-level OpenTurath AI —*
