---
description: OpenCode setup with providers, themes, MCP/LSP servers; oh-my-opencode removed, ocx retained
applyTo: "config/home/coding/opencode/**"
---

## Overview

OpenCode setup with provider configs, themes, formatters, MCP/LSP servers. ocx is retained as the profile switcher; oh-my-opencode plugin is removed.

## Where to Look

| Task | Location | Notes |
|------|----------|-------|
| Package + ocx install | setup.nix | Installs opencode and ocx binaries |
| Providers | providers.nix | Provider definitions and defaults |
| LSP/MCP | lsp.nix, mcp.nix | Server definitions for OpenCode |
| Themes | themes/default.nix, themes/ultraviolet.json | UI themes |
| Formatters | formatters.nix | Output formatting for OpenCode |
| TUI | tui.nix | Terminal UI settings |
| Settings | settings.nix | Core OpenCode settings (plugins: antigravity-auth, beads, pty) |
| Common generator | common.nix | Tool-specific mk* generator using _common data |

## Conventions

- Naming: kebab-case options/attrs; avoid new arbitrary keys without consumers.

## Anti-Patterns

- Do not hand-edit generated config files; edit Nix definitions instead.

## Notes

- ocx is installed via `customLib.mkPnpmDlxBin` in `setup.nix` alongside opencode.
