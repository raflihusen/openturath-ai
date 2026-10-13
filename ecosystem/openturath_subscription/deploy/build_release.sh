#!/usr/bin/env bash
# Builds a versioned release of the VPS access worker on the developer machine.
# Usage: deploy/build_release.sh            -> ecosystem/dist/openturath-access-<version>.tar.gz
# Nothing is uploaded; copy the tarball and its .sha256 to the VPS yourself.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
FUNCTIONS="$ROOT/openturath_ai/functions"
SOURCE="$ROOT/ecosystem/openturath_subscription"

if [ -n "$(git -C "$ROOT" status --porcelain -- openturath_ai/functions ecosystem/openturath_subscription)" ]; then
  echo "Working tree has uncommitted changes in the worker sources; commit first." >&2
  exit 1
fi
VERSION="$(date -u +%Y%m%dT%H%M%SZ)-$(git -C "$ROOT" rev-parse --short HEAD)"
NAME="openturath-access-$VERSION"
OUT="$ROOT/ecosystem/dist/$NAME"

echo "==> Verifying backend ($VERSION)"
(cd "$FUNCTIONS" && npm ci && npm run check && npm test && npm run build && node tool/export_shared.cjs)
if [ -n "$(git -C "$ROOT" status --porcelain -- ecosystem/openturath_subscription/shared openturath_ai/functions/lib)" ]; then
  echo "Compiled output or shared registries are stale; run 'npm run export-shared' and commit." >&2
  exit 1
fi
(cd "$SOURCE" && python3 -m unittest discover -s tests)

echo "==> Assembling $NAME"
rm -rf "$OUT"; mkdir -p "$OUT/lib"
cp "$FUNCTIONS"/lib/*.js "$OUT/lib/"
cp "$FUNCTIONS/package.json" "$FUNCTIONS/package-lock.json" "$OUT/"
cp "$SOURCE/verified_sharing.py" "$SOURCE/openturath-access.service" "$OUT/"
cp "$SOURCE"/notebooklm_py-*.whl "$OUT/"
cp -R "$SOURCE/shared" "$OUT/shared"
cp "$SOURCE/deploy/install_release.sh" "$SOURCE/deploy/rollback.sh" "$OUT/"
echo "$VERSION" > "$OUT/VERSION"

tar -C "$ROOT/ecosystem/dist" -czf "$OUT.tar.gz" "$NAME"
(cd "$ROOT/ecosystem/dist" && shasum -a 256 "$NAME.tar.gz" > "$NAME.tar.gz.sha256")
rm -rf "$OUT"
echo "==> $OUT.tar.gz"
