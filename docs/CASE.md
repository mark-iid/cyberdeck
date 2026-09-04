# Case & faceplate design

For the next enclosure. Written to be shopped and printed against, not admired.

**The computer is a self-contained module.** The display is a JUNEBOX 8"
1280×800 IPS 5-point touch unit (Amazon B0DX26BXPX) whose **backboard enclosure
houses the Raspberry Pi 5 itself** — plus, now, the NVMe SSD and heatsink. It
takes **DC 12 V** in, exposes HDMI / USB / power on the case, mounts via **VESA
75/100**, and carries **its own active cooling fan**. So the 203 × 136.5 × 51 mm
brick is the whole computer, not a screen bolted to a separate Pi.

That collapses the build to three essentials — the JUNEBOX module, a keyboard,
and the Miady LFP8AH LiFePO4 pack (12.8 V, 8 Ah, **102.4 Wh**) — plus an
**optional** RTL-SDR + telescopic antenna. The SDR is the first thing to cut if
space is tight; the deck is fully functional without it. The
operator has a 3D printer and an existing ~Pelican-1150-class shell that "opens
upside down."

## §1 — The one constraint that decides everything

> "It will never run fully closed, but I would like it waterproof fully closed."

That single sentence removes the hardest problem in a go-box build. It means:

1. **Do NOT penetrate the waterproof shell.** No bulkhead connectors through the
   case wall — every hole you drill is a seam to fail. All I/O lives on an
   **internal faceplate**, exposed only when the lid is open, sealed inside the
   shell when closed.
2. **The connectors do not need to be waterproof.** They are never exposed to
   weather while stowed (inside the sealed shell) and the deck is not run in the
   rain. So use cheap standard panel-mount parts, not IP67 ones. Big cost and
   sourcing saving.
3. **Cooling is a non-issue.** The active-cooler airflow problem (DESIGN §6) only
   bites in a *sealed running* box. This never runs sealed — open lid = open air.
   Waterproofing is a *transport/storage* requirement, which a stock Pelican-class
   shell meets out of the box with zero modification.

The build reduces to: an unmodified waterproof shell + a printed faceplate that
carries the screen, keyboard and connectors, deployed only when open.

## §2 — Form factor: single-face slab, not a clamshell

"Functional wins" + "opens upside down" both point the same way. The current
build is a clamshell (screen in lid, keyboard in base) and the lid orientation is
the complaint. Drop the clamshell.

**Recommended: a slab deck.** Screen, keyboard and connector panel are coplanar
on ONE printed faceplate that drops into the case base. The lid becomes a pure
waterproof cover — fully removable, or hinged to fold flat back past 180°.

Why it wins here:
- **Fixes the orientation gripe outright.** Open the lid, set it down, and the
  entire working surface faces up like a field radio (think TRS-80 Model 100 or a
  Elecraft go-box). Nothing to prop, nothing upside down.
- **The faceplate border IS the connector panel** — the frame around the screen
  and keyboard is exactly the real estate the operator asked for.
- **Prints flat and iterates cheaply.** A faceplate is a near-2.5D part: fast to
  print, trivial to reprint when a connector moves. A clamshell hinge is the
  hardest thing on a printer to get right and is a mechanical failure point.
- **No hinge to waterproof.** The seal is the shell's existing lid gasket, which
  is already rated.

Clamshell only wins on stowed compactness. This is a go-box, not a pocket deck;
footprint when open matters more than millimetres when closed.

## §3 — Connector cutouts (VERIFIED dimensions, 2026-09-02)

Print test coupons before committing the faceplate — filament shrinkage and slop
vary by printer, and RF connectors especially want a snug hole.

| Connector | Purpose | Cutout | Notes |
|---|---|---|---|
| **SMA** bulkhead | antenna feed (RECOMMENDED) | **⌀6.7 as printed** (6.5 nominal + 0.2) | Matches the all-SMA RTL-SDR kit with no adapter. Panel jack stays mated (coax to a stand), so the mating-cycle limit is moot. Add a flat/notch for anti-rotation. |
| **BNC** bulkhead | antenna feed (alt) | **~14 mm** round, keyed | Only if quick-swap at the panel matters; needs an SMA→BNC adapter for this kit. |
| **USB-A ×2, dual square** | data / peripherals | **21.5 × 24.5 mm**, local web **2.0 mm** | **Test-fitted 2026-09-04**, not from a vendor sheet — the sheet never had it. One housing, one hole. Bezel 25.4 × 28.6 overhangs ~2 mm per side. The 2.0 mm web is a rebate in the 4.5 mm tile, not a thinner tile. |
| **DC barrel 2.1 mm** | 12 V in / charge | **~8 mm** round (0.31") | Panel jack, up to 8 mm panel thickness. |
| **Cat6A keystone coupler** | panel Ethernet | ⚠️ **UNRESOLVED — enters 14.9 × 16.2, will not latch** (test fit 2026-09-04, §8 #8) | Confirms the 14.7 × 16.2 estimate to 0.1 mm. Body **32.6 mm** deep behind the plate. It is a **coupler** — needs a short Cat6 patch cable inside, Pi → back of jack. Goes in a printed keystone frame, not straight into the plate (see the thin-panel note below §3). |
| **Anderson Powerpole** | external 12 V IN | **⌀30.5 mm round** (1.2", vendor sheet 2026-09-04) | ⚠️ Round flip-cap weatherproof socket, **not** the flat PanelPole1 the buy list assumed and **not** a rectangle. Biggest cutout on the plate. Flange + cap diameter still unmeasured — see §8 #7, this is the one that may not fit the rail. |
| **16 mm anti-vandal button** | master power | **⌀16.2 as printed** (16.0 nominal + 0.2) | Latching, 5 A+. Hex flange **17.8 across flats = 20.6 across corners** — that, not 16, is the clearance the rail must give. Body **32 mm** deep behind the plate. Screw terminals on **8.3 mm** pitch. Between battery and the module — **there is no buck converter** (§5). |

**This printer runs holes 0.2 mm undersize.** Two independent ladders on the `rail`
coupon landed on the same offset — SMA wanted 6.7 for a 6.5 part, the switch wanted
16.2 for a 16.0 one. That is systematic shrinkage, so **every round hole on the plate
gets nominal + 0.2** rather than its own experiment. The USB result is consistent with
it too: 21.5 × 24.5 retains a part whose snap shoulder is nominally a touch larger.

**The thin-panel problem, and the one fix for all of it.** Two of the ordered parts
retain themselves by snapping to the panel — the USB unit's buckle and the keystone's
latch. Both are designed for **sheet metal or ~2–3 mm wall plate**. A printed faceplate
stiff enough to carry an 8" module wants **4–5 mm**. Neither will click home in that.

Do not thin the whole plate. **Print thin carrier inserts** — a keystone frame, a USB
bezel — each at the thickness its part expects, dropped into a larger rebated opening
in the thick plate and held with M3s from behind. One pattern, both parts, and it makes
either connector replaceable later without recutting the plate. §7 already called for
this for the keystone; it now applies to the USB too.

**One RF connector, and make it SMA.** The operator's RTL-SDR is a Blog-V3-class
kit — dongle, coax, and telescopic dipole all SMA. So an **SMA bulkhead on the
panel needs no adapter anywhere**, and it is the smallest cutout (⌀6.5 mm single
hole). SMA's only real drawback, its ~500-cycle mating limit, does not apply
here: the antenna sits on its stand on a length of coax, so the panel jack stays
mated and you adjust at the antenna end. Route a short internal SMA jumper from
this bulkhead to the dongle, which lives inside on a module USB port. (BNC would
work with an SMA→BNC adapter if quick-swap at the panel ever matters, but for
this kit it just adds a part.)

## §4 — Suggested faceplate layout

Sized to the **measured** interior (§6): **305 × 230**, vertical walls, plate riding
the moulded rib shelf at **75 mm**. Usable plate is **304 × 229** — in six or more
printed pieces, for reasons below.

```
 BACK ────────────────────── 305 mm ──────────────────────
 ┌──────────────────────────────────────────────────────┐
 │  ▒▒▒ BATTERY on side ▒▒▒  │  SDR · coax · antenna     │  back channel
 │  ~118 × 90, terms inboard │  cylinder                 │  ~88 mm deep
 ├───────┬──────────────────────────────────────┬───────┤
 │ LEFT  │                                      │ RIGHT │
 │ RAIL  │        8" TOUCHSCREEN                │ RAIL  │
 │ 50 mm │          173 × 118                   │ 50 mm │
 │ [SMA] │        (1280 × 800)                  │[USB-A]│
 │ [PP]  │   module 203 × 136.5 hangs below     │[USB-A]│
 │ [⏻SW] │                                      │[RJ45] │
 └───────┴──────────────────────────────────────┴───────┘
 FRONT (operator)
          keyboard lifts out, sets on the surface in front
```

**Width budget: 203 (module) + 2 × 50 (rails) = 303 of 304.** This stopped being the
binding dimension the moment the shell was measured — it came in 5 mm *wider* than
catalog, so the rails gained 2 mm each over the drawn 48 and the "SMA moves to a
corner" contingency in §8 #4 is dead. Depth is comfortable too: 136.5 module + ~90 mm
back channel against 229.

**The module's own I/O sets which side is which** — power/AV exit its LEFT edge,
USB/Ethernet its RIGHT — so the plate mirrors it: power + antenna left, data right,
short cable runs on both. Keep each rail on a **shallow raised lip** so cables exit
sideways rather than up into the screen's sightline.

**Keyboard stays separate** (§9, §10). At 230 × 160 it cannot share the plate with
a 136.5 mm-deep module inside 225 mm of depth — integrating it would require a
1550/4800-class shell, ~2.8× the volume for one feature. It stows flat over the
faceplate at close and is set on the surface in front during use, which is better
ergonomics anyway: a mini keyboard with a touchpad wants to be positioned.

\* The module's 12 V barrel already carries the Powerpole pigtail (see DONE
list); the panel Powerpole IN parallels it. Faceplate USB-A jacks are panel-mount
extensions off the Pi's right-edge ports.

### Construction — a frame on the rib shelf, tiles in the frame

**2 mm of ledge is enough, but only because the plate is trapped.** The rib inner
edges sit at 2 and 303, so the shelf opening is 301. A plate of width P has 305 − P
of lateral freedom, so if it slides fully to one side the thin side retains exactly
**P − 303 mm** of bearing:

| Plate width | Guaranteed bearing per side | Verdict |
|---|---|---|
| 303 | 0 | can lose the shelf entirely — no |
| **304** | **1.0 mm** | drop-in, 1 mm total clearance |
| 304.5 | 1.5 mm | sand to fit |

Load was never the concern — 1 mm across twelve ribs carries a 2 kg module and plate
without noticing. The concern was the plate walking off its shelf in transport, and it
cannot: escaping needs 2 mm of sideways travel and the wall stops it at 1.

The taper cuts the same way. Interior at the shelf is 305.0, and it *narrows* going
down (0.09 mm per mm), so a 304 frame drops in freely from a 307 rim and is stopped by
the ribs, not wedged by the wall. 304.5 would give 1.5 mm of bearing and a light wedge
right at the seat — the better number if the print comes off the bed accurate enough to
risk it, since anything oversize simply sits proud of 75 mm rather than not fitting.

**Corner radius is ~18 mm**, so the frame's corners are arcs and each side wall offers
**~193 mm of straight run** for connectors. **Rib centres are at 0 and ±74.5 mm** on
every wall (Pelican CAD, §6) — the long sides' lap joints go there.

**Nothing here prints in one piece.** The Ender 3 is 220 × 220 × 250, ~215 × 215 once
the nozzle's corner reach is allowed for. 304 × 229 is not close, and a full-length
frame rail does not fit diagonally either — a 215 mm square tops out near 304 mm of
combined length + width. A 304 mm plate at 4.5 mm would warp off that bed regardless.

So the plate is two kinds of part:

- **Frame** — outer 304 × 229, section ~12 mm wide, resting on all twelve rib tops.
  Six members: each long side split in two, each short side whole, lap-jointed with
  M3s. Being continuous it does not care where the ribs fall along a wall — but the
  **joints must land over a rib**, never mid-span.
- **Tiles** — screen bezel, left rail, right rail, back-channel fillers — dropped into
  the frame's inner flange. The flange turns a 2 mm ledge into a 10–12 mm one, so no
  tile inherits the tolerance problem the frame solves once.

The split delivers what §3 asked for independently: the USB and keystone carriers
wanted to be separate thin parts anyway, and now every connector sits on a piece small
enough to reprint alone when a cutout comes out wrong.

**Under the plate: 75 mm.** The module hangs 51 mm below, leaving ~20 mm of floor
clearance for cable runs; the battery on its 70 mm side clears the underside with 5 mm.
Anything resting on the floor is bounded by the flat **270 × 200** inside the fillet,
not by 305 × 230.

**Above the plate: 25 mm** (75 mm shelf in a 100 mm base). The Perixx is 23 mm thick,
so **the keyboard stows in the base recess, lying on the plate** — the lid is freed.
Measured protrusions, parts seated in their winning coupon holes (2026-09-04):

| Part | Stands proud | Under a 23 mm keyboard in a 25 mm recess |
|---|---|---|
| Switch | **1.5 mm** | fits |
| USB | **2.0 mm** | exactly at the limit — touching, zero clearance |
| SMA | **9.7 mm** | 5× over |

**The keyboard's footprint is a 2 mm keep-out zone**, and that is the whole budget:
75 + 23 = 98 against a 100 mm base. Centred, a 230 × 160 keyboard on a 304 × 229 plate
covers x ∈ [37, 267] and leaves the outer **37 mm of each rail uncovered** — so the
rail connectors are clear provided they sit outboard, which a 50 mm rail gives them
room to do. **The SMA must be kept out of the footprint deliberately**, not by luck:
outboard on the left rail, or back with the SDR and coax in the back channel where its
jumper wants to run anyway.

Stowing in the base beats the lid on retention too — a keyboard lying on a plate under
a closed lid cannot fall out when the case is opened, which a lid-mounted one can.

## §5 — Power & cooling (mostly solved by the module)

The self-contained 12 V module removes the two hardest parts of a go-box build:

- **No power conversion — and this was a deliberate purchase decision, not luck.**
  The module is 12 V-native *and powers the Pi from that same 12 V*, doing its own
  internal 12 V→5 V. The 12.8 V LiFePO4 feeds it **directly** — no buck converter to
  size, no 5 V rail to build, no brownout-throttle risk from an undersized
  regulator, no second PSU to find room for. The deck has **exactly one power
  inlet**, which is the cleanest possible path and the reason most of §5 is short.
- **No cooling to design.** The module has its own active fan (and the Pi inside
  carries the Geekworm active cooler — DESIGN §6.8, full 2.4 GHz sustained). The
  case only has to **not block the module's vents**. Combined with "never runs
  closed" (§1), thermal is a non-issue.

### Consequences of the single 12 V feed

- **NEVER plug power into the Pi's USB-C.** The Pi is powered *through* the module,
  so a charger or power bank on that port would be a second source fighting the
  module's 5 V rail. **Confirmed unused** (2026-09-02) — it is free for data/OTG,
  and nothing else.
- **USB budget, confirmed 2026-09-02.** One Pi USB-A is consumed internally by the
  module's touch input; the rest are free. With the Perixx's two built-in hubs on
  top, port count is not a constraint — the two panel USB-A jacks are comfortable.
- **One switch kills the whole deck.** The left-rail master switch sits on the 12 V
  feed *upstream* of the module, so it cuts screen, Pi, SSD and fan together. No
  partial-power states to reason about.
- **Size the fuse for the sum, not the Pi.** Pi 5 under load with peripherals plus
  the panel draws ~30 W worst case ≈ **2.5 A at 12 V**. A **5 A** fuse on the
  battery positive gives headroom without letting a real fault run.
- **Runtime comes off one number.** 102.4 Wh, derated ~10 % for practical LiFePO4
  discharge:

| Use | Draw | Runtime |
|---|---|---|
| Reading kiwix / maps, screen dim | ~10 W | ~9 h |
| Typical operating (FT8, browsing) | ~15 W | ~6 h |
| Heavy (local LLM, compiling) | ~28 W | ~3.5 h |

  A full field day at typical load, or an overnight at light load. If that is short
  for the intended trip, the fix is the panel Powerpole IN (below) rather than a
  bigger internal pack.

**Power distribution — internal battery + external Powerpole input.** The
Miady LFP8AH connects on Powerpole today, and the panel needs an **external
Powerpole IN** so the deck can run off shore power, a larger battery, or solar
while the internal pack is present. Standardise the whole bus on Powerpole (the
ARES/RACES convention anyway).

The one real gotcha is **how the two sources coexist on a LiFePO4 bus**:

- **Simplest — a selector switch.** A DPDT (or a Powerpole A/B switch) picks
  internal *or* external. No back-feeding, no charge-control surprises. Cheapest
  and safest; the downside is manual switchover, not seamless failover.
- **Seamless — a power-management board.** A West Mountain Super PWRgate (or
  equivalent ideal-diode ORing board with a LiFePO4 charge profile) runs the
  load from external power when present, floats/charges the pack, and fails over
  to battery with no interruption. This is the "right" go-box answer if the
  budget allows.
- **Do NOT dumb-parallel** a bare external supply straight onto the battery
  Powerpole unless that supply is a proper **14.6 V-CV LiFePO4 charger** — an
  arbitrary 12–13.8 V bench supply will fight the pack's chemistry.

Also required regardless of the above:

- **An inline fuse** on the battery positive, close to the terminal.
- **102.4 Wh is over the 100 Wh airline carry-on limit** — flyable in the
  100–160 Wh band with approval, max two spares. Only matters if it flies.

## §6 — Shell size

The LFP8AH is 90 × 70 × 100 mm (body; ~120 mm to the top of the wiring). It, plus
the JUNEBOX module + an 8" faceplate, does not fit the current ~1150-class shell
— which is exactly why the battery is external today.

| Shell | Interior (mm) | Fit |
|---|---|---|
| Pelican 1150 (current class) | 184 × 118 × 84 | Battery will not fit inside. Today's problem. |
| Pelican 1300 | 235 × 181 × 155 | **Rejected** — see below. |
| **Pelican 1400** | 300 × 225 × 132 catalog · **305 × 230 × 100 measured** | 203 module + 2 × **50 mm** rails. See the survey below. |
| Apache 4800 (Harbor Freight) | 454 × 327 × 168 | **Rejected** — 1550-class, 2.8× the volume. See below. |

### Measured 2026-09-04 — the catalog numbers describe a different box

Shell in hand, tape on the interior:

Confirmed a genuine Pelican 1400, not one of the clones §6 allows.

| | Catalog | Measured | Pelican CAD |
|---|---|---|---|
| Interior W × D @ 75 mm | 300 × 225 | 305 × 230 *(tape @ 85)* | **305.0 × 231.4** |
| Base interior height | 132 *(incl. lid)* | **100** *(calipers)* | ~100 |
| Flat floor W × D | — | **270 × 200** | fillet ends ~20 mm |
| Corner radius | — | — | **~18 mm** (slight ellipse, 18.2 × 18.3) |
| Rib shelf | — | **2 mm proud, tops at 75 mm** *(calipers)* | 0.5 mm, ends ~82 |
| Rib positions | — | 3 per wall × 4 walls | **centre and ±74.5 mm** |

Three corrections follow:

- **The walls taper, gently — about 2.5°.** The interior grows from 299.6 × 226.0 at
  20 mm to 306.8 × 233.1 at 100 mm: 0.09 mm of width per mm of height. This doc got
  it wrong twice in one day, first reading the 270 mm floor as heavy draft, then
  declaring the walls vertical because that is exactly how 2.5° looks to the eye and
  to a cloth tape. It matters because **plate width is tied to the height it rides
  at** after all. At the 75 mm shelf the interior is **305.0 × 231.4**.
- **300 × 225 was never the usable number, in either direction.** It understates the
  interior at plate height by 5 mm and overstates the floor by 30 — it is the
  interior taken down near the fillet. §8 #4 expected ~285 mm usable and braced for
  rails as thin as 41 mm; the real answer is 50, wider than the 48 the layout was
  drawn against.
- **Base height is 100, not 102.** The catalog 132 includes the lid.

### Cross-checked against Pelican's own CAD

Pelican publishes STEP models; the 1400 base is mirrored at
[DIYsciBorg/Pelican](https://github.com/DIYsciBorg/Pelican) as `1400_step/1400-bot.STEP`
(SolidWorks 2007, dated 2009). FreeCAD is installed here as the flatpak
`org.freecad.FreeCAD`; slice it and read the interior profile off directly:

    flatpak run --filesystem=host --command=freecadcmd org.freecad.FreeCAD /abs/path/script.py

Same flatpak trap as OpenSCAD — absolute paths only, and it cannot see /tmp.

**What the CAD is good for:** the envelope, the taper, the ~18 mm corner radius, and
the rib *positions* (centre and ±74.5 mm on every wall — which is where the frame's
lap joints go). It also vindicated the tape: the model says 305.7 at 85 mm where the
tape read 305.

**What it is wrong about: the ribs themselves.** It draws them 0.5 mm proud running to
~82 mm; calipers on the actual case give **2 mm proud, topping out at 75 mm**. A
seventeen-year-old simplified model loses exactly the feature this build wants to hang
a plate on, and 0.5 mm would not be a shelf at all. **The part wins.** Use the CAD for
the box and the calipers for the ribs.

The rib shelf is the find that matters. §1 forbids penetrating the shell, so the
plate had to be carried *somehow*, and the assumption was printed feet off the floor.
The shell already carries it — twelve flat pads at a single height. §4 has the frame
that uses them.

### 1300 rejected on two hard numbers

- **The keyboard alone rules it out.** The Perixx is **230 mm** wide against a
  235 mm interior — 2.5 mm a side before corner radii or foam. It will not drop in.
- **No room for the side rails.** The two-rail layout (§4) needs ~263 mm across for
  module + rails on the edges where the I/O actually exits. At 235 mm the connectors
  would have to move to the top/bottom edges and the cables run the wrong way.

Its only win is depth (155 vs 132 mm) for standing the battery upright — moot,
since the pack lies on its 70 mm side anyway.

### 1400 vs Apache 4800

**Note: Apache *is* Harbor Freight's house brand** — these are two options, not
three. (An earlier revision of this doc wrongly listed them separately.)

| | Pelican 1400 | Apache 4800 |
|---|---|---|
| Price | ~$110–140 | ~$25–40 |
| Weight | ~2.0 kg, lighter | noticeably heavier |
| Warranty | Lifetime, unconditional | Limited, far weaker |
| Latches | Double-throw, excellent | Stiffer; some loosening reports |
| Seal | IP67, o-ring + auto purge | Claims IP67-class, o-ring + purge |
| Availability | Everywhere | HF store or their shipping |

### 4800 rejected — it is a 1550-class box, not a 1400 one

**Correction (2026-09-02):** an earlier revision of this doc sized the 4800 at
~330 × 235 × 133 and recommended it as a cheap 1400 equivalent with a little extra
width. That was wrong. Harbor Freight lists it at **17-7/8 × 12-7/8 × 6-5/8 in =
454 × 327 × 168 mm** and benchmarks it against a **Pelican 1550** — two classes up,
**24.9 L against the 1400's 8.9 L**.

| | Pelican 1400 | Pelican 1500 | Apache 4800 |
|---|---|---|---|
| Volume | **8.9 L** | 18.7 L | 24.9 L |
| Loaded weight | ~4.5 kg | ~6 kg | ~7 kg |
| Keyboard on the plate? | no | no (284 < 296.5) | yes |

The only thing the extra volume buys is the **integrated keyboard**, and that is a
cliff rather than a slope: it needs module 136.5 + keyboard 160 = **296.5 mm of
depth**, so the 1500 misses it by 12 mm and nothing below 1550-class clears it. So
the choice is 2.8× the volume and ~2.5 kg for exactly one feature.

**Not worth it here.** Total contents are ~2.9 L — in a 4800 the deck would be **12 %
full**, carrying 22 L of air to avoid setting a keyboard down. The 1400 already fits
module + rails + battery and still leaves **~3 L** for the SDR kit and antenna, which
is the whole of the storage requirement (§11). And the Perixx is a mini keyboard with
a built-in touchpad — a device meant to be positioned, so leaving it loose is
arguably the better ergonomics, as §2 and §9 concluded first time round.

**Decision: Pelican 1400 class.** Cheap equivalents in the same class (Apache 3800,
Monoprice/Condition-1 weatherproof) are fine substitutes if the Pelican brand is not
the point — verify the interior against 300 × 225 × 132 before buying, since HF
listings vary by revision and the 4800 error above came from exactly that.

Note §1's no-penetrations rule means the shell is never cut, so a Pelican's
lifetime guarantee survives this build intact — unusual for a deck, and worth
something if you buy new.

## §7 — Print vs buy

- **Print:** the plate **frame** (six members) and its **tiles** — screen bezel with
  the 173 × 118 window, left/right connector rails, back-channel fillers (§4) — plus
  the battery cradle (open above the terminals), a VESA-75 bracket to hang the module
  from the plate, and a fold-out tilt foot for the front lip.
  **Printer on hand: Creality Ender 3 + Sprite Pro direct extruder, 220 × 220 × 250
  nominal, ~215 × 215 usable.** Recorded 2026-09-04 — it had never been written down,
  and it is a hard constraint on every printed part in this doc.
- **Buy:** the shell (injection-moulded waterproof beats printed for the gasket),
  the panel-mount connectors below, the LiFePO4 charger, the fuse holder.
  **No buck converter** — the module is 12 V-native (§5).

- **Reference builds** worth reading first: Jake-Simek/Pelican-Deck (Pi +
  Pelican, self-contained, water-resistant I/O — closest to this) and the
  Printables cyberdeck tag for faceplate STLs to adapt rather than start blank.

### Parts to order (buy list)

Orderable now, in parallel with the shell. Quantities are for one deck. Search
strings are given rather than links, which rot; **the verify column is the part that
matters** — three of these have common traps (below).

| Qty | Part | Search string | Verify |
|---|---|---|---|
| 1 | SMA bulkhead, F–F | `SMA female to female bulkhead panel mount connector` | **SMA, not RP-SMA.** ⌀6.5 mm hole, ships with nut + washer. Left rail; matches the all-SMA RTL-SDR kit with no adapter. |
| 1 | SMA jumper | `SMA male to male cable RG316 15cm` | 100–150 mm. RG316/RG178 stays flexible. Bulkhead → dongle inside. |
| ~~2~~ **1** | USB-A dual, square flush ✅ | `Dual Ports Square USB 3.0 Panel Flush Mount Extension Cable with Buckle` | **ORDERED 2026-09-04.** Supersedes the 2× snap-in row. Both ports in one square housing = **one** cutout. Measure the opening and the buckle's panel-thickness range on arrival (§8 #5). Right rail. |
| 0 | Powerpole panel inlet | ~~`Powerwerx PanelPole1`~~ · round socket now **surplus** | ⚠️ **Do not buy.** PanelPole1 needs a 1-1/8" hole — no smaller than the round socket already ordered, and both are far too big for the rail. **Print a PP15-45 retainer instead** (~16 × 8.3 mm/pair). The ordered socket moves to the case sidewall. §8 #7. |
| 1 | Master switch ✅ | `16mm latching anti-vandal push button switch 12V 5A` | **ORDERED 2026-09-04, ⌀16 latching 5 A+.** Trap 3 avoided. SVG widened ⌀12 → ⌀16. Left rail, upstream of the module (§5). |
| 1 | Inline fuse holder | `ATC ATO inline fuse holder 12 AWG waterproof` | On battery **positive**, close to the terminal. |
| several | Fuses | `ATC blade fuse 5 amp` | **5 A** — sized for the ~2.5 A total draw (§5), not the Pi alone. |
| — | Wire | `14 AWG silicone wire red black` | Silicone stays flexible in tight bends; PVC goes stiff. |
| — | Powerpole contacts + housings | `Anderson Powerpole 30 amp contacts housings kit` | **30 A contacts for 14 AWG** (45 A contacts are for 12 AWG). Keep the bus uniform. |
| 1 | RJ45 keystone ✅ | `Cat6 keystone jack coupler` | **ORDERED 2026-09-04 — no longer optional.** Right rail gets a third cutout, 14.7 × 16.2 portrait, in a printed keystone frame. |

**The three traps**

1. **SMA vs RP-SMA.** Reverse-polarity SMA is the WiFi-router variant, physically
   incompatible with the RTL-SDR kit. Listings mix them and the photos look
   identical. Confirm the title says plain **SMA**.
2. **USB panel style changes the cutout.** §3's 26.5 × 12.3 mm assumes **snap-in**.
   The round **D-type / Neutrik-style** needs a different ~24 mm opening instead.
   Decide before the plate is cut.
3. **Switch current rating.** Many 12 mm anti-vandal buttons are rated only **2 A** —
   below the ~2.5 A continuous draw, meaning a hot switch and eventual failure. Use
   16 mm rated 5 A+, or a toggle rated 10 A. (The SVG currently draws ⌀12; widen it
   to match whatever is bought.)

**Optional / drop first if space or budget is tight**

- **RJ45 panel jack.** Ethernet is a home-provisioning convenience, not a field need
  — the Pi's own port is reachable with the lid open. If wanted, a **Cat6 keystone
  jack in a printed keystone frame** (~14.7 × 16.2 mm opening) is easier to source
  than an RJ45 panel coupler, and standardised.
- **The SMA run** (rows 1–2) — the deck is fully functional without the SDR.

**Already sorted, do not re-buy:** the barrel→Powerpole pigtail (fitted, §5) and the
12.8 V LiFePO4 pack. As a Powerpole user the operator likely already has contacts,
housings, crimper, wire and heat-shrink — **check the shack before ordering**. The
genuinely new items are the SMA bulkhead + jumper, two USB panel mounts, the panel
Powerpole, and the switch.

## §9 — Input device: prefer the wired Perixx over the BT keyboard

Operator has a **Perixx PERIBOARD-510H Plus** — a wired USB mini keyboard with a
**built-in touchpad and two USB hubs**. For this deck it beats the Bluetooth
keyboard on every functional axis, and the layout should be designed around it:

- **Wired USB** — no pairing dance at boot, no battery to keep charged. A go-box
  input device should work the instant the deck powers up. (The BT keyboard
  currently throws "Bluetooth keyboard connected" reconnect notifications; that
  goes away.)
- **Integrated touchpad** — gives a precise pointer for the work touch is poor
  at (fine qutebrowser clicks, gqrx/SDR sliders). This is what the software side
  was compensating for; a real pointer is simpler than link-hint gymnastics.
  niri's touchpad block is already staged (config.kdl §input) and stays inert
  until the device is plugged in.
- **Two USB hubs** — expands the deck's own port count for the RTL-SDR, a GPS,
  and the Flipper at once. Feed one hub port back to a faceplate USB-A jack.

Faceplate consequences:
- The keyboard well is sized for the **PERIBOARD-510H footprint** (a mini board,
  ~12–13 mm thick with X-scissor keys), not the slim BT slab. Measure the actual
  unit before cutting the well — §8.
- The keyboard plugs into a **right-rail panel USB-A jack**, not an internal port —
  it is lifted out and set in front during use (§10), so its cable must reach the
  outside of the plate. Its own two hub ports then extend the deck's port count at
  the operator's hand, which is where extra ports are actually wanted.
- No separate mouse needed, which keeps the slab uncluttered — the touchpad is
  the pointer.

## §10 — Operating position

The deck works like a **field radio laid flat on a surface — not a laptop.** The
screen faces *up*; you look down at it and touch it like a tablet on a table, with
the keyboard set in front. This is the direct consequence of §2's slab decision.

### Deploying

1. Set the case flat — table, tailgate, ammo can, lap, ground.
2. Flip the latches, open the lid. A 1400-class lid hinges at the **back** and stops
   near 100°, so it stands up behind the deck rather than folding away.
3. Lift the **Perixx** out and set it on the surface in front. It stays plugged into
   the right rail — you are unstowing it, not connecting it.
4. Run coax from the left-rail SMA to the antenna on its stand. Plug external power
   into the left-rail Powerpole if on shore power. Flip the master switch (§5: one
   switch brings up screen, Pi, SSD and fan together).

No assembly, nothing to prop.

### Posture

```
          lid stands ~100° behind
           ╲   (sun shade · wind/spray block)
            ╲________________
   screen    [   FACEPLATE   ]  ← look DOWN, touch here
   faces up ┌┴───────────────┴┐
            │ base: module,   │
            │ battery, SDR    │
            └─┬─────────────┬─┘
   tilt foot ▏└─────────────┘   ← front lip raised 15–20°
   ══════════════════════════════ surface
       [ Perixx keyboard ]   ← separate, in front
            operator  ▼
```

- **Screen up, reclined toward you.** Flat is fine for a quick lookup; for real work
  a **fold-out tilt foot** under the front lip kicks the plate up 15–20°, the way a
  radio's tilt bail does. That is how a slab gets a viewing angle without the
  clamshell hinge §2 rejected.
- **Touch-first geometry.** Reaching *down* at a reclined surface avoids the gorilla
  arm of a vertical panel. The Perixx touchpad covers the fine pointing that touch
  is bad at (qutebrowser links, SDR sliders).
- **The open lid earns its keep.** At ~100° behind the screen it shades the display
  from overhead sun and blocks wind/spray from the working side, without ever
  obstructing an upward-facing screen. Pop it off if it is in the way.

### Three modes it actually gets used in

- **Field desk** — case flat on the tilt foot, keyboard out front. FT8/digital,
  kiwix, maps. The primary mode.
- **Lap / no table** — case on the thighs, screen up, keyboard beside or on the front
  lip. Works *because* the screen is up and the keyboard is loose rather than hinged
  to a fixed angle.
- **Touch-only** — lid up, screen flat, stand over it and thumb through kiwix or maps
  without pulling the keyboard at all.

### What it is not

It will not stand up and face you like a laptop — that needs the screen in the lid,
ruled out for the "opens upside down" complaint and hinge fragility. The trade: it
lies flatter and touches better, at the cost of a tilt foot for viewing angle and a
keyboard placed in front.

**An Osborne-style vertical posture was considered and declined (2026-09-02).** The
same 1400 can stand on its hinge edge with the open lid flat as a foot, putting the
faceplate near-vertical at no cost in volume or weight. It buys a better angle for
long typing sessions, but the screen still sits only ~110 mm above the table (look
*down* 20–30°, the Osborne 1's known neck-strain flaw), and a vertical screen makes
the touchscreen gorilla-arm territory. **Decision: horizontal only.** Consequently
the battery cradle may be a gravity-fit pocket rather than a strapped one (§11), and
no wedge is needed in the print list (§7).

## §11 — Stowage

Contents total ~2.9 L against the 1400's 8.9 L, leaving **~3 L genuinely usable**
after fan clearance and cable runs. Enough for the SDR kit and then some.

Pelican publishes the 1400's depth split as lid 1.18 in (30 mm), bottom 4.00 in
(102 mm). **Measured 2026-09-04 the base is 100 mm**, and — more to the point — the
faceplate does not sit at the rim. It rides the rib shelf at **75 mm** (§4, §6), which
re-cuts every number in this section:

- **Under the plate: 75 mm**, not ~97. The module hangs 51 mm below it, so Zone B is
  **~24 mm** of air, not 45.
- **The battery must lie on its 90 × 100 face, 70 mm tall** — not the 90 mm-tall
  orientation assumed above, which no longer clears the underside of the plate. At
  70 mm it has 5 mm of headroom. Terminals point sideways in this orientation, so the
  cradle's clear pocket moves from above the posts to beside them.
- **Above the plate there is now 25 mm of recess**, and the keyboard takes it. Test
  fits give switch 1.5 mm proud and USB 2.0 against a 2 mm budget, so the switch was
  never the threat — **the SMA is, at 9.7 mm**, and it gets placed outside the
  keyboard's footprint (§4). **Zone C moves from the lid to the base**, and the lid
  becomes free storage for the SDR kit, coax and antenna.

### Zones

| Zone | Space | Holds |
|---|---|---|
| **A — back channel** | ~180 × 88 × 90 mm beside the battery | SDR dongle, coax coil, **antenna cylinder** |
| **B — under the module** | ~24 mm of air below the module, 203 × 136.5 footprint | flat, non-fragile items — adapters, spare coax, parts tray |
| **C — over the faceplate** | thin, full width, under the closed lid | the keyboard itself, notes, cheat sheets |

**Zone B has one rule: do not pack it solid.** The module's fan lives on its back
face and needs to breathe. Use the perimeter, leave the centre open.

### The short hazard, and why it is already handled

Bare telescopic antenna elements loose in the same channel as exposed battery
terminals is a dead short on a LiFePO4 cell — a fire, not an inconvenience.

**The antenna ships in a plastic cylinder case, which resolves this** as long as it
actually gets put back in the tube. Belt and braces:

- The battery cradle gets a **printed cover over the terminals** — open above for
  clearance (§8), closed against intrusion.
- Anything else metal-cased riding in Zone A (Flipper, adapters, tools) goes in a
  pouch or a divided tray, not loose.

### Suggested pack list

Given ~3 L: SMA↔BNC↔PL-259 adapters, spare fuses, a small multimeter, QLG2 GPS
puck, a headlamp, and a paper log book with pencil. That is the difference between a
computer in a case and an actual go-kit.

## §8 — Open, needs the operator's measurements before CAD

KNOWN (do not re-measure): JUNEBOX outer 203×136.5×51, VESA 75/100, 12V, own
fan, Pi+SSD inside · Perixx keyboard 230×160×23 · SMA antenna · Powerpole power.

DONE:

- ✅ **JUNEBOX active area = 173 × 118 mm** (measured 2026-09-02). The faceplate
  window in docs/design/faceplate.svg is now cut to this, centered in the 203×136.5
  module face. (Runs a hair taller than the 172×107 an 8" 1280×800 would predict —
  cut to the measured number, not the theoretical.)
- ✅ **Module I/O + power path** (photographed + confirmed 2026-09-02). Viewed from
  the front (screen toward you), I/O is on the **left and right edges** — power on
  the LEFT, USB/data on the RIGHT. So the faceplate gets **two rails flanking the
  screen**, not a single strip: power/AV down the left, data down the right.
  - *LEFT edge (display board):* `AUDIO` (3.5 mm), `HDMI` (full-size), `USB Type-C`,
    and `DC 12V` — a **barrel jack**.
  - *RIGHT edge (Pi):* **2× USB-A** (USB-3 blue stack), **Gigabit Ethernet** (RJ45),
    the Pi's USB-C, and the NVMe/fan.
  - **Power path is already solved and already on Powerpole.** The 12 V inlet is the
    barrel, but a screw-terminal→barrel adapter (green Phoenix block) with a
    **Powerpole pigtail** is already fitted. No barrel→PP pigtail to build. The
    faceplate's external Powerpole IN just parallels this same feed onto the bus.
  - Faceplate USB-A jacks extend from the Pi's 2× USB-A. The module's AUDIO/HDMI/
    USB-C stay at the module edge for occasional use; they need not reach the plate.

- ✅ **Miady LFP8AH = 90 W × 70 D × 100 H mm** (measured 2026-09-02; confirms the
  working estimate). **The 100 mm is the body only — terminals sit proud of it.**
  Add ~15–20 mm for the posts + Powerpole lugs + cable bend → **~120 mm to the top
  of the wiring** when standing upright. That still clears a 1400's 132 mm depth,
  but the margin is thin; laying the pack on its 70 mm side banks headroom if the
  cradle allows. The cradle must leave a clear pocket above the terminals — never
  let a lid or bracket press on the posts.

4. ✅ **RESOLVED 2026-09-04 — the shell is measured, and it is bigger than catalog.**
   **305 × 230 × 100** interior, vertical walls, flat floor **270 × 200** inside a
   ~17 mm fillet, and a **12-rib shelf at 75 mm**. The pessimistic case never
   arrived: rails go to **50 mm**, wider than the 48 the layout was drawn against,
   and the "move the SMA to a corner" contingency is dead. Full survey in §6; the
   frame that sits on the ribs is in §4.

   Two things this measurement overturned rather than confirmed. The flare from
   270 to 305 is a **floor fillet, not wall draft** — plate width does not depend on
   the height it rides at. And the plate does not need printed feet, because the
   shell's own ribs are a shelf. Both had been assumed the other way.

   *Depth resolved from spec (§11): lid 30 mm, base 100 mm measured — battery clears
   the base underneath the plate. Keyboard stowage is now open again in a good way:
   25 mm of recess above the plate against a 23 mm keyboard (§4).*

**All connectors ordered 2026-09-04.** That closes #6 and reshapes #5.

6. ✅ **Master switch = ⌀16**, latching, 5 A+. Trap 3 avoided. SVG widened.
   Vendor dimension sheet read 2026-09-04 — ⌀16.0 mounting hole confirmed, plus three
   numbers the doc did not have:
   - **Hex flange 17.8 mm across flats → 20.6 across corners.** The rail must clear
     20.6, not 16. Fine either way: ~10 mm spare per side at a 41 mm rail, ~14 at 48.
   - **32 mm body length.** Protrudes behind the plate; harmless in the rail (full
     base depth beside the module) but it rules out mounting the switch anywhere
     over Zone B's ~45 mm once wire bend radius is added.
   - **Screw terminals on 8.3 mm pitch.** ⚠️ The buy list specifies **14 AWG** for the
     bus. 14 AWG silicone into a terminal that small is a fight — plan on ring or
     spade lugs crimped on, or a short 16 AWG pigtail up to the first Powerpole.
     Do not just jam bare strands under the screw.
   ✅ **RJ45 keystone is in** — right rail carries three cutouts, not two.

7. ⚠️ **NEW — the Powerpole inlet may not fit the left rail.** The socket ordered is
   a round flip-cap type needing a **⌀30.5 mm** hole. Against the rail budget:

   | Part | Footprint | Plate left each side @ 48 mm rail | @ 41 mm rail |
   |---|---|---|---|
   | Switch flange | 20.6 | 13.7 mm | 10.2 mm |
   | USB flange | 25.4 | 11.3 mm | 7.8 mm |
   | **Powerpole hole** | **30.5** | **8.8 mm** | **5.3 mm** |

   The *hole* fits even in the pessimistic 41 mm rail, with 5.3 mm of plate each
   side — thin for a 4–5 mm printed part carrying a latching switch's push force
   nearby, but survivable. **The unmeasured number is the flange and flip-cap
   diameter**, which the photo shows is visibly larger than the hole. If it is
   ~40 mm, it does not fit a 41 mm rail at all, and barely fits 48.

   **RESOLVED 2026-09-04 — print the retainer, and move the socket outside.**
   *(Resolved as a direction. The retainer is **not yet modelled** — see the intake
   note at the end of this section for what has to be measured before it can be.)*

   There is no smaller commercial panel mount. The buy list's own suggestion, the
   Powerwerx **PanelPole1, needs a 1-1/8" (28.6 mm) hole** — 1.9 mm less than the
   socket already bought, and it still carries a flange and a rear nut. The whole
   PanelPole family is built around that hole. Swapping parts does not fix this.

   What does fix it is not buying anything. A **PP15-45 housing is 24.6 × 8.3 × 7.9 mm**
   (Anderson datasheet), so a bonded pair presents **~16 × 8.3 mm** to the panel —
   confirming §7's estimate exactly:

   | Option | Panel face | Area | Plate left @41 mm rail | @48 mm |
   |---|---|---|---|---|
   | Round flip-cap (ordered) | ⌀30.5 | 730 mm² | 5.3 mm | 8.8 mm |
   | Powerwerx PanelPole1 | ⌀28.6 | 641 mm² | 6.2 mm | 9.7 mm |
   | **Printed PP15-45 retainer** | **16 × 8.3** | **133 mm²** | **12.5 mm** | **16.0 mm** |

   **5.5× less hole**, and it turns the worst cutout on the plate into the smallest.
   Housings dovetail together and pin with a standard 3/32" roll pin, so the printed
   part is a pocket with a pin hole and a lip — no fasteners, no purchase, and it
   re-scales freely if the floor measures short.

   **The weather cap buys nothing here.** The faceplate sits *inside* the base, under
   the closed lid (§11 Zone C) — the Pelican's own gasket is the IP67 seal. A cap on
   the faceplate is sealing against weather that already cannot reach it.

   **So keep the socket, and put it where its gasket earns its keep**: through the
   **case sidewall**, as a second, external inlet. There the 30.5 mm hole is trivial
   (the wall is 300 mm long, not 41), and it does something the faceplate inlet
   cannot — **shore power with the lid shut**. That is the one genuinely new
   capability in this whole section. Sidewall drilling is irreversible on a £110+
   shell, so do it after the deck is working, not before.

5. ✅ **RESOLVED 2026-09-04 by test fit — cutout 21.5 × 24.5, web 2.0 mm.**
   Both coupons agree and they were independent: the size ladder is cut at a 2.0 mm
   web throughout and picked 21.5 × 24.5; the web ladder is cut at 23.5 × 26.5 and
   picked 2.0. The unit seats in the *smallest* rung of the size ladder, so the
   ladder bottomed out — a tighter opening might also work, but there is no reason to
   chase it: at a 50 mm rail, 21.5 leaves plate to spare and a smaller hole buys
   nothing. The 21.5 × 24.5 + 2.0 mm pair has not been printed *together* yet; that
   combination is the USB tile itself, so it gets verified on the first tile print.

   The reasoning that got here, kept because it generalises:

   ⚠️ **The bezel was measured, the cutout was not, and never would be.**
   Vendor sheet 2026-09-04: bezel **25.4 × 28.6 mm** (1" × 1-1/8"), **28.6 mm** tall
   overall, cable neck 19.05 mm. Comfortable in either rail width.

   **The bezel is not the cutout and cannot be.** A flush-mount bezel has to overhang
   the hole to seat against the panel — if the opening were 25.4 × 28.6 the part would
   drop straight through. The dimension lines on the vendor image land on the bezel's
   outer corners; below it the body steps in at a shoulder with four snap tabs. Neither
   the body cross-section nor the thickness those tabs will clamp is published
   anywhere, and no amount of further searching will surface them.

   **So stop looking and print for it.** `docs/design/coupons.scad` ladders the opening
   from a 2 mm-per-side inset to 0.5 mm (`usb_size`) and the web thickness across
   1.5–3.0 mm (`usb_thick`). Two 20-minute prints answer both questions by test fit,
   which is what §3 asked for in the first place. What was ordered is a
   **dual-port square flush-mount** unit with a buckle — not the 2× snap-in the buy
   list assumed. Two consequences, neither cosmetic:
   - **One square cutout, not two rectangles.** §3's 26.5 × 12.3 no longer applies to
     anything on this plate. The SVG carries a dashed ~29 mm placeholder; it is not a
     cut dimension. Calipers on the housing when it lands.
   - **The buckle sets a maximum plate thickness.** These snap-latch automotive parts
     are designed for sheet metal or dash plastic, typically **~1–3 mm**. A printed
     faceplate stiff enough to carry an 8" module wants **4–5 mm**. If the buckle
     will not close, the fix is a **local recess** — thin the plate to the buckle's
     range in a pocket around the opening, keeping full thickness everywhere else.
     Design the recess in from the start; it is painful to retrofit.

**The plate is no longer gated.** #4 closed with a tape and a CAD cross-check, #5
closed by test fit. What remains of #7 — the flange and flip-cap diameter of the round
Powerpole socket — sizes a *sidewall* hole that is deliberately the last operation in
the build (§8 #7), and the faceplate stopped depending on it the moment the printed
retainer replaced it.

So the connector table in §3, the layout in §4, and the SVG in
docs/design/faceplate.svg can be cut now. What is still open is the **rail coupon**
(SMA, switch, keystone) and the **retainer fit** — those set this printer's offset per
hole, not whether the design works.

### 8. ⚠️ NEW — the keystone enters but will not latch

The VCE Cat6A coupler **fits the 14.9 opening and will not click into it**. Width was
never the problem, so the width ladder could not have answered this however far it ran.

A keystone retains by hooking a fixed lip over the front of the panel and snapping a
sprung tab over the back. If it enters and does not catch, the open variable is the
**web that tab closes over** — which `rail` fixes at 2.0 mm for every keystone rung and
never varies. Same miss as the USB, where the size ladder found the opening and
`usb_thick` was the coupon that actually made it latch. **One ladder per axis of
failure, not one per part** — that is the lesson worth keeping from both.

`coupons.scad` gains a **`keystone`** part: width held at the 14.9 known to admit the
coupler, web laddered **1.0 / 1.4 / 1.8 / 2.2 / 2.6**, against opening lengths **16.2
and 16.8** — the second row in case the hook needs room to swing rather than a thinner
web. Ten cells, one print, 140 × 78 × 4.5, render-verified manifold.

If a cell latches, its web is the number and the keystone tile is cut to it. If none
does, the part wants something outside 1.0–2.6 mm and the next move is calipers on the
lip-to-tab distance, not a third ladder.

Nothing else is blocked by this. The keystone is one tile on the right rail, and tiles
are independently reprintable (§4); the rest of the plate can be cut while it is
settled.

### Coupons printed 2026-09-04 — the desk work is done

All three (`usb_size`, `usb_thick`, `rail`) are off the printer, in the faceplate's
own filament, nozzle and layer height. Nothing else can be resolved by reading a
vendor sheet: every number still open is a test fit or a tape measure, and both are
waiting on delivery.

**SUPERSEDED 2026-09-04 — the sidewall inlet is dropped, and nothing is drilled.**
The operator's call, and the right one. What the sidewall socket bought was shore power
with the lid shut; the deck only runs with the lid *open*, so that reduces to charging
in transit or storage. Against that: the one penetration of a shell §1 says is never
cut, on a case whose lifetime warranty and IP67 both currently survive this build.

- **Design: charge with the lid open**, through the faceplate's Powerpole inlet. No
  parts, no risk, and the loss is confined to charging while stowed.
- **Escape hatch: a flat pass-through laid across the gasket** while charging, removed
  after. Unsealed in use, but the operator is present in use. Fully reversible.
- **Rejected: replacing the pressure-equalisation valve.** The screw-in manual purge
  valve is a *Storm*-series part; the 1400 is a Protector with a press-fit valve, and
  the hole is too small for a bonded pair regardless. It would also trade away the
  anti-vacuum-lock function to gain nothing.

Two consequences. **The round ⌀30.5 socket is now surplus** — it has no role left on
the deck. And the faceplate's printed retainer becomes the **only** power entry, so the
PP15-45 housings stop blocking one feature and start blocking power entirely.

The measurements below are kept because they are what closed the question, not because
anything still needs them.

**Socket measured 2026-09-04: threaded barrel ⌀28.7, flange ⌀35.** The vendor's
⌀30.5 hole is confirmed sane — 1.8 mm of clearance on the barrel, with the flange
overhanging 2.25 mm per side. **Sidewall hole: 29–30.5.** Tighter is better for
concentricity but 30.5 is the published number and lands on common bit sizes. The
flip-cap was not measured and is larger than the flange; it only has to clear outside
the shell, where nothing constrains it. This remains the one irreversible cut in the
build (§1), so it stays last regardless.

**The 35 mm flange settles the faceplate question, on a new argument.** §8 #7 rejected
the socket on hole-vs-rail; at 50 mm rails that objection had weakened to 9.75 mm of
plate each side. What kills it now is the *keep-out zone*: the keyboard covers all but
the outer 37 mm of each rail (§4), and a 35 mm flange consumes essentially that whole
strip — while competing for it with the SMA, which at 9.7 mm proud has nowhere else to
go either. The printed retainer's 16 × 8.3 takes none of it.

**So the retainer route stands, and the housings become a blocking buy.** Nothing is
wasted either way: the internal bus is Powerpole and the sidewall inlet will want
contacts too.

**Intake 2026-09-04 — the housings did not arrive.** Only the round ⌀30.5 socket did.
The buy list carries "Powerpole contacts + housings" on the assumption a Powerpole user
already has them in the shack; that assumption is wrong here, so **PP15-45 housings,
30 A contacts and 3/32" roll pins are an outstanding buy**, and the faceplate's power
inlet is blocked on them — the one item on the plate that is.

This also reopens the round socket as a fallback rather than a reject. §8 #7 rejected
it against a 41–48 mm rail; the rails measured **50 mm**, so a ⌀30.5 hole now leaves
**9.75 mm of plate each side** rather than 5.3. That is no longer obviously unusable.
The flange and flip-cap diameter — never measured, and the reason #7 stayed open — is
what decides it, and the socket is in hand, so it can be settled now.

**The Powerpole retainer is a decision, not a part.** §8 #7 resolved *that* it should
be printed; nothing was ever modelled or printed, and an earlier revision of this
section wrongly said otherwise. It cannot be drawn responsibly yet either — the pocket
size comes from the `rail` coupon's PP ladder and the roll-pin position has to be
measured off a housing in hand. Both are intake tasks, and neither has been done.

INTAKE — the day the boxes land, in this order:

| # | Part | Tool | Number it closes |
|---|---|---|---|
| 4 | ✅ Pelican 1400 | *done 2026-09-04* | 305 × 230 × 100, ribs at 75 → **50 mm rails** |
| 5 | ✅ USB unit | `usb_size` | *done* — **21.5 × 24.5** |
| 5 | ✅ USB unit | `usb_thick` | *done* — web **2.0 mm** |
| 5 | USB unit | calipers on the buckle | *optional now* — the web ladder answered it empirically |
| 6 | ✅ switch, SMA | `rail` | *done* — **16.2** and **6.7** (+0.2 offset) |
| 8 | RJ45 keystone | `keystone` coupon | ⚠️ enters 14.9, will not latch — web ladder |
| 7 | ⛔ PP15-45 housings | *not in hand 2026-09-04* | blocked — only the round socket arrived; housings/contacts/pins must be bought |
| 7 | Powerpole socket | calipers on flange + flip-cap | sidewall hole only — no longer gates the plate |

#4 is done, and it set the rail width the coupon results are judged against — 50 mm,
so every connector in §3 clears comfortably and no fit result can force a relayout.
Write the winners into §3 and cut faceplate.svg to them.

Do **not** drill the shell sidewall for the external Powerpole inlet on intake day —
that stays last, after the deck is working (§8 #7).
