#!/usr/bin/env python3
"""The deck's launcher page: every local resource, reachable with a finger.

WHY THIS EXISTS. The deck has a touchscreen and a keyboard and no mouse, and
every way into anything is currently a keybind. That is fine with the Perixx
plugged in and useless without it. This serves one page on 127.0.0.1:8000 that
lists what is running, what can be launched, and what is readable offline, with
targets a finger can actually hit. The panel is 1280 px across 220 mm, which is
5.8 px/mm, so nothing tappable here is under 56 px (about 9.6 mm).

WHY IT IS A SERVER AND NOT A STATIC FILE. Two reasons, both about not rotting:

  - The book list comes from kiwix-serve's own OPDS catalogue on :8080, so it
    cannot disagree with what is actually being served. There are 300 books
    registered as of 2026-09-29 and the README still says 42; a hand-maintained
    list on this machine has already been proven wrong once.
  - Service state is probed at render time. A dead service shows as dead rather
    than as a link that fails after you tap it. llama-server was found stopped
    on 2026-09-29 while Mod+A still pointed cheerfully at :8081.

WHY IT CAN SPAWN PROCESSES, AND THE TRAP THAT COMES WITH IT. Links alone do not
help: the things a finger most needs to reach on this deck are native apps, and
fuzzel has no touch story at all. So POST /spawn runs one of a fixed list of
commands through `niri msg action spawn`. The list is a dict in this file, not a
parameter, and nothing the client sends is ever passed to a shell.

That endpoint is still reachable by any page loaded in the same browser, and
this browser reads ZIMs, which are arbitrary third-party HTML out of a Wikipedia
dump. So a form POST from an article could otherwise launch things. The defence
is that /spawn requires the X-Deck-Launch header, which a cross-origin form
cannot set without a CORS preflight that this server refuses, and rejects any
request carrying a foreign Origin. Do not "simplify" either check away.
"""

import glob
import html
import json
import os
import re
import shutil
import socket
import subprocess
import time
import urllib.error
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

HOST = "127.0.0.1"
PORT = int(os.environ.get("DECKPAGE_PORT", "8000"))
KIWIX = "http://127.0.0.1:8080"

# --- What is on this machine -------------------------------------------------
# Ports verified listening on 2026-09-29 with `ss -ltnp`. Anything here that is
# down renders as down; nothing is assumed to be running.
SERVICES = [
    ("ZIM library",   8080, "/",       "kiwix-serve, the offline encyclopedia stack"),
    ("Local AI",      8081, "/",       "llama-server, 7B Mistral, fully offline"),
    ("APRS / DAPNET", 9333, "/",       "a2d portal"),
    ("Printing",       631, "/",       "CUPS"),
    ("gpsd",          2947, None,      "GPS and 1PPS, feeds chrony"),
]

# Launchable apps. Filtered by shutil.which at render time, so a tile never
# offers something that is not installed. Keys are opaque ids sent by the page;
# the argv is never built from anything the client says.
LAUNCH = {
    "mshv":     (["mshv"],          "MSHV",        "FT8/FT4, primary"),
    "wsjtx":    (["wsjtx"],         "WSJT-X",      "FT8/FT4, fallback"),
    "js8call":  (["js8call"],       "JS8Call",     "keyboard-to-keyboard"),
    "fldigi":   (["fldigi"],        "fldigi",      "PSK31, RTTY, Olivia"),
    "flrig":    (["flrig"],         "flrig",       "rig control"),
    "gqrx":     (["gqrx"],          "gqrx",        "SDR receiver"),
    "xastir":   (["xastir"],        "xastir",      "APRS and maps"),
    "gpredict": (["gpredict"],      "gpredict",    "satellite tracking"),
    "qmapshack":(["qmapshack"],     "QMapShack",   "offline Garmin maps"),
    "klog":     (["klog"],          "KLog",        "logging"),
    "tqsl":     (["tqsl"],          "TQSL",        "LoTW signing"),
    "kiwix":    (["kiwix-desktop"], "Kiwix",       "the desktop reader"),
    "term":     (["foot"],          "Terminal",    "foot"),
}

# Directories worth reaching without typing a path. Missing ones are dropped.
PLACES = [
    ("~/kiwix-share",          "ZIM files"),
    ("~/maps",                 "Map data"),
    ("~/flipper",              "Flipper Zero"),
    ("~/radio-data",           "Radio reference data"),
    ("~/cyberdeck/docs",       "This deck's own docs"),
    ("~/Pictures/Screenshots", "Screenshots"),
]

# --- Probes ------------------------------------------------------------------

def listening(port):
    """True if something is accepting connections on 127.0.0.1:port."""
    try:
        with socket.create_connection((HOST, port), timeout=0.25):
            return True
    except OSError:
        return False


_catalogue = {"at": 0.0, "books": []}


def catalogue():
    """Books from kiwix-serve's OPDS feed, cached for five minutes.

    Parsed with a regex rather than ElementTree on purpose: the feed carries
    three namespaces and a <name> element that is not in the Atom namespace,
    and the fields wanted here are flat text. Failure returns an empty list, so
    a stopped kiwix-serve renders as "library unavailable" instead of a stack
    trace.
    """
    now = time.time()
    if now - _catalogue["at"] < 300 and _catalogue["books"]:
        return _catalogue["books"]
    try:
        with urllib.request.urlopen(
            KIWIX + "/catalog/v2/entries?count=-1", timeout=5
        ) as r:
            xml = r.read().decode("utf-8", "replace")
    except (urllib.error.URLError, OSError, TimeoutError):
        return []

    books = []
    for entry in re.findall(r"<entry>(.*?)</entry>", xml, re.S):
        def field(name, default=""):
            m = re.search(r"<%s>(.*?)</%s>" % (name, name), entry, re.S)
            return html.unescape(m.group(1).strip()) if m else default

        href = re.search(r'<link type="text/html"\s+href="([^"]+)"', entry)
        if not href:
            continue
        tags = [t for t in field("tags").split(";") if t and not t.startswith("_")]
        try:
            count = int(field("articleCount", "0") or 0)
        except ValueError:
            count = 0
        books.append({
            "title": field("title"),
            "url": KIWIX + href.group(1),
            "articles": count,
            "tags": tags,
        })
    _catalogue.update(at=now, books=books)
    return books


def clock_status():
    """One line about what is disciplining the clock.

    This is the cheap half of the waybar GPS widget: chrony names its selected
    source, and a PPS refid is the difference between microseconds off a GPIO
    edge and tens of milliseconds off the network. See DESIGN §9.
    """
    try:
        out = subprocess.run(
            ["chronyc", "-n", "tracking"], capture_output=True, text=True, timeout=3
        ).stdout
    except (OSError, subprocess.SubprocessError):
        return "clock: chronyc unavailable", "warn"
    refid = re.search(r"Reference ID\s*:\s*(\S+)(?:\s*\((.*?)\))?", out)
    stratum = re.search(r"Stratum\s*:\s*(\d+)", out)
    leap = re.search(r"Leap status\s*:\s*(.+)", out)
    # Caught on the panel after the 2026-09-29 reboot, which is the only way it
    # would have been caught: for the first half minute chrony answers with
    # refid 00000000, stratum 0 and "Leap status: Not synchronised", and the
    # code below happily reported that as a healthy network source. An unsynced
    # clock is the one state this line exists to make visible, so it is checked
    # first and by three signals, not by whether the regex matched.
    unsynced = (
        not refid
        or refid.group(1) in ("00000000", "0.0.0.0")
        or (stratum and stratum.group(1) == "0")
        or (leap and "not synchronised" in leap.group(1).strip().lower())
    )
    if unsynced:
        return "clock: NOT SYNCHRONISED", "err"
    name = (refid.group(2) or refid.group(1)).strip()
    s = stratum.group(1) if stratum else "?"
    if "PPS" in name.upper():
        return "clock: PPS, stratum %s (GPS disciplined)" % s, "ok"
    return "clock: %s, stratum %s (network, GPS not selected)" % (name, s), "warn"


def places():
    out = []
    for path, label in PLACES:
        full = os.path.expanduser(path)
        if os.path.isdir(full):
            out.append((label, "file://" + full, path))
    return out


def launchable():
    return [(k, v) for k, v in LAUNCH.items() if shutil.which(v[0][0])]


def status():
    rows = []
    for name, port, path, note in SERVICES:
        up = listening(port)
        rows.append({
            "name": name, "port": port, "note": note, "up": up,
            "url": ("http://%s:%d%s" % (HOST, port, path)) if (path and up) else None,
        })
    return rows

# --- The page ----------------------------------------------------------------
# Norton Utilities / DirectoryMaster styling: one surface colour, bevels for
# separation, cyan inversion for the title and status bars, alert colours kept
# for [!] / [OK] / [X].
#
# Three places where the house style lost to legibility, all measured rather
# than argued, because this is a thing to use in the dark at arm's length and
# not a thing to look at:
#
#   The CRT edge fade is GONE. It is the signature of the theme and it is also
#   80 px of gradient plus the padding to clear it, which on a 1272 px viewport
#   is a whole grid column of tiles traded for an effect.
#
#   Muted text is #aaaaff, not the theme's #5555ff. #5555ff on #000080 measures
#   3.15:1, under the 4.5:1 small-text floor; #aaaaff is 7.55:1. FinkBot's kiosk
#   already uses this exact value, so it is in family rather than invented.
#
#   DejaVu Sans Mono leads the font stack. There is no Courier New on this
#   machine (checked with fc-list), so asking for it gets the Nimbus Mono PS
#   substitute, whose strokes are thin at 13 px on a 148 DPI panel.

CSS = """
:root {
  --navy:#000080; --cyan:#00ffff; --white:#ffffff; --black:#000000;
  --bevel-light:#5555ff; --bevel-dark:#000000;
  --warn:#ffff00; --ok:#00ff00; --err:#ff0000;
  --muted:#aaaaff;
  --mono:'DejaVu Sans Mono','Noto Sans Mono','Courier New',monospace;
}
*,*::before,*::after{box-sizing:border-box}
html,body{margin:0;padding:0}
body{
  background:var(--navy); color:var(--white); font-family:var(--mono);
  font-size:16px; line-height:1.35; padding:10px 14px 44px 14px;
  -webkit-text-size-adjust:100%;
}
.nb{border-top:2px solid var(--bevel-light);border-left:2px solid var(--bevel-light);
    border-bottom:2px solid var(--bevel-dark);border-right:2px solid var(--bevel-dark)}
.nbi{border-top:2px solid var(--bevel-dark);border-left:2px solid var(--bevel-dark);
     border-bottom:2px solid var(--bevel-light);border-right:2px solid var(--bevel-light)}
h1{margin:0 0 10px 0;background:var(--cyan);color:var(--navy);font-size:16px;
   text-transform:uppercase;letter-spacing:2px;padding:6px 10px;font-weight:bold}
h2{margin:18px 0 8px 0;color:var(--cyan);font-size:14px;text-transform:uppercase;
   letter-spacing:2px;font-weight:bold}
h2::before{content:'\\25BA  '}
.grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(240px,1fr));gap:8px}
/* 56 px is 9.6 mm at this panel's 5.8 px/mm. Nothing tappable goes under it. */
.tile{display:flex;flex-direction:column;justify-content:center;min-height:56px;
      padding:8px 10px;background:var(--navy);color:var(--white);
      text-decoration:none;font-family:var(--mono);font-size:15px;text-align:left;
      cursor:pointer;width:100%}
.tile:active,.book:active{border-top-color:var(--bevel-dark);border-left-color:var(--bevel-dark);
             border-bottom-color:var(--bevel-light);border-right-color:var(--bevel-light)}
.tile .t{color:var(--cyan);font-weight:bold;overflow-wrap:anywhere}
.tile .s{font-size:13px;color:var(--muted);overflow-wrap:anywhere}
.tile.down{opacity:.65}
.tile.down .t{color:var(--muted)}
.mark{font-weight:bold}
.ok{color:var(--ok)} .warn{color:var(--warn)} .err{color:var(--err)}
.bar{position:fixed;left:0;right:0;bottom:0;background:var(--cyan);color:var(--black);
     font-weight:bold;font-size:13px;padding:5px 14px;z-index:101;
     display:flex;gap:18px;flex-wrap:wrap}
.books{display:grid;grid-template-columns:repeat(auto-fill,minmax(300px,1fr));gap:6px}
.book{display:flex;justify-content:space-between;gap:10px;min-height:56px;
      align-items:center;padding:6px 10px;text-decoration:none;color:var(--white)}
/* NO :hover STYLING AT ALL, which is deliberate and was arrived at the hard
   way. The cyan inversion was first put behind @media (hover:hover), on the
   theory that a touchscreen would report hover:none and skip it. It does not:
   Chromium answers hover:hover whenever ANY pointer exists, and this deck's
   pointer is the panel, which (as config.kdl says) teleports to the last tap
   and stays there. So the first boot after this shipped had a tile latched
   cyan under a finger that had moved on, reading as a selection that was not
   one. Feedback is :active and :focus-visible only, both of which end when the
   interaction does. */
.tile:focus-visible,.book:focus-visible{outline:3px solid var(--cyan);outline-offset:-3px}
.book .n{color:var(--muted);font-size:13px;white-space:nowrap}
.empty{padding:10px;color:var(--warn)}
"""

JS = """
function launch(key, el){
  var was = el.querySelector('.s').textContent;
  el.querySelector('.s').textContent = 'starting...';
  fetch('/spawn', {
    method:'POST',
    headers:{'Content-Type':'application/json','X-Deck-Launch':'1'},
    body: JSON.stringify({app:key})
  }).then(function(r){ return r.json(); }).then(function(j){
    el.querySelector('.s').textContent = j.ok ? 'started' : ('failed: ' + j.error);
    setTimeout(function(){ el.querySelector('.s').textContent = was; }, 2500);
  }).catch(function(e){
    el.querySelector('.s').textContent = 'failed: ' + e;
  });
}
"""


def tile(title, sub, href=None, onclick=None, cls=""):
    inner = ('<span class="t">%s</span><span class="s">%s</span>'
             % (html.escape(title), html.escape(sub)))
    if href:
        return '<a class="tile nb %s" href="%s">%s</a>' % (cls, html.escape(href), inner)
    return '<button class="tile nb %s" onclick="%s">%s</button>' % (cls, onclick, inner)


def render():
    books = catalogue()
    parts = ['<!DOCTYPE html><html lang="en"><head><meta charset="utf-8">',
             '<meta name="viewport" content="width=device-width,initial-scale=1">',
             '<title>Cyberdeck</title><style>%s</style><script>%s</script>' % (CSS, JS),
             '</head><body>',
             '<h1>Cyberdeck: local resources</h1>']

    # Services
    parts.append('<h2>Running here</h2><div class="grid">')
    for s in status():
        mark = '<span class="mark ok">[OK]</span>' if s["up"] else '<span class="mark err">[X]</span>'
        sub = "%s  :%d  %s" % ("up" if s["up"] else "down", s["port"], s["note"])
        t = '<span class="t">%s %s</span><span class="s">%s</span>' % (
            mark, html.escape(s["name"]), html.escape(sub))
        cls = "" if s["up"] else "down"
        if s["url"]:
            parts.append('<a class="tile nb %s" href="%s">%s</a>' % (cls, s["url"], t))
        else:
            parts.append('<div class="tile nb %s">%s</div>' % (cls, t))
    parts.append('</div>')

    # Launchers
    apps = launchable()
    if apps:
        parts.append('<h2>Launch</h2><div class="grid">')
        for key, (_argv, label, note) in apps:
            parts.append(tile(label, note, onclick="launch('%s',this)" % key))
        parts.append('</div>')

    # Library
    parts.append('<h2>Library</h2>')
    if not books:
        parts.append('<div class="empty nb">[!] kiwix-serve is not answering on :8080. '
                     'Start it with: systemctl --user start kiwix-serve</div>')
    else:
        groups = {}
        for b in books:
            for t in b["tags"]:
                groups.setdefault(t, []).append(b)
        # Collections first, as one tile each, so 231 devdocs books do not bury
        # the encyclopedia. Then the biggest individual books by article count.
        parts.append('<div class="grid">')
        parts.append(tile("Everything", "%d books, kiwix catalogue" % len(books),
                          href=KIWIX + "/"))
        for name, label in (("devdocs", "Developer docs"), ("khan", "Khan Academy"),
                            ("stack_exchange", "Stack Exchange"),
                            ("gutenberg", "Project Gutenberg"),
                            ("preppers", "Preppers")):
            if len(groups.get(name, [])) > 1:
                # FRAGMENT, not query string. kiwix-serve's welcome page reads
                # its filters out of window.location.hash (its index.js defines
                # `class FragmentParams extends URLSearchParams` and pushes
                # `#tag=...` when you click a tag), so /catalog/v2/entries?tag=
                # is the raw OPDS feed and a browser shows it as XML source.
                # That is exactly what it did on the deck on 2026-09-29.
                parts.append(tile(label, "%d books" % len(groups[name]),
                                  href=KIWIX + "/#tag=" + name))
        parts.append('</div>')

        singles = sorted((b for b in books if "devdocs" not in b["tags"]),
                         key=lambda b: -b["articles"])[:14]
        parts.append('<div class="books" style="margin-top:8px">')
        for b in singles:
            parts.append('<a class="book nb" href="%s"><span class="t">%s</span>'
                         '<span class="n">%s</span></a>'
                         % (html.escape(b["url"]), html.escape(b["title"]),
                            "{:,}".format(b["articles"])))
        parts.append('</div>')

    # Places
    pl = places()
    if pl:
        parts.append('<h2>On disk</h2><div class="grid">')
        for label, url, path in pl:
            parts.append(tile(label, path, href=url))
        parts.append('</div>')

    msg, cls = clock_status()
    parts.append('<div class="bar"><span>%s</span>'
                 '<span>Mod+O overview</span><span>Mod+1 here</span>'
                 '<span>f = link hints</span></div>' % html.escape(msg))
    parts.append('</body></html>')
    return "".join(parts)

def niri_env():
    """Environment for `niri msg`, with the socket found rather than assumed.

    niri-session imports NIRI_SOCKET into the systemd user environment, so a
    unit started by graphical-session.target normally inherits it. Normally is
    not always: the value embeds the compositor PID (niri.wayland-1.1298.sock),
    so it goes stale if niri is restarted without a fresh import, and it is
    absent entirely if this is ever run by hand over ssh. That second case is
    how the bug was found, on 2026-09-29, with a spawn that came back "NIRI_
    SOCKET is not set, are you running this within niri?".

    So: trust the variable if it points at a socket that exists, otherwise take
    the newest one in XDG_RUNTIME_DIR, which is what bin/sync-to-pi.sh does for
    the same reason.
    """
    env = dict(os.environ)
    sock = env.get("NIRI_SOCKET")
    if sock and os.path.exists(sock):
        return env
    runtime = env.get("XDG_RUNTIME_DIR") or "/run/user/%d" % os.getuid()
    found = sorted(glob.glob(os.path.join(runtime, "niri.*.sock")),
                   key=os.path.getmtime, reverse=True)
    if found:
        env["NIRI_SOCKET"] = found[0]
    return env


# --- Server ------------------------------------------------------------------


class Handler(BaseHTTPRequestHandler):
    server_version = "deckpage"

    def log_message(self, fmt, *args):
        pass  # journald already timestamps; the default access log is noise.

    def _send(self, code, body, ctype="text/html; charset=utf-8"):
        raw = body.encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(raw)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(raw)

    def do_GET(self):
        path = self.path.split("?", 1)[0]
        if path == "/":
            self._send(200, render())
        elif path == "/status.json":
            msg, cls = clock_status()
            self._send(200, json.dumps({"services": status(), "clock": msg,
                                        "clock_state": cls}),
                       "application/json")
        else:
            self._send(404, "not found", "text/plain; charset=utf-8")

    def do_POST(self):
        if self.path.split("?", 1)[0] != "/spawn":
            self._send(404, '{"ok":false,"error":"not found"}', "application/json")
            return

        # See the module docstring. A ZIM article is third-party HTML in this
        # same browser, and a plain <form> POST from one would otherwise reach
        # this endpoint. A custom header cannot be set cross-origin without a
        # preflight, and this server answers no OPTIONS, so requiring it is the
        # whole defence. The Origin check catches the same thing from fetch().
        if self.headers.get("X-Deck-Launch") != "1":
            self._send(403, '{"ok":false,"error":"missing launch header"}',
                       "application/json")
            return
        origin = self.headers.get("Origin")
        if origin and origin not in ("http://%s:%d" % (HOST, PORT),
                                     "http://localhost:%d" % PORT):
            self._send(403, '{"ok":false,"error":"bad origin"}', "application/json")
            return

        try:
            n = int(self.headers.get("Content-Length", "0"))
            body = json.loads(self.rfile.read(min(n, 4096)) or b"{}")
            key = body.get("app", "")
        except (ValueError, OSError):
            self._send(400, '{"ok":false,"error":"bad request"}', "application/json")
            return

        entry = LAUNCH.get(key)
        if not entry:
            self._send(400, '{"ok":false,"error":"unknown app"}', "application/json")
            return

        argv, _label, _note = entry
        try:
            r = subprocess.run(["niri", "msg", "action", "spawn", "--"] + argv,
                               capture_output=True, text=True, timeout=10,
                               env=niri_env())
        except (OSError, subprocess.SubprocessError) as e:
            self._send(500, json.dumps({"ok": False, "error": str(e)}),
                       "application/json")
            return
        if r.returncode != 0:
            self._send(500, json.dumps(
                {"ok": False, "error": (r.stderr or r.stdout).strip()[:200]}),
                "application/json")
            return
        self._send(200, '{"ok":true}', "application/json")


def main():
    # Socket discovery lives in niri_env(), not here: `niri msg` does NOT find
    # the socket by itself, which is the opposite of what this comment used to
    # claim and was caught by testing the endpoint rather than reading it.
    srv = ThreadingHTTPServer((HOST, PORT), Handler)
    srv.serve_forever()


if __name__ == "__main__":
    main()
