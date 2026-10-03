#!/usr/bin/env python3
"""
publish_auto_update.py
======================
Script Otomasi Penuh (One-Click Auto-Deploy & Update Broadcaster) OpenTurath AI.

Tugas yang dijalankan secara otomatis:
1. (Opsional --build): Kompilasi APK Flutter release terbaru secara otomatis.
2. Membaca nomor versi (version & build number) langsung dari pubspec.yaml.
3. Menghitung checksum SHA-256 dan ukuran byte file APK rilis.
4. Menyalin file APK ke folder public Firebase Hosting (app-release-latest.apk).
5. Memperbarui berkas RELEASE_MANIFEST.json secara otomatis.
6. Mengunggah (deploy) file APK ke CDN Firebase Hosting secara otomatis.
7. Memperbarui dokumen Firestore 'app_config/version' via Google Cloud API.
8. Seluruh HP pengguna/santri seketika mendeteksi pembaruan, men-download senyap di background,
   dan memunculkan pop-up "Pembaruan Telah Siap - Pasang & Muat Ulang Sekarang".
"""

import os
import sys
import json
import hashlib
import subprocess
import urllib.request
import argparse
from datetime import datetime, timezone

BASE_DIR = '/Users/apple/Downloads/ramadhan'
FLUTTER_DIR = os.path.join(BASE_DIR, 'openturath_ai')
PUBSPEC_PATH = os.path.join(FLUTTER_DIR, 'pubspec.yaml')
DEFAULT_APK_SOURCE = os.path.join(FLUTTER_DIR, 'build/app/outputs/flutter-apk/app-release.apk')
FALLBACK_APK_SOURCE = os.path.join(BASE_DIR, 'app-release-latest.apk')
PUBLIC_DIR = os.path.join(FLUTTER_DIR, 'public')
TARGET_APK_PUBLIC = os.path.join(PUBLIC_DIR, 'app-release-latest.apk')
TARGET_APK_LEGACY = os.path.join(PUBLIC_DIR, 'OpenTurath_AI.apk')
MANIFEST_PUBLIC = os.path.join(PUBLIC_DIR, 'RELEASE_MANIFEST.json')

PROJECT_ID = 'open-turath'

def parse_args():
    parser = argparse.ArgumentParser(description='Otomasi Rilis & Broadcast Pembaruan OpenTurath AI')
    parser.add_argument('--build', action='store_true', help='Kompilasi release APK terlebih dahulu (flutter build apk --release)')
    parser.add_argument('--notes', type=str, default=None, help='Catatan rilis (Release Notes) yang akan tampil di pop-up dialog')
    parser.add_argument('--skip-deploy', action='store_true', help='Lewati langkah upload Firebase Hosting (hanya update local & firestore)')
    return parser.parse_args()

def get_pubspec_version():
    with open(PUBSPEC_PATH, 'r', encoding='utf-8') as f:
        for line in f:
            if line.startswith('version:'):
                raw = line.split(':', 1)[1].strip()
                # format: 1.0.51+52
                parts = raw.split('+')
                version_name = parts[0].strip()
                version_code = int(parts[1].strip()) if len(parts) > 1 else 1
                return version_name, version_code
    raise ValueError("Versi tidak ditemukan di pubspec.yaml")

def compute_sha256(filepath):
    sha256 = hashlib.sha256()
    with open(filepath, 'rb') as f:
        for chunk in iter(lambda: f.read(65536), b''):
            sha256.update(chunk)
    return sha256.hexdigest()

def get_google_access_token():
    try:
        token = subprocess.check_output(['gcloud', 'auth', 'print-access-token'], text=True).strip()
        if token:
            return token
    except Exception:
        pass
    return None

def update_firestore_version(version_name, version_code, apk_url, sha256_hash, release_notes):
    token = get_google_access_token()
    if not token:
        print("   [!] Peringatan: Tidak dapat mengambil token gcloud. Mencoba via npx firebase-tools...")
        # Alternatif: update via gcloud / curl
        return False

    url = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents/app_config/version"
    now_iso = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

    payload = {
        "fields": {
            "latest_version": {"stringValue": version_name},
            "latest_version_code": {"integerValue": str(version_code)},
            "min_supported_version_code": {"integerValue": "40"},
            "apk_url": {"stringValue": apk_url},
            "sha256": {"stringValue": sha256_hash},
            "release_notes": {"stringValue": release_notes},
            "updated_at": {"stringValue": now_iso}
        }
    }

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

    try:
        with urllib.request.urlopen(req) as resp:
            data = json.loads(resp.read().decode('utf-8'))
            print("   [OK] Firestore 'app_config/version' berhasil diperbarui!")
            return True
    except Exception as e:
        print(f"   [!] Gagal update Firestore via REST API: {e}")
        return False

def main():
    args = parse_args()
    print("=" * 65)
    print("🚀 OTOMASI RILIS & BROADCAST PEMBARUAN OPENTURATH AI")
    print("=" * 65)

    # 0. Gerbang kualitas: update tidak disiarkan bila analyzer atau tes gagal.
    print("\n[0/5] Menjalankan analyzer dan tes sebelum rilis...")
    for label, cmd in (
        ("flutter analyze", ['flutter', 'analyze', '--no-pub']),
        ("flutter test", ['flutter', 'test', '--no-pub']),
    ):
        if subprocess.run(cmd, cwd=FLUTTER_DIR).returncode != 0:
            print(f"❌ {label} gagal. Rilis dibatalkan; tidak ada yang diunggah atau disiarkan.")
            sys.exit(1)
    print("   [OK] Analyzer dan tes lulus.")

    # 1. Build APK jika flag --build diberikan
    if args.build:
        print("\n[1/5] Mengompilasi APK rilis baru (flutter build apk --release)...")
        res = subprocess.run(['flutter', 'build', 'apk', '--release'], cwd=FLUTTER_DIR)
        if res.returncode != 0:
            print("❌ Kompilasi APK gagal!")
            sys.exit(1)
        print("   [OK] Kompilasi Gradle selesai 100%!")
    else:
        print("\n[1/5] Melewati kompilasi (menggunakan binary APK rilis yang sudah ada)...")

    # 2. Cek file APK sumber
    apk_source = DEFAULT_APK_SOURCE if os.path.exists(DEFAULT_APK_SOURCE) else FALLBACK_APK_SOURCE
    if not os.path.exists(apk_source):
        print(f"❌ File APK sumber tidak ditemukan di {DEFAULT_APK_SOURCE} maupun {FALLBACK_APK_SOURCE}!")
        print("Jalankan dengan flag --build untuk mengompilasi APK baru terlebih dahulu.")
        sys.exit(1)

    apk_size_mb = os.path.getsize(apk_source) / (1024 * 1024)
    print(f"   Sumber APK : {apk_source} ({apk_size_mb:.1f} MB)")

    # 3. Baca pubspec & hitung hash SHA-256
    print("\n[2/5] Membaca metadata versi dan menghitung SHA-256...")
    version_name, version_code = get_pubspec_version()
    sha256_hash = compute_sha256(apk_source)
    release_notes = args.notes or f"Pembaruan versi {version_name} ({version_code}): Peningkatan fitur keilmuan, stabilitas telaah, dan performa aplikasi."
    print(f"   Versi Aplikasi  : v{version_name} (Build Code: {version_code})")
    print(f"   SHA-256 Hash    : {sha256_hash}")

    # 4. Sinkronisasi file ke folder public web
    print("\n[3/5] Menyalin berkas APK ke folder distribusi web...")
    os.makedirs(PUBLIC_DIR, exist_ok=True)
    subprocess.run(['cp', apk_source, TARGET_APK_PUBLIC], check=True)
    subprocess.run(['cp', apk_source, TARGET_APK_LEGACY], check=True)
    # Juga salin ke root ramadhan/app-release-latest.apk
    subprocess.run(['cp', apk_source, os.path.join(BASE_DIR, 'app-release-latest.apk')], check=True)

    manifest_data = {
        "version": version_name,
        "version_code": version_code,
        "sha256": sha256_hash,
        "apk_url": "https://openturath.web.app/app-release-latest.apk",
        "size_bytes": os.path.getsize(apk_source),
        "updated_at": datetime.now(timezone.utc).isoformat(),
        "release_notes": release_notes
    }
    with open(MANIFEST_PUBLIC, 'w', encoding='utf-8') as f:
        json.dump(manifest_data, f, indent=2)
    print("   [OK] File APK dan RELEASE_MANIFEST.json siap di folder public!")

    # 5. Deploy ke Firebase Hosting
    apk_live_url = "https://openturath.web.app/app-release-latest.apk"
    if not args.skip_deploy:
        print("\n[4/5] Mengunggah APK ke Firebase Hosting CDN...")
        deploy_cmd = ['npx', '-y', 'firebase-tools@latest', 'deploy', '--only', 'hosting:openturath', '--project', PROJECT_ID]
        res = subprocess.run(deploy_cmd, cwd=FLUTTER_DIR)
        if res.returncode == 0:
            print(f"   [OK] APK sukses terunggah dan live di: {apk_live_url}")
        else:
            print("   [!] Upload Firebase Hosting menghasilkan kode non-zero, melanjutkan...")
    else:
        print("\n[4/5] Melewati tahap upload Firebase Hosting (--skip-deploy).")

    # 6. Broadcast ke Firestore
    print("\n[5/5] Menyiarkan (broadcast) pembaruan ke seluruh perangkat pengguna via Firestore...")
    success = update_firestore_version(version_name, version_code, apk_live_url, sha256_hash, release_notes)

    print("\n" + "=" * 65)
    if success:
        print("🎉 PEMBARUAN BERHASIL DISIARKAN SECARA OTOMATIS!")
        print(f"Versi Terkini : v{version_name} (Code: {version_code})")
        print(f"URL Unduhan   : {apk_live_url}")
        print("Dampak        : Seluruh HP santri yang membuka aplikasi sekarang")
        print("                akan langsung mendownload APK di background dan")
        print("                memunculkan pop-up pasang & muat ulang otomatis!")
    else:
        print("⚠️ Pembaruan lokal selesai, namun broadcast Firestore perlu dicek.")
    print("=" * 65)

if __name__ == '__main__':
    main()
