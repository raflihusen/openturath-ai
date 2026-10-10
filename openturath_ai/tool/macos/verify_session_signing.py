"""Fail packaging when the macOS app cannot identify its persistent Keychain group."""
import argparse
import datetime
import pathlib
import plistlib
import re
import subprocess
import sys

parser = argparse.ArgumentParser()
parser.add_argument('app', type=pathlib.Path)
parser.add_argument('--allow-local-adhoc', action='store_true',
                    help='Permit a local package without expiring or restricted provisioning entitlements')
args = parser.parse_args()
app = args.app
subprocess.run(['codesign', '--verify', '--deep', '--strict', str(app)], check=True)
info = plistlib.loads((app / 'Contents/Info.plist').read_bytes())
signature = subprocess.run(['codesign', '-d', '--verbose=2', str(app)],
                           check=True, capture_output=True, text=True).stderr
result = subprocess.run(['codesign', '-d', '--entitlements', '-', '--xml', str(app)],
                        check=True, capture_output=True)
entitlements = plistlib.loads(result.stdout) if result.stdout.strip() else {}
if 'Signature=adhoc' in signature and args.allow_local_adhoc:
    if (app / 'Contents/embedded.provisionprofile').exists():
        sys.exit('Local ad-hoc app must not retain an expiring development profile.')
    restricted = ('keychain-access-groups', 'com.apple.application-identifier',
                  'application-identifier', 'com.apple.developer.team-identifier')
    if any(entitlements.get(key) for key in restricted):
        sys.exit('Local ad-hoc app claims restricted entitlements without Apple authorization.')
    project = pathlib.Path(__file__).resolve().parents[2]
    expected = re.search(r'^version:\s*(\S+)', (project / 'pubspec.yaml').read_text(), re.MULTILINE).group(1)
    version, build = expected.split('+')
    if info.get('CFBundleShortVersionString') != version or str(info.get('CFBundleVersion')) != build:
        sys.exit('Local package version does not match the current source version.')
    print('Local ad-hoc package verified: current version; no expiring profile or restricted entitlements.')
    print('Firebase SDK fallback owns persisted sessions; authenticated close/reopen still requires runtime verification.')
    sys.exit(0)
team = re.search(r'^TeamIdentifier=(.+)$', signature, re.MULTILINE)
if not team or team.group(1) == 'not set' or 'Signature=adhoc' in signature:
    sys.exit('Session persistence requires a stable Apple signing identity; ad-hoc packaging is refused.')
expected = team.group(1) + '.' + info['CFBundleIdentifier']
if expected not in entitlements.get('keychain-access-groups', []):
    sys.exit('The signed app is missing its own team-scoped Keychain access group.')

# Development signatures need a valid profile to authorize restricted Keychain
# entitlements. A successful codesign verification alone does not prove launch.
if 'Authority=Apple Development:' in signature:
    profile_path = app / 'Contents/embedded.provisionprofile'
    if not profile_path.is_file():
        sys.exit('Apple Development app has no embedded provisioning profile.')
    decoded = subprocess.run(['security', 'cms', '-D', '-i', str(profile_path)],
                             check=True, capture_output=True)
    profile = plistlib.loads(decoded.stdout)
    if team.group(1) not in profile.get('TeamIdentifier', []):
        sys.exit('Development profile does not belong to the signing team.')
    if profile['ExpirationDate'] <= datetime.datetime.now(datetime.timezone.utc).replace(tzinfo=None):
        sys.exit('Development profile has expired.')
    allowed_groups = profile.get('Entitlements', {}).get('keychain-access-groups', [])
    if not any(expected == group or (group.endswith('*') and expected.startswith(group[:-1]))
               for group in allowed_groups):
        sys.exit('Development profile does not authorize the app Keychain group.')
    print('Embedded development profile authorizes the app Keychain group.')

print('Persistent session signing verified: stable team and own Keychain group.')
