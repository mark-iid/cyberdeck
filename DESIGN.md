# Design notes

Why this machine is set up the way it is, written so the reasoning survives being
forgotten. Where a decision came from a measurement, the measurement is here too, an
unsourced number is a number nobody can re-check.

Sections run in reading order, not the order things were discovered. §4 is the long one
(thermal dominated this build) and §4 is also where the useful negative results live.
The enclosure is a separate document: [docs/CASE.md](docs/CASE.md).

---

## §1 Why Raspberry Pi OS and not Fedora

The obvious move was to reuse my existing BlueBuild/bootc images on Fedora Atomic. I
looked at it and rejected it, because Fedora is disqualified on this hardware four
separate ways:

- NVMe root isn't supported on the Pi 5. Fedora's ARM lead: *"PCIe for HATs via the
  add-on HATs and related products including NVME. Not currently for boot/root."*
  The F44 release notes still list NVMe under not-working. This deck's root is
  `/dev/nvme0n1p2` (468 G, 161 G used) and `config.txt` carries a deliberate
  `dtparam=nvme` + `dtparam=pciex1_gen=3`. Fedora would demote the machine to the
  microSD slot.
- Audio doesn't work on Fedora/Pi 5. This is a ham deck. Audio *is* the payload.
- Thermal management doesn't work, which is a bad property in an enclosure.
- No Atomic image exists for Pi 5 at all. F44 ships Minimal, KDE and GNOME only. So
  "Fedora Sway Atomic on a Pi 5" isn't a thing you can flash, which also removes the base
  my reference repos would have needed.

On top of which the Pi 5 kernel there is a non-vanilla COPR kernel maintained in spare
time. That's the wrong dependency for a machine whose entire purpose is working when
nothing else does.

What actually ports from the old repos is the `config.kdl`, not the machinery. The
Containerfile/recipes/modules apparatus is meaningless on a mutable Debian system, so
this repo is a different shape: provisioning scripts plus config, not an image build.

### OS currency (checked 2026-08-31)

Raspberry Pi OS trixie (Debian 13) *is* current, latest release 6.2, 2026-04-14.
Debian 14 "forky" is still in development, and `apt list --upgradable` returns nothing.
There's no newer OS to move to.

The one live question is the kernel. The box runs 6.12.62 with 6.18.39 staged.
There's an open upstream regression (random hard freezes on 6.18,
raspberrypi/linux#7381) reported on Pi 4/400 and not confirmed on Pi 5, with
reporters unable to reproduce on 6.12.75. `linux-image-6.12.62` and `6.12.47` are both
still installed, so rollback works. Validate 6.18.39 *before* building a desktop on top
of it, debugging a compositor and a kernel regression simultaneously is not something
to sign up for.

---

## §2 The screen

    HDMI-A-1   RTK CX101   1280x800@60   220x130mm   ~148 DPI

Scale 1 is forced, not chosen, and the proof was already on the disk. Decoding this
machine's own `~/.config/WSJT-X.ini` (Qt `saveGeometry` blobs, dated 2026-03-05):

| Window | Saved size |
|---|---|
| `[MainWindow]` | 880 × 685 |
| `[WideGraph]` waterfall | 938 × 337 |
| `[Configuration]` settings dialog | 1280 × 811 |

At scale 1.25 the logical desktop is 1024 × 640, and the WSJT-X main window alone wants
685 px of height, it wouldn't fit on an *empty* screen. That ends the scale discussion
with arithmetic instead of taste. Legibility comes back through font sizes in
`foot`/`waybar`, not compositor scale.

Everything else in `config/niri/config.kdl` follows from 1280 × 800:

- `gaps 4`, down from the 8 I use elsewhere.
- Column presets 0.5 / 0.75 / 1.0 (up from 0.33/0.5/0.66) and a
  `default-column-width` of 1.0. On this panel the normal case is one app at a time;
  a 0.33 column is 427 px and useful to nothing here.
- waybar height 24, plus `Mod+Shift+B` to hide it outright. Those 30 px are the
  difference between the WSJT-X main window fitting and not.
- No `focus-follows-mouse`. With a touchscreen the pointer teleports to wherever you
  last touched and then *stays* there, so focus-follows-mouse would hand keyboard focus
  to whatever happens to sit under a stale point. Keyboard focus only.
- `cursor { hide-when-typing }`, because the pointer is a touch artefact.

### The hotkey overlay is the manual

No mouse, and `prefer-no-csd` means no titlebars, so window management is 100% keyboard.
`Mod+Shift+Slash` is therefore the deck's actual documentation.

Rule for `config.kdl`: no `spawn` bind without a `hotkey-overlay-title`. Action binds
describe themselves in the overlay; spawns show up as a bare command line unless titled.

---

## §3 FT8 software

Settled on measurements from the real panel rather than inference. `niri msg windows`
with all three running at scale 1 on the 1280 × 800 output:

| | Windows | Main | Waterfall | Settings dialog |
|---|---|---|---|---|
| WSJT-X 2.7.0 | 2 | 1272 × 768 | separate, 1272 × 200 | 1280 × 813 |
| JTDX 2.2.159 | 2 | 1272 × 768 | separate |, |
| MSHV 2.76.7 | 1 | 1272 × 768 | inside the window (Ctrl+W) |, |

MSHV opens as a single window. WSJT-X and JTDX each need a second floating window placed
by hand-written rules, on a panel with roughly 776 px of usable height. WSJT-X's Settings
dialog measured 1280 × 813, taller than the screen, the `.ini` decode predicted 811, so
the prediction was sound and the problem is real.

What MSHV doesn't give up, checked against the built binary rather than assumed
(because "the niche fork must be worse at integration" is the obvious prior, and here
it's wrong):

- UDP port 2237, the WSJT-X protocol port. QLog, GridTracker and JTAlert all work
  against it.
- PSK Reporter built in (`report.pskreporter.info`).
- ADIF export all/selected, plus direct ClubLog, eQSL and QRZ upload.

So the choice costs no ecosystem integration and buys one window instead of two on a
screen that can't afford two.

WSJT-X stays installed as the reference implementation and the insurance: it's
apt-maintained, new modes land there first, and its window rules are verified working.
JTDX is redundant, it's a WSJT-X fork, so it duplicates the fallback rather than
adding one.

---

## §4 Thermal

Solved. Active cooler under the NVMe shield, fitted 2026-09-02. Case closed, which
no earlier figure in this file could claim:

    Baseline: 54.3 C  throttled=0x0  arm=1700 MHz
      t=30s   67.5 C   0x0   2400 MHz
      t=60s   69.2 C   0x0   2400 MHz
      t=120s  72.5 C   0x0   2400 MHz
      t=180s  74.1 C   0x0   2400 MHz
      t=240s  75.7 C   0x0   2400 MHz
      t=300s  76.3 C   0x0   2400 MHz

Full 2400 MHz sustained for five minutes with zero throttle bits, plateauing around
76 °C. The last four samples oscillate 75.7–76.8, which is equilibrium rather than a
climb, that distinction is the whole measurement.

| Configuration | Sustained | Temp | Throttled |
|---|---|---|---|
| Closed, no cooler | 1500 MHz | 80.1 °C at idle | permanently |
| Open case + external fan | 1769 MHz | 82.9–86.2 °C | yes |
| `arm_freq=1800` capped, no fan | 1503 MHz | 84.0–86.2 °C | yes |
| Closed + Active Cooler | 2400 MHz | 67.5–76.8 °C | never |

+60% sustained clock over the original baseline, and the machine reaches its rated
speed for the first time in anything measured here. `/sys/class/thermal/cooling_device0`
went from *absent* to `type=pwm-fan cur=1 max=4`, and it ramps 3602 rpm at idle to
9950 rpm (state 4/4) under load. The trip points at 50/60/67.5/75 °C that had been inert
since the beginning are doing their job.

75 °C is not a warning, and this is worth stating because it looks alarming next to
the old numbers: those trip points are fan speed steps, not throttle points. Hitting
75 means the fan goes to maximum, which is the system working correctly. Throttling
begins at the 85 °C soft limit; critical is 110 °C.

The deck used to sit at 80 °C *idle*. It now runs cooler under full four-core load than
it used to at rest, at 60% higher clock.

### What was wrong

Found 2026-08-31, and it was hardware, not software:

| Measurement | Value |
|---|---|
| Idle temperature | 88–90 °C (load ~1.1, nothing running but the desktop) |
| Under 20 s of 4-core load | 93.3 °C |
| `vcgencmd get_throttled` | `0x60006` |
| ARM clock, actual | 1.0 GHz |
| ARM clock, configured max | 2.4 GHz |
| `/sys/class/thermal/cooling_device*` | empty, no fan |

`0x60006` decodes to: frequency capped now (bit 1), throttled now (bit 2), and both have
occurred (bits 17, 18). The under-voltage bits (`0x1` / `0x10000`) are clear, so this
was purely thermal and not a supply problem. The deck was permanently running at ~42% of
its rated clock.

The device tree *did* expose a `cooling_fan` node all along (pwms, rpm-regmap,
cooling-levels) and the thermal zone had its trip points. All inert, because nothing was
plugged into the fan header. `config.txt` also sets `arm_boost=1`, which is to say it was
boosting a Pi with no cooling.

What's in the case, photographed rather than guessed: a Pi 5 with passive finned
heatsinks already on the SoC and RAM, a SupTronics RPi5 PIP-NVMe Shield X1001 V1.1
on the PCIe ribbon sitting *directly above the SoC* with a KingSpec M.2 2280 on top, a
display driver board alongside, and an empty 4-pin fan header.

I initially wrote that there was no vertical room for an Active Cooler under that shield.
That was inferred from a photograph and it's wrong. Geekworm's own X1001 docs say it
"supports installation of official Pi 5 active cooler" and describe the board as
"extremely thin ... gives ample room for cooling the Pi underneath". It's designed as a
thin lid *so that* a cooler fits below it, and they sell the X1001 + H505 as a bundle. So
no new NVMe board was needed; the aftermarket passive heatsinks just had to come off
first.

### Three negative results

1. Capping the clock does not help. The hypothesis was that capping `arm_freq` would
trade an unreachable peak for a higher *sustained* clock. Two 5-minute 4-core runs, same
ambient:

| Setting | Sustained mean | Range | Temp |
|---|---|---|---|
| Stock `arm_freq=2400`, `arm_boost=1` | 1500 MHz | flat 1500 | 84.5–87.3 °C |
| Capped `arm_freq=1800`, `arm_boost=0` | 1503 MHz | 1350–1711, oscillating | 84.0–86.2 °C |

Identical within noise, and the capped run dips to 1350, *below* the stock run's floor.
Why it failed: this SoC is thermally limited, not ceiling-limited. It settles at
whatever clock dissipates the sustainable wattage at ~85 °C, and lowering the ceiling
doesn't move that equilibrium, the governor was already finding the right clock. Capping
only makes its stepping noisier. Stock config also won in the fan case (1769 vs
~1600 MHz), which confirms it independently.

Don't cap `arm_freq` on this board.

2. No number recorded against an open case describes how this deck runs. The
50–63 °C idle figures I was pleased about were measured with the lid off. It's a display
case; the screen is the point; it runs closed.

| State | Idle |
|---|---|
| Closed, no fan, heat-soaked | 87–90 °C |
| Closed + external fan (the real operating state) | 80.1 °C |
| Open + external fan | 50–63 °C |

An external fan blowing at a closed box buys about 8 °C. Not nothing, but nowhere near
the 30 °C the open-case figures implied. The consequence wasn't a change of plan so much
as a hardening of it: the case is the thermal boundary, so the cooling has to be inside
it.

3. The synthetic load test understates real load. `70-thermal-tune.sh measure` runs
four `while :; do :; done` spinners, which is pure scalar ALU with the whole working set
in L1. It draws far less power than real work:

| Load | Peak temp | Throttle flags |
|---|---|---|
| Synthetic busy-loop | 76.8 °C | `0x0`, none |
| llama.cpp compile, `-j4` | ~85 °C | `0x80000`, soft limit *occurred* |
| 7B Q4_K_M inference | 82.3 °C | `0xe0008`, soft limit active now |

Bit 3 (`0x8`) means the SoC was sitting at the 85 °C soft limit while generating. The
clock only eased from 2400 to 2366, so it's mild and the work completes, but it's not the
"76.8 °C, zero throttling" headline. LLM inference saturates memory bandwidth and hammers
NEON/SIMD; a scalar spin loop touches neither, and a compile sits in between.

So the headline figure is a floor, not a ceiling. The honest summary: with the active
cooler this deck sustains full clock under synthetic load and brushes the soft limit under
genuinely heavy real work, without ever throttling hard. Nothing to fix, recorded so the
number isn't trusted beyond what it measures.

### Fan wiring

The Pi 5 fan header is 4-pin JST-SH 1.0 mm:

| Pin | Signal |
|---|---|
| 1 | +5 V (red), marked with a triangle |
| 2 | PWM (blue) |
| 3 | GND (black) |
| 4 | Tach (yellow) |

5 V and GND are pins 1 and 3, which are not adjacent. A 2-pin plug pushed into this
header lands on 1+2 (5 V + PWM) or 3+4 (GND + tach), never both rails. So a 2-pin fan
cannot use this connector, and forcing a mismatched JST-SH plug damages it.

The 2-pin connector next to the USB-C input is `J5`/`BATT`, the RTC battery. It's an
*input*, not a power source, a constant-current 3 mA charger for an ML2020 cell, with
charging disabled by default. A 30 mm fan wants 100–200 mA, about 100× more. Don't put a
fan on it.

For a 2-pin 5 V fan the answer is GPIO header pin 4 (+5 V) and pin 6 (GND): adjacent,
exposed, no adapter, always-on at full speed. If you later add an NPN (S8050) or a
logic-level MOSFET switching the fan's ground off a GPIO, then

    dtoverlay=gpio-fan,gpiopin=12,temp=60000

registers it as a real `cooling_device` with automatic on/off. Write that to the *NVMe's*
`config.txt`, see §5 for why that sentence needs saying.

### Consequences elsewhere

- `build_jobs()` in `bin/lib.sh` defaults to all cores. `JOBS=2` restores the
  conservative half-cores behaviour if the cooler is ever removed.
- `bin/60-local-ai.sh` is unblocked. Inference was previously refused because one short
  run hit 96.6 °C.
- `config/waybar/config` sets the temperature module's `critical-threshold` to 75, which
  now means "fan at maximum" rather than "permanently HOT".
- The 100 °C guard stays as a tripwire for a failed or obstructed fan, not as an
  expected condition.

---

## §5 Boot: duplicate UUIDs, and the bootloader EEPROM

Found 2026-08-31, and it's a data-integrity hazard rather than a performance one.

The 238 GB SD card was a full clone of the NVMe with byte-identical UUIDs and PARTUUIDs
on both partitions:

| | NVMe | SD |
|---|---|---|
| boot | PARTUUID `14191c5d-01`, UUID `F587-071F`, LABEL `bootfs` | identical |
| root | PARTUUID `14191c5d-02`, UUID `d6944274-…`, LABEL `rootfs` | identical |

`/etc/fstab` mounts `/boot/firmware` by `PARTUUID=14191c5d-01` and the kernel cmdline
uses `root=PARTUUID=14191c5d-02`, so both selectors matched two devices. Whichever
enumerated first won, and it varied per boot. I watched it flip from `nvme0n1p1` to
`mmcblk0p1` and back across three reboots. The two boot partitions had already diverged:
the SD's `kernel_2712.img` was from 2026-02-19, the NVMe's from 2026-08-31.

How it bit me: `bin/70-thermal-tune.sh set 1800` wrote to `/boot/firmware`, which on
that particular boot was the *SD*. The firmware boots from NVMe (`BOOT_ORDER=0xf146`), so
it read the NVMe's `config.txt` and the clock cap silently did nothing. The first "capped"
measurement was invalid, and I didn't know that until I went looking for something else.

The worse failure mode is `root=`. If a boot resolved `14191c5d-02` to `mmcblk0p2`,
the machine would come up on the 2025-12-04 clone and appear to have lost nine months of
work. Never observed, and nothing prevented it.

### Pulling the card

Verified it held nothing unique first. ZIM lists identical (the apparent 43-vs-42 was a
counting artefact, one non-`.zim` file in the directory). The only files present on SD
and not NVMe were `ai.sh`/`codeai.sh`, byte-identical copies of the `.py` versions with
the wrong extension. SD rootfs last modified 2025-12-04, SD kernel 2026-02-19, both stale.

Post-removal, verified by `bin/80-check-boot-integrity.sh`: each PARTUUID resolves to
exactly one device, `/boot/firmware` and `/` are both on `nvme0n1`, `kernel_2712.img` is
byte-identical to the installed `vcmlinuz`, and there's one `bootfs` and one `rootfs`.
No `fstab` change was needed, removing the duplicate made both selectors unambiguous
on their own.

Side benefit: idle temperature fell to 55.4 °C. Some of that was the open case, but the SD
carrier board sat in the airflow path too.

If a card ever has to stay physically installed, break the collision in software instead:
`fdisk /dev/mmcblk0` (`x` → `i`) for the disk identifier, `tune2fs -U random` on the
rootfs, re-create the FAT UUID, then fix that clone's own `fstab`/`cmdline.txt` so it
stays independently bootable. Removal is far simpler.

### A check that raised false alarms

`80-check-boot-integrity.sh` check 3 originally grepped the boot image with `strings` for
`uname -r`, and reported a divergence on a perfectly healthy system. `kernel_2712.img` is
gzip compressed, so the version string is never there in plaintext.

It now compares the image byte-for-byte against `/boot/vmlinuz-$(uname -r)` from the
installed `linux-image` package. Exact, and no decompression needed. A check that
produces false alarms is worse than no check, because it trains you to ignore it.

### The bootloader EEPROM

Done 2026-09-28, as its own step after a validated kernel reboot, because a bootloader
failure on a box that boots from NVMe is the one failure with no software recovery path.
2025-05-08 → 2026-09-25, a sixteen-month jump.

What matters is the config, not the image. The EEPROM holds `BOOT_ORDER=0xf146` — read
right to left, that's NVMe, then USB, then SD, then retry — and losing it means a machine
that comes up looking for an SD card that isn't there. Capture it before flashing:

    sudo rpi-eeprom-config > eeprom-config.pre-update.txt

`rpi-eeprom-update -a` does preserve it, and did here, but "it usually preserves it" is
not a recovery plan. Diff it afterwards rather than eyeballing it.

Two things worth knowing about the Pi 5 specifically:

- It flashes **immediately** over SPI via `flashrom`, and reports `VERIFY: SUCCESS`. It
  does not stage a `pieeprom.upd` for the next boot the way earlier models did, so there
  is no window in which you can inspect what's about to be written.
- `rpi-eeprom-update` still says "UPDATE AVAILABLE" after a successful flash, because it
  compares against the *running* bootloader. That is not a failed update. It reads "up to
  date" after the reboot.

If it ever does go wrong, the recovery is Raspberry Pi Imager's bootloader rescue SD
image — which is the one situation where the SD slot this section pulled a card out of
earns its keep.

---

## §6 XDG autostart collisions

Symptom on first boot into niri: two bars stacked on an 800 px panel.

`niri-session` starts a systemd user session that pulls in
`xdg-desktop-autostart.target`. Raspberry Pi OS populates `/etc/xdg/autostart` for its
labwc desktop, so those entries run inside niri too, and anything `config.kdl` also
spawns gets started twice. Confirmed by cgroup rather than guesswork:

    app-niri-waybar-1385.scope    <- spawn-at-startup in config.kdl
    waybar.service                <- Debian's systemd user unit

waybar.service ships enabled, and enabled GLOBALLY. `systemctl --user disable` isn't
enough, and it tells you so:

    The following unit files have been enabled in global scope. This means they
    will still be started automatically after a successful disablement in user
    scope: waybar.service

The symlink is at `/etc/systemd/user/graphical-session.target.wants/waybar.service` and
needs `sudo systemctl --global disable waybar.service`.

Second collision: two polkit agents. `config.kdl` spawned polkit-mate while
`/etc/xdg/autostart/lxpolkit.desktop` already provided one. My older Fedora config spawns
an agent because Fedora Sway Atomic has no such autostart, and that premise doesn't hold
here. Spawn removed, lxpolkit left to do its job.

`nm-applet` is deliberately *not* removed despite `/etc/xdg/autostart/nm-applet.desktop`
existing: that entry launches the plain applet, which uses the dead XEmbed tray, while
the config spawns `--indicator` for the StatusNotifierItem path waybar understands.
Verified exactly one instance runs.

### Two ssh traps

`pkill -f` over ssh is actively dangerous. `ssh host 'pkill -f jtdxjt9'` matched the
ssh-spawned shell's *own* command line and killed the session mid-command. Use `pkill -x`,
or match a pattern that can't appear in the invoking command.

Counting instances with `pgrep -f <name>` over ssh lies for the same reason, the ssh
command line contains the pattern and matches itself. That inflated every count in my
first pass and briefly suggested six duplicates that didn't exist. Use `pgrep -x`, or read
the cgroup tree with `systemd-cgls --user-unit app.slice`.

The reload action is `load-config-file`. `niri msg action reload-config` doesn't
exist; niri suggests the right one. Over ssh it also needs `NIRI_SOCKET`, which is
`/run/user/1000/niri.<display>.<pid>.sock`.

---

## §7 Reading the library without a mouse

This deck is two things at once: a doomsday device and a radio go-box companion.
That's why the ham stack is first-class rather than incidental, why the FT8 decision in §3
got measured rather than guessed, and why offline reference content is treated as payload.

### kiwix-desktop is only *partly* keyboard-navigable

Touchscreen and keyboard, no mouse. kiwix-desktop's application chrome is fine:
`Ctrl+T`, `Ctrl+1-9`, `Ctrl+Tab`, `F6`/`Ctrl+L` for search, `Ctrl+B` for bookmarks. Its
*content area* is a QtWebEngine view, so following a link inside an article means
Tab-cycling through every link before it. On a Wikipedia page that's hundreds of
keystrokes for the one you want, and following links is the single most common thing
anyone does in an encyclopaedia.

### Serving the ZIMs instead

`bin/52-kiwix-serve.sh` installs `kiwix-tools` + `qutebrowser` and runs kiwix-serve on
:8080 against the *existing* kiwix-desktop `library.xml`, so one catalogue feeds both
front-ends.

qutebrowser has vim-style link hints: press `f`, every visible link gets a letter, type
it to follow. The most common action drops from O(links) keystrokes to two or three.
`j`/`k` scroll, `H`/`L` back and forward, `/` finds, `o` opens.

It also unifies the machine: one keyboard-driven browser reaches both the ZIM library
(:8080) and the local 7B model (:8081), which is why llama-server went on 8081 and 8080
was left alone.

kiwix-desktop stays installed. This is an addition.

### Auto-expiring notifications

mako shipped with no config, so notifications stayed on screen until dismissed, and on a
mouseless deck "dismiss" is a keybind reach for every "Volume 40%". `config/mako/config`
sets `default-timeout=5000` so transient popups fade on their own, with one deliberate
exception: `[urgency=critical]` keeps `default-timeout=0`, so a real thermal or power
warning stays until acknowledged. That's the one case where click-to-dismiss is correct.

(`libnotify-bin` provides `notify-send`, without which nothing can post a notification at
all. It's in `00-packages.sh`.)

### Offline content

- Radio data (`53-radio-data.sh`): 512 satellite TLEs, gpredict had *none* and
  couldn't track anything. Plus `cty.dat` rescued from the MSHV build tree to a stable
  path for the four loggers, and apt set to keep `.deb`s for offline repair.
- Maps (`54-maps.sh`): whole-US OSM extract (11.3 GB) plus mkgmap/osmium/gdal, so a
  Garmin `.img` for *any* region can be built offline; TIGER2025 shapefiles for ten
  southwestern-PA counties for Xastir; a prebuilt SW-PA Garmin map for QMapShack. Formats
  differ per viewer. QMapShack needs Garmin `.img` (not Mapsforge `.map`), Xastir
  needs shapefiles.
- Computing (`55-fetch-computing.sh`): 2026 StackExchange refreshes (the deck's were
  2023), full Python docs, the Arch wiki, and the entire ~231-file devdocs collection for
  ~0.57 GB. Best value-per-byte on the machine by a wide margin.

### Flipper Zero

`56-flipper.sh` installs qflipper and clones an existing collection onto the deck. It
deliberately downloads nothing from upstream, that would fork work already done. The gap
was that none of the reference material was *on the deck*, and a go-box can't manage the
device if the docs and the flashing tool live only on a workstation.

One transfer note worth keeping: move the repo as a git bundle, not by streaming
`.git` over ssh. The naive `tar .git | ssh` got cut off by a timeout mid-write and left a
"bad object HEAD". A bundle is a single integrity-checked file, so it either lands
complete or fails cleanly.

---

## §8 Traps

- Rust MSRV. trixie ships rustc 1.85; niri v26.04 needs 1.87. The build fails
  confusingly rather than cleanly, which is the only reason `10-build-niri.sh` installs
  rustup. xwayland-satellite v0.8.2 pins 1.85.0 exactly and needs no rustup.
- Wayland platform plugins are load-bearing for BOTH Qt generations. The config sets
  `QT_QPA_PLATFORM=wayland` globally, and a Qt app whose generation lacks its plugin
  doesn't fall back, it aborts with *"Could not find the Qt platform plugin
  \"wayland\""*. `qtwayland5` covers Qt5 (wsjtx, jtdx, MSHV, gqrx); `qt6-wayland` covers
  Qt6. I missed the second one initially because every Qt app on the deck happened to be
  Qt5, so the gap stayed invisible until qutebrowser (PyQt6) refused to launch. Both are
  installed unconditionally. Don't remove either.
- `policykit-1-gnome` doesn't exist in trixie (`Candidate: (none)`). The agent here is
  `mate-polkit` at `/usr/libexec/polkit-mate-authentication-agent-1`, already
  installed and already what labwc autostarts. "Correcting" it to a Debian-looking
  `/usr/lib/policykit-1-gnome/` path is wrong.
- Debian calls the notification daemon `mako-notifier`, but the binary is still
  `mako`. A config spawning `mako` is correct.
- MSHV's `src/config.h` has a manual Qt4/Qt5 switch that may default to Qt4, which
  doesn't exist in trixie. `30-build-mshv.sh` rewrites it. Its aarch64 `.pro` uses generic
  `-lasound`, so the hardcoded-libasound-path fix in upstream's README does not apply.
- MSHV won't link against its own bundled fftw. `MSHV_Slarm64_PI.pro` ships a prebuilt
  static `libfftw3_slarm64_pi.a` compiled without `-fPIC`, and Debian builds PIE
  executables by default, so ld refuses it outright:

      relocation R_AARCH64_ADR_PREL_PG_HI21 against symbol `stdout@@GLIBC_2.17'
      which may bind externally can not be used when making a shared object

  The obvious fix is `-no-pie`. Substituting Debian's shared fftw is better: it keeps
  PIE hardening *and* the library gets security updates, rather than being frozen in a
  vendored archive from an unknown toolchain. `30-build-mshv.sh` rewrites the `LIBS` line
  to `-lfftw3 -lfftw3f -lfftw3_threads -lfftw3f_threads` and keeps a `.orig` alongside.
  (The archive provided double-precision `fftw_*` only; MSHV references a handful of
  `fftwf_*` but those resolve to dead code, the linked binary pulls in only
  `libfftw3.so.3`.)
- Window rules fail silently. Every `app-id` in `config.kdl` is a guess until checked
  with `niri msg windows`.
- MSHV publishes no git tags, only `main`, so it's pinned by commit SHA.

---

## §9 GPS time and position

FT8 needs the clock accurate to well under a second, and off-grid there is no NTP to
get that from. The clock drifts, decodes stop, and nothing reports an error — a
waterfall full of nothing is the only symptom. [docs/CONTENT.md](docs/CONTENT.md) makes
the case; this section is the build.

Two tiers, and the first is not a lesser version of the second. A USB GPS plus `gpsd`
and `chrony` gets tens of milliseconds, which is comfortably inside what FT8 needs, and
it needs no wiring and carries no risk. Tier 2 — the receiver on the GPIO header, with
its 1PPS edge on a GPIO — buys microseconds instead. That is not better FT8, it is a
different class of clock. Fitted here because the hardware was already on the bench.

`bin/57-gps-time.sh install`, then reboot, then `bin/57-gps-time.sh check`.

### Parts

| Part | Notes |
|---|---|
| QRP Labs QLG2 GNSS receiver | E108-GN01 module (GK9501), NMEA 9600 8N1, 0.1 s 1PPS. Needs its logic level changed before it can touch a Pi — see below. |
| Active patch antenna, magnetic mount, 2 m coax | Supplied with the QLG2. The magnet is the ground plane as well as the mount, so it wants a ferrous surface, not a windowsill. |
| SMA bulkhead F–F | Right rail, ⌀6.7 drawn (docs/CASE.md §5). Same part as the left rail's, so no second coupon. |
| 4 × jumper wire, F–F | QLG2 4-pin header to the Pi GPIO header. |

### Wiring

Count the **outer** row of the Pi header — the even-numbered pins — from the left:

| Wire | QLG2 | Pi pin | Position | Function |
|---|---|---|---|---|
| 5V+ | +5V | 2 | 1st | |
| Gnd | Gnd | 6 | 3rd | |
| TXD | Serial data out | 10 | 5th | GPIO15 / RXD0 |
| 1pps | 1PPS | 12 | 6th | GPIO18 |

The Pi's TX is deliberately not wired. Nothing needs to talk to the QLG2, and leaving
it off means there is no direction in which a level mismatch can matter.

**Pin 14 is ground and it is the very next pin after 12.** Being one position out puts
the QLG2's 1PPS push-pull output into a dead short. That happened here. It is
recoverable — the short is on one output pin, and the Pi cannot be hurt by anything
tied to its own ground plane — but count twice: 10 is 5th, 12 is 6th, 14 is 7th.

### The QLG2 is a 5 V part until you change it

Its 1PPS and serial outputs are 5 V by default, for QRP Labs' own kits. A Pi GPIO is
3.3 V only. Cut the UPPER (5 V) trace on **JP2** (PPS level) and **JP5** (SER level) and
jumper each centre pad to its LOWER pad, which is 2.8 V straight off the GNSS module.

2.8 V is fine: the Pi's input-high threshold is about 0.7 × 3.3 = 2.31 V, so there is
roughly half a volt of margin.

Two things that make this easy to get wrong:

- **LOWER is the pad nearest the board edge.** The traces are on the underside, so
  flipping the board mirrors left and right — but not near-edge versus far-edge. Use the
  edge, not "up".
- **JP8's polarity is inverted.** On JP8 the UPPER position is the 2.8 V one. Do not
  pattern-match the three level jumpers onto each other.

Then meter the 4-pin header *before* connecting anything to the Pi. TxD and 1pps must
read ~2.8 V. If either reads 5 V, stop.

### Three Pi-5 traps, one of which fails silently

**`/dev/serial0` is not the header UART.** On a Pi 5 it symlinks to `ttyAMA10`, the
separate debug connector. A config naming `serial0` reads a port with nothing on it.
Use `/dev/ttyAMA0` by name. Enabling it is `dtparam=uart0=on`, *not* `enable_uart=1` —
`raspi-config nonint do_serial_hw 0` picks the right one via its own board test, which
is why the script shells out to it rather than writing the line itself.

**`/dev/pps0` is not stable, and this is the one that costs a day.** The Pi 5's Ethernet
PHY registers a PPS device for its PTP clock, so there are two, and which one gets
`pps0` is decided by probe order. Measured 2026-09-28: `ptp0` held `pps0` before a
reboot and `pps1` after it, with the GPIO capture taking the other each time. So
`refclock PPS /dev/pps0` points chrony at the network card about half the time — and it
fails *silently*, because chrony simply never gets a sample from it. The fix is a udev
rule matching the capture device by its device-tree name:

    SUBSYSTEM=="pps", ATTR{name}=="pps@12.-1", SYMLINK+="pps-gps"

Note `pps@12`, not `pps@18`. Device-tree node addresses are hex, and GPIO18 is 0x12.
Writing the decimal number makes the rule never match, `/dev/pps-gps` never appear, and
the whole thing look like a bad overlay.

**A −18 s offset is not a misconfiguration.** It is the GPS-to-UTC leap second offset,
currently exactly 18 seconds, showing because the receiver has not yet downloaded the
UTC parameters from the navigation message. That needs a sustained fix — up to 12.5
minutes of continuous lock. It clears itself.

### Daemon layout

`gpsd` gets the UART only. `chrony` opens `/dev/pps-gps` itself as a refclock, so gpsd
never needs the PPS device and it is deliberately absent from `DEVICES`.

`gpsd.socket` has to be **disabled**, not merely unused. Socket activation waits for a
client, which is the exact opposite of what `-n` asks for, and with the socket enabled
chrony's shared-memory segment stays empty until something else connects. `-b` is there
because the Pi's TX is not wired: read-only stops gpsd writing probe strings into a line
that goes nowhere.

    refclock SHM 0 refid NMEA offset 0.2 delay 0.2 noselect
    refclock PPS /dev/pps-gps lock NMEA refid PPS prefer

NMEA only numbers the seconds; PPS does the disciplining. `noselect` keeps the sentences
out of the selection — they are the coarse reference PPS locks onto, nothing more. Retune
`offset` from `chronyc sourcestats` once it has run a while; at 9600 baud the sentence
lag is significant.

### What it measures

Measured 2026-09-28, with chrony having selected PPS as the system reference:

    #? NMEA    0  4  200  127   -42ms[  -42ms] +/- 100ms
    #* PPS     0  4  200  121   -380ns[-3486ns] +/- 352ns

−380 ns against ±352 ns of estimated error. The `#*` is the part that matters: chrony
picked the GPS over the pool.

Fixes are intermittent at this location because the sky view is poor, and that is
environmental, not a fault. Four satellites at SNR 22–32 is the marginal baseline seen
indoors here; 6+ at 35+ is what a solid lock wants.

### The first board was dead, and proving it took longer than the build

Worth recording because the failure looked exactly like bad rework, and the reasoning
that separated them generalises.

Symptoms: both QLG2 outputs sat statically high and never transitioned. No NMEA at any
of six baud rates, with the UART interrupt never firing once — not a framing problem, no
edges at all. No 1PPS under interrupt-driven `ppstest`, which cannot miss a 100 ms pulse.

What made it ambiguous is that the board's own status LEDs read the same node the Pi
did, so "module silent" and "break between module and header" produced identical
evidence. Three things settled it:

- A forced GPIO pull-down, with an unconnected pin as a control, showed both lines
  *actively driven* rather than floating. The control went low; these did not.
- Continuity on JP2 and JP5 was correct in both directions — centre-to-lower closed,
  centre-to-upper open — so the rework was sound.
- The SMA measured 7 kΩ centre-to-ground and 3.3 V of antenna bias, so the module had
  every rail it needed and the feed was not shorted.

Powered, correctly jumpered, correctly wired, and producing nothing. Swapping the module
fixed it on the first try, which is the only test that was ever going to be conclusive.

The lesson is ordering, not electronics: **prove a module works before you modify it.**
The first board was cut before it had ever been seen working, which made every
subsequent symptom ambiguous between a dead part and a bad cut. `57-gps-time.sh` says to
power the board on stock, with only 5 V and ground connected and no signal wires, and
confirm the yellow LED flickers and the green flashes — then cut.

---

## §10 Still open

- No audio capture device. Only `vc4hdmi0`/`vc4hdmi1` (HDMI playback). The radio
  interface presumably appears when connected, confirm that before relying on FT8 in the
  field.
- ~~`mariadbd` is enabled and burns 7–11% CPU at idle~~ RESOLVED 2026-09-29, by
  removal. `cqrlog`, `mariadb-server`, `mariadb-server-core` and the five
  `mariadb-plugin-provider-*` packages are purged, along with the orphaned
  client and perl libraries that came with them. No mariadb unit files remain.

  The cause is the part worth keeping, because neither file ever recorded it:
  **cqrlog** depended on `mariadb-server` and was the only installed package
  that did. cqrlog had never been configured or run (there was no
  `~/.config/cqrlog` at all), so a database server was idling on behalf of a
  logger that had never been opened. The datadir held `mysql`,
  `performance_schema` and `sys` and nothing else.

  Three loggers remain (`klog`, `tucnak`, `xlog`) and none of them wants a SQL
  server; they are all file or SQLite backed. `libmariadb3` and `mariadb-common`
  stay behind on purpose, because `libreoffice-sdbc-mysql` links against the
  client library. That is a library, not a service, and costs nothing.
- RTC cell. `J5`/`BATT` is empty and charging stays disabled until a
  known-rechargeable ML2020 is fitted (§4).
- GPS antenna siting. §9 is built, wired and measured — chrony selects PPS at −380 ns —
  but fixes are intermittent where the deck normally sits, because the sky view is poor.
  The supplied antenna wants open sky *and* a ferrous ground plane, and the deck offers
  neither. Nothing to fix in software; it needs somewhere better to sit.
- Compile-load temperature inside the enclosure. §4's numbers are from the bare setup
  on a desk; the deck measured 2–3 °C cooler on the synthetic test, but a compile is the
  case worth measuring directly (docs/CASE.md §11).
