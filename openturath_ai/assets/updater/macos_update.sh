#!/bin/sh
# Only application bundles are replaced. User data, cookies and Keychain are untouched.
set -eu
mode=$1
fail() { echo "$1" >&2; exit 1; }
plist() { /usr/libexec/PlistBuddy -c "Print :$2" "$1/Contents/Info.plist"; }
team() { /usr/bin/codesign -dv --verbose=2 "$1" 2>&1 | /usr/bin/awk -F= '/^TeamIdentifier=/{print $2}'; }
if [ "$mode" = prepare ]; then
  dmg=$2; target=$3; build=$4; hash=$5; adhoc=${6:-0}
  case "$build" in ''|*[!0-9]*) fail 'Invalid build';; esac
  [ -d "$target/Contents" ] && [ ! -L "$target" ] || fail 'Install the application in a writable folder first'
  parent=$(dirname "$target")
  [ -w "$parent" ] && [ -w "$target" ] || fail 'Application folder is not writable'
  actual=$(/usr/bin/shasum -a 256 "$dmg" | /usr/bin/awk '{print $1}')
  [ "$actual" = "$hash" ] || fail 'Package checksum changed'
  stage=$(/usr/bin/mktemp -d "$parent/.ot-update.XXXXXXXX")
  mount=$(/usr/bin/mktemp -d /tmp/ot-update-mount.XXXXXXXX)
  complete=0
  cleanup() {
    /usr/bin/hdiutil detach "$mount" -quiet >/dev/null 2>&1 || true
    /bin/rmdir "$mount" 2>/dev/null || true
    if [ "$complete" = 0 ]; then /bin/rm -rf "$stage"; fi
  }
  trap cleanup EXIT
  /usr/bin/hdiutil attach "$dmg" -readonly -nobrowse -quiet -mountpoint "$mount"
  source=''
  for candidate in "$mount"/*.app; do
    [ -d "$candidate" ] || continue
    [ -z "$source" ] || fail 'Ambiguous application package'
    [ ! -L "$candidate" ] || fail 'Application cannot be a symlink'
    source=$candidate
  done
  [ -n "$source" ] || fail 'Package does not contain an application'
  [ "$(plist "$source" CFBundleIdentifier)" = "$(plist "$target" CFBundleIdentifier)" ] || fail 'Application identity mismatch'
  [ "$(plist "$source" CFBundleVersion)" = "$build" ] || fail 'Package build mismatch'
  /usr/bin/codesign --verify --deep --strict "$source"
  oldteam=$(team "$target"); newteam=$(team "$source")
  if [ "$adhoc" != 1 ]; then
    [ -n "$newteam" ] && [ "$newteam" != 'not set' ] || fail 'A signed distribution build is required'
    if [ -n "$oldteam" ] && [ "$oldteam" != 'not set' ]; then
      [ "$oldteam" = "$newteam" ] || fail 'Signing team changed'
    fi
    /usr/sbin/spctl --assess --type execute "$source"
  fi
  /usr/bin/ditto "$source" "$stage/next.app"
  /usr/bin/codesign --verify --deep --strict "$stage/next.app"
  printf '%s' "$target" > "$stage/target"
  complete=1
  printf '%s\n' "$stage"
elif [ "$mode" = install ]; then
  stage=$2; target=$3; oldpid=$4; build=$5
  case "$oldpid:$build" in *[!0-9:]*|:*) fail 'Invalid install request';; esac
  [ "$(cat "$stage/target")" = "$target" ] || fail 'Install target changed'
  [ "$(dirname "$stage")" = "$(dirname "$target")" ] || fail 'Invalid staging folder'
  [ "$(plist "$stage/next.app" CFBundleVersion)" = "$build" ] || fail 'Staged build mismatch'
  /usr/bin/codesign --verify --deep --strict "$stage/next.app"
  echo waiting > "$stage/status"
  touch "$stage/ready"
  n=0
  while kill -0 "$oldpid" 2>/dev/null; do
    n=$((n+1)); [ "$n" -lt 120 ] || fail 'Application did not close'
    sleep 1
  done
  replaced=0
  rollback() {
    if [ "$replaced" = 1 ] && [ -d "$stage/previous.app" ]; then
      # Stop only the failed candidate before restoring its predecessor.
      /usr/bin/pkill -f "^$target/Contents/MacOS/" 2>/dev/null || true
      /bin/mv "$target" "$stage/failed.app" 2>/dev/null || true
      /bin/mv "$stage/previous.app" "$target"
      echo rolled_back > "$stage/status"
      /usr/bin/open -n "$target" || true
    fi
  }
  trap rollback EXIT
  /bin/mv "$target" "$stage/previous.app"
  replaced=1
  /bin/mv "$stage/next.app" "$target"
  echo installed > "$stage/status"
  /usr/bin/open -n "$target"
  n=0
  while [ ! -f "$stage/confirmed" ]; do
    n=$((n+1)); [ "$n" -lt "${OT_UPDATER_HEALTH_TIMEOUT:-90}" ] || fail 'New application did not confirm startup'
    sleep 1
  done
  replaced=0
  echo confirmed > "$stage/status"
  # Keep the previous bundle for diagnosis/recovery; never delete it before confirmation.
else
  fail 'Unknown updater operation'
fi
