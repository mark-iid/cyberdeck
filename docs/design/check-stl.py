#!/usr/bin/env python3
"""Pre-print sanity check for an OpenSCAD-exported STL.

Exists because a coupon was once drawn with its two halves touching at x=0.
OpenSCAD unioned them into one continuous bar, it sliced as a single object,
and it tested nothing - which was only discovered after it had been printed.

Reports the bounding box, whether the part fits the bed, and how many
DISCONNECTED solids the file contains. Pass --solids N to assert the count.

    python3 docs/design/check-stl.py build/plate/joint_test.stl --solids 3
"""
import sys, struct


def load(path):
    with open(path, 'rb') as f:
        head = f.read(5)
        f.seek(0)
        if head == b'solid':
            tris = []
            cur = []
            for line in f:
                p = line.split()
                if p and p[0] == b'vertex':
                    cur.append(tuple(round(float(v), 4) for v in p[1:4]))
                    if len(cur) == 3:
                        tris.append(cur); cur = []
            return tris
        f.read(80)
        n = struct.unpack('<I', f.read(4))[0]
        tris = []
        for _ in range(n):
            d = struct.unpack('<12fH', f.read(50))
            tris.append([tuple(round(d[3 + i * 3 + a], 4) for a in range(3))
                         for i in range(3)])
        return tris


def solids(tris):
    """Connected components over shared vertices."""
    parent = {}

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(a, b):
        ra, rb = find(a), find(b)
        if ra != rb:
            parent[ra] = rb

    for t in tris:
        for v in t:
            parent.setdefault(v, v)
        union(t[0], t[1]); union(t[1], t[2])
    return len({find(v) for v in parent})


def main():
    path = sys.argv[1]
    want = None
    if '--solids' in sys.argv:
        want = int(sys.argv[sys.argv.index('--solids') + 1])
    bed = 215.0

    tris = load(path)
    lo = [min(v[a] for t in tris for v in t) for a in range(3)]
    hi = [max(v[a] for t in tris for v in t) for a in range(3)]
    size = [hi[a] - lo[a] for a in range(3)]
    n = solids(tris)

    fits = size[0] <= bed and size[1] <= bed
    diag = (size[0] + size[1]) <= bed * 1.414
    # Facet count, because a part whose cutouts silently failed to cut looks
    # perfect on every other line here. Both back tiles once exported with NO
    # screw holes at all - the holes were placed in the wrong coordinate frame,
    # landed off the part, and removed nothing. Bounding box, solid count and
    # z0 were all still correct. 112 facets against a sibling's 2176 is the
    # only thing that showed it.
    print("%-18s %7.2f x %7.2f x %6.2f  z0=%+.2f  solids=%d  facets=%d  bed=%s%s"
          % (path.split('/')[-1], size[0], size[1], size[2], lo[2], n, len(tris),
             "ok" if fits else ("DIAGONAL-ONLY" if diag else "TOO BIG"),
             "" if abs(lo[2]) < 0.01 else "  WARN: not on z=0"))
    if len(tris) <= 24:
        print("  WARN: %d facets - this part has no cutouts at all. Intended?"
              % len(tris))
    if want is not None and n != want:
        print("  FAIL: expected %d solids, found %d" % (want, n))
        return 1
    return 0


sys.exit(main())
