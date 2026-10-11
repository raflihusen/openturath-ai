import os
import sys
import asyncio
from google.cloud import firestore
from google.cloud.firestore_v1.base_query import FieldFilter

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

print("=== SHARING LOG FOR muhammadalaydrus65@gmail.com ===")
logs = list(db.collection("sharing_log").where(filter=FieldFilter("email", "==", "muhammadalaydrus65@gmail.com")).stream())
for l in sorted(logs, key=lambda x: str(x.to_dict().get("created_at", ""))):
    data = l.to_dict()
    print(f"[{data.get('created_at')}] action: {data.get('action')}, status: {data.get('status')}, reason: {data.get('reason')}, source: {data.get('source')}")

print("\n=== USER DOCUMENTS IN FIRESTORE ===")
users = list(db.collection("users").where(filter=FieldFilter("email", "==", "muhammadalaydrus65@gmail.com")).stream())
for u in users:
    print(u.id, "=>", u.to_dict())

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
            viewers = {u.email.lower(): u.role.name for u in status.shared_users}
            present = "muhammadalaydrus65@gmail.com" in viewers
            role = viewers.get("muhammadalaydrus65@gmail.com", "NONE")
            print(f"{nb['name']}: {'ADA (' + role + ')' if present else 'TIDAK ADA'}")

asyncio.run(check_nlm())
