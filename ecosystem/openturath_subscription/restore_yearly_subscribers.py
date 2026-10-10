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

# Daftar Notebook & Target Restorasi
TARGETS_TO_RESTORE = [
    {
        "nb_name": "01 - FIKIH SYAFII (MASTER)",
        "nb_id": "c89d09ca-4b48-4000-a98d-59e532607fb6",
        "emails": [
            "basithmuhammad612@gmail.com",
            "ndsfraaaaaaa@gmail.com",
            "riefbois33@gmail.com"
        ]
    },
    {
        "nb_name": "AI Fikih Syafi'i (Legacy)",
        "nb_id": "334e7b83-0e76-4787-a1d6-314642a35862",
        "emails": [
            "basithmuhammad612@gmail.com",
            "ndsfraaaaaaa@gmail.com",
            "riefbois33@gmail.com"
        ]
    },
    {
        "nb_name": "Al-Muhaqqiq (Tahawwulat)",
        "nb_id": "dc7ee7e4-f4ad-4db6-9cd0-0013727abbe4",
        "emails": [
            "basithmuhammad612@gmail.com",
            "ndsfraaaaaaa@gmail.com",
            "riefbois33@gmail.com"
        ]
    },
    {
        "nb_name": "Al-Bayan (Fikih Tahawwulat)",
        "nb_id": "483d0291-0a70-411c-bff0-f1ea4b83b2fd",
        "emails": [
            "basithmuhammad612@gmail.com",
            "ndsfraaaaaaa@gmail.com",
            "riefbois33@gmail.com"
        ]
    }
]

async def restore_access():
    now = datetime.now(timezone.utc)
    print("=" * 80)
    print(f"🚀 MEMULIHKAN AKSES USER 1 TAHUN YANG TERCABUT: {now.isoformat()}")
    print("=" * 80)

    storage_path = os.path.expanduser("~/.notebooklm/profiles/default/storage_state.json")
    
    async with NotebookLMClient.from_storage(path=storage_path) as nlm:
        for target in TARGETS_TO_RESTORE:
            nb_name = target["nb_name"]
            nb_id = target["nb_id"]
            emails = target["emails"]
            print(f"\n📂 Memproses Notebook: {nb_name} ({nb_id})")
            
            # Cek siapa yang sudah ada
            try:
                status = await nlm.sharing.get_status(nb_id)
                current_viewers = {u.email.lower() for u in status.shared_users}
            except Exception as e:
                print(f"   ⚠️ Gagal get_status {nb_name}: {e}")
                current_viewers = set()

            for email in emails:
                email_clean = email.strip().lower()
                if email_clean in current_viewers:
                    print(f"   ✅ User {email_clean} SUDAH ADA di {nb_name}.")
                    continue
                
                print(f"   ➕ Menambahkan {email_clean} sebagai VIEWER...")
                try:
                    await nlm.sharing.add_user(nb_id, email_clean, SharePermission.VIEWER)
                    print(f"   🎉 BERHASIL menambahkan {email_clean} ke {nb_name}!")
                    
                    # Catat log pemulihan di Firestore
                    db.collection("sharing_log").add({
                        "email": email_clean,
                        "notebook_id": nb_id,
                        "notebook_name": nb_name,
                        "action": "add",
                        "status": "success",
                        "source": "reaper_emergency_recovery_1y",
                        "reason": "Pemulihan akses langganan 1 tahun (Annual Subscriber Protection)",
                        "created_at": now
                    })
                except Exception as ex:
                    print(f"   ❌ Gagal menambahkan {email_clean} ke {nb_name}: {ex}")

            # Pastikan level view tetap CHAT_ONLY dan Anti-Bocor aktif
            try:
                if status.is_public:
                    await nlm.sharing.set_public(nb_id, False)
                await nlm.sharing.set_view_level(nb_id, ShareViewLevel.CHAT_ONLY)
                mut_copy = [None, None, None, [None, None, None, None, 1]]
                mut_chat = [None, None, None, None, None, None, None, None, [[1]]]
                params = [nb_id, [mut_copy, mut_chat]]
                await nlm.rpc_call(RPCMethod.RENAME_NOTEBOOK, params, allow_null=True)
                print(f"   🔒 Keamanan {nb_name} dikunci: Restricted, Chat-Only, Anti-Copy Role.")
            except Exception as lock_err:
                print(f"   ⚠️ Warning lock setting {nb_name}: {lock_err}")

    # Perbarui data profil user basithmuhammad612@gmail.com di Firestore agar konsisten aktif
    print("\n📝 Memperbarui profil database Firestore untuk basithmuhammad612@gmail.com...")
    u_ref = db.collection("users").document("basithmuhammad612@gmail.com")
    u_doc = u_ref.get()
    exp_2027 = "2027-04-07T14:23:20.619000+00:00"
    u_ref.set({
        "email": "basithmuhammad612@gmail.com",
        "name": "Muhammad Abdul Basith",
        "status": "active",
        "active": True,
        "subscription_expiry": exp_2027,
        "entitlements": {
            "all_access": {
                "status": "active",
                "plan": "bahits_1y",
                "expiry": exp_2027,
                "updated_at": now
            },
            "fiqh_syafii": {
                "status": "active",
                "plan": "bahits_1y",
                "expiry": exp_2027,
                "updated_at": now
            },
            "fiqh_tahawwulat": {
                "status": "active",
                "plan": "bahits_1y",
                "expiry": exp_2027,
                "updated_at": now
            }
        },
        "last_updated_at": now,
        "notes": "Pelanggan 1 Tahun Sah (Rp 1.999.000) - Dipulihkan dan diproteksi permanen"
    }, merge=True)
    print("✅ Profil Firestore basithmuhammad612@gmail.com berhasil diperbarui!")

    # Perbarui status riefbois33@gmail.com
    print("\n📝 Memperbarui profil database Firestore untuk riefbois33@gmail.com...")
    r_ref = db.collection("users").document("riefbois33@gmail.com")
    r_ref.set({
        "email": "riefbois33@gmail.com",
        "status": "active",
        "active": True,
        "subscription_expiry": exp_2027,
        "entitlements": {
            "all_access": {
                "status": "active",
                "plan": "bahits_1y",
                "expiry": exp_2027,
                "updated_at": now
            },
            "fiqh_syafii": {
                "status": "active",
                "plan": "bahits_1y",
                "expiry": exp_2027,
                "updated_at": now
            },
            "fiqh_tahawwulat": {
                "status": "active",
                "plan": "bahits_1y",
                "expiry": exp_2027,
                "updated_at": now
            }
        },
        "last_updated_at": now,
        "notes": "Pelanggan 1 Tahun Sah (bahits_1y) - Dipulihkan dan diproteksi permanen"
    }, merge=True)
    print("✅ Profil Firestore riefbois33@gmail.com berhasil diperbarui!")

    # Update transaksi basith agar statusnya SUCCESS di samping TRANSFERRED
    db.collection("transactions").document("AKL-r2fvxfo-MMBR").update({
        "status": "SUCCESS",
        "entitlement_key": "all_access",
        "recovered_at": now
    })
    print("✅ Transaksi AKL-r2fvxfo-MMBR diupdate status -> SUCCESS (all_access)!")

if __name__ == "__main__":
    asyncio.run(restore_access())
