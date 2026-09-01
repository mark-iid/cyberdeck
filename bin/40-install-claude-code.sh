#!/usr/bin/env bash
# Install Claude Code from Anthropic's signed apt repository.
#
# WHY apt AND NOT `curl | bash`:
#   - The repo is GPG-signed and apt verifies every upgrade automatically.
#   - Updates arrive through the machine's normal `apt upgrade`, so package
#     state stays coherent with everything else on the deck.
#   - The native installer runs a BACKGROUND AUTO-UPDATER that rewrites the
#     binary under ~/.local/share/claude. On a machine whose whole point is
#     predictable behaviour offline, silent self-modification is the wrong
#     default. apt installs do not auto-update.
#   - npm is not viable here anyway: as of v2.1.198 it wants Node.js 22+,
#     trixie ships Node 20, and Node is not installed at all.
#
# SUPPORT (checked 2026-08-31): Debian 10+, ARM64, 4GB+ RAM. This box is
# Debian 13 trixie / aarch64 / 7.9GB. glibc 2.41.
#
# !! THIS NEEDS THE INTERNET. See the note at the bottom — Claude Code is NOT
# the deck's offline AI story.

source "$(dirname "$0")/lib.sh"
need_sudo

# 'stable' is ~a week behind and skips releases with major regressions.
# That is the right trade for this machine. Set CC_CHANNEL=latest to override.
CC_CHANNEL="${CC_CHANNEL:-stable}"

# Anthropic's release signing key fingerprint, from the official setup docs.
# If this does not match, STOP — do not install.
CC_FPR="31DDDE24DDFAB679F42D7BD2BAA929FF1A7ECACE"

apt_install curl gnupg ca-certificates
# ripgrep: Claude Code normally bundles its own, but the packaged one is
# present (14.1.1) and is a useful fallback if the builtin misbehaves.
apt_install ripgrep

log "Fetching the Claude Code signing key"
sudo install -d -m 0755 /etc/apt/keyrings
sudo curl -fsSL https://downloads.claude.ai/keys/claude-code.asc \
    -o /etc/apt/keyrings/claude-code.asc

log "Verifying key fingerprint"
got="$(gpg --show-keys --with-colons /etc/apt/keyrings/claude-code.asc 2>/dev/null \
        | awk -F: '/^fpr:/{print $10; exit}')"
if [ "$got" != "$CC_FPR" ]; then
    sudo rm -f /etc/apt/keyrings/claude-code.asc
    die "Key fingerprint MISMATCH.
  expected: $CC_FPR
  got:      ${got:-<none>}
Refusing to add the repository. Removed the downloaded key."
fi
log "Fingerprint OK: $got"

log "Registering the $CC_CHANNEL repository"
echo "deb [signed-by=/etc/apt/keyrings/claude-code.asc] https://downloads.claude.ai/claude-code/apt/${CC_CHANNEL} ${CC_CHANNEL} main" \
    | sudo tee /etc/apt/sources.list.d/claude-code.list >/dev/null

sudo apt-get update -qq
apt_install claude-code

log "Installed: $(claude --version 2>/dev/null || echo '<run claude --version>')"
echo
warn "NOT YET AUTHENTICATED. Run 'claude' and follow the browser prompts."
warn "Requires a Pro, Max, Team, Enterprise, or Console account —"
warn "the free Claude.ai plan does not include Claude Code."
echo
warn "OFFLINE REALITY CHECK: Claude Code requires an internet connection."
warn "It is a tool for the deck-as-workstation, NOT the deck-as-survival-radio."
warn "The offline AI story is the local GGUF models in \$HOME, which are"
warn "currently BROKEN (llama_cpp not installed). See DESIGN.md \$5."
echo
log "Upgrade later with: sudo apt update && sudo apt upgrade claude-code"
