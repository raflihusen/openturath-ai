"""Exercise the installed Firebase SDK's macOS fallback across fresh processes.

Uses disposable synthetic data only. Does not read real authentication sessions.
This verifies SDK storage, not real account sign-in or authorization.
"""
import pathlib
import subprocess
import tempfile
import uuid

project = pathlib.Path(__file__).resolve().parents[2]
sdk = project / 'macos/Pods/FirebaseAuth/FirebaseAuth/Sources/Swift/Storage/AuthUserDefaults.swift'
service = 'openturath_fallback_probe_' + uuid.uuid4().hex
with tempfile.TemporaryDirectory(prefix='openturath-firebase-fallback-') as folder:
    root = pathlib.Path(folder)
    source = root / 'main.swift'
    source.write_text('''import Foundation
import Security
let service = CommandLine.arguments[1]
let mode = CommandLine.arguments[2]
let storage = AuthUserDefaults(service: service)
let key = "synthetic-session-marker"
let marker = Data("synthetic-storage-check".utf8)
if mode == "write" {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: service,
        kSecAttrAccount as String: key,
        kSecUseDataProtectionKeychain as String: true,
        kSecValueData as String: marker,
    ]
    let status = SecItemAdd(query as CFDictionary, nil)
    print("Data Protection Keychain status: \\(status)")
    if status == errSecSuccess { SecItemDelete(query as CFDictionary) }
    storage.setData(marker, forKey: key)
    print("Synthetic SDK storage written")
} else {
    guard storage.data(forKey: key) == marker else {
        fputs("SDK storage did not survive process exit\\n", stderr)
        exit(1)
    }
    storage.clear()
    print("Synthetic SDK storage restored in a fresh process and cleared")
}
''')
    binary = root / 'fallback-check'
    subprocess.run(['swiftc', str(sdk), str(source), '-o', str(binary)], check=True)
    subprocess.run(['codesign', '--force', '--sign', '-', str(binary)], check=True)
    subprocess.run([str(binary), service, 'write'], check=True)
    subprocess.run([str(binary), service, 'read'], check=True)
