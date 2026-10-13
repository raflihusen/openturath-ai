#!/usr/bin/env bash
# Run on the VPS:  ./rollback.sh            -> list installed releases
#                  ./rollback.sh <release>  -> switch to it and restart the worker
# Code only: Firestore documents and NotebookLM membership are not rewound.
set -euo pipefail

BASE="${OPENTURATH_ACCESS_HOME:-/home/ubuntu/openturath-access}"
if [ -z "${1:-}" ]; then
  echo "Current: $(basename "$(readlink "$BASE/releases/current")")"
  ls -1dt "$BASE"/releases/openturath-access-* | xargs -n1 basename
  exit 0
fi
TARGET="$BASE/releases/$1"
[ -d "$TARGET" ] || { echo "Release $1 is not installed." >&2; exit 1; }
ln -sfn "$TARGET" "$BASE/releases/current"
sudo systemctl restart openturath-access
echo "Rolled back to $1"
