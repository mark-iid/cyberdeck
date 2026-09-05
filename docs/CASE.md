# Case & faceplate design

For the next enclosure. Written to be shopped and printed against, not admired.

**The computer is a self-contained module.** The display is a JUNEBOX 8"
1280×800 IPS 5-point touch unit (Amazon B0DX26BXPX) whose **backboard enclosure
houses the Raspberry Pi 5 itself** — plus, now, the NVMe SSD and heatsink. It
takes **DC 12 V** in, exposes HDMI / USB / power on the case, mounts via **VESA
75/100**, and carries **its own active cooling fan**. So the 200 × 137.5 × 44 mm
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

## §3 — Connector cutouts (test-fitted 2026-09-04 unless noted)

Print test coupons before committing the faceplate — filament shrinkage and slop
vary by printer, and RF connectors especially want a snug hole.

| Connector | Purpose | Cutout | Notes |
|---|---|---|---|
| **SMA** bulkhead | antenna feed (RECOMMENDED) | **⌀6.7 as printed** (6.5 nominal + 0.2) | Matches the all-SMA RTL-SDR kit with no adapter. Panel jack stays mated (coax to a stand), so the mating-cycle limit is moot. Add a flat/notch for anti-rotation. |
| **BNC** bulkhead | antenna feed (alt) | **~14 mm** round, keyed | Only if quick-swap at the panel matters; needs an SMA→BNC adapter for this kit. |
| **USB-A ×2, dual square** | data / peripherals | **21.5 × 24.5 mm**, local web **2.0 mm** | **Test-fitted 2026-09-04**, not from a vendor sheet — the sheet never had it. One housing, one hole. Bezel 25.4 × 28.6 overhangs ~2 mm per side. The 2.0 mm web is a rebate in the 4.5 mm tile, not a thinner tile. |
| ~~**DC barrel 2.1 mm**~~ | ~~12 V in / charge~~ | **not on the plate** | Vestigial. Power enters on Powerpole; the only barrel in the build is the module's own inlet, which already carries a Powerpole pigtail (§8 DONE). Kept as a row so it is not re-added by someone reading an old revision. |
| **RJ45 panel extension, screw-mount** | panel Ethernet | **~16.6 × 13.6** aperture + 2 × M3 | **Replaces the keystone, 2026-09-04.** Screwed through two mounting ears — **no snap, so plate thickness is irrelevant** and §8 #8 evaporates. Jack face 16 × 13, body ~21–27 wide, **37 mm ear-to-ear**, ⌀3 mounting holes. Mount **ears along the rail length**: 37 across a 39 mm tile would leave 1 mm. Mounts from *behind*, on **countersunk M3s through the tile** — not inserts, which need 6.7 mm of depth and the tile is 4.5 (§13 #3). Heads finish flush on the front. |
| ~~**Cat6A keystone coupler**~~ | ~~panel Ethernet~~ | ~~14.5 × 16.0~~ | **Superseded 2026-09-04.** Enters a 14.9 opening and will not latch: retention is a *rotational* snap against a moulded ~2.4 mm wall plate, so opening size was never the variable and two coupons were spent finding that out. Keep the part for a wall plate elsewhere. |
| **3.5 mm audio jack, panel extension** | headphones / powered speaker | **⌀6.2 drawn** ⚠️ **PROVISIONAL** | **NEW 2026-09-05.** Source is the module's own `AUDIO` socket on its **left edge** — same side as this rail, so the run is short. Added because the battery ends up 2.75 mm from the module's speakers and muffles them (§13 #13); this gives the sound somewhere to go. Sits at **y = 0**, in the 32 mm gap between the Powerpole and the rocker. **Not bought yet** — ⌀6.2 is a placeholder, not a measurement. Confirm the barrel thread diameter *and* the panel thickness range against a 4.5 mm tile before the left rail prints. |
| **Anderson Powerpole** | external 12 V IN | **16.2 × 8.5** printed retainer for a bonded PP15-45 pair | Measured 2026-09-04: the round socket is barrel ⌀28.7 / flange ⌀35 and is **surplus** — the sidewall inlet it was bought for is cancelled (§8 #7). The retainer is 133 mm² of hole against the socket's 730. Feeds the **A/B selector**, not the bus directly (§5). |
| **DPDT ON-OFF-ON rocker** | master power **and** source select | **28.7 × 21.2** opening (28.5 × 21 vendor + 0.2), web ⚠️ **untested** | **Replaces the ⌀16 anti-vandal button, 2026-09-04** — one control does both jobs (§5). Bezel **35 × 25.3**, stands **2 mm** proud, body **27.5 mm** deep. **6.3 mm spade terminals**, which take a 14 AWG crimp directly and delete §8 #6's problem. Mount with the **21 mm across the rail** (9 mm of tile each side); 28.5 across would leave 5.25 and is too thin. |
| ~~**16 mm anti-vandal button**~~ | ~~master power~~ | ~~⌀16.2~~ | **Deleted 2026-09-04**, superseded by the rocker above. Test fit gave ⌀16.2 (16.0 + 0.2) and that is what established this printer's offset, so the measurement survives its part. |

**Published dimensions govern; the offset is a printer correction, not a rival
number.** The rocker and the RJ45 extension both ship with properly dimensioned panel
data — 28.5 × 21 and 16 × 13 — and those are the openings the parts are engineered for,
so they are what the finished plate must *have*. The +0.2 below is how you get there on
this machine: draw 28.7, print 28.5. The operator's SMA and switch test fits are not
competing dimensions, they are the calibration that makes a drawn number and a real one
agree. Where a vendor publishes an opening, no ladder is needed at all — only the
offset. **The one number neither RJ45 image dimensions is the ear hole centre spacing**,
so that alone stayed provisional at 31 mm until calipers landed on it. **It is 26.5** —
31 forgot the 4 mm tray the plinth stands on (§13 #11).

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
panel needs no adapter anywhere**, and it is the smallest cutout (⌀6.7 as printed,
single hole). SMA's only real drawback, its ~500-cycle mating limit, does not apply
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
 │ [PP]  │   module 200 × 137.5 below           │[USB-A]│
 │ [⏻SW] │                                      │[RJ45] │
 └───────┴──────────────────────────────────────┴───────┘
 FRONT (operator)
          keyboard lifts out, sets on the surface in front
```

**Width budget: 200 (module, measured 2026-09-04) + 2 × 52 = 304, exactly.** In
practice the screen tile is drawn ~1 mm larger than the module all round, so the rails
come out **~51 mm** each. This stopped being the binding dimension the moment the shell
was measured — it came in wider than catalog, and the module came in *narrower* than the
203 this doc carried, so the rails gained 3 mm each over the drawn 48 and the "SMA moves
to a corner" contingency in §8 #4 is dead. Depth: **137.5** module + **91.5 mm** back
channel against 229.

**The module's own I/O sets which side is which** — power/AV exit its LEFT edge,
USB/Ethernet its RIGHT — so the plate mirrors it: power + antenna left, data right,
short cable runs on both. Keep each rail on a **shallow raised lip** so cables exit
sideways rather than up into the screen's sightline.

**Keyboard stays separate** (§9, §10). At 230 × 160 it cannot share the plate with
a 137.5 mm-deep module inside 229 mm of depth — integrating it would require a
1550/4800-class shell, ~2.8× the volume for one feature. It stows flat over the
faceplate at close and is set on the surface in front during use, which is better
ergonomics anyway: a mini keyboard with a touchpad wants to be positioned.

\* The module's 12 V barrel already carries the Powerpole pigtail (see DONE
list). The panel Powerpole IN does **not** parallel it — it feeds the **A/B selector**
(§5), which presents internal *or* external to the master switch, never both. Faceplate USB-A jacks are panel-mount
extensions off the Pi's right-edge ports.

### Construction — a frame on the rib shelf, tiles in the frame

*(Rib spacing of 0 and ±74.5 came from Pelican's CAD, which was wrong about rib height
and protrusion. **Verified against the real case 2026-09-04** — an 80 mm calibration bar
bridges two adjacent ribs. The positions are good; only the rib section was wrong.
The 12 × 6 frame section was hand-flexed at 80 mm and judged stiff enough, and ⌀4.2
takes an M3 heat-set insert — **the diameter only.** See §13 #3: the same coupon's holes
were 1.7 mm too shallow, and "the insert fits" did not reveal it.)*

**2 mm of ledge is enough, but only because the plate is trapped.** The rib inner
edges sit at 2 and 303, so the shelf opening is 301. A plate of width P has 305 − P
of lateral freedom, so if it slides fully to one side the thin side retains exactly
**P − 303 mm** of bearing:

| Plate width | Guaranteed bearing per side | Verdict |
|---|---|---|
| 303 | 0 | can lose the shelf entirely — no |
| 304 | 1.0 mm | drop-in, 1 mm total clearance |
| **304.5** ✅ | **1.5 mm** | chosen — 0.5 mm clearance, sand if tight |

**Biased oversize on purpose (2026-09-04).** A calibration bar printed 79.95 for a drawn
80.00, which is *inside caliper noise on a printed edge* — so the XY scale error is
**unknown, not measured**, and an 80 mm sample could not resolve 0.2 % over 304 mm
regardless. The bias is chosen for asymmetry of consequence: **too wide sands down in
minutes; too narrow loses bearing with no way to add material back.** Measure the first
printed member against the case before committing the other three.

The same bar remeasured at **6.05 for a drawn 6.00** (an initial 6.18 reading did not
hold). So the printer is dimensionally honest in all three axes, and no scale
compensation is applied anywhere.

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

**Under the plate: 75 mm.** The module stands **26.5 mm** off the 4 mm tray on its plinth
(§12), so its top face lands at 74.5. The battery does *not* fit under the plate at all —
it stands 90 tall and comes up through an open well (§13 #0).
Anything resting on the floor is bounded by the flat **270 × 200** inside the fillet,
not by 305 × 230.

**Above the plate: 19 mm** — a 100 mm base, less the 75 mm shelf, less the plate's
own 4.5 mm. The plate's top face sits at **79.5 mm**.

**The keyboard is 230 × 160 × 17** (Perixx drawing, 2026-09-04). §8 said 23 and §9 said
~12–13; both were wrong and the doc carried the contradiction for weeks. At 17 it lies
on the plate and tops out at **96.5 mm — 3.5 mm clear of the 100 mm rim**. So it stows
**entirely inside the base**, and the lid is genuinely free.

That 3.5 mm is also the **keep-out budget** under the keyboard's footprint:

| Part | Stands proud | Under the keyboard |
|---|---|---|
| Switch | **1.5 mm** | fine |
| USB | **2.0 mm** | fine |
| SMA | **9.7 mm** | no — lifts the keyboard 6 mm above the rim |

Centred, a 230 × 160 keyboard on a 304 × 229 plate covers x ∈ [37, 267], leaving the
outer **37 mm of each rail uncovered**, which a 50 mm rail gives connectors room to use.
**The SMA is placed outboard deliberately** — or back with the SDR and coax, where its
jumper wants to run anyway.

**The cable is the detail that bites.** It exits the keyboard's **top edge, centre**,
and plugs into a right-rail panel jack, so stowed it has to cross the plate. A ~4 mm
cable routed *under* a keyboard with 3.5 mm of headroom lifts it proud of the rim. The
locating lip therefore needs a **cable channel around the keyboard, not beneath it**.

The keyboard's own **two USB hub ports are on its right edge** (Perixx drawing) — worth
knowing for where it sits on the desk relative to the case.

Stowing in the base also beats the lid on retention: a keyboard lying on a plate under
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
- **USB budget, corrected 2026-09-04.** The earlier note counted the Perixx's two
  *downstream* hub ports as if they relieved pressure on the module's *upstream* ones.
  They do not — the constraint is upstream. The real accounting: the module's right
  edge exposes **2× USB-A**, and both are consumed by the dual panel unit's two
  pigtails, giving two panel jacks. The keyboard takes one of those, leaving one panel
  jack plus the keyboard's own two hub ports at the operator's hand. **The RTL-SDR
  dongle does not compete for these** — it runs off a Pi port free inside the module
  (operator, 2026-09-04), which is what makes the SMA bulkhead's internal jumper work.
  No hub is needed, but the margin is exactly zero: any further internal USB device
  needs one.
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

**RESOLVED 2026-09-04 — an A/B selector switch.** The two sources never meet. A
**DPDT** selector (or a Powerpole A/B switch) presents *internal* or *external* to the
master switch, switching **both conductors** so an external source with its own ground
reference cannot back-feed either. Chosen over the alternatives:

| Option | Why not chosen |
|---|---|
| **A/B selector** ✅ | manual switchover, and the pack does not charge while running external — accepted |
| Ideal-diode ORing board (Super PWRgate) | seamless and charges the pack, but ~£100+ and a pack-of-cards-sized board needing a home, wiring and thermal margin on the floor tray |
| Charger-only inlet | zero hardware, but the panel would accept *only* a 14.6 V CV LiFePO4 charger — no car socket, no bench supply, no solar controller |

The selector makes back-feeding **impossible by construction rather than by
discipline**, which is why it wins for a box that gets used tired and in the dark.

**One switch, not two (2026-09-04).** A **DPDT ON-OFF-ON rocker** does both jobs: its
three positions are **INT / OFF / EXT**. The ⌀16 anti-vandal button is deleted.

```
battery ── fuse ──┐
                  ├── DPDT ON-OFF-ON ── module 12 V barrel
panel PP IN ─ fuse┘        INT / OFF / EXT
```

Each source gets its own fuse close to its origin. Beyond the obvious simplification
this deletes a real annoyance: §8 #6 flagged that the anti-vandal button's **8.3 mm
screw terminals** would not take 14 AWG without lugs or a pigtail. The rocker's
**6.3 mm spades** take a 14 AWG crimp directly.

**Label the plate INT / OFF / EXT.** A rocker's two ON positions are not
self-explanatory, and this one is the difference between running off the pack and
running off shore power.

### The hole this exposed: nothing charges the pack

An A/B selector runs the load from *one* source and disconnects the other. **No position
ever connects the panel inlet to the battery**, so the internal pack has no charge path —
in either the two-switch or the one-switch version. §5's earlier line that "if runtime is
short, the fix is the panel Powerpole IN" is true for *extending* runtime by running on
shore power indefinitely; it is not a charging story, and this doc read it as one.

**Fix, and it needs no more switches: a charge pigtail off the battery**, run up into the
back channel and terminated in a Powerpole. A charger plugs straight onto the pack with
the lid open and nothing dismantled. It also keeps the charger where it belongs — talking
directly to the cells on its own 14.6 V CV profile, with no other load on the bus.

**Still do NOT dumb-parallel** a bare external supply onto the battery Powerpole. The
selector removes the temptation, but the rule stands for any future rewiring: an
arbitrary 12–13.8 V supply fights a LiFePO4 pack's chemistry.

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
| **Pelican 1400** | 300 × 225 × 132 catalog · **305 × 230 × 100 measured** | 200 module + 2 × **~51 mm** rails. See the survey below. |
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
cliff rather than a slope: it needs module 137.5 + keyboard 160 = **297.5 mm of
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
  the **floor tray** and its **module plinth**, the **battery cradle** (clamping a pack
  that lies on its 90 × 100 face, terminals *sideways*, so the clear pocket is beside
  the posts rather than above them), the **keyboard locating lip with its cable
  channel** (§4), the **Powerpole retainer**, a **keystone carrier**, and a fold-out
  tilt foot for the case's front lip. Load path and retention are §12.
  *(The old "VESA bracket to hang the module from the plate" is superseded — the module
  stands on the tray and the plate bears on it, not the reverse. §12.)*
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
| 1 | **Master + selector switch** | `DPDT ON-OFF-ON rocker 6 pin 16A` | **NEW 2026-09-04.** One part replaces both the anti-vandal button and the A/B selector (§5). Panel opening 28.5 × 21, 6.3 mm spades. Verify **DPDT** and **ON-OFF-ON**, not ON-OFF. The 16 A is an *AC* rating — fine at 12 V / 2.5 A, but it is not a DC figure. |
| ~~1~~ | ~~Master switch~~ ✅ | ~~`16mm latching anti-vandal push button`~~ | **Superseded 2026-09-04.** Bought and test-fitted; its ⌀16.2 result is what established this printer's +0.2 offset, so it earned its keep before being replaced. Keep as a spare. |
| 1 | **Battery charge pigtail** | `Anderson Powerpole pigtail 14 AWG` | §5: nothing else charges the pack. Runs off the battery into the back channel so a charger plugs on with the lid open. |
| 1 | Inline fuse holder | `ATC ATO inline fuse holder 12 AWG waterproof` | On battery **positive**, close to the terminal. |
| several | Fuses | `ATC blade fuse 5 amp` | **5 A** — sized for the ~2.5 A total draw (§5), not the Pi alone. |
| — | Wire | `14 AWG silicone wire red black` | Silicone stays flexible in tight bends; PVC goes stiff. |
| — | Powerpole contacts + housings | `Anderson Powerpole 30 amp contacts housings kit` | **30 A contacts for 14 AWG** (45 A contacts are for 12 AWG). Keep the bus uniform. |
| 1 | **3.5 mm audio panel extension** | `3.5mm stereo panel mount extension cable male to female` | **NEW 2026-09-05.** Left rail, y = 0. Verify **barrel diameter** (⌀6.2 is a guess) and that the **panel thickness range covers 4.5 mm** — a jack sized for sheet metal may not have enough thread. Female on the panel, male into the module's AUDIO socket. |
| 1 | **RJ45 panel extension** | `RJ45 panel mount extension cable screw mount female to male` | **NEW 2026-09-04**, replaces the keystone (§8 #8). Screw ears, not a snap. Verify it is a **female-to-male extension**, not a female-to-female coupler — the male end plugs straight into the Pi and deletes the internal patch cable. |
| ~~1~~ | ~~RJ45 keystone~~ ✅ | ~~`Cat6 keystone jack coupler`~~ | **Superseded 2026-09-04.** Will not latch into a printed plate; see §8 #8. Keep for a real wall plate. |
| 1 | **LiFePO4 charger** | `12.8V LiFePO4 charger 14.6V CV` | §7 always said buy one; it was never on this list. 14.6 V CV profile — a lead-acid charger will not fully charge the pack and a bench supply will fight it. |
| 1 | **2nd inline fuse** | `ATC ATO inline fuse holder` | One per source (§5). The external inlet needs its own, close to the panel. |
| — | **M3 hardware** | `M3 screws assortment` + `M3 heat set inserts` | **Structural, and absent until 2026-09-04.** The frame is lap-jointed with M3s, every tile is retained with them, the plinth bolts VESA-75, and the carriers mount from behind. Inserts **in hand**: ruthex RX-M3×5.7 (GE-M3X57-001) — 5.7 long, ⌀4.6 knurl, published hole **⌀4.0 × 6.7 deep min, 1.6 mm wall**. Frame joints want **M3 × 10** (M3 × 8 acceptable); tile and RJ45 screws want **countersunk** heads. |
| — | **6.3 mm spade crimps** | `6.3mm female spade connector 14 AWG insulated` | For the rocker's six terminals. Replaces the ring-lug workaround §8 #6 needed for the deleted anti-vandal switch. |

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
  — ~~the Pi's own port is reachable with the lid open~~. **Wrong, and it predates the
  faceplate.** The Pi lives *inside* the JUNEBOX and its ports are on the module's
  right edge, which sits below the plate once the plate is on the rib shelf. Opening
  the lid does not reach it; pulling the faceplate does. That is exactly why the panel
  connectors exist at all (§4: the USB-A jacks are extensions off those same buried
  ports), and why §7 marks the keystone **not optional**.
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
  **17 mm** thick — vendor drawing 2026-09-04, superseding both the ~12–13 guessed here
  and the 23 in §8), not the slim BT slab. Measure the actual
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

- **Under the plate: 75 mm**, not ~97. The module is **44 mm** thick (measured
  2026-09-04, against 51 from spec), so Zone B is **26.5 mm** of air, not 45.
- ~~**The battery must lie on its 90 × 100 face, 70 mm tall.**~~ **SUPERSEDED the same
  day by §13 #0**, which stands it **90 mm tall** on its 70 × 106 base and brings it up
  through an open well. Lying down needs 90 mm of floor behind the module and there are
  only 72.75. Struck rather than deleted: this doc carried both readings at once.
- **Above the plate there is 19 mm of recess**, but **the battery takes the back of
  it** — the pack stands **13 mm** above the plate through an open well (§13 #0), and its
  top is 94, six under the rim. That leaves ~143 mm of
  clear plate against a 160 mm keyboard. **Zone C is back in the lid**, reversing an
  earlier move made before the battery packing was worked out. The eggcrate foam stays;
  it preloads the stack against lifting (§4) and now retains the keyboard too.

### Zones

| Zone | Space | Holds |
|---|---|---|
| **A — back channel** | ~180 × 88 × 90 mm beside the battery | SDR dongle, coax coil, **antenna cylinder** |
| **B — under the module** | 26.5 mm of air below the module, 200 × 137.5 footprint | flat, non-fragile items — adapters, spare coax, parts tray |
| **C — over the faceplate** | thin, full width, under the closed lid | the keyboard itself, notes, cheat sheets |

**Zone B has one rule: do not pack it solid.** The module's fan lives on its back
face and needs to breathe. Use the perimeter, leave the centre open.

**Storage isolation comes free.** The rocker's centre OFF disconnects *both* sources,
so the deck can be stowed with the pack isolated without relying on a separate cut-off.

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

KNOWN: JUNEBOX outer **200 × 137.5 × 44**, all measured 2026-09-04 (spec said 51), VESA 75/100 M4 centred, 12V, own
fan, Pi+SSD inside · Perixx keyboard 230×160×**17** (vendor drawing 2026-09-04) · SMA antenna · Powerpole power.

DONE:

- ✅ **JUNEBOX active area = 173 × 118 mm** (measured 2026-09-02). The faceplate
  window in docs/design/faceplate.svg is now cut to this, centered in the 200×137.5
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
  - *Also on the module, and missing from this list until 2026-09-04:* an **OSD control
    cluster (Exit / Down / Up / Menu / Power) and speakers**, plus **two vents on the
    BACK face** either side of the VESA pattern — a heat-dissipation port and an air
    inlet (vendor port diagram).
  - **The control cluster can be buried.** Confirmed by the operator 2026-09-04: the
    12 V input brings up both screen and Pi, so the display's own Power button is not
    needed to wake it and no cutout has to reach it. This was the one failure mode that
    would have made the master switch look dead.
  - **Power path is already solved and already on Powerpole.** The 12 V inlet is the
    barrel, but a screw-terminal→barrel adapter (green Phoenix block) with a
    **Powerpole pigtail** is already fitted. No barrel→PP pigtail to build. The
    faceplate's external Powerpole IN feeds the **A/B selector** (§5) rather than
    joining this feed directly — an earlier revision said "parallels ... onto the bus",
    which is the one thing §5 says never to do to a LiFePO4 pack.
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
   - **Screw terminals on 8.3 mm pitch.** ⚠️ 14 AWG into a terminal that small is a
     fight. **Moot from 2026-09-04** — this switch is replaced by a DPDT rocker with
     6.3 mm spades, which take a 14 AWG crimp directly (§5).
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

### 8. ✅ CLOSED 2026-09-04 — replaced, not solved

**A screw-mount RJ45 panel extension retires the whole problem.** Two ears, two M3
screws, no snap anywhere — so panel thickness stops mattering and a 4.5 mm printed tile
is as good as a 2.4 mm moulded one. No coupon, no ladder, no third guess.

It deletes a second thing too: the part is an **extension cable, not a coupler**, so its
male plug goes straight into the Pi's RJ45. The "short Cat6 patch cable inside, Pi →
back of jack" that §3 called for is no longer a part. Same pattern as the USB unit, which
is also a panel-mount extension.

**Two numbers to confirm when it lands:**

- **Ear hole centre spacing** — the aperture and screw positions in the tile depend on
  it. **Drawn at 26.5 mm** — see §13 #11 for why it is not 31.
- **Cable length.** It must reach the module's right edge *and* carry §12's service
  loop — **+150 mm** over the direct run, or the plate cannot be lifted clear without
  unplugging at the Pi.

The history below is kept because the lesson generalises: **the fix for a part that will
not mount is sometimes a different part, not a better coupon.**

### 8a. ⚠️ SUPERSEDED — the keystone enters but will not latch

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

**ABANDONED before that print finished.** With the jack in hand: *none* of the openings
comes close to accommodating the sprung latch arm. The arm is not a tab that clears a
2 mm web, it is a spring designed to sit **behind an injection-moulded wall plate**,
outboard of a precise opening in ~2.4 mm of ABS. A printed rectangle in a 4.5 mm plate
with a 4 mm relief pocket cannot reproduce that, and a third ladder would only prove it
again. Two coupons were spent learning that the part was never a snap-into-plate part —
which is what §3 said in the first place: *"goes in a printed keystone frame, not
straight into the plate."* The coupons went the other way and should not have.

**The requirement, once the part is understood, is simple and printable:**

- panel **2.0–2.8 mm** thick at the opening (the clamped thickness — the one unknown),
- a plain **14.6 × 16.2** opening plus this printer's +0.2, so **14.8 × 16.4**,
- and **nothing behind it** — ~35 mm of clear air for the body, with the back face flat
  and unobstructed for ~5 mm around the opening for the hook and spring to grip.

Both numbers were already in §3 from the vendor sheet. Nothing new needed measuring;
what needed fixing was the model of how the part retains.

**The retention mechanism, from the spec rather than from the photo.** The
[keystone module](https://en.wikipedia.org/wiki/Keystone_module) standard gives a face
of **14.5 × 16.0 mm**, retained by *a diagonally inclined mounting flange on one side
plus a ramp and cantilever latch on the other*. Installation is asymmetric and
**rotational**: one end enters the opening until the ramp meets the plate's mounting
surface, then the jack rotates until the cantilever latch deflects and snaps. It is not
a symmetric clamp gripping a panel thickness, which is what an earlier revision of this
section assumed.

Two consequences that matter:

- **Too large an opening also prevents latching.** The 14.9 rung printed ~14.7 with the
  +0.2 offset and admitted the jack loosely — consistent with the latch having nothing
  to bite on. The failure was never simply "too small".
- **The standard does not specify plate thickness.** It fixes the face and the opening
  and leaves the rest to whatever ABS wall plates happen to be. So a printed carrier is
  guessing at the one number that matters, in a part whose insertion also needs
  rotational clearance.

**RESOLUTION — buy the reference geometry.** A 1-port keystone wall plate costs a couple
of pounds and settles all of it: it proves the mechanism, it yields measured numbers for
the opening and the thickness by calipers, and the rectangle containing its opening can
simply be **cut out and bolted into the right-rail tile** with two M3s. That is §7's own
rule applied consistently — buy the injection-moulded geometry, print the brackets.

`coupons.scad` carries a `keycarrier` part (three thicknesses, plain openings, open
behind) but **it should not be printed as drawn**: its openings were derived from the
vendor sheet plus a printer offset rather than measured off a real plate. If a printed
carrier is still wanted after the wall plate arrives, cut it to *those* numbers.

Nothing else is blocked by this. The keystone is one tile on the right rail, and tiles
are independently reprintable (§4); the rest of the plate can be cut while it is
settled.

### When a coupon is justified — and when it is waste

Three of 2026-09-04's prints were waste. Two were the keystone, printed twice against a
wrong model of how the part retains; one was the joint coupon, drawn with its halves
touching so OpenSCAD fused them into a single bar that tested nothing. The rules that
would have prevented all three:

1. **No coupon where the vendor publishes the number.** The rocker's panel opening and
   the RJ45's jack face are both published; those need the printer offset, not a ladder.
   Ladder only what is genuinely unknown — as the USB cutout was, and the printer's own
   offset was.
2. **Understand the retention mechanism before laddering a dimension.** Both keystone
   coupons laddered the right numbers against the wrong mechanism. No rung of either
   could have worked.
3. **Run `docs/design/check-stl.py` before slicing.** It reports the bounding box, bed
   fit, whether the part sits on z=0, and — the one that mattered — **how many
   disconnected solids the file actually contains**:

       python3 docs/design/check-stl.py build/plate/joint_test.stl --solids 3

4. **Put snap-in parts on small carriers, not on tiles.** A wrong web thickness should
   cost a three-minute insert, not a forty-minute rail. This is what §3 called for
   originally, and what the screw-mount RJ45 achieved by sidestepping snapping entirely.

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

**Intake 2026-09-04 — housings are in the shack after all.** The buy list's assumption
that a Powerpole user already owns contacts and housings was right; only the round
socket was *ordered*, which briefly read as the housings being absent. **Nothing is
blocked.** The retainer can be drawn as soon as the `rail` coupon's PP ladder gives the
panel opening and a housing gives up its roll-pin position.

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
| 8 | ✅ RJ45 | *replaced with a screw-mount panel extension* | no snap, no coupon — §8 #8 |
| 7 | PP15-45 housings | `rail` coupon PP ladder + calipers | panel opening for a bonded pair, and the roll-pin position for the retainer |
| 7 | Powerpole socket | calipers on flange + flip-cap | sidewall hole only — no longer gates the plate |

#4 is done, and it set the rail width the coupon results are judged against — 50 mm,
so every connector in §3 clears comfortably and no fit result can force a relayout.
Write the winners into §3 and cut faceplate.svg to them.

Do **not** drill the shell sidewall for the external Powerpole inlet on intake day —
that stays last, after the deck is working (§8 #7).

## §12 — Mechanical scheme: what carries what, and what stops it moving

Added 2026-09-04. The doc had a dimensional scheme and no load path; every part's
position was specified and nothing said what held it there. This section exists because
the operator asked how it fits together and stays together, and the honest answer was
that nobody had said.

### The inversion: heavy things sit on the floor

§7 used to call for a "VESA bracket to hang the module from the plate."

**The module weighs 417 g** (14.7 oz, measured 2026-09-04) — not the ~1.5 kg this
section assumed when it argued for the inversion. So the structural case was
**overstated by 3.6×**, and hanging it from the plate would probably not have failed.
The inversion still stands, for the reasons that survive the correction: a plinth sets
the module's height *exactly* (which a bracket has to be shimmed to do), it lets the
plate bear on the module rather than the reverse, and the tray has to exist anyway to
locate the battery — which at ~1 kg is the heaviest thing in the case and is on the
floor regardless.

**A printed floor tray** sits in the flat **270 × 200** floor. The ~17 mm fillet all
round means a tray cut to ~265 × 195 **cannot slide** — trapped on four sides, no
fastener, nothing bonded to a shell §1 says is never cut. Same trick as the plate on
the ribs. Printed in sections for the 215 × 215 bed.

The tray carries:

- **A module plinth, 26.5 mm tall**, bolted to the module's **VESA 75 × 75** (M4).
  Nominally 31 (75 − 44), drawn **0.5 short on purpose** — not to compensate for the
  printer, which measures accurate in Z, but against **over-constraint**. The plate is
  meant to land on twelve ribs *and* on the module, and those two supports must agree to
  a fraction of a millimetre or it rocks. Any positive error here lifts the plate off its
  ribs entirely. Drawn short, the module always lands slightly low and **a strip of foam
  tape on its top face** takes up the gap — a compliant centre support rather than a
  rigid one competing with the ribs. *A plinth
  here is simply a printed pedestal: the module cannot sit on the floor, because its
  screen has to finish level with the rib shelf, so it stands on a block that lifts it
  to exactly that height and bolts down through the VESA holes.*
- **The battery retention** — pack standing **90 mm tall**, gripped on its 100 mm axis
  by two printed blocks, one of which is a full-height shroud over the terminals
  (§14 #3). Not a four-walled cradle: that needed 77 mm of floor and there are 72.75.
- **Back-channel bays** for the SDR, coax coil and antenna, so they are not three loose
  objects in a box.

**The plinth must be a pillar, not a pad.** The module's two vents — a heat-dissipation
port and an air inlet — are on its **back face**, which points *down* in this design
(§8). A solid pad under it suffocates the module. The VESA pattern is central and the
vents sit either side of it, so a central pillar clears both by construction — and the
operator has cut **additional vents into the module's own back cover** (2026-09-04; the
shell is untouched, §1 intact), which makes the pillar-not-pad rule matter more, not
less. The **26.5 mm** gap beneath becomes a **plenum**, and the tray must keep a path from
it to the back channel rather than walling it off with the battery cradle.

### The plate then bears on two things

With the module's top face at exactly 75 — and **flat**, confirmed 2026-09-04 — the
plate rests on **the twelve ribs at its perimeter and the module's top face at its
centre**. Far stiffer than a perimeter-only shelf, and the plate now carries only itself
and the keyboard.

### The rail TILE is 39 mm, not 51 — and it kills the round socket

Drawing the frame surfaced this. The 51 mm "rail" is the zone from the plate edge to
the module; **12 mm of it is frame**, so the rail *tile* — the part connectors are
actually cut into — is **(280 − 202) / 2 = 39 mm**.

| Part | Footprint | Tile left each side |
|---|---|---|
| SMA | 6.7 | 16.2 |
| Powerpole retainer | 16.2 | 11.4 |
| Switch flange | 20.6 | 9.2 |
| USB | 21.5 | 8.8 |
| **Round Powerpole socket flange** | **35** | **2.0 — unusable** |

Earlier reasoning that the ⌀35 flange "fits comfortably in a 50 mm rail" was measuring
the zone, not the tile. It does not fit. **The printed retainer was the right call for
a reason that had not been found yet** — and this is exactly the class of error that
only appears when geometry is drawn rather than described.

### Frame and tile thicknesses, and what they cost

The frame must be *taller* than the tiles, because a tile needs a ledge to land on and
that ledge cannot hang below the frame — the module's top face is right there at 75.
Frame height therefore trades directly against what can ride above the plate:

| Frame | Ledge | Tile | Plate top | Recess left above it |
|---|---|---|---|---|
| 4.5 | — | 4.5 | 79.5 | 20.5 — but no ledge is possible |
| **6.0** ✅ | **1.5** | **4.5** | **81.0** | **19.0** |
| 8.0 | 3.5 | 4.5 | 83.0 | 17.0 |

**Chosen: 6 / 1.5 / 4.5, tiles flush with the frame top.** The ledge only carries a tile
*edge*; the module carries the middle through **2 mm of foam tape** — not the 0.5 this
section used to quote, which was the frame-to-module gap, not the tile-to-module one
(§14 #4).

*This table used to be scored on "keyboard top" and "clear of the rim", from when the
keyboard lay on the plate. It does not any more — §11 moved it to the lid, and §14 #4 is
the consequence.*

### What holds it down

✅ **RESOLVED 2026-09-05 — a TPU preload strip replaces the keyboard as the spacer.**
The diagnosis below stands; the fix is at the end of this section.

Nothing holds the plate until the lid closes. It is trapped sideways by the walls with
0.5 mm of clearance across the width and 0.9 down the depth, but invert the case and the
whole assembly lifts off its ribs.

**The foam was the retention** — *and it worked because the keyboard was the spacer.*
Keyboard on the plate at 81 + 17 = 98, two under the rim, lid foam bearing on it, load
straight down into the plate and onto the ribs. One preloaded stack.

**Taking the keyboard off the plate removed the middle of that argument.** What is left:

| | Height | Below the 100 rim |
|---|---|---|
| plate top | 81 | **19 mm** |
| battery top | 94 | 6 mm |

The lid foam now meets **the battery** first, 13 mm before it reaches the plate. Foam
will deform around it, but foam has shear stiffness as well as compressive — it bridges a
19 mm step rather than conforming to it. So the plate gets *some* preload near the front,
far from the battery, and little near the back. **Partial, and unquantified.**

The pack is also now the part taking the lid-closing load, which nothing chose.

**§11 argues against its own answer.** It says the base beats the lid on retention —
"a keyboard lying on a plate under a closed lid cannot fall out when the case is opened,
which a lid-mounted one can" — and then puts the keyboard in the lid anyway, because the
battery leaves ~143 mm of clear plate against a 160 mm keyboard. Both statements stand;
nothing reconciles them.

**Putting it back is not available.** The clear plate runs from the front edge to the
battery well: 143.5 mm. The keyboard needs 160 either way round, since 230 is longer
still. It is short by 16.5 mm and no orientation fixes that.

| Item | Held against sliding by | Held against lifting by |
|---|---|---|
| Floor tray | the floor fillet, four sides | the module and battery bolted to it |
| Module | VESA bolts into the plinth | same |
| Battery | two blocks on its 100 mm axis, bolted to the tray | the blocks, and the plate around its well |
| Plate | case walls, 0.5–0.9 mm clearance | **two TPU preload strips**, below |
| Keyboard | ⚠️ **in the lid, retention unspecified** | ⚠️ same |

### The fix: two TPU strips, on the side frame members

**Printed, not cut foam.** The height is repeatable, and the stiffness is a slicer
setting rather than a shopping trip — the operator stocks TPU.

**12 × 190 × 20, print two.** Each sits on a *side frame member*, whose 12 mm band runs
from the opening edge out to the plate edge. That band is clear of every connector,
because those are all on the rail tiles inboard of it — the strips need no cutouts and
foul nothing.

**Where the load goes is the whole point.** The strips sit **directly over the three side
ribs** at y = 0 and ±74.5. The plate is carried at its perimeter, so preload belongs
there; a pad in the middle would only press on the module, which is already bolted down
and needs no help. 190 mm long so it clears the R18 corners, which begin at ±97.25.

**Drawn solid on purpose.** Print in TPU at ~10 % gyroid, two perimeters — it behaves
like firm foam. Modelling a lattice would freeze the stiffness into the geometry, where
it cannot be tuned; in the slicer it is one number.

**20 mm against a 19 mm recess**, so the lid squeezes it 1 mm. If the latches will not
close, reprint at 19 or 18. It is a ten-minute part, which is the other argument for
printing it rather than cutting it.

**Still open:** how the keyboard is retained *in the lid*. §11's objection — that a
lid-mounted item can fall out when the case is opened — is unanswered, and a cut pocket
in the lid's foam or a strap is the likely answer.

### Service loops — the detail that ruins an afternoon

**Every panel connector's cable runs from the plate down to the module below it**: two
USB extensions, the Ethernet patch, the SMA jumper, and the 12 V run to the selector
and master switch. Lift the plate and you pull on all of them.

So each needs a **service loop** long enough to lift the plate clear of the rim and set
it beside the case — call it **+150 mm** over the direct run — with somewhere for the
slack to sit when closed. That is a design input for the tray's cable channels, and it
is the kind of thing discovered at assembly if it is not drawn in.

### Keyboard cable

It exits the keyboard's **top edge, centre**, and reaches a right-rail jack. Stowed, it
crosses the plate. A ~4 mm cable routed *under* a keyboard with 3.5 mm of headroom
lifts it proud of the rim, so the locating lip carries a **channel around the keyboard,
never beneath it**.

## §13 — Open items

Audit of 2026-09-04. Everything here is either undecided, undrawn, or unverified.

### Blocking

0. ✅ **RESOLVED 2026-09-04 — module shifted forward, battery stands in an open well.**
   Resolution at the end of this item. The problem as found:

   | | |
   |---|---|
   | Flat floor | 270 × 200 → y −100 … +100 |
   | Frame opening | 205 deep → y −102.5 … +102.5 |
   | Screen tile at the front of it | y −102.5 … **+37** |
   | Module beneath | y −101.5 … **+36** |
   | **Floor left behind the module** | **64 mm deep** |

   The Miady is 90 × 70 × 100 and only two orientations clear the 75 mm shelf:

   - **lying, 70 tall** → footprint 90 × 100. Needs **90 mm**. Short by 26.
   - **standing, 90 tall** → footprint 70 × 100. Needs **70 mm**. Short by 6, *and* 90
     is taller than the 75 mm shelf, so it only works in an **open** back well where it
     projects into the plate's 19 mm recess.

   **What broke it was the frame.** §4's original layout computed the back channel as
   225 − 136.5 ≈ 88 mm and the battery fitted. The frame's 12 mm section at each edge
   took 24 mm of depth that the earlier arithmetic never had, and the channel fell to
   65.5. This doc has carried "battery on its 90 × 100 face, terminals sideways" since
   this morning; it is not achievable.

   Options, none free:

   1. **Stand the battery and shift the module forward.** The module may sit under the
      *front frame* — only its 173 × 118 active area must stay inside the opening, and
      there is 9.75 mm of bezel to spend. That buys ~10 mm, giving ~74 mm against the
      70 needed. It requires the back well to be open (no tile) with the pack standing
      proud of the plate, which collides with the keyboard unless the keyboard sits
      forward of it.
   2. **A different pack.** ~102 Wh in a 60 × 250 × 70 envelope is not a hard ask, and
      the back channel is 270 mm wide and almost entirely empty.
   3. **Battery outside the case**, which is where it is today and what §6 set out to
      fix.

   **RESOLUTION — narrow the front frame member, shift the module forward, stand the
   pack.** The blocker was not the frame's width but its **ledge**: 12 mm of section
   plus a 10 mm ledge means usable tile starts 22 mm in, and the window cannot sit over
   a ledge. So the **front member alone** goes to 8 mm with a 5 mm ledge; sides and back
   stay 12 and keep the section the operator hand-verified as stiff enough.

   | | |
   |---|---|
   | Opening front edge | −106.5 |
   | Front ledge inner edge | −101.5 |
   | Window front, 1 mm margin | −100.5 |
   | Module front edge | **−110.25** |
   | Module back edge | **+27.25** |
   | **Floor behind it** | **72.75 mm** |

   **The pack is 90 × 70 × 106**, terminals on the 100 axis adding 6 mm (measured
   2026-09-04 — §8's 15–20 mm estimate was pessimistic). Standing **90 tall on a
   70 × 106 base** it needs **70 mm** of depth: fits with **2.75 mm** to spare. The wire
   bend projects along the 106 axis, which runs across 270 mm of width. It tops out at
   94 against a plate top of 81, so it stands **13 mm above the plate** through an open well — 6 mm
   below the rim.

   **Consequence: the keyboard returns to the lid.** With the pack proud, the clear span
   in front of it is ~140 mm against a 160 mm keyboard. §11's move to the base, made
   this morning on a 19 mm recess, is reversed. Not all loss — it **deletes the 2 mm
   keep-out entirely**, so the SMA, rocker and USB may sit anywhere on the rails, and the
   keyboard locating lip and cable channel stop being parts.

   The only orientation that would have kept the keyboard on the plate needs a pack under
   70 mm tall, and nothing in this capacity class is — the dominant form factor is the
   SLA replacement at 151 × 65 × 95, whose terminals are on the large top face and which
   therefore does not fit this case in any orientation at all.

1. ✅ **Ethernet — closed by replacing the part** (§8 #8). A screw-mount RJ45 panel
   extension: no snap, no panel-thickness dependency, and it deletes the internal patch
   cable too. Confirm ear spacing and cable length on arrival.
2. **Partly drawn as of 2026-09-04.** `docs/design/plate.scad` now carries the frame,
   the splice, the screen tile, a rail blank and a joint coupon — all render-verified
   manifold and all inside the Ender's 215 × 215:

   | Part | Size | Note |
   |---|---|---|
   | `member` | 152 × 114.5 × 6 | ×4, each an L carrying one corner |
   | `splice` | 70 × 10 × 4 | ×4, notched for the rib under each joint |
   | `screen_tile` | 202 × 139.5 × 4.5 | prints in **one piece** |
   | `rail_blank` | 39 × 139.5 × 4.5 | ×2, cutouts still pending |
   | `joint_test` | 80 × 12 × 10.2 | print this first |

   `docs/design/chassis.scad` carries the floor side:

   | Part | Size | Note |
   |---|---|---|
   | `plinth` | 85 × 85 × 30.5 | skeleton, four VESA bosses on a rib ring |
   | `tray` | 132.5 × 195 × 4 | ×2 halves, split at x=0, bridged by the plinth |
   | `cradle` | 129 × 77 × 20 | locates the pack's base; the plate's well catches its top |
   | `back_left` / `back_right` | 86.25 × 74.25 × 4.5 | fillers either side of the battery well |

   **Still undrawn: the Powerpole retainer** — it needs the roll-pin position off a
   housing, because a plain pocket cannot resist an unplugging pull and the pin is the
   only feature on a PP15-45 that can. Also undrawn: the tilt foot. The **keyboard lip
   and cable channel are deleted**, not pending — the keyboard is back in the lid.

   **`docs/design/faceplate.svg` is superseded and still wrong** — 300 × 225 with 48 mm
   rails and the module at x=48. Delete or regenerate it.

### New, and the same shape as two earlier misses

9. ⚠️ **The rocker is a snap-into-thin-panel part.** Its drawing dimensions a 0.8 mm
   step on the snap tab; switches of this style expect sheet metal or ~1 mm dash
   plastic, and the rail tile is 4.5. This is the third part in the build that retains
   by clipping to a panel thinner than the plate — the USB (solved), the keystone
   (still open), and now this. The opening is *published* (28.5 × 21), so unlike the
   keystone only one axis is unknown: **the web left by a local rebate**. One ladder,
   0.8 → 2.4, in `coupons.scad` as `rocker`.

14. ✅ **RESOLVED 2026-09-05 — the Powerpole hole was not a hole.** It was written
   as `cube([16.2, 8.5, TILE_T+2], center=true)` translated to z = 0. Centring in
   x and y is what was wanted; the same call also centres in **z**, so the cut
   spanned −3.25 … +3.25 in a 4.5 mm tile and **left 1.25 mm of material across
   the top**. Found by rebuilding the rails from a table and differencing the old
   mesh against the new: the volumes disagreed by **172.125 mm³**, which is
   16.2 × 8.5 × 1.25 exactly.

   Nothing could have caught it. `check-stl.py` sees a bounding box; the rail
   assertions check *where* cutouts sit, not whether they go through. A blind
   pocket and a through hole are the same shape from above.

   Every through-cut now goes through one `through()` module, so a cut cannot be
   accidentally blind. **Both rails are now drawn from their feature table** —
   `LEFT_FEATURES` and `RIGHT_FEATURES` — rather than the table sitting beside
   hard-coded geometry and agreeing only with itself, which is what the previous
   revision did and is the same fault as the plinth and the cradle.

   `build.sh` also now treats OpenSCAD's *"Ignoring unknown module"* as a
   **failure**. It is normally a warning, and it means geometry silently vanished
   while the STL still wrote and still looked plausible — it caught a deleted
   `rebated()` module during this very change, which would have printed rails
   with no rebates for the rocker and the USB.

12. ✅ **RESOLVED 2026-09-05 — the battery cradle did not fit, and did not need
   to.** Writing ten cross-part assertions (§13 #11) turned up four faults, all
   on the battery, all invisible to a per-part check:

   | | Was | Should be |
   |---|---|---|
   | Cradle depth needed | 77 | fits in **72.75** |
   | Cradle bolts, as the cradle drew them | (±60.5, 32.5/97.5) | — |
   | Cradle bolts, as the tray drilled them | (±40, 38/92) | **one shared list** |
   | Cradle back edge | y = 103.5 | flat floor ends at **100** |
   | Pack top | 90 (doc) / 98 (drawn) | **94** |

   **The depth.** Behind the module's back edge at +27.25 the flat floor runs to
   +100, so the battery gets 72.75 mm. The pack is 70. A four-walled cradle
   needs 70 + 1 of slip + two 3 mm walls = **77**. It overran by 4.25, and its
   back edge climbed 3.5 mm up the corner curve, so it could never have sat flat.

   **It was buying a constraint the case already gives away.** Front-to-back the
   pack is trapped between the module in front and the curve behind, with 2.75 mm
   of play. Only the 106 mm axis is unconstrained. So the cradle is now **two end
   blocks** gripping that axis — 11 × 70 × 20 each, print two. It went from a
   129 × 77 × 20 tub to a pair of small blocks, and the depth problem vanished.

   **The height.** The old cradle put a 4 mm floor under the pack for nothing,
   standing its top at 98 with 2 mm under the rim. Sitting on the tray it tops
   out at **94** — 13 mm above the 81 mm plate, 6 mm under the rim. §13 #0's "9 mm
   above the plate" was measured from the case floor and never counted the tray.

   **Still open, and a real question:** the module's back edge carries the
   on-screen-display buttons and the speakers (§13 #7), and the battery now
   stands 2.75 mm from them. The speakers fire into a wall and the buttons cannot
   be reached. See §13 #13.

13. ⚠️ **OPEN — the battery blocks the module's buttons and speakers.** 2.75 mm
   between the module's back edge and the pack. Options, none free:

   - **Accept it.** Set the display up once and never touch the buttons; lose the
     speakers to a muffled cavity. Costs nothing.
   - **Move the module forward.** The active area has ~6 mm of slack before it
     runs past the frame opening, but the module body would then reach y = −116
     and the case wall is at about −115. Buys 4 mm at most, and tightly.
   - **Turn the module 180°** so the buttons and speakers face the *front* channel
     under the narrowed front frame member. Costs a re-plan of every cable run.

   Needs a decision before the frame is printed, because option 2 moves the
   opening.

11. ✅ **RESOLVED 2026-09-05 — the plinth was 4 mm too tall, and a checker that
   looks at one part at a time could never have said so.** `PLINTH_H` was 30.5,
   from `75 − 44 − 0.5`. That arithmetic puts the plinth on the case *floor*. It
   stands on the **4 mm tray** — which is the entire reason it exists, to bridge
   the seam between the two tray halves. Real stack: `4 + 30.5 + 44 = 78.5`
   against a 75 mm shelf. The module would have stood **3.5 mm proud**, lifting
   the plate off all twelve ribs onto the module alone — precisely the failure
   the deliberate 0.5 mm undersize was introduced to prevent. **Now 26.5.**

   Two more of the same shape, found by looking for them:

   - **Plinth/tray bolts never matched.** Plinth drilled `(0, ±37.5)` local; the
     tray drilled `(±20, …)`. Nothing compared the two patterns. Worse, the
     plinth's pair at x = 0 sat exactly on the tray seam and would have bolted
     into the gap, holding neither half.
   - **The battery height was measured from the floor.** The pack stands on the
     cradle floor on top of the tray, so its top is `4 + 4 + 90 = 98`, not 90.
     It projects **17 mm** above the 81 mm plate, not the 9 this doc claims in
     §13 #0 — with 2 mm to the rim. See §13 #12.

   **The common cause, and the fix.** `check-stl.py` checks a part *in
   isolation*: bounding box, bed fit, z = 0, solid count. Every error it has
   caught was that kind. Every error it has **missed** was a *relationship
   between two parts* — a stack-up, a bolt pattern, a mating thickness. Those
   are sums that nobody added up, and no amount of re-reading catches a sum you
   did not know to take.

   So the shared numbers now live once, in **`docs/design/deck.scad`**, with the
   agreements written as `assert()`. An assertion failure stops OpenSCAD dead
   and **no STL is written** — a wrong part becomes unprintable rather than
   printed and then noticed. Verified by regression: restoring `PLINTH_H = 30.5`
   fails `"module stack does not reach the rib shelf"` and produces no file.

   **`docs/design/build.sh`** now builds every part and checks it, so no STL can
   go stale against the source. It immediately found one: `frame_full.stl` had
   been sitting at 304.0 since the source moved to 304.5.

10. ✅ **RESOLVED 2026-09-05 — the insert holes were 1.7 mm too shallow, and the fit
   test would never have caught it.** The operator's inserts are **ruthex RX-M3×5.7**
   (GE-M3X57-001), and the bag publishes the hole:

   | | Published | Was drawn | Now |
   |---|---|---|---|
   | Insert length | 5.7 | — | — |
   | Knurl OD | 4.6 | — | — |
   | **Hole ⌀** | **4.0** | 4.2 → prints 4.0 | unchanged ✅ |
   | **Hole depth** | **6.7 min** | **5.0** ❌ | **6.7** |
   | Wall around | 1.6 min | 4.0 (12 mm member) | unchanged ✅ |

   The diameter was right **by luck** — 4.2 drawn prints at 4.0 on this machine (§6
   offset), which lands exactly on ruthex's number. The depth was not. A 5.7 mm insert
   pressed into a 5.0 mm hole either stands 0.7 proud or goes home by splitting the
   1 mm skin on the *visible* face.

   **This is the same shape as the keystone.** The operator reported "they fit", which
   is true and was the wrong question: the hole accepted the insert. Whether the insert
   was seated in enough material is a different fact, and only the vendor drawing has
   it. §7's rule — *no coupon where the vendor publishes the number* — applies to
   fasteners too, and this doc read the fit instead of the bag.

   **Fix, without moving the plate.** 6.7 of hole plus 1 mm of skin wants 7.7 mm of
   material; the member is 6, and thickening the frame costs the headroom §11 has only
   3.5 mm of. So each hole gets a **local ⌀8 × 1.7 boss on the underside**, where there
   is 75 mm of nothing. The splice grew to **12 × 5** with a **⌀8.6 × 2.0 counterbore**
   that swallows the boss and still clamps on the flat around it. Screws: **M3 × 10**.

   **Second casualty: the RJ45 ears.** 6.7 mm of depth cannot exist in a 4.5 mm tile at
   all, and a boss under the tile would hold the ear off the face it clamps against. So
   the ears are now **plain through-holes, countersunk on the front** — flush heads, and
   it works whether the ears arrive threaded or plain-with-a-nut. This also removes a
   dependency: the mounting no longer needs a number the part has not delivered yet.

### Needs a measurement, not a decision

3. ✅ **Module measured 2026-09-04: 200 × 137.5 × 44.** Neither the vendor's
   200 × 136 nor this doc's 203 × 136.5, and the thickness was **44, not the 51 spec
   claimed** — 7 mm, straight into the plinth, which is now **26.5 mm** tall (§13 #11).
3b. ✅ **Both the active area and the VESA square are perfectly centred** in the
   200 × 137.5 face (operator, 2026-09-04). So the geometry is arithmetic, not
   measurement:

   | Derived | Value |
   |---|---|
   | Module centre | 100, 68.75 |
   | VESA hole centres | **±37.5 both axes** → x 62.5 / 137.5, y 31.25 / 106.25 |
   | Window margin left/right | **13.5 mm** |
   | Window margin top/bottom | **9.75 mm** |

   Nearest VESA hole sits 31.25 mm from the bottom edge, so the plinth pillar fits
   inside the outline with room. Still wanted: the **hole thread** (VESA 75 is
   normally M4) and roughly where the two back-face vents fall relative to the
   pattern, so the pillar misses both.
4. ✅ **VESA positions — resolved by the centring above.** Outstanding only: thread
   size, and vent positions relative to the pattern.
5. ✅ **Top face is flat** (operator, 2026-09-04) and **VESA is M4**. §12's "plate bears
   on the module at its centre" stands — no relief pocket over the glass needed.
6. ✅ **Module weight: 417 g** (14.7 oz). Light — see §12, where it corrects an
   assumption by 3.6×.
7. ✅ **OSD cluster and speakers are on the module's TOP edge** (operator,
   2026-09-04) — which, laid flat screen-up with ports left, is the **back** edge,
   facing the back channel. Two consequences: the tray's back-channel bays must stay
   ~10 mm clear of that edge rather than packing against it, and the speakers end up
   firing **up into the open channel** with the lid open, which is the best place they
   could have been.
8. ✅ **Keyboard cable is 5 ft (~1520 mm)** (operator, 2026-09-04). Far longer than the
   ~300 mm the deployed position needs, so **~1.2 m is permanent slack**. It gets a
   dedicated coil bay in the back channel on the floor tray, not an afterthought — and
   the cable must reach that bay *without* passing under the keyboard, which has only
   2 mm of headroom (§4).

### Resolved today, recorded for the trail

- §1 and §2 still describe a faceplate that "carries the screen, keyboard and
  connectors". **It does not** — the keyboard has been separate since §6, and those two
  sections were never revisited. Left as-is deliberately: they are the founding
  argument, and §4/§9/§10 are the current design. Read them in that order.
- Keyboard thickness was stated as 23 in §8 and ~12–13 in §9. It is **17**.
- The USB budget claim in §5 was wrong; corrected there.
- The power topology contradicted itself between §4 and §5; resolved to an A/B
  selector in §5.


## §14 — Adversarial audit, 2026-09-05

Written by attacking the plan rather than restating it. Findings are ordered by what
they cost if ignored, not by how hard they were to find. **Nothing here is a fix** —
several of these are decisions, and they are the operator's.

### A. Load-bearing gaps — things drawn as if solved that are not drawn at all

1. 🔴 **No tile has any fastening. None.** `screen_tile`, both rails and both back
   tiles are plain plates sitting in a **1.5 mm** ledge. The buy list says "every tile
   is retained with [M3s]"; the geometry has not one hole.

   This is not cosmetic. **The RJ45 and the USB unit are screwed to the rail tile**, so
   every gram of force from plugging and unplugging a cable goes into a tile that
   nothing holds down. Pull an Ethernet lead and the tile comes up out of its ledge with
   the connector still attached. Same for the Powerpole, which is the one thing on the
   plate that gets a deliberate hard pull.

2. 🔴 **The frame has no joint fasteners drawn either.** `member()` is
   `intersection(frame_full, cube)` and nothing else — no insert seats, no bolt holes.
   The four L pieces meet at the centre of each side and are supposed to be tied by a
   notched `splice` underneath, but only the *coupon* (`joint_bar`) has ever had the
   seats. **As drawn, the frame does not join.** The splice exists; the thing it bolts
   into does not.

3. 🟠 **The battery terminal cover was deleted by my own cradle redesign.** §11 names
   loose antenna elements beside bare LiFePO4 terminals as "a fire, not an
   inconvenience", and specifies "the battery cradle gets a **printed cover over the
   terminals**". The cradle is now two end blocks with a wire notch. **The cover is
   gone and nothing recorded that it went.** §11's Zone A still stores the antenna in
   the same channel as the terminals.

### B. Contradictions the document is still carrying

4. 🟠 **The doc cannot decide where the keyboard lives, and the plate's retention
   depends on the answer.** §11 says "Zone C is back in the lid". §12's table says
   "Keyboard on the plate", lists "Keyboard — held against sliding by *locating lip in
   the tiles*" (no such lip is drawn), and the frame-thickness table is scored on
   "Keyboard top 98.0, clear of the 100 rim 2.0".

   **The consequence is structural, not editorial.** §12 answers "what holds the plate
   down?" with *"the foam is the retention — keyboard on the plate, lid foam above it,
   lid compresses the stack."* Take the keyboard off the plate and that argument has no
   middle. The plate top is at 81 and the rim at 100, so the lid foam must reach **19 mm
   down** to touch the plate at all — and it will meet **the battery at 94** first, six
   millimetres under the rim. As drawn, the pack takes the lid preload and the plate may
   take none.

5. 🟡 **§11 still specifies the battery in an orientation §13 #0 overturned** —
   "must lie on its 90 × 100 face, 70 mm tall" — three bullets above the note that
   stands it 90 tall. Both are in the same section.

6. 🟡 **Stale arithmetic, all downstream of the plate top moving to 81 and the tray
   appearing under everything:**

   | Says | Is |
   |---|---|
   | recess above the plate 20.5 | **19** |
   | battery stands 9 above the plate | **13** |
   | Zone B, air under the module, ~31 | **26.5** |
   | plate depth 229 | **230.5** |

### C. Assumptions never tested

7. 🟠 **"Thermal is a non-issue" rests on a premise the faceplate invalidated.** §5
   argues the case "only has to not block the module's vents", and §1 backs it with
   "never runs sealed — open lid = open air". **Both predate a plate that covers the
   entire opening.**

   The module's vents face **down** into the plenum. Trace the air out of it: the front
   is closed by the screen tile, both sides by the rail tiles, the top by the module
   itself. What is left is the ring around the battery in the back well — **1 mm each
   side, 1.75 front, 2.5 back** — and whatever creeps out of the 0.25 mm gap between the
   plate edge and the wall, between ribs.

   I have not measured this and cannot say it overheats. What I can say is that
   **nothing in the plan was designed to vent it**, the sentence that dismissed the
   problem was written about a different geometry, and the operator has *cut extra vents
   into the module's back cover* — which increases flow into a space that may have
   nowhere to send it. Deliberate slots in the tiles would be nearly free to add now and
   impossible to add after the plate is printed.

8. 🟡 **The module's input voltage range is recorded nowhere.** It is a "DC 12 V"
   barrel. A LiFePO4 pack sits at ~13.3–13.6 V straight off charge, and a 14.6 V CV
   charger on the pigtail will hold the bus at **14.6 V** — which the module sees
   directly if the rocker is left on INT while charging. Nothing in §5 prevents that,
   and no label warns against it. **One number from the vendor closes this.**

9. 🟡 **Nothing fuses the charge pigtail.** §5 puts an inline fuse "on the battery
   positive, close to the terminal", and then taps a charge pigtail off the battery. If
   that tap is upstream of the fuse, the pigtail is an unfused conductor running into
   the back channel — the same channel §11 flags for loose metal.

### D. Known-open, restated so they are not lost

10. Powerpole retainer — undrawn, still needs the roll-pin position.
11. Rocker web thickness — `RK_WEB = 1.2` is a guess; the coupon was never printed.
12. RJ45 ear spacing — `RJ_EAR = 31`, provisional.
13. Audio jack diameter — `AUDIO_D = 6.2`, a placeholder, not a measurement.
14. Tilt foot — §10 wants 15–20°, §1 forbids attaching to the shell, nothing is drawn.
15. `docs/design/faceplate.svg` — superseded, still wrong (300 × 225, 48 mm rails).

### Drawn 2026-09-05 — findings 1, 2 and 3, and four more they uncovered

**1 — Tile fastening now exists.** `TILE_SCREW` in `deck.scad` holds **fourteen**
positions in plate coordinates. The frame grows a ⌀8 × 6.2 boss and an insert seat
under each; every tile filters the same list by its own footprint and cuts a
countersunk M3 clearance hole. Neither side re-lists anything, so they cannot
disagree — and an assertion requires **every seat to be claimed by exactly one tile**,
which caught two of them belonging to nobody while it was being written.

No screw sits on the **front** ledge: it is `LEDGE_WF` = 5 wide and a ⌀8 boss will not
fit, which is now an assertion rather than an omission.

**The screen tile is deliberately left unfastened**, and this is a decision, not an
oversight. It is 202 wide against a ledge whose inner edge is at ±130.25, so **it does
not reach the frame anywhere except its front lip**. It is bounded on all four sides by
the frame and the other tiles, carries no connector and takes no cable pull, and leaving
it loose is what makes the screen serviceable without dismantling the plate.

**2 — The frame now joins.** `JOINT_SEAT` holds sixteen positions, four per joint at 14
and 26 either side, and `frame_full()` carries a seat at each. `member()` inherits them.

*And the members were wrong in a second way.* The front rail is `FRAME_WF` (8) and the
other three are `FRAME_W` (12), so **a back member is not a front member turned round**.
`member()` drew only the +x+y quadrant, so building from it would have produced four
back members and a frame that could not close. It now takes a `front` flag and there are
two parts: `member` and `member_front`, two of each, mirroring one of each in X.

**3 — The terminal shroud is back.** One of the two cradle blocks is now a closed box:
outboard face, both ends and top closed, open toward the pack, wire out through a notch
at the bottom. It runs the full height of Zone A (74.5) because that is the only height
that is safe without knowing where the terminals sit.

*And drawing it found the cradle was gripping the wrong thing.* **106 is the envelope,
not the body** — a 100 mm case with 6 mm of terminal on one end. Both blocks closed on
±53, so the terminal-end block was squeezing **the posts and their wires**, not the
case. Blocks now close on the body at ±50.5, and the back tile's battery well follows the
off-centre envelope (−51 … +57) instead of a centred 108, which is why `back_left` and
`back_right` are now **89.25 and 83.25**, not twins.

**5 — CORRECTED, same day: the terminal geometry was already on record and this doc
had it wrong.** The operator's description — posts on the **top** face in the pack's
natural upright orientation, toward the **front**, one **left and one right**, standing
**8 mm** up — resolves everything the shroud needed, and each clause flips when the pack
is laid on its side:

| Upright | Laid down, 90 vertical |
|---|---|
| posts on the TOP face | on a **vertical end face** |
| stand 8 mm up | stick out 8 mm **sideways**, along x |
| "left and right" across the 90 | **at different heights**, spread over the 90 |
| "toward the front" across the 70 | still toward the deck's front |

**The middle row is the one that matters.** The two posts are not clustered — they sit
near opposite ends of the pack's 90 mm dimension, which is now vertical. *There is no
short cover that covers both.* The full-height shroud was drawn out of ignorance and
turns out to be the only thing that works.

**8 mm is not the envelope either.** §11 already budgets "~15–20 mm for the posts +
Powerpole lugs + cable bend", and the shroud has to contain the lugs and the bend, not
just the posts. Cavity is **20 mm** (`BATT_WIRE_W`), sourced from §11 rather than
invented, which puts the shroud at 31 × 70 × 74.5.

**The terminals go on the LEFT.** The left rail carries the rocker and the Powerpole
inlet, so that is the short side for the power run. The pack turns freely about its
vertical axis, so this is a build decision, not a measurement — now recorded as one.

Knock-on: the battery well is off-centre by 20 mm rather than 6, so `back_left` and
`back_right` are **69.25 and 89.25**. The tray's back-channel window moved from x 66 to
**84**, because the shroud bolts at 77.5 and the old window left no material under it.

✅ **SETTLED at 8** (operator, 2026-09-05). The apparent conflict with the earlier
"extends to 106" was not a conflict: **the posts stand 8 mm free and flex down to 6.**
So 6 is what they measure with something already pressing on them — which is exactly
the state the clearance exists to prevent, and therefore the wrong number to build
from. 8 is the resting height, and the only one that guarantees nothing touches them.

**4 — The foam tape is 2 mm, not 0.5.** §12 quotes 0.5 as the gap the tape on the
module's top face closes. That is the **frame**-to-module figure. What the module
actually carries is the **tiles**, and they sit `LEDGE_H` = 1.5 higher than the frame's
underside, so the real gap is **2.0**. Now derived as `FOAM_T` rather than quoted.

### What else the audit changed

The insert-wall assertion was checking `FRAME_W` (12) when the binding case is the
**front** member at `FRAME_WF` (8). It now checks the narrowest member. It still passes —
2.0 mm of wall against ruthex's 1.6 — but it was passing for the wrong reason, and
`BOSS_D` is 8 against a front member of 8, so there is no margin left to spend there.

### §14 #7 — plenum venting: DECIDED 2026-09-05, vent the back tiles

**The plenum was never the problem; the back channel above it was.** Tracing the air
properly: the module's vents face down into the plenum, and the plenum's back is **wide
open to the back channel across the full 200 × 26.5** — there is no wall between them.
The dead end is one storey up. The back channel is capped by the two back tiles, and the
only way out was the ring around the battery:

| Path | Open area |
|---|---|
| terminal side | blocked by the shroud below 74.5 |
| other side | 1 × 70 = **70 mm²** |
| front of the pack | 1.75 × 100 = **175 mm²** |
| behind the pack | 3.25 × 100 = **325 mm²** |
| plate edge to wall, between ribs | 0.25 mm slot |

**Grilles in both back tiles: 5 slots in `back_left`, 7 in `back_right`, 4 × 51 each —
2,448 mm².** Roughly four times the total above, and in open air rather than in a
crevice around a battery.

    module vents -> plenum -> back channel -> GRILLE -> open air

**Back tiles and nowhere else,** and the reason is geometric rather than aesthetic:

- **Not the screen tile.** It sits over the module's *top* face. Slots there open into
  the 2 mm foam gap and connect to nothing.
- **Not the rails.** They reach the plenum only through a 1 mm slot beside the module,
  and they are already crowded with connectors.

Slots are **4 mm** so nothing of consequence drops through, and inset 12 mm from every
edge, which clears the tile screws by construction — with an assertion saying so, since
"by construction" is what the plinth thought too.

**Still open from §14, untouched because they are decisions:** the keyboard/retention
contradiction (4), the stale arithmetic (6), the module's input voltage range (8, and
see below) and the charge pigtail's fuse (9).

### §14 #8 — input voltage: SEARCHED 2026-09-05, no published tolerance exists

The Amazon listing and the JUNEBOX user manual both say **"DC 12V Input"** and stop
there. No range, no tolerance, no current, no wattage. The manual does confirm the unit
will alternatively run from **USB-C** — note this is the *display board's* Type-C on the
left edge, not the Pi's on the right, which §5 forbids powering through.

Elecrow's 8-inch 1280 × 800 touchscreen looks like the same panel and **is not the same
product** — it is a 5 V microUSB display drawing 3.79 W. Its numbers are not this unit's
and were not borrowed.

**So the mitigation is procedural, and the hardware for it already exists.** The 14.6 V
case only arises while charging, and the rocker's centre **OFF** isolates *both* sources
from the module. **Charge with the switch at OFF.** Label the plate accordingly, next to
INT / OFF / EXT.

Resting voltage is a separate and milder question: a full LiFePO4 sits at ~13.3–13.6 V,
which is inside what a 12 V-input device normally tolerates — 13.8 V is the automotive
norm — but that is an inference about the class, **not a verified fact about this unit**.
One question to the seller settles it and costs nothing.
