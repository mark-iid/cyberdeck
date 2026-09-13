#!/usr/bin/env bash
# Export every part at its ASSEMBLED position, for render.py.
#
# assembly.scad already knows where each part goes (IN_PLACE=n gives part n
# alone, in place), so this does not restate a single coordinate. That matters:
# a render built from its own copy of the placements could disagree with the
# model that the interference checks actually verified.
#
# Also sets up build/venv, because render.py needs numpy and Fedora's python is
# externally managed (PEP 668) so installing into it is not on.
set -euo pipefail
cd "$(dirname "$0")/../.."
mkdir -p build/parts

for n in $(seq 0 22); do
    f="build/parts/$n.stl"
    if [ -s "$f" ] && [ "$f" -nt docs/design/assembly.scad ] \
                   && [ "$f" -nt docs/design/plate.scad ] \
                   && [ "$f" -nt docs/design/chassis.scad ] \
                   && [ "$f" -nt docs/design/deck.scad ]; then
        continue                      # still current, skip the re-render
    fi
    printf 'exporting part %s\n' "$n"
    flatpak run org.openscad.OpenSCAD -D "IN_PLACE=$n" -o "$PWD/$f" \
        "$PWD/docs/design/assembly.scad" >/dev/null 2>&1
    [ -s "$f" ] || { echo "part $n produced nothing" >&2; exit 1; }
done

if [ ! -x build/venv/bin/python ]; then
    echo "creating build/venv (needs numpy; system pillow is reused)"
    /usr/bin/python3 -m venv --system-site-packages build/venv
    build/venv/bin/python -m pip install --quiet numpy
fi

echo "ready:  build/venv/bin/python docs/design/render.py"
