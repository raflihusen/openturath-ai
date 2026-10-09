# Audit lanjutan dan kontrak akses Midtrans → master/cabang → aplikasi

Tanggal: 9 Oktober 2026. Status: rancangan yang diperbaiki berdasarkan audit kode lokal; belum diterapkan atau dibuktikan pada layanan produksi. Melengkapi `AUDIT_DAN_RANCANGAN_VPS.md`, bukan menggantikannya. Tidak ada perubahan kode operasional, pembayaran, sharing, atau akses pelanggan dalam audit ini.

## 1. Jawaban utama

**Alur overflow belum tersambung penuh dengan aplikasi.** Aplikasi sudah mengambil URL dari server dan mempertahankan UUID notebook yang dikembalikan. Akan tetapi resolver server saat ini selalu mengembalikan master, tidak membaca assignment cabang. Katalog cabang tersedia, tetapi katalog tidak sama dengan allocator dan bukti pemberian akses.

Target akhir: setelah pembayaran sah, server menetapkan notebook per pengguna/per entitas, memberi akses, memverifikasi membership, lalu semua pintu aplikasi menggunakan assignment yang sama. Pengguna tetap pada notebook tersebut saat login ulang, pindah perangkat, dan memperpanjang paket. Master penuh mengalihkan **pengguna baru** ke cabang sehat yang mempunyai kursi; pengguna lama tidak dipindah acak.

Tidak ada sistem yang dapat dijanjikan bebas kegagalan mutlak. Kontrak di bawah bertujuan mencegah kesalahan yang diketahui, mendeteksi kegagalan, dan menyelesaikan pekerjaan tertunda secara otomatis dengan bukti hasil. Kegagalan layanan Google atau seluruh VPS tetap dapat menunda penyelesaian; tidak boleh disamarkan sebagai sukses.

## 2. Kajian lama yang ditemukan

| Dokumen | Lokasi dan isi penting |
| --- | --- |
| Waterfall/Sticky Pooling | `/Users/apple/Downloads/ramadhan/NOTEBOOKLM_SCALING_AND_REPLICA_POOLING.md` — contoh allocator, assignment tetap, ambang operasional 1.950 dari batas 2.000 |
| Smart Slot Recycling | `/Users/apple/Downloads/ramadhan/STRATEGI_NOTEBOOK_REPLICA_POOLING_1995.md` — ambang operasional 1.995, pengisian kembali kursi yang kosong, assignment tetap |
| Katalog master/cabang | `/Users/apple/Downloads/Kitab Tahawwulat RAG/OPENTURATH_NOTEBOOK_CATALOG.md` |
| Manifest cabang | `/Users/apple/Downloads/Kitab Tahawwulat RAG/cloned_notebooks_master_catalog.json` |
| Salinan katalog di SSD Husen | `/Volumes/Husen/download/_Proyek OpenTurath & Web/OpenTurath_Audit_Refactor/openturath_ai/docs/OPENTURATH_NOTEBOOK_CATALOG.md` |

Manifest lokal mempunyai **312 baris, 312 UUID cabang unik, 24 entitas, tepat 13 cabang per entitas**. Seluruh UUID cabang tersebut ditemukan dalam katalog TypeScript saat audit sebelumnya pada tanggal yang sama. Katalog SSD bertanggal 18 September 2026 dan mencatat struktur 24 × 13 yang sama. Pernyataan “terverifikasi” dalam dokumen historis bukan pemeriksaan sharing/kesehatan cabang secara langsung hari ini. Pencarian SSD diarahkan pada folder proyek terkait, bukan pemeriksaan seluruh isi setiap disk.

Batas 2.000 pengguna per notebook mengikuti hasil pengecekan pemilik. Angka 1.950/1.995 merupakan pilihan buffer dalam kajian lama, bukan batas platform baru. Registry menyimpan `hard_limit=2000` dan `admission_limit` tersendiri. Kapasitas dihitung dari seluruh membership nyata, termasuk VIP, undangan, serta reservasi yang belum selesai; tidak menganggap 1.995 pelanggan ditambah VIP selalu aman.

## 3. Bukti celah pada rencana dan implementasi

### 3.1 Rencana lama belum aman terhadap permintaan bersamaan

Contoh TypeScript dari dokumen Waterfall dieksekusi secara lokal dengan database simulasi yang mendukung retry transaksi, tanpa menghubungi Google atau Firestore produksi:

- Sepuluh pemanggilan bersamaan dari UID yang sama menghasilkan counter **10** untuk satu assignment pengguna. Fungsi membaca assignment dari `userData` di luar transaksi, lalu hanya membaca ulang pool. Ketika transaksi diulang, ia tetap menganggap pengguna belum mempunyai assignment.
- Saat seluruh replica mencapai ambang, fungsi tetap mengembalikan `FULL-NOTEBOOK` melalui fallback terakhir, alih-alih menolak reservasi atau menunggu kapasitas.
- Pool yang tidak ditemukan mengembalikan `DEFAULT-NOTEBOOK`, tanpa bukti pengguna mempunyai membership di sana.

Tambahan hasil baca kode: counter naik sebelum sharing terverifikasi; notifikasi berada di callback transaksi yang bisa dieksekusi ulang; satu dokumen array pool menjadi titik persaingan; semua status selain disabled dapat ikut dipilih; SOP “Anyone with link” tidak memberikan kontrol pencabutan individual yang dibutuhkan proyek. Skrip manajemen pool yang disebut kedua kajian tidak ditemukan pada lokasi workspace yang diaudit.

### 3.2 Server memilih master meski assignment cabang tersedia

`openturath_ai/functions/src/notebook_catalog.ts:638`: `resolveAgentNotebook(agentId, uid)` tidak menggunakan UID dan langsung mengembalikan master. `functions/src/index.ts:280` memanggil resolver tersebut untuk `getAgentUrl`.

Uji lokal memakai fungsi backend asli dan user berhak aktif, dengan assignment fixture ke cabang `a1111111-b222-c333-d444-e55555555555`. Respons justru memilih master legacy Syafi'i `334e7b83-0e76-4787-a1d6-314642a35862`, `isMaster=true`. Ini membuktikan assignment yang disimpan tidak memengaruhi hasil resolver saat ini; fixture bukan pelanggan nyata.

Master Syafi'i di manifest dan katalog SSD adalah `c89d09ca-4b48-4000-a98d-59e532607fb6`, sesuai aturan workspace. Registry saat ini masih memuat legacy `334e…`. Migrasi harus menginventarisasi membership keduanya, mempertahankan VIP, dan tidak menghapus riwayat legacy sebelum pencabutan historis bisa dijamin.

### 3.3 Aplikasi mendukung URL cabang, tetapi belum mengelola seluruh perubahan assignment

| Pintu akses | Bukti saat audit | Kontrak yang diperlukan |
| --- | --- | --- |
| AgentService/WebView | URL server dipakai; host dinormalisasi, UUID dipertahankan | Ambil assignment yang sudah ready beserta revision; URL tidak boleh dipilih dari katalog master lokal |
| Tab yang sudah terbuka | URL tersimpan pada sesi; aktivasi ulang memeriksa kesehatan surface, bukan revision assignment | Invalidasi berbasis UID, perubahan hak, dan revision; tetap mempertahankan seluruh standar lifecycle WebView |
| Gate langganan aplikasi | Cached user dapat menolak sebelum server diperiksa | Refresh hak pada perubahan pembayaran/login; bedakan belum berhak dari pembayaran sah yang sedang disiapkan |
| Browser companion | Mengambil URL server setiap pengiriman; mempunyai pemeriksaan pemilik/generation; conversation key mencakup notebook | Gunakan resolver yang sama dan tolak job dari sesi akun sebelumnya |
| Logout normal | AuthService sudah menutup seluruh tab dan membersihkan sesi desktop/companion | Pertahankan perilaku ini; uji juga perubahan akun eksternal dan perubahan hak saat tab masih aktif |
| chatGate/wrapper web | Preview masih memakai notebook statis dari AGENTS | Sambungkan ke resolver assignment yang sama atau nonaktifkan jalur lama secara eksplisit |
| askAgent native | Prototipe dibatasi test UID; mengirim agentId/UID ke bridge | Sebelum rollout, bridge harus memvalidasi assignment/revision yang sama; jangan menganggap prototipe sudah mendukung seluruh cabang |

Empat suite Flutter terkait URL kanonis, browser companion, session manager, dan navigasi notebook lulus: **51 tes, exit 0**. Ini bukti perilaku fixture lokal, bukan pembuktian login Google nyata atau overflow produksi.

Login Firebase dan sesi Google NotebookLM adalah dua identitas berbeda. Email hint pada layar Google tidak membuktikan akun Google yang aktif sama dengan akun yang diberi akses. Uji nyata wajib mencakup kondisi kedua akun berbeda, tanpa mengotomasi atau melewati proses login Google.

## 4. Kontrak data tunggal

1. **Ledger pembayaran:** order ID, transaction ID, gateway, nominal, mata uang, status terverifikasi, waktu bayar, produk/versi harga, dan UID pemilik. Keunikan transaksi dijamin database. Rp0 hanya grant admin yang eksplisit, bukan perpanjangan otomatis.
2. **Grant per modul:** alasan akses, durasi, awal/akhir UTC, sumber transaksi atau keputusan owner. Projection profil diturunkan dari ledger/grant; bukan sumber kebenaran satu-satunya. Renewal satu kali per transaksi dan tidak menggandakan assignment.
3. **Pemetaan produk → modul → entitas:** semua produk yang dapat dibeli harus mempunyai pemetaan lengkap. Lima AI Tahawwulat dapat berbagi hak modul tetapi tetap mempunyai lima assignment notebook. Alias agent menuju entitas yang sama menggunakan satu assignment. Bundel tidak diaktifkan hanya karena rancangan mendukungnya.
4. **Registry notebook:** entity ID stabil, UUID notebook, owner, master/replica, batas, kesehatan, corpus version, dan status active/standby/draining/quarantined/disabled. Standby baru boleh menerima assignment setelah validasi dan aktivasi. Jangan menjadikan URL sebagai identitas utama.
5. **Assignment `(uid, entityId)`:** target notebook, status, revision, membership evidence, dan riwayat target. Semua perangkat dan pintu masuk membaca assignment yang sama. Riwayat diperlukan untuk mencabut akses yang tertinggal.
6. **Membership fisik `(verifiedGoogleIdentity, notebookId)`:** pisahkan dari UID aplikasi. Jumlah kursi mengikuti identitas Google yang benar-benar menjadi viewer. Bila satu email terhubung ke lebih dari satu UID, jangan mengurangi counter atau mencabut membership sebelum seluruh alasan akses diperiksa; konflik kepemilikan masuk recovery identitas.
7. **Outbox per operasi:** job ID unik, desired revision, lease, retry/backoff, hasil observasi, dan error terakhir. Perubahan ledger/grant, assignment/reservasi, dan pencatatan job yang terkait dilakukan dalam transaksi database yang sesuai. Google sharing dilakukan di luar transaksi.

VIP merupakan grant permanen dan perlindungan owner pada seluruh jalur. Semua indikator VIP yang diakui AGENTS.md dihormati. Registri VIP tidak dapat dimuat/hasilnya ambigu → hentikan removal terkait sampai aman. Overflow, refund, restore, dan migrasi tidak boleh otomatis memindahkan atau mencabut VIP.

## 5. Alur yang disempurnakan

### 5.1 Checkout dan settlement

- Checkout terikat UID terautentikasi serta email Google terverifikasi, bukan email pembayar yang bebas diisi. Harga dan cakupan produk dihitung server. Klik ulang menggunakan idempotency key; timeout tidak otomatis menciptakan order kedua.
- Admission memeriksa kelengkapan mapping, kesehatan pool, dan kapasitas. Reservasi sebelum bayar mempunyai expiry mengikuti order. Jangan menahan ribuan kursi tanpa batas; jangan menerima order baru saat kapasitas sudah tidak dapat dipenuhi sesuai janji layanan.
- Webhook diverifikasi, lalu status transaksi diperiksa terhadap Midtrans; bandingkan order, nominal, mata uang dan status. Notifikasi duplikat/terlambat tidak memperpanjang dua kali atau menurunkan pembayaran sah menjadi expired secara buta. Simpan event secara tahan lama sebelum membalas penerimaan.
- Jika settlement datang setelah reservasi checkout lepas, allocator mencoba kursi sehat yang tersedia. Jika belum tersedia, status jelas `paid_waiting_capacity`, dengan recovery/refund yang sudah ditentukan; tidak mengirim master penuh dan tidak menyuruh membeli lagi.
- Refund/partial refund/chargeback mengubah grant yang relevan melalui kebijakan tercatat, bukan menghapus seluruh hak pengguna. Grant lain dan VIP tetap diperiksa.

Referensi Midtrans yang digunakan dalam audit awal: [HTTP notification/webhooks](https://docs.midtrans.com/docs/https-notification-webhooks), [Handle notifications](https://docs.midtrans.com/reference/handle-notifications). Perhitungan masa paket mengikuti kebijakan produk yang dikunci; paket satu bulan historis mengikuti 30 hari sesuai aturan workspace, bukan berubah diam-diam menjadi bulan kalender.

### 5.2 Reservasi dan pemberian akses

Dalam transaksi, baca ulang assignment dan kapasitas target sebelum menulis. Jika assignment sah sudah ada, gunakan itu. Jika belum, waterfall memilih master/cabang sehat berdasarkan urutan prioritas, kemudian membuat reservasi unik, assignment pending, dan outbox. Dua transaksi untuk UID/entitas yang sama tidak dapat menciptakan dua reservasi. Dua UID berebut satu kursi tidak dapat melampaui kapasitas.

Kapasitas memakai membership terobservasi + reservasi/in-flight yang belum tercermin di observasi, tanpa menghitung dua kali operasi yang sama. Gunakan counter/record per notebook atau token kursi dengan batas atomik; bukan array global seluruh pool atau counter perkiraan yang tidak bisa menjamin batas. Kursi kembali hanya setelah removal terverifikasi. Kursi kosong di master boleh dipakai pelanggan baru; pelanggan cabang lama tetap di cabangnya.

Worker memeriksa desired revision dan hak terbaru sebelum sharing, menambahkan viewer, lalu membaca ulang daftar viewer untuk memastikan **email sasaran** hadir. Respons HTTP 200 atau jumlah viewer naik tidak cukup. Setelah observasi, assignment menjadi `ready`. Paket multi-entitas menyimpan readiness per entitas dan status paket keseluruhan; kegagalan satu cabang tidak membuat semuanya diklaim siap.

Reservasi yang habis waktu tidak otomatis dilepas bila Google mungkin sudah menambahkan viewer. Lease worker yang kedaluwarsa berarti perlu observasi/repair; tidak berarti kursi pasti kosong. Notifikasi pelanggan/admin dijalankan dari event setelah commit, bukan dari callback transaksi.

### 5.3 Login dan membuka AI

`getAgentUrl` memvalidasi akun dan hak terbaru, memetakan alias ke entitas, lalu membaca assignment. Ia mengembalikan `ready`, URL registry, UUID, entity ID, revision, dan masa validitas respons. Server tidak menerima pilihan UUID arbitrer dari aplikasi.

**Membuka AI tidak menambah counter atau membuat assignment baru secara diam-diam.** Pengguna paid/pending mendapat status persiapan yang bisa dipulihkan. Pengguna berhak tanpa assignment masuk antrean repair/legacy import; tidak otomatis diberi URL master. Hanya assignment legacy yang membership-nya sudah dibuktikan boleh diimpor sebagai ready.

Aplikasi menampilkan “akses sedang disiapkan” untuk hak sah yang belum ready, serta refresh setelah status berubah. Cache/sesi terikat `(uid, sessionGeneration, entityId, assignmentRevision)`. Account switch, pencabutan hak, dan migrasi menginvalidasi akses sesuai revision. Browser companion dan wrapper web memakai kontrak yang sama.

UUID cabang sudah bisa ditampilkan oleh jalur URL aplikasi sekarang. Namun status persiapan, revision, dan invalidasi membutuhkan perubahan aplikasi/server; jangan menjanjikan seluruh rancangan selesai tanpa pembaruan APK. Seluruh perubahan wajib mempertahankan empat sampel kesiapan, minimum elapsed 3.000 ms, microdelay 250 ms, dan error viewport bersih sesuai AGENTS.md.

### 5.4 Ekspirasi dan pencabutan

Scheduler memilih grant berakhir dengan pagination/cursor dan mengevaluasi ulang hak per modul, seluruh alasan grant, serta VIP. Ia membuat desired state revoke untuk semua notebook relevan pada riwayat assignment dan membership yang ditemukan. Satu modul berakhir tidak menghapus hak modul lain.

Worker memeriksa revision sebelum operasi; job lama tidak boleh membatalkan renewal baru. Karena pengecekan database dan Google tidak atomik, gunakan serialisasi operasi per membership dan reconciliation setelah hasil eksternal: jika hak berubah saat removal, segera jadwalkan add kembali dengan revision terbaru. Jangan mengklaim fencing database sendirian menutup seluruh race eksternal.

Removal dianggap selesai hanya setelah email sasaran tidak ditemukan pada pembacaan viewer yang lengkap. `revocation_pending/failed` tetap menjadi pekerjaan aktif dengan retry, observasi, dan alert; batas retry tidak boleh membuat job hilang selamanya. Counter baru berkurang setelah absensi terbukti, tanpa menyentuh VIP atau membership yang masih mempunyai grant lain.

Blokir semua akses publik “Anyone with link” pada notebook berbayar yang memerlukan pencabutan individual. Jika mode publik ditemukan, notebook dikarantina dari penempatan baru dan perbaikannya ditinjau sebelum dinyatakan aman. Menghapus viewer individual tidak cukup apabila URL tetap memberi akses publik.

### 5.5 Recovery, perpindahan dan pergantian email

Reconciliation berjalan dua arah: membandingkan hak/assignment database dengan membership nyata, mencatat orphan, pending grant, pending revoke, serta mismatch counter. Repair tidak menebak berdasarkan total viewer saja. Pengguna lama yang ditemukan di beberapa notebook dicatat semuanya dahulu; tidak dipindah massal dari perkiraan.

Perpindahan notebook harus eksplisit, memiliki revision dan jejak keputusan. Grant/verify target dahulu; perubahan assignment dan revoke sumber mempertimbangkan tujuan migrasi dan larangan VIP. Riwayat percakapan Google tidak dijanjikan ikut berpindah; catatan yang dimiliki aplikasi dipertahankan sesuai penyimpanannya.

Ganti email, akun dihapus/dibuat ulang, pembelian sebelum signup, dan pembayaran oleh orang lain masing-masing membutuhkan aturan pengikatan identitas. Email baru diverifikasi; akses lama tidak dibiarkan permanen akibat perubahan profil. Jangan menerapkan normalisasi alias Gmail secara spekulatif; gunakan identitas kanonis yang benar-benar diverifikasi provider.

## 6. VPS dan pembuktian skala

VPS menjalankan layanan penerima event, allocator, worker, scheduler dan reconciliation yang diawasi proses serta mempunyai heartbeat. Peran tersebut dapat berada dalam satu aplikasi dengan database yang kuat; 10.000 user tidak mengharuskan puluhan microservice. Firestore yang sudah dipakai dapat dipertahankan jika memenuhi transaksi/keunikan dan migrasi; jangan memiliki dua database yang sama-sama menjadi sumber kebenaran.

Laptop tidak menjadi syarat jalannya pemberian/pencabutan. Saat cutover, hanya satu penulis aktif; daemon lokal/Cloud Run lama dihentikan atau diberi fencing. Jangan menjalankan dua reaper dengan keputusan berbeda. Inventarisasi deployment aktual dan konfigurasi runtime wajib dilakukan sebelum cutover; pembacaan kode lokal belum membuktikan deployment mana yang aktif hari ini.

Backup di luar VPS, uji restore, replay ledger/outbox, proteksi secret, isolasi sandbox/production, dan monitoring layanan Google merupakan bagian acceptance. Satu VPS tanpa pemulihan tetap mempunyai titik kegagalan. Setelah restore, reconciliation memperhitungkan pembayaran yang terjadi setelah waktu backup dan membership yang belum tercatat.

Cabang dalam akun owner yang sama bukan redundansi autentikasi owner. Kapasitas viewer, throughput sharing, dan jumlah chat bersamaan diuji terpisah. Katalog 312 cabang tidak membuktikan sharing 240.000 membership untuk 10.000 pembeli semua 24 entitas dapat selesai dalam waktu yang dijanjikan. Uji worker/rate limit secara bertahap, lalu tentukan kapasitas operasi serta SLA dari hasil pengukuran.

Target rancangan awal yang perlu dibuktikan: job expiry dibuat maksimal 60 detik setelah jatuh tempo; saat provider sehat, sekurang-kurangnya 99,9% removal selesai terverifikasi dalam 5 menit; semua kegagalan melampaui batas tersebut muncul dalam dashboard/alert. Ini target engineering, bukan hasil pengujian atau garansi saat provider mati. Dashboard menunjukkan usia keterlambatan nyata, bukan hanya status scheduler hidup.

## 7. Gerbang implementasi dan penerimaan

| Tahap | Bukti wajib sebelum lanjut |
| --- | --- |
| Inventaris | Pemetaan seluruh produk/alias/24 entitas; canonical master Syafi'i; kesehatan dan mode sharing cabang; lokasi deployment aktif; snapshot VIP dan ledger |
| Shadow audit | Hitung desired rights tanpa mutation; cocokkan legacy/branch membership; jelaskan semua selisih, tidak menebak expiry dari profil korup |
| Ledger dan allocator | Webhook duplicate/out-of-order; settlement setelah reservasi habis; 100 pembayaran berebut satu kursi; 100 membuka UID sama menghasilkan satu assignment; pool penuh tidak fallback |
| Worker | Crash sebelum/sesudah sharing; job lama setelah renewal; timeout tak diketahui; verifier membaca viewer lengkap; tidak mengurangi kursi sebelum removal terbukti |
| Aplikasi | Akun terdaftar master membuka master; terdaftar cabang membuka cabang persis; login ulang/perangkat kedua sama; akun Google berbeda; cache lama/remote revoke; paid-pending tidak meminta bayar lagi |
| Multi-entitas/VIP | Tahawwulat lima entitas; produk lain seluruh mapping; fanout gagal sebagian; grant lintas modul; refund satu order; seluruh indikator VIP tetap utuh |
| Recovery | Laptop mati, VPS restart, owner auth habis, provider timeout, restore backup, double worker/lease expired, perubahan email dan UID |
| Skala | Dataset 10.000 tanpa overbooking, tanpa assignment salah; antrean terukur; viewer reconciliation berpaginasi; alert benar-benar terkirim ke kanal yang disetujui |
| Cutover bertahap | Sandbox dan akun uji consented → kelompok kecil → peningkatan bertahap; rollback tercatat; penulis lama berhenti; audit hasil nyata sebelum perluasan |

Hasil audit ini menyempurnakan kontrak dan mengidentifikasi celah yang dapat direproduksi. Sistem baru baru dapat dinyatakan memenuhi rancangan setelah implementasi serta gerbang di atas lulus. Pengujian lokal saat ini tidak membuktikan pemberian/cabut akses nyata di Google, kesehatan semua cabang, atau kapasitas VPS yang belum diukur.
