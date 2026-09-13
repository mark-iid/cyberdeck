#!/usr/bin/env bash
# Assert the boot configuration is UNAMBIGUOUS. Run after any disk change,
# any clone/backup operation, and before trusting a kernel update.
#
# WHY THIS EXISTS (DESIGN §5): a 238GB SD card was found to be a byte-identical
# clone of the NVMe — same UUIDs AND same PARTUUIDs on both partitions. Since
# /etc/fstab mounts /boot/firmware by PARTUUID and the kernel takes
# root=PARTUUID, BOTH selectors matched two devices and the winner changed
# between boots. Observed flipping across three reboots.
#
# Consequences that actually happened / were one coin-flip away:
#   - A config.txt edit landed on the SD while the firmware read the NVMe's,
#     so the change silently did nothing.
#   - The two boot partitions diverged: SD kernel 2026-02-19 vs NVMe 6.18.39.
#   - root=PARTUUID could have resolved to the SD's nine-month-old clone,
#     making it look like months of work had vanished.
#
# The SD was removed 2026-08-31. This script is the tripwire.

source "$(dirname "$0")/lib.sh"

# blkid lives in /usr/sbin and needs root to probe devices. A non-login shell
# does not have sbin on PATH, which made an earlier version of this script die
# with exit 127 before printing a single check.
PATH="/usr/sbin:/sbin:$PATH"
command -v blkid >/dev/null 2>&1 || die "blkid not found (expected in /usr/sbin)"
BLKID="blkid"
[ "$(id -u)" -eq 0 ] || BLKID="sudo blkid"
need_sudo

fail=0
ok()   { printf '  \033[1;32mOK  \033[0m %s\n' "$*"; }
bad()  { printf '  \033[1;31mFAIL\033[0m %s\n' "$*"; fail=$((fail+1)); }
note() { printf '       %s\n' "$*"; }

echo "=== 1. Every fstab/cmdline selector must match exactly ONE device ==="
selectors="$(grep -hoE '(PARTUUID|UUID)=[0-9a-fA-F-]+' /etc/fstab /proc/cmdline 2>/dev/null | sort -u)"
[ -n "$selectors" ] || bad "could not read any selectors from /etc/fstab or /proc/cmdline"
for sel in $selectors; do
    key="${sel%%=*}"; val="${sel#*=}"
    case "$key" in
        PARTUUID) n="$($BLKID -t "PARTUUID=$val" -o device 2>/dev/null | wc -l)" ;;
        UUID)     n="$($BLKID -t "UUID=$val"     -o device 2>/dev/null | wc -l)" ;;
    esac
    if [ "$n" -eq 1 ]; then
        ok "$key=$val -> $($BLKID -t "$key=$val" -o device 2>/dev/null | head -1)"
    elif [ "$n" -eq 0 ]; then
        bad "$key=$val matches NO device"
    else
        bad "$key=$val matches $n devices — AMBIGUOUS. This is the DESIGN §5 bug."
        $BLKID -t "$key=$val" -o device 2>/dev/null | sed 's/^/         /'
    fi
done

echo "=== 2. /boot/firmware and / must live on the SAME physical disk ==="
bootdev="$(findmnt -no SOURCE /boot/firmware 2>/dev/null)"
rootdev="$(findmnt -no SOURCE / 2>/dev/null)"
bootdisk="$(lsblk -no PKNAME "$bootdev" 2>/dev/null)"
rootdisk="$(lsblk -no PKNAME "$rootdev" 2>/dev/null)"
note "boot=$bootdev (disk $bootdisk)   root=$rootdev (disk $rootdisk)"
if [ -n "$bootdisk" ] && [ "$bootdisk" = "$rootdisk" ]; then
    ok "both on /dev/$bootdisk"
else
    bad "boot and root are on DIFFERENT disks — the firmware may read a config.txt
         and kernel that the running system never writes to."
fi

echo "=== 3. The mounted boot partition must hold the RUNNING kernel ==="
# Compare the boot-partition image byte-for-byte against the vmlinuz shipped by
# the installed linux-image package for the RUNNING kernel. That is exact.
#
# An earlier version grepped the image with `strings` for `uname -r` and cried
# wolf: kernel_2712.img is GZIP COMPRESSED, so the version string is never in
# plaintext. It reported a divergence on a perfectly correct system.
running="$(uname -r)"
img=/boot/firmware/kernel_2712.img
[ -f "$img" ] || img=/boot/firmware/kernel8.img
pkgimg="/boot/vmlinuz-$running"

if [ ! -f "$img" ]; then
    bad "no kernel image found under /boot/firmware"
elif [ ! -f "$pkgimg" ]; then
    note "SKIP: $pkgimg absent — cannot compare (running a kernel with no package?)"
elif [ "$(md5sum <"$img")" = "$(md5sum <"$pkgimg")" ]; then
    ok "$(basename "$img") is byte-identical to $(basename "$pkgimg")"
else
    bad "$(basename "$img") DIFFERS from $(basename "$pkgimg").
         The firmware boots a different partition than the one mounted, or a
         kernel update was written somewhere the firmware never reads."
    note "boot image: $(stat -c '%y %s bytes' "$img" | cut -d. -f1)"
    note "package:    $(stat -c '%y %s bytes' "$pkgimg" | cut -d. -f1)"
fi

echo "=== 4. No unexpected 'bootfs'/'rootfs' clones attached ==="
for lbl in bootfs rootfs; do
    n="$($BLKID -t "LABEL=$lbl" -o device 2>/dev/null | wc -l)"
    if [ "$n" -le 1 ]; then
        ok "exactly $n device labelled '$lbl'"
    else
        bad "$n devices labelled '$lbl' — a clone is attached:"
        $BLKID -t "LABEL=$lbl" -o device 2>/dev/null | sed 's/^/         /'
        note "If this is a deliberate backup, give it fresh identities:"
        note "  fdisk /dev/<disk>  -> x -> i   (new disk id, changes PARTUUIDs)"
        note "  tune2fs -U random /dev/<rootpart>"
        note "then fix that clone's own fstab and cmdline.txt."
    fi
done

echo
if [ "$fail" -eq 0 ]; then
    printf '\033[1;32mBoot configuration is unambiguous.\033[0m\n'
else
    printf '\033[1;31m%d problem(s) found — see DESIGN.md §7.\033[0m\n' "$fail"
fi
exit "$fail"
