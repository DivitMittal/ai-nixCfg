## Motive

This repository provides reusable Nix home-manager modules and personal configurations for AI coding assistants. It enables declarative, reproducible setup of tools like Claude Code, OpenAI Codex, GitHub Copilot CLI, Gemini, and others through the Nix ecosystem.

Key goals:
- Provide home-manager modules with typed options for AI assistant configuration
- Share personal configs as examples for customization
- Maintain consistent formatting, linting, and CI across all Nix code

---

Guidance for agentic coding workflows in this repository. Keep responses concise, follow the established Nix/home-manager patterns, and respect the security and git rules below.

## Nix Module Style
- File header shape:
  ```nix
  {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkIf mkOption types; # add others explicitly
    cfg = config.programs.<name>;
  in {
    options = { ... };
    config = mkIf cfg.enable { ... };
  }
  ```
- Use `lib.types.*` for mkOption; always add `description`.
- Use `literalExpression` for examples; `attrsOf`, `listOf`, `nullOr`, `enum`, `submodule` as needed.
- Prefer `mkIf` for conditional attrs; `mkMerge` for combining; `optionalAttrs` over `if-then-else {}`; `filterAttrs` to drop nulls; avoid `with`.
- Naming: options/attrs in kebab-case; local variables concise (`cfg` for config subtree).
- Imports: prefer `lib.custom.scanPaths ./` for directory defaults; module exports in modules/default.nix via `flake.homeManagerModules.*`.

## Testing Notes
- Primary: `nix flake check` (no traditional unit tests in repo)
- CI flavor: `nix -vL flake check --impure --all-systems --no-build`
- Targeted builds: `nix build .#<attr>` for specific derivations.
