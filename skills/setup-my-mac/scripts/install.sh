#!/usr/bin/env bash
#
# install.sh — Install dev tools on macOS.
#
# Philosophy: install via official methods only. Prefer brew when the
# vendor's own docs list it; otherwise use the vendor's installer.
#
# Usage:
#   bash install.sh            # install everything
#   bash install.sh uv zed     # install only uv and zed
#   bash install.sh --list     # list available tools
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
  local ver
  ver=$(uv python list --only-installed 2>/dev/null | head -n1 | awk '{print $1}')
  if [[ -n "$ver" ]]; then
    uv python pin "$ver" --global
    ok "global python pinned to $ver"
  fi
}

install_rust() {
  # Source: https://www.rust-lang.org/tools/install — official rustup (brew NOT listed)
  info "Rust (via rustup)"
  if command -v rustup &>/dev/null; then
    skip "rust ($(rustc --version 2>/dev/null | awk '{print $2}'))"; return
  fi
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  # shellcheck source=/dev/null
  source "$HOME/.cargo/env"
  ok "rust installed via rustup"
}

install_go() {
  # Source: https://go.dev/doc/install — official .pkg installer (brew NOT listed)
  info "Go"
  if command -v go &>/dev/null; then
    skip "go ($(go version | awk '{print $3}'))"; return
  fi
  local goversion pkg
  goversion=$(curl -fsSL 'https://go.dev/VERSION?m=text' | head -1)
  # Detect architecture
  local arch
  arch=$(uname -m)
  if [[ "$arch" == "arm64" ]]; then
    pkg="${goversion}.darwin-arm64.pkg"
  else
    pkg="${goversion}.darwin-amd64.pkg"
  fi
  curl -fsSL "https://go.dev/dl/${pkg}" -o /tmp/go.pkg
  sudo installer -pkg /tmp/go.pkg -target /
  rm -f /tmp/go.pkg
  ok "go $goversion installed"
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
  # Source: https://formulae.brew.sh/cask/claude-code — official brew cask
  info "Claude Code"
  if command -v claude &>/dev/null; then
    skip "claude"; return
  fi
  brew install --cask claude-code
  ok "claude installed"
}

install_gh() {
  # Source: https://cli.github.com — official brew method
  info "GitHub CLI"
  if command -v gh &>/dev/null; then
    skip "gh"; return
  fi
  brew install gh
  ok "gh installed"
}

install_fnm() {
  # Source: https://github.com/Schniz/fnm — official brew method
  info "fnm"
  if command -v fnm &>/dev/null; then
    skip "fnm"; return
  fi
  brew install fnm
  ok "fnm installed"
}

install_ripgrep() {
  # Source: https://github.com/BurntSushi/ripgrep — official brew method
  info "ripgrep"
  if command -v rg &>/dev/null; then
    skip "ripgrep"; return
  fi
  brew install ripgrep
  ok "ripgrep installed"
}

install_jq() {
  # Source: https://jqlang.github.io/jq — official brew method
  info "jq"
  if command -v jq &>/dev/null; then
    skip "jq"; return
  fi
  brew install jq
  ok "jq installed"
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

install_orbstack() {
  # Source: https://orbstack.dev — official brew cask
  info "OrbStack"
  if brew list --cask orbstack &>/dev/null 2>&1; then
    skip "orbstack"; return
  fi
  brew install --cask orbstack
  ok "orbstack installed"
}

install_raycast() {
  # Source: https://raycast.com — official brew cask
  info "Raycast"
  if brew list --cask raycast &>/dev/null 2>&1; then
    skip "raycast"; return
  fi
  brew install --cask raycast
  ok "raycast installed"
}

install_edge() {
  # Source: https://www.microsoft.com/edge — official brew cask
  info "Microsoft Edge"
  if brew list --cask microsoft-edge &>/dev/null 2>&1; then
    skip "edge"; return
  fi
  brew install --cask microsoft-edge
  ok "edge installed"
}

# ─── Tool registry ───────────────────────────────────────────────────
# Order matters: brew first, python depends on uv.
ALL_TOOLS=(
  brew uv python rust go bun claude
  gh fnm ripgrep jq
  warp zed orbstack raycast edge
)

show_list() {
  echo "Available tools: ${ALL_TOOLS[*]}"
}

show_summary() {
  info "Installed tools:"
  echo "    brew    : $(brew --version 2>/dev/null | head -n1 || echo 'N/A')"
  echo "    uv      : $(uv --version 2>/dev/null || echo 'N/A')"
  echo "    python  : $(uv python list --only-installed 2>/dev/null | head -n1 | awk '{print $1}')"
  echo "    rust    : $(rustc --version 2>/dev/null | awk '{print $2}' || echo 'N/A')"
  echo "    go      : $(go version 2>/dev/null | awk '{print $3}' || echo 'N/A')"
  echo "    bun     : $(bun --version 2>/dev/null || echo 'N/A')"
  echo "    claude  : $(claude --version 2>/dev/null || echo 'N/A')"
  echo "    gh      : $(gh --version 2>/dev/null | head -n1 || echo 'N/A')"
  echo "    fnm     : $(fnm --version 2>/dev/null || echo 'N/A')"
  echo "    ripgrep : $(rg --version 2>/dev/null | head -n1 || echo 'N/A')"
  echo "    jq      : $(jq --version 2>/dev/null || echo 'N/A')"
  echo "    warp    : $(brew list --cask --versions warp 2>/dev/null || echo 'N/A')"
  echo "    zed     : $(brew list --cask --versions zed 2>/dev/null || echo 'N/A')"
  echo "    orbstack: $(brew list --cask --versions orbstack 2>/dev/null || echo 'N/A')"
  echo "    raycast : $(brew list --cask --versions raycast 2>/dev/null || echo 'N/A')"
  echo "    edge    : $(brew list --cask --versions microsoft-edge 2>/dev/null || echo 'N/A')"
}

# ─── Main ─────────────────────────────────────────────────────────────
if [[ "${1:-}" == "--list" ]]; then
  show_list; exit 0
fi

tools=("${@:-${ALL_TOOLS[@]}}")

for tool in "${tools[@]}"; do
  case "$tool" in
    brew)     install_brew     ;;
    uv)       install_uv       ;;
    python)   install_python   ;;
    rust)     install_rust     ;;
    go)       install_go       ;;
    bun)      install_bun      ;;
    claude)   install_claude   ;;
    gh)       install_gh       ;;
    fnm)      install_fnm      ;;
    ripgrep)  install_ripgrep  ;;
    jq)       install_jq       ;;
    warp)     install_warp     ;;
    zed)      install_zed      ;;
    orbstack) install_orbstack ;;
    raycast)  install_raycast  ;;
    edge)     install_edge     ;;
    *)        echo "Unknown tool: $tool (use --list to see available tools)" ;;
  esac
done

show_summary
