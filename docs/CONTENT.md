# Offline content

This deck is a doomsday device *and* a radio go-box companion, which is why the ham stack
and the reference library are both treated as payload rather than extras. 123 GB of it
when I started, 49 books now, ~273 GB still free.

**Read it with `Mod+B`** — qutebrowser against kiwix-serve on :8080, press `f` for link
hints. [DESIGN §7](../DESIGN.md) explains why not kiwix-desktop.

## What's on it

Started from 42 ZIMs / 123 GB. **Medical was the largest single gap** (there was no
medical reference at all) and it's now covered from three angles: WikiMed for the
encyclopaedic view, WikEM for the emergency clinician's, and FAS Military Medicine for
austere field conditions where the first two assume a hospital.

| Added 2026-09-02 | Size |
|---|---|
| WikiMed Medical Encyclopedia | 2.06 GB |
| WikEM | ~0.5 GB |
| Military Medicine (FAS) | 0.08 GB |
| Post Disaster Resource Library | 0.65 GB |
| iFixit | 3.57 GB |
| Appropedia | 0.54 GB |
| TruePrepper | 1.33 GB |

Already present: full Wikipedia with images (`_maxi`, 2023-05), wikibooks, wikiversity,
rationalwiki, five StackExchange dumps (ham, electronics, security, DIY, 3D printing),
`zimgit-knots`, `zimgit-food-preparation`, and about 30 Khan Academy video sets.

Plus, from `55-fetch-computing.sh`: 2026 StackExchange refreshes (the deck's were 2023),
full Python docs, the Arch wiki, and the entire ~231-file devdocs collection for ~0.57 GB.
That last one is the best value-per-byte on the machine by a wide margin.

**Maps are covered too** (`54-maps.sh`): a whole-US OSM extract at 11.3 GB plus
mkgmap/osmium/gdal, so a Garmin `.img` for *any* region can be built offline without
network. TIGER2025 shapefiles for ten southwestern-PA counties feed Xastir, and there's a
prebuilt SW-PA Garmin map for QMapShack.

One trap worth repeating, because it wasted an evening: **the formats aren't
interchangeable.** QMapShack wants Garmin `.img` and will not read Mapsforge `.map`.
Xastir wants shapefiles. Fetching the wrong one gets you a viewer with nothing in it.

## `~/Bookshelf` is 13 MB, and that's the whole survival-manual collection

Three PDFs: the Raspberry Pi Beginner's Guide and two C programming books. Whatever
manual collection I thought was on here, it isn't. Everything genuinely
survival-oriented lives inside the ZIMs.

Worth knowing because it's the sort of thing you'd only discover when you needed it.

## Still missing

Browse and download at <https://library.kiwix.org>, then `kiwix-manage` to add to the
library so both front-ends see it.

| Priority | ZIM | Why |
|---|---|---|
| **3** | `wikihow_en_maxi` | Practical step-by-step how-to. Broad, shallow, useful. |
| **4** | `gutenberg_en_all` | ~60k public domain books. Morale and reference both. |
| **4** | `wikispecies` / foraging refs | Plant and animal identification. |
| **5** | `wikivoyage_en_all_maxi` | Geographic and practical regional detail Wikipedia omits. |

Nothing here is urgent. The high-priority gaps (medical, post-disaster, repair,
appropriate technology) are all closed.

## The one gap that isn't content: time

This is the gap that *silently* breaks a core function, which is why it's on this list at
all. **FT8 needs sub-second time.** The deck gets that from NTP over the internet. No
internet, no NTP, the clock drifts, and FT8 stops decoding within days — with no error
message, just a waterfall full of nothing.

Two parts, both cheap.

### Part 1: the RTC cell, and why the connector is deliberately empty

The Pi 5 has a built-in RTC (`rtc0: rpi-rtc`) and a `J5`/`BATT` 2-pin JST-SH connector
beside the USB-C input. Without a cell, an off-grid deck boots with no idea what time it
is.

**No cell is fitted and trickle charging is disabled, on purpose.** I briefly fitted a
salvaged cell — `2016.07.11` date code, an OEM part number, hand-taped with soldered
leads, chemistry unidentifiable. Added `dtparam=rtc_bbat_vchg`, then immediately reverted
it: charging an unknown cell risks venting if it turns out to be a CR/BR primary or a
3.6 V lithium thionyl chloride rather than a rechargeable ML/VL type. Charging a
non-rechargeable coin cell is a genuine hazard, not a theoretical one.

**Buy the actual Raspberry Pi RTC Battery (~$5).** It's an ML2020 rechargeable, ships with
the correct 2-pin JST plug and an adhesive pad, and it's the only cell it's safe to enable
charging on. Then, and only then:

    dtparam=rtc_bbat_vchg=3000000     # 3.0V; charger is CC 3mA, limits 1.3-4.4V

written to the **NVMe's** `config.txt` — see [DESIGN §5](../DESIGN.md) for why that needs
saying. Verify with `cat /sys/class/rtc/rtc0/charging_voltage`, where 0 means disabled.

Don't trust the `battery_voltage` sysfs reading as a health check. I watched it fluctuate
between 5982 and 6837, in units that don't correspond to a 3 V cell in any obvious way.
**The only real test is a full power-off**: unplug, wait, boot with the network
disconnected, and see whether the clock is right.

### Part 2: GPS discipline

A USB GPS plus `gpsd` and `chrony` fixes the drift properly, and both daemons are already
installed. `bin/50-doomsday-extras.sh time`.

If you use a QLG2, **jumper it to 3.3 V logic first.** The 5 V default will damage a Pi
GPIO.

## Local AI

`llama-server` on `127.0.0.1:8081`, via `bin/60-local-ai.sh`, so the 7B Mistral is
reachable from the same browser as Kiwix. On 8 GB a Q4_K_M 7B is comfortable. This is the
deck's *actual* offline AI story — Claude Code needs the internet and is a workstation
tool, not a survival one.

Two things I got wrong here and it's worth recording both:

- **I logged this as "broken" on a `ModuleNotFoundError`, and it wasn't.** `~/venv` had a
  working `llama_cpp_python` 0.3.16 the whole time; I'd run `ai.py` with the system
  python. The real faults were smaller: the system prompt was defined and never used, both
  scripts pointed at the 3B so the 4.1 GB Mistral was dead weight, the model path was
  relative so they only ran from `$HOME`, and `n_ctx` defaulted to 512 against a 2048+
  train context.
- **"Do this after fitting a fan" is now satisfied**, and it was a real blocker — one
  short inference run hit 96.6 °C on the fanless machine. With the active cooler fitted,
  7B inference sits at 82.3 °C and brushes the 85 °C soft limit without throttling hard
  ([DESIGN §4](../DESIGN.md)).
