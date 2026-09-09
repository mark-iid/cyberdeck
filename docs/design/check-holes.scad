// Every fastener position, probed against the geometry that is supposed to
// carry it. Run with PROBE set to one of the names below; an EMPTY result
// means every hole is present, a non-empty one means at least one is missing.
//
// WHY THIS EXISTS
// ---------------
// Both back tiles once exported with no screw holes at all. The shared screw
// LIST was correct and its assertion passed; the holes were placed in the wrong
// coordinate frame, landed off the part and cut nothing. Bounding box, solid
// count, z=0 seating and the list assertion were all still green.
//
// An assertion can only compare numbers to numbers. This compares the list to
// the SOLID: put a thin probe at every declared fastener position and
// intersect it with the parts. Material where a hole should be is a failure
// that nothing else in this repo can see.

// use, NOT include: `include` also runs each file's `if (PART == ...)` dispatch
// and drops stray parts into the scene, which every probe then hits. `use`
// imports the modules only, and they keep their own file's scope.
include <deck.scad>
use <plate.scad>
use <chassis.scad>

PROBE = "none";
TILE_BACK = MOD_FRONT + MOD_D + TILE_GAP;
RAIL_CX   = (MOD_W/2 + TILE_GAP + OPEN_W/2)/2;
RAIL_CY   = (OPEN_FRONT + TILE_BACK)/2;

// The four printed frame pieces, reassembled in plate coordinates.
module whole_frame() {
    member(false); mirror([1,0,0]) member(false);
    member(true);  mirror([1,0,0]) member(true);
}
// The five tiles, each moved from its print origin to where it sits.
module whole_tiles() {
    translate([-RAIL_CX, RAIL_CY, 0]) left_rail();
    translate([ RAIL_CX, RAIL_CY, 0]) right_rail();
    back_tile(-1); back_tile(1); screen_tile();
}
// Floor parts, in case coordinates.
module whole_chassis() {
    translate([0, MOD_CY, 0]) plinth();
    tray_half(); mirror([1,0,0]) tray_half();
    cradle_block(); shroud();
}

module probe(pts, z0, h) {
    for (p = pts) translate([p[0], p[1], z0]) cylinder(d=1, h=h, $fn=12);
}

// blind joint seats: bored -BOSS_H .. -BOSS_H+INSERT_H
if (PROBE == "joint")  intersection() { whole_frame(); probe(JOINT_SEAT, -1.4, 6.1); }
// blind tile seats in the frame ledge: bored LEDGE_H-INSERT_H .. LEDGE_H
if (PROBE == "ledge")  intersection() { whole_frame(); probe(TILE_SCREW, LEDGE_H-6.2, 5.9); }
// through-holes in the tiles themselves
if (PROBE == "tile")   intersection() { whole_tiles(); probe(TILE_SCREW, -0.5, TILE_T+1); }
// chassis through-holes
if (PROBE == "plinth") intersection() { whole_chassis(); probe(PLINTH_BOLT, -0.5, 11); }
if (PROBE == "cradle") intersection() { whole_chassis(); probe(CRADLE_BOLT, -0.5, 11); }
