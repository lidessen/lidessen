---
name: setup-my-mac
description: Automate setting up a fresh macOS machine with essential development tools. Use when the user wants to install dev tools on a new Mac, set up their development environment, or run the mac setup script. Covers Homebrew, uv, Python, Rust, Go, Bun, Claude Code, gh, fnm, ripgrep, jq, Warp, Zed, OrbStack, Raycast, Edge, and more tools as they are added.
---

# Setup My Mac

Automate installation of development tools on a fresh macOS. All tools are installed via their **official recommended method**, preferring `brew` when the tool's official documentation lists it.

## Philosophy

- **Official sources only** — every install command comes from the tool's own docs.
- **Prefer brew** — but only when the vendor officially supports it.
- **Idempotent** — the script can be re-run safely; already-installed tools are skipped.

## Tools & Install Methods

| Tool | Method | Command | Source |
|------|--------|---------|--------|
| Homebrew | Official script | `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"` | brew.sh |
| uv | brew (official) | `brew install uv` | docs.astral.sh/uv |
| Python (latest) | uv | `uv python install` + `uv python pin` globally | docs.astral.sh/uv |
| Rust | Official rustup (brew NOT listed) | `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \| sh -s -- -y` | rust-lang.org/tools/install |
| Go | Official .pkg (brew NOT listed) | Download from `go.dev/dl/` + `sudo installer -pkg` | go.dev/doc/install |
| Bun | brew (official) | `brew install oven-sh/bun/bun` | bun.sh/docs/installation |
| Claude Code | brew cask (official) | `brew install --cask claude-code` | formulae.brew.sh/cask/claude-code |
| gh | brew (official) | `brew install gh` | cli.github.com |
| fnm | brew (official) | `brew install fnm` | github.com/Schniz/fnm |
| ripgrep | brew (official) | `brew install ripgrep` | github.com/BurntSushi/ripgrep |
| jq | brew (official) | `brew install jq` | jqlang.github.io/jq |
| Warp | brew cask (official) | `brew install --cask warp` | docs.warp.dev |
| Zed | brew cask (official) | `brew install --cask zed` | zed.dev/docs/installation |
| OrbStack | brew cask (official) | `brew install --cask orbstack` | orbstack.dev |
| Raycast | brew cask (official) | `brew install --cask raycast` | raycast.com |
| Edge | brew cask (official) | `brew install --cask microsoft-edge` | microsoft.com/edge |

## Usage

### One-liner bootstrap (recommended)

`setup-my-mac.sh` sits at the repo root and is served at the site root. On a fresh Mac:

```bash
curl -fsSL https://lidessen.dev/setup-my-mac.sh | bash
```

What happens:

1. Installs **brew** and **bun** (the minimum bootstrap dependencies).
2. Installs **Claude Code** via `brew install --cask claude-code` (official brew cask).
3. Installs this skill via `bunx skills add lidessen/lidessen@setup-my-mac -y -g`.
4. Launches Claude in **headless mode** (`claude -p --dangerously-skip-permissions`) to install all remaining tools (uv, Python, Warp, Zed, etc.) using this skill's instructions.

If not already logged in, the script opens a browser for Claude OAuth login.

### Manual mode

Run the setup script directly (no Claude required):

```bash
bash scripts/install.sh
```

Each tool section prints clear headers so you can copy-paste individual commands if preferred.

## Adding New Tools

To add a tool, follow the same principle:

1. Check the tool's official website for installation instructions.
2. If brew is listed as an official method, use brew.
3. Otherwise use the official standalone installer.
4. Add the tool to the table above and to `scripts/install.sh`.
