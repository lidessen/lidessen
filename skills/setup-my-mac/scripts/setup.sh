#!/usr/bin/env bash
#
# setup.sh — Set up a fresh macOS with essential dev tools.
#
# Philosophy: install via official methods only. Prefer brew when the
# vendor's own docs list it; otherwise use the vendor's installer.
#
# Usage:
#   bash setup.sh            # install everything
#   bash setup.sh uv zed     # install only uv and zed
#   bash setup.sh --list     # list available tools
#
set -euo pipefail

# ─── Helpers ──────────────────────────────────────────────────────────
info()  { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
ok()    { printf '    \033[1;32m✔ %s\033[0m\n' "$*"; }
skip()  { printf '    \033[1;33m⏭ %s (already installed)\033[0m\n' "$*"; }

# ─── Tool functions ───────────────────────────────────────────────────
# Each function is self-contained: check → install → confirm.

install_brew() {
  # Source: https://brew.sh
  info "Homebrew"
  if command -v brew &>/dev/null; then
    skip "brew"; return
  fi
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  ok "brew installed"
}

install_uv() {
  # Source: https://docs.astral.sh/uv — official brew method
  info "uv"
  if command -v uv &>/dev/null; then
    skip "uv"; return
  fi
  brew install uv
  ok "uv installed"
}

install_python() {
  # Source: https://docs.astral.sh/uv/guides/install-python/
  info "Python (latest via uv)"
  if uv python list --only-installed 2>/dev/null | head -n1 | grep -q .; then
    skip "python ($(uv python list --only-installed | head -n1 | awk '{print $1}'))"
  else
    uv python install
    ok "python installed via uv"
  fi
  # Always pin the latest installed version globally
  local ver
  ver=$(uv python list --only-installed 2>/dev/null | head -n1 | awk '{print $1}')
  if [[ -n "$ver" ]]; then
    uv python pin "$ver" --global
    ok "global python pinned to $ver"
  fi
}

install_bun() {
  # Source: https://bun.sh/docs/installation — official brew method
  info "Bun"
  if command -v bun &>/dev/null; then
    skip "bun"; return
  fi
  brew install oven-sh/bun/bun
  ok "bun installed"
}

install_claude() {
  # Source: https://formulae.brew.sh/cask/claude-code
  info "Claude Code"
  if command -v claude &>/dev/null; then
    skip "claude"; return
  fi
  brew install --cask claude-code
  ok "claude installed"
}

install_warp() {
  # Source: https://docs.warp.dev — official brew cask
  info "Warp"
  if brew list --cask warp &>/dev/null 2>&1; then
    skip "warp"; return
  fi
  brew install --cask warp
  ok "warp installed"
}

install_zed() {
  # Source: https://zed.dev/docs/installation — official brew cask
  info "Zed"
  if brew list --cask zed &>/dev/null 2>&1; then
    skip "zed"; return
  fi
  brew install --cask zed
  ok "zed installed"
}

# ─── Tool registry ───────────────────────────────────────────────────
# Order matters: brew must be first, python depends on uv.
ALL_TOOLS=(brew uv python bun claude warp zed)

show_list() {
  echo "Available tools: ${ALL_TOOLS[*]}"
}

show_summary() {
  info "Installed tools:"
  echo "    brew  : $(brew --version 2>/dev/null | head -n1 || echo 'N/A')"
  echo "    uv    : $(uv --version 2>/dev/null || echo 'N/A')"
  echo "    python: $(uv python list --only-installed 2>/dev/null | head -n1 | awk '{print $1}')"
  echo "    bun   : $(bun --version 2>/dev/null || echo 'N/A')"
  echo "    claude: $(claude --version 2>/dev/null || echo 'N/A')"
  echo "    warp  : $(brew list --cask --versions warp 2>/dev/null || echo 'N/A')"
  echo "    zed   : $(brew list --cask --versions zed 2>/dev/null || echo 'N/A')"
}

# ─── Main ─────────────────────────────────────────────────────────────
if [[ "${1:-}" == "--list" ]]; then
  show_list; exit 0
fi

tools=("${@:-${ALL_TOOLS[@]}}")

for tool in "${tools[@]}"; do
  case "$tool" in
    brew)   install_brew   ;;
    uv)     install_uv     ;;
    python) install_python ;;
    bun)    install_bun    ;;
    claude) install_claude ;;
    warp)   install_warp   ;;
    zed)    install_zed    ;;
    *)      echo "Unknown tool: $tool (use --list to see available tools)" ;;
  esac
done

show_summary
