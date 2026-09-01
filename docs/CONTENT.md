# Content gaps — what this deck is missing

Assessed 2026-08-31 against the 42 ZIMs / 123 GB already in `~/kiwix-share`.
Free space: **287 GB**, so most of this fits comfortably.

Browse and download: <https://library.kiwix.org> · `kiwix-manage` to add to the library.

## First: the "survival manuals" are not actually on this machine

`~/Bookshelf` is **13 MB** — three PDFs: the Raspberry Pi Beginner's Guide and
two C programming books. Whatever survival manual collection was intended here,
it is not present. Everything genuinely survival-oriented is inside the ZIMs
(`zimgit-knots`, `zimgit-food-preparation`) and there are only two of those.

## Priority gaps

| Priority | ZIM | Why |
|---|---|---|
| **1** | `wikipedia_en_medicine_maxi` (WikiMed) | **There is no medical reference on this deck at all.** Largest single gap by a wide margin. |
| **1** | `zimgit-medicine_en` | Prepper-oriented practical medicine; complements WikiMed's clinical framing. |
| **2** | `zimgit-post-disaster_en` | Water purification, sanitation, shelter. The gap between "knots" and "food prep". |
| **2** | `ifixit_en_all` | Repair guides with photos. You have DIY StackExchange but not iFixit; they are not substitutes. |
| **3** | `wikihow_en_maxi` | Practical step-by-step how-to. Broad, shallow, useful. |
| **3** | `appropedia_en_all` | Appropriate technology — low-tech water, power, agriculture, construction. |
| **4** | `gutenberg_en_all` | ~60k public domain books. Morale and reference both. |
| **4** | `wikispecies` / foraging refs | Plant and animal identification. |
| **5** | `wikivoyage_en_all_maxi` | Geographic and practical regional detail Wikipedia omits. |

## Maps — the other thing Wikipedia does not cover

No offline mapping exists on this deck. A survival machine that cannot answer
"where am I, what is around me, how do I get there" has a real hole.

- Viewers: `qmapshack` (best offline support), `viking`, `marble` —
  `bin/50-doomsday-extras.sh maps` installs them.
- **Data is the part that matters and must be fetched in advance.** Get an
  OpenStreetMap regional extract from <https://download.geofabrik.de> for your
  state/region. Budget a few GB.
- Pair with a USB GPS — see the `time` tier, which you want anyway.

## Time — two parts, both cheap

### Part 1: RTC backup cell — connector present, currently EMPTY

The Pi 5 has a built-in RTC (`rtc0: rpi-rtc`, confirmed) and a `J5`/`BATT`
2-pin JST-SH connector beside the USB-C input. Without a cell, an off-grid deck
boots with no idea what time it is.

**Status 2026-08-31: no cell fitted, and trickle charging is DISABLED.**

A salvaged cell was briefly fitted and then removed. It carried a `2016.07.11`
date code and an OEM part number, hand-taped with soldered leads — chemistry
unidentifiable. `dtparam=rtc_bbat_vchg` was added and then **immediately
reverted**: charging an unknown cell risks venting if it turns out to be a
CR/BR primary or a 3.6V lithium thionyl chloride rather than a rechargeable
ML/VL type. Charging a non-rechargeable coin cell is a genuine hazard, not a
theoretical one.

**Buy the actual Raspberry Pi RTC Battery (~£5).** It is an ML2020
rechargeable, ships with the correct 2-pin JST plug and an adhesive pad, and is
the only cell it is safe to enable charging on. Then, and only then:

    dtparam=rtc_bbat_vchg=3000000     # 3.0V; charger is CC 3mA, limits 1.3-4.4V

written to the **NVMe** config.txt (DESIGN §7). Verify with
`cat /sys/class/rtc/rtc0/charging_voltage` — 0 means disabled.

Note the `battery_voltage` sysfs reading is not a trustworthy health check: it
was observed fluctuating (5982, then 6837) in units that do not correspond to a
3V cell. **The only real test is a full power-off** — unplug, wait, boot with
the network disconnected, and see whether the clock is right.

### Part 2: GPS discipline — see `bin/50-doomsday-extras.sh time`

Not content, but it belongs on this list because it is the one gap that
silently breaks a core function. FT8 needs sub-second time. This deck gets
that from **NTP over the internet**. No internet, no NTP, clock drifts, FT8
stops decoding within days. A USB GPS + `gpsd` + `chrony` fixes it, and both
daemons are already installed.

## Local AI — currently broken

`~/mistral-7b-instruct-v0.3-q4_k_m.gguf` and `~/q4_0-orca-mini-3b.gguf` are
present but `llama_cpp` is not installed, so `ai.py` / `codeai.py` both raise
`ModuleNotFoundError`. This is the deck's *actual* offline AI story — Claude
Code needs the internet and is a workstation tool, not a survival one.

Worth doing properly: build `llama.cpp` with a `llama-server` systemd unit, so
the 7B Mistral is reachable from a browser alongside Kiwix. On 8 GB of RAM a
Q4_K_M 7B is comfortable. **Do this after fitting a fan** (DESIGN §6) —
inference is sustained all-core load.
