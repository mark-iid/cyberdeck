#!/usr/bin/env bash
# Local offline AI: llama.cpp + llama-server, reachable in a browser next to Kiwix.
#
# READ THIS FIRST — the record was wrong. An earlier assessment claimed the AI
# stack was "broken" (ModuleNotFoundError). It is NOT. ~/venv contains a working
# llama_cpp_python 0.3.16 (plus torch 2.10, transformers 5.2). The error came
# from running ~/ai.py with the SYSTEM python instead of ~/venv/bin/python.
# Verified 2026-08-31: `cd ~ && ~/venv/bin/python ai.py` generates text fine.
#
# So this script is an UPGRADE, not a repair. It does two things:
#   1. Installs a corrected REPL (files/ai/ask-local.py) that fixes four real
#      bugs in ai.py/codeai.py — see that file's docstring.
#   2. Builds llama.cpp for llama-server: a browser chat UI on the touchscreen,
#      sitting alongside Kiwix, which is what makes this a deck feature rather
#      than a terminal toy. The native Cortex-A76 build should also beat the
#      generic pip wheel.
#
# !! THERMAL !! Inference is sustained all-core load. This Pi hit 96.6 C after
# ONE short inference, with no fan, already throttled to 1.0GHz (DESIGN §6).
# The critical trip is 110 C. FIT THE FAN BEFORE RUNNING THIS.

source "$(dirname "$0")/lib.sh"
need_sudo

LLAMA_REF="${LLAMA_REF:-master}"
LLAMA_DIR="$BUILD_ROOT/llama.cpp"
REPO="$(cd "$(dirname "$0")/.." && pwd)"

# Mistral-7B Q4_K_M: better answers, 4.1GB, comfortable in 8GB alongside a
# 4096-token KV cache. The 3B orca is the fast fallback.
MODEL="${MODEL:-$HOME/mistral-7b-instruct-v0.3-q4_k_m.gguf}"
PORT="${PORT:-8081}"          # 8080 left free for kiwix-serve
CTX="${CTX:-4096}"

thermal_check
# Threshold is 100C, NOT the 85C soft limit. This Pi IDLES at ~87C even with
# the case open (measured 2026-08-31), so a guard set at the soft limit would
# fire every single time and teach you to ignore it. What actually matters is
# margin to the 110C critical trip. 100C leaves 10C of headroom.
t="$(vcgencmd measure_temp 2>/dev/null | tr -dc '0-9.' | cut -d. -f1)"
if [ -n "$t" ] && [ "$t" -ge 100 ] && [ "${FORCE:-0}" != 1 ]; then
    die "Currently ${t}C — only $((110 - t))C from the critical trip, and no fan.
Let it cool, fit a fan (DESIGN §6), or re-run with FORCE=1."
fi
[ -n "$t" ] && [ "$t" -ge 85 ] && \
    warn "${t}C at start. Throttled builds are slow but safe; watch for thermal aborts."

# --- 1. The corrected REPL (cheap, no compute) ------------------------------
log "Installing ask-local.py"
sudo install -Dm755 "$REPO/files/ai/ask-local.py" /usr/local/bin/ask-local
for old in "$HOME/ai.py" "$HOME/codeai.py"; do
    [ -f "$old" ] && [ ! -f "$old.superseded" ] && {
        cp "$old" "$old.superseded"
        log "kept a copy of $(basename "$old") as $(basename "$old").superseded"
    }
done
log "Run it with: ask-local            (7B Mistral)"
log "             ask-local -m orca    (3B, faster)"

# --- 2. llama.cpp ------------------------------------------------------------
apt_install cmake ccache libcurl4-openssl-dev git build-essential

fetch_repo https://github.com/ggml-org/llama.cpp.git "$LLAMA_DIR" "$LLAMA_REF"
cd "$LLAMA_DIR"

# CPU only. The Pi 5's v3d GPU has a Vulkan driver in Mesa 26.2 and llama.cpp
# has a Vulkan backend, but the GPU is memory-bandwidth-starved and slower than
# the four Cortex-A76 cores for this workload. Not worth the build complexity.
log "Configuring (CPU, native Cortex-A76)"
cmake -B build -DCMAKE_BUILD_TYPE=Release -DGGML_NATIVE=ON -DLLAMA_CURL=ON

log "Building with -j$(build_jobs) — expect this to be slow while throttled"
cmake --build build --config Release -j"$(build_jobs)"

log "Installing llama-server and llama-cli"
sudo install -Dm755 build/bin/llama-server /usr/local/bin/llama-server
sudo install -Dm755 build/bin/llama-cli    /usr/local/bin/llama-cli

# --- 3. systemd user unit ----------------------------------------------------
# A USER unit, not system: the models live in $HOME and only this user needs it.
# Not enabled by default — starting a 7B server at boot on a fanless, throttled
# Pi is not a sensible default. Enable it deliberately once cooling exists.
log "Writing the llama-server user unit"
install -Dm644 /dev/stdin "$HOME/.config/systemd/user/llama-server.service" <<UNIT
[Unit]
Description=llama.cpp server (local offline LLM)
Documentation=https://github.com/ggml-org/llama.cpp
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/llama-server \\
    --model ${MODEL} \\
    --ctx-size ${CTX} \\
    --threads 4 \\
    --host 127.0.0.1 \\
    --port ${PORT}
Restart=on-failure
RestartSec=5
# Inference is all-core sustained load on a machine with no thermal headroom.
# Deprioritise it so the desktop stays responsive while it works.
Nice=10

[Install]
WantedBy=default.target
UNIT

systemctl --user daemon-reload
log "Unit written but NOT enabled."
echo
log "Start it on demand:   systemctl --user start llama-server"
log "Then open:            http://127.0.0.1:${PORT}"
log "Enable at boot ONLY once a fan is fitted:"
log "                      systemctl --user enable --now llama-server"
warn "Model: $(basename "$MODEL"), ctx ${CTX}, port ${PORT} (8080 left for kiwix-serve)."
