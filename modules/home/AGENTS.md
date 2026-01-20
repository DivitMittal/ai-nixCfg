# MODULES/HOME NOTES

## OVERVIEW
Reusable home-manager modules: claude-code, codex, github-copilot, crush. Each follows standard Nix module header with typed options and `cfg.enable` gating.

## WHERE TO LOOK
| Task | Location | Notes |
|------|----------|-------|
| Output styles | modules/home/claude-code.nix | Writes ~/.claude/output-styles/* from attrsOf strings |
| Codex prompts/skills | modules/home/codex.nix | Emits XDG markdown files via xdg.configFile |
| Copilot CLI | modules/home/github-copilot.nix | mcpServers (local/http), permissionsType, settingsType, commands |
| Crush assistant | modules/home/crush.nix | lspServerType, mcpServerType, permissionsType; JSON generation |
| Export wiring | modules/home/default.nix | Uses customLib.scanPaths ./ for auto-import |

## CONVENTIONS
- Header: `{ config, lib, pkgs, ... }: let inherit (lib) mkIf mkOption types; cfg = config.programs.<name>; in { ... }`.
- Types: lib.types.* with descriptions; use submodules for nested records (mcpServerType, permissionsType, lspServerType).
- Conditionals: `config = mkIf cfg.enable { ... };` ; use `filterAttrs` to drop nulls; `optionalAttrs` for gated blocks.
- File emission: `home.file` for dotfiles; `xdg.configFile` for XDG paths; `pkgs.formats.json {}` for generated JSON.
- Naming: kebab-case options, concise locals; no `with`.

## ANTI-PATTERNS
- Do not duplicate submodule definitions; reuse patterns across modules.
- Avoid hand-rolled path strings outside XDG/home.file helpers.
- Do not bypass cfg.enable guards.

## NOTES
- Copilot/Crush modules are the most type-heavy; follow existing submodule shapes when adding servers or permissions.
