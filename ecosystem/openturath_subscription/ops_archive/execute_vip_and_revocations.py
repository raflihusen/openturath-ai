import os
import sys
import asyncio
from datetime import datetime, timezone, timedelta
from google.cloud import firestore

# Load environment
env_file = os.path.join(os.path.dirname(__file__), ".env")
if os.path.exists(env_file):
    with open(env_file) as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                k, v = line.split("=", 1)
                if (v.startswith('"') and v.endswith('"')) or (v.startswith("'") and v.endswith("'")):
                    v = v[1:-1]
                os.environ[k] = v

NOTEBOOKLM_PY_PATH = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "notebooklm-py", "src"))
sys.path.insert(0, NOTEBOOKLM_PY_PATH)

from notebooklm import NotebookLMClient
from notebooklm.rpc.types import SharePermission, RPCMethod

cred_path = "/Users/apple/Downloads/ramadhan/service-account.json"
db = firestore.Client.from_service_account_json(cred_path) if os.path.exists(cred_path) else firestore.Client()
storage_path = os.path.expanduser("~/.notebooklm/profiles/default/storage_state.json")
now = datetime.now(timezone.utc)
far_future = now + timedelta(days=3650) # s/d 2036

SPECIAL_GUESTS = [
    {"email": "alkhateeb23@gmail.com", "name": "Al-Khateeb (Tamu Spesial)"},
    {"email": "omarasb1441@gmail.com", "name": "Omar Asb (Tamu Spesial)"},
    {"email": "prilatief@gmail.com", "name": "Pri Latief (Tamu Spesial)"},
]

REVOKE_TARGETS = [
    "fauzannurgisekolah@gmail.com",
    "rafiaqsal17@gmail.com",
    "rasyidgdx@gmail.com",
    "alghazalirozi2@gmail.com",
    "lamikfarza@gmail.com",
    "paisalkaff@gmail.com",
]

MASTER_NOTEBOOKS = [
    {"name": "AI Fikih Syafi'i", "id": "334e7b83-0e76-4787-a1d6-314642a35862", "key": "fiqh_syafii"},
    {"name": "Al-Muhaqqiq (Tahawwulat)", "id": "dc7ee7e4-f4ad-4db6-9cd0-0013727abbe4", "key": "fiqh_tahawwulat"},
    {"name": "Al-Bayan (Fikih Tahawwulat)", "id": "483d0291-0a70-411c-bff0-f1ea4b83b2fd", "key": "fiqh_tahawwulat"},
    {"name": "Al-Mukhtabir (Fikih Tahawwulat)", "id": "ac61a7a0-87e7-42a5-a30f-980ff74a78d8", "key": "fiqh_tahawwulat"},
    {"name": "Al-Habib (Fikih Tahawwulat)", "id": "6673e79a-7156-42e1-b116-bc1653a32094", "key": "fiqh_tahawwulat"},
    {"name": "Al-Khatib (Fikih Tahawwulat)", "id": "1288e413-9569-47a3-892f-64008e53c1e8", "key": "fiqh_tahawwulat"},
    {"name": "AI Bahasa Arab", "id": "15bc4cef-4b94-4241-b05a-d50a586bde06", "key": "nahwu"},
    {"name": "AI Hadits", "id": "b9626501-538c-4358-a44f-6731eaec50b6", "key": "hadits"},
    {"name": "AI Tafsir", "id": "df92cc50-1106-4221-8748-1663f00fa7fe", "key": "tafsir"},
    {"name": "AI Ushul Fiqih", "id": "6ab6dae8-0067-435a-85ca-b6bd4e17dd12", "key": "ushul_fiqh"},
]

async def run():
    print("=" * 80)
    print("STEP 1: DAFTARKAN TAMU SPESIAL SEBAGAI VIP_PERMANENT DI FIRESTORE")
    print("=" * 80)
    for guest in SPECIAL_GUESTS:
        em = guest["email"]
        nm = guest["name"]
        doc_id = f"vip_{em.replace('@', '_').replace('.', '_')}"
        db.collection("transactions").document(doc_id).set({
            "customer_email": em,
            "customer_name": nm,
            "plan": "VIP_PERMANENT",
            "status": "SUCCESS",
            "is_vip": True,
            "subscription_expires_at": far_future,
            "created_at": now,
            "source": "manual_special_guest_vip",
            "note": "Tamu spesial konfirmasi pengguna, dilindungi selamanya"
        }, merge=True)
        print(f"✅ Terdaftar VIP Permanen: {em} ({nm}) -> Doc: {doc_id}")

    print("\n" + "=" * 80)
    print("STEP 2: EKSEKUSI PENCABUTAN AKSES GOOGLE NOTEBOOKLM UNTUK 6 AKUN EXPIRED")
    print("=" * 80)
    revoke_set = set(REVOKE_TARGETS)
    revoked_actions = []

    async with NotebookLMClient.from_storage(path=storage_path) as client:
        for nb in MASTER_NOTEBOOKS:
            nb_id = nb["id"]
            nb_name = nb["name"]
            try:
                status = await client.sharing.get_status(nb_id)
                current_viewers = {u.email.lower() for u in status.shared_users if u.permission.name != "OWNER"}
                target_in_nb = current_viewers & revoke_set
                if target_in_nb:
                    print(f"🚨 Mencabut {len(target_in_nb)} user dari '{nb_name}'...")
                    removals = [[em, None, SharePermission._REMOVE.value] for em in target_in_nb]
                    params = [[[nb_id, removals, None, [0, ""]]], 0, None, [2]]
                    await client.sharing._rpc.rpc_call(
                        RPCMethod.SHARE_NOTEBOOK,
                        params,
                        source_path=f"/notebook/{nb_id}",
                        allow_null=True
                    )
                    for em in target_in_nb:
                        print(f"   ✂️ Dicabut: {em} dari {nb_name}")
                        revoked_actions.append({"email": em, "notebook": nb_name, "id": nb_id})
                        # Log to sharing_log
                        db.collection("sharing_log").add({
                            "email": em,
                            "notebook_id": nb_id,
                            "notebook_name": nb_name,
                            "action": "remove",
                            "status": "success",
                            "reason": "subscription_expired_revocation",
                            "created_at": now
                        })
                else:
                    print(f"ℹ️ '{nb_name}': Tidak ada target expired yang terdaftar.")
            except Exception as e:
                print(f"❌ Error pada '{nb_name}': {e}")

    print("\n" + "=" * 80)
    print("STEP 3: UPDATE STATUS FIRESTORE UNTUK 6 USER EXPIRED")
    print("=" * 80)
    for em in REVOKE_TARGETS:
        # Update transactions
        tx_query = db.collection("transactions").where(filter=firestore.FieldFilter("email", "==", em)).stream()
        for t in tx_query:
            t.reference.update({"status": "EXPIRED", "revoked_at": now})
        tx_query2 = db.collection("transactions").where(filter=firestore.FieldFilter("customer_email", "==", em)).stream()
        for t in tx_query2:
            t.reference.update({"status": "EXPIRED", "revoked_at": now})

        # Update users doc
        user_query = db.collection("users").where(filter=firestore.FieldFilter("email", "==", em)).stream()
        for u in user_query:
            u.reference.update({"status": "EXPIRED", "revoked_at": now})
        print(f"📝 Status Firestore diperbarui ke EXPIRED: {em}")

    print("\n" + "=" * 80)
    print(f"🎉 EKSEKUSI SELESAI: {len(SPECIAL_GUESTS)} VIP Dilindungi, {len(revoked_actions)} Akses Dicabut!")
    print("=" * 80)

if __name__ == "__main__":
    asyncio.run(run())
