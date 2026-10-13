import os
import sys
import asyncio
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

db = firestore.Client.from_service_account_json("/Users/apple/Downloads/ramadhan/service-account.json")

TARGET_EMAIL = "muhammadalaydrus65@gmail.com"

print(f"=== CHECKING FIRESTORE FOR {TARGET_EMAIL} ===")

# Check users by doc ID
u_doc = db.collection("users").document(TARGET_EMAIL).get()
if u_doc.exists:
    print(f"users/{TARGET_EMAIL} exists =>", u_doc.to_dict())
else:
    print(f"users/{TARGET_EMAIL} does NOT exist directly.")

# Search across collections for this email
for col_name in ["users", "customers", "access_grants", "access_assignments", "access_memberships", "access_legacy_owners", "access_reviews", "sharing_log"]:
    try:
        docs = list(db.collection(col_name).stream())
        matched = []
        for d in docs:
            data = d.to_dict() or {}
            # check if email matches anywhere
            if any(isinstance(v, str) and TARGET_EMAIL in v.lower() for v in data.values()):
                matched.append((d.id, data))
        if matched:
            print(f"\n--- Matched in collection '{col_name}': {len(matched)} docs ---")
            for mid, mdata in matched:
                print(f"  {mid}: {mdata}")
    except Exception as e:
        print(f"Error checking {col_name}: {e}")

NOTEBOOKS = [
    {"name": "01 - FIKIH SYAFII (MASTER)", "id": "c89d09ca-4b48-4000-a98d-59e532607fb6"},
    {"name": "AI Fikih Syafi'i (Legacy)", "id": "334e7b83-0e76-4787-a1d6-314642a35862"},
    {"name": "Al-Muhaqqiq (Tahawwulat)", "id": "dc7ee7e4-f4ad-4db6-9cd0-0013727abbe4"},
    {"name": "Al-Bayan (Fikih Tahawwulat)", "id": "483d0291-0a70-411c-bff0-f1ea4b83b2fd"},
]

async def check_nlm():
    print("\n=== NOTEBOOKLM SHARING STATUS ===")
    storage_path = os.path.expanduser("~/.notebooklm/profiles/default/storage_state.json")
    async with NotebookLMClient.from_storage(path=storage_path) as nlm:
        for nb in NOTEBOOKS:
            status = await nlm.sharing.get_status(nb["id"])
            viewers = {u.email.lower() for u in status.shared_users}
            present = TARGET_EMAIL in viewers
            print(f"{nb['name']} ({nb['id']}): {'✅ ADA (TERDAFTAR)' if present else '❌ TIDAK ADA (KECABUT)'}")

asyncio.run(check_nlm())
