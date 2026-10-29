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

# Bidang dokumen app_config/version yang boleh ditulis skrip ini (Android).
# Bidang lain (mis. `platforms`) tidak disentuh.
ANDROID_VERSION_FIELDS = (
    'latest_version',
    'latest_version_code',
    'min_supported_version_code',
    'apk_url',
    'sha256',
    'release_notes',
    'updated_at',
)

def parse_args():
    parser = argparse.ArgumentParser(description='Otomasi Rilis & Broadcast Pembaruan OpenTurath AI')
    parser.add_argument('--build', action='store_true', help='Kompilasi release APK terlebih dahulu (flutter build apk --release)')
    parser.add_argument('--notes', type=str, default=None, help='Catatan rilis (Release Notes) yang akan tampil di pop-up dialog')
    parser.add_argument('--skip-deploy', action='store_true', help='Lewati langkah upload Firebase Hosting (hanya update local & firestore)')
    parser.add_argument('--edition', choices=('standard', 'guru'), default='standard',
                        help='Edisi APK. Guru disiarkan ke editions.guru dan tidak menyentuh rilis standar.')
    parser.add_argument('--apk', type=str, default=None, help='Jalur APK sumber (wajib untuk --edition guru)')
    parser.add_argument('--dry-run', action='store_true',
                        help='Hanya hitung dan tampilkan rencana siaran. Tidak menyalin, mengunggah, atau menulis apa pun.')
    parser.add_argument('--version-name', type=str, default=None, help='Nama versi (wajib untuk --edition guru; standar memakai pubspec)')
    parser.add_argument('--version-code', type=int, default=None, help='Kode build (wajib untuk --edition guru; standar memakai pubspec)')
    parser.add_argument('--skip-gate', action='store_true', help='Lewati analyzer/tes (hanya diizinkan bersama --dry-run)')
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


PUBLIC_BASE_URL = 'https://openturath.web.app'


def versioned_apk_name(edition, version_code):
    """Nama berkas berversi. Tidak pernah ditimpa, jadi aman di-cache CDN."""
    if edition == 'guru':
        return f'OpenTurath_Guru_v{version_code}.apk'
    return f'OpenTurath_v{version_code}.apk'


def versioned_apk_url(edition, version_code):
    return f'{PUBLIC_BASE_URL}/{versioned_apk_name(edition, version_code)}'


def build_firestore_payload(edition, version_name, version_code, apk_url, sha256_hash, release_notes, now_iso):
    """Mengembalikan (payload, daftar updateMask). Fungsi murni, mudah diuji.

    Standar: bidang datar Android (kontrak produksi). Guru: hanya editions.guru,
    sehingga rilis standar tidak tersentuh dan sebaliknya.
    """
    if edition == 'guru':
        guru = {
            "build": {"integerValue": str(version_code)},
            "version": {"stringValue": version_name},
            "url": {"stringValue": apk_url},
            "sha256": {"stringValue": sha256_hash},
            "notes": {"stringValue": release_notes},
            "updated_at": {"stringValue": now_iso},
        }
        payload = {"fields": {"editions": {"mapValue": {"fields": {"guru": {"mapValue": {"fields": guru}}}}}}}
        return payload, ["editions.guru"]
    payload = {
        "fields": {
            "latest_version": {"stringValue": version_name},
            "latest_version_code": {"integerValue": str(version_code)},
            "min_supported_version_code": {"integerValue": "40"},
            "apk_url": {"stringValue": apk_url},
            "sha256": {"stringValue": sha256_hash},
            "release_notes": {"stringValue": release_notes},
            "updated_at": {"stringValue": now_iso},
        }
    }
    return payload, list(ANDROID_VERSION_FIELDS)


def verify_live_file(url, expected_size, timeout=30):
    """HEAD ke URL langsung. Kembalikan (ok, pesan). Dipakai sebelum siaran."""
    req = urllib.request.Request(url, method='HEAD', headers={'User-Agent': 'openturath-publish'})
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            if resp.status != 200:
                return False, f'HTTP {resp.status}'
            ctype = (resp.headers.get('Content-Type') or '').lower()
            if 'text/html' in ctype:
                return False, 'server mengembalikan halaman HTML (kemungkinan 404)'
            length = resp.headers.get('Content-Length')
            if length and length.isdigit() and int(length) != expected_size:
                return False, f'ukuran di server {length} berbeda dari lokal {expected_size}'
            return True, 'OK'
    except Exception as e:  # noqa: BLE001
        return False, str(e)[:100]


def update_firestore_version(version_name, version_code, apk_url, sha256_hash, release_notes, edition='standard'):
    token = get_google_access_token()
    if not token:
        print("   [!] Peringatan: Tidak dapat mengambil token gcloud.")
        return False

    url = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents/app_config/version"
    now_iso = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    payload, mask = build_firestore_payload(edition, version_name, version_code, apk_url, sha256_hash, release_notes, now_iso)

    # updateMask: hanya bidang milik skrip ini yang ditulis. Tanpa mask,
    # PATCH Firestore MENGGANTI seluruh dokumen dan menghapus bidang lain,
    # termasuk `platforms.*` dan `editions.*` yang dikelola terpisah.
    url = url + "?" + "&".join(f"updateMask.fieldPaths={k}" for k in mask)

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
            print(f"   [OK] Firestore 'app_config/version' berhasil diperbarui (edisi {edition}, bidang milik edisi itu saja)!")
            return True
    except Exception as e:
        print(f"   [!] Gagal update Firestore via REST API: {e}")
        return False

def fail(msg):
    print(f"❌ {msg}")
    sys.exit(1)


def main():
    args = parse_args()
    guru = args.edition == 'guru'
    print("=" * 65)
    print("🚀 OTOMASI RILIS & BROADCAST PEMBARUAN OPENTURATH AI" + (" [DRY-RUN]" if args.dry_run else ""))
    print("=" * 65)

    if args.skip_gate and not args.dry_run:
        fail("--skip-gate hanya boleh bersama --dry-run.")
    if guru:
        if args.build:
            fail("--build tidak didukung untuk edisi Guru (butuh --dart-define=APP_EDITION=guru). Bangun manual, lalu beri --apk.")
        if not (args.apk and args.version_name and args.version_code):
            fail("Edisi Guru wajib memakai --apk, --version-name, dan --version-code (pubspec adalah versi edisi standar).")

    # 0. Gerbang kualitas: update tidak disiarkan bila analyzer atau tes gagal.
    if args.skip_gate:
        print("\n[0/5] Gerbang analyzer/tes dilewati (--skip-gate, dry-run).")
    else:
        print("\n[0/5] Menjalankan analyzer dan tes sebelum rilis...")
        for label, cmd in (
            ("flutter analyze", ['flutter', 'analyze', '--no-pub']),
            ("flutter test", ['flutter', 'test', '--no-pub']),
        ):
            if subprocess.run(cmd, cwd=FLUTTER_DIR).returncode != 0:
                fail(f"{label} gagal. Rilis dibatalkan; tidak ada yang diunggah atau disiarkan.")
        print("   [OK] Analyzer dan tes lulus.")

    # 1. Build APK jika flag --build diberikan
    if args.build:
        if args.dry_run:
            fail("--build tidak boleh bersama --dry-run.")
        print("\n[1/5] Mengompilasi APK rilis baru (flutter build apk --release)...")
        if subprocess.run(['flutter', 'build', 'apk', '--release'], cwd=FLUTTER_DIR).returncode != 0:
            fail("Kompilasi APK gagal!")
        print("   [OK] Kompilasi Gradle selesai 100%!")
    else:
        print("\n[1/5] Melewati kompilasi (menggunakan binary APK rilis yang sudah ada)...")

    # 2. Cek file APK sumber
    if args.apk:
        apk_source = args.apk
    else:
        apk_source = DEFAULT_APK_SOURCE if os.path.exists(DEFAULT_APK_SOURCE) else FALLBACK_APK_SOURCE
    if not os.path.exists(apk_source):
        fail(f"File APK sumber tidak ditemukan: {apk_source}. Jalankan dengan --build atau beri --apk.")
    apk_size = os.path.getsize(apk_source)
    print(f"   Sumber APK : {apk_source} ({apk_size / (1024 * 1024):.1f} MB)")

    # 3. Metadata versi & hash
    print("\n[2/5] Membaca metadata versi dan menghitung SHA-256...")
    if guru:
        version_name, version_code = args.version_name, args.version_code
    else:
        version_name, version_code = get_pubspec_version()
    sha256_hash = compute_sha256(apk_source)
    release_notes = args.notes or f"Pembaruan versi {version_name} ({version_code}): Peningkatan fitur keilmuan, stabilitas telaah, dan performa aplikasi."
    apk_live_url = versioned_apk_url(args.edition, version_code)
    now_iso = datetime.now(timezone.utc).isoformat()
    print(f"   Edisi           : {args.edition}")
    print(f"   Versi Aplikasi  : v{version_name} (Build Code: {version_code})")
    print(f"   SHA-256 Hash    : {sha256_hash}")
    print(f"   URL berversi    : {apk_live_url}")

    if args.dry_run:
        payload, mask = build_firestore_payload(args.edition, version_name, version_code, apk_live_url, sha256_hash, release_notes, now_iso)
        print("\n[DRY-RUN] Tidak ada berkas disalin, tidak ada unggahan, tidak ada tulis Firestore.")
        print(f"   updateMask : {', '.join(mask)}")
        print(json.dumps(payload, indent=2, ensure_ascii=False))
        return

    # 4. Salin ke folder public. Berkas berversi tidak pernah ditimpa;
    # `latest` hanya salinan untuk tautan lama dan unduhan manual.
    print("\n[3/5] Menyalin berkas APK ke folder distribusi web...")
    os.makedirs(PUBLIC_DIR, exist_ok=True)
    versioned_path = os.path.join(PUBLIC_DIR, versioned_apk_name(args.edition, version_code))
    subprocess.run(['cp', apk_source, versioned_path], check=True)
    if guru:
        print("   [OK] APK Guru berversi siap. Berkas edisi standar tidak disentuh.")
    else:
        subprocess.run(['cp', apk_source, TARGET_APK_PUBLIC], check=True)
        subprocess.run(['cp', apk_source, TARGET_APK_LEGACY], check=True)
        subprocess.run(['cp', apk_source, os.path.join(BASE_DIR, 'app-release-latest.apk')], check=True)
        manifest_data = {
            "version": version_name,
            "version_code": version_code,
            "sha256": sha256_hash,
            "apk_url": apk_live_url,
            "size_bytes": apk_size,
            "updated_at": now_iso,
            "release_notes": release_notes,
        }
        with open(MANIFEST_PUBLIC, 'w', encoding='utf-8') as f:
            json.dump(manifest_data, f, indent=2)
        print("   [OK] APK berversi, salinan latest, dan RELEASE_MANIFEST.json siap!")

    # 5. Deploy ke Firebase Hosting. Gagal berarti berhenti: menyiarkan URL
    # yang belum ada akan membuat semua perangkat gagal mengunduh.
    if not args.skip_deploy:
        print("\n[4/5] Mengunggah APK ke Firebase Hosting CDN...")
        deploy_cmd = ['npx', '-y', 'firebase-tools@latest', 'deploy', '--only', 'hosting:openturath', '--project', PROJECT_ID]
        if subprocess.run(deploy_cmd, cwd=FLUTTER_DIR).returncode != 0:
            fail("Upload Firebase Hosting gagal. Broadcast DIBATALKAN; Firestore tidak diubah.")
        print("   [OK] Deploy Hosting selesai.")
    else:
        print("\n[4/5] Melewati tahap upload Firebase Hosting (--skip-deploy).")

    print("   Memeriksa berkas langsung di server sebelum siaran...")
    ok, why = verify_live_file(apk_live_url, apk_size)
    if not ok:
        fail(f"Berkas live tidak lolos ({why}). Broadcast DIBATALKAN; Firestore tidak diubah.")
    print(f"   [OK] {apk_live_url} live dan ukurannya cocok.")

    # 6. Broadcast ke Firestore
    print("\n[5/5] Menyiarkan (broadcast) pembaruan ke perangkat pengguna via Firestore...")
    success = update_firestore_version(version_name, version_code, apk_live_url, sha256_hash, release_notes, edition=args.edition)

    print("\n" + "=" * 65)
    if success:
        print("🎉 PEMBARUAN BERHASIL DISIARKAN!")
        print(f"Edisi         : {args.edition}")
        print(f"Versi Terkini : v{version_name} (Code: {version_code})")
        print(f"URL Unduhan   : {apk_live_url}")
        print("Verifikasi    : python3 manage_ota.py verify-release --deep")
    else:
        print("⚠️ Pembaruan lokal selesai, namun broadcast Firestore perlu dicek.")
        sys.exit(1)
    print("=" * 65)


if __name__ == '__main__':
    main()
