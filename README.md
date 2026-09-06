# cyberdeck

![Platform](docs/badges/platform.svg)
![OS](docs/badges/os.svg)
![Compositor](docs/badges/compositor.svg)
![Shell](docs/badges/shell.svg)
![Install](docs/badges/install.svg)
![Thermal](docs/badges/thermal.svg)
![Case](docs/badges/case.svg)

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
| `bin/40-install-claude-code.sh` | Claude Code under `~/.local/share/claude` |
| `bin/50-doomsday-extras.sh` | tiered offline extras — run bare to list the tiers |
| `bin/51-fetch-content.sh` | fetch ZIMs, register them in the kiwix library |
| `bin/52-kiwix-serve.sh` | `kiwix-serve` unit on `127.0.0.1:8080` (read in qutebrowser) |
| `bin/53-radio-data.sh` | ham reference data — `cty.dat` and friends |
| `bin/54-maps.sh` | TIGER shapefiles for Xastir + an offline-built Garmin `.img` |
| `bin/55-fetch-computing.sh` | computing/reference ZIM tier |
| `bin/56-flipper.sh` | qflipper + clone the existing flipper repo onto the deck |
| `bin/60-local-ai.sh` | `llama-server` on `127.0.0.1` + `files/ai/ask-local.py` |
| `bin/70-thermal-tune.sh` | `measure [secs]` — sustained-load thermal profile |
| `bin/80-check-boot-integrity.sh` | run after ANY disk/clone change |
| `bin/90-set-session.sh` | flip the boot session between `niri` and `labwc` |
| `bin/91-tidy-units.sh` | trim units that only make sense under the Pi desktop |
| `bin/deploy-config.sh` | symlink configs into `~/.config` |
| `bin/sync-to-pi.sh` | push this repo to the deck, validate the KDL, live-reload |
| `bin/verify-post-reboot.sh` | run after any kernel change |

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

- `DESIGN.md` — the reasoning. §6 is the thermal story, start to finish.
- `docs/CASE.md` — the enclosure. **Where the active work is.**
- `docs/design/*.scad` — the parts, with the cross-part assertions that gate them
  (`docs/design/build.sh` builds and checks all sixteen).
  *`faceplate.svg` is superseded and wrong — CASE §13.*
- `docs/INVENTORY.md` — full baseline capture.
- `docs/CONTENT.md` — offline content gaps (medical, maps, repair) and the
  GPS-time problem that silently breaks FT8 off-grid.

## Where this was left — 2026-09-02

**The software deck is done.** It boots into niri (`autologin-session=niri`).
niri 26.04, xwayland-satellite 0.8.2 and MSHV 2.76.7 are built and installed;
configs are symlinked and validated. Every window rule is verified against real
app-ids from `niri msg windows` — no guesses remain.

**Thermal: SOLVED.** An active cooler under the X1001 took the deck from 1500 MHz
sustained (throttled, 80.1 °C at idle) to the **full 2400 MHz, closed case,
peaking at 76.8 °C with zero throttle bits** (DESIGN §6.8). The fan appears as
`cooling_device0` and ramps 3602 -> 9950 rpm. 75 °C is a fan-speed trip point,
not a throttle point; throttling starts at 85 °C. Do NOT cap `arm_freq` —
measured, does not help (DESIGN §6.4).

```sh
bin/60-local-ai.sh                   # llama-server; was refused at 96.6C
bin/70-thermal-tune.sh measure 300   # re-measure any time; expect 2400MHz flat
```

**FT8 software: DECIDED — MSHV** (DESIGN §3). JTDX is a WSJT-X fork, so it
duplicates the fallback rather than adding one; `sudo apt remove jtdx` plus
dropping its (verified-working) rules, when confirmed.

**The case is the open work** (`docs/CASE.md`). As of **2026-09-06** the Pelican
1400 is **in hand and surveyed**, every part is bought, and the deck is
**printing**. The JUNEBOX module is the whole computer (Pi + NVMe inside its
backboard, 12 V in, VESA 75/100, own fan), so the build is module + keyboard +
LiFePO4 pack.

Printed and checked: three connector coupons, the joint coupon, and the module
plinth. Ready to print: the whole faceplate except the right rail, plus the floor
tray, battery blocks and terminal shroud. Blocked: the right rail (waiting on the
RJ45's ear spacing) and the Powerpole retainer (needs four measurements off a
housing). See **CASE.md § Build status** for the live list.

| Open | Blocks | Notes |
|---|---|---|
| ~~The 1400's **real flat floor width**~~ | ~~CAD, faceplate rails~~ | **RESOLVED 2026-09-04.** The catalog 300 mm was wrong twice over: the interior at the rib shelf is **305 × 231.4**, and the plate rides that shelf rather than the floor. Plate is **304.5 × 230.5**. CASE §6. |
| RTC cell (ML2020) | off-grid timekeeping | `J5`/`BATT` is EMPTY. Charging stays **disabled** until a known-rechargeable cell is fitted. |
| QLG2 GPS | sub-second time for FT8 | **Jumper it to 3.3V logic first** — 5V default will damage a Pi GPIO. `bin/50-doomsday-extras.sh time`. |

**Free win, not yet taken:** `mariadbd` is enabled and burns 7-11% CPU at idle
with no user databases on the machine. `systemctl disable --now mariadb`.

**If niri ever fails to come up:** there is no greeter to fall back to. ssh in,
or Ctrl+Alt+F1..F6, then `bin/90-set-session.sh labwc && sudo systemctl restart lightdm`.
