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

Then log out and choose **niri** in the lightdm session menu.

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
