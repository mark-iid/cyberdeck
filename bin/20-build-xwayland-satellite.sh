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

# PATH FIRST, THEN CHECK. An earlier version had these two lines the other way
# round and died with "cargo not found. Run 00-packages.sh first." on a healthy
# system: 00-packages does NOT install cargo (niri brings its own toolchain via
# rustup in 10-build-niri.sh), so the only cargo present lives in ~/.cargo/bin
# and the check ran before that was on PATH. The message was wrong twice over.
[ -d "$HOME/.cargo/bin" ] && export PATH="$HOME/.cargo/bin:$PATH"
command -v cargo >/dev/null 2>&1 || die "cargo not found on PATH or in ~/.cargo/bin.
Run 10-build-niri.sh first — it installs the rustup toolchain that this reuses.
(trixie's packaged cargo 1.85 would satisfy this crate's 1.85.0 MSRV, but it is
not installed by 00-packages.sh because niri needs 1.87 and gets rustup instead.)"

fetch_repo https://github.com/Supreeeme/xwayland-satellite.git "$XWS_DIR" "$XWS_REF"

log "Building xwayland-satellite $XWS_REF"
cd "$XWS_DIR"
thermal_check
cargo build --release --locked -j"$(build_jobs)"

log "Installing xwayland-satellite"
sudo install -Dm755 target/release/xwayland-satellite /usr/local/bin/xwayland-satellite

log "xwayland-satellite installed."
log "The niri config spawns it at startup and sets DISPLAY=:0 to match."
