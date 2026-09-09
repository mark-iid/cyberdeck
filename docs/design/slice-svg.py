#!/usr/bin/env python3
"""Slice an STL at a given height and draw the cross-section as SVG.

WHY: every fault found in this build was found by LOOKING at a part - the
keystone, the front-rail bosses, the splice against a rib, the tray's bolts
drilled into a window. None was found by an assertion, because an assertion
only tests what its author already thought of. A cross-section shows what is
actually there, including the things nobody thought to check.

Usage: slice-svg.py part.stl [fraction]      # fraction of height, default 0.5
"""
import re, sys, os

def load(p):
    v = [tuple(map(float, m)) for m in
         re.findall(r'vertex\s+(\S+)\s+(\S+)\s+(\S+)', open(p).read())]
    return list(zip(v[0::3], v[1::3], v[2::3]))

def slice_at(tris, z):
    segs = []
    for t in tris:
        pts = []
        for a, b in ((0,1),(1,2),(2,0)):
            p, q = t[a], t[b]
            if (p[2]-z) * (q[2]-z) < 0:
                f = (z - p[2]) / (q[2] - p[2])
                pts.append((p[0] + f*(q[0]-p[0]), p[1] + f*(q[1]-p[1])))
        if len(pts) == 2:
            segs.append(pts)
    return segs

def main():
    path = sys.argv[1]
    frac = float(sys.argv[2]) if len(sys.argv) > 2 else 0.5
    tris = load(path)
    zs = [v[2] for t in tris for v in t]
    z = min(zs) + (max(zs) - min(zs)) * frac
    segs = slice_at(tris, z)
    xs = [p[0] for t in tris for p in t]; ys = [p[1] for t in tris for p in t]
    pad = 6
    w = max(xs) - min(xs) + 2*pad; h = max(ys) - min(ys) + 2*pad
    sc = 900.0 / max(w, h)
    out = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{w*sc:.0f}" '
           f'height="{h*sc:.0f}" viewBox="0 0 {w*sc:.0f} {h*sc:.0f}">',
           f'<rect width="100%" height="100%" fill="white"/>']
    for (a, b) in segs:
        x1 = (a[0]-min(xs)+pad)*sc; y1 = (max(ys)-a[1]+pad)*sc
        x2 = (b[0]-min(xs)+pad)*sc; y2 = (max(ys)-b[1]+pad)*sc
        out.append(f'<line x1="{x1:.1f}" y1="{y1:.1f}" x2="{x2:.1f}" y2="{y2:.1f}" '
                   f'stroke="black" stroke-width="2"/>')
    out.append(f'<text x="8" y="20" font-family="monospace" font-size="16">'
               f'{os.path.basename(path)}  z={z:.2f}</text></svg>')
    sys.stdout.write("\n".join(out))

main()
