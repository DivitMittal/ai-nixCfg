---
allowed-tools: Read, Grep, Glob, Bash(git diff:*)
argument-hint: [file-or-path]
description: Review code for issues
---
## Context

- Files to review: $ARGUMENTS or staged changes
- Diff: !`git diff --cached --stat 2>/dev/null || git diff HEAD --stat`

## Task

Review the code for:
1. **Bugs**: Logic errors, edge cases, null checks
2. **Security**: Input validation, secrets, injection
3. **Performance**: Unnecessary work, memory leaks
4. **Style**: Naming, complexity, documentation

Output format:
- 🔴 Critical (must fix)
- 🟡 Warning (should fix)
- 🟢 Suggestion (nice to have)
