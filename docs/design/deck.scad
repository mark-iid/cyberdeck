// cyberdeck — SHARED dimensions and the assertions that tie them together.
//
// WHY THIS FILE EXISTS
// -------------------
// check-stl.py checks a part in isolation: bounding box, bed fit, z=0 seating,
// count of solids. Every error it has caught was that kind. Every error it has
// MISSED was a RELATIONSHIP BETWEEN TWO PARTS:
//
//   2026-09-05  plinth 30.5 tall, computed as 75 - 44 - 0.5, forgetting the
//               4 mm tray it stands on. Stack came to 78.5 against a 75 shelf.
//   2026-09-05  plinth's tray bolts at x=0, tray's at x=+-20. Never compared.
//               Two of them would have landed in the seam between tray halves.
//   2026-09-05  battery height measured from the floor, not from the cradle
//               floor on top of the tray. Off by 8 mm.
//
// All three are sums that nobody added up. So the numbers that two parts must
// agree on live HERE, once, and the agreements are assert()ed. An assertion
// that fails stops OpenSCAD dead - the STL is never written. That is the point:
// a wrong part should be unprintable, not merely printed and then noticed.
//
// RULE: if a number appears in two files, it belongs in this one.
// RULE: if two parts must add up, write the assert before drawing either.

// --- The case. Measured 2026-09-04, cross-checked against Pelican CAD (S6) ---
SHELF_H   = 75;      // rib tops - what the plate lands on
BASE_H    = 100;     // floor to rim

// --- The module. Measured 2026-09-04 (S13 #3) -------------------------------
MOD_W = 200; MOD_D = 137.5; MOD_T = 44;
MOD_FRONT = -110.25;
MOD_CY    = MOD_FRONT + MOD_D/2;      // -41.5
VESA      = 75;                       // M4, centred (S13 #3b)

// --- The battery. Vendor + operator, 90 x 70 x 106 incl. terminals ----------
BATT_W = 106; BATT_D = 70; BATT_H = 90;

// --- Plate section (S12) ----------------------------------------------------
FRAME_H = 6; LEDGE_H = 1.5; TILE_T = 4.5;
PLATE_TOP = SHELF_H + FRAME_H;        // 81

// --- Floor chassis ----------------------------------------------------------
TRAY_T      = 4;
CR_FLOOR    = 4;     // cradle floor: the pack does not sit on the tray directly
PLINTH_BIAS = 0.5;   // drawn short on purpose, see chassis.scad
PLINTH_H    = SHELF_H - MOD_T - TRAY_T - PLINTH_BIAS;   // 26.5

// --- Fasteners. ruthex RX-M3x5.7, hole published on the bag (S13 #10) -------
INSERT_LEN = 5.7;
INSERT_D   = 4.2;    // -> 4.0 as printed on this machine (S6 offset)
INSERT_H   = 6.7;    // vendor minimum blind depth
INSERT_SKIN = 1.0;   // material left over a blind seat, so nothing shows
BOSS_H     = 1.7;    // local thickening that buys the depth
BOSS_D     = 8;
M3_CLEAR   = 3.4;
M4_CLEAR   = 4.5;

// --- Shared bolt patterns, in CASE coordinates ------------------------------
// Both the plinth and the tray drill these. Declared once so they cannot drift.
// x = +-20 and not 0: the tray is split at x=0 and a centreline bolt would land
// in the seam and hold neither half.
PLINTH_BOLT = [[-20, MOD_CY - VESA/2], [20, MOD_CY - VESA/2],
               [-20, MOD_CY + VESA/2], [20, MOD_CY + VESA/2]];
CRADLE_BOLT = [[-40, 38], [40, 38], [-40, 92], [40, 92]];

// ============================================================================
// ASSERTIONS. Each one is a sum that has already been got wrong, or could be.
// ============================================================================

// 1. The vertical stack under the screen. This is the one that failed.
assert(TRAY_T + PLINTH_H + MOD_T + PLINTH_BIAS == SHELF_H,
       "module stack does not reach the rib shelf");

// 2. Tiles finish flush with the frame top.
assert(LEDGE_H + TILE_T == FRAME_H,
       "tile does not sit flush in the frame");

// 3. The battery stands on the cradle floor, which stands on the tray - not on
//    the case floor. It must still clear the rim.
BATT_TOP = TRAY_T + CR_FLOOR + BATT_H;                 // 98
assert(BATT_TOP <= BASE_H, "battery is taller than the case");
assert(BATT_TOP > PLATE_TOP,
       "battery no longer needs an open well - the back tile can close over it");

// 4. A blind insert seat needs depth plus skin, and only a boss can buy it.
assert(FRAME_H + BOSS_H >= INSERT_H + INSERT_SKIN,
       "insert seat is too shallow for the insert");
assert(INSERT_H >= INSERT_LEN, "insert is longer than its hole");

// 5. A tile is too thin to take an insert at all - this is why the RJ45 ears
//    are countersunk through-holes. Left as an assert so nobody re-adds one.
assert(TILE_T < INSERT_H + INSERT_SKIN,
       "tile is now thick enough for an insert - revisit the RJ45 ears");
