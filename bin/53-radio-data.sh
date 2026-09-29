#!/usr/bin/env bash
# Pre-fetch the reference data a radio go-box needs but cannot download later.
#
# These are the files that are USELESS to fetch when you actually need them,
# because needing them means the network is gone. Everything here is small.

source "$(dirname "$0")/lib.sh"

# --- 1. Satellite TLEs — gpredict currently has NONE ---------------------------
# Verified 2026-09-02: ~/.config/Gpredict/satdata/ is EMPTY, so satellite
# tracking does not work at all right now. gpredict's built-in updater needs the
# internet, which is precisely what is missing in the scenario this deck exists
# for.
#
# TLEs decay in accuracy over weeks, so these are not a fetch-once item. Refresh
# them whenever the deck has a connection; stale elements degrade gracefully
# (pointing error grows) rather than failing outright.
TLE_DIR="$HOME/.config/Gpredict/tle"
mkdir -p "$TLE_DIR"
log "Fetching TLEs into $TLE_DIR"
# "noaa" returned 0 satellites — celestrak folded it into "weather"
for grp in amateur weather cubesat stations visual gps-ops science; do
    url="https://celestrak.org/NORAD/elements/gp.php?GROUP=${grp}&FORMAT=tle"
    if curl -fsS --max-time 45 -o "$TLE_DIR/${grp}.txt" "$url"; then
        n=$(( $(wc -l < "$TLE_DIR/${grp}.txt") / 3 ))
        log "  ${grp}.txt — ${n} satellites"
    else
        warn "  ${grp}: fetch failed (network?)"
    fi
done
echo
warn "gpredict does NOT pick these up on its own. Import once with:"
warn "  gpredict -> Edit -> Update TLE data -> From local files -> $TLE_DIR"
warn "After that, satellites appear and gpredict tracks them offline."

# --- 2. cty.dat — DXCC country file -------------------------------------------
# Three loggers are installed (qlog, klog, tucnak) and they resolve a
# callsign to a DXCC entity using cty.dat. The only copy on this machine was
# buried in the MSHV BUILD TREE — scratch space that gets deleted (see the
# llama-server RPATH lesson in §5). Put a copy somewhere stable.
CTY_SRC="$(find "$HOME/.cache/cyberdeck-build" -name cty.dat 2>/dev/null | head -1)"
CTY_DST="$HOME/.local/share/hamradio/cty.dat"
if [ -n "$CTY_SRC" ]; then
    mkdir -p "$(dirname "$CTY_DST")"
    cp -n "$CTY_SRC" "$CTY_DST" && log "cty.dat copied to $CTY_DST"
else
    warn "no cty.dat found to copy; fetch from https://www.country-files.com/"
fi

# --- 3. Keep .debs so the machine can be repaired with no internet -------------
# apt deletes downloaded packages after installing. On a deck that may need to
# reinstall or roll back a package with no network, that is throwing away the
# only copy. 1412 .debs happened to still be cached; make that deliberate rather
# than luck.
CONF=/etc/apt/apt.conf.d/99cyberdeck-keep-debs
if [ ! -f "$CONF" ]; then
    printf '// Keep downloaded .debs so packages can be reinstalled offline.\n// This deck may need repair when there is no network to re-fetch from.\nBinary::apt::APT::Keep-Downloaded-Packages "true";\n' \
        | sudo tee "$CONF" >/dev/null
    log "apt will now KEEP downloaded .debs ($CONF)"
    log "  cache: $(ls /var/cache/apt/archives/*.deb 2>/dev/null | wc -l) packages, $(du -sh /var/cache/apt/archives 2>/dev/null | cut -f1)"
else
    log "apt .deb retention already configured"
fi
