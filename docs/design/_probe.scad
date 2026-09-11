include <assembly.scad>
// Probe: is there ledge material inside the battery well, on the LEFT member?
// The well runs WELL_X0=-71 .. WELL_X1=+51; the back ledge sits y 93.25..103.25, z 0..1.5.
intersection() {
    union() { part(0); part(1); }
    translate([WELL_X0, OPEN_BACK - LEDGE_W, 0]) cube([WELL_X1 - WELL_X0, LEDGE_W, LEDGE_H]);
}
