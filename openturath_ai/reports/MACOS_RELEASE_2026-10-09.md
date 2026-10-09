# Local macOS release — 9 October 2026

- Source checkpoint: 89c872ee401ff800a899bedd0c6fdf7119d40746.
- Version: 1.0.63+64 (version unchanged; latest source rebuilt).
- Artifact: `/Users/apple/Downloads/ramadhan/OpenTurath_AI_macOS.dmg`
- Size: 51,325,970 bytes (51.33 MB).
- SHA-256: `c5616e2f8dd2a4271cc631281daa6954a593880c9162cb78ab2fe20a57b5fb61`
- Completed: 2026-10-09T03:24:08+03:00 (Asia/Aden).

## Validation

- Dependency restoration preserved tracked package files. Initial default-parallel build was intentionally interrupted after heavy swapping; resumed with Xcode `-jobs 2`, exit 0.
- Final `flutter build macos --release --no-pub`: exit 0; application 132.5 MB.
- `bash tool/package_macos.sh`: exit 0.
- Info.plist lint and deep/strict codesign verification passed.
- All 37 distinct Mach-O binaries contain arm64 and x86_64.
- Compiled App.framework contains composer anchoring and placeholder-removal script markers.
- `hdiutil verify`: exit 0; DMG checksum VALID.
- Read-only mounted DMG contains the correct application version and Applications symlink. Packaged app signature passed; App.framework hash matches the build. Volume detached after verification.
- Root download copy matches packaged DMG SHA-256 and has a timestamp newer than the WebView source change.

## Boundaries

Local artifact only; no upload or update broadcast. Signature is ad-hoc; no Developer ID or Apple notarization. Third-party build warnings remain. No authenticated NotebookLM session, fresh installation, or Intel-host launch was verified in this release pass; previous WebKit fixtures do not substitute for that runtime check.
