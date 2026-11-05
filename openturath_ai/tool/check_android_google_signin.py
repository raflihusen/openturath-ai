"""Check an APK's package/certificate against its source Google configuration.

Read-only packaging guard. It does not replace a live Google sign-in test or
verify the current configuration in Firebase/Google Cloud.
"""
import argparse
import json
import os
from pathlib import Path
import re
import shutil
import subprocess


def android_tool(name):
    available = shutil.which(name)
    if available:
        return available
    sdk = os.environ.get('ANDROID_HOME') or os.environ.get('ANDROID_SDK_ROOT')
    properties = Path(__file__).resolve().parents[1] / 'android/local.properties'
    if not sdk and properties.exists():
        sdk = next((line.split('=', 1)[1].strip() for line in properties.read_text().splitlines()
                    if line.startswith('sdk.dir=')), None)
    if sdk:
        folders = [p for p in (Path(sdk) / 'build-tools').glob('*') if p.is_dir() and '-' not in p.name]
        for folder in sorted(folders, key=lambda p: tuple(int(n) for n in p.name.split('.')), reverse=True):
            for suffix in ['', '.exe', '.bat']:
                candidate = folder / (name + suffix)
                if candidate.exists():
                    return str(candidate)
    return name


def validate(config, package, sha1):
    clients = [c for c in config.get('client', []) if
               c.get('client_info', {}).get('android_client_info', {}).get('package_name') == package]
    if not clients:
        return f'No Firebase Android client for package {package}'
    oauth = [o for c in clients for o in c.get('oauth_client', [])]
    if not any(o.get('client_type') == 3 for o in oauth):
        return 'Missing web OAuth client for Google sign-in'
    normalize = lambda value: value.replace(':', '').lower()
    if not any(o.get('client_type') == 1 and
               o.get('android_info', {}).get('package_name') == package and
               normalize(o.get('android_info', {}).get('certificate_hash', '')) == normalize(sha1)
               for o in oauth):
        return f'APK signing certificate is not configured for package {package}'
    return None


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--apk', required=True)
    parser.add_argument('--aapt', default=android_tool('aapt'))
    parser.add_argument('--apksigner', default=android_tool('apksigner'))
    parser.add_argument('--config', type=Path, default=Path(__file__).resolve().parents[1] / 'android/app/google-services.json')
    args = parser.parse_args()
    try:
        metadata = subprocess.check_output([args.aapt, 'dump', 'badging', args.apk], text=True)
        certificate = subprocess.check_output([args.apksigner, 'verify', '--print-certs', args.apk], text=True)
        package = re.search(r"^package: name='([^']+)'", metadata, re.M).group(1)
        sha1 = re.search(r'certificate SHA-1 digest: ([a-fA-F0-9:]+)', certificate).group(1)
        issue = validate(json.loads(args.config.read_text()), package, sha1)
        if issue:
            parser.exit(1, issue + '\n')
        print(f'PASS: Google OAuth package and APK signing certificate match ({package}).')
    except (OSError, ValueError, AttributeError, subprocess.CalledProcessError) as error:
        parser.exit(1, f'Could not verify APK Google sign-in configuration: {type(error).__name__}\n')


if __name__ == '__main__':
    main()
