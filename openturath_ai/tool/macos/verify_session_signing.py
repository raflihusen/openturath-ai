"""Fail packaging when the macOS app cannot identify its persistent Keychain group."""
import datetime
import pathlib
import plistlib
import re
import subprocess
import sys

app = pathlib.Path(sys.argv[1])
subprocess.run(['codesign', '--verify', '--deep', '--strict', str(app)], check=True)
info = plistlib.loads((app / 'Contents/Info.plist').read_bytes())
signature = subprocess.run(['codesign', '-d', '--verbose=2', str(app)],
                           check=True, capture_output=True, text=True).stderr
team = re.search(r'^TeamIdentifier=(.+)$', signature, re.MULTILINE)
if not team or team.group(1) == 'not set' or 'Signature=adhoc' in signature:
    sys.exit('Session persistence requires a stable Apple signing identity; ad-hoc packaging is refused.')
result = subprocess.run(['codesign', '-d', '--entitlements', '-', str(app)],
                        check=True, capture_output=True)
entitlements = plistlib.loads(result.stdout)
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
