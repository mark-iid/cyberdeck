# What went wrong

Every fault in this build was found by looking at something: a photograph, a slicer
screenshot, a caliper on a real part. Not one was found by an assertion, and the model
carries 65 of them.

That's not bad luck, it's structural, and it's the first lesson. This page is the short
version of a much longer audit trail that isn't worth keeping: eight faults that each
taught something, written up so the next build doesn't have to rediscover them.

## 1. Check against what the part meets, not its own definition

This is the one that explains most of the others.

The plinth was drawn at 31 mm (75 shelf minus 44 module) and the assertion that guarded
it was, in effect, `assert(31 == 75 - 44)`. Which passes. What it *should* have checked is
the whole stack against the shelf, and the stack includes the 4 mm tray the plinth stands
on, so the real number is 26.5. I'd already started the print when that turned up.

Same shape, four more times:

- The ledge inset formula had a sign error. The assertion guarding it recomputed the
  *intended* formula and compared, so it agreed with itself. All four members were printed
  by then.
- The shroud's height was computed as if from the floor. It stands on the tray, so its top
  landed at 78.5 against a 75 shelf.
- The M4 VESA heads weren't pocketed, putting 4 mm of head between plinth and tray:
  4 + 4 + 26.5 + 44 = 78.5. Same failure as the shroud, different part, two weeks apart.
- The chassis nuts, if they'd sat *under* the tray instead of in pockets, would have added
  2.4 mm: 6.4 + 26.5 + 44 = 76.9. A nut isn't geometry, so no assertion was ever going to
  see it.

The rule: every dimension gets checked against the thing it meets, in the coordinate
frame it meets it in. If your check can be satisfied by rearranging the definition, it
isn't a check.

## 2. A tautological assertion cannot fail

I tested this rather than assuming it. Forced `TRAY_T = 6` in the model, which should
have made the stack 76.5 against a 75 shelf and blown up loudly. Instead `PLINTH_H`
silently became 24.5 and the assertion echoed 75, happily.

Four assertions are now labelled `TAUTOLOGY` in the source (three in `deck.scad`, one in
`plate.scad`), because deleting them would just mean someone writes them again. They're
documentation now, not checks.

If a value is derived from A and B, an assertion relating it to A and B is decoration.
Assert against an independent measurement or don't bother.

## 3. A consistent wrong number looks like a right one

The RJ45 aperture was 16.6 × 13.6, from a listing that said "jack face 16 × 13". Calipers
on the real part: 15.7 × 15.5. Very nearly square, and 1.9 mm short in the direction
that matters. The tile would have printed fine and the plug wouldn't have gone in.

Nothing in the assertion set could have caught that, because there's no inconsistency to
find. The number was wrong at the point it entered.

Vendor-published panel dimensions beat anything you derive, and calipers on the part in
your hand beat both. Where a vendor publishes an opening, that's the opening the part
is engineered for; your printer offset is a correction to reach it, not a rival number.

## 4. Mirrored parts and asymmetric features don't mix

The battery well is off-centre (−71 to +51). The back frame members are one part, mirrored
in the slicer. So a relief cut drawn at 0…51 lands at −51…0 on the mirrored copy, leaving
20 mm of ledge exactly where the shroud comes up.

Same bug, different part: the tray's bolts were filtered with `if (b[0] >= 0)`, so the
mirrored half got a different bolt pattern than the one that was checked.

If a part gets mirrored, every feature on it is either symmetric or a fault waiting for
assembly. Fold with `abs()` rather than filtering by sign, and check the mirrored copy
explicitly, it's a different part.

## 5. Know which origin you're drawing in

`tile_screws()` offset its holes by the tile's centre. Correct for the rails, which are
drawn centred. Wrong for the back tiles, which are drawn in plate coordinates. Both back
tiles exported with zero screw holes, and I shipped one to the printer.

It was visible in the facet count the whole time: 112 facets against a sibling's 2176.
`check-stl.py` now warns below 24 facets, and `tile_screws()` takes an explicit
drawn-origin parameter instead of guessing.

## 6. "No material" and "hole" are different claims

The hole probe checked that every fastener position had no material at it. Two plinth
bolts fell *inside* tray plenum windows, and the probe passed, because a window is also
no material.

Related: a `cube(..., center=true)` at z=0 centres in Z too. The Powerpole opening was
`cube([16.2, 8.5, TILE_T+2], center=true)` and left 1.25 mm of tile across the top. Found
by differencing meshes and getting 172.125 mm³, which is 16.2 × 8.5 × 1.25 exactly.

Every cut in `plate.scad` now goes through a `through()` module so no cut can be
accidentally blind, and the window positions are a declared list with an assertion that
no bolt lands in or beside one.

## 7. Interference checks measure volume, not emptiness

My first assembly check treated *any* intersection as a failure. Parts that rest on each
other share a zero-thickness face, which OpenSCAD reports as non-empty, so everything
failed and the check was useless.

It also didn't delete stale STLs, so it cheerfully reported two collisions I'd already
fixed.

The working version tests volume above a threshold, deletes its inputs first, and
intersects each of N parts against the union of all the others. N renders that cover
every pair, which removes the judgement about which pairs are worth checking. Final
result: 23 parts, 0 overlaps.

## 8. Some parts are built for sheet metal

Two connectors retain themselves by snapping to the panel. A Cat6 keystone coupler was
the worse one: I spent two coupons widening its opening before working out that retention
is a *rotational* snap against a moulded ~2.4 mm wall plate. Opening size was never the
variable. The part cannot latch into a printed plate at any hole size.

The 3.5 mm audio jack was the same family: thread only 6.86 long, which against a 4.5 mm
tile leaves 2.36 mm for a nut that needs 2.4.

Once you notice "this was designed for 1 mm of steel" is the category, the fix is
generic, rebate the tile down to the thickness the part expects for the width of its
bezel, or counterbore from behind to seat the body deeper. The keystone got replaced with
a screw-mount extension instead, which sidesteps panel thickness entirely.

When a panel-mount part fights a printed plate, check what thickness it was drawn for
before changing the hole.

---

## The general case

Assertions encode a model. If the model is wrong in a way nobody imagined, they pass,
and the more of them there are, the more confident you feel about a plate that doesn't
fit.

What actually worked was tooling that *reports* instead of *asserting*:
`features.py` slices a finished STL and lists every loop's size and centre, and
`slice-svg.py` draws it. Neither one knows what the answer is supposed to be. That's why
they found things.

Build one of those early.
