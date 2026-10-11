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

# 1. Master Asli Fikih Tahawwulat (71 Sumber)
TAHAWWULAT_MASTERS_ASLI = [
    {
        "name": "06.1 - AL-MUHAQQIQ (MASTER)",
        "id": "67b65ed8-0d1e-4fb4-929c-4fcb735d3be3",
        "key": "fiqh_tahawwulat"
    },
    {
        "name": "06.2 - AL-BAYAN (MASTER)",
        "id": "75882649-638f-4729-97f8-19897d90b108",
        "key": "fiqh_tahawwulat"
    },
    {
        "name": "06.3 - AL-MUKHTABIR (MASTER)",
        "id": "ac803816-5541-4446-bc9d-b56326493555",
        "key": "fiqh_tahawwulat"
    },
    {
        "name": "06.4 - AL-HABIB (MASTER)",
        "id": "c8b8a754-991d-429d-8379-b0478abb6ceb",
        "key": "fiqh_tahawwulat"
    },
    {
        "name": "06.5 - AL-KHATIB (MASTER)",
        "id": "926f3633-53fc-4dbf-81da-0570f7a4d26b",
        "key": "fiqh_tahawwulat"
    }
]

# 2. Master Syafi'i & Disiplin Lainnya
ALL_MASTERS_TO_SECURE = [
    # Master Syafi'i
    {"name": "01 - FIKIH SYAFII (MASTER)", "id": "c89d09ca-4b48-4000-a98d-59e532607fb6"},
    {"name": "AI Fikih Syafi'i (Legacy)", "id": "334e7b83-0e76-4787-a1d6-314642a35862"},
    # Tahawwulat Master Asli
    {"name": "06.1 - AL-MUHAQQIQ (MASTER)", "id": "67b65ed8-0d1e-4fb4-929c-4fcb735d3be3"},
    {"name": "06.2 - AL-BAYAN (MASTER)", "id": "75882649-638f-4729-97f8-19897d90b108"},
    {"name": "06.3 - AL-MUKHTABIR (MASTER)", "id": "ac803816-5541-4446-bc9d-b56326493555"},
    {"name": "06.4 - AL-HABIB (MASTER)", "id": "c8b8a754-991d-429d-8379-b0478abb6ceb"},
    {"name": "06.5 - AL-KHATIB (MASTER)", "id": "926f3633-53fc-4dbf-81da-0570f7a4d26b"},
    # Tahawwulat Secondary / Legacy Pool
    {"name": "Al-MUHAQQIQ (Secondary)", "id": "dc7ee7e4-f4ad-4db6-9cd0-0013727abbe4"},
    {"name": "AL-BAYAN (Secondary)", "id": "483d0291-0a70-411c-bff0-f1ea4b83b2fd"},
    {"name": "ALMUKHTABIR (Legacy)", "id": "ac61a7a0-87e7-42a5-a30f-980ff74a78d8"},
    {"name": "ALHABIB (Legacy)", "id": "6673e79a-7156-42e1-b116-bc1653a32094"},
    {"name": "ALKHATIB (Legacy)", "id": "1288e413-9569-47a3-892f-64008e53c1e8"},
    # Disiplin Lainnya
    {"name": "AI Bahasa Arab", "id": "1ae6ae57-53f0-4ce2-a2be-c324e03abb83"},
    {"name": "AI Hadits Nabawi", "id": "9da436c8-f9b7-4e8b-a51f-d798a31892a7"},
    {"name": "AI Tafsir & Ulumul Quran", "id": "f15bd838-dac9-415b-bd40-fef3da1355d4"},
    {"name": "AI Ushul Fiqih", "id": "6009f2ee-6328-497d-b74e-4276834caa94"},
    {"name": "AI Qawaid Fiqhiyyah", "id": "35cc555e-3d6c-43fd-ae82-6a06cd107899"},
    {"name": "AI Aqidah & Ushuluddin", "id": "d4807af1-1c3b-4ffd-b9b8-a944b2f8c5bd"},
    {"name": "AI Bibliografi & Faharis", "id": "d35f7598-076a-4c91-8ccf-9dc1aa1b0e7d"},
    {"name": "AI Tajwid & Qiraat", "id": "0364032d-3cb9-4b4e-bf5c-b0bf72f134f6"}
]

# Subscribers sah Fikih Tahawwulat yang WAJIB ada di Master Asli
TAHAWWULAT_VALID_USERS = [
    "muhammadalaydrus65@gmail.com",
    "riefbois33@gmail.com",
    "ndsfraaaaaaa@gmail.com",
    "prilatief@gmail.com",
    "udinvoldigoad05@gmail.com",
    "alkhateeb23@gmail.com",
    "omarasb1441@gmail.com"
]

async def secure_and_restore():
    now = datetime.now(timezone.utc)
    print("=" * 80)
    print(f"🔒 PENGUNCIAN KEAMANAN MUTLAK & RESTORASI MASTER ASLI: {now.isoformat()}")
    print("=" * 80)

    storage_path = os.path.expanduser("~/.notebooklm/profiles/default/storage_state.json")
    
    async with NotebookLMClient.from_storage(path=storage_path) as nlm:
        # 1. Pastikan subscriber sah Tahawwulat ada di Master Asli 71 Sumber
        print("\n✨ 1. MEMASTIKAN SUBSCRIBER SAH DI MASTER ASLI TAHAWWULAT (71 SUMBER)...")
        for target_nb in TAHAWWULAT_MASTERS_ASLI:
            nb_name = target_nb["name"]
            nb_id = target_nb["id"]
            print(f"\n📂 Memeriksa Master Asli: {nb_name} ({nb_id})")
            
            try:
                st = await nlm.sharing.get_status(nb_id)
                current_viewers = {u.email.lower() for u in st.shared_users}
            except Exception as e:
                print(f"   ⚠️ Gagal get_status {nb_name}: {e}")
                current_viewers = set()

            for user_email in TAHAWWULAT_VALID_USERS:
                em = user_email.strip().lower()
                if em in current_viewers:
                    print(f"   ✅ {em} SUDAH TERDAFTAR di {nb_name}.")
                else:
                    print(f"   ➕ Menambahkan {em} ke {nb_name}...")
                    try:
                        await nlm.sharing.add_user(nb_id, em, SharePermission.VIEWER)
                        print(f"   🎉 BERHASIL menambahkan {em} ke {nb_name}!")
                        db.collection("sharing_log").add({
                            "email": em,
                            "notebook_id": nb_id,
                            "notebook_name": nb_name,
                            "action": "add",
                            "status": "success",
                            "source": "master_asli_restoration",
                            "reason": "Restorasi ke Master Asli 71 Sumber",
                            "created_at": now
                        })
                    except Exception as add_err:
                        print(f"   ❌ Gagal tambah {em} ke {nb_name}: {add_err}")

        # 2. Penguncian Keamanan Mutlak pada SELURUH Notebook:
        # Restricted (is_public=False), Chat Only, No Allow Copies (requiredCopyRole=1)
        print("\n🛡️ 2. MENGUNCI KEAMANAN MUTLAK SELURUH MASTER NOTEBOOKS...")
        for nb in ALL_MASTERS_TO_SECURE:
            nb_name = nb["name"]
            nb_id = nb["id"]
            print(f"🔒 Mengunci: {nb_name} ({nb_id})...")
            try:
                st = await nlm.sharing.get_status(nb_id)
                # A. Kunci ke RESTRICTED
                if st.is_public:
                    await nlm.sharing.set_public(nb_id, False)
                    print(f"   🔒 Public access dimatikan -> RESTRICTED.")
                
                # B. Kunci ke CHAT ONLY
                await nlm.sharing.set_view_level(nb_id, ShareViewLevel.CHAT_ONLY)
                
                # C. Kunci NO ALLOW COPIES (requiredCopyRole = 1 / Owner Only)
                mut_copy = [None, None, None, [None, None, None, None, 1]]
                mut_chat = [None, None, None, None, None, None, None, None, [[1]]]
                params = [nb_id, [mut_copy, mut_chat]]
                await nlm.rpc_call(RPCMethod.RENAME_NOTEBOOK, params, allow_null=True)
                print(f"   ✅ {nb_name} AMAN: Restricted, Chat-Only, No Allow Copies (Owner Only).")
            except Exception as e:
                print(f"   ❌ Gagal mengunci {nb_name}: {e}")

    print("\n🎉 SELURUH PENGUNCIAN KEAMANAN & RESTORASI SELESAI DENGAN SUKSES!")

if __name__ == "__main__":
    asyncio.run(secure_and_restore())
