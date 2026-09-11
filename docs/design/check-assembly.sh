#!/usr/bin/env bash
# Interference checks on the ASSEMBLED plate. An EMPTY or ZERO-VOLUME result is
# a pass: two solids resting on each other share a face, and the intersection of
# a shared face is a zero-thickness sheet that OpenSCAD reports as "not empty".
# Volume is the honest test - contact is 0, interference is not.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
mkdir -p build/asm
rc=0
for k in "$@"; do
    # DELETE FIRST. Without this a failed or empty render leaves the previous
    # run's STL in place and the volume below measures history, not the model.
    # It reported two fixed collisions as still-failing before this line existed.
    rm -f "build/asm/$k.stl"
    flatpak run org.openscad.OpenSCAD -D "CHECK=\"$k\"" \
        -o "$PWD/build/asm/$k.stl" "$PWD/docs/design/assembly.scad" >/dev/null 2>&1
    if [ ! -s "build/asm/$k.stl" ]; then echo "  $k: PASS - no contact at all"; continue; fi
    v=$(python3 - "build/asm/$k.stl" <<'PY'
import re,sys
v=[tuple(map(float,m)) for m in re.findall(r'vertex\s+(\S+)\s+(\S+)\s+(\S+)',open(sys.argv[1]).read())]
t=list(zip(v[0::3],v[1::3],v[2::3]))
print("%.3f"%abs(sum((a[0]*(b[1]*c[2]-b[2]*c[1])-a[1]*(b[0]*c[2]-b[2]*c[0])+a[2]*(b[0]*c[1]-b[1]*c[0]))/6 for a,b,c in t)))
PY
)
    if [ "$(python3 -c "print(1 if float('$v')<1.0 else 0)")" = 1 ]; then
        echo "  $k: PASS - $v mm3 (shared faces only, no interference)"
    else
        echo "  $k: FAIL - $v mm3 of solids overlapping"; rc=1
    fi
done
exit $rc
