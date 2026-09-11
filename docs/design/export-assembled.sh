#!/usr/bin/env bash
# Every part exported IN ITS ASSEMBLED POSITION, one file each. Load them all
# into a slicer at once and they land where they belong - so you can hide and
# show parts and actually look at how they meet.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
mkdir -p build/assembled
NAMES=(member_BR member_BL member_FR member_FL left_rail right_rail back_left back_right
       screen_tile splice_back splice_R splice_L front_strap pp_retainer preload_R preload_L
       tray_R tray_L plinth cradle shroud MODULE BATTERY)
for i in $(seq 0 22); do
    f="build/assembled/${i}_${NAMES[$i]}.stl"; rm -f "$f"
    flatpak run org.openscad.OpenSCAD -D "IN_PLACE=$i" -o "$PWD/$f" \
        "$PWD/docs/design/assembly.scad" >/dev/null 2>&1
    [ -s "$f" ] && echo "  ${NAMES[$i]}" || echo "  ${NAMES[$i]}  FAILED"
done
