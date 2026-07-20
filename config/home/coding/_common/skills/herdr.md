# Herdr

Herdr is a terminal multiplexer and runtime for coding agents. It organizes terminals into workspaces, tabs, and panes, detects agent identity and status, and exposes the running session through the `herdr` CLI.

Before issuing any control command, check that this agent is running inside a Herdr-managed pane:

```bash
test "${HERDR_ENV:-}" = 1
```

If the check fails, say that you are not running inside Herdr and stop. Do not inspect or control the focused Herdr session from outside Herdr. When the check passes, the `herdr` binary in `PATH` talks to the running session.

## Learn the current CLI

The installed binary is the authority for command syntax. Begin with:

```bash
herdr --help
```

Then print the relevant command group by running it without a subcommand:

```bash
herdr pane
herdr workspace
herdr worktree
herdr tab
herdr wait
herdr terminal
herdr notification
herdr integration
herdr session
```

Do not run bare `herdr` for discovery; it launches or attaches the TUI. Do not probe a mutating nested command by omitting arguments; some commands, including `herdr workspace create`, are valid with defaults and will execute. Use the command-group output above instead.

Most control commands print JSON. Read identifiers and state from those responses instead of predicting either one.

## IDs and current context

Public IDs are short stable handles:

- workspace: `w1`
- tab: `w1:t1`
- pane: `w1:p1`
- terminal: `term_...`

The encoded suffix can contain letters and can grow beyond one character. Treat every ID as an opaque string. Closed tab and pane IDs are not reused and do not retarget later resources. A pane moved into another workspace receives a new public pane ID. Re-read create, split, move, list, or get responses after mutations; never construct an ID from a workspace or display number.

Herdr injects the caller's stable context into every managed pane:

```bash
printf '%s\n' "$HERDR_WORKSPACE_ID" "$HERDR_TAB_ID" "$HERDR_PANE_ID"
```

Prefer `--current` when a pane command should target the calling pane. Omitting a target can use the UI-focused pane, which may belong to the user or another client.

Discover live state with:

```bash
herdr workspace list
herdr tab list --workspace "$HERDR_WORKSPACE_ID"
herdr pane current --current
herdr pane list --workspace "$HERDR_WORKSPACE_ID"
```

## Control agents through panes

An agent runs inside a pane. Use the pane ID as the control target for agents, shells, servers, tests, and logs. This keeps spawning, input, reads, waits, and cleanup on one stable control surface.

Use workspace and tab commands for organization. Use worktree commands only when you intentionally want Herdr to create, open, or remove a Git checkout. Pane records expose `agent`, `agent_status`, and native session metadata when available. Agent status is `idle`, `working`, `blocked`, `done`, or `unknown`.

`idle` and `done` are the same underlying semantic state with different attention state:

- `idle`: the agent is waiting and its result is considered seen.
- `done`: the agent finished and its result has not been seen.

Always treat either `idle` or `done` as completed when inspecting `pane get`; the difference is whether the result has been seen. If a wait times out, inspect `herdr pane get <pane-id>` and `herdr pane read <pane-id>` before deciding what to do. A `blocked` agent needs input; an `unknown` pane may not yet contain a detected or integrated agent.

## Start agents or commands

Default to a sibling pane in the current tab and current working directory. Do not create a workspace, tab, worktree, or different cwd unless the user explicitly requests that topology or location.

Use the caller's layout to choose a direction:

```bash
herdr pane layout --pane "$HERDR_PANE_ID"
```

Split without moving the user's focus:

```bash
herdr pane split --current --direction right --no-focus
```

Read the new `pane_id` from the JSON response. Label it and start the requested agent with its normal executable:

```bash
herdr pane rename <returned-pane-id> "reviewer"
herdr pane run <returned-pane-id> "codex"
```

Supported agent executables include `codex`, `claude`, `pi`, `opencode`, and `omp`. Do not pass the task as an argv prompt or add non-interactive flags by default. Inspect the pane after launch, wait for `idle` if necessary, then submit the task with `pane run`.

For background work, wait for `done` (or `idle` when the user is watching), then read the transcript:

```bash
herdr wait agent-status <pane-id> --status done --timeout 120000
herdr pane read <pane-id> --source recent-unwrapped --lines 120
```

## Run commands and wait

Use `pane run` to send a command, then inspect existing output before waiting for future output:

```bash
herdr pane run <pane-id> "just test"
herdr wait output <pane-id> --match "test result" --timeout 120000
herdr pane read <pane-id> --source recent-unwrapped --lines 120
```

Use `--current` or an explicit ID. Do not rely on another client's focused pane. Use `recent-unwrapped` for logs and transcripts; use `visible` for the current viewport and `detection` for agent detection. A wait timeout exits with status `1`.

## Safety and coordination

- Use `--no-focus` for background work unless the user asked to switch context.
- Parse IDs from JSON responses; do not derive them from sidebar order or examples.
- Do not close workspaces, tabs, panes, or sessions you did not create unless the user explicitly asked.
- Never run `herdr server stop` from an active session unless the user explicitly intends to stop the server and its pane processes.
- Never kill the main Herdr process. Use named test sessions for experiments that need an isolated server.
