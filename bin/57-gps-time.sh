#!/usr/bin/env bash
# GPS time and position from a QRP Labs QLG2 on the GPIO header (DESIGN §9).
#
# This is TIER 2 of 50-doomsday-extras.sh's `time` tier, with the wiring done.
# Tier 1 (a USB GPS) needs none of this and is enough for FT8; everything here
# buys the microsecond-class 1PPS edge on top, which USB polling jitter cannot
# give you.
#
#   ./57-gps-time.sh install      # apply everything, then REBOOT
#   ./57-gps-time.sh check        # report state, changes nothing
#   ./57-gps-time.sh restore      # undo, from the backups install took
#
# WIRING — QLG2 4-pin header to the Pi 5 GPIO header. Count the OUTER row of
# pins (the even-numbered one) from the left:
#
#   QLG2 pin   Pi pin   Position on the outer row
#   5V+        2        1st
#   Gnd        6        3rd
#   TXD        10       5th   (GPIO15 / RXD0)
#   1pps       12       6th   (GPIO18)
#
# The Pi's TX is deliberately NOT wired. Nothing needs to talk to the QLG2, and
# leaving it off means there is no direction in which a level mismatch matters.
#
# !! PIN 14 IS GROUND AND IT IS THE VERY NEXT PIN AFTER 12 !!
# Being one position out puts the QLG2's 1PPS push-pull output into a dead
# short. Ask how I know. Count twice: 10 is 5th, 12 is 6th, 14 is 7th.
#
# !! LOGIC LEVELS: the QLG2 ships at 5V and a Pi GPIO is 3.3V only !!
# On the QLG2, cut the UPPER (5V) trace on JP2 (PPS level) and JP5 (SER level)
# and jumper each centre pad to its LOWER pad, which is 2.8V straight off the
# GNSS module. 2.8V clears the Pi's ~2.31V input-high threshold with half a volt
# to spare. LOWER is the pad NEAREST the board edge - that holds however you are
# holding it, and it survives flipping to the underside where the traces are.
# Do NOT pattern-match JP8: its polarity is inverted, UPPER is 2.8V there.
# Verify with a meter on the 4-pin header BEFORE connecting anything to the Pi:
# TxD and 1pps must read ~2.8V. If either reads 5V, stop.

source "$(dirname "$0")/lib.sh"

CFG=/boot/firmware/config.txt
CMD=/boot/firmware/cmdline.txt
UDEV=/etc/udev/rules.d/90-gps-pps.rules
GPSD=/etc/default/gpsd
CHRONY=/etc/chrony/chrony.conf

PPS_GPIO=18

# The device-tree name the pps-gpio overlay gives its capture device, and it is
# NOT "pps@18". Device-tree node addresses are HEX, so GPIO18 shows up as
# pps@12. Build the name by converting, because writing the decimal number
# straight in makes the udev rule silently never match and /dev/pps-gps never
# appear - which looks exactly like a bad overlay. The ".-1" suffix is the
# overlay's own, not a typo.
PPS_DT_NAME="pps@$(printf '%x' "$PPS_GPIO").-1"

install_gps() {
    need_sudo

    # gpsd and chrony are already on the image; these are the missing pieces.
    apt_install gpsd-clients pps-tools

    sudo cp -n "$CFG" "$CFG.pre-gps"
    sudo cp -n "$CMD" "$CMD.pre-gps"

    # --- The UART -----------------------------------------------------------
    # On a Pi 5 this is dtparam=uart0=on, NOT enable_uart=1. raspi-config picks
    # the right one via its own is_pifive test, which is why this shells out to
    # it rather than writing the line directly - the correct line differs by
    # board and there is no reason to duplicate that knowledge here.
    #
    # do_serial_cons 1 removes console=serial0 from cmdline.txt, which is what
    # actually stops the serial getty. On a Pi 5 that console was never on
    # GPIO14/15 anyway (see below), so this is tidiness rather than a conflict -
    # but it also costs the debug-UART recovery path, so it is worth knowing you
    # gave it up. `restore` puts it back.
    sudo raspi-config nonint do_serial_hw 0
    sudo raspi-config nonint do_serial_cons 1

    # --- 1PPS ---------------------------------------------------------------
    if grep -q "^dtoverlay=pps-gpio" "$CFG"; then
        log "config.txt: pps-gpio already present"
    else
        printf '\n# QLG2 GPS 1PPS on GPIO%s (header pin 12)\ndtoverlay=pps-gpio,gpiopin=%s\n' \
            "$PPS_GPIO" "$PPS_GPIO" | sudo tee -a "$CFG" >/dev/null
        log "config.txt: added dtoverlay=pps-gpio,gpiopin=$PPS_GPIO"
    fi

    # --- Which /dev/ppsN is OURS --------------------------------------------
    # THE TRAP: the Pi 5's Ethernet PHY registers a PPS device of its own for
    # its PTP clock, so there are TWO. Which one gets pps0 is decided by probe
    # order and it MOVES: measured 2026-09-28, ptp0 held pps0 before a reboot
    # and pps1 after it, with the GPIO capture taking the other each time.
    #
    # So `refclock PPS /dev/pps0` points chrony at the network card about half
    # the time, and it fails silently - chrony just never gets a sample. Match
    # the device by its device-tree name and hand chrony a stable symlink.
    printf '%s\n' \
        "# The Pi 5's Ethernet PTP clock also registers a PPS device, and which" \
        "# of the two gets /dev/pps0 changes across boots. Match the pps-gpio" \
        "# capture by name so chrony always gets the GPS and never the NIC." \
        "SUBSYSTEM==\"pps\", ATTR{name}==\"$PPS_DT_NAME\", SYMLINK+=\"pps-gps\"" \
        | sudo tee "$UDEV" >/dev/null
    sudo udevadm control --reload-rules
    log "udev: $UDEV -> /dev/pps-gps"

    # --- gpsd ---------------------------------------------------------------
    # ttyAMA0 BY NAME, never serial0. On a Pi 5 /dev/serial0 is a symlink to
    # ttyAMA10, which is the separate debug connector, NOT the GPIO header. A
    # config that says serial0 reads a port with nothing on it.
    #
    # PPS is deliberately not in DEVICES: chrony opens /dev/pps-gps itself as a
    # refclock, so gpsd never needs to touch it. gpsd gets the UART only.
    sudo cp -n "$GPSD" "$GPSD.orig"
    printf '%s\n' \
        '# QLG2 on the GPIO header UART. ttyAMA0 by name: /dev/serial0 on a Pi 5' \
        '# points at ttyAMA10, the debug connector, which is a different port.' \
        '# PPS is absent on purpose - chrony reads /dev/pps-gps directly.' \
        'DEVICES="/dev/ttyAMA0"' \
        '' \
        '# -n: poll without waiting for a client, so chrony has SHM from boot.' \
        '# -b: never write to the receiver. The Pi TX is not wired, so probing' \
        '#     it is pointless; read-only stops gpsd hunting on a dead line.' \
        'GPSD_OPTIONS="-n -b"' \
        '' \
        'USBAUTO="false"' \
        | sudo tee "$GPSD" >/dev/null
    log "gpsd: $GPSD -> /dev/ttyAMA0, -n -b"

    # -n only means anything if gpsd is actually RUNNING. Socket activation
    # waits for a client, which is the opposite of what -n asks for, so the
    # socket has to go or chrony's SHM stays empty until something connects.
    sudo systemctl disable --now gpsd.socket >/dev/null 2>&1 || true
    sudo systemctl enable gpsd.service >/dev/null 2>&1 || true
    # `enable gpsd.service` re-enables the socket via the sysv compat shim, so
    # it has to be put back down AFTER that, not before. Stop as well as
    # disable: a disabled-but-still-active socket stays a triggering unit, and
    # then `systemctl stop gpsd` blocks rather than returning.
    sudo systemctl disable gpsd.socket >/dev/null 2>&1 || true
    sudo systemctl stop gpsd.socket >/dev/null 2>&1 || true
    sudo systemctl restart gpsd.service >/dev/null 2>&1 || true
    log "gpsd: service enabled, socket stopped and disabled"

    # --- chrony -------------------------------------------------------------
    # NMEA only numbers the seconds; PPS does the actual disciplining. noselect
    # keeps the serial sentences out of the selection - they are the coarse
    # reference PPS locks onto, nothing more.
    sudo cp -n "$CHRONY" "$CHRONY.orig"
    if grep -q "refclock PPS" "$CHRONY"; then
        log "chrony: refclocks already present"
    else
        printf '%s\n' \
            '' \
            '# --- GPS discipline: QLG2 on the GPIO header (DESIGN §9) -------------' \
            '# NMEA numbers the seconds, PPS disciplines the clock. noselect keeps the' \
            '# sentences out of the selection; they are only what PPS locks onto.' \
            '# Retune offset from `chronyc sourcestats` once it has run a while - at' \
            '# 9600 baud the sentence lag is significant.' \
            '#' \
            '# /dev/pps-gps, NOT /dev/pps0: the GPIO capture and the Ethernet PTP clock' \
            '# swap numbers across boots. The symlink is pinned by name in' \
            '# /etc/udev/rules.d/90-gps-pps.rules.' \
            'refclock SHM 0 refid NMEA offset 0.2 delay 0.2 noselect' \
            'refclock PPS /dev/pps-gps lock NMEA refid PPS prefer' \
            | sudo tee -a "$CHRONY" >/dev/null
        log "chrony: added NMEA + PPS refclocks"
    fi

    echo
    warn "REBOOT REQUIRED - the UART and the pps-gpio overlay are boot-time."
    warn "Then: $0 check"
}

check_gps() {
    log "--- devices ---"
    [ -e /dev/ttyAMA0 ] && echo "  /dev/ttyAMA0   present" \
        || warn "  /dev/ttyAMA0   MISSING - dtparam=uart0=on not applied, or no reboot yet"
    [ -e /dev/pps-gps ] && echo "  /dev/pps-gps   -> $(readlink -f /dev/pps-gps)" \
        || warn "  /dev/pps-gps   MISSING - udev rule did not match"
    for d in /sys/class/pps/pps*; do
        [ -e "$d" ] || continue
        n=$(cat "$d/name" 2>/dev/null)
        printf '  %-14s name=%s%s\n' "$(basename "$d")" "$n" \
            "$([ "$n" = "$PPS_DT_NAME" ] && echo '   <- the GPS one' || echo '   (not ours)')"
    done

    log "--- daemons ---"
    printf '  gpsd.service   %s / %s\n' "$(systemctl is-enabled gpsd.service 2>&1)" "$(systemctl is-active gpsd.service 2>&1)"
    printf '  gpsd.socket    %s   (want: disabled - it defeats -n)\n' "$(systemctl is-enabled gpsd.socket 2>&1)"
    printf '  chrony         %s / %s\n' "$(systemctl is-enabled chrony 2>&1)" "$(systemctl is-active chrony 2>&1)"

    log "--- is the receiver actually talking? ---"
    if [ -e /dev/ttyAMA0 ]; then
        # Read the NMEA THROUGH gpsd, never from /dev/ttyAMA0 directly. Two
        # reasons, both found the hard way:
        #   - Stopping gpsd to free the port hangs. A disabled gpsd.socket can
        #     still be ACTIVE, systemd calls it a triggering unit, and the stop
        #     blocks instead of returning.
        #   - A bare `cat` on the port with nothing arriving does not reliably
        #     come back under `timeout` either.
        # Going through gpspipe avoids both and tests more of the chain anyway.
        local n
        if [ "$(systemctl is-active gpsd 2>/dev/null)" != active ]; then
            warn "  gpsd is not running - starting it to read the port"
            sudo systemctl start gpsd.service >/dev/null 2>&1 || true
            sleep 2
        fi
        n=$(timeout 8 gpspipe -r -n 20 2>/dev/null | wc -c)
        if [ "${n:-0}" -gt 0 ]; then
            echo "  NMEA           $n bytes seen"
        else
            warn "  NMEA           NOTHING. The receiver is silent, or TXD is not on pin 10."
            warn "                 Check the QLG2's yellow LED: it rests ON and flicks OFF"
            warn "                 during each data burst. Solid = no data leaving the board."
        fi
    fi

    if [ -e /dev/pps-gps ]; then
        # ppstest is the direct test, but a miss is not evidence of absence: it
        # samples a short window and 1PPS only runs while the receiver holds a
        # 3D fix. chrony's Reach column is the better authority - it is the
        # running history. Ask ppstest first, then fall back to what chrony has
        # actually been getting, so a working clock is never reported as broken.
        if sudo timeout 4 ppstest /dev/pps-gps 2>&1 | grep -q "assert"; then
            echo "  1PPS           pulses seen"
        elif chronyc sources 2>/dev/null | awk '/PPS/ && $4 != "0" {found=1} END {exit !found}'; then
            echo "  1PPS           none in a 4s window, but chrony has samples - fix is intermittent"
        else
            warn "  1PPS           no pulses, and chrony has no samples either. Expected"
            warn "                 until the receiver holds a 3D fix - the QLG2's green LED"
            warn "                 only starts blinking once it has one."
        fi
    fi

    log "--- chrony's view ---"
    chronyc sources 2>&1 | grep -E "NMEA|PPS|Name|====" || true
    echo
    log "Reading it: '#*' on PPS means chrony has SELECTED the GPS as the system"
    log "reference - that is the goal state. '#?' means unreachable, which is"
    log "normal until the receiver holds a 3D fix."
    log ""
    log "If you see a -18s offset, that is the GPS-UTC leap second offset and NOT"
    log "a misconfiguration. It clears once the receiver holds a fix long enough"
    log "to download the UTC parameters, which can take 12.5 minutes of lock."
}

restore_gps() {
    need_sudo
    for f in "$CFG" "$CMD"; do
        [ -f "$f.pre-gps" ] && { sudo cp "$f.pre-gps" "$f"; log "restored $(basename "$f")"; }
    done
    [ -f "$GPSD.orig" ]   && { sudo cp "$GPSD.orig" "$GPSD"; log "restored $(basename "$GPSD")"; }
    [ -f "$CHRONY.orig" ] && { sudo cp "$CHRONY.orig" "$CHRONY"; log "restored chrony.conf"; }
    sudo rm -f "$UDEV" && log "removed $UDEV"
    sudo udevadm control --reload-rules
    warn "Reboot to drop the UART and the pps-gpio overlay."
}

case "${1:-}" in
    install) install_gps ;;
    check)   check_gps ;;
    restore) restore_gps ;;
    *)       sed -n '2,40p' "$0"; exit 0 ;;
esac
