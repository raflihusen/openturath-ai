#!/usr/bin/env bash
# Run on the operator's own machine, where the owner account is signed in to
# Chrome:  deploy/push_session.sh ubuntu@<vps-host>
# The VPS has no browser, so the consented NotebookLM session is refreshed
# here and copied over. The file is a credential: it is never committed.
set -euo pipefail

HOST="${1:?usage: push_session.sh <user@vps-host>}"
OWNER="${ACCESS_OWNER_EMAIL:?set ACCESS_OWNER_EMAIL to the notebook owner account}"
REMOTE="${OPENTURATH_ACCESS_HOME:-/home/ubuntu/openturath-access}/secrets"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

notebooklm login --browser-cookies chrome --account "$OWNER" --storage "$TMP/storage_state.json"
chmod 600 "$TMP/storage_state.json"
scp -q "$TMP/storage_state.json" "$HOST:$REMOTE/storage_state.json.incoming"
ssh "$HOST" "chmod 600 '$REMOTE/storage_state.json.incoming' && mv '$REMOTE/storage_state.json.incoming' '$REMOTE/storage_state.json'"
echo "Session pushed. The worker picks it up on its next sharing call."
