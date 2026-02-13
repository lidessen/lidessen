---
name: setup-my-mac
description: Automate setting up a fresh macOS machine with development tools and configuration. Use when the user wants to install dev tools on a new Mac, set up their development environment, configure git, or run the mac setup script.
---

# Setup My Mac

Install development tools and apply configuration on a fresh macOS.

## Philosophy

- **Official sources only** — every install command comes from the tool's own docs.
- **Prefer brew** — but only when the vendor officially supports it.
- **Idempotent** — can be re-run safely; already-installed tools are skipped.

## What's Included

**CLI & Runtimes:** Homebrew, uv, Python, Rust, Go, Bun, gh, fnm, ripgrep, jq
**GUI Apps:** Claude Code, Warp, Zed, OrbStack, Raycast, Edge
**Config:** Oh My Zsh, Git defaults (ignorecase=false, pull.rebase, defaultBranch=main)

For full install commands and sources, see [references/tools.md](references/tools.md).

## Usage

### One-liner bootstrap (recommended)

```bash
curl -fsSL https://lidessen.dev/setup-my-mac.sh | bash
```

Installs brew + bun + Claude Code, then uses Claude headless mode to install everything else via this skill. Opens browser for OAuth login if needed.

### Manual mode

```bash
bash scripts/install.sh            # install everything
bash scripts/install.sh uv zed     # install specific tools
bash scripts/install.sh --list     # list available tools
```

## Adding New Tools

1. Check the tool's official website for installation instructions.
2. If brew is listed as an official method, use brew.
3. Otherwise use the official standalone installer.
4. Add the tool to [references/tools.md](references/tools.md) and `scripts/install.sh`.
