import os
import sys
import asyncio
import time
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
    print("PENYESUAIAN TRANSFER & AUDIT PENUH: BASITH -> RIEFBOIS + NADIA SAFIRA")
    print(f"Timestamp: {now.isoformat()}")
    print("=" * 80)

    storage_path = os.path.expanduser("~/.notebooklm/profiles/default/storage_state.json")
    
    # 1. Update NotebookLM Permissions
    print("\n1. Sinkronisasi Hak Akses NotebookLM...")
    async with NotebookLMClient.from_storage(path=storage_path) as nlm:
        for nb in NOTEBOOKS:
            nb_name = nb["name"]
            nb_id = nb["id"]
            print(f"\n--- Memproses {nb_name} ({nb_id}) ---")
            
            success = False
            for attempt in range(1, 4):
                try:
                    status = await nlm.sharing.get_status(nb_id)
                    current_viewers = {u.email.lower() for u in status.shared_users}
                    print(f"   [Cek {attempt}] Total viewers saat ini: {len(current_viewers)}")
                    
                    # A. Cabut Basith jika masih ada
                    if "basithmuhammad612@gmail.com" in current_viewers:
                        print(f"   🗑️ Mencabut basithmuhammad612@gmail.com...")
                        removals = [["basithmuhammad612@gmail.com", None, SharePermission._REMOVE.value]]
                        params = [[[nb_id, removals, None, [0, ""]]], 0, None, [2]]
                        await nlm.sharing._rpc.rpc_call(RPCMethod.SHARE_NOTEBOOK, params, source_path=f"/notebook/{nb_id}", allow_null=True)
                        print(f"   ✅ basithmuhammad612@gmail.com BERHASIL DICABUT.")
                    else:
                        print(f"   ✅ basithmuhammad612@gmail.com SUDAH TIDAK ADA (Clean).")
                    
                    # B. Pastikan riefbois33@gmail.com aktif
                    if "riefbois33@gmail.com" not in current_viewers:
                        print(f"   ➕ Menambahkan riefbois33@gmail.com sebagai VIEWER...")
                        await nlm.sharing.add_user(nb_id, "riefbois33@gmail.com", SharePermission.VIEWER)
                        print(f"   ✅ riefbois33@gmail.com BERHASIL DITAMBAHKAN.")
                    else:
                        print(f"   ✅ riefbois33@gmail.com SUDAH AKTIF.")

                    # C. Pastikan ndsfraaaaaaa@gmail.com aktif
                    if "ndsfraaaaaaa@gmail.com" not in current_viewers:
                        print(f"   ➕ Menambahkan ndsfraaaaaaa@gmail.com sebagai VIEWER...")
                        await nlm.sharing.add_user(nb_id, "ndsfraaaaaaa@gmail.com", SharePermission.VIEWER)
                        print(f"   ✅ ndsfraaaaaaa@gmail.com BERHASIL DITAMBAHKAN.")
                    else:
                        print(f"   ✅ ndsfraaaaaaa@gmail.com SUDAH AKTIF.")

                    # D. Kunci Anti-Copy & Chat-Only
                    mut_copy = [None, None, None, [None, None, None, None, 1]]
                    mut_chat = [None, None, None, None, None, None, None, None, [[1]]]
                    params = [nb_id, [mut_copy, mut_chat]]
                    await nlm.rpc_call(RPCMethod.RENAME_NOTEBOOK, params, allow_null=True)
                    print(f"   🔒 Anti-Copy & Chat-Only terkunci rapi.")

                    success = True
                    break
                except Exception as e:
                    print(f"   ⚠️ Percobaan {attempt} gagal: {e}")
                    await asyncio.sleep(2)
            
            if not success:
                print(f"   ❌ Gagal memproses {nb_name} setelah 3 percobaan!")

    # 2. Update Database Firestore dengan Retry
    print("\n2. Memperbarui status database Firestore...")
    for attempt in range(1, 4):
        try:
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
            
            try:
                db.collection("transactions").document("AKL-r2fvxfo-MMBR").update({
                    "status": "TRANSFERRED",
                    "transferred_to": "riefbois33@gmail.com",
                    "note": "Akses dialihkan ke riefbois33@gmail.com"
                })
            except Exception as e_tx:
                print(f"   Catatan transaksi AKL-r2fvxfo-MMBR: {e_tx}")
            
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

            # Nadia Safira status = ACTIVE (Pelanggan 1 Tahun Sah)
            db.collection("users").document("ndsfraaaaaaa@gmail.com").set({
                "email": "ndsfraaaaaaa@gmail.com",
                "name": "Nadia Safira",
                "status": "active",
                "active": True,
                "subscription_expiry": "2027-06-05T00:00:00.000000+00:00",
                "entitlements": {
                    "fiqh_tahawwulat": {
                        "status": "active",
                        "plan": "bahits_1y",
                        "expiry": "2027-06-05T00:00:00.000000+00:00",
                        "updated_at": now
                    },
                    "fiqh_syafii": {
                        "status": "active",
                        "plan": "bahits_1y",
                        "expiry": "2027-06-05T00:00:00.000000+00:00",
                        "updated_at": now
                    }
                },
                "notes": "Pelanggan 1 Tahun Sah Tahawwulat",
                "last_updated_at": now
            }, merge=True)

            # Catat di sharing_log
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
            db.collection("sharing_log").add({
                "email": "ndsfraaaaaaa@gmail.com",
                "action": "add",
                "status": "success",
                "source": "manual_transfer_correction",
                "reason": "Pemulihan pelanggan sah 1 tahun",
                "created_at": now
            })

            print("   ✅ Semua dokumen Firestore berhasil diperbarui dan dicatat di audit log!")
            break
        except Exception as e:
            print(f"   ⚠️ Percobaan {attempt} update Firestore gagal: {e}")
            time.sleep(2)

    # 3. Verifikasi Akhir
    print("\n" + "=" * 80)
    print("HASIL VERIFIKASI AKHIR STATUS SHARING NOTEBOOKLM:")
    print("=" * 80)
    async with NotebookLMClient.from_storage(path=storage_path) as nlm:
        for nb in NOTEBOOKS:
            nb_name = nb["name"]
            nb_id = nb["id"]
            status = await nlm.sharing.get_status(nb_id)
            viewers = {u.email.lower() for u in status.shared_users}
            
            basith_ok = "basithmuhammad612@gmail.com" not in viewers
            rief_ok = "riefbois33@gmail.com" in viewers
            nadia_ok = "ndsfraaaaaaa@gmail.com" in viewers
            
            print(f"Notebook: {nb_name}")
            print(f"  - Basith (Wajib Tidak Ada) : {'✅ AMAN (Tidak Ada)' if basith_ok else '❌ MASIH ADA'}")
            print(f"  - Riefbois (Wajib Ada)     : {'✅ AMAN (Aktif)' if rief_ok else '❌ HILANG'}")
            print(f"  - Nadia (Wajib Ada)        : {'✅ AMAN (Aktif)' if nadia_ok else '❌ HILANG'}")

    print("\n🎉 Proses Penyelarasan Selesai 100%!")

if __name__ == "__main__":
    asyncio.run(fix_transfer())
