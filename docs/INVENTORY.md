# Inventory, captured 2026-08-31

This is a snapshot of the machine as found, before any of this repo ran. It's kept
for diffing, not as a description of the deck today, two rows below (cooling, and the
AI stack) describe problems that are since fixed, and they're flagged where they appear.
Re-run the commands to diff against the current state.

## Hardware

| | |
|---|---|
| Board | Raspberry Pi 5 Model B Rev 1.0 (BCM2712) |
| RAM | 7.9 GiB + 2 GiB zram swap |
| Root disk | NVMe `NE-512` 476.9G, `nvme0n1p2` (468G, 161G used, 37%) on `/` |
| Boot | `nvme0n1p1` 512M on `/boot/firmware` |
| Also present | `mmcblk0` 238.3G SD card, unmounted, unused |
| Display | HDMI-A-1, RTK CX101, 1280x800@59.996, 220x130mm (~148 DPI) |
| | HDMI-A-2 disconnected |
| Input | `TSTP MTouch` USB touchscreen + `TSTP MTouch` USB keyboard (same device, 2 interfaces) |
| Audio | `vc4hdmi0`, `vc4hdmi1`. HDMI playback only, no capture device |
| GPU | vc4-drm / v3d, Mesa 26.2.0 (rpt backports) |
| Cooling | As found: NONE, no fan, idling 88-90°C, throttled to 1.0 GHz of 2.4. Since fixed with an active cooler under the X1001; now full 2400 MHz sustained. DESIGN §4. |

`config.txt` highlights: `dtoverlay=vc4-kms-v3d`, `max_framebuffers=2`,
`disable_fw_kms_setup=1`, `dtparam=audio=on`, `dtparam=nvme`,
`dtparam=pciex1_gen=3`, `arm_boost=1`.

## OS

- Debian 13 trixie (Raspberry Pi OS), aarch64
- Sources: deb.debian.org trixie + trixie-updates + trixie-security,
  archive.raspberrypi.com trixie
- Desktop: labwc under lightdm, with `wf-panel-pi` and `pcmanfm`
- `apt list --upgradable`: 0
- Kernel running 6.12.62, staged 6.18.39 (installed 19:53, boot img
  written 19:59, machine booted before that). 6.12.47 + 6.12.62 retained.
- `rpi-eeprom-update`: UPDATE AVAILABLE
- Passwordless sudo: yes. Groups include `gpio i2c spi render input dialout`.

## Not in any reachable repo

Probed trixie, trixie-updates, trixie-backports (temporarily enabled), and
archive.raspberrypi.com:

- niri, absent
- xwayland-satellite, absent
- mshv, absent (`/usr/include/linux/mshv.h` is the Microsoft Hypervisor
  header, an unrelated name collision)

Present and used: `foot` 1.21, `fuzzel` 1.12, `waybar` 0.12, `swaybg`,
`swayidle`, `gtklock` 4.0, `mako-notifier` 1.10, `cliphist` 0.5,
`wl-clipboard`, `wmctrl`, `seatd` 0.9, `xwayland` 24.1.6,
`xdg-desktop-portal-{wlr,gtk}`, `qtwayland5` (installed),
`rustc`/`cargo` 1.85 (too old for niri, see DESIGN §8).

## Ham radio stack (installed)

`wsjtx` 2.7.0 · `jtdx` 2.2.159 · `fldigi` · `flrig` · `js8call` · `chirp` ·
`direwolf` · `gqrx-sdr` · `gnuradio` 3.10.12 · `gpredict` · `kiwix`

Configs in `~/.config`: `WSJT-X.ini`, `gqrx`, `gnuradio`, `pat`, `MoeTronix`,
`kiwix-desktop`, `kanshi` (empty), `wf-panel-pi`, `labwc`.

WSJT-X and JTDX both link Qt5.

## Offline reference material

`~/kiwix-share`, 42 ZIM files, 123 GB:

- `wikipedia_en_all_maxi_2023-05`, full Wikipedia with images
- `wikibooks`, `wikiversity`, `rationalwiki` (all `_maxi`, 2021-03)
- StackExchange: ham, electronics, security, DIY, 3dprinting (2023)
- Prepper: `zimgit-knots`, `zimgit-food-preparation` (2023)
- ~30 Khan Academy video sets (math, physics, chem, bio, CS, crypto, history)

`~/Bookshelf`, only 13 MB: three PDFs (Raspberry Pi Beginner's Guide,
two C programming books). The survival material is all in the ZIMs.

## AI stack

- `~/mistral-7b-instruct-v0.3-q4_k_m.gguf`, `~/q4_0-orca-mini-3b.gguf`
- `~/ai.py`, `~/codeai.py`, near-identical `llama_cpp` REPLs, both pointing at the 3B
- `~/venv` with a working `llama_cpp_python` 0.3.16, plus torch 2.10 and transformers 5.2
- No ollama, no llama-server

I first recorded this as "BROKEN" on a `ModuleNotFoundError`, and that was wrong,
the error came from running `~/ai.py` with the *system* python instead of
`~/venv/bin/python`. The venv was fine the whole time. Replaced by
`files/ai/ask-local.py` (installed as `ask-local`), and `llama-server` is the real
upgrade. DESIGN §10.
