#!/usr/bin/env bash
# The touch layer: an on-screen keyboard, and gestures the compositor cannot do.
#
# THE PROBLEM THIS SOLVES. This deck's only guaranteed pointer is the panel, and
# niri gives a bare touchscreen almost nothing: window management is entirely
# keybinds, prefer-no-csd removes even a titlebar to drag, and niri's own
# 3-finger and 4-finger gestures are unreachable because they are fed by
# libinput POINTER gesture events, which libinput synthesises only for
# touchpads. The panel is a 10-point multitouch device (ABS_MT_SLOT max 9) whose
# extra fingers currently go nowhere.
#
# TWO PACKAGES, both plain apt, both already in trixie:
#
#   wvkbd 0.15-1  - on-screen keyboard over virtual-keyboard-v1.
#   lisgd 0.3.7-1 - reads the touch device directly and runs commands.
#
# WHY NOT squeekboard, WHICH IS ALREADY INSTALLED HERE. It is input-method
# driven: it appears when a client asks for text input through text-input-v3. No
# XWayland client ever does, so it would never raise itself for fldigi or
# anything else arriving through xwayland-satellite, and those are exactly the
# programs you are stuck with when the keyboard is in the lid. wvkbd sends real
# key events to whatever has focus and does not care what toolkit it is.
#
# NOTHING IS GRABBED. lisgd observes the evdev node alongside the compositor, so
# taps, drags and scrolling still reach niri and the apps. The gesture set
# mirrors what the Perixx touchpad would do if plugged in, so there is one set
# of habits rather than two.
#
# The user is already in the `input` group on this machine and /dev/input/event*
# is root:input 0660, so no udev rule or group change is needed. Checked
# 2026-09-29; if that ever stops being true, that is the thing to check first.

source "$(dirname "$0")/lib.sh"
need_sudo

REPO="$(cd "$(dirname "$0")/.." && pwd)"

apt_install wvkbd lisgd

log "Installing the touch helpers into /usr/local/bin"
for f in deck-niri deck-osk deck-gestures; do
    sudo install -Dm755 "$REPO/files/touch/$f" "/usr/local/bin/$f"
done

# Group membership is a prerequisite rather than something to set up: changing
# it would need a re-login, and it is already satisfied.
id -nG | tr ' ' '\n' | grep -qx input || \
    warn "$USER is not in the 'input' group; lisgd will not be able to read the panel."

log "Writing the deck-gestures user unit"
install -Dm644 /dev/stdin "$HOME/.config/systemd/user/deck-gestures.service" <<UNIT
[Unit]
Description=Touchscreen gestures (lisgd)
After=graphical-session.target
PartOf=graphical-session.target

[Service]
Type=simple
ExecStart=/usr/local/bin/deck-gestures
Restart=on-failure
RestartSec=5

[Install]
# graphical-session.target, not default.target: every gesture ends in
# \`niri msg action\`, which needs a compositor to talk to. lisgd also refuses to
# start without WAYLAND_DISPLAY unless it is given -w/-h by hand, and that
# variable only exists in the user manager once niri-session has imported it.
WantedBy=graphical-session.target
UNIT

systemctl --user daemon-reload

echo
log "Installed, NOT started. Gestures change how the machine feels under your"
log "hand, so try them in the foreground first and keep Ctrl+C:"
log "    deck-gestures"
echo
log "Then, if you want them:"
log "    systemctl --user enable --now deck-gestures"
log "Back out with:"
log "    systemctl --user disable --now deck-gestures"
echo
log "The gesture set (directions follow natural-scroll, as the touchpad does):"
log "    swipe up from the BOTTOM edge   on-screen keyboard, toggle"
log "    swipe down from the TOP edge    the Overview (also Mod+O)"
log "    3 fingers up / down             next / previous workspace"
log "    3 fingers left / right          scroll the columns"
echo
log "The keyboard alone, without the gestures:  deck-osk   (also Mod+I)"
