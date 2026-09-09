// cyberdeck — floor chassis: module plinth (tray and cradle to follow).
//
// The module's screen must finish level with the rib shelf at 75 mm (CASE.md S12).
// Module is 44 mm thick (measured) and the plinth does NOT stand on the floor -
// it bolts down onto the 4 mm floor tray, which is what ties the two tray halves
// together. So the stack is 4 + plinth + 44 = 75.
//
// Deliberately a skeleton, not a block. The module's vents are on its BACK face,
// which points down here, and the operator has cut further vents into that cover.
// So the plinth touches only the four VESA bosses and ties them together with a
// low rib ring, leaving 25 mm of open plenum directly under the vented face.
//
//   flatpak run --filesystem=host org.openscad.OpenSCAD \
//     -o "$PWD/build/plate/plinth.stl" -D 'PART="plinth"' "$PWD/docs/design/chassis.scad"

include <deck.scad>

PART = "plinth";

// 26.5, not 31 - the tray eats 4 mm, and 0.5 more is deliberate.
//
// CORRECTED 2026-09-05. The first value, 30.5, came from 75 - 44 - 0.5 and
// silently assumed the plinth sat on the case FLOOR. It does not: it sits on
// the tray, and 4 + 30.5 + 44 = 78.5 would have stood the module 3.5 mm proud
// of the rib shelf and lifted the plate off all twelve ribs - the exact failure
// the 0.5 bias below exists to prevent.
//
// Not printer compensation: the calibration bar remeasured at 6.05 for a drawn
// 6.00, so Z is accurate. The bias is against OVER-CONSTRAINT. The plate is
// meant to land on twelve ribs at its perimeter AND on the module at its
// centre, and those two supports have to agree to within a fraction of a
// millimetre or the plate rocks. Any positive error here lifts the plate off
// its ribs and leaves it bearing on the module alone. Drawn 0.5 short, the
// module always lands slightly low and a strip of foam tape on its top face
// takes up the gap - a compliant support instead of a rigid one that competes.
// PLINTH_H, TRAY_T, VESA, M3_CLEAR and M4_CLEAR now live in deck.scad, where
// the stack that produces them is assert()ed. Do not redeclare them here.
PIER_D   = 10;      // kept small: contact only around the VESA bosses
RIB_H    = 6;
RIB_W    = 8;
$fn = 48;

module plinth() {
    difference() {
        union() {
            for (x = [-1, 1], y = [-1, 1])
                translate([x*VESA/2, y*VESA/2, 0]) cylinder(d=PIER_D, h=PLINTH_H);
            for (y = [-1, 1])
                translate([-VESA/2, y*VESA/2 - RIB_W/2, 0]) cube([VESA, RIB_W, RIB_H]);
            for (x = [-1, 1])
                translate([x*VESA/2 - RIB_W/2, -VESA/2, 0]) cube([RIB_W, VESA, RIB_H]);
        }
        // M4 up into the module's VESA threads
        for (x = [-1, 1], y = [-1, 1])
            translate([x*VESA/2, y*VESA/2, -1]) cylinder(d=M4_CLEAR, h=PLINTH_H + 2);
        // M3 down into the floor tray, taken from the SHARED pattern in case
        // coordinates so the plinth and the tray cannot disagree about it.
        for (b = PLINTH_BOLT)
            translate([b[0], b[1] - MOD_CY, -1]) cylinder(d=M3_CLEAR, h=RIB_H + 2);
    }
}

if (PART == "plinth") plinth();

// ---------------------------------------------------------------------------
// Floor tray. Sits in the flat 270 x 200 floor; the ~17 mm fillet traps it on
// all four sides, so nothing fastens to the shell (CASE.md S1, S12).
//
// Two halves split at x=0, each 132.5 x 195 - inside the 215 bed. They are not
// joined to each other: the PLINTH bridges the seam and bolts into both, and
// the fillet stops either sliding.
//
// Skeletal rather than solid. Under the module the tray is mostly window: the
// module's vents face down into a 30.5 mm plenum and the tray must not wall it
// off. It also saves most of the plastic and most of the print time.
// ---------------------------------------------------------------------------
TRAY_W = 132.5;    // per half
TRAY_D = 195;
RIB    = 12;       // TRAY_T is declared up with the plinth, which stands on it

// Plinth and cradle bolts come from deck.scad in CASE coordinates.

// Windows declared as a LIST, so the bolt positions can be checked against them.
//
// The old pair spanned y -85.5..-60 and -48..10, and BOTH plinth bolts - at
// y = -79 and -4 - fell inside them. The holes were drilled into fresh air and
// the plinth had nothing to bolt to. Found from a slicer screenshot, not from
// any check here: check-holes.scad probes for "no material where a hole should
// be", and a window is also no material, so it read as a pass.
//
// One window now, spanning between the plinth's two cross ribs rather than
// across them.
TRAY_WINDOWS = [
    [RIB, -73, TRAY_W - RIB, -10],          // plenum, between the plinth ribs
    [84,   24, TRAY_W - RIB, TRAY_D/2 - RIB] // back channel, beside the battery
];

module tray_window(x0, y0, x1, y1) {
    translate([x0, y0, -1]) cube([x1 - x0, y1 - y0, TRAY_T + 2]);
}

// Every bolt must land on material, not in a window. This is the check that was
// missing; it is arithmetic, so it costs nothing and cannot give a false pass.
for (b0 = concat(PLINTH_BOLT, CRADLE_BOLT)) {
    b = [abs(b0[0]), b0[1]];
    for (w = TRAY_WINDOWS)
        assert(!(b[0] > w[0] - 4 && b[0] < w[2] + 4 &&
                 b[1] > w[1] - 4 && b[1] < w[3] + 4),
               str("tray bolt at ", b, " falls in or beside a window"));
    assert(b[0] <= TRAY_W - 4 && abs(b[1]) <= TRAY_D/2 - 4,
           str("tray bolt at ", b, " is off the tray"));
}

module tray_half() {
    difference() {
        translate([0, -TRAY_D/2, 0]) cube([TRAY_W, TRAY_D, TRAY_T]);
        for (w = TRAY_WINDOWS) tray_window(w[0], w[1], w[2], w[3]);
        // EVERY bolt, folded onto x >= 0 with abs() - not filtered to x >= 0.
        //
        // The filter was written when the pattern was symmetric, so mirroring
        // one half reproduced the other. CRADLE_BOLT stopped being symmetric
        // when the shroud moved to the terminal side: the block bolts at +57.5
        // and the shroud at -77.5. Filtering dropped the shroud's holes, and
        // mirroring then put a useless pair at -57.5 instead. The tray had no
        // holes for the shroud at all. check-holes.scad caught it.
        //
        // Folding gives both halves all three x positions, so two per half go
        // unused. Four spare ⌀3.6 holes in a skeletal tray costs nothing;
        // guessing which half needs which cost an afternoon.
        // Each gets a hex nut trap in the UNDERSIDE so nothing protrudes below
        // the tray - it has to sit flat on the case floor or the whole stack
        // rises (deck.scad).
        for (b0 = concat(PLINTH_BOLT, CRADLE_BOLT)) {
            b = [abs(b0[0]), b0[1]];
            translate([b[0], b[1], -1]) cylinder(d=M3_CLEAR, h=TRAY_T + 2);
            translate([b[0], b[1], -1])
                cylinder(d=NUT_AF/cos(30), h=NUT_POCK + 1, $fn=6);
        }
    }
}

// ---------------------------------------------------------------------------
// Battery retention - TWO END BLOCKS, not a tray.
//
// REDRAWN 2026-09-05. The first version was a four-walled tray with a floor,
// and it did not fit and was not needed:
//
//   Depth. Behind the module's back edge (+27.25) the flat floor runs to +100,
//   so the battery zone is 72.75 mm. The pack is 70. A cradle with front and
//   back walls needs 70 + 1 slip + 2x3 wall = 77. It overran by 4.25 and its
//   back edge climbed 3.5 mm up the fillet, so it could not have sat flat.
//   deck.scad now assert()s this.
//
//   Need. Fore-aft the pack is already trapped between the module in front and
//   the fillet behind, with 2.75 mm of play. Front and back walls were buying
//   a constraint the case supplies for free, at 7 mm of depth it did not have.
//
//   Height. The floor added 4 mm under the pack for nothing, standing it at 98
//   with 2 mm to the rim. On the tray alone it tops out at 94.
//
// So: two blocks capturing the 106 mm axis, where nothing else constrains it.
// The plate's back well catches the pack again at 81-94 mm (S13 #0).
// ---------------------------------------------------------------------------
// Everything dimensional comes from deck.scad, including CRADLE_BOLT, which is
// DERIVED from these blocks rather than typed - the previous pattern disagreed
// with the tray's on both axes and nothing compared them.
CR_LEN = BATT_D;                       // block runs the pack's full depth

// Both drawn in PLATE coordinates - the terminal end is whichever side
// BATT_TERM_SIDE says - and moved to the origin only for printing.
module cradle_block() {
    x0 = CR_BLOCK_SIDE > 0 ? CR_BLOCK_X : -CR_BLOCK_X - CR_WALL;
    fx = CR_BLOCK_SIDE > 0 ? CR_BLOCK_X : -CR_BLOCK_X - CR_WALL - CR_FLANGE;
    difference() {
        union() {
            translate([x0, CR_CY - CR_LEN/2, 0]) cube([CR_WALL, CR_LEN, CR_H]);
            translate([fx, CR_CY - CR_LEN/2, 0])
                cube([CR_WALL + CR_FLANGE, CR_LEN, TRAY_T]);
        }
        for (b = BLOCK_BOLT)
            translate([b[0], b[1], -1]) cylinder(d=M3_CLEAR, h=TRAY_T + 2);
    }
}

// Terminal shroud - the other end block, grown into a closed box.
//
// RESTORED 2026-09-05. S11 specifies "a printed cover over the terminals" and
// names loose antenna elements beside bare LiFePO4 posts as a fire risk. The
// four-walled cradle carried that cover; replacing it with two open blocks
// dropped it silently, and nothing recorded that it had gone.
//
// It must run the full height of Zone A, and that is not caution - the operator
// reports the posts on what is the pack's TOP face upright, "on the right and
// left", and laid on its side that dimension becomes the VERTICAL one. The two
// posts are at different heights, spread over most of the 90 mm. There is no
// short cover that covers both.
//
// Closed outboard, both ends and top; open toward the pack; wire out through a
// notch at the FRONT bottom, following the posts, which sit toward the front.
module shroud() {
    xi = BATT_TERM_SIDE > 0 ?  CR_BLOCK_X   : -CR_BLOCK_X;         // inboard
    xo = BATT_TERM_SIDE > 0 ?  CR_SHROUD_X  : -CR_SHROUD_X;        // outboard
    x0 = min(xi, xo + (BATT_TERM_SIDE > 0 ? 0 : -CR_WALL));
    x1 = max(xi, xo + (BATT_TERM_SIDE > 0 ? CR_WALL : 0));
    fx = BATT_TERM_SIDE > 0 ? x0 : x0 - CR_FLANGE;
    difference() {
        union() {
            translate([BATT_TERM_SIDE > 0 ? xo : xo - CR_WALL, CR_CY - CR_LEN/2, 0])
                cube([CR_WALL, CR_LEN, CR_SHROUD_H]);                    // outboard
            for (y = [CR_CY - CR_LEN/2, CR_CY + CR_LEN/2 - CR_WALL])
                translate([x0, y, 0]) cube([x1 - x0, CR_WALL, CR_SHROUD_H]);
            translate([x0, CR_CY - CR_LEN/2, CR_SHROUD_H - CR_WALL])
                cube([x1 - x0, CR_LEN, CR_WALL]);                        // lid
            translate([fx, CR_CY - CR_LEN/2, 0])
                cube([x1 - x0 + CR_FLANGE, CR_LEN, TRAY_T]);             // flange
        }
        // wire exit, low and toward the FRONT, where the posts are
        translate([x0 - 1, CR_CY - CR_LEN/2 + 6, TRAY_T + 4])
            cube([x1 - x0 + 2, 26, 16]);
        for (b = SHROUD_BOLT)
            translate([b[0], b[1], -1]) cylinder(d=M3_CLEAR, h=TRAY_T + 2);
    }
}

module cradle() { translate([-CR_BLOCK_SIDE*CR_BLOCK_X, -CR_CY + CR_LEN/2, 0]) cradle_block(); }
module shroud_part() { translate([-BATT_TERM_SIDE*CR_SHROUD_X, -CR_CY + CR_LEN/2, 0]) shroud(); }

if (PART == "tray")   tray_half();
if (PART == "cradle") cradle();
if (PART == "shroud") shroud_part();
