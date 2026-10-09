"""
Restore & Lock All Master Notebooks to Golden Standard:
1. is_public = True (Anyone with link can access)
2. view_level = CHAT_ONLY (guidebook_config = [True])
3. requiredCopyRole = 1 (Owner Only - Copy protected, RAG safe)
"""
import os
import sys
import asyncio
import socket
from datetime import datetime

# Resilient DNS
_orig_getaddrinfo = socket.getaddrinfo
def _resilient_getaddrinfo(host, port, *args, **kwargs):
    h_str = host.decode("utf-8", "ignore") if isinstance(host, (bytes, bytearray)) else str(host)
    if h_str == "notebooklm.google.com":
        return _orig_getaddrinfo("142.250.74.78", port, *args, **kwargs)
    return _orig_getaddrinfo(host, port, *args, **kwargs)
socket.getaddrinfo = _resilient_getaddrinfo

NOTEBOOKLM_PY_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "notebooklm-py", "src")
sys.path.insert(0, os.path.abspath(NOTEBOOKLM_PY_PATH))

from notebooklm import NotebookLMClient
from notebooklm.rpc.types import RPCMethod, ShareViewLevel
from autonomous_reaper import MASTER_NOTEBOOKS

async def main():
    storage = os.path.expanduser("~/.notebooklm/profiles/default/storage_state.json")
    print(f"Connecting with storage: {storage}")
    
    async with NotebookLMClient.from_storage(path=storage) as client:
        print(f"Total notebooks to restore: {len(MASTER_NOTEBOOKS)}")
        success_count = 0
        
        for item in MASTER_NOTEBOOKS:
            nb_id = item["id"]
            nb_name = item["name"]
            try:
                # 1. Pastikan link sharing aktif publik
                await client.sharing.set_public(nb_id, True)
                
                # 2. View level Chat Only
                await client.sharing.set_view_level(nb_id, ShareViewLevel.CHAT_ONLY)
                
                # 3. Kunci mutasi atomik: requiredCopyRole = 1 (Owner Only) + Sy = 1 (Chat Only)
                mut_copy = [None, None, None, [None, None, None, None, 1]]
                mut_chat = [None, None, None, None, None, None, None, None, [[1]]]
                params = [nb_id, [mut_copy, mut_chat]]
                await client.rpc_call(RPCMethod.RENAME_NOTEBOOK, params, allow_null=True)
                
                # 4. Validasi cepat
                status = await client.sharing.get_status(nb_id)
                res = await client.rpc_call(RPCMethod.GET_NOTEBOOK, [nb_id])
                meta = res[0][5]
                guidebook = res[0][8] if len(res[0]) > 8 else None
                
                is_pub = status.is_public
                copy_role = meta[18]
                chat_ok = (guidebook and guidebook[0] is True)
                
                print(f"✅ {nb_name:<30} [{nb_id[:8]}]: is_public={is_pub}, copyRole={copy_role}, chatOnly={chat_ok}")
                success_count += 1
            except Exception as e:
                print(f"❌ {nb_name:<30} [{nb_id[:8]}]: ERROR {e}")
                
        print(f"\nSelesai! {success_count}/{len(MASTER_NOTEBOOKS)} notebook berhasil dipulihkan.")

if __name__ == "__main__":
    asyncio.run(main())
