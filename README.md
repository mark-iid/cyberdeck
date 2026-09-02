# cyberdeck

niri on a Raspberry Pi 5 cyberdeck: 1280x800 touchscreen, USB keyboard, no mouse,
512GB NVMe, 123GB of offline reference material, and a ham radio stack.

## This is additive. It is not a reinstall.

Nothing here reformats, reinstalls, or replaces Raspberry Pi OS.

- **labwc stays installed and stays the default session.** niri is added
  *alongside* it in the lightdm session menu. Pick at the login screen.
- Everything built from source installs under **`/usr/local`**, which no distro
  package owns. `apt` stays consistent.
- `apt` steps only ever **add** packages. Nothing is removed or replaced.
- Configs are **symlinked** into `~/.config/{niri,waybar,foot}` — all new
  directories. `~/.config/labwc` and `~/.config/wf-panel-pi` are never touched.
- Your ZIMs, `~/.config/WSJT-X.ini`, gqrx, gnuradio, and pat configs are untouched.

**Rollback is: log out, choose labwc.** You are exactly where you started.

## Usage

```sh
bin/provision.sh        # build + install everything (idempotent, re-runnable)
bin/deploy-config.sh    # symlink configs into ~/.config
```

**There is no session menu on this machine** — Raspberry Pi OS ships autologin
(`autologin-session=rpd-labwc`), so it boots straight into labwc. To get into
niri, in increasing order of commitment:

```sh
niri                              # 1. nested inside labwc — zero risk smoke test
                                  # 2. Ctrl+Alt+F2, log in, run: niri-session
bin/90-set-session.sh niri        # 3. make it the boot default
bin/90-set-session.sh labwc       #    ...and back again
```

Recovery if niri fails at boot: ssh in, or Ctrl+Alt+F1..F6, then
`bin/90-set-session.sh labwc && sudo systemctl restart lightdm`.

Individual steps, if you would rather go one at a time:

| Script | What it does |
|---|---|
| `bin/00-packages.sh` | apt: the whole niri ecosystem + all three build toolchains |
| `bin/10-build-niri.sh` | niri `v26.04` from source (**needs rustup — see below**) |
| `bin/20-build-xwayland-satellite.sh` | X11 bridge `v0.8.2`, builds with Debian's rustc |
| `bin/30-build-mshv.sh` | MSHV FT8/FT4, pinned commit, `MSHV_Slarm64_PI.pro` |

## The three from-source builds, and why

Raspberry Pi OS trixie packages the *entire* niri ecosystem — foot, fuzzel,
waybar, swaybg, mako, cliphist, gtklock, seatd, xwayland — but **not niri
itself**. Verified 2026-08-31 against trixie, trixie-updates, trixie-backports
(temporarily enabled to check) and archive.raspberrypi.com. It missed the trixie
freeze. Same for `xwayland-satellite` and MSHV.

**The Rust trap:** trixie ships rustc/cargo **1.85**. niri v26.04 declares
`rust-version = "1.87"`, so the distro toolchain is **too old** and fails with a
confusing error rather than a clean MSRV message. `10-build-niri.sh` installs
rustup for this reason. `xwayland-satellite` v0.8.2 pins exactly 1.85.0 and
builds fine with Debian's own toolchain.

## Open decisions

- **§3 FT8 software is not decided.** WSJT-X 2.7.0, JTDX 2.2.159, and MSHV are
  all installed deliberately, to be compared on the real panel. See `DESIGN.md`.
- **Every `app-id` in `config/niri/config.kdl` is unverified.** Run
  `niri msg windows` on first login and correct them. A rule that matches
  nothing fails silently.

## Optional extras

```sh
bin/50-doomsday-extras.sh          # list the tiers
bin/50-doomsday-extras.sh time     # start here — see docs/CONTENT.md
```

## Editing config after deployment

`deploy-config.sh` symlinks `~/.config/{niri,waybar,foot}` into the repo checkout
**on the Pi**, which is a copy of this one. Edit here, then:

```sh
bin/sync-to-pi.sh    # rsync/tar across, validate the KDL, live-reload niri
```

## Health checks

```sh
bin/80-check-boot-integrity.sh   # run after ANY disk/clone change
bin/verify-post-reboot.sh        # run after any kernel change
bin/70-thermal-tune.sh measure   # 5-min sustained-load thermal profile
```

## Read next

- `DESIGN.md` — the reasoning. **§6 is the thermal problem; read it first.**
- `docs/INVENTORY.md` — full baseline capture.
- `docs/CONTENT.md` — offline content gaps (medical, maps, repair) and the
  GPS-time problem that silently breaks FT8 off-grid.

## Where this was left — 2026-08-31

**Working now.** The deck boots into niri (`autologin-session=niri`). niri 26.04,
xwayland-satellite 0.8.2 and MSHV 2.76.7 are built and installed; configs are
symlinked and validated. All window rules are verified against real app-ids from
`niri msg windows` — no guesses remain.

**Blocked on hardware, all on order:**

| Waiting for | Unblocks | Notes |
|---|---|---|
| Fan (5V 2-pin) | the thermal ceiling | Wire to GPIO **pin 4 (+5V)** and **pin 6 (GND)**. NOT the 4-pin header — 5V and GND are pins 1 and 3 there, not adjacent (DESIGN §6.5). |
| Active cooler for under the X1001 | the real fix | The X1001 is documented to clear the official Pi 5 Active Cooler / H505 (DESIGN §6.1). Existing passive heatsinks must come off. |
| RTC cell (ML2020) | off-grid timekeeping | `J5`/`BATT` is EMPTY. Charging stays **disabled** until a known-rechargeable cell is fitted (DESIGN §5, docs/CONTENT.md). |
| QLG2 GPS | sub-second time for FT8 | **Jumper it to 3.3V logic first** — 5V default will damage a Pi GPIO. `bin/50-doomsday-extras.sh time` has both tiers. |

**Thermal: SOLVED 2026-09-02.** An active cooler under the X1001 took the deck
from 1500 MHz sustained (throttled, 80.1 °C at idle) to the **full 2400 MHz,
closed case, peaking at 76.8 °C with zero throttle bits** (DESIGN §6.8). The fan
appears as `cooling_device0` and ramps 3602 -> 9950 rpm. 75 °C is a fan-speed
trip point, not a throttle point; throttling starts at 85 °C.

**Now unblocked:**

```sh
bin/60-local-ai.sh                   # llama-server; was refused at 96.6C
bin/70-thermal-tune.sh measure 300   # re-measure any time; expect 2400MHz flat
```

**Still waiting on parts:**

| Waiting for | Unblocks | Notes |
|---|---|---|
| RTC cell (ML2020) | off-grid timekeeping | `J5`/`BATT` is EMPTY. Charging stays **disabled** until a known-rechargeable cell is fitted. |
| QLG2 GPS | sub-second time for FT8 | **Jumper it to 3.3V logic first** — 5V default will damage a Pi GPIO. `bin/50-doomsday-extras.sh time`. |

**Open decisions:**

- **JTDX**: operator does not intend to use it. It is a WSJT-X fork, so it
  duplicates the fallback rather than adding one. `sudo apt remove jtdx` plus
  dropping its (verified-working) rules, when confirmed.
- **`mariadbd`** is enabled and burns 7-11% CPU at idle with no user databases
  on the machine. `systemctl disable --now mariadb` is free heat and RAM.
- Do NOT cap `arm_freq` — measured, does not help (DESIGN §6.4).

**If niri ever fails to come up:** there is no greeter to fall back to. ssh in,
or Ctrl+Alt+F1..F6, then `bin/90-set-session.sh labwc && sudo systemctl restart lightdm`.
