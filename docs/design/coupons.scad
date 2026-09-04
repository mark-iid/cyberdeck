// cyberdeck — connector test coupons.
//
// WHY: filament shrinkage and slop vary by printer, and two of the ordered parts
// (the USB unit, the keystone) retain themselves by SNAPPING to the panel. Their
// cutouts are not published — the vendor sheets give the bezel, which must
// overhang the hole to seat, so it can never be the hole. Guessing and finding
// out six hours into a faceplate print is the expensive way. These are
// 20-minute prints that turn every unknown into a test fit.
//
// Print in the SAME filament, nozzle and layer height as the real plate. A
// coupon printed in another material tells you about that material.
//
// OpenSCAD on this machine is a FLATPAK, not on PATH. From the repo root:
//
//   mkdir -p build/coupons
//   for p in usb_size usb_thick rail; do
//     flatpak run --filesystem=host org.openscad.OpenSCAD \
//       -o "$PWD/build/coupons/$p.stl" -D "PART=\"$p\"" "$PWD/docs/design/coupons.scad"
//   done
//
// Pass ABSOLUTE paths — the flatpak has its own private /tmp and will not see a
// relative or /tmp output path. build/ is gitignored; STLs are regenerable.
// Plain `openscad ...` works wherever it is a normal PATH binary.
//
// Verified 2026-09-04: all three render manifold (CGAL "Simple: yes"), bboxes
// 146x50x4.5, 146x50x4.5, 170x75x4.5, each originating at 0,0,0.
//
// Then write the winning numbers into CASE.md §3 and cut faceplate.svg to them.
// This is a measuring tool, not a part.

PART    = "all";
PLATE_T = 4.5;    // intended faceplate thickness (§3 thin-panel note)
ENGRAVE = 0.6;
$fn     = 96;

module lbl(s, sz=3.2) {
    translate([0, 0, PLATE_T - ENGRAVE]) linear_extrude(ENGRAVE + 0.4)
        text(s, size=sz, halign="center", valign="center",
             font="DejaVu Sans:style=Bold");
}

// Opening + local rebate. The rebate thins the plate to `t` around the hole so
// the snap tabs have something they can actually close over (§3 thin-panel rule).
module snap_hole(cx, cy, w, l, t, margin=4) {
    translate([cx - w/2 - margin, cy - l/2 - margin, t])
        cube([w + 2*margin, l + 2*margin, PLATE_T]);
    translate([cx - w/2, cy - l/2, -1]) cube([w, l, PLATE_T + 2]);
}

// ---------------------------------------------------------------------------
// USB — bezel 25.4 x 28.6 (vendor sheet). Ladder the opening from a 2mm-per-side
// inset down to 0.5mm and see which one clicks home.
// ---------------------------------------------------------------------------
USB_W = [21.5, 22.5, 23.5, 24.5];
USB_L = [24.5, 25.5, 26.5, 27.5];
USB_T = [1.5, 2.0, 2.5, 3.0];        // local thickness the tabs must clamp

module usb_size() {
    pitch = 34; n = len(USB_W);
    difference() {
        cube([pitch*n + 10, 50, PLATE_T]);
        for (i = [0:n-1]) {
            cx = 22 + pitch*i;
            snap_hole(cx, 28, USB_W[i], USB_L[i], 2.0);
            translate([cx, 5, 0]) lbl(str(USB_W[i], "x", USB_L[i]), 3.0);
        }
        translate([pitch*n/2 + 5, 47, 0]) lbl("USB — SIZE @2.0mm web", 3.4);
    }
}

module usb_thick() {
    w = 23.5; l = 26.5; pitch = 34; n = len(USB_T);
    difference() {
        cube([pitch*n + 10, 50, PLATE_T]);
        for (i = [0:n-1]) {
            cx = 22 + pitch*i;
            snap_hole(cx, 28, w, l, USB_T[i]);
            translate([cx, 5, 0]) lbl(str(USB_T[i], "mm"), 3.4);
        }
        translate([pitch*n/2 + 5, 47, 0]) lbl("USB — WEB @23.5x26.5", 3.4);
    }
}

// ---------------------------------------------------------------------------
// Rail — the four sizes now VERIFIED from vendor sheets. Narrow ladders, only
// wide enough to absorb this printer's offset.
// ---------------------------------------------------------------------------
SMA   = [6.3, 6.5, 6.7];                      // §3 ⌀6.5 ±0.1, wants to be snug
SW    = [15.8, 16.0, 16.2, 16.4];             // ⌀16.0 mounting hole
KEY_W = [14.3, 14.6, 14.9]; KEY_L = 16.2;     // keystone 14.6 x 16.2
PP    = [[15.6,7.9],[16.0,8.3],[16.4,8.7]];   // PP15-45 bonded pair, §8 #7

module rail() {
    difference() {
        cube([170, 75, PLATE_T]);
        for (i = [0:len(SMA)-1]) {
            translate([20 + 18*i, 52, -1]) cylinder(d=SMA[i], h=PLATE_T+2);
            translate([20 + 18*i, 34, 0]) lbl(str(SMA[i]), 2.8);
        }
        translate([38, 68, 0]) lbl("SMA ⌀6.5", 3.4);
        for (i = [0:len(SW)-1]) {
            translate([90 + 22*i, 52, -1]) cylinder(d=SW[i], h=PLATE_T+2);
            translate([90 + 22*i, 34, 0]) lbl(str(SW[i]), 2.8);
        }
        translate([123, 68, 0]) lbl("SWITCH ⌀16", 3.4);
        for (i = [0:len(KEY_W)-1]) {
            snap_hole(20 + 28*i, 18, KEY_W[i], KEY_L, 2.0);
            translate([20 + 28*i, 2.5, 0]) lbl(str(KEY_W[i]), 2.8);
        }
        for (i = [0:len(PP)-1]) {
            translate([110 + 20*i - PP[i][0]/2, 18 - PP[i][1]/2, -1])
                cube([PP[i][0], PP[i][1], PLATE_T + 2]);
            translate([110 + 20*i, 2.5, 0]) lbl(str(PP[i][0]), 2.8);
        }
    }
}

if      (PART == "usb_size")  usb_size();
else if (PART == "usb_thick") usb_thick();
else if (PART == "rail")      rail();
else { usb_size(); translate([0,55,0]) usb_thick(); translate([0,110,0]) rail(); }
