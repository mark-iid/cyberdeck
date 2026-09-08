#!/usr/bin/env bash
# Build every part and check it. Run this instead of invoking OpenSCAD by hand.
#
# Three things it guarantees that a one-off export does not:
#   1. deck.scad's assert()s run, so a part whose stack-up is wrong is never
#      written to disk at all.
#   2. Every STL is regenerated, so none can go stale against the source. A
#      stale frame_full.stl sat in build/ at 304.0 for a day after the source
#      moved to 304.5, and nothing noticed.
#   3. check-stl.py runs on all of them: bed fit, z=0 seating, solid count.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
ROOT=$PWD
OUT=$ROOT/build/plate
mkdir -p "$OUT"
SCAD=(flatpak run org.openscad.OpenSCAD)     # absolute paths only - no /tmp

PLATE_PARTS="member member_front splice preload pp_retainer screen_tile rail_blank left_rail right_rail back_left back_right joint_test frame_full"
CHASSIS_PARTS="plinth tray cradle shroud"

rc=0
build() {   # build <part> <srcfile>
    local log
    log=$("${SCAD[@]}" -D "PART=\"$1\"" -o "$OUT/$1.stl" "$ROOT/docs/design/$2" 2>&1)
    if [ ! -f "$OUT/$1.stl" ]; then
        echo "FAILED  $1"
        echo "$log" | grep -iE "assert|error" | sed 's/^/        /'
        rc=1
        return
    fi
    # "Ignoring unknown module/function" means geometry silently went MISSING -
    # the STL still writes, and looks plausible. Treat it as a failure.
    if echo "$log" | grep -qiE "ignoring unknown"; then
        echo "FAILED  $1 (dropped geometry)"
        echo "$log" | grep -iE "ignoring unknown" | sed 's/^/        /'
        rc=1
    fi
    echo "$log" | grep -iE "warning" | grep -viE "ignoring unknown" | sed "s/^/  warn $1: /"
}

rm -f "$OUT"/*.stl
for p in $PLATE_PARTS;   do build "$p" plate.scad;   done
for p in $CHASSIS_PARTS; do build "$p" chassis.scad; done

echo
for f in "$OUT"/*.stl; do
    python3 "$ROOT/docs/design/check-stl.py" "$f" || rc=1
done
exit $rc
