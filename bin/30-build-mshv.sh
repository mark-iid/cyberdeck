#!/usr/bin/env bash
# Build and install MSHV (LZ2HV) — FT8/FT4/Q65/MSK144/JT65 for a small screen.
#
# WHY MSHV ON THIS MACHINE (DESIGN.md §3): the panel is 1280x800. WSJT-X's own
# saved geometry on this box is main=880x685 plus a SEPARATE WideGraph=938x337.
# Stacked that is 1022px against ~770px of usable height. It does not fit.
#
# MSHV folds the waterfall INTO the main window and toggles it with Ctrl+W
# (Ctrl+T hides the TX widget), and it SAVES those states. That removes the
# two-window problem rather than working around it — and unlike a CLI decoder
# it keeps rig control and logging.
#
# This does NOT replace WSJT-X or JTDX. All three stay installed so they can be
# compared on the real panel (DESIGN.md §3 is a decision that is not yet made).

source "$(dirname "$0")/lib.sh"
need_sudo

# Upstream publishes NO git tags — only 'main'. So we pin a commit for
# reproducibility. Bump deliberately, not incidentally.
# 0eb2846 == v2.76.6-era main, read 2026-08-31.
MSHV_REF="${MSHV_REF:-0eb284619b03256341646a298af619cc588f9c61}"
MSHV_DIR="$BUILD_ROOT/MSHV"

# aarch64. Upstream ships several ARM .pro files:
#   MSHV_armv7l.pro    - 32-bit ARM
#   MSHV_ARM_PI.pro    - Raspberry Pi, 32-bit (armhf Pi OS)
#   MSHV_Slarm64_PI.pro - Raspberry Pi, 64-bit  <-- this machine
# Confirmed: this Pi is aarch64 and RPi OS trixie is 64-bit.
MSHV_PRO="${MSHV_PRO:-MSHV_Slarm64_PI.pro}"

[ "$(uname -m)" = "aarch64" ] || warn "Not aarch64 ($(uname -m)) — MSHV_PRO=$MSHV_PRO may be wrong."

fetch_repo https://github.com/LZ2HV/MSHV.git "$MSHV_DIR" "$MSHV_REF"
cd "$MSHV_DIR"

# --- Select Qt5 -------------------------------------------------------------
# README_HOW_TO_COMPILE.txt: src/config.h carries a manual toolkit switch, and
# it may default to Qt4. Qt4 does not exist in trixie, so this must be Qt5.
# Edit in place, idempotently.
if grep -qE '^\s*#define\s+MSHV_QT4' src/config.h 2>/dev/null; then
    log "config.h: switching MSHV_QT4 -> MSHV_QT5"
    sed -i 's|^\s*#define\s\+MSHV_QT4|//#define MSHV_QT4|' src/config.h
fi
if grep -qE '^\s*//\s*#define\s+MSHV_QT5' src/config.h 2>/dev/null; then
    sed -i 's|^\s*//\s*#define\s\+MSHV_QT5|#define MSHV_QT5|' src/config.h
fi
grep -qE '^\s*#define\s+MSHV_QT5' src/config.h \
    || warn "Could not confirm MSHV_QT5 is set in src/config.h — check it by hand."

# --- Replace the bundled static fftw with Debian's ---------------------------
# THE BUILD FAILS WITHOUT THIS. The .pro ships a PREBUILT STATIC archive:
#   LIBS = -lasound src/Hv_Lib_fftw/lin_arm/libfftw3_slarm64_pi.a -lpulse-simple -lpulse
# That archive was compiled WITHOUT -fPIC, and Debian builds PIE executables by
# default, so ld refuses it:
#   relocation R_AARCH64_ADR_PREL_PG_HI21 against symbol `stdout@@GLIBC_2.17'
#   which may bind externally can not be used when making a shared object
#
# The obvious fix is -no-pie. Substituting Debian's shared fftw is better: it
# KEEPS PIE hardening, and the library gets security updates instead of being
# frozen in a vendored .a from an unknown toolchain.
#
# The archive provides double-precision fftw_* (541 symbols). MSHV also
# references a few fftwf_* but they resolve to dead code — the resulting binary
# links only libfftw3.so.3. The single/threads variants are listed anyway;
# --as-needed drops what is unused.
#
# (The .pro's -lasound is a plain -l, not a hardcoded path, so the libasound fix
# upstream's README describes for the x86 .pro files does NOT apply here.)
apt_install libfftw3-dev

if grep -q 'libfftw3_slarm64_pi\.a' "$MSHV_PRO"; then
    cp -n "$MSHV_PRO" "$MSHV_PRO.orig"
    sed -i 's|src/Hv_Lib_fftw/lin_arm/libfftw3_slarm64_pi\.a|-lfftw3 -lfftw3f -lfftw3_threads -lfftw3f_threads|' "$MSHV_PRO"
    log "patched $MSHV_PRO to link the system fftw"
fi
grep -n '^LIBS' "$MSHV_PRO" | sed 's/^/    /'

# --- Build ------------------------------------------------------------------
log "Building MSHV with $MSHV_PRO"
qmake -qt=5 "$MSHV_PRO"
thermal_check
make -j"$(build_jobs)"

# Upstream drops the binary in ./bin or the build dir depending on the .pro.
BIN="$(find . -maxdepth 3 -type f -name 'MSHV*' -perm -u+x ! -name '*.pro' ! -name '*.o' 2>/dev/null | head -1)"
[ -n "$BIN" ] || die "Build produced no MSHV binary — check make output above."

log "Installing MSHV from $BIN"
sudo install -Dm755 "$BIN" /usr/local/bin/mshv

# A .desktop entry, so it shows up in fuzzel next to wsjtx and jtdx.
# StartupWMClass matters: niri matches Xwayland windows on WM_CLASS, and the
# window rules in config/niri/config.kdl key off it.
sudo install -Dm644 /dev/stdin /usr/share/applications/mshv.desktop <<'DESKTOP'
[Desktop Entry]
Type=Application
Name=MSHV
GenericName=Weak-signal digital modes
Comment=FT8/FT4/Q65/MSK144/JT65 with an integrated waterfall (Ctrl+W)
Exec=/usr/local/bin/mshv
Terminal=false
Categories=HamRadio;Network;
Keywords=ham;radio;ft8;ft4;q65;msk144;jt65;
StartupWMClass=MSHV
DESKTOP

log "MSHV installed as /usr/local/bin/mshv"
warn "UNVERIFIED: the StartupWMClass above is a guess. On first launch run"
warn "  niri msg windows"
warn "and correct both it and the MSHV window rule in config/niri/config.kdl."
