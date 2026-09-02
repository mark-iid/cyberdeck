#!/usr/bin/env bash
# Computing and electronics reference. Resumable and idempotent.
#
# The deck already carried electronics/ham/security/DIY StackExchange dumps, but
# they were the 2023 vintage. Three years of answers is a lot to leave on the
# table when the whole point is having the answer with no network.
#
# THE STANDOUT: the devdocs collection is ~231 separate ZIMs totalling about
# 0.57 GB — every language, framework and API reference (C, bash, Python, CMake,
# Ansible, PostgreSQL, git, ...) for roughly the size of one podcast episode.
# Best value-per-byte of anything fetched for this machine.

source "$(dirname "$0")/lib.sh"
DEST="${DEST:-$HOME/kiwix-share}"
BASE=https://download.kiwix.org/zim
mkdir -p "$DEST"

fetch() {                       # fetch <path-under-zim/>
    local name; name="$(basename "$1")"
    [ -f "$DEST/$name" ] && { log "have: $name"; return 0; }
    if wget -c -q --show-progress --progress=dot:giga -O "$DEST/$name.part" "$BASE/$1"; then
        mv "$DEST/$name.part" "$DEST/$name"
    else
        warn "FAILED: $name (resume by re-running)"
    fi
}

# --- Named sets ---------------------------------------------------------------
log "Q&A archives — 2026 vintages; the deck's copies were 2023"
for z in \
    "stack_exchange/electronics.stackexchange.com_en_all_2026-08.zim" \
    "stack_exchange/unix.stackexchange.com_en_all_2026-08.zim" \
    "stack_exchange/raspberrypi.stackexchange.com_en_all_2026-08.zim" \
    "stack_exchange/arduino.stackexchange.com_en_all_2026-07.zim" \
    "stack_exchange/security.stackexchange.com_en_all_2026-08.zim" \
    "stack_exchange/crypto.stackexchange.com_en_all_2026-07.zim" \
    "stack_exchange/robotics.stackexchange.com_en_all_2026-08.zim" \
    "stack_exchange/retrocomputing.stackexchange.com_en_all_2026-08.zim" \
; do fetch "$z"; done

log "Language and system documentation"
fetch "zimit/docs.python.org_en_all_2026-08.zim"      # 3.76 GB, the full Python docs
fetch "other/archlinux_en_all_maxi_2026-07.zim"       # the best Linux troubleshooting wiki

# --- devdocs: enumerate from the catalogue rather than hardcoding 231 names ----
# Hardcoding the list would rot within a month — these are rebuilt continuously
# and carry dates in their filenames. Ask the catalogue what exists today.
log "Enumerating the devdocs collection"
mapfile -t DEVDOCS < <(
  curl -s --max-time 90 "https://opds.library.kiwix.org/catalog/v2/entries?q=devdocs&lang=eng&count=-1" 2>/dev/null \
  | tr '>' '>\n' | grep -oE 'href="[^"]*devdocs/[^"]*\.zim\.meta4"' \
  | sed 's|href="https://lb.download.kiwix.org/zim/||;s|\.meta4"||' | sort -u
)
if [ "${#DEVDOCS[@]}" -eq 0 ]; then
    warn "devdocs enumeration returned nothing — catalogue unreachable?"
else
    log "devdocs: ${#DEVDOCS[@]} references (~0.6 GB total)"
    for z in "${DEVDOCS[@]}"; do fetch "$z"; done
fi

echo
log "Adding everything to the Kiwix library"
for f in "$DEST"/*.zim; do
    kiwix-manage "$HOME/.local/share/kiwix-desktop/library.xml" add "$f" 2>/dev/null || true
done
log "library now lists $(grep -c '<book ' "$HOME/.local/share/kiwix-desktop/library.xml" 2>/dev/null) books"
warn "Restart kiwix-serve to publish them: systemctl --user restart kiwix-serve"
