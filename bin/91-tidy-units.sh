#!/usr/bin/env bash
# Silence services that can never succeed on this machine, so `systemctl
# is-system-running` reports "running" rather than a permanent "degraded".
#
# WHY THIS MATTERS: a machine that is always degraded trains you to ignore the
# word. Four units were failing at every boot, none of them fixable by making
# them work, all of them fixable by not starting them. After this, a degraded
# state means something is ACTUALLY wrong.
#
# Every one is disabled or hidden, never deleted — all four are one command from
# coming back.

source "$(dirname "$0")/lib.sh"
need_sudo

# --- 1. mako.service: the waybar duplicate, missed the first time -------------
# Same pattern as waybar (DESIGN §6): Debian ships mako.service enabled, and
# enabled GLOBALLY via /etc/systemd/user/graphical-session.target.wants/. niri
# also spawns mako from config.kdl, so the systemd copy loses the race for the
# D-Bus name and fails. One mako runs; the unit just fails noisily beside it.
if [ -e /etc/systemd/user/graphical-session.target.wants/mako.service ]; then
    sudo systemctl --global disable mako.service
    log "mako.service globally disabled (niri spawns mako from config.kdl)"
else
    log "mako.service already not globally enabled"
fi
systemctl --user reset-failed mako.service 2>/dev/null || true

# --- 2 & 3. XDG autostart entries that cannot succeed -------------------------
# niri-session pulls in xdg-desktop-autostart.target, so Raspberry Pi OS's
# /etc/xdg/autostart entries run under niri. Two of them are guaranteed to fail:
#
#   pulseaudio  - this machine runs pipewire + pipewire-pulse + wireplumber.
#                 Classic pulseaudio cannot start; pipewire owns the sockets.
#   polkit-mate - lxpolkit.desktop also autostarts and wins the D-Bus name.
#                 Exactly one agent is needed and lxpolkit is it.
#
# Suppressed with a per-user override rather than by masking the generated unit
# or editing /etc/xdg: a same-named .desktop in ~/.config/autostart carrying
# Hidden=true is the mechanism the XDG spec defines for this, and it survives
# package updates that would rewrite the system copy.
mkdir -p "$HOME/.config/autostart"
for entry in pulseaudio polkit-mate-authentication-agent-1; do
    src="/etc/xdg/autostart/$entry.desktop"
    dst="$HOME/.config/autostart/$entry.desktop"
    if [ -f "$src" ] && [ ! -f "$dst" ]; then
        printf '[Desktop Entry]\nType=Application\nName=%s\nHidden=true\n' "$entry" > "$dst"
        log "hidden: $entry (see comment above for why it cannot succeed)"
    fi
done

# --- 4. soundmodem.service ----------------------------------------------------
# /etc/ax25/soundmodem.conf is an empty template — literally
# `<?xml version="1.0"?><modem/>` with no modem defined — so soundmodem exits
# with "Configuartion not found" [sic] at every boot. It has never worked on
# this machine. direwolf is the packet TNC actually installed here.
#
# Masked, not purged: configure /etc/ax25/soundmodem.conf and
# `sudo systemctl unmask soundmodem` to bring it back.
if systemctl is-enabled soundmodem.service >/dev/null 2>&1; then
    sudo systemctl mask soundmodem.service
    sudo systemctl reset-failed soundmodem.service 2>/dev/null || true
    log "soundmodem.service masked (its config is an empty template)"
fi

echo
log "Done. These take effect at the next login/reboot for the user units."
log "Check with:  systemctl is-system-running"
