import os
import sys
import asyncio
from datetime import datetime, timezone
from google.cloud import firestore

NOTEBOOKLM_PY_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "notebooklm-py", "src")
sys.path.insert(0, os.path.abspath(NOTEBOOKLM_PY_PATH))

import socket
_orig_getaddrinfo = socket.getaddrinfo
def _resilient_getaddrinfo(host, port, *args, **kwargs):
    h_str = host.decode("utf-8", "ignore") if isinstance(host, (bytes, bytearray)) else str(host)
    if h_str == "notebooklm.google.com":
        return _orig_getaddrinfo("142.250.74.78", port, *args, **kwargs)
    return _orig_getaddrinfo(host, port, *args, **kwargs)
socket.getaddrinfo = _resilient_getaddrinfo

from notebooklm import NotebookLMClient
from notebooklm.rpc.types import SharePermission, RPCMethod, ShareViewLevel

cred_path = "/Users/apple/Downloads/ramadhan/service-account.json"
db = firestore.Client.from_service_account_json(cred_path)

TARGET_EMAIL = "muhammadalaydrus65@gmail.com"
EXPIRY_ISO = "2027-08-26T23:59:59+00:00"

SYAFII_NOTEBOOKS = [
    {
        "name": "01 - FIKIH SYAFII (MASTER)",
        "id": "c89d09ca-4b48-4000-a98d-59e532607fb6"
    },
    {
        "name": "AI Fikih Syafi'i (Legacy)",
        "id": "334e7b83-0e76-4787-a1d6-314642a35862"
    }
]

TAHAWWULAT_NOTEBOOKS = [
    {
        "name": "Al-Muhaqqiq (Tahawwulat)",
        "id": "dc7ee7e4-f4ad-4db6-9cd0-0013727abbe4"
    },
    {
        "name": "Al-Bayan (Fikih Tahawwulat)",
        "id": "483d0291-0a70-411c-bff0-f1ea4b83b2fd"
    },
    {
        "name": "Al-Mukhtabir (Fikih Tahawwulat)",
        "id": "ac61a7a0-87e7-42a5-a30f-980ff74a78d8"
    },
    {
        "name": "Al-Habib (Fikih Tahawwulat)",
        "id": "6673e79a-7156-42e1-b116-bc1653a32094"
    },
    {
        "name": "Al-Khatib (Fikih Tahawwulat)",
        "id": "1288e413-9569-47a3-892f-64008e53c1e8"
    }
]

async def main():
    now = datetime.now(timezone.utc)
    print("=" * 80)
    print(f"🔧 KOREKSI GRANULARITAS HAK AKSES: {TARGET_EMAIL}")
    print(f"🎯 Aturan: HANYA Fikih Tahawwulat (Cabut dari Fikih Syafi'i)")
    print("=" * 80)

    storage_path = os.path.expanduser("~/.notebooklm/profiles/default/storage_state.json")
    
    async with NotebookLMClient.from_storage(path=storage_path) as nlm:
        # 1. Cabut dari Fikih Syafi'i
        print("\n🚫 1. MENCABUT DARI FIKIH SYAFII...")
        for nb in SYAFII_NOTEBOOKS:
            nb_name = nb["name"]
            nb_id = nb["id"]
            try:
                status = await nlm.sharing.get_status(nb_id)
                current_viewers = {u.email.lower() for u in status.shared_users}
                if TARGET_EMAIL in current_viewers:
                    print(f"   Cabut {TARGET_EMAIL} dari {nb_name}...")
                    await nlm.sharing.remove_user(nb_id, TARGET_EMAIL)
                    print(f"   ✅ BERHASIL dicabut dari {nb_name}!")
                    
                    db.collection("sharing_log").add({
                        "email": TARGET_EMAIL,
                        "notebook_id": nb_id,
                        "notebook_name": nb_name,
                        "action": "remove",
                        "status": "success",
                        "source": "granularity_correction",
                        "reason": "Koreksi hak akses: Pelanggan hanya membeli modul Fikih Tahawwulat",
                        "created_at": now
                    })
                else:
                    print(f"   ℹ️ {TARGET_EMAIL} sudah tidak ada di {nb_name}.")
            except Exception as e:
                print(f"   ❌ Gagal memproses {nb_name}: {e}")

        # 2. Verifikasi & Pastikan tetap ada di Tahawwulat
        print("\n✅ 2. MEMASTIKAN AKSES DI 5 NOTEBOOK FIKIH TAHAWWULAT...")
        for nb in TAHAWWULAT_NOTEBOOKS:
            nb_name = nb["name"]
            nb_id = nb["id"]
            try:
                status = await nlm.sharing.get_status(nb_id)
                current_viewers = {u.email.lower() for u in status.shared_users}
                if TARGET_EMAIL in current_viewers:
                    print(f"   ✅ {nb_name}: TERDAFTAR (OK)")
                else:
                    print(f"   ➕ Menambahkan ke {nb_name}...")
                    await nlm.sharing.add_user(nb_id, TARGET_EMAIL, SharePermission.VIEWER)
                    print(f"   ✅ {nb_name}: BERHASIL DITAMBAHKAN")
            except Exception as e:
                print(f"   ⚠️ Error cek {nb_name}: {e}")

    # 3. Update Firestore Transactions
    print("\n📝 3. MEMPERBARUI TRANSAKSI AKL-7g66d3p-MMBR...")
    try:
        db.collection("transactions").document("AKL-7g66d3p-MMBR").update({
            "entitlement_key": "fiqh_tahawwulat",
            "scope": "fiqh_tahawwulat",
            "updated_at": now
        })
        print("   ✅ Transaksi AKL-7g66d3p-MMBR diupdate: entitlement_key = fiqh_tahawwulat")
    except Exception as e:
        print(f"   ⚠️ Gagal update transaksi: {e}")

    # 4. Update Firestore Users
    print(f"\n📝 4. MEMPERBARUI DOKUMEN users/{TARGET_EMAIL}...")
    u_ref = db.collection("users").document(TARGET_EMAIL)
    u_ref.set({
        "email": TARGET_EMAIL,
        "name": "Muhammad Alaydrus",
        "status": "active",
        "active": True,
        "role": "subscriber",
        "subscription_expiry": EXPIRY_ISO,
        "entitlements": {
            "fiqh_tahawwulat": {
                "status": "active",
                "plan": "tholib_6m",
                "expiry": EXPIRY_ISO,
                "updated_at": now
            }
        },
        "last_updated_at": now,
        "notes": "Pelanggan Sah Fikih Tahawwulat Tholib 6M Rp 2.995.000 (AKL-7g66d3p-MMBR) - Aktif s/d 26 Agustus 2027"
    }, merge=False) # merge=False to completely eliminate all_access and fiqh_syafii
    print(f"   ✅ Dokumen users/{TARGET_EMAIL} diperbarui: HANYA fiqh_tahawwulat!")

    print("\n🎉 KOREKSI GRANULARITAS SELESAI DENGAN SEMPURNA!")

if __name__ == "__main__":
    asyncio.run(main())
