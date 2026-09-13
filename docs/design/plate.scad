// cyberdeck — faceplate frame + tiles.
//
// Rests on the Pelican 1400's twelve moulded rib tops at 75 mm (CASE.md S6, S12).
// Nothing fastens to the shell. Sizes are all measured, not catalog:
//   interior at the shelf 305.0 x 231.4, corner R ~18, ribs 2 mm proud at 0/+-74.5
//   module 200 x 137.5 x 51, VESA 75 centred, active area 173 x 118 centred
//
// Ender 3, ~215 x 215 usable. Every part here is checked against that.
//
//   for p in member splice screen_tile rail_blank joint_test; do
//     flatpak run --filesystem=host org.openscad.OpenSCAD \
//       -o "$PWD/build/plate/$p.stl" -D "PART=\"$p\"" "$PWD/docs/design/plate.scad"
//   done
// Absolute paths - the flatpak cannot see /tmp.

include <deck.scad>

PART = "all";

// 304.5, not 304 - biased deliberately oversize.
//
// The calibration bar measured 79.95 for a drawn 80, but that is inside caliper
// noise on a printed edge, so XY scale error is UNKNOWN, not measured. An 80mm
// sample could not resolve 0.2% over 304mm in any case.
//
// The bias is chosen because the error is correctable in one direction only.
// Too wide and it sands down in minutes. Too narrow and bearing is lost
// (bearing = P - 303) with no way to add material back. At 304.5 the nominal
// bearing is 1.5mm and clearance into the 305.0 opening is still 0.5mm.
// Check the first printed member against the case before committing the rest.
// PLATE_W/PLATE_D, FRAME_W/FRAME_WF and CORNER_R are in deck.scad, where the
// bearing they produce on the rib shelf is assert()ed against the case interior.

// LEDGE_W/LEDGE_WF are in deck.scad with the tile-screw pattern.
// FRAME_H, LEDGE_H and TILE_T come from deck.scad, which assert()s that a
// tile sits flush in the frame.

// Module shifted FORWARD, front edge at -110.25, so its back edge lands at
// +27.25 and leaves 72.75 mm of floor behind it for the battery standing on
// its 70 x 106 base (S13 #0). Only the 173 x 118 active area must stay inside
// the opening; the module's front bezel tucks under the narrowed front member.
// MOD_*, BATT_*, WIN_* and TILE_GAP from deck.scad.

RIB_X = [-74.5, 0, 74.5];
$fn = 64;

// OPEN_* are in deck.scad too - the rail width falls out of them.
LEDGE_IW = OPEN_W - 2*LEDGE_W;             // 260.5
LEDGE_ID = OPEN_D - LEDGE_W - LEDGE_WF;    // 194
// MINUS, not plus. The ledge inner rectangle is inset LEDGE_WF at the front and
// LEDGE_W at the back, so its centre moves BACKWARD from the opening's centre,
// not forward. With the sign wrong the front ledge came out 10 wide instead of
// 5 - reaching y -97.25 and covering 3.25 mm of the screen's active area, which
// starts at -100.5 - while the back ledge came out 5 instead of 10.
LEDGE_CY = OPEN_CY - (LEDGE_W - LEDGE_WF)/2;
OPEN_BACK  =  PLATE_D/2 - FRAME_W;         // +102.5

module rr(w, d, r, h) {
    linear_extrude(h) offset(r=r) square([w - 2*r, d - 2*r], center=true);
}
module ring(ow, od, orad, iw, id, irad, h) {
    difference() {
        rr(ow, od, orad, h);
        translate([0, 0, -1]) rr(iw, id, irad, h + 2);
    }
}

// Full frame, for visualisation and for measuring against. Never printed whole.
module frame_full() {
    difference() {
        union() {
            difference() {
                rr(PLATE_W, PLATE_D, CORNER_R, FRAME_H);
                translate([0, OPEN_CY, -1])
                    rr(OPEN_W, OPEN_D, CORNER_R - FRAME_W, FRAME_H + 2);
            }
            difference() {
                translate([0, OPEN_CY, 0])
                    rr(OPEN_W, OPEN_D, CORNER_R - FRAME_W, LEDGE_H);
                translate([0, LEDGE_CY, -1]) rr(LEDGE_IW, LEDGE_ID, 1, LEDGE_H + 2);
                // The BACK ledge crosses the battery well. The pack stands up
                // through the plate there, so the ledge has to stop - found by
                // the assembly check, 1012 mm3 of pack inside the ledge.
                //
                // FOLDED to +-max, not cut at WELL_X0..WELL_X1. The well is
                // OFF-CENTRE (-71..+51) and the two back members are one part
                // MIRRORED, so a cut at 0..51 mirrors to -51..0 and leaves
                // 20 mm of ledge standing at x -71..-51 - right where the
                // terminal shroud comes up. The assembly check found exactly
                // that: 191 mm3 of shroud inside the left member's ledge.
                //
                // Same fault as the tray's `if (b[0] >= 0)` bolt filter: an
                // asymmetric feature on a mirrored part. Folding costs only
                // unused ledge at x +51..+71 - the back-right tile still has
                // 69 mm of bearing and both its screws sit beyond 71.
                WELL_CUT = max(abs(WELL_X0), abs(WELL_X1));
                translate([-WELL_CUT, OPEN_BACK - LEDGE_W - 1, -1])
                    cube([2*WELL_CUT, LEDGE_W + 2, LEDGE_H + 2]);
            }
            // bosses under the ledge, deep enough for a tile screw's insert
            for (t = TILE_SCREW)
                translate([t[0], t[1], -TILE_BOSS_H]) cylinder(d=BOSS_D, h=TILE_BOSS_H);
            // bosses under the rim, for the joint screws
            for (j = JOINT_SEAT) translate([j[0], j[1], 0]) insert_seat();
        }
        // tile seats: bored DOWN from the ledge top, so the insert goes in from
        // above and the tile then covers it.
        for (t = TILE_SCREW)
            translate([t[0], t[1], LEDGE_H - INSERT_H]) cylinder(d=INSERT_D, h=INSERT_H);
        // joint seats: bored UP from below, so nothing shows on the finished top
        for (j = JOINT_SEAT) translate([j[0], j[1], 0]) insert_bore();
        // Clearance for the Powerpole retainer's OUTBOARD bolt, which passes
        // through the ledge on its way down. The rail tile already has the hole
        // at tile-local (-13, -20); this lets the bolt continue.
        //
        // Drawn on both sides because the front members are one part mirrored.
        // The right-hand one is unused - a ⌀3.6 hole in a 10 mm ledge, 20 mm
        // from the nearest ledge screw, under a rail with no Powerpole in it.
        for (sx = [-1, 1])
            translate([sx*(RAIL_CX + PP_EAR/2), RAIL_CY - 20, -1])
                cylinder(d=M3_CLEAR, h=LEDGE_H + 2);
    }
}

// One of four L-shaped members, each carrying a corner, butt-jointed at the
// centre of every side - which is where a rib is (0 on all four walls), so each
// joint is directly supported and a notched splice ties it underneath.
//
// There are TWO distinct shapes, not one. The front rail is FRAME_WF (8) and
// the other three are FRAME_W (12), so a back member is not a front member
// turned round. Print two of each and mirror one of each in X. An earlier
// revision drew only the +x+y quadrant, which would have produced four back
// members and a frame that could not close.
module member(front = false) {
    intersection() {
        frame_full();
        translate([0, front ? -PLATE_D : 0, -TILE_BOSS_H - 1])
            cube([PLATE_W, PLATE_D, FRAME_H + TILE_BOSS_H + 2]);
    }
}

// Inserts are ruthex RX-M3x5.7 (ITEM GE-M3X57-001), and the bag publishes the
// hole: 5.7 long, knurl OD 4.6, install into a *4.0* hole *6.7 deep minimum*,
// with at least 1.6 mm of wall around it.
//
// Drawn 4.2 prints at 4.0 on this machine (S6 offset), so the diameter was
// right by luck. The DEPTH was not: 5 mm of hole for a 5.7 mm insert leaves it
// standing 0.7 proud, or pressed home by splitting the 1 mm skin on the
// visible face. "It fits" is the hole accepting the insert, which is not the
// same as the insert being seated in enough material.
//
// 6.7 of blind hole plus 1 mm of skin needs 7.7 mm of material and the member
// is 6. Rather than thicken the whole frame - which costs plate height, and
// S11 has only 3.5 mm of headroom under the rim - each hole gets a local boss
// on the UNDERSIDE, where there is 75 mm of nothing. The splice is
// counterbored to swallow the boss and still clamp flat.
// INSERT_D/H and BOSS_D/H come from deck.scad, which assert()s that the seat
// is deep enough for the insert and that a 4.5 tile is not.

// A blind insert seat, drilled up from z=0 into material above, with the boss
// that makes the depth. Call with the part's underside at z=0.
module insert_seat() {
    translate([0, 0, -BOSS_H]) cylinder(d=BOSS_D, h=BOSS_H);
}
module insert_bore() {
    translate([0, 0, -BOSS_H]) cylinder(d=INSERT_D, h=INSERT_H);
}

// Splice bar, screwed up into the rim's underside either side of a joint.
//
// HOW IT MEETS THE RIBS - corrected 2026-09-07 after the operator asked, which
// is the only reason it was ever checked.
//
// The frame sits ON the rib tops at 75. The ribs are fins standing 2 mm proud of
// the wall, so BELOW 75 the rib is solid material in the outermost 2 mm of the
// opening. The splice hangs below 75, and the plate's edge reaches 1.75 mm past
// a rib's inner face - so at every joint the splice's OUTER EDGE runs straight
// into the rib that the joint is deliberately placed over.
//
// The previous relief cut a 6 x 2.6 slot across the splice's TOP face. That
// clears a rib projecting DOWNWARD onto the splice, which is not what a rib
// does - its top is coplanar with the frame's underside, and all of it is below.
// The slot removed material where there was no conflict and left the conflict
// untouched. Written from a description, never drawn against a rib.
//
// The real relief is a SCALLOP in the outer edge: the rib is only 4 mm wide and
// sits at the joint centre, while the splice's screws are at +-14 and +-26, so
// 2.5 mm off the outer edge over 8 mm of length clears it and touches nothing.
RIB_RELIEF = max(RIB_OVERLAP_W, RIB_OVERLAP_D) + 0.75;   // 2.5
// ⚠️ TAUTOLOGY: RIB_RELIEF is defined as this max + 0.75.
assert(RIB_RELIEF > max(RIB_OVERLAP_W, RIB_OVERLAP_D),
       "splice relief is shallower than the rib it must clear");
assert(4 + 4 < 2*14 - SPL_CB_D,
       "splice rib relief reaches the nearest counterbore");
// Widened 10 -> 12 to match the member: it now has to carry a counterbore that
// swallows the member's ⌀8 insert boss, and 8 in 10 left 1 mm of wall.
// Thickened 4 -> 5 as well: the counterbore eats 2 mm, and 2 mm of web left
// under an M3 head is not enough to clamp a joint with.
SPL_L = 70; SPL_W = 12; SPL_T = 5;
SPL_CB_D = BOSS_D + 0.6;          // boss clearance
SPL_CB_H = BOSS_H + 0.3;          // so the splice clamps on the flat, not the boss
// Screw: 3.3 mm of splice web below the boss, then 5.7 of insert -> M3 x 10.
// M3 x 8 also works (4.7 mm of engagement); anything longer bottoms out.
module splice() {
    difference() {
        translate([-SPL_L/2, -SPL_W/2, 0]) cube([SPL_L, SPL_W, SPL_T]);
        // rib relief - OUTER EDGE (+y), the side that faces the case wall
        translate([-4, SPL_W/2 - RIB_RELIEF, -1])
            cube([8, RIB_RELIEF + 1, SPL_T + 2]);
        for (x = [-26, -14, 14, 26]) {
            // M3_CLEAR, not a literal. This was hardcoded 3.4 and was the one
            // place missed when M3_CLEAR went to 3.6 - which was widened for
            // exactly this case, two separately printed parts whose holes have
            // to line up. Found by measuring the solid, not by reading code.
            translate([x, 0, -1]) cylinder(d=M3_CLEAR, h=SPL_T + 2);
            translate([x, 0, SPL_T - SPL_CB_H]) cylinder(d=SPL_CB_D, h=SPL_CB_H + 1);
        }
    }
}

// Screen tile - the module face plus 1 mm all round, window centred.
// Spans the opening front back to just past the module, with the window over
// the active area - which is centred on the module, not on the plate.
TILE_BACK = MOD_FRONT + MOD_D + TILE_GAP;   // +28.25
// Trapped under the rails by a thin lap. CORRECTED 2026-09-09.
//
// The first version put the lap in the tile's BOTTOM 1.2 mm, coplanar with the
// body. That was wrong, and the reason is that tiles are DRAWN at z 0..TILE_T
// but INSTALLED at z LEDGE_H..FRAME_H - they sit on the ledge. So the rail's
// underside is not 1.5 above the screen tile's underside; the two are
// COPLANAR, both resting on the same ledge. A lap in the bottom layer lands in
// the rail's own space and holds the tile up. The operator found it as a tile
// that would not sit flat.
//
// The free space is BELOW that plane: under the rail's inner cantilever, from
// x 101 out to the ledge at 130.25, there is nothing between z 0 and 1.5. So
// the lap has to HANG below the body, not share its bottom face.
//
// It also has to stop short of the FRONT ledge, which does occupy z 0..1.5
// across the opening - a lap running the full depth would foul it, which is
// precisely where the tile was sitting proud.
LAP_W = 5;
LAP_T = 1.2;
assert(LAP_T < LEDGE_H, "screen tile lap is thicker than the gap under the rail");
assert(MOD_W + 2*TILE_GAP + 2*LAP_W <= BED, "screen tile with laps is off the bed");

module screen_tile() {
    w  = MOD_W + 2*TILE_GAP;
    y0 = OPEN_FRONT + LEDGE_WF + 1;      // clear of the front ledge
    d  = TILE_BACK - y0;
    difference() {
        union() {
            // body, lifted so the lap hangs beneath it
            translate([-w/2, OPEN_FRONT, LAP_T]) cube([w, TILE_BACK - OPEN_FRONT, TILE_T]);
            // side laps only, below the body, clear of the front ledge
            // overlapped 0.5 into the body: butted exactly at w/2 the union
            // leaves a coincident face and OpenSCAD reports a non-manifold
            for (sx = [-1, 1])
                translate([sx > 0 ? w/2 - 0.5 : -w/2 - LAP_W, y0, 0])
                    cube([LAP_W + 0.5, d, LAP_T]);
        }
        translate([-WIN_W/2, MOD_CY - WIN_D/2, -1]) cube([WIN_W, WIN_D, TILE_T + LAP_T + 2]);
        // The LEFT lap runs into the Powerpole retainer: the retainer's inboard
        // edge is at plate -104.625 and the lap reaches -106, giving
        // 1.375 x 14.8 x 1.2 = 24.42 mm3 - exactly what the assembly sweep
        // measured. Notched rather than shortened: a 3 mm lap everywhere would
        // be worse than a 5 mm one with a 17 mm window in it.
        translate([-w/2 - LAP_W - 1, RAIL_CY - 20 - 8.4, -1])
            cube([LAP_W + 1.5, 16.8, LAP_T + 1]);
    }
}

// Back channel tile, with the well the battery stands proud through. The pack
// tops out at 90 against a plate top of 81, so it projects ~9 mm - which is why
// the keyboard cannot lie here and returns to the lid (S11).
// Two fillers with the battery well open between them. One full-width tile
// would be 280.5 mm and will not print - check-stl.py caught it. Splitting
// around the well also means the well needs no bridging.
// The well follows the pack ENVELOPE, which is off-centre: body -50..+50 plus
// 6 mm of terminal on one end. A centred well would foul the terminals.
// WELL_X0/WELL_X1 are in deck.scad - the frame's ledge needs them too.
// Vent grille. S14 #7: the module's vents face DOWN into the plenum, and the
// plenum's back is wide open to the back channel across the full 200 x 26.5 -
// but the back channel itself was capped by these tiles, with nothing but the
// ring around the battery to breathe through. Slots here complete the path:
//
//     module vents -> plenum -> back channel -> THESE SLOTS -> open air
//
// They go in the BACK tiles and nowhere else. The screen tile sits over the
// module's TOP face, so slots there would open into the 2 mm foam gap and
// reach nothing; the rails are crowded with connectors and reach the plenum
// only through a 1 mm slot beside the module.
//
// 4 mm wide so nothing of consequence drops through, and inset 12 mm from
// every edge, which keeps them clear of the tile screws by construction.
VENT_W = 4; VENT_PITCH = 9; VENT_INSET = 12;

module vent_slots(x0, x1, y0, y1) {
    n = floor((x1 - x0 - VENT_W) / VENT_PITCH) + 1;
    span = (n - 1)*VENT_PITCH + VENT_W;
    for (i = [0 : n-1])
        translate([x0 + (x1 - x0 - span)/2 + i*VENT_PITCH, y0, -1])
            cube([VENT_W, y1 - y0, TILE_T + 2]);
}

module back_tile(side) {
    w  = side > 0 ? OPEN_W/2 - WELL_X1 : WELL_X0 + OPEN_W/2;
    d  = OPEN_BACK - TILE_BACK;
    x0 = side > 0 ? WELL_X1 : -OPEN_W/2;
    in_opening() difference() {
        translate([x0, TILE_BACK, 0]) cube([w, d, TILE_T]);
        tile_screws(x0 + w/2, TILE_BACK + d/2, w, d, 0, 0);
        vent_slots(x0 + VENT_INSET, x0 + w - VENT_INSET,
                   TILE_BACK + VENT_INSET, TILE_BACK + d - VENT_INSET);
    }
}

// Rail tile blank. Connector cutouts are NOT here yet - the keystone is
// unresolved (S8 #8) and the A/B selector is not bought, so two of the four
// have no dimensions. This exists to pin the usable width.
RAIL_D = TILE_BACK - OPEN_FRONT;                // matches the screen tile
module rail_blank() {
    translate([-RAIL_W/2, -RAIL_D/2, 0]) cube([RAIL_W, RAIL_D, TILE_T]);
}

// Left rail tile — power/RF. One switch now does master AND source select
// (CASE.md S5), so this carries three cutouts, not four:
//   rocker 28.7 x 21.2 (21.2 across the rail, 9 mm of tile each side)
//   Powerpole retainer pocket 16.2 x 8.5
//   SMA 6.7
// The keyboard covers the inboard 14 mm of this tile, so the SMA at 9.7 mm
// proud is placed OUTBOARD. The rocker at 2.0 mm proud sits on the keep-out
// line; its 35 x 25.3 bezel is broad enough to bear a keyboard without harm.
// APIELE DPDT ON-OFF-ON, vendor drawing 2026-09-05. Panel opening 28.5 x 21,
// bezel 35 x 25.3 +-0.3, body 27.5 deep, terminals 6.3 x 0.8 on 10.3 centres,
// rated 20A/125VAC and 16A/250VAC - both AC, there is no DC figure.
RK_W = 28.7; RK_L = 21.2;         // 28.5 x 21 + the 0.2 offset
RK_BEZ_W = 25.3; RK_BEZ_L = 35;   // across the rail / along it
// 2.0 - read off the drawing, then CONFIRMED on the part with calipers
// 2026-09-07. The step between the bezel underside and the snap catch, which is
// the panel thickness the switch is built for. Was guessed at 1.2, and matches
// the USB's coupon-tested 2.0 exactly. Settled.
RK_WEB = 2.0;
// PP_* are in deck.scad with the measured pin geometry.
REBATE = 3;                       // relief margin around a snapped-in part
// SMA_D and AUDIO_D live in deck.scad with the rest of the connector openings.

module rebated(cx, cy, w, l, web, margin=REBATE) {
    translate([cx - w/2 - margin, cy - l/2 - margin, web])
        cube([w + 2*margin, l + 2*margin, TILE_T]);
    translate([cx - w/2, cy - l/2, -1]) cube([w, l, TILE_T + 2]);
}

// Everything a rail carries, as [name, centre y, kind, across, along, extra].
// All cutouts are centred across the rail, so position is one number.
//
// The table is the ONLY description - rail_tile() draws from it. An earlier
// revision had the table sitting BESIDE hard-coded cutouts, checking itself
// while the geometry went its own way: the same two-descriptions-of-one-thing
// that produced the plinth and the cradle. A collision check that cannot see
// the geometry it guards is decoration.
LEFT_FEATURES = [
    ["SMA",       -50, "round",  SMA_D,   SMA_D],
    ["audio",       0, "round_rb", AUDIO_D, AUDIO_D, AUDIO_RB_D, AUDIO_WEB],
    ["Powerpole", -20, "pp",     PP_W,    PP_H],
    // 21 ACROSS the rail, 28.5 along. An earlier revision had this the other
    // way up, putting 28.7 across a 39.25 tile - 5.27 mm of material each side,
    // which S3 had already written down as "too thin". The doc said one thing
    // and the geometry did the other, and nothing compared them.
    ["rocker",     30, "rebate", RK_L, RK_W, RK_WEB, RK_BEZ_W, RK_BEZ_L],
];

// Right rail tile — data. Two panel-mount extensions, both fitted from behind
// so the front stays flush under the keyboard:
//   dual USB   21.5 x 24.5, web 2.0 (test-fitted 2026-09-04)
//   RJ45       16.6 x 13.6 aperture + 2 x M3, ears ALONG the rail
// The RJ45 is 37 mm ear-to-ear; across a 39 mm tile that would leave 1 mm,
// so it runs lengthwise. Ear spacing PROVISIONAL until the part lands.
//
// The ears are NOT taken by heat-set inserts. An insert needs 5 mm of depth
// plus a skin, and the tile is 4.5 mm; a boss added under the tile to make up
// the difference would hold the ear off the surface it is meant to clamp
// against. So: plain through-holes, countersunk on the FRONT face. The head
// finishes flush under the keyboard, and it works whether the ears turn out
// threaded or plain-with-a-nut - which is still unknown until the part lands.
USB_W = 21.5; USB_L = 24.5; USB_WEB = 2.0;
USB_BEZ_W = 25.4; USB_BEZ_L = 28.6;   // vendor sheet
// MEASURED on the part 2026-09-07, and it corrects the aperture, not just the
// ear spacing. The body is 15.7 x 15.5 - very nearly SQUARE. This file had
// 16.6 x 13.6, derived from a listing's "jack face 16 x 13", so the aperture
// was 1.9 mm too SHORT in one axis and the connector would not have gone in.
// The tile would have printed unusable. Nothing catches that but a caliper.
RJ_BODY_W = 15.7; RJ_BODY_L = 15.5;
RJ_W = RJ_BODY_W + 0.2 + 0.3;     // 16.2 - print offset plus 0.3 clearance
RJ_L = RJ_BODY_L + 0.2 + 0.3;     // 16.0
RJ_EAR = 27.5;                    // hole centres, measured (was 31, a guess)
RJ_EAR_T = 7;                     // ear thickness - sets the screw length
// EARS GO BEHIND THE PLATE. Confirmed with the operator 2026-09-07, and it is
// what sets the aperture: mounted from behind, only the socket nose passes
// through, so the hole is the nose's 15.7 x 15.5. Mounted from the FRONT the
// wider rear body would have to pass instead - about 22 x 22 - and the ears and
// screw heads would sit on the show face.
//
// Behind wins twice: a 22 hole leaves 8.6 mm of tile each side against 11.8,
// and the front stays clean. It is also what S3 has specified all along.
// Ears are THREADED (operator 2026-09-07), so no nut: M3 x 12 countersunk,
// 4.5 through the tile and ~7 of engagement in the ear.
//
// Socket nose finishes NEARLY FLUSH with the tile's front face, so the tile
// needs no relief - unlike the audio jack, which is the same class of part and
// did. Checked because a recessed socket would put a plug's latch out of reach.
assert(RJ_EAR + RJ_CSK_D <= RAIL_D, "RJ45 ears run off the end of the rail");
RJ_CLEAR = 3.6;                   // M3 clearance, drawn 0.2 over (holes print
                                  // undersize) AND for slop across two ears
RJ_CSK_D = 6.4;                   // M3 90 deg countersunk head, same 0.2

RIGHT_FEATURES = [
    ["RJ45",     -20, "rj45",   RJ_W,  RJ_L],
    ["dual USB",  34, "rebate", USB_W, USB_L, USB_WEB, USB_BEZ_W, USB_BEZ_L],
];

// The space a cutout really occupies, which is not always the hole. A rebate
// needs REBATE of relief all round; the RJ45's footprint is set by its screw
// ears and their heads, not by the aperture between them.
// rebated() sinks the bezel into the relief pocket, so the pocket has to be
// bigger than the BEZEL, not just than the opening. Derived, because the rocker
// needed 3.65 and a flat REBATE of 3 gave 3 - a 34.7 pocket for a 35 bezel,
// which does not go in.
function rb_margin(f) = max(REBATE, (f[6] - f[3])/2 + 0.5, (f[7] - f[4])/2 + 0.5);
function f_across(f) =
    f[2] == "pp"       ? PP_EAR + RJ_CSK_D :
    f[2] == "rebate"   ? f[3] + 2*rb_margin(f) :
    f[2] == "rj45"     ? max(f[3], RJ_CSK_D) :
    f[2] == "round_rb" ? f[5] : f[3];
function f_along(f) =
    f[2] == "pp"       ? max(f[4], RJ_CSK_D) :
    f[2] == "rebate"   ? f[4] + 2*rb_margin(f) :
    f[2] == "rj45"     ? RJ_EAR + RJ_CSK_D :
    f[2] == "round_rb" ? f[5] : f[4];

// A sunk bezel must actually fit the pocket cut for it.
for (r = RAILS) for (f = r[1]) if (f[2] == "rebate") {
    assert(f[3] + 2*rb_margin(f) >= f[6], str(f[0], " bezel is wider than its pocket"));
    assert(f[4] + 2*rb_margin(f) >= f[7], str(f[0], " bezel is longer than its pocket"));
}

// Both rails, checked by the same three rules.
RAILS = [["left", LEFT_FEATURES], ["right", RIGHT_FEATURES]];
for (r = RAILS) for (f = r[1]) {
    assert(f_across(f) <= RAIL_W, str(f[0], " is wider than the ", r[0], " rail"));
    assert(abs(f[1]) + f_along(f)/2 <= RAIL_D/2,
           str(f[0], " runs off the end of the ", r[0], " rail"));
}
for (r = RAILS) for (i = [0 : len(r[1])-2], j = [i+1 : len(r[1])-1])
    assert(abs(r[1][i][1] - r[1][j][1]) >= (f_along(r[1][i]) + f_along(r[1][j]))/2,
           str(r[1][i][0], " overlaps ", r[1][j][0], " on the ", r[0], " rail"));

// Every through-cut goes through this, so none can be accidentally blind.
// The old Powerpole pocket was written as cube(..., center=true) translated to
// z=0, which spans -3.25..+3.25 in a 4.5 mm tile: it left 1.25 mm of material
// across the top and was never a hole at all. Centring in x and y is wanted;
// centring in z is a bug, and the two look identical in one call.
module through(cy, w, l) {
    translate([0, cy, TILE_T/2]) cube([w, l, TILE_T + 2], center=true);
}

module feature(f) {
    if      (f[2] == "round")  translate([0, f[1], -1]) cylinder(d=f[3], h=TILE_T + 2);
    // Round, with the tile relieved from BEHIND so a short thread can reach
    // through. z=TILE_T is the front face, so the pocket opens at z=0.
    // Powerpole: the pocket the pair passes through, plus two countersunk
    // screws that pull the retainer up against the tile's back face.
    else if (f[2] == "pp") {
        through(f[1], f[3] + 0.2 + PP_SLIP, f[4] + 0.2 + PP_SLIP);
        for (x = [-PP_EAR/2, PP_EAR/2]) translate([x, f[1], 0]) tile_screw();
    }
    else if (f[2] == "round_rb") {
        translate([0, f[1], -1]) cylinder(d=f[3], h=TILE_T + 2);
        translate([0, f[1], -1]) cylinder(d=f[5], h=TILE_T - f[6] + 1);
    }
    else if (f[2] == "rect")   through(f[1], f[3], f[4]);
    else if (f[2] == "rebate") rebated(0, f[1], f[3], f[4], f[5], rb_margin(f));
    else if (f[2] == "rj45") {
        through(f[1], f[3], f[4]);
        for (y = [f[1] - RJ_EAR/2, f[1] + RJ_EAR/2]) {
            translate([0, y, -1]) cylinder(d=RJ_CLEAR, h=TILE_T + 2);
            translate([0, y, TILE_T - (RJ_CSK_D - RJ_CLEAR)/2])
                cylinder(d1=RJ_CLEAR, d2=RJ_CSK_D, h=(RJ_CSK_D - RJ_CLEAR)/2 + 0.01);
        }
    }
    else assert(false, str(f[0], " has an unknown cutout kind"));
}

// The opening the tiles drop into has ROUNDED corners - radius CORNER_R minus
// FRAME_W, so 6. Four of the five tiles reach one of those corners and were
// drawn as plain rectangles with square corners, which foul the frame's fillet
// and hold the tile up. Found by the operator fitting a printed back tile,
// 2026-09-07.
//
// Rather than round each tile by hand, every tile is intersected with the
// OPENING'S OWN PROFILE - the same rr() call frame_full() uses. A tile cannot
// then disagree with the frame about its corners, whatever the radius becomes.
OPEN_R = CORNER_R - FRAME_W;      // 6

module in_opening() {
    intersection() {
        children();
        translate([0, OPEN_CY, -1]) rr(OPEN_W, OPEN_D, OPEN_R, TILE_T + 2);
    }
}

// A countersunk clearance hole, head flush with the tile top.
module tile_screw() {
    translate([0, 0, -1]) cylinder(d=RJ_CLEAR, h=TILE_T + 2);
    translate([0, 0, TILE_T - (RJ_CSK_D - RJ_CLEAR)/2])
        cylinder(d1=RJ_CLEAR, d2=RJ_CSK_D, h=(RJ_CSK_D - RJ_CLEAR)/2 + 0.01);
}
// The screws from the shared list that fall inside this tile's footprint, with
// the tile's own origin subtracted. Filtering rather than re-listing is what
// stops a tile and the frame disagreeing about where a screw is.
// (cx, cy, w, d) is the tile's footprint in PLATE coordinates; (ox, oy) is the
// origin the tile is actually DRAWN about. The rails are drawn centred on
// themselves, so ox = cx; the back tiles are drawn in plate coordinates, so
// ox = 0. Passing the wrong one puts the holes somewhere the tile is not and
// they silently cut nothing - which is exactly what happened to both back
// tiles, and no assertion saw it because the screw LIST was correct.
module tile_screws(cx, cy, w, d, ox, oy) {
    for (t = TILE_SCREW)
        if (abs(t[0] - cx) < w/2 && abs(t[1] - cy) < d/2)
            translate([t[0] - ox, t[1] - oy, 0]) tile_screw();
}

RAIL_CX = (MOD_W/2 + TILE_GAP + OPEN_W/2)/2;    // 120.625
RAIL_CY = (OPEN_FRONT + TILE_BACK)/2;           // -39.5

module rail_tile(features, side) {
    translate([-side*RAIL_CX, -RAIL_CY, 0]) in_opening()
        translate([side*RAIL_CX, RAIL_CY, 0]) difference() {
            translate([-RAIL_W/2, -RAIL_D/2, 0]) cube([RAIL_W, RAIL_D, TILE_T]);
            for (f = features) feature(f);
            tile_screws(side*RAIL_CX, RAIL_CY, RAIL_W, RAIL_D, side*RAIL_CX, RAIL_CY);
        }
}
module left_rail()  { rail_tile(LEFT_FEATURES, -1); }
module right_rail() { rail_tile(RIGHT_FEATURES,  1); }

// Powerpole retainer - the part that waited for a measurement.
//
// A bonded PP15-45 pair is a constant cross-section with no shoulder, so a
// plain pocket cannot hold it: pull the plug and the pair comes with it. The
// 3/32" roll pin is the only feature on the housing that can take that load.
//
// Measured 2026-09-07: mating face to pin centre 9.5, pin 2.38, hole runs
// through the 8.5 mm axis, housing 24.6 long. With the mating face flush at
// the tile's front, the pin sits 9.5 - 4.5 = 5.0 BEHIND the tile - inside this
// block, with 5 mm of wall in front of it to take the pull.
//
// The pin passes through retainer wall, housing, retainer wall: DOUBLE shear,
// and captive once fitted. Assembly is push the pair home from behind, then
// push the pin through.
//
// ⚠️ 16.2 x 8.5 is taken as the CONNECTOR's cross-section, not an already-
// clearanced pocket. If it was the latter the pocket ends up ~0.5 loose, which
// the pin makes harmless - retention is the pin's job, not the pocket's.
module pp_retainer() {
    ow = PP_EAR + 6;
    od = PP_H + 2*PP_WALL + PP_SLIP;
    pw = PP_W + 0.2 + PP_SLIP;
    pd = PP_H + 0.2 + PP_SLIP;
    difference() {
        translate([-ow/2, -od/2, 0]) cube([ow, od, PP_DEPTH]);
        translate([-pw/2, -pd/2, -1]) cube([pw, pd, PP_DEPTH + 2]);
        // pin, through both walls and the housing between them
        translate([0, 0, PP_A - TILE_T]) rotate([90, 0, 0])
            cylinder(d=PP_PIN + 0.2, h=od + 2, center=true);
        // TWO through-bolts with captive nuts, both INBOARD, straddling the
        // pocket along the rail. See deck.scad for why the outboard position is
        // unusable and why a nut beats a heat-set insert here.
        for (x = [-PP_EAR/2, PP_EAR/2]) {
            translate([x, 0, -1]) cylinder(d=M3_CLEAR, h=PP_DEPTH + 2);
            translate([x, 0, -1]) cylinder(d=NUT_AF/cos(30), h=NUT_POCK + 1, $fn=6);
        }
        // Ledge relief: the outboard end loses its top LEDGE_H so the frame's
        // ledge passes over it. PP_EAR = 26 was sized against the rail's 39.25
        // width and never against what is UNDERNEATH the rail - the assembly
        // sweep found 141.53 mm3 of this part inside member_FL's ledge.
        translate([-ow/2 - 1, -od/2 - 1, PP_DEPTH - LEDGE_H])
            cube([ow/2 - 9.625 + 1, od + 2, LEDGE_H + 1]);
    }
}


// Front joint strap - BONDED, not bolted, and the reason is arithmetic.
//
// A narrower splice fixes the wall interference but NOT the other conflict: the
// ⌀8 boss itself is 1.2 mm inside the module. And that is true for ANY seat
// position in an 8 mm rail - the boss cannot go outboard of the plate edge, so
// its inboard face always reaches past the module's front face at -110.25.
// There is no boss-and-splice arrangement that fits. The fastening has to
// change, not its size.
//
// What IS free is the band between the plate's edge and the module's front
// face: 5 mm wide, and nothing below it for the full 70 mm down to the tray.
// A strap bonded into that band ties the joint using only space nobody wants.
//
// It needs NO change to the members - the two already printed stay good, and
// their front insert seats simply go unused.
//
// PERMANENT. Epoxy, not CA: PETG does not solvent-weld and CA is brittle in
// peel. Key both faces with abrasive first. The other three joints stay
// bolted, so the frame still comes apart along its length.
FS_LEN = 60;                      // +-30 either side of the joint
// FS_W is in deck.scad, asserted against the band it has to fit.
FS_H   = 5;
FS_RIB = RIB_OVERLAP_D + 0.75;    // scallop for the rib under the joint

module front_strap() {
    difference() {
        cube([FS_LEN, FS_W, FS_H]);
        // rib relief, outer edge, at the joint centre
        translate([FS_LEN/2 - 4, -1, -1]) cube([8, FS_RIB + 1, FS_H + 2]);
    }
}

// Plate preload strip - print TWO, in TPU (S14 #4).
//
// It replaces the keyboard as the thing the lid foam presses on. Sits on a SIDE
// frame member, whose 12 mm band runs from the opening edge out to the plate
// edge and is clear of every connector - those are all on the rail tiles,
// inboard of it. Directly over the three side ribs, so the load lands where the
// plate is carried rather than in the middle, where it would only push on the
// module.
//
// Drawn SOLID on purpose. The compliance is a slicer setting - print in TPU at
// about 10% gyroid with two perimeters, which behaves like firm foam. Modelling
// a lattice would fix the stiffness in the geometry, where it cannot be tuned.
//
// 20 mm against a 19 mm recess, so it is squeezed 1 mm when the lid shuts. If
// the latches will not close, reprint at 19 or 18 - it is a ten minute part.
module preload_strip() {
    cube([FRAME_W, SPACER_L, SPACER_H]);
}

// One joint: two SEPARATE bars plus the splice, laid out flat on the bed.
// An earlier revision drew the bars meeting at x=0, so OpenSCAD unioned them
// into one continuous 80 mm bar - it printed as a single piece and tested
// nothing. They are now distinct objects with clear space between them.
//
// Insert holes are blind FROM BELOW, leaving 1 mm of material on top, so
// nothing shows on the finished plate. That is how the real members will be.
//

module joint_bar() {
    difference() {
        union() {
            cube([40, FRAME_W, FRAME_H]);
            for (x = [14, 26]) translate([x, FRAME_W/2, 0]) insert_seat();
        }
        for (x = [14, 26]) translate([x, FRAME_W/2, 0]) insert_bore();
    }
}

// Exported ALREADY THE RIGHT WAY UP: bars flipped so their flat visible face is
// on the bed and the insert bosses point at the ceiling. Bosses-down would ask
// the slicer to bridge a 40 x 12 bar across two 8 mm circles, and "remember to
// flip it" is not a build instruction, it is a future mistake.
module bar_for_bed() {
    translate([0, FRAME_W, FRAME_H]) rotate([180, 0, 0]) joint_bar();
}
module joint_test() {
    bar_for_bed();
    translate([0, FRAME_W + 6, 0]) bar_for_bed();
    translate([20, 2*(FRAME_W + 6) + 10, 0]) splice();
}

// Every screw the frame puts a seat under must be claimed by exactly one tile.
// Without this the frame can grow a seat that no tile has a hole for (a boss
// holding the tile off the ledge) or a tile can be missed entirely.
TILE_FOOTPRINT = [
    ["left rail",  -RAIL_CX,        RAIL_CY,                   RAIL_W, RAIL_D],
    ["right rail",  RAIL_CX,        RAIL_CY,                   RAIL_W, RAIL_D],
    ["back left",  (-OPEN_W/2 + WELL_X0)/2, (TILE_BACK + OPEN_BACK)/2,
                    WELL_X0 + OPEN_W/2,      OPEN_BACK - TILE_BACK],
    ["back right",  (OPEN_W/2 + WELL_X1)/2, (TILE_BACK + OPEN_BACK)/2,
                    OPEN_W/2 - WELL_X1,      OPEN_BACK - TILE_BACK],
];
function claims(t) = len([for (f = TILE_FOOTPRINT)
    if (abs(t[0] - f[1]) < f[3]/2 && abs(t[1] - f[2]) < f[4]/2) 1]);
for (t = TILE_SCREW)
    assert(claims(t) == 1,
           str("tile screw at ", t, " is claimed by ", claims(t), " tiles, not 1"));

// A vent slot must never land on a tile screw.
for (side = [-1, 1]) {
    w  = side > 0 ? OPEN_W/2 - WELL_X1 : WELL_X0 + OPEN_W/2;
    x0 = side > 0 ? WELL_X1 : -OPEN_W/2;
    for (t = TILE_SCREW)
        assert(!(t[0] > x0 + VENT_INSET - VENT_W && t[0] < x0 + w - VENT_INSET
                 && t[1] > TILE_BACK + VENT_INSET
                 && t[1] < OPEN_BACK - VENT_INSET),
               str("vent grille runs over the tile screw at ", t));
}

// The five tiles must cover the opening exactly - no gap, no overlap. Each is
// sized from a different chain of constants (the screen tile from the module,
// the rails from what is left over, the back tiles from the battery envelope),
// and nothing until now added them up.
assert(MOD_W + 2*TILE_GAP + 2*RAIL_W == OPEN_W,
       "screen tile + two rails do not fill the opening's width");
assert((TILE_BACK - OPEN_FRONT) + (OPEN_BACK - TILE_BACK) == OPEN_D,
       "tiles do not fill the opening's depth");
assert((WELL_X0 + OPEN_W/2) + (WELL_X1 - WELL_X0) + (OPEN_W/2 - WELL_X1) == OPEN_W,
       "back tiles plus the battery well do not fill the opening's width");
assert(WELL_X0 < BATT_X0 && WELL_X1 > BATT_X1,
       "battery well does not clear the pack");

// Derived from what frame_full() actually DRAWS, not from the intended formula.
// The old version of this assertion recomputed the ledge inner edge from
// FRAME_WF + LEDGE_WF and passed happily while the drawn ledge was 5 mm wider
// and sitting over the screen. A check that restates its subject cannot see the
// subject being wrong.
assert(MOD_CY - WIN_D/2 >= LEDGE_CY - LEDGE_ID/2,
       "front ledge overlaps the screen's active area");
// The back-ledge tile screws must sit ON the back ledge, not on its edge.
for (t = TILE_SCREW) if (t[1] > 90)
    assert(t[1] - BOSS_D/2 >= LEDGE_CY + LEDGE_ID/2 &&
           t[1] + BOSS_D/2 <= OPEN_BACK,
           str("back-ledge screw at ", t, " hangs off the ledge"));

// Members carry bosses below z=0. Exported FLIPPED, for the same reason as the
// joint coupon: visible face on the bed, every boss pointing up.
module member_for_bed(front) {
    translate([0, 0, FRAME_H]) rotate([180, 0, 0]) member(front);
}
if      (PART == "member")       member_for_bed(false);
else if (PART == "member_front") member_for_bed(true);
else if (PART == "splice")     splice();
else if (PART == "screen_tile") screen_tile();
else if (PART == "rail_blank") rail_blank();
else if (PART == "back_left")  back_tile(-1);
else if (PART == "back_right") back_tile(1);
else if (PART == "preload")    preload_strip();
else if (PART == "front_strap") front_strap();
else if (PART == "pp_retainer") pp_retainer();
else if (PART == "left_rail")  left_rail();
else if (PART == "right_rail") right_rail();
else if (PART == "joint_test") joint_test();
else if (PART == "frame_full") frame_full();
else { frame_full(); translate([0,0,20]) screen_tile(); }
