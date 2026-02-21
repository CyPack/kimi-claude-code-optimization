# Profile Switching Guide

This guide documents the safe toggle flow between Kimi, Claude, MiniMax, z.ai, and Ollama in Claude Code.

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
  - `$HOME/.local/bin/cc-zai`
  - `$HOME/.local/bin/cc-ollama`

Install references:

- Local clone: `bash scripts/install-switch.sh`
- One-command remote: `bash -c "$(curl -fsSL https://raw.githubusercontent.com/CyPack/claude-code-optimization-for-opensource-providers/main/scripts/install-from-github.sh)"`
- Full install guide: `docs/INSTALLATION.md`

## Commands

```bash
cc-provider status
cc-provider kimi
cc-provider claude
cc-provider minimax
cc-provider mini
cc-provider zai
cc-provider ollama
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

## GSD Model Sync (Automatic)

Every `cc-provider` switch also tries to sync GSD model profile:

- `claude` -> `balanced`
- `kimi` -> `budget`
- `minimax` -> `budget`
- `zai` -> `budget`
- `ollama` -> `budget`

Targets:

- Project-level: `<cwd>/.planning/config.json` (only if `.planning` exists)
- Global default: `$HOME/.gsd/defaults.json`

Output includes a `GSD profile sync` block with update status.

Optional overrides:

- `GSD_PROFILE_CLAUDE`, `GSD_PROFILE_KIMI`, `GSD_PROFILE_MINIMAX`, `GSD_PROFILE_ZAI`, `GSD_PROFILE_OLLAMA`
- `GSD_PROFILE_DEFAULT`
- `CC_PROVIDER_GSD_CWD` (sync target project path override)
- `GSD_DEFAULTS_FILE` (global defaults path override)
- `GSD_TOOLS_BIN` (custom gsd-tools binary path)

## What Happens on Switch

### `cc-provider claude`

- Backs up:
  - `$HOME/.claude/settings.json`
  - `$HOME/.claude/settings.local.json`
- Backup path:
  - `$HOME/.claude/backups/provider-switch-YYYYmmdd-HHMMSS-XXXXXX/`
- Saves Kimi key/base URL into:
  - Provider-specific profile stash (`kimi`, `minimax`, `zai`, or `ollama`) with permission `0600`
- Updates active config:
  - `model = sonnet`
  - `ENABLE_TOOL_SEARCH = auto:1`
  - Removes Kimi model pin env vars (if currently set to Kimi)
  - Re-enables `ToolSearch` in permissions
  - Removes `ANTHROPIC_API_KEY`, `ANTHROPIC_AUTH_TOKEN`, and `ANTHROPIC_BASE_URL` from active `settings.local.json`

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
  - `model = MiniMax-M2.5` (override via `MINIMAX_MODEL`)
  - `ENABLE_TOOL_SEARCH = auto:1`
  - `ANTHROPIC_MODEL = MiniMax-M2.5`
  - `ANTHROPIC_SMALL_FAST_MODEL = MiniMax-M2.5`
  - `ANTHROPIC_DEFAULT_HAIKU_MODEL = MiniMax-M2.5`
  - `ANTHROPIC_DEFAULT_SONNET_MODEL = MiniMax-M2.5`
  - `ANTHROPIC_DEFAULT_OPUS_MODEL = MiniMax-M2.5`
  - `CLAUDE_CODE_SUBAGENT_MODEL = MiniMax-M2.5`
  - `ANTHROPIC_AUTH_TOKEN = <your_minimax_api_key>`
  - `ANTHROPIC_BASE_URL = https://api.minimax.io/anthropic` (override via `MINIMAX_BASE_URL_DEFAULT`)
  - Legacy `https://api.minimax.chat/v1` entries are auto-migrated to the new default URL
  - Re-enables `ToolSearch` in permissions

### `cc-provider ollama`

- Backs up the same files with a new timestamp.
- Restores Ollama credentials from active config or Ollama profile stash.
- Updates active config:
  - `model = qwen3-coder` (override via `OLLAMA_MODEL`)
  - `ENABLE_TOOL_SEARCH = auto:1`
  - `API_TIMEOUT_MS = 3000000`
  - `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = 1`
  - `ANTHROPIC_MODEL = qwen3-coder`
  - `ANTHROPIC_SMALL_FAST_MODEL = qwen3-coder`
  - `ANTHROPIC_DEFAULT_HAIKU_MODEL = qwen3-coder`
  - `ANTHROPIC_DEFAULT_SONNET_MODEL = qwen3-coder`
  - `ANTHROPIC_DEFAULT_OPUS_MODEL = qwen3-coder`
  - `CLAUDE_CODE_SUBAGENT_MODEL = qwen3-coder`
  - `ANTHROPIC_AUTH_TOKEN = ollama` (override via `OLLAMA_AUTH_TOKEN_DEFAULT`)
  - `ANTHROPIC_BASE_URL = http://localhost:11434/anthropic` (override via `OLLAMA_BASE_URL_DEFAULT`)
  - Re-enables `ToolSearch` in permissions

### `cc-provider zai`

- Backs up the same files with a new timestamp.
- Restores z.ai credentials from active config or z.ai profile stash.
- Updates active config:
  - `model = sonnet` (override via `ZAI_CLAUDE_MODEL`)
  - `ENABLE_TOOL_SEARCH = auto:1`
  - `ANTHROPIC_AUTH_TOKEN = <your_zai_api_key>`
  - `ANTHROPIC_BASE_URL = https://api.z.ai/api/anthropic` (override via `ZAI_BASE_URL_DEFAULT`)
  - `ANTHROPIC_DEFAULT_HAIKU_MODEL = GLM-4.5-Air` (override via `ZAI_HAIKU_MODEL`)
  - `ANTHROPIC_DEFAULT_SONNET_MODEL = GLM-4.7` (override via `ZAI_SONNET_MODEL`)
  - `ANTHROPIC_DEFAULT_OPUS_MODEL = GLM-4.7` (override via `ZAI_OPUS_MODEL`)
  - `CLAUDE_CODE_SUBAGENT_MODEL = GLM-4.7`
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
- If `cc-provider minimax` warns about missing token:
  - Set `ANTHROPIC_AUTH_TOKEN` (MiniMax API key) in local settings and retry.
- If `cc-provider zai` warns about missing token:
  - Set `ANTHROPIC_AUTH_TOKEN` (z.ai API key) in local settings and retry.
- If `claude -p` says `Not logged in` after switching to API providers:
  - Run print-mode calls with command-scoped export from local settings:
    - `ANTHROPIC_AUTH_TOKEN=... ANTHROPIC_BASE_URL=... claude -p "..."`
- If `cc-provider ollama` works but requests fail:
  - Ensure `ollama serve` is running and your model is pulled (`ollama pull qwen3-coder`).
- If Claude auth is needed after switching:
  - Run `claude /login`.
- If anything breaks:
  - Restore latest files from `$HOME/.claude/backups/provider-switch-*`.

## Source References

- Claude Code settings docs:
  - https://docs.anthropic.com/en/docs/claude-code/settings
- MiniMax Claude Code docs:
  - https://platform.minimax.io/docs/coding-plan/claude-code
- Ollama Anthropic compatibility docs:
  - https://docs.ollama.com/openai#anthropic-compatibility
- Ollama Claude Code integration docs:
  - https://docs.ollama.com/integrations/claude-code
- z.ai Claude Code docs:
  - https://docs.z.ai/scenario-example/develop-tools/claude
- z.ai Coding FAQ:
  - https://docs.z.ai/devpack/faq
- Full source registry for this repo:
  - `docs/SOURCES.md`
