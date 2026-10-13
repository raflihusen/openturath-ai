"""
Script perbaikan khusus data Nadia Safira (ndsfraaaaaaa@gmail.com) di Firestore.
Mengembalikan tanggal ekspirasi ke tanggal sah (20 September 2026) dan
menandai transaksi ghost / phantom sebagai EXPIRED.

CATATAN: Akun VIP (Pri Latief, Masyayikh, dll.) TIDAK DISENTUH SAMA SEKALI.
"""
from google.cloud import firestore
from datetime import datetime, timezone

cred_path = "/Users/apple/Downloads/ramadhan/service-account.json"
db = firestore.Client.from_service_account_json(cred_path)

email = "ndsfraaaaaaa@gmail.com"
true_expiry_str = "2026-09-20T01:18:07.766362+00:00"
true_expiry_dt = datetime.fromisoformat(true_expiry_str)

print(f"1. Memperbaiki dokumen user {email}...")
user_ref = db.collection("users").document(email)
user_doc = user_ref.get()

if user_doc.exists:
    user_ref.update({
        "active": False,
        "subscription_expiry": true_expiry_str,
        "entitlements.fiqh_syafii.expiry": true_expiry_str,
        "entitlements.fiqh_syafii.plan": "syafii_1m",
        "entitlements.fiqh_tahawwulat.expiry": true_expiry_str,
        "entitlements.hadits.expiry": true_expiry_str,
        "entitlements.tafsir.expiry": true_expiry_str,
        "status": "EXPIRED",
        "last_corrected_at": datetime.now(timezone.utc).isoformat(),
        "correction_reason": "Audit koreksi ekspirasi manual 1 bulan sah (20 Sep 2026)"
    })
    print("   ✅ Dokumen user berhasil diperbarui ke status EXPIRED (20 Sep 2026).")
else:
    print("   ⚠️ Dokumen user tidak ditemukan.")

# 2. Perbaiki 8 transaksi hantu tanggal 23 September 2026
ghost_tx_ids = [
    "4PEniBmuqjJ1m7mAKst5",
    "APTDmvhmS9FLGMPd69q7",
    "Fh4BE4zOPfQBs7Md3fbf",
    "LekBiGnrLJCROsteuCiG",
    "NSP3x5kQS3G3iSwDI7nS",
    "NbDaG1ZCFCKG8lJWsnaB",
    "dmxAlUsXyiY1IgWj0shJ",
    "yzmZuDE4mRVScqeEupyW",
    "akal_ndsfraaaaaaa_gmail_com_tholib_1m"
]

print("\n2. Memperbarui transaksi ghost/phantom menjadi EXPIRED...")
for tx_id in ghost_tx_ids:
    doc_ref = db.collection("transactions").document(tx_id)
    d = doc_ref.get()
    if d.exists:
        doc_ref.update({
            "status": "EXPIRED",
            "revoked_at": datetime.now(timezone.utc),
            "correction_note": "Ghost duplicate sync corrected to EXPIRED"
        })
        print(f"   ✅ Transaksi {tx_id} diupdate -> EXPIRED")
    else:
        print(f"   ℹ️ Transaksi {tx_id} tidak ditemukan.")

print("\nSelesai! Data Nadia di Firestore sudah bersih dan terkonfirmasi EXPIRED.")
