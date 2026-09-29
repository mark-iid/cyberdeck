#!/usr/bin/env bash
# Symlink configs from this repo into $HOME. Nothing is copied, so editing the
# repo edits the live config and `niri msg action reload-config` picks it up.
#
# Existing files are backed up to <name>.pre-cyberdeck rather than clobbered.
# NOTHING under ~/.config/labwc or ~/.config/wf-panel-pi is touched — the
# Raspberry Pi OS desktop stays exactly as it is.

source "$(dirname "$0")/lib.sh"

REPO="$(cd "$(dirname "$0")/.." && pwd)"

# Symlink a single FILE into a directory that already holds state we must not
# displace. Same backup behaviour as link(), one level down.
link_file() {
    local src="$REPO/config/$1" dst="$HOME/.config/$1"
    mkdir -p "$(dirname "$dst")"
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        warn "Backing up existing $dst -> $dst.pre-cyberdeck"
        mv "$dst" "$dst.pre-cyberdeck"
    fi
    ln -sfn "$src" "$dst"
    log "linked ~/.config/$1"
}

link() {
    local src="$REPO/config/$1" dst="$HOME/.config/$1"
    mkdir -p "$(dirname "$dst")"
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        warn "Backing up existing $dst -> $dst.pre-cyberdeck"
        mv "$dst" "$dst.pre-cyberdeck"
    fi
    ln -sfn "$src" "$dst"
    log "linked ~/.config/$1"
}

link niri
link waybar
link foot
link mako

# qutebrowser gets a FILE link, not a directory link, and that is the whole
# reason link_file exists. ~/.config/qutebrowser is not ours: qutebrowser writes
# bookmarks/, greasemonkey/ and quickmarks into it itself, and linking the
# directory would shove all of that aside into a .pre-cyberdeck backup the first
# time this ran. Only config.py belongs to the repo.
link_file qutebrowser/config.py

log "Config deployed. Reload a running niri with:  niri msg action reload-config"
