#!/usr/bin/env python3
"""List every distinct cutout in a part, measured from the solid.

Slices the STL, joins the segments into closed loops, and reports each loop's
size and centre. The outer loop is the part; every inner loop is a hole, a
window or a pocket. This is what an assertion cannot do: it reports what IS
there, not what someone remembered to check for.
"""
import re, sys, math

def load(p):
    v=[tuple(map(float,m)) for m in re.findall(r'vertex\s+(\S+)\s+(\S+)\s+(\S+)',open(p).read())]
    return list(zip(v[0::3],v[1::3],v[2::3]))

def slice_at(tris,z):
    segs=[]
    for t in tris:
        pts=[]
        for a,b in ((0,1),(1,2),(2,0)):
            p,q=t[a],t[b]
            if (p[2]-z)*(q[2]-z)<0:
                f=(z-p[2])/(q[2]-p[2])
                pts.append((round(p[0]+f*(q[0]-p[0]),3), round(p[1]+f*(q[1]-p[1]),3)))
        if len(pts)==2 and pts[0]!=pts[1]: segs.append(tuple(pts))
    return segs

def loops(segs):
    adj={}
    for a,b in segs:
        adj.setdefault(a,[]).append(b); adj.setdefault(b,[]).append(a)
    seen=set(); out=[]
    for start in adj:
        if start in seen: continue
        comp=[start]; stack=[start]; seen.add(start)
        while stack:
            for n in adj[stack.pop()]:
                if n not in seen: seen.add(n); comp.append(n); stack.append(n)
        out.append(comp)
    return out

def main():
    path=sys.argv[1]; frac=float(sys.argv[2]) if len(sys.argv)>2 else 0.4
    tris=load(path); zs=[v[2] for t in tris for v in t]
    z=min(zs)+(max(zs)-min(zs))*frac
    ls=loops(slice_at(tris,z))
    rows=[]
    for c in ls:
        xs=[p[0] for p in c]; ys=[p[1] for p in c]
        rows.append((max(xs)-min(xs), max(ys)-min(ys),
                     (min(xs)+max(xs))/2, (min(ys)+max(ys))/2, len(c)))
    rows.sort(key=lambda r:-r[0]*r[1])
    print(f"{path.split('/')[-1]}  slice z={z:.2f}   {len(rows)} loops")
    for i,(w,h,cx,cy,n) in enumerate(rows):
        kind="OUTLINE" if i==0 else ("round" if n>16 else "rect ")
        print(f"    {kind:8} {w:7.2f} x {h:7.2f}   centre ({cx:8.2f},{cy:8.2f})")
main()
