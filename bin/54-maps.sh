#!/usr/bin/env bash
# Offline map data. Installing viewers without data was an omission — qmapshack,
# viking and marble were inert until this ran.
#
# FORMATS MATTER, and they differ per viewer:
#   QMapShack  wants Garmin .img (vector) or GDAL rasters. It CANNOT read
#              Mapsforge .map, and .map cannot be converted to .img — they have
#              to be built from source data.
#   Xastir     wants ESRI Shapefiles, and has native support for US Census
#              TIGER/Line. Its built-in "online TIGER" needs the internet, which
#              is exactly what is absent when this deck matters.
#
# So this fetches SOURCE data plus the tools to render it, rather than one
# vendor's prebuilt file. After this runs the deck can generate a Garmin map for
# ANY region with no network, which a prebuilt download cannot do.

source "$(dirname "$0")/lib.sh"
need_sudo

DEST="${DEST:-$HOME/maps}"
PBF="$DEST/us-latest.osm.pbf"
mkdir -p "$DEST"/{tiger,garmin}

apt_install mkgmap osmium-tool gdal-bin

avail=$(df --output=avail -BG "$DEST" | tail -1 | tr -dc '0-9')
[ "$avail" -gt 40 ] || die "Only ${avail}G free; need ~15G plus working space."

# --- 1. Whole-US OpenStreetMap extract ---------------------------------------
# 11.28 GB. This is the canonical source: full detail everywhere, including
# southwestern PA. "More detailed maps for SW PA" is not a separate download —
# OSM data IS the detail; the extract below just renders a subset of it.
log "Fetching the US OSM extract (~11.3 GB, resumable)"
wget -c -q --show-progress --progress=dot:giga -O "$PBF" \
    "https://download.geofabrik.de/north-america/us-latest.osm.pbf" \
    || warn "US pbf incomplete — re-run to resume"

# --- 2. TIGER/Line shapefiles for southwestern PA -> Xastir -------------------
# Per-county ROADS and AREAWATER, plus state-level PLACE and PRISECROADS.
# TIGER2025 is the current vintage (verified 2026-09-02).
# FIPS 42 = Pennsylvania.
TY=2025
declare -A CO=( [003]=Allegheny [005]=Armstrong [007]=Beaver [019]=Butler
                [051]=Fayette [059]=Greene [063]=Indiana [111]=Somerset
                [125]=Washington [129]=Westmoreland )
log "Fetching TIGER${TY} shapefiles for ${#CO[@]} southwestern PA counties"
for fips in "${!CO[@]}"; do
    for layer in ROADS AREAWATER; do
        f="tl_${TY}_42${fips}_$(echo $layer | tr 'A-Z' 'a-z').zip"
        [ -f "$DEST/tiger/$f" ] && continue
        curl -fsS --max-time 180 -o "$DEST/tiger/$f" \
            "https://www2.census.gov/geo/tiger/TIGER${TY}/${layer}/${f}" \
            && log "  ${CO[$fips]} ${layer}" || warn "  ${CO[$fips]} ${layer} FAILED"
    done
done
for layer in PLACE PRISECROADS; do
    f="tl_${TY}_42_$(echo $layer | tr 'A-Z' 'a-z').zip"
    [ -f "$DEST/tiger/$f" ] || curl -fsS --max-time 300 -o "$DEST/tiger/$f" \
        "https://www2.census.gov/geo/tiger/TIGER${TY}/${layer}/${f}" && log "  PA statewide ${layer}"
done
log "Unpacking shapefiles for Xastir"
for z in "$DEST"/tiger/*.zip; do unzip -o -q -d "$DEST/tiger" "$z" 2>/dev/null; done
log "Xastir: Map -> Map Chooser, then add $DEST/tiger  (needs WGS84 lat/lon, TIGER already is)"

# --- 3. Build a Garmin .img for southwestern PA -> QMapShack -----------------
# osmium carves a bounding box out of the US pbf; mkgmap turns it into the .img
# QMapShack actually reads. Both run locally, so this is repeatable offline for
# any bbox later.
#
# BBOX covers the Pittsburgh region and the ten counties above:
#   west -80.6  south 39.6  east -78.3  north 41.1
if [ -s "$PBF" ]; then
    SWPA="$DEST/swpa.osm.pbf"
    if [ ! -f "$SWPA" ]; then
        log "Extracting southwestern PA from the US pbf"
        osmium extract -b -80.6,39.6,-78.3,41.1 "$PBF" -o "$SWPA" --overwrite \
            && log "  $(du -h "$SWPA" | cut -f1)"
    fi
    if [ -s "$SWPA" ] && [ ! -f "$DEST/garmin/gmapsupp.img" ]; then
        # SPLIT FIRST, then mkgmap. A single Garmin tile has a hard 16MB RGN-
        # section limit, and even the SW-PA extract (96MB pbf) blows past it:
        #   SEVERE: The RGN section of the map or tile is too big.
        # So the correct workflow for any non-trivial area is splitter -> mkgmap,
        # not mkgmap alone. Doing it properly here makes the "build a map for any
        # region offline" capability work for real regions, not just tiny ones.
        #
        # splitter is not in Debian (the apt "splitter" is a VLC plugin). Fetch
        # the official jar from mkgmap.org once and cache it.
        SPLITTER_DIR="$DEST/splitter"
        SPLITTER_JAR="$SPLITTER_DIR/splitter.jar"
        if [ ! -f "$SPLITTER_JAR" ]; then
            log "Fetching splitter from mkgmap.org"
            mkdir -p "$SPLITTER_DIR"
            if curl -fsSL --max-time 120 -o "$DEST/splitter.zip" \
                 "https://www.mkgmap.org.uk/download/splitter-r654.zip" \
               && unzip -o -q -d "$SPLITTER_DIR" "$DEST/splitter.zip"; then
                ln -sf "$(find "$SPLITTER_DIR" -name splitter.jar | head -1)" "$SPLITTER_JAR" 2>/dev/null \
                    || SPLITTER_JAR="$(find "$SPLITTER_DIR" -name splitter.jar | head -1)"
                rm -f "$DEST/splitter.zip"
            else
                warn "  splitter download failed — skipping the Garmin build."
                warn "  Xastir (TIGER shapefiles) is unaffected and already done."
                SPLITTER_JAR=""
            fi
        fi

        if [ -n "$SPLITTER_JAR" ] && [ -f "$SPLITTER_JAR" ]; then
            log "Splitting SW-PA into Garmin-sized tiles"
            ( cd "$DEST/garmin" && java -jar "$SPLITTER_JAR" \
                --output-dir="$DEST/garmin/tiles" "$SWPA" ) > "$DEST/splitter.log" 2>&1 || true
            log "Building the Garmin map from the tiles with mkgmap"
            ( cd "$DEST/garmin" && mkgmap --max-jobs=2 --gmapsupp --route --index \
                --description="SW Pennsylvania" \
                "$DEST/garmin/tiles"/*.osm.pbf ) > "$DEST/mkgmap.log" 2>&1 || true
            if [ -s "$DEST/garmin/gmapsupp.img" ]; then
                log "  built $DEST/garmin/gmapsupp.img ($(du -h "$DEST/garmin/gmapsupp.img" | cut -f1))"
            else
                warn "  mkgmap still produced no gmapsupp.img — see $DEST/mkgmap.log"
            fi
        fi
    fi
    log "QMapShack: Menu -> Setup Map Paths -> add $DEST/garmin"
fi

echo
log "To build a map for anywhere else later, with NO network:"
log "  osmium extract -b W,S,E,N $PBF -o region.osm.pbf"
log "  mkgmap --gmapsupp --route --index region.osm.pbf"
