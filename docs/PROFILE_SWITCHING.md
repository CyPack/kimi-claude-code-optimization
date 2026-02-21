# Profile Switching Guide

This guide documents the safe toggle flow between Kimi, Claude, and MiniMax in Claude Code.

## Goals

- Make provider switch one command.
- Prevent `token + API key` auth conflicts.
- Keep Kimi credentials out of active Claude profile.
- Preserve rollback via timestamped backups.

## Script

- Repository source: `scripts/cc-provider`
- Installed command: `$HOME/.local/bin/cc-provider`
- Aliases:
  - `$HOME/.local/bin/cc-kimi`
  - `$HOME/.local/bin/cc-claude`
  - `$HOME/.local/bin/cc-mini`
  - `$HOME/.local/bin/cc-minimax`

Install references:

- Local clone: `bash scripts/install-switch.sh`
- One-command remote: `bash -c "$(curl -fsSL https://raw.githubusercontent.com/CyPack/claude-code-optimization-for-all-providers/main/scripts/install-from-github.sh)"`
- Full install guide: `docs/INSTALLATION.md`

## Commands

```bash
cc-provider status
cc-provider kimi
cc-provider claude
cc-provider minimax
cc-provider mini
```

## Built-in Notifications

- No-op protection:
  - If target profile is already active, switch is skipped.
  - Example message: `CC zaten su an kimi kullaniyor.`
- Transition summary:
  - After a real switch, output includes:
    - previous provider
    - current provider
    - previous API base URL
    - current API base URL

## What Happens on Switch

### `cc-provider claude`

- Backs up:
  - `$HOME/.claude/settings.json`
  - `$HOME/.claude/settings.local.json`
- Backup path:
  - `$HOME/.claude/backups/provider-switch-YYYYmmdd-HHMMSS-XXXXXX/`
- Saves Kimi key/base URL into:
  - Provider-specific profile stash (`kimi` or `minimax`) with permission `0600`
- Updates active config:
  - `model = sonnet`
  - `ENABLE_TOOL_SEARCH = auto:1`
  - Removes Kimi model pin env vars (if currently set to Kimi)
  - Re-enables `ToolSearch` in permissions
  - Removes `ANTHROPIC_API_KEY` and `ANTHROPIC_BASE_URL` from active `settings.local.json`

### `cc-provider kimi`

- Backs up the same files with a new timestamp.
- Restores Kimi credentials from active config or profile stash.
- Updates active config:
  - `model = kimi-for-coding`
  - `ENABLE_TOOL_SEARCH = 0`
  - `ANTHROPIC_DEFAULT_HAIKU_MODEL = kimi-for-coding`
  - `ANTHROPIC_DEFAULT_SONNET_MODEL = kimi-for-coding`
  - `CLAUDE_CODE_SUBAGENT_MODEL = kimi-for-coding`
  - `ANTHROPIC_BASE_URL = https://api.kimi.com/coding/` (unless a saved custom URL exists)
  - Disables `ToolSearch` in permissions

### `cc-provider minimax` / `cc-provider mini`

- Backs up the same files with a new timestamp.
- Restores MiniMax credentials from active config or MiniMax profile stash.
- Updates active config:
  - `model = minimax-2.5` (override via `MINIMAX_MODEL`)
  - `ENABLE_TOOL_SEARCH = auto:1`
  - `ANTHROPIC_DEFAULT_HAIKU_MODEL = minimax-2.5`
  - `ANTHROPIC_DEFAULT_SONNET_MODEL = minimax-2.5`
  - `CLAUDE_CODE_SUBAGENT_MODEL = minimax-2.5`
  - `ANTHROPIC_BASE_URL = https://api.minimax.chat/v1` (override via `MINIMAX_BASE_URL_DEFAULT`)
  - Re-enables `ToolSearch` in permissions

## Validation

```bash
cc-provider status
jq '{model,env,permissions}' $HOME/.claude/settings.json
jq '{env:(.env|keys)}' $HOME/.claude/settings.local.json
claude auth status
```

## Troubleshooting

- If `cc-provider kimi` warns about missing API key:
  - Re-auth with your Kimi flow or set `ANTHROPIC_API_KEY` in local settings.
- If Claude auth is needed after switching:
  - Run `claude /login`.
- If anything breaks:
  - Restore latest files from `$HOME/.claude/backups/provider-switch-*`.
