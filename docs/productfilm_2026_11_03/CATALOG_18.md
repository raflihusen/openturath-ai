# Daftar 18 AI untuk revisi film produk

3 November 2026 · Pemeriksaan kode lokal, bukan pembacaan konfigurasi produksi atau uji akses akun.

Sumber induk: `openturath_ai/lib/models/agent_model.dart:177–904`. Ada **18 konstruktor AgentModel induk** dalam `defaultAgents`. Lima sub-AI Tahawwulat berada di dalam satu induk Tahawwulat dan tidak dihitung lagi sebagai lima bidang tambahan. Getter judul menambahkan awalan **AI** pada label tampil (`:12–15`).

| Urutan katalog | ID | Judul sumber Indonesia | Judul Arab | Lokasi awal model |
|---|---|---|---|---|
| 1 | `fiqh_tahawwulat` | Fikih Tahawwulat | فقه التحولات | 179 |
| 2 | `fiqh_syafii` | Fikih Syafi'i | الفقه الشافعي | 265 |
| 3 | `fiqh_hanafi` | Fikih Hanafi | الفقه الحنفي | 316 |
| 4 | `fiqh_maliki` | Fikih Maliki | الفقه المالكي | 365 |
| 5 | `fiqh_hanbali` | Fikih Hanbali | الفقه الحنبلي | 413 |
| 6 | `fiqh_muqaran` | Perbandingan Mazhab & Fatwa | الفقه المقارن والفتاوى | 462 |
| 7 | `hadits` | Hadits | الحديث الشريف | 512 |
| 8 | `tafsir` | Tafsir | التفسير وعلوم القرآن | 563 |
| 9 | `ushul_fiqh` | Ushul & Kaidah Fikih | أصول الفقه والقواعد الفقهية | 615 |
| 10 | `nahwu_sharaf` | Bahasa Arab | علوم العربية | 667 |
| 11 | `aqidah` | Aqidah | العقيدة والتوحيد | 729 |
| 12 | `tarikh` | Sejarah & Sirah | السيرة والتاريخ | 753 |
| 13 | `tasawwuf` | Tasawuf | التصوف والأذكار | 776 |
| 17 | `tajwid_qiraat` | Tajwid & Qira'at | التجويد والقراءات | 793 |
| 18 | `musthalah_hadits` | Ilmu Hadits | مصطلح الحديث | 815 |
| 19 | `syarah_hadits` | Syarah Hadits | شروح الحديث النبوي | 837 |
| 20 | `thabaqat_rijal` | Rijal & Biografi Ulama | طبقات المحدثين ورجال الأسانيد | 860 |
| 21 | `bibliografi_faharis` | Bibliografi Kitab | فهارس التراث والببليوغرافيا | 882 |

Urutan di atas mempertahankan nilai `sortOrder` sumber, termasuk loncatan 13 ke 17. Loncatan itu bukan empat entri tambahan; jumlah model tetap 18. Untuk penomoran film, gunakan indeks presentasi 01–18, bukan menyimpulkan jumlah dari nilai urutan terbesar 21.

## Batas klaim ketersediaan

Semua 18 model bawaan berstatus `active`, tetapi itu **bukan** bukti bahwa semua telah aktif untuk distribusi atau akun publik saat ini:

- `AgentService._applyActiveStatus` menerapkan ulang status berdasarkan himpunan ID aktif; ID yang tidak aktif menjadi `coming_soon`: `openturath_ai/lib/services/agent_service.dart:50–69`.
- Himpunan itu dapat berasal dari Firestore `app_config/agents.active_agent_ids` dan cache: `:72–125`.
- Daftar peluncuran bawaan hanya memasukkan induk Tahawwulat, Syafi'i, dan sub-AI terkait: `:38–48`.
- Edisi Guru mengaktifkan seluruh model pada sisi klien: `:52–55`; getter model juga memperhitungkan edisi tersebut (`agent_model.dart:68–71`).
- Pengambilan URL AI tetap melalui callable server dan dapat menolak atau tidak menyediakan alamat: `agent_service.dart:132–158`.

Untuk film, perkenalkan **18 AI dalam katalog** tanpa kalimat “18 AI aktif” atau “semuanya siap dipakai”. Keterangan singkat yang dapat dipakai: **“Lihat ketersediaan dan akses di aplikasi.”** Nama dan jumlah menjelaskan cakupan katalog; klaim akses mengikuti status layanan serta hak akun yang benar.

## Pemeriksaan jumlah

Pemeriksaan mengidentifikasi konstruktor induk berindentasi delapan spasi (`AgentModel(`), lalu membaca ID, judul, Arab, status, dan urutan pertama pada setiap blok. Hasilnya 18 ID unik dan 18 judul unik. `SubAgentModel` tidak dicampurkan ke hitungan. Nama Latin di tabel mengikuti teks model; ejaan bidang pada layar beranda dapat memakai label kategori yang berbeda.
