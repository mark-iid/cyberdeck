#!/usr/bin/env bash
# Post-reboot validation against the 2026-08-31 baseline in docs/INVENTORY.md.
#
# Run this after rebooting into kernel 6.18.39. The point is to catch a
# regression BEFORE building a desktop on top of it — debugging a compositor
# and a kernel regression at the same time is not a thing to sign up for.
#
# See DESIGN.md §1: raspberrypi/linux#7381 reports random hard freezes on 6.18
# (Pi 4/400, not confirmed on Pi 5). linux-image-6.12.62 is still installed if
# a rollback is needed.

pass=0; fail=0
ck() { # ck <label> <expected-substring> <actual>
    if printf '%s' "$3" | grep -qF "$2"; then
        printf '  \033[1;32mOK  \033[0m %-22s %s\n' "$1" "$3"; pass=$((pass+1))
    else
        printf '  \033[1;31mFAIL\033[0m %-22s got:%s want:*%s*\n' "$1" "$3" "$2"; fail=$((fail+1))
    fi
}

echo "=== Kernel ==="
ck "running kernel" "6.18.39" "$(uname -r)"
ck "arch"           "aarch64"  "$(uname -m)"
printf '       uptime: %s\n' "$(uptime -p)"

echo "=== Storage (NVMe root is the reason we did not go Fedora) ==="
ck "root device" "nvme0n1p2" "$(findmnt -no SOURCE /)"
printf '       %s\n' "$(df -h / | tail -1)"

echo "=== Display ==="
ck "HDMI-A-1"  "connected" "$(cat /sys/class/drm/card*-HDMI-A-1/status 2>/dev/null | head -1)"
ck "mode"      "1280x800"  "$(head -1 /sys/class/drm/card*-HDMI-A-1/modes 2>/dev/null)"

echo "=== GPU / DRM (niri needs this path) ==="
drv="$(for d in /sys/class/drm/card[0-9]/device/uevent; do grep -h ^DRIVER= "$d" 2>/dev/null; done | sort -u | tr '\n' ' ')"
ck "drm driver" "vc4" "$drv"
ck "render node" "renderD128" "$(ls /sys/class/drm/ | grep renderD | head -1)"

echo "=== Input ==="
ck "touchscreen" "TSTP MTouch" "$(grep -m1 'TSTP MTouch' /proc/bus/input/devices | sed 's/.*Name="//;s/"//')"
printf '       keyboard: %s\n' "$(ls /dev/input/by-id/ 2>/dev/null | grep -c kbd) kbd interface(s)"

echo "=== Audio ==="
printf '       %s\n' "$(aplay -l 2>/dev/null | grep -c '^card') playback card(s): $(aplay -l 2>/dev/null | grep '^card' | sed 's/:.*//' | tr '\n' ' ')"
cap="$(arecord -l 2>/dev/null | grep -c '^card')"
if [ "$cap" -eq 0 ]; then
    printf '       \033[1;33mNOTE\033[0m  no capture device — expected unless the radio interface is plugged in\n'
else
    printf '       %s capture card(s) present\n' "$cap"
fi

echo "=== Session ==="
ck "display-manager" "active" "$(systemctl is-active lightdm 2>/dev/null)"
printf '       sessions: %s\n' "$(ls /usr/share/wayland-sessions/ 2>/dev/null | tr '\n' ' ')"

echo "=== Tooling ==="
printf '       claude:  %s\n' "$(claude --version 2>/dev/null || echo '<not installed>')"
printf '       niri:    %s\n' "$(niri --version 2>/dev/null || echo '<not built yet — expected>')"

echo
echo "=== Failed units ==="
systemctl --failed --no-legend --no-pager | head -10 || true

echo
printf 'Result: \033[1;32m%d passed\033[0m, \033[1;31m%d failed\033[0m\n' "$pass" "$fail"
[ "$fail" -eq 0 ] || echo "Rollback: linux-image-6.12.62+rpt-rpi-2712 is still installed."
exit "$( [ "$fail" -eq 0 ] && echo 0 || echo 1 )"
