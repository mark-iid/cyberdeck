# The case

This is the enclosure half of the deck: a Pelican 1400, an 8" touchscreen module,
a LiFePO4 pack, and a printed faceplate that carries all of it. The software side
is in [DESIGN.md](../DESIGN.md).

Roadmap, because the order matters: there's one constraint that decides everything
(§1), which forces the form factor (§2), which forces a plate that rides an internal
shelf (§3). Everything after that is consequences — what the plate is made of (§4),
what's cut into it (§5), how power moves (§6), what sits underneath (§7), and what
stops the whole lot lifting out in transport (§8). Then the practical half: printing
and fasteners (§9), the assembly order that geometry forces on you (§10), and what
the finished deck actually measured (§11).

If you only read one section, read §3. The rib shelf is the idea the whole build
hangs off.

## What it is

The computer is a *module*, not a collection of parts. The display is a JUNEBOX 8"
1280×800 IPS 5-point touch unit (Amazon B0DX26BXPX) whose backboard enclosure houses
the Raspberry Pi 5 itself, plus the NVMe SSD and heatsink. It takes 12 V in, exposes
HDMI / USB / power on its own edges, mounts via VESA 75/100, and carries its own
active fan. So the 200 × 137.5 × 44 mm brick is the entire computer.

That collapses the build to three things:

| | |
|---|---|
| JUNEBOX 8" module | 200 × 137.5 × 44, 417 g, VESA 75, 12 V |
| Perixx PERIBOARD-510H Plus | wired mini keyboard, touchpad, 230 × 160 × 17 |
| Miady LFP8AH | 12.8 V 8 Ah LiFePO4, 102.4 Wh, body 100 × 70 × 90 |

Plus an optional RTL-SDR and telescopic antenna (first thing to cut if space gets
tight — the deck is fully functional without it).

Shell is a Pelican 1400, surveyed by hand and cross-checked against Pelican's own CAD.

## §1 — The one constraint

*It will never run fully closed, but I'd like it waterproof fully closed.*

That sentence removes the hardest problem in a go-box build. Three consequences, and
the second and third are the ones people miss:

1. **Don't penetrate the shell.** No bulkhead connectors through the case wall. Every
   hole you drill is a seam that fails eventually. All the I/O lives on an *internal*
   faceplate, exposed when the lid's open, sealed inside the shell when it's shut.
2. **The connectors don't need to be waterproof.** They're never in the weather (they're
   inside a sealed shell when stowed, and the deck doesn't get run in the rain). So
   cheap standard panel-mount parts, not IP67 ones. Big saving on both cost and sourcing.
3. **Cooling stops being a design problem.** The airflow question only bites in a
   *sealed running* box. Open lid, open air. Waterproofing is a transport requirement,
   and a stock Pelican meets it with zero modification.

The build reduces to: an unmodified shell, plus a printed plate that carries the
screen, keyboard and connectors, deployed only when the lid's open.

## §2 — A slab, not a clamshell

The complaint about the old build was that it opens upside down. That's a clamshell
problem (screen in the lid, keyboard in the base), so drop the clamshell.

**Screen, keyboard and connectors all live on one plate that drops into the case base.**
The lid becomes a pure waterproof cover. Open it, set it down, and the whole working
surface faces up like a field radio (think TRS-80 Model 100, or an Elecraft go-box).
Nothing to prop, nothing upside down.

Why it wins here beyond fixing the gripe:

- **The plate's border *is* the connector panel.** The frame around the screen is exactly
  the real estate you want for connectors, so it costs nothing extra.
- **It prints flat and iterates cheaply.** A plate is a near-2.5D part: fast to print,
  trivial to reprint when a connector moves. A clamshell hinge is the hardest thing on
  a printer to get right and the most likely thing to break in the field.
- **No hinge to waterproof.** The seal is the shell's existing gasket, already rated.

The clamshell only wins on stowed compactness, and this is a go-box. Footprint when
open matters more than millimetres when closed.

The cost is that it won't stand up and face you like a laptop. You look *down* at it,
20–30°, which is fine for touch and fine for reading and slightly worse for long typing
sessions than a laptop would be. A fold-out tilt foot under the front lip would fix that
and hasn't been drawn yet (§11).

## §3 — The rib shelf, which is the whole trick

The Pelican 1400's interior has twelve moulded ribs, three per wall, four walls. They
stand 2 mm off the wall and their tops all finish at exactly 75 mm off the floor.

**The plate sits on those ribs.** No fasteners, no bonding, nothing that touches the
shell in a way §1 would object to. It just drops in and lands on twelve points.

### Measured, because the catalog numbers describe a different box

| | Catalog | Measured | Used |
|---|---|---|---|
| Interior width at the shelf | 11.81" (300) | **305** | 305 |
| Interior depth at the shelf | 8.87" (225) | ~230 | **231.4** (Pelican CAD) |
| Base interior height | 4.00" (102) | **100** | 100 |
| Flat floor, inside the corner fillet | — | **270 × 200** | 270 × 200 |
| Corner radius | — | ~18 | 18 |
| Rib height above the wall | — | **2.0** | 2 |
| Rib tops above the floor | — | **75** | 75 |
| Rib centres, every wall | — | — | 0 and ±74.5 (Pelican CAD) |

Two things to know about this table. The walls taper — the interior narrows about
0.09 mm per mm going down — so a plate cut for 305 at the shelf drops in freely from
a wider rim and gets stopped by the ribs rather than wedged by the wall. And the CAD
was *right* about rib spacing and *wrong* about rib section, so the positions came from
the drawing and the 2 mm came from calipers on the real case (an 80 mm bar bridges two
adjacent ribs, which confirms the spacing independently).

### Why the plate is 304.5 wide and not 304

The rib inner edges sit at 2 and 303, so the shelf opening is 301 mm across. A plate
of width P has 305 − P of sideways freedom, so if it slides all the way to one wall,
the thin side keeps exactly **P − 303** of bearing:

| Plate width | Guaranteed bearing, worst case | Verdict |
|---|---|---|
| 303 | 0 | can lose the shelf entirely. No. |
| 304 | 1.0 mm | drop-in, 1 mm total clearance |
| **304.5** | **1.5 mm** | chosen |

**304.5 is biased oversize on purpose, and the reason is asymmetry of consequence:**
too wide sands down in minutes, too narrow loses bearing with no way to add material
back. (Depth got the same treatment: 230.5 against a 231.4 opening, for 1.1 mm of
guaranteed bearing. 229 would have given −0.4, which is how you find out you did the
arithmetic on the wrong pair of numbers.)

Load was never the concern — 1 mm across twelve ribs carries a 2 kg assembly without
noticing. The concern was the plate walking off its shelf in transport, and it can't:
escaping needs 2 mm of sideways travel and the wall stops it at 1.

### The vertical budget

    100 ──── case rim ───────────────────────────
             19 mm recess (preload strips live here)
     81 ──── plate top face ────────────────────
              6 mm frame
     75 ──── rib tops ══════════════════════════
             44 mm module
     30.5 ── plinth top ────────────────────────
             26.5 mm plinth (this gap is the plenum)
      4 ──── tray top ──────────────────────────
             4 mm tray
      0 ──── case floor ─────────────────────────

4 + 26.5 + 44 = **74.5 under a 75 shelf**, and that half millimetre is deliberate
(§7). Anything on the floor is bounded by the flat 270 × 200 inside the fillet, not
by 305 × 230.

## §4 — The plate: a frame, and tiles that drop into it

**Nothing here prints in one piece.** The Ender 3 is 220 × 220 × 250, call it 215 × 215
once you allow for the nozzle's corner reach. 304 × 230 isn't close, and a full-length
frame rail doesn't fit diagonally either (a 215 mm square tops out around 304 mm of
combined length plus width, so it's marginal at best). A 304 mm part at 4.5 mm thick
would warp off that bed regardless.

So the plate is two kinds of part:

- **Frame** — 304.5 × 230.5 outer, 12 mm wide on the sides and back, 8 mm across the
  front, 6 mm tall. Four L-shaped members, lap-jointed with M3s through separate
  splices. Being continuous it doesn't care where the ribs fall along a wall, *but the
  joints have to land over a rib*, never mid-span. That's what puts them at 0 and ±74.5.
- **Tiles** — screen bezel, two connector rails, two back-channel fillers. 4.5 mm
  thick, dropped onto a ledge inside the frame. The ledge turns a 2 mm shelf into a
  10 mm one, so no tile inherits the tolerance problem the frame already solved once.

The split pays off a second time: every connector ends up on a piece small enough to
reprint on its own when a cutout comes out wrong. Which it will.

### Frame height, and what it costs

The frame has to be *taller* than the tiles, because a tile needs a ledge to land on
and that ledge can't hang below the frame (the module's top face is right there at 75).
So frame height trades directly against what can ride above the plate:

| Frame | Ledge | Tile | Plate top | Recess left |
|---|---|---|---|---|
| 4.5 | — | 4.5 | 79.5 | 20.5, but no ledge is possible |
| **6.0** | **1.5** | **4.5** | **81.0** | **19.0** |
| 8.0 | 3.5 | 4.5 | 83.0 | 17.0 |

6 / 1.5 / 4.5, tiles finishing flush with the frame top. The ledge only carries a tile
*edge*; the module carries the middle, through 2 mm of foam tape.

**The front member is 8 mm wide instead of 12** (with a 5 mm ledge instead of 10),
because the module sits as far forward as it'll go and 12 mm of frame would have
overlapped the active area. The ledge inset runs the opposite way there, which is
exactly the kind of asymmetry that bites you if you write the formula once and reuse it.

### The tiles have rounded corners

Not a detail — a bug I shipped four times. The frame's opening inherits the shell's
18 mm corners, so the inner opening has R6 corners, and a tile drawn with square
corners doesn't drop in. Every tile is now clipped to the opening's own rounded profile
rather than drawn as a rectangle and hoped over.

### The screen tile laps the front rail

The front frame member is only 8 mm wide, so the screen tile reaches over it and
shares 5 mm of lap. Both parts are *installed* at z 1.5…6, resting on the same plane,
which means the lap has to be cut in the tile's top 1.2 mm, not its bottom. (Get that
backwards and the tile sits high along the front edge, which is visible and annoying
and took a photograph to spot.)

Consequence for assembly: **the screen tile goes in before the rails.** With both rails
bolted down, engaging one lap needs a 5 mm slide that pulls the opposite lap out.

## §5 — The connector rails

The usable rail *tile* is 39.25 mm wide, and that number is smaller than it looks.
The rail zone from plate edge to module is ~51 mm, but 12 mm of it is frame, so the
part connectors actually get cut into is (280.5 − 202) / 2. Worth stating because it
kills at least one part you'd otherwise buy:

| Part | Footprint across the rail | Tile left each side |
|---|---|---|
| SMA bulkhead | 6.7 | 16.2 |
| Powerpole retainer | 16.2 | 11.5 |
| Rocker flange | 25.3 | 7.0 |
| USB dual | 21.5 | 8.9 |
| Round Powerpole socket, ⌀35 flange | 35 | **2.1, unusable** |

Left rail is power and RF, right rail is data, and that's not arbitrary: the module's
own I/O exits its left edge (power, AV) and its right edge (USB, Ethernet), so the
plate mirrors the module and every cable run stays short.

### What's cut, and what each hole is

| Connector | Rail | Opening | Notes |
|---|---|---|---|
| SMA bulkhead F–F | left | ⌀6.7 drawn | Matches the all-SMA RTL-SDR kit, no adapter anywhere. Smallest cutout of anything here. |
| Anderson Powerpole | left | 16.2 × 8.5 pocket + printed retainer | External 12 V in. Feeds the selector, not the bus. |
| DPDT ON-OFF-ON rocker | left | 28.7 × 21.2, 2.0 web | Master switch *and* source selector. Mounted 21 across the rail, 28.5 along. |
| 3.5 mm audio, panel extension | left | ⌀6.2 + ⌀13 relief from behind, 2.5 web | Runs to the module's own AUDIO socket, same edge. |
| USB-A dual, square flush | right | 21.5 × 24.5, 2.0 web | One housing, two ports, one hole. |
| RJ45 panel extension | right | 16.2 × 16.0 + 2 × M3 on 27.5 | Mounts from *behind*, screw ears, no snap. |

**This printer runs holes about 0.2 mm undersize**, so every round hole is drawn at
nominal + 0.2. Two independent ladders on a test coupon landed on the same offset (SMA
wanted 6.7 for a 6.5 part, a 16 mm switch wanted 16.2), which is systematic shrinkage
rather than two coincidences, so nothing else needed its own experiment.

Published dimensions govern and the offset is a printer correction, not a rival number.
Where a vendor publishes a panel opening, that's the opening the part is engineered for
and it's what the finished plate must *have*. The coupon results are just how you get
there on this machine: draw 28.7, print 28.5.

### The thin-panel problem, and the one fix for all of it

Two of these parts retain themselves by snapping to the panel, and both are designed
for sheet metal or a ~2 mm wall plate. A plate stiff enough to carry an 8" module wants
4.5 mm. Neither snaps home in that.

The fix isn't to thin the plate — it's a **rebate**. Cut the opening full size, then
step the tile down to the thickness the part expects for just the width of its bezel
(the 2.0 mm webs in the table above). The audio jack needed the same trick in reverse:
its thread is only 6.86 long, which against a 4.5 tile leaves 2.36 mm for a nut that
needs 2.4, so the tile is counterbored ⌀13 from *behind*, seating the body 2 mm deeper
and putting the nut on the front face where it has room.

Both of those parts are built for sheet metal. Once you notice that's the shape of the
problem you stop being surprised by it.

### The Powerpole retainer

A PP15-45 pair has nowhere to mount, so it gets a printed block behind the tile:
32 × 14.8 × 10, with a 16.2 × 8.5 pocket, held by two M3s through the tile on 26 mm
centres, with a captive hex nut on the far end of each.

The retention is the roll pin, not the pocket. With the mating face flush at the tile
front, the pin lands 5 mm behind the tile, inside the block, with 5 mm of wall in front
of it to take the pull. The pin passes through wall, housing, wall — double shear, and
captive once it's in. Assembly is push the pair home from behind, then push the pin
through.

(If 16.2 × 8.5 turns out to be an already-clearanced figure rather than the connector's
true cross-section, the pocket ends up ~0.5 loose, which the pin makes harmless.)

## §6 — Power

One inlet, one switch, one voltage. Most of this section is short because the module
did the hard part.

**No conversion, and that was a purchase decision rather than luck.** The module is
12 V-native and powers the Pi from that same 12 V, doing its own 12→5 internally. The
12.8 V pack feeds it directly: no buck converter to size, no 5 V rail to build, no
brownout-throttle risk from an undersized regulator, no second supply to find room for.

```
battery ── fuse ──┐
                  ├── DPDT ON-OFF-ON ── module 12 V barrel
panel PP IN ─ fuse┘        INT / OFF / EXT
```

**One DPDT ON-OFF-ON rocker does both jobs.** Its three positions are INT / OFF / EXT,
so it's the master switch and the A/B source selector in one part. The two sources never
meet, and they can't: switching both conductors means an external supply with its own
ground reference can't back-feed either. That's back-feeding made impossible by
construction rather than by discipline, which is what you want in a box that gets used
tired and in the dark.

Label the plate INT / OFF / EXT. A rocker's two ON positions are not self-explanatory,
and this one is the difference between running off the pack and running off shore power.

The alternative was an ideal-diode ORing board (Super PWRgate or similar). It switches
over without a break *and* charges the pack while running, which is genuinely better on
both counts — and it's £100+ and a pack-of-cards-sized board that needs a home on the
floor tray with thermal margin around it. Not worth it for a box with one load.

Other consequences of the single feed:

- **Never plug power into the Pi's USB-C.** The Pi is powered *through* the module, so a
  charger on that port is a second source fighting the module's 5 V rail. It's free for
  data, and nothing else. (It's also not the port you're looking for — see §10.)
- **One switch kills the whole deck**, because it's upstream of the module: screen, Pi,
  SSD and fan together. No partial-power states to reason about.
- **Size the fuse for the sum, not the Pi.** Worst case is ~30 W ≈ 2.5 A at 12 V, so a
  **5 A** fuse gives headroom without letting a real fault run. One per source, close
  to its origin.
- **USB is exactly full.** The module's right edge exposes 2× USB-A. Both go to the dual
  panel unit's pigtails, giving two panel jacks. The keyboard takes one. Inside, the
  touch controller and the RTL-SDR take the module's internal ports. That's four devices
  in four ports and the margin is zero (confirmed the hard way at first assembly: a
  500 GB drive made five, and got dropped rather than adding a hub).

### Runtime

102.4 Wh, derated ~10% for practical LiFePO4 discharge:

| Use | Draw | Runtime |
|---|---|---|
| Reading kiwix or maps, screen dim | ~10 W | ~9 h |
| Typical operating (FT8, browsing) | ~15 W | ~6 h |
| Heavy (local LLM, compiling) | ~28 W | ~3.5 h |

A full field day at typical load, or an overnight at light load.

### Nothing charges the pack, and here's the pigtail that fixes it

An A/B selector runs the load from one source and disconnects the other, which means
**no switch position ever connects the panel inlet to the battery**. The pack has no
charge path. This document read "if runtime is short, use the external inlet" as a
charging story for weeks, and it isn't one — it's a story about running on shore power
indefinitely, which is a different thing.

The fix needs no more switches: **a charge pigtail off the battery**, run up into the
back channel and terminated in a Powerpole. A charger plugs straight onto the pack with
the lid open and nothing dismantled. It also keeps the charger where it belongs, talking
directly to the cells on its own 14.6 V CV profile with no other load on the bus.

Don't dumb-parallel a bare supply onto the battery Powerpole. The selector removes the
temptation, but the rule stands for any future rewiring: an arbitrary 12–13.8 V supply
fights a LiFePO4 pack's chemistry.

Also: 102.4 Wh is over the 100 Wh airline carry-on limit. Flyable in the 100–160 Wh band
with approval, max two spares. Only matters if it flies.

## §7 — Under the plate

The heavy things sit on the floor and the plate bears *on* them, which is the reverse
of the obvious arrangement (hang the module off the plate on a VESA bracket).

To be fair to the obvious arrangement: the module is 417 g, so hanging it probably
wouldn't have failed. The inversion still wins for three reasons that survive that
correction. A plinth sets the module's height *exactly*, where a bracket has to be
shimmed to do the same. It lets the plate bear on the module instead of the reverse,
which stiffens the plate's centre. And the tray has to exist anyway to locate the
battery, which at ~1 kg is the heaviest thing in the case and is on the floor no matter
what the module does.

### The tray

Two halves, 132.5 × 195 × 4 each, split at x = 0, laid on the flat 270 × 200 floor
before the fillet climbs. 2.5 mm clearance all round. **Nothing fastens it to the shell**
— the fillet traps it on four sides and the mass on top holds it down. Same trick as the
plate on the ribs.

The halves aren't joined to each other. The plinth bridges the seam and bolts into both,
which is why its bolts are at x = ±20 and none on the centreline.

Two windows in the tray vent the plenum to the back channel. The bolt holes deliberately
sit *beside* them, not lined up with them, and there's an assertion in the model whose
whole job is to keep it that way (I drilled two bolts straight into a window once and
only caught it off a slicer screenshot).

### The plinth, and why it's 26.5 and not 31

Nominally 75 − 44 = 31. It's drawn at **26.5**, which is 31 minus the 4 mm tray it
stands on, minus a further **0.5 on purpose**.

That half millimetre isn't printer compensation (this printer measures accurate in Z).
It's insurance against **over-constraint**. The plate lands on twelve ribs *and* on the
module, and those two supports have to agree to a fraction of a millimetre or the plate
rocks. Any positive error here lifts the plate off its ribs entirely. Drawn short, the
module always lands slightly low, and **2 mm of foam tape on its top face** takes up the
gap — a compliant centre support rather than a rigid one competing with the ribs.

**The plinth is a pillar, not a pad.** The module's two vents are on its back face, which
points *down* in this design, so a solid pad under it suffocates the module. The VESA
pattern is central and the vents sit either side of it, so a central pillar clears both
by construction. The 26.5 mm gap underneath becomes a plenum, and the tray has to keep a
path from it out to the back channel rather than walling it off.

The four M4s go *up* into the module's VESA threads, so their heads land between plinth
and tray. They're countersunk, and they have to be: 4 + 4.0 of head + 26.5 + 44 = 78.5
against a 75 shelf. Use **M4 × 30 countersunk**, not socket cap.

### The battery

The pack stands **90 mm tall** on its 70 × 100 base and comes up through an open well in
the plate. Its top lands at 94, six under the rim.

It has to stand up. Lying on its 90 × 100 face needs 90 mm of floor behind the module
and there are 72.75.

Retention is two printed blocks gripping the 100 mm axis, bolted to the tray. Not a
four-walled cradle — that wanted 77 mm of floor and there are 72.75. And the blocks grip
the **100 mm body**, not the 106 mm envelope: the terminals are on the top face and stand
8 mm up, adding 6 mm to the width, and a block sized for 106 squeezes the posts.

One of the two blocks is a **full-height shroud over the terminals** — open above for
clearance, closed against intrusion. That matters because bare telescopic antenna
elements loose in the same channel as exposed battery terminals is a dead short on a
LiFePO4 cell (a fire, not an inconvenience). The antenna ships in a plastic tube, which
is the real answer as long as it actually goes back in the tube; the shroud is the belt
to that braces.

### Stowage zones

Contents total ~2.9 L against the 1400's 8.9 L.

| Zone | Space | Holds |
|---|---|---|
| **A — back channel** | ~180 × 88 × 90 beside the battery | SDR dongle, coax coil, antenna tube |
| **B — under the module** | 26.5 mm of air, 200 × 137.5 footprint | flat non-fragile items, adapters, spare coax |
| **C — in the lid** | thin, full width | the keyboard, notes, cheat sheets |

Zone B has one rule: **don't pack it solid.** That's the plenum.

The keyboard is in the lid because it won't fit on the plate. Clear plate runs from the
front edge to the battery well, 143.5 mm, and the keyboard needs 160 either way round
(230 is longer still). It's short by 16.5 and no orientation fixes that. Its retention in
the lid is still unspecified (§11) — a cut foam pocket or a strap.

Given ~3 L of genuinely usable space, a sensible pack list is SMA/BNC/PL-259 adapters,
spare fuses, a small multimeter, a GPS puck, a headlamp, and a paper log with a pencil.
That's the difference between a computer in a case and an actual go-kit.

### Service loops, the detail that ruins an afternoon

Every panel connector's cable runs from the plate down to the module below it: two USB
extensions, the Ethernet patch, the SMA jumper, and the 12 V run to the switch. Lift the
plate and you pull on all of them.

So each one needs a service loop long enough to lift the plate clear of the rim and set
it beside the case. Call it **+150 mm** over the direct run, with somewhere for the slack
to sit when it's closed. (The SMA jumper is the one that caught me out: 127.6 direct plus
150 is 278 mm, and the 150 mm jumper in hand is less than half of it.)

## §8 — What holds it down

Nothing, until the lid closes. The plate is trapped sideways by the walls with 0.5 mm of
clearance across the width and 0.9 down the depth, but invert the case and the whole
assembly lifts off its ribs.

It used to be simpler: when the keyboard lay on the plate at 81 + 17 = 98, the lid foam
bore on the keyboard, and the load went straight down through the plate into the ribs.
One preloaded stack. Moving the keyboard to the lid removed the middle of that argument,
and what's left is a 19 mm recess over the plate and a battery standing 13 mm into it.
Lid foam meets the battery first and bridges the step rather than conforming to it, so
the plate gets *some* preload near the front and little at the back. Partial and
unquantified, and the pack ends up taking the lid-closing load, which nothing chose.

**The fix is two printed TPU strips, 12 × 190 × 20, one on each side frame member.**

Printed rather than cut foam, because the height is repeatable and the stiffness is a
slicer setting rather than a shopping trip. Print at ~10% gyroid, two perimeters, and it
behaves like firm foam. They're drawn solid on purpose: modelling a lattice freezes the
stiffness into the geometry where you can't tune it, and in the slicer it's one number.

**Where the load goes is the entire point.** Each strip sits directly over the three side
ribs at y = 0 and ±74.5. The plate is carried at its perimeter, so preload belongs at the
perimeter; a pad in the middle would only press on the module, which is already bolted
down and needs no help. 190 mm long so it clears the R18 corners, which start at ±97.25.

20 mm against a 19 mm recess, so the lid squeezes it 1 mm. If the latches won't close,
reprint at 19 or 18. It's a ten-minute part, which is the other argument for printing it.

The side members' 12 mm band runs from the opening edge out to the plate edge, and that
band is clear of every connector (they're all on the rail tiles inboard of it), so the
strips need no cutouts and foul nothing.

### Retention, all of it, in one table

| Item | Held against sliding by | Held against lifting by |
|---|---|---|
| Floor tray | the floor fillet, four sides | the module and battery bolted to it |
| Module | VESA bolts into the plinth | same |
| Battery | two blocks on its 100 mm axis, bolted to the tray | the blocks, and the plate around its well |
| Plate | case walls, 0.5–0.9 mm clearance | two TPU preload strips |
| Keyboard | in the lid, **unspecified** | same |

## §9 — Printing it

**Fifteen distinct parts, 23 pieces on the bed** (four splices, two of several others).
The model is in [design/](design/): `deck.scad` holds every shared constant,
`plate.scad` and `chassis.scad` draw the parts, and `assembly.scad` places all 23 in one
coordinate frame so they can be checked against each other rather than against their own
definitions.

```
./design/build.sh              # every part to STL
./design/check-stl.py *.stl    # bbox, bed fit, z=0, solid count, facet count
./design/check-holes.sh        # probe every fastener position
./design/check-all-pairs.sh    # each part against the union of all others
./design/features.py part.stl 0.5   # what's actually in a finished STL
```

`features.py` is the useful one. It slices a finished STL and reports every loop's size
and centre, and it asserts nothing — which is exactly the point ([LESSONS.md](LESSONS.md)).
Sweep it at 0.3 / 0.5 / 0.75 on anything with bosses, because some features only appear
at certain heights.

### Handedness, stated once because it costs a print

**The frame is four L pieces and no two adjacent ones are the same part.**

| Print | Qty | Slicer |
|---|---|---|
| `member` | 2 | one as exported, **one mirrored in X** |
| `member_front` | 2 | one as exported, **one mirrored in X** |
| `splice` | 4 | identical; rotate 180° about Z to put the scallop toward the wall |

The frame is mirror-symmetric about the centreline, so a front-right member and a
front-left are mirror images, not copies. Two unmirrored copies gives you two right-hand
fronts and the frame doesn't close. **A spare can't be flipped over to fix it** — that
puts the insert bosses on the show face.

### Which way up

**Members print upside-down relative to how they install.** The STL is exported with the
flat show face on the bed, so a member comes off the printer with its bosses pointing up.
In the case they point down.

    ===============================   <- flat face: the SHOW face, points UP
     ()                       ()      <- ⌀8 bosses: point DOWN, hold the inserts
    ---------------------------
      |  splice, counterbored face UP against the member
      |  scallop toward the WALL
      O  screw heads underneath, M3 x 10 up from below

| Part | Identify it by | Which way |
|---|---|---|
| `member` | the face with two ⌀8 bumps | bumps **down** |
| `splice` | the face with ⌀8.6 counterbores | counterbores **up**, against the member |
| `splice` | the scallop in one long edge | scallop toward the **wall** |
| `front_strap` | scallop in one long edge | bonded under the front joint, scallop to the wall |

Screw heads finish on the splice's exposed underside. Nothing shows on the plate's top
face, which is what the 1 mm of skin over each blind insert is for.

### Print order, and why it's this order

**Everything visible derives from the plate's outer dimensions.** The opening sets the
screen tile, both rails and both back tiles, and the opening comes from 304.5 × 230.5 —
both biased oversize (§3). Print a tile before a member and a bad bias costs all seven
visible parts.

| Step | Print | What it settles |
|---|---|---|
| 1 | `member` ×1 | The 304.5 / 230.5 bias, the R18 corner against the shell's, bearing on the rib shelf, and the joint seats in a real part rather than a coupon. 21.6 cm³ to test the assumption everything else rests on. |
| 2 | `member_front` ×1 + `splice` ×1 | Joined to step 1, that's the complete right side of the frame, 230.5 end to end. Verifies the depth, the joint in situ, and the splice's rib notch. |
| 3 | one more of each + 3 more `splice` | Mirror in the slicer. Frame complete; offer the whole thing into the case. |
| 4 | tiles: `screen_tile`, `left_rail`, `right_rail`, `back_left`, `back_right` | Only now, with the opening confirmed. |
| 5 | floor: `tray` ×2, `plinth`, `cradle`, `shroud`, `pp_retainer` | Independent of the frame, colour doesn't matter. |
| — | `preload` ×2 in TPU | Any time. Good filler between the big prints. |

**Stop after step 1 and measure.** If the member's oversize the fix is sanding; if it's
undersize the fix is a reprint, and finding that out on one part instead of eight is the
entire reason the bias is written down.

One member is a *quarter* frame and it can slide anywhere in the opening, so it confirms
the corner radius, the bearing at 75, and that the seats came out — and it cannot confirm
304.5 or 230.5 end to end. One caliper reading on the two arm lengths (drawn 152.25 and
115.25) turns "seems to fit" into arithmetic against the surveyed interior, instead of
something to discover at step 3.

### Fasteners

| Where | Qty | Size | Head | Into |
|---|---|---|---|---|
| Frame joints, splice up into the members | 12 | M3 × 10 | any (hidden below the plate) | heat-set insert |
| Tiles down into the frame ledge | 14 | M3 × 10 | **countersunk** | heat-set insert |
| Powerpole retainer through the left rail | 2 | M3 × 10 | **countersunk** | nut, captive in the block |
| RJ45 ears through the right rail | 2 | M3 × 12 | **countersunk** | the ears' own threads |
| Plinth down into the tray | 4 | M3 × 10 + nut | any | nut, in a pocket |
| Cradle block + shroud into the tray | 4 | M3 × 8 + nut | any | nut, in a pocket |
| Plinth up into the module's VESA | 4 | **M4 × 30 countersunk** | must bury | the module's own threads |

**28 heat-set inserts** (12 frame joints, 14 tiles, 2 Powerpole). Inserts are ruthex
RX-M3×5.7: 5.7 long, ⌀4.6 knurl, published hole ⌀4.0 × 6.7 deep minimum, 1.6 mm wall
minimum. Seats are drawn ⌀4.2 (prints 4.0) × 6.7, which needs a ⌀8 × 1.7 boss under each
one because the frame is only 6 mm tall — 6.7 of seat plus 1 mm of skin doesn't fit in 6.

**M3 × 10 and not 12 for the tile screws**, because the tile is 4.5 and the insert is
5.7, so 10.2 is fully engaged and 11.2 is where a screw bottoms out in the seat. A 12
jacks the tile back off its ledge.

**The eight chassis nuts sit in hex pockets in the tray's underside**, 2.6 deep, leaving
1.4 mm of tray. That's not cosmetic. Nuts *under* the tray raise it 2.4 mm and the stack
becomes 6.4 + 26.5 + 44 = 76.9 against a 75 shelf, which lifts the plate off its ribs —
the exact failure the 0.5 plinth bias exists to prevent, arriving by a route no assertion
catches, because a nut isn't geometry.

## §10 — Assembly

The order is forced by geometry, and three of the four constraints are things you can't
undo once you're past them:

1. **The eight chassis nuts go in first.** They sit in blind downward pockets with no
   retention, and the tray then lies on the floor. You can't seat them afterwards.
2. **M4s into the module before the plinth meets the tray.** Afterwards the plinth's four
   M3s are driven down past an overhead module: 17.5 mm of headroom at 31.25 mm of reach,
   a 29° approach. Ball-end hex key, not a screwdriver.
3. **The shroud slides in sideways over the terminals**, never drops vertically. The posts
   are spread over the pack's height and at least one will be under the lid line.
4. **Screen tile before the rails** (§4).

Then: frame into the case, tiles down, connectors from behind, preload strips on the side
members, lid.

### Deploying it

1. Set the case flat — table, tailgate, lap, ground.
2. Flip the latches, open the lid. A 1400's lid hinges at the back and stops near 100°,
   so it stands up behind the deck rather than folding away (it shades the screen from
   overhead sun and blocks wind from the working side, which is a nice accident).
3. Lift the keyboard out and set it in front. It stays plugged into the right rail —
   you're unstowing it, not connecting it.
4. Coax from the left-rail SMA to the antenna on its stand. External power into the
   left-rail Powerpole if you're on shore power.
5. Rocker to INT or EXT. One switch brings up screen, Pi, SSD and fan together.

No assembly, nothing to prop.

### Three modes it actually gets used in

- **Field desk** — case flat, keyboard out front. FT8, kiwix, maps. The primary mode.
- **Lap** — case on the thighs, screen up, keyboard beside or on the front lip. Works
  *because* the screen faces up and the keyboard is loose rather than hinged to a fixed
  angle.
- **Touch only** — lid up, stand over it, thumb through kiwix or maps without pulling
  the keyboard at all.

### The touchscreen fault, recorded because it'll happen again

At first assembly the touchscreen didn't work. `lsusb` showed one device across four
root hubs, no throttling, nothing obviously wrong.

The 500 GB drive I'd added on a whim was plugged into the display board's USB-C — which
is the **touchscreen's device-side link**, not a spare host port. One wrong port, two
symptoms (no touch, and no drive). Moving the cable brought up `TSTP MTouch` on bus 3-2
with `Capabilities: touch`, and everything worked.

So: the Pi's USB-C is power-only and unused (§6), and the *display board's* USB-C is the
touch link. Neither of them is a port you plug storage into.

## §11 — Measured, and still open

### Thermal: the enclosure costs nothing

The one number this document argued about and never had. The module's vents face down
into a plenum, both of them, and no airflow path was ever designed. The measurement says
it doesn't matter:

    baseline  51.6 C
    t=30      67.0 C   2400 MHz   0x0
    t=120     70.8 C   2400 MHz   0x0
    t=210     74.1 C   2400 MHz   0x0
    t=300     73.6 C   2400 MHz   0x0

Full 2.4 GHz throughout, zero throttle bits, plateaued around 74 C from t=210. It reached
steady state rather than climbing, which is the signature that tells a breathing enclosure
from a sealed one.

Like for like: **the same synthetic test measured 76.8 C before the deck existed**, so
the deck runs 2–3 C *cooler* than the bare setup on a desk. (Probably the plenum acting
as a duct, but I haven't instrumented that and won't claim it.)

One caveat, and it's `70-thermal-tune.sh`'s own warning: this is a scalar spin loop and
it **understates** real thermal load. The same script records compile at ~85 C and LLM
inference at 82.3 C on the bare setup. Scaling the 2–3 C improvement across suggests ~82
and ~80 in the deck, both under the 85 C soft limit. **Compiling is the case worth
measuring directly** before treating it as settled.

### Fit

- Frame sits clean on all twelve ribs, no rocking.
- All four members close. 304.5 × 230.5 was the right bias.
- The R18 corners match the shell's.
- 23 parts, 0 overlaps, by exhaustive pairwise check in the assembly model.

### Still open

1. **Keyboard retention in the lid.** A cut foam pocket or a strap. Deferred.
2. **Tilt foot.** Never drawn. The deck works flat; a foot would make long sessions nicer.
3. **Compile-load temperature in the enclosure.** See above.
4. **Charge pigtail fuse** — has to tap downstream of the battery fuse, or carry its own.
5. **Module input voltage tolerance.** No published figure exists. Mitigation is to
   charge with the rocker at OFF, which is also what the INT/OFF/EXT label is for.
6. **The splice's rib notch** was never checked against a real rib. It assembles fine, so
   this is curiosity rather than a risk.
7. The already-printed splices have ⌀3.4 holes, from the one place `M3_CLEAR` didn't
   reach when it went to 3.6. They assemble fine; the fix applies to any reprint.

### What the model can't see

No case walls, ribs or fillet. **No fasteners**, which is exactly why the M4 head fault
read as zero overlap. The battery is drawn as its bare 100 mm body, so the 8 mm posts and
the 20 mm wire envelope are invisible to every check that mentions it. And the 23
placements are still a judgement call — a wrong one hides a collision rather than
reporting it.

See [LESSONS.md](LESSONS.md) for the faults that were worth generalising from.
