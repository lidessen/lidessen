# Tools & Install Methods

All tools use their **official recommended method**. Brew is preferred when the vendor's own docs list it; otherwise the vendor's standalone installer is used.

## CLI Tools & Runtimes

| Tool | Method | Command | Source |
|------|--------|---------|--------|
| Homebrew | Official script | `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"` | brew.sh |
| uv | brew (official) | `brew install uv` | docs.astral.sh/uv |
| Python (latest) | uv | `uv python install` + `uv python pin --global` | docs.astral.sh/uv |
| Rust | Official rustup (brew NOT listed) | `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \| sh -s -- -y` | rust-lang.org/tools/install |
| Go | Official .pkg (brew NOT listed) | Download from `go.dev/dl/` + `sudo installer -pkg` | go.dev/doc/install |
| Bun | brew (official) | `brew install oven-sh/bun/bun` | bun.sh/docs/installation |
| gh | brew (official) | `brew install gh` | cli.github.com |
| fnm | brew (official) | `brew install fnm` | github.com/Schniz/fnm |
| ripgrep | brew (official) | `brew install ripgrep` | github.com/BurntSushi/ripgrep |
| jq | brew (official) | `brew install jq` | jqlang.github.io/jq |

## GUI Apps

| Tool | Method | Command | Source |
|------|--------|---------|--------|
| Claude Code | brew cask (official) | `brew install --cask claude-code` | formulae.brew.sh/cask/claude-code |
| Warp | brew cask (official) | `brew install --cask warp` | docs.warp.dev |
| Zed | brew cask (official) | `brew install --cask zed` | zed.dev/docs/installation |
| OrbStack | brew cask (official) | `brew install --cask orbstack` | orbstack.dev |
| Raycast | brew cask (official) | `brew install --cask raycast` | raycast.com |
| Edge | brew cask (official) | `brew install --cask microsoft-edge` | microsoft.com/edge |

## Configuration

| Item | What it does |
|------|-------------|
| Oh My Zsh | Zsh framework — official install script from ohmyz.sh |
| Git config | `init.defaultBranch=main`, `core.ignorecase=false`, `pull.rebase=true`, `push.autoSetupRemote=true` |
