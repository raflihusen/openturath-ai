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
# The worker is healthy only when it has completed a cycle since this start,
# reports no error, has a valid provider session and, for the expected mode,
# actually holds (active) or yields (standby) the writer lease. A 503 body is
# still parsed: it is how the worker explains why it is not ready.
EXPECT_MODE="${OPENTURATH_EXPECT_MODE:-active}"   # active | standby | shadow
check_worker() {
  curl -s --max-time 5 http://127.0.0.1:8091/ | EXPECT_MODE="$EXPECT_MODE" python3 -c '
import json, os, sys, time
d = json.load(sys.stdin)
mode = os.environ["EXPECT_MODE"]
now = time.time() * 1000
def fail(why):
    print("not ready: " + why, file=sys.stderr); sys.exit(1)
if d.get("error"): fail("error " + str(d["error"]))
if d.get("authentication_error"): fail("provider authentication error")
if d.get("mode") != mode: fail("mode %s, expected %s" % (d.get("mode"), mode))
if not d.get("last_success_ms") or d["last_success_ms"] < d.get("started_ms", 0): fail("no successful cycle since start")
if mode == "active":
    if d.get("lease_held") is not True: fail("writer lease not held")
    if not d.get("last_provider_success_ms") or now - d["last_provider_success_ms"] > 300000: fail("provider not observed recently")
if mode == "standby" and d.get("lease_held") is True: fail("standby holds the lease")
' 2>/dev/null
}
healthy=0
for _ in $(seq 1 40); do
  sleep 3
  if check_worker; then
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
