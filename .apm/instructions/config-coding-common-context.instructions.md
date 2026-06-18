---
description: Pure data library with shared commands, skills, agents, rules metadata and lib helpers
applyTo: "config/home/coding/_common/**"
---

## Overview

Pure data library: shared metadata, content readers, and lib helpers. Tool-specific generation logic lives in each tool's `common.nix`, not here. Exported as a single attrset from `default.nix`.

## Where to Look

| Task | Location | Notes |
|------|----------|-------|
| Command templates | _common/commands/*.md | build, changelog, clean, commit, doc, explain, fix-issue, human-code-refactor, pr, refactor, review, test |
| Skills | _common/skills/*.md | nix-flakes, home-manager-modules, conventional-commits |
| Agents | _common/agents/*.md | code-reviewer, nix-expert, security-auditor, test-writer |
| Rules | _common/rules/*.md | code-quality, documentation, git-workflow, security |
| Metadata definitions | commands/default.nix, skills/default.nix, agents/default.nix, rules/default.nix | commandMeta, skillMeta, agentMeta; each tool's default.nix indexes its entries |
| Shared helpers | lib.nix | mkYamlFrontmatter, memoryInstruction, read* functions |
| Library entry point | default.nix | Exports `{ lib, commands, skills, agents, rules }` |
| Tool generators | ../../{claude,codex,copilot,gemini,opencode,crush}/common.nix | Each tool owns its mk* generators |

## Conventions

- `_common/` exports pure data: metadata attrsets + content readers. No tool-specific generation here.
- Each tool's `common.nix` imports `../_common` and uses `common.lib`, `common.commands`, `common.skills`, `common.agents`, `common.rules`.
- Formatting: YAML/TOML frontmatter is assembled in each tool's `common.nix` via `mkYamlFrontmatter`.
- Keep content DRY: edits to command/skill/agent/rule text happen in common markdown only.

## Anti-Patterns

- Do not add tool-specific generators or pre-generated sets to `_common/`; they belong in each tool dir.
- Do not duplicate command text in tool-specific dirs; modify common markdown instead.
- No broad reads of reference files; load only what is needed per instructions.

## Notes

- Changes to metadata (commandMeta, skillMeta, agentMeta) ripple across all tools via each tool's generator.
- Validate by evaluating one tool's `common.nix` directly: `nix eval --impure --expr 'import ./config/home/coding/claude/common.nix {...}'`.
- Directory was renamed from `common` to `_common`; update any stale references.
