# Installation Guide

This guide is credentials-safe. It installs switch scripts only and does not write API keys.

## Option A: Install from Local Clone

From repository root:

```bash
bash scripts/install-switch.sh
```

Default install path:

- `$HOME/.local/bin`

Installed commands:

- `cc-provider`
- `cc-kimi`
- `cc-claude`
- `cc-mini`
- `cc-minimax`

## Option B: One-Command Install (Remote)

With curl:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/CyPack/claude-code-optimization-for-all-providers/main/scripts/install-from-github.sh)"
```

If curl is missing, use wget manually:

```bash
wget -qO- https://raw.githubusercontent.com/CyPack/claude-code-optimization-for-all-providers/main/scripts/install-from-github.sh | bash
```

## Optional: Custom Install Directory

```bash
INSTALL_DIR="$HOME/bin" bash scripts/install-switch.sh
```

Or for remote installer:

```bash
INSTALL_DIR="$HOME/bin" bash -c "$(curl -fsSL https://raw.githubusercontent.com/CyPack/claude-code-optimization-for-all-providers/main/scripts/install-from-github.sh)"
```

## First Validation

```bash
cc-provider status
```

Switch examples:

```bash
cc-provider kimi
cc-provider claude
cc-provider minimax
```

Output behavior:

- If already on target profile: no-op notice is shown.
- If profile changes: previous -> current provider/API summary is shown.

## External CLI Integration Pattern

Any CLI/agent can call these commands directly. Recommended minimal protocol:

1. Run one switch command (`kimi`, `claude`, `minimax`).
2. Run `cc-provider status` immediately.
3. Parse and log profile/model/toolsearch state.

## Uninstall

```bash
rm -f "$HOME/.local/bin/cc-provider" \
      "$HOME/.local/bin/cc-kimi" \
      "$HOME/.local/bin/cc-claude" \
      "$HOME/.local/bin/cc-mini" \
      "$HOME/.local/bin/cc-minimax"
```

## Security Notes

- No credentials are included in this repository.
- The switch tool only reads/writes your local `~/.claude` config files.
- Backups are auto-created at each switch under:
  - `$HOME/.claude/backups/provider-switch-YYYYmmdd-HHMMSS-XXXXXX/`
