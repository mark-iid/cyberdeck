// cyberdeck — floor chassis: module plinth (tray and cradle to follow).
//
// The module's screen must finish level with the rib shelf at 75 mm (CASE.md S12).
// Module is 44 mm thick (measured), so it stands on a 31 mm plinth: 31 + 44 = 75.
//
// Deliberately a skeleton, not a block. The module's vents are on its BACK face,
// which points down here, and the operator has cut further vents into that cover.
// So the plinth touches only the four VESA bosses and ties them together with a
// low rib ring, leaving 25 mm of open plenum directly under the vented face.
//
//   flatpak run --filesystem=host org.openscad.OpenSCAD \
//     -o "$PWD/build/plate/plinth.stl" -D 'PART="plinth"' "$PWD/docs/design/chassis.scad"

PART = "plinth";

PLINTH_H = 31;      // 75 shelf - 44 module
VESA     = 75;      // M4, centred on the 200 x 137.5 face
BOSS_D   = 10;      // kept small: contact only around the VESA bosses
M4_CLEAR = 4.5;
RIB_H    = 6;
RIB_W    = 8;
M3_CLEAR = 3.4;
$fn = 48;

module plinth() {
    difference() {
        union() {
            for (x = [-1, 1], y = [-1, 1])
                translate([x*VESA/2, y*VESA/2, 0]) cylinder(d=BOSS_D, h=PLINTH_H);
            for (y = [-1, 1])
                translate([-VESA/2, y*VESA/2 - RIB_W/2, 0]) cube([VESA, RIB_W, RIB_H]);
            for (x = [-1, 1])
                translate([x*VESA/2 - RIB_W/2, -VESA/2, 0]) cube([RIB_W, VESA, RIB_H]);
        }
        // M4 up into the module's VESA threads
        for (x = [-1, 1], y = [-1, 1])
            translate([x*VESA/2, y*VESA/2, -1]) cylinder(d=M4_CLEAR, h=PLINTH_H + 2);
        // M3 down into the floor tray, mid-span on each rib
        for (p = [[0, VESA/2], [0, -VESA/2], [VESA/2, 0], [-VESA/2, 0]])
            translate([p[0], p[1], -1]) cylinder(d=M3_CLEAR, h=RIB_H + 2);
    }
}

if (PART == "plinth") plinth();
