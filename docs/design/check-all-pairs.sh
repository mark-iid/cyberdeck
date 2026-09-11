#!/usr/bin/env bash
# Every part against the union of all the others. N renders cover all pairs, and
# nothing depends on anyone choosing which pairs matter. Slow - run it and go
# away. Zero volume is contact; anything else is interference.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
mkdir -p build/pairs
NAMES=(member_BR member_BL member_FR member_FL left_rail right_rail back_left back_right
       screen_tile splice_back splice_R splice_L front_strap pp_retainer preload_R preload_L
       tray_R tray_L plinth cradle shroud MODULE BATTERY)
for i in $(seq 0 22); do
    f="build/pairs/$i.stl"; rm -f "$f"
    flatpak run org.openscad.OpenSCAD -D "PART_N=$i" -o "$PWD/$f" \
        "$PWD/docs/design/assembly.scad" >/dev/null 2>&1
    if [ ! -s "$f" ]; then echo "  ${NAMES[$i]}: clear"; continue; fi
    python3 - "$f" "${NAMES[$i]}" <<'PY'
import re,sys
v=[tuple(map(float,m)) for m in re.findall(r'vertex\s+(\S+)\s+(\S+)\s+(\S+)',open(sys.argv[1]).read())]
t=list(zip(v[0::3],v[1::3],v[2::3]))
vol=abs(sum((a[0]*(b[1]*c[2]-b[2]*c[1])-a[1]*(b[0]*c[2]-b[2]*c[0])+a[2]*(b[0]*c[1]-b[1]*c[0]))/6 for a,b,c in t))
xs=[p[0] for p in v]; ys=[p[1] for p in v]; zs=[p[2] for p in v]
tag = "contact only" if vol < 1.0 else "*** OVERLAP ***"
print(f"  {sys.argv[2]}: {vol:9.2f} mm3  {tag}"
      + ("" if vol < 1.0 else f"   at x {min(xs):.1f}..{max(xs):.1f} y {min(ys):.1f}..{max(ys):.1f} z {min(zs):.1f}..{max(zs):.1f}"))
PY
done
