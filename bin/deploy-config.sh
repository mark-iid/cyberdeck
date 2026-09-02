#!/usr/bin/env bash
# Symlink configs from this repo into $HOME. Nothing is copied, so editing the
# repo edits the live config and `niri msg action reload-config` picks it up.
#
# Existing files are backed up to <name>.pre-cyberdeck rather than clobbered.
# NOTHING under ~/.config/labwc or ~/.config/wf-panel-pi is touched — the
# Raspberry Pi OS desktop stays exactly as it is.

source "$(dirname "$0")/lib.sh"

REPO="$(cd "$(dirname "$0")/.." && pwd)"

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

log "Config deployed. Reload a running niri with:  niri msg action reload-config"
