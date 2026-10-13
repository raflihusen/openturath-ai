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

TARGET_NOTEBOOKS = [
    {
        "name": "01 - FIKIH SYAFII (MASTER)",
        "id": "c89d09ca-4b48-4000-a98d-59e532607fb6",
        "key": "fiqh_syafii"
    },
    {
        "name": "AI Fikih Syafi'i (Legacy)",
        "id": "334e7b83-0e76-4787-a1d6-314642a35862",
        "key": "fiqh_syafii"
    },
    {
        "name": "Al-Muhaqqiq (Tahawwulat)",
        "id": "dc7ee7e4-f4ad-4db6-9cd0-0013727abbe4",
        "key": "fiqh_tahawwulat"
    },
    {
        "name": "Al-Bayan (Fikih Tahawwulat)",
        "id": "483d0291-0a70-411c-bff0-f1ea4b83b2fd",
        "key": "fiqh_tahawwulat"
    },
    {
        "name": "Al-Mukhtabir (Fikih Tahawwulat)",
        "id": "ac61a7a0-87e7-42a5-a30f-980ff74a78d8",
        "key": "fiqh_tahawwulat"
    },
    {
        "name": "Al-Habib (Fikih Tahawwulat)",
        "id": "6673e79a-7156-42e1-b116-bc1653a32094",
        "key": "fiqh_tahawwulat"
    },
    {
        "name": "Al-Khatib (Fikih Tahawwulat)",
        "id": "1288e413-9569-47a3-892f-64008e53c1e8",
        "key": "fiqh_tahawwulat"
    }
]

async def main():
    now = datetime.now(timezone.utc)
    print("=" * 80)
    print(f"🚀 PEMULIHAN AKSES MUHAMMAD ALAYDRUS: {TARGET_EMAIL}")
    print(f"📅 Masa Aktif Sah: {EXPIRY_ISO}")
    print("=" * 80)

    storage_path = os.path.expanduser("~/.notebooklm/profiles/default/storage_state.json")
    
    async with NotebookLMClient.from_storage(path=storage_path) as nlm:
        for nb in TARGET_NOTEBOOKS:
            nb_name = nb["name"]
            nb_id = nb["id"]
            print(f"\n📂 Memeriksa Notebook: {nb_name} ({nb_id})")
            
            try:
                status = await nlm.sharing.get_status(nb_id)
                current_viewers = {u.email.lower() for u in status.shared_users}
            except Exception as e:
                print(f"   ⚠️ Gagal get_status {nb_name}: {e}")
                current_viewers = set()

            if TARGET_EMAIL in current_viewers:
                print(f"   ✅ {TARGET_EMAIL} SUDAH TERDAFTAR sebagai Viewer di {nb_name}.")
            else:
                print(f"   ➕ Menambahkan {TARGET_EMAIL} sebagai VIEWER...")
                try:
                    await nlm.sharing.add_user(nb_id, TARGET_EMAIL, SharePermission.VIEWER)
                    print(f"   🎉 BERHASIL menambahkan {TARGET_EMAIL} ke {nb_name}!")
                    
                    # Log Firestore
                    db.collection("sharing_log").add({
                        "email": TARGET_EMAIL,
                        "notebook_id": nb_id,
                        "notebook_name": nb_name,
                        "action": "add",
                        "status": "success",
                        "source": "manual_alaydrus_recovery",
                        "reason": "Pemulihan akses sah Tholib 6M (Rp 2.995.000) aktif s/d 26 Agustus 2027",
                        "created_at": now
                    })
                except Exception as ex:
                    print(f"   ❌ Gagal menambahkan {TARGET_EMAIL} ke {nb_name}: {ex}")

            # Pastikan level view tetap CHAT_ONLY dan Anti-Bocor aktif
            try:
                if status.is_public:
                    await nlm.sharing.set_public(nb_id, False)
                await nlm.sharing.set_view_level(nb_id, ShareViewLevel.CHAT_ONLY)
                mut_copy = [None, None, None, [None, None, None, None, 1]]
                mut_chat = [None, None, None, None, None, None, None, None, [[1]]]
                params = [nb_id, [mut_copy, mut_chat]]
                await nlm.rpc_call(RPCMethod.RENAME_NOTEBOOK, params, allow_null=True)
                print(f"   🔒 Keamanan {nb_name} terkunci: Chat-Only & Anti-Copy Role.")
            except Exception as lock_err:
                print(f"   ⚠️ Warning lock setting {nb_name}: {lock_err}")

    # Perbarui data profil user di Firestore users collection
    print(f"\n📝 Memperbarui dokumen users/{TARGET_EMAIL} di Firestore...")
    u_ref = db.collection("users").document(TARGET_EMAIL)
    u_data = {
        "email": TARGET_EMAIL,
        "name": "Muhammad Alaydrus",
        "status": "active",
        "active": True,
        "role": "vip",
        "subscription_expiry": EXPIRY_ISO,
        "entitlements": {
            "all_access": {
                "status": "active",
                "plan": "tholib_6m",
                "expiry": EXPIRY_ISO,
                "updated_at": now
            },
            "fiqh_syafii": {
                "status": "active",
                "plan": "tholib_6m",
                "expiry": EXPIRY_ISO,
                "updated_at": now
            },
            "fiqh_tahawwulat": {
                "status": "active",
                "plan": "tholib_6m",
                "expiry": EXPIRY_ISO,
                "updated_at": now
            }
        },
        "last_updated_at": now,
        "notes": "Pelanggan Sah Tholib 6M Rp 2.995.000 (AKL-7g66d3p-MMBR) - Dipulihkan & Dilindungi s/d 26 Agustus 2027"
    }
    u_ref.set(u_data, merge=True)
    print(f"✅ Dokumen users/{TARGET_EMAIL} berhasil diperbarui!")

    # Perbarui dokumen legacy owner jika ada hold
    legacy_doc_id = "legacy_adadaf8b7f3ff409d161801c1585cd4b43574f68406cf132a8c7690938120f2f"
    print(f"\n📝 Memperbarui access_legacy_owners/{legacy_doc_id}...")
    try:
        leg_ref = db.collection("access_legacy_owners").document(legacy_doc_id)
        leg_ref.update({
            "access_revocation_hold": False,
            "legacy_revoke_only": False,
            "status": "active",
            "recovered_at": now
        })
        print(f"✅ Dokumen legacy owner diperbarui (hold dilepas)!")
    except Exception as e:
        print(f"⚠️ Catatan update legacy owner: {e}")

    print("\n🎉 SELURUH PROSES PEMULIHAN MUHAMMAD ALAYDRUS SELESAI DENGAN SUKSES!")

if __name__ == "__main__":
    asyncio.run(main())
