#!/usr/bin/env bash
# Run the whole build, in order. Safe to re-run — every step is idempotent.
#
# THIS IS ADDITIVE. It does not reinstall, reformat, or replace Raspberry Pi OS.
# labwc stays installed and stays the default session; niri is added ALONGSIDE
# it as a second choice in the lightdm session menu. Everything built from
# source lands in /usr/local, which no distro package owns.

source "$(dirname "$0")/lib.sh"

HERE="$(cd "$(dirname "$0")" && pwd)"

log "Cyberdeck provisioning — additive, no reinstall"
log "Build tree: $BUILD_ROOT"
echo

for step in 00-packages 10-build-niri 20-build-xwayland-satellite 30-build-mshv 40-install-claude-code; do
    log "--- $step ---"
    "$HERE/$step.sh"
    echo
done

log "Build complete. Deploy configs with:  bin/deploy-config.sh"
log "Then log out and pick 'niri' in the lightdm session menu."
log "If anything is wrong, pick 'labwc' and you are exactly back where you started."
