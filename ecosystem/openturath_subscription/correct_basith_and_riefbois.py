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

NOTEBOOKS = [
    {"name": "01 - FIKIH SYAFII (MASTER)", "id": "c89d09ca-4b48-4000-a98d-59e532607fb6"},
    {"name": "AI Fikih Syafi'i (Legacy)", "id": "334e7b83-0e76-4787-a1d6-314642a35862"},
    {"name": "Al-Muhaqqiq (Tahawwulat)", "id": "dc7ee7e4-f4ad-4db6-9cd0-0013727abbe4"},
    {"name": "Al-Bayan (Fikih Tahawwulat)", "id": "483d0291-0a70-411c-bff0-f1ea4b83b2fd"},
]

async def fix_transfer():
    now = datetime.now(timezone.utc)
    print("=" * 80)
    print("PENYESUAIAN TRANSFER: BASITH TELAH DIPINDAHKAN KE RIEFBOIS")
    print(f"Timestamp: {now.isoformat()}")
    print("=" * 80)

    storage_path = os.path.expanduser("~/.notebooklm/profiles/default/storage_state.json")
    
    # 1. Cabut basithmuhammad612@gmail.com karena paketnya sudah dialihkan ke riefbois33@gmail.com
    print("\n1. Mencabut basithmuhammad612@gmail.com dari NotebookLM (Akses sah milik riefbois33)...")
    async with NotebookLMClient.from_storage(path=storage_path) as nlm:
        for nb in NOTEBOOKS:
            nb_name = nb["name"]
            nb_id = nb["id"]
            try:
                status = await nlm.sharing.get_status(nb_id)
                current_viewers = {u.email.lower() for u in status.shared_users}
                
                # Cabut Basith jika masih ada
                if "basithmuhammad612@gmail.com" in current_viewers:
                    print(f"   🗑️ Mencabut basithmuhammad612@gmail.com dari {nb_name}...")
                    removals = [["basithmuhammad612@gmail.com", None, SharePermission._REMOVE.value]]
                    params = [[[nb_id, removals, None, [0, ""]]], 0, None, [2]]
                    await nlm.sharing._rpc.rpc_call(RPCMethod.SHARE_NOTEBOOK, params, source_path=f"/notebook/{nb_id}", allow_null=True)
                    print(f"   ✅ basithmuhammad612@gmail.com BERHASIL DICABUT dari {nb_name}.")
                
                # Pastikan riefbois33@gmail.com tetap ada
                if "riefbois33@gmail.com" not in current_viewers:
                    print(f"   ➕ Menambahkan riefbois33@gmail.com ke {nb_name}...")
                    await nlm.sharing.add_user(nb_id, "riefbois33@gmail.com", SharePermission.VIEWER)
                    print(f"   ✅ riefbois33@gmail.com BERHASIL DITAMBAHKAN ke {nb_name}.")
                else:
                    print(f"   ✅ riefbois33@gmail.com SUDAH AKTIF di {nb_name}.")

                # Kunci setting anti-copy & chat-only
                mut_copy = [None, None, None, [None, None, None, None, 1]]
                mut_chat = [None, None, None, None, None, None, None, None, [[1]]]
                params = [nb_id, [mut_copy, mut_chat]]
                await nlm.rpc_call(RPCMethod.RENAME_NOTEBOOK, params, allow_null=True)

            except Exception as e:
                print(f"   ❌ Error di {nb_name}: {e}")

    # 2. Update Database Firestore
    print("\n2. Memperbarui status database...")
    # Basith status = TRANSFERRED
    db.collection("users").document("basithmuhammad612@gmail.com").set({
        "email": "basithmuhammad612@gmail.com",
        "name": "Muhammad Abdul Basith",
        "status": "TRANSFERRED",
        "active": False,
        "transferred_to": "riefbois33@gmail.com",
        "notes": "Langganan 1 Tahun dialihkan resmi ke riefbois33@gmail.com",
        "last_updated_at": now
    }, merge=True)
    
    db.collection("transactions").document("AKL-r2fvxfo-MMBR").update({
        "status": "TRANSFERRED",
        "transferred_to": "riefbois33@gmail.com",
        "note": "Akses dialihkan ke riefbois33@gmail.com"
    })
    print("   ✅ Dokumen user & transaksi basithmuhammad612@gmail.com diupdate ke TRANSFERRED.")

    # Riefbois status = ACTIVE (Pelanggan 1 Tahun Sah)
    db.collection("users").document("riefbois33@gmail.com").set({
        "email": "riefbois33@gmail.com",
        "name": "Arie (Riefbois)",
        "status": "active",
        "active": True,
        "subscription_expiry": "2027-04-07T14:23:20.619000+00:00",
        "entitlements": {
            "all_access": {
                "status": "active",
                "plan": "bahits_1y",
                "expiry": "2027-04-07T14:23:20.619000+00:00",
                "updated_at": now
            },
            "fiqh_tahawwulat": {
                "status": "active",
                "plan": "bahits_1y",
                "expiry": "2027-04-07T14:23:20.619000+00:00",
                "updated_at": now
            },
            "fiqh_syafii": {
                "status": "active",
                "plan": "bahits_1y",
                "expiry": "2027-04-07T14:23:20.619000+00:00",
                "updated_at": now
            }
        },
        "notes": "Pelanggan 1 Tahun Sah (Pengalihan dari basithmuhammad612)",
        "last_updated_at": now
    }, merge=True)
    print("   ✅ Dokumen user riefbois33@gmail.com diupdate ke ACTIVE 1 Tahun.")

    # 3. Catat di sharing_log
    db.collection("sharing_log").add({
        "email": "basithmuhammad612@gmail.com",
        "action": "remove",
        "status": "success",
        "source": "manual_transfer_correction",
        "reason": "Pengalihan resmi ke riefbois33@gmail.com",
        "created_at": now
    })
    db.collection("sharing_log").add({
        "email": "riefbois33@gmail.com",
        "action": "add",
        "status": "success",
        "source": "manual_transfer_correction",
        "reason": "Pemegang sah langganan 1 tahun transfer",
        "created_at": now
    })

    print("\n🎉 Penyesuaian Transfer Selesai dengan Sempurna!")

if __name__ == "__main__":
    asyncio.run(fix_transfer())
