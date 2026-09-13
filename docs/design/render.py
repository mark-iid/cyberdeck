#!/usr/bin/env python3
"""Flat-shaded renders of the deck, straight from the assembly model.

No OpenGL. OpenSCAD's own PNG export needs an offscreen GL context, which is not
available headless, so this reads the STLs assembly.scad writes with IN_PLACE=n
and rasterises them itself with a real z-buffer.

It is a z-buffer and not a painter's algorithm on purpose. Sorting triangles by
centroid depth is much less code and it looked plausible right up until the
frame drew itself over the module in front of it: centroid order is not visual
order once triangles are large, whether or not the parts interpenetrate.

  ./docs/design/export-parts.sh     # writes build/parts/0..22.stl
  build/venv/bin/python docs/design/render.py            # all views
  build/venv/bin/python docs/design/render.py hero plate # just these

Needs numpy + pillow; build/venv has both (see export-parts.sh).
"""
import math, struct, sys, pathlib
import numpy as np
from PIL import Image, ImageDraw, ImageFont

ROOT = pathlib.Path(__file__).resolve().parents[2]
PARTS, OUT = ROOT / "build/parts", ROOT / "build/render"

# --- what each part is, how far it travels when exploded, and its colour -----
# Index is assembly.scad's part(i). Keep in step with it.
SPEC = {
    0:  ("frame back right",   0, (74, 84, 99)),
    1:  ("frame back left",    0, (74, 84, 99)),
    2:  ("frame front right",  0, (74, 84, 99)),
    3:  ("frame front left",   0, (74, 84, 99)),
    4:  ("left rail",         46, (216, 118, 50)),
    5:  ("right rail",        46, (216, 118, 50)),
    6:  ("back tile left",    46, (120, 132, 152)),
    7:  ("back tile right",   46, (120, 132, 152)),
    8:  ("screen bezel",      46, (168, 178, 192)),
    9:  ("splice back",      -30, (92, 102, 118)),
    10: ("splice right",     -30, (92, 102, 118)),
    11: ("splice left",      -30, (92, 102, 118)),
    12: ("front strap",      -30, (92, 102, 118)),
    13: ("PP retainer",      -30, (198, 143, 74)),
    14: ("preload strip R",   88, (48, 156, 142)),
    15: ("preload strip L",   88, (48, 156, 142)),
    16: ("tray right",      -150, (104, 114, 130)),
    17: ("tray left",       -150, (104, 114, 130)),
    18: ("plinth",          -116, (216, 118, 50)),
    19: ("cradle block",    -150, (144, 152, 166)),
    20: ("terminal shroud", -150, (144, 152, 166)),
    21: ("JUNEBOX module",   -76, (38, 40, 46)),
    22: ("battery",         -150, (36, 118, 80)),
}
BG = (247, 246, 243)
LIGHT = np.array([-0.30, 0.42, 0.86])          # front-left, above
LIGHT /= np.linalg.norm(LIGHT)
INK, LEAD = (46, 52, 64), (140, 148, 160)

# Callouts for the plan view, in MODEL coordinates (mm, plate frame: 0,0 is the
# centre of the plate, +y toward the back of the case). Rail centres are at
# x = +-120.625 and the rail features are offset from y = -39.5, both derived in
# deck.scad -- so if a connector moves in the model, move it here too.
RAIL_X, RAIL_Y = 120.625, -39.5
CALLOUTS = {
 "plate": [
   (-RAIL_X, RAIL_Y - 50, "SMA bulkhead", "L"),
   (-RAIL_X, RAIL_Y - 20, "Powerpole 12 V in", "L"),
   (-RAIL_X, RAIL_Y +  0, "3.5 mm audio", "L"),
   (-RAIL_X, RAIL_Y + 30, "DPDT  INT / OFF / EXT", "L"),
   ( RAIL_X, RAIL_Y - 20, "RJ45", "R"),
   ( RAIL_X, RAIL_Y + 34, "dual USB-A", "R"),
   (-10,  103, "battery well", "T"),
   (-95,   75, "vent grille", "L"),
   (0,    -41, "8\" 1280x800 touch", "B"),
 ],
}


def load_stl(p):
    b = p.read_bytes()
    if b[:5] == b"solid" and b"facet" in b[:2000]:
        vals = [float(w) for ln in b.decode().splitlines()
                if ln.strip().startswith("vertex") for w in ln.split()[1:4]]
        return np.array(vals, dtype=np.float64).reshape(-1, 3, 3)
    n = struct.unpack("<I", b[80:84])[0]
    raw = np.frombuffer(b, dtype=np.uint8, count=n*50, offset=84).reshape(n, 50)
    return raw[:, 12:48].copy().view("<f4").reshape(n, 3, 3).astype(np.float64)


def render(name, parts, yaw, pitch, size=(1600, 1200), explode=0.0, margin=0.07):
    if name in CALLOUTS: margin = 0.24     # leave room for the callouts
    ry, rp = math.radians(yaw), math.radians(pitch)
    Rz = np.array([[math.cos(ry), -math.sin(ry), 0],
                   [math.sin(ry),  math.cos(ry), 0], [0, 0, 1]])
    Rx = np.array([[1, 0, 0],
                   [0, math.cos(rp), -math.sin(rp)],
                   [0, math.sin(rp),  math.cos(rp)]])
    M = Rx @ Rz                                  # world -> view

    tri, col = [], []
    for i in parts:
        f = PARTS / f"{i}.stl"
        if not f.exists():
            print(f"  missing {f.name}"); continue
        t = load_stl(f)
        t[:, :, 2] += SPEC[i][1] * explode
        tri.append(t @ M.T)
        col.append(np.tile(SPEC[i][2], (len(t), 1)))
    if not tri:
        return
    tri = np.concatenate(tri)                    # (N,3,3) view space
    col = np.concatenate(col).astype(np.float64)

    # flat shading from the geometric normal
    n = np.cross(tri[:, 1] - tri[:, 0], tri[:, 2] - tri[:, 0])
    n /= np.maximum(np.linalg.norm(n, axis=1, keepdims=True), 1e-12)
    sh = 0.32 + 0.68 * np.clip(n @ LIGHT, 0, 1)
    col = col * sh[:, None]

    W, H = size
    SS = 2
    Wp, Hp = W*SS, H*SS
    lo, hi = tri[:, :, :2].min((0, 1)), tri[:, :, :2].max((0, 1))
    sc = min(Wp*(1-2*margin)/(hi[0]-lo[0]), Hp*(1-2*margin)/(hi[1]-lo[1]))
    ctr = (lo + hi) / 2
    px = (tri[:, :, 0] - ctr[0]) * sc + Wp/2
    py = Hp/2 - (tri[:, :, 1] - ctr[1]) * sc
    pz = tri[:, :, 2]

    fb = np.zeros((Hp, Wp, 3), np.float64); fb[:] = BG
    zb = np.full((Hp, Wp), -np.inf)

    x0 = np.clip(np.floor(px.min(1)).astype(int), 0, Wp-1)
    x1 = np.clip(np.ceil (px.max(1)).astype(int), 0, Wp-1)
    y0 = np.clip(np.floor(py.min(1)).astype(int), 0, Hp-1)
    y1 = np.clip(np.ceil (py.max(1)).astype(int), 0, Hp-1)

    ax, ay = px[:, 0], py[:, 0]
    bx, by = px[:, 1], py[:, 1]
    cx, cy = px[:, 2], py[:, 2]
    area = (bx-ax)*(cy-ay) - (by-ay)*(cx-ax)

    for k in range(len(tri)):
        if abs(area[k]) < 1e-9 or x1[k] < x0[k] or y1[k] < y0[k]:
            continue
        X, Y = np.meshgrid(np.arange(x0[k], x1[k]+1) + 0.5,
                           np.arange(y0[k], y1[k]+1) + 0.5)
        w0 = ((bx[k]-ax[k])*(Y-ay[k]) - (by[k]-ay[k])*(X-ax[k])) / area[k]
        w1 = ((X-ax[k])*(cy[k]-ay[k]) - (Y-ay[k])*(cx[k]-ax[k])) / area[k]
        inside = (w0 >= 0) & (w1 >= 0) & (w0 + w1 <= 1)
        if not inside.any():
            continue
        z = pz[k,0] + w1*(pz[k,1]-pz[k,0]) + w0*(pz[k,2]-pz[k,0])
        sub = zb[y0[k]:y1[k]+1, x0[k]:x1[k]+1]
        win = inside & (z > sub)
        if not win.any():
            continue
        sub[win] = z[win]
        fb[y0[k]:y1[k]+1, x0[k]:x1[k]+1][win] = col[k]

    img = Image.fromarray(np.clip(fb, 0, 255).astype(np.uint8)).resize((W, H), Image.LANCZOS)

    if name in CALLOUTS:
        def to_px(wx, wy):                       # model mm -> final image px
            v = np.array([wx, wy, 0.0]) @ M.T
            return ((v[0]-ctr[0])*sc + Wp/2) / SS, (Hp/2 - (v[1]-ctr[1])*sc) / SS
        d = ImageDraw.Draw(img)
        try:
            f = ImageFont.truetype("/usr/share/fonts/google-noto-vf/NotoSans[wght].ttf", 21)
        except OSError:
            f = ImageFont.load_default()
        # Leaders terminate OUTSIDE the plate (half-width 152.25, half-depth
        # 115.25) rather than at a fixed pixel offset, so a label can never sit
        # on top of the geometry it is pointing at.
        for wx, wy, text, side in CALLOUTS[name]:
            x, y = to_px(wx, wy)
            if side == "L":   tx, ty = to_px(-166, wy);  anc, dx = "rm", -10
            elif side == "R": tx, ty = to_px( 166, wy);  anc, dx = "lm",  10
            elif side == "T": tx, ty = to_px(wx,  128);  anc, dx = "md",   0
            else:             tx, ty = x, y + 26;        anc, dx = "ma",   0
            if side != "B":
                d.line([(x, y), (tx, ty)], fill=LEAD, width=2)
            d.ellipse([x-4, y-4, x+4, y+4], fill=INK)
            d.text((tx + dx, ty + (-8 if side == "T" else 0)),
                   text, font=f, fill=INK, anchor=anc)

    # Trim the dead space the fixed canvas leaves around the drawing. The
    # framing is chosen by content, not by whatever aspect ratio I guessed.
    bbox = Image.new("RGB", img.size, BG)
    from PIL import ImageChops
    diff = ImageChops.difference(img, bbox).convert("L").point(lambda v: 255 if v > 6 else 0)
    if diff.getbbox():
        pad = 34
        l, t, r, b = diff.getbbox()
        img = img.crop((max(0, l-pad), max(0, t-pad),
                        min(img.width, r+pad), min(img.height, b+pad)))

    OUT.mkdir(parents=True, exist_ok=True)
    out = OUT / f"{name}.png"
    img.save(out, optimize=True)
    print(f"  {out.relative_to(ROOT)}  {len(tri)} tris  {out.stat().st_size//1024} KB")


def stack_diagram(name="stack", size=(1500, 1080)):
    """The vertical budget, which is the one idea the 3D views cannot show.

    Everything in this build is decided by where the rib shelf is (75 mm) and
    what has to fit above and below it, so it earns a drawing of its own.
    Heights are the real numbers from deck.scad, drawn to scale.
    """
    W, H = size
    SS = 2
    img = Image.new("RGB", (W*SS, H*SS), BG)
    d = ImageDraw.Draw(img)
    F = "/usr/share/fonts/google-noto-vf/NotoSans[wght].ttf"
    try:
        f  = ImageFont.truetype(F, 25*SS)
        fb = ImageFont.truetype(F, 27*SS)
        fs = ImageFont.truetype(F, 20*SS)
    except OSError:
        f = fb = fs = ImageFont.load_default()

    x0, x1 = int(0.235*W*SS), int(0.660*W*SS)         # the main column
    bx0, bx1 = int(0.700*W*SS), int(0.815*W*SS)       # the battery, beside it
    top, bot = int(0.095*H*SS), int(0.800*H*SS)
    mm = (bot - top) / 100.0                          # 0..100 mm of interior
    def Y(z): return bot - z*mm

    #        z0    z1     colour           label
    bands = [(81,  100, (236, 234, 229), "19 mm recess  ·  TPU strips, lid foam"),
             (75,   81, (74, 84, 99),    "6 mm frame + 4.5 mm tiles"),
             (30.5, 75, (38, 40, 46),    "44 mm  JUNEBOX module"),
             (4,  30.5, (216, 118, 50),  "26.5 mm plinth  ·  the plenum"),
             (0,     4, (104, 114, 130), "4 mm tray")]
    for z0, z1, col, label in bands:
        d.rectangle([x0, Y(z1), x1, Y(z0)], fill=col)
        ink = INK if sum(col) > 460 else (250, 249, 247)
        d.text((x0 + 16*SS, (Y(z0)+Y(z1))/2), label, font=f, fill=ink, anchor="lm")

    # the battery does not fit under the plate; it stands through it
    d.rectangle([bx0, Y(94), bx1, Y(4)], fill=(36, 118, 80))
    d.text(((bx0+bx1)/2, Y(94) - 12*SS), "battery", font=fs, fill=INK, anchor="md")
    d.text(((bx0+bx1)/2, Y(49), ), "90 mm\nstands up\nthrough\nthe plate",
           font=fs, fill=(250, 249, 247), anchor="mm", align="center")

    # datums, labelled short so nothing runs off the canvas
    for z, text, heavy in [(100, "100   case rim", 0), (81, "81   plate top", 0),
                           (75, "75   RIB SHELF", 1), (0, "0   case floor", 0)]:
        y = Y(z)
        d.line([x0 - 0.030*W*SS, y, bx1 + 0.020*W*SS, y],
               fill=(INK if heavy else LEAD), width=(3 if heavy else 1)*SS)
        d.text((x0 - 0.045*W*SS, y), text, font=(fb if heavy else f),
               fill=INK, anchor="rm")

    d.text((x0 - 0.045*W*SS, Y(75) + 30*SS), "the plate lands here,\non twelve moulded ribs",
           font=fs, fill=(110, 118, 132), anchor="ra", align="right")
    d.text((x0, Y(0) + 52*SS),
           "4 + 26.5 + 44 = 74.5 under a 75 mm shelf. The half millimetre is deliberate:",
           font=f, fill=INK, anchor="la")
    d.text((x0, Y(0) + 52*SS + 34*SS),
           "any positive error lifts the plate off its ribs, so the module always lands low",
           font=f, fill=(110, 118, 132), anchor="la")
    d.text((x0, Y(0) + 52*SS + 68*SS),
           "and 2 mm of foam tape takes up the gap.",
           font=f, fill=(110, 118, 132), anchor="la")

    img = img.resize((W, H), Image.LANCZOS)
    OUT.mkdir(parents=True, exist_ok=True)
    out = OUT / f"{name}.png"
    img.save(out, optimize=True)
    print(f"  {out.relative_to(ROOT)}  {out.stat().st_size//1024} KB")


ALL     = list(SPEC)
PLATE   = [0, 1, 2, 3, 4, 5, 6, 7, 8, 13]        # the face of the deck
CHASSIS = [16, 17, 18, 19, 20, 21, 22]           # everything below the shelf

# pitch is NEGATIVE for a view from above: it tips the top of the model toward
# the camera. pitch = 0 looks straight down and gives a plan view.
#  name        parts    yaw  pitch  explode
VIEWS = {
    "hero":     (ALL,     28,  -58,  0.0),
    "exploded": (ALL,     26,  -60,  1.0),
    "plate":    (PLATE,    0,    0,  0.0),   # annotated, see CALLOUTS
    "chassis":  (CHASSIS, 30,  -52,  0.0),
}

if __name__ == "__main__":
    for v in (sys.argv[1:] or list(VIEWS) + ["stack"]):
        if v == "stack":
            print("stack:"); stack_diagram(); continue
        if v not in VIEWS:
            print(f"unknown view {v}; have {', '.join(VIEWS)}"); continue
        parts, yaw, pitch, ex = VIEWS[v]
        print(f"{v}:")
        render(v, parts, yaw, pitch, explode=ex)
