# Release Notes

## v1.9.2 - 2026-02-21

### Added

- Automatic GSD profile sync inside `cc-provider` switches.
- Provider to GSD mapping defaults:
  - `claude` -> `balanced`
  - `kimi|minimax|zai|ollama` -> `budget`

### Changed

- `cc-provider` now updates:
  - project `.planning/config.json` (when available)
  - global `$HOME/.gsd/defaults.json`
- No-op switches also run GSD sync so project defaults stay aligned.

## v1.9.1 - 2026-02-21

### Fixed

- z.ai profile self-heal when provider is already active but stale model pins remain:
  - prevents `Unknown Model (1211)` caused by old `ANTHROPIC_MODEL` values.
- z.ai switch now clears stale local model-pin env keys before applying GLM mapping.

### Verified

- z.ai smoke call in Claude Code print mode:
  - `zai_smoke_ok`
- 4-way parallel sub-agent spawn in one prompt with full result collection.
- MCP tool usage (`mcp__sequential-thinking__sequentialthinking`) with debug evidence.
- Git worktree lifecycle via model tool-call (`add -> verify branch -> cleanup`).

## v1.9.0 - 2026-02-21

### Added

- z.ai provider switch support:
  - `cc-provider zai`
  - `cc-zai` alias
- z.ai integration guide:
  - `docs/ZAI_CLAUDE_CODE.md`
- z.ai brand logo in README hero with API key page redirect.

### Changed

- `scripts/cc-provider` now supports `Kimi <-> Claude <-> MiniMax <-> z.ai <-> Ollama`.
- Installer scripts include `cc-zai`.
- Source registry includes official z.ai docs and API key references.

## v1.8.0 - 2026-02-21

### Added

- Official source registry:
  - `docs/SOURCES.md`
- Ollama integration guide:
  - `docs/OLLAMA_CLAUDE_CODE.md`
- Ollama switch support:
  - `cc-provider ollama`
  - `cc-ollama` alias

### Changed

- Project naming updated to OpenSource Providers scope.
- `scripts/cc-provider` now supports `Kimi <-> Claude <-> MiniMax <-> Ollama`.
- Installer scripts include `cc-ollama`.
- Top-level and operational docs now include reference-backed update workflow.

## v1.7.0 - 2026-02-21

### Changed

- Reworked top-level `README.md` into a visual welcome page.
- Added logo row for:
  - Claude Code (Anthropic)
  - Kimi
  - MiniMax
  - Ollama
- Improved human-friendly and agent-friendly onboarding sections.
- Added clearer quick install/quick use flow at top-level.

## v1.6.0 - 2026-02-21

### Added

- Idempotent provider switch behavior:
  - If target provider is already active, switch is skipped with explicit notice.
- Transition notification output after each real switch:
  - previous provider/API base URL
  - current provider/API base URL

### Changed

- `scripts/cc-provider` now reports no-op and transition summaries for user clarity.
- Docs updated with notification behavior and agent handling notes.

## v1.5.0 - 2026-02-21

### Added

- Installer scripts for human/agent-friendly rollout:
  - `scripts/install-switch.sh` (local clone install)
  - `scripts/install-from-github.sh` (one-command remote install)
- New install guide:
  - `docs/INSTALLATION.md`

### Changed

- `README.md` quick start now includes one-command installer.
- `docs/PROFILE_SWITCHING.md` now links installation methods.
- `AGENTS.md` now includes explicit agent switch protocol.
- `agent-manifest.json` upgraded to `1.5.0` with installer metadata.

## v1.4.0 - 2026-02-21

### Added

- `cc-provider` MiniMax profile commands:
  - `cc-provider minimax`
  - `cc-provider mini`
- New alias scripts:
  - `scripts/cc-mini`
  - `scripts/cc-minimax`
- Provider-specific secret stash support:
  - `kimi-secrets.json`
  - `minimax-secrets.json`

### Changed

- Switch flow now supports `Kimi <-> Claude <-> MiniMax`.
- Docs and agent metadata updated for MiniMax-capable switching.

## v1.3.0 - 2026-02-21

### Added

- Provider switch automation scripts:
  - `scripts/cc-provider`
  - `scripts/cc-kimi`
  - `scripts/cc-claude`
- New guide: `docs/PROFILE_SWITCHING.md`
- README and docs updates for one-command `Kimi <-> Claude` switching.

### Changed

- `agent-manifest.json` upgraded to `1.3.0` with utility metadata.
- `llms.txt` index expanded with profile switching documentation.
- `docs/README.md` now documents backup behavior and auth-conflict-safe switching.

### Notes

- No credentials or secrets are stored in this repository.
- Runtime backups are created locally under `$HOME/.claude/backups/provider-switch-*`.
- Next planned feature: `MiniMax 2.5` profile addition to `cc-provider`.

## v1.2.0 - 2026-02-21

### Added

- Synced latest sanitized `kimi-ops` docs:
  - `docs/README.md`
  - `docs/ACTIONS_LOG.md`
  - `docs/LESSONS.md`
  - `docs/BACKUPS.md`
  - `docs/SWARM_OPTIMIZATION.md` (new)
- Documented commandless autonomous orchestration mode in repository content.
- Updated top-level `README.md` repo map and outcomes.

### Notes

- No credentials or tokens added.
- Paths remain normalized with `$HOME` placeholder.

## v1.1.0 - 2026-02-21

### Added

- Expanded top-level `README.md` with:
  - purpose
  - verified outcomes
  - quick start
  - limitations
  - repo map
- `AGENTS.md` for AI-agent execution guidance.
- `agent-manifest.json` for machine-readable repository capabilities.
- `llms.txt` for lightweight LLM indexing/retrieval.
- `RELEASE_NOTES.md` (this file).

### Notes

- Existing docs in `docs/` remain the source operational record:
  - `docs/README.md`
  - `docs/ACTIONS_LOG.md`
  - `docs/LESSONS.md`
  - `docs/BACKUPS.md`

## v1.0.0 - 2026-02-21

### Initial Public Baseline

- Created repository with sanitized Kimi + Claude Code optimization docs.
- Included operational timeline, backup notes, and troubleshooting lessons.
