#!/usr/bin/env bash
# Thermal tuning for a Pi 5 that CANNOT fit a fan (DESIGN §6).
#
# THE COUNTERINTUITIVE POINT, which is the whole reason this script exists:
#
#   A LOWER CONFIGURED CLOCK CAN BE FASTER THAN A HIGHER ONE.
#
# This deck is configured for arm_freq=2400 with arm_boost=1. It never gets
# there. Measured 2026-08-31 it runs at 1000-1500 MHz because the SoC is
# thermally throttling, and it oscillates as it fights the limit.
#
# Capping the clock at something the passive heatsinks can actually sustain
# means the chip holds that clock CONTINUOUSLY instead of sawtoothing down to
# 1000. Less heat generated, less throttling, higher average throughput. You
# trade an unreachable peak for a reachable floor.
#
#   ./70-thermal-tune.sh measure          # benchmark current settings
#   ./70-thermal-tune.sh set 1800         # cap at 1800MHz, drop arm_boost
#   ./70-thermal-tune.sh restore          # put config.txt back

source "$(dirname "$0")/lib.sh"
need_sudo

CFG=/boot/firmware/config.txt
BAK="$CFG.pre-cyberdeck"

# A 60s run is NOT long enough: measured 2026-08-31 the SoC held 2.2GHz for
# ~45s from cold and only began dropping at t=60. It is still heat-soaking.
# A real build runs 20-40 minutes, so steady state is what matters. Default 300s.
measure() {
    local dur="${1:-300}"
    log "Baseline: $(vcgencmd measure_temp), $(vcgencmd get_throttled), arm=$(vcgencmd measure_clock arm | cut -d= -f2)"
    log "Applying ${dur}s of 4-core load (steady state is the number that counts)..."
    for i in 1 2 3 4; do (while :; do :; done) & done
    local pids; pids="$(jobs -p)"
    local t=0
    while [ $t -lt "$dur" ]; do
        t=$((t+30))
        sleep 30
        printf '  t=%2ds  %s  %s  arm=%s\n' "$t" \
            "$(vcgencmd measure_temp)" "$(vcgencmd get_throttled)" \
            "$(vcgencmd measure_clock arm | cut -d= -f2)"
    done
    kill $pids 2>/dev/null
    log "Load removed. Compare 'arm=' across settings — the SUSTAINED value is"
    log "what matters, not the configured maximum."
}

case "${1:-}" in
measure) measure "${2:-300}" ;;

set)
    freq="${2:?usage: $0 set <MHz>   e.g. 1800}"
    [ -f "$BAK" ] || { sudo cp "$CFG" "$BAK"; log "backed up config.txt -> $(basename "$BAK")"; }

    # arm_boost pushes the peak clock. Boosting a Pi that cannot cool itself is
    # strictly counterproductive — it generates heat to reach a clock it will
    # immediately be throttled out of.
    sudo sed -i 's/^arm_boost=1/#arm_boost=1  # disabled: no cooling headroom (DESIGN §6)/' "$CFG"
    sudo sed -i '/^arm_freq=/d' "$CFG"
    printf 'arm_freq=%s\n' "$freq" | sudo tee -a "$CFG" >/dev/null

    log "Set arm_freq=$freq and disabled arm_boost."
    warn "Reboot, then re-run '$0 measure' and compare the SUSTAINED arm= value"
    warn "against the ~1000000000 (1.0GHz) it throttles to today."
    ;;

restore)
    [ -f "$BAK" ] || die "No backup at $BAK"
    sudo cp "$BAK" "$CFG"
    log "config.txt restored. Reboot to apply."
    ;;

*) sed -n '2,24p' "$0"; exit 0 ;;
esac
