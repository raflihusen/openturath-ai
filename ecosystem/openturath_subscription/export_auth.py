"""
OpenTurath Auth Exporter
========================
Mengekspor session cookies dari storage_state.json menjadi satu baris string JSON.
String ini digunakan sebagai environment variable `NOTEBOOKLM_AUTH_JSON` di cloud
sehingga server tidak memerlukan login interaktif atau akses file lokal untuk auth.
"""

import os
import sys
import json

def main():
    # Path default storage state notebooklm-py
    storage_path = os.path.expanduser("~/.notebooklm/profiles/default/storage_state.json")
    
    if not os.path.exists(storage_path):
        print(f"❌ File auth tidak ditemukan di: {storage_path}")
        print("Silakan jalankan login terlebih dahulu di folder notebooklm-py:")
        print("  .venv/bin/notebooklm login --browser-cookies arc")
        sys.exit(1)
        
    try:
        with open(storage_path, "r") as f:
            auth_data = json.load(f)
            
        # Ubah jadi string sebaris tanpa spasi
        auth_string = json.dumps(auth_data)
        
        # Tulis ke file .env lokal jika ada
        env_path = os.path.join(os.path.dirname(__file__), ".env")
        
        if os.path.exists(env_path):
            # Baca env saat ini
            with open(env_path, "r") as f:
                lines = f.readlines()
                
            # Filter baris NOTEBOOKLM_AUTH_JSON lama jika ada
            new_lines = [line for line in lines if not line.startswith("NOTEBOOKLM_AUTH_JSON=")]
            
            # Tambahkan yang baru
            new_lines.append(f"\nNOTEBOOKLM_AUTH_JSON='{auth_string}'\n")
            
            with open(env_path, "w") as f:
                f.writelines(new_lines)
                
            print("✅ Berhasil menambahkan NOTEBOOKLM_AUTH_JSON ke file `.env` Anda!")
        else:
            print("✅ Berhasil membaca auth JSON. Silakan salin string berikut ke Environment Variable Anda:")
            print("\n" + f"NOTEBOOKLM_AUTH_JSON='{auth_string}'" + "\n")
            
    except Exception as e:
        print(f"❌ Gagal mengekspor auth: {e}")

if __name__ == "__main__":
    main()
