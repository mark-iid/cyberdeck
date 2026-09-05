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
// PLATE_W/PLATE_D and FRAME_W/FRAME_WF are in deck.scad, where the bearing
// they produce on the rib shelf is assert()ed against the case interior.
CORNER_R = 18;

LEDGE_W  = 10;    // ledge reaching further inward, under the tiles
LEDGE_WF = 5;     // and narrowed at the front for the same reason
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
LEDGE_CY = OPEN_CY + (LEDGE_W - LEDGE_WF)/2;
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
        rr(PLATE_W, PLATE_D, CORNER_R, FRAME_H);
        translate([0, OPEN_CY, -1]) rr(OPEN_W, OPEN_D, CORNER_R - FRAME_W, FRAME_H + 2);
    }
    difference() {
        translate([0, OPEN_CY, 0]) rr(OPEN_W, OPEN_D, CORNER_R - FRAME_W, LEDGE_H);
        translate([0, LEDGE_CY, -1]) rr(LEDGE_IW, LEDGE_ID, 1, LEDGE_H + 2);
    }
}

// One of four L-shaped members, each carrying a corner, butt-jointed at the
// centre of every side - which is where a rib is (0 on all four walls), so each
// joint is directly supported and a notched splice ties it underneath.
module member() {
    intersection() {
        frame_full();
        translate([0, 0, -1]) cube([PLATE_W, PLATE_D, FRAME_H + 2]);
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
// Notched to clear the 4 x 2 mm rib that sits directly under that joint.
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
        translate([-3, -SPL_W/2 - 1, SPL_T - 2.6]) cube([6, SPL_W + 2, 3]);   // rib relief
        for (x = [-26, -14, 14, 26]) {
            translate([x, 0, -1]) cylinder(d=3.4, h=SPL_T + 2);
            translate([x, 0, SPL_T - SPL_CB_H]) cylinder(d=SPL_CB_D, h=SPL_CB_H + 1);
        }
    }
}

// Screen tile - the module face plus 1 mm all round, window centred.
// Spans the opening front back to just past the module, with the window over
// the active area - which is centred on the module, not on the plate.
TILE_BACK = MOD_FRONT + MOD_D + TILE_GAP;   // +28.25
module screen_tile() {
    w = MOD_W + 2*TILE_GAP;
    difference() {
        translate([-w/2, OPEN_FRONT, 0]) cube([w, TILE_BACK - OPEN_FRONT, TILE_T]);
        translate([-WIN_W/2, MOD_CY - WIN_D/2, -1]) cube([WIN_W, WIN_D, TILE_T + 2]);
    }
}

// Back channel tile, with the well the battery stands proud through. The pack
// tops out at 90 against a plate top of 81, so it projects ~9 mm - which is why
// the keyboard cannot lie here and returns to the lid (S11).
// Two fillers with the battery well open between them. One full-width tile
// would be 280.5 mm and will not print - check-stl.py caught it. Splitting
// around the well also means the well needs no bridging.
WELL_W = BATT_W + 2;
module back_tile(side) {
    x0 = side > 0 ? WELL_W/2 : -OPEN_W/2;
    translate([x0, TILE_BACK, 0])
        cube([OPEN_W/2 - WELL_W/2, OPEN_BACK - TILE_BACK, TILE_T]);
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
RK_W = 28.7; RK_L = 21.2;
RK_WEB = 1.2;                     // PROVISIONAL - the `rocker` coupon settles it
PP_W = 16.2; PP_H = 8.5;
SMA_D = 6.7;
REBATE = 3;                       // relief margin around a snapped-in part

module rebated(cx, cy, w, l, web, margin=REBATE) {
    translate([cx - w/2 - margin, cy - l/2 - margin, web])
        cube([w + 2*margin, l + 2*margin, TILE_T]);
    translate([cx - w/2, cy - l/2, -1]) cube([w, l, TILE_T + 2]);
}

module left_rail() {
    outb = RAIL_W - 12;           // 27: outboard band the keyboard does not cover
    difference() {
        translate([-RAIL_W/2, -RAIL_D/2, 0]) cube([RAIL_W, RAIL_D, TILE_T]);
        rebated(0, 30, RK_W, RK_L, RK_WEB);                 // rocker, centred across
        translate([RAIL_W/2 - outb/2 - 6, -20, 0])
            cube([PP_W, PP_H, TILE_T + 2], center=true);    // Powerpole retainer
        translate([RAIL_W/2 - outb/2 - 6, -50, -1])
            cylinder(d=SMA_D, h=TILE_T + 2);                 // SMA, outboard
    }
}

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
RJ_W = 16.6; RJ_L = 13.6;
RJ_EAR = 31;                      // PROVISIONAL - confirm on arrival (S8 #8)
RJ_CLEAR = 3.6;                   // M3 clearance, drawn 0.2 over (holes print
                                  // undersize) AND for slop across two ears
RJ_CSK_D = 6.4;                   // M3 90 deg countersunk head, same 0.2

module right_rail() {
    difference() {
        translate([-RAIL_W/2, -RAIL_D/2, 0]) cube([RAIL_W, RAIL_D, TILE_T]);
        rebated(0, 34, USB_W, USB_L, USB_WEB);
        translate([-RJ_W/2, -20 - RJ_L/2, -1]) cube([RJ_W, RJ_L, TILE_T + 2]);
        for (y = [-20 - RJ_EAR/2, -20 + RJ_EAR/2]) {
            translate([0, y, -1]) cylinder(d=RJ_CLEAR, h=TILE_T + 2);
            translate([0, y, TILE_T - (RJ_CSK_D - RJ_CLEAR)/2])
                cylinder(d1=RJ_CLEAR, d2=RJ_CSK_D, h=(RJ_CSK_D - RJ_CLEAR)/2 + 0.01);
        }
    }
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

// Bars are lifted by BOSS_H so the bosses hang inside the part rather than
// below the bed. Print boss-side UP: the visible face goes on the glass.
module joint_test() {
    translate([0, 0, BOSS_H]) joint_bar();
    translate([0, FRAME_W + 6, BOSS_H]) joint_bar();
    translate([20, 2*(FRAME_W + 6) + 10, 0]) splice();
}

if      (PART == "member")     member();
else if (PART == "splice")     splice();
else if (PART == "screen_tile") screen_tile();
else if (PART == "rail_blank") rail_blank();
else if (PART == "back_left")  back_tile(-1);
else if (PART == "back_right") back_tile(1);
else if (PART == "left_rail")  left_rail();
else if (PART == "right_rail") right_rail();
else if (PART == "joint_test") joint_test();
else if (PART == "frame_full") frame_full();
else { frame_full(); translate([0,0,20]) screen_tile(); }
