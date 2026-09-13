# Audit Forensik Website OpenTurath AI

Tanggal audit: 13 September 2026  
Objek audit: `openturath_website_source.zip`  
SHA-256 ZIP: `25a211df87dabb3a79a2ebe0f94d558cc92b8cbe7545d164b353fa4c4b0489e1`  
Keputusan: **NO-GO**  
Skor kesiapan: **34/100**

> Audit ini hanya mencakup website dan backend web di dalam ZIP. Aplikasi Flutter, APK, dan UI aplikasi tidak diaudit. Tidak ada deployment, transaksi, webhook, atau pemanggilan payment gateway produksi. Nilai konfigurasi sensitif tidak disalin ke laporan.

---

## A. Executive Summary

Website OpenTurath saat ini belum layak dipublikasikan sebagai funnel penjualan atau aplikasi web. Landing page memiliki arah visual yang cukup kuat: nuansa kertas hangat, tipografi editorial, aksen emas, penggunaan Amiri untuk teks Arab, dan tata letak yang tidak mengalami horizontal overflow pada 11 viewport yang diuji. Namun kualitas tersebut berhenti pada landing page.

Funnel bisnis utama gagal secara struktural. Checkout publik memanggil Cloud Function yang mewajibkan pengguna terautentikasi, sementara landing tidak memuat Firebase Auth dan tidak menyediakan proses login. Harga juga mempunyai tiga sumber yang saling bertentangan: harga yang dilihat pengguna, katalog JavaScript, dan harga otoritatif backend. Paket tahunan menjanjikan akses delapan bidang, sedangkan backend menonaktifkan paket semua-AI dan secara default memberikan satu entitlement. Ini bukan cacat kosmetik; ini adalah pelanggaran kontrak produk dan risiko transaksi.

Login dinamis juga tidak mungkin berhasil melalui form yang disediakan. Form hanya mengirim email, tetapi backend mewajibkan Firebase ID token terverifikasi. Halaman legal dan download menggunakan nama kelas dari design system lama yang tidak lagi tersedia di CSS, sehingga logo raster 478×519 tampil sangat besar dan konten menjadi hampir tanpa styling. Tautan APK mengarah ke file yang tidak ada dalam paket.

### Ringkasan severity

| Tingkat | Jumlah | Makna |
|---|---:|---|
| P0 Critical | 2 | Checkout dan kontrak harga/hak akses tidak aman untuk diluncurkan |
| P1 High | 8 | Login, halaman pendukung, download, callback, aksesibilitas kritis, dan hardening produksi |
| P2 Medium | 14 | UX, konsistensi visual, responsive chat, validasi, performa, SEO, dan maintainability |
| P3 Low | 5 | Semantik, detail aset, copy, dan polish |
| Opportunity | 4 | Penguatan identitas, bukti ilmiah, observability, dan content model |

### Lima risiko terbesar

1. Pengunjung tidak dapat menyelesaikan checkout karena frontend anonim memanggil fungsi yang mensyaratkan `context.auth`.
2. Harga yang ditampilkan, harga JavaScript, harga backend, dan hak akses yang dijanjikan berbeda secara material.
3. Form login tidak pernah menghasilkan `id_token`, sehingga jalur login normal selalu kembali dengan `auth_required` tanpa pesan yang terlihat.
4. Delapan halaman pendukung memakai kelas CSS yang sudah tidak ada; halaman legal dan download rusak secara visual pada desktop maupun ponsel.
5. Dependensi produksi memiliki 17 advisory aktif, termasuk 1 critical dan 4 high, sementara Hosting tidak mendefinisikan security headers.

### Lima kekuatan terbesar

1. Landing page mempunyai arah brand ilmiah yang lebih khas daripada template SaaS umum.
2. Semua sembilan halaman statis bebas horizontal overflow pada 11 viewport yang diuji.
3. Webhook DOKU memeriksa signature, timestamp, invoice, jumlah pembayaran, dan menerapkan aktivasi atomik/idempotent.
4. Session cookie memakai `HttpOnly`, `Secure`, `SameSite=Strict`, batas waktu delapan jam, HMAC, dan perbandingan signature yang timing-safe.
5. Firestore menolak penulisan transaksi dan koleksi server-only dari klien serta menggunakan default-deny.

### Keputusan

**NO-GO.** Jangan menerima pembayaran nyata sebelum F-001 dan F-002 selesai dan diuji end-to-end di staging. Jangan mengarahkan pengguna ke login, halaman legal, atau download sebagai jalur produksi sebelum seluruh P1 terkait selesai.

---

## B. Scope dan Metode

### Isi paket

Paket berisi 27 file nyata (35 entri termasuk direktori), total sekitar 3,93 MB:

- Frontend produksi: 9 HTML, 1 CSS, 4 PNG.
- Backend web: `functions/src/index.ts` (2.451 baris), build JavaScript dan source map.
- Deployment: `firebase.json`, `firestore.rules`, `firestore.indexes.json`.
- Test: audit harness, 30 regression tests backend, dan satu test yang bergantung pada file Flutter di luar paket.
- Dependency manifests: `package.json` dan lockfile.

### Metode yang dijalankan

- Ekstraksi ZIP ke direktori sementara dan verifikasi checksum.
- Inventaris file, ukuran, route, integrasi, data flow, trust boundary, dan kontrak frontend–backend.
- Server HTTP lokal; tidak memakai `file://`.
- Inspeksi visual dan DOM melalui Chromium.
- Pengujian 9 halaman statis pada 11 viewport: 320×568, 360×800, 375×812, 390×844, 412×915, 768×1024, 1024×768, 1280×800, 1366×768, 1440×900, dan 1920×1080.
- Render lokal template login dan chat langsung dari fungsi TypeScript. URL NotebookLM pada fixture diganti `about:blank` agar tidak mengakses layanan eksternal.
- Pengujian fokus, dialog, touch target, heading, landmark, image alt, overflow, motion, dan kontras.
- TypeScript compile check dan perbandingan build: hasil kompilasi identik byte-for-byte dengan `functions/lib/index.js` yang dikirim.
- Regression test backend: 30/30 lulus melalui harness sementara.
- Audit dependensi terhadap advisory database saat audit.
- Analisis statis auth, session, Firestore, checkout, DOKU webhook, entitlement, input validation, error handling, SEO, performa, dan legal copy.

### Batasan

- Tidak ada URL deployment yang diuji; hasil runtime produksi, DNS, TLS, cache CDN, Firebase IAM, secret manager, dan konfigurasi DOKU nyata tidak diverifikasi.
- Tidak dilakukan transaksi, login akun nyata, webhook, atau akses NotebookLM.
- Firefox dan Safari/WebKit tidak tersedia dalam jalur audit ini; browser runtime hanya Chromium.
- Core Web Vitals lapangan dan Lighthouse jaringan produksi tidak dapat diukur dari paket sumber.
- Screenshot diamati saat audit tetapi tidak disertakan sebagai file; bukti visual dijelaskan dan dipasangkan dengan DOM/CSS sumber.
- Test `webview_script.test.ts` tidak dapat berjalan mandiri karena mengharapkan file aplikasi Flutter yang memang dikecualikan dari ZIP website.

---

## C. Arsitektur Website

Website adalah **hybrid static/dynamic** dan sekaligus **wrapper layanan eksternal**:

```text
Pengunjung
  ├─ Firebase Hosting → HTML/CSS/PNG statis
  │    └─ Firebase Functions compat → callable createCheckout
  │           └─ DOKU Checkout → webhook → Firestore transaksi/entitlement
  └─ /login, /logout, /chat/* → chatGate Cloud Function
         ├─ Firebase Auth Admin + Firestore entitlement
         ├─ signed session cookie
         └─ HTML wrapper → iframe NotebookLM
```

### Trust boundary

```text
[Browser tidak dipercaya]
  │ form/email/phone/plan, cookie, route ref
  ▼
[Firebase Hosting / Callable / HTTP Function]
  │ Admin SDK dan secret runtime
  ▼
[Firestore dipercaya sebagai state otoritatif]
  │ signed request / callback
  ▼
[DOKU dan NotebookLM: pihak eksternal]
```

### Route map

| Route | Sumber | Jenis | Auth | Data sensitif | Backend | Status audit |
|---|---|---|---|---|---|---|
| `/`, `/index.html` | `public/index.html` | Statis | Tidak | Nama/email/telepon saat checkout | `createCheckout` | Tampil; checkout gagal |
| `/download.html` | `public/download.html` | Statis | Tidak | Tidak | Tidak | Tampil rusak; target APK 404 |
| `/payment-success.html` | static HTML | Statis | Tidak | Tidak | Tidak | Tidak memverifikasi transaksi |
| `/privacy.html` | static HTML | Statis | Tidak | Tidak | Tidak | Konten ada, styling rusak |
| `/terms.html` | static HTML | Statis | Tidak | Tidak | Tidak | Styling dan kebijakan bermasalah |
| `/refund.html` | static HTML | Statis | Tidak | Tidak | Tidak | Styling rusak; konflik dengan Terms |
| `/copyright.html` | static HTML | Statis | Tidak | Tidak | Tidak | Styling rusak |
| `/aup.html` | static HTML | Statis | Tidak | Tidak | Tidak | Styling rusak |
| `/ai-policy.html` | static HTML | Statis | Tidak | Tidak | Tidak | Styling rusak |
| `/login?ref=…` | `chatGate` | Dinamis | Belum | Email, ID token | Auth Admin/Firestore | Form tidak dapat memenuhi kontrak backend |
| `POST /login` | `chatGate` | Dinamis | ID token wajib | ID token/email | Auth Admin/Firestore | Form bawaan selalu gagal |
| `/logout` | `chatGate` | Dinamis | Cookie opsional | Session cookie | Tidak | Menghapus cookie dan redirect |
| `/chat/:agentId` | `chatGate` | Dinamis | Session + entitlement | Email/UID/session | Firestore, NotebookLM | Wrapper dapat dirender; E2E eksternal belum diuji |
| `/doku-webhook` | `dokuWebhook` | HTTP | DOKU signature | Data transaksi | Firestore/DOKU | Hardening baik; tidak dipanggil nyata |
| callable `createCheckout` | Cloud Function | Callable | Firebase Auth wajib | PII + transaksi | DOKU/Firestore | Kontrak frontend putus |
| callable `checkPaymentStatus` | Cloud Function | Callable | Firebase Auth wajib | Invoice | DOKU/Firestore | Tidak digunakan halaman sukses |

### Integrasi eksternal

- Firebase Hosting, Functions, Authentication, dan Firestore.
- DOKU checkout/API/webhook.
- NotebookLM iframe dan tautan layar penuh.
- Google Fonts.
- Telegram notification pada telemetry error.
- Copy publik juga menyebut “Akal”, tetapi hubungan Akal–DOKU tidak dijelaskan.

### Matriks halaman

| Halaman | Tujuan | CTA utama | Dependensi | Risiko utama |
|---|---|---|---|---|
| Landing | Edukasi dan konversi | Pilih paket | CSS, Fonts, Firebase | Checkout tak dapat dipakai |
| Download | Distribusi klien | Unduh APK | File APK | File tidak ada; layout rusak |
| Payment success | Konfirmasi | Kembali | Tidak ada status API | False-positive sukses |
| Legal ×6 | Kepercayaan/legal | Kembali/download | CSS | Design system putus; isi kontradiktif |
| Login | Membuat sesi web | Buka ruang kajian | Firebase Auth/Admin | UI hanya email, backend butuh ID token |
| Chat | Riset melalui iframe | NotebookLM | Session, entitlement, Google | Inkonisten, aksesibilitas drawer lemah |

---

## D. Scorecard

| Area | Bobot | Skor | Bukti utama |
|---|---:|---:|---|
| UI dan desain visual | 25 | 9 | Landing koheren; delapan halaman pendukung rusak; login/chat berbeda sistem |
| UX dan funnel | 15 | 3 | Checkout dan login putus; CTA web hilang; kebijakan kontradiktif |
| Responsivitas | 10 | 6 | Tidak ada overflow; chat mobile kehilangan panel bantuan; touch target kecil |
| Aksesibilitas | 10 | 3 | Modal tanpa semantics/focus trap; kontras gagal; no skip/reduced-motion |
| Fungsionalitas | 10 | 2 | Checkout, login, download, dan success verification tidak bekerja end-to-end |
| Keamanan | 10 | 5 | Webhook/session/rules cukup kuat; headers, dependencies, validation lemah |
| Kesiapan produksi/reliabilitas | 7 | 2 | Tidak ada staging E2E, monitoring frontend yang aman, atau recovery states |
| Performa | 5 | 2 | Aset PNG 3,38 MB, font/script blocking, tanpa cache policy |
| SEO dan konten | 4 | 1 | Title/description ada; canonical/OG/schema/robots/sitemap tidak ada |
| Kode dan maintainability | 4 | 1 | Monolit 2.451 baris, 174 inline style, 90 event attribute, test tak terintegrasi |
| **Total** | **100** | **34** | **Blocked / NO-GO** |

Proyeksi realistis:

- Setelah P0/P1 selesai: **65–72/100**, jika dibuktikan dengan E2E staging.
- Setelah roadmap penuh: **85–91/100**, bergantung hasil audit lapangan, legal review, dan iframe eksternal.

---

## E. Daftar Temuan Prioritas

### `[F-001] Checkout publik selalu ditolak karena autentikasi tidak pernah dibuat`

- Severity: **P0 Critical**
- Status bukti: **CONFIRMED**
- Confidence: Sangat tinggi
- Area: Funnel, auth, payment
- File dan baris: `public/index.html:10-11, 498-559`; `functions/src/index.ts:485-504`
- Route/halaman: Landing → modal checkout → callable `createCheckout`
- Kondisi pemicu: Pengunjung publik mengisi checkout dan menekan proses pembayaran.
- Perilaku sekarang: Halaman hanya memuat Firebase App dan Functions compat; tidak memuat Auth atau sign-in. Backend langsung menolak jika `context.auth` kosong.
- Perilaku yang diharapkan: Pengguna diarahkan melalui autentikasi yang jelas sebelum checkout, atau backend mendukung checkout tamu dengan model verifikasi dan anti-abuse yang eksplisit.
- Bukti: Tidak ada `firebase-auth` atau kode sign-in dalam HTML; `createCheckout` melempar `unauthenticated` pada baris 488–492.
- Dampak pengguna: Tidak dapat membayar walau modal tampak siap.
- Dampak bisnis: Conversion revenue secara efektif 0% dari landing publik.
- Dampak keamanan/legal: UI meminta PII sebelum menjelaskan bahwa akun wajib; pengguna mendapat error generik.
- Akar masalah: Kontrak autentikasi frontend dan callable backend dikembangkan terpisah.
- Rekomendasi: Tentukan checkout authenticated vs guest. Untuk authenticated, hadirkan CTA masuk Google/Firebase sebelum pricing, simpan intended plan, lalu lanjutkan checkout setelah auth. Ikat billing email ke token atau minta konfirmasi eksplisit.
- Cara verifikasi: E2E staging dari browser bersih sampai URL DOKU sandbox; assertion `context.auth.uid`, invoice pending, dan pesan error per state.
- Perkiraan usaha: L
- Dependensi: Keputusan produk auth, Firebase web app config, DOKU sandbox.
- Risiko regresi: App caller yang sudah memakai callable dapat terdampak jika kontrak request diubah.

### `[F-002] Tiga sumber harga dan entitlement paket tahunan saling bertentangan`

- Severity: **P0 Critical**
- Status bukti: **CONFIRMED**
- Confidence: Sangat tinggi
- Area: Pricing, payment integrity, entitlement, legal
- File dan baris: `public/index.html:280-315, 510-515, 545-559`; `functions/src/index.ts:334-357, 503-520`
- Route/halaman: Pricing → checkout → DOKU → aktivasi
- Kondisi pemicu: Memilih paket 1 bulan, 6 bulan, atau 1 tahun.
- Perilaku sekarang: UI menampilkan Rp99.000/Rp499.000/Rp799.000; katalog JS menyimpan Rp299.000/Rp1.499.000/Rp1.999.000; backend menagih Rp49.000/Rp299.000/Rp499.000. Paket tahunan menjanjikan seluruh 8 bidang, tetapi request tidak mengirim `agentId`, backend default ke `fiqh_tahawwulat`, dan paket `all_ai` justru dinonaktifkan.
- Perilaku yang diharapkan: Satu katalog produk kanonikal menentukan SKU, harga, durasi, scope entitlement, copy, dan gateway line item.
- Bukti: Nilai literal pada lokasi di atas; backend sengaja mengabaikan amount klien dan memilih harga sendiri—aman terhadap manipulasi nominal, tetapi berbeda dari kontrak visual.
- Dampak pengguna: Pengguna melihat total yang berbeda dari nilai transaksi dan memperoleh produk yang berbeda dari janji.
- Dampak bisnis: Sengketa, refund, chargeback, hilangnya kepercayaan, rekonsiliasi pendapatan salah.
- Dampak keamanan/legal: Risiko misrepresentation dan aktivasi entitlement tidak sesuai pembayaran.
- Akar masalah: Duplikasi katalog di HTML, JavaScript, dan backend tanpa contract test.
- Rekomendasi: Bekukan checkout. Definisikan SKU server-side; frontend mengambil katalog read-only bertanda versi; gateway dan entitlement harus berasal dari record SKU yang sama. Hapus promise “8 bidang” sampai benar-benar tersedia.
- Cara verifikasi: Contract test seluruh SKU dan E2E sandbox memastikan display total = invoice amount = paid amount = entitlement scope/duration.
- Perkiraan usaha: L
- Dependensi: Keputusan harga resmi dan definisi paket semua-AI.
- Risiko regresi: Migrasi pelanggan/entitlement lama dan caller aplikasi.

### `[F-003] Form login secara desain tidak dapat menghasilkan kredensial yang diwajibkan backend`

- Severity: **P1 High**
- Status bukti: **CONFIRMED**
- Confidence: Sangat tinggi
- Area: Login, auth, UX
- File dan baris: `functions/src/index.ts:1615-1663, 1823-1940`
- Route/halaman: GET/POST `/login`
- Kondisi pemicu: Pengguna memasukkan email lalu submit.
- Perilaku sekarang: Form hanya mengirim `ref`, `csrf_token`, dan email; handler mewajibkan `id_token`. Hasilnya redirect `auth_required`. Error map tidak memuat `auth_required`, `unverified_email`, atau `invalid_token`, sehingga alasan gagal tidak tampil.
- Perilaku yang diharapkan: UI melakukan Firebase Google sign-in, memperoleh ID token, lalu POST token; atau backend mengimplementasikan magic-link yang sesuai copy email-only.
- Bukti: Form baris 1931–1937 versus pemeriksaan token baris 1615–1628.
- Dampak pengguna: Pelanggan lama tidak bisa membuka ruang kajian.
- Dampak bisnis: Support load, churn, layanan berbayar tidak dapat digunakan.
- Dampak keamanan/legal: Mendorong pengguna mencoba berulang tanpa penjelasan; tidak ada kompromi langsung.
- Akar masalah: Mental model “email lookup” bercampur dengan token-based authentication.
- Rekomendasi: Pilih satu mekanisme. Disarankan Google/Firebase karena NotebookLM juga membutuhkan akun Google; jelaskan hubungan kedua akun dan jangan menjadikan email saja sebagai bukti identitas.
- Cara verifikasi: E2E akun verified, unverified, non-subscriber, expired, token revoked, dan session expired.
- Perkiraan usaha: L
- Dependensi: Firebase OAuth configuration dan UX persetujuan akun Google.
- Risiko regresi: Pemetaan email lama ke UID.

### `[F-004] Halaman legal dan download kehilangan hampir seluruh styling`

- Severity: **P1 High**
- Status bukti: **CONFIRMED**
- Confidence: Sangat tinggi
- Area: UI, brand, legal trust
- File dan baris: `public/{privacy,terms,refund,copyright,aup,ai-policy,download,payment-success}.html`; `public/style.css:184-258, 1019-1126`
- Route/halaman: Delapan halaman pendukung
- Kondisi pemicu: Membuka halaman selain landing.
- Perilaku sekarang: HTML memakai `.navbar-inner`, `.logo`, `.legal-container`, `.legal-content`, `.footer-inner`, dan kelas lama lainnya. CSS hanya menyediakan pola BEM seperti `.navbar__inner`/`.navbar__logo`; 102 penggunaan kelas legacy tidak memiliki definisi. Logo 478×519 tampil raksasa dan teks menjadi dokumen mentah.
- Perilaku yang diharapkan: Semua halaman memakai shell, navbar, footer, container, dan typography primitives yang sama.
- Bukti: Pencarian CSS menghasilkan nol definisi untuk kelas legacy. Inspeksi 1440×900 dan 390×844 memperlihatkan logo cyan mengisi mayoritas layar pertama.
- Dampak pengguna: Sulit membaca legal, sulit mempercayai checkout, orientasi halaman hilang.
- Dampak bisnis: Brand tampak rusak dan belum selesai; conversion serta legal defensibility menurun.
- Dampak keamanan/legal: Kebijakan penting secara faktual ada tetapi presentasinya tidak layak dan bisa menghambat informed consent.
- Akar masalah: Migrasi design system hanya dilakukan pada landing.
- Rekomendasi: Buat satu shared page shell; ubah semua halaman ke komponen/class kanonikal. Legal body 680–760 px, font minimum 16 px, line-height 1.65–1.8, heading anchors, dan footer konsisten.
- Cara verifikasi: Visual regression semua halaman × mobile/tablet/desktop; computed-style assertion untuk logo dan container.
- Perkiraan usaha: M
- Dependensi: Fondasi design system.
- Risiko regresi: Inline styles lama dapat mengalahkan token baru.

### `[F-005] Tautan download mengarah ke APK yang tidak tersedia`

- Severity: **P1 High**
- Status bukti: **CONFIRMED** untuk paket; runtime hosting belum diverifikasi
- Confidence: Tinggi
- Area: Download funnel
- File dan baris: `public/download.html:234-242`
- Route/halaman: `/download.html` → `OpenTurath_AI.apk`
- Kondisi pemicu: Menekan “Unduh APK Android”.
- Perilaku sekarang: File target tidak ada dalam `public/` atau ZIP; halaman mengklaim v1.0.2 dan 54 MB tanpa artefak yang dapat diverifikasi.
- Perilaku yang diharapkan: Tautan menunjuk rilis yang ada, checksum/ukuran/versinya berasal dari manifest rilis kanonikal.
- Bukti: Inventaris seluruh ZIP tidak menemukan APK.
- Dampak pengguna: 404 atau download gagal.
- Dampak bisnis: Funnel akuisisi putus; klaim rilis terlihat tidak terpercaya.
- Dampak keamanan/legal: Distribusi binary tanpa checksum/source-of-truth berisiko supply-chain.
- Akar masalah: HTML hard-coded tidak terhubung pipeline rilis.
- Rekomendasi: Gunakan manifest rilis bertanda tangan/terversioning dan validasi link pada CI. Jika website tidak mendistribusikan app, ganti CTA dengan kanal resmi.
- Cara verifikasi: HEAD/GET staging, checksum, content length, filename, dan installability diuji oleh pipeline rilis terpisah.
- Perkiraan usaha: S–M
- Dependensi: Pemilik pipeline rilis aplikasi (di luar scope audit UI).
- Risiko regresi: Cache CDN dan versi lama.

### `[F-006] Return pembayaran tidak menuju halaman sukses dan halaman sukses tidak memverifikasi status`

- Severity: **P1 High**
- Status bukti: **CONFIRMED** secara statis; alur DOKU membutuhkan verifikasi staging
- Confidence: Tinggi
- Area: Payment UX, reliability
- File dan baris: `functions/src/index.ts:374-389, 885-973`; `public/payment-success.html`
- Route/halaman: DOKU return → website
- Kondisi pemicu: Pembayaran selesai atau kembali dari gateway.
- Perilaku sekarang: `callback_url` hanya `https://openturath-ai.web.app`, bukan halaman sukses. Halaman sukses yang ada bersifat statis dan tidak memanggil `checkPaymentStatus`, tidak memiliki invoice, polling, pending, failed, retry, atau support reference.
- Perilaku yang diharapkan: Return URL membawa opaque transaction reference; halaman memverifikasi server-side dan menampilkan state pending/success/failed secara jujur.
- Bukti: Literal callback URL dan tidak ada JavaScript status di halaman sukses.
- Dampak pengguna: Tidak tahu apakah pembayaran berhasil atau akses aktif.
- Dampak bisnis: Tiket support, repeat payment, abandonment.
- Dampak keamanan/legal: Halaman statis dapat memberi kesan sukses tanpa bukti pembayaran.
- Akar masalah: Webhook fulfillment dan return UX tidak dirancang sebagai satu state machine.
- Rekomendasi: Definisikan state machine `created → pending → paid → provisioning → active/failed`; semua state idempotent dan dapat di-resume.
- Cara verifikasi: DOKU sandbox success, delayed webhook, duplicate callback, failed payment, timeout, refresh, dan back navigation.
- Perkiraan usaha: M–L
- Dependensi: DOKU sandbox dan transaction status endpoint.
- Risiko regresi: Deep link callback dan cache halaman sukses.

### `[F-007] Modal checkout tidak memenuhi pola dialog dan tidak dapat dioperasikan penuh dengan keyboard`

- Severity: **P1 High**
- Status bukti: **CONFIRMED**
- Confidence: Sangat tinggi
- Area: UI, accessibility, checkout
- File dan baris: `public/index.html:382-431, 520-535`; `public/style.css:853-1017`
- Route/halaman: Modal checkout
- Kondisi pemicu: Tekan CTA paket menggunakan mouse atau keyboard.
- Perilaku sekarang: Overlay tidak memiliki `role="dialog"`, `aria-modal`, atau accessible name; fokus tetap pada tombol di belakang; tidak ada focus trap, Escape, restore, atau scroll lock. Metode pembayaran adalah `<div onclick>` tanpa role/state dan tidak masuk tab order. Tombol tutup hanya karakter `✕` tanpa label.
- Perilaku yang diharapkan: Dialog bernama, fokus awal ke heading/field, tab terperangkap, Escape/backdrop aman, fokus dikembalikan, body terkunci, dan metode pembayaran berupa radio group native.
- Bukti: Browser menunjukkan overlay memenuhi 390×844 tetapi `document.activeElement` tetap CTA dasar dan body tetap scrollable.
- Dampak pengguna: Pengguna keyboard/screen reader tersesat atau tidak dapat memilih metode.
- Dampak bisnis: Checkout abandonment dan potensi pelanggaran aksesibilitas.
- Dampak keamanan/legal: Persetujuan transaksi tidak inklusif; close control ambigu.
- Akar masalah: Modal hanya mengubah class visual tanpa state/semantics interaction.
- Rekomendasi: Implementasikan dialog native atau komponen teruji; target minimum 44×44 untuk tindakan utama dan sekurang-kurangnya WCAG 24×24 untuk semua target.
- Cara verifikasi: Keyboard-only, screen reader, zoom 200/400%, mobile virtual keyboard, dan automated dialog rules.
- Perkiraan usaha: M
- Dependensi: Komponen form dan error states.
- Risiko regresi: Focus trap bertabrakan dengan redirect gateway jika tidak dibersihkan.

### `[F-008] Kebijakan refund bertentangan secara langsung`

- Severity: **P1 High**
- Status bukti: **CONFIRMED**
- Confidence: Sangat tinggi
- Area: Content, legal, trust
- File dan baris: `public/terms.html:43-49`; `public/refund.html:34-62`; `public/index.html:321, 365`
- Route/halaman: Landing, Terms, Refund
- Kondisi pemicu: Pengguna membandingkan kebijakan sebelum/atau sesudah membeli.
- Perilaku sekarang: Terms menyatakan pembayaran final dan tidak dapat dikembalikan kecuali double-charge; landing menawarkan refund penuh tujuh hari; Refund Policy mengizinkan tujuh hari dengan maksimum lima kredit serta kompensasi outage.
- Perilaku yang diharapkan: Satu kebijakan disetujui pemilik bisnis/legal dan direferensikan identik di pricing, checkout, FAQ, Terms, dan Refund.
- Bukti: Pernyataan eksplisit yang berlawanan pada baris di atas.
- Dampak pengguna: Tidak dapat mengetahui haknya.
- Dampak bisnis: Sengketa dan meningkatnya chargeback.
- Dampak keamanan/legal: Risiko consumer-protection dan ketentuan tidak dapat ditegakkan secara konsisten.
- Akar masalah: Dokumen dibuat tanpa content owner/single source.
- Rekomendasi: Hentikan copy refund sampai legal decision final; tambahkan versi/effective date dan audit cross-page CI.
- Cara verifikasi: Legal sign-off dan snapshot assertion untuk frasa/parameter kebijakan kanonikal.
- Perkiraan usaha: S untuk sinkronisasi, M untuk legal review.
- Dependensi: Keputusan legal/bisnis.
- Risiko regresi: Copy promosi lama muncul kembali.

### `[F-009] Hosting tidak mendefinisikan security headers dan kebijakan browser`

- Severity: **P1 High**
- Status bukti: **CONFIRMED** untuk source; header edge produksi perlu verifikasi runtime
- Confidence: Tinggi
- Area: Security, privacy, deployment
- File dan baris: `firebase.json:10-35`
- Route/halaman: Semua route hosting
- Kondisi pemicu: Setiap request browser.
- Perilaku sekarang: Tidak ada konfigurasi CSP, HSTS, `X-Content-Type-Options`, `Referrer-Policy`, `Permissions-Policy`, frame policy, atau cache policy.
- Perilaku yang diharapkan: Header baseline per route, dengan CSP yang mengizinkan Firebase/DOKU/Fonts secara minimum dan `frame-src` NotebookLM hanya pada chat.
- Bukti: Objek hosting hanya memuat site/public/ignore/rewrites.
- Dampak pengguna: Perlindungan browser lebih rendah dan privacy leakage lebih mungkin.
- Dampak bisnis: Security posture produksi lemah.
- Dampak keamanan/legal: Dampak XSS meningkat; referrer dan permission surface tidak dibatasi.
- Akar masalah: Konfigurasi deployment belum di-hardening.
- Rekomendasi: Tambahkan header bertahap, mulai CSP Report-Only, lalu enforce. Terapkan immutable caching hanya untuk aset ber-hash; HTML no-cache/revalidate.
- Cara verifikasi: Header scan staging, CSP violation report, iframe/payment/auth smoke tests.
- Perkiraan usaha: M
- Dependensi: Inventaris domain eksternal dan strategi asset hashing.
- Risiko regresi: CSP dapat memblokir inline script/style yang saat ini sangat banyak.

### `[F-010] Dependency produksi memiliki advisory critical/high aktif`

- Severity: **P1 High**
- Status bukti: **CONFIRMED** pada advisory database tanggal audit
- Confidence: Tinggi
- Area: Supply chain, backend security
- File dan baris: `functions/package.json`, `functions/package-lock.json`
- Route/halaman: Semua Cloud Functions
- Kondisi pemicu: Eksploit bergantung jalur kode/package tertentu.
- Perilaku sekarang: `npm audit --omit=dev` melaporkan 17 vulnerability: 1 critical, 4 high, 12 moderate. Critical melibatkan `websocket-driver`; high termasuk jalur `axios`, `@grpc/grpc-js`, `form-data`, dan `protobufjs`.
- Perilaku yang diharapkan: Tidak ada critical/high yang dapat dieksploitasi pada dependency graph produksi; exception terdokumentasi dengan compensating control.
- Bukti: Audit lockfile, 273 dependency total dan 187 production dependency.
- Dampak pengguna: Potensi availability, integrity, atau request processing impact bergantung exploitability.
- Dampak bisnis: Risiko insiden dan deploy terblokir.
- Dampak keamanan/legal: Known-vulnerability exposure.
- Akar masalah: Dependency refresh dan vulnerability gate belum ada.
- Rekomendasi: Upgrade terkontrol, review changelog, SCA CI gate, SBOM, dan minimalkan dependency `crypto` wrapper yang tidak perlu bila Node built-in digunakan.
- Cara verifikasi: Audit bersih untuk critical/high, build, 30 regression tests, emulator/integration tests.
- Perkiraan usaha: M
- Dependensi: Compatibility Firebase Functions/Admin/Google APIs.
- Risiko regresi: Major transitive upgrades.

### `[F-011] Navigasi tidak menyediakan jalur masuk atau CTA menggunakan web`

- Severity: **P2 Medium**
- Status bukti: **CONFIRMED**
- Confidence: Tinggi
- Area: UX, IA, conversion
- File dan baris: `public/index.html:17-44` dan footer; route dinamis di `functions/src/index.ts:1535-1610`
- Route/halaman: Landing → login/chat
- Kondisi pemicu: Pelanggan lama atau pengunjung yang ingin mencoba web.
- Perilaku sekarang: Navbar hanya Harga dan Download; copy menyebut layanan tersedia melalui web, tetapi tidak ada “Masuk”, “Buka Web”, atau pemilih kajian.
- Perilaku yang diharapkan: Navbar memisahkan CTA pengunjung baru dan pelanggan: “Lihat Harga” dan “Masuk/Buka Ruang Kajian”.
- Bukti: AX tree landing hanya menemukan Harga dan Download di navigasi.
- Dampak pengguna: Dead end dan mental model app-vs-web kabur.
- Dampak bisnis: Return-user funnel dan activation turun.
- Dampak keamanan/legal: Tidak material.
- Akar masalah: IA dibangun sebagai landing distribusi app, sementara backend berkembang menjadi aplikasi web.
- Rekomendasi: Putuskan posisi produk; tambahkan route hub autentikasi dan deep-link preserving ref.
- Cara verifikasi: Five-second test dan E2E pengunjung baru/pelanggan lama.
- Perkiraan usaha: S–M
- Dependensi: F-003.
- Risiko regresi: CTA berkompetisi jika prioritas visual tidak jelas.

### `[F-012] Mapping agent chat memakai ID yang tidak pernah cocok dengan route nyata`

- Severity: **P2 Medium**
- Status bukti: **CONFIRMED**
- Confidence: Sangat tinggi
- Area: Chat UX, correctness
- File dan baris: `functions/src/index.ts:1462-1498, 1949-1990, 2322-2335`
- Route/halaman: `/chat/:agentId`
- Kondisi pemicu: Membuka route hyphenated seperti `fikih-tahawwulat-muhaqqiq`.
- Perilaku sekarang: Cabang deskripsi membandingkan `fiqh_tahawwulat`, `fiqh_syafii`, dan `hadits`; route nyata memakai ID hyphenated, sehingga fallback generik selalu digunakan. Markdown `**` ditampilkan literal. Menu hanya memuat empat dari enam agent yang didefinisikan.
- Perilaku yang diharapkan: Metadata route, entitlement, label, description, prompts, dan navigation berasal dari registry tunggal.
- Bukti: Render lokal menunjukkan “Kajian **AI Fikih…**” dengan asterisk terlihat.
- Dampak pengguna: Konten bantuan salah/generik dan modul tidak konsisten.
- Dampak bisnis: Nilai diferensiasi tiap kajian hilang.
- Dampak keamanan/legal: Entitlement mapping perlu dijaga agar tidak ikut salah saat registry disatukan.
- Akar masalah: Tiga namespace ID (`fiqh_`, hyphen route, entitlement) tanpa tipe/contract test.
- Rekomendasi: Typed agent registry dan test setiap route → entitlement → Notebook ID → copy.
- Cara verifikasi: Snapshot seluruh agent route dan active-nav state.
- Perkiraan usaha: M
- Dependensi: Product catalog.
- Risiko regresi: Deep links lama.

### `[F-013] Chat mobile menghilangkan bantuan dan tidak memiliki drawer semantics`

- Severity: **P2 Medium**
- Status bukti: **CONFIRMED**
- Confidence: Tinggi
- Area: Responsive, accessibility, chat
- File dan baris: `functions/src/index.ts:1944-2417`
- Route/halaman: Chat pada lebar ≤991 px
- Kondisi pemicu: Viewport ponsel 390×844.
- Perilaku sekarang: Panel kanan berisi konteks, contoh pertanyaan, dan Bantuan disembunyikan tanpa alternatif. Tombol `☰` tidak punya accessible name/`aria-expanded`; Escape tidak menutup drawer; fokus tetap di tombol dan background tidak diinert-kan.
- Perilaku yang diharapkan: Drawer bernama dengan state ARIA, Escape, focus management, backdrop, dan akses alternatif untuk Help/examples.
- Bukti: Uji 390×844: `rightSidebarDisplay:none`; Escape meninggalkan `.sidebar-left.open`.
- Dampak pengguna: Pengguna mobile kehilangan bantuan dan orientasi.
- Dampak bisnis: Engagement dan task completion menurun.
- Dampak keamanan/legal: Tidak material langsung.
- Akar masalah: Responsive hanya menyembunyikan kolom, tidak merancang ulang fungsi.
- Rekomendasi: Jadikan konteks/help sebagai sheet/tab yang tetap dapat ditemukan; minimum target 44×44 untuk menu.
- Cara verifikasi: Keyboard, touch, screen reader, portrait/landscape, 200% zoom.
- Perkiraan usaha: M
- Dependensi: Navigation component.
- Risiko regresi: Iframe focus capture.

### `[F-014] Kontras warna kritis gagal WCAG AA`

- Severity: **P2 Medium**
- Status bukti: **CONFIRMED**
- Confidence: Tinggi
- Area: UI, accessibility
- File dan baris: `public/style.css:11-57, 123-179, 683-810, 1019-1126`; inline template login/chat
- Route/halaman: Landing, pricing, footer, login, chat
- Kondisi pemicu: Teks kecil/sekunder, CTA emas, footer.
- Perilaku sekarang: `#A8A29E`/putih 2,52:1; gold `#B8860B`/paper 3,15:1; putih/gold 3,25:1; putih/`#DAA520` 2,24:1; ink4/paper 2,44:1. Banyak pemakaian 11–13 px.
- Perilaku yang diharapkan: Teks normal ≥4,5:1, large text/UI ≥3:1, indikator fokus ≥3:1.
- Bukti: Perhitungan sRGB contrast terhadap token aktual.
- Dampak pengguna: Sulit dibaca low vision, layar redup, dan kondisi outdoor.
- Dampak bisnis: Persepsi kualitas dan conversion turun.
- Dampak keamanan/legal: Nonconformance WCAG 2.2 AA.
- Akar masalah: Warna dipilih secara estetis tanpa semantic contrast pair.
- Rekomendasi: Definisikan pasangan token `text-primary/secondary/muted/on-accent`; gunakan ink gelap pada tombol emas, dan jangan gunakan gold sebagai small body text di paper.
- Cara verifikasi: Automated contrast plus manual state hover/focus/disabled.
- Perkiraan usaha: S–M
- Dependensi: Token refactor.
- Risiko regresi: Brand appearance jika gold digunakan sebagai teks utama.

### `[F-015] Target sentuh dan ukuran tipografi terlalu kecil pada navigasi/footer`

- Severity: **P2 Medium**
- Status bukti: **CONFIRMED**
- Confidence: Tinggi
- Area: Responsive, accessibility, typography
- File dan baris: `public/style.css:247, 272, 323, 386, 438-444, 721, 769, 1081-1124`; chat inline CSS
- Route/halaman: Semua halaman
- Kondisi pemicu: Ponsel dan pengguna motor impairment.
- Perilaku sekarang: Landing mempunyai 11 elemen interaktif lebih pendek dari 24 px; link footer/legal sekitar 17–21 px. Banyak label 0.6875rem–0.8125rem; chat memakai 10–12 px untuk status/sidebar.
- Perilaku yang diharapkan: Target minimum 24×24 WCAG, ideal 44×44 untuk mobile; body/critical labels ≥14–16 px sesuai konteks.
- Bukti: Pengukuran DOM pada semua viewport.
- Dampak pengguna: Salah tekan dan fatigue membaca.
- Dampak bisnis: Mobile conversion/retention turun.
- Dampak keamanan/legal: WCAG 2.5.8 risk.
- Akar masalah: Visual density menjadi prioritas atas operability.
- Rekomendasi: Perbesar hit area melalui padding tanpa harus membesarkan glyph; gunakan skala type 12/14/16/18/24/32/48 dengan 12 hanya metadata non-kritis.
- Cara verifikasi: DOM target-size audit dan device touch test.
- Perkiraan usaha: S–M
- Dependensi: Design tokens.
- Risiko regresi: Footer menjadi lebih panjang; terima sebagai trade-off aksesibilitas.

### `[F-016] Reveal animation dapat menyembunyikan konten dan tidak menghormati reduced motion`

- Severity: **P2 Medium**
- Status bukti: **CONFIRMED** untuk CSS/JS; dampak no-JS sangat mungkin
- Confidence: Tinggi
- Area: Motion, resilience, accessibility
- File dan baris: `public/style.css:110-120`; `public/index.html:593-605`
- Route/halaman: Landing sections/pricing
- Kondisi pemicu: Load lambat, JS gagal, IntersectionObserver tidak jalan, atau reduced-motion.
- Perilaku sekarang: `.reveal` dimulai `opacity:0` dan baru tampak setelah observer; pada mobile audit konten sempat hampir tak terlihat. Tidak ada `prefers-reduced-motion`.
- Perilaku yang diharapkan: Konten terlihat secara default; enhancement menambahkan animasi hanya ketika JS siap, dan motion dimatikan untuk reduced-motion.
- Bukti: CSS transition 0,6 detik dan observer init setelah DOMContentLoaded.
- Dampak pengguna: Flash kosong atau konten permanen tersembunyi ketika JS gagal.
- Dampak bisnis: LCP/perceived performance dan conversion turun.
- Dampak keamanan/legal: Accessibility motion preference diabaikan.
- Akar masalah: Progressive enhancement terbalik.
- Rekomendasi: Default visible; tambahkan class `js` sebelum memakai hidden state; media query reduced-motion menghapus transform/transition.
- Cara verifikasi: JS disabled, throttled CPU, reduced-motion emulation.
- Perkiraan usaha: S
- Dependensi: Tidak ada.
- Risiko regresi: Urutan reveal berubah.

### `[F-017] Aset raster dan resource blocking membebani first load`

- Severity: **P2 Medium**
- Status bukti: **CONFIRMED** untuk source; Core Web Vitals perlu runtime
- Confidence: Tinggi
- Area: Performance, visual assets
- File dan baris: `public/logo*.png`; `public/style.css:8`; `public/index.html:10-11`
- Route/halaman: Semua halaman
- Kondisi pemicu: First visit jaringan seluler.
- Perilaku sekarang: Empat PNG total ±3,38 MB; `logo.png` sendiri ±2,14 MB. Logo aktif 424 KB dan tidak memiliki intrinsic width/height. CSS memakai blocking `@import` Google Fonts. Firebase compat scripts dimuat di `<head>` tanpa defer walau hanya dibutuhkan saat checkout.
- Perilaku yang diharapkan: Logo vektor atau WebP/AVIF terkompresi, dimensions eksplisit, fonts subset/preload/self-host, scripts deferred/on-demand.
- Bukti: Ukuran dan dimensi file: 1536×1024, 437×491, 478×519, 494×535.
- Dampak pengguna: LCP, CLS, dan data usage memburuk.
- Dampak bisnis: Bounce terutama koneksi lambat.
- Dampak keamanan/legal: Third-party font request memberi metadata koneksi kepada Google.
- Akar masalah: Tidak ada asset pipeline/performance budget.
- Rekomendasi: SVG logo, variant 1×/2×, image budget ≤100 KB above-fold, font subset, non-critical SDK lazy load.
- Cara verifikasi: Lighthouse staging, WebPageTest mobile, CLS/LCP field telemetry.
- Perkiraan usaha: M
- Dependensi: Asset source asli dan CSP.
- Risiko regresi: Perbedaan rendering logo/font.

### `[F-018] SEO dan social discovery hampir tidak disiapkan`

- Severity: **P2 Medium**
- Status bukti: **CONFIRMED**
- Confidence: Tinggi
- Area: SEO, content
- File dan baris: Seluruh `public/*.html`; `firebase.json`
- Route/halaman: Semua halaman publik
- Kondisi pemicu: Crawl, share, duplicate URL.
- Perilaku sekarang: Title dan description ada, tetapi sembilan halaman tidak punya canonical, Open Graph, Twitter card, structured data; tidak ada robots.txt/sitemap.xml. Halaman login/chat tidak memiliki noindex policy.
- Perilaku yang diharapkan: Canonical absolut, OG/Twitter per halaman penting, Organization/SoftwareApplication/FAQ schema yang benar, sitemap/robots, dan noindex untuk auth/chat/success.
- Bukti: Pencarian seluruh head menghasilkan nol marker tersebut.
- Dampak pengguna: Preview share buruk dan discoverability rendah.
- Dampak bisnis: Organic acquisition dan brand consistency lemah.
- Dampak keamanan/legal: Chat URL dapat terindeks walau isi terlindung.
- Akar masalah: SEO bukan bagian page template/deploy checklist.
- Rekomendasi: Metadata generator berbasis page manifest dan validation CI.
- Cara verifikasi: Rich Results, social card validators, crawl staging/production.
- Perkiraan usaha: M
- Dependensi: Domain kanonikal dan positioning copy.
- Risiko regresi: Schema membuat klaim yang belum terverifikasi.

### `[F-019] Validasi checkout lemah dan billing email tidak diikat ke identitas`

- Severity: **P2 Medium**
- Status bukti: **HIGHLY LIKELY**
- Confidence: Tinggi
- Area: Security, data quality, payment
- File dan baris: `functions/src/index.ts:494-505, 512-525`
- Route/halaman: callable `createCheckout`
- Kondisi pemicu: Caller authenticated mengirim tipe/panjang/format tidak normal atau email berbeda.
- Perilaku sekarang: Backend hanya memeriksa presence plan/name/email; tidak ada type/length/email/phone validation, rate limit khusus checkout, atau binding `email` ke `context.auth.token.email`. Unknown plan jatuh ke satu bulan; unknown `agentId` dapat diteruskan sebagai entitlement key fallback.
- Perilaku yang diharapkan: Schema allowlist SKU, agent, string length/format; identity email dari verified token; per-UID/IP throttling; normalized PII.
- Bukti: Tidak ada validasi lain sebelum penulisan transaksi dan DOKU call.
- Dampak pengguna: Invoice/contact salah dan error gateway ambigu.
- Dampak bisnis: Data rekonsiliasi kotor dan abuse biaya function/gateway.
- Dampak keamanan/legal: PII yang tidak perlu/keliru tersimpan; entitlement namespace tidak dibatasi tegas.
- Akar masalah: Trust berlebih pada caller authenticated.
- Rekomendasi: Runtime schema, canonical SKU registry, request size limit, idempotency key, rate limit, audit log redacted.
- Cara verifikasi: Negative tests type confusion, overlong payload, email mismatch, invalid SKU/agent, bursts.
- Perkiraan usaha: M
- Dependensi: F-002.
- Risiko regresi: Caller lama mengirim data non-normal.

### `[F-020] Telemetry Firestore menerima kiriman anonim dengan schema terlalu longgar`

- Severity: **P2 Medium**
- Status bukti: **CONFIRMED**
- Confidence: Tinggi
- Area: Security, cost, privacy
- File dan baris: `firestore.rules:50-58`; `functions/src/index.ts:2423-2451`
- Route/halaman: `client_error_logs`
- Kondisi pemicu: Klien anonim menulis dokumen berulang.
- Perilaku sekarang: Create tidak mensyaratkan auth; hanya `error` yang dibatasi tipe/panjang. Field stack, breadcrumbs, extra, email, dan lainnya tidak dibatasi ukuran/tipe; severity error dapat memicu Telegram.
- Perilaku yang diharapkan: Auth/App Check, strict schema/size, sampling/rate limit, PII scrubbing, dan server-side relay.
- Bukti: Rule create tanpa `request.auth`; trigger meneruskan beberapa field ke Telegram.
- Dampak pengguna: PII mungkin terforward; telemetry dapat dibanjiri.
- Dampak bisnis: Firestore/Functions/Telegram cost dan alert fatigue.
- Dampak keamanan/legal: Log injection dan privacy leakage.
- Akar masalah: Write-only disamakan dengan aman tanpa mempertimbangkan abuse/cost.
- Rekomendasi: App Check + authenticated UID, batas semua field, server sanitization/escaping, quotas.
- Cara verifikasi: Rules emulator fuzz, payload size, anonymous denial, alert sanitization.
- Perkiraan usaha: M
- Dependensi: Client telemetry contract.
- Risiko regresi: Error report dari user sebelum login berhenti; sediakan endpoint rate-limited jika benar-benar diperlukan.

### `[F-021] Error internal gateway dikembalikan ke caller dan pesan frontend tidak actionable`

- Severity: **P2 Medium**
- Status bukti: **CONFIRMED**
- Confidence: Tinggi
- Area: Error handling, security UX
- File dan baris: `public/index.html:570-573`; `functions/src/index.ts:529-560, 880`
- Route/halaman: Checkout/webhook
- Kondisi pemicu: DOKU/Firestore/internal failure.
- Perilaku sekarang: Frontend menampilkan `alert('Terjadi kesalahan: ' + err.message)`; backend tertentu mengirim raw `err.message`. Tidak ada field-level, retry, reference ID, preserved state, atau support path.
- Perilaku yang diharapkan: Pesan aman dan spesifik tindakan; detail teknis hanya pada log server dengan correlation ID.
- Bukti: Catch blocks literal.
- Dampak pengguna: Tidak tahu apa yang harus dilakukan dan dapat kehilangan konteks.
- Dampak bisnis: Abandonment/support.
- Dampak keamanan/legal: Potensi internal error disclosure.
- Akar masalah: Error object teknis langsung menjadi copy UI.
- Rekomendasi: Error taxonomy, mapping localized, correlation ID, non-destructive retry.
- Cara verifikasi: Fault injection per dependency.
- Perkiraan usaha: M
- Dependensi: State machine payment.
- Risiko regresi: Observability menurun bila detail server tidak dipertahankan.

### `[F-022] Test ada tetapi tidak menjadi workflow yang dapat dijalankan dari paket website`

- Severity: **P2 Medium**
- Status bukti: **CONFIRMED**
- Confidence: Tinggi
- Area: QA, maintainability
- File dan baris: `functions/package.json`; `functions/test/*`
- Route/halaman: Backend dan chat wrapper
- Kondisi pemicu: Engineer/CI menjalankan test standar.
- Perilaku sekarang: Tidak ada script `test`. Direct `node --test` gagal karena TypeScript parameter property pada Node strip-only dan test webview mencari file Flutter yang tidak ada. Setelah transpile manual, 30 backend regression test lulus.
- Perilaku yang diharapkan: `npm test` deterministik dari paket ini, memisahkan website tests dari app integration tests.
- Bukti: Scripts hanya build/serve/deploy; `test/package.json` hanya type module.
- Dampak pengguna: Regressi kontrak kritis mudah lolos.
- Dampak bisnis: Release confidence palsu.
- Dampak keamanan/legal: Payment/auth fixes tidak punya gate E2E.
- Akar masalah: Test harness tidak diproduktisasi.
- Rekomendasi: Build test TS atau runner resmi; suites unit/contract/emulator/browser; visual regression.
- Cara verifikasi: Fresh checkout `npm ci && npm test` tanpa file luar.
- Perkiraan usaha: M
- Dependensi: CI runtime.
- Risiko regresi: Test dapat bergantung timing jika tidak memakai fake clock.

### `[F-023] State 404/503/denied/expired/pending tidak memiliki UI yang konsisten`

- Severity: **P2 Medium**
- Status bukti: **CONFIRMED**
- Confidence: Tinggi
- Area: UX, reliability, UI states
- File dan baris: `functions/src/index.ts:1535-1610`; `public/payment-success.html`
- Route/halaman: Chat gate dan payment
- Kondisi pemicu: Config hilang, agent tidak ditemukan, session/entitlement invalid, payment pending.
- Perilaku sekarang: Plain text 404/503, redirect generik login, atau halaman sukses statis. Tidak ada branded recovery, status, retry, back/home/support action.
- Perilaku yang diharapkan: Shared error shell dan state-specific copy/action.
- Bukti: `res.status(...).send("...")` plain text dan tidak ada template state.
- Dampak pengguna: Dead end dan hilang konteks.
- Dampak bisnis: Support serta churn.
- Dampak keamanan/legal: Jangan membedakan account existence secara berlebihan; copy perlu aman.
- Akar masalah: Happy-path-only design.
- Rekomendasi: State inventory dan server-rendered shared shell; preserve safe `ref`.
- Cara verifikasi: E2E seluruh failure matrix.
- Perkiraan usaha: M
- Dependensi: Design system, error taxonomy.
- Risiko regresi: Redirect loops.

### `[F-024] Monolit backend dan inline styling/event menghambat konsistensi`

- Severity: **P2 Medium**
- Status bukti: **CONFIRMED**
- Confidence: Tinggi
- Area: Code quality, design system
- File dan baris: `functions/src/index.ts` seluruhnya; `public/*.html`
- Route/halaman: Semua
- Kondisi pemicu: Setiap perubahan lintas halaman.
- Perilaku sekarang: Satu file 2.451 baris memuat payment, auth, maintenance, telemetry, dan ±600 baris HTML/CSS/JS template; ada 24 penggunaan `any`, 174 atribut inline style, dan 90 inline event attributes.
- Perilaku yang diharapkan: Modul domain, typed contracts, reusable page/components, dan event listeners unobtrusive.
- Bukti: Statistik source.
- Dampak pengguna: Inkonsistensi dan regresi visual lebih sering.
- Dampak bisnis: Lead time dan review cost tinggi.
- Dampak keamanan/legal: Sulit menerapkan CSP tanpa `unsafe-inline`.
- Akar masalah: Pertumbuhan incremental tanpa boundary.
- Rekomendasi: Ekstrak catalog/auth/payment/chat/templates; shared tokens; schema types; lint/format/type/test gates.
- Cara verifikasi: Dependency graph, coverage, CSP tanpa unsafe-inline.
- Perkiraan usaha: L–XL
- Dependensi: Refactor bertahap setelah funnel stabil.
- Risiko regresi: Tinggi bila dilakukan big-bang; gunakan strangler approach.

### P3 dan polish

#### `[F-025] Alt text logo generik dan ikon dekoratif tidak dibedakan`

- Severity: P3; Status: **CONFIRMED**; Confidence: tinggi; Area: accessibility/assets.
- File/baris: halaman pendukung, penggunaan `alt="Logo"`; Route: semua halaman sekunder.
- Pemicu/perilaku: Screen reader membaca “Logo” tanpa brand; emoji/ikon kadang ikut dibaca. Seharusnya logo link bernama “OpenTurath AI” atau `alt=""` jika teks brand berdampingan.
- Bukti/dampak: Semua image memiliki alt, tetapi kualitas alt rendah; orientasi nonvisual memburuk. Dampak bisnis/legal rendah, WCAG name-context risk.
- Akar/rekomendasi: Tidak ada aturan content alternative; buat asset semantics standard.
- Verifikasi/usaha/dependensi/risiko: Screen reader smoke test; S; bergantung shared header; risiko sangat rendah.

#### `[F-026] Payment success tidak memakai landmark main`

- Severity: P3; Status: **CONFIRMED**; Confidence: tinggi; Area: semantics.
- File/baris: `public/payment-success.html`; Route: payment success.
- Pemicu/perilaku: Navigasi landmark menemukan tidak ada `<main>`; seharusnya konten utama berada dalam main dan status menggunakan live region sesuai kebutuhan.
- Bukti/dampak: Semantics scan 9 halaman; screen reader navigation kurang efisien. Bisnis/security rendah.
- Akar/rekomendasi: Markup visual-first; tambahkan landmark dan heading/status hierarchy.
- Verifikasi/usaha/dependensi/risiko: AX tree; S; F-006; rendah.

#### `[F-027] Context menu chat diblokir tanpa manfaat keamanan`

- Severity: P3; Status: **CONFIRMED**; Confidence: tinggi; Area: usability/security theater.
- File/baris: `functions/src/index.ts:2416-2417`; Route: chat.
- Pemicu/perilaku: Klik kanan selalu dicegah untuk “menyembunyikan URL”; URL tetap dapat ditemukan dan fitur browser/accessibility hilang.
- Bukti/dampak: Global `contextmenu.preventDefault`; mengganggu copy/open/accessibility dan tidak memperkuat security.
- Akar/rekomendasi: Obfuscation dianggap control; hapus dan lindungi akses dengan auth/entitlement.
- Verifikasi/usaha/dependensi/risiko: Context menu bekerja; S; tidak ada; rendah.

#### `[F-028] Identitas provider dan kanal dukungan tidak konsisten`

- Severity: P3; Status: **CONFIRMED**; Confidence: sedang; Area: copy/trust.
- File/baris: `public/index.html:250,321,358`; backend DOKU; `functions/src/index.ts:2379`; footer publik.
- Pemicu/perilaku: Publik melihat Akal, backend memakai DOKU, chat memakai `support@openturath.com`, legal memakai `openturath@gmail.com`. Seharusnya relasi provider dan kanal resmi dijelaskan konsisten.
- Bukti/dampak: String source; pengguna ragu saat redirect/support. Dampak legal tergantung kontrak provider.
- Akar/rekomendasi: Tidak ada content owner; definisikan provider disclosure dan satu support channel.
- Verifikasi/usaha/dependensi/risiko: Content QA; S; keputusan bisnis; rendah.

#### `[F-029] Konfigurasi website tercampur metadata Flutter dan Web app ID tampak memakai ID Android`

- Severity: P3; Status: **NEEDS RUNTIME VERIFICATION**; Confidence: sedang; Area: configuration hygiene.
- File/baris: `firebase.json:37-55`; `public/index.html:499-506`.
- Pemicu/perilaku: SDK web diinisialisasi dengan appId berformat Android; mungkin tetap berjalan sebagian, tetapi analytics/auth identity dapat salah. Firebase client config bukan secret otomatis.
- Bukti/dampak: Format literal dan scope contamination; risiko misconfiguration/maintenance, bukan kebocoran rahasia.
- Akar/rekomendasi: Config disalin dari app; daftarkan web app resmi dan pisahkan config per surface.
- Verifikasi/usaha/dependensi/risiko: Firebase console/staging init/auth; S; project owner; risiko migrasi analytics.

### Opportunities

#### `[O-001] Jadikan identitas “ruang riset turath” sebagai design language lengkap`

- Severity: Opportunity; Status: **DESIGN IMPROVEMENT**; Confidence: tinggi; Area: brand/UI.
- Bukti: Landing paper/ink/serif/Amiri terasa khas, sedangkan login/chat menjadi dashboard hitam-emas generik.
- Rekomendasi: Pertahankan nuansa editorial tenang di seluruh shell; gunakan emas sebagai aksen, bukan warna teks kecil; motif manuskrip sangat ringan, provenance/citation menjadi komponen visual utama.
- Verifikasi/usaha/dependensi/risiko: Brand critique + usability; L; design system; risiko dekorasi berlebihan.

#### `[O-002] Jadikan provenance jawaban sebagai pusat diferensiasi produk`

- Severity: Opportunity; Status: **DESIGN IMPROVEMENT**; Confidence: sedang; Area: product/UI.
- Bukti: Landing mengklaim jawaban bersumber, tetapi funnel dan wrapper tidak menunjukkan model citation, kitab, halaman, atau confidence.
- Rekomendasi: Komponen source card yang memperlihatkan kitab, jilid, halaman, kutipan singkat, dan batasan AI; klaim harus diverifikasi pemilik data.
- Verifikasi/usaha/dependensi/risiko: Research task testing; L; kemampuan NotebookLM; risiko overclaim.

#### `[O-003] Visual regression matrix menjadi release gate`

- Severity: Opportunity; Status: **INFORMATIONAL**; Confidence: tinggi; Area: QA/UI.
- Bukti: Class mismatch masif akan tertangkap oleh satu screenshot diff.
- Rekomendasi: Screenshot semua route pada 390, 768, 1280, plus component states; threshold kecil dan baseline reviewed.
- Verifikasi/usaha/dependensi/risiko: CI artifact; M; stable fonts/data; flakiness perlu dikendalikan.

#### `[O-004] Satu manifest konten/produk untuk harga, release, legal, dan agent`

- Severity: Opportunity; Status: **DESIGN IMPROVEMENT**; Confidence: tinggi; Area: architecture/content ops.
- Bukti: Harga, versi APK, refund, provider, agent, dan contact tersebar/hard-coded.
- Rekomendasi: Typed canonical manifests dengan version/effective date dan contract tests lintas frontend/backend.
- Verifikasi/usaha/dependensi/risiko: Snapshot/contract CI; L; product/legal ownership; risiko migrasi.

---

## F. Audit UI per Halaman

| Halaman/area | Kualitas visual | Masalah utama | State hilang | Prioritas |
|---|---|---|---|---|
| Landing | Baik | Hero bersih, tetapi whitespace sangat besar dan CTA web hilang | No-JS, loading, SDK failure | P2 setelah funnel |
| Hero | Baik | Klaim kuat belum diberi provenance langsung; CTA lebih condong jual/download | Auth/return-user | P2 |
| Bukti jawaban | Cukup baik | Card mendukung scan, namun perlu citation yang bisa diverifikasi | Long Arabic, empty, source unavailable | P2/Opp |
| Korpus | Cukup | Tags kecil 11–13 px; density dan hierarchy lemah | Long labels/RTL | P2 |
| Cara kerja | Baik secara komposisi | Copy “Akal”/web/app membentuk mental model ambigu | Provider unavailable | P3 |
| Pricing | Menarik secara visual | Harga dan entitlement salah; featured card mobile menjadi pertama via CSS | Sold out, unavailable, tax/fee | P0 |
| Checkout modal | Cukup visual, buruk interaksi | Semantics/focus/error/validation/policy disclosure hilang | Loading, field errors, retry, offline | P1 |
| Footer landing | Cukup | Banyak link kecil; contrast muted; target pendek | Active/current page | P2 |
| Download | Buruk/rusak | Legacy CSS dan giant logo; APK tidak ada | Platform unavailable, checksum, release notes | P1 |
| Payment success | Terlihat seperti kartu sukses | Tidak punya status nyata/landmark | Pending, failed, provisioning, retry | P1 |
| Privacy | Buruk/rusak | Tidak ada legal layout/typography | Print, anchor navigation | P1 |
| Terms | Buruk/rusak | No-refund bertentangan | Version comparison | P1 |
| Refund | Buruk/rusak | Kebijakan bertentangan | Request status | P1 |
| Copyright | Buruk/rusak | Tidak ada page shell | Report flow | P1 UI |
| AUP | Buruk/rusak | Inline styles dan hierarchy tidak stabil | Enforcement/appeal | P1 UI |
| AI Policy | Buruk/rusak | Long-form readability rendah | Model/version disclosure | P1 UI |
| Login dinamis | Visual rapi tetapi terlalu gelap/generik | Form tidak berfungsi; secondary text sangat redup | auth errors, loading, disabled | P1 |
| Chat wrapper | Layout desktop jelas tetapi sangat berbeda brand | Generic copy, Markdown literal, tiny labels | iframe error/offline/expired | P2 |
| Sidebar kiri | Fungsional desktop | Hanya 4 agent; mobile drawer tidak aksesibel | collapsed/selected/loading | P2 |
| Sidebar kanan | Berguna desktop | Hilang total mobile | mobile sheet/tab | P2 |
| Iframe | Dominan dan fokus | Tidak ada sandbox/referrer policy/fallback | blocked third-party/login required | P2 |
| 404/503/denied/expired | Tidak didesain | Plain text atau redirect ambigu | Seluruh recovery states | P2 |

### Arah desain yang disarankan

- Landing bukan masalah utama yang perlu “dirombak total”. Pertahankan karakter paper/ink/serif, lalu bawa shell yang sama ke legal, download, login, dan chat.
- Gunakan dua mode yang masih satu keluarga: “Editorial Light” untuk marketing/legal dan “Reading Dark” opsional untuk workspace. Keduanya harus berbagi logo, type scale, spacing, radius, dan semantic colors.
- Untuk OpenTurath, kredibilitas ilmiah harus muncul lewat struktur sumber, metadata kitab, dan disclosure batasan AI—bukan melalui ornamen emas berlebih.

---

## G. Audit Design System

### Inventaris token saat ini

| Sistem | Saat ini | Masalah | Rekomendasi kanonikal |
|---|---|---|---|
| Background | paper `#FDFBF7`, dark `#0a0e17/#0f1422` | Tidak ada mapping lintas surface | `surface-canvas`, `surface-raised`, `surface-inverse` |
| Text | ink 1–4 dan rgba putih | Muted pairs gagal contrast | `text-primary`, `secondary`, `muted`, `on-accent` dengan pasangan teruji |
| Accent | beberapa gold: `#B8860B`, `#DAA520`, `#D4AF37` | Brand drift dan contrast berbeda | Satu ramp gold 50–900, fungsi per state |
| Status | green tersebar/inline | Tidak ada warning/error/info set | semantic success/warning/error/info + icon/text |
| Typography | Source Serif 4, Inter, Amiri, Outfit | Dua sistem brand terpisah | Serif display/editorial, Inter UI, Amiri Arabic; hapus Outfit atau definisikan peran eksplisit |
| Type size | 0.6875–large hero | Terlalu banyak small text | 12 metadata, 14 compact UI, 16 body, 18 lead, 24/32/48 headings |
| Spacing | banyak nilai rem acak | Tidak ada skala enforceable | 4, 8, 12, 16, 24, 32, 48, 64, 96 |
| Radius | button/card/modal bervariasi | Tidak dipetakan per component | 8 control, 12 compact card, 20 modal/feature |
| Shadow | landing ringan, login sangat berat | Tone berubah drastis | elevation 0/1/2; dark mode memakai border lebih dari glow |
| Button | outline/gold/nav CTA/download inline | State set tidak lengkap | Primary/secondary/quiet/danger; hover/focus/pressed/disabled/loading |
| Input | landing dan login berbeda | Focus hanya border; error tidak ada | Label, help, error, success; 44–48 px high; visible ring |
| Card | proof/pricing/login/chat terpisah | Tidak berbagi anatomy | `Card` base + editorial/pricing/status variants |
| Modal | class visual saja | Tidak ada behavior contract | Dialog primitive dengan focus/escape/scroll lifecycle |
| Navigation | BEM landing vs legacy vs chat | Tiga implementasi | Shared header/footer/workspace navigation primitives |
| Motion | 0,2–0,6s | `transition: all`; no reduced-motion | 120/180/240 ms; proper properties; reduced-motion |

### Spesifikasi minimum konkret

- Body marketing/legal: 16–18 px, line-height 1.65–1.8, measure 65–75 karakter.
- Arabic reading: Amiri 22–28 px, line-height 1.8, `dir="rtl"`, hindari justified spacing.
- Button: minimum 44 px mobile, 40 px desktop, focus ring 2 px + offset 2 px dengan contrast ≥3:1.
- Input: label persisten, 48 px mobile, autocomplete benar, error terhubung `aria-describedby`.
- Legal container: max-width 760 px; section gap 32–48 px; anchor link per H2.
- Modal mobile ≤390 px: width `calc(100% - 24px)`, max-height `calc(100dvh - 24px)`, internal scroll, safe-area padding.
- Jangan gunakan `transition: all`; hanya properti yang memang dianimasikan.

---

## H. Audit Responsive

### Hasil viewport statis

| Viewport | 9 halaman statis | Overflow horizontal | Temuan utama |
|---|---|---|---|
| 320×568 | Diuji | Tidak | Landing stack baik; secondary giant logo; link kecil |
| 360×800 | Diuji | Tidak | Sama; checkout memerlukan internal-scroll review |
| 375×812 | Diuji | Tidak | Pricing featured muncul pertama, terbaca |
| 390×844 | Diuji mendalam | Tidak | Modal memenuhi layar; focus tetap di background |
| 412×915 | Diuji | Tidak | Legal tetap sangat panjang/tanpa shell |
| 768×1024 | Diuji | Tidak | Tablet layout stabil, kelas secondary tetap rusak |
| 1024×768 | Diuji | Tidak | Desktop breakpoint bekerja pada landing |
| 1280×800 | Diuji | Tidak | Whitespace hero besar namun hierarchy jelas |
| 1366×768 | Diuji | Tidak | Above-fold landing rapi |
| 1440×900 | Diuji mendalam | Tidak | Legal giant logo sangat jelas |
| 1920×1080 | Diuji | Tidak | Container membatasi landing dengan baik |

### Template dinamis

- Login 390×844: tidak overflow; card masuk viewport, control cukup tinggi; footer/secondary copy sangat redup.
- Chat 1440×900: tiga kolom terbaca, tetapi main iframe mendominasi dan tampak kosong bila eksternal gagal.
- Chat 390×844: iframe mengisi 390×796; panel kanan hilang; left drawer mulai di `left:-250px`; menu 27×34,5 px; Escape tidak menutup.
- Safe-area inset, iPhone landscape, keyboard virtual, dan browser zoom 400% belum ditangani eksplisit.

---

## I. Audit Aksesibilitas — WCAG 2.2 AA

| Kriteria | Status | Bukti |
|---|---|---|
| 1.1.1 Non-text Content | Partial | Alt ada, tetapi “Logo” generik dan emoji tidak konsisten |
| 1.3.1 Info and Relationships | Fail | Metode pembayaran div; modal tanpa dialog; success tanpa main |
| 1.3.2 Meaningful Sequence | Partial | Pricing featured diubah `order:-1` mobile; perlu pastikan DOM/visual expectation |
| 1.4.3 Contrast Minimum | Fail | Beberapa pair 2,24–3,25:1 untuk teks normal |
| 1.4.10 Reflow | Partial pass | Tidak ada overflow 320 px; chat/help content dihilangkan |
| 1.4.11 Non-text Contrast | Risk | Focus ring tidak eksplisit dan beberapa border sangat redup |
| 2.1.1 Keyboard | Fail | Payment cards div; drawer behavior; modal focus lifecycle |
| 2.1.2 No Keyboard Trap | Not proven | Modal tidak trap sama sekali; iframe trap perlu E2E |
| 2.4.1 Bypass Blocks | Fail | Tidak ada skip link pada semua halaman |
| 2.4.3 Focus Order | Fail | Focus tidak berpindah ke modal |
| 2.4.7 Focus Visible | Risk/Fail | `.form-control:focus { outline:none }` hanya mengganti border |
| 2.4.11 Focus Not Obscured | Needs runtime | Modal/drawer belum memiliki contract |
| 2.5.8 Target Size | Fail | 7–11 target/page <24 px pada pengukuran |
| 3.2.2 On Input | Pass terbatas | Tidak ada perubahan konteks otomatis yang terdeteksi |
| 3.3.1 Error Identification | Fail | Alert generik; error login hilang; tanpa per-field error |
| 4.1.2 Name, Role, Value | Fail | Close glyph, payment divs, menu toggle, toast, dialog |
| Reduced motion | Fail | Tidak ada `prefers-reduced-motion` |

Tidak ada skip link pada sembilan halaman; semua memakai `lang="id"` dan umumnya satu H1, yang merupakan dasar baik. Target perbaikan adalah keyboard-complete untuk landing → auth → checkout → confirmation → chat, bukan sekadar skor automated scanner.

---

## J. Audit Funnel

### Pengunjung baru

```text
Landing ✓ → memahami produk ~ → bukti ✓ → harga ✕
  → checkout terbuka ✓ → submit ✕ unauthenticated
  → DOKU tidak tercapai → konfirmasi/entitlement/login/chat tidak tercapai
```

Lokasi gagal: F-001, F-002, F-007, F-021.

### Pelanggan lama

```text
Landing → [CTA login tidak ada] ✕
Deep link /chat/* → /login ✓ → input email → POST ✕ id_token hilang
```

Lokasi gagal: F-003, F-011. Bahkan pelanggan yang tahu deep link tidak dapat memenuhi form bawaan.

### Download

```text
Landing → Download ✓ → halaman rusak ~ → klik APK → file tidak ada ✕
```

Lokasi gagal: F-004, F-005.

### Legal/kepercayaan

```text
Pricing/FAQ → Refund/Terms → layout rusak + isi kontradiktif ✕
Kembali → data modal tidak dipertahankan (modal tertutup/navigasi penuh)
```

### Payment state ideal

```text
Authenticated plan selection
  → server creates idempotent pending invoice
  → DOKU sandbox/production redirect
  → return page reads opaque reference
  → server checks webhook/inquiry
  ├─ pending: wait/poll safely
  ├─ paid: provisioning
  ├─ active: CTA buka kajian
  └─ failed/expired: retry without duplicate entitlement
```

---

## K. Audit Keamanan

### Threat model ringkas

| Aktor | Target | Jalur | Control saat ini | Celah |
|---|---|---|---|---|
| Pengunjung anonim | Function cost/telemetry | Firestore logs | write-only | no auth/App Check/rate/strict size |
| User authenticated | Harga/entitlement | callable payload | server chooses amount | SKU/agent allowlist lemah, email mismatch |
| Pemalsu webhook | Aktivasi | `/doku-webhook` | HMAC, timestamp, amount, transaction | runtime secret/IAM belum diverifikasi |
| Session thief | Chat access | cookie | Secure/HttpOnly/Strict/HMAC/expiry | CSP absent; CSRF token design perlu hardening |
| Supply-chain attacker | Functions | dependencies | lockfile | 17 advisories, no CI gate/SBOM |
| XSS/content injection | Browser/Telegram | inline templates/logs | escapeHtml di beberapa titik | CSP absent, inline code luas, telemetry fields longgar |

### Strength controls yang dibuktikan

- Webhook melakukan constant-time signature comparison, timestamp window ±15 menit, invoice-format validation, paid amount verification, transaction, dan `activation_applied` idempotency.
- Session signature memakai timing-safe comparison dan entitlement diperiksa kembali pada chat.
- Firestore transaksi, redeem, rate-limit, outbox, webhook events, dan default path ditolak untuk klien.
- Backend tidak mempercayai `amount` yang dikirim browser; harga ditentukan server. Masalahnya adalah source-of-truth server tidak sama dengan UI.

### Risiko tambahan

- CSRF comparison menggunakan equality biasa dan token bersifat stateless timestamp+HMAC, tidak terikat pada session/ref/form; replay dalam window satu jam mungkin terjadi. Dampak saat ini terbatas oleh kewajiban ID token.
- `ref` dari body dipakai pada redirect tanpa normalisasi/encoding konsisten. Prefix relatif menghambat open redirect eksternal langsung, tetapi route/query manipulation tetap perlu ditutup.
- Tautan NotebookLM `target="_blank"` tidak menyertakan `rel="noopener noreferrer"`.
- Iframe memiliki title dan permission microphone, tetapi tidak memiliki `sandbox` atau `referrerpolicy`; kompatibilitas NotebookLM perlu diuji sebelum pembatasan.
- Nilai Firebase client config bukan secret otomatis; secret runtime DOKU/session harus tetap di Secret Manager dan IAM perlu diverifikasi di luar source audit.

---

## L. Audit Performa

| Item | Ukuran | Catatan |
|---|---:|---|
| `logo.png` | 2.135.868 B | 1536×1024; tidak terlihat diperlukan oleh halaman utama |
| `logo_cropped_sig.png` | 375.475 B | 437×491 |
| `logo_open_ai.png` | 424.512 B | 478×519; dipakai halaman, terlalu berat untuk logo |
| `logo_open_ai_cropped.png` | 447.825 B | 494×535 |
| Seluruh PNG | ±3,38 MB | Duplikasi variant tanpa asset policy |
| `style.css` | 23.954 B | Kecil, tetapi blocking `@import` font |
| `index.html` | 28.668 B | Inline JS dan config |
| Functions source/build/map | 90/96/65 KB | Monolit, cold-start surface lebih besar dari perlu |

Prioritas:

1. Optimasi logo dan dimensions untuk mencegah bandwidth/CLS.
2. Hapus blocking CSS `@import`; subset/self-host/preload font sesuai privacy policy.
3. Lazy-load Firebase Functions SDK ketika checkout benar-benar dimulai.
4. Asset hashing dan cache policy eksplisit.
5. Ukur LCP/CLS/INP di staging dan RUM produksi; jangan menetapkan klaim angka dari localhost.

Target awal realistis mobile staging: LCP ≤2,5 s p75, CLS ≤0,1, INP ≤200 ms, initial transfer marketing page <500 KB kecuali bukti produk memang membutuhkan media.

---

## M. Audit SEO dan Konten

- Title dan description tersedia di halaman statis; ini kekuatan dasar.
- Canonical, OG, Twitter card, schema, robots.txt, dan sitemap.xml tidak ada.
- Favicon diminta browser dan menghasilkan 404 pada server lokal.
- Login, chat, logout, dan payment success seharusnya `noindex, nofollow` serta tidak masuk sitemap.
- Klaim “6.000+ halaman”, “1.000+ transkrip”, “seluruh 8 bidang”, harga promo, versi app, metode provider, dan refund memerlukan owner dan evidence date.
- “Turath”, “turats”, “Fikih/Fiqh”, dan transliterasi perlu style guide editorial konsisten.
- Legal pages menyatakan lokasi Jakarta dan kontak Gmail; status badan hukum, data controller, retention, subprocessors, cookie/analytics, serta cross-border processing perlu legal review terpisah.
- FAQ schema hanya boleh ditambahkan jika copy publik benar dan konsisten—jangan menjadikan schema cara memperkuat klaim yang belum terbukti.

---

## N. Audit Kualitas Kode dan Test

### Build dan test

- `tsc --noEmit`: lulus.
- Build baru identik SHA-256 dengan build `functions/lib/index.js` di ZIP: source dan artifact sinkron.
- 30/30 regression test backend lulus setelah test TypeScript ditranspilasi ke direktori sementara.
- Tidak ada `npm test`; eksekusi langsung tidak portable.
- Test webview bergantung file Flutter yang tidak ada dan tidak semestinya menjadi syarat paket website.

### Matriks coverage

| Area | Test tersedia | Kualitas | Celah | Prioritas |
|---|---|---|---|---|
| Webhook signature/amount/idempotency | Ya | Baik | DOKU sandbox dan concurrency nyata | P1 |
| Entitlement activation | Ya | Baik unit/harness | Cross-SKU contract dengan UI | P0 |
| Login/session | Sebagian | Cukup backend | Browser Firebase Auth E2E | P1 |
| Checkout callable | Sebagian | Backend-centric | Public browser path dan error UX | P0 |
| Firestore rules | Tidak terintegrasi | Analisis statis | Emulator rules fuzz | P1/P2 |
| Static pages | Tidak | — | Link, semantics, visual regression | P1 |
| Responsive/accessibility | Tidak | — | 11 viewport, keyboard, screen reader | P1/P2 |
| Payment return/status | Tidak | — | Pending/failed/delayed webhook | P1 |
| External NotebookLM | Tidak | — | iframe auth, permissions, outage | P2 |

### Technical debt utama

- Backend monolitik dan template HTML/CSS/JS berada di string TypeScript.
- Tidak ada typed schema pada callable boundary.
- Domain IDs dan copy tersebar.
- Event handler serta styling inline menghambat CSP dan component reuse.
- Tidak ada lint/format/test/visual/link/accessibility release gate yang terlihat di paket.

---

## O. Quick Wins — kurang dari satu hari

1. Matikan/sembunyikan tombol checkout produksi sampai F-001/F-002 selesai; tampilkan waitlist/contact yang jujur.
2. Sinkronkan atau sementara hapus seluruh angka harga/bonus yang belum disahkan.
3. Hapus klaim refund yang konflik setelah keputusan legal final.
4. Tambahkan CTA “Masuk” hanya setelah flow login benar; sebelum itu jangan membuat dead end baru.
5. Perbaiki class shell halaman legal/download atau rollback CSS legacy yang memang cocok.
6. Tambahkan `role`, accessible name, Escape, focus lifecycle pada modal; ubah payment cards menjadi radio.
7. Hapus context-menu blocking dan tambahkan `rel="noopener noreferrer"`.
8. Tambahkan `prefers-reduced-motion` dan ubah reveal menjadi progressive enhancement.
9. Naikkan hit area link footer/nav ke minimum 24×24 dan font kritis ≥14 px.
10. Tambahkan favicon, robots, canonical, noindex route privat, dan basic OG setelah domain resmi dikonfirmasi.
11. Tambahkan script `test` yang dapat berjalan dari fresh checkout.
12. Ganti raw error alert dengan pesan aman dan correlation ID.

---

## P. Roadmap Perbaikan

### Fase 0 — Stop-the-line (L)

- Sasaran: Mencegah transaksi/kontrak produk yang salah.
- Temuan: F-001, F-002, F-008.
- Urutan: freeze checkout → keputusan katalog harga/entitlement/refund → canonical SKU → contract tests.
- Acceptance: Tidak ada CTA payment aktif sampai display/gateway/entitlement/legal identik.
- Risiko: Migrasi pelanggan dan kontrak caller aplikasi.

### Fase 1 — Memulihkan funnel utama (XL)

- Sasaran: Login, checkout sandbox, status pembayaran, entitlement, download, chat dapat selesai end-to-end.
- Temuan: F-003, F-005, F-006, F-011, F-012, F-019, F-021, F-023.
- Urutan: auth decision → login → SKU checkout → return state machine → entitlement → download manifest → failure recovery.
- Acceptance: E2E staging untuk happy path dan seluruh failure path, tanpa production transaction.
- Risiko: Integrasi akun Google/NotebookLM dan mapping legacy UID/email.

### Fase 2 — Fondasi design system (L)

- Sasaran: Satu identitas lintas marketing, legal, login, dan workspace.
- Temuan: F-004, F-014, F-015, F-024, O-001.
- Urutan: tokens → primitives → shell → components → migration halaman.
- Acceptance: Tidak ada legacy undefined class, critical inline style, atau pasangan contrast gagal.
- Risiko: CSS specificity dan inline override lama.

### Fase 3 — Responsive dan accessibility (L)

- Sasaran: WCAG 2.2 AA pada semua alur utama.
- Temuan: F-007, F-013–F-016, F-025–F-026.
- Urutan: semantics/focus → target/contrast/type → drawer/mobile states → zoom/RTL/motion.
- Acceptance: Keyboard end-to-end, screen reader smoke, 320 px reflow, 200/400% zoom, no critical axe-equivalent violations.
- Risiko: Iframe third-party membatasi kontrol internal.

### Fase 4 — Performance dan SEO (M)

- Sasaran: Fast first load dan discoverability jujur.
- Temuan: F-017, F-018, F-029.
- Urutan: assets/fonts/scripts → headers/cache → metadata/sitemap → field metrics.
- Acceptance: Target CWV p75, asset budget, no broken resource/link, valid metadata.
- Risiko: Font/brand drift dan caching salah.

### Fase 5 — Hardening produksi (L)

- Sasaran: Security, observability, dan release confidence.
- Temuan: F-009, F-010, F-020, F-022, O-003/O-004.
- Urutan: dependencies → strict schemas/rules → CSP report/enforce → CI suites → monitoring/redaction/runbook.
- Acceptance: Zero exploitable critical/high, headers verified, staging E2E/visual/rules tests green, rollback/runbook siap.
- Risiko: CSP dan dependency upgrades mematahkan integrasi eksternal.

---

## Q. Acceptance Criteria Website Siap Produksi

- [ ] Semua P0 ditutup dan evidence dilampirkan.
- [ ] Semua P1 pada funnel ditutup.
- [ ] Login Google/Firebase berhasil end-to-end untuk subscriber aktif.
- [ ] Error verified/unverified/non-subscriber/expired/revoked jelas dan aman.
- [ ] Checkout DOKU sandbox berhasil dari browser bersih.
- [ ] Harga display, SKU server, invoice, paid amount, durasi, dan entitlement identik.
- [ ] Paket semua bidang benar-benar memberi scope yang dijanjikan atau copy dihapus.
- [ ] Webhook tetap signature-validated, amount-validated, atomic, dan idempotent.
- [ ] Delayed/duplicate webhook tidak menggandakan entitlement.
- [ ] Return page memverifikasi pending/success/failed/provisioning.
- [ ] Pengguna dapat melanjutkan kembali setelah refresh/interupsi.
- [ ] Tautan download valid, ukuran/versi/checksum cocok manifest.
- [ ] Tidak ada broken link, missing asset, favicon 404, atau critical console error.
- [ ] Semua halaman memakai design shell dan komponen kanonikal.
- [ ] Tidak ada horizontal overflow pada 11 viewport utama.
- [ ] Ponsel portrait/landscape, tablet, desktop, safe area, dan virtual keyboard diuji.
- [ ] Seluruh alur utama dapat dilakukan hanya dengan keyboard.
- [ ] Modal/drawer memiliki semantics, focus trap, Escape, restore, dan scroll lock.
- [ ] Semua critical text/UI contrast memenuhi WCAG AA.
- [ ] Target interaktif minimum 24×24; CTA mobile ideal 44×44.
- [ ] Reduced motion, zoom 200/400%, RTL/Arabic, dan screen reader smoke lulus.
- [ ] LCP ≤2,5 s, CLS ≤0,1, INP ≤200 ms p75 pada data representatif.
- [ ] Security headers tersedia dan CSP enforced setelah report-only stabil.
- [ ] Tidak ada secret server di source/client; client Firebase config diklasifikasi dengan benar.
- [ ] Critical/high dependency resolved atau risk acceptance formal.
- [ ] Firestore rules emulator tests dan telemetry anti-abuse lulus.
- [ ] Error/fallback 404, 503, offline, iframe blocked, denied, expired, pending tersedia.
- [ ] Canonical/OG/schema/robots/sitemap/noindex policy tervalidasi.
- [ ] Test unit, contract, emulator, E2E, accessibility, link, dan visual regression lulus di CI.
- [ ] Halaman legal konsisten dengan perilaku aktual dan mendapat legal sign-off.
- [ ] Klaim korpus, jumlah halaman/transkrip, provider, versi, harga, dan bidang memiliki owner/evidence date.
- [ ] Monitoring, PII redaction, alert threshold, runbook, dan rollback siap.

---

## R. Pertanyaan untuk Pemilik Produk

1. Apakah website dimaksudkan sebagai landing page, aplikasi web penuh, atau kanal distribusi aplikasi?
2. Apakah checkout wajib setelah login atau harus mendukung tamu?
3. Apakah login resmi Google/Firebase, magic-link email, atau lookup subscriber?
4. Apakah akun Google OpenTurath harus sama dengan akun yang diberi akses NotebookLM?
5. Apa sumber harga kanonikal: Rp99k/499k/799k, Rp299k/1.499k/1.999k, atau Rp49k/299k/499k?
6. Apakah paket tahunan benar-benar mencakup delapan bidang? Bidang mana saja?
7. Apakah paket semua-AI sengaja dinonaktifkan? Jika ya, mengapa masih dipromosikan?
8. Apa hubungan legal/brand antara Akal dan DOKU, dan nama apa yang harus dilihat pelanggan?
9. Kebijakan refund mana yang berlaku: no-refund atau tujuh hari/maksimum lima kredit?
10. Apakah ada subscription auto-renew? Refund page menyebut penghentian tagihan otomatis, tetapi source checkout tidak menunjukkan recurring billing.
11. Apa return URL dan status state machine resmi setelah DOKU?
12. Apa sumber versi rilis/ukuran/checksum aplikasi yang kanonikal?
13. Apakah website memang harus menyajikan APK, dan siapa pemilik pipeline rilisnya?
14. Enam agent backend mana yang benar-benar tersedia; mengapa menu web hanya empat?
15. Apakah NotebookLM preview dapat di-embed untuk seluruh akun/browser dan apa fallback ketika Google login/cookie diblokir?
16. Apakah chat web akan tetap wrapper NotebookLM atau menjadi UI OpenTurath native?
17. Mana email dukungan resmi: Gmail atau domain `openturath.com`?
18. Siapa data controller, badan hukum, alamat resmi, retention period, dan subprocessors?
19. Apakah Google Fonts, Firebase, DOKU, NotebookLM, Telegram, dan Akal sudah tercakup Privacy Policy?
20. Siapa target primer: mahasiswa, ustaz, peneliti akademik, atau publik umum?
21. Apakah bahasa Arab/RTL akan menjadi mode penuh atau hanya kutipan?
22. Apakah klaim 6.000+ halaman, 1.000+ transkrip, dan cited answers sudah diverifikasi serta memiliki tanggal data?
23. Apakah prioritas brand adalah editorial-ilmiah terang atau dashboard gelap? Bolehkah keduanya menjadi tema yang konsisten?
24. Apa SLA aktivasi setelah pembayaran dan support escalation bila provisioning gagal?
25. Siapa yang berwenang memberi keputusan GO setelah product, legal, security, dan payment sign-off?

---

## Kesimpulan Akhir

OpenTurath memiliki inti visual landing yang menjanjikan dan beberapa control backend payment/session yang dibangun dengan perhatian cukup baik. Masalah terbesarnya bukan sekadar “UI kurang modern”, melainkan website berkembang menjadi beberapa sistem yang tidak lagi berbagi kontrak: landing dan halaman pendukung memakai class berbeda; harga dan entitlement mempunyai sumber berbeda; form login dan backend memakai mekanisme identitas berbeda; payment webhook dan return UX tidak menjadi satu state machine; marketing light dan workspace dark tidak menjadi satu brand.

Urutan yang benar adalah menghentikan transaksi, mengunci kontrak produk, memulihkan login/payment secara end-to-end, baru menyatukan design system dan aksesibilitas. Redesign visual tanpa membereskan kontrak tersebut hanya akan membuat funnel yang rusak terlihat lebih meyakinkan—dan karena itu lebih berisiko.
