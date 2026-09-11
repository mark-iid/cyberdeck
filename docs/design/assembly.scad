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

// A tile must not intersect the frame - it sits IN the opening, ON the ledge.
if (CHECK == "tiles")  intersection() { frame(); tiles(); }
// Nothing on the plate may stand over the picture.
if (CHECK == "screen") intersection() { union() { frame(); tiles(); } screen_column(); }
// The plate must clear the module and the battery.
if (CHECK == "module") intersection() { union() { frame(); tiles(); } module_brick(); }
if (CHECK == "batt")   intersection() { union() { frame(); tiles(); } battery(); }
