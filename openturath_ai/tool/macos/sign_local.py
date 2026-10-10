"""Prepare an explicitly local macOS app without short-lived development profiles.

Does not notarize software or change Gatekeeper settings. Firebase owns its
macOS session fallback; no authentication data is copied by this tool.
"""
import pathlib
import subprocess
import sys

project = pathlib.Path(__file__).resolve().parents[2]
app = pathlib.Path(sys.argv[1]).resolve()
subprocess.run(['codesign', '--verify', '--deep', '--strict', str(app)], check=True)
profile = app / 'Contents/embedded.provisionprofile'
if profile.exists():
    profile.unlink()
magic = {b'\xfe\xed\xfa\xce', b'\xce\xfa\xed\xfe', b'\xfe\xed\xfa\xcf',
         b'\xcf\xfa\xed\xfe', b'\xca\xfe\xba\xbe', b'\xbe\xba\xfe\xca',
         b'\xca\xfe\xba\xbf', b'\xbf\xba\xfe\xca'}
native = []
for path in app.rglob('*'):
    if path.is_symlink() or not path.is_file():
        continue
    with path.open('rb') as handle:
        if handle.read(4) in magic:
            native.append(path)
for path in native:
    subprocess.run(['codesign', '--force', '--sign', '-', '--timestamp=none', str(path)],
                   check=True, capture_output=True)
frameworks = sorted((p for p in app.rglob('*.framework') if not p.is_symlink()),
                    key=lambda p: len(p.parts), reverse=True)
for framework in frameworks:
    subprocess.run(['codesign', '--force', '--sign', '-', '--timestamp=none', str(framework)],
                   check=True, capture_output=True)
subprocess.run(['codesign', '--force', '--sign', '-', '--timestamp=none',
                '--entitlements', str(project / 'macos/Runner/Release.entitlements'), str(app)],
               check=True)
subprocess.run([sys.executable, str(project / 'tool/macos/verify_session_signing.py'),
                str(app), '--allow-local-adhoc'], check=True)
print(f'Local package prepared: {len(native)} native binaries; no development profile expiry.')
