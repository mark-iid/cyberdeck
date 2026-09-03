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

```
 ┌───────────────────────────────────────────────┐
 │  [BNC ant] [USB-A][USB-A]          [⏻ switch]  │  ← connector strip (rear lip
 │                                     [DC][PP]   │     or top border)
 │   ┌───────────────────────────────────────┐   │
 │   │                                       │   │
 │   │            7" TOUCHSCREEN             │   │
 │   │            1280 x 800                  │   │
 │   └───────────────────────────────────────┘   │
 │   ┌───────────────────────────────────────┐   │
 │   │            KEYBOARD WELL               │   │
 │   └───────────────────────────────────────┘   │
 └───────────────────────────────────────────────┘
```

Put the connector strip on a **raised rear lip** (a short vertical wall at the
back edge of the faceplate) so cables exit horizontally toward the operator's
far side and route out over the open lid, rather than straight up into the
screen's sightline.

## §5 — Power & cooling (mostly solved by the module)

The self-contained 12 V module removes the two hardest parts of a go-box build:

- **No power conversion.** The module is 12 V-native and does its own internal
  12 V→5 V for the Pi. The 12.8 V LiFePO4 feeds it **directly** — no buck
  converter to size, no 5 V rail to build, no brownout-throttle risk from an
  undersized regulator. This is the cleanest possible power path.
- **No cooling to design.** The module has its own active fan (and the Pi inside
  carries the Geekworm active cooler — DESIGN §6.8, full 2.4 GHz sustained). The
  case only has to **not block the module's vents**. Combined with "never runs
  closed" (§1), thermal is a non-issue.

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

## §6 — Shell size## §6 — Shell size

The LFP8AH is a ~90 × 70 × 100 mm cube. It, plus the Pi + NVMe + cooler + a 7"
faceplate, does not fit the current ~1150-class shell — which is exactly why the
battery is external today.

| Shell | Interior (mm) | Fit |
|---|---|---|
| Pelican 1150 (current class) | 184 × 118 × 84 | Battery will not fit inside. Today's problem. |
| **Pelican 1300** | 233 × 178 × 155 | Deep; battery stands upright in the base. |
| **Pelican 1400** | 300 × 225 × 132 | Wide; battery + keyboard + SDR sit side-by-side. |

**Lean 1400.** The wider footprint keeps components in one layer beside each
other rather than stacked — stacking is what traps heat and complicates the
faceplate. Clone shells (Apache 4800, Harbor Freight Apache) share these
dimensions at lower cost if the Pelican brand is not the point.

## §7 — Print vs buy

- **Print:** the faceplate/bezel, the keyboard well, the connector rear-lip, the
  battery cradle, standoff risers for the Pi and the display board.
- **Buy:** the shell (injection-moulded waterproof beats printed for the gasket),
  the panel-mount connectors, the buck converter, the LiFePO4 charger, the fuse
  holder.
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
- One fewer thing on the connector strip: the keyboard is wired internally to a
  Pi USB port or an internal hub, so it does not need a panel jack. Its own two
  hub ports can BE the panel USB-A jacks, routed to the faceplate.
- No separate mouse needed, which keeps the slab uncluttered — the touchpad is
  the pointer.

## §8 — Open, needs the operator's measurements before CAD

KNOWN (do not re-measure): JUNEBOX outer 203×136.5×51, VESA 75/100, 12V, own
fan, Pi+SSD inside · Perixx keyboard 230×160×23 · SMA antenna · Powerpole power.

DONE:

- ✅ **JUNEBOX active area = 173 × 118 mm** (measured 2026-09-02). The faceplate
  window in docs/design/faceplate.svg is now cut to this, centered in the 203×136.5
  module face. (Runs a hair taller than the 172×107 an 8" 1280×800 would predict —
  cut to the measured number, not the theoretical.)
- ✅ **Module I/O + power path** (photographed 2026-09-02). The brick exposes I/O on
  **two adjacent edges** (an L), so the connector strip wraps the corner rather than
  riding one rail:
  - *Display-board edge:* `AUDIO` (3.5 mm), `HDMI` (full-size), `USB Type-C`, and
    `DC 12V` — a **barrel jack**.
  - *Pi edge:* **2× USB-A** (USB-3 blue stack), **Gigabit Ethernet** (RJ45), the
    Pi's USB-C, and the NVMe/fan.
  - **Power path is already solved and already on Powerpole.** The 12 V inlet is the
    barrel, but a screw-terminal→barrel adapter (green Phoenix block) with a
    **Powerpole pigtail** is already fitted. No barrel→PP pigtail to build. The
    faceplate's external Powerpole IN just parallels this same feed onto the bus.
  - Faceplate USB-A jacks extend from the Pi's 2× USB-A. The module's AUDIO/HDMI/
    USB-C stay at the module edge for occasional use; they need not reach the plate.

STILL NEEDED — two measurements, with a ruler on the physical parts:

3. **Miady LFP8AH exact L×W×H and terminal position** — the cradle and the shell
   choice depend on it. (Working estimate ~90×70×100 mm; confirm.)
4. **Chosen shell and its REAL usable interior** — catalog interior overstates
   it (gasket lip, radiused corners, ribs). Measure the flat inner floor.

Once those four exist, the connector table in §3, the layout in §4, and the SVG
in docs/design/faceplate.svg become a parametric plate.
