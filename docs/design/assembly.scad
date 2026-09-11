// THE ASSEMBLY, with every part where it actually goes - and the checks that
// only exist once it does.
//
// WHY: every part in this build is drawn at the origin, because that is what a
// printer wants. Nothing has ever represented a part in its INSTALLED position,
// so every question about how two parts meet has been answered in someone's
// head. That is where all of these came from:
//
//   tile screws placed in the wrong coordinate frame   (cut nothing)
//   tray bolts inside tray windows                     (held nothing)
//   square tile corners in a round opening             (would not seat)
//   screen-tile lap coplanar with the rails            (would not seat)
//   ledge inset the wrong way round                    (covers the screen)
//
// All five are interference or support questions, and all five are trivial to
// see once the parts are in place. Assertions could not catch them because an
// assertion compares numbers to numbers; these are solids meeting solids.
//
// Everything below is in PLATE coordinates: z = 0 is the rib shelf at 75 mm.

include <deck.scad>
use <plate.scad>
use <chassis.scad>

CHECK = "none";
TILE_BACK = MOD_FRONT + MOD_D + TILE_GAP;
RAIL_CX   = (MOD_W/2 + TILE_GAP + OPEN_W/2)/2;
RAIL_CY   = (OPEN_FRONT + TILE_BACK)/2;
LAP_T     = 1.2;                       // screen tile's body starts this high

// ---- the four frame members, as printed, in place ------------------------
module frame() {
    member(false); mirror([1,0,0]) member(false);
    member(true);  mirror([1,0,0]) member(true);
}
// ---- the five tiles, lifted onto the ledge -------------------------------
module tiles() {
    translate([-RAIL_CX, RAIL_CY, LEDGE_H]) left_rail();
    translate([ RAIL_CX, RAIL_CY, LEDGE_H]) right_rail();
    translate([0, 0, LEDGE_H]) back_tile(-1);
    translate([0, 0, LEDGE_H]) back_tile(1);
    // the screen tile's BODY starts at LAP_T, so it lifts by the difference
    translate([0, 0, LEDGE_H - LAP_T]) screen_tile();
}
// ---- what the plate has to live with -------------------------------------
module module_brick() {                       // top face 0.5 below the shelf
    translate([-MOD_W/2, MOD_FRONT, -MOD_T - 0.5]) cube([MOD_W, MOD_D, MOD_T]);
}
module battery() {                            // stands on the tray
    translate([-BATT_BODY_W/2, BATT_FRONT, TRAY_T - SHELF_H])
        cube([BATT_BODY_W, BATT_D, BATT_H]);
}
// ---- the screen's picture, extruded up to the plate top ------------------
module screen_column() {
    translate([-(WIN_W - 1)/2, MOD_CY - (WIN_D - 1)/2, -0.5])
        cube([WIN_W - 1, WIN_D - 1, FRAME_H + 1]);
}

// ---- EXHAUSTIVE MODE ------------------------------------------------------
// Every part, placed. PART_N selects one; the check intersects it with the
// UNION OF ALL THE OTHERS. If part i overlaps anything at all, it shows - so N
// renders cover all N(N-1)/2 pairs, and nothing depends on me choosing which
// pairs are worth looking at. That choice is what has failed repeatedly.
//
// Placements are the one place judgement still enters. Each is commented with
// the reasoning; a wrong placement shows up as a false positive, which gets
// investigated rather than believed.
SPL_JOINTS = [[0, PLATE_D/2 - FRAME_W/2, 0],        // back joint
              [ PLATE_W/2 - FRAME_W/2, 0, 90],      // right joint
              [-PLATE_W/2 + FRAME_W/2, 0, 90]];     // left joint

module part(i) {
    if (i == 0) member(false);                                    // back right
    if (i == 1) mirror([1,0,0]) member(false);                    // back left
    if (i == 2) member(true);                                     // front right
    if (i == 3) mirror([1,0,0]) member(true);                     // front left
    if (i == 4) translate([-RAIL_CX, RAIL_CY, LEDGE_H]) left_rail();
    if (i == 5) translate([ RAIL_CX, RAIL_CY, LEDGE_H]) right_rail();
    if (i == 6) translate([0,0,LEDGE_H]) back_tile(-1);
    if (i == 7) translate([0,0,LEDGE_H]) back_tile(1);
    // body starts at LAP_T, and the body must land on the ledge
    if (i == 8) translate([0,0,LEDGE_H - LAP_T]) screen_tile();
    // splices hang below the rim, under the three bolted joints
    if (i >= 9 && i <= 11) {
        j = SPL_JOINTS[i - 9];
        translate([j[0], j[1], -5]) rotate([0,0,j[2]]) splice();
    }
    // front strap: in the band between the plate edge and the module's face
    if (i == 12) translate([-30, -PLATE_D/2, -5]) front_strap();
    // Powerpole retainer: bolted to the BACK of the left rail, top at the
    // tile's underside
    if (i == 13) translate([-RAIL_CX, RAIL_CY - 20, LEDGE_H - PP_DEPTH]) pp_retainer();
    // preload strips stand ON the frame's side members
    if (i == 14) translate([ PLATE_W/2 - FRAME_W, -SPACER_L/2, FRAME_H]) preload_strip();
    if (i == 15) translate([-PLATE_W/2, -SPACER_L/2, FRAME_H]) preload_strip();
    // chassis, all referenced to the case floor at plate z = -SHELF_H
    if (i == 16) translate([0,0,-SHELF_H]) tray_half();
    if (i == 17) translate([0,0,-SHELF_H]) mirror([1,0,0]) tray_half();
    if (i == 18) translate([0, MOD_CY, -SHELF_H + TRAY_T]) plinth();
    if (i == 19) translate([0,0,-SHELF_H + TRAY_T]) cradle_block();
    if (i == 20) translate([0,0,-SHELF_H + TRAY_T]) shroud();
    if (i == 21) module_brick();
    if (i == 22) battery();
}
N_PARTS = 23;
PART_N = -1;

module others(k) { for (i = [0 : N_PARTS-1]) if (i != k) part(i); }

if (PART_N >= 0) intersection() { part(PART_N); others(PART_N); }

// PAIR mode: one named part against one other, to identify which neighbour a
// whole-assembly overlap actually belongs to.
PAIR_A = -1; PAIR_B = -1;
if (PAIR_A >= 0) intersection() { part(PAIR_A); part(PAIR_B); }

// ---- LOOK AT IT ----------------------------------------------------------
// The whole deck, assembled. Open it and look - which is how every fault in
// this build has actually been found.
//   IN_PLACE = -1  : everything, merged
//   IN_PLACE = n   : part n alone, but in its assembled position, so a slicer
//                    can load them all and keep them where they belong
IN_PLACE = -2;
if (IN_PLACE == -1) for (i = [0 : N_PARTS-1]) part(i);
if (IN_PLACE >= 0)  part(IN_PLACE);

// A tile must not intersect the frame - it sits IN the opening, ON the ledge.
if (CHECK == "tiles")  intersection() { frame(); tiles(); }
// Nothing on the plate may stand over the picture.
if (CHECK == "screen") intersection() { union() { frame(); tiles(); } screen_column(); }
// The plate must clear the module and the battery.
if (CHECK == "module") intersection() { union() { frame(); tiles(); } module_brick(); }
if (CHECK == "batt")   intersection() { union() { frame(); tiles(); } battery(); }
