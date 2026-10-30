#!/bin/bash
set -euo pipefail
project_root="$(cd "$(dirname "$0")/.." && pwd)"
products="$project_root/build/macos/Build/Products/Release"
app="$products/OpenTurath AI.app"
test -d "$app"
python3 "$project_root/tool/macos/verify_session_signing.py" "$app" --allow-local-adhoc
# Every shipped native executable/library must support both intended CPU families.
while IFS= read -r -d '' binary; do
  if file -b "$binary" | grep -q 'Mach-O'; then
    lipo "$binary" -verify_arch arm64 x86_64
  fi
done < <(find "$app/Contents" -type f -print0)
plutil -lint "$app/Contents/Info.plist"
stage="$(mktemp -d "$products/dmg-stage.XXXXXX")"
trap 'rm -rf "$stage"' EXIT
ditto "$app" "$stage/OpenTurath AI.app"
ln -s /Applications "$stage/Applications"
hdiutil create -volname 'OpenTurath AI' -srcfolder "$stage" -ov -format UDZO "$products/OpenTurath_AI_macOS.dmg"
shasum -a 256 "$products/OpenTurath_AI_macOS.dmg" > "$products/OpenTurath_AI_macOS.dmg.sha256"
# Packaging is local. Developer ID signing/notarization must precede public distribution.
# Distribusi publik (OPENTURATH_PUBLIC_DIST=1) wajib Developer ID + notarisasi
# yang lolos Gatekeeper; paket lokal ad-hoc tidak boleh dipublikasikan.
if [ "${OPENTURATH_PUBLIC_DIST:-0}" = "1" ]; then
  if ! codesign -dv "$app" 2>&1 | grep -q 'Authority=Developer ID Application'; then
    echo "Distribusi publik ditolak: aplikasi tidak ditandatangani Developer ID Application." >&2; exit 1
  fi
  spctl --assess --type execute -v "$app" || { echo "Distribusi publik ditolak: Gatekeeper menolak aplikasi." >&2; exit 1; }
  xcrun stapler validate "$app" || { echo "Distribusi publik ditolak: tiket notarisasi belum distaple." >&2; exit 1; }
fi
