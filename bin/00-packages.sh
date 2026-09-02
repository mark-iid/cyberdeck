#!/usr/bin/env bash
# Everything the cyberdeck needs that Debian actually packages.
#
# Only three things are NOT here, because trixie does not ship them:
#   niri                 -> 10-build-niri.sh
#   xwayland-satellite   -> 20-build-xwayland-satellite.sh
#   MSHV                 -> 30-build-mshv.sh
#
# Verified present in trixie/rpt arm64 on 2026-08-31.

source "$(dirname "$0")/lib.sh"
need_sudo

log "Refreshing package lists"
sudo apt-get update -qq

# --- The niri session itself -------------------------------------------------
# niri is the only missing piece; its whole ecosystem is packaged.
apt_install \
    foot fuzzel waybar swaybg swayidle gtklock \
    mako-notifier cliphist wl-clipboard wmctrl \
    xdg-desktop-portal-wlr xdg-desktop-portal-gtk \
    seatd xwayland \
    brightnessctl playerctl \
    network-manager-gnome blueman \
    mate-polkit pavucontrol wireplumber

# NOTE: Debian names the notification daemon 'mako-notifier', but the binary is
# still 'mako'. The niri config spawns 'mako' — that is correct, not a typo.

# --- Build toolchain (shared by all three from-source builds) ---------------
apt_install \
    build-essential git curl pkg-config clang

# --- niri build deps --------------------------------------------------------
apt_install \
    libudev-dev libgbm-dev libxkbcommon-dev libegl1-mesa-dev \
    libwayland-dev libinput-dev libseat-dev libpipewire-0.3-dev \
    libpango1.0-dev libdisplay-info-dev libdbus-1-dev libsystemd-dev

# --- xwayland-satellite build deps ------------------------------------------
apt_install libxcb1-dev libxcb-cursor-dev

# --- MSHV build deps --------------------------------------------------------
# Qt5 (not Qt6 — MSHV is Qt5, as are WSJT-X and JTDX on this machine).
# libqt5websockets5-dev is required by MSHV_Slarm64_PI.pro's "QT += websockets".
# libpulse-dev is required by its "-lpulse-simple -lpulse".
apt_install \
    qtbase5-dev qt5-qmake qtbase5-dev-tools \
    qtmultimedia5-dev libqt5serialport5-dev libqt5websockets5-dev \
    libasound2-dev libpulse-dev libfftw3-dev

# --- Wayland platform plugins for BOTH Qt generations ------------------------
# config.kdl sets QT_QPA_PLATFORM=wayland globally. Any Qt app whose generation
# lacks its wayland plugin then dies at startup with
#   "Could not find the Qt platform plugin \"wayland\""
# and the failure is total, not a fallback.
#
# qtwayland5 covers Qt5: wsjtx, jtdx, MSHV, gqrx.
# qt6-wayland covers Qt6 — MISSED INITIALLY, and qutebrowser (PyQt6) would not
# start until it was added. Any future Qt6 app hits the same wall, so both are
# installed unconditionally rather than on demand.
apt_install qtwayland5 qt6-wayland

log "All packaged dependencies installed."
