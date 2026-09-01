#!/usr/bin/env bash
# Build and install xwayland-satellite — niri's X11 bridge.
#
# This matters more here than on a normal desktop: fldigi is FLTK/X11, chirp is
# wxPython, and sdrtrunk-style Java apps are X11. Without this, they do not run.
#
# Unlike niri, this builds with Debian's OWN rustc: xwayland-satellite v0.8.2
# declares rust-version = "1.85.0" and trixie ships exactly 1.85. No rustup
# needed — though if 10-build-niri.sh already installed one, it is used instead
# and works fine.

source "$(dirname "$0")/lib.sh"
need_sudo

XWS_REF="${XWS_REF:-v0.8.2}"
XWS_DIR="$BUILD_ROOT/xwayland-satellite"

command -v cargo >/dev/null 2>&1 || die "cargo not found. Run 00-packages.sh first."
[ -d "$HOME/.cargo/bin" ] && export PATH="$HOME/.cargo/bin:$PATH"

fetch_repo https://github.com/Supreeeme/xwayland-satellite.git "$XWS_DIR" "$XWS_REF"

log "Building xwayland-satellite $XWS_REF"
cd "$XWS_DIR"
thermal_check
cargo build --release --locked -j"$(build_jobs)"

log "Installing xwayland-satellite"
sudo install -Dm755 target/release/xwayland-satellite /usr/local/bin/xwayland-satellite

log "xwayland-satellite installed."
log "The niri config spawns it at startup and sets DISPLAY=:0 to match."
