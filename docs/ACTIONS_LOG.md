# Actions Log

Date: 2026-02-21

## What Was Done

1. Inspected current Claude Code configuration and auth status.
2. Collected and reviewed active config files (`~/.claude/settings.json`, `~/.claude/settings.local.json`).
3. Added Kimi provider settings:
   - `ANTHROPIC_BASE_URL=https://api.kimi.com/coding/`
   - `ANTHROPIC_API_KEY` in `settings.local.json`
4. Removed auth conflict by logging out from `claude.ai`:
   - `claude auth logout`
5. Set model pins to Kimi-compatible values:
   - `model = "kimi-for-coding"`
   - `ANTHROPIC_DEFAULT_HAIKU_MODEL = "kimi-for-coding"`
   - `ANTHROPIC_DEFAULT_SONNET_MODEL = "kimi-for-coding"`
   - `CLAUDE_CODE_SUBAGENT_MODEL = "kimi-for-coding"`
6. Verified runtime behavior:
   - `claude -p "Reply with exactly: KIMI_FINAL_OK"` => `KIMI_FINAL_OK`
   - `claude -p "One line: model id only"` => `kimi-for-coding`
7. Verified Kimi CLI state from Kimi logs/config:
   - Provider and model shown as `type='kimi'`, `base_url='https://api.kimi.com/coding/v1'`, `model='kimi-for-coding'`
8. Reproduced SOR upload error with stream trace:
   - Command: `claude -p "SOR dosyalarini yukle" --verbose --output-format stream-json`
   - Error: `API Error: 400 {"error":{"type":"invalid_request_error","message":"Invalid request Error"}}`
9. Isolated failure point:
   - Failure happens right after `ToolSearch` returns `tool_reference` entries.
   - Error occurs before actual `mcp__VoorinfraAPIServer__batch_upload` execution.
10. Verified MCP status independently:
    - `VoorinfraAPIServer`: connected
    - `VoorinfraServer`: failed (not used in API upload path)
11. Tested `ENABLE_TOOL_SEARCH=0` runtime flag:
    - Result: model still attempted `ToolSearch`, same 400 path.
12. Applied reliable runtime workaround:
    - Command: `claude -p "SOR dosyalarini yukle" --verbose --output-format stream-json --disallowedTools ToolSearch`
13. Verified successful upload under workaround:
    - `2313DH_1_V1.SOR` uploaded
    - `opdracht_id: 243160`
    - `uploaded: 1, skipped: 0, failed: 0`
14. Created extra safety snapshot:
    - `$HOME/.claude/backups/settings.json.20260221-105733.bak`
15. Created pre-change backup before permanent ToolSearch fix:
    - `$HOME/.claude/backups/settings.json.20260221-110129.pre-toolsearch-disable.bak`
16. Applied permanent local mitigation in `$HOME/.claude/settings.json`:
    - Removed `ToolSearch` from `permissions.allow`
    - Added `ToolSearch` to `permissions.deny`
17. User scope requirement added:
    - Generic SOR upload flow must not inspect or touch `input/File case/`
    - Updated `$HOME/.claude/skills/voorinfra-upload/SKILL.md` with explicit scope guard
18. Post-fix verification (no CLI flag override):
    - `claude -p "SOR dosyalarini yukle. File case'e dokunma..." --dangerously-skip-permissions`
    - Result: completed without 400
    - File result: `2313DH_1_V1.SOR` => skipped (already uploaded), `failed: 0`
19. Applied Kimi swarm optimization profile:
    - `ENABLE_TOOL_SEARCH` changed from `auto:1` to `0` in `$HOME/.claude/settings.json`
20. Added custom robust orchestration command:
    - `$HOME/.claude/commands/custom/kimi-swarm.md`
    - Focus: real `agentId` tracking + resilient `TaskOutput` collection
21. Added optimization runbook:
    - `$HOME/kimi-ops/SWARM_OPTIMIZATION.md`
22. Created pre-change backup before swarm optimization:
    - `$HOME/.claude/backups/settings.json.20260221-115839.pre-swarm-opt.bak`
23. Added global autonomous orchestration rule:
    - `$HOME/.claude/rules/autonomous-orchestration.md`
    - Goal: commandless auto-spawn for complex tasks and explicit "agent spawn" requests
24. Updated swarm optimization runbook to include commandless autonomous mode.
25. Added official provider switching utilities and installation commands to repository docs.
26. Added MiniMax provider profile support with separate local stash:
    - `$HOME/.claude/profiles/minimax-secrets.json`
27. Added no-op and transition notices for `cc-provider` switching:
    - "already active" guard
    - previous -> current provider/API summary
28. Aligned MiniMax switch flow with official Claude Code docs:
    - `model = MiniMax-M2.5`
    - `ANTHROPIC_AUTH_TOKEN` primary credential
    - `ANTHROPIC_BASE_URL = https://api.minimax.io/anthropic`
29. Added migration logic for legacy MiniMax URL:
    - auto-upgrade `https://api.minimax.chat/v1` -> `https://api.minimax.io/anthropic`
30. Fixed provider-guess false positive after Claude switch:
    - clear MiniMax model-pin env vars when switching to `claude`
31. Added README official provider links block and logo click-through links:
    - Kimi logo -> Kimi code console
    - MiniMax logo -> MiniMax coding plan
32. Fixed MiniMax auth-conflict recurrence on profile switch:
    - Root cause: stale `ANTHROPIC_API_KEY` persisted beside `ANTHROPIC_AUTH_TOKEN`
    - Patch: remove `ANTHROPIC_API_KEY` when setting MiniMax auth token
    - Verification: `ANTHROPIC_AUTH_TOKEN` present, `ANTHROPIC_API_KEY` absent, smoke test passes
33. Renamed project scope from "all providers" to "opensource providers":
    - Updated repository title strings and installer/raw URLs
    - Updated references to new slug `claude-code-optimization-for-opensource-providers`
34. Added source governance for long-term maintenance:
    - New `docs/SOURCES.md` with official provider/documentation links
    - Added update cadence and change protocol
35. Added Ollama provider switching support to `cc-provider`:
    - New command: `cc-provider ollama`
    - New alias: `cc-ollama`
    - Defaults: `OLLAMA_MODEL=qwen3-coder`, `http://localhost:11434/anthropic`, token `ollama`
36. Added dedicated Ollama integration documentation:
    - `docs/OLLAMA_CLAUDE_CODE.md`
    - Updated top-level README and install/profile docs for Ollama flow
37. Added z.ai provider support end-to-end:
    - New command: `cc-provider zai`
    - New alias: `cc-zai`
    - New guide: `docs/ZAI_CLAUDE_CODE.md`
    - Added z.ai logo and API key link in README hero
38. Added z.ai source governance references:
    - z.ai Claude Code docs
    - z.ai FAQ
    - z.ai API key page
39. Fixed z.ai stale-pin edge case in switch logic:
    - Added `zai_profile_is_fresh()` in `scripts/cc-provider`
    - If z.ai is active but stale model pins exist, switch now re-applies profile instead of no-op
40. Re-validated idempotent switch behavior:
    - `cc-provider zai` now returns clean no-op when profile is truly fresh
    - `cc-provider claude` -> `cc-provider zai` transition summary verified
41. Verified z.ai runtime auth/model smoke (API route):
    - Inline env export from local settings used for `claude -p` tests
    - `claude -p "Reply with exactly: zai_smoke_ok" --model sonnet` => `zai_smoke_ok`
42. Verified multi-agent orchestration under z.ai:
    - Spawned 4 parallel subagents in one prompt
    - All 4 completed with collected results
    - Debug evidence includes `Task`, `SubagentStart`, `SubagentStop` traces
43. Verified MCP runtime under z.ai:
    - `claude mcp list` executed successfully and reported server health
    - Prompt-driven MCP tool call succeeded:
      - `mcp__sequential-thinking__sequentialthinking`
44. Verified worktree operations through tool-call flow:
    - Model executed:
      - `git worktree add /tmp/cc-zai-worktree-smoke -b cc-zai-wt-smoke`
      - branch check
      - cleanup remove + branch delete
    - Final result: `ADD=ok`, `BRANCH=cc-zai-wt-smoke`, `CLEANUP=ok`
45. Added automatic GSD profile sync to `cc-provider`:
    - Provider switch now aligns GSD `model_profile` automatically
    - Mapping defaults:
      - `claude -> balanced`
      - `kimi|minimax|zai|ollama -> budget`
46. Added dual-target GSD sync behavior:
    - Project target: `<cwd>/.planning/config.json` (when present)
    - Global default target: `$HOME/.gsd/defaults.json`
47. Added override controls for advanced usage:
    - `CC_PROVIDER_GSD_CWD`, `GSD_DEFAULTS_FILE`, `GSD_TOOLS_BIN`
    - `GSD_PROFILE_*` provider-specific profile overrides

## Important Notes

- No Kimi secret values are stored in this folder.
- Your shared key in chat should be rotated later for security.
- For Kimi + MCP-heavy workflows, keep `ToolSearch` disabled (now permanent in local settings).
- For z.ai smoke tests in this environment, prefer inline command-scoped auth export from local settings.
