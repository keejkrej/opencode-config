# opencode-config

Portable config for [opencode](https://opencode.ai), mirrored into `~/.config/opencode/`.

## Files

| File | Purpose | Copy to |
| --- | --- | --- |
| `opencode.jsonc` | Models (Vercel AI Gateway: Kimi as the default model, DeepSeek for built-in `explore`/`general`/`compaction`/`title`/`summary`) and MCP servers (paper via local `paper mcp`; ambient over local HTTP; mobbin over remote HTTP with OAuth; browse via local `browse mcp`) | `~/.config/opencode/opencode.jsonc` |
| `agents/build.md` | Primary `build` agent: Kimi orchestrator that plans, delegates and verifies; edits and shell are denied | `~/.config/opencode/agents/build.md` |
| `agents/worker.md` | `worker` subagent: DeepSeek implementer that edits, runs commands/tests and reports back | `~/.config/opencode/agents/worker.md` |
| `AGENTS.md` | Global instructions loaded in every session: the Ambient memory block | `~/.config/opencode/AGENTS.md` |

Provider credentials and other machine-local files (`node_modules/`, `package.json`,
`*.bak`, etc.) are not tracked; never commit credentials.

## New machine

Copy the tracked files into `~/.config/opencode/` (keeping the `agents/` folder), then
sign in to Vercel AI Gateway with `opencode auth login`.

The `paper` server runs the `paper` CLI that Paper Desktop installs into `~/.paper/bin`;
add that directory to `PATH` (on Windows: `%USERPROFILE%\.paper\bin` in the user `Path`).
The `browse` server runs the `browse` CLI from `~/.local/bin`; keep that directory on `PATH`
(on Windows: `%USERPROFILE%\.local\bin`) and install the browse extension in your Chrome-family browser.
Sign in to Mobbin once with `opencode mcp auth mobbin` (Pro/Team/Enterprise plan required).
Check everything with `opencode mcp list`.

## Agents

`build` is the default agent (`default_agent`). It never edits files or runs commands:
it inspects just enough context, delegates focused tasks to `worker` (implementation)
or `explore` (read-only research), then reviews their reports. To change models, edit
the `model` field in `opencode.jsonc` and the matching agent file.

## Ambient memory

The `ambient` server is the MCP endpoint inside the running [Ambient](https://alexandria.so)
desktop app (`http://127.0.0.1:8765/mcp`); its tools are unavailable when the app is closed.

`AGENTS.md` holds the same "always check Ambient memory" block Ambient writes into
Claude Code's `CLAUDE.md` and Codex's `AGENTS.md`. Ambient does not manage opencode,
so copy it into `~/.config/opencode/AGENTS.md` yourself.

The block is not refreshed when the app's wording changes: copy it again from
`ambient-app/electron/agent-global-instructions.ts` when needed.
