# MODULES/HOME NOTES

## OVERVIEW

Reusable home-manager modules: claude-code, codex, crush, hermes-agent, openclaw. Each follows standard Nix module header with typed options and `cfg.enable` gating. Auto-imported via `import-tree` in `default.nix`.

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Claude Code module | modules/home/claude-code.nix | output-styles (attrsOf strings → ~/.claude/output-styles/\*) |
| Codex module | modules/home/codex.nix | Emits XDG markdown files (prompts/skills) via xdg.configFile |
| Crush module | modules/home/crush.nix | lspServerType, mcpServerType, permissionsType; JSON generation |
| Hermes Agent module | modules/home/hermes-agent.nix | YAML config → ~/.hermes/config.yaml; mcp (attrsOf mcpServerType) |
| OpenClaw extension | modules/home/openclaw.nix | Extension for nix-openclaw upstream; extraBootstrapFiles → workspace dir |
| Auto-import wiring | modules/home/default.nix | import-tree ./home auto-imports all .nix files |

## CONVENTIONS

- Header: `{ config, lib, pkgs, ... }: let inherit (lib) mkIf mkOption types; cfg = config.programs.<name>; in { ... }`.
- Types: lib.types.\* with descriptions; use submodules for nested records (mcpServerType, permissionsType, lspServerType).
- Conditionals: `config = mkIf cfg.enable { ... };`; use `filterAttrs` to drop nulls; `optionalAttrs` for gated blocks.
- File emission: `home.file` for dotfiles; `xdg.configFile` for XDG paths; `pkgs.formats.json {}` for generated JSON.
- Naming: kebab-case options, concise locals; no `with`.

## ANTI-PATTERNS

- Do not duplicate submodule definitions; reuse patterns across modules.
- Avoid hand-rolled path strings outside XDG/home.file helpers.
- Do not bypass cfg.enable guards.

## NOTES

- Crush/hermes-agent are the most type-heavy; follow existing submodule shapes when adding MCP server types.
- openclaw.nix is an *extension* module — it adds options to the `programs.openclaw` namespace from the
  upstream nix-openclaw module without re-declaring options that upstream already owns.
- There is no module for Gemini, OpenCode, or Pi — those are config-only (in config/home/repl/).
- Do NOT re-add `github-copilot-cli` to modules/default.nix individual exports; that file does not exist.
