#!/usr/bin/env bash
# Flipper Zero support on the deck.
#
# The operator already maintains a well-developed flipper repo on their NAS:
# ~8800 .ir files, ~960 .nfc, an SD-card backup, plus hand-written references
# (badusb ducky cheatsheet, cc1101 SubGHz guide, GPIO pinout, nRF24 sweep notes,
# app and script inventories). Credentials are deliberately excluded from it.
#
# NOTHING is re-downloaded from upstream here — that work is done and would only
# create a second, diverging copy. The actual gap was that all of it lived on the
# workstation and the NAS, and NONE of it was on the deck. A go-box that cannot
# reach the NAS is exactly the situation the deck exists for.

source "$(dirname "$0")/lib.sh"
need_sudo

REMOTE="${REMOTE:-ssh://git@nas1.crosscreek:30143/mark/flipper.git}"
DEST="${DEST:-$HOME/src/flipper}"

# qflipper: manage and reflash the device from the go-box. It ships
# 42-flipperzero.rules, so the device is reachable without root provided the
# user is in dialout (verified: they are).
apt_install qflipper

mkdir -p "$(dirname "$DEST")"
if [ -d "$DEST/.git" ]; then
    log "Updating $DEST"
    git -C "$DEST" pull --ff-only 2>&1 | tail -2
else
    log "Cloning the flipper repo to $DEST"
    git clone "$REMOTE" "$DEST" 2>&1 | tail -3 \
        || die "Clone failed. The deck reaches nas1.crosscreek:30143, so this is
almost certainly ssh key auth. Copy a key, or pull from the workstation:
  rsync -a mark@<workstation>:~/src/flipper/ $DEST/"
fi

if [ -d "$DEST" ]; then
    log "On the deck now:"
    printf '    %-22s %s\n' "size" "$(du -sh "$DEST" 2>/dev/null | cut -f1)"
    printf '    %-22s %s\n' "infrared (.ir)" "$(find "$DEST" -name '*.ir' 2>/dev/null | wc -l)"
    printf '    %-22s %s\n' "nfc (.nfc)" "$(find "$DEST" -name '*.nfc' 2>/dev/null | wc -l)"
    printf '    %-22s %s\n' "subghz (.sub)" "$(find "$DEST" -name '*.sub' 2>/dev/null | wc -l)"
    printf '    %-22s %s\n' "docs" "$(ls "$DEST/flipper-docs" 2>/dev/null | wc -l) files"
fi

echo
log "The IR database is the part that earns its place on a go-box: ~8800 remote"
log "codes means the deck can drive a projector, AC unit or TV it has never seen."
warn "SubGHz is sparse (7 .sub files) — that is capture data, not a reference set,"
warn "so nothing to fetch; it fills up as you use the device."
