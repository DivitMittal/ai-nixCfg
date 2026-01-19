Guidance for agentic coding workflows in this repository. Keep responses concise, follow the established Nix/home-manager patterns, and respect the security and git rules below.

## Build / Lint / Test
- Dev shell: `nix develop`
- Build (flake): `nix build`
- Build (macOS system): `darwin-rebuild build --flake .`
- Check (primary test): `nix flake check`
- CI variant: `nix -vL flake check --impure --all-systems --no-build`
- Format everything: `nix fmt` (treefmt: alejandra, deadnix, statix)
- Single-file format/lint:
  - Nix format: `alejandra <file>`
  - Nix lint: `statix check <file>`
  - Nix dead code: `deadnix <file>`
- Pre-commit hooks: `pre-commit run --all-files`
- Other language scaffolding (detected in commands):
  - JS/TS/JSON/HTML/CSS/MD/YAML: prettier (`--stdin-filepath` usage)
  - Python: black (`-` stdin)
  - Shell: shfmt
  - Lua: stylua (`-` stdin)
  - C/C++: clang-format
  - Fish: fish_indent
  - Haskell: ormolu
  - Swift: swift-format

## Tooling Locations
- Nix formatters: flake/formatters.nix (treefmt with alejandra, deadnix, statix; treefmt hook disabled in pre-commit)
- Pre-commit: flake/checks.nix (trim trailing whitespace, BOM fix, shebang checks, detect private keys, case conflicts, etc.)
- Dev shell: flake/devshells.nix (nixd, alejandra available)
- Commands (AI prompts): myCfg/repl/claude/commands/*.md, myCfg/repl/gemini/commands/*.md, myCfg/repl/crush/commands.nix
- Formatter map for OpenCode agents: myCfg/repl/opencode/formatters.nix
- LSP map for OpenCode agents: myCfg/repl/opencode/lsp.nix
- Core style & rules memo: myCfg/repl/claude/memory.nix

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

## Formatting & EditorConfig
- .editorconfig: UTF-8, LF, 2 spaces, trim trailing whitespace, insert final newline, spelling en-US.
- Treefmt (nix fmt): alejandra + deadnix + statix; excludes .github/*.
- Single-file formatter commands (stdin where defined):
  - Nix: `alejandra <file>`
  - Dead code: `deadnix <file>`
  - Lint: `statix check <file>`
  - Web: `prettier --stdin-filepath <file>`
  - Python: `black -` (stdin) or `black <file>`
  - Shell: `shfmt <file>`
  - Lua: `stylua -` (stdin) or `stylua <file>`
  - C/C++: `clang-format <file>`
  - Fish: `fish_indent <file>`
  - Haskell: `ormolu <file>`
  - Swift: `swift-format <file>`

## Testing Notes
- Primary: `nix flake check` (no traditional unit tests in repo)
- CI flavor: `nix -vL flake check --impure --all-systems --no-build`
- Targeted builds: `nix build .#<attr>` for specific derivations.

## Git Workflow (Conventional Commits)
- Message: `type(scope): description`; imperative mood; keep atomic; reference issues when relevant (`fixes #123`).
- Branches: `feat/...`, `fix/...`; main is protected (no force push).
- Before committing: run `nix fmt`; run `nix flake check`; review diffs.
- Pre-commit hooks auto-run on commit; to run manually: `pre-commit run --all-files`.

## Security Rules
- Never commit secrets/api keys/tokens; prefer agenix/ragenix; ensure `.env` ignored.
- Validate external input; use allowlists; avoid string interpolation for commands; never log secrets.
- Nix specifics: use `lib.escapeShellArg`; avoid `builtins.fetchurl` without hash; review sandboxing/firewall for services.

## Error Handling
- Handle errors explicitly; fail fast; no silent catches; provide concise, helpful messages.
- Do not suppress type errors (no `as any`, `@ts-ignore`).

## Documentation
- Comments explain "why"; keep up to date; use `## Section` for long files.
- Nix mkOption must include `description`; document module dependencies; add usage examples in comments where non-obvious.

## Style Reminders for Agents
- Prefer pure functions; keep functions small; avoid deep nesting; use early returns.
- Keep changes minimal for bugfixes; follow existing patterns; avoid over-abstraction.
- No emojis, fancy Unicode, or decorative comments; avoid em dashes; keep output direct.

## LSP / Editor Support
- LSPs (OpenCode map): nixd, vscode-html/css/json servers, svelteserver, emmet, HLS, pylsp, lua-language-server, yaml-language-server.

## CI / Actions
- Workflow flake check: .github/workflows/flake-check.yml generated from flake/actions/flake-check.nix; runs `nix -vL flake check --impure --all-systems --no-build` with cache.
- Weekly lock update: .github/workflows/flake-lock-update.yml from flake/actions/flake-lock-update.nix.

## Interaction Patterns (AI commands)
- Quick build: see myCfg/repl/claude/commands/build.md (nix, darwin, npm, cargo)
- Quick test: see myCfg/repl/claude/commands/test.md (nix flake check primary)
- Crush commands: myCfg/repl/crush/commands.nix (git/PR/test/build/clean templates)

## When Unsure
- Follow patterns in modules/home/*.nix; mirror option shapes; keep descriptions.
- If adding new mkOption: include type, default, example (literalExpression if structured), and description.
- If touching CI/actions: match flake/actions/*.nix style and paths triggers.

## Running Single-File Checks
- Format only: `alejandra <file>` (Nix)
- Lint only: `statix check <file>`
- Dead code: `deadnix <file>`
- Formatter per language: use opencode formatter map (prettier/black/stylua/shfmt/clang-format/etc.).

## Development Environment
- Enter shell: `nix develop` (provides nixd, alejandra).
- Autoinstall pre-commit via devshell startup script (config.pre-commit.installationScript).

## Conventions Recap
- Kebab-case option names; concise locals; explicit `inherit (lib) ...`; avoid `with`.
- Use `mkIf`/`optionalAttrs`/`mkMerge` for conditionals; `filterAttrs` to drop nulls.
- Keep module outputs focused; do not over-abstract.

## File References
- README.md: overview, dev commands, formatting note.
- flake/formatters.nix: treefmt setup (alejandra, deadnix, statix).
- flake/checks.nix: pre-commit hooks.
- flake/devshells.nix: dev shell packages (nixd, alejandra).
- myCfg/repl/claude/memory.nix: detailed rules (git, security, docs, code quality).
- myCfg/repl/opencode/formatters.nix and lsp.nix: formatter/LSP maps.
- myCfg/repl/claude/commands/*.md and myCfg/repl/crush/commands.nix: operational commands.
