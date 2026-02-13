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

# ─── Generic installers ──────────────────────────────────────────────
# Format: "name:formula:check_cmd"  (check_cmd defaults to name)

brew_formula() {
  local name="$1" formula="$2" cmd="${3:-$1}"
  info "$name"
  if command -v "$cmd" &>/dev/null; then skip "$name"; return; fi
  brew install "$formula"
  ok "$name installed"
}

brew_cask() {
  local name="$1" cask="$2"
  info "$name"
  if brew list --cask "$cask" &>/dev/null 2>&1; then skip "$name"; return; fi
  brew install --cask "$cask"
  ok "$name installed"
}

# ─── Custom installers (non-trivial logic) ────────────────────────────

install_brew() {
  # Source: https://brew.sh
  info "Homebrew"
  if command -v brew &>/dev/null; then skip "brew"; return; fi
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  ok "brew installed"
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
  # Source: https://www.rust-lang.org/tools/install — brew NOT listed
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
  # Source: https://go.dev/doc/install — brew NOT listed
  info "Go"
  if command -v go &>/dev/null; then
    skip "go ($(go version | awk '{print $3}'))"; return
  fi
  local goversion pkg arch
  goversion=$(curl -fsSL 'https://go.dev/VERSION?m=text' | head -1)
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

install_ohmyzsh() {
  # Source: https://ohmyz.sh — official install script
  info "Oh My Zsh"
  if [[ -d "$HOME/.oh-my-zsh" ]]; then skip "oh-my-zsh"; return; fi
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  ok "oh-my-zsh installed"
}

install_gitconfig() {
  info "Git config"
  git config --global init.defaultBranch main
  git config --global core.ignorecase false
  git config --global pull.rebase true
  git config --global push.autoSetupRemote true
  ok "git configured (defaultBranch=main, ignorecase=false, pull.rebase, push.autoSetupRemote)"
}

# ─── Tool registry ───────────────────────────────────────────────────
# Order matters: brew must be first, python depends on uv.
ALL_TOOLS=(
  brew uv python rust go bun claude
  gh fnm ripgrep jq
  warp zed orbstack raycast edge
  ohmyzsh gitconfig
)

dispatch() {
  local tool="$1"
  case "$tool" in
    # Custom installers
    brew)      install_brew      ;;
    python)    install_python    ;;
    rust)      install_rust      ;;
    go)        install_go        ;;
    ohmyzsh)   install_ohmyzsh   ;;
    gitconfig) install_gitconfig ;;
    # Brew formulas — name:formula:check_cmd
    uv)        brew_formula "uv"      "uv"              ;;
    bun)       brew_formula "bun"     "oven-sh/bun/bun" ;;
    gh)        brew_formula "gh"      "gh"              ;;
    fnm)       brew_formula "fnm"     "fnm"             ;;
    ripgrep)   brew_formula "ripgrep" "ripgrep" "rg"    ;;
    jq)        brew_formula "jq"      "jq"              ;;
    # Brew casks — name:cask
    claude)    brew_cask "Claude Code"     "claude-code"     ;;
    warp)      brew_cask "Warp"            "warp"            ;;
    zed)       brew_cask "Zed"             "zed"             ;;
    orbstack)  brew_cask "OrbStack"        "orbstack"        ;;
    raycast)   brew_cask "Raycast"         "raycast"         ;;
    edge)      brew_cask "Microsoft Edge"  "microsoft-edge"  ;;
    *)         echo "Unknown tool: $tool (use --list to see available)" ;;
  esac
}

show_summary() {
  info "Installed tools:"
  # CLI tools
  command -v brew  &>/dev/null && echo "    brew     : $(brew --version | head -n1)"
  command -v uv    &>/dev/null && echo "    uv       : $(uv --version)"
  command -v uv    &>/dev/null && echo "    python   : $(uv python list --only-installed 2>/dev/null | head -n1 | awk '{print $1}')"
  command -v rustc &>/dev/null && echo "    rust     : $(rustc --version | awk '{print $2}')"
  command -v go    &>/dev/null && echo "    go       : $(go version | awk '{print $3}')"
  command -v bun   &>/dev/null && echo "    bun      : $(bun --version)"
  command -v gh    &>/dev/null && echo "    gh       : $(gh --version | head -n1)"
  command -v fnm   &>/dev/null && echo "    fnm      : $(fnm --version)"
  command -v rg    &>/dev/null && echo "    ripgrep  : $(rg --version | head -n1)"
  command -v jq    &>/dev/null && echo "    jq       : $(jq --version)"
  # GUI apps (check via brew cask)
  brew list --cask claude-code     &>/dev/null 2>&1 && echo "    claude   : $(brew list --cask --versions claude-code)"
  brew list --cask warp            &>/dev/null 2>&1 && echo "    warp     : $(brew list --cask --versions warp)"
  brew list --cask zed             &>/dev/null 2>&1 && echo "    zed      : $(brew list --cask --versions zed)"
  brew list --cask orbstack        &>/dev/null 2>&1 && echo "    orbstack : $(brew list --cask --versions orbstack)"
  brew list --cask raycast         &>/dev/null 2>&1 && echo "    raycast  : $(brew list --cask --versions raycast)"
  brew list --cask microsoft-edge  &>/dev/null 2>&1 && echo "    edge     : $(brew list --cask --versions microsoft-edge)"
  # Config
  [[ -d "$HOME/.oh-my-zsh" ]] && echo "    ohmyzsh  : installed"
}

# ─── Main ─────────────────────────────────────────────────────────────
if [[ "${1:-}" == "--list" ]]; then
  echo "Available tools: ${ALL_TOOLS[*]}"; exit 0
fi

tools=("${@:-${ALL_TOOLS[@]}}")
for tool in "${tools[@]}"; do dispatch "$tool"; done
show_summary
