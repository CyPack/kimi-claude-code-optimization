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

## MCP Snapshot (Relevant)

- `VoorinfraAPIServer`: connected (this is the server used for SOR upload flow)
- `VoorinfraServer`: failed to connect (legacy server, not required for API upload flow)

## Main Config Files

- `$HOME/.claude/settings.json`
- `$HOME/.claude/settings.local.json`
- `$HOME/.claude/.credentials.json`
- `$HOME/.config/Claude/config.json`
- `$HOME/.kimi/config.toml`
- `$HOME/.kimi/credentials/kimi-code.json`
- `$HOME/.kimi/logs/kimi.log`

## Documents In This Folder

- `$HOME/kimi-ops/ACTIONS_LOG.md`
- `$HOME/kimi-ops/BACKUPS.md`
- `$HOME/kimi-ops/LESSONS.md`

## Stable Runtime Patterns (Kimi)

```bash
# Current default already denies ToolSearch in settings.json
claude -p "SOR dosyalarini yukle"

# Alternative: strict allowlist for exact tool path
claude -p "SOR dosyalarini yukle" \
  --allowed-tools mcp__VoorinfraAPIServer__batch_upload,Bash,Read,Grep,Glob
```
