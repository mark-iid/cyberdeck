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
// How far the plate's edge reaches PAST a rib's inner face - i.e. how much of
// the plate's underside actually lands on a rib top. It is also how far
// anything hanging BELOW the plate at a rib would foul it.
RIB_OVERLAP_W = 304.5/2 - (CASE_W/2 - RIB_PROUD);   // 1.75
RIB_OVERLAP_D = 230.5/2 - (CASE_D/2 - RIB_PROUD);   // 1.55

// --- The module. Measured 2026-09-04 (S13 #3) -------------------------------
MOD_W = 200; MOD_D = 137.5; MOD_T = 44;
MOD_FRONT = -110.25;
MOD_CY    = MOD_FRONT + MOD_D/2;      // -41.5
VESA      = 75;                       // M4, centred (S13 #3b)

// --- The battery. Vendor + operator, 90 x 70 x 106 incl. terminals ----------
BATT_W = 106; BATT_D = 70; BATT_H = 90;

// Terminals, from the operator: on what is the TOP face in the pack's natural
// upright orientation, set toward the FRONT, one left and one right, standing
// 8 mm up from that face.
//
// The deck lays the pack on its side - 90 vertical, 70 front-to-back - so that
// top face becomes a VERTICAL END FACE, and the consequences flip:
//   - the 8 mm sticks out SIDEWAYS, along x, past the 100 mm body
//   - "left and right" was across the 90 mm dimension, which is now the
//     VERTICAL one. The two posts are therefore at DIFFERENT HEIGHTS, spread
//     over most of the pack's 90 mm - not clustered. A short cover cannot work;
//     the shroud has to run the height of Zone A, which is what it does.
//   - "toward the front" is across the 70 mm dimension, which stays
//     front-to-back, so both posts sit toward the deck's front. The wire exit
//     follows them there.
//
// 8 vs the earlier "extends to 106" (which implies 6): SETTLED at 8,
// 2026-09-05. Both readings were right - the posts stand 8 free and flex down
// to 6. So 6 is what they measure when something is already pressing on them,
// which is not a number to build clearance from. 8 is the resting height and
// the only one that guarantees nothing touches them.
BATT_BODY_W = 100;
BATT_TERM_W = 8;                 // posts at rest; they flex to 6 under load
// Posts alone are not the envelope. S11 already budgets "~15-20 mm for the
// posts + Powerpole lugs + cable bend"; the shroud has to contain all of it.
BATT_WIRE_W = 20;
// Terminals to the LEFT: the left rail carries the rocker and the Powerpole
// inlet (S8), so this is the short side for the power run.
BATT_TERM_SIDE = -1;
BATT_X0 = -BATT_BODY_W/2 - BATT_WIRE_W;      // -70, terminal side
BATT_X1 =  BATT_BODY_W/2;                    // +50
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
CORNER_R = 18;                       // matches the shell's interior corner
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
// DERIVED from the floor it sits on, not restated. 2.5 mm of clearance all
// round against the fillet that traps it.
TRAY_GAP    = 2.5;
TRAY_W      = (FLOOR_W - 2*TRAY_GAP)/2;   // 132.5 per half, split at x=0
TRAY_D      = FLOOR_D - 2*TRAY_GAP;       // 195
CR_WALL     = 3;
CR_H        = 20;      // how far up the pack's 90 mm the cradle grips
CR_FLANGE   = 8;
CR_SLIP     = 1;       // total clearance across a captured dimension
// Nut traps in the tray's UNDERSIDE. Without them the eight chassis nuts sit
// between the tray and the case floor, and the tray rides 2.4 mm up on them -
// which does not just rock, it breaks the stack: 6.4 + 26.5 + 44 = 76.9 against
// a 75 shelf, so the module lifts the plate off its ribs. Exactly the failure
// PLINTH_BIAS exists to prevent, arriving by a route the assertion cannot see
// because a nut is not geometry.
NUT_AF    = 5.5 + 0.4;   // M3 hex across flats, plus clearance
NUT_POCK  = 2.6;         // 2.4 nut + 0.2, leaving TRAY_T - 2.6 = 1.4 of tray
PLINTH_BIAS = 0.5;   // drawn short on purpose, see chassis.scad
PLINTH_H    = SHELF_H - MOD_T - TRAY_T - PLINTH_BIAS;   // 26.5
// The gap the foam tape on the module's top face has to close. S12 quotes 0.5,
// which is the frame-to-module figure. The TILES are what the module actually
// carries, and they sit LEDGE_H higher than the frame's underside, so the real
// gap is 2.0. Buy 2 mm tape, not 0.5.
FOAM_T      = LEDGE_H + PLINTH_BIAS;                    // 2.0 nominal, 1.8 measured
// Z ERROR CLOSED 2026-09-07 across three heights: 6.00 -> 6.05, 26.50 -> 26.70,
// 74.50 -> 74.60. A 0.8% scale would have made the shroud 75.10; it measured
// 74.60, so scale is out. A fixed offset is out too - the three offsets are
// +0.05, +0.20 and +0.10. What is left is ordinary FDM variation that does not
// track height, so there is nothing to compensate and nothing is compensated.
//
// PLINTH_BIAS absorbs it regardless of cause: ~4 + 26.7 + 44 = ~74.7 against a
// 75 shelf, so the module's top still lands below it and the plate keeps
// landing on its ribs.
//
// Only consequence: the foam tape closes ~1.8 rather than 2.0. 2 mm tape still
// works - it compresses, which is the point of using tape and not a shim.

// --- Plate preload, S14 #4 ---------------------------------------------------
// The keyboard used to be the spacer that let the lid foam press the plate onto
// its ribs. It moved to the lid, so something has to take its place. TPU, not
// cut foam: the height is repeatable and the stiffness is a slicer setting.
//
// Strips sit on the SIDE frame members, directly over the six side ribs, so the
// load goes into the plate where the plate is actually supported - not into the
// middle, which would just push on the module.
// The front strap lives in the band between the plate's edge and the module's
// front face. That band was measured by hand when the strap was drawn and never
// asserted - so this is the check, not the comment.
FS_BAND = MOD_FRONT - (-PLATE_D/2);       // 5.0
FS_W    = 4.5;
assert(FS_W < FS_BAND, "front strap is wider than the band beside the module");

SPACER_H = BASE_H - PLATE_TOP + 1;   // 20: one mm of deliberate squeeze
SPACER_L = 190;                      // clear of the R18 corners at +-97.25
assert(SPACER_H >= BASE_H - PLATE_TOP, "preload strip is shorter than the recess");
assert(SPACER_L/2 <= PLATE_D/2 - CORNER_R - 2, "preload strip runs into the corner radius");

// --- Panel connectors. Vendor-published openings where they exist (S3) ------
SMA_D    = 6.7;      // test-fitted 2026-09-04

// --- Anderson PP15-45 bonded pair, measured 2026-09-07 -----------------------
// A pair has a constant cross-section and no shoulder, so nothing about its
// OUTSIDE can stop it being pulled back out. The roll pin is the only feature
// that can, which is why this part waited for a measurement instead of being
// guessed at.
PP_W    = 16.2;      // across the rail
PP_H    = 8.5;       // along the rail
PP_A    = 9.5;       // mating face -> pin hole CENTRE, along the axis
PP_PIN  = 2.38;      // 3/32" roll pin
PP_LEN  = 24.6;      // housing overall
// The pin runs through the 8.5 axis, so it exits the two faces that lie along
// the rail - the retainer takes it in DOUBLE shear, one wall each side.
PP_SLIP = 0.3;       // pocket clearance on top of the +0.2 print offset
PP_WALL = 3;
PP_DEPTH = 10;       // retainer body behind the tile
PP_EAR  = 26;        // screw centres, across the rail
assert(PP_A > TILE_T + 3,
       "Powerpole pin lands too close behind the tile to leave a shoulder");
assert(PP_A - TILE_T + PP_WALL <= PP_DEPTH + PP_WALL,
       "Powerpole retainer is too shallow to reach the pin");
// 3.5 mm headphone jack, from the vendor drawing 2026-09-05 (0.23 / 0.27 /
// 0.31 / 0.49 / 1.36 inch):
//   thread OD 5.84   thread LENGTH 6.86   nut OD 7.87
//   body OD  12.45   body length  34.54
//
// The 6.2 guess was right: it prints 6.0, which clears a 5.84 thread by 0.16.
//
// The THREAD LENGTH is the one that matters, and it is the keystone problem in
// miniature. 6.86 of thread against a 4.5 tile leaves 2.36 for the nut, and a
// thin M6 nut is about 2.4. It does not go. This part is built for sheet metal.
//
// So the tile is relieved from BEHIND: a counterbore that lets the body seat
// 2 mm deeper, leaving a 2.5 mm web at the front. Thread then spans 2.5 + 2.4 =
// 4.9 against 6.86, with 2 mm spare. Nut sits on the front face, not recessed.
AUDIO_D    = 6.2;      // -> 6.0 printed, against a 5.84 thread
AUDIO_RB_D = 13.0;     // clears the 12.45 body
AUDIO_WEB  = 2.5;      // what is left at the front
// MEASURED on the part 2026-09-07, replacing numbers read off a product image:
// thread 6.9 (drawing said 6.86) and the nut 2.5 (assumed 2.4, never known).
// 2.5 web + 2.5 nut = 5.0 against 6.9, so 1.9 mm spare. The relief stands.
AUDIO_THREAD = 6.9;
AUDIO_NUT    = 2.5;
assert(AUDIO_WEB + AUDIO_NUT <= AUDIO_THREAD,
       "audio jack has no thread left for its nut");
assert(AUDIO_RB_D > 12.45, "audio relief will not pass the jack body");

// --- Fasteners. ruthex RX-M3x5.7, hole published on the bag (S13 #10) -------
INSERT_LEN = 5.7;
INSERT_D   = 4.2;    // -> 4.0 as printed on this machine (S6 offset)
INSERT_H   = 6.7;    // vendor minimum blind depth
INSERT_SKIN = 1.0;   // material left over a blind seat, so nothing shows
BOSS_H     = 1.7;    // local thickening that buys the depth
BOSS_D     = 8;
// 3.6, not 3.4. Drawn 3.4 prints ~3.2 on this machine and an M3 is 3.0 max, so
// 0.1 mm of radial clearance - which is fine for one part and not fine for two
// separately printed parts whose hole patterns have to line up. The plinth
// bolts into the tray, the cradle and shroud bolt into the tray, and every
// tile bolts into the frame. Same reasoning that put the RJ45 ears at 3.6.
M3_CLEAR   = 3.6;
M4_CLEAR   = 4.7;    // -> 4.5 printed, against a 4.0 screw

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
    [for (sx = [-1, 1], x = [80, 115]) [sx*x, LEDGE_BACK_Y]]);

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
CR_SHROUD_X = CR_BLOCK_X + BATT_WIRE_W;       // outboard of posts AND lugs
CR_BLOCK_SIDE = -BATT_TERM_SIDE;
CR_CY = (BATT_FRONT + BATT_BACK)/2;
BLOCK_BOLT  = [for (y = [-1, 1])
    [CR_BLOCK_SIDE*(CR_BLOCK_X + CR_WALL + CR_FLANGE/2), CR_CY + y*(BATT_D/2 - 10)]];
SHROUD_BOLT = [for (y = [-1, 1])
    [BATT_TERM_SIDE*(CR_SHROUD_X + CR_WALL + CR_FLANGE/2), CR_CY + y*(BATT_D/2 - 10)]];
CRADLE_BOLT = concat(BLOCK_BOLT, SHROUD_BOLT);
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
// The front-ledge-vs-screen check lives in plate.scad, where it can be derived
// from the ledge frame_full() actually draws rather than from the intended one.
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
