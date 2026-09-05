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
// 106 is the ENVELOPE: a 100 mm body with terminals adding 6 on ONE end
// (operator, 2026-09-05). The cradle must grip the BODY - a block closing on
// 53 would be squeezing the terminals, not the case.
BATT_W = 106; BATT_D = 70; BATT_H = 90;
BATT_BODY_W = 100;
BATT_TERM_W = BATT_W - BATT_BODY_W;    // 6
BATT_TERM_SIDE = 1;   // ⚠️ WHICH END - assumed +x. Not measured. Mirror if wrong.
// Body centred on x=0, so the envelope runs -50 .. +56 for BATT_TERM_SIDE = 1.
BATT_X0 = -BATT_BODY_W/2;
BATT_X1 =  BATT_BODY_W/2 + BATT_TERM_W;
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
// The gap the foam tape on the module's top face has to close. S12 quotes 0.5,
// which is the frame-to-module figure. The TILES are what the module actually
// carries, and they sit LEDGE_H higher than the frame's underside, so the real
// gap is 2.0. Buy 2 mm tape, not 0.5.
FOAM_T      = LEDGE_H + PLINTH_BIAS;                    // 2.0

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

// --- Tile and frame joint fastenings, in PLATE coordinates ------------------
// Both sides of every joint read these lists: the FRAME puts an insert seat at
// each point, the TILE puts a countersunk clearance hole. Each tile filters the
// list by its own footprint, so a tile cannot be given a screw the frame has no
// seat for, or miss one the frame does have.
LEDGE_W  = 10;      // ledge reaching inward under the tiles
LEDGE_WF = 5;       // narrowed at the front, same reason as FRAME_WF
OPEN_BACK    = OPEN_CY + OPEN_D/2;                 // 103.25
LEDGE_SIDE_X = OPEN_W/2 - LEDGE_W/2;               // 135.25
LEDGE_BACK_Y = OPEN_BACK - LEDGE_W/2;              // 98.25

// A tile screw goes DOWN through the tile into a seat under the ledge, so the
// ledge needs INSERT_H + skin of material and has LEDGE_H. The difference hangs
// below as a boss, into the space outboard of the module.
TILE_BOSS_H = INSERT_H + INSERT_SKIN - LEDGE_H;    // 6.2

TILE_SCREW = concat(
    // rails and back tiles, along the side ledges
    [for (sx = [-1, 1], y = [-95, -39.5, 15, 45, 85]) [sx*LEDGE_SIDE_X, y]],
    // back tiles again, along the back ledge
    [for (sx = [-1, 1], x = [70, 110]) [sx*x, LEDGE_BACK_Y]]);

// Frame joints. Members butt at the centre of every side, four screws per joint,
// pulled up from below by a splice. 14 and 26 from the joint, as the coupon.
JOINT_SEAT = concat(
    [for (sx = [-1, 1], d = [14, 26]) [sx*d,  PLATE_D/2 - FRAME_W/2]],   // back
    [for (sx = [-1, 1], d = [14, 26]) [sx*d, -PLATE_D/2 + FRAME_WF/2]],  // front
    [for (sx = [-1, 1], sy = [-1, 1], d = [14, 26])
        [sx*(PLATE_W/2 - FRAME_W/2), sy*d]]);                            // sides

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
CR_BLOCK_X  = BATT_BODY_W/2 + CR_SLIP/2;      // 50.5, against the BODY
// The terminal end carries a shroud, which is wider than a plain block, so the
// two ends do not have the same bolt line.
CR_SHROUD_X = CR_BLOCK_X + BATT_TERM_W;       // outboard of the terminals
CRADLE_BOLT = [for (y = [-1, 1])
    each [[-(CR_BLOCK_X  + CR_WALL + CR_FLANGE/2),
           (BATT_FRONT + BATT_BACK)/2 + y*(BATT_D/2 - 10)],
          [ (CR_SHROUD_X + CR_WALL + CR_FLANGE/2),
           (BATT_FRONT + BATT_BACK)/2 + y*(BATT_D/2 - 10)]]];
// Zone A is everything outboard of the pack, and S11 calls loose metal beside
// bare terminals "a fire, not an inconvenience". The shroud closes the terminal
// end up to the underside of the back tile - above that the pack is in the lid
// recess, where nothing loose rides.
CR_SHROUD_H = SHELF_H + LEDGE_H - 2;          // 74.5

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

// --- 13. Tile screws must land on ledge, and the ledge must carry an insert --
assert(BOSS_D <= LEDGE_W, "tile insert boss is wider than the ledge");
assert(LEDGE_H + TILE_BOSS_H >= INSERT_H + INSERT_SKIN, "tile seat is too shallow");
// No screw on the FRONT ledge: it is LEDGE_WF wide and a boss will not fit.
for (t = TILE_SCREW)
    assert(t[1] > OPEN_CY - OPEN_D/2 + LEDGE_WF,
           "a tile screw is on the front ledge, which is too narrow for a seat");
// Every screw must actually be over ledge, not over the open middle.
for (t = TILE_SCREW)
    assert(abs(t[0]) >= OPEN_W/2 - LEDGE_W || t[1] >= OPEN_BACK - LEDGE_W,
           "a tile screw is not over any ledge");
