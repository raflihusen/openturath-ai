#!/bin/bash
set -euo pipefail
project_root="$(cd "$(dirname "$0")/.." && pwd)"
products="$project_root/build/macos/Build/Products/Release"
app="$products/OpenTurath AI.app"
test -d "$app"
# Every shipped native executable/library must support both intended CPU families.
while IFS= read -r -d '' binary; do
  if file -b "$binary" | grep -q 'Mach-O'; then
    lipo "$binary" -verify_arch arm64 || lipo "$binary" -verify_arch x86_64
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
