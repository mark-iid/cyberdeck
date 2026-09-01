#!/usr/bin/env bash
# Switch which session lightdm autologins into.
#
# THIS MACHINE DOES NOT SHOW A GREETER. Raspberry Pi OS ships autologin:
#   autologin-user=mark
#   autologin-session=rpd-labwc
# so there is no session menu to pick niri from — the deck boots straight into
# labwc. Changing the session therefore means editing lightdm.conf, not clicking
# something at login. (greeter-session=pi-greeter-labwc is only reached if
# autologin is disabled, and pi-greeter is not guaranteed to offer a session
# picker at all — which is why this script exists rather than advice to log out.)
#
#   ./90-set-session.sh niri     # boot into niri
#   ./90-set-session.sh labwc    # back to stock Raspberry Pi OS desktop
#   ./90-set-session.sh status
#
# RECOVERY, if niri fails to start on boot: you still have ssh, and tty1-tty6
# via Ctrl+Alt+F1..F6. Run this script with 'labwc' and reboot.

source "$(dirname "$0")/lib.sh"
need_sudo

CONF=/etc/lightdm/lightdm.conf
BAK="$CONF.pre-cyberdeck"

current() { grep -E "^autologin-session=" "$CONF" | cut -d= -f2; }

case "${1:-status}" in
status)
    log "autologin-session = $(current)"
    log "autologin-user    = $(grep -E '^autologin-user=' "$CONF" | cut -d= -f2)"
    echo
    log "sessions lightdm knows about:"
    for f in /usr/share/wayland-sessions/*.desktop /usr/share/xsessions/*.desktop; do
        [ -f "$f" ] && printf '    %-22s %s\n' "$(basename "$f" .desktop)" \
            "$(grep -m1 '^Name=' "$f" | cut -d= -f2)"
    done
    ;;

niri|labwc|rpd-labwc)
    target="$1"; [ "$target" = labwc ] && target=rpd-labwc
    [ -f "/usr/share/wayland-sessions/$target.desktop" ] \
        || die "no /usr/share/wayland-sessions/$target.desktop — refusing to set a session that does not exist"

    [ -f "$BAK" ] || { sudo cp "$CONF" "$BAK"; log "backed up -> $(basename "$BAK")"; }
    sudo sed -i "s/^autologin-session=.*/autologin-session=$target/" "$CONF"
    log "autologin-session = $(current)"
    warn "Reboot (or: sudo systemctl restart lightdm) to apply."
    [ "$target" = niri ] && {
        warn "If niri does not come up: ssh in, or Ctrl+Alt+F2, then run"
        warn "  $0 labwc && sudo systemctl restart lightdm"
    }
    ;;

*) die "usage: $0 [niri|labwc|status]" ;;
esac
