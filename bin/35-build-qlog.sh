#!/usr/bin/env bash
# Build and install QLog (OK1MLG) — the logger this deck actually uses.
#
# WHY FROM SOURCE, which is the same question the other three builds answer.
# Upstream ships binaries for x86_64 ONLY: AppImage, Fedora rpm, Windows exe.
# Nothing for aarch64. Checked against the v0.53.0 release assets on 2026-09-29.
# The other routes and why they were not taken:
#
#   Ubuntu PPA  builds arm64, but it is Ubuntu, not Debian trixie. Mixing that
#               into Raspberry Pi OS is how apt gets broken.
#   Flathub     genuinely has an aarch64 build and is upstream's recommendation
#               for non-Ubuntu/Fedora distros, TrustedQSL included. Not taken:
#               it means adding flatpak as a parallel packaging system plus a
#               ~1.5 GB runtime to a machine whose README leads with "this is
#               additive", and the sandbox is friction for the two things a
#               logger needs most, hamlib rig control over USB serial and ADIF
#               paths on disk.
#   Debian      packages qlog in FORKY. Not in trixie. Same situation as niri:
#               it missed the freeze, so build it.
#
# WHAT IT REPLACED. cqrlog was removed on 2026-09-29 along with mariadb-server,
# which it was the sole reason for (DESIGN §10). xlog went with it. QLog is
# SQLite-backed and wants no database server at all.
#
# THE README'S DEPENDENCY LIST IS NOT ENOUGH, in two ways, both verified by
# building. Three packages are named for an older Debian:
#   libqt6charts6-dev -> qt6-charts-dev, libqt6svg6-dev -> qt6-svg-dev,
#   libqt6websockets6-dev -> qt6-websockets-dev
# and two Qt modules the .pro requires are not listed at all: `quickwidgets`
# (qt6-declarative-dev) and `webchannel` (qt6-webchannel-dev). Without those the
# qmake step fails on a missing module rather than on anything that names them.

source "$(dirname "$0")/lib.sh"
need_sudo

QLOG_REF="${QLOG_REF:-v0.53.0}"     # upstream DOES tag, unlike MSHV. Pin a tag.
QLOG_DIR="$BUILD_ROOT/QLog"

[ "$(uname -m)" = "aarch64" ] || warn "Not aarch64 ($(uname -m)) — this is the whole reason for building."

# Qt6, not Qt5. QLog.pro asks for charts, webenginewidgets, quickwidgets,
# webchannel, websockets, serialport, dbus, printsupport and sql.
apt_install \
    build-essential pkg-config \
    qt6-base-dev qt6-declarative-dev qt6-webengine-dev qt6-webchannel-dev \
    qt6-charts-dev qt6-svg-dev qt6-websockets-dev qt6-serialport-dev \
    qt6-tools-dev qtkeychain-qt6-dev \
    libhamlib-dev libsqlite3-dev libssl-dev libgl-dev

fetch_repo https://github.com/foldynl/QLog.git "$QLOG_DIR" "$QLOG_REF"
cd "$QLOG_DIR"

# qmake6, explicitly. `qmake` on this machine is Qt 5.15 and would configure a
# build that cannot succeed, failing somewhere unhelpful rather than here.
command -v qmake6 >/dev/null || die "qmake6 not found after installing qt6-base-dev"

log "Configuring with $(qmake6 -v 2>&1 | tail -1)"
qmake6 QLog.pro

thermal_check
make -j"$(build_jobs)"

[ -x ./qlog ] || die "Build produced no qlog binary — check make output above."

# STRIP. QLog.pro sets `CONFIG += force_debug_info`, so the linked binary is
# 236 MB of mostly DWARF. Stripped it is 17 MB. The unstripped copy stays in the
# build tree if a backtrace is ever wanted; /usr/local/bin gets the small one.
log "Installing qlog ($(du -h qlog | cut -f1) unstripped)"
cp qlog /tmp/qlog.$$ && strip /tmp/qlog.$$
sudo install -Dm755 /tmp/qlog.$$ /usr/local/bin/qlog
rm -f /tmp/qlog.$$
log "Installed /usr/local/bin/qlog ($(du -h /usr/local/bin/qlog | cut -f1) stripped)"

# .desktop entry so it appears in fuzzel beside the rest of the stack.
sudo install -Dm644 /dev/stdin /usr/local/share/applications/qlog.desktop <<DESKTOP
[Desktop Entry]
Type=Application
Name=QLog
GenericName=Amateur Radio Logger
Comment=Logging, awards, QSL and rig control
Exec=/usr/local/bin/qlog
Icon=qlog
Terminal=false
Categories=HamRadio;Network;
DESKTOP
[ -f res/icons/qlog.png ] && sudo install -Dm644 res/icons/qlog.png \
    /usr/local/share/icons/hicolor/128x128/apps/qlog.png 2>/dev/null || true

echo
log "Measured on the panel 2026-09-29, both numbers against 768 px of usable height:"
log "  main window     1272x768, the whole default layout fits, map and clock included"
log "  Settings dialog 800x882, which does NOT fit. It floats (config.kdl rule) and"
log "                  overflows the bottom by ~114 px, so its buttons are off screen."
log "                  Escape closes it; see the QLog window rules in config.kdl."
log "First run opens Settings and downloads DXCC/LOTW data. RSS settles near 500 MB."
