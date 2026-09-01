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
ssh "$HOST" 'if pgrep -x niri >/dev/null; then
    niri msg action reload-config && echo "   reloaded"
  else
    echo "   niri not running — changes apply at next login"
  fi'
