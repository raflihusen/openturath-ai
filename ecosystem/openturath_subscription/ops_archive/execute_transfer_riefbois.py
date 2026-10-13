"""
Script Eksekusi Transfer Akses Al-Muhaqqiq & Al-Bayan ke riefbois33@gmail.com
dan Pencabutan Akses AI Fikih Syafi'i (Expired) basithmuhammad612@gmail.com
=============================================================================
1. Cabut basithmuhammad612@gmail.com dari:
   - AI Fikih Syafi'i (334e7b83-0e76-4787-a1d6-314642a35862) [Expired 2026-09-22]
   - Al-Muhaqqiq (Tahawwulat) (dc7ee7e4-f4ad-4db6-9cd0-0013727abbe4) [Transfer]
   - Al-Bayan (Fikih Tahawwulat) (483d0291-0a70-411c-bff0-f1ea4b83b2fd) [Transfer]
2. Tambahkan riefbois33@gmail.com ke:
   - Al-Muhaqqiq (Tahawwulat) (dc7ee7e4-f4ad-4db6-9cd0-0013727abbe4) [Masa aktif s/d 2027-04-07]
   - Al-Bayan (Fikih Tahawwulat) (483d0291-0a70-411c-bff0-f1ea4b83b2fd) [Masa aktif s/d 2027-04-07]
3. Kunci keamanan (anti-copy requiredCopyRole=1 & chat-only) terjaga sesuai SOP.
4. Update status di Firestore (transactions, users, sharing_log).
"""

import os
import sys
import asyncio
from datetime import datetime, timezone
from pathlib import Path
from google.cloud import firestore

# Setup path untuk notebooklm-py
NOTEBOOKLM_PY_PATH = "/Users/apple/Downloads/ramadhan/archive_experiments/notebooklm-py/src"
sys.path.insert(0, NOTEBOOKLM_PY_PATH)

from notebooklm import NotebookLMClient
from notebooklm.rpc import RPCMethod
from notebooklm.rpc.types import SharePermission

CRED_PATH = "/Users/apple/Downloads/ramadhan/service-account.json"
STORAGE_PATH = "/Users/apple/Downloads/ramadhan/ecosystem/openturath_subscription/storage_state.json"

OLD_EMAIL = "basithmuhammad612@gmail.com"
NEW_EMAIL = "riefbois33@gmail.com"
EXPIRY_DATE = datetime(2027, 4, 7, 14, 23, 20, 619000, tzinfo=timezone.utc)

NB_FIKIH_SYAFII = {
    "name": "AI Fikih Syafi'i",
    "id": "334e7b83-0e76-4787-a1d6-314642a35862"
}
NB_MUHAQQIQ = {
    "name": "Al-Muhaqqiq (Tahawwulat)",
    "id": "dc7ee7e4-f4ad-4db6-9cd0-0013727abbe4"
}
NB_BAYAN = {
    "name": "Al-Bayan (Fikih Tahawwulat)",
    "id": "483d0291-0a70-411c-bff0-f1ea4b83b2fd"
}

async def secure_notebook_safeguards(client: NotebookLMClient, notebook_id: str, name: str):
    """Menjaga agar requiredCopyRole=1 (Owner only) dan Sy=1 (Chat only) tetap terkunci."""
    try:
        mut_copy = [None, None, None, [None, None, None, None, 1]]
        mut_chat = [None, None, None, None, None, None, None, None, [[1]]]
        params = [notebook_id, [mut_copy, mut_chat]]
        await client.sharing._rpc.rpc_call(RPCMethod.RENAME_NOTEBOOK, params, source_path=f"/notebook/{notebook_id}", allow_null=True)
        print(f"   🛡️ Safeguards terkunci untuk '{name}' (Copy Role=1, Chat Only=True)")
    except Exception as e:
        print(f"   ⚠️ Warning safeguarding '{name}': {e}")

async def run():
    now = datetime.now(timezone.utc)
    db = firestore.Client.from_service_account_json(CRED_PATH) if os.path.exists(CRED_PATH) else firestore.Client()

    print("=" * 80)
    print("STEP 1: EKSEKUSI PADA GOOGLE NOTEBOOKLM")
    print("=" * 80)

    async with NotebookLMClient.from_storage(path=STORAGE_PATH) as client:
        # A. Cabut AI Fikih Syafi'i dari basithmuhammad612@gmail.com
        print(f"\n[A] Menghapus {OLD_EMAIL} dari {NB_FIKIH_SYAFII['name']}...")
        await client.sharing.remove_user(NB_FIKIH_SYAFII["id"], OLD_EMAIL)
        print(f"   ✅ Berhasil mencabut {OLD_EMAIL} dari {NB_FIKIH_SYAFII['name']}")
        await secure_notebook_safeguards(client, NB_FIKIH_SYAFII["id"], NB_FIKIH_SYAFII["name"])

        # B. Transfer Al-Muhaqqiq: Hapus old, tambah new
        print(f"\n[B] Memproses {NB_MUHAQQIQ['name']}...")
        await client.sharing.remove_user(NB_MUHAQQIQ["id"], OLD_EMAIL)
        print(f"   ✅ Berhasil mencabut {OLD_EMAIL} dari {NB_MUHAQQIQ['name']}")
        await client.sharing.add_user(NB_MUHAQQIQ["id"], NEW_EMAIL, SharePermission.VIEWER, notify=False)
        print(f"   ✅ Berhasil menambahkan {NEW_EMAIL} ke {NB_MUHAQQIQ['name']}")
        await secure_notebook_safeguards(client, NB_MUHAQQIQ["id"], NB_MUHAQQIQ["name"])

        # C. Transfer Al-Bayan: Hapus old, tambah new
        print(f"\n[C] Memproses {NB_BAYAN['name']}...")
        await client.sharing.remove_user(NB_BAYAN["id"], OLD_EMAIL)
        print(f"   ✅ Berhasil mencabut {OLD_EMAIL} dari {NB_BAYAN['name']}")
        await client.sharing.add_user(NB_BAYAN["id"], NEW_EMAIL, SharePermission.VIEWER, notify=False)
        print(f"   ✅ Berhasil menambahkan {NEW_EMAIL} ke {NB_BAYAN['name']}")
        await secure_notebook_safeguards(client, NB_BAYAN["id"], NB_BAYAN["name"])

        # D. Verifikasi akhir status viewer
        print("\n[D] Verifikasi status akhir di Google NotebookLM:")
        for nb in [NB_FIKIH_SYAFII, NB_MUHAQQIQ, NB_BAYAN]:
            st = await client.sharing.get_status(nb["id"])
            viewers = {u.email.lower() for u in st.shared_users}
            print(f"   Notebook '{nb['name']}':")
            print(f"      - {OLD_EMAIL} ada: {OLD_EMAIL in viewers}")
            print(f"      - {NEW_EMAIL} ada: {NEW_EMAIL in viewers}")

    print("\n" + "=" * 80)
    print("STEP 2: UPDATE DATABASE FIRESTORE")
    print("=" * 80)

    # 1. Update transaksi Al-Muhaqqiq & Al-Bayan milik basith
    akl_tx_ref = db.collection("transactions").document("AKL-r2fvxfo-MMBR")
    akl_tx = akl_tx_ref.get()
    if akl_tx.exists:
        akl_tx_ref.update({
            "status": "TRANSFERRED",
            "transferred_to": NEW_EMAIL,
            "transferred_at": now,
            "note": f"Akses Al-Muhaqqiq dan Al-Bayan dipindahkan ke {NEW_EMAIL} atas instruksi pengguna"
        })
        print(f"✅ Transaksi AKL-r2fvxfo-MMBR diupdate: TRANSFERRED -> {NEW_EMAIL}")

    # 2. Update transaksi Fikih Syafi'i expired milik basith
    cmt_tx_ref = db.collection("transactions").document("cmt5eujlb0005ld044zoo6buu")
    cmt_tx = cmt_tx_ref.get()
    if cmt_tx.exists:
        cmt_tx_ref.update({
            "status": "EXPIRED",
            "revoked_at": now,
            "revocation_reason": "Paket 1 bulan habis per 2026-09-22 06:13:45 UTC, akses dicabut resmi"
        })
        print(f"✅ Transaksi cmt5eujlb0005ld044zoo6buu diupdate: EXPIRED")

    # 3. Buat transaksi baru untuk riefbois33@gmail.com
    transfer_doc_id = f"transfer_{NEW_EMAIL.replace('@', '_').replace('.', '_')}_bahits_1y"
    db.collection("transactions").document(transfer_doc_id).set({
        "customer_email": NEW_EMAIL,
        "customer_name": "Arie",
        "plan": "bahits_1y",
        "modules": ["fiqh_tahawwulat"],
        "notebooks": [NB_MUHAQQIQ["name"], NB_BAYAN["name"]],
        "amount": 0.0,
        "status": "success",
        "subscription_expires_at": EXPIRY_DATE,
        "created_at": now,
        "source": "transfer_from_basithmuhammad612",
        "original_transaction_id": "AKL-r2fvxfo-MMBR",
        "note": f"Transfer paket bahits_1y (Al-Muhaqqiq & Al-Bayan) dari {OLD_EMAIL}, masa aktif disamakan s/d {EXPIRY_DATE.strftime('%Y-%m-%d %H:%M:%S UTC')}"
    }, merge=True)
    print(f"✅ Transaksi transfer baru dibuat untuk {NEW_EMAIL}: doc {transfer_doc_id} (Exp: {EXPIRY_DATE})")

    # 4. Catat riwayat di sharing_log
    logs = [
        {"email": OLD_EMAIL, "notebook_id": NB_FIKIH_SYAFII["id"], "notebook_name": NB_FIKIH_SYAFII["name"], "action": "remove", "reason": "expired_subscription"},
        {"email": OLD_EMAIL, "notebook_id": NB_MUHAQQIQ["id"], "notebook_name": NB_MUHAQQIQ["name"], "action": "remove", "reason": "transferred_to_riefbois33"},
        {"email": OLD_EMAIL, "notebook_id": NB_BAYAN["id"], "notebook_name": NB_BAYAN["name"], "action": "remove", "reason": "transferred_to_riefbois33"},
        {"email": NEW_EMAIL, "notebook_id": NB_MUHAQQIQ["id"], "notebook_name": NB_MUHAQQIQ["name"], "action": "add", "reason": "transferred_from_basithmuhammad612"},
        {"email": NEW_EMAIL, "notebook_id": NB_BAYAN["id"], "notebook_name": NB_BAYAN["name"], "action": "add", "reason": "transferred_from_basithmuhammad612"},
    ]
    for log_item in logs:
        db.collection("sharing_log").add({
            **log_item,
            "status": "success",
            "created_at": now
        })
    print(f"✅ Dicatat {len(logs)} event di sharing_log Firestore")

    print("\n" + "=" * 80)
    print("SELESAI DENGAN SUKSES!")
    print("=" * 80)

if __name__ == "__main__":
    asyncio.run(run())
