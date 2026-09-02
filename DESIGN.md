# cyberdeck — design notes

Why this machine is set up the way it is. Written so the reasoning survives
being forgotten. Where a decision came from a measurement, the measurement is
here too — an unsourced number is a number nobody can re-check.

---

## §1 — Why Raspberry Pi OS, and not Fedora Sway Atomic

The obvious move was to reuse `~/src/frameworkimage` and `~/src/kb3lyb`, which
are BlueBuild/bootc images on Fedora Atomic. That was investigated and
**rejected**. Fedora is disqualified on this hardware:

- **NVMe root is not supported on the Pi 5.** Fedora's ARM lead: *"PCIe for HATs
  via the add-on HATs and related products including NVME. **Not currently for
  boot/root.**"* The Fedora 44 release notes still list NVMe under not-working.
  This deck's root filesystem is `/dev/nvme0n1p2` (468G, 161G used) and
  `config.txt` carries a deliberate `dtparam=nvme` + `dtparam=pciex1_gen=3`.
  Fedora would demote the machine to the microSD slot.
- **Audio does not work** on Fedora/Pi 5. This is a ham deck. Audio is the payload.
- **Thermal management does not work.** Bad in an enclosure.
- **No Atomic image exists for Pi 5 at all** — F44 ships Minimal, KDE and GNOME
  only. So "Fedora Sway Atomic" is not a thing that can be flashed here, which
  also removes the base the two reference repos would have needed.
- The Pi 5 kernel is a **non-vanilla COPR kernel** maintained in spare time.
  Wrong dependency for a machine whose purpose is working when nothing else does.

**What actually ports from the reference repos is the `config.kdl`, not the
machinery.** The Containerfile/recipes/modules apparatus is meaningless on a
mutable Debian system. This repo is therefore a different shape: provisioning
scripts plus config, not an image build.

### OS currency (checked 2026-08-31)

Raspberry Pi OS trixie (Debian 13) **is** current — latest release 6.2,
2026-04-14. Debian 14 "forky" is still in development. `apt list --upgradable`
returns 0. There is no newer OS to move to.

The one live question is the kernel: the box runs **6.12.62** with **6.18.39**
staged and awaiting reboot. There is an open upstream regression —
*random hard freezes on 6.18*, raspberrypi/linux#7381 — reported on **Pi 4/400,
not confirmed on Pi 5**, with reporters unable to reproduce on 6.12.75.
`linux-image-6.12.62` and `6.12.47` remain installed, so rollback is available.
Validate 6.18.39 **before** building a desktop on top of it; debugging a
compositor and a kernel regression simultaneously is not a thing to sign up for.

---

## §2 — The screen decides almost everything

    HDMI-A-1   RTK CX101   1280x800@60   220x130mm   ~148 DPI

**Scale 1 is forced, not chosen.** Decoded from this machine's own
`~/.config/WSJT-X.ini` (Qt `saveGeometry` blobs, dated 2026-03-05):

| Window | Saved size |
|---|---|
| `[MainWindow]` | **880 x 685** |
| `[WideGraph]` waterfall | 938 x 337 |
| `[Configuration]` settings dialog | 1280 x **811** |

At scale 1.25 the logical desktop is 1024x640. The WSJT-X main window alone
wants 685px of height — **it would not fit on an empty screen**. That ends the
scale discussion with arithmetic instead of taste. Legibility is recovered with
font sizes in `foot`/`waybar`, not with compositor scale.

Consequences that follow from 1280x800, all visible in `config/niri/config.kdl`:

- **`gaps 4`**, down from the parent's 8.
- **Column presets 0.5 / 0.75 / 1.0**, up from 0.33/0.5/0.66, and
  `default-column-width` of **1.0**. On this panel the normal case is one app at
  a time; a 0.33 column is 427px and useful to nothing here.
- **waybar height 24**, and `Mod+Shift+B` to hide it entirely — 30px is the
  difference between the WSJT-X main window fitting and not.
- **No `focus-follows-mouse`**, unlike *both* parent configs. With a touchscreen
  the pointer teleports to wherever you last touched and then stays there;
  focus-follows-mouse would hand keyboard focus to whatever sits under that
  stale point. Keyboard focus only.
- **`cursor { hide-when-typing }`** — the pointer is a touch artefact.

### The hotkey overlay is the manual

No mouse, and `prefer-no-csd` means no titlebars, so window management is 100%
keyboard. `Mod+Shift+Slash` is therefore the deck's actual documentation.

**Rule for `config.kdl`: no `spawn` bind without a `hotkey-overlay-title`.**
Action binds describe themselves in the overlay; spawns show up as a bare
command line unless titled.

---

## §3 — FT8 software: DECIDED. MSHV.

Settled 2026-08-31 on measurements from the real panel, not inference.
`niri msg windows` with all three running at scale 1 on the 1280x800 output:

| | Windows | Main | Waterfall | Settings dialog |
|---|---|---|---|---|
| WSJT-X 2.7.0 | **2** | 1272x768 | separate, 1272x200 | **1280x813** |
| JTDX 2.2.159 | **2** | 1272x768 | separate | — |
| **MSHV 2.76.7** | **1** | 1272x768 | **inside the window** (Ctrl+W) | — |

MSHV opens as a single window. WSJT-X and JTDX each need a second floating
window placed by hand-written rules, on a panel with roughly 776px of usable
height. That was the §2 arithmetic and it held up in practice.

WSJT-X's Settings dialog measured **1280x813** — taller than the 800px screen.
The `.ini` decode predicted 811, so the prediction was sound and the problem is
real. See §4 on why no window rule can float it.

**What MSHV does NOT give up** — checked against the built binary rather than
assumed, because "the niche fork must be worse at integration" is the obvious
prior and it is wrong here:

- **UDP port 2237** — the WSJT-X protocol port. QLog, GridTracker and JTAlert
  work against it.
- **PSK Reporter** built in (`report.pskreporter.info`).
- **ADIF** export all/selected, plus direct ClubLog, eQSL and QRZ upload.

So the choice costs no ecosystem integration. It buys one window instead of two
on a screen that cannot afford two.

**WSJT-X stays installed** as the reference implementation and insurance: it is
apt-maintained, new modes land there first, and its window rules are verified
working. **JTDX is redundant** — it is a WSJT-X fork, so it duplicates the
fallback rather than adding one. Operator has said it will not be used; it
remains installed but is a candidate for removal.

## §4 — Traps found, so they are not re-found

- **Rust MSRV.** trixie ships rustc 1.85; niri v26.04 needs **1.87**. The build
  fails confusingly, not cleanly. `10-build-niri.sh` installs rustup.
  xwayland-satellite v0.8.2 pins 1.85.0 exactly and needs no rustup.
- **`qtwayland5` is load-bearing.** The config sets `QT_QPA_PLATFORM=wayland`;
  without that package *every* Qt app (wsjtx, jtdx, MSHV, gqrx) refuses to
  start. It is installed — do not remove it.
- **`policykit-1-gnome` does not exist in trixie** (`Candidate: (none)`). The
  agent here is **`mate-polkit`** at `/usr/libexec/polkit-mate-authentication-agent-1`
  — already installed, and already what labwc autostarts. The parent config had
  this right; "correcting" it to a Debian-looking `/usr/lib/policykit-1-gnome/`
  path is wrong.
- **Debian calls the notification daemon `mako-notifier`**, but the binary is
  still `mako`. The config spawning `mako` is correct.
- **MSHV's `src/config.h` has a manual Qt4/Qt5 switch** that may default to Qt4,
  which does not exist in trixie. `30-build-mshv.sh` rewrites it.
  Its aarch64 `.pro` uses generic `-lasound`, so the hardcoded-libasound-path
  fix in upstream's README does **not** apply — but it does link a *prebuilt
  static* `libfftw3_slarm64_pi.a` from the repo, the first suspect on link errors.
- **Window rules fail silently.** Every `app-id` in `config.kdl` is a guess
  until checked with `niri msg windows`. The parent config demonstrates the rot:
  it documents a `Mod+W` "wsjtx-layout" script that exists in **no** `.kdl` and
  **not** in `files/scripts/`. Verify, then delete this warning.
- **MSHV publishes no git tags** — only `main`. It is pinned by commit SHA.

---

## §5 — Not yet addressed

- **The AI stack is NOT broken — that earlier claim was wrong.** `~/venv`
  contains a working `llama_cpp_python 0.3.16`, plus torch 2.10 and
  transformers 5.2. The `ModuleNotFoundError` came from running `~/ai.py` with
  the **system** python instead of `~/venv/bin/python`. Verified 2026-08-31:
  `cd ~ && ~/venv/bin/python ai.py` generates text correctly.

  What *was* genuinely wrong is smaller and is fixed by `files/ai/ask-local.py`
  (installed as `ask-local` by `bin/60-local-ai.sh`): `MODEL_INIT` was defined
  but never used, so the system prompt did nothing; both scripts pointed at the
  3B model, leaving the 4.1GB Mistral-7B unused; `MODEL_PATH` was relative so
  they only ran from `$HOME`; and `n_ctx` defaulted to 512 against a 2048+
  train context. The replacement also uses the model's own chat template
  instead of hand-rolled `### User:` strings.

  The real upgrade is `llama-server` with a browser UI next to Kiwix —
  `bin/60-local-ai.sh`. **Needs a fan first:** one short inference took this
  machine to **96.6 °C**.
- **No audio capture device.** Only `vc4hdmi0`/`vc4hdmi1` (HDMI playback). The
  radio interface presumably appears when connected — confirm before relying on
  FT8 in the field.
- **EEPROM update is available** (`rpi-eeprom-update`). Relevant because this
  box boots from NVMe. Do it as its **own** step, after the kernel reboot is
  validated, so a failure is attributable to one change.

---

## §6 — THERMAL: this Pi has no fan, and it is throttled at idle

Found 2026-08-31, immediately after the 6.18.39 reboot. This is the single
biggest problem with the machine and it is **hardware, not software**.

| Measurement | Value |
|---|---|
| Idle temperature | **88-90 °C** (load ~1.1, nothing running but the desktop) |
| Under 20s of 4-core load | **93.3 °C** |
| `vcgencmd get_throttled` | **`0x60006`** |
| ARM clock, actual | **1.0 GHz** |
| ARM clock, configured max | **2.4 GHz** |
| `/sys/class/thermal/cooling_device*` | **empty — no fan** |

`0x60006` decodes to: arm frequency capped **now** (bit 1), currently throttled
**now** (bit 2), and both have occurred (bits 17, 18). Crucially the
under-voltage bits (0x1 / 0x10000) are **clear** — this is purely thermal, not a
power supply problem.

**The deck is permanently running at ~42% of its rated clock.**

The device tree *does* expose a `cooling_fan` node (pwms, rpm-regmap,
cooling-levels), and the thermal zone has active trip points at 50/60/67.5/75 °C
— those are fan speed steps. They are all inert because nothing is plugged into
the fan header. `config.txt` also sets `arm_boost=1`, i.e. boosting a Pi with no
cooling.

Both the firmware (`vcgencmd`) and the kernel (`thermal_zone0`) agree on the
temperature, and the firmware independently reports a real clock cap, so this is
not a sensor glitch. Whether 6.18.39 made it worse is **unknown** — no
temperature reading was taken on 6.12.62 before the reboot. Given there is no
fan at all, it is near-certainly chronic rather than a kernel regression.

### What was done about it in this repo

`bin/lib.sh` gained `build_jobs()` and `thermal_check()`. All three from-source
builds now use **half the cores** (`-j2`) and print the temperature and throttle
flags first. Override with `JOBS=4` once a fan is fitted.

### What needs doing outside this repo

1. **Fit a fan.** The Pi 5 Active Cooler, or any 4-pin PWM fan on the header.
   The kernel is already set up to drive it — a cooling device will appear in
   `/sys/class/thermal/` and the 50/60/67.5/75 °C trip points start working.
2. Re-measure, then set `JOBS=4` and drop the `-j2` default.
3. Consider whether `arm_boost=1` is wise until cooling exists.
4. **`mariadbd` is enabled and burning ~7-11% CPU at idle** on a machine with no
   thermal headroom. Nothing on this deck obviously needs MariaDB. Investigate
   and probably `systemctl disable --now mariadb` — free heat and free RAM.

### Consequence for the waybar config

`config/waybar/config` sets the temperature module's `critical-threshold` to 75.
It will therefore show `HOT` permanently until a fan is fitted. That is correct
behaviour — it is reporting a real condition, not a misconfiguration.

### §6.1 — Physical constraints (photographed 2026-08-31)

The case was opened and photographed. What is actually in there:

- Raspberry Pi 5, with **passive finned heatsinks already fitted** to the SoC
  and RAM. So this is not a bare board — passive cooling is present and is
  simply not sufficient for a Pi 5 under an enclosure.
- A **SupTronics Technologies RPi5 PIP-NVMe Shield X1001 V1.1**, mounted on the
  PCIe FPC ribbon, sitting **directly above the SoC**, with a KingSpec NE Series
  M.2 2280 on top of it.
- A display driver board (CX 070FHD-P-V3.2) alongside.
- **The Pi 5 fan header is present and EMPTY** — the 4-pin JST next to the
  "HAT+ GPIO INTERFACE" silkscreen. This matches `/sys/class/thermal/cooling_device*`
  being empty.

**CORRECTION 2026-08-31.** An earlier version of this section claimed "there is
no vertical room for a Pi 5 Active Cooler under that shield." That was inferred
from a photograph and is **wrong**. Geekworm's own X1001 documentation states it
"supports installation of official Pi 5 active cooler" and lists the official
Active Cooler, Argon THRML, H505 and H501 as compatible. The X1001 is described
as "extremely thin ... gives ample room for cooling the Pi underneath" — it is
designed as a thin lid *so that* a cooler fits below it. Geekworm sells the
X1001 + H505 as a bundle.

So the board is not the problem; the **absence of active cooling under it** is.
The heatsinks currently fitted are passive and radiate into a PCB a few
millimetres above them, with no air being moved.

**This means no new NVMe board is needed.** The fix is an active cooler beneath
the existing X1001, plugged into the empty 4-pin fan header. Caveat: the
aftermarket passive heatsinks presently stuck to the SoC and RAM must come off
first. Measure PCB-surface-to-X1001-underside before ordering; the official
Active Cooler is roughly 10mm tall.

Bottom-mount alternatives exist if that fails — Geekworm **X1005** (rear-mount,
dual NVMe) or **Pimoroni NVMe Base** — but both add thickness BELOW the Pi, and
this build has the power board and HDMI driver board occupying that space. The
**M.2 HAT+ Compact** is the lowest-profile option of all but is 2230-only, so it
would mean a new SSD and migrating 158GB off the KingSpec 2280.

### §6.2 — Options, in order of effort

1. ~~**Cap the clock.**~~ **STRUCK — tested and does not work. See §6.4.** `bin/70-thermal-tune.sh`. The board is configured for 2400MHz with
   `arm_boost=1` and *never reaches it* — it throttles to 1000-1500MHz and
   oscillates. A cap the passive heatsinks can sustain (try 1800, then 1500)
   holds continuously instead of sawtoothing. **A sustained 1800MHz beats a
   throttled 1000MHz by 80%** while running cooler. Trade an unreachable peak
   for a reachable floor.
2. **`systemctl disable --now mariadb`** — 7-11% CPU burned permanently on a
   machine with no thermal headroom, for nothing this deck appears to use.
3. **A fan does not have to sit on the Pi.** The empty fan header takes a 4-pin
   JST-SH (PWM + tach) and the kernel already has trip points at 50/60/67.5/75°C
   waiting to drive it. A 25-30mm × 7mm fan mounted to the **case wall or lid**,
   wired to that header, gets full automatic control without needing clearance
   above the board. This is the fix that actually solves it rather than
   mitigating it.
4. **Raise the X1001 on taller standoffs**, if the case lid allows even 3-5mm.
   Airflow gap over the SoC matters more than absolute case volume.
5. Verify the heatsinks are properly seated and thermally bonded — worth a look
   while the case is open, since a lifted heatsink would explain a lot.

### §6.3 — Case open: measured, not guessed

Opening the case moved the sustained clock from **1.0GHz to 1.5GHz** and dropped
idle temperature by roughly 2°C (90°C → 87°C). `get_throttled` stayed `0x60006`
— still actively capped. Later readings hit `0xe0006`, which adds bit 19: the
**soft temperature limit has been reached**.

So airflow demonstrably helps and is the right axis to attack, but passive
convection alone does not clear the throttle on this board.

### §6.4 — The clock cap does NOT help. Measured, negative result.

The hypothesis in §6.2 item 1 — that capping `arm_freq` would trade an
unreachable peak for a higher *sustained* clock — was **tested and is wrong**.
Two 5-minute 4-core load runs, case open, same ambient:

| Setting | Sustained mean | Range | Temp |
|---|---|---|---|
| Stock: `arm_freq=2400`, `arm_boost=1` | **1500 MHz** | flat 1500 | 84.5–87.3 °C |
| Capped: `arm_freq=1800`, `arm_boost=0` | **1503 MHz** | 1350–1711, oscillating | 84.0–86.2 °C |

Identical within noise, and the capped run dips to **1350** — *below* the stock
run's floor. Reverted to stock.

**Why the hypothesis failed:** this SoC is *thermally* limited, not
ceiling-limited. It settles at whatever clock dissipates the sustainable
wattage at ~85 °C. Lowering the ceiling does not move that equilibrium; the
governor was already finding the correct clock. Capping only makes the
governor's stepping noisier.

**Therefore cooling is the only lever.** §6.2 items 3–5 (a case-wall fan on the
empty header, raising the X1001, reseating heatsinks) are the real options.
Item 1 is struck.

Useful side observation: from cold with the case open the machine idles at
**65–72 °C** and briefly reaches 2.2 GHz. The 87–96 °C figures from earlier were
a heat-soaked *closed* case. Airflow is worth a lot here.

---

## §7 — DUPLICATE UUIDs: the SD card is a clone and every boot is a coin flip

Found 2026-08-31. **This is a data-integrity hazard, not a performance one.**

The 238 GB SD card is a full clone of the NVMe, with **byte-identical UUIDs and
PARTUUIDs on both partitions**:

| | NVMe | SD |
|---|---|---|
| boot | PARTUUID `14191c5d-01`, UUID `F587-071F`, LABEL `bootfs` | **identical** |
| root | PARTUUID `14191c5d-02`, UUID `d6944274-…`, LABEL `rootfs` | **identical** |

`/etc/fstab` mounts `/boot/firmware` by `PARTUUID=14191c5d-01`, and the kernel
cmdline uses `root=PARTUUID=14191c5d-02`. **Both selectors match two devices.**
Whichever enumerates first wins, and it varies per boot — observed flipping from
`nvme0n1p1` to `mmcblk0p1` and back across three reboots.

The two boot partitions had already diverged:

| | SD | NVMe |
|---|---|---|
| `kernel_2712.img` | 2026-02-19 (stale) | 2026-08-31 (6.18.39, in use) |

**How it bit us:** `bin/70-thermal-tune.sh set 1800` wrote to `/boot/firmware`,
which that boot was the *SD*. The firmware boots from NVMe (`BOOT_ORDER=0xf146`
→ NVMe first; confirmed because the running 6.18.39 image exists only there), so
it read the NVMe's config.txt and the cap silently did nothing. The first
"capped" measurement was invalid.

**The worse failure mode is `root=`.** If a boot resolves `14191c5d-02` to
`mmcblk0p2`, the machine boots the **2025-12-04** clone and appears to have lost
nine months of work. Not yet observed, but nothing prevents it.

### Verdict: remove the SD card

Verified it holds nothing unique:

- ZIM lists **identical** to the NVMe (the apparent 43-vs-42 was a counting
  artifact — one non-`.zim` file in the directory).
- Only files present on SD and not NVMe were `ai.sh` / `codeai.sh`, which are
  byte-identical copies of `ai.py` / `codeai.py` with the wrong extension.
  Rescued to `$HOME` anyway.
- SD rootfs last modified **2025-12-04**; SD kernel **2026-02-19**. Both stale.

Removal needs no `fstab` change: with one device gone, both PARTUUID selectors
become unambiguous on their own.

If the card must stay physically installed, the alternative is to break the
collision in software — change the disk identifier with `fdisk /dev/mmcblk0`
(`x` → `i`), then `tune2fs -U random /dev/mmcblk0p2` and re-create the FAT
UUID — and then fix that clone's own `fstab`/`cmdline.txt` so it stays
independently bootable. Removal is far simpler.

### §7.1 — Resolved 2026-08-31: SD removed

Card pulled. Post-removal state verified by `bin/80-check-boot-integrity.sh`:

- `PARTUUID=14191c5d-01` → `/dev/nvme0n1p1` (one device)
- `PARTUUID=14191c5d-02` → `/dev/nvme0n1p2` (one device)
- `/boot/firmware` and `/` both on `nvme0n1` — same physical disk
- `kernel_2712.img` **byte-identical** to `vcmlinuz-6.18.39+rpt-rpi-2712`
- exactly one `bootfs` and one `rootfs` label

No `fstab` change was needed: removing the duplicate made both selectors
unambiguous on their own.

**Side benefit — idle temperature fell to 55.4 °C**, from 87–90 °C. Some of that
is the open case, but the SD carrier board sat in the airflow path too. For the
first time this session `get_throttled` showed `0xe0000` — history bits only,
**no active throttling**.

### §7.2 — A note on the check that cried wolf

`80-check-boot-integrity.sh` check 3 originally grepped the boot image with
`strings` for `uname -r` and reported a divergence on a perfectly healthy
system. `kernel_2712.img` is **gzip compressed**, so the version string is never
present in plaintext.

It now compares the image byte-for-byte against `/boot/vmlinuz-$(uname -r)` from
the installed `linux-image` package. Exact, and no decompression needed. A check
that produces false alarms is worse than no check — it trains you to ignore it.

### §6.5 — Fan wiring on this board (2-pin 5V fan)

The Pi 5 fan header is 4-pin JST-SH 1.0mm:

| Pin | Signal |
|---|---|
| 1 | +5V (red), marked with a triangle |
| 2 | PWM (blue) |
| 3 | GND (black) |
| 4 | Tach (yellow) |

**5V and GND are pins 1 and 3 — NOT adjacent.** A 2-pin plug pushed into this
header lands on 1+2 (5V+PWM) or 3+4 (GND+Tach), never both rails. A 2-pin fan
therefore CANNOT use this connector, and forcing a mismatched JST-SH plug
damages it.

**The 2-pin connector next to the USB-C power input is `J5`/`BATT` — the RTC
battery connector. It is an INPUT, not a power source.** Constant-current 3mA
charger for an ML2020 cell, charging disabled by default. A 30mm fan wants
100-200mA, ~100x more. Do not connect a fan to it.

**Chosen wiring for the 5V 2-pin fan: GPIO header pin 4 (+5V) and pin 6 (GND).**
Adjacent, exposed, no adapter. Always-on at full speed whenever the Pi is
powered. For a deck that throttles under any sustained load, always-on is
defensible rather than a compromise.

Optional upgrade, if a transistor gets added later: switch the fan's ground
through an NPN (S8050) or logic-level MOSFET on a GPIO, then

    dtoverlay=gpio-fan,gpiopin=12,temp=60000

in `config.txt` registers it as a real `cooling_device` with automatic on/off.
Note that this must be written to the NVMe's config.txt — see §7.


### §6.6 — Thermal conclusion: stock config + active airflow

Four 5-minute sustained 4-core runs, same ambient:

| Config | Sustained mean | Temp range |
|---|---|---|
| Stock 2400 + boost, no fan | 1500 MHz | 84.5-87.3 °C |
| `arm_freq=1800`, boost off, no fan | 1503 MHz | 84.0-86.2 °C |
| `arm_freq=1800`, boost off, **+ fan** | ~1600 MHz | 82.9-85.6 °C |
| **Stock 2400 + boost, + fan** | **1769 MHz** | 82.9-86.2 °C |

**Stock config wins in BOTH the fan and no-fan cases**, which independently
confirms §6.4: do not cap the clock. Airflow is worth **+18%** sustained
(1500 -> 1769 MHz), plateaus by t=30s, and leaves 24 °C of margin to the 110 °C
critical trip. `JOBS=4` is therefore safe with a fan present.

Idle with active airflow: **50-63 °C**, versus 87-90 °C in a closed, fanless,
heat-soaked case.

### §4.1 — MSHV will not link against its own bundled fftw

`MSHV_Slarm64_PI.pro` ships a **prebuilt static** `libfftw3_slarm64_pi.a`
compiled **without `-fPIC`**. Debian builds PIE executables by default, so ld
refuses it outright:

    relocation R_AARCH64_ADR_PREL_PG_HI21 against symbol `stdout@@GLIBC_2.17'
    which may bind externally can not be used when making a shared object

The obvious fix is `-no-pie`. **Substituting Debian's shared fftw is better** —
it keeps PIE hardening *and* the library receives security updates, rather than
being frozen in a vendored archive from an unknown toolchain. `30-build-mshv.sh`
rewrites the `LIBS` line to `-lfftw3 -lfftw3f -lfftw3_threads -lfftw3f_threads`
and keeps a `.orig` alongside.

The archive provided double-precision `fftw_*` (541 symbols). MSHV also
references a handful of `fftwf_*`, but those resolve to dead code: the linked
binary pulls in only `libfftw3.so.3`. Result is a PIE aarch64 executable
dynamically linked against system alsa, pulse, fftw and Qt5.

---

## §8 — niri-session runs the distro's XDG autostart, so spawns collide

Symptom on first boot into niri: **two bars stacked on a 800px panel.**

`niri-session` starts a systemd user session that pulls in
`xdg-desktop-autostart.target`. Raspberry Pi OS populates `/etc/xdg/autostart`
for its labwc desktop, and those entries therefore run inside niri too. Anything
`config.kdl` also spawns is then started twice. Confirmed by cgroup, not by
guesswork — the two waybars were:

    app-niri-waybar-1385.scope    <- spawn-at-startup in config.kdl
    waybar.service                <- Debian's systemd user unit

**waybar.service ships enabled, and enabled GLOBALLY.** `systemctl --user
disable` is not enough and says so:

    The following unit files have been enabled in global scope. This means they
    will still be started automatically after a successful disablement in user
    scope: waybar.service

The symlink lives at
`/etc/systemd/user/graphical-session.target.wants/waybar.service` and needs
`sudo systemctl --global disable waybar.service`.

Second collision: **two polkit agents.** `config.kdl` spawned polkit-mate while
`/etc/xdg/autostart/lxpolkit.desktop` was already providing one. The parent
kb3lyb config spawns an agent because Fedora Sway Atomic has no such autostart —
that premise does not hold here. The spawn is removed and lxpolkit is left to
do its job.

`nm-applet` is deliberately NOT removed despite `/etc/xdg/autostart/nm-applet.desktop`
existing: that entry launches the plain applet, which uses the dead XEmbed tray,
while the config spawns `--indicator` for the StatusNotifierItem path waybar
understands. Verified exactly one instance runs.

**`pkill -f` over ssh is actively dangerous, not just misleading.** Same root
cause as below: `ssh host 'pkill -f jtdxjt9'` matched the ssh-spawned shell's
own command line and killed the session mid-command. Use `pkill -x`, or match a
pattern that cannot appear in the invoking command.

**Counting instances with `pgrep -f <name>` over ssh lies** — the ssh command
line contains the pattern and matches itself, which inflated every count in the
first pass and briefly suggested six duplicates that did not exist. Use
`pgrep -x`, or read the cgroup tree with `systemd-cgls --user-unit app.slice`.

### §8.1 — the reload action is `load-config-file`

`niri msg action reload-config` does not exist; niri suggests
`load-config-file`. `bin/sync-to-pi.sh` was calling the wrong one. Over ssh it
also needs `NIRI_SOCKET`, which is `/run/user/1000/niri.<display>.<pid>.sock`.


### §6.7 — CORRECTION: the good thermal numbers were open-case artifacts

The 50-63 °C idle figures in §6.6 were measured with the **case open**. The case
has to be **closed** in normal use — it is a display case and the screen is the
point. Measured closed, with the external fan still blowing at it:

| State | Idle |
|---|---|
| Closed, no fan, heat-soaked | 87-90 °C |
| **Closed + external fan — THE REAL OPERATING STATE** | **80.1 °C** |
| Open + external fan | 50-63 °C |

An external fan buys roughly 8 °C through a closed case. That is not nothing,
but it is nowhere near the 30 °C the open-case figures implied, and **no number
recorded against an open case describes how this deck actually runs.**

The consequence is not a change of plan but a hardening of it: the case is the
thermal boundary, so cooling must be **inside** it. A case-wall or header-mounted
fan, or the active cooler under the X1001 (§6.1). Blowing air at a closed box was
always a stopgap and the measurement says how small a one.

Sustained-load figures in §6.4 and §6.6 were also taken with the case open, so
the 1769 MHz mean is an **upper bound**, not the operating baseline. The
closed-case sustained figure has not been measured. Do that when the fan arrives
so the comparison is like-for-like: `70-thermal-tune.sh measure 300`, case shut.

---

## §6.8 — RESOLVED. Active cooler fitted 2026-09-02.

The thermal problem that dominated this build is fixed. Definitive measurement,
**case closed**, which no earlier figure in this file can claim:

    Baseline: temp=54.3'C  throttled=0x0  arm=1700024448
      t=30s   67.5 °C   0x0   2400030464
      t=60s   69.2 °C   0x0   2400033792
      t=90s   70.8 °C   0x0   2400023808
      t=120s  72.5 °C   0x0   2400033792
      t=150s  73.6 °C   0x0   2400023808
      t=180s  74.1 °C   0x0   2400027136
      t=210s  76.3 °C   0x0   2400037120
      t=240s  75.7 °C   0x0   2400027136
      t=270s  76.8 °C   0x0   2400027136
      t=300s  76.3 °C   0x0   2400027136

**Full 2400 MHz sustained for five minutes with zero throttle bits**, plateauing
at ~76 °C. The last four samples oscillate 75.7-76.8, which is equilibrium, not
a climb.

| Configuration | Sustained | Temp | Throttled |
|---|---|---|---|
| Closed, no cooler | 1500 MHz | **80.1 °C at IDLE** | permanently |
| Open case + external fan | 1769 MHz | 82.9-86.2 °C | yes |
| `arm_freq=1800` capped, no fan | 1503 MHz | 84.0-86.2 °C | yes |
| **Closed + Active Cooler** | **2400 MHz** | 67.5-76.8 °C | **never** |

**+60% sustained clock over the original baseline**, and the machine reaches its
rated speed for the first time in anything measured here.

### The fan is a real cooling device now

`/sys/class/thermal/cooling_device0` went from **absent** to
`type=pwm-fan cur=1 max=4`, and it ramps: **3602 rpm at idle, 9950 rpm (state
4/4) under load**. The trip points at 50/60/67.5/75 °C that had been inert since
§6.1 are now doing their job.

### 75 °C is not a warning

Worth stating because it looks alarming next to the old numbers: **the
50/60/67.5/75 °C trip points are FAN SPEED STEPS, not throttle points.** Hitting
75 means the fan goes to maximum, which is the system working. Throttling begins
at the 85 °C soft limit; critical is 110 °C. At 76.8 °C under full load there is
8 °C of headroom and the clock never moved.

The deck previously sat at **80 °C while idle**. It now runs cooler under full
four-core load than it used to at rest, at 60% higher clock.

### Consequences

- `build_jobs()` now defaults to **all cores**, not half. `JOBS=2` restores the
  conservative behaviour if the cooler is ever removed.
- `bin/60-local-ai.sh` is **unblocked** — llama.cpp inference was previously
  refused because one short run hit 96.6 °C.
- The 100 °C guard stays as a tripwire for a **failed or obstructed fan**, not
  as an expected condition.
- §6.7's warning still stands for the historical numbers: everything measured
  before this section, except the 80.1 °C idle figure, was open-case.

### §6.9 — the synthetic load test UNDERSTATES real thermal load

`70-thermal-tune.sh measure` applies four `while :; do :; done` spinners. That is
pure scalar ALU with the whole working set in L1 — it draws far less power than
real work. Measured on the same machine, same cooler, case closed:

| Load | Peak temp | Throttle flags |
|---|---|---|
| Synthetic busy-loop (§6.8) | **76.8 °C** | `0x0` — none |
| llama.cpp compile, `-j4` | ~85 °C | `0x80000` — soft limit **occurred** |
| **7B Q4_K_M inference** | **82.3 °C** | `0xe0008` — soft limit **ACTIVE NOW** |

Bit 3 (`0x8`) means the SoC was sitting at the 85 °C soft limit while generating.
The clock only eased from 2400 to 2366 MHz, so this is mild and the work
completes — but it is not the "76.8 °C, zero throttling" headline from §6.8.

**Why:** LLM inference saturates memory bandwidth and hammers NEON/SIMD. A
scalar spin loop touches neither. The compile sits in between.

**So §6.8's figure is a floor, not a ceiling.** The honest summary is: with the
active cooler this deck sustains full clock under synthetic load and brushes the
soft limit under genuinely heavy real work, without ever throttling hard. That is
a working machine, not a marginal one — but a benchmark that reports 76.8 °C for
a workload that really runs at 85 °C would mislead the next person to read it.

Nothing to fix. Recorded so the number is not trusted beyond what it measures.
