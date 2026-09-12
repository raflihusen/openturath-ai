# Arsitektur Skalabilitas: NotebookLM Replica Pooling & Live Monitoring
**Batas Otoritatif:** Maksimal 1.950 Pengguna per Replika NotebookLM  
**Proyek:** OpenTurath AI  
**Lokasi Server:** Google Cloud Platform & Firebase (Firestore + Cloud Functions)

---

## 1. Konteks Masalah & Latar Belakang (Problem Statement)

### 1.1. Batasan Platform Google NotebookLM
Google NotebookLM saat ini merupakan fondasi penalaran dan pencarian semantik naskah turats di OpenTurath AI. Meskipun sangat andal dalam menganalisis hingga 250 sumber kitab per notebook, platform ini memiliki batasan arsitektural penting:
1. **Batas Berbagi Tautan (Sharing / Viewer Limit):** Satu notebook memiliki batas efektif sekitar 2.000 akun peninjau (*viewers*).
2. **Batas Konkurensi Pertanyaan (Query Concurrency):** Penggunaan intensif secara bersamaan oleh ribuan santri pada jam puncak (misal: ba'da Subuh atau malam Ramadhan) berpotensi memicu *rate-limiting* (`"Limits refresh every 5 hours"`).

### 1.2. Tantangan Skalabilitas 10.000+ Pengguna
Ketika OpenTurath AI mencapai 10.000 pengguna aktif:
- Menggunakan **satu tautan notebook tunggal** untuk setiap spesialis AI dipastikan akan mengalami kegagalan akses (*over-capacity*).
- Namun, **menduplikasi notebook secara terburu-buru saat ini belum tepat**, karena korpus rujukan dan metodologi pada modul-modul AI lainnya (Tafsir, Hadits, Nahwu, Ushul Fikih, dll.) masih dalam proses finalisasi kurasi data secara intensif.

### 1.3. Tujuan Dokumen Ini
Dokumen ini berfungsi sebagai **cetak biru arsitektur permanen (*definitive blueprint*)**. Dokumen ini merancang:
- Wadah dan pipa pengatur beban (*Load Balancer & Pooling Engine*) di server Google.
- Standar baku agar saat seluruh modul AI selesai difinalisasi, tim pengembang dapat langsung mengeksekusi duplikasi massal (5x–10x replika per spesialis) dengan sistem distribusi otomatis tanpa perlu mengubah atau mengompilasi ulang aplikasi Android (APK).

---

## 2. Prinsip Inti Arsitektur: *Waterfall Sticky Pooling*

```
[ Pengguna Menekan Buka Kajian di Aplikasi ]
                      │
                      ▼
        [ Cloud Function: getAgentUrl ]
                      │
                      ▼
          [ Cek Hak Akses / Langganan ] ──(Tidak Aktif)──▶ [ Tolak: Paywall / Voucher ]
                      │ (Aktif)
                      ▼
        [ Cek user.assigned_replicas[agentId] ]
         ├── Sudah Ada & Status Aktif ────▶ [ Kembalikan URL Replika Pengguna (Sticky) ]
         │
         └── Belum Ada / Replika Lama Nonaktif
                      │
                      ▼
           [ Transaksi Firestore: agent_pools/{agentId} ]
                      │
                      ▼
            Cari Replika Pertama dengan:
            status == 'active' & current_users < 1.950
                      ├── Ditemukan Replika X:
                      │     ├─ current_users += 1
                      │     ├─ Jika current_users == 1.950 ──▶ Tandai 'full' & Kirim Alert
                      │     ├─ Simpan ke user.assigned_replicas[agentId] = X
                      │     └─ Kembalikan URL Replika X
                      │
                      └── Seluruh Replika Penuh (Darurat):
                            ├─ Kirim Notifikasi Darurat ke Telegram Admin
                            └─ Alihkan ke Replika dengan Beban Terendah (Failover)
```

### A. Ambang Batas 1.950 Pengguna (*Safety Buffer*)
Meskipun batas teoretis Google adalah 2.000 akun, sistem menetapkan batas tegas di angka **1.950 pengguna**:
- **50 Slot Cadangan:** Digunakan sebagai penyangga (*buffer*) untuk akun pengelola (*super-admin*), penguji (*QA testers*), serta mencegah latensi sinkronisasi Google.
- Pengguna ke-1 hingga ke-1.950 masuk ke **Replika 01**.
- Pengguna ke-1.951 otomatis dialirkan (*spillover*) ke **Replika 02**, dan seterusnya.

### B. Keharusan *Sticky Affinity* (Konsistensi Riwayat Obrolan)
Di Google NotebookLM, riwayat chat pengguna disimpan oleh Google berdasarkan pasangan:
$$\text{Akun Google Pengguna} + \text{ID Notebook}$$

Jika sistem membagi pengguna secara acak (*round-robin* tiap klik), maka riwayat kajian pengguna kemarin tidak akan muncul di layar hari ini. Oleh karena itu, arsitektur ini menerapkan **Sticky Assignment**:
- Sekali seorang pengguna ditempatkan di `fiqh_syafii_01`, selamanya ia akan **selalu diarahkan ke `fiqh_syafii_01`**.
- Riwayat kajian, penelusuran ibarah, dan catatan pengguna di NotebookLM tetap utuh dan aman.

### C. *Zero APK Modification* (Kendali 100% di Server)
Aplikasi Android OpenTurath AI **tidak pernah menyimpan tautan notebook secara statis**. Aplikasi hanya meminta:
```dart
final url = await _agentService.getAgentUrl(agent.id);
```
Server Google Cloud Functions yang menentukan URL replika mana yang diberikan. Penambahan Replika 2, 3, 5, atau 10 di masa mendatang **murni dilakukan di database Google**, tanpa menuntut pengguna memperbarui aplikasi di Google Play Store.

---

## 3. Spesifikasi Skema Database (Google Cloud Firestore)

### 3.1. Koleksi Master: `agent_pools/{agentId}`
Dokumen ini mengatur kolam replika untuk setiap spesialis (misal: `fiqh_syafii`, `tafsir`, `hadits`, dll.).

```json
{
  "agent_id": "fiqh_syafii",
  "max_capacity_per_replica": 1950,
  "updated_at": "2026-09-12T21:55:00Z",
  "replicas": [
    {
      "replica_id": "fiqh_syafii_01",
      "url": "https://notebooklm.google.com/notebook/334e7b83-0e76-4787-a1d6-314642a35862",
      "current_users": 1820,
      "max_capacity": 1950,
      "status": "active",
      "owner_account": "admin-cluster1@openturath.id",
      "created_at": "2026-09-12T00:00:00Z",
      "updated_at": "2026-09-12T21:55:00Z"
    },
    {
      "replica_id": "fiqh_syafii_02",
      "url": "https://notebooklm.google.com/notebook/UUID_REPLIKA_02",
      "current_users": 340,
      "max_capacity": 1950,
      "status": "active",
      "owner_account": "admin-cluster2@openturath.id",
      "created_at": "2026-10-01T00:00:00Z",
      "updated_at": "2026-10-01T12:00:00Z"
    },
    {
      "replica_id": "fiqh_syafii_03",
      "url": "https://notebooklm.google.com/notebook/UUID_REPLIKA_03",
      "current_users": 0,
      "max_capacity": 1950,
      "status": "standby",
      "owner_account": "admin-cluster3@openturath.id",
      "created_at": "2026-10-01T00:00:00Z",
      "updated_at": "2026-10-01T12:00:00Z"
    }
  ]
}
```

### 3.2. Dokumen Pengguna: `users/{uid}`
Setiap dokumen pengguna memiliki peta penugasan replika:
```json
{
  "name": "Ahmad Santri",
  "email": "ahmad@example.com",
  "assigned_replicas": {
    "fiqh_syafii": "fiqh_syafii_01",
    "tafsir": "tafsir_01",
    "hadits": "hadits_02"
  }
}
```

---

## 4. Logika Server Backend (`functions/src/index.ts`)

### 4.1. Algoritma Alokasi Transaksional (`resolveUserReplicaUrl`)
```typescript
async function resolveUserReplicaUrl(
  uid: string,
  agentId: string,
  userData: FirebaseFirestore.DocumentData,
  defaultUrl: string
): Promise<string> {
  const assignedReplicas = userData.assigned_replicas || {};
  const existingReplicaId = assignedReplicas[agentId];

  const poolRef = db.collection("agent_pools").doc(agentId);
  const poolDoc = await poolRef.get();

  // 1. Graceful Fallback: Jika belum ada pool di Firestore, gunakan default URL
  if (!poolDoc.exists) {
    return defaultUrl;
  }

  const poolData = poolDoc.data()!;
  const replicas: NotebookReplica[] = poolData.replicas || [];

  // 2. Sticky Check: Jika pengguna sudah punya replika dan statusnya aktif/penuh
  if (existingReplicaId) {
    const matched = replicas.find(r => r.replica_id === existingReplicaId);
    if (matched && matched.status !== "disabled") {
      return matched.url;
    }
  }

  // 3. Alokasi Transaksional untuk Pengguna Baru / Replika Lama Disabled
  return await db.runTransaction(async (transaction) => {
    const freshPool = await transaction.get(poolRef);
    const freshReplicas: NotebookReplica[] = freshPool.data()?.replicas || [];

    // Cari replika aktif pertama yang kapasitasnya < 1950
    let target = freshReplicas.find(r => r.status === "active" && r.current_users < (r.max_capacity || 1950));

    if (target) {
      target.current_users += 1;
      if (target.current_users >= (target.max_capacity || 1950)) {
        target.status = "full";
        // Kirim notifikasi peringatan dini
        await sendTelegramNotification(
          `⚠️ <b>Kapasitas Penuh:</b> Replika <code>${target.replica_id}</code> (${agentId}) telah mencapai 1.950 pengguna. User baru berikutnya dialirkan ke replika selanjutnya.`
        );
      }
    } else {
      // Skenario Darurat: Semua replika penuh!
      await sendTelegramNotification(
        `🚨 <b>DARURAT:</b> Seluruh replika untuk <code>${agentId}</code> telah PENUH (1.950 user)! Mohon segera buat replika baru di NotebookLM.`
      );
      // Fallback ke replika terakhir yang aktif agar layanan tidak crash
      target = freshReplicas.filter(r => r.status !== "disabled").pop() || { url: defaultUrl } as any;
    }

    // Perbarui pool dan profil pengguna
    transaction.update(poolRef, { replicas: freshReplicas, updated_at: admin.firestore.FieldValue.serverTimestamp() });
    transaction.update(db.collection("users").doc(uid), {
      [`assigned_replicas.${agentId}`]: target.replica_id || "default",
    });

    return target.url;
  });
}
```

---

## 5. Sistem Pemantau & Peringatan Dini (Monitoring & Early Warning)

Sistem ini berjalan langsung di **Google Server resmi** proyek OpenTurath:

### 5.1. Alarm Peringatan Otomatis (Telegram Bot)
Server mengawasi persentase kapasitas notebook:
- **Kapasitas 85% (1.650 Pengguna):** Notifikasi *Advisory* agar admin mulai bersiap.
- **Kapasitas 95% (1.850 Pengguna):** Notifikasi *Urgent Warning* agar admin menduplikasi notebook di Google Drive dan menempelkan tautan baru.
- **Kapasitas 100% (1.950 Pengguna):** Status replika otomatis beralih ke `full`, sistem otomatis mengalirkan pendaftar baru ke replika berikutnya.

### 5.2. Skrip Operasional Python Developer (`tools/manage_notebook_pools.py`)
Skrip CLI untuk memantau dan mengelola pool langsung dari terminal pengembang:
```bash
# 1. Cek status kapasitas seluruh modul AI
python3 tools/manage_notebook_pools.py --status

# 2. Tambah tautan replika baru (misal: Fikih Syafi'i Replika 02)
python3 tools/manage_notebook_pools.py --add-replica \
  --agent fiqh_syafii \
  --replica-id fiqh_syafii_02 \
  --url "https://notebooklm.google.com/notebook/UUID_BARU" \
  --capacity 1950

# 3. Nonaktifkan replika jika terjadi kendala teknis (otomatis migrasi user)
python3 tools/manage_notebook_pools.py --disable-replica \
  --agent fiqh_syafii \
  --replica-id fiqh_syafii_01
```

---

## 6. Prosedur Operasional Pasca-Finalisasi AI (SOP)

Ketika seluruh AI (Fikih, Hadits, Tafsir, Nahwu, Ushul, dll.) selesai difinalisasi dan pengguna mulai mencapai ribuan, ikuti panduan praktis berikut:

1. **Buka Google Drive / NotebookLM**:
   - Pilih notebook AI yang ingin diduplikasi (misal: *AI Fikih Syafi'i Master*).
   - Klik **Make a Copy / Duplicate**. Seluruh 87 naskah kitab dan prompt metodologi muhaqqiq akan tersalin 100% identik dalam hitungan detik.
2. **Atur Hak Akses Berbagi**:
   - Klik tombol **Share** $\rightarrow$ pilih **Anyone with the link can view** (atau Chat).
   - Salin tautan publik notebook baru tersebut.
3. **Tempelkan Tautan ke Google Server**:
   - Jalankan skrip Python:
     ```bash
     python3 tools/manage_notebook_pools.py --add-replica --agent fiqh_syafii --url "<URL_BARU>"
     ```
   - Selesai! Server Google langsung mengenali replika tersebut. Pengguna ke-1.951 otomatis dialirkan ke notebook baru secara instan, tertib, dan tanpa *downtime*.

---
*Dokumen ini dirancang khusus untuk memandu skalabilitas OpenTurath AI hingga puluhan ribu penuntut ilmu secara mandiri, rapi, dan berkah.*
