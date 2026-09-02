#!/usr/bin/env bash
# Serve the ZIM library over HTTP and read it in a keyboard-driven browser.
#
# THE PROBLEM THIS SOLVES: this deck has a touchscreen and a keyboard, NO MOUSE.
# kiwix-desktop is keyboard-navigable at the application level (Ctrl+T, Ctrl+1-9,
# F6/Ctrl+L, Ctrl+B, Ctrl+Tab) but its content area is a QtWebEngine view, so
# following a link in an article means Tab-cycling through every link before it.
# On a Wikipedia page that is hundreds of tab presses for the one you want, and
# following links is the single most common thing you do in an encyclopaedia.
#
# THE FIX: serve the ZIMs over HTTP with kiwix-serve, and read them in
# qutebrowser, which has vim-style LINK HINTS -- press `f` and every visible link
# is labelled with a letter; type it to follow. That turns the most common action
# from O(number of links) keystrokes into two or three.
#
# It also unifies the deck: one keyboard-driven browser reaches BOTH the 123GB
# ZIM library (:8080) and the local 7B model (:8081). kiwix-desktop stays
# installed; this is an addition, not a replacement.

source "$(dirname "$0")/lib.sh"
need_sudo

PORT="${PORT:-8080}"          # 8081 is llama-server (bin/60-local-ai.sh)
ZIMDIR="${ZIMDIR:-$HOME/kiwix-share}"
LIB="$HOME/.local/share/kiwix-desktop/library.xml"

apt_install kiwix-tools qutebrowser

[ -d "$ZIMDIR" ] || die "No ZIM directory at $ZIMDIR"

# kiwix-serve can take a library.xml or a directory of ZIMs. Using the existing
# kiwix-desktop library keeps ONE catalogue for both front-ends, so a book added
# in either place shows up in the other.
if [ ! -f "$LIB" ]; then
    warn "No library.xml at $LIB — serving the directory directly instead."
    SERVE_ARGS="$ZIMDIR/*.zim"
else
    log "Serving the existing kiwix-desktop library: $LIB"
    SERVE_ARGS="--library $LIB"
fi

log "Writing the kiwix-serve user unit"
install -Dm644 /dev/stdin "$HOME/.config/systemd/user/kiwix-serve.service" <<UNIT
[Unit]
Description=kiwix-serve — offline ZIM library over HTTP
Documentation=man:kiwix-serve(1)
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/kiwix-serve --port ${PORT} --address 127.0.0.1 ${SERVE_ARGS}
Restart=on-failure
RestartSec=5
# Indexing 123GB of ZIMs should not fight the desktop for CPU.
Nice=5

[Install]
WantedBy=default.target
UNIT

systemctl --user daemon-reload
systemctl --user enable --now kiwix-serve.service
log "kiwix-serve enabled and started on http://127.0.0.1:${PORT}"
echo
log "Keyboard navigation in qutebrowser, the part that matters:"
log "  f          label every visible link, type the letter to follow"
log "  F          same, but open in a new tab"
log "  j / k      scroll down / up          gg / G   top / bottom"
log "  H / L      back / forward            /        find in page"
log "  o / O      open URL (here / new tab) d        close tab"
log "  Ctrl+PgUp/PgDn  switch tabs          :q       quit"
