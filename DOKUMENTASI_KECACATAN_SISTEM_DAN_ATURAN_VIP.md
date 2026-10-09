# DOKUMENTASI LENGKAP KECACATAN SISTEM & HUKUM SAKRAL VIP OPENTURATH AI
**Tanggal Audit:** 09 Oktober 2026  
**Status:** DOKUMEN WAJIB DIBACA SEMUA AI & PENGEMBANG (MANDATORY CONTEXT)

---

## ⚠️ PERINGATAN KERAS UNTUK SEMUA AI (CRITICAL DIRECTIVE)

> [!CAUTION]
> **HUKUM 1: YANG VIP ADALAH VIP SEJATI (JANGAN PERNAH DIRAGUKAN ATAU DICABUT!)**  
> Semua akun yang berstatus **VIP**, terdaftar di `STATIC_WHITELIST`, bertanda `is_vip: true`, `role: "vip"`, atau memiliki dokumen transaksi `VIP_PERMANENT` adalah **HAK PREROGATIF MUTLAK DARI PEMILIK (OWNER)**.  
> Mereka adalah Asatidz, Masyayikh, guru turats, tamu kehormatan, dan mitra terpilih (termasuk `prilatief@gmail.com`, `alkhateeb23@gmail.com`, `omarasb1441@gmail.com`, `udinvoldigoad05@gmail.com`, dan seluruh Masyayikh).  
> **DILARANG KERAS BAGI AI:**
> 1. Menganggap akun VIP sebagai "kesalahan input" atau "dokumen palsu".
> 2. Mencoba mencabut akses akun VIP dari Google NotebookLM.
> 3. Menghapus akun VIP dari whitelist atau database.

---

## 🔍 KECACATAN FATAL SISTEM: KASUS NADIA SAFIRA (`ndsfraaaaaaa@gmail.com`)

### 1. Riwayat Nyata Pengguna
- **Fakta Hak Akses:** Nadia Safira diberikan akses **1 bulan Fikih Syafi'i** secara manual pada **21 Agustus 2026 pukul 01:18:07 UTC** melalui transaksi `manual_1787275087_nadia`.
- **Tanggal Kadaluarsa Seharusnya:** **20 September 2026 pukul 01:18:07 UTC**.
- **Status Riil Saat Audit (Oktober 2026):** Sudah kedaluwarsa lebih dari 19 hari yang lalu.

---

### 2. Mengapa Sistem Otomasi & AI Gagal Mendeteksi Nadia sebagai Expired?

Ada **5 lapis kecacatan teknis** yang menyebabkan Nadia lolos dari sistem pencabutan:

```
[21 Ags 2026] Manual Grant: 1 Bulan (Exp: 20 Sep 2026)
      │
      ▼
[23 Sep 2026] 8x Sync/Webhook Ghost Run (Setiap 5 menit, Rp 0)
      │
      ▼
[webhook_server.py:418] Compounding Loop Tanpa Idempotensi
      │  Expiry ditumpuk: 2026-10 -> 2026-11 -> ... -> 2028-03-31!
      ▼
[users/ndsfraaaaaaa@gmail.com] Korup: subscription_expiry = 2028-03-31
      │
      ▼
[autonomous_reaper.py:427] Reaper Percaya Buta pada subscription_expiry
      │  Karena 2028 > 2026, Nadia dimasukkan ke 'active_map'
      ▼
[autonomous_reaper.py:493] strictly_expired = (viewers & expired) - active
      │  Nadia DISUBTRAKSIKAN dari daftar cabut!
      ▼
[autonomous_reaper.py:92] Notebook ID Master Fikih Syafi'i Mismatch!
      │  Reaper hanya monitor notebook legacy (334e...),
      │  tidak pernah monitor Master Fikih Syafi'i aktif (c89d...)
      ▼
HASIL FATAL: Nadia tetap menjadi Viewer aktif di 4 Notebook hingga Oktober 2026!
```

#### A. Kecacatan 1: Loop Sinkronisasi Hantu (Ghost Compounding Loop) Tanpa Idempotensi
Pada 23 September 2026 antara pukul 17:04 dan 17:39 UTC, terjadi siklus otomatis/sync yang berjalan tepat **setiap 5 menit** dan menciptakan 8 transaksi dengan `amount: 0.0`:
1. `yzmZuDE4mRVScqeEupyW` (17:04:20)
2. `4PEniBmuqjJ1m7mAKst5` (17:09:30)
3. `LekBiGnrLJCROsteuCiG` (17:14:26)
4. `Fh4BE4zOPfQBs7Md3fbf` (17:19:26)
5. `dmxAlUsXyiY1IgWj0shJ` (17:24:34)
6. `APTDmvhmS9FLGMPd69q7` (17:29:15)
7. `NSP3x5kQS3G3iSwDI7nS` (17:34:24)
8. `NbDaG1ZCFCKG8lJWsnaB` (17:39:20)

Di [webhook_server.py:418-421](file:///Users/apple/Downloads/ramadhan/ecosystem/openturath_subscription/webhook_server.py#L418-L421):
```python
if current_expiry_dt > base_date:
    # User masih aktif, perpanjang dari expiry yang ada
    expiry_date = current_expiry_dt + datetime.timedelta(days=30 * duration_months)
```
Karena tidak ada filter idempotensi (mengecek apakah ID order/transaksi sudah pernah diproses), setiap putaran 5 menit menambahkan +30 hari di atas tanggal expiry sebelumnya. Ini menyebabkan tanggal expiry Nadia melompat eksponensial hingga **31 Maret 2028**!

#### B. Kecacatan 2: Kepercayaan Buta Reaper pada Field User yang Korup
Di [autonomous_reaper.py:426-430](file:///Users/apple/Downloads/ramadhan/ecosystem/openturath_subscription/autonomous_reaper.py#L426-L430):
```python
u_sub_exp = parse_dt(d.get("subscription_expiry"))
if u_sub_exp and u_sub_exp > now:
    for k in active_by_module:
        active_by_module[k].add(email)
```
Reaper membaca dokumen `users/ndsfraaaaaaa@gmail.com`, melihat angka tahun 2028, dan langsung memasukkan Nadia ke dalam `active_by_module` untuk SEMUA modul turats. Lalu pada evaluasi pencabutan:
```python
strictly_expired = (current_viewers & expired_for_this_nb) - active_for_this_nb
```
Nadia otomatis dicoret dari target pencabutan karena tercatat "aktif" hingga 2028.

#### C. Kecacatan 3: Mismatch Notebook ID di Konfigurasi Reaper
Daftar `MASTER_NOTEBOOKS` di `autonomous_reaper.py` (baris 92) dan `.env` hanya memuat:
- Notebook Legacy Fikih Syafi'i: `334e7b83-0e76-4787-a1d6-314642a35862`

Padahal **Master Notebook Fikih Syafi'i yang aktif digunakan aplikasi dan user** adalah:
- **`01 - FIKIH SYAFII (MASTER)`**: `c89d09ca-4b48-4000-a98d-59e532607fb6`

Reaper **sama sekali tidak pernah memindai atau membersihkan** `c89d09ca-4b48-4000-a98d-59e532607fb6`! Akibatnya, ada 5 user lain yang sudah expired sejak awal September masih tersisa sebagai viewer di notebook master tersebut.

#### D. Kecacatan 4: Kebocoran Akses Antar-Notebook (Cross-Module Bleed)
Nadia hanya membeli/diberi akses 1 bulan untuk Fikih Syafi'i. Namun di Google NotebookLM, email Nadia terdaftar sebagai VIEWER di **4 notebook sekaligus**:
1. `01 - FIKIH SYAFII (MASTER)` (`c89d09ca-4b48-4000-a98d-59e532607fb6`)
2. `SUPER AI FOR FIKIH SYAFI'I` (`334e7b83-0e76-4787-a1d6-314642a35862`)
3. `Al-MUHAQQIQ (Tahawwulat)` (`dc7ee7e4-f4ad-4db6-9cd0-0013727abbe4`)
4. `AL-BAYAN (Tahawwulat)` (`483d0291-0a70-411c-bff0-f1ea4b83b2fd`)

Ini terjadi karena skrip sinkronisasi lama menambahkan user ke bundle Fikih Tahawwulat padahal paket yang dibeli hanya Fikih Syafi'i.

---

## 🛡️ ATURAN BAKU SISTEM (SOP PERMANEN)

1. **VIP Adalah VIP Permanen (Zero-Touch Policy):**
   - Daftar di `STATIC_WHITELIST` pada `autonomous_reaper.py` adalah daftar kebal mutlak.
   - Jangan pernah menghapus `prilatief@gmail.com`, Masyayikh, atau tamu terverifikasi.
   
2. **Idempotensi Wajib dalam Webhook/Sync:**
   - Dilarang membuat transaksi baru atau memperpanjang `subscription_expiry` jika ID transaksi Akal/Order sudah pernah tercatat.
   - Jika `amount == 0.0` dan bukan transaksi bonus yang sah dari admin, dilarang memperpanjang tanggal expired secara otomatis.

3. **Master Notebook ID Harus Selalu Sinkron:**
   - Master Notebook Fikih Syafi'i WAJIB menyertakan `c89d09ca-4b48-4000-a98d-59e532607fb6`.

4. **Validasi Silang Transaksi vs Field User:**
   - Jika field `subscription_expiry` di dokumen user menunjukkan tanggal jauh di masa depan (> 1 tahun), tetapi riwayat transaksinya hanya paket 1 bulan (`tholib_1m` / `syafii_1m`), sistem wajib melakukan flag audit anomali dan tidak langsung menganggapnya aktif tanpa dasar transaksi berbayar yang sah.
