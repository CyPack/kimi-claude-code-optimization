# Provider Ops Dossier

Last updated: 2026-02-21

This folder records provider switching setup, backups, and troubleshooting notes for local Claude Code CLI workflows.

## Current Effective State

- `claude auth status`: logged out (`loggedIn: false`)
- Active provider (latest validation): `zai`
  - `ANTHROPIC_BASE_URL=https://api.z.ai/api/anthropic`
  - `model=sonnet`
  - default mapping: haiku=`GLM-4.5-Air`, sonnet/opus=`GLM-4.7`
- Runtime verification (z.ai):
  - `claude -p "Reply with exactly: zai_smoke_ok" --model sonnet` => `zai_smoke_ok`
- Orchestration verification (z.ai):
  - 4 parallel subagents spawned and completed in a single prompt (`Task` + `SubagentStart/SubagentStop` traces confirmed)
- MCP verification (z.ai):
  - `claude mcp list` succeeded
  - `mcp__sequential-thinking__sequentialthinking` tool call succeeded
- Worktree verification (z.ai tool-call flow):
  - `git worktree add -> branch check -> cleanup` succeeded (`ADD=ok`, `CLEANUP=ok`)
- Known Kimi compatibility issue still tracked:
  - `ToolSearch -> tool_reference` path can trigger HTTP 400 on Kimi stack
  - mitigation remains: disable `ToolSearch` for Kimi profile

## MCP Snapshot (Relevant)

- `VoorinfraAPIServer`: connected (this is the server used for SOR upload flow)
- `VoorinfraServer`: failed to connect (legacy server, not required for API upload flow)

## Main Config Files

- `$HOME/.claude/settings.json`
- `$HOME/.claude/settings.local.json`
- `$HOME/.claude/profiles/kimi-secrets.json` (created by switch script)
- `$HOME/.claude/.credentials.json`
- `$HOME/.config/Claude/config.json`
- `$HOME/.kimi/config.toml`
- `$HOME/.kimi/credentials/kimi-code.json`
- `$HOME/.kimi/logs/kimi.log`

## Documents In This Folder

- `docs/ACTIONS_LOG.md`
- `docs/BACKUPS.md`
- `docs/LESSONS.md`
- `docs/SWARM_OPTIMIZATION.md`

Additional repository docs:

- `docs/SOURCES.md` (official source registry + update cadence)
- `docs/OLLAMA_CLAUDE_CODE.md` (Ollama integration guide)
- `docs/ZAI_CLAUDE_CODE.md` (z.ai integration guide)

## Fast Provider Switching (Kimi <-> Claude <-> MiniMax <-> z.ai <-> Ollama)

- Script: `$HOME/.local/bin/cc-provider` (repo source: `scripts/cc-provider`)
- Install:
  - Local clone: `bash scripts/install-switch.sh`
  - Remote one-command: `bash -c "$(curl -fsSL https://raw.githubusercontent.com/CyPack/claude-code-optimization-for-opensource-providers/main/scripts/install-from-github.sh)"`
  - Full guide: `docs/INSTALLATION.md`
- Commands:
  - `cc-provider status`
  - `cc-provider kimi`
  - `cc-provider claude`
  - `cc-provider minimax` (or `cc-provider mini`)
  - `cc-provider zai`
  - `cc-provider ollama`
- Convenience aliases:
  - `cc-kimi`
  - `cc-claude`
  - `cc-mini`
  - `cc-minimax`
  - `cc-zai`
  - `cc-ollama`

Behavior guarantees:
- On every switch, backups are saved under:
  - `$HOME/.claude/backups/provider-switch-YYYYmmdd-HHMMSS-XXXXXX/`
- Switching to `claude`:
  - Restores Claude-friendly model defaults
  - Re-enables `ToolSearch`
  - Removes `ANTHROPIC_API_KEY`, `ANTHROPIC_AUTH_TOKEN`, and `ANTHROPIC_BASE_URL` from active local env to avoid auth conflict
  - Stores Kimi secrets in `$HOME/.claude/profiles/kimi-secrets.json` (0600)
- Switching to `kimi`:
  - Applies `kimi-for-coding` model pins
  - Applies Kimi base URL
  - Disables `ToolSearch` for compatibility
  - Restores saved Kimi secrets from profile stash if available
- Switching to `minimax`:
  - Applies `MiniMax-M2.5` model pins (configurable via `MINIMAX_MODEL`)
  - Applies MiniMax base URL default (`https://api.minimax.io/anthropic`, configurable via `MINIMAX_BASE_URL_DEFAULT`)
  - Auto-migrates legacy `https://api.minimax.chat/v1` entries to the new base URL
  - Uses `ANTHROPIC_AUTH_TOKEN` as primary credential var (fallback compatible with `ANTHROPIC_API_KEY`)
  - Keeps `ToolSearch` enabled
  - Restores saved MiniMax secrets from profile stash if available
- Switching to `zai`:
  - Applies z.ai Anthropic-compatible URL default (`https://api.z.ai/api/anthropic`, configurable via `ZAI_BASE_URL_DEFAULT`)
  - Uses `ANTHROPIC_AUTH_TOKEN` as primary credential var
  - Applies model mapping defaults:
    - haiku=`GLM-4.5-Air`
    - sonnet=`GLM-4.7`
    - opus=`GLM-4.7`
  - Keeps `ToolSearch` enabled
  - Restores saved z.ai URL/token from profile stash if available
- Switching to `ollama`:
  - Applies `qwen3-coder` model pins (configurable via `OLLAMA_MODEL`)
  - Applies Ollama Anthropic-compatible URL default (`http://localhost:11434/anthropic`, configurable via `OLLAMA_BASE_URL_DEFAULT`)
  - Applies default auth token `ollama` (configurable via `OLLAMA_AUTH_TOKEN_DEFAULT`)
  - Keeps `ToolSearch` enabled
  - Restores saved Ollama URL/token from profile stash if available
- Every provider switch also performs GSD model_profile sync:
  - Project `.planning/config.json` (if present)
  - Global `$HOME/.gsd/defaults.json`

## Stable Runtime Patterns

z.ai smoke pattern:

```bash
token="$(jq -r '.env.ANTHROPIC_AUTH_TOKEN // empty' $HOME/.claude/settings.local.json)"
base="$(jq -r '.env.ANTHROPIC_BASE_URL // empty' $HOME/.claude/settings.local.json)"
ANTHROPIC_AUTH_TOKEN="$token" ANTHROPIC_BASE_URL="$base" \
  claude -p "Reply with exactly: zai_ok" --model sonnet
```

Kimi SOR pattern:

```bash
# Current default already denies ToolSearch in settings.json
claude -p "SOR dosyalarini yukle"

# Alternative: strict allowlist for exact tool path
claude -p "SOR dosyalarini yukle" \
  --allowed-tools mcp__VoorinfraAPIServer__batch_upload,Bash,Read,Grep,Glob
```
