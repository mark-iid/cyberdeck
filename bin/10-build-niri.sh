#!/usr/bin/env bash
# Build and install niri from source.
#
# WHY FROM SOURCE: niri is in no repository this machine can reach. Verified
# 2026-08-31 against trixie, trixie-updates, trixie-backports (temporarily
# enabled for the probe) and archive.raspberrypi.com. It missed the trixie
# freeze. This is not a preference, it is the only option short of changing
# distro — and changing distro was ruled out (see DESIGN.md §1).

source "$(dirname "$0")/lib.sh"
need_sudo

NIRI_REF="${NIRI_REF:-v26.04}"
NIRI_DIR="$BUILD_ROOT/niri"

# --- Rust toolchain ---------------------------------------------------------
# THE TRAP: trixie packages rustc/cargo 1.85, and niri v26.04 declares
# rust-version = "1.87". The distro toolchain is TOO OLD and the build fails
# with a confusing edition/feature error rather than a clean MSRV message.
#
# So niri gets rustup. (xwayland-satellite does NOT need this — it pins exactly
# 1.85.0, which is what Debian ships. See 20-build-xwayland-satellite.sh.)
NIRI_MSRV="1.87.0"

setup_rust() {
    if command -v rustup >/dev/null 2>&1; then
        log "rust: rustup present, ensuring stable >= $NIRI_MSRV"
        rustup toolchain install stable --profile minimal --no-self-update
        return
    fi

    local sys_ver=""
    command -v rustc >/dev/null 2>&1 && sys_ver="$(rustc --version | awk '{print $2}')"
    if [ -n "$sys_ver" ] && ver_ge "$sys_ver" "$NIRI_MSRV"; then
        log "rust: system rustc $sys_ver satisfies MSRV $NIRI_MSRV, using it"
        return
    fi

    warn "System rustc ${sys_ver:-<none>} < required $NIRI_MSRV. Installing rustup."
    warn "This downloads and runs the official rustup installer from https://sh.rustup.rs"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
        | sh -s -- -y --profile minimal --default-toolchain stable
    # shellcheck disable=SC1091
    source "$HOME/.cargo/env"
}

setup_rust
command -v rustup >/dev/null 2>&1 && export PATH="$HOME/.cargo/bin:$PATH"

fetch_repo https://github.com/niri-wm/niri.git "$NIRI_DIR" "$NIRI_REF"

log "Building niri $NIRI_REF (this takes a while on a Pi — 20-40 min is normal)"
cd "$NIRI_DIR"
thermal_check
cargo build --release --locked -j"$(build_jobs)"

# --- Install ----------------------------------------------------------------
# Paths follow niri's own packaging (its resources/ directory). Everything goes
# under /usr/local so a future distro niri package would cleanly take over.
log "Installing niri"
sudo install -Dm755 target/release/niri            /usr/local/bin/niri
sudo install -Dm755 resources/niri-session         /usr/local/bin/niri-session
sudo install -Dm644 resources/niri.desktop         /usr/share/wayland-sessions/niri.desktop
sudo install -Dm644 resources/niri-portals.conf    /usr/share/xdg-desktop-portal/niri-portals.conf
sudo install -Dm644 resources/niri.service         /usr/lib/systemd/user/niri.service
sudo install -Dm644 resources/niri-shutdown.target /usr/lib/systemd/user/niri-shutdown.target

log "niri installed: $(/usr/local/bin/niri --version)"
log "It will appear as a session choice in lightdm after a restart of the greeter."
