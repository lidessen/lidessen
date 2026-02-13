#!/usr/bin/env bash
#
# bootstrap.sh — One-liner bootstrap for a fresh macOS dev environment.
#
#   curl -fsSL https://your-domain.com/setup-my-mac.sh | bash
#
# This script installs the bare minimum (brew, bun, claude-code),
# then delegates the rest to Claude in headless mode via the
# setup-my-mac skill.
#
set -euo pipefail

# ─── Helpers ──────────────────────────────────────────────────────────
info()  { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
ok()    { printf '    \033[1;32m✔ %s\033[0m\n' "$*"; }
warn()  { printf '    \033[1;33m⚠ %s\033[0m\n' "$*"; }
fail()  { printf '    \033[1;31m✘ %s\033[0m\n' "$*"; exit 1; }

# ─── 1. Homebrew ──────────────────────────────────────────────────────
# Source: https://brew.sh
info "Homebrew"
if command -v brew &>/dev/null; then
  ok "brew already installed"
else
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Apple Silicon puts brew at /opt/homebrew
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  ok "brew installed"
fi

# ─── 2. Bun ──────────────────────────────────────────────────────────
# Source: https://bun.sh/docs/installation — official brew method
info "Bun"
if command -v bun &>/dev/null; then
  ok "bun already installed"
else
  brew install oven-sh/bun/bun
  ok "bun installed"
fi

# ─── 3. Claude Code ──────────────────────────────────────────────────
# Source: https://formulae.brew.sh/cask/claude-code
# Official brew cask — same philosophy: brew first when officially supported.
info "Claude Code"
if command -v claude &>/dev/null; then
  ok "claude already installed"
else
  brew install --cask claude-code
  ok "claude installed"
fi

# ─── 4. Check ANTHROPIC_API_KEY ──────────────────────────────────────
info "Checking API key"
if [[ -z "${ANTHROPIC_API_KEY:-}" ]]; then
  warn "ANTHROPIC_API_KEY is not set."
  printf '    Enter your Anthropic API key (or press Enter to skip): '
  read -r api_key
  if [[ -n "$api_key" ]]; then
    export ANTHROPIC_API_KEY="$api_key"
    ok "key set for this session"
  else
    fail "ANTHROPIC_API_KEY is required for Claude headless mode."
  fi
else
  ok "ANTHROPIC_API_KEY is set"
fi

# ─── 5. Install setup-my-mac skill ──────────────────────────────────
info "Installing setup-my-mac skill"
WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

cd "$WORK_DIR"
bunx skills add lidessen/lidessen@setup-my-mac -y -g
ok "skill installed"

# ─── 6. Hand off to Claude (headless) ───────────────────────────────
info "Handing off to Claude (headless mode)…"
claude -p --dangerously-skip-permissions \
  --output-format stream-json --verbose \
  "You have the setup-my-mac skill installed. Use it to install ALL remaining
tools listed in the skill (uv, Python via uv with global pin, Warp, Zed).
Homebrew and Bun are already installed — skip them.
Run each install command, verify it succeeded, then move to the next.
Print a final summary of installed tool versions when done."

info "Bootstrap complete!"
