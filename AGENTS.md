# PROJECT KNOWLEDGE BASE

## OVERVIEW
Nix flake with home-manager modules and personal configs for AI coding assistants (Claude Code, Codex, GitHub Copilot CLI, Gemini, OpenCode, Crush), LLM CLI/workflow tools, and custom packages (bv-bin, gowa). Uses flake-parts, home-manager, treefmt-nix, git-hooks, actions-nix, nix-direnv; imports customLib from OS-nixCfg for scanPaths.

## STRUCTURE
```
./
├── flake/                 # flake-parts modules: actions/, checks.nix, devshells.nix, formatters.nix
├── modules/               # reusable home-manager modules (claude-code, codex, github-copilot, crush)
├── config/                # personal configs: repl/ per tool, cli/, cloud.nix, mcp.nix, workflows.nix, setup.nix
├── pkgs/                  # custom packages (bv-bin, gowa) + default export
├── .github/workflows/     # autogen from flake/actions (do not hand-edit)
└── AGENTS.md              # this file
```

## WHERE TO LOOK
| Task | Location | Notes |
|------|----------|-------|
| Add/understand modules | modules/home/*.nix | Follow standard header; typed options; mkIf cfg.enable |
| AI REPL generators | config/repl/common/default.nix | Shared commands/skills/agents/rules factory (380 lines) |
| OpenCode profiles | config/repl/opencode/oh-my-opencode.nix | Profile/model mappings; symlink logic |
| Tool configs | config/repl/{claude,codex,copilot,crush,gemini,opencode}/ | Each imports common outputs |
| CLI tools | config/cli/*.nix | aichat, mods, fabric, vcs |
| CI/formatting/hooks | flake/actions/*, flake/formatters.nix, flake/checks.nix | Render workflows via nix run .#render-workflows |

## CODE MAP
| Symbol | Type | Location | Role |
|--------|------|----------|------|
| mkClaudeCommand/mkCodexPrompt/... | functions | config/repl/common/default.nix | Generate tool-specific frontmatter + files |
| mcpServerType/permissionsType | submodules | modules/home/{github-copilot,crush}.nix | Typed MCP/LSP/permission configs |
| mkProfileFiles | function | config/repl/opencode/oh-my-opencode.nix | Emit profile files + activation symlinks |

## CONVENTIONS
- Module header: `{ config, lib, pkgs, ... }: let inherit (lib) mkIf mkOption types; cfg = config.programs.<name>; in { options = {...}; config = mkIf cfg.enable {...}; }`
- Types: lib.types.* with descriptions; literalExpression for examples; prefer submodules for nested records.
- Conditionals/merging: mkIf, mkMerge, optionalAttrs, filterAttrs; avoid `with`.
- Naming: kebab-case options/attrs; concise locals (`cfg`). Paths via xdg.configFile or home.file; use pkgs.formats.json {} for generated JSON.
- Formatting: `nix fmt` (alejandra + deadnix + statix); .editorconfig enforces UTF-8, LF, 2-space, trim trailing whitespace.

## ANTI-PATTERNS (PROJECT)
- Do not hand-edit `.github/workflows/*` (render via Nix).
- Do not commit secrets; use agenix/ragenix; `.env` must stay ignored.
- No force-push to main; Conventional Commits required.
- Avoid deep nesting; prefer early returns and explicit error handling.

## UNIQUE STYLES
- `customLib.scanPaths` auto-import pattern in flake/, modules/home/, flake/actions/.
- Shared content factory in `config/repl/common/default.nix` emits commands/skills/agents/rules for multiple tools.
- OpenCode profile system generates per-profile JSONC and manages symlinked current profile.

## COMMANDS
```bash
nix fmt
nix -vL flake check --impure --all-systems --no-build
nix build .#<attr>
nix develop
nix run .#render-workflows
nix run .#pre-commit
```

## NOTES
- Primary validation via flake check; no traditional unit tests.
- Direnv enabled (.envrc) for nix-direnv; allow before working.
- If modifying flake/actions, rerun `nix run .#render-workflows` and commit YAML outputs.
