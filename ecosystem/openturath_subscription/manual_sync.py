"""
OpenTurath Manual Sync
=======================
Script untuk tes awal dan sync manual TANPA menunggu webhook.
Sangat berguna untuk:
  1. Test apakah add/remove viewer berfungsi
  2. Sync darurat jika webhook gagal
  3. Bulk-add email dari daftar lama

Cara pakai:
  # Test koneksi dulu
  python manual_sync.py test --notebook-id <ID>

  # Tambah 1 email
  python manual_sync.py add --email user@gmail.com --notebook-id <ID>

  # Hapus 1 email
  python manual_sync.py remove --email user@gmail.com --notebook-id <ID>

  # Lihat semua viewer saat ini
  python manual_sync.py list --notebook-id <ID>

  # Bulk add dari file (1 email per baris)
  python manual_sync.py bulk-add --file emails.txt --notebook-id <ID>
"""

import asyncio
import sys
import os
import argparse

# Pastikan kita bisa import notebooklm-py dari folder instalasi
NOTEBOOKLM_PY_PATH = os.path.join(os.path.dirname(__file__), "..", "notebooklm-py", "src")
sys.path.insert(0, os.path.abspath(NOTEBOOKLM_PY_PATH))

import notebooklm_manager as nlm


async def cmd_test(notebook_id: str):
    """Test koneksi ke NotebookLM."""
    print(f"🔍 Testing koneksi ke notebook: {notebook_id[:20]}...")
    result = await nlm.test_connection(notebook_id)
    if result["success"]:
        print(f"✅ Koneksi berhasil!")
        print(f"   is_public       : {result['is_public']}")
        print(f"   total viewers   : {result['total_shared_users']}")
        if result["shared_users"]:
            print(f"   viewers saat ini:")
            for email in result["shared_users"]:
                print(f"     - {email}")
    else:
        print(f"❌ Koneksi GAGAL: {result['error']}")
        print("\nPastikan sudah login dulu:")
        print("  cd ../notebooklm-py")
        print("  source .venv/bin/activate")
        print("  notebooklm login")


async def cmd_add(notebook_id: str, email: str, name: str = ""):
    """Tambah satu email sebagai viewer."""
    print(f"➕ Menambahkan {email} ke notebook...")
    result = await nlm.add_viewer(notebook_id, email, name)
    if result["success"]:
        print(f"✅ Berhasil! Total viewers sekarang: {result['total_shared_users']}")
    else:
        print(f"❌ Gagal: {result['error']}")


async def cmd_remove(notebook_id: str, email: str):
    """Hapus satu email dari viewer."""
    print(f"➖ Menghapus akses {email}...")
    result = await nlm.remove_viewer(notebook_id, email)
    if result["success"]:
        print(f"✅ Berhasil! Total viewers sekarang: {result['total_shared_users']}")
    else:
        print(f"❌ Gagal: {result['error']}")


async def cmd_list(notebook_id: str):
    """Tampilkan semua viewer saat ini."""
    print(f"📋 Daftar viewer notebook {notebook_id[:20]}...")
    try:
        viewers = await nlm.list_viewers(notebook_id)
        if not viewers:
            print("  (tidak ada viewer)")
        for v in viewers:
            print(f"  {v['email']:<40} [{v['permission']}]  {v['name']}")
        print(f"\nTotal: {len(viewers)} viewer")
    except Exception as e:
        print(f"❌ Gagal: {e}")


async def cmd_bulk_add(notebook_id: str, file_path: str):
    """Bulk-add email dari file teks (1 email per baris)."""
    try:
        with open(file_path) as f:
            emails = [line.strip() for line in f if line.strip() and "@" in line]
    except FileNotFoundError:
        print(f"❌ File tidak ditemukan: {file_path}")
        return

    print(f"📦 Akan menambahkan {len(emails)} email...")
    ok = 0
    fail = 0
    for i, email in enumerate(emails, 1):
        print(f"  [{i}/{len(emails)}] {email} ... ", end="", flush=True)
        result = await nlm.add_viewer(notebook_id, email)
        if result["success"]:
            print("✅")
            ok += 1
        else:
            print(f"❌ {result.get('error', '')}")
            fail += 1
        # Jeda antar request untuk menghindari rate limiting
        await asyncio.sleep(1.5)

    print(f"\n✅ Berhasil: {ok}  ❌ Gagal: {fail}")


def main():
    parser = argparse.ArgumentParser(
        description="OpenTurath NotebookLM Manual Sync Tool",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument(
        "command",
        choices=["test", "add", "remove", "list", "bulk-add"],
        help="Perintah yang akan dijalankan",
    )
    parser.add_argument("--notebook-id", "-n", help="ID Notebook NotebookLM")
    parser.add_argument("--email", "-e", help="Email yang akan ditambah/dihapus")
    parser.add_argument("--name", default="", help="Nama user (opsional, untuk add)")
    parser.add_argument("--file", "-f", help="File berisi daftar email (untuk bulk-add)")

    args = parser.parse_args()

    # Ambil notebook_id dari env jika tidak disediakan
    notebook_id = args.notebook_id or os.getenv("NOTEBOOK_ID", "")
    if not notebook_id and args.command != "test":
        print("❌ --notebook-id diperlukan (atau set env NOTEBOOK_ID)")
        sys.exit(1)

    if args.command == "test":
        if not notebook_id:
            print("❌ --notebook-id diperlukan untuk test")
            sys.exit(1)
        asyncio.run(cmd_test(notebook_id))

    elif args.command == "add":
        if not args.email:
            print("❌ --email diperlukan")
            sys.exit(1)
        asyncio.run(cmd_add(notebook_id, args.email, args.name))

    elif args.command == "remove":
        if not args.email:
            print("❌ --email diperlukan")
            sys.exit(1)
        asyncio.run(cmd_remove(notebook_id, args.email))

    elif args.command == "list":
        asyncio.run(cmd_list(notebook_id))

    elif args.command == "bulk-add":
        if not args.file:
            print("❌ --file diperlukan untuk bulk-add")
            sys.exit(1)
        asyncio.run(cmd_bulk_add(notebook_id, args.file))


if __name__ == "__main__":
    main()
