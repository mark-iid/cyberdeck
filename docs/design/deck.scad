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
CASE_W    = 305;     // interior at the shelf
CASE_D    = 231.4;
RIB_PROUD = 2;       // so the shelf opening is CASE_W - 2*RIB_PROUD
FLOOR_W   = 270;     // the FLAT floor, before the ~17 mm fillet climbs
FLOOR_D   = 200;
BED       = 215;     // Ender 3 usable

// --- The module. Measured 2026-09-04 (S13 #3) -------------------------------
MOD_W = 200; MOD_D = 137.5; MOD_T = 44;
MOD_FRONT = -110.25;
MOD_CY    = MOD_FRONT + MOD_D/2;      // -41.5
VESA      = 75;                       // M4, centred (S13 #3b)

// --- The battery. Vendor + operator, 90 x 70 x 106 incl. terminals ----------
BATT_W = 106; BATT_D = 70; BATT_H = 90;
// It stands at the back of the flat floor, behind the module.
BATT_BACK  = FLOOR_D/2;              // 100 - hard against where the fillet starts
BATT_FRONT = BATT_BACK - BATT_D;     // 30
MOD_BACK   = MOD_FRONT + MOD_D;      // 27.25

// --- Plate section (S12) ----------------------------------------------------
// 230.5, not 229. Same oversize bias as the width, and for the same reason -
// but the depth had never been given it. At 229 in a 231.4 opening the plate
// can slide 2.4 mm, and shoved to one wall its far edge stops 0.4 mm SHORT of
// the rib it is supposed to land on: zero guaranteed bearing on that side.
// 229 was sized against the operator's 230 tape measurement rather than the
// 231.4 from Pelican's CAD, and nothing reconciled the two. At 230.5 the
// guaranteed bearing is 1.1 mm and clearance 0.9. Sand if tight (S6).
PLATE_W = 304.5; PLATE_D = 230.5;
FRAME_W = 12; FRAME_WF = 8;          // front member narrowed for the battery
FRAME_H = 6; LEDGE_H = 1.5; TILE_T = 4.5;
PLATE_TOP = SHELF_H + FRAME_H;        // 81
OPEN_W  = PLATE_W - 2*FRAME_W;                // 280.5
OPEN_D  = PLATE_D - FRAME_W - FRAME_WF;       // 209
OPEN_CY = (FRAME_WF - FRAME_W)/2;             // -2
OPEN_FRONT = -PLATE_D/2 + FRAME_WF;           // -106.5
WIN_W = 173; WIN_D = 118;            // module active area, centred
TILE_GAP = 1;

// --- Floor chassis ----------------------------------------------------------
TRAY_T      = 4;
TRAY_W      = 132.5;   // per half, split at x=0
TRAY_D      = 195;
CR_WALL     = 3;
CR_H        = 20;      // how far up the pack's 90 mm the cradle grips
CR_FLANGE   = 8;
CR_SLIP     = 1;       // total clearance across a captured dimension
PLINTH_BIAS = 0.5;   // drawn short on purpose, see chassis.scad
PLINTH_H    = SHELF_H - MOD_T - TRAY_T - PLINTH_BIAS;   // 26.5

// --- Panel connectors. Vendor-published openings where they exist (S3) ------
SMA_D    = 6.7;      // test-fitted 2026-09-04
AUDIO_D  = 6.2;      // 3.5 mm headphone jack, PROVISIONAL - see S3. Not bought
                     // yet, so this is a placeholder for the barrel thread, not
                     // a measurement. Confirm before the left rail is printed.
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
// Cradle bolts DERIVED from the cradle's own geometry rather than typed, which
// is how the plinth's came to disagree with the tray's. The blocks grip the
// 106 mm axis only; see the assertion block for why there are no front or back
// walls.
CR_BLOCK_X  = BATT_W/2 + CR_SLIP/2;           // 53.5, inner face of a block
CRADLE_BOLT = [for (x = [-1, 1], y = [-1, 1])
                [x*(CR_BLOCK_X + CR_WALL + CR_FLANGE/2),
                 (BATT_FRONT + BATT_BACK)/2 + y*(BATT_D/2 - 10)]];

// ============================================================================
// ASSERTIONS. Each one is a sum that has already been got wrong, or could be.
// ============================================================================

// 1. The vertical stack under the screen. This is the one that failed.
assert(TRAY_T + PLINTH_H + MOD_T + PLINTH_BIAS == SHELF_H,
       "module stack does not reach the rib shelf");

// 2. Tiles finish flush with the frame top.
assert(LEDGE_H + TILE_T == FRAME_H,
       "tile does not sit flush in the frame");

// 3. The battery stands on the TRAY, not on the case floor. Getting this wrong
//    put its top at 90 in the doc for a day; it is 94.
BATT_TOP = TRAY_T + BATT_H;                            // 94
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

// --- 6. The plate lands on the rib shelf, and is not wedged by the walls -----
// GUARANTEED bearing per side - the worst case, plate shoved hard against one
// wall, when the far edge overlaps its rib by P - (W - RIB_PROUD). Not the
// centred figure, which is twice as flattering and would pass a plate that
// falls off one rib the moment it slides.
PLATE_BEAR_W = PLATE_W - (CASE_W - RIB_PROUD);
PLATE_BEAR_D = PLATE_D - (CASE_D - RIB_PROUD);
assert(PLATE_BEAR_W >= 1.0 && PLATE_BEAR_D >= 1.0, "plate loses bearing on the ribs");
assert(PLATE_W <= CASE_W && PLATE_D <= CASE_D, "plate will not enter the case");

// --- 7. Nothing is drawn that the bed cannot print --------------------------
// The frame prints as quartered L members; the screen tile as one piece.
assert(PLATE_W/2 <= BED && PLATE_D/2 <= BED, "frame member is off the bed");
assert(MOD_W + 2*TILE_GAP <= BED, "screen tile is off the bed");
assert(TRAY_W <= BED && TRAY_D <= BED, "tray half is off the bed");

// --- 8. The floor parts sit on FLAT floor, not up the fillet ----------------
assert(2*TRAY_W <= FLOOR_W && TRAY_D <= FLOOR_D, "tray rides up the fillet");

// --- 9. The battery zone. This is where the cradle went wrong ---------------
// Depth from the module's back edge to the back of the flat floor is all the
// battery gets, and the cradle spends it too. A cradle with front and back
// walls needs BATT_D + slip + 2*wall = 77 into 72.75 and does not fit - which
// is why the cradle grips the 106 mm axis only. Fore-aft the pack is already
// trapped: the module in front of it, the fillet behind.
BATT_ZONE = FLOOR_D/2 - MOD_BACK;                       // 72.75
assert(BATT_D <= BATT_ZONE, "battery is deeper than the floor behind the module");
assert(BATT_FRONT >= MOD_BACK, "battery overlaps the module");
CRADLE_W = BATT_W + CR_SLIP + 2*CR_WALL;
assert(CRADLE_W <= FLOOR_W, "cradle is wider than the flat floor");
// Every cradle bolt must land on tray material, on the correct half.
for (b = CRADLE_BOLT)
    assert(abs(b[0]) <= TRAY_W && abs(b[1]) <= TRAY_D/2,
           "a cradle bolt misses the tray");

// --- 10. The screen window sits inside the frame opening --------------------
assert(WIN_W <= OPEN_W, "screen window is wider than the opening");
assert(MOD_CY - WIN_D/2 >= OPEN_CY - OPEN_D/2 && MOD_CY + WIN_D/2 <= OPEN_CY + OPEN_D/2,
       "screen window runs past the frame opening");
assert(WIN_W <= MOD_W && WIN_D <= MOD_D, "active area is bigger than the module");

// --- 11. The rail tiles are what is left over, and must hold the connectors -
RAIL_W = (OPEN_W - (MOD_W + 2*TILE_GAP))/2;             // 39.25
assert(RAIL_W > 0, "the module leaves no rail");
// Widest thing on a rail is the USB rebate: 21.5 plus 3 mm of relief each side.
assert(21.5 + 2*3 <= RAIL_W, "USB rebate is wider than the rail tile");
assert(28.7 + 2*3 <= RAIL_W, "rocker rebate is wider than the rail tile");

// --- 12. An insert seat needs vendor wall, and the splice must swallow it ---
// Against the NARROWEST member, which is the front one at FRAME_WF. Checking
// FRAME_W passes trivially and would not notice a boss outgrowing the front.
assert(BOSS_D <= FRAME_WF, "insert boss is wider than the front frame member");
assert((FRAME_WF - (INSERT_D - 0.2))/2 >= 1.6,
       "insert has less than 1.6 mm of wall in the front frame member");
