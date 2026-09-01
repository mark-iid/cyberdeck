#!/home/mark/venv/bin/python
"""Local GGUF chat REPL for the cyberdeck.

Replaces ~/ai.py and ~/codeai.py, which were near-identical and carried four
real bugs:

  1. MODEL_INIT (the system prompt) was defined and then NEVER USED. Both
     scripts advertised a persona they did not apply.
  2. Both pointed at the 3B model, so the 4.1GB Mistral-7B was dead weight.
  3. MODEL_PATH was RELATIVE ("./..."), so they only ran from $HOME.
  4. n_ctx defaulted to 512 against a 2048+ train context, which llama.cpp
     warned about on every start.

They also had to be run with ~/venv/bin/python; run with the system python they
fail with ModuleNotFoundError, which is what made them look broken.
The shebang below fixes that permanently.

Usage:  ask-local.py [-m mistral|orca] [-c CTX] [-s "system prompt"]
"""
import argparse
import os
import sys

HOME = os.path.expanduser("~")
# max_ctx is the model's TRAINING context, not a preference. Exceeding it makes
# llama.cpp warn and the model produce nothing usable — which is exactly what
# happened on 2026-08-31 when a flat 4096 default was applied to the 3B orca
# (n_ctx_train = 2048) and it returned empty completions. Per-model, not global.
MODELS = {
    "mistral": (os.path.join(HOME, "mistral-7b-instruct-v0.3-q4_k_m.gguf"), 8192),
    "orca":    (os.path.join(HOME, "q4_0-orca-mini-3b.gguf"),               2048),
}

p = argparse.ArgumentParser(description="Local GGUF chat REPL")
p.add_argument("-m", "--model", choices=MODELS, default="mistral",
               help="mistral = 7B, better answers, slower. orca = 3B, faster.")
p.add_argument("-c", "--ctx", type=int, default=None,
               help="Defaults to the model's training context; clamped to it.")
p.add_argument("-t", "--threads", type=int, default=4)
p.add_argument("-s", "--system", default="You are a concise, practical assistant.")
args = p.parse_args()

path, max_ctx = MODELS[args.model]
if not os.path.exists(path):
    sys.exit(f"Model not found: {path}")

ctx = max_ctx if args.ctx is None else min(args.ctx, max_ctx)
if args.ctx and args.ctx > max_ctx:
    print(f"note: clamping ctx {args.ctx} -> {max_ctx} (this model's limit)",
          file=sys.stderr)

try:
    from llama_cpp import Llama
except ModuleNotFoundError:
    sys.exit("llama_cpp missing. Run with ~/venv/bin/python, or fix the shebang.")

print(f"Loading {os.path.basename(path)} (ctx={ctx}, threads={args.threads})...",
      file=sys.stderr)
llm = Llama(model_path=path, n_ctx=ctx, n_threads=args.threads, verbose=False)

# Use the model's own chat template rather than hand-rolled "### User:" strings,
# so Mistral gets [INST] markers and the system prompt is actually applied.
messages = [{"role": "system", "content": args.system}]
print("Ready. Ctrl-D or 'quit' to exit.\n", file=sys.stderr)

while True:
    try:
        user = input("> ").strip()
    except (EOFError, KeyboardInterrupt):
        print()
        break
    if user.lower() in ("quit", "exit"):
        break
    if not user:
        continue

    messages.append({"role": "user", "content": user})
    out = []
    for chunk in llm.create_chat_completion(messages=messages, stream=True, max_tokens=512):
        tok = chunk["choices"][0].get("delta", {}).get("content")
        if tok:
            out.append(tok)
            print(tok, end="", flush=True)
    print("\n")
    messages.append({"role": "assistant", "content": "".join(out)})

    # Keep the system prompt plus the last few turns so context does not overrun.
    if len(messages) > 11:
        messages = [messages[0]] + messages[-10:]
