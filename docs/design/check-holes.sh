#!/usr/bin/env bash
# Deep check: probe every declared fastener position against the real solid.
# Slow (~2 min) and CSG-heavy, so it is not part of build.sh - run it after any
# change to a bolt pattern, a part's placement, or a coordinate frame.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
mkdir -p build/holes
rc=0
for k in joint ledge tile plinth cradle; do
    out=$(flatpak run org.openscad.OpenSCAD -D "PROBE=\"$k\"" \
          -o "$PWD/build/holes/$k.stl" "$PWD/docs/design/check-holes.scad" 2>&1)
    if echo "$out" | grep -qi "top level object is empty"; then
        echo "  $k: PASS - every hole present"
    else
        echo "  $k: FAIL - material where a hole should be"
        rc=1
    fi
done
exit $rc
