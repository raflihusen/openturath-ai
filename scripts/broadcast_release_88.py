#!/usr/bin/env python3
"""
scripts/broadcast_release_88.py
================================
Menyiarkan (broadcast) rilis v1.0.87+88 untuk Android, macOS, dan Windows
ke Firestore app_config/version.
"""
import os
import sys
import json
import urllib.request
import subprocess
from datetime import datetime, timezone

PROJECT_ID = "open-turath"
FIRESTORE_URL = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents/app_config/version"

def get_google_access_token():
    try:
        token = subprocess.check_output(['gcloud', 'auth', 'print-access-token'], text=True).strip()
        if token:
            return token
    except Exception:
        pass
    return None

def patch_firestore(payload, mask, token):
    url = FIRESTORE_URL + "?" + "&".join(f"updateMask.fieldPaths={k}" for k in mask)
    req = urllib.request.Request(
        url,
        data=json.dumps(payload).encode('utf-8'),
        headers={
            "Authorization": f"Bearer {token}",
            "X-Goog-User-Project": PROJECT_ID,
            "Content-Type": "application/json"
        },
        method="PATCH"
    )
    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read().decode('utf-8'))

def broadcast_all(dry_run=False):
    token = get_google_access_token()
    if not token and not dry_run:
        print("❌ Tidak dapat mengambil token gcloud auth!")
        sys.exit(1)

    now_iso = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    notes = "Pembaruan versi 1.0.87 (88): Peningkatan fitur keilmuan, stabilitas telaah, pemecah masalah AI, dan performa aplikasi."

    # 1. Payload Android
    android_payload = {
        "fields": {
            "latest_version": {"stringValue": "1.0.87"},
            "latest_version_code": {"integerValue": "88"},
            "min_supported_version_code": {"integerValue": "40"},
            "apk_url": {"stringValue": "https://openturath.web.app/OpenTurath_v88.apk"},
            "sha256": {"stringValue": "858d5fb82ea61eb4d0c54c622e75ad6984a3739be746c13afe3025337ddda674"},
            "release_notes": {"stringValue": notes},
            "updated_at": {"stringValue": now_iso},
        }
    }
    android_mask = [
        "latest_version",
        "latest_version_code",
        "min_supported_version_code",
        "apk_url",
        "sha256",
        "release_notes",
        "updated_at",
    ]

    # 2. Payload Desktop Platforms (macOS & Windows)
    desktop_payload = {
        "fields": {
            "platforms": {
                "mapValue": {
                    "fields": {
                        "macos": {
                            "mapValue": {
                                "fields": {
                                    "build": {"integerValue": "88"},
                                    "version": {"stringValue": "1.0.87"},
                                    "url": {"stringValue": "https://openturath.web.app/OpenTurath_AI_macOS.dmg"},
                                    "sha256": {"stringValue": "63c99ac778a7b4f85de042be8094962aa0a6b2d415cae74b28ac5bf68deeafea"},
                                    "notes": {"stringValue": notes},
                                }
                            }
                        },
                        "windows": {
                            "mapValue": {
                                "fields": {
                                    "build": {"integerValue": "88"},
                                    "version": {"stringValue": "1.0.87"},
                                    "url": {"stringValue": "https://openturath.web.app/OpenTurath_AI_Windows_Setup.exe"},
                                    "sha256": {"stringValue": "00826441e7829e9acae9778d99c97bb8a08d516cd4e23e0881988f0c5190478f"},
                                    "notes": {"stringValue": notes},
                                    "installer_protocol": {"integerValue": "1"}
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    desktop_mask = ["platforms.macos", "platforms.windows"]

    print("=== BROADCAST RILIS v1.0.87+88 ===")
    print(f"Target Dokumen : app_config/version")
    print(f"Android Mask   : {android_mask}")
    print(f"Desktop Mask   : {desktop_mask}")

    if dry_run:
        print("[DRY-RUN] Selesai tanpa menulis ke Firestore.")
        return True

    print("Mengirim siaran Android...")
    patch_firestore(android_payload, android_mask, token)
    print("   ✓ Siaran Android berhasil!")

    print("Mengirim siaran macOS & Windows...")
    patch_firestore(desktop_payload, desktop_mask, token)
    print("   ✓ Siaran macOS & Windows berhasil!")

    return True

if __name__ == "__main__":
    dry = "--dry-run" in sys.argv
    broadcast_all(dry_run=dry)
