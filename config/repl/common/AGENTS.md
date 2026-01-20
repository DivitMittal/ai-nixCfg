# CONFIG/REPL/COMMON

## OVERVIEW
Shared generator factory (380 lines) that produces commands, skills, agents, rules for all AI tools. Central metadata lives here; tool-specific dirs consume outputs.

## WHERE TO LOOK
| Task | Location | Notes |
|------|----------|-------|
| Command templates | commands/*.md | commit, pr, changelog, review, refactor, test, build, clean, explain, doc, fix-issue, human-code-refactor |
| Skills | skills/*.md | nix-flakes, home-manager-modules, conventional-commits |
| Agents | agents/*.md | code-reviewer, nix-expert, security-auditor, test-writer |
| Rules | rules/*.md | git-workflow, security, documentation, code-quality |
| Generator logic | default.nix | mkClaudeCommand, mkCodexPrompt, mkCopilotCommand, mkGeminiCommand, mkOpenCodeCommand; mk*Skill; mk*Agent; mkYamlFrontmatter |

## CONVENTIONS
- Metadata attrsets: `commandMeta`, `skillMeta`, `agentMeta` hold base content; `lib.genAttrs` fans them out per tool.
- Formatting: YAML/TOML frontmatter per tool; avoid editing generated frontmatter fields in consumer dirs.
- File emission: `home.file` paths assembled with `lib.mapAttrs'` and `nameValuePair` helpers.
- Keep content DRY: edits should happen in common markdown, not per-tool overrides unless necessary.

## ANTI-PATTERNS
- Do not duplicate command text in tool-specific dirs; modify common markdown instead.
- Avoid adding new tools without matching mk* generator and metadata entry.
- No broad reads of reference files; load only what is needed per instructions.

## NOTES
- This is the primary complexity hotspot; changes ripple across all tools. Validate downstream by checking one sample tool (e.g., claude commands) after edits.
