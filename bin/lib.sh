# Shared helpers for the cyberdeck provisioning scripts.
# Sourced, not executed.

set -euo pipefail

# All source checkouts and build trees live here, outside the repo (.gitignore'd
# anyway, but keeping them out of the worktree makes `git status` honest).
BUILD_ROOT="${BUILD_ROOT:-$HOME/.cache/cyberdeck-build}"

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31m[x]\033[0m %s\n' "$*" >&2; exit 1; }

need_sudo() {
    sudo -n true 2>/dev/null || die "This script needs sudo. Run 'sudo -v' first."
}

# apt install that is quiet when there is nothing to do. Idempotent.
apt_install() {
    local missing=()
    for p in "$@"; do
        dpkg -s "$p" >/dev/null 2>&1 || missing+=("$p")
    done
    if [ ${#missing[@]} -eq 0 ]; then
        log "apt: already satisfied (${#@} packages)"
        return 0
    fi
    log "apt: installing ${missing[*]}"
    sudo apt-get install -y --no-install-recommends "${missing[@]}"
}

# Clone-or-update a pinned checkout. Always ends detached at exactly $ref.
fetch_repo() {
    local url="$1" dir="$2" ref="$3"
    mkdir -p "$(dirname "$dir")"
    if [ -d "$dir/.git" ]; then
        log "fetch: updating $(basename "$dir")"
        git -C "$dir" fetch --tags --force --quiet origin
    else
        log "fetch: cloning $(basename "$dir")"
        git clone --quiet "$url" "$dir"
    fi
    git -C "$dir" checkout --quiet --detach "$ref"
    log "fetch: $(basename "$dir") at $ref ($(git -C "$dir" rev-parse --short HEAD))"
}

# Compare dotted versions: ver_ge 1.87.0 1.85.0 -> true
ver_ge() {
    [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -1)" = "$2" ]
}

# --- Thermal guard ----------------------------------------------------------
# RESOLVED 2026-09-02: an active cooler was fitted and the deck now sustains the
# full 2400MHz for 5 minutes of 4-core load, closed case, peaking at 76.8C with
# throttle flags 0x0. See DESIGN §4.
#
# So all cores is now the correct default. The historical reason this was ever
# halved: before the cooler the machine idled at 88-90C, was clock-capped to
# 1.0GHz, and hit 93C under load — a full-core build would have sat at the
# thermal limit for hours. Set JOBS=2 to get that conservative behaviour back if
# the cooler is ever removed.
build_jobs() {
    echo "${JOBS:-$(nproc)}"
}

thermal_check() {
    command -v vcgencmd >/dev/null 2>&1 || return 0
    local t f; t="$(vcgencmd measure_temp 2>/dev/null | tr -dc '0-9.')"
    f="$(vcgencmd get_throttled 2>/dev/null | cut -d= -f2)"
    log "thermal: ${t:-?}C, throttle flags ${f:-?}, building with -j$(build_jobs)"
    # bit 2 (0x4) = currently throttled
    # bit 2 (0x4) = currently throttled. With the active cooler fitted this
    # should never fire; if it does, the fan has failed or is obstructed.
    if [ -n "$f" ] && [ $(( $(printf '%d' "$f") & 0x4 )) -ne 0 ]; then
        warn "THERMALLY THROTTLED RIGHT NOW (${t}C) — unexpected with the cooler fitted."
        warn "Check the fan: cat /sys/devices/platform/cooling_fan/hwmon/hwmon*/fan1_input"
        warn "and /sys/class/thermal/cooling_device0/cur_state. See DESIGN §4."
    fi
}
