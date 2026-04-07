# MODULES/HOME NOTES

## OVERVIEW
Reusable home-manager modules: claude-code, codex, github-copilot, crush. Each follows standard Nix module header with typed options and `cfg.enable` gating. Auto-imported via `customLib.scanPaths` in `default.nix`.

## WHERE TO LOOK
| Task | Location | Notes |
|------|----------|-------|
| Claude Code module | modules/home/claude-code.nix | output-styles (attrsOf strings → ~/.claude/output-styles/*), hooks, settings |
| Codex module | modules/home/codex.nix | Emits XDG markdown files (prompts/skills) via xdg.configFile |
| Copilot CLI module | modules/home/github-copilot.nix | mcpServers (local/http), permissionsType, settingsType, commands |
| Crush module | modules/home/crush.nix | lspServerType, mcpServerType, permissionsType; JSON generation |
| Auto-import wiring | modules/home/default.nix | Uses customLib.scanPaths ./ for scanPaths-based import |

## CONVENTIONS
- Header: `{ config, lib, pkgs, ... }: let inherit (lib) mkIf mkOption types; cfg = config.programs.<name>; in { ... }`.
- Types: lib.types.* with descriptions; use submodules for nested records (mcpServerType, permissionsType, lspServerType).
- Conditionals: `config = mkIf cfg.enable { ... };`; use `filterAttrs` to drop nulls; `optionalAttrs` for gated blocks.
- File emission: `home.file` for dotfiles; `xdg.configFile` for XDG paths; `pkgs.formats.json {}` for generated JSON.
- Naming: kebab-case options, concise locals; no `with`.

## ANTI-PATTERNS
- Do not duplicate submodule definitions; reuse patterns across modules.
- Avoid hand-rolled path strings outside XDG/home.file helpers.
- Do not bypass cfg.enable guards.

## NOTES
- Copilot/Crush modules are the most type-heavy; follow existing submodule shapes when adding servers or permissions.
- There is no module for Gemini, OpenCode, or OpenClaw — those are config-only (in config/home/repl/).
