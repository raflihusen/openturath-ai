"""Fail packaging when the macOS app cannot identify its persistent Keychain group."""
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
print('Persistent session signing verified: stable team and own Keychain group.')
