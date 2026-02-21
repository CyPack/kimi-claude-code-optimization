# Lessons and Troubleshooting

Date: 2026-02-21

## Lesson 1: Auth Conflict (`claude.ai` token + API key)

- Symptom: `Auth conflict: Both a token (claude.ai) and an API key (ANTHROPIC_API_KEY) are set`
- Cause: Logged in to `claude.ai` while `ANTHROPIC_API_KEY` is also configured.
- Fix:
  1. `claude auth logout`
  2. Keep `ANTHROPIC_BASE_URL` and `ANTHROPIC_API_KEY` in `~/.claude/settings.local.json`
  3. Restart Claude Code session

## Lesson 2: UI Label Says Sonnet

- Symptom: Header still shows Sonnet-style label.
- Cause: UI/compat label can differ from backend route.
- Fix:
  1. Pin model to `kimi-for-coding` in `~/.claude/settings.json`
  2. Verify runtime, not only UI label:
     - `claude -p "One line: model id only"` should return `kimi-for-coding`

## Lesson 3: Kimi CLI Says \"I am Claude\"

- Symptom: Kimi CLI textual reply claims it is Claude.
- Cause: Self-identification error in model response (content mistake), not provider switch.
- Fix:
  1. Check Kimi config: `~/.kimi/config.toml`
  2. Check Kimi logs: `~/.kimi/logs/kimi.log`
  3. Confirm lines include:
     - `Using LLM provider: type='kimi' base_url='https://api.kimi.com/coding/v1'`
     - `Using LLM model: ... model='kimi-for-coding'`

## Lesson 4: Safe Verification Pattern

- Prefer deterministic checks over conversational self-report.
- Use this checklist:
  1. `claude auth status` must be logged out if using API key route only.
  2. `~/.claude/settings.local.json` must contain Kimi base URL and API key.
  3. `claude -p "One line: model id only"` should return `kimi-for-coding`.
  4. Kimi CLI logs should show provider `type='kimi'`.

## Lesson 5: `ToolSearch` Path Causes 400 on Kimi

- Symptom: SOR flow starts, then crashes with:
  `API Error: 400 {"error":{"type":"invalid_request_error","message":"Invalid request Error"}}`
- Cause: `ToolSearch -> tool_reference` path can fail on `kimi-for-coding` before direct MCP call.
- Fix:
  1. Permanent: deny `ToolSearch` in `$HOME/.claude/settings.json`
  2. Runtime alternative: `--disallowed-tools ToolSearch`
  3. Fallback: strict `--allowed-tools` for exact MCP tool

## Lesson 6: SOR Flow Scope Must Exclude `File case/`

- Symptom: Assistant mentions/scans `input/File case/` during normal SOR upload request.
- Cause: Skill context includes both standard upload and file-case workflows.
- Fix:
  1. Add explicit scope guard in `voorinfra-upload` skill:
     - If user does not say `"file case"` / `"dosya case"`, do not inspect that folder.
  2. For generic request, execute only `batch_upload()` default main input flow.

## Lesson 7: 10-Agent Swarm'da "Completed" != "Results Collected"

- Symptom: "Agents Completed: 10" ama detaylı sonuç yalnızca bir kısmı geliyor.
- Cause:
  1. `TaskOutput` yanlış ID ile çağrılıyor (synthetic name yerine gerçek `agentId` gerekli)
  2. Çoklu sibling `TaskOutput` çağrısı zincir hatası üretebiliyor
- Fix:
  1. Her `Task` sonucundan gerçek `agentId` sakla
  2. `TaskOutput` çağrılarını `agentId` ile yap
  3. Çıktı toplamayı sequential veya küçük batch + retry ile yap
  4. Tüm output toplanmadıysa `PARTIAL` de, `SUCCESS` deme

## Lesson 8: Kimi Swarm İçin ToolSearch'i Tamamen Kapat

- Symptom: Arada orchestration sırasında beklenmedik request path sapmaları
- Cause: Tool discovery akışı Kimi endpoint ile bazı senaryolarda kırılgan
- Fix:
  1. `ENABLE_TOOL_SEARCH=0`
  2. `permissions.deny` içinde `ToolSearch` kalmalı
  3. Orchestration için `/custom:kimi-swarm` protokolünü kullan

## Lesson 9: MiniMax Uses `ANTHROPIC_AUTH_TOKEN` (Not `ANTHROPIC_API_KEY`)

- Symptom: MiniMax profile looks active but requests fail/auth mismatch appears.
- Cause: MiniMax Claude Code flow expects `ANTHROPIC_AUTH_TOKEN` as primary token variable.
- Fix:
  1. Set `ANTHROPIC_AUTH_TOKEN` in `~/.claude/settings.local.json`
  2. Set `ANTHROPIC_BASE_URL=https://api.minimax.io/anthropic`
  3. Remove `ANTHROPIC_API_KEY` from active env for MiniMax profile to avoid ambiguity

## Lesson 10: Auto-Migrate Legacy MiniMax Base URL

- Symptom: After switching to MiniMax, status shows old endpoint `https://api.minimax.chat/v1`.
- Cause: Old value restored from local stash/profile.
- Fix:
  1. Treat `api.minimax.chat` as legacy value
  2. Force-update to `https://api.minimax.io/anthropic` during `cc-provider minimax`
  3. Re-check with `cc-provider status`

## Lesson 11: Provider Guess Must Clear Model Pins on Claude Switch

- Symptom: `cc-provider claude` completed but provider guess still shows `minimax`.
- Cause: MiniMax model pin vars remained in `settings.json` env block.
- Fix:
  1. On Claude switch, remove:
     - `ANTHROPIC_MODEL`
     - `ANTHROPIC_SMALL_FAST_MODEL`
     - `ANTHROPIC_DEFAULT_HAIKU_MODEL`
     - `ANTHROPIC_DEFAULT_SONNET_MODEL`
     - `ANTHROPIC_DEFAULT_OPUS_MODEL`
     - `CLAUDE_CODE_SUBAGENT_MODEL`
  2. Re-run `cc-provider status` and verify active profile guess is `claude`

## Lesson 12: MiniMax Switch Must Remove Legacy `ANTHROPIC_API_KEY`

- Symptom: Claude Code shows:
  `Auth conflict: Both a token (ANTHROPIC_AUTH_TOKEN) and an API key (ANTHROPIC_API_KEY) are set`
- Cause: During MiniMax switch, `ANTHROPIC_AUTH_TOKEN` was set but stale `ANTHROPIC_API_KEY` stayed in active local env.
- Fix:
  1. In `switch_to_minimax()`, when token exists:
     - set `.env.ANTHROPIC_AUTH_TOKEN`
     - remove `.env.ANTHROPIC_API_KEY`
  2. Verify with:
     - `jq '.env | {ANTHROPIC_AUTH_TOKEN_set: has("ANTHROPIC_AUTH_TOKEN"), ANTHROPIC_API_KEY_set: has("ANTHROPIC_API_KEY")}' ~/.claude/settings.local.json`
  3. If warning persists in an already-open shell session:
     - `unset ANTHROPIC_API_KEY`

## Lesson 13: Track Official Sources to Prevent Drift

- Symptom: One year later docs/scripts diverge from provider reality.
- Cause: Settings and endpoint behavior changed upstream without local refresh cycle.
- Fix:
  1. Keep `docs/SOURCES.md` as single source registry.
  2. Re-verify official URLs monthly.
  3. If any provider requirement changes, update script + docs + release notes together.

## Lesson 14: Ollama Works via Anthropic-Compatible Endpoint

- Symptom: Unclear whether Claude Code can run against local Ollama.
- Cause: Older assumptions required third-party adapters.
- Fix:
  1. Use official Ollama Anthropic compatibility path:
     - `ANTHROPIC_BASE_URL=http://localhost:11434/anthropic`
     - `ANTHROPIC_AUTH_TOKEN=ollama`
  2. Prefer repository switch command:
     - `cc-provider ollama`
  3. Validate runtime and local model availability:
     - `ollama pull <model>`
     - `cc-provider status`

## Lesson 15: z.ai "Already Active" Can Still Need Repair

- Symptom: `cc-provider zai` says already active, but requests fail with:
  `API Error: 400 {"error":{"code":"1211","message":"Unknown Model, please check the model code."}}`
- Cause: stale `ANTHROPIC_MODEL` / `ANTHROPIC_SMALL_FAST_MODEL` pins (for example from MiniMax) can survive and override z.ai mapping.
- Fix:
  1. Add z.ai freshness check in `scripts/cc-provider`
  2. If z.ai is detected but stale pins exist, auto-reapply profile
  3. Ensure z.ai switch clears stale model-pin keys before applying GLM mapping

## Lesson 16: `claude -p` API Route Needs Shell Token Export

- Symptom: `claude -p ...` returns `Not logged in · Please run /login` even when `~/.claude/settings.local.json` contains API token/base URL.
- Cause: print-mode API auth can depend on shell-exported env in this setup.
- Fix:
  1. Read token/base URL from local settings
  2. Export inline only for command scope:
     - `ANTHROPIC_AUTH_TOKEN=... ANTHROPIC_BASE_URL=... claude -p ...`
  3. Keep secrets out of repository and logs

## Lesson 17: Deterministic Worktree Validation Should Use Git Commands

- Symptom: `claude --worktree <name> -p ...` can still show main path/branch in output.
- Cause: print-mode session behavior may not expose persistent worktree isolation clearly.
- Fix:
  1. Validate worktree using explicit Bash flow:
     - `git worktree add ...`
     - `git -C <wt> branch --show-current`
     - cleanup (`git worktree remove`, `git branch -D`)
  2. Use model tool-call smoke test to verify end-to-end execution (`ADD=ok`, `CLEANUP=ok`)

## Lesson 18: Multi-Agent and MCP Need Debug Evidence, Not Only Chat Text

- Symptom: chat says "spawned/completed", but reliability is unclear.
- Cause: result text alone can hide orchestration gaps.
- Fix:
  1. Run with `--debug-file`
  2. For multi-agent, verify `Task` + `SubagentStart/SubagentStop` entries in logs
  3. For MCP, verify concrete tool call line (example: `mcp__sequential-thinking__sequentialthinking`)
  4. Record both human-readable result and debug proof in action log

## Lesson 19: Provider Switch Should Also Align GSD Model Profile

- Symptom: Claude Code provider changed, but `/gsd:*` flows still behave with old planning model profile.
- Cause: provider switch and `.planning/config.json` model_profile were managed separately.
- Fix:
  1. Run automatic GSD sync inside `cc-provider` on every switch (including no-op).
  2. Map defaults:
     - `claude -> balanced`
     - `kimi|minimax|zai|ollama -> budget`
  3. Update both project config (`<cwd>/.planning/config.json`) and global defaults (`~/.gsd/defaults.json`).

## Quick Health Commands

```bash
claude auth status
jq '.env | {ANTHROPIC_BASE_URL, ANTHROPIC_API_KEY_set: has("ANTHROPIC_API_KEY")}' $HOME/.claude/settings.local.json
jq '{model, env: (.env | {ANTHROPIC_DEFAULT_HAIKU_MODEL, ANTHROPIC_DEFAULT_SONNET_MODEL, CLAUDE_CODE_SUBAGENT_MODEL})}' $HOME/.claude/settings.json
claude -p "One line: model id only" --output-format text
jq '.permissions | {allow, deny}' $HOME/.claude/settings.json
jq '.env.ENABLE_TOOL_SEARCH' $HOME/.claude/settings.json
claude -p "SOR dosyalarini yukle. File case'e dokunma." --dangerously-skip-permissions
jq '.env | {ANTHROPIC_AUTH_TOKEN_set: has("ANTHROPIC_AUTH_TOKEN"), ANTHROPIC_BASE_URL}' $HOME/.claude/settings.local.json
jq '.env | {ANTHROPIC_AUTH_TOKEN_set: has("ANTHROPIC_AUTH_TOKEN"), ANTHROPIC_API_KEY_set: has("ANTHROPIC_API_KEY"), ANTHROPIC_BASE_URL}' $HOME/.claude/settings.local.json
ollama --version
cc-provider ollama
```
