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
| **SMA** bulkhead | antenna feed (RECOMMENDED) | **6.5 mm** round (±0.1) | Matches the all-SMA RTL-SDR kit with no adapter. Panel jack stays mated (coax to a stand), so the mating-cycle limit is moot. Add a flat/notch for anti-rotation. |
| **BNC** bulkhead | antenna feed (alt) | **~14 mm** round, keyed | Only if quick-swap at the panel matters; needs an SMA→BNC adapter for this kit. |
| **USB-A** snap-in | data / peripherals | **26.5 × 12.3 mm** rectangular | Adafruit/McMaster snap-in panel-mount cable. Two of these. |
| **DC barrel 2.1 mm** | 12 V in / charge | **~8 mm** round (0.31") | Panel jack, up to 8 mm panel thickness. |
| **Anderson Powerpole** | external 12 V IN | Powerwerx PanelPole1/2, or a printed PP15-45 retainer (~16×8 mm/pair) | The external-power inlet. Internal battery also on Powerpole. See §5 on coexistence. |
| **Rocker/toggle switch** | master power | **~12 mm** round or 13×19 mm rocker | Between battery and the buck converter. |

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

Sized for a 1400-class plate: **300 × 225 interior, ~290 × 215 usable** after the
gasket lip and corner radii.

```
 BACK ────────────────────── 300 mm ──────────────────────
 ┌──────────────────────────────────────────────────────┐
 │  ▒▒▒ BATTERY on side ▒▒▒  │  SDR · coax · antenna     │  back channel
 │  ~118 × 90, terms inboard │  cylinder                 │  ~88 mm deep
 ├───────┬──────────────────────────────────────┬───────┤
 │ LEFT  │                                      │ RIGHT │
 │ RAIL  │        8" TOUCHSCREEN                │ RAIL  │
 │ 48 mm │          173 × 118                   │ 48 mm │
 │ [SMA] │        (1280 × 800)                  │[USB-A]│
 │ [PP]  │   module 203 × 136.5 hangs below     │[USB-A]│
 │ [⏻SW] │                                      │[RJ45] │
 └───────┴──────────────────────────────────────┴───────┘
 FRONT (operator)
          keyboard lifts out, sets on the surface in front
```

**Width budget is exact: 203 (module) + 2 × 48 (rails) = 299 of 300.** This is the
binding dimension — if the measured floor comes in under ~285 mm the rails thin or
the SMA moves to a corner (§8).

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
| **Pelican 1400** | 300 × 225 × 132 | Fits exactly: 203 module + 2 × ~48 mm rails. |
| Apache 4800 (Harbor Freight) | 454 × 327 × 168 | **Rejected** — 1550-class, 2.8× the volume. See below. |

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

- **Print:** the faceplate/bezel (with the 173 × 118 window), the left/right
  connector rails, the battery cradle (open above the terminals), a VESA-75 bracket
  to hang the module from the plate, and a fold-out tilt foot for the front lip.
- **Buy:** the shell (injection-moulded waterproof beats printed for the gasket),
  the panel-mount connectors, the LiFePO4 charger, the fuse holder.
  **No buck converter** — the module is 12 V-native (§5).
- **Reference builds** worth reading first: Jake-Simek/Pelican-Deck (Pi +
  Pelican, self-contained, water-resistant I/O — closest to this) and the
  Printables cyberdeck tag for faceplate STLs to adapt rather than start blank.

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

## §11 — Stowage

Contents total ~2.9 L against the 1400's 8.9 L, leaving **~3 L genuinely usable**
after fan clearance and cable runs. Enough for the SDR kit and then some.

### Zones

| Zone | Space | Holds |
|---|---|---|
| **A — back channel** | ~180 × 88 × 90 mm beside the battery | SDR dongle, coax coil, **antenna cylinder** |
| **B — under the module** | ~77 mm of air below the module, 203 × 136.5 footprint | flat, non-fragile items — adapters, spare coax, parts tray |
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

STILL NEEDED — one measurement, with a tape on the shell:

4. **The chosen 1400-class shell's REAL usable interior.** Catalog interior
   overstates it — gasket lip, radiused corners, ribs. Measure the **flat inner
   floor**, and separately the **base-vs-lid depth split** (that decides whether the
   keyboard stows in the lid or lying on the faceplate — §11 Zone C). Pass/fail
   thresholds for the layout as drawn:
   - **Width ≥ 285 mm** → rails stay ~40 mm+. Below that, thin the rails or move the
     SMA to a corner (it is the optional connector anyway). *This is the binding
     dimension: 203 + 2×48 = 299 of 300.*
   - **Depth ≥ ~113 mm** → battery-on-side (90) + keyboard (23) stack at close.
   - **Back channel ≥ ~75 mm** → battery lying 70 mm deep plus terminal clearance.

Once those four exist, the connector table in §3, the layout in §4, and the SVG
in docs/design/faceplate.svg become a parametric plate.
