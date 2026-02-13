#!/usr/bin/env bash
#
# setup.sh — Set up a fresh macOS with essential dev tools.
#
# Philosophy: install via official methods only. Prefer brew when the
# vendor's own docs list it; otherwise use the vendor's installer.
#
# Usage:  bash scripts/setup.sh
#
set -euo pipefail

# ─── Helpers ──────────────────────────────────────────────────────────
info()  { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
ok()    { printf '    \033[1;32m✔ %s\033[0m\n' "$*"; }
skip()  { printf '    \033[1;33m⏭ %s (already installed)\033[0m\n' "$*"; }

# ─── 1. Homebrew ──────────────────────────────────────────────────────
# Source: https://brew.sh
info "Homebrew"
if command -v brew &>/dev/null; then
  skip "brew"
else
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add brew to PATH for Apple Silicon (default install at /opt/homebrew)
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  ok "brew installed"
fi

# ─── 2. uv ───────────────────────────────────────────────────────────
# Source: https://docs.astral.sh/uv/getting-started/installation/
# Official docs list brew as a supported method.
info "uv"
if command -v uv &>/dev/null; then
  skip "uv"
else
  brew install uv
  ok "uv installed"
fi

# ─── 3. Python (latest, via uv) ──────────────────────────────────────
# Source: https://docs.astral.sh/uv/guides/install-python/
info "Python (latest via uv)"
LATEST_PY=$(uv python list --only-installed 2>/dev/null | head -n1 || true)
if [[ -n "$LATEST_PY" ]]; then
  skip "python ($(echo "$LATEST_PY" | awk '{print $1}'))"
else
  uv python install
  ok "python installed via uv"
fi

# Set the globally-pinned python version
INSTALLED_VER=$(uv python list --only-installed 2>/dev/null | head -n1 | awk '{print $1}')
if [[ -n "$INSTALLED_VER" ]]; then
  uv python pin "$INSTALLED_VER" --global
  ok "global python pinned to $INSTALLED_VER"
fi

# ─── 4. Bun ──────────────────────────────────────────────────────────
# Source: https://bun.sh/docs/installation
# Official docs list brew as a supported method: brew install oven-sh/bun/bun
info "Bun"
if command -v bun &>/dev/null; then
  skip "bun"
else
  brew install oven-sh/bun/bun
  ok "bun installed"
fi

# ─── 5. Claude Code ──────────────────────────────────────────────────
# Source: https://formulae.brew.sh/cask/claude-code
# Official brew cask.
info "Claude Code"
if command -v claude &>/dev/null; then
  skip "claude"
else
  brew install --cask claude-code
  ok "claude installed"
fi

# ─── 6. Warp ─────────────────────────────────────────────────────────
# Source: https://docs.warp.dev/getting-started/
# Official docs list brew cask as a supported method.
info "Warp"
if brew list --cask warp &>/dev/null 2>&1; then
  skip "warp"
else
  brew install --cask warp
  ok "warp installed"
fi

# ─── 7. Zed ──────────────────────────────────────────────────────────
# Source: https://zed.dev/docs/installation
# Official docs list brew cask as a supported method.
info "Zed"
if brew list --cask zed &>/dev/null 2>&1; then
  skip "zed"
else
  brew install --cask zed
  ok "zed installed"
fi

# ─── Done ─────────────────────────────────────────────────────────────
info "All done! Installed tools:"
echo "    brew  : $(brew --version | head -n1)"
echo "    uv    : $(uv --version)"
echo "    python: $(uv python list --only-installed | head -n1 | awk '{print $1}')"
echo "    bun   : $(bun --version 2>/dev/null || echo 'N/A')"
echo "    claude: $(claude --version 2>/dev/null || echo 'N/A')"
echo "    warp  : $(brew list --cask --versions warp 2>/dev/null || echo 'N/A')"
echo "    zed   : $(brew list --cask --versions zed 2>/dev/null || echo 'N/A')"
