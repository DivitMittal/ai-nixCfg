# CONFIG/REPL/OPENCODE

## OVERVIEW
OpenCode setup with oh-my-opencode profile system, provider configs, themes, formatters, MCP/LSP servers, memory, and activation symlinks.
oh-my-opencode plugin for opencode inherits: commands skills agents hooks plugins from claude-code automatically.

## WHERE TO LOOK
| Task | Location | Notes |
|------|----------|-------|
| Profile system | oh-my-opencode.nix | 9 profiles; agent→model mappings; mkProfileFiles generates JSONC; home.activation symlinks current profile |
| Providers | providers.nix | Provider definitions and defaults |
| LSP/MCP | lsp.nix, mcp.nix | Server definitions for OpenCode |
| Memory | memory.nix | Memory backend settings |
| Themes | themes/default.nix, themes/ultraviolet.json | UI themes |
| Formatters | formatters.nix | Output formatting for OpenCode |

## CONVENTIONS
- Profiles: attrset `profiles` with `agents` mapping; uses `foldl'` and `recursiveUpdate` to merge defaults.
- File emission: mkProfileFiles writes `~/.config/opencode/profiles/<profile>/oh-my-opencode.jsonc` and `ghost.jsonc`; activation symlinks `profiles/current` to selected profile.
- Model mapping: keep agent keys consistent across profiles; prefer extending defaults over redefining.
- Naming: kebab-case for profile names and agents; avoid new arbitrary keys without consumers.

## ANTI-PATTERNS
- Do not hand-edit generated profile files; edit Nix definitions instead.
- Avoid diverging agent lists between profiles unless intentional; mismatches break symlinked current profile.
- Do not bypass activation hook; symlink management lives in oh-my-opencode.nix.

## NOTES
- After profile edits, ensure activation renders: `home-manager switch` (or flake apply) to refresh symlinks/files.
