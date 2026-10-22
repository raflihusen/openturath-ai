#!/usr/bin/env bash
# Run on the VPS as the service user:  ./install_release.sh openturath-access-<version>.tar.gz
# Installs next to the previous release, switches the `current` symlink, and
# switches back automatically if the worker does not come up healthy.
set -euo pipefail

BASE="${OPENTURATH_ACCESS_HOME:-/home/ubuntu/openturath-access}"
SERVICE="openturath-access"
TARBALL="${1:?usage: install_release.sh <release.tar.gz>}"

(cd "$(dirname "$TARBALL")" && sha256sum -c "$(basename "$TARBALL").sha256")
NAME="$(basename "$TARBALL" .tar.gz)"
RELEASE="$BASE/releases/$NAME"
mkdir -p "$BASE/releases" "$BASE/secrets"
chmod 700 "$BASE/secrets"
rm -rf "$RELEASE"
tar -C "$BASE/releases" -xzf "$TARBALL"

echo "==> Installing dependencies"
(cd "$RELEASE" && npm ci --omit=dev --ignore-scripts)
[ -d "$BASE/venv" ] || python3 -m venv "$BASE/venv"
if [ -f "$BASE/requirements.lock" ]; then
  "$BASE/venv/bin/pip" install --quiet -r "$BASE/requirements.lock"
fi
"$BASE/venv/bin/pip" install --quiet "$RELEASE"/notebooklm_py-*.whl
# First install records the exact resolved versions; later installs reuse them.
[ -f "$BASE/requirements.lock" ] || "$BASE/venv/bin/pip" freeze --exclude notebooklm-py > "$BASE/requirements.lock"

PREVIOUS="$(readlink "$BASE/releases/current" 2>/dev/null || true)"
ln -sfn "$RELEASE" "$BASE/releases/current"
sudo install -m 0644 "$RELEASE/$SERVICE.service" "/etc/systemd/system/$SERVICE.service"
sudo systemctl daemon-reload
sudo systemctl restart "$SERVICE"

echo "==> Waiting for the worker"
healthy=0
for _ in $(seq 1 20); do
  sleep 3
  # The endpoint answers 503 while the provider has not been observed yet;
  # what matters here is that the process is up and its cycle did not fail.
  if curl -s --max-time 5 http://127.0.0.1:8091/ | python3 -c 'import json,sys; d=json.load(sys.stdin); sys.exit(1 if d.get("error") else 0)' 2>/dev/null; then
    healthy=1; break
  fi
done
if [ "$healthy" != 1 ]; then
  echo "Worker did not become healthy; restoring the previous release." >&2
  if [ -n "$PREVIOUS" ]; then ln -sfn "$PREVIOUS" "$BASE/releases/current"; sudo systemctl restart "$SERVICE"; fi
  exit 1
fi

# The owner bot is optional: it runs only once its secrets file exists.
if [ -f "$BASE/secrets/owner_bot.env" ]; then
  sudo install -m 0644 "$RELEASE/openturath-owner-bot.service" /etc/systemd/system/openturath-owner-bot.service
  sudo systemctl daemon-reload
  sudo systemctl enable --now openturath-owner-bot >/dev/null 2>&1 || true
  sudo systemctl restart openturath-owner-bot
  echo "==> Owner bot: $(systemctl is-active openturath-owner-bot)"
else
  echo "==> Owner bot skipped (no $BASE/secrets/owner_bot.env)"
fi

# Keep the five newest releases.
ls -1dt "$BASE"/releases/openturath-access-* | tail -n +6 | xargs -r rm -rf
echo "==> $NAME is live ($(curl -s --max-time 5 http://127.0.0.1:8091/ | python3 -c 'import json,sys; print("mode:", json.load(sys.stdin).get("mode"))'))"
