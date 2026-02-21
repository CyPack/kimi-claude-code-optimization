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

## Quick Health Commands

```bash
claude auth status
jq '.env | {ANTHROPIC_BASE_URL, ANTHROPIC_API_KEY_set: has("ANTHROPIC_API_KEY")}' $HOME/.claude/settings.local.json
jq '{model, env: (.env | {ANTHROPIC_DEFAULT_HAIKU_MODEL, ANTHROPIC_DEFAULT_SONNET_MODEL, CLAUDE_CODE_SUBAGENT_MODEL})}' $HOME/.claude/settings.json
claude -p "One line: model id only" --output-format text
jq '.permissions | {allow, deny}' $HOME/.claude/settings.json
claude -p "SOR dosyalarini yukle. File case'e dokunma." --dangerously-skip-permissions
```
