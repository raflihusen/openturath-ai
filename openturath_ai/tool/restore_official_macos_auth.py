"""Restore generated Pods altered by the retired Keychain patch.

Only SDK source files are touched; user preferences and credentials are never
read. A new pod installation already uses the official, unpatched sources.
"""
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import urllib.request

root = Path(__file__).resolve().parents[1]
sources = {
    "FirebaseAuth/FirebaseAuth/Sources/Swift/SystemService/AuthStoredUserManager.swift":
        "https://raw.githubusercontent.com/firebase/firebase-ios-sdk/11.15.0/FirebaseAuth/Sources/Swift/SystemService/AuthStoredUserManager.swift",
    "FirebaseAuth/FirebaseAuth/Sources/Swift/Storage/AuthKeychainServices.swift":
        "https://raw.githubusercontent.com/firebase/firebase-ios-sdk/11.15.0/FirebaseAuth/Sources/Swift/Storage/AuthKeychainServices.swift",
    "GoogleUtilities/GoogleUtilities/Environment/SecureStorage/GULKeychainStorage.m":
        "https://raw.githubusercontent.com/google/GoogleUtilities/8.1.3/GoogleUtilities/Environment/SecureStorage/GULKeychainStorage.m",
    "GoogleUtilities/GoogleUtilities/Environment/SecureStorage/GULKeychainUtils.m":
        "https://raw.githubusercontent.com/google/GoogleUtilities/8.1.3/GoogleUtilities/Environment/SecureStorage/GULKeychainUtils.m",
}
lock = (root / "macos/Podfile.lock").read_text()
if "FirebaseAuth (11.15.0)" not in lock or "GoogleUtilities/Environment (8.1.3)" not in lock:
    raise SystemExit("SDK versions differ from the audited versions; refusing restoration.")

prepared = {}
for relative, url in sources.items():
    with urllib.request.urlopen(url, timeout=25) as response:
        data = response.read()
    if len(data) < 1000 or b"Copyright" not in data[:400] or b"Google" not in data[:400]:
        raise SystemExit(f"Unexpected SDK source response for {relative}.")
    prepared[relative] = data

with tempfile.TemporaryDirectory(prefix="openturath-sdk-restore-") as folder:
    for relative, data in prepared.items():
        temporary = Path(folder) / Path(relative).name
        temporary.write_bytes(data)
        if temporary.suffix == ".swift":
            subprocess.run(["/usr/bin/xcrun", "swiftc", "-frontend", "-parse", str(temporary)], check=True)
    if "--apply" in sys.argv:
        backup = Path(tempfile.mkdtemp(prefix="openturath-sdk-before-restore-"))
        for relative, data in prepared.items():
            target = root / "macos/Pods" / relative
            if not target.is_file():
                raise SystemExit("Expected local Pod source missing; run pod install instead.")
        for relative, data in prepared.items():
            target = root / "macos/Pods" / relative
            saved = backup / relative
            saved.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(target, saved)
            target.chmod(0o644)
            target.write_bytes(data)
        print(json.dumps({"restored": len(prepared), "source_backup": str(backup)}))
    else:
        print("Validated official SDK source; pass --apply to restore local Pods.")
    for relative, data in prepared.items():
        print(json.dumps({"file": relative, "sha256": hashlib.sha256(data).hexdigest()}))
