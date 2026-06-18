---
description: OpenCode setup with oh-my-opencode profile system, providers, themes, and MCP/LSP servers
applyTo: "config/home/coding/opencode/**"
---

## Overview

OpenCode setup with oh-my-opencode profile system, provider configs, themes, formatters, MCP/LSP servers, and activation symlinks. The oh-my-opencode plugin for opencode inherits commands, skills, agents, hooks, and plugins from claude-code automatically.

## Where to Look

| Task | Location | Notes |
|------|----------|-------|
| Profile system | oh-my-opencode.nix | 8 profiles (claude, codex, gemini, agy, ghcp, glm, openrouter, zen); agent→model mappings; mkProfileFiles generates JSONC; home.activation symlinks current profile |
| Providers | providers.nix | Provider definitions and defaults |
| LSP/MCP | lsp.nix, mcp.nix | Server definitions for OpenCode |
| Themes | themes/default.nix, themes/ultraviolet.json | UI themes |
| Formatters | formatters.nix | Output formatting for OpenCode |
| TUI | tui.nix | Terminal UI settings |
| Settings | settings.nix | Core OpenCode settings |
| Common generator | common.nix | Tool-specific mk* generator using _common data |

## Conventions

- Profiles: attrset `profiles` with agent→model mappings per profile; `foldl'` over profile names to emit all files.
- File emission: `mkProfileFiles` writes `~/.config/opencode/profiles/<profile>/oh-my-opencode.jsonc` and `ocx.jsonc`; activation symlinks `profiles/current` to selected profile.
- Model mapping: keep agent keys consistent across profiles (defined in `agentNames`); prefer extending defaults over redefining.
- Naming: kebab-case for profile names and agents; avoid new arbitrary keys without consumers.

## Anti-Patterns

- Do not hand-edit generated profile files; edit Nix definitions instead.
- Avoid diverging agent lists between profiles unless intentional; mismatches break the symlinked current profile.
- Do not bypass the activation hook; symlink management lives in `oh-my-opencode.nix`.

## Notes

- After profile edits, ensure activation renders: run `home-manager switch` (or flake apply) to refresh symlinks/files.
- `agentNames` list in `oh-my-opencode.nix` is the canonical set of agents; all profiles must cover each name.
