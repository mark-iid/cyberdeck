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

# Run each step, but do not let one failure silently look like progress. A
# failed step aborts (set -e via lib.sh) and the summary below says which.
failed=""
for step in 00-packages 10-build-niri 20-build-xwayland-satellite 30-build-mshv 40-install-claude-code; do
    log "--- $step ---"
    if "$HERE/$step.sh"; then
        log "--- $step OK ---"
    else
        failed="$step"
        warn "--- $step FAILED (exit $?) ---"
        break
    fi
    echo
done

# NOTE for anyone checking progress remotely: do NOT use
#     ssh host 'pgrep -f provision.sh'
# to test whether this is alive. pgrep -f matches the ssh-spawned shell's own
# command line, so it reports RUNNING even after this has exited. Grep this
# log for "PROVISION COMPLETE" or "PROVISION FAILED" instead.
if [ -n "$failed" ]; then
    warn "PROVISION FAILED at $failed"
    exit 1
fi
log "PROVISION COMPLETE"

log "Build complete. Deploy configs with:  bin/deploy-config.sh"
log "There is NO greeter on this machine (autologin). To enter niri:"
log "  1. 'niri' from a terminal          -> nested, zero-risk smoke test"
log "  2. Ctrl+Alt+F2, then 'niri-session' -> real hardware, still reversible"
log "  3. bin/90-set-session.sh niri       -> make it the boot default"
log "Back out any time with: bin/90-set-session.sh labwc"
