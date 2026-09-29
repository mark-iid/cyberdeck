#!/usr/bin/env bash
# The launcher page: one screen listing every local resource on the deck.
#
# THE PROBLEM THIS SOLVES. Everything on this machine is reachable by keybind
# and almost nothing is reachable by finger. Mod+B is the ZIM library, Mod+A is
# the local model, Mod+M and Mod+N are the FT8 programs, and all of that assumes
# the Perixx is plugged in. It usually is. When it is not, the deck is a
# touchscreen with no way into anything, and fuzzel cannot help because it wants
# you to type. So: one page, served locally, with targets a finger can hit.
#
# It also fixes a smaller thing that had already gone wrong. The keybinds point
# at services whether or not they are running: on 2026-09-29 llama-server was
# stopped and disabled while Mod+A still opened :8081 and produced a connection
# error. The page probes before it links, so a dead service reads as dead.
#
# WHAT IT SERVES. files/www/deckpage.py, on 127.0.0.1:8000. Book list pulled
# live from kiwix-serve's OPDS catalogue on :8080 (300 books registered as of
# today, which is why the list is generated and not typed). Launch tiles POST to
# a fixed allowlist in that file and go out through `niri msg action spawn`.
# Read the module docstring before touching the /spawn endpoint; it is reachable
# from any ZIM article loaded in the same browser and the header check is what
# stops that mattering.
#
# Port 8000: 8080 is kiwix-serve, 8081 is llama-server, 9333 is the a2d APRS to
# DAPNET portal, 631 is CUPS, 2947 is gpsd. 8000 was the nearest thing free.

source "$(dirname "$0")/lib.sh"

REPO="$(cd "$(dirname "$0")/.." && pwd)"
PORT="${PORT:-8000}"

# No apt step. python3 is on Raspberry Pi OS already and the server is stdlib
# only: http.server, urllib, json, re. Adding flask here would mean a venv on a
# machine whose whole point is working with nothing to install from.
command -v python3 >/dev/null || die "python3 not found, which should be impossible on this image"

log "Installing deckpage to /usr/local/bin/deckpage"
sudo install -Dm755 "$REPO/files/www/deckpage.py" /usr/local/bin/deckpage

log "Writing the deckpage user unit"
install -Dm644 /dev/stdin "$HOME/.config/systemd/user/deckpage.service" <<UNIT
[Unit]
Description=Cyberdeck launcher page
# Wants, not Requires: the page is useful with kiwix-serve down (it says so, in
# yellow) and should not refuse to start because of it.
Wants=kiwix-serve.service
After=graphical-session.target

[Service]
Type=simple
Environment=DECKPAGE_PORT=${PORT}
ExecStart=/usr/local/bin/deckpage
Restart=on-failure
RestartSec=5

[Install]
# graphical-session.target, not default.target: /spawn calls \`niri msg\`, which
# needs a compositor to talk to. Starting this at login on a machine sitting in
# a text console would give a page whose launch tiles all fail.
WantedBy=graphical-session.target
UNIT

systemctl --user daemon-reload
systemctl --user enable --now deckpage.service

sleep 1
if curl -fsS -o /dev/null "http://127.0.0.1:${PORT}/"; then
    log "deckpage answering on http://127.0.0.1:${PORT}"
else
    warn "deckpage is not answering yet. Check: journalctl --user -u deckpage -n 30"
fi

echo
log "niri opens it at startup and pins it to the \"web\" workspace (Mod+1)."
log "Set it as qutebrowser's start page too, if you want every new tab to land"
log "there, by adding to ~/.config/qutebrowser/config.py:"
log "    c.url.start_pages = ['http://127.0.0.1:${PORT}']"
log "    c.url.default_page = 'http://127.0.0.1:${PORT}'"
