#!/usr/bin/env bash
# Fetch the offline content gaps identified in docs/CONTENT.md.
#
# Resumable (wget -c) and idempotent — re-running skips complete files, so an
# interrupted download over a slow link just picks up where it stopped.
#
# SELECTION RATIONALE (docs/CONTENT.md):
#  - Medical was the single largest gap: the deck had 42 ZIMs and NOTHING
#    medical. Three complementary sources rather than one, because they are
#    written for different readers: WikiMed is encyclopaedic, WikEM is
#    emergency-clinician oriented, and the FAS military medicine set is field
#    medicine under austere conditions.
#  - Video ZIMs (Canadian Prepper, Urban Prepper, Learning Self-Reliance, ~6GB)
#    are DELIBERATELY EXCLUDED. Low information density per GB next to text, and
#    the deck already carries ~30 Khan Academy video sets.
#  - MDWiki (2.14GB maxi / 10GB full) overlaps WikiMed heavily; not both.
#
# Sizes and dates were read from the Kiwix OPDS catalog on 2026-09-02. Newer
# builds appear regularly — check https://opds.library.kiwix.org/catalog/v2/entries?q=<term>
# rather than assuming these filenames stay current.

source "$(dirname "$0")/lib.sh"

DEST="${DEST:-$HOME/kiwix-share}"
BASE=https://download.kiwix.org/zim

ZIMS=(
  "wikipedia/wikipedia_en_medicine_maxi_2026-04.zim"        # 2.06 GB  WikiMed
  "other/wikem_en_all_maxi_2026-07.zim"                     # ~0.5 GB  emergency medicine
  "zimit/irp.fas.org_en_military-medicine_2026-05.zim"      # 0.08 GB  field medicine
  "other/zimgit-post-disaster_en_2024-05.zim"               # 0.65 GB  water/sanitation/shelter
  "ifixit/ifixit_en_all_2025-12.zim"                        # 3.57 GB  repair guides
  "other/appropedia_en_all_maxi_2026-02.zim"                # 0.54 GB  appropriate technology
  "other/trueprepper.com_en_all_2026-05.zim"                # 1.33 GB  practical prepping
)

mkdir -p "$DEST"
avail=$(df --output=avail -BG "$DEST" | tail -1 | tr -dc '0-9')
log "Destination $DEST — ${avail}G free"
[ "$avail" -gt 20 ] || die "Under 20G free; refusing to start (~9G of downloads plus headroom)."

fail=0
for z in "${ZIMS[@]}"; do
    name="$(basename "$z")"
    if [ -f "$DEST/$name" ]; then
        log "have: $name"
        continue
    fi
    log "fetching: $name"
    if ! wget -c -q --show-progress --progress=dot:giga -O "$DEST/$name.part" "$BASE/$z"; then
        warn "FAILED: $name — leaving .part for a later resume"
        fail=$((fail+1)); continue
    fi
    mv "$DEST/$name.part" "$DEST/$name"
done

echo
log "Adding everything to the Kiwix library"
for f in "$DEST"/*.zim; do
    kiwix-manage "$HOME/.local/share/kiwix-desktop/library.xml" add "$f" 2>/dev/null || true
done
log "library now lists $(grep -c '<book ' "$HOME/.local/share/kiwix-desktop/library.xml" 2>/dev/null || echo '?') books"
[ "$fail" -eq 0 ] || warn "$fail download(s) failed — re-run to resume."
