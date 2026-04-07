# CONFIG/REPL/COMMON

## OVERVIEW
Pure data library: shared metadata, content readers, and lib helpers. Tool-specific generation logic lives in each tool's `common.nix`, not here.

## WHERE TO LOOK
| Task | Location | Notes |
|------|----------|-------|
| Command templates | commands/*.md | commit, pr, changelog, review, refactor, test, build, clean, explain, doc, fix-issue, human-code-refactor |
| Skills | skills/*.md | nix-flakes, home-manager-modules, conventional-commits |
| Agents | agents/*.md | code-reviewer, nix-expert, security-auditor, test-writer |
| Rules | rules/*.md | git-workflow, security, documentation, code-quality |
| Metadata definitions | commands/default.nix, skills/default.nix, agents/default.nix | commandMeta, skillMeta, agentMeta |
| Shared helpers | lib.nix | mkYamlFrontmatter, memoryInstruction, read* functions |
| Tool generators | ../../{claude,codex,copilot,gemini,opencode,crush}/common.nix | Each tool owns its mk* generators |

## CONVENTIONS
- `common/` exports pure data: metadata attrsets + content readers. No tool-specific generation here.
- Each tool's `common.nix` imports `../common` and uses `common.lib`, `common.commands`, `common.skills`, `common.agents`, `common.rules`.
- Formatting: YAML/TOML frontmatter is assembled in each tool's `common.nix` via `mkYamlFrontmatter`.
- Keep content DRY: edits to command/skill/agent/rule text happen in common markdown only.

## ANTI-PATTERNS
- Do not add tool-specific generators or pre-generated sets to `common/`; they belong in each tool dir.
- Do not duplicate command text in tool-specific dirs; modify common markdown instead.
- No broad reads of reference files; load only what is needed per instructions.

## NOTES
- Changes to metadata (commandMeta, skillMeta, agentMeta) ripple across all tools via each tool's generator.
- Validate by evaluating one tool's `common.nix` directly: `nix eval --impure --expr 'import ./claude/common.nix {...}'`.
