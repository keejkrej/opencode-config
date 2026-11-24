# opencode-config

Portable config for [opencode](https://opencode.ai), mirrored into `~/.config/opencode/`.

## Files

| File | Purpose | Copy to |
| --- | --- | --- |
| `opencode.jsonc` | Models (Vercel AI Gateway: Kimi as the default model, DeepSeek for built-in `explore`/`general`/`compaction`/`title`/`summary`) and MCP servers (paper via local `paper mcp`; ambient over local HTTP; mobbin through `mcp-remote`, which owns the OAuth login; browse via local `browse mcp`) | `~/.config/opencode/opencode.jsonc` |
| `agents/build.md` | Primary `build` agent: Kimi orchestrator that plans, delegates and verifies; edits and shell are denied | `~/.config/opencode/agents/build.md` |
| `agents/worker.md` | `worker` subagent: DeepSeek implementer that edits, runs commands/tests and reports back | `~/.config/opencode/agents/worker.md` |
| `agents/reviewer.md` | `reviewer` subagent: an independent, read-only code reviewer with the same brief as the other agents' reviewers | `~/.config/opencode/agents/reviewer.md` |
| `AGENTS.md` | Global instructions loaded in every session: the Ambient memory block | `~/.config/opencode/AGENTS.md` |

Provider credentials and other machine-local files (`node_modules/`, `package.json`,
`*.bak`, etc.) are not tracked; never commit credentials.

## New machine

Run `./install.sh` (Git Bash, macOS, Linux) or `./install.ps1` (PowerShell): they copy the files
into `~/.config/opencode/` and back up anything they replace as `*.bak.<timestamp>`, including a
legacy `opencode.json`, which opencode would otherwise merge with `opencode.jsonc`. Nothing is
linked, so re-run the installer after editing. Then sign in to Vercel AI Gateway with
`opencode auth login`.

The `paper` server runs the `paper` CLI that Paper Desktop installs into `~/.paper/bin`;
add that directory to `PATH` (on Windows: `%USERPROFILE%\.paper\bin` in the user `Path`).
The `browse` server runs the `browse` CLI from `~/.local/bin`; keep that directory on `PATH`
(on Windows: `%USERPROFILE%\.local\bin`) and install the browse extension in your Chrome-family browser.
`mobbin` runs through [`mcp-remote`](https://github.com/geelen/mcp-remote). The first time opencode
starts it, a browser opens for the Mobbin login (Pro/Team/Enterprise plan required). The token is
stored once in `~/.mcp-auth` and shared by every agent that starts the same `mcp-remote` command,
so there is no `opencode mcp auth` step. On Windows, `npx` must resolve to a real executable (mise
shims do this); npm's own `npx.cmd` cannot be spawned without a shell, and the documented
workaround is `cmd /c npx -y mcp-remote …`.
Check everything with `opencode mcp list`.

## Agents

`build` is the default agent (`default_agent`). It never edits files or runs commands:
it inspects just enough context, delegates focused tasks to `worker` (implementation)
or `explore` (read-only research), then reviews their reports. To change models, edit
the `model` field in `opencode.jsonc` and the matching agent file.

`reviewer` is a subagent with the same brief as the other agents' reviewers: it reads the diff,
runs the build or tests, and reports findings with file:line without touching files (`edit` is
denied; shell stays allowed for `git diff` and tests). `build.md` tells `build` to run it before
accepting a worker's report.

## Ambient memory

The `ambient` server is the MCP endpoint inside the running [Ambient](https://alexandria.so)
desktop app (`http://127.0.0.1:8765/mcp`); its tools are unavailable when the app is closed.

`AGENTS.md` holds the same "always check Ambient memory" block Ambient writes into
Claude Code's `CLAUDE.md` and Codex's `AGENTS.md`. Ambient does not manage opencode,
so copy it into `~/.config/opencode/AGENTS.md` yourself.

The block is not refreshed when the app's wording changes: copy it again from
`ambient-app/electron/agent-global-instructions.ts` when needed.
