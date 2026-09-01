#!/usr/bin/env bash
# Push this repo to the deck and reload niri.
#
# WHY THIS IS NEEDED: bin/deploy-config.sh symlinks ~/.config/{niri,waybar,foot}
# into the repo checkout ON THE PI (~/cyberdeck). That checkout is a COPY of this
# one, not the same tree — so editing config.kdl here does nothing until it is
# synced. This closes that gap.
#
#   ./sync-to-pi.sh              # sync + validate + live-reload niri
#   HOST=otherpi ./sync-to-pi.sh

set -euo pipefail
HOST="${HOST:-mark@raspberrypi.local}"
REPO="$(cd "$(dirname "$0")/.." && pwd)"

echo "==> syncing $REPO -> $HOST:~/cyberdeck"
if command -v rsync >/dev/null 2>&1; then
    rsync -az --delete --exclude '.git' --exclude 'build/' \
        "$REPO"/ "$HOST":~/cyberdeck/
else
    # rsync is not installed on stock Raspberry Pi OS; tar over ssh always works.
    tar cf - -C "$REPO" --exclude=.git --exclude=build bin config files docs \
        | ssh "$HOST" 'rm -rf ~/cyberdeck/{bin,config,files,docs} && mkdir -p ~/cyberdeck && tar xf - -C ~/cyberdeck'
fi
ssh "$HOST" 'chmod +x ~/cyberdeck/bin/*.sh'

echo "==> validating config.kdl on the deck"
ssh "$HOST" 'niri validate -c ~/cyberdeck/config/niri/config.kdl 2>&1 | grep -E "config is valid|error" || true'

echo "==> reloading niri if it is running"
# `niri msg` needs NIRI_SOCKET, which an ssh session does not inherit. The
# socket is /run/user/<uid>/niri.<display>.<pid>.sock — discover it rather than
# hardcoding, since the pid changes every login.
ssh "$HOST" 'if pgrep -x niri >/dev/null; then
    export XDG_RUNTIME_DIR="/run/user/$(id -u)"
    export NIRI_SOCKET="$(ls -t "$XDG_RUNTIME_DIR"/niri.*.sock 2>/dev/null | head -1)"
    if [ -z "$NIRI_SOCKET" ]; then
      echo "   niri is running but no socket found under $XDG_RUNTIME_DIR"
    else
      niri msg action load-config-file && echo "   reloaded"
    fi
  else
    echo "   niri not running — changes apply at next login"
  fi'
