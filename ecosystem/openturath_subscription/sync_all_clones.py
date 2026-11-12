#!/usr/bin/env python3
"""
OpenTurath AI - Sync All Clones Orchestrator
===========================================
Wrapper dan alias cepat untuk mengeksekusi `batch_clone_all_masters.py`.
Memudahkan operator menjalankan sinkronisasi atau kloning batch ke-24 kajian master
ke akun Google khusus (TARGET_OWNER_EMAIL = macbookairm1ku@gmail.com).

Penggunaan Cepat:
-----------------
1. Kloning Penuh Semua 24 Kajian Master:
   python3 sync_all_clones.py

2. Cek Koneksi & Hitung Sumber (Dry-Run):
   python3 sync_all_clones.py --dry-run

3. Sinkronisasi Scope Tertentu (contoh: Fikih Syafi'i):
   python3 sync_all_clones.py --scope fiqh_syafii
"""

import sys
import os

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
if SCRIPT_DIR not in sys.path:
    sys.path.insert(0, SCRIPT_DIR)

from batch_clone_all_masters import main

if __name__ == "__main__":
    main()
