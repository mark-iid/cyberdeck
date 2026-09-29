#!/usr/bin/env bash
# Optional survival/cyberdeck additions. NOT run by provision.sh — pick tiers.
#
#   ./50-doomsday-extras.sh time      <- START HERE. See the comment below.
#   ./50-doomsday-extras.sh rf maps sec elec all
#
# Everything here was confirmed present in trixie/rpt arm64 on 2026-08-31.
# Already installed and deliberately not repeated: xastir, rtl-sdr,
# multimon-ng, gpsd, chrony, calibre, pat, direwolf, gqrx, gnuradio, gpredict.

source "$(dirname "$0")/lib.sh"
need_sudo

want() { printf '%s\n' "$@" | grep -qx -- "$TIER" || [ "$ALL" = 1 ]; }
ALL=0; [ "${1:-}" = "all" ] && ALL=1
[ $# -eq 0 ] && { sed -n '2,10p' "$0"; exit 0; }

for TIER in "$@"; do
case "$TIER" in

# --- TIME: the one that is actually a functional blocker --------------------
# FT8 requires the clock accurate to well under a second. This deck currently
# gets that from NTP OVER THE INTERNET (`timedatectl` reports NTP active).
# In the scenario the deck exists for, there is no NTP — the clock drifts, and
# within days FT8 silently stops decoding. Nothing else on this list matters if
# the radio cannot key at the right moment.
#
# Fix: a cheap USB GPS (u-blox or similar, appears as /dev/ttyACM0 or ttyUSB0),
# fed to gpsd, fed to chrony as a reference clock. gpsd and chrony are ALREADY
# installed; this adds the client tools and the wiring.
time)
    apt_install gpsd-clients pps-tools
    log "Installed gpsd-clients + pps-tools. gpsd and chrony were already present."
    echo
    warn "=============================================================="
    warn " HARDWARE: QRP Labs QLG2 GPS/GNSS receiver"
    warn "=============================================================="
    warn ""
    warn " !! BEFORE WIRING ANYTHING TO THE PI !!"
    warn " The QLG2's 1PPS, Serial, TXD and RXD default to 5V LOGIC."
    warn " Raspberry Pi GPIO is 3.3V ONLY. 5V into a GPIO can kill the SoC."
    warn " Cut the UPPER (5V) trace on JP2 (PPS level) and JP5 (SER level) and"
    warn " jumper each centre pad to its LOWER pad - 2.8V off the GNSS module,"
    warn " which clears the Pi's ~2.31V input-high threshold. LOWER is the pad"
    warn " NEAREST the board edge; the traces are on the underside, so left and"
    warn " right mirror but near-edge does not. JP8 is polarity-INVERTED, so do"
    warn " not copy the pattern onto it."
    warn " Then meter the 4-pin header before connecting: ~2.8V, not 5V."
    warn " (The USB path below is unaffected — USB is safe as-is.)"
    warn ""
    warn " TIER 1 - USB only. Enough for FT8, no wiring, no risk."
    warn "   NMEA 9600 8N1 over the QLG2's USB-serial converter."
    warn "   1. plug in; confirm /dev/ttyACM0 or /dev/ttyUSB0 appears"
    warn "   2. /etc/default/gpsd:  DEVICES=\"/dev/ttyACM0\"  GPSD_OPTIONS=\"-n\""
    warn "   3. systemctl enable --now gpsd && cgps      # wait for a fix"
    warn "   4. /etc/chrony/chrony.conf:"
    warn "        refclock SHM 0 refid GPS precision 1e-1 offset 0.0 delay 0.2"
    warn "   5. systemctl restart chrony && chronyc sources -v"
    warn "   Expect tens of milliseconds. FT8 needs sub-second, so this is fine."
    warn ""
    warn " TIER 2 - GPIO serial + 1PPS, for microsecond timing (optional)."
    warn "   USB carries polling jitter; a PPS edge on a GPIO does not."
    warn "   THIS IS NOW A SCRIPT:  bin/57-gps-time.sh install"
    warn "   Read its header first - the wiring and the QLG2 jumpers are in it."
    warn "   Measured 2026-09-28: chrony selected PPS at -380ns, +/-352ns."
    warn ""
    warn "   Three things that cost hours if you do this by hand instead:"
    warn "   * /dev/pps0 IS NOT STABLE. The Pi 5's Ethernet PTP clock registers"
    warn "     a PPS device too, and which one gets pps0 changes across boots -"
    warn "     watched it swap on a single reboot. 'refclock PPS /dev/pps0'"
    warn "     points chrony at the NIC about half the time and fails SILENTLY."
    warn "     57-gps-time.sh pins it by device-tree name as /dev/pps-gps."
    warn "   * /dev/serial0 IS NOT THE HEADER UART on a Pi 5. It is ttyAMA10,"
    warn "     the debug connector. Use /dev/ttyAMA0 by name. And it is enabled"
    warn "     with dtparam=uart0=on, NOT enable_uart=1."
    warn "   * PIN 14 IS GROUND AND IT IS NEXT TO PIN 12. One position out puts"
    warn "     1PPS into a dead short. Count: pin 10 is 5th on the outer row,"
    warn "     12 is 6th, 14 is 7th."
    warn ""
    warn " VERIFY IT ACTUALLY WORKS: unplug the network, reboot, and confirm"
    warn " the clock is still right and FT8 still decodes. That is the whole"
    warn " point — an off-grid deck cannot reach NTP."
    ;;

# --- RF: passive intelligence from the spectrum -----------------------------
rf)
    # satdump decodes NOAA/Meteor weather satellites into images — with gpredict
    # (already installed) for pass prediction, that is offline weather.
    # rtl_433 reads the 433MHz sensor soup: neighbours' weather stations, tyre
    # sensors, door sensors. readsb is ADS-B: aircraft, which is a decent proxy
    # for "is normal life still happening".
    apt_install satdump rtl-433 readsb
    log "satdump (weather sats) + rtl_433 (433MHz sensors) + readsb (ADS-B) installed."
    warn "No SDR was attached when this was checked. These need an RTL-SDR dongle."
    ;;

# --- MAPS: offline geography ------------------------------------------------
# A survival deck that cannot answer "where am I and what is around me" is
# missing something Wikipedia does not cover.
maps)
    apt_install qmapshack viking marble
    log "qmapshack (GPX/topo, best offline raster+vector support), viking, marble."
    warn "These are VIEWERS. They are useless without map DATA — download an"
    warn "OpenStreetMap regional extract (.mbtiles or .map) BEFORE you need it."
    warn "See docs/CONTENT.md."
    ;;

# --- SECURITY / DATA ---------------------------------------------------------
sec)
    apt_install keepassxc age borgbackup syncthing
    log "keepassxc (offline credential vault), age (file encryption),"
    log "borgbackup (dedup backups), syncthing (LAN sync, no cloud)."
    ;;

# --- ELECTRONICS: fix and build things --------------------------------------
elec)
    # NOTE: kicad is heavy and this Pi is thermally throttled to 1.0GHz
    # (DESIGN.md §6). Usable, but not pleasant, until a fan is fitted.
    apt_install sigrok-cli pulseview ngspice gtkwave
    log "pulseview/sigrok (logic analyser), ngspice (circuit sim), gtkwave."
    warn "kicad is available (9.0.2) but NOT installed here — it is heavy and"
    warn "this Pi runs at 42% clock. Install deliberately: sudo apt install kicad"
    ;;

*) die "Unknown tier '$TIER'. Try: time rf maps sec elec all" ;;
esac
done

log "Done. Not in Debian and worth a manual look: meshtastic (LoRa mesh),"
log "dump1090-fa, noaa-apt, veracrypt, ardop."
