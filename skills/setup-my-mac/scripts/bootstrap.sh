#!/usr/bin/env bash
#
# bootstrap.sh — One-liner bootstrap for a fresh macOS dev environment.
#
#   curl -fsSL https://lidessen.dev/skills/setup-my-mac/scripts/bootstrap.sh | bash
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
  # NONINTERACTIVE avoids the confirmation prompt that would break curl|bash
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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

# ─── 4. Claude auth (subscription login) ─────────────────────────────
# Uses OAuth login (opens browser). On a fresh Mac you need to log in once.
info "Claude auth"
if claude auth status &>/dev/null; then
  ok "already logged in"
else
  warn "Not logged in — opening browser for OAuth…"
  claude login </dev/tty
  ok "logged in"
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
  --output-format text \
  "You have the setup-my-mac skill installed.
Read the skill's SKILL.md, then install every tool in the Tools & Install Methods
table that is not already present on this machine.
For each tool: run the listed command, verify success, then move on.
Print a final summary of all installed tool versions when done."

info "Bootstrap complete!"
