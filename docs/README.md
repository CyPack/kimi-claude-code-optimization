# Kimi Ops Dossier

Last updated: 2026-02-21

This folder records the Kimi setup, backups, and troubleshooting notes for your local CLI setup.

## Current Effective State

- `claude auth status`: logged out (`loggedIn: false`)
- Active provider base URL: `https://api.kimi.com/coding/`
- API key is present in `~/.claude/settings.local.json` (stored, redacted here)
- Default model pins are set to `kimi-for-coding` in `~/.claude/settings.json`
- Runtime verification: `claude -p "One line: model id only"` returns `kimi-for-coding`
- Known Kimi compatibility issue: `ToolSearch -> tool_reference` path can trigger
  `API Error: 400 {"error":{"type":"invalid_request_error","message":"Invalid request Error"}}`
- Permanent local mitigation applied: `ToolSearch` removed from allow and added to deny
  in `$HOME/.claude/settings.json`
- Last verified production action with workaround: `2313DH_1_V1.SOR` uploaded successfully
  via `mcp__VoorinfraAPIServer__batch_upload` (opdracht_id `243160`)
- Latest verification after permanent mitigation:
  `2313DH_1_V1.SOR` processed without 400 (already uploaded, skipped as expected)
- Scope rule enforced: generic `"SOR dosyalarini yukle"` flow must not touch `input/File case/`
- Swarm optimization applied for Kimi:
  - `ENABLE_TOOL_SEARCH=0`
  - `/custom:kimi-swarm` command added for robust 10-agent orchestration

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

- `$HOME/kimi-ops/ACTIONS_LOG.md`
- `$HOME/kimi-ops/BACKUPS.md`
- `$HOME/kimi-ops/LESSONS.md`
- `$HOME/kimi-ops/SWARM_OPTIMIZATION.md`

## Fast Provider Switching (Kimi <-> Claude <-> MiniMax)

- Script: `$HOME/.local/bin/cc-provider` (repo source: `scripts/cc-provider`)
- Install:
  - Local clone: `bash scripts/install-switch.sh`
  - Remote one-command: `bash -c "$(curl -fsSL https://raw.githubusercontent.com/CyPack/claude-code-optimization-for-all-providers/main/scripts/install-from-github.sh)"`
  - Full guide: `docs/INSTALLATION.md`
- Commands:
  - `cc-provider status`
  - `cc-provider kimi`
  - `cc-provider claude`
  - `cc-provider minimax` (or `cc-provider mini`)
- Convenience aliases:
  - `cc-kimi`
  - `cc-claude`
  - `cc-mini`
  - `cc-minimax`

Behavior guarantees:
- On every switch, backups are saved under:
  - `$HOME/.claude/backups/provider-switch-YYYYmmdd-HHMMSS-XXXXXX/`
- Switching to `claude`:
  - Restores Claude-friendly model defaults
  - Re-enables `ToolSearch`
  - Removes `ANTHROPIC_API_KEY` and `ANTHROPIC_BASE_URL` from active local env to avoid auth conflict
  - Stores Kimi secrets in `$HOME/.claude/profiles/kimi-secrets.json` (0600)
- Switching to `kimi`:
  - Applies `kimi-for-coding` model pins
  - Applies Kimi base URL
  - Disables `ToolSearch` for compatibility
  - Restores saved Kimi secrets from profile stash if available
- Switching to `minimax`:
  - Applies `minimax-2.5` model pins (configurable)
  - Applies MiniMax base URL default (`https://api.minimax.chat/v1`, configurable)
  - Keeps `ToolSearch` enabled
  - Restores saved MiniMax secrets from profile stash if available

## Stable Runtime Patterns (Kimi)

```bash
# Current default already denies ToolSearch in settings.json
claude -p "SOR dosyalarini yukle"

# Alternative: strict allowlist for exact tool path
claude -p "SOR dosyalarini yukle" \
  --allowed-tools mcp__VoorinfraAPIServer__batch_upload,Bash,Read,Grep,Glob
```
