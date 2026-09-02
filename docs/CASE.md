# Case & faceplate design

For the next enclosure. Written to be shopped and printed against, not admired.
Operator has a 3D printer, an existing ~Pelican-1150-class shell that "opens
upside down," and a Miady LFP8AH LiFePO4 pack (12.8 V, 8 Ah, **102.4 Wh**)
currently living *outside* the case on Powerpole leads.

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
| **BNC** bulkhead | antenna feed (RECOMMENDED) | **~14 mm** round, keyed | Quarter-turn bayonet — fast, glove-friendly, thousands of mate cycles. Add an anti-rotation notch or flat. |
| **SMA** bulkhead | antenna feed (alt) | **6.5 mm** round (±0.1) | Smallest cutout, matches the RTL-SDR. Threaded and fiddly; ~500-cycle rating. Best if the antenna mostly stays on. |
| **USB-A** snap-in | data / peripherals | **26.5 × 12.3 mm** rectangular | Adafruit/McMaster snap-in panel-mount cable. Two of these. |
| **DC barrel 2.1 mm** | 12 V in / charge | **~8 mm** round (0.31") | Panel jack, up to 8 mm panel thickness. |
| **Anderson Powerpole** | battery / 12 V distribution | Powerwerx PanelPole2, or a printed PP15-45 retainer | Matches the existing external leads. Keep the Powerpole standard. |
| **Rocker/toggle switch** | master power | **~12 mm** round or 13×19 mm rocker | Between battery and the buck converter. |

**One RF connector, not a rack of them.** SO-239, N-type and multiples are
dropped: the operator carries adapters, so the panel needs a single antenna jack
and everything else adapts to it. BNC is the functional pick for a field deck
that plugs and unplugs often (bayonet quick-connect); SMA is the smaller-hole
alternative if the antenna lives connected. Standardise on whichever, keep an
SMA↔BNC adapter for the RTL-SDR, and the faceplate loses a 4-hole flange and two
cutouts.

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

## §5 — Power chain & charging (what "self-contained" still needs)

Getting the battery inside is necessary but not sufficient. The current setup
charges externally; self-contained needs the charge path inside too.

- **12.8 V bus** feeds the display driver board directly (it is a 12 V board —
  `DC 12V` silkscreen) and the SO-239-adjacent radio gear.
- **Buck converter 12 V → 5 V/5 A** for the Pi 5. Size it for the Pi's peaks or
  it brownout-throttles under load; the earlier `0x…0001` power-request warning
  and any USB current-limit events are the symptom to watch.
- **LiFePO4 charging is NOT lead-acid charging.** A LiFePO4 pack wants a charger
  that terminates at **14.6 V CV** (4× 3.65 V cells). A trickle/float lead-acid
  charger will under- or over-drive it. The keyboard base already shows a "Charge
  Power" LED, so some charge circuit exists — identify it before adding another.
- **Fuse the battery** (inline, close to the positive terminal). Non-negotiable
  on a LiFePO4 pack that can deliver tens of amps into a fault.
- **102.4 Wh is over the 100 Wh airline carry-on limit.** Flyable in the
  100–160 Wh band, but needs airline approval and max two spares. Only matters if
  this ever travels by air; noted so it is not a surprise at a checkpoint.

## §6 — Shell size

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

A precise faceplate cannot be drawn until these are known:
- exact screen module outline and mounting-hole pattern (the RTK CX101 panel)
- the Perixx PERIBOARD-510H footprint and thickness (the wired unit, §9)
- chosen shell, and therefore the usable interior faceplate rectangle
- whether the display driver board mounts under the faceplate or beside the Pi

Once those exist, the connector table in §3 and the layout in §4 become a
parametric plate.
