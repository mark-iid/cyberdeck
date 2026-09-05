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

PART = "all";

PLATE_W = 304;    // 1 mm clearance in a 305.0 opening; bearing = P - 303 (S4)
PLATE_D = 229;
CORNER_R = 18;

FRAME_W = 12;     // section width, inward from the outer edge
FRAME_H = 6;      // full height of the rim
LEDGE_W = 10;     // ledge reaching further inward, under the tiles
LEDGE_H = 1.5;    // so a 4.5 tile sits flush with the 6 mm rim (S12)
TILE_T  = 4.5;

MOD_W = 200; MOD_D = 137.5;      // measured 2026-09-04
WIN_W = 173; WIN_D = 118;        // active area, centred
TILE_GAP = 1;                    // clearance of screen tile around the module

RIB_X = [-74.5, 0, 74.5];
$fn = 64;

OPEN_W = PLATE_W - 2*FRAME_W;    // 280
OPEN_D = PLATE_D - 2*FRAME_W;    // 205
LEDGE_IW = OPEN_W - 2*LEDGE_W;   // 260
LEDGE_ID = OPEN_D - 2*LEDGE_W;   // 185

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
    ring(PLATE_W, PLATE_D, CORNER_R, OPEN_W, OPEN_D, CORNER_R - FRAME_W, FRAME_H);
    ring(OPEN_W, OPEN_D, CORNER_R - FRAME_W, LEDGE_IW, LEDGE_ID, 1, LEDGE_H);
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

// Splice bar, screwed up into the rim's underside either side of a joint.
// Notched to clear the 4 x 2 mm rib that sits directly under that joint.
SPL_L = 70; SPL_W = 10; SPL_T = 4;
module splice() {
    difference() {
        translate([-SPL_L/2, -SPL_W/2, 0]) cube([SPL_L, SPL_W, SPL_T]);
        translate([-3, -SPL_W/2 - 1, SPL_T - 2.6]) cube([6, SPL_W + 2, 3]);   // rib relief
        for (x = [-26, -14, 14, 26])
            translate([x, 0, -1]) cylinder(d=3.4, h=SPL_T + 2);
    }
}

// Screen tile - the module face plus 1 mm all round, window centred.
module screen_tile() {
    w = MOD_W + 2*TILE_GAP; d = MOD_D + 2*TILE_GAP;
    difference() {
        translate([-w/2, -d/2, 0]) cube([w, d, TILE_T]);
        translate([-WIN_W/2, -WIN_D/2, -1]) cube([WIN_W, WIN_D, TILE_T + 2]);
    }
}

// Rail tile blank. Connector cutouts are NOT here yet - the keystone is
// unresolved (S8 #8) and the A/B selector is not bought, so two of the four
// have no dimensions. This exists to pin the usable width.
RAIL_W = (OPEN_W - (MOD_W + 2*TILE_GAP)) / 2;   // 39
module rail_blank() {
    translate([-RAIL_W/2, -(MOD_D + 2*TILE_GAP)/2, 0])
        cube([RAIL_W, MOD_D + 2*TILE_GAP, TILE_T]);
}

// Left rail tile — power/RF. One switch now does master AND source select
// (CASE.md S5), so this carries three cutouts, not four:
//   rocker 28.7 x 21.2 (21.2 across the rail, 9 mm of tile each side)
//   Powerpole retainer pocket 16.2 x 8.5
//   SMA 6.7
// The keyboard covers the inboard 14 mm of this tile, so the SMA at 9.7 mm
// proud is placed OUTBOARD. The rocker at 2.0 mm proud sits on the keep-out
// line; its 35 x 25.3 bezel is broad enough to bear a keyboard without harm.
RAIL_D   = MOD_D + 2*TILE_GAP;    // 139.5
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

// Right rail tile — data. Two panel-mount extensions, both screwed or
// clipped from behind so the front stays flush under the keyboard:
//   dual USB   21.5 x 24.5, web 2.0 (test-fitted 2026-09-04)
//   RJ45       16.6 x 13.6 aperture + 2 x M3, ears ALONG the rail
// The RJ45 is 37 mm ear-to-ear; across a 39 mm tile that would leave 1 mm,
// so it runs lengthwise. Ear spacing PROVISIONAL until the part lands.
USB_W = 21.5; USB_L = 24.5; USB_WEB = 2.0;
RJ_W = 16.6; RJ_L = 13.6;
RJ_EAR = 31;                      // PROVISIONAL - confirm on arrival (S8 #8)
M3_INSERT = 4.2;

module right_rail() {
    difference() {
        translate([-RAIL_W/2, -RAIL_D/2, 0]) cube([RAIL_W, RAIL_D, TILE_T]);
        rebated(0, 34, USB_W, USB_L, USB_WEB);
        translate([-RJ_W/2, -20 - RJ_L/2, -1]) cube([RJ_W, RJ_L, TILE_T + 2]);
        for (y = [-20 - RJ_EAR/2, -20 + RJ_EAR/2])
            translate([0, y, TILE_T - 4.0]) cylinder(d=M3_INSERT, h=5);
    }
}

// One joint: two SEPARATE bars plus the splice, laid out flat on the bed.
// An earlier revision drew the bars meeting at x=0, so OpenSCAD unioned them
// into one continuous 80 mm bar - it printed as a single piece and tested
// nothing. They are now distinct objects with clear space between them.
//
// Insert holes are blind FROM BELOW, leaving 1 mm of material on top, so
// nothing shows on the finished plate. That is how the real members will be.
INSERT_D = 4.2;    // M3 heat-set. Confirm against the operator's inserts -
INSERT_H = 5;      // this number propagates to every printed part in the build.

module joint_bar() {
    difference() {
        cube([40, FRAME_W, FRAME_H]);
        for (x = [14, 26])
            translate([x, FRAME_W/2, -1]) cylinder(d=INSERT_D, h=INSERT_H + 1);
    }
}

module joint_test() {
    joint_bar();
    translate([0, FRAME_W + 6, 0]) joint_bar();
    translate([20, 2*(FRAME_W + 6) + 10, 0]) splice();
}

if      (PART == "member")     member();
else if (PART == "splice")     splice();
else if (PART == "screen_tile") screen_tile();
else if (PART == "rail_blank") rail_blank();
else if (PART == "left_rail")  left_rail();
else if (PART == "right_rail") right_rail();
else if (PART == "joint_test") joint_test();
else if (PART == "frame_full") frame_full();
else { frame_full(); translate([0,0,20]) screen_tile(); }
